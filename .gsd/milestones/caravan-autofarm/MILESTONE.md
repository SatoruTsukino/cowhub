---
name: caravan-autofarm
version: v0.1
status: planning
created: 2026-11-05T00:00:00Z
---

# Milestone: Caravan Autofarm

> **Status:** 🧪 Plan 1.1 built; standalone UAT (Plan 1.2) pending.
> Prototype in `luascripts/caravan_autofarm.lua` first, then port into `preview.lua` (theme `frost`), then promote to cowhub via `scripts/promote-preview.py`.

## Vision
When a caravan spawns, the hub scares the guide until it stops, loots every crate and barrel during the loot window, closes the crate reveal, then goes back to what it was doing. No manual input. Caravans come every 8–16 min, so it runs alongside the existing autofarm.

## Research (2026-11-05, dumps in `~/Opiumware/workspace/*_82507849398215_Source.txt`)

| Source | Finding |
|--------|---------|
| CaravanController L134–147 | State is the Folder `ReplicatedStorage.CowGame.CaravanState`. It can be recreated, so watch `CowGame.ChildAdded`. All state is in attributes. |
| CaravanController L255–326 | Attributes: `Phase` (`OnRoad` / `Stopped` / `Leaving`), `EventId` (number), `Kind` (`Supply` / `Fright`), `Route` (string), `Layout` (JSON), `StartAt`, `EndsAt`, `Speed`, `StopDistance`, `StoppedAt`, `LootEndsAt`, `GoneAt`, `LeftAt`, `Fear`, `FearAt`, `LeaveReason`, `Barrels` (JSON `{index: portions}`), `Crates` (JSON `{index: true | {userId: true}}`). |
| CaravanConfig | Schedule: every 720 s ± 240 s. Road phase 180 s. Loot phase 90 s. Guide goal 1000 (Supply) / 500 (Fright). Scare radius 15 studs, close radius 4 (+2). Base points: Moo 5, GrumpyMoo 7, Stomp 7. Armor adds +1 to +5. Herd bonus +2..4 when 2+ cows moo. Barrel capacity 50 (35 for CrazyCoal and Candy). Bite cooldown is `AppleSupplyRules.Cooldown`. |
| CaravanRules / CaravanRoute | Shared, pure modules. Position along the route = `CaravanRules.Pose(CaravanRoute.Build(Route), CaravanRules.Travelled(route, StartAt, Speed, serverNow))`. Once stopped, the distance is `StopDistance`. **Require them; don't copy the math.** |
| CaravanController L521–608 | Barrel hitbox: `NodeId = "Caravan<EventId>_B<index>"`, `CowBiteTargetKind = "CaravanBarrel"`, tag `CowBiteTarget` only while `Phase == "Stopped"`. Crate hitbox has `CanQuery = false` and a `CrateKickPrompt` BillboardGui with MaxDistance 18. Models are under `Workspace.CaravanConvoy`. |
| InputController L1296, L1438 | Barrel bite = `ChompRequest:FireServer(nodeId, nil, serial)`, the same wire as grass. The result is matched on `^Caravan%d+_B%d+$`. Rate limit 8 cap, 8/s. |
| InputController L2113–2213 | Kick = `KickRequest:FireServer({ Position, RequestId [, Target] [, FarmerId] }, "Hold"?)`. Rate limit 4 cap, 3/s. Needs `CowUpgrade_HindStrength >= 1`, and the server cooldown `CowNextKickAt`. |
| InputController L2386–2403, Config L216 | Moo = `MooRequest:FireServer(style?)`. Client cooldown 1.5 s; rate limit 2 cap, 2/3 per s. |
| CaravanController L1353–1425 | Server events: `Started`, `Stopped`, `Escaped`, `PackedUp`, `Fright` (Target Guide/Farmer, Total, Level), `FrightMissed` (too far), `Loot`, `CrateOpened`, `Crate` (reveal). **The carrying remote is not in the dumps.** |
| preview.lua L10449 | The existing reward-GUI closer already includes `CaravanCrateReveal`. Reuse it. |

### UAT run 1 findings (2026-11-05, caravan_20261105_162746 / _163119)
- Moo reaches the server: in our-moos-only windows fear rose 22–42 per 5 s at 3.5 studs, and caravan #2 hit 996 → Stopped. Manual moos share the 2-cap bucket, so don't moo by hand while the farm runs.
- Zero `in` events: the listener only checked arg 1 of `CowGame.Remotes` RemoteEvents. Now it covers every (Unreliable)RemoteEvent under ReplicatedStorage and finds the payload in any arg.
- That made the Grumpy "no_reply" rejection a false positive. "No reply" now counts only once the listener has heard a caravan event.
- Crates show "Hold Kick to open": a held kick (`"Hold"`, then `"Keep"` every 0.4 s, `CowKickHolding` must be set within 1 s, then `KickRequest(nil, "Release")`, grounded). Taps (no 2nd arg) never open them.

### UAT run 2 findings (2026-11-06, caravan_20261106_000519)
- Grumpy moo is **not credited**: 37 `MooRequest("Grumpy")` sends at about 3.5 studs, and Fear stayed 0 all caravan. Run 1 only scared because it fell back to a plain Moo. The fallback now uses the replicated `Fear` attribute: 5 in-range Grumpy sends with no rise → rejected → plain Moo.
- Still zero `in` events, so U1 is open. Caravan feedback can't rely on events. Use the `Fear` attribute instead.
- Destroy: the gen2 library has no `Destroy`. Use `Window:Unload()`.

### UAT run 3 findings (2026-11-06, caravan_20261106_163745)
- **U1 resolved:** caravan events arrive on `Remotes.ClientEvent` as `("Caravan", payload)`. 57 events seen.
- **Grumpy is credited:** `Fright{Action="GrumpyMoo", Base=7, Armor=5, Herd=3, Close=0}` → Total 15 per moo (17 with Close=2). Run 2's flat Fear was the debug hook: `log()` → `GetServerTimeNow` inside `__namecall` overwrote the pending method, so our own `MooRequest:FireServer` failed silently in `fire()`'s pcall (same bug as the CosmeticRequest error). Fixed by deferring the log.
- Pace: about 9 fear/s solo (15 per ~1.65 s). The script joined 61 s into the road phase, plus a 22 s walk-in, and reached 662/1000 → Escaped. A full 180 s at ~160 s in range ≈ 1450, so **solo reaches the goal if running from `Started`**.
- 5× `FrightMissed` (server Distance 16–18) while the client measured ~3.7 to the guide model. The server measures against something else. `miss_probe` now logs model vs route-pose distances.

### UAT run 4 findings (2026-11-06, caravan_20261106_181609, full AFK caravan)
- **Scare solved solo:** 1004/1000 → Stopped (14–16 per Grumpy moo, Herd 2). 1 FrightMissed. `miss_probe`: server 20.0, model 3.7, route pose 6.9, so the server's guide reference is neither.
- **Crates solved:** 3/3 `CrateOpened` (held kick, Target = crate model, Ok:true). One `KickCooldown` retry. Reveal closed via `KeepRaiding`.
- **Barrels weak:** 232 bites rotated across 4 barrels (1 s `CowBiteCooldown` each) but only 16 `Loot` events. User: grazing is continuous on one selected hitbox, with no need to move between bites. The farm now locks one barrel until it empties, then the nearest. `in_other` logs unknown replies while grazing to find the chomp result.

### Unknowns (Plan 1.2 resolves; manual search list in SEARCH.md)
- U1: ~~Which remote delivers `HandleEvent` payloads~~ → `Remotes.ClientEvent("Caravan", payload)` (run 3).
- U2: ~~Stomp~~ → replaced by Grumpy Moo (user decision 2026-11-05): `MooRequest:FireServer("Grumpy")`. Confirmed from CowExpressions: `MooStyles.Grumpy` has no Earned/Hidden/Disabled gate, and `IsMooStyle("Grumpy")` is true. The server should credit it as Action `GrumpyMoo` (+7); the script still falls back to a plain Moo if it is credited as Moo.
- U3: Whether a kick at a crate's `Position` (no `Target`, since the hitbox has CanQuery=false) opens it, and the kick reach.
- U4: Barrel bite range and cooldown (`AppleSupplyRules.Cooldown`), and whether one bite takes 1 portion (`BiteAmount = 1`).
- U5: Where the guide is in `CaravanConvoy` (seated model). The route pose is the fallback.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| CV-01 | Detect caravan phases from `CaravanState` attributes, and survive the folder being recreated | Must |
| CV-02 | OnRoad: stay within 4 studs of the guide/lead wagon and moo on cooldown (GrumpyMoo if owned; Stomp if U2 allows) until `Phase` leaves `OnRoad` | Must |
| CV-03 | Stopped: kick every unopened crate (opened = `Crates[i] == true` or `Crates[i][userId]`) | Must |
| CV-04 | Stopped: bite barrels with portions > 0 until they're empty or `LootEndsAt` passes, within rate limits | Must |
| CV-05 | Close the crate reveal (existing closer) | Must |
| CV-06 | Restore the previous position/farm afterwards, and pause the other autofarm loops while a caravan runs | Must |
| CV-07 | Respect the hub bot-check pause gate (Plan 1.0 heartbeat) and `BLOCK_ATTRS` | Must (safety) |
| CV-08 | Rayfield toggles: Caravan Autofarm, Loot Only, Debug Log | Must |
| CV-09 | Debug log in `cowhub/caravanlogs/` (JSONL) | Should |
| CV-11 | Natural mode: walk with Humanoid MoveTo / PathfindingService along the caravan route (intercept point ahead when far, beside the guide when close), act only within reach, walk back afterwards. No teleports | Must |
| CV-10 | Stats: caravans stopped / looted, barrels, crates, skins | Nice |

## Phases

### Phase 1: Caravan Autofarm
- [x] Plan 1.1: Standalone `luascripts/caravan_autofarm.lua` (watcher + probe + experimental farm)
- [ ] Plan 1.2: Standalone UAT (resolves U1–U5, proves farm)
- [ ] Plan 1.3: Integrate into preview.lua
- [ ] Plan 1.4: Hub UAT + promote to cowhub
