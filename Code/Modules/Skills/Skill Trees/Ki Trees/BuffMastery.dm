/datum/skill/tree/kibuffmas
	name = "Ki Buff Mastery"
	desc = "Defensive Specialization"
	skilltype = null
	common_sense = FALSE
	tier=1
	allowedtier = 4
	maxtier = 4
	enabled = 0
	constituentskills = list(new/datum/skill/mind/Basic_Buff_Mastery,new/datum/skill/mind/Basic_Debuff_Mastery,\
	new/datum/skill/mind/Basic_Defense_Mastery,new/datum/skill/mind/Advanced_Buff_Mastery,new/datum/skill/mind/Advanced_Debuff_Mastery,\
	new/datum/skill/mind/Advanced_Defense_Mastery,new/datum/skill/mind/Perfect_Buff_Mastery,new/datum/skill/mind/Perfect_Debuff_Mastery,\
	new/datum/skill/mind/Perfect_Defense_Mastery)

/datum/skill/tree/effusionmas/growbranches()
	enableskill(/datum/skill/mind/Basic_Buff_Mastery)
	enableskill(/datum/skill/mind/Basic_Debuff_Mastery)
	enableskill(/datum/skill/mind/Basic_Defense_Mastery)
	..()

/datum/skill/tree/effusionmas/prunebranches()

	..()


/datum/skill/mind/Basic_Buff_Mastery
	skilltype = "Mind Buff"
	name = "Basic Buff Mastery"
	desc = "Improve your proficiency with ki-based buffs, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand ki-based buffs better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over ki-based buffs grows! Basic Buff Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kibuffskill+=1
			if(level == 100)
				savant.kibuffskill+=5
				enableskill(/datum/skill/mind/Advanced_Buff_Mastery)
		if(attackcounter<savant.kibuffcounter)
			exp+=KiSkillGains(10*(savant.kibuffcounter-attackcounter))
			attackcounter = savant.kibuffcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Basic_Debuff_Mastery
	skilltype = "Mind Buff"
	name = "Basic Debuff Mastery"
	desc = "Improve your proficiency with ki-based debuffs, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand ki-based debuffs better!"
		savant<<"You can now channel your ki into a blinding flash!"
		assignverb(/mob/keyable/verb/Solar_Flare)
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over ki-based debuffs grows! Basic Debuff Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kidebuffskill+=1
			if(level == 20)
				savant<<"You can now temporarily paralyze your opponent"
				assignverb(/mob/keyable/verb/Paralysis)
			if(level == 50)
				savant<<"You can now bind your opponent's legs with ki, slowing them"
				assignverb(/mob/keyable/verb/Shackle)
			if(level == 100)
				savant.kidebuffskill+=5
				enableskill(/datum/skill/mind/Advanced_Debuff_Mastery)
		if(attackcounter<savant.kidebuffcounter)
			exp+=KiSkillGains(80*(savant.kidebuffcounter-attackcounter))
			attackcounter = savant.kidebuffcounter
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Solar_Flare)
		if(level>=20)
			assignverb(/mob/keyable/verb/Paralysis)
		if(level>=50)
			assignverb(/mob/keyable/verb/Shackle)

/datum/skill/mind/Basic_Defense_Mastery
	skilltype = "Mind Buff"
	name = "Basic Defense Mastery"
	desc = "Improve your ability to defend against ki attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/defensecounter
	after_learn()
		savant<<"You think you understand defending against ki better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over defending against ki grows! Basic Defense Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kidefenseskill+=1
			if(level % 10 == 0)
				savant.kidefBuff+=0.1
			if(level == 10)
				savant<<"You can now create a shield of ki to defend against attacks!"
				assignverb(/mob/keyable/verb/Energy_Shield)
			if(level == 100)
				savant.kidefenseskill+=5
				enableskill(/datum/skill/mind/Advanced_Defense_Mastery)
		if(defensecounter<savant.kidefensecounter)
			exp+=KiSkillGains(20*(savant.kidefensecounter-defensecounter))
			defensecounter = savant.kidefensecounter
	login(var/mob/logger)
		..()
		if(level>=10)
			assignverb(/mob/keyable/verb/Energy_Shield)

/datum/skill/mind/Advanced_Buff_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Buff Mastery"
	desc = "Further improve your proficiency with ki-based buffs."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand ki-based buffs better!"
		attackcounter=savant.kibuffcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over ki-based buffs grows! Advanced Buff Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kibuffskill+=2
			if(level == 75)
				savant.kibuffskill+=5
			if(level == 100)
				savant.kibuffskill+=5
				enableskill(/datum/skill/mind/Perfect_Buff_Mastery)
		if(attackcounter<savant.kibuffcounter)
			exp+=KiSkillGains(10*(savant.kibuffcounter-attackcounter))
			attackcounter = savant.kibuffcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Debuff_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Debuff Mastery"
	desc = "Further improve your proficiency with ki-based debuffs."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand ki-based debuffs better!"
		attackcounter=savant.kidebuffcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over ki-based debuffs grows! Advanced Debuff Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kidebuffskill+=2
			if(level == 75)
				savant.kidebuffskill+=5
			if(level == 100)
				savant.kidebuffskill+=5
				enableskill(/datum/skill/mind/Perfect_Debuff_Mastery)
		if(attackcounter<savant.kidebuffcounter)
			exp+=KiSkillGains(80*(savant.kidebuffcounter-attackcounter))
			attackcounter = savant.kidebuffcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Defense_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Defense Mastery"
	desc = "Further improve your ability to defend against ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/defensecounter
	after_learn()
		savant<<"You understand defending against ki better!"
		defensecounter=savant.kidefensecounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over defending against ki grows! Advanced Defense Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kidefenseskill+=2
			if(level % 10 == 0)
				savant.kidefBuff+=0.1
			if(level == 75)
				savant.kidefenseskill+=5
			if(level == 100)
				savant.kidefenseskill+=5
				enableskill(/datum/skill/mind/Perfect_Defense_Mastery)
		if(defensecounter<savant.kidefensecounter)
			exp+=KiSkillGains(20*(savant.kidefensecounter-defensecounter))
			defensecounter = savant.kidefensecounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Buff_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Buff Mastery"
	desc = "Perfect your proficiency with ki-based buffs."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected ki-based buffs!"
		attackcounter=savant.kibuffcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over ki-based buffs grows! Perfect Buff Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kibuffskill+=1
			if(level == 75)
				savant.kibuffskill+=2
			if(level == 100)
				savant.kibuffskill+=3
		if(attackcounter<savant.kibuffcounter)
			exp+=KiSkillGains(10*(savant.kibuffcounter-attackcounter))
			attackcounter = savant.kibuffcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Debuff_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Debuff Mastery"
	desc = "Perfect your proficiency with ki-based debuffs."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected ki-based debuffs!"
		attackcounter=savant.kidebuffcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over ki-based debuffs grows! Perfect Debuff Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kidebuffskill+=1
			if(level == 75)
				savant.kidebuffskill+=2
			if(level == 100)
				savant.kidebuffskill+=3
		if(attackcounter<savant.kidebuffcounter)
			exp+=KiSkillGains(80*(savant.kidebuffcounter-attackcounter))
			attackcounter = savant.kidebuffcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Defense_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Defense Mastery"
	desc = "Perfect your ability to defend against ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/defensecounter
	after_learn()
		savant<<"You've perfected defending against ki!"
		defensecounter=savant.kidefensecounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over defending against ki grows! Perfect Defense Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kidefenseskill+=1
			if(level % 10 == 0)
				savant.kidefBuff+=0.15
				savant.kiarmor+=2.5
			if(level == 75)
				savant.kidefenseskill+=2
			if(level == 100)
				savant.kidefenseskill+=3
		if(defensecounter<savant.kidefensecounter)
			exp+=KiSkillGains(20*(savant.kidefensecounter-defensecounter))
			defensecounter = savant.kidefensecounter
	login(var/mob/logger)
		..()