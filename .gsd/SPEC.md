# SPEC.md — Autofarm Chomp Refactor

> **Status**: `FINALIZED` (2026-11-03)
>
> ⚠️ **Planning Lock**: No code may be written until this spec is marked `FINALIZED`.

## Vision
Refactor the grass-chomp portion of the CowHub autofarm (`luascripts/cowhub.lua`, mirrored to `luascripts/preview.lua`) into one owned chomp module with two modes: **Remote** (script fires `ChompRequest` at the fastest interval the server accepts, computed live from player buffs) and **Natural** (script drives the game's own graze input via the `E` key so the game's `InputController` does targeting and pacing). Mob aura interrupts must hand control back to the active chomp mode automatically.

## Goals
1. **Chomp module consolidation** — One `chomp` table owns interval math, firing, natural input, and server-result feedback. Remove duplicated delay/repeat-delay branches and the 10-branch speed dropdown parser.
2. **Natural mode** — Engage in-game grazing with `VirtualInputManager` `E` key. Respect `CowGrazeToggle` (tap vs hold). Watchdog re-engages when character `CowAction ~= "Graze"`, including after every mob-aura attack.
3. **Auto max speed (Remote mode)** — Interval = `clamp(ChewCooldown attr or 0.7, 0.4, 3) × (0.5 if FoodKind == "Wheat") ÷ clamp(CowGrazingSpeedMultiplier or 1, 1, 1.236)`, plus adaptive margin driven by `ClientEvent "GrazeResult"` rejections (`ChewCooldown`). Fire with the game's wire shape `FireServer(nodeId, nil, serial)`.
4. **Bot-check pause** — When `CowBotCheckActive` or `CowBotQuarantined` is true: stop all chomp firing, release `E`, notify the user (Rayfield + webhook if configured). Resume automatically once both clear.
5. **Module dumper** — New `luascripts/module_dumper.lua` saves listed game ModuleScript sources to `cowhub/dumps/` for future research.

## Non-Goals (Out of Scope)
- Bot-check solver and dev findings — separate milestone: branch `gsd/botcheck-pentest`.
- Spoofing or suppressing `PlayerSignalReporter` / bot-signal telemetry.
- Firing faster than the computed server limit (sub-limit presets removed; they only produce rejections).
- Changes to mining (manatite/mithril), fishing, rafting, dodge, or mob payload resolution.

## Constraints
- Luau: zero compile errors; max register < 200 (`AGENTS.md`).
- Header + `Rayfield:CreateWindow` `Name` updated via `./scripts/update-hub-header.sh` on every commit touching `cowhub.lua` / `preview.lua`.
- All persisted files under executor `cowhub/` folder (`resolveCowHubPath`).
- AFK-relog save/restore must carry new settings (`ChompMode`, `AutoMaxSpeed`) with backward-compatible defaults.
- Shell discipline: one command per invocation, no `&&`.

## Success Criteria
- [ ] `luau-compile` clean on `cowhub.lua`, `preview.lua`, `module_dumper.lua`; registers < 200.
- [ ] Remote mode: `grep` shows exactly one `chompEvent:FireServer` call site for grass, using `(id, nil, serial)`.
- [ ] Remote mode in-game: `GrazeResult` rejection rate with reason `ChewCooldown` < 5% over 2 minutes (UAT).
- [ ] Natural mode in-game: grazing resumes ≤ 1.5 s after a mob-aura attack (UAT).
- [ ] Bot check appears → farm stops, notification shown, no `ChompRequest` fired until cleared (UAT).
- [ ] Old relog state files (no `ChompMode`) restore as Remote + AutoMax.

## Technical Requirements

| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| REQ-01 | `chomp.getInterval(node)` from live attributes | Must-have | Constants from `Config.Grass`, `GrazingSpeed.MaxMultiplier = 1.2 × 1.03` |
| REQ-02 | `GrazeResult` listener adjusts margin (+0.02 per reject, decay on accept, cap 0.15) | Must-have | `ClientEvent.OnClientEvent("GrazeResult", {RequestId, NodeId, Accepted, Reason})` |
| REQ-03 | Natural engage/release/watchdog | Must-have | Skip when `GetFocusedTextBox()` or action-blocked attributes set |
| REQ-04 | Mob aura → `chomp.onMobAttack(now)` re-arm | Must-have | Both mob fire branches in `processMobAura` |
| REQ-05 | Bot-check pause/resume | Must-have | Attribute-changed signals on LocalPlayer; webhook dropped (no generic sender exists in hub). ✅ base gate done (Plan 1.0) |
| REQ-06 | UI: mode dropdown, Auto Max toggle, manual speed dropdown (≥ server min only) | Must-have | Flags persist via Rayfield |
| REQ-07 | Relog save/restore of new fields | Must-have | |
| REQ-08 | `module_dumper.lua` | Should-have | `decompile`/`getscriptbytecode` guarded; writes `cowhub/dumps/<Name>.lua` |
| REQ-09 | Update `FUNCTIONS.md` and `FILE_OUTPUTS.md` | Should-have | |

---

*Last updated: 2026-11-03*
