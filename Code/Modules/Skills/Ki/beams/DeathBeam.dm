datum/skill/rank/Death_Beam
	skilltype = "Ki Attack"
	name = "Cruelity Origin - Death Beam"
	desc = "Like the Dodompa and the Makankosappo, focus on one specific point. However, the low drain, high speed, and high attack means this is perfect for killing."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

datum/skill/rank/Death_Beam/after_learn()
	assignverb(/mob/keyable/verb/Death_Beam)
	savant<<"You can use the Dodon Ray!"

datum/skill/rank/Death_Beam/before_forget()
	unassignverb(/mob/keyable/verb/Death_Beam)
	savant<<"You've forgotten how to use the Dodon Ray?"
datum/skill/rank/Death_Beam/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Death_Beam)
mob/var/DeathBeamicon='Makkankosappo3.dmi'
mob/keyable/verb/Death_Beam()
	set name = "Death Beam"
	set category = "Skills"
	var/kireq=21*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			forceicon=DeathBeamicon
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
			lastbeamcost=kireq*25
			beamspeed=0.3
			powmod=5
			bypass=1
			maxdistance=10
			//canfight = 0
			charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"