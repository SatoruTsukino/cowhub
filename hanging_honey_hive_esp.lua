-- HangingHoneyHive Multi-Model ESP
-- Highlights all visible HangingHoneyHive models simultaneously in workspace.LocalCowBeeHives

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
    visuals = {}, -- [Instance] = { highlight, billboard, label, targetPart, lastDist, ancestryConn }
    heartbeatConn = nil,
    wsChildAddedConn = nil,
    wsChildRemovedConn = nil,
    folderDescendantAddedConn = nil,
    folderDescendantRemovingConn = nil,
}

local function getRootPos()
    local char = plr.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
    if not root then return nil end
    return root.Position
end

local function isHiveModel(child)
    if not child then return false end
    if not (child:IsA("Model") or child:IsA("BasePart")) then return false end
    if child.Name == "HangingHoneyHive" or child.Name:find("HangingHoneyHive") then
        return true
    end
    local parent = child.Parent
    if parent and parent.Name == "LocalCowBeeHives" then
        if child.Name:find("Hive") or child:IsA("Model") then
            return true
        end
    end
    return false
end

local function isModelVisible(model, targetPart)
    if not model or not model.Parent then return false end
    if not model:IsDescendantOf(Workspace) then return false end

    if targetPart and targetPart.Parent and targetPart.Transparency < 0.95 then
        return true
    end

    local hasBasePart = false
    local hasVisiblePart = false
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            hasBasePart = true
            if desc.Transparency < 0.95 then
                hasVisiblePart = true
                break
            end
        end
    end

    if hasBasePart and not hasVisiblePart then
        return false
    end
    return true
end

local function removeVisual(model)
    local visual = hiveESP.visuals[model]
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
    hiveESP.visuals[model] = nil
end

local function cleanupAllVisuals()
    for model in pairs(hiveESP.visuals) do
        removeVisual(model)
    end
    table.clear(hiveESP.visuals)
end

local function attach(trackedHive)
    if not hiveESP.enabled or not trackedHive or not trackedHive.Parent then return end
    if hiveESP.visuals[trackedHive] then return end

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
    local displayName = trackedHive.Name == "HangingHoneyHive" and "Hanging Honey Hive" or trackedHive.Name
    textLabel.Text = "🍯 " .. displayName
    textLabel.Parent = billboard
    billboard.Parent = trackedHive

    local visual = {
        highlight = highlight,
        billboard = billboard,
        label = textLabel,
        targetPart = hivePart,
        displayName = displayName,
        lastDist = -1,
        ancestryConn = nil,
    }

    visual.ancestryConn = trackedHive.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeVisual(trackedHive)
        end
    end)

    hiveESP.visuals[trackedHive] = visual
end

local function hookFolder(folder)
    if not folder then return end

    if hiveESP.folderDescendantAddedConn then
        pcall(function() hiveESP.folderDescendantAddedConn:Disconnect() end)
        hiveESP.folderDescendantAddedConn = nil
    end
    if hiveESP.folderDescendantRemovingConn then
        pcall(function() hiveESP.folderDescendantRemovingConn:Disconnect() end)
        hiveESP.folderDescendantRemovingConn = nil
    end

    for _, desc in ipairs(folder:GetDescendants()) do
        if isHiveModel(desc) then
            attach(desc)
        end
    end

    hiveESP.folderDescendantAddedConn = folder.DescendantAdded:Connect(function(desc)
        if isHiveModel(desc) and hiveESP.enabled then
            task.wait(0.1)
            attach(desc)
        end
    end)

    hiveESP.folderDescendantRemovingConn = folder.DescendantRemoving:Connect(function(desc)
        if hiveESP.visuals[desc] then
            removeVisual(desc)
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
            if hiveESP.folderDescendantAddedConn then
                pcall(function() hiveESP.folderDescendantAddedConn:Disconnect() end)
                hiveESP.folderDescendantAddedConn = nil
            end
            if hiveESP.folderDescendantRemovingConn then
                pcall(function() hiveESP.folderDescendantRemovingConn:Disconnect() end)
                hiveESP.folderDescendantRemovingConn = nil
            end
            cleanupAllVisuals()
        end
    end)
end

local function startLoop()
    local lastUpdate = 0
    local lastScan = 0

    hiveESP.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not hiveESP.enabled then
            cleanupAllVisuals()
            return
        end

        local now = os.clock()

        -- Periodic sync for streamed instances
        if now - lastScan > 1.0 then
            lastScan = now
            local folder = Workspace:FindFirstChild("LocalCowBeeHives")
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    if isHiveModel(child) and not hiveESP.visuals[child] then
                        attach(child)
                    end
                end
            end
        end

        if now - lastUpdate <= 0.1 then return end
        lastUpdate = now

        local rPos = getRootPos()

        for model, visual in pairs(hiveESP.visuals) do
            if not model or not model.Parent or not visual.targetPart or not visual.targetPart.Parent then
                removeVisual(model)
            else
                local visible = isModelVisible(model, visual.targetPart)
                if visual.highlight.Enabled ~= visible then
                    visual.highlight.Enabled = visible
                end
                if visual.billboard.Enabled ~= visible then
                    visual.billboard.Enabled = visible
                end

                if visible and rPos then
                    local hPos = visual.targetPart.Position
                    local dx = rPos.X - hPos.X
                    local dy = rPos.Y - hPos.Y
                    local dz = rPos.Z - hPos.Z
                    local dist = math.floor(math.sqrt(dx * dx + dy * dy + dz * dz))
                    if dist ~= visual.lastDist then
                        visual.lastDist = dist
                        visual.label.Text = "🍯 " .. visual.displayName .. "\n[" .. dist .. " studs]"
                    end
                end
            end
        end
    end)
end

function hiveESP.destroy()
    hiveESP.enabled = false
    if hiveESP.heartbeatConn then
        pcall(function() hiveESP.heartbeatConn:Disconnect() end)
        hiveESP.heartbeatConn = nil
    end
    if hiveESP.wsChildAddedConn then
        pcall(function() hiveESP.wsChildAddedConn:Disconnect() end)
        hiveESP.wsChildAddedConn = nil
    end
    if hiveESP.wsChildRemovedConn then
        pcall(function() hiveESP.wsChildRemovedConn:Disconnect() end)
        hiveESP.wsChildRemovedConn = nil
    end
    if hiveESP.folderDescendantAddedConn then
        pcall(function() hiveESP.folderDescendantAddedConn:Disconnect() end)
        hiveESP.folderDescendantAddedConn = nil
    end
    if hiveESP.folderDescendantRemovingConn then
        pcall(function() hiveESP.folderDescendantRemovingConn:Disconnect() end)
        hiveESP.folderDescendantRemovingConn = nil
    end
    cleanupAllVisuals()
    if _G.HangingHoneyHiveESP == hiveESP then
        _G.HangingHoneyHiveESP = nil
    end
end

initWatcher()
startLoop()
_G.HangingHoneyHiveESP = hiveESP
return hiveESP
