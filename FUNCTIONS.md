# CowHub Codebase Function Navigation Index

This document indexes every function across all scripts in the CowHub repository with exact line links, signatures, and functional descriptions.

## Quick Navigation

- [Main Script Hub (`cowhub.lua` / `preview.lua`)](#main-script-hub-cowhublua--previewlua)
- [Trick or Treat Autofarm (`trick_or_treat.lua`)](#trick-or-treat-autofarm-trick_or_treatlua)
- [Voyage Telemetry Logger (`voyage_telemetry.lua`)](#voyage-telemetry-logger-voyage_telemetrylua)
- [Skin Hunter & Sniper (`skinhunter.lua`)](#skin-hunter-&-sniper-skinhunterlua)
- [Infernal Levers Solver (`infernal_levers.lua`)](#infernal-levers-solver-infernal_leverslua)
- [Bird Nest ESP (`bird_nest_esp.lua`)](#bird-nest-esp-bird_nest_esplua)
- [Hanging Honey Hive ESP (`hanging_honey_hive_esp.lua`)](#hanging-honey-hive-esp-hanging_honey_hive_esplua)

---

## Main Script Hub (`cowhub.lua` / `preview.lua`)

**Path**: [`luascripts/cowhub.lua`](file:///Users/jsph/cowhub/luascripts/cowhub.lua) *(synchronized with [`luascripts/preview.lua`](file:///Users/jsph/cowhub/luascripts/preview.lua))*

Primary CowHub script containing autofarm engines, mining, dodging, auction scanners, and Fjord rafting.

**Total Functions**: `241`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L138) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [182](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L182) | `resolveCharacter()` | Finds current player character model reliably. |
| [196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L196) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [216](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L216) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L223) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L242) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [260](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L260) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L298) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L367) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L398) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [792](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L792) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L827) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [844](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L844) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L858) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [875](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L875) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L886) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [893](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L893) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L987) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1006](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1006) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1044) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1083) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1161) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1233) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1241) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1266) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1337) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1388](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1388) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1572) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1595) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1640) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1648](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1648) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1674) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1686) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1735](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1735) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1750](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1750) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1811) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1851) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1883) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2437) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2444) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2451) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2464) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2474) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2486](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2486) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2501](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2501) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2527](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2527) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2536](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2536) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2553) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2568](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2568) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2575](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2575) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2601) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2651) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2674) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2699) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1952](file:///Users/jsph/cowhub/luascripts/preview.lua#L1952) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1961](file:///Users/jsph/cowhub/luascripts/preview.lua#L1961) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2034) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2049](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2049) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L352) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2070](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2070) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2104) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2205](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2205) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2225](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2225) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2235](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2235) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2244) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2256) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2282) | `chomp.release()` | Releases a held E key. |
| [2293](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2293) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2305](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2305) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2333) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2346) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2359) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2371) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2713) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2727](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2727) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2788](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2788) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2798](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2798) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2811) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2942) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2973) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2977) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3002) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3013](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3013) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3017](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3017) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3033](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3033) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3088) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3092](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3092) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3118](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3118) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3122) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3167](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3167) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3172](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3172) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3251](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3251) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3272) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3288](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3288) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3292) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3318) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3324](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3324) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3328) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3332](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3332) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3338) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3382](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3382) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3394) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3427](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3427) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3488](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3488) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3549](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3549) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3590](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3590) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3610) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3630) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3659](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3659) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3688](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3688) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3794) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3823](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3823) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3926](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3926) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3971) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3983) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3999](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3999) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4024](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4024) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4030](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4030) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4037](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4037) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4046](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4046) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4084](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4084) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4137) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4151) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4190](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4190) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4231](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4231) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4247) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4260](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4260) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4324](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4324) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4418) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4430) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4513) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4525](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4525) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4603](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4603) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4625](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4625) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4695](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4695) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4757) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4769](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4769) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4837](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4837) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4871](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4871) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 4951](file:///Users/jsph/cowhub/luascripts/preview.lua#L4951) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [4948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4948) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5266) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5311](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5311) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5384](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5384) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5416) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5455](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5455) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5522](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5522) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5568](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5568) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5610) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5663](file:///Users/jsph/cowhub/luascripts/preview.lua#L5663) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5682](file:///Users/jsph/cowhub/luascripts/preview.lua#L5682) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5669) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5910](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5910) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [6018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6018) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [6035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6035) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [6176](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6176) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [6207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6207) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [6285](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6285) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [6289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6289) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [6297](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6297) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4655](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4655) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [7204](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7204) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [7219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7219) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [7280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7280) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [7286](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7286) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7383) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7461](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7461) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7487](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7487) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7516) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7549](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7549) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7645](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7645) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7717) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7810](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7810) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7831) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7888](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7888) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7911](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7911) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7996) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [8010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8010) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [8048](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8048) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [8077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8077) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [8131](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8131) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [8168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8168) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8194](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8194) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [8223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8223) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [8261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8261) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [8269](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8269) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8381) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8480) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8489](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8489) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8505) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8510](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8510) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8535](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8535) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8555) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8859) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8876](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8876) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8897) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8906) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8979) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8991](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8991) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [9012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9012) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [9023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9023) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [9035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9035) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [9062](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9062) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [9166](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9166) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [9186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9186) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [9191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9191) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [9255](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9255) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [9271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9271) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9289) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9314) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9329](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9329) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9401) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9445](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9445) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9504](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9504) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9589) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9629](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9629) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9662](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9662) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9709](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9709) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9738) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9757) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9870](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9870) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9892](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9892) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9911](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9911) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9949](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9949) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9956) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [10012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10012) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [10090](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10090) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [10106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10106) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [10249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10249) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [10280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10280) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10353) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10378](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10378) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10400) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10414](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10414) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10432) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10438](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10438) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10479) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10518](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10518) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10580) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10645](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10645) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10655](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10655) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10671) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10701) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10749](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10749) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10856](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10856) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10921) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10990](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10990) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [11004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11004) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [11025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11025) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [11030](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11030) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [11044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11044) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [11063](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11063) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [11117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11117) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [11130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11130) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [11153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11153) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [11215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11215) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [11223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11223) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [11237](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11237) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [11243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11243) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [11256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11256) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [11262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11262) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11318) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11356](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11356) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11469](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11469) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11480) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11486](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11486) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11506](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11506) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11528) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11542) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11572) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11599](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11599) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11639](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11639) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11680) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11953](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11953) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11964](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11964) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12431](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12431) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12474) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12491](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12491) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12667) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12742](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12742) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12774) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12794) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12803](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12803) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12813) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12874) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12906) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12941](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12941) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

---

## Trick or Treat Autofarm (`trick_or_treat.lua`)

**Path**: [`luascripts/trick_or_treat.lua`](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua)

Standalone Trick or Treat autofarm with waypoint navigation, anti-equip modal dismissal, cooldown auto-detection, and telemetry UI.

**Total Functions**: `34`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [69](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L69) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [80](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L80) | `resolveRoot(targetChar)` | Locates and caches HumanoidRootPart of target character. |
| [93](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L93) | `resolveHumanoid(targetChar)` | Locates and caches Humanoid instance of character. |
| [100](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L100) | `resolveCharacter()` | Finds current player character model reliably. |
| [108](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L108) | `getRootPos(r)` | Returns Vector3 position of root part with zero extra allocations. |
| [114](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L114) | `getRootCFrame(r)` | Returns CFrame of root part safely. |
| [120](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L120) | `setRootCFrame(cf)` | Safely teleports character root part and clears velocities. |
| [127](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L127) | `cacheCharParts(c)` | Caches character parts and collision properties. |
| [214](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L214) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [231](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L231) | `safeReturnToSavedPosition(savedCF)` | Safely returns character to pre-farming CFrame upon completion. |
| [281](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L281) | `trickOrTreat.getTelemetry()` | Collects runtime metrics (total cycles, knocks, rewards, rate). |
| [312](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L312) | `trickOrTreat.detectCooldown()` | Scans workspace signs/billboards for active trick-or-treat cooldown. |
| [393](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L393) | `trickOrTreat.findHouse(houseName)` | Finds specific farmer house model in workspace by name. |
| [413](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L413) | `trickOrTreat.getHousesFolder()` | Finds folder holding trick-or-treat farmer houses. |
| [444](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L444) | `trickOrTreat.getHouseList()` | Collects all eligible farmer house models for the run. |
| [448](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L448) | `addCandidate(obj)` | Adds valid house model candidate to candidate list. |
| [504](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L504) | `resolveHousePart(obj)` | Locates reference primary part of house model. |
| [513](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L513) | `trickOrTreat.getDoorPart(houseModel)` | Finds front door / prompt part of house. |
| [524](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L524) | `trickOrTreat.getInsidePart(houseModel)` | Locates inside reference part for house approach. |
| [545](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L545) | `trickOrTreat.setHouseCollision(houseModel, canCollide)` | Toggles collision on house walls to enable walk-through. |
| [558](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L558) | `trickOrTreat.fireDoorPrompt(houseTarget)` | Triggers proximity prompt on house door natively. |
| [659](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L659) | `trickOrTreat.getTargetCFrame(houseTarget)` | Computes waypoint navigation CFrame at house door. |
| [838](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L838) | `trickOrTreat.getRemote()` | Finds trick-or-treat client remote event. |
| [855](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L855) | `trickOrTreat.initClientListener()` | Hooks client event for trick-or-treat notifications. |
| [895](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L895) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [933](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L933) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [968](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L968) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1000](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1000) | `trickOrTreat.dismissRewardGui(force)` | Closes candy/reward popups without clicking equip buttons. |
| [1116](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1116) | `trickOrTreat.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward UI until fully dismissed or timed out. |
| [1135](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1135) | `trickOrTreat.updateStatusUI()` | Updates live Rayfield status and telemetry text cards. |
| [1230](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1230) | `trickOrTreat.visitHouse(houseTarget, i, totalHouses)` | Navigates to single house, approaches door, triggers prompt, handles rewards. |
| [1374](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1374) | `trickOrTreat.runCycle()` | Executes complete neighborhood trick-or-treating cycle. |
| [1622](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1622) | `trickOrTreat.startLoop()` | Starts automated continuous loop with cooldown timers. |
| [1666](file:///Users/jsph/cowhub/luascripts/trick_or_treat.lua#L1666) | `trickOrTreat.toggle(Value)` | Enables or disables Trick or Treat autofarm. |

---

## Voyage Telemetry Logger (`voyage_telemetry.lua`)

**Path**: [`luascripts/voyage_telemetry.lua`](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua)

Fjord rafting telemetry logger recording high-frequency spatial physics, sensor observations, and channel geometry.

**Total Functions**: `40`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [94](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L94) | `jsonString(text)` | Escapes text for JSON output format. |
| [99](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L99) | `round3(n)` | Rounds float to 3 decimal places. |
| [146](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L146) | `cleanText(value)` | Strips whitespace and newlines from telemetry text values. |
| [154](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L154) | `writeLine(line)` | Appends formatted string to log buffer. |
| [160](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L160) | `flush(force)` | Writes buffered log data to file on disk. |
| [177](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L177) | `logEvent(name, data, force)` | Logs discrete event entry with timestamp and properties. |
| [182](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L182) | `logError(where, message)` | Logs handled error with callsite location. |
| [190](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L190) | `guarded(where, fn, ...)` | Executes function wrapped in pcall with error logging. |
| [195](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L195) | `connect(signal, fn)` | Connects signal with managed tracking for cleanup. |
| [206](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L206) | `channelInfo(x, z)` | Determines channel reach and index for coordinates. |
| [224](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L224) | `placeInfo(position)` | Resolves zone name and reach location. |
| [233](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L233) | `weatherInfo(position)` | Extracts current rain, fog, and storm attributes. |
| [257](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L257) | `findDeck()` | Locates player raft deck model in workspace. |
| [300](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L300) | `castRays(deck)` | Casts multi-point whiskers from deck to detect obstacles. |
| [324](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L324) | `characterInfo(deck)` | Extracts player position, health, and seat status on raft. |
| [359](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L359) | `damagedStations(snap)` | Checks damage state across all raft stations. |
| [369](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L369) | `headingOf(vector)` | Computes compass heading angle from direction vector. |
| [373](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L373) | `takeSample(now, dt)` | Captures comprehensive telemetry physics/steering sample. |
| [470](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L470) | `outputPath(name)` | Generates file path for output session log. |
| [475](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L475) | `surveyPath()` | Returns path for geometry survey JSON cache. |
| [479](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L479) | `loadSurvey()` | Loads cached cliff facade and cutaway survey data. |
| [502](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L502) | `partRecord(part)` | Extracts spatial bounding box record for geometry part. |
| [510](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L510) | `partKey(part)` | Generates unique identifier string for surveyed part. |
| [541](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L541) | `surveyFacades(fjord)` | Scans and records geometric cliff faces along river. |
| [563](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L563) | `surveyCutaways(fjord)` | Surveys cutaways and obstacle bounds along river. |
| [596](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L596) | `saveSurvey(force)` | Saves river geometry survey data to disk file. |
| [612](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L612) | `stormAttributes()` | Extracts active storm parameters from lighting/replicated storage. |
| [621](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L621) | `startSession(id)` | Initializes telemetry session file and begins logging. |
| [653](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L653) | `endSession(reason)` | Finalizes telemetry session and closes log file. |
| [677](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L677) | `observeSnapshot(snap)` | Processes server-broadcast raft position snapshot. |
| [738](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L738) | `dockDetails(snap)` | Parses dock station information from snapshot. |
| [752](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L752) | `onSnapshot(snap)` | Event listener for rafting snapshot network packets. |
| [772](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L772) | `onClientEvent(name, payload)` | Dispatcher for incoming client network events. |
| [803](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L803) | `watchStormWarnings(folder)` | Monitors workspace folder for incoming storm telegraphs. |
| [820](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L820) | `pollChest()` | Checks for reward chest presence in clearings. |
| [842](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L842) | `installOutgoingHook()` | Hooks namecall to log outgoing network requests. |
| [855](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L855) | `handler(self, ...)` | Namecall proxy hook handler function. |
| [870](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L870) | `drainOutgoing()` | Flushes captured outgoing network packets. |
| [890](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L890) | `createLabel()` | Creates on-screen HUD telemetry text label. |
| [914](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L914) | `updateLabel()` | Refreshes on-screen HUD text with current voyage metrics. |

---

## Skin Hunter & Sniper (`skinhunter.lua`)

**Path**: [`luascripts/skinhunter.lua`](file:///Users/jsph/cowhub/luascripts/skinhunter.lua)

Auction sniper and server-hopper for rare animal and Halloween event skins with Discord webhook alerts.

**Total Functions**: `24`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [43](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L43) | `log(msg)` | Prints formatted console log message. |
| [47](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L47) | `countKeys(tbl)` | Counts entries in dictionary table. |
| [60](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L60) | `destroyAllRayfieldGuis()` | Cleans up existing Rayfield UI instances from CoreGui. |
| [140](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L140) | `queueReload()` | Queues script reload on server hop. |
| [198](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L198) | `getTargetSkinList()` | Returns configured table of target mob skins. |
| [202](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L202) | `isTargetSkin(skinId)` | Checks if skin ID matches target list. |
| [207](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L207) | `areTargetSkinsEqual(listA, listB)` | Compares two skin configuration tables for equality. |
| [218](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L218) | `getTargetSkinsDisplayString(maxItems)` | Formats skin list into human-readable string. |
| [233](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L233) | `setTargetSkins(newList, shouldResetQueue)` | Updates configured target skins table. |
| [274](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L274) | `loadConfig()` | Restores all toggle and slider states from local config file. |
| [331](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L331) | `loadState()` | Loads persistent sniper state from disk file. |
| [373](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L373) | `prepareStorage()` | Creates cowhub/skinhunter/ and migrates legacy root state/config files. |
| [410](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L410) | `getCosmeticConfig()` | Requires and caches the game's CosmeticConfig module. |
| [421](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L421) | `getSkinRarity(skinId)` | Returns a skin's rarity from the catalogue or CosmeticConfig. |
| [432](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L432) | `getAuctionSkins()` | Builds the auction coat catalogue live from CosmeticConfig.Definitions, grouped by rarity and AuctionStatus. |
| [553](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L553) | `sendWebhook(title, description, color, fields)` | Sends Discord webhook notification for found skins. |
| [579](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L579) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [630](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L630) | `getAuctionData()` | Fetches raw auction house lot data from server. |
| [675](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L675) | `isServerLot(lot, lotName)` | Validates if lot belongs to current game server. |
| [693](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L693) | `getAuctionRemainingTime(skinAuction)` | Extracts remaining time on skin auction lot. |
| [715](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L715) | `formatRemainingTime(seconds)` | Formats remaining seconds into readable time string. |
| [722](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L722) | `checkForTargetSkin()` | Scans auction house for desired target skins. |
| [956](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L956) | `hopToServer(target)` | Teleports client to target server via TeleportService. |
| [1050](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L1050) | `waitForAuctionChange()` | Yields until auction house lot rotation occurs. |
| [1107](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L1107) | `checkServerLotUpdate()` | Checks if server lot attributes updated. |
| [1521](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L1521) | `rarityOrder(preferred, byRarity)` | Preferred rarity order plus any unlisted rarities found in the catalogue. |

---

## Infernal Levers Solver (`infernal_levers.lua`)

**Path**: [`luascripts/infernal_levers.lua`](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua)

Infernal dungeon puzzle automation for finding, navigating to, and pulling all levers with ESP.

**Total Functions**: `19`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [117](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L117) | `log(msg)` | Prints formatted console log message. |
| [121](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L121) | `getRootPart()` | Locates character HumanoidRootPart safely. |
| [127](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L127) | `getHumanoid()` | Locates character Humanoid instance safely. |
| [132](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L132) | `safeTeleport(cframe, extraWait)` | Teleports character to CFrame and settles physics. |
| [145](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L145) | `cleanupCameraAndLocks()` | Restores camera zoom and controls after lever interaction. |
| [175](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L175) | `triggerPrompt(prompt)` | Fires ProximityPrompt on lever. |
| [198](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L198) | `getLeversFolder()` | Finds workspace folder containing dungeon levers. |
| [207](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L207) | `resolveLevers()` | Collects all interactive lever models in dungeon. |
| [251](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L251) | `isLeverActive(leverData)` | Checks if lever is already in pulled / activated state. |
| [261](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L261) | `simulatePhysicalPull()` | Performs physical character interaction sequence on lever. |
| [339](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L339) | `teleportHome()` | Returns character to dungeon safe zone. |
| [345](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L345) | `interactSingleLever(leverData)` | Navigates to lever, aligns character, and activates prompt. |
| [376](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L376) | `runAllLevers()` | Executes full sequence to solve all dungeon levers. |
| [420](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L420) | `stopAutomation()` | Cancels lever automation run. |
| [432](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L432) | `clearESP()` | Removes ESP adornments from levers. |
| [439](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L439) | `updateESP()` | Renders ESP highlights and state text on dungeon levers. |
| [488](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L488) | `buildRayfieldUI()` | Builds Rayfield window for Infernal Levers controller. |
| [661](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L661) | `buildFallbackUI()` | Constructs simple fallback ScreenGui if Rayfield fails. |
| [699](file:///Users/jsph/cowhub/luascripts/infernal_levers.lua#L699) | `createBtn(text, yPos, callback)` | Helper to create button on fallback ScreenGui. |

---

## Bird Nest ESP (`bird_nest_esp.lua`)

**Path**: [`luascripts/bird_nest_esp.lua`](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua)

Visual ESP tracker highlighting wild bird nests and resident species across the map.

**Total Functions**: `12`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [33](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L33) | `getRootPos()` | Returns Vector3 position of root part with zero extra allocations. |
| [41](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L41) | `getBirdSpecies(model)` | Extracts bird species identifier from nest model. |
| [56](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L56) | `parseDisplayName(model)` | Formats clean species display name for billboard. |
| [74](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L74) | `isTargetResident(child)` | Validates if resident bird matches tracked species. |
| [83](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L83) | `isModelVisible(model, targetPart)` | Checks if model is rendered and within max view distance. |
| [109](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L109) | `removeVisual(model)` | Removes ESP Highlight and BillboardGui from nest model. |
| [131](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L131) | `cleanupAllVisuals()` | Cleans up all active nest ESP visuals in workspace. |
| [138](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L138) | `attach(trackedResident)` | Creates Highlight and BillboardGui for newly spawned nest. |
| [215](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L215) | `hookFolder(folder)` | Hooks ChildAdded/ChildRemoved on bird nests folder. |
| [247](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L247) | `initWatcher()` | Initializes folder observers and streaming listeners. |
| [275](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L275) | `startLoop()` | Runs distance sorting and visual update loop. |
| [339](file:///Users/jsph/cowhub/luascripts/bird_nest_esp.lua#L339) | `nestESP.destroy()` | Full cleanup of bird nest ESP script and listeners. |

---

## Hanging Honey Hive ESP (`hanging_honey_hive_esp.lua`)

**Path**: [`luascripts/hanging_honey_hive_esp.lua`](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua)

Visual ESP tracker highlighting harvestable hanging bee hives with distance indicators.

**Total Functions**: `10`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [33](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L33) | `getRootPos()` | Returns Vector3 position of root part with zero extra allocations. |
| [41](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L41) | `isHiveModel(child)` | Identifies if workspace model is a harvestable honey hive. |
| [56](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L56) | `isModelVisible(model, targetPart)` | Checks if model is rendered and within max view distance. |
| [82](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L82) | `removeVisual(model)` | Removes ESP Highlight and BillboardGui from nest model. |
| [98](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L98) | `cleanupAllVisuals()` | Cleans up all active nest ESP visuals in workspace. |
| [105](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L105) | `attach(trackedHive)` | Creates Highlight and BillboardGui for newly spawned nest. |
| [163](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L163) | `hookFolder(folder)` | Hooks ChildAdded/ChildRemoved on bird nests folder. |
| [195](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L195) | `initWatcher()` | Initializes folder observers and streaming listeners. |
| [223](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L223) | `startLoop()` | Runs distance sorting and visual update loop. |
| [281](file:///Users/jsph/cowhub/luascripts/hanging_honey_hive_esp.lua#L281) | `hiveESP.destroy()` | Full cleanup of honey hive ESP script and listeners. |

---

