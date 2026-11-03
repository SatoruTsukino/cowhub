---
milestone: autofarm-chomp-refactor
version: 0.1.0
updated: 2026-11-03T00:00:00Z
---

# Roadmap

> **Current Phase:** 4 - Bot-Check Pentest (user priority)
> **Status:** executing

## Must-Haves (from SPEC)

- [ ] REQ-01 Live server-limit chomp interval
- [ ] REQ-02 GrazeResult adaptive margin
- [ ] REQ-03 Natural E-key graze mode + watchdog
- [ ] REQ-04 Mob attack re-arms active chomp mode
- [ ] REQ-05 Bot-check pause/resume + notify
- [ ] REQ-06 UI controls
- [ ] REQ-07 Relog persistence
- [ ] REQ-10 Bot-check solver
- [ ] REQ-11 Solver transcript logs
- [ ] REQ-12 Dev hardening findings

---

## Phases

### Phase 1: Chomp Module Refactor
**Status:** ⬜ Not Started
**Objective:** Consolidate grass chomp into one `chomp` module with Remote (auto-max) and Natural modes, bot-check pause.
**Requirements:** REQ-01 … REQ-07, REQ-09

**Plans:**
- [ ] Plan 1.1: Chomp core — interval, wire shape, GrazeResult feedback (wave 1)
- [ ] Plan 1.2: Natural mode, mob re-arm, bot-check pause (wave 2)
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

### Phase 4: Bot-Check Pentest
**Status:** 🔄 In Progress
**Objective:** Pause hub during checks; standalone solver + transcript; hardening findings for the dev.
**Requirements:** REQ-05, REQ-10, REQ-11, REQ-12

**Plans:**
- [ ] Plan 4.1: Hub bot-check pause (pulled forward from Plan 1.2 task 3) (wave 1)
- [ ] Plan 4.2: `luascripts/botcheck_solver.lua` (wave 1)
- [ ] Plan 4.3: FINDINGS.md for dev (wave 2)
