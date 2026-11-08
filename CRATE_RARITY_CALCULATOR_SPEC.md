# Crate Rarity & Pity Mathematical Specification

A comprehensive technical reference decompiled from Cow Game (`Place_82507849398215_Folder_Shared_1794016208.txt`) for building a Python crate odds calculator with rarity inputs and ownership states.

---

## 1. Engine Source Files & Exact Locations

| Module | Source File / Namespace | Line Range (Shared Dump) | Role in Crate Odds |
|:---|:---|:---:|:---|
| **`LuckRules`** | `ReplicatedStorage.CowGame.Shared.LuckRules` | L231400 – L231650 | Base luck normalization, server event multiplier, tier boost caps, and Common/Uncommon floor drain. |
| **`CollectionLuckRules`** | `ReplicatedStorage.CowGame.Shared.CollectionLuckRules` | L285550 – L285800 | Dynamic collection pity, unowned exponential scaling ($100^f$), and owned duplicate weight surrender. |
| **`CaravanRules`** | `ReplicatedStorage.CowGame.Shared.CaravanRules` | L284000 – L284500 | Crate skin weight assembly (`SkinWeights`) and roll execution (`RollSkin`). |
| **`HalloweenConfig`** | `ReplicatedStorage.CowGame.Shared.HalloweenConfig` | L58000 – L59500 | Base item definitions, rarity assignments, and default chances for standard event crates. |

---

## 2. Core Variables & Crate Inputs

### User Inputs
- **Crate Counts ($N_r$):**
  - $N_C$: Number of Common items in crate
  - $N_U$: Number of Uncommon items in crate
  - $N_R$: Number of Rare items in crate
  - $N_{SR}$: Number of Super Rare items in crate
  - $N_M$: Number of Mythic items in crate
  - Total items in crate:
    $$N_{\text{total}} = N_C + N_U + N_R + N_{SR} + N_M$$

- **Owned Counts ($O_r$):**
  - $O_C, O_U, O_R, O_{SR}, O_M \in [0, N_r]$
  - Total owned items in crate:
    $$O_{\text{total}} = \sum_{r} \min(O_r, N_r)$$
  - Unowned count per tier:
    $$U_r = N_r - O_r$$

- **Modifiers (Optional / Defaults):**
  - $L \in [0, 100]$: Player Luck attribute (default = 0)
  - $E \in [1.0, 2.0]$: Server Luck Event multiplier (default = 1.0)
  - $K_{SR}$: Super Rare unowned multiplier cap (default = 6.0 in CaravanRules, 3.0 in standard)
  - $K_R$: Rare unowned multiplier cap (default = 1.5)

---

## 3. Mathematical Equations Step-by-Step

### Step 1: Base Tier Weights
In Cow Game (`HalloweenConfig.CrateSkins`), standard per-item base weights are:
- $w_{\text{Common}} = 0.079063636$ (11 skins = 86.97% total)
- $w_{\text{Uncommon}} = 0.040000000$
- $w_{\text{Rare}} = 0.030000000$ (4 skins = 12.00% total)
- $w_{\text{Super Rare}} = 0.005000000$ (2 skins = 1.00% total)
- $w_{\text{Mythic}} = 0.000300000$ (1 skin = 0.03% total)

Base weight of each tier $r$:
$$W_r = N_r \times w_r$$
Total crate base weight:
$$W_{\text{base}} = \sum_{r} W_r$$

---

### Step 2: Luck Rules Scaling (`LuckRules.Weights`)

1. **Normalized Player Luck:**
   $$L_{\text{norm}} = \text{clamp}(L, 0, 100)$$

2. **Tier Multipliers & Hard Caps (`LuckRules.Caps`):**
   - Rare Cap: $C_R = 1.25$
   - Super Rare Cap: $C_{SR} = 1.50$
   - Mythic Cap: $C_M = 2.00$

   For boosted tiers $r \in \{\text{Rare}, \text{Super Rare}, \text{Mythic}\}$:
   $$\text{BaseMult}_r = 1 + (C_r - 1) \times \frac{L_{\text{norm}}}{100}$$
   $$\text{Mult}_r = \min(C_r, \text{BaseMult}_r) \times E$$

3. **Weight Shift ($\Delta W$):**
   $$W'_r = W_r \times \text{Mult}_r$$
   $$\Delta W = \sum_{r \in \{R, SR, M\}} (W'_r - W_r)$$

4. **Ordinary Floor Protection (`LuckRules.OrdinaryFloor = 0.1`):**
   Common and Uncommon tiers cannot be drained below 10% of total crate weight:
   $$\text{Floor} = 0.10 \times W_{\text{base}}$$
   $$\text{Drainable}_C = \max(0, W_C - \text{Floor})$$
   $$\text{Drainable}_U = \max(0, W_U - \text{Floor})$$
   $$\text{Drainable}_{\text{total}} = \text{Drainable}_C + \text{Drainable}_U$$

   Actual drained weight:
   $$\text{Drain} = \min(\Delta W, \text{Drainable}_{\text{total}})$$
   $$W'_C = W_C - \text{Drain} \times \frac{\text{Drainable}_C}{\text{Drainable}_{\text{total}}}$$
   $$W'_U = W_U - \text{Drain} \times \frac{\text{Drainable}_U}{\text{Drainable}_{\text{total}}}$$

---

### Step 3: Collection Pity & Unowned Scaling (`CollectionLuckRules`)

1. **Progress Fraction ($f$):**
   If $N_{\text{total}} \le 1$, $f = 0$. Otherwise:
   $$f = \frac{O_{\text{total}}}{N_{\text{total}} - 1}$$
   *(Note: At 0 owned $\implies f = 0$. When 1 item remains unowned $\implies f = 1.0$.)*

2. **Unowned Item Multipliers ($M_i$):**
   - **Mythic (Exponential Pity):**
     $$M_{\text{Mythic}} = 100^f = 100^{\frac{O_{\text{total}}}{N_{\text{total}} - 1}}$$
     - At $f = 0 \implies 100^0 = 1.0\times$
     - At $f = 0.5 \implies 100^{0.5} = 10.0\times$
     - At $f = 1.0 \implies 100^1 = 100.0\times$ (Maximum 100x Mythic Pity!)
   - **Super Rare (Linear Pity):**
     $$M_{\text{SR}} = 1 + (K_{SR} - 1) \times f$$
     *(With $K_{SR} = 6.0 \implies 1 + 5f$, scales $1.0\times \to 6.0\times$)*
   - **Rare (Linear Pity):**
     $$M_{\text{Rare}} = 1 + (K_R - 1) \times f$$
     *(With $K_R = 1.5 \implies 1 + 0.5f$, scales $1.0\times \to 1.5\times$)*
   - **Common / Uncommon:**
     $$M_{\text{Common}} = 1.0, \quad M_{\text{Uncommon}} = 1.0$$
   - **Already Owned Items:**
     $$M_j = 1.0$$

3. **Crate Completed Exception ($O_{\text{total}} = N_{\text{total}}$):**
   When 100% of items are already owned (`CollectionLuckRules.Completed`):
   $$\text{Mult}_{\text{Mythic}} = 4.0\times, \quad \text{Mult}_{\text{SR}} = 1.5\times, \quad \text{Others} = 1.0\times$$

---

### Step 4: Weight Reallocation from Owned to Unowned

1. **Unowned Weight Demand ($\text{Demand}$):**
   $$\text{Demand} = \sum_{i \in \text{Unowned}} w'_i \times (M_i - 1)$$

2. **Owned Surrender Capacity (`RepeatFloor = 0.1`):**
   Owned copies can give up to 90% of their weight (retaining a 10% repeat floor):
   $$\text{Capacity}_j = w'_j \times (1 - 0.10) = 0.90 \times w'_j$$
   $$\text{TotalCapacity} = \sum_{j \in \text{Owned}} \text{Capacity}_j$$

3. **Actual Transferred Weight:**
   $$\text{Transfer} = \min(\text{Demand}, \text{TotalCapacity})$$
   $$\text{ScalingRatio} = \frac{\text{Transfer}}{\text{Demand}} \quad (\text{if Demand} > 0)$$

4. **Capacity Drain Order:**
   Owned items give up weight sorted by:
   1. Tier completion ($\frac{O_r}{N_r}$) descending
   2. Number of copies owned descending

5. **Final Item Weights ($W''_k$):**
   - For unowned item $i$:
     $$W''_i = w'_i + \left(w'_i \times (M_i - 1)\right) \times \text{ScalingRatio}$$
   - For owned item $j$:
     $$W''_j = w'_j - \text{Drained}_j$$

---

### Step 5: Final Probability Calculation

Total final weight:
$$W_{\text{final}} = \sum_{k} W''_k$$

1. **Probability of Any Specific Item $k$:**
   $$P(k) = \frac{W''_k}{W_{\text{final}}} \times 100\%$$

2. **Probability of a Specific Rarity Tier $r$:**
   $$P(\text{Tier } r) = \sum_{k \in r} P(k) = \frac{\sum_{k \in r} W''_k}{W_{\text{final}}} \times 100\%$$

3. **Probability of Rolling an UNOWNED Item of Tier $r$:**
   $$P(\text{Unowned Tier } r) = \frac{\sum_{i \in r \land \text{unowned}} W''_i}{W_{\text{final}}} \times 100\%$$

---

## 4. Standalone Barebones Python Calculator

Save and run this script directly with your desired crate and owned counts:

```python
#!/usr/bin/env python3
"""
Cow Game Crate Odds & Pity Calculator
Implements exact LuckRules and CollectionLuckRules from Place_82507849398215_Folder_Shared_1794016208.txt.
"""

def calculate_crate_odds(crate_counts, owned_counts, luck=0, event_luck=1.0, sr_pity_cap=6.0, rare_pity_cap=1.5):
    # Standard per-item base weights from HalloweenConfig.CrateSkins
    base_weights = {
        "Common": 0.07906363636363636,
        "Uncommon": 0.04000000000000000,
        "Rare": 0.03000000000000000,
        "Super Rare": 0.00500000000000000,
        "Mythic": 0.00030000000000000
    }
    tiers = ["Common", "Uncommon", "Rare", "Super Rare", "Mythic"]
    luck_caps = {"Rare": 1.25, "Super Rare": 1.50, "Mythic": 2.00}

    # 1. Expand crate items
    total_items = sum(crate_counts.get(t, 0) for t in tiers)
    total_owned = sum(min(owned_counts.get(t, 0), crate_counts.get(t, 0)) for t in tiers)
    
    items = []
    for t in tiers:
        n = crate_counts.get(t, 0)
        o = min(owned_counts.get(t, 0), n)
        for i in range(n):
            items.append({
                "id": f"{t}_{i+1}",
                "rarity": t,
                "weight": base_weights[t],
                "owned": (i < o)
            })

    total_weight = sum(it["weight"] for it in items)
    if total_weight <= 0:
        return {}, {}

    # 2. LuckRules.Weights
    tier_w = {t: sum(it["weight"] for it in items if it["rarity"] == t) for t in tiers}
    boosted_tier_w = dict(tier_w)

    norm_luck = max(0.0, min(100.0, luck))
    event_mult = max(1.0, min(2.0, event_luck))

    delta_w = 0.0
    for t in ["Mythic", "Super Rare", "Rare"]:
        if tier_w[t] > 0:
            cap = luck_caps[t]
            base_mult = 1.0 + (cap - 1.0) * (norm_luck / 100.0)
            mult = min(cap, base_mult) * event_mult
            boosted = tier_w[t] * mult
            delta_w += (boosted - tier_w[t])
            boosted_tier_w[t] = boosted

    # Drain Common and Uncommon down to OrdinaryFloor (10% total weight)
    ord_floor = 0.10 * total_weight
    drain_c = max(0.0, tier_w["Common"] - ord_floor)
    drain_u = max(0.0, tier_w["Uncommon"] - ord_floor)
    drain_pool = drain_c + drain_u

    drain = min(delta_w, drain_pool)
    if drain_pool > 0:
        d_c = drain * (drain_c / drain_pool)
        d_u = drain - d_c
        boosted_tier_w["Common"] -= d_c
        boosted_tier_w["Uncommon"] -= d_u

    luck_weights = []
    for it in items:
        t = it["rarity"]
        w = it["weight"] * (boosted_tier_w[t] / tier_w[t]) if tier_w[t] > 0 else 0.0
        luck_weights.append(w)

    # 3. CollectionLuckRules
    if total_owned == total_items and total_items > 0:
        completed_mults = {"Mythic": 4.0, "Super Rare": 1.5, "Rare": 1.0, "Common": 1.0, "Uncommon": 1.0}
        final_weights = [w * completed_mults[it["rarity"]] for w, it in zip(luck_weights, items)]
    elif total_items <= 1 or total_owned == 0:
        final_weights = list(luck_weights)
    else:
        progress_f = total_owned / (total_items - 1)
        unowned_mults = []
        for it in items:
            t = it["rarity"]
            if it["owned"]:
                unowned_mults.append(1.0)
            elif t == "Mythic":
                unowned_mults.append(100.0 ** progress_f)
            elif t == "Super Rare":
                unowned_mults.append(1.0 + (sr_pity_cap - 1.0) * progress_f)
            elif t == "Rare":
                unowned_mults.append(1.0 + (rare_pity_cap - 1.0) * progress_f)
            else:
                unowned_mults.append(1.0)

        demand = 0.0
        demand_list = []
        for it, w, m in zip(items, luck_weights, unowned_mults):
            d = it["weight"] * (m - 1.0)
            demand_list.append(d)
            demand += d

        capacity = 0.0
        cap_entries = []
        for idx, (it, w) in enumerate(zip(items, luck_weights)):
            if it["owned"] and w > 0:
                c = w * 0.90  # RepeatFloor = 0.10
                capacity += c
                cap_entries.append({"index": idx, "capacity": c})

        transfer = min(demand, capacity)
        ratio = (transfer / demand) if demand > 0 else 0.0

        final_weights = list(luck_weights)
        rem_transfer = transfer
        for entry in cap_entries:
            d = min(rem_transfer, entry["capacity"])
            final_weights[entry["index"]] -= d
            rem_transfer -= d
            if rem_transfer <= 0:
                break

        for idx, d in enumerate(demand_list):
            final_weights[idx] += d * ratio

    # 4. Final Percentages
    w_sum = sum(final_weights)
    tier_probs = {t: 0.0 for t in tiers}
    unowned_probs = {t: 0.0 for t in tiers}

    for it, w in zip(items, final_weights):
        p = (w / w_sum) * 100.0
        tier_probs[it["rarity"]] += p
        if not it["owned"]:
            unowned_probs[it["rarity"]] += p

    return tier_probs, unowned_probs


if __name__ == "__main__":
    # Example: Halloween Crate (18 total items)
    crate = {
        "Common": 11,
        "Uncommon": 0,
        "Rare": 4,
        "Super Rare": 2,
        "Mythic": 1
    }

    # Example: Player owns 17 out of 18 skins (only Mythic remains unowned)
    owned = {
        "Common": 11,
        "Uncommon": 0,
        "Rare": 4,
        "Super Rare": 2,
        "Mythic": 0
    }

    print("=== CRATE PROBABILITY CALCULATOR ===")
    print(f"Crate: {crate}")
    print(f"Owned: {owned}\n")

    tier_p, unowned_p = calculate_crate_odds(crate, owned, luck=0, event_luck=1.0)

    print(f"{'Rarity':<12} | {'Tier Chance':<12} | {'Unowned Chance':<15} | {'1-in-Odds'}")
    print("-" * 55)
    for t in ["Common", "Uncommon", "Rare", "Super Rare", "Mythic"]:
        if crate.get(t, 0) > 0:
            tp = tier_p[t]
            up = unowned_p[t]
            odds_str = f"1 in {100.0 / tp:.1f}" if tp > 0 else "0"
            print(f"{t:<12} | {tp:>10.4f}% | {up:>13.4f}% | {odds_str}")
```

