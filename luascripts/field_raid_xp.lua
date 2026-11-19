--[[
    Field Raid Powerup XP Autofarm (Standalone) — CowHub
    Maximizes Field Raid Powerup XP/hr in North River Field Raids:
      - Rush & Reset (default): Blitz Fields 1-9 -> Field 10 (Ogre's Acre) -> hunt Golden Apples
        (120 XP), Warlocks (150 XP), Field Ogre (500 XP), Archers (75 XP), and F10 Wheat (31 XP)
        -> exit via River Ferry (+1,000 Far Riverbank + 500 Safe Exit) -> Harvest Meadow -> repeat.
      - Camp F10: Blitz to Field 10 and continuously farm Golden Apples, Farmer waves (40 XP),
        fixed mobs, and respawning Wheat (31 XP / 18s), banking safely if Hearts drop low.

    Plan: .gsd/milestones/field-raid/phases/3/3.1-PLAN.md
    Safe to re-execute: replaces any previous _G.CowFieldRaidXP instance and pauses
    _G.CowHubFieldRaid.auto and _G.CowMillQuests.running.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

if _G.CowFieldRaidXP and _G.CowFieldRaidXP.destroy then
    pcall(_G.CowFieldRaidXP.destroy)
end

local cowGame = ReplicatedStorage:WaitForChild("CowGame", 15)
local cowRemotes = cowGame and cowGame:WaitForChild("Remotes", 15)
local cowShared = cowGame and cowGame:WaitForChild("Shared", 15)

local xp = {
    running = false,
    destroyed = false,
    mode = "Rush & Reset", -- "Rush & Reset" | "Camp F10"
    autoStart = true,
    status = "Idle (press Start)",

    -- Powerup XP & session stats (synced via GetSnapshot & Ended events)
    equipped = {},
    powerupXP = {},
    baselineTotalXP = nil,
    totalPowerupXP = 0,
    sessionXP = 0,
    runsDone = 0,
    activeSeconds = 0,
    lastActiveAt = 0,
    syncBusy = false,

    -- Live run state
    run = nil,
    level = 0,
    planting = nil,
    grazeRun = nil,
    leaving = false,
    exitVia = nil,
    returnedAt = 0,
    lastStartTry = 0,
    startTries = 0,
    lastSnapshotAsk = 0,
    lastTick = 0,
    lastScan = 0,
    lastPromptScan = 0,
    lastMove = 0,
    lastMeadowFire = 0,
    lastMeadowScan = 0,
    lastGateFire = 0,
    lastStream = 0,
    sprinting = nil,
    sprintAt = 0,

    -- Per-run XP & Field 10 trackers
    estActionXP = 0,
    f10EnteredAt = nil,
    f10VisitedMid = false,
    lastHighSeenAt = 0,
    recentMobHits = {}, -- [nodeId] = { at, species }

    -- World & target caches
    mobs = {},
    foods = {},
    chestPrompts = {},
    chestTried = setmetatable({}, { __mode = "k" }),
    gatePrompt = nil,
    ferryPrompt = nil,
    meadowChest = nil,
    homePrompt = nil,
    bossPos = nil,
    bossHealth = 0,

    -- Chest healing state
    chestBusy = false,
    chestUntil = 0,
    chestToken = nil,
    chestOpenedAt = 0,
    chestClosed = false,

    -- Chomp / serial wire state (distinct serial range from hub & mill_quests)
    serial = 800000,
    lastFire = 0,
    margin = 0.03,
    rtt = 0.25,
    blockUntil = 0,
    iasStreak = 0,
    pending = {},
    skip = {},
    REACH = 9,
    MOB_RANGE = 9,

    -- Hazard / dodge / path state
    hazards = {},
    lastBlink = 0,
    dodgeTarget = nil,
    dodgeUntil = 0,
    goalPos = nil,
    path = nil,
    pathTarget = nil,
    pathIndex = 0,
    pathAt = 0,
    pathBusy = false,
    stuckPos = nil,
    stuckAt = 0,
    nudgeUntil = 0,
    nudgeDir = 1,
    orbitAngle = 0,
    sweepDir = 1,

    -- Constants from FieldRaidPowerups / FieldRaidEnemies / FieldRaidLayout
    KILL_XP = {
        Spider = 20,
        Farmer = 40,
        VillageGuard = 70,
        VillageArcher = 75,
        CityGuard = 100,
        Warlock = 150,
        FieldOgre = 500,
    },
    SECONDARY = {
        GoldenApple = true,
        GoldMushroom = true,
        Mushroom = true,
        Clover = true,
        WildBarley = true,
    },
    HIGH_PACK = {
        FieldOgre = true,
        Warlock = true,
        VillageArcher = true,
    },
    FIELD_DEPTHS = { 0, 55, 115, 180, 250, 325, 405, 490, 585, 690, 810.42096 },
    PLANTING_FALLBACK = { Frame = CFrame.new(54.6875, 701.7, 30476.408), Size = Vector3.new(1080.0925, 1, 4052.1047) },
    GATE_REL = Vector3.new(-471.95, 5.25, 2056.05),
    FERRY_REL = Vector3.new(-462.95, 5.3, -2022.05),

    conns = {},
    gui = nil,
    ui = {},
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function getChar()
    local c = plr.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return c, r, h
end

local function setRootCFrame(cf, targetRoot)
    if not targetRoot or not cf then return end
    if targetRoot:IsA("BasePart") then
        targetRoot.CFrame = cf
    elseif targetRoot:IsA("Model") then
        targetRoot:PivotTo(cf)
    end
end

function xp.fireRaid(...)
    local remote = xp.raidRemote
    if not remote or not remote.Parent then
        remote = cowRemotes and cowRemotes:FindFirstChild("FieldRaidRequest")
        xp.raidRemote = remote
    end
    if not remote then return false end
    return (pcall(remote.FireServer, remote, ...))
end

function xp.loadMods()
    if not xp.combat and cowShared then
        pcall(function() xp.combat = require(cowShared:FindFirstChild("FieldRaidCombat")) end)
        pcall(function() xp.enemies = require(cowShared:FindFirstChild("FieldRaidEnemies")) end)
        pcall(function() xp.powerupsMod = require(cowShared:FindFirstChild("FieldRaidPowerups")) end)
    end
    return xp.combat, xp.enemies, xp.powerupsMod
end

function xp.setStatus(text)
    if xp.status == text then return end
    xp.status = text
    if xp.ui.statusLabel then
        xp.ui.statusLabel.Text = text
    end
end

function xp.formatRate()
    local hrs = xp.activeSeconds / 3600
    if hrs < 1 / 3600 then return "0 /hr" end
    local rate = math.floor(xp.sessionXP / hrs)
    if rate >= 1000 then
        return string.format("%.1fk/hr", rate / 1000)
    end
    return tostring(rate) .. "/hr"
end

function xp.refreshUI()
    local u = xp.ui
    if not u.gui or not u.gui.Parent then return end
    if u.startBtn then
        u.startBtn.Text = xp.running and "Stop" or "Start"
        u.startBtn.BackgroundColor3 = xp.running and Color3.fromRGB(165, 62, 54) or Color3.fromRGB(58, 134, 86)
    end
    if u.modeBtn then
        u.modeBtn.Text = "Mode: " .. xp.mode
    end
    if u.fieldLabel then
        local run = plr:GetAttribute("CowFieldRaidId")
        local hp = plr:GetAttribute("Hearts")
        local maxHp = plr:GetAttribute("MaxHealth")
        u.fieldLabel.Text = run
            and string.format("Field %d/10  |  Hearts %s/%s  |  ~%d XP", xp.level, tostring(hp or "?"), tostring(maxHp or "?"), math.floor(xp.estActionXP))
            or "Outside Raid (Camp)"
    end
    if u.statsLabel then
        u.statsLabel.Text = string.format("Session: +%d XP (%s)  |  Runs: %d", math.floor(xp.sessionXP), xp.formatRate(), xp.runsDone)
    end
    if u.powerupsLabel then
        local _, _, pmod = xp.loadMods()
        local parts = {}
        for _, id in ipairs(xp.equipped) do
            local raw = xp.powerupXP[id] or 0
            local shortName = (pmod and pmod.Names and pmod.Names[id]) or id
            if pmod and pmod.Level then
                local lv = pmod.Level(raw)
                parts[#parts + 1] = string.format("%s Lv%d", shortName, lv)
            else
                parts[#parts + 1] = string.format("%s (%d)", shortName, raw)
            end
        end
        u.powerupsLabel.Text = #parts > 0 and table.concat(parts, " · ") or "Powerups: Syncing..."
    end
end

function xp.syncPowerups()
    if xp.syncBusy then return end
    local fn = cowRemotes and cowRemotes:FindFirstChild("GetSnapshot")
    if not fn or not fn:IsA("RemoteFunction") then return end
    xp.syncBusy = true
    task.spawn(function()
        local ok, snap = pcall(fn.InvokeServer, fn)
        xp.syncBusy = false
        if xp.destroyed then return end
        local raids = ok and type(snap) == "table" and type(snap.Profile) == "table" and snap.Profile.FieldRaids
        local p = type(raids) == "table" and raids.Powerups
        if type(p) == "table" then
            xp.equipped = type(p.Equipped) == "table" and p.Equipped or {}
            xp.powerupXP = type(p.XP) == "table" and p.XP or {}
            local sum = 0
            for _, v in pairs(xp.powerupXP) do
                if type(v) == "number" then sum += v end
            end
            xp.totalPowerupXP = sum
            if not xp.baselineTotalXP then
                xp.baselineTotalXP = sum
            else
                xp.sessionXP = math.max(xp.sessionXP, sum - xp.baselineTotalXP)
            end
            xp.refreshUI()
        end
    end)
end

function xp.resetRunTrackers()
    xp.estActionXP = 0
    xp.f10EnteredAt = nil
    xp.f10VisitedMid = false
    xp.lastHighSeenAt = 0
    table.clear(xp.recentMobHits)
    xp.bossPos = nil
    xp.bossHealth = 0
    table.clear(xp.hazards)
    xp.dodgeTarget = nil
    xp.goalPos = nil
    xp.leaving = false
    xp.exitVia = nil
    xp.chestBusy = false
end

-- Z span of a field level (FieldRaidLayout.Band)
function xp.bandZ(level)
    local planting = xp.planting or xp.PLANTING_FALLBACK
    if type(planting) ~= "table" or typeof(planting.Frame) ~= "CFrame" or typeof(planting.Size) ~= "Vector3" then
        return nil, nil
    end
    level = math.clamp(level, 1, 10)
    local k = planting.Size.Z / xp.FIELD_DEPTHS[11]
    local front = planting.Frame.Position.Z + planting.Size.Z * 0.5
    return front - xp.FIELD_DEPTHS[level] * k, front - xp.FIELD_DEPTHS[level + 1] * k
end

function xp.levelAtZ(z)
    for level = 1, 10 do
        local nearZ, farZ = xp.bandZ(level)
        if nearZ and z <= nearZ and z >= farZ then return level end
    end
    return xp.level > 0 and xp.level or 1
end

function xp.sweepBounds()
    local planting = xp.planting or xp.PLANTING_FALLBACK
    if type(planting) == "table" and typeof(planting.Frame) == "CFrame" and typeof(planting.Size) == "Vector3" then
        local cx, half = planting.Frame.Position.X, planting.Size.X * 0.5 - 25
        return cx - half, cx + half
    end
    return nil, nil
end

function xp.arena()
    local cw = workspace:FindFirstChild("CowWorld")
    local geom = cw and cw:FindFirstChild("Geometry")
    if not geom then return nil end
    local _, root = getChar()
    local from = root and root.Position
    if not from then return geom:FindFirstChild("PrivateFieldRaids") end
    local best, bestD = nil, math.huge
    for _, model in ipairs(geom:GetChildren()) do
        if (model.Name == "PrivateFieldRaids" or string.sub(model.Name, 1, 2) == "FR") and model:IsA("Model") and model:FindFirstChild("HarvestLandings") then
            local ok, pivot = pcall(function() return model:GetPivot().Position end)
            local d = ok and math.abs(pivot.X - from.X) or math.huge
            if d < bestD then best, bestD = model, d end
        end
    end
    return best
end

function xp.cellPoint(part, pos)
    local cf, half = part.CFrame, part.Size * 0.5
    local lp = cf:PointToObjectSpace(pos)
    return cf:PointToWorldSpace(Vector3.new(
        math.clamp(lp.X, -half.X, half.X), math.clamp(lp.Y, -half.Y, half.Y), math.clamp(lp.Z, -half.Z, half.Z)))
end

function xp.mobAlive(part)
    return part and part.Parent ~= nil and (tonumber(part:GetAttribute("Health")) or 0) > 0
end

function xp.speciesOf(part)
    local model = part and part.Parent
    return model and model.Name or ""
end

function xp.isSecondaryFood(part)
    local sp = xp.speciesOf(part)
    if xp.SECONDARY[sp] then return true end
    local fk = part:GetAttribute("FoodKind")
    return fk ~= nil and fk ~= "Wheat" and xp.SECONDARY[tostring(fk)] == true
end

function xp.scan(now, force)
    if not force and now - xp.lastScan < 0.18 then return end
    xp.lastScan = now
    table.clear(xp.mobs)
    table.clear(xp.foods)
    local view = workspace:FindFirstChild("NorthRiverRaidView")
    if not view then return end
    for _, model in ipairs(view:GetChildren()) do
        local part = model:IsA("Model") and model.PrimaryPart
        if part then
            local kind = part:GetAttribute("CowBiteTargetKind")
            if kind == "RaidMob" then
                if xp.mobAlive(part) then
                    xp.mobs[#xp.mobs + 1] = part
                end
            elseif kind == "RaidFood" and part:GetAttribute("Available") == true then
                xp.foods[#xp.foods + 1] = part
            end
        end
    end
end

-- Chomp wire matching InputController: ChompRequest:FireServer(nodeId, nil, serial)
function xp.getInterval(node)
    local base = math.clamp(tonumber(plr:GetAttribute("ChewCooldown")) or 0.7, 0.4, 3)
    local mult = math.clamp(tonumber(plr:GetAttribute("CowGrazingSpeedMultiplier")) or 1, 1, 1.236)
    if node and typeof(node) == "Instance" and node:GetAttribute("FoodKind") == "Wheat" then
        base = base * 0.5
    end
    return (base / mult) + xp.margin
end

function xp.ensureGraze()
    local run = plr:GetAttribute("CowFieldRaidId")
    if run and xp.grazeRun ~= run then
        xp.grazeRun = run
        xp.fireRaid("GrazeStart", run)
    end
end

function xp.face(root, pos)
    if not root then return end
    local rp = root.Position
    local dx, dz = pos.X - rp.X, pos.Z - rp.Z
    if dx * dx + dz * dz > 0.01 then
        root.CFrame = CFrame.lookAt(rp, Vector3.new(pos.X, rp.Y, pos.Z))
    end
end

function xp.sendChomp(nodeId, node, now, root)
    if not nodeId or now < xp.blockUntil then return false end
    local interval = xp.getInterval(node)
    if now - xp.lastFire < interval then return false end
    local remote = xp.chompRemote
    if not remote or not remote.Parent then
        remote = cowRemotes and cowRemotes:FindFirstChild("ChompRequest")
        xp.chompRemote = remote
    end
    if not remote then return false end

    xp.ensureGraze()
    if root and node and node.Position then
        xp.face(root, node.Position)
    end

    xp.serial += 1
    local serial = xp.serial
    xp.lastFire = now
    local kind = node and typeof(node) == "Instance" and node:GetAttribute("CowBiteTargetKind") or ""
    local sp = node and typeof(node) == "Instance" and xp.speciesOf(node) or ""
    local isSec = node and typeof(node) == "Instance" and xp.isSecondaryFood(node) or false
    local lv = node and typeof(node) == "Instance" and xp.levelAtZ(node.Position.Z) or xp.level
    xp.pending[serial] = {
        NodeId = nodeId,
        SentAt = now,
        Kind = kind,
        Species = sp,
        Secondary = isSec,
        Level = lv,
    }
    if kind == "RaidMob" then
        xp.recentMobHits[nodeId] = { at = now, species = sp }
    else
        xp.skip[nodeId] = now + 1.5
    end
    if serial % 32 == 0 then
        for k, p in pairs(xp.pending) do
            if now - p.SentAt > 15 then xp.pending[k] = nil end
        end
        for k, t in pairs(xp.skip) do
            if now >= t then xp.skip[k] = nil end
        end
        for k, h in pairs(xp.recentMobHits) do
            if now - h.at > 15 then xp.recentMobHits[k] = nil end
        end
    end
    pcall(remote.FireServer, remote, nodeId, nil, serial)
    return true
end

-- Instant opportunistic bite in reach: Secondary > High-XP Mob > Wheat
function xp.biteNearby(now, root, rootPos)
    local bestFood, bestSec, bestFoodDist = nil, false, math.huge
    for _, part in ipairs(xp.foods) do
        if part.Parent and part:GetAttribute("Available") == true then
            local id = part:GetAttribute("NodeId")
            local skipUntil = id and xp.skip[id]
            if id and not (skipUntil and now < skipUntil) then
                local d = (xp.cellPoint(part, rootPos) - rootPos).Magnitude
                if d <= xp.REACH then
                    local sec = xp.isSecondaryFood(part)
                    if (sec and not bestSec) or (sec == bestSec and d < bestFoodDist) then
                        bestFood, bestSec, bestFoodDist = part, sec, d
                    end
                end
            end
        end
    end
    if bestFood and bestSec then
        xp.sendChomp(bestFood:GetAttribute("NodeId"), bestFood, now, root)
        return true
    end

    local bestMob, bestScore = nil, -1
    for _, part in ipairs(xp.mobs) do
        if xp.mobAlive(part) then
            local d = (part.Position - rootPos).Magnitude
            if d <= xp.MOB_RANGE then
                local sp = xp.speciesOf(part)
                local hp = math.max(1, tonumber(part:GetAttribute("Health")) or 10)
                local kxp = xp.KILL_XP[sp] or 20
                local score = kxp / hp
                if score > bestScore then
                    bestMob, bestScore = part, score
                end
            end
        end
    end
    if bestMob then
        xp.sendChomp(bestMob:GetAttribute("NodeId"), bestMob, now, root)
        return true
    end

    if bestFood then
        xp.sendChomp(bestFood:GetAttribute("NodeId"), bestFood, now, root)
        return true
    end
    return false
end

-- Telegraph danger & blink-dodge (FieldRaidCombat.Contains)
function xp.addHazard(msg)
    local attack = msg.Attack
    if type(attack) ~= "table" or type(attack.StrikeAt) ~= "number" then return end
    local _, enemies = xp.loadMods()
    if not enemies then return end
    local ok, def = pcall(enemies.Move, msg.Species, attack.Move)
    if not ok or type(def) ~= "table" or not def.Shape then return end

    if def.Projectile and msg.Kind == "Windup" and typeof(msg.Frame) == "CFrame" then
        local _, r = getChar()
        local shooter = msg.Frame.Position
        if r and (r.Position - shooter).Magnitude <= (def.Range or 60) + 10 then
            local lead = attack.StrikeAt - workspace:GetServerTimeNow()
            task.delay(math.max(0, lead - 0.12), function() xp.jink(shooter) end)
        end
    end

    local ends = tonumber(attack.EndsAt) or (attack.StrikeAt + 0.35)
    if def.Shape == "Tripline" then
        ends = math.max(ends, attack.StrikeAt + (def.ActiveSeconds or 1.6))
    end
    local list = xp.hazards
    if msg.Kind ~= "BarrageMark" then
        for i = #list, 1, -1 do
            if list[i].id == msg.Id and not list[i].mark then table.remove(list, i) end
        end
    end
    if type(attack.Points) == "table" and not attack.Point then
        local pulses = type(attack.PulseTimes) == "table" and attack.PulseTimes or {}
        for i, point in ipairs(attack.Points) do
            local strike = tonumber(pulses[i]) or attack.StrikeAt
            local one = table.clone(attack)
            one.Point, one.StrikeAt = point, strike
            list[#list + 1] = { id = msg.Id, def = def, attack = one, strike = strike, ends = strike + 0.35, mark = true }
        end
    else
        list[#list + 1] = { id = msg.Id, def = def, attack = attack, strike = attack.StrikeAt, ends = ends, mark = msg.Kind == "BarrageMark" }
    end

    task.defer(xp.blinkDodge)
    local lead = attack.StrikeAt - workspace:GetServerTimeNow()
    if lead > 0.2 then
        task.delay(lead - 0.15, xp.blinkDodge)
    end
end

function xp.dropHazards(id)
    local list = xp.hazards
    for i = #list, 1, -1 do
        if list[i].id == id then table.remove(list, i) end
    end
end

local DANGER_MARGIN = 1.6
local MARGIN_OFFSETS = {
    Vector3.zero, Vector3.new(DANGER_MARGIN, 0, 0), Vector3.new(-DANGER_MARGIN, 0, 0),
    Vector3.new(0, 0, DANGER_MARGIN), Vector3.new(0, 0, -DANGER_MARGIN),
}

local function segDist(p, a, b)
    local ab = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
    local ap = Vector3.new(p.X - a.X, 0, p.Z - a.Z)
    local len2 = ab:Dot(ab)
    if len2 < 1e-4 then return ap.Magnitude end
    local s = math.clamp(ap:Dot(ab) / len2, 0, 1)
    return (ap - ab * s).Magnitude
end

function xp.danger(pos, serverNow, horizon)
    local combat = xp.combat
    if not combat then return false end
    for _, h in ipairs(xp.hazards) do
        if serverNow <= h.ends and h.strike - serverNow <= horizon then
            local a = h.attack
            if typeof(a.Launch) == "Vector3" and typeof(a.FlightEnd) == "Vector3" then
                if segDist(pos, a.Launch, a.FlightEnd) <= (h.def.Radius or 3) + DANGER_MARGIN then return true end
            elseif h.def.Shape == "Tripline" then
                local ok, hit = pcall(combat.Contains, h.def, a, pos, 4)
                if ok and hit then return true end
            else
                for _, off in ipairs(MARGIN_OFFSETS) do
                    local ok, hit = pcall(combat.Contains, h.def, a, pos + off, 5)
                    if ok and hit then return true end
                end
            end
        end
    end
    return false
end

function xp.spotClear(char, from, spot)
    local view = workspace:FindFirstChild("NorthRiverRaidView")
    rayParams.FilterDescendantsInstances = view and { char, view } or { char }
    local up = Vector3.new(0, 2, 0)
    local dir = spot - from
    if workspace:Raycast(from + up, Vector3.new(dir.X, 0, dir.Z), rayParams) then return false end
    local ground = workspace:Raycast(spot + Vector3.new(0, 6, 0), Vector3.new(0, -14, 0), rayParams)
    return ground ~= nil and math.abs(ground.Position.Y - (from.Y - 3)) < 6
end

function xp.allowedSpot(spot, rootPos, holdF10)
    local minX, maxX = xp.sweepBounds()
    if minX and (spot.X < minX or spot.X > maxX) then return false end
    if holdF10 then
        local nearZ, farZ = xp.bandZ(10)
        if nearZ and farZ then
            return spot.Z <= nearZ - 4 and spot.Z >= farZ + 4
        end
    end
    if xp.leaving and xp.exitVia == "gate" then return true end
    return spot.Z <= rootPos.Z + 4
end

function xp.jumpSilk(humanoid, pos, serverNow)
    local combat = xp.combat
    if not combat or not humanoid then return end
    for _, h in ipairs(xp.hazards) do
        if h.def.Shape == "Tripline" and serverNow <= h.ends and h.strike - serverNow <= 0.35 then
            local ok, hit = pcall(combat.Contains, h.def, h.attack, pos, 4)
            if ok and hit then
                humanoid.Jump = true
                return
            end
        end
    end
end

function xp.blinkDodge(holdF10)
    if not xp.running then return end
    local char, root, humanoid = getChar()
    if not char or not root or not root.Parent or root.Anchored then return end
    xp.jumpSilk(humanoid, root.Position, workspace:GetServerTimeNow())
    if not plr:GetAttribute("CowFieldRaidId") then return end
    local now = os.clock()
    if now - xp.lastBlink < 0.16 then return end
    local serverNow = workspace:GetServerTimeNow()
    local pos = root.Position
    if not xp.danger(pos, serverNow, 1.3) then return end

    local hold = holdF10 or (xp.level >= 10 and not xp.leaving)
    local best, bestScore = nil, math.huge
    for _, r in ipairs({ 5, 8, 12, 17, 22, 26 }) do
        for k = 0, 15 do
            local a = k * math.pi / 8
            local spot = pos + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
            if xp.allowedSpot(spot, pos, hold) and not xp.danger(spot, serverNow, 2.5) then
                local score = r + (hold and 0 or (spot.Z - pos.Z) * 0.06)
                if xp.goalPos then score = r * 0.3 + (spot - xp.goalPos).Magnitude end
                if score < bestScore and xp.spotClear(char, pos, spot) then
                    best, bestScore = spot, score
                end
            end
        end
        if best and not xp.goalPos then break end
    end
    if not best then return end
    xp.lastBlink = now
    local look = root.CFrame.LookVector
    setRootCFrame(CFrame.lookAt(best, best + Vector3.new(look.X, 0, look.Z)), root)
    root.AssemblyLinearVelocity = Vector3.zero
    xp.path, xp.pathTarget = nil, nil
end

function xp.jink(shooterPos)
    if not xp.running or not plr:GetAttribute("CowFieldRaidId") then return end
    local char, root = getChar()
    if not char or not root or not root.Parent or root.Anchored then return end
    local pos = root.Position
    local toCow = Vector3.new(pos.X - shooterPos.X, 0, pos.Z - shooterPos.Z)
    if toCow.Magnitude < 0.5 then return end
    local side = Vector3.new(-toCow.Z, 0, toCow.X).Unit
    local serverNow = workspace:GetServerTimeNow()
    local hold = xp.level >= 10 and not xp.leaving
    local first = xp.jinkSide or 1
    if xp.goalPos then
        first = (xp.goalPos - pos):Dot(side) >= 0 and 1 or -1
    end
    for _, dist in ipairs({ 7, 10, 5 }) do
        for _, sgn in ipairs({ first, -first }) do
            local spot = pos + side * (dist * sgn)
            if xp.allowedSpot(spot, pos, hold) and not xp.danger(spot, serverNow, 2.5) and xp.spotClear(char, pos, spot) then
                xp.jinkSide = -sgn
                xp.lastBlink = os.clock()
                local look = root.CFrame.LookVector
                setRootCFrame(CFrame.lookAt(spot, spot + Vector3.new(look.X, 0, look.Z)), root)
                root.AssemblyLinearVelocity = Vector3.zero
                xp.path, xp.pathTarget = nil, nil
                return true
            end
        end
    end
    return false
end

function xp.dodgeStep(now, rootPos, humanoid, holdF10)
    local list = xp.hazards
    if #list == 0 then return false end
    xp.blinkDodge(holdF10)
    local serverNow = workspace:GetServerTimeNow()
    for i = #list, 1, -1 do
        if serverNow > list[i].ends then table.remove(list, i) end
    end
    local _, root = getChar()
    local vel = root and root.AssemblyLinearVelocity or Vector3.zero
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    if not xp.danger(rootPos, serverNow, 1.6)
        and not xp.danger(rootPos + flatVel * 0.35, serverNow, 1.6)
        and not xp.danger(rootPos + flatVel * 0.8, serverNow, 1.6) then
        if xp.dodgeTarget and now < xp.dodgeUntil then
            humanoid:MoveTo(xp.dodgeTarget)
            return true
        end
        xp.dodgeTarget = nil
        return false
    end
    local best, bestScore = nil, math.huge
    for _, r in ipairs({ 6, 10, 15, 21 }) do
        for k = 0, 15 do
            local a = k * math.pi / 8
            local spot = rootPos + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
            if xp.allowedSpot(spot, rootPos, holdF10) and not xp.danger(spot, serverNow, 2.5) then
                local score = r
                if score < bestScore then best, bestScore = spot, score end
            end
        end
        if best then break end
    end
    if best then
        xp.dodgeTarget, xp.dodgeUntil = best, now + 0.6
        xp.path, xp.pathTarget = nil, nil
        humanoid:MoveTo(best)
        xp.lastMove = now
    end
    return true
end

function xp.setSprint(on, now)
    if xp.sprinting == on and now - (xp.sprintAt or 0) < 5 then return end
    xp.sprinting, xp.sprintAt = on, now
    local remote = cowRemotes and cowRemotes:FindFirstChild("SprintRequest")
    if remote then pcall(remote.FireServer, remote, on) end
end

function xp.walkTo(target, now, humanoid, root)
    if not humanoid or not root then return end
    xp.setSprint(true, now)
    local here = root.Position
    if not (xp.leaving and xp.exitVia == "gate") and target.Z > here.Z + 4 and xp.level < 10 then
        target = Vector3.new(target.X, target.Y, math.min(target.Z, here.Z + 4))
    end
    if not xp.stuckPos or (here - xp.stuckPos).Magnitude > 2 then
        xp.stuckPos, xp.stuckAt = here, now
    elseif now - xp.stuckAt > 2.5 then
        xp.stuckPos, xp.stuckAt = here, now
        xp.path, xp.pathTarget, xp.pathAt = nil, nil, 0
        xp.nudgeDir = -xp.nudgeDir
        xp.nudgeUntil = now + 1.1
        humanoid.Jump = true
    end
    if now < xp.nudgeUntil then
        local dirVec = target - here
        local side = Vector3.new(-dirVec.Z, 0, dirVec.X)
        side = side.Magnitude > 0.1 and side.Unit or Vector3.new(1, 0, 0)
        humanoid:MoveTo(here + side * (12 * xp.nudgeDir))
        xp.lastMove = now
        return
    end
    if (target - here).Magnitude < 30 then
        xp.path, xp.pathTarget = nil, nil
        if now - xp.lastMove > 0.15 then
            xp.lastMove = now
            humanoid:MoveTo(target)
        end
        return
    end
    if xp.pathTarget and ((xp.pathTarget - target).Magnitude > 14 or now - xp.pathAt > 6) then
        xp.path, xp.pathTarget = nil, nil
    end
    if not xp.path and not xp.pathBusy and now - xp.pathAt > 2 then
        xp.pathBusy, xp.pathAt = true, now
        local from = here
        task.spawn(function()
            local ok, waypoints = pcall(function()
                local p = PathfindingService:CreatePath({ AgentRadius = 2.5, AgentHeight = 5, AgentCanJump = true })
                p:ComputeAsync(from, target)
                if p.Status ~= Enum.PathStatus.Success then return nil end
                return p:GetWaypoints()
            end)
            xp.pathBusy = false
            if ok and waypoints and #waypoints > 1 then
                xp.path, xp.pathTarget, xp.pathIndex = waypoints, target, 2
            end
        end)
    end
    local goal = target
    local path = xp.path
    if path then
        local wp = path[xp.pathIndex]
        while wp and (Vector3.new(wp.Position.X, 0, wp.Position.Z) - Vector3.new(here.X, 0, here.Z)).Magnitude < 3 do
            xp.pathIndex += 1
            wp = path[xp.pathIndex]
        end
        if wp then
            goal = wp.Position
            if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
        else
            xp.path, xp.pathTarget = nil, nil
        end
    end
    if now - xp.lastMove > 0.2 then
        xp.lastMove = now
        humanoid:MoveTo(goal)
    end
end

function xp.stopWalk()
    xp.path, xp.pathTarget = nil, nil
    local _, root, humanoid = getChar()
    if humanoid and root and xp.lastMove > 0 then
        xp.lastMove = 0
        humanoid:MoveTo(root.Position)
    end
end

function xp.prompts(now)
    if now - xp.lastPromptScan < 3 then return end
    xp.lastPromptScan = now
    table.clear(xp.chestPrompts)
    xp.gatePrompt, xp.ferryPrompt = nil, nil
    local arena = xp.arena()
    if not arena then return end
    for _, d in ipairs(arena:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            if d.Name == "OpenHarvestChest" then
                table.insert(xp.chestPrompts, d)
            elseif d.Name == "GateExit" then
                xp.gatePrompt = d
            elseif d.Name == "RiverExit" then
                xp.ferryPrompt = d
            end
        end
    end
end

function xp.promptPos(prompt)
    local holder = prompt and prompt.Parent
    if holder and holder:IsA("BasePart") then return holder.Position end
    if holder and holder:IsA("Attachment") then return holder.WorldPosition end
    if holder and holder:IsA("Model") then return holder:GetPivot().Position end
    return nil
end

function xp.firePrompt(prompt)
    if fireproximityprompt and prompt then
        return (pcall(fireproximityprompt, prompt))
    end
    return false
end

function xp.tryChest(now, rootPos, humanoid, root)
    local hearts = tonumber(plr:GetAttribute("Hearts")) or 0
    local maxHearts = tonumber(plr:GetAttribute("MaxHealth")) or 0
    local needHeal = maxHearts > 0 and hearts < maxHearts - 0.5
    if not needHeal then return false end
    for _, prompt in ipairs(xp.chestPrompts) do
        local owner = prompt:GetAttribute("RaidChestOwner")
        if prompt.Parent and prompt.Enabled and (owner == nil or owner == plr.UserId) then
            local pos = xp.promptPos(prompt)
            local d = pos and (pos - rootPos).Magnitude or math.huge
            if d < 140 and now - (xp.chestTried[prompt] or 0) > 6 then
                if d > math.max(4, prompt.MaxActivationDistance - 2) then
                    xp.walkTo(pos, now, humanoid, root)
                    xp.setStatus("Walking to chest (heal)")
                else
                    xp.stopWalk()
                    xp.chestTried[prompt] = now
                    xp.firePrompt(prompt)
                    xp.setStatus("Opening harvest chest (heal)")
                end
                return true
            end
        end
    end
    return false
end

function xp.exitSpot(via)
    local prompt = via == "ferry" and xp.ferryPrompt or xp.gatePrompt
    local pos = prompt and prompt.Parent and xp.promptPos(prompt)
    if pos then return prompt, pos end
    local planting = xp.planting or xp.PLANTING_FALLBACK
    local center = planting.Frame.Position
    return nil, center + (via == "ferry" and xp.FERRY_REL or xp.GATE_REL)
end

function xp.bank(now, rootPos, humanoid, root)
    local via = xp.exitVia or "ferry"
    if via == "nearest" then
        local _, ferry = xp.exitSpot("ferry")
        local _, gate = xp.exitSpot("gate")
        via = (ferry - rootPos).Magnitude <= (gate - rootPos).Magnitude and "ferry" or "gate"
        xp.exitVia = via
    end
    local prompt, pos = xp.exitSpot(via)
    local label = via == "ferry" and "River ferry" or "Mill gate"
    local d = (pos - rootPos).Magnitude
    if not prompt and now - xp.lastStream > 5 and d < 400 then
        xp.lastStream = now
        task.spawn(function() pcall(function() plr:RequestStreamAroundAsync(pos, 5) end) end)
    end
    if prompt and d <= math.max(4, prompt.MaxActivationDistance - 1.5) then
        xp.stopWalk()
        if now - xp.lastGateFire > 3 then
            xp.lastGateFire = now
            xp.firePrompt(prompt)
            xp.setStatus("Leaving at " .. label)
        end
        return
    end
    xp.walkTo(pos, now, humanoid, root)
    xp.setStatus(string.format("Exiting (%d studs to %s)", math.floor(d), label))
end

function xp.meadow(now, rootPos, humanoid)
    if now - xp.lastMeadowScan > 2 then
        xp.lastMeadowScan = now
        xp.meadowChest, xp.homePrompt = nil, nil
        local cw = workspace:FindFirstChild("CowWorld")
        local dynamic = cw and cw:FindFirstChild("Dynamic")
        if dynamic then
            for _, d in ipairs(dynamic:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Name == "OpenHarvestChest" and d:GetAttribute("RaidChestOwner") == plr.UserId then
                    xp.meadowChest = d
                end
            end
        end
        local arena = xp.arena()
        local landings = arena and arena:FindFirstChild("HarvestLandings")
        if landings then
            for _, d in ipairs(landings:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Name == "HomePrompt" then
                    xp.homePrompt = d
                end
            end
        end
    end
    local chest = xp.meadowChest
    local target, label = nil, nil
    if chest and chest.Parent and chest.Enabled and now - (xp.chestTried[chest] or 0) > 6 then
        target, label = chest, "gold chest"
    elseif xp.homePrompt and xp.homePrompt.Parent and xp.homePrompt.Enabled then
        target, label = xp.homePrompt, "Meadow gate"
    end
    if not target then
        xp.setStatus("Harvest meadow: waiting for prompts")
        return
    end
    local pos = xp.promptPos(target)
    if not pos then return end
    local d = (pos - rootPos).Magnitude
    if d > math.max(4, target.MaxActivationDistance - 2) then
        if humanoid and now - xp.lastMove > 0.25 then
            xp.lastMove = now
            humanoid:MoveTo(pos)
        end
        xp.setStatus("Harvest meadow: walking to " .. label)
        return
    end
    if now - xp.lastMeadowFire > 3 then
        xp.lastMeadowFire = now
        if target == chest then xp.chestTried[chest] = now end
        xp.firePrompt(target)
        xp.setStatus(target == chest and "Opening gold chest" or "Returning to camp (+1,500 XP claimed)")
    end
end

function xp.startRun(now, rootPos, humanoid, root)
    if not xp.autoStart then
        xp.setStatus("Outside raid (auto-start off)")
        return
    end
    if now - xp.returnedAt < 4 then
        xp.setStatus("Back at camp, preparing next outing...")
        return
    end
    local cw = workspace:FindFirstChild("CowWorld")
    local geom = cw and cw:FindFirstChild("Geometry")
    local camp = geom and geom:FindFirstChild("FieldRaids")
    local entry = camp and camp:FindFirstChild("Entry")
    local signup = entry and entry.Value
    if not signup or not signup:IsA("BasePart") then
        xp.setStatus("Go near Field Raid camp to start")
        return
    end
    local d = (signup.Position - rootPos).Magnitude
    if d > 10 then
        if d > 260 then
            xp.setStatus(string.format("Move closer to Field Raid camp (%d studs)", math.floor(d)))
            return
        end
        xp.walkTo(signup.Position, now, humanoid, root)
        xp.setStatus("Walking to raid sign-up")
        return
    end
    xp.stopWalk()
    if now - xp.lastStartTry < 10 then return end
    xp.lastStartTry = now
    xp.startTries += 1
    local prompt = signup:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then xp.firePrompt(prompt) end
    task.delay(0.8, function()
        if xp.running and not plr:GetAttribute("CowFieldRaidId") then
            xp.fireRaid("Solo", 1)
        end
    end)
    xp.setStatus("Starting solo raid (try " .. xp.startTries .. ")")
end

-- Score targets inside Field 10 for maximum XP/sec
function xp.pickF10Target(rootPos, now, nearZ, farZ, allowFarmers)
    local bestPart, bestPos, bestKind, bestLabel, bestScore = nil, nil, nil, nil, -1
    local hasHighPack = false

    -- 1. Secondary foods (GoldenApple = 120 XP in 1 bite)
    for _, part in ipairs(xp.foods) do
        if part.Parent and part:GetAttribute("Available") == true then
            local pz = part.Position.Z
            if pz <= nearZ + 12 and pz >= farZ - 12 then
                local id = part:GetAttribute("NodeId")
                local skipUntil = id and xp.skip[id]
                if id and not (skipUntil and now < skipUntil) then
                    local pt = xp.cellPoint(part, rootPos)
                    local d = (pt - rootPos).Magnitude
                    if xp.isSecondaryFood(part) then
                        local score = 120 / (0.6 + d / 32)
                        if score > bestScore then
                            bestPart, bestPos, bestKind, bestLabel, bestScore = part, pt, "Secondary", xp.speciesOf(part), score
                        end
                    elseif d <= 45 or xp.mode == "Camp F10" then
                        local score = 31 / (0.5 + d / 32)
                        if score > bestScore then
                            bestPart, bestPos, bestKind, bestLabel, bestScore = part, pt, "Wheat", "F10 Wheat", score
                        end
                    end
                end
            end
        end
    end

    -- 2. Field 10 Mobs (Warlock 150/34HP, Archer 75/23HP, Ogre 500/160HP, Farmer 40/14HP, ...)
    for _, part in ipairs(xp.mobs) do
        if xp.mobAlive(part) then
            local pz = part.Position.Z
            if pz <= nearZ + 15 and pz >= farZ - 15 then
                local sp = xp.speciesOf(part)
                if xp.HIGH_PACK[sp] then
                    hasHighPack = true
                end
                if sp ~= "Farmer" or allowFarmers or (part.Position - rootPos).Magnitude <= 28 then
                    local hp = math.max(1, tonumber(part:GetAttribute("Health")) or 20)
                    local kxp = xp.KILL_XP[sp] or 40
                    local d = (part.Position - rootPos).Magnitude
                    local estTime = (hp / 22) + (d / 32)
                    local packBonus = (xp.mode == "Rush & Reset" and xp.HIGH_PACK[sp]) and 1.35 or 1.0
                    local score = (kxp * packBonus) / math.max(0.5, estTime)
                    if score > bestScore then
                        bestPart, bestPos, bestKind, bestLabel, bestScore = part, part.Position, "Mob", sp, score
                    end
                end
            end
        end
    end

    return bestPart, bestPos, bestKind, bestLabel, hasHighPack
end

-- Rush & Reset / Camp F10 inside Field 10
function xp.farmF10(now, rootPos, humanoid, root)
    local nearZ, farZ = xp.bandZ(10)
    if not nearZ or not farZ then
        xp.setStatus("F10: awaiting field bounds")
        return
    end
    local minX, maxX = xp.sweepBounds()
    minX, maxX = minX or (rootPos.X - 180), maxX or (rootPos.X + 180)
    local midZ = (nearZ + farZ) * 0.5

    xp.f10EnteredAt = xp.f10EnteredAt or now
    if rootPos.Z <= midZ + 15 then
        xp.f10VisitedMid = true
    end

    -- Secondary nearby in F9/F10 or in-reach bite
    local allowFarmers = (xp.mode == "Camp F10") or (xp.estActionXP < 550)
    local part, pos, kind, label, hasHighPack = xp.pickF10Target(rootPos, now, nearZ, farZ, allowFarmers)
    if hasHighPack or kind == "Secondary" then
        xp.lastHighSeenAt = now
    end

    -- Rush & Reset exit gate: once we reached mid F10, cleared Ogre/Warlocks/Archers & GoldenApples, and have >= 550 action XP
    if xp.mode == "Rush & Reset"
        and xp.f10VisitedMid
        and (now - xp.f10EnteredAt) >= 4
        and not hasHighPack
        and kind ~= "Secondary"
        and xp.estActionXP >= 550
        and (now - xp.lastHighSeenAt) >= 2.5
    then
        xp.leaving = true
        xp.exitVia = "ferry"
        xp.bank(now, rootPos, humanoid, root)
        return
    end

    if part and pos then
        xp.goalPos = pos
        local d = (pos - rootPos).Magnitude
        local reach = kind == "Mob" and xp.MOB_RANGE or xp.REACH
        if d <= reach then
            xp.sendChomp(part:GetAttribute("NodeId"), part, now, root)
            xp.setStatus(string.format("F10: %s (%d XP est)", label, math.floor(xp.estActionXP)))
            return
        end
        xp.walkTo(Vector3.new(math.clamp(pos.X, minX, maxX), rootPos.Y, math.clamp(pos.Z, farZ + 6, nearZ - 6)), now, humanoid, root)
        xp.setStatus(string.format("F10: %s (%d studs)", label, math.floor(d)))
        return
    end

    -- If waiting to visit mid F10 or patrolling in Camp F10
    xp.goalPos = nil
    if not xp.f10VisitedMid then
        xp.walkTo(Vector3.new(math.clamp(rootPos.X, minX, maxX), rootPos.Y, midZ), now, humanoid, root)
        xp.setStatus("F10: advancing to Ogre / Warlocks")
        return
    end
    local dir = xp.sweepDir or 1
    if (dir > 0 and rootPos.X >= maxX - 20) or (dir < 0 and rootPos.X <= minX + 20) then
        dir = -dir
        xp.sweepDir = dir
    end
    xp.walkTo(Vector3.new(dir > 0 and maxX or minX, rootPos.Y, midZ), now, humanoid, root)
    xp.setStatus(string.format("F10: patrolling (%d XP est)", math.floor(xp.estActionXP)))
end

function xp.tick(now)
    if not xp.running then return end
    if now - xp.lastTick < 0.1 then return end
    local dt = xp.lastTick > 0 and math.min(1, now - xp.lastTick) or 0.1
    xp.lastTick = now
    xp.activeSeconds += dt

    local _, root, humanoid = getChar()
    if not root or not humanoid then return end
    local rootPos = root.Position

    local run = plr:GetAttribute("CowFieldRaidId")
    if not run then
        if xp.run then
            xp.run = nil
            xp.grazeRun = nil
            xp.returnedAt = now
            xp.stopWalk()
            xp.setSprint(false, now)
            xp.resetRunTrackers()
            xp.syncPowerups()
            xp.refreshUI()
        end
        if plr:GetAttribute("CowFieldRaidRewardRoom") then
            xp.meadow(now, rootPos, humanoid)
            return
        end
        xp.startRun(now, rootPos, humanoid, root)
        return
    end

    if xp.run ~= run then
        xp.run = run
        xp.resetRunTrackers()
        xp.startTries = 0
        xp.syncPowerups()
        xp.refreshUI()
    end

    if not xp.planting and now - xp.lastSnapshotAsk > 10 then
        xp.lastSnapshotAsk = now
        xp.fireRaid("Snapshot")
    end

    xp.scan(now)
    xp.prompts(now)

    -- Chest reveal healing pause
    if xp.chestBusy then
        local hearts = tonumber(plr:GetAttribute("Hearts")) or 0
        local maxHearts = tonumber(plr:GetAttribute("MaxHealth")) or 0
        if xp.chestToken and not xp.chestClosed and now - xp.chestOpenedAt > 0.6 and maxHearts > 0 and hearts >= maxHearts then
            xp.chestClosed = true
            xp.fireRaid("CloseChest", xp.chestToken)
        end
        xp.setStatus(string.format("Chest healing: %s/%s hearts", tostring(hearts), tostring(maxHearts)))
        return
    end

    -- Low-HP emergency safe exit (preserve +500 / +1,000 bonuses if no healing chest)
    local hearts = tonumber(plr:GetAttribute("Hearts")) or 0
    local maxHearts = tonumber(plr:GetAttribute("MaxHealth")) or 0
    local holdF10 = xp.level >= 10 and not xp.leaving
    if xp.dodgeStep(now, rootPos, humanoid, holdF10) then
        xp.biteNearby(now, root, rootPos)
        return
    end

    if xp.tryChest(now, rootPos, humanoid, root) then
        return
    end

    if not xp.leaving and maxHearts > 0 and hearts > 0 and (hearts / maxHearts) <= 0.25 and xp.estActionXP >= 500 then
        xp.leaving = true
        xp.exitVia = xp.level >= 9 and "ferry" or "nearest"
    end

    if xp.leaving then
        xp.biteNearby(now, root, rootPos)
        xp.bank(now, rootPos, humanoid, root)
        return
    end

    -- Opportunistic bite while blitzing or farming
    xp.biteNearby(now, root, rootPos)

    if xp.level < 10 then
        -- Opportunistically snatch GoldMushroom / high secondary within 35 studs in F8/F9
        if xp.level >= 8 then
            for _, part in ipairs(xp.foods) do
                if part.Parent and part:GetAttribute("Available") == true and xp.isSecondaryFood(part) then
                    local pt = xp.cellPoint(part, rootPos)
                    local d = (pt - rootPos).Magnitude
                    if d <= 35 and pt.Z <= rootPos.Z + 8 then
                        xp.goalPos = pt
                        xp.walkTo(pt, now, humanoid, root)
                        xp.setStatus(string.format("Blitz F%d->10: detour %s", xp.level, xp.speciesOf(part)))
                        return
                    end
                end
            end
        end
        local nearZ10, farZ10 = xp.bandZ(10)
        local goalZ = nearZ10 and (nearZ10 - 25) or (rootPos.Z - 55)
        if farZ10 then goalZ = math.max(farZ10 + 35, goalZ) end
        xp.goalPos = nil
        xp.walkTo(Vector3.new(rootPos.X, rootPos.Y, math.min(rootPos.Z - 45, goalZ)), now, humanoid, root)
        xp.setStatus(string.format("Blitzing Field %d -> 10", xp.level))
        return
    end

    xp.farmF10(now, rootPos, humanoid, root)
end

-- Server event listeners
do
    local clientEvent = cowRemotes and cowRemotes:FindFirstChild("ClientEvent")
    if clientEvent and clientEvent:IsA("RemoteEvent") then
        table.insert(xp.conns, clientEvent.OnClientEvent:Connect(function(name, msg)
            if xp.destroyed or type(msg) ~= "table" then return end
            if name == "GrazeResult" then
                local p = xp.pending[msg.RequestId]
                if not p or p.NodeId ~= msg.NodeId then return end
                xp.pending[msg.RequestId] = nil
                local now = os.clock()
                xp.rtt = xp.rtt * 0.8 + math.clamp(now - p.SentAt, 0, 2) * 0.2
                local reason = msg.Reason
                if reason == "InvalidActorState" then
                    xp.iasStreak += 1
                    if xp.iasStreak >= 3 then
                        xp.iasStreak = 0
                        xp.blockUntil = now + 1.2
                    end
                else
                    xp.iasStreak = 0
                end
                if msg.Accepted == true or reason == "Consumed" or reason == "Unavailable" then
                    if p.Kind ~= "RaidMob" then
                        xp.skip[p.NodeId] = now + 10
                    end
                elseif reason == "OutOfRange" or reason == "BehindCow" or reason == "OutsideCone" or reason == "Obstructed" then
                    xp.skip[p.NodeId] = now + 0.8
                end
                if msg.Accepted == true then
                    xp.margin = math.max(0.01, xp.margin - 0.002)
                    if p.Kind == "RaidFood" then
                        local lv = math.clamp(tonumber(p.Level) or xp.level, 1, 10)
                        local gain = p.Secondary and (20 + 10 * lv) or (1 + 3 * lv)
                        xp.estActionXP += gain
                        xp.refreshUI()
                    end
                elseif reason == "ChewCooldown" then
                    xp.margin = math.min(0.15, xp.margin + 0.02)
                    xp.lastFire = now
                end
                return
            end

            if name ~= "FieldRaid" then return end
            local kind = msg.Kind
            if kind == "Reset" or kind == "FieldChanged" or kind == "State" then
                if tonumber(msg.Level) then
                    xp.level = tonumber(msg.Level)
                    xp.refreshUI()
                end
                if kind == "Reset" then
                    xp.planting = msg.Planting
                end
                if typeof(msg.BossPosition) == "Vector3" then
                    xp.bossPos = msg.BossPosition
                end
                if tonumber(msg.BossHealth) then
                    xp.bossHealth = tonumber(msg.BossHealth)
                end
            elseif kind == "Windup" or kind == "ProjectileAim" or kind == "BarrageMark" then
                xp.addHazard(msg)
            elseif kind == "CancelWarning" then
                xp.dropHazards(msg.Id)
            elseif kind == "EnemyDefeated" then
                xp.dropHazards(msg.Id)
                local hit = xp.recentMobHits[msg.Id]
                if hit then
                    xp.recentMobHits[msg.Id] = nil
                    xp.estActionXP += (xp.KILL_XP[hit.species] or 40)
                    xp.refreshUI()
                end
            elseif kind == "ChestOpening" then
                xp.chestBusy = true
                xp.chestToken, xp.chestOpenedAt, xp.chestClosed = msg.Token, os.clock(), false
                local untilT = tonumber(msg.Until)
                local secs = untilT and math.clamp(untilT - workspace:GetServerTimeNow(), 1, 90) or 8
                xp.chestUntil = os.clock() + secs
                task.delay(secs, function() xp.chestBusy = false end)
            elseif kind == "ChestOpeningEnded" then
                xp.chestBusy = false
            elseif kind == "Ended" then
                xp.runsDone += 1
                local earned = (tonumber(msg.ActionXP) or 0) + (tonumber(msg.ExitXP) or 0) + (msg.EndXP and 1000 or 0)
                if earned > 0 then
                    xp.sessionXP += earned
                end
                xp.leaving, xp.grazeRun, xp.chestBusy = false, nil, false
                table.clear(xp.hazards)
                xp.syncPowerups()
                xp.refreshUI()
            elseif kind == "Leaving" then
                xp.leaving, xp.grazeRun, xp.chestBusy = false, nil, false
                table.clear(xp.hazards)
            end
        end))
    end
end

-- Compact draggable HUD
function xp.buildUI()
    local playerGui = plr:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("CowFieldRaidXPUI")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "CowFieldRaidXPUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 120
    sg.Parent = playerGui
    xp.gui = sg
    xp.ui.gui = sg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(320, 214)
    frame.Position = UDim2.new(0, 20, 0.5, -107)
    frame.BackgroundColor3 = Color3.fromRGB(28, 31, 38)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(78, 88, 108)
    stroke.Thickness = 1.2

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(39, 44, 54)
    header.BorderSizePixel = 0
    header.Parent = frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(165, 224, 185)
    title.Text = "Field Raid XP Autofarm"
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(92, 46, 46)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Text = "X"
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.Activated:Connect(function() xp.destroy() end)

    local dragging, dragStart, startPos
    table.insert(xp.conns, header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, inp.Position, frame.Position
        end
    end))
    table.insert(xp.conns, UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    table.insert(xp.conns, UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    local function makeLabel(y, size, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 18)
        lbl.Position = UDim2.fromOffset(10, y)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = size
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = color or Color3.fromRGB(220, 224, 232)
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = frame
        return lbl
    end

    xp.ui.fieldLabel = makeLabel(36, 12, Color3.fromRGB(162, 184, 218))
    xp.ui.powerupsLabel = makeLabel(56, 12, Color3.fromRGB(220, 232, 200))
    xp.ui.statsLabel = makeLabel(76, 12, Color3.fromRGB(165, 224, 185))
    xp.ui.statusLabel = makeLabel(102, 12, Color3.fromRGB(250, 214, 134))
    xp.ui.statusLabel.Text = xp.status

    local function makeBtn(x, y, w, text, bg)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(w, 30)
        btn.Position = UDim2.fromOffset(x, y)
        btn.BackgroundColor3 = bg
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
        return btn
    end

    xp.ui.startBtn = makeBtn(10, 134, 145, "Start", Color3.fromRGB(58, 134, 86))
    xp.ui.modeBtn = makeBtn(165, 134, 145, "Mode: Rush & Reset", Color3.fromRGB(62, 82, 118))
    local bankBtn = makeBtn(10, 172, 145, "Bank & Leave", Color3.fromRGB(115, 88, 52))
    local syncBtn = makeBtn(165, 172, 145, "Sync XP", Color3.fromRGB(72, 76, 92))

    xp.ui.startBtn.Activated:Connect(function()
        xp.setRunning(not xp.running)
    end)

    local modes = { "Rush & Reset", "Camp F10" }
    xp.ui.modeBtn.Activated:Connect(function()
        local idx = table.find(modes, xp.mode) or 1
        xp.mode = modes[(idx % #modes) + 1]
        xp.refreshUI()
    end)

    bankBtn.Activated:Connect(function()
        if plr:GetAttribute("CowFieldRaidId") then
            xp.leaving = true
            xp.exitVia = xp.level >= 9 and "ferry" or "nearest"
            xp.setStatus("Manual Bank & Leave")
            if not xp.running then xp.setRunning(true) end
        end
    end)

    syncBtn.Activated:Connect(function()
        xp.syncPowerups()
    end)

    xp.refreshUI()
end

function xp.setRunning(on)
    xp.running = on
    if on then
        local hub = _G.CowHubFieldRaid
        if hub then
            hub.auto = false
            if hub.setFlag then
                for _, flag in ipairs({ "Toggle_FieldRaidAuto", "Toggle_Chomp", "Toggle_MobAura" }) do
                    pcall(hub.setFlag, flag, false)
                end
            end
        end
        if _G.CowMillQuests and _G.CowMillQuests.setRunning and _G.CowMillQuests.running then
            pcall(_G.CowMillQuests.setRunning, false)
        end
        xp.setStatus("Running (" .. xp.mode .. ")")
    else
        xp.stopWalk()
        xp.setSprint(false, os.clock())
        xp.setStatus("Paused")
    end
    xp.refreshUI()
end

function xp.destroy()
    if xp.destroyed then return end
    xp.destroyed = true
    xp.running = false
    xp.stopWalk()
    for _, c in ipairs(xp.conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(xp.conns)
    if xp.gui then
        pcall(function() xp.gui:Destroy() end)
        xp.gui = nil
    end
    if _G.CowFieldRaidXP == xp then
        _G.CowFieldRaidXP = nil
    end
end

_G.CowFieldRaidXP = xp
xp.buildUI()
xp.syncPowerups()

table.insert(xp.conns, RunService.Heartbeat:Connect(function()
    if xp.destroyed or not xp.running then return end
    local ok, err = pcall(xp.tick, os.clock())
    if not ok then
        xp.setStatus("Error: " .. tostring(err))
    end
end))
