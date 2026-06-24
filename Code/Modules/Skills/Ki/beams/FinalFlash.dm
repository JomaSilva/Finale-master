datum/skill/rank/FinalFlash
	skilltype = "Ki Attack"
	name = "Final Flash"
	desc = "A powerful Ki attack, in a beam form. This Ki attack prioritizes constant jagged push and maximizing output. At it's best, it's a tsunami of Ki, obliterating foes much higher than the user's own strength."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=1
	enabled=1

datum/skill/rank/FinalFlash/after_learn()
	assignverb(/mob/keyable/verb/Final_Flash)
	savant<<"You can use Final Flash!"

datum/skill/rank/FinalFlash/before_forget()
	unassignverb(/mob/keyable/verb/Final_Flash)
	savant<<"You've forgotten how to use the Final Flash?"

datum/skill/rank/FinalFlash/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Final_Flash)
mob/var/FinalFlashicon='Beam - Big Fire.dmi'

mob/keyable/verb/Final_Flash()
	set category = "Skills"
	var/kireq=25*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging)
			beaming=1
			charging=0
			usr.icon_state="Blast"
			forceicon=FinalFlashicon
			usr.emit_Sound('basicbeam_fire.wav')
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.emit_Sound('basicbeam_chargeoriginal.wav')
			forcestate="origin"
			canmove = 0
			lastbeamcost=kireq
			beamspeed=0.6
			wavemult=4//makes the FinalFlash BP 4x greater than your own. Oof.
			bypass=1
			maxdistance=90
			if(usr.beamskill<30)
				canmove = 0
				lastbeamcost=kireq
				powmod=2.5
				bypass=1
				maxdistance=80
				//canfight = 0
				charging=1
			else if(usr.beamskill<70)
				canmove = 0
				lastbeamcost=kireq*10
				powmod=2.8
				bypass=1
				maxdistance=90
				//canfight = 0
				charging=1
			else if(usr.beamskill<100)
				canmove = 0
				lastbeamcost=kireq*20
				powmod=3
				bypass=1
				maxdistance=90
				//canfight = 0
				charging=1
			else if(usr.beamskill==100)
				canmove = 0
				lastbeamcost=kireq*30
				powmod=3.3
				bypass=1
				maxdistance=95
				//canfight = 0
				charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"