--[[
    Lua heap breakdown. Observation only. Walks getgc(true) in chunks so the client never stalls for long.

    Groups:
      - tables by key shape (up to 6 sorted string keys, or "array" / "mixed"), with total entry counts
      - functions by owning script (debug.info "s")
      - per-type counts (table, function, userdata, thread, ...)
    Entry counts approximate memory share: a table entry is ~16–40 bytes, so the largest shapes are where the heap is.
    Usage: loadstring(readfile("cowhub/perf_heap.lua"))()
    Output: cowhub/perflogs/heap_<time>.json
]]
local HttpService = game:GetService("HttpService")
local CHUNK = 20000
local MAX_TABLE_SCAN = 4096 -- entries counted per table before it is marked "large" and estimated

task.spawn(function()
    local started = os.clock()
    local objects = getgc(true)
    local total = #objects
    local kinds, shapes, funcs = {}, {}, {}
    local entriesTotal, bigTables = 0, {}

    for i = 1, total do
        local o = objects[i]
        objects[i] = nil -- drop our reference as we go
        local kind = type(o)
        kinds[kind] = (kinds[kind] or 0) + 1
        if kind == "table" then
            local n, keys, strKeys, arrayish = 0, {}, 0, true
            for k in next, o do
                n += 1
                if type(k) == "string" then
                    strKeys += 1
                    if #keys < 6 then table.insert(keys, k) end
                    arrayish = false
                elseif type(k) ~= "number" then
                    arrayish = false
                end
                if n >= MAX_TABLE_SCAN then break end
            end
            local shape
            if n == 0 then
                shape = "{}"
            elseif arrayish then
                shape = "array"
            else
                table.sort(keys)
                shape = (if strKeys < n then "mixed:" else "") .. table.concat(keys, ",")
            end
            local s = shapes[shape]
            if not s then
                s = { count = 0, entries = 0 }
                shapes[shape] = s
            end
            s.count += 1
            s.entries += n
            entriesTotal += n
            if n >= MAX_TABLE_SCAN then table.insert(bigTables, shape) end
        elseif kind == "function" then
            local ok, src = pcall(debug.info, o, "s")
            local key = if ok then tostring(src) else "?"
            key = string.match(key, "([^%.]+%.[^%.]+)$") or key
            funcs[key] = (funcs[key] or 0) + 1
        end
        if i % CHUNK == 0 then task.wait() end
    end
    objects = nil

    local function top(map, n, field)
        local list = {}
        for k, v in pairs(map) do
            table.insert(list, { key = k, value = if field then v[field] else v, count = if field then v.count else nil })
        end
        table.sort(list, function(a, b) return a.value > b.value end)
        local out = {}
        for i = 1, math.min(n, #list) do out[i] = list[i] end
        return out
    end

    local shapeTop = top(shapes, 40, "entries")
    for _, s in ipairs(shapeTop) do s.share = math.round(s.value / math.max(entriesTotal, 1) * 1000) / 10 end
    local out = {
        seconds = math.round((os.clock() - started) * 10) / 10,
        objects = total,
        kinds = kinds,
        tableEntries = entriesTotal,
        largeTables = #bigTables,
        shapesByEntries = shapeTop,
        functionsByScript = top(funcs, 30),
        luaHeapMb = math.round(game:GetService("Stats"):GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.LuaHeap)),
    }
    pcall(function()
        if not isfolder("cowhub/perflogs") then makefolder("cowhub/perflogs") end
    end)
    writefile(string.format("cowhub/perflogs/heap_%d.json", os.time()), HttpService:JSONEncode(out))
    if _G.CowPerfMonitor then _G.CowPerfMonitor.Mark("HEAP done") end
end)
