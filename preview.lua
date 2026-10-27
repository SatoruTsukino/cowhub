-- Rayfield Gen2 Autofarm, Manatite Farm, Raycast Grass Chomper, Auto-Fishing & Alive-Only Priority Mob Aura
-- Optimized for high framerates, zero-allocation math, memory safety, and executor stability.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

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
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "CowHubConfig",
        customFolder = "CowHub",
    },
    KeySystem = false
})

local function safeNotify(opts)
    if not Window or not opts then return end
    pcall(function()
        if Window.Notify then
            Window:Notify(opts)
        end
    end)
end

-- ==========================
-- SERVICES & FAST LOCAL APIS
-- ==========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local PathfindingService = game:GetService("PathfindingService")

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
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local char
local root
local humanoid

local function resolveCharacter()
    if plr.Character and plr.Character.Parent then
        return plr.Character
    end
    local cowWorld = workspace:FindFirstChild("CowWorld")
    local dynamic = cowWorld and cowWorld:FindFirstChild("Dynamic")
    local playerCows = dynamic and dynamic:FindFirstChild("PlayerCows")
    local myCow = playerCows and playerCows:FindFirstChild(plr.Name)
    if myCow and myCow.Parent then
        return myCow
    end
    return plr.Character
end

local function resolveRoot(character)
    if not character then return nil end
    if character:IsA("BasePart") then return character end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp end
    if character.PrimaryPart and character.PrimaryPart:IsA("BasePart") then
        return character.PrimaryPart
    end
    for _, name in ipairs({"HumanoidRootPart", "RootPart", "Torso", "UpperTorso", "CowRoot", "Body", "Head"}) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    local anyBasePart = character:FindFirstChildWhichIsA("BasePart")
    if anyBasePart then return anyBasePart end
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("BasePart") then return desc end
    end
    return nil
end

local function resolveHumanoid(character)
    if not character then return nil end
    local hum = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid")
    if hum and hum:IsA("Humanoid") then return hum end
    return character:FindFirstChildWhichIsA("Humanoid")
end

local function getRootPos(targetRoot)
    local r = targetRoot or root
    if not r then
        local c = resolveCharacter()
        r = resolveRoot(c)
        if r then root = r end
    end
    if not r then return nil end
    if r:IsA("BasePart") then
        return r.Position
    elseif r:IsA("Model") then
        local prim = r.PrimaryPart
        if prim and prim:IsA("BasePart") then return prim.Position end
        local pivot = r:GetPivot()
        return pivot.Position
    end
    return nil
end

local function getRootCFrame(targetRoot)
    local r = targetRoot or root
    if not r then
        local c = resolveCharacter()
        r = resolveRoot(c)
        if r then root = r end
    end
    if not r then return nil end
    if r:IsA("BasePart") then
        return r.CFrame
    elseif r:IsA("Model") then
        local prim = r.PrimaryPart
        if prim and prim:IsA("BasePart") then return prim.CFrame end
        return r:GetPivot()
    end
    return nil
end

local function setRootCFrame(cf, targetRoot)
    local r = targetRoot or root
    if not r or not cf then return end
    if r:IsA("BasePart") then
        r.CFrame = cf
    elseif r:IsA("Model") then
        r:PivotTo(cf)
    end
end

char = resolveCharacter()
if not char or not char.Parent then
    char = plr.CharacterAdded:Wait()
end

root = resolveRoot(char)
if not root then
    local waited = char:WaitForChild("HumanoidRootPart", 2)
    if waited and waited:IsA("BasePart") then
        root = waited
    else
        root = resolveRoot(char)
    end
end

humanoid = resolveHumanoid(char)
if not humanoid then
    local waited = char:WaitForChild("Humanoid", 2)
    if waited and waited:IsA("Humanoid") then
        humanoid = waited
    end
end

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
local trickOrTreatEvent = cowRemotes:FindFirstChild("TrickOrTreatRequest")

-- Pre-configured Raycast Parameters (Zero allocation per frame)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {char}

local wallRaycastParams = RaycastParams.new()
wallRaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local ELEVATED_OFFSET = Vector3.new(0, 1.2, 0)
local LOW_OFFSET = Vector3.new(0, 0.6, 0)
local HIGH_OFFSET = Vector3.new(0, 2.0, 0)
local JUMP_OFFSET = Vector3.new(0, 3.8, 0)

local function updateWallRaycastFilter()
    local filter = {}
    if char then
        table.insert(filter, char)
    end
    local gFolder = (cache and cache.grassFolder) or workspace:FindFirstChild("CowVirtualGrass")
    if gFolder and gFolder.Parent then
        table.insert(filter, gFolder)
    end
    wallRaycastParams.FilterDescendantsInstances = filter
end
updateWallRaycastFilter()

local manatite
local mithril
local trickOrTreat
local updateHeartbeatConnection

local charConn = plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = resolveRoot(newChar)
    if not root then
        task.spawn(function()
            local waited = newChar:WaitForChild("HumanoidRootPart", 2)
            if waited and waited:IsA("BasePart") then
                root = waited
            else
                root = resolveRoot(newChar)
            end
        end)
    end
    humanoid = resolveHumanoid(newChar)
    if not humanoid then
        task.spawn(function()
            local waited = newChar:WaitForChild("Humanoid", 2)
            if waited and waited:IsA("Humanoid") then
                humanoid = waited
                if dodge and (dodge.originalWalkSpeed == nil or dodge.originalWalkSpeed == 16) then
                    dodge.originalWalkSpeed = humanoid.WalkSpeed
                end
                humanoid.Died:Connect(function()
                    if rafting and rafting.onSessionEnded and (rafting.isSailing or (rafting.status and rafting.status ~= "Idle")) then
                        rafting.onSessionEnded("Player died. Automated rafting stopped.")
                    end
                end)
            end
        end)
    end
    if humanoid and dodge and (dodge.originalWalkSpeed == nil or dodge.originalWalkSpeed == 16) then
        dodge.originalWalkSpeed = humanoid.WalkSpeed
    end
    if humanoid then
        humanoid.Died:Connect(function()
            if rafting and rafting.onSessionEnded and (rafting.isSailing or (rafting.status and rafting.status ~= "Idle")) then
                rafting.onSessionEnded("Player died. Automated rafting stopped.")
            end
        end)
    end
    if rafting and rafting.onSessionEnded and (rafting.isSailing or (rafting.status and rafting.status ~= "Idle")) then
        rafting.onSessionEnded("Character respawned. Automated rafting stopped.")
    end
    raycastParams.FilterDescendantsInstances = {char}
    updateWallRaycastFilter()
    updateCharBaseParts(newChar)
    if dodge then
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
    end
    if aerial then
        aerial.active = false
        aerial.cframe = nil
        aerial.preCFrame = nil
        aerial.startTime = 0
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
    if trickOrTreat then
        trickOrTreat.isCycling = false
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
    grassChompDelay = 0.4, -- Server intended minimum is 0.4s (Config.Grass.MinimumChewCooldown); speeds < 0.4s fire faster than server intends (unsafe)
    grassChompRepeatDelay = 0.6,
    chompOnlyWhileMoving = true,
    lastChompedMob = "",
    mobChompCooldown = 0,
    castCooldown = 0,
    lastFishingSearchTime = 0,
    collisionDetection = true,
    lastStuckCheckPos = nil,
    lastStuckCheckTime = 0,
    stuckCounter = 0,
    isUnsticking = false,
    unstickTargetPos = nil,
    unstickEndTime = 0,
    currentNodeStartTime = 0,
    lastNodeSearchTime = 0,
    onlyMatureGrass = true,
    goldenAura = false,
    goldenAuraRadius = 60,
    lastGoldenAuraTime = 0,
}

local dodge = {
    auto = false,
    method = "Teleport Away (Surface)", -- "Underground", "Run Away (Surface)", "Teleport Away (Surface)"
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
    nodeIDs = setmetatable({}, { __mode = "k" }),
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
    solidObstacle = setmetatable({}, { __mode = "k" }),
    isEPressed = false,
    lastBackgroundTime = 0,
    isCachingBackground = false,
    lastSanitationTime = 0,
}
updateWallRaycastFilter()

local auction = {
    lotNames = {"Lot1", "Lot2", "Lot3", "Lot4"},
    previousSignatures = {},
    scannerRunning = false,
    connections = {},
    isChecking = false,
    cards = {},
    customBidAmounts = {},
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

local townAuction = {
    remote = nil,
    fitoutModel = nil,
    slots = {
        "Global1",
        "Global2",
        "Server2",
        "Server3",
        "BuyNow",
        "BuyNow2",
        "Player1",
        "Player2"
    },
    slotCategories = {
        Global1 = "Global Auction",
        Global2 = "Global Auction",
        Server2 = "Server Auction",
        Server3 = "Server Auction",
        BuyNow = "Buy Now Store",
        BuyNow2 = "Buy Now Store",
        Player1 = "Player Consignment",
        Player2 = "Player Consignment"
    },
    snapshot = nil,
    lastSnapshotTime = 0,
    snapshotTimestamp = 0,
    serverNow = 0,
    balance = 0,
    currency = "MooBucks",
    taxBasisPoints = 1000,
    deliveryHeld = 0,
    held = 0,
    lotsBySlot = {},
    ownedCopies = {},
    cards = {},
    customBidAmounts = {},
    infoCard = nil,
    isFetching = false,
    autoRefresh = false,
    autoRefreshInterval = 5,
    connections = {},
    autoBidConnections = {},
    autoBidAll = false,
    autoBidActive = {
        Global1 = false,
        Global2 = false,
        Server2 = false,
        Server3 = false,
        BuyNow = false,
        BuyNow2 = false,
        Player1 = false,
        Player2 = false,
    },
    maxAutoBidLimit = 0,
    isAutoBiddingSlot = {},
    lastAutoBidTime = {},
    autoBidLoopRunning = true,
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

-- ==========================
-- MAP & ASSET OPTIMIZER (Anti-Lag, Potato Mode & Streaming Watcher)
-- ==========================
local mapOptimizer = {
    enabled = false,
    autoCleanStreamed = true,
    removeTextures = true,
    disableShadows = true,
    disableParticles = true,
    optimizeTerrain = true,
    descendantConnection = nil,
    preloaded = false,
    lastPreloadTime = 0,
}

function mapOptimizer.optimizeInstance(inst)
    if not inst then return end
    pcall(function()
        if inst:IsA("BasePart") then
            if mapOptimizer.disableShadows then
                inst.CastShadow = false
            end
            if mapOptimizer.removeTextures then
                inst.Material = Enum.Material.SmoothPlastic
                inst.Reflectance = 0
            end
        elseif inst:IsA("Decal") or inst:IsA("Texture") then
            if mapOptimizer.removeTextures then
                inst.Transparency = 1
            end
        elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Beam") then
            if mapOptimizer.disableParticles then
                inst.Enabled = false
            end
        elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
            if mapOptimizer.disableShadows then
                inst.Shadows = false
            end
        elseif inst:IsA("PostEffect") then
            if mapOptimizer.disableParticles then
                inst.Enabled = false
            end
        elseif inst:IsA("Highlight") then
            if inst.Name ~= "ManatiteHighlight" and inst.Name ~= "MithrilHighlight" then
                inst.Enabled = false
            end
        end
    end)
end

function mapOptimizer.applyLighting()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") then
                child.Enabled = false
            end
        end
    end)
    pcall(function()
        if settings and settings().Rendering then
            settings().Rendering.QualityLevel = 1
        end
    end)
end

function mapOptimizer.applyTerrain()
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain") or workspace.Terrain
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            if sethiddenproperty then
                pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
            end
        end
    end)
end

function mapOptimizer.applyToWorld()
    mapOptimizer.applyLighting()
    mapOptimizer.applyTerrain()

    task.spawn(function()
        local descendants = workspace:GetDescendants()
        local batch = 350
        for i, inst in ipairs(descendants) do
            if not mapOptimizer.enabled then break end
            mapOptimizer.optimizeInstance(inst)
            if i % batch == 0 then
                task.wait()
            end
        end
    end)
end

function mapOptimizer.startStreamHook()
    if not mapOptimizer.descendantConnection then
        mapOptimizer.descendantConnection = workspace.DescendantAdded:Connect(function(inst)
            if mapOptimizer.enabled and mapOptimizer.autoCleanStreamed then
                mapOptimizer.optimizeInstance(inst)
            end
        end)
        table.insert(scriptConnections, mapOptimizer.descendantConnection)
    end
end

function mapOptimizer.stopStreamHook()
    if mapOptimizer.descendantConnection then
        pcall(function() mapOptimizer.descendantConnection:Disconnect() end)
        mapOptimizer.descendantConnection = nil
    end
end

function mapOptimizer.preloadAssets()
    local now = os.clock()
    if now - mapOptimizer.lastPreloadTime < 8 then return end
    mapOptimizer.lastPreloadTime = now

    task.spawn(function()
        local toPreload = {}
        local pGui = plr and plr:FindFirstChildOfClass("PlayerGui")
        if pGui then table.insert(toPreload, pGui) end

        local cowGame = ReplicatedStorage:FindFirstChild("CowGame")
        if cowGame then table.insert(toPreload, cowGame) end

        pcall(function()
            ContentProvider:PreloadAsync(toPreload)
        end)
        mapOptimizer.preloaded = true
    end)
end

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
    lastFolderSearch = 0,
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
    lastFolderSearch = 0,
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

-- ==========================
-- TRICK OR TREAT AUTOFARM (HALLOWEEN EVENT)
-- ==========================
trickOrTreat = {
    auto = false,
    autoDismissRewardGui = true,
    autoAcceptRewards = true,
    isCycling = false,
    isSingleRun = false,
    returnOnFinish = true,
    returnHeightOffset = 4.0, -- Vertical offset (studs) above previous position to prevent spawning under map
    pauseFarmDuringCycle = true,
    anchorDuringKnock = true,
    savedPreCFrame = nil,
    currentHouseInteracting = nil,
    completedHouseNames = {},
    erroredHouseNames = {},
    houseRetryAttempts = {},
    isRetryPass = false,
    maxHouseRetries = 2,
    barnPosition = Vector3.new(-523, 702, 171),
    barnLoadDelay = 2.5,
    settleDelay = 0.3,
    houseWaitTime = 1.4,
    disableInsideCollision = true, -- Disables collision for Inside / Interior parts of houses
    approachOrigin = "Inside House", -- "Inside House" (teleports deep inside, stops before door) or "Outside Porch"
    walkUpEnabled = true,   -- Walk up towards the door from inside so game registers walking
    walkDistance = 11.0,    -- Starting distance inside the house (farther away from door)
    walkTimeout = 1.5,      -- Max time (seconds) to walk up to the door
    doorDistance = 2.0,     -- Stop distance (studs before door inside house - does NOT exit)
    doorHeightOffset = 0.0, -- Vertical fine-tuning offset inside the house
    cycleCooldown = 600, -- Default 10 minutes (auto-detected from HalloweenConfig or server)
    detectedCooldown = nil,
    autoDetectCooldown = true,
    nextCycleTime = 0,
    lastCycleCompletedTime = 0,
    housesVisitedCount = 0,
    lastHouseName = "",
    statusText = "Idle",
    remote = nil,
    loopRunning = false,
    clientEventConn = nil,
    statusCard = nil,
    infoCard = nil,
    telemetryCard = nil,
    cachedHousesFolder = nil,
    lastDeepSearch = 0,
    -- Live Script Telemetry
    totalCycles = 0,
    totalHousesKnocked = 0,
    totalRewardsDismissed = 0,
    currentPhase = "Idle",
    currentHouseIndex = 0,
    totalHousesInCycle = 0,
    currentHouseDistance = 0,
    sessionStartTime = 0,
    cycleStartTime = 0,
    lastCycleDuration = 0,
    lastKnockTime = 0,
    longestDetectedCooldown = 0,
    houseCooldowns = {},
}

local function stopCharacterVelocity()
    pcall(function()
        if root and root:IsA("BasePart") then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    for _, part in ipairs(charBaseParts) do
        if part and part.Parent and part:IsA("BasePart") then
            pcall(function()
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end

local function safeReturnToSavedPosition(savedCF)
    if not savedCF then return end
    local baseCF = savedCF
    if typeof(baseCF) == "Vector3" then
        baseCF = CFrame.new(baseCF)
    elseif typeof(baseCF) ~= "CFrame" then
        return
    end

    if not char or not char.Parent then
        char = resolveCharacter()
    end
    if not root or not root.Parent or not root:IsA("BasePart") then
        root = resolveRoot(char)
    end
    if not root or not char then return end

    local heightOffset = trickOrTreat.returnHeightOffset or 4.0
    local targetCF = baseCF + Vector3.new(0, heightOffset, 0)

    -- Terrain raycast check to ensure player does not spawn underneath ground
    pcall(function()
        local rayOrigin = targetCF.Position + Vector3.new(0, 10, 0)
        local rayDir = Vector3.new(0, -25, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}
        local hit = workspace:Raycast(rayOrigin, rayDir, rayParams)
        if hit and hit.Position then
            local groundY = hit.Position.Y + heightOffset
            if groundY > targetCF.Position.Y then
                targetCF = CFrame.new(targetCF.Position.X, groundY, targetCF.Position.Z) * targetCF.Rotation
            end
        end
    end)

    pcall(function()
        root.Anchored = true
        char:PivotTo(targetCF)
        setRootCFrame(targetCF)
        stopCharacterVelocity()
    end)
    task.wait(0.15)
    pcall(function()
        if root and root:IsA("BasePart") then
            root.Anchored = false
        end
        stopCharacterVelocity()
    end)
end

function trickOrTreat.getTelemetry()
    local now = os.clock()
    local cdRemaining = math.max(0, math.ceil(trickOrTreat.nextCycleTime - now))
    local sessionSecs = trickOrTreat.sessionStartTime > 0 and math.floor(now - trickOrTreat.sessionStartTime) or 0
    local cycleSecs = trickOrTreat.isCycling and trickOrTreat.cycleStartTime > 0 and math.floor(now - trickOrTreat.cycleStartTime) or (trickOrTreat.lastCycleDuration or 0)
    local rPos = root and getRootPos(root)
    return {
        enabled = trickOrTreat.auto == true,
        isCycling = trickOrTreat.isCycling == true,
        isSingleRun = trickOrTreat.isSingleRun == true,
        isRetryPass = trickOrTreat.isRetryPass == true,
        status = trickOrTreat.statusText or "Idle",
        phase = trickOrTreat.currentPhase or "Idle",
        totalCycles = trickOrTreat.totalCycles or 0,
        totalHousesKnocked = trickOrTreat.totalHousesKnocked or 0,
        totalRewardsDismissed = trickOrTreat.totalRewardsDismissed or 0,
        lastCycleHouses = trickOrTreat.housesVisitedCount or 0,
        lastCycleDuration = trickOrTreat.lastCycleDuration or 0,
        currentCycleElapsed = cycleSecs,
        currentHouseIndex = trickOrTreat.currentHouseIndex or 0,
        totalHousesInCycle = trickOrTreat.totalHousesInCycle or 0,
        currentHouseName = trickOrTreat.lastHouseName or "",
        currentHouseDistance = trickOrTreat.currentHouseDistance or 0,
        cooldownRemaining = cdRemaining,
        cycleCooldown = trickOrTreat.cycleCooldown or 600,
        autoDetectCooldown = trickOrTreat.autoDetectCooldown == true,
        sessionUptime = sessionSecs,
        position = rPos and { X = rPos.X, Y = rPos.Y, Z = rPos.Z } or nil,
    }
end

function trickOrTreat.detectCooldown()
    if not trickOrTreat.autoDetectCooldown then
        return nil
    end
    local detected = nil
    pcall(function()
        local shared = cowGame and cowGame:FindFirstChild("Shared")
        if shared then
            local hwConfigMod = shared:FindFirstChild("HalloweenConfig")
            if hwConfigMod then
                local hw = require(hwConfigMod)
                if type(hw) == "table" and type(hw.TrickOrTreat) == "table" then
                    local tot = hw.TrickOrTreat
                    for _, k in ipairs({"CycleCooldown", "CycleSeconds", "CooldownSeconds", "Cooldown"}) do
                        if type(tot[k]) == "number" and tot[k] >= 60 then
                            detected = tot[k]
                            break
                        end
                    end
                end
            end
            if not detected then
                local hwRulesMod = shared:FindFirstChild("HalloweenQuestRules")
                if hwRulesMod then
                    local rules = require(hwRulesMod)
                    if type(rules) == "table" then
                        for _, k in ipairs({"CycleCooldown", "CycleSeconds", "CooldownSeconds", "Cooldown"}) do
                            if type(rules[k]) == "number" and rules[k] >= 60 then
                                detected = rules[k]
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    if detected and detected >= 60 then
        trickOrTreat.detectedCooldown = detected
        trickOrTreat.cycleCooldown = detected
        if trickOrTreat.lastCycleCompletedTime > 0 and not trickOrTreat.isCycling then
            local now = os.clock()
            local targetNext = trickOrTreat.lastCycleCompletedTime + detected
            if targetNext > now then
                trickOrTreat.nextCycleTime = targetNext
            end
        end
    end
    return detected
end

local KNOWN_HOUSE_NAMES = {
    "AppleOrchard_House1",
    "CloverCreek_House1",
    "CloverCreek_House2",
    "FishermansForest_House1",
    "FishermansForest_House2",
    "FishermansForest_FishermansHouse",
    "GoldenHill_House1",
    "HomeMeadow_House1",
    "HomeMeadow_House2",
    "MountainsideMeadow_House1",
    "SouthPastures_House1",
}
trickOrTreat.KNOWN_HOUSE_NAMES = KNOWN_HOUSE_NAMES

local HOUSE_WAYPOINTS = {
    AppleOrchard_House1 = Vector3.new(-185, 703, -425),
    CloverCreek_House1 = Vector3.new(100, 705, 1150),
    CloverCreek_House2 = Vector3.new(150, 705, 1250),
    FishermansForest_House1 = Vector3.new(-580, 703, 100),
    FishermansForest_House2 = Vector3.new(-460, 703, 160),
    FishermansForest_FishermansHouse = Vector3.new(-650, 702, 20),
    GoldenHill_House1 = Vector3.new(-10, 702, 40),
    HomeMeadow_House1 = Vector3.new(-320, 702, 50),
    HomeMeadow_House2 = Vector3.new(-270, 702, 80),
    MountainsideMeadow_House1 = Vector3.new(300, 750, 400),
    SouthPastures_House1 = Vector3.new(-100, 705, 1066),
}
trickOrTreat.HOUSE_WAYPOINTS = HOUSE_WAYPOINTS

function trickOrTreat.findHouse(houseName)
    if not houseName or houseName == "" then return nil end
    local folder = trickOrTreat.getHousesFolder()
    if folder then
        local h = folder:FindFirstChild(houseName)
        if h then return h end
    end
    local cowWorld = cache.cowWorldRef
    if not cowWorld or not cowWorld.Parent then
        cowWorld = workspace:FindFirstChild("CowWorld")
        cache.cowWorldRef = cowWorld
    end
    if cowWorld then
        local geom = cowWorld:FindFirstChild("Geometry")
        if geom then
            local h = geom:FindFirstChild(houseName, true)
            if h then return h end
        end
        local h = cowWorld:FindFirstChild(houseName, true)
        if h then return h end
    end
    return workspace:FindFirstChild(houseName, true)
end

function trickOrTreat.getHousesFolder()
    if trickOrTreat.cachedHousesFolder and trickOrTreat.cachedHousesFolder.Parent then
        return trickOrTreat.cachedHousesFolder
    end

    local cowWorld = cache.cowWorldRef
    if not cowWorld or not cowWorld.Parent then
        cowWorld = workspace:FindFirstChild("CowWorld")
        cache.cowWorldRef = cowWorld
    end

    -- 1. Direct path: workspace.CowWorld.Geometry.FarmerHouses (O(1))
    if cowWorld then
        local geometry = cowWorld:FindFirstChild("Geometry")
        if geometry then
            local fh = geometry:FindFirstChild("FarmerHouses") or geometry:FindFirstChild("Houses")
            if fh then
                trickOrTreat.cachedHousesFolder = fh
                return fh
            end
        end
        local fhDirect = cowWorld:FindFirstChild("FarmerHouses") or cowWorld:FindFirstChild("Houses")
        if fhDirect then
            trickOrTreat.cachedHousesFolder = fhDirect
            return fhDirect
        end
    end

    -- 2. Direct top-level check (O(1))
    local topFh = workspace:FindFirstChild("FarmerHouses") or workspace:FindFirstChild("Houses")
    if topFh then
        trickOrTreat.cachedHousesFolder = topFh
        return topFh
    end

    return nil
end

function trickOrTreat.getHouseList()
    local seen = {}
    local list = {}

    local function addCandidate(obj)
        if not obj or not (obj:IsA("Model") or obj:IsA("Folder")) then return end
        if seen[obj] or seen[obj.Name] then return end
        local n = obj.Name
        local nLower = n:lower()
        if string.match(n, "^%w+_[Hh]ouse%d*$") or string.find(nLower, "house") or string.find(nLower, "farmer") then
            seen[obj] = true
            seen[obj.Name] = true
            table.insert(list, obj)
        end
    end

    -- 1. Scan dedicated folder if found
    local folder = trickOrTreat.getHousesFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            addCandidate(child)
        end
    end

    -- 2. Scan CowWorld.Geometry and regional subfolders
    local cowWorld = cache.cowWorldRef
    if not cowWorld or not cowWorld.Parent then
        cowWorld = workspace:FindFirstChild("CowWorld")
        cache.cowWorldRef = cowWorld
    end

    local geometry = cowWorld and cowWorld:FindFirstChild("Geometry")
    if geometry then
        for _, child in ipairs(geometry:GetChildren()) do
            addCandidate(child)
            if child:IsA("Folder") or child:IsA("Model") then
                for _, subChild in ipairs(child:GetChildren()) do
                    addCandidate(subChild)
                end
            end
        end
    end

    -- 3. Direct lookup for any missing known houses
    if #list < #KNOWN_HOUSE_NAMES then
        for _, name in ipairs(KNOWN_HOUSE_NAMES) do
            if not seen[name] then
                local found = nil
                if geometry then
                    found = geometry:FindFirstChild(name, true)
                end
                if not found and cowWorld then
                    found = cowWorld:FindFirstChild(name, true)
                end
                if not found then
                    found = workspace:FindFirstChild(name, true)
                end
                if found then
                    addCandidate(found)
                end
            end
        end
    end

    table.sort(list, function(a, b) return a.Name < b.Name end)
    return list
end

local function resolveHousePart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
        return obj.PrimaryPart
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
end

function trickOrTreat.getDoorPart(houseModel)
    if not houseModel then return nil end
    local door = houseModel:FindFirstChild("Door", true)
    local part = resolveHousePart(door)
    if part then return part end
    local threshold = houseModel:FindFirstChild("Threshold", true)
    part = resolveHousePart(threshold)
    if part then return part end
    return nil
end

function trickOrTreat.getInsidePart(houseModel)
    if not houseModel then return nil end
    local inside = houseModel:FindFirstChild("Inside", true)
    local part = resolveHousePart(inside)
    if part then return part end

    local interior = houseModel:FindFirstChild("Interior", true)
    part = resolveHousePart(interior)
    if part then return part end

    local doorPart = trickOrTreat.getDoorPart(houseModel)
    if doorPart then return doorPart end

    local exit = houseModel:FindFirstChild("Exit", true)
    part = resolveHousePart(exit)
    if part then return part end

    if houseModel.PrimaryPart then return houseModel.PrimaryPart end
    return houseModel:FindFirstChildWhichIsA("BasePart", true)
end

function trickOrTreat.setHouseCollision(houseModel, canCollide)
    if not houseModel then return end
    for _, name in ipairs({"Inside", "Interior"}) do
        local part = houseModel:FindFirstChild(name, true)
        if part and part:IsA("BasePart") then
            local n = part.Name:lower()
            if not n:find("floor") and not n:find("ground") and not n:find("base") and not n:find("stair") and not n:find("porch") then
                pcall(function() part.CanCollide = canCollide end)
            end
        end
    end
end

function trickOrTreat.fireDoorPrompt(houseTarget)
    local firedAny = false
    local houseModel = (typeof(houseTarget) == "Instance" and houseTarget) or nil
    local houseName = (houseModel and houseModel.Name) or (type(houseTarget) == "string" and houseTarget) or ""

    -- 1. Fire any ProximityPrompt instances found in the house model
    if houseModel then
        pcall(function()
            for _, prompt in ipairs(houseModel:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    firedAny = true
                    if fireproximityprompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    else
                        pcall(function()
                            prompt:InputHoldBegin()
                            task.wait(0.04)
                            prompt:InputHoldEnd()
                        end)
                    end
                end
            end
        end)
    end

    -- 1b. Fallback: Search workspace near player (within 15 studs) for active prompts
    pcall(function()
        local rPos = root and root:IsA("BasePart") and root.Position
        if rPos then
            local pFolder = trickOrTreat.getHousesFolder() or workspace
            for _, desc in ipairs(pFolder:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    local pPart = desc.Parent
                    if pPart and pPart:IsA("BasePart") then
                        if (pPart.Position - rPos).Magnitude <= 15 then
                            firedAny = true
                            if fireproximityprompt then
                                pcall(function() fireproximityprompt(desc) end)
                            else
                                pcall(function()
                                    desc:InputHoldBegin()
                                    task.wait(0.04)
                                    desc:InputHoldEnd()
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- 2. Fire TrickOrTreatSign button in PlayerGui (decompiled client controller)
    local pg = plr and plr:FindFirstChild("PlayerGui")
    if pg then
        for _, sign in ipairs(pg:GetChildren()) do
            if sign.Name == "TrickOrTreatSign" and sign:IsA("BillboardGui") and sign.Enabled then
                local knockBtn = sign:FindFirstChild("Knock", true)
                if knockBtn and knockBtn:IsA("GuiButton") then
                    firedAny = true
                    if firesignal then
                        pcall(function() firesignal(knockBtn.Activated) end)
                    end
                    pcall(function()
                        if successVIM and VirtualInput and VirtualInput.SendMouseButtonEvent then
                            local abs = knockBtn.AbsolutePosition + (knockBtn.AbsoluteSize * 0.5)
                            VirtualInput:SendMouseButtonEvent(abs.X, abs.Y, 0, true, game, 1)
                            task.wait(0.03)
                            VirtualInput:SendMouseButtonEvent(abs.X, abs.Y, 0, false, game, 1)
                        end
                    end)
                end
            end
        end
    end

    -- 3. Fire server remote TrickOrTreatRequest
    local remote = trickOrTreat.getRemote()
    if remote and houseName ~= "" then
        pcall(function()
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer("Knock", houseName)
            else
                remote:FireServer("Knock", houseName)
            end
        end)
        firedAny = true
    end

    -- 4. Simulate virtual 'E' key press for ContextActionService binding
    pcall(function()
        if successVIM and VirtualInput and VirtualInput.SendKeyEvent then
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown("0x65")
            task.wait(0.05)
            VirtualUser:SetKeyUp("0x65")
        end
    end)

    return firedAny
end

function trickOrTreat.getTargetCFrame(houseTarget)
    if not houseTarget then return nil end
    local houseModel = (typeof(houseTarget) == "Instance" and houseTarget) or nil
    local houseName = (houseModel and houseModel.Name) or (type(houseTarget) == "string" and houseTarget) or ""
    if not houseModel and houseName ~= "" then
        houseModel = trickOrTreat.findHouse(houseName)
    end

    local thresholdPart, doorPart, exitPart, insidePart = nil, nil, nil, nil
    if houseModel then
        local threshold = houseModel:FindFirstChild("Threshold", true)
        thresholdPart = resolveHousePart(threshold)

        local door = houseModel:FindFirstChild("Door", true)
        doorPart = resolveHousePart(door)

        local exit = houseModel:FindFirstChild("Exit", true)
        exitPart = resolveHousePart(exit)

        local inside = houseModel:FindFirstChild("Inside", true) or houseModel:FindFirstChild("Interior", true)
        insidePart = resolveHousePart(inside)
    end

    -- Determine door / entrance reference point (prefer thresholdPart for exact KnockRange detection)
    local doorRef = thresholdPart or doorPart or exitPart or insidePart or (houseModel and (houseModel.PrimaryPart or houseModel:FindFirstChildWhichIsA("BasePart", true)))
    if not doorRef then
        local wp = HOUSE_WAYPOINTS[houseName]
        if wp then
            local knockPos = wp
            local knockCF = CFrame.new(wp)
            return knockCF, knockPos, knockCF
        end
        return nil
    end

    local doorPos = doorRef.Position

    -- Determine outward vector (pointing outside away from interior into porch/walkway)
    local outward = nil

    if exitPart and thresholdPart then
        local diff = exitPart.Position - thresholdPart.Position
        local flat = Vector3.new(diff.X, 0, diff.Z)
        if flat.Magnitude > 0.2 then
            outward = flat.Unit
        end
    end

    if not outward and thresholdPart and insidePart then
        local diff = thresholdPart.Position - insidePart.Position
        local flat = Vector3.new(diff.X, 0, diff.Z)
        if flat.Magnitude > 0.2 then
            outward = flat.Unit
        end
    end

    if not outward and doorPart and insidePart then
        local diff = doorPart.Position - insidePart.Position
        local flat = Vector3.new(diff.X, 0, diff.Z)
        if flat.Magnitude > 0.2 then
            outward = flat.Unit
        end
    end

    if not outward and doorPart then
        local lv = doorPart.CFrame.LookVector
        local flatLV = Vector3.new(lv.X, 0, lv.Z)
        if flatLV.Magnitude > 0.1 then
            outward = flatLV.Unit
            if insidePart then
                local toInside = insidePart.Position - doorPart.Position
                if outward:Dot(toInside) > 0 then
                    outward = -outward
                end
            end
        end
    end

    if not outward then
        outward = Vector3.new(0, 0, 1)
    end

    local isInsideApproach = (trickOrTreat.approachOrigin ~= "Outside Porch")
    local doorDist = math.max(0.5, trickOrTreat.doorDistance or 2.0)
    local walkDist = math.max(doorDist + 2.0, trickOrTreat.walkDistance or 11.0)

    local knockX, knockZ, appX, appZ

    if isInsideApproach then
        -- INSIDE APPROACH:
        -- Teleports inside the house, walks towards the door, stops before front door
        knockX = doorPos.X - (outward.X * doorDist)
        knockZ = doorPos.Z - (outward.Z * doorDist)

        appX = doorPos.X - (outward.X * walkDist)
        appZ = doorPos.Z - (outward.Z * walkDist)
    else
        -- OUTSIDE APPROACH:
        -- Spawns outside on porch/walkway, walks towards the door
        knockX = doorPos.X + (outward.X * doorDist)
        knockZ = doorPos.Z + (outward.Z * doorDist)

        local totalDist = doorDist + walkDist
        appX = doorPos.X + (outward.X * totalDist)
        appZ = doorPos.Z + (outward.Z * totalDist)
    end

    -- Determine base floor height at the doorway (hip height: +2.5 studs)
    local baseFloorY = nil
    if thresholdPart then
        baseFloorY = thresholdPart.Position.Y + 2.5
    elseif doorPart then
        baseFloorY = doorPart.Position.Y - (doorPart.Size.Y * 0.5) + 2.5
    elseif insidePart and isInsideApproach then
        baseFloorY = insidePart.Position.Y - (insidePart.Size.Y * 0.5) + 2.5
    elseif insidePart then
        baseFloorY = insidePart.Position.Y + 2.5
    else
        baseFloorY = doorPos.Y + 2.5
    end

    local rayParams = RaycastParams.new()
    local filter = char and {char} or {}
    if insidePart then table.insert(filter, insidePart) end
    if houseModel then
        -- Exclude roof, ceiling, and interior zone boundaries so raycast never hits the roof!
        pcall(function()
            for _, part in ipairs(houseModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    local pName = part.Name:lower()
                    if pName:find("roof") or pName:find("ceiling") or pName:find("chimney") or pName:find("eave") or pName == "inside" or pName == "interior" then
                        table.insert(filter, part)
                    end
                end
            end
        end)
    end
    pcall(function()
        rayParams.FilterDescendantsInstances = filter
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
    end)

    -- Raycast downward from chest height (baseFloorY + 1.0) so it's always underneath roof/ceiling
    local knockFloorY = nil
    pcall(function()
        local rayResult = workspace:Raycast(Vector3.new(knockX, baseFloorY + 1.0, knockZ), Vector3.new(0, -8, 0), rayParams)
        if rayResult then
            knockFloorY = rayResult.Position.Y + 2.5
        end
    end)
    if not knockFloorY then
        knockFloorY = baseFloorY
    end
    knockFloorY = knockFloorY + (trickOrTreat.doorHeightOffset or 0.0)

    local knockPos = Vector3.new(knockX, knockFloorY, knockZ)
    local knockLookTarget = Vector3.new(doorPos.X, knockFloorY, doorPos.Z)
    local knockCF
    if (knockPos - knockLookTarget).Magnitude > 0.1 then
        knockCF = CFrame.lookAt(knockPos, knockLookTarget)
    else
        knockCF = CFrame.new(knockPos)
    end

    -- 2. Approach start position for walking up
    if trickOrTreat.walkUpEnabled and (trickOrTreat.walkDistance or 0) > 0 then
        local appFloorY = nil
        pcall(function()
            local appRay = workspace:Raycast(Vector3.new(appX, baseFloorY + 1.0, appZ), Vector3.new(0, -8, 0), rayParams)
            if appRay then
                appFloorY = appRay.Position.Y + 2.5
            end
        end)
        if not appFloorY then
            appFloorY = knockFloorY
        end
        appFloorY = appFloorY + (trickOrTreat.doorHeightOffset or 0.0)

        local approachPos = Vector3.new(appX, appFloorY, appZ)
        local appLookTarget = Vector3.new(doorPos.X, appFloorY, doorPos.Z)
        local approachCF
        if (approachPos - appLookTarget).Magnitude > 0.1 then
            approachCF = CFrame.lookAt(approachPos, appLookTarget)
        else
            approachCF = knockCF
        end
        return approachCF, knockPos, knockCF
    end

    return knockCF, knockPos, knockCF
end

function trickOrTreat.getRemote()
    if trickOrTreat.remote and trickOrTreat.remote.Parent then
        return trickOrTreat.remote
    end
    local remote = nil
    if cowRemotes then
        remote = cowRemotes:FindFirstChild("TrickOrTreatRequest")
    end
    if not remote then
        pcall(function()
            remote = ReplicatedStorage:WaitForChild("CowGame", 2):WaitForChild("Remotes", 2):WaitForChild("TrickOrTreatRequest", 2)
        end)
    end
    trickOrTreat.remote = remote
    return remote
end

function trickOrTreat.initClientListener()
    if trickOrTreat.clientEventConn then return end
    pcall(function()
        local clientEvent = cowRemotes and cowRemotes:FindFirstChild("ClientEvent")
        if not clientEvent then
            clientEvent = cowRemotes:WaitForChild("ClientEvent", 3)
        end
        if clientEvent and clientEvent:IsA("RemoteEvent") then
            trickOrTreat.clientEventConn = clientEvent.OnClientEvent:Connect(function(eventName, payload)
                if eventName == "TrickOrTreat" and type(payload) == "table" then
                    if payload.Kind == "Refused" and tostring(payload.Reason) == "Cooldown" and type(payload.Wait) == "number" then
                        local waitSecs = math.ceil(payload.Wait)
                        local houseName = tostring(payload.House or payload.HouseName or trickOrTreat.lastHouseName or "")
                        if houseName ~= "" then
                            trickOrTreat.houseCooldowns[houseName] = os.clock() + waitSecs
                        end

                        if waitSecs >= 10 then
                            trickOrTreat.longestDetectedCooldown = math.max(trickOrTreat.longestDetectedCooldown or 0, waitSecs)
                            if trickOrTreat.autoDetectCooldown then
                                -- Strict requirement: Only schedule at the end of the LONGEST cooldown!
                                trickOrTreat.detectedCooldown = trickOrTreat.longestDetectedCooldown
                                trickOrTreat.cycleCooldown = math.max(trickOrTreat.cycleCooldown or 600, trickOrTreat.longestDetectedCooldown)
                                trickOrTreat.nextCycleTime = math.max(trickOrTreat.nextCycleTime, os.clock() + trickOrTreat.longestDetectedCooldown)
                            else
                                trickOrTreat.nextCycleTime = math.max(trickOrTreat.nextCycleTime, os.clock() + waitSecs)
                            end
                            trickOrTreat.updateStatusUI()
                        end
                    end
                end
            end)
        end
    end)
end

function trickOrTreat.dismissRewardGui(force)
    if not force and trickOrTreat.autoDismissRewardGui == false and trickOrTreat.autoAcceptRewards == false then return false end
    local p = plr or Players.LocalPlayer or localPlayer
    local pg = nil
    pcall(function() pg = p and p:FindFirstChildWhichIsA("PlayerGui") end)
    if not pg then return false end
    local dismissed = false
    local vi = VirtualInput

    -- 1. Targeted dismissal for known reward / reveal modal ScreenGuis
    local targetGuiNames = {
        "RewardBoxReveal", "HalloweenReward", "TrickOrTreatReward", "CandyReveal",
        "EventReward", "CowFavoriteReward", "FavoriteRewardPrompt", "QuestModal",
        "TrickOrTreatModal", "TreatReveal", "CandyPailReveal"
    }
    for _, tName in ipairs(targetGuiNames) do
        local rGui = nil
        pcall(function() rGui = pg:FindFirstChild(tName) end)
        local isTargetActive = false
        pcall(function()
            if rGui and rGui:IsA("ScreenGui") and rGui.Enabled then
                isTargetActive = true
            end
        end)
        if isTargetActive then
            local descs = nil
            pcall(function() descs = rGui:GetDescendants() end)
            if descs then
                for _, desc in ipairs(descs) do
                    pcall(function()
                        if desc:IsA("GuiButton") and desc.Visible then
                            local dName = desc.Name:lower()
                            local dText = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                            if dName == "primary" or dName == "secondary" or dName == "wearit" or dName == "keepraiding" or dName == "notnow"
                                or dName:find("close") or dName:find("done") or dName:find("claim") or dName:find("accept") or dName:find("okay")
                                or dText == "done" or dText:find("done") or dText:find("open another") or dText:find("wear") or dText:find("keep")
                                or dText:find("not now") or dText:find("close") or dText:find("claim") or dText:find("accept") or dText:find("okay")
                                or dText == "ok" or dText:find("thank") or dText:find("sweet") or dText:find("treat") then
                                if firesignal then
                                    pcall(function() firesignal(desc.Activated) end)
                                    pcall(function() firesignal(desc.MouseButton1Click) end)
                                end
                                if getconnections then
                                    pcall(function()
                                        for _, c in ipairs(getconnections(desc.Activated)) do
                                            if c.Function then pcall(c.Function) end
                                        end
                                        for _, c in ipairs(getconnections(desc.MouseButton1Click)) do
                                            if c.Function then pcall(c.Function) end
                                        end
                                    end)
                                end
                                if vi and vi.SendMouseButtonEvent then
                                    pcall(function()
                                        local abs = desc.AbsolutePosition + (desc.AbsoluteSize * 0.5)
                                        vi:SendMouseButtonEvent(abs.X, abs.Y, 0, true, game, 1)
                                        task.wait(0.04)
                                        vi:SendMouseButtonEvent(abs.X, abs.Y, 0, false, game, 1)
                                    end)
                                end
                                dismissed = true
                            end
                        end
                    end)
                end
            end
            if vi and vi.SendKeyEvent then
                pcall(function()
                    vi:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                    task.wait(0.05)
                    vi:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                end)
            end
            pcall(function() rGui.Enabled = false end)
            dismissed = true
        end
    end

    -- 2. General recursive search across all active ScreenGuis and BillboardGuis
    local children = nil
    pcall(function() children = pg:GetChildren() end)
    if children then
        for _, gui in ipairs(children) do
            local canCheck = false
            local gName = ""
            pcall(function()
                if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                    gName = gui.Name:lower()
                    if not gName:find("rayfield") and not gName:find("cowhub") and not gName:find("fjordraftinghud") and gName ~= "trickortreatsign" then
                        canCheck = true
                    end
                end
            end)
            if canCheck then
                local descs = nil
                pcall(function() descs = gui:GetDescendants() end)
                if descs then
                    for _, desc in ipairs(descs) do
                        pcall(function()
                            if desc:IsA("GuiButton") and desc.Visible then
                                local name = desc.Name:lower()
                                local text = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                                local attrLabel = desc:GetAttribute("AccessibilityLabel")
                                local labelText = (typeof(attrLabel) == "string" and attrLabel:lower()) or ""

                                local isRewardBtn = name == "primary" or name == "secondary" or name == "wearit" or name == "keepraiding" or name == "notnow"
                                    or name:find("accept") or name:find("okay") or name == "ok" or name:find("claim") or name:find("confirm") or name:find("close") or name:find("dismiss") or name:find("done")
                                    or text == "done" or text:find("done") or text:find("accept") or text:find("okay") or text == "ok" or text:find("claim") or text:find("confirm") or text:find("close") or text:find("great")
                                    or text:find("open another") or text:find("wear it") or text:find("keep raiding") or text:find("keep knocking") or text:find("not now") or text:find("thank you") or text:find("sweet") or text:find("treat")
                                    or labelText:find("done") or labelText:find("close") or labelText:find("accept") or labelText:find("okay")

                                if isRewardBtn then
                                    if firesignal then
                                        pcall(function() firesignal(desc.Activated) end)
                                        pcall(function() firesignal(desc.MouseButton1Click) end)
                                    end
                                    if getconnections then
                                        pcall(function()
                                            for _, c in ipairs(getconnections(desc.Activated)) do
                                                if c.Function then pcall(c.Function) end
                                            end
                                            for _, c in ipairs(getconnections(desc.MouseButton1Click)) do
                                                if c.Function then pcall(c.Function) end
                                            end
                                        end)
                                    end
                                    if vi and vi.SendMouseButtonEvent then
                                        pcall(function()
                                            local abs = desc.AbsolutePosition + (desc.AbsoluteSize * 0.5)
                                            vi:SendMouseButtonEvent(abs.X, abs.Y, 0, true, game, 1)
                                            task.wait(0.04)
                                            vi:SendMouseButtonEvent(abs.X, abs.Y, 0, false, game, 1)
                                        end)
                                    end
                                    dismissed = true
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    if dismissed then
        trickOrTreat.totalRewardsDismissed = (trickOrTreat.totalRewardsDismissed or 0) + 1
        if vi and vi.SendKeyEvent then
            pcall(function()
                vi:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                task.wait(0.04)
                vi:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
            end)
        end
    end

    return dismissed
end

function trickOrTreat.pollRewardGuiUntilDismissed(timeoutSecs, force)
    if not force and trickOrTreat.autoDismissRewardGui == false and trickOrTreat.autoAcceptRewards == false then return end
    timeoutSecs = timeoutSecs or 4.0
    task.spawn(function()
        local startTime = os.clock()
        while (os.clock() - startTime) < timeoutSecs do
            if not force and trickOrTreat.autoDismissRewardGui == false and trickOrTreat.autoAcceptRewards == false then break end
            local dismissed = trickOrTreat.dismissRewardGui(force)
            if dismissed then
                task.wait(0.25)
                if not trickOrTreat.dismissRewardGui(force) then
                    break
                end
            end
            task.wait(0.15)
        end
    end)
end

function trickOrTreat.updateStatusUI()
    if not trickOrTreat.statusCard and not trickOrTreat.infoCard and not trickOrTreat.telemetryCard then return end
    local now = os.clock()
    local cdRemaining = math.max(0, math.ceil(trickOrTreat.nextCycleTime - now))
    local cdMin = math.floor(trickOrTreat.cycleCooldown / 60)
    local cdSec = math.floor(trickOrTreat.cycleCooldown % 60)
    local modeStr = trickOrTreat.autoDetectCooldown and "Auto" or "Manual"

    -- 1. Status Card Update (Live Phase, House Progress, Countdown)
    if trickOrTreat.statusCard then
        local statusTitle = "Status: " .. trickOrTreat.statusText
        local statusBody = ""

        if trickOrTreat.isCycling then
            local cur = trickOrTreat.currentHouseIndex or 0
            local tot = trickOrTreat.totalHousesInCycle or 0
            local pct = tot > 0 and math.floor((cur / tot) * 100) or 0
            local cycleSecs = trickOrTreat.cycleStartTime > 0 and math.floor(now - trickOrTreat.cycleStartTime) or 0
            local cM = math.floor(cycleSecs / 60)
            local cS = math.floor(cycleSecs % 60)
            local distStr = (trickOrTreat.currentHouseDistance and trickOrTreat.currentHouseDistance > 0)
                and string.format(" | Dist: %.1f studs", trickOrTreat.currentHouseDistance)
                or ""
            statusBody = string.format("Phase: %s | House: %s\nCycle Progress: [%d/%d] (%d%%)%s\nCycle Elapsed: %02d:%02d",
                trickOrTreat.currentPhase or "Cycling",
                trickOrTreat.lastHouseName ~= "" and trickOrTreat.lastHouseName or "N/A",
                cur, tot, pct,
                distStr,
                cM, cS
            )
        elseif trickOrTreat.auto then
            if cdRemaining > 0 then
                local m = math.floor(cdRemaining / 60)
                local s = math.floor(cdRemaining % 60)
                statusBody = string.format("Next cycle in: %02d:%02d\nAuto-repeating when ready.", m, s)
            else
                statusBody = "Ready! Starting next cycle shortly..."
            end
        else
            statusBody = "Autofarm is currently OFF."
        end

        pcall(function()
            if trickOrTreat.statusCard.SetTitle then
                trickOrTreat.statusCard:SetTitle(statusTitle)
                trickOrTreat.statusCard:Set(statusBody)
            elseif trickOrTreat.statusCard.Set then
                trickOrTreat.statusCard:Set({ Title = statusTitle, Content = statusBody })
            end
        end)
    end

    -- 2. Script Telemetry Card Update (Session Stats, Uptime, Pace, Position)
    local telemCard = trickOrTreat.telemetryCard or trickOrTreat.infoCard
    if telemCard then
        local sessionSecs = trickOrTreat.sessionStartTime > 0 and math.floor(now - trickOrTreat.sessionStartTime) or 0
        local sH = math.floor(sessionSecs / 3600)
        local sM = math.floor((sessionSecs % 3600) / 60)
        local sS = math.floor(sessionSecs % 60)
        local uptimeStr = sH > 0 and string.format("%d:%02d:%02d", sH, sM, sS) or string.format("%02d:%02d", sM, sS)

        local avgHouses = (trickOrTreat.totalCycles and trickOrTreat.totalCycles > 0)
            and string.format("%.1f", trickOrTreat.totalHousesKnocked / trickOrTreat.totalCycles)
            or tostring(trickOrTreat.housesVisitedCount or 0)

        local posStr = "N/A"
        if root and root:IsA("BasePart") then
            local p = root.Position
            posStr = string.format("X:%d Y:%d Z:%d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
        end

        local telemTitle = string.format("Script Telemetry | Cycles: %d | Knocked: %d", trickOrTreat.totalCycles or 0, trickOrTreat.totalHousesKnocked or 0)
        local telemBody = string.format(
            "Uptime: %s | Total Cycles: %d | Total Knocked: %d\n" ..
            "Rewards Dismissed: %d | Avg/Cycle: %s | Last Duration: %.1fs\n" ..
            "Cooldown: %d:%02d (%s) | Pos: %s",
            uptimeStr,
            trickOrTreat.totalCycles or 0,
            trickOrTreat.totalHousesKnocked or 0,
            trickOrTreat.totalRewardsDismissed or 0,
            avgHouses,
            trickOrTreat.lastCycleDuration or 0,
            cdMin, cdSec, modeStr,
            posStr
        )

        pcall(function()
            if telemCard.SetTitle then
                telemCard:SetTitle(telemTitle)
                telemCard:Set(telemBody)
            elseif telemCard.Set then
                telemCard:Set({ Title = telemTitle, Content = telemBody })
            end
        end)
    end
end

function trickOrTreat.visitHouse(houseTarget, i, totalHouses)
    if not houseTarget then return false, "House target is nil" end
    local houseName = (typeof(houseTarget) == "Instance" and houseTarget.Name) or tostring(houseTarget)
    local house = (typeof(houseTarget) == "Instance" and houseTarget:IsDescendantOf(workspace) and houseTarget) or trickOrTreat.findHouse(houseName)

    -- In Roblox StreamingEnabled, if house is not loaded into workspace, teleport to regional waypoint unanchored to stream chunk
    if not house or not house:IsDescendantOf(workspace) then
        local wp = HOUSE_WAYPOINTS[houseName]
        if wp then
            trickOrTreat.currentPhase = "Streaming House"
            trickOrTreat.statusText = string.format("Streaming [%d/%d]: %s", i, totalHouses, houseName)
            trickOrTreat.updateStatusUI()

            pcall(function()
                root.Anchored = false
                char:PivotTo(CFrame.new(wp))
                setRootCFrame(CFrame.new(wp))
                stopCharacterVelocity()
            end)

            local streamStart = os.clock()
            while (os.clock() - streamStart < 1.5) do
                if not trickOrTreat.auto and not trickOrTreat.isSingleRun then break end
                task.wait(0.1)
                house = trickOrTreat.findHouse(houseName)
                if house and house:IsDescendantOf(workspace) then
                    break
                end
            end
        end
    end

    trickOrTreat.currentHouseInteracting = house or houseTarget

    local approachCF, knockPos, knockCF = nil, nil, nil
    local okTarget, errTarget = pcall(function()
        approachCF, knockPos, knockCF = trickOrTreat.getTargetCFrame(house or houseName)
    end)
    if not okTarget or not approachCF or not knockPos then
        return false, "Failed to resolve target CFrame: " .. tostring(errTarget)
    end

    local originLabel = trickOrTreat.approachOrigin or "Inside House"
    trickOrTreat.currentHouseIndex = i
    trickOrTreat.lastHouseName = houseName
    trickOrTreat.currentPhase = string.format("Approaching (%s)", originLabel)
    trickOrTreat.statusText = string.format("Approaching [%d/%d] (%s): %s", i, totalHouses, originLabel, houseName)
    trickOrTreat.updateStatusUI()

    -- Re-verify character & root
    if not char or not char.Parent then char = resolveCharacter() end
    if not root or not root.Parent then root = resolveRoot(char) end
    if not humanoid or not humanoid.Parent then humanoid = resolveHumanoid(char) end
    if not root or not humanoid or humanoid.Health <= 0 then
        return false, "Player dead or missing character/root"
    end

    -- 1. Disable collision on Inside / Interior boundary box so player doesn't clip/fling
    if house and trickOrTreat.disableInsideCollision then
        pcall(function() trickOrTreat.setHouseCollision(house, false) end)
    end

    -- 2. Teleport to approach start point (inside house or outside porch)
    pcall(function() root.Anchored = false end)
    pcall(function()
        char:PivotTo(approachCF)
        setRootCFrame(approachCF)
        stopCharacterVelocity()
    end)
    task.wait(0.05)

    -- 3. Walk up towards the door so the game registers character movement into KnockRange
    if trickOrTreat.walkUpEnabled and (trickOrTreat.walkDistance or 0) > 0 then
        trickOrTreat.currentPhase = "Walking to Door"
        trickOrTreat.statusText = string.format("Walking to Door [%d/%d]: %s", i, totalHouses, houseName)
        trickOrTreat.updateStatusUI()

        pcall(function() root.Anchored = false end)
        if humanoid then
            pcall(function() humanoid:MoveTo(knockPos) end)
        end

        local walkStart = os.clock()
        local maxWalkTime = trickOrTreat.walkTimeout or 1.8
        while (os.clock() - walkStart < maxWalkTime) do
            if not trickOrTreat.auto and not trickOrTreat.isSingleRun then break end
            if not root or not humanoid or humanoid.Health <= 0 then break end

            local rPos = getRootPos(root)
            if not rPos then break end
            local currentFlat = Vector3.new(rPos.X, 0, rPos.Z)
            local targetFlat = Vector3.new(knockPos.X, 0, knockPos.Z)
            local dist = (currentFlat - targetFlat).Magnitude
            trickOrTreat.currentHouseDistance = math.floor(dist * 10) / 10
            if dist <= 1.2 then
                break
            end
            task.wait(0.04)
        end

        if humanoid then
            pcall(function() humanoid:Move(Vector3.zero, false) end)
        end
        stopCharacterVelocity()
    end

    -- 4. Anchor during knock to prevent being pushed away
    if trickOrTreat.anchorDuringKnock then
        pcall(function() root.Anchored = true end)
    end

    -- 5. Pre-knock settle delay so server and client register arrival
    task.wait(trickOrTreat.settleDelay)

    -- 6. Trigger knock: fire proximity prompts, GUI button, remote & virtual key
    trickOrTreat.currentPhase = "Knocking"
    trickOrTreat.statusText = string.format("Knocking [%d/%d]: %s", i, totalHouses, houseName)
    trickOrTreat.updateStatusUI()

    local promptSuccess, promptErr = pcall(function()
        trickOrTreat.fireDoorPrompt(house or houseName)
    end)
    if not promptSuccess then
        if trickOrTreat.anchorDuringKnock then pcall(function() root.Anchored = false end) end
        if house and trickOrTreat.disableInsideCollision then pcall(function() trickOrTreat.setHouseCollision(house, true) end) end
        trickOrTreat.currentHouseInteracting = nil
        return false, "Prompt error: " .. tostring(promptErr)
    end

    trickOrTreat.totalHousesKnocked = (trickOrTreat.totalHousesKnocked or 0) + 1
    trickOrTreat.lastKnockTime = os.clock()

    -- 7. Wait interaction delay (throttle next knock, respecting NextKnockAt = 1.2s)
    if trickOrTreat.autoDismissRewardGui then
        trickOrTreat.currentPhase = "Dismissing Rewards"
        trickOrTreat.pollRewardGuiUntilDismissed(trickOrTreat.houseWaitTime)
    end
    trickOrTreat.currentPhase = "House Delay"
    task.wait(trickOrTreat.houseWaitTime)

    if trickOrTreat.anchorDuringKnock then
        pcall(function() root.Anchored = false end)
    end
    stopCharacterVelocity()

    -- Restore house collision
    if house and trickOrTreat.disableInsideCollision then
        pcall(function() trickOrTreat.setHouseCollision(house, true) end)
    end

    trickOrTreat.currentHouseInteracting = nil
    return true
end

function trickOrTreat.runCycle()
    if trickOrTreat.isCycling then return end

    -- Re-resolve character, root part, and humanoid if missing or dead
    if not char or not char.Parent then
        char = resolveCharacter()
    end
    if not root or not root.Parent or not root:IsA("BasePart") then
        root = resolveRoot(char)
    end
    if not humanoid or not humanoid.Parent then
        humanoid = resolveHumanoid(char)
    end
    if not root or not char or not humanoid or humanoid.Health <= 0 then
        trickOrTreat.isCycling = false
        trickOrTreat.isSingleRun = false
        trickOrTreat.statusText = "Waiting for character spawn..."
        trickOrTreat.nextCycleTime = os.clock() + 10
        trickOrTreat.updateStatusUI()
        return
    end

    local now = os.clock()
    -- Guard: If automated and cooldown is active, DO NOT TELEPORT!
    if not trickOrTreat.isSingleRun and trickOrTreat.nextCycleTime > now then
        trickOrTreat.updateStatusUI()
        return
    end

    -- Check if village houses are on cooldown before teleporting (unless this is a retry pass or fresh session)
    if not trickOrTreat.isSingleRun and not trickOrTreat.isRetryPass and trickOrTreat.houseCooldowns and (trickOrTreat.lastCycleCompletedTime or 0) > 0 then
        local anyReady = false
        local longestRemaining = 0
        local houseCount = 0
        for _, expiry in pairs(trickOrTreat.houseCooldowns) do
            houseCount = houseCount + 1
            local rem = expiry - now
            if rem <= 0 then
                anyReady = true
            else
                longestRemaining = math.max(longestRemaining, rem)
            end
        end

        -- USER REQUIREMENT: Only teleport at the end of the longest cooldown when autodetect is on
        if trickOrTreat.autoDetectCooldown and longestRemaining > 0 then
            trickOrTreat.nextCycleTime = now + longestRemaining
            trickOrTreat.statusText = string.format("Village on cooldown (%ds left). Waiting.", math.ceil(longestRemaining))
            trickOrTreat.currentPhase = "On Cooldown"
            trickOrTreat.updateStatusUI()
            return
        end

        if houseCount > 0 and not anyReady and longestRemaining > 0 then
            trickOrTreat.nextCycleTime = now + longestRemaining
            trickOrTreat.statusText = string.format("All houses on cooldown (%ds left). Waiting.", math.ceil(longestRemaining))
            trickOrTreat.currentPhase = "On Cooldown"
            trickOrTreat.updateStatusUI()
            return
        end
    end

    if trickOrTreat.sessionStartTime == 0 then
        trickOrTreat.sessionStartTime = os.clock()
    end
    trickOrTreat.cycleStartTime = os.clock()
    trickOrTreat.currentPhase = trickOrTreat.isRetryPass and "Retrying Failed Houses" or "Starting Cycle"
    trickOrTreat.isCycling = true
    trickOrTreat.statusText = trickOrTreat.isRetryPass and "Retrying Failed Houses..." or "Starting Cycle..."
    trickOrTreat.updateStatusUI()

    -- 1. Save original player position BEFORE teleporting to barn for map load
    local preCycleCFrame = getRootCFrame(root)
    trickOrTreat.savedPreCFrame = preCycleCFrame

    local function cleanupCycle()
        pcall(function()
            if root and root:IsA("BasePart") then
                root.Anchored = false
            end
        end)
        if trickOrTreat.currentHouseInteracting and trickOrTreat.disableInsideCollision then
            pcall(function() trickOrTreat.setHouseCollision(trickOrTreat.currentHouseInteracting, true) end)
        end
        trickOrTreat.currentHouseInteracting = nil
        if trickOrTreat.returnOnFinish and preCycleCFrame then
            safeReturnToSavedPosition(preCycleCFrame)
        end
        trickOrTreat.isCycling = false
        trickOrTreat.isSingleRun = false
        trickOrTreat.currentPhase = "Aborted"
        trickOrTreat.currentHouseIndex = 0
        trickOrTreat.currentHouseDistance = 0
    end

    -- 2. If player is outside village area (e.g. grass farming > 400 studs away), shift unanchored to village entry
    local curPos = getRootPos(root)
    if curPos and (curPos - trickOrTreat.barnPosition).Magnitude > 400 then
        trickOrTreat.currentPhase = "Entering Village"
        trickOrTreat.statusText = "Entering Village..."
        trickOrTreat.updateStatusUI()
        pcall(function()
            root.Anchored = false
            char:PivotTo(CFrame.new(trickOrTreat.barnPosition))
            setRootCFrame(CFrame.new(trickOrTreat.barnPosition))
            stopCharacterVelocity()
        end)
        task.wait(0.3)
    end

    local knockedCount = 0

    -- Determine candidate houses:
    -- In Roblox StreamingEnabled, houses across 1200+ studs are not all loaded at once.
    -- We use KNOWN_HOUSE_NAMES and dynamically discover any additional house models.
    local candidateNames = {}
    local seenNames = {}
    for _, name in ipairs(KNOWN_HOUSE_NAMES) do
        table.insert(candidateNames, name)
        seenNames[name] = true
    end
    local scanned = trickOrTreat.getHouseList()
    for _, hObj in ipairs(scanned) do
        if not seenNames[hObj.Name] then
            table.insert(candidateNames, hObj.Name)
            seenNames[hObj.Name] = true
        end
    end

    -- Determine houses to visit:
    -- If retrying from an error, ONLY retry the houses where errors occurred (or uncompleted)!
    local housesToVisit = {}
    if trickOrTreat.isRetryPass then
        for _, hName in ipairs(candidateNames) do
            if trickOrTreat.erroredHouseNames[hName] or not trickOrTreat.completedHouseNames[hName] then
                local attempts = trickOrTreat.houseRetryAttempts[hName] or 0
                if attempts < (trickOrTreat.maxHouseRetries or 2) then
                    table.insert(housesToVisit, hName)
                else
                    warn(string.format("[CowHub TrickOrTreat] House %s exceeded max retries (%d). Skipping this cycle.", hName, attempts))
                    trickOrTreat.erroredHouseNames[hName] = nil
                    trickOrTreat.completedHouseNames[hName] = true
                end
            end
        end
    else
        trickOrTreat.completedHouseNames = {}
        trickOrTreat.erroredHouseNames = {}
        trickOrTreat.houseRetryAttempts = {}
        housesToVisit = candidateNames
    end

    if #housesToVisit == 0 then
        trickOrTreat.isRetryPass = false
        housesToVisit = candidateNames
    end

    -- 3. Cycle through candidate houses
    trickOrTreat.totalHousesInCycle = #housesToVisit
    trickOrTreat.currentHouseIndex = 0
    for i, houseEntry in ipairs(housesToVisit) do
        if not trickOrTreat.auto and not trickOrTreat.isSingleRun then
            break
        end

        local hName = (typeof(houseEntry) == "Instance" and houseEntry.Name) or tostring(houseEntry)

        -- Check health / alive state
        if not humanoid or humanoid.Health <= 0 or not root or not root.Parent then
            warn("[CowHub TrickOrTreat] Player died or lost character during cycle. Pausing.")
            trickOrTreat.erroredHouseNames[hName] = true
            break
        end

        -- Check if this specific house is currently on cooldown:
        local houseExpiry = trickOrTreat.houseCooldowns and trickOrTreat.houseCooldowns[hName]
        if not trickOrTreat.isSingleRun and houseExpiry and houseExpiry > os.clock() then
            local waitLeft = math.ceil(houseExpiry - os.clock())
            trickOrTreat.statusText = string.format("Skipping [%d/%d] %s (%ds cooldown left)", i, #housesToVisit, hName, waitLeft)
            trickOrTreat.updateStatusUI()
            trickOrTreat.completedHouseNames[hName] = true
            trickOrTreat.erroredHouseNames[hName] = nil
        else
            -- Visit house with up to 2 immediate retry attempts
            local success, visitErr = false, nil
            for attempt = 1, 2 do
                success, visitErr = xpcall(function()
                    return trickOrTreat.visitHouse(houseEntry, i, #housesToVisit)
                end, function(e)
                    return debug.traceback(tostring(e), 2)
                end)
                if success then
                    knockedCount = knockedCount + 1
                    trickOrTreat.completedHouseNames[hName] = true
                    trickOrTreat.erroredHouseNames[hName] = nil
                    break
                else
                    warn(string.format("[CowHub TrickOrTreat] House %s error on attempt %d: %s", hName, attempt, tostring(visitErr)))
                    pcall(function()
                        if root and root:IsA("BasePart") then root.Anchored = false end
                        local curH = trickOrTreat.currentHouseInteracting
                        if curH and typeof(curH) == "Instance" and trickOrTreat.disableInsideCollision then
                            trickOrTreat.setHouseCollision(curH, true)
                        end
                    end)
                    task.wait(0.5)
                end
            end

            if not success then
                trickOrTreat.erroredHouseNames[hName] = true
                trickOrTreat.houseRetryAttempts[hName] = (trickOrTreat.houseRetryAttempts[hName] or 0) + 1
            end
        end
    end

    pcall(function() root.Anchored = false end)
    trickOrTreat.currentHouseInteracting = nil

    -- Check if any houses had errors and need retrying
    local remainingErrors = 0
    for hName, _ in pairs(trickOrTreat.erroredHouseNames) do
        local attempts = trickOrTreat.houseRetryAttempts[hName] or 0
        if attempts < (trickOrTreat.maxHouseRetries or 2) then
            remainingErrors = remainingErrors + 1
        else
            trickOrTreat.erroredHouseNames[hName] = nil
            trickOrTreat.completedHouseNames[hName] = true
        end
    end

    if remainingErrors > 0 and (trickOrTreat.auto or trickOrTreat.isSingleRun) then
        trickOrTreat.isRetryPass = true
        trickOrTreat.statusText = string.format("%d house(s) errored. Retrying only failed houses in 4s...", remainingErrors)
        trickOrTreat.currentPhase = "Retrying Failed Houses"
        trickOrTreat.nextCycleTime = os.clock() + 4
        trickOrTreat.isCycling = false
        trickOrTreat.updateStatusUI()

        if trickOrTreat.returnOnFinish and preCycleCFrame then
            safeReturnToSavedPosition(preCycleCFrame)
        end
        return
    end

    -- All houses completed without active errors: finalize cycle!
    trickOrTreat.isRetryPass = false
    trickOrTreat.completedHouseNames = {}
    trickOrTreat.erroredHouseNames = {}
    trickOrTreat.houseRetryAttempts = {}

    -- 4. Teleport back to original position before the cycle started
    if trickOrTreat.returnOnFinish and preCycleCFrame then
        trickOrTreat.currentPhase = "Returning to Start"
        trickOrTreat.statusText = "Returning to original position..."
        trickOrTreat.updateStatusUI()
        safeReturnToSavedPosition(preCycleCFrame)
        task.wait(0.1)
        if trickOrTreat.autoDismissRewardGui then
            pcall(trickOrTreat.dismissRewardGui)
        end
        stopCharacterVelocity()
    end

    local cycleDuration = os.clock() - (trickOrTreat.cycleStartTime or os.clock())
    trickOrTreat.lastCycleDuration = math.floor(cycleDuration * 10) / 10
    trickOrTreat.totalCycles = (trickOrTreat.totalCycles or 0) + 1
    trickOrTreat.currentPhase = "On Cooldown"
    trickOrTreat.currentHouseIndex = 0
    trickOrTreat.currentHouseDistance = 0
    local cd = math.max(10, trickOrTreat.cycleCooldown or 600)
    if trickOrTreat.autoDetectCooldown and (trickOrTreat.longestDetectedCooldown or 0) > 0 then
        cd = math.max(cd, trickOrTreat.longestDetectedCooldown)
        trickOrTreat.cycleCooldown = cd
    end
    trickOrTreat.lastCycleCompletedTime = os.clock()
    trickOrTreat.housesVisitedCount = knockedCount
    -- Only teleport at the end of the longest cooldown when autodetect is on
    trickOrTreat.nextCycleTime = math.max(trickOrTreat.nextCycleTime or 0, os.clock() + cd)
    trickOrTreat.isCycling = false
    trickOrTreat.isSingleRun = false
    trickOrTreat.statusText = string.format("Cycle finished (%d houses). On cooldown.", knockedCount)
    trickOrTreat.updateStatusUI()

    local cdMin = math.floor(cd / 60)
    local cdSec = math.floor(cd % 60)
    safeNotify({
        Title = "Trick or Treat Cycle Complete",
        Content = string.format("Knocked %d houses! Returned to start. Next cycle in %d:%02d.", knockedCount, cdMin, cdSec),
        Duration = 4,
        Image = 4483362458,
    })
end

function trickOrTreat.startLoop()
    if trickOrTreat.loopRunning then return end
    trickOrTreat.loopRunning = true
    task.spawn(function()
        while trickOrTreat.loopRunning do
            task.wait(1)
            pcall(trickOrTreat.updateStatusUI)
            if (trickOrTreat.auto or (trickOrTreat.isSingleRun and trickOrTreat.isRetryPass)) and not trickOrTreat.isCycling then
                local now = os.clock()
                if now >= trickOrTreat.nextCycleTime then
                    local success, err = xpcall(trickOrTreat.runCycle, function(e)
                        return debug.traceback(tostring(e), 2)
                    end)
                    if not success then
                        warn("[CowHub TrickOrTreat] Error during cycle:\n" .. tostring(err))
                        trickOrTreat.isCycling = false
                        trickOrTreat.isSingleRun = false
                        if trickOrTreat.currentHouseInteracting then
                            local curH = trickOrTreat.currentHouseInteracting
                            local hName = (typeof(curH) == "Instance" and curH.Name) or tostring(curH)
                            trickOrTreat.erroredHouseNames[hName] = true
                        end
                        local errCount = 0
                        for _ in pairs(trickOrTreat.erroredHouseNames) do errCount = errCount + 1 end
                        if errCount > 0 then
                            trickOrTreat.isRetryPass = true
                            trickOrTreat.statusText = string.format("Error during cycle. Retrying %d failed house(s) in 4s...", errCount)
                            trickOrTreat.nextCycleTime = os.clock() + 4
                        else
                            -- Cycle finished without house failures (non-fatal error in post-cycle GUI). Preserve active cooldown!
                            trickOrTreat.isRetryPass = false
                            if trickOrTreat.nextCycleTime <= os.clock() then
                                local cd = math.max(10, trickOrTreat.cycleCooldown or 600)
                                trickOrTreat.nextCycleTime = os.clock() + cd
                            end
                            trickOrTreat.statusText = "Cycle finished with non-fatal error. On cooldown."
                        end
                        pcall(trickOrTreat.updateStatusUI)
                    end
                end
            end
        end
    end)
end

function trickOrTreat.toggle(Value)
    if trickOrTreat.auto == Value then return end
    trickOrTreat.auto = Value

    -- Synchronize UI buttons/toggles across tabs without recursive loops
    if Window and Window.Flags then
        if Window.Flags.Toggle_TrickOrTreat ~= Value then
            pcall(function() Window:Set("Toggle_TrickOrTreat", Value) end)
        end
        if Window.Flags.Toggle_TrickOrTreat_Main ~= Value then
            pcall(function() Window:Set("Toggle_TrickOrTreat_Main", Value) end)
        end
    end

    if Value then
        if trickOrTreat.sessionStartTime == 0 then
            trickOrTreat.sessionStartTime = os.clock()
        end
        trickOrTreat.currentPhase = "Idle (Enabled)"
        trickOrTreat.initClientListener()
        if trickOrTreat.autoDetectCooldown then
            trickOrTreat.detectCooldown()
        end
        local now = os.clock()
        local cd = math.max(10, trickOrTreat.cycleCooldown or 600)
        if trickOrTreat.autoDetectCooldown and (trickOrTreat.longestDetectedCooldown or 0) > 0 then
            cd = math.max(cd, trickOrTreat.longestDetectedCooldown)
        end
        if (trickOrTreat.lastCycleCompletedTime or 0) == 0 then
            trickOrTreat.nextCycleTime = 0
        elseif trickOrTreat.nextCycleTime > now then
            -- Active scheduled cooldown in progress; do not wipe!
        elseif trickOrTreat.lastCycleCompletedTime > 0 and (now - trickOrTreat.lastCycleCompletedTime < cd) then
            trickOrTreat.nextCycleTime = trickOrTreat.lastCycleCompletedTime + cd
        else
            trickOrTreat.nextCycleTime = 0
        end

        -- Check if village houses are currently on cooldown:
        if (trickOrTreat.lastCycleCompletedTime or 0) > 0 and trickOrTreat.houseCooldowns then
            local longestRemaining = 0
            for _, expiry in pairs(trickOrTreat.houseCooldowns) do
                if expiry > now then
                    longestRemaining = math.max(longestRemaining, expiry - now)
                end
            end
            if trickOrTreat.autoDetectCooldown and longestRemaining > 0 then
                trickOrTreat.nextCycleTime = math.max(trickOrTreat.nextCycleTime, now + longestRemaining)
            end
        end
        trickOrTreat.startLoop()
        trickOrTreat.updateStatusUI()
        local notifyMsg = "Autofarm enabled. Starting cycle..."
        if trickOrTreat.nextCycleTime > now then
            notifyMsg = string.format("Autofarm enabled. Next cycle in %ds (cooldown active).", math.ceil(trickOrTreat.nextCycleTime - now))
        end
        safeNotify({
            Title = "Trick or Treat Autofarm",
            Content = notifyMsg,
            Duration = 3,
            Image = 4483362458,
        })
    else
        trickOrTreat.statusText = "Idle"
        trickOrTreat.currentPhase = "Idle (Disabled)"
        trickOrTreat.currentHouseIndex = 0
        trickOrTreat.currentHouseDistance = 0
        trickOrTreat.isRetryPass = false
        trickOrTreat.completedHouseNames = {}
        trickOrTreat.erroredHouseNames = {}
        trickOrTreat.houseRetryAttempts = {}
        if trickOrTreat.currentHouseInteracting and trickOrTreat.disableInsideCollision then
            pcall(function() trickOrTreat.setHouseCollision(trickOrTreat.currentHouseInteracting, true) end)
        end
        trickOrTreat.currentHouseInteracting = nil
        if trickOrTreat.isCycling and trickOrTreat.returnOnFinish and trickOrTreat.savedPreCFrame then
            safeReturnToSavedPosition(trickOrTreat.savedPreCFrame)
        end
        trickOrTreat.isCycling = false
        trickOrTreat.isSingleRun = false
        trickOrTreat.updateStatusUI()
    end
    if updateHeartbeatConnection then
        updateHeartbeatConnection()
    end
end

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
-- 6-HOUR AFK AUTO-REJOIN & STATE PERSISTENCE SYSTEM
-- ==========================
local afkRelog = {
    enabled = true,
    interval = 6 * 3600, -- 6 hours = 21,600 seconds
    sessionStartTime = os.time(),
    targetRejoinTime = os.time() + (6 * 3600),
    isRejoining = false,
    fileName = "CowHub_SessionPersistence.json",
    timerThread = nil,
    statusCard = nil,
    lastLoggedPos = nil,
    resumedSession = false,
}

function afkRelog.saveState()
    -- Flush Rayfield Gen2 window configuration to disk
    if Window and Window.Save then
        pcall(function() Window:Save() end)
    end

    if not root or not char then return false end
    local pos = getRootPos(root)
    if not pos then return false end
    local rootCF = getRootCFrame(root)
    local cfComponents = rootCF and { rootCF:GetComponents() } or { pos.X, pos.Y, pos.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1 }
    afkRelog.lastLoggedPos = pos

    local stateData = {
        Timestamp = os.time(),
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        Position = { X = pos.X, Y = pos.Y, Z = pos.Z },
        CFrameComponents = cfComponents,
        Farm = {
            On = farm.on == true,
            AutoChomp = farm.autoChomp == true,
            AutoChompMobs = farm.autoChompMobs == true,
            GoldenAura = farm.goldenAura == true,
            AutoFish = farm.autoFish == true,
            AnchorPos = farm.anchorPos and { X = farm.anchorPos.X, Y = farm.anchorPos.Y, Z = farm.anchorPos.Z } or nil,
            Radius = farm.radius or 75,
            Pattern = farm.pattern or "Guided Zigzag (Nodes)",
            PatternSpeed = farm.patternSpeed or 1.0,
            GrassChompDelay = math.max(0.01, farm.grassChompDelay or 0.4),
            OnlyMatureGrass = farm.onlyMatureGrass ~= false,
            ChompOnlyWhileMoving = farm.chompOnlyWhileMoving ~= false,
        },
        Dodge = {
            Auto = dodge.auto == true,
            Method = dodge.method or "Teleport Away (Surface)",
        },
        Manatite = {
            Auto = (manatite and manatite.auto) == true,
        },
        Mithril = {
            Auto = (mithril and mithril.auto) == true,
        },
        TrickOrTreat = {
            Auto = (trickOrTreat and trickOrTreat.auto) == true,
            CycleCooldown = trickOrTreat and trickOrTreat.cycleCooldown or 600,
            AutoDetectCooldown = (trickOrTreat and trickOrTreat.autoDetectCooldown) ~= false,
            AutoDismissRewardGui = (trickOrTreat and trickOrTreat.autoDismissRewardGui) ~= false,
            ReturnOnFinish = (trickOrTreat and trickOrTreat.returnOnFinish) ~= false,
            AnchorDuringKnock = (trickOrTreat and trickOrTreat.anchorDuringKnock) ~= false,
            PauseFarmDuringCycle = (trickOrTreat and trickOrTreat.pauseFarmDuringCycle) ~= false,
            BarnLoadDelay = trickOrTreat and trickOrTreat.barnLoadDelay or 2.5,
            HouseWaitTime = trickOrTreat and trickOrTreat.houseWaitTime or 1.4,
            SettleDelay = trickOrTreat and trickOrTreat.settleDelay or 0.3,
            TotalCycles = trickOrTreat and trickOrTreat.totalCycles or 0,
            TotalHousesKnocked = trickOrTreat and trickOrTreat.totalHousesKnocked or 0,
            TotalRewardsDismissed = trickOrTreat and trickOrTreat.totalRewardsDismissed or 0,
            LongestDetectedCooldown = trickOrTreat and trickOrTreat.longestDetectedCooldown or 0,
            NextCycleRemaining = trickOrTreat and (trickOrTreat.nextCycleTime > os.clock()) and math.ceil(trickOrTreat.nextCycleTime - os.clock()) or 0,
            WalkUpEnabled = (trickOrTreat and trickOrTreat.walkUpEnabled) ~= false,
            DisableInsideCollision = (trickOrTreat and trickOrTreat.disableInsideCollision) ~= false,
            ApproachOrigin = trickOrTreat and trickOrTreat.approachOrigin or "Inside House",
            WalkDistance = trickOrTreat and trickOrTreat.walkDistance or 11.0,
            WalkTimeout = trickOrTreat and trickOrTreat.walkTimeout or 1.5,
            DoorDistance = trickOrTreat and trickOrTreat.doorDistance or 2.0,
            DoorHeightOffset = trickOrTreat and trickOrTreat.doorHeightOffset or 0.0,
            ReturnHeightOffset = trickOrTreat and trickOrTreat.returnHeightOffset or 4.0,
        },
        TownAuction = {
            AutoBidAll = townAuction and townAuction.autoBidAll == true,
            AutoBidActive = townAuction and townAuction.autoBidActive or {},
            MaxAutoBidLimit = townAuction and townAuction.maxAutoBidLimit or 0,
        },
    }

    if writefile then
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(stateData)
        end)
        if success and encoded then
            local writeSuccess = pcall(function()
                writefile(afkRelog.fileName, encoded)
            end)
            return writeSuccess
        end
    end
    return false
end

function afkRelog.triggerRejoin()
    if afkRelog.isRejoining then return end
    afkRelog.isRejoining = true

    -- 1. Log coordinates & save full persistence state
    local saved = afkRelog.saveState()

    -- 2. Notify player
    safeNotify({
        Title = "6-Hour Auto-Rejoin",
        Content = "AFK timer elapsed! Coordinates logged. Rejoining now...",
        Duration = 6,
        Image = 4483362458,
    })

    -- 3. Hook queue_on_teleport so cowhub auto-executes on reconnect
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot([[
                task.wait(3)
                loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/main/cowhub.lua'))()
            ]])
        end)
    end

    task.wait(1.5)

    -- 4. Execute Teleport to rejoin
    pcall(function()
        if #Players:GetPlayers() <= 1 or not game.JobId or game.JobId == "" then
            TeleportService:Teleport(game.PlaceId, plr)
        else
            -- Try rejoining same server instance first
            local success = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
            end)
            if not success then
                TeleportService:Teleport(game.PlaceId, plr)
            end
        end
    end)

    -- Fallback repeat if first teleport attempt stalled
    task.delay(10, function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, plr)
        end)
    end)
end

function afkRelog.checkAndResumeState()
    if not (isfile and readfile and isfile(afkRelog.fileName)) then
        return
    end

    local success, content = pcall(function()
        return readfile(afkRelog.fileName)
    end)
    if not success or not content or content == "" then
        return
    end

    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not decodeSuccess or type(data) ~= "table" then
        return
    end

    -- Check if state file was written recently (within 30 minutes)
    local age = os.time() - (data.Timestamp or 0)
    if age > 1800 or age < 0 then
        if delfile then pcall(function() delfile(afkRelog.fileName) end) end
        return
    end

    -- Clean up persistence file so it only triggers once
    if delfile then
        pcall(function() delfile(afkRelog.fileName) end)
    end

    afkRelog.resumedSession = true

    -- Asynchronously wait for game & player to be fully ready before restoring
    task.spawn(function()
        local readyStart = os.clock()
        while (not root or not char or not humanoid or humanoid.Health <= 0) and (os.clock() - readyStart < 20) do
            task.wait(0.5)
        end

        task.wait(2.5) -- Allow geometry / map streaming to stabilize

        -- 1. Restore position & CFrame
        if data.CFrameComponents and #data.CFrameComponents == 12 then
            pcall(function()
                local restoredCF = CFrame.new(table.unpack(data.CFrameComponents))
                char:PivotTo(restoredCF)
                root.CFrame = restoredCF
                if stopCharacterVelocity then stopCharacterVelocity() end
            end)
        elseif data.Position then
            pcall(function()
                local restoredPos = Vector3.new(data.Position.X, data.Position.Y, data.Position.Z)
                char:PivotTo(CFrame.new(restoredPos))
                root.CFrame = CFrame.new(restoredPos)
                if stopCharacterVelocity then stopCharacterVelocity() end
            end)
        end

        task.wait(1.0)

        -- 2. Restore Farming & Feature States and Sync Rayfield Gen2 UI Elements
        local f = data.Farm or {}
        if f.AnchorPos then
            farm.anchorPos = Vector3.new(f.AnchorPos.X, f.AnchorPos.Y, f.AnchorPos.Z)
        elseif root then
            farm.anchorPos = getRootPos(root)
        end

        if f.Radius then
            farm.radius = f.Radius
            farm.radiusSq = f.Radius * f.Radius
            pcall(function() Window:Set("Slider_Radius", f.Radius) end)
        end
        if f.Pattern then
            farm.pattern = f.Pattern
            pcall(function() Window:Set("Dropdown_Pattern", f.Pattern) end)
        end
        if f.PatternSpeed then
            farm.patternSpeed = f.PatternSpeed
        end
        if f.GrassChompDelay then
            farm.grassChompDelay = math.max(0.01, tonumber(f.GrassChompDelay) or 0.4)
            farm.grassChompRepeatDelay = farm.grassChompDelay + 0.1
            pcall(function() Window:Set("Slider_GrassChompDelay", farm.grassChompDelay) end)
        end
        if f.OnlyMatureGrass ~= nil then
            farm.onlyMatureGrass = f.OnlyMatureGrass
            pcall(function() Window:Set("Toggle_OnlyMatureGrass", f.OnlyMatureGrass) end)
        end
        if f.ChompOnlyWhileMoving ~= nil then
            farm.chompOnlyWhileMoving = f.ChompOnlyWhileMoving
            pcall(function() Window:Set("Toggle_ChompOnlyMoving", f.ChompOnlyWhileMoving) end)
        end

        if f.AutoChomp then
            farm.autoChomp = true
            pcall(function() Window:Set("Toggle_Chomp", true) end)
        end
        if f.AutoChompMobs then
            farm.autoChompMobs = true
            pcall(function() Window:Set("Toggle_MobAura", true) end)
        end
        if f.GoldenAura then
            farm.goldenAura = true
            pcall(function() Window:Set("Toggle_GoldenAura", true) end)
        end
        if f.AutoFish then
            farm.autoFish = true
            cache.initRippleTracking()
            pcall(function() Window:Set("Toggle_Fish", true) end)
        end

        if data.Dodge and data.Dodge.Auto then
            dodge.auto = true
            pcall(function() Window:Set("Toggle_AutoDodge", true) end)
        end
        if data.Manatite and data.Manatite.Auto and manatite then
            manatite.auto = true
            manatite.preCFrame = root and root.CFrame
            pcall(function() Window:Set("Toggle_ManatiteFarm", true) end)
        end
        if data.Mithril and data.Mithril.Auto and mithril then
            mithril.auto = true
            mithril.preCFrame = root and root.CFrame
            pcall(function() Window:Set("Toggle_MithrilFarm", true) end)
        end
        if data.TrickOrTreat then
            if data.TrickOrTreat.AutoDetectCooldown ~= nil then
                trickOrTreat.autoDetectCooldown = data.TrickOrTreat.AutoDetectCooldown
                pcall(function() Window:Set("Toggle_ToT_AutoDetect", data.TrickOrTreat.AutoDetectCooldown) end)
            end
            if data.TrickOrTreat.AutoDismissRewardGui ~= nil then
                trickOrTreat.autoDismissRewardGui = data.TrickOrTreat.AutoDismissRewardGui
                trickOrTreat.autoAcceptRewards = data.TrickOrTreat.AutoDismissRewardGui
                pcall(function() Window:Set("Toggle_ToT_DismissRewardGui", data.TrickOrTreat.AutoDismissRewardGui) end)
            end
            if data.TrickOrTreat.CycleCooldown then
                trickOrTreat.cycleCooldown = data.TrickOrTreat.CycleCooldown
                pcall(function() Window:Set("Slider_ToT_CycleCooldown", data.TrickOrTreat.CycleCooldown) end)
            end
            if data.TrickOrTreat.BarnLoadDelay then
                trickOrTreat.barnLoadDelay = data.TrickOrTreat.BarnLoadDelay
                pcall(function() Window:Set("Slider_ToT_BarnDelay", data.TrickOrTreat.BarnLoadDelay) end)
            end
            if data.TrickOrTreat.HouseWaitTime then
                trickOrTreat.houseWaitTime = data.TrickOrTreat.HouseWaitTime
                pcall(function() Window:Set("Slider_ToT_HouseWait", data.TrickOrTreat.HouseWaitTime) end)
            end
            if data.TrickOrTreat.SettleDelay then
                trickOrTreat.settleDelay = data.TrickOrTreat.SettleDelay
                pcall(function() Window:Set("Slider_ToT_SettleDelay", data.TrickOrTreat.SettleDelay) end)
            end
            if data.TrickOrTreat.TotalCycles then
                trickOrTreat.totalCycles = data.TrickOrTreat.TotalCycles
            end
            if data.TrickOrTreat.TotalHousesKnocked then
                trickOrTreat.totalHousesKnocked = data.TrickOrTreat.TotalHousesKnocked
            end
            if data.TrickOrTreat.TotalRewardsDismissed then
                trickOrTreat.totalRewardsDismissed = data.TrickOrTreat.TotalRewardsDismissed
            end
            if data.TrickOrTreat.LongestDetectedCooldown then
                trickOrTreat.longestDetectedCooldown = data.TrickOrTreat.LongestDetectedCooldown
            end
            if data.TrickOrTreat.NextCycleRemaining and data.TrickOrTreat.NextCycleRemaining > 0 then
                trickOrTreat.nextCycleTime = os.clock() + data.TrickOrTreat.NextCycleRemaining
            end
            if data.TrickOrTreat.ReturnOnFinish ~= nil then
                trickOrTreat.returnOnFinish = data.TrickOrTreat.ReturnOnFinish
                pcall(function() Window:Set("Toggle_ToT_ReturnOnFinish", data.TrickOrTreat.ReturnOnFinish) end)
            end
            if data.TrickOrTreat.AnchorDuringKnock ~= nil then
                trickOrTreat.anchorDuringKnock = data.TrickOrTreat.AnchorDuringKnock
                pcall(function() Window:Set("Toggle_ToT_AnchorKnock", data.TrickOrTreat.AnchorDuringKnock) end)
            end
            if data.TrickOrTreat.PauseFarmDuringCycle ~= nil then
                trickOrTreat.pauseFarmDuringCycle = data.TrickOrTreat.PauseFarmDuringCycle
                pcall(function() Window:Set("Toggle_ToT_PauseFarm", data.TrickOrTreat.PauseFarmDuringCycle) end)
            end
            if data.TrickOrTreat.DisableInsideCollision ~= nil then
                trickOrTreat.disableInsideCollision = data.TrickOrTreat.DisableInsideCollision
                pcall(function() Window:Set("Toggle_ToT_DisableInsideCollision", data.TrickOrTreat.DisableInsideCollision) end)
            end
            if data.TrickOrTreat.ApproachOrigin then
                trickOrTreat.approachOrigin = data.TrickOrTreat.ApproachOrigin
                pcall(function() Window:Set("Dropdown_ToT_ApproachOrigin", data.TrickOrTreat.ApproachOrigin) end)
            end
            if data.TrickOrTreat.WalkUpEnabled ~= nil then
                trickOrTreat.walkUpEnabled = data.TrickOrTreat.WalkUpEnabled
                pcall(function() Window:Set("Toggle_ToT_WalkUp", data.TrickOrTreat.WalkUpEnabled) end)
            end
            if data.TrickOrTreat.WalkDistance then
                trickOrTreat.walkDistance = data.TrickOrTreat.WalkDistance
                pcall(function() Window:Set("Slider_ToT_WalkDistance", data.TrickOrTreat.WalkDistance) end)
            end
            if data.TrickOrTreat.WalkTimeout then
                trickOrTreat.walkTimeout = data.TrickOrTreat.WalkTimeout
                pcall(function() Window:Set("Slider_ToT_WalkTimeout", data.TrickOrTreat.WalkTimeout) end)
            end
            if data.TrickOrTreat.DoorDistance then
                trickOrTreat.doorDistance = data.TrickOrTreat.DoorDistance
                pcall(function() Window:Set("Slider_ToT_DoorDistance", data.TrickOrTreat.DoorDistance) end)
            end
            if data.TrickOrTreat.DoorHeightOffset then
                trickOrTreat.doorHeightOffset = data.TrickOrTreat.DoorHeightOffset
                pcall(function() Window:Set("Slider_ToT_DoorHeightOffset", data.TrickOrTreat.DoorHeightOffset) end)
            end
            if data.TrickOrTreat.ReturnHeightOffset then
                trickOrTreat.returnHeightOffset = data.TrickOrTreat.ReturnHeightOffset
                pcall(function() Window:Set("Slider_ToT_ReturnHeightOffset", data.TrickOrTreat.ReturnHeightOffset) end)
            end
            if data.TrickOrTreat.Auto and trickOrTreat then
                trickOrTreat.toggle(true)
                pcall(function() Window:Set("Toggle_TrickOrTreat", true) end)
                pcall(function() Window:Set("Toggle_TrickOrTreat_Main", true) end)
            end
        end

        if data.TownAuction then
            local ta = data.TownAuction
            if ta.AutoBidAll then
                townAuction.autoBidAll = true
                pcall(function() Window:Set("Toggle_TownAutoBidAll", true) end)
            end
            if type(ta.AutoBidActive) == "table" then
                for slot, active in pairs(ta.AutoBidActive) do
                    if active then
                        townAuction.autoBidActive[slot] = true
                        pcall(function() Window:Set("Toggle_TownAutoBid_" .. slot, true) end)
                    end
                end
            end
            if ta.MaxAutoBidLimit and ta.MaxAutoBidLimit > 0 then
                townAuction.maxAutoBidLimit = ta.MaxAutoBidLimit
            end
        end

        if f.On then
            pcall(function() Window:Set("Toggle_Farm", true) end)
            farm.on = true
            farm.collisionDetection = true
            if f.AnchorPos then
                farm.anchorPos = Vector3.new(f.AnchorPos.X, f.AnchorPos.Y, f.AnchorPos.Z)
            end
        end

        if updateHeartbeatConnection then
            updateHeartbeatConnection()
        end

        -- 3. Notify user that state has been fully restored
        local posX = data.Position and math.floor(data.Position.X) or 0
        local posY = data.Position and math.floor(data.Position.Y) or 0
        local posZ = data.Position and math.floor(data.Position.Z) or 0
        Window:Notify({
            Title = "Session Resumed Successfully",
            Content = string.format("Restored coordinates (%d, %d, %d) and resumed previous farming tasks!", posX, posY, posZ),
            Duration = 5,
            Image = 4483362458,
        })
    end)
end

function afkRelog.startTimer()
    if afkRelog.timerThread then return end
    afkRelog.sessionStartTime = os.time()
    afkRelog.targetRejoinTime = os.time() + afkRelog.interval

    afkRelog.timerThread = task.spawn(function()
        while true do
            task.wait(1)
            if afkRelog.enabled and not afkRelog.isRejoining then
                local now = os.time()
                local remaining = afkRelog.targetRejoinTime - now
                if remaining <= 0 then
                    afkRelog.triggerRejoin()
                    break
                end
            end
            if afkRelog.updateUI then
                afkRelog.updateUI()
            end
        end
    end)
end

function afkRelog.updateUI()
    if not afkRelog.statusCard then return end
    local now = os.time()
    local remaining = math.max(0, afkRelog.targetRejoinTime - now)
    local h = math.floor(remaining / 3600)
    local m = math.floor((remaining % 3600) / 60)
    local s = math.floor(remaining % 60)

    local title = "AFK Rejoin Timer: " .. (afkRelog.enabled and string.format("%02dh %02dm %02ds", h, m, s) or "Disabled")
    local rPos = getRootPos(root)
    local posStr = rPos and string.format("(%d, %d, %d)", math.floor(rPos.X), math.floor(rPos.Y), math.floor(rPos.Z)) or "N/A"
    local body = string.format("Interval: %g hours (%ds)\nCurrent Coords: %s\nState Persistence: Ready",
        afkRelog.interval / 3600,
        afkRelog.interval,
        posStr
    )

    pcall(function()
        if afkRelog.statusCard.SetTitle then
            afkRelog.statusCard:SetTitle(title)
            afkRelog.statusCard:Set(body)
        elseif afkRelog.statusCard.Set then
            afkRelog.statusCard:Set({ Title = title, Content = body })
        end
    end)
end

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
        if string.find(val, "Grass", 1, true)
            or string.find(val, "VirtualGrass", 1, true)
            or string.find(val, "Manatite", 1, true)
            or string.find(val, "Mithril", 1, true)
            or string.find(val, "Ore", 1, true)
            or string.find(val, "Fish", 1, true) then
            return nil
        end

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
        if #spiderLogger.data.identifiers > 200 then
            local oldId = table.remove(spiderLogger.data.identifiers, 1)
            if oldId then spiderLogger.idSet[oldId] = nil end
        end
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
    local firstArg = ...
    if firstArg then
        local firstStr = tostring(firstArg)
        if string.find(firstStr, "Grass", 1, true)
            or string.find(firstStr, "VirtualGrass", 1, true)
            or string.find(firstStr, "Manatite", 1, true)
            or string.find(firstStr, "Mithril", 1, true) then
            return
        end
    end
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
                    local firstArg = args[1]
                    local firstStr = firstArg and tostring(firstArg) or ""
                    if not (string.find(firstStr, "Grass", 1, true) or string.find(firstStr, "VirtualGrass", 1, true)) then
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
            end

            if (self == townAuction.remote or (typeof(self) == "Instance" and self.Name == "CowTownAuctionRequest"))
                and (method == "InvokeServer" or method == "invokeServer") then
                local result = oldNamecall(self, ...)
                if type(result) == "table" and result.Ok and result.Lots then
                    task.spawn(function()
                        if townAuction.handleSnapshotResult then
                            townAuction.handleSnapshotResult(result)
                        end
                    end)
                end
                return result
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
        updateWallRaycastFilter()
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

local function isValidGrassNodeID(id)
    if type(id) ~= "string" or id == "" then return false end
    if string.find(id, "Floor", 1, true) then return false end
    return string.match(id, ".*Grass.*_[np%-]?%d+$") ~= nil
end
cache.isValidNodeID = isValidGrassNodeID

function cache.resolveGrassNode(inst)
    if not inst then return nil end
    local folder = cache.grassFolder or workspace:FindFirstChild("CowVirtualGrass")
    if not folder or inst == folder then return nil end

    -- Must strictly be within the CowVirtualGrass folder
    if not inst:IsDescendantOf(folder) then
        return nil
    end

    local curr = inst
    while curr and curr.Parent and curr.Parent ~= folder do
        curr = curr.Parent
    end
    if not curr or curr.Parent ~= folder then
        return nil
    end

    local nodeId = cache.getNodeID(curr)
    if nodeId and isValidGrassNodeID(nodeId) then
        return curr
    end

    return nil
end

function cache.getNodeID(node)
    if not node or not node.Parent then return nil end
    local cached = cache.nodeIDs[node]
    if cached ~= nil then return cached or nil end

    -- Must be strictly in CowVirtualGrass
    local folder = cache.grassFolder or workspace:FindFirstChild("CowVirtualGrass")
    if folder and not node:IsDescendantOf(folder) then
        cache.nodeIDs[node] = false
        return nil
    end

    local attrId = node:GetAttribute("nodeID")
    if attrId == nil then attrId = node:GetAttribute("NodeID") end
    if attrId == nil then attrId = node:GetAttribute("nodeId") end
    if attrId == nil then attrId = node:GetAttribute("NodeId") end

    if attrId == nil and node.Parent and node.Parent ~= folder and node.Parent ~= workspace then
        attrId = node.Parent:GetAttribute("nodeID")
        if attrId == nil then attrId = node.Parent:GetAttribute("NodeID") end
        if attrId == nil then attrId = node.Parent:GetAttribute("nodeId") end
        if attrId == nil then attrId = node.Parent:GetAttribute("NodeId") end
    end

    if attrId and attrId ~= "" then
        local cleanId = tostring(attrId)
        if string.find(cleanId, "GrassVisual", 1, true) then
            cleanId = string.gsub(cleanId, "GrassVisual", "")
            cleanId = string.gsub(cleanId, "^_+", "")
            cleanId = string.gsub(cleanId, "_+$", "")
        end
        if isValidGrassNodeID(cleanId) then
            cache.nodeIDs[node] = cleanId
            return cleanId
        end
    end

    -- Fallback: legacy name cleaning if attribute is absent
    local fallback = cache.getCleanGrassName(node.Name)
    if fallback and isValidGrassNodeID(fallback) then
        cache.nodeIDs[node] = fallback
        return fallback
    end

    cache.nodeIDs[node] = false
    return nil
end

function cache.getCleanGrassName(nodeName)
    local cached = cache.nodeCleanNames[nodeName]
    if cached ~= nil then return cached or nil end

    if string.find(nodeName, "Floor", 1, true) then
        cache.nodeCleanNames[nodeName] = false
        return nil
    end

    local cleanName = string.gsub(nodeName, "GrassVisual", "")
    cleanName = string.gsub(cleanName, "^_+", "")
    cleanName = string.gsub(cleanName, "_+$", "")

    if isValidGrassNodeID(cleanName) then
        cache.nodeCleanNames[nodeName] = cleanName
        return cleanName
    else
        cache.nodeCleanNames[nodeName] = false
        return nil
    end
end

function cache.extractGrassNodeId(target)
    if not target then return nil end
    local rawName = nil
    if typeof(target) == "Instance" then
        local attrId = target:GetAttribute("nodeID")
        if attrId == nil then attrId = target:GetAttribute("NodeID") end
        if attrId == nil then attrId = target:GetAttribute("nodeId") end
        if attrId == nil then attrId = target:GetAttribute("NodeId") end
        if attrId and type(attrId) == "string" and attrId ~= "" then
            rawName = attrId
        else
            rawName = target.Name
        end
    elseif type(target) == "string" and target ~= "" then
        rawName = target
    end

    if not rawName or rawName == "" then return nil end
    local clean = cache.getCleanGrassName(rawName)
    if not clean and typeof(target) == "Instance" and target.Parent and target.Parent ~= workspace then
        clean = cache.extractGrassNodeId(target.Parent)
    end
    return clean
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
    if now - cache.lastBlacklistCleanup > 10 then
        cache.lastBlacklistCleanup = now
        for node, timestamp in pairs(cache.nodeBlacklist) do
            if not node or not node.Parent or (now >= timestamp) then
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

    -- 1. Direct path: workspace.FjordDelta.ManatiteFjordCave.ManatiteMaze.ManatiteClusters (O(1))
    local fjord = workspace:FindFirstChild("FjordDelta")
    if not fjord and cache.cowWorldRef and cache.cowWorldRef.Parent then
        fjord = cache.cowWorldRef:FindFirstChild("FjordDelta")
    end

    if fjord then
        local cave = fjord:FindFirstChild("ManatiteFjordCave")
        if cave then
            local maze = cave:FindFirstChild("ManatiteMaze")
            if maze then
                local clusters = maze:FindFirstChild("ManatiteClusters")
                if clusters then
                    manatite.cachedFolder = clusters
                    return clusters
                end
            end
        end
    end

    local directClusters = workspace:FindFirstChild("ManatiteClusters")
    if directClusters then
        manatite.cachedFolder = directClusters
        return directClusters
    end

    -- 2. Throttled deep search (at most once every 2.0s to avoid frame freezing)
    local now = os.clock()
    if not manatite.lastFolderSearch or (now - manatite.lastFolderSearch >= 2.0) then
        manatite.lastFolderSearch = now
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
        local clusters = workspace:FindFirstChild("ManatiteClusters", true)
        if clusters then
            manatite.cachedFolder = clusters
            return clusters
        end
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
    local origin = searchOrigin or getRootPos(root) or Vector3.zero
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

    local nextModel, nextTarget = manatite.findNext(rootPos or getRootPos(root), true)
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

    stopCharacterVelocity()
    char:PivotTo(targetCFrame)
    root.CFrame = targetCFrame
    stopCharacterVelocity()

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

    -- 1. Direct path: resources.CrystalGeodeOres (O(1))
    local res = getResourcesFolder()
    if res then
        local geode = res:FindFirstChild("CrystalGeodeOres")
        if geode then
            mithril.cachedFolder = geode
            return geode
        end
    end

    -- 2. Direct path via CowWorld (O(1))
    local cowWorld = cache.cowWorldRef
    if not cowWorld or not cowWorld.Parent then
        cowWorld = workspace:FindFirstChild("CowWorld")
        cache.cowWorldRef = cowWorld
    end
    if cowWorld then
        local rafting = cowWorld:FindFirstChild("FjordRafting")
        if rafting then
            local geode = rafting:FindFirstChild("CrystalGeodeOres")
            if geode then
                mithril.cachedFolder = geode
                return geode
            end
        end
        local directGeode = cowWorld:FindFirstChild("CrystalGeodeOres")
        if directGeode then
            mithril.cachedFolder = directGeode
            return directGeode
        end
    end

    local topGeode = workspace:FindFirstChild("CrystalGeodeOres")
    if topGeode then
        mithril.cachedFolder = topGeode
        return topGeode
    end

    -- 3. Throttled deep search (at most once every 2.0s to avoid frame freezing)
    local now = os.clock()
    if not mithril.lastFolderSearch or (now - mithril.lastFolderSearch >= 2.0) then
        mithril.lastFolderSearch = now
        if res then
            local geode = res:FindFirstChild("CrystalGeodeOres", true)
            if geode then
                mithril.cachedFolder = geode
                return geode
            end
        end
        if cowWorld then
            local rafting = cowWorld:FindFirstChild("FjordRafting", true)
            if rafting then
                local geode = rafting:FindFirstChild("CrystalGeodeOres", true)
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
        local geode = workspace:FindFirstChild("CrystalGeodeOres", true)
        if geode then
            mithril.cachedFolder = geode
            return geode
        end
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
    local origin = searchOrigin or getRootPos(root) or Vector3.zero
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

    local nextModel, nextOre = mithril.findNext(rootPos or getRootPos(root), true)
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

    stopCharacterVelocity()
    char:PivotTo(targetCFrame)
    root.CFrame = targetCFrame
    stopCharacterVelocity()

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
    local cowWorld = cache.cowWorldRef and cache.cowWorldRef.Parent and cache.cowWorldRef or workspace:FindFirstChild("CowWorld")
    if cowWorld then
        local folder = cowWorld:FindFirstChild("MithrilCaveSpiders")
        if folder then
            cache.cachedMithrilCaveFolder = folder
            return folder
        end
    end
    local topFolder = workspace:FindFirstChild("MithrilCaveSpiders")
    if topFolder then
        cache.cachedMithrilCaveFolder = topFolder
        return topFolder
    end

    local now = os.clock()
    if not cache.lastSpiderFolderSearch or (now - cache.lastSpiderFolderSearch >= 3.0) then
        cache.lastSpiderFolderSearch = now
        if cowWorld then
            local folder = cowWorld:FindFirstChild("MithrilCaveSpiders", true)
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
                    local name = clearing.Name
                    local isMob = (string.find(name, "Snake", 1, true) or string.find(name, "Spider", 1, true))
                    if isMob and (clearing:IsA("Model") or clearing:IsA("BasePart")) then
                        if dodge.isMobAlive(clearing) and not table.find(cache.activeAuraMobs, clearing) then
                            table.insert(cache.activeAuraMobs, clearing)
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
            pcall(function() penESP.visualizer:Destroy() end)
            penESP.visualizer = nil
        end
    end
end

-- Cleanup single-chest ESP instances
function chestESP.cleanup()
    if chestESP.espConn then
        pcall(function() chestESP.espConn:Disconnect() end)
        chestESP.espConn = nil
    end
    if chestESP.highlight then
        pcall(function() chestESP.highlight:Destroy() end)
        chestESP.highlight = nil
    end
    if chestESP.billboard then
        pcall(function() chestESP.billboard:Destroy() end)
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
            local rPos = getRootPos(root)
            if rPos and chestPart.Parent then
                local dist = math.floor(get2DDistance(rPos, chestPart.Position))
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
            pcall(function() chestESP.childAddedConn:Disconnect() end)
            chestESP.childAddedConn = nil
        end
        if chestESP.childRemovedConn then
            pcall(function() chestESP.childRemovedConn:Disconnect() end)
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
        pcall(function() manatite.espConn:Disconnect() end)
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
        pcall(function() mithril.espConn:Disconnect() end)
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
    if now - cache.lastSanitationTime > 15 then
        cache.lastSanitationTime = now

        for node, _ in pairs(cache.nodePosition) do
            if not node or not node.Parent then
                cache.nodePosition[node] = nil
            end
        end

        for node, _ in pairs(cache.nodeIDs) do
            if not node or not node.Parent then
                cache.nodeIDs[node] = nil
            end
        end

        for part, _ in pairs(cache.solidObstacle) do
            if not part or not part.Parent then
                cache.solidObstacle[part] = nil
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
                collectgarbage("step", 500)
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

-- Checks if a part represents a solid physical barrier (wall, building, fence, rock)
function farm.isSolidObstacle(instance)
    if not instance or not instance:IsA("BasePart") then return false end
    local cached = cache.solidObstacle[instance]
    if cached ~= nil then return cached end

    if not instance.CanCollide then
        cache.solidObstacle[instance] = false
        return false
    end
    if char and instance:IsDescendantOf(char) then
        cache.solidObstacle[instance] = false
        return false
    end
    if cache.grassFolder and instance:IsDescendantOf(cache.grassFolder) then
        cache.solidObstacle[instance] = false
        return false
    end
    local name = instance.Name
    if name == "VirtualGrass" or name == "Grass" or string.find(name, "Grass", 1, true) then
        cache.solidObstacle[instance] = false
        return false
    end
    local model = instance:FindFirstAncestorOfClass("Model")
    if model and model ~= workspace and (model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("Mob") or model:FindFirstChild("Monster")) then
        cache.solidObstacle[instance] = false
        return false
    end
    cache.solidObstacle[instance] = true
    return true
end

-- Raycasts between startPos and endPos to determine if a solid wall or obstacle obstructs the path
function farm.hasWallBetween(startPos, endPos)
    if not startPos or not endPos then return false end
    local startElevated = startPos + ELEVATED_OFFSET
    local endElevated = endPos + ELEVATED_OFFSET
    local fullDir = endElevated - startElevated
    local totalDist = fullDir.Magnitude
    if totalDist < 1.0 then return false end

    local dirUnit = fullDir.Unit
    local curOrigin = startElevated
    local remainingDist = totalDist
    local maxIterations = 3

    while remainingDist > 0.5 and maxIterations > 0 do
        maxIterations = maxIterations - 1
        local rayDir = dirUnit * remainingDist
        local hit = workspace:Raycast(curOrigin, rayDir, wallRaycastParams)
        if not hit then
            return false
        end

        if farm.isSolidObstacle(hit.Instance) then
            if hit.Normal.Y <= 0.65 then
                return true
            end
        end

        local stepDist = (hit.Position - curOrigin).Magnitude + 0.15
        if stepDist >= remainingDist then
            break
        end
        remainingDist = remainingDist - stepDist
        curOrigin = hit.Position + (dirUnit * 0.15)
    end

    return false
end

-- Checks for forward obstacles: jumps over low obstacles or calculates deflection along wall tangents
function farm.checkForwardWall(rootPos, moveDir, checkDist)
    local dist = checkDist or 4.5
    local dir = moveDir * dist
    local originLow = rootPos + LOW_OFFSET
    local originHigh = rootPos + HIGH_OFFSET
    local originJump = rootPos + JUMP_OFFSET

    local hitLow = workspace:Raycast(originLow, dir, wallRaycastParams)
    local hitHigh = workspace:Raycast(originHigh, dir, wallRaycastParams)

    local lowSolid = hitLow and farm.isSolidObstacle(hitLow.Instance) and (hitLow.Normal.Y <= 0.65)
    local highSolid = hitHigh and farm.isSolidObstacle(hitHigh.Instance) and (hitHigh.Normal.Y <= 0.65)

    if not lowSolid and not highSolid then
        return nil, false
    end

    -- Case 1: Low obstacle (small fence, curb, rock), but high clearance is completely open
    if lowSolid and not highSolid then
        local hitJump = workspace:Raycast(originJump, dir, wallRaycastParams)
        local jumpBlocked = hitJump and farm.isSolidObstacle(hitJump.Instance) and (hitJump.Normal.Y <= 0.65)
        if not jumpBlocked then
            return nil, true
        end
    end

    -- Case 2: Solid wall or obstacle blocking forward motion -> calculate deflection along wall normal
    local hitToUse = highSolid and hitHigh or hitLow
    local hitNormal = hitToUse and hitToUse.Normal
    if hitNormal then
        local norm2D = Vector3.new(hitNormal.X, 0, hitNormal.Z)
        if norm2D.Magnitude > 0.05 then
            norm2D = norm2D.Unit
            local tan1 = Vector3.new(-norm2D.Z, 0, norm2D.X)
            local tan2 = Vector3.new(norm2D.Z, 0, -norm2D.X)

            local chosenTan = (moveDir:Dot(tan1) >= moveDir:Dot(tan2)) and tan1 or tan2
            local steerDir = (chosenTan * 0.85 + norm2D * 0.45).Unit

            -- Check if primary tangent is blocked by an adjacent corner
            local cornerCheck = workspace:Raycast(originHigh, steerDir * 3.0, wallRaycastParams)
            if cornerCheck and farm.isSolidObstacle(cornerCheck.Instance) and (cornerCheck.Normal.Y <= 0.65) then
                local altTan = (chosenTan == tan1) and tan2 or tan1
                steerDir = (altTan * 0.85 + norm2D * 0.45).Unit
            end

            local adjustedPos = rootPos + (steerDir * math.max(4.0, dist))
            return adjustedPos, false
        end
    end

    return nil, false
end

local ESCAPE_ANGLES = {
    0,
    math.pi * 0.25,
    math.pi * 0.5,
    math.pi * 0.75,
    math.pi,
    -math.pi * 0.75,
    -math.pi * 0.5,
    -math.pi * 0.25
}

-- Scans 8 radial directions around the player to locate the clearest escape route
function farm.findClearEscapeDirection(rootPos)
    local bestDir = nil
    local bestScore = -math.huge
    local rayOrigin = rootPos + ELEVATED_OFFSET
    local scanDist = 16.0

    for _, angle in ipairs(ESCAPE_ANGLES) do
        local dir = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local hit = workspace:Raycast(rayOrigin, dir * scanDist, wallRaycastParams)
        local clearDist = scanDist
        if hit and farm.isSolidObstacle(hit.Instance) and (hit.Normal.Y <= 0.65) then
            clearDist = (hit.Position - rayOrigin).Magnitude
        end

        local score = clearDist
        if farm.anchorPos then
            local testPos = rootPos + (dir * 8.0)
            local distFromAnchorSq = get2DDistanceSq(farm.anchorPos, testPos)
            if distFromAnchorSq > farm.radiusSq then
                score = score - 8.0
            else
                score = score + 4.0
            end
        end

        if score > bestScore then
            bestScore = score
            bestDir = dir
        end
    end

    if not bestDir then
        local rootCF = getRootCFrame(root)
        local look = rootCF and rootCF.LookVector or Vector3.new(0, 0, -1)
        bestDir = -Vector3.new(look.X, 0, look.Z).Unit
    end

    return bestDir
end

function farm.processMovement(dt, now, rootPos)
    farm.patternTimer = farm.patternTimer + (dt * farm.patternSpeed)

    -- Anti-Stuck & Real-Time Progress Monitor
    if farm.collisionDetection then
        if now - farm.lastStuckCheckTime >= 0.4 then
            if farm.lastStuckCheckPos then
                local distMovedSq = get2DDistanceSq(rootPos, farm.lastStuckCheckPos)
                if distMovedSq < 1.0 then
                    farm.stuckCounter = farm.stuckCounter + 1
                else
                    farm.stuckCounter = math.max(0, farm.stuckCounter - 1)
                end
            end
            farm.lastStuckCheckPos = rootPos
            farm.lastStuckCheckTime = now

            -- Step 1: Minor stuck (0.8s stationary) -> jump and drop blocked node
            if farm.stuckCounter >= 2 then
                if humanoid then humanoid.Jump = true end
                if farm.currentTargetNode then
                    cache.nodeBlacklist[farm.currentTargetNode] = now + 15
                    farm.currentTargetNode = nil
                    farm.currentNodeStartTime = 0
                end
                farm.nextRandomPos = nil
            end

            -- Step 2: Major stuck (1.2s stationary) -> active unstick escape maneuver
            if farm.stuckCounter >= 3 then
                farm.isUnsticking = true
                farm.unstickEndTime = now + 1.2
                local escapeDir = farm.findClearEscapeDirection(rootPos)
                farm.unstickTargetPos = rootPos + (escapeDir * 12.0)
                farm.stuckCounter = 0
            end
        end

        -- Check if active unsticking period has concluded
        if farm.isUnsticking and now >= farm.unstickEndTime then
            farm.isUnsticking = false
            farm.unstickTargetPos = nil
            farm.stuckCounter = 0
            farm.lastStuckCheckPos = rootPos
        end
    end

    local targetPos

    -- If actively escaping/unsticking, prioritize escape target
    if farm.collisionDetection and farm.isUnsticking and farm.unstickTargetPos then
        targetPos = farm.unstickTargetPos
        if humanoid then humanoid.Jump = true end
    elseif farm.pattern == "Guided Zigzag (Nodes)" then
        local ghostX = math.sin(farm.patternTimer * 1.3) * farm.radius
        local ghostZ = math.cos(farm.patternTimer * 1.9) * farm.radius
        local ghostPos = farm.anchorPos + Vector3.new(ghostX, 0, ghostZ)

        local needNewNode = false
        if not farm.currentTargetNode or not farm.currentTargetNode.Parent then
            if now - farm.lastNodeSearchTime >= 0.25 then
                needNewNode = true
            end
        else
            local tPos = cache.getNodePosition(farm.currentTargetNode)
            local distSq = get2DDistanceSq(rootPos, tPos)
            if distSq < 16 then
                if farm.autoChomp and (now - farm.lastRaycastChompTime >= (farm.grassChompDelay or 0.4)) then
                    farm.processGrassChomp(now, rootPos)
                end
                if not farm.currentTargetNode or (farm.currentNodeStartTime > 0 and (now - farm.currentNodeStartTime > 2.0)) then
                    needNewNode = true
                end
            elseif farm.onlyMatureGrass then
                local currGrowth = farm.currentTargetNode:GetAttribute("GrowthState") or farm.currentTargetNode:GetAttribute("growthState") or farm.currentTargetNode:GetAttribute("growth_state")
                if currGrowth and string.lower(tostring(currGrowth)) ~= "mature" then
                    cache.nodeBlacklist[farm.currentTargetNode] = now + 5
                    farm.currentTargetNode = nil
                    farm.currentNodeStartTime = 0
                    needNewNode = true
                end
            elseif farm.currentNodeStartTime > 0 and (now - farm.currentNodeStartTime > 4.5) then
                -- Timeout: couldn't reach node within 4.5 seconds
                cache.nodeBlacklist[farm.currentTargetNode] = now + 15
                farm.currentTargetNode = nil
                farm.currentNodeStartTime = 0
                needNewNode = true
            elseif farm.collisionDetection and farm.stuckCounter >= 1 and farm.hasWallBetween(rootPos, tPos) then
                -- Impassable wall blocking the target node while stalled
                cache.nodeBlacklist[farm.currentTargetNode] = now + 15
                farm.currentTargetNode = nil
                farm.currentNodeStartTime = 0
                needNewNode = true
            end
        end

        if needNewNode then
            farm.lastNodeSearchTime = now
            local nearestDistSq = math.huge
            local nearestNode = nil
            local fallbackNode = nil
            local fallbackDistSq = math.huge
            local grassNodes = cache.getGrassNodes()

            for _, node in ipairs(grassNodes) do
                if node.Parent then
                    local nodePos = cache.getNodePosition(node)
                    if get2DDistanceSq(farm.anchorPos, nodePos) <= farm.radiusSq then
                        local growth = node:GetAttribute("GrowthState") or node:GetAttribute("growthState") or node:GetAttribute("growth_state")
                        if not farm.onlyMatureGrass or (growth and string.lower(tostring(growth)) == "mature") then
                            local nodeId = cache.getNodeID(node)
                            if nodeId then
                                local distFromGhostSq = get2DDistanceSq(ghostPos, nodePos)
                                local blacklistedAt = cache.nodeBlacklist[node]
                                if not blacklistedAt or now - blacklistedAt > 10 then
                                    if distFromGhostSq < fallbackDistSq then
                                        fallbackDistSq = distFromGhostSq
                                        fallbackNode = node
                                    end

                                    if distFromGhostSq < nearestDistSq then
                                        local isBlocked = false
                                        if farm.collisionDetection then
                                            isBlocked = farm.hasWallBetween(rootPos, nodePos)
                                        end

                                        if not isBlocked then
                                            nearestDistSq = distFromGhostSq
                                            nearestNode = node
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local chosenNode = nearestNode or (not farm.collisionDetection and fallbackNode)
            if chosenNode then
                farm.currentTargetNode = chosenNode
                farm.currentNodeStartTime = now
                cache.nodeBlacklist[chosenNode] = now
                farm.lastNodeSearchTime = 0
            else
                farm.currentTargetNode = nil
                farm.currentNodeStartTime = 0
                if not farm.nextRandomPos or get2DDistanceSq(rootPos, farm.nextRandomPos) < 25 then
                    local foundSafe = false
                    if farm.collisionDetection then
                        local maxDist = math.max(5, math.floor(farm.radius))
                        local minDist = math.min(5, maxDist)
                        for _ = 1, 6 do
                            local angle = math.random() * (math.pi * 2)
                            local dist = math.random(minDist, maxDist)
                            local candidatePos = farm.anchorPos + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
                            if not farm.hasWallBetween(rootPos, candidatePos) then
                                farm.nextRandomPos = candidatePos
                                foundSafe = true
                                break
                            end
                        end
                    end
                    if not foundSafe then
                        local angle = math.random() * (math.pi * 2)
                        farm.nextRandomPos = farm.anchorPos + Vector3.new(math.cos(angle) * farm.radius, 0, math.sin(angle) * farm.radius)
                    end
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
            local foundSafe = false
            if farm.collisionDetection then
                local maxDist = math.max(5, math.floor(farm.radius))
                local minDist = math.min(5, maxDist)
                for _ = 1, 6 do
                    local angle = math.random() * (math.pi * 2)
                    local dist = math.random(minDist, maxDist)
                    local candidatePos = farm.anchorPos + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
                    if not farm.hasWallBetween(rootPos, candidatePos) then
                        farm.nextRandomPos = candidatePos
                        foundSafe = true
                        break
                    end
                end
            end
            if not foundSafe then
                local angle = math.random() * (math.pi * 2)
                farm.nextRandomPos = farm.anchorPos + Vector3.new(math.cos(angle) * farm.radius, 0, math.sin(angle) * farm.radius)
            end
        end
        targetPos = farm.nextRandomPos
    end

    if targetPos and (now - farm.lastMoveTime > 0.05) then
        -- Forward obstacle check & dynamic wall deflection
        if farm.collisionDetection and not farm.isUnsticking then
            local moveVec = targetPos - rootPos
            local moveDist = Vector3.new(moveVec.X, 0, moveVec.Z).Magnitude
            if moveDist > 1.5 then
                local moveDir = Vector3.new(moveVec.X, 0, moveVec.Z).Unit
                local adjustedPos, shouldJump = farm.checkForwardWall(rootPos, moveDir, math.min(moveDist, 5.0))
                if shouldJump and humanoid then
                    humanoid.Jump = true
                end
                if adjustedPos then
                    targetPos = adjustedPos
                end
            end
        end

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
    local closestMob = nil
    local closestDistSq = math.huge
    local closestMobPos = nil

    for _, mob in ipairs(cache.activeAuraMobs) do
        if mob.Parent then
            local mobPos = dodge.getMobAttackOrigin(mob) or (mob:IsA("Model") and mob:GetPivot().Position or mob.Position)
            if mobPos then
                local distSq = get3DDistanceSq(auraOrigin, mobPos)
                if distSq <= farm.mobAuraRadiusSq and distSq < closestDistSq then
                    if dodge.isMobAlive(mob) then
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
    local chompDelay = farm.grassChompDelay or 0.4
    if (now - farm.lastRaycastChompTime >= chompDelay) then
        if farm.chompOnlyWhileMoving then
            local isMoving = (humanoid and humanoid.MoveDirection.Magnitude > 0.05)
                or (root and Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude > 0.5)
            if not isMoving then
                return
            end
        end
        farm.lastRaycastChompTime = now

        local targetNodeId = nil
        local targetInstance = nil
        local repeatDelay = farm.grassChompRepeatDelay or (chompDelay + 0.1)

        local function tryCandidate(inst, id)
            if not id and inst then
                id = cache.getNodeID(inst) or cache.extractGrassNodeId(inst)
            end
            if not id then return false end

            -- If candidate is the last chomped node, only accept if repeatDelay has elapsed
            if id == farm.lastChompedNode and (now - farm.chompCooldown < repeatDelay) then
                return false
            end

            targetNodeId = id
            targetInstance = inst
            return true
        end

        -- 1. Primary: Game's native CowGrassPrediction SelectionBox in Camera (mouth/view target)
        local camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera") or workspace:FindFirstChild("Camera")
        local predBox = camera and camera:FindFirstChild("CowGrassPrediction")
        if predBox then
            local adornee = nil
            local pcallOk, propVal = pcall(function() return predBox.Adornee end)
            if pcallOk and propVal then
                adornee = propVal
            else
                adornee = predBox:GetAttribute("Adornee") or predBox:GetAttribute("Target") or predBox:GetAttribute("Node")
            end

            if adornee then
                local resolved = (typeof(adornee) == "Instance" and cache.resolveGrassNode(adornee)) or adornee
                local pos = (typeof(resolved) == "Instance" and cache.getNodePosition(resolved))
                -- Ensure prediction target is within reasonable eating reach (<= 7 studs / 49 sq)
                if not pos or get2DDistanceSq(rootPos, pos) <= 49 then
                    local id = cache.extractGrassNodeId(resolved) or (typeof(resolved) == "Instance" and cache.getNodeID(resolved))
                    tryCandidate(resolved, id)
                end
            end
        end

        -- 2. Physical Downward Raycast: Directly detect grass beneath character
        if not targetNodeId then
            local hit = workspace:Raycast(rootPos, RAYCAST_DOWN, raycastParams)
            if hit and hit.Instance then
                local rayNode = cache.resolveGrassNode(hit.Instance)
                if rayNode then
                    tryCandidate(rayNode, cache.getNodeID(rayNode))
                end
            end
        end

        -- 3. Proximity Fallback 1: Current target node within 6 studs (36 sq)
        if not targetNodeId and farm.currentTargetNode and farm.currentTargetNode.Parent then
            local tPos = cache.getNodePosition(farm.currentTargetNode)
            if tPos and get2DDistanceSq(rootPos, tPos) <= 36 then
                tryCandidate(farm.currentTargetNode, cache.getNodeID(farm.currentTargetNode))
            end
        end

        -- 4. Proximity Fallback 2: Any grass node in CowVirtualGrass within 6 studs (closest)
        if not targetNodeId then
            local grassNodes = cache.getGrassNodes()
            local bestDistSq = 36
            local bestNode = nil
            for _, node in ipairs(grassNodes) do
                if node and node.Parent then
                    local nodePos = cache.getNodePosition(node)
                    if nodePos then
                        local dSq = get2DDistanceSq(rootPos, nodePos)
                        if dSq < bestDistSq then
                            local id = cache.getNodeID(node)
                            if id and (id ~= farm.lastChompedNode or (now - farm.chompCooldown >= repeatDelay)) then
                                bestDistSq = dSq
                                bestNode = node
                            end
                        end
                    end
                end
            end
            if bestNode then
                tryCandidate(bestNode, cache.getNodeID(bestNode))
            end
        end

        -- 5. Fire Chomp Request
        if targetNodeId then
            if (now - farm.chompCooldown >= chompDelay) and (targetNodeId ~= farm.lastChompedNode or (now - farm.chompCooldown >= repeatDelay)) then
                chompEvent:FireServer(targetNodeId)
                farm.lastChompedNode = targetNodeId
                farm.chompCooldown = now

                if farm.currentTargetNode then
                    local currId = cache.getNodeID(farm.currentTargetNode)
                    if farm.currentTargetNode == targetInstance
                        or farm.currentTargetNode.Name == targetNodeId
                        or (targetInstance and typeof(targetInstance) == "Instance" and farm.currentTargetNode.Name == targetInstance.Name)
                        or (currId and currId == targetNodeId) then
                        farm.currentTargetNode = nil
                        farm.currentNodeStartTime = 0
                        farm.lastNodeSearchTime = 0
                    end
                end
            end
        end
    end
end

function farm.applyGoldenAura(customRadius)
    local rootPos = getRootPos(root)
    if not rootPos then return 0 end
    local radius = customRadius or farm.goldenAuraRadius or 60
    local radiusSq = radius * radius
    local grassNodes = cache.getGrassNodes()
    local count = 0

    for _, node in ipairs(grassNodes) do
        if node and node.Parent then
            local nodePos = cache.getNodePosition(node)
            if nodePos and get2DDistanceSq(rootPos, nodePos) <= radiusSq then
                local nodeId = cache.getNodeID(node)
                if nodeId then
                    local isGolden = node:GetAttribute("Golden")
                    if isGolden == nil then
                        isGolden = node:GetAttribute("golden")
                    end
                    if isGolden ~= true then
                        pcall(function()
                            node:SetAttribute("Golden", true)
                        end)
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end
farm.setGoldenGrassAroundMe = farm.applyGoldenAura

if getgenv then
    getgenv().ApplyGoldenAura = farm.applyGoldenAura
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
function updateHeartbeatConnection()
    if farm.on or farm.autoChomp or farm.autoFish or farm.autoChompMobs or dodge.auto or farm.goldenAura or (manatite and manatite.auto) or (mithril and mithril.auto) or (trickOrTreat and trickOrTreat.auto) then
        if not HeartbeatConnection then
            HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
                if not root or not root.Parent or not root:IsA("BasePart") then
                    local currentCharacter = resolveCharacter()
                    if currentCharacter then
                        char = currentCharacter
                        root = resolveRoot(currentCharacter)
                    end
                end
                if not humanoid or not humanoid.Parent then
                    local currentCharacter = resolveCharacter()
                    if currentCharacter then
                        humanoid = resolveHumanoid(currentCharacter)
                    end
                end

                if not root or not humanoid or not root.Parent or not humanoid.Parent or humanoid.Health <= 0 then
                    if dodge.isUnderground then
                        dodge.isUnderground = false
                        pcall(function() if root and root:IsA("BasePart") then root.Anchored = false end end)
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
                local rootPos = getRootPos(root)
                if not rootPos then return end

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
                local totPausing = (trickOrTreat and trickOrTreat.isCycling and trickOrTreat.pauseFarmDuringCycle ~= false)
                if farm.on and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not totPausing and farm.anchorPos and not dodge.isDodging and not dodge.isUnderground then
                    farm.processMovement(dt, now, rootPos)
                end

                local prioritizedMobThisFrame = false

                -- 2. Priority Mob Aura Logic
                if farm.autoChompMobs and not totPausing then
                    prioritizedMobThisFrame = farm.processMobAura(now, rootPos)
                end

                -- 3. Raycast Grass Chomp Logic (Yields to Mobs & Dodging)
                if farm.autoChomp and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not totPausing and not prioritizedMobThisFrame and not dodge.isUnderground and not dodge.isDodging then
                    farm.processGrassChomp(now, rootPos)
                end

                -- 3b. Golden Grass Aura Logic (Periodic Pulse)
                if farm.goldenAura and not totPausing and (now - farm.lastGoldenAuraTime > 0.3) then
                    farm.lastGoldenAuraTime = now
                    farm.applyGoldenAura()
                end

                -- 4. Auto-Fishing Logic
                if farm.autoFish and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not totPausing then
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
            setRootCFrame(dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0))
            pcall(function() root.Anchored = false end)
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
        farm.currentNodeStartTime = 0
        farm.isUnsticking = false
        farm.unstickTargetPos = nil
        farm.stuckCounter = 0
        farm.lastStuckCheckPos = nil
        farm.lastStuckCheckTime = 0
        farm.lastNodeSearchTime = 0

        if Value then
            farm.collisionDetection = true
            farm.isUnsticking = false
            farm.unstickTargetPos = nil
            farm.stuckCounter = 0
            farm.anchorPos = getRootPos(root) or Vector3.zero

            Window:Notify({
                Title = "Autofarm Enabled",
                Content = "Absolute static home base set. Walking started with anti-stuck enabled.",
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
    Name = "Enable Golden Grass Aura",
    CurrentValue = false,
    Flag = "Toggle_GoldenAura",
    Callback = function(Value)
        farm.goldenAura = Value
        if Value then
            farm.applyGoldenAura()
        end
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
    Name = "Enable Trick or Treat Autofarm",
    CurrentValue = false,
    Flag = "Toggle_TrickOrTreat_Main",
    Callback = function(Value)
        trickOrTreat.toggle(Value)
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
                setRootCFrame(dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0))
                pcall(function() root.Anchored = false end)
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
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
    Name = "Grass Chomp Speed",
    Options = {
        "Instant (0.05s) [Unsafe - Firing faster than server intends]",
        "Extreme (0.1s) [Unsafe - Firing faster than server intends]",
        "Ultra (0.2s) [Unsafe - Firing faster than server intends]",
        "Hyper (0.3s) [Unsafe - Firing faster than server intends]",
        "Fastest Safe (0.4s - Server Minimum)",
        "Fast (0.5s)",
        "Balanced (0.6s)",
        "Default (0.7s - Game Base)",
        "Safe (1.0s)",
        "Very Slow (1.5s)"
    },
    CurrentOption = {"Fastest Safe (0.4s - Server Minimum)"},
    MultipleOptions = false,
    Flag = "Dropdown_GrassSpeed",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        local selStr = tostring(selection)
        if string.find(selStr, "0.05") then
            farm.grassChompDelay = 0.05
            farm.grassChompRepeatDelay = 0.08
        elseif string.find(selStr, "0.1") then
            farm.grassChompDelay = 0.1
            farm.grassChompRepeatDelay = 0.15
        elseif string.find(selStr, "0.2") then
            farm.grassChompDelay = 0.2
            farm.grassChompRepeatDelay = 0.25
        elseif string.find(selStr, "0.3") then
            farm.grassChompDelay = 0.3
            farm.grassChompRepeatDelay = 0.35
        elseif string.find(selStr, "0.4") then
            farm.grassChompDelay = 0.4
            farm.grassChompRepeatDelay = 0.5
        elseif string.find(selStr, "0.5") then
            farm.grassChompDelay = 0.5
            farm.grassChompRepeatDelay = 0.7
        elseif string.find(selStr, "0.6") then
            farm.grassChompDelay = 0.6
            farm.grassChompRepeatDelay = 0.8
        elseif string.find(selStr, "0.7") then
            farm.grassChompDelay = 0.7
            farm.grassChompRepeatDelay = 1.0
        elseif string.find(selStr, "1.0") then
            farm.grassChompDelay = 1.0
            farm.grassChompRepeatDelay = 1.5
        elseif string.find(selStr, "1.5") then
            farm.grassChompDelay = 1.5
            farm.grassChompRepeatDelay = 2.0
        else
            farm.grassChompDelay = math.max(0.01, tonumber(string.match(selStr, "(%d+%.?%d*)")) or 0.4)
            farm.grassChompRepeatDelay = farm.grassChompDelay + 0.1
        end
        pcall(function() Window:Set("Slider_GrassChompDelay", farm.grassChompDelay) end)
        if farm.grassChompDelay < 0.4 then
            pcall(function()
                Window:Notify({
                    Title = "Unsafe Chomp Speed",
                    Content = string.format("Set to %.2fs (Unsafe: Firing faster than server intends).", farm.grassChompDelay),
                    Duration = 3,
                })
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Chomp Only While Moving",
    CurrentValue = true,
    Flag = "Toggle_ChompOnlyMoving",
    Callback = function(Value)
        farm.chompOnlyWhileMoving = Value
    end,
})

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

MainTab:CreateToggle({
    Name = "Focus Only Mature Grass",
    CurrentValue = true,
    Flag = "Toggle_OnlyMatureGrass",
    Callback = function(Value)
        farm.onlyMatureGrass = Value
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

MainTab:CreateButton({
    Name = "Turn On Golden Grass (Once)",
    Callback = function()
        local count = farm.applyGoldenAura(farm.goldenAuraRadius or 60)
        Window:Notify({
            Title = "Golden Aura",
            Content = "Turned golden for " .. tostring(count) .. " nearby grass nodes.",
            Duration = 2.5,
            Image = 4483362458,
        })
    end,
})

MainTab:CreateSection({ Name = "Mob Attack Dodge Configuration" })

MainTab:CreateDropdown({
    Name = "Dodge Method",
    Options = {"Underground", "Run Away (Surface)", "Teleport Away (Surface)"},
    CurrentOption = {"Teleport Away (Surface)"},
    MultipleOptions = false,
    Flag = "Dropdown_DodgeMethod",
    Callback = function(Option)
        dodge.method = type(Option) == "table" and Option[1] or Option
        if dodge.method ~= "Underground" and dodge.isUnderground and root and dodge.lastSurfaceCFrame then
            setRootCFrame(dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0))
            pcall(function() root.Anchored = false end)
            dodge.isUnderground = false
        end
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
-- UI SETUP: Sliders Tab
-- ==========================
local SlidersTab = Window:CreateTab({ Name = "Sliders", Icon = 4483362458 })

SlidersTab:CreateSection({ Name = "Autofarm & Movement Sliders" })

SlidersTab:CreateSlider({
    Name = "Farm Radius (Studs)",
    Range = {10, 300},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 75,
    Flag = "Slider_Radius",
    Callback = function(Value)
        farm.radius = Value
        farm.radiusSq = farm.radius * farm.radius
        if penESP and penESP.update then
            pcall(penESP.update)
        end
    end,
})

SlidersTab:CreateSlider({
    Name = "Golden Aura Radius",
    Range = {10, 150},
    Increment = 5,
    Suffix = "Studs",
    CurrentValue = 60,
    Flag = "Slider_GoldenRadius",
    Callback = function(Value)
        farm.goldenAuraRadius = Value
    end,
})

SlidersTab:CreateSlider({
    Name = "Grass Chomp Delay (<0.4s Unsafe: Faster than Server Intends)",
    Range = {0.05, 2.0},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = farm.grassChompDelay or 0.4,
    Flag = "Slider_GrassChompDelay",
    Callback = function(Value)
        farm.grassChompDelay = Value
        farm.grassChompRepeatDelay = Value + 0.1
    end,
})

SlidersTab:CreateSection({ Name = "Mob Attack Dodge Sliders" })

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
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

SlidersTab:CreateSection({ Name = "Mining Sliders (Manatite & Mithril)" })

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
    Name = "Manatite Teleport Height Offset",
    Range = {0, 8},
    Increment = 0.5,
    Suffix = "Studs",
    CurrentValue = 2.5,
    Flag = "Slider_ManatiteHeight",
    Callback = function(Value)
        manatite.heightOffset = Value
    end,
})

SlidersTab:CreateSlider({
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

SlidersTab:CreateSlider({
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

SlidersTab:CreateSection({ Name = "Performance Sliders" })

SlidersTab:CreateSlider({
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
    CurrentOption = {"Largest Crystal Yield"},
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
    Flag = "Input_DiscordWebhook",
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

ScannerTab:CreateSection({ Name = "Auction House Tools" })

ScannerTab:CreateButton({
    Name = "Refresh Auction Display",
    Callback = function()
        auction.updateAllLotDisplays()
        Window:Notify({ Title = "Refreshed", Content = "Auction lot displays updated.", Duration = 2 })
    end,
})

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

function auction.executeBid(lotName, customAmount, isManual)
    if type(customAmount) == "boolean" and isManual == nil then
        isManual = customAmount
        customAmount = nil
    end

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

    local amount = tonumber(customAmount) or tonumber(auction.customBidAmounts[lotName]) or tonumber(minBid) or minBid

    local success, result = pcall(function()
        return auction.remote:InvokeServer({
            Slot = slot,
            Round = round,
            Action = "Bid",
            Amount = amount
        })
    end)

    if success then
        local skinName = lot:GetAttribute("SkinName") or skinId
        Window:Notify({
            Title = isManual and "Manual Bid Placed" or "Auto Bid Placed!",
            Content = string.format("%s (%s)\nAmount: 🪙 %s", lotName, tostring(skinName), formatNumber(amount)),
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

function auction.parseAmount(input)
    if not input then return nil end
    local str = type(input) == "table" and (input.CurrentValue or input.Text or input[1]) or tostring(input)
    str = str:gsub("%$", ""):gsub(",", ""):gsub("_", ""):gsub("%s+", "")
    if str == "" then return nil end

    local mult = 1
    local lower = str:lower()
    if lower:sub(-1) == "k" then
        mult = 1000
        str = str:sub(1, -2)
    elseif lower:sub(-1) == "m" then
        mult = 1000000
        str = str:sub(1, -2)
    elseif lower:sub(-1) == "b" then
        mult = 1000000000
        str = str:sub(1, -2)
    end

    local num = tonumber(str)
    if num and num > 0 then
        return math.floor(num * mult)
    end
    return nil
end

function auction.findTextBox(lotName)
    local parent = nil
    if gethui then
        pcall(function() parent = gethui() end)
    end
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent and plr then
        pcall(function() parent = plr:FindFirstChild("PlayerGui") end)
    end
    if not parent then return nil end

    local searchPattern = "Bid Amount (" .. lotName .. ")"
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextBox") then
            local p = desc.Parent
            while p and p ~= parent do
                local title = p:FindFirstChild("Title")
                if title and title:IsA("TextLabel") and title.Text == searchPattern then
                    return desc
                end
                p = p.Parent
            end
        end
    end
    return nil
end

function auction.resolveCustomAmount(lotName)
    local val = auction.customBidAmounts[lotName]
    if val and val > 0 then return val end

    local flagName = "Input_SkinBid_" .. lotName
    if Window and Window.Flags and Window.Flags[flagName] ~= nil then
        val = auction.parseAmount(Window.Flags[flagName])
        if val and val > 0 then
            auction.customBidAmounts[lotName] = val
            return val
        end
    end

    if Rayfield and Rayfield.Flags and Rayfield.Flags[flagName] ~= nil then
        val = auction.parseAmount(Rayfield.Flags[flagName])
        if val and val > 0 then
            auction.customBidAmounts[lotName] = val
            return val
        end
    end

    local tb = auction.findTextBox(lotName)
    if tb and tb.Text and tb.Text ~= "" then
        val = auction.parseAmount(tb.Text)
        if val and val > 0 then
            auction.customBidAmounts[lotName] = val
            return val
        end
    end

    return nil
end

function auction.setupLotUI(tab, lotName)
    tab:CreateSection({ Name = "Skin Lot: " .. lotName })

    local initialTitle, initialBody = auction.getLotDisplayInfo(lotName)
    local card = nil
    if tab.CreateText then
        pcall(function()
            card = tab:CreateText({
                name = initialTitle,
                text = initialBody
            })
        end)
    end
    if not card and tab.CreateParagraph then
        pcall(function()
            card = tab:CreateParagraph({
                Title = initialTitle,
                Content = initialBody
            })
        end)
    end
    auction.cards[lotName] = card

    tab:CreateInput({
        Name = "Bid Amount (" .. lotName .. ")",
        CurrentValue = "",
        PlaceholderText = "Enter custom amount (e.g. 50000 or 50k)",
        RemoveTextAfterFocusLost = false,
        Flag = "Input_SkinBid_" .. lotName,
        Callback = function(Text)
            local num = auction.parseAmount(Text)
            if num and num > 0 then
                auction.customBidAmounts[lotName] = num
            else
                auction.customBidAmounts[lotName] = nil
            end
        end,
    })

    task.spawn(function()
        task.wait(0.2)
        local tb = auction.findTextBox(lotName)
        if tb then
            tb:GetPropertyChangedSignal("Text"):Connect(function()
                local num = auction.parseAmount(tb.Text)
                if num and num > 0 then
                    auction.customBidAmounts[lotName] = num
                end
            end)
        end
    end)

    tab:CreateButton({
        Name = "Bid Minimum / Next " .. lotName,
        Callback = function()
            auction.executeBid(lotName, nil, true)
        end,
    })

    tab:CreateButton({
        Name = "Bid Custom Amount (" .. lotName .. ")",
        Callback = function()
            local custom = auction.resolveCustomAmount(lotName)
            if not custom then
                Window:Notify({ Title = "No Amount", Content = "Please enter an amount in the input above first.", Duration = 3 })
                return
            end
            auction.executeBid(lotName, custom, true)
        end,
    })
end

for _, lotName in ipairs(auction.lotNames) do
    auction.setupLotUI(ScannerTab, lotName)
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
    CurrentValue = "",
    PlaceholderText = "Enter max coins (e.g. 5000000 or 5m)",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_MaxAutoBid",
    Callback = function(Text)
        local num = auction.parseAmount(Text) or 0
        auction.maxAutoBidLimit = num
        Window:Notify({
            Title = "Limit Updated",
            Content = num == 0 and "Max bid limit set to Unlimited." or ("Max bid limit set to: " .. formatNumber(num)),
            Duration = 3
        })
    end,
})

-- ==========================
-- TOWN AUCTION LOGIC & UI SETUP
-- ==========================
function townAuction.getFitoutModel()
    if townAuction.fitoutModel and townAuction.fitoutModel.Parent then
        return townAuction.fitoutModel
    end
    local cowWorld = workspace:FindFirstChild("CowWorld")
    local geom = cowWorld and cowWorld:FindFirstChild("Geometry")
    local townUpdate = geom and geom:FindFirstChild("Cow Town WIP Update (DO NOT DELETE UNDER ANY CIRCUMSTANCES)")
    local village = townUpdate and townUpdate:FindFirstChild("RoundaboutVillage")
    local creamery = village and village:FindFirstChild("ButtercupCreamery")
    local fitout = creamery and creamery:FindFirstChild("TownStoreFitout")
    if not fitout then
        local now = os.clock()
        if not townAuction.lastFitoutSearch or (now - townAuction.lastFitoutSearch >= 3.0) then
            townAuction.lastFitoutSearch = now
            fitout = workspace:FindFirstChild("TownStoreFitout", true)
        end
    end
    townAuction.fitoutModel = fitout
    return fitout
end

function townAuction.getRemote()
    if townAuction.remote and townAuction.remote.Parent then
        return townAuction.remote
    end
    if cowRemotes then
        townAuction.remote = cowRemotes:FindFirstChild("CowTownAuctionRequest")
    end
    if not townAuction.remote then
        pcall(function()
            local cg = game:GetService("ReplicatedStorage"):WaitForChild("CowGame", 2)
            local rem = cg and cg:WaitForChild("Remotes", 2)
            townAuction.remote = rem and rem:FindFirstChild("CowTownAuctionRequest")
        end)
    end
    return townAuction.remote
end

function townAuction.formatRemainingTime(endsAt)
    if not endsAt or type(endsAt) ~= "number" or endsAt <= 0 then return "N/A" end
    local nowTime = os.time()
    if townAuction.serverNow and townAuction.snapshotTimestamp and townAuction.snapshotTimestamp > 0 then
        nowTime = townAuction.serverNow + (os.time() - townAuction.snapshotTimestamp)
    end
    local remaining = math.max(0, endsAt - nowTime)
    if remaining <= 0 then
        return "Ended / Rotating"
    end
    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    local seconds = remaining % 60
    if days > 0 then
        return string.format("%dd %02dh %02dm", days, hours, minutes)
    elseif hours > 0 then
        return string.format("%dh %02dm %02ds", hours, minutes, seconds)
    else
        return string.format("%dm %02ds", minutes, seconds)
    end
end

function townAuction.getSlotDisplayInfo(slotName)
    local lot = townAuction.lotsBySlot[slotName]
        or (slotName == "BuyNow" and townAuction.lotsBySlot["BuyNow1"])
        or (slotName == "BuyNow1" and townAuction.lotsBySlot["BuyNow"])
    local fitout = townAuction.getFitoutModel()
    local model = fitout and (fitout:FindFirstChild(slotName)
        or (slotName == "BuyNow" and fitout:FindFirstChild("BuyNow1"))
        or (slotName == "BuyNow1" and fitout:FindFirstChild("BuyNow")))

    local category = townAuction.slotCategories[slotName] or "Auction"

    local itemName = (lot and lot.Name)
        or (model and (model:GetAttribute("TownAuctionName") or model:GetAttribute("Name") or model:GetAttribute("TownAuctionItemID")))
        or "[Unknown Item]"
    local itemId = (lot and lot.ItemId)
        or (model and (model:GetAttribute("TownAuctionItemID") or model:GetAttribute("ItemId")))
        or "N/A"
    local rarity = (lot and lot.Rarity)
        or (model and (model:GetAttribute("TownAuctionRarity") or model:GetAttribute("Rarity")))
        or "Common"
    local scope = (lot and lot.Scope)
        or (model and (model:GetAttribute("TownAuctionScope") or model:GetAttribute("Scope")))
        or category
    local round = (lot and lot.Round)
        or (model and (model:GetAttribute("TownAuctionRound") or model:GetAttribute("Round")))
        or "N/A"
    local endsAt = (lot and lot.EndsAt)
        or (model and (model:GetAttribute("TownAuctionEndsAt") or model:GetAttribute("EndsAt")))
    local price = (lot and lot.Price)
        or (model and (model:GetAttribute("TownAuctionPrice") or model:GetAttribute("Price")))
    local bid = (lot and lot.Bid)
        or (model and (model:GetAttribute("TownAuctionBid") or model:GetAttribute("Bid")))
        or 0
    local minBid = (lot and lot.Minimum)
        or (model and (model:GetAttribute("TownAuctionMinimum") or model:GetAttribute("Minimum")))
        or (price or 1)
    local currency = (lot and lot.Currency) or townAuction.currency or "MooBucks"
    local isEmpty = (lot and lot.Empty == true)
        or (model and model:GetAttribute("TownAuctionEmpty") == true)
        or (itemId == "N/A" and (not lot or not lot.Name))

    if isEmpty then
        local title = string.format("%s: [Empty / Inactive] (%s)", slotName, scope)
        local body = string.format("Status: Empty Lot\nNo active item listed for this slot.\nScope: %s | Round: %s", scope, tostring(round))
        return title, body, nil, minBid, round
    end

    local leaderName = (lot and lot.Leader) or (model and model:GetAttribute("Leader"))
    local leaderId = (lot and lot.LeaderId) or (model and model:GetAttribute("LeaderId"))
    local myDisplayName = tostring(plr:GetAttribute("DisplayName") or plr.DisplayName or plr.Name)
    local myUsername = plr.Name
    local myUserId = plr.UserId

    local leaderStatus
    if not leaderName or leaderName == "" or leaderName == "None" then
        leaderStatus = "None (No bids yet)"
    elseif (leaderId and leaderId == myUserId) or leaderName == myDisplayName or leaderName == myUsername then
        leaderStatus = "⭐ YOU (" .. tostring(leaderName) .. ") - Leading"
    else
        leaderStatus = "👤 " .. tostring(leaderName) .. " (Outbid)"
    end

    local ownedCount = 0
    if itemId and townAuction.ownedCopies[itemId] then
        ownedCount = townAuction.ownedCopies[itemId]
    end

    local isBuyNow = string.find(slotName, "BuyNow") ~= nil
    local title = string.format("%s: %s [%s] (%s)", slotName, tostring(itemName), tostring(rarity), tostring(scope))
    local priceLine = ""
    if isBuyNow then
        priceLine = string.format("Price: 🪙 %s %s", formatNumber(price or minBid or 0), currency)
    elseif price and price > 0 then
        priceLine = string.format("Price: 🪙 %s %s | Next Min: 🪙 %s %s", formatNumber(price), currency, formatNumber(minBid), currency)
    else
        priceLine = string.format("Current Bid: 🪙 %s %s | Next Min: 🪙 %s %s", formatNumber(bid), currency, formatNumber(minBid), currency)
    end

    local body = string.format("%s\nLeader: %s\nRound: %s | Ends In: %s\nItem ID: %s | Owned Copies: %d",
        priceLine,
        leaderStatus,
        tostring(round),
        townAuction.formatRemainingTime(endsAt),
        tostring(itemId),
        ownedCount
    )

    return title, body, itemName, minBid, round
end

function townAuction.updateCard(slotName)
    local card = townAuction.cards[slotName]
    if not card then return end
    local title, body = townAuction.getSlotDisplayInfo(slotName)
    pcall(function()
        if card.SetTitle then
            card:SetTitle(title)
            card:Set(body)
        elseif card.Set then
            card:Set({ Title = title, Content = body })
        end
    end)
end

function townAuction.updateInfoCard()
    if not townAuction.infoCard then return end
    local balanceStr = formatNumber(townAuction.balance)
    local taxPct = string.format("%.1f%%", (townAuction.taxBasisPoints or 1000) / 100)
    local lastUpdated = townAuction.lastSnapshotTime > 0
        and os.date("%I:%M:%S %p", townAuction.lastSnapshotTime)
        or "Not fetched yet"
    local activeCount = 0
    for _, slotName in ipairs(townAuction.slots) do
        local lot = townAuction.lotsBySlot[slotName]
        if lot and not lot.Empty then
            activeCount = activeCount + 1
        end
    end

    local title = string.format("Town Auction Overview | %s %s", balanceStr, townAuction.currency)
    local body = string.format(
        "🪙 Balance: %s %s | Tax Basis: %s\n📦 Delivery Held: %s | Held: %s\n🏷️ Active Lots: %d / %d | Last Sync: %s",
        balanceStr,
        townAuction.currency,
        taxPct,
        formatNumber(townAuction.deliveryHeld or 0),
        formatNumber(townAuction.held or 0),
        activeCount,
        #townAuction.slots,
        lastUpdated
    )

    pcall(function()
        if townAuction.infoCard.SetTitle then
            townAuction.infoCard:SetTitle(title)
            townAuction.infoCard:Set(body)
        elseif townAuction.infoCard.Set then
            townAuction.infoCard:Set({ Title = title, Content = body })
        end
    end)
end

function townAuction.updateAllCards()
    for _, slotName in ipairs(townAuction.slots) do
        townAuction.updateCard(slotName)
    end
    townAuction.updateInfoCard()
end

local townAuctionResultMessages = {
    Purchased = "Purchased! Your item is being delivered.",
    Accepted = "Your bid is now the highest.",
    Listed = "Your exact item copy is listed.",
    PurchaseSaving = "Your purchase is saving. It will not charge twice if you try again.",
    Pending = "Confirmation is pending. Your funds or item remain reserved.",
    Saving = "Saving your reservation. Please try again shortly.",
    SlotOccupied = "That player auction spot was taken. Your item is being returned.",
    InventoryFull = "There is no room for another copy of this item.",
    OfferChanged = "That offer has changed. The current offers are shown below.",
    AlreadyLeading = "You are already the highest bidder.",
    BidTooLow = "A higher bid is required.",
    UnequipRequired = "Unequip this item before listing it.",
    Cancelled = "Listing cancelled. Your exact copy returns when your inventory has room.",
    BidsAlreadyPlaced = "This listing already has bids and must finish its auction.",
    ListingNotFound = "That listing has already finished. Your inventory is up to date.",
    RoundBusy = "This round is busy. Please use another auction or wait for the next offer.",
    DuplicateRequired = "You need a duplicate. Your first copy stays in your Closet.",
    RarityNotEligible = "Player auctions accept Super Rare and Mythic duplicates only. Your first copy cannot be sold."
}

function townAuction.handleSnapshotResult(res)
    if not res or type(res) ~= "table" or not res.Ok then return end
    townAuction.snapshot = res
    townAuction.lastSnapshotTime = os.time()
    townAuction.snapshotTimestamp = os.time()
    townAuction.serverNow = res.Now or os.time()
    townAuction.balance = res.Balance or 0
    townAuction.currency = res.Currency or "MooBucks"
    townAuction.taxBasisPoints = res.PlayerTaxBasisPoints or 1000
    townAuction.deliveryHeld = res.DeliveryHeld or 0
    townAuction.held = res.Held or 0

    table.clear(townAuction.lotsBySlot)
    if type(res.Lots) == "table" then
        for _, lot in ipairs(res.Lots) do
            if lot.Slot then
                local slotId = tostring(lot.Slot)
                local roundStr = tostring(lot.Round or "")
                if slotId == "BuyNow2" or string.find(roundStr, "BuyNow2") then
                    townAuction.lotsBySlot["BuyNow2"] = lot
                elseif slotId == "BuyNow" or slotId == "BuyNow1" or string.find(roundStr, "BuyNow_") or string.find(roundStr, "BuyNow1") then
                    if not townAuction.lotsBySlot["BuyNow"] then
                        townAuction.lotsBySlot["BuyNow"] = lot
                        townAuction.lotsBySlot["BuyNow1"] = lot
                    else
                        townAuction.lotsBySlot["BuyNow2"] = lot
                    end
                else
                    townAuction.lotsBySlot[slotId] = lot
                end
            end
        end
    end

    table.clear(townAuction.ownedCopies)
    if type(res.Copies) == "table" then
        for _, copy in ipairs(res.Copies) do
            if copy.Id then
                townAuction.ownedCopies[copy.Id] = copy.OwnedCount or 1
            end
        end
    end

    townAuction.updateAllCards()

    if townAuction.hasAnyAutoBidActive and townAuction.hasAnyAutoBidActive() then
        for _, slotName in ipairs(townAuction.slots) do
            if townAuction.autoBidAll or townAuction.autoBidActive[slotName] then
                task.spawn(function() townAuction.checkAndAutoBidSlot(slotName) end)
            end
        end
    end
end

function townAuction.fetchSnapshot(isManual)
    if townAuction.isFetching then return false end
    townAuction.isFetching = true
    local remote = townAuction.getRemote()
    if not remote then
        townAuction.isFetching = false
        if isManual then
            Window:Notify({ Title = "Error", Content = "CowTownAuctionRequest remote not found.", Duration = 4 })
        end
        return false
    end

    local success, result = pcall(function()
        return remote:InvokeServer({ Action = "Snapshot" })
    end)

    townAuction.isFetching = false

    if success and type(result) == "table" and result.Ok then
        townAuction.handleSnapshotResult(result)
        if isManual then
            Window:Notify({
                Title = "Snapshot Updated",
                Content = string.format("Balance: %s %s | Synced %d lots.", formatNumber(townAuction.balance), townAuction.currency, #townAuction.slots),
                Duration = 3
            })
        end
        return true
    else
        if isManual then
            local err = (type(result) == "table" and (result.Error or result.Message)) or tostring(result)
            Window:Notify({ Title = "Fetch Failed", Content = tostring(err), Duration = 4 })
        end
        return false
    end
end

function townAuction.parseAmount(input)
    if not input then return nil end
    local str = type(input) == "table" and (input.CurrentValue or input.Text or input[1]) or tostring(input)
    str = str:gsub("%$", ""):gsub(",", ""):gsub("_", ""):gsub("%s+", "")
    if str == "" then return nil end

    local mult = 1
    local lower = str:lower()
    if lower:sub(-1) == "k" then
        mult = 1000
        str = str:sub(1, -2)
    elseif lower:sub(-1) == "m" then
        mult = 1000000
        str = str:sub(1, -2)
    elseif lower:sub(-1) == "b" then
        mult = 1000000000
        str = str:sub(1, -2)
    end

    local num = tonumber(str)
    if num and num > 0 then
        return math.floor(num * mult)
    end
    return nil
end

function townAuction.findTextBox(slotName)
    local parent = nil
    if gethui then
        pcall(function() parent = gethui() end)
    end
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent and plr then
        pcall(function() parent = plr:FindFirstChild("PlayerGui") end)
    end
    if not parent then return nil end

    local searchPattern = "Bid Amount (" .. slotName .. ")"
    for _, desc in ipairs(parent:GetDescendants()) do
        if desc:IsA("TextBox") then
            local p = desc.Parent
            while p and p ~= parent do
                local title = p:FindFirstChild("Title")
                if title and title:IsA("TextLabel") and title.Text == searchPattern then
                    return desc
                end
                p = p.Parent
            end
        end
    end
    return nil
end

function townAuction.resolveCustomAmount(slotName)
    local val = townAuction.customBidAmounts[slotName]
    if val and val > 0 then return val end

    local flagName = "Input_TownBid_" .. slotName
    if Window and Window.Flags and Window.Flags[flagName] ~= nil then
        val = townAuction.parseAmount(Window.Flags[flagName])
        if val and val > 0 then
            townAuction.customBidAmounts[slotName] = val
            return val
        end
    end

    if Rayfield and Rayfield.Flags and Rayfield.Flags[flagName] ~= nil then
        val = townAuction.parseAmount(Rayfield.Flags[flagName])
        if val and val > 0 then
            townAuction.customBidAmounts[slotName] = val
            return val
        end
    end

    local tb = townAuction.findTextBox(slotName)
    if tb and tb.Text and tb.Text ~= "" then
        val = townAuction.parseAmount(tb.Text)
        if val and val > 0 then
            townAuction.customBidAmounts[slotName] = val
            return val
        end
    end

    return nil
end

function townAuction.hasAnyAutoBidActive()
    if townAuction.autoBidAll then return true end
    for _, active in pairs(townAuction.autoBidActive) do
        if active then return true end
    end
    return false
end

function townAuction.checkAndAutoBidSlot(slotName)
    if not (townAuction.autoBidAll or townAuction.autoBidActive[slotName]) then return end

    local remote = townAuction.getRemote()
    if not remote then return end

    local lot = townAuction.lotsBySlot[slotName]
        or (slotName == "BuyNow" and townAuction.lotsBySlot["BuyNow1"])
        or (slotName == "BuyNow1" and townAuction.lotsBySlot["BuyNow"])
    local fitout = townAuction.getFitoutModel()
    local model = fitout and (fitout:FindFirstChild(slotName)
        or (slotName == "BuyNow" and fitout:FindFirstChild("BuyNow1"))
        or (slotName == "BuyNow1" and fitout:FindFirstChild("BuyNow")))

    local isEmpty = (lot and lot.Empty == true)
        or (model and model:GetAttribute("TownAuctionEmpty") == true)
    if isEmpty then return end

    local itemId = (lot and lot.ItemId)
        or (model and (model:GetAttribute("TownAuctionItemID") or model:GetAttribute("ItemId")))
    if not itemId or itemId == "" or itemId == "N/A" then return end

    local round = (lot and lot.Round)
        or (model and (model:GetAttribute("TownAuctionRound") or model:GetAttribute("Round")))
    if not round or round == "" or round == "N/A" then return end

    local isBuyNow = string.find(slotName, "BuyNow") ~= nil
    local price = (lot and lot.Price)
        or (model and (model:GetAttribute("TownAuctionPrice") or model:GetAttribute("Price")))
    local minBid = (lot and lot.Minimum)
        or (model and (model:GetAttribute("TownAuctionMinimum") or model:GetAttribute("Minimum")))
        or (price or 1)

    local amount = isBuyNow and (price or minBid or 1) or (minBid or 1)
    if not amount or type(amount) ~= "number" or amount <= 0 then return end

    if townAuction.maxAutoBidLimit > 0 and amount > townAuction.maxAutoBidLimit then
        return
    end

    -- Check if we are already leading
    local leaderName = (lot and lot.Leader) or (model and model:GetAttribute("Leader"))
    local leaderId = (lot and lot.LeaderId) or (model and model:GetAttribute("LeaderId"))
    local myDisplayName = tostring(plr:GetAttribute("DisplayName") or plr.DisplayName or plr.Name)
    local myUsername = plr.Name
    local myUserId = plr.UserId

    if (leaderId and leaderId == myUserId)
        or (leaderName and (leaderName == myDisplayName or leaderName == myUsername or leaderName == plr.DisplayName)) then
        return
    end

    -- Throttle to avoid duplicate rapid requests
    local now = os.clock()
    if townAuction.isAutoBiddingSlot[slotName] then return end
    if townAuction.lastAutoBidTime[slotName] and (now - townAuction.lastAutoBidTime[slotName] < 1.5) then return end

    townAuction.isAutoBiddingSlot[slotName] = true
    townAuction.lastAutoBidTime[slotName] = now

    task.spawn(function()
        local targetSlot = slotName == "BuyNow1" and "BuyNow" or slotName
        local success, result = pcall(function()
            if isBuyNow then
                return remote:InvokeServer({
                    Round = round,
                    Action = "Buy",
                    Slot = targetSlot
                })
            else
                return remote:InvokeServer({
                    Slot = targetSlot,
                    Round = round,
                    Action = "Bid",
                    Amount = amount
                })
            end
        end)

        townAuction.isAutoBiddingSlot[slotName] = false

        if success then
            local isOk = (type(result) == "table" and result.Ok ~= false) or (result == true or result == nil)
            local code = type(result) == "table" and result.Code
            local translatedMsg = code and (townAuctionResultMessages[code] or code)

            if isOk then
                local itemName = (lot and lot.Name)
                    or (model and (model:GetAttribute("TownAuctionName") or model:GetAttribute("TownAuctionItemID")))
                    or slotName
                local statusLine = translatedMsg and ("\n" .. translatedMsg) or ""
                Window:Notify({
                    Title = isBuyNow and "Auto Buy Placed!" or "Auto Outbid Placed!",
                    Content = string.format("%s (%s)\nAmount: 🪙 %s %s%s",
                        slotName,
                        tostring(itemName),
                        formatNumber(amount),
                        townAuction.currency,
                        isBuyNow and statusLine or ("\nOutbidding: " .. tostring(leaderName or "None"))),
                    Duration = 4
                })
                task.delay(0.5, function()
                    townAuction.fetchSnapshot(false)
                end)
            end
        end
    end)
end

function townAuction.executeBid(slotName, customAmount, forcePrice)
    local remote = townAuction.getRemote()
    if not remote then
        Window:Notify({ Title = "Error", Content = "CowTownAuctionRequest remote not found.", Duration = 4 })
        return false
    end

    local lot = townAuction.lotsBySlot[slotName]
        or (slotName == "BuyNow" and townAuction.lotsBySlot["BuyNow1"])
        or (slotName == "BuyNow1" and townAuction.lotsBySlot["BuyNow"])
    local fitout = townAuction.getFitoutModel()
    local model = fitout and (fitout:FindFirstChild(slotName)
        or (slotName == "BuyNow" and fitout:FindFirstChild("BuyNow1"))
        or (slotName == "BuyNow1" and fitout:FindFirstChild("BuyNow")))

    local round = (lot and lot.Round)
        or (model and (model:GetAttribute("TownAuctionRound") or model:GetAttribute("Round")))

    local isBuyNow = string.find(slotName, "BuyNow") ~= nil
    local price = (lot and lot.Price)
        or (model and (model:GetAttribute("TownAuctionPrice") or model:GetAttribute("Price")))
    local minAmount = (lot and (lot.Minimum or lot.Price))
        or (model and (model:GetAttribute("TownAuctionMinimum") or model:GetAttribute("TownAuctionPrice") or model:GetAttribute("Minimum") or model:GetAttribute("Price")))
        or 1

    local amount
    if forcePrice or (isBuyNow and not customAmount) then
        amount = tonumber(price) or tonumber(minAmount) or 1
    elseif customAmount then
        amount = tonumber(customAmount) or 1
    else
        amount = tonumber(minAmount) or 1
    end

    if not round or round == "" or round == "N/A" then
        Window:Notify({ Title = "Error", Content = slotName .. " has no active round.", Duration = 4 })
        return false
    end

    local targetSlot = slotName == "BuyNow1" and "BuyNow" or slotName

    local success, result = pcall(function()
        if isBuyNow then
            return remote:InvokeServer({
                Round = round,
                Action = "Buy",
                Slot = targetSlot
            })
        else
            return remote:InvokeServer({
                Slot = targetSlot,
                Round = round,
                Action = "Bid",
                Amount = amount
            })
        end
    end)

    if success then
        local isOk = (type(result) == "table" and result.Ok ~= false) or (result == true or result == nil)
        local itemName = (lot and lot.Name)
            or (model and (model:GetAttribute("TownAuctionName") or model:GetAttribute("TownAuctionItemID")))
            or slotName

        local code = type(result) == "table" and result.Code
        local translatedMsg = code and (townAuctionResultMessages[code] or code)

        if isOk then
            local actionTitle = isBuyNow and "Purchase Placed!" or "Bid Placed!"
            local statusLine = translatedMsg and ("\n" .. translatedMsg) or ""
            Window:Notify({
                Title = actionTitle,
                Content = string.format("%s (%s)\nAmount: 🪙 %s %s%s", slotName, tostring(itemName), formatNumber(amount), townAuction.currency, statusLine),
                Duration = 4
            })
            task.delay(0.5, function()
                townAuction.fetchSnapshot(false)
            end)
            return true
        else
            local errMsg = (type(result) == "table" and (translatedMsg or result.Error or result.Message or result.Reason)) or tostring(result)
            Window:Notify({
                Title = isBuyNow and "Purchase Rejected" or "Bid Rejected",
                Content = string.format("%s: %s", slotName, tostring(errMsg)),
                Duration = 4
            })
            return false
        end
    else
        Window:Notify({
            Title = isBuyNow and "Purchase Failed" or "Bid Failed",
            Content = string.format("%s: %s", slotName, tostring(result)),
            Duration = 4
        })
        return false
    end
end

function townAuction.teleportToStore()
    local fitout = townAuction.getFitoutModel()
    if not fitout then
        Window:Notify({ Title = "Not Found", Content = "TownStoreFitout model not streamed in yet.", Duration = 4 })
        return
    end
    if root then
        local targetPos = fitout:GetPivot().Position + Vector3.new(0, 3, 0)
        stopCharacterVelocity()
        root.CFrame = CFrame.new(targetPos)
        Window:Notify({ Title = "Teleported", Content = "Teleported to Buttercup Creamery Town Store.", Duration = 3 })
    end
end

function townAuction.startAutoRefresh()
    townAuction.stopAutoRefresh()
    townAuction.autoRefresh = true
    townAuction.autoRefreshThread = task.spawn(function()
        while townAuction.autoRefresh do
            townAuction.fetchSnapshot(false)
            local waited = 0
            while townAuction.autoRefresh and waited < (townAuction.autoRefreshInterval or 5) do
                task.wait(1)
                waited = waited + 1
                townAuction.updateAllCards()
            end
        end
    end)
end

function townAuction.stopAutoRefresh()
    townAuction.autoRefresh = false
    townAuction.autoRefreshThread = nil
end

function townAuction.cleanup()
    townAuction.stopAutoRefresh()
    townAuction.autoBidLoopRunning = false
    townAuction.autoBidAll = false
    for _, conn in ipairs(townAuction.connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    for _, conn in ipairs(townAuction.autoBidConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(townAuction.connections)
    table.clear(townAuction.autoBidConnections)
    table.clear(townAuction.cards)
    table.clear(townAuction.lotsBySlot)
    table.clear(townAuction.ownedCopies)
    table.clear(townAuction.customBidAmounts)
    table.clear(townAuction.autoBidActive)
end

function townAuction.initWorkspaceListeners()
    local fitout = townAuction.getFitoutModel()
    if not fitout then return end
    for _, slotName in ipairs(townAuction.slots) do
        local model = fitout:FindFirstChild(slotName)
            or (slotName == "BuyNow" and fitout:FindFirstChild("BuyNow1"))
            or (slotName == "BuyNow1" and fitout:FindFirstChild("BuyNow"))
        if model then
            local conn = model.AttributeChanged:Connect(function()
                townAuction.updateCard(slotName)
                if townAuction.autoBidAll or townAuction.autoBidActive[slotName] then
                    townAuction.checkAndAutoBidSlot(slotName)
                end
            end)
            table.insert(townAuction.connections, conn)
            table.insert(townAuction.autoBidConnections, conn)
        end
    end
end

function townAuction.setupSlotUI(tab, slotName)
    local initialTitle, initialBody = townAuction.getSlotDisplayInfo(slotName)
    local card = nil
    if tab.CreateText then
        pcall(function()
            card = tab:CreateText({
                name = initialTitle,
                text = initialBody
            })
        end)
    end
    if not card and tab.CreateParagraph then
        pcall(function()
            card = tab:CreateParagraph({
                Title = initialTitle,
                Content = initialBody
            })
        end)
    end
    townAuction.cards[slotName] = card

    tab:CreateInput({
        Name = "Bid Amount (" .. slotName .. ")",
        CurrentValue = "",
        PlaceholderText = "Enter custom amount (e.g. 50000 or 50k)",
        RemoveTextAfterFocusLost = false,
        Flag = "Input_TownBid_" .. slotName,
        Callback = function(Text)
            local num = townAuction.parseAmount(Text)
            if num and num > 0 then
                townAuction.customBidAmounts[slotName] = num
            else
                townAuction.customBidAmounts[slotName] = nil
            end
        end,
    })

    task.spawn(function()
        task.wait(0.2)
        local tb = townAuction.findTextBox(slotName)
        if tb then
            tb:GetPropertyChangedSignal("Text"):Connect(function()
                local num = townAuction.parseAmount(tb.Text)
                if num and num > 0 then
                    townAuction.customBidAmounts[slotName] = num
                end
            end)
        end
    end)

    local isBuyNow = string.find(slotName, "BuyNow") ~= nil
    local btnName = isBuyNow and ("Buy Now (" .. slotName .. ")") or ("Bid Minimum / Next " .. slotName)
    tab:CreateButton({
        Name = btnName,
        Callback = function()
            townAuction.executeBid(slotName, nil, isBuyNow)
        end,
    })

    tab:CreateButton({
        Name = "Bid Custom Amount (" .. slotName .. ")",
        Callback = function()
            local custom = townAuction.resolveCustomAmount(slotName)
            if not custom then
                Window:Notify({ Title = "No Amount", Content = "Please enter an amount in the input above first.", Duration = 3 })
                return
            end
            townAuction.executeBid(slotName, custom)
        end,
    })
end

-- ==========================
-- UI SETUP: Town Auction Tab
-- ==========================
local TownAuctionTab = Window:CreateTab({ Name = "Town Auction", Icon = 4483362458 })

TownAuctionTab:CreateSection({ Name = "Town Store & Live Controls" })

local initialInfoTitle = string.format("Town Auction Overview | 0 %s", townAuction.currency)
local initialInfoBody = "Snapshot not loaded yet. Click 'Fetch Snapshot Now' below."
if TownAuctionTab.CreateText then
    pcall(function()
        townAuction.infoCard = TownAuctionTab:CreateText({
            name = initialInfoTitle,
            text = initialInfoBody
        })
    end)
end
if not townAuction.infoCard and TownAuctionTab.CreateParagraph then
    pcall(function()
        townAuction.infoCard = TownAuctionTab:CreateParagraph({
            Title = initialInfoTitle,
            Content = initialInfoBody
        })
    end)
end

TownAuctionTab:CreateButton({
    Name = "Fetch Snapshot Now",
    Callback = function()
        townAuction.fetchSnapshot(true)
    end,
})

TownAuctionTab:CreateToggle({
    Name = "Auto-Refresh Snapshot (5s)",
    CurrentValue = false,
    Flag = "Toggle_TownAutoRefresh",
    Callback = function(Value)
        if Value then
            townAuction.startAutoRefresh()
        else
            townAuction.stopAutoRefresh()
        end
    end,
})

TownAuctionTab:CreateButton({
    Name = "Teleport to Town Store (Buttercup Creamery)",
    Callback = function()
        townAuction.teleportToStore()
    end,
})

TownAuctionTab:CreateSection({ Name = "Auto Outbid & Auto Buy (When Not Leading)" })

TownAuctionTab:CreateToggle({
    Name = "Auto Outbid / Buy All Lots",
    CurrentValue = false,
    Flag = "Toggle_TownAutoBidAll",
    Callback = function(Value)
        townAuction.autoBidAll = Value
        if Value then
            for _, slotName in ipairs(townAuction.slots) do
                task.spawn(function() townAuction.checkAndAutoBidSlot(slotName) end)
            end
        end
    end,
})

for _, slotName in ipairs(townAuction.slots) do
    local isBuyNow = string.find(slotName, "BuyNow") ~= nil
    local toggleName = isBuyNow and ("Auto Buy Now (" .. slotName .. ")") or ("Auto Outbid " .. slotName)
    TownAuctionTab:CreateToggle({
        Name = toggleName,
        CurrentValue = false,
        Flag = "Toggle_TownAutoBid_" .. slotName,
        Callback = function(Value)
            townAuction.autoBidActive[slotName] = Value
            if Value then
                task.spawn(function() townAuction.checkAndAutoBidSlot(slotName) end)
            end
        end,
    })
end

TownAuctionTab:CreateInput({
    Name = "Max Auto Bid Limit (0 = Unlimited)",
    CurrentValue = "",
    PlaceholderText = "Enter max MooBucks (e.g. 5000000 or 5m)",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_TownMaxAutoBid",
    Callback = function(Text)
        local num = townAuction.parseAmount(Text) or 0
        townAuction.maxAutoBidLimit = num
        Window:Notify({
            Title = "Limit Updated",
            Content = num == 0 and "Max bid limit set to Unlimited." or ("Max bid limit set to: " .. formatNumber(num) .. " " .. townAuction.currency),
            Duration = 3
        })
    end,
})

TownAuctionTab:CreateSection({ Name = "Global Auction Lots" })
townAuction.setupSlotUI(TownAuctionTab, "Global1")
townAuction.setupSlotUI(TownAuctionTab, "Global2")

TownAuctionTab:CreateSection({ Name = "Server Auction Lots" })
townAuction.setupSlotUI(TownAuctionTab, "Server2")
townAuction.setupSlotUI(TownAuctionTab, "Server3")

TownAuctionTab:CreateSection({ Name = "Buy Now Store Lots" })
townAuction.setupSlotUI(TownAuctionTab, "BuyNow")
townAuction.setupSlotUI(TownAuctionTab, "BuyNow2")

TownAuctionTab:CreateSection({ Name = "Player Consignment Lots" })
townAuction.setupSlotUI(TownAuctionTab, "Player1")
townAuction.setupSlotUI(TownAuctionTab, "Player2")

townAuction.initWorkspaceListeners()

task.spawn(function()
    while townAuction.autoBidLoopRunning do
        task.wait(1)
        if townAuction.hasAnyAutoBidActive and townAuction.hasAnyAutoBidActive() then
            for _, slotName in ipairs(townAuction.slots) do
                if townAuction.autoBidAll or townAuction.autoBidActive[slotName] then
                    townAuction.checkAndAutoBidSlot(slotName)
                end
            end
        end
    end
end)

task.spawn(function()
    task.wait(1.5)
    townAuction.fetchSnapshot(false)
end)

-- ==========================
-- UI SETUP: Trick or Treat Tab
-- ==========================
local TotTab = Window:CreateTab({ Name = "Trick or Treat", Icon = 4483362458 })

TotTab:CreateSection({ Name = "Trick or Treat Autofarm" })

TotTab:CreateToggle({
    Name = "Enable Trick or Treat Autofarm",
    CurrentValue = false,
    Flag = "Toggle_TrickOrTreat",
    Callback = function(Value)
        trickOrTreat.toggle(Value)
    end,
})

TotTab:CreateToggle({
    Name = "Auto-Dismiss Reward GUI (Accept / Okay / Done)",
    CurrentValue = true,
    Flag = "Toggle_ToT_DismissRewardGui",
    Callback = function(Value)
        trickOrTreat.autoDismissRewardGui = Value
        trickOrTreat.autoAcceptRewards = Value
    end,
})

TotTab:CreateButton({
    Name = "Dismiss Reward GUI Now",
    Callback = function()
        local didDismiss = trickOrTreat.dismissRewardGui(true)
        if didDismiss then
            safeNotify({ Title = "Trick or Treat GUI", Content = "Dismissed reward popup.", Duration = 2 })
        else
            safeNotify({ Title = "Trick or Treat GUI", Content = "No active reward popup found.", Duration = 2 })
        end
    end,
})

TotTab:CreateButton({
    Name = "Run Single Cycle Now",
    Callback = function()
        if trickOrTreat.isCycling then
            if (os.clock() - (trickOrTreat.cycleStartTime or 0)) > 60 then
                warn("[CowHub TrickOrTreat] Stuck isCycling flag detected (>60s). Resetting.")
                trickOrTreat.isCycling = false
            else
                safeNotify({ Title = "Already Running", Content = "A cycle is already in progress!", Duration = 3 })
                return
            end
        end
        safeNotify({ Title = "Trick or Treat", Content = "Starting single cycle...", Duration = 3 })
        trickOrTreat.initClientListener()
        if trickOrTreat.autoDetectCooldown then
            trickOrTreat.detectCooldown()
        end
        trickOrTreat.isRetryPass = false
        trickOrTreat.completedHouseNames = {}
        trickOrTreat.erroredHouseNames = {}
        trickOrTreat.houseRetryAttempts = {}
        trickOrTreat.isSingleRun = true
        trickOrTreat.startLoop()
        task.spawn(function()
            local success, err = xpcall(trickOrTreat.runCycle, function(e)
                return debug.traceback(tostring(e), 2)
            end)
            if not success then
                warn("[CowHub TrickOrTreat] Error during single cycle:\n" .. tostring(err))
                trickOrTreat.isCycling = false
                if trickOrTreat.currentHouseInteracting then
                    local curH = trickOrTreat.currentHouseInteracting
                    local hName = (typeof(curH) == "Instance" and curH.Name) or tostring(curH)
                    trickOrTreat.erroredHouseNames[hName] = true
                end
                local errCount = 0
                for _ in pairs(trickOrTreat.erroredHouseNames) do errCount = errCount + 1 end
                if errCount > 0 then
                    trickOrTreat.isRetryPass = true
                    trickOrTreat.statusText = string.format("Error in cycle. Retrying %d failed house(s) in 4s...", errCount)
                    trickOrTreat.nextCycleTime = os.clock() + 4
                    pcall(trickOrTreat.updateStatusUI)
                    task.delay(4, function()
                        if trickOrTreat.isSingleRun and not trickOrTreat.isCycling then
                            trickOrTreat.runCycle()
                        end
                    end)
                else
                    trickOrTreat.isRetryPass = false
                    trickOrTreat.statusText = "Single cycle completed."
                    pcall(trickOrTreat.updateStatusUI)
                end
            end
        end)
    end,
})

TotTab:CreateButton({
    Name = "Return to Saved Position",
    Callback = function()
        if trickOrTreat.savedPreCFrame then
            safeReturnToSavedPosition(trickOrTreat.savedPreCFrame)
            safeNotify({ Title = "Returned", Content = "Returned to saved position (+4 studs safe height).", Duration = 2 })
        else
            safeNotify({ Title = "No Saved Position", Content = "No saved position exists yet.", Duration = 2 })
        end
    end,
})

TotTab:CreateSection({ Name = "Status & Live Telemetry" })

local initialStatusTitle = "Status: Idle"
local initialStatusBody = "Autofarm is currently OFF."
if TotTab.CreateText then
    pcall(function()
        trickOrTreat.statusCard = TotTab:CreateText({
            name = initialStatusTitle,
            text = initialStatusBody
        })
    end)
end
if not trickOrTreat.statusCard and TotTab.CreateParagraph then
    pcall(function()
        trickOrTreat.statusCard = TotTab:CreateParagraph({
            Title = initialStatusTitle,
            Content = initialStatusBody
        })
    end)
end

local initialTelemTitle = "Script Telemetry | Cycles: 0 | Knocked: 0"
local initialTelemBody = "Uptime: 00:00 | Total Cycles: 0 | Total Knocked: 0\nRewards Dismissed: 0 | Avg/Cycle: 0 | Last Duration: 0.0s\nCooldown: 10:00 (Auto) | Pos: N/A"
if TotTab.CreateText then
    pcall(function()
        trickOrTreat.infoCard = TotTab:CreateText({
            name = initialTelemTitle,
            text = initialTelemBody
        })
        trickOrTreat.telemetryCard = trickOrTreat.infoCard
    end)
end
if not trickOrTreat.infoCard and TotTab.CreateParagraph then
    pcall(function()
        trickOrTreat.infoCard = TotTab:CreateParagraph({
            Title = initialTelemTitle,
            Content = initialTelemBody
        })
        trickOrTreat.telemetryCard = trickOrTreat.infoCard
    end)
end

TotTab:CreateButton({
    Name = "Reset Session Telemetry",
    Callback = function()
        trickOrTreat.totalCycles = 0
        trickOrTreat.totalHousesKnocked = 0
        trickOrTreat.totalRewardsDismissed = 0
        trickOrTreat.sessionStartTime = os.clock()
        trickOrTreat.lastCycleDuration = 0
        trickOrTreat.updateStatusUI()
        safeNotify({ Title = "Telemetry Reset", Content = "Trick or Treat session counters reset.", Duration = 2 })
    end,
})

TotTab:CreateSection({ Name = "Timing & Sliders" })

TotTab:CreateSlider({
    Name = "Cycle Cooldown (Seconds)",
    Range = {10, 1800},
    Increment = 10,
    Suffix = "s",
    CurrentValue = trickOrTreat.cycleCooldown,
    Flag = "Slider_ToT_CycleCooldown",
    Callback = function(Value)
        trickOrTreat.cycleCooldown = Value
        if trickOrTreat.lastCycleCompletedTime > 0 and not trickOrTreat.isCycling then
            local now = os.clock()
            local targetNext = trickOrTreat.lastCycleCompletedTime + Value
            if targetNext > now then
                trickOrTreat.nextCycleTime = targetNext
            elseif trickOrTreat.nextCycleTime > now then
                trickOrTreat.nextCycleTime = now
            end
        end
        trickOrTreat.updateStatusUI()
    end,
})

TotTab:CreateSlider({
    Name = "Barn Map Load Delay (Seconds)",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 2.5,
    Flag = "Slider_ToT_BarnDelay",
    Callback = function(Value)
        trickOrTreat.barnLoadDelay = Value
    end,
})

TotTab:CreateSlider({
    Name = "House Interaction Delay (Seconds)",
    Range = {1.0, 5.0},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1.4,
    Flag = "Slider_ToT_HouseWait",
    Callback = function(Value)
        trickOrTreat.houseWaitTime = Value
    end,
})

TotTab:CreateSlider({
    Name = "Pre-Knock Settle Delay (Seconds)",
    Range = {0.1, 1.5},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.3,
    Flag = "Slider_ToT_SettleDelay",
    Callback = function(Value)
        trickOrTreat.settleDelay = Value
    end,
})

TotTab:CreateSlider({
    Name = "Inside Stop Distance (Studs Before Door)",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 2.0,
    Flag = "Slider_ToT_DoorDistance",
    Callback = function(Value)
        trickOrTreat.doorDistance = Value
    end,
})

TotTab:CreateSlider({
    Name = "Door Height Fine-Tuning",
    Range = {-5.0, 5.0},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 0.0,
    Flag = "Slider_ToT_DoorHeightOffset",
    Callback = function(Value)
        trickOrTreat.doorHeightOffset = Value
    end,
})

TotTab:CreateSlider({
    Name = "Return Position Height Offset",
    Range = {0.0, 15.0},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 4.0,
    Flag = "Slider_ToT_ReturnHeightOffset",
    Callback = function(Value)
        trickOrTreat.returnHeightOffset = Value
    end,
})

TotTab:CreateToggle({
    Name = "Disable House Inside Collision",
    CurrentValue = true,
    Flag = "Toggle_ToT_DisableInsideCollision",
    Callback = function(Value)
        trickOrTreat.disableInsideCollision = Value
    end,
})

TotTab:CreateDropdown({
    Name = "Walk Approach Origin",
    Options = {"Inside House", "Outside Porch"},
    CurrentOption = {"Inside House"},
    Flag = "Dropdown_ToT_ApproachOrigin",
    Callback = function(Option)
        local chosen = type(Option) == "table" and Option[1] or Option
        trickOrTreat.approachOrigin = chosen or "Inside House"
    end,
})

TotTab:CreateToggle({
    Name = "Walk Up to Door Before Knocking",
    CurrentValue = true,
    Flag = "Toggle_ToT_WalkUp",
    Callback = function(Value)
        trickOrTreat.walkUpEnabled = Value
    end,
})

TotTab:CreateSlider({
    Name = "Inside Start Distance (Studs from Door)",
    Range = {4.0, 25.0},
    Increment = 1.0,
    Suffix = " studs",
    CurrentValue = 11.0,
    Flag = "Slider_ToT_WalkDistance",
    Callback = function(Value)
        trickOrTreat.walkDistance = Value
    end,
})

TotTab:CreateSlider({
    Name = "Walk-Up Timeout (Seconds)",
    Range = {0.5, 4.0},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1.5,
    Flag = "Slider_ToT_WalkTimeout",
    Callback = function(Value)
        trickOrTreat.walkTimeout = Value
    end,
})

TotTab:CreateToggle({
    Name = "Return to Original Position After Cycle",
    CurrentValue = true,
    Flag = "Toggle_ToT_ReturnOnFinish",
    Callback = function(Value)
        trickOrTreat.returnOnFinish = Value
    end,
})

TotTab:CreateToggle({
    Name = "Anchor During Knock (Anti-Ghost Push)",
    CurrentValue = true,
    Flag = "Toggle_ToT_AnchorKnock",
    Callback = function(Value)
        trickOrTreat.anchorDuringKnock = Value
    end,
})

TotTab:CreateToggle({
    Name = "Auto-Detect Game Cooldown",
    CurrentValue = true,
    Flag = "Toggle_ToT_AutoDetect",
    Callback = function(Value)
        trickOrTreat.autoDetectCooldown = Value
        if Value then
            trickOrTreat.detectCooldown()
        end
        trickOrTreat.updateStatusUI()
    end,
})

TotTab:CreateToggle({
    Name = "Pause Regular Farm During Cycle",
    CurrentValue = true,
    Flag = "Toggle_ToT_PauseFarm",
    Callback = function(Value)
        trickOrTreat.pauseFarmDuringCycle = Value
    end,
})

-- ==========================
-- FJORD RAFTING AUTOMATION SYSTEM
-- ==========================
local rafting = {
    enabled = false,
    autoLoop = false,
    naturalMode = false,
    route = "Hybrid Dynamic Explorer", -- "Leftmost Clearings & Caves (Far-North / Left-Left-Forward)", "Hybrid Dynamic Explorer", "Clearing & Chest Explorer", "Fast Sea Run (Center/Direct)", "North Channels (Caves & Drops)", "South Channels (Scenic & Clearings)"
    selectedByZone = {
        [1] = { ["Clearing_02"] = true },
        [2] = { ["Clearing_03"] = true, ["Clearing_04"] = true },
        [3] = { ["Clearing_05"] = true, ["Clearing_06"] = true, ["Clearing_07"] = true, ["Clearing_08"] = true },
        [4] = { ["Clearing_09"] = true, ["Clearing_10"] = true },
    },
    selectedClearings = {
        ["Clearing_02"] = true,
        ["Clearing_03"] = true,
        ["Clearing_04"] = true,
        ["Clearing_05"] = true,
        ["Clearing_06"] = true,
        ["Clearing_07"] = true,
        ["Clearing_08"] = true,
        ["Clearing_09"] = true,
        ["Clearing_10"] = true,
    },
    autoContinueFromDock = true,
    autoAcceptRewards = true,
    autoDismissRewardGui = true,
    autoBoost = true,
    minBoostStamina = 40,
    isBoosting = false,
    nextBoostAt = 0,
    autoRepair = true,
    emergencyReturnHp = 25,
    emergencyDocked = false,
    isEndingVoyage = false,
    isEndingVoyageInProgress = false,
    lastSessionEndNotify = 0,
    autoEvadeHobgoblins = true,
    autoRecoverOverboard = true,
    incomingRocks = {},
    isEvadingRock = false,
    currentDockSite = nil,
    lastRockHitTime = 0,
    remote = nil,
    clientEventConn = nil,
    heartbeatConn = nil,
    renderSteppedConn = nil,
    lastSteerKey = nil,
    lastStepTime = 0,
    lastLootedSite = nil,
    visitedSites = {},
    isDockedState = false,
    targetDeckX = 0,
    errorZ = 0,
    whiskerClearances = {},
    lastSensorAt = 0,
    lastRemoteCalls = {},
    lastProgressPos = nil,
    lastProgressX = nil,
    lastProgressTime = 0,
    stuckDuration = 0,
    isUnsticking = false,
    unstickDirection = 0,
    unstickStartTime = 0,
    currentSnapshot = nil,
    teamChests = nil,
    teamChestSite = nil,
    lastLootedChestId = nil,
    isCastingOff = false,
    sessionId = nil,
    raftModel = nil,
    deckPart = nil,
    status = "Idle",
    statusText = "Idle at Raft Yard",
    teleportAttempts = 0,
    lastRepairTime = 0,
    lastSnapshotTime = 0,
    diedConn = nil,
    isSailing = false,
    dockMaxWaitSeconds = 4,
    connections = {},
    statusCard = nil,
    telemetryCard = nil,
    infoCard = nil,
}

function rafting.getRemote()
    if rafting.remote and rafting.remote.Parent then
        return rafting.remote
    end
    if cowRemotes then
        rafting.remote = cowRemotes:FindFirstChild("RaftingRequest")
    end
    if not rafting.remote then
        pcall(function()
            local cg = game:GetService("ReplicatedStorage"):WaitForChild("CowGame", 2)
            local rem = cg and cg:WaitForChild("Remotes", 2)
            rafting.remote = rem and rem:FindFirstChild("RaftingRequest")
        end)
    end
    return rafting.remote
end

function rafting.fireRemoteSafely(action, arg, debounceSec)
    local rem = rafting.getRemote()
    if not rem then return false end
    debounceSec = debounceSec or 0.4
    local now = os.clock()
    local lastCall = rafting.lastRemoteCalls[action] or 0
    if (now - lastCall) < debounceSec then
        return false
    end
    rafting.lastRemoteCalls[action] = now
    local success = pcall(function()
        if arg ~= nil then
            rem:FireServer(action, arg)
        else
            rem:FireServer(action)
        end
    end)
    return success
end

function rafting.getRaftDeck()
    if rafting.deckPart and rafting.deckPart.Parent and rafting.raftModel and rafting.raftModel.Parent then
        return rafting.deckPart, rafting.raftModel
    end
    if char then
        local cowDeck = char:FindFirstChild("CowRaftingDeck")
        if cowDeck and cowDeck:IsA("ObjectValue") and cowDeck.Value and cowDeck.Value:IsA("BasePart") then
            rafting.deckPart = cowDeck.Value
            rafting.raftModel = cowDeck.Value.Parent
            return cowDeck.Value, cowDeck.Value.Parent
        end
    end
    local sessionId = rafting.sessionId or (rafting.currentSnapshot and rafting.currentSnapshot.Id)
    local fjordFolder = workspace:FindFirstChild("FjordRafting") or (workspace:FindFirstChild("CowWorld") and workspace.CowWorld:FindFirstChild("FjordRafting"))
    if fjordFolder then
        if sessionId then
            local raftName = "TeamRaft_" .. tostring(sessionId)
            local model = fjordFolder:FindFirstChild(raftName) or workspace:FindFirstChild(raftName)
            if model then
                local deck = model:FindFirstChild("Deck")
                if deck and deck:IsA("BasePart") then
                    rafting.raftModel = model
                    rafting.deckPart = deck
                    return deck, model
                end
            end
        end
        for _, child in ipairs(fjordFolder:GetChildren()) do
            if child:IsA("Model") and (child.Name:sub(1, 9) == "TeamRaft_" or child:FindFirstChild("Deck")) then
                local deck = child:FindFirstChild("Deck")
                if deck and deck:IsA("BasePart") then
                    rafting.raftModel = child
                    rafting.deckPart = deck
                    return deck, child
                end
            end
        end
    end
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child.Name:sub(1, 9) == "TeamRaft_" then
            local deck = child:FindFirstChild("Deck")
            if deck and deck:IsA("BasePart") then
                rafting.raftModel = child
                rafting.deckPart = deck
                return deck, child
            end
        end
    end
    return nil, nil
end

local FjordZones
local FjordContentConfig
pcall(function()
    local cg = game:GetService("ReplicatedStorage"):FindFirstChild("CowGame")
    local shared = cg and cg:FindFirstChild("Shared")
    local fzMod = shared and shared:FindFirstChild("FjordZones")
    if fzMod and fzMod:IsA("ModuleScript") then
        FjordZones = require(fzMod)
    end
    local fccMod = shared and shared:FindFirstChild("FjordContentConfig")
    if fccMod and fccMod:IsA("ModuleScript") then
        FjordContentConfig = require(fccMod)
    end
end)

local function getFjordLevel(posX)
    if FjordContentConfig and FjordContentConfig.Level then
        local lvl = FjordContentConfig.Level(posX)
        if lvl then return lvl end
    end
    if posX < 1350 then return 1
    elseif posX < 2650 then return 2
    elseif posX < 4100 then return 3
    else return 4 end
end

local function getHarbourZ(posX)
    if FjordZones and FjordZones.RibbonAt then
        local cz = FjordZones.RibbonAt(posX)
        if cz then return cz end
    end
    return -37.81
end

local reachData = nil
local getReachData
local getReachIndex

local clearingSites = {}
rafting.clearingSites = clearingSites
rafting.allSites = {}
rafting.sitesById = {}
rafting.sitesInitialized = false
rafting.collectAllLootChests = true
rafting.lootedChestSites = {}
rafting.isLootingChest = false

local function placeCowAboveDeck(deck)
    if not deck or not root then return end
    stopCharacterVelocity()
    local deckTopY = (deck.Size and deck.Size.Y * 0.5) or 1.0
    root.CFrame = deck.CFrame * CFrame.new(0, deckTopY + 5.5, 0)
    if humanoid then
        humanoid:Move(Vector3.zero, false)
        humanoid:MoveTo(root.Position)
    end
end

local function isCowOnDeck(deck)
    if not deck or not root then return false end
    local cowRel = deck.CFrame:PointToObjectSpace(root.Position)
    local onDeckX = math.abs(cowRel.X) <= 5.8
    local onDeckZ = math.abs(cowRel.Z) <= 14.0
    local onDeckY = cowRel.Y >= -0.5 and cowRel.Y <= 8.5
    return onDeckX and onDeckZ and onDeckY
end
rafting.isCowOnDeck = isCowOnDeck

function rafting.ensureDynamicSites()
    if rafting.sitesInitialized and #clearingSites > 0 then return end
    if not FjordZones then
        pcall(function()
            local cg = game:GetService("ReplicatedStorage"):FindFirstChild("CowGame")
            local shared = cg and cg:FindFirstChild("Shared")
            local fzMod = shared and shared:FindFirstChild("FjordZones")
            if fzMod and fzMod:IsA("ModuleScript") then
                FjordZones = require(fzMod)
            end
        end)
    end
    if not FjordZones or not FjordZones.Sites then return end

    local sitesList = {}
    local clearingsList = {}
    local byId = {}
    local coves = FjordZones.Coves or {}

    for _, s in ipairs(FjordZones.Sites) do
        local sid = s.Id
        local kind = s.Kind or "Clearing"
        local bank = s.BankSide or (if s.MaxZ < -37.81 then "North" else "South")
        local floorY = s.FloorY or 700.7

        local matchedCove = nil
        for _, c in ipairs(coves) do
            if c[6] == kind then
                if kind == "Clearing" and c[7] == string.gsub(sid, "^Clearing_", "") then
                    matchedCove = c
                    break
                elseif kind == "Cave" then
                    local caveSub = string.gsub(sid, "^Cave_", "")
                    if string.find(c[7], caveSub, 1, true) or (caveSub == "12" and string.find(c[7], "Cubby06", 1, true)) then
                        matchedCove = c
                        break
                    end
                end
            end
        end

        local coveX = matchedCove and matchedCove[1] or ((s.MinX + s.MaxX) * 0.5)
        local coveZ = matchedCove and matchedCove[2] or ((s.MinZ + s.MaxZ) * 0.5)
        local mouthZ = if bank == "North" then s.MaxZ else s.MinZ
        local mouthPos = Vector3.new(coveX, 700.5, mouthZ)
        local landPos = Vector3.new(coveX, floorY + 1.8, coveZ)

        if sid == "Cave_Cubby04" then
            bank = "North"
            coveX = 4503.58
            coveZ = -551.46
            mouthZ = -542.46
            mouthPos = Vector3.new(coveX, 700.5, mouthZ)
            landPos = Vector3.new(coveX, floorY + 1.8, coveZ)
        elseif sid == "Cave_Cubby05" then
            bank = "South"
            coveX = 6348.58
            coveZ = -874.16
            mouthZ = -883.16
            mouthPos = Vector3.new(coveX, 700.5, mouthZ)
            landPos = Vector3.new(6444.58, floorY + 1.8, -551.46)
        end

        local siteData = {
            Id = sid,
            Kind = kind,
            Name = (if kind == "Clearing" then "Clearing " .. string.gsub(sid, "^Clearing_", "") else "Cave " .. string.gsub(sid, "^Cave_", "")) .. " (" .. bank .. ")",
            BankSide = bank,
            Mouth = mouthPos,
            MinX = s.MinX,
            MaxX = s.MaxX,
            MinZ = s.MinZ,
            MaxZ = s.MaxZ,
            FloorY = floorY,
            LandPos = landPos,
            ShoreZ = coveZ,
            FjordLevel = getFjordLevel(coveX),
            Reach = (getReachIndex and getReachIndex(coveX)) or 1,
        }
        table.insert(sitesList, siteData)
        if kind == "Clearing" then
            table.insert(clearingsList, siteData)
        end
        byId[sid] = siteData
    end

    table.sort(sitesList, function(a, b) return a.MinX < b.MinX end)
    table.sort(clearingsList, function(a, b) return a.MinX < b.MinX end)
    for i, s in ipairs(clearingsList) do
        clearingSites[i] = s
    end
    rafting.clearingSites = clearingSites
    rafting.allSites = sitesList
    rafting.sitesById = byId
    rafting.sitesInitialized = true
    reachData = nil
    getReachData()
end

function rafting.getSiteChannelZ(site)
    if not site then return -37.81 end
    if FjordZones and FjordZones.Channels then
        local reach = getReachIndex(site.MinX)
        local bestZ = -37.81
        local minDiff = math.huge
        for _, ch in ipairs(FjordZones.Channels) do
            if ch[7] == reach then
                local diff = math.abs(ch[2] - site.ShoreZ)
                if diff < minDiff then
                    minDiff = diff
                    bestZ = ch[2]
                end
            end
        end
        return bestZ
    end
    return -37.81
end

function rafting.getClearingById(siteId)
    rafting.ensureDynamicSites()
    return rafting.sitesById[siteId]
end

function rafting.getNearbyClearing(posX, posZ)
    rafting.ensureDynamicSites()
    for _, site in ipairs(rafting.allSites) do
        if posX >= site.MinX and posX <= site.MaxX and posZ >= site.MinZ and posZ <= site.MaxZ then
            return site
        end
    end
    return nil
end

getReachData = function()
    if reachData then return reachData end
    reachData = {
        maxReach = 7,
        forkX = { 1844.58, 2844.58, 3294.58, 4294.58, 4744.58, 5844.58, 6594.58 },
        channelsByReach = {},
    }
    for r = 1, 7 do
        reachData.channelsByReach[r] = {}
    end
    if FjordZones and FjordZones.Channels then
        local maxR = 1
        for _, ch in ipairs(FjordZones.Channels) do
            local rIdx = ch[7] or 1
            if rIdx > maxR then maxR = rIdx end
            if not reachData.channelsByReach[rIdx] then
                reachData.channelsByReach[rIdx] = {}
            end
            table.insert(reachData.channelsByReach[rIdx], ch)
            local endX = ch[1] + ch[5]
            if not reachData.forkX[rIdx] or endX > reachData.forkX[rIdx] then
                reachData.forkX[rIdx] = endX
            end
        end
        reachData.maxReach = maxR
    end
    return reachData
end

getReachIndex = function(posX)
    local rd = getReachData()
    for r = 1, rd.maxReach do
        if posX <= rd.forkX[r] then
            return r
        end
    end
    return rd.maxReach
end

local reachChannelZ = {
    [1] = { -37.81 },
    [2] = { -262.81, -37.81, 187.19 },
    [3] = { -487.81, -262.81, -37.81, 412.19 },
    [4] = { -712.81, -487.81, -37.81, 412.19, 637.19 },
    [5] = { -937.81, -487.81, -37.81, 187.19, 412.19, 862.19 },
    [6] = { -1162.81, -937.81, -487.81, -37.81, 412.19, 862.19, 1087.19 },
    [7] = { -1387.81, -937.81, -487.81, -37.81, 412.19, 862.19, 1312.19 },
}

function rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)
    if not nominalChZ then return -37.81 end
    if reachIdx == 2 then
        if math.abs(nominalChZ - (-262.81)) <= 40 then
            local x = posX or 2344.58
            return -262.81 - 0.315 * (x - 2344.58)
        elseif math.abs(nominalChZ - 187.19) <= 40 then
            local x = posX or 2344.58
            return 187.19 + 0.324 * (x - 2344.58)
        end
    end
    if FjordZones and FjordZones.Channels then
        local bestCh = nil
        local minDiff = 40
        for _, ch in ipairs(FjordZones.Channels) do
            if ch[7] == reachIdx then
                local diff = math.abs(ch[2] - nominalChZ)
                if diff < minDiff then
                    minDiff = diff
                    bestCh = ch
                end
            end
        end
        if bestCh then
            local midX = bestCh[1]
            local midZ = bestCh[2]
            local dirX = bestCh[3] or 1
            local dirZ = bestCh[4] or 0
            if math.abs(dirX) > 0.01 and math.abs(dirZ) > 0.001 and posX then
                local slope = dirZ / dirX
                return midZ + slope * (posX - midX)
            end
            return midZ
        end
    end
    return nominalChZ
end

function rafting.getCurrentChannel(posX, posZ)
    local reachIdx = getReachIndex(posX)
    local channels = reachChannelZ[reachIdx] or { -37.81 }
    local bestZ = channels[1]
    local minDiff = math.huge
    local z = posZ or -37.81
    for _, chZ in ipairs(channels) do
        local centerZ = rafting.getChannelCenterZ(reachIdx, chZ, posX)
        local diff = math.abs(centerZ - z)
        if diff < minDiff then
            minDiff = diff
            bestZ = chZ
        end
    end
    return bestZ, reachIdx
end

local channelTransitions = {
    [1] = {
        [-37.81] = { -262.81, -37.81, 187.19 },
    },
    [2] = {
        [-262.81] = { -487.81 },
        [-37.81]  = { -262.81, -37.81 },
        [187.19]  = { 412.19 },
    },
    [3] = {
        [-487.81] = { -712.81, -487.81 },
        [-262.81] = { -712.81, -487.81 },
        [-37.81]  = { -37.81 },
        [412.19]  = { 412.19, 637.19 },
    },
    [4] = {
        [-712.81] = { -937.81 },
        [-487.81] = { -487.81 },
        [-37.81]  = { -37.81, 187.19 },
        [412.19]  = { 412.19 },
        [637.19]  = { 862.19 },
    },
    [5] = {
        [-937.81] = { -1162.81, -937.81 },
        [-487.81] = { -487.81 },
        [-37.81]  = { -37.81 },
        [187.19]  = { 412.19 },
        [412.19]  = { 412.19 },
        [862.19]  = { 862.19, 1087.19 },
    },
    [6] = {
        [-1162.81] = { -1387.81 },
        [-937.81]  = { -937.81 },
        [-487.81]  = { -487.81 },
        [-37.81]   = { -37.81 },
        [412.19]   = { 412.19 },
        [862.19]   = { 862.19 },
        [1087.19]  = { 1312.19 },
    },
}

local pipelineCorridors = {
    ["North"]    = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -487.81, [5] = -487.81, [6] = -487.81, [7] = -487.81 },
    ["NorthFar"] = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -712.81, [5] = -937.81, [6] = -937.81, [7] = -937.81 },
    ["South"]    = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 412.19,  [5] = 412.19,  [6] = 412.19,  [7] = 412.19 },
    ["SouthFar"] = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 637.19,  [5] = 862.19,  [6] = 1087.19,  [7] = 1312.19 },
    ["Center"]   = { [1] = -37.81, [2] = -37.81,  [3] = -37.81,  [4] = -37.81,  [5] = -37.81,  [6] = -37.81,   [7] = -37.81 },
}

function rafting.selectOptimalPipeline()
    local route = rafting.route or "Hybrid Dynamic Explorer"
    if route:find("Fast Sea") or route:find("Center") then
        return "Center"
    elseif route:find("Leftmost") then
        return "NorthFar"
    elseif route:find("North Channels") then
        return "North"
    elseif route:find("South Channels") then
        return "South"
    end

    local northCount = 0
    local southCount = 0
    local wantsFarNorth = false
    local wantsFarSouth = false

    local sitesToScan = rafting.allSites or clearingSites or {}
    for _, site in ipairs(sitesToScan) do
        if rafting.isSiteSelected(site) then
            local shoreZ = site.ShoreZ or (site.Mouth and site.Mouth.Z) or -37.81
            if shoreZ < -100 then
                northCount = northCount + 1
                if shoreZ < -700 then
                    wantsFarNorth = true
                end
            elseif shoreZ > 50 then
                southCount = southCount + 1
                if shoreZ > 700 then
                    wantsFarSouth = true
                end
            end
        end
    end

    if northCount >= southCount and northCount > 0 then
        return if wantsFarNorth then "NorthFar" else "North"
    elseif southCount > 0 then
        return if wantsFarSouth then "SouthFar" else "South"
    end

    return "North"
end

local function getDownstreamChannelZ(reachIdx, curChZ, prefRoute)
    local rTrans = channelTransitions[reachIdx]
    if not rTrans then return curChZ end
    local validNext = nil
    local minDiff = 40
    for keyZ, list in pairs(rTrans) do
        local diff = math.abs(keyZ - curChZ)
        if diff < minDiff then
            minDiff = diff
            validNext = list
        end
    end
    if not validNext or #validNext == 0 then return curChZ end
    if #validNext == 1 then return validNext[1] end

    local pipeline = rafting.selectOptimalPipeline()
    local pCorr = pipelineCorridors[pipeline] or pipelineCorridors["North"]
    local nextReach = reachIdx + 1
    if pCorr and pCorr[nextReach] then
        local targetPZ = pCorr[nextReach]
        local bestPZ = validNext[1]
        local minPDiff = math.huge
        for _, z in ipairs(validNext) do
            local diff = math.abs(z - targetPZ)
            if diff < minPDiff then
                minPDiff = diff
                bestPZ = z
            end
        end
        return bestPZ
    end

    local r = prefRoute or rafting.route or ""
    if r:find("Leftmost") or r:find("North") or r:find("Left") then
        local minZ = math.huge
        for _, z in ipairs(validNext) do
            if z < minZ then minZ = z end
        end
        return minZ
    elseif r:find("South") or r:find("Right") then
        local maxZ = -math.huge
        for _, z in ipairs(validNext) do
            if z > maxZ then maxZ = z end
        end
        return maxZ
    else
        local bestNext = validNext[1]
        local closestDiff = math.huge
        for _, z in ipairs(validNext) do
            local diff = math.abs(z - curChZ)
            if diff < closestDiff then
                closestDiff = diff
                bestNext = z
            end
        end
        return bestNext
    end
end

local function getReachableChannelsInReach(curReach, curChZ, targetReach)
    local currentSet = { [curChZ] = true }
    if curReach >= targetReach then
        return currentSet
    end
    for r = curReach, targetReach - 1 do
        local nextSet = {}
        local rTransitions = channelTransitions[r]
        if rTransitions then
            for chZ in pairs(currentSet) do
                local matchedTrans = nil
                local minDiff = 40
                for transKey, targets in pairs(rTransitions) do
                    local diff = math.abs(transKey - chZ)
                    if diff < minDiff then
                        minDiff = diff
                        matchedTrans = targets
                    end
                end
                if matchedTrans then
                    for _, nextZ in ipairs(matchedTrans) do
                        nextSet[nextZ] = true
                    end
                end
            end
        end
        if not next(nextSet) then
            return currentSet
        end
        currentSet = nextSet
    end
    return currentSet
end

local zoneSites = {
    [1] = { "Clearing_01", "Cave_Cubby02", "Cave_Cubby01", "Clearing_02" },
    [2] = { "Clearing_03", "Cave_Cubby03", "Clearing_04" },
    [3] = { "Clearing_05", "Clearing_07", "Clearing_06", "Cave_Cubby04", "Clearing_08" },
    [4] = { "Clearing_09", "Cave_11", "Clearing_10", "Cave_12", "Cave_Cubby05" },
}

local siteZoneMap = {
    ["Clearing_01"] = 1, ["Cave_Cubby02"] = 1, ["Cave_Cubby01"] = 1, ["Clearing_02"] = 1,
    ["Clearing_03"] = 2, ["Cave_Cubby03"] = 2, ["Clearing_04"] = 2,
    ["Clearing_05"] = 3, ["Clearing_07"] = 3, ["Clearing_06"] = 3, ["Cave_Cubby04"] = 3, ["Clearing_08"] = 3,
    ["Clearing_09"] = 4, ["Cave_11"] = 4, ["Clearing_10"] = 4, ["Cave_12"] = 4, ["Cave_Cubby05"] = 4,
}

local siteReach = {
    ["Clearing_01"] = 1, ["Cave_Cubby02"] = 1, ["Clearing_02"] = 1, ["Cave_Cubby01"] = 1,
    ["Clearing_03"] = 3, ["Cave_Cubby03"] = 3, ["Clearing_04"] = 3,
    ["Clearing_05"] = 5, ["Clearing_06"] = 5, ["Cave_Cubby04"] = 5, ["Clearing_07"] = 5, ["Clearing_08"] = 5,
    ["Cave_11"] = 7, ["Clearing_09"] = 7, ["Clearing_10"] = 7, ["Cave_Cubby05"] = 7, ["Cave_12"] = 7,
}

local siteCorridors = {
    -- Level 1 & 2 (Reach 1)
    ["Clearing_01"] = { [1] = -37.81 },
    ["Clearing_02"] = { [1] = -37.81 },
    ["Cave_Cubby01"] = { [1] = -37.81 },
    ["Cave_Cubby02"] = { [1] = -37.81 },

    -- Level 3 (Reach 3)
    ["Clearing_03"] = { [1] = -37.81, [2] = -262.81, [3] = -487.81 },
    ["Clearing_04"] = { [1] = -37.81, [2] = 187.19,  [3] = 412.19 },
    ["Cave_Cubby03"] = { [1] = -37.81, [2] = -37.81,  [3] = -37.81 },

    -- Level 4 Delta (Reach 5)
    ["Clearing_05"] = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -712.81, [5] = -937.81 },
    ["Clearing_06"] = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -487.81, [5] = -487.81 },
    ["Cave_Cubby04"] = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -487.81, [5] = -487.81 },
    ["Clearing_07"] = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 412.19,  [5] = 412.19 },
    ["Clearing_08"] = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 637.19,  [5] = 862.19 },

    -- Level 4 Terminus (Reach 7)
    ["Cave_Cubby05"]      = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -712.81, [5] = -937.81, [6] = -937.81,  [7] = -937.81 },
    ["Clearing_09"]       = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -712.81, [5] = -937.81, [6] = -937.81,  [7] = -937.81 },
    ["Clearing_10"]       = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -487.81, [5] = -487.81, [6] = -487.81,  [7] = -487.81 },
    ["Cave_11"]           = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 412.19,  [5] = 412.19,  [6] = 412.19,   [7] = 412.19 },
    ["Cave_12"]           = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 637.19,  [5] = 862.19,  [6] = 1087.19,  [7] = 1312.19 },
}

function rafting.isSiteReachable(site, posX, currentZ)
    if not site then return false end
    local maxX = site.MaxX or site.MinX
    if posX > (maxX + 25) then
        return false
    end
    if currentZ == nil then
        return true
    end

    local mouthX = site.Mouth and site.Mouth.X or ((site.MinX + site.MaxX) * 0.5)
    local shoreZ = site.ShoreZ or ((site.MinZ + site.MaxZ) * 0.5)

    -- If already inside cove or close proximity to mouth, reachable
    if posX >= (mouthX - 100) and posX <= (maxX + 25) then
        if math.abs(currentZ - shoreZ) <= 150 then
            return true
        end
    end

    local curChZ, curReach = rafting.getCurrentChannel(posX, currentZ)
    local sReach = siteReach[site.Id] or getReachIndex(mouthX)

    if curReach > sReach then
        return false
    end

    local corridors = siteCorridors[site.Id]
    local siteTargetChZ = corridors and corridors[sReach]

    if curReach == sReach then
        if siteTargetChZ and math.abs(curChZ - siteTargetChZ) > 40 then
            if site.Id == "Clearing_10" and (math.abs(curChZ - (-487.81)) <= 40 or math.abs(curChZ - (-37.81)) <= 40) then
                return true
            end
            if site.Id == "Cave_12" and (math.abs(curChZ - 862.19) <= 40 or math.abs(curChZ - 1312.19) <= 40) then
                return true
            end
            return false
        end
        return true
    else
        local reachableSet = getReachableChannelsInReach(curReach, curChZ, sReach)
        if siteTargetChZ then
            if reachableSet[siteTargetChZ] then
                return true
            end
            if site.Id == "Clearing_10" and (reachableSet[-487.81] or reachableSet[-37.81]) then
                return true
            end
            if site.Id == "Cave_12" and (reachableSet[862.19] or reachableSet[1312.19]) then
                return true
            end
            return false
        end
        return true
    end
end

local function getEndCaveSite(currentZ)
    rafting.ensureDynamicSites()
    local z = currentZ or -37.81
    local bestCave = nil
    local minDiff = math.huge
    if rafting.allSites then
        for _, s in ipairs(rafting.allSites) do
            if s.Kind == "Cave" and (s.MaxX or s.MinX) >= 5800 then
                local diff = math.abs((s.ShoreZ or -37.81) - z)
                if diff < minDiff then
                    minDiff = diff
                    bestCave = s
                end
            end
        end
    end
    return bestCave or rafting.sitesById["Cave_Cubby05"]
end

local leftmostSites = {
    ["Clearing_01"] = true,
    ["Cave_Cubby01"] = true,
    ["Clearing_03"] = true,
    ["Clearing_05"] = true,
    ["Cave_Cubby05"] = true,
}

local northPresetSites = {
    ["Clearing_01"] = true,
    ["Cave_Cubby01"] = true,
    ["Clearing_03"] = true,
    ["Cave_Cubby04"] = true,
    ["Clearing_05"] = true,
    ["Cave_Cubby05"] = true,
}

local southPresetSites = {
    ["Cave_Cubby02"] = true,
    ["Clearing_02"] = true,
    ["Cave_Cubby03"] = true,
    ["Clearing_04"] = true,
    ["Clearing_07"] = true,
    ["Clearing_08"] = true,
    ["Cave_11"] = true,
    ["Cave_12"] = true,
}

function rafting.isSiteSelected(site)
    if not site then return false end
    local route = rafting.route or "Hybrid Dynamic Explorer"
    if string.find(route, "Fast Sea Run", 1, true) then
        return false
    end
    if string.find(route, "Leftmost", 1, true) then
        return leftmostSites[site.Id] == true
    end
    if string.find(route, "North Channels", 1, true) then
        return northPresetSites[site.Id] == true
    end
    if string.find(route, "South Channels", 1, true) then
        return southPresetSites[site.Id] == true
    end
    if string.find(route, "Clearing & Chest Explorer", 1, true) or rafting.selectAllClearings then
        return site.Kind == "Clearing"
    end
    if rafting.selectAllSites then
        return true
    end
    if rafting.selectedClearings then
        return rafting.selectedClearings[site.Id] == true
    end
    return false
end

function rafting.getNextTargetClearing(posX, currentZ)
    rafting.ensureDynamicSites()
    local route = rafting.route or "Hybrid Dynamic Explorer"
    if string.find(route, "Fast Sea Run", 1, true) then
        rafting.isSelfCorrecting = false
        return nil
    end

    local bestSite = nil
    local bestCost = math.huge

    local pipeline = rafting.selectOptimalPipeline()
    local pCorr = pipelineCorridors[pipeline] or pipelineCorridors["North"]

    local sitesToScan = rafting.allSites or clearingSites
    for _, site in ipairs(sitesToScan) do
        local isCandidate = rafting.isSiteSelected(site)

        if isCandidate and not rafting.visitedSites[site.Id] then
            if posX <= (site.MaxX or site.MinX) + 25 then
                local sReach = siteReach[site.Id] or getReachIndex(site.MinX)
                local expectedChZ = pCorr[sReach] or -37.81
                local corridors = siteCorridors[site.Id]
                local siteTargetChZ = (corridors and corridors[sReach]) or expectedChZ

                -- Dynamic reachability: site must be physically accessible downstream from current position
                if currentZ == nil or rafting.isSiteReachable(site, posX, currentZ) then
                    local mouthX = site.Mouth and site.Mouth.X or site.MinX
                    local dx = math.max(0, mouthX - posX)
                    local dz = math.abs((site.ShoreZ or -37.81) - (currentZ or -37.81))
                    -- Prefer sites aligned with active pipeline, but reachable sites are always valid (autocorrect for weather)
                    local pipelinePenalty = (math.abs(siteTargetChZ - expectedChZ) <= 50) and 0 or 250
                    local cost = dx + dz * 0.4 + pipelinePenalty
                    if cost < bestCost then
                        bestCost = cost
                        bestSite = site
                    end
                end
            else
                rafting.visitedSites[site.Id] = true
            end
        end
    end

    if bestSite then
        rafting.isSelfCorrecting = false
        return bestSite
    end

    -- End Cave fallback if route explicitly specifies caves or pipeline ends at cave
    if string.find(route, "Leftmost", 1, true) or string.find(route, "North Channels", 1, true) or pipeline:find("North") then
        local endSite = rafting.sitesById["Cave_Cubby05"]
        if endSite and not rafting.visitedSites[endSite.Id] and posX <= (endSite.MaxX or endSite.MinX) + 25 and rafting.isSiteReachable(endSite, posX, currentZ) then
            rafting.isSelfCorrecting = false
            return endSite
        end
    elseif string.find(route, "South Channels", 1, true) or pipeline:find("South") then
        local endSite = rafting.sitesById["Cave_12"] or rafting.sitesById["Cave_11"]
        if endSite and not rafting.visitedSites[endSite.Id] and posX <= (endSite.MaxX or endSite.MinX) + 25 and rafting.isSiteReachable(endSite, posX, currentZ) then
            rafting.isSelfCorrecting = false
            return endSite
        end
    end

    -- Opportunistic Self-Correction Fallback:
    -- Raft in a channel where no user-selected sites are reachable.
    -- Dock at nearest accessible clearing or cubby in this zone/reach!
    if rafting.allSites then
        local bestFallback = nil
        local bestFallbackCost = math.huge
        for _, site in ipairs(rafting.allSites) do
            if not rafting.visitedSites[site.Id] and posX <= (site.MaxX or site.MinX) + 25 then
                if rafting.isSiteReachable(site, posX, currentZ) then
                    local mouthX = site.Mouth and site.Mouth.X or site.MinX
                    local dx = math.max(0, mouthX - posX)
                    local dz = math.abs((site.ShoreZ or -37.81) - (currentZ or -37.81))
                    local cost = dz * 1.5 + dx
                    if cost < bestFallbackCost then
                        bestFallbackCost = cost
                        bestFallback = site
                    end
                end
            end
        end
        if bestFallback then
            rafting.isSelfCorrecting = true
            return bestFallback
        end
    end

    rafting.isSelfCorrecting = false

    if rafting.selectAllSites then
        local ec = getEndCaveSite(currentZ)
        if ec and rafting.isSiteReachable(ec, posX, currentZ) then return ec end
    end
    if rafting.selectedClearings then
        for sId, active in pairs(rafting.selectedClearings) do
            if active and (string.sub(sId, 1, 4) == "Cave") then
                local ec = getEndCaveSite(currentZ)
                if ec and rafting.isSiteReachable(ec, posX, currentZ) then return ec end
            end
        end
    end

    -- When clearings only selected and all passed downriver, return nil (steer straight to sea)
    return nil
end

local function parseSiteId(opt)
    if not opt or type(opt) ~= "string" then return nil end
    local cubbyNum = string.match(opt, "Cubby%s*(%d+)")
    if cubbyNum then
        return string.format("Cave_Cubby%02d", tonumber(cubbyNum))
    end
    local clearingNum = string.match(opt, "Clearing%s*(%d+)")
    if clearingNum then
        return string.format("Clearing_%02d", tonumber(clearingNum))
    end
    local caveNum = string.match(opt, "Cave%s*(%d+)")
    if caveNum then
        return string.format("Cave_%s", caveNum)
    end
    return nil
end

local zone1Sites = { ["Clearing_01"] = true, ["Cave_Cubby01"] = true, ["Cave_Cubby02"] = true, ["Clearing_02"] = true }
local zone2Sites = { ["Clearing_03"] = true, ["Cave_Cubby03"] = true, ["Clearing_04"] = true }
local zone3Sites = { ["Clearing_05"] = true, ["Cave_Cubby04"] = true, ["Clearing_06"] = true, ["Clearing_07"] = true, ["Clearing_08"] = true }
local zone4Sites = { ["Cave_Cubby05"] = true, ["Clearing_09"] = true, ["Clearing_10"] = true, ["Cave_11"] = true, ["Cave_12"] = true }

function rafting.getSiteZone(siteOrId)
    local sid = type(siteOrId) == "table" and siteOrId.Id or siteOrId
    if not sid then return 1 end
    if zone1Sites[sid] then return 1 end
    if zone2Sites[sid] then return 2 end
    if zone3Sites[sid] then return 3 end
    if zone4Sites[sid] then return 4 end

    -- Fallback by X coordinate
    local x = type(siteOrId) == "table" and ((siteOrId.MinX + siteOrId.MaxX) * 0.5) or 0
    if x > 0 then
        if x < 2000 then return 1
        elseif x < 3600 then return 2
        elseif x < 5400 then return 3
        else return 4 end
    end
    return 1
end

function rafting.updateZoneSites(zoneIdx, options)
    rafting.ensureDynamicSites()
    if not rafting.selectedByZone then
        rafting.selectedByZone = { [1] = {}, [2] = {}, [3] = {}, [4] = {} }
    end
    local zoneSet = {}
    if type(options) == "table" then
        for k, v in pairs(options) do
            local optStr = type(k) == "number" and v or k
            local sid = parseSiteId(optStr)
            if sid then
                zoneSet[sid] = true
            end
        end
    elseif type(options) == "string" then
        local sid = parseSiteId(options)
        if sid then
            zoneSet[sid] = true
        end
    end

    rafting.selectedByZone[zoneIdx] = zoneSet

    local combined = {}
    for z = 1, 4 do
        local zMap = rafting.selectedByZone[z]
        if zMap then
            for sid, active in pairs(zMap) do
                if active then combined[sid] = true end
            end
        end
    end
    rafting.selectedClearings = combined
    rafting.selectAllSites = false
    rafting.selectAllClearings = false
    rafting.updateCards()
end

function rafting.updateTargetClearings(options)
    rafting.ensureDynamicSites()
    local selected = {}
    local selectAllSites = false
    local selectAllClearings = false
    local hasSpecific = false

    local function parseOption(opt)
        if not opt or type(opt) ~= "string" then return end
        if string.find(opt, "All Sites", 1, true) then
            selectAllSites = true
            return
        end
        if opt == "All Clearings" or string.find(opt, "All Clearings", 1, true) then
            selectAllClearings = true
            return
        end
        local sid = parseSiteId(opt)
        if sid then
            selected[sid] = true
            hasSpecific = true
        end
    end

    if type(options) == "table" then
        for k, v in pairs(options) do
            if type(k) == "number" and type(v) == "string" then
                parseOption(v)
            elseif type(k) == "string" and v == true then
                parseOption(k)
            end
        end
    elseif type(options) == "string" then
        parseOption(options)
    end

    if hasSpecific then
        selectAllSites = false
        selectAllClearings = false
    elseif selectAllSites and rafting.allSites then
        for _, s in ipairs(rafting.allSites) do
            selected[s.Id] = true
        end
    elseif selectAllClearings and rafting.allSites then
        for _, s in ipairs(rafting.allSites) do
            if s.Kind == "Clearing" then
                selected[s.Id] = true
            end
        end
    end

    rafting.selectAllSites = selectAllSites
    rafting.selectAllClearings = selectAllClearings
    rafting.selectedClearings = selected
    rafting.updateCards()
end

local whiskerRayParams = RaycastParams.new()
whiskerRayParams.FilterType = Enum.RaycastFilterType.Exclude
whiskerRayParams.IgnoreWater = true

function rafting.getWhiskerClearances(deck)
    local now = os.clock()
    if (now - (rafting.lastSensorAt or 0)) < 0.08 and rafting.whiskerClearances and next(rafting.whiskerClearances) then
        return rafting.whiskerClearances
    end
    rafting.lastSensorAt = now

    local filterList = {}
    if char then table.insert(filterList, char) end
    if rafting.raftModel then table.insert(filterList, rafting.raftModel) end
    if deck then table.insert(filterList, deck) end
    whiskerRayParams.FilterDescendantsInstances = filterList

    -- Origins placed on perimeter: bow center at Z = -14.0, bow shoulders at X = +/- 5.0, Z = -12.0
    local bowCenterOrigin  = deck.CFrame:PointToWorldSpace(Vector3.new(0, 2.5, -14.0))
    local bowLeftOrigin    = deck.CFrame:PointToWorldSpace(Vector3.new(-5.0, 2.5, -12.0))
    local bowRightOrigin   = deck.CFrame:PointToWorldSpace(Vector3.new(5.0, 2.5, -12.0))
    local midLeftOrigin    = deck.CFrame:PointToWorldSpace(Vector3.new(-6.0, 2.5, 0.0))
    local midRightOrigin   = deck.CFrame:PointToWorldSpace(Vector3.new(6.0, 2.5, 0.0))
    local sternLeftOrigin  = deck.CFrame:PointToWorldSpace(Vector3.new(-6.0, 2.5, 12.0))
    local sternRightOrigin = deck.CFrame:PointToWorldSpace(Vector3.new(6.0, 2.5, 12.0))

    -- Extended phased raycast shield to sense rock facades and divider islands far in advance
    local whiskers = {
        Forward        = { origin = bowCenterOrigin,  dir = Vector3.new(0, 0, -1), range = 110 },
        ForwardLeft    = { origin = bowLeftOrigin,    dir = Vector3.new(-0.2588, 0, -0.9659), range = 95 },
        ForwardRight   = { origin = bowRightOrigin,   dir = Vector3.new(0.2588, 0, -0.9659), range = 95 },
        LeftOblique    = { origin = bowLeftOrigin,    dir = Vector3.new(-0.5736, 0, -0.8192), range = 75 },
        RightOblique   = { origin = bowRightOrigin,   dir = Vector3.new(0.5736, 0, -0.8192), range = 75 },
        LeftLateral    = { origin = midLeftOrigin,    dir = Vector3.new(-1, 0, 0), range = 45 },
        RightLateral   = { origin = midRightOrigin,   dir = Vector3.new(1, 0, 0), range = 45 },
        LeftStern      = { origin = sternLeftOrigin,  dir = Vector3.new(-1, 0, 0), range = 40 },
        RightStern     = { origin = sternRightOrigin, dir = Vector3.new(1, 0, 0), range = 40 },
    }

    local distances = {}
    for name, w in pairs(whiskers) do
        local worldDir = deck.CFrame:VectorToWorldSpace(w.dir)
        local result = workspace:Raycast(w.origin, worldDir * w.range, whiskerRayParams)
        local isSolid = false
        if result and result.Instance then
            if result.Instance:IsA("Terrain") then
                isSolid = (result.Material ~= Enum.Material.Water)
            elseif result.Instance.CanCollide then
                isSolid = true
            end
        end
        if isSolid then
            distances[name] = (result.Position - w.origin).Magnitude
        else
            distances[name] = w.range
        end
    end

    -- Mathematical Canal Boundary Enclosure (Harbour: Dock to Delta Entrance)
    if deck and FjordZones and FjordZones.RibbonAt then
        local posX = deck.Position.X
        local posZ = deck.Position.Z
        if posX <= 1094.58 then
            local cz, hw = FjordZones.RibbonAt(posX)
            if cz and hw then
                local distToNorthBank = math.max(0, posZ - (cz - hw))
                local distToSouthBank = math.max(0, (cz + hw) - posZ)
                distances.LeftLateral = math.min(distances.LeftLateral, distToNorthBank)
                distances.LeftOblique = math.min(distances.LeftOblique, distToNorthBank * 1.25)
                distances.LeftStern = math.min(distances.LeftStern, distToNorthBank)
                distances.RightLateral = math.min(distances.RightLateral, distToSouthBank)
                distances.RightOblique = math.min(distances.RightOblique, distToSouthBank * 1.25)
                distances.RightStern = math.min(distances.RightStern, distToSouthBank)
            end
        end
    end

    rafting.whiskerClearances = distances
    return distances
end

function rafting.getTargetZ(posX, currentZ, clearances)
    -- In Harbour canal (Dock at -241 to Reach 1 Canyon entrance at 200), follow official canal ribbon
    if posX <= 200 then
        if FjordZones and FjordZones.RibbonAt then
            local z = FjordZones.RibbonAt(posX)
            if z then return z end
        end
        return getHarbourZ(posX)
    end

    -- If currently inside or departing a visited clearing cove, steer back towards the reach channel
    local departSiteId = rafting.currentDockSite or rafting.lastDepartSite
    local departSite = departSiteId and (rafting.sitesById[departSiteId] or rafting.getClearingById(departSiteId))
    if departSite then
        local isDeparting = (os.clock() - (rafting.lastCastOffTime or 0)) < 6.0
        local insideCoveBounds = posX <= (departSite.MaxX + 40)
        local rd = getReachData()
        local reachIdx = getReachIndex(posX)
        local forkX = rd and rd.forkX and rd.forkX[reachIdx]
        local nearUpcomingFork = forkX and (posX >= (forkX - 100))
        if (isDeparting or insideCoveBounds) and not nearUpcomingFork then
            return rafting.getSiteChannelZ(departSite)
        end
    end

    -- Find next upcoming selected, unvisited, and reachable clearing
    local targetSite = rafting.getNextTargetClearing(posX, currentZ)
    local rd = getReachData()
    local reachIdx = getReachIndex(posX)
    local r = rafting.route or "Hybrid Dynamic Explorer"

    if not targetSite then
        local curChZ, rIdx = rafting.getCurrentChannel(posX, currentZ)
        local curCenterZ = rafting.getChannelCenterZ(rIdx, curChZ, posX)
        local forkX = rd.forkX[rIdx]
        local forkLead = 320.0
        if forkX and posX >= (forkX - forkLead) and posX <= forkX then
            local nextReach = math.min(rIdx + 1, rd.maxReach)
            local nextChZ = getDownstreamChannelZ(rIdx, curChZ, r)
            local targetThroatZ = nextChZ
            if rIdx == 1 then
                if nextChZ < -100 then
                    targetThroatZ = -105.0
                elseif nextChZ > 100 then
                    targetThroatZ = 25.0
                else
                    targetThroatZ = -37.81
                end
            else
                targetThroatZ = rafting.getChannelCenterZ(nextReach, nextChZ, forkX)
            end
            local rawT = math.clamp((posX - (forkX - forkLead)) / forkLead, 0, 1)
            local t = (1 - math.cos(rawT * math.pi)) * 0.5
            return curCenterZ + t * (targetThroatZ - curCenterZ)
        end
        return curCenterZ
    end

    local minX = targetSite.MinX
    local maxX = targetSite.MaxX
    local mouthX = targetSite.Mouth and targetSite.Mouth.X or ((minX + maxX) * 0.5)
    local mouthZ = targetSite.Mouth and targetSite.Mouth.Z or (targetSite.ShoreZ or -37.81)
    local shoreZ = targetSite.ShoreZ or mouthZ

    local corridors = siteCorridors[targetSite.Id]
    local nominalChZ = (corridors and corridors[reachIdx]) or rafting.getSiteChannelZ(targetSite)
    local currentChZ = rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)

    -- Physical channel clamp: prevent commanding cross-canyon Z if raft is in a different branch.
    -- Suppressed during fork transitions (320 studs before fork and 150 studs after fork).
    local physicalChZ = rafting.getCurrentChannel(posX, currentZ)
    local forkX = rd.forkX[reachIdx]
    local nearFork = (forkX and posX >= (forkX - 320)) or (reachIdx > 1 and posX <= ((rd.forkX[reachIdx - 1] or 0) + 150))
    if not nearFork and math.abs(physicalChZ - nominalChZ) > 40 then
        currentChZ = rafting.getChannelCenterZ(reachIdx, physicalChZ, posX)
        nominalChZ = physicalChZ
    end

    -- Two-Stage Cove Approach:
    -- Stage 1 (Approaching mouth from river): align with mouth opening in river bank (160 studs lead)
    if posX >= (mouthX - 160.0) and posX < mouthX then
        local rawT = math.clamp((posX - (mouthX - 160.0)) / 160.0, 0, 1)
        local t = (1 - math.cos(rawT * math.pi)) * 0.5
        return currentChZ + t * (mouthZ - currentChZ)
    end
    -- Stage 2 (Passing through mouth into interior): steer from mouth to landing dock
    if posX >= mouthX and posX <= (maxX + 25) then
        local leadIn = math.max(1.0, (maxX + 25) - mouthX)
        local rawT = math.clamp((posX - mouthX) / leadIn, 0, 1)
        local t = (1 - math.cos(rawT * math.pi)) * 0.5
        return mouthZ + t * (shoreZ - mouthZ)
    end

    -- Pre-Fork Spline Guidance: smooth continuous S-curve into the next reach channel (320 studs lead)
    local forkLead = 320.0
    if forkX and posX >= (forkX - forkLead) and posX <= forkX then
        local nextReach = math.min(reachIdx + 1, rd.maxReach)
        local nextNominalZ = (corridors and corridors[nextReach]) or getDownstreamChannelZ(reachIdx, nominalChZ, r)
        local targetThroatZ = nextNominalZ
        if reachIdx == 1 then
            if nextNominalZ < -100 then
                targetThroatZ = -105.0
            elseif nextNominalZ > 100 then
                targetThroatZ = 25.0
            else
                targetThroatZ = -37.81
            end
        else
            targetThroatZ = rafting.getChannelCenterZ(nextReach, nextNominalZ, forkX)
        end
        local rawT = math.clamp((posX - (forkX - forkLead)) / forkLead, 0, 1)
        local t = (1 - math.cos(rawT * math.pi)) * 0.5
        return currentChZ + t * (targetThroatZ - currentChZ)
    end

    return currentChZ
end

local function walkToPosition(targetPos, timeout, stopDistance)
    if not humanoid or not root then return false end
    timeout = timeout or 3.5
    stopDistance = stopDistance or 3.5
    humanoid.WalkSpeed = 24
    humanoid.AutoRotate = true
    if root then pcall(function() root.Anchored = false end) end
    humanoid:MoveTo(targetPos)

    local start = os.clock()
    local lastPos = root.Position
    local lastMoveTime = os.clock()

    while (os.clock() - start) < timeout do
        if not root or not humanoid then return false end
        local d = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
        if d <= stopDistance then
            humanoid:Move(Vector3.zero, false)
            return true
        end
        if (root.Position - lastPos).Magnitude > 0.5 then
            lastPos = root.Position
            lastMoveTime = os.clock()
        elseif (os.clock() - lastMoveTime) > 1.2 then
            break
        end
        task.wait(0.1)
    end
    return false
end

local function naturalWalkTo(targetWorldPos, timeout, stopDistance)
    if not humanoid or not root then return false end
    timeout = timeout or 8.0
    stopDistance = stopDistance or 3.5

    local path = nil
    if PathfindingService then
        pcall(function()
            path = PathfindingService:CreatePath({
                AgentRadius = 3.0,
                AgentHeight = 5.0,
                AgentCanJump = true,
                WaypointSpacing = 4.0,
                Costs = { Water = math.huge }
            })
            path:ComputeAsync(root.Position, targetWorldPos)
        end)
    end

    if path and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, wp in ipairs(waypoints) do
            if not root or not humanoid then return false end
            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            humanoid.WalkSpeed = 24
            humanoid.AutoRotate = true
            if root then pcall(function() root.Anchored = false end) end
            humanoid:MoveTo(wp.Position)

            local wpStart = os.clock()
            local lastP = root.Position
            local lastMoveT = os.clock()
            while os.clock() - wpStart < 2.0 do
                if not root or not humanoid then return false end
                local d = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(wp.Position.X, 0, wp.Position.Z)).Magnitude
                if d <= stopDistance then break end
                if (root.Position - lastP).Magnitude > 0.4 then
                    lastP = root.Position
                    lastMoveT = os.clock()
                elseif (os.clock() - lastMoveT) > 0.8 then
                    humanoid.Jump = true
                    break
                end
                task.wait(0.08)
            end
        end
        local finalDist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(targetWorldPos.X, 0, targetWorldPos.Z)).Magnitude
        if finalDist <= stopDistance then
            humanoid:Move(Vector3.zero, false)
            return true
        end
    end

    return walkToPosition(targetWorldPos, timeout, stopDistance)
end
rafting.naturalWalkTo = naturalWalkTo

local function ensureCowOnDeck(deck, timeoutSecs)
    if not deck or not root then return false end
    timeoutSecs = timeoutSecs or 5.0
    local startT = os.clock()
    while (os.clock() - startT) < timeoutSecs and rafting.enabled do
        if isCowOnDeck(deck) then
            return true
        end
        local elapsed = os.clock() - startT
        if naturalWalkTo and elapsed <= 3.0 then
            local deckTarget = deck.CFrame:PointToWorldSpace(Vector3.new(0, 3.45, 0))
            naturalWalkTo(deckTarget, 2.5, 2.5)
            local rel = deck.CFrame:PointToObjectSpace(root.Position)
            if math.abs(rel.X) > 5.8 or math.abs(rel.Z) > 14.0 or rel.Y < -0.5 then
                if humanoid then humanoid.Jump = true end
            end
        else
            placeCowAboveDeck(deck)
        end
        task.wait(0.2)
    end
    return isCowOnDeck(deck)
end
rafting.ensureCowOnDeck = ensureCowOnDeck

local function triggerChestNatively(chestModel)
    local prompt = chestModel and chestModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt.Enabled then
        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
            return true
        end
        if getconnections then
            local conns = getconnections(prompt.Triggered)
            if conns and #conns > 0 then
                for _, conn in ipairs(conns) do
                    if conn.Function then
                        pcall(conn.Function)
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function sendRaftKey(keyCode, holdSec)
    if VirtualInput and VirtualInput.SendKeyEvent then
        pcall(function()
            VirtualInput:SendKeyEvent(true, keyCode, false, game)
            task.wait(holdSec or 0.25)
            VirtualInput:SendKeyEvent(false, keyCode, false, game)
        end)
    end
end

local localPlayer = plr or Players.LocalPlayer

local function getContinueButton()
    local playerGui = (localPlayer or plr or Players.LocalPlayer) and (localPlayer or plr or Players.LocalPlayer):FindFirstChildWhichIsA("PlayerGui")
    if not playerGui then return nil end
    local hud = playerGui:FindFirstChild("FjordRaftingHUD")
    if hud then
        local btn = hud:FindFirstChild("Continue", true)
        if btn and btn:IsA("GuiButton") then return btn end
    end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if string.find(gui.Name, "Raft", 1, true) then
            local btn = gui:FindFirstChild("Continue", true)
            if btn and btn:IsA("GuiButton") then return btn end
        end
    end
    return nil
end
rafting.getContinueButton = getContinueButton

local function isContinueButtonActive()
    local btn = getContinueButton()
    return btn and btn.Visible and btn.Active or false
end
rafting.isContinueButtonActive = isContinueButtonActive

local function isBoardingAnimationActive()
    if isContinueButtonActive() then
        return false
    end
    local char = character or (localPlayer and localPlayer.Character)
    if char then
        local cowDeck = char:FindFirstChild("CowRaftingDeck")
        if cowDeck and cowDeck:GetAttribute("RaftBoarding") == true then
            return true
        end
        if char:GetAttribute("CowMoofCutscene") == true then
            return true
        end
    end
    if localPlayer and localPlayer:GetAttribute("CowMoofCutscene") == true then
        return true
    end
    local hum = humanoid or (char and char:FindFirstChildOfClass("Humanoid"))
    if hum then
        local ok, tracks = pcall(function() return hum:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, t in ipairs(tracks) do
                if t.IsPlaying then
                    local anim = t.Animation
                    local aName = anim and anim.Name and anim.Name:lower() or ""
                    local tName = t.Name and t.Name:lower() or ""
                    if aName:find("board") or tName:find("board") or aName:find("cutscene") or tName:find("cutscene") then
                        return true
                    end
                end
            end
        end
    end
    local snap = rafting.currentSnapshot
    if snap and snap.AllAboard == false and snap.Status ~= "Travelling" then
        return true
    end
    return false
end
rafting.isBoardingAnimationActive = isBoardingAnimationActive

local function triggerRaftingCommand(cmd)
    if cmd == "Sail" or cmd == "Continue" or cmd == "Start" or cmd == "Vote" then
        sendRaftKey(Enum.KeyCode.N, 0.25)
    elseif cmd == "Return" then
        sendRaftKey(Enum.KeyCode.H, 0.25)
    end

    local candidateNames = { cmd, cmd .. "Button" }
    if cmd == "Sail" or cmd == "Start" or cmd == "Vote" then
        table.insert(candidateNames, "Continue")
        table.insert(candidateNames, "ContinueButton")
    end

    local playerGui = localPlayer and localPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if string.find(gui.Name, "Raft", 1, true) then
                for _, name in ipairs(candidateNames) do
                    local btn = gui:FindFirstChild(name, true)
                    if btn and btn:IsA("GuiButton") and btn.Visible and btn.Active then
                        if firesignal then
                            pcall(function() firesignal(btn.Activated) end)
                        end
                        if getconnections then
                            local conns = getconnections(btn.Activated)
                            if conns and #conns > 0 then
                                for _, c in ipairs(conns) do
                                    if c.Function then pcall(c.Function); return true end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

function rafting.castOff()
    local rem = rafting.getRemote()
    if not rem then return end
    if rafting.isCastingOff then return end
    rafting.isCastingOff = true
    rafting.lastCastOffTime = os.clock()
    rafting.lastProgressPos = nil
    rafting.lastProgressX = nil
    rafting.lastProgressTime = 0
    rafting.stuckDuration = 0
    rafting.isUnsticking = false
    rafting.unstickDirection = 0
    rafting.unstickStartTime = 0
    local wasDocked = (rafting.status == "Docked")
    rafting.statusText = "Boarding raft..."
    rafting.updateCards()

    task.spawn(function()
        local deck = rafting.getRaftDeck()
        local onDeck = ensureCowOnDeck(deck, 6.0)
        if onDeck then
            local waitAnimStart = os.clock()
            while isBoardingAnimationActive() and (os.clock() - waitAnimStart) < 6.0 and rafting.enabled do
                task.wait(0.2)
            end
            task.wait(0.3) -- Allow native _stepDeckMotion to register and bind Key N
            -- Dispatch departure via native Key N (FjordRafting_Continue)
            sendRaftKey(Enum.KeyCode.N, 0.25)
            if wasDocked then
                triggerRaftingCommand("Continue")
            end
        end

        task.delay(1.5, function()
            if rafting.enabled and rafting.isDockedState then
                rafting.fireRemoteSafely("Continue", nil, 2.0)
            end
        end)

        -- Resume sailing state
        rafting.status = "Travelling"
        rafting.isDockedState = false
        rafting.currentDockSite = nil
        rafting.isSailing = true
        rafting.statusText = "Resuming voyage..."
        rafting.isCastingOff = false
        rafting.updateCards()
    end)
end

function rafting.updateCards()
    local snap = rafting.currentSnapshot
    local statusTitle = "Fjord Rafting: " .. tostring(rafting.statusText)
    local nextSite = snap and snap.Frame and typeof(snap.Frame) == "CFrame" and rafting.getNextTargetClearing(snap.Frame.Position.X, snap.Frame.Position.Z)
    local nextSiteStr = nextSite and nextSite.Id or "Sea (Finish)"
    if nextSite and rafting.isSelfCorrecting then
        nextSiteStr = nextSiteStr .. " (Self-Corrected)"
    end
    local pipeline = rafting.selectOptimalPipeline and rafting.selectOptimalPipeline() or "North"
    local statusContent = string.format("Session: %s | Auto-Pilot: %s | Target: %s\nRoute: %s (%s Pipeline) | Natural: %s | Auto-Loop: %s",
        tostring(rafting.status),
        rafting.enabled and "Active" or "Disabled",
        nextSiteStr,
        tostring(rafting.route),
        tostring(pipeline),
        rafting.naturalMode and "ON" or "OFF",
        rafting.autoLoop and "ON" or "OFF"
    )

    if rafting.statusCard then
        pcall(function()
            if rafting.statusCard.SetTitle then
                rafting.statusCard:SetTitle(statusTitle)
                rafting.statusCard:Set(statusContent)
            elseif rafting.statusCard.Set then
                rafting.statusCard:Set({ Title = statusTitle, Content = statusContent })
            end
        end)
    end

    if rafting.telemetryCard then
        local hp = snap and snap.Health or 0
        local maxHp = snap and snap.MaxHealth or 120
        local nrg = snap and snap.Energy or 0
        local maxNrg = snap and snap.MaxEnergy or 326
        local spd = snap and snap.Speed or 0
        local steer = snap and snap.Steering or 0
        local posStr = "N/A"
        if snap and snap.Frame and typeof(snap.Frame) == "CFrame" then
            posStr = string.format("X: %d | Z: %d", math.floor(snap.Frame.Position.X), math.floor(snap.Frame.Position.Z))
        end

        local w = rafting.whiskerClearances or {}
        local whiskerStr = string.format("Whiskers: L:%.0f | F:%.0f | R:%.0f", w.LeftLateral or 25, w.Forward or 50, w.RightLateral or 25)

        local telemTitle = string.format("Raft Telemetry | HP: %d/%d | Energy: %d/%d", hp, maxHp, nrg, maxNrg)
        local telemBody = string.format("Speed: %.1f kts | Steering: %+.2f | Pos: %s\nReach: %s | Boosting: %s | %s",
            spd,
            steer,
            posStr,
            tostring(snap and snap.Reach or "Harbour"),
            tostring(snap and snap.Boosting == true),
            whiskerStr
        )
        pcall(function()
            if rafting.telemetryCard.SetTitle then
                rafting.telemetryCard:SetTitle(telemTitle)
                rafting.telemetryCard:Set(telemBody)
            elseif rafting.telemetryCard.Set then
                rafting.telemetryCard:Set({ Title = telemTitle, Content = telemBody })
            end
        end)
    end
end

function rafting.handleHobgoblinRock(rock)
    if not rock or typeof(rock) ~= "table" or not rock.Id or not rock.Landing then return end
    if rock.RaftId and rafting.sessionId and tostring(rock.RaftId) ~= tostring(rafting.sessionId) then
        return
    end

    rock.ReceivedAt = os.clock()
    rafting.incomingRocks[rock.Id] = rock

    if rafting.autoEvadeHobgoblins then
        local flight = rock.Flight or 1.8
        Window:Notify({
            Title = "Hobgoblin Attack!",
            Content = string.format("Rock incoming! Evading impact (%.1fs)...", flight),
            Duration = math.clamp(flight, 1.5, 3)
        })
    end
end

function rafting.handleHobgoblinLanded(landed)
    if not landed or typeof(landed) ~= "table" or not landed.Id then return end
    rafting.incomingRocks[landed.Id] = nil
    if landed.Hit then
        rafting.lastRockHitTime = os.clock()
    end
end

function rafting.getThreatEvasionOffset(deck, frame)
    if not rafting.autoEvadeHobgoblins then
        rafting.isEvadingRock = false
        return nil, false, false
    end

    local now = os.clock()
    local bestEvadeDeckX = nil
    local shouldBoost = false
    local shouldJump = false
    local threatFound = false

    local speed = (rafting.currentSnapshot and rafting.currentSnapshot.Speed) or 25
    local threats = {}

    -- 1. Incoming Hobgoblin projectile rocks
    if rafting.incomingRocks then
        for rockId, rock in pairs(rafting.incomingRocks) do
            local flight = rock.Flight or 1.8
            local elapsed = now - (rock.ReceivedAt or now)
            local timeLeft = flight - elapsed
            if timeLeft < -0.5 or elapsed > 5.0 then
                rafting.incomingRocks[rockId] = nil
            elseif timeLeft > 0 and timeLeft < 2.5 then
                table.insert(threats, { pos = rock.Landing or Vector3.new(rock.X or 0, 700.5, rock.Z or 0), timeLeft = timeLeft })
            end
        end
    end

    -- 2. Workspace visual hazard indicators (LocalHobgoblinFx rings / cores)
    local fxFolder = workspace:FindFirstChild("LocalHobgoblinFx")
    if fxFolder then
        for _, child in ipairs(fxFolder:GetChildren()) do
            if child:IsA("BasePart") and child.Name == "RockRing" then
                local dist = (child.Position - deck.Position).Magnitude
                if dist < 60 then
                    local timeLeft = math.clamp(dist / math.max(speed, 10), 0.2, 2.0)
                    table.insert(threats, { pos = child.Position, timeLeft = timeLeft })
                end
            end
        end
    end

    if #threats > 0 then
        table.sort(threats, function(a, b) return a.timeLeft < b.timeLeft end)
        for _, entry in ipairs(threats) do
            local threatPos = entry.pos
            local timeLeft = entry.timeLeft
            local forwardVec = deck.CFrame.LookVector
            local predictedPos = deck.Position + forwardVec * (speed * timeLeft)
            local predictedFrame = CFrame.new(predictedPos) * (deck.CFrame - deck.Position)
            local relLanding = predictedFrame:PointToObjectSpace(threatPos)

            if math.abs(relLanding.X) <= 12.0 and math.abs(relLanding.Z) <= 18.0 then
                threatFound = true
                if relLanding.X <= 0 then
                    bestEvadeDeckX = 4.5
                else
                    bestEvadeDeckX = -4.5
                end
                if relLanding.Z >= -4 then
                    shouldBoost = true
                end
                if timeLeft <= 0.35 and root then
                    local cowDist = (root.Position - threatPos).Magnitude
                    if cowDist <= 12 then
                        shouldJump = true
                    end
                end
                break
            end
        end
    end

    rafting.isEvadingRock = threatFound
    return bestEvadeDeckX, shouldBoost, shouldJump
end

rafting.getHobgoblinEvasionOffset = rafting.getThreatEvasionOffset

function rafting.dismissChestRewardGui(force)
    if not force and rafting.autoDismissRewardGui == false and rafting.autoAcceptRewards == false then return false end
    local p = plr or Players.LocalPlayer or localPlayer
    local pg = nil
    pcall(function() pg = p and p:FindFirstChildWhichIsA("PlayerGui") end)
    if not pg then return false end
    local dismissed = false
    local vi = VirtualInput

    -- 1. Targeted dismissal for known reward / reveal modal ScreenGuis (RewardBoxReveal from TeamChestController, etc.)
    local targetGuiNames = { "RewardBoxReveal", "CaravanCrateReveal", "CowFavoriteReward", "FavoriteRewardPrompt", "QuestModal" }
    for _, tName in ipairs(targetGuiNames) do
        local rGui = nil
        pcall(function() rGui = pg:FindFirstChild(tName) end)
        local isTargetActive = false
        pcall(function()
            if rGui and rGui:IsA("ScreenGui") and rGui.Enabled then
                isTargetActive = true
            end
        end)
        if isTargetActive then
            -- Find action buttons inside panel (Primary: "Done" / "Open another", Secondary: "Done", WearIt, KeepRaiding, NotNow)
            local descs = nil
            pcall(function() descs = rGui:GetDescendants() end)
            if descs then
                for _, desc in ipairs(descs) do
                    pcall(function()
                        if desc:IsA("GuiButton") and desc.Visible then
                            local dName = desc.Name:lower()
                            local dText = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                            if dName == "primary" or dName == "secondary" or dName == "wearit" or dName == "keepraiding" or dName == "notnow"
                                or dText == "done" or dText:find("done") or dText:find("open another") or dText:find("wear") or dText:find("keep") or dText:find("not now") or dText:find("close") then
                                if firesignal then
                                    pcall(function() firesignal(desc.Activated) end)
                                    pcall(function() firesignal(desc.MouseButton1Click) end)
                                end
                                if getconnections then
                                    pcall(function()
                                        for _, c in ipairs(getconnections(desc.Activated)) do
                                            if c.Function then pcall(c.Function) end
                                        end
                                        for _, c in ipairs(getconnections(desc.MouseButton1Click)) do
                                            if c.Function then pcall(c.Function) end
                                        end
                                    end)
                                end
                                if vi and vi.SendMouseButtonEvent then
                                    pcall(function()
                                        local abs = desc.AbsolutePosition + (desc.AbsoluteSize * 0.5)
                                        vi:SendMouseButtonEvent(abs.X, abs.Y, 0, true, game, 1)
                                        task.wait(0.04)
                                        vi:SendMouseButtonEvent(abs.X, abs.Y, 0, false, game, 1)
                                    end)
                                end
                                dismissed = true
                            end
                        end
                    end)
                end
            end
            -- Send Escape key (natively bound to CowRewardBoxRevealClose in ContextActionService at priority 3300)
            if vi and vi.SendKeyEvent then
                pcall(function()
                    vi:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                    task.wait(0.05)
                    vi:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                end)
            end
            -- Direct safety disable
            pcall(function() rGui.Enabled = false end)
            dismissed = true
        end
    end

    -- 2. General recursive search across all active ScreenGuis and BillboardGuis
    local children = nil
    pcall(function() children = pg:GetChildren() end)
    if children then
        for _, gui in ipairs(children) do
            local canCheck = false
            local gName = ""
            pcall(function()
                if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                    gName = gui.Name:lower()
                    if not gName:find("rayfield") and not gName:find("cowhub") and not gName:find("fjordraftinghud") then
                        canCheck = true
                    end
                end
            end)
            if canCheck then
                local descs = nil
                pcall(function() descs = gui:GetDescendants() end)
                if descs then
                    for _, desc in ipairs(descs) do
                        pcall(function()
                            if desc:IsA("GuiButton") and desc.Visible then
                                local name = desc.Name:lower()
                                local text = (desc:IsA("TextButton") and desc.Text:lower()) or ""
                                local attrLabel = desc:GetAttribute("AccessibilityLabel")
                                local labelText = (typeof(attrLabel) == "string" and attrLabel:lower()) or ""

                                local isRewardBtn = name == "primary" or name == "secondary" or name == "wearit" or name == "keepraiding" or name == "notnow"
                                    or name:find("accept") or name:find("okay") or name == "ok" or name:find("claim") or name:find("confirm") or name:find("close") or name:find("dismiss") or name:find("done")
                                    or text == "done" or text:find("done") or text:find("accept") or text:find("okay") or text == "ok" or text:find("claim") or text:find("confirm") or text:find("close") or text:find("great")
                                    or text:find("open another") or text:find("wear it") or text:find("keep raiding") or text:find("keep knocking") or text:find("not now") or text:find("thank you")
                                    or labelText:find("done") or labelText:find("close") or labelText:find("accept") or labelText:find("okay")

                                if isRewardBtn then
                                    if firesignal then
                                        pcall(function() firesignal(desc.Activated) end)
                                        pcall(function() firesignal(desc.MouseButton1Click) end)
                                    end
                                    if getconnections then
                                        pcall(function()
                                            for _, c in ipairs(getconnections(desc.Activated)) do
                                                if c.Function then pcall(c.Function) end
                                            end
                                            for _, c in ipairs(getconnections(desc.MouseButton1Click)) do
                                                if c.Function then pcall(c.Function) end
                                            end
                                        end)
                                    end
                                    if vi and vi.SendMouseButtonEvent then
                                        pcall(function()
                                            local abs = desc.AbsolutePosition + (desc.AbsoluteSize * 0.5)
                                            vi:SendMouseButtonEvent(abs.X, abs.Y, 0, true, game, 1)
                                            task.wait(0.04)
                                            vi:SendMouseButtonEvent(abs.X, abs.Y, 0, false, game, 1)
                                        end)
                                    end
                                    dismissed = true
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    if dismissed and vi and vi.SendKeyEvent then
        pcall(function()
            vi:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
            task.wait(0.04)
            vi:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
        end)
    end

    return dismissed
end

function rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)
    if not force and rafting.autoDismissRewardGui == false and rafting.autoAcceptRewards == false then return end
    timeoutSecs = timeoutSecs or 8.0
    task.spawn(function()
        local startTime = os.clock()
        while (os.clock() - startTime) < timeoutSecs do
            if not force and rafting.autoDismissRewardGui == false and rafting.autoAcceptRewards == false then break end
            local dismissed = rafting.dismissChestRewardGui(force)
            if dismissed then
                task.wait(0.3)
                if not rafting.dismissChestRewardGui(force) then
                    break
                end
            end
            task.wait(0.15)
        end
    end)
end

local ProximityPromptService = game:GetService("ProximityPromptService")
if ProximityPromptService then
    pcall(function()
        ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
            if playerWhoTriggered == (plr or Players.LocalPlayer) and prompt then
                local promptName = ""
                local pName = ""
                local grandParentName = ""
                pcall(function()
                    promptName = prompt.Name:lower()
                    if prompt.Parent then
                        pName = prompt.Parent.Name:lower()
                        if prompt.Parent.Parent then
                            grandParentName = prompt.Parent.Parent.Name:lower()
                        end
                    end
                end)
                if promptName:find("chest") or pName:find("chest") or grandParentName:find("chest") or pName == "localteamchest" or grandParentName == "localteamchest" then
                    rafting.pollRewardGuiUntilDismissed(8.0)
                elseif promptName:find("knock") or promptName:find("door") or promptName:find("treat") or pName:find("door") or grandParentName:find("farmerhouse") then
                    if trickOrTreat and trickOrTreat.autoDismissRewardGui then
                        trickOrTreat.pollRewardGuiUntilDismissed(4.0)
                    end
                end
            end
        end)
    end)
end

task.spawn(function()
    local pg = nil
    pcall(function()
        pg = (plr or Players.LocalPlayer):WaitForChild("PlayerGui", 5)
    end)
    if pg then
        pg.ChildAdded:Connect(function(child)
            local childName = nil
            pcall(function() childName = child.Name end)
            if not childName then return end

            if rafting.autoDismissRewardGui and (childName == "RewardBoxReveal" or childName:find("Reveal") or childName:find("Reward")) then
                task.wait(0.2)
                rafting.dismissChestRewardGui()
            end
            if trickOrTreat and trickOrTreat.autoDismissRewardGui and (
                childName == "RewardBoxReveal"
                or childName:find("Reveal")
                or childName:find("Reward")
                or childName:find("Treat")
                or childName:find("Halloween")
                or childName:find("Candy")
            ) then
                task.wait(0.2)
                pcall(trickOrTreat.dismissRewardGui)
            end
        end)
    end
end)

function rafting.lootSingleSite(targetSite)
    if not root or not targetSite then return false end
    local landPos = targetSite.LandPos or Vector3.new((targetSite.MinX + targetSite.MaxX) * 0.5, targetSite.FloorY + 2.5, (targetSite.MinZ + targetSite.MaxZ) * 0.5)

    -- Request stream replication for distant / unrendered clearings
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp.RequestStreamAroundAsync then
            lp:RequestStreamAroundAsync(landPos, 5)
        end
    end)

    if rafting.naturalMode then
        -- Natural mode: debark and walk from raft deck onto shore landing
        naturalWalkTo(landPos, 8.0, 3.5)
    else
        -- Teleport onto landing ground: triggers client/server to spawn LocalTeamChest
        stopCharacterVelocity()
        root.CFrame = CFrame.new(landPos.X, landPos.Y + 1.5, landPos.Z)
        root.Anchored = true
        if humanoid then
            humanoid:Move(Vector3.zero, false)
            humanoid:MoveTo(root.Position)
        end
        task.wait(0.25)
        root.Anchored = false
    end
    -- Paced landing settle: allows server physics to register touchdown and stream TeamChestSnapshot
    task.wait(0.5)

    -- Poll for LocalTeamChest to spawn on ground
    local targetChest = nil
    local targetModel = nil
    local pollStart = os.clock()
    while (os.clock() - pollStart) < 4.0 do
        local localChest = workspace:FindFirstChild("LocalTeamChest", true)
        if localChest and localChest:IsA("Model") and not localChest:GetAttribute("Opened") then
            local chestPos = localChest:GetPivot().Position
            if (chestPos - landPos).Magnitude < 120 then
                targetChest = { Id = localChest.Name, CFrame = localChest:GetPivot(), Opened = false }
                targetModel = localChest
                break
            end
        end
        if rafting.teamChests and type(rafting.teamChests) == "table" then
            for _, chest in ipairs(rafting.teamChests) do
                if not chest.Opened and chest.Id ~= rafting.lastLootedChestId then
                    targetChest = chest
                    break
                end
            end
        end
        if targetChest then break end
        task.wait(0.12)
    end

    if targetChest and targetChest.CFrame then
        local approachPos = (targetChest.CFrame * CFrame.new(0, 1.5, 3.5)).Position
        if rafting.naturalMode then
            naturalWalkTo(approachPos, 8.0, 3.0)
        else
            local distToChest = (root.Position - approachPos).Magnitude
            local walkedToChest = false
            if distToChest <= 25 then
                walkedToChest = walkToPosition(approachPos, 2.0, 3.0)
            end
            if not walkedToChest then
                stopCharacterVelocity()
                root.CFrame = targetChest.CFrame * CFrame.new(0, 1.5, 3.5) * CFrame.Angles(0, math.pi, 0)
                if humanoid then
                    humanoid:Move(Vector3.zero, false)
                    humanoid:MoveTo(root.Position)
                end
            end
        end
        -- Paced chest settle: guarantees server receives character position packet inside 12-stud prompt radius before trigger
        task.wait(0.7)

        -- Hooked native trigger via ProximityPrompt from CowGameClient.Bootstrap
        local triggeredNatively = false
        if targetModel then
            triggeredNatively = triggerChestNatively(targetModel)
        else
            local foundModel = workspace:FindFirstChild("LocalTeamChest", true)
            if foundModel then
                triggeredNatively = triggerChestNatively(foundModel)
            end
        end

        if not triggeredNatively then
            local remotes = cowRemotes or (game:GetService("ReplicatedStorage"):FindFirstChild("CowGame") and game.ReplicatedStorage.CowGame:FindFirstChild("Remotes"))
            local teamChestReq = remotes and remotes:FindFirstChild("TeamChestRequest")
            if teamChestReq then
                pcall(function() teamChestReq:FireServer(targetChest.Id) end)
            end
        end

        rafting.lastLootedChestId = targetChest.Id
        targetChest.Opened = true
        task.wait(0.8) -- Wait for chest celebration / hat animation

        -- Automatically poll and dismiss Accept or Okay on teamchest reward GUI until dismissed
        rafting.pollRewardGuiUntilDismissed(8.0)
        task.wait(0.4)
    end

    rafting.lootedChestSites[targetSite.Id] = true
    rafting.visitedSites[targetSite.Id] = true
    return true
end

function rafting.sweepZoneChests(zoneNum, deck)
    if rafting.isLootingChest or not root or not zoneNum then return false end
    local curDeck = deck or rafting.getRaftDeck()
    if not curDeck then return false end
    local zoneList = zoneSites[zoneNum]
    if not zoneList then return false end

    local hasUnlooted = false
    for _, siteId in ipairs(zoneList) do
        if not rafting.lootedChestSites[siteId] then
            hasUnlooted = true
            break
        end
    end
    if not hasUnlooted then return false end

    rafting.isLootingChest = true
    task.spawn(function()
        for _, siteId in ipairs(zoneList) do
            local targetSite = rafting.sitesById[siteId] or (rafting.getClearingById and rafting.getClearingById(siteId))
            if not targetSite and rafting.allSites then
                for _, s in ipairs(rafting.allSites) do
                    if s.Id == siteId then targetSite = s break end
                end
            end
            if targetSite and not rafting.lootedChestSites[siteId] then
                rafting.statusText = string.format("Zone %d Sweep: Looting %s...", zoneNum, targetSite.Name or siteId)
                rafting.updateCards()
                rafting.lootSingleSite(targetSite)
                task.wait(0.4)
            end
        end

        local deckRef = rafting.getRaftDeck() or curDeck
        if deckRef and root then
            if rafting.naturalMode then
                rafting.statusText = "Boarding raft..."
                rafting.updateCards()
                naturalWalkTo(deckRef.Position, 8.0, 3.5)
                local cowRel = deckRef.CFrame:PointToObjectSpace(root.Position)
                if math.abs(cowRel.X) > 5.5 or math.abs(cowRel.Z) > 13.0 or cowRel.Y < -0.5 then
                    humanoid.Jump = true
                    naturalWalkTo(deckRef.Position, 3.0, 2.5)
                end
                task.wait(0.4)
                rafting.dismissChestRewardGui()
            else
                placeCowAboveDeck(deckRef)
                task.wait(0.4)
                rafting.dismissChestRewardGui()
            end
        end

        rafting.isLootingChest = false
    end)
    return true
end

function rafting.lootReachChests(dockSite, deck)
    if rafting.isLootingChest or not root or not dockSite then return end
    local curDeck = deck or rafting.getRaftDeck()
    if not curDeck then return end

    task.spawn(function()
        local zoneNum = siteZoneMap[dockSite.Id] or (dockSite.FjordLevel and math.clamp(dockSite.FjordLevel, 1, 4)) or 1

        if rafting.collectAllLootChests and not rafting.naturalMode then
            rafting.sweepZoneChests(zoneNum, curDeck)
            while rafting.isLootingChest do task.wait(0.2) end
        else
            -- Loot ONLY the clearing where the raft is physically docked
            if not rafting.lootedChestSites[dockSite.Id] then
                rafting.isLootingChest = true
                rafting.statusText = string.format("Looting %s...", dockSite.Name or dockSite.Id)
                rafting.updateCards()
                rafting.lootSingleSite(dockSite)
                task.wait(0.5)

                local deckRef = rafting.getRaftDeck() or curDeck
                if deckRef and root then
                    if rafting.naturalMode then
                        rafting.statusText = "Boarding raft..."
                        rafting.updateCards()
                        naturalWalkTo(deckRef.Position, 8.0, 3.5)
                    else
                        placeCowAboveDeck(deckRef)
                    end
                    task.wait(0.4)
                    rafting.dismissChestRewardGui()
                end
                rafting.isLootingChest = false
            end
        end

        rafting.isLootingChest = false

        -- Check emergency docked: if health low or adrift, return to shore now that chests are looted
        local snap = rafting.currentSnapshot
        local isEmergency = rafting.emergencyDocked
            or (snap and snap.Health and snap.Health <= rafting.emergencyReturnHp and snap.Health > 0)
            or (snap and snap.Adrift == true)

        if isEmergency then
            rafting.emergencyDocked = false
            rafting.statusText = string.format("Emergency docked at %s: chests looted! Returning to shore...", dockSite.Id or "Clearing")
            rafting.updateCards()
            Window:Notify({
                Title = "Rafting Emergency",
                Content = "Emergency docked: chests looted! Returning to shore...",
                Duration = 4
            })
            task.wait(0.6)
            rafting.endVoyage()
            return
        end

        -- Resume voyage
        if rafting.autoContinueFromDock or rafting.autoLoop then
            local waitSecs = rafting.dockMaxWaitSeconds or 4
            rafting.statusText = string.format("Docked at %s. Reach cleared! Resuming in %ds...", dockSite.Id, waitSecs)
            rafting.updateCards()
            task.delay(waitSecs, function()
                if rafting.enabled and rafting.status == "Docked" then
                    rafting.castOff()
                end
            end)
        else
            rafting.statusText = string.format("Docked at %s. All chests in reach looted! Click 'Sail Now' to resume.", dockSite.Id)
            rafting.updateCards()
        end
    end)
end

rafting.lootSiteChest = rafting.lootReachChests

function rafting.handleSnapshot(payload)
    if not payload or type(payload) ~= "table" then return end
    rafting.lastSnapshotTime = os.clock()

    -- Auto-rearm steering loop whenever enabled
    if rafting.enabled then
        if not rafting.heartbeatConn or not rafting.renderSteppedConn then
            rafting.startSteeringLoop()
        end
    end

    -- Detect new session
    if payload.Id and payload.Id ~= rafting.sessionId then
        rafting.sessionId = payload.Id
        rafting.visitedSites = {}
        rafting.lootedChestSites = {}
        rafting.isLootingChest = false
        rafting.incomingRocks = {}
        rafting.isDockedState = false
        rafting.currentDockSite = nil
        rafting.lastLootedSite = nil
        rafting.lastProgressPos = nil
        rafting.lastProgressX = nil
        rafting.lastProgressTime = 0
        rafting.stuckDuration = 0
        rafting.isUnsticking = false
        rafting.unstickDirection = 0
        if rafting.enabled then
            rafting.isSailing = true
            rafting.startSteeringLoop()
        end
    end

    rafting.currentSnapshot = payload

    -- Auto-castoff when Ready
    if payload.Status == "Ready" and rafting.enabled and not rafting.isSailing then
        rafting.status = "Ready"
        rafting.isSailing = true
        rafting.statusText = "Raft Ready! Casting off..."
        task.delay(0.6, function()
            if rafting.enabled and rafting.currentSnapshot and rafting.currentSnapshot.Status == "Ready" then
                rafting.castOff()
            end
        end)
    elseif payload.Status == "Departing" then
        rafting.status = "Departing"
        rafting.isSailing = true
        if rafting.enabled and (not rafting.heartbeatConn or not rafting.renderSteppedConn) then
            rafting.startSteeringLoop()
        end
        rafting.statusText = "Departing dock..."
    elseif payload.Status == "Travelling" and (rafting.status ~= "Docked" or (payload.Speed and payload.Speed > 8.0)) then
        rafting.status = "Travelling"
        rafting.isDockedState = false
        rafting.isSailing = true
        if rafting.enabled and (not rafting.heartbeatConn or not rafting.renderSteppedConn) then
            rafting.startSteeringLoop()
        end
        if not rafting.isEvadingRock then
            rafting.statusText = "Travelling down river..."
        end
    end

    -- Check for Clearing Arrival / Docking when on "Clearing & Chest Explorer" or server docked
    if rafting.enabled and payload.Frame and typeof(payload.Frame) == "CFrame" then
        local posX = payload.Frame.Position.X
        local posZ = payload.Frame.Position.Z
        local speed = payload.Speed or 0

        -- Auto-mark clearing as visited once past its downriver exit
        local sitesToScan = rafting.allSites or clearingSites
        for _, site in ipairs(sitesToScan) do
            if not rafting.visitedSites[site.Id] and rafting.status ~= "Docked" then
                local inCove = (site.BankSide == "North" and posZ <= (site.MaxZ + 10)) or (site.BankSide == "South" and posZ >= (site.MinZ - 10))
                if posX > (site.MaxX + 25) and not inCove then
                    rafting.visitedSites[site.Id] = true
                end
            end
        end

        -- Check if landing at an unvisited clearing or server reported Docked
        local isServerDocked = (payload.Status == "Docked")
        if isServerDocked and rafting.lastCastOffTime and (os.clock() - rafting.lastCastOffTime < 6.0) then
            isServerDocked = false
        end
        if isServerDocked then
            rafting.stuckDuration = 0
            rafting.isUnsticking = false
            rafting.unstickDirection = 0
            rafting.lastProgressPos = nil
            rafting.lastProgressX = nil
        end

        if rafting.status ~= "Docked" then
            local nextSite = rafting.getNextTargetClearing(posX, posZ)
            local site = (payload.SiteId and (rafting.sitesById[payload.SiteId] or rafting.getClearingById(payload.SiteId))) or rafting.getNearbyClearing(posX, posZ) or nextSite
            local isSelectedSite = (site and rafting.isSiteSelected(site)) or isServerDocked
            if (site or isServerDocked) and isSelectedSite and ((site and not rafting.visitedSites[site.Id]) or isServerDocked) then
                local mouthZ = (site and site.Mouth and site.Mouth.Z) or (site and site.ShoreZ) or -37.81
                local inCoveInterior = site and (
                    (site.BankSide == "North" and posZ <= (mouthZ + 10)) or
                    (site.BankSide == "South" and posZ >= (mouthZ - 10))
                )
                local inSiteX = site and posX >= (site.MinX - 35) and posX <= (site.MaxX + 35)
                local distToLand = site and site.LandPos and (Vector3.new(posX, 700.5, posZ) - site.LandPos).Magnitude or math.huge
                local distToMouth = site and site.Mouth and (Vector3.new(posX, 700.5, posZ) - site.Mouth).Magnitude or math.huge

                local reachedShore = isServerDocked
                if not reachedShore and site then
                    if rafting.naturalMode then
                        reachedShore = inCoveInterior and inSiteX and (
                            distToLand < 75
                            or (distToMouth < 60 and (speed or 20) <= 14.0)
                            or ((rafting.stuckDuration or 0) >= 0.5)
                        )
                    else
                        -- Non-natural mode: take advantage of server BeachSiteRange (45 studs) to dock reliably
                        reachedShore = (inSiteX and distToMouth <= 45.0)
                            or (inCoveInterior and inSiteX and distToLand < 75)
                            or (inSiteX and ((rafting.stuckDuration or 0) >= 0.5))
                    end
                end

                if reachedShore then
                    local siteId = (site and site.Id) or payload.SiteId or "Clearing_Dock"
                    rafting.visitedSites[siteId] = true
                    rafting.status = "Docked"
                    rafting.isDockedState = true
                    rafting.currentDockSite = siteId
                    rafting.lastDepartSite = siteId
                    rafting.isSailing = false

                    local hp = payload.Health or 100
                    if (hp <= rafting.emergencyReturnHp and hp > 0) or payload.Adrift then
                        rafting.emergencyDocked = true
                    end

                    -- Stop any active boost immediately
                    if rafting.isBoosting then
                        rafting.isBoosting = false
                        rafting.nextBoostAt = 0
                        local rem = rafting.getRemote()
                        if rem then pcall(function() rem:FireServer("BoostRelease") end) end
                    end

                    -- Stop any active steering & release all keys once
                    if VirtualInput and VirtualInput.SendKeyEvent then
                        pcall(function()
                            VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                            VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                        end)
                        rafting.lastSteerKey = nil
                    end
                    if humanoid then
                        pcall(function()
                            humanoid:Move(Vector3.zero, false)
                            if root then humanoid:MoveTo(root.Position) end
                            humanoid.AutoRotate = true
                        end)
                    end
                    if root then
                        pcall(function() root.Anchored = false end)
                    end
                    stopCharacterVelocity()

                    local curDeck = rafting.getRaftDeck()
                    if site and curDeck then
                        rafting.lootReachChests(site, curDeck)
                    elseif curDeck then
                        placeCowAboveDeck(curDeck)
                        if rafting.emergencyDocked then
                            rafting.emergencyDocked = false
                            safeNotify({ Title = "Rafting Emergency", Content = "Emergency dock: returning to shore...", Duration = 4 })
                            task.wait(0.6)
                            rafting.endVoyage()
                        end
                    end
                end
            end
        end

        -- Water recovery check: If character touches water or is away from deck, instantly return to deck (+5.5 studs hoof clearance)
        if rafting.status == "Docked" and root then
            local deck = rafting.getRaftDeck()
            if deck then
                local distFromDeck = (root.Position - deck.Position).Magnitude
                local inWater = (root.Position.Y < 700.5 and distFromDeck > 6.0) or (root.Position.Y < 698.0) or (humanoid and humanoid.FloorMaterial == Enum.Material.Water)
                if inWater then
                    placeCowAboveDeck(deck)
                end
            else
                rafting.teleportToRaftYard()
                rafting.onSessionEnded("Raft missing while docked. Returned to launch pad.")
            end
        end
    end

    rafting.updateCards()
end

function rafting.handleBoarding(payload)
    rafting.status = "Boarding"
    rafting.statusText = "Boarding raft (walking aboard)..."
    rafting.zone4Swept = false
    rafting.updateCards()
end

function rafting.stepSteering(dt)
    if not rafting.enabled or not rafting.isSailing then return end

    -- Immediate death check: stop automated rafting when dead
    if not humanoid or humanoid.Health <= 0 then
        rafting.onSessionEnded("Player died. Automated rafting stopped.")
        return
    end

    -- Snapshot timeout: if server stopped sending snapshots for > 4.0s, session ended or raft despawned
    if rafting.lastSnapshotTime and (os.clock() - rafting.lastSnapshotTime > 4.0) then
        rafting.onSessionEnded("Raft session ended (snapshots timed out).")
        return
    end

    local snap = rafting.currentSnapshot
    if not snap or (snap.Status ~= "Travelling" and snap.Status ~= "Departing") then return end
    if rafting.status == "Docked" or snap.Status == "Docked" then
        if humanoid then
            pcall(function()
                humanoid:Move(Vector3.zero, false)
                if root then humanoid:MoveTo(root.Position) end
            end)
        end
        return
    end

    local frame = snap.Frame
    if not frame or typeof(frame) ~= "CFrame" then return end

    local deck = rafting.getRaftDeck()
    if not deck then return end

    local posX = frame.Position.X
    local posZ = frame.Position.Z



    -- Terminus Zone 4 Sweep Failsafe: if approaching Sea without docking in Zone 4, sweep Zone 4 sites
    if not rafting.zone4Swept and posX >= 6350 and not rafting.naturalMode and rafting.collectAllLootChests and not rafting.isLootingChest and not (rafting.status == "Docked") and root then
        rafting.zone4Swept = true
        rafting.sweepZoneChests(4, deck)
    end

    -- Reached the Sea? (SeaStartX = 6594.58)
    if posX >= 6590 and not rafting.isEndingVoyage then
        rafting.isEndingVoyage = true
        rafting.isSailing = false
        rafting.status = "Idle"
        rafting.statusText = "Reached The Sea! Ending voyage..."
        rafting.updateCards()
        safeNotify({ Title = "Voyage Finished", Content = "Reached The Sea! Returning to shore.", Duration = 4 })
        task.spawn(rafting.endVoyage)
        return
    end

    -- Adaptive lookahead: use 50 studs in channels, but short 15 studs when approaching or inside cove
    -- so lookAheadX does not overshoot the cove into the downriver channel
    local lookAhead = 50
    local nextSite = rafting.getNextTargetClearing(posX, posZ)
    if nextSite and posX >= (nextSite.MinX - 100) and posX <= (nextSite.MaxX + 25) then
        lookAhead = 15
    end
    local lookAheadX = posX + lookAhead

    -- 1. Compute Whisker Clearances via Raycasts
    local clearances = rafting.getWhiskerClearances(deck)

    -- 2. Hybrid Target Z
    local targetZ = rafting.getTargetZ(lookAheadX, posZ, clearances)
    local errorZ = targetZ - posZ
    rafting.errorZ = errorZ

    -- 3. Flow Guidance Bias (-5.8 to +5.8 with smooth proportional ramp & deadband)
    local absErr = math.abs(errorZ)
    local flowBias = 0
    if absErr <= 1.8 then
        -- Stable deadband on straightaways: boat glides straight down channel centerline
        flowBias = 0
    elseif absErr <= 6.0 then
        local t = (absErr - 1.8) / 4.2
        local mag = 0.6 + t * 2.2
        flowBias = if errorZ > 0 then mag else -mag
    elseif absErr <= 14.0 then
        local t = (absErr - 6.0) / 8.0
        local mag = 2.8 + t * 2.4
        flowBias = if errorZ > 0 then mag else -mag
    else
        flowBias = if errorZ > 0 then 5.8 else -5.8
    end

    -- 4. Dynamic Whisker Wall Repulsion
    local whiskerRepulsion = 0
    local leftLateralDist = math.min(clearances.LeftLateral or 45, clearances.LeftStern or 40)
    local rightLateralDist = math.min(clearances.RightLateral or 45, clearances.RightStern or 40)
    local leftObliqueDist = math.min(clearances.ForwardLeft or 95, clearances.LeftOblique or 75)
    local rightObliqueDist = math.min(clearances.ForwardRight or 95, clearances.RightOblique or 75)
    local leftMinDist = math.min(leftLateralDist, leftObliqueDist)
    local rightMinDist = math.min(rightLateralDist, rightObliqueDist)
    local forwardDist = math.min(clearances.Forward or 110, clearances.ForwardLeft or 95, clearances.ForwardRight or 95)

    local minX = nextSite and nextSite.MinX or 0
    local maxX = nextSite and nextSite.MaxX or minX
    local mouthX = nextSite and nextSite.Mouth and nextSite.Mouth.X or ((minX + maxX) * 0.5)
    local mouthZ = nextSite and nextSite.Mouth and nextSite.Mouth.Z or (nextSite and nextSite.ShoreZ or -37.81)
    local shoreZ = nextSite and nextSite.ShoreZ or -37.81
    local isDeparting = (os.clock() - (rafting.lastCastOffTime or 0)) < 6.0

    -- True cove interior check (past the river bank line):
    local isInsideCoveInterior = false
    if nextSite and posX >= (minX - 10) and posX <= (maxX + 25) then
        if nextSite.BankSide == "North" and posZ <= (mouthZ - 15) then
            isInsideCoveInterior = true
        elseif nextSite.BankSide == "South" and posZ >= (mouthZ + 15) then
            isInsideCoveInterior = true
        end
    end

    local isHeadingToNorthCove = (not isDeparting) and nextSite and nextSite.BankSide == "North" and posX >= (mouthX - 160) and posX <= (maxX + 25)
    local isHeadingToSouthCove = (not isDeparting) and nextSite and nextSite.BankSide == "South" and posX >= (mouthX - 160) and posX <= (maxX + 25)

    -- Stand-Off Buffer: deck half-width is 7.0 studs.
    -- Begin repelling when wall is closer than 32 studs from center (25 studs from railing).
    -- Full lock repel when closer than 18 studs from center (11 studs from railing).
    if leftMinDist < 32.0 then
        local push = math.clamp((32.0 - leftMinDist) / 14.0, 0, 1)
        if leftMinDist < 16.0 or not isHeadingToNorthCove then
            whiskerRepulsion = whiskerRepulsion + (if leftMinDist < 14.0 then 5.8 else push * 5.8)
        end
    end
    if rightMinDist < 32.0 then
        local push = math.clamp((32.0 - rightMinDist) / 14.0, 0, 1)
        if rightMinDist < 16.0 or not isHeadingToSouthCove then
            whiskerRepulsion = whiskerRepulsion - (if rightMinDist < 14.0 then 5.8 else push * 5.8)
        end
    end

    -- Forward Facade & Divider Headwall Deflection (suppressed when actively tracking into a clearing cove)
    local isHeadingToCove = isHeadingToNorthCove or isHeadingToSouthCove
    if not isHeadingToCove then
        if forwardDist < 60.0 then
            local steerAway = 5.8
            if leftMinDist > rightMinDist + 2.0 then
                steerAway = -5.8
            elseif rightMinDist > leftMinDist + 2.0 then
                steerAway = 5.8
            else
                steerAway = if (errorZ < 0) then -5.8 else 5.8
            end
            whiskerRepulsion = steerAway
            rafting.statusText = "FACADE CRITICAL! Hard lock deflection..."
        elseif forwardDist < 85.0 then
            local pushT = (85.0 - forwardDist) / 25.0
            local steerSign = 1
            if leftMinDist > rightMinDist + 1.5 then
                steerSign = -1
            elseif rightMinDist > leftMinDist + 1.5 then
                steerSign = 1
            else
                steerSign = if (errorZ < 0) then -1 else 1
            end
            local forwardDeflection = steerSign * (2.5 + pushT * 3.3)
            if math.abs(forwardDeflection) > math.abs(whiskerRepulsion) then
                whiskerRepulsion = forwardDeflection
            end
            rafting.statusText = "FACADE AHEAD! Raycast whiskers early deflection..."
        elseif math.abs(whiskerRepulsion) > 1.0 then
            rafting.statusText = "WALL PROXIMITY! Raycast whiskers maintaining clearance..."
        end
    elseif math.abs(whiskerRepulsion) > 1.0 then
        rafting.statusText = "COVE APPROACH! Guiding into cove landing..."
    end

    -- Directional flow suppression: never allow flow bias to steer towards a detected wall
    if whiskerRepulsion > 0.5 and flowBias < 0 and not isHeadingToCove then
        flowBias = 0
    elseif whiskerRepulsion < -0.5 and flowBias > 0 and not isHeadingToCove then
        flowBias = 0
    end

    -- 5. Blend Flow Bias with Whisker Repulsion
    local targetDeckX = 0
    if isHeadingToNorthCove then
        -- Priority 1: Steer into North clearing cove along smooth curve while avoiding outer rock corner collisions
        if leftMinDist < 16.0 or (whiskerRepulsion > 1.8 and not isInsideCoveInterior) then
            targetDeckX = whiskerRepulsion
            rafting.statusText = "OBSTACLE NEAR COVE! Whiskers steering clear..."
        else
            targetDeckX = flowBias
            rafting.statusText = string.format("Approaching %s! Tracking cove entry curve...", nextSite.Id)
        end
    elseif isHeadingToSouthCove then
        -- Priority 1: Steer into South clearing cove along smooth curve while avoiding outer rock corner collisions
        if rightMinDist < 16.0 or (whiskerRepulsion < -1.8 and not isInsideCoveInterior) then
            targetDeckX = whiskerRepulsion
            rafting.statusText = "OBSTACLE NEAR COVE! Whiskers steering clear..."
        else
            targetDeckX = flowBias
            rafting.statusText = string.format("Approaching %s! Tracking cove entry curve...", nextSite.Id)
        end
    elseif forwardDist < 60.0 or leftMinDist < 20.0 or rightMinDist < 20.0 or math.abs(whiskerRepulsion) > 1.2 then
        -- Complete obstacle avoidance dominance: no dilution by flow bias
        targetDeckX = whiskerRepulsion
    else
        targetDeckX = flowBias
    end

    -- 5b. Wall Scraping / Contact Watchdog & Active Dislodge Maneuver
    local now = os.clock()
    local isScrapingLeft = (leftMinDist < 16.0)
    local isScrapingRight = (rightMinDist < 16.0)
    local isScrapingWall = isScrapingLeft or isScrapingRight

    if not rafting.lastProgressX then
        rafting.lastProgressX = posX
        rafting.lastProgressTime = now
        rafting.stuckDuration = 0
        rafting.isUnsticking = false
    else
        local timeSinceCheck = now - (rafting.lastProgressTime or now)
        if timeSinceCheck >= 0.4 then
            local dxMoved = posX - (rafting.lastProgressX or posX)
            -- River flows down +X. If dx < 1.5 studs over 0.4s while travelling, boat is stuck or wedged
            if (dxMoved < 1.5 or isScrapingWall) and (snap.Status == "Travelling" or snap.Status == "Departing") then
                rafting.stuckDuration = (rafting.stuckDuration or 0) + timeSinceCheck
            else
                rafting.stuckDuration = math.max(0, (rafting.stuckDuration or 0) - timeSinceCheck * 1.5)
                if rafting.isUnsticking and dxMoved >= 4.0 and not isScrapingWall and (not rafting.coveDislodgeUntil or now >= rafting.coveDislodgeUntil) then
                    rafting.isUnsticking = false
                    rafting.unstickDirection = 0
                end
            end
            rafting.lastProgressX = posX
            rafting.lastProgressTime = now
        end
    end

    -- Cove corner trap watchdog: if blocked attempting to enter a cove for >= 1.5s, abandon site & self-correct downriver
    local isApproachingCoveMouth = nextSite and posX >= (minX - 80) and posX <= (maxX + 25) and not isInsideCoveInterior
    local isCoveBlocked = isApproachingCoveMouth and (rafting.stuckDuration or 0) >= 1.5

    if isCoveBlocked then
        local blockedSiteId = nextSite.Id
        rafting.visitedSites[blockedSiteId] = true
        rafting.abandonedSiteId = blockedSiteId
        rafting.coveDislodgeUntil = now + 2.5
        rafting.coveDislodgeDir = if nextSite.BankSide == "North" then 5.8 else -5.8
        rafting.stuckDuration = 0
        rafting.isUnsticking = true
        rafting.unstickStartTime = now
        print(string.format("[Rafting] Cove corner blocked for >= 2.0s! Abandoning site %s, dislodging downstream...", blockedSiteId))
    end

    local isWallStuck = (rafting.stuckDuration or 0) >= 0.6
    local isActivelyDislodging = (rafting.coveDislodgeUntil and now < rafting.coveDislodgeUntil) or isWallStuck

    if rafting.coveDislodgeUntil and now < rafting.coveDislodgeUntil then
        targetDeckX = rafting.coveDislodgeDir or 5.8
        rafting.statusText = "DISLODGING FROM COVE CORNER! Pushing off bank..."
    elseif isWallStuck then
        if not rafting.isUnsticking then
            rafting.isUnsticking = true
            rafting.unstickStartTime = now
            -- Hard counter-steer away from contact side:
            if isScrapingLeft then
                rafting.unstickDirection = 5.8
            elseif isScrapingRight then
                rafting.unstickDirection = -5.8
            else
                local prevSteer = rafting.targetDeckX or 0
                rafting.unstickDirection = if (prevSteer <= 0) then 5.8 else -5.8
            end
        else
            -- Alternate counter-steer (wiggle) every 1.2s if still wedged
            local elapsed = now - (rafting.unstickStartTime or now)
            local cycle = math.floor(elapsed / 1.2) % 2
            if cycle == 1 then
                rafting.unstickDirection = if (rafting.unstickDirection > 0) then -5.8 else 5.8
            end
        end

        targetDeckX = rafting.unstickDirection
        rafting.statusText = string.format("WALL SCRAPING! Dislodging: hard counter-steer (%+.1f)...", targetDeckX)
    end

    -- 6. Check Hobgoblin Rock Threat (Prioritize landing at clearing over dodging)
    local evadeDeckX, shouldEvadeBoost, shouldEvadeJump = rafting.getHobgoblinEvasionOffset(deck, frame)
    if evadeDeckX ~= nil and not isActivelyDislodging then
        if isHeadingToNorthCove or (isInsideCoveInterior and nextSite and nextSite.BankSide == "North") then
            -- Landing at North clearing (cove is to the Left / -5.8)
            if evadeDeckX < 0 then
                targetDeckX = -5.8
                rafting.statusText = "DODGING TOWARDS CLEARING! Steering into North cove..."
            else
                targetDeckX = -5.8
                shouldEvadeJump = true
                rafting.statusText = "PRIORITIZING CLEARING DOCK! Holding course into cove..."
            end
        elseif isHeadingToSouthCove or (isInsideCoveInterior and nextSite and nextSite.BankSide == "South") then
            -- Landing at South clearing (cove is to the Right / +5.8)
            if evadeDeckX > 0 then
                targetDeckX = 5.8
                rafting.statusText = "DODGING TOWARDS CLEARING! Steering into South cove..."
            else
                targetDeckX = 5.8
                shouldEvadeJump = true
                rafting.statusText = "PRIORITIZING CLEARING DOCK! Holding course into cove..."
            end
        else
            -- Open river navigation
            local safeToEvade = true
            if forwardDist < 60.0 then
                safeToEvade = false
            elseif evadeDeckX < 0 and (leftMinDist < 32.0 or whiskerRepulsion > 0.5) then
                safeToEvade = false
            elseif evadeDeckX > 0 and (rightMinDist < 32.0 or whiskerRepulsion < -0.5) then
                safeToEvade = false
            end

            if safeToEvade then
                targetDeckX = evadeDeckX
                rafting.statusText = "DODGING HOBGOBLIN ROCK! Steering clear of impact..."
            else
                shouldEvadeJump = true
                rafting.statusText = "HOBGOBLIN THREAT! Wall near: cow jump evasion..."
            end
        end
    end

    rafting.targetDeckX = math.clamp(targetDeckX, -5.8, 5.8)

    -- Active Steering via Humanoid:MoveTo & Overboard Safety Check
    if root and char and humanoid and humanoid.Health > 0 then
        if shouldEvadeJump or isActivelyDislodging then
            humanoid.Jump = true
        end

        local cowPos = root.Position
        local cowRel = deck.CFrame:PointToObjectSpace(cowPos)
        local distFromDeck = (cowPos - deck.Position).Magnitude

        -- If character is separated from the raft (jumped off, thrown, or fell in water)
        if distFromDeck > 30.0 then
            if rafting.autoRecoverOverboard and deck and deck.Parent then
                placeCowAboveDeck(deck)
                local rem = rafting.getRemote()
                if rem then pcall(function() rem:FireServer("Boarded") end) end
                return
            else
                rafting.teleportToRaftYard()
                rafting.onSessionEnded("Character separated from raft. Returned to dock.")
                return
            end
        end

        -- Oriented Bounding Box Deck Check: Longboat is 14 wide (X: -7 to +7), 32 long (Z: -16 to +16).
        -- Deck top is at Y = 0.6; character root is at Y in [1.5, 5.0].
        local isOnDeck = math.abs(cowRel.X) <= 6.8 and math.abs(cowRel.Z) <= 16.2 and cowRel.Y >= -1.0

        if not isOnDeck and cowRel.Y < -2.0 and distFromDeck <= 25.0 then
            -- Character genuinely slipped off into water adjacent to boat: require sustained duration before recovery
            if not rafting.overboardStartTime then
                rafting.overboardStartTime = os.clock()
            elseif os.clock() - rafting.overboardStartTime > 0.35 then
                placeCowAboveDeck(deck)
                rafting.overboardStartTime = nil
                local rem = rafting.getRemote()
                if rem then pcall(function() rem:FireServer("Boarded") end) end
            end
        else
            rafting.overboardStartTime = nil

            -- Deck Railing Clamp: Never allow character center beyond +/- 6.2 on the deck (deck boundary is +/- 7.0)
            if math.abs(cowRel.X) > 6.2 then
                local clampedX = math.clamp(cowRel.X, -5.8, 5.8)
                root.CFrame = deck.CFrame * CFrame.new(clampedX, math.max(cowRel.Y, 3.45), cowRel.Z)
                stopCharacterVelocity()
            end

            humanoid.WalkSpeed = 24
            humanoid.AutoRotate = true
            local targetZOffset = if isActivelyDislodging then 7.0 else 0.0
            local targetWorldPos = deck.CFrame:PointToWorldSpace(Vector3.new(rafting.targetDeckX, 3.45, targetZOffset))
            humanoid:MoveTo(targetWorldPos)
        end
    end

    -- Auto-Boost on straightaways: strictly conserve stamina & suppress in cove or near facades
    local rem = rafting.getRemote()
    local rd = getReachData()
    local reachIdx = getReachIndex(posX)
    local forkX = rd and rd.forkX and rd.forkX[reachIdx]
    local approachingFork = forkX and (posX >= forkX - 160) and (posX <= forkX)
    local approachingCove = nextSite and posX >= (mouthX - 140) and posX <= (nextSite.MaxX + 25)
    local nearFacade = (forwardDist < 75.0) or (leftMinDist < 22.0) or (rightMinDist < 22.0)
    local suppressBoost = isInsideCoveInterior or approachingCove or approachingFork or nearFacade or isWallStuck or rafting.isUnsticking or isActivelyDislodging

    if rafting.autoBoost and not suppressBoost then
        local energy = snap.Energy or 0
        local maxEnergy = snap.MaxEnergy or 100
        local energyPct = (energy / math.max(maxEnergy, 1)) * 100
        local isStraight = (math.abs(errorZ) <= 8 and not snap.LowEnergy and (snap.Speed or 0) > 5)
        local minEnergyThreshold = math.max(rafting.minBoostStamina, 40)
        local shouldBoost = (energyPct >= minEnergyThreshold) and not snap.LowEnergy and isStraight

        if shouldBoost then
            if not rafting.isBoosting or os.clock() >= (rafting.nextBoostAt or 0) then
                rafting.isBoosting = true
                rafting.nextBoostAt = os.clock() + 0.25
                rafting.fireRemoteSafely("BoostHeld", nil, 0.2)
            end
        else
            if rafting.isBoosting then
                rafting.isBoosting = false
                rafting.nextBoostAt = 0
                rafting.fireRemoteSafely("BoostRelease", nil, 0.2)
            end
        end
    else
        if rafting.isBoosting then
            rafting.isBoosting = false
            rafting.nextBoostAt = 0
            rafting.fireRemoteSafely("BoostRelease", nil, 0.2)
        end
    end

    -- Auto-Repair split beams
    if rafting.autoRepair and (os.clock() - rafting.lastRepairTime >= 1.0) and snap.RepairStations then
        for _, station in ipairs(snap.RepairStations) do
            if station.Damaged then
                rafting.lastRepairTime = os.clock()
                local rem = rafting.getRemote()
                if rem and station.Id then
                    pcall(function() rem:FireServer("RepairRelease", station.Id) end)
                end
                break
            end
        end
    end

    -- Emergency Health Return (Debounced & Single-Trigger)
    local hp = snap.Health or 100
    if ((hp <= rafting.emergencyReturnHp and hp > 0) or snap.Adrift) and not rafting.isEndingVoyage then
        if rafting.status == "Docked" or rafting.isDockedState or rafting.isLootingChest then
            if not rafting.emergencyDocked then
                rafting.emergencyDocked = true
                rafting.statusText = "Emergency: low health / adrift while docked! Looting chests first..."
                rafting.updateCards()
            end
            return
        end

        rafting.isEndingVoyage = true
        rafting.isSailing = false
        rafting.status = "Idle"
        rafting.statusText = "Emergency return to shore (low health / adrift)..."
        rafting.updateCards()
        Window:Notify({ Title = "Rafting Emergency", Content = "Low health or adrift! Returning to shore...", Duration = 4 })
        task.spawn(rafting.endVoyage)
        return
    end
end

function rafting.stepSteeringAnimation(dt)
    if not rafting.enabled or not rafting.isSailing then return end
    if not humanoid or humanoid.Health <= 0 then return end
    local snap = rafting.currentSnapshot
    if not snap or (snap.Status ~= "Travelling" and snap.Status ~= "Departing") then return end
    if rafting.status == "Docked" or snap.Status == "Docked" then return end

    local deck = rafting.getRaftDeck()
    if not deck then return end

    local targetDeckX = math.clamp(rafting.targetDeckX or 0, -5.8, 5.8)

    -- 1. Humanoid Walk Direction: focus purely on lateral displacement (X on deck) to railing
    if root and char and humanoid and humanoid.Health > 0 then
        local distFromDeck = (root.Position - deck.Position).Magnitude
        if distFromDeck <= 16 then
            local cowRel = deck.CFrame:PointToObjectSpace(root.Position)
            local deltaX = targetDeckX - cowRel.X
            if math.abs(deltaX) > 0.35 then
                if humanoid.WalkSpeed < 24 then
                    humanoid.WalkSpeed = 24
                end
                local localMove = Vector3.new(deltaX, 0, 0)
                local worldMove = deck.CFrame:VectorToWorldSpace(localMove)
                humanoid:Move(Vector3.new(worldMove.X, 0, worldMove.Z).Unit, false)
            else
                humanoid:Move(Vector3.zero, false)
            end
        end
    end

    -- 2. VirtualInput Key Safety: Ensure steering keys never remain stuck down
    if VirtualInput and VirtualInput.SendKeyEvent and rafting.lastSteerKey then
        pcall(function()
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)
        end)
        rafting.lastSteerKey = nil
    end
end

function rafting.getLaunchTarget()
    local fjord = workspace:FindFirstChild("FjordRafting") or (workspace:FindFirstChild("CowWorld") and workspace.CowWorld:FindFirstChild("FjordRafting"))
    if fjord then
        local construct = fjord:FindFirstChild("ConstructionLaunch")
        if construct and construct:IsA("BasePart") then
            local prompt = construct:FindFirstChildWhichIsA("ProximityPrompt")
            return construct, prompt, construct.CFrame * CFrame.new(0, 3.5, 0)
        end
        local launch = fjord:FindFirstChild("Launch")
        if launch and launch:IsA("BasePart") then
            local prompt = launch:FindFirstChildWhichIsA("ProximityPrompt")
            return launch, prompt, launch.CFrame * CFrame.new(0, 3.5, 0)
        end
    end
    return nil, nil, CFrame.new(-240.12, 705.5, 12.35)
end

function rafting.startVoyage()
    local rem = rafting.getRemote()
    if not rem then
        Window:Notify({ Title = "Error", Content = "RaftingRequest remote not found.", Duration = 4 })
        return
    end

    local part, prompt, targetCF = rafting.getLaunchTarget()

    -- Enforce Launch Distance Check: walk naturally to the Launch prompt in all modes
    if root then
        local launchPos = part and part.Position or Vector3.new(-240.12, 703.99, 12.35)
        local dist = (root.Position - launchPos).Magnitude
        if dist > 5.0 then
            if dist <= 250 then
                rafting.statusText = "Walking to Harbour launch..."
                rafting.updateCards()
                naturalWalkTo(launchPos, 15.0, 4.0)
            else
                stopCharacterVelocity()
                root.CFrame = (targetCF or CFrame.new(-240.12, 705.5, 12.35)) * CFrame.new(0, 0, 20)
                task.wait(0.2)
                naturalWalkTo(launchPos, 8.0, 4.0)
            end
        end
        -- Face the launch prompt / part naturally
        stopCharacterVelocity()
        local lookTarget = Vector3.new(launchPos.X, root.Position.Y, launchPos.Z)
        root.CFrame = CFrame.new(root.Position, lookTarget)
        task.wait(0.4)
    end

    -- 1. Fire server from the dock to create/start voyage session (N and H do not work until on deck)
    rafting.fireRemoteSafely("Start", nil, 1.0)
    if prompt and prompt.Enabled then
        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
        end
        if getconnections then
            local conns = getconnections(prompt.Triggered)
            if conns and #conns > 0 then
                for _, c in ipairs(conns) do
                    if c.Function then pcall(c.Function) end
                end
            end
        end
    end

    rafting.enabled = true
    rafting.sessionId = nil
    rafting.deckPart = nil
    rafting.raftModel = nil
    rafting.isCastingOff = false
    rafting.lastCastOffTime = nil
    rafting.visitedSites = {}
    rafting.isDockedState = false
    rafting.currentDockSite = nil
    rafting.incomingRocks = {}
    rafting.isEvadingRock = false
    rafting.lastLootedSite = nil
    rafting.currentSnapshot = nil
    rafting.targetDeckX = 0
    rafting.lastProgressPos = nil
    rafting.lastProgressX = nil
    rafting.lastProgressTime = 0
    rafting.stuckDuration = 0
    rafting.isUnsticking = false
    rafting.unstickDirection = 0
    rafting.unstickStartTime = 0
    rafting.isSelfCorrecting = false
    rafting.abandonedSiteId = nil
    rafting.coveDislodgeUntil = nil
    rafting.isEndingVoyage = false
    rafting.isEndingVoyageInProgress = false
    rafting.emergencyDocked = false
    rafting.initClientListener()
    rafting.startSteeringLoop()
    rafting.statusText = "Boarding raft at Harbour berth..."
    rafting.isSailing = false
    if root then pcall(function() root.Anchored = false end) end
    rafting.updateCards()

    -- 2. Boarding & Departure Sequence: wait for boarding animation to end before pressing N
    task.spawn(function()
        -- Wait for raft deck instance to stream in
        local deck = nil
        local waitDeckStart = os.clock()
        while (os.clock() - waitDeckStart) < 8.0 and rafting.enabled do
            deck = rafting.getRaftDeck()
            if deck then break end
            task.wait(0.25)
        end

        -- Let native boarding animation/cutscene play naturally without interference!
        rafting.statusText = "Boarding cutscene playing..."
        rafting.updateCards()

        -- Brief initial delay to ensure cutscene starts and attributes/HUD mount
        task.wait(0.6)

        local animWaitStart = os.clock()
        while (os.clock() - animWaitStart) < 12.0 and rafting.enabled do
            local snap = rafting.currentSnapshot
            if snap and (snap.Status == "Travelling" or (snap.Speed and snap.Speed > 5)) then
                break
            end

            -- If Continue button is already visible and active, animation has 100% finished!
            if isContinueButtonActive() then
                break
            end

            -- Check if boarding animation or cutscene attributes are still active
            if not isBoardingAnimationActive() and (os.clock() - animWaitStart) > 2.5 then
                -- Animation has stopped and minimum buffer has elapsed
                break
            end

            task.wait(0.25)
        end

        -- Confirm cow is physically in bounds and on/above the deck now that animation finished
        local currentDeck = rafting.getRaftDeck() or deck
        local onDeck = isCowOnDeck(currentDeck)
        if not onDeck then
            onDeck = ensureCowOnDeck(currentDeck, 4.0)
        end

        if onDeck then
            Window:Notify({ Title = "Rafting Started", Content = "Boarding complete. Activating Key N / Harbour departure...", Duration = 3 })
            task.wait(0.4) -- Allow RaftingController to register deck contact and bind Key N
        else
            rafting.statusText = "Boarding raft deck..."
            rafting.updateCards()
        end

        local waitStart = os.clock()
        while (os.clock() - waitStart) < 25.0 and rafting.enabled do
            local snap = rafting.currentSnapshot
            if snap and (snap.Status == "Travelling" or (snap.Speed and snap.Speed > 5)) then
                rafting.status = "Travelling"
                rafting.isSailing = true
                rafting.statusText = "Voyage underway! Steering engaged..."
                rafting.updateCards()
                break
            end

            currentDeck = rafting.getRaftDeck() or deck
            if currentDeck and root then
                if isCowOnDeck(currentDeck) then
                    -- ONLY pulse Key N & Continue button when verified on deck in bounds and animation finished!
                    sendRaftKey(Enum.KeyCode.N, 0.25)
                    triggerRaftingCommand("Continue")
                else
                    -- Player is off-deck or separated: re-board first, DO NOT press N while off deck
                    ensureCowOnDeck(currentDeck, 2.0)
                end
            end

            -- Single debounced fallback after 5.0 seconds without moving
            if (os.clock() - waitStart) > 5.0 then
                rafting.fireRemoteSafely("Sail", nil, 2.0)
                rafting.fireRemoteSafely("Vote", nil, 2.0)
            end

            task.wait(1.5)
        end
    end)
end

function rafting.onSessionEnded(reason)
    rafting.isSailing = false
    rafting.isEndingVoyage = false
    rafting.isEndingVoyageInProgress = false
    rafting.emergencyDocked = false
    rafting.currentSnapshot = nil
    rafting.status = "Idle"
    rafting.visitedSites = {}
    rafting.isDockedState = false
    rafting.currentDockSite = nil
    rafting.incomingRocks = {}
    rafting.isEvadingRock = false
    rafting.targetDeckX = 0
    rafting.lastSnapshotTime = nil
    rafting.lastProgressPos = nil
    rafting.lastProgressX = nil
    rafting.lastProgressTime = 0
    rafting.stuckDuration = 0
    rafting.isUnsticking = false
    rafting.unstickDirection = 0
    rafting.unstickStartTime = 0
    rafting.isSelfCorrecting = false
    rafting.abandonedSiteId = nil
    rafting.coveDislodgeUntil = nil
    local oldDeck = rafting.deckPart
    rafting.deckPart = nil
    rafting.raftModel = nil
    if not (rafting.autoLoop and rafting.enabled) then
        rafting.stopSteeringLoop()
    end

    -- River rescue failsafe: ensure player is never abandoned in river water
    task.spawn(function()
        task.wait(0.5)
        if root then
            local rPos = root.Position
            local inRiver = (rPos.X > 50) or (rPos.Y < 703.0) or (humanoid and humanoid.FloorMaterial == Enum.Material.Water)
            if inRiver then
                local deck = rafting.getRaftDeck() or oldDeck
                if deck and deck.Parent and (root.Position - deck.Position).Magnitude <= 35.0 then
                    placeCowAboveDeck(deck)
                    safeNotify({ Title = "Rafting Recovered", Content = "Returned safely to boat deck.", Duration = 3 })
                else
                    rafting.teleportToRaftYard()
                    safeNotify({ Title = "River Failsafe", Content = "Rescued from river! Returned to dock.", Duration = 3 })
                    if rafting.autoLoop and rafting.enabled then
                        task.wait(2)
                        rafting.startVoyage()
                    end
                end
            end
        end
    end)

    if reason then
        rafting.statusText = reason
        local now = os.clock()
        if (now - (rafting.lastSessionEndNotify or 0)) > 3.0 then
            rafting.lastSessionEndNotify = now
            safeNotify({ Title = "Rafting Stopped", Content = reason, Duration = 4 })
        end
    else
        rafting.statusText = "Rafting session ended."
    end
    rafting.updateCards()
end

function rafting.endVoyage()
    if rafting.isEndingVoyageInProgress then return end
    rafting.isEndingVoyageInProgress = true
    rafting.isEndingVoyage = true
    rafting.isSailing = false
    rafting.status = "Idle"

    sendRaftKey(Enum.KeyCode.H, 0.25)
    triggerRaftingCommand("Return")
    task.wait(0.2)
    rafting.fireRemoteSafely("Return", nil, 1.0)
    rafting.onSessionEnded("Voyage ended. Returned to shore.")

    -- Immediate failsafe: guarantee teleport back to launch pad within 1.0s if still in water
    task.delay(1.0, function()
        if root then
            local rPos = root.Position
            if rPos.X > 50 or rPos.Y < 703.0 or (humanoid and humanoid.FloorMaterial == Enum.Material.Water) then
                rafting.teleportToRaftYard()
            end
        end
    end)

    if rafting.autoLoop and rafting.enabled then
        task.delay(4, function()
            if rafting.autoLoop and rafting.enabled then
                rafting.teleportToRaftYard()
                task.wait(2)
                rafting.startVoyage()
            end
        end)
    end
end

function rafting.teleportToRaftYard()
    if root and char then
        stopCharacterVelocity()
        local part, prompt, targetCF = rafting.getLaunchTarget()
        root.CFrame = targetCF or CFrame.new(-240.12, 705.5, 12.35)
        safeNotify({ Title = "Teleported", Content = "Teleported to Fjord Raft Launch Pad.", Duration = 3 })
    end
end

function rafting.teleportToDeck()
    local deck = rafting.getRaftDeck()
    if root and deck then
        placeCowAboveDeck(deck)
        safeNotify({ Title = "Teleported", Content = "Placed safely ~3 studs above raft deck.", Duration = 3 })
    else
        safeNotify({ Title = "Teleport Failed", Content = "Raft deck not found.", Duration = 3 })
    end
end

function rafting.initClientListener()
    if rafting.clientEventConn then return end
    local clientEvent = cowRemotes and cowRemotes:FindFirstChild("ClientEvent")
    if not clientEvent then
        pcall(function()
            local cg = game:GetService("ReplicatedStorage"):WaitForChild("CowGame", 2)
            local rem = cg and cg:WaitForChild("Remotes", 2)
            clientEvent = rem and rem:FindFirstChild("ClientEvent")
        end)
    end
    if clientEvent then
        rafting.clientEventConn = clientEvent.OnClientEvent:Connect(function(eventName, payload)
            if eventName == "RaftingSnapshot" then
                rafting.handleSnapshot(payload)
            elseif eventName == "RaftingBoard" then
                rafting.handleBoarding(payload)
            elseif eventName == "RaftingEnded" then
                rafting.onSessionEnded("Rafting session ended on server.")
            elseif eventName == "RaftingSinking" then
                rafting.onSessionEnded("Raft sank! Session ended.")
            elseif eventName == "HobgoblinRock" then
                rafting.handleHobgoblinRock(payload)
            elseif eventName == "HobgoblinLanded" then
                rafting.handleHobgoblinLanded(payload)
            elseif eventName == "TeamChestSnapshot" then
                if payload and payload.Chests then
                    rafting.teamChests = payload.Chests
                    rafting.teamChestSite = payload.SiteId
                end
            elseif eventName == "TeamChestClear" then
                rafting.teamChests = nil
                rafting.teamChestSite = nil
            elseif eventName == "RaftingNotice" or eventName == "WeatherEvent" or eventName == "RiverHazard" or eventName == "HazardWarning" then
                if payload and typeof(payload.Text) == "string" then
                    if string.find(payload.Text, "Hobgoblin") then
                        rafting.statusText = "Hobgoblins spotted on cliffs! Evasion armed."
                    else
                        rafting.statusText = "Weather / river threat detected! Evasion armed."
                    end
                    rafting.updateCards()
                end
            end
        end)
        table.insert(rafting.connections, rafting.clientEventConn)
    end
end

function rafting.startSteeringLoop()
    if rafting.heartbeatConn or rafting.renderSteppedConn then return end
    rafting.lastStepTime = os.clock()

    if humanoid then
        if rafting.diedConn then pcall(function() rafting.diedConn:Disconnect() end) end
        rafting.diedConn = humanoid.Died:Connect(function()
            rafting.onSessionEnded("Player died. Automated rafting stopped.")
        end)
        table.insert(rafting.connections, rafting.diedConn)
    end

    rafting.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        if rafting.enabled then
            pcall(rafting.stepSteering, dt)
        end
    end)
    table.insert(rafting.connections, rafting.heartbeatConn)

    rafting.renderSteppedConn = RunService.RenderStepped:Connect(function(dt)
        if rafting.enabled then
            pcall(rafting.stepSteeringAnimation, dt)
        end
    end)
    table.insert(rafting.connections, rafting.renderSteppedConn)
end

function rafting.stopSteeringLoop()
    if rafting.diedConn then
        pcall(function() rafting.diedConn:Disconnect() end)
        rafting.diedConn = nil
    end
    if rafting.isBoosting then
        rafting.isBoosting = false
        rafting.nextBoostAt = 0
        local rem = rafting.getRemote()
        if rem then pcall(function() rem:FireServer("BoostRelease") end) end
    end
    if VirtualInput and VirtualInput.SendKeyEvent then
        pcall(function()
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)
        end)
        rafting.lastSteerKey = nil
    end
    if rafting.heartbeatConn then
        pcall(function() rafting.heartbeatConn:Disconnect() end)
        rafting.heartbeatConn = nil
    end
    if rafting.renderSteppedConn then
        pcall(function() rafting.renderSteppedConn:Disconnect() end)
        rafting.renderSteppedConn = nil
    end
    if root then pcall(function() root.Anchored = false end) end
    if humanoid then
        pcall(function()
            humanoid:Move(Vector3.zero, false)
            humanoid.AutoRotate = true
        end)
    end
end

function rafting.cleanup()
    rafting.enabled = false
    rafting.autoLoop = false
    rafting.visitedSites = {}
    rafting.isDockedState = false
    rafting.currentDockSite = nil
    rafting.teamChests = nil
    rafting.teamChestSite = nil
    rafting.lastLootedChestId = nil
    rafting.isCastingOff = false
    rafting.incomingRocks = {}
    rafting.isEvadingRock = false
    rafting.stopSteeringLoop()
    if root then pcall(function() root.Anchored = false end) end
    if humanoid then
        pcall(function()
            humanoid:Move(Vector3.zero, false)
            humanoid.AutoRotate = true
        end)
    end
    for _, conn in ipairs(rafting.connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(rafting.connections)
    rafting.clientEventConn = nil
    rafting.heartbeatConn = nil
    rafting.renderSteppedConn = nil
    rafting.currentSnapshot = nil
    rafting.deckPart = nil
    rafting.raftModel = nil
end

-- ==========================
-- UI SETUP: Fjord Rafting Tab
-- ==========================
local RaftingTab = Window:CreateTab({ Name = "Fjord Rafting", Icon = 4483362458 })

RaftingTab:CreateSection({ Name = "Live Voyage Telemetry" })

local initialRaftStatusTitle = "Fjord Rafting: Idle at Raft Yard"
local initialRaftStatusBody = "Rafting inactive. Click 'Start Rafting Voyage' to begin."
if RaftingTab.CreateText then
    pcall(function()
        rafting.statusCard = RaftingTab:CreateText({
            name = initialRaftStatusTitle,
            text = initialRaftStatusBody
        })
    end)
end
if not rafting.statusCard and RaftingTab.CreateParagraph then
    pcall(function()
        rafting.statusCard = RaftingTab:CreateParagraph({
            Title = initialRaftStatusTitle,
            Content = initialRaftStatusBody
        })
    end)
end

local initialTelemTitle = "Raft Telemetry | HP: --/-- | Energy: --/--"
local initialTelemBody = "Speed: 0.0 kts | Steering: 0.00 | Pos: N/A\nReach: Harbour | Boosting: false | Adrift: false"
if RaftingTab.CreateText then
    pcall(function()
        rafting.telemetryCard = RaftingTab:CreateText({
            name = initialTelemTitle,
            text = initialTelemBody
        })
    end)
end
if not rafting.telemetryCard and RaftingTab.CreateParagraph then
    pcall(function()
        rafting.telemetryCard = RaftingTab:CreateParagraph({
            Title = initialTelemTitle,
            Content = initialTelemBody
        })
    end)
end

RaftingTab:CreateSection({ Name = "Session Controls" })

RaftingTab:CreateToggle({
    Name = "Enable Automated Rafting",
    CurrentValue = false,
    Flag = "Toggle_Rafting_Enabled",
    Callback = function(Value)
        rafting.enabled = Value
        if Value then
            rafting.initClientListener()
            rafting.startSteeringLoop()
            Window:Notify({ Title = "Rafting Auto-Pilot", Content = "Auto-Pilot enabled. Raft will steer along the selected route.", Duration = 3 })
        else
            rafting.stopSteeringLoop()
        end
        rafting.updateCards()
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Loop Voyages (Repeat Runs)",
    CurrentValue = false,
    Flag = "Toggle_Rafting_AutoLoop",
    Callback = function(Value)
        rafting.autoLoop = Value
    end,
})

RaftingTab:CreateButton({
    Name = "Start Rafting Voyage",
    Callback = function()
        rafting.startVoyage()
    end,
})

RaftingTab:CreateButton({
    Name = "Sail Now / Cast Off",
    Callback = function()
        rafting.castOff()
        Window:Notify({ Title = "Sailing", Content = "Cast off signal sent!", Duration = 3 })
    end,
})

RaftingTab:CreateButton({
    Name = "Return to Shore / Dock",
    Callback = function()
        rafting.endVoyage()
    end,
})

RaftingTab:CreateButton({
    Name = "Teleport to Raft Yard Dock",
    Callback = function()
        rafting.teleportToRaftYard()
    end,
})

RaftingTab:CreateButton({
    Name = "Teleport Above Raft Deck",
    Callback = function()
        rafting.teleportToDeck()
    end,
})

RaftingTab:CreateSection({ Name = "Route Navigation Settings" })

RaftingTab:CreateDropdown({
    Name = "Rafting Route Profile",
    Options = {
        "Leftmost Clearings & Caves (Far-North / Left-Left-Forward)",
        "Hybrid Dynamic Explorer (Custom Selection)",
        "Clearing & Chest Explorer (All Clearings)",
        "North Channels (Caves & Drops)",
        "South Channels (Scenic & Clearings)",
        "Fast Sea Run (Center/Direct)"
    },
    CurrentOption = {"Hybrid Dynamic Explorer (Custom Selection)"},
    Flag = "Dropdown_Rafting_Route",
    Callback = function(Option)
        local chosen = type(Option) == "table" and Option[1] or Option
        rafting.route = chosen or "Hybrid Dynamic Explorer (Custom Selection)"
        rafting.updateCards()
    end,
})

RaftingTab:CreateSection({ Name = "Target Sites Selection by Level & River Bank" })

RaftingTab:CreateDropdown({
    Name = "Zone 1: Level 1 & 2 Sites (Upper Fjord - Reach 1)",
    Options = {
        "[Left] Clearing 01 (Level 1, North Bank)",
        "[Left] Cubby 01 Cave (Level 2, North Bank)",
        "[Right] Cubby 02 Cave (Level 1, South Bank)",
        "[Right] Clearing 02 (Level 2, South Bank)"
    },
    CurrentOption = {
        "[Right] Clearing 02 (Level 2, South Bank)"
    },
    MultipleOptions = true,
    Flag = "Dropdown_Rafting_Zone1",
    Callback = function(Options)
        rafting.updateZoneSites(1, Options)
    end,
})

RaftingTab:CreateDropdown({
    Name = "Zone 2: Level 3 Sites (Mid-Fjord Canyon - Reach 3)",
    Options = {
        "[Left] Clearing 03 (Level 3, North Bank)",
        "[Center] Cubby 03 Cave (Level 3, Center/South Bank)",
        "[Right] Clearing 04 (Level 3, South Bank)"
    },
    CurrentOption = {
        "[Left] Clearing 03 (Level 3, North Bank)",
        "[Right] Clearing 04 (Level 3, South Bank)"
    },
    MultipleOptions = true,
    Flag = "Dropdown_Rafting_Zone2",
    Callback = function(Options)
        rafting.updateZoneSites(2, Options)
    end,
})

RaftingTab:CreateDropdown({
    Name = "Zone 3: Level 4 Delta Sites (Lower Fjord - Reach 5)",
    Options = {
        "[Far-Left] Clearing 05 (Level 4, North 1 Channel)",
        "[Left] Cubby 04 Cave (Level 4, North 2 Channel)",
        "[Mid-Left] Clearing 06 (Level 4, North-Center Channel)",
        "[Mid-Right] Clearing 07 (Level 4, South-Center Channel)",
        "[Far-Right] Clearing 08 (Level 4, South 1 Channel)"
    },
    CurrentOption = {
        "[Far-Left] Clearing 05 (Level 4, North 1 Channel)",
        "[Mid-Left] Clearing 06 (Level 4, North-Center Channel)",
        "[Mid-Right] Clearing 07 (Level 4, South-Center Channel)",
        "[Far-Right] Clearing 08 (Level 4, South 1 Channel)"
    },
    MultipleOptions = true,
    Flag = "Dropdown_Rafting_Zone3",
    Callback = function(Options)
        rafting.updateZoneSites(3, Options)
    end,
})

RaftingTab:CreateDropdown({
    Name = "Zone 4: Level 4 Terminus Sites (Delta Terminus - Reach 7 & Caves)",
    Options = {
        "[Left] Cubby 05 Cave (Level 4, North 1 Channel)",
        "[Mid-Left] Clearing 09 (Level 4, North 2 Channel)",
        "[Mid-Left] Clearing 10 (Level 4, North 2 Channel)",
        "[Mid-Right] Cave 11 (Level 4, South 2 Channel)",
        "[Far-Right] Cave 12 (Level 4, South Terminus)"
    },
    CurrentOption = {
        "[Mid-Left] Clearing 09 (Level 4, North 2 Channel)",
        "[Mid-Left] Clearing 10 (Level 4, North 2 Channel)"
    },
    MultipleOptions = true,
    Flag = "Dropdown_Rafting_Zone4",
    Callback = function(Options)
        rafting.updateZoneSites(4, Options)
    end,
})

RaftingTab:CreateButton({
    Name = "Select All Sites (All 4 Zones)",
    Callback = function()
        rafting.selectAllSites = true
        rafting.selectAllClearings = false
        if rafting.allSites then
            local combined = {}
            for _, s in ipairs(rafting.allSites) do
                combined[s.Id] = true
            end
            rafting.selectedClearings = combined
        end
        rafting.updateCards()
    end,
})

RaftingTab:CreateButton({
    Name = "Clear All Sites (All 4 Zones)",
    Callback = function()
        rafting.selectAllSites = false
        rafting.selectAllClearings = false
        rafting.selectedClearings = {}
        rafting.selectedByZone = { [1] = {}, [2] = {}, [3] = {}, [4] = {} }
        rafting.updateCards()
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Dismiss Chest Reward GUI (Accept / Okay)",
    CurrentValue = true,
    Flag = "Toggle_Rafting_DismissChestRewardGui",
    Callback = function(Value)
        rafting.autoDismissRewardGui = Value
        rafting.autoAcceptRewards = Value
    end,
})

RaftingTab:CreateButton({
    Name = "Dismiss Reward GUI Now",
    Callback = function()
        local didDismiss = rafting.dismissChestRewardGui(true)
        if didDismiss then
            Window:Notify({ Title = "Chest GUI", Content = "Dismissed reward popup.", Duration = 2 })
        else
            Window:Notify({ Title = "Chest GUI", Content = "No active reward popup found.", Duration = 2 })
        end
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Continue After Docking & Chest",
    CurrentValue = true,
    Flag = "Toggle_Rafting_AutoContinue",
    Callback = function(Value)
        rafting.autoContinueFromDock = Value
    end,
})

RaftingTab:CreateToggle({
    Name = "Collect All Loot Chests (Clearings & Caves)",
    CurrentValue = true,
    Flag = "Toggle_Rafting_CollectAllLootChests",
    Callback = function(Value)
        rafting.collectAllLootChests = Value
        rafting.updateCards()
    end,
})

RaftingTab:CreateSection({ Name = "Automation & Safety" })

RaftingTab:CreateToggle({
    Name = "Natural Mode (Walk & Pathfind, No Teleports)",
    CurrentValue = false,
    Flag = "Toggle_Rafting_NaturalMode",
    Callback = function(Value)
        rafting.naturalMode = Value
        rafting.updateCards()
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Recover Overboard / Separated",
    CurrentValue = true,
    Flag = "Toggle_Rafting_AutoRecoverOverboard",
    Callback = function(Value)
        rafting.autoRecoverOverboard = Value
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Boost (Sprint on Straights)",
    CurrentValue = true,
    Flag = "Toggle_Rafting_AutoBoost",
    Callback = function(Value)
        rafting.autoBoost = Value
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Evade Threats & Weather",
    CurrentValue = true,
    Flag = "Toggle_Rafting_AutoEvadeHobgoblins",
    Callback = function(Value)
        rafting.autoEvadeHobgoblins = Value
    end,
})

RaftingTab:CreateSlider({
    Name = "Min Stamina to Boost (%)",
    Range = {10, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = rafting.minBoostStamina,
    Flag = "Slider_Rafting_MinBoostStamina",
    Callback = function(Value)
        rafting.minBoostStamina = Value
    end,
})

RaftingTab:CreateToggle({
    Name = "Auto-Repair Split Beams",
    CurrentValue = true,
    Flag = "Toggle_Rafting_AutoRepair",
    Callback = function(Value)
        rafting.autoRepair = Value
    end,
})

RaftingTab:CreateSlider({
    Name = "Emergency Return Health",
    Range = {10, 80},
    Increment = 5,
    Suffix = " HP",
    CurrentValue = rafting.emergencyReturnHp,
    Flag = "Slider_Rafting_EmergencyReturnHp",
    Callback = function(Value)
        rafting.emergencyReturnHp = Value
    end,
})

RaftingTab:CreateSlider({
    Name = "Dock Stop Delay (Seconds)",
    Range = {2, 30},
    Increment = 1,
    Suffix = "s",
    CurrentValue = rafting.dockMaxWaitSeconds,
    Flag = "Slider_Rafting_DockWait",
    Callback = function(Value)
        rafting.dockMaxWaitSeconds = Value
    end,
})

-- ==========================
-- UI SETUP: Settings Tab
-- ==========================
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = 4483362458 })

SettingsTab:CreateSection({ Name = "Performance & Anti-Lag" })

SettingsTab:CreateToggle({
    Name = "Map & Asset Optimizer (Anti-Lag)",
    CurrentValue = false,
    Flag = "Toggle_MapOptimizer",
    Callback = function(Value)
        mapOptimizer.enabled = Value
        if Value then
            mapOptimizer.applyToWorld()
            mapOptimizer.startStreamHook()
            mapOptimizer.preloadAssets()
            if Window and Window.Notify then
                Window:Notify({
                    Title = "Anti-Lag Optimizer Enabled",
                    Content = "Simplified map materials, disabled heavy shadows/particles, and hooked chunk streaming.",
                    Duration = 3.5,
                })
            end
        else
            mapOptimizer.stopStreamHook()
        end
    end,
})

SettingsTab:CreateToggle({
    Name = "Auto-Clean Streamed Chunks",
    CurrentValue = true,
    Flag = "Toggle_StreamCleaner",
    Callback = function(Value)
        mapOptimizer.autoCleanStreamed = Value
    end,
})

SettingsTab:CreateButton({
    Name = "Preload Game Audio & Assets",
    Callback = function()
        mapOptimizer.preloadAssets()
        if Window and Window.Notify then
            Window:Notify({
                Title = "Asset Preloader",
                Content = "Preloaded game audio and interface assets into memory cache.",
                Duration = 2.5,
            })
        end
    end,
})

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

SettingsTab:CreateSection({ Name = "AFK Anti-Cheat & Auto-Rejoin" })

SettingsTab:CreateToggle({
    Name = "Enable 6-Hour Auto-Rejoin & Resume",
    CurrentValue = true,
    Flag = "Toggle_AFK_Rejoin",
    Callback = function(Value)
        afkRelog.enabled = Value
        afkRelog.updateUI()
    end,
})

SettingsTab:CreateSlider({
    Name = "Rejoin Interval (Hours)",
    Range = {0.5, 12.0},
    Increment = 0.5,
    Suffix = " Hours",
    CurrentValue = 6.0,
    Flag = "Slider_AFK_Interval",
    Callback = function(Value)
        afkRelog.interval = Value * 3600
        afkRelog.targetRejoinTime = os.time() + afkRelog.interval
        afkRelog.updateUI()
    end,
})

pcall(function()
    afkRelog.statusCard = SettingsTab:CreateParagraph({
        Title = "AFK Rejoin Timer: Initializing...",
        Content = "State persistence: Ready"
    })
end)

SettingsTab:CreateButton({
    Name = "Save State & Test Rejoin Now",
    Callback = function()
        afkRelog.triggerRejoin()
    end,
})

SettingsTab:CreateButton({
    Name = "Clear Saved Persistence File",
    Callback = function()
        if delfile then
            pcall(function() delfile(afkRelog.fileName) end)
        end
        Window:Notify({ Title = "Cleared", Content = "Saved persistence file removed.", Duration = 2 })
    end,
})

SettingsTab:CreateSection({ Name = "Rayfield Gen2 Configuration Saving" })

SettingsTab:CreateButton({
    Name = "Save Configuration (CowHubConfig.rfld)",
    Callback = function()
        local success, err = pcall(function()
            return Window:Save()
        end)
        if success then
            Window:Notify({
                Title = "Configuration Saved",
                Content = "Saved current UI flags to Rayfield/Configurations/CowHub/CowHubConfig.rfld",
                Duration = 4,
                Image = 4483362458,
            })
        else
            Window:Notify({
                Title = "Save Error",
                Content = "Failed to save configuration: " .. tostring(err),
                Duration = 4,
            })
        end
    end,
})

SettingsTab:CreateButton({
    Name = "Reload Configuration (CowHubConfig.rfld)",
    Callback = function()
        local success, err = pcall(function()
            return Window:Load()
        end)
        if success then
            Window:Notify({
                Title = "Configuration Loaded",
                Content = "Restored and applied settings from Rayfield/Configurations/CowHub/CowHubConfig.rfld",
                Duration = 4,
                Image = 4483362458,
            })
        else
            Window:Notify({
                Title = "Load Error",
                Content = "Failed to load configuration: " .. tostring(err),
                Duration = 4,
            })
        end
    end,
})

SettingsTab:CreateSection({ Name = "Script Controls" })

SettingsTab:CreateButton({
    Name = "Close Script & Destroy UI",
    Callback = function()
        pcall(function()
            if auction.scannerRunning and httpRequest and WEBHOOK_URL ~= "" then
                task.spawn(function()
                    pcall(function()
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
                end)
            end

            farm.on = false
            farm.autoChomp = false
            farm.autoChompMobs = false
            farm.autoFish = false
            farm.goldenAura = false
            cache.cleanupRippleTracking()
            dodge.auto = false

            if manatite then
                pcall(function()
                    manatite.auto = false
                    manatite.showESP = false
                    manatite.cleanupVisuals()
                    if manatite.anchor and root then
                        pcall(function() root.Anchored = false end)
                    end
                    manatite.model = nil
                    manatite.target = nil
                    manatite.payload = nil
                end)
            end

            if mithril then
                pcall(function()
                    mithril.auto = false
                    mithril.showESP = false
                    mithril.cleanupVisuals()
                    if mithril.anchor and root then
                        pcall(function() root.Anchored = false end)
                    end
                    mithril.model = nil
                    mithril.orePart = nil
                    mithril.payload = nil
                end)
            end

            if aerial then
                pcall(function()
                    if aerial.active and root then
                        aerial.active = false
                        pcall(function() root.Anchored = false end)
                        if aerial.preCFrame then
                            pcall(function() char:PivotTo(aerial.preCFrame) end)
                            pcall(function() setRootCFrame(aerial.preCFrame) end)
                        end
                        pcall(function()
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end)
                        aerial.cframe = nil
                        aerial.preCFrame = nil
                    end
                end)
            end

            if dodge then
                pcall(function()
                    if dodge.isUnderground and root and dodge.lastSurfaceCFrame then
                        setRootCFrame(dodge.lastSurfaceCFrame + Vector3.new(0, 0.5, 0))
                        pcall(function() root.Anchored = false end)
                        pcall(function()
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end)
                        dodge.isUnderground = false
                        dodge.currentUndergroundRetreatOffset = nil
                    end
                    if dodge.isDodging then
                        if humanoid then humanoid.WalkSpeed = dodge.originalWalkSpeed or 16 end
                        dodge.isDodging = false
                        dodge.currentAttackingMob = nil
                    end
                end)
            end

            if trickOrTreat then
                pcall(function()
                    trickOrTreat.auto = false
                    trickOrTreat.loopRunning = false
                    if trickOrTreat.isCycling and trickOrTreat.savedPreCFrame then
                        pcall(function() safeReturnToSavedPosition(trickOrTreat.savedPreCFrame) end)
                    end
                    if trickOrTreat.clientEventConn then
                        pcall(function() trickOrTreat.clientEventConn:Disconnect() end)
                    end
                end)
            end

            if afkRelog then
                pcall(function()
                    afkRelog.enabled = false
                    afkRelog.isRejoining = false
                end)
            end

            auction.scannerRunning = false
            pcall(function()
                penESP.show = false
                penESP.update()
            end)
            pcall(function()
                chestESP.show = false
                chestESP.update()
            end)

            pcall(function() table.clear(cache.activeAuraMobs) end)
            pcall(function() table.clear(cache.mithrilCaveMobSet) end)

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

            for _, conn in ipairs(auction.connections) do
                if conn and conn.Disconnect then
                    pcall(function() conn:Disconnect() end)
                end
            end
            table.clear(auction.connections)

            auction.autoBidLoopRunning = false
            for _, conn in ipairs(auction.autoBidConnections) do
                if conn and conn.Disconnect then
                    pcall(function() conn:Disconnect() end)
                end
            end
            table.clear(auction.autoBidConnections)
            table.clear(auction.cards)
            table.clear(auction.customBidAmounts)

            if townAuction and townAuction.cleanup then
                pcall(function() townAuction.cleanup() end)
            end

            if rafting and rafting.cleanup then
                pcall(function() rafting.cleanup() end)
            end

            for _, conn in ipairs(scriptConnections) do
                if conn and conn.Disconnect then
                    pcall(function() conn:Disconnect() end)
                end
            end
            if mapOptimizer and mapOptimizer.stopStreamHook then
                pcall(function() mapOptimizer.stopStreamHook() end)
            end
            table.clear(scriptConnections)

            pcall(function() RunService:Set3dRenderingEnabled(true) end)
            if setfpscap then pcall(function() setfpscap(60) end) end

            if HeartbeatConnection then
                pcall(function() HeartbeatConnection:Disconnect() end)
                HeartbeatConnection = nil
            end
            pcall(function() if humanoid then humanoid:Move(Vector3.zero, false) end end)
        end)

        task.delay(0.05, function()
            pcall(function()
                if Window and Window.Unload then
                    Window:Unload()
                end
            end)
        end)
    end,
})

-- ==========================
-- BOOT: Initialize 6-Hour AFK Timer, State Resume & Preloading
-- ==========================
afkRelog.startTimer()
afkRelog.checkAndResumeState()
task.spawn(function()
    task.wait(1.5)
    if mapOptimizer and mapOptimizer.preloadAssets then
        mapOptimizer.preloadAssets()
    end
end)
