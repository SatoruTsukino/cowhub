--[[
    Mill Quests Automator (Standalone) — CowHub
    Automates all 3 North River Field Raid Mill Challenges for the Windmill at Dusk coat:
      1. Harvest ripe wheat in Fields 3, 4 and 5 in one outing.
      2. Take three ripe bites in Field 8 without taking damage between them.
      3. Dodge an Ogre stomp aimed at you, then clear Ogre's Acre (River Ferry + Harvest Meadow).

    Plan: .gsd/milestones/field-raid/phases/2/2.1-PLAN.md
    Safe to re-execute: replaces any previous _G.CowMillQuests instance and pauses _G.CowHubFieldRaid.auto.
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

if _G.CowMillQuests and _G.CowMillQuests.destroy then
    pcall(_G.CowMillQuests.destroy)
end

local cowGame = ReplicatedStorage:WaitForChild("CowGame", 15)
local cowRemotes = cowGame and cowGame:WaitForChild("Remotes", 15)
local cowShared = cowGame and cowGame:WaitForChild("Shared", 15)

local mq = {
    running = false,
    destroyed = false,
    mode = "Auto", -- "Auto" | "C1" | "C2" | "C3"
    autoStart = true,
    status = "Idle (press Start)",

    -- Server challenge state: Profile.FieldRaids.Challenges (bit 1 = C1, bit 2 = C2, bit 4 = C3)
    challengesMask = 0,
    ledgerSynced = false,
    ledgerBusy = false,

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
    lastGateFire = 0,
    lastMeadowFire = 0,
    lastMeadowScan = 0,
    lastStream = 0,
    sprinting = nil,
    sprintAt = 0,

    -- Per-run challenge trackers
    c1Fields = {},       -- [3] = true, [4] = true, [5] = true
    c1Missed = false,    -- passed a needed C1 field without its ripe harvest this outing
    c2Missed = false,    -- passed Field 8 before 3 clean ripe bites this outing
    holdNearZ = nil,     -- while holding a field: its near edge (moving back inside the field is allowed)
    pendingCells = {},   -- [nodeId] = field level: ripe cell bitten, credit once the server removes it
    f8RipeStreak = 0,    -- 0..3 clean ripe bites in Field 8
    c2DoneRun = false,
    stompDodged = false, -- true once an Ogre HarvestStomp windup is dodged unhit
    ogreStomp = nil,     -- { strikeAt, origin, hit }

    -- World & target caches
    mobs = {},
    wheat = {},
    chestPrompts = {},
    chestTried = setmetatable({}, { __mode = "k" }),
    gatePrompt = nil,
    ferryPrompt = nil,
    meadowChest = nil,
    homePrompt = nil,
    bell = nil,          -- { Position, Opens, Closes, Row, Bell }
    -- Ripe bells come 3 per field (Bell = 1..3, ~55-75 s apart) at one spot of that field
    bellSpot = {},       -- [field] = last bell Position
    bellIndex = {},      -- [field] = highest Bell index seen this outing
    holdSince = {},      -- [field] = os.clock() when the cow started holding it
    lastBellAt = 0,      -- os.clock() of the last Bell event
    BELL_TIMEOUT = 150,  -- no bell for this long while holding a field: give it up for the outing
    bossPos = nil,
    bossHealth = 0,

    -- Chest healing state
    chestBusy = false,
    chestUntil = 0,
    chestToken = nil,
    chestOpenedAt = 0,
    chestClosed = false,

    -- Chomp / serial wire state
    serial = 700000,     -- own range: the game and the hub count their chomp serials up from ~0
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
    sweepZ = nil,

    -- Constants from FieldRaidLayout / geometry dump
    FIELD_DEPTHS = { 0, 55, 115, 180, 250, 325, 405, 490, 585, 690, 810.42096 },
    PLANTING_FALLBACK = { Frame = CFrame.new(54.6875, 701.7, 30476.408), Size = Vector3.new(1080.0925, 1, 4052.1047) },
    -- Exit prompts relative to the run's Planting center (arenas are placed at different X per run)
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

function mq.fireRaid(...)
    local remote = mq.raidRemote
    if not remote or not remote.Parent then
        remote = cowRemotes and cowRemotes:FindFirstChild("FieldRaidRequest")
        mq.raidRemote = remote
    end
    if not remote then return false end
    return (pcall(remote.FireServer, remote, ...))
end

function mq.loadMods()
    if not mq.combat and cowShared then
        pcall(function() mq.combat = require(cowShared:FindFirstChild("FieldRaidCombat")) end)
        pcall(function() mq.enemies = require(cowShared:FindFirstChild("FieldRaidEnemies")) end)
    end
    return mq.combat, mq.enemies
end

function mq.isDone(idx)
    return bit32.btest(mq.challengesMask, bit32.lshift(1, idx - 1))
end

function mq.c1Complete()
    return (mq.c1Fields[3] and mq.c1Fields[4] and mq.c1Fields[5]) == true
end

function mq.c2Complete()
    return mq.c2DoneRun or mq.f8RipeStreak >= 3
end

function mq.c3Complete()
    return mq.isDone(3)
end

function mq.activeGoal()
    -- Forced targets stop once the server Ledger marks them done
    if mq.mode == "C1" then return (not mq.isDone(1)) and 1 or nil end
    if mq.mode == "C2" then return (not mq.isDone(2)) and 2 or nil end
    if mq.mode == "C3" then return (not mq.isDone(3)) and 3 or nil end
    -- C1 is lost for this outing once the cow is past a field it still needs (forward only)
    if not mq.isDone(1) and not mq.c1Complete() and not mq.c1Missed then return 1 end
    if not mq.isDone(2) and not mq.c2Complete() and not mq.c2Missed then return 2 end
    if not mq.isDone(3) then return 3 end
    return nil
end

function mq.resetRunTrackers()
    table.clear(mq.c1Fields)
    mq.c1Missed = false
    mq.c2Missed = false
    mq.holdNearZ = nil
    table.clear(mq.pendingCells)
    mq.f8RipeStreak = 0
    mq.c2DoneRun = false
    mq.stompDodged = false
    mq.ogreStomp = nil
    mq.bell = nil
    table.clear(mq.bellSpot)
    table.clear(mq.bellIndex)
    table.clear(mq.holdSince)
    mq.bossPos = nil
    mq.bossHealth = 0
    table.clear(mq.hazards)
    mq.dodgeTarget = nil
    mq.leaving = false
    mq.exitVia = nil
    mq.chestBusy = false
    mq.sweepZ = nil
end

function mq.setStatus(text)
    if mq.status == text then return end
    mq.status = text
    if mq.ui.statusLabel then
        mq.ui.statusLabel.Text = text
    end
end

function mq.refreshUI()
    local u = mq.ui
    if not u.gui or not u.gui.Parent then return end
    if u.startBtn then
        u.startBtn.Text = mq.running and "Stop" or "Start"
        u.startBtn.BackgroundColor3 = mq.running and Color3.fromRGB(165, 62, 54) or Color3.fromRGB(58, 134, 86)
    end
    if u.modeBtn then
        u.modeBtn.Text = "Target: " .. mq.mode
    end
    local function mark(done, extra)
        if done then return "[✓] " else return extra and ("[·] ") or "[ ] " end
    end
    if u.c1Label then
        local prog = string.format("(%s/%s/%s)",
            mq.c1Fields[3] and "3" or "-",
            mq.c1Fields[4] and "4" or "-",
            mq.c1Fields[5] and "5" or "-")
        u.c1Label.Text = mark(mq.isDone(1) or mq.c1Complete()) .. "C1: Ripe F3-4-5 "
            .. (mq.isDone(1) and "(Saved)" or (mq.c1Missed and (prog .. " missed, next outing") or prog))
        u.c1Label.TextColor3 = (mq.isDone(1) or mq.c1Complete()) and Color3.fromRGB(145, 224, 158) or Color3.fromRGB(235, 230, 218)
    end
    if u.c2Label then
        u.c2Label.Text = mark(mq.isDone(2) or mq.c2Complete()) .. "C2: 3x Ripe F8 "
            .. (mq.isDone(2) and "(Saved)" or (string.format("(%d/3)", mq.f8RipeStreak) .. (mq.c2Missed and " missed, next outing" or "")))
        u.c2Label.TextColor3 = (mq.isDone(2) or mq.c2Complete()) and Color3.fromRGB(145, 224, 158) or Color3.fromRGB(235, 230, 218)
    end
    if u.c3Label then
        local st = mq.isDone(3) and "(Saved)" or (mq.stompDodged and "(Stomp dodged! Clear F10)" or "(Bait Ogre + Clear)")
        u.c3Label.Text = mark(mq.isDone(3)) .. "C3: Ogre Stomp " .. st
        u.c3Label.TextColor3 = mq.isDone(3) and Color3.fromRGB(145, 224, 158) or Color3.fromRGB(235, 230, 218)
    end
    if u.fieldLabel then
        local run = plr:GetAttribute("CowFieldRaidId")
        local hp = plr:GetAttribute("Hearts")
        local maxHp = plr:GetAttribute("MaxHealth")
        u.fieldLabel.Text = run
            and string.format("Field %d/10  |  Hearts %s/%s", mq.level, tostring(hp or "?"), tostring(maxHp or "?"))
            or "Outside Raid (Camp)"
    end
end

-- Read the challenge mask from the player snapshot (Remotes.GetSnapshot -> Profile.FieldRaids.Challenges).
-- The "Ledger" request only answers with Leaderboards; Board/Info records still update it passively.
function mq.syncLedger()
    if mq.ledgerBusy then return end
    local fn = cowRemotes and cowRemotes:FindFirstChild("GetSnapshot")
    if not fn or not fn:IsA("RemoteFunction") then return end
    mq.ledgerBusy = true
    task.spawn(function()
        local ok, snap = pcall(fn.InvokeServer, fn)
        mq.ledgerBusy = false
        if mq.destroyed then return end
        local raids = ok and type(snap) == "table" and type(snap.Profile) == "table" and snap.Profile.FieldRaids
        local mask = type(raids) == "table" and tonumber(raids.Challenges)
        if mask then
            mq.challengesMask = mask
            mq.ledgerSynced = true
            mq.refreshUI()
        end
    end)
end

-- Z span of a field level (FieldRaidLayout.Band)
function mq.bandZ(level)
    local planting = mq.planting or mq.PLANTING_FALLBACK
    if type(planting) ~= "table" or typeof(planting.Frame) ~= "CFrame" or typeof(planting.Size) ~= "Vector3" then
        return nil, nil
    end
    level = math.clamp(level, 1, 10)
    local k = planting.Size.Z / mq.FIELD_DEPTHS[11]
    local front = planting.Frame.Position.Z + planting.Size.Z * 0.5
    return front - mq.FIELD_DEPTHS[level] * k, front - mq.FIELD_DEPTHS[level + 1] * k
end

function mq.levelAtZ(z)
    for level = 1, 10 do
        local nearZ, farZ = mq.bandZ(level)
        if nearZ and z <= nearZ and z >= farZ then return level end
    end
    return nil
end

function mq.sweepBounds()
    local planting = mq.planting or mq.PLANTING_FALLBACK
    if type(planting) == "table" and typeof(planting.Frame) == "CFrame" and typeof(planting.Size) == "Vector3" then
        local cx, half = planting.Frame.Position.X, planting.Size.X * 0.5 - 25
        return cx - half, cx + half
    end
    return nil, nil
end

-- Raid arenas are separate models (PrivateFieldRaids, FR<course id>, ...) at different X offsets:
-- the cow's arena is the one (with HarvestLandings) whose pivot is nearest the cow
function mq.arena()
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

function mq.cellPoint(part, pos)
    local cf, half = part.CFrame, part.Size * 0.5
    local lp = cf:PointToObjectSpace(pos)
    return cf:PointToWorldSpace(Vector3.new(
        math.clamp(lp.X, -half.X, half.X), math.clamp(lp.Y, -half.Y, half.Y), math.clamp(lp.Z, -half.Z, half.Z)))
end

function mq.mobAlive(part)
    return part and part.Parent ~= nil and (tonumber(part:GetAttribute("Health")) or 0) > 0
end

function mq.scan(now, force)
    if not force and now - mq.lastScan < 0.2 then return end
    mq.lastScan = now
    table.clear(mq.mobs)
    table.clear(mq.wheat)
    local view = workspace:FindFirstChild("NorthRiverRaidView")
    if not view then return end
    for _, model in ipairs(view:GetChildren()) do
        local part = model:IsA("Model") and model.PrimaryPart
        if part then
            local kind = part:GetAttribute("CowBiteTargetKind")
            if kind == "RaidMob" then
                if mq.mobAlive(part) then
                    mq.mobs[#mq.mobs + 1] = part
                end
            elseif kind == "RaidFood" and part:GetAttribute("Available") == true then
                mq.wheat[#mq.wheat + 1] = part
            end
        end
    end
end

function mq.findOgre()
    local view = workspace:FindFirstChild("NorthRiverRaidView")
    if view then
        for _, model in ipairs(view:GetChildren()) do
            if model:IsA("Model") and (model.Name == "FieldOgre" or string.find(model.Name, "Ogre", 1, true)) then
                local part = model.PrimaryPart
                if mq.mobAlive(part) then
                    return part, part.Position
                end
            end
        end
    end
    for _, part in ipairs(mq.mobs) do
        if mq.mobAlive(part) and (part:GetAttribute("MaxHealth") or 0) >= 120 then
            return part, part.Position
        end
    end
    if mq.bossPos and mq.bossHealth > 0 then
        return nil, mq.bossPos
    end
    return nil, nil
end

function mq.findWheat(rootPos, now, ripeOnly, minZ, maxZ)
    local best, bestDist, bestRipe, bestVal = nil, math.huge, false, 0
    for _, part in ipairs(mq.wheat) do
        if part.Parent and part:GetAttribute("Available") == true then
            local id = part:GetAttribute("NodeId")
            local skipUntil = id and mq.skip[id]
            local pz = part.Position.Z
            local inBand = (not minZ or pz >= minZ) and (not maxZ or pz <= maxZ)
            local ripe = part:GetAttribute("RaidRipe") == true
            if id and inBand and (not ripeOnly or ripe) and not (skipUntil and now < skipUntil) then
                local d = (mq.cellPoint(part, rootPos) - rootPos).Magnitude
                local inReach = d <= mq.REACH
                local val = inReach and (tonumber(part:GetAttribute("BaseCalories")) or 0) or 0
                local better
                if ripe ~= bestRipe then
                    better = ripe
                elseif inReach ~= (bestDist <= mq.REACH) then
                    better = inReach
                elseif val ~= bestVal then
                    better = val > bestVal
                else
                    better = d < bestDist
                end
                if better then
                    best, bestDist, bestRipe, bestVal = part, d, ripe, val
                end
            end
        end
    end
    return best, bestDist
end

function mq.nearestMob(rootPos)
    local best, bestDist = nil, math.huge
    for _, part in ipairs(mq.mobs) do
        if mq.mobAlive(part) then
            local d = (part.Position - rootPos).Magnitude
            if d < bestDist then best, bestDist = part, d end
        end
    end
    return best, bestDist
end

-- Chomp wire matching InputController: ChompRequest:FireServer(nodeId, nil, serial)
function mq.getInterval(node)
    local base = math.clamp(tonumber(plr:GetAttribute("ChewCooldown")) or 0.7, 0.4, 3)
    local mult = math.clamp(tonumber(plr:GetAttribute("CowGrazingSpeedMultiplier")) or 1, 1, 1.236)
    if node and typeof(node) == "Instance" and node:GetAttribute("FoodKind") == "Wheat" then
        base = base * 0.5
    end
    return (base / mult) + mq.margin
end

function mq.ensureGraze()
    local run = plr:GetAttribute("CowFieldRaidId")
    if run and mq.grazeRun ~= run then
        mq.grazeRun = run
        mq.fireRaid("GrazeStart", run)
    end
end

function mq.face(root, pos)
    if not root then return end
    local rp = root.Position
    local dx, dz = pos.X - rp.X, pos.Z - rp.Z
    if dx * dx + dz * dz > 0.01 then
        root.CFrame = CFrame.lookAt(rp, Vector3.new(pos.X, rp.Y, pos.Z))
    end
end

function mq.sendChomp(nodeId, node, now, root)
    if not nodeId or now < mq.blockUntil then return false end
    local interval = mq.getInterval(node)
    if now - mq.lastFire < interval then return false end
    local remote = mq.chompRemote
    if not remote or not remote.Parent then
        remote = cowRemotes and cowRemotes:FindFirstChild("ChompRequest")
        mq.chompRemote = remote
    end
    if not remote then return false end

    mq.ensureGraze()
    if root and node and node.Position then
        mq.face(root, node.Position)
    end

    mq.serial += 1
    local serial = mq.serial
    mq.lastFire = now
    local isRipe = node and typeof(node) == "Instance" and node:GetAttribute("RaidRipe") == true
    mq.pending[serial] = {
        NodeId = nodeId,
        SentAt = now,
        Ripe = isRipe,
        Level = mq.level,
    }
    mq.skip[nodeId] = now + 1.5
    if serial % 32 == 0 then
        for k, p in pairs(mq.pending) do
            if now - p.SentAt > 15 then mq.pending[k] = nil end
        end
        for k, t in pairs(mq.skip) do
            if now >= t then mq.skip[k] = nil end
        end
    end
    pcall(remote.FireServer, remote, nodeId, nil, serial)
    return true
end

function mq.biteNearby(now, root, rootPos)
    local ripePart, rd = mq.findWheat(rootPos, now, true)
    if ripePart and rd <= mq.REACH then
        mq.sendChomp(ripePart:GetAttribute("NodeId"), ripePart, now, root)
        return true
    end
    local mob, md = mq.nearestMob(rootPos)
    if mob and md <= mq.MOB_RANGE then
        mq.sendChomp(mob:GetAttribute("NodeId"), mob, now, root)
        return true
    end
    local wheat, wd = mq.findWheat(rootPos, now, false)
    if wheat and wd <= mq.REACH then
        mq.sendChomp(wheat:GetAttribute("NodeId"), wheat, now, root)
        return true
    end
    return false
end

-- Telegraph danger & blink-dodge (FieldRaidCombat.Contains)
function mq.addHazard(msg)
    local attack = msg.Attack
    if type(attack) ~= "table" or type(attack.StrikeAt) ~= "number" then return end
    local _, enemies = mq.loadMods()
    if not enemies then return end
    local ok, def = pcall(enemies.Move, msg.Species, attack.Move)
    if not ok or type(def) ~= "table" or not def.Shape then return end

    if msg.Species == "FieldOgre" and attack.Move == "HarvestStomp" and not mq.stompDodged then
        local _, r = getChar()
        local origin = attack.Point or attack.Origin
        if r and typeof(origin) == "Vector3" and (r.Position - origin).Magnitude <= (def.Radius or 16) + 2 then
            mq.ogreStomp = {
                strikeAt = attack.StrikeAt,
                origin = origin,
                radius = def.Radius or 16,
                hit = false,
            }
        end
    end

    -- Projectile windup (StrikeAt = release): sidestep just before the shot locks onto the cow
    if def.Projectile and msg.Kind == "Windup" and typeof(msg.Frame) == "CFrame" then
        local _, r = getChar()
        local shooter = msg.Frame.Position
        if r and (r.Position - shooter).Magnitude <= (def.Range or 60) + 10 then
            local lead = attack.StrikeAt - workspace:GetServerTimeNow()
            task.delay(math.max(0, lead - 0.12), function() mq.jink(shooter) end)
        end
    end

    local ends = tonumber(attack.EndsAt) or (attack.StrikeAt + 0.35)
    if def.Shape == "Tripline" then
        ends = math.max(ends, attack.StrikeAt + (def.ActiveSeconds or 1.6))
    end
    local list = mq.hazards
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

    task.defer(mq.blinkDodge)
    local lead = attack.StrikeAt - workspace:GetServerTimeNow()
    if lead > 0.2 then
        task.delay(lead - 0.15, mq.blinkDodge)
    end
end

function mq.dropHazards(id)
    local list = mq.hazards
    for i = #list, 1, -1 do
        if list[i].id == id then table.remove(list, i) end
    end
end

-- Safety margin around the cow: latency and the game's forecast aim land hits 1-2 studs outside the
-- exact shape (hit log: GuardArrow hits at 2.6-2.8 studs from a 2.7-stud circle)
local DANGER_MARGIN = 1.6
local MARGIN_OFFSETS = {
    Vector3.zero, Vector3.new(DANGER_MARGIN, 0, 0), Vector3.new(-DANGER_MARGIN, 0, 0),
    Vector3.new(0, 0, DANGER_MARGIN), Vector3.new(0, 0, -DANGER_MARGIN),
}

-- Flat distance from p to segment a-b
local function segDist(p, a, b)
    local ab = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
    local ap = Vector3.new(p.X - a.X, 0, p.Z - a.Z)
    local len2 = ab:Dot(ab)
    if len2 < 1e-4 then return ap.Magnitude end
    local s = math.clamp(ap:Dot(ab) / len2, 0, 1)
    return (ap - ab * s).Magnitude
end

function mq.danger(pos, serverNow, horizon)
    local combat = mq.combat
    if not combat then return false end
    for _, h in ipairs(mq.hazards) do
        if serverNow <= h.ends and h.strike - serverNow <= horizon then
            local a = h.attack
            if typeof(a.Launch) == "Vector3" and typeof(a.FlightEnd) == "Vector3" then
                -- Aimed projectile: it hits anything along its flight (FieldRaidCombat.ArrowContact)
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


function mq.spotClear(char, from, spot)
    local view = workspace:FindFirstChild("NorthRiverRaidView")
    rayParams.FilterDescendantsInstances = view and { char, view } or { char }
    local up = Vector3.new(0, 2, 0)
    local dir = spot - from
    if workspace:Raycast(from + up, Vector3.new(dir.X, 0, dir.Z), rayParams) then return false end
    local ground = workspace:Raycast(spot + Vector3.new(0, 6, 0), Vector3.new(0, -14, 0), rayParams)
    return ground ~= nil and math.abs(ground.Position.Y - (from.Y - 3)) < 6
end

function mq.allowedSpot(spot, rootPos, holdLevel)
    local minX, maxX = mq.sweepBounds()
    if minX and (spot.X < minX or spot.X > maxX) then return false end
    if holdLevel then
        local nearZ, farZ = mq.bandZ(holdLevel)
        if nearZ and farZ then
            return spot.Z <= nearZ - 4 and spot.Z >= farZ + 4
        end
    end
    if mq.leaving and mq.exitVia == "gate" then return true end
    return spot.Z <= rootPos.Z + 4
end

-- Game hint (FieldRaidCatalog): "Spiders spin low webs in your path. Jump the silk or run around its edge."
function mq.jumpSilk(humanoid, pos, serverNow)
    local combat = mq.combat
    if not combat or not humanoid then return end
    for _, h in ipairs(mq.hazards) do
        if h.def.Shape == "Tripline" and serverNow <= h.ends and h.strike - serverNow <= 0.35 then
            local ok, hit = pcall(combat.Contains, h.def, h.attack, pos, 4)
            if ok and hit then
                humanoid.Jump = true
                return
            end
        end
    end
end

function mq.blinkDodge(holdLevel)
    if not mq.running then return end
    local char, root, humanoid = getChar()
    if not char or not root or not root.Parent or root.Anchored then return end
    mq.jumpSilk(humanoid, root.Position, workspace:GetServerTimeNow())
    if not plr:GetAttribute("CowFieldRaidId") then return end
    local now = os.clock()
    if now - mq.lastBlink < 0.16 then return end
    local serverNow = workspace:GetServerTimeNow()
    local pos = root.Position
    if not mq.danger(pos, serverNow, 1.3) then return end

    local best, bestScore = nil, math.huge
    for _, r in ipairs({ 5, 8, 12, 17, 22, 26 }) do
        for k = 0, 15 do
            local a = k * math.pi / 8
            local spot = pos + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
            if mq.allowedSpot(spot, pos, holdLevel) and not mq.danger(spot, serverNow, 2.5) then
                local score = r + (holdLevel and 0 or (spot.Z - pos.Z) * 0.06)
                if score < bestScore and mq.spotClear(char, pos, spot) then
                    best, bestScore = spot, score
                end
            end
        end
        if best then break end
    end
    if not best then return end
    mq.lastBlink = now
    local look = root.CFrame.LookVector
    setRootCFrame(CFrame.lookAt(best, best + Vector3.new(look.X, 0, look.Z)), root)
    root.AssemblyLinearVelocity = Vector3.zero
    mq.path, mq.pathTarget = nil, nil
end

-- Arrows, stones and boulders aim at the cow's forecast when released and then fly too fast to react to:
-- blink 5-10 studs perpendicular to the shooter right before release, alternating sides
function mq.jink(shooterPos)
    if not mq.running or not plr:GetAttribute("CowFieldRaidId") then return end
    local char, root = getChar()
    if not char or not root or not root.Parent or root.Anchored then return end
    local pos = root.Position
    local toCow = Vector3.new(pos.X - shooterPos.X, 0, pos.Z - shooterPos.Z)
    if toCow.Magnitude < 0.5 then return end
    local side = Vector3.new(-toCow.Z, 0, toCow.X).Unit
    local serverNow = workspace:GetServerTimeNow()
    local holdLevel = (mq.holdLevelNow and mq.level == mq.holdLevelNow) and mq.holdLevelNow or nil
    local first = mq.jinkSide or 1
    for _, dist in ipairs({ 7, 10, 5 }) do
        for _, sgn in ipairs({ first, -first }) do
            local spot = pos + side * (dist * sgn)
            if mq.allowedSpot(spot, pos, holdLevel) and not mq.danger(spot, serverNow, 2.5) and mq.spotClear(char, pos, spot) then
                mq.jinkSide = -sgn
                mq.lastBlink = os.clock()
                local look = root.CFrame.LookVector
                setRootCFrame(CFrame.lookAt(spot, spot + Vector3.new(look.X, 0, look.Z)), root)
                root.AssemblyLinearVelocity = Vector3.zero
                mq.path, mq.pathTarget = nil, nil
                mq.jinks = (mq.jinks or 0) + 1
                return true
            end
        end
    end
    return false
end

function mq.dodgeStep(now, rootPos, humanoid, holdLevel)
    local list = mq.hazards
    if #list == 0 then return false end
    mq.blinkDodge(holdLevel)
    local serverNow = workspace:GetServerTimeNow()
    for i = #list, 1, -1 do
        if serverNow > list[i].ends then table.remove(list, i) end
    end
    local _, root = getChar()
    local vel = root and root.AssemblyLinearVelocity or Vector3.zero
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    if not mq.danger(rootPos, serverNow, 1.6)
        and not mq.danger(rootPos + flatVel * 0.35, serverNow, 1.6)
        and not mq.danger(rootPos + flatVel * 0.8, serverNow, 1.6) then
        if mq.dodgeTarget and now < mq.dodgeUntil then
            humanoid:MoveTo(mq.dodgeTarget)
            return true
        end
        mq.dodgeTarget = nil
        return false
    end
    local best, bestScore = nil, math.huge
    for _, r in ipairs({ 6, 10, 15, 21 }) do
        for k = 0, 15 do
            local a = k * math.pi / 8
            local spot = rootPos + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
            if mq.allowedSpot(spot, rootPos, holdLevel) and not mq.danger(spot, serverNow, 2.5) then
                local score = r
                if score < bestScore then best, bestScore = spot, score end
            end
        end
        if best then break end
    end
    if best then
        mq.dodgeTarget, mq.dodgeUntil = best, now + 0.6
        mq.path, mq.pathTarget = nil, nil
        humanoid:MoveTo(best)
        mq.lastMove = now
    end
    return true
end

function mq.setSprint(on, now)
    if mq.sprinting == on and now - (mq.sprintAt or 0) < 5 then return end
    mq.sprinting, mq.sprintAt = on, now
    local remote = cowRemotes and cowRemotes:FindFirstChild("SprintRequest")
    if remote then pcall(remote.FireServer, remote, on) end
end

function mq.walkTo(target, now, humanoid, root)
    if not humanoid or not root then return end
    mq.setSprint(true, now)
    local here = root.Position
    -- Forward only (fields deepen toward -Z); only the Mill-gate exit may walk back
    local backZ = math.max(here.Z + 4, mq.holdNearZ or -math.huge)
    if not (mq.leaving and mq.exitVia == "gate") and target.Z > backZ then
        target = Vector3.new(target.X, target.Y, math.max(here.Z, math.min(target.Z, backZ)))
    end
    if not mq.stuckPos or (here - mq.stuckPos).Magnitude > 2 then
        mq.stuckPos, mq.stuckAt = here, now
    elseif now - mq.stuckAt > 2.5 then
        mq.stuckPos, mq.stuckAt = here, now
        mq.path, mq.pathTarget, mq.pathAt = nil, nil, 0
        mq.nudgeDir = -mq.nudgeDir
        mq.nudgeUntil = now + 1.1
        humanoid.Jump = true
    end
    if now < mq.nudgeUntil then
        local dirVec = target - here
        local side = Vector3.new(-dirVec.Z, 0, dirVec.X)
        side = side.Magnitude > 0.1 and side.Unit or Vector3.new(1, 0, 0)
        humanoid:MoveTo(here + side * (12 * mq.nudgeDir))
        mq.lastMove = now
        return
    end
    if mq.pathTarget and ((mq.pathTarget - target).Magnitude > 14 or now - mq.pathAt > 6) then
        mq.path, mq.pathTarget = nil, nil
    end
    if not mq.path and not mq.pathBusy and now - mq.pathAt > 2 then
        mq.pathBusy, mq.pathAt = true, now
        local from = here
        task.spawn(function()
            local ok, waypoints = pcall(function()
                local p = PathfindingService:CreatePath({ AgentRadius = 2.5, AgentHeight = 5, AgentCanJump = true })
                p:ComputeAsync(from, target)
                if p.Status ~= Enum.PathStatus.Success then return nil end
                return p:GetWaypoints()
            end)
            mq.pathBusy = false
            if ok and waypoints and #waypoints > 1 then
                mq.path, mq.pathTarget, mq.pathIndex = waypoints, target, 2
            end
        end)
    end
    local goal = target
    local path = mq.path
    if path then
        local wp = path[mq.pathIndex]
        while wp and (Vector3.new(wp.Position.X, 0, wp.Position.Z) - Vector3.new(here.X, 0, here.Z)).Magnitude < 3 do
            mq.pathIndex += 1
            wp = path[mq.pathIndex]
        end
        if wp then
            goal = wp.Position
            if not (mq.leaving and mq.exitVia == "gate") and goal.Z > backZ then
                goal = Vector3.new(goal.X, goal.Y, math.max(here.Z, math.min(goal.Z, backZ)))
            end
            if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
        else
            mq.path, mq.pathTarget = nil, nil
        end
    end
    if now - mq.lastMove > 0.2 then
        mq.lastMove = now
        humanoid:MoveTo(goal)
    end
end

function mq.stopWalk()
    mq.path, mq.pathTarget = nil, nil
    local _, root, humanoid = getChar()
    if humanoid and root and mq.lastMove > 0 then
        mq.lastMove = 0
        humanoid:MoveTo(root.Position)
    end
end

function mq.prompts(now)
    if now - mq.lastPromptScan < 3 then return end
    mq.lastPromptScan = now
    table.clear(mq.chestPrompts)
    mq.gatePrompt, mq.ferryPrompt = nil, nil
    local arena = mq.arena()
    if not arena then return end
    for _, d in ipairs(arena:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            if d.Name == "OpenHarvestChest" then
                table.insert(mq.chestPrompts, d)
            elseif d.Name == "GateExit" then
                mq.gatePrompt = d
            elseif d.Name == "RiverExit" then
                mq.ferryPrompt = d
            end
        end
    end
end

function mq.promptPos(prompt)
    local holder = prompt and prompt.Parent
    if holder and holder:IsA("BasePart") then return holder.Position end
    if holder and holder:IsA("Attachment") then return holder.WorldPosition end
    if holder and holder:IsA("Model") then return holder:GetPivot().Position end
    return nil
end

function mq.firePrompt(prompt)
    if fireproximityprompt and prompt then
        return (pcall(fireproximityprompt, prompt))
    end
    return false
end

function mq.tryChest(now, rootPos, humanoid, root)
    local hearts = tonumber(plr:GetAttribute("Hearts")) or 0
    local maxHearts = tonumber(plr:GetAttribute("MaxHealth")) or 0
    local needHeal = maxHearts > 0 and hearts < maxHearts - 0.5
    for _, prompt in ipairs(mq.chestPrompts) do
        local owner = prompt:GetAttribute("RaidChestOwner")
        if prompt.Parent and prompt.Enabled and (owner == nil or owner == plr.UserId) then
            local pos = mq.promptPos(prompt)
            local d = pos and (pos - rootPos).Magnitude or math.huge
            local maxRange = needHeal and 160 or 65
            if d < maxRange and now - (mq.chestTried[prompt] or 0) > 6 then
                if d > math.max(4, prompt.MaxActivationDistance - 2) then
                    mq.walkTo(pos, now, humanoid, root)
                    mq.setStatus("Walking to harvest chest (heal)")
                else
                    mq.stopWalk()
                    mq.chestTried[prompt] = now
                    mq.firePrompt(prompt)
                    mq.setStatus("Opening harvest chest")
                end
                return true
            end
        end
    end
    return false
end

function mq.exitSpot(via)
    local prompt = via == "ferry" and mq.ferryPrompt or mq.gatePrompt
    local pos = prompt and prompt.Parent and mq.promptPos(prompt)
    if pos then return prompt, pos end
    local planting = mq.planting or mq.PLANTING_FALLBACK
    local center = planting.Frame.Position
    return nil, center + (via == "ferry" and mq.FERRY_REL or mq.GATE_REL)
end

function mq.bank(now, rootPos, humanoid, root)
    local via = mq.exitVia or "ferry"
    if via == "nearest" then
        local _, ferry = mq.exitSpot("ferry")
        local _, gate = mq.exitSpot("gate")
        via = (ferry - rootPos).Magnitude <= (gate - rootPos).Magnitude and "ferry" or "gate"
        mq.exitVia = via
    end
    local prompt, pos = mq.exitSpot(via)
    local label = via == "ferry" and "River ferry" or "Mill gate"
    local d = (pos - rootPos).Magnitude
    if not prompt and now - mq.lastStream > 5 and d < 400 then
        mq.lastStream = now
        task.spawn(function() pcall(function() plr:RequestStreamAroundAsync(pos, 5) end) end)
    end
    if prompt and d <= math.max(4, prompt.MaxActivationDistance - 1.5) then
        mq.stopWalk()
        if now - mq.lastGateFire > 3 then
            mq.lastGateFire = now
            mq.firePrompt(prompt)
            mq.setStatus("Leaving at " .. label)
        end
        return
    end
    mq.walkTo(pos, now, humanoid, root)
    mq.setStatus(string.format("Exiting (%d studs to %s)", math.floor(d), label))
end

function mq.meadow(now, rootPos, humanoid)
    if now - mq.lastMeadowScan > 2 then
        mq.lastMeadowScan = now
        mq.meadowChest, mq.homePrompt = nil, nil
        local cw = workspace:FindFirstChild("CowWorld")
        local dynamic = cw and cw:FindFirstChild("Dynamic")
        if dynamic then
            for _, d in ipairs(dynamic:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Name == "OpenHarvestChest" and d:GetAttribute("RaidChestOwner") == plr.UserId then
                    mq.meadowChest = d
                end
            end
        end
        local arena = mq.arena()
        local landings = arena and arena:FindFirstChild("HarvestLandings")
        if landings then
            for _, d in ipairs(landings:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Name == "HomePrompt" then
                    mq.homePrompt = d
                end
            end
        end
    end
    local chest = mq.meadowChest
    local target, label = nil, nil
    if chest and chest.Parent and chest.Enabled and now - (mq.chestTried[chest] or 0) > 6 then
        target, label = chest, "gold chest"
    elseif mq.homePrompt and mq.homePrompt.Parent and mq.homePrompt.Enabled then
        target, label = mq.homePrompt, "Meadow gate"
    end
    if not target then
        mq.setStatus("Harvest meadow: waiting for prompts")
        return
    end
    local pos = mq.promptPos(target)
    if not pos then return end
    local d = (pos - rootPos).Magnitude
    if d > math.max(4, target.MaxActivationDistance - 2) then
        if humanoid and now - mq.lastMove > 0.25 then
            mq.lastMove = now
            humanoid:MoveTo(pos)
        end
        mq.setStatus("Harvest meadow: walking to " .. label)
        return
    end
    if now - mq.lastMeadowFire > 3 then
        mq.lastMeadowFire = now
        if target == chest then mq.chestTried[chest] = now end
        mq.firePrompt(target)
        mq.setStatus(target == chest and "Opening gold chest" or "Returning to town (Ogre's Acre cleared!)")
    end
end

function mq.startRun(now, rootPos, humanoid, root)
    if not mq.autoStart then
        mq.setStatus("Outside raid (auto-start off)")
        return
    end
    if now - mq.returnedAt < 5 then
        mq.setStatus("Back at camp, preparing next outing...")
        return
    end
    local cw = workspace:FindFirstChild("CowWorld")
    local geom = cw and cw:FindFirstChild("Geometry")
    local camp = geom and geom:FindFirstChild("FieldRaids")
    local entry = camp and camp:FindFirstChild("Entry")
    local signup = entry and entry.Value
    if not signup or not signup:IsA("BasePart") then
        mq.setStatus("Go near Field Raid camp to start")
        return
    end
    local d = (signup.Position - rootPos).Magnitude
    if d > 10 then
        if d > 260 then
            mq.setStatus(string.format("Move closer to Field Raid camp (%d studs)", math.floor(d)))
            return
        end
        mq.walkTo(signup.Position, now, humanoid, root)
        mq.setStatus("Walking to raid sign-up")
        return
    end
    mq.stopWalk()
    if now - mq.lastStartTry < 12 then return end
    mq.lastStartTry = now
    mq.startTries += 1
    local prompt = signup:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then mq.firePrompt(prompt) end
    task.delay(0.8, function()
        if mq.running and not plr:GetAttribute("CowFieldRaidId") then
            mq.fireRaid("Solo", 1)
        end
    end)
    mq.setStatus("Starting solo raid (try " .. mq.startTries .. ")")
end

-- Hold safely inside `targetLevel` and hunt ripe wheat (Bell or RaidRipe wheat cells)
function mq.huntRipeInField(now, rootPos, humanoid, root, targetLevel, statusPrefix)
    local nearZ, farZ = mq.bandZ(targetLevel)
    if not nearZ or not farZ then
        mq.setStatus(statusPrefix .. ": awaiting field bounds")
        return
    end
    local safeNearZ = nearZ - 10
    local safeFarZ = farZ + 10
    local minX, maxX = mq.sweepBounds()
    minX, maxX = minX or (rootPos.X - 180), maxX or (rootPos.X + 180)
    local midZ = (safeNearZ + safeFarZ) * 0.5

    -- Forward only: step into the band from behind; never walk back once past it
    if rootPos.Z > safeNearZ then
        mq.walkTo(Vector3.new(math.clamp(rootPos.X, minX, maxX), rootPos.Y, safeNearZ - 8), now, humanoid, root)
        mq.setStatus(statusPrefix .. ": entering Field " .. targetLevel)
        return
    end
    if rootPos.Z < farZ then
        -- Past the field: this challenge is lost for the outing; the next goal takes over
        if targetLevel == 8 then mq.c2Missed = true else mq.c1Missed = true end
        mq.refreshUI()
        mq.setStatus(statusPrefix .. ": past Field " .. targetLevel .. ", moving on")
        return
    end
    -- Inside the field the cow may move back toward its near edge (it never leaves the field backwards)
    mq.holdNearZ = safeNearZ

    -- 1) Live RaidRipe wheat cell inside this field band
    local ripePart, ripeDist = mq.findWheat(rootPos, now, true, farZ, nearZ)
    if ripePart then
        if ripeDist <= mq.REACH then
            mq.sendChomp(ripePart:GetAttribute("NodeId"), ripePart, now, root)
            mq.setStatus(statusPrefix .. ": biting ripe wheat!")
            return
        end
        local tp = ripePart.Position
        mq.walkTo(Vector3.new(math.clamp(tp.X, minX, maxX), rootPos.Y, math.clamp(tp.Z, safeFarZ, safeNearZ)), now, humanoid, root)
        mq.setStatus(string.format("%s: rushing ripe wheat (%d studs)", statusPrefix, math.floor(ripeDist)))
        return
    end

    -- 2) Announced Bell (ripening or open) inside this field band
    local serverNow = workspace:GetServerTimeNow()
    local bell = mq.bell
    if bell and typeof(bell.Position) == "Vector3" and serverNow < (bell.Closes or 0) then
        local bz = bell.Position.Z
        if bz <= nearZ + 4 and bz >= farZ - 4 then
            local bx = math.clamp(bell.Position.X, minX, maxX)
            local bzc = math.clamp(bz, safeFarZ, safeNearZ)
            local targetPos = Vector3.new(bx, rootPos.Y, bzc)
            local dist = (targetPos - rootPos).Magnitude
            if dist > 8 then
                mq.walkTo(targetPos, now, humanoid, root)
            else
                -- Orbit at ~6 studs so mobs don't lock telegraphs onto a stationary cow while waiting for Opens
                mq.orbitAngle = (mq.orbitAngle + 0.35) % (math.pi * 2)
                local orbitPos = Vector3.new(
                    math.clamp(bx + math.cos(mq.orbitAngle) * 6, minX, maxX),
                    rootPos.Y,
                    math.clamp(bzc + math.sin(mq.orbitAngle) * 6, safeFarZ, safeNearZ)
                )
                mq.walkTo(orbitPos, now, humanoid, root)
            end
            local waitSecs = math.max(0, math.ceil((bell.Opens or serverNow) - serverNow))
            mq.setStatus(waitSecs > 0
                and string.format("%s: waiting at bell (%ds)", statusPrefix, waitSecs)
                or (statusPrefix .. ": scanning bell patch"))
            return
        end
    end

    -- 3) Bells are spent after the third one (or none rang for BELL_TIMEOUT): lost for the outing
    mq.holdSince[targetLevel] = mq.holdSince[targetLevel] or now
    local quiet = now - math.max(mq.holdSince[targetLevel], mq.lastBellAt) > mq.BELL_TIMEOUT
    if (mq.bellIndex[targetLevel] or 0) >= 3 or quiet then
        if targetLevel == 8 then mq.c2Missed = true else mq.c1Missed = true end
        mq.refreshUI()
        mq.setStatus(statusPrefix .. ": F" .. targetLevel .. " bells spent, next outing")
        return
    end

    -- 4) The next bell rings near the last one: circle that spot (moving, so aim never settles)
    local spot = mq.bellSpot[targetLevel]
    if spot then
        mq.orbitAngle = (mq.orbitAngle + 0.25) % (math.pi * 2)
        local cx = math.clamp(spot.X, minX + 12, maxX - 12)
        local cz = math.clamp(spot.Z, safeFarZ + 12, safeNearZ - 12)
        mq.walkTo(Vector3.new(cx + math.cos(mq.orbitAngle) * 12, rootPos.Y, cz + math.sin(mq.orbitAngle) * 12), now, humanoid, root)
        mq.setStatus(string.format("%s: circling F%d bell spot (bell %d/3)", statusPrefix, targetLevel, mq.bellIndex[targetLevel] or 0))
        return
    end

    -- 5) No bell yet in this field: patrol laterally along midZ
    local dir = mq.sweepDir or 1
    if (dir > 0 and rootPos.X >= maxX - 15) or (dir < 0 and rootPos.X <= minX + 15) then
        dir = -dir
        mq.sweepDir = dir
    end
    local goalX = dir > 0 and maxX or minX
    mq.walkTo(Vector3.new(goalX, rootPos.Y, midZ), now, humanoid, root)
    mq.setStatus(statusPrefix .. ": waiting for ripe bell in F" .. targetLevel)
end

-- Challenge 3: Bait FieldOgre HarvestStomp in F10, blink-dodge outside 16 studs, then clear via RiverExit
function mq.runChallenge3(now, rootPos, humanoid, root)
    -- Confirm stomp dodge once StrikeAt + 0.25s has elapsed without getting hurt by it
    if mq.ogreStomp and not mq.stompDodged then
        local serverNow = workspace:GetServerTimeNow()
        if serverNow > mq.ogreStomp.strikeAt + 0.25 then
            local dist = (rootPos - mq.ogreStomp.origin).Magnitude
            if not mq.ogreStomp.hit and dist > (mq.ogreStomp.radius or 16) then
                mq.stompDodged = true
                mq.ogreStomp = nil
                mq.refreshUI()
            else
                -- Missed/got hit or stayed inside: reset to bait the next stomp
                mq.ogreStomp = nil
            end
        end
    end

    if mq.stompDodged then
        mq.leaving = true
        mq.exitVia = "ferry"
        mq.bank(now, rootPos, humanoid, root)
        return
    end

    local _, ogrePos = mq.findOgre()
    if not ogrePos then
        -- Sweep deep into Field 10 until the Ogre loads/appears
        local nearZ, farZ = mq.bandZ(10)
        local targetZ = farZ and (farZ + 40) or (rootPos.Z - 60)
        mq.walkTo(Vector3.new(rootPos.X, rootPos.Y, targetZ), now, humanoid, root)
        mq.setStatus("C3: Searching for Field Ogre in F10")
        return
    end

    local d = (ogrePos - rootPos).Magnitude
    if mq.ogreStomp then
        -- Stomp windup is active: move outside 19 studs from its origin
        local away = rootPos - mq.ogreStomp.origin
        local dir = Vector3.new(away.X, 0, away.Z)
        dir = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, -1)
        mq.walkTo(mq.ogreStomp.origin + dir * 20, now, humanoid, root)
        mq.setStatus("C3: Dodging Ogre stomp!")
    elseif d > 13 then
        mq.walkTo(ogrePos, now, humanoid, root)
        mq.setStatus(string.format("C3: Approaching Ogre (%d studs) to bait stomp", math.floor(d)))
    else
        -- Circle around the Ogre at ~10 studs so its stomp triggers while avoiding boulder/charge lines
        mq.orbitAngle = (mq.orbitAngle + 0.3) % (math.pi * 2)
        local orbitPos = ogrePos + Vector3.new(math.cos(mq.orbitAngle) * 10, 0, math.sin(mq.orbitAngle) * 10)
        mq.walkTo(orbitPos, now, humanoid, root)
        mq.setStatus("C3: Baiting Ogre HarvestStomp...")
    end
end

function mq.tick(now)
    if not mq.running then return end
    if now - mq.lastTick < 0.1 then return end
    mq.lastTick = now

    local _, root, humanoid = getChar()
    if not root or not humanoid then return end
    local rootPos = root.Position

    local run = plr:GetAttribute("CowFieldRaidId")
    if not run then
        if mq.run then
            mq.run = nil
            mq.grazeRun = nil
            mq.returnedAt = now
            mq.stopWalk()
            mq.setSprint(false, now)
            mq.resetRunTrackers()
            mq.syncLedger()
            mq.refreshUI()
        end
        if plr:GetAttribute("CowFieldRaidRewardRoom") then
            mq.meadow(now, rootPos, humanoid)
            return
        end
        local goal = mq.activeGoal()
        if not goal then
            mq.running = false
            mq.setStatus("All selected Mill Challenges complete!")
            mq.refreshUI()
            return
        end
        mq.startRun(now, rootPos, humanoid, root)
        return
    end

    if mq.run ~= run then
        mq.run = run
        mq.resetRunTrackers()
        mq.startTries = 0
        mq.syncLedger()
        mq.refreshUI()
    end

    if not mq.planting and now - mq.lastSnapshotAsk > 10 then
        mq.lastSnapshotAsk = now
        mq.fireRaid("Snapshot")
    end

    mq.scan(now)
    mq.prompts(now)

    -- Chest reveal healing pause
    if mq.chestBusy then
        local hearts = tonumber(plr:GetAttribute("Hearts")) or 0
        local maxHearts = tonumber(plr:GetAttribute("MaxHealth")) or 0
        if mq.chestToken and not mq.chestClosed and now - mq.chestOpenedAt > 0.6 and maxHearts > 0 and hearts >= maxHearts then
            mq.chestClosed = true
            mq.fireRaid("CloseChest", mq.chestToken)
        end
        mq.setStatus(string.format("Chest healing: %s/%s hearts", tostring(hearts), tostring(maxHearts)))
        return
    end

    mq.holdNearZ = nil
    -- Determine active objective for this run
    local goal = mq.activeGoal()
    if not goal then
        mq.leaving = true
        mq.exitVia = mq.exitVia or "nearest"
        mq.biteNearby(now, root, rootPos)
        mq.bank(now, rootPos, humanoid, root)
        return
    end

    -- Figure out which field we should hold in (if any)
    local holdLevel = nil
    if goal == 1 then
        if not mq.c1Fields[3] then
            holdLevel = 3
        elseif not mq.c1Fields[4] then
            holdLevel = 4
        elseif not mq.c1Fields[5] then
            holdLevel = 5
        end
    elseif goal == 2 then
        holdLevel = 8
    elseif goal == 3 then
        holdLevel = 10
    end

    -- Always dodge telegraphs first; bite on the move
    mq.holdLevelNow = holdLevel
    local dodgeClamp = (holdLevel and mq.level == holdLevel) and holdLevel or nil
    if mq.dodgeStep(now, rootPos, humanoid, dodgeClamp) then
        mq.biteNearby(now, root, rootPos)
        return
    end

    -- Take chest if hurt or if a chest is adjacent
    if mq.tryChest(now, rootPos, humanoid, root) then
        return
    end

    if mq.leaving then
        mq.biteNearby(now, root, rootPos)
        mq.bank(now, rootPos, humanoid, root)
        return
    end

    mq.biteNearby(now, root, rootPos)

    -- Advance toward target level
    if holdLevel and mq.level < holdLevel then
        local _, farZ = mq.bandZ(holdLevel)
        local goalZ = farZ and (farZ + 35) or (rootPos.Z - 45)
        mq.walkTo(Vector3.new(rootPos.X, rootPos.Y, math.min(rootPos.Z - 40, goalZ)), now, humanoid, root)
        mq.setStatus(string.format("Pushing F%d -> F%d (Goal: C%d)", mq.level, holdLevel, goal))
        return
    end

    -- Execute field-specific challenge routine
    if goal == 1 then
        if mq.c1Complete() then
            -- If C2/C3 still needed in Auto mode, next tick picks them; otherwise bank safely
            if mq.mode == "C1" or (mq.isDone(2) and mq.isDone(3)) then
                mq.leaving, mq.exitVia = true, "nearest"
                mq.bank(now, rootPos, humanoid, root)
            end
            return
        end
        mq.huntRipeInField(now, rootPos, humanoid, root, holdLevel, "C1")
    elseif goal == 2 then
        if mq.c2Complete() then
            if mq.mode == "C2" or mq.isDone(3) then
                mq.leaving, mq.exitVia = true, "nearest"
                mq.bank(now, rootPos, humanoid, root)
            end
            return
        end
        mq.huntRipeInField(now, rootPos, humanoid, root, 8, string.format("C2 [%d/3]", mq.f8RipeStreak))
    elseif goal == 3 then
        mq.runChallenge3(now, rootPos, humanoid, root)
    end
end

-- Server event listeners
do
    local clientEvent = cowRemotes and cowRemotes:FindFirstChild("ClientEvent")
    if clientEvent and clientEvent:IsA("RemoteEvent") then
        table.insert(mq.conns, clientEvent.OnClientEvent:Connect(function(name, msg)
            if mq.destroyed or type(msg) ~= "table" then return end
            if name == "GrazeResult" then
                local p = mq.pending[msg.RequestId]
                if not p or p.NodeId ~= msg.NodeId then return end
                mq.pending[msg.RequestId] = nil
                local now = os.clock()
                mq.rtt = mq.rtt * 0.8 + math.clamp(now - p.SentAt, 0, 2) * 0.2
                local reason = msg.Reason
                if reason == "InvalidActorState" then
                    mq.iasStreak += 1
                    if mq.iasStreak >= 3 then
                        mq.iasStreak = 0
                        mq.blockUntil = now + 1.2
                    end
                else
                    mq.iasStreak = 0
                end
                if msg.Accepted == true or reason == "Consumed" or reason == "Unavailable" then
                    mq.skip[p.NodeId] = now + 10
                elseif reason == "OutOfRange" or reason == "BehindCow" or reason == "OutsideCone" or reason == "Obstructed" then
                    mq.skip[p.NodeId] = now + 0.8
                end
                if msg.Accepted == true then
                    mq.margin = math.max(0.01, mq.margin - 0.002)
                    if p.Ripe then
                        -- Field from the cell id (<run>_F<level>_<n>): FieldChanged flaps at field borders
                        local lv = tonumber(string.match(tostring(p.NodeId), "_F(%d+)_")) or tonumber(p.Level) or mq.level
                        if lv == 3 or lv == 4 or lv == 5 then
                            -- "Harvest": credit when the cell is gone (Consumed reply or Remove event), not a partial bite
                            if reason == "Consumed" then
                                mq.c1Fields[lv] = true
                            else
                                mq.pendingCells[p.NodeId] = lv
                            end
                        elseif lv == 8 then
                            mq.f8RipeStreak += 1
                            if mq.f8RipeStreak >= 3 then
                                mq.c2DoneRun = true
                            end
                        end
                        mq.refreshUI()
                    end
                elseif reason == "ChewCooldown" then
                    mq.margin = math.min(0.15, mq.margin + 0.02)
                    mq.lastFire = now
                end
                return
            end

            if name ~= "FieldRaid" then return end
            local kind = msg.Kind
            if type(msg.Record) == "table" and type(msg.Record.Challenges) == "number" then
                mq.challengesMask = msg.Record.Challenges
                mq.ledgerSynced = true
                mq.refreshUI()
            end
            if kind == "Reset" or kind == "FieldChanged" or kind == "State" then
                if tonumber(msg.Level) then
                    mq.level = tonumber(msg.Level)
                    mq.refreshUI()
                end
                if kind == "Reset" then
                    mq.planting = msg.Planting
                    mq.sweepZ = nil
                end
                if typeof(msg.BossPosition) == "Vector3" then
                    mq.bossPos = msg.BossPosition
                end
                if tonumber(msg.BossHealth) then
                    mq.bossHealth = tonumber(msg.BossHealth)
                end
            elseif kind == "Bell" then
                mq.bell = msg
                mq.lastBellAt = os.clock()
                local lv = typeof(msg.Position) == "Vector3" and mq.levelAtZ(msg.Position.Z)
                if lv then
                    mq.bellSpot[lv] = msg.Position
                    mq.bellIndex[lv] = math.max(mq.bellIndex[lv] or 0, tonumber(msg.Bell) or 0)
                end
            elseif kind == "Windup" or kind == "ProjectileAim" or kind == "BarrageMark" then
                mq.addHazard(msg)
            elseif kind == "CancelWarning" or kind == "EnemyDefeated" then
                mq.dropHazards(msg.Id)
            elseif kind == "Remove" then
                local lv = mq.pendingCells[msg.Id]
                if lv then
                    mq.pendingCells[msg.Id] = nil
                    mq.c1Fields[lv] = true
                    mq.refreshUI()
                end
            elseif kind == "Hurt" then
                if type(msg.Result) == "table" and msg.Result.Applied == true then
                    if mq.f8RipeStreak > 0 and not mq.c2DoneRun then
                        mq.f8RipeStreak = 0
                        mq.refreshUI()
                    end
                    if mq.ogreStomp then
                        mq.ogreStomp.hit = true
                    end
                end
            elseif kind == "ChestOpening" then
                mq.chestBusy = true
                mq.chestToken, mq.chestOpenedAt, mq.chestClosed = msg.Token, os.clock(), false
                local untilT = tonumber(msg.Until)
                local secs = untilT and math.clamp(untilT - workspace:GetServerTimeNow(), 1, 90) or 8
                mq.chestUntil = os.clock() + secs
                task.delay(secs, function() mq.chestBusy = false end)
            elseif kind == "ChestOpeningEnded" then
                mq.chestBusy = false
            elseif kind == "Ended" or kind == "Leaving" then
                mq.leaving, mq.grazeRun, mq.chestBusy = false, nil, false
                table.clear(mq.hazards)
            end
        end))
    end
end

-- Backup damage check via Hearts attribute drop in Field 8
table.insert(mq.conns, plr:GetAttributeChangedSignal("Hearts"):Connect(function()
    local cur = tonumber(plr:GetAttribute("Hearts"))
    local prev = mq.lastHearts
    mq.lastHearts = cur
    if cur and prev and cur < prev - 0.01 then
        if mq.level == 8 and mq.f8RipeStreak > 0 and not mq.c2DoneRun then
            mq.f8RipeStreak = 0
            mq.refreshUI()
        end
        if mq.ogreStomp then
            mq.ogreStomp.hit = true
        end
    end
end))
mq.lastHearts = tonumber(plr:GetAttribute("Hearts"))

-- Build compact draggable UI
function mq.buildUI()
    local playerGui = plr:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("CowMillQuestsUI")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "CowMillQuestsUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 120
    sg.Parent = playerGui
    mq.gui = sg
    mq.ui.gui = sg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(310, 224)
    frame.Position = UDim2.new(0, 20, 0.5, -112)
    frame.BackgroundColor3 = Color3.fromRGB(28, 31, 38)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(78, 88, 108)
    stroke.Thickness = 1.2

    -- Dragging on header
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
    title.TextColor3 = Color3.fromRGB(245, 226, 179)
    title.Text = "Mill Quests Automator"
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
    closeBtn.Activated:Connect(function() mq.destroy() end)

    local dragging, dragStart, startPos
    table.insert(mq.conns, header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, inp.Position, frame.Position
        end
    end))
    table.insert(mq.conns, UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    table.insert(mq.conns, UserInputService.InputEnded:Connect(function(inp)
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

    mq.ui.fieldLabel = makeLabel(36, 12, Color3.fromRGB(162, 184, 218))
    mq.ui.c1Label = makeLabel(56, 12)
    mq.ui.c2Label = makeLabel(76, 12)
    mq.ui.c3Label = makeLabel(96, 12)
    mq.ui.statusLabel = makeLabel(120, 12, Color3.fromRGB(250, 214, 134))
    mq.ui.statusLabel.Text = mq.status

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

    mq.ui.startBtn = makeBtn(10, 146, 140, "Start", Color3.fromRGB(58, 134, 86))
    mq.ui.modeBtn = makeBtn(160, 146, 140, "Target: Auto", Color3.fromRGB(62, 82, 118))
    local bankBtn = makeBtn(10, 184, 140, "Bank & Leave", Color3.fromRGB(115, 88, 52))
    local syncBtn = makeBtn(160, 184, 140, "Sync Progress", Color3.fromRGB(72, 76, 92))

    mq.ui.startBtn.Activated:Connect(function()
        mq.setRunning(not mq.running)
    end)

    local modes = { "Auto", "C1", "C2", "C3" }
    mq.ui.modeBtn.Activated:Connect(function()
        local idx = table.find(modes, mq.mode) or 1
        mq.mode = modes[(idx % #modes) + 1]
        mq.refreshUI()
    end)

    bankBtn.Activated:Connect(function()
        if plr:GetAttribute("CowFieldRaidId") then
            mq.leaving, mq.exitVia = true, "nearest"
            mq.setStatus("Manual Bank & Leave")
            if not mq.running then mq.setRunning(true) end
        end
    end)

    syncBtn.Activated:Connect(function()
        mq.syncLedger()
    end)

    mq.refreshUI()
end

function mq.setRunning(on)
    mq.running = on
    if on then
        -- The hub's raid autofarm, Auto-Chomp and Mob Aura bite the same targets on the shared chew
        -- cooldown: switch them off while this runs
        local hub = _G.CowHubFieldRaid
        if hub then
            hub.auto = false
            if hub.setFlag then
                for _, flag in ipairs({ "Toggle_FieldRaidAuto", "Toggle_Chomp", "Toggle_MobAura" }) do
                    pcall(hub.setFlag, flag, false)
                end
            end
        end
        mq.setStatus("Running (" .. mq.mode .. ")")
    else
        mq.stopWalk()
        mq.setSprint(false, os.clock())
        mq.setStatus("Paused")
    end
    mq.refreshUI()
end

function mq.destroy()
    if mq.destroyed then return end
    mq.destroyed = true
    mq.running = false
    mq.stopWalk()
    for _, c in ipairs(mq.conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(mq.conns)
    if mq.gui then
        pcall(function() mq.gui:Destroy() end)
        mq.gui = nil
    end
    if _G.CowMillQuests == mq then
        _G.CowMillQuests = nil
    end
end

_G.CowMillQuests = mq
mq.buildUI()
mq.syncLedger()

table.insert(mq.conns, RunService.Heartbeat:Connect(function()
    if mq.destroyed or not mq.running then return end
    local ok, err = pcall(mq.tick, os.clock())
    if not ok then
        mq.setStatus("Error: " .. tostring(err))
    end
end))
