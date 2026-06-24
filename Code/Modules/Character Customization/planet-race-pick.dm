/*Planet() //</font size></font face></font type></font color></font>
			var/list/A=new/list
			//A.Add("Big Gete Star")
			//A.Add("Arlia")
			A.Add("Earth")
			A.Add("Namek")
			A.Add("Vegeta")
			//A.Add("Arconia")
			A.Add("Heaven")
			A.Add("Hell")
			//A.Add("Icer Planet")
			//A.Add("Large Space Station")
			//A.Add("Small Space Station")
			switch(input("Choose Starting Area","",text) in A)
				if("Earth")
					usr.spawnPlanet="Earth"
				if("Namek")
					usr.spawnPlanet="Namek"
				if("Vegeta")
					usr.spawnPlanet="Vegeta"
				if("Arconia")
					usr.spawnPlanet="Arconia"
				if("Icer Planet")
					usr.spawnPlanet="Icer Planet"
				if("Arlia")
					usr.spawnPlanet="Arlia"
				if("Heaven")
					usr.spawnPlanet="Heaven"
				if("Hell")
					usr.spawnPlanet="Hell"
				if("Large Space Station")
					usr.spawnPlanet="Large Space Station"
				if("Small Space Station")
					usr.spawnPlanet="Small Space Station"
				if("Big Gete Star")
					usr.spawnPlanet="Big Gete Star"
*/

obj
	dummy_planet
		var/planet
		Click()
			usr.spawnPlanet = planet
			usr.dummy_race = ""
			winset(usr,"race_pick_act.name","text=\"\"")
			winset(usr,"race_pick_act.description","text=\"\"")
			usr.initialize_race_window(planet)
	dummy_egg //a standin for BOTH eggs and females
		Click()
			usr.dummy_race = ""
			winset(usr,"race_pick_act.name","text=\"\"")
			winset(usr,"race_pick_act.description","text=\"\"")
			usr.initialize_race_window("pregnant")
mob/var/tmp/dummy_race=""

mob/proc/update_race_desc(racename,desc)
	winset(usr,"race_pick_act.name","text=\"[racename]\"")
	winset(usr,"race_pick_act.description","text=\"[desc]\"")
	dummy_race = racename

mob/proc/initialize_planet_window()
	var/list/planet_list = list()
	planet_list += new/obj/Planets/Earth(null,1)
	planet_list += new/obj/Planets/Namek(null,1)
	planet_list += new/obj/Planets/Vegeta(null,1)
	planet_list += new/obj/Planets/Heaven(null,1)
	planet_list += new/obj/Planets/Hell(null,1)
	winshow(src,"race_pick_act",1)
	var/dummyobjs
	for(var/obj/Planets/nR in planet_list)
		var/obj/dummy_planet/nP = new
		nP.name = nR.name
		nP.icon = nR.planetIcon
		nP.icon_state = nR.planetState
		nP.planet = nR.planetType
		src<<output(nP,"race_pick_act.planet_grid: [++dummyobjs]")
	var/obj/dummy_egg/eGG = new
	eGG.name = "Pregnant/Eggs"
	eGG.icon = 'Egg.dmi'
	src<<output(eGG,"race_pick_act.planet_grid: [++dummyobjs]")
	inAwindow=1
	contents += new/obj/race_window_proceed

mob/proc/initialize_race_window(planet)
	var/list/A=new/list
	for(var/mob/M) if(M.client)
		if(M.Race=="Human"&&M.Age>=16&&M.SAge>=16)
			Halfie_Year+=0.5
		if(M.Race=="Saiyan"&&M.Age>=16&&M.SAge>=16)
			Halfie_Year+=0.5
	var/canlegend=0
	if(canlegendary)
		if(legend_sig.len >= 1)
			if(legend_override && AscensionStarted) canlegend = 1
			else
				if(legend_pre_ssj)
					for(var/mob/M) if(M.client)
						if(M.Class=="Legendary")
							canlegend=0
							break
		else if(legend_pre_ssj) canlegend = 1
	if(canlegend)
		legend_override = 0//double check to prevent people from queuing up multiple Legendaries.
		usr<<"<br><br>The requirements for Legendary Saiyan have been unlocked: there isnt a Legendary Saiyan online already, or the Legendary Saiyan hasn't been on for awhile."
	//for(var/mob/M) if(M.client) if(M.Race=="Half-Saiyan"&&M.hasssj)
	//	usr.canqs=1
	//	break

	if(android_creator_list && android_creator_list.len) A.Add("Android")
	if(spirit_creator_list && spirit_creator_list.len) A.Add("Spirit Doll")
	if(bio_creator_list && bio_creator_list.len) A.Add("Bio-Android")
	switch(planet)
		if("Earth")//Earth
			if(canhuman)	A.Add("Human")
			if(canshape)	A.Add("Shapeshifter") //move Shapeshifter into classes of Human.
			if(canDemigod)
				A.Add("Demigod")
			/*if(Halfie_Year>=1&&cansai)
				A.Add("Half-Saiyan")
			if(canqs&&cansai)
				A.Add("Quarter-Saiyan")*/
			if(canmajin)
				A.Add("Majin")
			if(canalien)	A.Add("Alien")
			if(candroid) A.Add("Android")
			if(candoll) A.Add("Spirit Doll")
			if(canbio) A.Add("Bio-Android")

		if("Large Space Station")
			if(canmajin)
				A.Add("Majin")
			if(candroid) A.Add("Android")
			if(canalien)	A.Add("Alien")
			if(canmeta)	A.Add("Meta")
			if(canchangie)	A.Add("Frost Demon")
			if(canbio) A.Add("Bio-Android")

		if("Small Space Station")
			if(canheran)	A.Add("Heran")
			if(canalien)	A.Add("Alien")
			if(candroid) A.Add("Android")
			if(canmeta)	A.Add("Meta")
			if(canchangie)	A.Add("Frost Demon")
			if(canbio) A.Add("Bio-Android")

		if("Vegeta")//Vegeta
			if(cansai)	A.Add("Saiyan")
			if(Halfie_Year>=1&&cansai)
				A.Add("Half-Saiyan")
			if(canlegend&&cansai)
				A.Add("Legendary Saiyan")
			if(canintel) A.Add("Tsujin")
			if(cansaib)	A.Add("Saibamen")
			if(canheran)	A.Add("Heran")
			if(canmeta)	A.Add("Meta")
			if(canchangie)	A.Add("Frost Demon")
			if(canalien)	A.Add("Alien")

		if("Namek")//Namek
			if(cannamek)
				A.Add("Namekian")
			if(canarl)	A.Add("Arlian")
			if(canmakyo)	A.Add("Makyo")
			if(cangray)	A.Add("Gray")
			if(canalien)	A.Add("Alien")
			if(cankan)	A.Add("Kanassa-Jin")
			if(canyardrat)	A.Add("Yardrat")

		if("Big Gete Star")//Gete Star
			if(canmeta)	A.Add("Meta")
			if(canalien)	A.Add("Alien")
			if(canbio) A.Add("Bio-Android")

		if("Arlia")//Arlian
			if(canarl)	A.Add("Arlian")
			if(canmakyo) A.Add("Makyo")
			if(cangray)	A.Add("Gray")
			if(canalien)	A.Add("Alien")

		if("Icer Planet")//Changie
			if(canchangie)	A.Add("Frost Demon")
			if(canalien)	A.Add("Alien")

		if("Arconia")//Arconia -- Aliens
			if(canalien)	A.Add("Alien")
			if(cankan)	A.Add("Kanassa-Jin")
			if(canyardrat)	A.Add("Yardrat")
			if(canheran)	A.Add("Heran")

		if("Heaven")//Heaven
			if(canDemigod) A.Add("Demigod")
			if(cankai)	A.Add("Kai")

		if("Hell")//Hell
			if(candemon)	A.Add("Demon")
			if(canDemigod) A.Add("Demigod")

	var/list/race_list = list()
	var/list/race_app_list = list()
	race_list += typesof(/obj/race)
	race_list -= /obj/race
	for(var/race_type in race_list)
		var/obj/race/nR = new race_type
		if(nR.racename in A)
			race_app_list += nR
	winset(usr,"race_pick_act.race_grid","cells=0")

	if(planet == "pregnant")
		for(var/mob/M in player_list)
			if(M.Pregnant)
				var/obj/race/nR = new()
				nR.name = "[M.name]"
				nR.icon = M.icon
				nR.overlays = M.overlays
				nR.racename = "Pregnant NULL"
				nR.desc = "Be born as a child from [M.name] and [M.Husband]. You shall have the traits of the dominate genome, but the status of all races in makeup of the genome."
				race_app_list += nR
		for(var/mob/Egg/M in mob_list)
			var/obj/race/nR = new()
			nR.name = "[M.name]"
			nR.icon = M.icon
			nR.racename = "Pregnant NULL"
			nR.desc = "Be born from a egg of [M.name]. You shall have the traits of the dominate genome, but the status of all races in the makeup of the genome."
			race_app_list += nR
	var/dummyobjs
	for(var/obj/obja in race_app_list)
		src<<output(obja,"race_pick_act.race_grid: [++dummyobjs]")
	
	//winset(usr,"race_pick_act.race_grid")

obj/race_window_proceed
	IsntAItem=1
	verb/proceedbutton()
		set category = null
		set hidden = 1
		if(usr.dummy_race!="" && usr.spawnPlanet!="")
			winshow(usr,"race_pick_act", 0)
			usr.inAwindow=0
			usr.Race(usr.dummy_race)
			usr.race_window_proceed_remove()//causes a infinite cross reference loop otherwise
			del(src)
		else if(usr.dummy_race == "Pregnant NULL" && usr.tmp_parent)
			winshow(usr,"race_pick_act", 0)
			usr.inAwindow=0
			var/mob/m = usr.tmp_parent
			usr.genome = return_new_genome(m.womb)
			if(m.Egg) usr.eggpar(m)
			else usr.parentpar(m)
			usr.Race("Pregnant")
			del(src)
		else usr<<"Pick a race and planet."
mob/var/tmp/tmp_parent
mob/proc/race_window_proceed_remove()
	verbs -= typesof(/obj/race_window_proceed/verb)
	contents -= /obj/race_window_proceed
	inAwindow=0
