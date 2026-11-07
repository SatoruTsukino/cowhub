# Companion Bait Mechanics & Spawning Context

Complete technical reference decompiled from `Place_82507849398215_Folder_Shared_1794016208.txt` and `Place_82507849398215_Folder_CowGameClient_1794018577.txt`.

---

## 1. Bait Configuration (`CompanionConfig`)
File: `ReplicatedStorage.CowGame.Shared.CompanionConfig`

```lua
CompanionConfig.Bait = {
    Chicken = "Dog",
    Catfish = "Cat"
}
```

- `Chicken` attracts wild dogs.
- `Catfish` attracts wild cats.

---

## 2. Model Templates & Assets
File: `ReplicatedStorage.CowGame.Shared.ItemModels`

### Asset Storage Hierarchy:
- **Catfish Model**:
  `ReplicatedStorage.CowGame.Shared.CompanionBaitModels.Catfish`
- **Chicken Model**:
  `ReplicatedStorage.CowGame.Shared.ItemVisualAssets.Chicken`

### Creation Function:
```lua
function ItemModels.Create(itemId: string, appearance: table?, cFrame: CFrame?)
```
- Inspects `CompanionBaitModels` for `Catfish`.
- Inspects `ItemVisualAssets` for `Chicken`.
- Clones model, applies scale attributes (`Scale`), palette attributes (`Palette`), anchors parts, disables collision/touch/query.

---

## 3. Client Equip & Interaction Flow
File: `CowGameClient` (`CraftingController`)

### Equip Action:
When selecting a bait item from player inventory:
```lua
if CompanionConfig.Bait[selectedItem.Id] then
    local currentBait = Players.LocalPlayer:GetAttribute("CowTamingBait")
    local newBait = if currentBait == selectedItem.Id then "" else selectedItem.Id
    companionRequest:InvokeServer({
        Action = "Bait",
        ItemId = newBait
    })
end
```

### Player Attribute State:
- Server sets player attribute upon equip:
  ```lua
  Player:SetAttribute("CowTamingBait", "Chicken") -- or "Catfish", or nil/"" when unequipped
  ```
- No separate tool or physical accessory is parented to the player character during holding; the state is driven by the attribute.

---

## 4. Server AI Perception & Slot Assignment
File: `ReplicatedStorage.CowGame.Shared.AnimalBaitBehavior`

### Active Bait Table Record:
The server maintains a list of active baits passed to `AnimalBaitBehavior.Assign`:
```lua
{
    Key = tostring(player.UserId),
    Species = "Dog" | "Cat",            -- Mapped from CompanionConfig.Bait[CowTamingBait]
    UserId = player.UserId,
    Position = rootPart.Position,
    Forward = rootPart.CFrame.LookVector,
    FloorY = groundRaycastY
}
```

### Perception Radius & Drive Calculation:
```lua
function AnimalBaitBehavior.Drive(animal)
    local hunger = math.clamp(animal.Needs.Hunger or 0, 0, 1)
    local timidity = math.clamp(animal.Personality.Timidity or 0.5, 0, 1)
    local boldness = math.clamp(((animal.Personality.Boldness or 1) - 0.65) / 0.8, 0, 1)
    local patience = math.clamp(animal.Personality.Patience or 0.5, 0, 1)

    local intensity = math.clamp(
        hunger * 0.67 + 0.17 + boldness * 0.17 + (animal.Personality.FoodTaking or 0.5) * 0.1 - timidity * 0.19,
        0, 1
    )

    return {
        Intensity = intensity,
        Radius = intensity * 22 + 20,       -- 20 to 42 studs perception radius
        Distance = timidity * 2.5 + 7.2 + (1 - intensity) * 1.3, -- Approach distance
        Notice = timidity * 1.8 + 0.35 + patience * 0.8,
        Gesture = patience * 3.5 + 2.8 + (1 - intensity) * 2.4,
        Voice = math.clamp(17 - intensity * 9 + patience * 5, 5, 24)
    }
end
```

### Approach Slots Around Player:
Baits arrange approaching animals in an arc around the player using pre-calculated angular offsets:
```lua
local SLOTS = { 0, 0.68, -0.68, 1.36, -1.36, 2.1, -2.1, math.pi }
```

### Behavior Execution (`AnimalBaitBehavior.Step`):
- Sets `animal.Goal = { Kind = "BegForTreat" }`.
- Pathfinds to destination slot near player: `destination = bait.Position + offset * drive.Distance`.
- When within $1.1$ studs, poses:
  - `"Crouching"` if `Timidity > 0.75`
  - `"Sitting"` (default cat/dog posture)
  - `"PawGentle"` if `Intensity > 0.64`
  - `"Sniffing"` if `Species == "Dog"`

---

## 5. Workspace Hierarchy & Physical Instances

### Case A: Feeding In Progress (`AnimalTamingMeal`)
File: `CowGameClient` -> `AnimalFoodPresentation` (lines 162750-162780)
When the animal is actively fed / eating:
```
Workspace
└── Animals (or World Model)
    └── [AnimalModel]
        └── AnimalTamingMeal                   -- Cloned via ItemModels.Create(Item)
            ├── ModelMesh / Parts
            └── Scale: shrinks 7 bite ticks: (1 - math.floor(progress * 7) * 0.78 / 7)
```
- Destroyed once feeding ends or meal expires.

### Case B: Dropped Manually via Inventory Drop (`<ItemId>Drop`)
File: `ReplicatedStorage.CowGame.Shared.ItemModels` -> `authored()`
When dropped onto the ground as an item:
```
Workspace
└── <ItemId>Drop                              -- "CatfishDrop" or "ChickenDrop"
    ├── Attribute: ItemId = "Catfish" | "Chicken"
    ├── Attribute: Scale = 1.0 (clamped 0.75 - 1.25)
    ├── Attribute: Palette = "Natural" | "Sunlit" | "Moonlit"
    └── BaseParts: Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false
```

### Case C: Equipped Bait (Player Character)
- **NO physical item is welded or parented to character parts.**
- The bait status exists purely as a networked attribute on the Player instance:
  ```lua
  game.Players.LocalPlayer:GetAttribute("CowTamingBait")
  ```

