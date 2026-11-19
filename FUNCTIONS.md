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
- [Field Raid Probe (`fieldraid_probe.lua`)](#field-raid-probe-fieldraid_probelua)

---

## Main Script Hub (`cowhub.lua` / `preview.lua`)

**Path**: [`luascripts/cowhub.lua`](file:///Users/jsph/cowhub/luascripts/cowhub.lua) *(synchronized with [`luascripts/preview.lua`](file:///Users/jsph/cowhub/luascripts/preview.lua))*

Primary CowHub script containing autofarm engines, mining, dodging, auction scanners, and Fjord rafting.

**Total Functions**: `290`

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
| [862](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L862) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L897) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [914](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L914) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [928](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L928) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L945) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L956) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [1037](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1037) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1056) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1094](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1094) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1133](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1133) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1211](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1211) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1283](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1283) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1291) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1322](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1322) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1359) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1388](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1388) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1460](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1460) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1511](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1511) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1711) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1734](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1734) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1779](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1779) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1787) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1813) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1825](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1825) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1874) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1889](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1889) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1950) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1990](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1990) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [2022](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2022) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2583](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2583) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2590](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2590) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2597](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2597) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2610) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2620](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2620) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2632](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2632) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2647) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2673) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2682](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2682) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2699) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2714](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2714) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2721) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2747](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2747) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2797](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2797) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2820) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2845](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2845) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2083](file:///Users/jsph/cowhub/luascripts/preview.lua#L2083) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2092](file:///Users/jsph/cowhub/luascripts/preview.lua#L2092) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2173](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2173) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2188](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2188) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L351) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2209](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2209) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2243) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2355) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2371) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2381) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2390](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2390) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2402) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2428](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2428) | `chomp.release()` | Releases a held E key. |
| [2439](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2439) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2451) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2479) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2492) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2505](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2505) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2517) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2859) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2873) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2934](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2934) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2944](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2944) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2957](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2957) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3088) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3119) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3123) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3148](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3148) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3159) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3163) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3179](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3179) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3234) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3238) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3264](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3264) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3268](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3268) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3313](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3313) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3318) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3397](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3397) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3418) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3434) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3438](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3438) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3464) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3470) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3474) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3478) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3484) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3528) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3540](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3540) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3573) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3638) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3699) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3740](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3740) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3760) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3780) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3809](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3809) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3838](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3838) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3944](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3944) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3973) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4076](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4076) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4121) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4133](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4133) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4149](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4149) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4174) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4180](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4180) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4187](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4187) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4196](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4196) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4234) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4295](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4295) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4309) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4348](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4348) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4389](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4389) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4405](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4405) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4418) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4482](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4482) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4576) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4588](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4588) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4671) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4683](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4683) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4761](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4761) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4783](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4783) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4853](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4853) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4915](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4915) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4927](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4927) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4989](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4989) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [5023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5023) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5084](file:///Users/jsph/cowhub/luascripts/preview.lua#L5084) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5100](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5100) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5418) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5463](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5463) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5536](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5536) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5568](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5568) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5607](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5607) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5674) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5720](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5720) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5762) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5796](file:///Users/jsph/cowhub/luascripts/preview.lua#L5796) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5815](file:///Users/jsph/cowhub/luascripts/preview.lua#L5815) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5821](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5821) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [7000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7000) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [7112](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7112) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [7134](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7134) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [7280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7280) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [7311](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7311) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [7389](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7389) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [7393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7393) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [7401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7401) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4813) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [8316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8316) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [8331](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8331) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [8392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8392) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [8398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8398) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [8495](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8495) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [8573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8573) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8599](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8599) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [8628](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8628) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [8661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8661) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [8757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8757) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [8829](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8829) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [8922](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8922) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [8943](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8943) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [9000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9000) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [9023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9023) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [9108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9108) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [9122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9122) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [9160](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9160) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [9189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9189) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [9243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9243) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [9280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9280) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [9306](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9306) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [9335](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9335) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [9373](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9373) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [9381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9381) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [9493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9493) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [9592](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9592) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [9601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9601) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [9617](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9617) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [9622](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9622) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [9647](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9647) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [9667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9667) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [9971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9971) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [9988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9988) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [10009](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10009) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [10018](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10018) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [10091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10091) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [10103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10103) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [10124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10124) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [10135](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10135) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [10147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10147) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [10174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10174) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [10278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10278) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [10298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10298) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [10303](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10303) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [10367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10367) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [10383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10383) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [10401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10401) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [10426](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10426) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [10441](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10441) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [10513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10513) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [10557](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10557) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [10616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10616) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [10701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10701) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [10741](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10741) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [10774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10774) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [10821](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10821) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [10850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10850) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [10869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10869) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [10982](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10982) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [11004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11004) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [11023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11023) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [11061](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11061) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [11068](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11068) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [11124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11124) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [11202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11202) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [11218](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11218) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [11361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11361) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [11392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11392) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [11465](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11465) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [11490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11490) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [11512](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11512) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [11526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11526) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [11544](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11544) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [11550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11550) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [11591](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11591) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [11630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11630) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [11692](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11692) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [11757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11757) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [11767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11767) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [11783](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11783) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [11813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11813) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [11861](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11861) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [11968](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11968) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [12033](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12033) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [12104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12104) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [12118](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12118) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [12139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12139) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [12144](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12144) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [12158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12158) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [12177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12177) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [12231](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12231) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [12244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12244) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [12267](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12267) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [12329](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12329) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [12337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12337) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [12351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12351) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [12357](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12357) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [12370](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12370) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [12376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12376) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [12432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12432) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [12470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12470) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [12583](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12583) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [12594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12594) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [12600](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12600) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [12620](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12620) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [12642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12642) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [12656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12656) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [12686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12686) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [12713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12713) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [12753](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12753) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [12794](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12794) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [13072](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13072) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [13083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13083) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [13550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13550) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [13593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13593) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [13610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13610) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [13816](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13816) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [13891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13891) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [13923](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13923) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [13960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13960) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [13969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13969) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [13979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13979) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [14040](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14040) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [14072](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14072) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [14107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14107) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |
| [6065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6065) | `fieldraid.runId()` | Current field raid run id (player attribute `CowFieldRaidId`). |
| [6069](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6069) | `fieldraid.inRaid()` | True while the cow is in a field raid run. |
| [6073](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6073) | `fieldraid.fire(...)` | Fires `FieldRaidRequest` (raid start, graze, smith job) safely. |
| [6083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6083) | `fieldraid.setStatus(text)` | Updates the Field Raid status paragraph. |
| [6093](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6093) | `fieldraid.isRaidMob(part)` | True for a raid enemy PrimaryPart (`CowBiteTargetKind` RaidMob). |
| [6097](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6097) | `fieldraid.mobAlive(part)` | Raid mob is alive when its Health attribute is above 0. |
| [6102](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6102) | `fieldraid.scan(now, force)` | Throttled pass over `NorthRiverRaidView`: live mobs and available wheat. |
| [6124](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6124) | `fieldraid.cellPoint(part, pos)` | Closest point of a wheat cell box to a position (bite distance). |
| [6133](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6133) | `fieldraid.findWheat(rootPos, now)` | Best food: in reach ripe, then richest BaseCalories, then nearest. |
| [6162](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6162) | `fieldraid.nearestMob(rootPos)` | Nearest live raid mob and its distance. |
| [6174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6174) | `fieldraid.combatMods()` | Requires the game's FieldRaidCombat / FieldRaidEnemies modules. |
| [6184](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6184) | `fieldraid.addHazard(msg)` | Records a server attack telegraph (Windup / ProjectileAim / BarrageMark). |
| [6257](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6257) | `fieldraid.dropHazards(id)` | Forgets telegraphs of a cancelled or defeated mob. |
| [6265](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6265) | `fieldraid.danger(pos, serverNow, horizon)` | Game hit test (`FieldRaidCombat.Contains`) against live telegraphs. |
| [6278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6278) | `fieldraid.dodgeStep(now, rootPos)` | Moves the cow to the nearest safe ring spot when a telegraph covers it. |
| [6323](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6323) | `fieldraid.face(pos)` | Turns the root toward a target (raid mobs need facing). |
| [6333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6333) | `fieldraid.ensureGraze()` | Sends `GrazeStart` once per run, like FieldRaidGraze.Hold. |
| [6341](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6341) | `fieldraid.chompWheat(now, rootPos)` | Bites the best raid wheat in reach via `chomp.send` (serial wire). |
| [6354](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6354) | `fieldraid.biteMob(part, now)` | Bites a raid mob via `chomp.send`, shares the mob aura cooldown. |
| [6372](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6372) | `fieldraid.forward(target, rootPos)` | Forward-only clamp: never aims behind the cow (+Z) unless banking manually. |
| [6383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6383) | `fieldraid.bandZ(level)` | Z span of a field level (FieldRaidLayout.Band on the run Planting). |
| [6394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6394) | `fieldraid.backLimit(rootPos)` | Furthest +Z allowed: whole max field when farming, else just behind the cow. |
| [6403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6403) | `fieldraid.walkTo(target, now)` | PathfindingService walk with stuck jump/sidestep recovery. |
| [6462](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6462) | `fieldraid.stopWalk()` | Clears the raid path and halts movement. |
| [6470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6470) | `fieldraid.arena()` | Private raid arena model (`Geometry.PrivateFieldRaids`). |
| [6477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6477) | `fieldraid.prompts(now)` | Rescans arena chest (`OpenHarvestChest`) and `GateExit` prompts. |
| [6495](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6495) | `fieldraid.promptPos(prompt)` | World position of a prompt holder. |
| [6503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6503) | `fieldraid.firePrompt(prompt)` | fireproximityprompt wrapper. |
| [6511](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6511) | `fieldraid.tryChest(now, rootPos)` | Walks to and opens an earned harvest chest. |
| [6534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6534) | `fieldraid.fmtCal(n)` | Formats calories as K/M/B. |
| [6541](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6541) | `fieldraid.bank(now, rootPos)` | Manual Bank & Leave: walks to the Mill gate and fires GateExit. |
| [6572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6572) | `fieldraid.startRun(now, rootPos)` | At the camp sign-up, starts a solo raid (`Solo`, 1). |
| [6612](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6612) | `fieldraid.setSprint(on, now)` | Throttled `SprintRequest` toggle while travelling in a raid. |
| [6619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6619) | `fieldraid.travel(target, now)` | Sprint + path walk. |
| [6624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6624) | `fieldraid.tick(now, rootPos)` | Field raid dispatcher: chest heal, blink/walk dodge, bite on the move, push deeper, sweep max field. |
| [6713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6713) | `fieldraid.sweepBounds()` | Lateral bounds of the raid field (Planting, else FieldSoil). |
| [6728](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6728) | `fieldraid.sweep(now, rootPos)` | Deepest-field farming: lateral sprint passes, biting on the move. |
| [6219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6219) | `fieldraid.spotClear(from, spot)` | Blink target check: ground below, no wall/fence in between. |
| [6228](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6228) | `fieldraid.blinkDodge()` | Instant forward-only step out of a telegraph landing within ~1.2 s. |
| [6805](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6805) | `fieldraid.smithRules()` | Requires SmithingRules + DayNightCycle. |
| [6815](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6815) | `fieldraid.smithStatus(text)` | Updates the Blacksmith Shift status paragraph. |
| [6827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6827) | `fieldraid.smithEvent(msg)` | Handles SmithJob Status/Mark/Finished; fires perfect `SmithJobStrike`. |
| [6851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6851) | `fieldraid.smithHead()` | Blacksmith NPC head when at work (BlacksmithSite.WorkingHead). |
| [6861](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6861) | `fieldraid.smithAnvilPos()` | Blacksmith anvil position (AnvilCollider or constant). |
| [6872](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6872) | `fieldraid.smithReach(pos, range, label)` | Gets within range: opt-in teleport, else walk when close. |
| [6890](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6890) | `fieldraid.smithReturn()` | Teleports back to where the shift started. |
| [6899](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6899) | `fieldraid.smithTick()` | Anvil shift state machine: hire, hammer, turn in. |
| [6983](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6983) | `fieldraid.smithStart()` | Starts the tokened smith loop. |
| [16283](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L16283) | `fieldraid.setFlag(flag, on)` | Sets a Rayfield flag (debug handle). |

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

## Field Raid Probe (`fieldraid_probe.lua`)

**Path**: [`luascripts/fieldraid_probe.lua`](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua)

One-shot dump of raid geometry, live raid targets, player raid/smith attributes and the anvil site to `cowhub/probes/`.

**Total Functions**: `7`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [19](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L19) | `add(line)` | Appends a line to the report. |
| [23](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L23) | `fmtVec(v)` | Formats a Vector3. |
| [28](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L28) | `fmtAttrs(inst)` | Sorted attribute summary of an instance. |
| [41](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L41) | `instPos(inst)` | Position of a part or model pivot. |
| [50](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L50) | `rootPos()` | Local HumanoidRootPart position. |
| [56](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L56) | `promptLine(p, depth)` | Report line for a ProximityPrompt. |
| [64](file:///Users/jsph/cowhub/luascripts/fieldraid_probe.lua#L64) | `tree(inst, depth, maxDepth)` | Recursive instance tree dump with prompts. |

---
