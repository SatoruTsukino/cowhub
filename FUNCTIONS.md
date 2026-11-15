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
| [181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L181) | `resolveCharacter()` | Finds current player character model reliably. |
| [195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L195) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L215) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [222](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L222) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L241) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [259](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L259) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [297](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L297) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [366](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L366) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [397](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L397) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L827) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [862](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L862) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L879) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [893](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L893) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [910](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L910) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L921) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [1002](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1002) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1021) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1059](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1059) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1098) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1176](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1176) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1248) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1256) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1287) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1324](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1324) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1353) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1425](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1425) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1476](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1476) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1676) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1699) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1744) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1752](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1752) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1778](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1778) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1790](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1790) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1839](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1839) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1854) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1915](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1915) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1955) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1987) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2548](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2548) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2555) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2562](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2562) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2575](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2575) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2585](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2585) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2597](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2597) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2612](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2612) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2638) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2647) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2664) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2679) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2686) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2712](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2712) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2762) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2785) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2810](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2810) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2048](file:///Users/jsph/cowhub/luascripts/preview.lua#L2048) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2057](file:///Users/jsph/cowhub/luascripts/preview.lua#L2057) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2138](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2138) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2153) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L351) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2174) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2208](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2208) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2320](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2320) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2336) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2346) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2355) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2367) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2393) | `chomp.release()` | Releases a held E key. |
| [2404](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2404) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2416) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2444) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2457](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2457) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2470) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2482](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2482) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2824) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2838) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2899](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2899) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2909) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2922](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2922) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3053) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3084](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3084) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3088) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3113](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3113) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3124) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3128) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3144](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3144) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3199](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3199) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3203) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3229](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3229) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3233) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3278) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3283](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3283) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3362](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3362) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3383) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3399) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3403) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3429](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3429) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3435) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3439](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3439) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3443](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3443) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3449](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3449) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3493) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3505) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3538) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3599](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3599) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3660) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3701) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3721) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3741](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3741) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3770) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3799](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3799) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3905](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3905) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3934](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3934) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4037](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4037) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4082](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4082) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4094](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4094) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4110](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4110) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4135) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4141](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4141) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4148](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4148) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4157) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4195) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4248) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4262) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4301) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4342](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4342) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4358](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4358) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4371) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4435](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4435) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4529](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4529) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4541](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4541) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4624) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4636) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4714](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4714) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4736) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4806](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4806) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4868](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4868) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4880) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4942) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4976) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5037](file:///Users/jsph/cowhub/luascripts/preview.lua#L5037) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5053) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5371) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5416) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5489](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5489) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5521](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5521) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5560](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5560) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5627](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5627) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5673) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5715) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5749](file:///Users/jsph/cowhub/luascripts/preview.lua#L5749) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5768](file:///Users/jsph/cowhub/luascripts/preview.lua#L5768) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5774) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [6015](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6015) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [6123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6123) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [6140](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6140) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [6286](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6286) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [6317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6317) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [6395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6395) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [6399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6399) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [6407](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6407) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4766](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4766) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [7316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7316) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [7331](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7331) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [7392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7392) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [7398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7398) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [7495](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7495) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [7573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7573) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7599](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7599) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [7628](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7628) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [7661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7661) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7757) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7829](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7829) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7922](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7922) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7943](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7943) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [8000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8000) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [8023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8023) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [8108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8108) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [8122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8122) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [8160](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8160) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [8189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8189) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [8243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8243) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [8280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8280) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8306) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [8335](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8335) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [8373](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8373) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [8381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8381) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [8493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8493) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [8592](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8592) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [8601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8601) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [8617](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8617) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [8622](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8622) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [8647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8647) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [8667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8667) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8971) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8988) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [9009](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9009) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [9018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9018) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [9091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9091) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [9103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9103) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [9124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9124) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [9135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9135) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [9147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9147) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [9174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9174) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [9278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9278) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [9298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9298) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [9303](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9303) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [9367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9367) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [9383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9383) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [9401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9401) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [9426](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9426) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [9441](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9441) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [9513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9513) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [9557](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9557) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [9616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9616) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9701) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9741](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9741) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9774) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9821](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9821) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9850) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9869) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9982](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9982) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [10004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10004) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [10023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10023) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [10061](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10061) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [10068](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10068) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [10124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10124) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [10202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10202) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [10218](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10218) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [10361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10361) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [10392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10392) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [10465](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10465) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [10490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10490) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [10512](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10512) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [10526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10526) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [10544](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10544) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [10550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10550) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [10591](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10591) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [10630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10630) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [10692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10692) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10757) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10767) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10783](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10783) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10813) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10861](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10861) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10968](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10968) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [11033](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11033) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [11102](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11102) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [11116](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11116) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [11137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11137) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [11142](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11142) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [11156](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11156) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [11175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11175) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [11229](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11229) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [11242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11242) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [11265](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11265) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [11327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11327) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [11335](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11335) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [11349](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11349) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [11355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11355) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [11368](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11368) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [11374](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11374) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [11430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11430) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [11468](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11468) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [11581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11581) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [11592](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11592) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [11598](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11598) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [11618](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11618) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [11640](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11640) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [11654](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11654) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [11684](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11684) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11711) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11751) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11792](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11792) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [12065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12065) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [12076](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12076) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [12543](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12543) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [12586](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12586) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [12603](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12603) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12779](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12779) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12854) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12886) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12906) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12915](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12915) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12925) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12986](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12986) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [13018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13018) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [13053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13053) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

