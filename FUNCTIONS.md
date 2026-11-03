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
| [966](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L966) | `resolveCowHubPath(fileName)` | Resolves path inside dedicated cowhub folder and migrates legacy root files. |
| [1011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1011) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1019](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1019) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1043) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1107) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1158) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1331](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1331) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1354](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1354) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1400) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1408) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1434) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1446](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1446) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1495](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1495) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1510](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1510) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1571) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1609) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1641](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1641) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [1698](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1698) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [1705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1705) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [1712](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1712) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [1725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1725) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [1733](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1733) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [1741](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1741) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [1754](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1754) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [1763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1763) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [1780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1780) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [1794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1794) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [1801](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1801) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [1827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1827) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [1875](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1875) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [1897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1897) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [1922](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1922) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [1936](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1936) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [1950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1950) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2011) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2021) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2034) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2163) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2194](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2194) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2198](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2198) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2223) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2234) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2238) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2254](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2254) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2309) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2313](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2313) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2339) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2343](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2343) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2388](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2388) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2393) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2472](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2472) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2493) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2509) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2513) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2539](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2539) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2545](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2545) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2549](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2549) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2553) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2558](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2558) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [2602](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2602) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [2614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2614) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [2647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2647) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [2708](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2708) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [2769](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2769) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [2810](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2810) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [2830](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2830) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [2850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2850) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [2879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2879) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [2908](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2908) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3014](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3014) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3043) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3146) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3191) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3203) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3219) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3244) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3250](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3250) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3257](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3257) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3266) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3304](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3304) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3357](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3357) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3371) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3410) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3450](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3450) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [3466](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3466) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [3478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3478) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3538) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [3628](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3628) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [3640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3640) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [3723](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3723) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [3735](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3735) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [3813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3813) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [3835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3835) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [3845](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3845) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [3906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3906) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [3918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3918) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [3992](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3992) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4026) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4083) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4391](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4391) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4436) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4509) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4541](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4541) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [4580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4580) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [4646](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4646) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [4686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4686) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [4929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4929) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5035) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5051](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5051) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5157) | `farm.applyGoldenAura(customRadius)` | Applies golden grass harvesting pulses periodically. |
| [5193](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5193) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5223) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5301) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5305](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5305) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5312) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6215) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6219) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6231](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6231) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6274) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6288](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6288) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6405](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6405) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6483](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6483) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6509) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6538) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6571) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [6651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6651) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [6721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6721) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [6811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6811) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [6832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6832) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [6849](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6849) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [6872](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6872) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [6962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6962) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [6976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6976) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7014](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7014) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7042](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7042) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7096](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7096) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7133](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7133) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7159) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7188](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7188) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7221) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7229](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7229) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7338) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7436) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7450](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7450) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7466](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7466) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7471) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7494](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7494) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7514](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7514) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [7811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7811) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [7828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7828) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [7849](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7849) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [7858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7858) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [7929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7929) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [7940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7940) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [7961](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7961) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [7972](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7972) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [7984](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7984) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8011) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8115](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8115) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8135) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8140](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8140) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8202) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8218](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8218) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8236](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8236) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8261) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8276](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8276) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8348](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8348) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8392) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8451) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [8536](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8536) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [8576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8576) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [8609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8609) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [8656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8656) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [8683](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8683) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [8794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8794) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [8816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8816) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [8835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8835) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [8873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8873) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [8880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8880) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [8934](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8934) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9011) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9027](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9027) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9168) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9199](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9199) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9271) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9296) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9318) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9330](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9330) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9348](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9348) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9354](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9354) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9395) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9434) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9496) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [9561](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9561) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [9571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9571) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [9587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9587) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [9614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9614) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. |
| [9661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9661) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [9767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9767) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [9830](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9830) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [9899](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9899) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [9913](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9913) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [9934](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9934) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [9940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9940) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [9991](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9991) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10004) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10027](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10027) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10089](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10089) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10097](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10097) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10111) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10117) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10130) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10136](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10136) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10192) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10230](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10230) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [10342](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10342) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [10353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10353) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [10359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10359) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [10379](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10379) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [10401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10401) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10414](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10414) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10444) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [10471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10471) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [10511](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10511) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [10552](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10552) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [10817](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10817) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [10828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10828) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11272) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [11315](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11315) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [11332](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11332) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [11508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11508) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [11582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11582) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [11624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11624) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [11633](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11633) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [11643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11643) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [11702](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11702) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [11734](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11734) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [11769](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11769) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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
| [485](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L485) | `partRecord(part)` | Extracts spatial bounding box record for geometry part. |
| [493](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L493) | `partKey(part)` | Generates unique identifier string for surveyed part. |
| [524](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L524) | `surveyFacades(fjord)` | Scans and records geometric cliff faces along river. |
| [546](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L546) | `surveyCutaways(fjord)` | Surveys cutaways and obstacle bounds along river. |
| [579](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L579) | `saveSurvey(force)` | Saves river geometry survey data to disk file. |
| [595](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L595) | `stormAttributes()` | Extracts active storm parameters from lighting/replicated storage. |
| [604](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L604) | `startSession(id)` | Initializes telemetry session file and begins logging. |
| [639](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L639) | `endSession(reason)` | Finalizes telemetry session and closes log file. |
| [663](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L663) | `observeSnapshot(snap)` | Processes server-broadcast raft position snapshot. |
| [724](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L724) | `dockDetails(snap)` | Parses dock station information from snapshot. |
| [738](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L738) | `onSnapshot(snap)` | Event listener for rafting snapshot network packets. |
| [758](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L758) | `onClientEvent(name, payload)` | Dispatcher for incoming client network events. |
| [789](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L789) | `watchStormWarnings(folder)` | Monitors workspace folder for incoming storm telegraphs. |
| [806](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L806) | `pollChest()` | Checks for reward chest presence in clearings. |
| [828](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L828) | `installOutgoingHook()` | Hooks namecall to log outgoing network requests. |
| [841](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L841) | `handler(self, ...)` | Namecall proxy hook handler function. |
| [856](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L856) | `drainOutgoing()` | Flushes captured outgoing network packets. |
| [876](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L876) | `createLabel()` | Creates on-screen HUD telemetry text label. |
| [900](file:///Users/jsph/cowhub/luascripts/voyage_telemetry.lua#L900) | `updateLabel()` | Refreshes on-screen HUD text with current voyage metrics. |

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

