-- Cow Hub Module Finder
-- Finds the client code that constructs GrassRenderController (and the remote it is given),
-- then saves every loaded module whose source mentions a needle to cowhub/dumps/.
-- Run after the world has loaded. Output: cowhub/dumps/module_finder_<time>.txt

local NEEDLES = {
    "GrassRenderController.new",
    "GrassRenderController",
    "RequestRemote",
    "Action =",
    "ApplyGrassModifiers",
}
local MAX_LINES_PER_FILE = 25

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")

local DIR = "cowhub/dumps"
local report = {}
local function out(fmt, ...)
    local line = string.format(fmt, ...)
    table.insert(report, line)
    print("[ModuleFinder] " .. line)
end

local canWrite = type(writefile) == "function"
if canWrite and type(makefolder) == "function" then
    pcall(function()
        if not (isfolder and isfolder("cowhub")) then makefolder("cowhub") end
        if not (isfolder and isfolder(DIR)) then makefolder(DIR) end
    end)
end

local function safeName(s)
    return (tostring(s):gsub("[^%w_%-]", "_"))
end

local function fullName(inst)
    local ok, name = pcall(function() return inst:GetFullName() end)
    return ok and name or tostring(inst)
end

local getUpvalues = (debug and debug.getupvalues) or getupvalues

-- ---------- Pass 1: live controller via the garbage collector ----------
out("PlaceId %d | JobId %s | %s", game.PlaceId, game.JobId, os.date("%Y-%m-%d %H:%M:%S"))
out("")
out("== Live pass (getgc) ==")

if type(getgc) ~= "function" then
    out("getgc unavailable: skipped")
else
    local ok, objs = pcall(getgc, true)
    if not ok or type(objs) ~= "table" then
        out("getgc failed: %s", tostring(objs))
    else
        local controllers, classes = {}, {}
        for _, t in ipairs(objs) do
            if type(t) == "table" and rawget(t, "RequestRemote") ~= nil and rawget(t, "Nodes") ~= nil then
                controllers[t] = true
                local mt = getmetatable(t)
                local cls = type(mt) == "table" and rawget(mt, "__index")
                if type(cls) == "table" then classes[cls] = true end
                if type(mt) == "table" then classes[mt] = true end
                local remote = rawget(t, "RequestRemote")
                local kind = typeof(remote) == "Instance" and remote.ClassName or typeof(remote)
                out("Controller found. RequestRemote = %s (%s)", typeof(remote) == "Instance" and fullName(remote) or tostring(remote), kind)
            end
        end
        if next(controllers) == nil then
            out("No live GrassRenderController (is the grass loaded?)")
        end

        -- Functions holding the controller or its class as an upvalue = the code that built/owns it
        local seen = {}
        if getUpvalues and next(controllers) ~= nil then
            for _, fn in ipairs(objs) do
                if type(fn) == "function" and not (iscclosure and iscclosure(fn)) then
                    local okU, ups = pcall(getUpvalues, fn)
                    if okU and type(ups) == "table" then
                        for _, v in pairs(ups) do
                            if type(v) == "table" and (controllers[v] or classes[v]) then
                                local okS, src, line, name = pcall(debug.info, fn, "sln")
                                local key = okS and (tostring(src) .. ":" .. tostring(name)) or tostring(fn)
                                if not seen[key] then
                                    seen[key] = true
                                    out("Holder: %s  fn=%s line=%s  (%s)", tostring(src), tostring(name), tostring(line),
                                        controllers[v] and "instance" or "class")
                                end
                                break
                            end
                        end
                    end
                end
            end
        elseif not getUpvalues then
            out("getupvalues unavailable: holder search skipped")
        end
    end
end

-- ---------- Pass 2: decompile and search sources ----------
out("")
out("== Source pass ==")

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
for _, root in ipairs(roots) do
    for _, d in ipairs(root:GetDescendants()) do add(d) end
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
            for _, needle in ipairs(NEEDLES) do
                if string.find(src, needle, 1, true) then table.insert(matched, needle) end
            end
            if #matched > 0 then
                hits += 1
                out("")
                out("HIT %s [%s]  needles: %s", fullName(inst), inst.ClassName, table.concat(matched, ", "))
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
                    local path = string.format("%s/%s_%s_%d_Source.txt", DIR, safeName(inst.Name), inst.ClassName, game.PlaceId)
                    pcall(writefile, path, "-- " .. fullName(inst) .. "\n" .. src)
                    out("  saved -> %s", path)
                end
            end
        end
    end
    out("")
    out("%d matching scripts, %d failed to decompile", hits, failed)
end

-- ---------- Report ----------
local reportPath = string.format("%s/module_finder_%d.txt", DIR, os.time())
if canWrite then
    pcall(writefile, reportPath, table.concat(report, "\n") .. "\n")
end
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Module Finder",
        Text = canWrite and ("Report: " .. reportPath) or "Done (see console; writefile unavailable)",
        Duration = 8,
    })
end)
