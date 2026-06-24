/*
/datum/skill/tree/Introspection
	name = "Introspection"
	desc = "Learn to better channel your mind."
	maxtier = 3
	tier=1
	enabled=0
	constituentskills = list(new/datum/skill/GivePower,new/datum/skill/Telepathy,new/datum/skill/focusX,new/datum/skill/tactics)

/datum/skill/tree/Introspection/growbranches()
	if(invested>=3)allowedtier=2
	if(invested>=6)allowedtier=3
	..()
	return

/datum/skill/tree/Introspection/prunebranches()
	if(invested<6)allowedtier=2
	if(invested<3)allowedtier=1
	..()
	return
*/
/datum/skill/Telepathy
	skilltype = "Ki"
	name = "Telepathy"
	desc = "The user learns to read and speak to minds."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	maxlevel = 1
	tier = 2
	skillcost = 1

/datum/skill/Telepathy/after_learn()
	assignverb(/mob/keyable/verb/Telepathy)
	savant<<"You can talk to minds!"
/datum/skill/Telepathy/before_forget()
	unassignverb(/mob/keyable/verb/Telepathy)
	savant<<"You've forgotten how to read minds!?"
/datum/skill/Telepathy/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Telepathy)

/datum/skill/focusX
	skilltype = "Mind Buff"
	name = "Focus X"
	desc = "The user further intensifies their focus. KiOff+, P.Off+, KiSkill++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=0
	maxlevel = 1
	tier = 1
/datum/skill/focusX/after_learn()
	savant<<"You feel much more focused."
	savant.kioffBuff+=0.1
	savant.physoffBuff+=0.1
	savant.kiskillBuff+=0.3
/datum/skill/focusX/before_forget()
	savant<<"You feel less focused."
	savant.kioffBuff-=0.1
	savant.physoffBuff-=0.1
	savant.kiskillBuff-=0.3

/datum/skill/tactics
	skilltype = "Body Buff"
	name = "Tactics"
	desc = "The user leverages their increasing brainpower to reinforce their technique and resistance. Tech++, P.Def+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
/datum/skill/tactics/after_learn()
	savant<<"You feel prepared."
	savant.techniqueBuff+=0.3
	savant.physdefBuff+=0.2
/datum/skill/tactics/before_forget()
	savant<<"You feel unprepared."
	savant.techniqueBuff-=0.3
	savant.physdefBuff-=0.2

/*/datum/skill/GivePower
	skilltype = "Ki"
	name = "Give Power"
	desc = "The user learns to give power to others."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	maxlevel = 1
	tier = 1
	skillcost = 2

/datum/skill/GivePower/after_learn()
	savant.cangivepower=1
	savant<<"You have the ability to temporarily transfer your health and energy to others to boost their power. (by clicking them)"
/datum/skill/GivePower/before_forget()
	savant.cangivepower=0
	savant<<"You have forgone the ability to temporarily transfer your health and energy to others to boost their power."*/