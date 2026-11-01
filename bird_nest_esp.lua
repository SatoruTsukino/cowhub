-- Bird Nest Multi-Model ESP
-- Highlights all visible NestResident models in workspace.LocalCowBirdNests

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Prevent duplicate instances on re-execution
if _G.BirdNestESP and type(_G.BirdNestESP.destroy) == "function" then
    pcall(_G.BirdNestESP.destroy)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local nestESP = {
    enabled = true,
    visuals = {}, -- [Instance] = { highlight, billboard, label, targetPart, displayName, lastDist, ancestryConn }
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

local function getBirdSpecies(model)
    local species = model:GetAttribute("BirdSpecies")
    if species and tostring(species) ~= "" then
        return tostring(species)
    end
    local parent = model.Parent
    if parent then
        species = parent:GetAttribute("BirdSpecies")
        if species and tostring(species) ~= "" then
            return tostring(species)
        end
    end
    return nil
end

local function parseDisplayName(model)
    local name = model.Name
    local region = string.match(name, "NestResident_([^_]+)") or string.match(name, "Nest_([^_]+)")
    local species = getBirdSpecies(model)

    if species then
        if region and region ~= "" then
            return species .. " (" .. region .. ")"
        end
        return species
    end

    if region and region ~= "" then
        return "Bird Nest (" .. region .. ")"
    end
    return "Bird Nest"
end

local function isTargetResident(child)
    if not child then return false end
    if not (child:IsA("Model") or child:IsA("BasePart")) then return false end
    if string.find(child.Name, "NestResident") then
        return true
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
    local visual = nestESP.visuals[model]
    if not visual then return end

    if visual.ancestryConn then
        pcall(function() visual.ancestryConn:Disconnect() end)
    end
    if visual.attrConn then
        pcall(function() visual.attrConn:Disconnect() end)
    end
    if visual.parentAttrConn then
        pcall(function() visual.parentAttrConn:Disconnect() end)
    end
    if visual.highlight then
        pcall(function() visual.highlight:Destroy() end)
    end
    if visual.billboard then
        pcall(function() visual.billboard:Destroy() end)
    end
    nestESP.visuals[model] = nil
end

local function cleanupAllVisuals()
    for model in pairs(nestESP.visuals) do
        removeVisual(model)
    end
    table.clear(nestESP.visuals)
end

local function attach(trackedResident)
    if not nestESP.enabled or not trackedResident or not trackedResident.Parent then return end
    if nestESP.visuals[trackedResident] then return end

    local targetPart = trackedResident:IsA("Model") and (trackedResident.PrimaryPart or trackedResident:FindFirstChildWhichIsA("BasePart")) or (trackedResident:IsA("BasePart") and trackedResident)
    if not targetPart then
        targetPart = trackedResident:FindFirstChildWhichIsA("BasePart", true)
    end
    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "BirdNestHighlight"
    highlight.Adornee = trackedResident
    highlight.FillColor = Color3.fromRGB(0, 220, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = trackedResident

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BirdNestESPText"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 180, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(80, 240, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    local displayName = parseDisplayName(trackedResident)
    textLabel.Text = "🪺 " .. displayName
    textLabel.Parent = billboard
    billboard.Parent = trackedResident

    local visual = {
        highlight = highlight,
        billboard = billboard,
        label = textLabel,
        targetPart = targetPart,
        displayName = displayName,
        lastDist = -1,
        ancestryConn = nil,
        attrConn = nil,
        parentAttrConn = nil,
    }

    visual.ancestryConn = trackedResident.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeVisual(trackedResident)
        end
    end)

    visual.attrConn = trackedResident.AttributeChanged:Connect(function(attr)
        if attr == "BirdSpecies" then
            visual.displayName = parseDisplayName(trackedResident)
            visual.lastDist = -1
        end
    end)

    local parentObj = trackedResident.Parent
    if parentObj then
        visual.parentAttrConn = parentObj.AttributeChanged:Connect(function(attr)
            if attr == "BirdSpecies" then
                visual.displayName = parseDisplayName(trackedResident)
                visual.lastDist = -1
            end
        end)
    end

    nestESP.visuals[trackedResident] = visual
end

local function hookFolder(folder)
    if not folder then return end

    if nestESP.folderDescendantAddedConn then
        pcall(function() nestESP.folderDescendantAddedConn:Disconnect() end)
        nestESP.folderDescendantAddedConn = nil
    end
    if nestESP.folderDescendantRemovingConn then
        pcall(function() nestESP.folderDescendantRemovingConn:Disconnect() end)
        nestESP.folderDescendantRemovingConn = nil
    end

    for _, desc in ipairs(folder:GetDescendants()) do
        if isTargetResident(desc) then
            attach(desc)
        end
    end

    nestESP.folderDescendantAddedConn = folder.DescendantAdded:Connect(function(desc)
        if isTargetResident(desc) and nestESP.enabled then
            task.wait(0.1)
            attach(desc)
        end
    end)

    nestESP.folderDescendantRemovingConn = folder.DescendantRemoving:Connect(function(desc)
        if nestESP.visuals[desc] then
            removeVisual(desc)
        end
    end)
end

local function initWatcher()
    local currentFolder = Workspace:FindFirstChild("LocalCowBirdNests")
    if currentFolder then
        hookFolder(currentFolder)
    end

    nestESP.wsChildAddedConn = Workspace.ChildAdded:Connect(function(child)
        if child.Name == "LocalCowBirdNests" and nestESP.enabled then
            task.wait(0.1)
            hookFolder(child)
        end
    end)

    nestESP.wsChildRemovedConn = Workspace.ChildRemoved:Connect(function(child)
        if child.Name == "LocalCowBirdNests" then
            if nestESP.folderDescendantAddedConn then
                pcall(function() nestESP.folderDescendantAddedConn:Disconnect() end)
                nestESP.folderDescendantAddedConn = nil
            end
            if nestESP.folderDescendantRemovingConn then
                pcall(function() nestESP.folderDescendantRemovingConn:Disconnect() end)
                nestESP.folderDescendantRemovingConn = nil
            end
            cleanupAllVisuals()
        end
    end)
end

local function startLoop()
    local lastUpdate = 0
    local lastScan = 0

    nestESP.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not nestESP.enabled then
            cleanupAllVisuals()
            return
        end

        local now = os.clock()

        -- Periodic sync for streaming
        if now - lastScan > 1.0 then
            lastScan = now
            local folder = Workspace:FindFirstChild("LocalCowBirdNests")
            if folder then
                for _, desc in ipairs(folder:GetDescendants()) do
                    if isTargetResident(desc) and not nestESP.visuals[desc] then
                        attach(desc)
                    end
                end
            end
        end

        if now - lastUpdate <= 0.1 then return end
        lastUpdate = now

        local rPos = getRootPos()

        for model, visual in pairs(nestESP.visuals) do
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
                    local currentName = parseDisplayName(model)
                    if currentName ~= visual.displayName then
                        visual.displayName = currentName
                        visual.lastDist = -1
                    end

                    local hPos = visual.targetPart.Position
                    local dx = rPos.X - hPos.X
                    local dy = rPos.Y - hPos.Y
                    local dz = rPos.Z - hPos.Z
                    local dist = math.floor(math.sqrt(dx * dx + dy * dy + dz * dz))
                    if dist ~= visual.lastDist then
                        visual.lastDist = dist
                        visual.label.Text = "🪺 " .. visual.displayName .. "\n[" .. dist .. " studs]"
                    end
                end
            end
        end
    end)
end

function nestESP.destroy()
    nestESP.enabled = false
    if nestESP.heartbeatConn then
        pcall(function() nestESP.heartbeatConn:Disconnect() end)
        nestESP.heartbeatConn = nil
    end
    if nestESP.wsChildAddedConn then
        pcall(function() nestESP.wsChildAddedConn:Disconnect() end)
        nestESP.wsChildAddedConn = nil
    end
    if nestESP.wsChildRemovedConn then
        pcall(function() nestESP.wsChildRemovedConn:Disconnect() end)
        nestESP.wsChildRemovedConn = nil
    end
    if nestESP.folderDescendantAddedConn then
        pcall(function() nestESP.folderDescendantAddedConn:Disconnect() end)
        nestESP.folderDescendantAddedConn = nil
    end
    if nestESP.folderDescendantRemovingConn then
        pcall(function() nestESP.folderDescendantRemovingConn:Disconnect() end)
        nestESP.folderDescendantRemovingConn = nil
    end
    cleanupAllVisuals()
    if _G.BirdNestESP == nestESP then
        _G.BirdNestESP = nil
    end
end

initWatcher()
startLoop()
_G.BirdNestESP = nestESP
return nestESP

