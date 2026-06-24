/datum/skill/rank/Paralysis
	skilltype = "Ki"
	name = "Paralysis"
	desc = "This attack doesnt really do any damage unless the opponent is pretty weak, but if it makes contact it can paralyze the opponent for up to 60 seconds, it cannot be deflected or blocked but it is rather slow."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/rank/Paralysis/after_learn()
	assignverb(/mob/keyable/verb/Paralysis)
	savant<<"You can fire an [name]!"

/datum/skill/rank/Paralysis/before_forget()
	unassignverb(/mob/keyable/verb/Paralysis)
	savant<<"You've forgotten how to fire an [name]!?"
datum/skill/rank/Paralysis/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Paralysis)

mob/var/ParalysisIcon='KiHead.dmi'
