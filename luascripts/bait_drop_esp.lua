-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false, -- true: remove the running Bait Drop ESP and stop (nothing new starts)

    DOG_BONE = true, -- highlight every Dog Bone model   (item id "Chicken")
    CATFISH = true, -- highlight every Catfish model    (item id "Catfish")
    LOG = true, -- print each found bait model to the console
}
-- ==========================================================================

-- Bait Drop ESP
-- Highlights every companion bait model anywhere in workspace: dropped on the ground,
-- being eaten by a pet (AnimalTamingMeal), or anywhere else.
-- ItemModels.Create / DropGeometry.CreateItem stamp attribute ItemId on every item model,
-- so the match is ItemId (any model name). "<ItemId>Drop" name is a fallback for models
-- without the attribute. "Dog Bone" is the display name of item "Chicken" (ItemAppearance).

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
    Chicken = { label = "🦴 Dog Bone", color = Color3.fromRGB(255, 225, 160), on = SETTINGS.DOG_BONE == true },
    Catfish = { label = "🐟 Catfish", color = Color3.fromRGB(80, 200, 255), on = SETTINGS.CATFISH == true },
}
local DROP_NAMES = { ChickenDrop = "Chicken", CatfishDrop = "Catfish" }

local baitESP = {
    visuals = {}, -- [Model] = { highlight, billboard, label, targetPart, kind, lastDist }
    conns = {},
}

local function kindOf(inst)
    if not inst:IsA("Model") then return nil end
    local kind = KINDS[inst:GetAttribute("ItemId") or DROP_NAMES[inst.Name]]
    return kind and kind.on and kind or nil
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
    local text = kind.label .. (model.Name == "AnimalTamingMeal" and " (eating)" or "")
    label.Text = text
    label.Parent = billboard
    billboard.Parent = model

    if SETTINGS.LOG then
        print("[BaitDropESP] found " .. text .. " -> " .. model:GetFullName())
    end

    baitESP.visuals[model] = {
        highlight = highlight,
        billboard = billboard,
        label = label,
        targetPart = targetPart,
        text = text,
        lastDist = -1,
    }
end

-- Item models get parts + ItemId before parenting; retry once in case parts stream in late.
local function onAdded(inst)
    if not kindOf(inst) then return end
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

if not (KINDS.Chicken.on or KINDS.Catfish.on) then
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
                visual.label.Text = visual.text .. "\n[" .. dist .. " studs]"
            end
        end
    end
end)

if SETTINGS.LOG then
    local n = 0
    for _ in pairs(baitESP.visuals) do n += 1 end
    print("[BaitDropESP] running; " .. n .. " bait model(s) in workspace now")
end

_G.BaitDropESP = baitESP
return baitESP
