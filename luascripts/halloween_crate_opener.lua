-- ===================== SETTINGS (edit, then execute) =====================
local SETTINGS = {
    DESTROY = false, -- true: stop the running crate opener and exit (nothing new starts)

    TARGET = "PumpkinHeadCoat", -- stop once this cosmetic is owned
    OPEN_DELAY = 1.5, -- seconds between opens (game: 0.5 s action cooldown, up to 3 s for the result)
}
-- ==========================================================================

-- Halloween Crate Opener
-- Opens Halloween crates only while Lucky Skies AND Barnyard Bonus are both active
-- (crate rolls use luck: HalloweenCrateRules.OpenBox(..., luck)), until TARGET is owned
-- or the crates run out.
-- State comes from the game's live Store (Store:GetState(), same lookup as Cow Hub's
-- cosmetics.getProfile); old profile copies left in memory are never read.
--   Lucky Skies:    LuckySkiesRules.IsActive(serverTime)
--   Barnyard Bonus: state.Runtime.CountyFair.BoostEndsAt > serverTime
--   Owned:          state.Profile.UnlockedCosmetics[TARGET] == true
--   Crates:         state.Profile.Materials.HalloweenCrate
--   Open:           CraftRequest:FireServer({ Action = "OpenHalloweenCrate" }) (CraftingController:_send)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if _G.HalloweenCrateOpener and type(_G.HalloweenCrateOpener.destroy) == "function" then
    pcall(_G.HalloweenCrateOpener.destroy)
end

if SETTINGS.DESTROY then
    return nil
end

local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("CowGame"):WaitForChild("Shared")
local Remotes = RS.CowGame:WaitForChild("Remotes")
local LuckySkies = require(Shared:WaitForChild("LuckySkiesRules"))

local opener = { running = true, opened = 0 }

function opener.destroy()
    opener.running = false
    if _G.HalloweenCrateOpener == opener then
        _G.HalloweenCrateOpener = nil
    end
end

_G.HalloweenCrateOpener = opener

local store
local function getState()
    if store then
        local ok, state = pcall(function() return store:GetState() end)
        if ok and type(state) == "table" and type(state.Profile) == "table" then return state end
        store = nil
    end
    if type(getgc) ~= "function" then return nil end
    for _, t in ipairs(getgc(true)) do
        if type(t) == "table" and rawget(t, "Remotes") ~= nil and type(rawget(t, "Store")) == "table" then
            local s = rawget(t, "Store")
            local ok, state = pcall(function() return s:GetState() end)
            if ok and type(state) == "table" and type(state.Profile) == "table" then
                store = s
                return state
            end
        end
    end
    return nil
end

local function crateCount(profile)
    local c = profile.Materials and profile.Materials.HalloweenCrate
    if type(c) == "table" then return tonumber(c.Quantity or c.Count) or 0 end
    return tonumber(c) or 0
end

local function log(msg)
    print("[HalloweenCrateOpener] " .. msg)
end

task.spawn(function()
    local waiting = false
    while opener.running do
        local state = getState()
        if not state then
            warn("[HalloweenCrateOpener] store not found; retrying")
            task.wait(5)
            continue
        end
        local profile = state.Profile

        if profile.UnlockedCosmetics and profile.UnlockedCosmetics[SETTINGS.TARGET] == true then
            log(SETTINGS.TARGET .. " owned after " .. opener.opened .. " crate(s); stopping")
            break
        end
        local crates = crateCount(profile)
        if crates < 1 then
            log("out of Halloween crates after " .. opener.opened .. " opened; stopping")
            break
        end

        local now = workspace:GetServerTimeNow()
        local fair = state.Runtime and state.Runtime.CountyFair
        local barnyard = type(fair) == "table" and (tonumber(fair.BoostEndsAt) or 0) > now
        local lucky = LuckySkies.IsActive(now)

        if lucky and barnyard then
            waiting = false
            Remotes.CraftRequest:FireServer({ Action = "OpenHalloweenCrate" })
            opener.opened += 1
            log("opened crate #" .. opener.opened .. " (" .. (crates - 1) .. " left)")
            task.wait(SETTINGS.OPEN_DELAY)
        else
            if not waiting then
                waiting = true
                log("waiting: Lucky Skies " .. (lucky and "on" or "off") .. ", Barnyard Bonus " .. (barnyard and "on" or "off") .. "; " .. crates .. " crate(s)")
            end
            task.wait(1)
        end
    end
    opener.destroy()
end)

log("running; target " .. SETTINGS.TARGET)
return opener
