--[[
    Automatic activity marks for the perf monitor log. Observation only.

    Adds Mark() lines to the running _G.CowPerfMonitor for:
      - activities seen in ClientEvent traffic (rafting, grazing, crafting, ...): "start" on the first message,
        "end" after GAP seconds without one
      - caravan phases (CowGame.CaravanState Phase attribute)
      - menus: NavigationController tab open / close, and other controllers' IsOpen flags
      - local player string / boolean attribute changes (zone, mode flags), rate limited
      - respawns
    Running it again replaces the previous instance. Stop: _G.CowPerfAutoMark.Stop()
]]

local GAP = 15
local POLL = 1
local ATTR_COOLDOWN = 10

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

if _G.CowPerfAutoMark and _G.CowPerfAutoMark.Stop then pcall(_G.CowPerfAutoMark.Stop) end
local M = { running = true, connections = {}, active = {}, lastAttr = {} }
_G.CowPerfAutoMark = {
    Stop = function()
        M.running = false
        for _, c in ipairs(M.connections) do pcall(function() c:Disconnect() end) end
    end,
    State = M,
}

local function mark(text)
    local monitor = _G.CowPerfMonitor
    if monitor and monitor.Mark then pcall(monitor.Mark, "AUTO " .. text) end
end

local function connect(signal, fn)
    table.insert(M.connections, signal:Connect(fn))
end

-- Activities from ClientEvent message names
local ACTIVITY = {
    RaftingSnapshot = "rafting", RaftRiverLoad = "rafting",
    GrazeResult = "grazing", AuraBiteStarted = "grazing",
    CraftingResult = "crafting",
    Caravan = "caravan traffic",
    FieldEventImpact = "field event",
    RoundPhase = "round",
}

local cowGame = ReplicatedStorage:WaitForChild("CowGame", 30)
local remotes = cowGame and cowGame:FindFirstChild("Remotes")
local clientEvent = remotes and remotes:FindFirstChild("ClientEvent")
if clientEvent then
    connect(clientEvent.OnClientEvent, function(name)
        local activity = type(name) == "string" and ACTIVITY[name]
        if not activity then return end
        if not M.active[activity] then mark(activity .. " start") end
        M.active[activity] = os.clock()
    end)
end

-- Caravan phases
local function watchCaravan(folder)
    if folder.Name ~= "CaravanState" then return end
    connect(folder:GetAttributeChangedSignal("Phase"), function()
        mark(string.format("caravan %s %s", tostring(folder:GetAttribute("Phase")), tostring(folder:GetAttribute("Kind"))))
    end)
end
if cowGame then
    for _, child in ipairs(cowGame:GetChildren()) do watchCaravan(child) end
    connect(cowGame.ChildAdded, watchCaravan)
end

-- Player attributes (strings and booleans only: numbers change too often to be marks)
connect(player.AttributeChanged, function(attr)
    local value = player:GetAttribute(attr)
    local kind = type(value)
    if kind ~= "string" and kind ~= "boolean" and value ~= nil then return end
    local now = os.clock()
    if M.lastAttr[attr] and now - M.lastAttr[attr] < ATTR_COOLDOWN then return end
    M.lastAttr[attr] = now
    mark(string.format("attr %s=%s", attr, tostring(value)))
end)

connect(player.CharacterAdded, function() mark("respawn") end)

-- Controller instances, for menu state
local function findInstance(name)
    local module = player.PlayerScripts:FindFirstChild(name, true)
    if not module or not module:IsA("ModuleScript") then return nil end
    local ok, class = pcall(require, module)
    if not ok or type(class) ~= "table" then return nil end
    for _, t in ipairs(getgc(true)) do
        if type(t) == "table" and t ~= class then
            local mt = getmetatable(t)
            if mt == class or (type(mt) == "table" and rawget(mt, "__index") == class) then return t end
        end
    end
    return nil
end

task.spawn(function()
    local nav = findInstance("NavigationController")
    local others = {}
    for _, name in ipairs({ "SkinAuctionController", "RaftYardController", "PlayerMailController", "GardenController",
        "TownServicesController", "YodelController", "PartyHatController", "TreePollController" }) do
        local c = findInstance(name)
        if c then others[name] = c end
    end
    mark("automark ready nav=" .. tostring(nav ~= nil))
    local lastMenu, lastOpen = nil, {}
    while M.running do
        task.wait(POLL)
        local now = os.clock()
        for activity, at in pairs(M.active) do
            if now - at > GAP then
                M.active[activity] = nil
                mark(activity .. " end")
            end
        end
        if nav then
            local ok, menu = pcall(function()
                local p = nav._store:GetState().Presentation
                return if p.MenuOpen then tostring(p.SelectedTab) else false
            end)
            if ok and menu ~= lastMenu then
                mark(if menu then "menu open " .. menu else "menu closed")
                lastMenu = menu
            end
        end
        for name, c in pairs(others) do
            local open = c.IsOpen == true
            if open ~= (lastOpen[name] or false) then
                lastOpen[name] = open
                mark(string.format("%s %s", name, if open then "open" else "closed"))
            end
        end
    end
end)
