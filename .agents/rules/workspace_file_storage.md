# Workspace File Storage Rule

All files generated or persisted by CowHub scripts must be placed in a dedicated `cowhub/` subdirectory within the executor workspace.

1. **Dedicated Directory:**
   Always use `cowhub/` for all runtime artifacts (`CowScannerWebhook.txt`, `CowHub_SessionPersistence.json`, `SpiderIdentifiers.json`, `cowhub_raft_*.log`, `cowhub_raft_facades.json`).

2. **Directory Resolution & Creation:**
   Always resolve paths through directory helper and ensure folder creation via `makefolder("cowhub")` and `isfolder("cowhub")` before writing.

3. **Legacy Migration:**
   Check for and migrate existing root files into `cowhub/` automatically to preserve existing user settings, persistence states, and caches.

