#!/usr/bin/env python3
"""Tkinter GUI for the Cow Game Grass Multiplier & Calorie Yield Calculator — Rebirth Proposal Edition.

Theme-aware desktop application with high-contrast legibility across:
  - macOS Dark Mode (Night)
  - macOS Light Mode (Day)
  - Windows / Linux dark and light settings
  - High-Contrast mode
  - Automatic live system theme detection

Features full side-by-side comparison between:
  - Current Game Economy (Legacy 2.0^r exponential doubling)
  - Proposed Model 2 (R20 Log-Time Pivot, matching RebirthEconomy.luau)
  - Proposed Model 1 (R20 Asymptotic Softcap, 200h ceiling)
"""

from __future__ import annotations

import os
import sys
import tkinter as tk
from tkinter import font as tkfont
from tkinter import ttk
from typing import Any, Dict, Tuple

# Ensure scripts directory is on sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from grass_calorie_calculator_proposal import (
    BITE_POWER_MAX_LEVEL,
    CHEW_SPEED_MAX_LEVEL,
    FIELD_RAID_FIELDS,
    GRASS_TYPES,
    HEADWEAR_BONUSES,
    MUSHROOM_ISLAND_MAX_LEVEL,
    PILLARS,
    PROPOSAL_PIVOT,
    RUMEN_MAX_LEVEL,
    SPIRIT_LANTERNS_MAX,
    STRONG_CHOMPERS_MAX_LEVEL,
    TITLES,
    TRAILBLAZER_BRANCHES,
    TRAILBLAZER_MAX_LEVEL,
    ZONES,
    ComparisonBiteCalculation,
    calculate_comparison_bite_yield,
    format_hours_abbr,
    format_number_abbr,
    get_bite_power_bonus,
    get_chew_cooldown,
    get_companion_multiplier,
    get_cumulative_rebirth_calories,
    get_rebirth_multiplier,
    get_rebirth_requirement,
    get_ripe_bonus,
    get_rumen_stats,
)

PALETTES: Dict[str, Dict[str, str]] = {
    "dark": {
        "name": "Dark (Night)",
        "bg_window": "#1e1e20",
        "bg_panel": "#1e1e20",
        "bg_card": "#2a2a2e",
        "fg_text": "#e0e0e0",
        "fg_muted": "#a0a0a5",
        "accent_primary": "#4da6ff",
        "accent_success": "#34d399",
        "accent_warning": "#fbbf24",
        "accent_danger": "#f87171",
        "border": "#3d3d42",
        "bg_table_even": "#242428",
        "bg_table_odd": "#1e1e20",
        "bg_table_current": "#1e3a5f",
        "fg_table_current": "#ffffff",
        "bg_table_pivot": "#451a03",
        "fg_table_pivot": "#fef3c7",
        "bg_table_goal": "#064e3b",
        "fg_table_goal": "#a7f3d0",
        "fg_table": "#e0e0e0",
    },
    "light": {
        "name": "Light (Day)",
        "bg_window": "#f4f4f6",
        "bg_panel": "#ffffff",
        "bg_card": "#ffffff",
        "fg_text": "#1a1a1a",
        "fg_muted": "#555555",
        "accent_primary": "#0066cc",
        "accent_success": "#059669",
        "accent_warning": "#d97706",
        "accent_danger": "#dc2626",
        "border": "#cccccc",
        "bg_table_even": "#f9f9fb",
        "bg_table_odd": "#ffffff",
        "bg_table_current": "#dbeafe",
        "fg_table_current": "#1e3a8a",
        "bg_table_pivot": "#fef3c7",
        "fg_table_pivot": "#92400e",
        "bg_table_goal": "#d1fae5",
        "fg_table_goal": "#065f46",
        "fg_table": "#1a1a1a",
    },
    "contrast": {
        "name": "High Contrast",
        "bg_window": "#000000",
        "bg_panel": "#0a0a0a",
        "bg_card": "#121212",
        "fg_text": "#ffffff",
        "fg_muted": "#cccccc",
        "accent_primary": "#00bfff",
        "accent_success": "#00ff66",
        "accent_warning": "#ffcc00",
        "accent_danger": "#ff3333",
        "border": "#ffffff",
        "bg_table_even": "#141414",
        "bg_table_odd": "#000000",
        "bg_table_current": "#003366",
        "fg_table_current": "#ffffff",
        "bg_table_pivot": "#4a3b00",
        "fg_table_pivot": "#ffff99",
        "bg_table_goal": "#004d26",
        "fg_table_goal": "#99ffcc",
        "fg_table": "#ffffff",
    },
}

PRESETS: Dict[str, Dict[str, Any]] = {
    "Starter Cow (R0, Starter)": {
        "rebirth": 0,
        "zone": "HomeMeadow",
        "grass": "Regular",
        "bite_power": 0,
        "rumen": 0,
        "combo": "zero",
        "companion": 0.0,
        "chew_speed": 0,
        "headwear": "None",
        "title": "None",
        "bunnies": 0,
        "pillar": "None",
        "gamepass": False,
        "clover_aura": 0,
        "extra_mult": 1.0,
    },
    "Mid-Game Grinder (R15, Cave)": {
        "rebirth": 15,
        "zone": "Cave",
        "grass": "CaveMoss2",
        "bite_power": 20,
        "rumen": 8,
        "combo": "max",
        "companion": 1.0,
        "chew_speed": 12,
        "headwear": "Rare",
        "title": "CloverMarbles",
        "bunnies": 2,
        "pillar": "None",
        "gamepass": False,
        "clover_aura": 2,
        "extra_mult": 1.0,
    },
    "R20 Pivot Anchor (The Crossroads)": {
        "rebirth": 20,
        "zone": "Cave",
        "grass": "CaveMoss4",
        "bite_power": 25,
        "rumen": 10,
        "combo": "max",
        "companion": 1.0,
        "chew_speed": 15,
        "headwear": "Mythic",
        "title": "CloverMarbles",
        "bunnies": 5,
        "pillar": "Grazer",
        "gamepass": True,
        "clover_aura": 5,
        "extra_mult": 1.0,
    },
    "R24 Pre-Update Goal (The Wall vs The Path)": {
        "rebirth": 24,
        "zone": "Cave",
        "grass": "CaveMoss4",
        "bite_power": 25,
        "rumen": 10,
        "combo": "max",
        "companion": 1.0,
        "chew_speed": 15,
        "headwear": "Mythic",
        "title": "CloverMarbles",
        "bunnies": 5,
        "pillar": "Grazer",
        "gamepass": True,
        "clover_aura": 5,
        "extra_mult": 1.0,
    },
    "V3.0 Raid Runner (R20, Field 8 Granary)": {
        "rebirth": 20,
        "zone": "FieldRaid8",
        "grass": "Regular",
        "bite_power": 25,
        "rumen": 10,
        "combo": "max",
        "companion": 1.0,
        "chew_speed": 15,
        "headwear": "Mythic",
        "title": "CloverMarbles",
        "bunnies": 5,
        "pillar": "Grazer",
        "gamepass": True,
        "clover_aura": 5,
        "extra_mult": 1.0,
        "all_auras": True,
        "spirit_lanterns": 1,
        "davy_heart": True,
        "bionic_stomach": True,
        "trailblazer": 5,
        "trailblazer_branch": "Adventurous",
        "strong_chompers": 50,
        "mushroom_island": 50,
        "raid_ripe": False,
        "weekend": False,
    },
    "V3.0 Max Ogre's Acre (R24, Field 10 + Ripe)": {
        "rebirth": 24,
        "zone": "FieldRaid10",
        "grass": "Regular",
        "bite_power": 25,
        "rumen": 10,
        "combo": "max",
        "companion": 1.0,
        "chew_speed": 15,
        "headwear": "Mythic",
        "title": "CloverMarbles",
        "bunnies": 5,
        "pillar": "Grazer",
        "gamepass": True,
        "clover_aura": 5,
        "extra_mult": 1.0,
        "all_auras": True,
        "spirit_lanterns": 3,
        "davy_heart": True,
        "bionic_stomach": True,
        "trailblazer": 5,
        "trailblazer_branch": "Adventurous",
        "strong_chompers": 99,
        "mushroom_island": 99,
        "raid_ripe": True,
        "weekend": True,
    },
}


class ProposalCalculatorApp:
    """Tkinter application displaying comparison between Legacy and Proposed Rebirth models."""

    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("Cow Game · Rebirth Scaling Proposal & Calorie Calculator")
        self.root.geometry("1160x780")
        self.root.minsize(980, 680)

        self.is_system_dark = self._detect_macos_dark_mode()
        self.var_theme_mode = tk.StringVar(value="Auto (System)")

        # App State
        self.var_model = tk.StringVar(value="model2")
        self.var_preset = tk.StringVar(value="R20 Pivot Anchor (The Crossroads)")
        self.var_rebirth = tk.IntVar(value=20)
        self.var_zone = tk.StringVar(value="Cave")
        self.var_grass = tk.StringVar(value="CaveMoss4")
        self.var_bite_power = tk.IntVar(value=25)
        self.var_rumen = tk.IntVar(value=10)
        self.var_combo = tk.StringVar(value="max")
        self.var_companion = tk.DoubleVar(value=1.0)
        self.var_chew_speed = tk.IntVar(value=15)
        self.var_headwear = tk.StringVar(value="Mythic")
        self.var_title = tk.StringVar(value="CloverMarbles")
        self.var_bunnies = tk.IntVar(value=5)
        self.var_pillar = tk.StringVar(value="Grazer")
        self.var_gamepass = tk.BooleanVar(value=True)
        self.var_clover_aura = tk.IntVar(value=5)
        self.var_extra_mult = tk.DoubleVar(value=1.0)
        self.var_all_auras = tk.BooleanVar(value=False)
        self.var_spirit_lanterns = tk.IntVar(value=0)
        self.var_davy_heart = tk.BooleanVar(value=False)
        self.var_bionic_stomach = tk.BooleanVar(value=False)
        self.var_trailblazer = tk.IntVar(value=0)
        self.var_trailblazer_branch = tk.StringVar(value="None")
        self.var_strong_chompers = tk.IntVar(value=0)
        self.var_mushroom_island = tk.IntVar(value=0)
        self.var_raid_ripe = tk.BooleanVar(value=False)
        self.var_weekend = tk.BooleanVar(value=False)

        self._setup_fonts()
        self._build_layout()
        self._apply_theme()
        self._recalculate()

    def _detect_macos_dark_mode(self) -> bool:
        if sys.platform == "darwin":
            try:
                import subprocess
                cmd = ["defaults", "read", "-g", "AppleInterfaceStyle"]
                out = subprocess.check_output(cmd, stderr=subprocess.DEVNULL)
                return "Dark" in out.decode("utf-8")
            except Exception:
                return False
        return False

    def _setup_fonts(self) -> None:
        self.font_header = tkfont.Font(family="Helvetica", size=14, weight="bold")
        self.font_card_title = tkfont.Font(family="Helvetica", size=9, weight="bold")
        self.font_card_val = tkfont.Font(family="Helvetica", size=16, weight="bold")
        self.font_card_sub = tkfont.Font(family="Helvetica", size=9, weight="bold")
        self.font_mono = tkfont.Font(family="Courier", size=10)
        self.font_bold = tkfont.Font(family="Helvetica", size=10, weight="bold")

    def _get_current_palette(self) -> Dict[str, str]:
        mode = self.var_theme_mode.get()
        if mode == "Auto (System)":
            return PALETTES["dark" if self.is_system_dark else "light"]
        elif "Dark" in mode:
            return PALETTES["dark"]
        elif "Light" in mode:
            return PALETTES["light"]
        elif "High Contrast" in mode:
            return PALETTES["contrast"]
        return PALETTES["dark" if self.is_system_dark else "light"]

    def _build_layout(self) -> None:
        self.top_bar = tk.Frame(self.root, padx=12, pady=8)
        self.top_bar.pack(side=tk.TOP, fill=tk.X)

        self.lbl_title = tk.Label(
            self.top_bar,
            text="🐮 Cow Game · Rebirth Scaling Proposal & Comparison",
            font=self.font_header,
        )
        self.lbl_title.pack(side=tk.LEFT)

        hdr_right = tk.Frame(self.top_bar)
        hdr_right.pack(side=tk.RIGHT)

        tk.Label(hdr_right, text="Theme: ", font=self.font_bold).pack(side=tk.LEFT, padx=(0, 4))
        theme_cb = ttk.Combobox(
            hdr_right,
            textvariable=self.var_theme_mode,
            values=["Auto (System)", "Dark (Night)", "Light (Day)", "High Contrast"],
            state="readonly",
            width=13,
        )
        theme_cb.pack(side=tk.LEFT, padx=(0, 10))
        theme_cb.bind("<<ComboboxSelected>>", lambda e: self._apply_theme())

        tk.Label(hdr_right, text="Preset: ", font=self.font_bold).pack(side=tk.LEFT, padx=(0, 4))
        preset_cb = ttk.Combobox(
            hdr_right,
            textvariable=self.var_preset,
            values=list(PRESETS.keys()),
            state="readonly",
            width=28,
        )
        preset_cb.pack(side=tk.LEFT)
        preset_cb.bind("<<ComboboxSelected>>", self._on_preset_selected)

        # Paned Window
        main_paned = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        main_paned.pack(fill=tk.BOTH, expand=True, padx=10, pady=(0, 10))

        # --- LEFT PANEL: Inputs ---
        left_container = ttk.Frame(main_paned, padding=6)
        main_paned.add(left_container, weight=1)

        self.canvas = tk.Canvas(left_container, borderwidth=0, highlightthickness=0)
        self.scrollbar = ttk.Scrollbar(left_container, orient=tk.VERTICAL, command=self.canvas.yview)
        self.scrollable_frame = ttk.Frame(self.canvas)
        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all")),
        )
        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self._build_input_controls(self.scrollable_frame)

        # --- RIGHT PANEL: Results ---
        right_container = ttk.Frame(main_paned, padding=6)
        main_paned.add(right_container, weight=3)

        self._build_cards(right_container)

        self.notebook = ttk.Notebook(right_container)
        self.notebook.pack(fill=tk.BOTH, expand=True, pady=(6, 0))

        # Tab 1: Breakdown
        tab_breakdown = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(tab_breakdown, text="  Breakdown & Model Comparison  ")
        self.txt_breakdown = tk.Text(
            tab_breakdown,
            wrap=tk.WORD,
            font=self.font_mono,
            borderwidth=1,
            relief=tk.SOLID,
        )
        sb_txt = ttk.Scrollbar(tab_breakdown, orient=tk.VERTICAL, command=self.txt_breakdown.yview)
        self.txt_breakdown.configure(yscrollcommand=sb_txt.set)
        self.txt_breakdown.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        sb_txt.pack(side=tk.RIGHT, fill=tk.Y)

        # Tab 2: Side-by-side progression table
        tab_prog = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(tab_prog, text="  Side-by-Side Progression Table (R0-R30)  ")

        prog_cols = (
            "tier", "inc_mult", "leg_req", "leg_time", "prop_req", "prop_time", "saved", "daily_pace"
        )
        self.tree_prog = ttk.Treeview(tab_prog, columns=prog_cols, show="headings", height=20)
        self.tree_prog.heading("tier", text="Tier Step")
        self.tree_prog.heading("inc_mult", text="Income Mult")
        self.tree_prog.heading("leg_req", text="Legacy Req (2.0^r)")
        self.tree_prog.heading("leg_time", text="Legacy Time")
        self.tree_prog.heading("prop_req", text="Model 2 Req (Log)")
        self.tree_prog.heading("prop_time", text="Model 2 Time")
        self.tree_prog.heading("saved", text="Time Saved")
        self.tree_prog.heading("daily_pace", text="Daily Pace (5h)")

        self.tree_prog.column("tier", width=105, anchor="center")
        self.tree_prog.column("inc_mult", width=85, anchor="e")
        self.tree_prog.column("leg_req", width=130, anchor="e")
        self.tree_prog.column("leg_time", width=95, anchor="e")
        self.tree_prog.column("prop_req", width=130, anchor="e")
        self.tree_prog.column("prop_time", width=95, anchor="e")
        self.tree_prog.column("saved", width=85, anchor="center")
        self.tree_prog.column("daily_pace", width=100, anchor="center")

        sb_prog = ttk.Scrollbar(tab_prog, orient=tk.VERTICAL, command=self.tree_prog.yview)
        self.tree_prog.configure(yscrollcommand=sb_prog.set)
        self.tree_prog.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        sb_prog.pack(side=tk.RIGHT, fill=tk.Y)

        # Tab 3: Field Raids Comparison (Fields 1 - 10)
        tab_raids = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(tab_raids, text="  🌾 Field Raids (F1 - F10)  ")

        raid_cols = (
            "field", "name", "base_cal", "ripe_bonus", "avg_bite", "cal_sec", "ripe_cal_sec", "leg_time", "prop_time"
        )
        self.tree_raids = ttk.Treeview(tab_raids, columns=raid_cols, show="headings", height=14)
        self.tree_raids.heading("field", text="Field")
        self.tree_raids.heading("name", text="Raid Field Name")
        self.tree_raids.heading("base_cal", text="Base Cal")
        self.tree_raids.heading("ripe_bonus", text="Ripe Bonus")
        self.tree_raids.heading("avg_bite", text="Avg Bite")
        self.tree_raids.heading("cal_sec", text="Cal / Sec")
        self.tree_raids.heading("ripe_cal_sec", text="Ripe Cal/s")
        self.tree_raids.heading("leg_time", text="Legacy Next R")
        self.tree_raids.heading("prop_time", text="Model 2 Next R")

        self.tree_raids.column("field", width=48, anchor="center")
        self.tree_raids.column("name", width=155, anchor="w")
        self.tree_raids.column("base_cal", width=80, anchor="e")
        self.tree_raids.column("ripe_bonus", width=95, anchor="e")
        self.tree_raids.column("avg_bite", width=100, anchor="e")
        self.tree_raids.column("cal_sec", width=100, anchor="e")
        self.tree_raids.column("ripe_cal_sec", width=105, anchor="e")
        self.tree_raids.column("leg_time", width=90, anchor="e")
        self.tree_raids.column("prop_time", width=90, anchor="e")

        sb_raids = ttk.Scrollbar(tab_raids, orient=tk.VERTICAL, command=self.tree_raids.yview)
        self.tree_raids.configure(yscrollcommand=sb_raids.set)
        self.tree_raids.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        sb_raids.pack(side=tk.RIGHT, fill=tk.Y)

        self.notebook.bind("<<NotebookTabChanged>>", lambda e: self._on_tab_changed())

    def _build_input_controls(self, parent: ttk.Frame) -> None:
        # 1. Economy Model Selection
        sec_model = ttk.LabelFrame(parent, text="Proposal Model Switcher", padding="8 6 8 8")
        sec_model.pack(fill=tk.X, pady=(0, 6))

        rb_m2 = ttk.Radiobutton(
            sec_model,
            text="Model 2: Log-Time Pivot (Proposal) [Recommended]",
            value="model2",
            variable=self.var_model,
            command=self._recalculate,
        )
        rb_m2.pack(anchor="w", pady=1)

        rb_leg = ttk.Radiobutton(
            sec_model,
            text="Legacy: 2.0^r Exponential (Current Game)",
            value="legacy",
            variable=self.var_model,
            command=self._recalculate,
        )
        rb_leg.pack(anchor="w", pady=1)

        rb_m1 = ttk.Radiobutton(
            sec_model,
            text="Model 1: Asymptotic Softcap (200h Ceiling)",
            value="model1",
            variable=self.var_model,
            command=self._recalculate,
        )
        rb_m1.pack(anchor="w", pady=1)

        # 2. Rebirth Tier
        sec_rebirth = ttk.LabelFrame(parent, text="Rebirth Tier", padding="8 6 8 8")
        sec_rebirth.pack(fill=tk.X, pady=(0, 6))

        row_r = ttk.Frame(sec_rebirth)
        row_r.pack(fill=tk.X, pady=2)
        ttk.Label(row_r, text="Rebirth Count (n):", width=16).pack(side=tk.LEFT)
        sp_r = ttk.Spinbox(
            row_r,
            from_=0,
            to=100,
            textvariable=self.var_rebirth,
            width=6,
            command=self._recalculate,
        )
        sp_r.pack(side=tk.LEFT, padx=4)
        sp_r.bind("<KeyRelease>", lambda e: self._recalculate())
        self.lbl_rebirth_mult = tk.Label(row_r, text="1.00x", font=self.font_bold)
        self.lbl_rebirth_mult.pack(side=tk.LEFT, padx=6)

        # 3. Zone & Flora
        sec_zone = ttk.LabelFrame(parent, text="Zone & Flora", padding="8 6 8 8")
        sec_zone.pack(fill=tk.X, pady=(0, 6))

        row_z = ttk.Frame(sec_zone)
        row_z.pack(fill=tk.X, pady=2)
        ttk.Label(row_z, text="Zone:", width=16).pack(side=tk.LEFT)
        cb_z = ttk.Combobox(
            row_z,
            textvariable=self.var_zone,
            values=list(ZONES.keys()),
            state="readonly",
            width=16,
        )
        cb_z.pack(side=tk.LEFT, padx=4)
        cb_z.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        row_g = ttk.Frame(sec_zone)
        row_g.pack(fill=tk.X, pady=2)
        ttk.Label(row_g, text="Grass Type:", width=16).pack(side=tk.LEFT)
        cb_g = ttk.Combobox(
            row_g,
            textvariable=self.var_grass,
            values=list(GRASS_TYPES.keys()),
            state="readonly",
            width=16,
        )
        cb_g.pack(side=tk.LEFT, padx=4)
        cb_g.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        # 4. Upgrades
        sec_upgrades = ttk.LabelFrame(parent, text="Core Upgrades", padding="8 6 8 8")
        sec_upgrades.pack(fill=tk.X, pady=(0, 6))

        row_bp = ttk.Frame(sec_upgrades)
        row_bp.pack(fill=tk.X, pady=2)
        ttk.Label(row_bp, text="Bite Power (0-25):", width=16).pack(side=tk.LEFT)
        sp_bp = ttk.Spinbox(
            row_bp,
            from_=0,
            to=BITE_POWER_MAX_LEVEL,
            textvariable=self.var_bite_power,
            width=6,
            command=self._recalculate,
        )
        sp_bp.pack(side=tk.LEFT, padx=4)
        sp_bp.bind("<KeyRelease>", lambda e: self._recalculate())

        row_ru = ttk.Frame(sec_upgrades)
        row_ru.pack(fill=tk.X, pady=2)
        ttk.Label(row_ru, text="Rumen (0-10):", width=16).pack(side=tk.LEFT)
        sp_ru = ttk.Spinbox(
            row_ru,
            from_=0,
            to=RUMEN_MAX_LEVEL,
            textvariable=self.var_rumen,
            width=6,
            command=self._recalculate,
        )
        sp_ru.pack(side=tk.LEFT, padx=4)
        sp_ru.bind("<KeyRelease>", lambda e: self._recalculate())

        row_cs = ttk.Frame(sec_upgrades)
        row_cs.pack(fill=tk.X, pady=2)
        ttk.Label(row_cs, text="Chew Speed (0-15):", width=16).pack(side=tk.LEFT)
        sp_cs = ttk.Spinbox(
            row_cs,
            from_=0,
            to=CHEW_SPEED_MAX_LEVEL,
            textvariable=self.var_chew_speed,
            width=6,
            command=self._recalculate,
        )
        sp_cs.pack(side=tk.LEFT, padx=4)
        sp_cs.bind("<KeyRelease>", lambda e: self._recalculate())

        # 5. Gear & Titles
        sec_gear = ttk.LabelFrame(parent, text="Gear, Title & Pillar", padding="8 6 8 8")
        sec_gear.pack(fill=tk.X, pady=(0, 6))

        row_hw = ttk.Frame(sec_gear)
        row_hw.pack(fill=tk.X, pady=2)
        ttk.Label(row_hw, text="Hat (Cosmetic):", width=16).pack(side=tk.LEFT)
        cb_hw = ttk.Combobox(
            row_hw,
            textvariable=self.var_headwear,
            values=list(HEADWEAR_BONUSES.keys()),
            state="readonly",
            width=14,
        )
        cb_hw.pack(side=tk.LEFT, padx=4)
        cb_hw.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        row_ti = ttk.Frame(sec_gear)
        row_ti.pack(fill=tk.X, pady=2)
        ttk.Label(row_ti, text="Equipped Title:", width=16).pack(side=tk.LEFT)
        cb_ti = ttk.Combobox(
            row_ti,
            textvariable=self.var_title,
            values=list(TITLES.keys()),
            state="readonly",
            width=14,
        )
        cb_ti.pack(side=tk.LEFT, padx=4)
        cb_ti.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        row_pil = ttk.Frame(sec_gear)
        row_pil.pack(fill=tk.X, pady=2)
        ttk.Label(row_pil, text="Pillar Perk:", width=16).pack(side=tk.LEFT)
        cb_pil = ttk.Combobox(
            row_pil,
            textvariable=self.var_pillar,
            values=list(PILLARS.keys()),
            state="readonly",
            width=14,
        )
        cb_pil.pack(side=tk.LEFT, padx=4)
        cb_pil.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        row_bn = ttk.Frame(sec_gear)
        row_bn.pack(fill=tk.X, pady=2)
        ttk.Label(row_bn, text="Back Bunnies (0-5):", width=16).pack(side=tk.LEFT)
        sp_bn = ttk.Spinbox(
            row_bn,
            from_=0,
            to=5,
            textvariable=self.var_bunnies,
            width=6,
            command=self._recalculate,
        )
        sp_bn.pack(side=tk.LEFT, padx=4)
        sp_bn.bind("<KeyRelease>", lambda e: self._recalculate())

        # 6. Buffs
        sec_buffs = ttk.LabelFrame(parent, text="Companion & Gamepass", padding="8 6 8 8")
        sec_buffs.pack(fill=tk.X, pady=(0, 6))

        row_cp = ttk.Frame(sec_buffs)
        row_cp.pack(fill=tk.X, pady=2)
        ttk.Label(row_cp, text="Companion (0-1):", width=16).pack(side=tk.LEFT)
        sc_cp = ttk.Scale(
            row_cp,
            from_=0.0,
            to=1.0,
            variable=self.var_companion,
            command=lambda v: self._recalculate(),
        )
        sc_cp.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        row_gp = ttk.Frame(sec_buffs)
        row_gp.pack(fill=tk.X, pady=2)
        cb_gp = ttk.Checkbutton(
            row_gp,
            text="2x Calories Gamepass",
            variable=self.var_gamepass,
            command=self._recalculate,
        )
        cb_gp.pack(side=tk.LEFT)

        # 7. Alpha V3.0.0 Progression & Field Raids
        sec_v3 = ttk.LabelFrame(parent, text="Alpha V3.0.0: Progression & Field Raids", padding="8 6 8 8")
        sec_v3.pack(fill=tk.X, pady=(0, 6))

        cb_aa = ttk.Checkbutton(
            sec_v3,
            text="All 5 Aura Paths Mastered (2x Rebirth Mult)",
            variable=self.var_all_auras,
            command=self._recalculate,
        )
        cb_aa.pack(anchor="w", pady=1)

        row_sl = ttk.Frame(sec_v3)
        row_sl.pack(fill=tk.X, pady=2)
        ttk.Label(row_sl, text="Spirit Lanterns (0-3):", width=18).pack(side=tk.LEFT)
        sp_sl = ttk.Spinbox(
            row_sl,
            from_=0,
            to=SPIRIT_LANTERNS_MAX,
            textvariable=self.var_spirit_lanterns,
            width=6,
            command=self._recalculate,
        )
        sp_sl.pack(side=tk.LEFT, padx=4)
        sp_sl.bind("<KeyRelease>", lambda e: self._recalculate())

        cb_dh = ttk.Checkbutton(
            sec_v3,
            text="Heart o' Davy Jones (2.0x Intake)",
            variable=self.var_davy_heart,
            command=self._recalculate,
        )
        cb_dh.pack(anchor="w", pady=1)

        cb_bs = ttk.Checkbutton(
            sec_v3,
            text="Bionic Stomach (1.33x Intake)",
            variable=self.var_bionic_stomach,
            command=self._recalculate,
        )
        cb_bs.pack(anchor="w", pady=1)

        row_tb = ttk.Frame(sec_v3)
        row_tb.pack(fill=tk.X, pady=2)
        ttk.Label(row_tb, text="Trailblazer (0-5):", width=18).pack(side=tk.LEFT)
        sp_tb = ttk.Spinbox(
            row_tb,
            from_=0,
            to=TRAILBLAZER_MAX_LEVEL,
            textvariable=self.var_trailblazer,
            width=5,
            command=self._recalculate,
        )
        sp_tb.pack(side=tk.LEFT, padx=2)
        sp_tb.bind("<KeyRelease>", lambda e: self._recalculate())
        cb_tbb = ttk.Combobox(
            row_tb,
            textvariable=self.var_trailblazer_branch,
            values=list(TRAILBLAZER_BRANCHES),
            state="readonly",
            width=11,
        )
        cb_tbb.pack(side=tk.LEFT, padx=2)
        cb_tbb.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        row_sc = ttk.Frame(sec_v3)
        row_sc.pack(fill=tk.X, pady=2)
        ttk.Label(row_sc, text="Strong Chompers (0-99):", width=18).pack(side=tk.LEFT)
        sp_sc = ttk.Spinbox(
            row_sc,
            from_=0,
            to=STRONG_CHOMPERS_MAX_LEVEL,
            textvariable=self.var_strong_chompers,
            width=6,
            command=self._recalculate,
        )
        sp_sc.pack(side=tk.LEFT, padx=4)
        sp_sc.bind("<KeyRelease>", lambda e: self._recalculate())

        row_mi = ttk.Frame(sec_v3)
        row_mi.pack(fill=tk.X, pady=2)
        ttk.Label(row_mi, text="Mushroom Island (0-99):", width=18).pack(side=tk.LEFT)
        sp_mi = ttk.Spinbox(
            row_mi,
            from_=0,
            to=MUSHROOM_ISLAND_MAX_LEVEL,
            textvariable=self.var_mushroom_island,
            width=6,
            command=self._recalculate,
        )
        sp_mi.pack(side=tk.LEFT, padx=4)
        sp_mi.bind("<KeyRelease>", lambda e: self._recalculate())

        cb_rr = ttk.Checkbutton(
            sec_v3,
            text="Ripe Wheat Bell Window Active (Raid)",
            variable=self.var_raid_ripe,
            command=self._recalculate,
        )
        cb_rr.pack(anchor="w", pady=1)

        cb_wk = ttk.Checkbutton(
            sec_v3,
            text="Weekend Event (1.5x Cal, -10% Req)",
            variable=self.var_weekend,
            command=self._recalculate,
        )
        cb_wk.pack(anchor="w", pady=1)

    def _build_cards(self, parent: ttk.Frame) -> None:
        cards_frame = tk.Frame(parent)
        cards_frame.pack(fill=tk.X, pady=(0, 6))
        self.cards = []

        titles = [
            "GRASS MULTIPLIER",
            "BITE CALORIE YIELD",
            "CALORIE INCOME RATE",
            "NEXT REBIRTH PACING",
        ]

        for i, title in enumerate(titles):
            f = tk.Frame(cards_frame, relief=tk.SOLID, borderwidth=1, padx=8, pady=6)
            f.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0 if i == 0 else 4, 0))

            lbl_t = tk.Label(f, text=title, font=self.font_card_title)
            lbl_t.pack(anchor="w")

            lbl_v = tk.Label(f, text="--", font=self.font_card_val)
            lbl_v.pack(anchor="w", pady=(2, 0))

            lbl_s = tk.Label(f, text="--", font=self.font_card_sub)
            lbl_s.pack(anchor="w")

            self.cards.append((f, lbl_t, lbl_v, lbl_s))

    def _apply_theme(self) -> None:
        p = self._get_current_palette()
        self.root.configure(bg=p["bg_window"])
        self.top_bar.configure(bg=p["bg_panel"])
        self.lbl_title.configure(bg=p["bg_panel"], fg=p["fg_text"])

        for f, lbl_t, lbl_v, lbl_s in self.cards:
            f.configure(bg=p["bg_card"], highlightbackground=p["border"])
            lbl_t.configure(bg=p["bg_card"], fg=p["fg_muted"])
            lbl_v.configure(bg=p["bg_card"], fg=p["accent_primary"])
            lbl_s.configure(bg=p["bg_card"], fg=p["accent_success"])

        self.txt_breakdown.configure(
            bg=p["bg_card"],
            fg=p["fg_text"],
            insertbackground=p["fg_text"],
            highlightbackground=p["border"],
        )

        style = ttk.Style()
        style.theme_use("default")
        style.configure(
            "Treeview",
            background=p["bg_table_odd"],
            foreground=p["fg_table"],
            fieldbackground=p["bg_table_odd"],
            borderwidth=0,
            font=self.font_mono,
        )
        style.configure(
            "Treeview.Heading",
            background=p["bg_card"],
            foreground=p["fg_text"],
            font=self.font_bold,
        )

        self._update_progression_table()
        self._update_raid_table()

    def _on_preset_selected(self, event=None) -> None:
        name = self.var_preset.get()
        if name in PRESETS:
            d = PRESETS[name]
            self.var_rebirth.set(d["rebirth"])
            self.var_zone.set(d["zone"])
            self.var_grass.set(d["grass"])
            self.var_bite_power.set(d["bite_power"])
            self.var_rumen.set(d["rumen"])
            self.var_companion.set(d["companion"])
            self.var_chew_speed.set(d["chew_speed"])
            self.var_headwear.set(d["headwear"])
            self.var_title.set(d["title"])
            self.var_bunnies.set(d["bunnies"])
            self.var_pillar.set(d["pillar"])
            self.var_gamepass.set(d["gamepass"])
            self.var_all_auras.set(bool(d.get("all_auras", False)))
            self.var_spirit_lanterns.set(int(d.get("spirit_lanterns", 0)))
            self.var_davy_heart.set(bool(d.get("davy_heart", False)))
            self.var_bionic_stomach.set(bool(d.get("bionic_stomach", False)))
            self.var_trailblazer.set(int(d.get("trailblazer", 0)))
            self.var_trailblazer_branch.set(str(d.get("trailblazer_branch", "None")))
            self.var_strong_chompers.set(int(d.get("strong_chompers", 0)))
            self.var_mushroom_island.set(int(d.get("mushroom_island", 0)))
            self.var_raid_ripe.set(bool(d.get("raid_ripe", False)))
            self.var_weekend.set(bool(d.get("weekend", False)))
            self._recalculate()

    def _safe_get_int(self, var: tk.IntVar, default: int = 0, min_val: int = 0, max_val: int = 1000) -> int:
        try:
            val = var.get()
            return max(min_val, min(max_val, int(val)))
        except (tk.TclError, ValueError, TypeError):
            return default

    def _safe_get_float(self, var: tk.DoubleVar, default: float = 1.0, min_val: float = 0.0, max_val: float = 100.0) -> float:
        try:
            val = var.get()
            return max(min_val, min(max_val, float(val)))
        except (tk.TclError, ValueError, TypeError):
            return default

    def _recalculate(self) -> None:
        calc = calculate_comparison_bite_yield(
            rebirth=self._safe_get_int(self.var_rebirth, default=0, min_val=0, max_val=1000),
            zone=self.var_zone.get(),
            grass_type=self.var_grass.get(),
            bite_power_level=self._safe_get_int(self.var_bite_power, default=25, min_val=0, max_val=BITE_POWER_MAX_LEVEL),
            rumen_level=self._safe_get_int(self.var_rumen, default=10, min_val=0, max_val=RUMEN_MAX_LEVEL),
            combo=self.var_combo.get(),
            companion_bond=self._safe_get_float(self.var_companion, default=1.0, min_val=0.0, max_val=1.0),
            chew_speed_level=self._safe_get_int(self.var_chew_speed, default=15, min_val=0, max_val=CHEW_SPEED_MAX_LEVEL),
            headwear=self.var_headwear.get(),
            title=self.var_title.get(),
            back_bunnies=self._safe_get_int(self.var_bunnies, default=0, min_val=0, max_val=5),
            pillar=self.var_pillar.get(),
            gamepass_2x=bool(self.var_gamepass.get()),
            model=self.var_model.get(),
            all_auras_completed=bool(self.var_all_auras.get()),
            spirit_lanterns=self._safe_get_int(self.var_spirit_lanterns, default=0, min_val=0, max_val=SPIRIT_LANTERNS_MAX),
            davy_jones_heart=bool(self.var_davy_heart.get()),
            bionic_stomach=bool(self.var_bionic_stomach.get()),
            trailblazer_level=self._safe_get_int(self.var_trailblazer, default=0, min_val=0, max_val=TRAILBLAZER_MAX_LEVEL),
            trailblazer_branch=self.var_trailblazer_branch.get(),
            strong_chompers_level=self._safe_get_int(self.var_strong_chompers, default=0, min_val=0, max_val=STRONG_CHOMPERS_MAX_LEVEL),
            mushroom_island_level=self._safe_get_int(self.var_mushroom_island, default=0, min_val=0, max_val=MUSHROOM_ISLAND_MAX_LEVEL),
            raid_ripe_active=bool(self.var_raid_ripe.get()),
            weekend_event=bool(self.var_weekend.get()),
        )

        self.lbl_rebirth_mult.config(text=f"{calc.rebirth_multiplier:,.2f}×")

        # Cards
        _, _, card0_val, card0_sub = self.cards[0]
        card0_val.config(text=f"{calc.rebirth_multiplier:,.2f}×")
        aura_tag = " [2x Aura]" if calc.all_auras_completed else ""
        card0_sub.config(text=f"+{(calc.rebirth_multiplier - 1.0) * 100:,.0f}% vs R0{aura_tag}")

        _, _, card1_val, card1_sub = self.cards[1]
        card1_val.config(text=f"{calc.avg_bite_calories:,.1f} Cal")
        card1_sub.config(text=f"{calc.min_bite_calories:,} min – {calc.max_bite_calories:,} max")

        _, _, card2_val, card2_sub = self.cards[2]
        card2_val.config(text=f"{calc.calories_per_second:,.1f} /s")
        hr_rate = calc.calories_per_second * 3600
        hr_str = f"{hr_rate / 1e6:,.2f}M /hr" if hr_rate >= 1e6 else f"{hr_rate:,.0f} /hr"
        card2_sub.config(text=f"{hr_str} ({calc.chew_cooldown:.2f}s/bite)")

        _, _, card3_val, card3_sub = self.cards[3]
        active_hours = calc.active_seconds / 3600.0
        time_str = f"{active_hours:,.1f} hrs" if active_hours >= 1.0 else f"{calc.active_seconds / 60.0:,.1f} min"
        card3_val.config(text=f"{format_number_abbr(calc.active_requirement)} Cal")
        if calc.rebirth > PROPOSAL_PIVOT and self.var_model.get() == "model2":
            card3_sub.config(text=f"{time_str} (-{calc.time_saved_percent:.1f}% vs 2.0^r)")
        else:
            card3_sub.config(text=f"{time_str} to complete")

        self._update_breakdown_text(calc)
        active_tab = self.notebook.index(self.notebook.select())
        if active_tab == 1:
            self._update_progression_table()
        elif active_tab == 2:
            self._update_raid_table()

    def _update_breakdown_text(self, calc: ComparisonBiteCalculation) -> None:
        self.txt_breakdown.delete("1.0", tk.END)
        raid_section = ""
        if calc.is_field_raid and calc.field_raid_level is not None:
            raid_section = (
                f"--------------------------------------------------------------------------------\n"
                f"NORTH RIVER FIELD RAID (Field {calc.field_raid_level}):\n"
                f"--------------------------------------------------------------------------------\n"
                f"• Raid Wheat Cooldown:                {calc.chew_cooldown:.3f}s (0.5× fast wheat chew)\n"
                f"• Ripe Wheat Bonus (Bell Window):     +{calc.ripe_bonus_calories:,} Base Cal ({'ACTIVE' if calc.raid_ripe_active else 'inactive'})\n"
                f"• Expected Ripe Opportunities:        {calc.ripe_opportunities_per_cycle:.1f} / 20m cycle\n"
                f"• Ripe Window Bite & Rate:            {calc.ripe_avg_bite_calories:,.1f} Cal/bite ({calc.ripe_calories_per_second:,.1f} Cal/s)\n"
                f"• Mushroom Island Patch Growth:       +{calc.mushroom_island_rate:,.0f} Cal/s (Cap {calc.mushroom_island_capacity:,} Cal)\n\n"
            )
        text = (
            f"================================================================================\n"
            f"🐮 COW GAME REBIRTH & BITE CALORIE CALCULATOR — PROPOSAL EDITION (Rebirth {calc.rebirth})\n"
            f"================================================================================\n"
            f"Active Model Selected:                {calc.selected_model.upper()}\n"
            f"• Grass Multiplier:                   {calc.rebirth_multiplier:,.4f}× (Compound (1 + 0.22)^{calc.rebirth}{' × 2 All Auras' if calc.all_auras_completed else ''})\n"
            f"• Total Combined Multiplier:          {calc.total_multiplier:,.4f}×\n"
            f"• V3.0 Intake Bonuses:                DavyHeart={calc.davy_jones_multiplier:.2f}× | Stomach={calc.bionic_stomach_multiplier:.2f}× | Chompers={calc.strong_chompers_multiplier:.2f}×\n"
            f"• V3.0 Excursion & Event:             Trailblazer={calc.excursion_multiplier:.4f}× | Weekend={calc.weekend_multiplier:.2f}× | Lanterns={calc.spirit_lanterns}/3\n"
            f"• Effective Base Calories:            {calc.effective_base_calories:.2f} Cal\n"
            f"• Average Bite Yield:                 {calc.avg_bite_calories:,.1f} Calories / bite\n"
            f"• Calorie Earning Rate:               {calc.calories_per_second:,.1f} Cal/sec ({calc.calories_per_second * 3600:,.0f} Cal/hr)\n\n"
            f"{raid_section}"
            f"--------------------------------------------------------------------------------\n"
            f"PROGRESSION & RETENTION COMPARISON:\n"
            f"--------------------------------------------------------------------------------\n"
            f"  [1] Legacy Exponential (2.0^{calc.rebirth}):\n"
            f"      Requirement:                    {calc.legacy_requirement:,} Cal ({format_number_abbr(calc.legacy_requirement)})\n"
            f"      Estimated Time:                 {format_hours_abbr(calc.legacy_seconds)}\n"
            f"      Daily Pace (5h active play):    {calc.daily_pace_5h_legacy:.1f}% / day\n\n"
            f"  [2] Proposal Model 2 (R20 Log-Time Pivot) [RECOMMENDED]:\n"
            f"      Requirement:                    {calc.proposal_requirement:,} Cal ({format_number_abbr(calc.proposal_requirement)})\n"
            f"      Estimated Time:                 {format_hours_abbr(calc.proposal_seconds)}\n"
            f"      Daily Pace (5h active play):    {calc.daily_pace_5h_proposal:.1f}% / day\n"
            f"      Time Saved vs Legacy:           {format_hours_abbr(calc.time_saved_seconds)} (-{calc.time_saved_percent:.1f}%)\n\n"
            f"  [3] Proposal Model 1 (R20 Asymptotic Softcap, 200h Ceiling):\n"
            f"      Requirement:                    {calc.model1_requirement:,} Cal ({format_number_abbr(calc.model1_requirement)})\n"
            f"      Estimated Time:                 {format_hours_abbr(calc.model1_seconds)}\n"
            f"--------------------------------------------------------------------------------\n"
            f"Takeaway for Rebirth {calc.rebirth}:\n"
            f"  Under Model 2, a player in a 5h daily session gains {calc.daily_pace_5h_proposal:.1f}% progress per day,\n"
            f"  turning what was a {format_hours_abbr(calc.legacy_seconds)} cliff into an achievable {format_hours_abbr(calc.proposal_seconds)} milestone.\n"
            f"================================================================================\n"
        )
        self.txt_breakdown.insert(tk.END, text)

    def _on_tab_changed(self) -> None:
        idx = self.notebook.index(self.notebook.select())
        if idx == 1:
            self._update_progression_table()
        elif idx == 2:
            self._update_raid_table()

    def _update_progression_table(self) -> None:
        p = self._get_current_palette()
        for item in self.tree_prog.get_children():
            self.tree_prog.delete(item)

        current_r = self._safe_get_int(self.var_rebirth, default=0, min_val=0, max_val=1000)
        zone = self.var_zone.get()
        grass = self.var_grass.get()
        bp = self._safe_get_int(self.var_bite_power, default=25, min_val=0, max_val=BITE_POWER_MAX_LEVEL)
        rumen = self._safe_get_int(self.var_rumen, default=10, min_val=0, max_val=RUMEN_MAX_LEVEL)
        combo = self.var_combo.get()
        comp = self._safe_get_float(self.var_companion, default=1.0, min_val=0.0, max_val=1.0)
        chew = self._safe_get_int(self.var_chew_speed, default=15, min_val=0, max_val=CHEW_SPEED_MAX_LEVEL)
        hw = self.var_headwear.get()
        title = self.var_title.get()
        bunnies = self._safe_get_int(self.var_bunnies, default=0, min_val=0, max_val=5)
        pillar = self.var_pillar.get()
        gp = bool(self.var_gamepass.get())
        all_auras = bool(self.var_all_auras.get())
        lanterns = self._safe_get_int(self.var_spirit_lanterns, default=0, min_val=0, max_val=SPIRIT_LANTERNS_MAX)
        davy = bool(self.var_davy_heart.get())
        stomach = bool(self.var_bionic_stomach.get())
        tb_lvl = self._safe_get_int(self.var_trailblazer, default=0, min_val=0, max_val=TRAILBLAZER_MAX_LEVEL)
        tb_branch = self.var_trailblazer_branch.get()
        chompers = self._safe_get_int(self.var_strong_chompers, default=0, min_val=0, max_val=STRONG_CHOMPERS_MAX_LEVEL)
        mush = self._safe_get_int(self.var_mushroom_island, default=0, min_val=0, max_val=MUSHROOM_ISLAND_MAX_LEVEL)
        ripe = bool(self.var_raid_ripe.get())
        wknd = bool(self.var_weekend.get())

        for r in range(31):
            c = calculate_comparison_bite_yield(
                rebirth=r,
                zone=zone,
                grass_type=grass,
                bite_power_level=bp,
                rumen_level=rumen,
                combo=combo,
                companion_bond=comp,
                chew_speed_level=chew,
                headwear=hw,
                title=title,
                back_bunnies=bunnies,
                pillar=pillar,
                gamepass_2x=gp,
                all_auras_completed=all_auras,
                spirit_lanterns=lanterns,
                davy_jones_heart=davy,
                bionic_stomach=stomach,
                trailblazer_level=tb_lvl,
                trailblazer_branch=tb_branch,
                strong_chompers_level=chompers,
                mushroom_island_level=mush,
                raid_ripe_active=ripe,
                weekend_event=wknd,
            )

            tier_label = f"R{r}→R{r+1}"
            if r == PROPOSAL_PIVOT:
                tag = "pivot"
                tier_label += " (Pivot)"
            elif r == 24 or r == 25:
                tag = "goal"
                tier_label += " (Goal)"
            elif r == current_r:
                tag = "current"
                tier_label += " (Cur)"
            else:
                tag = "even" if r % 2 == 0 else "odd"

            saved_str = f"-{c.time_saved_percent:.1f}%" if c.time_saved_percent > 0 else "0.0%"
            pace_str = f"{c.daily_pace_5h_proposal:.1f}%/day"

            self.tree_prog.insert(
                "",
                tk.END,
                values=(
                    tier_label,
                    f"{c.rebirth_multiplier:,.2f}×",
                    format_number_abbr(c.legacy_requirement),
                    format_hours_abbr(c.legacy_seconds),
                    format_number_abbr(c.proposal_requirement),
                    format_hours_abbr(c.proposal_seconds),
                    saved_str,
                    pace_str,
                ),
                tags=(tag,),
            )

        self.tree_prog.tag_configure("current", background=p["bg_table_current"], foreground=p["fg_table_current"])
        self.tree_prog.tag_configure("pivot", background=p["bg_table_pivot"], foreground=p["fg_table_pivot"])
        self.tree_prog.tag_configure("goal", background=p["bg_table_goal"], foreground=p["fg_table_goal"])
        self.tree_prog.tag_configure("even", background=p["bg_table_even"], foreground=p["fg_table"])
        self.tree_prog.tag_configure("odd", background=p["bg_table_odd"], foreground=p["fg_table"])

    def _update_raid_table(self) -> None:
        if not hasattr(self, "tree_raids"):
            return
        p = self._get_current_palette()
        for item in self.tree_raids.get_children():
            self.tree_raids.delete(item)

        r = self._safe_get_int(self.var_rebirth, default=0, min_val=0, max_val=1000)
        cur_zone = self.var_zone.get()
        bp = self._safe_get_int(self.var_bite_power, default=25, min_val=0, max_val=BITE_POWER_MAX_LEVEL)
        rumen = self._safe_get_int(self.var_rumen, default=10, min_val=0, max_val=RUMEN_MAX_LEVEL)
        combo = self.var_combo.get()
        comp = self._safe_get_float(self.var_companion, default=1.0, min_val=0.0, max_val=1.0)
        chew = self._safe_get_int(self.var_chew_speed, default=15, min_val=0, max_val=CHEW_SPEED_MAX_LEVEL)
        hw = self.var_headwear.get()
        title = self.var_title.get()
        bunnies = self._safe_get_int(self.var_bunnies, default=0, min_val=0, max_val=5)
        pillar = self.var_pillar.get()
        gp = bool(self.var_gamepass.get())
        all_auras = bool(self.var_all_auras.get())
        lanterns = self._safe_get_int(self.var_spirit_lanterns, default=0, min_val=0, max_val=SPIRIT_LANTERNS_MAX)
        davy = bool(self.var_davy_heart.get())
        stomach = bool(self.var_bionic_stomach.get())
        tb_lvl = self._safe_get_int(self.var_trailblazer, default=0, min_val=0, max_val=TRAILBLAZER_MAX_LEVEL)
        tb_branch = self.var_trailblazer_branch.get()
        chompers = self._safe_get_int(self.var_strong_chompers, default=0, min_val=0, max_val=STRONG_CHOMPERS_MAX_LEVEL)
        mush = self._safe_get_int(self.var_mushroom_island, default=0, min_val=0, max_val=MUSHROOM_ISLAND_MAX_LEVEL)
        wknd = bool(self.var_weekend.get())

        for fl in range(1, 11):
            z_key = f"FieldRaid{fl}"
            f_info = FIELD_RAID_FIELDS[fl]
            c = calculate_comparison_bite_yield(
                rebirth=r,
                zone=z_key,
                grass_type="Regular",
                bite_power_level=bp,
                rumen_level=rumen,
                combo=combo,
                companion_bond=comp,
                chew_speed_level=chew,
                headwear=hw,
                title=title,
                back_bunnies=bunnies,
                pillar=pillar,
                gamepass_2x=gp,
                all_auras_completed=all_auras,
                spirit_lanterns=lanterns,
                davy_jones_heart=davy,
                bionic_stomach=stomach,
                trailblazer_level=tb_lvl,
                trailblazer_branch=tb_branch,
                strong_chompers_level=chompers,
                mushroom_island_level=mush,
                raid_ripe_active=False,
                weekend_event=wknd,
            )
            tag = "current" if cur_zone == z_key else ("even" if fl % 2 == 0 else "odd")
            self.tree_raids.insert(
                "",
                tk.END,
                values=(
                    f"F{fl}",
                    str(f_info["name"]),
                    f"{int(f_info['base_calories']):,}",
                    f"+{c.ripe_bonus_calories:,}",
                    format_number_abbr(int(round(c.avg_bite_calories))),
                    f"{format_number_abbr(int(round(c.calories_per_second)))}/s",
                    f"{format_number_abbr(int(round(c.ripe_calories_per_second)))}/s",
                    format_hours_abbr(c.legacy_seconds),
                    format_hours_abbr(c.proposal_seconds),
                ),
                tags=(tag,),
            )

        self.tree_raids.tag_configure("current", background=p["bg_table_current"], foreground=p["fg_table_current"])
        self.tree_raids.tag_configure("even", background=p["bg_table_even"], foreground=p["fg_table"])
        self.tree_raids.tag_configure("odd", background=p["bg_table_odd"], foreground=p["fg_table"])


def main() -> None:
    root = tk.Tk()
    app = ProposalCalculatorApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
