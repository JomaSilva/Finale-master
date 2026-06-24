/datum/skill/Erasure
	skilltype = "Ki"
	name = "Erasure Cannon"
	desc = "Has a decent damage output at great speed, but it's expensive and doesn't travel very far."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/Erasure/after_learn()
	assignverb(/mob/keyable/verb/Erasure)
	savant<<"You can fire an Erasure Cannon!"

/datum/skill/Erasure/before_forget()
	unassignverb(/mob/keyable/verb/Erasure)
	savant<<"You've forgotten how to fire an Erasure Cannon!?"
datum/skill/Erasure/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Erasure)
	
mob/keyable/verb/Erasure()
	set category = "Skills"
	var/kireq=23*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging)
			beaming=1
			charging=0
			usr.icon_state="Blast"
			forceicon='EraserCannon.dmi'
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
			maxdistance=45
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
				lastbeamcost=kireq*12
				beamspeed=0.3
				powmod=2.2
				bypass=1
				maxdistance=35
				//canfight = 0
				charging=1
			else if(usr.beamskill<100)
				canmove = 0
				lastbeamcost=kireq*22
				beamspeed=0.2
				powmod=2.4
				bypass=1
				maxdistance=30
				//canfight = 0
				charging=1
			else if(usr.beamskill==100)
				canmove = 0
				lastbeamcost=kireq*32
				beamspeed=0.3
				powmod=3
				wavemult=2.5
				bypass=1
				maxdistance=30
				//canfight = 0
				charging=1
			//canfight = 0
			charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"