-- Cow Hub Oven Probe (Auto Bake, Task 0 recon; temporary)
-- 1. Lists world instances that look like the North River smithy oven (path, position, attributes, prompts).
-- 2. Decompiles loaded scripts mentioning oven/bake/bread; saves full sources to cowhub/dumps/.
-- 3. Records CowGame remote traffic (client -> server and server -> client) for SPY_SECONDS.
--    While it records: walk to the oven and bake ONE item by hand, then a 2nd with a different amount.
-- Output: cowhub/probes/oven.txt (rewritten as traffic arrives). Stop early: _G.OvenProbeStop = true

local SPY_SECONDS = 240
local NAME_PATTERNS = { "oven", "bake", "bread", "bakery", "smithy", "hearth", "loaf", "dough" }
local SOURCE_NEEDLES = { "Oven", "Bake", "Bread", "Baking", "Bakery" }
local MAX_LINES_PER_FILE = 40

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
    if depth >= 5 then return "{...}" end
    seen[v] = true
    local parts, n = {}, 0
    for k, val in pairs(v) do
        n += 1
        if n > 60 then table.insert(parts, "...") break end
        table.insert(parts, "[" .. ser(k, depth + 1, seen) .. "]=" .. ser(val, depth + 1, seen))
    end
    seen[v] = nil
    return "{" .. table.concat(parts, ", ") .. "}"
end

local function matchesName(s)
    s = string.lower(tostring(s))
    for _, p in ipairs(NAME_PATTERNS) do
        if string.find(s, p, 1, true) then return true end
    end
    return false
end

local function attrsText(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    return (ok and next(attrs) ~= nil) and ser(attrs) or ""
end

local function positionOf(inst)
    local ok, pos = pcall(function()
        if inst:IsA("BasePart") then return inst.Position end
        if inst:IsA("Model") then return inst:GetPivot().Position end
        local p = inst:FindFirstAncestorWhichIsA("BasePart")
        return p and p.Position
    end)
    return ok and pos and ser(pos) or "-"
end

-- ---------- Pass 1: world ----------
out("PlaceId %d | JobId %s | %s", game.PlaceId, game.JobId, os.date("%Y-%m-%d %H:%M:%S"))
local root = Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
out("Player at %s", root and ser(root.Position) or "?")
out("")
out("== World matches ==")
do
    local stationTypes, shown = {}, 0
    for i, d in ipairs(workspace:GetDescendants()) do
        if i % 3000 == 0 then task.wait() end
        local okA, st = pcall(function() return d:GetAttribute("CowCraftingStationType") end)
        if okA and st ~= nil then
            stationTypes[tostring(st)] = (stationTypes[tostring(st)] or 0) + 1
            out("STATION %s=%s %s @ %s attrs=%s", d.ClassName, tostring(st), fullName(d), positionOf(d), attrsText(d))
        end
        local isPrompt = d:IsA("ProximityPrompt")
        local hit = matchesName(d.Name)
            or (isPrompt and (matchesName(d.ActionText) or matchesName(d.ObjectText)))
        if hit and shown < 200 then
            shown += 1
            out("%s %s @ %s attrs=%s", d.ClassName, fullName(d), positionOf(d), attrsText(d))
        end
        if isPrompt and (hit or matchesName(d.Parent and d.Parent.Name) or matchesName(d.Parent and d.Parent.Parent and d.Parent.Parent.Name)) then
            out("  PROMPT Action=%q Object=%q Hold=%.2f Range=%.1f LoS=%s Enabled=%s",
                d.ActionText, d.ObjectText, d.HoldDuration, d.MaxActivationDistance, tostring(d.RequiresLineOfSight), tostring(d.Enabled))
        end
    end
    out("Station types: %s", ser(stationTypes))
end
flush()

-- ---------- Pass 2: remotes ----------
local cg = ReplicatedStorage:FindFirstChild("CowGame")
local remotes = cg and cg:FindFirstChild("Remotes")
out("")
out("== Remotes ==")
if remotes then
    for _, r in ipairs(remotes:GetChildren()) do out("  %s [%s]", r.Name, r.ClassName) end
else
    out("CowGame.Remotes not found")
end
flush()

-- ---------- Pass 3: sources ----------
out("")
out("== Source pass ==")
do
    local candidates, added = {}, {}
    local function add(inst)
        if typeof(inst) == "Instance" and not added[inst] and (inst:IsA("ModuleScript") or inst:IsA("LocalScript")) then
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
    out("%d scripts to scan", #candidates)

    if type(decompile) ~= "function" then
        out("decompile unavailable: source pass skipped")
    else
        local hits, failed = 0, 0
        for i, inst in ipairs(candidates) do
            if i % 10 == 0 then task.wait() end
            local ok, src = pcall(decompile, inst)
            if not ok or type(src) ~= "string" then
                failed += 1
            else
                local matched = {}
                for _, needle in ipairs(SOURCE_NEEDLES) do
                    if string.find(src, needle, 1, true) then table.insert(matched, needle) end
                end
                if #matched > 0 then
                    hits += 1
                    out("")
                    out("HIT %s [%s] needles: %s", fullName(inst), inst.ClassName, table.concat(matched, ", "))
                    local lineNo, shown = 0, 0
                    for line in string.gmatch(src .. "\n", "([^\n]*)\n") do
                        lineNo += 1
                        if shown >= MAX_LINES_PER_FILE then break end
                        for _, needle in ipairs(matched) do
                            if string.find(line, needle, 1, true) then
                                shown += 1
                                out("  %5d: %s", lineNo, (line:gsub("^%s+", "")):sub(1, 200))
                                break
                            end
                        end
                    end
                    if canWrite then
                        local path = string.format("%s/%s_%s_%d_Source.txt", DUMP_DIR,
                            (inst.Name:gsub("[^%w_%-]", "_")), inst.ClassName, game.PlaceId)
                        pcall(writefile, path, "-- " .. fullName(inst) .. "\n" .. src)
                        out("  saved -> %s", path)
                    end
                end
            end
        end
        out("")
        out("%d matching scripts, %d failed to decompile", hits, failed)
    end
end
flush()

-- ---------- Pass 4: live traffic ----------
-- Noisy per-frame remotes are skipped so the bake request stands out.
local QUIET = { MoveSync = true, Heartbeat = true, Ping = true, CameraSync = true, InputSync = true }
_G.OvenProbeStop = false
local started = os.clock()
local function live() return not _G.OvenProbeStop and os.clock() - started < SPY_SECONDS end

out("")
out("== Traffic (%ds; bake by hand now) ==", SPY_SECONDS)
flush()
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Oven Probe",
        Text = "Recording " .. SPY_SECONDS .. "s: bake at the oven now",
        Duration = 8,
    })
end)

local conns = {}
if remotes then
    for _, r in ipairs(remotes:GetChildren()) do
        if r:IsA("RemoteEvent") and not QUIET[r.Name] then
            table.insert(conns, r.OnClientEvent:Connect(function(...)
                if not live() then return end
                local a = table.pack(...)
                local s = {}
                for i = 1, a.n do s[i] = ser(a[i]) end
                out("[%6.1f] S->C %s %s", os.clock() - started, r.Name, table.concat(s, " | "):sub(1, 3000))
                flush()
            end))
        end
    end
end

local oldNamecall
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure and newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if (m == "FireServer" or m == "InvokeServer") and live() and not checkcaller()
            and typeof(self) == "Instance" and remotes and self.Parent == remotes and not QUIET[self.Name] then
            local a = table.pack(...)
            task.spawn(function()
                local s = {}
                for i = 1, a.n do s[i] = ser(a[i]) end
                out("[%6.1f] C->S %s:%s %s", os.clock() - started, self.Name, m, table.concat(s, " | "):sub(1, 3000))
                flush()
            end)
        end
        return oldNamecall(self, ...)
    end) or function(self, ...) return oldNamecall(self, ...) end)
else
    out("hookmetamethod unavailable: outgoing requests not recorded")
end

while live() do task.wait(0.5) end
-- The namecall hook stays installed but goes inert once live() is false.
for _, c in ipairs(conns) do c:Disconnect() end
out("")
out("== Done ==")
flush()
pcall(function()
    StarterGui:SetCore("SendNotification", { Title = "Oven Probe", Text = "Done: " .. OUT_PATH, Duration = 8 })
end)
