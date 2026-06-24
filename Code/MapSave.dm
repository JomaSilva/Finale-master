mob/Admin3/verb/MassKO()
	set category="Admin"
	for(var/mob/A) if(A.client) spawn A.KO()
mob/Admin2/verb/ToggleMapSave()
	set category="Admin"
	if(!mapenabled)
		usr<<"On"
		mapenabled=1
	else
		usr<<"Off"
		mapenabled=0
var/maploadcomplete=0
proc
	MapSave()
		if(mapenabled)
			var/amount=0
			fdel("MapSave")
			var/savefile/F=new("MapSave")
			var/list/L=new/list
			L.Add(turfsave)
			amount+=turfsave.len
			F<<L
			world<<"Map Saved ([amount])"
	MapLoad()
		var/amount =0 
		if(fexists("MapSave"))
			var/savefile/F=new("MapSave")
			var/list/L=new/list
			F>>L
			amount = L.len
		LoadPlanets()
		maploadcomplete=1
		world<<"<font size=1>Map Loaded. ([amount])"

	BMapSave()
		if(mapenabled)
			var/amount=0
			fdel("MapSaveBck")
			var/savefile/F=new("MapSaveBck")
			var/list/L=new/list
			L.Add(turfsave)
			amount+=turfsave.len
			F<<L
			world<<"Backup Map Saved ([amount])"

	BMapLoad()
		maploadcomplete=0
		if(fexists("MapSaveBck"))
			var/savefile/F=new("MapSaveBck")
			var/list/L=new/list
			F>>L
		LoadPlanets()
		maploadcomplete=1
		world<<"<font size=1>Backup Map Loaded."

	AreaSave()
		if(mapenabled)
			fdel("AreaSave")
			var/savefile/F=new("AreaSave")
			var/list/L=new/list
			for(var/area/A in area_list)
				var/datum/areaLoadDatum/lA = new
				lA.areaType = A.type
				lA.HasMoon = A.HasMoon
				lA.IsHellstar = A.IsHellstar
				lA.daylightcycle = A.daylightcycle
				lA.mooncycle = A.mooncycle
				lA.planet_dying = A.planet_dying
				lA.currentWeather = A.currentWeather
				L += lA
			F<<L
			world<<"Areas Saved"
	AreaLoad()
		if(fexists("AreaSave"))
			var/savefile/F=new("AreaSave")
			var/list/L=new/list
			F>>L
			var/numloadlist = 0
			var/actualloadlist = 0
			for(var/datum/areaLoadDatum/lA in L)
				numloadlist += 1
				for(var/area/A in area_list)
					if(A.type == lA.areaType) //theres only one area of each type in the game
						actualloadlist += 1
						A.HasMoon = lA.HasMoon
						A.IsHellstar = lA.IsHellstar
						A.daylightcycle = lA.daylightcycle
						A.mooncycle = lA.mooncycle
						A.planet_dying = lA.planet_dying
						A.currentWeather = lA.currentWeather
					else continue
			world<<"Areas Loaded. [numloadlist] areas in memory, [actualloadlist] actually loaded."

datum/areaLoadDatum
	var
		areaType
		HasMoon=1
		IsHellstar=0
		daylightcycle=0
		mooncycle = 0
		planet_dying=0
		currentWeather = ""

proc/SaveItems()
	var/foundobjects=0
	fdel("ItemSave")
	var/savefile/F=new("ItemSave")
	var/list/L=new/list
	for(var/obj/A)
		if(A.SaveItem&&A.x>=1&&!istype(A,/obj/Creatables)&&!A.NotSavable&&A.z<=39)
			foundobjects+=1
			A.saved_x=A.x
			A.saved_y=A.y
			A.saved_z=A.z
			L.Add(A)
	F["SavedItems"]<<L
	world<<"<font size=1>Items saved ([foundobjects] items)"
proc/LoadItems()
	var/amount=0
	if(fexists("ItemSave"))
		var/savefile/F=new("ItemSave")
		var/list/L=new/list
		F["SavedItems"]>>L
		spawn
			for(var/obj/A in L)
				amount+=1
				A.loc=locate(A.saved_x,A.saved_y,A.saved_z)
				if(A.type == /obj/Core_Computer)
					var/obj/Core_Computer/nACC = A
					if(!ghetto_star_exist) del(nACC)
					if(ghetto_star_own)
						nACC.controller = ghetto_star_own
			world<<"<font size=1>Items Loaded ([amount])."
	else world<<"<font size=1>Items Loaded ([amount])."
proc/SaveMobs()
	var/foundobjects=0
	var/list/father_list = list()
	fdel("MobSave")
	var/savefile/F=new("MobSave")
	var/list/L=new/list
	for(var/mob/A) if(!A.client)
		if(A.SaveMob||A.SLogoffOverride||A.BlankPlayer)
			if(A.Father)//clones
				if(!A.Father in father_list)
					father_list.len++
					father_list[father_list.len] = A.Father
					father_list[A.Father] = 0
				if(father_list[A.Father] >= 10)
					continue
				else
					father_list[A.Father]+=1
					foundobjects+=1
					A.saved_x=A.x
					A.saved_y=A.y
					A.saved_z=A.z
					L.Add(A)
			else
				foundobjects+=1
				A.saved_x=A.x
				A.saved_y=A.y
				A.saved_z=A.z
				L.Add(A)
	F["MobSave"]<<L
	world<<"<font size=1>Mobs saved ([foundobjects] items)"
proc/LoadMobs()
	var/amount=0
	if(fexists("MobSave"))
		var/savefile/F=new("MobSave")
		var/list/L=new/list
		F["MobSave"]>>L
		for(var/mob/A in L)
			amount+=1
			A.loc=locate(A.saved_x,A.saved_y,A.saved_z)
			if(A.clone && !(A.SLogoffOverride||A.BlankPlayer))
				A.clone_degeneration++
				if(A.clone_degeneration >= 5) A.deleteMe()
			for(var/mob/B in mob_list) //prevents duping: characters with the same signature will delete the mob being loaded.
				sleep(1)
				if(B.signature == A.signature) del(A)
	world<<"<font size=1>Mobs Loaded ([amount])."
obj/var
	saved_x=1
	saved_y=1
	saved_z=1
	savetype
	SaveItem=0
mob/var
	saved_x=1
	saved_y=1
	saved_z=1
	SaveMob = 0