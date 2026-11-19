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

**Total Functions**: `285`

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
| [860](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L860) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L895) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [912](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L912) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [926](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L926) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [943](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L943) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [954](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L954) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [1035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1035) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1054](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1054) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1092](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1092) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1131](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1131) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1209](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1209) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1281) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1289) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1320](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1320) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1357](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1357) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1386) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1458](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1458) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1509) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1709](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1709) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1732](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1732) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1777) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1785) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1811) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1823](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1823) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1872](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1872) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1887](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1887) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1948) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1988) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [2020](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2020) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2581) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2588](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2588) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2595) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2608](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2608) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2618](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2618) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2630) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2645](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2645) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2671) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2680) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2697) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2712](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2712) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2719](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2719) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2745](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2745) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2795](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2795) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2818) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2843](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2843) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2081](file:///Users/jsph/cowhub/luascripts/preview.lua#L2081) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2090](file:///Users/jsph/cowhub/luascripts/preview.lua#L2090) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2171) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2186) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L351) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2207) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2241) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2353) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2369](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2369) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2379](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2379) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2388](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2388) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2400) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2426](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2426) | `chomp.release()` | Releases a held E key. |
| [2437](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2437) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2449](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2449) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2477) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2490) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2503) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2515](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2515) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2857) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2871](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2871) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2932](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2932) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2942) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2955) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3086](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3086) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3117) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3121](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3121) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3146) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3157) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3161) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3177) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3232](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3232) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3236](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3236) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3262) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3266) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3311](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3311) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3316) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3395) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3416) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3432) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3436) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3462](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3462) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3468](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3468) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3472](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3472) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3476](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3476) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3482](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3482) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3526](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3526) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3538) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3571) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3636) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3697) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3738) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3758](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3758) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3778](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3778) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3807](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3807) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3836](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3836) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3942) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3971](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3971) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4074](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4074) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4119) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4131](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4131) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4147) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4172](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4172) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4178) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4185](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4185) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4194](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4194) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4232](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4232) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4293](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4293) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4307](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4307) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4346) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4387) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4403) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4416) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4480) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4574](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4574) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4586](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4586) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4669) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4681](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4681) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4759) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4781](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4781) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4851) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4913](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4913) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4925) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4987) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [5021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5021) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5082](file:///Users/jsph/cowhub/luascripts/preview.lua#L5082) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5098) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5416) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5461](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5461) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5534) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5566](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5566) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5605](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5605) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5672](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5672) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5718](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5718) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5760](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5760) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5794](file:///Users/jsph/cowhub/luascripts/preview.lua#L5794) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5813](file:///Users/jsph/cowhub/luascripts/preview.lua#L5813) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5819) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [6886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6886) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [6998](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6998) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [7020](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7020) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [7166](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7166) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [7197](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7197) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [7275](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7275) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [7279](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7279) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [7287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7287) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4811](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4811) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [8202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8202) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [8217](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8217) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [8278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8278) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [8284](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8284) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [8381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8381) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [8459](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8459) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8485](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8485) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [8514](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8514) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [8547](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8547) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [8643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8643) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [8715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8715) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [8808](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8808) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [8829](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8829) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [8886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8886) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [8909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8909) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [8994](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8994) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [9008](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9008) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [9046](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9046) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [9075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9075) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [9129](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9129) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [9166](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9166) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [9192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9192) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [9221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9221) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [9259](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9259) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [9267](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9267) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [9379](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9379) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [9478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9478) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [9487](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9487) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [9503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9503) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [9508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9508) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [9533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9533) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [9553](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9553) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [9857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9857) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [9874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9874) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [9895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9895) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [9904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9904) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [9977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9977) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [9989](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9989) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [10010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10010) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [10021](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10021) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [10033](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10033) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [10060](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10060) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [10164](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10164) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [10184](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10184) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [10189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10189) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [10253](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10253) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [10269](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10269) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [10287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10287) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [10312](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10312) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [10327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10327) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [10399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10399) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [10443](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10443) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [10502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10502) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [10587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10587) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [10627](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10627) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [10660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10660) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [10707](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10707) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [10736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10736) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [10755](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10755) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [10868](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10868) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [10890](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10890) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [10909](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10909) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [10947](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10947) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [10954](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10954) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [11010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11010) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [11088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11088) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [11104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11104) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [11247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11247) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [11278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11278) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [11351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11351) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [11376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11376) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [11398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11398) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [11412](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11412) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [11430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11430) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [11436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11436) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [11477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11477) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [11516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11516) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [11578](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11578) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [11643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11643) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [11653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11653) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [11669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11669) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [11699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11699) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [11747](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11747) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [11854](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11854) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [11919](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11919) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [11990](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11990) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [12004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12004) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [12025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12025) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [12030](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12030) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [12044](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12044) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [12063](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12063) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [12117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12117) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [12130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12130) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [12153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12153) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [12215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12215) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [12223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12223) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [12237](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12237) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [12243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12243) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [12256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12256) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [12262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12262) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [12318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12318) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [12356](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12356) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [12469](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12469) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [12480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12480) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [12486](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12486) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [12506](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12506) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [12528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12528) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [12542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12542) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [12572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12572) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [12599](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12599) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [12639](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12639) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [12680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12680) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [12958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12958) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [12969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12969) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [13436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13436) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [13479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13479) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [13496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13496) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [13702](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13702) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [13777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13777) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [13809](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13809) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [13846](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13846) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [13855](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13855) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [13865](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13865) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [13926](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13926) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [13958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13958) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [13993](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13993) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |
| [6063](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6063) | `fieldraid.runId()` | Current field raid run id (player attribute `CowFieldRaidId`). |
| [6067](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6067) | `fieldraid.inRaid()` | True while the cow is in a field raid run. |
| [6071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6071) | `fieldraid.fire(...)` | Fires `FieldRaidRequest` (raid start, graze, smith job) safely. |
| [6081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6081) | `fieldraid.setStatus(text)` | Updates the Field Raid status paragraph. |
| [6091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6091) | `fieldraid.isRaidMob(part)` | True for a raid enemy PrimaryPart (`CowBiteTargetKind` RaidMob). |
| [6095](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6095) | `fieldraid.mobAlive(part)` | Raid mob is alive when its Health attribute is above 0. |
| [6100](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6100) | `fieldraid.scan(now, force)` | Throttled pass over `NorthRiverRaidView`: live mobs and available wheat. |
| [6122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6122) | `fieldraid.cellPoint(part, pos)` | Closest point of a wheat cell box to a position (bite distance). |
| [6131](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6131) | `fieldraid.findWheat(rootPos, now)` | Best food: in reach ripe, then richest BaseCalories, then nearest. |
| [6159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6159) | `fieldraid.nearestMob(rootPos)` | Nearest live raid mob and its distance. |
| [6171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6171) | `fieldraid.combatMods()` | Requires the game's FieldRaidCombat / FieldRaidEnemies modules. |
| [6181](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6181) | `fieldraid.addHazard(msg)` | Records a server attack telegraph (Windup / ProjectileAim / BarrageMark). |
| [6200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6200) | `fieldraid.dropHazards(id)` | Forgets telegraphs of a cancelled or defeated mob. |
| [6208](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6208) | `fieldraid.danger(pos, serverNow, horizon)` | Game hit test (`FieldRaidCombat.Contains`) against live telegraphs. |
| [6221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6221) | `fieldraid.dodgeStep(now, rootPos)` | Moves the cow to the nearest safe ring spot when a telegraph covers it. |
| [6261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6261) | `fieldraid.face(pos)` | Turns the root toward a target (raid mobs need facing). |
| [6271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6271) | `fieldraid.ensureGraze()` | Sends `GrazeStart` once per run, like FieldRaidGraze.Hold. |
| [6279](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6279) | `fieldraid.chompWheat(now, rootPos)` | Bites the best raid wheat in reach via `chomp.send` (serial wire). |
| [6292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6292) | `fieldraid.biteMob(part, now)` | Bites a raid mob via `chomp.send`, shares the mob aura cooldown. |
| [6310](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6310) | `fieldraid.forward(target, rootPos)` | Forward-only clamp: never aims behind the cow (+Z) unless banking manually. |
| [6316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6316) | `fieldraid.walkTo(target, now)` | PathfindingService walk with stuck jump/sidestep recovery. |
| [6375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6375) | `fieldraid.stopWalk()` | Clears the raid path and halts movement. |
| [6383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6383) | `fieldraid.arena()` | Private raid arena model (`Geometry.PrivateFieldRaids`). |
| [6390](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6390) | `fieldraid.prompts(now)` | Rescans arena chest (`OpenHarvestChest`) and `GateExit` prompts. |
| [6408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6408) | `fieldraid.promptPos(prompt)` | World position of a prompt holder. |
| [6416](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6416) | `fieldraid.firePrompt(prompt)` | fireproximityprompt wrapper. |
| [6424](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6424) | `fieldraid.tryChest(now, rootPos)` | Walks to and opens an earned harvest chest. |
| [6447](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6447) | `fieldraid.fmtCal(n)` | Formats calories as K/M/B. |
| [6454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6454) | `fieldraid.bank(now, rootPos)` | Manual Bank & Leave: walks to the Mill gate and fires GateExit. |
| [6485](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6485) | `fieldraid.startRun(now, rootPos)` | At the camp sign-up, starts a solo raid (`Solo`, 1). |
| [6525](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6525) | `fieldraid.setSprint(on, now)` | Throttled `SprintRequest` toggle while travelling in a raid. |
| [6532](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6532) | `fieldraid.travel(target, now)` | Sprint + path walk. |
| [6538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6538) | `fieldraid.fight(mob, md, now, rootPos)` | Bites a raid mob and kites outside its close-move range. |
| [6552](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6552) | `fieldraid.tick(now, rootPos)` | Field raid autofarm dispatcher (forward only: chest heal, dodge, fight, graze, push deeper). |
| [6687](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6687) | `fieldraid.smithRules()` | Requires SmithingRules + DayNightCycle. |
| [6697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6697) | `fieldraid.smithStatus(text)` | Updates the Blacksmith Shift status paragraph. |
| [6709](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6709) | `fieldraid.smithEvent(msg)` | Handles SmithJob Status/Mark/Finished; fires perfect `SmithJobStrike`. |
| [6733](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6733) | `fieldraid.smithHead()` | Blacksmith NPC head when at work (BlacksmithSite.WorkingHead). |
| [6743](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6743) | `fieldraid.smithAnvilPos()` | Blacksmith anvil position (AnvilCollider or constant). |
| [6754](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6754) | `fieldraid.smithReach(pos, range, label)` | Gets within range: opt-in teleport, else walk when close. |
| [6776](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6776) | `fieldraid.smithReturn()` | Teleports back to where the shift started. |
| [6785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6785) | `fieldraid.smithTick()` | Anvil shift state machine: hire, hammer, turn in. |
| [6869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6869) | `fieldraid.smithStart()` | Starts the tokened smith loop. |
| [16155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L16155) | `fieldraid.setFlag(flag, on)` | Sets a Rayfield flag (debug handle). |

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
