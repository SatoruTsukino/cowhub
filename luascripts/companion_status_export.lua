-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false, -- true: stop the running exporter and exit (nothing new starts)

    SNAPSHOT_EVERY = 5, -- seconds between full snapshots of the equipped companion's record
    PRINT = true, -- also print each status change to the console
}
-- ==========================================================================

-- Companion Status Export
-- Logs the equipped companion's state to cowhub/companionlogs/companion_<time>.jsonl:
--   attr:     every change to a CowCompanion* player attribute (CowCompanionStatus = AskPlay, Affection, ...)
--   snapshot: the companion's profile record (Care.Bond, Care.Needs, Care.Favorites, ...) every SNAPSHOT_EVERY s
-- Profile comes from the game's live Store (Store:GetState().Profile.Companions.Owned[EquippedId]).

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.CompanionStatusExport and type(_G.CompanionStatusExport.destroy) == "function" then
    pcall(_G.CompanionStatusExport.destroy)
end

if SETTINGS.DESTROY then
    return nil
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
while not plr do
    task.wait(0.1)
    plr = Players.LocalPlayer
end

local exporter = { running = true, conns = {}, lines = 0 }
_G.CompanionStatusExport = exporter

local DIR = "cowhub/companionlogs"
local canWrite = type(writefile) == "function" and type(appendfile) == "function"
local path = DIR .. "/companion_" .. os.time() .. ".jsonl"
if canWrite then
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            if not isfolder("cowhub") then makefolder("cowhub") end
            if not isfolder(DIR) then makefolder(DIR) end
        end
        writefile(path, "")
    end)
end

-- JSON-safe copy: non-JSON values become strings, depth-limited, cycles cut
local function sanitize(v, depth, seen)
    local t = type(v)
    if t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return tostring(v) end
        return v
    elseif t == "string" or t == "boolean" or v == nil then
        return v
    elseif t == "table" then
        if depth > 5 or seen[v] then return "<table>" end
        seen[v] = true
        local out = {}
        for k, val in pairs(v) do
            if type(val) ~= "function" then
                out[tostring(k)] = sanitize(val, depth + 1, seen)
            end
        end
        seen[v] = nil
        return out
    end
    return tostring(v)
end

local function emit(ev, data)
    data = data or {}
    data.ev = ev
    data.t = workspace:GetServerTimeNow()
    local ok, line = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then return end
    exporter.lines += 1
    if canWrite then
        pcall(appendfile, path, line .. "\n")
    end
end

local store
local function getProfile()
    if store then
        local ok, state = pcall(function() return store:GetState() end)
        if ok and type(state) == "table" and type(state.Profile) == "table" then return state.Profile end
        store = nil
    end
    if type(getgc) ~= "function" then return nil end
    for _, t in ipairs(getgc(true)) do
        if type(t) == "table" and rawget(t, "Remotes") ~= nil and type(rawget(t, "Store")) == "table" then
            local s = rawget(t, "Store")
            local ok, state = pcall(function() return s:GetState() end)
            if ok and type(state) == "table" and type(state.Profile) == "table" then
                store = s
                return state.Profile
            end
        end
    end
    return nil
end

local function companionAttrs()
    local out = {}
    for name, value in pairs(plr:GetAttributes()) do
        if string.sub(name, 1, 12) == "CowCompanion" then
            out[name] = sanitize(value, 0, {})
        end
    end
    return out
end

local function snapshot()
    local profile = getProfile()
    local comps = profile and profile.Companions
    local id = plr:GetAttribute("CowCompanionId") or (type(comps) == "table" and comps.EquippedId)
    local record = type(comps) == "table" and type(comps.Owned) == "table" and id and comps.Owned[id] or nil
    -- Profile record stores care as Care (the server-side runtime copy is CompanionCare)
    local care = type(record) == "table" and (record.Care or record.CompanionCare) or nil
    emit("snapshot", {
        id = id,
        found = record ~= nil,
        bond = type(care) == "table" and care.Bond or nil,
        attrs = companionAttrs(),
        record = record and sanitize(record, 0, {}) or nil,
    })
end

local lastStatus = plr:GetAttribute("CowCompanionStatus")
exporter.conns[#exporter.conns + 1] = plr.AttributeChanged:Connect(function(name)
    if string.sub(name, 1, 12) ~= "CowCompanion" then return end
    local value = plr:GetAttribute(name)
    emit("attr", { name = name, value = sanitize(value, 0, {}) })
    if SETTINGS.PRINT and name == "CowCompanionStatus" then
        print(string.format("[CompanionStatusExport] status %s -> %s", tostring(lastStatus), tostring(value)))
        lastStatus = value
    end
end)

function exporter.destroy()
    exporter.running = false
    for _, conn in ipairs(exporter.conns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(exporter.conns)
    if _G.CompanionStatusExport == exporter then
        _G.CompanionStatusExport = nil
    end
    print("[CompanionStatusExport] stopped; " .. exporter.lines .. " line(s)" .. (canWrite and (" in " .. path) or ""))
end

emit("start", { attrs = companionAttrs() })
task.spawn(function()
    while exporter.running do
        snapshot()
        task.wait(SETTINGS.SNAPSHOT_EVERY)
    end
end)

print("[CompanionStatusExport] logging to " .. (canWrite and path or "<no file API>") .. "; status now " .. tostring(lastStatus))
return exporter
