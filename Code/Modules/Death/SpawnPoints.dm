mob/Admin2/verb/Create_Spawnpoint()
	set category = "Admin"
	if(alert(usr,"Create spawnpoint?","","Yes","No")=="No")
		return
	var/obj/SpawnPoint/A = new
	A.spawnRace = input(usr,"Which race? You need to know the exact race 'name'! (You can find this in Edit-> then look a player's Race var.)") as text
	A.loc = locate(usr.x,usr.y,usr.z)
	A.SaveItem = 1
	return

mob/Admin2/verb/Delete_Spawnpoint()
	set category = "Admin"
	var/list/nlA = list()
	for(var/obj/SpawnPoint/S in obj_list)
		nlA += S
	nlA += "Cancel"
	var/obj/SpawnPoint/A = input(usr,"Select the spawnpoint") in nlA
	if(isobj(A))
		if(alert(usr,"Delete spawnpoint? It won't technically 'delete' in order to save, but it will render it invisible. (You can manually delete custom spawnpoints anyway.)","","Yes","No")=="No")
			return
		else
			A.Disabled = 1
			A.invisibility = 101

mob/Admin3/verb/Toggle_Spawnpoints()
	set category = "Admin"
	if(alert(usr,"This will toggle spawning at spawnpoints. This will cause would-be spawnees to be randomly placed around the world. If a race doesn't have a homeworld, they'll still spawn at the Large Spacestation spawn anyways.","","Toggle On","Toggle Off")=="Toggle On")
		GotoSpawnpoint = 1
		world << "Spawnpoints on."
		return
	else
		GotoSpawnpoint = 0
		world << "Spawnpoints off."
		return

mob/Admin3/verb/Return_Mob_To_Spawn(var/mob/M in view())
	set category = "Admin"
	M:Locate()

obj/SpawnPoint
	SaveItem = 0
	IsntAItem=1
	canGrab = 0
	IsntAItem=1
	icon = 'Spirit Energy.dmi'
	name = "Spawnpoint"
	var/spawnRace = "Human"//race that spawns here.
	var/spawnPlanet = "Earth" //planet that the race spawns in.
	var/Disabled = 0
	New()
		..()
		spawn(150) if(Disabled) invisibility = 101
	//This is specified, because if Spirit Dolls doesn't have a specified 'spawnpoint', but they DO have a specified planet, they'll use this spawnpoint.
	//Spawnpoints are just 'markers'. If you don't have a spawnpoint, you might spawn
	// either in a random place on your homeworld, or on the Spacestation if the homeworld doesn't exist.
	//Admins can 'add' races to planets by adding spawnpoints.
	// Order of checking is if(Spawnpoints ON), for(obj/SpawnPoint/A) if(A.spawnRaces = Race) if(spawnPlanet = SpawnPlanet) ... etc.

mob/var/spawnPlanet = ""
//Planet goto code

mob/proc/GotoPlanet(planet as text,spawnType = 0 as num)
	var/obj/SpawnPoint/TargetSpawnpoint = null
	for(var/test in args)
		if(istext(planet)&&isnum(spawnType))
			break
		if(istext(test))
			planet = test
			continue
		if(isnum(test))
			spawnType = test
			continue
	redoplanetfind
	if(spawnType==1&&GotoSpawnpoint&&!isnull(planet))
		var/list/spawnpoints = list()
		for(var/obj/SpawnPoint/A in obj_list)
			if(A.spawnPlanet == planet&&!A.Disabled)
				spawnpoints+=A
				if(A.spawnRace == Race)
					TargetSpawnpoint = A
					break
				if(A.spawnRace == "")
					TargetSpawnpoint = A
					break
			else continue
		if(!TargetSpawnpoint) //if there is no spawnpoint on the planet, find the first available one.
			for(var/obj/SpawnPoint/A in obj_list)
				if(A.spawnPlanet == planet&&!A.Disabled)
					TargetSpawnpoint = A
					break
			if(!TargetSpawnpoint)
				spawnType = 0
				goto redoplanetfind
		if(TargetSpawnpoint)
			src.Move(locate(TargetSpawnpoint.x,TargetSpawnpoint.y,TargetSpawnpoint.z))
			return TRUE
		else return FALSE //no spawnpoint? failed move.
	else if(spawnType==1&&!isnull(planet))
		var/area/targetArea
		var/list/areacheck = area_outside_list
		for(var/area/B in area_list)
			if(istype(B,/area/afterlifeareas))
				areacheck+=B
		for(var/area/A in areacheck)
			if(A.Planet == planet&&A.PlayersCanSpawn==1)
				targetArea = A
				break
		if(targetArea)
			var/turf/temploc = pickTurf(targetArea,1)
			src.loc = (locate(temploc.x,temploc.y,temploc.z))
		else return FALSE //noarea? failed move.
	else if(spawnType==0&&!isnull(planet))
		var/area/targetArea
		var/list/areacheck = area_outside_list
		for(var/area/B in area_list)
			if(istype(B,/area/afterlifeareas))
				areacheck+=B
		for(var/area/A in areacheck)
			if(A.Planet == planet)
				targetArea = A
				break
		if(targetArea)
			var/turf/temploc = pickTurf(targetArea,1)
			src.loc = (locate(temploc.x,temploc.y,temploc.z))
		else return FALSE //noarea? failed move.
	else
		return FALSE //treat this as a failed teleport.


mob/proc/Locate()
	client.view="[screenx]x[screeny]"
	if(!isBorn)
		isBorn = 1
		if(Parent!="")
			for(var/mob/M)
				if(Parent=="[M]" || (M.Egg && Parent =="[M.Parent]"))
					loc=locate(M.x-1,M.y,M.z)
					Age=1
					//Body=1 don't need to set body, that's done dynamically by Stats.dm
					SAge=1
					spawnPlanet = M.spawnPlanet
					view()<<"[src] just popped out of [M]!"
					src << "You were born from [M]!"
					M << "[src] was born from you!"
					if(M.Egg)
						del(M)
					else M.Pregnant=0
					return
		else switch(Race)
			if("Bio-Android")
				if(bio_creator_list.len)
					var/list/born_list = bio_creator_list[bio_creator_list.len]
					loc=locate(born_list[1],born_list[2],born_list[3])
					SAge=1
					return

			if("Android")
				if(android_creator_list.len)
					var/list/born_list = android_creator_list[android_creator_list.len]
					loc=locate(born_list[1],born_list[2],born_list[3])
					SAge=1
					return
			if("Spirit Doll")
				if(spirit_creator_list.len)
					var/list/born_list = spirit_creator_list[spirit_creator_list.len]
					loc=locate(born_list[1],born_list[2],born_list[3])
					SAge=1
					return

	if(dead) //dead characters (e.g. logging in while dead) go to the death checkpoint, NOT their homeworld
		if(HasSoul)
			loc=locate(187,104,6)
		else
			loc=locate(187,104,7)
	else if(spawnPlanet)
		GotoPlanet(spawnPlanet,1)
	else
		spawnPlanet = pick("Earth","Namek","Vegeta")
		Locate()