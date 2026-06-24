/datum/skill/GivePower
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
	assignverb(/mob/keyable/verb/Give_Power)
	savant<<"You have the ability to temporarily transfer your health and energy to others to boost their power."
/datum/skill/GivePower/before_forget()
	savant.cangivepower=0
	unassignverb(/mob/keyable/verb/Give_Power)
	savant<<"You have forgone the ability to temporarily transfer your health and energy to others to boost their power."

/datum/skill/GivePower/login()
	..()
	assignverb(/mob/keyable/verb/Give_Power)

mob/var/tmp
	gavepower
	givingpower = 0
mob/keyable/verb/Give_Power()
	set category = "Skills"
	if(givingpower)
		givingpower = 0
		return
	var/mob/M
	if(target) M = target
	else M = input(usr, "Select a player or pet.") in oview(5)
	if(usr.cangivepower&&!usr.KO&&!gavepower) if(M.client || istype(M,/mob/npc/pet))
		givingpower=1
		view(usr,12)<<"[usr] transfers their energy to [M]!!"
		usr.gavepower=100
		var/gaveamount = 0
		while(givingpower && Ki >= 0.01*MaxKi)
			M.Ki+=usr.MaxKi*0.01
			Ki-=usr.MaxKi*0.01
			gaveamount++
			M.SpreadHeal(1)
			missile('Spirit.dmi',src,M)
			CooldownAmount += M.MaxKi / usr.MaxKi
			sleep(2)
		if(M.client && gaveamount >= 10)
			M.got_power_count[M] = world.time
			M.count_got_power()
		spawn usr.KO()
		givingpower=0