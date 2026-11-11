-- Groups RunService per-frame connections by the script that owns the callback
local RunService = game:GetService("RunService")
local tag = ... or "probe"
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
writefile("cowhub/conn_probe_" .. tag .. ".json", game:GetService("HttpService"):JSONEncode(out))
