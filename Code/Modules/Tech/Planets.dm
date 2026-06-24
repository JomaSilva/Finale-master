mob/var/tmp/inpod
obj/var
	tech=0
	techcost=0 //Tells how much money it took to upgrade it to this level.
/*
"Central Quadrant" - Large Space Station, No Planet. (Afterlife Temple?)
"Eastern Quadrant" - Space : Desert, Arlia, Vegeta.
"Southern Quadrant" - Small Space Station, Arconia
"Western Quadrant" - Space : Geti Star, Ice (and New Vegeta)
"Northern Quadrant" - Space : Earth, Namek
Planets:
//1 = Earth
//2 = Namek
//3 = Vegeta
//4 = Icer Planet
//5 = Arconia
//8 = Desert
//11 = Hera
//19 = Big Geti Star
//21 = Arlia
//26 = Large Space Station
//28 = Small Space Station
//24 = Interdimension //Portal
//Below 3 are all portal related. Negative Earth will be implemented when Star Dragons are.
//20 = Negative Earth //via Interdimension
//6 = Afterlife (What we call Checkpoint) //via Interdimension
//13 = HBTC //via Interdimension
*/

obj/Planets
	icon='Planets.dmi'
	density=1
	SaveItem=0
	IsntAItem=1
	plane = 1
	pixel_x = -48
	pixel_y = -48
	canGrab=0
	var/planetIcon='Planets.dmi'
	var/planetState=""
	var/planetType = ""
	var/planetQuadrant = "" //Central Quadrant, Eastern Quadrant, Western Quadrant, Northern Quadrant. After adding a planet, make sure it has a z level on bump!
	var/pleasekillme = 0 //For planets that don't deserve to exist. (Heaven/hell)
	var/isMoving = 1
	var/isDestroyed=0
	var/isBeingDestroyed=0
	var/restrictedX = list(0,1)
	var/restrictedY = list(0,1)
	var/destroyAble=1
	var/tmp/overrided = 0
	New(loc,override)
		..()
		overrided=override
		if(override) return
		planet_list+=src
		switch(planetQuadrant)
			if("Central Quadrant")
				restrictedX = list(225,275)
				restrictedY = list(225,275)
			if("Eastern Quadrant")
				restrictedX = list(275,499)
				restrictedY = list(200,300)
			if("Southern Quadrant")
				restrictedX = list(225,275)
				restrictedY = list(1,200)
			if("Western Quadrant")
				restrictedX = list(1,225)
				restrictedY = list(200,300)
			if("Northern Quadrant")
				restrictedX = list(225,275)
				restrictedY = list(300,499)
		start
		if(isMoving && !isDestroyed)
			var/alreadyExists
			for(var/obj/Planets/P in world)
				if(P!=src&&P.planetType==planetType&&!P.overrided)
					alreadyExists=1
					break
			if(alreadyExists)
				del(src)
			var/list/goodPlaces= list()
			CHECK_TICK
			for(var/turf/T in oview(1,src))
				if(!T.density)
					if(T.x>=restrictedX[1]&&T.x<=restrictedX[2]&&T.y>=restrictedY[1]&&T.y<=restrictedY[2])
						goodPlaces += T
			if(goodPlaces.len>=1)
				var/turf/choice = pick(goodPlaces)
				step_to(src,choice)
			else
				switch(planetQuadrant)
					if("Central Quadrant")
						loc=locate(rand(225,275),rand(225,275),26)
					if("Eastern Quadrant")
						loc=locate(rand(275,499),rand(200,300),26)
					if("Southern Quadrant")
						loc=locate(rand(225,275),rand(1,200),26)
					if("Western Quadrant")
						loc=locate(rand(0,225),rand(200,300),26)
					if("Northern Quadrant")
						loc=locate(rand(225,275),rand(300,499),26)
		if(isDestroyed)
			icon=null
			icon_state=null
			density=0
			isBeingDestroyed=0
			for(var/area/A in area_list)
				if(A.Planet == planetType)
					A.isdestroyed = 1
		else
			icon=planetIcon
			icon_state=planetState
			density=1
			for(var/area/A in area_list)
				if(A.Planet == planetType)
					A.isdestroyed = 0
		spawn(100) goto start
	Del()
		planet_list-=src
		..()
	Earth
		planetState = "Earth"
		planetType = "Earth"
		planetQuadrant = "Northern Quadrant"
	Namek
		planetState = "Namek"
		planetType = "Namek"
		planetQuadrant = "Northern Quadrant"
	Vegeta
		planetState = "Vegeta"
		planetType = "Vegeta"
		planetQuadrant = "Eastern Quadrant"
	Big_Gete_Star
		planetState = "Big Gete Star"
		planetType = "Big Gete Star"
		planetQuadrant = "Western Quadrant"
	Arconia
		planetState = "Arconia"
		planetType = "Arconia"
		planetQuadrant = "Southern Quadrant"
	Vampa
		planetState = "Vampa"
		planetType = "Desert"
		planetQuadrant = "Eastern Quadrant"
	Arlia
		planetState = "Arlia"
		planetType = "Arlia"
		planetQuadrant = "Eastern Quadrant"
	Large_Space_Station
		planetState = "Large Space Station"
		planetType = "Large Space Station"
		planetQuadrant = "Central Quadrant"
	Small_Space_Station
		planetState = "Small Space Station"
		planetType = "Small Space Station"
		planetQuadrant = "Southern Quadrant"
	Ice
		planetState = "Icer Planet"
		planetType = "Icer Planet"
		planetQuadrant = "Western Quadrant"
	Interdimension
		planetState = "Interdimension"
		planetType = "Interdimension"
		planetQuadrant = "Western Quadrant"
		destroyAble=0

	Heaven
		pleasekillme=1
		planetState = "Heaven"
		planetType = "Heaven"
	Hell
		pleasekillme=1
		planetState = "Hell"
		planetType = "Hell"

mob/proc/testPlanetbump(var/A)
	if(istype(A,/obj/Planets))
		var/obj/Planets/P = A
		if(P.isDestroyed)
			return
		switch(P.planetType)
			if("Earth")
				usr.loc=locate(rand(240,260),rand(240,260),1)
				usr.Planet="Earth"
			if("Namek")
				usr.loc=locate(rand(240,260),rand(240,260),2)
				usr.Planet="Namek"
			if("Vegeta")
				usr.loc=locate(rand(240,260),rand(240,260),3)
				usr.Planet="Vegeta"
			if("Big Gete Star")
				usr.loc=locate(rand(240,260),rand(240,260),19)
				usr.Planet="Big Gete Star"
			if("Arconia")
				usr.loc=locate(rand(240,260),rand(240,260),5)
				usr.Planet="Arconia"
			if("Desert")
				usr.loc=locate(rand(240,260),rand(240,260),8)
				usr.Planet="Desert"
			if("Arlia")
				usr.loc=locate(rand(240,260),rand(240,260),21)
				usr.Planet="Arlia"
			if("Icer Planet")
				usr.loc=locate(rand(240,260),rand(240,260),4)
				usr.Planet="Icer Planet"
			if("Hera")
				usr.loc=locate(rand(240,260),rand(240,260),11)
				usr.Planet="Hera"
			if("Interdimension")
				usr.loc=locate(rand(240,260),rand(240,260),24)
				usr.Planet="Interdimension"
			if("Large Space Station")
				usr.loc=locate(73,78,28)
				Planet = "Large Space Station"
			if("Small Space Station")
				usr.loc=locate(146,180,27)
				Planet = "Small Space Station"
var/list/PlanetDisableList = list()

proc/LoadPlanets()
	for(var/AA in typesof(/obj/Planets))
		var/obj/Planets/A = new AA
		if(A.type == /obj/Planets)
			del(A)
			continue
		if(A.planetType in PlanetDisableList)
			continue
		if(A.pleasekillme)
			continue
		var/alreadyExists
		for(var/obj/Planets/P in world)
			if(P!=A&&P.planetType==A.planetType)
				alreadyExists=1
				break
		if(alreadyExists)
			del(A)
			continue
		else
			switch(A.planetQuadrant)
				if("Central Quadrant")
					A.loc=locate(rand(225,275),rand(225,275),26)
				if("Eastern Quadrant")
					A.loc=locate(rand(275,499),rand(200,300),26)
				if("Southern Quadrant")
					A.loc=locate(rand(225,275),rand(1,200),26)
				if("Western Quadrant")
					A.loc=locate(rand(0,225),rand(200,300),26)
				if("Northern Quadrant")
					A.loc=locate(rand(225,275),rand(300,499),26)

mob/Admin3/verb/Planet_Options()
	set category = "Admin"
	switch(input(usr,"Enable a planet, disable a planet, check planets that are disabled. Toggle planet destroy, and restore/destroy existing planets.") in list("Disable","Enable","Check","Toggle","Restore/Destroy","Cancel"))
		if("Disable")
			PlanetDisableList+=input(usr,"Type the name of the planet EXACTLY how you see it! Alternatively, find the planet in space, edit it, find the planetType variable, and input it here.") as text
		if("Enable")
			PlanetDisableList-=input(usr,"Type the name of the planet EXACTLY how you see it! Alternatively, find the planet in space, edit it, find the planetType variable, and input it here.") as text
		if("Check")
			for(var/A in PlanetDisableList)
				usr << "Toggle Planet: [A] is disabled."
		if("Toggle")
			if(canplanetdestroy)
				canplanetdestroy = 0
				world << "Planet Destroy off."
			else
				canplanetdestroy = 1
				world << "Planet Destroy on."
		if("Restore/Destroy")
			var/list/deadlist = list()
			for(var/obj/Planets/P)
				deadlist+=P
			if(deadlist.len>=1)
				var/obj/Planets/revivespecific = input(usr,"Restore/destroy what planet?","") as null|anything in deadlist
				if(!isnull(revivespecific))
					if(revivespecific.isDestroyed)
						revivespecific.isDestroyed = 0
						world << "[revivespecific] restored."
					else
						revivespecific.isDestroyed = 1
						world << "[revivespecific] destroyed."


mob/keyable/verb/Planet_Destroy()
	set name = "Planet Destroy"
	set category="Skills"
	set waitfor =0
	set background = 1
	if(usr.Ki>=1000*BaseDrain&&usr.expressedBP>=10000*usr.Planetgrav)
		var/obj/Planets/currentP
		for(var/obj/Planets/P in planet_list)
			if(P.planetType==usr.Planet)
				currentP = P.planetType
				if(!P.destroyAble||usr.Planet=="Space"||!canplanetdestroy)
					usr << "You can't use Planet Destroy here."
					return
				break
		if(!currentP)
			usr << "You can't use Planet Destroy here."
			return
		usr.Ki-=1000*BaseDrain
		switch(input("Destroy this Planet?","",text) in list("No","Yes"))
			if("Yes")
				//var/zz=usr.z
				var/mexpressedBP = usr.expressedBP
				for(var/obj/Planets/P in planet_list)
					if(P.planetType==currentP)
						P.isBeingDestroyed = 1
						break
				view(usr)<<"<font color=yellow>*[usr] begins focusing their energy on destroying the planet!*"
				WriteToLog("rplog","[usr] blew up [currentP] with planet destroy!!!   ([time2text(world.realtime,"Day DD hh:mm")])")
				usr.emit_Sound('deathball_charge.wav')
				var/obj/attack/blast/A=new/obj/attack/blast
				A.icon='15.dmi'
				A.icon_state="15"
				A.density=1
				A.loc=locate(usr.x,usr.y+1,usr.z)
				sleep(300)
				flick('Zanzoken.dmi',usr)
				if(A)
					A.icon='16.dmi'
					A.icon_state="16"
					sleep(10)
					walk(A,SOUTH,3)
					spawn(30) if(A)
						var/obj/B=new/obj
						B.icon='Giant Hole.dmi'
						B.loc=A.loc
						del(A)
					var/area/currentarea=GetArea()
					currentarea.DestroyPlanet(mexpressedBP)

	else usr<<"You do not have enough energy. (You need 1000 Ki, and a expressed BP of 10k * The planet's gravity.)"


/datum/skill/Ki_Control/Planet_Destroy
	skilltype = "Ki"
	name = "Planet Destroy"
	desc = "Raze entire planets underneath your palms."
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	after_learn()
		savant<<"Your body molds into it's utter peak."
		assignverb(/mob/keyable/verb/Planet_Destroy)
	before_forget()
		savant<<"Your body falls from the peak, and you feel intense sorrow. /fit/ disapproves."
		unassignverb(/mob/keyable/verb/Planet_Destroy)
	login()
		..()
		assignverb(/mob/keyable/verb/Planet_Destroy)

var/canplanetdestroy = 1
