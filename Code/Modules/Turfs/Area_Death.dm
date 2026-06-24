//so theres two different kinds of ways of destroying a planet
//You can kill the planet, slowly killing off all NPCs and setting a NPC cap, eventually destroying the planet entirely.
//or you can just blow it. This is the former.
area/var
	tmp/death_proc_running = 0
	planet_dying = 0
	planet_death_stage = 0
area/proc/Planet_Death(var/expressedBP)
	var/obj/Planets/Planet
	for(var/obj/Planets/Pl in planet_list)
		if(Pl.planetType==Planet)
			Planet = Pl
	planet_dying=1
	for(var/area/A in area_list)
		if(A.Planet == Planet && !A.planet_dying)
			A.planet_dying = 1
			if(!A.death_proc_running) spawn Planet_Death(AverageBP)
	destroy
	if(planet_death_stage<=3)
		beginning
		switch(planet_death_stage)
			if(0)
				limit_life()
				sleep(2000)
				planet_death_stage++
			if(1)//at this point weather permanently changes into nighttime
				limit_life()
				sleep(3000)
				planet_death_stage++
			if(2)//players will notice random turfs destroying themselves, trees dead
				limit_life()
				death_turf_destroy()
				sleep(3000)
				planet_death_stage++
			if(3)//all mobs are mostly gone, basically indentical to stage 2.
				limit_life()
				death_turf_destroy()
				sleep(4000)
				planet_death_stage++
		if(planet_death_stage==4) goto destroy
		else goto beginning
	else if(!Planet.isBeingDestroyed)
		Planet.isBeingDestroyed = 1
		DestroyPlanet(expressedBP)

area/proc/limit_life()
	for(var/mob/M in my_mob_list)
		if(M.isNPC)
			if(prob((planet_death_stage+1)*25)) M.mobDeath()

area/var/tmp/death_turf_destroy = 0
area/proc/death_turf_destroy()
	if(death_turf_destroy) return
	else
		death_turf_destroy=1
		spawn while(planet_death_stage>=2 && planet_death_stage!=4)
			sleep(60 + rand(10,90))
			for(var/mob/M in my_player_list) //a problem with the previous method: why affect land that won't affect players? Just do effects around players.
				if(M.client)
					var/turf/randturf = locate(M.x+rand(1,20),M.y+rand(1,20),M.z)
					for(var/turf/T in block(locate(randturf.x-5,randturf.y-5,randturf.z),locate(randturf.x+5,randturf.y+5,randturf.z)))
						lagstopsleep()
						if(prob(60)) sleep(1)
						if(!T.isSpecial&&!T.proprietor)
							if(prob(15))
								createDust(T,1)
								T.Destroy()
								break
area/proc/DestroyPlanet(var/mexpressedBP)
	set waitfor=0
	if(death_proc_running == 2) return
	planet_death_stage=4
	planet_dying=1
	death_proc_running=2
	for(var/area/A in area_list)
		if(A.Planet == Planet && A != src)
			if(A.death_proc_running!=2) spawn DestroyPlanet(mexpressedBP)
	for(var/mob/M in my_player_list)
		if(M.client)
			M.Quake()
			emit_Sound('telekinesis_charge.wav')
			M<<"<font color=red><font size=4>*The planet begins breaking apart around you!!*"
	var/obj/Planets/P=null
	for(var/obj/Planets/Pl in planet_list)
		if(Pl.planetType==Planet)
			P = Pl
	spawn while(P.isBeingDestroyed)
		IsWeathering = 1
		currentWeather = "Destruction"
		sleep(20 + rand(10,90))
		for(var/mob/M in my_player_list) //a problem with the previous method: why affect land that won't affect players? Just do effects around players.
			if(M.client)
				M.Quake()
				var/turf/randturf = locate(M.x+rand(1,40),M.y+rand(1,40),M.z)
				switch(pick(1,2,3))
					if(1)
						emit_Sound(pick('thunderclap.wav','rockmoving.wav'))
					if(2)
						//var/turf/randturf = locate(M.x+rand(1,20),M.y+rand(1,20),M.z)
						spawnExplosion(randturf,null,mexpressedBP/100,5)
					if(3)
						for(var/turf/T in block(locate(randturf.x-5,randturf.y-5,randturf.z),locate(randturf.x+5,randturf.y+5,randturf.z)))
							lagstopsleep()
							if(prob(60)) sleep(1)
							if(!T.isSpecial&&!T.proprietor)
								if(prob(50))
									T.Destroy()
									if(prob(50)) new/turf/Other/Stars(T)
									break
						sleep(10)
					if(4)
						var/turf/T = pick(my_turf_list)
						if(!T.isSpecial&&!T.proprietor)
							switch(rand(1,4))
								if(1) createDustmisc(T,rand(1,3))
								if(2)
									createLightningmisc(T,1)
									createLightningmisc(locate(T.x,T.y+1,T.z),1)
									createLightningmisc(locate(T.x,T.y-1,T.z),1)
								if(3) createDustmisc(T,rand(1,3))
								if(4) createCrater(T,pick(1,3))
	sleep(3100)//five minutes lol
	if(P.isBeingDestroyed)
		for(var/mob/M in my_player_list)
			if(M.isNPC)
				M.buudead = "force"
				M.Death()
			if(M.expressedBP<=mexpressedBP)
				M.SpreadDamage(99)
				M << "You have been damaged by the planet destructing!"
		P.isBeingDestroyed = 0
		PlanetDisableList += P.planetType
		P.isDestroyed=1
		createCrater(P.loc,3)
		spawnExplosion(location=P.loc,strength=mexpressedBP,radius=20)