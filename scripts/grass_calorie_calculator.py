#!/usr/bin/env python3
"""Grass Multiplier and Average Bite Calorie Yield Calculator for Cow Game.

Mirrors the decompiled Cow Game modules (Opiumware workspace dumps, including Alpha V3.0.0):
  Config.Rebirth:
    CaloriesMultiplierPerRebirth = 0.22 (compound 1.22^n)
    GetRebirthMultiplier(n, profile) = 1.22^n * (2 if AuraConfig.AreAllPathsCompleted else 1)
    BaseRequirement = 10,000, GrowthRate = 2 (10,000 * 2^n)
    GetRebirthRequirement(n, now, spiritLanterns):
      req = round(10,000 * 2^n / 100) * 100
      if WeekendEvent.Active: req = round(req * 0.9)
      return max(1, ceil(req / 2^spiritLanterns))
  GrassEconomy.Calculate (Version 3):
    Base calories = Zone Category BaseValue + GrassType Bonus + BitePower Bonus
    + Headwear/Helmet BaseCalories Bonus
    + Expected Secondary Growth (Clover, Mushroom, Barley, Wheat, Apple, GoldMushroom, GoldenApple)
    * IntakeMultiplier (Heart o' Davy Jones 2.0x, Bionic Stomach 1.33x, Strong Chompers up to 2.0x)
    * Node Modifiers (Golden 2.0x, Fertilized 1.33x, etc.)
    * Maturity (1.0 at full growth)
    * RumenMultiplier (1 + 0.02 * Combo)
    * RebirthMultiplier ((1 + 0.22)^n * (2 if All Auras Completed else 1))
    * GrazingTitleMultiplier (e.g. 1.03x from Title_CloverMarbles)
    * Back Friend Bonus (1.01x to 1.05x from 1-5 Back Bunnies)
    * ExcursionMultiplier (Trailblazer Aura: (1 + 0.20 * L) * 1.02^adventure)
    * WeekendMultiplier (1.5x during WeekendEvent)
    * CompanionMultiplier (1 + 0.15 * Bond, clamped [1.0, 1.15])
    * PillarBonus (1 + PillarBonus, e.g. 1.10x from Grazer Pillar)
    * Optional Gamepasses / Event boosts / Herd
  FieldRaidCatalog & FieldRaidPowerups (Alpha V3.0.0):
    10 Raid Fields (Spider Patch -> Ogre's Acre): BaseCalories 100 -> 25,000, RipeExtra 100 -> 8,000,000
    Raid Food Chew Cooldown: 0.5x of normal chew cooldown (0.20s at Chew Speed 15)
    RipeBonus(level, rebirth): round(max(BaseCalories * 0.01, RipeExtra * RipeFactor[rebirth]))
    Strong Chompers (Lvl 0-99): +(100% if L==99 else L%) grazing calories
    Mushroom Island (Lvl 0-99): Passive patch growth (L + 1) * 200 cal/s, capacity (L + 1) * 2,000,000 cal
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import asdict, dataclass
from typing import Any, Dict, List, Optional, Tuple

# --- Game Constants ---

REBIRTH_MULTIPLIER_STEP = 0.22  # Config.Rebirth.CaloriesMultiplierPerRebirth
REBIRTH_BASE_REQUIREMENT = 10000  # Config.Rebirth.BaseRequirement
REBIRTH_GROWTH_RATE = 2.0  # Config.Rebirth.GrowthRate
REBIRTH_REQUIREMENT_ROUNDING = 100  # Config.Rebirth.RequirementRounding

BITE_POWER_MAX_LEVEL = 25  # UpgradeConfig.Definitions.BitePower.MaxLevel
RUMEN_MAX_LEVEL = 10  # UpgradeConfig.Definitions.Rumen.MaxLevel
CHEW_SPEED_MAX_LEVEL = 15  # UpgradeConfig.Definitions.ChewSpeed.MaxLevel
TRAILBLAZER_MAX_LEVEL = 5  # AuraConfig.Definitions.Trailblazer.MaxLevel
RAID_POWERUP_MAX_LEVEL = 99  # FieldRaidPowerups max level

CHEW_BASE_COOLDOWN = 0.7  # UpgradeConfig.GetDerived ChewCooldown
CHEW_MIN_COOLDOWN = 0.4

# Alpha V3.0.0 Progression Items (ProgressionItems & CurrentUpdate)
DAVY_JONES_HEART_MULTIPLIER = 2.0  # Heart o' Davy Jones: permanently doubles calorie intake
BIONIC_STOMACH_MULTIPLIER = 1.33  # Bionic Stomach: 1.33x calorie intake while enabled (costs 25 raid pts)
WEEKEND_CALORIE_MULTIPLIER = 1.5  # WeekendEvent.CalorieMultiplier
WEEKEND_REQ_DISCOUNT = 0.9  # Config.GetRebirthRequirement weekend multiplier

# Grass Types (PlantingConfig.GrassTypes)
GRASS_TYPES: Dict[str, Dict[str, Any]] = {
    "Regular": {"BonusCalories": 0, "DisplayName": "Regular Grass"},
    "Redgrass": {"BonusCalories": 120, "DisplayName": "Redgrass (+120)"},
    "Bluegrass": {"BonusCalories": 360, "DisplayName": "Bluegrass (+360)"},
    "CaveMoss1": {"BonusCalories": 0, "DisplayName": "Cave Moss 1 (+0)"},
    "CaveMoss2": {"BonusCalories": 0, "DisplayName": "Cave Moss 2 (+0)"},
    "CaveMoss3": {"BonusCalories": 7, "DisplayName": "Cave Moss 3 (+7)"},
    "CaveMoss4": {"BonusCalories": 14, "DisplayName": "Cave Moss 4 (+14)"},
}

# Headwear / Mining Hat Base Calorie Bonuses (HelmetBonuses & MiningHatConfig.Benefits)
HEADWEAR_BONUSES: Dict[str, Dict[str, Any]] = {
    "None": {"Bonus": 0, "DisplayName": "No Hat (+0)"},
    "Common": {"Bonus": 5, "DisplayName": "Common Mining Hat (+5 Base)"},
    "Uncommon": {"Bonus": 10, "DisplayName": "Uncommon Mining Hat (+10 Base)"},
    "Rare": {"Bonus": 15, "DisplayName": "Rare Hat / Mithril Hard Hat (+15 Base)"},
    "SuperRare": {"Bonus": 20, "DisplayName": "Super Rare Hat (+20 Base)"},
    "Mythic": {"Bonus": 25, "DisplayName": "Mythic Mining Hat (+25 Base)"},
}

# Titles (CloverQuestConfig & TitleCatalog)
TITLES: Dict[str, Dict[str, Any]] = {
    "None": {"Multiplier": 1.0, "DisplayName": "No Title (1.00×)"},
    "CloverMarbles": {
        "Multiplier": 1.03,
        "DisplayName": "Who Found Clover’s Lost Marbles (+3% Cal)",
    },
}

# Pillars (PillarConfig)
PILLARS: Dict[str, Dict[str, Any]] = {
    "None": {"Bonus": 0.0, "DisplayName": "No Pillar"},
    "Grazer": {"Bonus": 0.10, "DisplayName": "Grazer Pillar (+10% Grass Cal)"},
}

# Secondaries Base Values (FoodConfig.Secondaries)
SECONDARIES_BASE: Dict[str, float] = {
    "Clover": 7.0,
    "Mushroom": 5.0,
    "MeadowMushroom": 10.0,
    "PorciniMushroom": 20.0,
    "ChanterelleMushroom": 40.0,
    "GoldMushroom": 80.0,
    "Apple": 15.0,
    "GoldenApple": 30.0,  # Field 10 secondary (2x Apple base)
    "WildBarley": 17.0,
    "WildWheat": 21.0,
    "Fern": 7.0,
    "Bush": 6.0,
    "Flower": 5.0,
}

# Mushroom variety weights (FoodConfig.MushroomVarieties & GoldenMushroomChance)
MUSHROOM_GOLDEN_CHANCE = 0.05
MUSHROOM_WEIGHTS = [
    ("Mushroom", 40, SECONDARIES_BASE["Mushroom"]),
    ("MeadowMushroom", 25, SECONDARIES_BASE["MeadowMushroom"]),
    ("PorciniMushroom", 18, SECONDARIES_BASE["PorciniMushroom"]),
    ("ChanterelleMushroom", 12, SECONDARIES_BASE["ChanterelleMushroom"]),
]
_total_mush_weight = sum(w for _, w, _ in MUSHROOM_WEIGHTS)
EXPECTED_MUSHROOM_VALUE = (
    MUSHROOM_GOLDEN_CHANCE * SECONDARIES_BASE["GoldMushroom"]
    + (1.0 - MUSHROOM_GOLDEN_CHANCE)
    * sum((w / _total_mush_weight) * val for _, w, val in MUSHROOM_WEIGHTS)
)  # = 0.05 * 80 + 0.95 * (1290 / 95) = 4.0 + 12.90 = 16.90

# Field Raid Ripe Wheat Scaling Factors (FieldRaidCatalog.luau)
RIPE_BONUS_FACTORS: Dict[int, float] = {
    15: 0.0015,
    16: 0.008,
    17: 0.019,
    18: 0.035,
    19: 0.059,
    20: 0.106,
    21: 0.15,
    22: 0.216,
    23: 0.315,
    24: 0.468,
    25: 0.698,
}

# Ripe opportunities per 4-outing cycle for R10-R14 (FieldRaidCatalog.luau)
RIPE_OPPORTUNITIES_CYCLE4: Dict[int, int] = {
    10: 17,  # avg 4.25 per outing
    11: 22,  # avg 5.50 per outing
    12: 30,  # avg 7.50 per outing
    13: 41,  # avg 10.25 per outing
    14: 56,  # avg 14.00 per outing
}

# Field Raids Catalog (FieldRaidCatalog.Fields)
FIELD_RAID_FIELDS: Dict[int, Dict[str, Any]] = {
    1: {
        "Level": 1,
        "ZoneKey": "FieldRaid1",
        "Name": "Spider Patch",
        "BaseCalories": 100,
        "RipeExtra": 100,
        "SecondaryKind": "Clover",
        "SecondaryRate": 0.03,
        "SecondaryValue": 1.5,
        "Difficulty": "Open rows",
    },
    2: {
        "Level": 2,
        "ZoneKey": "FieldRaid2",
        "Name": "Spiderweb Rows",
        "BaseCalories": 250,
        "RipeExtra": 500,
        "SecondaryKind": "WildBarley",
        "SecondaryRate": 0.03,
        "SecondaryValue": 1.5,
        "Difficulty": "Open rows",
    },
    3: {
        "Level": 3,
        "ZoneKey": "FieldRaid3",
        "Name": "Stone-Throwers’ Track",
        "BaseCalories": 500,
        "RipeExtra": 3000,
        "SecondaryKind": "Clover",
        "SecondaryRate": 0.04,
        "SecondaryValue": 1.5,
        "Difficulty": "Patrolled",
    },
    4: {
        "Level": 4,
        "ZoneKey": "FieldRaid4",
        "Name": "Warlock’s Crossing",
        "BaseCalories": 750,
        "RipeExtra": 7500,
        "SecondaryKind": "WildBarley",
        "SecondaryRate": 0.04,
        "SecondaryValue": 1.5,
        "Difficulty": "Patrolled",
    },
    5: {
        "Level": 5,
        "ZoneKey": "FieldRaid5",
        "Name": "Guarded Yard",
        "BaseCalories": 1000,
        "RipeExtra": 25000,
        "SecondaryKind": "Clover",
        "SecondaryRate": 0.04,
        "SecondaryValue": 1.5,
        "Difficulty": "Patrolled",
    },
    6: {
        "Level": 6,
        "ZoneKey": "FieldRaid6",
        "Name": "Archers’ Row",
        "BaseCalories": 1500,
        "RipeExtra": 75000,
        "SecondaryKind": "WildBarley",
        "SecondaryRate": 0.04,
        "SecondaryValue": 1.75,
        "Difficulty": "Guarded",
    },
    7: {
        "Level": 7,
        "ZoneKey": "FieldRaid7",
        "Name": "Patrol Grounds",
        "BaseCalories": 2500,
        "RipeExtra": 200000,
        "SecondaryKind": "Clover",
        "SecondaryRate": 0.05,
        "SecondaryValue": 1.75,
        "Difficulty": "Guarded",
    },
    8: {
        "Level": 8,
        "ZoneKey": "FieldRaid8",
        "Name": "City Guard Granary",
        "BaseCalories": 5000,
        "RipeExtra": 800000,
        "SecondaryKind": "Mushroom",
        "SecondaryRate": 0.05,
        "SecondaryValue": 2.0,
        "Difficulty": "Endurance",
    },
    9: {
        "Level": 9,
        "ZoneKey": "FieldRaid9",
        "Name": "Warlocks’ Reach",
        "BaseCalories": 10000,
        "RipeExtra": 1800000,
        "SecondaryKind": "GoldMushroom",
        "SecondaryRate": 0.10,
        "SecondaryValue": 2.0,
        "Difficulty": "Endurance",
    },
    10: {
        "Level": 10,
        "ZoneKey": "FieldRaid10",
        "Name": "Ogre’s Acre",
        "BaseCalories": 25000,
        "RipeExtra": 8000000,
        "SecondaryKind": "GoldenApple",
        "SecondaryRate": 0.15,
        "SecondaryValue": 2.0,
        "Difficulty": "Endurance",
    },
}

# Zone Definitions (FoodConfig.Categories & FieldRaidCatalog.Fields)
ZONES: Dict[str, Dict[str, Any]] = {
    "HomeMeadow": {
        "Group": 1,
        "Category": "Fields1",
        "BaseValue": 7,
        "SecondaryValue": 1.0,
        "GoldenChance": 0.005,
        "SecondaryRate": 0.10,
        "SecondaryKind": None,
        "MinRebirth": 0,
        "IsFieldRaid": False,
        "Description": "Starter pasture; safe zone.",
    },
    "CloverCreek": {
        "Group": 1,
        "Category": "Fields1",
        "BaseValue": 7,
        "SecondaryValue": 1.0,
        "GoldenChance": 0.005,
        "SecondaryRate": 0.10,
        "SecondaryKind": "Clover",
        "MinRebirth": 0,
        "IsFieldRaid": False,
        "Description": "Fields 1 zone with wild Clover (+7 base).",
    },
    "FishermansForest": {
        "Group": 1,
        "Category": "Fields1",
        "BaseValue": 7,
        "SecondaryValue": 1.0,
        "GoldenChance": 0.005,
        "SecondaryRate": 0.10,
        "SecondaryKind": "Mushroom",
        "MinRebirth": 0,
        "IsFieldRaid": False,
        "Description": "Forest zone with variety mushrooms (avg +16.9 base).",
    },
    "SouthPastures": {
        "Group": 2,
        "Category": "Fields2",
        "BaseValue": 14,
        "SecondaryValue": 1.1,
        "GoldenChance": 0.0075,
        "SecondaryRate": 0.15,
        "SecondaryKind": "Mushroom",
        "MinRebirth": 0,
        "IsFieldRaid": False,
        "Description": "Fields 2 zone with mushrooms scaled by 1.1x.",
    },
    "AppleOrchard": {
        "Group": 2,
        "Category": "Fields2",
        "BaseValue": 14,
        "SecondaryValue": 1.1,
        "GoldenChance": 0.0075,
        "SecondaryRate": 0.15,
        "SecondaryKind": "Apple",
        "MinRebirth": 0,
        "IsFieldRaid": False,
        "Description": "Fields 2 zone with fallen apples (15 * 1.1 = +16.5 base).",
    },
    "MountainsideMeadow": {
        "Group": 3,
        "Category": "Fields3",
        "BaseValue": 21,
        "SecondaryValue": 1.25,
        "GoldenChance": 0.010,
        "SecondaryRate": 0.25,
        "SecondaryKind": "WildBarley",
        "MinRebirth": 1,
        "IsFieldRaid": False,
        "Description": "Rebirth 1+ zone with Wild Barley (17 * 1.25 = +21.25 base).",
    },
    "GoldenHill": {
        "Group": 3,
        "Category": "Fields3",
        "BaseValue": 21,
        "SecondaryValue": 1.25,
        "GoldenChance": 0.010,
        "SecondaryRate": 0.25,
        "SecondaryKind": "WildWheat",
        "MinRebirth": 1,
        "IsFieldRaid": False,
        "Description": "Fields 3 zone with Wild Wheat (21 * 1.25 = +26.25 base).",
    },
    "Cave": {
        "Group": 4,
        "Category": "Cave",
        "BaseValue": 28,
        "SecondaryValue": 1.5,
        "GoldenChance": 0.030,
        "SecondaryRate": 0.33,
        "SecondaryKind": "Mushroom",
        "MinRebirth": 0,
        "IsFieldRaid": False,
        "Description": "Cavern zone with high base (28) and 1.5x mushrooms.",
    },
}

# Register FieldRaid1..FieldRaid10 into ZONES
for _lvl, _f in FIELD_RAID_FIELDS.items():
    ZONES[_f["ZoneKey"]] = {
        "Group": 5,
        "Category": f"Raid F{_lvl}",
        "BaseValue": _f["BaseCalories"],
        "RipeExtra": _f["RipeExtra"],
        "RaidLevel": _lvl,
        "RaidName": _f["Name"],
        "Difficulty": _f["Difficulty"],
        "SecondaryValue": _f["SecondaryValue"],
        "GoldenChance": 0.0,  # Raid wheat uses Ripe Bell windows instead of random golden grass
        "SecondaryRate": _f["SecondaryRate"],
        "SecondaryKind": _f["SecondaryKind"],
        "MinRebirth": 1,
        "IsFieldRaid": True,
        "Description": f"Field Raid {_lvl} ({_f['Name']}): {_f['BaseCalories']:,} base, {_f['RipeExtra']:,} ripe pool.",
    }


# --- Calculation Helpers ---

def get_rebirth_multiplier(rebirth: int, all_auras_completed: bool = False) -> float:
    """Calculate the grass/calorie multiplier for rebirth n.

    Config.luau:
      (1 + Config.Rebirth.CaloriesMultiplierPerRebirth) ^ n * (2 if AuraConfig.AreAllPathsCompleted else 1)
    """
    n = max(0, int(rebirth))
    base_mult = (1.0 + REBIRTH_MULTIPLIER_STEP) ** n
    return base_mult * (2.0 if all_auras_completed else 1.0)


def get_rebirth_requirement(
    rebirth: int,
    spirit_lanterns: int = 0,
    weekend_discount: bool = False,
) -> int:
    """Calculate the calories required to perform rebirth n -> n + 1.

    Config.luau:
      num5 = round(BaseRequirement * GrowthRate ^ n / Rounding) * Rounding
      if WeekendEvent.Active(now) then num5 = round(num5 * 0.9) end
      return max(1, ceil(num5 / 2 ^ (spiritLanterns or 0)))
    """
    n = max(0, int(rebirth))
    lanterns = max(0, int(spirit_lanterns))
    req = round(REBIRTH_BASE_REQUIREMENT * (REBIRTH_GROWTH_RATE ** n) / REBIRTH_REQUIREMENT_ROUNDING) * REBIRTH_REQUIREMENT_ROUNDING
    if weekend_discount:
        req = int(math.floor(req * WEEKEND_REQ_DISCOUNT + 0.5))
    return max(1, int(math.ceil(req / (2 ** lanterns))))


def get_cumulative_rebirth_calories(
    target_rebirth: int,
    weekend_discount: bool = False,
) -> int:
    """Total cumulative calories required to go from Rebirth 0 to target_rebirth."""
    n = max(0, int(target_rebirth))
    return sum(get_rebirth_requirement(i, weekend_discount=weekend_discount) for i in range(n))


def get_bite_power_bonus(level: int) -> int:
    """Bite Power upgrade flat base calorie bonus.

    UpgradeConfig.luau: level * (level + 3) / 2
    """
    lvl = max(0, min(int(level), BITE_POWER_MAX_LEVEL))
    return (lvl * (lvl + 3)) // 2


def get_chew_cooldown(chew_speed_level: int, is_field_raid: bool = False) -> float:
    """Chew cooldown in seconds based on Chew Speed upgrade and target type.

    UpgradeConfig.luau: max(0.4, 0.7 - kickPower * 0.02)
    InputController.luau: RaidFood / Wheat multiplies chew cooldown by 0.5 (e.g. 0.4s -> 0.2s).
    """
    lvl = max(0, min(int(chew_speed_level), CHEW_SPEED_MAX_LEVEL))
    base_cd = max(CHEW_MIN_COOLDOWN, CHEW_BASE_COOLDOWN - lvl * 0.02)
    return base_cd * (0.5 if is_field_raid else 1.0)


def get_rumen_stats(rumen_level: int) -> Tuple[int, float]:
    """Returns (ComboCap, MaxRumenMultiplier).

    UpgradeConfig.luau:
      ComboCap = level * 2 + 20
      RumenMultiplierCap = ComboCap * 0.02 + 1
    """
    lvl = max(0, min(int(rumen_level), RUMEN_MAX_LEVEL))
    combo_cap = lvl * 2 + 20
    max_multiplier = 1.0 + combo_cap * 0.02
    return combo_cap, max_multiplier


def get_companion_multiplier(bond: float = 0.0) -> float:
    """Companion / Pet grazing multiplier.

    GrassEconomy / CompanionCare: clamp(1 + bond * 0.15, 1.0, 1.15)
    """
    if bond <= 0:
        return 1.0
    return max(1.0, min(1.15, 1.0 + bond * 0.15))


def get_intake_multiplier(
    davy_jones_heart: bool = False,
    bionic_stomach: bool = False,
    strong_chompers_level: Optional[int] = None,
    is_field_raid: bool = False,
) -> Tuple[float, float, float]:
    """Calculate (davy_mult, stomach_mult, chompers_mult) feeding into IntakeMultiplier.

    - Heart o' Davy Jones: 2.0x permanent calorie intake
    - Bionic Stomach: 1.33x calorie intake while enabled
    - Strong Chompers (FieldRaidPowerups.Stats):
        Grazing = (100 if level == 99 else level) / 100 -> 1.0 + Grazing (up to 2.0x in raids/active)
    """
    davy_mult = DAVY_JONES_HEART_MULTIPLIER if davy_jones_heart else 1.0
    stomach_mult = BIONIC_STOMACH_MULTIPLIER if bionic_stomach else 1.0
    chompers_mult = get_strong_chompers_multiplier(strong_chompers_level) if (is_field_raid and strong_chompers_level is not None) else 1.0
    return davy_mult, stomach_mult, chompers_mult


def get_strong_chompers_multiplier(level: Optional[int]) -> float:
    """FieldRaidPowerups.Stats('StrongChompers', level).Grazing bonus as a multiplier.

    Note: In FieldRaidPowerups.luau, level 0 grants +0% (1.00x), level 1 grants +1% (1.01x),
    ..., level 98 grants +98% (1.98x), level 99 grants +100% (2.00x).
    """
    if level is None or level < 0:
        return 1.0
    lvl = max(0, min(int(level), RAID_POWERUP_MAX_LEVEL))
    num3 = 100 if lvl == 99 else lvl
    return 1.0 + (num3 / 100.0)


def get_mushroom_island_stats(level: Optional[int]) -> Tuple[int, int]:
    """FieldRaidPowerups.Stats('MushroomIsland', level) -> (Growth cal/sec, Capacity cal).

    If level is None or < 0 (unequipped), returns (0, 0).
    At level 0..99:
      Growth = (level + 1) * 200 cal/s (200 cal/s at L0 -> 20,000 cal/s at L99)
      Capacity = (level + 1) * 2,000,000 cal (2M at L0 -> 200M at L99)
    """
    if level is None or level < 0:
        return 0, 0
    lvl = max(0, min(int(level), RAID_POWERUP_MAX_LEVEL))
    return (lvl + 1) * 200, (lvl + 1) * 2_000_000


def get_excursion_multiplier(
    trailblazer_level: int = 0,
    trailblazer_branch: Optional[str] = None,
    on_excursion: bool = False,
) -> float:
    """AuraConfig.ExcursionCalories(profile).

    Trailblazer (RequiredRebirths = 10, MaxLevel = 5):
      Calories = level * 0.2 (+20% to +100% -> 1.0x to 2.0x)
      Adventure = 2 if (branch == 'Adventurous' and level == 5) else (1 if branch == 'Adventurous' and level >= 3 else 0)
      ExcursionCalories = (1 + Calories) * (1.02 ^ Adventure)
    Applied as ExcursionMultiplier when on excursion (Field Raids, Rafting, Fishing) or when Trailblazer is active.
    """
    if not on_excursion or trailblazer_level <= 0:
        return 1.0
    lvl = max(0, min(int(trailblazer_level), TRAILBLAZER_MAX_LEVEL))
    cal_bonus = lvl * 0.2
    adventure = 0
    if lvl >= 3 and trailblazer_branch == "Adventurous":
        adventure = 2 if lvl == 5 else 1
    return (1.0 + cal_bonus) * (1.02 ** adventure)


def get_field_raid_ripe_bonus(field_level: int, rebirth: int) -> int:
    """FieldRaidCatalog.RipeBonus(field_level, rebirth).

    Luau:
      local field = FieldRaidCatalog.Fields[num1]
      local var3 = var1[math.clamp(math.floor(num2), 0, 25)] or 0
      return math.round(math.max(field.BaseCalories * 0.01, field.RipeExtra * var3))
    """
    f_info = FIELD_RAID_FIELDS.get(int(field_level))
    if not f_info:
        return 0
    clamped_r = max(0, min(int(rebirth), 25))
    factor = RIPE_BONUS_FACTORS.get(clamped_r, 0.0)
    raw = max(f_info["BaseCalories"] * 0.01, f_info["RipeExtra"] * factor)
    return int(math.floor(raw + 0.5))


def get_field_raid_ripe_opportunities(rebirth: int) -> float:
    """Average ripe wheat opportunities per field section / outing at given rebirth.

    FieldRaidCatalog.RipeOpportunities:
      For R10-R14: var2[r] / 4 (17/4=4.25, 22/4=5.5, 30/4=7.5, 41/4=10.25, 56/4=14.0)
      Otherwise (R0-R9 and R15+): 6
    """
    r = max(0, int(rebirth))
    if r in RIPE_OPPORTUNITIES_CYCLE4:
        return RIPE_OPPORTUNITIES_CYCLE4[r] / 4.0
    return 6.0


def get_expected_secondary_bonus(zone_name: str) -> float:
    """Expected calorie bonus per node from secondary growth spawns.

    GrassEconomy: SecondaryBase * Zone.SecondaryValue when spawned.
    In Field Raids, secondary spawns (Clover, WildBarley, Mushroom, GoldMushroom, GoldenApple)
    spawn at `SecondaryRate` with `BaseCalories * Secondary.Multiplier` (or secondary base value).
    """
    zone = ZONES.get(zone_name, ZONES["HomeMeadow"])
    sec_kind = zone.get("SecondaryKind")
    if not sec_kind:
        return 0.0

    rate = float(zone.get("SecondaryRate", 0.0))
    sec_mult = float(zone.get("SecondaryValue", 1.0))

    if zone.get("IsFieldRaid"):
        # In Field Raids, secondary forage node base is field.BaseCalories * Secondary.Multiplier
        # (gives extra burst calories + buff like Heal/Speed/GoldHearts + 20+10*L Raid XP)
        return rate * float(zone["BaseValue"]) * (sec_mult - 1.0)

    if sec_kind == "Mushroom":
        avg_base = EXPECTED_MUSHROOM_VALUE
    elif sec_kind in SECONDARIES_BASE:
        avg_base = SECONDARIES_BASE[sec_kind]
    else:
        avg_base = 0.0

    return rate * (avg_base * sec_mult)


def get_expected_node_multiplier(zone_name: str, lucky_clover_level: int = 0) -> float:
    """Expected node modifier multiplier from Golden grass spawns.

    Golden grass provides a 2.0x multiplier.
    Expected = (1 - P_gold) * 1.0 + P_gold * 2.0 = 1.0 + P_gold.
    Field Raid wheat cells do not roll random Golden grass (they use Ripe Wheat bell windows).
    """
    zone = ZONES.get(zone_name, ZONES["HomeMeadow"])
    if zone.get("IsFieldRaid"):
        return 1.0
    base_golden_chance = float(zone.get("GoldenChance", 0.005))
    aura_boost = max(0, lucky_clover_level) * 0.03
    p_gold = min(1.0, base_golden_chance + aura_boost)
    return 1.0 + p_gold * (2.0 - 1.0)


# --- Core Calculator Data Models & Engine ---

@dataclass
class BiteCalculation:
    rebirth: int
    all_auras_completed: bool
    rebirth_multiplier: float
    spirit_lanterns: int
    weekend_event: bool
    zone: str
    is_field_raid: bool
    raid_level: int
    zone_base: int
    ripe_wheat_active: bool
    ripe_bonus_base: int
    grass_type: str
    grass_bonus: int
    bite_power_level: int
    bite_power_bonus: int
    headwear: str
    headwear_bonus: int
    expected_secondary_bonus: float
    effective_base_calories: float
    davy_jones_heart: bool
    bionic_stomach: bool
    strong_chompers_level: int
    strong_chompers_multiplier: float
    intake_multiplier: float
    trailblazer_level: int
    trailblazer_branch: str
    excursion_multiplier: float
    weekend_multiplier: float
    golden_chance: float
    expected_node_multiplier: float
    rumen_level: int
    combo_stacks: int
    rumen_multiplier: float
    companion_bond: float
    companion_multiplier: float
    title: str
    title_multiplier: float
    back_bunnies: int
    back_bunnies_multiplier: float
    pillar: str
    pillar_multiplier: float
    gamepass_2x: bool
    other_multiplier: float
    total_multiplier: float
    avg_bite_calories: float
    ripe_bite_calories: float
    min_bite_calories: int
    max_bite_calories: int
    chew_speed_level: int
    chew_cooldown: float
    bite_calories_per_second: float
    mushroom_island_level: int
    mushroom_patch_cal_per_sec: int
    mushroom_patch_capacity: int
    calories_per_second: float
    next_rebirth_requirement: int
    expected_bites_to_rebirth: float
    expected_seconds_to_rebirth: float


def calculate_bite_yield(
    rebirth: int = 0,
    zone: str = "HomeMeadow",
    grass_type: str = "Regular",
    bite_power_level: int = 25,
    rumen_level: int = 10,
    combo_mode: str = "max",  # "max", "zero", "half", or numeric string
    companion_bond: float = 1.0,  # 0.0 (none), 0.25 (fresh), 1.0 (max)
    chew_speed_level: int = 15,
    headwear: str = "None",  # None, Common, Uncommon, Rare, SuperRare, Mythic
    title: str = "None",  # None, CloverMarbles
    back_bunnies: int = 0,  # 0 to 5 (+1% each)
    pillar: str = "None",  # None, Grazer (+10%)
    gamepass_2x: bool = False,
    lucky_clover_level: int = 0,
    other_multiplier: float = 1.0,
    # --- Alpha V3.0.0 Stat Bonuses & Field Raids ---
    all_auras_completed: bool = False,
    spirit_lanterns: int = 0,
    davy_jones_heart: bool = False,
    bionic_stomach: bool = False,
    trailblazer_level: int = 0,
    trailblazer_branch: str = "None",  # None, Adventurous, Unrelenting
    on_excursion: Optional[bool] = None,
    weekend_event: bool = False,
    strong_chompers_level: int = 0,
    mushroom_island_level: int = -1,  # -1 = unequipped, 0..99 = equipped level
    ripe_wheat_active: bool = False,
) -> BiteCalculation:
    """Calculate exact grass multiplier and average bite calorie yield.

    Returns a BiteCalculation dataclass with complete breakdown including Alpha V3.0.0
    progression items, aura mastery, Trailblazer excursion bonuses, and Field Raids.
    """
    z_info = ZONES.get(zone, ZONES["HomeMeadow"])
    g_info = GRASS_TYPES.get(grass_type, GRASS_TYPES["Regular"])
    is_raid = bool(z_info.get("IsFieldRaid", False))
    raid_lvl = int(z_info.get("RaidLevel", 0))

    # 1. Base Calories
    zone_base = int(z_info["BaseValue"])
    # In Field Raids, FoodKind is "Wheat", so PlantingConfig grass seed bonus does not apply
    grass_bonus = 0 if is_raid else int(g_info["BonusCalories"])
    bp_bonus = get_bite_power_bonus(bite_power_level)
    hw_bonus = HEADWEAR_BONUSES.get(headwear, HEADWEAR_BONUSES["None"])["Bonus"]
    sec_expected = get_expected_secondary_bonus(zone)

    ripe_bonus_base = get_field_raid_ripe_bonus(raid_lvl, rebirth) if is_raid else 0
    active_ripe_add = ripe_bonus_base if (is_raid and ripe_wheat_active) else 0

    effective_base = zone_base + active_ripe_add + grass_bonus + bp_bonus + hw_bonus + sec_expected

    # Min base (no secondary) and max base (with best secondary / ripe bonus)
    sec_kind = z_info.get("SecondaryKind")
    sec_mult = float(z_info.get("SecondaryValue", 1.0))
    if is_raid:
        max_sec_val = float(zone_base) * (sec_mult - 1.0) + ripe_bonus_base
    elif sec_kind == "Mushroom":
        max_sec_val = SECONDARIES_BASE["GoldMushroom"] * sec_mult
    elif sec_kind and sec_kind in SECONDARIES_BASE:
        max_sec_val = SECONDARIES_BASE[sec_kind] * sec_mult
    else:
        max_sec_val = 0.0
    min_base = zone_base + grass_bonus + bp_bonus + hw_bonus
    max_base = zone_base + grass_bonus + bp_bonus + hw_bonus + max_sec_val

    # 2. Multipliers
    rebirth_mult = get_rebirth_multiplier(rebirth, all_auras_completed=all_auras_completed)
    node_mult = get_expected_node_multiplier(zone, lucky_clover_level)

    combo_cap, max_rumen_mult = get_rumen_stats(rumen_level)
    if combo_mode == "max":
        combo_stacks = combo_cap
        rumen_mult = max_rumen_mult
    elif combo_mode == "zero":
        combo_stacks = 0
        rumen_mult = 1.0
    elif combo_mode == "half":
        combo_stacks = combo_cap // 2
        rumen_mult = 1.0 + combo_stacks * 0.02
    else:
        try:
            combo_stacks = max(0, min(combo_cap, int(combo_mode)))
            rumen_mult = 1.0 + combo_stacks * 0.02
        except ValueError:
            combo_stacks = combo_cap
            rumen_mult = max_rumen_mult

    comp_mult = get_companion_multiplier(companion_bond)

    # Title Buff: GrazingTitleMultiplier
    title_mult = TITLES.get(title, TITLES["None"])["Multiplier"]

    # Back Bunnies: 1% grazing calories per bunny on back (0 to 5)
    bunnies_count = max(0, min(5, int(back_bunnies)))
    bunnies_mult = 1.0 + (bunnies_count * 0.01)

    # Pillar: Grazer adds +10% PillarBonus in GrassEconomy on Grass/Honeycomb (0 on Wheat)
    pillar_bonus = 0.0 if is_raid else PILLARS.get(pillar, PILLARS["None"])["Bonus"]
    pillar_mult = 1.0 + pillar_bonus

    # Alpha V3.0.0 IntakeMultiplier (Davy Jones Heart 2x, Bionic Stomach 1.33x, Strong Chompers in Raids)
    chompers_lvl = max(0, min(RAID_POWERUP_MAX_LEVEL, int(strong_chompers_level)))
    davy_m, stomach_m, chompers_m = get_intake_multiplier(
        davy_jones_heart=davy_jones_heart,
        bionic_stomach=bionic_stomach,
        strong_chompers_level=chompers_lvl,
        is_field_raid=is_raid,
    )
    intake_mult = davy_m * stomach_m * chompers_m

    # Alpha V3.0.0 ExcursionMultiplier (Trailblazer Aura)
    effective_on_excursion = is_raid if on_excursion is None else bool(on_excursion or is_raid)
    tb_lvl = max(0, min(TRAILBLAZER_MAX_LEVEL, int(trailblazer_level)))
    excursion_mult = get_excursion_multiplier(
        trailblazer_level=tb_lvl,
        trailblazer_branch=trailblazer_branch,
        on_excursion=effective_on_excursion,
    )

    # Weekend Event Multiplier (1.5x calories)
    weekend_mult = WEEKEND_CALORIE_MULTIPLIER if weekend_event else 1.0

    gp_mult = 2.0 if gamepass_2x else 1.0
    external_mult = gp_mult * other_multiplier

    total_mult = (
        intake_mult
        * rebirth_mult
        * node_mult
        * rumen_mult
        * comp_mult
        * title_mult
        * bunnies_mult
        * excursion_mult
        * weekend_mult
        * pillar_mult
        * external_mult
    )

    # 3. Expected Yield (per bite)
    avg_yield = effective_base * total_mult

    # Ripe wheat single-bite yield (in Field Raids when Ripe Bell window is open)
    ripe_single_base = zone_base + ripe_bonus_base + bp_bonus + hw_bonus
    ripe_bite_yield = ripe_single_base * total_mult if is_raid else avg_yield

    # Min bite (no secondary, ordinary non-golden node)
    min_mult = (
        intake_mult
        * rebirth_mult
        * 1.0
        * rumen_mult
        * comp_mult
        * title_mult
        * bunnies_mult
        * excursion_mult
        * weekend_mult
        * pillar_mult
        * external_mult
    )
    min_yield = int(math.floor(min_base * min_mult))

    # Max bite (max secondary/ripe, golden node 2.0x on grass or 1.0x in raid)
    max_node_mult = 1.0 if is_raid else 2.0
    max_mult = (
        intake_mult
        * rebirth_mult
        * max_node_mult
        * max_rumen_mult
        * comp_mult
        * title_mult
        * bunnies_mult
        * excursion_mult
        * weekend_mult
        * pillar_mult
        * external_mult
    )
    max_yield = int(math.floor(max_base * max_mult))

    # 4. Pacing, Mushroom Island Patch & Progression
    cooldown = get_chew_cooldown(chew_speed_level, is_field_raid=is_raid)
    bite_cal_per_sec = avg_yield / cooldown if cooldown > 0 else 0.0

    mi_lvl = int(mushroom_island_level) if (is_raid and mushroom_island_level is not None and mushroom_island_level >= 0) else -1
    patch_rate, patch_cap = get_mushroom_island_stats(mi_lvl if is_raid else -1)
    cal_per_sec = bite_cal_per_sec + patch_rate

    next_req = get_rebirth_requirement(
        rebirth,
        spirit_lanterns=spirit_lanterns,
        weekend_discount=weekend_event,
    )
    bites_to_rebirth = next_req / avg_yield if avg_yield > 0 else float("inf")
    sec_to_rebirth = next_req / cal_per_sec if cal_per_sec > 0 else float("inf")

    return BiteCalculation(
        rebirth=rebirth,
        all_auras_completed=all_auras_completed,
        rebirth_multiplier=rebirth_mult,
        spirit_lanterns=max(0, int(spirit_lanterns)),
        weekend_event=weekend_event,
        zone=zone,
        is_field_raid=is_raid,
        raid_level=raid_lvl,
        zone_base=zone_base,
        ripe_wheat_active=bool(is_raid and ripe_wheat_active),
        ripe_bonus_base=ripe_bonus_base,
        grass_type=grass_type,
        grass_bonus=grass_bonus,
        bite_power_level=bite_power_level,
        bite_power_bonus=bp_bonus,
        headwear=headwear,
        headwear_bonus=hw_bonus,
        expected_secondary_bonus=sec_expected,
        effective_base_calories=effective_base,
        davy_jones_heart=davy_jones_heart,
        bionic_stomach=bionic_stomach,
        strong_chompers_level=chompers_lvl if is_raid else 0,
        strong_chompers_multiplier=chompers_m,
        intake_multiplier=intake_mult,
        trailblazer_level=tb_lvl,
        trailblazer_branch=trailblazer_branch,
        excursion_multiplier=excursion_mult,
        weekend_multiplier=weekend_mult,
        golden_chance=z_info["GoldenChance"],
        expected_node_multiplier=node_mult,
        rumen_level=rumen_level,
        combo_stacks=combo_stacks,
        rumen_multiplier=rumen_mult,
        companion_bond=companion_bond,
        companion_multiplier=comp_mult,
        title=title,
        title_multiplier=title_mult,
        back_bunnies=bunnies_count,
        back_bunnies_multiplier=bunnies_mult,
        pillar=pillar,
        pillar_multiplier=pillar_mult,
        gamepass_2x=gamepass_2x,
        other_multiplier=other_multiplier,
        total_multiplier=total_mult,
        avg_bite_calories=avg_yield,
        ripe_bite_calories=ripe_bite_yield,
        min_bite_calories=max(1, min_yield),
        max_bite_calories=max(1, max_yield),
        chew_speed_level=chew_speed_level,
        chew_cooldown=cooldown,
        bite_calories_per_second=bite_cal_per_sec,
        mushroom_island_level=mi_lvl,
        mushroom_patch_cal_per_sec=patch_rate,
        mushroom_patch_capacity=patch_cap,
        calories_per_second=cal_per_sec,
        next_rebirth_requirement=next_req,
        expected_bites_to_rebirth=bites_to_rebirth,
        expected_seconds_to_rebirth=sec_to_rebirth,
    )


# --- Formatting & Output ---

def format_rebirth_summary(calc: BiteCalculation) -> str:
    """Format single calculation summary including Alpha V3.0.0 bonuses & Field Raids."""
    aura_tag = " [All Auras Mastered 2×]" if calc.all_auras_completed else ""
    lantern_tag = f" (Spirit Lanterns: {calc.spirit_lanterns} → ÷{2**calc.spirit_lanterns})" if calc.spirit_lanterns > 0 else ""
    wknd_tag = " [Weekend -10% Req]" if calc.weekend_event else ""

    lines = [
        "================================================================================",
        f"🐄 COW GAME REBIRTH & BITE CALORIE CALCULATOR — V3.0.0 (Rebirth {calc.rebirth})",
        "================================================================================",
        f"• Grass Multiplier (Rebirth {calc.rebirth}):   {calc.rebirth_multiplier:,.4f}×{aura_tag}  (+{(calc.rebirth_multiplier - 1.0) * 100:,.1f}% vs R0)",
        f"• Next Rebirth Requirement (R{calc.rebirth}→R{calc.rebirth + 1}): {calc.next_rebirth_requirement:,} Calories{lantern_tag}{wknd_tag}",
        f"• Cumulative Prior Rebirth Cost:      {get_cumulative_rebirth_calories(calc.rebirth, weekend_discount=calc.weekend_event):,} Calories",
        "--------------------------------------------------------------------------------",
        "BITE CALORIE COMPONENTS:",
        f"  Zone ({calc.zone}):                 {calc.zone_base:,} base (Category: {ZONES[calc.zone]['Category']})",
    ]
    if calc.is_field_raid:
        ripe_status = "ACTIVE included in base" if calc.ripe_wheat_active else f"Bell burst: +{calc.ripe_bonus_base:,} base ({calc.ripe_bite_calories:,.1f} Cal/bite)"
        lines.append(f"  Field Raid Ripe Wheat Bonus:       +{calc.ripe_bonus_base if calc.ripe_wheat_active else 0:,} base ({ripe_status})")
    else:
        lines.append(f"  Grass Type ({calc.grass_type}):           +{calc.grass_bonus} base")
    lines.extend([
        f"  Bite Power Upgrade (Lvl {calc.bite_power_level:02d}/25):   +{calc.bite_power_bonus} base [formula: L*(L+3)/2]",
        f"  Headwear Hat ({calc.headwear}):           +{calc.headwear_bonus} base (MiningHatConfig)",
        f"  Expected Secondary Growth:         +{calc.expected_secondary_bonus:.2f} base (Spawn rate: {ZONES[calc.zone]['SecondaryRate']*100:.0f}%)",
        f"  = Total Effective Base:            {calc.effective_base_calories:,.2f} Calories",
        "--------------------------------------------------------------------------------",
        "MULTIPLIERS APPLIED (GrassEconomy v3):",
        f"  Rebirth Multiplier:                {calc.rebirth_multiplier:,.4f}×  (1.22^{calc.rebirth}{' × 2 All Auras' if calc.all_auras_completed else ''})",
        f"  Intake Multiplier (V3.0 Items):    {calc.intake_multiplier:.4f}×  (DavyHeart: {'2.0×' if calc.davy_jones_heart else '1.0×'}, BionicStomach: {'1.33×' if calc.bionic_stomach else '1.0×'}, Chompers: {calc.strong_chompers_multiplier:.2f}×)",
        f"  Excursion Multiplier (Trailblazer):{calc.excursion_multiplier:.4f}×  (Lvl {calc.trailblazer_level}/5, Branch: {calc.trailblazer_branch})",
        f"  Node Quality (Golden avg):         {calc.expected_node_multiplier:.4f}×  (Golden chance: {calc.golden_chance*100:.2f}%)",
        f"  Rumen Combo (Lvl {calc.rumen_level:02d}, {calc.combo_stacks} stacks):    {calc.rumen_multiplier:.2f}×  (+2% per stack, cap: {get_rumen_stats(calc.rumen_level)[0]})",
        f"  Companion Multiplier (Bond {calc.companion_bond:.2f}):  {calc.companion_multiplier:.4f}×  (max: 1.15×)",
        f"  Title Buff ({calc.title}):             {calc.title_multiplier:.2f}×  (Title_CloverMarbles +3% Cal)",
        f"  Back Friends ({calc.back_bunnies} Bunnies):        {calc.back_bunnies_multiplier:.2f}×  (+1% per bunny on back)",
        f"  Pillar Bonus ({calc.pillar}):             {calc.pillar_multiplier:.2f}×  ({'N/A on Raid Wheat' if calc.is_field_raid else 'Grazer +10% grass Cal'})",
        f"  Weekend / 2x Gamepass:             {calc.weekend_multiplier * (2.0 if calc.gamepass_2x else 1.0):.2f}×  (Weekend: {calc.weekend_multiplier:.1f}×, 2x GP: {2.0 if calc.gamepass_2x else 1.0:.1f}×)",
        f"  = Combined Total Multiplier:       {calc.total_multiplier:,.4f}×",
        "--------------------------------------------------------------------------------",
        "CALORIE YIELD & PROGRESSION PACING:",
        f"  ★ AVERAGE BITE YIELD:              {calc.avg_bite_calories:,.1f} Calories / bite",
    ])
    if calc.is_field_raid:
        lines.append(f"  ★ RIPE WHEAT BELL BITE YIELD:      {calc.ripe_bite_calories:,.1f} Calories / ripe bite")
    lines.extend([
        f"  • Single Bite Range:               {calc.min_bite_calories:,} (plain min) – {calc.max_bite_calories:,} (max)",
        f"  • Chew Cooldown (Speed Lvl {calc.chew_speed_level:02d}):   {calc.chew_cooldown:.2f}s per bite{' (0.5× Field Raid Wheat speed)' if calc.is_field_raid else ''}",
        f"  • Grazing Bite Rate:               {calc.bite_calories_per_second:,.1f} Calories / sec",
    ])
    if calc.mushroom_patch_cal_per_sec > 0:
        lines.append(
            f"  • Mushroom Island Patch (Lvl {calc.mushroom_island_level:02d}): +{calc.mushroom_patch_cal_per_sec:,} Calories / sec (Cap: {calc.mushroom_patch_capacity:,} Cal)"
        )
    lines.extend([
        f"  • Total Calorie Gain Rate:         {calc.calories_per_second:,.1f} Calories / sec  ({calc.calories_per_second * 3600:,.0f} Cal/hr)",
        f"  • Expected Bites to Next Rebirth:  {calc.expected_bites_to_rebirth:,.0f} bites",
        f"  • Expected Time to Next Rebirth:   {calc.expected_seconds_to_rebirth / 60:.1f} minutes  ({calc.expected_seconds_to_rebirth / 3600:.2f} hours)",
        "================================================================================",
    ])
    return "\n".join(lines)


def format_progression_table(
    max_rebirth: int = 25,
    zone: str = "HomeMeadow",
    grass_type: str = "Regular",
    bite_power_level: int = 25,
    rumen_level: int = 10,
    companion_bond: float = 1.0,
    chew_speed_level: int = 15,
    headwear: str = "None",
    title: str = "None",
    back_bunnies: int = 0,
    pillar: str = "None",
    gamepass_2x: bool = False,
    all_auras_completed: bool = False,
    spirit_lanterns: int = 0,
    davy_jones_heart: bool = False,
    bionic_stomach: bool = False,
    trailblazer_level: int = 0,
    trailblazer_branch: str = "None",
    weekend_event: bool = False,
    strong_chompers_level: int = 0,
    mushroom_island_level: int = -1,
    ripe_wheat_active: bool = False,
) -> str:
    """Print an ASCII table showing progression from Rebirth 0 up to max_rebirth."""
    header = (
        f"| {'Rebirth':^7} | {'Multiplier':^11} | {'Requirement':^15} | "
        f"{'Avg Bite Cal':^14} | {'Cal / Sec':^13} | {'Bites to Rebirth':^16} | {'Time to Rebirth':^15} |"
    )
    divider = "+" + "+".join("-" * (len(col) + 2) for col in [
        "  Rebirth", "  Multiplier ", "   Requirement  ", "  Avg Bite Cal ",
        "   Cal / Sec  ", " Bites to Rebirth ", " Time to Rebirth "
    ]) + "+"

    rows = [
        f"REBIRTH PROGRESSION TABLE ({zone}, Grass: {grass_type}, DavyHeart: {davy_jones_heart}, Stomach: {bionic_stomach})",
        divider,
        header,
        divider,
    ]

    for r in range(max_rebirth + 1):
        calc = calculate_bite_yield(
            rebirth=r,
            zone=zone,
            grass_type=grass_type,
            bite_power_level=bite_power_level,
            rumen_level=rumen_level,
            companion_bond=companion_bond,
            chew_speed_level=chew_speed_level,
            headwear=headwear,
            title=title,
            back_bunnies=back_bunnies,
            pillar=pillar,
            gamepass_2x=gamepass_2x,
            all_auras_completed=all_auras_completed,
            spirit_lanterns=spirit_lanterns,
            davy_jones_heart=davy_jones_heart,
            bionic_stomach=bionic_stomach,
            trailblazer_level=trailblazer_level,
            trailblazer_branch=trailblazer_branch,
            weekend_event=weekend_event,
            strong_chompers_level=strong_chompers_level,
            mushroom_island_level=mushroom_island_level,
            ripe_wheat_active=ripe_wheat_active,
        )
        mins = calc.expected_seconds_to_rebirth / 60.0
        time_str = f"{mins:,.1f} min" if mins < 120 else f"{mins / 60:,.1f} hrs"
        row = (
            f"| {r:^7d} | {calc.rebirth_multiplier:^11.4f} | {calc.next_rebirth_requirement:^15,d} | "
            f"{calc.avg_bite_calories:^14,.1f} | {calc.calories_per_second:^13,.1f} | "
            f"{calc.expected_bites_to_rebirth:^16,.0f} | {time_str:^15} |"
        )
        rows.append(row)

    rows.append(divider)
    return "\n".join(rows)


def format_zone_comparison(
    rebirth: int = 0,
    grass_type: str = "Regular",
    bite_power_level: int = 25,
    rumen_level: int = 10,
    companion_bond: float = 1.0,
    chew_speed_level: int = 15,
    headwear: str = "None",
    title: str = "None",
    back_bunnies: int = 0,
    pillar: str = "None",
    gamepass_2x: bool = False,
    all_auras_completed: bool = False,
    spirit_lanterns: int = 0,
    davy_jones_heart: bool = False,
    bionic_stomach: bool = False,
    trailblazer_level: int = 0,
    trailblazer_branch: str = "None",
    weekend_event: bool = False,
    strong_chompers_level: int = 0,
    mushroom_island_level: int = -1,
) -> str:
    """Compare average bite yield across all zones (including Field Raids) at a given rebirth."""
    header = (
        f"| {'Zone':^18} | {'Category':^9} | {'Base+Sec':^10} | "
        f"{'Avg Bite Cal':^14} | {'Cal / Sec':^13} | {'Time to Next':^14} | {'Unlock':^8} |"
    )
    divider = "+" + "+".join("-" * (len(col) + 2) for col in [
        "       Zone       ", " Category", " Base+Sec ", "  Avg Bite Cal ",
        "   Cal / Sec  ", " Time to Next ", "  Unlock"
    ]) + "+"

    rows = [
        f"ZONE COMPARISON AT REBIRTH {rebirth} (Grass: {grass_type}, Hat: {headwear}, Title: {title})",
        divider,
        header,
        divider,
    ]

    for z_name, z_info in ZONES.items():
        calc = calculate_bite_yield(
            rebirth=rebirth,
            zone=z_name,
            grass_type=grass_type,
            bite_power_level=bite_power_level,
            rumen_level=rumen_level,
            companion_bond=companion_bond,
            chew_speed_level=chew_speed_level,
            headwear=headwear,
            title=title,
            back_bunnies=back_bunnies,
            pillar=pillar,
            gamepass_2x=gamepass_2x,
            all_auras_completed=all_auras_completed,
            spirit_lanterns=spirit_lanterns,
            davy_jones_heart=davy_jones_heart,
            bionic_stomach=bionic_stomach,
            trailblazer_level=trailblazer_level,
            trailblazer_branch=trailblazer_branch,
            weekend_event=weekend_event,
            strong_chompers_level=strong_chompers_level,
            mushroom_island_level=mushroom_island_level,
        )
        unlock_str = "Unlocked" if rebirth >= z_info["MinRebirth"] else f"Req R{z_info['MinRebirth']}"
        base_sec = f"{calc.effective_base_calories:,.1f}"
        mins = calc.expected_seconds_to_rebirth / 60.0
        time_str = f"{mins:,.1f} min" if mins < 120 else f"{mins / 60:,.1f} hrs"
        row = (
            f"| {z_name:<18} | {z_info['Category']:^9} | {base_sec:^10} | "
            f"{calc.avg_bite_calories:^14,.1f} | {calc.calories_per_second:^13,.1f} | "
            f"{time_str:^14} | {unlock_str:^8} |"
        )
        rows.append(row)

    rows.append(divider)
    return "\n".join(rows)


def format_field_raid_comparison(
    rebirth: int = 20,
    bite_power_level: int = 25,
    rumen_level: int = 10,
    companion_bond: float = 1.0,
    chew_speed_level: int = 15,
    headwear: str = "Mythic",
    title: str = "CloverMarbles",
    back_bunnies: int = 5,
    gamepass_2x: bool = False,
    all_auras_completed: bool = False,
    spirit_lanterns: int = 0,
    davy_jones_heart: bool = False,
    bionic_stomach: bool = False,
    trailblazer_level: int = 5,
    trailblazer_branch: str = "Adventurous",
    weekend_event: bool = False,
    strong_chompers_level: int = 0,
    mushroom_island_level: int = -1,
) -> str:
    """Compare all 10 Field Raid levels at a given rebirth, showing ordinary wheat, ripe wheat bonus, and pacing."""
    header = (
        f"| {'Field':^7} | {'Name':^22} | {'Base Cal':^9} | {'Ripe Base':^11} | "
        f"{'Avg Bite Cal':^14} | {'Ripe Bite Cal':^15} | {'Cal / Sec':^13} | {'Time to Rebirth':^15} |"
    )
    divider = "+" + "+".join("-" * (len(col) + 2) for col in [
        " Field ", "         Name         ", " Base Cal", " Ripe Base ",
        "  Avg Bite Cal ", " Ripe Bite Cal ", "   Cal / Sec  ", " Time to Rebirth "
    ]) + "+"

    rows = [
        f"🌾 NORTH RIVER FIELD RAIDS COMPARISON AT REBIRTH {rebirth} "
        f"(Chompers L{max(0, strong_chompers_level)}, Trailblazer L{trailblazer_level}, "
        f"DavyHeart: {davy_jones_heart}, Stomach: {bionic_stomach})",
        divider,
        header,
        divider,
    ]

    for lvl in range(1, 11):
        f_info = FIELD_RAID_FIELDS[lvl]
        z_key = f_info["ZoneKey"]
        calc = calculate_bite_yield(
            rebirth=rebirth,
            zone=z_key,
            bite_power_level=bite_power_level,
            rumen_level=rumen_level,
            companion_bond=companion_bond,
            chew_speed_level=chew_speed_level,
            headwear=headwear,
            title=title,
            back_bunnies=back_bunnies,
            gamepass_2x=gamepass_2x,
            all_auras_completed=all_auras_completed,
            spirit_lanterns=spirit_lanterns,
            davy_jones_heart=davy_jones_heart,
            bionic_stomach=bionic_stomach,
            trailblazer_level=trailblazer_level,
            trailblazer_branch=trailblazer_branch,
            weekend_event=weekend_event,
            strong_chompers_level=strong_chompers_level,
            mushroom_island_level=mushroom_island_level,
        )
        mins = calc.expected_seconds_to_rebirth / 60.0
        time_str = f"{mins:,.1f} min" if mins < 120 else f"{mins / 60:,.1f} hrs"
        row = (
            f"| {f'F{lvl}':^7} | {f_info['Name']:<22} | {f_info['BaseCalories']:^9,d} | "
            f"{'+' + format(calc.ripe_bonus_base, ',d'):^11} | "
            f"{calc.avg_bite_calories:^14,.1f} | {calc.ripe_bite_calories:^15,.1f} | "
            f"{calc.calories_per_second:^13,.1f} | {time_str:^15} |"
        )
        rows.append(row)

    rows.append(divider)
    ripe_opps = get_field_raid_ripe_opportunities(rebirth)
    rows.append(
        f"  • Raid Wheat Chew Cooldown: 0.5× normal ({get_chew_cooldown(chew_speed_level, True):.2f}s/bite) | "
        f"Ripe Bell Opportunities: {ripe_opps:g} per field outing (8s window)"
    )
    return "\n".join(rows)


# --- CLI Parser ---

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Cow Game Rebirth Grass Multiplier & Average Bite Calorie Yield Calculator (Alpha V3.0.0)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("-n", "--rebirth", type=int, default=0, help="Rebirth count n (>= 0)")
    parser.add_argument(
        "-z", "--zone",
        type=str,
        default="HomeMeadow",
        choices=list(ZONES.keys()),
        help="Zone or Field Raid (HomeMeadow..Cave, FieldRaid1..FieldRaid10)",
    )
    parser.add_argument(
        "-g", "--grass",
        type=str,
        default="Regular",
        choices=list(GRASS_TYPES.keys()),
        help="Grass type/seeds (Regular, Redgrass, Bluegrass)",
    )
    parser.add_argument("-b", "--bite-power", type=int, default=25, help="Bite Power upgrade level (0 to 25)")
    parser.add_argument("-r", "--rumen", type=int, default=10, help="Rumen upgrade level (0 to 10)")
    parser.add_argument("--combo", type=str, default="max", help="Rumen combo stacks: 'max', 'zero', 'half', or integer")
    parser.add_argument("-c", "--companion", type=float, default=1.0, help="Companion bond (0.0 to 1.0)")
    parser.add_argument("-s", "--chew-speed", type=int, default=15, help="Chew Speed upgrade level (0 to 15)")
    parser.add_argument("--hat", type=str, default="None", choices=list(HEADWEAR_BONUSES.keys()), help="Headwear / Mining Hat cosmetic")
    parser.add_argument("--title", type=str, default="None", choices=list(TITLES.keys()), help="Equipped Title perk")
    parser.add_argument("--bunnies", type=int, default=0, choices=[0, 1, 2, 3, 4, 5], help="Back Bunnies equipped (0-5)")
    parser.add_argument("--pillar", type=str, default="None", choices=list(PILLARS.keys()), help="Active Pillar buff")
    parser.add_argument("--gamepass", action="store_true", help="Enable 2x Calories Gamepass")
    parser.add_argument("--clover-aura", type=int, default=0, help="Lucky Clover aura level (0 to 5)")

    # Alpha V3.0.0 Progression & Field Raid arguments
    parser.add_argument("--all-auras", action="store_true", help="All 5 aura paths mastered (2x Rebirth Multiplier)")
    parser.add_argument("--spirit-lanterns", type=int, default=0, help="Lit Spirit Lanterns (halves next rebirth cost per lantern)")
    parser.add_argument("--davy-heart", action="store_true", help="Heart o' Davy Jones attuned (permanent 2x calorie intake)")
    parser.add_argument("--bionic-stomach", action="store_true", help="Bionic Stomach enabled (1.33x calorie intake)")
    parser.add_argument("--trailblazer", type=int, default=0, help="Trailblazer aura level (0 to 5, +20%% cal/lvl on excursions)")
    parser.add_argument(
        "--trailblazer-branch",
        type=str,
        default="None",
        choices=["None", "Adventurous", "Unrelenting"],
        help="Trailblazer branch at Lvl 3+ (Adventurous adds 1.02^1 or 1.02^2 excursion calories)",
    )
    parser.add_argument("--weekend", action="store_true", help="Weekend Event active (1.5x calories & -10%% rebirth requirement)")
    parser.add_argument("--strong-chompers", type=int, default=0, help="Field Raid Strong Chompers powerup level (0 to 99)")
    parser.add_argument("--mushroom-island", type=int, default=-1, help="Field Raid Mushroom Island powerup level (-1=off, 0 to 99)")
    parser.add_argument("--ripe-wheat", action="store_true", help="Evaluate Field Raid bite during Ripe Wheat bell window")
    parser.add_argument("--compare-raids", action="store_true", help="Display comparison across all 10 Field Raid levels")

    parser.add_argument("--table", action="store_true", help="Display progression table across rebirths 0 to N")
    parser.add_argument("--max-rebirth", type=int, default=25, help="Maximum rebirth for the progression table")
    parser.add_argument("--compare-zones", action="store_true", help="Display side-by-side comparison across all zones")
    parser.add_argument("--json", action="store_true", help="Output raw JSON instead of formatted text")
    parser.add_argument("--gui", action="store_true", help="Launch the interactive desktop GUI application")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.gui:
        try:
            import grass_calorie_gui
            grass_calorie_gui.main()
            return
        except ImportError:
            from scripts import grass_calorie_gui
            grass_calorie_gui.main()
            return

    calc = calculate_bite_yield(
        rebirth=args.rebirth,
        zone=args.zone,
        grass_type=args.grass,
        bite_power_level=args.bite_power,
        rumen_level=args.rumen,
        combo_mode=args.combo,
        companion_bond=args.companion,
        chew_speed_level=args.chew_speed,
        headwear=args.hat,
        title=args.title,
        back_bunnies=args.bunnies,
        pillar=args.pillar,
        gamepass_2x=args.gamepass,
        lucky_clover_level=args.clover_aura,
        all_auras_completed=args.all_auras,
        spirit_lanterns=args.spirit_lanterns,
        davy_jones_heart=args.davy_heart,
        bionic_stomach=args.bionic_stomach,
        trailblazer_level=args.trailblazer,
        trailblazer_branch=args.trailblazer_branch,
        weekend_event=args.weekend,
        strong_chompers_level=args.strong_chompers,
        mushroom_island_level=args.mushroom_island,
        ripe_wheat_active=args.ripe_wheat,
    )

    if args.json:
        data = asdict(calc)
        print(json.dumps(data, indent=2))
        return

    print(format_rebirth_summary(calc))

    if args.compare_raids:
        print("\n" + format_field_raid_comparison(
            rebirth=args.rebirth,
            bite_power_level=args.bite_power,
            rumen_level=args.rumen,
            companion_bond=args.companion,
            chew_speed_level=args.chew_speed,
            headwear=args.hat,
            title=args.title,
            back_bunnies=args.bunnies,
            gamepass_2x=args.gamepass,
            all_auras_completed=args.all_auras,
            spirit_lanterns=args.spirit_lanterns,
            davy_jones_heart=args.davy_heart,
            bionic_stomach=args.bionic_stomach,
            trailblazer_level=args.trailblazer,
            trailblazer_branch=args.trailblazer_branch,
            weekend_event=args.weekend,
            strong_chompers_level=args.strong_chompers,
            mushroom_island_level=args.mushroom_island,
        ))

    if args.compare_zones:
        print("\n" + format_zone_comparison(
            rebirth=args.rebirth,
            grass_type=args.grass,
            bite_power_level=args.bite_power,
            rumen_level=args.rumen,
            companion_bond=args.companion,
            chew_speed_level=args.chew_speed,
            headwear=args.hat,
            title=args.title,
            back_bunnies=args.bunnies,
            pillar=args.pillar,
            gamepass_2x=args.gamepass,
            all_auras_completed=args.all_auras,
            spirit_lanterns=args.spirit_lanterns,
            davy_jones_heart=args.davy_heart,
            bionic_stomach=args.bionic_stomach,
            trailblazer_level=args.trailblazer,
            trailblazer_branch=args.trailblazer_branch,
            weekend_event=args.weekend,
            strong_chompers_level=args.strong_chompers,
            mushroom_island_level=args.mushroom_island,
        ))

    if args.table:
        print("\n" + format_progression_table(
            max_rebirth=args.max_rebirth,
            zone=args.zone,
            grass_type=args.grass,
            bite_power_level=args.bite_power,
            rumen_level=args.rumen,
            companion_bond=args.companion,
            chew_speed_level=args.chew_speed,
            headwear=args.hat,
            title=args.title,
            back_bunnies=args.bunnies,
            pillar=args.pillar,
            gamepass_2x=args.gamepass,
            all_auras_completed=args.all_auras,
            spirit_lanterns=args.spirit_lanterns,
            davy_jones_heart=args.davy_heart,
            bionic_stomach=args.bionic_stomach,
            trailblazer_level=args.trailblazer,
            trailblazer_branch=args.trailblazer_branch,
            weekend_event=args.weekend,
            strong_chompers_level=args.strong_chompers,
            mushroom_island_level=args.mushroom_island,
            ripe_wheat_active=args.ripe_wheat,
        ))


if __name__ == "__main__":
    main()
