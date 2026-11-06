--[[
    Caravan Autofarm (standalone prototype) — CowHub
    Scares the caravan guide, kicks crates, grazes barrels, closes the crate reveal,
    then returns you to where you stood. Debug probe logs caravan traffic to
    cowhub/caravanlogs/ to confirm remote payloads before hub integration.
    Plan: .gsd/milestones/caravan-autofarm/phases/1/1.1-PLAN.md
    Run with the hub autofarm OFF (both move the character).
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

-- One instance at a time: re-executing replaces the old one
if _G.CowCaravanAutofarm and _G.CowCaravanAutofarm.destroy then
    pcall(_G.CowCaravanAutofarm.destroy)
end

local CONFIG = {
    FOLDER = "cowhub/caravanlogs",
    LOOP_DT = 0.1,
    MOO_INTERVAL = 1.6,       -- client cooldown 1.5 s; server bucket 2 cap / 0.667 per s
    KICK_INTERVAL = 0.4,      -- server bucket 4 cap / 3 per s
    KICK_KEEP = 0.4,          -- InputController:_updateKickHold sends "Keep" every 0.4 s
    KICK_HOLD_CONFIRM = 1,    -- hold dropped if CowKickHolding isn't set after 1 s
    KICK_HOLD_MAX = 8,        -- give up on one crate after this long
    KICK_RETRY = 1.5,         -- back off after a dropped hold
    BITE_SPACING = 0.15,      -- server bucket 8 cap / 8 per s
    BITE_COOLDOWN_PAD = 0.05,
    GUIDE_OFFSET = 3,         -- CloseRadius is 4 (+2 per moo)
    TARGET_OFFSET = 3,
    TARGET_SCAN = 0.25,
    FEAR_LOG_INTERVAL = 5,
    FLUSH_INTERVAL = 1,
    TREE_DEPTH = 3,
    REVEAL_RETRY = 1,
    -- Natural mode (walk, never teleport)
    SCARE_RADIUS = 14,        -- Intimidation.Radius is 15
    ACT_REACH = 6,            -- only kick / bite once this close (flat studs)
    PATH_DIRECT = 30,         -- closer than this: plain MoveTo; further: PathfindingService
    PATH_RECOMPUTE = 2,
    PATH_GOAL_SHIFT = 12,
    WAYPOINT_REACH = 3,
    SPRINT_FAR = 14,
    INTERCEPT_SPEED = 18,     -- assumed cow speed when leading a far caravan
    INTERCEPT_MAX = 250,
    RETURN_TIMEOUT = 90,
    -- Grumpy Moo (replaces Stomp): fall back to plain Moo if the server won't credit it
    GRUMPY_MISSES = 3,
    GRUMPY_UNANSWERED = 4,
}

local BLOCK_ATTRS = { "CowBotCheckActive", "CowBotQuarantined", "CowCaptured", "CowStunned", "CowMoofCutscene", "CatapultActive" }
local CARAVAN_KINDS = {
    Started = true, FrightSoon = true, Stopped = true, Escaped = true, PackedUp = true,
    Fright = true, FrightMissed = true, Loot = true, CrateOpened = true, Crate = true,
}
local WATCH_OUT = { MooRequest = true, KickRequest = true, CosmeticRequest = true, ChompRequest = true }
local NUM_ATTRS = { "EventId", "StartAt", "EndsAt", "Speed", "StopDistance", "StoppedAt", "LootEndsAt", "GoneAt", "LeftAt", "Fear", "FearAt" }

local cowGame = ReplicatedStorage:WaitForChild("CowGame")
local remotes = cowGame:WaitForChild("Remotes")
local shared = cowGame:WaitForChild("Shared")

local function sharedModule(name)
    local m = shared:FindFirstChild(name)
    if not m then return nil end
    local ok, res = pcall(require, m)
    return ok and res or nil
end

local CaravanConfig = sharedModule("CaravanConfig")
local CaravanRules = sharedModule("CaravanRules")
local CaravanRoute = sharedModule("CaravanRoute")

local VirtualInput = nil
pcall(function() VirtualInput = game:GetService("VirtualInputManager") end)

local S = {
    running = true,
    farm = false,
    lootOnly = false,
    debug = false,
    natural = false,
    useGrumpy = true,
    grumpyState = "unknown",  -- unknown / ok / rejected
    grumpyMisses = 0,
    grumpyUnanswered = 0,
    lastMooStyle = nil,
    eventsSeen = 0,
    hold = nil,               -- { part, since, lastKeep } while a held kick is active
    kickBackoff = 0,
    walk = { waypoints = nil, idx = 0, goal = nil, computedAt = 0, lastGoal = nil, lastMoveAt = 0, failures = 0 },
    sprinting = false,
    returningSince = nil,
    conns = {},
    probeConns = {},
    folder = nil,
    folderConn = nil,
    snap = nil,
    lastPhase = nil,
    lastEventId = nil,
    routes = {},
    savedCF = nil,
    lastMoo = 0,
    lastKick = 0,
    lastBite = 0,
    lastReveal = 0,
    lastFearLog = 0,
    lastScan = 0,
    kickId = 100000,          -- above the game's own counter in case the server wants increasing RequestIds
    serial = 0,
    barrelNext = {},
    crates = {},
    barrels = {},
    status = "Idle",
    stats = { caravans = 0, stopped = 0, moos = 0, kicks = 0, bites = 0, opened = 0, kickOk = 0, kickBad = 0, loot = 0, frights = 0, missed = 0, skins = 0 },
    logFile = nil,
    pending = {},
    lastFlush = 0,
    hookInstalled = false,
    originalNamecall = nil,
}
_G.CowCaravanAutofarm = S

----------------------------------------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------------------------------------

local function serverNow()
    return Workspace:GetServerTimeNow()
end

local function getRoot()
    local c = plr.Character
    if not c then return nil end
    local r = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
    if r and r:IsA("BasePart") then return r end
    return nil
end

local function setRoot(cf)
    local r = getRoot()
    if not r then return false end
    return (pcall(function()
        r.CFrame = cf
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end))
end

local function flatDist(a, b)
    return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

-- Point `offset` studs from pos on the side we are already on
local function standPoint(pos, offset)
    local r = getRoot()
    if not r then return nil end
    local away = r.Position - pos
    away = Vector3.new(away.X, 0, away.Z)
    if away.Magnitude < 0.1 then away = Vector3.xAxis end
    return pos + away.Unit * offset
end

-- Teleport there, facing pos
local function standAt(pos, offset)
    local stand = standPoint(pos, offset)
    if not stand then return false end
    return setRoot(CFrame.lookAt(stand, Vector3.new(pos.X, stand.Y, pos.Z)))
end

local function blocked()
    local c = plr.Character
    for _, a in ipairs(BLOCK_ATTRS) do
        if plr:GetAttribute(a) == true or (c and c:GetAttribute(a) == true) then
            return a
        end
    end
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return "dead" end
    return nil
end

local function decode(s)
    if type(s) ~= "string" or s == "" then return nil end
    local ok, res = pcall(HttpService.JSONDecode, HttpService, s)
    return ok and res or nil
end

----------------------------------------------------------------------------------------------------
-- Log (JSONL, only while Debug Log is on)
----------------------------------------------------------------------------------------------------

local function sanitize(v, depth)
    local t = typeof(v)
    if t == "nil" or t == "boolean" or t == "string" then return v end
    if t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return tostring(v) end
        return v
    end
    if t == "Instance" then
        local ok, n = pcall(v.GetFullName, v)
        return ok and n or tostring(v)
    end
    if t == "table" then
        if depth <= 0 then return "<table>" end
        local out, n = {}, 0
        for k, x in pairs(v) do
            n += 1
            if n > 64 then out["_truncated"] = true; break end
            out[tostring(k)] = sanitize(x, depth - 1)
        end
        return out
    end
    return tostring(v)
end

local function openLog()
    if S.logFile or not writefile then return end
    pcall(function()
        if makefolder then
            if not (isfolder and isfolder("cowhub")) then pcall(makefolder, "cowhub") end
            if not (isfolder and isfolder(CONFIG.FOLDER)) then pcall(makefolder, CONFIG.FOLDER) end
        end
        local name = CONFIG.FOLDER .. "/caravan_" .. os.date("%Y%m%d_%H%M%S") .. ".jsonl"
        writefile(name, "")
        S.logFile = name
    end)
end

local function log(kind, data)
    if not S.debug then return end
    openLog()
    if not S.logFile then return end
    local ok, line = pcall(HttpService.JSONEncode, HttpService, {
        t = math.floor(serverNow() * 1000) / 1000,
        k = kind,
        d = sanitize(data, 5),
    })
    if ok then table.insert(S.pending, line) end
end

local function flushLog(force)
    if not S.logFile or #S.pending == 0 then return end
    local now = os.clock()
    if not force and now - S.lastFlush < CONFIG.FLUSH_INTERVAL then return end
    S.lastFlush = now
    local chunk = table.concat(S.pending, "\n") .. "\n"
    table.clear(S.pending)
    pcall(function()
        if appendfile then
            appendfile(S.logFile, chunk)
        else
            writefile(S.logFile, (readfile and readfile(S.logFile) or "") .. chunk)
        end
    end)
end

local function dumpTree(inst, depth, out)
    out = out or {}
    if not inst or #out > 400 then return out end
    local attrs = inst:GetAttributes()
    table.insert(out, {
        path = inst:GetFullName(),
        class = inst.ClassName,
        attrs = next(attrs) and attrs or nil,
    })
    if depth > 0 then
        for _, ch in ipairs(inst:GetChildren()) do
            dumpTree(ch, depth - 1, out)
        end
    end
    return out
end

----------------------------------------------------------------------------------------------------
-- Caravan state (ReplicatedStorage.CowGame.CaravanState attributes)
----------------------------------------------------------------------------------------------------

local function readState()
    local f = S.folder
    if not f or not f.Parent then return nil end
    local st = {
        Phase = f:GetAttribute("Phase"),
        Kind = f:GetAttribute("Kind") or "Supply",
        Route = f:GetAttribute("Route"),
        LeaveReason = f:GetAttribute("LeaveReason"),
        Barrels = decode(f:GetAttribute("Barrels")) or {},
        Crates = decode(f:GetAttribute("Crates")) or {},
        Layout = decode(f:GetAttribute("Layout")),
    }
    for _, k in ipairs(NUM_ATTRS) do
        local v = f:GetAttribute(k)
        st[k] = type(v) == "number" and v or nil
    end
    local kind = CaravanConfig and CaravanConfig.Kind and CaravanConfig.Kind(st.Kind)
    st.Goal = (kind and kind.GuideGoal) or 1000
    st.Active = (st.Phase == "OnRoad" or st.Phase == "Stopped") and st.EventId ~= nil
    return st
end

local function bindFolder(f)
    if S.folder == f or not (f and f:IsA("Folder")) then return end
    if S.folderConn then S.folderConn:Disconnect() end
    S.folder = f
    S.folderConn = f.AttributeChanged:Connect(function(attr)
        if attr == "Phase" or attr == "EventId" then
            log("attr", { name = attr, value = f:GetAttribute(attr) })
        end
    end)
end

-- Same math the client uses to place the convoy (CaravanController:_distance / _pose)
local function routePose(st, lead)
    if not (CaravanRules and CaravanRoute and type(st.Route) == "string") then return nil end
    local route = S.routes[st.Route]
    if not route then
        local ok, built = pcall(CaravanRoute.Build, st.Route)
        if not ok then return nil end
        route = built
        S.routes[st.Route] = route
    end
    local dist
    if st.Phase == "OnRoad" and st.StartAt and st.Speed then
        dist = CaravanRules.Travelled(route, st.StartAt, st.Speed, serverNow())
    else
        dist = st.StopDistance or 0
    end
    local ok, cf = pcall(CaravanRules.Pose, route, dist + (lead or 0))
    return ok and cf or nil
end

local function guidePart()
    local convoy = Workspace:FindFirstChild("CaravanConvoy")
    local guide = convoy and convoy:FindFirstChild("CaravanGuide", true)
    local hrp = guide and guide:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp end
    return nil
end

local function guidePos(st)
    local hrp = guidePart()
    if hrp then return hrp.Position, "model" end
    local cf = routePose(st)
    if cf then return cf.Position, "route" end
    return nil, "none"
end

-- Open targets as CaravanController exposes them to the local player
local function scanTargets()
    local barrels, crates = {}, {}
    for _, p in ipairs(CollectionService:GetTagged("CowBiteTarget")) do
        if p:IsA("BasePart") and p:GetAttribute("CowBiteTargetKind") == "CaravanBarrel"
            and p:GetAttribute("Available") == true
            and (tonumber(p:GetAttribute("PortionsRemaining")) or 0) > 0 then
            table.insert(barrels, p)
        end
    end
    local convoy = Workspace:FindFirstChild("CaravanConvoy")
    if convoy then
        for _, d in ipairs(convoy:GetDescendants()) do
            if d:IsA("BillboardGui") and d.Name == "CrateKickPrompt" and d.Enabled
                and d.Adornee and d.Adornee:IsA("BasePart") then
                table.insert(crates, d.Adornee)
            end
        end
    end
    S.barrels, S.crates = barrels, crates
end

----------------------------------------------------------------------------------------------------
-- Probe: incoming caravan events + outgoing requests
----------------------------------------------------------------------------------------------------

-- The caravan payload may not be the first arg (Aura/FjordStorm HandleEvent take (name, payload))
local function caravanPayload(...)
    for i = 1, select("#", ...) do
        local a = select(i, ...)
        if type(a) == "table" and CARAVAN_KINDS[a.Kind] then return a end
    end
    return nil
end

local function kickResult(...)
    for i = 1, select("#", ...) do
        local a = select(i, ...)
        if type(a) == "table" and type(a.RequestId) == "number" and a.Ok ~= nil then return a end
    end
    return nil
end

local function watchIncoming(rem)
    if not (rem:IsA("RemoteEvent") or rem:IsA("UnreliableRemoteEvent")) then return end
    table.insert(S.probeConns, rem.OnClientEvent:Connect(function(...)
        local a = caravanPayload(...)
        if not a then
            local kr = kickResult(...)
            if kr and kr.RequestId >= 100000 then
                if kr.Ok == true then S.stats.kickOk += 1 else S.stats.kickBad += 1 end
                log("kick_result", { remote = rem:GetFullName(), args = { ... } })
            end
            return
        end
        S.eventsSeen += 1
        local mine = tostring(a.ActorId) == tostring(plr.UserId)
        if a.Kind == "Fright" and mine then
            S.stats.frights += 1
            S.grumpyUnanswered = 0
            if a.Action == "GrumpyMoo" then
                S.grumpyState, S.grumpyMisses = "ok", 0
            elseif a.Action == "Moo" and S.lastMooStyle == "GrumpyMoo" and S.grumpyState == "unknown" then
                S.grumpyMisses += 1
                if S.grumpyMisses >= CONFIG.GRUMPY_MISSES then
                    S.grumpyState = "rejected"
                    log("grumpy_rejected", { why = "credited_as_moo" })
                end
            end
        end
        if a.Kind == "FrightMissed" then
            S.stats.missed += 1
            S.grumpyUnanswered = 0
        end
        if a.Kind == "CrateOpened" and mine then S.stats.opened += 1 end
        if a.Kind == "Loot" then S.stats.loot += 1 end
        if a.Kind == "Crate" then S.stats.skins += 1 end
        log("in", { remote = rem:GetFullName(), mine = mine, args = { ... } })
    end))
end

-- Incoming listeners always run (they feed the stats); log() itself is gated by Debug Log
local function listenIncoming()
    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do watchIncoming(rem) end
    table.insert(S.probeConns, ReplicatedStorage.DescendantAdded:Connect(watchIncoming))
end

-- Outgoing hook is installed on first Debug Log enable; the handler passes through while debug is off
local function startProbe()
    if S.hookInstalled or not (hookmetamethod and getnamecallmethod) then return end
    S.hookInstalled = true
    local original
    local handler = function(self, ...)
        if S.debug and getnamecallmethod() == "FireServer" and typeof(self) == "Instance"
            and self.Parent == remotes and WATCH_OUT[self.Name] then
            local a = ...
            if self.Name ~= "ChompRequest" or (type(a) == "string" and string.match(a, "^Caravan")) then
                log("out", {
                    remote = self.Name,
                    ours = checkcaller and checkcaller() or nil,
                    args = { ... },
                })
            end
        end
        return original(self, ...)
    end
    original = hookmetamethod(game, "__namecall", newcclosure and newcclosure(handler) or handler)
    S.originalNamecall = original
end

local function stopProbe()
    flushLog(true)
end

----------------------------------------------------------------------------------------------------
-- Actions (each one rate-gated)
----------------------------------------------------------------------------------------------------

local function fire(name, ...)
    local rem = remotes:FindFirstChild(name)
    if not rem then return false end
    local args = table.pack(...)
    return (pcall(function() rem:FireServer(table.unpack(args, 1, args.n)) end))
end

local function tryMoo(now)
    if now - S.lastMoo < CONFIG.MOO_INTERVAL then return end
    S.lastMoo = now
    local grumpy = S.useGrumpy and S.grumpyState ~= "rejected"
    local ok
    if grumpy then
        ok = fire("MooRequest", "Grumpy") -- CowExpressions.MooStyles.Grumpy (no unlock)
        if S.grumpyState == "unknown" and S.eventsSeen > 0 then
            -- No Fright / FrightMissed reply at all → server dropped the style
            S.grumpyUnanswered += 1
            if S.grumpyUnanswered >= CONFIG.GRUMPY_UNANSWERED then
                S.grumpyState = "rejected"
                log("grumpy_rejected", { why = "no_reply" })
            end
        end
    else
        ok = fire("MooRequest")
    end
    S.lastMooStyle = grumpy and "GrumpyMoo" or "Moo"
    if ok then S.stats.moos += 1 end
end

----------------------------------------------------------------------------------------------------
-- Natural movement: Humanoid walking (MoveTo / PathfindingService), never teleports
----------------------------------------------------------------------------------------------------

local function getHumanoid()
    local c = plr.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function setSprint(on)
    if S.sprinting == on then return end
    S.sprinting = on
    fire("SprintRequest", on)
end

local function stopWalk()
    local h, r = getHumanoid(), getRoot()
    if h and r then pcall(function() h:MoveTo(r.Position) end) end
    S.walk.waypoints = nil
    S.walk.lastGoal = nil
    setSprint(false)
end

-- Walk toward goal; returns flat distance to it. Direct MoveTo when near, path waypoints when far.
local function walkTo(goal, now)
    local h, r = getHumanoid(), getRoot()
    if not (h and r) then return math.huge end
    local w = S.walk
    local d = flatDist(r.Position, goal)
    setSprint(d > CONFIG.SPRINT_FAR)
    if d <= CONFIG.PATH_DIRECT then
        w.waypoints = nil
        if not w.lastGoal or (w.lastGoal - goal).Magnitude > 0.5 or now - w.lastMoveAt > 1 then
            w.lastGoal, w.lastMoveAt = goal, now
            h:MoveTo(goal)
        end
        return d
    end
    if not w.waypoints or now - w.computedAt > CONFIG.PATH_RECOMPUTE
        or (w.goal and (w.goal - goal).Magnitude > CONFIG.PATH_GOAL_SHIFT) then
        w.computedAt, w.goal = now, goal
        local path = PathfindingService:CreatePath({ AgentRadius = 2.5, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 6 })
        local ok = pcall(function() path:ComputeAsync(r.Position, goal) end)
        if ok and path.Status == Enum.PathStatus.Success then
            w.waypoints, w.idx = path:GetWaypoints(), 2
        else
            w.waypoints = nil
            w.failures += 1
            log("path_fail", { from = r.Position, to = goal, status = ok and path.Status or "error" })
        end
    end
    local wps = w.waypoints
    if not wps then
        -- No path: walk straight and let the next recompute try again
        h:MoveTo(goal)
        return d
    end
    local wp = wps[w.idx]
    while wp and w.idx < #wps and flatDist(r.Position, wp.Position) < CONFIG.WAYPOINT_REACH do
        w.idx += 1
        wp = wps[w.idx]
    end
    if wp then
        if wp.Action == Enum.PathWaypointAction.Jump then h.Jump = true end
        h:MoveTo(wp.Position)
    end
    return d
end

-- Get within reach of a part: teleport mode stands there, natural mode walks there
local function approach(part, now)
    if not S.natural then
        local r = getRoot()
        if not r or flatDist(r.Position, part.Position) > CONFIG.ACT_REACH or math.abs(r.Position.Y - part.Position.Y) > 6 then
            standAt(part.Position, CONFIG.TARGET_OFFSET)
        end
        return true
    end
    local goal = standPoint(part.Position, CONFIG.TARGET_OFFSET)
    if not goal then return false end
    walkTo(goal, now)
    local r = getRoot()
    return r ~= nil and flatDist(r.Position, part.Position) <= CONFIG.ACT_REACH
end

local function kickReady(now)
    if (tonumber(plr:GetAttribute("CowUpgrade_HindStrength")) or 0) < 1 then return false, "no_hind_strength" end
    if now - S.lastKick < CONFIG.KICK_INTERVAL then return false, "spacing" end
    local gate = math.max(tonumber(plr:GetAttribute("CowNextKickAt")) or 0, tonumber(plr:GetAttribute("CowKickPendingUntil")) or 0)
    if serverNow() < gate then return false, "server_cooldown" end
    return true
end

-- Matches InputController:_kickAim: Target = the model the aim locked onto (tree, crate, ...),
-- sent on "Hold" only; "Keep" carries just Position + RequestId
local function kickAim(part, withTarget)
    S.kickId = S.kickId % 2147483647 + 1
    local aim = { Position = part.Position, RequestId = S.kickId }
    if withTarget then
        local model = part.Parent
        aim.Target = (model and model:IsA("Model")) and model or part
    end
    return aim
end

local function releaseKick(why)
    if not S.hold then return end
    fire("KickRequest", nil, "Release")
    log("kick_release", { why = why, held = os.clock() - S.hold.since })
    S.hold = nil
end

local function grounded()
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.FloorMaterial ~= Enum.Material.Air and not h.Sit
end

-- Crates say "Hold Kick to open": same wire as InputController:_updateKickHold
-- ("Hold" once, "Keep" every 0.4 s, "Release" at the end)
local function holdKick(part, now)
    local hold = S.hold
    if hold and hold.part ~= part then
        releaseKick("target_changed")
        hold = nil
    end
    if not hold then
        if now < S.kickBackoff then return "backoff" end
        if not grounded() then return "airborne" end
        local ok, why = kickReady(now)
        if not ok then return why end
        S.lastKick = now
        if fire("KickRequest", kickAim(part, true), "Hold") then S.stats.kicks += 1 end
        S.hold = { part = part, since = now, lastKeep = now }
        log("kick_hold", { part = part, id = S.kickId })
        return "hold"
    end
    if now - hold.since > CONFIG.KICK_HOLD_MAX then
        releaseKick("timeout")
        S.kickBackoff = now + CONFIG.KICK_RETRY
        return "timeout"
    end
    if now - hold.lastKeep < CONFIG.KICK_KEEP then return "holding" end
    local c = plr.Character
    if now - hold.since > CONFIG.KICK_HOLD_CONFIRM and not (c and c:GetAttribute("CowKickHolding") == true) then
        releaseKick("not_holding")
        S.kickBackoff = now + CONFIG.KICK_RETRY
        return "dropped"
    end
    if not grounded() then
        releaseKick("airborne")
        return "airborne"
    end
    hold.lastKeep = now
    fire("KickRequest", kickAim(part), "Keep")
    return "holding"
end

local function biteReady(part, now)
    local nodeId = part:GetAttribute("CowBiteTargetId") or part:GetAttribute("NodeId")
    if type(nodeId) ~= "string" then return nil end
    if now < (S.barrelNext[nodeId] or 0) then return nil end
    return nodeId
end

local function tryBite(part, nodeId, now)
    if now - S.lastBite < CONFIG.BITE_SPACING then return end
    S.lastBite = now
    local cd = tonumber(part:GetAttribute("CowBiteCooldown")) or 1
    S.barrelNext[nodeId] = now + cd + CONFIG.BITE_COOLDOWN_PAD
    S.serial += 1
    if fire("ChompRequest", nodeId, nil, S.serial) then S.stats.bites += 1 end
    log("bite", { node = nodeId, serial = S.serial, portions = part:GetAttribute("PortionsRemaining"), cd = cd })
end

local function isDismissButton(b)
    if not (b:IsA("GuiButton") and b.Visible) then return false end
    local name = b.Name:lower()
    local text = b:IsA("TextButton") and b.Text:lower() or ""
    local label = tostring(b:GetAttribute("AccessibilityLabel") or ""):lower()
    local all = name .. " " .. text .. " " .. label
    if all:find("wear") or all:find("equip") or all:find("try on") then return false end
    return all:find("close") or all:find("done") or all:find("keep") or all:find("continue")
        or all:find("okay") or text == "ok" or all:find("not now") or all:find("nice") or all:find("cool")
end

local function activate(b)
    local done = false
    if getconnections then
        for _, sig in ipairs({ b.Activated, b.MouseButton1Click }) do
            pcall(function()
                for _, c in ipairs(getconnections(sig)) do
                    if c.Function then pcall(c.Function); done = true end
                end
            end)
        end
    end
    if not done and firesignal then
        pcall(function() firesignal(b.Activated); done = true end)
    end
    return done
end

local function closeReveal(now)
    if plr:GetAttribute("CowCrateRevealOpen") ~= true then return end
    if now - S.lastReveal < CONFIG.REVEAL_RETRY then return end
    S.lastReveal = now
    local pg = plr:FindFirstChildOfClass("PlayerGui")
    local gui = pg and pg:FindFirstChild("CaravanCrateReveal")
    local buttons = {}
    if gui then
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("GuiButton") then
                table.insert(buttons, { name = d.Name, text = d:IsA("TextButton") and d.Text or nil, visible = d.Visible })
                if isDismissButton(d) and activate(d) then
                    log("reveal_close", { button = d })
                    return
                end
            end
        end
    end
    log("reveal_stuck", { gui = gui, buttons = buttons })
end

----------------------------------------------------------------------------------------------------
-- Farm loop
----------------------------------------------------------------------------------------------------

-- Teleport mode: snap back. Natural mode: stop walking here (step() walks back while the farm is on).
local function restore()
    releaseKick("restore")
    if S.natural then
        stopWalk()
    elseif S.savedCF then
        setRoot(S.savedCF)
        log("restore", { cf = S.savedCF })
    end
    S.savedCF, S.returningSince = nil, nil
end

-- Natural mode: walk along the road beside the guide. When far, aim at an intercept
-- point ahead on the caravan route instead of chasing the wagon from behind.
local function scareGoal(st, gp)
    local r = getRoot()
    local far = r and flatDist(r.Position, gp) or 0
    local lead = 1
    if far > CONFIG.PATH_DIRECT and st.Speed then
        lead = math.min(CONFIG.INTERCEPT_MAX, st.Speed * far / CONFIG.INTERCEPT_SPEED)
    end
    local cf = routePose(st, lead)
    if not cf then return gp end
    if lead > 1 then return cf.Position end
    -- Beside the guide (right of travel), slightly ahead so we keep pace
    return gp + cf.RightVector * CONFIG.GUIDE_OFFSET + cf.LookVector
end

local function onPhase(st, prev)
    log("phase", { from = prev, to = st and st.Phase, state = st })
    if st and st.Phase == "OnRoad" and prev ~= "OnRoad" then
        S.stats.caravans += 1
        table.clear(S.barrelNext)
    end
    if st and st.Phase == "Stopped" then S.stats.stopped += 1 end
    if S.debug and st and (st.Phase == "OnRoad" or st.Phase == "Stopped") then
        task.delay(2, function()
            log("convoy_tree", { phase = st.Phase, tree = dumpTree(Workspace:FindFirstChild("CaravanConvoy"), CONFIG.TREE_DEPTH) })
        end)
    end
end

local function scareStep(st, now)
    local pos, src = guidePos(st)
    if not pos then
        S.status = "OnRoad: guide not found"
        return
    end
    local r = getRoot()
    if S.natural then
        walkTo(scareGoal(st, pos), now)
        if r and flatDist(r.Position, pos) <= CONFIG.SCARE_RADIUS then tryMoo(now) end
    else
        standAt(pos, CONFIG.GUIDE_OFFSET)
        tryMoo(now)
    end
    S.status = string.format("Scaring (%s%s) · fear %d/%d · %s",
        src, S.natural and ", walking" or "", math.floor(st.Fear or 0), st.Goal,
        r and string.format("%.0f studs", flatDist(r.Position, pos)) or "?")
    if now - S.lastFearLog >= CONFIG.FEAR_LOG_INTERVAL then
        S.lastFearLog = now
        log("fear", { fear = st.Fear, goal = st.Goal, src = src, dist = r and (r.Position - pos).Magnitude })
    end
end

local function lootStep(st, now)
    if now - S.lastScan >= CONFIG.TARGET_SCAN then
        S.lastScan = now
        scanTargets()
    end
    local crate = S.crates[1]
    if crate and crate.Parent then
        local why = approach(crate, now) and holdKick(crate, now) or "walking"
        -- Without HindStrength we can't kick: fall through and graze
        if why ~= "no_hind_strength" then
            S.status = string.format("Kicking crates · %d left · %s", #S.crates, why)
            return
        end
    end
    releaseKick("no_crate")
    local best, bestId
    local soonest, soonPart = math.huge, nil
    for _, b in ipairs(S.barrels) do
        if b.Parent then
            local id = biteReady(b, now)
            if id then best, bestId = b, id; break end
            local nodeId = b:GetAttribute("CowBiteTargetId")
            local t = S.barrelNext[nodeId] or 0
            if t < soonest then soonest, soonPart = t, b end
        end
    end
    local target = best or soonPart
    if not target then
        S.status = "Looted · waiting for caravan to leave"
        return
    end
    if approach(target, now) and best then tryBite(best, bestId, now) end
    local left = math.max(0, math.floor((st.LootEndsAt or 0) - serverNow()))
    S.status = string.format("Grazing barrels · %d left · %ds", #S.barrels, left)
end

local function step(now)
    if not S.folder or not S.folder.Parent then
        bindFolder(cowGame:FindFirstChild("CaravanState"))
    end
    local st = readState()
    S.snap = st
    local phase = st and st.Phase
    local eventId = st and st.EventId
    if phase ~= S.lastPhase or eventId ~= S.lastEventId then
        local prev = S.lastPhase
        S.lastPhase, S.lastEventId = phase, eventId
        onPhase(st, prev)
    end

    if not S.farm then
        S.status = st and st.Active and ("Caravan " .. tostring(phase) .. " · farm off") or "Idle · farm off"
        return
    end
    closeReveal(now)
    if not (st and st.Active) then
        if S.natural and S.savedCF then
            S.returningSince = S.returningSince or now
            local d = walkTo(S.savedCF.Position, now)
            if d <= 4 or now - S.returningSince > CONFIG.RETURN_TIMEOUT then
                log("returned", { dist = d, secs = now - S.returningSince })
                restore()
            else
                S.status = string.format("Walking back · %.0f studs", d)
            end
            return
        end
        restore()
        S.status = "Waiting for caravan"
        return
    end
    S.returningSince = nil
    local why = blocked()
    if why then
        releaseKick("blocked")
        if S.natural then stopWalk() end
        S.status = "Paused: " .. why
        return
    end
    if not S.savedCF then
        local r = getRoot()
        S.savedCF = r and r.CFrame
    end
    if phase == "OnRoad" then
        if S.lootOnly then
            S.status = "OnRoad · loot only, waiting"
        else
            scareStep(st, now)
        end
    elseif phase == "Stopped" then
        lootStep(st, now)
    end
end

----------------------------------------------------------------------------------------------------
-- UI
----------------------------------------------------------------------------------------------------

local Rayfield = _G.CowHubRayfield
if not Rayfield then
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
    end)
    if ok then Rayfield = res end
end

local Window, statusCard
local function setCard(title, body)
    if not statusCard then return end
    pcall(function()
        if statusCard.SetTitle then
            statusCard:SetTitle(title)
            statusCard:Set(body)
        elseif statusCard.Set then
            statusCard:Set({ Title = title, Content = body })
        end
    end)
end

local function destroy()
    S.running = false
    S.farm = false
    restore()
    stopProbe()
    for _, c in ipairs(S.probeConns) do pcall(function() c:Disconnect() end) end
    table.clear(S.probeConns)
    if S.folderConn then S.folderConn:Disconnect() end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    if S.originalNamecall and hookmetamethod then
        pcall(hookmetamethod, game, "__namecall", S.originalNamecall)
        S.originalNamecall = nil
    end
    if Window and Window.Destroy then pcall(function() Window:Destroy() end) end
    if _G.CowCaravanAutofarm == S then _G.CowCaravanAutofarm = nil end
end
S.destroy = destroy

if Rayfield and Rayfield.CreateWindow then
    pcall(function()
        Window = Rayfield:CreateWindow({
            Name = "Caravan Autofarm",
            Subtitle = "Prototype — CowHub",
            showIconOnly = false,
            theme = "frost",
            configuration = { enabled = true, folder = "cowhub", file = "CaravanAutofarmConfig" },
        })
    end)
end

if Window then
    local tab = Window:CreateTab({ Name = "Caravan", Icon = 4483362458 })
    tab:CreateSection({ Name = "Caravan Autofarm" })
    tab:CreateToggle({
        Name = "Caravan Autofarm",
        CurrentValue = false,
        Flag = "Toggle_CaravanFarm",
        Callback = function(v)
            S.farm = v == true
            if not S.farm then restore() end
        end,
    })
    tab:CreateToggle({
        Name = "Natural Mode (walk the caravan path)",
        CurrentValue = false,
        Flag = "Toggle_CaravanNatural",
        Callback = function(v)
            local on = v == true
            if on ~= S.natural then
                if on then S.savedCF = nil else stopWalk() end
            end
            S.natural = on
        end,
    })
    tab:CreateToggle({
        Name = "Grumpy Moo (replaces Stomp)",
        CurrentValue = true,
        Flag = "Toggle_CaravanGrumpy",
        Callback = function(v)
            S.useGrumpy = v == true
            if S.useGrumpy then S.grumpyState, S.grumpyMisses, S.grumpyUnanswered = "unknown", 0, 0 end
        end,
    })
    tab:CreateToggle({
        Name = "Loot Only (skip scaring)",
        CurrentValue = false,
        Flag = "Toggle_CaravanLootOnly",
        Callback = function(v) S.lootOnly = v == true end,
    })
    tab:CreateToggle({
        Name = "Caravan Debug Log",
        CurrentValue = false,
        Flag = "Toggle_CaravanDebug",
        Callback = function(v)
            S.debug = v == true
            if S.debug then
                startProbe()
                task.spawn(function()
                    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
                        if d:IsA("ModuleScript") and d.Name == "CowExpressions" then
                            local ok, m = pcall(require, d)
                            log("expressions", {
                                path = d,
                                grumpyIsStyle = ok and type(m) == "table" and type(m.IsMooStyle) == "function"
                                    and m.IsMooStyle("Grumpy") or nil,
                                module = ok and m or nil,
                            })
                            break
                        end
                    end
                end)
                log("probe_on", { state = readState(), hasHook = hookmetamethod ~= nil, modules = {
                    config = CaravanConfig ~= nil, rules = CaravanRules ~= nil, route = CaravanRoute ~= nil } })
            else
                stopProbe()
            end
        end,
    })
    tab:CreateButton({
        Name = "Dump State Now",
        Callback = function()
            local was = S.debug
            S.debug = true
            scanTargets()
            log("dump", {
                state = readState(),
                guide = guidePart(),
                routePose = S.snap and routePose(S.snap),
                barrels = S.barrels,
                crates = S.crates,
                tree = dumpTree(Workspace:FindFirstChild("CaravanConvoy"), CONFIG.TREE_DEPTH),
            })
            flushLog(true)
            S.debug = was
        end,
    })
    tab:CreateButton({ Name = "Destroy Script", Callback = destroy })
    tab:CreateSection({ Name = "Status" })
    pcall(function()
        if tab.CreateText then
            statusCard = tab:CreateText({ Title = "Status: Idle", Content = "Farm off." })
        end
    end)
    if not statusCard and tab.CreateParagraph then
        pcall(function()
            statusCard = tab:CreateParagraph({ Title = "Status: Idle", Content = "Farm off." })
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Run
----------------------------------------------------------------------------------------------------

bindFolder(cowGame:FindFirstChild("CaravanState"))
listenIncoming()
table.insert(S.conns, cowGame.ChildAdded:Connect(function(ch)
    if ch.Name == "CaravanState" then bindFolder(ch) end
end))

task.spawn(function()
    local lastCard = 0
    while S.running do
        local now = os.clock()
        local ok, err = pcall(step, now)
        if not ok then
            S.status = "Error: " .. tostring(err)
            log("error", { err = tostring(err) })
        end
        flushLog(false)
        if now - lastCard >= 0.5 then
            lastCard = now
            local st = S.snap
            local s = S.stats
            setCard("Status: " .. S.status, string.format(
                "Mode: %s · Grumpy: %s\nPhase: %s · Kind: %s\nCaravans %d · Stopped %d\nMoos %d · Frights %d · Missed %d\nKicks %d (ok %d / rejected %d) · Crates opened %d · Skins %d\nBites %d · Loot drops %d%s",
                S.natural and "Natural (walk)" or "Teleport", S.useGrumpy and S.grumpyState or "off",
                tostring(st and st.Phase or "none"), tostring(st and st.Kind or "-"),
                s.caravans, s.stopped, s.moos, s.frights, s.missed, s.kicks, s.kickOk, s.kickBad, s.opened, s.skins, s.bites, s.loot,
                S.debug and ("\nLog: " .. tostring(S.logFile)) or ""))
        end
        task.wait(CONFIG.LOOP_DT)
    end
end)
