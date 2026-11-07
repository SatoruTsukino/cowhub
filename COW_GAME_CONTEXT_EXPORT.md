# Cow Game Decompiled Context & Mechanics Export

Exported context from place dump `/Users/jsph/Opiumware/workspace/Place_82507849398215_Folder_Shared_1794016208.txt` and client dump `Place_82507849398215_Folder_CowGameClient_1794018577.txt`.

---

## 1. Pet Personality Traits, Vectors & Dispositions

### PRNG Traits (AnimalTemperament & Seed Offsets)
Traits derive deterministically from individual animal seed via `AnimalTemperament.Sample(Seed, Offset)`:

| Trait | Offset | Range | Functional Impact |
|---|---|---|---|
| Dominance | 401 | [0, 1] | Lowers `Threshold` for `CanStand` defense against predators; increases intimidate. |
| Timidity | 409 | [0, 1] | Increases standoff retreat distance; if ≥ 0.72, blocks `CanStand` stance. |
| Trouble | 413 | [0, 1] | Increases mischievous idle behaviors and rogue roaming. |
| Leadership | 417 | [0, 1] | Herd following priority; group steering weight. |
| Neuroticism | 419 | [0, 1] | Reaction speed to sudden player movements or loud sounds. |
| HighPlaces | 359 | [0, 1] | Preference for pathfinding onto rocks, roofs, elevated terrain. |
| ThreatWatch | 367 | [0, 1] | Awareness cone and alert latency for predators/hazards. |
| Wanderlust | 373 | [0, 1] | Roam radius expander beyond `Home` or `RoamAnchor`. |
| Initiative | 281 | [0, 1] | Drive to start social interactions or activities autonomously. |
| Affection | 283 | [0, 1] | Closeness to owner; frequency of nuzzles and follow triggers. |
| Patience | 293 | [0, 1] | Duration animal will wait at bait spots before breaking attention. |
| Defiance | 307 | [0, 1] | Resistance to commands/follow goals; core gate for `CanStand`. |

### Standoff Defense (`CanStand`) Logic
Determines whether an animal confronts a predator rather than fleeing:
```lua
-- Threshold formula:
local threshold = 1.0 - (Boldness * 0.35) - (Dominance * 0.25)
local canStand = (Defiance >= threshold) and (Taunts >= 3) and (Timidity < 0.72)
```

### Disposition Evaluation Hierarchy
Evaluated in priority order in `CompanionRules`:
1. **Headstrong**: `Defiance > 0.86`
2. **Rascal**: `Initiative > 0.7` and `Play > 1.1`
3. **Companion**: `Affection > 0.68`
4. **Observer**: `Patience > 0.70`
5. **Independent**: `Initiative < 0.30`
6. **Sociable**: Default fallback

---

## 2. Cosmetic Crate Pity & Loot Luck Mechanics

### Crate Pity Multiplier Formula
Located in `CollectionLuckRules`:
$$\text{Multiplier} = 100^{\frac{\text{ItemsOwned}}{\text{TotalItems} - 1}}$$

- Applied specifically to the unobtained Mythic / rarest item in the crate set.
- When player owns all items except the Mythic ($17/18$ items), exponent $= \frac{17}{17} = 1.0$:
  $$\text{Multiplier} = 100^1 = 100\times$$
- Base Mythic rate ($0.03\%$) multiplied by $100\times \to \mathbf{3.00\%}$.
- Common probability is reduced to accommodate the boosted tiers ($84.00\%$).

### Halloween Crate Tiers & Rates

| Tier | Items | Base Rate (No Pity) | Max Pity Rate (17/18 Owned) | 4x Server Event + Max Pity |
|---|---|---|---|---|
| **Mythic** (`PumpkinHeadCoat`) | 1 | 0.03% (1 in 3333) | **3.00%** (1 in 33.3) | **12.00%** (1 in 8.3) |
| **Legendary** | 2 | 0.50% | 0.50% | 2.00% |
| **Epic** | 3 | 3.50% | 3.50% | 14.00% |
| **Rare** | 4 | 12.00% | 12.00% | 24.00% |
| **Common** | 8 | 83.97% | **81.00%** | **48.00%** |

---

## 3. Luck Multipliers, Stacking & Bunny Luck

### Stacking Multipliers
- **Server Luck Events**: Direct multiplier to rare/mythic weight (e.g. `4x Mythic` multiplies active rate by 4).
- **Titles**: Additive or fractional scaling applied via `LuckRules.TitleBonus`.
- **Four-Leaf Clovers**: Flat boost to luck seed or luck bonus tier.
- **Back Bunnies**: Player can carry up to **5 bunnies on their back** (`BackFriendSnapshot`). Each back bunny adds luck scaling depending on species/coat.
- **Pen Bunnies**: **DO NOT GIVE LUCK**. In live production calls to `LuckRules.Weights(player, crateId, penContext)`, `penContext` is passed as `nil`. Bunnies inside player enclosures generate passive resources/drops, not luck multipliers.

---

## 4. Bunny Pen Enclosures & Survival Mechanics

### Pen Validation Minimum Requirements (`BunnyPenRules`)
1. **Fully Enclosed Perimeter**: Continuous fences or walls with no gaps $> 1.5$ studs.
2. **Access Latch / Gate**: At least one recognized gate part with prompt/hinge.
3. **Max Area**: Bounded by plot limits, minimum area $12 \times 12$ studs per 2 bunnies.
4. **Valid Floor**: Natural terrain (Grass/Dirt) or straw bedding; bare stone/water invalidates pen.

### Survival & Care Needs (`BunnyPenSimulation`)
- **Food Trough**: Must contain Hay, Clover, or Carrots. If hunger reaches 0 for $> 300\text{s}$, health drains.
- **Water Source**: Trough or shallow water dish.
- **Weather Shelter**: Covered roof required during `FjordStorm` / heavy rain; unshaded bunnies take comfort and health debuffs during storms.

---

## 5. Companion Bait Spawning & Workspace Representation

### Bait Configuration (`CompanionConfig`)
```lua
CompanionConfig.Bait = {
    Chicken = "Dog",
    Catfish = "Cat"
}
```

### Template Models
- **Catfish**: Stored in `ReplicatedStorage.CowGame.Shared.CompanionBaitModels.Catfish`.
- **Chicken**: Stored in `ReplicatedStorage.CowGame.Shared.ItemVisualAssets.Chicken`.

### Player Bait Equip Flow
1. Inventory UI triggers:
   ```lua
   companionRequest:InvokeServer({ Action = "Bait", ItemId = "Chicken" })
   ```
2. Server attaches player attribute:
   ```lua
   Player:SetAttribute("CowTamingBait", "Chicken") -- or "Catfish"
   ```
3. `AnimalBaitBehavior.Assign` tracks live bait holders:
   ```lua
   {
       Key = tostring(UserId),
       Species = "Dog", -- or "Cat"
       UserId = Player.UserId,
       Position = Character.PrimaryPart.Position,
       Forward = Character.PrimaryPart.CFrame.LookVector,
       FloorY = GroundRaycastY
   }
   ```
4. Detection radius is $20 - 42$ studs (scaled by hunger and boldness).
5. Approaching animals transition goal to `BegForTreat`.

### Workspace Instance Names & Hierarchy
- **When being fed (`AnimalFoodPresentation`)**:
  - Cloned via `ItemModels.Create(item)`.
  - Named: **`AnimalTamingMeal`**.
  - Parented inside the target animal: `animalModel.AnimalTamingMeal`.
  - Scales down progressively over 7 bite ticks.
- **When dropped as world loot (`ItemModels.authored`)**:
  - Cloned with name: **`<ItemId>Drop`** (e.g. `CatfishDrop`, `ChickenDrop`).
  - Attributes: `ItemId` (string), `Scale` (number), `Palette` ("Natural" | "Sunlit" | "Moonlit").
  - Parented under `Workspace` (or drop containers).

