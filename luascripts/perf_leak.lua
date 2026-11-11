--[[
    Menu leak test. Opens and closes each game menu CYCLES times through the game's own controllers (the same
    calls its buttons make), then takes a leak snapshot (cowhub/conn_probe.lua, after GC). Growth that is still
    there after GC and after the menu is closed is a leak.

    Needs cowhub/conn_probe.lua in the workspace. Output: cowhub/conn_probe_leak_<n>_<menu>.json
    Stop early: _G.CowPerfLeak.Stop()
]]

local CYCLES = 10
-- Optional: loadstring(readfile("cowhub/perf_leak.lua"))({ tabs = {"Closet"}, controllers = {}, prefix = "leak2" })
local opts = ...
opts = if type(opts) == "table" then opts else {}
local PREFIX = opts.prefix or "leak"
local OPEN_TIME = 1.2
local CLOSE_TIME = 1.0

local Players = game:GetService("Players")
local player = Players.LocalPlayer

if _G.CowPerfLeak and _G.CowPerfLeak.Stop then pcall(_G.CowPerfLeak.Stop) end
local L = { running = true, log = {} }
_G.CowPerfLeak = { Stop = function() L.running = false end, State = L }

local function note(text)
    table.insert(L.log, text)
    local monitor = _G.CowPerfMonitor
    if monitor and monitor.Mark then pcall(monitor.Mark, "LEAK " .. text) end
end

-- Controller instance = a table whose metatable (or its __index) is the controller class
local function findInstance(name)
    local module = player.PlayerScripts:FindFirstChild(name, true)
    if not module or not module:IsA("ModuleScript") then return nil, "module not found" end
    local ok, class = pcall(require, module)
    if not ok or type(class) ~= "table" then return nil, "require failed" end
    for _, t in ipairs(getgc(true)) do
        if type(t) == "table" and t ~= class then
            local mt = getmetatable(t)
            if mt == class or (type(mt) == "table" and rawget(mt, "__index") == class) then
                return t
            end
        end
    end
    return nil, "no instance"
end

local function snapshot(tag)
    local ok, err = pcall(function()
        loadstring(readfile("cowhub/conn_probe.lua"))(tag, "gc")
    end)
    if not ok then note("snapshot error " .. tostring(err)) end
end

local function cycle(name, open, close)
    note(name .. " start")
    local okCount, err = 0, nil
    for _ = 1, CYCLES do
        if not L.running then break end
        local ok1, e1 = pcall(open)
        task.wait(OPEN_TIME)
        local ok2, e2 = pcall(close)
        task.wait(CLOSE_TIME)
        if ok1 and ok2 then okCount += 1 else err = tostring(e1 or e2) end
    end
    note(string.format("%s done %d/%d %s", name, okCount, CYCLES, err or ""))
    return okCount
end

task.spawn(function()
    snapshot(PREFIX .. "_00_before")
    local step = 0
    local nav, navErr = findInstance("NavigationController")
    note("NavigationController " .. (nav and "found" or tostring(navErr)))
    if nav then
        for _, tab in ipairs(opts.tabs or { "Profile", "Grow", "Herd", "Auras", "Closet", "CosmeticIndex", "Quests", "Map",
            "Settings", "Controls", "Audio", "Membership", "DailyStamp" }) do
            if not L.running then break end
            step += 1
            local n = cycle("Nav:" .. tab, function() nav:Open(tab) end, function() nav:Close() end)
            if n > 0 then snapshot(string.format("%s_%02d_%s", PREFIX, step, tab)) end
        end
    end
    for _, name in ipairs(opts.controllers or { "SkinAuctionController", "RaftYardController", "PlayerMailController", "GardenController" }) do
        if not L.running then break end
        local c, cErr = findInstance(name)
        note(name .. " " .. (c and "found" or tostring(cErr)))
        if c then
            step += 1
            local n = cycle(name, function() c:Open() end, function() c:Close() end)
            if n > 0 then snapshot(string.format("%s_%02d_%s", PREFIX, step, name)) end
        end
    end
    task.wait(5)
    snapshot(PREFIX .. "_99_after")
    note("finished")
    pcall(writefile, "cowhub/perf_" .. PREFIX .. "_log.txt", table.concat(L.log, "\n"))
    L.running = false
end)
