--[[
    Graphics A/B test. Measures how much GPU / render CPU time each rendering feature costs on this client.

    Client-local only: every change is a property on this client's copy of the world and is restored when
    the test ends (or on _G.CowPerfAB.Stop()). Fires no remotes.

    Stand still in the area to test. The camera is locked at its current position for the run.
    Windows run as B, V1, B, V2, B, ... so each variant is compared with the baseline windows on both sides.

    Output: cowhub/perflogs/ab_<time>.json  (+ marks in the perf monitor log when it is running)
]]

local CONFIG = {
    FOLDER = "cowhub/perflogs",
    SETTLE = 3,
    MEASURE = 30,
    REAPPLY_INTERVAL = 1,
    LOCK_CAMERA = true,
}

-- Optional overrides: loadstring(readfile("cowhub/perf_ab.lua"))({ measure = 60, label = "field" })
local opts = ...
if type(opts) == "table" then
    CONFIG.MEASURE = tonumber(opts.measure) or CONFIG.MEASURE
    CONFIG.LABEL = opts.label and tostring(opts.label) or nil
    CONFIG.MODE = opts.mode
end

if _G.CowPerfAB and _G.CowPerfAB.Stop then
    pcall(_G.CowPerfAB.Stop)
end

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local VARIANTS
local A = { running = true, saved = {}, results = {}, resets = 0, status = "starting" }

----------------------------------------------------------------------------------------------------
-- Saved properties (restored at the end)
----------------------------------------------------------------------------------------------------

local function save(inst, prop)
    local key = inst
    local entry = A.saved[key]
    if not entry then
        entry = {}
        A.saved[key] = entry
    end
    if entry[prop] == nil then
        local ok, value = pcall(function() return inst[prop] end)
        if ok then entry[prop] = { value = value } end
    end
end

local function set(inst, prop, value)
    save(inst, prop)
    local ok, current = pcall(function() return inst[prop] end)
    if ok and current ~= value then
        pcall(function() inst[prop] = value end)
        return true
    end
    return false
end

local function restoreAll()
    local restored, failed = 0, 0
    for inst, props in pairs(A.saved) do
        for prop, entry in pairs(props) do
            if inst.Parent ~= nil or inst == Lighting then
                local ok = pcall(function() inst[prop] = entry.value end)
                if ok then restored += 1 else failed += 1 end
            end
        end
    end
    table.clear(A.saved)
    return restored, failed
end

----------------------------------------------------------------------------------------------------
-- Variants: apply() changes the world and returns how many properties it changed
----------------------------------------------------------------------------------------------------

local function eachDescendant(root, class, fn)
    local n = 0
    for _, inst in ipairs(root:GetDescendants()) do
        if inst:IsA(class) and fn(inst) then n += 1 end
    end
    return n
end

VARIANTS = {
    {
        name = "GlobalShadows off",
        apply = function()
            return if set(Lighting, "GlobalShadows", false) then 1 else 0
        end,
    },
    {
        name = "CastShadow off (all parts)",
        apply = function()
            return eachDescendant(workspace, "BasePart", function(p)
                return set(p, "CastShadow", false)
            end)
        end,
    },
    {
        name = "Bloom off",
        apply = function()
            return eachDescendant(Lighting, "BloomEffect", function(e) return set(e, "Enabled", false) end)
        end,
    },
    {
        name = "ColorCorrection off",
        apply = function()
            return eachDescendant(Lighting, "ColorCorrectionEffect", function(e) return set(e, "Enabled", false) end)
        end,
    },
    {
        name = "Atmosphere density 0",
        apply = function()
            return eachDescendant(Lighting, "Atmosphere", function(e) return set(e, "Density", 0) end)
        end,
    },
    {
        name = "Point/Spot lights off",
        apply = function()
            return eachDescendant(workspace, "Light", function(l) return set(l, "Enabled", false) end)
        end,
    },
    {
        name = "Beams off",
        apply = function()
            return eachDescendant(workspace, "Beam", function(b) return set(b, "Enabled", false) end)
        end,
    },
    {
        name = "Particles off",
        apply = function()
            return eachDescendant(workspace, "ParticleEmitter", function(e) return set(e, "Enabled", false) end)
        end,
    },
}

-- Quality sweep: opts.mode = "quality" replaces the variants with fixed graphics quality levels.
-- QualityLevel is not an instance property, so it is saved and restored here rather than through save()/set().
if CONFIG.MODE == "quality" then
    local rendering = settings().Rendering
    local original = rendering.QualityLevel
    A.restoreQuality = function()
        pcall(function() rendering.QualityLevel = original end)
    end
    VARIANTS = {}
    for _, level in ipairs({ 1, 3, 5, 7, 10 }) do
        local item = Enum.QualityLevel["Level" .. string.format("%02d", level)]
        table.insert(VARIANTS, {
            name = "Quality " .. level,
            apply = function()
                if rendering.QualityLevel ~= item then
                    rendering.QualityLevel = item
                    return 1
                end
                return 0
            end,
        })
    end
    A.originalQuality = original.Name
end

----------------------------------------------------------------------------------------------------
-- Measurement
----------------------------------------------------------------------------------------------------

local function stat(prop)
    local ok, v = pcall(function() return Stats[prop] end)
    return if ok and type(v) == "number" then v else nil
end

local function summarize(list)
    if #list == 0 then return nil end
    table.sort(list)
    local sum = 0
    for _, v in ipairs(list) do sum += v end
    local function at(p) return list[math.clamp(math.floor(#list * p + 0.5), 1, #list)] end
    return {
        mean = math.round(sum / #list * 1000) / 1000,
        p50 = math.round(at(0.5) * 1000) / 1000,
        p95 = math.round(at(0.95) * 1000) / 1000,
        n = #list,
    }
end

local function mark(text)
    local monitor = _G.CowPerfMonitor
    if monitor and monitor.Mark then pcall(monitor.Mark, "AB " .. text) end
end

local function measureWindow(name, apply)
    local changed = 0
    if apply then changed = apply() end
    local settleEnd = os.clock() + CONFIG.SETTLE
    while os.clock() < settleEnd and A.running do task.wait() end
    if not A.running then return nil end
    mark(name .. " start")

    local gpu, cpu, frame, dts = {}, {}, {}, {}
    local resets = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        table.insert(dts, dt * 1000)
        local g, c, f = stat("RenderGPUFrameTime"), stat("RenderCPUFrameTime"), stat("FrameTime")
        if g then table.insert(gpu, g * 1000) end
        if c then table.insert(cpu, c * 1000) end
        if f then table.insert(frame, f * 1000) end
    end)
    local measureEnd = os.clock() + CONFIG.MEASURE
    local nextReapply = os.clock() + CONFIG.REAPPLY_INTERVAL
    while os.clock() < measureEnd and A.running do
        task.wait()
        if apply and os.clock() >= nextReapply then
            nextReapply = os.clock() + CONFIG.REAPPLY_INTERVAL
            local again = apply()
            if again > 0 then resets += again end
        end
    end
    conn:Disconnect()
    A.resets += resets
    mark(name .. " end")
    local fpsList = {}
    for _, d in ipairs(dts) do fpsList[#fpsList + 1] = 1000 / math.max(d, 0.001) end
    return {
        name = name,
        changed = changed,
        reapplied = resets,
        gpuMs = summarize(gpu),
        cpuMs = summarize(cpu),
        frameMs = summarize(frame),
        dtMs = summarize(dts),
        fps = summarize(fpsList),
        primitives = stat("PrimitivesCount"),
        instances = stat("InstanceCount"),
    }
end

----------------------------------------------------------------------------------------------------
-- Run
----------------------------------------------------------------------------------------------------

local function ensureFolder()
    pcall(function()
        if not isfolder("cowhub") then makefolder("cowhub") end
        if not isfolder(CONFIG.FOLDER) then makefolder(CONFIG.FOLDER) end
    end)
end

local function delta(variant, before, after)
    local function d(key)
        if not (variant[key] and before[key] and after[key]) then return nil end
        local base = (before[key].mean + after[key].mean) / 2
        return {
            base = math.round(base * 100) / 100,
            variant = math.round(variant[key].mean * 100) / 100,
            delta = math.round((variant[key].mean - base) * 100) / 100,
            baseSpread = math.round(math.abs(before[key].mean - after[key].mean) * 100) / 100,
        }
    end
    return { name = variant.name, changed = variant.changed, reapplied = variant.reapplied,
        gpu = d("gpuMs"), cpu = d("cpuMs"), frame = d("frameMs"), dt = d("dtMs") }
end

local fileName

local function writeResults(final)
    if not fileName then return end
    local deltas = {}
    local windows = A.results
    for i = 2, #windows - 1, 2 do
        if windows[i] and windows[i - 1] and windows[i + 1] then
            table.insert(deltas, delta(windows[i], windows[i - 1], windows[i + 1]))
        end
    end
    local out = {
        final = final, placeId = game.PlaceId, jobId = game.JobId, startedAt = A.startedAt,
        position = A.position, viewport = A.viewport, quality = A.quality, resets = A.resets,
        restore = A.restore, originalQuality = A.originalQuality, label = CONFIG.LABEL, measure = CONFIG.MEASURE, deltas = deltas, windows = windows,
    }
    pcall(writefile, fileName, HttpService:JSONEncode(out))
end

local Test = {}

function Test.Stop()
    if not A.running then return end
    A.running = false
end

local function run()
    ensureFolder()
    fileName = string.format("%s/ab_%d_%s.json", CONFIG.FOLDER, os.time(), string.sub(HttpService:GenerateGUID(false), 1, 6))
    A.startedAt = os.time()
    local camera = workspace.CurrentCamera
    pcall(function()
        A.viewport = { camera.ViewportSize.X, camera.ViewportSize.Y }
        A.quality = settings().Rendering.QualityLevel.Name
        local p = camera.CFrame.Position
        A.position = { math.round(p.X), math.round(p.Y), math.round(p.Z) }
    end)
    A.cameraType = camera and camera.CameraType
    if CONFIG.LOCK_CAMERA and camera then
        local cf = camera.CFrame
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = cf
        A.cameraConn = RunService.RenderStepped:Connect(function()
            if camera.CameraType ~= Enum.CameraType.Scriptable then camera.CameraType = Enum.CameraType.Scriptable end
            camera.CFrame = cf
        end)
    end
    mark("run start")

    local ok, err = pcall(function()
        table.insert(A.results, measureWindow("baseline", nil))
        for i, v in ipairs(VARIANTS) do
            if not A.running then break end
            A.status = string.format("%d/%d %s", i, #VARIANTS, v.name)
            local result = measureWindow(v.name, v.apply)
            restoreAll()
            if A.restoreQuality then A.restoreQuality() end
            if not result then break end
            table.insert(A.results, result)
            local base = measureWindow("baseline", nil)
            if not base then break end
            table.insert(A.results, base)
            writeResults(false)
        end
    end)
    if not ok then A.error = tostring(err) end

    if A.cameraConn then A.cameraConn:Disconnect() end
    local restored, failed = restoreAll()
    if A.restoreQuality then A.restoreQuality() end
    pcall(function() camera.CameraType = A.cameraType or Enum.CameraType.Custom end)
    A.restore = { restored = restored, failed = failed, error = A.error }
    mark("run end")
    A.running = false
    A.status = "done"
    writeResults(true)
    if _G.CowPerfAB == Test then _G.CowPerfAB = nil end
end

Test.State = A
_G.CowPerfAB = Test
task.spawn(run)
print(string.format("[PerfAB] running %d variants, ~%d s", #VARIANTS,
    (#VARIANTS * 2 + 1) * (CONFIG.SETTLE + CONFIG.MEASURE)))
