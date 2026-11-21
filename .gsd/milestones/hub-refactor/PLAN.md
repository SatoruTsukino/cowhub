---
phase: 1
plan: 1
wave: 1
gap_closure: false
---

# Plan 1.1: Hub refactor (perf + 6-tab UI)

## Objective
Deliver SPEC REQ-01..06 in `luascripts/preview.lua` without changing farm behaviour.

## Context
- .gsd/milestones/hub-refactor/SPEC.md
- luascripts/preview.lua (UI blocks: Autofarm ~7809, Ore ~8294, Auction ~8505/10002, Rafting ~14396,
  Caravan ~15674, Teleports ~15759, Dailies ~16376, Field Raid ~17020, Settings ~17150)

## Tasks

<task type="auto">
  <name>Perf: allocation-free DescendantAdded handlers</name>
  <files>luascripts/preview.lua</files>
  <action>
    1. mapOptimizer.optimizeInstance: hoist the pcall body into a named local; call pcall(fn, inst).
    2. Chest ESP isTeamChest: reject names without "chest" (case-insensitive class pattern) before string.lower.
    AVOID: changing which instances get optimized/tracked.
  </action>
  <verify>luau-compile luascripts/preview.lua</verify>
  <done>No closure created per DescendantAdded call; same instance set handled.</done>
</task>

<task type="auto">
  <name>UI: create the 6 tabs up front, move sections, merge controls</name>
  <files>luascripts/preview.lua</files>
  <action>
    1. Create Farm, Auction, Rafting, Raids, Dailies, Settings tabs once, right after the Window.
    2. Point each UI block at its new tab; move Teleports and ESP/Spam/Debug into the Settings block.
    3. Ore Farm section replaces both Manatite and Mithril sections (REQ-03).
    4. Merges per REQ-04.
    USE: existing ui.optionDropdown for merged toggles (keeps per-option callbacks).
  </action>
  <verify>Control inventory script (before/after) — every old callback reachable.</verify>
  <done>6 tabs; no lost callback; teleport/debug/ESP/spam reachable.</done>
</task>

<task type="auto">
  <name>Config migration + legacy flag aliases</name>
  <files>luascripts/preview.lua</files>
  <action>
    1. Before the UI builds, read Rayfield/Configurations/CowHub/CowHubConfig.rfld; for each new flag that is
       absent, derive it from the old flags; write back.
    2. AFK resume and dailies restore map Toggle_ManatiteFarm/Toggle_MithrilFarm → Ore type + Toggle_OreFarm.
  </action>
  <verify>Old config with Toggle_FPSCap=true, Slider_FPSCap=26 → Slider_FPSCap=26; Toggle_FPSCap=false → 0.</verify>
  <done>Saved settings survive the upgrade.</done>
</task>

<task type="checkpoint">
  <name>Gates + in-game pass</name>
  <files>luascripts/preview.lua, FUNCTIONS.md</files>
  <action>Compile, register count, FUNCTIONS.md resync. User loads hub, checks each tab, toggles each farm.</action>
  <verify>luau-compile; register < 200; python3 scripts/update-functions-md.py --check</verify>
  <done>All gates pass; user confirms in game.</done>
</task>
