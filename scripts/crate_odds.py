#!/usr/bin/env python3
"""Barebones crate skin odds calculator (tkinter GUI).

Mirrors the decompiled Cow Game modules (Opiumware workspace dumps):
  LuckRules.Weights             luck boost for R/SR/M, funded by Common/Uncommon above OrdinaryFloor,
                                then by lower boosted tiers
  CollectionLuckRules.Weights   pity demand = base weight * (mult - 1), funded by owned skins
                                (each keeps RepeatFloor = 10%)
  CaravanRules.SkinWeights      passes { SuperRare = 6, Rare = 1.5 if Halloween else 1 }
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
NO_PRESET = "No preset"
BORDER = "#444"
ERROR_FG = "#e53935"  # mid red: readable on light and dark backgrounds


def luck_tier_weights(tier_w, luck, event):
    """LuckRules.Weights at tier level (every skin in a tier is scaled by the same ratio)."""
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


def calc(counts, owned, weights, luck=0.0, event=1.0, k_sr=6.0, k_r=1.5):
    """Returns (f, complete, {tier: (tier %, unowned-in-tier %, per unowned skin %)})."""
    # skins with weight <= 0 are skipped by CollectionLuckRules.Progress
    items = [(t, i < owned[t]) for t in TIERS if weights[t] > 0 for i in range(counts[t])]
    if not items:
        return 0.0, False, {}
    tier_w = {t: counts[t] * weights[t] if weights[t] > 0 else 0.0 for t in TIERS}
    luck_w = luck_tier_weights(tier_w, luck, event)
    w = [weights[t] * luck_w[t] / tier_w[t] for t, _ in items]

    n_total, earned = len(items), sum(own for _, own in items)
    complete = earned == n_total
    f = earned / (n_total - 1) if n_total > 1 else 0.0

    def mult(t, own):
        if complete:
            return COMPLETED.get(t, 1.0)
        if own or n_total <= 1:
            return 1.0
        if t == "Mythic":
            return 100 ** f
        cap = k_sr if t == "Super Rare" else k_r if t == "Rare" else 1.0
        return 1 + max(0.0, cap - 1) * f

    demand = [weights[t] * (mult(t, own) - 1) for t, own in items]  # uses BASE weight, as in source
    donors = [k for k, (_, own) in enumerate(items) if own and demand[k] == 0 and w[k] > 0]
    need, capacity = sum(demand), sum(w[k] for k in donors) * (1 - REPEAT_FLOOR)
    if need > 0 and capacity > 0:
        # Completion desc, then Copies desc (1 each here), then Rank asc (Common first)
        donors.sort(key=lambda k: (-owned[items[k][0]] / counts[items[k][0]], RANK[items[k][0]]))
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
        ws = [(x, own) for x, (tt, own) in zip(w, items) if tt == t]
        if ws:
            new = sum(x for x, own in ws if not own) / total * 100
            unowned = sum(not own for _, own in ws)
            out[t] = (sum(x for x, _ in ws) / total * 100, new, new / unowned if unowned else 0.0)
    return f, complete, out


def main():
    root = tk.Tk()
    root.title("Crate Odds")
    for col, h in enumerate(["Tier", "In crate", "Owned", "Skin weight"]):
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
        e.delete(0, tk.END)
        e.insert(0, str(val))

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

    # fields that define the crate: locked while a preset is chosen
    crate_fields = [e for t in TIERS for e in (rows[t][0], rows[t][2])] + [mods["k_sr"], mods["k_r"]]

    def load(name):
        for e in crate_fields:
            e.config(state="normal")
        if name == NO_PRESET:
            return
        tiers, k_r = PRESETS[name]
        for t in TIERS:
            n, wt = tiers.get(t, (0, 0))
            put(rows[t][0], n)
            put(rows[t][2], wt)
        put(mods["k_sr"], 6.0)
        put(mods["k_r"], k_r)
        for e in crate_fields:
            e.config(state="readonly")

    tk.Label(root, text="Crate preset").grid(row=0, column=0, sticky="w", padx=6, pady=4)
    preset = tk.StringVar(value=next(iter(PRESETS)))
    bordered(tk.OptionMenu, preset, *PRESETS, NO_PRESET, command=load).grid(
        row=0, column=1, columnspan=3, sticky="w", pady=4)
    load(preset.get())

    out = tk.Label(root, font=("Courier", 12), justify="left", anchor="w")
    text_fg = out.cget("fg")  # theme's own text colour (e.g. systemTextColor on macOS), follows light/dark
    out.grid(row=len(TIERS) + 5, column=0, columnspan=4, padx=6, pady=6, sticky="w")

    def run(*_):
        try:
            counts = {t: int(rows[t][0].get() or 0) for t in TIERS}
            owned = {t: int(rows[t][1].get() or 0) for t in TIERS}
            weights = {t: float(rows[t][2].get() or 0) for t in TIERS}
            m = {k: float(e.get() or 0) for k, e in mods.items()}
            if any(v < 0 for v in [*counts.values(), *owned.values(), *weights.values()]):
                raise ValueError("negative value")
            bad = [t for t in TIERS if owned[t] > counts[t]]
            if bad:
                raise ValueError(f"owned > in crate: {', '.join(bad)}")
            m["event"] = max(1.0, min(2.0, m["event"]))  # LuckRules clamps event to 1-2
            f, complete, res = calc(counts, owned, weights, m["luck"], m["event"], m["k_sr"], m["k_r"])
            if not res:
                raise ValueError("crate has no weighted skins")
        except ValueError as e:
            out.config(text=f"Error: {e}", fg=ERROR_FG)
            return
        n = sum(counts[t] for t in res)
        o = sum(owned[t] for t in res)
        pity = "complete: M x4, SR x1.5" if complete else f"Mythic pity x{100 ** f:.2f}"
        lines = [f"Owned {o}/{n}   f={f:.3f}   {pity}", "",
                 f"{'Tier':<11}{'Tier %':>9}{'New %':>9}{'Per new %':>11}{'1 in':>9}"]
        for t, (tp, np, per) in res.items():
            lines.append(f"{t:<11}{tp:>9.4f}{np:>9.4f}{per:>11.4f}{(100 / tp if tp else 0):>9.1f}")
        new = sum(np for _, np, _ in res.values())
        lines += ["", f"New skin per open: {new:.4f}%" + (f" (1 in {100 / new:.1f})" if new else "")]
        total_w = sum(counts[t] * weights[t] for t in res)
        if abs(total_w - 1) > 1e-6:
            lines.append(f"note: weights sum to {total_w:.4f}, not 1 (shown normalized)")
        out.config(text="\n".join(lines), fg=text_fg)

    bordered(tk.Button, text="Calculate", command=run).grid(row=len(TIERS) + 4, column=0, columnspan=4, pady=4)
    root.bind("<Return>", run)
    root.mainloop()


if __name__ == "__main__":
    main()
