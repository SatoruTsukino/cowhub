# Script Hub Title Versioning Rule

Every modification or commit touching `luascripts/cowhub.lua` and `luascripts/preview.lua` must reflect the latest commit short hash in the Window title:

1. **Commit hash lookup:**
   ```bash
   git rev-parse --short HEAD
   ```

2. **Window title format:**
   Update Rayfield `CreateWindow` `Name` argument:
   ```lua
   Name = "Cow Hub [<commit-hash>]",
   ```

