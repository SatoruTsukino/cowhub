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
local fishingEvent = cowRemotes:FindFirstChild("FishingRequest") or cowRemotes:WaitForChild("FishingRequest")
local skinAuction = cowGame:WaitForChild("SkinAuction")
local fishingSpotsFolder = workspace:WaitForChild("Fishing Spots")

-- Pre-configured Raycast Parameters (Zero allocation per frame)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {char}

local charConn = plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if humanoid then originalWalkSpeed = humanoid.WalkSpeed end
    raycastParams.FilterDescendantsInstances = {char}
    updateCharBaseParts(newChar)
    isDodging = false
    isUnderground = false
    currentAttackingMob = nil
    preDodgePos = nil
    preDodgeCFrame = nil
    lastSurfaceCFrame = nil
    lastSurfacePos = nil
    undergroundCFrame = nil
    currentManatiteModel = nil
    currentGrazeTarget = nil
    currentManatitePayload = nil
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
local MOB_AURA_RADIUS_SQ = 100 -- Hardcoded 10 studs squared (10 * 10)
local mobAuraDelay = 0.1
local lastMoveTime = 0
local HeartbeatConnection = nil

-- Manatite Farm Variables
local autoManatite = false
local manatiteChompDelay = 0.1
local manatiteHeightOffset = 2.5
local manatiteOrder = "Nearest Available" -- "Nearest Available", "Alphabetical (A-Z)"
local manatiteAnchorChomp = false
local returnOnDisable = false
local preManatiteCFrame = nil
local currentManatiteModel = nil
local currentGrazeTarget = nil
local currentManatitePayload = nil
local lastManatiteChompTime = 0
local lastManatiteTeleportTime = 0
local lastManatiteSearchTime = 0
local currentManatiteStartTime = 0
local manatiteBlacklist = setmetatable({}, { __mode = "k" })
local lastManatiteBlacklistCleanup = 0
local manatitePayloadCache = {}

-- Manatite ESP Variables
local showManatiteESP = false
local manatiteVisuals = {}
local manatiteEspConnection = nil

-- Pen ESP Variables
local showPenESP = false
local penVisualizer = nil

-- Dynamic Team Chest ESP Variables
local showChestESP = false
local chestHighlight = nil
local chestBillboard = nil
local chestEspConnection = nil
local chestChildAddedConn = nil
local chestChildRemovedConn = nil

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

-- Background Caching Variables
local castCooldown = 0
local activeRipples = {}
local activeAuraMobs = {}
local lastBackgroundCacheTime = 0

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
local dodgeRetreatDistance = 25 -- Horizontal distance to retreat away from attacking mob
local dodgeWalkSpeed = 26 -- Sprint speed when running away from attack
local originalWalkSpeed = humanoid and humanoid.WalkSpeed or 16
local dodgeDetectionRadius = 15
local dodgeDetectionRadiusSq = 15 * 15
local dodgeLingerDelay = 0.02
local lastWarningSeenTime = 0
local notifyOnDodge = false
local mobWarningCache = setmetatable({}, { __mode = "k" })

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
local mobAttackOriginPartCache = setmetatable({}, { __mode = "k" })
local mobHumanoidCache = setmetatable({}, { __mode = "k" })
local mobWarningCache = setmetatable({}, { __mode = "k" })
local mobWarningCheckTime = setmetatable({}, { __mode = "k" })
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

local function getFishingSpots()
    local now = os.clock()
    if now - lastFishingSpotsCacheTime > 5 or #cachedFishingSpots == 0 then
        lastFishingSpotsCacheTime = now
        if fishingSpotsFolder and fishingSpotsFolder.Parent then
            cachedFishingSpots = fishingSpotsFolder:GetChildren()
        end
    end
    return cachedFishingSpots
end

local function getSpotPosition(spot)
    local pos = fishingSpotPosCache[spot]
    if pos then return pos end
    pos = spot:IsA("Model") and spot:GetPivot().Position or spot.Position
    fishingSpotPosCache[spot] = pos
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
            if now - timestamp > 10 then
                nodeBlacklist[node] = nil
            end
        end
    end
end

-- ==========================
-- MANATITE CLUSTERS & SEA MAZE HELPERS
-- ==========================
local cachedManatiteFolder = nil
local cachedManatiteModels = {}
local lastManatiteCacheTime = 0

local function getManatiteClustersFolder()
    if cachedManatiteFolder and cachedManatiteFolder.Parent then
        return cachedManatiteFolder
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
                    cachedManatiteFolder = clusters
                    return clusters
                end
            end
        end
    end

    -- Fallback: Search workspace for "ManatiteClusters"
    local clusters = workspace:FindFirstChild("ManatiteClusters", true)
    if clusters then
        cachedManatiteFolder = clusters
        return clusters
    end

    return nil
end

local function getManatiteModels()
    local now = os.clock()
    local folder = getManatiteClustersFolder()
    if folder and (now - lastManatiteCacheTime > 2 or #cachedManatiteModels == 0) then
        lastManatiteCacheTime = now
        cachedManatiteModels = folder:GetChildren()
    end
    return cachedManatiteModels
end

local function getGrazeTarget(model)
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

local function isGrazeTargetAvailable(target, model)
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
        return (attr == true or attr == "true" or attr == 1)
    end

    return true
end

local function getManatitePayload(modelName)
    local cached = manatitePayloadCache[modelName]
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

    manatitePayloadCache[modelName] = payload
    return payload
end

local function cleanupManatiteBlacklist(now)
    if now - lastManatiteBlacklistCleanup > 10 then
        lastManatiteBlacklistCleanup = now
        for model, timestamp in pairs(manatiteBlacklist) do
            if now - timestamp > 20 then
                manatiteBlacklist[model] = nil
            end
        end
    end
end

local function findNextAvailableManatite(searchOrigin)
    local models = getManatiteModels()
    if not models or #models == 0 then return nil, nil end

    local now = os.clock()
    local origin = searchOrigin or (root and root.Position) or Vector3.zero

    if manatiteOrder == "Alphabetical (A-Z)" then
        local availableList = {}
        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = manatiteBlacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local target = getGrazeTarget(model)
                    if target and isGrazeTargetAvailable(target, model) then
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
    else
        local bestModel = nil
        local bestTarget = nil
        local shortestDistSq = math.huge

        for _, model in ipairs(models) do
            if model.Parent then
                local blacklistedAt = manatiteBlacklist[model]
                if not blacklistedAt or (now - blacklistedAt > 20) then
                    local target = getGrazeTarget(model)
                    if target and isGrazeTargetAvailable(target, model) then
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

local function teleportToManatite(grazeTarget, model)
    if not root or not char or not grazeTarget or not grazeTarget.Parent then return end

    local targetPos = grazeTarget.Position + Vector3.new(0, manatiteHeightOffset, 0)
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

    if manatiteAnchorChomp then
        pcall(function() root.Anchored = true end)
    end
end

-- Gets the cached attacking part (Head for snakes, CavernBodyVisual for spiders)
local function getMobAttackOriginPart(mob)
    if not mob then return nil end
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

-- Validates whether a mob is physically alive (O(1) checks, zero GetDescendants)
local function isMobAlive(mob)
    if not mob or not mob.Parent then return false end

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
    if checkPart and checkPart.Parent then
        return checkPart.Transparency < 0.9
    end

    if mob:IsA("BasePart") then
        return mob.Transparency < 0.9
    elseif mob:IsA("Model") then
        local primary = mob.PrimaryPart
        if primary then
            return primary.Transparency < 0.9
        end
        for _, part in ipairs(mob:GetChildren()) do
            if part:IsA("BasePart") then
                return part.Transparency < 0.9
            end
        end
    end

    return false
end

-- Finds CavernAttackWarning with weak caching and 0.5s throttled retries
local function findAttackWarning(mob)
    if not mob or not mob.Parent then return nil end

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

-- Zero-allocation background caching for ripples and Aura Mobs (Snakes & Spiders)
local function cacheBackgroundElements()
    local cWorld = cowWorldRef and cowWorldRef.Parent and cowWorldRef or workspace:FindFirstChild("CowWorld")

    -- 1. Cache Water Ripples (Only if auto-fishing is enabled)
    if autoFish then
        table.clear(activeRipples)
        local searchRoot = cWorld or workspace
        for _, v in ipairs(searchRoot:GetDescendants()) do
            if string.find(v.Name, "CowFishingWaterRipples", 1, true) then
                table.insert(activeRipples, v)
            end
        end
    else
        if #activeRipples > 0 then
            table.clear(activeRipples)
        end
    end

    -- 2. Cache Aura Mobs (Snakes & Spiders) strictly under their clearings
    if autoChompMobs or autoDodgeMobs then
        table.clear(activeAuraMobs)
        local resources = getResourcesFolder()

        if resources then
            for _, clearing in ipairs(resources:GetChildren()) do
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
    else
        if #activeAuraMobs > 0 then
            table.clear(activeAuraMobs)
        end
    end
end

local ripplePosCache = setmetatable({}, { __mode = "k" })
local function getRipplePosition(ripple)
    local pos = ripplePosCache[ripple]
    if pos then return pos end
    pos = ripple:IsA("Model") and ripple:GetPivot().Position or (ripple:IsA("BasePart") and ripple.Position)
    if pos then
        ripplePosCache[ripple] = pos
    end
    return pos
end

local function isSpotAvailable(spot)
    local spotPos = getSpotPosition(spot)

    for _, ripple in ipairs(activeRipples) do
        if ripple.Parent then
            local ripplePos = getRipplePosition(ripple)

            if ripplePos then
                -- 5 studs squared = 25 (zero allocation 3D check)
                if get3DDistanceSq(spotPos, ripplePos) <= 25 then
                    local surfaceGui = ripple:FindFirstChild("FishingWaterSurface")
                    if surfaceGui and surfaceGui.Enabled then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function updatePenVisualizer()
    if showPenESP and farmOn and anchorPos then
        if not penVisualizer then
            penVisualizer = Instance.new("Part")
            penVisualizer.Name = "CowPenESP"
            penVisualizer.Anchored = true
            penVisualizer.CanCollide = false
            penVisualizer.Shape = Enum.PartType.Cylinder
            penVisualizer.Material = Enum.Material.Neon
            penVisualizer.Color = Color3.fromRGB(255, 105, 180)
            penVisualizer.Transparency = 0.85
            penVisualizer.CastShadow = false
            penVisualizer.Parent = workspace
        end
        penVisualizer.Size = Vector3.new(0.5, farmRadius * 2, farmRadius * 2)
        penVisualizer.CFrame = CFrame.new(anchorPos) * CFrame.Angles(0, 0, math.rad(90))
    else
        if penVisualizer then
            penVisualizer:Destroy()
            penVisualizer = nil
        end
    end
end

-- Cleanup single-chest ESP instances
local function cleanupChestVisuals()
    if chestEspConnection then
        chestEspConnection:Disconnect()
        chestEspConnection = nil
    end
    if chestHighlight then
        chestHighlight:Destroy()
        chestHighlight = nil
    end
    if chestBillboard then
        chestBillboard:Destroy()
        chestBillboard = nil
    end
end

-- Attach ESP to a loaded chest model/part
local function attachChestESP(trackedChest)
    cleanupChestVisuals()
    if not trackedChest or not trackedChest.Parent then return end

    local chestPart = trackedChest:IsA("Model") and (trackedChest.PrimaryPart or trackedChest:FindFirstChildWhichIsA("BasePart")) or (trackedChest:IsA("BasePart") and trackedChest)
    if not chestPart then return end

    chestHighlight = Instance.new("Highlight")
    chestHighlight.Name = "ChestHighlight"
    chestHighlight.Adornee = trackedChest
    chestHighlight.FillColor = Color3.fromRGB(255, 215, 0)
    chestHighlight.FillTransparency = 0.5
    chestHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    chestHighlight.OutlineTransparency = 0
    chestHighlight.Parent = trackedChest

    chestBillboard = Instance.new("BillboardGui")
    chestBillboard.Name = "ChestESPText"
    chestBillboard.Adornee = chestPart
    chestBillboard.Size = UDim2.new(0, 150, 0, 50)
    chestBillboard.StudsOffset = Vector3.new(0, 3, 0)
    chestBillboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "Team Chest"
    textLabel.Parent = chestBillboard

    chestBillboard.Parent = trackedChest

    local lastDist = -1
    local lastChestUpdate = 0
    chestEspConnection = RunService.Heartbeat:Connect(function()
        if not showChestESP or not trackedChest or not trackedChest.Parent then
            cleanupChestVisuals()
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
local function updateChestESP()
    if showChestESP then
        local currentChest = workspace:FindFirstChild("LocalTeamChest")
        if currentChest then
            attachChestESP(currentChest)
        end

        if not chestChildAddedConn then
            chestChildAddedConn = workspace.ChildAdded:Connect(function(child)
                if child.Name == "LocalTeamChest" and showChestESP then
                    task.wait(0.1)
                    attachChestESP(child)
                end
            end)
        end

        if not chestChildRemovedConn then
            chestChildRemovedConn = workspace.ChildRemoved:Connect(function(child)
                if child.Name == "LocalTeamChest" then
                    cleanupChestVisuals()
                end
            end)
        end
    else
        if chestChildAddedConn then
            chestChildAddedConn:Disconnect()
            chestChildAddedConn = nil
        end
        if chestChildRemovedConn then
            chestChildRemovedConn:Disconnect()
            chestChildRemovedConn = nil
        end
        cleanupChestVisuals()
    end
end

-- ==========================
-- MANATITE ESP VISUALIZER
-- ==========================
local function cleanupManatiteVisuals()
    if manatiteEspConnection then
        manatiteEspConnection:Disconnect()
        manatiteEspConnection = nil
    end
    for model, visual in pairs(manatiteVisuals) do
        if visual.highlight then pcall(function() visual.highlight:Destroy() end) end
        if visual.billboard then pcall(function() visual.billboard:Destroy() end) end
    end
    table.clear(manatiteVisuals)
end

local function updateManatiteESP()
    if showManatiteESP then
        if not manatiteEspConnection then
            local lastEspUpdate = 0
            manatiteEspConnection = RunService.Heartbeat:Connect(function()
                if not showManatiteESP then
                    cleanupManatiteVisuals()
                    return
                end
                local now = os.clock()
                if now - lastEspUpdate > 0.4 then
                    lastEspUpdate = now
                    local models = getManatiteModels()
                    for _, model in ipairs(models) do
                        if model.Parent then
                            local target = getGrazeTarget(model)
                            if target then
                                local available = isGrazeTargetAvailable(target, model)
                                local visual = manatiteVisuals[model]
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
                                    manatiteVisuals[model] = visual
                                end

                                if visual.highlight and visual.label then
                                    if available then
                                        visual.highlight.FillColor = Color3.fromRGB(0, 220, 255)
                                        visual.label.TextColor3 = Color3.fromRGB(0, 255, 200)
                                        visual.label.Text = "💎 " .. model.Name .. "\n[AVAILABLE]"
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
        cleanupManatiteVisuals()
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
-- MAIN ENGINE HEARTBEAT LOOP
-- ==========================
local function updateHeartbeatConnection()
    if farmOn or autoChomp or autoFish or autoChompMobs or autoDodgeMobs or autoManatite then
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
                    currentManatiteModel = nil
                    currentGrazeTarget = nil
                    currentManatitePayload = nil
                    return
                end

                local now = os.clock()
                local rootPos = root.Position

                -- Targeted background caches refresh
                if (autoFish or autoChompMobs or autoDodgeMobs) and (now - lastBackgroundCacheTime > 1.5) then
                    lastBackgroundCacheTime = now
                    task.spawn(cacheBackgroundElements)
                end

                -- Weak blacklist sweep
                cleanupNodeBlacklist(now)

                -- 0. Priority Mob Attack Warning & Dodge Logic (Run Away & Surface Retreat)
                if autoDodgeMobs then
                    local attackingMobFound = false
                    local attackingMobInstance = nil

                    -- If already dodging, keep tracking the mob that caused the dodge
                    if isDodging and currentAttackingMob and currentAttackingMob.Parent and isMobAlive(currentAttackingMob) then
                        local warning = findAttackWarning(currentAttackingMob)
                        if isWarningActive(warning, currentAttackingMob) then
                            attackingMobFound = true
                            attackingMobInstance = currentAttackingMob
                        end
                    end

                    -- If not already locked onto an active warning, scan activeAuraMobs
                    if not attackingMobFound then
                        local checkOrigin = (isDodging and preDodgePos) or (isUnderground and lastSurfacePos) or rootPos
                        for _, mob in ipairs(activeAuraMobs) do
                            if mob.Parent then
                                local mobPos = getMobAttackOrigin(mob)
                                if mobPos and get2DDistanceSq(checkOrigin, mobPos) <= dodgeDetectionRadiusSq then
                                    if isMobAlive(mob) then
                                        local warning = findAttackWarning(mob)
                                        if isWarningActive(warning, mob) then
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

                    if attackingMobFound and attackingMobInstance then
                        lastWarningSeenTime = now

                        -- Calculate horizontal retreat direction directly away from the attacking mob
                        local attackOrigin = getMobAttackOrigin(attackingMobInstance) or (preDodgePos or rootPos)
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

                        if not isDodging then
                            isDodging = true
                            preDodgePos = rootPos
                            preDodgeCFrame = root.CFrame
                            if humanoid then
                                originalWalkSpeed = humanoid.WalkSpeed
                            end

                            if dodgeMethod == "Run Away (Surface)" then
                                if humanoid then
                                    humanoid.WalkSpeed = dodgeWalkSpeed
                                end
                                root.Anchored = false
                            elseif dodgeMethod == "Teleport Away (Surface)" then
                                local retreatOffset = away2D * dodgeRetreatDistance
                                local retreatTarget = preDodgePos + retreatOffset
                                local rayHit = workspace:Raycast(retreatTarget + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0), raycastParams)
                                local groundY = rayHit and (rayHit.Position.Y + 3) or preDodgePos.Y
                                local targetCFrame = CFrame.new(Vector3.new(retreatTarget.X, groundY, retreatTarget.Z)) * preDodgeCFrame.Rotation
                                char:PivotTo(targetCFrame)
                                root.CFrame = targetCFrame
                                root.Anchored = false
                            elseif dodgeMethod == "Underground" then
                                isUnderground = true
                                lastSurfaceCFrame = root.CFrame
                                lastSurfacePos = rootPos

                                local retreatOffset = away2D * dodgeRetreatDistance
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
                                local methodDesc = (dodgeMethod == "Run Away (Surface)" and "Running away " .. tostring(dodgeRetreatDistance) .. " studs.")
                                    or (dodgeMethod == "Teleport Away (Surface)" and "Teleported " .. tostring(dodgeRetreatDistance) .. " studs away.")
                                    or "Retreated underground."
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
                        -- No active warning seen this frame: check if currently dodging
                        if isDodging then
                            if (now - lastWarningSeenTime) >= dodgeLingerDelay then
                                -- Safe! Attack has completely ended
                                if dodgeMethod == "Underground" and isUnderground then
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
                                else
                                    -- Surface / Run Away cleanup
                                    if humanoid then
                                        humanoid.WalkSpeed = originalWalkSpeed or 16
                                        if not farmOn then
                                            humanoid:Move(Vector3.zero, false)
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
                    isDodging = false
                    currentAttackingMob = nil
                    preDodgePos = nil
                    preDodgeCFrame = nil
                end

                -- 1. Movement Logic
                if farmOn and not autoManatite and anchorPos and not isDodging and not isUnderground then
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

                -- 2. Priority Mob Aura Logic
                if autoChompMobs then
                    local auraOrigin = isUnderground and (lastSurfacePos or rootPos) or rootPos
                    for _, mob in ipairs(activeAuraMobs) do
                        if mob.Parent then
                            local mobPos = getMobAttackOrigin(mob)
                            -- Distance check FIRST before any alive/descendant validation (hardcoded 10 studs)
                            if mobPos and get3DDistanceSq(auraOrigin, mobPos) <= MOB_AURA_RADIUS_SQ then
                                if isMobAlive(mob) then
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
                                        break
                                    end
                                end
                            end
                        end
                    end
                end

                -- 3. Raycast Grass Chomp Logic (Yields to Mobs & Dodging)
                if autoChomp and not autoManatite and not prioritizedMobThisFrame and not isUnderground and not isDodging then
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
                if autoFish and not autoManatite and fishingEvent then
                    if now - castCooldown > 3 then
                        local nearestSpot = nil
                        local shortestDistSq = 2500 -- 50 studs squared
                        local fishingSpots = getFishingSpots()

                        for _, spot in ipairs(fishingSpots) do
                            if spot.Parent then
                                local spotPos = getSpotPosition(spot)
                                local distSq = get2DDistanceSq(rootPos, spotPos)

                                if distSq < shortestDistSq and isSpotAvailable(spot) then
                                    shortestDistSq = distSq
                                    nearestSpot = spot
                                end
                            end
                        end

                        if nearestSpot then
                            fishingEvent:FireServer("Cast", nearestSpot)
                            castCooldown = now
                        end
                    end
                end

                -- 5. Manatite Farm Logic (Sea Maze Teleport & Autochomp)
                if autoManatite and not isUnderground and not isDodging then
                    cleanupManatiteBlacklist(now)

                    local targetValid = currentManatiteModel
                        and currentGrazeTarget
                        and currentManatiteModel.Parent
                        and currentGrazeTarget.Parent
                        and isGrazeTargetAvailable(currentGrazeTarget, currentManatiteModel)
                        and (now - currentManatiteStartTime <= 15)

                    if not targetValid then
                        if currentManatiteModel and (now - currentManatiteStartTime > 15) then
                            manatiteBlacklist[currentManatiteModel] = now
                        end

                        currentManatiteModel = nil
                        currentGrazeTarget = nil
                        currentManatitePayload = nil

                        if manatiteAnchorChomp and root then
                            pcall(function() root.Anchored = false end)
                        end

                        if (now - lastManatiteSearchTime > 0.1) then
                            lastManatiteSearchTime = now
                            local nextModel, nextTarget = findNextAvailableManatite(rootPos)
                            if nextModel and nextTarget then
                                currentManatiteModel = nextModel
                                currentGrazeTarget = nextTarget
                                currentManatitePayload = getManatitePayload(nextModel.Name)
                                currentManatiteStartTime = now
                                teleportToManatite(nextTarget, nextModel)
                                lastManatiteTeleportTime = now
                                lastManatiteChompTime = 0
                            end
                        end
                    else
                        local targetPos = currentGrazeTarget.Position + Vector3.new(0, manatiteHeightOffset, 0)

                        if get3DDistanceSq(rootPos, targetPos) > 36 then
                            if (now - lastManatiteTeleportTime > 0.4) then
                                teleportToManatite(currentGrazeTarget, currentManatiteModel)
                                lastManatiteTeleportTime = now
                            end
                        else
                            if manatiteAnchorChomp and not root.Anchored then
                                pcall(function() root.Anchored = true end)
                            end
                        end

                        if (now - lastManatiteChompTime >= manatiteChompDelay) then
                            lastManatiteChompTime = now
                            chompEvent:FireServer(currentManatitePayload)
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
        if not autoManatite and manatiteAnchorChomp and root then
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

        updatePenVisualizer()
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
    Name = "Enable Manatite Farm (Sea Maze)",
    CurrentValue = false,
    Flag = "Toggle_ManatiteFarm",
    Callback = function(Value)
        autoManatite = Value
        if Value then
            if root then
                preManatiteCFrame = root.CFrame
            end
            currentManatiteModel = nil
            currentGrazeTarget = nil
            currentManatitePayload = nil
            lastManatiteSearchTime = 0

            Window:Notify({
                Title = "Manatite Farm Enabled",
                Content = "Teleporting to Sea Maze Manatite clusters & chomping...",
                Duration = 3,
                Image = 4483362458,
            })
        else
            if manatiteAnchorChomp and root then
                pcall(function() root.Anchored = false end)
            end
            if returnOnDisable and preManatiteCFrame and root and char then
                char:PivotTo(preManatiteCFrame)
                root.CFrame = preManatiteCFrame
                for _, part in ipairs(charBaseParts) do
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            currentManatiteModel = nil
            currentGrazeTarget = nil
            currentManatitePayload = nil
        end
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

MainTab:CreateSection({ Name = "Manatite Farm Configuration" })

MainTab:CreateDropdown({
    Name = "Cluster Selection Order",
    Options = {"Nearest Available", "Alphabetical (A-Z)"},
    CurrentOption = {"Nearest Available"},
    MultipleOptions = false,
    Flag = "Dropdown_ManatiteOrder",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Alphabetical (A-Z)" then
            manatiteOrder = "Alphabetical (A-Z)"
        else
            manatiteOrder = "Nearest Available"
        end
    end,
})

MainTab:CreateSlider({
    Name = "Manatite Chomp Delay",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "Slider_ManatiteDelay",
    Callback = function(Value)
        manatiteChompDelay = Value
    end,
})

MainTab:CreateSlider({
    Name = "Teleport Height Offset",
    Range = {0, 8},
    Increment = 0.5,
    Suffix = "Studs",
    CurrentValue = 2.5,
    Flag = "Slider_ManatiteHeight",
    Callback = function(Value)
        manatiteHeightOffset = Value
    end,
})

MainTab:CreateToggle({
    Name = "Anchor Root While Chomping",
    CurrentValue = false,
    Flag = "Toggle_ManatiteAnchor",
    Callback = function(Value)
        manatiteAnchorChomp = Value
        if not Value and root and not isUnderground then
            pcall(function() root.Anchored = false end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Return to Pre-Farm Pos on Disable",
    CurrentValue = false,
    Flag = "Toggle_ManatiteReturn",
    Callback = function(Value)
        returnOnDisable = Value
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
    Range = {0.01, 2.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.02,
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

MainTab:CreateSection({ Name = "Visuals / ESP" })

MainTab:CreateToggle({
    Name = "Show Pen Boundary (ESP)",
    CurrentValue = false,
    Flag = "Toggle_PenESP",
    Callback = function(Value)
        showPenESP = Value
        updatePenVisualizer()
    end,
})

MainTab:CreateToggle({
    Name = "Show Team Chest ESP (Dynamic)",
    CurrentValue = false,
    Flag = "Toggle_ChestESP",
    Callback = function(Value)
        showChestESP = Value
        updateChestESP()
    end,
})

MainTab:CreateToggle({
    Name = "Show Manatite ESP (Sea Maze)",
    CurrentValue = false,
    Flag = "Toggle_ManatiteESP",
    Callback = function(Value)
        showManatiteESP = Value
        updateManatiteESP()
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
        autoDodgeMobs = false
        autoManatite = false
        showManatiteESP = false
        cleanupManatiteVisuals()
        if manatiteAnchorChomp and root then
            pcall(function() root.Anchored = false end)
        end
        currentManatiteModel = nil
        currentGrazeTarget = nil
        currentManatitePayload = nil
        if isUnderground and root and lastSurfaceCFrame then
            root.CFrame = lastSurfaceCFrame + Vector3.new(0, 0.5, 0)
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            isUnderground = false
        end
        if isDodging then
            if humanoid then humanoid.WalkSpeed = originalWalkSpeed or 16 end
            isDodging = false
            currentAttackingMob = nil
        end
        scannerRunning = false
        showPenESP = false
        showChestESP = false
        updatePenVisualizer()
        updateChestESP()

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
