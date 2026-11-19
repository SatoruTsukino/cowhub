---
name: field-raid
version: v0.1
status: verifying
created: 2026-11-18T00:00:00Z
---

# Milestone: Field Raid + Blacksmith Anvil Automation

> **Status**: `FINALIZED` (2026-11-18). Plan 1.1 is built and live-tested in the client. Anvil shift UAT is pending.
> Build in `luascripts/preview.lua` (frost), promote to `luascripts/cowhub.lua` with `scripts/promote-preview.py`.

## Vision
Running a North River Field Raid needs no input: the hub starts a solo raid, eats raid wheat, bites raid
mobs, opens earned harvest chests, and banks at the Mill gate before the cow is in danger. It then starts
the next raid. Separately, during Day the hub works the blacksmith's part-time anvil shift. It accepts the
shift, hammers five perfect strikes and turns in the sheet.

## Research (2026-11-18)
Sources: Cobalt logs `2026-11-19T01_22_49Z.log` and `2026-11-19T01_39_36Z.log`, raid geometry dump
`Place_..._Model_FR987d2b...txt`, decompiled modules in the 18-11 `.rbxlx`.

| Source | Finding |
|--------|---------|
| Log 1 #8234, log 2 #303 | Start = `Remotes.FieldRaidRequest:FireServer("Solo", 1)`. Player attribute `CowFieldRaidId` = run id, e.g. `FR987d2b3b3a864725a2738de3b31662ee`. |
| Geometry dump | Arena = `workspace.CowWorld.Geometry[<run id>]`. Parts `Arrival`/`Entry`/`Return`, `FieldSoil` (1080×2026). `Harvest chest` models (attrs `Open`, `RaidChestRun`, `RaidChestTier`) hold the prompt `OpenHarvestChest` (Hold 0.25). The prompt `GateExit` ("Bank and leave") is on the `Mill gate` model. |
| FieldRaidController.target | Raid targets are client-built models in `workspace.NorthRiverRaidView`. On the PrimaryPart: `NodeId` / `CowBiteTargetId` (= server id), `CowBiteTargetKind` `RaidMob` or `RaidFood`, `Available`, `Health`, `MaxHealth`, `RaidState`, `RaidRipe`. Wheat cells carry `RaidWheatCell`. Ids: wheat `<run>_F<level>_<n>`, enemies `<run>_E<level>_<n>`. |
| InputController L~1296 | Every raid bite (wheat and mob) is `ChompRequest:FireServer(nodeId, nil, serial)`. This is the hub's existing `chomp.send` wire. A mob is chosen only when facing it (dot ≥ 0.9). |
| FieldRaidGraze | Grazing in a raid sends `FieldRaidRequest("GrazeStart", runId)`, and stopping sends `GrazeStop`. The server answers with `Forage` offers. |
| FieldRaidController.HandleEvent | Server → `ClientEvent("FieldRaid", {Kind=...})`: `Reset` (Level, Planting), `FieldChanged` (Level), `Targets`, `Remove`, `Cull`, `Health`, `EnemyDefeated`, `Bag` (Calories), `State` (Loadout), `Hurt`, `ChestOpening` (Token) → the game sends `CloseChest`, `Ended` (Home) → the game sends `AcknowledgeHome`. |
| FieldRaidEnemies | Spider 8 HP … Field Ogre 160 HP (boss). Hit damage is 0.5–4.5 hearts. |
| BlacksmithDialogueController / SmithingSheet / SmithingRules | Remote = `FieldRaidRequest`. `SmithJobStatus` → reply `FieldRaid {Kind="SmithJob", Event="Status", State=Available/Active/Ready/Paid, Cycle, Score}`. `SmithJobAccept(cycle)`, `SmithJobStart` → `Event="Mark" {Id, Index, Mark{Start,Phase,X,Y}, Last}` ×5. Strike = `SmithJobStrike {Id, Index, Time, X, Y}`. 100/100 when `(X,Y) = SmithingRules.Mark(Mark, Time)`. `Finished {Id, Score}`. Turn in = `SmithJobClaim(cycle)`. Open only when `SmithingRules.Open(DayNightCycle.Sample())`. Range limits: talking needs the cow within 16 studs of `CowWorld.Decorations.Blacksmith.Head`. Hammering needs it within 8 studs of `…NorthRiverOutfitters.BlacksmithHouseAndPorch["Blacksmith Shop"].AnvilCollider`. |

## Goals
1. `luascripts/fieldraid_probe.lua`: dump raid geometry, raid targets, player raid attributes and the smith site to `cowhub/probes/`.
2. Mob aura also bites raid mobs (`RaidMob`, Health > 0) with the raid wire `(NodeId, nil, serial)`.
3. Auto-chomp also works in a raid. Remote mode bites the nearest available raid wheat (ripe first) and sends `GrazeStart` once per run.
4. Field raid autofarm: auto start, wheat + mobs, walk to the next wheat, open owned chests, bank and leave on low hearts / bag target / time limit, then restart.
5. Blacksmith anvil autofarm: accept, hammer with perfect aim, claim. Teleport to the site and back.

## Non-Goals
- Dodging raid attack telegraphs (v1 bails out on low hearts instead).
- Powerup / companion / smith shop purchases.
- Advancing past a user-set max field level.

## Success Criteria
- [ ] `luau-compile` clean on preview.lua, cowhub.lua and fieldraid_probe.lua; max register < 200.
- [ ] `python3 scripts/update-functions-md.py --check` passes. New functions are indexed.
- [ ] `diff preview.lua cowhub.lua` shows only the theme and link lines.
- [ ] UAT: raid run banks calories hands-free, and the anvil shift is paid with grade A+.

## Build Notes (2026-11-18, live client tests via executor port)
- Live wire check: `ChompRequest(<run>_F7_325, nil, serial)` and `(<run>_E7_13, nil, serial)` came back with server GrazeResult `ChestOpening`. The ids and wire are valid. The bites were only rejected because a chest reveal was open.
- The arena is `Geometry.PrivateFieldRaids`, not `Geometry[<run id>]`. The camp is `Geometry.FieldRaids`, with `Stations` and `Entry` (= SignupInteraction).
- **Deeper fields grow richer wheat** (user). The autofarm pushes toward -Z up to Max Field. It bites what is in reach and picks the highest `BaseCalories` first.
- **Forward only** (user): no automatic retreat or banking. Dodge, kite, path and stuck-nudge never aim behind the cow (+Z). Wheat and chests are only targeted when ahead. Bank & Leave is manual only.
- Chest reveal: the server anchors the root and sets `CowFieldRaidChestProtectedUntil`. Damage is blocked (`Hurt Reason=chest_opening`) and hearts refill. `CloseChest` clears the protection right away. Policy: keep the reveal open until hearts are full, then close it (live: 8.5 → 13 in 12 s).
- Telegraph dodge uses the game's `FieldRaidCombat.Contains` with `FieldRaidEnemies.Move` on `Windup`/`ProjectileAim`/`BarrageMark` attacks. Raid mobs are kited at 6.8 studs or more, so FangBite (5.5) and ShieldCheck (6.2) don't reach.
- Live runs: auto-start → L1–L5 with a 103.7M bag. One run died at L4 (multiple mobs). Damage avoidance needs more tuning.

## Survival rework (2026-11-18, round 2)
- Probe of manual play (`cowhub/probes/moves.txt`, `hits.txt`): the user reached L7 in about 190 s at full hearts. They sprinted non-stop at 20–34 studs/s, never stopped to fight, and paused only briefly at chests. 10 of 30 hits landed.
- Telegraphs land 0.4–0.7 s after the windup, which is too fast to walk out of. **Blink dodge**: an instant forward-only step (≤ 25 studs, ground + no-fence check) out of any `FieldRaidCombat.Contains` hit within 1.2 s. It runs on the event and again just before the strike. IceBarrage `Points` become one circle per pulse.
- The cow never stops: it sprints, bites mobs and wheat only while passing, and no longer stands and fights.
- Max field: it roams the whole max field (from the `FieldRaidLayout.Band` entry line to the far edge) but never goes back into an earlier field. Lateral sweep passes and wheat-cluster seeking.
- Live: a fresh run went L1→L10 in about 500 s at 13/13 hearts. At L10 it farmed for 8 min, 6.94B → 27.2B bag (~2.5B/min), with no hearts lost and no deaths.

## Exits (2026-11-18, round 3)
- End of run: `PrivateFieldRaids.HarvestLandings["River ferry"]["Ferry sign"].RiverExit` ("Visit harvest meadow") at (-408, 707, 28454), the far edge of field 10. Firing it sends `Notice` "Riverbank reached..." and `Leaving`. The player then has `CowFieldRaidRewardRoom = <run>` and `CowFieldRaidId = nil`.
- Harvest meadow: the gold chest is `CowWorld.Dynamic["Harvest chest"]...OpenHarvestChest` (`RaidChestOwner` = us, `RaidChestTier` 3). Back to town: `HarvestLandings["Harvest meadow"]["Meadow gate"]["Town sign"].HomePrompt` ("Return to town").
- Loot Runs: after the last chest plot within Max Field, keep going forward to the ferry, then the meadow (gold chest, then Return to town), then auto start. Live: L1→L10 → ferry fired at 13/13 hearts. In the meadow the hub started walking to the gold chest; the chest opening and Return to town are not verified yet (auto was switched off mid-step).
- Manual Bank & Leave uses the nearer exit (ferry or Mill gate).
