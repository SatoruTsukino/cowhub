-- Field Raid Probe
-- One-shot dump of everything the hub's field raid + blacksmith automation reads:
--   player raid/smith attributes, workspace.CowWorld.Geometry (raid arena FR<run id>, FieldRaids stations),
--   live raid targets in workspace.NorthRiverRaidView (wheat cells + enemies), and the blacksmith/anvil site.
-- Output: cowhub/probes/fieldraid_<unix>.txt (and a short console summary).

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer
local DIR = "cowhub/probes"
local path = DIR .. "/fieldraid_" .. os.time() .. ".txt"
local out = {}

local function add(line)
    out[#out + 1] = line
end

local function fmtVec(v)
    if typeof(v) ~= "Vector3" then return tostring(v) end
    return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
end

local function fmtAttrs(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    if not ok or not attrs or next(attrs) == nil then return "" end
    local parts = {}
    for k, v in pairs(attrs) do
        local s = typeof(v) == "Vector3" and fmtVec(v) or tostring(v)
        if #s > 60 then s = string.sub(s, 1, 60) .. "…" end
        parts[#parts + 1] = k .. "=" .. s
    end
    table.sort(parts)
    return " {" .. table.concat(parts, ", ") .. "}"
end

local function instPos(inst)
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok then return cf.Position end
    end
    return nil
end

local function rootPos()
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or nil
end

local function promptLine(p, depth)
    local holder = p.Parent
    local pos = holder and instPos(holder)
    add(string.rep("  ", depth) .. string.format("[Prompt] %s action=%q object=%q enabled=%s dist=%.0f hold=%.2f at %s%s",
        p.Name, p.ActionText, p.ObjectText, tostring(p.Enabled), p.MaxActivationDistance, p.HoldDuration,
        fmtVec(pos), fmtAttrs(p)))
end

local function tree(inst, depth, maxDepth)
    local pos = instPos(inst)
    add(string.rep("  ", depth) .. string.format("%s [%s] #%d%s%s", inst.Name, inst.ClassName, #inst:GetChildren(),
        pos and (" @ " .. fmtVec(pos)) or "", fmtAttrs(inst)))
    if depth >= maxDepth then
        -- Still surface prompts deeper down: they are what the automation fires
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("ProximityPrompt") then promptLine(d, depth + 1) end
        end
        return
    end
    for _, child in ipairs(inst:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            promptLine(child, depth + 1)
        elseif not child:IsA("BasePart") or #child:GetChildren() > 0 or depth < 2 then
            tree(child, depth + 1, maxDepth)
        end
    end
end

-- 1. Player state
add("== Player ==")
for _, name in ipairs({ "CowFieldRaidId", "CowFieldRaidRewardRoom", "Hearts", "MaxHealth", "SmithJobCycle",
    "SmithJobAtAnvil", "CowClientReady", "CowClientWakeComplete", "ChewCooldown", "CowGrazingSpeedMultiplier" }) do
    add(string.format("  %s = %s", name, tostring(plr:GetAttribute(name))))
end
local rp = rootPos()
add("  root = " .. fmtVec(rp))
local runId = plr:GetAttribute("CowFieldRaidId")

-- 2. Geometry
add("")
add("== workspace.CowWorld.Geometry ==")
local cowWorld = workspace:FindFirstChild("CowWorld")
local geometry = cowWorld and cowWorld:FindFirstChild("Geometry")
if geometry then
    for _, child in ipairs(geometry:GetChildren()) do
        local isRaid = string.sub(child.Name, 1, 2) == "FR" or child.Name == "FieldRaids"
        if isRaid then
            tree(child, 1, 3)
        else
            add(string.format("  %s [%s] #%d", child.Name, child.ClassName, #child:GetChildren()))
        end
    end
else
    add("  (missing)")
end
if runId and geometry and not geometry:FindFirstChild(runId) then
    add("  !! run arena " .. tostring(runId) .. " not found under Geometry")
end

-- 3. Live raid targets
add("")
add("== workspace.NorthRiverRaidView ==")
local view = workspace:FindFirstChild("NorthRiverRaidView")
local counts = { RaidMob = 0, RaidFood = 0, other = 0, available = 0, ripe = 0 }
if view then
    local rows = {}
    for _, model in ipairs(view:GetChildren()) do
        local part = model:IsA("Model") and model.PrimaryPart or (model:IsA("BasePart") and model or nil)
        if part then
            local kind = part:GetAttribute("CowBiteTargetKind")
            counts[kind == "RaidMob" and "RaidMob" or kind == "RaidFood" and "RaidFood" or "other"] += 1
            if part:GetAttribute("Available") then counts.available += 1 end
            if part:GetAttribute("RaidRipe") then counts.ripe += 1 end
            local dist = rp and (part.Position - rp).Magnitude or -1
            rows[#rows + 1] = { dist, string.format("  %-44s %-8s %-10s avail=%s ripe=%s hp=%s/%s state=%s size=%s dist=%.1f @ %s",
                tostring(part:GetAttribute("NodeId")), tostring(kind), model.Name,
                tostring(part:GetAttribute("Available")), tostring(part:GetAttribute("RaidRipe")),
                tostring(part:GetAttribute("Health")), tostring(part:GetAttribute("MaxHealth")),
                tostring(part:GetAttribute("RaidState")), fmtVec(part.Size), dist, fmtVec(part.Position)) }
        else
            counts.other += 1
            rows[#rows + 1] = { math.huge, "  " .. model.Name .. " [" .. model.ClassName .. "] (no PrimaryPart)" }
        end
    end
    table.sort(rows, function(a, b) return a[1] < b[1] end)
    for i, r in ipairs(rows) do
        if i > 200 then add("  … " .. (#rows - 200) .. " more") break end
        add(r[2])
    end
else
    add("  (missing: not in a raid)")
end

-- 4. Blacksmith / anvil site
add("")
add("== Blacksmith ==")
local decorations = cowWorld and cowWorld:FindFirstChild("Decorations")
local smith = decorations and decorations:FindFirstChild("Blacksmith")
add("  Blacksmith = " .. tostring(smith and smith:GetFullName()) .. " Activity=" .. tostring(smith and smith:GetAttribute("Activity")))
local head = smith and smith:FindFirstChild("Head")
add("  Head @ " .. fmtVec(head and head.Position))
local outfitters = decorations and decorations:FindFirstChild("NorthRiverOutfitters")
local house = outfitters and outfitters:FindFirstChild("BlacksmithHouseAndPorch")
local shop = house and house:FindFirstChild("Blacksmith Shop")
local anvil = shop and shop:FindFirstChild("AnvilCollider")
add("  AnvilCollider @ " .. fmtVec(anvil and anvil.Position) .. (rp and anvil and string.format(" dist=%.1f", (anvil.Position - rp).Magnitude) or ""))
local shared = ReplicatedStorage:FindFirstChild("CowGame") and ReplicatedStorage.CowGame:FindFirstChild("Shared")
local okCycle, sample = pcall(function() return require(shared.DayNightCycle).Sample() end)
local okRules, rules = pcall(function() return require(shared.SmithingRules) end)
if okCycle and type(sample) == "table" then
    add(string.format("  DayNight Phase=%s Progress=%.3f CycleIndex=%s Enabled=%s Open=%s", tostring(sample.Phase),
        tonumber(sample.PhaseProgress) or -1, tostring(sample.CycleIndex), tostring(sample.Enabled),
        okRules and tostring(rules.Open(sample)) or "?"))
else
    add("  DayNightCycle require failed: " .. tostring(sample))
end

-- 5. Remotes
add("")
add("== Remotes ==")
local remotes = ReplicatedStorage:FindFirstChild("CowGame") and ReplicatedStorage.CowGame:FindFirstChild("Remotes")
for _, name in ipairs({ "FieldRaidRequest", "ChompRequest", "ClientEvent" }) do
    local r = remotes and remotes:FindFirstChild(name)
    add(string.format("  %s = %s", name, r and r.ClassName or "missing"))
end

local text = table.concat(out, "\n")
local saved = false
if type(writefile) == "function" then
    saved = pcall(function()
        if type(makefolder) == "function" then
            if type(isfolder) ~= "function" or not isfolder("cowhub") then pcall(makefolder, "cowhub") end
            if type(isfolder) ~= "function" or not isfolder(DIR) then pcall(makefolder, DIR) end
        end
        writefile(path, text)
    end)
end

print(string.format("[FieldRaidProbe] run=%s mobs=%d wheat=%d available=%d ripe=%d -> %s",
    tostring(runId), counts.RaidMob, counts.RaidFood, counts.available, counts.ripe, saved and path or "(writefile unavailable)"))
if not saved then
    print(text)
end
