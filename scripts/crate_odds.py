#!/usr/bin/env python3
"""Barebones crate / team chest odds calculator (tkinter GUI).

Mirrors the decompiled Cow Game modules (Opiumware workspace dumps):
  LuckRules.Weights             luck boost for R/SR/M, funded by Common/Uncommon above OrdinaryFloor,
                                then by lower boosted tiers
  CollectionLuckRules.Weights   pity demand = base weight * (mult - 1), funded by owned items
                                (each keeps RepeatFloor = 10%)
  CaravanRules.SkinWeights      crates: passes { SuperRare = 6, Rare = 1.5 if Halloween else 1 }
  TeamChestLoot.HatChance       chests: tier hat weights, pity family = whole hat collection,
                                module default caps (SR 3, Rare 1.5), times RareChance
"""
import tkinter as tk

TIERS = ["Common", "Uncommon", "Rare", "Super Rare", "Mythic"]
RANK = {t: i for i, t in enumerate(TIERS)}
LUCK_CAPS = {"Mythic": 2.0, "Super Rare": 1.5, "Rare": 1.25}  # LuckRules.Caps
LUCK_FUNDERS = {"Mythic": ["Rare", "Super Rare"], "Super Rare": ["Rare"], "Rare": []}
COMPLETED = {"Mythic": 4.0, "Super Rare": 1.5}  # CollectionLuckRules.Completed
ORDINARY_FLOOR = 0.1
REPEAT_FLOOR = 0.1

# Crate presets: tier -> (count, per-skin weight), plus Rare pity cap
PRESETS = {
    "Halloween": ({"Common": (11, 0.07906363636363636), "Rare": (4, 0.03),
                   "Super Rare": (2, 0.005), "Mythic": (1, 0.0003)}, 1.5),
    "Caravan": ({"Rare": (10, 0.09847), "Super Rare": (3, 0.005), "Mythic": (1, 0.0003)}, 1.0),
}

# TeamChestLoot. Mining: weight per rarity, split evenly over that rarity's hats (MiningHatConfig.ByRarity).
MINING_HATS = {
    "Common": ["CopperHardHat", "PigIronHardHat", "CrazyCoalCap", "GoggleCap", "BeetlePot", "TinPotHat",
               "LuckyOreSack"],
    "Uncommon": ["ForemooLampHat", "DynamooteHat", "SparePickCap", "FirePitCap", "OreSamplerCap",
                 "PackedLunchHat", "CandleSack"],
    "Rare": ["BandedIronPotHelm", "MoonstoneHardHat", "SteelYourselfCap", "SackOfCrazyCoal", "BeetleManiaHelm"],
    "Super Rare": ["TinyMine", "CanaryCageHat", "AnvilHat"],
}
MINING_WEIGHTS = [
    {"Common": 70, "Uncommon": 30},
    {"Common": 50, "Uncommon": 45, "Rare": 4, "Super Rare": 1},
    {"Common": 30, "Uncommon": 60, "Rare": 8, "Super Rare": 2},
    {"Common": 5, "Uncommon": 75, "Rare": 16, "Super Rare": 4},
]
# Viking: weight per hat (VikingHatConfig.ChestHats)
VIKING_HATS = {
    "Uncommon": ["LonghornHelm", "RaidersKeg"],
    "Rare": ["HayManeCap", "TinyLongship"],
    "Super Rare": ["FenrirCowl", "CoalBerserker", "HuginnMooninn", "ValkyMoorieWings"],
}
VIKING_WEIGHTS = [
    {"LonghornHelm": 60, "RaidersKeg": 40},
    {"LonghornHelm": 30, "RaidersKeg": 30, "HayManeCap": 20, "TinyLongship": 20},
    {"LonghornHelm": 15, "RaidersKeg": 15, "HayManeCap": 25, "TinyLongship": 25, "FenrirCowl": 10,
     "CoalBerserker": 10},
    {"LonghornHelm": 5, "RaidersKeg": 5, "HayManeCap": 20, "TinyLongship": 20, "FenrirCowl": 15,
     "CoalBerserker": 15, "HuginnMooninn": 10, "ValkyMoorieWings": 10},
]
CHESTS = {
    "Team Chest – Cave": {"zone": "Cave", "rare_chance": 0.3, "hats": MINING_HATS},
    "Team Chest – Clearing": {"zone": "Clearing", "rare_chance": 0.07, "hats": VIKING_HATS},
}
CHEST_CAPS = (3.0, 1.5)  # CollectionLuckRules.Multiplier defaults; HatWeights passes no caps
SECRET_SKIN = ("NoobCoat", 0.2, 1)  # TeamChestLoot.SecretSkin: Id, Chance, Level

NO_PRESET = "No preset"
BORDER = "#444"
ERROR_FG = "#e53935"  # mid red: readable on light and dark backgrounds


def chest_items(name, level):
    """TeamChestLoot.HatWeights list for one chest tier: [(id, rarity, weight)] in source order."""
    hats = CHESTS[name]["hats"]
    if CHESTS[name]["zone"] == "Cave":
        return [(h, r, w / len(hats[r])) for r, w in MINING_WEIGHTS[level - 1].items() for h in hats[r]]
    rarity = {h: r for r, hs in hats.items() for h in hs}
    return [(h, rarity[h], w) for h, w in VIKING_WEIGHTS[level - 1].items()]


def luck_tier_weights(tier_w, luck, event):
    """LuckRules.Weights at tier level (every item in a tier is scaled by the same ratio)."""
    total = sum(tier_w.values())
    l_norm = max(0.0, min(100.0, luck)) / 100
    target = dict(tier_w)
    gain = 0.0
    for t, cap in LUCK_CAPS.items():
        target[t] = tier_w[t] * min(cap, 1 + (cap - 1) * l_norm) * event
        gain += target[t] - tier_w[t]
    if gain <= 0:
        return dict(tier_w)
    floor = dict.fromkeys(TIERS, 0.0)
    for t in ("Common", "Uncommon"):
        if total * ORDINARY_FLOOR <= tier_w[t] + total * 1e-12:  # a tier already under the floor gets no floor
            floor[t] = min(tier_w[t], total * ORDINARY_FLOOR)
    cur = dict(tier_w)
    for t in LUCK_CAPS:  # Mythic, Super Rare, Rare
        want = max(0.0, target[t] - cur[t])
        dc = max(0.0, cur["Common"] - floor["Common"])
        pool = dc + max(0.0, cur["Uncommon"] - floor["Uncommon"])
        take = min(want, pool)
        if take > 0:
            c = take * dc / pool
            cur["Common"] = max(floor["Common"], cur["Common"] - c)
            cur["Uncommon"] = max(floor["Uncommon"], cur["Uncommon"] - (take - c))
        short = want - take
        for f in LUCK_FUNDERS[t]:
            x = min(short, cur[f])
            cur[f] -= x
            short -= x
        cur[t] += want - short
    return cur


def calc_items(items, family, luck=0.0, event=1.0, k_sr=6.0, k_r=1.5):
    """items: [(id, tier, base weight)] rollable outcomes; family: {id: (tier, owned)} pity collection.
    Returns (f, complete, {tier: (tier %, unowned-in-tier %, avg % per unowned item)})."""
    items = [it for it in items if it[2] > 0]
    if not items:
        return 0.0, False, {}
    tier_w = dict.fromkeys(TIERS, 0.0)
    for _, t, wt in items:
        tier_w[t] += wt
    luck_w = luck_tier_weights(tier_w, luck, event)
    w = [wt * luck_w[t] / tier_w[t] for _, t, wt in items]

    # CollectionLuckRules.Progress over the family
    n_total = len(family)
    earned = sum(own for _, own in family.values())
    complete = n_total > 0 and earned == n_total
    f = earned / (n_total - 1) if n_total > 1 else 0.0
    tier_done = {}
    for t in TIERS:
        members = [own for tt, own in family.values() if tt == t]
        if members:
            tier_done[t] = sum(members) / len(members)

    def owned(i):
        return family.get(i, (None, False))[1]

    def mult(i, t):
        if i not in family:
            return 1.0
        if complete:
            return COMPLETED.get(t, 1.0)
        if owned(i) or n_total <= 1:
            return 1.0
        if t == "Mythic":
            return 100 ** f
        cap = k_sr if t == "Super Rare" else k_r if t == "Rare" else 1.0
        return 1 + max(0.0, cap - 1) * f

    demand = [wt * (mult(i, t) - 1) for i, t, wt in items]  # BASE weight, as in source
    donors = [k for k, (i, _, _) in enumerate(items) if owned(i) and demand[k] == 0 and w[k] > 0]
    need, capacity = sum(demand), sum(w[k] for k in donors) * (1 - REPEAT_FLOOR)
    if need > 0 and capacity > 0:
        # Completion desc, then Copies desc (1 each here), then Rank asc, then Id
        donors.sort(key=lambda k: (-tier_done[items[k][1]], RANK[items[k][1]], items[k][0]))
        left = moved = min(need, capacity)
        for k in donors:
            x = min(left, w[k] * (1 - REPEAT_FLOOR))
            w[k] -= x
            left -= x
            if left <= 0:
                break
        ratio = (moved - left) / need
        w = [x + d * ratio for x, d in zip(w, demand)]

    total = sum(w)
    out = {}
    for t in TIERS:
        ws = [(x, owned(i)) for x, (i, tt, _) in zip(w, items) if tt == t]
        if ws:
            new = sum(x for x, own in ws if not own) / total * 100
            unowned = sum(not own for _, own in ws)
            out[t] = (sum(x for x, _ in ws) / total * 100, new, new / unowned if unowned else 0.0)
    return f, complete, out


def calc(counts, owned, weights, luck=0.0, event=1.0, k_sr=6.0, k_r=1.5):
    """Crate wrapper: N identical skins per tier; the crate itself is the pity family."""
    items, family = [], {}
    for t in TIERS:
        if weights[t] > 0:  # skins with weight <= 0 are skipped by CollectionLuckRules.Progress
            for i in range(counts[t]):
                sid = f"{t} {i + 1:02d}"
                items.append((sid, t, weights[t]))
                family[sid] = (t, i < owned[t])
    return calc_items(items, family, luck, event, k_sr, k_r)


def pity_text(f, complete, tiers, k_sr, k_r):
    if complete:
        return "complete: " + ", ".join(f"{t} x{COMPLETED[t]:g}" for t in ("Mythic", "Super Rare") if t in tiers)
    parts = []
    if "Mythic" in tiers:
        parts.append(f"Mythic pity x{100 ** f:.2f}")
    if "Super Rare" in tiers:
        parts.append(f"SR x{1 + max(0.0, k_sr - 1) * f:.2f}")
    if "Rare" in tiers:
        parts.append(f"R x{1 + max(0.0, k_r - 1) * f:.2f}")
    return "  ".join(parts)


def main():
    root = tk.Tk()
    root.title("Crate Odds")
    for col, h in enumerate(["Tier", "In crate", "Owned", "Item weight"]):
        tk.Label(root, text=h, font=("", 0, "bold")).grid(row=1, column=col, padx=6, pady=4)

    def entry(row, col, val, width=8):
        e = tk.Entry(root, width=width, relief="flat",
                     highlightthickness=2, highlightbackground=BORDER, highlightcolor=BORDER)
        e.insert(0, str(val))
        e.grid(row=row, column=col, padx=4, pady=1)
        return e

    def bordered(widget, *args, **kw):
        """Wrap a button/dropdown in a 4px frame (macOS Aqua ignores relief/bd on buttons). Returns the frame."""
        frame = tk.Frame(root, highlightbackground=BORDER, highlightcolor=BORDER, highlightthickness=4, bd=0)
        widget(frame, *args, **kw).pack()
        return frame

    def put(e, val):
        state = e.cget("state")
        e.config(state="normal")
        e.delete(0, tk.END)
        e.insert(0, str(val))
        e.config(state=state)

    def lock(fields, locked):
        for e in fields:
            e.config(state="readonly" if locked else "normal")

    rows = {}
    for r, t in enumerate(TIERS, 2):
        tk.Label(root, text=t).grid(row=r, column=0, sticky="w", padx=6)
        rows[t] = (entry(r, 1, 0, 6), entry(r, 2, 0, 6), entry(r, 3, 0, 20))

    mods = {}
    for i, (key, label, val) in enumerate([("luck", "Luck (0-100)", 0), ("event", "Event x (1-2)", 1.0),
                                           ("k_sr", "SR pity cap", 6.0), ("k_r", "Rare pity cap", 1.5)]):
        r = len(TIERS) + 2 + i // 2
        tk.Label(root, text=label).grid(row=r, column=(i % 2) * 2, sticky="e", padx=6)
        mods[key] = entry(r, (i % 2) * 2 + 1, val, 6)

    # chest-only widgets: tier field + owned-hat checkboxes
    level_label = tk.Label(root, text="Chest tier (zone 1-4)")
    level_entry = entry(len(TIERS) + 4, 1, 1, 6)
    hats_frame = tk.LabelFrame(root, text="Hats owned")
    hat_vars = {}

    crate_fields = [e for t in TIERS for e in (rows[t][0], rows[t][2])] + [mods["k_sr"], mods["k_r"]]
    owned_fields = [rows[t][1] for t in TIERS]
    preset = tk.StringVar(value=next(iter(PRESETS)))

    def chest_level():
        lv = int(level_entry.get() or 0)
        if not 1 <= lv <= 4:
            raise ValueError("chest tier must be 1-4")
        return lv

    def refresh_chest(*_):
        """Fill counts/owned/weights from the chest tables and the ticked hats."""
        name = preset.get()
        if name not in CHESTS:
            return
        hats = CHESTS[name]["hats"]
        try:
            per_hat = {h: w for h, _, w in chest_items(name, chest_level())}
        except ValueError:
            per_hat = {}
        for t in TIERS:
            ids = hats.get(t, [])
            put(rows[t][0], len(ids))
            put(rows[t][1], sum(hat_vars[h].get() for h in ids))
            ws = sorted({round(per_hat.get(h, 0), 4) for h in ids}, reverse=True)
            put(rows[t][2], "/".join(f"{x:g}" for x in ws) if ids else 0)

    def load(name):
        lock(crate_fields + owned_fields, False)
        level_label.grid_remove()
        level_entry.grid_remove()
        hats_frame.grid_remove()
        if name == NO_PRESET:
            return
        for e in owned_fields:  # owned counts belong to the previous crate/chest
            put(e, 0)
        if name in CHESTS:
            for child in hats_frame.winfo_children():
                child.destroy()
            hat_vars.clear()
            ids = [h for t in TIERS for h in CHESTS[name]["hats"].get(t, [])]
            for k, h in enumerate(ids):
                hat_vars[h] = tk.BooleanVar(value=False)
                tk.Checkbutton(hats_frame, text=h, variable=hat_vars[h], command=refresh_chest).grid(
                    row=k // 3, column=k % 3, sticky="w", padx=2)
            put(mods["k_sr"], CHEST_CAPS[0])
            put(mods["k_r"], CHEST_CAPS[1])
            level_label.grid(row=len(TIERS) + 4, column=0, sticky="e", padx=6)
            level_entry.grid()
            hats_frame.grid(row=len(TIERS) + 5, column=0, columnspan=4, padx=6, pady=4, sticky="we")
            refresh_chest()
            lock(crate_fields + owned_fields, True)
            return
        tiers, k_r = PRESETS[name]
        for t in TIERS:
            n, wt = tiers.get(t, (0, 0))
            put(rows[t][0], n)
            put(rows[t][2], wt)
        put(mods["k_sr"], 6.0)
        put(mods["k_r"], k_r)
        lock(crate_fields, True)

    level_entry.bind("<KeyRelease>", refresh_chest)

    tk.Label(root, text="Preset").grid(row=0, column=0, sticky="w", padx=6, pady=4)
    bordered(tk.OptionMenu, preset, *PRESETS, *CHESTS, NO_PRESET, command=load).grid(
        row=0, column=1, columnspan=3, sticky="w", pady=4)

    out = tk.Label(root, font=("Courier", 12), justify="left", anchor="w")
    out.grid(row=len(TIERS) + 7, column=0, columnspan=4, padx=6, pady=6, sticky="w")
    text_fg = out.cget("fg")  # theme's own text colour (e.g. systemTextColor on macOS), follows light/dark

    def run(*_):
        name = preset.get()
        try:
            m = {k: float(e.get() or 0) for k, e in mods.items()}
            m["event"] = max(1.0, min(2.0, m["event"]))  # LuckRules clamps event to 1-2
            args = (m["luck"], m["event"], m["k_sr"], m["k_r"])
            if name in CHESTS:
                level = chest_level()
                chest = CHESTS[name]
                family = {h: (t, hat_vars[h].get()) for t, hs in chest["hats"].items() for h in hs}
                items = [(h, t, w) for h, t, w in chest_items(name, level)]
                f, complete, res = calc_items(items, family, *args)
                scale = chest["rare_chance"]
                o, n = sum(own for _, own in family.values()), len(family)
                tiers = {t for t, _ in family.values()}
                head = [f"Hat drops in {scale:.0%} of {chest['zone']} chests (tier {level}); % are per chest"]
            else:
                counts = {t: int(rows[t][0].get() or 0) for t in TIERS}
                owned = {t: int(rows[t][1].get() or 0) for t in TIERS}
                weights = {t: float(rows[t][2].get() or 0) for t in TIERS}
                if any(v < 0 for v in [*counts.values(), *owned.values(), *weights.values()]):
                    raise ValueError("negative value")
                bad = [t for t in TIERS if owned[t] > counts[t]]
                if bad:
                    raise ValueError(f"owned > in crate: {', '.join(bad)}")
                f, complete, res = calc(counts, owned, weights, *args)
                scale = 1.0
                n = sum(counts[t] for t in res)
                o = sum(owned[t] for t in res)
                tiers = set(res)
                head = []
            if not res:
                raise ValueError("nothing to roll")
        except ValueError as e:
            out.config(text=f"Error: {e}", fg=ERROR_FG)
            return
        lines = head + [f"Owned {o}/{n}   f={f:.3f}   {pity_text(f, complete, tiers, m['k_sr'], m['k_r'])}", "",
                        f"{'Tier':<11}{'Tier %':>9}{'New %':>9}{'Per new %':>11}{'1 in':>9}"]
        new = 0.0
        for t, (tp, np, per) in res.items():
            tp, np, per = tp * scale, np * scale, per * scale
            new += np
            lines.append(f"{t:<11}{tp:>9.4f}{np:>9.4f}{per:>11.4f}{(100 / tp if tp else 0):>9.1f}")
        lines += ["", f"New item per open: {new:.4f}%" + (f" (1 in {100 / new:.1f})" if new else "")]
        if name in CHESTS and level == SECRET_SKIN[2]:
            lines.append(f"tier {level}: secret {SECRET_SKIN[0]} roll {SECRET_SKIN[1]:.0%} (trigger not in dumps)")
        if name not in CHESTS:
            total_w = sum(counts[t] * weights[t] for t in res)
            if abs(total_w - 1) > 1e-6:
                lines.append(f"note: weights sum to {total_w:.4f}, not 1 (shown normalized)")
        out.config(text="\n".join(lines), fg=text_fg)

    bordered(tk.Button, text="Calculate", command=run).grid(row=len(TIERS) + 6, column=0, columnspan=4, pady=4)
    root.bind("<Return>", run)
    load(preset.get())
    root.mainloop()


if __name__ == "__main__":
    main()
