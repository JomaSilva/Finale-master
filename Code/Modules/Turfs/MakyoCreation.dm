//Makyo star creates doorways on realms it's linked to.
//Makyo star has a doorway which leads randomly to one of these realms (if theres multiple)

area/var
	hasHellstarGate = 0
	tmp/obj/MakyoGate/HellstarGateObj = null

area/proc/testHellstar()
	if(IsHellstar)
		hasHellstarGate = 1
		if(HellstarGateObj) del(HellstarGateObj)
		var/turf/A = pickTurf(src,2)
		if(A)
			var/obj/MakyoGate/nG = new (A)
			HellstarGateObj = nG
		else
			return
	else hasHellstarGate = 0

mob/Admin3/verb/ForceWeather()
	set category = "Admin"
	var/list/areapicklist = list()
	for(var/area/A in area_outside_list)
		areapicklist += A
	var/area/choice1 = input(usr,"What area?") as null|area in areapicklist
	if(isarea(choice1))
		switch(input(usr,"Which weather type?") in list("Cancel","Makyo Star"))
			if("Makyo Star")
				choice1.IsHellstar=1
				choice1.testHellstar()

/obj/MakyoGate
	name = "Mysterious Gateway"
	icon = 'HellSpiral.dmi'
	density = 0
	canGrab=0
	IsntAItem=1
	pixel_x = -34
	pixel_y = -34
	mouse_opacity = 1
	Crossed(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/M = Obstacle
			var/area/targetArea
			for(var/area/A in area_outside_list)
				if(A.Planet == "Makyo Star")
					targetArea = A
					break
			if(targetArea)
				var/turf/temploc = pickTurf(targetArea,1)
				M.loc = (locate(temploc.x,temploc.y,temploc.z))
			else return FALSE //noarea? failed move.
		..()

/obj/MakyoReturn
	name = "Mysterious Exit"
	icon = 'HellSpiral.dmi'
	density = 0
	canGrab=0
	IsntAItem=1
	pixel_x = -34
	pixel_y = -34
	mouse_opacity = 1
	Crossed(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/M = Obstacle
			var/area/targetArea
			for(var/area/A in area_outside_list)
				if(A.hasHellstarGate && A.Planet != "Makyo Star")
					targetArea = A
					break
			if(!targetArea)//if the Makyo Star isn't actually connected to anything
				for(var/area/A in area_outside_list)
					if(A.Planet == "Space")//send to Space
						targetArea = A
						break
			if(targetArea)
				var/turf/temploc = pickTurf(targetArea,1)
				M.loc = (locate(temploc.x,temploc.y,temploc.z))
			else return FALSE //noarea? failed move.
		..()