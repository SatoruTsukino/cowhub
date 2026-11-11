--[[
    Byte calibration: compares Roblox's own network byte counters with the perf monitor's payload estimates
    over the same window. Observation only. Needs _G.CowPerfMonitor running.
    Usage: loadstring(readfile("cowhub/perf_calibrate.lua"))(120)  -- window in seconds
    Output: cowhub/perflogs/calibrate_<time>.json
]]
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local seconds = tonumber((...)) or 120

local COUNTERS = { "totalBytesReceived", "totalBytesSent", "totalNetStreamBytesReceived", "totalNetStreamBytesSent",
    "totalPacketsReceived", "totalPacketsSent", "totalRxDroppedPackets" }

local function readCounters()
    local found = {}
    for _, item in ipairs(Stats:GetDescendants()) do
        if item:IsA("StatsItem") and table.find(COUNTERS, item.Name) and found[item.Name] == nil then
            local ok, v = pcall(function() return item:GetValue() end)
            if ok then found[item.Name] = v end
        end
    end
    return found
end

local function monitorTotals()
    local m = _G.CowPerfMonitor
    local t = m and m.State and m.State.totals
    local s = m and m.State and m.State.second
    if not t then return nil end
    return { inB = t.inB + s.inB, outB = t.outB + s.outB, inN = t.inN + s.inN, outN = t.outN + s.outN }
end

task.spawn(function()
    local c0, m0, t0 = readCounters(), monitorTotals(), os.clock()
    if _G.CowPerfMonitor then _G.CowPerfMonitor.Mark("CALIBRATE start") end
    task.wait(seconds)
    local c1, m1, dt = readCounters(), monitorTotals(), os.clock() - t0
    local out = { seconds = math.round(dt), counters = {}, estimate = {} }
    for k, v in pairs(c1) do
        if c0[k] then out.counters[k] = { delta = v - c0[k], perSec = math.round((v - c0[k]) / dt) } end
    end
    if m0 and m1 then
        for k, v in pairs(m1) do out.estimate[k] = { delta = v - m0[k], perSec = math.round((v - m0[k]) / dt) } end
        local rx, tx = out.counters.totalBytesReceived, out.counters.totalBytesSent
        if rx and out.estimate.inB.delta > 0 then out.rxRatio = math.round(rx.delta / out.estimate.inB.delta * 100) / 100 end
        if tx and out.estimate.outB.delta > 0 then out.txRatio = math.round(tx.delta / out.estimate.outB.delta * 100) / 100 end
    end
    pcall(function()
        if not isfolder("cowhub/perflogs") then makefolder("cowhub/perflogs") end
    end)
    writefile(string.format("cowhub/perflogs/calibrate_%d.json", os.time()), HttpService:JSONEncode(out))
    if _G.CowPerfMonitor then _G.CowPerfMonitor.Mark("CALIBRATE end") end
end)
