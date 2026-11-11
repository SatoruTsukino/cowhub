---
name: perf-audit
version: v0.1
status: executing
created: 2026-11-10T00:00:00Z
---

# Milestone: Game Performance Audit

> **Status:** ✅ Monitor built; 3 captures (incl. clean no-cowhub) analysed in FINDINGS.md.

## Vision
Measure how the Cow game uses the network, the client CPU/GPU and memory, then write evidence-backed
suggestions the user can pass to the developers. Everything is observation only. The monitor never
fires a remote, moves the character or changes game state.

## Goals
1. Passive monitor script (`luascripts/perf_monitor.lua`) that records:
   - outgoing `FireServer` / `InvokeServer` per remote and per action (first string arg): rate, est. bytes, repeated identical payloads, and whether the call came from the game or from an executor script (`checkcaller`)
   - incoming `OnClientEvent` per remote and per action: rate, est. bytes, duplicates
   - client frame stats every second: FPS, worst frame, Heartbeat/physics/render times, net send/recv kbps, ping, memory by tag, instance and primitive counts
   - instance churn in `workspace` (adds/removes per second, by class and top-level model)
   - a periodic render census (parts, meshes, shadows, lights, particles, beams, GUIs, sounds, humanoids, animation tracks)
2. Logs in `cowhub/perflogs/` (executor workspace, read from the Mac at `~/Opiumware/workspace/cowhub/perflogs/`).
3. Analysis of captured logs plus the decompiled client (`Place_…_Folder_CowGameClient_*.txt`) into `FINDINGS.md`: what is excessive, why, and the concrete fix to suggest.

## Non-Goals
- Changing game behaviour, throttling remotes or "fixing" anything client-side.
- Server-side profiling. The server is only seen through what reaches the client.
- Adding the monitor to `cowhub.lua` / `preview.lua`. It stays a standalone script.

## Research (2026-11-10, static)

| Source | Finding |
|--------|---------|
| CowGameClient dump | 26 `RunService.RenderStepped:Connect`, 24 `Heartbeat:Connect`, 4 `PreSimulation:Connect`, 17 `BindToRenderStep`. Per-frame work is a likely CPU cost; measure with the monitor. |
| CowGameClient dump | Remotes are not saved in the place dumps (created at runtime under `ReplicatedStorage.CowGame.Remotes`). The monitor discovers them live. |
| CowGameClient dump | Only 1 reference to `UnreliableRemoteEvent`. Cosmetic, high-rate traffic is probably on reliable remotes. To check with live data. |
| CowGameClient dump | `GrassRenderController` (~97 KB) does client-side grass. A candidate for render cost. |

## Phases
- [x] Phase 1 / Plan 1.1: Passive perf monitor script
- [x] Phase 1 / Plan 1.2: Capture sessions (rafting, autofarm, grazing, caravan, clean no-cowhub) → FINDINGS.md
- [x] Phase 2 / Plan 2.1: Graphics A/B (6), long soak (1), menu leak test (2)
- [x] Phase 2 / Plan 2.2: calibration (8), heap (9), quality sweep (7), join (3, partial: precise timeline needs autoexec)
- [ ] Phase 2 / Plan 2.3+: player count (4), events (5), MicroProfiler (10), BlueStacks mobile (11)
