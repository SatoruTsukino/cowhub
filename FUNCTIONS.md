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
| [4375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4375) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4437) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4449](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4449) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4517) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4551](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4551) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4608](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4608) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4916](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4916) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4961](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4961) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5034) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5066](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5066) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5105](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5105) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5171) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [preview 5341](file:///Users/jsph/cowhub/luascripts/preview.lua#L5341) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`); staging only (Plan 1.7). |
| [5235](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5235) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5442) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5550) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5567](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5567) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5665](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5665) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5695](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5695) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5773) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5777) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5784](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5784) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6702](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6702) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6707](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6707) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6757) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6818) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6824) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6918) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6996) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7022](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7022) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7051](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7051) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7084](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7084) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7177) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7249) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7353) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7374](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7374) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7431](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7431) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7454) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7539](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7539) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7553) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7591](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7591) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7619) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7673) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7710](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7710) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7736) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7765](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7765) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7803](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7803) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7811) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7923](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7923) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8021) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8035) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8051](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8051) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8056) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8081) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8101) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8413) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8430) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8451) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8460](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8460) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8531](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8531) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8542) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8563](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8563) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8574](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8574) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8586](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8586) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8613](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8613) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8717) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8737](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8737) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8742](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8742) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8804](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8804) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8820) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8838) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8863](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8863) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8878](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8878) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8950) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8994](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8994) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9053) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9138) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9178) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9211](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9211) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9258](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9258) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9287) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9306) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9417](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9417) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9439](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9439) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9458](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9458) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9496) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9503) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9557](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9557) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9634](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9634) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9650](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9650) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9791) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9822) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9894) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9919](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9919) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9941](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9941) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9953](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9953) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9971) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9977) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10018) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10057](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10057) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10119) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10184](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10184) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10194](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10194) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10210](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10210) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10240) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10288](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10288) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10394) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10457](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10457) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10526) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10540](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10540) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10561](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10561) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10566](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10566) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10580) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10599](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10599) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10653) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10666](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10666) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10689](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10689) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10751) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10759) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10773) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10779](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10779) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10792](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10792) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10798](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10798) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10854) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10892](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10892) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11004) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11015](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11015) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11021) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11041](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11041) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11063](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11063) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11076](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11076) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11106) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11133](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11133) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11173](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11173) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11214](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11214) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11487](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11487) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11498) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11965](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11965) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12008](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12008) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12025) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12201) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12276](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12276) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12308](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12308) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12328) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12337) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12347](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12347) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12408) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12440](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12440) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12475](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12475) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

