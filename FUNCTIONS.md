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
| [800](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L800) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L835) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [852](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L852) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [866](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L866) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L883) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L894) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L901) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [995](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L995) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1014](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1014) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1052](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1052) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1091) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1169](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1169) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1241) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1249) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1280) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1317) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1346) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1418) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1469](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1469) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1669) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1692) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1737](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1737) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1745](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1745) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1771](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1771) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1783](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1783) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1832) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1847](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1847) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1908](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1908) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1948) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1980](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1980) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2545](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2545) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2552](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2552) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2559](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2559) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2572) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2582) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2594) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2609) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2635](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2635) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2644](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2644) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2661) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2676) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2683](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2683) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2709](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2709) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2759) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2782](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2782) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2807](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2807) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2041](file:///Users/jsph/cowhub/luascripts/preview.lua#L2041) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2050](file:///Users/jsph/cowhub/luascripts/preview.lua#L2050) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2131](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2131) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2146) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L352) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2167](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2167) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2201) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2313](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2313) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2333) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2343](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2343) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2352) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2364](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2364) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2390](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2390) | `chomp.release()` | Releases a held E key. |
| [2401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2401) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2413) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2441](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2441) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2454) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2467](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2467) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2479) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2821](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2821) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2835) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2896](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2896) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2906) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2919](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2919) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3050](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3050) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3081) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3085](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3085) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3110](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3110) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3121) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3125) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3141](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3141) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3196) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3200) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3226) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3230](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3230) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3275](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3275) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3280) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3359) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3380](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3380) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3396](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3396) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3400) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3426](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3426) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3432) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3436) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3440](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3440) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3446](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3446) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3490) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3502) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3535](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3535) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3596](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3596) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3657) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3698](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3698) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3718](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3718) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3738) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3767) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3796](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3796) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3902](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3902) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3931](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3931) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4034) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4079) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4091) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4107) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4132](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4132) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4138) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4145](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4145) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4154](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4154) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4192) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4245](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4245) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4259](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4259) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4298) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4339) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4355) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4368](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4368) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4432) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4526) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4538) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4621) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4633) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4711) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4733](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4733) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4803](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4803) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4865](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4865) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4877) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4945) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4979) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5040](file:///Users/jsph/cowhub/luascripts/preview.lua#L5040) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5056) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5374](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5374) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5419) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5492) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5524](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5524) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5563](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5563) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5630) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5676) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5718](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5718) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5752](file:///Users/jsph/cowhub/luascripts/preview.lua#L5752) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5771](file:///Users/jsph/cowhub/luascripts/preview.lua#L5771) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5777) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [6018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6018) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [6126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6126) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [6143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6143) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [6289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6289) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [6320](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6320) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [6398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6398) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [6402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6402) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [6410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6410) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4763) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [7319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7319) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [7334](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7334) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [7395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7395) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [7401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7401) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7498) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7576) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7602](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7602) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7631](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7631) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7664) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7760) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7832) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7925) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7946) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [8003](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8003) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [8026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8026) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [8111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8111) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [8125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8125) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [8163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8163) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [8192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8192) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [8246](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8246) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [8283](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8283) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8309) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [8338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8338) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [8376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8376) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [8384](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8384) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8496) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8595) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8604](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8604) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8620](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8620) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8625](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8625) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8650](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8650) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8670) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8974](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8974) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8991](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8991) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [9012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9012) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [9021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9021) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [9094](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9094) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [9106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9106) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [9127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9127) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [9138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9138) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [9150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9150) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [9177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9177) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [9281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9281) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [9301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9301) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [9306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9306) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [9370](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9370) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [9386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9386) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9404](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9404) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9429](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9429) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9444) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9516) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9560](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9560) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9619) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9704) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9744) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9777) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9824) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9853](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9853) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9872](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9872) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9985](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9985) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [10007](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10007) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [10026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10026) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [10064](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10064) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [10071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10071) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [10127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10127) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [10205](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10205) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [10221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10221) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [10364](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10364) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [10395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10395) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10468](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10468) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10493) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10515](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10515) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10529](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10529) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10547) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10553) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10594) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10633) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10695](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10695) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10760) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10770) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10786](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10786) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10816) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10864](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10864) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10971) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [11036](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11036) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [11105](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11105) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [11119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11119) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [11140](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11140) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [11145](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11145) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [11159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11159) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [11178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11178) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [11232](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11232) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [11245](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11245) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [11268](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11268) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [11330](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11330) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [11338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11338) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [11352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11352) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [11358](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11358) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [11371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11371) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [11377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11377) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11433](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11433) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11471) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11584](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11584) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11595) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11601) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11621) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11643) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11657) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11687](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11687) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11714](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11714) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11754](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11754) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11795](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11795) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [12068](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12068) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [12079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12079) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12546](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12546) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12589) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12606](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12606) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12782](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12782) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12857) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12889](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12889) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12909) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12918) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12928](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12928) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12989](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12989) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [13021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13021) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [13056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13056) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

