---
name: skinhunter-catalog
version: v0.1
status: planning
created: 2026-11-05T00:00:00Z
---

# Milestone: Skin Hunter Links + Live Skin Catalogue

> **Status:** 📝 Planning: Plan 1.1 awaiting approval.
> Independent of the hub milestones; touches `luascripts/skinhunter.lua` only.

## Vision
Skin Hunter reloads itself after every server hop, and its target dropdowns list exactly the coats the game can auction, read live from the game. No hand-maintained skin list.

## Research (2026-11-05)

| Source | Finding |
|--------|---------|
| skinhunter.lua L28 `SCRIPT_SOURCE_URL` | `…/refs/heads/main/skinhunter.lua` returns **404**; `…/main/luascripts/skinhunter.lua` returns **200**. `queueReload` (L134) runs this URL after a teleport, so a hunt currently can't survive a server hop. |
| skinhunter.lua L372–495 | Hardcoded `DEFAULT_AUCTION_SKINS` (52 ids) and `AUCTION_COAT_META` (rarity + Active/Deferred). `getAuctionSkins` (L520) seeds from them, then guesses at the game's config. |
| `CosmeticConfig` dump L2731 | Module returns `{ Definitions = Definitions, … }`. Auction coats: `Slot = "Coat"`, `UnlockRule = "Auction"`, `Rarity`, `AuctionStatus` ("Active" / "Deferred"). Halloween auction coats are generated in a loop with the same fields (L~3060). |
| Dump vs hardcoded | 51 static auction coats in the dump; hardcoded has 52. `BumbleCoat` is a feat reward (`FeatId = "HoneycombEater"`), **not** an auction coat. |
| Rarity / status counts | Mythic 2 · Super Rare 4 Active + 14 Deferred + 1 with no status · Rare 8 + 1 Deferred · Uncommon 11 · Common 10. All within the existing rarity orders. |
| skinhunter.lua L796, L1308 | Reads a lot `Rarity` attribute, which doesn't exist (see auction-ownership Phase 3), so webhooks/logs say "Unknown". |
| skinhunter.lua L31–32 | `SkinHunterState.json` / `SkinHunterConfig.json` are written to the workspace root, against AGENTS.md "Workspace File Storage". |

## Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| SH-01 | `SCRIPT_SOURCE_URL` → `luascripts/skinhunter.lua` (HTTP 200) | Must-have | ⬜ |
| SH-02 | Dropdowns built only from `CosmeticConfig.Definitions` (Coat + UnlockRule Auction); rarity from `Rarity`, Active vs Deferred from `AuctionStatus` (missing → Active) | Must-have | ⬜ |
| SH-03 | Remove `DEFAULT_AUCTION_SKINS` / `AUCTION_COAT_META` and the hardcoded Halloween ids | Must-have | ⬜ |
| SH-04 | Lot rarity in logs/webhooks from the definition, not the missing attribute | Should-have | ⬜ |
| SH-05 | State/config under `cowhub/skinhunter/`, migrating legacy root files | Must-have (AGENTS.md) | ⬜ |

## Phases

### Phase 1: Links + Live Catalogue
- [ ] Plan 1.1: skinhunter.lua changes
- [ ] Plan 1.2: In-game UAT (dropdown counts, hop + reload)
