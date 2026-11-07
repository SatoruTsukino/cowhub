-- Corrected Crate Pity Exporter
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.CowGame.Shared

local CollectionLuckRules = require(Shared.CollectionLuckRules)
local HalloweenConfig = require(Shared.HalloweenConfig)
local CaravanConfig = require(Shared.CaravanConfig)

local function getProfile()
    for _, t in ipairs(getgc(true)) do
        if type(t) == "table" then
            if rawget(t, "Remotes") and type(rawget(t, "Store")) == "table" then
                local ok, s = pcall(function() return t.Store:GetState() end)
                if ok and type(s) == "table" and type(s.Profile) == "table" then
                    return s.Profile
                end
            elseif rawget(t, "UnlockedCosmetics") and rawget(t, "CosmeticProvenance") then
                return t
            end
        end
    end
    return nil
end

local profile = getProfile()
assert(profile, "Profile not found in getgc")

local CRATE_SETS = {
    HalloweenCrate = HalloweenConfig.CrateSkins,
    CaravanCrate   = CaravanConfig.Skins,
}

local report = {}

for crateName, items in pairs(CRATE_SETS) do
    local prog = CollectionLuckRules.Progress(items, profile)
    local itemList = {}

    for _, it in ipairs(items) do
        local mult = CollectionLuckRules.Multiplier(it.Id, it.Rarity, prog)
        table.insert(itemList, {
            Id = it.Id,
            Rarity = it.Rarity,
            Owned = prog.Found[it.Id] == true,
            BaseChance = it.Chance or it.Weight,
            PityMultiplier = mult,
        })
    end

    report[crateName] = {
        Earned = prog.Earned,
        Total = prog.Total,
        Complete = prog.Complete,
        Items = itemList,
    }
end

writefile("cowhub/pity_export.json", HttpService:JSONEncode(report))
print("[PityExport] Written to cowhub/pity_export.json")