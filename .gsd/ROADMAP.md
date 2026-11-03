---
milestone: autofarm-chomp-refactor
version: 0.1.0
updated: 2026-11-03T00:00:00Z
---

# Roadmap

> **Current Phase:** 1 - Chomp Module Refactor
> **Status:** executing (Plan 1.0 done; next Plan 1.1)
>
> Separate milestone (blocked on dev availability): branch `gsd/botcheck-pentest`

## Must-Haves (from SPEC)

- [ ] REQ-01 Live server-limit chomp interval
- [ ] REQ-02 GrazeResult adaptive margin
- [ ] REQ-03 Natural E-key graze mode + watchdog
- [ ] REQ-04 Mob attack re-arms active chomp mode
- [ ] REQ-05 Bot-check pause/resume + notify (base gate ✅ Plan 1.0; E release pending Plan 1.2)
- [ ] REQ-06 UI controls
- [ ] REQ-07 Relog persistence

---

## Phases

### Phase 1: Chomp Module Refactor
**Status:** 🔄 In Progress
**Objective:** Consolidate grass chomp into one `chomp` module with Remote (auto-max) and Natural modes, bot-check pause.
**Requirements:** REQ-01 … REQ-07, REQ-09

**Plans:**
- [x] Plan 1.0: Hub bot-check pause — heartbeat gate (e3f0e7d)
- [ ] Plan 1.1: Chomp core — interval, wire shape, GrazeResult feedback (wave 1)
- [ ] Plan 1.2: Natural mode, mob re-arm, bot-check E release (wave 2)
- [ ] Plan 1.3: UI, relog persistence, docs, header (wave 3)

### Phase 2: Module Dumper
**Status:** ⬜ Not Started
**Objective:** Standalone script saving game ModuleScript sources to `cowhub/dumps/`.
**Requirements:** REQ-08

**Plans:**
- [ ] Plan 2.1: `luascripts/module_dumper.lua` (wave 1, independent of Phase 1)

### Phase 3: In-Game UAT
**Status:** ⬜ Not Started
**Objective:** Human verification of SPEC success criteria in a live server.

**Plans:**
- [ ] Plan 3.1: UAT checklist (checkpoint:human-verify)
