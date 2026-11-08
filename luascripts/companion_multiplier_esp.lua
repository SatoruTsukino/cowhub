-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false, -- true: remove running Companion Multiplier ESP and stop

    DOGS = true, -- show for dogs
    CATS = true, -- show for cats
    ONLY_EQUIPPED = false, -- true: only show for your actively equipped companion

    MAX_DISTANCE = 400, -- max studs distance to render billboard
}
-- ==========================================================================

-- Companion Multiplier ESP
-- Displays exact CompanionMultiplier (1.00x - 1.15x grazing calorie bonus)
-- and Bond familiarity directly above companion/pet heads.
--
-- Formula (GrassEconomy / CompanionCare):
--   CompanionMultiplier = math.clamp(1 + (Bond * 0.15), 1, 1.15)
--   Untamed base: Bond = 0.25 -> 1.0375x (+3.75%)
--   Max bond:     Bond = 1.00 -> 1.1500x (+15.00%)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.CompanionMultiplierESP and type(_G.CompanionMultiplierESP.destroy) == "function" then
    pcall(_G.CompanionMultiplierESP.destroy)
end

if SETTINGS.DESTROY then
    return nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local FOLDERS = {
    LocalDogs = "Dog",
    LocalBarnCats = "Cat",
}

local esp = {
    running = true,
    visuals = {},
    controllers = {},
    modelRecords = {},
    lastGcScan = -math.huge,
    store = nil, -- cached profile Store (found once via getgc)
    lastStoreScan = -math.huge,
    knownBond = {}, -- [species..":"..Id] = last bond seen; bridges transient misses
    conns = {},
}
_G.CompanionMultiplierESP = esp

-- Profile Store for live equipped companion data. getgc only when the Store is not cached
-- (at most every 5 s); GetState itself is cheap and runs once per draw tick.
local function getProfileCompanions()
    if not esp.store and type(getgc) == "function" and os.clock() - esp.lastStoreScan > 5 then
        esp.lastStoreScan = os.clock()
        local ok, objects = pcall(getgc, true)
        if ok and type(objects) == "table" then
            for _, obj in ipairs(objects) do
                if type(obj) == "table" and rawget(obj, "Remotes") and type(rawget(obj, "Store")) == "table" then
                    local store = rawget(obj, "Store")
                    local okState, state = pcall(function() return store:GetState() end)
                    if okState and type(state) == "table" and type(state.Profile) == "table" then
                        esp.store = store
                        break
                    end
                end
            end
        end
    end
    local store = esp.store
    if not store then return nil end
    local okState, state = pcall(function() return store:GetState() end)
    if not okState or type(state) ~= "table" or type(state.Profile) ~= "table" then
        esp.store = nil
        return nil
    end
    local companions = state.Profile.Companions
    return type(companions) == "table" and companions or nil
end

-- Find Dog/Cat controllers via getgc to resolve model -> actor record
local function findControllers()
    if type(getgc) ~= "function" then return end
    local now = os.clock()
    if now - esp.lastGcScan < 4 then return end
    esp.lastGcScan = now

    local wanted = {}
    local need = false
    for folderName in pairs(FOLDERS) do
        local folder = Workspace:FindFirstChild(folderName)
        local ctrl = esp.controllers[folderName]
        if folder and not (ctrl and rawget(ctrl, "Folder") == folder) then
            wanted[folder] = folderName
            need = true
        end
    end
    if not need then return end

    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return end
    for _, obj in ipairs(objects) do
        if type(obj) == "table" then
            local folder = rawget(obj, "Folder")
            local name = folder and wanted[folder]
            if name and type(rawget(obj, "Actors")) == "table" then
                esp.controllers[name] = obj
                wanted[folder] = nil
                if next(wanted) == nil then break end
            end
        end
    end
end

-- Refresh Model -> Record cache
local function refreshRecords()
    table.clear(esp.modelRecords)
    for _, ctrl in pairs(esp.controllers) do
        local actors = rawget(ctrl, "Actors")
        if type(actors) == "table" then
            for _, actor in pairs(actors) do
                if type(actor) == "table" then
                    local model = rawget(actor, "Model")
                    -- Record is authoritative; RenderRecord can be an interpolated sample without CompanionCare.
                    local record = rawget(actor, "Record") or rawget(actor, "RenderRecord")
                    if typeof(model) == "Instance" and type(record) == "table" then
                        esp.modelRecords[model] = record
                    end
                end
            end
        end
    end
end

-- Calculate CompanionMultiplier & Bond from record/profile
local function getCompanionStats(model, record, companions, myRuntimeId)
    local isMyCompanion = false
    local bond = nil
    local name = nil
    local species = nil

    if record then
        species = record.Species or (record.Coat and "Cat" or "Dog")
        name = record.Name
        if myRuntimeId and record.Id == myRuntimeId then
            isMyCompanion = true
        end
        local care = record.CompanionCare or record.Care
        if type(care) == "table" and type(care.Bond) == "number" then
            bond = care.Bond
        end
    end

    if isMyCompanion or not bond then
        if companions and companions.EquippedId and companions.Owned then
            local owned = companions.Owned[companions.EquippedId]
            if owned and type(owned.Care) == "table" and type(owned.Care.Bond) == "number" then
                if isMyCompanion or not record then
                    bond = owned.Care.Bond
                    species = owned.Species or species
                    name = owned.Name or name
                end
            end
        end
    end

    -- Remember the last real bond per pet so a one-tick lookup miss does not flash "Untamed".
    local key = record and record.Id ~= nil and (tostring(species) .. ":" .. tostring(record.Id)) or nil
    if key then
        if bond then
            esp.knownBond[key] = bond
        else
            bond = esp.knownBond[key]
        end
    end

    -- Default fallback for untamed wild pet: base bond is 0.25 on tame
    local isUntamed = false
    if not bond then
        bond = 0.25
        isUntamed = true
    end

    bond = math.clamp(bond, 0, 1)
    local multiplier = math.clamp(1 + bond * 0.15, 1, 1.15)
    local percentBonus = (multiplier - 1) * 100

    return {
        multiplier = multiplier,
        percentBonus = percentBonus,
        bond = bond,
        isMyCompanion = isMyCompanion,
        isUntamed = isUntamed,
        species = species or "Companion",
        name = name,
    }
end

-- Remove Visuals
local function removeVisual(model)
    local visual = esp.visuals[model]
    if not visual then return end
    pcall(function() visual.billboard:Destroy() end)
    pcall(function() visual.highlight:Destroy() end)
    esp.visuals[model] = nil
end

-- Create Visuals
local function attachVisual(model, species)
    if esp.visuals[model] or not model:IsA("Model") then return end
    local head = model:FindFirstChild("Head") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "CompanionMultHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(0, 230, 180)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CompanionMultBillboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 220, 0, 68)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = SETTINGS.MAX_DISTANCE

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(15, 20, 26)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 230, 180)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -12, 0, 18)
    title.Position = UDim2.new(0, 6, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Text = species:upper()
    title.Parent = frame

    local multLabel = Instance.new("TextLabel")
    multLabel.Name = "Multiplier"
    multLabel.Size = UDim2.new(1, -12, 0, 22)
    multLabel.Position = UDim2.new(0, 6, 0, 22)
    multLabel.BackgroundTransparency = 1
    multLabel.Font = Enum.Font.GothamBlack
    multLabel.TextSize = 16
    multLabel.TextColor3 = Color3.fromRGB(80, 255, 180)
    multLabel.TextXAlignment = Enum.TextXAlignment.Center
    multLabel.Text = "1.0000× (+0.0%)"
    multLabel.Parent = frame

    local bondLabel = Instance.new("TextLabel")
    bondLabel.Name = "Bond"
    bondLabel.Size = UDim2.new(1, -12, 0, 16)
    bondLabel.Position = UDim2.new(0, 6, 0, 46)
    bondLabel.BackgroundTransparency = 1
    bondLabel.Font = Enum.Font.GothamMedium
    bondLabel.TextSize = 11
    bondLabel.TextColor3 = Color3.fromRGB(200, 215, 230)
    bondLabel.TextXAlignment = Enum.TextXAlignment.Center
    bondLabel.Text = "Bond: 0%"
    bondLabel.Parent = frame

    billboard.Parent = model

    esp.visuals[model] = {
        model = model,
        billboard = billboard,
        highlight = highlight,
        title = title,
        multLabel = multLabel,
        bondLabel = bondLabel,
        stroke = stroke,
    }
end

-- Update loop (Heartbeat, gated: folders 1 s, records 0.5 s, draw 0.25 s; controllers self-gate at 4 s)
local clock = { scan = -math.huge, records = -math.huge, draw = -math.huge }

local function update()
    if not esp.running then return end
    local now = os.clock()
    findControllers()
    if now - clock.records >= 0.5 then
        clock.records = now
        refreshRecords()
    end
    if now - clock.scan < 1 and now - clock.draw < 0.25 then return end

    -- Scan models in LocalDogs & LocalBarnCats
    if now - clock.scan >= 1 then
    clock.scan = now
    for folderName, species in pairs(FOLDERS) do
        local enabled = (species == "Dog" and SETTINGS.DOGS) or (species == "Cat" and SETTINGS.CATS)
        local folder = Workspace:FindFirstChild(folderName)
        if folder and enabled then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") and not esp.visuals[child] then
                    attachVisual(child, species)
                end
            end
        end
    end
    end

    if now - clock.draw < 0.25 then return end
    clock.draw = now

    -- Once per draw tick, shared by every pet
    local companions = getProfileCompanions()
    local myRuntimeId = plr:GetAttribute("CowCompanionRuntimeId")

    -- Update each active visual
    for model, visual in pairs(esp.visuals) do
        if not model.Parent then
            removeVisual(model)
        else
            local record = esp.modelRecords[model]
            local stats = getCompanionStats(model, record, companions, myRuntimeId)
            local hidden = SETTINGS.ONLY_EQUIPPED and not stats.isMyCompanion
            -- Skip all property writes when nothing visible changed
            local state = hidden and "hidden" or string.format("%s|%s|%s|%.4f|%.3f|%s",
                tostring(stats.isMyCompanion), stats.species, tostring(stats.name), stats.multiplier, stats.bond, tostring(stats.isUntamed))

            if state == visual.state then
                -- unchanged
            elseif hidden then
                visual.state = state
                visual.billboard.Enabled = false
                visual.highlight.Enabled = false
            else
                visual.state = state
                visual.billboard.Enabled = true
                visual.highlight.Enabled = true

                -- Update Title
                if stats.isMyCompanion then
                    visual.title.Text = "★ YOUR " .. stats.species:upper() .. (stats.name and (" · " .. stats.name) or "")
                    visual.title.TextColor3 = Color3.fromRGB(255, 220, 80)
                    visual.stroke.Color = Color3.fromRGB(255, 220, 80)
                    visual.highlight.FillColor = Color3.fromRGB(255, 220, 80)
                else
                    visual.title.Text = stats.species:upper() .. (stats.name and (" · " .. stats.name) or "")
                    visual.title.TextColor3 = Color3.fromRGB(255, 255, 255)
                    visual.stroke.Color = Color3.fromRGB(0, 230, 180)
                    visual.highlight.FillColor = Color3.fromRGB(0, 230, 180)
                end

                -- Multiplier Text
                visual.multLabel.Text = string.format("%.4f× (+%.1f%% Cal)", stats.multiplier, stats.percentBonus)

                -- Bond / Status Text
                if stats.isUntamed then
                    visual.bondLabel.Text = string.format("Untamed Base · Bond: %.0f%%", stats.bond * 100)
                    visual.bondLabel.TextColor3 = Color3.fromRGB(160, 180, 200)
                elseif stats.bond >= 1 then
                    visual.bondLabel.Text = "★ MAX BOND (100%)"
                    visual.bondLabel.TextColor3 = Color3.fromRGB(80, 255, 180)
                else
                    visual.bondLabel.Text = string.format("Bond: %.1f%% / 100%%", stats.bond * 100)
                    visual.bondLabel.TextColor3 = Color3.fromRGB(200, 220, 240)
                end
            end
        end
    end
end

-- Lifecycle connection
table.insert(esp.conns, RunService.Heartbeat:Connect(update))

-- Destroy / Cleanup
function esp.destroy()
    esp.running = false
    for _, conn in ipairs(esp.conns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(esp.conns)
    for model in pairs(esp.visuals) do
        removeVisual(model)
    end
    table.clear(esp.visuals)
    table.clear(esp.knownBond)
    esp.store = nil
    if _G.CompanionMultiplierESP == esp then
        _G.CompanionMultiplierESP = nil
    end
end

print("[CompanionMultiplierESP] Active. Showing CompanionMultiplier above pet heads.")
return esp

