---
name: auction-ownership
version: v0.1
status: planning
created: 2026-11-04T00:00:00Z
---

# Milestone: Town Auction Ownership

> **Status:** 🧪 Plan 1.1 built; in-game UAT (Plan 1.2) pending.
> Replaces the earlier inventory-logger idea (no log files).
> Independent of the autofarm chomp refactor (`.gsd/SPEC.md`, `.gsd/ROADMAP.md`).

## Vision
Each lot card in the hub's Town Auction tab shows whether the player owns that cosmetic and how many copies, read live from the game's own Closet logic. The player can then judge a lot without opening the Closet.

## Scope
- `luascripts/preview.lua` `townAuction` module only (staging, theme `frost`).
- Promote to `cowhub.lua` via `scripts/promote-preview.py` after UAT.

## Non-Goals
- Writing log files.
- New remote calls. Ownership is read from client memory, and the existing auction `Snapshot` refresh is unchanged.
- Furniture ownership. Furniture-venue lots show `n/a`.

## Research (from `cowhub/dumps/`, place 82507849398215)

| Source | Finding |
|--------|---------|
| preview.lua L7403–7406 | The card's current `Owned Copies` uses `townAuction.ownedCopies[itemId]`, filled from auction `res.Copies` (L7545–7550). |
| `CowTownAuctionController` L63–80, L265 | `Copies` = only Super Rare / Mythic **duplicates** you can list (the first copy stays protected). A single owned copy shows 0, so the current number is misleading. |
| `BarnBook` (UI.Screens) L1523–1534, L811 | Closet cards: `CosmeticPresentation.describe(id, category, profile)` returns `Owned`, `Equipped`, `OwnedCount`. |
| `CosmeticPresentation` | `ReplicatedStorage.CowGame.UI.Shared.CosmeticPresentation`. Not dumped. |
| `CosmeticConfig` | `ReplicatedStorage.CowGame.Shared.CosmeticConfig`; `.Get(id)` returns the definition (`Id`, `Category`, …). Not dumped. |
| `UIController` L165 | `self.Store = UIStore.new(...)`; `Store:GetState().Profile` holds `UnlockedCosmetics` (id → `true`) and `EquippedCosmetics`. Findable with `getgc`, the same pattern as `chomp.findInput` (preview L1934). |
| `CowGame.Remotes.ClientEvent` | Server pushes `"Snapshot"` with `payload.Profile` after profile changes (UIController L2732). |

Resolved (Plan 1.1 Task 1, dumps in executor workspace root):
1. `describe(id, slot, profile, page?)` is heavy (builds copy-history pages); internally it calls `CosmeticConfig.GetOwnedCount(id, profile)` (CosmeticPresentation L907). **Use `CosmeticConfig.GetOwnedCount` / `IsOwned(id, profile)` directly.** Both index `profile.*` without nil checks, so the profile must be a table.
2. `GetOwnedCount`: Auction/TownAuction items → `PurchasedCosmetics.Count`; reward cosmetics → `RewardCosmetics.Count`; else `IsOwned and 1 or 0` (CosmeticConfig L2885).
3. `lot.ItemId` is a cosmetic id: the game gates on `CosmeticConfig.Get(lot.ItemId)` (CowTownAuctionController L443, L673). Nil → non-cosmetic (furniture) → `n/a`.
4. `Copies[].Id` stays keyed as preview already does (`ownedCopies`); shown as "listable".

## Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| AO-01 | Find and cache the live UI profile store (`getgc`, throttled ≥5 s rescans) | Must-have | ✅ code (UAT pending) |
| AO-02 | Per lot: Owned + copies via `CosmeticConfig.IsOwned` / `GetOwnedCount`; fallback to listable count | Must-have | ✅ code (UAT pending) |
| AO-03 | Card line: `Owned: ✅ ×N (M listable)` / `Owned: ❌` / `Owned: n/a` | Must-have | ✅ code (UAT pending) |
| AO-04 | Cards redraw on a `ClientEvent` `"Snapshot"` push (no extra remote calls) | Should-have | ✅ code (UAT pending) |

## Phases

### Phase 1: Preview Town Auction Ownership
**Plans:**
- [x] Plan 1.1: Ownership lookup + card line (preview.lua)
- [ ] Plan 1.2: In-game UAT, then promote to cowhub
