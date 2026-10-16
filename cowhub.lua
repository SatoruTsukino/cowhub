--[[
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Rayfield Gen2 Autofarm, Manatite Farm, Raycast Grass Chomper, Auto-Fishing & Alive-Only Priority Mob Aura
-- Optimized for high framerates, zero-allocation math, memory safety, and executor stability.

-- 1. The Server-Hop Queue Hook
local queueOnTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queueOnTeleport then
    pcall(function()
        queueOnTeleport([[
            task.wait(3)
            loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/main/cowhub.lua'))()
        ]])
    end)
end

-- 2. Build the Hub
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/gen2'))()

local Window = Rayfield:CreateWindow({
    Name = "Cow Hub",
    Subtitle = "by Gemini & I",
    showIconOnly = true,
    theme = "rose",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false
})

-- ==========================
-- SERVICES & FAST LOCAL APIS
-- ==========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local successVIM, VirtualInput = pcall(function()
    return game:GetService("VirtualInputManager")
end)
if not successVIM or not VirtualInput then
    VirtualInput = VirtualUser
end

local RAYCAST_DOWN = Vector3.new(0, -15, 0)

-- ==========================
-- PLAYER & CHARACTER STATE
-- ==========================
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local scriptConnections = {}

-- Pre-cached character baseparts for zero-allocation collision toggling
local charBaseParts = {}
local function updateCharBaseParts(character)
    table.clear(charBaseParts)
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(charBaseParts, part)
            end
        end
    end
end
updateCharBaseParts(char)

-- Anti-AFK (Runs on Load)
local idleConn = plr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end)
table.insert(scriptConnections, idleConn)

-- ==========================
-- REMOTES & GAME FOLDERS
-- ==========================
local cowGame = ReplicatedStorage:WaitForChild("CowGame")
local cowRemotes = cowGame:WaitForChild("Remotes")
local chompEvent = cowRemotes:WaitForChild("ChompRequest")
local fishingEvent = cowRemotes:FindFirstChild("FishingRequest") or cowRemotes:WaitForChild("FishingRequest", 5)
local skinAuction = cowGame:WaitForChild("SkinAuction")
local fishingSpotsFolder = workspace:FindFirstChild("Fishing Spots") or workspace:WaitForChild("Fishing Spots", 5)

-- Pre-configured Raycast Parameters (Zero allocation per frame)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {char}

local manatite
local mithril

local charConn = plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if humanoid then dodge.originalWalkSpeed = humanoid.WalkSpeed end
    raycastParams.FilterDescendantsInstances = {char}
    updateCharBaseParts(newChar)
    dodge.isDodging = false
    dodge.isUnderground = false
    dodge.lastRecordedHearts = nil
    dodge.currentAttackingMob = nil
    dodge.preDodgePos = nil
    dodge.preDodgeCFrame = nil
    dodge.lastSurfaceCFrame = nil
    dodge.lastSurfacePos = nil
    dodge.undergroundCFrame = nil
    dodge.currentUndergroundRetreatOffset = nil
    aerial.active = false
    aerial.cframe = nil
    aerial.preCFrame = nil
    aerial.startTime = 0
    if manatite then
        manatite.model = nil
        manatite.target = nil
        manatite.payload = nil
    end
    if mithril then
        mithril.model = nil
        mithril.orePart = nil
        mithril.payload = nil
    end
end)
table.insert(scriptConnections, charConn)

-- ==========================
-- ==========================
-- STATE TABLES (Grouped for Luau register optimization < 200 limit)
-- ==========================
local farm = {
    on = false,
    autoChomp = false,
    autoChompMobs = false,
    autoFish = false,
    anchorPos = nil,
    pattern = "Guided Zigzag (Nodes)",
    patternSpeed = 1.0,
    patternTimer = 0,
    nextRandomPos = nil,
    radius = 75,
    radiusSq = 75 * 75,
    mobAuraRadiusSq = 100, -- Hardcoded 10 studs squared (10 * 10) - server-enforced attack reach
    mobAuraDelay = 0.1,
    lastMoveTime = 0,
    currentTargetNode = nil,
    lastChompedNode = "",
    chompCooldown = 0,
    lastRaycastChompTime = 0,
    lastChompedMob = "",
    mobChompCooldown = 0,
    castCooldown = 0,
    lastFishingSearchTime = 0,
}

local dodge = {
    auto = false,
    method = "Underground", -- "Underground", "Run Away (Surface)", "Teleport Away (Surface)"
    isDodging = false,
    isUnderground = false,
    currentAttackingMob = nil,
    preDodgePos = nil,
    preDodgeCFrame = nil,
    lastSurfaceCFrame = nil,
    lastSurfacePos = nil,
    undergroundCFrame = nil,
    undergroundDepth = 20,
    currentUndergroundRetreatOffset = nil,
    retreatDistance = 25,
    retreatAngle = 45,
    walkSpeed = 26,
    originalWalkSpeed = humanoid and humanoid.WalkSpeed or 16,
    detectionRadius = 15,
    detectionRadiusSq = 15 * 15,
    lingerDelay = 0.6,
    prioritizeMobsOverManatite = false,
    retreatOnThreat = true,
    manatiteThreatRadiusSq = 225, -- 15 studs squared (15 * 15) to detect spiders before they reach 10-stud attack reach
    lastWarningSeenTime = 0,
    lastTeleportDodgeDist = 0,
    notifyOnDodge = false,
    dodgeOnHeartsDecreased = true,
    lastRecordedHearts = nil,
    normalPlayerHearts = 0,
    lastRecordedArmor = nil,
    normalPlayerArmor = 0,
    lastDamageRetreatTime = 0,
    threatStartTime = 0,
    startTime = 0,
}

local aerial = {
    active = false,
    startTime = 0,
    duration = 60,   -- seconds to hover before returning
    height = 200,    -- studs above current position
    cframe = nil,    -- position locked while hovering
    preCFrame = nil, -- original position to return to
    cooldown = 10,   -- minimum seconds between aerial retreats
    lastTime = 0,
}

local cache = {
    nodeBlacklist = setmetatable({}, { __mode = "k" }),
    lastBlacklistCleanup = 0,
    nodeCleanNames = {},
    mobPayloads = {},
    nodePosition = setmetatable({}, { __mode = "k" }),
    mobAttackOriginPart = setmetatable({}, { __mode = "kv" }),
    mobHumanoid = setmetatable({}, { __mode = "kv" }),
    mobWarning = setmetatable({}, { __mode = "kv" }),
    mobWarningCheckTime = setmetatable({}, { __mode = "kv" }),
    fishingSpotPos = setmetatable({}, { __mode = "k" }),
    grassFolder = workspace:FindFirstChild("CowVirtualGrass"),
    grassNodes = {},
    lastGrassTime = 0,
    fishingSpots = {},
    lastFishingSpotsTime = 0,
    cowWorldRef = workspace:FindFirstChild("CowWorld"),
    activeRipples = setmetatable({}, { __mode = "k" }),
    rippleConnections = {},
    ripplePos = setmetatable({}, { __mode = "kv" }),
    activeAuraMobs = {},
    mithrilCaveMobSet = setmetatable({}, { __mode = "k" }),
    spiderIdentifier = setmetatable({}, { __mode = "k" }),
    cachedMithrilCaveFolder = nil,
    isEPressed = false,
    lastBackgroundTime = 0,
    isCachingBackground = false,
    lastSanitationTime = 0,
}

local auction = {
    lotNames = {"Lot1", "Lot2", "Lot3", "Lot4"},
    previousSignatures = {},
    scannerRunning = false,
    connections = {},
    isChecking = false,
    cards = {},
    remote = nil,
    autoBidAll = false,
    autoBidActive = {
        Lot1 = false,
        Lot2 = false,
        Lot3 = false,
        Lot4 = false
    },
    maxAutoBidLimit = 0,
    autoBidConnections = {},
    autoBidLoopRunning = true,
    lastAutoBidTime = {},
    isAutoBiddingLot = {},
}

local fps = {
    capEnabled = false,
    currentCap = 60,
    rarityColors = {
        ["Common"] = 0xB0BEC5,
        ["Uncommon"] = 0x66BB6A,
        ["Rare"] = 0x42A5F5,
        ["Super Rare"] = 0xAB47BC,
        ["Mythic"] = 0xFF5252,
        ["Unique"] = 0xFFD700,
        ["Unrated"] = 0xFFFFFF,
        ["Default"] = 0x5865F2
    }
}
local HeartbeatConnection = nil

manatite = {
    auto = false,
    delay = 0.1,
    heightOffset = 2.5,
    order = "Nearest Available", -- "Nearest Available", "Alphabetical (A-Z)", "Largest Crystal Yield"
    anchor = false,
    returnOnDisable = false,
    preCFrame = nil,
    model = nil,
    target = nil,
    payload = nil,
    lastChompTime = 0,
    lastTeleportTime = 0,
    lastSearchTime = 0,
    startTime = 0,
    blacklist = setmetatable({}, { __mode = "k" }),
    lastBlacklistCleanup = 0,
    payloadCache = {},
    showESP = false,
    visuals = {},
    espConn = nil,
    cachedFolder = nil,
    cachedModels = {},
    lastCacheTime = 0,
    yieldAttributes = {
        "CrystalYield",
        "crystalYield",
        "Crystal_Yield",
        "crystal_yield",
        "Crystal Yield",
        "Yield",
        "yield",
        "Crystals",
        "crystals",
        "CrystalAmount",
        "crystalAmount",
        "CrystalCount",
        "crystalCount",
        "RemainingYield",
        "remainingYield",
        "YieldRemaining",
        "yieldRemaining",
    },
}

-- Mithril Farm & ESP State Table
mithril = {
    auto = false,
    delay = 0.1,
    heightOffset = 2.5,
    order = "Nearest Available", -- "Nearest Available", "Alphabetical (A-Z)"
    anchor = false,
    returnOnDisable = false,
    preCFrame = nil,
    model = nil,
    orePart = nil,
    payload = nil,
    lastChompTime = 0,
    lastTeleportTime = 0,
    lastSearchTime = 0,
    startTime = 0,
    blacklist = setmetatable({}, { __mode = "k" }),
    lastBlacklistCleanup = 0,
    payloadCache = {},
    showESP = false,
    visuals = {},
    espConn = nil,
    cachedFolder = nil,
    cachedModels = {},
    lastCacheTime = 0,
}

-- Visual ESP State Tables
local penESP = {
    show = false,
    visualizer = nil,
}

local chestESP = {
    show = false,
    highlight = nil,
    billboard = nil,
    espConn = nil,
    childAddedConn = nil,
    childRemovedConn = nil,
}

-- Node Pathfinding & Memoization

-- Chomp & Aura Cooldowns

-- Background Caching & Auto-Fishing Variables

-- Mob Attack Dodge Variables (Run Away & Surface Retreat)

-- Aerial Retreat Variables (Low-Health Emergency Retreat)

-- Spammer Variables
local spamThreads = {E = 0, Q = 0}

-- Scanner & File System Variables
local httpRequest = (request or http_request or (http and http.request) or (syn and syn.request))

-- FPS Variables


-- ==========================
-- FILE SAVING SYSTEM
-- ==========================
local configFileName = "CowScannerWebhook.txt"

local function loadWebhook()
    if isfile and readfile and isfile(configFileName) then
        local success, result = pcall(function() return readfile(configFileName) end)
        if success and result then return result end
    end
    return ""
end

local function saveWebhook(url)
    if writefile then
        pcall(function() writefile(configFileName, url) end)
    end
end

local WEBHOOK_URL = loadWebhook()

-- ==========================
-- SPIDER IDENTIFIER LOGGER & CACHE (JSON Persistence in Workspace)
-- ==========================
local SPIDER_JSON_FILE = "SpiderIdentifiers.json"

local spiderLogger = {
    fileName = SPIDER_JSON_FILE,
    data = {
        identifiers = {},   -- Array of unique string IDs e.g. ["200809"]
        byPosition = {},    -- "X_Y_Z" -> identifier
        byPath = {},        -- Mob full path or name -> identifier
        history = {},       -- Array of recent discovery events
    },
    idSet = {},             -- Fast O(1) membership set
    currentUnknownMob = nil,-- The unknown mob instance currently being attacked
    currentUnknownTime = 0, -- Time when attack on unknown mob began
    isInternalFire = false, -- Flag to distinguish script's own chomp calls from other scripts
}

local function getSpiderPosKey(pos)
    if not pos then return nil end
    local rx = math.floor(pos.X / 5 + 0.5) * 5
    local ry = math.floor(pos.Y / 5 + 0.5) * 5
    local rz = math.floor(pos.Z / 5 + 0.5) * 5
    return string.format("%d_%d_%d", rx, ry, rz)
end

function spiderLogger.load()
    if isfile and readfile and isfile(spiderLogger.fileName) then
        local success, raw = pcall(function() return readfile(spiderLogger.fileName) end)
        if success and raw and raw ~= "" then
            local parseSuccess, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if parseSuccess and type(decoded) == "table" then
                spiderLogger.data.identifiers = decoded.identifiers or {}
                spiderLogger.data.byPosition = decoded.byPosition or {}
                spiderLogger.data.byPath = decoded.byPath or {}
                spiderLogger.data.history = decoded.history or {}

                spiderLogger.idSet = {}
                for _, id in ipairs(spiderLogger.data.identifiers) do
                    spiderLogger.idSet[tostring(id)] = true
                end
                for _, id in pairs(spiderLogger.data.byPosition) do
                    spiderLogger.idSet[tostring(id)] = true
                end
                for _, id in pairs(spiderLogger.data.byPath) do
                    spiderLogger.idSet[tostring(id)] = true
                end
            end
        end
    end
end

function spiderLogger.save()
    if not writefile then return end
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(spiderLogger.data)
    end)
    if success and encoded then
        pcall(function()
            writefile(spiderLogger.fileName, encoded)
        end)
    end
end

function spiderLogger.extractIdentifier(val, depth)
    depth = depth or 0
    if depth > 3 or val == nil then return nil end

    local valType = typeof(val)
    if valType == "string" then
        local num = string.match(val, "Cavern_Mob_Spider_(%d+)")
            or string.match(val, "Spider_(%d+)")
            or string.match(val, "Mob_Spider_(%d+)")
        if num then return tostring(num) end

        local digits = string.match(val, "^(%d%d%d%d+)$")
        if digits then return digits end

        local anyNum = string.match(val, "(%d%d%d%d+)")
        if anyNum and #anyNum >= 4 then return anyNum end
    elseif valType == "number" then
        if val >= 1000 then
            return tostring(math.floor(val))
        end
    elseif valType == "table" then
        for _, k in ipairs({"Identifier", "identifier", "Id", "id", "ID", "SpiderId", "spiderId", "MobId", "mobId", "Payload", "payload", "TargetId", "Target", "target"}) do
            if val[k] ~= nil then
                local found = spiderLogger.extractIdentifier(val[k], depth + 1)
                if found then return found end
            end
        end
        for _, subVal in pairs(val) do
            local found = spiderLogger.extractIdentifier(subVal, depth + 1)
            if found then return found end
        end
    elseif valType == "Instance" then
        if val:IsA("Model") or val:IsA("BasePart") then
            local numMatch = string.match(val.Name, "(%d%d%d%d+)")
            if numMatch then return numMatch end
        end
    end
    return nil
end

function spiderLogger.getMobPosition(mob)
    if not mob then return nil end
    if dodge and dodge.getMobAttackOrigin then
        local pos = dodge.getMobAttackOrigin(mob)
        if pos then return pos end
    end
    if mob.PrimaryPart then return mob.PrimaryPart.Position end
    local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head") or mob:FindFirstChild("CavernBodyVisual")
    if hrp and hrp:IsA("BasePart") then return hrp.Position end
    if mob:IsA("BasePart") then return mob.Position end
    local ok, pivot = pcall(function() return mob:GetPivot().Position end)
    if ok and pivot then return pivot end
    return nil
end

function spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)
    if not idStr or idStr == "" then return end
    idStr = tostring(idStr)

    local targetMob = mobInstance or spiderLogger.currentUnknownMob
    local changed = false

    if not spiderLogger.idSet[idStr] then
        spiderLogger.idSet[idStr] = true
        table.insert(spiderLogger.data.identifiers, idStr)
        changed = true
    end

    local mobPos = nil
    if targetMob and targetMob.Parent then
        cache.spiderIdentifier[targetMob] = idStr

        local path = targetMob:GetFullName()
        if not spiderLogger.data.byPath[path] then
            spiderLogger.data.byPath[path] = idStr
            changed = true
        end
        if not spiderLogger.data.byPath[targetMob.Name] then
            spiderLogger.data.byPath[targetMob.Name] = idStr
            changed = true
        end

        mobPos = spiderLogger.getMobPosition(targetMob)
        if mobPos then
            local posKey = getSpiderPosKey(mobPos)
            if posKey and not spiderLogger.data.byPosition[posKey] then
                spiderLogger.data.byPosition[posKey] = idStr
                changed = true
            end
        end
    end

    table.insert(spiderLogger.data.history, 1, {
        timestamp = os.date("!%Y-%m-%d %H:%M:%SZ"),
        identifier = idStr,
        source = source or "ChompRequest",
        mobName = targetMob and targetMob.Name or "Unknown",
        position = mobPos and string.format("%.1f, %.1f, %.1f", mobPos.X, mobPos.Y, mobPos.Z) or nil,
        raw = extraRaw and tostring(extraRaw) or nil
    })
    if #spiderLogger.data.history > 50 then
        table.remove(spiderLogger.data.history)
    end

    spiderLogger.save()

    if targetMob == spiderLogger.currentUnknownMob then
        spiderLogger.currentUnknownMob = nil
        spiderLogger.currentUnknownTime = 0
    end
end

function spiderLogger.resolveSpiderIdentifier(mob)
    if not mob or not mob.Parent then return nil end

    -- 1. Check direct path / name lookup
    local path = mob:GetFullName()
    if spiderLogger.data.byPath[path] then
        return spiderLogger.data.byPath[path]
    end
    if spiderLogger.data.byPath[mob.Name] then
        return spiderLogger.data.byPath[mob.Name]
    end

    -- 2. Check position proximity (within 10 studs / 100 studs squared)
    local mobPos = spiderLogger.getMobPosition(mob)
    if mobPos then
        local posKey = getSpiderPosKey(mobPos)
        if posKey and spiderLogger.data.byPosition[posKey] then
            return spiderLogger.data.byPosition[posKey]
        end

        for savedPosKey, id in pairs(spiderLogger.data.byPosition) do
            local sx, sy, sz = string.match(savedPosKey, "^(%-?%d+)_(%-?%d+)_(%-?%d+)$")
            if sx and sy and sz then
                local spos = Vector3.new(tonumber(sx), tonumber(sy), tonumber(sz))
                local distSq = (mobPos.X - spos.X)^2 + (mobPos.Y - spos.Y)^2 + (mobPos.Z - spos.Z)^2
                if distSq <= 100 then
                    return id
                end
            end
        end
    end

    return nil
end

spiderLogger.load()

-- Hook ChompRequest for server-fired responses & client-fired bite events
local function onChompRemoteReceived(source, ...)
    local args = {...}
    task.spawn(function()
        local id = nil
        for _, arg in ipairs(args) do
            id = spiderLogger.extractIdentifier(arg)
            if id then break end
        end
        if id then
            spiderLogger.recordIdentifier(id, source, spiderLogger.currentUnknownMob, args[1])
        end
    end)
end

-- 1. Hook incoming server events via OnClientEvent
if chompEvent and chompEvent:IsA("RemoteEvent") then
    local serverConn = chompEvent.OnClientEvent:Connect(function(...)
        onChompRemoteReceived("OnClientEvent", ...)
    end)
    table.insert(scriptConnections, serverConn)
elseif chompEvent and chompEvent:IsA("RemoteFunction") then
    local origCallback = chompEvent.OnClientInvoke
    chompEvent.OnClientInvoke = function(...)
        onChompRemoteReceived("OnClientInvoke", ...)
        if origCallback then
            return origCallback(...)
        end
    end
end

-- 2. Metamethod hook for client-fired bites (from proximity prompts, tools, or other local scripts)
pcall(function()
    if hookmetamethod and getnamecallmethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if self == chompEvent and (method == "FireServer" or method == "fireServer") then
                local isOurs = (checkcaller and checkcaller()) or spiderLogger.isInternalFire
                if not isOurs then
                    local args = {...}
                    task.spawn(function()
                        local id = nil
                        for _, arg in ipairs(args) do
                            id = spiderLogger.extractIdentifier(arg)
                            if id then break end
                        end
                        if id then
                            spiderLogger.recordIdentifier(id, "GameInputController", spiderLogger.currentUnknownMob, args[1])
                        end
                    end)
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

-- ==========================
-- HIGH-PERFORMANCE MATH HELPERS
-- ==========================
-- 2D Euclidean Distance (Zero Vector3 heap allocation)
local function get2DDistance(p1, p2)
    local dx = p1.X - p2.X
    local dz = p1.Z - p2.Z
    return math.sqrt(dx * dx + dz * dz)
end

-- Squared 2D Distance (Zero allocations, avoids math.sqrt)
local function get2DDistanceSq(p1, p2)
    local dx = p1.X - p2.X
    local dz = p1.Z - p2.Z
    return dx * dx + dz * dz
end

-- Squared 3D Distance (Zero allocations, avoids math.sqrt)
local function get3DDistanceSq(p1, p2)
    local dx = p1.X - p2.X
    local dy = p1.Y - p2.Y
    local dz = p1.Z - p2.Z
    return dx * dx + dy * dy + dz * dz
end

-- ==========================
-- CACHE & STRING MEMOIZATIONS
-- ==========================



local function getResourcesFolder()
    if not cache.cowWorldRef or not cache.cowWorldRef.Parent then
        cache.cowWorldRef = workspace:FindFirstChild("CowWorld")
    end
    local rafting = cache.cowWorldRef and cache.cowWorldRef:FindFirstChild("FjordRafting")
    return rafting and rafting:FindFirstChild("Resources")
end

function cache.getNodePosition(node)
    local pos = cache.nodePosition[node]
    if pos then return pos end
    pos = node:IsA("Model") and node:GetPivot().Position or node.Position
    cache.nodePosition[node] = pos
    return pos
end

function cache.getGrassNodes()
    local now = os.clock()
    if not cache.grassFolder or not cache.grassFolder.Parent then
        cache.grassFolder = workspace:FindFirstChild("CowVirtualGrass")
    end
    if cache.grassFolder and (now - cache.lastGrassTime > 4 or #cache.grassNodes == 0) then
        cache.lastGrassTime = now
        cache.grassNodes = cache.grassFolder:GetChildren()
    end
    return cache.grassNodes
end

function cache.getFishingSpotsFolder()
    if fishingSpotsFolder and fishingSpotsFolder.Parent then return fishingSpotsFolder end
    fishingSpotsFolder = workspace:FindFirstChild("Fishing Spots") or workspace:FindFirstChild("FishingSpots")
    if not fishingSpotsFolder and cache.cowWorldRef and cache.cowWorldRef.Parent then
        fishingSpotsFolder = cache.cowWorldRef:FindFirstChild("Fishing Spots", true) or cache.cowWorldRef:FindFirstChild("FishingSpots", true)
    end
    return fishingSpotsFolder
end

function cache.getFishingSpots()
    local now = os.clock()
    if now - cache.lastFishingSpotsTime > 5 or #cache.fishingSpots == 0 then
        cache.lastFishingSpotsTime = now
        local folder = cache.getFishingSpotsFolder()
        if folder then
            table.clear(cache.fishingSpots)
            for _, spot in ipairs(folder:GetChildren()) do
                if (spot:IsA("BasePart") or spot:IsA("Model")) and spot.Parent then
                    table.insert(cache.fishingSpots, spot)
                end
            end
        end
    end
    return cache.fishingSpots
end

function cache.getSpotPosition(spot)
    if not spot or not spot.Parent then
        cache.fishingSpotPos[spot] = nil
        return nil
    end
    local pos = cache.fishingSpotPos[spot]
    if pos then return pos end
    pos = spot:IsA("Model") and spot:GetPivot().Position or (spot:IsA("BasePart") and spot.Position)
    if pos then
        cache.fishingSpotPos[spot] = pos
    end
    return pos
end

function cache.getCleanGrassName(nodeName)
    local cached = cache.nodeCleanNames[nodeName]
    if cached ~= nil then return cached end

    local cleanName = string.gsub(nodeName, "GrassVisual", "")
    cleanName = string.gsub(cleanName, "^_+", "")
    cleanName = string.gsub(cleanName, "_+$", "")

    if string.match(cleanName, ".*Grass.*_[np%-]?%d+_[np%-]?%d+$") then
        cache.nodeCleanNames[nodeName] = cleanName
        return cleanName
    else
        cache.nodeCleanNames[nodeName] = false
        return false
    end
end

function cache.getMobPayload(mobName)
    local cached = cache.mobPayloads[mobName]
    if cached then return cached end

    local formattedMobName = string.gsub(mobName, "(%a+)(%d+)", "%1_%2")
    if string.find(mobName, "Spider", 1, true) then
        cached = "Cavern_Mob_" .. formattedMobName
    else
        cached = "Fjord_Mob_" .. formattedMobName
    end
    cache.mobPayloads[mobName] = cached
    return cached
end

function cache.cleanupNodeBlacklist(now)
    if now - cache.lastBlacklistCleanup > 15 then
        cache.lastBlacklistCleanup = now
        for node, timestamp in pairs(cache.nodeBlacklist) do
            if not node or not node.Parent or (now - timestamp > 10) then
                cache.nodeBlacklist[node] = nil
            end
        end
    end
end

-- ==========================
-- MANATITE CLUSTERS & SEA MAZE HELPERS
-- ==========================
function manatite.getFolder()
    if manatite.cachedFolder and manatite.cachedFolder.Parent then
        return manatite.cachedFolder
    end

    -- Primary: workspace.FjordDelta.ManatiteFjordCave.ManatiteMaze.ManatiteClusters
    local fjord = workspace:FindFirstChild("FjordDelta")
    if not fjord and cache.cowWorldRef and cache.cowWorldRef.Parent then
        fjord = cache.cowWorldRef:FindFirstChild("FjordDelta")
    end
    if not fjord then
        fjord = workspace:FindFirstChild("FjordDelta", true)
    end

    if fjord then
        local cave = fjord:FindFirstChild("ManatiteFjordCave") or fjord:FindFirstChild("ManatiteFjordCave", true)
        if cave then
            local maze = cave:FindFirstChild("ManatiteMaze") or cave:FindFirstChild("ManatiteMaze", true)
            if maze then
                local clusters = maze:FindFirstChild("ManatiteClusters") or maze:FindFirstChild("ManatiteClusters", true)
                if clusters then
                    manatite.cachedFolder = clusters
                    return clusters
                end
            end
        end
    end

    -- Fallback: Search workspace for "ManatiteClusters"
    local clusters = workspace:FindFirstChild("ManatiteClusters", true)
    if clusters then
        manatite.cachedFolder = clusters
        return clusters
    end

    return nil
end

function manatite.getModels()
    local now = os.clock()
    local folder = manatite.getFolder()
    if folder and (now - manatite.lastCacheTime > 2 or #manatite.cachedModels == 0) then
        manatite.lastCacheTime = now
        manatite.cachedModels = folder:GetChildren()
    end
    return manatite.cachedModels
end

function manatite.getGrazeTarget(model)
    if not model or not model.Parent then return nil end
    local target = model:FindFirstChild("GrazeTarget")
    if target and target:IsA("BasePart") then
        return target
    end
    local recursiveTarget = model:FindFirstChild("GrazeTarget", true)
    if recursiveTarget and recursiveTarget:IsA("BasePart") then
        return recursiveTarget
    end
    return nil
end

function manatite.getGrazeTargetYield(target, model)
    if not target then return 0, false end

    -- 1. Direct attribute check on GrazeTarget part
    for _, name in ipairs(manatite.yieldAttributes) do
        local val = target:GetAttribute(name)
        if val ~= nil then
            local num = tonumber(val)
            if num and num == num and num ~= math.huge and num ~= -math.huge then
                return num, true
            end
        end
    end

    -- 2. Dynamic attribute scan on GrazeTarget part
    local ok, attrs = pcall(function() return target:GetAttributes() end)
    if ok and type(attrs) == "table" then
        -- Priority 1: contains both "crystal" and "yield" (ignoring max/total/capacity limits)
        for name, val in pairs(attrs) do
            local lower = string.lower(name)
            if not (string.find(lower, "max") or string.find(lower, "total") or string.find(lower, "cap")) then
                if string.find(lower, "crystal") and string.find(lower, "yield") then
                    local num = tonumber(val)
                    if num and num == num and num ~= math.huge and num ~= -math.huge then
                        return num, true
                    end
                end
            end
        end

        -- Priority 2: contains "yield"
        for name, val in pairs(attrs) do
            local lower = string.lower(name)
            if not (string.find(lower, "max") or string.find(lower, "total") or string.find(lower, "cap")) then
                if string.find(lower, "yield") then
                    local num = tonumber(val)
                    if num and num == num and num ~= math.huge and num ~= -math.huge then
                        return num, true
                    end
                end
            end
        end

        -- Priority 3: contains "crystal"
        for name, val in pairs(attrs) do
            local lower = string.lower(name)
            if not (string.find(lower, "max") or string.find(lower, "total") or string.find(lower, "cap")) then
                if string.find(lower, "crystal") then
                    local num = tonumber(val)
                    if num and num == num and num ~= math.huge and num ~= -math.huge then
                        return num, true
                    end
                end
            end
        end

        -- Fallback: check max/total yield attributes if present
        for name, val in pairs(attrs) do
            local lower = string.lower(name)
            if string.find(lower, "crystal") or string.find(lower, "yield") then
                local num = tonumber(val)
                if num and num == num and num ~= math.huge and num ~= -math.huge then
                    return num, true
                end
            end
        end
    end

    -- 3. ValueBase child fallback on GrazeTarget
    for _, name in ipairs(manatite.yieldAttributes) do
        local child = target:FindFirstChild(name)
        if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            return child.Value, true
        end
    end

    -- 4. Fallback checks on model
    if model then
        for _, name in ipairs(manatite.yieldAttributes) do
            local val = model:GetAttribute(name)
            if val ~= nil then
                local num = tonumber(val)
                if num and num == num and num ~= math.huge and num ~= -math.huge then
                    return num, true
                end
            end
        end

        local mOk, mAttrs = pcall(function() return model:GetAttributes() end)
        if mOk and type(mAttrs) == "table" then
            for name, val in pairs(mAttrs) do
                local lower = string.lower(name)
                if not (string.find(lower, "max") or string.find(lower, "total") or string.find(lower, "cap")) then
                    if string.find(lower, "crystal") and string.find(lower, "yield") then
                        local num = tonumber(val)
                        if num and num == num and num ~= math.huge and num ~= -math.huge then
                            return num, true
                        end
                    end
                end
            end
            for name, val in pairs(mAttrs) do
                local lower = string.lower(name)
                if not (string.find(lower, "max") or string.find(lower, "total") or string.find(lower, "cap")) then
                    if string.find(lower, "yield") then
                        local num = tonumber(val)
                        if num and num == num and num ~= math.huge and num ~= -math.huge then
                            return num, true
                        end
                    end
                end
            end
            for name, val in pairs(mAttrs) do
                local lower = string.lower(name)
                if not (string.find(lower, "max") or string.find(lower, "total") or string.find(lower, "cap")) then
                    if string.find(lower, "crystal") then
                        local num = tonumber(val)
                        if num and num == num and num ~= math.huge and num ~= -math.huge then
                            return num, true
                        end
                    end
                end
            end
        end
    end

    return 0, false
end

function manatite.isAvailable(target, model)
    if not target or not target.Parent then return false end
    if model and not model.Parent then return false end

    -- Check attribute "Available" / "available" directly on GrazeTarget
    local attr = target:GetAttribute("Available")
    if attr == nil then
        attr = target:GetAttribute("available")
    end
    -- Fallback to model attribute
    if attr == nil and model then
        attr = model:GetAttribute("Available")
        if attr == nil then
            attr = model:GetAttribute("available")
        end
    end

    if attr ~= nil then
        if not (attr == true or attr == "true" or attr == 1) then
            return false
        end
    end

    -- If a crystal yield attribute is present and explicitly <= 0, cluster is depleted
    local yieldVal, hasYield = manatite.getGrazeTargetYield(target, model)
    if hasYield and yieldVal <= 0 then
        return false
    end

    return true
end

function manatite.getPayload(modelName)
    local cached = manatite.payloadCache[modelName]
    if cached then return cached end

    local payload
    if string.find(modelName, "^Manatite_SeaMaze_") then
        payload = modelName
    else
        local suffix = string.match(modelName, "^Manatite_(.+)$")
        if suffix then
            payload = "Manatite_SeaMaze_" .. suffix
        else
            local tag = string.match(modelName, "^Manatite[_-]?(.*)$")
            if tag and tag ~= "" then
                payload = "Manatite_SeaMaze_" .. tag
            else
                payload = "Manatite_SeaMaze_" .. modelName
            end
        end
    end

    manatite.payloadCache[modelName] = payload
    return payload
end

function manatite.cleanupBlacklist(now)
    if now - manatite.lastBlacklistCleanup > 10 then
        manatite.lastBlacklistCleanup = now
        for model, timestamp in pairs(manatite.blacklist) do
            if not model or not model.Parent or (now - timestamp > 20) then
                manatite.blacklist[model] = nil
            end
        end
    end
end

function manatite.isPositionNearMob(pos, distSq)
    if not pos then return false end
    distSq = distSq or (dodge.manatiteThreatRadiusSq or 225)
    for _, mob in ipairs(cache.activeAuraMobs) do
        if mob.Parent and dodge.isMobAlive(mob) then
            local mobPos = dodge.getMobAttackOrigin(mob)
            if mobPos and get3DDistanceSq(pos, mobPos) <= distSq then
                return true
            end
        end
    end
    return false
end

function manatite.findNext(searchOrigin, avoidMobs)
    local models = manatite.getModels()
    if not models or #models == 0 then return nil, nil end

    local now = os.clock()
    local origin = searchOrigin or (root and root.Position) or Vector3.zero
    local requireSafe = (avoidMobs == true) or (avoidMobs == nil and dodge.retreatOnThreat)

    local safeCandidates = {}
    local allCandidates = {}

    for _, model in ipairs(models) do
        if model.Parent then
            local blacklistedAt = manatite.blacklist[model]
            if not blacklistedAt or (now - blacklistedAt > 20) then
                local target = manatite.getGrazeTarget(model)
                if target and manatite.isAvailable(target, model) then
                    local isNear = manatite.isPositionNearMob(target.Position, dodge.manatiteThreatRadiusSq or 225)
                    local item = {
                        model = model,
                        target = target,
                        isNearMob = isNear,
                        distSq = get3DDistanceSq(origin, target.Position),
                        yield = (manatite.order == "Largest Crystal Yield") and manatite.getGrazeTargetYield(target, model) or 0
                    }
                    table.insert(allCandidates, item)
                    if not isNear then
                        table.insert(safeCandidates, item)
                    end
                end
            end
        end
    end

    local pool = (requireSafe and #safeCandidates > 0) and safeCandidates or allCandidates
    if #pool == 0 then return nil, nil end

    if manatite.order == "Alphabetical (A-Z)" then
        table.sort(pool, function(a, b) return a.model.Name < b.model.Name end)
        return pool[1].model, pool[1].target
    elseif manatite.order == "Largest Crystal Yield" then
        table.sort(pool, function(a, b)
            if a.yield ~= b.yield then return a.yield > b.yield end
            if a.distSq ~= b.distSq then return a.distSq < b.distSq end
            return a.model.Name < b.model.Name
        end)
        return pool[1].model, pool[1].target
    else
        table.sort(pool, function(a, b)
            return a.distSq < b.distSq
        end)
        return pool[1].model, pool[1].target
    end
end

function manatite.retreatToSafeCrystal(now, rootPos)
    local currentModel = manatite.model
    if currentModel then
        manatite.blacklist[currentModel] = now
    end

    manatite.model = nil
    manatite.target = nil
    manatite.payload = nil

    if root then
        pcall(function() root.Anchored = false end)
    end

    local nextModel, nextTarget = manatite.findNext(rootPos or (root and root.Position), true)
    if nextModel and nextTarget then
        manatite.model = nextModel
        manatite.target = nextTarget
        manatite.payload = manatite.getPayload(nextModel.Name)
        manatite.startTime = now
        manatite.teleport(nextTarget, nextModel)
        manatite.lastTeleportTime = now
        manatite.lastChompTime = 0
        manatite.lastSearchTime = now

        if dodge.notifyOnDodge then
            Window:Notify({
                Title = "Manatite Retreat",
                Content = "Spiders nearby! Relocated to a safe crystal.",
                Duration = 2,
            })
        end
        return true
    end
    return false
end

function manatite.teleport(grazeTarget, model)
    if not root or not char or not grazeTarget or not grazeTarget.Parent then return end

    local targetPos = grazeTarget.Position + Vector3.new(0, manatite.heightOffset, 0)
    local modelPos = model and model:GetPivot().Position or grazeTarget.Position
    local lookDir = Vector3.new(modelPos.X - targetPos.X, 0, modelPos.Z - targetPos.Z)
    local targetCFrame
    if lookDir.Magnitude > 0.5 then
        targetCFrame = CFrame.lookAt(targetPos, targetPos + lookDir.Unit)
    else
        targetCFrame = CFrame.new(targetPos)
    end

    char:PivotTo(targetCFrame)
    root.CFrame = targetCFrame

    for _, part in ipairs(charBaseParts) do
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end

    if humanoid then
        humanoid:Move(Vector3.zero, false)
    end

    if manatite.anchor then
        pcall(function() root.Anchored = true end)
    end
end

-- Mithril Ore Farm Helpers (Crystal Geode Ores)
function mithril.getFolder()
    if mithril.cachedFolder and mithril.cachedFolder.Parent then
        return mithril.cachedFolder
    end

    -- 1. Primary: workspace.CowWorld.FjordRafting.Resources.CrystalGeodeOres
    local res = getResourcesFolder()
    if res then
        local geode = res:FindFirstChild("CrystalGeodeOres") or res:FindFirstChild("CrystalGeodeOres", true)
        if geode then
            mithril.cachedFolder = geode
            return geode
        end
    end

    -- 2. Direct path via CowWorld
    local cowWorld = cache.cowWorldRef
    if not cowWorld or not cowWorld.Parent then
        cowWorld = workspace:FindFirstChild("CowWorld")
    end
    if cowWorld then
        local rafting = cowWorld:FindFirstChild("FjordRafting") or cowWorld:FindFirstChild("FjordRafting", true)
        if rafting then
            local geode = rafting:FindFirstChild("CrystalGeodeOres") or rafting:FindFirstChild("CrystalGeodeOres", true)
            if geode then
                mithril.cachedFolder = geode
                return geode
            end
        end
        local directGeode = cowWorld:FindFirstChild("CrystalGeodeOres", true)
        if directGeode then
            mithril.cachedFolder = directGeode
            return directGeode
        end
    end

    -- 3. Fallback: Search anywhere in workspace
    local geode = workspace:FindFirstChild("CrystalGeodeOres", true)
    if geode then
        mithril.cachedFolder = geode
        return geode
    end

    return nil
end

function mithril.getModels()
    local now = os.clock()
    local folder = mithril.getFolder()
    if folder and (now - mithril.lastCacheTime > 2 or #mithril.cachedModels == 0) then
        mithril.lastCacheTime = now
        local rawChildren = folder:GetChildren()
        local list = {}
        for _, child in ipairs(rawChildren) do
            if string.find(string.lower(child.Name), "mithril") then
                table.insert(list, child)
            end
        end
        if #list == 0 and #rawChildren > 0 then
            mithril.cachedModels = rawChildren
        else
            mithril.cachedModels = list
        end
    end
    return mithril.cachedModels
end

function mithril.getOrePart(model)
    if not model or not model.Parent then return nil end
    local ore = model:FindFirstChild("Ore")
    if ore and ore:IsA("BasePart") then
        return ore
    end
    local recursiveOre = model:FindFirstChild("Ore", true)
    if recursiveOre and recursiveOre:IsA("BasePart") then
        return recursiveOre
    end
    if model:IsA("BasePart") then
        return model
    end
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

function mithril.isAvailable(orePart, model)
    if not orePart or not orePart.Parent then return false end
    if model and not model.Parent then return false end

    -- Check attribute "Available" / "available" directly on Ore part
    local attr = orePart:GetAttribute("Available")
    if attr == nil then
        attr = orePart:GetAttribute("available")
    end
    -- Fallback to model attribute
    if attr == nil and model then
        attr = model:GetAttribute("Available")
        if attr == nil then
            attr = model:GetAttribute("available")
        end
    end

    if attr ~= nil then
        return (attr == true or attr == "true" or attr == 1)
    end

    return true
end

function mithril.getPayload(modelName)
    local cached = mithril.payloadCache[modelName]
    if cached then return cached end

    local payload
    if string.find(modelName, "^Cavern_Ore_") then
        payload = modelName
    else
        local oreType, id = string.match(modelName, "^(MithrilOre)_?(%d+)$")
        if oreType and id then
            payload = "Cavern_Ore_" .. oreType .. "_" .. id
        else
            local prefix, numId = string.match(modelName, "^(.-)(%d+)$")
            if prefix and numId and prefix ~= "" then
                prefix = string.gsub(prefix, "_$", "")
                payload = "Cavern_Ore_" .. prefix .. "_" .. numId
            else
                payload = "Cavern_Ore_" .. modelName
            end
        end
    end

    mithril.payloadCache[modelName] = payload
    return payload
end

function mithril.cleanupBlacklist(now)
    if now - mithril.lastBlacklistCleanup > 10 then
        mithril.lastBlacklistCleanup = now
        for model, timestamp in pairs(mithril.blacklist) do
            if not model or not model.Parent or (now - timestamp > 20) then
                mithril.blacklist[model] = nil
            end
        end
    end
end

function mithril.isPositionNearMob(pos, distSq)
    if not pos then return false end
    distSq = distSq or (dodge.manatiteThreatRadiusSq or 225)
    for _, mob in ipairs(cache.activeAuraMobs) do
        if mob.Parent and dodge.isMobAlive(mob) then
            local mobPos = dodge.getMobAttackOrigin(mob)
            if mobPos and get3DDistanceSq(pos, mobPos) <= distSq then
                return true
            end
        end
    end
    return false
end

function mithril.findNext(searchOrigin, avoidMobs)
    local models = mithril.getModels()
    if not models or #models == 0 then return nil, nil end

    local now = os.clock()
    local origin = searchOrigin or (root and root.Position) or Vector3.zero
    local requireSafe = (avoidMobs == true) or (avoidMobs == nil and dodge.retreatOnThreat)

    local safeCandidates = {}
    local allCandidates = {}

    for _, model in ipairs(models) do
        if model.Parent then
            local blacklistedAt = mithril.blacklist[model]
            if not blacklistedAt or (now - blacklistedAt > 20) then
                local orePart = mithril.getOrePart(model)
                if orePart and mithril.isAvailable(orePart, model) then
                    local isNear = mithril.isPositionNearMob(orePart.Position, dodge.manatiteThreatRadiusSq or 225)
                    local item = {
                        model = model,
                        target = orePart,
                        isNearMob = isNear,
                        distSq = get3DDistanceSq(origin, orePart.Position),
                    }
                    table.insert(allCandidates, item)
                    if not isNear then
                        table.insert(safeCandidates, item)
                    end
                end
            end
        end
    end

    local pool = (requireSafe and #safeCandidates > 0) and safeCandidates or allCandidates
    if #pool == 0 then return nil, nil end

    if mithril.order == "Alphabetical (A-Z)" then
        table.sort(pool, function(a, b) return a.model.Name < b.model.Name end)
        return pool[1].model, pool[1].target
    else
        table.sort(pool, function(a, b)
            return a.distSq < b.distSq
        end)
        return pool[1].model, pool[1].target
    end
end

function mithril.retreatToSafeOre(now, rootPos)
    local currentModel = mithril.model
    if currentModel then
        mithril.blacklist[currentModel] = now
    end

    mithril.model = nil
    mithril.orePart = nil
    mithril.payload = nil

    if root then
        pcall(function() root.Anchored = false end)
    end

    local nextModel, nextOre = mithril.findNext(rootPos or (root and root.Position), true)
    if nextModel and nextOre then
        mithril.model = nextModel
        mithril.orePart = nextOre
        mithril.payload = mithril.getPayload(nextModel.Name)
        mithril.startTime = now
        mithril.teleport(nextOre, nextModel)
        mithril.lastTeleportTime = now
        mithril.lastChompTime = 0
        mithril.lastSearchTime = now

        if dodge.notifyOnDodge then
            Window:Notify({
                Title = "Mithril Retreat",
                Content = "Spiders nearby! Relocated to safe ore.",
                Duration = 2,
            })
        end
        return true
    end
    return false
end

function mithril.teleport(orePart, model)
    if not root or not char or not orePart or not orePart.Parent then return end

    local targetPos = orePart.Position + Vector3.new(0, mithril.heightOffset, 0)
    local modelPos = model and model:GetPivot().Position or orePart.Position
    local lookDir = Vector3.new(modelPos.X - targetPos.X, 0, modelPos.Z - targetPos.Z)
    local targetCFrame
    if lookDir.Magnitude > 0.5 then
        targetCFrame = CFrame.lookAt(targetPos, targetPos + lookDir.Unit)
    else
        targetCFrame = CFrame.new(targetPos)
    end

    char:PivotTo(targetCFrame)
    root.CFrame = targetCFrame

    for _, part in ipairs(charBaseParts) do
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end

    if humanoid then
        humanoid:Move(Vector3.zero, false)
    end

    if mithril.anchor then
        pcall(function() root.Anchored = true end)
    end
end

-- Gets the cached attacking part (Head for snakes, CavernBodyVisual for spiders)
function dodge.getMobAttackOriginPart(mob)
    if not mob or not mob.Parent then
        cache.mobAttackOriginPart[mob] = nil
        return nil
    end
    local cached = cache.mobAttackOriginPart[mob]
    if cached and cached.Parent and cached:IsDescendantOf(mob) then
        return cached
    end

    local head = mob:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        cache.mobAttackOriginPart[mob] = head
        return head
    end

    local visual = mob:FindFirstChild("CavernBodyVisual")
    if visual then
        if visual:IsA("BasePart") then
            cache.mobAttackOriginPart[mob] = visual
            return visual
        elseif visual:IsA("Model") then
            local primary = visual.PrimaryPart or visual:FindFirstChildWhichIsA("BasePart")
            if primary then
                cache.mobAttackOriginPart[mob] = primary
                return primary
            end
        end
    end

    if mob:IsA("BasePart") then
        cache.mobAttackOriginPart[mob] = mob
        return mob
    elseif mob:IsA("Model") then
        local primary = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
        if primary then
            cache.mobAttackOriginPart[mob] = primary
            return primary
        end
    end

    return nil
end

function dodge.getMobAttackOrigin(mob)
    local part = dodge.getMobAttackOriginPart(mob)
    if part then
        return part.Position
    end
    if mob:IsA("Model") then
        return mob:GetPivot().Position
    end
    return mob.Position
end

-- Checks if there is an unobstructed line of sight (no walls, terrain, or solid geometry) between origin and mob
function dodge.hasLineOfSight(origin, mobPos, mob)
    if not origin or not mobPos or not mob then return false end

    local dir = mobPos - origin
    local dist = dir.Magnitude
    if dist < 0.5 then return true end

    local hit = workspace:Raycast(origin, dir, raycastParams)
    if not hit then
        return true
    end

    if hit.Instance and hit.Instance:IsDescendantOf(mob) then
        return true
    end

    -- If the hit part is non-collidable and translucent/transparent (e.g. grass, aura effects, zone triggers)
    -- cast a second ray from beyond the hit part
    if hit.Instance and not hit.Instance.CanCollide and (hit.Instance.Transparency > 0.4 or not hit.Instance.CastShadow) then
        local hitPos = hit.Position + (dir.Unit * 0.1)
        local remainingDir = mobPos - hitPos
        if remainingDir.Magnitude > 0.2 then
            local nextHit = workspace:Raycast(hitPos, remainingDir, raycastParams)
            if not nextHit or (nextHit.Instance and nextHit.Instance:IsDescendantOf(mob)) then
                return true
            end
        end
    end

    return false
end

-- Validates whether a mob is physically alive (O(1) checks, zero GetDescendants)
function dodge.isMobAlive(mob)
    if not mob or not mob.Parent then
        cache.mobHumanoid[mob] = nil
        return false
    end

    -- Check Humanoid health if mob is rigged with a humanoid
    local hum = cache.mobHumanoid[mob]
    if hum == nil then
        hum = mob:FindFirstChildWhichIsA("Humanoid") or false
        cache.mobHumanoid[mob] = hum
    end
    if hum and hum.Parent and hum.Health <= 0 then
        return false
    end

    -- Check death attributes
    if mob:GetAttribute("Dead") == true or mob:GetAttribute("Alive") == false then
        return false
    end
    if mob:FindFirstChild("Dead") then
        return false
    end

    -- Check transparency: check attack part or primary part (eliminates GetDescendants)
    local checkPart = dodge.getMobAttackOriginPart(mob)
    if checkPart and checkPart.Parent and checkPart.Transparency < 0.9 then
        return true
    end

    local visual = mob:FindFirstChild("CavernBodyVisual")
    if visual then
        if visual:IsA("BasePart") and visual.Transparency < 0.9 then
            return true
        elseif visual:IsA("Model") then
            for _, p in ipairs(visual:GetChildren()) do
                if p:IsA("BasePart") and p.Transparency < 0.9 then
                    return true
                end
            end
        end
    end

    if mob:IsA("BasePart") then
        return mob.Transparency < 0.9
    elseif mob:IsA("Model") then
        local primary = mob.PrimaryPart
        if primary and primary.Transparency < 0.9 then
            return true
        end
        for _, part in ipairs(mob:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 0.9 then
                return true
            end
        end
    end

    return false
end

-- Finds CavernAttackWarning with weak caching and 0.5s throttled retries
function dodge.findAttackWarning(mob)
    if not mob or not mob.Parent then
        cache.mobWarning[mob] = nil
        cache.mobWarningCheckTime[mob] = nil
        return nil
    end

    local cached = cache.mobWarning[mob]
    if cached then
        if cached.Parent and cached:IsDescendantOf(mob) then
            return cached
        else
            cache.mobWarning[mob] = nil
        end
    end

    local now = os.clock()
    local lastCheck = cache.mobWarningCheckTime[mob]
    if lastCheck and (now - lastCheck < 0.5) then
        return nil
    end
    cache.mobWarningCheckTime[mob] = now

    -- Fast path for snakes: Head.CavernAttackWarning
    local head = mob:FindFirstChild("Head")
    if head then
        local w = head:FindFirstChild("CavernAttackWarning")
        if w then
            cache.mobWarning[mob] = w
            return w
        end
    end

    -- Fast path for spiders: CavernBodyVisual.CavernAttackWarning
    local visual = mob:FindFirstChild("CavernBodyVisual")
    if visual then
        local w = visual:FindFirstChild("CavernAttackWarning")
        if w then
            cache.mobWarning[mob] = w
            return w
        end
    end

    -- Direct child check strictly for CavernAttackWarning
    local direct = mob:FindFirstChild("CavernAttackWarning")
    if direct then
        cache.mobWarning[mob] = direct
        return direct
    end

    -- Recursive search strictly for CavernAttackWarning
    local recursive = mob:FindFirstChild("CavernAttackWarning", true)
    if recursive then
        cache.mobWarning[mob] = recursive
        return recursive
    end

    return nil
end

-- Checks if CavernAttackWarning (BillboardGui) is actively enabled via its "Enabled" attribute
function dodge.isWarningActive(warning, mob)
    if not warning or not warning.Parent then return false end

    -- Must be strictly named CavernAttackWarning (prevents any false positives)
    if warning.Name ~= "CavernAttackWarning" and not string.find(warning.Name, "AttackWarning", 1, true) then
        return false
    end

    -- 1. Check the "Enabled" attribute directly on CavernAttackWarning (Primary)
    local attr = warning:GetAttribute("Enabled")
    if attr == nil then
        attr = warning:GetAttribute("enabled")
    end
    if attr ~= nil then
        return attr == true
    end

    -- 2. Check the "Enabled" attribute on the mob or parent part
    if mob then
        local mobAttr = mob:GetAttribute("Enabled") or mob:GetAttribute("enabled")
        if mobAttr ~= nil then
            return mobAttr == true
        end
    end

    if warning.Parent then
        local parentAttr = warning.Parent:GetAttribute("Enabled") or warning.Parent:GetAttribute("enabled")
        if parentAttr ~= nil then
            return parentAttr == true
        end
    end

    -- 3. Fallback: Check BillboardGui.Enabled property
    if warning:IsA("BillboardGui") then
        return warning.Enabled == true
    end

    return false
end

-- Reads current hearts/health attribute from LocalPlayer, Character, or Humanoid
function dodge.getLocalPlayerHearts()
    if plr then
        for _, attr in ipairs({"Hearts", "hearts", "Heart", "heart", "Health", "health"}) do
            local val = plr:GetAttribute(attr)
            if typeof(val) == "number" then return val, attr end
        end
    end
    if char then
        for _, attr in ipairs({"Hearts", "hearts", "Heart", "heart", "Health", "health"}) do
            local val = char:GetAttribute(attr)
            if typeof(val) == "number" then return val, attr end
        end
    end
    if humanoid and typeof(humanoid.Health) == "number" then
        return humanoid.Health, "HumanoidHealth"
    end
    return nil, nil
end

-- Reads max/normal hearts attribute from LocalPlayer, Character, or Humanoid
function dodge.getLocalPlayerMaxHearts()
    if plr then
        for _, attr in ipairs({"MaxHearts", "maxHearts", "NormalHearts", "normalHearts", "MaxHealth", "maxHealth"}) do
            local val = plr:GetAttribute(attr)
            if typeof(val) == "number" then return val end
        end
    end
    if char then
        for _, attr in ipairs({"MaxHearts", "maxHearts", "NormalHearts", "normalHearts", "MaxHealth", "maxHealth"}) do
            local val = char:GetAttribute(attr)
            if typeof(val) == "number" then return val end
        end
    end
    if humanoid and typeof(humanoid.MaxHealth) == "number" and humanoid.MaxHealth > 0 then
        return humanoid.MaxHealth
    end
    return nil
end

-- Reads current armor attribute or value from LocalPlayer or Character
function dodge.getLocalPlayerArmor()
    if plr then
        for _, attr in ipairs({"Armor", "armor", "Shield", "shield", "ArmorHealth", "armorHealth", "CurrentArmor", "currentArmor"}) do
            local val = plr:GetAttribute(attr)
            if typeof(val) == "number" then return val, attr end
        end
        for _, name in ipairs({"Armor", "armor", "Shield", "shield"}) do
            local obj = plr:FindFirstChild(name)
            if obj and obj:IsA("ValueBase") and typeof(obj.Value) == "number" then
                return obj.Value, name
            end
        end
    end
    if char then
        for _, attr in ipairs({"Armor", "armor", "Shield", "shield", "ArmorHealth", "armorHealth", "CurrentArmor", "currentArmor"}) do
            local val = char:GetAttribute(attr)
            if typeof(val) == "number" then return val, attr end
        end
        for _, name in ipairs({"Armor", "armor", "Shield", "shield"}) do
            local obj = char:FindFirstChild(name)
            if obj and obj:IsA("ValueBase") and typeof(obj.Value) == "number" then
                return obj.Value, name
            end
        end
    end
    return nil, nil
end

-- Reads max/normal armor attribute from LocalPlayer or Character
function dodge.getLocalPlayerMaxArmor()
    if plr then
        for _, attr in ipairs({"MaxArmor", "maxArmor", "NormalArmor", "normalArmor", "MaxShield", "maxShield"}) do
            local val = plr:GetAttribute(attr)
            if typeof(val) == "number" then return val end
        end
        for _, name in ipairs({"MaxArmor", "maxArmor", "NormalArmor", "normalArmor", "MaxShield", "maxShield"}) do
            local obj = plr:FindFirstChild(name)
            if obj and obj:IsA("ValueBase") and typeof(obj.Value) == "number" then
                return obj.Value
            end
        end
    end
    if char then
        for _, attr in ipairs({"MaxArmor", "maxArmor", "NormalArmor", "normalArmor", "MaxShield", "maxShield"}) do
            local val = char:GetAttribute(attr)
            if typeof(val) == "number" then return val end
        end
        for _, name in ipairs({"MaxArmor", "maxArmor", "NormalArmor", "normalArmor", "MaxShield", "maxShield"}) do
            local obj = char:FindFirstChild(name)
            if obj and obj:IsA("ValueBase") and typeof(obj.Value) == "number" then
                return obj.Value
            end
        end
    end
    return nil
end

-- Calculates an unobstructed, safe surface retreat position avoiding walls, rocks, and cave ceilings
function dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)
    if not originPos or not preCFrame or not away2D then return nil, 0, nil end

    local filterList = {char}
    if attackingMob and attackingMob.Parent then
        table.insert(filterList, attackingMob)
    end

    local dodgeRayParams = RaycastParams.new()
    dodgeRayParams.FilterType = Enum.RaycastFilterType.Exclude
    dodgeRayParams.FilterDescendantsInstances = filterList

    -- Sample current floor height to preserve relative humanoid root elevation
    local groundSample = workspace:Raycast(originPos + Vector3.new(0, 1, 0), Vector3.new(0, -6, 0), dodgeRayParams)
    local rootHeightOffset = groundSample and (originPos.Y - groundSample.Position.Y) or 2.8
    if rootHeightOffset < 1.0 or rootHeightOffset > 5.0 then
        rootHeightOffset = 2.8
    end

    local rayOrigin = originPos + Vector3.new(0, 0.5, 0)

    -- Build candidate escape angles (preferred angle first, then radial spread up to 135 deg)
    local candidateAngles = {}
    if preferredAngle and preferredAngle > 0 then
        table.insert(candidateAngles, preferredAngle)
        table.insert(candidateAngles, -preferredAngle)
    end

    for _, ang in ipairs({0, 30, -30, 45, -45, 60, -60, 75, -75, 90, -90, 115, -115, 135, -135}) do
        if not preferredAngle or preferredAngle <= 0 or (math.abs(ang - preferredAngle) > 0.01 and math.abs(ang + preferredAngle) > 0.01) then
            table.insert(candidateAngles, ang)
        end
    end

    local bestCandidate = nil
    local bestScore = -math.huge

    for _, angle in ipairs(candidateAngles) do
        local rad = math.rad(angle)
        local cosA = math.cos(rad)
        local sinA = math.sin(rad)
        local candDir = Vector3.new(away2D.X * cosA - away2D.Z * sinA, 0, away2D.X * sinA + away2D.Z * cosA)

        if candDir.Magnitude > 0.01 then
            candDir = candDir.Unit

            -- 1. Horizontal obstacle & wall clearance check (with stepped distances for narrow caves)
            local wallHit = workspace:Raycast(rayOrigin, candDir * maxDist, dodgeRayParams)
            local clearDist
            if wallHit then
                clearDist = wallHit.Distance - 1.5
            else
                clearDist = maxDist
            end

            -- Require at least 2.0 studs of clear travel to permit cave nooks and corridors
            if clearDist >= 2.0 then
                local testDest = originPos + (candDir * clearDist)

                -- 2. Destination floor check (cast down from +2 studs to prevent clipping cave ceilings)
                local floorHit = workspace:Raycast(testDest + Vector3.new(0, 2.0, 0), Vector3.new(0, -10, 0), dodgeRayParams)
                if floorHit then
                    local destRootY = floorHit.Position.Y + rootHeightOffset

                    -- Discard extreme vertical drops or mountain climbs (> 8 studs)
                    if math.abs(destRootY - originPos.Y) <= 8.0 then
                        local finalRootPos = Vector3.new(testDest.X, destRootY, testDest.Z)

                        -- 3. Ceiling headroom verification (require 2.5 studs clearance for low cave ceilings)
                        local ceilHit = workspace:Raycast(finalRootPos, Vector3.new(0, 2.5, 0), dodgeRayParams)
                        if not ceilHit then
                            -- 4. Line of sight check from current position to destination
                            local pathVec = (finalRootPos + Vector3.new(0, 0.5, 0)) - rayOrigin
                            local pathHit = workspace:Raycast(rayOrigin, pathVec, dodgeRayParams)
                            if not pathHit or pathHit.Distance >= (pathVec.Magnitude - 1.5) then
                                -- 5. Score candidate: prioritize travel distance and alignment away from threat
                                local dot = candDir:Dot(away2D)
                                local score = clearDist * (1.0 + math.max(0, dot))
                                if preferredAngle and preferredAngle > 0 and (math.abs(angle - preferredAngle) < 0.01 or math.abs(angle + preferredAngle) < 0.01) then
                                    score = score * 1.15
                                end

                                if score > bestScore then
                                    bestScore = score
                                    bestCandidate = {
                                        cframe = CFrame.new(finalRootPos) * preCFrame.Rotation,
                                        distance = clearDist,
                                        direction = candDir,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if bestCandidate then
        return bestCandidate.cframe, bestCandidate.distance, bestCandidate.direction
    end

    return nil, 0, nil
end

-- Simulates an interaction keypress ('E') without blocking the render/heartbeat loop
local function pressE()
    if cache.isEPressed then return end
    cache.isEPressed = true
    pcall(function()
        if successVIM and VirtualInput then
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        elseif keypress then
            keypress(0x45)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown("0x65")
        end
    end)
    task.spawn(function()
        task.wait(0.04)
        pcall(function()
            if successVIM and VirtualInput then
                VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            elseif keyrelease then
                keyrelease(0x45)
            elseif VirtualUser then
                VirtualUser:SetKeyUp("0x65")
            end
        end)
        cache.isEPressed = false
    end)
end

-- Checks for an identifier number on Mithril cave spiders if present (e.g. 200809)
function cache.findSpiderIdentifier(mob)
    if not mob then return nil end
    local cached = cache.spiderIdentifier[mob]
    if cached ~= nil and cached ~= false then return cached end

    -- Check persistent JSON data loaded from workspace (Path, Position proximity, Name)
    if spiderLogger and spiderLogger.resolveSpiderIdentifier then
        local fromJson = spiderLogger.resolveSpiderIdentifier(mob)
        if fromJson then
            cache.spiderIdentifier[mob] = fromJson
            return fromJson
        end
    end

    for _, attr in ipairs({"Id", "ID", "Identifier", "MobId", "SpiderId", "Index", "Number", "SpawnId", "NetworkId", "ServerId", "TargetId", "UID", "UUID", "EntityId"}) do
        local val = mob:GetAttribute(attr)
        if val ~= nil and tostring(val) ~= "" then
            local str = tostring(val)
            cache.spiderIdentifier[mob] = str
            if spiderLogger and spiderLogger.recordIdentifier then
                spiderLogger.recordIdentifier(str, "Attribute", mob)
            end
            return str
        end
    end

    for attrName, attrVal in pairs(mob:GetAttributes()) do
        if typeof(attrVal) == "number" or (typeof(attrVal) == "string" and string.match(attrVal, "^%d%d%d+$")) then
            local str = tostring(attrVal)
            cache.spiderIdentifier[mob] = str
            if spiderLogger and spiderLogger.recordIdentifier then
                spiderLogger.recordIdentifier(str, "AttributeValue", mob)
            end
            return str
        end
    end

    for _, child in ipairs(mob:GetChildren()) do
        if child:IsA("ValueBase") then
            local val = child.Value
            if val and tostring(val) ~= "" then
                local str = tostring(val)
                cache.spiderIdentifier[mob] = str
                if spiderLogger and spiderLogger.recordIdentifier then
                    spiderLogger.recordIdentifier(str, "ChildValue", mob)
                end
                return str
            end
        end
    end

    local visual = mob:FindFirstChild("CavernBodyVisual") or mob:FindFirstChild("Head") or mob.PrimaryPart
    if visual then
        for _, attr in ipairs({"Id", "ID", "Identifier", "MobId", "SpiderId", "Index", "Number", "SpawnId", "NetworkId"}) do
            local val = visual:GetAttribute(attr)
            if val ~= nil and tostring(val) ~= "" then
                local str = tostring(val)
                cache.spiderIdentifier[mob] = str
                if spiderLogger and spiderLogger.recordIdentifier then
                    spiderLogger.recordIdentifier(str, "VisualAttribute", mob)
                end
                return str
            end
        end
        for attrName, attrVal in pairs(visual:GetAttributes()) do
            if typeof(attrVal) == "number" or (typeof(attrVal) == "string" and string.match(attrVal, "^%d%d%d+$")) then
                local str = tostring(attrVal)
                cache.spiderIdentifier[mob] = str
                if spiderLogger and spiderLogger.recordIdentifier then
                    spiderLogger.recordIdentifier(str, "VisualAttributeValue", mob)
                end
                return str
            end
        end
    end

    pcall(function()
        local CollectionService = game:GetService("CollectionService")
        for _, tag in ipairs(CollectionService:GetTags(mob)) do
            local num = string.match(tag, "(%d%d%d+)")
            if num then
                cache.spiderIdentifier[mob] = num
                if spiderLogger and spiderLogger.recordIdentifier then
                    spiderLogger.recordIdentifier(num, "Tag", mob)
                end
                return num
            end
        end
    end)

    local numMatch = string.match(mob.Name, "(%d%d%d+)")
    if numMatch and #numMatch >= 4 then
        cache.spiderIdentifier[mob] = numMatch
        if spiderLogger and spiderLogger.recordIdentifier then
            spiderLogger.recordIdentifier(numMatch, "NameDigits", mob)
        end
        return numMatch
    end

    cache.spiderIdentifier[mob] = false
    return nil
end

function cache.getMithrilCaveSpidersFolder()
    if cache.cachedMithrilCaveFolder and cache.cachedMithrilCaveFolder.Parent then
        return cache.cachedMithrilCaveFolder
    end
    local resources = getResourcesFolder()
    if resources then
        local folder = resources:FindFirstChild("MithrilCaveSpiders")
        if folder then
            cache.cachedMithrilCaveFolder = folder
            return folder
        end
    end
    if cache.cowWorldRef and cache.cowWorldRef.Parent then
        local folder = cache.cowWorldRef:FindFirstChild("MithrilCaveSpiders", true)
        if folder then
            cache.cachedMithrilCaveFolder = folder
            return folder
        end
    end
    local folder = workspace:FindFirstChild("MithrilCaveSpiders", true)
    if folder then
        cache.cachedMithrilCaveFolder = folder
        return folder
    end
    return nil
end

function dodge.isSpiderMobInstance(instance)
    if not (instance:IsA("Model") or instance:IsA("BasePart")) then return false end
    local name = instance.Name
    if name == "Mama Spider" or string.find(name, "FjordSpider", 1, true) then
        return true
    end
    if string.find(name, "Spider", 1, true) and not string.find(name, "Chamber", 1, true) then
        return true
    end
    return false
end

function dodge.isMithrilCaveMob(mob)
    if not mob then return false end
    if cache.mithrilCaveMobSet[mob] then return true end
    local mFolder = cache.getMithrilCaveSpidersFolder()
    if mFolder and mob:IsDescendantOf(mFolder) then
        cache.mithrilCaveMobSet[mob] = true
        return true
    end
    local name = mob.Name
    if string.find(name, "FjordSpider", 1, true) or name == "Mama Spider" or string.find(name, "Mama", 1, true) then
        return true
    end
    return false
end

-- Recursively collects living spiders from Mithril Cave chambers and rooms
function dodge.collectSpidersFromChamber(chamber)
    if not chamber then return end
    if dodge.isSpiderMobInstance(chamber) then
        if dodge.isMobAlive(chamber) and not cache.mithrilCaveMobSet[chamber] then
            table.insert(cache.activeAuraMobs, chamber)
            cache.mithrilCaveMobSet[chamber] = true
        end
        return
    end

    for _, child in ipairs(chamber:GetChildren()) do
        if dodge.isSpiderMobInstance(child) then
            if dodge.isMobAlive(child) and not cache.mithrilCaveMobSet[child] then
                table.insert(cache.activeAuraMobs, child)
                cache.mithrilCaveMobSet[child] = true
            end
        elseif child:IsA("Folder") or child:IsA("Configuration") or child:IsA("Model") then
            dodge.collectSpidersFromChamber(child)
        end
    end
end

-- ==========================
-- FISHING RIPPLE TRACKING (Zero Allocation & Leak-Free)
-- ==========================
function cache.registerRipple(ripple)
    if not ripple or not ripple.Parent then return end
    if not string.find(ripple.Name, "FishingWaterRipples", 1, true) then return end
    cache.activeRipples[ripple] = true
end

function cache.unregisterRipple(ripple)
    if ripple then
        cache.activeRipples[ripple] = nil
        cache.ripplePos[ripple] = nil
    end
end

function cache.cleanupRippleTracking()
    for _, conn in ipairs(cache.rippleConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(cache.rippleConnections)
    table.clear(cache.activeRipples)
    table.clear(cache.ripplePos)
end

function cache.initRippleTracking()
    cache.cleanupRippleTracking()

    -- 1. Scan direct children / descendants of fishingSpotsFolder (tiny scope: ~50 instances)
    local fFolder = cache.getFishingSpotsFolder()
    if fFolder then
        for _, desc in ipairs(fFolder:GetDescendants()) do
            cache.registerRipple(desc)
        end
        local conn = fFolder.DescendantAdded:Connect(cache.registerRipple)
        table.insert(cache.rippleConnections, conn)
        local remConn = fFolder.DescendantRemoving:Connect(cache.unregisterRipple)
        table.insert(cache.rippleConnections, remConn)
    end

    -- 2. Scan direct workspace children only (not descendants! ~30 instances)
    for _, child in ipairs(workspace:GetChildren()) do
        cache.registerRipple(child)
    end
    local wsConn = workspace.ChildAdded:Connect(cache.registerRipple)
    table.insert(cache.rippleConnections, wsConn)
    local wsRemConn = workspace.ChildRemoved:Connect(cache.unregisterRipple)
    table.insert(cache.rippleConnections, wsRemConn)

    -- 3. Scan direct CowWorld children if present (~20 instances)
    local cWorld = cache.cowWorldRef and cache.cowWorldRef.Parent and cache.cowWorldRef or workspace:FindFirstChild("CowWorld")
    if cWorld then
        for _, child in ipairs(cWorld:GetChildren()) do
            cache.registerRipple(child)
        end
        local cwConn = cWorld.ChildAdded:Connect(cache.registerRipple)
        table.insert(cache.rippleConnections, cwConn)
        local cwRemConn = cWorld.ChildRemoved:Connect(cache.unregisterRipple)
        table.insert(cache.rippleConnections, cwRemConn)
    end
end

-- Lightweight background caching for Aura Mobs (Snakes & Spiders) strictly under their clearings
function cache.cacheBackgroundElements()
    if cache.isCachingBackground then return end
    cache.isCachingBackground = true

    if farm.autoChompMobs or dodge.auto then
        table.clear(cache.activeAuraMobs)
        table.clear(cache.mithrilCaveMobSet)
        local resources = getResourcesFolder()

        if resources then
            for _, clearing in ipairs(resources:GetChildren()) do
                if clearing.Name == "MithrilCaveSpiders" or string.find(clearing.Name, "Spider", 1, true) or string.find(clearing.Name, "Cave", 1, true) then
                    for _, chamber in ipairs(clearing:GetChildren()) do
                        dodge.collectSpidersFromChamber(chamber)
                    end
                else
                    for _, v in ipairs(clearing:GetChildren()) do
                        local name = v.Name
                        local isMob = (string.find(name, "Snake", 1, true) or string.find(name, "Spider", 1, true))
                        if isMob and (v:IsA("Model") or v:IsA("BasePart")) then
                            if dodge.isMobAlive(v) then
                                table.insert(cache.activeAuraMobs, v)
                            end
                        end
                    end
                end
            end
        end

        local mithrilFolder = cache.getMithrilCaveSpidersFolder()
        if mithrilFolder and (not resources or not resources:FindFirstChild("MithrilCaveSpiders")) then
            for _, chamber in ipairs(mithrilFolder:GetChildren()) do
                dodge.collectSpidersFromChamber(chamber)
            end
        end
    else
        if #cache.activeAuraMobs > 0 then
            table.clear(cache.activeAuraMobs)
        end
        table.clear(cache.mithrilCaveMobSet)
    end

    cache.isCachingBackground = false
end


function cache.getRipplePosition(ripple)
    if not ripple or not ripple.Parent then
        cache.ripplePos[ripple] = nil
        return nil
    end
    local pos = cache.ripplePos[ripple]
    if pos then return pos end
    pos = ripple:IsA("Model") and ripple:GetPivot().Position or (ripple:IsA("BasePart") and ripple.Position)
    if pos then
        cache.ripplePos[ripple] = pos
    end
    return pos
end

function cache.isSpotAvailable(spot)
    if not spot or not spot.Parent then return false end
    local spotPos = cache.getSpotPosition(spot)
    if not spotPos then return false end

    -- 1. Check direct surface on spot first (fastest non-allocating check)
    local directSurface = spot:FindFirstChild("FishingWaterSurface")
    if directSurface and directSurface.Enabled then
        return true
    end

    -- 2. Check direct ripple child on spot
    local directRipple = spot:FindFirstChild("CowFishingWaterRipples") or spot:FindFirstChild("FishingWaterRipples")
    if directRipple and directRipple.Parent then
        local surfaceGui = directRipple:FindFirstChild("FishingWaterSurface")
        if (surfaceGui and surfaceGui.Enabled) or not surfaceGui then
            return true
        end
    end

    -- 3. Check tracked active ripples (within 7 studs squared = 49 or descendant)
    for ripple, _ in pairs(cache.activeRipples) do
        if ripple and ripple.Parent then
            local ripplePos = cache.getRipplePosition(ripple)
            if ripplePos and (get3DDistanceSq(spotPos, ripplePos) <= 49 or ripple:IsDescendantOf(spot)) then
                local surfaceGui = ripple:FindFirstChild("FishingWaterSurface")
                if (surfaceGui and surfaceGui.Enabled) or not surfaceGui then
                    return true
                end
            end
        else
            cache.activeRipples[ripple] = nil
            cache.ripplePos[ripple] = nil
        end
    end

    return false
end

function penESP.update()
    if penESP.show and farm.on and farm.anchorPos then
        if not penESP.visualizer then
            penESP.visualizer = Instance.new("Part")
            penESP.visualizer.Name = "CowPenESP"
            penESP.visualizer.Anchored = true
            penESP.visualizer.CanCollide = false
            penESP.visualizer.Shape = Enum.PartType.Cylinder
            penESP.visualizer.Material = Enum.Material.Neon
            penESP.visualizer.Color = Color3.fromRGB(255, 105, 180)
            penESP.visualizer.Transparency = 0.85
            penESP.visualizer.CastShadow = false
            penESP.visualizer.Parent = workspace
        end
        penESP.visualizer.Size = Vector3.new(0.5, farm.radius * 2, farm.radius * 2)
        penESP.visualizer.CFrame = CFrame.new(farm.anchorPos) * CFrame.Angles(0, 0, math.rad(90))
    else
        if penESP.visualizer then
            penESP.visualizer:Destroy()
            penESP.visualizer = nil
        end
    end
end

-- Cleanup single-chest ESP instances
function chestESP.cleanup()
    if chestESP.espConn then
        chestESP.espConn:Disconnect()
        chestESP.espConn = nil
    end
    if chestESP.highlight then
        chestESP.highlight:Destroy()
        chestESP.highlight = nil
    end
    if chestESP.billboard then
        chestESP.billboard:Destroy()
        chestESP.billboard = nil
    end
end

-- Attach ESP to a loaded chest model/part
function chestESP.attach(trackedChest)
    chestESP.cleanup()
    if not trackedChest or not trackedChest.Parent then return end

    local chestPart = trackedChest:IsA("Model") and (trackedChest.PrimaryPart or trackedChest:FindFirstChildWhichIsA("BasePart")) or (trackedChest:IsA("BasePart") and trackedChest)
    if not chestPart then return end

    chestESP.highlight = Instance.new("Highlight")
    chestESP.highlight.Name = "ChestHighlight"
    chestESP.highlight.Adornee = trackedChest
    chestESP.highlight.FillColor = Color3.fromRGB(255, 215, 0)
    chestESP.highlight.FillTransparency = 0.5
    chestESP.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    chestESP.highlight.OutlineTransparency = 0
    chestESP.highlight.Parent = trackedChest

    chestESP.billboard = Instance.new("BillboardGui")
    chestESP.billboard.Name = "ChestESPText"
    chestESP.billboard.Adornee = chestPart
    chestESP.billboard.Size = UDim2.new(0, 150, 0, 50)
    chestESP.billboard.StudsOffset = Vector3.new(0, 3, 0)
    chestESP.billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "Team Chest"
    textLabel.Parent = chestESP.billboard

    chestESP.billboard.Parent = trackedChest

    local lastDist = -1
    local lastChestUpdate = 0
    chestESP.espConn = RunService.Heartbeat:Connect(function()
        if not chestESP.show or not trackedChest or not trackedChest.Parent then
            chestESP.cleanup()
            return
        end
        local now = os.clock()
        if now - lastChestUpdate > 0.1 then
            lastChestUpdate = now
            if root and chestPart.Parent then
                local dist = math.floor(get2DDistance(root.Position, chestPart.Position))
                if dist ~= lastDist then
                    lastDist = dist
                    textLabel.Text = "📦 Team Chest\n[" .. dist .. " studs]"
                end
            end
        end
    end)
end

-- Dynamic load/unload watcher for LocalTeamChest
function chestESP.update()
    if chestESP.show then
        local currentChest = workspace:FindFirstChild("LocalTeamChest")
        if currentChest then
            chestESP.attach(currentChest)
        end

        if not chestESP.childAddedConn then
            chestESP.childAddedConn = workspace.ChildAdded:Connect(function(child)
                if child.Name == "LocalTeamChest" and chestESP.show then
                    task.wait(0.1)
                    chestESP.attach(child)
                end
            end)
        end

        if not chestESP.childRemovedConn then
            chestESP.childRemovedConn = workspace.ChildRemoved:Connect(function(child)
                if child.Name == "LocalTeamChest" then
                    chestESP.cleanup()
                end
            end)
        end
    else
        if chestESP.childAddedConn then
            chestESP.childAddedConn:Disconnect()
            chestESP.childAddedConn = nil
        end
        if chestESP.childRemovedConn then
            chestESP.childRemovedConn:Disconnect()
            chestESP.childRemovedConn = nil
        end
        chestESP.cleanup()
    end
end

-- ==========================
-- MANATITE ESP VISUALIZER
-- ==========================
function manatite.cleanupVisuals()
    if manatite.espConn then
        manatite.espConn:Disconnect()
        manatite.espConn = nil
    end
    for model, visual in pairs(manatite.visuals) do
        if visual.highlight then pcall(function() visual.highlight:Destroy() end) end
        if visual.billboard then pcall(function() visual.billboard:Destroy() end) end
    end
    table.clear(manatite.visuals)
end

function manatite.updateESP()
    if manatite.showESP then
        if not manatite.espConn then
            local lastEspUpdate = 0
            manatite.espConn = RunService.Heartbeat:Connect(function()
                if not manatite.showESP then
                    manatite.cleanupVisuals()
                    return
                end
                local now = os.clock()
                if now - lastEspUpdate > 0.4 then
                    lastEspUpdate = now
                    for model, visual in pairs(manatite.visuals) do
                        if not model or not model.Parent then
                            if visual.highlight then pcall(function() visual.highlight:Destroy() end) end
                            if visual.billboard then pcall(function() visual.billboard:Destroy() end) end
                            manatite.visuals[model] = nil
                        end
                    end
                    local models = manatite.getModels()
                    for _, model in ipairs(models) do
                        if model.Parent then
                            local target = manatite.getGrazeTarget(model)
                            if target then
                                local available = manatite.isAvailable(target, model)
                                local visual = manatite.visuals[model]
                                if not visual then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ManatiteHighlight"
                                    highlight.Adornee = model
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    highlight.OutlineTransparency = 0.2
                                    highlight.Parent = model

                                    local bb = Instance.new("BillboardGui")
                                    bb.Name = "ManatiteESPText"
                                    bb.Adornee = target
                                    bb.Size = UDim2.new(0, 160, 0, 40)
                                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                    bb.AlwaysOnTop = true

                                    local lbl = Instance.new("TextLabel")
                                    lbl.Name = "Label"
                                    lbl.Size = UDim2.new(1, 0, 1, 0)
                                    lbl.BackgroundTransparency = 1
                                    lbl.TextStrokeTransparency = 0
                                    lbl.TextSize = 13
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.Parent = bb
                                    bb.Parent = model

                                    visual = {highlight = highlight, billboard = bb, label = lbl}
                                    manatite.visuals[model] = visual
                                end

                                if visual.highlight and visual.label then
                                    if available then
                                        local yieldVal = manatite.getGrazeTargetYield(target, model)
                                        local yieldSuffix = yieldVal > 0 and (" [" .. yieldVal .. "]") or ""
                                        visual.highlight.FillColor = Color3.fromRGB(0, 220, 255)
                                        visual.label.TextColor3 = Color3.fromRGB(0, 255, 200)
                                        visual.label.Text = "💎 " .. model.Name .. yieldSuffix .. "\n[AVAILABLE]"
                                    else
                                        visual.highlight.FillColor = Color3.fromRGB(120, 120, 120)
                                        visual.label.TextColor3 = Color3.fromRGB(180, 180, 180)
                                        visual.label.Text = "⚪ " .. model.Name .. "\n[DEPLETED]"
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        manatite.cleanupVisuals()
    end
end

-- ==========================
-- MITHRIL ESP VISUALIZER
-- ==========================
function mithril.cleanupVisuals()
    if mithril.espConn then
        mithril.espConn:Disconnect()
        mithril.espConn = nil
    end
    for model, visual in pairs(mithril.visuals) do
        if visual.highlight then pcall(function() visual.highlight:Destroy() end) end
        if visual.billboard then pcall(function() visual.billboard:Destroy() end) end
    end
    table.clear(mithril.visuals)
end

function mithril.updateESP()
    if mithril.showESP then
        if not mithril.espConn then
            local lastEspUpdate = 0
            mithril.espConn = RunService.Heartbeat:Connect(function()
                if not mithril.showESP then
                    mithril.cleanupVisuals()
                    return
                end
                local now = os.clock()
                if now - lastEspUpdate > 0.4 then
                    lastEspUpdate = now
                    for model, visual in pairs(mithril.visuals) do
                        if not model or not model.Parent then
                            if visual.highlight then pcall(function() visual.highlight:Destroy() end) end
                            if visual.billboard then pcall(function() visual.billboard:Destroy() end) end
                            mithril.visuals[model] = nil
                        end
                    end
                    local models = mithril.getModels()
                    for _, model in ipairs(models) do
                        if model.Parent then
                            local orePart = mithril.getOrePart(model)
                            if orePart then
                                local available = mithril.isAvailable(orePart, model)
                                local visual = mithril.visuals[model]
                                if not visual then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "MithrilHighlight"
                                    highlight.Adornee = model
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    highlight.OutlineTransparency = 0.2
                                    highlight.Parent = model

                                    local bb = Instance.new("BillboardGui")
                                    bb.Name = "MithrilESPText"
                                    bb.Adornee = orePart
                                    bb.Size = UDim2.new(0, 160, 0, 40)
                                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                    bb.AlwaysOnTop = true

                                    local lbl = Instance.new("TextLabel")
                                    lbl.Name = "Label"
                                    lbl.Size = UDim2.new(1, 0, 1, 0)
                                    lbl.BackgroundTransparency = 1
                                    lbl.TextStrokeTransparency = 0
                                    lbl.TextSize = 13
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.Parent = bb
                                    bb.Parent = model

                                    visual = {highlight = highlight, billboard = bb, label = lbl}
                                    mithril.visuals[model] = visual
                                end

                                if visual.highlight and visual.label then
                                    if available then
                                        visual.highlight.FillColor = Color3.fromRGB(80, 190, 255)
                                        visual.label.TextColor3 = Color3.fromRGB(120, 220, 255)
                                        visual.label.Text = "⛏️ " .. model.Name .. "\n[AVAILABLE]"
                                    else
                                        visual.highlight.FillColor = Color3.fromRGB(120, 120, 120)
                                        visual.label.TextColor3 = Color3.fromRGB(180, 180, 180)
                                        visual.label.Text = "⚪ " .. model.Name .. "\n[DEPLETED]"
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        mithril.cleanupVisuals()
    end
end

local function HandleSpam(keyName, state, delayTime)
    spamThreads[keyName] = spamThreads[keyName] + 1
    local currentThread = spamThreads[keyName]
    delayTime = delayTime or 0.05

    if state then
        task.spawn(function()
            local keyCode = Enum.KeyCode[keyName]
            while spamThreads[keyName] == currentThread do
                pcall(function()
                    VirtualInput:SendKeyEvent(true, keyCode, false, game)
                end)
                task.wait(delayTime)
                pcall(function()
                    VirtualInput:SendKeyEvent(false, keyCode, false, game)
                end)
                task.wait(delayTime)
            end
        end)
    end
end

local function formatNumber(n)
    if not n then return "N/A" end
    local formatted = tostring(n)
    local k
    repeat
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    until k == 0
    return formatted
end

function auction.checkLots()
    if not httpRequest or WEBHOOK_URL == "" then return end

    for _, lotName in ipairs(auction.lotNames) do
        local lot = skinAuction:FindFirstChild(lotName)

        if lot then
            local currentSkinId = lot:GetAttribute("SkinId")
            local endsAt = lot:GetAttribute("EndsAt")

            local currentSignature = tostring(currentSkinId) .. "_" .. tostring(endsAt)

            if currentSkinId and currentSkinId ~= "" and currentSignature ~= auction.previousSignatures[lotName] then
                auction.previousSignatures[lotName] = currentSignature

                local skinName = lot:GetAttribute("SkinName") or "Unknown Skin"
                local rarity = lot:GetAttribute("Rarity") or "Default"
                local scope = lot:GetAttribute("Scope") or "N/A"
                local bid = lot:GetAttribute("Bid")
                local minBid = lot:GetAttribute("MinimumBid")

                local embedColor = fps.rarityColors[rarity] or fps.rarityColors["Default"]

                local endsAtDisplay = "N/A"
                if endsAt then
                    endsAtDisplay = "<t:" .. tostring(endsAt) .. ":t> (<t:" .. tostring(endsAt) .. ":R>)"
                end

                local embed = {
                    ["title"] = "Skin : " .. tostring(skinName),
                    ["color"] = embedColor,
                    ["fields"] = {
                        {["name"] = "Skin", ["value"] = "`" .. tostring(currentSkinId) .. "`", ["inline"] = true},
                        {["name"] = "✨ Rarity", ["value"] = "**" .. tostring(rarity) .. "**", ["inline"] = true},
                        {["name"] = "Scope", ["value"] = tostring(scope), ["inline"] = true},
                        {["name"] = "Current Bid", ["value"] = "🪙 " .. formatNumber(bid), ["inline"] = true},
                        {["name"] = "Minimum Bid", ["value"] = "🪙 " .. formatNumber(minBid), ["inline"] = true},
                        {["name"] = "⏳ Ends At", ["value"] = endsAtDisplay, ["inline"] = true}
                    },
                    ["footer"] = {["text"] = "Auction Scanner • " .. os.date("%X")}
                }

                local payload = { ["embeds"] = {embed} }

                if rarity == "Super Rare" or rarity == "Mythic" or rarity == "Unique" then
                    payload["content"] = "@everyone 🚨 **High-tier skin detected in auction!**"
                end

                httpRequest({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })

                task.wait(0.5)
            end
        end
    end
end

function auction.debouncedCheckLots()
    if auction.isChecking then return end
    auction.isChecking = true
    task.spawn(function()
        auction.checkLots()
        auction.isChecking = false
    end)
end

-- ==========================
-- PERIODIC MEMORY SANITATION & GC ASSISTANCE
-- ==========================
function cache.sanitizeMemory(now)
    if now - cache.lastSanitationTime > 30 then
        cache.lastSanitationTime = now

        for node, _ in pairs(cache.nodePosition) do
            if not node or not node.Parent then
                cache.nodePosition[node] = nil
            end
        end

        for spot, _ in pairs(cache.fishingSpotPos) do
            if not spot or not spot.Parent then
                cache.fishingSpotPos[spot] = nil
            end
        end

        for ripple, _ in pairs(cache.activeRipples) do
            if not ripple or not ripple.Parent then
                cache.activeRipples[ripple] = nil
                cache.ripplePos[ripple] = nil
            end
        end

        for mob, _ in pairs(cache.mobAttackOriginPart) do
            if not mob or not mob.Parent then
                cache.mobAttackOriginPart[mob] = nil
                cache.mobHumanoid[mob] = nil
                cache.mobWarning[mob] = nil
                cache.mobWarningCheckTime[mob] = nil
                cache.spiderIdentifier[mob] = nil
            end
        end

        if spiderLogger and spiderLogger.currentUnknownMob then
            if not spiderLogger.currentUnknownMob.Parent or (now - spiderLogger.currentUnknownTime > 8) then
                spiderLogger.currentUnknownMob = nil
                spiderLogger.currentUnknownTime = 0
            end
        end

        cache.cleanupNodeBlacklist(now)
        if manatite and manatite.cleanupBlacklist then
            manatite.cleanupBlacklist(now)
        end
        if mithril and mithril.cleanupBlacklist then
            mithril.cleanupBlacklist(now)
        end

        pcall(function()
            if collectgarbage then
                collectgarbage("step", 100)
            end
        end)
    end
end

-- ==========================
-- MAIN ENGINE HEARTBEAT LOOP
-- ==========================
-- ==========================
-- HEARTBEAT SUB-SYSTEM HANDLERS (Modularized for Luau frame register limits < 200)
-- ==========================
function aerial.process(now, rootPos)
    local elapsed = now - aerial.startTime
    if elapsed < aerial.duration then
        if aerial.cframe and root and root.Parent then
            char:PivotTo(aerial.cframe)
            root.CFrame = aerial.cframe
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    else
        aerial.active = false
        if root and root.Parent then
            root.Anchored = false
            if aerial.preCFrame then
                char:PivotTo(aerial.preCFrame)
                root.CFrame = aerial.preCFrame
                for _, part in ipairs(charBaseParts) do
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
        aerial.cframe = nil
        aerial.preCFrame = nil
        if dodge.notifyOnDodge then
            Window:Notify({
                Title = "Aerial Retreat: Complete",
                Content = "Returned to mining position. Resuming autofarm.",
                Duration = 2,
            })
        end
    end
end

function aerial.checkHealth(now, rootPos)
    local currentHearts = dodge.getLocalPlayerHearts()
    if currentHearts and dodge.lastRecordedHearts ~= nil and currentHearts < dodge.lastRecordedHearts then
        if dodge.retreatOnThreat then
            if manatite and manatite.auto then
                local retreated = manatite.retreatToSafeCrystal(now, rootPos)
                if retreated then
                    dodge.lastRecordedHearts = currentHearts
                    return
                end
            elseif mithril and mithril.auto then
                local retreated = mithril.retreatToSafeOre(now, rootPos)
                if retreated then
                    dodge.lastRecordedHearts = currentHearts
                    return
                end
            end
        end

        if (now - aerial.lastTime) >= aerial.cooldown and not aerial.active then
            aerial.active = true
            aerial.startTime = now
            aerial.lastTime = now
            aerial.preCFrame = root.CFrame
            local hoverPos = rootPos + Vector3.new(0, aerial.height, 0)
            aerial.cframe = CFrame.new(hoverPos) * root.CFrame.Rotation
            char:PivotTo(aerial.cframe)
            root.CFrame = aerial.cframe
            root.Anchored = true
            for _, part in ipairs(charBaseParts) do
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
            if manatite and manatite.auto and manatite.model then
                manatite.blacklist[manatite.model] = now
                manatite.model = nil
                manatite.target = nil
                manatite.payload = nil
            end
            if mithril and mithril.auto and mithril.model then
                mithril.blacklist[mithril.model] = now
                mithril.model = nil
                mithril.orePart = nil
                mithril.payload = nil
            end
            if dodge.notifyOnDodge then
                Window:Notify({
                    Title = "Aerial Retreat: Low Health!",
                    Content = string.format("Retreating %d studs up for %ds. Mining paused.", aerial.height, aerial.duration),
                    Duration = 3,
                })
            end
        end
    end
    dodge.lastRecordedHearts = currentHearts
end

function dodge.process(now, rootPos)
    local currentHearts = dodge.getLocalPlayerHearts()
    local heartsDecreased = false
    local heartsBelowNormal = false

    if currentHearts then
        if dodge.normalPlayerHearts == 0 or currentHearts > dodge.normalPlayerHearts then
            dodge.normalPlayerHearts = currentHearts
        end
        local maxAttr = dodge.getLocalPlayerMaxHearts()
        if maxAttr and maxAttr > dodge.normalPlayerHearts then
            dodge.normalPlayerHearts = maxAttr
        end

        if dodge.lastRecordedHearts ~= nil and currentHearts < dodge.lastRecordedHearts then
            heartsDecreased = true
        end
        if dodge.normalPlayerHearts > 0 and (dodge.normalPlayerHearts - currentHearts) > 0.05 then
            heartsBelowNormal = true
        end
        dodge.lastRecordedHearts = currentHearts
    end

    local currentArmor = dodge.getLocalPlayerArmor()
    local armorDecreased = false
    local armorAtZero = false

    if currentArmor ~= nil then
        if dodge.normalPlayerArmor == 0 or currentArmor > dodge.normalPlayerArmor then
            dodge.normalPlayerArmor = currentArmor
        end
        local maxArmorAttr = dodge.getLocalPlayerMaxArmor()
        if maxArmorAttr and maxArmorAttr > dodge.normalPlayerArmor then
            dodge.normalPlayerArmor = maxArmorAttr
        end

        if dodge.lastRecordedArmor ~= nil and currentArmor < dodge.lastRecordedArmor then
            armorDecreased = true
        end
        if currentArmor <= 0.05 then
            armorAtZero = true
        end
        dodge.lastRecordedArmor = currentArmor
    else
        armorAtZero = true
    end

    local attackingMobFound = false
    local attackingMobInstance = nil

    local checkOrigin = (dodge.isUnderground and dodge.lastSurfacePos) or rootPos
    local losOrigin = checkOrigin + Vector3.new(0, 0.5, 0)
    for _, mob in ipairs(cache.activeAuraMobs) do
        if mob.Parent then
            local mobPos = dodge.getMobAttackOrigin(mob)
            if mobPos and get2DDistanceSq(checkOrigin, mobPos) <= dodge.detectionRadiusSq then
                if dodge.isMobAlive(mob) then
                    local warning = dodge.findAttackWarning(mob)
                    if dodge.isWarningActive(warning, mob) then
                        if dodge.hasLineOfSight(losOrigin, mobPos, mob) then
                            attackingMobFound = true
                            attackingMobInstance = mob
                            dodge.currentAttackingMob = mob
                            break
                        end
                    end
                end
            end
        end
    end

    local damageRetreatTriggered = false
    if dodge.dodgeOnHeartsDecreased then
        if armorDecreased and armorAtZero then
            damageRetreatTriggered = true
            dodge.lastDamageRetreatTime = now
        elseif armorAtZero and heartsBelowNormal and not dodge.isDodging and (now - dodge.lastDamageRetreatTime > 2.0) then
            damageRetreatTriggered = true
            dodge.lastDamageRetreatTime = now
        end
    end

    local shouldRetreat = (attackingMobFound and attackingMobInstance) or damageRetreatTriggered

    if shouldRetreat then
        dodge.lastWarningSeenTime = now

        if dodge.retreatOnThreat then
            if manatite and manatite.auto then
                local retreated = manatite.retreatToSafeCrystal(now, rootPos)
                if retreated then return end
            elseif mithril and mithril.auto then
                local retreated = mithril.retreatToSafeOre(now, rootPos)
                if retreated then return end
            end
        end

        if not dodge.isDodging then
            dodge.isDodging = true
            dodge.startTime = now
            dodge.preDodgePos = rootPos
            dodge.preDodgeCFrame = root.CFrame

            if farm.on then
                farm.currentTargetNode = nil
            end

            if dodge.notifyOnDodge then
                Window:Notify({
                    Title = "Mob Attack Incoming!",
                    Content = string.format("Evading attack (%s).", dodge.method),
                    Duration = 2,
                })
            end

            if dodge.method == "Underground" then
                dodge.lastSurfaceCFrame = root.CFrame
                dodge.lastSurfacePos = rootPos

                local attackOrigin = (attackingMobInstance and dodge.getMobAttackOrigin(attackingMobInstance)) or rootPos
                local awayDir = rootPos - attackOrigin
                local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)
                away2D = (away2D.Magnitude > 0.1) and away2D.Unit or Vector3.new(0, 0, 1)

                local horizontalOffset = away2D * 15
                dodge.currentUndergroundRetreatOffset = horizontalOffset
                dodge.undergroundCFrame = CFrame.new(rootPos + horizontalOffset - Vector3.new(0, dodge.undergroundDepth, 0)) * root.CFrame.Rotation

                char:PivotTo(dodge.undergroundCFrame)
                root.CFrame = dodge.undergroundCFrame
                root.Anchored = true
                dodge.isUnderground = true

                for _, part in ipairs(charBaseParts) do
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                    if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                        part.CanCollide = false
                    end
                end
            elseif dodge.method == "Run Away (Surface)" then
                if humanoid then
                    dodge.originalWalkSpeed = humanoid.WalkSpeed
                    humanoid.WalkSpeed = dodge.walkSpeed

                    local attackOrigin = (attackingMobInstance and dodge.getMobAttackOrigin(attackingMobInstance)) or rootPos
                    local awayDir = rootPos - attackOrigin
                    local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)
                    away2D = (away2D.Magnitude > 0.1) and away2D.Unit or Vector3.new(0, 0, 1)

                    local rotatedAway = CFrame.Angles(0, math.rad(dodge.retreatAngle), 0):VectorToWorldSpace(away2D)
                    humanoid:Move(rotatedAway, false)
                end
            elseif dodge.method == "Teleport Away (Surface)" then
                local attackOrigin = (attackingMobInstance and dodge.getMobAttackOrigin(attackingMobInstance)) or rootPos
                local awayDir = rootPos - attackOrigin
                local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)
                away2D = (away2D.Magnitude > 0.1) and away2D.Unit or Vector3.new(0, 0, 1)

                local safeDodgeCFrame, safeDodgeDist = dodge.findSafeDodgePosition(rootPos, root.CFrame, away2D, 25, attackingMobInstance)

                if safeDodgeCFrame then
                    char:PivotTo(safeDodgeCFrame)
                    root.CFrame = safeDodgeCFrame
                    dodge.lastTeleportDodgeDist = safeDodgeDist

                    for _, part in ipairs(charBaseParts) do
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                    if humanoid then
                        humanoid:Move(Vector3.zero, false)
                    end
                else
                    dodge.lastSurfaceCFrame = root.CFrame
                    dodge.lastSurfacePos = rootPos
                    dodge.undergroundCFrame = CFrame.new(rootPos - Vector3.new(0, dodge.undergroundDepth, 0)) * root.CFrame.Rotation
                    char:PivotTo(dodge.undergroundCFrame)
                    root.CFrame = dodge.undergroundCFrame
                    root.Anchored = true
                    dodge.isUnderground = true
                    for _, part in ipairs(charBaseParts) do
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                        if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                            part.CanCollide = false
                        end
                    end
                end
            end
        else
            if dodge.method == "Underground" and dodge.isUnderground and dodge.undergroundCFrame then
                char:PivotTo(dodge.undergroundCFrame)
                root.CFrame = dodge.undergroundCFrame
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            elseif dodge.method == "Run Away (Surface)" then
                if humanoid then
                    if humanoid.WalkSpeed ~= dodge.walkSpeed then
                        humanoid.WalkSpeed = dodge.walkSpeed
                    end
                    local attackOrigin = (attackingMobInstance and dodge.getMobAttackOrigin(attackingMobInstance)) or (dodge.preDodgePos or rootPos)
                    local currentDist = get2DDistance(rootPos, attackOrigin)
                    if currentDist < dodge.retreatDistance then
                        local awayDir = rootPos - attackOrigin
                        local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)
                        away2D = (away2D.Magnitude > 0.1) and away2D.Unit or Vector3.new(0, 0, 1)
                        local rotatedAway = CFrame.Angles(0, math.rad(dodge.retreatAngle), 0):VectorToWorldSpace(away2D)
                        humanoid:Move(rotatedAway, false)
                    else
                        humanoid:Move(Vector3.zero, false)
                    end
                end
            end
        end
    else
        if dodge.isDodging then
            if (now - dodge.lastWarningSeenTime >= dodge.lingerDelay) then
                if dodge.method == "Underground" and dodge.isUnderground then
                    if dodge.lastSurfaceCFrame then
                        local surfaceTarget = dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
                        char:PivotTo(surfaceTarget)
                        root.CFrame = surfaceTarget
                    end
                    root.Anchored = false
                    for _, part in ipairs(charBaseParts) do
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                        if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                            part.CanCollide = true
                        end
                    end
                    dodge.isUnderground = false
                    dodge.lastSurfaceCFrame = nil
                    dodge.lastSurfacePos = nil
                    dodge.undergroundCFrame = nil
                elseif dodge.method == "Run Away (Surface)" then
                    if humanoid then
                        humanoid.WalkSpeed = dodge.originalWalkSpeed or 16
                        if not farm.on then
                            humanoid:Move(Vector3.zero, false)
                        end
                    end
                elseif dodge.method == "Teleport Away (Surface)" then
                    if humanoid then
                        humanoid.WalkSpeed = dodge.originalWalkSpeed or 16
                    end
                    if dodge.preDodgeCFrame then
                        local crystalStillValid = (manatite and manatite.auto and manatite.model and not manatite.blacklist[manatite.model])
                            or (mithril and mithril.auto and mithril.model and not mithril.blacklist[mithril.model])
                        if crystalStillValid then
                            char:PivotTo(dodge.preDodgeCFrame)
                            root.CFrame = dodge.preDodgeCFrame
                            for _, part in ipairs(charBaseParts) do
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end
                            if ((manatite and manatite.auto and manatite.anchor) or (mithril and mithril.auto and mithril.anchor)) and not dodge.hasNearbyThreat then
                                pcall(function() root.Anchored = true end)
                            end
                        end
                    end
                end

                dodge.isDodging = false
                dodge.currentAttackingMob = nil
                dodge.preDodgePos = nil
                dodge.preDodgeCFrame = nil

                if farm.on then
                    farm.currentTargetNode = nil
                end

                if dodge.notifyOnDodge then
                    Window:Notify({
                        Title = "Attack Cleared",
                        Content = "Safe from attack. Resumed normal activity.",
                        Duration = 1.2,
                    })
                end
            else
                if dodge.method == "Run Away (Surface)" then
                    if humanoid then
                        if humanoid.WalkSpeed ~= dodge.walkSpeed then
                            humanoid.WalkSpeed = dodge.walkSpeed
                        end
                        local attackOrigin = (dodge.currentAttackingMob and dodge.getMobAttackOrigin(dodge.currentAttackingMob)) or (dodge.preDodgePos or rootPos)
                        local currentDist = get2DDistance(rootPos, attackOrigin)
                        if currentDist < dodge.retreatDistance then
                            local awayDir = rootPos - attackOrigin
                            local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)
                            away2D = (away2D.Magnitude > 0.1) and away2D.Unit or Vector3.new(0, 0, 1)
                            humanoid:Move(away2D, false)
                        else
                            humanoid:Move(Vector3.zero, false)
                        end
                    end
                elseif dodge.method == "Underground" and dodge.isUnderground and dodge.undergroundCFrame then
                    char:PivotTo(dodge.undergroundCFrame)
                    root.CFrame = dodge.undergroundCFrame
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end
end

function dodge.cleanup()
    if dodge.isUnderground then
        if dodge.lastSurfaceCFrame then
            local surfaceTarget = dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            char:PivotTo(surfaceTarget)
            root.CFrame = surfaceTarget
        end
        root.Anchored = false
        for _, part in ipairs(charBaseParts) do
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
            if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                part.CanCollide = true
            end
        end
        dodge.isUnderground = false
        dodge.lastSurfaceCFrame = nil
        dodge.lastSurfacePos = nil
        dodge.undergroundCFrame = nil
    end
    if humanoid then
        humanoid.WalkSpeed = dodge.originalWalkSpeed or 16
        if not farm.on then
            humanoid:Move(Vector3.zero, false)
        end
    end
    if dodge.method == "Teleport Away (Surface)" and dodge.preDodgeCFrame then
        if ((manatite and manatite.auto) or (mithril and mithril.auto)) then
            char:PivotTo(dodge.preDodgeCFrame)
            root.CFrame = dodge.preDodgeCFrame
            for _, part in ipairs(charBaseParts) do
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
            if ((manatite and manatite.auto and manatite.anchor) or (mithril and mithril.auto and mithril.anchor)) then
                pcall(function() root.Anchored = true end)
            end
        end
    end
    dodge.isDodging = false
    dodge.currentAttackingMob = nil
    dodge.preDodgePos = nil
    dodge.preDodgeCFrame = nil
end

function dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)
    local hasNearbyThreat = false
    if (manatite and manatite.auto) or (mithril and mithril.auto) or (farm.autoChompMobs and farm.on) then
        local threatOrigin = dodge.isUnderground and (dodge.lastSurfacePos or rootPos) or rootPos
        local losOrigin = threatOrigin + Vector3.new(0, 0.5, 0)
        for _, mob in ipairs(cache.activeAuraMobs) do
            if mob.Parent and dodge.isMobAlive(mob) then
                local mobPos = dodge.getMobAttackOrigin(mob)
                if mobPos and get3DDistanceSq(threatOrigin, mobPos) <= dodge.manatiteThreatRadiusSq then
                    if dodge.hasLineOfSight(losOrigin, mobPos, mob) then
                        hasNearbyThreat = true
                        break
                    end
                end
            end
        end
    end

    if hasNearbyThreat then
        if dodge.retreatOnThreat then
            local retreated = false
            if manatite and manatite.auto then
                retreated = manatite.retreatToSafeCrystal(now, rootPos)
            elseif mithril and mithril.auto then
                retreated = mithril.retreatToSafeOre(now, rootPos)
            end
            if retreated then
                dodge.threatStartTime = 0
                return false
            end
        end

        if not prioritizedMobThisFrame then
            hasNearbyThreat = false
        end

        if hasNearbyThreat then
            if dodge.threatStartTime == 0 then
                dodge.threatStartTime = now
            elseif (now - dodge.threatStartTime > 1.5) then
                if manatite and manatite.auto and manatite.model then
                    manatite.blacklist[manatite.model] = now
                    manatite.model = nil
                    manatite.target = nil
                    manatite.payload = nil
                end
                if mithril and mithril.auto and mithril.model then
                    mithril.blacklist[mithril.model] = now
                    mithril.model = nil
                    mithril.orePart = nil
                    mithril.payload = nil
                end
                if root then
                    pcall(function() root.Anchored = false end)
                end
                dodge.threatStartTime = 0
                hasNearbyThreat = false
            end
        else
            dodge.threatStartTime = 0
        end
    else
        dodge.threatStartTime = 0
    end

    if hasNearbyThreat and dodge.prioritizeMobsOverManatite and root.Anchored and not dodge.isUnderground then
        pcall(function() root.Anchored = false end)
    end

    return hasNearbyThreat
end

function farm.processMovement(dt, now, rootPos)
    farm.patternTimer = farm.patternTimer + (dt * farm.patternSpeed)
    local targetPos

    if farm.pattern == "Guided Zigzag (Nodes)" then
        local ghostX = math.sin(farm.patternTimer * 1.3) * farm.radius
        local ghostZ = math.cos(farm.patternTimer * 1.9) * farm.radius
        local ghostPos = farm.anchorPos + Vector3.new(ghostX, 0, ghostZ)

        local needNewNode = false
        if not farm.currentTargetNode or not farm.currentTargetNode.Parent then
            needNewNode = true
        else
            local tPos = cache.getNodePosition(farm.currentTargetNode)
            if get2DDistanceSq(rootPos, tPos) < 16 then
                needNewNode = true
            end
        end

        if needNewNode then
            local nearestDistSq = math.huge
            local nearestNode = nil
            local grassNodes = cache.getGrassNodes()

            for _, node in ipairs(grassNodes) do
                if node.Parent then
                    local nodePos = cache.getNodePosition(node)
                    if get2DDistanceSq(farm.anchorPos, nodePos) <= farm.radiusSq then
                        local cleanName = cache.getCleanGrassName(node.Name)
                        if cleanName then
                            local distFromGhostSq = get2DDistanceSq(ghostPos, nodePos)
                            local blacklistedAt = cache.nodeBlacklist[node]
                            if distFromGhostSq < nearestDistSq and (not blacklistedAt or now - blacklistedAt > 10) then
                                nearestDistSq = distFromGhostSq
                                nearestNode = node
                            end
                        end
                    end
                end
            end

            if nearestNode then
                farm.currentTargetNode = nearestNode
                cache.nodeBlacklist[nearestNode] = now
            else
                farm.currentTargetNode = nil
                if not farm.nextRandomPos or get2DDistanceSq(rootPos, farm.nextRandomPos) < 25 then
                    local angle = math.random() * (math.pi * 2)
                    farm.nextRandomPos = farm.anchorPos + Vector3.new(math.cos(angle) * farm.radius, 0, math.sin(angle) * farm.radius)
                end
            end
        end

        if farm.currentTargetNode and farm.currentTargetNode.Parent then
            targetPos = cache.getNodePosition(farm.currentTargetNode)
        else
            targetPos = farm.nextRandomPos
        end

    elseif farm.pattern == "Circle" then
        local currentRadius = farm.radius * math.abs(math.sin(farm.patternTimer * 0.2))
        local angle = farm.patternTimer * 1.5
        targetPos = farm.anchorPos + Vector3.new(math.cos(angle) * currentRadius, 0, math.sin(angle) * currentRadius)

    elseif farm.pattern == "Square" then
        targetPos = farm.anchorPos + Vector3.new(math.sin(farm.patternTimer * 1.8) * farm.radius, 0, math.cos(farm.patternTimer * 0.2) * farm.radius)

    elseif farm.pattern == "Zigzag" then
        targetPos = farm.anchorPos + Vector3.new(math.sin(farm.patternTimer * 1.3) * farm.radius, 0, math.cos(farm.patternTimer * 1.9) * farm.radius)

    elseif farm.pattern == "Random" then
        if not farm.nextRandomPos or get2DDistanceSq(rootPos, farm.nextRandomPos) < 25 then
            local angle = math.random() * (math.pi * 2)
            farm.nextRandomPos = farm.anchorPos + Vector3.new(math.cos(angle) * farm.radius, 0, math.sin(angle) * farm.radius)
        end
        targetPos = farm.nextRandomPos
    end

    if targetPos and (now - farm.lastMoveTime > 0.05) then
        local offX = targetPos.X - farm.anchorPos.X
        local offZ = targetPos.Z - farm.anchorPos.Z
        local distSq = offX * offX + offZ * offZ
        if distSq > farm.radiusSq then
            local scale = farm.radius / math.sqrt(distSq)
            targetPos = Vector3.new(farm.anchorPos.X + offX * scale, targetPos.Y, farm.anchorPos.Z + offZ * scale)
        end

        humanoid:MoveTo(targetPos)
        farm.lastMoveTime = now
    end
end

function farm.processMobAura(now, rootPos)
    local auraOrigin = dodge.isUnderground and (dodge.lastSurfacePos or rootPos) or rootPos
    local losOrigin = (dodge.isUnderground and dodge.lastSurfacePos or rootPos) + Vector3.new(0, 0.5, 0)
    local closestMob = nil
    local closestDistSq = math.huge
    local closestMobPos = nil

    for _, mob in ipairs(cache.activeAuraMobs) do
        if mob.Parent then
            local mobPos = dodge.getMobAttackOrigin(mob)
            if mobPos then
                local distSq = get3DDistanceSq(auraOrigin, mobPos)
                if distSq <= farm.mobAuraRadiusSq and distSq < closestDistSq then
                    if dodge.isMobAlive(mob) and dodge.hasLineOfSight(losOrigin, mobPos, mob) then
                        closestDistSq = distSq
                        closestMob = mob
                        closestMobPos = mobPos
                    end
                end
            end
        end
    end

    if closestMob then
        local mob = closestMob
        local mobPos = closestMobPos
        local isCaveMob = dodge.isMithrilCaveMob(mob)

        if isCaveMob then
            if (now - farm.mobChompCooldown > farm.mobAuraDelay) or (farm.lastChompedMob ~= mob) then
                if not dodge.isUnderground and not dodge.isDodging then
                    local lookDx = mobPos.X - rootPos.X
                    local lookDz = mobPos.Z - rootPos.Z
                    if (lookDx * lookDx + lookDz * lookDz) > 0.01 then
                        root.CFrame = CFrame.lookAt(rootPos, Vector3.new(mobPos.X, rootPos.Y, mobPos.Z))
                    end
                end

                local spiderId = cache.findSpiderIdentifier(mob)
                if spiderId then
                    local payloadName = "Cavern_Mob_Spider_" .. tostring(spiderId)
                    if spiderLogger then spiderLogger.isInternalFire = true end
                    chompEvent:FireServer(payloadName)
                    if spiderLogger then spiderLogger.isInternalFire = false end
                else
                    if spiderLogger then
                        spiderLogger.currentUnknownMob = mob
                        spiderLogger.currentUnknownTime = now
                        spiderLogger.isInternalFire = true

                        -- 1. Reference all known identifiers logged from the server in SpiderIdentifiers.json
                        if spiderLogger.data and spiderLogger.data.identifiers then
                            for _, knownId in ipairs(spiderLogger.data.identifiers) do
                                chompEvent:FireServer("Cavern_Mob_Spider_" .. tostring(knownId))
                            end
                        end
                    end

                    -- 2. Fallbacks
                    local fallbackPayload = cache.getMobPayload(mob.Name)
                    if fallbackPayload then
                        chompEvent:FireServer(fallbackPayload)
                    end
                    chompEvent:FireServer("Cavern_Mob_Spider")
                    chompEvent:FireServer(mob.Name)

                    if spiderLogger then spiderLogger.isInternalFire = false end
                end

                if fireproximityprompt then
                    local prompt = mob:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end

                pressE()

                farm.lastChompedMob = mob
                farm.mobChompCooldown = now
                return true
            else
                return true
            end
        else
            local payloadName = cache.getMobPayload(mob.Name)

            if payloadName ~= farm.lastChompedMob or (now - farm.mobChompCooldown > farm.mobAuraDelay) then
                if not dodge.isUnderground and not dodge.isDodging then
                    local lookDx = mobPos.X - rootPos.X
                    local lookDz = mobPos.Z - rootPos.Z
                    if (lookDx * lookDx + lookDz * lookDz) > 0.01 then
                        root.CFrame = CFrame.lookAt(rootPos, Vector3.new(mobPos.X, rootPos.Y, mobPos.Z))
                    end
                end
                chompEvent:FireServer(payloadName)
                farm.lastChompedMob = payloadName
                farm.mobChompCooldown = now
                return true
            else
                return true
            end
        end
    end
    return false
end

function farm.processGrassChomp(now, rootPos)
    if (now - farm.lastRaycastChompTime > 0.04) then
        farm.lastRaycastChompTime = now
        local hit = workspace:Raycast(rootPos, RAYCAST_DOWN, raycastParams)

        if hit and hit.Instance then
            local actualNode = hit.Instance

            if not string.find(actualNode.Name, "Grass", 1, true) and actualNode.Parent then
                if string.find(actualNode.Parent.Name, "Grass", 1, true) then
                    actualNode = actualNode.Parent
                end
            end

            local nodeName = actualNode.Name
            if string.find(nodeName, "Grass", 1, true) then
                local cleanName = cache.getCleanGrassName(nodeName)
                if cleanName then
                    if cleanName ~= farm.lastChompedNode or (now - farm.chompCooldown > 1) then
                        chompEvent:FireServer(cleanName)
                        farm.lastChompedNode = cleanName
                        farm.chompCooldown = now

                        if farm.currentTargetNode and farm.currentTargetNode.Name == nodeName then
                            farm.currentTargetNode = nil
                        end
                    end
                end
            end
        end
    end
end

function farm.processFishing(now, rootPos)
    if not fishingEvent and cowRemotes then
        fishingEvent = cowRemotes:FindFirstChild("FishingRequest")
    end
    if fishingEvent and (now - farm.castCooldown > 3) and (now - farm.lastFishingSearchTime > 0.3) then
        farm.lastFishingSearchTime = now
        local nearestSpot = nil
        local shortestDistSq = 2500
        local fishingSpots = cache.getFishingSpots()

        for _, spot in ipairs(fishingSpots) do
            if spot.Parent then
                local spotPos = cache.getSpotPosition(spot)
                if spotPos then
                    local distSq = get2DDistanceSq(rootPos, spotPos)
                    if distSq < shortestDistSq and cache.isSpotAvailable(spot) then
                        shortestDistSq = distSq
                        nearestSpot = spot
                    end
                end
            end
        end

        if nearestSpot then
            fishingEvent:FireServer("Cast", nearestSpot)
            farm.castCooldown = now
        end
    end
end

function manatite.process(now, rootPos)
    manatite.cleanupBlacklist(now)

    local targetValid = manatite.model
        and manatite.target
        and manatite.model.Parent
        and manatite.target.Parent
        and manatite.isAvailable(manatite.target, manatite.model)
        and (now - manatite.startTime <= 15)

    if not targetValid then
        if manatite.model and (now - manatite.startTime > 15) then
            manatite.blacklist[manatite.model] = now
        end

        manatite.model = nil
        manatite.target = nil
        manatite.payload = nil

        if manatite.anchor and root then
            pcall(function() root.Anchored = false end)
        end

        if (now - manatite.lastSearchTime > 0.1) then
            manatite.lastSearchTime = now
            local nextModel, nextTarget = manatite.findNext(rootPos)
            if nextModel and nextTarget then
                manatite.model = nextModel
                manatite.target = nextTarget
                manatite.payload = manatite.getPayload(nextModel.Name)
                manatite.startTime = now
                manatite.teleport(nextTarget, nextModel)
                manatite.lastTeleportTime = now
                manatite.lastChompTime = 0
            end
        end
    else
        local targetPos = manatite.target.Position + Vector3.new(0, manatite.heightOffset, 0)

        if dodge.retreatOnThreat and (now - manatite.lastSearchTime > 0.25) then
            local checkPos = manatite.target.Position
            if manatite.isPositionNearMob(checkPos, dodge.manatiteThreatRadiusSq) or manatite.isPositionNearMob(rootPos, dodge.manatiteThreatRadiusSq) then
                manatite.retreatToSafeCrystal(now, rootPos)
                return
            end
        end

        if get3DDistanceSq(rootPos, targetPos) > 36 then
            if (now - manatite.lastTeleportTime > 0.4) then
                manatite.teleport(manatite.target, manatite.model)
                manatite.lastTeleportTime = now
            end
        else
            if manatite.anchor and not root.Anchored and not dodge.isDodging and not dodge.isUnderground and not dodge.hasNearbyThreat then
                pcall(function() root.Anchored = true end)
            end
        end

        if (now - manatite.lastChompTime >= manatite.delay) then
            manatite.lastChompTime = now
            chompEvent:FireServer(manatite.payload)
        end
    end
end

function mithril.process(now, rootPos)
    mithril.cleanupBlacklist(now)

    local targetValid = mithril.model
        and mithril.orePart
        and mithril.model.Parent
        and mithril.orePart.Parent
        and mithril.isAvailable(mithril.orePart, mithril.model)
        and (now - mithril.startTime <= 15)

    if not targetValid then
        if mithril.model and (now - mithril.startTime > 15) then
            mithril.blacklist[mithril.model] = now
        end

        mithril.model = nil
        mithril.orePart = nil
        mithril.payload = nil

        if mithril.anchor and root then
            pcall(function() root.Anchored = false end)
        end

        if (now - mithril.lastSearchTime > 0.1) then
            mithril.lastSearchTime = now
            local nextModel, nextOre = mithril.findNext(rootPos)
            if nextModel and nextOre then
                mithril.model = nextModel
                mithril.orePart = nextOre
                mithril.payload = mithril.getPayload(nextModel.Name)
                mithril.startTime = now
                mithril.teleport(nextOre, nextModel)
                mithril.lastTeleportTime = now
                mithril.lastChompTime = 0
            end
        end
    else
        local targetPos = mithril.orePart.Position + Vector3.new(0, mithril.heightOffset, 0)

        if dodge.retreatOnThreat and (now - mithril.lastSearchTime > 0.25) then
            local checkPos = mithril.orePart.Position
            if mithril.isPositionNearMob(checkPos, dodge.manatiteThreatRadiusSq) or mithril.isPositionNearMob(rootPos, dodge.manatiteThreatRadiusSq) then
                mithril.retreatToSafeOre(now, rootPos)
                return
            end
        end

        if get3DDistanceSq(rootPos, targetPos) > 36 then
            if (now - mithril.lastTeleportTime > 0.4) then
                mithril.teleport(mithril.orePart, mithril.model)
                mithril.lastTeleportTime = now
            end
        else
            if mithril.anchor and not root.Anchored and not dodge.isDodging and not dodge.isUnderground and not dodge.hasNearbyThreat then
                pcall(function() root.Anchored = true end)
            end
        end

        if (now - mithril.lastChompTime >= mithril.delay) then
            mithril.lastChompTime = now
            chompEvent:FireServer(mithril.payload)
        end
    end
end

-- ==========================
-- MAIN ENGINE HEARTBEAT LOOP (Concise Dispatcher)
-- ==========================
local function updateHeartbeatConnection()
    if farm.on or farm.autoChomp or farm.autoFish or farm.autoChompMobs or dodge.auto or (manatite and manatite.auto) or (mithril and mithril.auto) then
        if not HeartbeatConnection then
            HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
                if not root or not humanoid or not root.Parent or not humanoid.Parent or humanoid.Health <= 0 then
                    if dodge.isUnderground then
                        dodge.isUnderground = false
                        pcall(function() if root then root.Anchored = false end end)
                    end
                    if dodge.isDodging then
                        dodge.isDodging = false
                        dodge.currentAttackingMob = nil
                    end
                    if manatite then
                        manatite.model = nil
                        manatite.target = nil
                        manatite.payload = nil
                    end
                    if mithril then
                        mithril.model = nil
                        mithril.orePart = nil
                        mithril.payload = nil
                    end
                    return
                end

                local now = os.clock()
                local rootPos = root.Position

                -- Targeted background caches refresh (only when mobs need caching)
                if (farm.autoChompMobs or dodge.auto) and (now - cache.lastBackgroundTime > 1.5) then
                    cache.lastBackgroundTime = now
                    task.spawn(cache.cacheBackgroundElements)
                end

                -- Comprehensive memory sanitation
                cache.sanitizeMemory(now)

                -- 0. Priority Mob Attack Warning & Dodge Logic (Run Away & Surface Retreat)
                -- === AERIAL RETREAT: Low-Health Emergency Hover ===
                if aerial.active then
                    aerial.process(now, rootPos)
                elseif dodge.auto and dodge.dodgeOnHeartsDecreased then
                    aerial.checkHealth(now, rootPos)
                end

                if dodge.auto and not aerial.active then
                    dodge.process(now, rootPos)
                elseif dodge.isDodging or dodge.isUnderground then
                    dodge.cleanup()
                end

                -- 1. Movement Logic
                if farm.on and not (manatite and manatite.auto) and not (mithril and mithril.auto) and farm.anchorPos and not dodge.isDodging and not dodge.isUnderground then
                    farm.processMovement(dt, now, rootPos)
                end

                local prioritizedMobThisFrame = false

                -- 2. Priority Mob Aura Logic
                if farm.autoChompMobs then
                    prioritizedMobThisFrame = farm.processMobAura(now, rootPos)
                end

                -- 3. Raycast Grass Chomp Logic (Yields to Mobs & Dodging)
                if farm.autoChomp and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not prioritizedMobThisFrame and not dodge.isUnderground and not dodge.isDodging then
                    farm.processGrassChomp(now, rootPos)
                end

                -- 4. Auto-Fishing Logic
                if farm.autoFish and not (manatite and manatite.auto) and not (mithril and mithril.auto) then
                    farm.processFishing(now, rootPos)
                end

                -- Threat clearing detection
                local hasNearbyThreat = dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)

                -- 5. Manatite Farm Logic
                if manatite and manatite.auto and not dodge.isUnderground and not dodge.isDodging and not aerial.active and not (dodge.prioritizeMobsOverManatite and hasNearbyThreat) then
                    manatite.process(now, rootPos)
                end

                -- 6. Mithril Ore Farm Logic
                if mithril and mithril.auto and not dodge.isUnderground and not dodge.isDodging and not aerial.active and not (dodge.prioritizeMobsOverManatite and hasNearbyThreat) then
                    mithril.process(now, rootPos)
                end
            end)
        end
    else
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
            HeartbeatConnection = nil
        end
        if dodge.isUnderground and root and dodge.lastSurfaceCFrame then
            root.CFrame = dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            for _, part in ipairs(charBaseParts) do
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                    part.CanCollide = true
                end
            end
            dodge.isUnderground = false
            dodge.lastSurfaceCFrame = nil
            dodge.lastSurfacePos = nil
            dodge.undergroundCFrame = nil
        end
        if dodge.isDodging then
            if humanoid then humanoid.WalkSpeed = dodge.originalWalkSpeed or 16 end
            dodge.isDodging = false
            dodge.currentAttackingMob = nil
            dodge.preDodgePos = nil
            dodge.preDodgeCFrame = nil
        end
        if manatite and not manatite.auto and manatite.anchor and root then
            pcall(function() root.Anchored = false end)
        end
        if mithril and not mithril.auto and mithril.anchor and root then
            pcall(function() root.Anchored = false end)
        end
        if not farm.on and humanoid then humanoid:Move(Vector3.zero, false) end
    end
end

-- ==========================
-- UI SETUP: Main Farming Tab
-- ==========================
local MainTab = Window:CreateTab({ Name = "Autofarm", Icon = 4483362458 })

MainTab:CreateSection({ Name = "Main Toggles" })

MainTab:CreateToggle({
    Name = "Enable Autofarm (Movement)",
    CurrentValue = false,
    Flag = "Toggle_Farm",
    Callback = function(Value)
        farm.on = Value
        farm.patternTimer = 0
        farm.nextRandomPos = nil
        farm.currentTargetNode = nil

        if Value then
            farm.anchorPos = root.Position

            Window:Notify({
                Title = "Autofarm Enabled",
                Content = "Absolute static home base set. Walking started.",
                Duration = 3,
                Image = 4483362458,
            })
        end

        penESP.update()
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Auto-Chomper (Grass)",
    CurrentValue = false,
    Flag = "Toggle_Chomp",
    Callback = function(Value)
        farm.autoChomp = Value
        updateHeartbeatConnection()
    end,
})


MainTab:CreateToggle({
    Name = "Enable Mob Aura (Priority)",
    CurrentValue = false,
    Flag = "Toggle_MobAura",
    Callback = function(Value)
        farm.autoChompMobs = Value
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Auto-Fishing",
    CurrentValue = false,
    Flag = "Toggle_Fish",
    Callback = function(Value)
        farm.autoFish = Value
        if Value then
            cache.initRippleTracking()
        else
            cache.cleanupRippleTracking()
        end
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Mob Attack Dodge",
    CurrentValue = false,
    Flag = "Toggle_AutoDodge",
    Callback = function(Value)
        dodge.auto = Value
        if not Value then
            if dodge.isUnderground and root and dodge.lastSurfaceCFrame then
                root.CFrame = dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
                root.Anchored = false
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                for _, part in ipairs(charBaseParts) do
                    if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                        part.CanCollide = true
                    end
                end
                dodge.isUnderground = false
                dodge.lastSurfaceCFrame = nil
                dodge.lastSurfacePos = nil
                dodge.undergroundCFrame = nil
            end
            if dodge.isDodging then
                if humanoid then humanoid.WalkSpeed = dodge.originalWalkSpeed or 16 end
                dodge.isDodging = false
                dodge.currentAttackingMob = nil
                dodge.preDodgePos = nil
                dodge.preDodgeCFrame = nil
                if not farm.on and humanoid then humanoid:Move(Vector3.zero, false) end
            end
        end
        updateHeartbeatConnection()
    end,
})


MainTab:CreateSection({ Name = "Aura & Pattern Configuration" })

MainTab:CreateDropdown({
    Name = "Mob Aura Speed",
    Options = {"Slow (1.0s)", "Normal (0.5s)", "Fast (0.1s)"},
    CurrentOption = {"Fast (0.1s)"},
    MultipleOptions = false,
    Flag = "Dropdown_MobSpeed",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Slow (1.0s)" then farm.mobAuraDelay = 1.0
        elseif selection == "Normal (0.5s)" then farm.mobAuraDelay = 0.5
        elseif selection == "Fast (0.1s)" then farm.mobAuraDelay = 0.1
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Walking Pattern",
    Options = {"Guided Zigzag (Nodes)", "Circle", "Square", "Zigzag", "Random"},
    CurrentOption = {"Guided Zigzag (Nodes)"},
    MultipleOptions = false,
    Flag = "Dropdown_Pattern",
    Callback = function(Option) farm.pattern = type(Option) == "table" and Option[1] or Option end,
})

MainTab:CreateSlider({
    Name = "Farm Radius (Studs)",
    Range = {10, 300},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 75,
    Flag = "Slider_Radius",
    Callback = function(Value)
        farm.radius = Value
        farm.radiusSq = farm.radius * farm.radius
        updatePenVisualizer()
    end,
})

MainTab:CreateDropdown({
    Name = "Walking Speed",
    Options = {"Very Slow (0.4x)", "Slow (0.6x)", "Normal (1.0x)", "Fast (1.6x)"},
    CurrentOption = {"Normal (1.0x)"},
    MultipleOptions = false,
    Flag = "Dropdown_Speed",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Very Slow (0.4x)" then farm.patternSpeed = 0.4
        elseif selection == "Slow (0.6x)" then farm.patternSpeed = 0.6
        elseif selection == "Normal (1.0x)" then farm.patternSpeed = 1.0
        elseif selection == "Fast (1.6x)" then farm.patternSpeed = 1.6
        end
    end,
})

MainTab:CreateSection({ Name = "Mob Attack Dodge Configuration" })

MainTab:CreateDropdown({
    Name = "Dodge Method",
    Options = {"Underground", "Run Away (Surface)", "Teleport Away (Surface)"},
    CurrentOption = {"Underground"},
    MultipleOptions = false,
    Flag = "Dropdown_DodgeMethod",
    Callback = function(Option)
        dodge.method = type(Option) == "table" and Option[1] or Option
        if dodge.method ~= "Underground" and dodge.isUnderground and root and dodge.lastSurfaceCFrame then
            root.CFrame = dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            dodge.isUnderground = false
        end
    end,
})

MainTab:CreateSlider({
    Name = "Retreat Distance (Studs)",
    Range = {10, 60},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 25,
    Flag = "Slider_DodgeRetreat",
    Callback = function(Value)
        dodge.retreatDistance = Value
    end,
})

MainTab:CreateSlider({
    Name = "Retreat Angle (Degrees)",
    Range = {0, 90},
    Increment = 5,
    Suffix = "°",
    CurrentValue = 45,
    Flag = "Slider_DodgeAngle",
    Callback = function(Value)
        dodge.retreatAngle = Value
    end,
})

MainTab:CreateSlider({
    Name = "Retreat Walk Speed",
    Range = {16, 50},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 26,
    Flag = "Slider_DodgeSpeed",
    Callback = function(Value)
        dodge.walkSpeed = Value
    end,
})

MainTab:CreateSlider({
    Name = "Underground Depth (Studs)",
    Range = {0, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 20,
    Flag = "Slider_DodgeDepth",
    Callback = function(Value)
        dodge.undergroundDepth = Value
    end,
})

MainTab:CreateSlider({
    Name = "Dodge Detection Range (Studs)",
    Range = {10, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 15,
    Flag = "Slider_DodgeRange",
    Callback = function(Value)
        dodge.detectionRadius = Value
        dodge.detectionRadiusSq = Value * Value
    end,
})

MainTab:CreateSlider({
    Name = "Dodge Return Delay (Seconds)",
    Range = {0.05, 2.5},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.6,
    Flag = "Slider_DodgeLinger",
    Callback = function(Value)
        dodge.lingerDelay = Value
    end,
})

MainTab:CreateToggle({
    Name = "Notify on Attack Dodge",
    CurrentValue = false,
    Flag = "Toggle_DodgeNotify",
    Callback = function(Value)
        dodge.notifyOnDodge = Value
    end,
})

MainTab:CreateToggle({
    Name = "Retreat on Armor / Hearts Decreased",
    CurrentValue = true,
    Flag = "Toggle_DodgeHearts",
    Callback = function(Value)
        dodge.dodgeOnHeartsDecreased = Value
    end,
})

MainTab:CreateSection({ Name = "Visuals / ESP" })

MainTab:CreateToggle({
    Name = "Show Pen Boundary (ESP)",
    CurrentValue = false,
    Flag = "Toggle_PenESP",
    Callback = function(Value)
        penESP.show = Value
        penESP.update()
    end,
})

MainTab:CreateToggle({
    Name = "Show Team Chest ESP (Dynamic)",
    CurrentValue = false,
    Flag = "Toggle_ChestESP",
    Callback = function(Value)
        chestESP.show = Value
        chestESP.update()
    end,
})

MainTab:CreateSection({ Name = "Virtual Input Spammer (0.05s CD)" })

MainTab:CreateToggle({
    Name = "Spam [E] Key",
    CurrentValue = false,
    Flag = "Toggle_Spam_E",
    Callback = function(Value) HandleSpam("E", Value, 0.05) end,
})

MainTab:CreateToggle({
    Name = "Spam [Q] Key",
    CurrentValue = false,
    Flag = "Toggle_Spam_Q",
    Callback = function(Value) HandleSpam("Q", Value, 0.05) end,
})

-- ==========================
-- UI SETUP: Manatite & Mithril Tab
-- ==========================
local MiningTab = Window:CreateTab({ Name = "Manatite & Mithril", Icon = 4483362458 })

MiningTab:CreateSection({ Name = "Manatite Farm (Sea Maze)" })

MiningTab:CreateToggle({
    Name = "Enable Manatite Farm (Sea Maze)",
    CurrentValue = false,
    Flag = "Toggle_ManatiteFarm",
    Callback = function(Value)
        manatite.auto = Value
        if Value then
            if root then
                manatite.preCFrame = root.CFrame
            end
            manatite.model = nil
            manatite.target = nil
            manatite.payload = nil
            manatite.lastSearchTime = 0

            Window:Notify({
                Title = "Manatite Farm Enabled",
                Content = "Teleporting to Sea Maze Manatite clusters & chomping...",
                Duration = 3,
                Image = 4483362458,
            })
        else
            if manatite.anchor and root then
                pcall(function() root.Anchored = false end)
            end
            if manatite.returnOnDisable and manatite.preCFrame and root and char then
                char:PivotTo(manatite.preCFrame)
                root.CFrame = manatite.preCFrame
                for _, part in ipairs(charBaseParts) do
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            manatite.model = nil
            manatite.target = nil
            manatite.payload = nil
        end
        updateHeartbeatConnection()
    end,
})

MiningTab:CreateToggle({
    Name = "Show Manatite ESP (Sea Maze)",
    CurrentValue = false,
    Flag = "Toggle_ManatiteESP",
    Callback = function(Value)
        manatite.showESP = Value
        manatite.updateESP()
    end,
})

MiningTab:CreateDropdown({
    Name = "Cluster Selection Order",
    Options = {"Nearest Available", "Alphabetical (A-Z)", "Largest Crystal Yield"},
    CurrentOption = {"Nearest Available"},
    MultipleOptions = false,
    Flag = "Dropdown_ManatiteOrder",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Alphabetical (A-Z)" then
            manatite.order = "Alphabetical (A-Z)"
        elseif selection == "Largest Crystal Yield" or string.find(tostring(selection), "Yield") or string.find(tostring(selection), "yield") then
            manatite.order = "Largest Crystal Yield"
        else
            manatite.order = "Nearest Available"
        end
    end,
})

MiningTab:CreateSlider({
    Name = "Manatite Chomp Delay",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "Slider_ManatiteDelay",
    Callback = function(Value)
        manatite.delay = Value
    end,
})

MiningTab:CreateSlider({
    Name = "Teleport Height Offset",
    Range = {0, 8},
    Increment = 0.5,
    Suffix = "Studs",
    CurrentValue = 2.5,
    Flag = "Slider_ManatiteHeight",
    Callback = function(Value)
        manatite.heightOffset = Value
    end,
})

MiningTab:CreateToggle({
    Name = "Anchor Root While Chomping",
    CurrentValue = false,
    Flag = "Toggle_ManatiteAnchor",
    Callback = function(Value)
        manatite.anchor = Value
        if not Value and root and not dodge.isUnderground then
            pcall(function() root.Anchored = false end)
        end
    end,
})

MiningTab:CreateToggle({
    Name = "Return to Pre-Farm Pos on Disable",
    CurrentValue = false,
    Flag = "Toggle_ManatiteReturn",
    Callback = function(Value)
        manatite.returnOnDisable = Value
    end,
})

MiningTab:CreateToggle({
    Name = "Retreat to Safe Crystal on Spider Threat",
    CurrentValue = true,
    Flag = "Toggle_RetreatSafeCrystal",
    Callback = function(Value)
        dodge.retreatOnThreat = Value
        dodge.prioritizeMobsOverManatite = not Value
    end,
})

MiningTab:CreateSection({ Name = "Mithril Farm (Crystal Geode)" })

MiningTab:CreateToggle({
    Name = "Enable Mithril Farm (Crystal Geode)",
    CurrentValue = false,
    Flag = "Toggle_MithrilFarm",
    Callback = function(Value)
        mithril.auto = Value
        if Value then
            if root then
                mithril.preCFrame = root.CFrame
            end
            mithril.model = nil
            mithril.orePart = nil
            mithril.payload = nil
            mithril.lastSearchTime = 0

            Window:Notify({
                Title = "Mithril Farm Enabled",
                Content = "Teleporting to Crystal Geode Mithril ores & chomping...",
                Duration = 3,
                Image = 4483362458,
            })
        else
            if mithril.anchor and root then
                pcall(function() root.Anchored = false end)
            end
            if mithril.returnOnDisable and mithril.preCFrame and root and char then
                char:PivotTo(mithril.preCFrame)
                root.CFrame = mithril.preCFrame
                for _, part in ipairs(charBaseParts) do
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            mithril.model = nil
            mithril.orePart = nil
            mithril.payload = nil
        end
        updateHeartbeatConnection()
    end,
})

MiningTab:CreateToggle({
    Name = "Show Mithril ESP (Crystal Geode)",
    CurrentValue = false,
    Flag = "Toggle_MithrilESP",
    Callback = function(Value)
        mithril.showESP = Value
        mithril.updateESP()
    end,
})

MiningTab:CreateDropdown({
    Name = "Mithril Selection Order",
    Options = {"Nearest Available", "Alphabetical (A-Z)"},
    CurrentOption = {"Nearest Available"},
    MultipleOptions = false,
    Flag = "Dropdown_MithrilOrder",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Alphabetical (A-Z)" then
            mithril.order = "Alphabetical (A-Z)"
        else
            mithril.order = "Nearest Available"
        end
    end,
})

MiningTab:CreateSlider({
    Name = "Mithril Chomp Delay",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "Slider_MithrilDelay",
    Callback = function(Value)
        mithril.delay = Value
    end,
})

MiningTab:CreateSlider({
    Name = "Mithril Teleport Height Offset",
    Range = {0, 8},
    Increment = 0.5,
    Suffix = "Studs",
    CurrentValue = 2.5,
    Flag = "Slider_MithrilHeight",
    Callback = function(Value)
        mithril.heightOffset = Value
    end,
})

MiningTab:CreateToggle({
    Name = "Anchor Root While Mining",
    CurrentValue = false,
    Flag = "Toggle_MithrilAnchor",
    Callback = function(Value)
        mithril.anchor = Value
        if not Value and root and not dodge.isUnderground then
            pcall(function() root.Anchored = false end)
        end
    end,
})

MiningTab:CreateToggle({
    Name = "Return to Pre-Farm Pos on Disable (Mithril)",
    CurrentValue = false,
    Flag = "Toggle_MithrilReturn",
    Callback = function(Value)
        mithril.returnOnDisable = Value
    end,
})

-- ==========================
-- UI SETUP: Scanner Tab
-- ==========================
local ScannerTab = Window:CreateTab({ Name = "Auction Scanner", Icon = 4483362458 })

ScannerTab:CreateSection({ Name = "Discord Webhook Integration" })

ScannerTab:CreateInput({
    Name = "Discord Webhook URL",
    Placeholder = WEBHOOK_URL ~= "" and "Saved webhook loaded! Paste to overwrite." or "Paste your Webhook URL here",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text:match("discord%.com/api/webhooks") then
            WEBHOOK_URL = Text
            saveWebhook(Text)
            Window:Notify({ Title = "Webhook Saved", Content = "Your Webhook URL has been saved locally.", Duration = 3 })
        else
            Window:Notify({ Title = "Invalid URL", Content = "Please enter a valid Discord webhook URL.", Duration = 3 })
        end
    end,
})

ScannerTab:CreateToggle({
    Name = "Enable Discord Webhook",
    CurrentValue = true,
    Flag = "ScannerToggle",
    Callback = function(Value)
        auction.scannerRunning = Value

        if auction.scannerRunning then
            if not httpRequest then
                Window:Notify({ Title = "Unsupported", Content = "Your executor does not support HTTP requests.", Duration = 4 })
                auction.scannerRunning = false
                return
            elseif WEBHOOK_URL == "" then
                Window:Notify({ Title = "No Webhook", Content = "Please enter a valid Discord Webhook URL first.", Duration = 4 })
                auction.scannerRunning = false
                return
            end

            for _, lotName in ipairs(auction.lotNames) do
                local lot = skinAuction:FindFirstChild(lotName)
                if lot then
                    local conn = lot:GetAttributeChangedSignal("SkinId"):Connect(function()
                        task.wait(1)
                        if auction.scannerRunning then auction.debouncedCheckLots() end
                    end)
                    table.insert(auction.connections, conn)
                end
            end

            auction.debouncedCheckLots()
        else
            for _, conn in ipairs(auction.connections) do conn:Disconnect() end
            table.clear(auction.connections)
        end
    end,
})

-- ==========================
-- LIVE AUCTION HOUSE DISPLAY
-- ==========================
ScannerTab:CreateSection({ Name = "Live Auction House Display" })

function auction.getLocalDisplayName()
    return tostring(plr:GetAttribute("DisplayName") or plr.DisplayName or plr.Name)
end

function auction.formatRemainingTime(endsAt)
    if not endsAt or type(endsAt) ~= "number" then return "N/A" end
    local remaining = math.max(0, endsAt - os.time())
    if remaining <= 0 then
        return "Ended / Rotating"
    end
    local minutes = math.floor(remaining / 60)
    local seconds = remaining % 60
    return string.format("%dm %02ds", minutes, seconds)
end


function auction.getLotDisplayInfo(lotName)
    local lot = skinAuction:FindFirstChild(lotName)
    if not lot then
        return lotName .. ": [Not Found]", "Lot folder does not exist in ReplicatedStorage."
    end

    local skinName = lot:GetAttribute("SkinName")
    local skinId = lot:GetAttribute("SkinId")
    if not skinId or skinId == "" or skinId == "None" then
        return lotName .. ": [Empty / Inactive]", "No skin currently on auction in this lot."
    end

    local rarity = lot:GetAttribute("Rarity") or "Common"
    local bid = lot:GetAttribute("Bid")
    local minBid = lot:GetAttribute("MinimumBid")
    local round = lot:GetAttribute("Round") or "N/A"
    local endsAt = lot:GetAttribute("EndsAt")
    local leaderName = lot:GetAttribute("LeaderName")

    local myDisplayName = auction.getLocalDisplayName()
    local myUsername = plr.Name

    local leaderStatus
    if not leaderName or leaderName == "" or leaderName == "None" then
        leaderStatus = "None (No bids yet)"
    elseif leaderName == myDisplayName or leaderName == myUsername or leaderName == plr.DisplayName then
        leaderStatus = "⭐ YOU (" .. tostring(leaderName) .. ") - Leading"
    else
        leaderStatus = "👤 " .. tostring(leaderName) .. " (Outbid)"
    end

    local title = string.format("%s: %s [%s]", lotName, tostring(skinName or skinId), tostring(rarity))
    local body = string.format("Current Bid: 🪙 %s | Next Min: 🪙 %s\nLeader: %s\nRound: %s | Ends In: %s",
        formatNumber(bid),
        formatNumber(minBid),
        leaderStatus,
        tostring(round),
        auction.formatRemainingTime(endsAt)
    )

    return title, body
end

function auction.updateLotDisplay(lotName)
    local card = auction.cards[lotName]
    if not card then return end
    local title, body = auction.getLotDisplayInfo(lotName)
    pcall(function()
        if card.SetTitle then
            card:SetTitle(title)
            card:Set(body)
        elseif card.Set then
            card:Set({ Title = title, Content = body })
        end
    end)
end

function auction.updateAllLotDisplays()
    for _, lotName in ipairs(auction.lotNames) do
        auction.updateLotDisplay(lotName)
    end
end

-- Create live cards for each lot in Rayfield Gen2
for _, lotName in ipairs(auction.lotNames) do
    local initialTitle, initialBody = auction.getLotDisplayInfo(lotName)
    local card = nil
    if ScannerTab.CreateText then
        pcall(function()
            card = ScannerTab:CreateText({
                name = initialTitle,
                text = initialBody
            })
        end)
    end
    if not card and ScannerTab.CreateParagraph then
        pcall(function()
            card = ScannerTab:CreateParagraph({
                Title = initialTitle,
                Content = initialBody
            })
        end)
    end
    auction.cards[lotName] = card
end

ScannerTab:CreateButton({
    Name = "Refresh Auction Display",
    Callback = function()
        auction.updateAllLotDisplays()
        Window:Notify({ Title = "Refreshed", Content = "Auction lot displays updated.", Duration = 2 })
    end,
})

ScannerTab:CreateSection({ Name = "Auction House Tools" })

-- Show Current Auction Skins button
ScannerTab:CreateButton({
    Name = "Show Current Auction Skins",
    Callback = function()
        local lines = {}
        for _, lotName in ipairs(auction.lotNames) do
            local lot = skinAuction:FindFirstChild(lotName)
            if lot then
                local skinName = lot:GetAttribute("SkinName")
                local skinId = lot:GetAttribute("SkinId")
                if skinName and skinName ~= "" and skinId and skinId ~= "" then
                    local rarity = lot:GetAttribute("Rarity") or "?"
                    local bid = lot:GetAttribute("Bid")
                    local minBid = lot:GetAttribute("MinimumBid")
                    local leader = lot:GetAttribute("LeaderName") or "None"
                    table.insert(lines,
                        lotName .. ": " .. tostring(skinName)
                        .. " [" .. tostring(rarity) .. "]"
                        .. " | Leader: " .. tostring(leader)
                        .. " | Min: " .. formatNumber(minBid)
                    )
                else
                    table.insert(lines, lotName .. ": Empty")
                end
            else
                table.insert(lines, lotName .. ": Not Found")
            end
        end
        Window:Notify({
            Title = "Current Auction Lots",
            Content = table.concat(lines, "\n"),
            Duration = 10
        })
    end,
})

-- Single Open Auction House Proximity Prompt Button
ScannerTab:CreateButton({
    Name = "Open Auction House",
    Callback = function()
        local prompt = nil
        pcall(function()
            prompt = workspace.CowWorld.Decorations.SkinAuctionHall.Lot1.Pedestal.CowAuctionBid
        end)

        if not prompt then
            pcall(function()
                local pedestal = workspace:FindFirstChild("CowWorld")
                    and workspace.CowWorld:FindFirstChild("Decorations")
                    and workspace.CowWorld.Decorations:FindFirstChild("SkinAuctionHall")
                    and workspace.CowWorld.Decorations.SkinAuctionHall:FindFirstChild("Lot1")
                    and workspace.CowWorld.Decorations.SkinAuctionHall.Lot1:FindFirstChild("Pedestal")
                if pedestal then
                    prompt = pedestal:FindFirstChild("CowAuctionBid")
                        or pedestal:FindFirstChildWhichIsA("ProximityPrompt", true)
                end
            end)
        end

        if not prompt then
            pcall(function()
                local hall = workspace:FindFirstChild("CowWorld")
                    and workspace.CowWorld:FindFirstChild("Decorations")
                    and workspace.CowWorld.Decorations:FindFirstChild("SkinAuctionHall")
                if hall then
                    prompt = hall:FindFirstChild("CowAuctionBid", true)
                        or hall:FindFirstChildWhichIsA("ProximityPrompt", true)
                end
            end)
        end

        if not prompt then
            Window:Notify({ Title = "Error", Content = "Auction House proximity prompt (CowAuctionBid) not found.", Duration = 4 })
            return
        end

        local fired = false
        if fireproximityprompt then
            pcall(function()
                fireproximityprompt(prompt)
                fired = true
            end)
        end

        if not fired then
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.05)
                prompt:InputHoldEnd()
                fired = true
            end)
        end

        if fired then
            Window:Notify({ Title = "Prompt Fired", Content = "Auction House prompt opened.", Duration = 3 })
        else
            Window:Notify({ Title = "Error", Content = "Failed to fire auction prompt.", Duration = 4 })
        end
    end,
})

-- Manual Bid Buttons

function auction.executeBid(lotName, isManual)
    if not auction.remote then
        auction.remote = cowRemotes:FindFirstChild("SkinAuctionRequest")
        if not auction.remote then
            if isManual then
                Window:Notify({ Title = "Error", Content = "SkinAuctionRequest remote not found.", Duration = 4 })
            end
            return false
        end
    end

    local lot = skinAuction:FindFirstChild(lotName)
    if not lot then
        if isManual then
            Window:Notify({ Title = "Error", Content = lotName .. " not found in SkinAuction.", Duration = 4 })
        end
        return false
    end

    local skinId = lot:GetAttribute("SkinId")
    if not skinId or skinId == "" or skinId == "None" then
        if isManual then
            Window:Notify({ Title = "Error", Content = lotName .. " has no active skin.", Duration = 4 })
        end
        return false
    end

    local round = lot:GetAttribute("Round")
    local slot = lot:GetAttribute("Slot") or tonumber(lotName:match("%d+")) or 1
    local minBid = lot:GetAttribute("MinimumBid")

    if not round or not minBid or type(minBid) ~= "number" or minBid <= 0 then
        if isManual then
            Window:Notify({ Title = "Error", Content = lotName .. " missing valid Round/MinimumBid.", Duration = 4 })
        end
        return false
    end

    local success, result = pcall(function()
        return auction.remote:InvokeServer({
            Slot = slot,
            Round = round,
            Action = "Bid",
            Amount = minBid
        })
    end)

    if success then
        local skinName = lot:GetAttribute("SkinName") or skinId
        Window:Notify({
            Title = isManual and "Manual Bid Placed" or "Auto Bid Placed!",
            Content = lotName .. " (" .. tostring(skinName) .. ") | Amount: " .. formatNumber(minBid),
            Duration = 4
        })
        task.spawn(function()
            task.wait(0.5)
            auction.updateLotDisplay(lotName)
        end)
        return true
    else
        if isManual then
            Window:Notify({
                Title = "Bid Failed",
                Content = lotName .. ": " .. tostring(result),
                Duration = 4
            })
        end
        return false
    end
end

ScannerTab:CreateSection({ Name = "Manual Bidding" })

for _, lotName in ipairs(auction.lotNames) do
    ScannerTab:CreateButton({
        Name = "Bid " .. lotName,
        Callback = function()
            auction.executeBid(lotName, true)
        end,
    })
end

-- ==========================
-- AUTO OUTBID SYSTEM
-- ==========================

function auction.checkAndAutoBidLot(lotName)
    if not (auction.autoBidAll or auction.autoBidActive[lotName]) then return end
    if not auction.remote then
        auction.remote = cowRemotes:FindFirstChild("SkinAuctionRequest")
        if not auction.remote then return end
    end

    local lot = skinAuction:FindFirstChild(lotName)
    if not lot then return end

    local skinId = lot:GetAttribute("SkinId")
    if not skinId or skinId == "" or skinId == "None" then return end

    local round = lot:GetAttribute("Round")
    local slot = lot:GetAttribute("Slot") or tonumber(lotName:match("%d+")) or 1
    local minBid = lot:GetAttribute("MinimumBid")
    if not round or not minBid or type(minBid) ~= "number" or minBid <= 0 then return end

    if auction.maxAutoBidLimit > 0 and minBid > auction.maxAutoBidLimit then
        return
    end

    local leaderName = lot:GetAttribute("LeaderName")
    local myDisplayName = auction.getLocalDisplayName()
    local myUsername = plr.Name

    -- Check if we are already leading
    if leaderName and (leaderName == myDisplayName or leaderName == myUsername or leaderName == plr.DisplayName) then
        return
    end

    -- Throttle to avoid duplicate rapid requests
    local now = os.clock()
    if auction.isAutoBiddingLot[lotName] then return end
    if auction.lastAutoBidTime[lotName] and (now - auction.lastAutoBidTime[lotName] < 1.5) then return end

    auction.isAutoBiddingLot[lotName] = true
    auction.lastAutoBidTime[lotName] = now

    task.spawn(function()
        local success, result = pcall(function()
            return auction.remote:InvokeServer({
                Slot = slot,
                Round = round,
                Action = "Bid",
                Amount = minBid
            })
        end)

        auction.isAutoBiddingLot[lotName] = false

        if success then
            local skinName = lot:GetAttribute("SkinName") or skinId
            Window:Notify({
                Title = "Auto Outbid Placed!",
                Content = lotName .. " (" .. tostring(skinName) .. ")\nAmount: " .. formatNumber(minBid) .. "\nOutbidding: " .. tostring(leaderName or "None"),
                Duration = 4
            })
            task.spawn(function()
                task.wait(0.5)
                auction.updateLotDisplay(lotName)
            end)
        end
    end)
end

-- Hook attribute changes for instant reaction & live display updates
for _, lotName in ipairs(auction.lotNames) do
    local lot = skinAuction:FindFirstChild(lotName)
    if lot then
        local function onLotAttributeChanged()
            auction.updateLotDisplay(lotName)
            if auction.autoBidAll or auction.autoBidActive[lotName] then
                auction.checkAndAutoBidLot(lotName)
            end
        end

        local c1 = lot:GetAttributeChangedSignal("LeaderName"):Connect(onLotAttributeChanged)
        local c2 = lot:GetAttributeChangedSignal("MinimumBid"):Connect(onLotAttributeChanged)
        local c3 = lot:GetAttributeChangedSignal("Bid"):Connect(function() auction.updateLotDisplay(lotName) end)
        local c4 = lot:GetAttributeChangedSignal("Round"):Connect(onLotAttributeChanged)
        local c5 = lot:GetAttributeChangedSignal("SkinId"):Connect(onLotAttributeChanged)
        local c6 = lot:GetAttributeChangedSignal("SkinName"):Connect(function() auction.updateLotDisplay(lotName) end)
        local c7 = lot:GetAttributeChangedSignal("EndsAt"):Connect(function() auction.updateLotDisplay(lotName) end)

        table.insert(auction.autoBidConnections, c1)
        table.insert(auction.autoBidConnections, c2)
        table.insert(auction.autoBidConnections, c3)
        table.insert(auction.autoBidConnections, c4)
        table.insert(auction.autoBidConnections, c5)
        table.insert(auction.autoBidConnections, c6)
        table.insert(auction.autoBidConnections, c7)
    end
end

-- 1-second live countdown ticker and periodic outbid check
task.spawn(function()
    while auction.autoBidLoopRunning do
        task.wait(1)
        auction.updateAllLotDisplays()
        if auction.autoBidAll or auction.autoBidActive.Lot1 or auction.autoBidActive.Lot2 or auction.autoBidActive.Lot3 or auction.autoBidActive.Lot4 then
            for _, lotName in ipairs(auction.lotNames) do
                if auction.autoBidAll or auction.autoBidActive[lotName] then
                    auction.checkAndAutoBidLot(lotName)
                end
            end
        end
    end
end)

ScannerTab:CreateSection({ Name = "Auto Outbid (When Not Leading)" })

ScannerTab:CreateToggle({
    Name = "Auto Outbid All Lots",
    CurrentValue = false,
    Flag = "Toggle_AutoBidAll",
    Callback = function(Value)
        auction.autoBidAll = Value
        if Value then
            for _, lotName in ipairs(auction.lotNames) do
                task.spawn(function() auction.checkAndAutoBidLot(lotName) end)
            end
        end
    end,
})

for _, lotName in ipairs(auction.lotNames) do
    ScannerTab:CreateToggle({
        Name = "Auto Outbid " .. lotName,
        CurrentValue = false,
        Flag = "Toggle_AutoBid_" .. lotName,
        Callback = function(Value)
            auction.autoBidActive[lotName] = Value
            if Value then
                task.spawn(function() auction.checkAndAutoBidLot(lotName) end)
            end
        end,
    })
end

ScannerTab:CreateInput({
    Name = "Max Auto Bid Limit (0 = Unlimited)",
    Placeholder = "Enter max coins (e.g. 5000000)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text:gsub(",", ""):gsub("%$", ""))
        if num and num >= 0 then
            auction.maxAutoBidLimit = num
            Window:Notify({
                Title = "Limit Updated",
                Content = num == 0 and "Max bid limit set to Unlimited." or ("Max bid limit set to: " .. formatNumber(num)),
                Duration = 3
            })
        else
            Window:Notify({ Title = "Invalid Number", Content = "Please enter a valid number.", Duration = 3 })
        end
    end,
})

-- ==========================
-- UI SETUP: Settings Tab
-- ==========================
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = 4483362458 })

SettingsTab:CreateSection({ Name = "Performance" })

SettingsTab:CreateToggle({
    Name = "Disable 3D Rendering",
    CurrentValue = false,
    Flag = "Toggle_3DRender",
    Callback = function(Value)
        pcall(function()
            RunService:Set3dRenderingEnabled(not Value)
        end)
    end,
})

SettingsTab:CreateToggle({
    Name = "Enable FPS Cap",
    CurrentValue = false,
    Flag = "Toggle_FPSCap",
    Callback = function(Value)
        fps.capEnabled = Value
        if setfpscap then pcall(function() setfpscap(fps.capEnabled and fps.currentCap or 60) end) end
    end,
})

SettingsTab:CreateSlider({
    Name = "FPS Cap Limit",
    Range = {15, 60},
    Increment = 1,
    Suffix = "FPS",
    CurrentValue = 60,
    Flag = "Slider_FPSCap",
    Callback = function(Value)
        fps.currentCap = Value
        if fps.capEnabled and setfpscap then pcall(function() setfpscap(fps.currentCap) end) end
    end,
})

SettingsTab:CreateSection({ Name = "Script Controls" })

SettingsTab:CreateButton({
    Name = "Close Script & Destroy UI",
    Callback = function()
        if auction.scannerRunning and httpRequest and WEBHOOK_URL ~= "" then
            task.spawn(function()
                httpRequest({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({["embeds"] = {{
                        ["title"] = "🛑 Scanner Offline",
                        ["description"] = "The script has been closed and the auction scanner is no longer active.",
                        ["color"] = 0xFF0000,
                        ["footer"] = {["text"] = "Auction Scanner • " .. os.date("%X")}
                    }}})
                })
            end)
        end

        farm.on = false
        farm.autoChomp = false
        farm.autoChompMobs = false
        farm.autoFish = false
        cache.cleanupRippleTracking()
        dodge.auto = false
        if manatite then
            manatite.auto = false
            manatite.showESP = false
            manatite.cleanupVisuals()
            if manatite.anchor and root then
                pcall(function() root.Anchored = false end)
            end
            manatite.model = nil
            manatite.target = nil
            manatite.payload = nil
        end
        if mithril then
            mithril.auto = false
            mithril.showESP = false
            mithril.cleanupVisuals()
            if mithril.anchor and root then
                pcall(function() root.Anchored = false end)
            end
            mithril.model = nil
            mithril.orePart = nil
            mithril.payload = nil
        end
        if aerial.active and root then
            aerial.active = false
            root.Anchored = false
            if aerial.preCFrame then
                pcall(function() char:PivotTo(aerial.preCFrame) end)
                pcall(function() root.CFrame = aerial.preCFrame end)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            aerial.cframe = nil
            aerial.preCFrame = nil
        end
        if dodge.isUnderground and root and dodge.lastSurfaceCFrame then
            root.CFrame = dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            dodge.isUnderground = false
            dodge.currentUndergroundRetreatOffset = nil
        end
        if dodge.isDodging then
            if humanoid then humanoid.WalkSpeed = dodge.originalWalkSpeed or 16 end
            dodge.isDodging = false
            dodge.currentAttackingMob = nil
        end
        auction.scannerRunning = false
        penESP.show = false
        chestESP.show = false
        penESP.update()
        chestESP.update()

        table.clear(cache.activeAuraMobs)
        table.clear(cache.mithrilCaveMobSet)
        pcall(function()
            if successVIM and VirtualInput then
                VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            elseif keyrelease then
                keyrelease(0x45)
            elseif VirtualUser then
                VirtualUser:SetKeyUp("0x65")
            end
        end)

        spamThreads.E = spamThreads.E + 1
        spamThreads.Q = spamThreads.Q + 1

        for _, conn in ipairs(auction.connections) do conn:Disconnect() end
        table.clear(auction.connections)

        auction.autoBidLoopRunning = false
        for _, conn in ipairs(auction.autoBidConnections) do conn:Disconnect() end
        table.clear(auction.autoBidConnections)
        table.clear(auction.cards)

        for _, conn in ipairs(scriptConnections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        table.clear(scriptConnections)

        pcall(function() RunService:Set3dRenderingEnabled(true) end)
        if setfpscap then pcall(function() setfpscap(60) end) end

        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
            HeartbeatConnection = nil
        end
        pcall(function() if humanoid then humanoid:Move(Vector3.zero, false) end end)

        Window:Unload()
    end,
})
