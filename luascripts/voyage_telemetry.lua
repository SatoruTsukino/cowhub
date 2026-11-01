--[[
    Fjord voyage telemetry recorder.

    Passive: it never steers, moves the character or fires a remote, so it can run alongside cowhub
    or during a manually sailed voyage. Run it before setting sail. Running it again replaces the
    previous instance. To stop it: _G.CowVoyageTelemetry.Stop()

    Output, in the executor workspace:
      cowhub_telemetry/voyage_<time>_<id>.log   one file per voyage
      cowhub_telemetry/world_survey.json        wall geometry, merged across voyages

    Voyage log lines:
      H,<column names>     column names for S lines
      S,<values>           sample, SAMPLE_INTERVAL while sailing, MOORED_INTERVAL otherwise
      E,<time>,<name>,<json>  event
]]

local CONFIG = {
    SAMPLE_INTERVAL = 0.2,
    MOORED_INTERVAL = 1,
    FLUSH_INTERVAL = 2,
    SURVEY_INTERVAL = 6,
    SURVEY_SAVE_INTERVAL = 20,
    SESSION_TIMEOUT = 20,     -- seconds without a snapshot before the voyage is closed
    RAY_RANGE = 120,
    HOOK_OUTGOING = true,     -- log RaftingRequest / chest remotes; needs hookmetamethod
    SHOW_STATUS_LABEL = true,
    FOLDER = "cowhub_telemetry",
}

if _G.CowVoyageTelemetry and _G.CowVoyageTelemetry.Stop then
    pcall(_G.CowVoyageTelemetry.Stop)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local cowGame = ReplicatedStorage:WaitForChild("CowGame", 30)
assert(cowGame, "[VoyageTelemetry] ReplicatedStorage.CowGame not found")
local remotes = cowGame:WaitForChild("Remotes", 30)
assert(remotes, "[VoyageTelemetry] CowGame.Remotes not found")
local clientEvent = remotes:WaitForChild("ClientEvent", 30)
assert(clientEvent, "[VoyageTelemetry] Remotes.ClientEvent not found")

local T = {
    running = true,
    connections = {},
    pending = {},
    fileName = nil,
    sessionId = nil,
    snapshot = nil,
    snapshotAt = 0,
    lastSampleAt = 0,
    lastFlushAt = 0,
    samples = 0,
    crashes = 0,
    bumps = 0,
    seenEvents = {},
    seenKeys = {},
    observed = {},
    outgoing = {},
    errors = {},
    deck = nil,
    deckFindAt = 0,
    lastCross = nil,
    lastChannel = nil,
    lastChestKey = nil,
    survey = nil,
    surveyDirty = false,
    surveySavedAt = 0,
    surveyCounts = {},
}

local modules = {}
local shared = cowGame:FindFirstChild("Shared")
for _, name in ipairs({ "RaftingConfig", "FjordZones", "FjordStormRules", "FjordStormConfig" }) do
    pcall(function()
        modules[name] = require(shared:FindFirstChild(name))
    end)
end
local FjordZones = modules.FjordZones
local StormRules = modules.FjordStormRules
local steerSpeed = (modules.RaftingConfig and modules.RaftingConfig.SteerSpeed) or 10

----------------------------------------------------------------------------------------------------
-- Encoding
----------------------------------------------------------------------------------------------------

local jsonValue

local function jsonString(text)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(text) end)
    return ok and encoded or '"?"'
end

local function round3(n)
    return math.round(n * 1000) / 1000
end

jsonValue = function(value, depth)
    depth = depth or 0
    local kind = typeof(value)
    if kind == "nil" then
        return "null"
    elseif kind == "boolean" then
        return tostring(value)
    elseif kind == "number" then
        if value ~= value or value == math.huge or value == -math.huge then return "null" end
        return tostring(round3(value))
    elseif kind == "string" then
        return jsonString(value)
    elseif kind == "Vector3" then
        return string.format("[%.3f,%.3f,%.3f]", value.X, value.Y, value.Z)
    elseif kind == "CFrame" then
        local p, l = value.Position, value.LookVector
        return string.format('{"pos":[%.3f,%.3f,%.3f],"look":[%.3f,%.3f,%.3f]}', p.X, p.Y, p.Z, l.X, l.Y, l.Z)
    elseif kind == "Instance" then
        local ok, path = pcall(function() return value:GetFullName() end)
        return jsonString(ok and path or value.Name)
    elseif kind == "buffer" then
        return jsonString("<buffer " .. buffer.len(value) .. ">")
    elseif kind ~= "table" then
        return jsonString(tostring(value))
    end

    if depth >= 6 then return '"<deep>"' end
    local limit = if depth < 0 then math.huge else 200 -- negative depth: whole table, used by the survey
    local parts = {}
    local count = #value
    if count > 0 and next(value, count) == nil then
        for i = 1, math.min(count, limit) do
            parts[i] = jsonValue(value[i], depth + 1)
        end
        return "[" .. table.concat(parts, ",") .. "]"
    end
    for k, v in pairs(value) do
        table.insert(parts, jsonString(tostring(k)) .. ":" .. jsonValue(v, depth + 1))
        if #parts >= limit then break end
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

local function cleanText(value)
    return (string.gsub(tostring(value == nil and "" or value), "[,\r\n]", ";"))
end

----------------------------------------------------------------------------------------------------
-- File output
----------------------------------------------------------------------------------------------------

local function writeLine(line)
    if T.fileName then
        table.insert(T.pending, line)
    end
end

local function flush(force)
    local now = os.clock()
    if not T.fileName or #T.pending == 0 then return end
    if not force and (now - T.lastFlushAt) < CONFIG.FLUSH_INTERVAL then return end
    T.lastFlushAt = now
    local chunk = table.concat(T.pending, "\n") .. "\n"
    T.pending = {}
    pcall(function()
        if appendfile then
            appendfile(T.fileName, chunk)
        else
            T.fullText = (T.fullText or "") .. chunk
            writefile(T.fileName, T.fullText)
        end
    end)
end

local function logEvent(name, data, force)
    writeLine(string.format("E,%.3f,%s,%s", os.clock(), name, jsonValue(data)))
    if force then flush(true) end
end

local function logError(where, message)
    local key = where .. tostring(message)
    if T.errors[key] then return end
    T.errors[key] = true
    logEvent("ScriptError", { where = where, message = tostring(message) }, true)
    warn("[VoyageTelemetry] " .. where .. ": " .. tostring(message))
end

local function guarded(where, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then logError(where, err) end
end

local function connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(T.connections, conn)
    return conn
end

----------------------------------------------------------------------------------------------------
-- River geometry
----------------------------------------------------------------------------------------------------

-- All channels containing the point, and offsets against the one whose centre line is closest.
local function channelInfo(x, z)
    if not (FjordZones and FjordZones.Channels) then return "", nil end
    local inside = {}
    local best, bestCross, bestAlong = nil, nil, nil
    for index, ch in ipairs(FjordZones.Channels) do
        local dx, dz = x - ch[1], z - ch[2]
        local along = dx * ch[3] + dz * ch[4]
        local cross = -dx * ch[4] + dz * ch[3]
        if math.abs(along) <= ch[5] and math.abs(cross) <= ch[6] then
            table.insert(inside, tostring(index))
            if not best or math.abs(cross) < math.abs(bestCross) then
                best, bestCross, bestAlong = ch, cross, along
            end
        end
    end
    return table.concat(inside, "|"), best, bestCross, bestAlong
end

local function placeInfo(position)
    if not (FjordZones and FjordZones.Place) then return "", "" end
    local ok, place, id = pcall(FjordZones.Place, position)
    if not ok then return "", "" end
    return place or "", id or ""
end

-- Weather plus the game's gust value under two candidates for its time argument. Comparing both with
-- measured drift shows which one (if either) the server uses.
local function weatherInfo(position)
    if not (StormRules and StormRules.WeatherAt) then return "", 0, 0, 0 end
    local kind, gustEpoch, gustServer, headingOffset = "Clear", 0, 0, 0
    pcall(function()
        local mask = cowGame:GetAttribute("FjordStormMask")
        local passage = StormRules.WeatherAt(position, mask)
        if not passage then return end
        kind = StormRules.Kind(passage, mask) or "Clear"
        local seed = cowGame:GetAttribute("FjordStormSeed")
        local epoch = cowGame:GetAttribute("FjordStormEpoch")
        local now = workspace:GetServerTimeNow()
        if seed then
            gustServer = StormRules.Gust(passage, seed, now)
            gustEpoch = StormRules.Gust(passage, seed, now - (epoch or 0))
            headingOffset = math.deg(StormRules.HeadingOffset(gustEpoch, kind))
        end
    end)
    return kind, gustEpoch, gustServer, headingOffset
end

----------------------------------------------------------------------------------------------------
-- Raft and sensors
----------------------------------------------------------------------------------------------------

local function findDeck()
    if T.deck and T.deck.Parent then return T.deck end
    local now = os.clock()
    if now < T.deckFindAt then return nil end
    T.deckFindAt = now + 0.5

    local character = player.Character
    local link = character and character:FindFirstChild("CowRaftingDeck")
    if link and link:IsA("ObjectValue") and link.Value and link.Value:IsA("BasePart") then
        T.deck = link.Value
    elseif T.sessionId then
        local raft = workspace:FindFirstChild("TeamRaft_" .. tostring(T.sessionId), true)
        local deck = raft and raft:FindFirstChild("Deck")
        if deck and deck:IsA("BasePart") then T.deck = deck end
    end

    if T.deck then
        local attributes = T.deck:GetAttributes()
        logEvent("DeckFound", { path = T.deck, size = T.deck.Size, attributes = attributes }, true)
    end
    return T.deck
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
rayParams.RespectCanCollide = true

-- Name, origin on the deck in studs, direction in deck space (-Z is forward).
local RAYS = {
    { "F",  Vector3.new(0, 2.5, -14),  Vector3.new(0, 0, -1) },
    { "FL", Vector3.new(-7, 2.5, -14), Vector3.new(0, 0, -1) },
    { "FR", Vector3.new(7, 2.5, -14),  Vector3.new(0, 0, -1) },
    { "L",  Vector3.new(-6, 2.5, 0),   Vector3.new(-1, 0, 0) },
    { "R",  Vector3.new(6, 2.5, 0),    Vector3.new(1, 0, 0) },
    { "LB", Vector3.new(-6, 2.5, -12), Vector3.new(-1, 0, 0) },
    { "RB", Vector3.new(6, 2.5, -12),  Vector3.new(1, 0, 0) },
    { "LS", Vector3.new(-6, 2.5, 12),  Vector3.new(-1, 0, 0) },
    { "RS", Vector3.new(6, 2.5, 12),   Vector3.new(1, 0, 0) },
    { "O1", Vector3.new(-5, 2.5, -12), Vector3.new(-0.5736, 0, -0.8192) },
    { "O2", Vector3.new(5, 2.5, -12),  Vector3.new(0.5736, 0, -0.8192) },
}

local function castRays(deck)
    local filter = { deck }
    if deck.Parent then table.insert(filter, deck.Parent) end
    if player.Character then table.insert(filter, player.Character) end
    rayParams.FilterDescendantsInstances = filter

    local distances, names = {}, {}
    local frame = deck.CFrame
    for index, ray in ipairs(RAYS) do
        local origin = frame:PointToWorldSpace(ray[2])
        local result = workspace:Raycast(origin, frame:VectorToWorldSpace(ray[3]) * CONFIG.RAY_RANGE, rayParams)
        if result then
            distances[index] = string.format("%.1f", result.Distance)
            names[index] = cleanText(result.Instance.Name)
        else
            distances[index] = ""
            names[index] = ""
        end
    end
    return distances, names
end

local function characterInfo(deck)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root then return nil end
    local offset = deck and deck.CFrame:PointToObjectSpace(root.Position) or Vector3.zero
    return {
        position = root.Position,
        offset = offset,
        state = humanoid and humanoid:GetState().Name or "",
        floor = humanoid and humanoid.FloorMaterial.Name or "",
        health = humanoid and humanoid.Health or 0,
    }
end

----------------------------------------------------------------------------------------------------
-- Samples
----------------------------------------------------------------------------------------------------

local rayHeader = {}
for _, ray in ipairs(RAYS) do table.insert(rayHeader, "ray" .. ray[1]) end
local rayNameHeader = {}
for _, ray in ipairs(RAYS) do table.insert(rayNameHeader, "hit" .. ray[1]) end

local SAMPLE_COLUMNS = table.concat({
    "clock", "serverTime", "snapAge", "status", "reach", "place", "placeId",
    "deckX", "deckY", "deckZ", "headingDeg", "frameX", "frameZ", "frameHeadingDeg",
    "attrVelX", "attrVelZ", "attrAngY", "speed", "steering", "boosting", "propulsion",
    "health", "maxHealth", "energy", "lowEnergy", "adrift", "overboard", "crash", "bump", "damagedStations", "yourRepair",
    "channels", "channelReach", "cross", "along", "channelHeadingDeg", "crossSpeed", "drift",
    "weather", "gustEpoch", "gustServer", "headingOffsetDeg",
    "cowX", "cowY", "cowZ", "cowDeckX", "cowDeckY", "cowDeckZ", "cowState", "cowFloor", "cowHealth",
    table.concat(rayHeader, ","), table.concat(rayNameHeader, ","),
}, ",")

local function damagedStations(snap)
    local ids = {}
    for _, station in ipairs(snap.RepairStations or {}) do
        if station.Damaged then
            table.insert(ids, tostring(station.Id) .. ":" .. string.format("%.2f", station.Progress or 0))
        end
    end
    return table.concat(ids, "|")
end

local function headingOf(vector)
    return math.deg(math.atan2(vector.Z, vector.X))
end

local function takeSample(now, dt)
    local snap = T.snapshot
    if not snap then return end
    local deck = findDeck()

    local position, heading
    if deck then
        position = deck.Position
        heading = headingOf(deck.CFrame.LookVector)
    elseif typeof(snap.Frame) == "CFrame" then
        position = snap.Frame.Position
        heading = headingOf(snap.Frame.LookVector)
    end
    if not position then return end

    local frameX, frameZ, frameHeading = "", "", ""
    if typeof(snap.Frame) == "CFrame" then
        frameX = string.format("%.2f", snap.Frame.Position.X)
        frameZ = string.format("%.2f", snap.Frame.Position.Z)
        frameHeading = string.format("%.2f", headingOf(snap.Frame.LookVector))
    end

    local attrVel = deck and deck:GetAttribute("RaftLinearVelocity")
    local attrAng = deck and deck:GetAttribute("RaftAngularVelocity")
    local place, placeId = placeInfo(position)
    local channels, channel, cross, along = channelInfo(position.X, position.Z)

    local crossSpeed, drift = "", ""
    if cross and channel == T.lastChannel and T.lastCross and dt > 0 and dt < 1 then
        local measured = (cross - T.lastCross) / dt
        crossSpeed = string.format("%.2f", measured)
        drift = string.format("%.2f", measured - steerSpeed * (snap.Steering or 0))
    end
    T.lastCross, T.lastChannel = cross, channel

    local weather, gustEpoch, gustServer, headingOffset = weatherInfo(position)
    local cow = characterInfo(deck)
    local distances, names = {}, {}
    if deck then
        distances, names = castRays(deck)
    end
    for index in ipairs(RAYS) do
        distances[index] = distances[index] or ""
        names[index] = names[index] or ""
    end

    local values = {
        string.format("%.3f", now),
        string.format("%.3f", workspace:GetServerTimeNow()),
        string.format("%.3f", now - T.snapshotAt),
        cleanText(snap.Status), cleanText(snap.Reach), cleanText(place), cleanText(placeId),
        string.format("%.2f", position.X), string.format("%.2f", position.Y), string.format("%.2f", position.Z),
        string.format("%.2f", heading), frameX, frameZ, frameHeading,
        typeof(attrVel) == "Vector3" and string.format("%.2f", attrVel.X) or "",
        typeof(attrVel) == "Vector3" and string.format("%.2f", attrVel.Z) or "",
        typeof(attrAng) == "Vector3" and string.format("%.3f", attrAng.Y) or "",
        string.format("%.2f", snap.Speed or 0), string.format("%.3f", snap.Steering or 0),
        cleanText(snap.Boosting), cleanText(snap.Propulsion),
        cleanText(snap.Health), cleanText(snap.MaxHealth), string.format("%.2f", snap.Energy or 0),
        cleanText(snap.LowEnergy), cleanText(snap.Adrift), cleanText(snap.Overboard),
        cleanText(snap.CrashSerial), cleanText(snap.BumpSerial),
        damagedStations(snap), snap.YourRepair and "1" or "",
        channels, channel and tostring(channel[7]) or "",
        cross and string.format("%.2f", cross) or "", along and string.format("%.2f", along) or "",
        channel and string.format("%.2f", math.deg(math.atan2(channel[4], channel[3]))) or "",
        crossSpeed, drift,
        weather, string.format("%.3f", gustEpoch), string.format("%.3f", gustServer), string.format("%.2f", headingOffset),
        cow and string.format("%.2f", cow.position.X) or "",
        cow and string.format("%.2f", cow.position.Y) or "",
        cow and string.format("%.2f", cow.position.Z) or "",
        cow and string.format("%.2f", cow.offset.X) or "",
        cow and string.format("%.2f", cow.offset.Y) or "",
        cow and string.format("%.2f", cow.offset.Z) or "",
        cow and cleanText(cow.state) or "", cow and cleanText(cow.floor) or "",
        cow and string.format("%.1f", cow.health) or "",
        table.concat(distances, ","), table.concat(names, ","),
    }
    writeLine("S," .. table.concat(values, ","))
    T.samples += 1
end

----------------------------------------------------------------------------------------------------
-- World survey: wall geometry as streaming loads it
----------------------------------------------------------------------------------------------------

local function outputPath(name)
    return (T.useFolder and (CONFIG.FOLDER .. "/") or "") .. name
end

local function surveyPath()
    return outputPath("world_survey.json")
end

local function loadSurvey()
    if T.survey then return end
    T.survey = { facades = {}, cutawayWalls = {}, cutawayBounds = {} }
    if isfile and readfile and isfile(surveyPath()) then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(surveyPath())) end)
        if ok and type(decoded) == "table" then
            T.survey.facades = decoded.facades or T.survey.facades
            T.survey.cutawayWalls = decoded.cutawayWalls or T.survey.cutawayWalls
            T.survey.cutawayBounds = decoded.cutawayBounds or T.survey.cutawayBounds
        end
    end
end

local function partRecord(part)
    local p, s, l = part.Position, part.Size, part.CFrame.LookVector
    return {
        round3(p.X), round3(p.Y), round3(p.Z), round3(s.X), round3(s.Y), round3(s.Z),
        round3(math.deg(math.atan2(l.X, l.Z))), part.ClassName, part.Name, part.CanCollide,
    }
end

local function partKey(part)
    local p = part.Position
    return string.format("%s_%.1f_%.1f_%.1f", part.Name, p.X, p.Y, p.Z)
end

local function surveyFacades(fjord)
    local wall = fjord:FindFirstChild("Cliff Wall")
    if not wall then return end
    for _, cell in ipairs(wall:GetChildren()) do
        local key = "wall/" .. cell.Name
        local descendants = cell:GetDescendants()
        if #descendants ~= T.surveyCounts[key] then
            T.surveyCounts[key] = #descendants
            for _, part in ipairs(descendants) do
                if part:IsA("BasePart") then
                    local id = partKey(part)
                    if not T.survey.facades[id] then
                        T.survey.facades[id] = partRecord(part)
                        T.surveyDirty = true
                    end
                end
            end
        end
    end
end

-- Only collidable cutaway parts at hull height: cutaways hold thousands of decorative parts.
local function surveyCutaways(fjord)
    local cutaways = fjord:FindFirstChild("Cutaways")
    if not cutaways then return end
    for _, model in ipairs(cutaways:GetChildren()) do
        local key = "cut/" .. model.Name
        local descendants = model:GetDescendants()
        if #descendants ~= T.surveyCounts[key] then
            T.surveyCounts[key] = #descendants
            local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
            for index, part in ipairs(descendants) do
                if part:IsA("BasePart") then
                    local p = part.Position
                    minX, maxX = math.min(minX, p.X), math.max(maxX, p.X)
                    minZ, maxZ = math.min(minZ, p.Z), math.max(maxZ, p.Z)
                    local halfY = part.Size.Y / 2
                    if part.CanCollide and p.Y - halfY <= 712 and p.Y + halfY >= 696 then
                        local id = model.Name .. "_" .. partKey(part)
                        if not T.survey.cutawayWalls[id] then
                            T.survey.cutawayWalls[id] = partRecord(part)
                            T.surveyDirty = true
                        end
                    end
                end
                if index % 500 == 0 then task.wait() end
            end
            if minX < math.huge then
                T.survey.cutawayBounds[model.Name] = { round3(minX), round3(maxX), round3(minZ), round3(maxZ) }
                T.surveyDirty = true
            end
        end
    end
end

local function saveSurvey(force)
    if not T.survey or not T.surveyDirty or not writefile then return end
    local now = os.clock()
    if not force and (now - T.surveySavedAt) < CONFIG.SURVEY_SAVE_INTERVAL then return end
    T.surveySavedAt = now
    T.surveyDirty = false
    local ok, err = pcall(function()
        writefile(surveyPath(), jsonValue(T.survey, -100))
    end)
    if not ok then logError("saveSurvey", err) end
end

----------------------------------------------------------------------------------------------------
-- Voyage lifecycle
----------------------------------------------------------------------------------------------------

local function stormAttributes()
    return {
        mask = cowGame:GetAttribute("FjordStormMask"),
        seed = cowGame:GetAttribute("FjordStormSeed"),
        epoch = cowGame:GetAttribute("FjordStormEpoch"),
        serverTime = workspace:GetServerTimeNow(),
    }
end

local function startSession(id)
    T.sessionId = id
    T.observed = {}
    T.seenKeys = {}
    T.seenEvents = {}
    T.pending = {}
    T.fullText = nil
    T.samples, T.crashes, T.bumps = 0, 0, 0
    T.deck = nil
    T.deckFindAt = 0
    T.lastCross, T.lastChannel = nil, nil
    T.lastChestKey = nil

    if makefolder and not (isfolder and isfolder(CONFIG.FOLDER)) then
        pcall(makefolder, CONFIG.FOLDER)
    end
    T.useFolder = isfolder ~= nil and isfolder(CONFIG.FOLDER)
    T.fileName = outputPath(string.format("voyage_%d_%s.log", os.time(), string.sub(tostring(id), 1, 8)))
    pcall(writefile, T.fileName, "")

    writeLine("H," .. SAMPLE_COLUMNS)
    logEvent("SessionStart", {
        id = id,
        placeVersion = game.PlaceVersion,
        userId = player.UserId,
        storm = stormAttributes(),
    })
    if modules.RaftingConfig then logEvent("RaftingConfig", modules.RaftingConfig) end
    if modules.FjordStormConfig then logEvent("FjordStormConfig", modules.FjordStormConfig) end
    logEvent("CowGameAttributes", cowGame:GetAttributes())
    logEvent("PlayerAttributes", player:GetAttributes())
    flush(true)
    print("[VoyageTelemetry] Recording to " .. T.fileName)
end

local function endSession(reason)
    if not T.fileName then return end
    logEvent("SessionEnd", {
        reason = reason,
        samples = T.samples,
        crashes = T.crashes,
        bumps = T.bumps,
        lastSnapshot = T.snapshot,
    }, true)
    saveSurvey(true)
    print(string.format("[VoyageTelemetry] Closed %s (%s): %d samples, %d crashes", T.fileName, tostring(reason), T.samples, T.crashes))
    T.lastFileName = T.fileName
    T.fileName = nil
    T.endedId = T.sessionId
    T.sessionId = nil
    T.snapshot = nil
end

local WATCHED_FIELDS = {
    "Status", "Reach", "SiteKind", "SiteId", "Level", "Adrift", "Overboard", "LowEnergy", "AllAboard",
    "Boosting", "Repairing", "Propulsion", "AutoDepart",
}

-- A snapshot is ~4 Hz, so log what changed rather than every copy.
local function observeSnapshot(snap)
    local seen = T.observed
    for key in pairs(snap) do
        if not T.seenKeys[key] then
            T.seenKeys[key] = true
            logEvent("NewSnapshotKey", { key = key, value = snap[key] })
        end
    end

    local deck = T.deck
    local context = {
        x = typeof(snap.Frame) == "CFrame" and snap.Frame.Position.X or nil,
        z = typeof(snap.Frame) == "CFrame" and snap.Frame.Position.Z or nil,
        speed = snap.Speed,
        steering = snap.Steering,
    }

    for _, key in ipairs(WATCHED_FIELDS) do
        if snap[key] ~= seen[key] then
            logEvent("Change", { field = key, from = seen[key], to = snap[key], at = context }, key == "Status")
            seen[key] = snap[key]
        end
    end

    if seen.Health ~= nil and snap.Health ~= seen.Health then
        logEvent("Health", { from = seen.Health, to = snap.Health, delta = (snap.Health or 0) - seen.Health, at = context }, true)
    end
    seen.Health = snap.Health

    local crash = snap.CrashSerial or 0
    if seen.CrashSerial ~= nil and crash ~= seen.CrashSerial then
        T.crashes += 1
        local rayDistances, rayNames = nil, nil
        if deck then rayDistances, rayNames = castRays(deck) end
        logEvent("Crash", {
            serial = crash, health = snap.Health, at = context, heading = deck and headingOf(deck.CFrame.LookVector),
            deckPosition = deck and deck.Position, rayDistances = rayDistances, rayNames = rayNames,
        }, true)
    end
    seen.CrashSerial = crash

    local bump = snap.BumpSerial or 0
    if seen.BumpSerial ~= nil and bump ~= seen.BumpSerial then
        T.bumps += 1
        logEvent("Bump", { serial = bump, health = snap.Health, at = context, deckPosition = deck and deck.Position }, true)
    end
    seen.BumpSerial = bump

    local damaged = damagedStations(snap)
    if damaged ~= seen.damaged then
        logEvent("Stations", { damaged = damaged, yourRepair = snap.YourRepair, stations = snap.RepairStations })
        seen.damaged = damaged
    end

    local crewKey = jsonValue(snap.Crew)
    if crewKey ~= seen.crew then
        logEvent("Crew", snap.Crew)
        seen.crew = crewKey
    end
end

local function dockDetails(snap)
    local deck = findDeck()
    local details = { snapshot = snap, storm = stormAttributes() }
    if deck then
        local distances, names = castRays(deck)
        details.deckPosition = deck.Position
        details.deckLook = deck.CFrame.LookVector
        details.rayDistances = distances
        details.rayNames = names
        details.place = { placeInfo(deck.Position) }
    end
    logEvent("Docked", details, true)
end

local function onSnapshot(snap)
    if type(snap) ~= "table" or (snap.Id and snap.Id == T.endedId) then return end
    if snap.Id and snap.Id ~= T.sessionId then
        endSession("new session")
        startSession(snap.Id)
        logEvent("FirstSnapshot", snap)
    end
    local previousStatus = T.snapshot and T.snapshot.Status
    T.snapshot = snap
    T.snapshotAt = os.clock()
    observeSnapshot(snap)
    if snap.Status == "Docked" and previousStatus ~= "Docked" then
        dockDetails(snap)
    end
end

-- High-volume events unrelated to rafting are only noted the first time they appear.
local RELEVANT_EVENT_PATTERNS = { "Raft", "Fjord", "Storm", "TeamChest", "Chest", "Hobgoblin", "Hazard", "Weather", "River", "Lightning", "Rock", "Reward" }
local NOISY_EVENTS = { RaftRiverLoad = true, RaftRiverKeep = true, RaftYard = true }

local function onClientEvent(name, payload)
    if name == "RaftingSnapshot" then
        onSnapshot(payload)
        return
    end
    if not T.fileName or type(name) ~= "string" then return end

    if not T.seenEvents[name] then
        T.seenEvents[name] = true
        logEvent("FirstSeenEvent", { name = name })
    end
    if NOISY_EVENTS[name] then return end
    for _, pattern in ipairs(RELEVANT_EVENT_PATTERNS) do
        if string.find(name, pattern, 1, true) then
            logEvent("Client:" .. name, payload, true)
            break
        end
    end

    if name == "RaftingEnded" or name == "RaftingSinking" then
        logEvent("LastSnapshot", T.snapshot, true)
    end
    if name == "RaftingEnded" then
        endSession("RaftingEnded")
    end
end

----------------------------------------------------------------------------------------------------
-- Observers
----------------------------------------------------------------------------------------------------

local function watchStormWarnings(folder)
    connect(folder.ChildAdded, function(child)
        if child.Name ~= "LightningWarning" or not child:IsA("BasePart") then return end
        guarded("lightning", function()
            local deck = T.deck
            local localPoint = deck and deck.CFrame:PointToObjectSpace(child.Position)
            logEvent("LightningWarning", {
                position = child.Position,
                radius = child.Size.Y / 2,
                deckPosition = deck and deck.Position,
                deckLocal = localPoint,
                speed = T.snapshot and T.snapshot.Speed,
            }, true)
        end)
    end)
end

local function pollChest()
    local chest = workspace:FindFirstChild("LocalTeamChest", true)
    local key = "none"
    local data = nil
    if chest then
        local pivot = chest:IsA("Model") and chest:GetPivot() or nil
        data = {
            path = chest,
            position = pivot and pivot.Position or nil,
            attributes = chest:GetAttributes(),
            cowDistance = nil,
        }
        local cow = characterInfo(nil)
        if cow and pivot then data.cowDistance = (cow.position - pivot.Position).Magnitude end
        key = jsonValue(data.position) .. jsonValue(data.attributes)
    end
    if key ~= T.lastChestKey then
        T.lastChestKey = key
        logEvent("ChestState", data or { state = "none" }, true)
    end
end

local function installOutgoingHook()
    if not (CONFIG.HOOK_OUTGOING and hookmetamethod and getnamecallmethod) then return end
    local watched = {}
    for _, remote in ipairs(remotes:GetChildren()) do
        local name = remote.Name
        if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
            if string.find(name, "Raft", 1, true) or string.find(name, "Chest", 1, true) then
                watched[remote] = name
            end
        end
    end

    local original
    local handler = function(self, ...)
        if T.running and watched[self] and getnamecallmethod() == "FireServer" then
            table.insert(T.outgoing, {
                clock = os.clock(),
                remote = watched[self],
                args = { ... },
                fromExecutor = checkcaller and checkcaller() or nil,
            })
        end
        return original(self, ...)
    end
    original = hookmetamethod(game, "__namecall", newcclosure and newcclosure(handler) or handler)
    T.originalNamecall = original
end

local function drainOutgoing()
    if #T.outgoing == 0 then return end
    local batch = T.outgoing
    T.outgoing = {}
    for _, call in ipairs(batch) do
        local first = call.args[1]
        -- Repair and boost heartbeats repeat several times a second; the first of a run is enough.
        local runKey = call.remote .. tostring(first)
        local isHeartbeat = first == "RepairHeld" or first == "BoostHeld"
        if not (isHeartbeat and T.lastOutgoingKey == runKey) then
            logEvent("Outgoing", call)
        end
        T.lastOutgoingKey = runKey
    end
end

----------------------------------------------------------------------------------------------------
-- Status label
----------------------------------------------------------------------------------------------------

local function createLabel()
    if not CONFIG.SHOW_STATUS_LABEL then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "VoyageTelemetryStatus"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(460, 22)
    label.Position = UDim2.new(0, 8, 1, -30)
    label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    label.BackgroundTransparency = 0.3
    label.BorderSizePixel = 0
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = " telemetry: waiting for a voyage"
    label.Parent = gui
    local parent = (gethui and gethui()) or player:FindFirstChildOfClass("PlayerGui")
    gui.Parent = parent
    T.gui = gui
    T.label = label
end

local function updateLabel()
    if not T.label then return end
    local snap = T.snapshot
    if T.fileName and snap then
        local x = typeof(snap.Frame) == "CFrame" and snap.Frame.Position.X or 0
        T.label.Text = string.format(" REC %s x%.0f hp%s crash%d bump%d n%d",
            tostring(snap.Status), x, tostring(snap.Health), T.crashes, T.bumps, T.samples)
    else
        T.label.Text = " telemetry: waiting for a voyage"
    end
end

----------------------------------------------------------------------------------------------------
-- Start
----------------------------------------------------------------------------------------------------

connect(clientEvent.OnClientEvent, function(name, payload)
    guarded("clientEvent", onClientEvent, name, payload)
end)

for _, attribute in ipairs({ "FjordStormMask", "FjordStormSeed", "FjordStormEpoch" }) do
    connect(cowGame:GetAttributeChangedSignal(attribute), function()
        guarded("stormAttr", function()
            logEvent("StormAttribute", { name = attribute, data = stormAttributes() }, true)
        end)
    end)
end

for _, attribute in ipairs({ "CowRiverHurt", "CowRiverSwim", "CowRaftingTeam", "Captured" }) do
    connect(player:GetAttributeChangedSignal(attribute), function()
        guarded("playerAttr", function()
            logEvent("PlayerAttribute", { name = attribute, value = player:GetAttribute(attribute) }, true)
        end)
    end)
end

local stormFolder = workspace:FindFirstChild("LocalFjordStorms")
if stormFolder then
    watchStormWarnings(stormFolder)
end
connect(workspace.ChildAdded, function(child)
    if child.Name == "LocalFjordStorms" then
        guarded("stormFolder", watchStormWarnings, child)
    end
end)

guarded("hook", installOutgoingHook)
guarded("label", createLabel)

connect(RunService.Heartbeat, function()
    guarded("heartbeat", function()
        drainOutgoing()
        if not T.fileName then return end

        local now = os.clock()
        if (now - T.snapshotAt) > CONFIG.SESSION_TIMEOUT then
            endSession("snapshot timeout")
            updateLabel()
            return
        end

        local status = T.snapshot and T.snapshot.Status
        local sailing = status == "Travelling" or status == "Departing"
        local interval = sailing and CONFIG.SAMPLE_INTERVAL or CONFIG.MOORED_INTERVAL
        local dt = now - T.lastSampleAt
        if dt >= interval then
            T.lastSampleAt = now
            takeSample(now, dt)
            updateLabel()
        end
        flush(false)
    end)
end)

-- Slower work runs off the heartbeat so it cannot hitch steering.
task.spawn(function()
    while T.running do
        task.wait(1)
        if T.fileName and T.snapshot and T.snapshot.Status == "Docked" then
            guarded("chest", pollChest)
        end
    end
end)

task.spawn(function()
    while T.running do
        task.wait(CONFIG.SURVEY_INTERVAL)
        if T.fileName and writefile then
            guarded("survey", function()
                loadSurvey()
                if not (T.fjord and T.fjord.Parent) then
                    local cowWorld = workspace:FindFirstChild("CowWorld")
                    T.fjord = workspace:FindFirstChild("FjordDelta") or (cowWorld and cowWorld:FindFirstChild("FjordDelta"))
                end
                local fjord = T.fjord
                if fjord then
                    surveyFacades(fjord)
                    surveyCutaways(fjord)
                    saveSurvey(false)
                end
            end)
        end
    end
end)

_G.CowVoyageTelemetry = {
    State = T,
    Stop = function()
        T.running = false
        endSession("stopped")
        for _, conn in ipairs(T.connections) do
            pcall(function() conn:Disconnect() end)
        end
        T.connections = {}
        if T.originalNamecall and hookmetamethod then
            pcall(hookmetamethod, game, "__namecall", T.originalNamecall)
        end
        if T.gui then
            pcall(function() T.gui:Destroy() end)
        end
        _G.CowVoyageTelemetry = nil
    end,
}

print("[VoyageTelemetry] Ready. Recording starts with the next raft snapshot.")
