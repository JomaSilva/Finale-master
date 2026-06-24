/datum/skill/Enkumei
	skilltype = "Ki"
	name = "Enkumei"
	desc = "Probably one of the most forceful beams in the game, it has good max range and damage, and average everything else"
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/Enkumei/after_learn()
	assignverb(/mob/keyable/verb/Enkumei)
	savant<<"You can fire an Dark Fire wave!"

/datum/skill/Enkumei/before_forget()
	unassignverb(/mob/keyable/verb/Enkumei)
	savant<<"You've forgotten how to fire an Dark Fire wave!?"
datum/skill/Enkumei/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Enkumei)
	
mob/keyable/verb/Enkumei()
	set category = "Skills"
	var/kireq=22*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging)
			beaming=1
			charging=0
			usr.icon_state="Blast"
			forceicon='Enkumei.dmi'
			usr.emit_Sound('kamehameha_fire.wav')
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.emit_Sound('kame_charge.wav')
			forcestate="origin"
			canmove = 0
			lastbeamcost=kireq
			beamspeed=0.4
			wavemult=1.2
			bypass=1
			maxdistance=60
			if(usr.beamskill<30)
				canmove = 0
				lastbeamcost=kireq
				beamspeed=0.3
				powmod=2
				bypass=1
				maxdistance=40
				//canfight = 0
				charging=1
			else if(usr.beamskill<70)
				canmove = 0
				lastbeamcost=kireq*10
				beamspeed=0.3
				powmod=2.2
				bypass=1
				maxdistance=45
				//canfight = 0
				charging=1
			else if(usr.beamskill<100)
				canmove = 0
				lastbeamcost=kireq*20
				beamspeed=0.2
				powmod=2.4
				bypass=1
				maxdistance=45
				//canfight = 0
				charging=1
			else if(usr.beamskill==100)
				canmove = 0
				lastbeamcost=kireq*30
				beamspeed=0.3
				powmod=3
				wavemult=2
				bypass=1
				maxdistance=45
				//canfight = 0
				charging=1
			//canfight = 0
			charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"