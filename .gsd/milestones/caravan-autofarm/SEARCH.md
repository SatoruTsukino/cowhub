# Manual Search Checklist (hand results back to Claude)

Dumps live in `~/Opiumware/workspace/*_82507849398215_Source.txt`.
For each item, send back **file name + line numbers**, or paste the snippet (≤ 50 lines). Skip any item that's already answered by a caravan log.

| # | Unknown | What to search | Where to look | What to send back |
|---|---------|----------------|---------------|-------------------|
| S1 ✅ | GrumpyMoo style id (U2): **`"Grumpy"`**, no unlock (CowExpressions L244, L460) | `IsMooStyle`, `GrumpyMoo`, `Grumpy` | `CowExpressions` ModuleScript (not dumped yet; dump it with module_finder / the dumper) | The `IsMooStyle` function, the list of moo style ids, and any owned/unlock check |
| S2 | Caravan event remote (U1) | `:HandleEvent(`, `CaravanController`, `Caravan` near `OnClientEvent` | The client bootstrap that requires controllers (e.g. `CowGameClient` init / `ClientMain`), the `Config` Remotes list | The remote name whose `OnClientEvent` calls `CaravanController:HandleEvent` |
| S3 | Crate kick targeting (U3) | `Crate`, `CrateKickPrompt`, `CaravanCrate`, `Bay`, `InReach`, `Reach` | `KickFeedback`, `KickPrediction` ModuleScripts | How a kick picks a crate (Target / Position) and the reach distance |
| S4 | Barrel bite range + cooldown (U4) | `Cooldown`, `Reach`, `BiteRange`, `MaxDistance`, `CaravanBarrel` | `AppleSupplyRules`, `InputController` (near L640, L1179), `Config` (Chomp/Bite section) | The `AppleSupplyRules.Cooldown` value and the bite reach number |
| S5 | Caravan speed | `Speed`, `StopDistance`, `EventLength` | `CaravanConfig` has none, so this is server-side; skip unless a shared module sets it | A number, if one exists. Otherwise the caravan log covers it |
| S6 | Guide model (U5), only if the log shows `src=route` | `SeatGuide`, `CaravanGuide`, `Hitbox` | `CaravanModels` ModuleScript | The `SeatGuide` function |

Fastest way, from the workspace folder:
```bash
grep -n -E 'IsMooStyle|GrumpyMoo' *CowExpressions*            # S1
grep -ln 'HandleEvent' *.txt                                  # S2 → then open the hit near "Caravan"
grep -n -E 'Crate|Reach|InReach' *KickFeedback* *KickPrediction*   # S3
grep -n -E 'Cooldown' *AppleSupplyRules*                      # S4
```
