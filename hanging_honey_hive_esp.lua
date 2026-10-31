-- HangingHoneyHive Model ESP
-- Mirrors LocalTeamChest ESP pattern from CowHub for workspace.LocalCowBeeHives.HangingHoneyHive

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Prevent duplicate instances on re-execution
if _G.HangingHoneyHiveESP and type(_G.HangingHoneyHiveESP.destroy) == "function" then
    pcall(_G.HangingHoneyHiveESP.destroy)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local hiveESP = {
    enabled = true,
    highlight = nil,
    billboard = nil,
    espConn = nil,
    ancestryConn = nil,
    wsChildAddedConn = nil,
    wsChildRemovedConn = nil,
    folderChildAddedConn = nil,
    folderChildRemovedConn = nil,
}

local function getRootPos()
    local char = plr.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
    if not root then return nil end
    return root.Position
end

local function cleanupVisuals()
    if hiveESP.espConn then
        pcall(function() hiveESP.espConn:Disconnect() end)
        hiveESP.espConn = nil
    end
    if hiveESP.ancestryConn then
        pcall(function() hiveESP.ancestryConn:Disconnect() end)
        hiveESP.ancestryConn = nil
    end
    if hiveESP.highlight then
        pcall(function() hiveESP.highlight:Destroy() end)
        hiveESP.highlight = nil
    end
    if hiveESP.billboard then
        pcall(function() hiveESP.billboard:Destroy() end)
        hiveESP.billboard = nil
    end
end

local function attach(trackedHive)
    cleanupVisuals()
    if not trackedHive or not trackedHive.Parent then return end

    local hivePart = trackedHive:IsA("Model") and (trackedHive.PrimaryPart or trackedHive:FindFirstChildWhichIsA("BasePart")) or (trackedHive:IsA("BasePart") and trackedHive)
    if not hivePart then
        hivePart = trackedHive:FindFirstChildWhichIsA("BasePart", true)
    end
    if not hivePart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "HoneyHiveHighlight"
    highlight.Adornee = trackedHive
    highlight.FillColor = Color3.fromRGB(255, 185, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = trackedHive
    hiveESP.highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HoneyHiveESPText"
    billboard.Adornee = hivePart
    billboard.Size = UDim2.new(0, 160, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "🍯 Hanging Honey Hive"
    textLabel.Parent = billboard
    billboard.Parent = trackedHive
    hiveESP.billboard = billboard

    hiveESP.ancestryConn = trackedHive.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanupVisuals()
        end
    end)

    local lastDist = -1
    local lastHiveUpdate = 0
    hiveESP.espConn = RunService.Heartbeat:Connect(function()
        if not hiveESP.enabled or not trackedHive.Parent or not hivePart.Parent then
            cleanupVisuals()
            return
        end
        local now = os.clock()
        if now - lastHiveUpdate > 0.1 then
            lastHiveUpdate = now
            local rPos = getRootPos()
            if rPos and hivePart.Parent then
                local hPos = hivePart.Position
                local dx = rPos.X - hPos.X
                local dy = rPos.Y - hPos.Y
                local dz = rPos.Z - hPos.Z
                local dist = math.floor(math.sqrt(dx * dx + dy * dy + dz * dz))
                if dist ~= lastDist then
                    lastDist = dist
                    textLabel.Text = "🍯 Hanging Honey Hive\n[" .. dist .. " studs]"
                end
            end
        end
    end)
end

local function hookFolder(folder)
    if not folder then return end

    if hiveESP.folderChildAddedConn then
        pcall(function() hiveESP.folderChildAddedConn:Disconnect() end)
        hiveESP.folderChildAddedConn = nil
    end
    if hiveESP.folderChildRemovedConn then
        pcall(function() hiveESP.folderChildRemovedConn:Disconnect() end)
        hiveESP.folderChildRemovedConn = nil
    end

    local currentHive = folder:FindFirstChild("HangingHoneyHive")
    if currentHive then
        attach(currentHive)
    end

    hiveESP.folderChildAddedConn = folder.ChildAdded:Connect(function(child)
        if child.Name == "HangingHoneyHive" and hiveESP.enabled then
            task.wait(0.1)
            attach(child)
        end
    end)

    hiveESP.folderChildRemovedConn = folder.ChildRemoved:Connect(function(child)
        if child.Name == "HangingHoneyHive" then
            cleanupVisuals()
        end
    end)
end

local function initWatcher()
    local currentFolder = Workspace:FindFirstChild("LocalCowBeeHives")
    if currentFolder then
        hookFolder(currentFolder)
    end

    hiveESP.wsChildAddedConn = Workspace.ChildAdded:Connect(function(child)
        if child.Name == "LocalCowBeeHives" and hiveESP.enabled then
            task.wait(0.1)
            hookFolder(child)
        end
    end)

    hiveESP.wsChildRemovedConn = Workspace.ChildRemoved:Connect(function(child)
        if child.Name == "LocalCowBeeHives" then
            if hiveESP.folderChildAddedConn then
                pcall(function() hiveESP.folderChildAddedConn:Disconnect() end)
                hiveESP.folderChildAddedConn = nil
            end
            if hiveESP.folderChildRemovedConn then
                pcall(function() hiveESP.folderChildRemovedConn:Disconnect() end)
                hiveESP.folderChildRemovedConn = nil
            end
            cleanupVisuals()
        end
    end)
end

function hiveESP.destroy()
    hiveESP.enabled = false
    if hiveESP.wsChildAddedConn then
        pcall(function() hiveESP.wsChildAddedConn:Disconnect() end)
        hiveESP.wsChildAddedConn = nil
    end
    if hiveESP.wsChildRemovedConn then
        pcall(function() hiveESP.wsChildRemovedConn:Disconnect() end)
        hiveESP.wsChildRemovedConn = nil
    end
    if hiveESP.folderChildAddedConn then
        pcall(function() hiveESP.folderChildAddedConn:Disconnect() end)
        hiveESP.folderChildAddedConn = nil
    end
    if hiveESP.folderChildRemovedConn then
        pcall(function() hiveESP.folderChildRemovedConn:Disconnect() end)
        hiveESP.folderChildRemovedConn = nil
    end
    cleanupVisuals()
    if _G.HangingHoneyHiveESP == hiveESP then
        _G.HangingHoneyHiveESP = nil
    end
end

initWatcher()
_G.HangingHoneyHiveESP = hiveESP
return hiveESP

