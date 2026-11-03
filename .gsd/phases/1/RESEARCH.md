# Phase 1 Research — Grazing Internals

Sources: `~/Opiumware/workspace/InputController_ModuleScript_82507849398215_Source.txt`, `Config_…`, `AuraController_…`, `BotCheckConfig_…`, place dump `.rbxlx` (2026-11-01).

## Chew interval (client `InputController:_chewCooldown`)
- `speedMult = clamp(Player.CowGrazingSpeedMultiplier or 1, 1, GrazingSpeed.MaxMultiplier)`
- `GrazingSpeed.MaxMultiplier = MountainsideStory.GrazingSpeedMultiplier (1.2) × HerdersHooves (1.03) = 1.236`
- `base = clamp(Player.ChewCooldown or Config.Grass.BaseChewCooldown 0.7, MinimumChewCooldown 0.4, 3)`
- Node `CowBiteCooldown` attr (number) → `max(CowBiteCooldown, base) / speedMult`
- Grass: `base / speedMult`; Wheat: `base × 0.5 / speedMult`
- Hay/Apple/Acorn/Honeycomb: `1 / speedMult`
- `UpgradeConfig` ChewSpeed: `ChewCooldown = max(0.4, 0.7 − level × 0.02)` → floor 0.4 at level 15
- Absolute floor (grass): `0.4 / 1.236 ≈ 0.3236 s`
- Rate limit `ChompRequest`: Capacity 8, refill 8/s (not binding at ≥ 0.32 s)

## Wire protocol
- Grass bite: `ChompRequest:FireServer(nodeId, nil, serial)`
- Reply: `ClientEvent.OnClientEvent("GrazeResult", {RequestId, NodeId, Accepted, Reason})`
- Reject reasons: `Unavailable, OutOfRange, BehindCow, OutsideCone, Obstructed, ChewCooldown, CowBusy, CraftCooldown`
- Current hub fires `FireServer(nodeId)` (missing serial) — deviates from the game's shape.

## Natural graze input
- `HotkeyBindings.BindAction("CowGraze", …, Enum.KeyCode.E, ControlPrompts.Bindings.Graze)`
- Begin → `SetGrazeActive(true, "E")`; End → `SetGrazeActive(false, "E")`
- `CowGrazeToggle == true` → press toggles grazing; otherwise hold-to-graze
- `_grazePressed` latch: a second Begin without End is ignored → watchdog must send End before re-Begin
- Blocked when: `CowMoofCutscene, CowBotCheckActive, CowBotQuarantined`, modal blocks, construction, `CowClientReady ~= true`, `CatapultActive`, focused TextBox
- Replicated state: `Character:GetAttribute("CowAction") == "Graze"`

## Bot check
- Triggered server-side when signal `Count ≥ 20` and `Kind ∈ {automation_pattern, botting_suspected}`
- Client flags: `CowBotCheckActive`, `CowBotQuarantined`; QuickCheck deadline 10 s
- Decision: pause + notify human; no solver (see SPEC Non-Goals)
