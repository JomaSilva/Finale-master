mob/var/effusion = 0
/*/datum/skill/tree/Rudeff
	name = "Rudimentary Effusion"
	desc = "Energy Projection. All offensive masteries."
	maxtier = 3
	tier=1
	enabled=0
	/*constituentskills = list(new/datum/skill/ki/EnergyShield,new/datum/skill/kidefense,new/datum/skill/deflection,new/datum/skill/peffusion,new/datum/skill/beffusion,new/datum/skill/spaceflight,new/datum/skill/Ki_Control/Planet_Destroy)*/
	constituentskills = list()
	can_refund = TRUE

mob/var/rudeffpb
mob/var/rudeffpbcheck

/datum/skill/tree/Rudeff/mod()
	savant.effusion=1
	..()
/datum/skill/tree/Rudeff/demod()
	savant.effusion=0
	..()
/datum/skill/tree/Rudeff/growbranches()
	/*if(invested>=3&&allowedtier<3)
		allowedtier=4
		enabletree(/datum/skill/tree/AdvEffusion)
	..()
	if(savant.rudeffpbcheck)
		savant.rudeffpbcheck=0
		if(savant.rudeffpb==0)
			whitelist(/datum/skill/peffusion)
			whitelist(/datum/skill/beffusion)
		if(savant.rudeffpb==1)
			blacklist(/datum/skill/beffusion)
		if(savant.rudeffpb==2)
			blacklist(/datum/skill/peffusion)
	return*/

/datum/skill/tree/Rudeff/prunebranches()
	..()
	return
	/*if(didchange&&invested<5)
		allowedtier=2
		disabletree(/datum/skill/tree/AdvEffusion)
	if(didchange&&invested<3)
		allowedtier=1
		disabletree(/datum/skill/tree/Focused)
		disabletree(/datum/skill/tree/Diffuse)
	..()
	return*/
*/
/*
/datum/skill/kidefense
	skilltype = "Ki Buff"
	name = "Ki Defense"
	desc = "The user learns some particulars on how to concentrate their Ki to protect their body. P.Def+, KiDef++"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/kidefense/after_learn()
	savant<<"You feel protected."
	savant.physdef+=0.1
	savant.kidef+=0.3
/datum/skill/kidefense/before_forget()
	savant<<"You feel frail."
	savant.physdef-=0.1
	savant.kidef-=0.3

/datum/skill/deflection
	skilltype = "Ki Buff"
	name = "Ki Deflection"
	desc = "The user gets a lot better at defending themselves from Ki attacks. KiDef++, KiSkill+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/deflection/after_learn()
	savant<<"You feel amped."
	savant.kidef+=0.4
	savant.kiskill+=0.05
/datum/skill/deflection/before_forget()
	savant<<"You feel frail."
	savant.kidef-=0.4
	savant.kiskill-=0.05

/datum/skill/peffusion
	skilltype = "Ki Buff"
	name = "Precise Effusion"
	desc = "The user leverages their raw power to amplify their skill. KiOff-, KiDef+, KiSkill++"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/peffusion/after_learn()
	savant<<"You feel careful."
	savant.kioff-=0.2
	savant.kidef+=0.15
	savant.kiskill+=0.3
	savant.rudeffpbcheck=1
	savant.rudeffpb=1

/datum/skill/peffusion/before_forget()
	savant<<"You feel more powerful, but something is missing..."
	savant.kioff+=0.2
	savant.kidef-=0.15
	savant.kiskill-=0.3
	savant.rudeffpbcheck=1
	savant.rudeffpb=0

/datum/skill/beffusion
	skilltype = "Ki Buff"
	name = "Brutal Effusion"
	desc = "The user leverages some of their precision to amplify their raw power. KiOff+++, KiSkill-"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/beffusion/after_learn()
	savant<<"You feel powerful."
	savant.kioff+=0.5
	savant.kiskill-=0.2
	savant.rudeffpbcheck=1
	savant.rudeffpb=2

/datum/skill/beffusion/before_forget()
	savant<<"You feel more steady, but something is missing..."
	savant.kioff-=0.5
	savant.kiskill+=0.2
	savant.rudeffpbcheck=1
	savant.rudeffpb=0*/

/datum/skill/ki/EnergyShield
	skilltype = "Ki"
	name = "Energy Shield"
	desc = "The user learns to gather their Ki into a shield."
	level = 0
	expbarrier = 100
	maxlevel = 0
	can_forget = TRUE
	common_sense = TRUE
	skillcost=1
	//prereqs = list(new/datum/skill/kidefense)
	var/tmp/accum=0
	enabled = 0
datum/skill/ki/EnergyShield/effector(var/mob/logger)
	..()
	if(savant.shielding)
		savant.kidefensecounter++
		accum++
		if(accum>=6)
			accum=0
			var/kireq=savant.shieldexpense*savant.BaseDrain
			if(savant.Ki>=kireq)
				if(savant.shieldexpense)
					savant.Ki-=kireq
			else savant.stopShield()

datum/skill/ki/EnergyShield/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Energy_Shield)

/datum/skill/ki/EnergyShield/after_learn()
	savant << "You feel like you can use your Ki to actively protect yourself."
	assignverb(/mob/keyable/verb/Energy_Shield)

/datum/skill/ki/EnergyShield/before_forget()
	savant << "You feel nervous without your shield."
	unassignverb(/mob/keyable/verb/Energy_Shield)

/datum/skill/PowerControl
	skilltype = "Ki"
	name = "Power Control"
	desc = "The user learns to control his power. In order to actively power up or down, you must be standing still."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	maxlevel = 1
	tier = 2
	skillcost = 1
/*
/datum/skill/PowerControl/after_learn()
	assignverb(/mob/keyable/verb/Power_Up)
	assignverb(/mob/keyable/verb/Power_Down)
	assignverb(/mob/keyable/verb/Conceal_Power)
	savant<<"You can control your power!"
/datum/skill/PowerControl/login()
	..()
	assignverb(/mob/keyable/verb/Power_Up)
	assignverb(/mob/keyable/verb/Power_Down)
	assignverb(/mob/keyable/verb/Conceal_Power)

/datum/skill/PowerControl/before_forget()
	unassignverb(/mob/keyable/verb/Power_Up)
	unassignverb(/mob/keyable/verb/Power_Down)
	unassignverb(/mob/keyable/verb/Conceal_Power)
	savant<<"You've forgotten how to control power!?"*/