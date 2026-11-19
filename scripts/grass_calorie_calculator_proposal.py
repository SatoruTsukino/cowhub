#!/usr/bin/env python3
"""Grass Multiplier and Average Bite Calorie Yield Calculator — Rebirth Proposal Edition.

Implements the proposed Model 2 (R20 Log-Time Pivot) from the Rebirth Scaling Proposal,
matching `scripts/RebirthEconomy.luau` and `docs/rebirth_scaling_proposal.html`, alongside
the current legacy exponential (2.0^r) curve and Model 1 (Asymptotic Softcap), plus all
Alpha V3.0.0 stat bonuses (Heart o' Davy Jones, Bionic Stomach, Spirit Lanterns, All Auras
Mastered, Trailblazer Excursion Multiplier) and North River Field Raids (Fields 1-10).
"""

from __future__ import annotations

import argparse
import json
import math
import os
import sys
from dataclasses import asdict, dataclass
from typing import Any, Dict, List, Optional, Tuple

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from grass_calorie_calculator import (
    BIONIC_STOMACH_MULTIPLIER,
    BITE_POWER_MAX_LEVEL,
    CHEW_BASE_COOLDOWN,
    CHEW_MIN_COOLDOWN,
    CHEW_SPEED_MAX_LEVEL,
    DAVY_JONES_HEART_MULTIPLIER,
    EXPECTED_MUSHROOM_VALUE,
    FIELD_RAID_FIELDS,
    GRASS_TYPES as _CORE_GRASS_TYPES,
    HEADWEAR_BONUSES as _CORE_HEADWEAR_BONUSES,
    PILLARS as _CORE_PILLARS,
    RAID_POWERUP_MAX_LEVEL,
    REBIRTH_BASE_REQUIREMENT,
    REBIRTH_GROWTH_RATE,
    REBIRTH_MULTIPLIER_STEP,
    REBIRTH_REQUIREMENT_ROUNDING,
    RIPE_BONUS_FACTORS,
    RIPE_OPPORTUNITIES_CYCLE4,
    RUMEN_MAX_LEVEL,
    SECONDARIES_BASE,
    TITLES as _CORE_TITLES,
    TRAILBLAZER_MAX_LEVEL,
    WEEKEND_CALORIE_MULTIPLIER,
    WEEKEND_REQ_DISCOUNT,
    ZONES,
    format_field_raid_comparison,
    get_bite_power_bonus,
    get_chew_cooldown,
    get_companion_multiplier,
    get_excursion_multiplier,
    get_expected_node_multiplier,
    get_expected_secondary_bonus,
    get_field_raid_ripe_bonus,
    get_field_raid_ripe_opportunities,
    get_intake_multiplier,
    get_mushroom_island_stats,
    get_rumen_stats,
    get_strong_chompers_multiplier,
)

# Proposal Model 2 Constants (Log-Time Pivot, matching RebirthEconomy.luau)
PROPOSAL_PIVOT = 20
PROPOSAL_T0_HOURS = 29.4
PROPOSAL_A_HOURS = 12.0
PROPOSAL_LOG_GAIN = PROPOSAL_A_HOURS / PROPOSAL_T0_HOURS  # ~0.408163265
PROPOSAL_INCOME_GROWTH = 1.0 + REBIRTH_MULTIPLIER_STEP    # 1.22
PROPOSAL_SIGNIFICANT_DIGITS = 3
PROPOSAL_PIVOT_REQUIREMENT = REBIRTH_BASE_REQUIREMENT * (2 ** PROPOSAL_PIVOT)  # 10,485,760,000

# Proposal Model 1 Constants (Asymptotic Softcap)
MODEL1_TMAX_HOURS = 200.0
MODEL1_K = 3.0

# Keeps INCOME_GROWTH^dr finite and inputs bounded, matching RebirthEconomy.luau
MAX_REBIRTH = 1000
SPIRIT_LANTERNS_MAX = 3
STRONG_CHOMPERS_MAX_LEVEL = RAID_POWERUP_MAX_LEVEL
MUSHROOM_ISLAND_MAX_LEVEL = RAID_POWERUP_MAX_LEVEL
TRAILBLAZER_BRANCHES = ("None", "Adventurous", "Swift")
get_ripe_bonus = get_field_raid_ripe_bonus

# Expose dictionaries compatible with proposal callers
GRASS_TYPES: Dict[str, Dict[str, Any]] = {
    k: {"Bonus": v["BonusCalories"], "BonusCalories": v["BonusCalories"], "DisplayName": v["DisplayName"]}
    for k, v in _CORE_GRASS_TYPES.items()
}

HEADWEAR_BONUSES: Dict[str, int] = {k: v["Bonus"] for k, v in _CORE_HEADWEAR_BONUSES.items()}

TITLES: Dict[str, Dict[str, Any]] = {
    k: {"Multiplier": v["Multiplier"], "Description": v["DisplayName"], "DisplayName": v["DisplayName"]}
    for k, v in _CORE_TITLES.items()
}

PILLARS: Dict[str, Dict[str, Any]] = {
    k: {"Multiplier": 1.0 + v["Bonus"], "Bonus": v["Bonus"], "Description": v["DisplayName"], "DisplayName": v["DisplayName"]}
    for k, v in _CORE_PILLARS.items()
}


# --- Calculation Helpers ---

def sanitize_rebirth_count(rebirth: Any) -> int:
    """Sanitize rebirth count matching RebirthEconomy.luau:
    NaN/negative -> 0, fractional -> floor, bounded to [0, MAX_REBIRTH].
    """
    try:
        val = float(rebirth)
    except (ValueError, TypeError):
        return 0
    if math.isnan(val) or val < 0:
        return 0
    if math.isinf(val) or val > MAX_REBIRTH:
        return MAX_REBIRTH
    return int(math.floor(val))


def get_rebirth_multiplier(rebirth: Any, all_auras_completed: bool = False) -> float:
    """Calculate the grass/calorie multiplier for rebirth n: (1 + 0.22)^n * (2 if all_auras_completed else 1)."""
    n = sanitize_rebirth_count(rebirth)
    return ((1.0 + REBIRTH_MULTIPLIER_STEP) ** n) * (2.0 if all_auras_completed else 1.0)


def round_significant(x: float, digits: int = 3) -> int:
    """Round positive number to `digits` significant figures, matching Luau math.round (half-up)."""
    if x <= 0 or math.isnan(x) or math.isinf(x):
        return 0
    magnitude = 10 ** (math.floor(math.log10(x)) - digits + 1)
    scaled = x / magnitude
    rounded = math.floor(scaled + 0.5)
    return int(rounded * magnitude)


def _apply_req_modifiers(base_req: int, spirit_lanterns: int = 0, weekend_discount: bool = False) -> int:
    req = base_req
    if weekend_discount:
        req = int(math.floor(req * WEEKEND_REQ_DISCOUNT + 0.5))
    lanterns = max(0, int(spirit_lanterns))
    return max(1, int(math.ceil(req / (2 ** lanterns))))


def get_rebirth_requirement_legacy(
    rebirth: Any,
    spirit_lanterns: int = 0,
    weekend_discount: bool = False,
) -> int:
    """Legacy requirement: 10,000 * 2^n (exponential doubling) with optional Spirit Lanterns & Weekend discount."""
    n = sanitize_rebirth_count(rebirth)
    req = int(round(REBIRTH_BASE_REQUIREMENT * (REBIRTH_GROWTH_RATE ** n) / REBIRTH_REQUIREMENT_ROUNDING) * REBIRTH_REQUIREMENT_ROUNDING)
    return _apply_req_modifiers(req, spirit_lanterns=spirit_lanterns, weekend_discount=weekend_discount)


def get_rebirth_requirement_model2(
    rebirth: Any,
    spirit_lanterns: int = 0,
    weekend_discount: bool = False,
) -> int:
    """Proposal Model 2 (R20 Pivot to Log-Time), exact match to RebirthEconomy.luau."""
    n = sanitize_rebirth_count(rebirth)
    if n <= PROPOSAL_PIVOT:
        base_req = REBIRTH_BASE_REQUIREMENT * (2 ** n)
    else:
        delta_r = n - PROPOSAL_PIVOT
        time_scale = 1.0 + PROPOSAL_LOG_GAIN * math.log(1.0 + delta_r)
        raw_req = PROPOSAL_PIVOT_REQUIREMENT * (PROPOSAL_INCOME_GROWTH ** delta_r) * time_scale
        base_req = round_significant(raw_req, PROPOSAL_SIGNIFICANT_DIGITS)
    return _apply_req_modifiers(base_req, spirit_lanterns=spirit_lanterns, weekend_discount=weekend_discount)


def get_rebirth_requirement_model1(
    rebirth: Any,
    spirit_lanterns: int = 0,
    weekend_discount: bool = False,
) -> int:
    """Proposal Model 1 (R20 Pivot to Asymptotic Softcap, Tmax = 200h)."""
    n = sanitize_rebirth_count(rebirth)
    if n <= PROPOSAL_PIVOT:
        base_req = REBIRTH_BASE_REQUIREMENT * (2 ** n)
    else:
        delta_r = n - PROPOSAL_PIVOT
        t_target = PROPOSAL_T0_HOURS + (MODEL1_TMAX_HOURS - PROPOSAL_T0_HOURS) * (delta_r / (delta_r + MODEL1_K))
        time_scale = t_target / PROPOSAL_T0_HOURS
        raw_req = PROPOSAL_PIVOT_REQUIREMENT * (PROPOSAL_INCOME_GROWTH ** delta_r) * time_scale
        base_req = round_significant(raw_req, PROPOSAL_SIGNIFICANT_DIGITS)
    return _apply_req_modifiers(base_req, spirit_lanterns=spirit_lanterns, weekend_discount=weekend_discount)


def get_rebirth_requirement(
    rebirth: Any,
    model: str = "model2",
    spirit_lanterns: int = 0,
    weekend_discount: bool = False,
    weekend_event: Optional[bool] = None,
) -> int:
    """Calculate the calories required to perform rebirth n -> n + 1 for specified model."""
    wk = weekend_discount if weekend_event is None else bool(weekend_event)
    m = model.lower()
    if m in ("legacy", "current", "exponential"):
        return get_rebirth_requirement_legacy(rebirth, spirit_lanterns=spirit_lanterns, weekend_discount=wk)
    elif m in ("model1", "asymptote", "softcap"):
        return get_rebirth_requirement_model1(rebirth, spirit_lanterns=spirit_lanterns, weekend_discount=wk)
    else:
        return get_rebirth_requirement_model2(rebirth, spirit_lanterns=spirit_lanterns, weekend_discount=wk)


def get_cumulative_rebirth_calories(
    target_rebirth: Any,
    model: str = "model2",
    weekend_discount: bool = False,
) -> int:
    """Total cumulative calories required to go from Rebirth 0 to target_rebirth."""
    n = sanitize_rebirth_count(target_rebirth)
    return sum(get_rebirth_requirement(i, model=model, weekend_discount=weekend_discount) for i in range(n))


def get_rumen_multiplier(level: int, combo_stacks: int) -> float:
    """Rumen multiplier given combo stacks: 1 + 0.02 * min(combo_stacks, cap)."""
    cap, _ = get_rumen_stats(level)
    effective_combo = max(0, min(int(combo_stacks), cap))
    return 1.0 + 0.02 * effective_combo


def get_back_bunnies_multiplier(bunnies_count: int) -> float:
    """Back bunnies grazing multiplier: 1 + 0.01 * count (0 to 5 bunnies)."""
    count = max(0, min(int(bunnies_count), 5))
    return 1.0 + 0.01 * count


# --- Data Structure ---

@dataclass
class ComparisonBiteCalculation:
    """Calorie yields and time progression for both Legacy and Proposal systems (including V3.0.0 & Field Raids)."""
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

    # System comparison metrics
    legacy_requirement: int
    proposal_requirement: int
    model1_requirement: int

    legacy_seconds: float
    proposal_seconds: float
    model1_seconds: float

    time_saved_seconds: float
    time_saved_percent: float
    daily_pace_5h_legacy: float
    daily_pace_5h_proposal: float

    selected_model: str
    active_requirement: int
    active_seconds: float

    @property
    def field_raid_level(self) -> Optional[int]:
        return self.raid_level if self.is_field_raid else None

    @property
    def ripe_bonus_calories(self) -> int:
        return self.ripe_bonus_base

    @property
    def raid_ripe_active(self) -> bool:
        return self.ripe_wheat_active

    @property
    def ripe_avg_bite_calories(self) -> float:
        return self.ripe_bite_calories

    @property
    def ripe_calories_per_second(self) -> float:
        bite_sec = (self.ripe_bite_calories / self.chew_cooldown) if self.chew_cooldown > 0 else 0.0
        return bite_sec + self.mushroom_patch_cal_per_sec

    @property
    def ripe_opportunities_per_cycle(self) -> float:
        return float(get_field_raid_ripe_opportunities(self.rebirth)) if self.is_field_raid else 0.0

    @property
    def mushroom_island_rate(self) -> float:
        return float(self.mushroom_patch_cal_per_sec)

    @property
    def mushroom_island_capacity(self) -> int:
        return self.mushroom_patch_capacity

    @property
    def davy_jones_multiplier(self) -> float:
        return DAVY_JONES_HEART_MULTIPLIER if self.davy_jones_heart else 1.0

    @property
    def bionic_stomach_multiplier(self) -> float:
        return BIONIC_STOMACH_MULTIPLIER if self.bionic_stomach else 1.0


def calculate_comparison_bite_yield(
    rebirth: int = 0,
    zone: str = "HomeMeadow",
    grass_type: str = "Regular",
    bite_power_level: int = 25,
    rumen_level: int = 10,
    combo: str | int = "max",
    companion_bond: float = 1.0,
    chew_speed_level: int = 15,
    headwear: str = "None",
    title: str = "None",
    back_bunnies: int = 0,
    pillar: str = "None",
    gamepass_2x: bool = False,
    lucky_clover_level: int = 0,
    other_multiplier: float = 1.0,
    model: str = "model2",
    # --- Alpha V3.0.0 Stat Bonuses & Field Raids ---
    all_auras_completed: bool = False,
    spirit_lanterns: int = 0,
    davy_jones_heart: bool = False,
    bionic_stomach: bool = False,
    trailblazer_level: int = 0,
    trailblazer_branch: str = "None",
    on_excursion: Optional[bool] = None,
    weekend_event: bool = False,
    strong_chompers_level: int = 0,
    mushroom_island_level: int = -1,
    ripe_wheat_active: bool = False,
    raid_ripe_active: Optional[bool] = None,
) -> ComparisonBiteCalculation:
    """Perform full calorie calculation with side-by-side legacy vs proposal metrics."""
    if raid_ripe_active is not None:
        ripe_wheat_active = bool(raid_ripe_active)
    if zone not in ZONES:
        raise ValueError(f"Unknown zone: '{zone}'. Valid: {list(ZONES.keys())}")
    if grass_type not in GRASS_TYPES:
        raise ValueError(f"Unknown grass type: '{grass_type}'. Valid: {list(GRASS_TYPES.keys())}")
    if headwear not in HEADWEAR_BONUSES:
        raise ValueError(f"Unknown headwear: '{headwear}'. Valid: {list(HEADWEAR_BONUSES.keys())}")
    if title not in TITLES:
        raise ValueError(f"Unknown title: '{title}'. Valid: {list(TITLES.keys())}")
    if pillar not in PILLARS:
        raise ValueError(f"Unknown pillar: '{pillar}'. Valid: {list(PILLARS.keys())}")

    z_info = ZONES[zone]
    g_info = GRASS_TYPES[grass_type]
    t_info = TITLES[title]
    p_info = PILLARS[pillar]
    is_raid = bool(z_info.get("IsFieldRaid", False))
    raid_lvl = int(z_info.get("RaidLevel", 0))

    zone_base = int(z_info["BaseValue"])
    grass_bonus = 0 if is_raid else int(g_info["Bonus"])
    bp_bonus = get_bite_power_bonus(bite_power_level)
    hw_bonus = HEADWEAR_BONUSES[headwear]
    sec_expected = get_expected_secondary_bonus(zone)

    ripe_bonus_base = get_field_raid_ripe_bonus(raid_lvl, rebirth) if is_raid else 0
    active_ripe_add = ripe_bonus_base if (is_raid and ripe_wheat_active) else 0

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
    max_base = min_base + max_sec_val
    effective_base = min_base + active_ripe_add + sec_expected

    rebirth_mult = get_rebirth_multiplier(rebirth, all_auras_completed=all_auras_completed)
    node_mult = get_expected_node_multiplier(zone, lucky_clover_level)

    cap, max_rumen_mult = get_rumen_stats(rumen_level)
    if isinstance(combo, str):
        c_lower = combo.lower()
        if c_lower == "max":
            combo_stacks = cap
        elif c_lower == "zero":
            combo_stacks = 0
        elif c_lower == "half":
            combo_stacks = cap // 2
        else:
            try:
                combo_stacks = int(combo)
            except ValueError:
                combo_stacks = cap
    else:
        combo_stacks = int(combo)
    combo_stacks = max(0, min(combo_stacks, cap))
    rumen_mult = get_rumen_multiplier(rumen_level, combo_stacks)

    comp_mult = get_companion_multiplier(companion_bond)
    title_mult = t_info["Multiplier"]
    bunnies_count = max(0, min(int(back_bunnies), 5))
    bunnies_mult = get_back_bunnies_multiplier(bunnies_count)
    pillar_mult = 1.0 if is_raid else p_info["Multiplier"]

    chompers_lvl = max(0, min(RAID_POWERUP_MAX_LEVEL, int(strong_chompers_level)))
    davy_m, stomach_m, chompers_m = get_intake_multiplier(
        davy_jones_heart=davy_jones_heart,
        bionic_stomach=bionic_stomach,
        strong_chompers_level=chompers_lvl,
        is_field_raid=is_raid,
    )
    intake_mult = davy_m * stomach_m * chompers_m

    effective_on_excursion = is_raid if on_excursion is None else bool(on_excursion or is_raid)
    tb_lvl = max(0, min(TRAILBLAZER_MAX_LEVEL, int(trailblazer_level)))
    excursion_mult = get_excursion_multiplier(
        trailblazer_level=tb_lvl,
        trailblazer_branch=trailblazer_branch,
        on_excursion=effective_on_excursion,
    )

    weekend_mult = WEEKEND_CALORIE_MULTIPLIER if weekend_event else 1.0
    gp_mult = 2.0 if gamepass_2x else 1.0
    external_mult = gp_mult * max(0.01, float(other_multiplier))

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
    avg_yield = effective_base * total_mult
    ripe_single_base = zone_base + ripe_bonus_base + bp_bonus + hw_bonus
    ripe_bite_yield = ripe_single_base * total_mult if is_raid else avg_yield

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

    cooldown = get_chew_cooldown(chew_speed_level, is_field_raid=is_raid)
    bite_cal_per_sec = avg_yield / cooldown if cooldown > 0 else 0.0

    mi_lvl = int(mushroom_island_level) if (is_raid and mushroom_island_level is not None and mushroom_island_level >= 0) else -1
    patch_rate, patch_cap = get_mushroom_island_stats(mi_lvl if is_raid else -1)
    cal_per_sec = bite_cal_per_sec + patch_rate

    # Calculate across all 3 models
    req_legacy = get_rebirth_requirement_legacy(rebirth, spirit_lanterns=spirit_lanterns, weekend_discount=weekend_event)
    req_model2 = get_rebirth_requirement_model2(rebirth, spirit_lanterns=spirit_lanterns, weekend_discount=weekend_event)
    req_model1 = get_rebirth_requirement_model1(rebirth, spirit_lanterns=spirit_lanterns, weekend_discount=weekend_event)

    sec_legacy = (req_legacy / cal_per_sec) if cal_per_sec > 0 else float("inf")
    sec_model2 = (req_model2 / cal_per_sec) if cal_per_sec > 0 else float("inf")
    sec_model1 = (req_model1 / cal_per_sec) if cal_per_sec > 0 else float("inf")

    time_saved = max(0.0, sec_legacy - sec_model2)
    saved_pct = (time_saved / sec_legacy * 100.0) if sec_legacy > 0 else 0.0

    pace_legacy = ((5.0 * 3600.0) / sec_legacy * 100.0) if sec_legacy > 0 else 0.0
    pace_model2 = ((5.0 * 3600.0) / sec_model2 * 100.0) if sec_model2 > 0 else 0.0

    # Active model selection
    active_m = model.lower()
    if active_m in ("legacy", "current", "exponential"):
        active_req = req_legacy
        active_sec = sec_legacy
    elif active_m in ("model1", "asymptote", "softcap"):
        active_req = req_model1
        active_sec = sec_model1
    else:
        active_req = req_model2
        active_sec = sec_model2

    return ComparisonBiteCalculation(
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
        legacy_requirement=req_legacy,
        proposal_requirement=req_model2,
        model1_requirement=req_model1,
        legacy_seconds=sec_legacy,
        proposal_seconds=sec_model2,
        model1_seconds=sec_model1,
        time_saved_seconds=time_saved,
        time_saved_percent=saved_pct,
        daily_pace_5h_legacy=pace_legacy,
        daily_pace_5h_proposal=pace_model2,
        selected_model=model,
        active_requirement=active_req,
        active_seconds=active_sec,
    )


# --- Formatting Helpers ---

def format_number_abbr(n: float) -> str:
    """Format large numbers with B/M/K suffix for compact tables."""
    abs_n = abs(n)
    if abs_n >= 1e12:
        return f"{n / 1e12:,.2f} T"
    if abs_n >= 1e9:
        return f"{n / 1e9:,.2f} B"
    if abs_n >= 1e6:
        return f"{n / 1e6:,.2f} M"
    if abs_n >= 1e3:
        return f"{n / 1e3:,.1f} K"
    return f"{n:,.0f}"


def format_hours_abbr(seconds: float) -> str:
    """Format seconds into concise hours/minutes."""
    if seconds == float("inf"):
        return "inf"
    hours = seconds / 3600.0
    if hours >= 1000:
        return f"{hours:,.0f}h"
    elif hours >= 1.0:
        return f"{hours:,.1f}h"
    else:
        return f"{seconds / 60.0:,.1f}m"


def format_side_by_side_comparison(
    max_rebirth: int = 25,
    min_rebirth: int = 15,
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
    """Format side-by-side progression table comparing Legacy (2.0^r) vs Proposal (Model 2)."""
    header = (
        f"| {'Tier':^9} | {'Inc Mult':^10} | {'Legacy Req (2.0^r)':^19} | {'Legacy Time':^13} | "
        f"{'Model 2 Req (Log)':^19} | {'Model 2 Time':^13} | {'Time Saved':^11} | {'Daily Pace (5h)':^15} |"
    )
    divider = "+" + "+".join([
        "-" * 11, "-" * 12, "-" * 21, "-" * 15, "-" * 21, "-" * 15, "-" * 13, "-" * 17
    ]) + "+"

    lines = [
        "",
        "==================================================================================================================",
        f"  📊 REBIRTH SCALING PROPOSAL: SYSTEM COMPARISON TABLE ({zone}, DavyHeart: {davy_jones_heart}, Stomach: {bionic_stomach})",
        "  Comparing Legacy Exponential (2.0^r) vs Proposal Model 2 (R20 Log-Time Pivot)",
        "==================================================================================================================",
        divider,
        header,
        divider,
    ]

    for r in range(min_rebirth, max_rebirth + 1):
        calc = calculate_comparison_bite_yield(
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

        tier_tag = f"R{r}→R{r+1}"
        if r == PROPOSAL_PIVOT:
            tier_tag += " ★"
        elif r == 24:
            tier_tag += " 🎯"

        saved_str = f"-{calc.time_saved_percent:,.1f}%" if calc.time_saved_percent > 0 else "0.0%"
        pace_str = f"{calc.daily_pace_5h_proposal:,.1f}% / day"

        row = (
            f"| {tier_tag:^9} | {calc.rebirth_multiplier:^10.2f}× | "
            f"{format_number_abbr(calc.legacy_requirement):^19} | {format_hours_abbr(calc.legacy_seconds):^13} | "
            f"{format_number_abbr(calc.proposal_requirement):^19} | {format_hours_abbr(calc.proposal_seconds):^13} | "
            f"{saved_str:^11} | {pace_str:^15} |"
        )
        lines.append(row)

    lines.append(divider)
    lines.append("  ★ R20: Seamless Anchor Pivot point (curves match at R20 by mathematical construction)")
    lines.append("  🎯 R24→R25: Pre-update gateway")
    lines.append("")
    return "\n".join(lines)


# --- CLI Parser ---

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Cow Game Rebirth Grass Multiplier & Calorie Yield Calculator (Proposal & V3.0.0 Edition)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("-n", "--rebirth", type=int, default=0, help="Rebirth count n (>= 0)")
    parser.add_argument(
        "--model",
        choices=["model2", "legacy", "model1"],
        default="model2",
        help="Rebirth requirement formula model (model2 = Proposal Log-Time, legacy = 2.0^r, model1 = Asymptotic Softcap)",
    )
    parser.add_argument(
        "-z",
        "--zone",
        choices=list(ZONES.keys()),
        default="HomeMeadow",
        help="Zone or Field Raid (HomeMeadow..Cave, FieldRaid1..FieldRaid10)",
    )
    parser.add_argument(
        "-g",
        "--grass",
        choices=list(GRASS_TYPES.keys()),
        default="Regular",
        help="Grass type/seeds",
    )
    parser.add_argument("-b", "--bite-power", type=int, default=25, help="Bite Power upgrade level (0 to 25)")
    parser.add_argument("-r", "--rumen", type=int, default=10, help="Rumen upgrade level (0 to 10)")
    parser.add_argument("--combo", default="max", help="Rumen combo stacks: 'max', 'zero', 'half', or integer")
    parser.add_argument("-c", "--companion", type=float, default=1.0, help="Companion bond (0.0 to 1.0)")
    parser.add_argument("-s", "--chew-speed", type=int, default=15, help="Chew Speed level (0 to 15)")
    parser.add_argument("--hat", choices=list(HEADWEAR_BONUSES.keys()), default="None", help="Headwear bonus")
    parser.add_argument("--title", choices=list(TITLES.keys()), default="None", help="Equipped Title perk")
    parser.add_argument("--bunnies", type=int, choices=[0, 1, 2, 3, 4, 5], default=0, help="Back Bunnies (0-5)")
    parser.add_argument("--pillar", choices=list(PILLARS.keys()), default="None", help="Active Pillar buff")
    parser.add_argument("--gamepass", action="store_true", default=False, help="Enable 2x Calories Gamepass")
    parser.add_argument("--clover-aura", type=int, default=0, help="Lucky Clover aura level (0 to 5)")

    # Alpha V3.0.0 & Field Raid options
    parser.add_argument("--all-auras", action="store_true", help="All 5 aura paths mastered (2x Rebirth Multiplier)")
    parser.add_argument("--spirit-lanterns", type=int, default=0, help="Lit Spirit Lanterns (halves next rebirth cost per lantern)")
    parser.add_argument("--davy-heart", action="store_true", help="Heart o' Davy Jones attuned (permanent 2x calorie intake)")
    parser.add_argument("--bionic-stomach", action="store_true", help="Bionic Stomach enabled (1.33x calorie intake)")
    parser.add_argument("--trailblazer", type=int, default=0, help="Trailblazer aura level (0 to 5)")
    parser.add_argument(
        "--trailblazer-branch",
        type=str,
        default="None",
        choices=["None", "Adventurous", "Unrelenting"],
        help="Trailblazer branch at Lvl 3+",
    )
    parser.add_argument("--weekend", action="store_true", help="Weekend Event active (1.5x calories & -10%% rebirth requirement)")
    parser.add_argument("--strong-chompers", type=int, default=0, help="Field Raid Strong Chompers powerup level (0 to 99)")
    parser.add_argument("--mushroom-island", type=int, default=-1, help="Field Raid Mushroom Island powerup level (-1=off, 0 to 99)")
    parser.add_argument("--ripe-wheat", action="store_true", help="Evaluate Field Raid bite during Ripe Wheat bell window")
    parser.add_argument("--compare-raids", action="store_true", help="Display comparison across all 10 Field Raid levels")

    parser.add_argument("--compare-models", action="store_true", default=False, help="Display side-by-side comparison table")
    parser.add_argument("--min-rebirth", type=int, default=15, help="Minimum rebirth for comparison table")
    parser.add_argument("--max-rebirth", type=int, default=25, help="Maximum rebirth for comparison table")
    parser.add_argument("--table", action="store_true", default=False, help="Display progression table")
    parser.add_argument("--json", action="store_true", default=False, help="Output raw JSON")
    parser.add_argument("--gui", action="store_true", default=False, help="Launch interactive comparison GUI")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.gui:
        import subprocess
        gui_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "grass_calorie_gui_proposal.py")
        subprocess.run([sys.executable, gui_path])
        return

    if args.compare_raids:
        print(format_field_raid_comparison(
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
        if not (args.compare_models or args.table):
            return

    if args.compare_models or args.table:
        output = format_side_by_side_comparison(
            max_rebirth=args.max_rebirth,
            min_rebirth=args.min_rebirth,
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
        )
        print(output)
        return

    calc = calculate_comparison_bite_yield(
        rebirth=args.rebirth,
        zone=args.zone,
        grass_type=args.grass,
        bite_power_level=args.bite_power,
        rumen_level=args.rumen,
        combo=args.combo,
        companion_bond=args.companion,
        chew_speed_level=args.chew_speed,
        headwear=args.hat,
        title=args.title,
        back_bunnies=args.bunnies,
        pillar=args.pillar,
        gamepass_2x=args.gamepass,
        lucky_clover_level=args.clover_aura,
        model=args.model,
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
        print(json.dumps(asdict(calc), indent=2))
        return

    print("================================================================================")
    print(f"🐮 COW GAME REBIRTH & BITE CALORIE CALCULATOR — PROPOSAL EDITION (Rebirth {calc.rebirth})")
    print("================================================================================")
    print(f"• Active Model:                        {calc.selected_model.upper()}")
    print(f"• Zone / Raid:                         {calc.zone} (Base: {calc.zone_base:,}, Chew: {calc.chew_cooldown:.2f}s)")
    print(f"• Grass Multiplier (Rebirth {calc.rebirth}):       {calc.rebirth_multiplier:,.4f}×  (All Auras 2×: {calc.all_auras_completed})")
    print(f"• V3.0 Intake / Excursion Mult:        Intake {calc.intake_multiplier:.4f}× | Excursion {calc.excursion_multiplier:.4f}×")
    print(f"• Average Bite Yield:                  {calc.avg_bite_calories:,.1f} Calories / bite")
    if calc.is_field_raid:
        print(f"• Ripe Wheat Bell Bite Yield:          {calc.ripe_bite_calories:,.1f} Calories / ripe bite (+{calc.ripe_bonus_base:,} base)")
    print(f"• Calorie Income Rate:                 {calc.calories_per_second:,.1f} Cal/sec ({calc.calories_per_second * 3600:,.0f} Cal/hr)")
    print("--------------------------------------------------------------------------------")
    print("PROGRESSION REQUIREMENT COMPARISON:")
    print(f"  Legacy Req (2.0^{calc.rebirth}):             {calc.legacy_requirement:,} Cal  ({format_hours_abbr(calc.legacy_seconds)})")
    print(f"  Proposal Req (Model 2 Log):          {calc.proposal_requirement:,} Cal  ({format_hours_abbr(calc.proposal_seconds)})")
    print(f"  Model 1 Req (Asymptote 200h):        {calc.model1_requirement:,} Cal  ({format_hours_abbr(calc.model1_seconds)})")
    if calc.rebirth > PROPOSAL_PIVOT:
        print(f"  ★ Time Saved under Proposal:         {format_hours_abbr(calc.time_saved_seconds)} (-{calc.time_saved_percent:.1f}%)")
        print(f"  ★ Daily Pace (5h/day):               {calc.daily_pace_5h_proposal:.1f}% / day  (vs {calc.daily_pace_5h_legacy:.1f}% legacy)")
    else:
        print(f"  ★ Pre-Pivot Status:                  Continuous (Both systems match perfectly at R{calc.rebirth} <= 20)")
    print("================================================================================")


if __name__ == "__main__":
    main()
