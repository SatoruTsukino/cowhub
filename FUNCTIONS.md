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

**Total Functions**: `291`

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
| [866](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L866) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L901) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [918](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L918) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [932](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L932) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [949](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L949) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [960](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L960) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [1041](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1041) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1060](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1060) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1098](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1098) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1137) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1215) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1287) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1295](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1295) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1326](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1326) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1363](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1363) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1392](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1392) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1464) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1515](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1515) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1715](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1715) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1738](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1738) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1783](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1783) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1791) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1817](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1817) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1829](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1829) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1878](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1878) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1893](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1893) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [1954](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1954) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [1994](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1994) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [2026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2026) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2587) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2594) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2601](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2601) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2614](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2614) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2624](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2624) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2636) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2651) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2677](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2677) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2686](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2686) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2703](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2703) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2718](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2718) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2725) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2751) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2801](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2801) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2824](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2824) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2849](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2849) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2087](file:///Users/jsph/cowhub/luascripts/preview.lua#L2087) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2096](file:///Users/jsph/cowhub/luascripts/preview.lua#L2096) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2177) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2192](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2192) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [351](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L351) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2213](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2213) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2247) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2359](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2359) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2375) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2385](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2385) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2394](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2394) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2406](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2406) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2432](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2432) | `chomp.release()` | Releases a held E key. |
| [2443](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2443) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2455](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2455) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2483](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2483) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2496) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2509](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2509) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2521](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2521) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2863](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2863) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2877) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2938](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2938) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2948) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [2961](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2961) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3092](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3092) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3123](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3123) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3127](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3127) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3152](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3152) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3163](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3163) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3167](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3167) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3183](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3183) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3238) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3242](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3242) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3268](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3268) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3272) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3317) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3322](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3322) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3401) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3422) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3438](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3438) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3442) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3468](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3468) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3474) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3478](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3478) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3482](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3482) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3488](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3488) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3532](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3532) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3544](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3544) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3577](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3577) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3642) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3703](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3703) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3744](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3744) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3764](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3764) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3784](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3784) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3813) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3842](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3842) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3948](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3948) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [3977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3977) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4080](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4080) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4125) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4137) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4153) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4178) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4184](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4184) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4191) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4200) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4238](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4238) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4299](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4299) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4313](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4313) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4352) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4393](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4393) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4409](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4409) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4422) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4486](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4486) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4580](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4580) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4592](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4592) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4675](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4675) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4687](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4687) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4765](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4765) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4787) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4857](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4857) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4919](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4919) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4931](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4931) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [4993](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4993) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [5027](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5027) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5088](file:///Users/jsph/cowhub/luascripts/preview.lua#L5088) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5104) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5422](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5422) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5467](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5467) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5540](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5540) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5572](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5572) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5611](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5611) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5678](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5678) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5724](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5724) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5766](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5766) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5800](file:///Users/jsph/cowhub/luascripts/preview.lua#L5800) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5819](file:///Users/jsph/cowhub/luascripts/preview.lua#L5819) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5825](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5825) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [7013](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7013) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [7125](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7125) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [7147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7147) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [7293](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7293) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [7324](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7324) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [7402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7402) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [7406](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7406) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [7414](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7414) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4817](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4817) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [8345](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8345) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [8360](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8360) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [8421](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8421) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [8427](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8427) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [8524](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8524) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [8602](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8602) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8628](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8628) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [8657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8657) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [8690](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8690) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [8786](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8786) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [8858](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8858) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [8951](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8951) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [8972](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8972) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [9029](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9029) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [9052](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9052) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [9137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9137) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [9151](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9151) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [9189](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9189) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [9218](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9218) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [9272](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9272) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [9309](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9309) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [9335](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9335) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [9364](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9364) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [9402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9402) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [9410](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9410) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [9522](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9522) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [9621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9621) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [9630](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9630) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [9646](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9646) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [9651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9651) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [9676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9676) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [9696](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9696) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [10000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10000) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [10017](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10017) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [10038](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10038) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [10047](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10047) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [10120](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10120) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [10132](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10132) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [10153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10153) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [10164](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10164) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [10176](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10176) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [10203](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10203) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [10307](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10307) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [10327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10327) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [10332](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10332) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [10396](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10396) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [10412](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10412) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [10430](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10430) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [10455](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10455) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [10470](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10470) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [10542](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10542) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [10586](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10586) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [10645](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10645) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [10730](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10730) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [10770](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10770) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [10803](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10803) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [10850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10850) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [10879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10879) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [10898](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10898) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [11011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11011) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [11033](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11033) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [11052](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11052) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [11090](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11090) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [11097](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11097) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [11153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11153) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [11231](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11231) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [11247](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11247) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [11390](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11390) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [11421](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11421) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [11494](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11494) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [11519](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11519) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [11541](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11541) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [11555](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11555) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [11573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11573) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [11579](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11579) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [11620](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11620) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [11659](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11659) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [11721](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11721) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [11786](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11786) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [11796](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11796) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [11812](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11812) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [11842](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11842) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [11890](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11890) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [12000](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12000) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [12065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12065) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [12136](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12136) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [12150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12150) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [12171](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12171) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [12176](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12176) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [12190](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12190) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [12209](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12209) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [12263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12263) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [12276](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12276) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [12299](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12299) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [12361](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12361) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [12369](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12369) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [12383](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12383) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [12389](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12389) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [12402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12402) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [12408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12408) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [12464](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12464) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [12502](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12502) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [12615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12615) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [12626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12626) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [12632](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12632) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [12652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12652) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [12674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12674) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [12688](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12688) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [12718](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12718) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [12745](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12745) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [12785](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12785) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [12826](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12826) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [13104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13104) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [13115](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13115) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [13582](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13582) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [13625](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13625) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [13642](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13642) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [13848](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13848) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [13923](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13923) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [13955](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13955) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [13992](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13992) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [14001](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14001) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [14011](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14011) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [14072](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14072) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [14104](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14104) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [14139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14139) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |
| [6069](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6069) | `fieldraid.runId()` | Current field raid run id (player attribute `CowFieldRaidId`). |
| [6073](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6073) | `fieldraid.inRaid()` | True while the cow is in a field raid run. |
| [6077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6077) | `fieldraid.fire(...)` | Fires `FieldRaidRequest` (raid start, graze, smith job) safely. |
| [6087](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6087) | `fieldraid.setStatus(text)` | Updates the Field Raid status paragraph. |
| [6097](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6097) | `fieldraid.isRaidMob(part)` | True for a raid enemy PrimaryPart (`CowBiteTargetKind` RaidMob). |
| [6101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6101) | `fieldraid.mobAlive(part)` | Raid mob is alive when its Health attribute is above 0. |
| [6106](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6106) | `fieldraid.scan(now, force)` | Throttled pass over `NorthRiverRaidView`: live mobs and available wheat. |
| [6128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6128) | `fieldraid.cellPoint(part, pos)` | Closest point of a wheat cell box to a position (bite distance). |
| [6137](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6137) | `fieldraid.findWheat(rootPos, now)` | Best food: in reach ripe, then richest BaseCalories, then nearest. |
| [6166](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6166) | `fieldraid.nearestMob(rootPos)` | Nearest live raid mob and its distance. |
| [6178](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6178) | `fieldraid.combatMods()` | Requires the game's FieldRaidCombat / FieldRaidEnemies modules. |
| [6188](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6188) | `fieldraid.addHazard(msg)` | Records a server attack telegraph (Windup / ProjectileAim / BarrageMark). |
| [6261](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6261) | `fieldraid.dropHazards(id)` | Forgets telegraphs of a cancelled or defeated mob. |
| [6269](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6269) | `fieldraid.danger(pos, serverNow, horizon)` | Game hit test (`FieldRaidCombat.Contains`) against live telegraphs. |
| [6282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6282) | `fieldraid.dodgeStep(now, rootPos)` | Moves the cow to the nearest safe ring spot when a telegraph covers it. |
| [6327](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6327) | `fieldraid.face(pos)` | Turns the root toward a target (raid mobs need facing). |
| [6337](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6337) | `fieldraid.ensureGraze()` | Sends `GrazeStart` once per run, like FieldRaidGraze.Hold. |
| [6345](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6345) | `fieldraid.chompWheat(now, rootPos)` | Bites the best raid wheat in reach via `chomp.send` (serial wire). |
| [6358](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6358) | `fieldraid.biteMob(part, now)` | Bites a raid mob via `chomp.send`, shares the mob aura cooldown. |
| [6376](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6376) | `fieldraid.forward(target, rootPos)` | Forward-only clamp: never aims behind the cow (+Z) unless banking manually. |
| [6387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6387) | `fieldraid.bandZ(level)` | Z span of a field level (FieldRaidLayout.Band on the run Planting). |
| [6398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6398) | `fieldraid.backLimit(rootPos)` | Furthest +Z allowed: whole max field when farming, else just behind the cow. |
| [6408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6408) | `fieldraid.walkTo(target, now)` | PathfindingService walk with stuck jump/sidestep recovery. |
| [6467](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6467) | `fieldraid.stopWalk()` | Clears the raid path and halts movement. |
| [6475](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6475) | `fieldraid.arena()` | Private raid arena model (`Geometry.PrivateFieldRaids`). |
| [6482](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6482) | `fieldraid.prompts(now)` | Rescans arena chest (`OpenHarvestChest`) and `GateExit` prompts. |
| [6500](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6500) | `fieldraid.promptPos(prompt)` | World position of a prompt holder. |
| [6508](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6508) | `fieldraid.firePrompt(prompt)` | fireproximityprompt wrapper. |
| [6516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6516) | `fieldraid.tryChest(now, rootPos)` | Walks to and opens an earned harvest chest. |
| [6539](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6539) | `fieldraid.fmtCal(n)` | Formats calories as K/M/B. |
| [6546](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6546) | `fieldraid.bank(now, rootPos)` | Manual Bank & Leave: walks to the Mill gate and fires GateExit. |
| [6573](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6573) | `fieldraid.startRun(now, rootPos)` | At the camp sign-up, starts a solo raid (`Solo`, 1). |
| [6613](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6613) | `fieldraid.setSprint(on, now)` | Throttled `SprintRequest` toggle while travelling in a raid. |
| [6620](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6620) | `fieldraid.travel(target, now)` | Sprint + path walk. |
| [6625](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6625) | `fieldraid.tick(now, rootPos)` | Field raid dispatcher: chest heal, blink/walk dodge, bite on the move, push deeper, sweep max field. |
| [6725](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6725) | `fieldraid.sweepBounds()` | Lateral bounds of the raid field (Planting, else FieldSoil). |
| [6740](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6740) | `fieldraid.sweep(now, rootPos)` | Deepest-field farming: lateral sprint passes, biting on the move. |
| [6223](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6223) | `fieldraid.spotClear(from, spot)` | Blink target check: ground below, no wall/fence in between. |
| [6232](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6232) | `fieldraid.blinkDodge()` | Instant forward-only step out of a telegraph landing within ~1.2 s. |
| [6818](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6818) | `fieldraid.smithRules()` | Requires SmithingRules + DayNightCycle. |
| [6828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6828) | `fieldraid.smithStatus(text)` | Updates the Blacksmith Shift status paragraph. |
| [6840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6840) | `fieldraid.smithEvent(msg)` | Handles SmithJob Status/Mark/Finished; fires perfect `SmithJobStrike`. |
| [6864](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6864) | `fieldraid.smithHead()` | Blacksmith NPC head when at work (BlacksmithSite.WorkingHead). |
| [6874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6874) | `fieldraid.smithAnvilPos()` | Blacksmith anvil position (AnvilCollider or constant). |
| [6885](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6885) | `fieldraid.smithReach(pos, range, label)` | Gets within range: opt-in teleport, else walk when close. |
| [6903](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6903) | `fieldraid.smithReturn()` | Teleports back to where the shift started. |
| [6912](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6912) | `fieldraid.smithTick()` | Anvil shift state machine: hire, hammer, turn in. |
| [6996](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6996) | `fieldraid.smithStart()` | Starts the tokened smith loop. |
| [16296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L16296) | `fieldraid.setFlag(flag, on)` | Sets a Rayfield flag (debug handle). |
| [16300](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L16300) | `fieldraid.setOption(label, on)` | Sets one Raid Options dropdown entry (debug handle). |

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
