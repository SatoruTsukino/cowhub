# Non-Main Branch / Brain Loadstring Rule

Whenever changes are committed or pushed in a branch or brain workspace other than `main`, an executable Roblox loadstring must be provided in the response.

1. **Trigger Condition:**
   - Active branch is not `main` (e.g. `feature/*`, `fix/*`, `preview`, or isolated subagent/brain workspace).
   - Commits pushed to remote repository.

2. **Required Loadstring Formats:**
   - Branch-targeted:
     ```lua
     loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/refs/heads/<branch>/luascripts/<script>.lua'))()
     ```
   - Commit-pinned:
     ```lua
     loadstring(game:HttpGet('https://raw.githubusercontent.com/SatoruTsukino/cowhub/<commit-hash>/luascripts/<script>.lua'))()
     ```

3. **Purpose:**
   - Allows instant in-game execution and verification in Roblox executors without manual URL assembly.

