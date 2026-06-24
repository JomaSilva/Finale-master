/*/datum/skill/tree/Diffuse
	name = "Diffuse Ki"
	desc = "Spread it out.\nIncreased kioff, Decreased kiskill."
	maxtier = 3
	tier=2
	enabled=0
	constituentskills = list(new/datum/skill/ki/Solar_Flare,new/datum/skill/ki/Scattering_Bullet,new/datum/skill/multitasking,\
	new/datum/skill/rank/BusterBarrage)
	can_refund = TRUE

mob/var/bonusShots=0

/datum/skill/tree/Diffuse/mod()
	savant.kioffBuff+=0.3
	savant.kiskillBuff-=0.3
	..()
/datum/skill/tree/Diffuse/demod()
	savant.kioffBuff-=0.3
	savant.kiskillBuff+=0.3
	..()
*/
/datum/skill/ki/Solar_Flare
	skilltype = "Ki"
	name = "Solar Flare"
	desc = "The user learns to spread Ki violently in the form of light."
	level = 0
	expbarrier = 100
	maxlevel = 0
	can_forget = TRUE
	common_sense = TRUE
	skillcost=1
	prereqs = list()

datum/skill/ki/Solar_Flare/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Solar_Flare)

/datum/skill/ki/Solar_Flare/after_learn()
	savant << "You feel like you can use your Ki to generate light."
	assignverb(/mob/keyable/verb/Solar_Flare)

/datum/skill/ki/Solar_Flare/before_forget()
	savant << "You can't feel the light."
	unassignverb(/mob/keyable/verb/Solar_Flare)

/datum/skill/ki/Scattering_Bullet
	skilltype = "Ki"
	name = "Scattering Bullet"
	desc = "The user learns eject masses of Ki and redirect them towards their Target."
	level = 0
	expbarrier = 100
	maxlevel = 0
	can_forget = TRUE
	common_sense = TRUE
	skillcost=2
	prereqs = list()

datum/skill/ki/Scattering_Bullet/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Scattering_Bullet)

/datum/skill/ki/Scattering_Bullet/after_learn()
	savant << "You feel like you can use your Ki to generate light."
	assignverb(/mob/keyable/verb/Scattering_Bullet)

/datum/skill/ki/Scattering_Bullet/before_forget()
	savant << "You can't feel the light."
	unassignverb(/mob/keyable/verb/Scattering_Bullet)

/datum/skill/multitasking
	skilltype = "Mind Buff"
	name = "Multitasking"
	desc = "Your ability to maneuver more Ki at a time increases. KiOff+, Blast Number++"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/multitasking/after_learn()
	savant<<"You feel ready to handle more masses of Ki."
	savant.kioffBuff+=0.2
	savant.bonusShots+=2
/datum/skill/multitasking/before_forget()
	savant<<"You lose your concentration."
	savant.kioffBuff-=0.2
	savant.bonusShots-=2