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
    if humanoid then originalWalkSpeed = humanoid.WalkSpeed end
    raycastParams.FilterDescendantsInstances = {char}
    updateCharBaseParts(newChar)
    isDodging = false
    isUnderground = false
    lastRecordedHearts = nil
    currentAttackingMob = nil
    preDodgePos = nil
    preDodgeCFrame = nil
    lastSurfaceCFrame = nil
    lastSurfacePos = nil
    undergroundCFrame = nil
    currentUndergroundRetreatOffset = nil
    isAerialRetreat = false
    aerialRetreatCFrame = nil
    preAerialCFrame = nil
    aerialRetreatStartTime = 0
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
-- STATE VARIABLES
-- ==========================
-- Farming Variables
local farmOn = false
local autoChomp = false
local autoChompMobs = false
local autoFish = false
local anchorPos = nil
local pattern = "Guided Zigzag (Nodes)"
local patternSpeed = 1.0
local patternTimer = 0
local nextRandomPos = nil
local farmRadius = 75
local farmRadiusSq = farmRadius * farmRadius
local MOB_AURA_RADIUS_SQ = 100 -- Hardcoded 10 studs squared (10 * 10) - server-enforced attack reach
local mobAuraDelay = 0.1
local lastMoveTime = 0
local HeartbeatConnection = nil

-- Manatite Farm & ESP State Table
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
local nodeBlacklist = setmetatable({}, { __mode = "k" })
local lastBlacklistCleanup = 0
local currentTargetNode = nil
local nodeCleanNameCache = {}
local mobPayloadCache = {}

-- Chomp & Aura Cooldowns
local lastChompedNode = ""
local chompCooldown = 0
local lastRaycastChompTime = 0
local lastChompedMob = ""
local mobChompCooldown = 0

-- Background Caching & Auto-Fishing Variables
local castCooldown = 0
local lastFishingSearchTime = 0
local activeRipples = setmetatable({}, { __mode = "k" })
local rippleConnections = {}
local ripplePosCache = setmetatable({}, { __mode = "kv" })
local activeAuraMobs = {}
local mithrilCaveMobSet = setmetatable({}, { __mode = "k" })
local spiderIdentifierCache = setmetatable({}, { __mode = "k" })
local isEPressed = false
local lastBackgroundCacheTime = 0
local isCachingBackground = false
local lastSanitationTime = 0

-- Mob Attack Dodge Variables (Run Away & Surface Retreat)
local autoDodgeMobs = false
local dodgeMethod = "Underground" -- "Underground", "Run Away (Surface)", "Teleport Away (Surface)"
local isDodging = false
local isUnderground = false
local currentAttackingMob = nil
local preDodgePos = nil
local preDodgeCFrame = nil
local lastSurfaceCFrame = nil
local lastSurfacePos = nil
local undergroundCFrame = nil
local undergroundDepth = 20
local currentUndergroundRetreatOffset = nil
local dodgeRetreatDistance = 25 -- Horizontal distance to retreat away from attacking mob
local dodgeRetreatAngle = 45 -- Angle in degrees to offset retreat vector away from mob
local dodgeWalkSpeed = 26 -- Sprint speed when running away from attack
local originalWalkSpeed = humanoid and humanoid.WalkSpeed or 16
local dodgeDetectionRadius = 15
local dodgeDetectionRadiusSq = 15 * 15
local dodgeLingerDelay = 0.6
local prioritizeMobsOverManatite = true
local MANATITE_THREAT_RADIUS_SQ = 100 -- 10 studs squared (10 * 10) matching server attack reach
local lastWarningSeenTime = 0
local lastTeleportDodgeDist = 0
local notifyOnDodge = false
local dodgeOnHeartsDecreased = true
local lastRecordedHearts = nil
local normalPlayerHearts = 0
local lastRecordedArmor = nil
local normalPlayerArmor = 0
local lastDamageRetreatTime = 0
local threatStartTime = 0
local dodgeStartTime = 0

-- Aerial Retreat Variables (Low-Health Emergency Retreat)
local isAerialRetreat = false
local aerialRetreatStartTime = 0
local aerialRetreatDuration = 60   -- seconds to hover before returning
local aerialRetreatHeight = 200    -- studs above current position
local aerialRetreatCFrame = nil    -- position locked while hovering
local preAerialCFrame = nil        -- original position to return to
local aerialRetreatCooldown = 10   -- minimum seconds between aerial retreats
local lastAerialRetreatTime = 0

-- Spammer Variables
local spamThreads = {E = 0, Q = 0}

-- Scanner & File System Variables
local lotNames = {"Lot1", "Lot2", "Lot3", "Lot4"}
local httpRequest = (request or http_request or (http and http.request) or (syn and syn.request))
local previousAuctionSignatures = {}
local scannerRunning = false
local auctionConnections = {}
local isCheckingAuction = false

-- FPS Variables
local fpsCapEnabled = false
local currentFpsCap = 60

local rarityColors = {
    ["Common"] = 0xB0BEC5,
    ["Uncommon"] = 0x66BB6A,
    ["Rare"] = 0x42A5F5,
    ["Super Rare"] = 0xAB47BC,
    ["Mythic"] = 0xFF5252,
    ["Unique"] = 0xFFD700,
    ["Unrated"] = 0xFFFFFF,
    ["Default"] = 0x5865F2
}

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
local nodePositionCache = setmetatable({}, { __mode = "k" })
local mobAttackOriginPartCache = setmetatable({}, { __mode = "kv" })
local mobHumanoidCache = setmetatable({}, { __mode = "kv" })
local mobWarningCache = setmetatable({}, { __mode = "kv" })
local mobWarningCheckTime = setmetatable({}, { __mode = "kv" })
local fishingSpotPosCache = setmetatable({}, { __mode = "k" })

local cachedGrassFolder = workspace:FindFirstChild("CowVirtualGrass")
local cachedGrassNodes = {}
local lastGrassCacheTime = 0

local cachedFishingSpots = {}
local lastFishingSpotsCacheTime = 0

local cowWorldRef = workspace:FindFirstChild("CowWorld")
local function getResourcesFolder()
    if not cowWorldRef or not cowWorldRef.Parent then
        cowWorldRef = workspace:FindFirstChild("CowWorld")
    end
    local rafting = cowWorldRef and cowWorldRef:FindFirstChild("FjordRafting")
    return rafting and rafting:FindFirstChild("Resources")
end

local function getNodePosition(node)
    local pos = nodePositionCache[node]
    if pos then return pos end
    pos = node:IsA("Model") and node:GetPivot().Position or node.Position
    nodePositionCache[node] = pos
    return pos
end

local function getGrassNodes()
    local now = os.clock()
    if not cachedGrassFolder or not cachedGrassFolder.Parent then
        cachedGrassFolder = workspace:FindFirstChild("CowVirtualGrass")
    end
    if cachedGrassFolder and (now - lastGrassCacheTime > 4 or #cachedGrassNodes == 0) then
        lastGrassCacheTime = now
        cachedGrassNodes = cachedGrassFolder:GetChildren()
    end
    return cachedGrassNodes
end

local function getFishingSpotsFolder()
    if fishingSpotsFolder and fishingSpotsFolder.Parent then return fishingSpotsFolder end
    fishingSpotsFolder = workspace:FindFirstChild("Fishing Spots") or workspace:FindFirstChild("FishingSpots")
    if not fishingSpotsFolder and cowWorldRef and cowWorldRef.Parent then
        fishingSpotsFolder = cowWorldRef:FindFirstChild("Fishing Spots", true) or cowWorldRef:FindFirstChild("FishingSpots", true)
    end
    return fishingSpotsFolder
end

local function getFishingSpots()
    local now = os.clock()
    if now - lastFishingSpotsCacheTime > 5 or #cachedFishingSpots == 0 then
        lastFishingSpotsCacheTime = now
        local folder = getFishingSpotsFolder()
        if folder then
            table.clear(cachedFishingSpots)
            for _, spot in ipairs(folder:GetChildren()) do
                if (spot:IsA("BasePart") or spot:IsA("Model")) and spot.Parent then
                    table.insert(cachedFishingSpots, spot)
                end
            end
        end
    end
    return cachedFishingSpots
end

local function getSpotPosition(spot)
    if not spot or not spot.Parent then
        fishingSpotPosCache[spot] = nil
        return nil
    end
    local pos = fishingSpotPosCache[spot]
    if pos then return pos end
    pos = spot:IsA("Model") and spot:GetPivot().Position or (spot:IsA("BasePart") and spot.Position)
    if pos then
        fishingSpotPosCache[spot] = pos
    end
    return pos
end

local function getCleanGrassName(nodeName)
    local cached = nodeCleanNameCache[nodeName]
    if cached ~= nil then return cached end

    local cleanName = string.gsub(nodeName, "GrassVisual", "")
    cleanName = string.gsub(cleanName, "^_+", "")
    cleanName = string.gsub(cleanName, "_+$", "")

    if string.match(cleanName, ".*Grass.*_[np%-]?%d+_[np%-]?%d+$") then
        nodeCleanNameCache[nodeName] = cleanName
        return cleanName
    else
        nodeCleanNameCache[nodeName] = false
        return false
    end
end

local function getMobPayload(mobName)
    local cached = mobPayloadCache[mobName]
    if cached then return cached end

    local formattedMobName = string.gsub(mobName, "(%a+)(%d+)", "%1_%2")
    if string.find(mobName, "Spider", 1, true) then
        cached = "Cavern_Mob_" .. formattedMobName
    else
        cached = "Fjord_Mob_" .. formattedMobName
    end
    mobPayloadCache[mobName] = cached
    return cached
end

local function cleanupNodeBlacklist(now)
    if now - lastBlacklistCleanup > 15 then
        lastBlacklistCleanup = now
        for node, timestamp in pairs(nodeBlacklist) do
            if not node or not node.Parent or (now - timestamp > 10) then
                nodeBlacklist[node] = nil
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
    if not fjord and cowWorldRef and cowWorldRef.Parent then
        fjord = cowWorldRef:FindFirstChild("FjordDelta")
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

function manatite.findNext(searchOrigin)
    local models = manatite.getModels()
    if not models or #models == 0 then return nil, nil end

    local now = os.clock()
    local origin = searchOrigin or (root and root.Position) or Vector3.zero

    if manatite.order == "Alphabetical (A-Z)" then
        local availableList = {}
        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = manatite.blacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local target = manatite.getGrazeTarget(model)
                    if target and manatite.isAvailable(target, model) then
                        table.insert(availableList, {model = model, target = target})
                    end
                end
            end
        end
        if #availableList > 0 then
            table.sort(availableList, function(a, b) return a.model.Name < b.model.Name end)
            return availableList[1].model, availableList[1].target
        end
        return nil, nil
    elseif manatite.order == "Largest Crystal Yield" then
        local availableList = {}
        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = manatite.blacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local target = manatite.getGrazeTarget(model)
                    if target and manatite.isAvailable(target, model) then
                        local yieldVal = manatite.getGrazeTargetYield(target, model)
                        local distSq = get3DDistanceSq(origin, target.Position)
                        table.insert(availableList, {
                            model = model,
                            target = target,
                            yield = yieldVal,
                            distSq = distSq
                        })
                    end
                end
            end
        end
        if #availableList > 0 then
            table.sort(availableList, function(a, b)
                if a.yield ~= b.yield then
                    return a.yield > b.yield
                end
                if a.distSq ~= b.distSq then
                    return a.distSq < b.distSq
                end
                return a.model.Name < b.model.Name
            end)
            return availableList[1].model, availableList[1].target
        end
        return nil, nil
    else
        local bestModel = nil
        local bestTarget = nil
        local shortestDistSq = math.huge

        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = manatite.blacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local target = manatite.getGrazeTarget(model)
                    if target and manatite.isAvailable(target, model) then
                        local distSq = get3DDistanceSq(origin, target.Position)
                        if distSq < shortestDistSq then
                            shortestDistSq = distSq
                            bestModel = model
                            bestTarget = target
                        end
                    end
                end
            end
        end

        return bestModel, bestTarget
    end
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
    local cowWorld = cowWorldRef
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

function mithril.findNext(searchOrigin)
    local models = mithril.getModels()
    if not models or #models == 0 then return nil, nil end

    local now = os.clock()
    local origin = searchOrigin or (root and root.Position) or Vector3.zero

    if mithril.order == "Alphabetical (A-Z)" then
        local availableList = {}
        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = mithril.blacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local orePart = mithril.getOrePart(model)
                    if orePart and mithril.isAvailable(orePart, model) then
                        table.insert(availableList, {model = model, target = orePart})
                    end
                end
            end
        end
        if #availableList > 0 then
            table.sort(availableList, function(a, b) return a.model.Name < b.model.Name end)
            return availableList[1].model, availableList[1].target
        end
        return nil, nil
    else
        local bestModel = nil
        local bestTarget = nil
        local shortestDistSq = math.huge

        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = mithril.blacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local orePart = mithril.getOrePart(model)
                    if orePart and mithril.isAvailable(orePart, model) then
                        local distSq = get3DDistanceSq(origin, orePart.Position)
                        if distSq < shortestDistSq then
                            shortestDistSq = distSq
                            bestModel = model
                            bestTarget = orePart
                        end
                    end
                end
            end
        end

        return bestModel, bestTarget
    end
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
local function getMobAttackOriginPart(mob)
    if not mob or not mob.Parent then
        mobAttackOriginPartCache[mob] = nil
        return nil
    end
    local cached = mobAttackOriginPartCache[mob]
    if cached and cached.Parent and cached:IsDescendantOf(mob) then
        return cached
    end

    local head = mob:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        mobAttackOriginPartCache[mob] = head
        return head
    end

    local visual = mob:FindFirstChild("CavernBodyVisual")
    if visual then
        if visual:IsA("BasePart") then
            mobAttackOriginPartCache[mob] = visual
            return visual
        elseif visual:IsA("Model") then
            local primary = visual.PrimaryPart or visual:FindFirstChildWhichIsA("BasePart")
            if primary then
                mobAttackOriginPartCache[mob] = primary
                return primary
            end
        end
    end

    if mob:IsA("BasePart") then
        mobAttackOriginPartCache[mob] = mob
        return mob
    elseif mob:IsA("Model") then
        local primary = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
        if primary then
            mobAttackOriginPartCache[mob] = primary
            return primary
        end
    end

    return nil
end

local function getMobAttackOrigin(mob)
    local part = getMobAttackOriginPart(mob)
    if part then
        return part.Position
    end
    if mob:IsA("Model") then
        return mob:GetPivot().Position
    end
    return mob.Position
end

-- Checks if there is an unobstructed line of sight (no walls, terrain, or solid geometry) between origin and mob
local function hasLineOfSight(origin, mobPos, mob)
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
local function isMobAlive(mob)
    if not mob or not mob.Parent then
        mobHumanoidCache[mob] = nil
        return false
    end

    -- Check Humanoid health if mob is rigged with a humanoid
    local hum = mobHumanoidCache[mob]
    if hum == nil then
        hum = mob:FindFirstChildWhichIsA("Humanoid") or false
        mobHumanoidCache[mob] = hum
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
    local checkPart = getMobAttackOriginPart(mob)
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
local function findAttackWarning(mob)
    if not mob or not mob.Parent then
        mobWarningCache[mob] = nil
        mobWarningCheckTime[mob] = nil
        return nil
    end

    local cached = mobWarningCache[mob]
    if cached then
        if cached.Parent and cached:IsDescendantOf(mob) then
            return cached
        else
            mobWarningCache[mob] = nil
        end
    end

    local now = os.clock()
    local lastCheck = mobWarningCheckTime[mob]
    if lastCheck and (now - lastCheck < 0.5) then
        return nil
    end
    mobWarningCheckTime[mob] = now

    -- Fast path for snakes: Head.CavernAttackWarning
    local head = mob:FindFirstChild("Head")
    if head then
        local w = head:FindFirstChild("CavernAttackWarning")
        if w then
            mobWarningCache[mob] = w
            return w
        end
    end

    -- Fast path for spiders: CavernBodyVisual.CavernAttackWarning
    local visual = mob:FindFirstChild("CavernBodyVisual")
    if visual then
        local w = visual:FindFirstChild("CavernAttackWarning")
        if w then
            mobWarningCache[mob] = w
            return w
        end
    end

    -- Direct child check strictly for CavernAttackWarning
    local direct = mob:FindFirstChild("CavernAttackWarning")
    if direct then
        mobWarningCache[mob] = direct
        return direct
    end

    -- Recursive search strictly for CavernAttackWarning
    local recursive = mob:FindFirstChild("CavernAttackWarning", true)
    if recursive then
        mobWarningCache[mob] = recursive
        return recursive
    end

    return nil
end

-- Checks if CavernAttackWarning (BillboardGui) is actively enabled via its "Enabled" attribute
local function isWarningActive(warning, mob)
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
local function getLocalPlayerHearts()
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
local function getLocalPlayerMaxHearts()
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
local function getLocalPlayerArmor()
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
local function getLocalPlayerMaxArmor()
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
local function findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)
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
    if isEPressed then return end
    isEPressed = true
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
        isEPressed = false
    end)
end

-- Checks for an identifier number on Mithril cave spiders if present (e.g. 200809)
local function findSpiderIdentifier(mob)
    if not mob then return nil end
    local cached = spiderIdentifierCache[mob]
    if cached ~= nil then return cached or nil end

    for _, attr in ipairs({"Id", "ID", "Identifier", "MobId", "SpiderId", "Index", "Number", "SpawnId", "NetworkId", "ServerId", "TargetId", "UID", "UUID", "EntityId"}) do
        local val = mob:GetAttribute(attr)
        if val ~= nil and tostring(val) ~= "" then
            local str = tostring(val)
            spiderIdentifierCache[mob] = str
            return str
        end
    end

    for attrName, attrVal in pairs(mob:GetAttributes()) do
        if typeof(attrVal) == "number" or (typeof(attrVal) == "string" and string.match(attrVal, "^%d%d%d+$")) then
            local str = tostring(attrVal)
            spiderIdentifierCache[mob] = str
            return str
        end
    end

    for _, child in ipairs(mob:GetChildren()) do
        if child:IsA("ValueBase") then
            local val = child.Value
            if val and tostring(val) ~= "" then
                local str = tostring(val)
                spiderIdentifierCache[mob] = str
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
                spiderIdentifierCache[mob] = str
                return str
            end
        end
        for attrName, attrVal in pairs(visual:GetAttributes()) do
            if typeof(attrVal) == "number" or (typeof(attrVal) == "string" and string.match(attrVal, "^%d%d%d+$")) then
                local str = tostring(attrVal)
                spiderIdentifierCache[mob] = str
                return str
            end
        end
    end

    pcall(function()
        local CollectionService = game:GetService("CollectionService")
        for _, tag in ipairs(CollectionService:GetTags(mob)) do
            local num = string.match(tag, "(%d%d%d+)")
            if num then
                spiderIdentifierCache[mob] = num
                return num
            end
        end
    end)

    local numMatch = string.match(mob.Name, "(%d%d%d+)")
    if numMatch and #numMatch >= 4 then
        spiderIdentifierCache[mob] = numMatch
        return numMatch
    end

    spiderIdentifierCache[mob] = false
    return nil
end

local cachedMithrilCaveFolder = nil
local function getMithrilCaveSpidersFolder()
    if cachedMithrilCaveFolder and cachedMithrilCaveFolder.Parent then
        return cachedMithrilCaveFolder
    end
    local resources = getResourcesFolder()
    if resources then
        local folder = resources:FindFirstChild("MithrilCaveSpiders")
        if folder then
            cachedMithrilCaveFolder = folder
            return folder
        end
    end
    if cowWorldRef and cowWorldRef.Parent then
        local folder = cowWorldRef:FindFirstChild("MithrilCaveSpiders", true)
        if folder then
            cachedMithrilCaveFolder = folder
            return folder
        end
    end
    local folder = workspace:FindFirstChild("MithrilCaveSpiders", true)
    if folder then
        cachedMithrilCaveFolder = folder
        return folder
    end
    return nil
end

local function isSpiderMobInstance(instance)
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

local function isMithrilCaveMob(mob)
    if not mob then return false end
    if mithrilCaveMobSet[mob] then return true end
    local mFolder = getMithrilCaveSpidersFolder()
    if mFolder and mob:IsDescendantOf(mFolder) then
        mithrilCaveMobSet[mob] = true
        return true
    end
    local name = mob.Name
    if string.find(name, "FjordSpider", 1, true) or name == "Mama Spider" or string.find(name, "Mama", 1, true) then
        return true
    end
    return false
end

-- Recursively collects living spiders from Mithril Cave chambers and rooms
local function collectSpidersFromChamber(chamber)
    if not chamber then return end
    if isSpiderMobInstance(chamber) then
        if isMobAlive(chamber) and not mithrilCaveMobSet[chamber] then
            table.insert(activeAuraMobs, chamber)
            mithrilCaveMobSet[chamber] = true
        end
        return
    end

    for _, child in ipairs(chamber:GetChildren()) do
        if isSpiderMobInstance(child) then
            if isMobAlive(child) and not mithrilCaveMobSet[child] then
                table.insert(activeAuraMobs, child)
                mithrilCaveMobSet[child] = true
            end
        elseif child:IsA("Folder") or child:IsA("Configuration") or child:IsA("Model") then
            collectSpidersFromChamber(child)
        end
    end
end

-- ==========================
-- FISHING RIPPLE TRACKING (Zero Allocation & Leak-Free)
-- ==========================
local function registerRipple(ripple)
    if not ripple or not ripple.Parent then return end
    if not string.find(ripple.Name, "FishingWaterRipples", 1, true) then return end
    activeRipples[ripple] = true
end

local function unregisterRipple(ripple)
    if ripple then
        activeRipples[ripple] = nil
        ripplePosCache[ripple] = nil
    end
end

local function cleanupRippleTracking()
    for _, conn in ipairs(rippleConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(rippleConnections)
    table.clear(activeRipples)
    table.clear(ripplePosCache)
end

local function initRippleTracking()
    cleanupRippleTracking()

    -- 1. Scan direct children / descendants of fishingSpotsFolder (tiny scope: ~50 instances)
    local fFolder = getFishingSpotsFolder()
    if fFolder then
        for _, desc in ipairs(fFolder:GetDescendants()) do
            registerRipple(desc)
        end
        local conn = fFolder.DescendantAdded:Connect(registerRipple)
        table.insert(rippleConnections, conn)
        local remConn = fFolder.DescendantRemoving:Connect(unregisterRipple)
        table.insert(rippleConnections, remConn)
    end

    -- 2. Scan direct workspace children only (not descendants! ~30 instances)
    for _, child in ipairs(workspace:GetChildren()) do
        registerRipple(child)
    end
    local wsConn = workspace.ChildAdded:Connect(registerRipple)
    table.insert(rippleConnections, wsConn)
    local wsRemConn = workspace.ChildRemoved:Connect(unregisterRipple)
    table.insert(rippleConnections, wsRemConn)

    -- 3. Scan direct CowWorld children if present (~20 instances)
    local cWorld = cowWorldRef and cowWorldRef.Parent and cowWorldRef or workspace:FindFirstChild("CowWorld")
    if cWorld then
        for _, child in ipairs(cWorld:GetChildren()) do
            registerRipple(child)
        end
        local cwConn = cWorld.ChildAdded:Connect(registerRipple)
        table.insert(rippleConnections, cwConn)
        local cwRemConn = cWorld.ChildRemoved:Connect(unregisterRipple)
        table.insert(rippleConnections, cwRemConn)
    end
end

-- Lightweight background caching for Aura Mobs (Snakes & Spiders) strictly under their clearings
local function cacheBackgroundElements()
    if isCachingBackground then return end
    isCachingBackground = true

    if autoChompMobs or autoDodgeMobs then
        table.clear(activeAuraMobs)
        table.clear(mithrilCaveMobSet)
        local resources = getResourcesFolder()

        if resources then
            for _, clearing in ipairs(resources:GetChildren()) do
                if clearing.Name == "MithrilCaveSpiders" or string.find(clearing.Name, "Spider", 1, true) or string.find(clearing.Name, "Cave", 1, true) then
                    for _, chamber in ipairs(clearing:GetChildren()) do
                        collectSpidersFromChamber(chamber)
                    end
                else
                    for _, v in ipairs(clearing:GetChildren()) do
                        local name = v.Name
                        local isMob = (string.find(name, "Snake", 1, true) or string.find(name, "Spider", 1, true))
                        if isMob and (v:IsA("Model") or v:IsA("BasePart")) then
                            if isMobAlive(v) then
                                table.insert(activeAuraMobs, v)
                            end
                        end
                    end
                end
            end
        end

        local mithrilFolder = getMithrilCaveSpidersFolder()
        if mithrilFolder and (not resources or not resources:FindFirstChild("MithrilCaveSpiders")) then
            for _, chamber in ipairs(mithrilFolder:GetChildren()) do
                collectSpidersFromChamber(chamber)
            end
        end
    else
        if #activeAuraMobs > 0 then
            table.clear(activeAuraMobs)
        end
        table.clear(mithrilCaveMobSet)
    end

    isCachingBackground = false
end


local function getRipplePosition(ripple)
    if not ripple or not ripple.Parent then
        ripplePosCache[ripple] = nil
        return nil
    end
    local pos = ripplePosCache[ripple]
    if pos then return pos end
    pos = ripple:IsA("Model") and ripple:GetPivot().Position or (ripple:IsA("BasePart") and ripple.Position)
    if pos then
        ripplePosCache[ripple] = pos
    end
    return pos
end

local function isSpotAvailable(spot)
    if not spot or not spot.Parent then return false end
    local spotPos = getSpotPosition(spot)
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
    for ripple, _ in pairs(activeRipples) do
        if ripple and ripple.Parent then
            local ripplePos = getRipplePosition(ripple)
            if ripplePos and (get3DDistanceSq(spotPos, ripplePos) <= 49 or ripple:IsDescendantOf(spot)) then
                local surfaceGui = ripple:FindFirstChild("FishingWaterSurface")
                if (surfaceGui and surfaceGui.Enabled) or not surfaceGui then
                    return true
                end
            end
        else
            activeRipples[ripple] = nil
            ripplePosCache[ripple] = nil
        end
    end

    return false
end

function penESP.update()
    if penESP.show and farmOn and anchorPos then
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
        penESP.visualizer.Size = Vector3.new(0.5, farmRadius * 2, farmRadius * 2)
        penESP.visualizer.CFrame = CFrame.new(anchorPos) * CFrame.Angles(0, 0, math.rad(90))
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

local function checkAuctionLots()
    if not httpRequest or WEBHOOK_URL == "" then return end

    for _, lotName in ipairs(lotNames) do
        local lot = skinAuction:FindFirstChild(lotName)

        if lot then
            local currentSkinId = lot:GetAttribute("SkinId")
            local endsAt = lot:GetAttribute("EndsAt")

            local currentSignature = tostring(currentSkinId) .. "_" .. tostring(endsAt)

            if currentSkinId and currentSkinId ~= "" and currentSignature ~= previousAuctionSignatures[lotName] then
                previousAuctionSignatures[lotName] = currentSignature

                local skinName = lot:GetAttribute("SkinName") or "Unknown Skin"
                local rarity = lot:GetAttribute("Rarity") or "Default"
                local scope = lot:GetAttribute("Scope") or "N/A"
                local bid = lot:GetAttribute("Bid")
                local minBid = lot:GetAttribute("MinimumBid")

                local embedColor = rarityColors[rarity] or rarityColors["Default"]

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

local function debouncedCheckAuctionLots()
    if isCheckingAuction then return end
    isCheckingAuction = true
    task.spawn(function()
        checkAuctionLots()
        isCheckingAuction = false
    end)
end

-- ==========================
-- PERIODIC MEMORY SANITATION & GC ASSISTANCE
-- ==========================
local function sanitizeMemory(now)
    if now - lastSanitationTime > 30 then
        lastSanitationTime = now

        for node, _ in pairs(nodePositionCache) do
            if not node or not node.Parent then
                nodePositionCache[node] = nil
            end
        end

        for spot, _ in pairs(fishingSpotPosCache) do
            if not spot or not spot.Parent then
                fishingSpotPosCache[spot] = nil
            end
        end

        for ripple, _ in pairs(activeRipples) do
            if not ripple or not ripple.Parent then
                activeRipples[ripple] = nil
                ripplePosCache[ripple] = nil
            end
        end

        for mob, _ in pairs(mobAttackOriginPartCache) do
            if not mob or not mob.Parent then
                mobAttackOriginPartCache[mob] = nil
                mobHumanoidCache[mob] = nil
                mobWarningCache[mob] = nil
                mobWarningCheckTime[mob] = nil
                spiderIdentifierCache[mob] = nil
            end
        end

        cleanupNodeBlacklist(now)
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
local function updateHeartbeatConnection()
    if farmOn or autoChomp or autoFish or autoChompMobs or autoDodgeMobs or (manatite and manatite.auto) or (mithril and mithril.auto) then
        if not HeartbeatConnection then
            HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
                if not root or not humanoid or not root.Parent or not humanoid.Parent or humanoid.Health <= 0 then
                    if isUnderground then
                        isUnderground = false
                        pcall(function() if root then root.Anchored = false end end)
                    end
                    if isDodging then
                        isDodging = false
                        currentAttackingMob = nil
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
                if (autoChompMobs or autoDodgeMobs) and (now - lastBackgroundCacheTime > 1.5) then
                    lastBackgroundCacheTime = now
                    task.spawn(cacheBackgroundElements)
                end

                -- Comprehensive memory sanitation
                sanitizeMemory(now)

                -- 0. Priority Mob Attack Warning & Dodge Logic (Run Away & Surface Retreat)
                -- === AERIAL RETREAT: Low-Health Emergency Hover ===
                -- Triggered when hearts decrease; independently of autoDodgeMobs.
                -- Teleports player 200 studs up, pauses mining for 60s, then returns.
                if isAerialRetreat then
                    local elapsed = now - aerialRetreatStartTime
                    if elapsed < aerialRetreatDuration then
                        -- Lock the character at the aerial hover position
                        if aerialRetreatCFrame and root and root.Parent then
                            char:PivotTo(aerialRetreatCFrame)
                            root.CFrame = aerialRetreatCFrame
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end
                    else
                        -- 60 seconds elapsed: return to pre-retreat position and resume mining
                        isAerialRetreat = false
                        if root and root.Parent then
                            root.Anchored = false
                            if preAerialCFrame then
                                char:PivotTo(preAerialCFrame)
                                root.CFrame = preAerialCFrame
                                for _, part in ipairs(charBaseParts) do
                                    part.AssemblyLinearVelocity = Vector3.zero
                                    part.AssemblyAngularVelocity = Vector3.zero
                                end
                            end
                        end
                        aerialRetreatCFrame = nil
                        preAerialCFrame = nil
                        if notifyOnDodge then
                            Window:Notify({
                                Title = "Aerial Retreat: Complete",
                                Content = "Returned to mining position. Resuming autofarm.",
                                Duration = 2,
                            })
                        end
                    end
                elseif autoDodgeMobs and dodgeOnHeartsDecreased then
                    -- Quick health check to trigger aerial retreat (runs even without full autoDodge scan)
                    local currentHearts = getLocalPlayerHearts()
                    if currentHearts and lastRecordedHearts ~= nil and currentHearts < lastRecordedHearts then
                        if (now - lastAerialRetreatTime) >= aerialRetreatCooldown and not isAerialRetreat then
                            -- Save position and teleport 200 studs up
                            isAerialRetreat = true
                            aerialRetreatStartTime = now
                            lastAerialRetreatTime = now
                            preAerialCFrame = root.CFrame
                            local hoverPos = rootPos + Vector3.new(0, aerialRetreatHeight, 0)
                            aerialRetreatCFrame = CFrame.new(hoverPos) * root.CFrame.Rotation
                            char:PivotTo(aerialRetreatCFrame)
                            root.CFrame = aerialRetreatCFrame
                            root.Anchored = true
                            for _, part in ipairs(charBaseParts) do
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end
                            -- Blacklist current ore nodes so bot finds new ones on return
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
                            if notifyOnDodge then
                                Window:Notify({
                                    Title = "Aerial Retreat: Low Health!",
                                    Content = string.format("Retreating %d studs up for %ds. Mining paused.", aerialRetreatHeight, aerialRetreatDuration),
                                    Duration = 3,
                                })
                            end
                        end
                    end
                    lastRecordedHearts = currentHearts
                end

                if autoDodgeMobs and not isAerialRetreat then
                    local currentHearts = getLocalPlayerHearts()
                    local heartsDecreased = false
                    local heartsBelowNormal = false

                    if currentHearts then
                        if normalPlayerHearts == 0 or currentHearts > normalPlayerHearts then
                            normalPlayerHearts = currentHearts
                        end
                        local maxAttr = getLocalPlayerMaxHearts()
                        if maxAttr and maxAttr > normalPlayerHearts then
                            normalPlayerHearts = maxAttr
                        end

                        if lastRecordedHearts ~= nil and currentHearts < lastRecordedHearts then
                            heartsDecreased = true
                        end
                        if normalPlayerHearts > 0 and (normalPlayerHearts - currentHearts) > 0.05 then
                            heartsBelowNormal = true
                        end
                        lastRecordedHearts = currentHearts
                    end

                    local currentArmor = getLocalPlayerArmor()
                    local armorDecreased = false
                    local armorAtZero = false

                    if currentArmor ~= nil then
                        if normalPlayerArmor == 0 or currentArmor > normalPlayerArmor then
                            normalPlayerArmor = currentArmor
                        end
                        local maxArmorAttr = getLocalPlayerMaxArmor()
                        if maxArmorAttr and maxArmorAttr > normalPlayerArmor then
                            normalPlayerArmor = maxArmorAttr
                        end

                        if lastRecordedArmor ~= nil and currentArmor < lastRecordedArmor then
                            armorDecreased = true
                        end
                        if currentArmor <= 0.05 then
                            armorAtZero = true
                        end
                        lastRecordedArmor = currentArmor
                    else
                        -- No armor attribute or system detected: player is unarmored
                        armorAtZero = true
                    end

                    local attackingMobFound = false
                    local attackingMobInstance = nil

                    -- Chained multi-mob dodging: scan activeAuraMobs for ANY active attack warning relative to current position
                    local checkOrigin = (isUnderground and lastSurfacePos) or rootPos
                    local losOrigin = checkOrigin + Vector3.new(0, 0.5, 0)
                    for _, mob in ipairs(activeAuraMobs) do
                        if mob.Parent then
                            local mobPos = getMobAttackOrigin(mob)
                            if mobPos and get2DDistanceSq(checkOrigin, mobPos) <= dodgeDetectionRadiusSq then
                                if isMobAlive(mob) then
                                    local warning = findAttackWarning(mob)
                                    if isWarningActive(warning, mob) then
                                        if hasLineOfSight(losOrigin, mobPos, mob) then
                                            attackingMobFound = true
                                            attackingMobInstance = mob
                                            currentAttackingMob = mob
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local damageRetreatTriggered = false
                    if dodgeOnHeartsDecreased then
                        if armorDecreased and armorAtZero then
                            damageRetreatTriggered = true
                            lastDamageRetreatTime = now
                        elseif armorAtZero and heartsBelowNormal and not isDodging and (now - lastDamageRetreatTime > 2.0) then
                            damageRetreatTriggered = true
                            lastDamageRetreatTime = now
                        end
                        -- Note: heartsDecreased is now handled exclusively by the Aerial Retreat system above.
                    end

                    local shouldRetreat = (attackingMobFound and attackingMobInstance) or damageRetreatTriggered

                    if shouldRetreat then
                        lastWarningSeenTime = now

                        -- If attacking mob is outside server attack range (10 studs), or if damaged while mining:
                        -- The current crystal is infested and cannot be cleared from here.
                        -- Blacklist it immediately so the bot relocates to a clean crystal in another cavern chamber.
                        if (manatite and manatite.auto and manatite.model) or (mithril and mithril.auto and mithril.model) then
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
                        end

                        -- Force unanchor during surface dodges so evasion is never locked
                        if root.Anchored and dodgeMethod ~= "Underground" then
                            pcall(function() root.Anchored = false end)
                        end

                        -- Determine threat position to retreat away from
                        local attackOrigin = nil
                        if attackingMobInstance then
                            attackOrigin = getMobAttackOrigin(attackingMobInstance)
                        else
                            local closestDistSq = math.huge
                            for _, mob in ipairs(activeAuraMobs) do
                                if mob.Parent and isMobAlive(mob) then
                                    local mobPos = getMobAttackOrigin(mob)
                                    if mobPos then
                                        local distSq = get2DDistanceSq(rootPos, mobPos)
                                        if distSq < closestDistSq then
                                            closestDistSq = distSq
                                            attackingMobInstance = mob
                                            attackOrigin = mobPos
                                        end
                                    end
                                end
                            end
                        end
                        attackOrigin = attackOrigin or (preDodgePos or rootPos)

                        local awayDir = rootPos - attackOrigin
                        local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)

                        if away2D.Magnitude > 0.1 then
                            away2D = away2D.Unit
                        else
                            local look = root.CFrame.LookVector
                            away2D = Vector3.new(-look.X, 0, -look.Z)
                            if away2D.Magnitude > 0.1 then
                                away2D = away2D.Unit
                            else
                                away2D = Vector3.new(0, 0, 1)
                            end
                        end

                        if not isDodging or (isDodging and damageRetreatTriggered) then
                            if not isDodging then
                                isDodging = true
                                dodgeStartTime = now
                                preDodgePos = rootPos
                                preDodgeCFrame = root.CFrame
                                if humanoid then
                                    originalWalkSpeed = humanoid.WalkSpeed
                                end
                            end

                            local safeDodgeCFrame, safeDodgeDist, safeDodgeDir = findSafeDodgePosition(preDodgePos or rootPos, preDodgeCFrame or root.CFrame, away2D, dodgeRetreatDistance, dodgeRetreatAngle, attackingMobInstance)
                            local retreatDir = safeDodgeDir or away2D
                            local actualRetreatDist = safeDodgeDist or dodgeRetreatDistance

                            if dodgeMethod == "Run Away (Surface)" then
                                if humanoid then
                                    humanoid.WalkSpeed = dodgeWalkSpeed
                                end
                                root.Anchored = false
                            elseif dodgeMethod == "Teleport Away (Surface)" then
                                local targetCFrame = nil
                                local actualDist = 0

                                if safeDodgeCFrame and safeDodgeDist and safeDodgeDist >= 2.0 then
                                    targetCFrame = safeDodgeCFrame
                                    actualDist = safeDodgeDist
                                end

                                -- If damage occurred, retreat regardless of obstacle clearance
                                if not targetCFrame and (damageRetreatTriggered or (safeDodgeDist and safeDodgeDist < 2.0)) then
                                    local fallbackOffset = retreatDir * dodgeRetreatDistance
                                    local fallbackPos = (preDodgePos or rootPos) + fallbackOffset
                                    local floorRay = workspace:Raycast(fallbackPos + Vector3.new(0, 2.0, 0), Vector3.new(0, -10, 0), raycastParams)
                                    local groundY = floorRay and (floorRay.Position.Y + 2.8) or (preDodgePos and preDodgePos.Y or rootPos.Y)
                                    targetCFrame = CFrame.new(Vector3.new(fallbackPos.X, groundY, fallbackPos.Z)) * (preDodgeCFrame and preDodgeCFrame.Rotation or root.CFrame.Rotation)
                                    actualDist = dodgeRetreatDistance
                                end

                                if targetCFrame then
                                    char:PivotTo(targetCFrame)
                                    root.CFrame = targetCFrame
                                    for _, part in ipairs(charBaseParts) do
                                        part.AssemblyLinearVelocity = Vector3.zero
                                        part.AssemblyAngularVelocity = Vector3.zero
                                    end
                                    lastTeleportDodgeDist = actualDist
                                else
                                    lastTeleportDodgeDist = 0
                                end
                                root.Anchored = false
                            elseif dodgeMethod == "Underground" then
                                isUnderground = true
                                lastSurfaceCFrame = root.CFrame
                                lastSurfacePos = rootPos

                                local retreatOffset = retreatDir * (actualRetreatDist > 0 and actualRetreatDist or dodgeRetreatDistance)
                                currentUndergroundRetreatOffset = retreatOffset
                                local targetPos = lastSurfacePos + retreatOffset - Vector3.new(0, undergroundDepth, 0)
                                undergroundCFrame = CFrame.new(targetPos) * (lastSurfaceCFrame.Rotation)

                                char:PivotTo(undergroundCFrame)
                                root.CFrame = undergroundCFrame
                                root.Anchored = true

                                for _, part in ipairs(charBaseParts) do
                                    part.AssemblyLinearVelocity = Vector3.zero
                                    part.AssemblyAngularVelocity = Vector3.zero
                                    if part ~= root then
                                        part.CanCollide = false
                                    end
                                end
                            end

                            if notifyOnDodge then
                                local reason = (armorAtZero and (heartsDecreased or heartsBelowNormal) and " [Armor Broken & Hearts Decreased]")
                                    or ((heartsDecreased or heartsBelowNormal) and " [Hearts Decreased]")
                                    or ""
                                local methodDesc = (dodgeMethod == "Run Away (Surface)" and "Running away " .. tostring(dodgeRetreatDistance) .. " studs" .. reason .. ".")
                                    or (dodgeMethod == "Teleport Away (Surface)" and (lastTeleportDodgeDist > 0 and string.format("Teleported %.1f studs away%s.", lastTeleportDodgeDist, reason) or "Retreated away."))
                                    or ("Retreated underground (" .. tostring(math.floor(dodgeRetreatDistance)) .. " studs away" .. reason .. ").")
                                Window:Notify({
                                    Title = "Attack Warning Detected",
                                    Content = methodDesc,
                                    Duration = 1.5,
                                })
                            end
                        end

                        -- Ongoing evasion while warning is active
                        if dodgeMethod == "Run Away (Surface)" then
                            if humanoid then
                                if humanoid.WalkSpeed ~= dodgeWalkSpeed then
                                    humanoid.WalkSpeed = dodgeWalkSpeed
                                end
                                root.Anchored = false
                                local currentDist = get2DDistance(rootPos, attackOrigin)
                                if currentDist < dodgeRetreatDistance then
                                    local retreatTarget = attackOrigin + (away2D * (dodgeRetreatDistance + 5))
                                    humanoid:Move(away2D, false)
                                    humanoid:MoveTo(retreatTarget)
                                else
                                    humanoid:Move(Vector3.zero, false)
                                end
                            end
                        elseif dodgeMethod == "Underground" and isUnderground and undergroundCFrame then
                            char:PivotTo(undergroundCFrame)
                            root.CFrame = undergroundCFrame
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end
                    else
                        -- No active attack warning or damage hit this frame: check if currently dodging
                        if isDodging then
                            local canExitDodge = ((now - lastWarningSeenTime) >= dodgeLingerDelay) or (now - dodgeStartTime > 2.0)

                            if canExitDodge then
                                -- Safe! Attack has completely ended
                                if dodgeMethod == "Underground" and isUnderground then
                                    if lastSurfaceCFrame then
                                        local surfaceRetreatPos = lastSurfacePos and (lastSurfacePos + (currentUndergroundRetreatOffset or Vector3.zero)) or lastSurfaceCFrame.Position
                                        local rayHit = workspace:Raycast(surfaceRetreatPos + Vector3.new(0, 4, 0), Vector3.new(0, -20, 0), raycastParams)
                                        local groundY = rayHit and (rayHit.Position.Y + 3) or (lastSurfacePos and (lastSurfacePos.Y + 0.5) or surfaceRetreatPos.Y)
                                        local surfaceTarget = CFrame.new(Vector3.new(surfaceRetreatPos.X, groundY, surfaceRetreatPos.Z)) * lastSurfaceCFrame.Rotation
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
                                    isUnderground = false
                                    lastSurfaceCFrame = nil
                                    lastSurfacePos = nil
                                    undergroundCFrame = nil
                                    currentUndergroundRetreatOffset = nil
                                else
                                    -- Surface / Run Away cleanup
                                    if humanoid then
                                        humanoid.WalkSpeed = originalWalkSpeed or 16
                                        if not farmOn then
                                            humanoid:Move(Vector3.zero, false)
                                        end
                                    end

                                    -- Return safely to preDodgeCFrame if farming Manatite or Mithril ONLY IF the crystal wasn't blacklisted from damage
                                    if dodgeMethod == "Teleport Away (Surface)" and preDodgeCFrame then
                                        local crystalStillValid = (manatite and manatite.auto and manatite.model and not manatite.blacklist[manatite.model])
                                            or (mithril and mithril.auto and mithril.model and not mithril.blacklist[mithril.model])
                                        if crystalStillValid then
                                            char:PivotTo(preDodgeCFrame)
                                            root.CFrame = preDodgeCFrame
                                            for _, part in ipairs(charBaseParts) do
                                                part.AssemblyLinearVelocity = Vector3.zero
                                                part.AssemblyAngularVelocity = Vector3.zero
                                            end
                                            if ((manatite and manatite.auto and manatite.anchor) or (mithril and mithril.auto and mithril.anchor)) and not hasNearbyThreat then
                                                pcall(function() root.Anchored = true end)
                                            end
                                        end
                                    end
                                end

                                isDodging = false
                                currentAttackingMob = nil
                                preDodgePos = nil
                                preDodgeCFrame = nil

                                if farmOn then
                                    currentTargetNode = nil
                                end

                                if notifyOnDodge then
                                    Window:Notify({
                                        Title = "Attack Cleared",
                                        Content = "Safe from attack. Resumed normal activity.",
                                        Duration = 1.2,
                                    })
                                end
                            else
                                -- Still lingering (mob strike animation playing): maintain evasion
                                if dodgeMethod == "Run Away (Surface)" then
                                    if humanoid then
                                        if humanoid.WalkSpeed ~= dodgeWalkSpeed then
                                            humanoid.WalkSpeed = dodgeWalkSpeed
                                        end
                                        local attackOrigin = (currentAttackingMob and getMobAttackOrigin(currentAttackingMob)) or (preDodgePos or rootPos)
                                        local currentDist = get2DDistance(rootPos, attackOrigin)
                                        if currentDist < dodgeRetreatDistance then
                                            local awayDir = rootPos - attackOrigin
                                            local away2D = Vector3.new(awayDir.X, 0, awayDir.Z)
                                            away2D = (away2D.Magnitude > 0.1) and away2D.Unit or Vector3.new(0, 0, 1)
                                            humanoid:Move(away2D, false)
                                        else
                                            humanoid:Move(Vector3.zero, false)
                                        end
                                    end
                                elseif dodgeMethod == "Underground" and isUnderground and undergroundCFrame then
                                    char:PivotTo(undergroundCFrame)
                                    root.CFrame = undergroundCFrame
                                    root.AssemblyLinearVelocity = Vector3.zero
                                    root.AssemblyAngularVelocity = Vector3.zero
                                end
                            end
                        end
                    end
                elseif isDodging or isUnderground then
                    -- autoDodgeMobs was disabled while dodging
                    if isUnderground then
                        if lastSurfaceCFrame then
                            local surfaceTarget = lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
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
                        isUnderground = false
                        lastSurfaceCFrame = nil
                        lastSurfacePos = nil
                        undergroundCFrame = nil
                    end
                    if humanoid then
                        humanoid.WalkSpeed = originalWalkSpeed or 16
                        if not farmOn then
                            humanoid:Move(Vector3.zero, false)
                        end
                    end
                    if dodgeMethod == "Teleport Away (Surface)" and preDodgeCFrame then
                        if ((manatite and manatite.auto) or (mithril and mithril.auto)) then
                            char:PivotTo(preDodgeCFrame)
                            root.CFrame = preDodgeCFrame
                            for _, part in ipairs(charBaseParts) do
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end
                            if ((manatite and manatite.auto and manatite.anchor) or (mithril and mithril.auto and mithril.anchor)) then
                                pcall(function() root.Anchored = true end)
                            end
                        end
                    end
                    isDodging = false
                    currentAttackingMob = nil
                    preDodgePos = nil
                    preDodgeCFrame = nil
                end

                -- 1. Movement Logic
                if farmOn and not (manatite and manatite.auto) and not (mithril and mithril.auto) and anchorPos and not isDodging and not isUnderground then
                    patternTimer = patternTimer + (dt * patternSpeed)
                    local targetPos

                    if pattern == "Guided Zigzag (Nodes)" then
                        local ghostX = math.sin(patternTimer * 1.3) * farmRadius
                        local ghostZ = math.cos(patternTimer * 1.9) * farmRadius
                        local ghostPos = anchorPos + Vector3.new(ghostX, 0, ghostZ)

                        local needNewNode = false
                        if not currentTargetNode or not currentTargetNode.Parent then
                            needNewNode = true
                        else
                            local tPos = getNodePosition(currentTargetNode)
                            if get2DDistanceSq(rootPos, tPos) < 16 then
                                needNewNode = true
                            end
                        end

                        if needNewNode then
                            local nearestDistSq = math.huge
                            local nearestNode = nil
                            local grassNodes = getGrassNodes()

                            for _, node in ipairs(grassNodes) do
                                if node.Parent then
                                    local nodePos = getNodePosition(node)
                                    -- Distance check FIRST: only parse strings if inside farm radius
                                    if get2DDistanceSq(anchorPos, nodePos) <= farmRadiusSq then
                                        local cleanName = getCleanGrassName(node.Name)
                                        if cleanName then
                                            local distFromGhostSq = get2DDistanceSq(ghostPos, nodePos)
                                            local blacklistedAt = nodeBlacklist[node]
                                            if distFromGhostSq < nearestDistSq and (not blacklistedAt or now - blacklistedAt > 10) then
                                                nearestDistSq = distFromGhostSq
                                                nearestNode = node
                                            end
                                        end
                                    end
                                end
                            end

                            if nearestNode then
                                currentTargetNode = nearestNode
                                nodeBlacklist[nearestNode] = now
                            else
                                currentTargetNode = nil
                                if not nextRandomPos or get2DDistanceSq(rootPos, nextRandomPos) < 25 then
                                    local angle = math.random() * (math.pi * 2)
                                    nextRandomPos = anchorPos + Vector3.new(math.cos(angle) * farmRadius, 0, math.sin(angle) * farmRadius)
                                end
                            end
                        end

                        if currentTargetNode and currentTargetNode.Parent then
                            targetPos = getNodePosition(currentTargetNode)
                        else
                            targetPos = nextRandomPos
                        end

                    elseif pattern == "Circle" then
                        local currentRadius = farmRadius * math.abs(math.sin(patternTimer * 0.2))
                        local angle = patternTimer * 1.5
                        targetPos = anchorPos + Vector3.new(math.cos(angle) * currentRadius, 0, math.sin(angle) * currentRadius)

                    elseif pattern == "Square" then
                        targetPos = anchorPos + Vector3.new(math.sin(patternTimer * 1.8) * farmRadius, 0, math.cos(patternTimer * 0.2) * farmRadius)

                    elseif pattern == "Zigzag" then
                        targetPos = anchorPos + Vector3.new(math.sin(patternTimer * 1.3) * farmRadius, 0, math.cos(patternTimer * 1.9) * farmRadius)

                    elseif pattern == "Random" then
                        if not nextRandomPos or get2DDistanceSq(rootPos, nextRandomPos) < 25 then
                            local angle = math.random() * (math.pi * 2)
                            nextRandomPos = anchorPos + Vector3.new(math.cos(angle) * farmRadius, 0, math.sin(angle) * farmRadius)
                        end
                        targetPos = nextRandomPos
                    end

                    if targetPos and (now - lastMoveTime > 0.05) then
                        local offX = targetPos.X - anchorPos.X
                        local offZ = targetPos.Z - anchorPos.Z
                        local distSq = offX * offX + offZ * offZ
                        if distSq > farmRadiusSq then
                            local scale = farmRadius / math.sqrt(distSq)
                            targetPos = Vector3.new(anchorPos.X + offX * scale, targetPos.Y, anchorPos.Z + offZ * scale)
                        end

                        humanoid:MoveTo(targetPos)
                        lastMoveTime = now
                    end
                end

                local prioritizedMobThisFrame = false

                -- 2. Priority Mob Aura Logic (unobstructed line of sight only)
                if autoChompMobs then
                    local auraOrigin = isUnderground and (lastSurfacePos or rootPos) or rootPos
                    local losOrigin = (isUnderground and lastSurfacePos or rootPos) + Vector3.new(0, 0.5, 0)
                    local closestMob = nil
                    local closestDistSq = math.huge
                    local closestMobPos = nil

                    for _, mob in ipairs(activeAuraMobs) do
                        if mob.Parent then
                            local mobPos = getMobAttackOrigin(mob)
                            if mobPos then
                                local distSq = get3DDistanceSq(auraOrigin, mobPos)
                                if distSq <= MOB_AURA_RADIUS_SQ and distSq < closestDistSq then
                                    if isMobAlive(mob) and hasLineOfSight(losOrigin, mobPos, mob) then
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
                        local isCaveMob = isMithrilCaveMob(mob)

                        if isCaveMob then
                            if (now - mobChompCooldown > mobAuraDelay) or (lastChompedMob ~= mob) then
                                if not isUnderground and not isDodging then
                                    local lookDx = mobPos.X - rootPos.X
                                    local lookDz = mobPos.Z - rootPos.Z
                                    if (lookDx * lookDx + lookDz * lookDz) > 0.01 then
                                        root.CFrame = CFrame.lookAt(rootPos, Vector3.new(mobPos.X, rootPos.Y, mobPos.Z))
                                    end
                                end

                                local spiderId = findSpiderIdentifier(mob)
                                if spiderId then
                                    local payloadName = "Cavern_Mob_Spider_" .. tostring(spiderId)
                                    chompEvent:FireServer(payloadName)
                                else
                                    local fallbackPayload = getMobPayload(mob.Name)
                                    if fallbackPayload then
                                        chompEvent:FireServer(fallbackPayload)
                                    end
                                    chompEvent:FireServer("Cavern_Mob_Spider")
                                    chompEvent:FireServer(mob.Name)
                                end

                                if fireproximityprompt then
                                    local prompt = mob:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt and prompt.Enabled then
                                        pcall(function() fireproximityprompt(prompt) end)
                                    end
                                end

                                pressE()

                                lastChompedMob = mob
                                mobChompCooldown = now
                                prioritizedMobThisFrame = true
                            else
                                prioritizedMobThisFrame = true
                            end
                        else
                            local payloadName = getMobPayload(mob.Name)

                            if payloadName ~= lastChompedMob or (now - mobChompCooldown > mobAuraDelay) then
                                if not isUnderground and not isDodging then
                                    local lookDx = mobPos.X - rootPos.X
                                    local lookDz = mobPos.Z - rootPos.Z
                                    if (lookDx * lookDx + lookDz * lookDz) > 0.01 then
                                        root.CFrame = CFrame.lookAt(rootPos, Vector3.new(mobPos.X, rootPos.Y, mobPos.Z))
                                    end
                                end
                                chompEvent:FireServer(payloadName)
                                lastChompedMob = payloadName
                                mobChompCooldown = now
                                prioritizedMobThisFrame = true
                            else
                                prioritizedMobThisFrame = true
                            end
                        end
                    end
                end

                -- 3. Raycast Grass Chomp Logic (Yields to Mobs & Dodging)
                if autoChomp and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not prioritizedMobThisFrame and not isUnderground and not isDodging then
                    if (now - lastRaycastChompTime > 0.04) then
                        lastRaycastChompTime = now
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
                                local cleanName = getCleanGrassName(nodeName)
                                if cleanName then
                                    if cleanName ~= lastChompedNode or (now - chompCooldown > 1) then
                                        chompEvent:FireServer(cleanName)
                                        lastChompedNode = cleanName
                                        chompCooldown = now

                                        if currentTargetNode and currentTargetNode.Name == nodeName then
                                            currentTargetNode = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- 4. Auto-Fishing Logic
                if autoFish and not (manatite and manatite.auto) and not (mithril and mithril.auto) then
                    if not fishingEvent and cowRemotes then
                        fishingEvent = cowRemotes:FindFirstChild("FishingRequest")
                    end
                    if fishingEvent and (now - castCooldown > 3) and (now - lastFishingSearchTime > 0.3) then
                        lastFishingSearchTime = now
                        local nearestSpot = nil
                        local shortestDistSq = 2500 -- 50 studs squared
                        local fishingSpots = getFishingSpots()

                        for _, spot in ipairs(fishingSpots) do
                            if spot.Parent then
                                local spotPos = getSpotPosition(spot)
                                if spotPos then
                                    local distSq = get2DDistanceSq(rootPos, spotPos)

                                    if distSq < shortestDistSq and isSpotAvailable(spot) then
                                        shortestDistSq = distSq
                                        nearestSpot = spot
                                    end
                                end
                            end
                        end

                        if nearestSpot then
                            fishingEvent:FireServer("Cast", nearestSpot)
                            castCooldown = now
                        end
                    end
                end

                -- Threat clearing detection: check if any alive hostile mobs are within server attack reach (10 studs) with unobstructed line of sight
                local hasNearbyThreat = false
                if autoChompMobs and ((manatite and manatite.auto) or (mithril and mithril.auto) or farmOn) then
                    local threatOrigin = isUnderground and (lastSurfacePos or rootPos) or rootPos
                    local losOrigin = threatOrigin + Vector3.new(0, 0.5, 0)
                    for _, mob in ipairs(activeAuraMobs) do
                        if mob.Parent and isMobAlive(mob) then
                            local mobPos = getMobAttackOrigin(mob)
                            if mobPos and get3DDistanceSq(threatOrigin, mobPos) <= MANATITE_THREAT_RADIUS_SQ then
                                if hasLineOfSight(losOrigin, mobPos, mob) then
                                    hasNearbyThreat = true
                                    break
                                end
                            end
                        end
                    end
                end

                -- Mobs outside actual server attack reach (closestMob was nil in autoChompMobs) must NOT freeze the farm loop
                if hasNearbyThreat and not prioritizedMobThisFrame then
                    hasNearbyThreat = false
                end

                -- Deadlock breaker: if surrounding mobs cannot be killed or persist for > 1.5 seconds, relocate to next crystal
                if hasNearbyThreat then
                    if threatStartTime == 0 then
                        threatStartTime = now
                    elseif (now - threatStartTime > 1.5) then
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
                        threatStartTime = 0
                        hasNearbyThreat = false
                    end
                else
                    threatStartTime = 0
                end

                if hasNearbyThreat and prioritizeMobsOverManatite and root.Anchored and not isUnderground then
                    pcall(function() root.Anchored = false end)
                end

                -- 5. Manatite Farm Logic (Sea Maze Teleport & Autochomp)
                if manatite and manatite.auto and not isUnderground and not isDodging and not isAerialRetreat and not (prioritizeMobsOverManatite and hasNearbyThreat) then
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

                        if get3DDistanceSq(rootPos, targetPos) > 36 then
                            if (now - manatite.lastTeleportTime > 0.4) then
                                manatite.teleport(manatite.target, manatite.model)
                                manatite.lastTeleportTime = now
                            end
                        else
                            if manatite.anchor and not root.Anchored and not isDodging and not isUnderground and not hasNearbyThreat then
                                pcall(function() root.Anchored = true end)
                            end
                        end

                        if (now - manatite.lastChompTime >= manatite.delay) then
                            manatite.lastChompTime = now
                            chompEvent:FireServer(manatite.payload)
                        end
                    end
                end

                -- 6. Mithril Ore Farm Logic (Crystal Geode Ores Teleport & Autochomp)
                if mithril and mithril.auto and not isUnderground and not isDodging and not isAerialRetreat and not (prioritizeMobsOverManatite and hasNearbyThreat) then
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

                        if get3DDistanceSq(rootPos, targetPos) > 36 then
                            if (now - mithril.lastTeleportTime > 0.4) then
                                mithril.teleport(mithril.orePart, mithril.model)
                                mithril.lastTeleportTime = now
                            end
                        else
                            if mithril.anchor and not root.Anchored and not isDodging and not isUnderground and not hasNearbyThreat then
                                pcall(function() root.Anchored = true end)
                            end
                        end

                        if (now - mithril.lastChompTime >= mithril.delay) then
                            mithril.lastChompTime = now
                            chompEvent:FireServer(mithril.payload)
                        end
                    end
                end
            end)
        end
    else
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
            HeartbeatConnection = nil
        end
        if isUnderground and root and lastSurfaceCFrame then
            root.CFrame = lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            for _, part in ipairs(charBaseParts) do
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                    part.CanCollide = true
                end
            end
            isUnderground = false
            lastSurfaceCFrame = nil
            lastSurfacePos = nil
            undergroundCFrame = nil
        end
        if isDodging then
            if humanoid then humanoid.WalkSpeed = originalWalkSpeed or 16 end
            isDodging = false
            currentAttackingMob = nil
            preDodgePos = nil
            preDodgeCFrame = nil
        end
        if manatite and not manatite.auto and manatite.anchor and root then
            pcall(function() root.Anchored = false end)
        end
        if mithril and not mithril.auto and mithril.anchor and root then
            pcall(function() root.Anchored = false end)
        end
        if not farmOn and humanoid then humanoid:Move(Vector3.zero, false) end
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
        farmOn = Value
        patternTimer = 0
        nextRandomPos = nil
        currentTargetNode = nil

        if Value then
            anchorPos = root.Position

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
        autoChomp = Value
        updateHeartbeatConnection()
    end,
})


MainTab:CreateToggle({
    Name = "Enable Mob Aura (Priority)",
    CurrentValue = false,
    Flag = "Toggle_MobAura",
    Callback = function(Value)
        autoChompMobs = Value
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Auto-Fishing",
    CurrentValue = false,
    Flag = "Toggle_Fish",
    Callback = function(Value)
        autoFish = Value
        if Value then
            initRippleTracking()
        else
            cleanupRippleTracking()
        end
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Mob Attack Dodge",
    CurrentValue = false,
    Flag = "Toggle_AutoDodge",
    Callback = function(Value)
        autoDodgeMobs = Value
        if not Value then
            if isUnderground and root and lastSurfaceCFrame then
                root.CFrame = lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
                root.Anchored = false
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                for _, part in ipairs(charBaseParts) do
                    if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "Torso" then
                        part.CanCollide = true
                    end
                end
                isUnderground = false
                lastSurfaceCFrame = nil
                lastSurfacePos = nil
                undergroundCFrame = nil
            end
            if isDodging then
                if humanoid then humanoid.WalkSpeed = originalWalkSpeed or 16 end
                isDodging = false
                currentAttackingMob = nil
                preDodgePos = nil
                preDodgeCFrame = nil
                if not farmOn and humanoid then humanoid:Move(Vector3.zero, false) end
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
        if selection == "Slow (1.0s)" then mobAuraDelay = 1.0
        elseif selection == "Normal (0.5s)" then mobAuraDelay = 0.5
        elseif selection == "Fast (0.1s)" then mobAuraDelay = 0.1
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Walking Pattern",
    Options = {"Guided Zigzag (Nodes)", "Circle", "Square", "Zigzag", "Random"},
    CurrentOption = {"Guided Zigzag (Nodes)"},
    MultipleOptions = false,
    Flag = "Dropdown_Pattern",
    Callback = function(Option) pattern = type(Option) == "table" and Option[1] or Option end,
})

MainTab:CreateSlider({
    Name = "Farm Radius (Studs)",
    Range = {10, 300},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 75,
    Flag = "Slider_Radius",
    Callback = function(Value)
        farmRadius = Value
        farmRadiusSq = farmRadius * farmRadius
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
        if selection == "Very Slow (0.4x)" then patternSpeed = 0.4
        elseif selection == "Slow (0.6x)" then patternSpeed = 0.6
        elseif selection == "Normal (1.0x)" then patternSpeed = 1.0
        elseif selection == "Fast (1.6x)" then patternSpeed = 1.6
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
        dodgeMethod = type(Option) == "table" and Option[1] or Option
        if dodgeMethod ~= "Underground" and isUnderground and root and lastSurfaceCFrame then
            root.CFrame = lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            isUnderground = false
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
        dodgeRetreatDistance = Value
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
        dodgeRetreatAngle = Value
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
        dodgeWalkSpeed = Value
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
        undergroundDepth = Value
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
        dodgeDetectionRadius = Value
        dodgeDetectionRadiusSq = Value * Value
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
        dodgeLingerDelay = Value
    end,
})

MainTab:CreateToggle({
    Name = "Notify on Attack Dodge",
    CurrentValue = false,
    Flag = "Toggle_DodgeNotify",
    Callback = function(Value)
        notifyOnDodge = Value
    end,
})

MainTab:CreateToggle({
    Name = "Retreat on Armor / Hearts Decreased",
    CurrentValue = true,
    Flag = "Toggle_DodgeHearts",
    Callback = function(Value)
        dodgeOnHeartsDecreased = Value
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
        if not Value and root and not isUnderground then
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
    Name = "Prioritize Mobs Near Manatite (10 Studs)",
    CurrentValue = true,
    Flag = "Toggle_PrioritizeMobsManatite",
    Callback = function(Value)
        prioritizeMobsOverManatite = Value
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
        if not Value and root and not isUnderground then
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
        scannerRunning = Value

        if scannerRunning then
            if not httpRequest then
                Window:Notify({ Title = "Unsupported", Content = "Your executor does not support HTTP requests.", Duration = 4 })
                scannerRunning = false
                return
            elseif WEBHOOK_URL == "" then
                Window:Notify({ Title = "No Webhook", Content = "Please enter a valid Discord Webhook URL first.", Duration = 4 })
                scannerRunning = false
                return
            end

            for _, lotName in ipairs(lotNames) do
                local lot = skinAuction:FindFirstChild(lotName)
                if lot then
                    local conn = lot:GetAttributeChangedSignal("SkinId"):Connect(function()
                        task.wait(1)
                        if scannerRunning then debouncedCheckAuctionLots() end
                    end)
                    table.insert(auctionConnections, conn)
                end
            end

            debouncedCheckAuctionLots()
        else
            for _, conn in ipairs(auctionConnections) do conn:Disconnect() end
            table.clear(auctionConnections)
        end
    end,
})

ScannerTab:CreateSection({ Name = "Auction House Tools" })

-- Show Current Auction Skins button
ScannerTab:CreateButton({
    Name = "Show Current Auction Skins",
    Callback = function()
        local lines = {}
        for _, lotName in ipairs(lotNames) do
            local lot = skinAuction:FindFirstChild(lotName)
            if lot then
                local skinName = lot:GetAttribute("SkinName")
                local skinId = lot:GetAttribute("SkinId")
                if skinName and skinName ~= "" and skinId and skinId ~= "" then
                    local rarity = lot:GetAttribute("Rarity") or "?"
                    local bid = lot:GetAttribute("Bid")
                    local minBid = lot:GetAttribute("MinimumBid")
                    table.insert(lines,
                        lotName .. ": " .. tostring(skinName)
                        .. " [" .. tostring(rarity) .. "]"
                        .. " | Bid: " .. formatNumber(bid)
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

-- Auto Bid buttons for each lot
local skinAuctionRemote = cowRemotes:FindFirstChild("SkinAuctionRequest")

for i, lotName in ipairs(lotNames) do
    ScannerTab:CreateButton({
        Name = "Auto Bid " .. lotName,
        Callback = function()
            if not skinAuctionRemote then
                Window:Notify({ Title = "Error", Content = "SkinAuctionRequest remote not found.", Duration = 4 })
                return
            end

            local lot = skinAuction:FindFirstChild(lotName)
            if not lot then
                Window:Notify({ Title = "Error", Content = lotName .. " not found in SkinAuction.", Duration = 4 })
                return
            end

            local round = lot:GetAttribute("Round")
            local slot = lot:GetAttribute("Slot")
            local minBid = lot:GetAttribute("MinimumBid")

            if not round or not slot or not minBid then
                Window:Notify({
                    Title = "Error",
                    Content = lotName .. " missing attributes (Round/Slot/MinimumBid).",
                    Duration = 4
                })
                return
            end

            local success, result = pcall(function()
                return skinAuctionRemote:InvokeServer({
                    Slot = slot,
                    Round = round,
                    Action = "Bid",
                    Amount = minBid
                })
            end)

            if success then
                Window:Notify({
                    Title = "Bid Placed",
                    Content = lotName .. " | Amount: " .. formatNumber(minBid) .. "\nRound: " .. tostring(round),
                    Duration = 5
                })
            else
                Window:Notify({
                    Title = "Bid Failed",
                    Content = lotName .. ": " .. tostring(result),
                    Duration = 5
                })
            end
        end,
    })
end

ScannerTab:CreateSection({ Name = "Proximity Prompts" })

for i, lotName in ipairs(lotNames) do
    ScannerTab:CreateButton({
        Name = "Fire Bid Prompt " .. lotName,
        Callback = function()
            local pedestalPath = workspace:FindFirstChild("CowWorld")
                and workspace.CowWorld:FindFirstChild("Decorations")
                and workspace.CowWorld.Decorations:FindFirstChild("SkinAuctionHall")
                and workspace.CowWorld.Decorations.SkinAuctionHall:FindFirstChild(lotName)
                and workspace.CowWorld.Decorations.SkinAuctionHall[lotName]:FindFirstChild("Pedestal")

            if not pedestalPath then
                Window:Notify({ Title = "Error", Content = "Could not find " .. lotName .. " pedestal.", Duration = 4 })
                return
            end

            local prompt = pedestalPath:FindFirstChild("CowAuctionBid")
                or pedestalPath:FindFirstChildWhichIsA("ProximityPrompt", true)

            if not prompt then
                Window:Notify({ Title = "Error", Content = "No proximity prompt found on " .. lotName .. " pedestal.", Duration = 4 })
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
                -- Fallback: trigger via the ProximityPrompt's Triggered signal
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + 0.05)
                    prompt:InputHoldEnd()
                    fired = true
                end)
            end

            if fired then
                Window:Notify({ Title = "Prompt Fired", Content = lotName .. " bid prompt activated.", Duration = 3 })
            else
                Window:Notify({ Title = "Error", Content = "Failed to fire " .. lotName .. " prompt.", Duration = 4 })
            end
        end,
    })
end

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
        fpsCapEnabled = Value
        if setfpscap then pcall(function() setfpscap(fpsCapEnabled and currentFpsCap or 60) end) end
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
        currentFpsCap = Value
        if fpsCapEnabled and setfpscap then pcall(function() setfpscap(currentFpsCap) end) end
    end,
})

SettingsTab:CreateSection({ Name = "Script Controls" })

SettingsTab:CreateButton({
    Name = "Close Script & Destroy UI",
    Callback = function()
        if scannerRunning and httpRequest and WEBHOOK_URL ~= "" then
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

        farmOn = false
        autoChomp = false
        autoChompMobs = false
        autoFish = false
        cleanupRippleTracking()
        autoDodgeMobs = false
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
        if isAerialRetreat and root then
            isAerialRetreat = false
            root.Anchored = false
            if preAerialCFrame then
                pcall(function() char:PivotTo(preAerialCFrame) end)
                pcall(function() root.CFrame = preAerialCFrame end)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            aerialRetreatCFrame = nil
            preAerialCFrame = nil
        end
        if isUnderground and root and lastSurfaceCFrame then
            root.CFrame = lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            isUnderground = false
            currentUndergroundRetreatOffset = nil
        end
        if isDodging then
            if humanoid then humanoid.WalkSpeed = originalWalkSpeed or 16 end
            isDodging = false
            currentAttackingMob = nil
        end
        scannerRunning = false
        penESP.show = false
        chestESP.show = false
        penESP.update()
        chestESP.update()

        table.clear(activeAuraMobs)
        table.clear(mithrilCaveMobSet)
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

        for _, conn in ipairs(auctionConnections) do conn:Disconnect() end
        table.clear(auctionConnections)

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
