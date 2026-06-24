proc/Dungeon_Timer(t)
	set waitfor= 0
	t += 1
	dungeon_timer_check()
	if(add_rnd_dungeon())
		world << "The previous dungeon has collapsed! A new dungeon has formed..."
	else world << "ERROR: Dungeon Failed to load!"
	if(t >= 4) return
	sleep(36000)
	spawn Dungeon_Timer(t)


proc/dungeon_timer_check()
	for(var/obj/dungeon/D in dun_list)
		D.timer -= 1
		if(D.timer == 0 && !D.semi_perm)
			D.dungeon_delete()

proc/add_rnd_dungeon()
	var/list/valid_dungeons = check_valid_dungeons()
	if(isnull(valid_dungeons)||!valid_dungeons.len) return FALSE
	var/i = rand(1,valid_dungeons.len)
	var/list/allowed_areas = valid_dungeons[i]["allowed_areas"]
	var/list/rng_dng_areas = active_o_play_areas
	var/area/target_area = null
	if(allowed_areas.len)
		rng_dng_areas = allowed_areas
	target_area = pick_planet_to_Area(rng_dng_areas)
	if(target_area) add_Dungeon(pickTurf(target_area,2),valid_dungeons[i]["dungeon_file_name"])
	return TRUE

proc/pick_planet_to_Area(list/rndm_area_list)
	var/i = pick(rndm_area_list)
	for(var/area/A in area_outside_list)
		if(i == A.Planet)
			return A

proc/turf_to_coordinates(turf/t)
	if(!isturf(t)) return FALSE
	var/list/coords[3]
	coords[1] = t.x
	coords[2] = t.y
	coords[3] = t.z
	return coords


turf //so these are legacy tiles that are only here to not break dungeons.
	TileWhite icon='White.dmi'
	Tile26
		icon='turfs.dmi'
		icon_state="tile9"
	Stairs4
		icon='Turfs 1.dmi'
		icon_state="stairs1"
	Stairs5
		icon='Turfs 1.dmi'
		icon_state="earthstairs"
	Stairs3
		icon='Turfs 1.dmi'
		icon_state="stairs2"
	Stairs2
		icon='Turfs 12.dmi'
	Stairs1
		icon='Turfs 96.dmi'
		icon_state="steps"
	Plant17
		icon='Turfs 1.dmi'
		icon_state="bushes"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant11
		icon='Plants.dmi'
		icon_state="plant2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant10
		icon='Plants.dmi'
		icon_state="plant3"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant16
		icon='roomobj.dmi'
		icon_state="flowers"
	Plant15
		icon='roomobj.dmi'
		icon_state="flowers2"
	Plant2
		icon='Turf3.dmi'
		icon_state="plant"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant3
		icon='turfs.dmi'
		icon_state="stump"
	Plant4
		icon='Turf2.dmi'
		icon_state="plant2"
	Plant5
		icon='Turf2.dmi'
		icon_state="plant3"
	Plant13
		icon='turfs.dmi'
		icon_state="bush"
	Plant14
		icon='Turfs 1.dmi'
		icon_state="frozentree"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant18
		icon='Trees.dmi'
		icon_state="Dead Tree1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant6
		icon='Turfs1.dmi'
		icon_state="1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant20
		icon='Turfs1.dmi'
		icon_state="2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant19
		icon='Turfs1.dmi'
		icon_state="3"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant7
		icon='Trees.dmi'
		icon_state="Tree1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant8
		icon='Turfs 1.dmi'
		icon_state="smalltree"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Plant9
		icon='Turfs 2.dmi'
		icon_state="treeb"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1