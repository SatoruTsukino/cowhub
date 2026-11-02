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
| [267](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L267) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [297](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L297) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L595) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L630) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L647) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L661) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [678](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L678) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [689](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L689) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [696](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L696) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [790](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L790) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [807](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L807) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [845](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L845) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L883) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [954](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L954) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L962) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [986](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L986) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1050](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1050) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1101) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1272) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1295](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1295) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1341](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1341) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1349](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1349) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1375) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1387) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1436) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1451) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1512](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1512) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1550) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1582) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [1639](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1639) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [1646](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1646) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [1653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1653) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [1666](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1666) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [1674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1674) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [1682](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1682) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [1695](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1695) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [1704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1704) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [1721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1721) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [1735](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1735) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [1742](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1742) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [1768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1768) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [1816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1816) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [1838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1838) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [1863](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1863) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [1877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1877) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [1891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1891) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [1952](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1952) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [1962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1962) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [1975](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1975) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2104) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2135) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2139) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2164](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2164) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2175) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2179](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2179) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2195) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2250](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2250) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2254](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2254) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2280) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2284](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2284) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2329](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2329) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2334](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2334) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2413) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2434) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2450](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2450) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2454) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2480) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2486](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2486) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2490) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2494](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2494) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2499](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2499) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [2543](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2543) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [2555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2555) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [2588](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2588) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [2649](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2649) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [2710](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2710) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [2751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2751) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [2771](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2771) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [2791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2791) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [2820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2820) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [2849](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2849) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [2955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2955) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [2984](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2984) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3087) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3132](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3132) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3144](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3144) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3160](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3160) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3185](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3185) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3191) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3198](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3198) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3207) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3245](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3245) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3298) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3312) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3351) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3376) | `chestESP.cleanup()` | Clears highlight and billboard adornments on chests. |
| [3392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3392) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3451) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [3490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3490) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [3502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3502) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [3585](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3585) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [3597](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3597) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [3675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3675) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [3697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3697) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [3707](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3707) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [3768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3768) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [3780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3780) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [3854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3854) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [3888](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3888) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [3945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3945) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4253](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4253) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4298) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4371) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4403) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [4442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4442) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [4508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4508) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [4548](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4548) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [4791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4791) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [4897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4897) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [4913](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4913) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5019](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5019) | `farm.applyGoldenAura(customRadius)` | Applies golden grass harvesting pulses periodically. |
| [5055](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5055) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5085](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5085) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5163) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5167](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5167) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5174) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6077) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6081) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6093](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6093) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6136](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6136) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6150) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6267](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6267) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6345](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6345) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6371) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6400) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6433](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6433) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [6513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6513) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [6583](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6583) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [6673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6673) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [6694](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6694) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [6711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6711) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [6734](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6734) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [6824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6824) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [6838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6838) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [6876](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6876) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [6904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6904) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [6958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6958) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [6995](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6995) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7021) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7050](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7050) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7083) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7091) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7200) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7298) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7312) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7328) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7333) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7356](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7356) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7376) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [7673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7673) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [7690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7690) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [7710](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7710) | `rafting.getRaftDeck()` | Finds player raft deck part in workspace. |
| [7776](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7776) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [7787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7787) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [7808](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7808) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [7819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7819) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [7831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7831) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [7858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7858) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [7962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7962) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [7982](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7982) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [7987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7987) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8049](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8049) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8065) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8083) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8108) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8123) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8195) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8239](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8239) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8298) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [8383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8383) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [8423](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8423) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [8456](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8456) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [8503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8503) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [8530](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8530) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [8641](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8641) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [8663](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8663) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [8682](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8682) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [8720](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8720) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [8727](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8727) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [8781](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8781) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [8858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8858) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [8874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8874) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9015](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9015) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9046](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9046) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9118](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9118) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9143) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9165](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9165) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9177) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9195) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9201) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9242) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9281) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9343](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9343) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [9408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9408) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [9418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9418) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [9434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9434) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [9461](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9461) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. |
| [9508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9508) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [9614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9614) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [9677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9677) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [9746](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9746) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [9760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9760) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [9781](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9781) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [9787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9787) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [9838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9838) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [9851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9851) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [9874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9874) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [9936](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9936) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [9944](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9944) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [9958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9958) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [9964](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9964) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [9977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9977) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [9983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9983) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10039](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10039) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10077) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [10189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10189) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [10200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10200) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [10206](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10206) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [10226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10226) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [10248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10248) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10261) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10291) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [10318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10318) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [10358](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10358) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [10399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10399) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [10664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10664) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [10675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10675) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11119) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [11162](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11162) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [11179](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11179) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [11355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11355) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [11429](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11429) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [11471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11471) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [11480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11480) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [11490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11490) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [11549](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11549) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [11581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11581) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [11616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11616) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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
| [458](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L458) | `outputPath(name)` | Generates file path for output session log. |
| [462](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L462) | `surveyPath()` | Returns path for geometry survey JSON cache. |
| [466](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L466) | `loadSurvey()` | Loads cached cliff facade and cutaway survey data. |
| [479](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L479) | `partRecord(part)` | Extracts spatial bounding box record for geometry part. |
| [487](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L487) | `partKey(part)` | Generates unique identifier string for surveyed part. |
| [518](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L518) | `surveyFacades(fjord)` | Scans and records geometric cliff faces along river. |
| [540](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L540) | `surveyCutaways(fjord)` | Surveys cutaways and obstacle bounds along river. |
| [573](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L573) | `saveSurvey(force)` | Saves river geometry survey data to disk file. |
| [589](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L589) | `stormAttributes()` | Extracts active storm parameters from lighting/replicated storage. |
| [598](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L598) | `startSession(id)` | Initializes telemetry session file and begins logging. |
| [633](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L633) | `endSession(reason)` | Finalizes telemetry session and closes log file. |
| [657](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L657) | `observeSnapshot(snap)` | Processes server-broadcast raft position snapshot. |
| [718](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L718) | `dockDetails(snap)` | Parses dock station information from snapshot. |
| [732](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L732) | `onSnapshot(snap)` | Event listener for rafting snapshot network packets. |
| [752](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L752) | `onClientEvent(name, payload)` | Dispatcher for incoming client network events. |
| [783](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L783) | `watchStormWarnings(folder)` | Monitors workspace folder for incoming storm telegraphs. |
| [800](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L800) | `pollChest()` | Checks for reward chest presence in clearings. |
| [822](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L822) | `installOutgoingHook()` | Hooks namecall to log outgoing network requests. |
| [835](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L835) | `handler(self, ...)` | Namecall proxy hook handler function. |
| [850](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L850) | `drainOutgoing()` | Flushes captured outgoing network packets. |
| [870](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L870) | `createLabel()` | Creates on-screen HUD telemetry text label. |
| [894](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L894) | `updateLabel()` | Refreshes on-screen HUD text with current voyage metrics. |

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

