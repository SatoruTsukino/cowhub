-- CowHub Bot Check Solver | Authorized pentest tool (run with developer consent)
-- Answers the game's human check over BotCheckRequest and logs a full transcript
-- to cowhub/botcheck/ so detection weaknesses can be reported to the developer.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

if _G.CowHubBotCheckSolver and _G.CowHubBotCheckSolver.stop then
    pcall(_G.CowHubBotCheckSolver.stop)
end

local plr = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("CowGame"):WaitForChild("Remotes")
local clientEvent = remotes:WaitForChild("ClientEvent")
local botRemote = remotes:WaitForChild("BotCheckRequest")

local LOG_DIR = "cowhub/botcheck"
local ACTIONS = { QuickCheck = "Answer", RoomEntry = "Open", Dialogue = "Dialogue" }
local MAX_QUICK_RESETS = 3

local solver = {
    running = true,
    minDelay = 0.9,
    maxDelay = 2.4,
    lastKey = nil,
    lastQuickStage = nil,
    quickResets = 0,
    conns = {},
    rng = Random.new(),
    logPath = nil,
}
_G.CowHubBotCheckSolver = solver

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 5 })
    end)
end

local function log(event, data)
    if not writefile then return end
    pcall(function()
        if makefolder and isfolder then
            if not isfolder("cowhub") then makefolder("cowhub") end
            if not isfolder(LOG_DIR) then makefolder(LOG_DIR) end
        end
        if not solver.logPath then
            solver.logPath = string.format("%s/botcheck_%d.jsonl", LOG_DIR, os.time())
        end
        local line = HttpService:JSONEncode({
            t = os.time(),
            serverTime = workspace:GetServerTimeNow(),
            event = event,
            data = data,
        }) .. "\n"
        local exists = isfile and isfile(solver.logPath)
        if exists and appendfile then
            appendfile(solver.logPath, line)
        else
            local prev = (exists and readfile) and readfile(solver.logPath) or ""
            writefile(solver.logPath, prev .. line)
        end
    end)
end

local function lower(s)
    return string.lower(tostring(s or ""))
end

-- Returns (choice, strategy) or (nil, reason)
function solver.pick(snap)
    local choices = snap.Choices
    if type(choices) ~= "table" or #choices == 0 then
        return nil, "no choices"
    end

    if snap.Phase == "QuickCheck" then
        local prompt = lower(snap.Prompt)
        local match, count = nil, 0
        for _, c in ipairs(choices) do
            local text = lower(c.Text)
            if text ~= "" and string.find(prompt, text, 1, true) then
                match, count = c, count + 1
            end
        end
        if count == 1 then return match, "prompt-text" end

        local flat = string.gsub(prompt, "%s+", "")
        match, count = nil, 0
        for _, c in ipairs(choices) do
            local icon = lower(c.Icon)
            if icon ~= "" and string.find(flat, icon, 1, true) then
                match, count = c, count + 1
            end
        end
        if count == 1 then return match, "prompt-icon" end
        return nil, "ambiguous quick prompt"
    end

    for _, c in ipairs(choices) do
        if c.Tone == "Green" then return c, "tone-green" end
    end
    return nil, "no green choice"
end

function solver.answerDelay(snap)
    local delay = solver.minDelay + solver.rng:NextNumber() * (solver.maxDelay - solver.minDelay)
    if snap.Phase == "QuickCheck" and type(snap.Deadline) == "number" then
        local remaining = snap.Deadline - workspace:GetServerTimeNow()
        if remaining > 0 and remaining < 60 then
            delay = math.min(delay, math.max(0.3, remaining - 1))
        end
    end
    return delay
end

function solver.handle(snap)
    if not solver.running or type(snap) ~= "table" then return end

    if snap.Phase == "Released" then
        log("released", snap)
        solver.lastKey, solver.lastQuickStage, solver.quickResets = nil, nil, 0
        notify("Bot Check", "Released.", 4)
        return
    end

    local action = ACTIONS[snap.Phase]
    if not action or type(snap.Id) ~= "string" or type(snap.Nonce) ~= "string" then
        log("ignored", snap)
        return
    end

    local key = snap.Phase .. ":" .. snap.Id .. ":" .. snap.Nonce .. ":" .. tostring(snap.Stage)
    if key == solver.lastKey then return end
    solver.lastKey = key
    log("snapshot", snap)

    -- Wrong QuickCheck answers reset Stage to 1; stop before looping.
    if snap.Phase == "QuickCheck" then
        if snap.Stage == 1 and solver.lastQuickStage and solver.lastQuickStage >= 1 then
            solver.quickResets += 1
        end
        solver.lastQuickStage = snap.Stage
        if solver.quickResets >= MAX_QUICK_RESETS then
            log("halted", { reason = "quick resets", resets = solver.quickResets })
            notify("Bot Check Solver", "Stopped after repeated resets — answer manually.", 10)
            return
        end
    end

    local choice, strategy = solver.pick(snap)
    if not choice or choice.Id == nil then
        log("unsolved", { key = key, reason = strategy })
        notify("Bot Check Solver", "Unsolved (" .. tostring(strategy) .. ") — answer manually.", 10)
        return
    end

    local delay = solver.answerDelay(snap)
    task.delay(delay, function()
        if not solver.running or solver.lastKey ~= key then return end
        local payload = {
            Action = action,
            Id = snap.Id,
            Nonce = snap.Nonce,
            Stage = snap.Stage,
            ChoiceId = choice.Id,
        }
        local ok, err = pcall(function() botRemote:FireServer(payload) end)
        log("answer", {
            key = key,
            strategy = strategy,
            choice = choice.Text,
            delay = delay,
            ok = ok,
            err = ok and nil or tostring(err),
        })
    end)
end

table.insert(solver.conns, clientEvent.OnClientEvent:Connect(function(name, snap)
    if name == "BotCheck" then
        solver.handle(snap)
    end
end))

function solver.stop()
    solver.running = false
    for _, c in ipairs(solver.conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(solver.conns)
    if _G.CowHubBotCheckSolver == solver then
        _G.CowHubBotCheckSolver = nil
    end
end

-- Check already open before load: ask the server to resend the current snapshot.
if plr:GetAttribute("CowBotCheckActive") == true or plr:GetAttribute("CowBotQuarantined") == true then
    pcall(function() botRemote:FireServer({ Action = "Ready" }) end)
    log("resync", {})
end

log("start", { placeId = game.PlaceId, jobId = game.JobId })
notify("Bot Check Solver", "Armed. Logging to " .. LOG_DIR, 4)
