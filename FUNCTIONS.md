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
| [619](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L619) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [654](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L654) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [671](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L671) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [685](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L685) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [702](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L702) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L713) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [720](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L720) | `mapOptimizer.preloadAssets()` | Preloads critical meshes and animations via ContentProvider. |
| [814](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L814) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L831) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L869) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [907](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L907) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [982](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L982) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1051](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1051) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1059](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1059) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1083) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1148](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1148) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1199](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1199) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1375) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1398) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1444) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1452](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1452) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1478) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1490) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1539](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1539) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1554](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1554) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1615) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1653) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [1685](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1685) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2046](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2046) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2053](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2053) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2060](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2060) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2073](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2073) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2081](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2081) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2089](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2089) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2102](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2102) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2111) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2128) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2142](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2142) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2149](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2149) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2175) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2223) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2245](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2245) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2270](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2270) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 1754](file:///Users/jsph/cowhub/luascripts/preview.lua#L1754) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 1763](file:///Users/jsph/cowhub/luascripts/preview.lua#L1763) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [1746](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1746) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [1761](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1761) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [1770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1770) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [1823](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1823) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [1842](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1842) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [1852](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1852) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [1861](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1861) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [1873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1873) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [1897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1897) | `chomp.release()` | Releases a held E key. |
| [1907](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1907) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [1918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1918) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [1945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1945) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [1957](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1957) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [1970](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1970) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [1982](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1982) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2284](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2284) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2298](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2298) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2359) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2369](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2369) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2382](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2382) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [2511](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2511) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [2542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2542) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [2546](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2546) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [2571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2571) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [2582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2582) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [2586](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2586) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [2602](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2602) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [2657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2657) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [2661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2661) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [2687](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2687) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [2691](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2691) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [2736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2736) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [2741](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2741) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [2820](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2820) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [2841](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2841) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [2857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2857) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [2861](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2861) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [2887](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2887) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [2893](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2893) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [2897](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2897) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [2901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2901) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [2906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2906) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [2950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2950) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [2962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2962) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [2995](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2995) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3056](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3056) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3117](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3117) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3158](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3158) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3178) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3198](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3198) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3227](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3227) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3256](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3256) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3362](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3362) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3391](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3391) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [3494](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3494) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [3539](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3539) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [3551](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3551) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [3567](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3567) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [3592](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3592) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [3598](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3598) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [3605](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3605) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [3614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3614) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [3652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3652) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [3705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3705) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [3719](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3719) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [3758](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3758) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [3798](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3798) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [3814](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3814) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [3826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3826) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [3886](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3886) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [3976](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3976) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [3988](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3988) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4071) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4083) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4161](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4161) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4183) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4210](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4210) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4271) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4283](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4283) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4357](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4357) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [4391](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4391) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [4448](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4448) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [4756](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4756) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [4801](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4801) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [4874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4874) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [4906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4906) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [4945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4945) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5011) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5051](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5051) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [5294](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5294) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [5402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5402) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [5419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5419) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [5522](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5522) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [5552](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5552) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [5630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5630) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [5634](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5634) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [5641](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5641) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [6534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6534) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [6538](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6538) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [6550](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6550) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [6593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6593) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [6607](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6607) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [6724](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6724) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [6802](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6802) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [6828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6828) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [6857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6857) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [6890](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6890) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [6970](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6970) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [7040](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7040) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [7130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7130) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [7151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7151) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [7168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7168) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [7191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7191) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [7281](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7281) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [7295](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7295) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [7333](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7333) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [7361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7361) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [7415](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7415) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [7452](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7452) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [7478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7478) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [7507](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7507) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [7540](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7540) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [7548](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7548) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [7657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7657) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [7755](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7755) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [7769](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7769) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [7785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7785) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [7790](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7790) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [7813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7813) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [7833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7833) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [8130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8130) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [8147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8147) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [8168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8168) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [8177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8177) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [8248](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8248) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [8259](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8259) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [8280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8280) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [8291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8291) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [8303](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8303) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [8330](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8330) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [8434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8434) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [8454](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8454) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [8459](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8459) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [8521](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8521) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [8537](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8537) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [8555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8555) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [8580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8580) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [8595](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8595) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [8667](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8667) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [8711](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8711) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [8770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8770) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [8855](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8855) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [8895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8895) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [8928](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8928) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [8975](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8975) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [9004](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9004) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [9023](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9023) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [9134](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9134) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [9156](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9156) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [9175](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9175) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [9213](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9213) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [9220](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9220) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [9274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9274) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [9351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9351) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [9367](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9367) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [9508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9508) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [9539](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9539) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [9611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9611) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [9636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9636) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [9658](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9658) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [9670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9670) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [9688](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9688) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [9694](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9694) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [9735](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9735) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [9774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9774) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [9836](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9836) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [9901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9901) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [9911](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9911) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [9927](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9927) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [9957](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9957) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [10005](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10005) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [10111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10111) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [10174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10174) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [10243](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10243) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [10257](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10257) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [10278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10278) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [10283](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10283) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [10297](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10297) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [10316](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10316) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [10370](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10370) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [10383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10383) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [10406](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10406) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [10468](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10468) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [10476](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10476) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [10490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10490) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [10496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10496) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [10509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10509) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [10515](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10515) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [10571](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10571) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [10609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10609) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [10721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10721) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [10732](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10732) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [10738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10738) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [10758](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10758) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [10780](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10780) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [10793](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10793) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [10823](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10823) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [10850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10850) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [10890](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10890) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [10931](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10931) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [11204](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11204) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [11215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11215) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [11682](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11682) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [11725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11725) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [11742](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11742) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [11918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11918) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [11993](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11993) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [12025](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12025) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [12045](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12045) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [12054](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12054) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [12064](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12064) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [12125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12125) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [12157](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12157) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [12192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12192) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |

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

