-- Pet ESP (Dogs / Barn Cats) with temperament readout
-- Highlights every pet model in workspace.LocalDogs / workspace.LocalBarnCats and
-- labels it with Disposition + AnimalTemperament trait vector.
--
-- Pet models carry no attributes; the Model -> Record mapping lives only in the
-- DogController / BarnCatController tables ({ Folder, Actors = { {Model, Record} } }),
-- so traits are pulled via getgc. Missing personality fields are recomputed from the
-- record Seed with the game's own Sample PRNG (AnimalTemperament.Sample).
--
-- The block between BEGIN/END petESP core is pasted verbatim into preview.lua.
-- API: set petESP.show.Dog / petESP.show.Cat / petESP.leaderOnly, then call petESP.update().

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.PetESP and type(_G.PetESP.destroy) == "function" then
    pcall(_G.PetESP.destroy)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

-- BEGIN petESP core
local petESP = {
    show = { Dog = false, Cat = false },
    leaderOnly = false, -- true: show only stand-ground leaders (Defiance > 0.86, Timidity < 0.72)
    visuals = {}, -- [Model] = { highlight, billboard, label, targetPart, folderName, lastText }
    controllers = {}, -- [folderName] = DogController / BarnCatController table
    modelRecords = {}, -- [Model] = record
    conn = nil,
}

do
    local FOLDERS = {
        LocalDogs = { species = "Dog", icon = "🐕" },
        LocalBarnCats = { species = "Cat", icon = "🐈" },
    }

    local DISPOSITION_COLORS = {
        Headstrong = Color3.fromRGB(255, 80, 80),
        Rascal = Color3.fromRGB(255, 170, 40),
        Companion = Color3.fromRGB(255, 120, 200),
        Observer = Color3.fromRGB(120, 180, 255),
        Independent = Color3.fromRGB(170, 170, 170),
        Sociable = Color3.fromRGB(110, 230, 120),
    }
    local UNKNOWN_COLOR = Color3.fromRGB(0, 220, 255)
    local LEADER_COLOR = Color3.fromRGB(255, 215, 0)

    -- Trait rows shown on the label: { key, short label, salt }
    local TRAIT_ROWS = {
        { { "Initiative", "Ini", 281 }, { "Affection", "Aff", 283 }, { "Patience", "Pat", 293 }, { "Defiance", "Def", 307 } },
        { { "Dominance", "Dom", 401 }, { "Timidity", "Tim", 409 }, { "Leadership", "Ldr", 417 }, { "Neuroticism", "Neu", 419 } },
        { { "Trouble", "Trb", 413 }, { "Wanderlust", "Wan", 373 }, { "ThreatWatch", "Thr", 367 }, { "HighPlaces", "Hi", 359 } },
    }

    local function folderOn(name)
        local info = FOLDERS[name]
        return info ~= nil and petESP.show[info.species] == true
    end

    -- Temperament (ported verbatim from AnimalTemperament)
    local function sample(seed, salt)
        local a = ((math.floor(math.abs(seed or 1)) + salt * 7919) % 2147483646 + 1) * 48271 % 2147483647
        local b = bit32.bxor(a, bit32.lrotate(a, 13), salt * 104729) * 48271 % 2147483647
        return bit32.bxor(b, bit32.rshift(b, 11)) * 48271 % 2147483647 / 2147483647
    end

    local function traitValue(personality, seed, key, salt)
        local v = personality and tonumber(personality[key])
        if v then return v end
        if seed then return sample(seed, salt) end
        return nil
    end

    local function computeDisposition(personality, seed)
        if personality and type(personality.Disposition) == "string" then
            return personality.Disposition
        end
        local defiance = traitValue(personality, seed, "Defiance", 307)
        local initiative = traitValue(personality, seed, "Initiative", 281)
        local affection = traitValue(personality, seed, "Affection", 283)
        local patience = traitValue(personality, seed, "Patience", 293)
        if not (defiance and initiative and affection and patience) then return nil end
        local play = personality and tonumber(personality.Play) or 1
        if defiance > 0.86 then return "Headstrong" end
        if initiative > 0.7 and play > 1 then return "Rascal" end
        if affection > 0.68 then return "Companion" end
        if patience > 0.7 then return "Observer" end
        if initiative < 0.3 then return "Independent" end
        return "Sociable"
    end

    local function descriptor(personality)
        if not personality then return nil end
        if (tonumber(personality.Play) or 0) > 1.1 then return "playful" end
        if (tonumber(personality.Curiosity) or 0) > 1.1 then return "curious" end
        return "easygoing"
    end

    local function buildTraitText(record)
        local personality = type(record.Personality) == "table" and record.Personality or nil
        local seed = tonumber(record.Seed)
        if not personality and not seed then
            return nil, nil
        end

        local disposition = computeDisposition(personality, seed)
        local head = disposition or "?"
        local desc = descriptor(personality)
        if desc then head = head .. " · " .. desc end
        local lines = { head }

        -- Stand-ground leader: hard gates from AnimalTemperament.CanStand
        -- (Defiance must beat the 0.86–0.91 threshold; Timidity < 0.72 unlocks taunt resistance).
        local function t(key, salt) return traitValue(personality, seed, key, salt) or 0 end
        local leader = t("Defiance", 307) > 0.86 and t("Timidity", 409) < 0.72
        if leader then
            local score = (t("Initiative", 281) + t("Leadership", 417) + t("Dominance", 401)
                + (1 - t("Timidity", 409)) + (1 - t("Neuroticism", 419))) / 5
            lines[1] = "★ LEADER " .. string.format("%.2f", score) .. " · " .. head
        end

        for _, row in ipairs(TRAIT_ROWS) do
            local parts = {}
            for _, t in ipairs(row) do
                local v = traitValue(personality, seed, t[1], t[3])
                parts[#parts + 1] = t[2] .. " " .. (v and string.format("%.2f", v) or "--")
            end
            lines[#lines + 1] = table.concat(parts, "  ")
        end

        if personality then
            local extras = {}
            for _, key in ipairs({ "Play", "Curiosity", "Boldness" }) do
                local v = tonumber(personality[key])
                if v then extras[#extras + 1] = string.sub(key, 1, 4) .. " " .. string.format("%.2f", v) end
            end
            local tempo = tonumber(personality.SocialTempo) or (seed and 0.78 + sample(seed, 311) * 0.58)
            if tempo then extras[#extras + 1] = "Tempo " .. string.format("%.2f", tempo) end
            if #extras > 0 then lines[#lines + 1] = table.concat(extras, "  ") end
        end

        return table.concat(lines, "\n"), disposition, leader
    end
    petESP.buildTraitText = buildTraitText

    -- Controller discovery (getgc) and Model -> Record map
    local function findControllers()
        if type(getgc) ~= "function" then return end
        local wanted = {}
        local need = false
        for name in pairs(FOLDERS) do
            local folder = workspace:FindFirstChild(name)
            local ctrl = petESP.controllers[name]
            if folder and folderOn(name) and not (ctrl and rawget(ctrl, "Folder") == folder) then
                wanted[folder] = name
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
                    petESP.controllers[name] = obj
                    wanted[folder] = nil
                    if next(wanted) == nil then break end
                end
            end
        end
    end

    local function refreshRecords()
        table.clear(petESP.modelRecords)
        for _, ctrl in pairs(petESP.controllers) do
            local actors = rawget(ctrl, "Actors")
            if type(actors) == "table" then
                for _, actor in pairs(actors) do
                    if type(actor) == "table" then
                        local model = rawget(actor, "Model")
                        local record = rawget(actor, "RenderRecord") or rawget(actor, "Record")
                        if typeof(model) == "Instance" and type(record) == "table" then
                            petESP.modelRecords[model] = record
                        end
                    end
                end
            end
        end
    end

    -- Visuals
    local function removeVisual(model)
        local visual = petESP.visuals[model]
        if not visual then return end
        pcall(function() visual.highlight:Destroy() end)
        pcall(function() visual.billboard:Destroy() end)
        petESP.visuals[model] = nil
    end

    local function attach(model, folderName)
        if petESP.visuals[model] or not model:IsA("Model") then return end
        local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if not targetPart then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "PetESPHighlight"
        highlight.Adornee = model
        highlight.FillColor = UNKNOWN_COLOR
        highlight.FillTransparency = 0.55
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PetESPText"
        billboard.Adornee = targetPart
        billboard.Size = UDim2.new(0, 260, 0, 96)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 400

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextYAlignment = Enum.TextYAlignment.Bottom
        label.Parent = billboard
        billboard.Parent = model

        petESP.visuals[model] = {
            highlight = highlight,
            billboard = billboard,
            label = label,
            targetPart = targetPart,
            folderName = folderName,
            lastText = nil,
        }
    end

    local function syncFolders()
        for name in pairs(FOLDERS) do
            local folder = folderOn(name) and workspace:FindFirstChild(name)
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    attach(child, name)
                end
            end
        end
    end

    local function updateVisual(model, visual, rPos)
        local info = FOLDERS[visual.folderName]
        local record = petESP.modelRecords[model]
        local title = info.icon .. " " .. info.species
        local body, disposition, leader

        if record then
            local variant = record.Variant or record.Coat
            if type(record.Name) == "string" and record.Name ~= "" then
                title = info.icon .. " " .. record.Name
            end
            if type(variant) == "string" then title = title .. " (" .. variant .. ")" end
            if record.AgeStage == "Young" or record.Puppy == true or record.Kitten == true then
                title = title .. " [young]"
            end
            body, disposition, leader = buildTraitText(record)
        end

        local visible = leader or not petESP.leaderOnly
        if visual.highlight.Enabled ~= visible then
            visual.highlight.Enabled = visible
            visual.billboard.Enabled = visible
        end
        if not visible then return end
        body = body or (petESP.controllers[visual.folderName] and "traits: no record" or "traits unavailable (no getgc)")

        local dist = ""
        if rPos then
            dist = "\n[" .. math.floor((rPos - visual.targetPart.Position).Magnitude) .. " studs]"
        end

        local text = title .. "\n" .. body .. dist
        if text ~= visual.lastText then
            visual.lastText = text
            visual.label.Text = text
            local color = leader and LEADER_COLOR or disposition and DISPOSITION_COLORS[disposition] or UNKNOWN_COLOR
            visual.highlight.FillColor = color
            visual.label.TextColor3 = color
        end
    end

    local function step(clock)
        local now = os.clock()
        if now - clock.gc > 5 then
            clock.gc = now
            findControllers()
        end
        if now - clock.scan > 1 then
            clock.scan = now
            syncFolders()
        end
        if now - clock.records > 0.5 then
            clock.records = now
            refreshRecords()
        end
        if now - clock.draw < 0.15 then return end
        clock.draw = now

        local char = plr.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        local rPos = root and root.Position or nil
        for model, visual in pairs(petESP.visuals) do
            local folder = model.Parent
            if not folder or folder.Parent ~= workspace or not folderOn(folder.Name) or not visual.targetPart.Parent then
                -- Pooled models are reparented to nil when released
                removeVisual(model)
            else
                updateVisual(model, visual, rPos)
            end
        end
    end

    -- Apply petESP.show: attach/drop per species, start/stop the loop.
    function petESP.update()
        for model, visual in pairs(petESP.visuals) do
            if not folderOn(visual.folderName) then
                removeVisual(model)
            end
        end

        if petESP.show.Dog or petESP.show.Cat then
            findControllers()
            refreshRecords()
            syncFolders()
            if not petESP.conn then
                local clock = { gc = os.clock(), scan = 0, records = 0, draw = 0 }
                petESP.conn = RunService.Heartbeat:Connect(function()
                    step(clock)
                end)
            end
        elseif petESP.conn then
            pcall(function() petESP.conn:Disconnect() end)
            petESP.conn = nil
            table.clear(petESP.modelRecords)
        end
    end
end
-- END petESP core

function petESP.destroy()
    petESP.show.Dog = false
    petESP.show.Cat = false
    petESP.update()
    table.clear(petESP.controllers)
    if _G.PetESP == petESP then
        _G.PetESP = nil
    end
end

-- Standalone run: both species on.
petESP.show.Dog = true
petESP.show.Cat = true
petESP.update()
_G.PetESP = petESP
return petESP
