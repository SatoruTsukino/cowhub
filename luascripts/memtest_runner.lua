--[[
    CowHub memory A/B runner. Started from autoexec; runs ONE test per client session, then asks for a restart.

    State (executor workspace): cowhub/memtest/state.json
      { "idx": 1, "duration": 600, "settle": 30,
        "runs": [ { "name": "clean" },
                  { "name": "old_idle", "hub": "<raw url>" },
                  { "name": "new_farm", "hub": "<raw url>", "farm": true } ] }
    Each run: wait for character + settle -> blank hub config -> perf_monitor -> load hub (optional)
    -> Toggle_Farm (optional) -> sample `duration` s -> perf_heap -> stop monitor -> idx += 1.
    Progress: cowhub/memtest/runner.log (JSON lines). Logs: cowhub/perflogs/perf_*.log, heap_*.json.
    The hub's Rayfield config is deleted before each run so saved toggles don't skew results;
    back it up first (see PERF_TESTING.md) and restore it when the series ends.
]]
if _G.CowMemTestRunning then return end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local DIR = "cowhub/memtest"
local STATE = DIR .. "/state.json"
local HUB_CONFIG = "Rayfield/Configurations/CowHub/CowHubConfig.rfld"

if not (isfile and isfile(STATE)) then return end
local okState, state = pcall(function() return HttpService:JSONDecode(readfile(STATE)) end)
if not okState or type(state) ~= "table" or type(state.runs) ~= "table" then return end
local run = state.runs[state.idx or 1]
if not run then return end
_G.CowMemTestRunning = true

local function log(event, extra)
    extra = extra or {}
    extra.ev, extra.run, extra.t = event, run.name, os.time()
    local line = HttpService:JSONEncode(extra) .. "\n"
    pcall(function()
        local path = DIR .. "/runner.log"
        if appendfile and isfile(path) then appendfile(path, line)
        else writefile(path, (isfile(path) and readfile(path) or "") .. line) end
    end)
end

local function notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Mem test: " .. run.name, Text = text, Duration = duration or 10 })
    end)
end

local function newestHeap(since)
    local found
    pcall(function()
        for _, f in ipairs(listfiles("cowhub/perflogs")) do
            local ts = tonumber(string.match(f, "heap_(%d+)%.json$"))
            if ts and ts >= since then found = f end
        end
    end)
    return found
end

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local plr = Players.LocalPlayer
    if not plr.Character then plr.CharacterAdded:Wait() end
    notify(string.format("Run %d/%d starts in %d s. Leave the game idle.", state.idx, #state.runs, state.settle or 30), 15)
    task.wait(state.settle or 30)

    pcall(function() if isfile(HUB_CONFIG) then delfile(HUB_CONFIG) end end)

    local okMon, monErr = pcall(function() loadstring(readfile("cowhub/perf_monitor.lua"))() end)
    local mon = _G.CowPerfMonitor
    if not okMon or not mon then
        log("error", { stage = "monitor", err = tostring(monErr) })
        notify("perf_monitor failed to start", 30)
        _G.CowMemTestRunning = nil
        return
    end
    mon.Mark("memtest start " .. run.name)
    log("start", { perfLog = mon.State and mon.State.fileName })

    if run.hub then
        local ok, err = pcall(function() loadstring(game:HttpGet(run.hub))() end)
        log("hub", { ok = ok, err = (not ok) and tostring(err) or nil })
        mon.Mark("hub loaded")
    end
    if run.farm then
        task.wait(5)
        local ok, err = pcall(function() _G.CowHubWindow:Set("Toggle_Farm", true) end)
        log("farm", { ok = ok, err = (not ok) and tostring(err) or nil })
        mon.Mark("farm on")
    end

    local t0 = os.clock()
    while os.clock() - t0 < (state.duration or 600) do task.wait(5) end

    mon.Mark("heap start")
    local heapSince = os.time()
    pcall(function() loadstring(readfile("cowhub/perf_heap.lua"))() end)
    local heapFile
    local deadline = os.clock() + 180
    while not heapFile and os.clock() < deadline do
        task.wait(3)
        heapFile = newestHeap(heapSince)
    end
    pcall(mon.Stop)

    state.idx = (state.idx or 1) + 1
    pcall(function() writefile(STATE, HttpService:JSONEncode(state)) end)
    log("done", { heap = heapFile })
    local more = state.runs[state.idx] ~= nil
    notify(more and "Done. Restart the client for the next run." or "All runs done.", 120)
    _G.CowMemTestRunning = nil
end)
