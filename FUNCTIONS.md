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
- [Field Raid XP Autofarm (`field_raid_xp.lua`)](#field-raid-xp-autofarm-field_raid_xplua)

---

## Main Script Hub (`cowhub.lua` / `preview.lua`)

**Path**: [`luascripts/cowhub.lua`](file:///Users/jsph/cowhub/luascripts/cowhub.lua) *(synchronized with [`luascripts/preview.lua`](file:///Users/jsph/cowhub/luascripts/preview.lua))*

Primary CowHub script containing autofarm engines, mining, dodging, auction scanners, and Fjord rafting.

**Total Functions**: `295`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L150) | `safeNotify(opts)` | Displays UI notification or falls back to StarterGui:SetCore. |
| [193](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L193) | `resolveCharacter()` | Finds current player character model reliably. |
| [207](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L207) | `resolveRoot(character)` | Locates and caches HumanoidRootPart of target character. |
| [227](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L227) | `resolveHumanoid(character)` | Locates and caches Humanoid instance of character. |
| [234](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L234) | `getRootPos(targetRoot)` | Returns Vector3 position of root part with zero extra allocations. |
| [253](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L253) | `getRootCFrame(targetRoot)` | Returns CFrame of root part safely. |
| [271](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L271) | `setRootCFrame(cf, targetRoot)` | Safely teleports character root part and clears velocities. |
| [344](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L344) | `updateCharBaseParts(character)` | Caches all BaseParts in character for collision & physics manipulation. |
| [413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L413) | `updateWallRaycastFilter()` | Rebuilds RaycastParams collision mask ignoring player & transparent parts. |
| [444](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L444) | `setupHumanoid(h)` | Hooks humanoid death & state signals for recovery. |
| [915](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L915) | `mapOptimizer.optimizeInstance(inst)` | Disables shadows, lowers material fidelity, or removes decorative clutter. |
| [950](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L950) | `mapOptimizer.applyLighting()` | Strips atmospheric effects, bloom, sunrays for maximum FPS. |
| [967](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L967) | `mapOptimizer.applyTerrain()` | Lowers water wave size, disables decorations on terrain. |
| [981](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L981) | `mapOptimizer.applyToWorld()` | Runs full optimization pass on Workspace instances. |
| [998](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L998) | `mapOptimizer.startStreamHook()` | Pre-emptively requests streaming replication around target areas. |
| [1009](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1009) | `mapOptimizer.stopStreamHook()` | Cleans up streaming hooks and observers. |
| [1090](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1090) | `stopCharacterVelocity()` | Zeros AssemblyLinearVelocity and AssemblyAngularVelocity on all character parts. |
| [1109](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1109) | `isGuiObjectTrulyVisible(obj)` | Validates if GUI element is strictly visible (hierarchy, size, transparency). |
| [1147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1147) | `isRewardDismissButton(desc)` | Determines if button text/name matches reward modal dismissals (done, claim, ok). |
| [1186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1186) | `activateGuiButton(desc, vi)` | Simulates native click / VirtualInputManager press on GUI button. |
| [1264](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1264) | `resolveCowHubPath(fileName, subFolder)` | Resolves path inside dedicated cowhub folder/subfolder and migrates legacy files. |
| [1336](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1336) | `loadWebhook()` | Reads Discord webhook URL from local config file. |
| [1344](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1344) | `saveWebhook(url)` | Saves Discord webhook URL to disk. |
| [1375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1375) | `settings.load()` | Loads persisted settings (walkspeeds) from CowHub_Settings.json on disk. |
| [1412](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1412) | `settings.save()` | Persists current settings (walkspeeds) to CowHub_Settings.json on disk. |
| [1441](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1441) | `afkRelog.saveState()` | Persists session state before scheduled 6-hour rejoin. |
| [1513](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1513) | `afkRelog.triggerRejoin()` | Executes TeleportService rejoin into current or reserve server. |
| [1564](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1564) | `afkRelog.checkAndResumeState()` | Detects recent reconnect and restores active autofarms. |
| [1764](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1764) | `afkRelog.startTimer()` | Spawns countdown timer for 6-hour auto-reconnect cycle. |
| [1787](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1787) | `afkRelog.updateUI()` | Updates UI text card showing time remaining until next relog. |
| [1832](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1832) | `getSpiderPosKey(pos)` | Generates grid-quantized string key from spider Vector3 coordinates. |
| [1840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1840) | `spiderLogger.load()` | Loads known spider identifier JSON cache from disk. |
| [1866](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1866) | `spiderLogger.save()` | Flushes identified spider entries into JSON file on disk. |
| [1878](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1878) | `spiderLogger.extractIdentifier(val, depth)` | Scans mob model attributes and string tags for unique spider IDs. |
| [1927](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1927) | `spiderLogger.getMobPosition(mob)` | Extracts world position of spider PrimaryPart. |
| [1942](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L1942) | `spiderLogger.recordIdentifier(idStr, source, mobInstance, extraRaw)` | Saves newly resolved spider identifier with source context. |
| [2003](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2003) | `spiderLogger.resolveSpiderIdentifier(mob)` | Matches runtime spider instance against known cached identifiers. |
| [2043](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2043) | `onChompRemoteReceived(source, ...)` | Listens for server chomp network confirmations. |
| [2075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2075) | `chompEvent.OnClientInvoke(...)` | Handles server validation callbacks for player chomp events. |
| [2636](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2636) | `get2DDistance(p1, p2)` | Calculates 2D Euclidean distance (X, Z plane) without heap allocations. |
| [2643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2643) | `get2DDistanceSq(p1, p2)` | Calculates squared 2D distance for high-speed radius comparisons. |
| [2650](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2650) | `get3DDistanceSq(p1, p2)` | Calculates squared 3D distance between two points. |
| [2663](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2663) | `getResourcesFolder()` | Returns cached reference to workspace Resources folder. |
| [2673](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2673) | `cache.getNodePosition(node)` | Retrieves world position of grass / crop node. |
| [2685](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2685) | `cache.grassNear(pos, radius)` | Grass visuals near a point via GetPartBoundsInRadius (spatial index, not a full folder scan). |
| [2700](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2700) | `cache.getGrassNodes()` | Returns cached table of harvestable grass nodes. |
| [2726](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2726) | `cache.getFishingSpotsFolder()` | Finds fishing zones folder in workspace. |
| [2735](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2735) | `cache.getFishingSpots()` | Collects all fishing spot models with active waters. |
| [2752](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2752) | `cache.getSpotPosition(spot)` | Extracts Vector3 center of target fishing spot. |
| [2767](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2767) | `isValidGrassNodeID(id)` | Validates grass node ID against invalid / barren models. |
| [2774](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2774) | `cache.resolveGrassNode(inst)` | Locates PrimaryPart and identity of grass node model. |
| [2800](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2800) | `cache.getNodeID(node)` | Extracts numeric node identifier from instance name or attribute. |
| [2850](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2850) | `cache.getCleanGrassName(nodeName)` | Strips numerical suffixes from grass model names. |
| [2873](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2873) | `cache.extractGrassNodeId(target)` | Extracts node ID from interaction target instance. |
| [2898](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2898) | `cache.getMobPayload(mobName)` | Retrieves cached network attack payload table for mob species. |
| [preview 2096](file:///Users/jsph/cowhub/luascripts/preview.lua#L2096) | `chomp.log(event, data)` | **Staging only.** Buffers a debug JSON line while Chomp Debug Log is on. Stripped from cowhub.lua by `scripts/promote-preview.py`. |
| [preview 2105](file:///Users/jsph/cowhub/luascripts/preview.lua#L2105) | `chomp.flushLog(force)` | **Staging only.** Writes buffered debug lines to `cowhub/chomplogs/` at most every 2 s. |
| [2226](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2226) | `chomp.serverInterval(node)` | Fastest server-accepted bite interval from live ChewCooldown / grazing multiplier (wheat & node cooldown aware). |
| [2241](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2241) | `chomp.getInterval(node)` | Server interval + adaptive margin, floored at the manual delay when Auto Max is off. |
| [398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L398) | `findGrassFolder()` | Returns the `CowVirtualGrass` folder the game targets (`CowClientGrassRenderer`). |
| [2262](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2262) | `chomp.canTarget(node, id, rootPos, now)` | Mirrors the game's grass target rules: skip/reservation list, `Available`, exclusions, 8-stud reach and forward cone judged from the lag-compensated (server-view) position. |
| [2296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2296) | `chomp.fire(nodeId, node, now)` | Single grass ChompRequest call site; fires `(nodeId, nil, serial)` when the interval has elapsed. |
| [2408](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2408) | `chomp.findInput(now)` | Locates the game InputController instance via `getgc` (cached, 5 s rescan throttle). |
| [2424](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2424) | `chomp.isGrazing()` | Returns `grazing, source`: controller `_grazing`, else `CowAction` attr, else recent non-hub GrazeResult. |
| [2434](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2434) | `chomp.canEngage()` | Blocks E input during cutscenes, capture, stun, bot check, or focused textbox. |
| [2443](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2443) | `chomp.sendKey(down)` | Sends E key down/up through VirtualInputManager (keypress fallback). |
| [2455](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2455) | `chomp.engage(now)` | Natural mode: taps E (Toggle Graze setting) or re-holds E (hold setting). |
| [2481](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2481) | `chomp.release()` | Releases a held E key. |
| [2492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2492) | `chomp.stopNatural()` | Release + untoggle grazing when leaving Natural mode. |
| [2504](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2504) | `chomp.tickNatural(now)` | Natural watchdog: re-engages grazing after drops and mob attacks. |
| [2532](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2532) | `chomp.onMobAttack(now)` | Shares chew cooldown with mob bites and arms natural re-engage. |
| [2545](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2545) | `chomp.getCalories()` | Returns current player calories from attribute or leaderstats. |
| [2558](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2558) | `chomp.resetCalories()` | Resets active chomp session calorie counter and timer. |
| [2570](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2570) | `chomp.updateCalories()` | Tracks positive calorie deltas during Auto-Chomp into session gained. |
| [2912](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2912) | `cache.cleanupNodeBlacklist(now)` | Removes expired blacklisted nodes from memory. |
| [2926](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2926) | `manatite.getFolder()` | Finds Manatite cluster folder in workspace. |
| [2987](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2987) | `manatite.getModels()` | Collects all active Manatite crystal models. |
| [2997](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L2997) | `manatite.getGrazeTarget(model)` | Finds optimal hit point on Manatite cluster. |
| [3010](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3010) | `manatite.getGrazeTargetYield(target, model)` | Estimates ore yield / remaining health of crystal. |
| [3141](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3141) | `isOreAvailable(targetPart, model, checkYield)` | Checks if ore node is intact and not currently depleted. |
| [3172](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3172) | `manatite.isAvailable(target, model)` | Verifies availability of target Manatite crystal. |
| [3176](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3176) | `manatite.getPayload(modelName)` | Constructs network graze packet for Manatite harvesting. |
| [3201](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3201) | `cleanupOreBlacklist(oreState, now)` | Clears expired ore node blacklist timestamps. |
| [3212](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3212) | `manatite.cleanupBlacklist(now)` | Removes blacklisted Manatite nodes whose cooldowns elapsed. |
| [3216](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3216) | `isPositionNearThreatMob(pos, distSq)` | Checks if target coordinates lie inside mob threat aggro radius. |
| [3232](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3232) | `findNextOreCandidate(oreState, getTargetFn, checkYield, searchOrigin, avoidMobs)` | Scans workspace for closest valid, non-blacklisted ore candidate. |
| [3287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3287) | `manatite.findNext(searchOrigin, avoidMobs)` | Finds nearest valid Manatite node avoiding hostile mobs. |
| [3291](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3291) | `teleportToOreNode(oreState, targetPart, model)` | Teleports character into harvesting position adjacent to ore node. |
| [3317](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3317) | `manatite.teleport(grazeTarget, model)` | Moves player to target Manatite crystal. |
| [3321](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3321) | `retreatOreNode(oreState, isMithril, title, content, now, rootPos)` | Executes emergency retreat away from dangerous ore spot. |
| [3366](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3366) | `manatite.retreatToSafeCrystal(now, rootPos)` | Falls back to known safe crystal during threat. |
| [3371](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3371) | `mithril.getFolder()` | Locates Mithril cave folder in workspace. |
| [3450](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3450) | `mithril.getModels()` | Collects active Mithril ore models in cave systems. |
| [3471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3471) | `mithril.getOrePart(model)` | Finds interactable base part of Mithril node. |
| [3487](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3487) | `mithril.isAvailable(orePart, model)` | Verifies Mithril ore node health and availability. |
| [3491](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3491) | `mithril.getPayload(modelName)` | Builds network attack packet for Mithril harvesting. |
| [3517](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3517) | `mithril.cleanupBlacklist(now)` | Purges expired entries from Mithril node blacklist. |
| [3523](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3523) | `mithril.findNext(searchOrigin, avoidMobs)` | Finds nearest safe Mithril node in cave. |
| [3527](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3527) | `mithril.retreatToSafeOre(now, rootPos)` | Retreats player away from hostile cave spiders. |
| [3531](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3531) | `mithril.teleport(orePart, model)` | Teleports character to target Mithril ore part. |
| [3537](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3537) | `dodge.getMobAttackOriginPart(mob)` | Resolves head/torso part where mob attack origin spawns. |
| [3581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3581) | `dodge.getMobAttackOrigin(mob)` | Calculates Vector3 world position of mob attack source. |
| [3593](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3593) | `dodge.hasLineOfSight(origin, mobPos, mob)` | Raycasts between mob and player to verify threat line of sight. |
| [3626](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3626) | `dodge.isMobAlive(mob)` | Verifies target mob has valid health and humanoid state. |
| [3691](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3691) | `dodge.findAttackWarning(mob)` | Detects active red warning telegraphs or charge indicators. |
| [3752](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3752) | `dodge.isWarningActive(warning, mob)` | Checks if detected threat warning is currently ticking. |
| [3793](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3793) | `dodge.getLocalPlayerHearts()` | Reads current player heart count from UI / attributes. |
| [3813](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3813) | `dodge.getLocalPlayerMaxHearts()` | Reads maximum player heart capacity. |
| [3833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3833) | `dodge.getLocalPlayerArmor()` | Reads current player armor durability. |
| [3862](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3862) | `dodge.getLocalPlayerMaxArmor()` | Reads maximum player armor rating. |
| [3891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3891) | `dodge.findSafeDodgePosition(originPos, preCFrame, away2D, maxDist, preferredAngle, attackingMob)` | Calculates safe offset away from attack direction. |
| [3997](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L3997) | `pressE()` | Simulates pressing E key via VirtualInputManager. |
| [4026](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4026) | `cache.findSpiderIdentifier(mob)` | Extracts unique identifier for cave spider mob. |
| [4129](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4129) | `cache.getMithrilCaveSpidersFolder()` | Locates workspace folder containing cave spiders. |
| [4174](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4174) | `dodge.isSpiderMobInstance(instance)` | Checks if instance is a hostile spider mob. |
| [4186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4186) | `dodge.isMithrilCaveMob(mob)` | Identifies if mob belongs to Mithril cave threat pool. |
| [4202](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4202) | `dodge.collectSpidersFromChamber(chamber)` | Gathers all active spiders in specified cave chamber. |
| [4227](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4227) | `cache.registerRipple(ripple)` | Adds newly spawned water ripple into active tracking table. |
| [4233](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4233) | `cache.unregisterRipple(ripple)` | Removes despawned ripple from active tracking table. |
| [4240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4240) | `cache.cleanupRippleTracking()` | Cleans up all tracked water ripple connections. |
| [4249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4249) | `cache.initRippleTracking()` | Sets up workspace ChildAdded listener for water ripples. |
| [4287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4287) | `cache.cacheBackgroundElements()` | Updates background spatial partitions for mobs and nodes. |
| [4348](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4348) | `cache.getRipplePosition(ripple)` | Extracts world position of water ripple part. |
| [4362](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4362) | `cache.isSpotAvailable(spot)` | Checks if fishing spot is occupied or accessible. |
| [4401](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4401) | `penESP.update()` | Renders bounding boxes and labels for animal pens. |
| [4442](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4442) | `chestESP.removeVisual(model)` | Removes highlight and billboard adornments for a specific chest. |
| [4458](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4458) | `chestESP.cleanup()` | Clears highlight and billboard adornments on all chests. |
| [4471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4471) | `chestESP.attach(trackedChest)` | Attaches visual ESP Adornment to newly discovered chest. |
| [4535](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4535) | `chestESP.update()` | Refreshes chest ESP positions and distance tags. |
| [4629](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4629) | `manatite.cleanupVisuals()` | Removes highlight adornments from Manatite crystals. |
| [4641](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4641) | `manatite.updateESP()` | Renders ESP highlights and distance labels on Manatite nodes. |
| [4724](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4724) | `mithril.cleanupVisuals()` | Removes highlight adornments from Mithril ore nodes. |
| [4736](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4736) | `mithril.updateESP()` | Renders ESP highlights and distance labels on Mithril nodes. |
| [4814](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4814) | `HandleSpam(keyName, state, delayTime)` | Debounces rapid key presses or remote invocations. |
| [4836](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4836) | `formatNumber(n)` | Formats integers with comma separators for currency displays. |
| [4906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4906) | `auction.checkLots()` | Inspects active auction house lots for desired items/prices. |
| [4968](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4968) | `auction.debouncedCheckLots()` | Debounced wrapper around auction lot scanner. |
| [4980](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4980) | `cache.sanitizeMemory(now)` | Runs periodic garbage collection and clears stale cache references. |
| [5042](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5042) | `aerial.process(now, rootPos)` | Maintains emergency aerial hover position during low health. |
| [5076](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5076) | `aerial.checkHealth(now, rootPos)` | Evaluates player heart drops to trigger aerial retreat. |
| [preview 5097](file:///Users/jsph/cowhub/luascripts/preview.lua#L5097) | `dodge.nearestMob(pos, maxDistSq)` | Nearest alive aura mob, the flee origin for damage-only retreats; staging only (Plan 1.10). |
| [5153](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5153) | `dodge.process(now, rootPos)` | Executes main evasion step (underground retreat, blink, or run away). |
| [5471](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5471) | `dodge.cleanup()` | Resets dodge state and restores original walkspeed / collision. |
| [5516](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5516) | `dodge.checkNearbyThreat(now, rootPos, prioritizedMobThisFrame)` | Scans 3D radius for approaching hostile mobs. |
| [5589](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5589) | `farm.isSolidObstacle(instance)` | Checks if part impedes direct farming traversal. |
| [5621](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5621) | `farm.hasWallBetween(startPos, endPos)` | Raycasts between character and target to detect walls. |
| [5660](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5660) | `farm.checkForwardWall(rootPos, moveDir, checkDist)` | Subsystem helper / execution logic. |
| [5727](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5727) | `farm.findClearEscapeDirection(rootPos)` | Subsystem helper / execution logic. |
| [5773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5773) | `farm.isEdible(node)` | Grass node edible by the server's rule (`Available == true`) (Plan 1.7). |
| [5815](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5815) | `farm.findBait(rootPos, now)` | Closest GrazingBaitFind drop inside the farm radius (not over water, not skipped) (Plan 1.8). |
| [preview 5809](file:///Users/jsph/cowhub/luascripts/preview.lua#L5809) | `farm.teleportTo(target)` | Teleport the character and re-home the autofarm anchor; staging only (Plan 1.9). |
| [preview 5828](file:///Users/jsph/cowhub/luascripts/preview.lua#L5828) | `farm.nodeValue(node)` | Bite value: GrowthProgress × 2 when Golden; staging only (Plan 1.9). |
| [5874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L5874) | `farm.processMovement(dt, now, rootPos)` | Controls character movement along farming patrol path. |
| [7263](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7263) | `farm.processMobAura(now, rootPos)` | Dispatches auto-attacks against hostile mobs in aura range. |
| [7375](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7375) | `farm.processGrassChomp(now, rootPos)` | Directs raycast grass harvesting toward nearest target. |
| [7397](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7397) | `tryCandidate(inst, id)` | Subsystem helper / execution logic. |
| [7543](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7543) | `farm.processFishing(now, rootPos)` | Manages automated casting, reel timing, and ripple interaction. |
| [7574](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7574) | `processOreFarm(oreState, isMithril, now, rootPos)` | Generic mining loop step handling teleportation, grazing, and threat checks. |
| [7652](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7652) | `manatite.process(now, rootPos)` | Heartbeat mining loop tick for Manatite farming. |
| [7656](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7656) | `mithril.process(now, rootPos)` | Heartbeat mining loop tick for Mithril farming. |
| [7664](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7664) | `updateHeartbeatConnection()` | Main RunService.Heartbeat connection dispatcher for all farms. |
| [4866](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L4866) | `auction.getLocalDisplayName()` | Returns local player username / display name. |
| [8594](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8594) | `auction.formatRemainingTime(endsAt)` | Formats remaining lot duration into MM:SS format. |
| [8609](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8609) | `auction.getLotDisplayInfo(lotName)` | Parses lot metadata, seller, bids, and current price. |
| [8670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8670) | `auction.updateLotDisplay(lotName)` | Subsystem helper / execution logic. |
| [8676](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8676) | `auction.updateAllLotDisplays()` | Subsystem helper / execution logic. |
| [8773](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8773) | `auction.executeBid(lotName, customAmount, isManual)` | Subsystem helper / execution logic. |
| [8851](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8851) | `auction.parseAmount(input)` | Subsystem helper / execution logic. |
| [8877](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8877) | `auction.findTextBox(lotName)` | Subsystem helper / execution logic. |
| [8906](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8906) | `auction.resolveCustomAmount(lotName)` | Subsystem helper / execution logic. |
| [8939](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L8939) | `auction.setupLotUI(tab, lotName)` | Subsystem helper / execution logic. |
| [9035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9035) | `auction.checkAndAutoBidLot(lotName)` | Evaluates outbid threshold and automatically submits higher bid. |
| [9107](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9107) | `onLotAttributeChanged()` | Triggers outbid check when lot attribute updates. |
| [9200](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9200) | `townAuction.getFitoutModel()` | Finds Town Auction billboard and stage model in workspace. |
| [9221](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9221) | `townAuction.getRemote()` | Locates network remote event for Town Auction bids. |
| [9278](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9278) | `townAuction.formatRemainingTime(endsAt)` | Formats remaining Town Auction timer string. |
| [9301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9301) | `townAuction.getSlotDisplayInfo(slotName)` | Subsystem helper / execution logic. |
| [9386](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9386) | `townAuction.updateCard(slotName)` | Subsystem helper / execution logic. |
| [9400](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9400) | `townAuction.updateInfoCard()` | Subsystem helper / execution logic. |
| [9438](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9438) | `townAuction.updateAllCards()` | Subsystem helper / execution logic. |
| [9467](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9467) | `townAuction.handleSnapshotResult(res)` | Subsystem helper / execution logic. |
| [9521](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9521) | `townAuction.fetchSnapshot(isManual)` | Requests snapshot of current town auction bids. |
| [9558](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9558) | `townAuction.parseAmount(input)` | Subsystem helper / execution logic. |
| [9584](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9584) | `townAuction.findTextBox(slotName)` | Subsystem helper / execution logic. |
| [9613](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9613) | `townAuction.resolveCustomAmount(slotName)` | Subsystem helper / execution logic. |
| [9651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9651) | `townAuction.hasAnyAutoBidActive()` | Subsystem helper / execution logic. |
| [9659](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9659) | `townAuction.checkAndAutoBidSlot(slotName)` | Subsystem helper / execution logic. |
| [9771](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9771) | `townAuction.executeBid(slotName, customAmount, forcePrice)` | Subsystem helper / execution logic. |
| [9870](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9870) | `townAuction.teleportToStore()` | Subsystem helper / execution logic. |
| [9879](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9879) | `townAuction.startAutoRefresh()` | Subsystem helper / execution logic. |
| [9895](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9895) | `townAuction.stopAutoRefresh()` | Subsystem helper / execution logic. |
| [9900](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9900) | `townAuction.cleanup()` | Subsystem helper / execution logic. |
| [9925](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9925) | `townAuction.initWorkspaceListeners()` | Subsystem helper / execution logic. |
| [9945](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L9945) | `townAuction.setupSlotUI(tab, slotName)` | Subsystem helper / execution logic. |
| [10249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10249) | `rafting.getRemote()` | Returns network remote event for Fjord Rafting commands. |
| [10266](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10266) | `rafting.fireRemoteSafely(action, arg, debounceSec)` | Debounced network remote invocation for raft commands. |
| [10287](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10287) | `rafting.deckSessionOf(deck, model)` | Session id a raft deck belongs to (RaftSessionId attribute or TeamRaft_ name). |
| [10296](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10296) | `rafting.getRaftDeck()` | Finds this session's raft deck; caches only a deck whose RaftSessionId matches, never another crew's raft. |
| [10369](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10369) | `getFjordLevel(posX)` | Subsystem helper / execution logic. |
| [10381](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10381) | `getHarbourZ(posX)` | Subsystem helper / execution logic. |
| [10402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10402) | `placeCowAboveDeck(deck)` | Subsystem helper / execution logic. |
| [10413](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10413) | `isCowOnDeck(deck)` | Subsystem helper / execution logic. |
| [10425](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10425) | `rafting.pickCaveEntrance(siteId, coves)` | Subsystem helper / execution logic. |
| [10452](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10452) | `rafting.ensureDynamicSites()` | Subsystem helper / execution logic. |
| [10556](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10556) | `rafting.getSiteChannelZ(site)` | Subsystem helper / execution logic. |
| [10576](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10576) | `rafting.getClearingById(siteId)` | Retrieves metadata for specified clearing identifier. |
| [10581](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10581) | `rafting.getNearbyClearing(posX, posZ)` | Finds clearing closest to raft current coordinates. |
| [10645](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10645) | `rafting.findChannel(reachIdx, nominalChZ)` | Resolves water channel segment for given reach index. |
| [10661](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10661) | `rafting.getChannelCenterZ(reachIdx, nominalChZ, posX)` | Calculates central Z coordinate of river channel. |
| [10679](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10679) | `rafting.getRouteCenterZ(reachIdx, nominalChZ, posX)` | Calculates target Z coordinate along selected route corridor. |
| [10704](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10704) | `rafting.channelFrame(posX, posZ)` | Computes local coordinate frame relative to river channel. |
| [10719](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10719) | `rafting.getCurrentChannel(posX, posZ)` | Identifies which water channel the raft currently occupies. |
| [10791](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10791) | `rafting.selectOptimalPipeline()` | Determines best routing sequence based on selected clearings. |
| [10835](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10835) | `getDownstreamChannelZ(reachIdx, curChZ, prefRoute)` | Calculates channel target Z coordinate for downstream reaches. |
| [10894](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10894) | `getReachableChannelsInReach(curReach, curChZ, targetReach)` | Enumerates all reachable downstream channels from current position. |
| [10979](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L10979) | `rafting.isSiteReachable(site, posX, currentZ)` | Evaluates if clearing or cave can be reached without hitting rocks. |
| [11019](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11019) | `rafting.channelLeadsToSite(curChZ, curReach, site, mouthX)` | Whether a channel can reach the site downstream. |
| [11052](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11052) | `getEndCaveSite(currentZ)` | Returns final destination cave site for current route. |
| [11099](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11099) | `rafting.isSiteSelected(site)` | Checks if clearing is checked in user configuration. |
| [11128](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11128) | `rafting.logTargetChange(site, posX, posZ)` | Logs RaftTarget on each steering-target change, with selected sites already visited. |
| [11147](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11147) | `rafting.getNextTargetClearing(posX, currentZ)` | Finds upcoming target clearing along travel path. |
| [11260](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11260) | `parseSiteId(opt)` | Extracts clearing site ID from UI dropdown string. |
| [11282](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11282) | `rafting.getSiteZone(siteOrId)` | Returns zone index (1-4) for specified clearing. |
| [11301](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11301) | `rafting.updateZoneSites(zoneIdx, options)` | Updates selection state for all clearings in a zone. |
| [11339](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11339) | `rafting.updateTargetClearings(options)` | Batch updates clearing selection from UI dropdown. |
| [11346](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11346) | `parseOption(opt)` | Helper to parse UI multi-select option string. |
| [11402](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11402) | `rafting.getWhiskerClearances(deck)` | Raycasts multi-whisker sensors ahead of raft to detect riverbanks. |
| [11480](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11480) | `rafting.getTargetZ(posX, currentZ, clearances)` | Calculates target lateral Z position balancing route and obstacles. |
| [11496](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11496) | `rafting.getRiverTargetZ(posX, currentZ, clearances)` | Refines target lateral position based on river current. |
| [11639](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11639) | `walkToPosition(targetPos, timeout, stopDistance)` | Humanoid path walk to local target position with timeout. |
| [11670](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11670) | `naturalWalkTo(targetWorldPos, timeout, stopDistance)` | Smooth movement step toward local world position. |
| [11743](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11743) | `ensureCowOnDeck(deck, timeoutSecs)` | Safely verifies and resets character onto raft deck surface. |
| [11768](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11768) | `triggerChestNatively(chestModel)` | Interacts with clearing chest prompt natively. |
| [11790](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11790) | `sendRaftKey(keyCode, holdSec)` | Simulates key press (A/D) to steer raft rudder. |
| [11804](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11804) | `getContinueButton()` | Finds dock 'Continue Voyage' UI button. |
| [11822](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11822) | `isContinueButtonActive()` | Checks if dock continue prompt is currently visible. |
| [11828](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11828) | `isBoardingAnimationActive()` | Checks if raft boarding camera animation is active. |
| [11869](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11869) | `triggerRaftingCommand(cmd)` | Dispatches remote command (Board, CastOff, Repair). |
| [11908](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11908) | `rafting.castOff()` | Casts off raft from dock to begin voyage. |
| [11970](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L11970) | `rafting.updateCards()` | Refreshes Rayfield UI cards with live voyage metrics. |
| [12035](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12035) | `rafting.handleHobgoblinRock(rock)` | Predicts projectile impact point for thrown goblin rocks. |
| [12045](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12045) | `rafting.handleHobgoblinLanded(landed)` | Avoids landing zone of hobgoblin rock. |
| [12061](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12061) | `rafting.getRockThreats(deck)` | Lists rocks in flight whose landing lines up with the hull at impact. |
| [12091](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12091) | `rafting.avoidRocks(deck, wantedDeckX, leftClear, rightClear, isCommitted)` | Keeps the wanted deck position unless it ends in a rock hit, then moves it as little as clears every rock. When committed (route error ≥ ROCK_COMMIT_ERROR), it never reverses the correction. |
| [12139](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12139) | `rafting.dismissChestRewardGui(force)` | Dismisses clearing chest reward popup modal without equipping. |
| [12249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12249) | `rafting.pollRewardGuiUntilDismissed(timeoutSecs, force)` | Polls reward popup until dismissed or timeout expires. |
| [12314](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12314) | `rafting.lootSingleSite(targetSite)` | Performs full looting sequence on target clearing / cave. |
| [12385](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12385) | `rafting.findSiteChest(siteId)` | Returns the unopened chest named by that site's own snapshot, or whether it was already opened. |
| [12399](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12399) | `rafting.awaitChestOutcome(chest, timeout)` | Waits for the server's answer to a chest request. |
| [12420](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12420) | `rafting.siteIdOfChest(chest)` | Extracts the site id from a chest id. |
| [12425](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12425) | `rafting.cowStandHeight()` | Root height above the floor when the cow stands (HipHeight + half root, fallback 4.8). |
| [12439](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12439) | `rafting.placeCowAtChest(chest, standPos)` | Teleports the cow upright onto the chest ground facing the chest, and gets it up if it has fallen over. |
| [12458](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12458) | `rafting.openChest(chest)` | Stands beside the chest and requests it, trying other sides if blocked; only a server answer counts. |
| [12512](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12512) | `rafting.lootSiteGuarded(targetSite)` | Runs one site's loot under pcall and logs RaftLootError instead of leaving the loot lock held. |
| [12525](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12525) | `rafting.armLootDeadline(siteId)` | Starts a dock's loot run; after 90 s a stalled run is abandoned, the cow reboarded and the raft cast off. |
| [12548](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12548) | `rafting.sweepZoneChests(zoneNum, deck)` | Loots all available chests in current river zone. |
| [12610](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12610) | `rafting.findStation(snap, stationId)` | Finds a repair station in the snapshot. |
| [12618](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12618) | `rafting.pickDamagedStation(snap, cowRel)` | Picks the damaged station nearest the cow. |
| [12632](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12632) | `rafting.energyReserve(posX, snap)` | Energy needed to reach the sea and leave a dock. |
| [12638](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12638) | `rafting.gameConfig()` | Reads RaftingConfig values with fallbacks. |
| [12651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12651) | `rafting.isHealthLow(hp, maxHp)` | Low-health test: the slider value or 15% of max, whichever is higher. |
| [12657](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12657) | `rafting.repairAtDock()` | Patches damaged stations with the full repair protocol while docked. |
| [12713](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12713) | `rafting.stepRepairUnderway(snap, deck, posX, allowed)` | Patches while sailing: moves along the deck to the station row and keeps steering. |
| [12751](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12751) | `rafting.lootReachChests(dockSite, deck)` | Loots dock and reach chests during mooring stop. |
| [12864](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12864) | `rafting.telemetryText(value, depth)` | Formats telemetry data into structured key-value line. |
| [12875](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12875) | `rafting.telemetryLine(line)` | Appends formatted telemetry line to buffer. |
| [12881](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12881) | `rafting.telemetryFlush(force)` | Flushes voyage telemetry buffer to disk file. |
| [12901](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12901) | `rafting.telemetryStart(sessionId)` | Initializes new telemetry logging session on disk. |
| [12923](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12923) | `rafting.telemetryEvent(name, payload)` | Logs discrete telemetry event (damage, turn, dock). |
| [12937](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12937) | `rafting.telemetryObserve(payload)` | Captures sensor observation snapshot for machine learning analysis. |
| [12967](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12967) | `rafting.telemetryWeather(pos)` | Logs atmospheric conditions and wind vectors. |
| [12994](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L12994) | `rafting.telemetrySample(snap, deck, targetZ, errorZ, clearances)` | Records high-frequency navigation sample (speed, error, whiskers). |
| [13034](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13034) | `rafting.surveyFacades()` | Surveys geometric cliff faces along river channel. |
| [13075](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13075) | `rafting.handleSnapshot(payload)` | Processes server voyage state snapshot (health, distance, speed). |
| [13353](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13353) | `rafting.handleBoarding(payload)` | Handles character seating and camera transition upon boarding. |
| [13364](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13364) | `rafting.stepSteering(dt)` | Main PID steering tick calculating rudder corrections. |
| [13831](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13831) | `rafting.stepSteeringAnimation(dt)` | Animates character steering wheel / oar interaction. |
| [13874](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13874) | `rafting.getLaunchTarget()` | Calculates launch coordinates from dock into main river current. |
| [13891](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L13891) | `rafting.startVoyage()` | Initiates full autonomous rafting voyage sequence. |
| [14097](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14097) | `rafting.onSessionEnded(reason)` | Handles voyage completion or premature termination. |
| [14172](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14172) | `rafting.scheduleLoopRestart()` | Single auto-loop restart: waits for the server to close the session and for a live character, starts the next voyage, retries if no session appears. |
| [14204](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14204) | `rafting.endVoyage()` | Cleans up rafting session and resets character state. |
| [14240](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14240) | `rafting.teleportToRaftYard()` | Teleports player character to Fjord rafting entrance. |
| [14249](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14249) | `rafting.teleportToDeck()` | Teleports character onto raft deck safely. |
| [14259](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14259) | `rafting.initClientListener()` | Hooks server network events for rafting snapshots. |
| [14320](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14320) | `rafting.startSteeringLoop()` | Starts background steering task loop. |
| [14352](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14352) | `rafting.stopSteeringLoop()` | Stops steering task loop. |
| [14387](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L14387) | `rafting.cleanup()` | Full teardown of rafting state, timers, and connections. |
| [6118](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6118) | `fieldraid.runId()` | Current field raid run id (player attribute `CowFieldRaidId`). |
| [6122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6122) | `fieldraid.inRaid()` | True while the cow is in a field raid run. |
| [6126](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6126) | `fieldraid.fire(...)` | Fires `FieldRaidRequest` (raid start, graze, smith job) safely. |
| [6136](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6136) | `fieldraid.setStatus(text)` | Updates the Field Raid status paragraph. |
| [6146](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6146) | `fieldraid.isRaidMob(part)` | True for a raid enemy PrimaryPart (`CowBiteTargetKind` RaidMob). |
| [6150](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6150) | `fieldraid.mobAlive(part)` | Raid mob is alive when its Health attribute is above 0. |
| [6155](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6155) | `fieldraid.scan(now, force)` | Throttled pass over `NorthRiverRaidView`: live mobs and available wheat. |
| [6177](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6177) | `fieldraid.cellPoint(part, pos)` | Closest point of a wheat cell box to a position (bite distance). |
| [6186](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6186) | `fieldraid.findWheat(rootPos, now)` | Best food: in reach ripe, then richest BaseCalories, then nearest. |
| [6215](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6215) | `fieldraid.nearestMob(rootPos)` | Nearest live raid mob and its distance. |
| [6227](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6227) | `fieldraid.combatMods()` | Requires the game's FieldRaidCombat / FieldRaidEnemies modules. |
| [6237](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6237) | `fieldraid.addHazard(msg)` | Records a server attack telegraph (Windup / ProjectileAim / BarrageMark). |
| [6347](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6347) | `fieldraid.dropHazards(id)` | Forgets telegraphs of a cancelled or defeated mob. |
| [6373](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6373) | `fieldraid.danger(pos, serverNow, horizon)` | Game hit test (`FieldRaidCombat.Contains`) against live telegraphs. |
| [6398](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6398) | `fieldraid.dodgeStep(now, rootPos)` | Moves the cow to the nearest safe ring spot when a telegraph covers it. |
| [6443](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6443) | `fieldraid.face(pos)` | Turns the root toward a target (raid mobs need facing). |
| [6453](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6453) | `fieldraid.ensureGraze()` | Sends `GrazeStart` once per run, like FieldRaidGraze.Hold. |
| [6461](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6461) | `fieldraid.chompWheat(now, rootPos)` | Bites the best raid wheat in reach via `chomp.send` (serial wire). |
| [6474](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6474) | `fieldraid.biteMob(part, now)` | Bites a raid mob via `chomp.send`, shares the mob aura cooldown. |
| [6492](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6492) | `fieldraid.forward(target, rootPos)` | Forward-only clamp: never aims behind the cow (+Z) unless banking manually. |
| [6503](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6503) | `fieldraid.bandZ(level)` | Z span of a field level (FieldRaidLayout.Band on the run Planting). |
| [6514](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6514) | `fieldraid.backLimit(rootPos)` | Furthest +Z allowed: whole max field when farming, else just behind the cow. |
| [6528](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6528) | `fieldraid.walkTo(target, now)` | PathfindingService walk with stuck jump/sidestep recovery. |
| [6587](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6587) | `fieldraid.stopWalk()` | Clears the raid path and halts movement. |
| [6597](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6597) | `fieldraid.arena()` | Private raid arena model (`Geometry.PrivateFieldRaids`). |
| [6615](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6615) | `fieldraid.prompts(now)` | Rescans arena chest (`OpenHarvestChest`) and `GateExit` prompts. |
| [6635](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6635) | `fieldraid.promptPos(prompt)` | World position of a prompt holder. |
| [6643](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6643) | `fieldraid.firePrompt(prompt)` | fireproximityprompt wrapper. |
| [6651](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6651) | `fieldraid.tryChest(now, rootPos)` | Walks to and opens an earned harvest chest. |
| [6674](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6674) | `fieldraid.fmtCal(n)` | Formats calories as K/M/B. |
| [6682](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6682) | `fieldraid.exitSpot(via)` | Exit prompt + position: River ferry (RiverExit) or Mill gate (GateExit), with fallbacks. |
| [6691](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6691) | `fieldraid.pickExit(rootPos)` | Nearer exit for manual Bank & Leave. |
| [6697](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6697) | `fieldraid.bank(now, rootPos)` | Leaves the run: walks to the chosen exit (ferry forward / gate back) and fires its prompt. |
| [6722](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6722) | `fieldraid.meadow(now, rootPos)` | Harvest meadow after the ferry: opens our gold chest, then Return to town. |
| [6784](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6784) | `fieldraid.startRun(now, rootPos)` | At the camp sign-up, starts a solo raid (`Solo`, 1). |
| [6833](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6833) | `fieldraid.setSprint(on, now)` | Throttled `SprintRequest` toggle while travelling in a raid. |
| [6840](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6840) | `fieldraid.travel(target, now)` | Sprint + path walk. |
| [6845](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6845) | `fieldraid.tick(now, rootPos)` | Field raid dispatcher: chest heal, blink/walk dodge, bite on the move, push deeper, sweep max field. |
| [6962](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6962) | `fieldraid.sweepBounds()` | Lateral bounds of the raid field (Planting, else FieldSoil). |
| [6977](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6977) | `fieldraid.sweep(now, rootPos)` | Deepest-field farming: lateral sprint passes, biting on the move. |
| [6280](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6280) | `fieldraid.spotClear(from, spot)` | Blink target check: ground below, no wall/fence in between. |
| [6290](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6290) | `fieldraid.jink(shooterPos)` | Sidesteps perpendicular to an archer/thrower just before release (aim locks on the forecast). |
| [6318](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L6318) | `fieldraid.blinkDodge()` | Instant forward-only step out of a telegraph landing within ~1.2 s. |
| [7055](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7055) | `fieldraid.smithRules()` | Requires SmithingRules + DayNightCycle. |
| [7065](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7065) | `fieldraid.smithStatus(text)` | Updates the Blacksmith Shift status paragraph. |
| [7077](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7077) | `fieldraid.smithEvent(msg)` | Handles SmithJob Status/Mark/Finished; fires perfect `SmithJobStrike`. |
| [7101](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7101) | `fieldraid.smithHead()` | Blacksmith NPC head when at work (BlacksmithSite.WorkingHead). |
| [7111](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7111) | `fieldraid.smithAnvilPos()` | Blacksmith anvil position (AnvilCollider or constant). |
| [7122](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7122) | `fieldraid.smithReach(pos, range, label)` | Gets within range: opt-in teleport, else walk when close. |
| [7140](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7140) | `fieldraid.smithReturn()` | Teleports back to where the shift started. |
| [7149](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7149) | `fieldraid.smithTick()` | Walk-by shift dialogue: Status → Accept → Hammer (anvil) → Turn in; never walks the cow. |
| [7246](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L7246) | `fieldraid.smithStart()` | Starts the tokened smith loop. |
| [17191](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L17191) | `fieldraid.setFlag(flag, on)` | Sets a Rayfield flag (debug handle). |
| [17195](file:///Users/jsph/cowhub/luascripts/cowhub.lua#L17195) | `fieldraid.setOption(label, on)` | Sets one Raid Options dropdown entry (debug handle). |

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

**Total Functions**: `54`

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [155](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L155) | `getChar()` | Returns current character, HumanoidRootPart, and Humanoid. |
| [162](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L162) | `setRootCFrame(cf, targetRoot)` | Teleports root part or model pivot safely. |
| [171](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L171) | `mq.fireRaid(...)` | Fires `FieldRaidRequest` remote safely. |
| [181](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L181) | `mq.loadMods()` | Lazy-requires `FieldRaidCombat` and `FieldRaidEnemies` shared modules. |
| [189](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L189) | `mq.isDone(idx)` | Checks whether challenge bit `idx` (1..3) is set in `challengesMask`. |
| [193](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L193) | `mq.c1Complete()` | Returns true when ripe wheat has been bitten in Fields 3, 4, and 5. |
| [197](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L197) | `mq.c2Complete()` | Returns true when 3 clean ripe bites in Field 8 have been recorded. |
| [201](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L201) | `mq.c3Complete()` | Returns true when Challenge 3 is saved in server Ledger bitmask. |
| [205](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L205) | `mq.activeGoal()` | Resolves next target challenge (1, 2, 3, or nil) based on `mq.mode` and progress. |
| [217](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L217) | `mq.resetRunTrackers()` | Clears per-run challenge, hazard, bell, and exit state. |
| [243](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L243) | `mq.setStatus(text)` | Updates `mq.status` and the compact UI status label. |
| [251](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L251) | `mq.refreshUI()` | Syncs UI buttons, challenge checkboxes, and current field/hearts display. |
| [295](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L295) | `mq.syncLedger()` | Reads the challenge mask from `GetSnapshot` → `Profile.FieldRaids.Challenges` (async). |
| [315](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L315) | `mq.bandZ(level)` | Computes nearZ and farZ world bounds for Field `level` using `FieldRaidLayout.Band`. |
| [326](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L326) | `mq.levelAtZ(z)` | Field level whose band contains a Z (bell → field). |
| [334](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L334) | `mq.sweepBounds()` | Returns clamped lateral X bounds across the planting field. |
| [345](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L345) | `mq.arena()` | Resolves the active `PrivateFieldRaids` or run geometry folder. |
| [363](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L363) | `mq.cellPoint(part, pos)` | Clamps `pos` onto `part`'s oriented bounding box for accurate reach checks. |
| [370](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L370) | `mq.mobAlive(part)` | Checks if a raid mob part still exists and has positive Health. |
| [374](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L374) | `mq.scan(now, force)` | Scans `NorthRiverRaidView` for live `RaidMob` and available `RaidFood` parts. |
| [396](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L396) | `mq.findOgre()` | Locates live `FieldOgre` model or boss position in Field 10. |
| [419](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L419) | `mq.findWheat(rootPos, now, ripeOnly, minZ, maxZ)` | Selects highest-priority wheat cell filtered by ripeness and Z band. |
| [451](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L451) | `mq.nearestMob(rootPos)` | Finds closest living raid mob to `rootPos`. |
| [463](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L463) | `mq.getInterval(node)` | Computes server-aligned chew cooldown interval plus adaptive margin. |
| [472](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L472) | `mq.ensureGraze()` | Sends `GrazeStart` once per active raid run. |
| [480](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L480) | `mq.face(root, pos)` | Rotates root horizontally toward target position `pos`. |
| [489](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L489) | `mq.sendChomp(nodeId, node, now, root)` | Fires `ChompRequest` with serial tracking and ripe/level metadata. |
| [528](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L528) | `mq.biteNearby(now, root, rootPos)` | Bites in-range ripe wheat, raid mobs, or regular wheat on the move. |
| [548](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L548) | `mq.addHazard(msg)` | Parses enemy telegraphs, tracks FieldOgre `HarvestStomp` for C3, and schedules blink-dodges. |
| [608](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L608) | `mq.dropHazards(id)` | Removes active hazards belonging to canceled or defeated enemy `id`. |
| [633](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L633) | `mq.danger(pos, serverNow, horizon)` | Evaluates `FieldRaidCombat.Contains` against active hazards at `pos`. |
| [657](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L657) | `mq.spotClear(char, from, spot)` | Raycasts wall/fence clearance and valid ground under candidate dodge `spot`. |
| [667](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L667) | `mq.allowedSpot(spot, rootPos, holdLevel)` | Enforces field X bounds and target Z-band clamping for dodge spots. |
| [681](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L681) | `mq.jumpSilk(humanoid, pos, serverNow)` | Jumps a SilkTripline web about to catch the cow (game hint: jump the silk). |
| [695](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L695) | `mq.blinkDodge(holdLevel)` | Micro-teleports out of imminent telegraph footprints using radial clearance scoring. |
| [732](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L732) | `mq.jink(shooterPos)` | Sidesteps perpendicular to an archer/thrower just before release, inside the held field. |
| [765](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L765) | `mq.dodgeStep(now, rootPos, humanoid, holdLevel)` | Combines blink-dodge and `Humanoid:MoveTo` evasion from active telegraphs. |
| [807](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L807) | `mq.setSprint(on, now)` | Toggles raid sprint via `SprintRequest` with rate limiting. |
| [814](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L814) | `mq.walkTo(target, now, humanoid, root)` | Pathfinding-assisted movement with stuck detection and perpendicular unstick nudges. |
| [892](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L892) | `mq.stopWalk()` | Clears active path and halts humanoid movement. |
| [901](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L901) | `mq.prompts(now)` | Caches `OpenHarvestChest`, `GateExit`, and `RiverExit` ProximityPrompts in arena. |
| [921](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L921) | `mq.promptPos(prompt)` | Resolves world position of a ProximityPrompt's parent part, attachment, or model. |
| [929](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L929) | `mq.firePrompt(prompt)` | Triggers a ProximityPrompt safely via `fireproximityprompt`. |
| [936](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L936) | `mq.tryChest(now, rootPos, humanoid, root)` | Walks to and opens nearby or healing harvest chests when hurt or adjacent. |
| [963](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L963) | `mq.exitSpot(via)` | Resolves `RiverExit` or `GateExit` prompt and world position fallback. |
| [972](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L972) | `mq.bank(now, rootPos, humanoid, root)` | Navigates to chosen raid exit and fires its prompt to bank run rewards. |
| [1000](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1000) | `mq.meadow(now, rootPos, humanoid)` | Collects owned Harvest Meadow gold chest then interacts with `HomePrompt`. |
| [1053](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1053) | `mq.startRun(now, rootPos, humanoid, root)` | Walks to raid camp sign-up and enters a Solo raid when outside. |
| [1096](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1096) | `mq.huntRipeInField(now, rootPos, humanoid, root, targetLevel, statusPrefix)` | Holds inside `targetLevel` and chases `RaidRipe` wheat or announced `Bell` patches. |
| [1206](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1206) | `mq.runChallenge3(now, rootPos, humanoid, root)` | Baits `FieldOgre` stomp in F10, confirms unhit dodge >16 studs, and exits via `RiverExit`. |
| [1260](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1260) | `mq.tick(now)` | Main 10Hz state machine orchestrating camp start, raid progression, dodge, and exits. |
| [1550](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1550) | `mq.buildUI()` | Builds compact draggable `CowMillQuestsUI` status and control panel. |
| [1690](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1690) | `mq.setRunning(on)` | Starts/stops automation and pauses conflicting `_G.CowHubFieldRaid.auto`. |
| [1713](file:///Users/jsph/cowhub/luascripts/mill_quests.lua#L1713) | `mq.destroy()` | Disconnects listeners, stops movement, removes UI, and clears `_G.CowMillQuests`. |

---

## Field Raid XP Autofarm (`field_raid_xp.lua`)

**Path**: [`luascripts/field_raid_xp.lua`](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua)

Standalone Field Raid Powerup XP autofarm (`Rush & Reset` and `Camp F10` modes) with Field 10 XP/sec target scoring, telegraph blink-dodging, and live XP/hr HUD.

| Line | Function Signature | Description |
| :--- | :--- | :--- |
| [184](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L184) | `getChar()` | Resolves character, HumanoidRootPart, and Humanoid safely. |
| [191](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L191) | `setRootCFrame(cf, targetRoot)` | Teleports root part or pivots model cleanly. |
| [200](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L200) | `xp.fireRaid(...)` | Fires `FieldRaidRequest` remote with auto-resolved reference. |
| [210](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L210) | `xp.loadMods()` | Lazy-requires `FieldRaidCombat`, `FieldRaidEnemies`, and `FieldRaidPowerups`. |
| [219](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L219) | `xp.setStatus(text)` | Updates `xp.status` and the compact UI status label. |
| [227](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L227) | `xp.formatRate()` | Formats active session XP/hour rate string. |
| [237](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L237) | `xp.refreshUI()` | Syncs UI buttons, field/XP readout, session rate, and equipped powerup levels. |
| [283](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L283) | `xp.layoutUI()` | Grows the wrapped powerups label to fit and shifts the stats, status and buttons below it. |
| [300](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L300) | `xp.syncPowerups()` | Reads `Profile.FieldRaids.Powerups` from `GetSnapshot` and updates baseline/session XP. |
| [329](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L329) | `xp.resetRunTrackers()` | Clears per-run XP estimates, F10 progress, hazards, and exit state. |
| [350](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L350) | `xp.addGain(amt)` | Adds estimated action XP and logs it against the F10 farm clock. |
| [358](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L358) | `xp.recentRate()` | XP/s over the last `RATE_WINDOW` seconds of active F10 farming; prunes old log entries. |
| [374](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L374) | `xp.marginalExit(now, rootPos)` | Marginal Rush exit: leave when recent F10 XP/s < whole-run XP/s incl. exit bonus + exit time. |
| [383](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L383) | `xp.bandZ(level)` | Computes nearZ and farZ world bounds for Field `level` using `FieldRaidLayout.Band`. |
| [394](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L394) | `xp.levelAtZ(z)` | Returns the field level whose band contains world `z`. |
| [402](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L402) | `xp.sweepBounds()` | Returns clamped lateral X bounds across the planting field. |
| [411](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L411) | `xp.arena()` | Resolves the active `PrivateFieldRaids` or run geometry folder. |
| [429](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L429) | `xp.cellPoint(part, pos)` | Clamps `pos` onto `part`'s oriented bounding box for accurate reach checks. |
| [436](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L436) | `xp.mobAlive(part)` | Checks if a raid mob part still exists and has positive Health. |
| [440](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L440) | `xp.speciesOf(part)` | Returns species/model name of a raid food or mob part. |
| [445](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L445) | `xp.isSecondaryFood(part)` | Identifies high-XP secondary foods (`GoldenApple`, `GoldMushroom`, etc.). |
| [452](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L452) | `xp.scan(now, force)` | Scans `NorthRiverRaidView` for live `RaidMob` and available `RaidFood` parts. |
| [477](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L477) | `xp.getInterval(node)` | Computes server-aligned chew cooldown interval plus adaptive margin. |
| [486](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L486) | `xp.ensureGraze()` | Sends `GrazeStart` once per active raid run. |
| [494](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L494) | `xp.face(root, pos)` | Rotates root horizontally toward target position `pos`. |
| [503](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L503) | `xp.sendChomp(nodeId, node, now, root)` | Fires `ChompRequest` with serial tracking and species/secondary metadata. |
| [555](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L555) | `xp.biteNearby(now, root, rootPos)` | Bites in-range secondary foods, highest XP/HP mobs, or wheat on the move. |
| [605](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L605) | `xp.addHazard(msg)` | Parses enemy telegraphs and schedules blink-dodges or projectile jinks. |
| [651](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L651) | `xp.dropHazards(id)` | Removes active hazards belonging to canceled or defeated enemy `id`. |
| [664](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L664) | `segDist(p, a, b)` | Computes flat XZ distance from point `p` to segment `a-b`. |
| [673](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L673) | `xp.danger(pos, serverNow, horizon)` | Evaluates `FieldRaidCombat.Contains` against active hazards at `pos`. |
| [695](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L695) | `xp.spotClear(char, from, spot)` | Raycasts wall/fence clearance and valid ground under candidate dodge `spot`. |
| [705](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L705) | `xp.allowedSpot(spot, rootPos, holdF10)` | Enforces field X bounds and Field 10 Z-band clamping for dodge spots. |
| [718](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L718) | `xp.jumpSilk(humanoid, pos, serverNow)` | Jumps a SilkTripline web about to catch the cow. |
| [732](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L732) | `xp.blinkDodge(holdF10)` | Micro-teleports out of imminent telegraph footprints using radial clearance scoring. |
| [768](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L768) | `xp.jink(shooterPos)` | Sidesteps perpendicular to an archer/thrower right before projectile release. |
| [799](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L799) | `xp.dodgeStep(now, rootPos, humanoid, holdF10)` | Combines blink-dodge and `Humanoid:MoveTo` evasion from active telegraphs. |
| [846](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L846) | `xp.setSprint(on, now)` | Toggles raid sprint via `SprintRequest` with rate limiting. |
| [853](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L853) | `xp.walkTo(target, now, humanoid, root)` | Pathfinding-assisted movement with stuck detection and perpendicular unstick nudges. |
| [926](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L926) | `xp.stopWalk()` | Clears active path and halts humanoid movement. |
| [935](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L935) | `xp.prompts(now)` | Caches `OpenHarvestChest`, `GateExit`, and `RiverExit` ProximityPrompts in arena. |
| [955](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L955) | `xp.promptPos(prompt)` | Resolves world position of a ProximityPrompt's parent part, attachment, or model. |
| [963](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L963) | `xp.firePrompt(prompt)` | Triggers a ProximityPrompt safely via `fireproximityprompt`. |
| [970](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L970) | `xp.tryChest(now, rootPos, humanoid, root)` | Walks to and opens healing harvest chests when hearts are low. |
| [999](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L999) | `xp.exitSpot(via)` | Resolves `RiverExit` or `GateExit` prompt and world position fallback. |
| [1008](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1008) | `xp.bank(now, rootPos, humanoid, root)` | Navigates to chosen raid exit and fires its prompt to bank run XP/rewards. |
| [1037](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1037) | `xp.meadow(now, rootPos, humanoid)` | Collects owned Harvest Meadow gold chest then interacts with `HomePrompt`. |
| [1090](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1090) | `xp.startRun(now, rootPos, humanoid, root)` | Walks to raid camp sign-up and enters a Solo raid when outside. |
| [1142](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1142) | `xp.pickF10Target(rootPos, now, nearZ, farZ, allowFarmers)` | Scores Field 10 secondary foods, enemies, and wheat by estimated XP/sec. |
| [1217](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1217) | `xp.ogreBlocking(ogrePart)` | True while the Field Ogre is alive (in view or per `BossHealth`) and still losing HP; gives up after `OGRE_GIVEUP` s. |
| [1227](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1227) | `xp.farmF10(now, rootPos, humanoid, root)` | Executes `Rush & Reset` clear-and-exit or continuous `Camp F10` farming inside Field 10. |
| [1320](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1320) | `xp.tick(now)` | Main 10Hz state machine orchestrating camp start, blitz to F10, farming, dodging, and exits. |
| [1538](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1538) | `xp.buildUI()` | Builds compact draggable `CowFieldRaidXPUI` HUD and controls. |
| [1694](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1694) | `xp.setRunning(on)` | Starts/stops automation and pauses conflicting `_G.CowHubFieldRaid.auto` and `_G.CowMillQuests`. |
| [1718](file:///Users/jsph/cowhub/luascripts/field_raid_xp.lua#L1718) | `xp.destroy()` | Disconnects listeners, stops movement, removes UI, and clears `_G.CowFieldRaidXP`. |

---
