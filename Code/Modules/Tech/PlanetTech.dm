obj/items
	Nav_System
		icon='Misc2.dmi'
		icon_state="Radar"
		var/link
		New()
			..()
			link = "[rand(1,9999)]"
		verb/Power_Switch()
			set category=null
			set src in usr
			if(equipped==0)
				usr.hasnav=1
				usr<<"<b>You turn on your navigation system.(Only works while in space)"
				equipped=1
			else
				usr.hasnav=0
				usr<<"<b>You turn off your navigation system"
				equipped=0
		verb/Call_Ship()
			set category = null
			set src in usr
			var/linkedship
			view(usr)<<"[usr] presses a button on a small computer!"
			for(var/obj/Spacepod/Sp in world)
				if(Sp.link==link)
					linkedship = 1
					usr<<"You call the linked ship. This will take [((400/Sp.Speed)/10)] second(s)"
					sleep(400/Sp.Speed)
					Sp.loc = locate(usr.x + rand(1,-1),usr.y + rand(1,-1),usr.z)
					break
			if(linkedship)
				usr<<"There's no ship to call."
		verb/Change_Link()
			set src in usr
			set category = null
			link = input(usr,"Change the link of the nav system, letting you call a linked spacecraft.","",link) as text
mob/var/tmp/obj/Spacepod/ship
obj/Spacepod
	density=1
	SaveItem=1
	plane = 6
	cantblueprint=0
	icon='Spacepod.dmi'
	fragile = 1
	move_delay = 0.1
	var/channel = "" //channel of the ship, for talking
	var/link = "" //link of the ship, for calling
	var/Speed=1 //divisor of the probability of delay (*100) the pod will have when it moves.
	var/tmp/mob/pilot = null
	var/eject = 0
	New()
		..()
		link = "[rand(1,9999)]"
	verb/Launch()
		set category=null
		set src in view(1)
		usr<<"ETA [((400/Speed)/10)] second(s)"
		icon_state = "Launching"
		pilot.launchParalysis = 1
		sleep(400/Speed)
		for(var/obj/Planets/P in world)
			if(P.planetType==usr.Planet)
				var/list/randTurfs = list()
				for(var/turf/T in view(1,P))
					randTurfs += T
				var/turf/rT = pick(randTurfs)
				src.loc = locate(rT.x,rT.y,rT.z)
				pilot.loc = locate(rT.x,rT.y,rT.z)
				icon_state = ""
				break
		icon_state = ""
		pilot.launchParalysis = 0

	verb/Use()
		set category=null
		set src in view(1)
		set background = 1
		if(pilot)
			eject = 1
			pilot.launchParalysis = 0
			pilot.ship = null
			density = 1
			pilot = null
		else
			spawn
				pilot = usr
				pilot.ship = src
				density = 0
				eject = 0
				pilot.launchParalysis = 0
				pilot.loc = locate(x,y,z)
				while(!eject&&pilot)
					sleep(0.2)
					if(!pilot) return
					loc = locate(pilot.x,pilot.y,pilot.z)
					pilot.ship = src
				pilot.ship = null
				pilot = null
				density = 1
				eject = 0
				pilot.launchParalysis = 0

	Del()
		if(pilot)
			pilot.ship = null
		spawnExplosion(location=loc,strength=maxarmor,radius=1)
		..()
	verb/Link()
		set src in oview(1)
		set category = null
		link = input(usr,"Change the link of the spacecraft, letting you call it from a linked Nav System.","",link) as text
	verb/Channel()
		set src in oview(1)
		set category = null
		channel = input(usr,"Change the channel of the spacecraft, letting you talk to other devices on the same frequency.","",channel) as text
	verb/Ship_Speak(msg as text)
		set src in oview(1)
		set category = null
		for(var/obj/O)
			if(istype(O,/obj/items/Scouter))
				var/obj/items/Scouter/nO = O
				if(nO.suffix&&ismob(nO.loc)&&link==nO.channel)
					var/mob/M = nO.loc
					M<<"(Spacepod)<[usr.SayColor]>[usr] says, '[msg]'"
			if(istype(O,/obj/Spacepod))
				var/obj/Spacepod/nO = O
				if(link==nO.link)
					view(O)<<"(Spacepod)<[usr.SayColor]>[usr] says, '[msg]'"
			if(istype(O,/obj/items/Communicator))
				var/obj/items/Communicator/nO = O
				if(link in nO.freqlist)
					nO.messagelist+={"<html><head><title></title></head><body><body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>(Spacepod)<[usr.SayColor]>[usr] says, '[msg]'</font><br></body><html>"}
					if(nO.hasbroadcaster) view(nO) << "(Spacepod)<[usr.SayColor]>[usr] says, '[msg]'"
	verb/Info()
		set src in oview(1)
		set category=null
		usr<<"Speed: [Speed]"
		usr<<"Cost to make: [techcost]z"
	verb/Upgrade()
		set src in oview(1)
		set category=null
		var/cost=0
		var/list/Choices=new/list
		Choices.Add("Cancel")
		if(usr.zenni>=1000*Speed&&Speed<=39) Choices.Add("Speed ([1000*Speed]z)")
		if(usr.zenni>=1000) Choices.Add("Armor (1000z)")
		var/A=input("Upgrade what?") in Choices

		if(A=="Cancel") return
		if(A=="Speed ([1000*Speed]z)")
			cost=1000*Speed
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Speed increased."
			Speed+=1
		if(A=="Armor (1000z)")
			cost=1000*Speed
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Armor increased."
			armor=usr.intBPcap
			maxarmor=usr.intBPcap
		usr<<"Cost: [cost]z"
		usr.zenni-=cost
		tech+=1
		techcost+=cost

obj/Creatables
	Rocket_Ship
		icon='rocketship.dmi'
		icon_state="stable"
		cost=200000
		neededtech=30 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Rocket Ships are basically just one-use pods. They're more expensive to make, but pretty easy to build."
		create_type = /obj/Rocketship

	Spacesuit
		icon='spacesuit.dmi'
		cost=75000
		neededtech=25 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Spacesuits are easier to make than Rebreathers, but are pretty cumbersome on looks. They also have communication functionality."
		create_type = /obj/items/clothes/Spacesuit

obj/Rocketship
	density=1
	SaveItem=1
	plane = 6
	cantblueprint=0
	icon='rocketship.dmi'
	icon_state="stable"
	fragile = 1
	move_delay = 0.1
	var/channel = "" //channel of the ship, for talking
	var/link = "" //link of the ship, for calling
	var/Speed=1 //divisor of the probability of delay (*100) the pod will have when it moves.
	var/tmp/mob/pilot = null
	var/eject = 0
	var/didland = 0
	New()
		..()
		link = "[rand(1,9999)]"
	verb/Launch()
		set category=null
		set src in oview(1)
		if(icon_state!="stable") return
		var/area/nA = GetArea()
		if(nA.InsideArea)
			usr << "[src]: Error: inside"
			return
		view(src)<<"ETA [((400/Speed)/10)] second(s)"
		icon_state = "liftoff"
		pilot.launchParalysis = 1
		sleep(400/Speed)
		for(var/obj/Planets/P in world)
			if(P.planetType==usr.Planet)
				var/list/randTurfs = list()
				for(var/turf/T in view(1,P))
					randTurfs += T
				var/turf/rT = pick(randTurfs)
				src.loc = locate(rT.x,rT.y,rT.z)
				pilot.loc = locate(rT.x,rT.y,rT.z)
				icon_state = "space"
				break
		sleep(150)
		view(src) << "[src]: Re-entry imminenet."
		sleep(100)
		var/turf/temploc = pickTurf(nA,2)
		if(pilot)
			pilot.loc = locate(temploc.x,temploc.y,temploc.z)
		src.loc = locate(temploc.x,temploc.y,temploc.z)
		icon_state = "landed"
		if(pilot)
			sleep(10)
			view(src) << "[src]: Re-entry success."
			didland=1
		else
			sleep(10)
			view(src) << "[src]: Re-entry failure."
			del(src)

	verb/Use()
		set category=null
		set src in view(1)
		set background = 1
		if(pilot)
			eject = 1
			pilot.launchParalysis = 0
			pilot.ship = null
			density = 1
			pilot = null
		else
			spawn
				pilot = usr
				pilot.ship = src
				density = 0
				eject = 0
				pilot.launchParalysis = 1
				pilot.loc = locate(x,y,z)
				while(!eject&&pilot)
					sleep(0.2)
					if(!pilot) return
					loc = locate(pilot.x,pilot.y,pilot.z)
					pilot.ship = src
				pilot.ship = null
				pilot = null
				density = 1
				eject = 0
				pilot.launchParalysis = 0
	verb/Fit()
		set category = null
		set src in oview(1)
		if(didland)
			switch(input(usr,"Fit the pod onto another rocket? Costs 100k Zenni.") in list("Yes","No"))
				if("Yes")
					if(usr.zenni>=100000)
						usr.zenni-=100000
						didland = 0
						icon_state = "stable"
					else usr<<"You dont have enough money"
	verb/Channel()
		set src in oview(1)
		set category = null
		channel = input(usr,"Change the channel of the spacecraft, letting you talk to other devices on the same frequency.","",channel) as text
	verb/Rocket_Speak(msg as text)
		set src in oview(1)
		set category = null
		for(var/obj/O)
			if(istype(O,/obj/items/clothes/Spacesuit))
				var/obj/items/clothes/Spacesuit/nO = O
				if(nO.suffix&&ismob(nO.loc)&&channel==nO.channel)
					var/mob/M = nO.loc
					M<<"(Rocketship)<[usr.SayColor]>[usr] says, '[msg]'"
			if(istype(O,/obj/items/Communicator))
				var/obj/items/Communicator/nO = O
				if(channel in nO.freqlist)
					nO.messagelist+={"<html><head><title></title></head><body><body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>(Rocketship)<[usr.SayColor]>[usr] says, '[msg]'</font><br></body><html>"}
					if(nO.hasbroadcaster) view(nO) << "(Rocketship)<[usr.SayColor]>[usr] says, '[msg]'"
	Del()
		if(pilot)
			pilot.ship = null
		spawnExplosion(location=loc,strength=maxarmor,radius=1)
		..()

obj/items/clothes
	Spacesuit
		icon='spacesuit.dmi'
		NotSavable=1
		var/channel
		verb/Channel()
			set src in oview(1)
			set category = null
			channel = input(usr,"Change the channel of the spacesuit, letting you talk to other devices on the same frequency.","",channel) as text
		verb/Ship_Speak(msg as text)
			set src in oview(1)
			set category = null
			for(var/obj/O)
				if(istype(O,/obj/Rocketship))
					var/obj/Rocketship/nO = O
					if(channel==nO.channel)
						view(nO)<<"(Spacesuit)<[usr.SayColor]>[usr] says, '[msg]'"
				if(istype(O,/obj/items/Communicator))
					var/obj/items/Communicator/nO = O
					if(channel in nO.freqlist)
						nO.messagelist+={"<html><head><title></title></head><body><body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>(Spacesuit)<[usr.SayColor]>[usr] says, '[msg]'</font><br></body><html>"}
						if(nO.hasbroadcaster) view(nO) << "(Spacesuit)<[usr.SayColor]>[usr] says, '[msg]'"
		Equip()
			set category=null
			set src in usr
			if(equipped==0)
				equipped=1

				suffix="*Equipped*"
				usr.spacesuit=1
				usr.overlayList+=icon
				usr.overlaychanged=1
				usr<<"You put on the [src]."
			else
				equipped=0
				suffix=""
				usr.spacesuit=0
				usr.overlayList-=icon
				usr.overlaychanged=1
				usr<<"You take off the [src]."