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
| [70](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L70) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [114](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L114) | `resolveCharacter()` | Finds current player character model reliably. |
| [128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L128) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [148](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L148) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L155) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L174) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L192) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [230](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L230) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L280) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [310](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L310) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L621) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L656) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L673) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [687](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L687) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L704) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L715) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [722](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L722) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L816) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L833) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [871](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L871) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L909) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [984](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L984) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1053) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1061](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1061) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1085](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1085) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1151) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1202) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1382](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1382) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1405](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1405) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1451) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1459](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1459) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1485](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1485) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1497](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1497) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1546](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1546) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1561](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1561) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1622](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1622) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1660) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1692) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [1991](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1991) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [1998](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1998) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2005](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2005) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2018) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2026) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2034) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2047](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2047) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2056) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2073](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2073) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2087) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2094](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2094) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2120) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2168) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2190](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2190) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2215) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1757](file:///Users/jsph/cowhub/luascripts/preview.lua#L1757) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1766](file:///Users/jsph/cowhub/luascripts/preview.lua#L1766) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [1753](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1753) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [1768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1768) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [1777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1777) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [1830](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1830) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [1849](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1849) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [1859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1859) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [1868](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1868) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [1880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1880) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [1904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1904) | `chomp.release()` | Releases a held E key. |
| [1914](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1914) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [1925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1925) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [1952](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1952) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2229](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2229) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2243) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2304](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2304) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2314) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2327) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2456](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2456) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2487](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2487) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2491](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2491) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2516) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2527](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2527) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2531](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2531) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2547) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2602](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2602) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2606](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2606) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2632](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2632) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2636) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2681](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2681) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2686) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2765](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2765) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2786](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2786) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2802) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2806](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2806) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2832) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2838) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2842](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2842) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2846](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2846) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2851) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [2895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2895) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [2907](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2907) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [2940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2940) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3001](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3001) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3062](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3062) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3103) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3123) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3143) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3172](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3172) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3201) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3307](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3307) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3336) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3439](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3439) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3484) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3496) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3512](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3512) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3537](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3537) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3543](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3543) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3550) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3559](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3559) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3597](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3597) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3650](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3650) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3664) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3703](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3703) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3743](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3743) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [3759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3759) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [3771](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3771) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3831) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [3921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3921) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [3933](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3933) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4016](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4016) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4028](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4028) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4106) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4128) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4138) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4199](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4199) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4211](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4211) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4285](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4285) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4319) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4376) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4684](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4684) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4729) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4802) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4834](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4834) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [4873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4873) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [4939](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4939) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [4979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4979) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5222](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5222) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5330](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5330) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5347](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5347) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5450](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5450) | `farm.applyGoldenAura(customRadius)` | Applies golden grass harvesting pulses periodically. |
| [5486](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5486) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5516) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5594) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5598](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5598) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5605](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5605) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6517) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6521](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6521) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6533) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6576) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6590](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6590) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6707](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6707) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6785) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6811) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6840) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6873) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [6953](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6953) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7023) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7113) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7134](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7134) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7151) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7174) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7264](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7264) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7278) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7316) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7344](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7344) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7398) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7435) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7461](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7461) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7490) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7523](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7523) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7531](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7531) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7640) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7738) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7752](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7752) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7768) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7773) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7796](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7796) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7816) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8113) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8130) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8151) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8160](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8160) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8231](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8231) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8242) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8263) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8274) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8286](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8286) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8313](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8313) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8417](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8417) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8437) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8442) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8504](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8504) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8520](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8520) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8538) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8563](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8563) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8578](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8578) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8650](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8650) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8694](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8694) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8753](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8753) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [8838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8838) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [8878](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8878) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [8911](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8911) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [8958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8958) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [8987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8987) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9006](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9006) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9117) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9139) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9158) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9196) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9203) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9257](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9257) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9334](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9334) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9350](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9350) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9491](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9491) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9522](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9522) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9594) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9619) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9641](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9641) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9653) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9671) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9677) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9718](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9718) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9757) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9819) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [9884](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9884) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [9894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9894) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [9910](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9910) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [9940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9940) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [9988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9988) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10094](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10094) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10157) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10226) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10240) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10261) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10266) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10280) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10299](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10299) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10353) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10366](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10366) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10389](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10389) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10451) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10459](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10459) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10473](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10473) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10479) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10492) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10498) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10554](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10554) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10592](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10592) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [10704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10704) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [10715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10715) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [10721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10721) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [10741](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10741) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [10763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10763) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10776](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10776) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10806](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10806) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [10833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10833) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [10873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10873) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [10914](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10914) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11187](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11187) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11198](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11198) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11665](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11665) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [11708](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11708) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [11725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11725) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [11901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11901) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [11976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11976) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12008](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12008) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12028](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12028) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12037](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12037) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12047](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12047) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12108) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12140](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12140) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12175) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

