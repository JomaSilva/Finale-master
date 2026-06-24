datum/skill/rank/GalicGun
	skilltype = "Ki Attack"
	name = "Royalty Wave - Galick Ho"
	desc = "A powerful Ki attack, in a beam form. This Ki attack prioritizes attack and minimizing drain. At it's best and most controlled, more like a extended arm of Ki, rather than a straight projectile."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

datum/skill/rank/GalicGun/after_learn()
	assignverb(/mob/keyable/verb/GalicGun)
	savant<<"You can use the Galick Gun!"

datum/skill/rank/GalicGun/before_forget()
	unassignverb(/mob/keyable/verb/GalicGun)
	savant<<"You've forgotten how to use the Galick Gun?"
datum/skill/rank/GalicGun/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/GalicGun)
mob/var/GalicGunicon='galacticgun.dmi'
mob/keyable/verb/GalicGun()
	set name = "Galick Gun"
	set category = "Skills"
	var/kireq=21*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			forceicon=GalicGunicon
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
			if(usr.beamskill<30)
				canmove = 0
				lastbeamcost=kireq*1.2
				beamspeed=0.3
				powmod=2.4
				bypass=1
				maxdistance=40
				//canfight = 0
				charging=1
			else if(usr.beamskill<70)
				canmove = 0
				lastbeamcost=kireq*12
				beamspeed=0.3
				powmod=2.6
				bypass=1
				maxdistance=45
				//canfight = 0
				charging=1
			else if(usr.beamskill<100)
				canmove = 0
				lastbeamcost=kireq*22
				beamspeed=0.3
				powmod=2.8
				bypass=1
				maxdistance=45
				//canfight = 0
				charging=1
			else if(usr.beamskill==100)
				canmove = 0
				lastbeamcost=kireq*30
				beamspeed=0.4
				powmod=3
				bypass=1
				maxdistance=50
				//canfight = 0
				charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"