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
| [65](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L65) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [109](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L109) | `resolveCharacter()` | Finds current player character model reliably. |
| [123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L123) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L143) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L150) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [169](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L169) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [187](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L187) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [225](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L225) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [275](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L275) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [305](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L305) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [603](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L603) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L638) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [655](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L655) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L669) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L686) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L697) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L704) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [798](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L798) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [815](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L815) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [853](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L853) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L891) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [966](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L966) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1035) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1043) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1067](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1067) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1131](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1131) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1182](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1182) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1355) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1378](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1378) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1424](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1424) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1432) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1458](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1458) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1470) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1519](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1519) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1534) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1595) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1633) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1665](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1665) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [1722](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1722) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [1729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1729) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [1736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1736) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [1749](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1749) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [1757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1757) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [1765](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1765) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [1778](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1778) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [1787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1787) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [1804](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1804) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [1818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1818) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [1825](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1825) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [1851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1851) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [1899](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1899) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [1921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1921) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [1946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1946) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [1960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1960) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [1974](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1974) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2035) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2045](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2045) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2058](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2058) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2187](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2187) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2218](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2218) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2222](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2222) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2247) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2258](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2258) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2262) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2278) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2333) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2337) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2363) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2367) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2412](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2412) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2417](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2417) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2496) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2517) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2533) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2537](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2537) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2563](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2563) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2569](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2569) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2573) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2577) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2582) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [2626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2626) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [2638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2638) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [2671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2671) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [2732](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2732) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [2793](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2793) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [2834](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2834) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [2854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2854) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [2874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2874) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [2903](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2903) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [2932](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2932) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3038](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3038) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3067](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3067) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3170](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3170) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3215) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3227](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3227) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3243) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3268](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3268) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3274) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3281) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3290](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3290) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3328) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3381) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3395) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3434) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3474) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [3490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3490) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [3502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3502) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3562](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3562) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [3652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3652) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [3664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3664) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [3747](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3747) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [3759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3759) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [3837](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3837) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [3859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3859) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [3869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3869) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [3930](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3930) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [3942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3942) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4016](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4016) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4050](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4050) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4107) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4415](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4415) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4460](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4460) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4533) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4565](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4565) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [4604](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4604) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [4670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4670) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [4710](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4710) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [4953](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4953) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5059](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5059) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5075) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5181) | `farm.applyGoldenAura(customRadius)` | Applies golden grass harvesting pulses periodically. |
| [5217](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5217) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5247) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5325](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5325) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5329](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5329) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5336) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6239](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6239) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6243) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6255](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6255) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6298) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6312) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6429](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6429) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6507](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6507) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6533) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6562](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6562) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6595) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [6675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6675) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [6745](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6745) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [6835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6835) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [6856](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6856) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [6873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6873) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [6896](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6896) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [6986](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6986) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7000) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7038](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7038) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7066](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7066) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7120) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7157) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7183) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7212](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7212) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7245](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7245) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7253](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7253) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7362](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7362) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7460](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7460) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7474) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7490) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7495](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7495) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7518](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7518) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7538) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [7835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7835) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [7852](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7852) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [7873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7873) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [7882](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7882) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [7953](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7953) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [7964](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7964) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [7985](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7985) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [7996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7996) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8008](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8008) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8035) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8139) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8159) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8164](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8164) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8226) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8242) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8260](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8260) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8285](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8285) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8300](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8300) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8372](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8372) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8416) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8475](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8475) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [8560](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8560) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [8600](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8600) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [8633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8633) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [8680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8680) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [8709](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8709) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [8728](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8728) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [8839](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8839) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [8861](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8861) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [8880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8880) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [8918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8918) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [8925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8925) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [8979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8979) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9056) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9072](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9072) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9213](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9213) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9244) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9316) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9341](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9341) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9363) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9375) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9393) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9399) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9440](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9440) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9479) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9541](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9541) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [9606](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9606) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [9616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9616) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [9632](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9632) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [9662](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9662) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [9710](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9710) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [9816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9816) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [9879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9879) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [9948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9948) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [9962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9962) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [9983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9983) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [9988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9988) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10002) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10021) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10075) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10088) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10111) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10173](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10173) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10181) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10195) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10201) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10214](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10214) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10220](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10220) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10276](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10276) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10314) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [10426](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10426) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [10437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10437) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [10443](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10443) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [10463](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10463) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [10485](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10485) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10498) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10528) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [10555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10555) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [10595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10595) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [10636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10636) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [10909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10909) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [10920](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10920) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11387) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [11430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11430) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [11447](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11447) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [11623](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11623) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [11698](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11698) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [11730](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11730) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [11750](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11750) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [11759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11759) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [11769](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11769) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [11830](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11830) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [11862](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11862) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [11897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11897) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

