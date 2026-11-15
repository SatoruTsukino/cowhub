#!/usr/bin/env python3
"""Unit tests for grass_calorie_calculator.py."""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from grass_calorie_calculator import (
    BITE_POWER_MAX_LEVEL,
    RUMEN_MAX_LEVEL,
    ZONES,
    calculate_bite_yield,
    get_bite_power_bonus,
    get_chew_cooldown,
    get_companion_multiplier,
    get_cumulative_rebirth_calories,
    get_expected_node_multiplier,
    get_expected_secondary_bonus,
    get_rebirth_multiplier,
    get_rebirth_requirement,
    get_rumen_stats,
)


class TestGrassCalorieCalculator(unittest.TestCase):

    def test_rebirth_multiplier(self):
        # Config.luau: (1 + 0.22) ^ n
        self.assertAlmostEqual(get_rebirth_multiplier(0), 1.0)
        self.assertAlmostEqual(get_rebirth_multiplier(1), 1.22)
        self.assertAlmostEqual(get_rebirth_multiplier(2), 1.4884)
        self.assertAlmostEqual(get_rebirth_multiplier(3), 1.22 ** 3)
        self.assertAlmostEqual(get_rebirth_multiplier(5), 1.22 ** 5)
        self.assertAlmostEqual(get_rebirth_multiplier(10), 1.22 ** 10)
        # Negative clamped to 0
        self.assertAlmostEqual(get_rebirth_multiplier(-1), 1.0)

    def test_rebirth_requirement(self):
        # Config.luau: round(10000 * 2^n / 100) * 100
        self.assertEqual(get_rebirth_requirement(0), 10000)
        self.assertEqual(get_rebirth_requirement(1), 20000)
        self.assertEqual(get_rebirth_requirement(2), 40000)
        self.assertEqual(get_rebirth_requirement(3), 80000)
        self.assertEqual(get_rebirth_requirement(4), 160000)
        self.assertEqual(get_rebirth_requirement(5), 320000)

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

    def test_chew_cooldown(self):
        # max(0.4, 0.7 - level * 0.02)
        self.assertAlmostEqual(get_chew_cooldown(0), 0.7)
        self.assertAlmostEqual(get_chew_cooldown(10), 0.5)
        self.assertAlmostEqual(get_chew_cooldown(15), 0.4)
        self.assertAlmostEqual(get_chew_cooldown(20), 0.4)

    def test_zone_definitions(self):
        # FoodConfig.Categories
        self.assertEqual(ZONES["HomeMeadow"]["BaseValue"], 7)
        self.assertEqual(ZONES["SouthPastures"]["BaseValue"], 14)
        self.assertEqual(ZONES["MountainsideMeadow"]["BaseValue"], 21)
        self.assertEqual(ZONES["Cave"]["BaseValue"], 28)

        # Expected secondary bonuses
        self.assertEqual(get_expected_secondary_bonus("HomeMeadow"), 0.0)
        # CloverCreek: 0.10 * (7 * 1.0) = 0.70
        self.assertAlmostEqual(get_expected_secondary_bonus("CloverCreek"), 0.70)
        # AppleOrchard: 0.15 * (15 * 1.1) = 2.475
        self.assertAlmostEqual(get_expected_secondary_bonus("AppleOrchard"), 2.475)

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
