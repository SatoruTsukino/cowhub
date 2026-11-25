-- Anomaly Cafe Probe
-- Pass 1 (passive): game id, remotes, prompts/click detectors, task-ish GUI, anticheat scan of client scripts.
-- Pass 2 (SPY = true only): logs outgoing FireServer/InvokeServer + incoming OnClientEvent for SPY_SECONDS
--   while you complete tasks by hand. Enable only after pass 1 shows no client anticheat.
-- Output: cowhub/probes/anomaly_<unix>.txt, sources in cowhub/probes/anomaly_src/

local SPY = false
local SPY_SECONDS = 120

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer

local DIR, SRC = "cowhub/probes", "cowhub/probes/anomaly_src"
local canWrite = type(writefile) == "function"
if canWrite and type(makefolder) == "function" then
    for _, d in ipairs({ "cowhub", DIR, SRC }) do
        if not (isfolder and isfolder(d)) then pcall(makefolder, d) end
    end
end

local report = {}
local function out(fmt, ...)
    report[#report + 1] = select("#", ...) > 0 and string.format(fmt, ...) or fmt
end
local function fullName(i)
    local ok, n = pcall(function() return i:GetFullName() end)
    return ok and n or tostring(i)
end
local function safeName(s) return (tostring(s):gsub("[^%w_%-]", "_")) end
local function fmtVal(v, depth)
    depth = depth or 0
    local t = typeof(v)
    if t == "Instance" then return fullName(v) end
    if t == "Vector3" then return string.format("V3(%.2f,%.2f,%.2f)", v.X, v.Y, v.Z) end
    if t == "CFrame" then return string.format("CF(%.2f,%.2f,%.2f)", v.X, v.Y, v.Z) end
    if t == "string" then return string.format("%q", #v > 120 and v:sub(1, 120) .. "…" or v) end
    if t == "table" then
        if depth > 2 then return "{…}" end
        local parts, n = {}, 0
        for k, x in pairs(v) do
            n += 1
            if n > 12 then parts[#parts + 1] = "…" break end
            parts[#parts + 1] = tostring(k) .. "=" .. fmtVal(x, depth + 1)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(v)
end
local function attrs(i)
    local ok, a = pcall(function() return i:GetAttributes() end)
    return (ok and a and next(a)) and (" " .. fmtVal(a)) or ""
end
local function flush()
    if canWrite then pcall(writefile, DIR .. "/anomaly_" .. os.time() .. ".txt", table.concat(report, "\n") .. "\n") end
end

out("PlaceId %d | GameId %d | JobId %s | %s", game.PlaceId, game.GameId, game.JobId, os.date("%Y-%m-%d %H:%M:%S"))
out("Executor: %s", identifyexecutor and tostring((identifyexecutor())) or "?")
out("Player attrs:%s", attrs(plr))
for _, f in ipairs(plr:GetChildren()) do
    if f:IsA("Folder") or f:IsA("Configuration") or f:IsA("ValueBase") then
        out("  plr.%s [%s]%s%s", f.Name, f.ClassName, f:IsA("ValueBase") and (" = " .. fmtVal(f.Value)) or "", attrs(f))
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("ValueBase") then out("    %s = %s", c.Name, fmtVal(c.Value)) end
        end
    end
end

-- ---------- Remotes ----------
out("")
out("== Remotes ==")
local AC_REMOTE = { "ban", "kick", "flag", "report", "log", "secur", "detect", "cheat", "exploit", "integrity", "heartbeat", "ping" }
for _, root in ipairs({ RS, workspace, plr:FindFirstChild("PlayerGui"), plr:FindFirstChild("PlayerScripts") }) do
    if root then
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("UnreliableRemoteEvent") or d:IsA("BindableEvent") then
                local low, tag = d.Name:lower(), ""
                for _, k in ipairs(AC_REMOTE) do if low:find(k, 1, true) then tag = "  <-- AC?" break end end
                if not d:IsA("BindableEvent") or tag ~= "" then out("  %s [%s]%s", fullName(d), d.ClassName, tag) end
            end
        end
    end
end

-- ---------- Interactables ----------
out("")
out("== ProximityPrompts / ClickDetectors ==")
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
    if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
        n += 1
        if n <= 300 then
            local p = d:FindFirstAncestorWhichIsA("BasePart") or d.Parent
            local pos = (p and p:IsA("BasePart")) and fmtVal(p.Position) or ""
            if d:IsA("ProximityPrompt") then
                out("  %s [PP] action=%q object=%q hold=%.2f enabled=%s %s%s", fullName(d), d.ActionText, d.ObjectText,
                    d.HoldDuration, tostring(d.Enabled), pos, attrs(d.Parent))
            else
                out("  %s [CD] %s%s", fullName(d), pos, attrs(d.Parent))
            end
        end
    end
end
out("  total %d", n)

-- ---------- GUI ----------
out("")
out("== PlayerGui (visible text / buttons) ==")
local pg = plr:FindFirstChild("PlayerGui")
if pg then
    for _, g in ipairs(pg:GetChildren()) do
        out("  [%s] %s enabled=%s", g.ClassName, g.Name, tostring(g:IsA("ScreenGui") and g.Enabled))
    end
    for _, d in ipairs(pg:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and d.Text ~= "" then
            out("  %s [%s] %q vis=%s", fullName(d), d.ClassName, d.Text:sub(1, 80), tostring(d.Visible))
        elseif d:IsA("ImageButton") then
            out("  %s [ImageButton] vis=%s", fullName(d), tostring(d.Visible))
        end
    end
end

-- ---------- Workspace top level ----------
out("")
out("== Workspace top level ==")
for _, c in ipairs(workspace:GetChildren()) do
    out("  %s [%s] children=%d%s", c.Name, c.ClassName, #c:GetChildren(), attrs(c))
end

-- ---------- Anticheat scan ----------
out("")
out("== Anticheat scan (client scripts) ==")
local AC_NEEDLES = {
    ":Kick(", "anticheat", "anti_cheat", "AntiCheat", "getgc", "hookfunction", "hookmetamethod", "checkcaller",
    "newcclosure", "getrawmetatable", "islclosure", "identifyexecutor", "debug.info", "debug.traceback",
    "ScriptContext", "LogService", "MessageOut", "GetPropertyChangedSignal(\"WalkSpeed\")", "WalkSpeed",
    "JumpPower", "CoreGui", "gcinfo", "collectgarbage", "memorycategory", "GetTotalMemoryUsageMb",
}
local candidates, seen = {}, {}
local function add(i)
    if typeof(i) == "Instance" and not seen[i] and (i:IsA("ModuleScript") or i:IsA("LocalScript")) then
        seen[i] = true
        candidates[#candidates + 1] = i
    end
end
if type(getloadedmodules) == "function" then
    local ok, m = pcall(getloadedmodules)
    if ok then for _, x in ipairs(m) do add(x) end end
end
if type(getrunningscripts) == "function" then
    local ok, m = pcall(getrunningscripts)
    if ok then for _, x in ipairs(m) do add(x) end end
end
for _, root in ipairs({ RS, game:GetService("ReplicatedFirst"), plr:FindFirstChild("PlayerScripts"), plr.Character }) do
    if root then for _, d in ipairs(root:GetDescendants()) do add(d) end end
end
out("%d client scripts", #candidates)
for _, s in ipairs(candidates) do
    local low = s.Name:lower()
    if low:find("anti") or low:find("cheat") or low:find("secur") or low:find("guard") or low:find("detect") then
        out("  NAME HIT %s [%s]", fullName(s), s.ClassName)
    end
end

if type(decompile) ~= "function" then
    out("decompile unavailable: source scan skipped")
else
    local failed, saved = 0, 0
    for i, s in ipairs(candidates) do
        if i % 8 == 0 then task.wait() end
        local ok, src = pcall(decompile, s)
        if not ok or type(src) ~= "string" then
            failed += 1
        else
            -- skip Roblox core packages; keep game code
            local fn = fullName(s)
            if not fn:find("_Index", 1, true) and not fn:find("Packages", 1, true) and not fn:find("PlayerModule", 1, true) then
                if canWrite then
                    saved += 1
                    pcall(writefile, SRC .. "/" .. safeName(fn) .. ".lua", "-- " .. fn .. "\n" .. src)
                end
                local lineNo, shown = 0, 0
                for line in string.gmatch(src .. "\n", "([^\n]*)\n") do
                    lineNo += 1
                    for _, nd in ipairs(AC_NEEDLES) do
                        if line:find(nd, 1, true) then
                            if shown == 0 then out("") out("HIT %s [%s]", fn, s.ClassName) end
                            shown += 1
                            if shown <= 15 then out("  %5d [%s] %s", lineNo, nd, line:gsub("^%s+", ""):sub(1, 180)) end
                            break
                        end
                    end
                end
            end
        end
    end
    out("")
    out("%d sources saved, %d failed to decompile", saved, failed)
end
flush()

-- ---------- Pass 2: remote spy ----------
if SPY and type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    out("")
    out("== Remote spy (%ds) ==", SPY_SECONDS)
    local t0, live = os.clock(), true
    local function log(dir, r, ...)
        if live then out("  +%.2fs %s %s %s", os.clock() - t0, dir, fullName(r), fmtVal({ ... })) end
    end
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if live and not checkcaller() then
            local m = getnamecallmethod()
            if m == "FireServer" or m == "InvokeServer" then
                if typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent")) then
                    log(m == "FireServer" and "OUT" or "INV", self, ...)
                end
            end
        end
        return old(self, ...)
    end))
    local conns = {}
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("UnreliableRemoteEvent") then
            conns[#conns + 1] = d.OnClientEvent:Connect(function(...) log("IN ", d, ...) end)
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            conns[#conns + 1] = d.Triggered:Connect(function() log("PP ", d) end)
        end
    end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Anomaly Probe", Text = "Spy on: do tasks now (" .. SPY_SECONDS .. "s)", Duration = 6 })
    end)
    task.wait(SPY_SECONDS)
    live = false
    for _, c in ipairs(conns) do c:Disconnect() end
    flush()
end

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Anomaly Probe", Text = "Done: " .. DIR, Duration = 6 })
end)
