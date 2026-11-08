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
| [786](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L786) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [821](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L821) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L838) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [852](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L852) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L869) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L880) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [887](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L887) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [981](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L981) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1000) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1038](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1038) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1077) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1155) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1227](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1227) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1235](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1235) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1260](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1260) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1331](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1331) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1382](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1382) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1566](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1566) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1589) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1634](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1634) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1642) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1668](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1668) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1680) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1729) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1744) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1805](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1805) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1845](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1845) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1877) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2312) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2319) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2326](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2326) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2339) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2349](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2349) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2355) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2381) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2390](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2390) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2407](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2407) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2422) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2429](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2429) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2455](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2455) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2505) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2528) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2553) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1944](file:///Users/jsph/cowhub/luascripts/preview.lua#L1944) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1953](file:///Users/jsph/cowhub/luascripts/preview.lua#L1953) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [1939](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1939) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [1954](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1954) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L352) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [1975](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1975) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2009](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2009) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2089](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2089) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2108) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2118](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2118) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2127) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2139) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2163) | `chomp.release()` | Releases a held E key. |
| [2173](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2173) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2184](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2184) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2211](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2211) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2223) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2236](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2236) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2248) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2567](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2567) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2581) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2642) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2652) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2665](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2665) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2796](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2796) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2827) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2831) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2856](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2856) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2867](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2867) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2871](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2871) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2887](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2887) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2942) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2946) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2972](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2972) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2976) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3021) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3026) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3105](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3105) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3126) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3142](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3142) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3146) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3172](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3172) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3178) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3182](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3182) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3186) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3192) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3236](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3236) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3248) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3281) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3342](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3342) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3403) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3444) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3464) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3484) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3513) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3542) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3648](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3648) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3677) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3780) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3825](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3825) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3837](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3837) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3853](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3853) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3878](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3878) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3884](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3884) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3891) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3900) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3938](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3938) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3991](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3991) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4005](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4005) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4044) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4085](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4085) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4101) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4114](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4114) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4178) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4272) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4284](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4284) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4367) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4379](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4379) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4457](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4457) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4479) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4549](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4549) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4611) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4623](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4623) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4691](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4691) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4725) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 4911](file:///Users/jsph/cowhub/luascripts/preview.lua#L4911) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [4802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4802) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5120) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5165](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5165) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5238) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5270](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5270) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5309) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5376) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5422) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5464) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5623](file:///Users/jsph/cowhub/luascripts/preview.lua#L5623) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5642](file:///Users/jsph/cowhub/luascripts/preview.lua#L5642) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5523](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5523) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5755](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5755) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5863](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5863) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5880) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [6013](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6013) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [6044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6044) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [6122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6122) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [6126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6126) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [6134](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6134) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4509) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6968](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6968) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6983) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [7044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7044) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [7050](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7050) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7147) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7225](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7225) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7251](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7251) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7280) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7313](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7313) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7409](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7409) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7481](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7481) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7574](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7574) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7595) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7652) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7675) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7760) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7774) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7812](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7812) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7841](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7841) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7895) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7932](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7932) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7958) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7987) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [8025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8025) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [8033](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8033) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8145](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8145) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8244) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8253](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8253) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8269](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8269) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8274) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8299](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8299) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8319) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8623](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8623) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8640) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8661) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8670) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8743](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8743) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8755](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8755) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8776](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8776) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8787) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8799](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8799) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8826) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8930](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8930) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8950) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8955) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [9019](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9019) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [9035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9035) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9053) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9078](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9078) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9093](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9093) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9165](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9165) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9209](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9209) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9268](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9268) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9353) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9393) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9426](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9426) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9473](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9473) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9502) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9521](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9521) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9634](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9634) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9656) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9675) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9713) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9720](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9720) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9776](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9776) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9854) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9870](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9870) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [10013](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10013) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [10044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10044) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10117) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10142](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10142) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10164](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10164) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10178) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10196) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10202) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10243) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10282) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10344](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10344) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10409](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10409) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10419) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10435) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10465](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10465) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10513) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10620](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10620) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10685](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10685) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10754](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10754) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10768) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10789](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10789) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10794) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10808](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10808) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10827) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10881](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10881) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10894) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10917](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10917) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10979) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10987) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [11001](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11001) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [11007](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11007) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [11020](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11020) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [11026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11026) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11082](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11082) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11120) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11233) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11244) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11250](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11250) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11270](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11270) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11292) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11306) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11336) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11363) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11403) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11444) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11717) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11728](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11728) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12195) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12238) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12255](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12255) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12431](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12431) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12506](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12506) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12538) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12558](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12558) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12567](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12567) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12577) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12638) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12670) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12705) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

