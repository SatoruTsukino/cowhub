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
| [77](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L77) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L121) | `resolveCharacter()` | Finds current player character model reliably. |
| [135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L135) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L155) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [162](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L162) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L181) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [199](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L199) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [237](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L237) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [302](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L302) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L333) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L721) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [756](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L756) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L773) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L787) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [804](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L804) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [815](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L815) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L822) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [916](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L916) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [935](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L935) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L973) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1012) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1090](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1090) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1162](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1162) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1170](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1170) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1195) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1266) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1317) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1501](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1501) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1524](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1524) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1569](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1569) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1577) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1603](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1603) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1615) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1664) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1679) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1740](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1740) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1780) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1812](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1812) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2247) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2254](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2254) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2261) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2274) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2284](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2284) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2290](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2290) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2316) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2325](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2325) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2342](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2342) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2357](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2357) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2364](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2364) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2390](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2390) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2440](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2440) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2463](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2463) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2488](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2488) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1879](file:///Users/jsph/cowhub/luascripts/preview.lua#L1879) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1888](file:///Users/jsph/cowhub/luascripts/preview.lua#L1888) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [1874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1874) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [1889](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1889) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L291) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [1910](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1910) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [1944](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1944) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2024](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2024) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2043) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2053) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2062](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2062) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2074](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2074) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2098) | `chomp.release()` | Releases a held E key. |
| [2108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2108) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2119) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2146) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2158) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2171) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2183) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2502) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2516) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2577) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2587) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2600](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2600) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2731](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2731) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2762) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2766](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2766) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2791) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2802) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2806](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2806) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2822) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2877) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2881](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2881) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2907](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2907) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2911](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2911) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2956) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2961](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2961) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3040](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3040) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3061](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3061) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3077) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3081) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3107) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3113) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3117) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3121) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3127) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3171) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3183) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3216](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3216) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3277](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3277) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3338) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3379](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3379) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3399) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3419) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3448](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3448) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3477) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3583](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3583) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3612](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3612) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3715) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3760) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3772](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3772) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3788](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3788) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3813) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3819) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3826) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3835) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3873) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3926](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3926) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3940) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3979) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4020](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4020) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4036](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4036) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4049](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4049) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4113) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4207) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4219) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4302](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4302) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4314) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4392) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4414](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4414) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4484) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4546](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4546) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4558](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4558) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4626) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4660) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4717) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5025) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5070](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5070) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5143) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5175) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5214](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5214) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5281) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5327) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5369](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5369) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [5402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5402) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5632](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5632) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5740](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5740) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5757) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5855](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5855) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5886) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5964](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5964) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5968](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5968) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5976) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4444) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6893](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6893) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6908](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6908) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6969) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6975](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6975) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7072](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7072) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7150) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7176](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7176) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7205](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7205) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7238) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7334](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7334) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7406](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7406) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7511](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7511) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7532](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7532) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7589) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7612](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7612) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7697) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7711) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7749](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7749) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7778](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7778) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7832) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7869) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7895) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7924](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7924) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7962) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7970](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7970) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8082](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8082) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8181) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8196) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8212](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8212) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8217](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8217) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8242) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8262) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8572) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8589) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8610) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8619) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8692) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8704) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8725) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8736) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8748](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8748) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8775](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8775) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8879) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8899](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8899) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8904) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8968](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8968) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8984](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8984) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9002) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9027](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9027) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9042](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9042) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9114](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9114) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9158) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9217](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9217) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9302](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9302) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9342](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9342) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9375) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9422) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9451) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9470) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9583](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9583) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9605](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9605) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9624) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9662](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9662) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9669) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9725) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9803](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9803) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9819) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9962) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9993](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9993) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10066](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10066) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10091) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10113) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10127) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10145](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10145) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10151) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10192) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10231](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10231) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10293](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10293) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10358](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10358) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10368](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10368) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10384](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10384) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10414](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10414) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10462](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10462) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10569](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10569) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10634](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10634) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10703](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10703) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10717) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10738) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10743](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10743) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10757) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10776](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10776) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10830](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10830) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10843](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10843) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10866](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10866) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10928](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10928) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10936](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10936) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10950) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10956) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10969) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10975](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10975) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11031](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11031) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11069](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11069) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11182](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11182) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11193](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11193) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11199](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11199) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11219) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11241) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11255](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11255) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11285](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11285) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11312) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11352) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11393) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11666](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11666) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11677) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12144](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12144) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12187](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12187) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12204](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12204) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12380](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12380) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12455](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12455) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12487](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12487) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12507](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12507) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12516) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12526) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12587) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12619) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12654](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12654) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

