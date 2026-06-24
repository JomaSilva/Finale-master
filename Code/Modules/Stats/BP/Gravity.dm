mob/var/tmp
	Planetgrav=1
	gravmult=0

mob/var
	HBTCMod=1 //Multiplies  while in there.
	HBTCTime=36000 //-1 every sleep(1), equals 1 hour
	EnteredHBTC=0 //How many times you have been in HBTC.

mob/proc/Grav_Gain()
	set waitfor = 0
	var/gravity = gravmult+Planetgrav
	var/testgrav = Grav_Handler(gravity)
	switch(testgrav)
		if(1)
			GravMastered+=0.001 + BPTick*(gravity)*GravMod*2*GlobalGravGain * 0.01
			GravMastered= min((gravmult+Planetgrav),GravMastered, gravitycap)
			BP+=capcheck(relBPmax*BPTick*TrainMod*Egains*(1/55))
			gravParalysis=0
		if(2)
			GravMastered+=0.001 + BPTick*(gravity)*GravMod*3*GlobalGravGain * 0.01
			BP+=capcheck(relBPmax*BPTick*TrainMod*Egains*(1/35))
			GravMastered= min((gravmult+Planetgrav),GravMastered, gravitycap)
			gravParalysis=0
		if(3)
			GravMastered+=0.001 + BPTick*(gravity)*GravMod*GlobalGravGain/1.1 * 0.01
			BP+=capcheck(relBPmax*BPTick*TrainMod*Egains*(1/45))
			GravMastered= min((gravity+Planetgrav),GravMastered, gravitycap)
		if(4)//equal gravity, mastered gravity is above normal limits.
			GravMastered+=BPTick*(gravity)*GravMod*GlobalGravGain * 0.001
			GravMastered= min((gravmult+Planetgrav),GravMastered, gravitycap)
			BP+=capcheck(relBPmax*BPTick*TrainMod*Egains*(1/60))
			gravParalysis=0
//so basically: grav is fucking retarded and so are you
//grav training in both the show and reality (reality it's more like weight training) is very destructive and dangerous
//why the fuck the last system encouraged you to step into a room of 100x your own mastery is fucking stupid.

mob/proc/Grav_Handler(var/Gravity)
	set waitfor = 0
	if(Gravity>GravMastered&&(!dead||KeepsBody))//dead people can no longer abuse not dying for grav gains without an actual body
		if(Gravity>(GravMastered*4))
			SpreadDamage((0.1*(Gravity/GravMastered))/(1+(Ephysdef*Ekidef)))
			stamina-=(0.1*(maxstamina/100))/(1+(Ephysdef*Ekidef))
			gravParalysis=1 //you're in above your head, this stops you from moving.
			zenkaiStore += (0.003*ZenkaiMod)*(Gravity/GravMastered)
			return 3
		else if(Gravity>=(GravMastered*2))
			SpreadDamage((0.07*(Gravity/GravMastered))/(2+(Ephysdef*Ekidef)))
			stamina-=(0.1*(maxstamina/100))/(1+(Ephysdef*Ekidef))
			zenkaiStore += (0.001*ZenkaiMod)*(Gravity/GravMastered)
			//movement delays already handled by movement handler.dm
			return 2
		else if(Gravity>=(GravMastered*1.5))
			SpreadDamage((0.03*(Gravity/GravMastered))/(5+(Ephysdef*Ekidef)))
			zenkaiStore += (0.001*ZenkaiMod)
			stamina-=(0.1*(maxstamina/100))/(2+(Ephysdef*Ekidef))
			//basically no stamina drain whatsoever.
			return 2
		else
			stamina-=(0.1*(maxstamina/100))/(2+(Ephysdef*Ekidef))
			return 1
	else
		gravParalysis=0
		if(Gravity==GravMastered && Gravity > 10) return 4
		return 0
	/*if(!KO)
		Grav_Gain(1)
		if(Gravity>GravMastered)
			HP-=((Gravity/GravMastered)/1000)
			if(attacking) GravMastered+=0.009*Gravity*GravMod*(train+1)
		spawn(100) if(prob(20)&&KO&&Gravity/GravMastered>5&&Gravity>50) Death()*/
mob/proc/Grav()
	set waitfor = 0
	//Regular Stuff
	//var/Gravity=gravmult+Planetgrav
	var/Tier=round(GravMastered/100)**3
	if(Tier<1) Tier=1
	if(GravMastered>1500) GravMod=1
	//Planet Grav...
	Planetgrav=1
	var/area/currentPlanet = src.GetArea()
	if(currentPlanet) Planet = currentPlanet.Planet
	switch(Planet)
		if("Sealed") Planetgrav=17 //Sealed Zone
		if("Hyperbolic Time Dimension")
			switch(z)
				if(13) Planetgrav=25 //HBTC
				if(15) Planetgrav=125 //HBTC
				if(16) Planetgrav=225 //HBTC
				if(17) Planetgrav=325 //HBTC
				if(18) Planetgrav=425 //HBTC
		if("Void") Planetgrav = GravMastered
		if("God Realm") Planetgrav = 500
		if("Earth") Planetgrav=1 //Earth
		if("Namek") Planetgrav=1 //Namek
		if("Vegeta") Planetgrav=10 //New Vegeta
		if("Icer Planet") Planetgrav=15 //Icer Planet ...
		if("Space") Planetgrav=0 //Space
		if("Heaven")
			Planetgrav=1 //Heaven
		if("Hera") Planetgrav=10 //Heran's world.
		if("Hell")
			Planetgrav=10 //Hell
		if("Afterlife") Planetgrav=1 //Afterlife
		if("Big Gete Star") Planetgrav=25 //Geti Star
		if("Arlia") Planetgrav=2 //Arlian Planet
		if("Makyo Star")
			if(prob(1)&&prob(1)) Planetgrav = rand(10,155)
		else Planetgrav=1
	regionalGains = 1
	if(in_Dungeon && BP < relBPmax)
		regionalGains = 1.5
		dungeonGains = 2.5
	else dungeonGains = 1
	if(Planet=="Makyo Star" && BP < relBPmax)
		regionalGains = 2.5
	if(Planet=="God Realm" && BP < relBPmax)
		regionalGains = 3

	//kaioshin/demon buffs
	if(Race=="Kai" && Planet == "Heaven") transBuff = 1.25
	else if(Race=="Demon" && Planet == "Hell") transBuff = 1.25
	else if(Race=="Demon"||Race=="Kai") transBuff = 1
	//
	Grav_Gain()



mob/var/tmp
	dungeonGains=1
obj/items/Gravity
	plane=MOB_LAYER+5
	SaveItem=1
	density=0
	cantblueprint=1
	stackable=0
	New()
		..()
		Grav = 0
		src.overlays.Cut()
		Ticker()
	proc/Ticker()
		set background = 1
		set waitfor = 0
		while(src)
			if(Grav>0)
				Energy-=Grav*0.01
				if(Energy<=0)
					Energy=0
					Grav=0
					src.overlays.Cut()
					for(var/obj/o in BB)
						var/list/nL = bounds(o)
						for(var/mob/M in nL)
							M.gravmult = 0
						BB -= o
						o.deleteMe()
					view(src)<<"<font color=red>[src]: Battery is completely drained. Shutting down..."

			else if(prob(NanoCore))
				Energy=MaxEnergy
				view(src)<<"[src]: Nanites activated. Energy fully restored. This feature will only work if the [src] is off."
			sleep(100)
	density=1
	desc="Place this anywhere on the ground to use it, it will affect anything within its radius."
	var/Max=10
	var/Grav=1
	var/Range=0
	var/Stability=0
	var/Efficiency=1
	var/Energy=1
	var/MaxEnergy=1
	var/NanoCore=0
	var/tmp/choosinggrav = 0
	icon='Scan Machine.dmi'
	verb/Info()
		set src in oview(1)
		set category=null
		usr<<"Field Strength: [Max]x"
		usr<<"Battery: [Energy*100] / [MaxEnergy*100]"
		usr<<"Field Range: [Range]"
		usr<<"Field Fluctuation Control: [Stability]"
		usr<<"Shutdown Protection: [Efficiency]"
		if(NanoCore) usr<<"Nanite Energy Regeneration: [NanoCore]"
		usr<<"Cost to make: [techcost]z"
	verb/Upgrade()
		set src in oview(1)
		set category=null
		thechoices
		if(usr.KO) return
		var/cost=0
		var/list/Choices=new/list
		Choices.Add("Cancel")
		if(usr.zenni>=5*Max) Choices.Add("Field Strength ([5*Max]z)")
		if(usr.zenni>=100*MaxEnergy) Choices.Add("Battery Life ([50*MaxEnergy]z)")
		if(usr.zenni>=500*(Range+1)&&Range<10) Choices.Add("Field Range ([500*(Range+1)]z)")
		if(usr.zenni>=500000&&Stability==0) Choices.Add("Field Fluctuation (500000z)")
		if(usr.zenni>=500*(NanoCore+1)&&usr.techskill>=6) Choices.Add("Nanite Regeneration ([500*(NanoCore+1)]z)")
		var/A=input("Upgrade what?") in Choices
		if(A=="Cancel") return
		if(A=="Field Strength ([5*Max]z)")
			if(Max>gravitycap)
				usr<<"You cannot upgrade this any further([gravitycap]."
			cost=5*Max
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			usr<<"Field Strength increased."
			Max=round(Max*1.2)
		if(A=="Battery Life ([50*(MaxEnergy)]z)")
			cost=50*MaxEnergy
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			usr<<"Battery expanded and recharged. [50*MaxEnergy]"
			MaxEnergy*=2
			Energy=MaxEnergy
		if(A=="Field Range ([500*(Range+1)]z)")
			cost=500*(Range+1)
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			usr<<"Field Range increased."
			Range+=1
		if(A=="Field Fluctuation (500000z)")
			cost=500000
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			usr<<"Field stabilized."
			Stability=1
		if(A=="Nanite Regeneration ([500*(NanoCore+1)]z)")
			cost=500*(NanoCore+1)
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			usr<<"Nano Regeneration increased."
			NanoCore+=1
		usr<<"Cost: [cost]z"
		usr.zenni-=cost
		tech+=1
		techcost+=cost
		goto thechoices
	Click()
		if(Energy<=0)
			usr<<"The machine has no battery left..."
			return
		if(!Bolted)
			usr<<"The machine has to be bolted."
			return
		var/inview
		for(var/mob/M in view(1,src)) if(M==usr)
			inview=1
			break
		if(inview)
			if(!choosinggrav)
				choosinggrav=1
				Grav=0
				src.overlays.Cut()
				view(src)<<"[src]: Gravity temporarily neutralized."
				for(var/obj/o in BB)
					var/list/nL = bounds(o)
					for(var/mob/M in nL)
						M.gravmult = 0
					BB -= o
					o.deleteMe()
				Grav=input(usr,"Current grav is [Grav]x. Range is [Range] meters. You can set the gravity multiplier by using this panel. Be aware that the level of gravity affects everyone in the room. Maxgrav is [Max]x. Current admin set maximum is [gravitycap]","",0) as num
				WriteToLog("rplog","[usr] sets gravity to [Grav]x    ([time2text(world.realtime,"Day DD hh:mm")])")
				view(src)<<"[src]: Gravity changing in <font color=gray>five seconds</font>."
				sleep(50)
				if(Grav>Max) Grav=Max
				if(Grav<0) Grav=0
				if(Grav>gravitycap)
					Grav = gravitycap
				if(!Grav)
					view(src)<<"<center>[usr] sets the Gravity multiplier set to <font color=white>normal.</font></center>"
				else
					view(src)<<"<center>[usr] sets the Gravity multiplier set to <font color=red>[Grav]x</font></center>"
					src.overlays.Cut()
					var/image/I=image('Gravity Field.dmi',layer=OBJ_LAYER)
					I.transform *= Range
					src.overlays.Add(I)
					sleep(5)
					bounding_box_create(loc,list(Range,Range))
				choosinggrav=0
	verb/Bolt()
		set category=null
		set src in oview(1)
		if(x&&y&&z&&!Bolted)
			switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
				if("Yes")
					view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
					Bolted=1
					boltersig=usr.signature
		else if(Bolted&&boltersig==usr.signature)
			switch(input("Unbolt?","",text) in list("Yes","No",))
				if("Yes")
					view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
					Bolted=0

	BBCross(boundbox,O)
		if(ismob(O))
			var/mob/M = O
			M.gravmult += Grav
		return TRUE

	BBUnCross(boundbox,O)
		if(ismob(O))
			var/mob/M = O
			M.gravmult -= Grav
		return TRUE


turf/var/gravity=0 //1x the normal Planet grav, which varies.

var/gravitycap = 500

mob/Admin3/verb/Gravity_Cap()
	set category = "Admin"
	gravitycap = input(usr,"Normal is 500.","",500) as num
