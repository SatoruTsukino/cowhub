# Workspace File Storage Rule

All files generated or persisted by CowHub scripts must be placed in a dedicated `cowhub/` subdirectory within the executor workspace.

1. **Dedicated Directory & Subdirectories:**
   Always use `cowhub/` for runtime artifacts (`CowScannerWebhook.txt`, `CowHub_SessionPersistence.json`, `SpiderIdentifiers.json`, `cowhub_raft_facades.json`).
   Always route raft telemetry logs (`cowhub_raft_*.log`) into `cowhub/raftlogs/`.
   Always route voyage telemetry logs (`voyage_*.log`, `world_survey.json`) into `cowhub/voyagelogs/`.

2. **Directory Resolution & Creation:**
   Always resolve paths through directory helper and ensure folder creation via `makefolder("cowhub")`, `makefolder("cowhub/raftlogs")`, and `makefolder("cowhub/voyagelogs")` before writing.

3. **Legacy Migration:**
   Check for and migrate existing root or parent files into target directories automatically to preserve existing user settings, persistence states, and logs.

