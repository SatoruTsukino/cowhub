---
name: pet-esp
version: v0.1
status: building
created: 2026-11-06T00:00:00Z
---

# Milestone: Pet ESP

> **Status:** 🧪 Plan 1.1 built (`luascripts/pet_esp.lua`); in-game UAT (Plan 1.2) pending.
> Standalone first. Port into `preview.lua` (theme `frost`) only after UAT pass.

## Vision
See every dog and barn cat. Highlight each one. Label shows overall trait (Disposition) and temperament vector.

## Research (2026-11-06, dumps in `~/Opiumware/workspace/`)

| Source | Finding |
|--------|---------|
| AnimalTemperament | `Sample(seed, salt)` PRNG. Salts: Initiative 281, Affection 283, Patience 293, Defiance 307, SocialTempo 311, PlayStyle 313, HighPlaces 359, ThreatWatch 367, Wanderlust 373, Dominance 401, Timidity 409, Trouble 413, Leadership 417, Neuroticism 419. |
| AnimalTemperament.Init | Disposition chain: Defiance>0.86 Headstrong → Initiative>0.7 & Play>1 Rascal → Affection>0.68 Companion → Patience>0.7 Observer → Initiative<0.3 Independent → Sociable. |
| rbxlx DogController.new / BarnCatController.new | Make `workspace.LocalDogs` / `workspace.LocalBarnCats`. Controller table `{ Folder, Actors = { [key] = { Model, Record, RenderRecord } }, Pool }`. Models pooled, released → `Parent = nil`. |
| rbxlx (no SetAttribute) | Pet models carry no attributes. Model→Record only in controller Lua state → need `getgc`. |
| AnimalLife | Young = `AgeStage == "Young"` or `Puppy`/`Kitten`. Dog look = `Variant`, cat look = `Coat`. |

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| PE-01 | Highlight every pet model in both folders; drop when pooled away | Must |
| PE-02 | Label: name/variant, young tag, Disposition · descriptor, 12 trait values, distance | Must |
| PE-03 | Traits from `record.Personality`, missing ones recomputed from `Seed` with ported Sample; never write to game records/models | Must |
| PE-04 | No `getgc` → highlight still works, label say "traits unavailable" | Must |
| PE-05 | `_G.PetESP` re-exec guard + `destroy()` | Must |
| PE-06 | Separate Dog / Cat toggles: `petESP.show.Dog` / `petESP.show.Cat` + `petESP.update()`; standalone run turns both on | Must |

## Non-goals
- No hub integration; standalone script only.
- No highlight-cap juggling (Roblox ~31 Highlight limit).

## Unknowns
- U1: Do non-local (network) pet records carry `Seed` / `Personality`?
- U2: Is `actor.Model.Parent` always the folder (direct child)?

## Phases

### Phase 1: Standalone Pet ESP
- [x] Plan 1.1: `luascripts/pet_esp.lua` — compile ok, 23 regs, 0/5000 Sample+Disposition mismatch vs decompiled module
- [ ] Plan 1.2: In-game UAT (checkpoint) — test toggles: `_G.PetESP.show.Cat = false; _G.PetESP.update()` drops cats only, dogs stay
- Hub integration: not planned. Script stays standalone in `luascripts/` (user decision 2026-11-06).
