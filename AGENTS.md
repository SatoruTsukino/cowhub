# Project Rules

## Luau Post-Edit Verification
On every code creation/modification:
1. Compile check (zero errors):
   ```bash
   luau-compile <file> > /dev/null
   ```
2. Register count (<200):
   ```bash
   LC_ALL=C luau-compile --text <file> | grep -o 'R[0-9]\{1,\}' | tr -d 'R' | sort -n | tail -1
   ```

## Script Hub Title Versioning
On every modification/commit to `luascripts/cowhub.lua` and `luascripts/preview.lua`:
1. Retrieve latest commit short hash:
   ```bash
   git rev-parse --short HEAD
   ```
2. Set Window `Name` in `Rayfield:CreateWindow`:
   ```lua
   Name = "Cow Hub [<commit-hash>]",
   ```


