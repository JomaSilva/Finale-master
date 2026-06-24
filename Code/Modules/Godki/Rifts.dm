//rifts are essentially cool shit:
//about three/four types of rifts:
//rift 1: rng rift (rare), spawns at random at reboob, links one place to another (goes both ways)
//rift 2: godki rift, meditate inside for it to give you godki mastery (if you hit the req)
//rift 3: interdimension rift, spawns in interdimension, takes you to a random spot in the gameworld. (type one but touchy)
//rift 4: uhh lemme think on it.
//rift 1 and 2 are activated via clicking.
//rift 3 is activated via touch.

obj/Rift
	icon = 'colorableport.dmi'
	density = 0
	SaveItem = 0
	var/destinationx
	var/destinationy
	var/destinationz
	var/preset =0
	canGrab = 0
	pixel_x = -34
	pixel_y = -34
	var
		clicktotele = 1
		touchtotele = 0
		bthwy
		tmp/grace_period=0
		tmp/obj/Rift/partner_rift = null
	proc/Ticker()
		set waitfor = 0
		set background = 1
		if(grace_period)
			grace_period = max(0,grace_period-1)
		sleep(10)
		Ticker()
	proc/check_otherside(loct)
		if(bthwy)
			for(var/obj/Rift/O in loct)
				partner_rift = O
				break
			if(isnull(partner_rift))
				partner_rift = new type(loct)
				partner_rift.destinationx = x
				partner_rift.destinationy = y
				partner_rift.destinationz = z
			partner_rift.grace_period+=2

	New()
		..()
		for(var/obj/Teleporter/S in loc)
			if(S!=src)
				S.deleteMe()
		if(isnull(destinationx)||isnull(destinationy)||isnull(destinationz))
			if(preset) return
			var/area/targetArea
			var/templanet
			templanet = pick("Earth","Namek","Vegeta","Arconia","Afterlife") //no ball 'planet' results in the balls being spread accross the entire gameworld
			for(var/area/A in area_outside_list)
				CHECK_TICK
				if(A.Planet == templanet)
					targetArea = A
					break
			if(targetArea)
				var/turf/temploc = pickTurf(targetArea,2)
				destinationx = temploc.x
				destinationy = temploc.y
				destinationz = temploc.z

		spawn Ticker()
	Cross(atom/movable/Obstacle)
		if(ismob(Obstacle) && touchtotele && grace_period == 0)
			var/mob/M = Obstacle
			if(isnull(destinationx)||isnull(destinationy)||isnull(destinationz))
			else
				check_otherside(locate(destinationx,destinationy,destinationz))
				M.loc = locate(destinationx,destinationy,destinationz)
		. = ..()
		return .
	Click()
		if(ismob(usr) && clicktotele && grace_period == 0)
			var/mob/M = usr
			if(get_dist(src,M) <= 1)
				if(isnull(destinationx)||isnull(destinationy)||isnull(destinationz))
				else
					check_otherside(locate(destinationx,destinationy,destinationz))
					M.loc = locate(destinationx,destinationy,destinationz)
		..()
	Interdimensional_Rift
		color = "#640d86"
		bthwy = 0
		clicktotele = 0
		touchtotele = 1
	Rift
		color = "#0d6486"
		bthwy = 1
	GodKi_Rift
		color = "#e8e8e8"
		bthwy = 0
		var/trenegy = 110
		Ticker()
			var/mob/M = locate(/mob) in loc
			if(M && trenegy >= 1)
				if(M.med && M.godki && M.godki.tier == 0)
					trenegy--
					M.godki.usage = 1
					if(M.Ekiskill >= 5) M.gain_godki(2)
					if(M.kiratio > 1) M.gain_godki(1)
				else if(M.godki && M.godki.tier != 0)
					if(prob(50))
						trenegy--
						M.train_godki(1)
			..()
	
	GodKi_Enter_Rift
		color = "#e8e8e8"
		bthwy = 1
		preset=1
		New()
			..()
			if(isnull(destinationx)||isnull(destinationy)||isnull(destinationz))
				var/area/targetArea
				var/templanet
				templanet = "God Realm"
				for(var/area/A in area_outside_list)
					CHECK_TICK
					if(A.Planet == templanet)
						targetArea = A
						break
				if(targetArea)
					var/turf/temploc = pickTurf(targetArea,2)
					destinationx = temploc.x
					destinationy = temploc.y
					destinationz = temploc.z