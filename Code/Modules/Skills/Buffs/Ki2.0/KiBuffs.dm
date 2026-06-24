mob/var/tmp
	kibuffon = 0
	focuson = 0
	efficiencyon = 0
	initdrain = 0
	initbuff = 0

mob/keyable/verb/Focus()
	set category = "Skills"
	desc = "Focus on the circulation of your ki, increasing both your power and your drain."
	if(!isBuffed(/obj/buff/Focus)&&!usr.KO)
		usr<<"You focus on your ki circulation."
		usr.startbuff(/obj/buff/Focus)
	else if(isBuffed(/obj/buff/Focus))
		usr<<"You let your mind drift."
		usr.stopbuff(/obj/buff/Focus)

/obj/buff/Focus
	name = "Focus"
	slot=sBUFF
	Buff()
		..()
		emit_Sound('1aura.wav')
		container.initdrain = 1+(container.kicirculationskill+container.kibuffskill)/100
		container.initbuff = 1+(container.kicirculationskill+container.kibuffskill)/100
		container.DrainMod*=container.initdrain
		container.Tkioff+=container.initbuff
		container.kibuffon=1
	DeBuff()
		container.DrainMod/=container.initdrain
		container.Tkioff-=container.initbuff
		container.kibuffon=0
		..()

mob/keyable/verb/Efficiency()
	set category = "Skills"
	desc = "Attempt to restrict your ki expenditure, becoming much more efficient but suffering a power reduction."
	if(!isBuffed(/obj/buff/Efficiency)&&!usr.KO)
		usr<<"You limit your ki expenditure."
		usr.efficiencyon=1
		usr.startbuff(/obj/buff/Efficiency)
	else if(isBuffed(/obj/buff/Efficiency))
		usr<<"You stop limiting your ki expenditure."
		usr.efficiencyon=0
		usr.stopbuff(/obj/buff/Efficiency)

/obj/buff/Efficiency
	name = "Efficiency"
	slot=sBUFF
	Buff()
		..()
		emit_Sound('1aura.wav')
		container.initdrain = 2+(container.kiefficiencyskill)/200
		container.initbuff = 0.5-(container.kibuffskill)/200
		container.DrainMod/=container.initdrain
		container.Tkioff-=container.initbuff
		container.kibuffon=1
	DeBuff()
		container.DrainMod*=container.initdrain
		container.Tkioff+=container.initbuff
		container.kibuffon=0
		..()

mob/var/shieldstorage
mob/var/shieldbuffamnt
mob/var/shielding=0
/mob/keyable/verb/Energy_Shield()
	set category = "Skills"
	if(shielding && !isBuffed(/obj/buff/Shield)) stopShield() //legacy protections
	else if(shielding)
		stopbuff(/obj/buff/Shield)
	else
		var/kireq=0.01*MaxKi*(1/kidefenseskill)*BaseDrain
		if(canfight&&!charging&&!shielding&&Ki>=kireq)
			startbuff(/obj/buff/Shield)
mob/proc/stopShield()
	Tkidef=max(Tkidef - shieldbuffamnt,1)
	superkiarmor=max(superkiarmor - shieldstorage,0)
	shieldstorage=0
	shielding=0
	sleep(5)
	removeOverlay(/obj/overlay/effects/shield)
mob/var/shieldexpense

/obj/buff/Shield
	name = "Shield"
	slot=sBUFF
	Buff()
		..()
		emit_Sound('1aura.wav')
		container.shieldbuffamnt=1.1*max(1.1,container.Ekiskill/3)*(1 + (container.kidefenseskill/100))
		container.Tkidef+=container.shieldbuffamnt
		container.shieldstorage=(container.Ekiskill/2.5)+(container.kidefenseskill/35)
		container.superkiarmor+=container.shieldstorage
		container.superkiarmorMod *= 1.2
		container.shielding=1
		container.updateOverlay(/obj/overlay/effects/shield,,container.blastR,container.blastG,container.blastB)
		container.kibuffon=1
	Loop()
		var/kireq=(1/container.kidefenseskill)*container.BaseDrain + 1
		if(container.canfight && !container.charging && container.Ki>=kireq && !container.KO && container.superkiarmor)
			container.Ki -= kireq
		else DeBuff()
	DeBuff()
		container.Tkidef -= container.shieldbuffamnt
		container.superkiarmor-=container.shieldstorage
		container.shieldstorage=0
		container.shielding=0
		container.superkiarmorMod /= 1.2
		container.removeOverlay(/obj/overlay/effects/shield)
		container.kibuffon=0
		..()