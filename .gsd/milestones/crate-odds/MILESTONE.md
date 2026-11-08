---
name: crate-odds
version: v0.1
status: verifying
created: 2026-11-08T00:00:00Z
---

# Milestone: Crate Odds Calculator

> **Status:** 🧪 Plan 1.1 built (`scripts/crate_odds.py`); verification and commit pending.

## Vision
A small desktop tool (Python + tkinter) that shows the chance of rolling each skin rarity from a crate.
You enter how many skins of each rarity the crate holds and how many of each you own. The tool applies
the game's luck and collection-pity rules exactly as the decompiled shared modules do. A dropdown fills
in the real crate layouts (Halloween / Caravan).

## Non-Goals
- Opening crates or any in-game automation. `luascripts/halloween_crate_opener.lua` already covers that.
- Reading the player's live inventory. Owned counts are typed in by hand.
- Back-bunny / title luck. CaravanRules passes `nil` for that term.

## Research (2026-11-08, dumps in `~/Opiumware/workspace/*_82507849398215_Source.txt` + `Place_…_Folder_Shared_1794016208.txt`)

| Source | Finding |
|--------|---------|
| LuckRules | `Caps = { Mythic = 2, Super Rare = 1.5, Rare = 1.25 }`, `OrdinaryFloor = 0.1`, `MaxLuck = 100`. Multiplier = `min(cap, (1 + (cap-1)·L/100) · (1 + bunny)) · event`, with event clamped to 1–2. |
| LuckRules.Weights | Boosts are funded one tier at a time, in the order Mythic → Super Rare → Rare. Each takes weight from Common/Uncommon above the floor first. Any shortfall comes from lower boosted tiers (Mythic takes from Rare then Super Rare; Super Rare takes from Rare). A Common/Uncommon tier that is already below `0.1·total` gets **no** floor and can be drained to 0. |
| CollectionLuckRules.Multiplier | When the crate is not complete, every owned skin gets ×1. An unowned Mythic gets `100^(E/(T-1))`. Unowned Super Rare and Rare get `1 + (cap-1)·E/(T-1)`, with default caps of SR 3 and Rare 1.5. Once complete, the multipliers are `{ Mythic = 4, Super Rare = 1.5 }` and they are paid for by reallocation, not by multiplying weights directly. |
| CollectionLuckRules.Weights | Demand = **base** weight × (mult − 1). Owned skins with mult 1 donate up to 90% of their luck-adjusted weight (`RepeatFloor = 0.1`). Donors are sorted by tier completion (descending), then copies (descending), then rank (ascending, Common first), then Id. |
| CollectionLuckRules.Progress | Skins with weight ≤ 0 are excluded from `Total`/`Earned`. Example: `FrankenmooCoat`, a Rare with Chance 0. |
| CaravanRules.SkinWeights (Shared L53936) | Passes `{ SuperRare = 6, Rare = 1.5 if Theme == "Halloween" else 1, Event }`. The bunny term is `nil`. |
| CaravanRules.RollSkin | Rolls `NextNumber()` in [0,1) against the cumulative weights. If the weights sum to less than 1, the leftover goes to the first skin in the list. |
| HalloweenConfig.CrateSkins (L58262) | 11 Common @ 0.0790636…, 4 Rare @ 0.03 (+1 Rare @ 0), 2 Super Rare @ 0.005, 1 Mythic @ 0.0003. Sum = 1. |
| CaravanConfig.Skins (Supply) | 10 Rare @ 0.09847, 3 Super Rare @ 0.005, 1 Mythic @ 0.0003. Sum = 1. |

### Corrections to `CRATE_RARITY_CALCULATOR_SPEC.md`
1. Pity demand uses the base weight. The spec's equations say luck-adjusted; its sample code had this right.
2. Completed bonus: the spec's code multiplies the raw weights. In the source it goes through owned → unowned reallocation.
3. Floor: a Common/Uncommon tier below 10% of the total is fully drainable. The spec says `max(0, W − floor)`.
4. Luck shortfall falls through to lower boosted tiers. The spec leaves this out.
5. Super Rare cap: 6 for every caravan crate, and the module default is 3. The Rare cap is 1 for Supply, not 1.5.
6. Uncommon weight `0.04` has no source. No crate in the dumps contains an Uncommon skin.

## Phases
- [x] Phase 1 / Plan 1.1: Calculator engine + GUI + presets (built; verify pending)
