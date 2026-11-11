--[[
    Cow game performance monitor.

    Observation only: it never fires a remote, moves the character or writes a property on a game
    instance. It counts network traffic and samples client performance so the numbers can back
    feedback to the developers. Running it again replaces the previous instance.

        _G.CowPerfMonitor.Mark("caravan start")   -- tag a moment in the log
        _G.CowPerfMonitor.Census()                -- run a render census now
        _G.CowPerfMonitor.Stop()                  -- write the summary and stop

    Output, in the executor workspace:
      cowhub/perflogs/perf_<time>_<id>.log           running log
      cowhub/perflogs/perf_<time>_<id>_summary.json  rewritten every SUMMARY_INTERVAL and on Stop

    Log lines (CSV, t = seconds since start):
      H,<kind>,<column names>     column names for the S / R / W lines
      S,<t>,...                   1 s client sample (frames, Stats, network totals, churn)
      R,<t>,...                   per remote + action, for each REPORT_INTERVAL window it was active
      W,<t>,<json>                workspace churn per REPORT_INTERVAL: top classes and top models
      M,<t>,<json>                memory by Enum.DeveloperMemoryTag (MB)
      C,<t>,<json>                render census
      P,<t>,<json>                per-frame connections by owning script (every PROBE_INTERVAL)
      E,<t>,<name>,<json>         event (start, env, mark, stop, error)

    Byte counts are estimates of the payload (Roblox does not expose per-remote wire size).
    Limits: RemoteFunction OnClientInvoke is not watched, and remote calls made with
    remote.FireServer(remote, ...) instead of remote:FireServer(...) bypass __namecall.
]]

local CONFIG = {
    FOLDER = "cowhub/perflogs",
    SAMPLE_INTERVAL = 1,
    REPORT_INTERVAL = 10,
    CENSUS_INTERVAL = 60,
    PROBE_INTERVAL = 300,      -- per-frame connection owners (P line); needs getconnections
    FLUSH_INTERVAL = 2,
    SUMMARY_INTERVAL = 30,
    CENSUS_CHUNK = 2000,       -- instances per frame during a census
    NEW_REMOTE_DELAY = 3,      -- seconds before listening to a remote created after start
    HOOK_OUTGOING = true,      -- needs hookmetamethod + getnamecallmethod
    SHOW_STATUS_LABEL = true,
    SIG_MAX_BYTES = 2048,      -- payloads larger than this are compared by size only
    FLAG_RATE = 10,            -- msgs/s in a window for one remote + action
    FLAG_AVG_BYTES = 1000,
    FLAG_DUP_RATIO = 0.5,
}

if _G.CowPerfMonitor and _G.CowPerfMonitor.Stop then
    pcall(_G.CowPerfMonitor.Stop)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

local T = {
    running = true,
    start = os.clock(),
    connections = {},
    pending = {},
    fileName = nil,
    summaryName = nil,
    buckets = {},
    watched = setmetatable({}, { __mode = "k" }),
    frames = 0,
    worstFrame = 0,
    worstHeartbeat = 0,
    second = { inN = 0, inB = 0, outN = 0, outB = 0, add = 0, rem = 0 },
    window = { addClass = {}, addModel = {}, remClass = {} },
    totals = { inN = 0, inB = 0, outN = 0, outB = 0, add = 0, rem = 0, samples = 0 },
    fpsSum = 0,
    fpsMin = math.huge,
    worstFrameEver = 0,
    monTime = 0,
    lastCensus = nil,
    censusRunning = false,
    env = nil,
    errors = 0,
}

----------------------------------------------------------------------------------------------------
-- Encoding
----------------------------------------------------------------------------------------------------

local function jsonString(text)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, text)
    return ok and encoded or '"?"'
end

local function jsonValue(value, depth)
    depth = depth or 0
    local kind = typeof(value)
    if kind == "nil" then
        return "null"
    elseif kind == "boolean" then
        return tostring(value)
    elseif kind == "number" then
        if value ~= value or value == math.huge or value == -math.huge then return "null" end
        return tostring(math.round(value * 1000) / 1000)
    elseif kind == "string" then
        return jsonString(value)
    elseif kind == "Vector3" then
        return string.format("[%.2f,%.2f,%.2f]", value.X, value.Y, value.Z)
    elseif kind == "Instance" then
        return jsonString(value.Name)
    elseif kind == "buffer" then
        return jsonString("<buffer " .. buffer.len(value) .. ">")
    elseif kind ~= "table" then
        return jsonString(tostring(value))
    end
    if depth >= 6 then return '"<deep>"' end
    local parts = {}
    local count = #value
    if count > 0 and next(value, count) == nil then
        for i = 1, math.min(count, 200) do
            parts[i] = jsonValue(value[i], depth + 1)
        end
        return "[" .. table.concat(parts, ",") .. "]"
    end
    for k, v in pairs(value) do
        table.insert(parts, jsonString(tostring(k)) .. ":" .. jsonValue(v, depth + 1))
        if #parts >= 200 then break end
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

-- Rough wire size of one remote argument (Roblox's binary format: type tag + payload)
local SIZES = {
    ["nil"] = 1, boolean = 2, number = 9, Vector3 = 13, Vector2 = 9, Color3 = 13,
    CFrame = 25, Instance = 5, EnumItem = 5, UDim2 = 17, BrickColor = 5, Vector3int16 = 7,
}

local function argBytes(value, depth)
    local kind = typeof(value)
    local fixed = SIZES[kind]
    if fixed then return fixed end
    if kind == "string" then return #value + 3 end
    if kind == "buffer" then return buffer.len(value) + 3 end
    if kind ~= "table" then return 9 end
    if depth >= 8 then return 2 end
    local total = 2
    for k, v in pairs(value) do
        total += argBytes(k, depth + 1) + argBytes(v, depth + 1)
    end
    return total
end

local function csvField(text)
    return (string.gsub(string.sub(tostring(text), 1, 60), "[,%c]", "_"))
end

local function elapsed()
    return math.round((os.clock() - T.start) * 100) / 100
end

----------------------------------------------------------------------------------------------------
-- Log file
----------------------------------------------------------------------------------------------------

local canWrite = type(writefile) == "function"

local function ensureFolder()
    if type(makefolder) ~= "function" then return end
    pcall(function()
        if not (isfolder and isfolder("cowhub")) then makefolder("cowhub") end
        if not (isfolder and isfolder(CONFIG.FOLDER)) then makefolder(CONFIG.FOLDER) end
    end)
end

local function openLog()
    if not canWrite then return end
    ensureFolder()
    local id = string.sub(HttpService:GenerateGUID(false), 1, 8)
    local base = string.format("%s/perf_%d_%s", CONFIG.FOLDER, os.time(), id)
    T.fileName = base .. ".log"
    T.summaryName = base .. "_summary.json"
    pcall(writefile, T.fileName, "")
end

local function line(text)
    table.insert(T.pending, text)
end

local function event(name, data)
    line(string.format("E,%.2f,%s,%s", elapsed(), csvField(name), jsonValue(data)))
end

local function flush()
    if not T.fileName or #T.pending == 0 then return end
    local chunk = table.concat(T.pending, "\n") .. "\n"
    table.clear(T.pending)
    if type(appendfile) == "function" then
        pcall(appendfile, T.fileName, chunk)
    else
        local ok, old = pcall(readfile, T.fileName)
        pcall(writefile, T.fileName, (ok and old or "") .. chunk)
    end
end

----------------------------------------------------------------------------------------------------
-- Remote accounting
----------------------------------------------------------------------------------------------------

local function bucketFor(dir, remote, action)
    local key = dir .. "|" .. remote .. "|" .. action
    local b = T.buckets[key]
    if not b then
        b = {
            dir = dir, remote = remote, action = action,
            n = 0, bytes = 0, maxBytes = 0, dup = 0, ours = 0, peakRate = 0,
            wn = 0, wbytes = 0, wdup = 0, wmax = 0, lastSig = nil, firstAt = elapsed(),
        }
        T.buckets[key] = b
    end
    return b
end

local function record(dir, remote, ours, args)
    if not T.running then return end
    local t0 = os.clock()
    local ok, err = pcall(function()
        local first = args[1]
        local action = if type(first) == "string" then first else typeof(first)
        local name = remote.Name
        if remote.ClassName == "UnreliableRemoteEvent" then name ..= "~u" end
        if remote.ClassName == "RemoteFunction" then name ..= "~f" end
        local bytes = 0
        for i = 1, args.n do
            bytes += argBytes(args[i], 0)
        end
        local sig = if bytes <= CONFIG.SIG_MAX_BYTES then jsonValue(args) else ("#" .. bytes)
        local b = bucketFor(dir, name, csvField(action))
        if b.lastSig == sig then
            b.dup += 1
            b.wdup += 1
        end
        b.lastSig = sig
        b.n += 1
        b.wn += 1
        b.bytes += bytes
        b.wbytes += bytes
        if bytes > b.maxBytes then b.maxBytes = bytes end
        if bytes > b.wmax then b.wmax = bytes end
        if ours then b.ours += 1 end
        local s = T.second
        if dir == "in" then
            s.inN += 1
            s.inB += bytes
        else
            s.outN += 1
            s.outB += bytes
        end
    end)
    if not ok then
        T.errors += 1
        if T.errors <= 20 then event("error", { where = "record", err = tostring(err) }) end
    end
    T.monTime += os.clock() - t0
end

local function watchRemote(inst)
    if T.watched[inst] then return end
    local class = inst.ClassName
    if class ~= "RemoteEvent" and class ~= "UnreliableRemoteEvent" then return end
    T.watched[inst] = true
    table.insert(T.connections, inst.OnClientEvent:Connect(function(...)
        record("in", inst, false, table.pack(...))
    end))
end

local function watchIncoming()
    local roots = { ReplicatedStorage, player }
    local count = 0
    for _, root in ipairs(roots) do
        for _, inst in ipairs(root:GetDescendants()) do
            watchRemote(inst)
            count += 1
        end
        -- Remotes created later: wait before listening so the game's own handler connects first and
        -- receives any queued events (Roblox gives the queue to the first listener only)
        table.insert(T.connections, root.DescendantAdded:Connect(function(inst)
            if inst:IsA("BaseRemoteEvent") then
                task.delay(CONFIG.NEW_REMOTE_DELAY, function()
                    if T.running and inst.Parent then watchRemote(inst) end
                end)
            end
        end))
    end
    return count
end

local function installHook()
    if not CONFIG.HOOK_OUTGOING then return "disabled" end
    if not (hookmetamethod and getnamecallmethod) then return "unsupported" end
    local CLASS_OK = { RemoteEvent = true, UnreliableRemoteEvent = true, RemoteFunction = true }
    local METHOD_OK = { FireServer = true, InvokeServer = true, fireServer = true, invokeServer = true }
    local original
    -- Nothing in here may make a namecall: that would replace the pending method before original()
    local handler = function(self, ...)
        if T.running then
            local method = getnamecallmethod()
            if METHOD_OK[method] and typeof(self) == "Instance" and CLASS_OK[self.ClassName] then
                local ours = if checkcaller then checkcaller() else false
                task.defer(record, "out", self, ours, table.pack(...))
            end
        end
        return original(self, ...)
    end
    original = hookmetamethod(game, "__namecall", if newcclosure then newcclosure(handler) else handler)
    T.originalNamecall = original
    return "installed"
end

----------------------------------------------------------------------------------------------------
-- Workspace churn
----------------------------------------------------------------------------------------------------

local function topModel(inst)
    local node = inst
    for _ = 1, 64 do
        local parent = node.Parent
        if parent == nil then return "?" end
        if parent == workspace then return node.Name end
        node = parent
    end
    return "?"
end

local function onAdded(inst)
    local t0 = os.clock()
    T.second.add += 1
    local w = T.window
    local class = inst.ClassName
    w.addClass[class] = (w.addClass[class] or 0) + 1
    local model = topModel(inst)
    w.addModel[model] = (w.addModel[model] or 0) + 1
    T.monTime += os.clock() - t0
end

local function onRemoving(inst)
    T.second.rem += 1
    local class = inst.ClassName
    T.window.remClass[class] = (T.window.remClass[class] or 0) + 1
end

local function topN(map, n)
    local list = {}
    for k, v in pairs(map) do
        table.insert(list, { k, v })
    end
    table.sort(list, function(a, b) return a[2] > b[2] end)
    local out = {}
    for i = 1, math.min(n, #list) do
        out[list[i][1]] = list[i][2]
    end
    return out
end

----------------------------------------------------------------------------------------------------
-- Environment and render census
----------------------------------------------------------------------------------------------------

local function read(object, prop)
    local ok, value = pcall(function() return object[prop] end)
    if not ok then return nil end
    if typeof(value) == "EnumItem" then return value.Name end
    return value
end

local function connectionCounts()
    if type(getconnections) ~= "function" then return nil end
    local out = {}
    for _, name in ipairs({ "RenderStepped", "Heartbeat", "Stepped", "PreSimulation", "PostSimulation", "PreRender" }) do
        pcall(function()
            out[name] = #getconnections(RunService[name])
        end)
    end
    return out
end

-- Per-frame connections grouped by the script that owns the callback (P line)
local function probeOwners()
    if type(getconnections) ~= "function" then return nil end
    local out = {}
    for _, name in ipairs({ "Heartbeat", "RenderStepped", "Stepped", "PreSimulation" }) do
        local ok, conns = pcall(getconnections, RunService[name])
        if ok then
            local groups = {}
            for _, c in ipairs(conns) do
                local key = "[foreign]"
                local fn = c.Function
                if fn then
                    local okInfo, src, ln = pcall(debug.info, fn, "sl")
                    if okInfo then
                        local short = string.match(tostring(src), "([^%.]+%.[^%.]+)$") or tostring(src)
                        local exec = isexecutorclosure and isexecutorclosure(fn)
                        key = (if exec then "[exec] " else "") .. short .. ":" .. tostring(ln)
                    end
                end
                groups[key] = (groups[key] or 0) + 1
            end
            out[name] = { total = #conns, top = topN(groups, 15) }
        end
    end
    local okEvt, n = pcall(function()
        return #getconnections(ReplicatedStorage.CowGame.Remotes.ClientEvent.OnClientEvent)
    end)
    if okEvt then out.clientEventListeners = n end
    return out
end

local function readEnv()
    local env = { workspace = {}, lighting = {}, effects = {}, client = {} }
    for _, p in ipairs({ "StreamingEnabled", "StreamingTargetRadius", "StreamingMinRadius", "StreamOutBehavior",
        "StreamingIntegrityMode", "ModelStreamingBehavior", "SignalBehavior", "PhysicsSteppingMethod",
        "InterpolationThrottling", "LevelOfDetail", "MeshPartHeadsAndAccessories", "Gravity" }) do
        env.workspace[p] = read(workspace, p)
    end
    for _, p in ipairs({ "Technology", "GlobalShadows", "ShadowSoftness", "EnvironmentDiffuseScale",
        "EnvironmentSpecularScale", "Brightness", "LightingStyle", "PrioritizeLightingQuality" }) do
        env.lighting[p] = read(Lighting, p)
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
            local enabled = read(child, "Enabled")
            env.effects[child.ClassName .. ":" .. child.Name] = if enabled == nil then true else enabled
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        env.terrain = { Decoration = read(terrain, "Decoration"), WaterWaveSize = read(terrain, "WaterWaveSize") }
    end
    pcall(function()
        env.client.qualityLevel = settings().Rendering.QualityLevel.Name
    end)
    pcall(function()
        local ugs = UserSettings():GetService("UserGameSettings")
        env.client.savedQuality = ugs.SavedQualityLevel.Name
        env.client.graphicsMode = read(settings().Rendering, "GraphicsMode")
    end)
    local camera = workspace.CurrentCamera
    if camera then
        env.client.viewport = { camera.ViewportSize.X, camera.ViewportSize.Y }
        env.client.fov = camera.FieldOfView
    end
    env.connections = connectionCounts()
    return env
end

local CENSUS_CLASSES = {
    "BasePart", "MeshPart", "PartOperation", "Model", "Humanoid", "Animator", "Decal", "Texture",
    "SurfaceAppearance", "ParticleEmitter", "Beam", "Trail", "PointLight", "SpotLight", "SurfaceLight",
    "Highlight", "BillboardGui", "SurfaceGui", "Sound", "Attachment", "Constraint", "WeldConstraint",
    "Motor6D", "Script", "LocalScript", "ClickDetector", "ProximityPrompt", "Fire", "Smoke", "Sparkles",
}

local function newCensus()
    local c = { counts = {}, flags = {
        shadowParts = 0, transparentParts = 0, unanchoredParts = 0, touchParts = 0,
        preciseRender = 0, preciseCollision = 0, particleRate = 0, particlesOn = 0, lightsOn = 0,
        lightShadows = 0, billboardsOnTop = 0, soundsPlaying = 0, animTracks = 0, beamsOn = 0, trailsOn = 0,
    }, total = 0 }
    for _, class in ipairs(CENSUS_CLASSES) do
        c.counts[class] = 0
    end
    return c
end

local function censusPart(f, inst)
    if inst.CastShadow and inst.Transparency < 1 then f.shadowParts += 1 end
    if inst.Transparency > 0 and inst.Transparency < 1 then f.transparentParts += 1 end
    if not inst.Anchored then f.unanchoredParts += 1 end
    if inst.CanTouch then f.touchParts += 1 end
    if inst:IsA("MeshPart") then
        if inst.RenderFidelity == Enum.RenderFidelity.Precise then f.preciseRender += 1 end
        if inst.CollisionFidelity == Enum.CollisionFidelity.PreciseConvexDecomposition then f.preciseCollision += 1 end
    end
end

local function censusOther(f, inst)
    if inst:IsA("ParticleEmitter") then
        if inst.Enabled then
            f.particlesOn += 1
            f.particleRate += inst.Rate
        end
    elseif inst:IsA("Light") then
        if inst.Enabled then
            f.lightsOn += 1
            if inst.Shadows then f.lightShadows += 1 end
        end
    elseif inst:IsA("BillboardGui") then
        if inst.AlwaysOnTop and inst.Enabled then f.billboardsOnTop += 1 end
    elseif inst:IsA("Sound") then
        if inst.IsPlaying then f.soundsPlaying += 1 end
    elseif inst:IsA("Animator") then
        f.animTracks += #inst:GetPlayingAnimationTracks()
    elseif inst:IsA("Beam") then
        if inst.Enabled then f.beamsOn += 1 end
    elseif inst:IsA("Trail") then
        if inst.Enabled then f.trailsOn += 1 end
    end
end

local function censusOne(c, inst)
    c.total += 1
    for _, class in ipairs(CENSUS_CLASSES) do
        if inst:IsA(class) then c.counts[class] += 1 end
    end
    if inst:IsA("BasePart") then
        censusPart(c.flags, inst)
    else
        censusOther(c.flags, inst)
    end
end

local function censusGui()
    local gui = { screenGuis = 0, enabledScreenGuis = 0, guiObjects = 0, visibleGuiObjects = 0, viewports = 0 }
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return gui end
    for _, inst in ipairs(playerGui:GetDescendants()) do
        if inst:IsA("ScreenGui") then
            gui.screenGuis += 1
            if inst.Enabled then gui.enabledScreenGuis += 1 end
        elseif inst:IsA("GuiObject") then
            gui.guiObjects += 1
            if inst.Visible then gui.visibleGuiObjects += 1 end
            if inst:IsA("ViewportFrame") then gui.viewports += 1 end
        end
    end
    return gui
end

local function runCensus()
    if T.censusRunning or not T.running then return end
    T.censusRunning = true
    local started = os.clock()
    local ok, err = pcall(function()
        local c = newCensus()
        local list = workspace:GetDescendants()
        for i, inst in ipairs(list) do
            local t0 = os.clock()
            pcall(censusOne, c, inst)
            T.monTime += os.clock() - t0
            if i % CONFIG.CENSUS_CHUNK == 0 then
                task.wait()
                if not T.running then return end
            end
        end
        c.gui = censusGui()
        c.connections = connectionCounts()
        c.seconds = math.round((os.clock() - started) * 100) / 100
        T.lastCensus = c
        line(string.format("C,%.2f,%s", elapsed(), jsonValue(c)))
    end)
    if not ok then event("error", { where = "census", err = tostring(err) }) end
    T.censusRunning = false
end

----------------------------------------------------------------------------------------------------
-- Samples and reports
----------------------------------------------------------------------------------------------------

local SAMPLE_COLUMNS = "t,fps,worstFrameMs,worstHeartbeatMs,heartbeatMs,physicsMs,renderCpuMs,renderGpuMs,"
    .. "frameMs,recvKbps,sendKbps,physRecvKbps,physSendKbps,pingMs,memMb,instances,primitives,moving,"
    .. "contacts,physicsFps,inMsgs,inBytes,outMsgs,outBytes,added,removed,monitorMs"

local REPORT_COLUMNS = "t,dir,remote,action,count,ratePerSec,bytes,avgBytes,maxBytes,dups,oursTotal"

local function num(v, digits)
    if type(v) ~= "number" or v ~= v then return "" end
    return string.format("%." .. (digits or 1) .. "f", v)
end

local function stat(prop)
    local ok, v = pcall(function() return Stats[prop] end)
    return if ok then v else nil
end

local function sample(dt)
    local s = T.second
    local fps = T.frames / dt
    local ping, mem, physFps
    pcall(function() ping = player:GetNetworkPing() * 1000 end)
    pcall(function() mem = Stats:GetTotalMemoryUsageMb() end)
    pcall(function() physFps = workspace:GetRealPhysicsFPS() end)
    local row = {
        num(elapsed(), 2), num(fps), num(T.worstFrame * 1000), num(T.worstHeartbeat * 1000),
        num(stat("HeartbeatTimeMs"), 2), num(stat("PhysicsStepTimeMs"), 2), num((stat("RenderCPUFrameTime") or 0) * 1000, 2),
        num((stat("RenderGPUFrameTime") or 0) * 1000, 2), num((stat("FrameTime") or 0) * 1000, 2), num(stat("DataReceiveKbps"), 2),
        num(stat("DataSendKbps"), 2), num(stat("PhysicsReceiveKbps"), 2), num(stat("PhysicsSendKbps"), 2),
        num(ping), num(mem), tostring(stat("InstanceCount") or ""), tostring(stat("PrimitivesCount") or ""),
        tostring(stat("MovingPrimitivesCount") or ""), tostring(stat("ContactsCount") or ""), num(physFps),
        s.inN, s.inB, s.outN, s.outB, s.add, s.rem, num(T.monTime * 1000 / dt, 2),
    }
    line("S," .. table.concat(row, ","))

    local tot = T.totals
    tot.samples += 1
    tot.inN += s.inN
    tot.inB += s.inB
    tot.outN += s.outN
    tot.outB += s.outB
    tot.add += s.add
    tot.rem += s.rem
    T.fpsSum += fps
    if fps < T.fpsMin then T.fpsMin = fps end
    if T.worstFrame > T.worstFrameEver then T.worstFrameEver = T.worstFrame end
    T.status = string.format("perf %d fps | in %d/s %.1fKB | out %d/s | +%d -%d inst",
        math.floor(fps + 0.5), s.inN, s.inB / 1024, s.outN, s.add, s.rem)

    s.inN, s.inB, s.outN, s.outB, s.add, s.rem = 0, 0, 0, 0, 0, 0
    T.frames, T.worstFrame, T.worstHeartbeat, T.monTime = 0, 0, 0, 0
end

local function report(windowSeconds)
    local t = num(elapsed(), 2)
    for _, b in pairs(T.buckets) do
        if b.wn > 0 then
            local rate = b.wn / windowSeconds
            if rate > b.peakRate then b.peakRate = rate end
            line(string.format("R,%s,%s,%s,%s,%d,%.2f,%d,%.0f,%d,%d,%d", t, b.dir, csvField(b.remote), b.action,
                b.wn, rate, b.wbytes, b.wbytes / b.wn, b.wmax, b.wdup, b.ours))
            b.wn, b.wbytes, b.wdup, b.wmax = 0, 0, 0, 0
        end
    end
    local w = T.window
    if next(w.addClass) or next(w.remClass) then
        line(string.format("W,%s,%s", t, jsonValue({
            addedByClass = topN(w.addClass, 10), addedByModel = topN(w.addModel, 10), removedByClass = topN(w.remClass, 10),
        })))
    end
    table.clear(w.addClass)
    table.clear(w.addModel)
    table.clear(w.remClass)

    local memory = {}
    pcall(function()
        for _, tag in ipairs(Enum.DeveloperMemoryTag:GetEnumItems()) do
            local mb = Stats:GetMemoryUsageMbForTag(tag)
            if mb >= 1 then memory[tag.Name] = math.round(mb * 10) / 10 end
        end
    end)
    line(string.format("M,%s,%s", t, jsonValue(memory)))
end

local function bucketFlags(b, minutes)
    local flags = {}
    if b.peakRate >= CONFIG.FLAG_RATE then
        table.insert(flags, string.format("peak %.1f msgs/s in a %ds window", b.peakRate, CONFIG.REPORT_INTERVAL))
    end
    local avg = b.bytes / math.max(b.n, 1)
    if avg >= CONFIG.FLAG_AVG_BYTES then
        table.insert(flags, string.format("large payload: avg %.0f B, max %d B", avg, b.maxBytes))
    end
    if b.n >= 20 and b.dup / b.n >= CONFIG.FLAG_DUP_RATIO then
        table.insert(flags, string.format("%.0f%% identical to the previous payload", b.dup / b.n * 100))
    end
    if b.ours > 0 then
        table.insert(flags, string.format("%d of %d sent by an executor script, not the game", b.ours, b.n))
    end
    if minutes > 0 and b.bytes / minutes > 50 * 1024 then
        table.insert(flags, string.format("%.0f KB/min", b.bytes / minutes / 1024))
    end
    return flags
end

local function writeSummary(final)
    if not T.summaryName then return end
    local seconds = os.clock() - T.start
    local minutes = seconds / 60
    local list = {}
    for _, b in pairs(T.buckets) do
        table.insert(list, {
            dir = b.dir, remote = b.remote, action = b.action, count = b.n,
            perMinute = math.round(b.n / math.max(minutes, 1 / 60) * 10) / 10,
            peakPerSec = math.round(b.peakRate * 100) / 100,
            bytes = b.bytes, avgBytes = math.round(b.bytes / math.max(b.n, 1)), maxBytes = b.maxBytes,
            duplicates = b.dup, ours = b.ours, flags = bucketFlags(b, minutes),
        })
    end
    table.sort(list, function(a, b) return a.bytes > b.bytes end)
    local tot = T.totals
    local summary = {
        final = final, seconds = math.round(seconds), placeId = game.PlaceId, jobId = game.JobId,
        players = #Players:GetPlayers(),
        client = {
            avgFps = math.round(T.fpsSum / math.max(tot.samples, 1) * 10) / 10,
            minFps = if T.fpsMin == math.huge then nil else math.round(T.fpsMin * 10) / 10,
            worstFrameMs = math.round(T.worstFrameEver * 1000),
        },
        network = {
            inMsgs = tot.inN, inBytes = tot.inB, outMsgs = tot.outN, outBytes = tot.outB,
            inPerSec = math.round(tot.inN / math.max(seconds, 1) * 10) / 10,
            outPerSec = math.round(tot.outN / math.max(seconds, 1) * 10) / 10,
        },
        churn = { added = tot.add, removed = tot.rem },
        remotes = list,
        env = T.env,
        lastCensus = T.lastCensus,
    }
    pcall(writefile, T.summaryName, jsonValue(summary))
end

----------------------------------------------------------------------------------------------------
-- Status label
----------------------------------------------------------------------------------------------------

local function makeLabel()
    if not CONFIG.SHOW_STATUS_LABEL then return end
    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "CowPerfMonitor"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 1000
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromOffset(420, 18)
        label.Position = UDim2.fromOffset(8, 40)
        label.BackgroundTransparency = 0.4
        label.BackgroundColor3 = Color3.new(0, 0, 0)
        label.TextColor3 = Color3.fromRGB(180, 230, 255)
        label.Font = Enum.Font.Code
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = "perf: starting"
        label.Parent = gui
        gui.Parent = if gethui then gethui() else game:GetService("CoreGui")
        T.gui = gui
        T.label = label
    end)
end

----------------------------------------------------------------------------------------------------
-- Lifecycle
----------------------------------------------------------------------------------------------------

local Monitor = {}

function Monitor.Mark(label)
    event("mark", { label = tostring(label) })
end

function Monitor.Census()
    task.spawn(runCensus)
end

function Monitor.Stop()
    if not T.running then return end
    report(math.max(os.clock() - (T.lastReport or T.start), 1))
    event("stop", { seconds = math.round(os.clock() - T.start), errors = T.errors })
    T.running = false
    for _, c in ipairs(T.connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(T.connections)
    -- The hook stays installed but passes straight through once running is false
    flush()
    writeSummary(true)
    if T.gui then pcall(function() T.gui:Destroy() end) end
    if _G.CowPerfMonitor == Monitor then _G.CowPerfMonitor = nil end
end

Monitor.State = T
_G.CowPerfMonitor = Monitor

openLog()
event("start", { placeId = game.PlaceId, jobId = game.JobId, players = #Players:GetPlayers(), canWrite = canWrite })
T.env = readEnv()
event("env", T.env)
line("H,S," .. SAMPLE_COLUMNS)
line("H,R," .. REPORT_COLUMNS)
local watchedCount = watchIncoming()
local hookState = installHook()
event("hooks", { incomingScanned = watchedCount, outgoing = hookState })
makeLabel()

table.insert(T.connections, RunService.RenderStepped:Connect(function(dt)
    T.frames += 1
    if dt > T.worstFrame then T.worstFrame = dt end
end))
table.insert(T.connections, RunService.Heartbeat:Connect(function(dt)
    if dt > T.worstHeartbeat then T.worstHeartbeat = dt end
end))
table.insert(T.connections, workspace.DescendantAdded:Connect(onAdded))
table.insert(T.connections, workspace.DescendantRemoving:Connect(onRemoving))

task.spawn(function()
    local lastSample, lastFlush, lastSummary = os.clock(), os.clock(), os.clock()
    T.lastReport = os.clock()
    local lastCensus = os.clock() - CONFIG.CENSUS_INTERVAL + 5 -- first census after 5 s
    local lastProbe = os.clock() - CONFIG.PROBE_INTERVAL + 10 -- first probe after 10 s
    while T.running do
        task.wait(CONFIG.SAMPLE_INTERVAL)
        if not T.running then break end
        local now = os.clock()
        sample(now - lastSample)
        lastSample = now
        if T.label then T.label.Text = T.status end
        if now - T.lastReport >= CONFIG.REPORT_INTERVAL then
            report(now - T.lastReport)
            T.lastReport = now
        end
        if now - lastProbe >= CONFIG.PROBE_INTERVAL then
            lastProbe = now
            local ok, owners = pcall(probeOwners)
            if ok and owners then line(string.format("P,%.2f,%s", elapsed(), jsonValue(owners))) end
        end
        if now - lastCensus >= CONFIG.CENSUS_INTERVAL then
            lastCensus = now
            task.spawn(runCensus)
        end
        if now - lastFlush >= CONFIG.FLUSH_INTERVAL then
            flush()
            lastFlush = now
        end
        if now - lastSummary >= CONFIG.SUMMARY_INTERVAL then
            writeSummary(false)
            lastSummary = now
        end
    end
end)

print(string.format("[PerfMonitor] running. hook=%s remotes scanned=%d log=%s", hookState, watchedCount,
    tostring(T.fileName)))
