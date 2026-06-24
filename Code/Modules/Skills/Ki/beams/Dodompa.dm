datum/skill/rank/Dodompa
	skilltype = "Ki Attack"
	name = "Crane School Dodompa - Dodon Ray"
	desc = "Technically more powerful than the Kamehameha, this attack is perfect for high damage and assassination."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

datum/skill/rank/Dodompa/after_learn()
	assignverb(/mob/keyable/verb/Dodompa)
	savant<<"You can use the Dodon Ray!"

datum/skill/rank/Dodompa/before_forget()
	unassignverb(/mob/keyable/verb/Dodompa)
	savant<<"You've forgotten how to use the Dodon Ray?"
datum/skill/rank/Dodompa/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Dodompa)
mob/keyable/verb/Dodompa()
	set name = "Dodon Ray"
	set category = "Skills"
	var/kireq=21*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			forceicon=Dodompaicon
			beaming=1
			charging=0
			usr.emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.emit_Sound('kame_charge.wav')
			forcestate="origin"
			chargedelay=5
			canmove = 0
			lastbeamcost=kireq*29
			beamspeed=0.6
			powmod=4
			bypass=1
			maxdistance=35
			//canfight = 0
			charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"