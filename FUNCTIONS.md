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
- [Mill Quests Automator (`mill_quests.lua`)](#mill-quests-automator-mill_questslua)

---

## Main Script Hub (`cowhub.lua` / `preview.lua`)

**Path**: [`luascripts/cowhub.lua`](file:///Users/jsph/cowhub/luascripts/cowhub.lua) *(synchronized with [`luascripts/preview.lua`](file:///Users/jsph/cowhub/luascripts/preview.lua))*

Primary CowHub script containing autofarm engines, mining, dodging, auction scanners, and Fjord rafting.

**Total Functions**: `294`

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
| [868](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L868) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [903](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L903) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [920](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L920) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [934](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L934) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [951](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L951) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L962) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [1043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1043) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1062](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1062) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1100](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1100) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1139) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1217](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1217) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1289](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1289) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1297](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1297) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1328](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1328) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1365](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1365) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1394) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1466](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1466) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1517) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1717) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1740](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1740) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1785) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1793](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1793) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1819) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1831) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1880](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1880) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1895) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1956](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1956) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1996) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [2028](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2028) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2589) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2596](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2596) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2603](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2603) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2616](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2616) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2626) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2638) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2653](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2653) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2679) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2688](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2688) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2705) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2720](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2720) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2727](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2727) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2753](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2753) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2803](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2803) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2826) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2851) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2089](file:///Users/jsph/cowhub/luascripts/preview.lua#L2089) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2098](file:///Users/jsph/cowhub/luascripts/preview.lua#L2098) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2179](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2179) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2194](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2194) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L351) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2215) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2249) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2361) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2377](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2377) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2387) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2396](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2396) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2408) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2434) | `chomp.release()` | Releases a held E key. |
| [2445](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2445) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2457](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2457) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2485](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2485) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2498](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2498) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2511](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2511) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2523](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2523) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2865](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2865) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2879) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2940](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2940) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2950) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2963](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2963) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3094](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3094) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3125) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3129](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3129) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3154](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3154) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3165](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3165) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3169](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3169) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3185](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3185) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3240) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3244](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3244) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3270](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3270) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3274](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3274) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3319](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3319) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3324](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3324) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3403](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3403) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3424](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3424) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3440](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3440) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3444) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3470) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3476](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3476) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3480) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3484](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3484) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3490](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3490) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3534](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3534) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3546](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3546) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3579](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3579) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3644](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3644) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3705](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3705) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3746](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3746) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3766](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3766) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3786](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3786) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3815](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3815) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3844](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3844) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3950) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3979) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4082](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4082) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4127) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4139) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4155) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4180](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4180) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4186) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4193](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4193) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4202) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4240) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4301) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4315](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4315) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4354](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4354) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4395](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4395) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4411](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4411) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4424](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4424) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4488](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4488) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4582) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4594) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4677) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4689](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4689) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4767) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4789](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4789) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4859](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4859) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4921](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4921) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4933](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4933) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4995](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4995) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [5029](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5029) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5090](file:///Users/jsph/cowhub/luascripts/preview.lua#L5090) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5106) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5424](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5424) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5469](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5469) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5542) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5574](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5574) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5613](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5613) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5680](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5680) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5726](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5726) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5768) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5802](file:///Users/jsph/cowhub/luascripts/preview.lua#L5802) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5821](file:///Users/jsph/cowhub/luascripts/preview.lua#L5821) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5827) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [7100](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7100) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [7212](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7212) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [7234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7234) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [7380](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7380) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [7411](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7411) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [7489](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7489) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [7493](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7493) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [7501](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7501) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4819](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4819) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [8432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8432) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [8447](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8447) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [8508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8508) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [8514](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8514) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [8611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8611) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [8689](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8689) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8715) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [8744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8744) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [8777](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8777) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [8873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8873) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [8945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8945) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [9038](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9038) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [9059](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9059) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [9116](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9116) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [9139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9139) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [9224](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9224) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [9238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9238) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [9276](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9276) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [9305](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9305) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [9359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9359) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [9396](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9396) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [9422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9422) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [9451](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9451) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [9489](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9489) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [9497](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9497) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [9609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9609) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [9708](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9708) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [9717](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9717) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [9733](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9733) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [9738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9738) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [9763](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9763) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [9783](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9783) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [10087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10087) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [10104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10104) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [10125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10125) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [10134](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10134) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [10207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10207) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [10219](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10219) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [10240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10240) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [10251](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10251) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [10263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10263) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [10290](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10290) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [10394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10394) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [10414](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10414) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [10419](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10419) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [10483](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10483) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [10499](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10499) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [10517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10517) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [10542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10542) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [10557](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10557) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [10629](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10629) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [10673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10673) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [10732](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10732) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [10817](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10817) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [10857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10857) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [10890](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10890) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [10937](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10937) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [10966](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10966) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [10985](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10985) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [11098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11098) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [11120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11120) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [11139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11139) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [11177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11177) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [11184](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11184) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [11240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11240) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [11318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11318) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [11334](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11334) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [11477](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11477) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [11508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11508) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [11581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11581) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [11606](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11606) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [11628](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11628) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [11642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11642) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [11660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11660) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [11666](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11666) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [11707](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11707) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [11746](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11746) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [11808](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11808) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [11873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11873) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [11883](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11883) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [11899](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11899) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [11929](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11929) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [11977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11977) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [12087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12087) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [12152](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12152) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [12223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12223) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [12237](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12237) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [12258](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12258) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [12263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12263) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [12277](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12277) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [12296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12296) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [12350](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12350) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [12363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12363) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [12386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12386) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [12448](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12448) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [12456](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12456) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [12470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12470) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [12476](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12476) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [12489](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12489) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [12495](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12495) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [12551](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12551) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [12589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12589) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [12702](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12702) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [12713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12713) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [12719](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12719) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [12739](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12739) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [12761](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12761) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [12775](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12775) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [12805](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12805) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [12832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12832) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [12872](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12872) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [12913](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12913) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [13191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13191) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [13202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13202) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [13669](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13669) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [13712](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13712) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [13729](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13729) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [13935](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13935) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [14010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14010) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [14042](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14042) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [14079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14079) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [14088](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14088) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [14098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14098) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [14159](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14159) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [14191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14191) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [14226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14226) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |
| [6071](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6071) | `fieldraid.runId()` | Current field raid run id (player attribute `CowFieldRaidId`). |
| [6075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6075) | `fieldraid.inRaid()` | True while the cow is in a field raid run. |
| [6079](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6079) | `fieldraid.fire(...)` | Fires `FieldRaidRequest` (raid start, graze, smith job) safely. |
| [6089](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6089) | `fieldraid.setStatus(text)` | Updates the Field Raid status paragraph. |
| [6099](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6099) | `fieldraid.isRaidMob(part)` | True for a raid enemy PrimaryPart (`CowBiteTargetKind` RaidMob). |
| [6103](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6103) | `fieldraid.mobAlive(part)` | Raid mob is alive when its Health attribute is above 0. |
| [6108](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6108) | `fieldraid.scan(now, force)` | Throttled pass over `NorthRiverRaidView`: live mobs and available wheat. |
| [6130](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6130) | `fieldraid.cellPoint(part, pos)` | Closest point of a wheat cell box to a position (bite distance). |
| [6139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6139) | `fieldraid.findWheat(rootPos, now)` | Best food: in reach ripe, then richest BaseCalories, then nearest. |
| [6168](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6168) | `fieldraid.nearestMob(rootPos)` | Nearest live raid mob and its distance. |
| [6180](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6180) | `fieldraid.combatMods()` | Requires the game's FieldRaidCombat / FieldRaidEnemies modules. |
| [6190](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6190) | `fieldraid.addHazard(msg)` | Records a server attack telegraph (Windup / ProjectileAim / BarrageMark). |
| [6263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6263) | `fieldraid.dropHazards(id)` | Forgets telegraphs of a cancelled or defeated mob. |
| [6271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6271) | `fieldraid.danger(pos, serverNow, horizon)` | Game hit test (`FieldRaidCombat.Contains`) against live telegraphs. |
| [6284](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6284) | `fieldraid.dodgeStep(now, rootPos)` | Moves the cow to the nearest safe ring spot when a telegraph covers it. |
| [6329](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6329) | `fieldraid.face(pos)` | Turns the root toward a target (raid mobs need facing). |
| [6339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6339) | `fieldraid.ensureGraze()` | Sends `GrazeStart` once per run, like FieldRaidGraze.Hold. |
| [6347](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6347) | `fieldraid.chompWheat(now, rootPos)` | Bites the best raid wheat in reach via `chomp.send` (serial wire). |
| [6360](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6360) | `fieldraid.biteMob(part, now)` | Bites a raid mob via `chomp.send`, shares the mob aura cooldown. |
| [6378](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6378) | `fieldraid.forward(target, rootPos)` | Forward-only clamp: never aims behind the cow (+Z) unless banking manually. |
| [6389](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6389) | `fieldraid.bandZ(level)` | Z span of a field level (FieldRaidLayout.Band on the run Planting). |
| [6400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6400) | `fieldraid.backLimit(rootPos)` | Furthest +Z allowed: whole max field when farming, else just behind the cow. |
| [6410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6410) | `fieldraid.walkTo(target, now)` | PathfindingService walk with stuck jump/sidestep recovery. |
| [6469](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6469) | `fieldraid.stopWalk()` | Clears the raid path and halts movement. |
| [6479](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6479) | `fieldraid.arena()` | Private raid arena model (`Geometry.PrivateFieldRaids`). |
| [6497](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6497) | `fieldraid.prompts(now)` | Rescans arena chest (`OpenHarvestChest`) and `GateExit` prompts. |
| [6517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6517) | `fieldraid.promptPos(prompt)` | World position of a prompt holder. |
| [6525](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6525) | `fieldraid.firePrompt(prompt)` | fireproximityprompt wrapper. |
| [6533](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6533) | `fieldraid.tryChest(now, rootPos)` | Walks to and opens an earned harvest chest. |
| [6556](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6556) | `fieldraid.fmtCal(n)` | Formats calories as K/M/B. |
| [6564](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6564) | `fieldraid.exitSpot(via)` | Exit prompt + position: River ferry (RiverExit) or Mill gate (GateExit), with fallbacks. |
| [6573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6573) | `fieldraid.pickExit(rootPos)` | Nearer exit for manual Bank & Leave. |
| [6579](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6579) | `fieldraid.bank(now, rootPos)` | Leaves the run: walks to the chosen exit (ferry forward / gate back) and fires its prompt. |
| [6604](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6604) | `fieldraid.meadow(now, rootPos)` | Harvest meadow after the ferry: opens our gold chest, then Return to town. |
| [6656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6656) | `fieldraid.startRun(now, rootPos)` | At the camp sign-up, starts a solo raid (`Solo`, 1). |
| [6696](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6696) | `fieldraid.setSprint(on, now)` | Throttled `SprintRequest` toggle while travelling in a raid. |
| [6703](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6703) | `fieldraid.travel(target, now)` | Sprint + path walk. |
| [6708](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6708) | `fieldraid.tick(now, rootPos)` | Field raid dispatcher: chest heal, blink/walk dodge, bite on the move, push deeper, sweep max field. |
| [6812](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6812) | `fieldraid.sweepBounds()` | Lateral bounds of the raid field (Planting, else FieldSoil). |
| [6827](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6827) | `fieldraid.sweep(now, rootPos)` | Deepest-field farming: lateral sprint passes, biting on the move. |
| [6225](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6225) | `fieldraid.spotClear(from, spot)` | Blink target check: ground below, no wall/fence in between. |
| [6234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6234) | `fieldraid.blinkDodge()` | Instant forward-only step out of a telegraph landing within ~1.2 s. |
| [6905](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6905) | `fieldraid.smithRules()` | Requires SmithingRules + DayNightCycle. |
| [6915](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6915) | `fieldraid.smithStatus(text)` | Updates the Blacksmith Shift status paragraph. |
| [6927](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6927) | `fieldraid.smithEvent(msg)` | Handles SmithJob Status/Mark/Finished; fires perfect `SmithJobStrike`. |
| [6951](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6951) | `fieldraid.smithHead()` | Blacksmith NPC head when at work (BlacksmithSite.WorkingHead). |
| [6961](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6961) | `fieldraid.smithAnvilPos()` | Blacksmith anvil position (AnvilCollider or constant). |
| [6972](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6972) | `fieldraid.smithReach(pos, range, label)` | Gets within range: opt-in teleport, else walk when close. |
| [6990](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6990) | `fieldraid.smithReturn()` | Teleports back to where the shift started. |
| [6999](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6999) | `fieldraid.smithTick()` | Anvil shift state machine: hire, hammer, turn in. |
| [7083](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7083) | `fieldraid.smithStart()` | Starts the tokened smith loop. |
| [16383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L16383) | `fieldraid.setFlag(flag, on)` | Sets a Rayfield flag (debug handle). |
| [16387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L16387) | `fieldraid.setOption(label, on)` | Sets one Raid Options dropdown entry (debug handle). |

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

## Mill Quests Automator (`mill_quests.lua`)

**Path**: [`luascripts/mill_quests.lua`](file:///Users/jsph/cowhub/luascripts/mill_quests.lua)

Standalone automator for all 3 North River Field Raid Mill Challenges (`WindmillAtDusk` coat).

**Total Functions**: `52`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [146](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L146) | `getChar()` | Returns current character, HumanoidRootPart, and Humanoid. |
| [153](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L153) | `setRootCFrame(cf, targetRoot)` | Teleports root part or model pivot safely. |
| [162](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L162) | `mq.fireRaid(...)` | Fires `FieldRaidRequest` remote safely. |
| [172](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L172) | `mq.loadMods()` | Lazy-requires `FieldRaidCombat` and `FieldRaidEnemies` shared modules. |
| [180](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L180) | `mq.isDone(idx)` | Checks whether challenge bit `idx` (1..3) is set in `challengesMask`. |
| [184](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L184) | `mq.c1Complete()` | Returns true when ripe wheat has been bitten in Fields 3, 4, and 5. |
| [188](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L188) | `mq.c2Complete()` | Returns true when 3 clean ripe bites in Field 8 have been recorded. |
| [192](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L192) | `mq.c3Complete()` | Returns true when Challenge 3 is saved in server Ledger bitmask. |
| [196](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L196) | `mq.activeGoal()` | Resolves next target challenge (1, 2, 3, or nil) based on `mq.mode` and progress. |
| [208](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L208) | `mq.resetRunTrackers()` | Clears per-run challenge, hazard, bell, and exit state. |
| [229](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L229) | `mq.setStatus(text)` | Updates `mq.status` and the compact UI status label. |
| [237](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L237) | `mq.refreshUI()` | Syncs UI buttons, challenge checkboxes, and current field/hearts display. |
| [279](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L279) | `mq.syncLedger(silent)` | Queries server `Ledger` and optionally auto-closes the raid board modal. |
| [287](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L287) | `mq.bandZ(level)` | Computes nearZ and farZ world bounds for Field `level` using `FieldRaidLayout.Band`. |
| [298](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L298) | `mq.sweepBounds()` | Returns clamped lateral X bounds across the planting field. |
| [309](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L309) | `mq.arena()` | Resolves the active `PrivateFieldRaids` or run geometry folder. |
| [327](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L327) | `mq.cellPoint(part, pos)` | Clamps `pos` onto `part`'s oriented bounding box for accurate reach checks. |
| [334](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L334) | `mq.mobAlive(part)` | Checks if a raid mob part still exists and has positive Health. |
| [338](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L338) | `mq.scan(now, force)` | Scans `NorthRiverRaidView` for live `RaidMob` and available `RaidFood` parts. |
| [360](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L360) | `mq.findOgre()` | Locates live `FieldOgre` model or boss position in Field 10. |
| [383](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L383) | `mq.findWheat(rootPos, now, ripeOnly, minZ, maxZ)` | Selects highest-priority wheat cell filtered by ripeness and Z band. |
| [415](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L415) | `mq.nearestMob(rootPos)` | Finds closest living raid mob to `rootPos`. |
| [427](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L427) | `mq.getInterval(node)` | Computes server-aligned chew cooldown interval plus adaptive margin. |
| [436](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L436) | `mq.ensureGraze()` | Sends `GrazeStart` once per active raid run. |
| [444](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L444) | `mq.face(root, pos)` | Rotates root horizontally toward target position `pos`. |
| [453](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L453) | `mq.sendChomp(nodeId, node, now, root)` | Fires `ChompRequest` with serial tracking and ripe/level metadata. |
| [492](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L492) | `mq.biteNearby(now, root, rootPos)` | Bites in-range ripe wheat, raid mobs, or regular wheat on the move. |
| [512](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L512) | `mq.addHazard(msg)` | Parses enemy telegraphs, tracks FieldOgre `HarvestStomp` for C3, and schedules blink-dodges. |
| [562](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L562) | `mq.dropHazards(id)` | Removes active hazards belonging to canceled or defeated enemy `id`. |
| [569](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L569) | `mq.danger(pos, serverNow, horizon)` | Evaluates `FieldRaidCombat.Contains` against active hazards at `pos`. |
| [581](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L581) | `mq.spotClear(char, from, spot)` | Raycasts wall/fence clearance and valid ground under candidate dodge `spot`. |
| [591](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L591) | `mq.allowedSpot(spot, rootPos, holdLevel)` | Enforces field X bounds and target Z-band clamping for dodge spots. |
| [605](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L605) | `mq.jumpSilk(humanoid, pos, serverNow)` | Jumps a SilkTripline web about to catch the cow (game hint: jump the silk). |
| [619](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L619) | `mq.blinkDodge(holdLevel)` | Micro-teleports out of imminent telegraph footprints using radial clearance scoring. |
| [653](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L653) | `mq.dodgeStep(now, rootPos, humanoid, holdLevel)` | Combines blink-dodge and `Humanoid:MoveTo` evasion from active telegraphs. |
| [695](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L695) | `mq.setSprint(on, now)` | Toggles raid sprint via `SprintRequest` with rate limiting. |
| [702](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L702) | `mq.walkTo(target, now, humanoid, root)` | Pathfinding-assisted movement with stuck detection and perpendicular unstick nudges. |
| [771](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L771) | `mq.stopWalk()` | Clears active path and halts humanoid movement. |
| [780](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L780) | `mq.prompts(now)` | Caches `OpenHarvestChest`, `GateExit`, and `RiverExit` ProximityPrompts in arena. |
| [800](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L800) | `mq.promptPos(prompt)` | Resolves world position of a ProximityPrompt's parent part, attachment, or model. |
| [808](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L808) | `mq.firePrompt(prompt)` | Triggers a ProximityPrompt safely via `fireproximityprompt`. |
| [815](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L815) | `mq.tryChest(now, rootPos, humanoid, root)` | Walks to and opens nearby or healing harvest chests when hurt or adjacent. |
| [842](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L842) | `mq.exitSpot(via)` | Resolves `RiverExit` or `GateExit` prompt and world position fallback. |
| [851](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L851) | `mq.bank(now, rootPos, humanoid, root)` | Navigates to chosen raid exit and fires its prompt to bank run rewards. |
| [879](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L879) | `mq.meadow(now, rootPos, humanoid)` | Collects owned Harvest Meadow gold chest then interacts with `HomePrompt`. |
| [932](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L932) | `mq.startRun(now, rootPos, humanoid, root)` | Walks to raid camp sign-up and enters a Solo raid when outside. |
| [975](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L975) | `mq.huntRipeInField(now, rootPos, humanoid, root, targetLevel, statusPrefix)` | Holds inside `targetLevel` and chases `RaidRipe` wheat or announced `Bell` patches. |
| [1059](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1059) | `mq.runChallenge3(now, rootPos, humanoid, root)` | Baits `FieldOgre` stomp in F10, confirms unhit dodge >16 studs, and exits via `RiverExit`. |
| [1113](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1113) | `mq.tick(now)` | Main 10Hz state machine orchestrating camp start, raid progression, dodge, and exits. |
| [1412](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1412) | `mq.buildUI()` | Builds compact draggable `CowMillQuestsUI` status and control panel. |
| [1552](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1552) | `mq.setRunning(on)` | Starts/stops automation and pauses conflicting `_G.CowHubFieldRaid.auto`. |
| [1575](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1575) | `mq.destroy()` | Disconnects listeners, stops movement, removes UI, and clears `_G.CowMillQuests`. |

---
