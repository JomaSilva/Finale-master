// ============================================================================
// PLANET POPULATION  --  ambient, race-appropriate citizens per planet.
//   Vegeta : Saiyans (Normal/Low-Class commoners) + an Elite King (~20k BP) & Prince (~16k BP).
//   Earth  : Humans (gi or mundane clothes).
//   Namek  : Namekians (always bald, namek-themed clothes).
// They are created through the SAME race/class pipeline a player uses (StatRace +
// race_genome_post_init), so they have real genome/limb/stat data.
// PEACEFUL but TRAINABLE: they do NOT aggro on sight (AIAlwaysActive=0); they fight
// back with the full combat AI when attacked. Slaying the King (as a Saiyan) grants
// the killer the real King_of_Vegeta rank.
// Built at world boot (idempotent) + topped-up by a maintenance loop (respawn).
// NPCs are NOT saved in the .dmm (rebuilt each boot); the throne itself persists
// through the existing Save_Rank/Load_Rank (King_of_Vegeta).
// ============================================================================

// ---- tunables: how many of each per planet ----
#define POP_VEGETA_COMMON 15
#define POP_EARTH_HUMANS  15
#define POP_NAMEK_NAMEKS  12

var/list/citizen_list = list()  // all living population NPCs
var/planet_pop_built = 0        // idempotent boot guard

// ---------------------------------------------------------------------------
// The citizen mob
// ---------------------------------------------------------------------------
mob/npc/Citizen
	monster = 1           // a fightable being -> base foundTarget ENGAGES (chaseState) when provoked
	AIAlwaysActive = 0    // ...but never aggros on sight (OnStep aggro needs AIAlwaysActive) -> peaceful until hit
	hasAI = 1
	mindswappable = 0
	HasSoul = 1
	attackable = 1
	dropsCorpse = 1
	itemrarity = 0
	var
		pop_planet = ""        // "Vegeta" / "Earth" / "Namek"
		pop_role = "commoner"  // "commoner" / "prince" / "king"
		pop_seed_bp = 1000     // fixed BP seed (NPCTicker keeps this; no AverageBP scaling)
		idle_wandering = 1     // slow ambient wandering when idle
		tmp/provoke_cd = 0

	New()
		..()
		citizen_list |= src
		spawn idle_wander_loop()

	Del()
		citizen_list -= src
		..()

	// fixed BP: keep the seeded value instead of the AverageBP scaling the base NPCTicker does
	NPCTicker()
		set waitfor = 0
		set background = 1
		AIRunning = 1
		if(pop_seed_bp) BP = pop_seed_bp
		NPCAscension()

	// fight back when attacked (peaceful-but-trainable)
	DamageLimb(var/damage as num, var/theselection, var/enemymurderToggle as num, var/penetration as num)
		. = ..()
		if(damage > 0 && !target && !KO && !dead && world.time >= provoke_cd)
			provoke_cd = world.time + 5
			spawn(2) provoke()

	proc/provoke()
		if(target || KO || dead || !hasAI || client) return
		var/mob/atk = lastDamager
		if(!(atk && atk.client))  // blasts don't set lastDamager -> fall back to a nearby in-combat player
			for(var/mob/P in view(6,src))
				if(P.client && (P.IsInFight || P.combatTag) && !P.dead)
					atk = P
					break
		if(atk && atk.client && atk != src && !atk.dead)
			foundTarget(atk)

	// cheap idle wandering so the planet feels alive (prob-gated, pauses during combat)
	proc/idle_wander_loop()
		set waitfor = 0
		set background = 1
		while(src && idle_wandering)
			sleep(rand(45,95))
			if(!src || AIRunning || KO || dead || target) continue
			if(prob(35)) step_rand(src)

	// -----------------------------------------------------------------------
	// The King of Vegeta: slaying him (as a Saiyan) makes the killer the new King.
	// -----------------------------------------------------------------------
	King
		pop_role = "king"
		var/tmp/throne_granted = 0
		mobDeath()
			grant_throne()
			..()
		proc/grant_throne()
			if(throne_granted) return
			throne_granted = 1
			var/mob/killer = lastDamager
			if(!(killer && killer.client))  // ki kill: lastDamager unset -> nearest in-combat player
				for(var/mob/P in view(8,src))
					if(P.client && (P.IsInFight || P.combatTag) && !P.dead)
						killer = P
						break
			if(killer && killer.client && !killer.dead && (killer.Race == "Saiyan" || killer.Parent_Race == "Saiyan"))
				King_of_Vegeta = killer.key  // mirror the existing throne-grant in Murder.dm/killer_stuff
				killer.Rank_Verb_Assign()
				Save_Rank()  // persist the new monarch immediately
				to_chat(killer, "<font color=yellow><b>By slaying the King of Vegeta, you have claimed the throne! You are the new King of Vegeta!</b></font>")
				view(8) << output("<font color=yellow><b>[killer] has slain the King of Vegeta and claimed the throne!</b></font>","Chatpane.Chat")
				chatcast(view(8), "[killer] has slain the King of Vegeta and claimed the throne!", "combat")
			else
				view(8) << output("<font color=red><b>The King of Vegeta has fallen!</b></font>","Chatpane.Chat")

// ---------------------------------------------------------------------------
// Appearance helpers (clientless: operate on the mob, never usr)
// ---------------------------------------------------------------------------
// wear an existing clothes datum type (Gi, Saiyan gloves/shoes, cape, namek jacket...)
proc/npc_wear_simple(mob/M, clothtype)
	if(!M || !clothtype) return
	var/obj/items/clothes/C = new clothtype
	npc_apply_clothes_overlay(M, C)

// wear a generic battle-armor overlay from a raw .dmi (optionally random-tinted)
proc/npc_wear_armor_icon(mob/M, armoricon, randomize_color)
	if(!M || !armoricon) return
	var/obj/items/clothes/C = new
	C.icon = armoricon
	if(randomize_color) C.icon += rgb(rand(0,255), rand(0,255), rand(0,255))
	C.name = "Battle Armor"
	npc_apply_clothes_overlay(M, C)

// shared overlay-equip path -- same calls the player Equip() verb uses, but on M instead of usr
proc/npc_apply_clothes_overlay(mob/M, obj/items/clothes/C)
	if(!M || !C) return
	C.equipped = 1
	C.suffix = "*Equipped*"
	M.contents += C
	M.updateOverlaycID(/obj/overlay/clothes/clothes_handler, C.icon, null, null, null, "[C.clothid]")
	M.overlayStats(/obj/overlay/clothes/clothes_handler, "[C.clothid]", C.plane, C.pixel_x, C.pixel_y)

// assign a hairstyle (or make bald). Mirrors the player path: set vars -> selecthair -> Add/Remove.
proc/npc_apply_hair(mob/M, style, r, g, b)
	if(!M) return
	if(!style || style == "Bald")
		M.hair = "Bald"
		M.selecthair()
		M.RemoveHair()
		return
	M.hairred = r
	M.hairgreen = g
	M.hairblue = b
	M.hair = style
	M.selecthair()
	M.AddHair()

// a valid, walkable turf on a planet, using the same SpawnPoints players use (scattered a bit)
proc/planet_spawn_turf(planet)
	var/list/sps = list()
	for(var/obj/SpawnPoint/A in obj_list)
		if(A.spawnPlanet == planet && !A.Disabled) sps += A
	if(sps.len)
		var/obj/SpawnPoint/A = pick(sps)
		for(var/tries = 1 to 25)
			var/turf/T2 = locate(A.x + rand(-10,10), A.y + rand(-10,10), A.z)
			if(T2 && !T2.density) return T2
		return locate(A.x, A.y, A.z)
	// fallback: the generic landing region on the planet's z
	var/cz = (planet == "Earth") ? 1 : (planet == "Namek") ? 2 : 3
	for(var/tries = 1 to 25)
		var/turf/T3 = locate(rand(230,270), rand(230,270), cz)
		if(T3 && !T3.density) return T3
	return locate(250, 250, cz)

// ---------------------------------------------------------------------------
// Core factory: run the player race/class pipeline on a clientless NPC
// ---------------------------------------------------------------------------
// pick a race/gender-appropriate body icon directly (returnIcons() has no "Human" case;
// the human bodies live in body_custom's own branch, so we mirror that choice here).
proc/npc_pick_body(race, mgender)
	if(race == "Namekian")  // Namekians are sexless (always male); body is any icon from the Namekians folder
		return pick('Albino Namek.dmi','Namek - Shadow.dmi','Namek 2.dmi','Namek Adult.dmi','Namek Young.dmi','Namek.dmi','NamekOld - Guru Style.dmi','NamekOld.dmi')
	if(mgender == "female") return pick('NewPaleFemale.dmi','NewTanFemale.dmi','NewBlackFemale.dmi')
	return pick('NewPaleMale.dmi','NewTanMale.dmi','NewBlackMale.dmi')

proc/init_citizen(turf/T, mobtype, race, class, planet, bp, mgender)
	if(!T) return null
	var/mob/npc/Citizen/M = new mobtype(T)
	if(!istype(M)) return null
	M.gender = mgender
	M.pgender = mgender
	M.Race = race
	M.Parent_Race = race
	M.Class = class            // pre-set (non-"None") so the stat procs skip the input() class roll
	M.spawnPlanet = planet
	M.pop_planet = planet
	if(race == "Saiyan") M.SaiyanLineage = "Saiyan"  // else statsaiyan input() hangs a clientless boot
	M.StatRace(race, 1)        // build the genome + apply the class
	M.race_genome_post_init()  // finalize_Race -> build_stats -> apply_stats
	// body icon (bypass the client body-picker window)
	M.icon = npc_pick_body(race, mgender)
	M.oicon = M.icon
	// fixed battle power
	M.pop_seed_bp = bp
	M.BP = bp
	M.powerlevel()
	return M

// hairstyle pools (verified names from selecthair)
var/list/saiyan_hair_m = list("Goku","Vegeta","Raditz","Spike","Spiked2","Bushy","Bedhead","Mohawk","Broly","Vegito","Super","Teen Gohan","Cell Gohan","GT Vegeta","GT Trunks","Goten","S17")
var/list/saiyan_hair_f = list("Caulifla","Kale","FemBroly","Female Long","Female Ponytail","Side-tail","Ponytail")
var/list/human_hair_m  = list("Yamcha","Messy","Ponytail","Wavy","Shaggy","Stylish","Afro","Cloud","Bangless","Anime","Ren","Headband","Roxas","Toushiro","Hitsugaya","Kidd")
var/list/human_hair_f  = list("Female Long","Female Long 2","Female Ponytail","Lyndis","Raphtalia","Chie","Muse","Side-tail")

// ---------------------------------------------------------------------------
// Per-role builders
// ---------------------------------------------------------------------------
proc/make_saiyan_commoner(turf/T)
	var/g = pick("male","male","male","female")
	var/class = pick("Normal","Normal","Low-Class")
	var/bp = (class == "Normal") ? rand(2000,5000) : rand(800,2500)
	var/mob/npc/Citizen/M = init_citizen(T, /mob/npc/Citizen, "Saiyan", class, "Vegeta", bp, g)
	if(!M) return
	M.name = pick("Saiyan Warrior","Saiyan Soldier","Saiyan Fighter","Saiyan")
	npc_apply_hair(M, pick(g == "female" ? saiyan_hair_f : saiyan_hair_m), 0, 0, 0)  // canonical black Saiyan hair
	// common Saiyan battle armor (Armor 8 gets a random color)
	var/armor = pick('Armor 8.dmi','Armor Bardock.dmi','Nappa Armor.dmi','RaditzArmorTobiUchiha.dmi')
	npc_wear_armor_icon(M, armor, armor == 'Armor 8.dmi')
	return M

proc/make_saiyan_elite(turf/T, role, bp, cape)
	var/g = "male"
	var/mob/npc/Citizen/M = init_citizen(T, (role == "king") ? /mob/npc/Citizen/King : /mob/npc/Citizen, "Saiyan", "Elite", "Vegeta", bp, g)
	if(!M) return
	M.pop_role = role
	M.name = (role == "king") ? "King Vegeta" : "Prince Vegeta"
	npc_apply_hair(M, (role == "king") ? "Vegeta" : "Vegeta Junior", 0, 0, 0)
	// elite armor + saiyan gloves & shoes
	npc_wear_armor_icon(M, pick('Armor_Elite.dmi','Clothes_VegetaSaiyanSagaArmor.dmi'), 0)
	npc_wear_simple(M, /obj/items/clothes/SaiyanGloves)
	npc_wear_simple(M, /obj/items/clothes/SaiyanShoes)
	if(cape) npc_wear_simple(M, /obj/items/clothes/Vegetacape)
	return M

proc/make_human(turf/T)
	var/g = pick("male","male","female")
	var/class = pick("Normal","Normal","Normal","Peak Human")
	var/bp = (class == "Peak Human") ? rand(1500,3500) : rand(500,2500)
	var/mob/npc/Citizen/M = init_citizen(T, /mob/npc/Citizen, "Human", class, "Earth", bp, g)
	if(!M) return
	M.name = pick("Martial Artist","Villager","Fighter","Townsperson")
	npc_apply_hair(M, pick(g == "female" ? human_hair_f : human_hair_m), rand(0,255), rand(0,255), rand(0,255))
	// gi or mundane clothes
	if(prob(50))
		if(g == "female") npc_wear_simple(M, /obj/items/clothes/Gifemale)
		else
			npc_wear_simple(M, /obj/items/clothes/Gi_Top)
			npc_wear_simple(M, /obj/items/clothes/Gi_Bottom)
	else
		npc_wear_simple(M, pick(/obj/items/clothes/TankTop, /obj/items/clothes/ShortSleeveShirt, /obj/items/clothes/LongSleeveShirt))
	return M

proc/make_namekian(turf/T)
	var/class = pick("Warrior clan","Warrior clan","Dragon clan","Demon clan")
	var/bp = rand(1500,4000)
	var/mob/npc/Citizen/M = init_citizen(T, /mob/npc/Citizen, "Namekian", class, "Namek", bp, "male")
	if(!M) return
	M.name = pick("Namekian Warrior","Namekian","Dragon Clansman")
	npc_apply_hair(M, "Bald", 0, 0, 0)  // Namekians are always bald
	// namek-themed garb
	if(prob(60)) npc_wear_simple(M, /obj/items/clothes/Namekjacket)
	if(prob(50)) npc_wear_simple(M, /obj/items/clothes/NamekianScarf)
	return M

// ---------------------------------------------------------------------------
// Population control: initial build + top-up (respawn) maintenance
// ---------------------------------------------------------------------------
proc/count_citizens(planet, role)
	var/n = 0
	for(var/mob/npc/Citizen/C in citizen_list)
		if(!C || C.dead) continue
		if(C.pop_planet == planet && (!role || C.pop_role == role)) n++
	return n

proc/populate_vegeta()
	var/have = count_citizens("Vegeta", "commoner")
	for(var/i = have + 1 to POP_VEGETA_COMMON)
		make_saiyan_commoner(planet_spawn_turf("Vegeta"))
		sleep(1)
	if(count_citizens("Vegeta", "prince") < 1)
		make_saiyan_elite(planet_spawn_turf("Vegeta"), "prince", rand(14000,18000), 0)
	// King only while the throne is vacant (no player King). Throne state persists via Save/Load_Rank.
	if(!King_of_Vegeta && count_citizens("Vegeta", "king") < 1)
		make_saiyan_elite(planet_spawn_turf("Vegeta"), "king", rand(18000,22000), 1)

proc/populate_earth()
	var/have = count_citizens("Earth", "commoner")
	for(var/i = have + 1 to POP_EARTH_HUMANS)
		make_human(planet_spawn_turf("Earth"))
		sleep(1)

proc/populate_namek()
	var/have = count_citizens("Namek", "commoner")
	for(var/i = have + 1 to POP_NAMEK_NAMEKS)
		make_namekian(planet_spawn_turf("Namek"))
		sleep(1)

proc/Populate_All_Planets()
	populate_vegeta()
	populate_earth()
	populate_namek()

proc/Population_Maintenance_Loop()
	set waitfor = 0
	set background = 1
	while(1)
		sleep(3000)  // every ~5 min: top each planet back up to target (respawn the fallen)
		Populate_All_Planets()

proc/Build_Planet_Population()
	set waitfor = 0
	if(planet_pop_built) return
	planet_pop_built = 1
	while(worldloading) sleep(1)  // mob/npc/New() waits on worldloading too; don't race it
	Populate_All_Planets()
	Population_Maintenance_Loop()

