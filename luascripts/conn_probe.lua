-- Leak snapshot: per-frame connections grouped by the script that owns the callback, plus instance,
-- GUI and Lua memory counts. Observation only. Usage: loadstring(readfile("cowhub/conn_probe.lua"))("<tag>")
-- Writes cowhub/conn_probe_<tag>.json. Pass "gc" as the second argument to collect garbage first
-- (needs the executor's collectgarbage), so a later diff shows memory that is still held.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local tag, mode = ...
tag = tag or "probe"

if mode == "gc" then
    pcall(function()
        for _ = 1, 3 do collectgarbage("collect") end
    end)
    task.wait(1)
end

local out = { tag = tag, at = os.time() }
for _, sig in ipairs({ "Heartbeat", "RenderStepped", "Stepped", "PreSimulation" }) do
    local groups = {}
    local ok, conns = pcall(getconnections, RunService[sig])
    if ok then
        for _, c in ipairs(conns) do
            local fn = c.Function
            local key = "?"
            if fn then
                local s, l = debug.info(fn, "sl")
                local exec = isexecutorclosure and isexecutorclosure(fn)
                key = (exec and "[exec] " or "") .. tostring(s) .. ":" .. tostring(l)
            elseif c.ForeignState then
                key = "[foreign]"
            end
            groups[key] = (groups[key] or 0) + 1
        end
        out[sig] = { total = #conns, by = groups }
    end
end

local counts = {}
pcall(function() counts.workspace = #workspace:GetDescendants() end)
pcall(function()
    local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local screens, enabled, visible = 0, 0, 0
    local all = playerGui:GetDescendants()
    for _, inst in ipairs(all) do
        if inst:IsA("ScreenGui") then
            screens += 1
            if inst.Enabled then enabled += 1 end
        elseif inst:IsA("GuiObject") and inst.Visible then
            visible += 1
        end
    end
    counts.playerGui, counts.screenGuis, counts.enabledScreenGuis, counts.visibleGuiObjects = #all, screens, enabled, visible
end)
pcall(function() counts.instances = Stats.InstanceCount end)
pcall(function() counts.luaHeapMb = math.round(Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.LuaHeap) * 10) / 10 end)
pcall(function() counts.guiMb = math.round(Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Gui) * 10) / 10 end)
pcall(function() counts.totalMb = math.round(Stats:GetTotalMemoryUsageMb()) end)
pcall(function() counts.gcKb = math.round(gcinfo()) end)
pcall(function()
    local remote = game:GetService("ReplicatedStorage").CowGame.Remotes.ClientEvent
    counts.clientEventListeners = #getconnections(remote.OnClientEvent)
end)
out.counts = counts

writefile("cowhub/conn_probe_" .. tag .. ".json", game:GetService("HttpService"):JSONEncode(out))
