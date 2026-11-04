# Script Roles & Themes Rule

`preview.lua` and `cowhub.lua` serve distinct roles and must not always be kept at 100% parity:

1. **`luascripts/preview.lua` (Staging / Experimental):**
   - Target for new features, experimental patches, and verbose debug modes.
   - Window Theme: `"frost"`.

2. **`luascripts/cowhub.lua` (Production / Stable):**
   - Target for verified features ready to push without extensive debugging.
   - Window Theme: `"rose"`.

3. **Parity Guidelines:**
   - Do NOT unconditionally mirror all changes between both files.
   - Preserve differing theme assignments (`frost` for preview, `rose` for cowhub).
   - Only promote features from `preview.lua` to `cowhub.lua` once tested and stable.

