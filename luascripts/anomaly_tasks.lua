-- Anomaly Cafe Task Autocomplete
-- When a cooking minigame starts, waits a human-paced delay, sets the module's score state to
-- the best possible result and calls the game's own _finish, so the normal callback sends a perfect
-- CookingMinigameComplete and the UI closes itself. Re-run to restart; set getgenv().AnomalyTasksStop = true to stop.
-- Log: cowhub/anomaly_logs/tasks_<unix>.jsonl

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local env = getgenv and getgenv() or _G
if env.AnomalyTasksConn then env.AnomalyTasksConn:Disconnect() end
env.AnomalyTasksStop = false

local DIR = "cowhub/anomaly_logs"
local LOG = DIR .. "/tasks_" .. os.time() .. ".jsonl"
if makefolder then
    for _, d in ipairs({ "cowhub", DIR }) do
        if not (isfolder and isfolder(d)) then pcall(makefolder, d) end
    end
end
local function log(t)
    t.t = os.time()
    local line = HttpService:JSONEncode(t)
    print("[AnomalyTasks] " .. line)
    if appendfile then pcall(appendfile, LOG, line .. "\n") elseif writefile then pcall(writefile, LOG, line .. "\n") end
end

local controller = Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client")
    :WaitForChild("Controllers"):WaitForChild("CookingMinigameController")

-- name -> { delay range (s) for a natural finish, function(m) that sets perfect state and finishes }
local function tapGame(m) -- Coffee / Knife / Milkshake: 3 Superb tries = 1 + 3 * 0.5
    m._currentTry = 3
    m._multiplier = 2.5
    m._badCount = 0
    m:_finish()
end
local GAMES = {
    Coffee = { 3.0, 4.5, tapGame },
    Knife = { 3.0, 4.5, tapGame },
    Milkshake = { 3.5, 5.0, tapGame },
    CryoRepair = { 2.5, 3.5, function(m)
        m._goodHits = 2
        m._currentTry = 2
        m:_finish(true)
    end },
    PowerBreaker = { 3.0, 4.5, function(m)
        m._matches = 4
        m:_finish(true)
    end },
    Croissant = { 4.5, 6.0, function(m) m:_finish(true) end },
    Pie = { 4.5, 6.0, function(m) m:_finish(true) end },
    CleanPlates = { 3.0, 4.5, function(m)
        m._cleanedGunk = m._totalGunk
        m:_finish(true)
    end },
}

local mods = {}
for name in pairs(GAMES) do
    local ok, m = pcall(require, controller:WaitForChild(name, 10))
    if ok and type(m) == "table" and type(m.IsPlaying) == "function" and type(m._finish) == "function" then
        mods[name] = m
    else
        log({ ev = "load_fail", game = name, err = tostring(m) })
    end
end

local rng = Random.new()
local pending = {} -- module -> true while a finish is scheduled
env.AnomalyTasksConn = RunService.Heartbeat:Connect(function()
    if env.AnomalyTasksStop then
        env.AnomalyTasksConn:Disconnect()
        return
    end
    for name, m in pairs(mods) do
        if not pending[m] and m:IsPlaying() then
            pending[m] = true
            local g = GAMES[name]
            local wait = rng:NextNumber(g[1], g[2])
            if name == "CleanPlates" then -- server gives the wipe time; don't beat it
                wait = math.max(wait, (tonumber(m._cleanSeconds) or 0) + 0.5)
            end
            log({ ev = "start", game = name, wait = wait })
            task.delay(wait, function()
                if m:IsPlaying() and not env.AnomalyTasksStop then
                    local ok, err = pcall(g[3], m)
                    log({ ev = ok and "done" or "error", game = name, err = not ok and tostring(err) or nil })
                end
                pending[m] = nil
            end)
        end
    end
end)

local loaded = {}
for name in pairs(mods) do loaded[#loaded + 1] = name end
log({ ev = "ready", games = loaded })
