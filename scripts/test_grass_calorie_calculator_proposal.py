#!/usr/bin/env python3
"""Unit tests for grass_calorie_calculator_proposal.py."""

import math
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from grass_calorie_calculator_proposal import (
    MAX_REBIRTH,
    PROPOSAL_PIVOT,
    PROPOSAL_PIVOT_REQUIREMENT,
    calculate_comparison_bite_yield,
    get_cumulative_rebirth_calories,
    get_rebirth_multiplier,
    get_rebirth_requirement,
    get_rebirth_requirement_legacy,
    get_rebirth_requirement_model1,
    get_rebirth_requirement_model2,
    round_significant,
    sanitize_rebirth_count,
)


class TestRebirthProposalCalculator(unittest.TestCase):

    def test_round_significant(self):
        """Verify 3-significant-figure half-up rounding matching Luau math.round."""
        self.assertEqual(round_significant(16412345678, 3), 16400000000)
        self.assertEqual(round_significant(22598765432, 3), 22600000000)
        self.assertEqual(round_significant(12345, 3), 12300)
        self.assertEqual(round_significant(0, 3), 0)
        self.assertEqual(round_significant(-500, 3), 0)
        self.assertEqual(round_significant(float("nan"), 3), 0)
        self.assertEqual(round_significant(float("inf"), 3), 0)

        # Half-up rounding tie test
        # 125 with 2 sig digits -> 130
        self.assertEqual(round_significant(125, 2), 130)

    def test_sanitize_rebirth_count(self):
        """Verify clamping and NaN/Inf guards matching RebirthEconomy.luau."""
        self.assertEqual(sanitize_rebirth_count(0), 0)
        self.assertEqual(sanitize_rebirth_count(25), 25)
        self.assertEqual(sanitize_rebirth_count(20.9), 20)
        self.assertEqual(sanitize_rebirth_count(-10), 0)
        self.assertEqual(sanitize_rebirth_count(float("nan")), 0)
        self.assertEqual(sanitize_rebirth_count(float("inf")), MAX_REBIRTH)
        self.assertEqual(sanitize_rebirth_count(MAX_REBIRTH + 500), MAX_REBIRTH)
        self.assertEqual(sanitize_rebirth_count("invalid"), 0)

    def test_legacy_vs_model2_pre_pivot(self):
        """Below and at pivot (r <= 20), Legacy and Model 2 MUST produce identical values."""
        for r in range(0, PROPOSAL_PIVOT + 1):
            legacy = get_rebirth_requirement_legacy(r)
            model2 = get_rebirth_requirement_model2(r)
            self.assertEqual(
                legacy,
                model2,
                f"Mismatch at pre-pivot tier R{r}: legacy={legacy:,} vs model2={model2:,}",
            )

        # Pivot exact check
        self.assertEqual(get_rebirth_requirement_model2(20), 10_485_760_000)
        self.assertEqual(get_rebirth_requirement_legacy(20), 10_485_760_000)

    def test_model2_proposal_values(self):
        """Verify Model 2 matches the verified proposal constants and RebirthEconomy.luau."""
        expected = {
            20: 10_485_760_000,
            21: 16_400_000_000,
            22: 22_600_000_000,
            23: 29_800_000_000,
            24: 38_500_000_000,
            25: 49_100_000_000,
        }
        for r, expected_req in expected.items():
            actual = get_rebirth_requirement_model2(r)
            self.assertEqual(
                actual,
                expected_req,
                f"Model 2 requirement mismatch at R{r}: actual={actual:,} vs expected={expected_req:,}",
            )

    def test_legacy_explosion(self):
        """Verify that legacy curve explodes while Model 2 stays contained."""
        # R24: Legacy is ~167.77B (209h+), Model 2 is 38.5B (~48h)
        legacy_24 = get_rebirth_requirement_legacy(24)
        model2_24 = get_rebirth_requirement_model2(24)
        self.assertEqual(legacy_24, 167_772_160_000)
        self.assertEqual(model2_24, 38_500_000_000)
        self.assertLess(model2_24, legacy_24 * 0.25)  # More than 75% reduction

        # R25: Legacy is ~335.5B, Model 2 is 49.1B
        legacy_25 = get_rebirth_requirement_legacy(25)
        model2_25 = get_rebirth_requirement_model2(25)
        self.assertEqual(legacy_25, 335_544_320_000)
        self.assertEqual(model2_25, 49_100_000_000)
        self.assertLess(model2_25, legacy_25 * 0.16)

    def test_model1_asymptotic_softcap_exact(self):
        """Verify Model 1 exact values and saturation curve."""
        self.assertEqual(get_rebirth_requirement_model1(20), 10_485_760_000)
        self.assertEqual(get_rebirth_requirement_model1(21), 31_400_000_000)
        self.assertEqual(get_rebirth_requirement_model1(22), 51_800_000_000)
        self.assertEqual(get_rebirth_requirement_model1(23), 74_300_000_000)

        # Requirement increases monotonically
        self.assertGreater(get_rebirth_requirement_model1(30), get_rebirth_requirement_model1(25))

    def test_model_dispatch_flag(self):
        """Verify get_rebirth_requirement dispatches properly based on model name."""
        self.assertEqual(get_rebirth_requirement(24, model="legacy"), 167_772_160_000)
        self.assertEqual(get_rebirth_requirement(24, model="model2"), 38_500_000_000)
        self.assertEqual(get_rebirth_requirement(24, model="default"), 38_500_000_000)
        self.assertEqual(get_rebirth_requirement(20, model="model1"), 10_485_760_000)

    def test_comparison_bite_calculation(self):
        """Verify calculation object contains side-by-side metrics."""
        calc = calculate_comparison_bite_yield(
            rebirth=24,
            zone="HomeMeadow",
            bite_power_level=25,
            rumen_level=10,
            combo="max",
            companion_bond=1.0,
            chew_speed_level=15,
        )
        self.assertEqual(calc.legacy_requirement, 167_772_160_000)
        self.assertEqual(calc.proposal_requirement, 38_500_000_000)
        self.assertGreater(calc.time_saved_percent, 75.0)
        self.assertGreater(calc.daily_pace_5h_proposal, calc.daily_pace_5h_legacy)

    def test_cumulative_rebirth_calories(self):
        """Verify cumulative calculations across models."""
        cum_legacy_5 = get_cumulative_rebirth_calories(5, model="legacy")
        cum_model2_5 = get_cumulative_rebirth_calories(5, model="model2")
        self.assertEqual(cum_legacy_5, cum_model2_5)  # Identical pre-pivot

        # Cumulative up to R25
        cum_legacy_25 = get_cumulative_rebirth_calories(25, model="legacy")
        cum_model2_25 = get_cumulative_rebirth_calories(25, model="model2")
        self.assertLess(cum_model2_25, cum_legacy_25)

    def test_report_exploration_matrix_models(self):
        """Verify the 3 report exploration models: formulas, T(r) hours, daily pace, and campaign totals."""
        models = {
            "Original": {"t0": 100.0, "a": 40.0, "expected_sum": 1604.2, "t20": 100.0, "t24": 164.4, "t29": 192.1, "daily20": 5.0, "daily24": 3.0, "daily29": 2.6},
            "Mediating": {"t0": 50.0, "a": 25.0, "expected_sum": 877.6, "t20": 50.0, "t24": 90.2, "t29": 107.6, "daily20": 10.0, "daily24": 5.5, "daily29": 4.6},
            "Current": {"t0": 29.4, "a": 12.0, "expected_sum": 475.3, "t20": 29.4, "t24": 48.7, "t29": 57.0, "daily20": 17.0, "daily24": 10.3, "daily29": 8.8},
        }

        for name, cfg in models.items():
            t_vals = [cfg["t0"] + cfg["a"] * math.log(1.0 + (r - 20)) for r in range(20, 30)]
            campaign_sum = round(sum(t_vals), 1)
            self.assertEqual(campaign_sum, cfg["expected_sum"], f"{name} cumulative campaign hours mismatch")

            # Check individual milestone tiers
            self.assertEqual(round(t_vals[0], 1), cfg["t20"], f"{name} R20 hours mismatch")
            self.assertEqual(round(t_vals[4], 1), cfg["t24"], f"{name} R24 hours mismatch")
            self.assertEqual(round(t_vals[9], 1), cfg["t29"], f"{name} R29 hours mismatch")

            # Check daily pace (5.0h / T(r))
            self.assertEqual(round(5.0 / t_vals[0] * 100.0, 1), cfg["daily20"], f"{name} R20 daily pace mismatch")
            self.assertEqual(round(5.0 / t_vals[4] * 100.0, 1), cfg["daily24"], f"{name} R24 daily pace mismatch")
            self.assertEqual(round(5.0 / t_vals[9] * 100.0, 1), cfg["daily29"], f"{name} R29 daily pace mismatch")

    def test_v3_stat_bonuses_and_field_raids_in_proposal_calc(self):
        """Verify Alpha V3.0.0 stat bonuses and Field Raids work in calculate_comparison_bite_yield."""
        # Spirit lanterns & weekend reduction on Model 2 (R24 = 38,500,000,000)
        # Weekend -> round(38,500,000,000 * 0.9) = 34,650,000,000
        # 2 Spirit Lanterns (/4) -> 8,662,500,000
        req_m2 = get_rebirth_requirement(24, model="model2", spirit_lanterns=2, weekend_event=True)
        self.assertEqual(req_m2, 8_662_500_000)

        # FieldRaid10 comparison calculation with full V3.0 bonuses
        calc_base = calculate_comparison_bite_yield(
            rebirth=24,
            zone="FieldRaid10",
            bite_power_level=25,
            rumen_level=10,
            combo="max",
            companion_bond=1.0,
            chew_speed_level=15,
        )
        calc_v3 = calculate_comparison_bite_yield(
            rebirth=24,
            zone="FieldRaid10",
            bite_power_level=25,
            rumen_level=10,
            combo="max",
            companion_bond=1.0,
            chew_speed_level=15,
            all_auras_completed=True,
            spirit_lanterns=3,
            davy_jones_heart=True,
            bionic_stomach=True,
            trailblazer_level=5,
            trailblazer_branch="Adventurous",
            strong_chompers_level=99,
            mushroom_island_level=99,
            raid_ripe_active=True,
            weekend_event=True,
        )
        self.assertTrue(calc_v3.is_field_raid)
        self.assertEqual(calc_v3.field_raid_level, 10)
        self.assertAlmostEqual(calc_v3.chew_cooldown, 0.20, places=5)
        self.assertEqual(calc_v3.ripe_bonus_calories, 3_744_000)
        self.assertEqual(calc_v3.effective_base_calories, 3_773_100.0)
        self.assertEqual(calc_v3.mushroom_island_rate, 20_000.0)
        self.assertGreater(calc_v3.total_multiplier, calc_base.total_multiplier * 30.0)
        self.assertLess(calc_v3.proposal_requirement, calc_base.proposal_requirement)


if __name__ == "__main__":
    unittest.main()
