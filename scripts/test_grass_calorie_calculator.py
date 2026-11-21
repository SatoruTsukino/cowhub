#!/usr/bin/env python3
"""Unit tests for grass_calorie_calculator.py (including Alpha V3.0.0 & Field Raids)."""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from grass_calorie_calculator import (
    BITE_POWER_MAX_LEVEL,
    FIELD_RAID_FIELDS,
    RUMEN_MAX_LEVEL,
    ZONES,
    calculate_bite_yield,
    get_bite_power_bonus,
    get_chew_cooldown,
    get_companion_multiplier,
    get_cumulative_rebirth_calories,
    get_excursion_multiplier,
    get_expected_node_multiplier,
    get_expected_secondary_bonus,
    get_field_raid_ripe_bonus,
    get_field_raid_ripe_opportunities,
    get_intake_multiplier,
    get_mushroom_island_stats,
    get_rebirth_multiplier,
    get_rebirth_requirement,
    get_rumen_stats,
    get_strong_chompers_multiplier,
)


class TestGrassCalorieCalculator(unittest.TestCase):

    def test_rebirth_multiplier(self):
        # Config.luau: (1 + 0.22) ^ n * (2 if AreAllPathsCompleted else 1)
        self.assertAlmostEqual(get_rebirth_multiplier(0), 1.0)
        self.assertAlmostEqual(get_rebirth_multiplier(1), 1.22)
        self.assertAlmostEqual(get_rebirth_multiplier(2), 1.4884)
        self.assertAlmostEqual(get_rebirth_multiplier(3), 1.22 ** 3)
        self.assertAlmostEqual(get_rebirth_multiplier(5), 1.22 ** 5)
        self.assertAlmostEqual(get_rebirth_multiplier(10), 1.22 ** 10)
        # Negative clamped to 0
        self.assertAlmostEqual(get_rebirth_multiplier(-1), 1.0)

        # Alpha V3.0.0: All Aura Paths Mastered doubles rebirth multiplier
        self.assertAlmostEqual(get_rebirth_multiplier(0, all_auras_completed=True), 2.0)
        self.assertAlmostEqual(get_rebirth_multiplier(10, all_auras_completed=True), 2.0 * (1.22 ** 10))
        self.assertAlmostEqual(get_rebirth_multiplier(20, all_auras_completed=True), 2.0 * (1.22 ** 20))

    def test_rebirth_requirement_and_spirit_lanterns(self):
        # Config.luau: round(10000 * 2^n / 100) * 100
        self.assertEqual(get_rebirth_requirement(0), 10000)
        self.assertEqual(get_rebirth_requirement(1), 20000)
        self.assertEqual(get_rebirth_requirement(2), 40000)
        self.assertEqual(get_rebirth_requirement(3), 80000)
        self.assertEqual(get_rebirth_requirement(4), 160000)
        self.assertEqual(get_rebirth_requirement(5), 320000)

        # Alpha V3.0.0: Spirit Lanterns halve cost per lit lantern: ceil(req / 2^L)
        self.assertEqual(get_rebirth_requirement(0, spirit_lanterns=1), 5000)
        self.assertEqual(get_rebirth_requirement(0, spirit_lanterns=2), 2500)
        self.assertEqual(get_rebirth_requirement(5, spirit_lanterns=3), 40000)

        # Weekend Event 10% discount
        self.assertEqual(get_rebirth_requirement(0, weekend_discount=True), 9000)
        self.assertEqual(get_rebirth_requirement(0, spirit_lanterns=1, weekend_discount=True), 4500)

        # Cumulative
        self.assertEqual(get_cumulative_rebirth_calories(0), 0)
        self.assertEqual(get_cumulative_rebirth_calories(1), 10000)
        self.assertEqual(get_cumulative_rebirth_calories(2), 30000)
        self.assertEqual(get_cumulative_rebirth_calories(5), 310000)

    def test_bite_power_bonus(self):
        # UpgradeConfig.luau: level * (level + 3) / 2
        self.assertEqual(get_bite_power_bonus(0), 0)
        self.assertEqual(get_bite_power_bonus(1), 2)
        self.assertEqual(get_bite_power_bonus(2), 5)
        self.assertEqual(get_bite_power_bonus(10), (10 * 13) // 2)  # 65
        self.assertEqual(get_bite_power_bonus(25), (25 * 28) // 2)  # 350
        # Clamped to max level 25
        self.assertEqual(get_bite_power_bonus(30), 350)
        self.assertEqual(get_bite_power_bonus(-5), 0)

    def test_rumen_stats(self):
        # UpgradeConfig.luau: cap = level * 2 + 20, max_mult = 1 + cap * 0.02
        cap0, mult0 = get_rumen_stats(0)
        self.assertEqual(cap0, 20)
        self.assertAlmostEqual(mult0, 1.40)

        cap10, mult10 = get_rumen_stats(10)
        self.assertEqual(cap10, 40)
        self.assertAlmostEqual(mult10, 1.80)

    def test_companion_multiplier(self):
        # clamp(1 + bond * 0.15, 1.0, 1.15)
        self.assertAlmostEqual(get_companion_multiplier(0.0), 1.0)
        self.assertAlmostEqual(get_companion_multiplier(0.25), 1.0375)
        self.assertAlmostEqual(get_companion_multiplier(1.0), 1.15)
        self.assertAlmostEqual(get_companion_multiplier(1.5), 1.15)

    def test_chew_cooldown_and_field_raid_speed(self):
        # max(0.4, 0.7 - level * 0.02), and 0.5x on RaidFood / Wheat
        self.assertAlmostEqual(get_chew_cooldown(0, is_field_raid=False), 0.7)
        self.assertAlmostEqual(get_chew_cooldown(10, is_field_raid=False), 0.5)
        self.assertAlmostEqual(get_chew_cooldown(15, is_field_raid=False), 0.4)
        self.assertAlmostEqual(get_chew_cooldown(20, is_field_raid=False), 0.4)

        # Field Raid 0.5x chew cooldown
        self.assertAlmostEqual(get_chew_cooldown(0, is_field_raid=True), 0.35)
        self.assertAlmostEqual(get_chew_cooldown(15, is_field_raid=True), 0.20)

    def test_zone_definitions(self):
        # FoodConfig.Categories
        self.assertEqual(ZONES["HomeMeadow"]["BaseValue"], 7)
        self.assertEqual(ZONES["SouthPastures"]["BaseValue"], 14)
        self.assertEqual(ZONES["MountainsideMeadow"]["BaseValue"], 21)
        self.assertEqual(ZONES["Cave"]["BaseValue"], 28)

        # Field Raid Zones F1..F10
        self.assertEqual(ZONES["FieldRaid1"]["BaseValue"], 100)
        self.assertEqual(ZONES["FieldRaid5"]["BaseValue"], 1000)
        self.assertEqual(ZONES["FieldRaid8"]["BaseValue"], 5000)
        self.assertEqual(ZONES["FieldRaid10"]["BaseValue"], 25000)

        # Expected secondary bonuses
        self.assertEqual(get_expected_secondary_bonus("HomeMeadow"), 0.0)
        # CloverCreek: 0.10 * (7 * 1.0) = 0.70
        self.assertAlmostEqual(get_expected_secondary_bonus("CloverCreek"), 0.70)
        # AppleOrchard: 0.15 * (15 * 1.1) = 2.475
        self.assertAlmostEqual(get_expected_secondary_bonus("AppleOrchard"), 2.475)

    def test_v3_progression_items_intake(self):
        # Heart o' Davy Jones (2.0x) and Bionic Stomach (1.33x)
        c_base = calculate_bite_yield(rebirth=10, zone="Cave")
        c_davy = calculate_bite_yield(rebirth=10, zone="Cave", davy_jones_heart=True)
        c_stom = calculate_bite_yield(rebirth=10, zone="Cave", bionic_stomach=True)
        c_both = calculate_bite_yield(rebirth=10, zone="Cave", davy_jones_heart=True, bionic_stomach=True)

        self.assertAlmostEqual(c_davy.avg_bite_calories / c_base.avg_bite_calories, 2.0)
        self.assertAlmostEqual(c_stom.avg_bite_calories / c_base.avg_bite_calories, 1.33)
        self.assertAlmostEqual(c_both.avg_bite_calories / c_base.avg_bite_calories, 2.66)

    def test_trailblazer_excursion_multiplier(self):
        # AuraConfig.ExcursionCalories: (1 + 0.2*L) * 1.02^adventure
        self.assertAlmostEqual(get_excursion_multiplier(0, "None", True), 1.0)
        self.assertAlmostEqual(get_excursion_multiplier(5, "None", False), 1.0)
        self.assertAlmostEqual(get_excursion_multiplier(5, "None", True), 2.0)
        self.assertAlmostEqual(get_excursion_multiplier(3, "Adventurous", True), 1.6 * 1.02)
        self.assertAlmostEqual(get_excursion_multiplier(5, "Adventurous", True), 2.0 * (1.02 ** 2))
        self.assertAlmostEqual(get_excursion_multiplier(5, "Unrelenting", True), 2.0)

    def test_field_raid_ripe_bonus_and_powerups(self):
        # FieldRaidCatalog.RipeBonus(level, rebirth)
        # Below R15, factor is 0 -> max(BaseCalories * 0.01, 0) = round(BaseCalories * 0.01)
        self.assertEqual(get_field_raid_ripe_bonus(1, 10), 1)
        self.assertEqual(get_field_raid_ripe_bonus(10, 10), 250)

        # At R20 (factor 0.106): Field 10 RipeExtra = 8,000,000 -> 8,000,000 * 0.106 = 848,000
        self.assertEqual(get_field_raid_ripe_bonus(10, 20), 848_000)
        # At R25 (factor 0.698): Field 10 RipeExtra = 8,000,000 -> 8,000,000 * 0.698 = 5,584,000
        self.assertEqual(get_field_raid_ripe_bonus(10, 25), 5_584_000)

        # Ripe opportunities
        self.assertAlmostEqual(get_field_raid_ripe_opportunities(5), 6.0)
        self.assertAlmostEqual(get_field_raid_ripe_opportunities(10), 17 / 4.0)
        self.assertAlmostEqual(get_field_raid_ripe_opportunities(14), 56 / 4.0)
        self.assertAlmostEqual(get_field_raid_ripe_opportunities(20), 6.0)

        # Strong Chompers (FieldRaidPowerups.Stats)
        self.assertAlmostEqual(get_strong_chompers_multiplier(0), 1.00)
        self.assertAlmostEqual(get_strong_chompers_multiplier(50), 1.50)
        self.assertAlmostEqual(get_strong_chompers_multiplier(98), 1.98)
        self.assertAlmostEqual(get_strong_chompers_multiplier(99), 2.00)

        # Mushroom Island (FieldRaidPowerups.Stats)
        self.assertEqual(get_mushroom_island_stats(-1), (0, 0))
        self.assertEqual(get_mushroom_island_stats(0), (200, 2_000_000))
        self.assertEqual(get_mushroom_island_stats(99), (20_000, 200_000_000))

    def test_field_raid_bite_calculation(self):
        calc = calculate_bite_yield(
            rebirth=20,
            zone="FieldRaid10",
            bite_power_level=25,
            rumen_level=10,
            combo_mode="max",
            companion_bond=1.0,
            chew_speed_level=15,
            headwear="Mythic",
            title="CloverMarbles",
            back_bunnies=5,
            davy_jones_heart=True,
            bionic_stomach=True,
            trailblazer_level=5,
            trailblazer_branch="Adventurous",
            strong_chompers_level=99,
            mushroom_island_level=99,
        )
        self.assertTrue(calc.is_field_raid)
        self.assertEqual(calc.raid_level, 10)
        self.assertAlmostEqual(calc.chew_cooldown, 0.20)
        self.assertEqual(calc.ripe_bonus_base, 848_000)
        self.assertEqual(calc.mushroom_patch_cal_per_sec, 20_000)
        self.assertAlmostEqual(calc.calories_per_second, calc.bite_calories_per_second + 20_000)
        self.assertGreater(calc.ripe_bite_calories, calc.avg_bite_calories * 20)

    def test_calculate_bite_yield_starter(self):
        calc = calculate_bite_yield(
            rebirth=0,
            zone="HomeMeadow",
            grass_type="Regular",
            bite_power_level=0,
            rumen_level=0,
            combo_mode="zero",
            companion_bond=0.0,
            chew_speed_level=0,
            gamepass_2x=False,
        )
        self.assertEqual(calc.rebirth, 0)
        self.assertAlmostEqual(calc.rebirth_multiplier, 1.0)
        self.assertEqual(calc.effective_base_calories, 7.0)
        self.assertAlmostEqual(calc.rumen_multiplier, 1.0)
        self.assertAlmostEqual(calc.companion_multiplier, 1.0)
        # With 0.5% golden chance (avg node mult = 1.005), avg yield = 7.0 * 1.005 = 7.035
        self.assertAlmostEqual(calc.avg_bite_calories, 7.035, places=2)

    def test_calculate_bite_yield_scaling(self):
        # When rebirth increases by 1, multiplier scales by exactly 1.22
        c0 = calculate_bite_yield(rebirth=0)
        c1 = calculate_bite_yield(rebirth=1)
        c2 = calculate_bite_yield(rebirth=2)

        self.assertAlmostEqual(c1.avg_bite_calories / c0.avg_bite_calories, 1.22)
        self.assertAlmostEqual(c2.avg_bite_calories / c1.avg_bite_calories, 1.22)

    def test_title_buff(self):
        # Title_CloverMarbles adds 1.03x to GrazingTitleMultiplier
        c_no_title = calculate_bite_yield(title="None")
        c_title = calculate_bite_yield(title="CloverMarbles")
        self.assertAlmostEqual(c_title.avg_bite_calories / c_no_title.avg_bite_calories, 1.03)

    def test_headwear_bonuses(self):
        # Mining hats add flat base calories before multipliers: Common 5, Mythic 25
        c_none = calculate_bite_yield(headwear="None")
        c_common = calculate_bite_yield(headwear="Common")
        c_mythic = calculate_bite_yield(headwear="Mythic")

        self.assertEqual(c_common.headwear_bonus, 5)
        self.assertEqual(c_mythic.headwear_bonus, 25)
        self.assertEqual(c_common.effective_base_calories - c_none.effective_base_calories, 5)
        self.assertEqual(c_mythic.effective_base_calories - c_none.effective_base_calories, 25)

    def test_back_bunnies(self):
        # 1% per bunny, up to 5 bunnies (1.05x)
        c_0 = calculate_bite_yield(back_bunnies=0)
        c_5 = calculate_bite_yield(back_bunnies=5)
        self.assertAlmostEqual(c_5.avg_bite_calories / c_0.avg_bite_calories, 1.05)

    def test_pillar_bonus(self):
        # Grazer adds 10% pillar bonus
        c_none = calculate_bite_yield(pillar="None")
        c_grazer = calculate_bite_yield(pillar="Grazer")
        self.assertAlmostEqual(c_grazer.avg_bite_calories / c_none.avg_bite_calories, 1.10)


if __name__ == "__main__":
    unittest.main()
