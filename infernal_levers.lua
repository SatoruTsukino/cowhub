--[[
    Lobotomy Simulator: Infernal — Lever Automator & Return Home
    Automates finding, teleporting, interacting with all 8 levers,
    auto-completing the pull minigame, and teleporting back home.

    Workspace path: workspace.Game.Levers
    Home default: workspace.Environment.SpawnLocation (Elevator room)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================================
-- CONSTANTS & DUMPED COORDINATES
-- Source: Place_114526296398286_Folder_Levers_1792911698.txt
--         Place_114526296398286_Lobotomy Simulator: Infernal_25-10-2026_00-23-57.xml
-- ============================================================================

local DEFAULT_HOME_CFRAME = CFrame.new(-125.95, 265.5, 6.55) -- Elevator / SpawnLocation
local START_LEVER_CFRAME = CFrame.new(-67.91, 269.35, -0.49) -- workspace.Game.Start.LeverDetection

local KNOWN_LEVERS = {
    {
        id = 1,
        mainPos = Vector3.new(313.61, 269.95, 24.58),
        camPos = Vector3.new(313.63, 269.60, 21.99),
        cframe = CFrame.new(313.631134, 269.599976, 21.993845, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    },
    {
        id = 2,
        mainPos = Vector3.new(334.74, 269.95, -132.30),
        camPos = Vector3.new(337.32, 269.60, -132.28),
        cframe = CFrame.new(337.32074, 269.599976, -132.275009, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    },
    {
        id = 3,
        mainPos = Vector3.new(122.61, 269.95, 24.58),
        camPos = Vector3.new(122.63, 269.60, 21.99),
        cframe = CFrame.new(122.631119, 269.599976, 21.993845, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    },
    {
        id = 4,
        mainPos = Vector3.new(185.77, 269.60, -98.24),
        camPos = Vector3.new(185.75, 269.25, -95.65),
        cframe = CFrame.new(185.75, 269.25, -95.654205, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    },
    {
        id = 5,
        mainPos = Vector3.new(96.76, 269.95, 215.73),
        camPos = Vector3.new(96.78, 269.60, 213.14),
        cframe = CFrame.new(96.781578, 269.599976, 213.14386, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    },
    {
        id = 6,
        mainPos = Vector3.new(187.17, 269.60, 129.06),
        camPos = Vector3.new(187.15, 269.25, 131.65),
        cframe = CFrame.new(187.149994, 269.25, 131.645798, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    },
    {
        id = 7,
        mainPos = Vector3.new(334.74, 269.95, 160.70),
        camPos = Vector3.new(337.32, 269.60, 160.73),
        cframe = CFrame.new(337.32074, 269.599976, 160.725006, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    },
    {
        id = 8,
        mainPos = Vector3.new(313.71, 269.95, 120.28),
        camPos = Vector3.new(313.73, 269.60, 117.69),
        cframe = CFrame.new(313.73114, 269.599976, 117.693848, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    },
}

-- ============================================================================
-- STATE CONFIGURATION
-- ============================================================================

local State = {
    homeCFrame = DEFAULT_HOME_CFRAME,
    useStartAsHome = true, -- If true, sets Home to player position right before running
    isRunning = false,
    autoSolveMinigame = true,
    simulatePhysicalDrag = true, -- Simulates downward drag motion and timing
    dragDuration = 0.25, -- Duration to simulate lever pull down
    teleportDelay = 0.35,
    promptHoldDelay = 0.30,
    teleportHomeWhenDone = true,
    espEnabled = false,
    currentProgress = 0,
    totalRequired = 5,
    completedLevers = {},
    statusText = "Ready",
}

-- ============================================================================
-- REMOTES RESOLUTION
-- ============================================================================

local objectiveEvents = ReplicatedStorage:WaitForChild("InfernalObjectiveEvents", 10)
local remotes = {
    LeverInteractionStart = objectiveEvents and objectiveEvents:WaitForChild("LeverInteractionStart", 10),
    LeverInteractionComplete = objectiveEvents and objectiveEvents:WaitForChild("LeverInteractionComplete", 10),
    LeverProgress = objectiveEvents and objectiveEvents:WaitForChild("LeverProgress", 10),
    FinalLeverActivated = objectiveEvents and objectiveEvents:WaitForChild("FinalLeverActivated", 10),
    GateStatus = objectiveEvents and objectiveEvents:WaitForChild("GateStatus", 10),
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

local function log(msg)
    print("[InfernalLevers] " .. tostring(msg))
end

local function getRootPart()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function safeTeleport(cframe, extraWait)
    local root = getRootPart()
    if not root then return false end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = cframe
    task.wait(extraWait or 0.05)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function cleanupCameraAndLocks()
    pcall(function()
        LocalPlayer:SetAttribute("InfernalLeverInteracting", false)
        RunService:UnbindFromRenderStep("InfernalLeverInteractionCamera")

        local cam = Workspace.CurrentCamera
        local hum = getHumanoid()
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            if hum and hum.Parent then
                cam.CameraSubject = hum
                hum.AutoRotate = true
            end
        end

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true

        -- Clean up client highlight if left behind
        local leversFolder = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Levers")
        if leversFolder then
            for _, item in ipairs(leversFolder:GetDescendants()) do
                if item:IsA("Highlight") and item.Name == "InfernalLeverHighlight" then
                    item:Destroy()
                end
            end
        end
    end)
end

local function triggerPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    if not prompt.Enabled then return false end

    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt, 1, true)
        end)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.05)
            prompt:InputHoldEnd()
        end)
    end
    return true
end

-- ============================================================================
-- LEVERS FOLDER & OBJECT RESOLUTION
-- Path: workspace.Game.Levers
-- ============================================================================

local function getLeversFolder()
    local gameFolder = Workspace:FindFirstChild("Game")
    if gameFolder then
        local levers = gameFolder:FindFirstChild("Levers")
        if levers then return levers end
    end
    return nil
end

local function resolveLevers()
    local resolved = {}
    local leversFolder = getLeversFolder()
    local foundModels = leversFolder and leversFolder:GetChildren() or {}

    for idx, known in ipairs(KNOWN_LEVERS) do
        local matchedModel = nil
        local bestDist = 15 -- max matching radius in studs

        for _, model in ipairs(foundModels) do
            if model:IsA("Model") then
                local main = model:FindFirstChild("Main")
                if main and main:IsA("BasePart") then
                    local dist = (main.Position - known.mainPos).Magnitude
                    if dist < bestDist then
                        matchedModel = model
                        bestDist = dist
                    end
                end
            end
        end

        local mainPart = matchedModel and matchedModel:FindFirstChild("Main")
        local prompt = mainPart and mainPart:FindFirstChildWhichIsA("ProximityPrompt")
        local camPart = matchedModel and matchedModel:FindFirstChild("Camera_Position")

        local standCF = known.cframe
        if camPart and camPart:IsA("BasePart") and mainPart and mainPart:IsA("BasePart") then
            standCF = CFrame.lookAt(camPart.Position, mainPart.Position)
        end

        table.insert(resolved, {
            index = idx,
            model = matchedModel,
            main = mainPart,
            prompt = prompt,
            cframe = standCF,
            known = known,
        })
    end

    return resolved
end

local function isLeverActive(leverData)
    if State.completedLevers[leverData.index] then
        return false
    end
    if leverData.prompt and not leverData.prompt.Enabled then
        return false
    end
    return true
end

local function simulatePhysicalPull()
    -- Simulates downward drag motion that the client script InfernalLeverInteractionClient listens for
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local cam = Workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local cx, cy = vp.X / 2, vp.Y / 2

        if vim then
            vim:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
            for i = 1, 6 do
                task.wait(0.03)
                vim:SendMouseMoveEvent(cx, cy + (i * 35), game)
            end
            task.wait(0.04)
            vim:SendMouseButtonEvent(cx, cy + 210, 0, false, game, 0)
        elseif mouse1press and mousemoverel and mouse1release then
            mouse1press()
            for _ = 1, 5 do
                task.wait(0.04)
                mousemoverel(0, 45)
            end
            task.wait(0.04)
            mouse1release()
        end
    end)
end

-- ============================================================================
-- AUTOMATIC MINIGAME COMPLETION LISTENER
-- When server triggers LeverInteractionStart, handle physical pull & completion
-- ============================================================================

if remotes.LeverInteractionStart and remotes.LeverInteractionComplete then
    remotes.LeverInteractionStart.OnClientEvent:Connect(function(id, mainPart)
        log("Lever minigame started for ID: " .. tostring(id))

        if State.autoSolveMinigame then
            if State.simulatePhysicalDrag then
                task.spawn(simulatePhysicalPull)
                task.wait(State.dragDuration)
            else
                task.wait(0.08)
            end

            pcall(function()
                remotes.LeverInteractionComplete:FireServer(id, true)
            end)
            log("Fired LeverInteractionComplete for ID: " .. tostring(id))

            task.delay(0.15, cleanupCameraAndLocks)
        end
    end)
end

if remotes.LeverProgress then
    remotes.LeverProgress.OnClientEvent:Connect(function(current, total)
        State.currentProgress = tonumber(current) or State.currentProgress
        State.totalRequired = tonumber(total) or State.totalRequired
        State.statusText = string.format("%d/%d Levers Activated", State.currentProgress, State.totalRequired)
        log(State.statusText)
    end)
end

if remotes.FinalLeverActivated then
    remotes.FinalLeverActivated.OnClientEvent:Connect(function()
        log("All required levers activated! Gate is opening.")
        State.statusText = "Gate opening! Escaping home..."
        if State.teleportHomeWhenDone then
            safeTeleport(State.homeCFrame, 0.1)
        end
    end)
end

-- ============================================================================
-- CORE WORKFLOWS
-- ============================================================================

local function teleportHome()
    log("Teleporting to Home...")
    cleanupCameraAndLocks()
    safeTeleport(State.homeCFrame, 0.1)
end

local function interactSingleLever(leverData)
    log(string.format("Interacting with Lever #%d...", leverData.index))

    -- 1. Teleport to stand position
    safeTeleport(leverData.cframe, 0.08)
    task.wait(State.teleportDelay)

    -- 2. Trigger ProximityPrompt
    local prompt = leverData.prompt
    if not prompt and leverData.model then
        prompt = leverData.model:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    if prompt and prompt.Enabled then
        triggerPrompt(prompt)
        task.wait(State.promptHoldDelay)
    else
        -- If prompt not loaded, try clicking or remote directly
        log(string.format("Prompt missing or disabled for Lever #%d, attempting direct complete", leverData.index))
        if remotes.LeverInteractionComplete then
            pcall(function()
                remotes.LeverInteractionComplete:FireServer(leverData.index, true)
            end)
        end
    end

    -- 3. Cleanup camera/mouse state
    cleanupCameraAndLocks()
    State.completedLevers[leverData.index] = true
end

local function runAllLevers()
    if State.isRunning then
        log("Automation already running!")
        return
    end

    State.isRunning = true
    State.statusText = "Running levers automation..."

    -- Save dynamic home if enabled
    local root = getRootPart()
    if State.useStartAsHome and root then
        State.homeCFrame = root.CFrame
        log("Saved starting position as Home: " .. tostring(root.Position))
    end

    local levers = resolveLevers()
    local completedCount = 0

    for _, lever in ipairs(levers) do
        if not State.isRunning then break end

        if isLeverActive(lever) then
            State.statusText = string.format("Pulling Lever #%d...", lever.index)
            interactSingleLever(lever)
            completedCount = completedCount + 1
            task.wait(State.teleportDelay)
        else
            log(string.format("Lever #%d already pulled, skipping.", lever.index))
        end
    end

    -- Teleport back home when finished
    if State.teleportHomeWhenDone then
        State.statusText = "Teleporting back Home..."
        task.wait(0.2)
        teleportHome()
    end

    State.isRunning = false
    State.statusText = string.format("Finished! Pulled %d levers.", completedCount)
    log(State.statusText)
end

local function stopAutomation()
    State.isRunning = false
    State.statusText = "Stopped"
    cleanupCameraAndLocks()
end

-- ============================================================================
-- ESP HIGHLIGHTS & BILLBOARDS
-- ============================================================================

local espFolder = nil

local function clearESP()
    if espFolder then
        espFolder:Destroy()
        espFolder = nil
    end
end

local function updateESP()
    clearESP()
    if not State.espEnabled then return end

    espFolder = Instance.new("Folder")
    espFolder.Name = "InfernalLeverESP"
    espFolder.Parent = Workspace

    local levers = resolveLevers()
    for _, lever in ipairs(levers) do
        local main = lever.main or (lever.model and lever.model:FindFirstChild("Main"))
        if main and main:IsA("BasePart") then
            -- Highlight
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_HL_" .. lever.index
            hl.Adornee = lever.model or main
            hl.FillColor = State.completedLevers[lever.index] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 180, 0)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = espFolder

            -- Billboard
            local bb = Instance.new("BillboardGui")
            bb.Name = "ESP_BB_" .. lever.index
            bb.Adornee = main
            bb.Size = UDim2.new(0, 120, 0, 40)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent = espFolder

            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextColor3 = State.completedLevers[lever.index] and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 210, 50)
            label.TextStrokeTransparency = 0.2
            label.Text = string.format("Lever #%d\n[%s]", lever.index, State.completedLevers[lever.index] and "PULLED" or "PENDING")
            label.Parent = bb
        end
    end
end

-- ============================================================================
-- USER INTERFACE (RAYFIELD OR CLEAN FALLBACK)
-- ============================================================================

local function buildRayfieldUI()
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)

    if not success or not Rayfield then
        log("Rayfield failed to load. Launching fallback standalone GUI.")
        return false
    end

    local Window = Rayfield:CreateWindow({
        Name = "Lobotomy Simulator: Infernal — Levers",
        LoadingTitle = "Infernal Levers Hub",
        LoadingSubtitle = "Auto Levers & Teleport Home",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Automation", 4483362458)

    local StatusLabel = MainTab:CreateLabel("Status: Ready (0/5)")

    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                StatusLabel:Set(string.format("Status: %s (%d/%d)", State.statusText, State.currentProgress, State.totalRequired))
            end)
        end
    end)

    MainTab:CreateButton({
        Name = "▶ Start Auto Levers & Teleport Home",
        Callback = function()
            task.spawn(runAllLevers)
        end,
    })

    MainTab:CreateButton({
        Name = "⏹ Stop Automation",
        Callback = function()
            stopAutomation()
        end,
    })

    MainTab:CreateButton({
        Name = "🏠 Teleport Home Now",
        Callback = function()
            teleportHome()
        end,
    })

    MainTab:CreateButton({
        Name = "📍 Set Current Position as Home",
        Callback = function()
            local root = getRootPart()
            if root then
                State.homeCFrame = root.CFrame
                log("Updated Home to current position.")
            end
        end,
    })

    MainTab:CreateButton({
        Name = "🔄 Reset Home to Elevator (Spawn)",
        Callback = function()
            State.homeCFrame = DEFAULT_HOME_CFRAME
            log("Reset Home to Elevator / SpawnLocation.")
        end,
    })

    MainTab:CreateButton({
        Name = "🔓 Unstuck Controls & Reset Camera",
        Callback = function()
            cleanupCameraAndLocks()
            log("Controls unlocked and camera reset.")
        end,
    })

    local SettingsTab = Window:CreateTab("Settings", 4483362458)

    SettingsTab:CreateToggle({
        Name = "Auto Teleport Home When Done",
        CurrentValue = State.teleportHomeWhenDone,
        Flag = "TeleportHomeDone",
        Callback = function(val)
            State.teleportHomeWhenDone = val
        end,
    })

    SettingsTab:CreateToggle({
        Name = "Save Start Position as Home",
        CurrentValue = State.useStartAsHome,
        Flag = "StartAsHome",
        Callback = function(val)
            State.useStartAsHome = val
        end,
    })

    SettingsTab:CreateToggle({
        Name = "Auto-Solve Pull Minigame",
        CurrentValue = State.autoSolveMinigame,
        Flag = "AutoSolveMinigame",
        Callback = function(val)
            State.autoSolveMinigame = val
        end,
    })

    SettingsTab:CreateToggle({
        Name = "Simulate Physical Drag",
        CurrentValue = State.simulatePhysicalDrag,
        Flag = "SimulatePhysicalDrag",
        Callback = function(val)
            State.simulatePhysicalDrag = val
        end,
    })

    SettingsTab:CreateSlider({
        Name = "Drag Pull Duration (sec)",
        Range = {0.05, 1.0},
        Increment = 0.05,
        CurrentValue = State.dragDuration,
        Flag = "DragDuration",
        Callback = function(val)
            State.dragDuration = val
        end,
    })

    SettingsTab:CreateToggle({
        Name = "Lever ESP & Highlights",
        CurrentValue = State.espEnabled,
        Flag = "LeverESP",
        Callback = function(val)
            State.espEnabled = val
            updateESP()
        end,
    })

    SettingsTab:CreateSlider({
        Name = "Teleport Delay (sec)",
        Range = {0.1, 1.5},
        Increment = 0.05,
        CurrentValue = State.teleportDelay,
        Flag = "TeleportDelay",
        Callback = function(val)
            State.teleportDelay = val
        end,
    })

    local TeleportTab = Window:CreateTab("Teleports", 4483362458)

    TeleportTab:CreateButton({
        Name = "Teleport to Start Lever",
        Callback = function()
            safeTeleport(START_LEVER_CFRAME, 0.1)
        end,
    })

    for i = 1, 8 do
        TeleportTab:CreateButton({
            Name = string.format("Teleport to Lever #%d", i),
            Callback = function()
                local levers = resolveLevers()
                if levers[i] then
                    safeTeleport(levers[i].cframe, 0.1)
                end
            end,
        })
    end

    return true
end

local function buildFallbackUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "InfernalLeversFallbackGui"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 260)
    frame.Position = UDim2.new(0.02, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.Text = "Infernal Levers Hub"
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 24)
    status.Position = UDim2.new(0, 10, 0, 34)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(180, 220, 255)
    status.Text = "Status: Ready"
    status.Parent = frame

    local function createBtn(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 32)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.Parent = frame

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    createBtn("▶ Run All Levers & Home", 65, function()
        task.spawn(runAllLevers)
    end)

    createBtn("🏠 Teleport Home", 105, function()
        teleportHome()
    end)

    createBtn("📍 Set Pos as Home", 145, function()
        local root = getRootPart()
        if root then State.homeCFrame = root.CFrame end
    end)

    createBtn("🔓 Unstuck Controls", 185, function()
        cleanupCameraAndLocks()
    end)

    task.spawn(function()
        while task.wait(0.5) and gui.Parent do
            status.Text = string.format("Status: %s (%d/%d)", State.statusText, State.currentProgress, State.totalRequired)
        end
    end)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Try Rayfield UI, fallback to clean draggable ScreenGui if Rayfield fails
if not buildRayfieldUI() then
    buildFallbackUI()
end

-- Keybind shortcuts: Press [X] to run levers, [H] to teleport home
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then
        task.spawn(runAllLevers)
    elseif input.KeyCode == Enum.KeyCode.H then
        teleportHome()
    end
end)

log("Infernal Levers Automator initialized. Hotkeys: [X] Run All, [H] Teleport Home.")

return {
    Run = runAllLevers,
    Stop = stopAutomation,
    TeleportHome = teleportHome,
    ResolveLevers = resolveLevers,
    State = State,
}
