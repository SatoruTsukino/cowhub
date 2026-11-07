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
| [293](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L293) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [323](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L323) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L697) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [732](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L732) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [749](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L749) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L763) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L780) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L791) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [798](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L798) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [892](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L892) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L909) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [947](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L947) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [985](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L985) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1060](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1060) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1129](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1129) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1137) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1161) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1230](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1230) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1281) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1465](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1465) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1488](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1488) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1534) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1542) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1568](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1568) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1580) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1629](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1629) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1644](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1644) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1705) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1743](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1743) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1775](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1775) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2196) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2203) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2210](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2210) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2223) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2233) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2239](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2239) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2265](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2265) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2274) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2291) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2305](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2305) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2312) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2338](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2338) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2388](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2388) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2410) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2435) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1841](file:///Users/jsph/cowhub/luascripts/preview.lua#L1841) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1850](file:///Users/jsph/cowhub/luascripts/preview.lua#L1850) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [1836](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1836) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [1851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1851) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L282) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [1871](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1871) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [1904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1904) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [1973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1973) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [1992](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1992) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2002) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2011) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2023) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2047](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2047) | `chomp.release()` | Releases a held E key. |
| [2057](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2057) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2068](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2068) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2095](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2095) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2107) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2120) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2132](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2132) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2449](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2449) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2463](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2463) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2524](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2524) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2534) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2547) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2676) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2707](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2707) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2711) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2736) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2747](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2747) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2751) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2767) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2822) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2826) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2852](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2852) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2856](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2856) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2901) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2906) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2985](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2985) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3006](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3006) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3022](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3022) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3026) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3052](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3052) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3058](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3058) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3062](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3062) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3066](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3066) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3071) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3115](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3115) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3127) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3160](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3160) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3221) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3282) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3323](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3323) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3343](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3343) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3363) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3392) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3421](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3421) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3527](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3527) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3556](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3556) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3659](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3659) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3704) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3716](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3716) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3732](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3732) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3757) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3763) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3770) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3779](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3779) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3817](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3817) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3870](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3870) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3884](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3884) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3923](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3923) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3963](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3963) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [3979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3979) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [3991](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3991) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4051](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4051) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4141](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4141) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4153) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4236](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4236) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4248) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4326](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4326) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4348](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4348) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4418) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4480) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4492) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4560](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4560) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4594) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4651) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4959](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4959) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5004) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5077) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5109](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5109) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5148](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5148) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5214](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5214) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [preview 5384](file:///Users/jsph/cowhub/luascripts/preview.lua#L5384) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`); staging only (Plan 1.7). |
| [5278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5278) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5485](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5485) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5593) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5610) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5708](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5708) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5738) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5816) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5820) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5827) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4378](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4378) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6744) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6759) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6820) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6826) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6920](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6920) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6998](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6998) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7024](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7024) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7053) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7086](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7086) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7179](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7179) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7251](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7251) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7355) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7376) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7433](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7433) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7456](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7456) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7541](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7541) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7555) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7593) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7621) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7675) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7712](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7712) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7738) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7767) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7805](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7805) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7813) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7925) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8023) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8037](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8037) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8053) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8058](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8058) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8083) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8103) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8415](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8415) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8432) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8453](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8453) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8462](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8462) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8533) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8544](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8544) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8565](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8565) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8576) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8588](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8588) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8615) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8719](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8719) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8739](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8739) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8744) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8806](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8806) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8822) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8840) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8865](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8865) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8880) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8952](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8952) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8996) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9055](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9055) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9140](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9140) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9180](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9180) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9213](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9213) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9260](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9260) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9289) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9308](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9308) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9419) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9441](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9441) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9460](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9460) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9498) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9505) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9559](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9559) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9636) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9652) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9793](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9793) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9824) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9896](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9896) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9921) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9943](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9943) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9955) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9973) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9979) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10020](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10020) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10059](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10059) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10121) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10186) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10196) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10212](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10212) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10242) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10290](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10290) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10396](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10396) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10459](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10459) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10528) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10542) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10563](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10563) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10568](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10568) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10582) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10601) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10655](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10655) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10668](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10668) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10691](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10691) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10753](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10753) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10761](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10761) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10775](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10775) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10781](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10781) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10794) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10800](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10800) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10856](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10856) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10894) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11006](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11006) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11017](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11017) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11023) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11043) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11065) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11078](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11078) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11108) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11135) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11175) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11216](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11216) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11489](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11489) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11500](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11500) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11967](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11967) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12010) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12027](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12027) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12203) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12278) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12310](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12310) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12330](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12330) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12339) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12349](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12349) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12410) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12442) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12477) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

