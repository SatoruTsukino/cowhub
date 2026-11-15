#!/usr/bin/env python3
"""Tkinter GUI for the Cow Game Grass Multiplier & Calorie Yield Calculator.

Theme-aware desktop application with high-contrast legibility across:
  - macOS Dark Mode (Night)
  - macOS Light Mode (Day)
  - Windows / Linux dark and light settings
  - High-Contrast mode
  - Automatic live system theme detection

Factors in:
  - Rebirth Multipliers ((1 + 0.22)^n)
  - Upgrades (Bite Power, Rumen Combo, Chew Speed)
  - Headwear / Mining Hat Base Calorie bonuses (+5 to +25 Base)
  - Titles (e.g. Title_CloverMarbles +3% grazing calories)
  - Back Bunnies (0 to 5 bunnies, +1% grazing calories each)
  - Pillar buffs (e.g. Grazer Pillar +10% grass calories)
  - Companion Familiarity / Pet bond (up to 1.15x)
  - Golden grass node chances & secondary flora
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

from grass_calorie_calculator import (
    BITE_POWER_MAX_LEVEL,
    CHEW_SPEED_MAX_LEVEL,
    GRASS_TYPES,
    HEADWEAR_BONUSES,
    PILLARS,
    RUMEN_MAX_LEVEL,
    TITLES,
    ZONES,
    BiteCalculation,
    calculate_bite_yield,
    get_bite_power_bonus,
    get_chew_cooldown,
    get_companion_multiplier,
    get_cumulative_rebirth_calories,
    get_rebirth_multiplier,
    get_rebirth_requirement,
    get_rumen_stats,
)

# --- Color Palettes for Flawless Day & Night Legibility ---

PALETTES: Dict[str, Dict[str, str]] = {
    "dark": {
        "name": "Dark (Night)",
        "bg_window": "#1e1e20",
        "bg_panel": "#1e1e20",
        "bg_card": "#28282b",
        "border_card": "#3e3e42",
        "fg_primary": "#f5f5f7",
        "fg_secondary": "#a1a1a6",
        "fg_accent": "#4ade80",       # bright pastel green for key stats
        "fg_card_title": "#9ca3af",
        "fg_card_sub": "#cbd5e1",
        "bg_text": "#161618",
        "fg_text": "#f3f4f6",
        "border_text": "#374151",
        "bg_table_even": "#242428",
        "bg_table_odd": "#1a1a1d",
        "fg_table": "#f3f4f6",
        "bg_table_current": "#14532d",  # deep forest green highlight
        "fg_table_current": "#86efac",  # high-contrast bright text
        "tree_header_bg": "#2e2e32",
        "tree_header_fg": "#f9fafb",
    },
    "light": {
        "name": "Light (Day)",
        "bg_window": "#f2f2f7",
        "bg_panel": "#f2f2f7",
        "bg_card": "#ffffff",
        "border_card": "#d1d1d6",
        "fg_primary": "#1c1c1e",
        "fg_secondary": "#4b5563",
        "fg_accent": "#15803d",       # rich dark green for key stats
        "fg_card_title": "#4b5563",
        "fg_card_sub": "#374151",
        "bg_text": "#ffffff",
        "fg_text": "#111827",
        "border_text": "#cbd5e1",
        "bg_table_even": "#f9fafb",
        "bg_table_odd": "#ffffff",
        "fg_table": "#111827",
        "bg_table_current": "#dcfce7",  # soft mint green
        "fg_table_current": "#14532d",  # deep green text
        "tree_header_bg": "#e5e7eb",
        "tree_header_fg": "#111827",
    },
    "contrast": {
        "name": "High Contrast",
        "bg_window": "#000000",
        "bg_panel": "#000000",
        "bg_card": "#121212",
        "border_card": "#ffffff",
        "fg_primary": "#ffffff",
        "fg_secondary": "#facc15",    # vibrant amber/yellow
        "fg_accent": "#00ff66",       # pure high-contrast lime
        "fg_card_title": "#e2e8f0",
        "fg_card_sub": "#ffffff",
        "bg_text": "#000000",
        "fg_text": "#ffffff",
        "border_text": "#ffffff",
        "bg_table_even": "#18181b",
        "bg_table_odd": "#09090b",
        "fg_table": "#ffffff",
        "bg_table_current": "#00441b",
        "fg_table_current": "#00ff66",
        "tree_header_bg": "#27272a",
        "tree_header_fg": "#ffffff",
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
    "Early Game (R1, Level 5 BP)": {
        "rebirth": 1,
        "zone": "CloverCreek",
        "grass": "Regular",
        "bite_power": 5,
        "rumen": 2,
        "combo": "max",
        "companion": 0.25,
        "chew_speed": 5,
        "headwear": "Common",
        "title": "None",
        "bunnies": 1,
        "pillar": "None",
        "gamepass": False,
        "clover_aura": 0,
        "extra_mult": 1.0,
    },
    "Mid Game (R3, Rare Hat + Title)": {
        "rebirth": 3,
        "zone": "SouthPastures",
        "grass": "Regular",
        "bite_power": 15,
        "rumen": 6,
        "combo": "max",
        "companion": 0.5,
        "chew_speed": 10,
        "headwear": "Rare",
        "title": "CloverMarbles",
        "bunnies": 2,
        "pillar": "None",
        "gamepass": False,
        "clover_aura": 1,
        "extra_mult": 1.0,
    },
    "High Pastures (R5, Mountainside)": {
        "rebirth": 5,
        "zone": "MountainsideMeadow",
        "grass": "Redgrass",
        "bite_power": 25,
        "rumen": 10,
        "combo": "max",
        "companion": 1.0,
        "chew_speed": 15,
        "headwear": "SuperRare",
        "title": "CloverMarbles",
        "bunnies": 5,
        "pillar": "Grazer",
        "gamepass": False,
        "clover_aura": 2,
        "extra_mult": 1.0,
    },
    "Endgame Cavern Farmer (R10+, Maxed)": {
        "rebirth": 10,
        "zone": "Cave",
        "grass": "Bluegrass",
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
}


def detect_system_is_dark(root: tk.Tk) -> bool:
    """Detect whether current OS window environment is in Dark / Night mode."""
    try:
        rgb = root.winfo_rgb(root.cget("bg"))
        lum = (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 65535.0
        return lum < 0.5
    except Exception:
        return True


class GrassCalorieGUI:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("Cow Game · Grass Multiplier & Calorie Yield Calculator")
        self.root.geometry("1100x820")
        self.root.minsize(960, 700)

        # Detect system dark mode on startup
        self.is_system_dark = detect_system_is_dark(self.root)
        self.active_theme_key = "dark" if self.is_system_dark else "light"

        # UI Variables
        self.var_theme_mode = tk.StringVar(value="Auto (System)")
        self.var_preset = tk.StringVar(value="High Pastures (R5, Mountainside)")
        self.var_rebirth = tk.IntVar(value=5)
        self.var_zone = tk.StringVar(value="MountainsideMeadow")
        self.var_grass = tk.StringVar(value="Redgrass")
        self.var_bite_power = tk.IntVar(value=25)
        self.var_rumen = tk.IntVar(value=10)
        self.var_combo = tk.StringVar(value="max")
        self.var_companion = tk.DoubleVar(value=1.0)
        self.var_chew_speed = tk.IntVar(value=15)
        self.var_headwear = tk.StringVar(value="SuperRare")
        self.var_title = tk.StringVar(value="CloverMarbles")
        self.var_bunnies = tk.IntVar(value=5)
        self.var_pillar = tk.StringVar(value="Grazer")
        self.var_gamepass = tk.BooleanVar(value=False)
        self.var_clover_aura = tk.IntVar(value=2)
        self.var_extra_mult = tk.DoubleVar(value=1.0)

        self._updating = False

        self._setup_fonts()
        self._build_layout()
        self._apply_theme()
        self._bind_events()
        self._recalculate()

    def _setup_fonts(self) -> None:
        self.font_header = tkfont.Font(family="Helvetica", size=15, weight="bold")
        self.font_card_title = tkfont.Font(family="Helvetica", size=9, weight="bold")
        self.font_card_val = tkfont.Font(family="Helvetica", size=18, weight="bold")
        self.font_card_sub = tkfont.Font(family="Helvetica", size=10, weight="bold")
        self.font_mono = tkfont.Font(family="Courier", size=11)
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
        # Top Header Bar
        self.top_bar = tk.Frame(self.root, padx=12, pady=8)
        self.top_bar.pack(side=tk.TOP, fill=tk.X)

        self.lbl_title = tk.Label(
            self.top_bar,
            text="🐄 Cow Game · Grass Multiplier & Calorie Calculator",
            font=self.font_header,
        )
        self.lbl_title.pack(side=tk.LEFT)

        # Right Header Controls (Preset & Theme Selectors)
        hdr_right = tk.Frame(self.top_bar)
        hdr_right.pack(side=tk.RIGHT)

        # Theme Selector
        self.lbl_theme = tk.Label(hdr_right, text="Theme: ", font=self.font_bold)
        self.lbl_theme.pack(side=tk.LEFT, padx=(0, 4))
        theme_cb = ttk.Combobox(
            hdr_right,
            textvariable=self.var_theme_mode,
            values=["Auto (System)", "Dark (Night)", "Light (Day)", "High Contrast"],
            state="readonly",
            width=14,
        )
        theme_cb.pack(side=tk.LEFT, padx=(0, 12))
        theme_cb.bind("<<ComboboxSelected>>", self._on_theme_changed)

        # Preset Selector
        self.lbl_preset = tk.Label(hdr_right, text="Preset: ", font=self.font_bold)
        self.lbl_preset.pack(side=tk.LEFT, padx=(0, 4))
        preset_cb = ttk.Combobox(
            hdr_right,
            textvariable=self.var_preset,
            values=list(PRESETS.keys()),
            state="readonly",
            width=28,
        )
        preset_cb.pack(side=tk.LEFT)
        preset_cb.bind("<<ComboboxSelected>>", self._on_preset_selected)

        # Main Paned / 2-column layout
        main_paned = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        main_paned.pack(fill=tk.BOTH, expand=True, padx=10, pady=(0, 10))

        # --- LEFT PANEL: Inputs & Upgrades ---
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

        self._build_controls(self.scrollable_frame)

        # --- RIGHT PANEL: Cards & Notebook ---
        right_container = ttk.Frame(main_paned, padding=6)
        main_paned.add(right_container, weight=3)

        self._build_results(right_container)

    def _build_controls(self, parent: ttk.Frame) -> None:
        # 1. Rebirth Section
        sec_rebirth = ttk.LabelFrame(parent, text="Rebirth Status", padding="8 6 8 8")
        sec_rebirth.pack(fill=tk.X, pady=(0, 8))

        row1 = ttk.Frame(sec_rebirth)
        row1.pack(fill=tk.X, pady=2)
        ttk.Label(row1, text="Rebirth Level (n):", width=16).pack(side=tk.LEFT)
        sp_rebirth = ttk.Spinbox(
            row1,
            from_=0,
            to=100,
            textvariable=self.var_rebirth,
            width=8,
            command=self._recalculate,
        )
        sp_rebirth.pack(side=tk.LEFT, padx=4)
        sp_rebirth.bind("<KeyRelease>", lambda e: self._recalculate())

        self.lbl_rebirth_sub = tk.Label(sec_rebirth, text="Multiplier: 1.0000x | Next: 10,000 Cal", anchor="w")
        self.lbl_rebirth_sub.pack(fill=tk.X, pady=(2, 0))

        # 2. Location & Flora
        sec_zone = ttk.LabelFrame(parent, text="Zone & Flora", padding="8 6 8 8")
        sec_zone.pack(fill=tk.X, pady=(0, 8))

        row_z = ttk.Frame(sec_zone)
        row_z.pack(fill=tk.X, pady=2)
        ttk.Label(row_z, text="Zone:", width=16).pack(side=tk.LEFT)
        cb_zone = ttk.Combobox(
            row_z,
            textvariable=self.var_zone,
            values=list(ZONES.keys()),
            state="readonly",
            width=18,
        )
        cb_zone.pack(side=tk.LEFT, padx=4)
        cb_zone.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        self.lbl_zone_sub = tk.Label(sec_zone, text="Base: 7 Cal | Golden: 0.5%", anchor="w")
        self.lbl_zone_sub.pack(fill=tk.X, pady=(1, 4))

        row_g = ttk.Frame(sec_zone)
        row_g.pack(fill=tk.X, pady=2)
        ttk.Label(row_g, text="Grass Type:", width=16).pack(side=tk.LEFT)
        cb_grass = ttk.Combobox(
            row_g,
            textvariable=self.var_grass,
            values=[k for k in GRASS_TYPES.keys() if "CaveMoss" not in k or "Cave" in self.var_zone.get()],
            state="readonly",
            width=18,
        )
        cb_grass.pack(side=tk.LEFT, padx=4)
        cb_grass.bind("<<ComboboxSelected>>", lambda e: self._recalculate())

        # 3. Upgrades Section
        sec_upgrades = ttk.LabelFrame(parent, text="Cow Upgrades", padding="8 6 8 8")
        sec_upgrades.pack(fill=tk.X, pady=(0, 8))

        # Bite Power
        row_bp = ttk.Frame(sec_upgrades)
        row_bp.pack(fill=tk.X, pady=2)
        ttk.Label(row_bp, text="Bite Power (0-25):", width=16).pack(side=tk.LEFT)
        self.lbl_bp_val = tk.Label(row_bp, text="25 (+350)", width=10, font=self.font_bold)
        self.lbl_bp_val.pack(side=tk.RIGHT)
        sc_bp = ttk.Scale(
            row_bp,
            from_=0,
            to=BITE_POWER_MAX_LEVEL,
            variable=self.var_bite_power,
            command=self._on_bp_scale,
        )
        sc_bp.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        # Rumen
        row_rumen = ttk.Frame(sec_upgrades)
        row_rumen.pack(fill=tk.X, pady=2)
        ttk.Label(row_rumen, text="Rumen (0-10):", width=16).pack(side=tk.LEFT)
        self.lbl_rumen_val = tk.Label(row_rumen, text="10 (Cap 40)", width=10, font=self.font_bold)
        self.lbl_rumen_val.pack(side=tk.RIGHT)
        sc_rumen = ttk.Scale(
            row_rumen,
            from_=0,
            to=RUMEN_MAX_LEVEL,
            variable=self.var_rumen,
            command=self._on_rumen_scale,
        )
        sc_rumen.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        row_combo = ttk.Frame(sec_upgrades)
        row_combo.pack(fill=tk.X, pady=2)
        ttk.Label(row_combo, text="Combo Mode:", width=16).pack(side=tk.LEFT)
        cb_combo = ttk.Combobox(
            row_combo,
            textvariable=self.var_combo,
            values=["max", "half", "zero"],
            state="readonly",
            width=8,
        )
        cb_combo.pack(side=tk.LEFT, padx=4)
        cb_combo.bind("<<ComboboxSelected>>", lambda e: self._recalculate())
        self.lbl_combo_sub = tk.Label(row_combo, text="1.80x (+80%)")
        self.lbl_combo_sub.pack(side=tk.LEFT, padx=4)

        # Chew Speed
        row_chew = ttk.Frame(sec_upgrades)
        row_chew.pack(fill=tk.X, pady=2)
        ttk.Label(row_chew, text="Chew Speed (0-15):", width=16).pack(side=tk.LEFT)
        self.lbl_chew_val = tk.Label(row_chew, text="15 (0.40s)", width=10, font=self.font_bold)
        self.lbl_chew_val.pack(side=tk.RIGHT)
        sc_chew = ttk.Scale(
            row_chew,
            from_=0,
            to=CHEW_SPEED_MAX_LEVEL,
            variable=self.var_chew_speed,
            command=self._on_chew_scale,
        )
        sc_chew.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        # 4. Title, Headwear & Gear Buffs (NEW)
        sec_gear = ttk.LabelFrame(parent, text="Gear, Title & Cosmetics", padding="8 6 8 8")
        sec_gear.pack(fill=tk.X, pady=(0, 8))

        # Headwear Hat
        row_hw = ttk.Frame(sec_gear)
        row_hw.pack(fill=tk.X, pady=2)
        ttk.Label(row_hw, text="Headwear Hat:", width=16).pack(side=tk.LEFT)
        cb_hw = ttk.Combobox(
            row_hw,
            textvariable=self.var_headwear,
            values=list(HEADWEAR_BONUSES.keys()),
            state="readonly",
            width=14,
        )
        cb_hw.pack(side=tk.LEFT, padx=4)
        cb_hw.bind("<<ComboboxSelected>>", lambda e: self._recalculate())
        self.lbl_hw_hint = tk.Label(row_hw, text="+0 Base Cal")
        self.lbl_hw_hint.pack(side=tk.LEFT)

        # Title
        row_title = ttk.Frame(sec_gear)
        row_title.pack(fill=tk.X, pady=2)
        ttk.Label(row_title, text="Title Buff:", width=16).pack(side=tk.LEFT)
        cb_title = ttk.Combobox(
            row_title,
            textvariable=self.var_title,
            values=list(TITLES.keys()),
            state="readonly",
            width=14,
        )
        cb_title.pack(side=tk.LEFT, padx=4)
        cb_title.bind("<<ComboboxSelected>>", lambda e: self._recalculate())
        self.lbl_title_hint = tk.Label(row_title, text="1.00×")
        self.lbl_title_hint.pack(side=tk.LEFT)

        # Back Bunnies
        row_bunnies = ttk.Frame(sec_gear)
        row_bunnies.pack(fill=tk.X, pady=2)
        ttk.Label(row_bunnies, text="Back Bunnies (0-5):", width=16).pack(side=tk.LEFT)
        sp_bunnies = ttk.Spinbox(
            row_bunnies,
            from_=0,
            to=5,
            textvariable=self.var_bunnies,
            width=6,
            command=self._recalculate,
        )
        sp_bunnies.pack(side=tk.LEFT, padx=4)
        sp_bunnies.bind("<KeyRelease>", lambda e: self._recalculate())
        self.lbl_bunnies_hint = tk.Label(row_bunnies, text="(+1% Cal each)")
        self.lbl_bunnies_hint.pack(side=tk.LEFT)

        # Pillar
        row_pillar = ttk.Frame(sec_gear)
        row_pillar.pack(fill=tk.X, pady=2)
        ttk.Label(row_pillar, text="Pillar Perk:", width=16).pack(side=tk.LEFT)
        cb_pillar = ttk.Combobox(
            row_pillar,
            textvariable=self.var_pillar,
            values=list(PILLARS.keys()),
            state="readonly",
            width=14,
        )
        cb_pillar.pack(side=tk.LEFT, padx=4)
        cb_pillar.bind("<<ComboboxSelected>>", lambda e: self._recalculate())
        self.lbl_pillar_hint = tk.Label(row_pillar, text="+0% Cal")
        self.lbl_pillar_hint.pack(side=tk.LEFT)

        # 5. Companion & Extra Boosts
        sec_buffs = ttk.LabelFrame(parent, text="Companion & Boosts", padding="8 6 8 8")
        sec_buffs.pack(fill=tk.X, pady=(0, 8))

        row_comp = ttk.Frame(sec_buffs)
        row_comp.pack(fill=tk.X, pady=2)
        ttk.Label(row_comp, text="Companion:", width=16).pack(side=tk.LEFT)
        self.lbl_comp_val = tk.Label(row_comp, text="1.15x (Max)", width=10, font=self.font_bold)
        self.lbl_comp_val.pack(side=tk.RIGHT)
        sc_comp = ttk.Scale(
            row_comp,
            from_=0.0,
            to=1.0,
            variable=self.var_companion,
            command=self._on_companion_scale,
        )
        sc_comp.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        row_clover = ttk.Frame(sec_buffs)
        row_clover.pack(fill=tk.X, pady=2)
        ttk.Label(row_clover, text="Lucky Clover Aura:", width=16).pack(side=tk.LEFT)
        sp_clover = ttk.Spinbox(
            row_clover,
            from_=0,
            to=5,
            textvariable=self.var_clover_aura,
            width=6,
            command=self._recalculate,
        )
        sp_clover.pack(side=tk.LEFT, padx=4)
        sp_clover.bind("<KeyRelease>", lambda e: self._recalculate())
        self.lbl_clover_hint = tk.Label(row_clover, text="(+3% gold / lvl)")
        self.lbl_clover_hint.pack(side=tk.LEFT)

        row_gp = ttk.Frame(sec_buffs)
        row_gp.pack(fill=tk.X, pady=4)
        cb_gp = ttk.Checkbutton(
            row_gp,
            text="2x Calories Gamepass",
            variable=self.var_gamepass,
            command=self._recalculate,
        )
        cb_gp.pack(side=tk.LEFT)

        row_extra = ttk.Frame(sec_buffs)
        row_extra.pack(fill=tk.X, pady=2)
        ttk.Label(row_extra, text="Event / Other Mult:", width=16).pack(side=tk.LEFT)
        sp_extra = ttk.Spinbox(
            row_extra,
            from_=1.0,
            to=10.0,
            increment=0.5,
            textvariable=self.var_extra_mult,
            width=6,
            command=self._recalculate,
        )
        sp_extra.pack(side=tk.LEFT, padx=4)
        sp_extra.bind("<KeyRelease>", lambda e: self._recalculate())

    def _build_results(self, parent: ttk.Frame) -> None:
        # 4 High-Legibility Result Cards
        self.cards_container = tk.Frame(parent)
        self.cards_container.pack(fill=tk.X, pady=(0, 8))

        self.cards: list[Tuple[tk.Frame, tk.Label, tk.Label, tk.Label]] = []
        self.cards.append(self._create_stat_card(self.cards_container, "GRASS MULTIPLIER", "1.0000×", "+0.0% vs R0", col=0))
        self.cards.append(self._create_stat_card(self.cards_container, "AVG BITE YIELD", "0.0 Cal", "Single Bite Yield", col=1))
        self.cards.append(self._create_stat_card(self.cards_container, "CALORIE RATE", "0.0 Cal/s", "0 Cal / hr", col=2))
        self.cards.append(self._create_stat_card(self.cards_container, "NEXT REBIRTH", "0 bites", "0.0 minutes", col=3))

        for c in range(4):
            self.cards_container.columnconfigure(c, weight=1)

        # Tabbed Notebook
        self.notebook = ttk.Notebook(parent)
        self.notebook.pack(fill=tk.BOTH, expand=True)

        # Tab 1: Detailed Breakdown
        self.tab_breakdown = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(self.tab_breakdown, text="Calculation Breakdown")
        self._build_breakdown_tab(self.tab_breakdown)

        # Tab 2: Rebirth Progression Table
        self.tab_progression = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(self.tab_progression, text="Rebirth Table (R0 - R20)")
        self._build_progression_tab(self.tab_progression)

        # Tab 3: Zone Comparison Table
        self.tab_zones = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(self.tab_zones, text="Zone Comparison")
        self._build_zones_tab(self.tab_zones)

    def _create_stat_card(
        self, parent: tk.Frame, title: str, default_val: str, default_sub: str, col: int
    ) -> Tuple[tk.Frame, tk.Label, tk.Label, tk.Label]:
        card = tk.Frame(parent, padx=10, pady=8, relief="solid", borderwidth=1)
        card.grid(row=0, column=col, sticky="nsew", padx=3)

        title_lbl = tk.Label(card, text=title, font=self.font_card_title, anchor="w")
        title_lbl.pack(anchor="w")

        val_lbl = tk.Label(card, text=default_val, font=self.font_card_val, anchor="w")
        val_lbl.pack(anchor="w", pady=(3, 2))

        sub_lbl = tk.Label(card, text=default_sub, font=self.font_card_sub, anchor="w")
        sub_lbl.pack(anchor="w")

        return card, title_lbl, val_lbl, sub_lbl

    def _build_breakdown_tab(self, parent: ttk.Frame) -> None:
        self.txt_breakdown = tk.Text(
            parent,
            wrap=tk.WORD,
            font=self.font_mono,
            borderwidth=1,
            relief="solid",
            padx=8,
            pady=8,
        )
        scroll = ttk.Scrollbar(parent, orient=tk.VERTICAL, command=self.txt_breakdown.yview)
        self.txt_breakdown.configure(yscrollcommand=scroll.set)

        self.txt_breakdown.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll.pack(side=tk.RIGHT, fill=tk.Y)

    def _build_progression_tab(self, parent: ttk.Frame) -> None:
        cols = ("Rebirth", "Multiplier", "Requirement", "AvgBite", "CalSec", "BitesToRebirth", "TimeToRebirth")
        self.tree_prog = ttk.Treeview(parent, columns=cols, show="headings", height=16)

        self.tree_prog.heading("Rebirth", text="Rebirth (n)")
        self.tree_prog.heading("Multiplier", text="Multiplier")
        self.tree_prog.heading("Requirement", text="Next Req (Cal)")
        self.tree_prog.heading("AvgBite", text="Avg Bite Yield")
        self.tree_prog.heading("CalSec", text="Cal / Sec")
        self.tree_prog.heading("BitesToRebirth", text="Bites to Rebirth")
        self.tree_prog.heading("TimeToRebirth", text="Est. Time")

        self.tree_prog.column("Rebirth", width=85, anchor="center")
        self.tree_prog.column("Multiplier", width=95, anchor="center")
        self.tree_prog.column("Requirement", width=120, anchor="e")
        self.tree_prog.column("AvgBite", width=115, anchor="e")
        self.tree_prog.column("CalSec", width=105, anchor="e")
        self.tree_prog.column("BitesToRebirth", width=115, anchor="e")
        self.tree_prog.column("TimeToRebirth", width=105, anchor="center")

        scroll = ttk.Scrollbar(parent, orient=tk.VERTICAL, command=self.tree_prog.yview)
        self.tree_prog.configure(yscrollcommand=scroll.set)

        self.tree_prog.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll.pack(side=tk.RIGHT, fill=tk.Y)

    def _build_zones_tab(self, parent: ttk.Frame) -> None:
        cols = ("Zone", "Category", "BaseSec", "GoldenPct", "AvgBite", "CalSec", "BitesToNext", "Unlock")
        self.tree_zones = ttk.Treeview(parent, columns=cols, show="headings", height=12)

        self.tree_zones.heading("Zone", text="Zone")
        self.tree_zones.heading("Category", text="Category")
        self.tree_zones.heading("BaseSec", text="Base+Sec")
        self.tree_zones.heading("GoldenPct", text="Golden Rate")
        self.tree_zones.heading("AvgBite", text="Avg Bite Cal")
        self.tree_zones.heading("CalSec", text="Cal / Sec")
        self.tree_zones.heading("BitesToNext", text="Bites to Next")
        self.tree_zones.heading("Unlock", text="Status")

        self.tree_zones.column("Zone", width=155, anchor="w")
        self.tree_zones.column("Category", width=85, anchor="center")
        self.tree_zones.column("BaseSec", width=85, anchor="e")
        self.tree_zones.column("GoldenPct", width=95, anchor="center")
        self.tree_zones.column("AvgBite", width=115, anchor="e")
        self.tree_zones.column("CalSec", width=105, anchor="e")
        self.tree_zones.column("BitesToNext", width=110, anchor="e")
        self.tree_zones.column("Unlock", width=90, anchor="center")

        scroll = ttk.Scrollbar(parent, orient=tk.VERTICAL, command=self.tree_zones.yview)
        self.tree_zones.configure(yscrollcommand=scroll.set)

        self.tree_zones.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll.pack(side=tk.RIGHT, fill=tk.Y)

    def _bind_events(self) -> None:
        self.notebook.bind("<<NotebookTabChanged>>", self._on_tab_changed)

    # --- Theme Application ---

    def _apply_theme(self) -> None:
        p = self._get_current_palette()

        # Window and Header Bar
        self.root.configure(bg=p["bg_window"])
        self.top_bar.configure(bg=p["bg_panel"])
        self.lbl_title.configure(bg=p["bg_panel"], fg=p["fg_primary"])
        self.lbl_theme.configure(bg=p["bg_panel"], fg=p["fg_secondary"])
        self.lbl_preset.configure(bg=p["bg_panel"], fg=p["fg_secondary"])

        # Canvas & Container
        self.canvas.configure(bg=p["bg_panel"])
        self.cards_container.configure(bg=p["bg_panel"])

        # Helper Text Labels
        helper_labels = [
            self.lbl_rebirth_sub,
            self.lbl_zone_sub,
            self.lbl_bp_val,
            self.lbl_rumen_val,
            self.lbl_combo_sub,
            self.lbl_chew_val,
            self.lbl_hw_hint,
            self.lbl_title_hint,
            self.lbl_bunnies_hint,
            self.lbl_pillar_hint,
            self.lbl_comp_val,
            self.lbl_clover_hint,
        ]
        for lbl in helper_labels:
            lbl.configure(bg=p["bg_panel"], fg=p["fg_secondary"])

        # Highlight Values (Bold Primary)
        self.lbl_bp_val.configure(fg=p["fg_primary"])
        self.lbl_rumen_val.configure(fg=p["fg_primary"])
        self.lbl_chew_val.configure(fg=p["fg_primary"])
        self.lbl_comp_val.configure(fg=p["fg_primary"])

        # Cards
        for card, title_lbl, val_lbl, sub_lbl in self.cards:
            card.configure(bg=p["bg_card"], highlightbackground=p["border_card"])
            title_lbl.configure(bg=p["bg_card"], fg=p["fg_card_title"])
            val_lbl.configure(bg=p["bg_card"], fg=p["fg_accent"])
            sub_lbl.configure(bg=p["bg_card"], fg=p["fg_card_sub"])

        # Text Breakdown Box
        self.txt_breakdown.configure(
            bg=p["bg_text"],
            fg=p["fg_text"],
            insertbackground=p["fg_primary"],
            highlightbackground=p["border_text"],
        )

        # Style TTK widgets (Treeview, Headings)
        style = ttk.Style()
        style.configure(
            "Treeview",
            background=p["bg_table_odd"],
            foreground=p["fg_table"],
            fieldbackground=p["bg_table_odd"],
            rowheight=24,
            font=("Helvetica", 10),
        )
        style.configure(
            "Treeview.Heading",
            background=p["tree_header_bg"],
            foreground=p["tree_header_fg"],
            font=("Helvetica", 10, "bold"),
        )
        style.map(
            "Treeview",
            background=[("selected", p["bg_table_current"])],
            foreground=[("selected", p["fg_table_current"])],
        )

    def _on_theme_changed(self, event: Any) -> None:
        self._apply_theme()
        self._recalculate()

    # --- Event Handlers & Scale Listeners ---

    def _on_bp_scale(self, val: str) -> None:
        lvl = int(float(val))
        self.var_bite_power.set(lvl)
        bonus = get_bite_power_bonus(lvl)
        self.lbl_bp_val.config(text=f"{lvl} (+{bonus})")
        self._recalculate()

    def _on_rumen_scale(self, val: str) -> None:
        lvl = int(float(val))
        self.var_rumen.set(lvl)
        cap, mult = get_rumen_stats(lvl)
        self.lbl_rumen_val.config(text=f"{lvl} (Cap {cap})")
        self.lbl_combo_sub.config(text=f"{mult:.2f}x max")
        self._recalculate()

    def _on_chew_scale(self, val: str) -> None:
        lvl = int(float(val))
        self.var_chew_speed.set(lvl)
        cd = get_chew_cooldown(lvl)
        self.lbl_chew_val.config(text=f"{lvl} ({cd:.2f}s)")
        self._recalculate()

    def _on_companion_scale(self, val: str) -> None:
        bond = float(val)
        mult = get_companion_multiplier(bond)
        label = "None" if bond <= 0 else f"{mult:.4f}x ({int(bond * 100)}%)"
        self.lbl_comp_val.config(text=label)
        self._recalculate()

    def _on_preset_selected(self, event: Any) -> None:
        name = self.var_preset.get()
        if name not in PRESETS:
            return
        p = PRESETS[name]
        self._updating = True
        self.var_rebirth.set(p["rebirth"])
        self.var_zone.set(p["zone"])
        self.var_grass.set(p["grass"])
        self.var_bite_power.set(p["bite_power"])
        self.var_rumen.set(p["rumen"])
        self.var_combo.set(p["combo"])
        self.var_companion.set(p["companion"])
        self.var_chew_speed.set(p["chew_speed"])
        self.var_headwear.set(p.get("headwear", "None"))
        self.var_title.set(p.get("title", "None"))
        self.var_bunnies.set(p.get("bunnies", 0))
        self.var_pillar.set(p.get("pillar", "None"))
        self.var_gamepass.set(p["gamepass"])
        self.var_clover_aura.set(p["clover_aura"])
        self.var_extra_mult.set(p["extra_mult"])

        # Update slider label texts
        bp_b = get_bite_power_bonus(p["bite_power"])
        self.lbl_bp_val.config(text=f"{p['bite_power']} (+{bp_b})")
        r_cap, _ = get_rumen_stats(p["rumen"])
        self.lbl_rumen_val.config(text=f"{p['rumen']} (Cap {r_cap})")
        cd = get_chew_cooldown(p["chew_speed"])
        self.lbl_chew_val.config(text=f"{p['chew_speed']} ({cd:.2f}s)")
        c_mult = get_companion_multiplier(p["companion"])
        self.lbl_comp_val.config(text=f"{c_mult:.4f}x ({int(p['companion'] * 100)}%)")

        self._updating = False
        self._recalculate()

    def _on_tab_changed(self, event: Any) -> None:
        tab_idx = self.notebook.index(self.notebook.select())
        if tab_idx == 1:
            self._update_progression_table()
        elif tab_idx == 2:
            self._update_zones_table()

    # --- Calculation & View Updates ---

    def _recalculate(self) -> None:
        if self._updating:
            return

        r = max(0, self.var_rebirth.get())
        zone = self.var_zone.get()
        grass = self.var_grass.get()
        bp = self.var_bite_power.get()
        rumen = self.var_rumen.get()
        combo = self.var_combo.get()
        comp = self.var_companion.get()
        chew = self.var_chew_speed.get()
        hw = self.var_headwear.get()
        title = self.var_title.get()
        bunnies = max(0, min(5, self.var_bunnies.get()))
        pillar = self.var_pillar.get()
        gp = self.var_gamepass.get()
        clover = self.var_clover_aura.get()
        extra = max(0.1, self.var_extra_mult.get())

        calc = calculate_bite_yield(
            rebirth=r,
            zone=zone,
            grass_type=grass,
            bite_power_level=bp,
            rumen_level=rumen,
            combo_mode=combo,
            companion_bond=comp,
            chew_speed_level=chew,
            headwear=hw,
            title=title,
            back_bunnies=bunnies,
            pillar=pillar,
            gamepass_2x=gp,
            lucky_clover_level=clover,
            other_multiplier=extra,
        )

        # Update gear hints
        hw_b = HEADWEAR_BONUSES.get(hw, HEADWEAR_BONUSES["None"])["Bonus"]
        self.lbl_hw_hint.config(text=f"+{hw_b} Base Cal")
        t_mult = TITLES.get(title, TITLES["None"])["Multiplier"]
        self.lbl_title_hint.config(text=f"{t_mult:.2f}× (+{(t_mult-1)*100:.0f}%)")
        self.lbl_bunnies_hint.config(text=f"(+{bunnies}% Cal)")
        p_bonus = PILLARS.get(pillar, PILLARS["None"])["Bonus"]
        self.lbl_pillar_hint.config(text=f"+{p_bonus*100:.0f}% Cal")

        # Update Rebirth Sub-label
        self.lbl_rebirth_sub.config(
            text=f"Multiplier: {calc.rebirth_multiplier:,.4f}× | Next Req: {calc.next_rebirth_requirement:,} Cal"
        )
        z_info = ZONES[zone]
        self.lbl_zone_sub.config(
            text=f"Category: {z_info['Category']} | Base: {z_info['BaseValue']} | Golden: {z_info['GoldenChance']*100:.2f}%"
        )

        # Update Highlight Cards
        _, _, card0_val, card0_sub = self.cards[0]
        card0_val.config(text=f"{calc.rebirth_multiplier:,.4f}×")
        pct_increase = (calc.rebirth_multiplier - 1.0) * 100
        card0_sub.config(text=f"+{pct_increase:,.1f}% vs Rebirth 0")

        _, _, card1_val, card1_sub = self.cards[1]
        card1_val.config(text=f"{calc.avg_bite_calories:,.1f} Cal")
        card1_sub.config(text=f"{calc.min_bite_calories:,} min – {calc.max_bite_calories:,} max")

        _, _, card2_val, card2_sub = self.cards[2]
        card2_val.config(text=f"{calc.calories_per_second:,.1f} /s")
        hr_rate = calc.calories_per_second * 3600
        hr_str = f"{hr_rate / 1e6:,.2f}M /hr" if hr_rate >= 1e6 else f"{hr_rate:,.0f} /hr"
        card2_sub.config(text=f"{hr_str} ({calc.chew_cooldown:.2f}s/bite)")

        _, _, card3_val, card3_sub = self.cards[3]
        mins = calc.expected_seconds_to_rebirth / 60.0
        time_str = f"{mins:,.1f} min" if mins < 120 else f"{mins / 60:,.1f} hrs"
        card3_val.config(text=f"{calc.expected_bites_to_rebirth:,.0f} bites")
        card3_sub.config(text=f"Req {calc.next_rebirth_requirement:,} ({time_str})")

        # Update Tab 1 (Breakdown Text)
        self._update_breakdown_text(calc)

        # Update currently active tab if it's Table or Zones
        current_tab = self.notebook.index(self.notebook.select())
        if current_tab == 1:
            self._update_progression_table()
        elif current_tab == 2:
            self._update_zones_table()

    def _update_breakdown_text(self, calc: BiteCalculation) -> None:
        self.txt_breakdown.delete("1.0", tk.END)

        text = (
            f"=== BITE CALORIE CALCULATION BREAKDOWN (REBIRTH {calc.rebirth}) ===\n\n"
            f"1. BASE CALORIES COMPOSITION:\n"
            f"   • Zone Base ({calc.zone}):             {calc.zone_base:6.1f} Cal\n"
            f"   • Grass Seed Bonus ({calc.grass_type}):        +{calc.grass_bonus:5.1f} Cal\n"
            f"   • Bite Power Upgrade (Lvl {calc.bite_power_level:02d}/25):     +{calc.bite_power_bonus:5.1f} Cal  [formula: L*(L+3)/2]\n"
            f"   • Headwear Hat Bonus ({calc.headwear}):        +{calc.headwear_bonus:5.1f} Cal  [MiningHatConfig.Benefits]\n"
            f"   • Expected Secondary Spawns:          +{calc.expected_secondary_bonus:5.2f} Cal  (Rate: {ZONES[calc.zone]['SecondaryRate']*100:.0f}%, Kind: {ZONES[calc.zone]['SecondaryKind'] or 'None'})\n"
            f"   ----------------------------------------------------\n"
            f"   = Effective Base Calories:            {calc.effective_base_calories:6.2f} Cal\n\n"
            f"2. MULTIPLIERS APPLIED (GrassEconomy.luau):\n"
            f"   • Rebirth Multiplier (1.22^{calc.rebirth}):           {calc.rebirth_multiplier:7.4f}×\n"
            f"   • Node Quality Multiplier:            {calc.expected_node_multiplier:7.4f}×  (Golden chance: {calc.golden_chance*100:.2f}%)\n"
            f"   • Rumen Combo ({calc.combo_stacks} stacks @ +2%):        {calc.rumen_multiplier:7.2f}×  (Combo cap: {get_rumen_stats(calc.rumen_level)[0]})\n"
            f"   • Companion Multiplier (Bond {calc.companion_bond:.2f}):      {calc.companion_multiplier:7.4f}×  (clamp(1 + bond*0.15, 1, 1.15))\n"
            f"   • Title Buff ({calc.title}):             {calc.title_multiplier:7.4f}×  (Title_CloverMarbles +3% Cal)\n"
            f"   • Back Friends ({calc.back_bunnies} Back Bunnies):       {calc.back_bunnies_multiplier:7.4f}×  (+1% per bunny on back)\n"
            f"   • Pillar Buff ({calc.pillar}):             {calc.pillar_multiplier:7.4f}×  (Grazer Pillar +10% grass Cal)\n"
            f"   • Gamepass / Extra Multipliers:       {2.0 if calc.gamepass_2x else 1.0:7.2f}×  (2x Gamepass: {calc.gamepass_2x})\n"
            f"   ----------------------------------------------------\n"
            f"   = Combined Total Multiplier:          {calc.total_multiplier:7.4f}×\n\n"
            f"3. CALORIE YIELD & PROGRESSION SUMMARY:\n"
            f"   ★ AVERAGE BITE YIELD:                 {calc.avg_bite_calories:,.1f} Calories / bite\n"
            f"   • Minimum Plain Bite (zero sec):      {calc.min_bite_calories:,} Calories\n"
            f"   • Maximum Golden Bite (max sec):      {calc.max_bite_calories:,} Calories\n"
            f"   • Chew Cooldown (Chew Speed {calc.chew_speed_level:02d}):     {calc.chew_cooldown:.2f} seconds\n"
            f"   • Calorie Income Rate:                {calc.calories_per_second:,.1f} Cal/sec ({calc.calories_per_second * 3600:,.0f} Cal/hr)\n"
            f"   • Next Rebirth Requirement (R{calc.rebirth}→R{calc.rebirth+1}): {calc.next_rebirth_requirement:,} Calories\n"
            f"   • Bites Needed to Next Rebirth:       {calc.expected_bites_to_rebirth:,.0f} bites\n"
            f"   • Estimated Time to Next Rebirth:     {calc.expected_seconds_to_rebirth / 60:.1f} minutes ({calc.expected_seconds_to_rebirth:,.0f} seconds)\n"
            f"   • Cumulative Calories up to R{calc.rebirth}:     {get_cumulative_rebirth_calories(calc.rebirth):,} Calories\n"
        )
        self.txt_breakdown.insert(tk.END, text)

    def _update_progression_table(self) -> None:
        p = self._get_current_palette()
        for item in self.tree_prog.get_children():
            self.tree_prog.delete(item)

        zone = self.var_zone.get()
        grass = self.var_grass.get()
        bp = self.var_bite_power.get()
        rumen = self.var_rumen.get()
        combo = self.var_combo.get()
        comp = self.var_companion.get()
        chew = self.var_chew_speed.get()
        hw = self.var_headwear.get()
        title = self.var_title.get()
        bunnies = max(0, min(5, self.var_bunnies.get()))
        pillar = self.var_pillar.get()
        gp = self.var_gamepass.get()
        clover = self.var_clover_aura.get()
        extra = self.var_extra_mult.get()
        current_r = self.var_rebirth.get()

        for r in range(21):
            c = calculate_bite_yield(
                rebirth=r,
                zone=zone,
                grass_type=grass,
                bite_power_level=bp,
                rumen_level=rumen,
                combo_mode=combo,
                companion_bond=comp,
                chew_speed_level=chew,
                headwear=hw,
                title=title,
                back_bunnies=bunnies,
                pillar=pillar,
                gamepass_2x=gp,
                lucky_clover_level=clover,
                other_multiplier=extra,
            )
            mins = c.expected_seconds_to_rebirth / 60.0
            time_str = f"{mins:,.1f} min" if mins < 120 else f"{mins / 60:,.1f} hrs"
            tag = "current" if r == current_r else ("even" if r % 2 == 0 else "odd")

            self.tree_prog.insert(
                "",
                tk.END,
                values=(
                    f"R{r}" + (" (Current)" if r == current_r else ""),
                    f"{c.rebirth_multiplier:.4f}×",
                    f"{c.next_rebirth_requirement:,}",
                    f"{c.avg_bite_calories:,.1f}",
                    f"{c.calories_per_second:,.1f}",
                    f"{c.expected_bites_to_rebirth:,.0f}",
                    time_str,
                ),
                tags=(tag,),
            )

        self.tree_prog.tag_configure("current", background=p["bg_table_current"], foreground=p["fg_table_current"])
        self.tree_prog.tag_configure("even", background=p["bg_table_even"], foreground=p["fg_table"])
        self.tree_prog.tag_configure("odd", background=p["bg_table_odd"], foreground=p["fg_table"])

    def _update_zones_table(self) -> None:
        p = self._get_current_palette()
        for item in self.tree_zones.get_children():
            self.tree_zones.delete(item)

        r = self.var_rebirth.get()
        grass = self.var_grass.get()
        bp = self.var_bite_power.get()
        rumen = self.var_rumen.get()
        combo = self.var_combo.get()
        comp = self.var_companion.get()
        chew = self.var_chew_speed.get()
        hw = self.var_headwear.get()
        title = self.var_title.get()
        bunnies = max(0, min(5, self.var_bunnies.get()))
        pillar = self.var_pillar.get()
        gp = self.var_gamepass.get()
        clover = self.var_clover_aura.get()
        extra = self.var_extra_mult.get()
        current_zone = self.var_zone.get()

        for z_name, z_info in ZONES.items():
            c = calculate_bite_yield(
                rebirth=r,
                zone=z_name,
                grass_type=grass,
                bite_power_level=bp,
                rumen_level=rumen,
                combo_mode=combo,
                companion_bond=comp,
                chew_speed_level=chew,
                headwear=hw,
                title=title,
                back_bunnies=bunnies,
                pillar=pillar,
                gamepass_2x=gp,
                lucky_clover_level=clover,
                other_multiplier=extra,
            )
            unlocked = "Unlocked" if r >= z_info["MinRebirth"] else f"Req R{z_info['MinRebirth']}"
            tag = "current" if z_name == current_zone else ("even" if list(ZONES.keys()).index(z_name) % 2 == 0 else "odd")

            self.tree_zones.insert(
                "",
                tk.END,
                values=(
                    z_name + (" (Selected)" if z_name == current_zone else ""),
                    z_info["Category"],
                    f"{c.effective_base_calories:.1f}",
                    f"{z_info['GoldenChance'] * 100:.2f}%",
                    f"{c.avg_bite_calories:,.1f}",
                    f"{c.calories_per_second:,.1f}",
                    f"{c.expected_bites_to_rebirth:,.0f}",
                    unlocked,
                ),
                tags=(tag,),
            )

        self.tree_zones.tag_configure("current", background=p["bg_table_current"], foreground=p["fg_table_current"])
        self.tree_zones.tag_configure("even", background=p["bg_table_even"], foreground=p["fg_table"])
        self.tree_zones.tag_configure("odd", background=p["bg_table_odd"], foreground=p["fg_table"])


def main() -> None:
    root = tk.Tk()
    app = GrassCalorieGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
