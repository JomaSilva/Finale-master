/datum/skill/tree/demigod
	name="Demigod Racials"
	desc="Demigods have been the source of many things throughout history... fire, victory, strife. You are another one of these legendary figures."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Demigod")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/materialization,new/datum/skill/conjure,new/datum/skill/expand,new/datum/skill/RiftTeleport,\
	new/datum/skill/demon/soulabsorb,new/datum/skill/general/observe)
	var/hasdemitype =  0
	growbranches()
		if(hasdemitype == 1)
			disableskill(/datum/skill/tree/kai)
		..()
		return


/datum/skill/RiftTeleport
	skilltype="Ki"
	name="Rift Teleport"
	desc="Rip a hole in reality, and travel through it."
	tier=2
	enabled=1
	skillcost=2
	can_forget= FALSE
	common_sense = TRUE
	teacher=FALSE
	after_learn()
		savant << "You figured out how to tear open reality to travel places!"
		assignverb(/mob/keyable/verb/RiftTeleport)

	before_forget()
		savant <<"You've forgotten how to tear open reality!"
		unassignverb(/mob/keyable/verb/RiftTeleport)

	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/RiftTeleport)

mob/keyable/verb/RiftTeleport()
	set category="Skills"
	var/image/I=image(icon='Black Hole.dmi',icon_state="full")
	if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) return
	if(canfight&&!usr.med&&!usr.train&&usr.Ki>=usr.MaxKi&&usr.Planet!="Sealed"&&!usr.inteleport)
		view(6)<<"[usr] seems to be concentrating"
		var/choice = input("Where would you like to go? Your rift abilities only extend to the following places.", "", text) in list ("Earth", "Namek", "Vegeta", "Icer Planet", "Arconia", "Desert", "Arlia", "Large Space Station", "Small Space Station", "Afterlife", "Heaven", "Nevermind",)
		if(choice!="Nevermind")
			usr<<"Pick your target coordinates."
			var/xx=input("X Location?") as num
			var/yy=input("Y Location?") as num
			usr.Ki=0
			oview(usr)<<"[usr] disappears into a  rift that closes in on itself."
			spawn flick(I,usr)
			usr.inteleport=1
			sleep(10)
			GotoPlanet(choice)
			usr.loc=locate(xx,yy, usr.z)
			oview(usr)<<"[usr] appears out of a rift in time-space."
			usr.inteleport=0
		else return
	else usr<<"You need full ki and total concentration to use this."


/datum/skill/demigod/Elemental
	skilltype="Ki"
	icon='transformation.jpg'
	name="Elemental"
	desc="As a Demigod, you are what mortals would normally call a God. Whether or not that's the truth, is up to you. However, you are not considered as such for no reason. By choosing this, you augment your physical offense, and grant yourself a flexible powerup based on the element."
	tier=2
	enabled=1
	skillcost=1
	can_forget= FALSE
	common_sense = FALSE
	var/tmp/choosingtype=0
	after_learn()
		savant <<"The element that once rested inside of you... what was it called again?"
		assignverb(/mob/keyable/verb/Elemental)
		savant.demi_element_type = input(savant,"What is your basic Demigod type? The more complex it is, the more estoric the effect, but it's overall less effective.") in list("Fire","Earth","Air","Water","Lightning","Mud","Lava","Sand","Steam","Cloud")
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Elemental)
	effector()
		..()
		if(AscensionStarted && !savant.demi_true_type && !choosingtype)
			choosingtype=1
			savant.inAwindow = 1
			var/list/tlist = list()
			switch(savant.demi_element_type)
				if("Fire")
					savant.demi_true_type = "Hellfire"
				if("Earth")
					savant.demi_true_type = "Primordial"
				if("Air")
					savant.demi_true_type = "Atmosphere"
				if("Water")
					savant.demi_true_type = "Steel Ice"
				if("Lightning")
					tlist+= "Hellfire"
					tlist+= "Atmosphere"
				if("Mud")
					tlist+= "Primordial"
					tlist+= "Steel Ice"
				if("Lava")
					tlist+= "Hellfire"
					tlist+= "Primordial"
				if("Sand")
					tlist+= "Steel Ice"
					tlist+= "Primordial"
				if("Steam")
					tlist+= "Steel Ice"
					tlist+= "Hellfire"
				if("Cloud")
					tlist+= "Steel Ice"
					tlist+= "Atmosphere"
			if(tlist.len >= 1) savant.demi_true_type = input(savant,"Choose your ascension true elemental type. This will further your stats whenever your use the Elemental buff.") in tlist
			savant.inAwindow = 0
mob/var
	demi_element_type = "" //Can be: Fire, Earth, Air (wind), Water.
	demi_true_type = "" //Can be: Hellfire, Steel Ice, Atmosphere, Primordial.

mob/keyable/verb/Elemental()
	set category = "Skills"
	emit_Sound('chargeaura.wav')
	startbuff(/obj/buff/elemental)

obj/buff/elemental
	name = "Elemental"
	icon='transformation.jpg'
	slot=sAURA //which slot does this buff occupy
	var/lastForm=0
	Buff()
		lastForm=0
		switch(container.demi_element_type)
			if("Fire")
				container.Tphysoff += 1
				container << "The raw power of Fire increases the damage you do!"
			if("Earth")
				container.Tphysdef += 1
				container << "Earth's mighty rumble increases your defence..."
			if("Air")
				container.Tspeed += 1
				container << "The brisk pace of the Air around you makes you dance!"
			if("Water")
				container.Ttechnique += 1
				container << "Water's gentle and smoothing motions infuses yourself- you no longer fight, you flow."
			if("Lightning")
				container.Tphysoff += 0.5
				container.Tspeed += 0.5
				container << "Lightning's extreme heat flows into you with a <font color=#FF3333>shocking</font> passion!"
			if("Mud")
				container.Ttechnique += 0.5
				container.Tphysdef += 0.5
				container << "Mud does not submit to the mere elements. It may be the lowest... <b>but it is not the weakest.</b>"
			if("Lava")
				container.Tphysoff += 0.5
				container.Tphysdef += 0.5
				container << "You call to the Earth's scorching reserves... <i>and it voices back in approval.</i>"
			if("Sand")
				container.Tphysdef += 0.5
				container.Tspeed += 0.5
				container << "You shift, the sand around you becoming both a hard shell and a movement enabler."
			if("Steam")
				container.Tspeed += 0.5
				container.Ttechnique += 0.5
				container << "Steam's whispy and burning qualities emobolden your body."
			if("Cloud")
				container.Ttechnique += 0.5
				container.Tspeed += 0.5
				container << "The old elements often forget us. <b>We'll remind them why we're above them all.</b>"
		switch(container.demi_true_type)
			if("Hellfire")
				container.Tphysoff += 1
				container.Tkioff += 1
				container.aurasBuff = 1.5
				container << "Your scorching heat reaches the peak... <font color=#FF3333>The element of Fire refuses to let you fight alone!</font>!"
				oview(container) << "<font color=#FF3333>The element of Fire refuses to let [container] fight alone!</font>"
			if("Steel Ice")
				container.Ttechnique += 1
				container.Tkioff += 1
				container.aurasBuff = 1.5
				container << "Water's arctic touch lets you carve mountains like glaciers... <font color=#0B86F3>The element of Water refuses to let you fight alone!</font>"
				oview(container) << "<font color=#0B86F3>The element of Water refuses to let [container] fight alone!</font>"
			if("Atmosphere")
				container.Tspeed += 1
				container.Ttechnique += 1
				container.aurasBuff = 1.5
				container << "Air is all encompassing, it's bearing reassuring... <font color=#E0E0E0>The element of Air refuses to let you fight alone!</font>"
				oview(container) << "<font color=#E0E0E0>The element of Air refuses to let [container] fight alone!</font>"
			if("Primordial")
				container.Tphysdef += 1
				container.Tphysoff += 1
				container.aurasBuff = 1.5
				container << "The planet itself rumbles... The ground beneath your feet providing you extra ability... <font color=#70460E>The element of Earth refuses to let you fight alone!</font>"
				oview(container) << "<font color=#70460E>The element of Earth refuses to let [container] fight alone!</font>"
		..()
	Loop()
		if(!container.transing)
			if(container.stamina>=container.maxstamina*(0.001/container.Emagiskill))
				if(prob(20)) container.Ki-=(0.1/container.Emagiskill)*container.BaseDrain //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*(0.001/container.Emagiskill))
					DeBuff()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,0.01/container.Emagiskill) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
			else container.Revert()
		..()
	DeBuff()
		switch(container.demi_element_type)
			if("Fire")
				container.Tphysoff -= 1
			if("Earth")
				container.Tphysdef -= 1
			if("Air")
				container.Tspeed -= 1
			if("Water")
				container.Ttechnique -= 1
			if("Lightning")
				container.Tphysoff -= 0.5
				container.Tspeed -= 0.5
			if("Mud")
				container.Ttechnique -= 0.5
				container.Tphysdef -= 0.5
			if("Lava")
				container.Tphysoff -= 0.5
				container.Tphysdef -= 0.5
			if("Sand")
				container.Tphysdef -= 0.5
				container.Tspeed -= 0.5
			if("Steam")
				container.Tspeed -= 0.5
				container.Ttechnique -= 0.5
			if("Cloud")
				container.Ttechnique -= 0.5
				container.Tspeed -= 0.5
		switch(container.demi_true_type)
			if("Hellfire")
				container.Tphysoff -= 1
				container.Tkioff -= 1
				container.aurasBuff = 1
			if("Steel Ice")
				container.Ttechnique -= 1
				container.Tkioff -= 1
				container.aurasBuff = 1
			if("Atmosphere")
				container.Tspeed -= 1
				container.Ttechnique -= 1
				container.aurasBuff = 1
			if("Primordial")
				container.Tphysdef -= 1
				container.Tphysoff -= 1
				container.aurasBuff = 1
		..()