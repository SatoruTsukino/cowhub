#!/usr/bin/env python3
"""Grass Multiplier and Average Bite Calorie Yield Calculator for Cow Game.

Mirrors the decompiled Cow Game modules (Opiumware workspace dumps):
  Config.Rebirth:
    CaloriesMultiplierPerRebirth = 0.22 (compound 1.22^n)
    BaseRequirement = 10,000, GrowthRate = 2 (10,000 * 2^n)
  GrassEconomy.Calculate:
    Base calories = Zone Category BaseValue + GrassType Bonus + BitePower Bonus
    + Headwear/Helmet BaseCalories Bonus
    + Expected Secondary Growth (Clover, Mushroom, Barley, Wheat, Apple)
    * Node Modifiers (Golden 2.0x, etc.)
    * Maturity (1.0 at full growth)
    * RumenMultiplier (1 + 0.02 * Combo)
    * RebirthMultiplier ((1 + 0.22)^n)
    * GrazingTitleMultiplier (e.g. 1.03x from Title_CloverMarbles)
    * Back Friend Bonus (1.01x to 1.05x from 1-5 Back Bunnies)
    * CompanionMultiplier (1 + 0.15 * Bond, clamped [1.0, 1.15])
    * PillarBonus (1 + PillarBonus, e.g. 1.10x from Grazer Pillar)
    * Optional Gamepasses / Event boosts / Herd
  UpgradeConfig:
    BitePowerBonus = level * (level + 3) / 2  (Max Level 25 -> +350 base)
    Rumen ComboCap = level * 2 + 20           (Max Level 10 -> Cap 40 -> 1.80x)
  FoodConfig:
    Fields1: Base = 7,  Golden = 0.005,  SecondaryRate = 0.10
    Fields2: Base = 14, Golden = 0.0075, SecondaryRate = 0.15
    Fields3: Base = 21, Golden = 0.010,  SecondaryRate = 0.25
    Cave:    Base = 28, Golden = 0.030,  SecondaryRate = 0.33
  HelmetBonuses & MiningHatConfig:
    Common: +5, Uncommon: +10, Rare: +15, Super Rare: +20, Mythic: +25 Base Calories
  TitleCatalog & CloverQuestConfig:
    Title_CloverMarbles ("Who Found Clover’s Lost Marbles"): +3% grazing Calories
  PillarConfig:
    Grazer: +10% Calories from grass
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

CHEW_BASE_COOLDOWN = 0.7  # UpgradeConfig.GetDerived ChewCooldown
CHEW_MIN_COOLDOWN = 0.4

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

# Zone Definitions (FoodConfig.Categories & FoodConfig.FieldGroups & SecondaryKinds)
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
        "Description": "Cavern zone with high base (28) and 1.5x mushrooms.",
    },
}


# --- Calculation Helpers ---

def get_rebirth_multiplier(rebirth: int) -> float:
    """Calculate the grass/calorie multiplier for rebirth n.

    Config.luau: (1 + Config.Rebirth.CaloriesMultiplierPerRebirth) ^ n
    = 1.22 ^ n.
    """
    n = max(0, int(rebirth))
    return (1.0 + REBIRTH_MULTIPLIER_STEP) ** n


def get_rebirth_requirement(rebirth: int) -> int:
    """Calculate the calories required to perform rebirth n -> n + 1.

    Config.luau: round(BaseRequirement * GrowthRate ^ n / Rounding) * Rounding
    = round(10000 * 2^n / 100) * 100 = 10000 * 2^n.
    """
    n = max(0, int(rebirth))
    req = REBIRTH_BASE_REQUIREMENT * (REBIRTH_GROWTH_RATE ** n)
    return int(round(req / REBIRTH_REQUIREMENT_ROUNDING) * REBIRTH_REQUIREMENT_ROUNDING)


def get_cumulative_rebirth_calories(target_rebirth: int) -> int:
    """Total cumulative calories required to go from Rebirth 0 to target_rebirth."""
    n = max(0, int(target_rebirth))
    return sum(get_rebirth_requirement(i) for i in range(n))


def get_bite_power_bonus(level: int) -> int:
    """Bite Power upgrade flat base calorie bonus.

    UpgradeConfig.luau: level * (level + 3) / 2
    """
    lvl = max(0, min(int(level), BITE_POWER_MAX_LEVEL))
    return (lvl * (lvl + 3)) // 2


def get_chew_cooldown(chew_speed_level: int) -> float:
    """Chew cooldown in seconds based on Chew Speed upgrade.

    UpgradeConfig.luau: max(0.4, 0.7 - kickPower * 0.02)
    """
    lvl = max(0, min(int(chew_speed_level), CHEW_SPEED_MAX_LEVEL))
    return max(CHEW_MIN_COOLDOWN, CHEW_BASE_COOLDOWN - lvl * 0.02)


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
    If bond is 0 (no companion), returns 1.0.
    Untamed base bond = 0.25 -> 1.0375x (+3.75%)
    Max bond = 1.0 -> 1.1500x (+15.00%)
    """
    if bond <= 0:
        return 1.0
    return max(1.0, min(1.15, 1.0 + bond * 0.15))


def get_expected_secondary_bonus(zone_name: str) -> float:
    """Expected calorie bonus per grass node from secondary growth spawns.

    GrassEconomy: SecondaryBase * Zone.SecondaryValue when spawned.
    Expected = SecondaryRate * (SecondaryBase * SecondaryValue).
    """
    zone = ZONES.get(zone_name, ZONES["HomeMeadow"])
    sec_kind = zone.get("SecondaryKind")
    if not sec_kind:
        return 0.0

    rate = float(zone.get("SecondaryRate", 0.0))
    sec_mult = float(zone.get("SecondaryValue", 1.0))

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
    """
    zone = ZONES.get(zone_name, ZONES["HomeMeadow"])
    base_golden_chance = float(zone.get("GoldenChance", 0.005))
    aura_boost = max(0, lucky_clover_level) * 0.03
    p_gold = min(1.0, base_golden_chance + aura_boost)
    return 1.0 + p_gold * (2.0 - 1.0)


# --- Core Calculator Data Models & Engine ---

@dataclass
class BiteCalculation:
    rebirth: int
    rebirth_multiplier: float
    zone: str
    zone_base: int
    grass_type: str
    grass_bonus: int
    bite_power_level: int
    bite_power_bonus: int
    headwear: str
    headwear_bonus: int
    expected_secondary_bonus: float
    effective_base_calories: float
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
    min_bite_calories: int
    max_bite_calories: int
    chew_speed_level: int
    chew_cooldown: float
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
) -> BiteCalculation:
    """Calculate exact grass multiplier and average bite calorie yield.

    Returns a BiteCalculation dataclass with complete breakdown.
    """
    z_info = ZONES.get(zone, ZONES["HomeMeadow"])
    g_info = GRASS_TYPES.get(grass_type, GRASS_TYPES["Regular"])

    # 1. Base Calories
    zone_base = int(z_info["BaseValue"])
    grass_bonus = int(g_info["BonusCalories"])
    bp_bonus = get_bite_power_bonus(bite_power_level)
    hw_bonus = HEADWEAR_BONUSES.get(headwear, HEADWEAR_BONUSES["None"])["Bonus"]
    sec_expected = get_expected_secondary_bonus(zone)
    effective_base = zone_base + grass_bonus + bp_bonus + hw_bonus + sec_expected

    # Min base (no secondary) and max base (with best secondary)
    sec_kind = z_info.get("SecondaryKind")
    sec_mult = float(z_info.get("SecondaryValue", 1.0))
    if sec_kind == "Mushroom":
        max_sec_val = SECONDARIES_BASE["GoldMushroom"] * sec_mult
    elif sec_kind and sec_kind in SECONDARIES_BASE:
        max_sec_val = SECONDARIES_BASE[sec_kind] * sec_mult
    else:
        max_sec_val = 0.0
    min_base = zone_base + grass_bonus + bp_bonus + hw_bonus
    max_base = zone_base + grass_bonus + bp_bonus + hw_bonus + max_sec_val

    # 2. Multipliers
    rebirth_mult = get_rebirth_multiplier(rebirth)
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

    # Pillar: Grazer adds +10% PillarBonus in GrassEconomy (var9 + var9 * PillarBonus)
    pillar_bonus = PILLARS.get(pillar, PILLARS["None"])["Bonus"]
    pillar_mult = 1.0 + pillar_bonus

    gp_mult = 2.0 if gamepass_2x else 1.0
    external_mult = gp_mult * other_multiplier

    total_mult = (
        rebirth_mult
        * node_mult
        * rumen_mult
        * comp_mult
        * title_mult
        * bunnies_mult
        * pillar_mult
        * external_mult
    )

    # 3. Expected Yield (per bite)
    # GrassEconomy: floor(var10 + var10 * HerdBonus + 1e-7)
    avg_yield = effective_base * total_mult

    # Min bite (no secondary, ordinary non-golden node)
    min_mult = (
        rebirth_mult
        * 1.0
        * rumen_mult
        * comp_mult
        * title_mult
        * bunnies_mult
        * pillar_mult
        * external_mult
    )
    min_yield = int(math.floor(min_base * min_mult))

    # Max bite (max secondary, golden node 2.0x)
    max_node_mult = 2.0
    max_mult = (
        rebirth_mult
        * max_node_mult
        * max_rumen_mult
        * comp_mult
        * title_mult
        * bunnies_mult
        * pillar_mult
        * external_mult
    )
    max_yield = int(math.floor(max_base * max_mult))

    # 4. Pacing & Progression
    cooldown = get_chew_cooldown(chew_speed_level)
    cal_per_sec = avg_yield / cooldown if cooldown > 0 else 0.0
    next_req = get_rebirth_requirement(rebirth)
    bites_to_rebirth = next_req / avg_yield if avg_yield > 0 else float("inf")
    sec_to_rebirth = bites_to_rebirth * cooldown

    return BiteCalculation(
        rebirth=rebirth,
        rebirth_multiplier=rebirth_mult,
        zone=zone,
        zone_base=zone_base,
        grass_type=grass_type,
        grass_bonus=grass_bonus,
        bite_power_level=bite_power_level,
        bite_power_bonus=bp_bonus,
        headwear=headwear,
        headwear_bonus=hw_bonus,
        expected_secondary_bonus=sec_expected,
        effective_base_calories=effective_base,
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
        min_bite_calories=max(1, min_yield),
        max_bite_calories=max(1, max_yield),
        chew_speed_level=chew_speed_level,
        chew_cooldown=cooldown,
        calories_per_second=cal_per_sec,
        next_rebirth_requirement=next_req,
        expected_bites_to_rebirth=bites_to_rebirth,
        expected_seconds_to_rebirth=sec_to_rebirth,
    )


# --- Formatting & Output ---

def format_rebirth_summary(calc: BiteCalculation) -> str:
    """Format single calculation summary."""
    lines = [
        "================================================================================",
        f"🐄 COW GAME REBIRTH & BITE CALORIE CALCULATOR (Rebirth {calc.rebirth})",
        "================================================================================",
        f"• Grass Multiplier (Rebirth {calc.rebirth}):   {calc.rebirth_multiplier:,.4f}×  (+{(calc.rebirth_multiplier - 1.0) * 100:,.1f}% vs Rebirth 0)",
        f"• Next Rebirth Requirement (R{calc.rebirth}→R{calc.rebirth + 1}): {calc.next_rebirth_requirement:,} Calories",
        f"• Cumulative Prior Rebirth Cost:      {get_cumulative_rebirth_calories(calc.rebirth):,} Calories",
        "--------------------------------------------------------------------------------",
        "BITE CALORIE COMPONENTS:",
        f"  Zone ({calc.zone}):                 {calc.zone_base} base (Category: {ZONES[calc.zone]['Category']})",
        f"  Grass Type ({calc.grass_type}):           +{calc.grass_bonus} base",
        f"  Bite Power Upgrade (Lvl {calc.bite_power_level:02d}/25):   +{calc.bite_power_bonus} base [formula: L*(L+3)/2]",
        f"  Headwear Hat ({calc.headwear}):           +{calc.headwear_bonus} base (MiningHatConfig)",
        f"  Expected Secondary Growth:         +{calc.expected_secondary_bonus:.2f} base (Spawn rate: {ZONES[calc.zone]['SecondaryRate']*100:.0f}%)",
        f"  = Total Effective Base:            {calc.effective_base_calories:.2f} Calories",
        "--------------------------------------------------------------------------------",
        "MULTIPLIERS APPLIED:",
        f"  Rebirth Multiplier:                {calc.rebirth_multiplier:.4f}×  (1.22^{calc.rebirth})",
        f"  Node Quality (Golden avg):         {calc.expected_node_multiplier:.4f}×  (Golden chance: {calc.golden_chance*100:.2f}%)",
        f"  Rumen Combo (Lvl {calc.rumen_level:02d}, {calc.combo_stacks} stacks):    {calc.rumen_multiplier:.2f}×  (+2% per stack, cap: {get_rumen_stats(calc.rumen_level)[0]})",
        f"  Companion Multiplier (Bond {calc.companion_bond:.2f}):  {calc.companion_multiplier:.4f}×  (max: 1.15×)",
        f"  Title Buff ({calc.title}):             {calc.title_multiplier:.2f}×  (Title_CloverMarbles +3% Cal)",
        f"  Back Friends ({calc.back_bunnies} Bunnies):        {calc.back_bunnies_multiplier:.2f}×  (+1% per bunny on back)",
        f"  Pillar Bonus ({calc.pillar}):             {calc.pillar_multiplier:.2f}×  (Grazer +10% grass Cal)",
        f"  2x Gamepass:                       {2.0 if calc.gamepass_2x else 1.0:.1f}×",
        f"  = Combined Total Multiplier:       {calc.total_multiplier:.4f}×",
        "--------------------------------------------------------------------------------",
        "CALORIE YIELD & PROGRESSION PACING:",
        f"  ★ AVERAGE BITE YIELD:              {calc.avg_bite_calories:,.1f} Calories / bite",
        f"  • Single Bite Range:               {calc.min_bite_calories:,} (plain min) – {calc.max_bite_calories:,} (golden max)",
        f"  • Chew Cooldown (Speed Lvl {calc.chew_speed_level:02d}):   {calc.chew_cooldown:.2f}s per bite",
        f"  • Calorie Gain Rate:               {calc.calories_per_second:,.1f} Calories / sec  ({calc.calories_per_second * 3600:,.0f} Cal/hr)",
        f"  • Expected Bites to Next Rebirth:  {calc.expected_bites_to_rebirth:,.0f} bites",
        f"  • Expected Time to Next Rebirth:   {calc.expected_seconds_to_rebirth / 60:.1f} minutes  ({calc.expected_seconds_to_rebirth:.0f} seconds)",
        "================================================================================",
    ]
    return "\n".join(lines)


def format_progression_table(
    max_rebirth: int = 15,
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
) -> str:
    """Print an ASCII table showing progression from Rebirth 0 up to max_rebirth."""
    header = (
        f"| {'Rebirth':^7} | {'Multiplier':^10} | {'Requirement':^13} | "
        f"{'Avg Bite Cal':^14} | {'Cal / Sec':^11} | {'Bites to Rebirth':^16} | {'Time to Rebirth':^15} |"
    )
    divider = "+" + "+".join("-" * (len(col) + 2) for col in [
        "  Rebirth", " Multiplier ", "  Requirement ", "  Avg Bite Cal ",
        "  Cal / Sec ", " Bites to Rebirth ", " Time to Rebirth "
    ]) + "+"

    rows = [
        f"REBIRTH PROGRESSION TABLE ({zone}, Grass: {grass_type}, Hat: {headwear}, Title: {title})",
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
        )
        mins = calc.expected_seconds_to_rebirth / 60.0
        time_str = f"{mins:,.1f} min" if mins < 120 else f"{mins / 60:,.1f} hrs"
        row = (
            f"| {r:^7d} | {calc.rebirth_multiplier:^10.4f} | {calc.next_rebirth_requirement:^13,d} | "
            f"{calc.avg_bite_calories:^14,.1f} | {calc.calories_per_second:^11,.1f} | "
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
) -> str:
    """Compare average bite yield across all zones at a given rebirth."""
    header = (
        f"| {'Zone':^18} | {'Category':^9} | {'Base+Sec':^9} | "
        f"{'Avg Bite Cal':^14} | {'Cal / Sec':^11} | {'Bites to Next':^14} | {'Unlock':^8} |"
    )
    divider = "+" + "+".join("-" * (len(col) + 2) for col in [
        "       Zone       ", " Category", " Base+Sec", "  Avg Bite Cal ",
        "  Cal / Sec ", " Bites to Next", "  Unlock"
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
        )
        unlock_str = "Unlocked" if rebirth >= z_info["MinRebirth"] else f"Req R{z_info['MinRebirth']}"
        base_sec = f"{calc.effective_base_calories:.1f}"
        row = (
            f"| {z_name:<18} | {z_info['Category']:^9} | {base_sec:^9} | "
            f"{calc.avg_bite_calories:^14,.1f} | {calc.calories_per_second:^11,.1f} | "
            f"{calc.expected_bites_to_rebirth:^14,.0f} | {unlock_str:^8} |"
        )
        rows.append(row)

    rows.append(divider)
    return "\n".join(rows)


# --- CLI Parser ---

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Cow Game Rebirth Grass Multiplier & Average Bite Calorie Yield Calculator",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-n", "--rebirth",
        type=int,
        default=0,
        help="Rebirth count n (>= 0)",
    )
    parser.add_argument(
        "-z", "--zone",
        type=str,
        default="HomeMeadow",
        choices=list(ZONES.keys()),
        help="Zone where cow is grazing",
    )
    parser.add_argument(
        "-g", "--grass",
        type=str,
        default="Regular",
        choices=list(GRASS_TYPES.keys()),
        help="Grass type/seeds (Regular, Redgrass, Bluegrass)",
    )
    parser.add_argument(
        "-b", "--bite-power",
        type=int,
        default=25,
        help="Bite Power upgrade level (0 to 25)",
    )
    parser.add_argument(
        "-r", "--rumen",
        type=int,
        default=10,
        help="Rumen upgrade level (0 to 10)",
    )
    parser.add_argument(
        "--combo",
        type=str,
        default="max",
        help="Rumen combo stacks: 'max', 'zero', 'half', or integer stack count",
    )
    parser.add_argument(
        "-c", "--companion",
        type=float,
        default=1.0,
        help="Companion bond (0.0 = none, 0.25 = untamed fresh pet, 1.0 = max bond)",
    )
    parser.add_argument(
        "-s", "--chew-speed",
        type=int,
        default=15,
        help="Chew Speed upgrade level (0 to 15)",
    )
    parser.add_argument(
        "--hat",
        type=str,
        default="None",
        choices=list(HEADWEAR_BONUSES.keys()),
        help="Headwear / Mining Hat cosmetic (+5 to +25 Base Calories)",
    )
    parser.add_argument(
        "--title",
        type=str,
        default="None",
        choices=list(TITLES.keys()),
        help="Equipped Title perk (e.g. CloverMarbles for +3%% grazing calories)",
    )
    parser.add_argument(
        "--bunnies",
        type=int,
        default=0,
        choices=[0, 1, 2, 3, 4, 5],
        help="Number of Back Bunnies equipped (0-5, +1%% Cal each)",
    )
    parser.add_argument(
        "--pillar",
        type=str,
        default="None",
        choices=list(PILLARS.keys()),
        help="Active Pillar buff (Grazer for +10%% grass calories)",
    )
    parser.add_argument(
        "--gamepass",
        action="store_true",
        help="Enable 2x Calories Gamepass",
    )
    parser.add_argument(
        "--clover-aura",
        type=int,
        default=0,
        help="Lucky Clover aura level (0 to 5)",
    )
    parser.add_argument(
        "--table",
        action="store_true",
        help="Display progression table across rebirths 0 to N",
    )
    parser.add_argument(
        "--max-rebirth",
        type=int,
        default=15,
        help="Maximum rebirth for the progression table",
    )
    parser.add_argument(
        "--compare-zones",
        action="store_true",
        help="Display side-by-side comparison across all zones",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output raw JSON instead of formatted text",
    )
    parser.add_argument(
        "--gui",
        action="store_true",
        help="Launch the interactive desktop GUI application",
    )
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
    )

    if args.json:
        data = asdict(calc)
        print(json.dumps(data, indent=2))
        return

    print(format_rebirth_summary(calc))

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
        ))


if __name__ == "__main__":
    main()
