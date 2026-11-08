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
| [792](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L792) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L827) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [844](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L844) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L858) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [875](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L875) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L886) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [893](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L893) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L987) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1006](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1006) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1044) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1083) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1161) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1233) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1241) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1266) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1337) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1388](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1388) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1572) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1595) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1640) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1648](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1648) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1674) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1686) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1735](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1735) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1750](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1750) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1811) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1851) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1883) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2437) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2444) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2451) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2464) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2474) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2480) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2506](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2506) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2515](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2515) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2532](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2532) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2547) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2554](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2554) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2580) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2630) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2653) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2678](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2678) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1944](file:///Users/jsph/cowhub/luascripts/preview.lua#L1944) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1953](file:///Users/jsph/cowhub/luascripts/preview.lua#L1953) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2034) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2049](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2049) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L352) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2070](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2070) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2104) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2205](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2205) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2225](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2225) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2235](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2235) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2244) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2256) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2282) | `chomp.release()` | Releases a held E key. |
| [2293](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2293) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2305](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2305) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2333) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2346) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2359) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2371) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2692) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2706](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2706) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2767) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2777) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2790](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2790) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2921) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2952](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2952) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2956) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2981](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2981) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2992](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2992) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2996) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3012) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3067](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3067) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3071) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3097](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3097) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3101) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3146) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3151) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3230](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3230) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3251](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3251) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3267](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3267) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3271) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3297](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3297) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3303](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3303) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3307](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3307) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3311](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3311) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3317) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3361) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3373](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3373) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3406](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3406) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3467](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3467) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3528) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3569](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3569) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3589) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3609) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3638) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3667) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3773) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3802) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3905](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3905) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3950) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3962) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3978](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3978) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4003](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4003) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4009](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4009) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4016](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4016) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4025) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4063](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4063) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4116](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4116) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4130) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4169](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4169) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4210](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4210) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4226) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4239](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4239) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4303](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4303) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4397](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4397) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4409](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4409) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4492) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4504](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4504) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4582) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4604](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4604) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4674) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4736) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4748](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4748) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4816) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4850) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 4911](file:///Users/jsph/cowhub/luascripts/preview.lua#L4911) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [4927](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4927) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5245](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5245) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5290](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5290) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5363) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5395) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5434) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5501](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5501) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5547) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5589) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5623](file:///Users/jsph/cowhub/luascripts/preview.lua#L5623) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5642](file:///Users/jsph/cowhub/luascripts/preview.lua#L5642) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5648](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5648) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5888](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5888) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5996) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [6013](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6013) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [6152](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6152) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [6183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6183) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [6261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6261) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [6265](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6265) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [6273](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6273) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4634](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4634) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [7152](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7152) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [7167](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7167) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [7228](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7228) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [7234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7234) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7331](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7331) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7409](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7409) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7435) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7464) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7497](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7497) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7593) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7665](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7665) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7758](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7758) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7779](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7779) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7836](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7836) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7859) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7944](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7944) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7958) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7996) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [8025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8025) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [8079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8079) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [8116](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8116) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8142](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8142) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [8171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8171) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [8209](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8209) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [8217](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8217) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8329](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8329) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8428](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8428) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8437) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8453](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8453) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8458](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8458) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8483](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8483) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8503) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8807](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8807) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8824) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8845](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8845) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8854) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8927](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8927) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8939](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8939) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8960) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8971) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8983) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [9010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9010) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [9114](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9114) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [9134](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9134) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [9139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9139) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [9203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9203) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [9219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9219) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9237](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9237) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9262) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9277](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9277) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9349](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9349) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9393) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9452](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9452) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9537](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9537) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9577) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9610) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9657) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9686) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9705) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9818) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9840) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9859) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9897) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9904) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9960) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [10038](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10038) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [10054](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10054) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [10197](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10197) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [10228](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10228) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10301) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10326](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10326) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10348](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10348) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10362](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10362) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10380](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10380) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10386) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10427](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10427) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10466](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10466) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10528) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10593) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10603](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10603) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10619) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10649](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10649) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10697) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10804](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10804) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10869) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10938](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10938) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10952](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10952) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10973) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10978](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10978) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10992](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10992) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [11011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11011) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [11065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11065) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [11078](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11078) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [11101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11101) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [11163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11163) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [11171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11171) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [11185](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11185) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [11191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11191) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [11204](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11204) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [11210](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11210) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11266) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11304](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11304) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11417](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11417) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11428](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11428) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11434) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11454) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11476](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11476) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11490) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11520](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11520) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11547) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11587) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11628](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11628) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11901) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11912](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11912) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12379](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12379) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12422) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12439](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12439) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12615) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12690) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12722](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12722) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12742](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12742) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12751) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12761](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12761) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12822) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12854) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12889](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12889) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

