-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false,              -- true: remove running autofarm and stop
    AUTO_EQUIP = true,            -- auto-equip first owned companion if none equipped
    STAND_STILL = true,           -- anchor RootPart during cuddle (server checks Speed <= 0.8)
    TELEPORT_TO_PET = true,       -- teleport to companion if > 13 studs away
    CYCLE_DELAY = 3,              -- extra delay after each interaction (server reward lock is 8.0s from completion)
    SHOW_HUD = true,              -- show floating progress HUD
    STOP_ON_MAX = true,           -- auto-stop when 1.1500x (100% bond) reached
    MODE = "Feed",                -- "Feed": feed bait (only path that raised Bond in logs) | "Interact": nuzzle/play/explore
    ON_EMPTY = "Stop",            -- Feed mode, out of bait: "Stop" the autofarm | "Interact": switch to Interact mode
    HOLD_MAX = 15,                -- max seconds to stand still while an interaction runs
}
-- ==========================================================================

-- Companion Multiplier Autofarm
-- Automates companion interactions (Affection / Play / Explore) to max out
-- CompanionMultiplier from 1.0375x (base) to 1.1500x (+15.00% grazing calories).
--
-- Mechanics (Shared.CompanionCare / Shared.CompanionLife):
--   - Bond starts at 0.25 (untamed base)
--   - Each completed interaction yields +0.012 Bond
--   - Server reward cooldown: exactly 8.0s (NextReward = tick + 8)
--   - Max Bond (1.000) reached in ~63 interactions (~8.9 minutes)
--   - Formula: CompanionMultiplier = math.clamp(1 + (Bond * 0.15), 1, 1.15)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.CompanionAutofarm and type(_G.CompanionAutofarm.destroy) == "function" then
    pcall(_G.CompanionAutofarm.destroy)
end

if SETTINGS.DESTROY then
    return nil
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local cowGame = ReplicatedStorage:WaitForChild("CowGame", 10)
if not cowGame then
    warn("[CompanionAutofarm] ReplicatedStorage.CowGame not found.")
    return nil
end

local remotes = cowGame:WaitForChild("Remotes", 10)
local companionRequest = remotes and remotes:WaitForChild("CompanionRequest", 10)
if not companionRequest then
    warn("[CompanionAutofarm] Remotes.CompanionRequest not found.")
    return nil
end

local farm = {
    running = true,
    conns = {},
    gui = nil,
    ticksDone = 0,
    currentBond = 0.25,
    currentMult = 1.0375,
    lastInteraction = 0,
    statusText = "Initializing...",
}
_G.CompanionAutofarm = farm

-- Profile / GC extractor for accurate live bond state
local function getProfile()
    if type(getgc) ~= "function" then return nil end
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return nil end
    for _, obj in ipairs(objects) do
        if type(obj) == "table" and rawget(obj, "Remotes") and type(rawget(obj, "Store")) == "table" then
            local okState, state = pcall(function() return obj.Store:GetState() end)
            if okState and type(state) == "table" and type(state.Profile) == "table" then
                return state.Profile
            end
        end
    end
    return nil
end

local function getProfileCompanions()
    local profile = getProfile()
    return profile and type(profile.Companions) == "table" and profile.Companions or nil
end

-- Bait per species (Shared.CompanionConfig.Bait); one is used per feed. Count lives in Profile.Materials.
local BAIT = { Cat = "Catfish", Dog = "Chicken" }
local function baitCount(species)
    local id = BAIT[species]
    local profile = getProfile()
    local materials = profile and profile.Materials
    if not id or type(materials) ~= "table" then return nil end -- unknown: keep feeding
    return tonumber(materials[id]) or 0
end

-- Find physical companion model
local function findCompanionModel(runtimeId)
    local folders = { Workspace:FindFirstChild("LocalDogs"), Workspace:FindFirstChild("LocalBarnCats") }
    for _, folder in ipairs(folders) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") then
                    if runtimeId and child:GetAttribute("Id") == runtimeId then
                        return child
                    end
                end
            end
            -- fallback: first model if only one exists
            local children = folder:GetChildren()
            if #children == 1 and children[1]:IsA("Model") then
                return children[1]
            end
        end
    end
    return nil
end

-- Build HUD Card
local function createHud()
    if not SETTINGS.SHOW_HUD then return end

    local parentGui = (type(gethui) == "function" and gethui()) or CoreGui:FindFirstChild("RobloxGui") or plr:FindFirstChild("PlayerGui")
    local screen = Instance.new("ScreenGui")
    screen.Name = "CowHub_CompanionAutofarm"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 9999

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(0, 280, 0, 150)
    card.Position = UDim2.new(1, -295, 0, 120)
    card.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    card.BorderSizePixel = 0
    card.Active = true
    card.Draggable = true
    card.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(48, 56, 70)
    stroke.Thickness = 1.5
    stroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -16, 0, 24)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255, 215, 80)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "🐮 CowHub · Companion Multiplier Maxer"
    title.Parent = card

    local multLabel = Instance.new("TextLabel")
    multLabel.Name = "MultLabel"
    multLabel.Size = UDim2.new(1, -16, 0, 24)
    multLabel.Position = UDim2.new(0, 8, 0, 32)
    multLabel.BackgroundTransparency = 1
    multLabel.Font = Enum.Font.GothamBlack
    multLabel.TextSize = 18
    multLabel.TextColor3 = Color3.fromRGB(80, 255, 180)
    multLabel.TextXAlignment = Enum.TextXAlignment.Left
    multLabel.Text = "1.0375× (+3.8% Cal)"
    multLabel.Parent = card

    local bondLabel = Instance.new("TextLabel")
    bondLabel.Name = "BondLabel"
    bondLabel.Size = UDim2.new(1, -16, 0, 16)
    bondLabel.Position = UDim2.new(0, 8, 0, 58)
    bondLabel.BackgroundTransparency = 1
    bondLabel.Font = Enum.Font.GothamMedium
    bondLabel.TextSize = 12
    bondLabel.TextColor3 = Color3.fromRGB(200, 215, 230)
    bondLabel.TextXAlignment = Enum.TextXAlignment.Left
    bondLabel.Text = "Bond: 25.0% / 100.0% · 63 ticks left"
    bondLabel.Parent = card

    -- Progress Bar Background
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(1, -16, 0, 8)
    barBg.Position = UDim2.new(0, 8, 0, 80)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 36, 46)
    barBg.BorderSizePixel = 0
    barBg.Parent = card

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(0.25, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 230, 180)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -85, 0, 20)
    statusLabel.Position = UDim2.new(0, 8, 0, 94)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.fromRGB(160, 175, 195)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Text = "Status: Starting..."
    statusLabel.Parent = card

    local etaLabel = Instance.new("TextLabel")
    etaLabel.Name = "EtaLabel"
    etaLabel.Size = UDim2.new(1, -85, 0, 16)
    etaLabel.Position = UDim2.new(0, 8, 0, 116)
    etaLabel.BackgroundTransparency = 1
    etaLabel.Font = Enum.Font.GothamMedium
    etaLabel.TextSize = 11
    etaLabel.TextColor3 = Color3.fromRGB(230, 200, 120)
    etaLabel.TextXAlignment = Enum.TextXAlignment.Left
    etaLabel.Text = "ETA: ~8.9 min"
    etaLabel.Parent = card

    -- Stop Button
    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "StopBtn"
    stopBtn.Size = UDim2.new(0, 65, 0, 22)
    stopBtn.Position = UDim2.new(1, -73, 0, 94)
    stopBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 60)
    stopBtn.BorderSizePixel = 0
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 11
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.Text = "STOP"
    stopBtn.Parent = card

    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 4)
    stopCorner.Parent = stopBtn

    stopBtn.MouseButton1Click:Connect(function()
        farm.destroy()
    end)

    -- Mode picker: click to switch Feed <-> Interact (read by the next care tick)
    local modeBtn = Instance.new("TextButton")
    modeBtn.Name = "ModeBtn"
    modeBtn.Size = UDim2.new(0, 65, 0, 22)
    modeBtn.Position = UDim2.new(1, -73, 0, 120)
    modeBtn.BackgroundColor3 = Color3.fromRGB(45, 110, 190)
    modeBtn.BorderSizePixel = 0
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 11
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeBtn.Text = SETTINGS.MODE
    modeBtn.Parent = card

    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 4)
    modeCorner.Parent = modeBtn

    modeBtn.MouseButton1Click:Connect(function()
        SETTINGS.MODE = SETTINGS.MODE == "Feed" and "Interact" or "Feed"
        modeBtn.Text = SETTINGS.MODE
        farm.statusText = "Mode: " .. SETTINGS.MODE -- shown on the next HUD refresh (updateHud is defined below)
    end)

    screen.Parent = parentGui
    farm.gui = {
        screen = screen,
        multLabel = multLabel,
        bondLabel = bondLabel,
        barFill = barFill,
        statusLabel = statusLabel,
        etaLabel = etaLabel,
        modeBtn = modeBtn,
    }
end

-- Update HUD elements
local function updateHud()
    if not farm.gui then return end
    local bond = math.clamp(farm.currentBond, 0, 1)
    local mult = math.clamp(1 + (bond * 0.15), 1, 1.15)
    local bonus = (mult - 1) * 100

    farm.gui.multLabel.Text = string.format("%.4f× (+%.2f%% Cal)", mult, bonus)
    farm.gui.barFill.Size = UDim2.new(bond, 0, 1, 0)

    local remainingBond = math.max(0, 1 - bond)
    local remainingTicks = math.ceil(remainingBond / 0.012)
    local etaSec = remainingTicks * math.max(8, SETTINGS.CYCLE_DELAY) -- 8 s server reward lock
    local etaMin = math.floor(etaSec / 60)
    local etaSecMod = math.floor(etaSec % 60)

    if bond >= 1 then
        farm.gui.bondLabel.Text = "★ MAX BOND (100.0%) · 1.1500× CAP REACHED!"
        farm.gui.bondLabel.TextColor3 = Color3.fromRGB(80, 255, 180)
        farm.gui.etaLabel.Text = "ETA: Complete (0s)"
        farm.gui.statusLabel.Text = "Status: Cap Achieved"
        farm.gui.barFill.BackgroundColor3 = Color3.fromRGB(80, 255, 180)
    else
        farm.gui.bondLabel.Text = string.format("Bond: %.1f%% / 100.0%% · ~%d ticks left", bond * 100, remainingTicks)
        farm.gui.etaLabel.Text = string.format("ETA: ~%dm %02ds (%d ticks)", etaMin, etaSecMod, remainingTicks)
        farm.gui.statusLabel.Text = "Status: " .. farm.statusText
    end
end

-- Refresh live stats from profile
local function refreshLiveStats()
    local comps = getProfileCompanions()
    if comps and comps.Owned then
        local eqId = plr:GetAttribute("CowCompanionId") or comps.EquippedId
        if eqId and comps.Owned[eqId] then
            local data = comps.Owned[eqId]
            if type(data.Care) == "table" and type(data.Care.Bond) == "number" then
                farm.currentBond = data.Care.Bond
                farm.currentMult = math.clamp(1 + (data.Care.Bond * 0.15), 1, 1.15)
                return
            end
        end
    end
    -- fallback: estimate via ticks done
    farm.currentMult = math.clamp(1 + (farm.currentBond * 0.15), 1, 1.15)
end

-- Auto-Equip if none equipped
local function ensureEquipped()
    local compId = plr:GetAttribute("CowCompanionId")
    if compId and compId ~= "" then
        return true
    end

    if not SETTINGS.AUTO_EQUIP then
        return false
    end

    local comps = getProfileCompanions()
    if comps and comps.Owned then
        for id, _ in pairs(comps.Owned) do
            farm.statusText = "Auto-equipping " .. tostring(id) .. "..."
            updateHud()
            pcall(function()
                companionRequest:InvokeServer({
                    Action = "Equip",
                    Id = id,
                    Revision = comps.Revision or 1,
                })
            end)
            task.wait(1)
            return plr:GetAttribute("CowCompanionId") ~= nil
        end
    end
    return false
end

-- Single Care Interaction Tick
local function performCareTick()
    if not ensureEquipped() then
        farm.statusText = "No companion equipped! Equip one."
        updateHud()
        return false
    end

    local compId = plr:GetAttribute("CowCompanionId")
    local species = plr:GetAttribute("CowCompanionSpecies")
    local runtimeId = plr:GetAttribute("CowCompanionRuntimeId")
    local status = plr:GetAttribute("CowCompanionStatus")

    if not compId or not runtimeId then
        farm.statusText = "Waiting for companion spawn..."
        updateHud()
        return false
    end

    -- Pick interaction kind matching status cue
    local kind = "Affection"
    if status == "AskPlay" then
        kind = "Play"
    elseif status == "AskExplore" then
        kind = "Explore"
    end

    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then
        farm.statusText = "Waiting for character..."
        updateHud()
        return false
    end

    -- Proximity / Teleport
    local model = findCompanionModel(runtimeId)
    local petPart = model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true))
    if petPart then
        local dist = (root.Position - petPart.Position).Magnitude
        if dist > 13 and SETTINGS.TELEPORT_TO_PET then
            farm.statusText = "Moving to companion..."
            updateHud()
            local targetPos = petPart.Position + Vector3.new(0, 2, 0)
            root.CFrame = CFrame.new(targetPos, petPart.Position)
            task.wait(0.3)
        end
    end

    -- Stand Still guarantee (Speed <= 0.8)
    local prevAnchored = root.Anchored
    if SETTINGS.STAND_STILL then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = true
        task.wait(0.15)
    end

    farm.statusText = "Interacting (" .. kind .. ")..."
    updateHud()

    refreshLiveStats()
    local bondBefore = farm.currentBond

    -- Feed matches the game's own payload when grazing with bait equipped near the pet.
    -- Interact (nuzzle) mostly returns "Try again in a moment." and its 2 s Affection never paid Bond
    -- (logs companion_1794118105 / companion_1794118504); Feed raised Bond +0.012.
    local feeding = SETTINGS.MODE == "Feed"
    if feeding and baitCount(species) == 0 then
        local bait = BAIT[species] or "bait"
        if SETTINGS.ON_EMPTY == "Interact" then
            SETTINGS.MODE = "Interact"
            feeding = false
            if farm.gui and farm.gui.modeBtn then farm.gui.modeBtn.Text = "Interact" end
            print("[CompanionAutofarm] Out of " .. bait .. "; switched to Interact")
        else
            farm.statusText = "Out of " .. bait .. "; stopped"
            updateHud()
            print("[CompanionAutofarm] Out of " .. bait .. "; stopping")
            farm.running = false
            if SETTINGS.STAND_STILL then root.Anchored = prevAnchored end
            return false
        end
    end
    if feeding then kind = "Feed" end
    local success, reply = pcall(function()
        if feeding then
            return companionRequest:InvokeServer({ Species = species, Action = "Feed", TargetId = runtimeId })
        end
        return companionRequest:InvokeServer({
            Action = "Interact",
            Kind = kind,
            Id = compId,
            Species = species,
            TargetId = runtimeId,
        })
    end)

    -- Server reply, for diagnosing refused interactions
    local replyText = tostring(reply)
    if type(reply) == "table" then
        local parts = {}
        for k, v in pairs(reply) do parts[#parts + 1] = tostring(k) .. "=" .. tostring(v) end
        replyText = "{" .. table.concat(parts, ", ") .. "}"
    end
    print(string.format("[CompanionAutofarm] %s -> ok=%s reply=%s status=%s", kind, tostring(success), replyText, tostring(plr:GetAttribute("CowCompanionStatus"))))
    -- Also into the companion log when companion_status_export.lua is running
    local exporter = _G.CompanionStatusExport
    if exporter and type(exporter.emit) == "function" then
        pcall(exporter.emit, "request", {
            kind = kind,
            ok = success,
            reply = type(reply) == "table" and reply or tostring(reply),
            status = plr:GetAttribute("CowCompanionStatus"),
            bondBefore = bondBefore,
        })
    end

    -- The interaction runs while CowCompanionStatus == kind; moving cancels it (status -> None
    -- after ~2 s with no reward, log companion_1794117805). Stay still until it ends.
    if feeding then
        task.wait(1) -- profile Care syncs after the treat is accepted
    elseif success then
        local started = os.clock()
        while os.clock() - started < 1.5 and plr:GetAttribute("CowCompanionStatus") ~= kind do
            task.wait(0.1)
        end
        while os.clock() - started < SETTINGS.HOLD_MAX and plr:GetAttribute("CowCompanionStatus") == kind do
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.1)
        end
        task.wait(0.5) -- profile Care syncs after completion
    end

    if SETTINGS.STAND_STILL then
        root.Anchored = prevAnchored
    end

    -- Count only a real reward: live bond rose (Care.Bond, +0.012 per completion)
    refreshLiveStats()
    if success and farm.currentBond > bondBefore then
        farm.ticksDone += 1
        farm.statusText = string.format("Completed %s · Bond %.3f", kind, farm.currentBond)
        updateHud()
        return true
    end
    farm.statusText = success and ("No reward (" .. tostring(plr:GetAttribute("CowCompanionStatus")) .. "). Retrying...") or "Remote rejected. Retrying..."
    updateHud()
    return false
end

-- Main Loop
task.spawn(function()
    createHud()
    refreshLiveStats()
    updateHud()

    while farm.running do
        refreshLiveStats()
        updateHud()

        if farm.currentBond >= 1 then
            farm.statusText = "MAX BOND (100%) REACHED!"
            updateHud()
            print("[CompanionAutofarm] CompanionMultiplier maxed at 1.1500x (+15.00% cal)!")
            if SETTINGS.STOP_ON_MAX then
                break
            end
            task.wait(SETTINGS.CYCLE_DELAY)
        else
            performCareTick()
            task.wait(SETTINGS.CYCLE_DELAY)
        end
    end
end)

-- Cleanup / Destroy
function farm.destroy()
    farm.running = false
    for _, conn in ipairs(farm.conns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(farm.conns)
    if farm.gui and farm.gui.screen then
        pcall(function() farm.gui.screen:Destroy() end)
        farm.gui = nil
    end
    if _G.CompanionAutofarm == farm then
        _G.CompanionAutofarm = nil
    end
    print("[CompanionAutofarm] Stopped.")
end

print("[CompanionAutofarm] Initialized. Holding still through each interaction, then " .. tostring(SETTINGS.CYCLE_DELAY) .. "s between cycles.")
return farm

