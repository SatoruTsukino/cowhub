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
| [679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L679) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [714](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L714) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [731](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L731) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [745](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L745) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [762](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L762) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L773) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L780) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L874) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L891) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L929) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [967](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L967) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1042](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1042) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1111) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1119) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1143) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1212](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1212) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1263) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1447](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1447) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1470) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1516) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1524](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1524) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1550) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1562](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1562) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1611) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1626) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1687](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1687) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1725) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1757) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2118](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2118) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2125) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2132](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2132) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2145](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2145) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2153) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2161) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2174) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2183) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2200) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2214](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2214) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2221) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2247) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2295](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2295) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2317) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2342](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2342) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1842](file:///Users/jsph/cowhub/luascripts/preview.lua#L1842) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1851](file:///Users/jsph/cowhub/luascripts/preview.lua#L1851) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [1818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1818) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [1833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1833) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [preview 282](file:///Users/jsph/cowhub/luascripts/preview.lua#L282) | `findGrassFolder()` | **Staging (Plan 1.6).** Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [preview 1967](file:///Users/jsph/cowhub/luascripts/preview.lua#L1967) | `chomp.canTarget(node, id, rootPos, now)` | **Staging (Plan 1.6).** Mirrors the game's target rules: skip list, `Available`, 8-stud reach and forward cone, checked from the current and a lag-compensated position. |
| [1842](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1842) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [1895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1895) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [1914](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1914) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [1924](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1924) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [1933](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1933) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [1945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1945) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [1969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1969) | `chomp.release()` | Releases a held E key. |
| [1979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1979) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [1990](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1990) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2017](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2017) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2029](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2029) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2042](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2042) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2054](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2054) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2356](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2356) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2370](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2370) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2431](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2431) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2441](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2441) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2454) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2583](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2583) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2614) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2618](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2618) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2643) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2654](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2654) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2658](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2658) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2674) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2729) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2733](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2733) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2759](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2759) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2763) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2808](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2808) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2813) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2892](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2892) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2913](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2913) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2929) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2933](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2933) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2959](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2959) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2965](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2965) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2969](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2969) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2973](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2973) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2978](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2978) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3022](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3022) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3034) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3067](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3067) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3128) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3189) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3230](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3230) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3250](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3250) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3270](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3270) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3299](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3299) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3328) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3434) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3463](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3463) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3566](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3566) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3611) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3623](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3623) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3639](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3639) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3664) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3670) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3677) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3686) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3724](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3724) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3777) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3791) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3830](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3830) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3870](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3870) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [3886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3886) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [3898](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3898) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3958](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3958) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4048](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4048) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4060](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4060) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4143](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4143) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4155) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4233) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4255](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4255) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4282) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4343](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4343) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4355](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4355) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4429](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4429) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4463](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4463) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4520](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4520) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4828) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4873) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4946](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4946) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4978](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4978) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5017](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5017) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5083) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5123) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5366](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5366) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5474) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5491](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5491) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5594) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5624) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5702](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5702) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5706](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5706) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5713) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6606](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6606) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6610) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6622](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6622) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6665](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6665) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6679) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6796](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6796) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6874) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6900) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6929) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6962) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [7055](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7055) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7128) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7232](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7232) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7253](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7253) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7310](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7310) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7333) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7418](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7418) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7432) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7470) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7498) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7552](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7552) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7589) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7615) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7644](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7644) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7682](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7682) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7690) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7802) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7900) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7914](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7914) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7930](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7930) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7935](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7935) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7960) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7980](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7980) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8292](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8292) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8309) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8330](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8330) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8339) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8410) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8421](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8421) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8442) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8453](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8453) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8465](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8465) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8492) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8596](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8596) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8616) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8621) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8683](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8683) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8699](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8699) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8717) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8742](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8742) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8757](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8757) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8829](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8829) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8873) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8932](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8932) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [9017](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9017) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [9057](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9057) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [9090](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9090) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [9137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9137) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9166](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9166) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9185](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9185) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9296) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9318) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9337) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9375) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9382](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9382) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9436](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9436) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9513) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9529](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9529) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9670) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9701](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9701) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9773) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9798](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9798) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9820) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9832) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9850) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9856](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9856) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9897) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9936](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9936) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9998](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9998) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [10063](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10063) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [10073](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10073) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [10089](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10089) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [10119](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10119) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10167](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10167) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10273](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10273) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10336) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10405](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10405) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10419) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10440](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10440) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10445](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10445) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10459](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10459) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10478) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10532](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10532) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10545](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10545) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10568](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10568) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10630) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10638) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10652) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10658](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10658) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10671) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10677) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10733](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10733) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10771](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10771) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [10883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10883) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [10894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10894) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [10900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10900) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [10920](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10920) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [10942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10942) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10955) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10985](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10985) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [11012](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11012) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [11052](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11052) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [11093](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11093) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11366](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11366) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11377) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11844](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11844) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [11887](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11887) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [11904](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11904) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [12080](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12080) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [12155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12155) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12187](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12187) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12207) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12216](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12216) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12226) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12287) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12319) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12354](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12354) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

