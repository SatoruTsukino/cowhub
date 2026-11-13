--[[
    Fjord river load probe. Observation only.

    The client's RaftRiverLoader gets a RaftRiverLoad payload (Box, Size, Required ids, Regions, Points), asks the
    engine to stream the map around each point (RequestStreamAroundAsync) and replies RiverReady Loaded=true only once
    every required river part (attribute CowRaftRiverPart) is found inside the box. This probe records the same check
    from the outside, so a stuck load shows which river parts never arrived.

    Records:
      - every Raft* / River* ClientEvent (time, size estimate, payload summary)
      - outgoing RaftingRequest calls (pass-through __namecall hook), including RiverReady Loaded / Position
      - CowRaftRiverPart parts streamed in and out, with their parent folders
      - each second while a load is pending: present / required / missing ids, streaming settings, GameplayPaused
      - client errors and warnings mentioning raft / river / stream
      - server: JobId, uptime, players, FjordRafting attributes
    Usage: loadstring(readfile("cowhub/perf_river.lua"))()   Stop: _G.CowRiverProbe.Stop()
    Output: cowhub/perflogs/river_<time>.json (rewritten every 5 s)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local ScriptContext = game:GetService("ScriptContext")
local Stats = game:GetService("Stats")

local MAX_EVENTS = 3000
local player = Players.LocalPlayer

if _G.CowRiverProbe and _G.CowRiverProbe.Stop then pcall(_G.CowRiverProbe.Stop) end

local P = {
    running = true,
    connections = {},
    events = {},
    dropped = 0,
    riverParts = {}, -- part -> id
    riverIds = {},   -- id -> count of parts with it
    parents = {},    -- parent path -> count
    added = 0,
    removed = 0,
    load = nil,      -- last RaftRiverLoad payload summary + raw payload
    lastReply = nil,
}
local fileName = string.format("cowhub/perflogs/river_%d.json", os.time())
local started = os.clock()

local function now() return math.round((os.clock() - started) * 100) / 100 end

local function event(kind, data)
    if #P.events >= MAX_EVENTS then
        P.dropped += 1
        return
    end
    data = data or {}
    data.t = now()
    data.kind = kind
    table.insert(P.events, data)
end

local function connect(signal, fn)
    table.insert(P.connections, signal:Connect(fn))
end

local function round(v) return math.round(v * 10) / 10 end

local function vec(v)
    if typeof(v) == "Vector3" then return { round(v.X), round(v.Y), round(v.Z) } end
    if typeof(v) == "CFrame" then return vec(v.Position) end
    return nil
end

local function count(t)
    local n = 0
    if type(t) == "table" then for _ in pairs(t) do n += 1 end end
    return n
end

local function sizeOf(v, depth)
    depth = depth or 0
    local kind = typeof(v)
    if kind == "string" then return #v + 2 end
    if kind == "number" or kind == "boolean" then return 9 end
    if kind == "Vector3" then return 13 end
    if kind == "CFrame" then return 49 end
    if kind == "Instance" then return 9 end
    if kind == "table" and depth < 6 then
        local s = 4
        for k, x in pairs(v) do s += sizeOf(k, depth + 1) + sizeOf(x, depth + 1) end
        return s
    end
    return 8
end

local function keysOf(t)
    local keys = {}
    if type(t) ~= "table" then return keys end
    for k in pairs(t) do
        if #keys >= 24 then break end
        table.insert(keys, tostring(k))
    end
    table.sort(keys)
    return keys
end

-- River parts present in the world
local function riverId(inst)
    if not inst:IsA("BasePart") then return nil end
    return inst:GetAttribute("CowRaftRiverPart")
end

local function trackAdd(inst)
    local id = riverId(inst)
    if id == nil or P.riverParts[inst] then return end
    P.riverParts[inst] = id
    P.riverIds[id] = (P.riverIds[id] or 0) + 1
    P.added += 1
    local parent = inst.Parent and inst.Parent:GetFullName() or "?"
    P.parents[parent] = (P.parents[parent] or 0) + 1
end

local function trackRemove(inst)
    local id = P.riverParts[inst]
    if id == nil then return end
    P.riverParts[inst] = nil
    P.riverIds[id] = (P.riverIds[id] or 1) - 1
    if P.riverIds[id] <= 0 then P.riverIds[id] = nil end
    P.removed += 1
end

for _, inst in ipairs(workspace:GetDescendants()) do trackAdd(inst) end
connect(workspace.DescendantAdded, trackAdd)
connect(workspace.DescendantRemoving, trackRemove)

-- The loader's own presence check: river ids of parts inside the payload box
local function presentIds(payload)
    local ids = {}
    local ok = pcall(function()
        for _, part in ipairs(workspace:GetPartBoundsInBox(payload.Box, payload.Size)) do
            local id = part:GetAttribute("CowRaftRiverPart")
            if id then ids[id] = true end
        end
    end)
    return ids, ok
end

local function summariseLoad(payload)
    local s = {
        sessionId = tostring(payload.SessionId),
        serial = payload.Serial,
        currentSerial = payload.CurrentSerial,
        pendingSerial = payload.PendingSerial,
        characterMatches = payload.Character == player.Character,
        hasDeck = payload.Deck ~= nil,
        box = vec(payload.Box),
        size = vec(payload.Size),
        required = count(payload.Required),
        regions = count(payload.Regions),
        points = count(payload.Points),
        keys = keysOf(payload),
    }
    if type(payload.Points) == "table" then
        local first, last = payload.Points[1], payload.Points[#payload.Points]
        s.firstPoint, s.lastPoint = vec(first), vec(last)
    end
    local ids = presentIds(payload)
    local missing = {}
    if type(payload.Required) == "table" then
        for _, id in ipairs(payload.Required) do
            if not ids[id] then table.insert(missing, tostring(id)) end
        end
    end
    s.presentAtArrival = count(ids)
    s.missingAtArrival = #missing
    s.missingSample = { table.unpack(missing, 1, math.min(#missing, 20)) }
    return s
end

-- Incoming river / rafting events
local remotes = ReplicatedStorage:WaitForChild("CowGame", 30):WaitForChild("Remotes", 30)
local clientEvent = remotes:WaitForChild("ClientEvent", 30)
local raftingRequest = remotes:FindFirstChild("RaftingRequest")

connect(clientEvent.OnClientEvent, function(name, payload)
    if type(name) ~= "string" then return end
    if not (string.find(name, "Raft", 1, true) or string.find(name, "River", 1, true) or string.find(name, "Fjord", 1, true)) then
        return
    end
    if name == "RaftingSnapshot" then
        P.snapshots = (P.snapshots or 0) + 1
        P.lastSnapshot = { t = now(), keys = keysOf(payload), status = type(payload) == "table" and tostring(payload.Status) or nil }
        return
    end
    local data = { name = name, bytes = sizeOf(payload) }
    if name == "RaftRiverLoad" and type(payload) == "table" then
        data.load = summariseLoad(payload)
        P.load = { summary = data.load, payload = payload, at = now() }
    elseif type(payload) == "table" then
        data.keys = keysOf(payload)
        data.sessionId = payload.SessionId and tostring(payload.SessionId) or nil
        data.text = type(payload.Text) == "string" and payload.Text or nil
        data.serial = payload.Serial
    else
        data.value = tostring(payload)
    end
    if name == "RaftRiverCancel" or name == "RaftingEnded" then P.load = nil end
    event("in", data)
end)

-- Outgoing rafting requests (pass-through)
if hookmetamethod and getnamecallmethod and raftingRequest then
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        if P.running and self == raftingRequest and getnamecallmethod() == "FireServer" then
            local action, payload = ...
            local data = { action = tostring(action) }
            if type(payload) == "table" then
                data.keys = keysOf(payload)
                data.loaded = payload.Loaded
                data.serial = payload.Serial
                data.position = vec(payload.Position)
            end
            if action == "RiverReady" then
                P.riverReady = (P.riverReady or 0) + 1
                P.lastReply = { t = now(), loaded = data.loaded, serial = data.serial, position = data.position }
                -- Log only changes of the Loaded flag, plus every 10th reply
                if P.lastLoadedFlag ~= data.loaded or P.riverReady % 10 == 0 then
                    P.lastLoadedFlag = data.loaded
                    event("out", data)
                end
            else
                event("out", data)
            end
        end
        return old(self, ...)
    end)
end

-- Errors and warnings
local function interesting(text)
    local lower = string.lower(tostring(text))
    return string.find(lower, "raft", 1, true) or string.find(lower, "river", 1, true)
        or string.find(lower, "stream", 1, true) or string.find(lower, "fjord", 1, true)
end
connect(ScriptContext.Error, function(message, trace)
    if interesting(message) or interesting(trace) then
        event("error", { message = tostring(message), trace = string.sub(tostring(trace), 1, 600) })
    end
end)
connect(LogService.MessageOut, function(message, kind)
    if kind ~= Enum.MessageType.MessageOutput and interesting(message) then
        event("log", { message = string.sub(tostring(message), 1, 400), type = tostring(kind) })
    end
end)

-- Server and client context
local function attrs(inst)
    local out = {}
    if not inst then return out end
    for k, v in pairs(inst:GetAttributes()) do
        if typeof(v) ~= "string" or #v < 200 then out[k] = tostring(v) end
    end
    return out
end

local function prop(inst, name)
    local ok, v = pcall(function() return inst[name] end)
    if not ok and gethiddenproperty then ok, v = pcall(gethiddenproperty, inst, name) end
    return if ok then tostring(v) else nil
end

local function context()
    local cowWorld = workspace:FindFirstChild("CowWorld")
    local fjord = cowWorld and cowWorld:FindFirstChild("FjordRafting")
    local ping
    pcall(function() ping = math.round(player:GetNetworkPing() * 1000) end)
    local mem
    pcall(function() mem = math.round(Stats:GetTotalMemoryUsageMb()) end)
    return {
        jobId = game.JobId,
        placeVersion = game.PlaceVersion,
        uptime = math.round(workspace.DistributedGameTime),
        players = #Players:GetPlayers(),
        pingMs = ping,
        memMb = mem,
        streaming = {
            enabled = workspace.StreamingEnabled,
            targetRadius = prop(workspace, "StreamingTargetRadius"),
            minRadius = prop(workspace, "StreamingMinRadius"),
            integrity = prop(workspace, "StreamingIntegrityMode"),
            streamOut = prop(workspace, "StreamOutBehavior"),
            gameplayPaused = player.GameplayPaused,
        },
        fjordAttributes = attrs(fjord),
        playerAttributes = attrs(player),
        cowhubLoaded = _G.CowHubRayfield ~= nil,
    }
end

local function save()
    local ids = 0
    for _ in pairs(P.riverIds) do ids += 1 end
    local parts = 0
    for _ in pairs(P.riverParts) do parts += 1 end
    local out = {
        version = 1,
        seconds = now(),
        context = context(),
        riverPartsNow = parts,
        riverIdsNow = ids,
        riverPartsAdded = P.added,
        riverPartsRemoved = P.removed,
        riverParents = P.parents,
        rafting = {
            snapshots = P.snapshots or 0,
            lastSnapshot = P.lastSnapshot,
            riverReady = P.riverReady or 0,
            lastReply = P.lastReply,
            pendingLoad = P.load and P.load.summary or nil,
        },
        droppedEvents = P.dropped,
        events = P.events,
    }
    pcall(function()
        if not isfolder("cowhub/perflogs") then makefolder("cowhub/perflogs") end
        writefile(fileName, HttpService:JSONEncode(out))
    end)
end

-- While a load is pending: what is present, what is still missing
task.spawn(function()
    local lastSave = os.clock()
    local lastMissing
    while P.running do
        task.wait(1)
        local load = P.load
        if load and type(load.payload.Required) == "table" then
            local ids, ok = presentIds(load.payload)
            local missing = {}
            for _, id in ipairs(load.payload.Required) do
                if not ids[id] then table.insert(missing, tostring(id)) end
            end
            if #missing ~= lastMissing or P.lastReply and P.lastReply.loaded == false then
                lastMissing = #missing
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                event("pending", {
                    queryOk = ok,
                    present = count(ids),
                    required = #load.payload.Required,
                    missing = #missing,
                    missingSample = { table.unpack(missing, 1, math.min(#missing, 20)) },
                    loadAge = round(now() - load.at),
                    lastLoaded = P.lastReply and P.lastReply.loaded,
                    gameplayPaused = player.GameplayPaused,
                    root = hrp and vec(hrp.Position) or nil,
                    memMb = math.round(Stats:GetTotalMemoryUsageMb()),
                    clearings = resourceCounts(),
                })
            end
        end
        if os.clock() - lastSave >= 5 then
            lastSave = os.clock()
            save()
        end
    end
end)

-- Fjord content state on the server, and how much of each clearing has streamed in
local function resourceCounts()
    local out = {}
    local cowWorld = workspace:FindFirstChild("CowWorld")
    local res = cowWorld and cowWorld:FindFirstChild("FjordRafting") and cowWorld.FjordRafting:FindFirstChild("Resources")
    if res then
        for _, c in ipairs(res:GetChildren()) do out[c.Name] = #c:GetDescendants() end
    end
    return out
end
task.spawn(function()
    local cowWorld = workspace:WaitForChild("CowWorld", 30)
    local fjord = cowWorld and cowWorld:WaitForChild("FjordRafting", 30)
    if fjord then
        connect(fjord.AttributeChanged, function(name)
            event("fjordAttr", { name = name, value = tostring(fjord:GetAttribute(name)) })
        end)
    end
end)

event("start", context())
save()

_G.CowRiverProbe = {
    Stop = function()
        P.running = false
        for _, c in ipairs(P.connections) do pcall(function() c:Disconnect() end) end
        event("stop")
        save()
    end,
    Save = save,
    State = P,
    File = fileName,
}
if _G.CowPerfMonitor then pcall(_G.CowPerfMonitor.Mark, "RIVER probe started") end
