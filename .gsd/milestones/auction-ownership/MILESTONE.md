---
name: auction-ownership
version: v0.1
status: complete
created: 2026-11-04T00:00:00Z
---

# Milestone: Town Auction Ownership

> **Status:** 📝 Phase 1 complete (promoted to cowhub). Phase 2 (auto-bid unowned) UAT passed; promoted to cowhub 2026-11-04. Phase 3 (Skin Auction live display) UAT passed; promoted to cowhub 2026-11-04. All phases complete.
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
| AO-01 | Find and cache the live UI profile store (`getgc`, throttled ≥5 s rescans) | Must-have | ✅ UAT passed |
| AO-02 | Per lot: Owned + copies via `CosmeticConfig.IsOwned` / `GetOwnedCount`; fallback to listable count | Must-have | ✅ UAT passed |
| AO-03 | Card line: `Owned: ✅ ×N (M listable)` / `Owned: ❌` / `Owned: n/a` | Must-have | ✅ UAT passed |
| AO-04 | Cards redraw on a `ClientEvent` `"Snapshot"` push (no extra remote calls) | Should-have | ✅ UAT passed |
| AO-05 | Shared `cosmetics.isOwned(id)` helper (true / false / nil = unknown) used by both auctions | Must-have | ✅ UAT passed |
| AO-06 | Town Auction toggle "Auto Bid Unowned": auto-bid/buy every lot whose cosmetic is not owned | Must-have | ✅ UAT passed |
| AO-07 | Skin Auction toggle "Auto Bid Unowned": same for `SkinId` lots | Must-have | ✅ UAT passed |
| AO-08 | Fail-safe: unknown ownership or non-cosmetic → never bid. No max-bid requirement (user decision 2026-11-04); an existing Max Auto Bid limit still applies if set | Must-have | ✅ UAT passed |
| AO-09 | Both toggles persist across relog (TownAuction / Auction state) | Should-have | ✅ UAT passed |
| AO-10 | "Live Auction House Display" section shows all skin lots live (name, rarity, owned, min bid, leader, time left) | Must-have | ✅ UAT passed |
| AO-11 | Lot reads match the game: server-time countdown, rarity from CosmeticConfig, leading by `LeaderId`, min bid falls back to `StartingBid` | Must-have | ✅ UAT passed |
| AO-12 | Remove the "Show Current Auction Skins" button | Must-have | ✅ UAT passed |

## Phases

### Phase 1: Preview Town Auction Ownership
**Plans:**
- [x] Plan 1.1: Ownership lookup + card line (preview.lua)
- [x] Plan 1.2: In-game UAT, then promote to cowhub (feature commit applied directly; promote-preview.py would also ship the Plan 4.1 golden-probe debug code)

### Phase 2: Auto-Bid Unowned (Town Auction + Skin Auction)
Research: `SkinAuctionController` L109–116 decides ownership with the same `CosmeticConfig.IsOwned(skinId, profile)`, so `SkinId` is a cosmetic id and one helper serves both auctions.

**Plans:**
- [x] Plan 2.1: Shared ownership helper + two toggles (preview.lua)
- [x] Plan 2.2: In-game UAT, then promote (commit 510a594 applied directly: a full promote would also ship untested preview chomp commits f1c5445, c94b3e8, 9363000)

### Phase 3: Skin Auction Live Display
Research: "Live Auction House Display" (preview ~L6852) is an empty section; the live cards are made later under "Skin Lot: LotN". `SkinAuctionController` L130–154 reads lots with `GetServerTimeNow`, `CosmeticConfig.Get(skinId).Rarity` (no `Rarity` attribute exists), `LeaderId == UserId and Bid > 0`, and `MinimumBid or StartingBid`.

**Plans:**
- [x] Plan 3.1: Shared lot reader + live overview card, remove Show button (preview.lua)
- [x] Plan 3.2: In-game UAT, then promote (commit a1334b6 applied directly)
