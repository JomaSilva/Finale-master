/*/datum/skill/tree/Focused
	name = "Focused Ki"
	desc = "Pull it together.\nIncreased kiskill, Decreased kioff."
	maxtier = 3
	tier=2
	enabled=0
	allowedtier=2
	//constituentskills = list(new/datum/skill/ki/Ki_Wave,new/datum/skill/CustomAttacks/ki/beam/Beam,new/datum/skill/ki/kienzan,new/datum/skill/ki/Boom_Wave,new/datum/skill/ki/Galick_Gun,new/datum/skill/bfocus,new/datum/skill/powerhouse)
	can_refund = TRUE
/datum/skill/tree/Focused/mod()
	savant.kioffBuff-=0.3
	savant.kiskillBuff+=0.3
	..()
/datum/skill/tree/Focused/demod()
	savant.kioffBuff+=0.3
	savant.kiskillBuff-=0.3
	..()

/datum/skill/tree/Focused/effector()
	..() //don't banic, i moved the beam checker effectively to beams.dm (under its own proc),
	//as shit like kamehameha and etc which are rank only skills wouldn't work once properly ported.
*/

/datum/skill/bfocus
	skilltype = "Mind Buff"
	name = "Brutal Focus"
	desc = "The user turns their focus into a weapon. KiSkill++"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/bfocus/after_learn()
	savant<<"You could channel your ki down to a needlepoint if you felt like it."
	savant.kiskillBuff+=0.3
/datum/skill/bfocus/before_forget()
	savant<<"You lose a bit of focus."
	savant.kiskillBuff-=0.3

/datum/skill/powerhouse
	skilltype = "Mind Buff"
	name = "Powerhouse"
	desc = "The user leverages a bit of their precision back into raw Ki power with great effect. KiOff++, KiSkill-"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/powerhouse/after_learn()
	savant<<"You begin to magnify your ki projection."
	savant.kioffBuff+=0.3
	savant.kiskillBuff-=0.1
/datum/skill/powerhouse/before_forget()
	savant<<"You regain a bit of focus."
	savant.kioffBuff-=0.3
	savant.kiskillBuff+=0.1

