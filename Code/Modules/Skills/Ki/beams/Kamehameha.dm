datum/skill/rank/Kamehameha
	skilltype = "Ki Attack"
	name = "Turtle School - Kamehameha | Turtle Destruction Wave"
	desc = "A powerful Ki attack, in a beam form. This Ki attack prioritizes constant push and minimizing drain. At it's best and most controlled, more like a extended arm of Ki, rather than a straight projectile."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

datum/skill/rank/Kamehameha/after_learn()
	assignverb(/mob/keyable/verb/Kamehameha)
	var/type=rand(1,6)
	if(type==1) savant.Kamehamehaicon='Kamehameha1.dmi'
	if(type==2) savant.Kamehamehaicon='Kamehameha2.dmi'
	if(type==3) savant.Kamehamehaicon='Kamehameha3.dmi'
	if(type==4) savant.Kamehamehaicon='Kamehameha4.dmi'
	if(type==5) savant.Kamehamehaicon='Kamehameha5.dmi'
	if(type==6) savant.Kamehamehaicon='Kamehameha6.dmi'
	savant<<"You can use Kamehameha!"

datum/skill/rank/Kamehameha/before_forget()
	unassignverb(/mob/keyable/verb/Kamehameha)
	savant<<"You've forgotten how to use the Kamehameha?"
datum/skill/rank/Kamehameha/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Kamehameha)
mob/var/Kamehamehaicon='Kamehameha1.dmi'
mob/keyable/verb/Kamehameha()
	set category = "Skills"
	var/kireq=20*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			forceicon=Kamehamehaicon
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
				lastbeamcost=kireq
				beamspeed=0.4
				powmod=2.3
				bypass=1
				maxdistance=40
				//canfight = 0
				charging=1
			else if(usr.beamskill<70)
				canmove = 0
				lastbeamcost=kireq*10
				beamspeed=0.4
				powmod=2.5
				bypass=1
				maxdistance=45
				//canfight = 0
				charging=1
			else if(usr.beamskill<100)
				canmove = 0
				lastbeamcost=kireq*20
				beamspeed=0.4
				powmod=2.7
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
				maxdistance=45
				//canfight = 0
				charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"