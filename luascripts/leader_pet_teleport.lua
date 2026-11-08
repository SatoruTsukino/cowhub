-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false,           -- true: remove running script and close GUI
    TELEPORT_HEIGHT = 3.5,     -- studs above ground to teleport player
    HIGHLIGHT_COLOR = Color3.fromRGB(255, 215, 0), -- golden leader highlight
    HIGHLIGHT_DURATION = 300,  -- seconds highlight stays active (or until next teleport)
}
-- ==========================================================================

-- Leader Pet Teleport & Highlight
-- Teleports player directly to the hardcoded spawn habitats of the highest-rated
-- Leader pets in Cow Game (AnimalHabitatCatalog), and highlights the pet model in gold.
--
-- All 60 habitats (30 Cats + 30 Dogs) possess fixed, deterministic seeds:
-- Exactly 4 pets pass the stand-ground Leader Gate (Defiance > 0.86 & Timidity < 0.72):
--   1. CatHome20 : SouthPastures       | Cat (SilverTabby)     | Score: 0.730
--   2. DogHome03 : HomeMeadow          | Dog (GermanShepherd)  | Score: 0.686
--   3. DogHome17 : SouthPastures       | Dog (Corgi)           | Score: 0.630
--   4. DogHome26 : MountainsideMeadow  | Dog (BorderCollie)    | Score: 0.279

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.LeaderPetTeleport and type(_G.LeaderPetTeleport.destroy) == "function" then
    pcall(_G.LeaderPetTeleport.destroy)
end

if SETTINGS.DESTROY then
    return nil
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

-- Curated list of top pets (Top 4 Gated Leaders + Top High-Stat Runners)
local PET_CATALOG = {
    -- === GATED LEADERS (Def > 0.86, Tim < 0.72) ===
    {
        id = "CatHome20",
        species = "Cat",
        variant = "SilverTabby",
        zone = "SouthPastures",
        score = 0.730,
        gate = true,
        rank = "#1 Cat Leader",
        seed = 9838,
        def = 0.95,
        tim = 0.27,
        ldr = 0.98,
        bold = 1.05,
        disp = "Headstrong",
        pos = Vector3.new(230.22, 700.73, 941.02),
        desc = "Near South Pastures stone wall & stream",
    },
    {
        id = "DogHome03",
        species = "Dog",
        variant = "GermanShepherd",
        zone = "HomeMeadow",
        score = 0.686,
        gate = true,
        rank = "#1 Dog Leader",
        seed = 19623,
        def = 0.94,
        tim = 0.09,
        ldr = 0.95,
        bold = 1.39,
        disp = "Headstrong",
        pos = Vector3.new(-319.00, 700.74, 594.41),
        desc = "Meadow Lesson hay shelter near gate",
    },
    {
        id = "DogHome17",
        species = "Dog",
        variant = "Corgi",
        zone = "SouthPastures",
        score = 0.630,
        gate = true,
        rank = "#2 Dog Leader",
        seed = 21037,
        def = 0.99,
        tim = 0.48,
        ldr = 0.41,
        bold = 1.17,
        disp = "Headstrong",
        pos = Vector3.new(-24.00, 700.93, 1015.00),
        desc = "Deep South Pastures farm edge",
    },
    {
        id = "DogHome26",
        species = "Dog",
        variant = "BorderCollie",
        zone = "MountainsideMeadow",
        score = 0.279,
        gate = true,
        rank = "#3 Dog Leader",
        seed = 21946,
        def = 0.87,
        tim = 0.20,
        ldr = 0.04,
        bold = 0.88,
        disp = "Headstrong",
        pos = Vector3.new(512.50, 700.74, 841.97),
        desc = "Mountainside Meadow house corner",
    },

    -- === HIGH STAT BONUS RUNNERS-UP ===
    {
        id = "CatHome10",
        species = "Cat",
        variant = "GingerTabby",
        zone = "CloverCreek",
        score = 0.737,
        gate = false,
        rank = "#1 Raw Cat",
        seed = 8828,
        def = 0.46,
        tim = 0.40,
        ldr = 0.67,
        bold = 1.10,
        disp = "Companion",
        pos = Vector3.new(-673.10, 700.73, 627.46),
        desc = "Clover Creek riverside bank",
    },
    {
        id = "DogHome27",
        species = "Dog",
        variant = "GermanShepherd",
        zone = "MountainsideMeadow",
        score = 0.721,
        gate = false,
        rank = "#1 Raw Dog",
        seed = 22047,
        def = 0.49,
        tim = 0.04,
        ldr = 0.85,
        bold = 1.45,
        disp = "Companion",
        pos = Vector3.new(488.23, 700.74, 561.99),
        desc = "Mountainside Orchard crates",
    },
    {
        id = "DogHome29",
        species = "Dog",
        variant = "Corgi",
        zone = "GoldenHill",
        score = 0.706,
        gate = false,
        rank = "#2 Raw Dog",
        seed = 22249,
        def = 0.07,
        tim = 0.25,
        ldr = 0.35,
        bold = 1.19,
        disp = "Rascal",
        pos = Vector3.new(308.95, 700.74, 211.56),
        desc = "Golden Hill house corner shelter",
    },
    {
        id = "CatHome22",
        species = "Cat",
        variant = "Calico",
        zone = "AppleOrchard",
        score = 0.695,
        gate = false,
        rank = "#2 Raw Cat",
        seed = 10040,
        def = 0.52,
        tim = 0.11,
        ldr = 0.51,
        bold = 1.12,
        disp = "Companion",
        pos = Vector3.new(308.95, 700.73, 406.08),
        desc = "Apple Orchard barn hay stack",
    },
}

local RunService = game:GetService("RunService")

local FOLDER_BY_SPECIES = { Dog = "LocalDogs", Cat = "LocalBarnCats" }
local SEED_SEARCH_SECONDS = 15 -- after this with no seed match, fall back to nearest pet

local app = {
    running = true,
    gui = nil,
    currentHighlight = nil,
    currentBillboard = nil,
    highlightedModel = nil,
    controllers = {}, -- [folderName] = DogController / BarnCatController (via getgc)
    lastGcScan = {}, -- [folderName] = os.clock() of last scan
    track = nil, -- { pet, statusLabel, startedAt, untilAt, lastStep, mode }
    trackConn = nil,
}
_G.LeaderPetTeleport = app

-- Remove active pet highlight
local function clearHighlight()
    if app.currentHighlight then
        pcall(function() app.currentHighlight:Destroy() end)
        app.currentHighlight = nil
    end
    if app.currentBillboard then
        pcall(function() app.currentBillboard:Destroy() end)
        app.currentBillboard = nil
    end
    app.highlightedModel = nil
end

-- Dog/BarnCat controller table for a folder (getgc; cached, rescan at most every 3 s while missing)
local function getController(folder, folderName)
    local ctrl = app.controllers[folderName]
    if ctrl and rawget(ctrl, "Folder") == folder then return ctrl end
    app.controllers[folderName] = nil
    if type(getgc) ~= "function" then return nil end
    local now = os.clock()
    if now - (app.lastGcScan[folderName] or -math.huge) < 3 then return nil end
    app.lastGcScan[folderName] = now
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return nil end
    for _, obj in ipairs(objects) do
        if type(obj) == "table" and rawget(obj, "Folder") == folder and type(rawget(obj, "Actors")) == "table" then
            app.controllers[folderName] = obj
            return obj
        end
    end
    return nil
end

-- Exact pet: the actor whose record Seed equals the habitat seed
local function findPetModelBySeed(petData)
    local folderName = FOLDER_BY_SPECIES[petData.species]
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then return nil end
    local ctrl = getController(folder, folderName)
    local actors = ctrl and rawget(ctrl, "Actors")
    if type(actors) ~= "table" then return nil end
    for _, actor in pairs(actors) do
        if type(actor) == "table" then
            local model = rawget(actor, "Model")
            local record = rawget(actor, "Record") or rawget(actor, "RenderRecord")
            if typeof(model) == "Instance" and model.Parent == folder and type(record) == "table"
                and tonumber(record.Seed) == petData.seed then
                return model
            end
        end
    end
    return nil
end

-- Fallback guess: nearest pet model of the species near the habitat
local function findPetModelAt(pos, species)
    local folderName = FOLDER_BY_SPECIES[species]
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then return nil end

    local bestModel = nil
    local bestDist = 45 -- within 45 studs of home coordinate

    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") then
            local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local dist = (part.Position - pos).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestModel = child
                end
            end
        end
    end
    return bestModel
end

-- Highlight target pet in world
local function highlightPet(model, petData, guessed)
    clearHighlight()
    if not model then return end
    app.highlightedModel = model

    local hl = Instance.new("Highlight")
    hl.Name = "LeaderPetHighlight"
    hl.Adornee = model
    hl.FillColor = SETTINGS.HIGHLIGHT_COLOR
    hl.FillTransparency = 0.4
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = model
    app.currentHighlight = hl

    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if targetPart then
        local bb = Instance.new("BillboardGui")
        bb.Name = "LeaderPetTag"
        bb.Adornee = targetPart
        bb.Size = UDim2.new(0, 200, 0, 70)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = bb

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = SETTINGS.HIGHLIGHT_COLOR
        stroke.Thickness = 1.5
        stroke.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 18)
        title.Position = UDim2.new(0, 5, 0, 4)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextColor3 = SETTINGS.HIGHLIGHT_COLOR
        title.Text = "★ " .. petData.rank:upper() .. " ★" .. (guessed and " (nearest guess)" or "")
        title.Parent = frame

        local details = Instance.new("TextLabel")
        details.Size = UDim2.new(1, -10, 0, 22)
        details.Position = UDim2.new(0, 5, 0, 22)
        details.BackgroundTransparency = 1
        details.Font = Enum.Font.GothamBlack
        details.TextSize = 13
        details.TextColor3 = Color3.fromRGB(255, 255, 255)
        details.Text = string.format("%s (%s)", petData.variant, petData.disp)
        details.Parent = frame

        local stats = Instance.new("TextLabel")
        stats.Size = UDim2.new(1, -10, 0, 16)
        stats.Position = UDim2.new(0, 5, 0, 46)
        stats.BackgroundTransparency = 1
        stats.Font = Enum.Font.GothamMedium
        stats.TextSize = 11
        stats.TextColor3 = Color3.fromRGB(80, 255, 180)
        stats.Text = string.format("Score: %.3f | Def: %.2f | Tim: %.2f", petData.score, petData.def, petData.tim)
        stats.Parent = frame

        bb.Parent = targetPart
        app.currentBillboard = bb
    end
end

-- Teleport to specific pet
local function teleportToPet(petData, statusLabel)
    local char = plr.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not root then
        if statusLabel then statusLabel.Text = "Status: Waiting for character..." end
        return
    end

    local targetPos = petData.pos + Vector3.new(0, SETTINGS.TELEPORT_HEIGHT, 0)
    root.CFrame = CFrame.new(targetPos)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    if statusLabel then
        statusLabel.Text = "Teleported to " .. petData.id .. " (" .. petData.zone .. "). Searching by seed..."
    end

    -- Track the pet until HIGHLIGHT_DURATION ends or the next teleport
    clearHighlight()
    local now = os.clock()
    app.track = {
        pet = petData,
        statusLabel = statusLabel,
        startedAt = now,
        untilAt = now + (tonumber(SETTINGS.HIGHLIGHT_DURATION) or 300),
        lastStep = -math.huge,
        mode = nil,
    }
end

local function setStatus(track, text)
    if track.statusLabel and track.statusLabel.Text ~= text then
        track.statusLabel.Text = text
    end
end

-- Every 0.5 s: re-resolve the tracked pet; move the highlight if its model changed
local function stepTrack()
    local track = app.track
    if not track then return end
    local now = os.clock()
    if now - track.lastStep < 0.5 then return end
    track.lastStep = now

    if now >= track.untilAt then
        clearHighlight()
        app.track = nil
        setStatus(track, "Highlight expired for " .. track.pet.id .. ".")
        return
    end

    local pet = track.pet
    local model = findPetModelBySeed(pet)
    local guessed = false
    if not model and (type(getgc) ~= "function" or now - track.startedAt >= SEED_SEARCH_SECONDS) then
        model = findPetModelAt(pet.pos, pet.species)
        guessed = model ~= nil
    end

    if not model then
        if app.highlightedModel then clearHighlight() end
        setStatus(track, "Searching for " .. pet.id .. " (seed " .. pet.seed .. ")... pet not loaded / nearby")
        return
    end

    local mode = guessed and "guess" or "seed"
    if model ~= app.highlightedModel or mode ~= track.mode or not app.currentHighlight or not app.currentHighlight.Parent then
        track.mode = mode
        highlightPet(model, pet, guessed)
    end
    if guessed then
        setStatus(track, "No seed match for " .. pet.id .. "; highlighting nearest " .. pet.species .. " (guess)")
    else
        setStatus(track, "★ " .. pet.rank .. " matched by seed " .. pet.seed .. " · highlighted")
    end
end

-- Build GUI
local function createGui()
    local parentGui = (type(gethui) == "function" and gethui()) or CoreGui:FindFirstChild("RobloxGui") or plr:FindFirstChild("PlayerGui")
    local screen = Instance.new("ScreenGui")
    screen.Name = "CowHub_LeaderPetTeleport"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 9999

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 340, 0, 440)
    main.Position = UDim2.new(0.5, -170, 0.5, -220)
    main.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screen

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = main

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(50, 60, 75)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = main

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 38)
    header.BackgroundColor3 = Color3.fromRGB(24, 30, 40)
    header.BorderSizePixel = 0
    header.Parent = main

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    -- Fix header bottom rounding
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Color3.fromRGB(24, 30, 40)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255, 215, 80)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "★ CowHub · Leader Pet Teleporter"
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -32, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        app.destroy()
    end)

    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -16, 0, 26)
    statusBar.Position = UDim2.new(0, 8, 0, 44)
    statusBar.BackgroundColor3 = Color3.fromRGB(26, 32, 42)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = main

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusBar

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -12, 1, 0)
    statusText.Position = UDim2.new(0, 6, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextSize = 11
    statusText.TextColor3 = Color3.fromRGB(150, 210, 255)
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Text = "Select a pet below to teleport & highlight."
    statusText.Parent = statusBar

    -- Scrolling Pet List
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -80)
    scroll.Position = UDim2.new(0, 8, 0, 74)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 95, 120)
    scroll.CanvasSize = UDim2.new(0, 0, 0, #PET_CATALOG * 78)
    scroll.Parent = main

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = scroll

    for i, pet in ipairs(PET_CATALOG) do
        local card = Instance.new("Frame")
        card.Name = "Card_" .. pet.id
        card.Size = UDim2.new(1, -6, 0, 72)
        card.BackgroundColor3 = Color3.fromRGB(24, 30, 40)
        card.BorderSizePixel = 0
        card.LayoutOrder = i
        card.Parent = scroll

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 6)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = if pet.gate then Color3.fromRGB(255, 215, 80) else Color3.fromRGB(50, 65, 85)
        cardStroke.Thickness = if pet.gate then 1.5 else 1.0
        cardStroke.Parent = card

        local icon = if pet.species == "Dog" then "🐕" else "🐈"
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Size = UDim2.new(1, -85, 0, 18)
        headerLabel.Position = UDim2.new(0, 8, 0, 4)
        headerLabel.BackgroundTransparency = 1
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.TextSize = 12
        headerLabel.TextColor3 = if pet.gate then Color3.fromRGB(255, 220, 90) else Color3.fromRGB(220, 230, 245)
        headerLabel.TextXAlignment = Enum.TextXAlignment.Left
        headerLabel.Text = string.format("%s %s · %s", icon, pet.rank, pet.variant)
        headerLabel.Parent = card

        local zoneLabel = Instance.new("TextLabel")
        zoneLabel.Size = UDim2.new(1, -85, 0, 15)
        zoneLabel.Position = UDim2.new(0, 8, 0, 22)
        zoneLabel.BackgroundTransparency = 1
        zoneLabel.Font = Enum.Font.Gotham
        zoneLabel.TextSize = 11
        zoneLabel.TextColor3 = Color3.fromRGB(160, 175, 195)
        zoneLabel.TextXAlignment = Enum.TextXAlignment.Left
        zoneLabel.Text = string.format("Zone: %s (%s)", pet.zone, pet.id)
        zoneLabel.Parent = card

        local statsLabel = Instance.new("TextLabel")
        statsLabel.Size = UDim2.new(1, -85, 0, 15)
        statsLabel.Position = UDim2.new(0, 8, 0, 38)
        statsLabel.BackgroundTransparency = 1
        statsLabel.Font = Enum.Font.GothamMedium
        statsLabel.TextSize = 11
        statsLabel.TextColor3 = Color3.fromRGB(80, 255, 180)
        statsLabel.TextXAlignment = Enum.TextXAlignment.Left
        statsLabel.Text = string.format("Score: %.3f | Def: %.2f | Tim: %.2f", pet.score, pet.def, pet.tim)
        statsLabel.Parent = card

        local subLabel = Instance.new("TextLabel")
        subLabel.Size = UDim2.new(1, -85, 0, 14)
        subLabel.Position = UDim2.new(0, 8, 0, 54)
        subLabel.BackgroundTransparency = 1
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextSize = 10
        subLabel.TextColor3 = Color3.fromRGB(120, 135, 150)
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.Text = pet.desc
        subLabel.Parent = card

        -- Teleport Button
        local tpBtn = Instance.new("TextButton")
        tpBtn.Name = "TeleportBtn"
        tpBtn.Size = UDim2.new(0, 68, 0, 32)
        tpBtn.Position = UDim2.new(1, -74, 0.5, -16)
        tpBtn.BackgroundColor3 = if pet.gate then Color3.fromRGB(220, 170, 40) else Color3.fromRGB(45, 125, 210)
        tpBtn.BorderSizePixel = 0
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 11
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.Text = "TELEPORT"
        tpBtn.Parent = card

        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 5)
        tpCorner.Parent = tpBtn

        tpBtn.MouseButton1Click:Connect(function()
            teleportToPet(pet, statusText)
        end)
    end

    screen.Parent = parentGui
    app.gui = screen
end

-- Initialize
createGui()
app.trackConn = RunService.Heartbeat:Connect(stepTrack)

-- Cleanup
function app.destroy()
    app.running = false
    if app.trackConn then
        pcall(function() app.trackConn:Disconnect() end)
        app.trackConn = nil
    end
    app.track = nil
    clearHighlight()
    if app.gui then
        pcall(function() app.gui:Destroy() end)
        app.gui = nil
    end
    if _G.LeaderPetTeleport == app then
        _G.LeaderPetTeleport = nil
    end
    print("[LeaderPetTeleport] Closed.")
end

print("[LeaderPetTeleport] Ready. GUI opened.")
return app

