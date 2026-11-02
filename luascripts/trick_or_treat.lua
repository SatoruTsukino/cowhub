--[[
    Trick or Treat Autofarm (Halloween Event)
    Automates visiting, approaching, and knocking on all farmer houses across CowWorld.
    Includes smart cooldown detection, automatic retry handling, collision bypass,
    anti-equip reward GUI dismissal, and live session telemetry.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local ContextActionService = game:GetService("ContextActionService")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

-- Virtual Input setup
local successVIM, VirtualInput = pcall(function()
    return game:GetService("VirtualInputManager")
end)
if not successVIM or not VirtualInput then
    VirtualInput = nil
end

local successVU, VirtualUser = pcall(function()
    return game:GetService("VirtualUser")
end)
if not successVU or not VirtualUser then
    VirtualUser = nil
end

-- Rayfield UI Initialization
local Rayfield = _G.CowHubRayfield
if not Rayfield then
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
    end)
    if ok and res then
        Rayfield = res
    end
end

local Window = nil
if Rayfield and Rayfield.CreateWindow then
    pcall(function()
        Window = Rayfield:CreateWindow({
            Name = "Trick or Treat Autofarm",
            Subtitle = "Halloween Event — CowHub",
            showIconOnly = false,
            theme = "rose",
            configuration = {
                enabled = true,
                folder = "CowHub",
                file = "TrickOrTreatConfig",
            },
        })
    end)
end

local function safeNotify(opts)
    if not Window or not opts then return end
    pcall(function()
        if Window.Notify then
            Window:Notify(opts)
        end
    end)
end

-- Character & Root Resolution Helpers
local char = plr.Character or plr.CharacterAdded:Wait()
local function resolveRoot(targetChar)
    if not targetChar then return nil end
    local r = targetChar:FindFirstChild("HumanoidRootPart")
    if r and r:IsA("BasePart") then return r end
    r = targetChar:FindFirstChild("RootPart")
    if r and r:IsA("BasePart") then return r end
    r = targetChar.PrimaryPart
    if r and r:IsA("BasePart") then return r end
    return targetChar:FindFirstChildWhichIsA("BasePart")
end

local root = resolveRoot(char)

local function resolveHumanoid(targetChar)
    if not targetChar then return nil end
    return targetChar:FindFirstChildOfClass("Humanoid") or targetChar:FindFirstChildWhichIsA("Humanoid")
end

local humanoid = resolveHumanoid(char)

local function resolveCharacter()
    local c = plr.Character
    if not c or not c.Parent then
        c = plr.CharacterAdded:Wait()
    end
    return c
end

local function getRootPos(r)
    if not r or not r.Parent then return nil end
    local ok, pos = pcall(function() return r.Position end)
    return ok and pos or nil
end

local function getRootCFrame(r)
    if not r or not r.Parent then return nil end
    local ok, cf = pcall(function() return r.CFrame end)
    return ok and cf or nil
end

local function setRootCFrame(cf)
    if not root or not root.Parent then return false end
    local ok = pcall(function() root.CFrame = cf end)
    return ok
end

local charBaseParts = {}
local function cacheCharParts(c)
    table.clear(charBaseParts)
    if not c then return end
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(charBaseParts, part)
        end
    end
end
cacheCharParts(char)

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = resolveRoot(newChar)
    humanoid = resolveHumanoid(newChar)
    cacheCharParts(newChar)
end)

-- Game Remotes
local cowGame = ReplicatedStorage:WaitForChild("CowGame", 10)
local cowRemotes = cowGame and cowGame:WaitForChild("Remotes", 10)
local trickOrTreatEvent = cowRemotes and (cowRemotes:FindFirstChild("TrickOrTreatRequest") or cowRemotes:WaitForChild("TrickOrTreatRequest", 5))

-- ==========================
-- STATE TABLE
-- ==========================
local trickOrTreat = {
    auto = false,
    autoDismissRewardGui = true,
    autoAcceptRewards = true,
    isCycling = false,
    isSingleRun = false,
    returnOnFinish = true,
    returnHeightOffset = 4.0,
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
    disableInsideCollision = true,
    approachOrigin = "Inside House",
    walkUpEnabled = true,
    walkDistance = 11.0,
    walkTimeout = 1.5,
    doorDistance = 2.0,
    doorHeightOffset = 0.0,
    cycleCooldown = 600,
    detectedCooldown = nil,
    autoDetectCooldown = true,
    nextCycleTime = 0,
    lastCycleCompletedTime = 0,
    housesVisitedCount = 0,
    lastHouseName = "",
    statusText = "Idle",
    remote = trickOrTreatEvent,
    loopRunning = false,
    clientEventConn = nil,
    statusCard = nil,
    infoCard = nil,
    telemetryCard = nil,
    cachedHousesFolder = nil,
    lastDeepSearch = 0,
    totalCycles = 0,
    totalHousesKnocked = 0,
    totalRewardsDismissed = 0,
    lastRewardDismissTime = 0,
    lastServerRewardTime = 0,
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
    local cowWorld = workspace:FindFirstChild("CowWorld")
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

    local cowWorld = workspace:FindFirstChild("CowWorld")
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

    local folder = trickOrTreat.getHousesFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            addCandidate(child)
        end
    end

    local cowWorld = workspace:FindFirstChild("CowWorld")
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
        knockX = doorPos.X - (outward.X * doorDist)
        knockZ = doorPos.Z - (outward.Z * doorDist)
        appX = doorPos.X - (outward.X * walkDist)
        appZ = doorPos.Z - (outward.Z * walkDist)
    else
        knockX = doorPos.X + (outward.X * doorDist)
        knockZ = doorPos.Z + (outward.Z * doorDist)
        local totalDist = doorDist + walkDist
        appX = doorPos.X + (outward.X * totalDist)
        appZ = doorPos.Z + (outward.Z * totalDist)
    end

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
                    if payload.Kind == "Scene" and payload.Outcome == "Candy" then
                        trickOrTreat.lastServerRewardTime = os.clock()
                    elseif payload.Kind == "Refused" and tostring(payload.Reason) == "Cooldown" and type(payload.Wait) == "number" then
                        local waitSecs = math.ceil(payload.Wait)
                        local houseName = tostring(payload.House or payload.HouseName or trickOrTreat.lastHouseName or "")
                        if houseName ~= "" then
                            trickOrTreat.houseCooldowns[houseName] = os.clock() + waitSecs
                        end

                        if waitSecs >= 10 then
                            trickOrTreat.longestDetectedCooldown = math.max(trickOrTreat.longestDetectedCooldown or 0, waitSecs)
                            if trickOrTreat.autoDetectCooldown then
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

-- ==========================
-- REWARD GUI DISMISSER (ANTI-EQUIP & VISIBILITY VALIDATED)
-- ==========================
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

    if name:find("wear") or name:find("equip")
        or text:find("wear") or text:find("equip") or text:find("try on") or text:find("put on")
        or label:find("wear") or label:find("equip") then
        return false
    end

    local isDismiss = false
    if name == "secondary" or name == "keepraiding" or name == "notnow"
        or name:find("close") or name:find("done") or name:find("claim") or name:find("accept")
        or name:find("okay") or name == "ok" or name:find("dismiss") or name:find("cancel") then
        isDismiss = true
    elseif name == "primary" then
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

function trickOrTreat.dismissRewardGui(force)
    if not force and trickOrTreat.autoDismissRewardGui == false and trickOrTreat.autoAcceptRewards == false then return false end
    local p = plr or Players.LocalPlayer
    local pg = nil
    pcall(function() pg = p and p:FindFirstChildWhichIsA("PlayerGui") end)
    if not pg then return false end
    local dismissed = false
    local vi = VirtualInput

    local targetGuiNames = {
        "RewardBoxReveal", "HalloweenReward", "TrickOrTreatReward", "CandyReveal",
        "EventReward", "CowFavoriteReward", "FavoriteRewardPrompt", "QuestModal",
        "TrickOrTreatModal", "TreatReveal", "CandyPailReveal", "CaravanCrateReveal"
    }
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
                            or gName:find("reward") or gName:find("reveal") or gName:find("treat")
                            or gName:find("candy") or gName:find("prize") or gName:find("halloween")
                            or gName:find("chest") or gName:find("crate") or gName:find("loot") then
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

    if dismissed then
        local now = os.clock()
        if (now - (trickOrTreat.lastRewardDismissTime or 0)) >= 1.5 then
            trickOrTreat.lastRewardDismissTime = now
            trickOrTreat.totalRewardsDismissed = (trickOrTreat.totalRewardsDismissed or 0) + 1
        end
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

    if not char or not char.Parent then char = resolveCharacter() end
    if not root or not root.Parent then root = resolveRoot(char) end
    if not humanoid or not humanoid.Parent then humanoid = resolveHumanoid(char) end
    if not root or not humanoid or humanoid.Health <= 0 then
        return false, "Player dead or missing character/root"
    end

    if house and trickOrTreat.disableInsideCollision then
        pcall(function() trickOrTreat.setHouseCollision(house, false) end)
    end

    pcall(function() root.Anchored = false end)
    pcall(function()
        char:PivotTo(approachCF)
        setRootCFrame(approachCF)
        stopCharacterVelocity()
    end)
    task.wait(0.05)

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

    if trickOrTreat.anchorDuringKnock then
        pcall(function() root.Anchored = true end)
    end

    task.wait(trickOrTreat.settleDelay)

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

    if house and trickOrTreat.disableInsideCollision then
        pcall(function() trickOrTreat.setHouseCollision(house, true) end)
    end

    trickOrTreat.currentHouseInteracting = nil
    return true
end

function trickOrTreat.runCycle()
    if trickOrTreat.isCycling then return end

    if not char or not char.Parent then char = resolveCharacter() end
    if not root or not root.Parent or not root:IsA("BasePart") then root = resolveRoot(char) end
    if not humanoid or not humanoid.Parent then humanoid = resolveHumanoid(char) end
    if not root or not char or not humanoid or humanoid.Health <= 0 then
        trickOrTreat.isCycling = false
        trickOrTreat.isSingleRun = false
        trickOrTreat.statusText = "Waiting for character spawn..."
        trickOrTreat.nextCycleTime = os.clock() + 10
        trickOrTreat.updateStatusUI()
        return
    end

    local now = os.clock()
    if not trickOrTreat.isSingleRun and trickOrTreat.nextCycleTime > now then
        trickOrTreat.updateStatusUI()
        return
    end

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

    local preCycleCFrame = getRootCFrame(root)
    trickOrTreat.savedPreCFrame = preCycleCFrame

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

    local housesToVisit = {}
    if trickOrTreat.isRetryPass then
        for _, hName in ipairs(candidateNames) do
            if trickOrTreat.erroredHouseNames[hName] or not trickOrTreat.completedHouseNames[hName] then
                local attempts = trickOrTreat.houseRetryAttempts[hName] or 0
                if attempts < (trickOrTreat.maxHouseRetries or 2) then
                    table.insert(housesToVisit, hName)
                else
                    warn(string.format("[TrickOrTreat] House %s exceeded max retries (%d). Skipping.", hName, attempts))
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

    trickOrTreat.totalHousesInCycle = #housesToVisit
    trickOrTreat.currentHouseIndex = 0
    for i, houseEntry in ipairs(housesToVisit) do
        if not trickOrTreat.auto and not trickOrTreat.isSingleRun then
            break
        end

        local hName = (typeof(houseEntry) == "Instance" and houseEntry.Name) or tostring(houseEntry)

        if not humanoid or humanoid.Health <= 0 or not root or not root.Parent then
            warn("[TrickOrTreat] Player died or lost character during cycle. Pausing.")
            trickOrTreat.erroredHouseNames[hName] = true
            break
        end

        local houseExpiry = trickOrTreat.houseCooldowns and trickOrTreat.houseCooldowns[hName]
        if not trickOrTreat.isSingleRun and houseExpiry and houseExpiry > os.clock() then
            local waitLeft = math.ceil(houseExpiry - os.clock())
            trickOrTreat.statusText = string.format("Skipping [%d/%d] %s (%ds cooldown left)", i, #housesToVisit, hName, waitLeft)
            trickOrTreat.updateStatusUI()
            trickOrTreat.completedHouseNames[hName] = true
            trickOrTreat.erroredHouseNames[hName] = nil
        else
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
                    warn(string.format("[TrickOrTreat] House %s error on attempt %d: %s", hName, attempt, tostring(visitErr)))
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
        trickOrTreat.statusText = string.format("%d house(s) errored. Retrying in 4s...", remainingErrors)
        trickOrTreat.currentPhase = "Retrying Failed Houses"
        trickOrTreat.nextCycleTime = os.clock() + 4
        trickOrTreat.isCycling = false
        trickOrTreat.updateStatusUI()

        if trickOrTreat.returnOnFinish and preCycleCFrame then
            safeReturnToSavedPosition(preCycleCFrame)
        end
        return
    end

    trickOrTreat.isRetryPass = false
    trickOrTreat.completedHouseNames = {}
    trickOrTreat.erroredHouseNames = {}
    trickOrTreat.houseRetryAttempts = {}

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
                        warn("[TrickOrTreat] Error during cycle:\n" .. tostring(err))
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

    if Window and Window.Flags then
        if Window.Flags.Toggle_TrickOrTreat ~= Value then
            pcall(function() Window:Set("Toggle_TrickOrTreat", Value) end)
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
            -- Cooldown in progress
        elseif trickOrTreat.lastCycleCompletedTime > 0 and (now - trickOrTreat.lastCycleCompletedTime < cd) then
            trickOrTreat.nextCycleTime = trickOrTreat.lastCycleCompletedTime + cd
        else
            trickOrTreat.nextCycleTime = 0
        end

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
end

-- ==========================
-- PROXIMITY PROMPT & POPUP LISTENERS
-- ==========================
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
                if promptName:find("knock") or promptName:find("door") or promptName:find("treat") or pName:find("door") or grandParentName:find("farmerhouse") then
                    if trickOrTreat.autoDismissRewardGui then
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

            if trickOrTreat.autoDismissRewardGui and (
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

-- ==========================
-- USER INTERFACE (RAYFIELD TAB / WINDOW)
-- ==========================
if Window then
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
                    warn("[TrickOrTreat] Stuck isCycling flag detected (>60s). Resetting.")
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
                    warn("[TrickOrTreat] Error during single cycle:\n" .. tostring(err))
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
                        task.delay(4.5, function()
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
        Name = "Return to Start Position",
        Callback = function()
            if trickOrTreat.savedPreCFrame then
                safeReturnToSavedPosition(trickOrTreat.savedPreCFrame)
                safeNotify({ Title = "Returned", Content = "Returned to start position.", Duration = 2 })
            else
                safeNotify({ Title = "No Saved Position", Content = "No start position saved yet.", Duration = 2 })
            end
        end,
    })

    TotTab:CreateSection({ Name = "Status & Telemetry" })

    pcall(function()
        if TotTab.CreateText then
            trickOrTreat.statusCard = TotTab:CreateText({
                Title = "Status: Idle",
                Content = "Autofarm is currently OFF.",
            })
        end
    end)
    if not trickOrTreat.statusCard and TotTab.CreateParagraph then
        pcall(function()
            trickOrTreat.statusCard = TotTab:CreateParagraph({
                Title = "Status: Idle",
                Content = "Autofarm is currently OFF.",
            })
        end)
    end

    pcall(function()
        if TotTab.CreateText then
            trickOrTreat.infoCard = TotTab:CreateText({
                Title = "Script Telemetry | Cycles: 0 | Knocked: 0",
                Content = "Uptime: 00:00 | Total Cycles: 0 | Total Knocked: 0\nRewards Dismissed: 0 | Avg/Cycle: 0 | Last Duration: 0.0s\nCooldown: 10:00 (Auto) | Pos: N/A",
            })
            trickOrTreat.telemetryCard = trickOrTreat.infoCard
        end
    end)
    if not trickOrTreat.infoCard and TotTab.CreateParagraph then
        pcall(function()
            trickOrTreat.infoCard = TotTab:CreateParagraph({
                Title = "Script Telemetry | Cycles: 0 | Knocked: 0",
                Content = "Uptime: 00:00 | Total Cycles: 0 | Total Knocked: 0\nRewards Dismissed: 0 | Avg/Cycle: 0 | Last Duration: 0.0s\nCooldown: 10:00 (Auto) | Pos: N/A",
            })
            trickOrTreat.telemetryCard = trickOrTreat.infoCard
        end)
    end

    TotTab:CreateButton({
        Name = "Reset Telemetry Counters",
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
        Range = {30, 1800},
        Increment = 15,
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
        Name = "Village Map Load Delay",
        Range = {0.5, 8.0},
        Increment = 0.5,
        Suffix = "s",
        CurrentValue = trickOrTreat.barnLoadDelay,
        Flag = "Slider_ToT_BarnDelay",
        Callback = function(Value)
            trickOrTreat.barnLoadDelay = Value
        end,
    })

    TotTab:CreateSlider({
        Name = "House Interaction Delay",
        Range = {0.8, 4.0},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = trickOrTreat.houseWaitTime,
        Flag = "Slider_ToT_HouseWait",
        Callback = function(Value)
            trickOrTreat.houseWaitTime = Value
        end,
    })

    TotTab:CreateSlider({
        Name = "Pre-Knock Settle Delay",
        Range = {0.1, 1.5},
        Increment = 0.05,
        Suffix = "s",
        CurrentValue = trickOrTreat.settleDelay,
        Flag = "Slider_ToT_SettleDelay",
        Callback = function(Value)
            trickOrTreat.settleDelay = Value
        end,
    })

    TotTab:CreateSlider({
        Name = "Knock Distance from Door",
        Range = {0.5, 6.0},
        Increment = 0.5,
        Suffix = " studs",
        CurrentValue = trickOrTreat.doorDistance,
        Flag = "Slider_ToT_DoorDistance",
        Callback = function(Value)
            trickOrTreat.doorDistance = Value
        end,
    })

    TotTab:CreateSlider({
        Name = "Door Height Offset",
        Range = {-2.0, 5.0},
        Increment = 0.5,
        Suffix = " studs",
        CurrentValue = trickOrTreat.doorHeightOffset,
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
        CurrentValue = trickOrTreat.returnHeightOffset,
        Flag = "Slider_ToT_ReturnHeightOffset",
        Callback = function(Value)
            trickOrTreat.returnHeightOffset = Value
        end,
    })

    TotTab:CreateToggle({
        Name = "Disable House Collision During Knock",
        CurrentValue = true,
        Flag = "Toggle_ToT_DisableInsideCollision",
        Callback = function(Value)
            trickOrTreat.disableInsideCollision = Value
        end,
    })

    TotTab:CreateDropdown({
        Name = "Approach Origin Position",
        Options = {"Inside House", "Outside Porch"},
        CurrentOption = {trickOrTreat.approachOrigin},
        MultipleOptions = false,
        Flag = "Dropdown_ToT_ApproachOrigin",
        Callback = function(Option)
            local chosen = type(Option) == "table" and Option[1] or Option
            trickOrTreat.approachOrigin = chosen or "Inside House"
        end,
    })

    TotTab:CreateToggle({
        Name = "Walk Up Towards Door",
        CurrentValue = true,
        Flag = "Toggle_ToT_WalkUp",
        Callback = function(Value)
            trickOrTreat.walkUpEnabled = Value
        end,
    })

    TotTab:CreateSlider({
        Name = "Walk-Up Starting Distance",
        Range = {4.0, 20.0},
        Increment = 1.0,
        Suffix = " studs",
        CurrentValue = trickOrTreat.walkDistance,
        Flag = "Slider_ToT_WalkDistance",
        Callback = function(Value)
            trickOrTreat.walkDistance = Value
        end,
    })

    TotTab:CreateSlider({
        Name = "Walk-Up Max Timeout",
        Range = {0.5, 4.0},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = trickOrTreat.walkTimeout,
        Flag = "Slider_ToT_WalkTimeout",
        Callback = function(Value)
            trickOrTreat.walkTimeout = Value
        end,
    })

    TotTab:CreateToggle({
        Name = "Return to Start After Cycle",
        CurrentValue = true,
        Flag = "Toggle_ToT_ReturnOnFinish",
        Callback = function(Value)
            trickOrTreat.returnOnFinish = Value
        end,
    })

    TotTab:CreateToggle({
        Name = "Anchor Character During Knock",
        CurrentValue = true,
        Flag = "Toggle_ToT_AnchorKnock",
        Callback = function(Value)
            trickOrTreat.anchorDuringKnock = Value
        end,
    })

    TotTab:CreateToggle({
        Name = "Auto-Detect Server Cooldown",
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
end

trickOrTreat.initClientListener()
trickOrTreat.detectCooldown()
trickOrTreat.updateStatusUI()

return trickOrTreat

