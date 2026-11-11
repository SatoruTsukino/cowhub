# Perf Audit: Findings (session 1)

**Capture:** 2026-11-10. `perf_1794370315_d8f26879.log` (310 s) and `perf_1794370676_5c9fef7e.log` (ongoing,
with the render-time fix). Server had 10 players. The player was rafting; a caravan ran just before
the log started. cowhub was running at the same time. Its traffic is tagged `ours` and left out below:
in this capture only `CowTownAuctionRequest`, about 0.2/s.

Client: macOS, viewport 860×1052, quality Automatic, 60 FPS cap.

## Headline numbers

| Metric | Value | Comment |
|---|---|---|
| FPS | avg 58.3, p50 60 | Fine on average |
| Worst frame per second | p50 18 ms, p95 57 ms, max 230 ms | Visible hitches. The cause is below. |
| GPU frame | 8–16 ms (render CPU 3–9 ms) | GPU-bound: up to the whole 16.6 ms budget at a small viewport |
| Client memory | 4.5 → 4.7 GB | **Very high.** LuaHeap 703 MB, Internal 1.19 GB, GraphicsTexture 177 MB |
| Instances in DataModel | 105k–148k | Streaming is on, but counts stay high |
| Incoming remote msgs | avg 51/s, peak 242/s | Mostly grass and animal snapshots |
| Incoming bytes (estimated) | p50 7 KB/s, peaks 1.7–1.9 MB in one second | The peaks match the frame hitches |
| Workspace churn | avg +451 / −500 instances per s, peak 6k/s | Mostly `CowVirtualGrass` |
| Ping | 150–275 ms, 43% CV | High jitter |

## Findings, ranked by player impact

### 1. Full-state `Snapshot` pushes (≈ 900 KB each) cause 170–230 ms hitches
- `ClientEvent("Snapshot")` arrived twice in 5 min, avg payload **907 KB** (estimated). The worst frames in the
  log (t = 46.6, 166, 286 s) are the seconds with 1.7–1.9 MB incoming.
- Client code (`CowGameClient`, around L131 / L1951 / L10000 / L28319 / L31482 / L68837) has at least 6 handlers that
  each take the whole snapshot. Every one walks the full table in the same frame.
- **Suggest:** send deltas after the first join snapshot. If a full resync is needed, split it into
  sections (`Profile`, `Crafting`, …), send them over several frames, and let each controller apply only its
  own section. Deep-copying or JSON-decoding a ~1 MB table on the main thread is the hitch.

### 2. `SnapshotRequest` → `SnapshotReply` polling: 47 KB every ~4 s
- 73 request/reply pairs in 300 s (0.24/s), avg reply **47.7 KB**. That is ~11.6 KB/s, which on its own is
  more than all other incoming traffic at p50.
- **Suggest:** push changes instead of polling, or reply with a diff against the client's last
  `ObservationAck` / baseline token (the CowTownAuction menu already uses a `Baseline.Token` pattern, L129331).

### 3. Grass streaming creates and destroys instances instead of reusing them
- `CowVirtualGrass` added **83,741 instances in 5 min (~280/s)**: MeshPart, Part, SpecialMesh, WedgePart. Matching
  removals. Churn spikes of 3–6k instances per second line up with 100–165 ms frames (t = 46–58 s).
- Grass traffic: `GrassChunkSnapshot` 5/s avg (peak 22/s, ~2 KB each), `GrassStateBatch` 7.5/s,
  `GrassChunkEvict` 4/s (peak 22/s), `GrassConsumed` 1.3/s.
- **50% of `GrassChunkEvict` messages are byte-identical to the one before** (605 of 1215). The server
  sends the same evict more than once.
- **Suggest:** (a) pool grass blade parts. Move or reparent them, or use one `MeshPart` per chunk, or
  `EditableMesh`. Don't `Instance.new`/`Destroy`. (b) Remove duplicate evicts on the server. (c) Merge chunk
  snapshot, evict and state into one per-tick message. (d) Send grass over an `UnreliableRemoteEvent` with a
  `buffer` payload. It is cosmetic and the client can recover from a dropped message.

### 4. Reliable table-based animal snapshots
- `DogSnapshot` 4/s and `BarnCatSnapshot` 2.4/s are sent as Lua tables over reliable RemoteEvents (150–220 B each).
  `Motion` already does this well: an `UnreliableRemoteEvent` with a `buffer`, 22/s at 98 B.
- **Suggest:** move Dog/Cat/Goat/Bunny snapshots onto the `Motion`-style unreliable buffer path. Reliable
  ordering for cosmetic positions builds up a backlog under the 150–275 ms jittery ping above.

### 5. One `ClientEvent` remote with 25 listeners
- `ClientEvent` has **25 `OnClientEvent` connections** (getconnections, live). Every message (≈ 40/s) runs all
  25 Lua handlers, and most of them just compare `arg1` with a string and return. That is ~1,000 handler calls
  per second, and each is passed the full payload.
- **Suggest:** one dispatcher (`arg1 → handler` table) or separate remotes per subsystem.

### 6. GPU load: shadows, lights, mesh fidelity
- Census: **22–26k shadow-casting parts**, `GlobalShadows` on, `Technology = ShadowMap`,
  `PrioritizeLightingQuality = true`, 84–132 enabled PointLights, 2.2–4.7k MeshParts with
  `RenderFidelity = Precise`, Bloom + 2 ColorCorrection on. GPU 8–16 ms at a small window.
- `LocalFjordAurora` added 5.9k instances and 2,090 Beams at one point (census 5).
- **Suggest:** `CastShadow = false` on grass, small props and debris. `RenderFidelity = Automatic` on
  decorative meshes. Turn off PointLights by distance. Make the aurora one texture/beam set, not thousands
  of beams. Let the graphics quality setting lower these.

### 7. Memory: 4.6 GB client, 703 MB Lua heap
- Climbed 4.52 → 4.70 GB over 5 min while rafting. LuaHeap 703 MB is very large for one client.
- Likely contributors: retained full snapshots (finding 1), grass state tables, 7.8k visible GuiObjects across 95
  ScreenGuis (51 enabled), 28 ViewportFrames.
- **Suggest:** destroy closed menus instead of hiding them, reuse snapshot tables, and check for snapshot
  history being kept. A longer capture (30+ min) is needed to tell growth from a plateau.

### 8. Per-frame callbacks
- Live: **~155 Heartbeat and ~62 RenderStepped connections** (cowhub and this monitor add some; the game's own
  dump has 24 + 26 + 17 BindToRenderStep). Heartbeat time is fine at p50 2.3 ms, but the worst Heartbeat in a second
  is often > 50 ms.
- **Suggest:** one scheduler that updates far or offscreen systems (grass render, animals, aurora) at lower rates.

### 9. Client telemetry remotes (informational)
- `SessionPerformanceReport` (~2 KB, 9 of 10 payloads identical), `PlayerSignalReport` (1.6 KB), and
  `SessionChatReport` go out about every 30 s. Low cost; the repeated identical perf reports could be skipped.

## Session 2: 30-min capture, by activity (`perf_1794370676_5c9fef7e.log`)

Segments come from `Mark()` lines. Caravan phases were marked automatically: Supply OnRoad at t = 440 and t = 1568,
Stopped at t = 1732.

| Segment | Secs | FPS | Worst frame avg / p95 | Hitches > 100 ms | GPU ms avg / p95 | Render CPU ms | In msgs/s | In KB/s (avg) | Instances |
|---|---|---|---|---|---|---|---|---|---|
| Rafting, cowhub on | 335 | 57.9 | 36 / 92 | **2.7 / min** | 12.3 / 16 | 3.4 | 48 | 37 | 104k |
| Autofarm, cowhub on | 444 | 58.9 | 26 / 48 | 0.8 / min | 13.9 / 17 | 3.8 | 44 | 24 | 128k |
| Grazing, cowhub off | 650 | 58.6 | 28 / 58 | 0.7 / min | **14.8 / 19** | **5.9** | **68** | 37 | 131k |
| Rafting, cowhub off | 387 | 58.6 | 26 / 48 | 0.5 / min | 12.5 / 19 | 4.2 | 41 | 30 | 102k |

### What the 30-min run adds
- **GPU is the main steady-state limit.** It averages 12–15 ms and reaches p95 16–19 ms against a 16.6 ms budget,
  and it is worst in the main field: up to 26k shadow-casting parts and 132–138 lights enabled when the census
  ran there (t ≈ 917–1040). In the fjord, `LocalFjordAurora` keeps **2,088 Beams** loaded the whole time.
  Finding 6 stands. Shadows, lights and aurora beams are the GPU levers.
- **Grazing triggers frequent `Snapshot` pushes.** With cowhub off, `ClientEvent("Snapshot")` arrived **1.7/s
  (1,109 in 650 s, ~7.5 KB each, 12.4 KB/s)**. That is a full-state message for what are probably
  coin/hunger/XP changes per bite. It goes with `GrazeResult` 2.2/s and `AuraBiteStarted` 2.1/s. **Suggest:** send
  only the changed fields (e.g. `ProfileDelta`). With finding 1 (≈ 900 KB snapshots), this makes `Snapshot` the
  biggest single fix.
- **Duplicate resends on the server:**
  - `CraftingSnapshot` arrived identical to the previous one **every time** (17 / 17 while rafting, ~85 KB each window).
  - `RaftYard` 97% identical (34 / 35).
  - `GrassChunkEvict` 45–66% identical in every segment.
  - `GrassConsumed` 86% identical while autofarming.
  - `RaftingSnapshot` 27% identical, at 3.6/s.

  **Suggest:** compare against the last sent value on the server and skip unchanged messages.
- **`SnapshotReply` size depends on the area:** ~60 KB per reply in the fjord (≈ 15 KB/s at 0.25/s), ~10 KB in
  the field. `RaftRiverLoad` is ~28 KB, 0.2/s. River chunk payloads would be a good fit for `buffer` encoding.
- **Memory is a plateau, not a leak.** 4.6–4.75 GB the whole run. LuaHeap stays at 656–710 MB and drops back after
  leaving the field. The absolute size is still very high (finding 7).
- **Hitches with cowhub on while rafting** (2.7/min, vs 0.5/min with cowhub off) include the very large
  fjord loads at the start of the run. It is not clear that cowhub caused them. Repeat with cowhub fully
  unloaded before blaming either side.
- **Callback counts don't change when cowhub is turned off** (Heartbeat 150–156, RenderStepped 59–64 the whole
  run). Session 3 and the connection probe show cowhub does not keep loops connected when toggled off (see below).

## Session 3: clean capture, cowhub never loaded (`perf_1794372688_d1883dd4.log`)

Fresh client (new Roblox process), same server (JobId 6f9973ee…), 7 players. Only this monitor was running.
FPS cap is **240** (`getfpscap()` = 240; the cowhub sessions read 60). The client only reached **~100 FPS (p95 ~120)**,
so it is render-bound at ~10 ms per frame (GPU 10–12 ms, render CPU 7–8 ms), well below the cap. Compare frame *times*, not FPS.

| Segment | Secs | FPS | Worst frame avg / p95 | Hitches > 100 ms | GPU ms avg / p95 | Render CPU ms | Memory | In msgs/s |
|---|---|---|---|---|---|---|---|---|
| Grazing 1 | 202 | 97 | 22 / 36 | 0.6 / min | 11.6 / 16 | 8.1 | 3.29 GB | 55 |
| Rafting (+ Supply caravan t = 489–681) | 548 | 99 | 24 / 44 | **1.2 / min** | 9.7 / 19 | 7.2 | 3.19 GB | 38 |
| Grazing 2 | 384 | 102 | 24 / 36 | 0.8 / min | 9.8 / 13 | 7.4 | 3.53 GB | 59 |

### Clean vs cowhub sessions
- **The game's own findings hold without cowhub.** Grazing still gets full `Snapshot` pushes (0.9–1.4/s;
  in grazing 2 **526 pushes in 384 s, 11.5 KB avg, 15.3 KB/s**, the biggest single incoming stream in the field). `SnapshotReply` is ~35 KB in the field and ~64 KB in the fjord, every 4 s.
  `RaftRiverLoad` is ~31 KB. `CraftingSnapshot` is 36 KB and identical every time (7 / 7 while rafting).
  `RaftingSnapshot` is 28% duplicates and `GrassChunkSnapshot` 36% duplicates in the fjord. The aurora keeps its
  2,088 Beams and the field has 21–31k shadow-casting parts with 96–148 lights.
- **Rafting hitches are the game's.** 1.2 per min clean. The 2.7 per min with cowhub came from big fjord loads,
  not from cowhub.
- **cowhub's own cost, measured:**
  - ~~+~50 Heartbeat connections that stay connected when toggled off~~ **Disproved** (connection probe,
    `cowhub/conn_probe.lua`, grouping `getconnections` by owning script). Clean 104 Heartbeat / 59 RenderStepped;
    cowhub loaded, all toggles off: 105 / 59; features on: 110 / 63 (main loop L6413, raft L13001/L13013, chest ESP
    L4460, + 4 from another loaded chunk, likely the UI library); features off: 108–109 / 62–63. The main loop and
    raft loops disconnect. Chest ESP's Heartbeat stays only while `chestESP.show` is true (it calls `cleanup()` on
    its first frame with `show` false), so it was still ticked. The 150–156 seen in session 2 did not come from
    cowhub's toggled-off loops. Its source is unknown; that session ran 30+ min on a long-lived client.
  - **+~1.2 GB client memory** (3.2–3.5 GB clean vs 4.6–4.75 GB). Part of this may be session length (session 2 had
    run longer), but LuaHeap staying high suggests retained hub state.
  - `getfpscap()` read 60 in the cowhub sessions vs 240 clean. Check whether cowhub or a setting lowers it.

  These matter for our own scripts, not for developer feedback. No loop-lifecycle fix needed in cowhub.
- **Memory over the clean run:** 3.29 → 3.58 GB in 19 min (field → fjord → field). It moves with the area loaded. Too short to call growth.
- **Baseline client numbers for the dev report:** ~3.2–3.5 GB memory, 135k–147k instances in the field,
  ~670 instances created per second while grazing (`CowVirtualGrass`), GPU 10–12 ms average.

## Session 4: graphics A/B at spawn (`ab_*.json`, Plan 2.1 test 6)

Spawn area (-1842, 708, 308), 6 players, camera locked, 30 s per window, baseline windows before and after each
variant. FPS sat at ~120 the whole run, so the display or cap limit was reached before the GPU limit. Costs here
are what each feature would save if the GPU were the limit. All changes were restored and checked afterwards.

| Variant | Changed | GPU Δ ms (base) | Render CPU Δ ms | Baseline spread ms | Read |
|---|---|---|---|---|---|
| Atmosphere density 0 | 1 (game reset it 29×) | **+4.66** (10.3) | **+2.26** | 1.6 | Fog is acting as distance culling: without it far terrain and props are drawn. Keep it; tune `Atmosphere` instead of lowering it. |
| Point/Spot lights off | 59 | −1.08 (8.5) | −0.56 | 2.0 | Likely real but within noise at spawn; repeat in the field (84–148 lights) |
| Bloom off | 1 | −0.67 (9.2) | −0.23 | 1.4 | Small |
| GlobalShadows off | 1 | −0.59 (8.6) | −0.04 | 0.6 | Small at spawn |
| ColorCorrection off | 2 | −0.45 (10.5) | −0.46 | 1.2 | Within noise |
| CastShadow off (all parts) | 16,724 (+373 streamed in) | −0.27 (8.4) | −0.03 | 0.2 | Small at spawn |
| Beams off | 17 | −0.17 (7.1) | −0.05 | 0.7 | Spawn has 17 Beams; the 2,088 aurora Beams are in the fjord |
| Particles off | 59 | −0.04 (6.8) | −0.06 | 0.0 | None |

Takeaways:
- At spawn no single feature costs more than ~1 ms of GPU. The baseline itself moved between 6.8 and 11.1 ms over
  the run, more than most effects. The field and the fjord are where the cost is, so the test has to be repeated there.
- **Atmosphere is a net saving.** Turning its fog off cost +4.7 ms GPU and +2.3 ms render CPU. Suggest to the devs:
  don't drop `Atmosphere` on low settings; use its density / haze as the cheap draw-distance limit.
- A game controller keeps resetting `Atmosphere` (29 resets in 30 s) and lights (29), which fits the zone grading
  controllers re-applying their settings every second.

## Session 5: graphics A/B in the field (`ab_*.json`, label `field`)

Field (-409, 709, 455), camera locked, 60 s per window. FPS 84–118 (cap 240), so here the GPU is the limit.
The baseline still drifted between 9.4 and 12.8 ms GPU over the 18 min, so "spread" (the gap between the two
baselines around each variant) is the noise bar for that variant.

| Variant | Changed | GPU Δ ms | Render CPU Δ ms | Frame Δ ms | Spread (GPU / CPU) | Read |
|---|---|---|---|---|---|---|
| CastShadow off (all parts) | 34,071 (+284 streamed in) | **−2.48** | −1.05 | −0.45 | 2.85 / 1.34 | Lowest GPU of the run (8.85 ms vs every baseline ≥ 9.44). Likely −1 to −2.5 ms. |
| Bloom off | 1 | **−1.87** | −0.89 | −1.05 | 1.17 / 0.59 | Real, ~1–2 ms |
| Point/Spot lights off | 146 | −1.13 | −0.25 | −0.13 | 1.55 / 0.39 | Within noise again |
| GlobalShadows off | 1 | −0.67 | **−1.09** | **−1.05** | 0.10 / 0.30 | **Most reliable result**: ~1 ms per frame, mostly render CPU |
| Beams off | 17 | −0.59 | −0.74 | −0.57 | 0.57 / 0.06 | Small (only 17 Beams here) |
| Atmosphere density 0 | 1 (reset 59×) | −0.59 | −0.29 | −0.49 | 1.03 / 0.88 | Neutral in the field, vs +4.7 ms at spawn: the fog only saves where the view is long |
| Particles off | 9 | −0.32 | −0.12 | +0.10 | 0.90 / 0.41 | None |
| ColorCorrection off | 2 | +0.73 | +0.79 | +0.96 | 1.28 / 1.21 | None (noise) |

Takeaways for the dev report:
- **Shadows are the biggest lever in the field:** per-part `CastShadow` on 34k parts costs about 1–2.5 ms GPU, and the
  global shadow pass about 1 ms of frame time on its own. Turning `CastShadow` off on grass, small props and debris
  keeps the look and recovers most of it.
- **Bloom costs ~1–2 ms GPU.** Worth a lower-quality toggle.
- Lights, Beams (in the field), particles and color correction are each under the noise floor (~1 ms).
- After the restore, 1 light and 1 Beam read disabled; spawn read 0 / 0 before the run, so these are most likely
  game-controlled (a zone controller), not left over from the test. Everything else matched.

## Session 6: menu leak test (`perf_leak.lua`, `conn_probe_leak*_*.json`)

Each menu opened and closed 10× through the game's own controllers (`NavigationController:Open(tab)` / `:Close()`,
`SkinAuctionController`, `RaftYardController`, `GardenController`; `PlayerMailController` had no instance). A
snapshot after GC followed each menu.

| Point | PlayerGui instances | Gui memory | Visible GuiObjects | Lua heap |
|---|---|---|---|---|
| Before | 11,405 | 75 MB | 7,056 | 485 MB |
| After Closet ×10 | 29,940 | 121 MB | 19,771 | 529 MB |
| After CosmeticIndex ×10 | **54,206** | **181 MB** | 34,329 | 511 MB |
| After the other 7 tabs | 35,882 | 138 MB | 21,745 | 501–535 MB |
| After auction / raft yard / garden (+4 ScreenGuis) | 37,060 | 137 MB | 22,065 | 507–540 MB |
| Pass 2: Closet, CosmeticIndex ×2 each | 55,374 (flat on repeats) | 183 MB | 34,651 | 509–550 MB |

- **No per-cycle leak.** Repeating Closet / CosmeticIndex stays flat at 55,374 instances. Per-frame connections
  stayed at 105–108 Heartbeat / 59–60 RenderStepped the whole test, and `ClientEvent` stayed at 21 listeners.
- **But the cosmetics UI is never released.** Opening Closet or CosmeticIndex once builds **18–43k GUI instances
  (+46–108 MB Gui memory)**. They stay in `PlayerGui` after the menu closes, still marked `Visible` (34k visible
  GuiObjects with every menu closed). The client never got back to its 11.4k / 75 MB starting point. This is the
  biggest single UI cost found.
- **Suggest:** build the cosmetic grid lazily and virtualise it (only the rows on screen, reused as you scroll), and
  destroy the grid when the menu closes or after a timeout. Or at least parent it to `nil` / disable its ScreenGui when
  closed, so layout and memory don't carry it.
- Skin auction and raft yard each create a ScreenGui once and keep it (+2 each). Small, cached, fine.

## Session 7: 90-min long session (`perf_1794378042_352f17ea.log`, Plan 2.1 test 1)

One client, no cowhub, 90 min on one server (6 players): spawn A/B (0–600 s), field A/B (~900–2000 s), menu
leak test (~2370–3000 s), then normal play with auto-marks (grazing, fishing, river swim, caravan, rounds).
The connection owners were probed every 5 min.

| Time | Memory | Instances | LuaHeap | Gui | Internal | Heartbeat / RenderStepped |
|---|---|---|---|---|---|---|
| 0 min (spawn) | 2.82 GB | 96k | 411 MB | 33 MB | 735 MB | 104 / 60 |
| 15 min (field loaded) | 3.31 GB | 141k | 479 MB | 74 MB | 986 MB | 101 / 59 |
| 40 min (before menu test) | 3.49 GB | 144k | 518 MB | 76 MB | 1,004 MB | 106 / 59 |
| 50 min (after cosmetics UI) | 3.78 GB | 188k | 514 MB | 183 MB | 1,028 MB | 105 / 60 |
| 60–85 min (normal play) | 3.74–3.80 GB | 182–185k | 521–556 MB | 184 MB | 1,032–1,043 MB | 106–109 / 60–61 |
| 90 min | 3.74 GB | 166k | 546 MB | 140 MB | 1,039 MB | 106 / 61 |

- **No leak over 90 min.** Memory rises in steps when content loads (+0.5 GB when the field streams in,
  +0.3 GB for the cosmetics UI), then stays flat (3.74–3.80 GB for the last 40 min). Per-frame connections stay
  flat at 101–109 Heartbeat and 59–61 RenderStepped. `ClientEvent` went 21 → 22 listeners only because the
  auto-marker connected one.
- **The cosmetics UI is the one avoidable step:** +108 MB Gui and +44k instances held until about the 90 min
  point, when Gui memory dropped to 140 MB, so some of it is released eventually.
- **The 150+ Heartbeat seen in session 2 did not reappear.** That was a different, long-lived client that also had
  cowhub loaded. It stays unexplained, but it is not the game growing over time.

## Session 8: Plan 2.2: byte calibration, heap breakdown, quality sweep (tests 8, 9, 7)

### Byte calibration (`calibrate_*.json`, 120 s, field)
| Counter | Per second |
|---|---|
| `totalBytesReceived` (wire) | **32.3 KB/s** (NetStream 28.2 KB/s) |
| Remote payload estimate (monitor) | 17.2 KB/s, 32 msgs/s |
| `totalBytesSent` (wire) | 6.9 KB/s, 65 packets/s |
| Remote payload estimate, outgoing | 0.1 KB/s |
| Dropped packets | 12 in 120 s |

- Received bytes / remote estimate = **1.88**. Remote events are about half of downstream traffic; the rest is
  instance and property replication (streaming, animals, players). The KB/s figures in this file are remote payloads
  only. Multiply by ~1.9 for total downstream.
- Outgoing is nearly all character replication and acks (remotes are under 2% of sent bytes).

### Lua heap breakdown (`heap_*.json`, LuaHeap 530 MB)
`getgc(true)`: 1.42M objects: 172k tables (1.46M entries), 39k functions, 189k userdata. Strings and buffers are not
returned by `getgc`, so the tables below are probably ~50–100 MB of the 530 MB.

| Table shape (keys) | Tables | Entries | Share | What it likely is |
|---|---|---|---|---|
| plain arrays | 49,367 | 654,635 | 44.9% | lists inside everything below |
| `CreatedAt, CreatorName, CreatorUserId, SkinId, Source, UUID` | **16,668** | 116,676 | 8.0% | skin item records (inventory / market listings) |
| `Count, Max, Mean, P50, P90, QuantileSamples` | 2,382 | 14,292 | 1.0% | performance telemetry stats kept in memory |
| `AttemptId, Build, Journey, Outcome, Second, Source` | 1,188 | 13,068 | 0.9% | journey / attempt telemetry |
| `At, Key, Ms(, Reason)` | 2,515 | 8,639 | 0.6% | timing logs |
| `Deaths, GrassBites, HayPortions, ItemsCrafted, …` | 564 | 8,460 | 0.6% | session stat snapshots |
| `AppliedGrassRendering, AppliedGroundPosition, …` (several) | ~1,400 | ~45,000 | 3.1% | grass / plant state per cell |
| `Cells, Index, Kind, Moved, Part, Resized` | 2,127 | 17,016 | 1.2% | grass chunk records |

Functions by owning script: `InstanceUtil` 3,939, **`CosmeticIndexCard` 2,894**, `CowGrowthVisual` 2,808,
`BirdPerchCatalog` 2,385, `CowRig` 2,274, `AccessibilityController` 1,492, `CosmeticIndexPage` 827. The cosmetics
UI closures are still alive long after the menu closed, matching session 6.

Suggest: page skin records instead of holding ~16.7k at once; cap telemetry history (ring buffers, send and drop);
release the cosmetic index cards on close.

### Quality sweep (`ab_*.json`, label `quality`, field, 60 s windows)
| Fixed level | GPU ms (vs Automatic) | Render CPU ms | Frame ms | FPS p50 |
|---|---|---|---|---|
| Automatic (baseline, 6 windows) | 8.0–11.3 | 6.8–8.1 | 8.4–11.1 | 91–120 |
| 1 | 5.71 (−3.70) | 6.77 (−1.10) | 8.43 | 120 |
| 3 | 4.88 (−3.83) | 6.25 (−1.04) | 8.50 | 120 |
| 5 | 4.88 (−4.84) | 5.95 (−1.48) | 8.49 | 120 |
| 7 | 5.29 (−5.21) | 5.92 (−1.79) | 8.54 | 120 |
| 10 | 5.75 (−3.13) | 7.06 (−0.61) | 8.41 | 120 |

- **Every fixed level from 1 to 10 hits the 120 FPS limit (8.4 ms frame) with the GPU at ~5–6 ms.** Automatic sits
  4–5 ms higher and drops to 91–112 FPS. On this Mac, Automatic picks a level above 10 (the engine has 21 internal
  levels), and that extra level is what costs the frames.
- Levels 1–10 barely differ from each other here, and the primitive count did not change (~61k) at any level: on
  this client the quality setting is not reducing what is drawn, only how it is shaded. The game's own content
  (shadow casters, lights, the aurora) should scale with quality too. See the A/B results.
- Levels above 10 were not tested. That would be the next step to find where Automatic lands.
- Quality was restored to Automatic and the camera to Custom (checked).

### Join (test 3, autoexec run, `join_*.json`)
`perf_join.lua` ran from the executor's autoexec at injection. Roblox could not be quit from here, so this is again an
in-place rejoin in the same process and server (5 players). Assets were already cached, so the times are a best case.

| Stage | Since join | Received (cumulative) | Instances | Memory |
|---|---|---|---|---|
| Loaded | 2.31 s | 10.5 MB | 59,590 | 2.95 GB |
| Character | 3.40 s | 10.6 MB | 60,075 | 3.01 GB |
| First `Snapshot` | 3.48 s | 12.4 MB (**+1.85 MB** in 80 ms) | 60,097 | 3.03 GB |
| First grass chunk | 3.62 s | 15.0 MB (**+2.55 MB**) | 66,497 | 3.09 GB |
| Playable | 3.69 s | 15.0 MB | 66,644 | 3.10 GB |
| +30 s | 33.2 s | 17.6 MB | 100,469 | 3.31 GB |

- **The join Snapshot is ~1.8 MB** on the wire, the largest single message seen (compressed; the ~900 KB payload
  estimate from session 1 is the in-game size). With the first grass burst (+2.6 MB) that is ~4.4 MB in 0.2 s right
  as the player appears. The hitch is visible on join.
- Streaming then adds ~34k instances and 2.6 MB more over the next 30 s.

### Join (test 3, first try, `join_*.json`), partial
Rejoined through `roblox://placeId=…` with the client still open: the running process rejoined in place (same
server, JobId 6f9973ee…, 4 players). The join script could only be injected 23.8 s after the join, by which point the
player was already playable, so the stage times are bounded rather than measured.

| Point | Since join | Received (cumulative) | Instances | Memory |
|---|---|---|---|---|
| Injection (already playable) | 23.8 s | **24.4 MB** | 134,660 | 3.56 GB* |
| +30 s | 53.8 s | 25.5 MB (+35 KB/s) | 134,682 | 3.54 GB* |

- **Joining downloads ~24 MB in the first ~24 s (~1 MB/s), then traffic drops to the normal ~35 KB/s.** Playable
  in under 24 s on this connection.
- *Memory carried over from the previous session in the same process, so it is not a fresh-join figure.
- A precise stage timeline (time to character, first Snapshot, first grass chunk, playable) needs the script to run at
  injection on a fresh launch. That means putting `perf_join.lua` in the executor's autoexec folder, which needs
  the user's go-ahead.

## Session 9: Plan 2.3: event windows (test 5)

Every AUTO / manual event mark in all perf logs; 30 s after the event against the 60 s before it (averages over n events).

| Event | n | Worst frame after / before | Hitches >100 ms per min after / before | In KB/s after / before | Instances added/s after / before |
|---|---|---|---|---|---|
| **Caravan Leaving** | 7 | 122 / 92 ms | **1.4 / 0.4** | **39.5 / 17.8** | 162 / 146 |
| **Caravan Idle (packed up)** | 7 | 128 / 94 ms | **1.7 / 0.4** | **39.1 / 21.6** | 166 / 146 |
| Caravan OnRoad (spawn) | 7 | 54 / 361 ms | 0.0 / 0.7 | 8.9 / 26.1 | 179 / 122 |
| Caravan Stopped | 2 | 90 / 165 ms | 1.0 / 1.0 | 8.5 / 41.1 | 246 / 287 |
| Round start | 20 | 70 / 109 ms | 0.5 / 0.6 | 18.1 / 19.6 | 41 / 36 |
| Caravan traffic (any) | 32 | 110 / 143 ms | 0.7 / 0.7 | 21.2 / 19.6 | 33 / 29 |
| Field event start | 2 | 60 / 152 ms | 0.0 / 1.0 | 4.6 / 31.0 | 45 / 16 |

- **The caravan leaving / packing up is the one event that measurably hurts:** hitches go from 0.4 to 1.4–1.7 per
  minute and incoming traffic doubles (~18–22 → ~39 KB/s) for the 30 s after. Likely the loot / crate reveal
  messages and the convoy models being torn down at once. Suggest despawning the convoy over several frames and
  sending the loot summary as one message.
- Caravan arrival, rounds and field events show no extra hitching (their "before" windows were busier).
- n is small for some rows (2); the caravan Leaving / Idle rows (n = 7 each) are the reliable ones.

## Session 9b: player count (test 4), partial

The public server list (`games.roblox.com/v1/games/82507849398215/servers/Public`) had **one** server (5 / 16 players),
so a full vs empty comparison was not possible. The existing logs cover 4–10 players on the same server:

| Players | Log | Duration | `Motion` msgs/s | `Motion` bytes/msg | `DogSnapshot`/s | `ClientEvent` KB/s |
|---|---|---|---|---|---|---|
| 4 | perf_1794384961 | 411 s | 28.5 | 94 | 4.2 | 14.6 |
| 5 | perf_1794385383 | 657 s | 21.5 | 87 | 2.3 | 19.6 |
| 6 | perf_1794378042 | 6,885 s | 24.8 | 88 | 3.5 | 15.3 |
| 7 | perf_1794372688 | 1,143 s | 19.7 | 96 | 3.9 | 27.0 |
| 10 | perf_1794370315 | 362 s | 21.8 | 98 | 4.1 | 30.6 |
| 10 | perf_1794370676 | 1,972 s | 21.4 | 96 | 4.0 | 29.5 |

- `Motion` is sent at a fixed ~20–28/s, batched: its payload grows only ~1–2 B per extra player (87 → 98 B). This
  scales well.
- `ClientEvent` traffic is ~2× higher at 10 players (≈30 vs 15–20 KB/s), but those sessions were also mostly rafting /
  caravan, so activity and player count can't be separated with this data. To repeat when a busier server exists.

## Session 10: MicroProfiler capture (test 10, `microprofile-20261111-003850.gprx`, `scripts/mp_analyze.py`)

62 frames during a Supply caravan, all calm (median 10.0 ms, max 11.5 ms). No hitch frame was in the capture, so this
shows where the **steady** frame time goes. Read with Roblox LibMP (Python + wasmtime, scratch venv).

| Work (per frame, average) | ms | Thread | Read |
|---|---|---|---|
| Render `Perform` → `Scene` | 6.4 | RBX Main | Engine draw submission |
| ↳ `SceneUpdater::computeLightingPerform` | **2.5** | RBX Main | Largest single render scope. Lighting / light grid; fits the 84–148 lights in the field |
| ↳ `RenderView` / `UpdateView` | 2.1 / 1.7 | RBX Main | Per-view culling and draw lists |
| `Simulation` → **`gameStepped`** | **2.6** | workers | `RunService.Stepped` / `PreSimulation` callbacks (game Luau). Physics itself only 0.3 |
| `Heartbeat` → **`deferredThreads`** | **2.0** | workers | Resumed / deferred Luau threads (`task.defer`, signal handlers) |
| `RenderJob` → **`PreRender`** | **2.0** | workers | `RenderStepped` / `PreRender` callbacks (game Luau) |
| `CullJob` → `queryOcclusion` | 1.2 | workers | Occlusion culling |
| `LightGridCPU` updates | 0.4 | workers | Light grid chunks |
| Lua GC | 0.3 | workers | |

- **Game Luau takes ~6.6 ms per frame** in callbacks alone (Stepped 2.6 + deferred threads 2.0 + PreRender 2.0), while
  physics is 0.3 ms. That is the biggest CPU item and matches the 26 RenderStepped + 24 Heartbeat + 17 BindToRenderStep
  hooks in the client code (and `NPCDialogueUI`'s 15 idle RenderStepped connections). Suggest one scheduler that runs
  far / offscreen systems at a lower rate, and disconnecting idle per-frame hooks.
- **Lighting is the biggest render scope (2.5 ms)**, in line with the A/B results (shadows and lights).
- Still needed: a dump that contains a hitch frame (pause right after a tall bar) to name what fills a 100 ms+ frame.

### Second capture (`microprofile-20261111-004633.x.html`, 48 frames)
Heavier moment: median 17.0 ms, p95 21.1 ms, max 26.1 ms (no 100 ms hitch caught again).

| Main-thread scope (avg / worst frame) | ms |
|---|---|
| `Present` → **`waitOnGpu`** | **5.8 avg, up to 11.1** |
| `Scene` | 6.1 avg |
| `ShadowMapSystem::updatePerform` | **1.6–2.1** |
| `SceneUpdater::computeLightingPerform` | 1.7–2.2 |
| `RenderView` → `DefaultPass` | 1.7–2.1 |

- Here the main thread spends up to half of each frame **waiting on the GPU**, and shadow-map updates are ~2 ms of
  CPU on top. It confirms the A/B: in busy scenes the GPU (shadows) is the limit.
### Third round (10 dumps, 00:47–00:49)
Four dumps had a spike frame (68–77 ms; 004900, 004928–004931). In every one the main thread was busy only
**6.9–9.8 ms** of the spike frame, and the worker threads show no long scope either (longest ~5 ms `queryOcclusion`;
game Luau `Script_Bootstrap` ≤ 3.2 ms; `BarnCats.Client` 1.3 ms). The other ~60 ms is not in any profiled scope.
The dumps were taken one per second in a burst, so the spike is most likely the previous dump being written
(11–12 MB each) or the window losing focus, not game work. **These spikes are profiler artefacts, not game hitches.**

- The 100 ms+ hitches were not caught in either capture. They most likely come from script / instance bursts
  (join snapshot, grass churn, cosmetics UI build, caravan teardown) that the event and churn data already point to.


## Monitor caveats
- Byte counts are estimates of the Luau payload, not wire size. Roblox compresses.
- `Stats.DataReceiveKbps` reads 0 on this client, so incoming bandwidth comes from the remote estimates.
- The monitor's own census (every 60 s) costs up to ~0.8 s of work spread over frames (`monitorMs` spikes at
  t ≈ 128 and 310 s). The frame spikes in those seconds were ≤ 65 ms. Census seconds are not the cause of the 170–230 ms hitches.

## Next captures (Plan 1.2)
1. Idle in the main field with cowhub **off**, 10 min, to get a clean baseline.
2. Caravan start → loot, with `Mark()`.
3. A 30-min session for the memory growth trend.
