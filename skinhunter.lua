--[[
    Skin Hunter — Server-Hopping Auction Sniper
    Hops through every active server of "POV You Are A Cow Simulator"
    looking for a target SkinId in the auction lots.
    Once all servers are exhausted, waits for the auction to rotate
    before sweeping again.

    Includes Rayfield Gen2 UI with toggles for starting/stopping,
    Skin ID input, webhook input, rejoin button, and a close button.
]]

-- ============================
-- SERVICES
-- ============================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local plr = Players.LocalPlayer

-- ============================
-- SINGLE-INSTANCE & REJOIN DEBOUNCE
-- ============================
if getgenv then
    local now = os.clock()
    -- If another execution occurred less than 4 seconds ago, abort this duplicate execution immediately
    if getgenv()._SkinHunterLastExec and (now - getgenv()._SkinHunterLastExec) < 4 then
        print("[SkinHunter] Duplicate script execution detected within 4s. Aborting duplicate instance.")
        return
    end
    getgenv()._SkinHunterLastExec = now

    -- If a previous instance is registered, trigger its full cleanup
    if getgenv()._SkinHunterCleanup then
        pcall(getgenv()._SkinHunterCleanup)
        getgenv()._SkinHunterCleanup = nil
    end
    if getgenv()._SkinHunterWindow and getgenv()._SkinHunterWindow.Unload then
        pcall(function()
            getgenv()._SkinHunterWindow:Unload()
        end)
        getgenv()._SkinHunterWindow = nil
    end
end

-- ============================
-- EXECUTOR API DETECTION
-- ============================
local queueOnTeleport = (syn and syn.queue_on_teleport)
    or queue_on_teleport
    or queueonteleport
    or (fluxus and fluxus.queue_on_teleport)
    or (getgenv and getgenv().queue_on_teleport)

local httpRequest = (request or http_request or (http and http.request) or (syn and syn.request))

local readFileFunc = readfile
local writeFileFunc = writefile
local isFileFunc = isfile

-- ============================
-- CONSTANTS
-- ============================
local PLACE_ID = (game.PlaceId and game.PlaceId > 0) and game.PlaceId or 82507849398215
local SCRIPT_SOURCE_URL = "https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/main/skinhunter.lua"
local LOT_NAMES = {"Lot1", "Lot2", "Lot3", "Lot4"}

local STATE_FILE = "SkinHunterState.json"
local CONFIG_FILE = "SkinHunterConfig.json"

-- ============================
-- UTILITY & QUEUE HELPERS
-- ============================
local function log(msg)
    print("[SkinHunter] " .. tostring(msg))
end

local function countKeys(tbl)
    if type(tbl) ~= "table" then return 0 end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

local reloadQueued = false
local function queueReload()
    if reloadQueued then return end
    reloadQueued = true
    if queueOnTeleport then
        pcall(function()
            queueOnTeleport(string.format([[
                task.wait(3)
                loadstring(game:HttpGet('%s'))()
            ]], SCRIPT_SOURCE_URL))
        end)
    end
end

-- ============================
-- GUI CLEANUP HELPER
-- Ensures no duplicate Rayfield hubs remain on screen
-- ============================
local function cleanupExistingGuis()
    local containers = {}
    if typeof(gethui) == "function" then
        local s, hui = pcall(gethui)
        if s and hui then table.insert(containers, hui) end
    end
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        if coreGui and not table.find(containers, coreGui) then
            table.insert(containers, coreGui)
        end
    end)
    pcall(function()
        local playerGui = plr and plr:FindFirstChildOfClass("PlayerGui")
        if playerGui and not table.find(containers, playerGui) then
            table.insert(containers, playerGui)
        end
    end)

    for _, container in ipairs(containers) do
        pcall(function()
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("ScreenGui") then
                    local shouldDestroy = false
                    if child.Name == "Rayfield" or child.Name:find("Rayfield") then
                        shouldDestroy = true
                    elseif child:FindFirstChild("Skin Hunter") or child:FindFirstChild("Cow Hub") then
                        shouldDestroy = true
                    else
                        for _, sub in ipairs(child:GetChildren()) do
                            if sub:IsA("Frame") and (sub.Name == "Skin Hunter" or sub.Name == "Cow Hub" or sub.Name == "Rayfield") then
                                shouldDestroy = true
                                break
                            end
                            -- Rayfield window structure check
                            if sub:IsA("Frame") and sub:FindFirstChild("Header") and (sub:FindFirstChild("Tabs") or sub:FindFirstChild("MainContainer")) then
                                shouldDestroy = true
                                break
                            end
                        end
                    end

                    if shouldDestroy then
                        log("Destroyed existing Rayfield ScreenGui: " .. tostring(child.Name))
                        pcall(function() child:Destroy() end)
                    end
                end
            end
        end)
    end
end

-- ============================
-- RUNTIME STATE
-- ============================
local hunterRunning = false
local hunterThread = nil
local scriptConnections = {}
local HunterToggle = nil

-- Forward declarations
local main
local startHunter
local stopHunter
local rejoinServer
local fetchServerList
local getNextCandidateServer
local getRemainingCandidateServers

-- ============================
-- PERSISTENT STATE
-- ============================
local state = {
    visitedServers = {},
    failedServers = {},
    serverQueue = {},
    targetSkinId = "",
    lastAuctionSignatures = {},
    sweepCount = 0,
    found = false,
    hunting = false,
}

-- ============================
-- CONFIGURATION (defaults, overridden by saved config & UI)
-- ============================
local TARGET_SKIN_ID = ""
local WEBHOOK_URL = "https://discord.com/api/webhooks/1558179605590970441/FriRPRhVe5j2wpuBOvT5a2MGYotX8eYHaB7Zij98yZA6Su3WaiKV7JNDrAxU9uP8xslw"
local NOTIFY_ON_HOP = false
local HOP_DELAY = 3
local AUCTION_WAIT_INTERVAL = 30

-- ============================
-- CONFIG & STATE PERSISTENCE
-- ============================
local function loadConfig()
    if not isFileFunc or not readFileFunc then return end
    pcall(function()
        if isFileFunc(CONFIG_FILE) then
            local raw = readFileFunc(CONFIG_FILE)
            local cfg = HttpService:JSONDecode(raw)
            if cfg and type(cfg) == "table" then
                if cfg.targetSkinId and cfg.targetSkinId ~= "" then
                    TARGET_SKIN_ID = cfg.targetSkinId
                end
                if cfg.webhookUrl and cfg.webhookUrl ~= "" then
                    WEBHOOK_URL = cfg.webhookUrl
                end
                if cfg.notifyOnHop ~= nil then
                    NOTIFY_ON_HOP = cfg.notifyOnHop
                end
                if cfg.hunting ~= nil then
                    state.hunting = cfg.hunting
                end
            end
        end
    end)
end

local function saveConfig()
    if not writeFileFunc then return end
    pcall(function()
        writeFileFunc(CONFIG_FILE, HttpService:JSONEncode({
            targetSkinId = TARGET_SKIN_ID,
            webhookUrl = WEBHOOK_URL,
            notifyOnHop = NOTIFY_ON_HOP,
            hunting = hunterRunning,
        }))
    end)
end

local function saveState()
    if not writeFileFunc then return end
    pcall(function()
        state.targetSkinId = TARGET_SKIN_ID
        state.hunting = hunterRunning
        writeFileFunc(STATE_FILE, HttpService:JSONEncode(state))
    end)
end

local function loadState()
    if not isFileFunc or not readFileFunc then return end
    pcall(function()
        if isFileFunc(STATE_FILE) then
            local raw = readFileFunc(STATE_FILE)
            local loaded = HttpService:JSONDecode(raw)
            if loaded and type(loaded) == "table" then
                if TARGET_SKIN_ID == "" and loaded.targetSkinId and loaded.targetSkinId ~= "" then
                    TARGET_SKIN_ID = loaded.targetSkinId
                end
                if loaded.targetSkinId == TARGET_SKIN_ID then
                    state.visitedServers = loaded.visitedServers or {}
                    state.failedServers = loaded.failedServers or {}
                    state.serverQueue = loaded.serverQueue or {}
                    state.lastAuctionSignatures = loaded.lastAuctionSignatures or {}
                    state.sweepCount = loaded.sweepCount or 0
                    state.found = loaded.found or false
                    if loaded.hunting ~= nil then
                        state.hunting = loaded.hunting
                    end
                else
                    log("Target skin changed or new session. Starting fresh sweep.")
                end
            end
        end
    end)
end

-- Load config and state before building UI
loadConfig()
loadState()

-- ============================
-- AUCTION SKINS CATALOGUE
-- (Extracted from ReplicatedStorage.CowGame.Shared.SkinAuctionConfig)
-- ============================
local DEFAULT_AUCTION_SKINS = {
    "AngusCoat",
    "AyrshireCoat",
    "BeltedGallowayCoat",
    "BlueRoanCoat",
    "BrindleCoat",
    "BrownSwissCoat",
    "BubblegumCoat",
    "BumbleCoat",
    "BurgerCoat",
    "CharolaisCoat",
    "ChocolateMilkCoat",
    "CreamHighlandCoat",
    "DinoCoat",
    "DutchBeltedCoat",
    "GuernseyCoat",
    "HerefordCoat",
    "HolsteinCoat",
    "JackOLanternCoat",
    "JerseyCoat",
    "JuicySliceCoat",
    "LovestruckCoat",
    "MatchaLatteCoat",
    "MintChipCoat",
    "MoonWalkerCoat",
    "NeapolitanCoat",
    "NormandeCoat",
    "PandaCoat",
    "PirateCoat",
    "PlushieCoat",
    "RainCloudCoat",
    "RedAngusCoat",
    "RedHolsteinCoat",
    "RoboCoat",
    "SheepCoat",
    "SilverHighlandCoat",
    "SleepyheadCoat",
    "SpaDayCoat",
    "SpeckleParkCoat",
    "UnicornCoat",
}

local function getAuctionSkins()
    local seen = {}
    local skins = {}

    local function add(id)
        if type(id) == "string" and id ~= "" and not seen[id] then
            seen[id] = true
            table.insert(skins, id)
        end
    end

    for _, id in ipairs(DEFAULT_AUCTION_SKINS) do
        add(id)
    end

    -- Discover live or seasonal event auction skins from ReplicatedStorage if available
    pcall(function()
        local cowGame = ReplicatedStorage:FindFirstChild("CowGame")
        local shared = cowGame and cowGame:FindFirstChild("Shared")
        if shared then
            local auctionConfigMod = shared:FindFirstChild("SkinAuctionConfig")
            if auctionConfigMod then
                local cfg = require(auctionConfigMod)
                if type(cfg) == "table" then
                    for _, tbl in ipairs({cfg.HalloweenSkins, cfg.Skins, cfg.LegacySkins, cfg.VersionThreeSkins}) do
                        if type(tbl) == "table" then
                            for _, id in pairs(tbl) do add(id) end
                        end
                    end
                end
            end

            local halloweenMod = shared:FindFirstChild("HalloweenConfig")
            if halloweenMod then
                local hw = require(halloweenMod)
                if type(hw) == "table" and type(hw.AuctionSet) == "table" then
                    for _, id in pairs(hw.AuctionSet) do add(id) end
                end
            end
        end
    end)

    table.sort(skins)
    return skins
end

local AUCTION_SKIN_OPTIONS = getAuctionSkins()

if TARGET_SKIN_ID == "" then
    TARGET_SKIN_ID = AUCTION_SKIN_OPTIONS[1] or "HolsteinCoat"
end

-- ============================
-- RAYFIELD UI
-- Clean up any existing Rayfield hub first to prevent clutter
-- ============================
cleanupExistingGuis()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/gen2'))()

local Window = Rayfield:CreateWindow({
    Name = "Skin Hunter",
    Subtitle = "Server-Hopping Auction Sniper",
    showIconOnly = true,
    theme = "frost",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

if getgenv then
    getgenv()._SkinHunterWindow = Window
    getgenv()._SkinHunterCleanup = function()
        hunterRunning = false
        for _, conn in ipairs(scriptConnections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        table.clear(scriptConnections)
        if Window and Window.Unload then
            pcall(function() Window:Unload() end)
        end
        cleanupExistingGuis()
    end
end

local MainTab = Window:CreateTab({ Name = "Hunter", Icon = 4483362458 })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = 4483362458 })

-- ============================
-- ANTI-AFK & TELEPORT SAFEGUARDS
-- ============================
local idleConn = plr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end)
table.insert(scriptConnections, idleConn)

local teleportInitConn = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == plr then
        log("Teleport failed (" .. tostring(teleportResult) .. "): " .. tostring(errorMessage))
        Window:Notify({
            Title = "Teleport Failed",
            Content = tostring(errorMessage or "Teleport failed. Retrying..."),
            Duration = 5,
        })
    end
end)
table.insert(scriptConnections, teleportInitConn)

-- ============================
-- WEBHOOK & FORMATTING UTILITIES
-- ============================
local function sendWebhook(title, description, color, fields)
    if not httpRequest or not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    pcall(function()
        local embed = {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 0x5865F2,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {["text"] = "Skin Hunter • Server " .. tostring(game.JobId):sub(1, 8)}
        }
        if fields then
            embed["fields"] = fields
        end
        local payload = {["embeds"] = {embed}}
        if color == 0xFF0000 or color == 0xFFD700 then
            payload["content"] = "@everyone"
        end
        httpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

local function formatNumber(n)
    if not n then return "N/A" end
    n = tonumber(n)
    if not n then return "N/A" end
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end

-- ============================
-- REJOIN SERVER
-- ============================
rejoinServer = function()
    log("Rejoining current server: " .. tostring(game.JobId))

    Window:Notify({
        Title = "Rejoining Server",
        Content = "Attempting to reconnect to this server...",
        Duration = 4,
    })

    reloadQueued = false
    queueReload()

    task.spawn(function()
        task.wait(0.5)
        local success, err = pcall(function()
            if #Players:GetPlayers() <= 1 then
                TeleportService:Teleport(PLACE_ID, plr)
            else
                TeleportService:TeleportToPlaceInstance(PLACE_ID, game.JobId, plr)
            end
        end)

        if not success then
            log("TeleportToPlaceInstance failed (" .. tostring(err) .. "), attempting standard Teleport...")
            pcall(function()
                TeleportService:Teleport(PLACE_ID, plr)
            end)
        end
    end)
end

-- ============================
-- AUCTION LOT CHECKER
-- ============================
local function getAuctionData()
    local cowGame = ReplicatedStorage:FindFirstChild("CowGame")
    if not cowGame then
        cowGame = ReplicatedStorage:WaitForChild("CowGame", 10)
    end
    if not cowGame then return nil end

    local skinAuction = cowGame:FindFirstChild("SkinAuction")
    if not skinAuction then
        skinAuction = cowGame:WaitForChild("SkinAuction", 10)
    end
    if not skinAuction then return nil end

    local lots = {}
    for _, lotName in ipairs(LOT_NAMES) do
        local lot = skinAuction:FindFirstChild(lotName)
        if lot then
            local skinId = lot:GetAttribute("SkinId")
            local skinName = lot:GetAttribute("SkinName") or "Unknown"
            local rarity = lot:GetAttribute("Rarity") or "Unknown"
            local scope = lot:GetAttribute("Scope") or "N/A"
            local bid = lot:GetAttribute("Bid")
            local minBid = lot:GetAttribute("MinimumBid")
            local endsAt = lot:GetAttribute("EndsAt")

            if skinId and skinId ~= "" then
                table.insert(lots, {
                    lotName = lotName,
                    skinId = skinId,
                    skinName = skinName,
                    rarity = rarity,
                    scope = scope,
                    bid = bid,
                    minBid = minBid,
                    endsAt = endsAt,
                    signature = tostring(skinId) .. "_" .. tostring(endsAt),
                })
            end
        end
    end
    return lots, skinAuction
end

local function checkForTargetSkin()
    log("Checking auction lots for target skin: " .. TARGET_SKIN_ID)

    local lots = getAuctionData()
    if not lots then
        log("Could not read auction data from this server.")
        return false, nil
    end

    local currentSignatures = {}
    for _, lot in ipairs(lots) do
        currentSignatures[lot.lotName] = lot.signature
        log(string.format("  %s: %s (%s) — %s", lot.lotName, lot.skinName, lot.rarity, lot.skinId))

        if tostring(lot.skinId) == tostring(TARGET_SKIN_ID) then
            log("🎯 TARGET SKIN FOUND! " .. lot.skinName .. " in " .. lot.lotName)

            local endsAtDisplay = "N/A"
            if lot.endsAt then
                endsAtDisplay = "<t:" .. tostring(lot.endsAt) .. ":t> (<t:" .. tostring(lot.endsAt) .. ":R>)"
            end

            sendWebhook(
                "🎯 TARGET SKIN FOUND!",
                "**" .. lot.skinName .. "** was found in the auction!",
                0xFFD700,
                {
                    {["name"] = "Skin ID", ["value"] = "`" .. tostring(lot.skinId) .. "`", ["inline"] = true},
                    {["name"] = "✨ Rarity", ["value"] = "**" .. lot.rarity .. "**", ["inline"] = true},
                    {["name"] = "Lot", ["value"] = lot.lotName, ["inline"] = true},
                    {["name"] = "Current Bid", ["value"] = "🪙 " .. formatNumber(lot.bid), ["inline"] = true},
                    {["name"] = "Minimum Bid", ["value"] = "🪙 " .. formatNumber(lot.minBid), ["inline"] = true},
                    {["name"] = "⏳ Ends At", ["value"] = endsAtDisplay, ["inline"] = true},
                    {["name"] = "🌐 Server", ["value"] = "`" .. tostring(game.JobId) .. "`", ["inline"] = false},
                }
            )

            Window:Notify({
                Title = "🎯 TARGET SKIN FOUND!",
                Content = lot.skinName .. " (" .. lot.rarity .. ") in " .. lot.lotName,
                Duration = 15,
            })

            return true, lot
        end
    end

    state.lastAuctionSignatures = currentSignatures
    return false, nil
end

-- ============================
-- ROBUST SERVER LIST FETCHER
-- Discovers ALL active public servers with automatic pagination & rate-limit handling
-- ============================
fetchServerList = function()
    if not httpRequest then
        log("HTTP requests not supported. Cannot fetch server list.")
        return {}
    end

    local allServers = {}
    local seenIds = {}
    local cursor = ""
    local pageCount = 0
    local maxPages = 10 -- Cap at 10 pages (up to 1,000 servers) to avoid infinite loops

    repeat
        if not hunterRunning then return allServers end

        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100", PLACE_ID)
        if cursor and cursor ~= "" then
            local cleanCursor = cursor:gsub("[\r\n]", "")
            url = url .. "&cursor=" .. cleanCursor
        end

        local responseData = nil
        local retries = 0

        while retries < 3 and not responseData and hunterRunning do
            local success, response = pcall(function()
                return httpRequest({
                    Url = url,
                    Method = "GET",
                    Headers = {
                        ["User-Agent"] = "Roblox/WinInet",
                        ["Accept"] = "application/json",
                    }
                })
            end)

            if success and response and response.Body then
                local decodeOk, data = pcall(function()
                    return HttpService:JSONDecode(response.Body)
                end)

                if decodeOk and data and data.data then
                    responseData = data
                    break
                elseif decodeOk and data and data.errors then
                    log("Roblox API rate limit or error on page " .. tostring(pageCount + 1) .. ". Retrying after delay...")
                    task.wait(2.5 + (retries * 2))
                end
            else
                task.wait(1.5)
            end
            retries = retries + 1
        end

        if responseData and responseData.data then
            for _, s in ipairs(responseData.data) do
                if s.id and not seenIds[s.id] then
                    seenIds[s.id] = true
                    table.insert(allServers, {
                        jobId = s.id,
                        playing = tonumber(s.playing) or 0,
                        maxPlayers = tonumber(s.maxPlayers) or 16,
                    })
                end
            end
            cursor = responseData.nextPageCursor
            pageCount = pageCount + 1
            if cursor and cursor ~= "" then
                task.wait(1) -- Respect Roblox API rate limits
            end
        else
            log("Failed to fetch server page " .. tostring(pageCount + 1) .. " after retries.")
            cursor = nil
        end
    until not cursor or cursor == "" or pageCount >= maxPages or not hunterRunning

    log(string.format("Discovered %d active servers across %d page(s).", #allServers, pageCount))
    return allServers
end

-- ============================
-- QUEUE & CANDIDATE SELECTION
-- Systematically checks ALL servers, prioritizing reachable servers with open slots
-- ============================
getRemainingCandidateServers = function()
    local unvisited = {}
    for _, s in ipairs(state.serverQueue) do
        local id = s.jobId
        if id and id ~= game.JobId and not state.visitedServers[id] and not state.failedServers[id] then
            table.insert(unvisited, s)
        end
    end
    return unvisited
end

getNextCandidateServer = function()
    local unvisited = getRemainingCandidateServers()

    -- If no unvisited servers left in local queue, refresh from Roblox API
    if #unvisited == 0 then
        log("No unvisited servers in local queue. Refreshing full server list from Roblox API...")
        local fresh = fetchServerList()

        local existingMap = {}
        for _, s in ipairs(state.serverQueue) do
            existingMap[s.jobId] = true
        end

        for _, s in ipairs(fresh) do
            if not existingMap[s.jobId] then
                table.insert(state.serverQueue, s)
            end
        end

        if #state.serverQueue == 0 then
            state.serverQueue = fresh
        end
        saveState()

        unvisited = getRemainingCandidateServers()
    end

    if #unvisited == 0 then
        return nil, 0
    end

    -- Sort candidates: Servers with available slots (playing < maxPlayers and playing > 0) come first!
    -- This guarantees high-success joins without getting blocked by full servers.
    table.sort(unvisited, function(a, b)
        local aFree = a.maxPlayers - a.playing
        local bFree = b.maxPlayers - b.playing
        local aJoinable = (aFree > 0 and a.playing > 0)
        local bJoinable = (bFree > 0 and b.playing > 0)

        if aJoinable and not bJoinable then return true end
        if bJoinable and not aJoinable then return false end

        if aFree ~= bFree then
            return aFree > bFree
        end

        return a.playing > b.playing
    end)

    return unvisited[1], #unvisited
end

-- ============================
-- SERVER HOPPING
-- Resilient hopping with failure recovery and automatic candidate advance
-- ============================
local function hopToServer(target)
    if not hunterRunning then return end

    local targetJobId = type(target) == "table" and target.jobId or target
    local playingStr = (type(target) == "table" and target.playing) and tostring(target.playing) or "?"
    local maxPlayersStr = (type(target) == "table" and target.maxPlayers) and tostring(target.maxPlayers) or "?"

    log(string.format("Hopping to server: %s (%s/%s players)...", tostring(targetJobId):sub(1, 8), playingStr, maxPlayersStr))

    -- Mark CURRENT server as visited
    state.visitedServers[game.JobId] = true
    state.hunting = true
    saveState()
    saveConfig()

    reloadQueued = false
    queueReload()

    local remainingCandidates = getRemainingCandidateServers()

    if NOTIFY_ON_HOP then
        sendWebhook(
            "🔄 Server Hop",
            "Skin not found on this server. Hopping to next server...",
            0x5865F2,
            {
                {["name"] = "Servers Checked", ["value"] = tostring(countKeys(state.visitedServers)), ["inline"] = true},
                {["name"] = "Remaining in Queue", ["value"] = tostring(#remainingCandidates), ["inline"] = true},
                {["name"] = "Sweep #", ["value"] = tostring(state.sweepCount), ["inline"] = true},
            }
        )
    end

    Window:Notify({
        Title = "Server Hop",
        Content = string.format("Hopping to %s (%d remaining)...", tostring(targetJobId):sub(1, 8), #remainingCandidates),
        Duration = 3,
    })

    pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, targetJobId, plr)
    end)

    task.wait(10)
    if not hunterRunning then return end

    log("Teleport to " .. tostring(targetJobId):sub(1, 8) .. " didn't transition within 10s. Retrying once...")
    reloadQueued = false
    queueReload()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, targetJobId, plr)
    end)

    task.wait(12)
    if not hunterRunning then return end

    -- Server is unreachable (full, restricted, or closed).
    -- Mark it as failed so we NEVER loop on it again this sweep!
    log("Server " .. tostring(targetJobId):sub(1, 8) .. " is unreachable or full. Skipping to next candidate.")
    state.failedServers[targetJobId] = true
    saveState()

    local nextTarget, remaining = getNextCandidateServer()
    if nextTarget then
        log("Proceeding to next server in queue: " .. tostring(nextTarget.jobId):sub(1, 8))
        hopToServer(nextTarget)
    else
        log("No further specific candidate servers available. Trying fallback random hop...")
        reloadQueued = false
        queueReload()
        pcall(function()
            TeleportService:Teleport(PLACE_ID, plr)
        end)
    end
end

-- ============================
-- AUCTION CHANGE WATCHER
-- ============================
local function waitForAuctionChange(skinAuction)
    log("All servers exhausted. Watching for auction rotation...")

    Window:Notify({
        Title = "⏸ Sweep Complete",
        Content = "All servers checked. Waiting for auction to rotate...",
        Duration = 5,
    })

    sendWebhook(
        "⏸ All Servers Checked",
        "Sweep #" .. tostring(state.sweepCount) .. " complete. Waiting for auction to rotate before next sweep.",
        0xFFA500,
        {
            {["name"] = "Servers Visited", ["value"] = tostring(countKeys(state.visitedServers)), ["inline"] = true},
            {["name"] = "Target Skin", ["value"] = "`" .. TARGET_SKIN_ID .. "`", ["inline"] = true},
        }
    )

    local changed = false
    local watchConns = {}

    if skinAuction then
        for _, lotName in ipairs(LOT_NAMES) do
            local lot = skinAuction:FindFirstChild(lotName)
            if lot then
                local conn = lot:GetAttributeChangedSignal("SkinId"):Connect(function()
                    changed = true
                end)
                table.insert(watchConns, conn)
            end
        end
    end

    local startSignatures = state.lastAuctionSignatures or {}

    while not changed and hunterRunning do
        task.wait(AUCTION_WAIT_INTERVAL)
        if not hunterRunning then break end

        local lots = getAuctionData()
        if lots then
            for _, lot in ipairs(lots) do
                local oldSig = startSignatures[lot.lotName]
                if oldSig and lot.signature ~= oldSig then
                    changed = true
                    log("Auction rotation detected via polling! " .. lot.lotName .. " changed.")
                    break
                end

                if tostring(lot.skinId) == tostring(TARGET_SKIN_ID) then
                    log("🎯 TARGET SKIN APPEARED ON CURRENT SERVER!")

                    local endsAtDisplay = "N/A"
                    if lot.endsAt then
                        endsAtDisplay = "<t:" .. tostring(lot.endsAt) .. ":t> (<t:" .. tostring(lot.endsAt) .. ":R>)"
                    end

                    sendWebhook(
                        "🎯 TARGET SKIN FOUND!",
                        "**" .. lot.skinName .. "** appeared in the auction while waiting!",
                        0xFFD700,
                        {
                            {["name"] = "Skin ID", ["value"] = "`" .. tostring(lot.skinId) .. "`", ["inline"] = true},
                            {["name"] = "✨ Rarity", ["value"] = "**" .. lot.rarity .. "**", ["inline"] = true},
                            {["name"] = "Lot", ["value"] = lot.lotName, ["inline"] = true},
                            {["name"] = "Current Bid", ["value"] = "🪙 " .. formatNumber(lot.bid), ["inline"] = true},
                            {["name"] = "Minimum Bid", ["value"] = "🪙 " .. formatNumber(lot.minBid), ["inline"] = true},
                            {["name"] = "⏳ Ends At", ["value"] = endsAtDisplay, ["inline"] = true},
                        }
                    )

                    Window:Notify({
                        Title = "🎯 TARGET SKIN FOUND!",
                        Content = lot.skinName .. " appeared while waiting!",
                        Duration = 15,
                    })

                    state.found = true
                    state.hunting = false
                    hunterRunning = false
                    saveState()
                    saveConfig()

                    if HunterToggle and HunterToggle.Set then
                        pcall(function() HunterToggle:Set(false) end)
                    end

                    for _, c in ipairs(watchConns) do pcall(function() c:Disconnect() end) end
                    return true
                end
            end
        end

        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end

    for _, c in ipairs(watchConns) do pcall(function() c:Disconnect() end) end

    if not hunterRunning then
        log("Hunter stopped by user during auction wait.")
        return false
    end

    log("Auction changed! Starting new sweep...")
    return false
end

-- ============================
-- MAIN LOOP
-- ============================
main = function()
    if TARGET_SKIN_ID == "" then
        Window:Notify({
            Title = "No Skin ID",
            Content = "Enter a Target Skin ID before starting the hunter.",
            Duration = 4,
        })
        hunterRunning = false
        state.hunting = false
        saveState()
        saveConfig()
        if HunterToggle and HunterToggle.Set then
            pcall(function() HunterToggle:Set(false) end)
        end
        return
    end

    log("=== Skin Hunter Running ===")
    log("Target Skin ID: " .. TARGET_SKIN_ID)
    log("Current Server: " .. tostring(game.JobId))

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(HOP_DELAY)

    if not hunterRunning then return end

    -- 1. Check the CURRENT server first
    local found, lotData = checkForTargetSkin()

    if found then
        state.found = true
        state.hunting = false
        hunterRunning = false
        saveState()
        saveConfig()

        if HunterToggle and HunterToggle.Set then
            pcall(function() HunterToggle:Set(false) end)
        end

        log("✅ Target skin found! Staying on this server.")
        return
    end

    if not hunterRunning then return end

    -- Mark this server as visited
    state.visitedServers[game.JobId] = true
    state.sweepCount = state.sweepCount + (state.sweepCount == 0 and 1 or 0)
    saveState()

    -- 2. Pick next candidate from queue and hop
    local nextCandidate, remainingCount = getNextCandidateServer()

    if not hunterRunning then return end

    if nextCandidate then
        log(string.format("Next target: %s (%s/%s players) | %d remaining in queue", 
            nextCandidate.jobId:sub(1, 8), 
            tostring(nextCandidate.playing), 
            tostring(nextCandidate.maxPlayers), 
            remainingCount
        ))
        hopToServer(nextCandidate)
    else
        -- All servers exhausted — wait for auction rotation
        local totalChecked = countKeys(state.visitedServers)
        log(string.format("All %d available servers exhausted for sweep #%d.", totalChecked, state.sweepCount))

        local _, skinAuction
        local lots
        lots, skinAuction = getAuctionData()

        local foundWhileWaiting = waitForAuctionChange(skinAuction)

        if foundWhileWaiting then
            log("✅ Target skin found while waiting! Staying on this server.")
            state.found = true
            state.hunting = false
            hunterRunning = false
            saveState()
            saveConfig()

            if HunterToggle and HunterToggle.Set then
                pcall(function() HunterToggle:Set(false) end)
            end
            return
        end

        if not hunterRunning then return end

        -- Reset visited servers, failed servers, and server queue for the new sweep
        state.visitedServers = {}
        state.failedServers = {}
        state.serverQueue = {}
        state.sweepCount = state.sweepCount + 1
        saveState()

        log("Starting sweep #" .. tostring(state.sweepCount))

        sendWebhook(
            "🔄 New Sweep Starting",
            "Auction rotated. Beginning sweep #" .. tostring(state.sweepCount) .. " across all servers.",
            0x00FF88
        )

        Window:Notify({
            Title = "New Sweep",
            Content = "Auction rotated. Starting sweep #" .. tostring(state.sweepCount),
            Duration = 3,
        })

        local freshCandidate = getNextCandidateServer()
        if not hunterRunning then return end

        if freshCandidate then
            hopToServer(freshCandidate)
        else
            task.wait(AUCTION_WAIT_INTERVAL)
            if hunterRunning then
                main()
            end
        end
    end
end

-- ============================
-- HUNTER CONTROLLER
-- ============================
startHunter = function(isAutoResume)
    if hunterRunning and hunterThread and coroutine.status(hunterThread) ~= "dead" then
        return
    end

    if TARGET_SKIN_ID == "" then
        Window:Notify({ Title = "No Skin ID", Content = "Enter or select a Target Skin ID first.", Duration = 4 })
        hunterRunning = false
        state.hunting = false
        saveState()
        saveConfig()
        if HunterToggle and HunterToggle.Set then
            pcall(function() HunterToggle:Set(false) end)
        end
        return
    end

    hunterRunning = true
    state.hunting = true
    state.found = false
    saveState()
    saveConfig()

    Window:Notify({
        Title = isAutoResume and "Hunter Auto-Resumed" or "Hunter Started",
        Content = (isAutoResume and "Continuing hunt for " or "Hunting for ") .. TARGET_SKIN_ID .. "...",
        Duration = 3,
    })

    log("Hunter started. Target: " .. TARGET_SKIN_ID)
    hunterThread = task.spawn(main)
end

stopHunter = function()
    hunterRunning = false
    state.hunting = false
    saveState()
    saveConfig()

    Window:Notify({
        Title = "Hunter Stopped",
        Content = "Server hopping halted.",
        Duration = 3,
    })
    log("Hunter stopped by user.")
end

-- ============================
-- UI: MAIN TAB
-- ============================
MainTab:CreateSection({ Name = "Target Configuration" })

local initialSkinSelection = table.find(AUCTION_SKIN_OPTIONS, TARGET_SKIN_ID) and TARGET_SKIN_ID or AUCTION_SKIN_OPTIONS[1]

MainTab:CreateDropdown({
    Name = "Select Target Skin",
    Options = AUCTION_SKIN_OPTIONS,
    CurrentOption = { initialSkinSelection },
    MultipleOptions = false,
    Flag = "Dropdown_TargetSkin",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection and selection ~= "" then
            if TARGET_SKIN_ID ~= selection then
                TARGET_SKIN_ID = selection
                state.visitedServers = {}
                state.failedServers = {}
                state.serverQueue = {}
                state.sweepCount = 0
                state.found = false
                saveConfig()
                saveState()
                Window:Notify({
                    Title = "Target Skin Selected",
                    Content = "Now hunting: " .. selection,
                    Duration = 3,
                })
                log("Selected target skin from dropdown: " .. selection)
            end
        end
    end,
})

MainTab:CreateInput({
    Name = "Custom Skin ID (Manual Override)",
    Placeholder = TARGET_SKIN_ID ~= "" and ("Current: " .. TARGET_SKIN_ID) or "Enter custom SkinId if not in dropdown",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text and Text ~= "" then
            if TARGET_SKIN_ID ~= Text then
                TARGET_SKIN_ID = Text
                state.visitedServers = {}
                state.failedServers = {}
                state.serverQueue = {}
                state.sweepCount = 0
                state.found = false
                saveConfig()
                saveState()
                Window:Notify({ Title = "Skin ID Overridden", Content = "Now hunting: " .. Text, Duration = 3 })
                log("Manually set target skin: " .. Text)
            end
        end
    end,
})

MainTab:CreateSection({ Name = "Server Hopping & Connection" })

local initialHunterValue = (state.hunting == true and not state.found)

HunterToggle = MainTab:CreateToggle({
    Name = "Start Skin Hunter",
    CurrentValue = initialHunterValue,
    Flag = "Toggle_SkinHunter",
    Callback = function(Value)
        if Value then
            if not hunterRunning then
                startHunter(false)
            end
        else
            if hunterRunning then
                stopHunter()
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Notify on Each Hop (Discord)",
    CurrentValue = NOTIFY_ON_HOP,
    Flag = "Toggle_NotifyOnHop",
    Callback = function(Value)
        NOTIFY_ON_HOP = Value
        saveConfig()
    end,
})

MainTab:CreateButton({
    Name = "Rejoin Current Server",
    Callback = function()
        rejoinServer()
    end,
})

MainTab:CreateButton({
    Name = "View Sweep Status & Queue",
    Callback = function()
        local visitedCount = countKeys(state.visitedServers)
        local failedCount = countKeys(state.failedServers)
        local totalInQueue = #state.serverQueue
        local remaining = #getRemainingCandidateServers()

        Window:Notify({
            Title = "Sweep Status #" .. tostring(state.sweepCount),
            Content = string.format("Checked: %d | Remaining: %d | Total Queued: %d (Skipped/Full: %d)", 
                visitedCount, remaining, totalInQueue, failedCount),
            Duration = 6,
        })
    end,
})

MainTab:CreateSection({ Name = "Current Auction" })

MainTab:CreateButton({
    Name = "Check This Server's Auction",
    Callback = function()
        local lots = getAuctionData()
        if not lots or #lots == 0 then
            Window:Notify({ Title = "Auction", Content = "No auction data found on this server.", Duration = 3 })
            return
        end
        for _, lot in ipairs(lots) do
            Window:Notify({
                Title = lot.lotName .. ": " .. lot.skinName,
                Content = lot.rarity .. " — " .. tostring(lot.skinId),
                Duration = 5,
            })
        end
    end,
})

-- ============================
-- UI: SETTINGS TAB
-- ============================
SettingsTab:CreateSection({ Name = "Discord Webhook" })

SettingsTab:CreateInput({
    Name = "Webhook URL",
    Placeholder = WEBHOOK_URL ~= "" and "Saved webhook loaded! Paste to overwrite." or "Paste your Discord Webhook URL here",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text:match("discord%.com/api/webhooks") then
            WEBHOOK_URL = Text
            saveConfig()
            Window:Notify({ Title = "Webhook Saved", Content = "Your webhook URL has been saved.", Duration = 3 })
        else
            Window:Notify({ Title = "Invalid URL", Content = "Please enter a valid Discord webhook URL.", Duration = 3 })
        end
    end,
})

SettingsTab:CreateSection({ Name = "Script Control" })

SettingsTab:CreateButton({
    Name = "Rejoin Current Server",
    Callback = function()
        rejoinServer()
    end,
})

SettingsTab:CreateButton({
    Name = "Reset Visited Servers & Queue",
    Callback = function()
        state.visitedServers = {}
        state.failedServers = {}
        state.serverQueue = {}
        state.sweepCount = 0
        state.found = false
        saveState()
        Window:Notify({ Title = "Reset", Content = "Visited servers & queue cleared. Next sweep checks all servers fresh.", Duration = 3 })
    end,
})

SettingsTab:CreateButton({
    Name = "Close Script & Destroy UI",
    Callback = function()
        hunterRunning = false
        state.hunting = false
        saveState()
        saveConfig()

        if getgenv then
            getgenv()._SkinHunterWindow = nil
            getgenv()._SkinHunterCleanup = nil
            getgenv()._SkinHunterLastExec = nil
        end

        for _, conn in ipairs(scriptConnections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        table.clear(scriptConnections)

        Window:Unload()
        cleanupExistingGuis()
    end,
})

-- ============================
-- AUTO-RESUME HUNTER (AFTER HOP)
-- ============================
if state.hunting and not state.found then
    log("Persisted state indicates hunting was active before hop. Resuming hunter on this server...")
    task.spawn(function()
        task.wait(1)
        if not hunterRunning then
            startHunter(true)
        end
        if HunterToggle and HunterToggle.Set then
            pcall(function()
                HunterToggle:Set(true)
            end)
        end
    end)
end
