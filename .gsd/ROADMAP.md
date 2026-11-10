---
milestone: autofarm-chomp-refactor
version: 0.1.0
updated: 2026-11-03T00:00:00Z
---

# Roadmap

> **Current Phase:** 1 - Chomp Module Refactor
> **Status:** verifying — Plans 1.0–1.3 built; awaiting in-game UAT logs (Plan 3.1)
>
> Separate milestone (blocked on dev availability): branch `gsd/botcheck-pentest`
> Separate milestone (complete): `.gsd/milestones/auction-ownership/MILESTONE.md`
> Separate milestone (planning): `.gsd/milestones/skinhunter-catalog/MILESTONE.md`
> Separate milestone (planning): `.gsd/milestones/caravan-autofarm/MILESTONE.md`
> Separate milestone (verifying): `.gsd/milestones/crate-odds/MILESTONE.md`

## Must-Haves (from SPEC)

- [ ] REQ-01 Live server-limit chomp interval
- [ ] REQ-02 GrazeResult adaptive margin
- [ ] REQ-03 Natural E-key graze mode + watchdog
- [ ] REQ-04 Mob attack re-arms active chomp mode
- [ ] REQ-05 Bot-check pause/resume + notify (built; UAT pending)
- [ ] REQ-06 UI controls
- [ ] REQ-07 Relog persistence

---

## Phases

### Phase 1: Chomp Module Refactor
**Status:** 🧪 Built, UAT pending
**Objective:** Consolidate grass chomp into one `chomp` module with Remote (auto-max) and Natural modes, bot-check pause.
**Requirements:** REQ-01 … REQ-07, REQ-09

**Plans:**
- [x] Plan 1.0: Hub bot-check pause — heartbeat gate (e3f0e7d)
- [x] Plan 1.1: Chomp core — interval, wire shape, GrazeResult feedback (1f02e45)
- [x] Plan 1.2: Natural mode, mob re-arm, bot-check E release (1f02e45)
- [x] Plan 1.3: UI, debug log, relog persistence, docs, header
- [x] Plan 1.4: Natural mode graze-state fix
- [x] Plan 1.5: Autofarm chomp calories/hr stat
- [x] Plan 1.6: Remote chomp target validation — rejects 32% → 9.1%, throughput held (shipped to cowhub)
- [x] Plan 1.11: Autofarm rebirth ETA stat
- [x] Plan 1.12: Cut grass bite rejects without throughput loss (662ddbd)
- [x] Plan 1.13: Persistent walkspeed settings

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
