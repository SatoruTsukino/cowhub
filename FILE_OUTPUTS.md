# CowHub Generated Files Reference

Catalog of all runtime files generated, read, and persisted by Lua scripts within the executor `workspace/` directory.

---

## Workspace Directory Structure

```text
<executor_workspace>/
├── cowhub/
│   ├── CowScannerWebhook.txt               # Discord webhook URL for notifications
│   ├── CowHub_SessionPersistence.json       # AFK state, player position & toggles across relog
│   ├── SpiderIdentifiers.json              # Resolved mob IDs & position cache
│   ├── cowhub_raft_facades.json             # River cliff face wall geometry cache
│   ├── chomplogs/
│   │   └── chomp_<unix>.jsonl              # Chomp debug log (sends, GrazeResult, natural E events)
│   ├── companionlogs/
│   │   └── companion_<unix>.jsonl          # Companion status / bond export
│   ├── raftlogs/
│   │   └── cowhub_raft_<time>_<id>.log     # Raft navigation telemetry & sensor logs
│   └── voyagelogs/
│       ├── voyage_<time>_<id>.log          # Standalone voyage navigation telemetry
│       └── world_survey.json               # Merged river channel survey geometry
├── Rayfield/Configurations/
│   └── CowHub/
│       └── CowHubConfig.rfld               # Rayfield UI configuration & flag autosave
├── SkinHunterConfig.json                   # SkinHunter target configuration
└── SkinHunterState.json                    # SkinHunter session state & stats
```

---

## Master File Registry

| File Path in Executor Workspace | Source Script | Format | Lifecycle | Description | Legacy Path |
|---------------------------------|---------------|--------|-----------|-------------|-------------|
| `cowhub/CowScannerWebhook.txt` | [cowhub.lua](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1033), [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L1033) | Plain text (URL) | Persistent | Discord webhook URL for auction sniper & notifications | `CowScannerWebhook.txt` |
| `cowhub/CowHub_SessionPersistence.json` | [cowhub.lua](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1060), [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L1060) | JSON | Ephemeral (30m max age, deleted on resume) | Player CFrame, active farm toggles, auction bids across 6h reconnect | `CowHub_SessionPersistence.json` |
| `cowhub/SpiderIdentifiers.json` | [cowhub.lua](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1408), [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L1408) | JSON | Persistent (capped at 200 IDs, 50 history) | Unique server spider/mob identifiers indexed by ID, position, and path | `SpiderIdentifiers.json` |
| `cowhub/chomplogs/chomp_<unix>.jsonl` | [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L1765) (staging only) | JSON Lines | Per debug session (toggle on → new file) | Chomp sends, server GrazeResult replies, natural-mode E/graze events, mob re-arms, bot-check pauses | None |
| `cowhub/companionlogs/companion_<unix>.jsonl` | [companion_status_export.lua](file:///Users/jsph/cowhub/luascripts/companion_status_export.lua) | JSON Lines | Per run | CowCompanion* attribute changes, equipped companion profile record snapshots (CompanionCare.Bond, NextReward, Needs) | None |
| `cowhub/raftlogs/cowhub_raft_<time>_<id>.log` | [cowhub.lua](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10427), [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L10427) | CSV / Text | Per-session (one per voyage) | Raft telemetry: heading, cross error, PID steering, health, sensors | `cowhub_raft_*.log` |
| `cowhub/cowhub_raft_facades.json` | [cowhub.lua](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10559), [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L10559) | JSON | Persistent (cached across runs) | River channel cliff wall geometry & bounding boxes | `cowhub_raft_facades.json` |
| `Rayfield/Configurations/CowHub/CowHubConfig.rfld` | [cowhub.lua](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L60), [preview.lua](file:///Users/jsph/cowhub/luascripts/preview.lua#L60) | Rayfield Proprietary | Persistent | UI flag autosave / reload configuration | None |
| `cowhub/voyagelogs/voyage_<time>_<id>.log` | [voyage_telemetry.lua](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L635) | CSV / Text | Per-voyage | Standalone voyage telemetry recording | `cowhub/voyage_*.log`, `cowhub_telemetry/voyage_*.log` |
| `cowhub/voyagelogs/world_survey.json` | [voyage_telemetry.lua](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L471) | JSON | Persistent | Merged river channel survey geometry across voyages | `cowhub/world_survey.json`, `cowhub_telemetry/world_survey.json` |
| `SkinHunterConfig.json` | [skinhunter.lua](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L32) | JSON | Persistent | Target animal skins, price limits, webhook settings | None |
| `SkinHunterState.json` | [skinhunter.lua](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L31) | JSON | Persistent | Target items purchased, scans performed, running stats | None |

---

## Details by Script

### 1. CowHub & Preview (`luascripts/cowhub.lua`, `luascripts/preview.lua`)

All files in CowHub route through `resolveCowHubPath(fileName, subFolder)` at [L966](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L966):
- Automatically creates `cowhub/` and subdirectories (`cowhub/raftlogs/`) via `makefolder`.
- Checks for legacy root workspace files or parent `cowhub/` files and auto-migrates them to the target path.
- Deletes legacy file via `delfile` / `deletefile` once migrated.

#### File Specifications:
- **`cowhub/CowScannerWebhook.txt`**:
  - Contains raw Discord Webhook URL string.
  - Written via Settings UI or auction alerts.
- **`cowhub/CowHub_SessionPersistence.json`**:
  - Saved before 6-hour AFK teleport reconnect.
  - Structure: `{ Timestamp, PlaceId, JobId, Position, CFrameComponents, Farm, Dodge, Manatite, Mithril, TownAuction }`.
  - Deleted automatically upon successful resume or after 30 minutes expired.
- **`cowhub/SpiderIdentifiers.json`**:
  - Structure: `{ identifiers: string[], byPosition: map, byPath: map, history: list }`.
  - Flushed on new discovery.
- **`cowhub/raftlogs/cowhub_raft_<time>_<id>.log`**:
  - Header line: `H,t,x,z,headingDeg,cross,along,steering,targetDeckX,targetZ,errorZ,left,right,forward,status,health,energy,speed,crash,bump,weather,gust,drift,statusText`.
  - Flushed periodically (every 5 seconds) or on voyage events.
- **`cowhub/cowhub_raft_facades.json`**:
  - Map of part names to `{ x, y, z, sx, sy, sz, yaw }`.
  - Flushed every 15 seconds when dirty.

### 2. Voyage Telemetry (`luascripts/voyage_telemetry.lua`)

- Uses `CONFIG.FOLDER = "cowhub/voyagelogs"` at [L28](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L28).
- Output files:
  - `cowhub/voyagelogs/voyage_<time>_<id>.log`
  - `cowhub/voyagelogs/world_survey.json` (auto-falls back to legacy `cowhub/world_survey.json` or `cowhub_telemetry/world_survey.json`).

### 3. SkinHunter (`luascripts/skinhunter.lua`)

- `SkinHunterConfig.json`: Saved user options.
- `SkinHunterState.json`: Session metrics and targets found.

