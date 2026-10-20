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
            loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/main/preview.lua'))()
        ]])
    end)
end

-- 2. Build the Hub
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/gen2'))()

local Window = Rayfield:CreateWindow({
    Name = "Cow Hub",
    Subtitle = "by Gemini & I",
    showIconOnly = true,
    theme = "frost",
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "CowHubConfig",
        customFolder = "CowHub",
    },
    KeySystem = false
})

-- ==========================
-- SERVICES & FAST LOCAL APIS
-- ==========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
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
            end
        end)
    end
    if humanoid and dodge and (dodge.originalWalkSpeed == nil or dodge.originalWalkSpeed == 16) then
        dodge.originalWalkSpeed = humanoid.WalkSpeed
    end
    raycastParams.FilterDescendantsInstances = {char}
    updateWallRaycastFilter()
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

-- ==========================
-- TRICK OR TREAT AUTOFARM (HALLOWEEN EVENT)
-- ==========================
trickOrTreat = {
    auto = false,
    isCycling = false,
    isSingleRun = false,
    returnOnFinish = true,
    pauseFarmDuringCycle = true,
    anchorDuringKnock = true,
    savedPreCFrame = nil,
    barnPosition = Vector3.new(-537, 727, 600),
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

function trickOrTreat.detectCooldown()
    local detected = nil
    pcall(function()
        local shared = cowGame and cowGame:FindFirstChild("Shared")
        if shared then
            local hwConfigMod = shared:FindFirstChild("HalloweenConfig")
            if hwConfigMod then
                local hw = require(hwConfigMod)
                if type(hw) == "table" and type(hw.TrickOrTreat) == "table" then
                    local tot = hw.TrickOrTreat
                    for _, k in ipairs({"Cooldown", "HouseCooldown", "KnockCooldown", "WaitTime", "CooldownSeconds", "CycleCooldown", "CycleSeconds"}) do
                        if type(tot[k]) == "number" and tot[k] > 0 then
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
                        for _, k in ipairs({"HouseCooldown", "Cooldown", "KnockCooldown", "WaitTime", "KnockWaitTime"}) do
                            if type(rules[k]) == "number" and rules[k] > 0 then
                                detected = rules[k]
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    if detected and detected > 0 then
        trickOrTreat.detectedCooldown = detected
        trickOrTreat.cycleCooldown = detected
    end
    return detected
end

function trickOrTreat.getHousesFolder()
    local cowWorld = cache.cowWorldRef
    if not cowWorld or not cowWorld.Parent then
        cowWorld = workspace:FindFirstChild("CowWorld")
        cache.cowWorldRef = cowWorld
    end
    if cowWorld then
        local geometry = cowWorld:FindFirstChild("Geometry") or cowWorld:FindFirstChild("Geometry", true)
        if geometry then
            local fh = geometry:FindFirstChild("FarmerHouses") or geometry:FindFirstChild("Houses")
            if fh then return fh end
        end
        local fhDirect = cowWorld:FindFirstChild("FarmerHouses", true) or cowWorld:FindFirstChild("Houses", true)
        if fhDirect then return fhDirect end
    end
    return workspace:FindFirstChild("FarmerHouses", true) or workspace:FindFirstChild("Houses", true)
end

function trickOrTreat.getHouseList()
    local folder = trickOrTreat.getHousesFolder()
    local list = {}
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") or child:IsA("Folder") then
                local n = child.Name:lower()
                if string.match(child.Name, "^%w+_House%d+$") or string.find(n, "house") or string.find(n, "farmer") then
                    table.insert(list, child)
                end
            end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
    end
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

function trickOrTreat.fireDoorPrompt(houseModel)
    local firedAny = false

    -- 1. Fire any ProximityPrompt instances found in the house
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
    if remote then
        pcall(function()
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer("Knock", houseModel.Name)
            else
                remote:FireServer("Knock", houseModel.Name)
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

function trickOrTreat.getTargetCFrame(houseModel)
    if not houseModel then return nil end

    local threshold = houseModel:FindFirstChild("Threshold", true)
    local thresholdPart = resolveHousePart(threshold)

    local door = houseModel:FindFirstChild("Door", true)
    local doorPart = resolveHousePart(door)

    local exit = houseModel:FindFirstChild("Exit", true)
    local exitPart = resolveHousePart(exit)

    local inside = houseModel:FindFirstChild("Inside", true) or houseModel:FindFirstChild("Interior", true)
    local insidePart = resolveHousePart(inside)

    -- Determine door / entrance reference point (prefer thresholdPart for exact KnockRange detection)
    local doorRef = thresholdPart or doorPart or exitPart or insidePart or houseModel.PrimaryPart or houseModel:FindFirstChildWhichIsA("BasePart", true)
    if not doorRef then return nil end

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
        for _, part in ipairs(houseModel:GetDescendants()) do
            if part:IsA("BasePart") then
                local pName = part.Name:lower()
                if pName:find("roof") or pName:find("ceiling") or pName:find("chimney") or pName:find("eave") or pName == "inside" or pName == "interior" then
                    table.insert(filter, part)
                end
            end
        end
    end
    rayParams.FilterDescendantsInstances = filter
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Raycast downward from chest height (baseFloorY + 1.0) so it's always underneath roof/ceiling
    local knockFloorY = nil
    local rayResult = workspace:Raycast(Vector3.new(knockX, baseFloorY + 1.0, knockZ), Vector3.new(0, -8, 0), rayParams)
    if rayResult then
        knockFloorY = rayResult.Position.Y + 2.5
    else
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
        local appRay = workspace:Raycast(Vector3.new(appX, baseFloorY + 1.0, appZ), Vector3.new(0, -8, 0), rayParams)
        if appRay then
            appFloorY = appRay.Position.Y + 2.5
        else
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
                        if waitSecs > 0 then
                            trickOrTreat.nextCycleTime = math.max(trickOrTreat.nextCycleTime, os.clock() + waitSecs)
                            if trickOrTreat.autoDetectCooldown and waitSecs > 10 then
                                trickOrTreat.cycleCooldown = waitSecs
                            end
                            trickOrTreat.updateStatusUI()
                        end
                    end
                end
            end)
        end
    end)
end

function trickOrTreat.updateStatusUI()
    if not trickOrTreat.statusCard then return end
    local now = os.clock()
    local statusTitle = "Status: " .. trickOrTreat.statusText
    local statusBody = ""

    if trickOrTreat.isCycling then
        statusBody = "Currently cycling through houses..."
    elseif trickOrTreat.auto then
        local cdRemaining = math.max(0, math.ceil(trickOrTreat.nextCycleTime - now))
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

    if trickOrTreat.infoCard then
        local infoTitle = "Cycle Telemetry"
        local cdMin = math.floor(trickOrTreat.cycleCooldown / 60)
        local cdSec = math.floor(trickOrTreat.cycleCooldown % 60)
        local infoBody = string.format("Configured Cooldown: %d:%02d (%ds)\nLast Cycle Houses Knocked: %d\nLast House: %s",
            cdMin, cdSec, trickOrTreat.cycleCooldown,
            trickOrTreat.housesVisitedCount,
            trickOrTreat.lastHouseName ~= "" and trickOrTreat.lastHouseName or "None"
        )
        pcall(function()
            if trickOrTreat.infoCard.SetTitle then
                trickOrTreat.infoCard:SetTitle(infoTitle)
                trickOrTreat.infoCard:Set(infoBody)
            elseif trickOrTreat.infoCard.Set then
                trickOrTreat.infoCard:Set({ Title = infoTitle, Content = infoBody })
            end
        end)
    end
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
        return
    end

    trickOrTreat.isCycling = true
    trickOrTreat.statusText = "Starting Cycle..."
    trickOrTreat.updateStatusUI()

    -- 1. Save original player position BEFORE teleporting to barn for map load
    local preCycleCFrame = getRootCFrame(root)
    trickOrTreat.savedPreCFrame = preCycleCFrame

    local currentHouseInteracting = nil

    local function cleanupCycle()
        pcall(function()
            if root and root:IsA("BasePart") then
                root.Anchored = false
            end
        end)
        if currentHouseInteracting and trickOrTreat.disableInsideCollision then
            pcall(function() trickOrTreat.setHouseCollision(currentHouseInteracting, true) end)
        end
        if trickOrTreat.returnOnFinish and preCycleCFrame and root and char and char.Parent then
            pcall(function()
                char:PivotTo(preCycleCFrame)
                setRootCFrame(preCycleCFrame)
                stopCharacterVelocity()
            end)
        end
        trickOrTreat.isCycling = false
        trickOrTreat.isSingleRun = false
    end

    -- 2. Teleport player to the barn (-537, 727, 600) so the map will load
    trickOrTreat.statusText = "Loading Map at Barn..."
    trickOrTreat.updateStatusUI()

    pcall(function() root.Anchored = false end)
    pcall(function()
        char:PivotTo(CFrame.new(trickOrTreat.barnPosition))
        setRootCFrame(CFrame.new(trickOrTreat.barnPosition))
        stopCharacterVelocity()
    end)
    pcall(function() root.Anchored = true end)

    -- Wait for map to load (poll for houses)
    local barnStart = os.clock()
    local houses = {}
    while (os.clock() - barnStart < trickOrTreat.barnLoadDelay) do
        if not trickOrTreat.auto and not trickOrTreat.isSingleRun then
            cleanupCycle()
            trickOrTreat.statusText = "Aborted"
            trickOrTreat.updateStatusUI()
            return
        end
        task.wait(0.25)
        houses = trickOrTreat.getHouseList()
        if #houses > 0 and (os.clock() - barnStart >= 1.5) then
            break
        end
    end

    pcall(function() root.Anchored = false end)

    if #houses == 0 then
        houses = trickOrTreat.getHouseList()
    end

    if #houses == 0 then
        trickOrTreat.statusText = "Error: FarmerHouses not loaded"
        trickOrTreat.nextCycleTime = os.clock() + 20
        trickOrTreat.updateStatusUI()
        if Window and Window.Notify then
            Window:Notify({
                Title = "Trick or Treat",
                Content = "FarmerHouses folder not loaded yet! Retrying in 20s.",
                Duration = 4,
            })
        end
        cleanupCycle()
        return
    end

    local remote = trickOrTreat.getRemote()
    local knockedCount = 0

    -- 3. Cycle through all houses in FarmerHouses
    for i, house in ipairs(houses) do
        if not trickOrTreat.auto and not trickOrTreat.isSingleRun then
            break
        end

        -- Check health / alive state
        if not humanoid or humanoid.Health <= 0 or not root or not root.Parent then
            warn("[CowHub TrickOrTreat] Player died or lost character during cycle. Aborting.")
            break
        end

        currentHouseInteracting = house

        local approachCF, knockPos = trickOrTreat.getTargetCFrame(house)
        if approachCF and knockPos then
            local originLabel = trickOrTreat.approachOrigin or "Inside House"
            trickOrTreat.statusText = string.format("Approaching [%d/%d] (%s): %s", i, #houses, originLabel, house.Name)
            trickOrTreat.lastHouseName = house.Name
            trickOrTreat.updateStatusUI()

            -- 1. Disable collision on Inside / Interior boundary box so player doesn't clip/fling
            if trickOrTreat.disableInsideCollision then
                trickOrTreat.setHouseCollision(house, false)
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
                trickOrTreat.statusText = string.format("Walking to Door [%d/%d]: %s", i, #houses, house.Name)
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
                    if (currentFlat - targetFlat).Magnitude <= 1.2 then
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
            trickOrTreat.statusText = string.format("Knocking [%d/%d]: %s", i, #houses, house.Name)
            trickOrTreat.updateStatusUI()

            pcall(function() trickOrTreat.fireDoorPrompt(house) end)

            knockedCount = knockedCount + 1

            -- 7. Wait interaction delay (throttle next knock, respecting NextKnockAt = 1.2s)
            task.wait(trickOrTreat.houseWaitTime)

            if trickOrTreat.anchorDuringKnock then
                pcall(function() root.Anchored = false end)
            end
            stopCharacterVelocity()

            -- Restore house collision
            if trickOrTreat.disableInsideCollision then
                pcall(function() trickOrTreat.setHouseCollision(house, true) end)
            end
        end

        currentHouseInteracting = nil
    end

    pcall(function() root.Anchored = false end)

    -- 4. Teleport back to original position before the cycle started
    if trickOrTreat.returnOnFinish and preCycleCFrame then
        trickOrTreat.statusText = "Returning to original position..."
        trickOrTreat.updateStatusUI()
        pcall(function()
            char:PivotTo(preCycleCFrame)
            setRootCFrame(preCycleCFrame)
            stopCharacterVelocity()
        end)
        task.wait(0.2)
        stopCharacterVelocity()
    end

    trickOrTreat.lastCycleCompletedTime = os.clock()
    trickOrTreat.housesVisitedCount = knockedCount
    trickOrTreat.nextCycleTime = os.clock() + trickOrTreat.cycleCooldown
    trickOrTreat.isCycling = false
    trickOrTreat.isSingleRun = false
    trickOrTreat.statusText = string.format("Cycle finished (%d houses). On cooldown.", knockedCount)
    trickOrTreat.updateStatusUI()

    if Window and Window.Notify then
        local cdMin = math.floor(trickOrTreat.cycleCooldown / 60)
        local cdSec = math.floor(trickOrTreat.cycleCooldown % 60)
        Window:Notify({
            Title = "Trick or Treat Cycle Complete",
            Content = string.format("Knocked %d houses! Returned to start. Next cycle in %d:%02d.", knockedCount, cdMin, cdSec),
            Duration = 4,
            Image = 4483362458,
        })
    end
end

function trickOrTreat.startLoop()
    if trickOrTreat.loopRunning then return end
    trickOrTreat.loopRunning = true
    task.spawn(function()
        while trickOrTreat.loopRunning do
            task.wait(1)
            pcall(trickOrTreat.updateStatusUI)
            if trickOrTreat.auto and not trickOrTreat.isCycling then
                local now = os.clock()
                if now >= trickOrTreat.nextCycleTime then
                    local success, err = pcall(trickOrTreat.runCycle)
                    if not success then
                        warn("[CowHub TrickOrTreat] Error during cycle:", err)
                        trickOrTreat.isCycling = false
                        trickOrTreat.isSingleRun = false
                        trickOrTreat.statusText = "Cycle Error (retrying in 20s)"
                        trickOrTreat.nextCycleTime = os.clock() + 20
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
        trickOrTreat.initClientListener()
        trickOrTreat.detectCooldown()
        trickOrTreat.nextCycleTime = 0
        trickOrTreat.startLoop()
        if Window and Window.Notify then
            Window:Notify({
                Title = "Trick or Treat Autofarm",
                Content = "Autofarm enabled. Teleporting to barn to load map...",
                Duration = 3,
                Image = 4483362458,
            })
        end
    else
        trickOrTreat.statusText = "Idle"
        if trickOrTreat.isCycling and trickOrTreat.returnOnFinish and trickOrTreat.savedPreCFrame and root then
            pcall(function() root.Anchored = false end)
            pcall(function()
                char:PivotTo(trickOrTreat.savedPreCFrame)
                setRootCFrame(trickOrTreat.savedPreCFrame)
                stopCharacterVelocity()
            end)
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
            WalkUpEnabled = (trickOrTreat and trickOrTreat.walkUpEnabled) ~= false,
            DisableInsideCollision = (trickOrTreat and trickOrTreat.disableInsideCollision) ~= false,
            ApproachOrigin = trickOrTreat and trickOrTreat.approachOrigin or "Inside House",
            WalkDistance = trickOrTreat and trickOrTreat.walkDistance or 11.0,
            WalkTimeout = trickOrTreat and trickOrTreat.walkTimeout or 1.5,
            DoorDistance = trickOrTreat and trickOrTreat.doorDistance or 2.0,
            DoorHeightOffset = trickOrTreat and trickOrTreat.doorHeightOffset or 0.0,
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
    if Window and Window.Notify then
        Window:Notify({
            Title = "6-Hour Auto-Rejoin",
            Content = "AFK timer elapsed! Coordinates logged. Rejoining now...",
            Duration = 6,
            Image = 4483362458,
        })
    end

    -- 3. Hook queue_on_teleport so cowhub auto-executes on reconnect
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot([[
                task.wait(3)
                loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/main/preview.lua'))()
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
            if data.TrickOrTreat.CycleCooldown then
                trickOrTreat.cycleCooldown = data.TrickOrTreat.CycleCooldown
                pcall(function() Window:Set("Slider_ToT_CycleCooldown", data.TrickOrTreat.CycleCooldown) end)
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

        local targetGrassNode = nil
        local hit = workspace:Raycast(rootPos, RAYCAST_DOWN, raycastParams)
        if hit and hit.Instance then
            targetGrassNode = cache.resolveGrassNode(hit.Instance)
        end

        -- Proximity Fallback 1: Current target node within 6 studs (36 sq)
        if not targetGrassNode and farm.currentTargetNode and farm.currentTargetNode.Parent then
            local tPos = cache.getNodePosition(farm.currentTargetNode)
            if tPos and get2DDistanceSq(rootPos, tPos) <= 36 then
                local id = cache.getNodeID(farm.currentTargetNode)
                if id then
                    targetGrassNode = farm.currentTargetNode
                end
            end
        end

        -- Proximity Fallback 2: Any grass node in CowVirtualGrass within 6 studs
        if not targetGrassNode then
            local grassNodes = cache.getGrassNodes()
            local bestDistSq = 36
            for _, node in ipairs(grassNodes) do
                if node and node.Parent then
                    local nodePos = cache.getNodePosition(node)
                    if nodePos then
                        local dSq = get2DDistanceSq(rootPos, nodePos)
                        if dSq < bestDistSq then
                            local nodeId = cache.getNodeID(node)
                            if nodeId then
                                bestDistSq = dSq
                                targetGrassNode = node
                            end
                        end
                    end
                end
            end
        end

        if targetGrassNode then
            local nodeId = cache.getNodeID(targetGrassNode)
            if nodeId then
                local repeatDelay = farm.grassChompRepeatDelay or (chompDelay + 0.1)
                if (now - farm.chompCooldown >= chompDelay) and (nodeId ~= farm.lastChompedNode or (now - farm.chompCooldown >= repeatDelay)) then
                    chompEvent:FireServer(nodeId)
                    farm.lastChompedNode = nodeId
                    farm.chompCooldown = now

                    if farm.currentTargetNode and (farm.currentTargetNode == targetGrassNode or farm.currentTargetNode.Name == targetGrassNode.Name) then
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
                if farm.on and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not (trickOrTreat and trickOrTreat.isCycling) and farm.anchorPos and not dodge.isDodging and not dodge.isUnderground then
                    farm.processMovement(dt, now, rootPos)
                end

                local prioritizedMobThisFrame = false

                -- 2. Priority Mob Aura Logic
                if farm.autoChompMobs and not (trickOrTreat and trickOrTreat.isCycling) then
                    prioritizedMobThisFrame = farm.processMobAura(now, rootPos)
                end

                -- 3. Raycast Grass Chomp Logic (Yields to Mobs & Dodging)
                if farm.autoChomp and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not (trickOrTreat and trickOrTreat.isCycling) and not prioritizedMobThisFrame and not dodge.isUnderground and not dodge.isDodging then
                    farm.processGrassChomp(now, rootPos)
                end

                -- 3b. Golden Grass Aura Logic (Periodic Pulse)
                if farm.goldenAura and not (trickOrTreat and trickOrTreat.isCycling) and (now - farm.lastGoldenAuraTime > 0.3) then
                    farm.lastGoldenAuraTime = now
                    farm.applyGoldenAura()
                end

                -- 4. Auto-Fishing Logic
                if farm.autoFish and not (manatite and manatite.auto) and not (mithril and mithril.auto) and not (trickOrTreat and trickOrTreat.isCycling) then
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
        updatePenVisualizer()
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
        fitout = workspace:FindFirstChild("TownStoreFitout", true)
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
        local buyNowIndex = 1
        for _, lot in ipairs(res.Lots) do
            if lot.Slot then
                if lot.Slot == "BuyNow" then
                    if buyNowIndex == 1 then
                        townAuction.lotsBySlot["BuyNow"] = lot
                        townAuction.lotsBySlot["BuyNow1"] = lot
                        buyNowIndex = 2
                    else
                        townAuction.lotsBySlot["BuyNow2"] = lot
                        buyNowIndex = buyNowIndex + 1
                    end
                else
                    townAuction.lotsBySlot[lot.Slot] = lot
                    if lot.Slot == "BuyNow1" then
                        townAuction.lotsBySlot["BuyNow"] = lot
                    end
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
        local success, result = pcall(function()
            if isBuyNow then
                return remote:InvokeServer({
                    Round = round,
                    Action = "Buy",
                    Slot = "BuyNow"
                })
            else
                return remote:InvokeServer({
                    Slot = slotName,
                    Round = round,
                    Action = "Bid",
                    Amount = amount
                })
            end
        end)

        townAuction.isAutoBiddingSlot[slotName] = false

        if success then
            local isOk = (type(result) == "table" and result.Ok ~= false) or (result == true or result == nil)
            if isOk then
                local itemName = (lot and lot.Name)
                    or (model and (model:GetAttribute("TownAuctionName") or model:GetAttribute("TownAuctionItemID")))
                    or slotName
                Window:Notify({
                    Title = isBuyNow and "Auto Buy Placed!" or "Auto Outbid Placed!",
                    Content = string.format("%s (%s)\nAmount: 🪙 %s %s\nOutbidding: %s",
                        slotName,
                        tostring(itemName),
                        formatNumber(amount),
                        townAuction.currency,
                        tostring(leaderName or "None")),
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

    local success, result = pcall(function()
        if isBuyNow then
            return remote:InvokeServer({
                Round = round,
                Action = "Buy",
                Slot = "BuyNow"
            })
        else
            return remote:InvokeServer({
                Slot = slotName,
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

        if isOk then
            local actionTitle = isBuyNow and "Purchase Placed!" or "Bid Placed!"
            Window:Notify({
                Title = actionTitle,
                Content = string.format("%s (%s)\nAmount: 🪙 %s %s", slotName, tostring(itemName), formatNumber(amount), townAuction.currency),
                Duration = 4
            })
            task.delay(0.5, function()
                townAuction.fetchSnapshot(false)
            end)
            return true
        else
            local errMsg = (type(result) == "table" and (result.Error or result.Message or result.Reason)) or tostring(result)
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

TotTab:CreateButton({
    Name = "Run Single Cycle Now",
    Callback = function()
        if trickOrTreat.isCycling then
            Window:Notify({ Title = "Already Running", Content = "A cycle is already in progress!", Duration = 3 })
            return
        end
        trickOrTreat.initClientListener()
        trickOrTreat.detectCooldown()
        trickOrTreat.isSingleRun = true
        task.spawn(function()
            local success, err = pcall(trickOrTreat.runCycle)
            if not success then
                warn("[CowHub TrickOrTreat] Error during single cycle:", err)
                trickOrTreat.isCycling = false
                trickOrTreat.isSingleRun = false
                trickOrTreat.statusText = "Error in cycle"
                pcall(trickOrTreat.updateStatusUI)
            end
        end)
    end,
})

TotTab:CreateButton({
    Name = "Return to Saved Position",
    Callback = function()
        if trickOrTreat.savedPreCFrame and root and char then
            pcall(function() root.Anchored = false end)
            pcall(function()
                char:PivotTo(trickOrTreat.savedPreCFrame)
                setRootCFrame(trickOrTreat.savedPreCFrame)
                stopCharacterVelocity()
            end)
            Window:Notify({ Title = "Returned", Content = "Returned to original saved position.", Duration = 2 })
        else
            Window:Notify({ Title = "No Saved Position", Content = "No saved position exists yet.", Duration = 2 })
        end
    end,
})

TotTab:CreateSection({ Name = "Status & Live Telemetry" })

pcall(function()
    trickOrTreat.statusCard = TotTab:CreateParagraph({
        Title = "Status: Idle",
        Content = "Autofarm is currently OFF."
    })
end)

pcall(function()
    trickOrTreat.infoCard = TotTab:CreateParagraph({
        Title = "Cycle Telemetry",
        Content = string.format("Configured Cooldown: %ds\nHouses Knocked: 0", trickOrTreat.cycleCooldown)
    })
end)

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
    route = "Clearing & Chest Explorer", -- "Clearing & Chest Explorer", "Fast Sea Run (Center/Direct)", "North Channels (Caves & Drops)", "South Channels (Scenic & Clearings)"
    autoBoost = true,
    minBoostStamina = 40,
    isBoosting = false,
    nextBoostAt = 0,
    autoRepair = true,
    emergencyReturnHp = 25,
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
    currentSnapshot = nil,
    sessionId = nil,
    raftModel = nil,
    deckPart = nil,
    status = "Idle",
    statusText = "Idle at Raft Yard",
    teleportAttempts = 0,
    lastRepairTime = 0,
    isSailing = false,
    dockMaxWaitSeconds = 5,
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
    if sessionId then
        local raftName = "TeamRaft_" .. tostring(sessionId)
        local fjordFolder = workspace:FindFirstChild("FjordRafting") or (workspace:FindFirstChild("CowWorld") and workspace.CowWorld:FindFirstChild("FjordRafting"))
        local model = (fjordFolder and fjordFolder:FindFirstChild(raftName)) or workspace:FindFirstChild(raftName)
        if model then
            local deck = model:FindFirstChild("Deck")
            if deck and deck:IsA("BasePart") then
                rafting.raftModel = model
                rafting.deckPart = deck
                return deck, model
            end
        end
    end
    return nil, nil
end

local harbourRibbon = {
    { -241.77, -29.41 },
    { -141.77, -37.84 },
    {  -41.77, -36.71 },
    {   58.23, -37.96 },
    {  158.23, -40.16 },
    {  258.23, -39.84 },
    {  358.23, -37.84 },
    {  458.23, -35.84 },
    {  558.23, -35.58 },
    {  658.23, -36.00 },
    {  758.23, -37.74 },
    {  858.23, -37.81 },
    {  958.23, -37.81 },
    { 1094.58, -37.81 },
}

local function getHarbourZ(posX)
    if posX <= harbourRibbon[1][1] then
        return harbourRibbon[1][2]
    end
    if posX >= harbourRibbon[#harbourRibbon][1] then
        return harbourRibbon[#harbourRibbon][2]
    end
    for i = 1, #harbourRibbon - 1 do
        local p0 = harbourRibbon[i]
        local p1 = harbourRibbon[i + 1]
        if posX >= p0[1] and posX <= p1[1] then
            local span = p1[1] - p0[1]
            if span <= 0 then return p0[2] end
            local alpha = (posX - p0[1]) / span
            return p0[2] + alpha * (p1[2] - p0[2])
        end
    end
    return -37.81
end

local clearingLandCoords = {
    ["Clearing_01"] = Vector3.new(1334.58, 702.5, -175.96),
    ["Clearing_02"] = Vector3.new(1622.58, 702.5, 113.34),
    ["Clearing_03"] = Vector3.new(2985.08, 702.5, -635.96),
    ["Clearing_04"] = Vector3.new(3144.58, 702.5, 578.34),
    ["Clearing_05"] = Vector3.new(4424.58, 702.5, -1108.46),
    ["Clearing_06"] = Vector3.new(4564.58, 702.5, -347.66),
    ["Clearing_07"] = Vector3.new(4448.08, 702.5, 712.04),
    ["Clearing_08"] = Vector3.new(4604.08, 702.5, 1013.34),
    ["Clearing_09"] = Vector3.new(6014.58, 702.5, -772.66),
    ["Clearing_10"] = Vector3.new(6274.58, 702.5, -190.96),
}

function rafting.getTargetZ(posX, currentZ)
    -- In Harbour (Dock at -241 to Delta Entrance at 1094.58), follow official canal ribbon
    if posX <= 1094.58 then
        return getHarbourZ(posX)
    end

    local r = rafting.route

    -- "Clearing & Chest Explorer" (Docks at clearings along the river)
    if r == "Clearing & Chest Explorer" then
        if posX <= 1420 then
            if rafting.visitedSites["Clearing_01"] then
                -- Already visited Clearing 01: steer smoothly towards Clearing 02 approach
                local t = math.clamp((posX - 1200) / 220, 0, 1)
                return -37.81 + t * (90.0 - (-37.81))
            elseif posX <= 1260 then
                -- Approach Clearing 01 (North cove, mouth X=1334.58, Z=-175.96, dock box Z in [-261.46, -87.36])
                local t = math.clamp((posX - 1094.58) / 165.42, 0, 1)
                return -37.81 + t * (-140.0 - (-37.81))
            else
                -- Dock at Clearing 01
                return -140.0
            end
        elseif posX <= 1540 then
            -- Depart Clearing 01 and cross towards Clearing 02 (South cove, mouth X=1622.58, Z=113.34, dock box Z in [11.74, 211.84])
            local t = math.clamp((posX - 1420) / 120, 0, 1)
            return -37.81 + t * (90.0 - (-37.81))
        elseif posX <= 1720 then
            if rafting.visitedSites["Clearing_02"] then
                -- Depart Clearing 02 and merge into South Channel (412.19)
                local t = math.clamp((posX - 1600) / 244.58, 0, 1)
                return 90.0 + t * (412.19 - 90.0)
            else
                -- Dock at Clearing 02
                return 90.0
            end
        elseif posX <= 1844.58 then
            -- Depart Clearing 02 and merge into South Channel (412.19)
            local t = math.clamp((posX - 1720) / 124.58, 0, 1)
            return 90.0 + t * (412.19 - 90.0)
        elseif posX <= 2844.58 then
            -- Reach 2 South Channel
            return 412.19
        elseif posX <= 3050 then
            -- Reach 3 South Channel approach
            return 412.19
        elseif posX <= 3180 then
            if rafting.visitedSites["Clearing_04"] then
                return 540.0
            else
                -- Steer into Clearing 04 (South cove, mouth X=3144.58, Z=578.34, dock box Z in [463.74, 691.84])
                local t = math.clamp((posX - 3050) / 130, 0, 1)
                return 412.19 + t * (540.0 - 412.19)
            end
        elseif posX <= 3294.58 then
            if rafting.visitedSites["Clearing_04"] then
                local t = math.clamp((posX - 3180) / 114.58, 0, 1)
                return 540.0 + t * (862.19 - 540.0)
            else
                -- Dock at Clearing 04
                return 540.0
            end
        elseif posX <= 4294.58 then
            -- Reach 4: transition from 540 to Far South (862.19)
            local t = math.clamp((posX - 3294.58) / 1000, 0, 1)
            return 540.0 + t * (862.19 - 540.0)
        elseif posX <= 4520 then
            if rafting.visitedSites["Clearing_07"] then
                return 862.19
            else
                -- Steer towards Clearing 07 (mouth X=4448.08, Z=712.04)
                local t = math.clamp((posX - 4294.58) / 225.42, 0, 1)
                return 862.19 + t * (710.0 - 862.19)
            end
        elseif posX <= 4744.58 then
            if rafting.visitedSites["Clearing_08"] then
                return 960.0
            else
                -- Steer towards Clearing 08 (mouth X=4604.08, Z=1013.34)
                local t = math.clamp((posX - 4520) / 224.58, 0, 1)
                return 710.0 + t * (960.0 - 710.0)
            end
        elseif posX <= 5844.58 then
            -- Reach 6: diagonal to Extreme South (1312.19)
            local t = math.clamp((posX - 4744.58) / 1100, 0, 1)
            return 960.0 + t * (1312.19 - 960.0)
        else
            -- Reach 7 to Sea
            return 1312.19
        end

    -- "North Channels (Caves & Drops)"
    elseif r == "North Channels (Caves & Drops)" then
        if posX <= 1844.58 then
            return -37.81
        elseif posX <= 2844.58 then
            local t = math.clamp((posX - 1844.58) / 1000, 0, 1)
            return -37.81 + t * (-487.81 - (-37.81))
        elseif posX <= 3294.58 then
            return -487.81
        elseif posX <= 4294.58 then
            local t = math.clamp((posX - 3294.58) / 1000, 0, 1)
            return -487.81 + t * (-937.81 - (-487.81))
        elseif posX <= 4744.58 then
            return -937.81
        elseif posX <= 5844.58 then
            local t = math.clamp((posX - 4744.58) / 1100, 0, 1)
            return -937.81 + t * (-1387.81 - (-937.81))
        else
            return -1387.81
        end

    -- "South Channels (Scenic & Clearings)"
    elseif r == "South Channels (Scenic & Clearings)" then
        if posX <= 1844.58 then
            return -37.81
        elseif posX <= 2844.58 then
            local t = math.clamp((posX - 1844.58) / 1000, 0, 1)
            return -37.81 + t * (412.19 - (-37.81))
        elseif posX <= 3294.58 then
            return 412.19
        elseif posX <= 4294.58 then
            local t = math.clamp((posX - 3294.58) / 1000, 0, 1)
            return 412.19 + t * (862.19 - 412.19)
        elseif posX <= 4744.58 then
            return 862.19
        elseif posX <= 5844.58 then
            local t = math.clamp((posX - 4744.58) / 1100, 0, 1)
            return 862.19 + t * (1312.19 - 862.19)
        else
            return 1312.19
        end

    else
        -- "Fast Sea Run (Center/Direct)"
        -- Center channel all the way to the Sea!
        return -37.81
    end
end

function rafting.castOff()
    local rem = rafting.getRemote()
    if not rem then return end
    local snap = rafting.currentSnapshot
    local status = snap and snap.Status or rafting.status

    -- Bring player back safely aboard the raft deck before casting off
    local deck = rafting.getRaftDeck()
    if root and deck then
        stopCharacterVelocity()
        root.CFrame = deck.CFrame * CFrame.new(0, 3.45, 0)
        task.wait(0.2)
    end

    if status == "Docked" then
        rem:FireServer("Continue")
        rem:FireServer("Sail", nil)
        rem:FireServer("Vote", true)
    else
        rem:FireServer("Sail", nil)
        rem:FireServer("Vote", true)
    end
end

function rafting.updateCards()
    local snap = rafting.currentSnapshot
    local statusTitle = "Fjord Rafting: " .. tostring(rafting.statusText)
    local statusContent = string.format("Session State: %s | Auto-Pilot: %s\nRoute: %s | Auto-Loop: %s",
        tostring(rafting.status),
        rafting.enabled and "Active" or "Disabled",
        tostring(rafting.route),
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

        local telemTitle = string.format("Raft Telemetry | HP: %d/%d | Energy: %d/%d", hp, maxHp, nrg, maxNrg)
        local telemBody = string.format("Speed: %.1f kts | Steering: %+.2f | Pos: %s\nReach: %s | Boosting: %s | Adrift: %s",
            spd,
            steer,
            posStr,
            tostring(snap and snap.Reach or "Harbour"),
            tostring(snap and snap.Boosting == true),
            tostring(snap and snap.Adrift == true)
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

function rafting.handleSnapshot(payload)
    if not payload or type(payload) ~= "table" then return end
    rafting.currentSnapshot = payload
    rafting.sessionId = payload.Id
    rafting.status = payload.Status or "Travelling"

    if rafting.status ~= "Docked" then
        rafting.isDockedState = false
    end

    -- Auto-castoff when Ready
    if rafting.status == "Ready" and rafting.enabled and not rafting.isSailing then
        rafting.isSailing = true
        rafting.statusText = "Raft Ready! Casting off..."
        task.delay(0.6, function()
            if rafting.enabled and rafting.status == "Ready" then
                rafting.castOff()
            end
        end)
    elseif rafting.status == "Travelling" then
        rafting.isSailing = true
        rafting.statusText = "Travelling down river..."
    elseif rafting.status == "Departing" then
        rafting.isSailing = true
        rafting.statusText = "Departing dock..."
    elseif rafting.status == "Docked" and rafting.enabled then
        local siteId = payload.SiteId or "Clearing"
        rafting.visitedSites[siteId] = true

        -- Recover player if they slipped into the river water while docked
        if root and root.Position.Y < 701 then
            local landPos = clearingLandCoords[siteId]
            if landPos then
                stopCharacterVelocity()
                root.CFrame = CFrame.new(landPos)
            end
        end

        if not rafting.isDockedState then
            rafting.isDockedState = true
            rafting.statusText = string.format("Docked at %s. Looting & resuming in %ds...", tostring(siteId), rafting.dockMaxWaitSeconds)

            -- 1. Teleport player safely onto clearing dry land
            task.spawn(function()
                task.wait(0.2)
                local landPos = clearingLandCoords[siteId]
                if not landPos then
                    local deck = rafting.getRaftDeck()
                    if deck then
                        local bankOffset = (deck.Position.Z < -37.81) and -20 or 20
                        landPos = Vector3.new(deck.Position.X, 702.5, deck.Position.Z + bankOffset)
                    end
                end
                if landPos and root then
                    stopCharacterVelocity()
                    root.CFrame = CFrame.new(landPos)
                end
            end)
            
            -- 2. Loot TeamChest if present at this stop
            if siteId and siteId ~= rafting.lastLootedSite then
                rafting.lastLootedSite = siteId
                task.spawn(function()
                    task.wait(0.8)
                    pcall(function()
                        local remotes = cowRemotes or (game:GetService("ReplicatedStorage"):FindFirstChild("CowGame") and game.ReplicatedStorage.CowGame:FindFirstChild("Remotes"))
                        local teamChestReq = remotes and remotes:FindFirstChild("TeamChestRequest")
                        if teamChestReq then
                            teamChestReq:FireServer(siteId)
                        end
                    end)
                end)
            end

            -- 3. Automatically cast off after dockMaxWaitSeconds (ONLY ONCE per docking session)
            task.delay(rafting.dockMaxWaitSeconds, function()
                if rafting.enabled and rafting.status == "Docked" then
                    rafting.castOff()
                end
            end)
        end
    end

    rafting.updateCards()
end

function rafting.handleBoarding(payload)
    rafting.status = "Boarding"
    rafting.statusText = "Boarding raft (walking aboard)..."
    rafting.updateCards()
end

function rafting.stepSteering(dt)
    if not rafting.enabled or not rafting.currentSnapshot then return end
    local snap = rafting.currentSnapshot
    if snap.Status ~= "Travelling" and snap.Status ~= "Departing" then return end

    local frame = snap.Frame
    if not frame or typeof(frame) ~= "CFrame" then return end

    local deck = rafting.getRaftDeck()
    if not deck then return end

    local posX = frame.Position.X
    local posZ = frame.Position.Z

    -- Reached the Sea? (SeaStartX = 6594.58)
    if posX >= 6590 then
        rafting.statusText = "Reached The Sea! Ending voyage..."
        Window:Notify({ Title = "Voyage Finished", Content = "Reached The Sea! Returning to shore.", Duration = 4 })
        rafting.endVoyage()
        return
    end

    -- Look ahead 35 studs downriver to steer smoothly into upcoming curves
    local lookAheadX = posX + 35
    local targetZ = rafting.getTargetZ(lookAheadX, posZ)

    local errorZ = targetZ - posZ
    rafting.errorZ = errorZ

    -- Determine target X on deck (-5.5 = Left / North, +5.5 = Right / South)
    -- Continuous proportional steering with narrow deadzone (0.8)
    local targetDeckX = 0
    if math.abs(errorZ) <= 0.8 then
        targetDeckX = 0 -- In channel center: run straight
    elseif errorZ < -0.8 then
        -- Raft is too far South (posZ > targetZ), steer North (Left, -X on deck)
        targetDeckX = math.clamp(errorZ * 0.5, -5.5, -2.0)
    else
        -- Raft is too far North (posZ < targetZ), steer South (Right, +X on deck)
        targetDeckX = math.clamp(errorZ * 0.5, 2.0, 5.5)
    end
    rafting.targetDeckX = targetDeckX

    -- Calculate delta time safely
    local dtVal = dt or 0.016
    if dtVal <= 0 or dtVal > 0.1 then dtVal = 0.016 end

    -- Steer the cow across the deck using Kinematic Relative Positioning
    -- This keeps the cow standing fully on top of the deck with hooves grounded,
    -- allowing Roblox humanoid platform replication and the game's _stepDeckMotion to work seamlessly!
    if root and char and humanoid and humanoid.Health > 0 then
        if humanoid.AutoRotate then
            humanoid.AutoRotate = false
        end
        local cowPos = root.Position
        local cowRel = deck.CFrame:PointToObjectSpace(cowPos)
        local currentX = cowRel.X
        local currentZ = cowRel.Z
        local currentY = cowRel.Y

        -- Overboard / fall-through recovery safeguard: only teleport if thrown off the raft into water
        if math.abs(currentX) > 8.5 or math.abs(currentZ) > 17.5 or currentY < -1.5 or currentY > 7.0 then
            root.CFrame = deck.CFrame * CFrame.new(targetDeckX, 3.45, 0)
            stopCharacterVelocity()
        else
            -- Preserve valid deck elevation (normal standing height is ~3.45)
            if currentY < 1.0 or currentY > 5.5 then
                currentY = 3.45
            end

            -- Smoothly step laterally across the deck at 16 studs/sec
            local maxStep = 16.0 * dtVal
            local deltaX = targetDeckX - currentX
            local stepX = math.clamp(deltaX, -maxStep, maxStep)
            local deltaZ = 0 - currentZ
            local stepZ = math.clamp(deltaZ, -maxStep, maxStep)

            local nextX = currentX + stepX
            local nextZ = currentZ + stepZ
            -- Fix character spinning: do not multiply by root.CFrame.Rotation!
            -- deck.CFrame * CFrame.new(...) is already oriented facing downriver with the raft deck
            root.CFrame = deck.CFrame * CFrame.new(nextX, currentY, nextZ)
        end
    end

    -- Auto-Boost on straightaways using official BoostHeld / BoostRelease heartbeat
    local rem = rafting.getRemote()
    if rafting.autoBoost and rem then
        local energy = snap.Energy or 0
        local maxEnergy = snap.MaxEnergy or 100
        local energyPct = (energy / math.max(maxEnergy, 1)) * 100
        local isStraight = math.abs(errorZ) <= 8 and not snap.LowEnergy and (snap.Speed or 0) > 5
        local shouldBoost = energyPct >= rafting.minBoostStamina and isStraight

        if shouldBoost then
            if not rafting.isBoosting or os.clock() >= (rafting.nextBoostAt or 0) then
                rafting.isBoosting = true
                rafting.nextBoostAt = os.clock() + 0.2 -- RaftingConfig.BoostHeartbeatSeconds
                rem:FireServer("BoostHeld")
            end
        else
            if rafting.isBoosting then
                rafting.isBoosting = false
                rafting.nextBoostAt = 0
                rem:FireServer("BoostRelease")
            end
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

    -- Emergency Health Return
    local hp = snap.Health or 100
    if (hp <= rafting.emergencyReturnHp and hp > 0) or snap.Adrift then
        Window:Notify({ Title = "Rafting Emergency", Content = "Low health or adrift! Returning to shore...", Duration = 4 })
        rafting.endVoyage()
    end
end

function rafting.stepSteeringAnimation(dt)
    if not rafting.enabled or not rafting.currentSnapshot then return end
    local snap = rafting.currentSnapshot
    if snap.Status ~= "Travelling" and snap.Status ~= "Departing" then return end

    local deck = rafting.getRaftDeck()
    if not deck then return end

    local targetDeckX = rafting.targetDeckX or 0

    -- 1. Humanoid Walk Animation: set MoveDirection so the cow faces and animates naturally
    if root and char and humanoid and humanoid.Health > 0 then
        local cowRel = deck.CFrame:PointToObjectSpace(root.Position)
        local deltaX = targetDeckX - cowRel.X
        local deltaZ = 0 - cowRel.Z
        local localMove = Vector3.new(deltaX, 0, deltaZ)

        if localMove.Magnitude > 0.15 then
            if humanoid.WalkSpeed < 16 then
                humanoid.WalkSpeed = 16
            end
            local worldMove = deck.CFrame:VectorToWorldSpace(localMove)
            humanoid:Move(Vector3.new(worldMove.X, 0, worldMove.Z).Unit, false)
        else
            humanoid:Move(Vector3.zero, false)
        end
    end

    -- 2. VirtualInput Key Simulation: Press A/D keys for native engine integration
    if VirtualInput and VirtualInput.SendKeyEvent then
        pcall(function()
            if targetDeckX < -1.5 then
                if rafting.lastSteerKey ~= "A" then
                    if rafting.lastSteerKey == "D" then
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                    end
                    VirtualInput:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    rafting.lastSteerKey = "A"
                end
            elseif targetDeckX > 1.5 then
                if rafting.lastSteerKey ~= "D" then
                    if rafting.lastSteerKey == "A" then
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    end
                    VirtualInput:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    rafting.lastSteerKey = "D"
                end
            else
                if rafting.lastSteerKey then
                    if rafting.lastSteerKey == "A" then
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    elseif rafting.lastSteerKey == "D" then
                        VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                    end
                    rafting.lastSteerKey = nil
                end
            end
        end)
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

    -- Enforce Launch Distance Check: verify player is within 14 studs of the Launch part
    if root then
        local launchPos = part and part.Position or Vector3.new(-240.12, 703.99, 12.35)
        local dist = (root.Position - launchPos).Magnitude
        if dist > 14 then
            stopCharacterVelocity()
            root.CFrame = targetCF or CFrame.new(-240.12, 705.5, 12.35)
            task.wait(0.3)
        end
    end

    rafting.enabled = true
    rafting.visitedSites = {}
    rafting.isDockedState = false
    rafting.lastLootedSite = nil
    rafting.initClientListener()
    rafting.startSteeringLoop()
    rafting.statusText = "Starting session at Raft Yard..."
    rafting.isSailing = false
    rafting.updateCards()

    if prompt and fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    end
    rem:FireServer("Start")
    Window:Notify({ Title = "Rafting Started", Content = "Session requested at launch pad. Boarding raft...", Duration = 3 })
end

function rafting.endVoyage()
    rafting.stopSteeringLoop()
    local rem = rafting.getRemote()
    if rem then
        rem:FireServer("Return", nil)
    end
    rafting.isSailing = false
    rafting.currentSnapshot = nil
    rafting.status = "Idle"
    rafting.visitedSites = {}
    rafting.isDockedState = false
    rafting.statusText = "Voyage ended. Returned to shore."
    rafting.updateCards()

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
        Window:Notify({ Title = "Teleported", Content = "Teleported to Fjord Raft Launch Pad.", Duration = 3 })
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
            end
        end)
        table.insert(rafting.connections, rafting.clientEventConn)
    end
end

function rafting.startSteeringLoop()
    if rafting.heartbeatConn or rafting.renderSteppedConn then return end
    rafting.lastStepTime = os.clock()
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
    if rafting.isBoosting then
        rafting.isBoosting = false
        rafting.nextBoostAt = 0
        local rem = rafting.getRemote()
        if rem then pcall(function() rem:FireServer("BoostRelease") end) end
    end
    if VirtualInput and VirtualInput.SendKeyEvent and rafting.lastSteerKey then
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
    rafting.stopSteeringLoop()
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

RaftingTab:CreateSection({ Name = "Route Navigation Settings" })

RaftingTab:CreateDropdown({
    Name = "Rafting Route Profile",
    Options = {
        "Clearing & Chest Explorer",
        "Fast Sea Run (Center/Direct)",
        "North Channels (Caves & Drops)",
        "South Channels (Scenic & Clearings)"
    },
    CurrentOption = {"Clearing & Chest Explorer"},
    Flag = "Dropdown_Rafting_Route",
    Callback = function(Option)
        local chosen = type(Option) == "table" and Option[1] or Option
        rafting.route = chosen or "Clearing & Chest Explorer"
        rafting.updateCards()
    end,
})

RaftingTab:CreateSection({ Name = "Automation & Safety" })

RaftingTab:CreateToggle({
    Name = "Auto-Boost (Sprint on Straights)",
    CurrentValue = true,
    Flag = "Toggle_Rafting_AutoBoost",
    Callback = function(Value)
        rafting.autoBoost = Value
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
                    if trickOrTreat.isCycling and trickOrTreat.savedPreCFrame and root then
                        pcall(function() root.Anchored = false end)
                        pcall(function() char:PivotTo(trickOrTreat.savedPreCFrame) end)
                        pcall(function() setRootCFrame(trickOrTreat.savedPreCFrame) end)
                        pcall(stopCharacterVelocity)
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
-- BOOT: Initialize 6-Hour AFK Timer & State Resume
-- ==========================
afkRelog.startTimer()
afkRelog.checkAndResumeState()
