--[[
    Join timing. Run it as soon as the executor can attach after launching the game. It starts the perf monitor and
    records when the join reaches each stage. Observation only.
    Times are workspace.DistributedGameTime (seconds since this client joined the server). Byte counts come from the
    cumulative Stats counter, so stages reached before the script ran are still dated at injection with their bytes.
    Output: cowhub/perflogs/join_<time>.json (+ marks in the perf monitor log)
]]
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local J = { stages = {}, order = {} }

local function bytesReceived()
    for _, item in ipairs(Stats:GetDescendants()) do
        if item.Name == "totalBytesReceived" and item:IsA("StatsItem") then
            local ok, v = pcall(function() return item:GetValue() end)
            if ok then return v end
        end
    end
    return nil
end

local function stage(name)
    if J.stages[name] then return end
    local mem
    pcall(function() mem = math.round(Stats:GetTotalMemoryUsageMb()) end)
    J.stages[name] = {
        t = math.round(workspace.DistributedGameTime * 100) / 100,
        bytes = bytesReceived(),
        memMb = mem,
        instances = Stats.InstanceCount,
    }
    table.insert(J.order, name)
    if _G.CowPerfMonitor then pcall(_G.CowPerfMonitor.Mark, "JOIN " .. name) end
end

stage("injected")
if not game:IsLoaded() then game.Loaded:Wait() end
stage("loaded")

pcall(function() loadstring(readfile("cowhub/perf_monitor.lua"))() end)
stage("monitor")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
stage("character")

local remotes = game:GetService("ReplicatedStorage"):WaitForChild("CowGame", 60):WaitForChild("Remotes", 60)
local clientEvent = remotes:WaitForChild("ClientEvent", 60)
local conn = clientEvent.OnClientEvent:Connect(function(name)
    if name == "Snapshot" then
        stage("first Snapshot")
    elseif name == "GrassChunkSnapshot" then
        stage("first grass chunk")
    end
end)

-- Playable: character on the ground and the HUD showing
task.spawn(function()
    local hrp = character:WaitForChild("HumanoidRootPart", 60)
    local humanoid = character:WaitForChild("Humanoid", 60)
    local playerGui = player:WaitForChild("PlayerGui")
    local deadline = os.clock() + 120
    while os.clock() < deadline do
        local grounded = humanoid and humanoid.FloorMaterial ~= Enum.Material.Air
        local hud = 0
        for _, g in ipairs(playerGui:GetChildren()) do
            if g:IsA("ScreenGui") and g.Enabled then hud += 1 end
        end
        if hrp and grounded and hud >= 10 then
            stage("playable")
            break
        end
        task.wait(0.1)
    end
    task.wait(30)
    stage("playable+30s")
    conn:Disconnect()
    pcall(function()
        if not isfolder("cowhub/perflogs") then makefolder("cowhub/perflogs") end
    end)
    J.jobId = game.JobId
    J.players = #Players:GetPlayers()
    writefile(string.format("cowhub/perflogs/join_%d.json", os.time()), HttpService:JSONEncode(J))
end)
