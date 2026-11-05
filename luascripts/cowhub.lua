-- Cow Hub [ea7f5c7] | Rayfield Gen2 Autofarm, Manatite Farm, Raycast Grass Chomper, Auto-Fishing & Alive-Only Priority Mob Aura
-- Optimized for high framerates, zero-allocation math, memory safety, and executor stability.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- 0. Prevent Hub Duplication on Rejoin
if _G.CowHubLoaded then
    -- The rafting autopilot keeps its own connections. Without this, the old copy keeps steering after a re-run,
    -- with no UI left to switch it off.
    if _G.CowHubRaftingCleanup then
        pcall(_G.CowHubRaftingCleanup)
        _G.CowHubRaftingCleanup = nil
    end
    -- Old copy may be holding the graze key (Natural mode) and buffering debug log lines
    if _G.CowHubChompCleanup then
        pcall(_G.CowHubChompCleanup)
        _G.CowHubChompCleanup = nil
    end
    pcall(function()
        if _G.CowHubRayfield and _G.CowHubRayfield.Destroy then
            _G.CowHubRayfield:Destroy()
        end
    end)
    if _G.CowHubConnections then
        for _, conn in ipairs(_G.CowHubConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if _G.CowHubHeartbeat then
        pcall(function() _G.CowHubHeartbeat:Disconnect() end)
        _G.CowHubHeartbeat = nil
    end
    _G.CowHubConnections = nil
    _G.CowHubRayfield = nil
    task.wait(0.3)
end
_G.CowHubLoaded = true

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
_G.CowHubRayfield = Rayfield

local Window = Rayfield:CreateWindow({
    Name = "Cow Hub [ea7f5c7]",
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
_G.CowHubConnections = scriptConnections

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

-- Drain unhandled spam remotes to prevent 1024 engine queue exhaustion
task.spawn(function()
    local marketEv = cowRemotes:WaitForChild("PublicMarketChanged", 5)
    if marketEv and marketEv:IsA("RemoteEvent") then
        marketEv.OnClientEvent:Connect(function() end)
    end
end)

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
    local function setupHumanoid(h)
        if not h then return end
        if dodge and (dodge.originalWalkSpeed == nil or dodge.originalWalkSpeed == 16) then
            dodge.originalWalkSpeed = h.WalkSpeed
        end
        h.Died:Connect(function()
            if rafting and rafting.onSessionEnded and (rafting.isSailing or (rafting.status and rafting.status ~= "Idle")) then
                rafting.onSessionEnded("Player died. Automated rafting stopped.")
            end
        end)
    end
    humanoid = resolveHumanoid(newChar)
    if humanoid then
        setupHumanoid(humanoid)
    else
        task.spawn(function()
            local waited = newChar:WaitForChild("Humanoid", 2)
            if waited and waited:IsA("Humanoid") then
                humanoid = waited
                setupHumanoid(humanoid)
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
    lastRaycastChompTime = 0, -- grass pacing lives in the chomp module (chomp.getInterval)
    chompOnlyWhileMoving = true,
    lastChompedMob = "",
    mobChompCooldown = 0,
    botCheckActive = false, -- Mirrors CowBotCheckActive / CowBotQuarantined; heartbeat halts while true
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
}

-- Grass chomp module state (functions defined after spiderLogger / remotes; see CHOMP MODULE)
local chomp = {
    BASE = 0.7, MIN = 0.4, MAX_COOLDOWN = 3, MAX_MULT = 1.236,
    BLOCK_ATTRS = { "CowMoofCutscene", "CowCaptured", "CowStunned", "CatapultActive", "CowBotCheckActive", "CowBotQuarantined" },
    mode = "Remote",   -- "Remote" (script fires ChompRequest) | "Natural" (drives the game's own E graze)
    autoMax = true,
    manualDelay = 0.4,
    margin = 0.03,     -- adaptive safety margin over the server limit, tuned by GrazeResult
    serial = 0,
    pending = {},
    lastFire = 0,
    lastNode = nil,
    stats = { sent = 0, accepted = 0, rejected = 0, cooldownRejects = 0 },
    calories = { sessionGained = 0, startTime = 0, activeDuration = 0, lastTimestamp = 0, lastCalories = nil, ratePerHour = 0 },
    natural = { held = false, lastTap = 0, lastEngage = 0, notGrazingSince = nil, rearmAt = 0, lastGrazing = nil, lastGameResult = 0, input = nil, lastScan = -math.huge, engaged = false },
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
    profileStore = nil,
    profileScanAt = -math.huge,
    cosmeticConfig = nil,
    ownershipRedrawQueued = false,
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

local function isGuiObjectTrulyVisible(obj)
    if not obj or not obj:IsA("GuiObject") then return false end
    if not obj.Visible then return false end

    local absSize = nil
    local absPos = nil
    pcall(function()
        absSize = obj.AbsoluteSize
        absPos = obj.AbsolutePosition
    end)
    if not absSize or not absPos then return false end
    if absSize.X < 4 or absSize.Y < 4 then return false end

    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize
    if vp then
        if (absPos.X + absSize.X) <= 0 or absPos.X >= vp.X
            or (absPos.Y + absSize.Y) <= 0 or absPos.Y >= vp.Y then
            return false
        end
    end

    local cur = obj.Parent
    while cur and cur:IsA("GuiObject") do
        if not cur.Visible then return false end
        if cur:IsA("CanvasGroup") and cur.GroupTransparency >= 0.95 then
            return false
        end
        cur = cur.Parent
    end

    if cur and (cur:IsA("ScreenGui") or cur:IsA("BillboardGui") or cur:IsA("SurfaceGui")) then
        if not cur.Enabled then return false end
    end

    return true
end

local function isRewardDismissButton(desc)
    if not desc or not desc:IsA("GuiButton") then return false end
    if not isGuiObjectTrulyVisible(desc) then return false end

    local name = desc.Name:lower()
    local text = (desc:IsA("TextButton") and desc.Text:lower()) or ""
    local attrLabel = desc:GetAttribute("AccessibilityLabel")
    local label = (typeof(attrLabel) == "string" and attrLabel:lower()) or ""

    -- Explicit Reject: Never click buttons that equip / wear items
    if name:find("wear") or name:find("equip")
        or text:find("wear") or text:find("equip") or text:find("try on") or text:find("put on")
        or label:find("wear") or label:find("equip") then
        return false
    end

    -- Match safe dismiss / close / accept buttons
    local isDismiss = false
    if name == "secondary" or name == "keepraiding" or name == "notnow"
        or name:find("close") or name:find("done") or name:find("claim") or name:find("accept")
        or name:find("okay") or name == "ok" or name:find("dismiss") or name:find("cancel") then
        isDismiss = true
    elseif name == "primary" then
        -- Primary button is ONLY safe if it does not wear items (e.g. "Done", "Open another", "Claim", "Accept", "OK", "Continue")
        if text == "done" or text:find("done") or text:find("claim") or text:find("accept") or text:find("okay") or text == "ok" or text:find("open another") or text:find("continue") then
            isDismiss = true
        elseif text == "" and (label:find("done") or label:find("claim") or label:find("close") or label:find("accept")) then
            isDismiss = true
        end
    elseif text == "done" or text:find("done") or text:find("close") or text:find("claim") or text:find("accept") or text:find("okay") or text == "ok" or text:find("not now") or text:find("keep raiding") or text:find("keep knocking") or text:find("thank you") or text:find("sweet") or text:find("treat") or text:find("great") then
        isDismiss = true
    elseif label:find("done") or label:find("close") or label:find("claim") or label:find("accept") or label:find("okay") or label:find("not now") or label:find("keep raiding") then
        isDismiss = true
    end

    return isDismiss
end

local function activateGuiButton(desc, vi)
    if not desc then return false end
    local activated = false
    pcall(function()
        if firesignal then
            pcall(function() firesignal(desc.Activated) end)
            pcall(function() firesignal(desc.MouseButton1Click) end)
            activated = true
        end
        if getconnections then
            pcall(function()
                for _, c in ipairs(getconnections(desc.Activated)) do
                    if c.Function then pcall(c.Function); activated = true end
                end
                for _, c in ipairs(getconnections(desc.MouseButton1Click)) do
                    if c.Function then pcall(c.Function); activated = true end
                end
            end)
        end
        if vi and vi.SendMouseButtonEvent then
            pcall(function()
                local abs = desc.AbsolutePosition + (desc.AbsoluteSize * 0.5)
                vi:SendMouseButtonEvent(abs.X, abs.Y, 0, true, game, 1)
                task.wait(0.04)
                vi:SendMouseButtonEvent(abs.X, abs.Y, 0, false, game, 1)
                activated = true
            end)
        end
    end)
    return activated
end

-- Visual ESP State Tables
local penESP = {
    show = false,
    visualizer = nil,
}

local chestESP = {
    show = false,
    visuals = {},
    highlight = nil,
    billboard = nil,
    espConn = nil,
    childAddedConn = nil,
    childRemovedConn = nil,
    descendantAddedConn = nil,
    descendantRemovingConn = nil,
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
local COWHUB_DIR = "cowhub"
local resolvedPaths = {}

local function resolveCowHubPath(fileName, subFolder)
    local cacheKey = (subFolder and (subFolder .. "/") or "") .. fileName
    if resolvedPaths[cacheKey] then
        return resolvedPaths[cacheKey]
    end

    local targetDir = COWHUB_DIR
    if makefolder then
        if isfolder then
            if not isfolder(COWHUB_DIR) then
                pcall(makefolder, COWHUB_DIR)
            end
        else
            pcall(makefolder, COWHUB_DIR)
        end
    end

    if subFolder then
        targetDir = COWHUB_DIR .. "/" .. subFolder
        if makefolder then
            if isfolder then
                if not isfolder(targetDir) then
                    pcall(makefolder, targetDir)
                end
            else
                pcall(makefolder, targetDir)
            end
        end
    end

    local hasFolder = false
    if isfolder then
        hasFolder = isfolder(targetDir)
    elseif makefolder then
        hasFolder = true
    end

    if not hasFolder then
        resolvedPaths[cacheKey] = fileName
        return fileName
    end

    local folderPath = targetDir .. "/" .. fileName

    -- Migrate legacy files into new directory if present
    local legacyPaths = { fileName }
    if subFolder then
        table.insert(legacyPaths, COWHUB_DIR .. "/" .. fileName)
    end

    for _, oldPath in ipairs(legacyPaths) do
        if isfile and isfile(oldPath) and (not isfile(folderPath)) then
            if readfile and writefile then
                local ok, content = pcall(readfile, oldPath)
                if ok and content then
                    pcall(writefile, folderPath, content)
                    local deleteFn = delfile or deletefile
                    if deleteFn then pcall(deleteFn, oldPath) end
                end
            end
        end
    end

    resolvedPaths[cacheKey] = folderPath
    return folderPath
end

local configFileName = resolveCowHubPath("CowScannerWebhook.txt")

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
    fileName = resolveCowHubPath("CowHub_SessionPersistence.json"),
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
            AutoFish = farm.autoFish == true,
            AnchorPos = farm.anchorPos and { X = farm.anchorPos.X, Y = farm.anchorPos.Y, Z = farm.anchorPos.Z } or nil,
            Radius = farm.radius or 75,
            Pattern = farm.pattern or "Guided Zigzag (Nodes)",
            PatternSpeed = farm.patternSpeed or 1.0,
            ChompMode = chomp.mode,
            ChompAutoMax = chomp.autoMax,
            ChompManualDelay = chomp.manualDelay,
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
        local deleteFn = delfile or deletefile
        if deleteFn then pcall(function() deleteFn(afkRelog.fileName) end) end
        return
    end

    -- Clean up persistence file so it only triggers once
    local deleteFn = delfile or deletefile
    if deleteFn then
        pcall(function() deleteFn(afkRelog.fileName) end)
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
        -- Chomp module (legacy GrassChompDelay maps to manual delay, floored at the server minimum)
        chomp.mode = (f.ChompMode == "Natural") and "Natural" or "Remote"
        pcall(function() Window:Set("Dropdown_ChompMode", { chomp.mode == "Natural" and "Natural (E Key)" or "Remote (Auto Max)" }) end)
        if f.ChompAutoMax ~= nil then
            chomp.autoMax = f.ChompAutoMax == true
            pcall(function() Window:Set("Toggle_ChompAutoMax", chomp.autoMax) end)
        end
        local manual = tonumber(f.ChompManualDelay) or tonumber(f.GrassChompDelay)
        if manual then
            chomp.manualDelay = math.max(chomp.MIN, manual)
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
local SPIDER_JSON_FILE = resolveCowHubPath("SpiderIdentifiers.json")

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
-- CHOMP MODULE (grass bite pacing: Remote auto-max / Natural E-key graze)
-- Interval mirrors InputController:_chewCooldown:
--   clamp(ChewCooldown, 0.4, 3) [x0.5 Wheat] / clamp(CowGrazingSpeedMultiplier, 1, 1.2 * 1.03)
-- ==========================
-- chomp state table is declared next to `farm` (used by relog save/restore above)

-- Fastest interval the server accepts right now (buffs read live from player attributes)
function chomp.serverInterval(node)
    local base = math.clamp(tonumber(plr:GetAttribute("ChewCooldown")) or chomp.BASE, chomp.MIN, chomp.MAX_COOLDOWN)
    local mult = math.clamp(tonumber(plr:GetAttribute("CowGrazingSpeedMultiplier")) or 1, 1, chomp.MAX_MULT)
    if node and typeof(node) == "Instance" then
        local biteCooldown = node:GetAttribute("CowBiteCooldown")
        if type(biteCooldown) == "number" then
            return math.max(biteCooldown, base) / mult
        end
        if node:GetAttribute("FoodKind") == "Wheat" then
            base = base * 0.5
        end
    end
    return base / mult
end

function chomp.getInterval(node)
    local interval = chomp.serverInterval(node) + chomp.margin
    if not chomp.autoMax then
        interval = math.max(interval, chomp.manualDelay)
    end
    return interval
end

-- Single grass ChompRequest call site; wire shape matches InputController (nodeId, nil, serial)
function chomp.fire(nodeId, node, now)
    if farm.botCheckActive or chomp.mode ~= "Remote" then return false end
    local interval = chomp.getInterval(node)
    if now - chomp.lastFire < interval then return false end
    chomp.serial += 1
    local serial = chomp.serial
    chomp.lastFire = now
    chomp.lastNode = nodeId
    chomp.pending[serial] = { NodeId = nodeId, SentAt = now }
    if serial % 32 == 0 then
        for k, p in pairs(chomp.pending) do
            if now - p.SentAt > 15 then chomp.pending[k] = nil end
        end
    end
    chomp.stats.sent += 1
    spiderLogger.isInternalFire = true
    pcall(function() chompEvent:FireServer(nodeId, nil, serial) end)
    spiderLogger.isInternalFire = false
    return true
end

-- GrazeResult feedback: tighten margin on accept, back off on ChewCooldown rejects
do
    local clientEvent = cowRemotes:FindFirstChild("ClientEvent")
    if clientEvent and clientEvent:IsA("RemoteEvent") then
        table.insert(scriptConnections, clientEvent.OnClientEvent:Connect(function(name, res)
            if name ~= "GrazeResult" or type(res) ~= "table" then return end
            local p = chomp.pending[res.RequestId]
            if not p then
                -- Not ours: the game's own graze loop is biting (natural-mode evidence)
                chomp.natural.lastGameResult = os.clock()
                return
            end
            if p.NodeId ~= res.NodeId then return end
            chomp.pending[res.RequestId] = nil
            local now = os.clock()
            if res.Accepted == true then
                chomp.stats.accepted += 1
                chomp.margin = math.max(0.01, chomp.margin - 0.002)
            else
                chomp.stats.rejected += 1
                if res.Reason == "ChewCooldown" then
                    chomp.stats.cooldownRejects += 1
                    chomp.margin = math.min(0.15, chomp.margin + 0.02)
                    chomp.lastFire = now
                end
            end
        end))
    end
end

-- ---------- Natural mode: drive the game's CowGraze action (E) ----------
-- The game keeps graze state privately on its InputController instance (_grazing)
function chomp.findInput(now)
    local n = chomp.natural
    local ctrl = n.input
    if ctrl and rawget(ctrl, "_grazeSources") ~= nil then return ctrl end
    n.input = nil
    if type(getgc) ~= "function" or now - n.lastScan < 5 then return nil end
    n.lastScan = now
    local ok, objs = pcall(getgc, true)
    if not ok or type(objs) ~= "table" then return nil end
    for _, t in ipairs(objs) do
        if type(t) == "table" and rawget(t, "_grazeSources") ~= nil and rawget(t, "_grazePressed") ~= nil then
            n.input = t
            return t
        end
    end
    return nil
end

-- Returns grazing, source ("ctrl" | "attr" | "result" | "none")
function chomp.isGrazing()
    local now = os.clock()
    local ctrl = chomp.findInput(now)
    if ctrl then return rawget(ctrl, "_grazing") == true, "ctrl" end
    local c = plr.Character
    if c and c:GetAttribute("CowAction") == "Graze" then return true, "attr" end
    if now - chomp.natural.lastGameResult < 2.5 then return true, "result" end
    return false, "none"
end

function chomp.canEngage()
    if farm.botCheckActive or plr:GetAttribute("CowClientReady") ~= true then return false end
    for _, attr in ipairs(chomp.BLOCK_ATTRS) do
        if plr:GetAttribute(attr) == true then return false end
    end
    local ok, box = pcall(function() return game:GetService("UserInputService"):GetFocusedTextBox() end)
    return not (ok and box)
end

function chomp.sendKey(down)
    pcall(function()
        if successVIM and VirtualInput then
            VirtualInput:SendKeyEvent(down, Enum.KeyCode.E, false, game)
        elseif down and keypress then
            keypress(0x45)
        elseif not down and keyrelease then
            keyrelease(0x45)
        end
    end)
end

function chomp.engage(now)
    local n = chomp.natural
    if not chomp.canEngage() then return end
    if plr:GetAttribute("CowGrazeToggle") == true then
        -- Toggle setting: a press flips grazing, so tap sparingly
        if now - n.lastTap < (n.input and 3 or 6) then return end
        n.lastTap = now
        n.engaged = true
        chomp.sendKey(true)
        task.delay(0.05, function() chomp.sendKey(false) end)
    else
        -- Hold setting: game latches _grazePressed, so release before re-press
        if n.held then
            chomp.sendKey(false)
            task.delay(0.05, function()
                if n.held then chomp.sendKey(true) end
            end)
        else
            chomp.sendKey(true)
        end
        n.held = true
    end
end

function chomp.release()
    local n = chomp.natural
    if n.held then
        n.held = false
        chomp.sendKey(false)
    end
    n.notGrazingSince = nil
end

-- Full stop (mode switch / toggle off): also untoggle grazing under the Toggle Graze setting
function chomp.stopNatural()
    chomp.release()
    local engaged = chomp.natural.engaged
    chomp.natural.engaged = false
    -- Only undo a graze the hub turned on; never untoggle the player's own grazing
    if engaged and plr:GetAttribute("CowGrazeToggle") == true and chomp.isGrazing() then
        chomp.sendKey(true)
        task.delay(0.05, function() chomp.sendKey(false) end)
    end
end

function chomp.tickNatural(now)
    local n = chomp.natural
    if farm.botCheckActive then
        chomp.release()
        return
    end
    local grazing, src = chomp.isGrazing()
    if grazing ~= n.lastGrazing then
        n.lastGrazing = grazing
    end
    if grazing then
        n.notGrazingSince = nil
        return
    end
    n.notGrazingSince = n.notGrazingSince or now
    local toggleSetting = plr:GetAttribute("CowGrazeToggle") == true
    local idleNeeded = toggleSetting and 1.5 or 0.4
    local retry = (n.held and not toggleSetting) and 3 or 0.75
    local rearmDue = n.rearmAt > 0 and now >= n.rearmAt
    if (rearmDue or now - n.notGrazingSince >= idleNeeded) and now - n.lastEngage >= retry then
        n.rearmAt = 0
        n.lastEngage = now
        chomp.engage(now)
    end
end

-- Mob aura bites interrupt grazing and share the server chew cooldown
function chomp.onMobAttack(now)
    chomp.lastFire = now
    local n = chomp.natural
    n.rearmAt = now + 0.25
    n.lastEngage = 0
    n.lastTap = 0
    n.notGrazingSince = nil
    -- pressE() (cave mobs) sends an E release, so a held graze key is no longer held
    n.held = false
end

-- Calorie tracking for Auto-Chomp stats
function chomp.getCalories()
    local val = tonumber(plr:GetAttribute("Calories"))
    if val then return val end
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
        local c = ls:FindFirstChild("Calories")
        if c and c:IsA("ValueBase") then
            return tonumber(c.Value)
        end
    end
    return nil
end

function chomp.resetCalories()
    local now = os.clock()
    local current = chomp.getCalories()
    local cal = chomp.calories
    cal.sessionGained = 0
    cal.startTime = now
    cal.activeDuration = 0
    cal.lastTimestamp = now
    cal.lastCalories = current
    cal.ratePerHour = 0
end

function chomp.updateCalories()
    local current = chomp.getCalories()
    if not current then return end
    local cal = chomp.calories
    if not cal.lastCalories then
        cal.lastCalories = current
        return
    end
    local delta = current - cal.lastCalories
    cal.lastCalories = current
    if delta > 0 and farm.autoChomp then
        cal.sessionGained = cal.sessionGained + delta
    end
end

do
    table.insert(scriptConnections, plr:GetAttributeChangedSignal("Calories"):Connect(function()
        chomp.updateCalories()
    end))
    local function watchLeaderstats(parent)
        local c = parent:FindFirstChild("Calories")
        if c and c:IsA("ValueBase") then
            table.insert(scriptConnections, c.Changed:Connect(function()
                chomp.updateCalories()
            end))
        end
    end
    local ls = plr:FindFirstChild("leaderstats")
    if ls then watchLeaderstats(ls) end
    table.insert(scriptConnections, plr.ChildAdded:Connect(function(child)
        if child.Name == "leaderstats" then
            watchLeaderstats(child)
        end
    end))
end

_G.CowHubChompCleanup = function()
    chomp.stopNatural()
end

-- ==========================
-- BOT CHECK PAUSE (game human-check active -> halt all farm actions)
-- ==========================
do
    local function refreshBotCheck()
        local active = plr:GetAttribute("CowBotCheckActive") == true or plr:GetAttribute("CowBotQuarantined") == true
        if active == farm.botCheckActive then return end
        farm.botCheckActive = active
        if active then chomp.release() end
        safeNotify({
            Title = active and "Bot Check Active" or "Bot Check Cleared",
            Content = active and "Autofarm paused until the human check is completed." or "Autofarm resumed.",
            Duration = active and 10 or 4,
        })
    end
    table.insert(scriptConnections, plr:GetAttributeChangedSignal("CowBotCheckActive"):Connect(refreshBotCheck))
    table.insert(scriptConnections, plr:GetAttributeChangedSignal("CowBotQuarantined"):Connect(refreshBotCheck))
    refreshBotCheck()
end

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

local function isOreAvailable(targetPart, model, checkYield)
    if not targetPart or not targetPart.Parent then return false end
    if model and not model.Parent then return false end

    local attr = targetPart:GetAttribute("Available")
    if attr == nil then
        attr = targetPart:GetAttribute("available")
    end
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

    if checkYield then
        local yieldVal, hasYield = manatite.getGrazeTargetYield(targetPart, model)
        if hasYield and yieldVal <= 0 then
            return false
        end
    end

    return true
end

function manatite.isAvailable(target, model)
    return isOreAvailable(target, model, true)
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

local function cleanupOreBlacklist(oreState, now)
    if now - oreState.lastBlacklistCleanup > 10 then
        oreState.lastBlacklistCleanup = now
        for model, timestamp in pairs(oreState.blacklist) do
            if not model or not model.Parent or (now - timestamp > 20) then
                oreState.blacklist[model] = nil
            end
        end
    end
end

function manatite.cleanupBlacklist(now)
    cleanupOreBlacklist(manatite, now)
end

local function isPositionNearThreatMob(pos, distSq)
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

manatite.isPositionNearMob = isPositionNearThreatMob

local function findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)
    local models = oreState.getModels()
    if not models or #models == 0 then return nil, nil end

    local now = os.clock()
    local origin = searchOrigin or getRootPos(root) or Vector3.zero
    local requireSafe = (avoidMobs == true) or (avoidMobs == nil and dodge.retreatOnThreat)

    local safeCandidates = {}
    local allCandidates = {}

    for _, model in ipairs(models) do
        if model.Parent then
            local blacklistedAt = oreState.blacklist[model]
            if not blacklistedAt or (now - blacklistedAt > 20) then
                local target = getTargetFn(model)
                if target and oreState.isAvailable(target, model) then
                    local isNear = isPositionNearThreatMob(target.Position, dodge.manatiteThreatRadiusSq or 225)
                    local item = {
                        model = model,
                        target = target,
                        isNearMob = isNear,
                        distSq = get3DDistanceSq(origin, target.Position),
                        yield = (checkYield and oreState.order == "Largest Crystal Yield") and oreState.getGrazeTargetYield(target, model) or 0
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

    if oreState.order == "Alphabetical (A-Z)" then
        table.sort(pool, function(a, b) return a.model.Name < b.model.Name end)
        return pool[1].model, pool[1].target
    elseif checkYield and oreState.order == "Largest Crystal Yield" then
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

function manatite.findNext(searchOrigin, avoidMobs)
    return findNextOreCandidate(manatite, manatite.getGrazeTarget, true, searchOrigin, avoidMobs)
end

local function teleportToOreNode(oreState, targetPart, model)
    if not root or not char or not targetPart or not targetPart.Parent then return end

    local targetPos = targetPart.Position + Vector3.new(0, oreState.heightOffset, 0)
    local modelPos = model and model:GetPivot().Position or targetPart.Position
    local lookDir = Vector3.new(modelPos.X - targetPos.X, 0, modelPos.Z - targetPos.Z)
    local targetCFrame = (lookDir.Magnitude > 0.5) and CFrame.lookAt(targetPos, targetPos + lookDir.Unit) or CFrame.new(targetPos)

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

    if oreState.anchor then
        pcall(function() root.Anchored = true end)
    end
end

function manatite.teleport(grazeTarget, model)
    teleportToOreNode(manatite, grazeTarget, model)
end

local function retreatOreNode(oreState, isMithril, title, content, now, rootPos)
    local currentModel = oreState.model
    if currentModel then
        oreState.blacklist[currentModel] = now
    end

    oreState.model = nil
    if isMithril then
        oreState.orePart = nil
    else
        oreState.target = nil
    end
    oreState.payload = nil

    if root then
        pcall(function() root.Anchored = false end)
    end

    local nextModel, nextPart = oreState.findNext(rootPos or getRootPos(root), true)
    if nextModel and nextPart then
        oreState.model = nextModel
        if isMithril then
            oreState.orePart = nextPart
        else
            oreState.target = nextPart
        end
        oreState.payload = oreState.getPayload(nextModel.Name)
        oreState.startTime = now
        oreState.teleport(nextPart, nextModel)
        oreState.lastTeleportTime = now
        oreState.lastChompTime = 0
        oreState.lastSearchTime = now

        if dodge.notifyOnDodge and Window and Window.Notify then
            Window:Notify({
                Title = title,
                Content = content,
                Duration = 2,
            })
        end
        return true
    end
    return false
end

function manatite.retreatToSafeCrystal(now, rootPos)
    return retreatOreNode(manatite, false, "Manatite Retreat", "Spiders nearby! Relocated to a safe crystal.", now, rootPos)
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
    return isOreAvailable(orePart, model, false)
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
    cleanupOreBlacklist(mithril, now)
end

mithril.isPositionNearMob = isPositionNearThreatMob

function mithril.findNext(searchOrigin, avoidMobs)
    return findNextOreCandidate(mithril, mithril.getOrePart, false, searchOrigin, avoidMobs)
end

function mithril.retreatToSafeOre(now, rootPos)
    return retreatOreNode(mithril, true, "Mithril Retreat", "Spiders nearby! Relocated to safe ore.", now, rootPos)
end

function mithril.teleport(orePart, model)
    teleportToOreNode(mithril, orePart, model)
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

-- Helper to identify team chest models
local function isTeamChest(inst)
    if not inst then return false end
    if not (inst:IsA("Model") or inst:IsA("BasePart")) then return false end
    local parent = inst.Parent
    if parent and parent:IsA("Model") then
        local pLower = string.lower(parent.Name)
        if string.find(pLower, "teamchest", 1, true) or string.find(pLower, "team_chest", 1, true) then
            return false
        end
    end
    local lowerName = string.lower(inst.Name)
    return string.find(lowerName, "teamchest", 1, true) ~= nil or string.find(lowerName, "team_chest", 1, true) ~= nil
end

-- Remove a specific chest ESP visual
function chestESP.removeVisual(model)
    local visual = chestESP.visuals[model]
    if not visual then return end
    if visual.ancestryConn then
        pcall(function() visual.ancestryConn:Disconnect() end)
    end
    if visual.highlight then
        pcall(function() visual.highlight:Destroy() end)
    end
    if visual.billboard then
        pcall(function() visual.billboard:Destroy() end)
    end
    chestESP.visuals[model] = nil
end

-- Cleanup all chest ESP instances
function chestESP.cleanup()
    if chestESP.espConn then
        pcall(function() chestESP.espConn:Disconnect() end)
        chestESP.espConn = nil
    end
    for model in pairs(chestESP.visuals) do
        chestESP.removeVisual(model)
    end
    table.clear(chestESP.visuals)
end

-- Attach ESP to a loaded chest model/part
function chestESP.attach(trackedChest)
    if not chestESP.show or not trackedChest or not trackedChest.Parent then return end
    if chestESP.visuals[trackedChest] then return end

    local chestPart = trackedChest:IsA("Model") and (trackedChest.PrimaryPart or trackedChest:FindFirstChildWhichIsA("BasePart")) or (trackedChest:IsA("BasePart") and trackedChest)
    if not chestPart then
        chestPart = trackedChest:FindFirstChildWhichIsA("BasePart", true)
    end
    if not chestPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ChestHighlight"
    highlight.Adornee = trackedChest
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = trackedChest

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ChestESPText"
    billboard.Adornee = chestPart
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    local displayName = (trackedChest.Name == "LocalTeamChest" or trackedChest.Name == "TeamChest") and "Team Chest" or trackedChest.Name
    textLabel.Text = "📦 " .. displayName
    textLabel.Parent = billboard

    billboard.Parent = trackedChest

    local visual = {
        highlight = highlight,
        billboard = billboard,
        label = textLabel,
        chestPart = chestPart,
        displayName = displayName,
        lastDist = -1,
        ancestryConn = nil,
    }

    visual.ancestryConn = trackedChest.AncestryChanged:Connect(function(_, parent)
        if not parent then
            chestESP.removeVisual(trackedChest)
        end
    end)

    chestESP.visuals[trackedChest] = visual
end

-- Dynamic load/unload watcher for TeamChest models
function chestESP.update()
    if chestESP.show then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if isTeamChest(desc) then
                chestESP.attach(desc)
            end
        end

        if not chestESP.descendantAddedConn then
            chestESP.descendantAddedConn = workspace.DescendantAdded:Connect(function(desc)
                if chestESP.show and isTeamChest(desc) then
                    task.wait(0.1)
                    chestESP.attach(desc)
                end
            end)
        end

        if not chestESP.descendantRemovingConn then
            chestESP.descendantRemovingConn = workspace.DescendantRemoving:Connect(function(desc)
                if chestESP.visuals[desc] then
                    chestESP.removeVisual(desc)
                end
            end)
        end

        if not chestESP.espConn then
            local lastChestUpdate = 0
            local lastScan = 0
            chestESP.espConn = RunService.Heartbeat:Connect(function()
                if not chestESP.show then
                    chestESP.cleanup()
                    return
                end
                local now = os.clock()
                if now - lastScan > 2.0 then
                    lastScan = now
                    for _, child in ipairs(workspace:GetChildren()) do
                        if isTeamChest(child) and not chestESP.visuals[child] then
                            chestESP.attach(child)
                        end
                    end
                    local found = workspace:FindFirstChild("LocalTeamChest", true)
                    if found and isTeamChest(found) and not chestESP.visuals[found] then
                        chestESP.attach(found)
                    end
                end

                if now - lastChestUpdate > 0.1 then
                    lastChestUpdate = now
                    local rPos = getRootPos(root)
                    if rPos then
                        for trackedChest, visual in pairs(chestESP.visuals) do
                            if not trackedChest or not trackedChest.Parent or not visual.chestPart or not visual.chestPart.Parent then
                                chestESP.removeVisual(trackedChest)
                            else
                                local dist = math.floor(get2DDistance(rPos, visual.chestPart.Position))
                                if dist ~= visual.lastDist then
                                    visual.lastDist = dist
                                    visual.label.Text = "📦 " .. visual.displayName .. "\n[" .. dist .. " studs]"
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        if chestESP.descendantAddedConn then
            pcall(function() chestESP.descendantAddedConn:Disconnect() end)
            chestESP.descendantAddedConn = nil
        end
        if chestESP.descendantRemovingConn then
            pcall(function() chestESP.descendantRemovingConn:Disconnect() end)
            chestESP.descendantRemovingConn = nil
        end
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

local function formatCompact(n)
    if not n or n ~= n then return "0" end
    local abs = math.abs(n)
    local sign = n < 0 and "-" or ""
    if abs >= 1e12 then
        return string.format("%s%.2fT", sign, abs / 1e12)
    elseif abs >= 1e9 then
        return string.format("%s%.2fB", sign, abs / 1e9)
    elseif abs >= 1e6 then
        return string.format("%s%.2fM", sign, abs / 1e6)
    elseif abs >= 1e3 then
        return string.format("%s%.2fK", sign, abs / 1e3)
    else
        return string.format("%s%.0f", sign, abs)
    end
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
                if farm.autoChomp and (now - farm.lastRaycastChompTime >= chomp.getInterval()) then
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
                chomp.onMobAttack(now)
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
                chomp.onMobAttack(now)
                return true
            else
                return true
            end
        end
    end
    return false
end

function farm.processGrassChomp(now, rootPos)
    if chomp.mode ~= "Remote" or farm.botCheckActive then return end
    local chompDelay = chomp.getInterval()
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
        local repeatDelay = chompDelay + 0.2

        local function tryCandidate(inst, id)
            if not id and inst then
                id = cache.getNodeID(inst) or cache.extractGrassNodeId(inst)
            end
            if not id then return false end

            -- If candidate is the last chomped node, only accept if repeatDelay has elapsed
            if id == chomp.lastNode and (now - chomp.lastFire < repeatDelay) then
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
                            if id and (id ~= chomp.lastNode or (now - chomp.lastFire >= repeatDelay)) then
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

        -- 5. Fire Chomp Request (pacing + wire shape owned by chomp.fire)
        if targetNodeId then
            local resolvedNode = typeof(targetInstance) == "Instance" and targetInstance or nil
            if chomp.fire(targetNodeId, resolvedNode, now) then
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

local function processOreFarm(oreState, isMithril, now, rootPos)
    oreState.cleanupBlacklist(now)

    local targetPart = isMithril and oreState.orePart or oreState.target
    local targetValid = oreState.model
        and targetPart
        and oreState.model.Parent
        and targetPart.Parent
        and oreState.isAvailable(targetPart, oreState.model)
        and (now - oreState.startTime <= 15)

    if not targetValid then
        if oreState.model and (now - oreState.startTime > 15) then
            oreState.blacklist[oreState.model] = now
        end

        oreState.model = nil
        if isMithril then
            oreState.orePart = nil
        else
            oreState.target = nil
        end
        oreState.payload = nil

        if oreState.anchor and root then
            pcall(function() root.Anchored = false end)
        end

        if (now - oreState.lastSearchTime > 0.1) then
            oreState.lastSearchTime = now
            local nextModel, nextPart = oreState.findNext(rootPos)
            if nextModel and nextPart then
                oreState.model = nextModel
                if isMithril then
                    oreState.orePart = nextPart
                else
                    oreState.target = nextPart
                end
                oreState.payload = oreState.getPayload(nextModel.Name)
                oreState.startTime = now
                oreState.teleport(nextPart, nextModel)
                oreState.lastTeleportTime = now
                oreState.lastChompTime = 0
            end
        end
    else
        local targetPos = targetPart.Position + Vector3.new(0, oreState.heightOffset, 0)

        if dodge.retreatOnThreat and (now - oreState.lastSearchTime > 0.25) then
            local checkPos = targetPart.Position
            if isPositionNearThreatMob(checkPos, dodge.manatiteThreatRadiusSq) or isPositionNearThreatMob(rootPos, dodge.manatiteThreatRadiusSq) then
                if isMithril then
                    oreState.retreatToSafeOre(now, rootPos)
                else
                    oreState.retreatToSafeCrystal(now, rootPos)
                end
                return
            end
        end

        if get3DDistanceSq(rootPos, targetPos) > 36 then
            if (now - oreState.lastTeleportTime > 0.4) then
                oreState.teleport(targetPart, oreState.model)
                oreState.lastTeleportTime = now
            end
        else
            if oreState.anchor and not root.Anchored and not dodge.isDodging and not dodge.isUnderground and not dodge.hasNearbyThreat then
                pcall(function() root.Anchored = true end)
            end
        end

        if (now - oreState.lastChompTime >= oreState.delay) then
            oreState.lastChompTime = now
            chompEvent:FireServer(oreState.payload)
        end
    end
end

function manatite.process(now, rootPos)
    processOreFarm(manatite, false, now, rootPos)
end

function mithril.process(now, rootPos)
    processOreFarm(mithril, true, now, rootPos)
end

-- ==========================
-- MAIN ENGINE HEARTBEAT LOOP (Concise Dispatcher)
-- ==========================
function updateHeartbeatConnection()
    if farm.on or farm.autoChomp or farm.autoFish or farm.autoChompMobs or dodge.auto or (manatite and manatite.auto) or (mithril and mithril.auto) then
        if not HeartbeatConnection then
            HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
            _G.CowHubHeartbeat = HeartbeatConnection
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
                if farm.botCheckActive then return end

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
                if farm.autoChomp and chomp.mode == "Natural" then
                    -- Natural: the game's InputController targets and paces; we keep E engaged
                    if not (manatite and manatite.auto) and not (mithril and mithril.auto) and not dodge.isUnderground then
                        chomp.tickNatural(now)
                    end
                elseif farm.autoChomp and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not prioritizedMobThisFrame and not dodge.isUnderground and not dodge.isDodging then
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
            _G.CowHubHeartbeat = nil
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
        if not Value and chomp.mode == "Natural" then
            chomp.stopNatural()
        end
        if Value then
            chomp.resetCalories()
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
    Name = "Chomp Mode",
    Options = { "Remote (Auto Max)", "Natural (E Key)" },
    CurrentOption = { "Remote (Auto Max)" },
    MultipleOptions = false,
    Flag = "Dropdown_ChompMode",
    Callback = function(Option)
        local selection = tostring(type(Option) == "table" and Option[1] or Option)
        local newMode = string.find(selection, "Natural", 1, true) and "Natural" or "Remote"
        if newMode == chomp.mode then return end
        if chomp.mode == "Natural" then chomp.stopNatural() end
        chomp.mode = newMode
    end,
})

MainTab:CreateToggle({
    Name = "Auto Max Chomp Speed (Server Limit)",
    CurrentValue = true,
    Flag = "Toggle_ChompAutoMax",
    Callback = function(Value)
        chomp.autoMax = Value
    end,
})

MainTab:CreateDropdown({
    Name = "Manual Chomp Speed (when Auto Max off)",
    Options = { "0.4s", "0.5s", "0.6s", "0.7s (Game Base)", "1.0s", "1.5s" },
    CurrentOption = { "0.4s" },
    MultipleOptions = false,
    Flag = "Dropdown_GrassSpeed",
    Callback = function(Option)
        local selection = tostring(type(Option) == "table" and Option[1] or Option)
        chomp.manualDelay = math.max(chomp.MIN, tonumber(string.match(selection, "(%d+%.?%d*)")) or chomp.MIN)
    end,
})

do
    local title, body = "Chomp: --", "Interval: --"
    if MainTab.CreateText then
        pcall(function() chomp.statusCard = MainTab:CreateText({ name = title, text = body }) end)
    end
    if not chomp.statusCard and MainTab.CreateParagraph then
        pcall(function() chomp.statusCard = MainTab:CreateParagraph({ Title = title, Content = body }) end)
    end
    task.spawn(function()
        while chomp.statusCard and _G.CowHubConnections == scriptConnections do
            task.wait(1)
            if farm.autoChomp then
                chomp.updateCalories()
                local now = os.clock()
                local cal = chomp.calories
                if cal.lastTimestamp == 0 then cal.lastTimestamp = now end
                local dt = now - cal.lastTimestamp
                cal.lastTimestamp = now
                if not farm.botCheckActive and dt > 0 and dt < 5 then
                    cal.activeDuration = cal.activeDuration + dt
                end

                if cal.activeDuration >= 3 and cal.sessionGained > 0 then
                    cal.ratePerHour = (cal.sessionGained / cal.activeDuration) * 3600
                end

                local calRateStr = "--"
                if cal.activeDuration >= 3 and cal.ratePerHour > 0 then
                    calRateStr = string.format("%s/hr (%s)", formatCompact(cal.ratePerHour), formatNumber(math.floor(cal.ratePerHour)))
                elseif cal.activeDuration < 3 then
                    calRateStr = "Calculating..."
                end

                local st = chomp.stats
                local t = string.format("Chomp: %s%s", chomp.mode, farm.botCheckActive and " | PAUSED (bot check)" or "")
                local b = string.format("Interval: %.3fs (server %.3fs + margin %.3fs)\nSent %d | OK %d | Rejected %d (cooldown %d)\nGrazing: %s\nAvg Calories/hr: %s",
                    chomp.getInterval(), chomp.serverInterval(), chomp.margin,
                    st.sent, st.accepted, st.rejected, st.cooldownRejects, tostring(chomp.isGrazing()),
                    calRateStr)
                pcall(function()
                    if chomp.statusCard.SetTitle then
                        chomp.statusCard:SetTitle(t)
                        chomp.statusCard:Set(b)
                    elseif chomp.statusCard.Set then
                        chomp.statusCard:Set({ Title = t, Content = b })
                    end
                end)
            end
        end
    end)
end

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
        if penESP and penESP.update then
            pcall(penESP.update)
        end
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

-- Closet ownership: the game's live profile (UIController.Store) + CosmeticConfig, as the Closet uses
function townAuction.getProfile()
    local store = townAuction.profileStore
    if store then
        local ok, state = pcall(function() return store:GetState() end)
        if ok and type(state) == "table" and type(state.Profile) == "table" then return state.Profile end
        townAuction.profileStore = nil
    end
    local now = os.clock()
    if type(getgc) ~= "function" or now - townAuction.profileScanAt < 5 then return nil end
    townAuction.profileScanAt = now
    local ok, objs = pcall(getgc, true)
    if not ok or type(objs) ~= "table" then return nil end
    for _, t in ipairs(objs) do
        if type(t) == "table" and rawget(t, "Remotes") ~= nil and type(rawget(t, "Store")) == "table" then
            local s = rawget(t, "Store")
            local okState, state = pcall(function() return s:GetState() end)
            if okState and type(state) == "table" and type(state.Profile) == "table" then
                townAuction.profileStore = s
                return state.Profile
            end
        end
    end
    return nil
end

function townAuction.getCosmeticConfig()
    if townAuction.cosmeticConfig == nil then
        local ok, mod = pcall(function()
            return require(game:GetService("ReplicatedStorage").CowGame.Shared.CosmeticConfig)
        end)
        townAuction.cosmeticConfig = (ok and type(mod) == "table") and mod or false
    end
    return townAuction.cosmeticConfig or nil
end

-- Card text for "Owned:" — closet count from the game, plus listable duplicates from the auction snapshot
function townAuction.formatOwnership(itemId)
    if not itemId then return "-" end
    local listable = townAuction.ownedCopies[itemId] or 0
    local extra = listable > 0 and string.format(" (%d listable)", listable) or ""
    local config = townAuction.getCosmeticConfig()
    if config then
        local okDef, def = pcall(config.Get, itemId)
        if okDef and not def then return "n/a" end
        local profile = okDef and townAuction.getProfile()
        if profile then
            local okOwned, owned = pcall(config.IsOwned, itemId, profile)
            if okOwned then
                if owned ~= true then return "❌" end
                local okCount, count = pcall(config.GetOwnedCount, itemId, profile)
                count = okCount and tonumber(count) or nil
                if count and count > 0 then return string.format("✅ ×%d%s", count, extra) end
                return "✅" .. extra
            end
        end
    end
    if listable > 0 then return "✅" .. extra end
    return "? (Closet unavailable)"
end

-- Redraw cards after the server pushes a profile Snapshot (buy/win/list changes ownership)
function townAuction.initOwnershipListener()
    local clientEvent = cowRemotes and cowRemotes:FindFirstChild("ClientEvent")
    if not (clientEvent and clientEvent:IsA("RemoteEvent")) then return end
    table.insert(townAuction.connections, clientEvent.OnClientEvent:Connect(function(name)
        if name ~= "Snapshot" or townAuction.ownershipRedrawQueued then return end
        townAuction.ownershipRedrawQueued = true
        -- let the game's own handler apply the new profile first
        task.delay(0.25, function()
            townAuction.ownershipRedrawQueued = false
            townAuction.updateAllCards()
        end)
    end))
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

    local body = string.format("%s\nLeader: %s\nRound: %s | Ends In: %s\nItem ID: %s | Owned: %s",
        priceLine,
        leaderStatus,
        tostring(round),
        townAuction.formatRemainingTime(endsAt),
        tostring(itemId),
        townAuction.formatOwnership(itemId)
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
    townAuction.profileStore = nil
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
townAuction.initOwnershipListener()

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

-- Session a deck belongs to: its RaftSessionId attribute, else the TeamRaft_<id> model name
function rafting.deckSessionOf(deck, model)
    local id = deck:GetAttribute("RaftSessionId")
    if id == nil and model and model.Name:sub(1, 9) == "TeamRaft_" then
        id = model.Name:sub(10)
    end
    return id and tostring(id) or nil
end

-- Other crews' rafts share the folder, so a deck is only trusted (and cached) once it is known to be ours
function rafting.getRaftDeck()
    local sessionId = rafting.sessionId or (rafting.currentSnapshot and rafting.currentSnapshot.Id)
    sessionId = sessionId and tostring(sessionId) or nil
    local cached, cachedModel = rafting.deckPart, rafting.raftModel
    if cached and cached.Parent and cachedModel and cachedModel.Parent then
        local owner = rafting.deckSessionOf(cached, cachedModel)
        if not (sessionId and owner and owner ~= sessionId) then
            return cached, cachedModel
        end
    end
    rafting.deckPart = nil
    rafting.raftModel = nil

    local candidates = {}
    if char then
        local cowDeck = char:FindFirstChild("CowRaftingDeck")
        if cowDeck and cowDeck:IsA("ObjectValue") and cowDeck.Value and cowDeck.Value:IsA("BasePart") then
            table.insert(candidates, cowDeck.Value)
        end
    end
    local fjordFolder = workspace:FindFirstChild("FjordRafting") or (workspace:FindFirstChild("CowWorld") and workspace.CowWorld:FindFirstChild("FjordRafting"))
    local folders = fjordFolder and { fjordFolder, workspace } or { workspace }
    for _, folder in ipairs(folders) do
        if sessionId then
            local model = folder:FindFirstChild("TeamRaft_" .. sessionId)
            local deck = model and model:FindFirstChild("Deck")
            if deck then table.insert(candidates, deck) end
        end
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and (child.Name:sub(1, 9) == "TeamRaft_" or folder == fjordFolder) then
                local deck = child:FindFirstChild("Deck")
                if deck then table.insert(candidates, deck) end
            end
        end
    end

    local fallback
    for _, deck in ipairs(candidates) do
        if deck:IsA("BasePart") and deck.Parent then
            local owner = rafting.deckSessionOf(deck, deck.Parent)
            if sessionId and owner == sessionId then
                rafting.deckPart = deck
                rafting.raftModel = deck.Parent
                return deck, deck.Parent
            elseif not fallback and (not sessionId or not owner) then
                fallback = deck
            end
        end
    end
    -- Unverified match: usable this call, never cached, so the next call re-checks once the session id arrives
    if fallback then
        return fallback, fallback.Parent
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

-- A cave can have several entrances. Use one that opens onto the channel the site's corridor arrives in,
-- and the widest of those: a 32-long raft fits a 120-wide door far more reliably than a 42-wide one.
function rafting.pickCaveEntrance(siteId, coves)
    local caveSub = string.gsub(siteId, "^Cave_", "")
    local corridor = rafting.siteCorridors and rafting.siteCorridors[siteId]
    local arrivalZ = nil
    if corridor then
        local lastReach = 0
        for reachIdx, chZ in pairs(corridor) do
            if reachIdx > lastReach then
                lastReach = reachIdx
                arrivalZ = chZ
            end
        end
    end

    local best, bestFacing, bestWidth = nil, false, -1
    for _, c in ipairs(coves) do
        local owner = c[6] == "Cave" and string.match(c[7], "^(.-)::")
        if owner == caveSub or (caveSub == "12" and owner == "Cubby06") then
            local facing = arrivalZ ~= nil and math.abs(c[2] - arrivalZ) <= 90
            if (facing and not bestFacing) or (facing == bestFacing and c[3] > bestWidth) then
                best, bestFacing, bestWidth = c, facing, c[3]
            end
        end
    end
    return best
end

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
        if kind == "Cave" then
            matchedCove = rafting.pickCaveEntrance(sid, coves)
        else
            local clearingSub = string.gsub(sid, "^Clearing_", "")
            for _, c in ipairs(coves) do
                if c[6] == kind and c[7] == clearingSub then
                    matchedCove = c
                    break
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
        elseif sid == "Clearing_09" then
            bank = "South"
            coveX = 6014.58
            coveZ = -772.66
            mouthZ = -885.26
            mouthPos = Vector3.new(5920.0, 700.5, mouthZ)
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
            MouthHalfWidth = matchedCove and (matchedCove[3] * 0.5) or nil,
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
            -- Only straight channels define a fork: HalfLength on a diagonal runs along its sloped axis
            if math.abs(ch[4] or 0) < 0.001 then
                local endX = ch[1] + ch[5]
                if not reachData.forkX[rIdx] or endX > reachData.forkX[rIdx] then
                    reachData.forkX[rIdx] = endX
                end
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

function rafting.findChannel(reachIdx, nominalChZ)
    if not (FjordZones and FjordZones.Channels and nominalChZ) then return nil end
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
    return bestCh
end

function rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)
    if not nominalChZ then return -37.81 end
    local ch = rafting.findChannel(reachIdx, nominalChZ)
    if ch then
        local dirX = ch[3] or 1
        local dirZ = ch[4] or 0
        if math.abs(dirX) > 0.01 and math.abs(dirZ) > 0.001 and posX then
            return ch[2] + (dirZ / dirX) * (posX - ch[1])
        end
        return ch[2]
    end
    return nominalChZ
end

-- Centre line the raft should follow on a route. Differs from the geometric centre in two places:
-- * Crossovers overlap the middle channel before they cross it, so hold the middle until the crossing.
-- * Diagonals leave a fork from the same centre as the straight branch, so start on the branch's own
--   side and ease back, putting the hull on the correct side of the divider before it begins.
function rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)
    local center = rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)
    local ch = rafting.findChannel(reachIdx, nominalChZ)
    local dirZ = ch and ch[4] or 0
    if math.abs(dirZ) < 0.001 then return center end

    if type(ch[8]) == "string" then
        local middleZ = (FjordZones and FjordZones.CenterlineZ) or -37.81
        return if dirZ < 0 then math.min(center, middleZ) else math.max(center, middleZ)
    end

    local prevForkX = reachIdx > 1 and getReachData().forkX[reachIdx - 1]
    if prevForkX and posX then
        local past = posX - prevForkX
        if past >= -0.5 and past < 200 then
            local side = if dirZ < 0 then -25 else 25
            return center + side * (1 - math.max(past, 0) / 200)
        end
    end
    return center
end

-- Channel the raft is physically in. Uses the nearest route centre rather than FjordZones.ChannelAt,
-- which returns the first overlapping rectangle and so picks the north branch at every fork.
-- Returns axisX, axisZ, cross-channel offset, along-channel offset; a straight +X axis outside a channel.
function rafting.channelFrame(posX, posZ)
    local chZ, reachIdx = rafting.getCurrentChannel(posX, posZ)
    local ch = rafting.findChannel(reachIdx, chZ)
    if ch then
        local dx = posX - ch[1]
        local dz = posZ - ch[2]
        local along = dx * ch[3] + dz * ch[4]
        local cross = -dx * ch[4] + dz * ch[3]
        if math.abs(along) <= ch[5] + 10 and math.abs(cross) <= ch[6] + 10 then
            return ch[3], ch[4], cross, along
        end
    end
    return 1, 0, nil, nil
end

function rafting.getCurrentChannel(posX, posZ)
    local reachIdx = getReachIndex(posX)
    local channels = reachChannelZ[reachIdx] or { -37.81 }
    local bestZ = channels[1]
    local minDiff = math.huge
    local z = posZ or -37.81
    local middleZ = (FjordZones and FjordZones.CenterlineZ) or -37.81
    for _, chZ in ipairs(channels) do
        -- A crossover overlaps the middle channel, so a raft inside the middle channel is in the middle channel
        local ch = rafting.findChannel(reachIdx, chZ)
        local isCrossover = ch and type(ch[8]) == "string"
        if not (isCrossover and math.abs(z - middleZ) <= 54.65) then
            local centerZ = rafting.getRouteCenterZ(reachIdx, chZ, posX)
            local diff = math.abs(centerZ - z)
            if diff < minDiff then
                minDiff = diff
                bestZ = chZ
            end
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
    -- Clearing 07 opens onto the 862 channel (its MaxZ is that channel's north wall), not the 412 channel
    ["Clearing_07"] = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 637.19,  [5] = 862.19 },
    ["Clearing_08"] = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 637.19,  [5] = 862.19 },

    -- Level 4 Terminus (Reach 7)
    ["Cave_Cubby05"]      = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -712.81, [5] = -937.81, [6] = -937.81,  [7] = -937.81 },
    ["Clearing_09"]       = { [1] = -37.81, [2] = -262.81, [3] = -487.81, [4] = -712.81, [5] = -937.81, [6] = -937.81,  [7] = -937.81 },
    -- Clearing 10 opens onto the centre channel (its MaxZ is that channel's north wall), not the -487 channel
    ["Clearing_10"]       = { [1] = -37.81, [2] = -37.81,  [3] = -37.81,  [4] = -37.81,  [5] = -37.81,  [6] = -37.81,   [7] = -37.81 },
    ["Cave_11"]           = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 412.19,  [5] = 412.19,  [6] = 412.19,   [7] = 412.19 },
    ["Cave_12"]           = { [1] = -37.81, [2] = 187.19,  [3] = 412.19,  [4] = 637.19,  [5] = 862.19,  [6] = 1087.19,  [7] = 1312.19 },
}
rafting.siteCorridors = siteCorridors

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

    -- Branches overlap for the first stretch past a fork, so the raft can be in several channels at once.
    -- The site is reachable if any of them leads to it.
    local curChZ, curReach = rafting.getCurrentChannel(posX, currentZ)
    if rafting.channelLeadsToSite(curChZ, curReach, site, mouthX) then
        return true
    end
    if FjordZones and FjordZones.Channels then
        for _, ch in ipairs(FjordZones.Channels) do
            if not ch[8] then
                local dx, dz = posX - ch[1], currentZ - ch[2]
                if math.abs(dx * ch[3] + dz * ch[4]) <= ch[5] and math.abs(-dx * ch[4] + dz * ch[3]) <= ch[6]
                    and rafting.channelLeadsToSite(ch[2], ch[7], site, mouthX) then
                    return true
                end
            end
        end
    end
    return false
end

function rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)
    local sReach = siteReach[site.Id] or getReachIndex(mouthX)

    if curReach > sReach then
        return false
    end

    local corridors = siteCorridors[site.Id]
    local siteTargetChZ = corridors and corridors[sReach]

    if curReach == sReach then
        if siteTargetChZ and math.abs(curChZ - siteTargetChZ) > 40 then
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

-- Logs each change of steering target, with the selected sites already marked visited, so a skipped dock
-- shows whether it was never chosen, marked visited early, or dropped mid-approach.
function rafting.logTargetChange(site, posX, posZ)
    local siteId = site and site.Id or "none"
    if siteId == rafting.lastTargetId then return end
    rafting.lastTargetId = siteId
    local visited = {}
    for id in pairs(rafting.visitedSites or {}) do
        local s = rafting.sitesById and rafting.sitesById[id]
        if s and rafting.isSiteSelected(s) then table.insert(visited, id) end
    end
    table.sort(visited)
    rafting.telemetryEvent("RaftTarget", {
        Site = siteId,
        X = math.floor(posX + 0.5),
        Z = math.floor(posZ + 0.5),
        Visited = table.concat(visited, " "),
        Abandoned = rafting.abandonedSiteId,
    })
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

    -- End Cave fallback ONLY if route explicitly specifies caves OR site was selected by user
    local routeWantsCaves = string.find(route, "Leftmost", 1, true) or string.find(route, "North Channels", 1, true)
    local cubby05 = rafting.sitesById["Cave_Cubby05"]
    local userSelectedCubby05 = cubby05 and rafting.isSiteSelected(cubby05)
    if (routeWantsCaves or userSelectedCubby05) and cubby05 and not rafting.visitedSites[cubby05.Id] and posX <= (cubby05.MaxX or cubby05.MinX) + 25 and rafting.isSiteReachable(cubby05, posX, currentZ) then
        rafting.isSelfCorrecting = false
        return cubby05
    end

    local routeWantsSouthCaves = string.find(route, "South Channels", 1, true)
    local southCave = rafting.sitesById["Cave_12"] or rafting.sitesById["Cave_11"]
    local userSelectedSouthCave = southCave and rafting.isSiteSelected(southCave)
    if (routeWantsSouthCaves or userSelectedSouthCave) and southCave and not rafting.visitedSites[southCave.Id] and posX <= (southCave.MaxX or southCave.MinX) + 25 and rafting.isSiteReachable(southCave, posX, currentZ) then
        rafting.isSelfCorrecting = false
        return southCave
    end

    -- Opportunistic Self-Correction Fallback:
    -- Only run when no specific sites are selected (e.g. general exploration or selectAllSites/selectAllClearings)
    local hasSpecificSelections = rafting.selectedClearings and next(rafting.selectedClearings) ~= nil and not (rafting.selectAllSites or rafting.selectAllClearings)
    if not hasSpecificSelections and rafting.allSites then
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
        return getHarbourZ(posX)
    end
    local riverZ = rafting.getRiverTargetZ(posX, currentZ, clearances)
    -- Ease from the ribbon onto the river route so the hand-over is not a step in the steering target
    if posX < 400 then
        local rawT = (posX - 200) / 200
        local t = (1 - math.cos(rawT * math.pi)) * 0.5
        local harbourZ = getHarbourZ(posX)
        return harbourZ + t * (riverZ - harbourZ)
    end
    return riverZ
end

function rafting.getRiverTargetZ(posX, currentZ, clearances)
    -- If currently inside or departing a visited clearing cove, steer back towards the reach channel
    local departSiteId = rafting.currentDockSite or rafting.lastDepartSite
    local departSite = departSiteId and (rafting.sitesById[departSiteId] or rafting.getClearingById(departSiteId))
    if departSite then
        local isDeparting = (os.clock() - (rafting.lastCastOffTime or 0)) < 6.0
        local insideCoveBounds = posX >= (departSite.MinX - 60) and posX <= (departSite.MaxX + 40)
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
        local curCenterZ = rafting.getRouteCenterZ(rIdx, curChZ, posX)
        local forkX = rd.forkX[rIdx]
        local forkLead = 320.0
        if forkX and posX >= (forkX - forkLead) and posX <= forkX then
            local nextReach = math.min(rIdx + 1, rd.maxReach)
            local nextChZ = getDownstreamChannelZ(rIdx, curChZ, r)
            local targetThroatZ = rafting.getRouteCenterZ(nextReach, nextChZ, forkX)
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
    local currentChZ = rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)

    -- Physical channel clamp: prevent commanding cross-canyon Z if raft is in a different branch.
    -- Suppressed during fork transitions (320 studs before fork and 150 studs after fork).
    local physicalChZ = rafting.getCurrentChannel(posX, currentZ)
    local forkX = rd.forkX[reachIdx]
    local nearFork = (forkX and posX >= (forkX - 320)) or (reachIdx > 1 and posX <= ((rd.forkX[reachIdx - 1] or 0) + 150))
    if not nearFork and math.abs(physicalChZ - nominalChZ) > 40 then
        currentChZ = rafting.getRouteCenterZ(reachIdx, physicalChZ, posX)
        nominalChZ = physicalChZ
    end

    -- Bank-Side Channel Lane Biasing: Pre-align raft with target site's bank side (North/South lane)
    local bankLaneOffset = if targetSite.BankSide == "North" then -10.0 else 10.0
    -- Fade the lane in and out around forks so entering or leaving a fork zone is not a 10-stud step
    local laneWeight = 0
    if not nearFork and math.abs(physicalChZ - nominalChZ) <= 40 then
        laneWeight = 1
        if forkX then
            laneWeight = math.min(laneWeight, math.clamp((forkX - 320 - posX) / 100, 0, 1))
        end
        if reachIdx > 1 and rd.forkX[reachIdx - 1] then
            laneWeight = math.min(laneWeight, math.clamp((posX - (rd.forkX[reachIdx - 1] + 150)) / 100, 0, 1))
        end
    end
    local channelBaselineZ = currentChZ + bankLaneOffset * laneWeight

    -- Pre-Fork Spline Guidance: smooth continuous S-curve into the next reach channel (320 studs lead)
    local forkLead = 320.0
    if forkX and posX >= (forkX - forkLead) and posX <= forkX then
        local nextReach = math.min(reachIdx + 1, rd.maxReach)
        local nextNominalZ = (corridors and corridors[nextReach]) or getDownstreamChannelZ(reachIdx, nominalChZ, r)
        local targetThroatZ = rafting.getRouteCenterZ(nextReach, nextNominalZ, forkX)
        local rawT = math.clamp((posX - (forkX - forkLead)) / forkLead, 0, 1)
        local t = (1 - math.cos(rawT * math.pi)) * 0.5
        channelBaselineZ = currentChZ + t * (targetThroatZ - currentChZ)
    end

    -- Two-Stage Cove Approach:
    if targetSite.Id == "Clearing_09" then
        local fork6X = 5844.58
        -- Before Fork 6 in Reach 6: stay safely inside Channel 2, bias smoothly towards South lane (-925.0)
        if posX >= (fork6X - 250.0) and posX < fork6X then
            local rawT = math.clamp((posX - (fork6X - 250.0)) / 250.0, 0, 1)
            local t = (1 - math.cos(rawT * math.pi)) * 0.5
            return currentChZ + t * (-925.0 - currentChZ)
        end
        -- Past Fork 6 into Clearing 09: smoothly track through mouth opening directly to interior landing dock
        if posX >= fork6X and posX <= (maxX + 25) then
            local leadIn = math.max(1.0, (maxX + 25) - fork6X)
            local rawT = math.clamp((posX - fork6X) / leadIn, 0, 1)
            local t = (1 - math.cos(rawT * math.pi)) * 0.5
            return -925.0 + t * (shoreZ - (-925.0))
        end
    else
        local approachLead = 360.0
        local targetLeadZ = mouthZ
        if targetSite.Kind == "Cave" then
            -- Blend mouth with interior for cubbies so trajectory angles directly into throat
            targetLeadZ = mouthZ * 0.7 + shoreZ * 0.3
        end
        -- Stage 1 (Approaching mouth from river): align with mouth opening in river bank.
        -- A mouth just past a fork must wait for the fork, or the blend cuts the corner into the divider.
        local approachStartX = mouthX - approachLead
        local mouthReach = getReachIndex(mouthX)
        local mouthPrevForkX = mouthReach > 1 and rd.forkX[mouthReach - 1]
        if mouthPrevForkX and mouthPrevForkX > approachStartX and mouthPrevForkX < mouthX then
            approachStartX = mouthPrevForkX
        end
        if posX >= approachStartX and posX < mouthX then
            local rawT = math.clamp((posX - approachStartX) / (mouthX - approachStartX), 0, 1)
            local t = (1 - math.cos(rawT * math.pi)) * 0.5
            local approachZ = channelBaselineZ + t * (targetLeadZ - channelBaselineZ)
            -- Until the whole hull is past the start of the opening, keep it clear of the facade beside it:
            -- 6 studs of panel thickness + 7 of half-beam. The stern needs 16 more studs (half-length).
            local openingStartX = mouthX - (targetSite.MouthHalfWidth or 0) + 16
            local laneCh = rafting.findChannel(reachIdx, nominalChZ)
            if laneCh and posX < openingStartX then
                local clearHalfWidth = (laneCh[6] - 13) / math.max(laneCh[3], 0.1)
                approachZ = math.clamp(approachZ, currentChZ - clearHalfWidth, currentChZ + clearHalfWidth)
            end
            return approachZ
        end
        -- Stage 2 (Passing through mouth into interior): steer from mouth to landing dock
        if posX >= mouthX and posX <= (maxX + 25) then
            local leadIn = math.max(1.0, (maxX + 25) - mouthX)
            local rawT = math.clamp((posX - mouthX) / leadIn, 0, 1)
            local t = (1 - math.cos(rawT * math.pi)) * 0.5
            return targetLeadZ + t * (shoreZ - targetLeadZ)
        end
    end

    return channelBaselineZ
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

    -- ComputeAsync has no timeout of its own and the caller holds the loot lock, so wait for it 2.5 s at most
    -- and walk straight there otherwise
    local path = nil
    if PathfindingService then
        local candidate, computed = nil, false
        local fromPos = root.Position
        task.spawn(function()
            pcall(function()
                candidate = PathfindingService:CreatePath({
                    AgentRadius = 3.0,
                    AgentHeight = 5.0,
                    AgentCanJump = true,
                    WaypointSpacing = 4.0,
                    Costs = { Water = math.huge }
                })
                candidate:ComputeAsync(fromPos, targetWorldPos)
            end)
            computed = true
        end)
        local computeStart = os.clock()
        while not computed and (os.clock() - computeStart) < 2.5 do task.wait(0.05) end
        if computed then path = candidate end
    end

    if path and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        -- Each waypoint may take 2 s, so bound the whole walk as well
        local walkDeadline = os.clock() + timeout + (root.Position - targetWorldPos).Magnitude / 12
        for _, wp in ipairs(waypoints) do
            if not root or not humanoid then return false end
            if os.clock() > walkDeadline then break end
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
    rafting.dockedStartTime = nil
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
        else
            if deck then placeCowAboveDeck(deck) end
            sendRaftKey(Enum.KeyCode.N, 0.25)
        end

        -- A dock only answers Continue. Sail is for Boarding and Ready, and at a dock just gets
        -- "Board the raft before setting sail" back. The key above worked at every logged dock, so these
        -- are fallbacks for when it did not.
        local departCommand = if wasDocked then "Continue" else "Sail"
        local function stillWaiting()
            local current = rafting.currentSnapshot
            return current and (current.Status == "Docked" or current.Status == "Ready")
        end
        task.wait(0.8)
        if stillWaiting() then
            triggerRaftingCommand(departCommand)
            task.wait(0.8)
            if stillWaiting() then
                rafting.fireRemoteSafely(departCommand, nil, 0.5)
            end
        end

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
end

function rafting.handleHobgoblinLanded(landed)
    if not landed or typeof(landed) ~= "table" or not landed.Id then return end
    rafting.incomingRocks[landed.Id] = nil
    if landed.Hit then
        rafting.lastRockHitTime = os.clock()
    end
end

-- Hull size as rocks see it, measured from 56 logged rocks: every hit landed within 30 studs along the hull
-- and 9 across it, though the deck itself is only 32 x 14. Across includes margin for prediction error.
local ROCK_HALF_LENGTH = 31
local ROCK_HALF_BEAM = 11.5
local STEER_SPEED = 10
local STEER_LAG = 0.3 -- seconds for the cow to reach a new deck position
local DECK_STEER_RANGE = 5.8

function rafting.getRockThreats(deck)
    local threats = {}
    local rocks = rafting.incomingRocks
    if not rocks or not rafting.autoEvadeHobgoblins then return threats end

    local snap = rafting.currentSnapshot
    local speed = (snap and snap.Speed) or 0
    local serverNow = workspace:GetServerTimeNow()
    local clockNow = os.clock()
    for rockId, rock in pairs(rocks) do
        local flight = rock.Flight or 1.9
        local timeLeft = if rock.ReleaseAt then rock.ReleaseAt + flight - serverNow else flight - (clockNow - (rock.ReceivedAt or clockNow))
        if timeLeft < -0.5 or timeLeft > 6 then
            rocks[rockId] = nil
        elseif timeLeft > 0.05 and typeof(rock.Landing) == "Vector3" then
            local rel = deck.CFrame:PointToObjectSpace(rock.Landing)
            if math.abs(-rel.Z - speed * timeLeft) <= ROCK_HALF_LENGTH then
                table.insert(threats, { across = rel.X, timeLeft = timeLeft })
            end
        end
    end
    return threats
end

-- Leaves the wanted deck position alone unless it ends in a rock hit, and then moves it as little as clears
-- every rock in flight. Checking the wanted course is what stops a dodge or a lane return steering into a
-- second rock, which is how most logged hits happened.
-- Route error (studs) beyond which a dodge may ease the correction but not reverse it
rafting.ROCK_COMMIT_ERROR = 25

function rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)
    local threats = rafting.getRockThreats(deck)
    if #threats == 0 then
        rafting.isEvadingRock = false
        return wantedDeckX, false
    end

    local snap = rafting.currentSnapshot
    local steerNow = (snap and snap.Steering) or 0
    local function penalty(steer)
        local cost, wallMove = 0, 0
        for _, threat in ipairs(threats) do
            local lag = math.min(STEER_LAG, threat.timeLeft)
            local moved = STEER_SPEED * (steerNow * lag + steer * (threat.timeLeft - lag))
            if math.abs(threat.across - moved) <= ROCK_HALF_BEAM then
                cost = cost + 1
            end
            if math.abs(moved) > math.abs(wallMove) then wallMove = moved end
        end
        -- A crash costs about what a rock does, and also stops the raft
        local room = if wallMove < 0 then leftClear else rightClear
        if room - 7 - math.abs(wallMove) < 2 then
            cost = cost + 1
        end
        return cost
    end

    local wantedSteer = math.clamp(wantedDeckX / DECK_STEER_RANGE, -1, 1)
    local bestSteer, bestCost = wantedSteer, penalty(wantedSteer)
    if bestCost == 0 then
        rafting.isEvadingRock = false
        return wantedDeckX, false
    end
    for _, steer in ipairs({ 0, 0.35, -0.35, 0.7, -0.7, 1, -1 }) do
        local allowed = not isCommitted or wantedSteer == 0 or (steer * wantedSteer > 0 and math.abs(steer) >= 0.7)
        local cost = if allowed then penalty(steer) else math.huge
        if cost < bestCost or (cost == bestCost and math.abs(steer - wantedSteer) < math.abs(bestSteer - wantedSteer)) then
            bestSteer, bestCost = steer, cost
        end
    end
    rafting.isEvadingRock = bestSteer ~= wantedSteer
    return bestSteer * DECK_STEER_RANGE, rafting.isEvadingRock
end

rafting.CHEST_RETRY_NOTICES = { ChestBlocked = true, ApproachChest = true }
rafting.CHEST_DONE_NOTICES = { ChestAlreadyClaimed = true, ChestUnavailable = true }
rafting.CHEST_ABORT_NOTICES = { NotAtRaftingStop = true, InventoryFull = true }

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
                if tName == "RewardBoxReveal" then
                    local panel = rGui:FindFirstChild("Backdrop") and rGui.Backdrop:FindFirstChild("Panel")
                    if rGui:GetAttribute("RewardBox") ~= nil or (panel and panel:IsA("CanvasGroup") and panel.GroupTransparency < 0.9) then
                        isTargetActive = true
                    end
                else
                    isTargetActive = true
                end
            end
        end)
        if isTargetActive then
            local descs = nil
            pcall(function() descs = rGui:GetDescendants() end)
            if descs then
                for _, desc in ipairs(descs) do
                    if isRewardDismissButton(desc) then
                        if activateGuiButton(desc, vi) then
                            dismissed = true
                        end
                    end
                end
            end
            if dismissed or (rGui:GetAttribute("RewardBox") ~= nil) then
                if vi and vi.SendKeyEvent then
                    pcall(function()
                        vi:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                        task.wait(0.04)
                        vi:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                    end)
                end
                pcall(function() rGui.Enabled = false end)
                dismissed = true
            end
        end
    end

    -- 2. General search across reward ScreenGuis and BillboardGuis
    local children = nil
    pcall(function() children = pg:GetChildren() end)
    if children then
        local ignoredGuiNames = {
            rayfield = true, cowhub = true, fjordraftinghud = true, trickortreatsign = true,
            fieldhud = true, barnbook = true, quickmenus = true, adminpanel = true,
            herdmenu = true, updatesmenu = true, cosmeticdetail = true, playermailbox = true,
            npcshoppanel = true, plotpanel = true, constructionpanel = true, atlaspage = true,
            gardenpanel = true, robloxgui = true, chat = true
        }
        for _, gui in ipairs(children) do
            local canCheck = false
            local gName = ""
            pcall(function()
                if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                    gName = gui.Name:lower()
                    if not ignoredGuiNames[gName] and not gName:find("rayfield") and not gName:find("cowhub") and not gName:find("hud") then
                        if gui:GetAttribute("RewardBox") ~= nil
                            or gName:find("reward") or gName:find("reveal") or gName:find("chest")
                            or gName:find("crate") or gName:find("prize") or gName:find("loot") then
                            canCheck = true
                        end
                    end
                end
            end)
            if canCheck then
                local descs = nil
                pcall(function() descs = gui:GetDescendants() end)
                if descs then
                    for _, desc in ipairs(descs) do
                        if isRewardDismissButton(desc) then
                            if activateGuiButton(desc, vi) then
                                dismissed = true
                            end
                        end
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
        end)
    end
end)

function rafting.lootSingleSite(targetSite)
    if not root or not targetSite or rafting.cancelLooting or rafting.isEndingVoyage then return false end
    local landPos = targetSite.LandPos or Vector3.new((targetSite.MinX + targetSite.MaxX) * 0.5, targetSite.FloorY + 2.5, (targetSite.MinZ + targetSite.MaxZ) * 0.5)

    -- Request stream replication for distant / unrendered clearings. In its own thread: the call yields, and
    -- the snapshot poll below already waits for the site.
    rafting.lootStep = "Stream " .. targetSite.Id
    task.spawn(pcall, function()
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp.RequestStreamAroundAsync then
            lp:RequestStreamAroundAsync(landPos, 5)
        end
    end)

    rafting.lootStep = "Land " .. targetSite.Id
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

    -- Only this site's own snapshot names its chest. The LocalTeamChest model and the latest snapshot can still
    -- belong to the previous site, which opened the wrong chest and marked this one as looted.
    local chest, wasOpened
    rafting.lootStep = "Snapshot " .. targetSite.Id
    local pollStart = os.clock()
    while (os.clock() - pollStart) < 4.0 do
        if rafting.cancelLooting or rafting.isEndingVoyage then return false end
        chest, wasOpened = rafting.findSiteChest(targetSite.Id)
        if chest or wasOpened then break end
        task.wait(0.1)
    end

    local result = if wasOpened then "AlreadyOpen" else "NoSnapshot"
    local attempts = 0
    while chest and attempts < 3 and not (rafting.cancelLooting or rafting.isEndingVoyage or rafting.abortSweep) do
        attempts = attempts + 1
        rafting.lootStep = "Open " .. targetSite.Id
        local opened, detail = rafting.openChest(chest)
        result = detail
        if not opened then
            -- A second chest at the site still gets its own try, but this one has used up its positions
            break
        end
        task.wait(0.2)
        chest, wasOpened = rafting.findSiteChest(targetSite.Id)
    end
    rafting.telemetryEvent("TeamChestResult", { Site = targetSite.Id, Result = result })

    local looted = (not chest) and (wasOpened or result == "Opened" or result == "AlreadyClaimed")
    if looted then
        rafting.lootedChestSites[targetSite.Id] = true
        rafting.visitedSites[targetSite.Id] = true
    end
    return looted
end

function rafting.findSiteChest(siteId)
    local chestSnap = rafting.chestSnapshots and rafting.chestSnapshots[siteId]
    if not chestSnap or not chestSnap.Chests then return nil, false end
    local anyOpened = false
    for _, chest in ipairs(chestSnap.Chests) do
        if not chest.Opened and not (rafting.chestRewards and rafting.chestRewards[chest.Id]) then
            return chest, false
        end
        anyOpened = true
    end
    return nil, anyOpened
end

-- Waits for the server's answer to a chest request. Returns "Opened", "AlreadyClaimed", "Retry", "Abort" or nil.
function rafting.awaitChestOutcome(chest, timeout)
    local start = os.clock()
    while (os.clock() - start) < timeout do
        if rafting.chestRewards[chest.Id] then return "Opened" end
        local chestSnap = rafting.chestSnapshots[rafting.siteIdOfChest(chest)]
        if chestSnap and chestSnap.Chests then
            for _, known in ipairs(chestSnap.Chests) do
                if known.Id == chest.Id and known.Opened then return "Opened" end
            end
        end
        local notice = rafting.lastChestNotice
        if notice then
            if rafting.CHEST_DONE_NOTICES[notice] then return "AlreadyClaimed" end
            if rafting.CHEST_RETRY_NOTICES[notice] then return "Retry" end
            if rafting.CHEST_ABORT_NOTICES[notice] then return "Abort" end
        end
        task.wait(0.08)
    end
    return nil
end

function rafting.siteIdOfChest(chest)
    return string.match(tostring(chest.Id), ":([^:]+):%d+$") or ""
end

-- Height of the root above the floor when the cow stands: ~4.8 on grass in the voyage logs
function rafting.cowStandHeight()
    local height = nil
    pcall(function()
        if humanoid and root and root:IsA("BasePart") and humanoid.HipHeight > 0 then
            height = humanoid.HipHeight + root.Size.Y * 0.5
        end
    end)
    if not height or height < 2.5 or height > 8 then height = 4.8 end
    return height
end

-- Places the cow standing on the chest's ground, facing it. The old spot was 1.5 above the chest pivot, which
-- is the ground itself, so the cow spawned ~3 studs into the floor and physics ejected it, often down under
-- the map: 98 of the logged ChestBlocked answers came with the cow FallingDown below ground.
function rafting.placeCowAtChest(chest, standPos)
    stopCharacterVelocity()
    local chestPos = chest.CFrame.Position
    root.CFrame = CFrame.lookAt(standPos, Vector3.new(chestPos.X, standPos.Y, chestPos.Z))
    if humanoid then
        pcall(function()
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Physics then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
        humanoid:Move(Vector3.zero, false)
        humanoid:MoveTo(root.Position)
    end
end

-- Stands beside the chest and opens it, trying other sides if the server says the spot is blocked or too far.
-- Only a reward, an opened snapshot or a "claimed" notice counts as done.
function rafting.openChest(chest)
    local remotes = cowRemotes or (game:GetService("ReplicatedStorage"):FindFirstChild("CowGame") and game.ReplicatedStorage.CowGame:FindFirstChild("Remotes"))
    local teamChestReq = remotes and remotes:FindFirstChild("TeamChestRequest")
    local standOffsets = { CFrame.new(0, 0, 3.5), CFrame.new(3.5, 0, 0), CFrame.new(-3.5, 0, 0), CFrame.new(0, 0, -3.5) }
    local groundY = tonumber(chest.GroundY) or chest.CFrame.Position.Y

    for _, offset in ipairs(standOffsets) do
        if rafting.cancelLooting or rafting.isEndingVoyage or not root then return false, "Cancelled" end
        local standHeight = rafting.cowStandHeight()
        local flat = (chest.CFrame * offset).Position
        local standPos = Vector3.new(flat.X, groundY + standHeight + 0.3, flat.Z)
        if rafting.naturalMode then
            naturalWalkTo(standPos, 8.0, 3.0)
        else
            rafting.placeCowAtChest(chest, standPos)
        end
        -- Paced chest settle: the server must see the new position before the request arrives
        task.wait(0.7)
        -- Sank or knocked over anyway: put it back on its feet before asking
        if not rafting.naturalMode and root and root.Position.Y < groundY + standHeight - 1.5 then
            rafting.placeCowAtChest(chest, standPos)
            task.wait(0.5)
        end

        rafting.lastChestNotice = nil
        local outcome = nil
        local model = workspace:FindFirstChild("LocalTeamChest", true)
        if model and model:IsA("Model") and (model:GetPivot().Position - chest.CFrame.Position).Magnitude < 8
            and triggerChestNatively(model) then
            outcome = rafting.awaitChestOutcome(chest, 1.0)
        end
        if not outcome and teamChestReq then
            pcall(function() teamChestReq:FireServer(chest.Id) end)
            outcome = rafting.awaitChestOutcome(chest, 1.5)
        end

        if outcome == "Opened" then
            task.wait(0.8) -- Wait for chest celebration / hat animation
            rafting.pollRewardGuiUntilDismissed(8.0)
            task.wait(0.4)
            return true, "Opened"
        elseif outcome == "AlreadyClaimed" then
            rafting.chestRewards[chest.Id] = true
            return true, "AlreadyClaimed"
        elseif outcome == "Abort" then
            rafting.abortSweep = true
            return false, tostring(rafting.lastChestNotice)
        end
    end
    return false, "NoResponse"
end

-- An error inside a spawned loot thread is otherwise silent and leaves isLootingChest set for good, which
-- also stops the steering and the dock watchdog. Two voyages sat docked at their first clearing this way.
function rafting.lootSiteGuarded(targetSite)
    local ok, result = pcall(rafting.lootSingleSite, targetSite)
    if not ok then
        rafting.telemetryEvent("RaftLootError", { Site = targetSite.Id, Step = rafting.lootStep, Error = tostring(result) })
        return false
    end
    return result
end

-- Backstop for a loot run that stalls anyway: past the deadline the cow is put back aboard and the raft sails on.
-- A full zone sweep takes about 30 s and a natural-mode walk about 25 s.
rafting.LOOT_DEADLINE = 90

function rafting.armLootDeadline(siteId)
    local run = (rafting.lootRun or 0) + 1
    rafting.lootRun = run
    rafting.lootStep = "Start"
    rafting.telemetryEvent("RaftLootStart", { Site = siteId, Sweep = rafting.collectAllLootChests and not rafting.naturalMode })
    task.delay(rafting.LOOT_DEADLINE, function()
        if rafting.lootRun ~= run then return end
        rafting.lootRun = run + 1
        rafting.abortSweep = true
        rafting.isLootingChest = false
        rafting.telemetryEvent("RaftLootTimeout", { Site = siteId, Step = rafting.lootStep })
        if rafting.enabled and rafting.isDockedState and not rafting.isEndingVoyage then
            local deck = rafting.getRaftDeck()
            if deck and root then placeCowAboveDeck(deck) end
            local rem = rafting.getRemote()
            if rem then pcall(function() rem:FireServer("Boarded") end) end
            rafting.isDockedState = false
            rafting.castOff()
        end
    end)
    return run
end

function rafting.sweepZoneChests(zoneNum, deck)
    if rafting.isLootingChest or not root or not zoneNum or rafting.cancelLooting or rafting.isEndingVoyage then return false end
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
    rafting.abortSweep = false
    task.spawn(function()
        for _, siteId in ipairs(zoneList) do
            if rafting.cancelLooting or rafting.isEndingVoyage or rafting.abortSweep then break end
            local targetSite = rafting.sitesById[siteId] or (rafting.getClearingById and rafting.getClearingById(siteId))
            if not targetSite and rafting.allSites then
                for _, s in ipairs(rafting.allSites) do
                    if s.Id == siteId then targetSite = s break end
                end
            end
            if targetSite and not rafting.lootedChestSites[siteId] then
                rafting.statusText = string.format("Zone %d Sweep: Looting %s...", zoneNum, targetSite.Name or siteId)
                rafting.updateCards()
                rafting.lootSiteGuarded(targetSite)
                task.wait(0.4)
            end
        end

        local deckRef = rafting.getRaftDeck() or curDeck
        if deckRef and root and not rafting.cancelLooting and not rafting.isEndingVoyage then
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
            local rem = rafting.getRemote()
            if rem then pcall(function() rem:FireServer("Boarded") end) end
        end

        rafting.isLootingChest = false
    end)
    return true
end

function rafting.findStation(snap, stationId)
    for _, station in ipairs((snap and snap.RepairStations) or {}) do
        if station.Id == stationId then return station end
    end
    return nil
end

-- The damaged station closest to where the cow already is, so steering is disturbed least
function rafting.pickDamagedStation(snap, cowRel)
    local best, bestDist = nil, math.huge
    for _, station in ipairs((snap and snap.RepairStations) or {}) do
        if station.Damaged and station.Id and typeof(station.Offset) == "Vector3" then
            local dist = math.abs(station.Offset.X - cowRel.X) + math.abs(station.Offset.Z - cowRel.Z)
            if dist < bestDist then
                best, bestDist = station, dist
            end
        end
    end
    return best
end

-- Energy to reach the sea at the current speed, plus enough left to leave a dock
function rafting.energyReserve(posX, snap)
    local cfg = rafting.gameConfig()
    local speed = math.max((snap and snap.Speed) or 0, 10)
    return math.max(0, 6594.58 - posX) / speed * cfg.EnergyDrainPerSecond + cfg.MinContinueEnergy
end

function rafting.gameConfig()
    if rafting.configCache then return rafting.configCache end
    local cfg = { EnergyDrainPerSecond = 0.75, MinContinueEnergy = 15, RepairHeartbeatSeconds = 0.18, RepairRange = 6.5 }
    pcall(function()
        local live = require(game:GetService("ReplicatedStorage").CowGame.Shared.RaftingConfig)
        for key in pairs(cfg) do
            if type(live[key]) == "number" then cfg[key] = live[key] end
        end
    end)
    rafting.configCache = cfg
    return cfg
end

function rafting.isHealthLow(hp, maxHp)
    -- The slider is in raft health, which is too little on a raft with hundreds of it
    return hp > 0 and hp <= math.max(rafting.emergencyReturnHp or 25, (maxHp or 0) * 0.15)
end

-- Runs in the looting thread, with the cow back aboard and the raft stopped.
function rafting.repairAtDock()
    if not rafting.autoRepair or os.clock() < (rafting.repairBlockedUntil or 0) then return end
    local rem = rafting.getRemote()
    if not rem then return end
    local cfg = rafting.gameConfig()

    for _ = 1, 4 do
        local snap = rafting.currentSnapshot
        local deck = rafting.getRaftDeck()
        if not snap or snap.Status ~= "Docked" or not deck or not root then break end
        if (snap.Health or 0) >= (snap.MaxHealth or 1) * 0.9 then break end
        if (snap.Energy or 0) < cfg.MinContinueEnergy + (snap.RepairEnergyCost or 5) + 30 then break end
        local cowRel = deck.CFrame:PointToObjectSpace(root.Position)
        local station = rafting.pickDamagedStation(snap, cowRel)
        if not station then break end

        rafting.statusText = string.format("Patching split beam %s...", tostring(station.Id))
        rafting.updateCards()
        stopCharacterVelocity()
        root.CFrame = deck.CFrame * CFrame.new(station.Offset.X, 5.4, station.Offset.Z)
        if humanoid then
            humanoid:Move(Vector3.zero, false)
            humanoid:MoveTo(root.Position)
        end
        task.wait(0.3)

        local before = snap.Health
        local finished = false
        pcall(function() rem:FireServer("RepairBegin", station.Id) end)
        local start = os.clock()
        while (os.clock() - start) < 5.0 and rafting.enabled and not rafting.cancelLooting do
            task.wait(cfg.RepairHeartbeatSeconds)
            pcall(function() rem:FireServer("RepairHeld", station.Id) end)
            local current = rafting.findStation(rafting.currentSnapshot, station.Id)
            if not current or not current.Damaged then
                finished = true
                break
            end
        end
        pcall(function() rem:FireServer("RepairRelease", station.Id) end)
        task.wait(0.3)
        rafting.telemetryEvent("RaftRepair", { Station = station.Id, Docked = true, Finished = finished,
            Before = before, After = rafting.currentSnapshot and rafting.currentSnapshot.Health })
        if not finished then
            -- Most likely out of driftwood. Do not hold up the voyage retrying.
            rafting.repairBlockedUntil = os.clock() + 60
            break
        end
    end

    local deckRef = rafting.getRaftDeck()
    if deckRef and root and not rafting.naturalMode then placeCowAboveDeck(deckRef) end
end

-- Patches while sailing: the cow only moves along the deck to the station's row. X stays with steering,
-- and the station stays in range across the whole steering width.
function rafting.stepRepairUnderway(snap, deck, posX, allowed)
    local rem = rafting.getRemote()
    local held = rafting.heldRepair
    local now = os.clock()
    local cfg = rafting.gameConfig()
    if held then
        local station = rafting.findStation(snap, held.Id)
        local timedOut = (now - held.StartedAt) > 6
        if not allowed or timedOut or not station or not station.Damaged then
            if rem then pcall(function() rem:FireServer("RepairRelease", held.Id) end) end
            rafting.telemetryEvent("RaftRepair", { Station = held.Id, Docked = false, Finished = not (station and station.Damaged),
                Before = held.Before, After = snap.Health })
            if timedOut then rafting.repairBlockedUntil = now + 60 end
            rafting.heldRepair = nil
            rafting.targetDeckZ = 0
        elseif rem and (now - held.LastPulseAt) >= cfg.RepairHeartbeatSeconds then
            held.LastPulseAt = now
            pcall(function() rem:FireServer("RepairHeld", held.Id) end)
        end
        return
    end

    rafting.targetDeckZ = 0
    if not rafting.autoRepair or not allowed or not rem or not root or now < (rafting.repairBlockedUntil or 0) then return end
    if (snap.Health or 0) >= (snap.MaxHealth or 1) * 0.7 then return end
    if (snap.Energy or 0) < rafting.energyReserve(posX, snap) + (snap.RepairEnergyCost or 5) + 10 then return end

    local cowRel = deck.CFrame:PointToObjectSpace(root.Position)
    local station = rafting.pickDamagedStation(snap, cowRel)
    if not station then return end
    rafting.targetDeckZ = station.Offset.Z
    local offX, offZ = station.Offset.X - cowRel.X, station.Offset.Z - cowRel.Z
    if math.sqrt(offX * offX + offZ * offZ) <= cfg.RepairRange - 0.5 then
        pcall(function() rem:FireServer("RepairBegin", station.Id) end)
        rafting.heldRepair = { Id = station.Id, StartedAt = now, LastPulseAt = now, Before = snap.Health }
    end
end

function rafting.lootReachChests(dockSite, deck)
    if rafting.isLootingChest or not root or not dockSite then return end
    local curDeck = deck or rafting.getRaftDeck()
    if not curDeck then return end

    task.spawn(function()
        local run = rafting.armLootDeadline(dockSite.Id)
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
                rafting.lootSiteGuarded(dockSite)
                task.wait(0.5)

                local deckRef = rafting.getRaftDeck() or curDeck
                if deckRef and root and not rafting.cancelLooting and not rafting.isEndingVoyage then
                    if rafting.naturalMode then
                        rafting.statusText = "Boarding raft..."
                        rafting.updateCards()
                        naturalWalkTo(deckRef.Position, 8.0, 3.5)
                    else
                        placeCowAboveDeck(deckRef)
                    end
                    task.wait(0.4)
                    rafting.dismissChestRewardGui()
                    local rem = rafting.getRemote()
                    if rem then pcall(function() rem:FireServer("Boarded") end) end
                end
                rafting.isLootingChest = false
            end
        end

        -- Past the deadline the raft has already sailed on without this run
        if rafting.lootRun ~= run then return end
        rafting.lootRun = run + 1
        rafting.telemetryEvent("RaftLootDone", { Site = dockSite.Id, Step = rafting.lootStep })

        -- Still flagged as looting, so the dock watchdog cannot cast off mid-patch
        rafting.isLootingChest = true
        pcall(rafting.repairAtDock)
        rafting.isLootingChest = false

        -- Check emergency docked: if health low or adrift, return to shore now that chests are looted.
        -- Below the energy needed to leave, the server will not let the raft continue either.
        local snap = rafting.currentSnapshot
        local isEmergency = rafting.emergencyDocked
            or (snap and snap.Health and rafting.isHealthLow(snap.Health, snap.MaxHealth))
            or (snap and snap.Adrift == true)
            or (snap and snap.Energy and snap.Energy < rafting.gameConfig().MinContinueEnergy)

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
                if rafting.enabled and (rafting.status == "Docked" or rafting.isDockedState) and not rafting.isLootingChest then
                    rafting.isDockedState = false
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

-- Voyage telemetry: appends to a workspace file so a crash, sink or logger backlog cannot lose the record.
-- Lines are "S,..." for samples (see the header line) and "E,..." for events.
rafting.telemetry = {
    fileName = nil,
    pending = {},
    allLines = {},
    lastSampleAt = 0,
    lastFlushAt = 0,
    lastSurveyAt = 0,
    lastObserved = {},
    knownKeys = {},
    lastCross = nil,
    lastCrossAt = 0,
    facades = nil,
    facadeCells = {},
    facadesDirty = false,
    facadesSavedAt = 0,
}

local telemetryIgnoredEvents = { RaftingSnapshot = true, RaftRiverLoad = true, RaftRiverKeep = true, RaftYard = true }

function rafting.telemetryText(value, depth)
    depth = depth or 0
    if type(value) ~= "table" then return tostring(value) end
    if depth >= 3 then return "{...}" end
    local parts = {}
    for k, v in pairs(value) do
        table.insert(parts, tostring(k) .. "=" .. rafting.telemetryText(v, depth + 1))
    end
    return "{" .. table.concat(parts, " ") .. "}"
end

function rafting.telemetryLine(line)
    local tel = rafting.telemetry
    if not tel.fileName then return end
    table.insert(tel.pending, line)
end

function rafting.telemetryFlush(force)
    local tel = rafting.telemetry
    local now = os.clock()
    if not tel.fileName or #tel.pending == 0 then return end
    if not force and (now - tel.lastFlushAt) < 5 then return end
    tel.lastFlushAt = now
    local chunk = table.concat(tel.pending, "\n") .. "\n"
    tel.pending = {}
    pcall(function()
        if appendfile then
            appendfile(tel.fileName, chunk)
        elseif writefile then
            -- No append support: rewrite the file, capped so a long voyage cannot stall on it
            table.insert(tel.allLines, chunk)
            if #tel.allLines > 400 then table.remove(tel.allLines, 1) end
            writefile(tel.fileName, table.concat(tel.allLines))
        end
    end)
end

function rafting.telemetryStart(sessionId)
    local tel = rafting.telemetry
    if not writefile then return end
    tel.fileName = resolveCowHubPath(string.format("cowhub_raft_%d_%s.log", os.time(), string.sub(tostring(sessionId), 1, 8)), "raftlogs")
    tel.pending = {}
    tel.allLines = {}
    tel.lastObserved = {}
    tel.knownKeys = {}
    tel.lastCross = nil
    pcall(function() writefile(tel.fileName, "") end)
    rafting.telemetryLine("H,t,x,z,headingDeg,cross,along,steering,targetDeckX,targetZ,errorZ,left,right,forward,status,health,energy,speed,crash,bump,weather,gust,drift,statusText")
    local cg = game:GetService("ReplicatedStorage"):FindFirstChild("CowGame")
    if cg then
        rafting.telemetryEvent("StormAttributes", {
            Seed = cg:GetAttribute("FjordStormSeed"),
            Epoch = cg:GetAttribute("FjordStormEpoch"),
            Mask = cg:GetAttribute("FjordStormMask"),
        })
    end
    rafting.telemetryFlush(true)
end

function rafting.telemetryEvent(name, payload)
    if not rafting.telemetry.fileName or telemetryIgnoredEvents[name] then return end
    if type(name) ~= "string" then return end
    local isRelevant = name == "SessionEnded" or name == "StormAttributes" or name == "Snapshot"
        or string.find(name, "Raft", 1, true) or string.find(name, "Storm", 1, true) or string.find(name, "TeamChest", 1, true)
        or string.find(name, "Hobgoblin", 1, true) or string.find(name, "Hazard", 1, true) or string.find(name, "Weather", 1, true)
    if not isRelevant then return end
    local ok, text = pcall(rafting.telemetryText, payload)
    rafting.telemetryLine(string.format("E,%.2f,%s,%s", os.clock(), name, ok and text or "?"))
    rafting.telemetryFlush(true)
end

-- Records snapshot transitions, and any snapshot field not seen before, as events.
function rafting.telemetryObserve(payload)
    local tel = rafting.telemetry
    if payload.Id and payload.Id ~= tel.sessionId then
        tel.sessionId = payload.Id
        rafting.telemetryStart(payload.Id)
    end
    if not tel.fileName then return end
    local seen = tel.lastObserved
    local changed = false
    for _, key in ipairs({ "Status", "Health", "CrashSerial", "BumpSerial", "Adrift", "Overboard", "LowEnergy", "Reach", "SiteKind", "Level", "AllAboard" }) do
        if payload[key] ~= seen[key] then
            rafting.telemetryLine(string.format("E,%.2f,Change,%s %s->%s", os.clock(), key, tostring(seen[key]), tostring(payload[key])))
            seen[key] = payload[key]
            changed = true
        end
    end
    for key in pairs(payload) do
        if not tel.knownKeys[key] then
            tel.knownKeys[key] = true
            rafting.telemetryLine(string.format("E,%.2f,NewKey,%s", os.clock(), tostring(key)))
        end
    end
    if changed and payload.Status == "Docked" then
        rafting.telemetryEvent("Snapshot", payload)
    end
    if changed then rafting.telemetryFlush(true) end
end

-- Current weather and predicted gust at a position, using the game's own rules. Logged only for now:
-- comparing the prediction with measured drift shows whether gusts can be fed into steering.
function rafting.telemetryWeather(pos)
    local tel = rafting.telemetry
    if tel.stormRules == nil then
        tel.stormRules = false
        pcall(function()
            local shared = game:GetService("ReplicatedStorage").CowGame.Shared
            tel.stormRules = require(shared.FjordStormRules)
        end)
    end
    if not tel.stormRules then return "?", 0 end
    local kind, gust = "Clear", 0
    pcall(function()
        local cg = game:GetService("ReplicatedStorage").CowGame
        local mask = cg:GetAttribute("FjordStormMask")
        local passage = tel.stormRules.WeatherAt(pos, mask)
        if passage then
            kind = tel.stormRules.Kind(passage, mask) or "Clear"
            local seed = cg:GetAttribute("FjordStormSeed")
            local epoch = cg:GetAttribute("FjordStormEpoch")
            if seed and epoch then
                gust = tel.stormRules.Gust(passage, seed, workspace:GetServerTimeNow() - epoch)
            end
        end
    end)
    return kind, gust
end

function rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)
    local tel = rafting.telemetry
    local now = os.clock()
    if not tel.fileName or (now - tel.lastSampleAt) < 0.2 then return end
    local dt = now - tel.lastSampleAt
    tel.lastSampleAt = now

    local ok, line = pcall(function()
        local pos = deck.Position
        local axisX, axisZ, cross, along = rafting.channelFrame(pos.X, pos.Z)
        local steering = snap.Steering or 0
        local drift = 0
        if cross and tel.lastCross and dt < 1 then
            drift = (cross - tel.lastCross) / dt - 10 * steering
        end
        tel.lastCross = cross
        local look = deck.CFrame.LookVector
        local kind, gust = rafting.telemetryWeather(pos)
        local left = math.min(clearances.LeftLateral or 45, clearances.LeftStern or 40)
        local right = math.min(clearances.RightLateral or 45, clearances.RightStern or 40)
        local forward = math.min(clearances.Forward or 110, clearances.ForwardLeft or 95, clearances.ForwardRight or 95)
        return string.format(
            "S,%.2f,%.1f,%.1f,%.1f,%.1f,%.1f,%.2f,%.2f,%.1f,%.1f,%.0f,%.0f,%.0f,%s,%s,%.0f,%.1f,%s,%s,%s,%.2f,%.1f,%s",
            now, pos.X, pos.Z, math.deg(math.atan2(look.Z, look.X)), cross or 0, along or 0, steering,
            rafting.targetDeckX or 0, targetZ, errorZ, left, right, forward, tostring(snap.Status), tostring(snap.Health),
            snap.Energy or 0, snap.Speed or 0, tostring(snap.CrashSerial), tostring(snap.BumpSerial), kind, gust, drift,
            (string.gsub(tostring(rafting.statusText or ""), ",", ";"))
        )
    end)
    if ok and line then rafting.telemetryLine(line) end
    rafting.telemetryFlush(false)

    if (now - tel.lastSurveyAt) >= 3 then
        tel.lastSurveyAt = now
        pcall(rafting.surveyFacades)
    end
end

-- Maps the cliff facades as streaming loads them, merged across voyages, so wall positions along the
-- whole river can be checked against the channel rectangles.
function rafting.surveyFacades()
    local tel = rafting.telemetry
    if not writefile then return end
    local fileName = resolveCowHubPath("cowhub_raft_facades.json")
    if not tel.facades then
        tel.facades = {}
        if isfile and readfile and isfile(fileName) then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
            if ok and type(decoded) == "table" then tel.facades = decoded end
        end
    end

    local fjord = workspace:FindFirstChild("FjordDelta") or (cache.cowWorldRef and cache.cowWorldRef:FindFirstChild("FjordDelta"))
    local wall = fjord and fjord:FindFirstChild("Cliff Wall")
    if not wall then return end
    for _, cell in ipairs(wall:GetChildren()) do
        local children = cell:GetChildren()
        if #children ~= tel.facadeCells[cell.Name] then
            tel.facadeCells[cell.Name] = #children
            for _, part in ipairs(children) do
                if part:IsA("BasePart") and not tel.facades[part.Name] then
                    local look = part.CFrame.LookVector
                    tel.facades[part.Name] = {
                        x = part.Position.X, y = part.Position.Y, z = part.Position.Z,
                        sx = part.Size.X, sy = part.Size.Y, sz = part.Size.Z,
                        yaw = math.deg(math.atan2(look.X, look.Z)),
                    }
                    tel.facadesDirty = true
                end
            end
        end
    end

    if tel.facadesDirty and (os.clock() - tel.facadesSavedAt) >= 15 then
        tel.facadesDirty = false
        tel.facadesSavedAt = os.clock()
        local encoded = HttpService:JSONEncode(tel.facades)
        writefile(fileName, encoded)
    end
end

function rafting.handleSnapshot(payload)
    if not payload or type(payload) ~= "table" then return end
    -- The server has closed this session; its late snapshots would restart steering on a finished voyage
    if payload.Id and payload.Id == rafting.endedSessionId then return end
    rafting.lastSnapshotTime = os.clock()
    if payload.Id and payload.Id ~= rafting.sessionId then
        rafting.sessionSeenAt = os.clock()
    end
    if payload.Id then
        rafting.lastSessionSnapAt = os.clock()
    end

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
        rafting.cancelLooting = false
        rafting.isEndingVoyage = false
        rafting.isEndingVoyageInProgress = false
        rafting.dockedStartTime = nil
        rafting.incomingRocks = {}
        rafting.isDockedState = false
        rafting.currentDockSite = nil
        rafting.lastLootedSite = nil
        -- Left over, this sends the raft to the previous voyage's channel for the whole early river
        rafting.lastDepartSite = nil
        rafting.chestSnapshots = {}
        rafting.chestRewards = {}
        rafting.lastChestNotice = nil
        rafting.abortSweep = false
        rafting.heldRepair = nil
        rafting.targetDeckZ = 0
        rafting.repairBlockedUntil = 0
        rafting.lastStepOkAt = nil
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
    rafting.telemetryObserve(payload)

    -- Auto-castoff when Ready
    if payload.Status == "Ready" and rafting.enabled and not rafting.isSailing then
        rafting.cancelLooting = false
        rafting.isEndingVoyage = false
        rafting.isEndingVoyageInProgress = false
        rafting.dockedStartTime = nil
        rafting.status = "Ready"
        rafting.isSailing = true
        rafting.statusText = "Raft Ready! Casting off..."
        task.delay(0.6, function()
            if rafting.enabled and rafting.currentSnapshot and rafting.currentSnapshot.Status == "Ready" then
                rafting.castOff()
            end
        end)
    elseif payload.Status == "Departing" then
        rafting.cancelLooting = false
        rafting.isEndingVoyage = false
        rafting.isEndingVoyageInProgress = false
        rafting.dockedStartTime = nil
        rafting.status = "Departing"
        rafting.isSailing = true
        if rafting.enabled and (not rafting.heartbeatConn or not rafting.renderSteppedConn) then
            rafting.startSteeringLoop()
        end
        rafting.statusText = "Departing dock..."
    elseif payload.Status == "Travelling" then
        rafting.cancelLooting = false
        rafting.isEndingVoyage = false
        rafting.isEndingVoyageInProgress = false
        rafting.dockedStartTime = nil
        if not rafting.isDockedState and not rafting.isLootingChest then
            rafting.status = "Travelling"
            rafting.isSailing = true
            if rafting.enabled and (not rafting.heartbeatConn or not rafting.renderSteppedConn) then
                rafting.startSteeringLoop()
            end
            if not rafting.isEvadingRock then
                rafting.statusText = "Travelling down river..."
            end
        elseif rafting.isDockedState and not rafting.isLootingChest and not rafting.isCastingOff
            and (os.clock() - (rafting.dockedAt or 0)) > 2.0 then
            -- The server is sailing but we still think we are docked: nothing would steer the raft
            rafting.telemetryEvent("RaftStaleDockCleared", { Site = rafting.currentDockSite })
            rafting.isDockedState = false
            rafting.currentDockSite = nil
            rafting.status = "Travelling"
            rafting.isSailing = true
        end

        -- Log what is blocking steering if it goes quiet. The cause of a stall is otherwise invisible.
        if rafting.enabled and not rafting.isLootingChest and not rafting.isCastingOff then
            local quiet = os.clock() - (rafting.lastStepOkAt or os.clock())
            if quiet > 1.5 and not rafting.stallLogged then
                rafting.stallLogged = true
                rafting.telemetryEvent("RaftSteeringStalled", {
                    Quiet = quiet, Sailing = rafting.isSailing, Status = rafting.status, Docked = rafting.isDockedState,
                    Ending = rafting.isEndingVoyage, HasDeck = rafting.getRaftDeck() ~= nil, LastError = rafting.lastStepError,
                })
            end
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
                -- Only the server docks a raft: it does so when the hull touches the shore of a site. All five logged
                -- docks came this way, so stopping the steering any earlier only risks leaving the raft unsteered.
                local reachedShore = isServerDocked

                if reachedShore then
                    local siteId = (site and site.Id) or payload.SiteId or "Clearing_Dock"
                    rafting.visitedSites[siteId] = true
                    rafting.status = "Docked"
                    rafting.isDockedState = true
                    rafting.currentDockSite = siteId
                    rafting.lastDepartSite = siteId
                    rafting.isSailing = false
                    rafting.dockedStartTime = os.clock()
                    rafting.dockedAt = os.clock()

                    local hp = payload.Health or 100
                    if rafting.isHealthLow(hp, payload.MaxHealth) or payload.Adrift then
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
                        -- Paced arrival settle: pause 0.5s for boat physics to settle against shore before looting
                        task.delay(0.5, function()
                            if rafting.isDockedState and not rafting.isEndingVoyage then
                                rafting.lootReachChests(site, curDeck)
                            else
                                task.delay(3.0, function()
                                    if rafting.isDockedState and not rafting.isLootingChest then
                                        rafting.castOff()
                                    end
                                end)
                            end
                        end)
                    elseif curDeck then
                        placeCowAboveDeck(curDeck)
                        if rafting.emergencyDocked then
                            rafting.emergencyDocked = false
                            safeNotify({ Title = "Rafting Emergency", Content = "Emergency dock: returning to shore...", Duration = 4 })
                            task.wait(0.6)
                            rafting.endVoyage()
                        else
                            task.delay(3.0, function()
                                if rafting.isDockedState and not rafting.isLootingChest then
                                    rafting.castOff()
                                end
                            end)
                        end
                    end
                end
            end
        end

        -- Dock watchdog: if docked for >= 8.0s and not actively looting, force cast off
        if (rafting.status == "Docked" or payload.Status == "Docked") and not rafting.isLootingChest and not rafting.isEndingVoyage then
            if not rafting.dockedStartTime then
                rafting.dockedStartTime = os.clock()
            elseif (os.clock() - rafting.dockedStartTime) >= ((rafting.dockMaxWaitSeconds or 4) + 4.0) then
                rafting.dockedStartTime = os.clock()
                if rafting.enabled and not rafting.isCastingOff then
                    rafting.isDockedState = false
                    rafting.castOff()
                end
            end
        else
            if payload.Status ~= "Docked" and rafting.status ~= "Docked" then
                rafting.dockedStartTime = nil
            end
        end

        -- Water recovery check: If character touches water or is away from deck, instantly return to deck (+5.5 studs hoof clearance)
        -- Suppressed during active looting so player is not yanked off land shore
        if rafting.status == "Docked" and root and not rafting.isLootingChest then
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
    rafting.cancelLooting = false
    rafting.isEndingVoyage = false
    rafting.isEndingVoyageInProgress = false
    rafting.dockedStartTime = nil
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
    if rafting.status == "Docked" or rafting.isDockedState or rafting.isLootingChest or snap.Status == "Docked" then
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

    -- Reached the Sea? (SeaStartX = 6594.58). Once per session: late snapshots used to re-enter and stack restarts.
    if posX >= 6590 and not rafting.isEndingVoyage and rafting.seaEndedSessionId ~= rafting.sessionId then
        rafting.seaEndedSessionId = rafting.sessionId
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
    rafting.logTargetChange(nextSite, posX, posZ)
    local lookAheadX = posX + lookAhead

    -- 1. Compute Whisker Clearances via Raycasts
    local clearances = rafting.getWhiskerClearances(deck)

    -- 2. Hybrid Target Z
    local targetZ = rafting.getTargetZ(lookAheadX, posZ, clearances)
    -- The raft's heading follows its channel, so steering only has to correct movement across the channel.
    -- Remove the channel's own slope over the lookahead (otherwise a diagonal reads as a constant error)
    -- and measure what is left across the channel axis.
    -- The axis is the raft's own heading: the server sets it to the channel it is steering along (logged -24.2°
    -- on the 0.45 diagonals, 0° on straights). Guessing the channel from position picked an overlapping -52°
    -- connector at the Reach 3 fork, read a 31-stud phantom error and steered into the wrong branch.
    local look = frame.LookVector
    local lookLen = math.sqrt(look.X * look.X + look.Z * look.Z)
    local axisX, axisZ
    if lookLen > 0.1 and look.X / lookLen > 0.3 then
        axisX, axisZ = look.X / lookLen, look.Z / lookLen
    else
        axisX, axisZ = rafting.channelFrame(posX, posZ)
    end
    local errorZ = (targetZ - (axisZ / axisX) * lookAhead - posZ) * axisX
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

    local coveLeadIn = 360
    local isHeadingToNorthCove = (not isDeparting) and nextSite and nextSite.BankSide == "North" and posX >= (mouthX - coveLeadIn) and posX <= (maxX + 25)
    local isHeadingToSouthCove = (not isDeparting) and nextSite and nextSite.BankSide == "South" and posX >= (mouthX - coveLeadIn) and posX <= (maxX + 25)

    -- Stand-Off Buffer: deck half-width is 7.0 studs.
    -- Begin repelling when wall is closer than 32 studs from center (25 studs from railing).
    -- Full lock repel when closer than 18 studs from center (11 studs from railing).
    if leftMinDist < 32.0 then
        local push = math.clamp((32.0 - leftMinDist) / 14.0, 0, 1)
        if not isHeadingToNorthCove or leftMinDist < 6.0 then
            local rep = if leftMinDist < 8.0 then 4.0 else push * 5.8
            whiskerRepulsion = whiskerRepulsion + (if isHeadingToNorthCove then math.min(rep, 2.5) else rep)
        end
    end
    if rightMinDist < 32.0 then
        local push = math.clamp((32.0 - rightMinDist) / 14.0, 0, 1)
        if not isHeadingToSouthCove or rightMinDist < 6.0 then
            local rep = if rightMinDist < 8.0 then 4.0 else push * 5.8
            whiskerRepulsion = whiskerRepulsion - (if isHeadingToSouthCove then math.min(rep, 2.5) else rep)
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
        -- Cut boost early so raft arrives at controlled approach speed
        if rafting.isBoosting then
            rafting.isBoosting = false
            local rem = rafting.getRemote()
            if rem then pcall(function() rem:FireServer("BoostRelease") end) end
        end
        -- Priority 1: Steer into North clearing cove along smooth curve without bouncing off entrance bank
        if leftMinDist < 6.0 then
            targetDeckX = math.clamp(whiskerRepulsion, -2.5, 2.5)
            rafting.statusText = "CORNER PROXIMITY! Cushioning cove entry..."
        else
            local steerMag = if absErr > 1.8 then math.clamp(3.8 + (absErr / 12.0) * 2.0, 3.8, 5.8) else math.abs(flowBias)
            targetDeckX = if errorZ > 0 then steerMag else -steerMag
            rafting.statusText = string.format("Approaching %s! Tracking cove entry curve...", nextSite.Id)
        end
    elseif isHeadingToSouthCove then
        -- Cut boost early so raft arrives at controlled approach speed
        if rafting.isBoosting then
            rafting.isBoosting = false
            local rem = rafting.getRemote()
            if rem then pcall(function() rem:FireServer("BoostRelease") end) end
        end
        -- Priority 1: Steer into South clearing cove along smooth curve without bouncing off entrance bank
        if rightMinDist < 6.0 then
            targetDeckX = math.clamp(whiskerRepulsion, -2.5, 2.5)
            rafting.statusText = "CORNER PROXIMITY! Cushioning cove entry..."
        else
            local steerMag = if absErr > 1.8 then math.clamp(3.8 + (absErr / 12.0) * 2.0, 3.8, 5.8) else math.abs(flowBias)
            targetDeckX = if errorZ > 0 then steerMag else -steerMag
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
        -- A network stall freezes the snapshot (logged: 1.3 s at full speed) and reads as no progress,
        -- so give no verdict until fresh data arrives. Snapshots are normally under 0.25 s old.
        local isSnapshotStale = rafting.lastSnapshotTime and (now - rafting.lastSnapshotTime) > 0.35
        if isSnapshotStale then
            rafting.lastProgressTime = now
            rafting.lastProgressX = posX
        elseif timeSinceCheck >= 0.4 then
            local dxMoved = posX - (rafting.lastProgressX or posX)
            -- River flows down +X. If dx < 1.2 studs over 0.4s while travelling, boat is not making progress
            local isMakingProgress = dxMoved >= 1.2
            if not isMakingProgress and (snap.Status == "Travelling" or snap.Status == "Departing") then
                rafting.stuckDuration = (rafting.stuckDuration or 0) + timeSinceCheck
            else
                rafting.stuckDuration = math.max(0, (rafting.stuckDuration or 0) - timeSinceCheck * 1.5)
                if rafting.isUnsticking and dxMoved >= 3.0 and (not rafting.coveDislodgeUntil or now >= rafting.coveDislodgeUntil) then
                    rafting.isUnsticking = false
                    rafting.unstickDirection = 0
                end
            end
            rafting.lastProgressX = posX
            rafting.lastProgressTime = now
        end
    end

    -- Cove corner trap watchdog: if blocked attempting to enter an unselected cove or truly wedged for extended duration, abandon site
    local isApproachingCoveMouth = nextSite and posX >= (minX - 80) and posX <= (maxX + 25) and not isInsideCoveInterior
    local isUserSelected = nextSite and rafting.isSiteSelected(nextSite)
    local maxCoveWait = if isUserSelected then 6.0 else 1.8
    local isCoveBlocked = isApproachingCoveMouth and (rafting.stuckDuration or 0) >= maxCoveWait

    if isCoveBlocked then
        local blockedSiteId = nextSite.Id
        -- Only permanently mark visited if boat is already past the mouth entrance or not a selected target
        if not isUserSelected or posX >= (mouthX + 40) then
            rafting.visitedSites[blockedSiteId] = true
        end
        rafting.abandonedSiteId = blockedSiteId
        rafting.coveDislodgeUntil = now + 2.5
        rafting.coveDislodgeDir = if nextSite.BankSide == "North" then 5.8 else -5.8
        rafting.stuckDuration = 0
        rafting.isUnsticking = true
        rafting.unstickStartTime = now
        print(string.format("[Rafting] Cove corner blocked for >= %.1fs! Dislodging downstream...", maxCoveWait))
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

    -- 6. Hobgoblin rocks: keep the course unless it ends in a hit. Applies to forks and cove approaches too,
    -- because the smallest correction that clears a rock rarely costs the turn.
    if not isActivelyDislodging then
        -- Far off the route with a site still ahead, a dodge that reverses the correction can cost the branch
        -- (aimed rocks lead the raft, so they land on the side it is steering to). A hit costs ~12 HP.
        local hp, maxHp = (snap and snap.Health) or 0, (snap and snap.MaxHealth) or 0
        local isCommitted = nextSite ~= nil and math.abs(errorZ) >= rafting.ROCK_COMMIT_ERROR
            and maxHp > 0 and hp >= maxHp * 0.5
        local clearDeckX, isDodging = rafting.avoidRocks(deck, targetDeckX, leftLateralDist, rightLateralDist, isCommitted)
        if isDodging then
            targetDeckX = clearDeckX
            rafting.statusText = "DODGING HOBGOBLIN ROCK! Steering clear of impact..."
        end
    end

    rafting.targetDeckX = math.clamp(targetDeckX, -5.8, 5.8)
    rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)

    -- Active Steering via Humanoid:MoveTo & Overboard Safety Check
    if root and char and humanoid and humanoid.Health > 0 then
        local cowPos = root.Position
        local cowRel = deck.CFrame:PointToObjectSpace(cowPos)
        local distFromDeck = (cowPos - deck.Position).Magnitude

        -- If character is separated from the raft (jumped off, thrown, or fell in water)
        if distFromDeck > 30.0 and not rafting.isDockedState and not rafting.isLootingChest then
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
            local targetZOffset = rafting.targetDeckZ or 0.0
            if isActivelyDislodging then targetZOffset = 7.0 end
            local targetWorldPos = deck.CFrame:PointToWorldSpace(Vector3.new(rafting.targetDeckX, 3.45, targetZOffset))
            humanoid:MoveTo(targetWorldPos)
        end
    end

    rafting.lastStepOkAt = os.clock()
    rafting.stallLogged = false

    -- Auto-Boost on straightaways: strictly conserve stamina & suppress in cove or near facades
    local rem = rafting.getRemote()
    local rd = getReachData()
    local reachIdx = getReachIndex(posX)
    local forkX = rd and rd.forkX and rd.forkX[reachIdx]
    local approachingFork = forkX and (posX >= forkX - 160) and (posX <= forkX)
    local coveLead = 320
    local approachingCove = nextSite and posX >= (mouthX - coveLead) and posX <= (nextSite.MaxX + 25)
    local nearFacade = (forwardDist < 75.0) or (leftMinDist < 22.0) or (rightMinDist < 22.0)
    local suppressBoost = isInsideCoveInterior or approachingCove or approachingFork or nearFacade or isWallStuck or rafting.isUnsticking or isActivelyDislodging

    if rafting.autoBoost and not suppressBoost then
        local energy = snap.Energy or 0
        local maxEnergy = snap.MaxEnergy or 100
        local energyPct = (energy / math.max(maxEnergy, 1)) * 100
        local isStraight = (math.abs(errorZ) <= 8 and not snap.LowEnergy and (snap.Speed or 0) > 5)
        local minEnergyThreshold = math.max(rafting.minBoostStamina, 40)
        -- At zero energy the raft cannot be steered, so never spend what is needed to reach the sea
        local hasSpare = energy > rafting.energyReserve(posX, snap) * 1.15 + 15
        local shouldBoost = (energyPct >= minEnergyThreshold) and not snap.LowEnergy and isStraight and hasSpare

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

    -- Auto-Repair split beams on open water, never where steering has work to do
    local repairAllowed = not (approachingCove or approachingFork or nearFacade or isWallStuck or isActivelyDislodging
        or rafting.isEvadingRock or isInsideCoveInterior)
    rafting.stepRepairUnderway(snap, deck, posX, repairAllowed)

    -- Emergency Health Return (Debounced & Single-Trigger)
    local hp = snap.Health or 100
    if (rafting.isHealthLow(hp, snap.MaxHealth) or snap.Adrift) and not rafting.isEndingVoyage then
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
            local deltaZ = (rafting.targetDeckZ or 0) - cowRel.Z
            if math.abs(deltaZ) <= 1.5 then deltaZ = 0 end
            if math.abs(deltaX) > 0.35 or deltaZ ~= 0 then
                if humanoid.WalkSpeed < 24 then
                    humanoid.WalkSpeed = 24
                end
                local localMove = Vector3.new(deltaX, 0, deltaZ)
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
    rafting.cancelLooting = false
    rafting.isEndingVoyage = false
    rafting.isEndingVoyageInProgress = false
    rafting.isLootingChest = false
    rafting.isDockedState = false

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
    rafting.telemetryEvent("SessionEnded", reason)
    rafting.telemetryFlush(true)
    rafting.isSailing = false
    rafting.isEndingVoyage = false
    rafting.isEndingVoyageInProgress = false
    rafting.cancelLooting = true
    rafting.isLootingChest = false
    rafting.isDockedState = false
    rafting.emergencyDocked = false
    rafting.currentSnapshot = nil
    rafting.status = "Idle"
    rafting.visitedSites = {}
    rafting.currentDockSite = nil
    rafting.lastDepartSite = nil
    rafting.heldRepair = nil
    rafting.targetDeckZ = 0
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
                local deck = (not rafting.isEndingVoyage) and (rafting.getRaftDeck() or oldDeck)
                if deck and deck.Parent and (root.Position - deck.Position).Magnitude <= 35.0 then
                    placeCowAboveDeck(deck)
                    safeNotify({ Title = "Rafting Recovered", Content = "Returned safely to boat deck.", Duration = 3 })
                else
                    rafting.teleportToRaftYard()
                    safeNotify({ Title = "River Failsafe", Content = "Rescued from river! Returned to dock.", Duration = 3 })
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
    rafting.scheduleLoopRestart()
end

-- The one place the auto loop starts the next voyage. Every ending (sea, Return, sinking, death, river rescue)
-- lands here, and a newer call replaces an older one, so an ending reported several times starts one voyage.
-- A start that does not produce a session (logged: the cow died and respawned elsewhere mid-start) is retried.
rafting.LOOP_RETRY_SECONDS = 30
function rafting.scheduleLoopRestart()
    if not (rafting.autoLoop and rafting.enabled) then return end
    local gen = (rafting.loopGen or 0) + 1
    rafting.loopGen = gen
    task.spawn(function()
        local function isCurrent()
            return rafting.loopGen == gen and rafting.autoLoop and rafting.enabled
        end
        task.wait(3)
        -- Until the server closes the session, the cow belongs on the raft: a Return can be refused mid-river,
        -- and the voyage then carries on with steering.
        while isCurrent() do
            local sessionLive = rafting.lastSessionSnapAt and (os.clock() - rafting.lastSessionSnapAt) < 4
            if not sessionLive or rafting.endedSessionId == rafting.sessionId then break end
            task.wait(0.5)
        end
        -- After a death, wait for the respawned character
        while isCurrent() and not (root and root.Parent and humanoid and humanoid.Health > 0) do
            task.wait(0.5)
        end
        if not isCurrent() then return end
        rafting.telemetryEvent("RaftLoopRestart", { Gen = gen })
        local attemptAt = os.clock()
        rafting.startVoyage()
        task.wait(rafting.LOOP_RETRY_SECONDS)
        if isCurrent() and (rafting.sessionSeenAt or 0) < attemptAt then
            rafting.telemetryEvent("RaftLoopRetry", { Gen = gen })
            rafting.scheduleLoopRestart()
        end
    end)
end

function rafting.endVoyage()
    if rafting.isEndingVoyageInProgress then return end
    rafting.isEndingVoyageInProgress = true
    rafting.isEndingVoyage = true
    rafting.cancelLooting = true
    rafting.isLootingChest = false
    rafting.isDockedState = false
    rafting.isSailing = false
    rafting.status = "Idle"

    sendRaftKey(Enum.KeyCode.H, 0.25)
    triggerRaftingCommand("Return")
    task.wait(0.2)
    rafting.fireRemoteSafely("Return", nil, 1.0)
    -- No teleport here: the session is still open until the server ends it, and pulling the cow off a sailing
    -- raft was followed by a death and a respawn elsewhere. scheduleLoopRestart (via onSessionEnded) brings the
    -- cow back once the session has closed, and startVoyage teleports it to the launch if it is far away.
    rafting.onSessionEnded("Voyage ended. Returned to shore.")
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
            rafting.telemetryEvent(eventName, payload)
            if eventName == "RaftingSnapshot" then
                rafting.handleSnapshot(payload)
            elseif eventName == "RaftingBoard" then
                rafting.handleBoarding(payload)
            elseif eventName == "RaftingEnded" then
                rafting.endedSessionId = rafting.sessionId
                rafting.onSessionEnded("Rafting session ended on server.")
            elseif eventName == "RaftingSinking" then
                rafting.endedSessionId = rafting.sessionId
                rafting.onSessionEnded("Raft sank! Session ended.")
            elseif eventName == "HobgoblinRock" then
                rafting.handleHobgoblinRock(payload)
            elseif eventName == "HobgoblinLanded" then
                rafting.handleHobgoblinLanded(payload)
            elseif eventName == "TeamChestSnapshot" then
                if payload and payload.Chests then
                    rafting.teamChests = payload.Chests
                    rafting.teamChestSite = payload.SiteId
                    if payload.SiteId then
                        rafting.chestSnapshots = rafting.chestSnapshots or {}
                        rafting.chestSnapshots[payload.SiteId] = payload
                    end
                end
            elseif eventName == "TeamChestReward" then
                if payload and payload.Id then
                    rafting.chestRewards = rafting.chestRewards or {}
                    rafting.chestRewards[payload.Id] = true
                end
            elseif eventName == "TeamChestClear" then
                rafting.teamChests = nil
                rafting.teamChestSite = nil
            elseif eventName == "RaftingNotice" or eventName == "WeatherEvent" or eventName == "RiverHazard" or eventName == "HazardWarning" then
                if payload and typeof(payload.Text) == "string" then
                    if rafting.CHEST_RETRY_NOTICES[payload.Text] or rafting.CHEST_DONE_NOTICES[payload.Text] or rafting.CHEST_ABORT_NOTICES[payload.Text] then
                        rafting.lastChestNotice = payload.Text
                    elseif string.find(payload.Text, "Hobgoblin") then
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
            local ok, err = pcall(rafting.stepSteering, dt)
            -- An error here silently stops the steering, so record each distinct one
            if not ok and tostring(err) ~= rafting.lastStepError then
                rafting.lastStepError = tostring(err)
                rafting.telemetryEvent("RaftStepError", rafting.lastStepError)
            end
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
_G.CowHubRaftingCleanup = rafting.cleanup

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
        rafting.telemetryEvent("RaftAutoPilot", { Enabled = Value, Status = rafting.status })
        if Value then
            rafting.cancelLooting = false
            rafting.isEndingVoyage = false
            rafting.isEndingVoyageInProgress = false
            rafting.lastStepOkAt = nil
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
        local deleteFn = delfile or deletefile
        if deleteFn then
            pcall(function() deleteFn(afkRelog.fileName) end)
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
            pcall(_G.CowHubChompCleanup)
            farm.autoChompMobs = false
            farm.autoFish = false
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

            _G.CowHubLoaded = nil
            _G.CowHubRayfield = nil
            _G.CowHubConnections = nil
            _G.CowHubHeartbeat = nil
        end)

        task.delay(0.05, function()
            pcall(function()
                if Rayfield and Rayfield.Destroy then
                    Rayfield:Destroy()
                elseif Window and Window.Unload then
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
