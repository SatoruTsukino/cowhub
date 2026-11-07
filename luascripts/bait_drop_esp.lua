-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false, -- true: remove the running Bait Drop ESP and stop (nothing new starts)

    DOG_BONE = true, -- highlight dropped Dog Bones   (item id "Chicken" -> model "ChickenDrop")
    CATFISH = true, -- highlight dropped Catfish      (item id "Catfish" -> model "CatfishDrop")
}
-- ==========================================================================

-- Bait Drop ESP
-- Highlights companion bait dropped on the ground anywhere in workspace.
-- ItemModels.Create names a world drop "<ItemId>Drop" and sets attribute ItemId.
-- "Dog Bone" is the display name of item "Chicken" (ItemAppearance), so ChickenDrop is the bone.
-- Exact-name match skips AnimalTamingMeal (same item model, renamed, inside a pet being fed).

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.BaitDropESP and type(_G.BaitDropESP.destroy) == "function" then
    pcall(_G.BaitDropESP.destroy)
end

if SETTINGS.DESTROY then
    return nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local KINDS = {
    ChickenDrop = { itemId = "Chicken", label = "🦴 Dog Bone", color = Color3.fromRGB(255, 225, 160), on = SETTINGS.DOG_BONE == true },
    CatfishDrop = { itemId = "Catfish", label = "🐟 Catfish", color = Color3.fromRGB(80, 200, 255), on = SETTINGS.CATFISH == true },
}

local baitESP = {
    visuals = {}, -- [Model] = { highlight, billboard, label, targetPart, kind, lastDist }
    conns = {},
}

local function kindOf(inst)
    local kind = KINDS[inst.Name]
    if kind and kind.on and inst:IsA("Model") and inst:GetAttribute("ItemId") == kind.itemId then
        return kind
    end
    return nil
end

local function removeVisual(model)
    local visual = baitESP.visuals[model]
    if not visual then return end
    pcall(function() visual.highlight:Destroy() end)
    pcall(function() visual.billboard:Destroy() end)
    baitESP.visuals[model] = nil
end

local function attach(model)
    if baitESP.visuals[model] then return end
    local kind = kindOf(model)
    if not kind then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "BaitDropHighlight"
    highlight.Adornee = model
    highlight.FillColor = kind.color
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BaitDropText"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 160, 0, 36)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = kind.color
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Text = kind.label
    label.Parent = billboard
    billboard.Parent = model

    baitESP.visuals[model] = {
        highlight = highlight,
        billboard = billboard,
        label = label,
        targetPart = targetPart,
        kind = kind,
        lastDist = -1,
    }
end

-- Drop models get their parts before parenting, but retry once in case they stream in late.
local function onAdded(inst)
    if not KINDS[inst.Name] then return end
    attach(inst)
    if not baitESP.visuals[inst] then
        task.delay(0.2, function()
            if inst.Parent then attach(inst) end
        end)
    end
end

function baitESP.destroy()
    for _, conn in ipairs(baitESP.conns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(baitESP.conns)
    for model in pairs(baitESP.visuals) do
        removeVisual(model)
    end
    if _G.BaitDropESP == baitESP then
        _G.BaitDropESP = nil
    end
end

if not (KINDS.ChickenDrop.on or KINDS.CatfishDrop.on) then
    return nil
end

for _, inst in ipairs(workspace:GetDescendants()) do
    onAdded(inst)
end

baitESP.conns[#baitESP.conns + 1] = workspace.DescendantAdded:Connect(onAdded)
baitESP.conns[#baitESP.conns + 1] = workspace.DescendantRemoving:Connect(function(inst)
    if baitESP.visuals[inst] then
        removeVisual(inst)
    end
end)

local lastDraw = 0
baitESP.conns[#baitESP.conns + 1] = RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastDraw < 0.2 then return end
    lastDraw = now

    local char = plr.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    local rPos = root and root.Position or nil
    for model, visual in pairs(baitESP.visuals) do
        if not model.Parent or not visual.targetPart.Parent then
            removeVisual(model)
        elseif rPos then
            local dist = math.floor((rPos - visual.targetPart.Position).Magnitude)
            if dist ~= visual.lastDist then
                visual.lastDist = dist
                visual.label.Text = visual.kind.label .. "\n[" .. dist .. " studs]"
            end
        end
    end
end)

_G.BaitDropESP = baitESP
return baitESP
