# Script Hub Title Versioning Rule

Every modification or commit touching `luascripts/cowhub.lua` and `luascripts/preview.lua` must reflect the latest commit short hash in the Window title:

1. **Commit hash lookup:**
   ```bash
   git rev-parse --short HEAD
   ```

2. **Window title format & automated update:**
   Always append latest commit short hash to top comment and Window `Name` in Rayfield `CreateWindow`:
   ```lua
   Name = "Cow Hub [<commit-hash>]", -- e.g. Name = "Cow Hub [56ff3af]"
   ```
   Or run the automated updater:
   ```bash
   ./scripts/update-hub-header.sh
   ```
   A git `pre-commit` hook is also installed to re-sync automatically upon every commit.

