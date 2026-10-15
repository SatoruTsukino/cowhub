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
local SERVERS_API = "https://games.roblox.com/v1/games/%d/servers/0?sortOrder=2&excludeFullGames=true&limit=%d"
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

local function queueReload()
    if queueOnTeleport then
        pcall(function()
            queueOnTeleport(string.format([[
                task.wait(3)
                loadstring(game:HttpGet('%s'))()
            ]], SCRIPT_SOURCE_URL))
        end)
    end
end

-- Prime queue hook immediately on script run
queueReload()

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

-- ============================
-- PERSISTENT STATE
-- ============================
local state = {
    visitedServers = {},
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
local MAX_SERVERS_PER_PAGE = 100

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
-- ============================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/gen2'))()

local Window = Rayfield:CreateWindow({
    Name = "Skin Hunter",
    Subtitle = "Server-Hopping Auction Sniper",
    showIconOnly = true,
    theme = "frost",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

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
-- SERVER LIST FETCHER
-- ============================
local function fetchAllServers()
    if not httpRequest then
        log("HTTP requests not supported. Cannot fetch server list.")
        return {}
    end

    local servers = {}
    local cursor = ""
    local pageCount = 0

    repeat
        if not hunterRunning then return servers end

        local url = string.format(SERVERS_API, PLACE_ID, MAX_SERVERS_PER_PAGE)
        if cursor and cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local success, response = pcall(function()
            return httpRequest({
                Url = url,
                Method = "GET",
            })
        end)

        if success and response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.id and server.id ~= game.JobId then
                        if not state.visitedServers[server.id] then
                            table.insert(servers, {
                                jobId = server.id,
                                playing = server.playing or 0,
                                maxPlayers = server.maxPlayers or 0,
                            })
                        end
                    end
                end
                cursor = data.nextPageCursor
                pageCount = pageCount + 1
            else
                cursor = nil
            end
        else
            log("Failed to fetch server page " .. tostring(pageCount + 1))
            cursor = nil
        end

        if cursor then task.wait(0.5) end
    until not cursor or cursor == ""

    log("Fetched " .. #servers .. " unvisited servers (page count: " .. pageCount .. ")")
    return servers
end

-- ============================
-- SERVER HOPPING
-- ============================
local function hopToServer(jobId)
    if not hunterRunning then return end

    log("Hopping to server: " .. tostring(jobId):sub(1, 8) .. "...")

    state.visitedServers[game.JobId] = true
    state.hunting = true
    saveState()
    saveConfig()

    queueReload()

    if NOTIFY_ON_HOP then
        sendWebhook(
            "🔄 Server Hop",
            "Skin not found. Hopping to next server...",
            0x5865F2,
            {
                {["name"] = "Servers Checked", ["value"] = tostring(countKeys(state.visitedServers)), ["inline"] = true},
                {["name"] = "Sweep #", ["value"] = tostring(state.sweepCount), ["inline"] = true},
            }
        )
    end

    Window:Notify({
        Title = "Server Hop",
        Content = "Skin not here. Hopping to next server...",
        Duration = 2,
    })

    pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, plr)
    end)

    task.wait(10)
    if not hunterRunning then return end

    log("Teleport may have failed. Retrying...")
    queueReload()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, plr)
    end)

    task.wait(15)
    if not hunterRunning then return end

    log("Teleport failed. Trying random server hop...")
    queueReload()
    pcall(function()
        TeleportService:Teleport(PLACE_ID, plr)
    end)
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

    -- 2. Fetch remaining unvisited servers and hop
    local servers = fetchAllServers()

    if not hunterRunning then return end

    if #servers > 0 then
        local target = servers[1]
        log("Next server: " .. target.jobId:sub(1, 8) .. " (" .. target.playing .. "/" .. target.maxPlayers .. " players)")
        hopToServer(target.jobId)
    else
        -- All servers exhausted — wait for auction rotation
        log("No unvisited servers remain.")

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

        -- Reset visited servers for the new sweep
        state.visitedServers = {}
        state.sweepCount = state.sweepCount + 1
        saveState()

        log("Starting sweep #" .. tostring(state.sweepCount))

        sendWebhook(
            "🔄 New Sweep Starting",
            "Auction rotated. Beginning sweep #" .. tostring(state.sweepCount),
            0x00FF88
        )

        Window:Notify({
            Title = "New Sweep",
            Content = "Auction rotated. Starting sweep #" .. tostring(state.sweepCount),
            Duration = 3,
        })

        local freshServers = fetchAllServers()
        if not hunterRunning then return end

        if #freshServers > 0 then
            hopToServer(freshServers[1].jobId)
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
    Name = "Reset Visited Servers",
    Callback = function()
        state.visitedServers = {}
        state.sweepCount = 0
        state.found = false
        saveState()
        Window:Notify({ Title = "Reset", Content = "Visited servers list cleared. Next sweep starts fresh.", Duration = 3 })
    end,
})

SettingsTab:CreateButton({
    Name = "Close Script & Destroy UI",
    Callback = function()
        hunterRunning = false
        state.hunting = false
        saveState()
        saveConfig()

        for _, conn in ipairs(scriptConnections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        table.clear(scriptConnections)

        Window:Unload()
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
