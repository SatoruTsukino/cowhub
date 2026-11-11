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
  run). Either these are the game's own, or cowhub keeps its loops connected when its toggles are off. A capture in a
  fresh server without cowhub loaded will tell which.

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
  - **+~50 Heartbeat connections** (104–109 clean vs 150–156). They stay connected when cowhub's toggles are off.
  - **+~1.2 GB client memory** (3.2–3.5 GB clean vs 4.6–4.75 GB). Part of this may be session length (session 2 had
    run longer), but LuaHeap staying high suggests retained hub state.
  - `getfpscap()` read 60 in the cowhub sessions vs 240 clean. Check whether cowhub or a setting lowers it.

  These matter for our own scripts, not for developer feedback. Follow-up for cowhub: disconnect loops when
  their toggle is off.
- **Memory over the clean run:** 3.29 → 3.58 GB in 19 min (field → fjord → field). It moves with the area loaded. Too short to call growth.
- **Baseline client numbers for the dev report:** ~3.2–3.5 GB memory, 135k–147k instances in the field,
  ~670 instances created per second while grazing (`CowVirtualGrass`), GPU 10–12 ms average.

## Monitor caveats
- Byte counts are estimates of the Luau payload, not wire size. Roblox compresses.
- `Stats.DataReceiveKbps` reads 0 on this client, so incoming bandwidth comes from the remote estimates.
- The monitor's own census (every 60 s) costs up to ~0.8 s of work spread over frames (`monitorMs` spikes at
  t ≈ 128 and 310 s). The frame spikes in those seconds were ≤ 65 ms. Census seconds are not the cause of the 170–230 ms hitches.

## Next captures (Plan 1.2)
1. Idle in the main field with cowhub **off**, 10 min, to get a clean baseline.
2. Caravan start → loot, with `Mark()`.
3. A 30-min session for the memory growth trend.
