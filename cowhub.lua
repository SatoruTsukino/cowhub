-- 1. The Server-Hop Queue Hook
local queueOnTeleport = (queue_on_teleport or syn and syn.queue_on_teleport)
if queueOnTeleport then
    pcall(function()
        queueOnTeleport([[
            task.wait(3)
            loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/main/cowhub.lua'))()
        ]])
    end)
end

-- 2. Build the Hub
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/gen2'))()

local Window = Rayfield:CreateWindow({
    Name = "Cow Hub",
    Subtitle = "by Gemini & I",
    showIconOnly = true,
    theme = "rose",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false
})

-- ==========================
-- SERVICES, VARIABLES & CACHING
-- ==========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager") or game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local m_abs = math.abs
local m_sin = math.sin
local m_cos = math.cos
local m_random = math.random
local v3 = Vector3.new

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

-- ==========================
-- ANTI-AFK (Runs on Load)
-- ==========================
plr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Farming Variables
local farmOn = false
local autoChomp = false
local autoChompMobs = false
local autoFish = false
local anchorPos = nil
local pattern = "Guided Zigzag (Nodes)"
local patternSpeed = 1.0
local patternTimer = 0
local nextRandomPos = nil
local farmRadius = 75
local mobAuraRadius = 10
local mobAuraDelay = 0.5
local lastMoveTime = 0 
local HeartbeatConnection = nil

-- Pen ESP Variables
local showPenESP = false
local penVisualizer = nil

-- Dynamic Team Chest ESP Variables
local showChestESP = false
local chestHighlight = nil
local chestBillboard = nil
local chestEspConnection = nil
local chestChildAddedConn = nil
local chestChildRemovedConn = nil

-- Node Pathfinding Variables
local nodeBlacklist = {}
local currentTargetNode = nil

-- Chomp & Aura Variables
local chompEvent = ReplicatedStorage:WaitForChild("CowGame"):WaitForChild("Remotes"):WaitForChild("ChompRequest")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local lastChompedNode = ""
local chompCooldown = 0
local lastChompedMob = ""
local mobChompCooldown = 0

-- Background Caching Variables
local fishingSpotsFolder = workspace:WaitForChild("Fishing Spots")
local castCooldown = 0
local activeRipples = {}
local activeAuraMobs = {}
local lastBackgroundCacheTime = 0

-- Spammer Variables
local spamThreads = {E = 0, Q = 0}

-- Scanner & File System Variables
local skinAuction = ReplicatedStorage:WaitForChild("CowGame"):WaitForChild("SkinAuction")
local lotNames = {"Lot1", "Lot2", "Lot3", "Lot4"}
local httpRequest = (request or http_request or (http and http.request) or syn and syn.request)

local previousAuctionSignatures = {} 
local scannerRunning = false
local auctionConnections = {}

-- FPS Variables
local fpsCapEnabled = false
local currentFpsCap = 60

local rarityColors = {
    ["Common"] = 0xB0BEC5,
    ["Uncommon"] = 0x66BB6A,
    ["Rare"] = 0x42A5F5,
    ["Super Rare"] = 0xAB47BC,
    ["Mythic"] = 0xFF5252,
    ["Unique"] = 0xFFD700,
    ["Unrated"] = 0xFFFFFF,
    ["Default"] = 0x5865F2
}

-- ==========================
-- FILE SAVING SYSTEM
-- ==========================
local configFileName = "CowScannerWebhook.txt"

local function loadWebhook()
    if isfile and readfile and isfile(configFileName) then
        local success, result = pcall(function() return readfile(configFileName) end)
        if success and result then return result end
    end
    return ""
end

local function saveWebhook(url)
    if writefile then
        pcall(function() writefile(configFileName, url) end)
    end
end

local WEBHOOK_URL = loadWebhook()

-- ==========================
-- HELPER FUNCTIONS
-- ==========================
local function get2DDistance(p1, p2)
    return (v3(p1.X, 0, p1.Z) - v3(p2.X, 0, p2.Z)).Magnitude
end

-- Unified background caching for ripples and Aura Mobs (Snakes & Spiders)
local function cacheBackgroundElements()
    -- 1. Cache Water Ripples
    local newRipples = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if string.match(v.Name, "CowFishingWaterRipples") then
            table.insert(newRipples, v)
        end
    end
    activeRipples = newRipples
    
    -- 2. Cache Aura Mobs (Snakes & Spiders)
    local newMobs = {}
    local cowWorld = workspace:FindFirstChild("CowWorld")
    local resources = cowWorld and cowWorld:FindFirstChild("FjordRafting") and cowWorld.FjordRafting:FindFirstChild("Resources")
    
    if resources then
        for _, v in ipairs(resources:GetDescendants()) do
            if (string.match(v.Name, "Snake") or string.match(v.Name, "Spider")) and (v:IsA("Model") or v:IsA("BasePart")) then
                table.insert(newMobs, v)
            end
        end
    end
    activeAuraMobs = newMobs
end

local function isSpotAvailable(spot)
    local spotPos = spot:IsA("Model") and spot:GetPivot().Position or spot.Position
    
    for _, ripple in ipairs(activeRipples) do
        if ripple.Parent then 
            local ripplePos = ripple:IsA("Model") and ripple:GetPivot().Position or (ripple:IsA("BasePart") and ripple.Position)
            
            if ripplePos and (spotPos - ripplePos).Magnitude <= 5 then
                local surfaceGui = ripple:FindFirstChild("FishingWaterSurface")
                if surfaceGui and surfaceGui.Enabled then
                    return true
                end
            end
        end
    end
    return false
end

local function updatePenVisualizer()
    if showPenESP and farmOn and anchorPos then
        if not penVisualizer then
            penVisualizer = Instance.new("Part")
            penVisualizer.Name = "CowPenESP"
            penVisualizer.Anchored = true
            penVisualizer.CanCollide = false
            penVisualizer.Shape = Enum.PartType.Cylinder
            penVisualizer.Material = Enum.Material.Neon
            penVisualizer.Color = Color3.fromRGB(255, 105, 180) 
            penVisualizer.Transparency = 0.85
            penVisualizer.CastShadow = false
            penVisualizer.Parent = workspace
        end
        penVisualizer.Size = v3(0.5, farmRadius * 2, farmRadius * 2)
        penVisualizer.CFrame = CFrame.new(anchorPos) * CFrame.Angles(0, 0, math.rad(90))
    else
        if penVisualizer then
            penVisualizer:Destroy()
            penVisualizer = nil
        end
    end
end

-- Cleanup single-chest ESP instances
local function cleanupChestVisuals()
    if chestEspConnection then
        chestEspConnection:Disconnect()
        chestEspConnection = nil
    end
    if chestHighlight then
        chestHighlight:Destroy()
        chestHighlight = nil
    end
    if chestBillboard then
        chestBillboard:Destroy()
        chestBillboard = nil
    end
end

-- Attach ESP to a loaded chest model/part
local function attachChestESP(trackedChest)
    cleanupChestVisuals()
    if not trackedChest or not trackedChest.Parent then return end

    chestHighlight = Instance.new("Highlight")
    chestHighlight.Name = "ChestHighlight"
    chestHighlight.Adornee = trackedChest
    chestHighlight.FillColor = Color3.fromRGB(255, 215, 0)
    chestHighlight.FillTransparency = 0.5
    chestHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    chestHighlight.OutlineTransparency = 0
    chestHighlight.Parent = trackedChest

    chestBillboard = Instance.new("BillboardGui")
    chestBillboard.Name = "ChestESPText"
    chestBillboard.Adornee = trackedChest:IsA("Model") and trackedChest.PrimaryPart or trackedChest:FindFirstChildWhichIsA("BasePart")
    chestBillboard.Size = UDim2.new(0, 150, 0, 50)
    chestBillboard.StudsOffset = Vector3.new(0, 3, 0)
    chestBillboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "Team Chest"
    textLabel.Parent = chestBillboard

    chestBillboard.Parent = trackedChest

    chestEspConnection = RunService.RenderStepped:Connect(function()
        if not showChestESP or not trackedChest or not trackedChest.Parent then
            cleanupChestVisuals()
            return
        end
        local chestPart = trackedChest:IsA("Model") and trackedChest.PrimaryPart or trackedChest:FindFirstChildWhichIsA("BasePart")
        if root and chestPart and textLabel then
            local dist = math.floor((root.Position - chestPart.Position).Magnitude)
            textLabel.Text = "📦 Team Chest\n[" .. tostring(dist) .. " studs]"
        end
    end)
end

-- Dynamic load/unload watcher for LocalTeamChest
local function updateChestESP()
    if showChestESP then
        local currentChest = workspace:FindFirstChild("LocalTeamChest")
        if currentChest then
            attachChestESP(currentChest)
        end

        if not chestChildAddedConn then
            chestChildAddedConn = workspace.ChildAdded:Connect(function(child)
                if child.Name == "LocalTeamChest" and showChestESP then
                    task.wait(0.1) -- Allow model parts/PrimaryPart to replicate
                    attachChestESP(child)
                end
            end)
        end

        if not chestChildRemovedConn then
            chestChildRemovedConn = workspace.ChildRemoved:Connect(function(child)
                if child.Name == "LocalTeamChest" then
                    cleanupChestVisuals()
                end
            end)
        end
    else
        if chestChildAddedConn then
            chestChildAddedConn:Disconnect()
            chestChildAddedConn = nil
        end
        if chestChildRemovedConn then
            chestChildRemovedConn:Disconnect()
            chestChildRemovedConn = nil
        end
        cleanupChestVisuals()
    end
end

local function HandleSpam(keyName, state, delayTime)
    spamThreads[keyName] = spamThreads[keyName] + 1
    local currentThread = spamThreads[keyName]
    delayTime = delayTime or 0.05
    
    if state then
        task.spawn(function()
            local keyCode = Enum.KeyCode[keyName]
            while spamThreads[keyName] == currentThread do
                VirtualInput:SendKeyEvent(true, keyCode, false, game)
                task.wait(delayTime)
                VirtualInput:SendKeyEvent(false, keyCode, false, game)
                task.wait(delayTime)
            end
        end)
    end
end

local function formatNumber(n)
    if not n then return "N/A" end
    local formatted = tostring(n)
    while true do  
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

local function checkAuctionLots()
    if not httpRequest or WEBHOOK_URL == "" then return end

    for _, lotName in ipairs(lotNames) do
        local lot = skinAuction:FindFirstChild(lotName)
        
        if lot then
            local currentSkinId = lot:GetAttribute("SkinId")
            local endsAt = lot:GetAttribute("EndsAt")
            
            local currentSignature = tostring(currentSkinId) .. "_" .. tostring(endsAt)
            
            if currentSkinId and currentSkinId ~= "" and currentSignature ~= previousAuctionSignatures[lotName] then
                
                previousAuctionSignatures[lotName] = currentSignature

                local skinName = lot:GetAttribute("SkinName") or "Unknown Skin"
                local rarity = lot:GetAttribute("Rarity") or "Default"
                local scope = lot:GetAttribute("Scope") or "N/A"
                local bid = lot:GetAttribute("Bid")
                local minBid = lot:GetAttribute("MinimumBid")
                
                local embedColor = rarityColors[rarity] or rarityColors["Default"]
                
                local endsAtDisplay = "N/A"
                if endsAt then
                    endsAtDisplay = "<t:" .. tostring(endsAt) .. ":t> (<t:" .. tostring(endsAt) .. ":R>)"
                end

                local embed = {
                    ["title"] = "Skin : " .. tostring(skinName),
                    ["color"] = embedColor,
                    ["fields"] = {
                        {["name"] = "Skin", ["value"] = "`" .. tostring(currentSkinId) .. "`", ["inline"] = true},
                        {["name"] = "✨ Rarity", ["value"] = "**" .. tostring(rarity) .. "**", ["inline"] = true},
                        {["name"] = "Scope", ["value"] = tostring(scope), ["inline"] = true},
                        {["name"] = "Current Bid", ["value"] = "🪙 " .. formatNumber(bid), ["inline"] = true},
                        {["name"] = "Minimum Bid", ["value"] = "🪙 " .. formatNumber(minBid), ["inline"] = true},
                        {["name"] = "⏳ Ends At", ["value"] = endsAtDisplay, ["inline"] = true}
                    },
                    ["footer"] = {["text"] = "Auction Scanner • " .. os.date("%X")}
                }

                local payload = { ["embeds"] = {embed} }

                if rarity == "Super Rare" or rarity == "Mythic" or rarity == "Unique" then
                    payload["content"] = "@everyone 🚨 **High-tier skin detected in auction!**"
                end

                httpRequest({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })
                
                payload = nil
                embed = nil
                
                task.wait(0.5) 
            end
        end
    end
end

local function updateHeartbeatConnection()
    if farmOn or autoChomp or autoFish or autoChompMobs then
        if not HeartbeatConnection then
            HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
                if not root or not humanoid then return end

                local grassFolder = workspace:FindFirstChild("CowVirtualGrass")

                -- Keep background caches fresh every 1 second
                if tick() - lastBackgroundCacheTime > 1 then
                    task.spawn(cacheBackgroundElements)
                    lastBackgroundCacheTime = tick()
                end

                -- 1. Movement Logic
                if farmOn and anchorPos then
                    patternTimer = patternTimer + (dt * patternSpeed)
                    local targetPos

                    if pattern == "Guided Zigzag (Nodes)" then
                        local ghostX = m_sin(patternTimer * 1.3) * farmRadius
                        local ghostZ = m_cos(patternTimer * 1.9) * farmRadius
                        local ghostPos = anchorPos + v3(ghostX, 0, ghostZ)

                        local needNewNode = false
                        
                        if not currentTargetNode or not currentTargetNode.Parent then
                            needNewNode = true
                        else
                            local tPos = currentTargetNode:IsA("Model") and currentTargetNode:GetPivot().Position or currentTargetNode.Position
                            if get2DDistance(root.Position, tPos) < 4 then
                                needNewNode = true
                            end
                        end
                        
                        if needNewNode then
                            local nearestDist = math.huge
                            local nearestNode = nil
                            
                            if grassFolder then
                                for _, node in ipairs(grassFolder:GetChildren()) do
                                    local cleanName = string.gsub(node.Name, "GrassVisual", "")
                                    cleanName = string.gsub(cleanName, "^_+", "")
                                    cleanName = string.gsub(cleanName, "_+$", "")
                                    
                                    if string.match(cleanName, ".*Grass.*_[np%-]?%d+_[np%-]?%d+$") then
                                        local nodePos = node:IsA("Model") and node:GetPivot().Position or node.Position
                                        
                                        if get2DDistance(anchorPos, nodePos) <= farmRadius then
                                            local distFromGhost = get2DDistance(ghostPos, nodePos)
                                            
                                            if distFromGhost < nearestDist and (not nodeBlacklist[node] or tick() - nodeBlacklist[node] > 10) then
                                                nearestDist = distFromGhost
                                                nearestNode = node
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if nearestNode then
                                currentTargetNode = nearestNode
                                nodeBlacklist[nearestNode] = tick()
                            else
                                currentTargetNode = nil
                                if not nextRandomPos or get2DDistance(root.Position, nextRandomPos) < 5 then
                                    local angle = m_random() * math.pi * 2
                                    nextRandomPos = anchorPos + v3(m_cos(angle) * farmRadius, 0, m_sin(angle) * farmRadius)
                                end
                            end
                        end
                        
                        if currentTargetNode then 
                            targetPos = currentTargetNode:IsA("Model") and currentTargetNode:GetPivot().Position or currentTargetNode.Position
                        else
                            targetPos = nextRandomPos
                        end

                    elseif pattern == "Circle" then
                        local currentRadius = farmRadius * m_abs(m_sin(patternTimer * 0.2))
                        local angle = patternTimer * 1.5
                        targetPos = anchorPos + v3(m_cos(angle) * currentRadius, 0, m_sin(angle) * currentRadius)
                        
                    elseif pattern == "Square" then
                        targetPos = anchorPos + v3(m_sin(patternTimer * 1.8) * farmRadius, 0, m_cos(patternTimer * 0.2) * farmRadius)
                        
                    elseif pattern == "Zigzag" then
                        targetPos = anchorPos + v3(m_sin(patternTimer * 1.3) * farmRadius, 0, m_cos(patternTimer * 1.9) * farmRadius)
                        
                    elseif pattern == "Random" then
                        if not nextRandomPos or get2DDistance(root.Position, nextRandomPos) < 5 then
                            local angle = m_random() * math.pi * 2
                            nextRandomPos = anchorPos + v3(m_cos(angle) * farmRadius, 0, m_sin(angle) * farmRadius)
                        end
                        targetPos = nextRandomPos
                    end

                    if targetPos and tick() - lastMoveTime > 0.033 then
                        local offset2D = v3(targetPos.X - anchorPos.X, 0, targetPos.Z - anchorPos.Z)
                        if offset2D.Magnitude > farmRadius then
                            local clampedOffset = offset2D.Unit * farmRadius
                            targetPos = v3(anchorPos.X + clampedOffset.X, targetPos.Y, anchorPos.Z + clampedOffset.Z)
                        end
                        
                        humanoid:MoveTo(targetPos)
                        lastMoveTime = tick()
                    end
                end

                local prioritizedMobThisFrame = false

                -- 2. Priority Mob Aura Logic (Adjustable Radius, Speed, and Auto-Align)
                if autoChompMobs then
                    for _, mob in ipairs(activeAuraMobs) do
                        if mob.Parent then
                            local mobPos = mob:IsA("Model") and mob:GetPivot().Position or mob.Position
                            if mobPos and (root.Position - mobPos).Magnitude <= mobAuraRadius then
                                local formattedMobName = string.gsub(mob.Name, "(%a+)(%d+)", "%1_%2")
                                local payloadName = ""
                                
                                if string.match(mob.Name, "Spider") then
                                    payloadName = "Cavern_Mob_" .. formattedMobName
                                else
                                    payloadName = "Fjord_Mob_" .. formattedMobName
                                end
                                
                                if payloadName ~= lastChompedMob or tick() - mobChompCooldown > mobAuraDelay then
                                    root.CFrame = CFrame.lookAt(root.Position, v3(mobPos.X, root.Position.Y, mobPos.Z))
                                    chompEvent:FireServer(payloadName)
                                    lastChompedMob = payloadName
                                    mobChompCooldown = tick()
                                    prioritizedMobThisFrame = true
                                    break
                                end
                            end
                        end
                    end
                end

                -- 3. Raycast Grass Chomp Logic (Yields to Mobs)
                if autoChomp and not prioritizedMobThisFrame then
                    raycastParams.FilterDescendantsInstances = {char}
                    local hit = workspace:Raycast(root.Position, v3(0, -15, 0), raycastParams)
                    
                    if hit and hit.Instance then
                        local actualNode = hit.Instance
                        
                        if not string.match(actualNode.Name, "Grass") and actualNode.Parent then
                            if string.match(actualNode.Parent.Name, "Grass") then
                                actualNode = actualNode.Parent
                            end
                        end
                        
                        local nodeName = actualNode.Name
                        
                        if string.match(nodeName, "Grass") then
                            local cleanName = string.gsub(nodeName, "GrassVisual", "")
                            cleanName = string.gsub(cleanName, "^_+", "")
                            cleanName = string.gsub(cleanName, "_+$", "")
                            
                            if string.match(cleanName, ".*Grass.*_[np%-]?%d+_[np%-]?%d+$") then
                                if cleanName ~= lastChompedNode or tick() - chompCooldown > 1 then
                                    chompEvent:FireServer(cleanName)
                                    lastChompedNode = cleanName
                                    chompCooldown = tick()
                                    
                                    if currentTargetNode and currentTargetNode.Name == nodeName then
                                        currentTargetNode = nil
                                    end
                                end
                            end
                        end
                    end
                end

                -- 4. Auto-Fishing Logic
                if autoFish then
                    if tick() - castCooldown > 3 then
                        local nearestSpot = nil
                        local shortestDistance = 50
                        
                        for _, spot in ipairs(fishingSpotsFolder:GetChildren()) do
                            if spot:IsA("BasePart") or spot:IsA("Model") then
                                local spotPos = spot:IsA("Model") and spot:GetPivot().Position or spot.Position
                                local dist = get2DDistance(root.Position, spotPos)
                                
                                if dist < shortestDistance and isSpotAvailable(spot) then
                                    shortestDistance = dist
                                    nearestSpot = spot
                                end
                            end
                        end
                        
                        if nearestSpot then
                            fishingEvent:FireServer("Cast", nearestSpot)
                            castCooldown = tick()
                        end
                    end
                end
            end)
        end
    else
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
            HeartbeatConnection = nil
        end
        if not farmOn and humanoid then humanoid:Move(v3(), false) end
    end
end

-- ==========================
-- UI SETUP: Main Farming Tab
-- ==========================
local MainTab = Window:CreateTab({ Name = "Autofarm", Icon = 4483362458 })

MainTab:CreateSection({ Name = "Main Toggles" })

MainTab:CreateToggle({
    Name = "Enable Autofarm (Movement)",
    CurrentValue = false,
    Flag = "Toggle_Farm",
    Callback = function(Value)
        farmOn = Value
        patternTimer = 0
        nextRandomPos = nil
        currentTargetNode = nil
        
        if Value then 
            anchorPos = root.Position 
            
            Window:Notify({
                Title = "Autofarm Enabled",
                Content = "Absolute static home base set. Walking started.",
                Duration = 3,
                Image = 4483362458,
            })
        end
        
        updatePenVisualizer()
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Auto-Chomper (Grass)",
    CurrentValue = false,
    Flag = "Toggle_Chomp",
    Callback = function(Value)
        autoChomp = Value
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Mob Aura (Priority)",
    CurrentValue = false,
    Flag = "Toggle_MobAura",
    Callback = function(Value)
        autoChompMobs = Value
        updateHeartbeatConnection()
    end,
})

MainTab:CreateToggle({
    Name = "Enable Auto-Fishing",
    CurrentValue = false,
    Flag = "Toggle_Fish",
    Callback = function(Value)
        autoFish = Value
        updateHeartbeatConnection()
    end,
})

MainTab:CreateSection({ Name = "Aura & Pattern Configuration" })

MainTab:CreateSlider({
    Name = "Mob Aura Radius (Studs)",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "Slider_MobAura",
    Callback = function(Value) 
        mobAuraRadius = Value 
    end,
})

MainTab:CreateDropdown({
    Name = "Mob Aura Speed",
    Options = {"Slow (1.0s)", "Normal (0.5s)", "Fast (0.1s)"},
    CurrentOption = {"Normal (0.5s)"},
    MultipleOptions = false,
    Flag = "Dropdown_MobSpeed",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Slow (1.0s)" then mobAuraDelay = 1.0
        elseif selection == "Normal (0.5s)" then mobAuraDelay = 0.5
        elseif selection == "Fast (0.1s)" then mobAuraDelay = 0.1
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Walking Pattern",
    Options = {"Guided Zigzag (Nodes)", "Circle", "Square", "Zigzag", "Random"},
    CurrentOption = {"Guided Zigzag (Nodes)"},
    MultipleOptions = false,
    Flag = "Dropdown_Pattern",
    Callback = function(Option) pattern = type(Option) == "table" and Option[1] or Option end,
})

MainTab:CreateSlider({
    Name = "Farm Radius (Studs)",
    Range = {10, 300},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 75,
    Flag = "Slider_Radius",
    Callback = function(Value) 
        farmRadius = Value 
        updatePenVisualizer()
    end,
})

MainTab:CreateDropdown({
    Name = "Walking Speed",
    Options = {"Very Slow (0.4x)", "Slow (0.6x)", "Normal (1.0x)", "Fast (1.6x)"},
    CurrentOption = {"Normal (1.0x)"},
    MultipleOptions = false,
    Flag = "Dropdown_Speed",
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        if selection == "Very Slow (0.4x)" then patternSpeed = 0.4
        elseif selection == "Slow (0.6x)" then patternSpeed = 0.6
        elseif selection == "Normal (1.0x)" then patternSpeed = 1.0
        elseif selection == "Fast (1.6x)" then patternSpeed = 1.6
        end
    end,
})

MainTab:CreateSection({ Name = "Visuals / ESP" })

MainTab:CreateToggle({
    Name = "Show Pen Boundary (ESP)",
    CurrentValue = false,
    Flag = "Toggle_PenESP",
    Callback = function(Value)
        showPenESP = Value
        updatePenVisualizer()
    end,
})

MainTab:CreateToggle({
    Name = "Show Team Chest ESP (Dynamic)",
    CurrentValue = false,
    Flag = "Toggle_ChestESP",
    Callback = function(Value)
        showChestESP = Value
        updateChestESP()
    end,
})

MainTab:CreateSection({ Name = "Virtual Input Spammer (0.05s CD)" })

MainTab:CreateToggle({
    Name = "Spam [E] Key",
    CurrentValue = false,
    Flag = "Toggle_Spam_E",
    Callback = function(Value) HandleSpam("E", Value, 0.05) end,
})

MainTab:CreateToggle({
    Name = "Spam [Q] Key",
    CurrentValue = false,
    Flag = "Toggle_Spam_Q",
    Callback = function(Value) HandleSpam("Q", Value, 0.05) end,
})

-- ==========================
-- UI SETUP: Scanner Tab
-- ==========================
local ScannerTab = Window:CreateTab({ Name = "Auction Scanner", Icon = 4483362458 })

ScannerTab:CreateSection({ Name = "Discord Webhook Integration" })

ScannerTab:CreateInput({
    Name = "Discord Webhook URL",
    Placeholder = WEBHOOK_URL ~= "" and "Saved webhook loaded! Paste to overwrite." or "Paste your Webhook URL here",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text:match("discord%.com/api/webhooks") then
            WEBHOOK_URL = Text
            saveWebhook(Text)
            Window:Notify({ Title = "Webhook Saved", Content = "Your Webhook URL has been saved locally.", Duration = 3 })
        else
            Window:Notify({ Title = "Invalid URL", Content = "Please enter a valid Discord webhook URL.", Duration = 3 })
        end
    end,
})

ScannerTab:CreateToggle({
    Name = "Enable Discord Webhook",
    CurrentValue = false,
    Flag = "ScannerToggle",
    Callback = function(Value)
        scannerRunning = Value
        
        if scannerRunning then
            if not httpRequest then
                Window:Notify({ Title = "Unsupported", Content = "Your executor does not support HTTP requests.", Duration = 4 })
                scannerRunning = false
                return
            elseif WEBHOOK_URL == "" then
                Window:Notify({ Title = "No Webhook", Content = "Please enter a valid Discord Webhook URL first.", Duration = 4 })
                scannerRunning = false
                return
            end
            
            for _, lotName in ipairs(lotNames) do
                local lot = skinAuction:FindFirstChild(lotName)
                if lot then
                    local conn = lot:GetAttributeChangedSignal("SkinId"):Connect(function()
                        task.wait(1) 
                        if scannerRunning then checkAuctionLots() end
                    end)
                    table.insert(auctionConnections, conn)
                end
            end
            
            task.spawn(checkAuctionLots)
        else
            for _, conn in ipairs(auctionConnections) do conn:Disconnect() end
            table.clear(auctionConnections)
        end
    end,
})

-- ==========================
-- UI SETUP: Settings Tab
-- ==========================
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = 4483362458 })

SettingsTab:CreateSection({ Name = "Performance" })

SettingsTab:CreateToggle({
    Name = "Disable 3D Rendering",
    CurrentValue = false,
    Flag = "Toggle_3DRender",
    Callback = function(Value)
        pcall(function()
            RunService:Set3dRenderingEnabled(not Value)
        end)
    end,
})

SettingsTab:CreateToggle({
    Name = "Enable FPS Cap",
    CurrentValue = false,
    Flag = "Toggle_FPSCap",
    Callback = function(Value)
        fpsCapEnabled = Value
        if setfpscap then pcall(function() setfpscap(fpsCapEnabled and currentFpsCap or 60) end) end
    end,
})

SettingsTab:CreateSlider({
    Name = "FPS Cap Limit",
    Range = {15, 60},
    Increment = 1,
    Suffix = "FPS",
    CurrentValue = 60,
    Flag = "Slider_FPSCap",
    Callback = function(Value)
        currentFpsCap = Value
        if fpsCapEnabled and setfpscap then pcall(function() setfpscap(currentFpsCap) end) end
    end,
})

SettingsTab:CreateSection({ Name = "Script Controls" })

SettingsTab:CreateButton({
    Name = "Close Script & Destroy UI",
    Callback = function()
        if scannerRunning and httpRequest and WEBHOOK_URL ~= "" then
            task.spawn(function()
                httpRequest({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({["embeds"] = {{
                        ["title"] = "🛑 Scanner Offline",
                        ["description"] = "The script has been closed and the auction scanner is no longer active.",
                        ["color"] = tonumber("0xFF0000"), 
                        ["footer"] = {["text"] = "Auction Scanner • " .. os.date("%X")}
                    }}})
                })
            end)
        end

        farmOn = false
        autoChomp = false
        autoChompMobs = false
        autoFish = false
        scannerRunning = false 
        showPenESP = false
        showChestESP = false
        updatePenVisualizer()
        updateChestESP()
        
        spamThreads.E = spamThreads.E + 1
        spamThreads.Q = spamThreads.Q + 1
        
        for _, conn in ipairs(auctionConnections) do conn:Disconnect() end
        table.clear(auctionConnections)
        
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
        if setfpscap then pcall(function() setfpscap(60) end) end
        
        if HeartbeatConnection then HeartbeatConnection:Disconnect() end
        pcall(function() if humanoid then humanoid:Move(v3(), false) end end)
        
        Window:Unload()
    end,
})
