//tmp var lists for cleaning sake
obj
	New()
		..()
		obj_list += src
	Del()
		obj_list -= src
		..()

obj
	items
		New()
			..()
			item_list += src
		Del()
			if(amount>1 && loc)
				amount--
				suffix = "[amount]"
				return
			item_list -= src
			..()
	attack
		New()
			..()
			attack_list += src
		Del()
			attack_list -= src
			..()
//turf new() in NewTurfs.dm

datum/proc/deleteMe()

	if(istype(src,/atom)) src:loc = null //let garbage collection take it. (may not work in some cases)
	//removing all world references
	if(istype(src,/obj))
		obj_list -= src
		if(istype(src,/obj/items)) item_list -= src
		if(istype(src,/obj/attack)) attack_list -= src
		if(istype(src,/obj/Planets)) planet_list -= src
		src:SaveItem = 0
	if(istype(src,/mob))
		mob_list -= src
		NPC_list -= src
	//remove all references
var/legend_poll=0
var/legend_override=0

proc/Cleaner()
	set waitfor=0
	set background = 1
	world << "Maid-kun is cleaning up the map!"
	if(!firstcleaner)
		for(var/obj/attack/A in attack_list) A.deleteMe()
		for(var/obj/Crater/D in obj_list) D.deleteMe()
		for(var/obj/bodyparts/H in obj_list) H.deleteMe()
		for(var/obj/O in obj_list) if(O.icon_state=="chunk1") O.deleteMe() //This refers to the Majin dummy objects, a just-in-case deletion.
		SaveWorld()
		world.Repop()
		if(prob(50))
			if(WipeRanks)
				WipeRank()
				AutoRank()
				//for(var/mob/M in player_list)
				//	M.GettingRank=0
		if(autorevivetimer==18000)
			world.AutoRevive()
		player_list.Cut()
		for(var/mob/C in mob_list)
			if(C.client) player_list |= C
			if(C.z == 30)
				if(!C.client)
					C.deleteMe()
		if(!legend_overrider) legend_poll = 0
		if(prob(5*legend_poll))
			var/check=0
			for(var/mob/M in player_list)
				if(M.signature in legend_sig)
					legend_poll--
					check=1
					break
			if(!check && legend_poll > 5)
				legend_override=1
		legend_poll++
		spawn(18000) Cleaner()
		return
	if(firstcleaner)
		if(WipeRanks)
			CHECK_TICK
			WipeRank()
		firstcleaner=0
		CHECK_TICK
		spawn(18000) Cleaner()
		return

proc/CleanTurfOverlays()
	set waitfor=0
	for(var/turf/T in turf_list)
		sleep(1)
		CHECK_TICK
		if(T.overlays)
			T.overlays-=T.overlays //this needs to be redone eventually, but this is essentially there to wipe annoying transformation artifacts.
			//also, uh, this is really slow.
			//like freezith gameith for fucking 5 whole entire minutes dwarfing the SSJ3 transformation
		world << "Turf overlays cleared."