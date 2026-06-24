datum/skill/rank/Makkankosappo
	skilltype = "Ki Attack"
	name = "Makkankosappo"
	desc = "A concentrated Ki attack, in a beam form. This Ki attack prioritizes pinpoint thrust and extremely fast speed. At it's best, it's a attack whose density is greater than a white dwarf star, yet no smaller than a penny."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=1
	enabled=1

datum/skill/rank/Makkankosappo/after_learn()
	assignverb(/mob/keyable/verb/Makkankosappo)
	savant<<"You can use Final Flash!"

datum/skill/rank/Makkankosappo/before_forget()
	unassignverb(/mob/keyable/verb/Makkankosappo)
	savant<<"You've forgotten how to use the Final Flash?"

datum/skill/rank/Makkankosappo/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Makkankosappo)
mob/var/Makkankoicon='Makkankosappo.dmi'