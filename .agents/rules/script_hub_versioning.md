# Script Hub Title Versioning Rule

Every modification or commit touching `luascripts/cowhub.lua` and `luascripts/preview.lua` must reflect the latest commit short hash in the Window title:

1. **Commit hash lookup:**
   ```bash
   git rev-parse --short HEAD
   ```

2. **Window title format:**
   Always append latest commit short hash to Window `Name` in Rayfield `CreateWindow`:
   ```lua
   Name = "Cow Hub [<commit-hash>]", -- e.g. Name = "Cow Hub [f4c407f]"
   ```

