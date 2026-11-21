# SPEC.md — Hub refactor: performance + UI consolidation (`luascripts/preview.lua`)

> **Status**: `FINALIZED` (2026-11-20, approved in chat)

## Vision
Same features, fewer and better-grouped controls, lower per-instance cost in hot event handlers.
`cowhub.lua` is untouched; it gets the change later via `scripts/promote-preview.py`.

## Requirements
- **REQ-01 Perf:** No per-call closure allocation in `workspace.DescendantAdded` handlers
  (Map Optimizer stream hook, Chest ESP). Cheap name pre-filter before `string.lower` in Chest ESP.
- **REQ-02 Tabs 10 → 6:** Farm · Auction · Rafting · Raids · Dailies · Settings.
  - Farm = Autofarm + Ore Farm. Auction = Auction Scanner + Town Auction. Raids = Caravan + Field Raid.
  - Dailies = Dailies + Bakehouse + Blacksmith Shift. Settings = Performance, Teleports, AFK Rejoin & Config, Debug & Misc.
- **REQ-03 Ore Farm:** Manatite and Mithril can't run together → one `Ore` dropdown + one `Toggle_OreFarm`,
  one shared options dropdown / order / delay / height (applied to both ores).
- **REQ-04 Merges:** 6 teleport buttons → one dropdown; Chomp + Caravan debug toggles → one `Debug Logs`
  option dropdown; ESP + key spammer → Settings Debug & Misc; Rafting Natural Mode → Safety Options;
  FPS cap toggle+slider → slider (0 = off); AFK rejoin toggle+slider → slider (0 = off).
- **REQ-05 Config compat:** Kept controls keep their flag. Merged controls get new flags, seeded once from the
  old flags in `CowHubConfig.rfld` before the UI builds. AFK resume and the dailies pause list accept the
  old ore flags.
- **REQ-06 Gates:** `luau-compile` 0 errors, max register < 200, `update-functions-md.py --check` clean.

## Non-Goals
- Changing farm logic, remotes, or timings. Touching `cowhub.lua`.
