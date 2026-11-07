-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false, -- true: remove the running Pet ESP and stop (nothing new starts)

    DOGS = true, -- highlight workspace.LocalDogs
    CATS = true, -- highlight workspace.LocalBarnCats

    -- Stand-ground leader filters. All off = show every pet.
    -- Any on = show only pets one of them picks (all need Defiance > 0.86, Timidity < 0.72).
    LEADER_SCORE = false, -- leader score >= MIN_SCORE
    LEADER_STRICT = false, -- Ini, Ldr, Dom >= MIN_TRAIT and Boldness >= MIN_BOLD
    LEADER_BEST = false, -- only the highest-scoring leader in range

    MIN_SCORE = 0.70,
    MIN_TRAIT = 0.70,
    MIN_BOLD = 1.0,
}
-- ==========================================================================

-- Pet ESP (Dogs / Barn Cats) with temperament readout
-- Highlights every pet model in workspace.LocalDogs / workspace.LocalBarnCats and
-- labels it with Disposition + full personality vector.
--
-- Pet models carry no attributes; the Model -> Record mapping lives only in the
-- DogController / BarnCatController tables ({ Folder, Actors = { {Model, Record} } }),
-- so records are pulled via getgc. Any personality field the record lacks is rebuilt
-- from its Seed with the game's own generators:
--   AnimalIntent.Init        12 base traits (sequential LCG x breed multiplier)
--   AnimalTemperament.Init   salted Sample() traits + Disposition
--   AnimalRelationships      Generosity / FoodTaking;  AnimalBaitBehavior  Chattiness
--
-- Re-executing always replaces the running ESP with the SETTINGS above.
-- Live toggles from console (set, then call _G.PetESP.update()):
--   petESP.show.Dog / petESP.show.Cat         species on/off
--   petESP.leader.score / .strict / .best     stand-ground leader filters (any on = filter;
--                                             a pet shows if any enabled filter picks it)
-- Thresholds live in petESP.leaderRules.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.PetESP and type(_G.PetESP.destroy) == "function" then
    pcall(_G.PetESP.destroy)
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

-- BEGIN petESP core
local petESP = {
    show = { Dog = false, Cat = false },
    -- Every leader filter requires the CanStand gate: Defiance > 0.86 (Headstrong) and Timidity < 0.72.
    leader = {
        score = false, -- gate + leader score >= minScore
        strict = false, -- gate + Ini, Ldr, Dom >= minTrait and Boldness >= minBold
        best = false, -- gate + highest leader score among pets in range
    },
    leaderRules = { minScore = 0.70, minTrait = 0.70, minBold = 1.0 },
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

    -- AnimalIntent.Init: generation order matters (one LCG step per trait).
    local BASE_TRAITS = {
        "Curiosity", "Boldness", "Social", "Play", "Comfort", "Perch",
        "Companion", "Alertness", "Sniff", "Persistence", "Rest", "Energy",
    }
    local BREEDS = {
        GoldenRetriever = { Social = 1.35, Companion = 1.35, Play = 1.15 },
        BorderCollie = { Curiosity = 1.15, Play = 1.35, Companion = 1.2, Energy = 1.2 },
        GermanShepherd = { Boldness = 1.3, Alertness = 1.4, Companion = 1.15 },
        Beagle = { Curiosity = 1.4, Sniff = 1.6, Persistence = 1.25 },
        Corgi = { Social = 1.2, Play = 1.4, Energy = 0.95 },
        Dachshund = { Curiosity = 1.2, Persistence = 1.4, Rest = 1.25 },
    }

    -- Salted AnimalTemperament.Sample traits
    local SALTS = {
        Initiative = 281, Affection = 283, Patience = 293, Defiance = 307,
        HighPlaces = 359, ThreatWatch = 367, Wanderlust = 373,
        Dominance = 401, Timidity = 409, Trouble = 413, Leadership = 417, Neuroticism = 419,
        Generosity = 541, FoodTaking = 547, Chattiness = 193,
    }

    -- Label rows: { key, short label }
    local TRAIT_ROWS = {
        { { "Initiative", "Ini" }, { "Affection", "Aff" }, { "Patience", "Pat" }, { "Defiance", "Def" } },
        { { "Dominance", "Dom" }, { "Timidity", "Tim" }, { "Leadership", "Ldr" }, { "Neuroticism", "Neu" } },
        { { "Trouble", "Trb" }, { "Wanderlust", "Wan" }, { "ThreatWatch", "Thr" }, { "HighPlaces", "Hi" } },
        { { "Play", "Play" }, { "Curiosity", "Curi" }, { "Boldness", "Bold" }, { "SocialTempo", "Tempo" } },
    }

    local function folderOn(name)
        local info = FOLDERS[name]
        return info ~= nil and petESP.show[info.species] == true
    end

    -- AnimalTemperament.Sample (verbatim port)
    local function sample(seed, salt)
        local a = ((math.floor(math.abs(seed or 1)) + salt * 7919) % 2147483646 + 1) * 48271 % 2147483647
        local b = bit32.bxor(a, bit32.lrotate(a, 13), salt * 104729) * 48271 % 2147483647
        return bit32.bxor(b, bit32.rshift(b, 11)) * 48271 % 2147483647 / 2147483647
    end

    -- AnimalIntent.Init base traits (verbatim port)
    local function baseTraits(seed, variant)
        local out = {}
        local mult = BREEDS[variant] or {}
        local v = (seed or 1) % 2147483646 + 1
        for _, key in ipairs(BASE_TRAITS) do
            v = v * 48271 % 2147483647
            out[key] = (0.8 + 0.4 * v / 2147483647) * (mult[key] or 1)
        end
        return out
    end

    -- Full personality vector + disposition. Record values win; missing ones are regenerated.
    local function readTraits(record)
        local personality = type(record.Personality) == "table" and record.Personality or nil
        local seed = tonumber(record.Seed)
        if not personality and not seed then return nil end

        local base = seed and baseTraits(seed, record.Variant) or {}
        local t = {}
        for _, key in ipairs(BASE_TRAITS) do
            t[key] = personality and tonumber(personality[key]) or base[key]
        end
        for key, salt in pairs(SALTS) do
            t[key] = personality and tonumber(personality[key]) or (seed and sample(seed, salt))
        end
        t.SocialTempo = personality and tonumber(personality.SocialTempo) or (seed and 0.78 + sample(seed, 311) * 0.58)

        local disposition = personality and type(personality.Disposition) == "string" and personality.Disposition
        if not disposition and t.Defiance and t.Initiative and t.Affection and t.Patience then
            local play = t.Play or 1
            disposition = t.Defiance > 0.86 and "Headstrong"
                or (t.Initiative > 0.7 and play > 1) and "Rascal"
                or t.Affection > 0.68 and "Companion"
                or t.Patience > 0.7 and "Observer"
                or t.Initiative < 0.3 and "Independent"
                or "Sociable"
        end
        return t, disposition or nil
    end

    -- Stand-ground leader rating (gates from AnimalTemperament.CanStand).
    local function rateLeader(t)
        local def, tim = t.Defiance or 0, t.Timidity or 1
        local gate = def > 0.86 and tim < 0.72
        local ini, ldr, dom = t.Initiative or 0, t.Leadership or 0, t.Dominance or 0
        local bold = t.Boldness or 1
        local boldNorm = math.clamp((bold - 0.8) / 0.4, 0, 1)
        local score = (ini + ldr + dom + (1 - tim) + (1 - (t.Neuroticism or 1)) + boldNorm) / 6
        local r = petESP.leaderRules
        local strict = gate and ini >= r.minTrait and ldr >= r.minTrait and dom >= r.minTrait and bold >= r.minBold
        return gate, score, strict
    end

    local function describe(record)
        local t, disposition = readTraits(record)
        if not t then return nil end
        local gate, score, strict = rateLeader(t)
        return {
            traits = t,
            disposition = disposition,
            gate = gate,
            score = score,
            strict = strict,
            byScore = gate and score >= petESP.leaderRules.minScore,
        }
    end
    petESP.describe = describe

    local function descriptor(t)
        if (t.Play or 0) > 1.1 then return "playful" end
        if (t.Curiosity or 0) > 1.1 then return "curious" end
        return "easygoing"
    end

    local function traitText(info, isBest)
        local t = info.traits
        local head = (info.disposition or "?") .. " · " .. descriptor(t)
        if info.gate then
            local tags = {}
            if isBest then tags[#tags + 1] = "BEST" end
            if info.strict then tags[#tags + 1] = "STRICT" end
            local tagText = #tags > 0 and (" [" .. table.concat(tags, "/") .. "]") or ""
            head = "★ LEADER " .. string.format("%.2f", info.score) .. tagText .. " · " .. head
        end
        local lines = { head }
        for _, row in ipairs(TRAIT_ROWS) do
            local parts = {}
            for _, cell in ipairs(row) do
                local v = t[cell[1]]
                parts[#parts + 1] = cell[2] .. " " .. (v and string.format("%.2f", v) or "--")
            end
            lines[#lines + 1] = table.concat(parts, "  ")
        end
        return table.concat(lines, "\n")
    end

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
        billboard.Size = UDim2.new(0, 280, 0, 110)
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

    local function setVisible(visual, visible)
        if visual.highlight.Enabled ~= visible then
            visual.highlight.Enabled = visible
            visual.billboard.Enabled = visible
        end
    end

    local function drawVisual(visual, record, info, isBest, rPos)
        local folder = FOLDERS[visual.folderName]
        local title = folder.icon .. " " .. folder.species
        if record then
            if type(record.Name) == "string" and record.Name ~= "" then
                title = folder.icon .. " " .. record.Name
            end
            local variant = record.Variant or record.Coat
            if type(variant) == "string" then title = title .. " (" .. variant .. ")" end
            if record.AgeStage == "Young" or record.Puppy == true or record.Kitten == true then
                title = title .. " [young]"
            end
        end

        local body = info and traitText(info, isBest)
            or (petESP.controllers[visual.folderName] and "traits: no record" or "traits unavailable (no getgc)")
        local dist = rPos and ("\n[" .. math.floor((rPos - visual.targetPart.Position).Magnitude) .. " studs]") or ""

        local text = title .. "\n" .. body .. dist
        if text ~= visual.lastText then
            visual.lastText = text
            visual.label.Text = text
            local color = info and info.gate and LEADER_COLOR
                or info and info.disposition and DISPOSITION_COLORS[info.disposition]
                or UNKNOWN_COLOR
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

        -- Pass 1: drop dead visuals, describe live ones, find best leader.
        local infos = {}
        local bestModel, bestScore = nil, -1
        for model, visual in pairs(petESP.visuals) do
            local folder = model.Parent
            if not folder or folder.Parent ~= workspace or not folderOn(folder.Name) or not visual.targetPart.Parent then
                -- Pooled models are reparented to nil when released
                removeVisual(model)
            else
                local record = petESP.modelRecords[model]
                local info = record and describe(record)
                infos[model] = info or false
                if info and info.gate and info.score > bestScore then
                    bestModel, bestScore = model, info.score
                end
            end
        end

        -- Pass 2: filter + draw.
        local L = petESP.leader
        local filtering = L.score or L.strict or L.best
        local char = plr.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        local rPos = root and root.Position or nil
        for model, info in pairs(infos) do
            local visual = petESP.visuals[model]
            local isBest = model == bestModel
            local visible = not filtering
                or (info and ((L.score and info.byScore) or (L.strict and info.strict) or (L.best and isBest)))
                or false
            setVisible(visual, visible)
            if visible then
                drawVisual(visual, petESP.modelRecords[model], info or nil, isBest, rPos)
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

petESP.show.Dog = SETTINGS.DOGS == true
petESP.show.Cat = SETTINGS.CATS == true
petESP.leader.score = SETTINGS.LEADER_SCORE == true
petESP.leader.strict = SETTINGS.LEADER_STRICT == true
petESP.leader.best = SETTINGS.LEADER_BEST == true
petESP.leaderRules.minScore = tonumber(SETTINGS.MIN_SCORE) or petESP.leaderRules.minScore
petESP.leaderRules.minTrait = tonumber(SETTINGS.MIN_TRAIT) or petESP.leaderRules.minTrait
petESP.leaderRules.minBold = tonumber(SETTINGS.MIN_BOLD) or petESP.leaderRules.minBold
petESP.update()
_G.PetESP = petESP
return petESP
