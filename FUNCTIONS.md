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
| [59](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L59) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L103) | `resolveCharacter()` | Finds current player character model reliably. |
| [117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L117) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L137) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [144](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L144) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L163) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L181) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L219) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L261) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L291) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L589) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L624) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [641](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L641) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [655](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L655) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [672](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L672) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [683](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L683) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L690) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [784](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L784) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [801](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L801) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [839](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L839) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L877) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L948) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L956) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [980](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L980) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1044) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1095](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1095) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1266) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1289) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1335](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1335) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1343](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1343) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1369](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1369) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1381) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1430) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1445](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1445) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1506](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1506) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1544](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1544) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1576) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [1633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1633) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [1640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1640) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [1647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1647) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [1660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1660) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [1668](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1668) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [1676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1676) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [1689](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1689) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [1698](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1698) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [1715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1715) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [1729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1729) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [1736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1736) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [1762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1762) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [1810](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1810) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [1832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1832) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [1857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1857) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [1871](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1871) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [1885](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1885) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [1946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1946) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [1956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1956) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [1969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1969) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2098) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2129](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2129) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2133](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2133) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2158) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2169](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2169) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2173](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2173) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2189) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2244) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2248) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2274) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2278) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2323](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2323) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2328) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2407](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2407) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2428](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2428) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2444) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2448](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2448) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2474) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2480) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2484) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2488](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2488) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2493) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [2537](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2537) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [2549](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2549) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [2582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2582) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [2643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2643) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [2704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2704) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [2745](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2745) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [2765](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2765) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [2785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2785) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [2814](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2814) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [2843](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2843) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [2949](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2949) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [2978](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2978) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3081) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3126) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3138) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3154](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3154) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3179](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3179) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3185](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3185) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3192) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3201) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3239](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3239) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3292) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3306) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3345](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3345) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3370](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3370) | `chestESP.cleanup()` | Clears highlight and billboard adornments on chests. |
| [3386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3386) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3445](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3445) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [3484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3484) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [3496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3496) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [3579](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3579) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [3591](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3591) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [3669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3669) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [3691](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3691) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [3701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3701) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [3762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3762) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [3774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3774) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [3848](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3848) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [3882](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3882) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [3939](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3939) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4247) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4292) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4365](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4365) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4397](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4397) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [4436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4436) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [4502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4502) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [4542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4542) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [4785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4785) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [4891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4891) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [4907](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4907) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5013](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5013) | `farm.applyGoldenAura(customRadius)` | Applies golden grass harvesting pulses periodically. |
| [5049](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5049) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5079) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5157) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5161) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5168) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6071) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6075) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6087) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6130) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6144](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6144) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6261) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6339) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6365](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6365) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6394) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6427](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6427) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [6507](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6507) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [6577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6577) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [6667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6667) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [6688](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6688) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [6705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6705) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [6728](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6728) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [6818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6818) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [6832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6832) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [6870](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6870) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [6898](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6898) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [6952](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6952) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [6989](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6989) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7015](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7015) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7044) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7077) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7085](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7085) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7194](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7194) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7292) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7306) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7322](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7322) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7327) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7350](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7350) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7370](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7370) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [7667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7667) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [7684](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7684) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [7704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7704) | `rafting.getRaftDeck()` | Finds player raft deck part in workspace. |
| [7770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7770) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [7781](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7781) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [7802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7802) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [7813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7813) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [7825](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7825) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [7852](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7852) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [7956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7956) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [7976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7976) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [7981](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7981) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8043) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8059](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8059) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8077) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8102](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8102) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8117) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8189) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8233) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8292) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [8377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8377) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [8430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8430) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [8477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8477) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [8504](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8504) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [8615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8615) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [8637](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8637) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [8656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8656) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [8694](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8694) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [8701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8701) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [8755](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8755) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [8832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8832) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [8848](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8848) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [8989](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8989) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9020](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9020) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9079) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9104) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9126) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9138) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9156](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9156) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9162](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9162) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9203) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9242) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9312) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [9377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9377) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [9396](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9396) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [9404](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9404) | `rafting.getThreatEvasionOffset(deck, frame)` | Calculates lateral offset needed to dodge obstacles / rocks. |
| [9484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9484) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [9590](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9590) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [9653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9653) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [9767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9767) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [9828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9828) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [9929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9929) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [9940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9940) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [9946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9946) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [9966](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9966) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [9988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9988) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10001](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10001) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10031](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10031) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [10058](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10058) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [10098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10098) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [10139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10139) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [10395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10395) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [10406](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10406) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [10905](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10905) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [10946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10946) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [10963](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10963) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [11139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11139) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [11210](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11210) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [11252](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11252) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [11261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11261) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [11271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11271) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [11319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11319) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [11346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11346) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [11381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11381) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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
| [322](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L322) | `characterInfo(deck)` | Extracts player position, health, and seat status on raft. |
| [357](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L357) | `damagedStations(snap)` | Checks damage state across all raft stations. |
| [367](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L367) | `headingOf(vector)` | Computes compass heading angle from direction vector. |
| [371](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L371) | `takeSample(now, dt)` | Captures comprehensive telemetry physics/steering sample. |
| [456](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L456) | `outputPath(name)` | Generates file path for output session log. |
| [460](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L460) | `surveyPath()` | Returns path for geometry survey JSON cache. |
| [464](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L464) | `loadSurvey()` | Loads cached cliff facade and cutaway survey data. |
| [477](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L477) | `partRecord(part)` | Extracts spatial bounding box record for geometry part. |
| [485](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L485) | `partKey(part)` | Generates unique identifier string for surveyed part. |
| [490](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L490) | `surveyFacades(fjord)` | Scans and records geometric cliff faces along river. |
| [512](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L512) | `surveyCutaways(fjord)` | Surveys cutaways and obstacle bounds along river. |
| [545](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L545) | `saveSurvey(force)` | Saves river geometry survey data to disk file. |
| [561](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L561) | `stormAttributes()` | Extracts active storm parameters from lighting/replicated storage. |
| [570](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L570) | `startSession(id)` | Initializes telemetry session file and begins logging. |
| [605](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L605) | `endSession(reason)` | Finalizes telemetry session and closes log file. |
| [629](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L629) | `observeSnapshot(snap)` | Processes server-broadcast raft position snapshot. |
| [690](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L690) | `dockDetails(snap)` | Parses dock station information from snapshot. |
| [704](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L704) | `onSnapshot(snap)` | Event listener for rafting snapshot network packets. |
| [724](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L724) | `onClientEvent(name, payload)` | Dispatcher for incoming client network events. |
| [755](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L755) | `watchStormWarnings(folder)` | Monitors workspace folder for incoming storm telegraphs. |
| [772](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L772) | `pollChest()` | Checks for reward chest presence in clearings. |
| [794](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L794) | `installOutgoingHook()` | Hooks namecall to log outgoing network requests. |
| [807](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L807) | `handler(self, ...)` | Namecall proxy hook handler function. |
| [822](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L822) | `drainOutgoing()` | Flushes captured outgoing network packets. |
| [842](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L842) | `createLabel()` | Creates on-screen HUD telemetry text label. |
| [866](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L866) | `updateLabel()` | Refreshes on-screen HUD text with current voyage metrics. |

---

## Skin Hunter & Sniper (`skinhunter.lua`)

**Path**: [`luascripts/skinhunter.lua`](file:///Users/jsph/cowhub/luascripts/skinhunter.lua)

Auction sniper and server-hopper for rare animal and Halloween event skins with Discord webhook alerts.

**Total Functions**: `24`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [37](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L37) | `log(msg)` | Prints formatted console log message. |
| [41](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L41) | `countKeys(tbl)` | Counts entries in dictionary table. |
| [54](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L54) | `destroyAllRayfieldGuis()` | Cleans up existing Rayfield UI instances from CoreGui. |
| [134](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L134) | `queueReload()` | Queues script reload on server hop. |
| [192](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L192) | `getTargetSkinList()` | Returns configured table of target mob skins. |
| [196](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L196) | `isTargetSkin(skinId)` | Checks if skin ID matches target list. |
| [201](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L201) | `areTargetSkinsEqual(listA, listB)` | Compares two skin configuration tables for equality. |
| [212](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L212) | `getTargetSkinsDisplayString(maxItems)` | Formats skin list into human-readable string. |
| [227](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L227) | `setTargetSkins(newList, shouldResetQueue)` | Updates configured target skins table. |
| [268](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L268) | `loadConfig()` | Restores all toggle and slider states from local config file. |
| [325](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L325) | `loadState()` | Loads persistent sniper state from disk file. |
| [516](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L516) | `getAuctionSkins()` | Collects skins currently listed on auction. |
| [521](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L521) | `add(id)` | Adds skin entry to auction lot list. |
| [528](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L528) | `addHalloween(id)` | Adds event Halloween skin entry to lot list. |
| [700](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L700) | `sendWebhook(title, description, color, fields)` | Sends Discord webhook notification for found skins. |
| [726](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L726) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [777](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L777) | `getAuctionData()` | Fetches raw auction house lot data from server. |
| [822](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L822) | `isServerLot(lot, lotName)` | Validates if lot belongs to current game server. |
| [840](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L840) | `getAuctionRemainingTime(skinAuction)` | Extracts remaining time on skin auction lot. |
| [862](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L862) | `formatRemainingTime(seconds)` | Formats remaining seconds into readable time string. |
| [869](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L869) | `checkForTargetSkin()` | Scans auction house for desired target skins. |
| [1103](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L1103) | `hopToServer(target)` | Teleports client to target server via TeleportService. |
| [1197](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L1197) | `waitForAuctionChange()` | Yields until auction house lot rotation occurs. |
| [1254](file:///Users/jsph/cowhub/luascripts/skinhunter.lua#L1254) | `checkServerLotUpdate()` | Checks if server lot attributes updated. |

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

