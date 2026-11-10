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
| [1272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1272) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1309) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1338) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1410) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1461](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1461) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1661) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1684](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1684) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1729) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1737](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1737) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1763) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1775](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1775) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1824) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1839](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1839) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1900) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1940) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1972](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1972) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2526) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2533) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2540](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2540) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2553) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2563](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2563) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2575](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2575) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2590](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2590) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2616) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2625](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2625) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2642) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2657) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2664) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2690) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2740](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2740) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2763) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2788](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2788) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2048](file:///Users/jsph/cowhub/luascripts/preview.lua#L2048) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2057](file:///Users/jsph/cowhub/luascripts/preview.lua#L2057) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2123) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2138) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L352) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2159) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2193](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2193) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2294](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2294) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2314) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2324](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2324) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2333) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2345](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2345) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2371) | `chomp.release()` | Releases a held E key. |
| [2382](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2382) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2394) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2422) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2435) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2448](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2448) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2460](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2460) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2802) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2816) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2877) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2887](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2887) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2900) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3031](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3031) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3062](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3062) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3066](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3066) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3091) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3102](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3102) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3106) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3122) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3177) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3181) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3207) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3211](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3211) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3256) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3261) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3340](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3340) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3361) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3377) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3381) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3407](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3407) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3413) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3417](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3417) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3421](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3421) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3427](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3427) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3471) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3483](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3483) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3516) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3577) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3638) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3679) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3699) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3719](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3719) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3748](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3748) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3777) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3883) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3912](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3912) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4015](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4015) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4060](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4060) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4072](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4072) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4088) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4113) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4119) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4126) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4135) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4173](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4173) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4226) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4240) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4279](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4279) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4320](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4320) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4336) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4349](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4349) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4413) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4507](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4507) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4519](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4519) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4602](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4602) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4614) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4692) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4714](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4714) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4784](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4784) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4846](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4846) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4858) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4926](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4926) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4960) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5048](file:///Users/jsph/cowhub/luascripts/preview.lua#L5048) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5037](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5037) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5355) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5400) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5473](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5473) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5505) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5544](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5544) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5611) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5657) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5699) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5760](file:///Users/jsph/cowhub/luascripts/preview.lua#L5760) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5779](file:///Users/jsph/cowhub/luascripts/preview.lua#L5779) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5758](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5758) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5999](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5999) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [6107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6107) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [6124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6124) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [6265](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6265) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [6296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6296) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [6374](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6374) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [6378](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6378) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [6386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6386) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4744) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [7295](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7295) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [7310](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7310) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [7371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7371) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [7377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7377) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7474) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7552](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7552) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7578](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7578) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7607](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7607) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7640) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7736) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7808](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7808) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7901) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7922](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7922) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7979) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [8002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8002) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [8087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8087) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [8101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8101) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [8139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8139) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [8168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8168) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [8222](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8222) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [8259](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8259) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8285](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8285) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [8314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8314) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [8352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8352) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [8360](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8360) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8472](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8472) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8571) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8580) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8596](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8596) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8601) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8626) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8646](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8646) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8950) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8967](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8967) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8988) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8997](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8997) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [9070](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9070) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [9082](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9082) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [9103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9103) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [9114](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9114) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [9126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9126) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [9153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9153) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [9257](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9257) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [9277](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9277) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [9282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9282) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [9346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9346) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [9362](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9362) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9380](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9380) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9405](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9405) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9420](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9420) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9492) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9536](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9536) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9595) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9680) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9720](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9720) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9753](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9753) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9800](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9800) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9829](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9829) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9848](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9848) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9961](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9961) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9983) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [10002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10002) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [10040](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10040) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [10047](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10047) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [10103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10103) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [10181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10181) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [10197](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10197) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [10340](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10340) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [10371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10371) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10444) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10469](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10469) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10491](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10491) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10505) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10523](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10523) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10529](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10529) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10570](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10570) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10609) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10671) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10736) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10746](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10746) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10762) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10792](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10792) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10840) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10947](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10947) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [11012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11012) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [11081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11081) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [11095](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11095) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [11116](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11116) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [11121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11121) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [11135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11135) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [11154](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11154) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [11208](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11208) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [11221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11221) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [11244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11244) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [11306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11306) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [11314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11314) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [11328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11328) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [11334](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11334) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [11347](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11347) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [11353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11353) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11409](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11409) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11447](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11447) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11560](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11560) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11571) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11577) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11597](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11597) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11619) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11633) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11663](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11663) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11690) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11730](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11730) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11771](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11771) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [12044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12044) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [12055](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12055) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12522](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12522) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12565](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12565) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12582) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12758](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12758) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12833) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12865](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12865) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12885](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12885) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12894) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12904) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12965](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12965) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12997](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12997) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [13032](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13032) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

