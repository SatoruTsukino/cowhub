#!/usr/bin/env python3
"""Barebones crate skin odds calculator (tkinter GUI).

Implements CRATE_RARITY_CALCULATOR_SPEC.md:
  1. Base per-item weights (HalloweenConfig.CrateSkins)
  2. LuckRules.Weights: R/SR/M boost, drained from Common/Uncommon down to OrdinaryFloor
  3. CollectionLuckRules: unowned pity multipliers, Completed exception
  4. Owned items surrender up to 90% of weight (RepeatFloor) to fund unowned demand
"""
import tkinter as tk

TIERS = ["Common", "Uncommon", "Rare", "Super Rare", "Mythic"]
BASE_W = {"Common": 0.07906363636363636, "Uncommon": 0.04, "Rare": 0.03,
          "Super Rare": 0.005, "Mythic": 0.0003}
LUCK_CAPS = {"Rare": 1.25, "Super Rare": 1.50, "Mythic": 2.00}
COMPLETED = {"Mythic": 4.0, "Super Rare": 1.5}
ORDINARY_FLOOR = 0.10
REPEAT_FLOOR = 0.10


def calc(counts, owned, weights, luck=0.0, event=1.0, k_sr=6.0, k_r=1.5):
    """Returns (pity f, {tier: (tier %, unowned-in-tier %, per unowned skin %)})."""
    items = [(t, i < owned[t]) for t in TIERS for i in range(counts[t])]  # (tier, owned)
    n_total, o_total = len(items), sum(owned.values())
    if not items:
        return 0.0, {}

    # Step 1-2: base tier weights + LuckRules
    tier_w = {t: counts[t] * weights[t] for t in TIERS}
    w_base = sum(tier_w.values())
    boosted = dict(tier_w)
    l_norm = max(0.0, min(100.0, luck)) / 100
    delta = 0.0
    for t, cap in LUCK_CAPS.items():
        boosted[t] = tier_w[t] * min(cap, 1 + (cap - 1) * l_norm) * event
        delta += boosted[t] - tier_w[t]
    floor = ORDINARY_FLOOR * w_base
    dr = {t: max(0.0, tier_w[t] - floor) for t in ("Common", "Uncommon")}
    pool = sum(dr.values())
    if pool > 0:
        drain = min(delta, pool)
        for t in dr:
            boosted[t] -= drain * dr[t] / pool
    w = [weights[t] * boosted[t] / tier_w[t] if tier_w[t] else 0.0 for t, _ in items]

    # Step 3-4: CollectionLuckRules
    f = o_total / (n_total - 1) if n_total > 1 else 0.0
    if o_total == n_total:
        w = [x * COMPLETED.get(t, 1.0) for x, (t, _) in zip(w, items)]
    else:
        def mult(t):
            return {"Mythic": 100 ** f, "Super Rare": 1 + (k_sr - 1) * f,
                    "Rare": 1 + (k_r - 1) * f}.get(t, 1.0)
        demand = [0.0 if own else x * (mult(t) - 1) for x, (t, own) in zip(w, items)]
        total_demand = sum(demand)
        capacity = sum((1 - REPEAT_FLOOR) * x for x, (_, own) in zip(w, items) if own)
        transfer = min(total_demand, capacity)
        ratio = transfer / total_demand if total_demand > 0 else 0.0
        # drain owned items: tier completion desc (copies are 1 each, so no second key)
        order = sorted((k for k, (_, own) in enumerate(items) if own),
                       key=lambda k: -owned[items[k][0]] / counts[items[k][0]])
        for k in order:
            take = min(transfer, (1 - REPEAT_FLOOR) * w[k])
            w[k] -= take
            transfer -= take
            if transfer <= 0:
                break
        w = [x + d * ratio for x, d in zip(w, demand)]

    # Step 5: probabilities
    total = sum(w)
    out = {}
    for t in TIERS:
        if counts[t]:
            tier_p = sum(x for x, (tt, _) in zip(w, items) if tt == t) / total * 100
            new_p = sum(x for x, (tt, own) in zip(w, items) if tt == t and not own) / total * 100
            unowned = counts[t] - owned[t]
            out[t] = (tier_p, new_p, new_p / unowned if unowned else 0.0)
    return f, out


def main():
    root = tk.Tk()
    root.title("Crate Odds")
    for col, h in enumerate(["Tier", "In crate", "Owned", "Item weight"]):
        tk.Label(root, text=h, font=("", 0, "bold")).grid(row=0, column=col, padx=6, pady=4)

    def entry(row, col, val, width=8):
        e = tk.Entry(root, width=width)
        e.insert(0, str(val))
        e.grid(row=row, column=col, padx=4, pady=1)
        return e

    rows = {}
    for r, t in enumerate(TIERS, 1):
        tk.Label(root, text=t).grid(row=r, column=0, sticky="w", padx=6)
        rows[t] = (entry(r, 1, 0, 6), entry(r, 2, 0, 6), entry(r, 3, round(BASE_W[t], 8), 12))

    mods = {}
    for i, (key, label, val) in enumerate([("luck", "Luck (0-100)", 0), ("event", "Event x (1-2)", 1.0),
                                           ("k_sr", "SR pity cap", 6.0), ("k_r", "Rare pity cap", 1.5)]):
        r = len(TIERS) + 1 + i // 2
        tk.Label(root, text=label).grid(row=r, column=(i % 2) * 2, sticky="e", padx=6)
        mods[key] = entry(r, (i % 2) * 2 + 1, val, 6)

    out = tk.Label(root, font=("Courier", 12), justify="left", anchor="w")
    out.grid(row=len(TIERS) + 4, column=0, columnspan=4, padx=6, pady=6, sticky="w")

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
            if not 1.0 <= m["event"] <= 2.0:
                raise ValueError("event multiplier must be 1-2")
            f, res = calc(counts, owned, weights, m["luck"], m["event"], m["k_sr"], m["k_r"])
            if not res or sum(p for p, _, _ in res.values()) <= 0:
                raise ValueError("crate has no weight")
        except (ValueError, ZeroDivisionError) as e:
            out.config(text=f"Error: {e}", fg="red")
            return
        o, n = sum(owned.values()), sum(counts.values())
        mythic = "  (complete: M x4, SR x1.5)" if o == n else f"  Mythic pity x{100 ** f:.2f}"
        lines = [f"Owned {o}/{n}   f={f:.3f}{mythic}", "",
                 f"{'Tier':<11}{'Tier %':>9}{'New %':>9}{'Per new %':>11}{'1 in':>9}"]
        for t, (tp, np, per) in res.items():
            lines.append(f"{t:<11}{tp:>9.4f}{np:>9.4f}{per:>11.4f}{(100 / tp if tp else 0):>9.1f}")
        new = sum(np for _, np, _ in res.values())
        lines += ["", f"New skin per open: {new:.4f}%" + (f" (1 in {100 / new:.1f})" if new else "")]
        out.config(text="\n".join(lines), fg="black")

    tk.Button(root, text="Calculate", command=run).grid(row=len(TIERS) + 3, column=0, columnspan=4, pady=4)
    root.bind("<Return>", run)
    root.mainloop()


if __name__ == "__main__":
    main()
