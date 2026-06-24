/datum/skill/tree/Mind
	name = "Strength of Mind"
	desc = "General Mental Ability"
	maxtier = 10
	allowedtier = 10//we'll handle skill enabling within individual skills, tiers are for display purposes here
	tier=0
	constituentskills = list(new/datum/skill/mind/Ki_Unlocked,new/datum/skill/mind/Basic_Ki_Awareness,new/datum/skill/mind/Basic_Ki_Circulation,\
	new/datum/skill/mind/Basic_Ki_Control,new/datum/skill/mind/Basic_Ki_Efficiency,\
	new/datum/skill/mind/Basic_Ki_Gathering, new/datum/skill/mind/Advanced_Ki_Awareness,new/datum/skill/mind/Advanced_Ki_Circulation,\
	new/datum/skill/mind/Advanced_Ki_Control,new/datum/skill/mind/Advanced_Ki_Efficiency,new/datum/skill/mind/Advanced_Ki_Gathering,\
	new/datum/skill/mind/Advanced_Targeted_Mastery,new/datum/skill/mind/Perfect_Ki_Awareness,new/datum/skill/mind/Perfect_Ki_Circulation,\
	new/datum/skill/mind/Perfect_Ki_Control,new/datum/skill/mind/Perfect_Ki_Efficiency,new/datum/skill/mind/Perfect_Ki_Gathering)

/datum/skill/tree/Mind/growbranches()
	if(savant.kiawarenessskill>=1)
		enableskill(/datum/skill/mind/Basic_Ki_Awareness)
	if(savant.kieffusionskill>=1)
		enabletree(/datum/skill/tree/effusionmas)
	if(savant.kicirculationskill>=1)
		enableskill(/datum/skill/mind/Basic_Ki_Circulation)
	if(savant.kicontrolskill>=5)
		enableskill(/datum/skill/mind/Basic_Ki_Control)
	if(savant.kiefficiencyskill>=5)
		enableskill(/datum/skill/mind/Basic_Ki_Efficiency)
	if(savant.kigatheringskill>=5)
		enableskill(/datum/skill/mind/Basic_Ki_Gathering)
		//enable blast, beam, and kiai trees
	if(savant.kibuffskill>=1)
		enabletree(/datum/skill/tree/kibuffmas)
		//enable ki buff, defense, and debuff skills
	..()
	return

/datum/skill/tree/Mind/prunebranches()//there shouldn't be a reason to prune skills here, but you never know...
	..()
	return

/datum/skill/mind
	var/expbuffer = 0//stored exp from study other
	var/ptree = /datum/skill/tree/Mind
	effector()
		..()
		sleep(1)
		if(savant && (savant.IsInFight || savant.med || savant.train) && prob(10) && !savant.afk)
			if(expbuffer <= 100 * GlobalKiExpRate) expbuffer++ //bonus gains when doing something, but isn't immediate.
		//also before levelup to not screw it up.
		if(levelup)
			expbuffer = 0
	proc/enableskill(var/datum/skill/S)
		for(var/datum/skill/tree/T in savant.possessed_trees)
			if(T.type == ptree)
				for(var/datum/skill/nS in T.constituentskills)
					if(nS.type==S)
						if(!nS.enabled) savant<<"You can now learn [nS.name]!"
						nS.enabled=1
	proc/disableskill(var/datum/skill/S)
		for(var/datum/skill/tree/T in savant.possessed_trees)
			if(T.type == ptree)
				for(var/datum/skill/nS in T.constituentskills)
					if(nS.type==S)
						if(nS.enabled) savant<<"You can no longer learn [nS.name]!"
						nS.enabled=0

//Basic Mastery Block
/datum/skill/mind/Ki_Unlocked//this skill is the basis for all other ki skills, it gives the foundations to use ki
	skilltype = "Mind Buff"
	name = "Ki Unlocked"
	desc = "You begin to truly feel around you. The energy of life courses through the trees, water, and grass. And it flows through you too. Acquire this skill to begin your journey to ki mastery."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 0
	after_learn()
		savant<<"It flows through you. You will never forget this experience, and you don't think you can. Akin to surfacing for air after nearly drowning, this feeling permates through your body."
		savant<<"You can now write your knowledge of ki skills down for others to read."
		savant.KiUnlockPercent=1
		savant.MeditateGivesKiRegen=1
		assignverb(/mob/keyable/verb/Write_Teachings)
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel your ki flowing within you! Ki Unlocked is now level [level]!"
			/*if(savant.MaxKi < 300/savant.KiMod) expbarrier=(5000*1.03**(level+(300/(savant.MaxKi*savant.KiMod))))//general formula for leveling curve
			else */
			expbarrier=(5000*1.03**level)
			//will be togglable in the future
			//king - issue where Ki can be frequent & easy really earlygame, evaluate this shit to a better sol'n
			//
			if(level % 5 == 0)//is the level an even multiple of 5?
				savant.kiawarenessskill+=1
				savant.kigatheringskill+=0.5
			if(level % 10 == 0)
				savant.kicontrolskill+=0.5
				savant.kiefficiencyskill+=0.5
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.2)//totals up to a whole point of KiMod at mastery
				savant.kiskillBuff+=0.1//0.5 points of ki skill, or 5 displayed
			if(level == 5)//mastery breakpoints, you can allow unique behavior such as granting skills, beyond the default levelup bonuses
				savant << "You feel a bizarre presence near you...it seems to be coming from other nearby living beings. What is this sensation?"
				var/datum/skill/A = new/datum/skill/sense
				A.learn(savant, 1)
			if(level == 10)//learn basic kiai
				savant<<"You feel as if you can force your ki out of your body, like a blast of air. You have learned the basic Kiai!"
				assignverb(/mob/keyable/verb/Kiai)
			if(level == 30)//learn flight
				var/datum/skill/A = new/datum/skill/flying
				A.learn(savant, 0)
			if(level == 35)
				savant<<"You've learned to expel your ki into a damaging sphere. You have learned the basic Blast!"
				assignverb(/mob/keyable/verb/Basic_Blast)
				savant.kieffusionskill+=1
			if(level == 50)
				savant<<"You've learned a advanced form of training! You can create little targets made out of Ki, and then shoot at them!"
				assignverb(/mob/keyable/verb/Ki_Targets)
			if(level == 75)//boost to ki regen and ki mod
				savant.kiregenMod+=0.30
				savant.genome.add_to_stat("Energy Level",0.2)
				savant.kicirculationskill+=1
			if(level == 100)//capstone boost to ki regen, ki mod, and ki skill
				savant.kiregenMod+=0.50
				savant.genome.add_to_stat("Energy Level",0.3)
				savant.kiskillBuff+=0.2
		if(!savant.med&&!savant.flight)
			exp+=KiSkillGains(1)
		if(savant.med)
			exp+=KiSkillGains(2)
		if(savant.flight)
			exp+=KiSkillGains(2)
		if(savant.kibuffon)
			savant.kibuffcounter+=1
		maxlevel = min(100,round(savant.BP/2))
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Write_Teachings)
		if(level >= 10)
			assignverb(/mob/keyable/verb/Kiai)
		if(level >= 35)
			if(savant.kieffusionskill<1)
				savant.kieffusionskill+=1
			assignverb(/mob/keyable/verb/Basic_Blast)
		if(level >= 50)
			assignverb(/mob/keyable/verb/Ki_Targets)

/datum/skill/mind/Basic_Ki_Awareness//more boosts for meditating, useful to gain sufficient ki control for more advanced skills
	skilltype = "Mind Buff"
	name = "Basic Ki Awareness"
	desc = "You have learned to detect the energy of other living beings. This is the path to harnessing that ability."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 1
	enabled = 0//anything after Ki Unlocked has prerequisites to meet
	after_learn()
		savant<<"You realize that the boundaries to your sensing could be limitless!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel the ki around you! Basic Ki Awareness is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kiawarenessskill+=1
			if(level % 10 == 0)
				savant.kicontrolskill+=1
			if(level % 20 == 0)
				savant.kiskillBuff+=0.05
			if(level == 10)
				savant<<"You've learned to sense how others are using their ki. You could learn something from them."
				assignverb(/mob/keyable/verb/Study_Other)
				assignverb(/mob/keyable/verb/Focus_Skill)
			if(level == 50)
				savant<<"You feel aware enough to judge someone else's ki skill."
				assignverb(/mob/keyable/verb/Assess_Ki_Skill)
				savant.kicontrolskill+=1
			if(level == 75)
				savant.kicontrolskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 100)
				savant.kicontrolskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
				enableskill(/datum/skill/mind/Advanced_Ki_Awareness)
		if(savant.studying)
			exp+=KiSkillGains(2)
		if(level<10&&savant.med)
			exp+=KiSkillGains(2)
		else
			exp+=KiSkillGains(1)
	login(var/mob/logger)
		..()
		if(level>=10)
			assignverb(/mob/keyable/verb/Study_Other)
			assignverb(/mob/keyable/verb/Focus_Skill)
		if(level>=50)
			assignverb(/mob/keyable/verb/Assess_Ki_Skill)

/datum/skill/mind/Basic_Ki_Circulation
	skilltype = "Mind Buff"
	name = "Basic Ki Circulation"
	desc = "You have learned to channel ki within yourself to increase your power. This is the path to harnessing that skill."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 1
	enabled = 0
	after_learn()
		savant<<"You start to truly feel the ki flow within you!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel the ki within you! Basic Ki Circulation is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kicirculationskill+=1
			if(level % 10 == 0)
				savant.kicontrolskill+=0.5
				savant.kidefBuff+=0.05
			if(level % 20 == 0)
				savant.willpowerMod+=0.01
				savant.speedBuff+=0.1
			if(level == 30)//learn Focus buff
				savant<<"You have learned to focus on your ki circulation, making greater amounts available at once!"
				savant<<"You feel like simply meditating can teach you nothing more"
				assignverb(/mob/keyable/verb/Focus)
				savant.kibuffskill+=1
			if(level == 50)
				savant.kicirculationskill+=1
			if(level == 75)
				savant.kicirculationskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 100)
				savant.kicirculationskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
				enableskill(/datum/skill/mind/Advanced_Ki_Circulation)
		if(level<30&&savant.med)
			exp+=KiSkillGains(2)
		else if(savant.kibuffon)
			exp+=KiSkillGains(2)
		else
			exp+=KiSkillGains(1)
	login(var/mob/logger)
		..()
		if(level >= 30)
			assignverb(/mob/keyable/verb/Focus)

/datum/skill/mind/Basic_Ki_Control
	skilltype = "Mind Buff"
	name = "Basic Ki Control"
	desc = "You have learned to direct your ki with greater control. This is the path to harnessing that skill."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 1
	enabled = 0
	after_learn()
		savant<<"You start to bend your ki to your will!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel greater control of your ki! Basic Ki Control is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kicontrolskill+=1
			if(level % 10 == 0)
				savant.kieffusionskill+=0.5
				savant.kiskillBuff+=0.05
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.01)
			if(level == 5)//learn Power Control
				savant<<"You have learned to control your ki, allowing you to increase your power! (Press C to charge.)"
				savant.canPower = 1
				assignverb(/mob/keyable/verb/Power_Control)
				assignverb(/mob/keyable/verb/Conceal_Power)
				savant.kigatheringskill+=5
			if(level == 30)
				savant<<"You feel as though you can create a guided blast!"
				assignverb(/mob/keyable/verb/Guided_Ball)
				savant.guidedskill+=1
			if(level == 50)
				savant<<"You can now surround a target with blasts! You've learned the Ki Bomb!"
				assignverb(/mob/keyable/verb/Ki_Bomb)
				savant.targetedskill+=1
				savant.kicontrolskill+=1
			if(level == 75)
				savant.kicontrolskill+=2
				savant.kiskillBuff+=0.1
			if(level == 100)
				savant.kicontrolskill+=2
				savant.kiskillBuff+=0.15
				enableskill(/datum/skill/mind/Advanced_Ki_Control)
		if(level<5)
			if(savant.med)
				exp+=KiSkillGains(2)
			else
				exp+=KiSkillGains(1)
		else if(savant.kiratio>1)
			exp+=KiSkillGains(1*savant.kiratio)
	login(var/mob/logger)
		..()
		if(level >= 5)
			logger.canPower = 1
			assignverb(/mob/keyable/verb/Power_Control)
			assignverb(/mob/keyable/verb/Conceal_Power)
		if(level >=30)
			assignverb(/mob/keyable/verb/Guided_Ball)
		if(level>=50)
			assignverb(/mob/keyable/verb/Ki_Bomb)

/datum/skill/mind/Basic_Ki_Efficiency
	skilltype = "Mind Buff"
	name = "Basic Ki Efficiency"
	desc = "You have begun to efficiently channel your ki. This is the path to harnessing that skill."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 1
	enabled = 0
	var/tmp/lastki=0
	var/tmp/diffki=0
	after_learn()
		savant<<"You become more efficient in your ki usage!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel more efficient with your ki! Basic Ki Efficiency is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kiefficiencyskill+=1
				savant.kiarmor += 1
			if(level % 10 == 0)
				savant.kigatheringskill+=0.5
				savant.kiskillBuff+=0.01
			if(level % 20 == 0)
				savant.kicontrolskill+=1
			if(level == 30)//learn Efficiency
				savant<<"You have learned to control your ki, allowing you to increase your efficiency!"
				assignverb(/mob/keyable/verb/Efficiency)
				savant.kigatheringskill+=2
				savant.kibuffskill+=1
			if(level == 50)
				savant.genome.add_to_stat("Energy Level",0.01)
			if(level == 75)
				savant.kiefficiencyskill+=2
				savant.kidefBuff+=0.1
			if(level == 100)
				savant.kiefficiencyskill+=2
				savant.kiskillBuff+=0.15
				savant.kioffBuff+=0.2
				enableskill(/datum/skill/mind/Advanced_Ki_Efficiency)
		diffki=(savant.Ki-lastki)
		if(savant.Ki!=lastki&&diffki<0)
			exp+=KiSkillGains(3)
		lastki=savant.Ki
	login(var/mob/logger)
		..()
		if(level >= 30)
			assignverb(/mob/keyable/verb/Efficiency)

/datum/skill/mind/Basic_Ki_Gathering
	skilltype = "Mind Buff"
	name = "Basic Ki Gathering"
	desc = "You have learned to better muster your ki when your reserves run low. This is the path to harnessing that skill."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 1
	enabled = 0
	after_learn()
		savant<<"You feel a wellspring of ki within you!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel your ki welling within you! Basic Ki Gathering is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kigatheringskill+=1
			if(level % 10 == 0)
				savant.kiefficiencyskill+=0.5
				savant.kidefBuff+=0.05
			if(level % 20 == 0)
				savant.willpowerMod+=0.01
				savant.kicontrolskill+=1
			if(level == 30)
				savant.kioffBuff+=0.1
			if(level == 50)
				savant.kigatheringskill+=1
				savant.kidefBuff+=0.1
			if(level == 75)
				savant.kigatheringskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 100)
				savant.kigatheringskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
				enableskill(/datum/skill/mind/Advanced_Ki_Gathering)
		if((savant.Ki/savant.MaxKi)<0.9)
			exp+=KiSkillGains(3*(2-(savant.Ki/savant.MaxKi)))
		else if(savant.deepmeditation)
			exp+=KiSkillGains(2)

//Advanced Mastery Block
/datum/skill/mind/Advanced_Ki_Awareness
	skilltype = "Mind Buff"
	name = "Advanced Ki Awareness"
	desc = "Further improve your ability to detect the energy of other living beings."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 3
	enabled = 0//anything after Ki Unlocked has prerequisites to meet
	after_learn()
		savant<<"You are becoming adept at sensing energy!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You truly feel the ki around you! Advanced Ki Awareness is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kiawarenessskill+=2
			if(level % 10 == 0)
				savant.speedBuff+=0.05
			if(level % 20 == 0)
				savant.kiskillBuff+=0.1
				savant.kidefBuff+=0.05
			if(level == 10)
				savant<<"You've learned to communicate directly with others using your ki."
				assignverb(/mob/keyable/verb/Telepathy)
			if(level == 50)
				savant<<"You feel as though you can pinpoint someone's ki and sense their environment."
				assignverb(/mob/keyable/verb/Observe)
			if(level == 75)
				savant.genome.add_to_stat("Energy Level",0.1)
				savant.kiskillBuff+=0.25
				savant.kiawarenessskill+=5
			if(level == 100)
				savant.genome.add_to_stat("Energy Level",0.1)
				savant.kiskillBuff+=0.25
				savant.kidefBuff+=0.1
				savant.kiawarenessskill+=5
				enableskill(/datum/skill/mind/Perfect_Ki_Awareness)
		if(savant.studying)
			exp+=KiSkillGains(2)
		if(savant.observingnow)
			exp+=KiSkillGains(3)
		else
			exp+=KiSkillGains(1)
	login(var/mob/logger)
		..()
		if(level>=10)
			assignverb(/mob/keyable/verb/Telepathy)
		if(level>=50)
			assignverb(/mob/keyable/verb/Observe)

mob/var/effusionspecial=0//opens the Effusive Specialty tree

mob/var/buffregen=0//ki buffs will speedBuff natural healing

/datum/skill/mind/Advanced_Ki_Circulation
	skilltype = "Mind Buff"
	name = "Advanced Ki Circulation"
	desc = "Further master circulating ki to improve your power."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 3
	enabled = 0
	after_learn()
		savant<<"Your ki flows almost effortlessly within you!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You truly feel the ki within you! Advanced Ki Circulation is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kicirculationskill+=2
			if(level % 10 == 0)
				savant.kidefBuff+=0.1
			if(level % 20 == 0)
				savant.willpowerMod+=0.05
				savant.speedBuff+=0.1
			if(level == 30)
				savant<<"Your ability to circulate ki now improves your regeneration while you have a ki buff on!"
				savant.buffregen=1
			if(level == 50)
				savant.kidefBuff+=0.5
			if(level == 75)
				savant.kicirculationskill+=5
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 100)
				savant.kicirculationskill+=5
				savant.genome.add_to_stat("Energy Level",0.05)
				enableskill(/datum/skill/mind/Perfect_Ki_Circulation)
		if(savant.kibuffon)
			//savant.kibuffcounter+=1
			exp+=KiSkillGains(2)
			if(savant.buffregen)
				savant.SpreadHeal(0.01)
		else
			exp+=KiSkillGains(1)
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Ki_Control
	skilltype = "Mind Buff"
	name = "Advanced Ki Control"
	desc = "Further improve your ability to direct your ki."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 3
	enabled = 0
	after_learn()
		savant<<"You skillfully bend your ki to your will!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel deep control of your ki! Advanced Ki Control is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kicontrolskill+=2
			if(level % 10 == 0)
				savant.kiskillBuff+=0.1
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 50)
				savant.kioffBuff+=0.1
				savant.kidefBuff+=0.1
			if(level == 75)
				savant.kicontrolskill+=5
				savant.kiskillBuff+=0.2
			if(level == 100)
				savant.kicontrolskill+=5
				savant.kiskillBuff+=0.3
				enableskill(/datum/skill/mind/Perfect_Ki_Control)
		if(savant.kiratio>1)
			exp+=KiSkillGains(1*savant.kiratio)
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Ki_Efficiency
	skilltype = "Mind Buff"
	name = "Advanced Ki Efficiency"
	desc = "Further increase your ki efficieny."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 3
	enabled = 0
	var/tmp/lastki=0
	var/tmp/diffki=0
	after_learn()
		savant<<"You become even more efficient with your ki!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel very efficient with your ki! Advanced Ki Efficiency is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kiefficiencyskill+=2
			if(level % 10 == 0)
				savant.kiskillBuff+=0.02
			if(level % 20 == 0)
				savant.kidefBuff+=0.1
			if(level == 50)
				savant.genome.add_to_stat("Energy Level",0.02)
			if(level == 75)
				savant.kiefficiencyskill+=5
				savant.kidefBuff+=0.2
			if(level == 100)
				savant.kiefficiencyskill+=5
				savant.kiskillBuff+=0.3
				savant.kioffBuff+=0.4
				enableskill(/datum/skill/mind/Perfect_Ki_Efficiency)
		diffki=(savant.Ki-lastki)
		if(savant.Ki!=lastki&&diffki<0)
			exp+=KiSkillGains(3)
		lastki=savant.Ki
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Ki_Gathering
	skilltype = "Mind Buff"
	name = "Advanced Ki Gathering"
	desc = "You further improve your ability to gather ki."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 3
	enabled = 0
	after_learn()
		savant<<"Your ki reserves are overflowing!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your ki overflows within you! Advanced Ki Gathering is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kigatheringskill+=2
			if(level % 10 == 0)
				savant.kidefBuff+=0.1
			if(level % 20 == 0)
				savant.willpowerMod+=0.02
			if(level == 30)
				savant.kioffBuff+=0.2
			if(level == 50)
				savant.kidefBuff+=0.2
			if(level == 75)
				savant.kigatheringskill+=5
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 100)
				savant.kigatheringskill+=5
				savant.genome.add_to_stat("Energy Level",0.05)
				enableskill(/datum/skill/mind/Perfect_Ki_Gathering)
		if((savant.Ki/savant.MaxKi)<0.9)
			exp+=KiSkillGains(3*(2-(savant.Ki/savant.MaxKi)))
		else if(savant.deepmeditation)
			exp+=KiSkillGains(2)
//Perfect Mastery Block
/datum/skill/mind/Perfect_Ki_Awareness
	skilltype = "Mind Buff"
	name = "Perfect Ki Awareness"
	desc = "Master your ability to detect the energy of other living beings."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 5
	enabled = 0//anything after Ki Unlocked has prerequisites to meet
	after_learn()
		savant<<"You are a master at sensing energy!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You are one with the ki around you! Perfect Ki Awareness is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kiawarenessskill+=1
			if(level % 10 == 0)
				savant.speedBuff+=0.1
			if(level % 20 == 0)
				savant.kiskillBuff+=0.15
				savant.kidefBuff+=0.1
			if(level == 75)
				savant.genome.add_to_stat("Energy Level",0.1)
				savant.kiskillBuff+=0.25
				savant.kiawarenessskill+=2
			if(level == 100)
				savant.genome.add_to_stat("Energy Level",0.1)
				savant.kiskillBuff+=0.25
				savant.kidefBuff+=0.1
				savant.kiawarenessskill+=3
		if(savant.studying)
			exp+=KiSkillGains(2)
		if(savant.observingnow)
			exp+=KiSkillGains(3)
		else
			exp+=KiSkillGains(1)
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Ki_Circulation
	skilltype = "Mind Buff"
	name = "Perfect Ki Circulation"
	desc = "Truly master circulating ki to improve your power."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 5
	enabled = 0
	after_learn()
		savant<<"Your ki flows effortlessly within you!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your ki flows effortlessly! Perfect Ki Circulation is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kicirculationskill+=1
			if(level % 10 == 0)
				savant.kidefBuff+=0.15
			if(level % 20 == 0)
				savant.willpowerMod+=0.05
				savant.speedBuff+=0.15
			if(level == 50)
				savant.kidefBuff+=0.5
			if(level == 75)
				savant.kicirculationskill+=2
				savant.genome.add_to_stat("Energy Level",0.075)
			if(level == 100)
				savant.kicirculationskill+=3
				savant.genome.add_to_stat("Energy Level",0.075)
		if(savant.kibuffon)
			exp+=KiSkillGains(2)
		else
			exp+=KiSkillGains(1)
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Ki_Control
	skilltype = "Mind Buff"
	name = "Perfect Ki Control"
	desc = "Master your ability to direct your ki."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 5
	enabled = 0
	after_learn()
		savant<<"You masterfully bend your ki to your will!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel perfect control of your ki! Perfect Ki Control is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kicontrolskill+=1
			if(level % 10 == 0)
				savant.kiskillBuff+=0.15
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 50)
				savant.kioffBuff+=0.15
				savant.kidefBuff+=0.15
			if(level == 75)
				savant.kicontrolskill+=2
				savant.kiskillBuff+=0.3
			if(level == 100)
				savant.kicontrolskill+=3
				savant.kiskillBuff+=0.4
		if(savant.kiratio>1)
			exp+=KiSkillGains(1*savant.kiratio)
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Ki_Efficiency
	skilltype = "Mind Buff"
	name = "Perfect Ki Efficiency"
	desc = "Master your ki efficiency."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 5
	enabled = 0
	var/tmp/lastki=0
	var/tmp/diffki=0
	after_learn()
		savant<<"You become masterfully efficient with your ki!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel perfectly efficient with your ki! Perfect Ki Efficiency is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kiefficiencyskill+=1
			if(level % 10 == 0)
				savant.kiskillBuff+=0.05
			if(level % 20 == 0)
				savant.kidefBuff+=0.15
			if(level == 50)
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 75)
				savant.kiefficiencyskill+=2
				savant.kidefBuff+=0.2
			if(level == 100)
				savant.kiefficiencyskill+=3
				savant.kiskillBuff+=0.3
				savant.kioffBuff+=0.4
		diffki=(savant.Ki-lastki)
		if(savant.Ki!=lastki&&diffki<0)
			exp+=KiSkillGains(3)
		lastki=savant.Ki
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Ki_Gathering
	skilltype = "Mind Buff"
	name = "Perfect Ki Gathering"
	desc = "You master your ability to gather ki."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 5
	enabled = 0
	after_learn()
		savant<<"Your ki reserves are limitless!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your ki is limitless within you! Perfect Ki Gathering is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kigatheringskill+=1
			if(level % 10 == 0)
				savant.kidefBuff+=0.15
			if(level % 20 == 0)
				savant.willpowerMod+=0.02
			if(level == 30)
				savant.kioffBuff+=0.25
			if(level == 50)
				savant.kidefBuff+=0.25
			if(level == 75)
				savant.kigatheringskill+=2
				savant.genome.add_to_stat("Energy Level",0.05)
			if(level == 100)
				savant.kigatheringskill+=3
				savant.genome.add_to_stat("Energy Level",0.05)
		if((savant.Ki/savant.MaxKi)<0.9)
			exp+=KiSkillGains(3*(2-(savant.Ki/savant.MaxKi)))
		else if(savant.deepmeditation)
			exp+=KiSkillGains(2)

//Advanced Skill Mastery block


/datum/skill/mind/proc/KiSkillGains(exp)
	if(savant)
		if(savant.MaxKi <= 300)
			exp *= savant.MaxKi/3000
	var/gain = exp*max((2+((AverageKiLevel-savant.KiTotal())/(AverageKiLevel+1))),0.25)*savant.Ekiskill*GlobalKiExpRate
	if(expbuffer)
		if(expbuffer-gain>0)
			expbuffer-=gain
			gain*= sqrt(max(4,(expbuffer / gain)*4))
		else
			gain+=expbuffer
			expbuffer=0
	return gain