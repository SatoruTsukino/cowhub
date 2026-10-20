# Fjord Rafting & Roblox Platform Mechanics

## 1. Raft Steering is Purely Deck-Relative Position, NOT Input Velocity
- In Fjord Rafting, the game engine calculates steering on the server via `RaftingRules.Steering(tbl3, num1)`:
  $$\text{Steering} = \text{clamp}\left(\frac{\text{cowRel.X}}{\text{DeckSize.X} / 2}, -1, 1\right)$$
- The server does **not** check whether input keys (WASD) are pressed, nor does it inspect character linear velocity.
- Any method that shifts `HumanoidRootPart.Position` laterally on the deck (`cowRel.X = deck.CFrame:PointToObjectSpace(root.Position).X`) successfully controls the steering angle (up to $\pm 0.785$).

## 2. Why Early Iterations Steered vs Why Middle Iterations Broke
- **Early Iterations (Working Steering):**
  - Directly updated `root.CFrame = deck.CFrame * CFrame.new(targetDeckX, targetY, targetDeckZ)`.
  - Replicated `root.Position` to the server at `targetDeckX = -5.5` or `+5.5`, yielding non-zero `Steering` (up to $-0.86$ in log `20_40_21Z`).
  - **Issue in Early Iteration:** The vertical offset `targetY` was placed too low (`1.2` studs), causing the cow to clip/sink into the deck floor.
- **Middle Iterations (Broken Steering):**
  - Attempted to avoid clipping by replacing `root.CFrame` with `humanoid:Move(moveDir.Unit, false)` inside `RunService.Heartbeat`.
  - In Roblox, `PlayerScripts.PlayerModule.ControlModule` and the game's `InputController` run on `RenderStepped` (`CowCompositeKeyboardMove`). Every frame without physical keypresses, they invoke `keyboardPrimaryBinding:Fire(Vector2.zero)` and `humanoid:Move(Vector3.zero, true)`.
  - Because `Heartbeat` runs *after* physics simulation and `RenderStepped` runs *before*, `ControlModule` immediately zeroed out `humanoid:Move()` before physics could step.
  - The cow remained stuck at deck $X = 0$, producing $Steering = 0.0$.
  - In log `22_14_20Zrec325`, the only non-zero frames occurred when the player physically pressed keys, causing an incorrect assumption that manual input was required.
## 3. The Correct Hybrid Solution
- **Kinematic Deck Steer:** Update the character's deck-relative position along $X$ towards `targetDeckX` smoothly at 16 studs/sec, while preserving deck surface elevation ($Y \approx 3.45$):
  ```lua
  local maxStep = 16.0 * dtVal
  local deltaX = targetDeckX - currentX
  local stepX = math.clamp(deltaX, -maxStep, maxStep)
  root.CFrame = deck.CFrame * CFrame.new(currentX + stepX, currentY, currentZ + stepZ) * root.CFrame.Rotation
  ```
- **Post-Input Walk Animation:** In `RenderStepped`, call `humanoid:Move(worldMoveDir.Unit, false)` so character walk animations and hoof strides match the motion.
- **VirtualInput Keypress Emulation:** Emulate 'A' / 'D' keys via `VirtualInput:SendKeyEvent` to keep input contexts active.
- **Clearing Docking:** Never clamp $Z$ in Reach 1 to `[-55, -20]`; steer into the cove bounding boxes to allow docking.

## 4. Why Grass Autofarm Works vs Why Humanoid:Move Failed on Raft
- **`Humanoid:MoveTo(targetPos)` (Used by Grass Autofarm):**
  - Used at line 5645 (`humanoid:MoveTo(targetPos)`).
  - `MoveTo` sets the engine-level C++ state `WalkToPoint` to a 3D world coordinate.
  - When the user has no keyboard input, Roblox's `ControlModule` does **not** cancel active `WalkToPoint` navigation; the internal path solver steers the character to the target point continuously until reached (or 8s timeout).
  - The mainland ground is stationary (`Velocity = 0`), so the target coordinate stays under the grass node.
- **Why `Humanoid:MoveTo` Failed on the Raft (Commit `998789c`):**
  - The raft is a moving platform travelling at 16–33 studs/sec downriver.
  - Calling `humanoid:MoveTo(deck.CFrame:PointToWorldSpace(...))` gave a world coordinate that was instantaneously left behind in the water as the boat moved forward. The engine's path solver attempted to steer backward towards the water where the boat used to be.
  - In addition, passing $Y = 1.2$ commanded the cow into the floor planking.
- **Why `Humanoid:Move(direction)` Failed on the Raft (Commits `ca2c810` / `337ea0b`):**
  - `Humanoid:Move(dir)` does **not** set a pathfinding target; it only applies a directional vector for that single frame.
  - `ControlModule:OnRenderStepped` executes every frame and calls `humanoid:Move(self.moveVector, true)` with `Vector3.zero` when no keys are pressed.
  - Any external `humanoid:Move()` call made on `Heartbeat` is immediately overridden by `ControlModule` on `RenderStepped` before the next physics step.
  - Furthermore, `RaftingController:_stepDeckMotion` executes on `PreSimulation` and locks the character's deck-relative position `motionFrame:ToObjectSpace(humanoidRootPart.CFrame)` unless the character's relative CFrame is updated.
- **The Takeaway:**
  - On static ground: `Humanoid:MoveTo(worldPos)` works natively without interference.
  - On a high-speed moving platform: Pathfinding in world space fails because the reference frame moves. Character position must be advanced in **platform object-space** via `root.CFrame = deck.CFrame * CFrame.new(relX, relY, relZ)`.

