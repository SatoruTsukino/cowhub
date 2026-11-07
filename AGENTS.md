# Project Rules

## GSD Planning Outlines
Always follow GSD planning outlines before implementing features or non-trivial edits:
1. **Protocol**: Follow `SPEC` → `PLAN` → `EXECUTE` → `VERIFY` → `COMMIT`. Never write code without an active, approved plan.
2. **Structure**: Follow [`.gsd/templates/PLAN.md`](file:///Users/jsph/cowhub/.gsd/templates/PLAN.md) outline strictly (`<task type="auto|checkpoint">` with `<name>`, `<files>`, `<action>`, `<verify>`, `<done>`).
3. **Goal-Backward**: Define exact verification proof and measurable done criteria before execution.

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
2. Automatically update header comments and Window `Name` in `Rayfield:CreateWindow`:
   ```lua
   Name = "Cow Hub [<commit-hash>]", -- e.g. Name = "Cow Hub [56ff3af]"
   ```
   Or run automated updater:
   ```bash
   ./scripts/update-hub-header.sh
   ```

## Workspace File Storage
All files generated or persisted by CowHub scripts (configs, state, logs, telemetry, caches) must reside in a dedicated `cowhub/` directory within executor workspace. Never write loose files to root workspace directory. Raft logs must generate into `cowhub/raftlogs/` and voyage telemetry into `cowhub/voyagelogs/`. Ensure `makefolder` and migrate legacy root/parent files when reading/writing.

## Script Roles & Themes
- `luascripts/preview.lua`: Staging for new features and debug modes. Theme: `"frost"`.
- `luascripts/cowhub.lua`: Stable / production for features deployable without debugging. Theme: `"rose"`.
- **Parity**: Do not force 100% parity between preview and cowhub. Keep themes distinct.

## Non-Main Branch / Brain Loadstring
When pushing commits on any branch or brain workspace other than `main`:
Always provide an executable Roblox loadstring in chat:
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/<branch>/luascripts/<script>.lua'))()
-- or commit-pinned:
loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/<commit-hash>/luascripts/<script>.lua'))()
```

## FUNCTIONS.md Line Numbers
Line numbers in `FUNCTIONS.md` must always match the code. After any change that shifts lines in an indexed script, run:
```bash
python3 scripts/update-functions-md.py
```
The pre-commit hook runs this automatically. Use `--check` to verify without writing; it exits 1 if any number is stale.
