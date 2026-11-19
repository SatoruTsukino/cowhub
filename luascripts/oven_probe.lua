-- Cow Hub Oven Probe v2 (Auto Bake, Task 0 recon; temporary)
-- v1 found the target: CowWorld.Decorations.NorthRiverOutfitters["North River Bakehouse"]
--   (MixingTable.FieldRaidMixingTable prompt "Make dough", OvenMouth), owned by the client
--   BakehouseController (FieldRaidController shows it on ClientEvent Kind="Bakehouse").
-- v1 stalled while decompiling every script, so v2:
--   1. records remote traffic FIRST (starts immediately, SPY_SECONDS),
--   2. dumps the Bakehouse model (descendants, attributes, prompts),
--   3. decompiles only scripts whose NAME matches TARGETS and saves them to cowhub/dumps/.
-- While it records: open the mixing table, make dough once, bake once by hand, then repeat
-- with a different amount / recipe. Output: cowhub/probes/oven.txt. Stop early: _G.OvenProbeStop = true

local SPY_SECONDS = 300
local TARGETS = { "bakehouse", "bake", "dough", "bread", "oven", "fieldraidrules", "fieldraidconfig", "fieldraidservice" }

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")

local OUT_DIR, DUMP_DIR = "cowhub/probes", "cowhub/dumps"
local OUT_PATH = OUT_DIR .. "/oven.txt"
local canWrite = type(writefile) == "function"
if canWrite and type(makefolder) == "function" then
    pcall(function()
        for _, d in ipairs({ "cowhub", OUT_DIR, DUMP_DIR }) do
            if not (isfolder and isfolder(d)) then makefolder(d) end
        end
    end)
end

local report = {}
local function flush()
    if canWrite then pcall(writefile, OUT_PATH, table.concat(report, "\n") .. "\n") end
end
local function out(fmt, ...)
    local line = string.format(fmt, ...)
    table.insert(report, line)
    print("[OvenProbe] " .. line)
end

local function fullName(inst)
    local ok, name = pcall(function() return inst:GetFullName() end)
    return ok and name or tostring(inst)
end

local function ser(v, depth, seen)
    depth = depth or 0
    local t = typeof(v)
    if t == "string" then return string.format("%q", v) end
    if t == "Instance" then return "<" .. v.ClassName .. " " .. fullName(v) .. ">" end
    if t == "Vector3" then return string.format("V3(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) end
    if t == "CFrame" then return string.format("CF(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) end
    if t ~= "table" then return tostring(v) end
    seen = seen or {}
    if seen[v] then return "<cycle>" end
    if depth >= 6 then return "{...}" end
    seen[v] = true
    local parts, n = {}, 0
    for k, val in pairs(v) do
        n += 1
        if n > 80 then table.insert(parts, "...") break end
        table.insert(parts, "[" .. ser(k, depth + 1, seen) .. "]=" .. ser(val, depth + 1, seen))
    end
    seen[v] = nil
    return "{" .. table.concat(parts, ", ") .. "}"
end

local function packArgs(...)
    local a = table.pack(...)
    local s = {}
    for i = 1, a.n do s[i] = ser(a[i]) end
    return table.concat(s, " | "):sub(1, 4000)
end

out("PlaceId %d | JobId %s | %s", game.PlaceId, game.JobId, os.date("%Y-%m-%d %H:%M:%S"))
local hrp = Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
out("Player at %s", hrp and ser(hrp.Position) or "?")

-- ---------- Pass 1: live traffic (background) ----------
local QUIET = { MoveSync = true, Heartbeat = true, Ping = true, CameraSync = true, InputSync = true,
    RaftingPose = true, ClientMemoryReport = true, SessionPerformanceReport = true, PlayerSignalReport = true,
    GrassChunkRequest = true, BunnyPenMotion = true }
_G.OvenProbeStop = false
local started = os.clock()
local function live() return not _G.OvenProbeStop and os.clock() - started < SPY_SECONDS end
local traffic = {}
local function logTraffic(fmt, ...)
    table.insert(traffic, string.format("[%6.1f] " .. fmt, os.clock() - started, ...))
end

local cg = ReplicatedStorage:FindFirstChild("CowGame")
local remotes = cg and cg:FindFirstChild("Remotes")
local conns = {}
if remotes then
    for _, r in ipairs(remotes:GetChildren()) do
        if r:IsA("RemoteEvent") and not QUIET[r.Name] then
            table.insert(conns, r.OnClientEvent:Connect(function(...)
                if live() then logTraffic("S->C %s %s", r.Name, packArgs(...)) end
            end))
        end
    end
end

local oldNamecall
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    local function hook(self, ...)
        local m = getnamecallmethod()
        if (m == "FireServer" or m == "InvokeServer") and live() and not checkcaller()
            and typeof(self) == "Instance" and remotes and self.Parent == remotes and not QUIET[self.Name] then
            local line = packArgs(...)
            local name = self.Name
            task.spawn(logTraffic, "C->S %s:%s %s", name, m, line)
        end
        return oldNamecall(self, ...)
    end
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure and newcclosure(hook) or hook)
else
    out("hookmetamethod unavailable: outgoing requests not recorded")
end

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Oven Probe v2",
        Text = "Recording " .. SPY_SECONDS .. "s: make dough + bake by hand now",
        Duration = 8,
    })
end)

-- ---------- Pass 2: Bakehouse model ----------
out("")
out("== Bakehouse model ==")
local bakehouse
do
    local deco = workspace:FindFirstChild("CowWorld") and workspace.CowWorld:FindFirstChild("Decorations")
    local nro = deco and deco:FindFirstChild("NorthRiverOutfitters")
    bakehouse = nro and nro:FindFirstChild("North River Bakehouse")
    if not bakehouse then
        out("North River Bakehouse not found (stream in by standing near it)")
    else
        out("%s %s pivot=%s attrs=%s", bakehouse.ClassName, fullName(bakehouse), ser(bakehouse:GetPivot().Position), ser(bakehouse:GetAttributes()))
        for _, d in ipairs(bakehouse:GetDescendants()) do
            local attrs = d:GetAttributes()
            local line = string.format("  %s %s", d.ClassName, d.Name)
            if d:IsA("BasePart") then line ..= " @ " .. ser(d.Position) end
            if next(attrs) ~= nil then line ..= " attrs=" .. ser(attrs) end
            if d:IsA("ProximityPrompt") then
                line ..= string.format(" PROMPT Action=%q Object=%q Hold=%.2f Range=%.1f LoS=%s Enabled=%s Style=%s",
                    d.ActionText, d.ObjectText, d.HoldDuration, d.MaxActivationDistance,
                    tostring(d.RequiresLineOfSight), tostring(d.Enabled), tostring(d.Style))
            end
            out("%s", line)
        end
    end
end
-- Any other prompts tagged as field raid interactions (other bakehouse stations may live elsewhere)
for i, d in ipairs(workspace:GetDescendants()) do
    if i % 4000 == 0 then task.wait() end
    if d:IsA("ProximityPrompt") and d:GetAttribute("FieldRaidInteraction") ~= nil
        and not (bakehouse and d:IsDescendantOf(bakehouse)) then
        out("FieldRaidInteraction prompt %s Action=%q Object=%q Range=%.1f attrs=%s",
            fullName(d), d.ActionText, d.ObjectText, d.MaxActivationDistance, ser(d:GetAttributes()))
    end
end
flush()

-- ---------- Pass 3: targeted sources ----------
out("")
out("== Targeted sources ==")
do
    local candidates, added = {}, {}
    local function want(inst)
        local n = string.lower(inst.Name)
        for _, t in ipairs(TARGETS) do
            if string.find(n, t, 1, true) then return true end
        end
        return false
    end
    local function add(inst)
        if typeof(inst) == "Instance" and not added[inst]
            and (inst:IsA("ModuleScript") or inst:IsA("LocalScript")) and want(inst) then
            added[inst] = true
            table.insert(candidates, inst)
        end
    end
    if type(getloadedmodules) == "function" then
        local ok, mods = pcall(getloadedmodules)
        if ok and type(mods) == "table" then for _, m in ipairs(mods) do add(m) end end
    end
    local roots = { ReplicatedStorage, ReplicatedFirst }
    local ps = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then table.insert(roots, ps) end
    for _, r in ipairs(roots) do
        for _, d in ipairs(r:GetDescendants()) do add(d) end
    end
    if type(getnilinstances) == "function" then
        local ok, nils = pcall(getnilinstances)
        if ok and type(nils) == "table" then for _, d in ipairs(nils) do add(d) end end
    end
    out("%d target scripts", #candidates)
    for _, inst in ipairs(candidates) do
        task.wait()
        local ok, src = false, nil
        if type(decompile) == "function" then ok, src = pcall(decompile, inst) end
        if ok and type(src) == "string" then
            local path = string.format("%s/%s_%s_%d_Source.txt", DUMP_DIR,
                (inst.Name:gsub("[^%w_%-]", "_")), inst.ClassName, game.PlaceId)
            if canWrite then pcall(writefile, path, "-- " .. fullName(inst) .. "\n" .. src) end
            out("SAVED %s (%d bytes) -> %s", fullName(inst), #src, path)
        else
            out("FAILED %s: %s", fullName(inst), tostring(src))
        end
        flush()
    end
end

-- ---------- Wait for traffic ----------
out("")
out("== Traffic (until %ds) ==", SPY_SECONDS)
flush()
local written = 0
while live() do
    task.wait(1)
    if #traffic > written then
        for i = written + 1, #traffic do table.insert(report, traffic[i]) end
        written = #traffic
        flush()
    end
end
-- The namecall hook stays installed but goes inert once live() is false.
for _, c in ipairs(conns) do c:Disconnect() end
for i = written + 1, #traffic do table.insert(report, traffic[i]) end
out("")
out("== Done ==")
flush()
pcall(function()
    StarterGui:SetCore("SendNotification", { Title = "Oven Probe v2", Text = "Done: " .. OUT_PATH, Duration = 8 })
end)
