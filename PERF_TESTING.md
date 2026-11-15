# Performance Testing

How to measure client memory, CPU and network for the Cow game and CowHub. All scripts only observe: they
never fire remotes or change game state (except the runner, which loads the hub and can turn on `Toggle_Farm`).
Earlier results are in `.gsd/milestones/perf-audit/FINDINGS.md`.

## Paths

| What | Mac path |
|------|----------|
| Executor workspace | `~/Opiumware/workspace/` |
| Perf logs | `~/Opiumware/workspace/cowhub/perflogs/` |
| Autoexec (runs on every injection) | `~/Opiumware/autoexec/` |
| Hub Rayfield config | `~/Opiumware/workspace/Rayfield/Configurations/CowHub/CowHubConfig.rfld` |

Copy a script from `luascripts/` into `~/Opiumware/workspace/cowhub/` before running it with `readfile`.

## Tools (`luascripts/`)

| Script | Use | Output |
|--------|-----|--------|
| `perf_monitor.lua` | 1 s samples: FPS, frame times, memory by tag (`M` lines), instances, remotes, per-frame connections. `_G.CowPerfMonitor.Mark("label")`, `.Stop()` | `perf_<time>_<id>.log` + `_summary.json` |
| `perf_heap.lua` | One-off Lua heap breakdown by table shape / function owner. Heavy: one `getgc(true)` pass, so run it at the end of a window | `heap_<time>.json` |
| `conn_probe.lua` | Heartbeat / RenderStepped connections grouped by owning script | `conn_probe_*.json` |
| `perf_leak.lua` | Opens and closes menus to check UI growth | perf marks |
| `perf_ab.lua`, `perf_calibrate.lua`, `perf_join.lua`, `perf_river.lua` | Graphics A/B, byte calibration, join timeline, river load probe | see each header |
| `memtest_runner.lua` | Automated A/B series, one run per client session (below) | `cowhub/memtest/runner.log` + perf logs |

Manual start: `loadstring(readfile("cowhub/perf_monitor.lua"))()`.

## Automated memory A/B (`memtest_runner.lua`)

1. Back up the hub config: `cp <hub config> ~/Opiumware/workspace/cowhub/memtest/CowHubConfig.rfld.bak`.
   The runner deletes the config before each run so saved toggles (rafting, ESP, mob aura...) don't skew results.
2. Copy the runner: `cp luascripts/memtest_runner.lua ~/Opiumware/workspace/cowhub/memtest_runner.lua`.
3. Write `~/Opiumware/workspace/cowhub/memtest/state.json`. Use commit-pinned raw URLs so you know which code ran:
   ```json
   {"idx":1,"duration":600,"settle":30,"runs":[
     {"name":"clean"},
     {"name":"old_idle","hub":"https://raw.githubusercontent.com/SatoruTsukino/cowhub/<old-hash>/luascripts/cowhub.lua"},
     {"name":"new_idle","hub":"https://raw.githubusercontent.com/SatoruTsukino/cowhub/<new-hash>/luascripts/preview.lua"},
     {"name":"new_farm","hub":"https://raw.githubusercontent.com/SatoruTsukino/cowhub/<new-hash>/luascripts/preview.lua","farm":true}]}
   ```
4. Install the autoexec stub:
   `echo 'loadstring(readfile("cowhub/memtest_runner.lua"))()' > ~/Opiumware/autoexec/zz_cowhub_memtest.lua`
5. For each run: start a fresh client, join, inject, leave it idle at spawn. A run takes ~12 min
   (30 s settle + 600 s sample + heap scan). When `runner.log` shows `"ev":"done"`, restart the client.
   `tail -f ~/Opiumware/workspace/cowhub/memtest/runner.log`
6. Clean up: remove `~/Opiumware/autoexec/zz_cowhub_memtest.lua` and `state.json`, then restore the config backup.

Rules that keep runs comparable:
- Fresh client per run. Memory climbs in steps as areas stream in and stays up, so session length and visited areas confound results.
- Same place (spawn) and same idle state in every run except deliberate farm runs. Use the same server if possible.
- Other autoexec scripts (e.g. `perf_river.lua`) run in every run. Leave them alone or remove them for the whole series.

## Reading results

`M` lines in the perf log are memory by `Enum.DeveloperMemoryTag` in MB. Compare the median of the last 5 min of each run:
- **Total / Internal**: overall client memory.
- **LuaHeap**: script memory (hub tables, getgc churn).
- **GraphicsTexture / GraphicsMeshParts / Sounds**: loaded assets (what `PreloadAsync` inflates).
- **Gui**: PlayerGui instances (menus never destroyed).

Reference (FINDINGS.md): clean client 3.2–3.8 GB in the field, LuaHeap 410–560 MB. Old cowhub sessions 4.6–4.75 GB, LuaHeap ~700 MB.
