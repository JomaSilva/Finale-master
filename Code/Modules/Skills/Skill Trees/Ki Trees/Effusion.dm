//skill tree for picking a specialization and expanding on it
/datum/skill/tree/effusionmas
	name = "Effusive Mastery"
	desc = "Offensive Specialization"
	skilltype = null
	common_sense = FALSE
	tier=1
	allowedtier = 4
	maxtier = 4
	enabled = 0
	constituentskills = list(new/datum/skill/mind/Basic_Blast_Mastery,new/datum/skill/mind/Basic_Ki_Effusion,\
	new/datum/skill/mind/Advanced_Ki_Effusion, new/datum/skill/mind/Basic_Beam_Mastery,new/datum/skill/mind/Basic_Kiai_Mastery,\
	new/datum/skill/mind/Advanced_Blast_Mastery, new/datum/skill/mind/Advanced_Beam_Mastery,new/datum/skill/mind/Advanced_Kiai_Mastery,\
	new/datum/skill/mind/Perfect_Ki_Effusion,new/datum/skill/mind/Perfect_Blast_Mastery,new/datum/skill/mind/Perfect_Beam_Mastery,\
	new/datum/skill/mind/Perfect_Kiai_Mastery)

/datum/skill/tree/effusionmas/growbranches()
	if(savant.kieffusionskill>=5)
		enableskill(/datum/skill/mind/Basic_Blast_Mastery)
		enableskill(/datum/skill/mind/Basic_Beam_Mastery)
		enableskill(/datum/skill/mind/Basic_Kiai_Mastery)
	if(savant.effusionspecial==1)
		enabletree(/datum/skill/tree/effusionspec)
	..()

/datum/skill/tree/effusionmas/prunebranches()
	..()

/datum/skill/mind/Basic_Ki_Effusion
	skilltype = "Mind Buff"
	name = "Basic Ki Effusion"
	desc = "You have learned to expel your ki to effect change on your environment. This is the path to harnessing that power."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 1
	enabled = 0
	var/attackcounter = 0//running counter of effusion attacks done for exp purposes
	after_learn()
		savant<<"You begin to master the art of effusing ki."
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel your ki erupt from you! Basic Effusion is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kieffusionskill+=1
				savant.kiarmor += 1
			if(level % 10 == 0)
				savant.kicontrolskill+=0.2
				savant.kiefficiencyskill+=0.5
				savant.kioffBuff+=0.05
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kiskillBuff+=0.05
			if(level == 25)//learn beam
				savant<<"You have learned to focus your ki into a single point before effusing it. You have learned the basic Beam!"
				assignverb(/mob/keyable/verb/Ki_Wave)
			if(level == 50) //learn Give Power
				savant.kioffBuff+=0.1
				savant.kidefBuff+=0.1
				savant<<"You have learned to focus your Ki into somebody else, healing and increasing their power!"
				assignverb(/mob/keyable/verb/Give_Power)
			if(level == 75)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kioffBuff+=0.1
			if(level == 100)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kiskillBuff+=0.1
				enableskill(/datum/skill/mind/Advanced_Ki_Effusion)
		var/effusioncounter=savant.blastcounter+savant.beamcounter+savant.chargedcounter+savant.kiaicounter+savant.guidedcounter+savant.homingcounter+savant.targetedcounter+savant.volleycounter
		if(attackcounter<effusioncounter)
			exp+=KiSkillGains(10*(effusioncounter-attackcounter))
			attackcounter=effusioncounter
	login(var/mob/logger)
		..()
		if(level >= 25) assignverb(/mob/keyable/verb/Ki_Wave)
		if(level >= 50) assignverb(/mob/keyable/verb/Give_Power)

/datum/skill/mind/Advanced_Ki_Effusion
	skilltype = "Mind Buff"
	name = "Advanced Ki Effusion"
	desc = "Further improve your ability to expel your ki."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 3
	enabled = 0
	var/attackcounter = 0//running counter of effusion attacks done for exp purposes
	var/effusioncounter= 0
	after_learn()
		savant<<"You are becoming adept at effusing ki."
		effusioncounter = savant.blastcounter+savant.beamcounter+savant.chargedcounter+savant.kiaicounter+savant.guidedcounter+savant.homingcounter+savant.targetedcounter+savant.volleycounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel your ki explode from you! Advanced Effusion is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kieffusionskill+=2
			if(level % 10 == 0)
				savant.kioffBuff+=0.1
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kiskillBuff+=0.05
				savant.kidefBuff+=0.05
			if(level == 25)
				savant<<"You think you've discovered how to alter your effusion! You can now learn an effusion specialty!"
				savant.effusionspecial=1
			if(level == 50)
				savant.kioffBuff+=0.2
				savant.kidefBuff+=0.2
			if(level == 75)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kioffBuff+=0.2
				savant.kieffusionskill+=5
			if(level == 100)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kiskillBuff+=0.2
				savant.kieffusionskill+=5
				enableskill(/datum/skill/mind/Perfect_Ki_Effusion)
		effusioncounter=savant.blastcounter+savant.beamcounter+savant.chargedcounter+savant.kiaicounter+savant.guidedcounter+savant.homingcounter+savant.targetedcounter+savant.volleycounter
		if(attackcounter<effusioncounter)
			exp+=KiSkillGains(10*(effusioncounter-attackcounter))
			attackcounter=effusioncounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Ki_Effusion
	skilltype = "Mind Buff"
	name = "Perfect Ki Effusion"
	desc = "Master your ability to expel your ki."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 5
	enabled = 0
	var/attackcounter = 0//running counter of effusion attacks done for exp purposes
	var/effusioncounter= 0
	after_learn()
		savant<<"You are a master at effusing ki."
		effusioncounter = savant.blastcounter+savant.beamcounter+savant.chargedcounter+savant.kiaicounter+savant.guidedcounter+savant.homingcounter+savant.targetedcounter+savant.volleycounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"You feel your ki explode from you! Perfect Effusion is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kieffusionskill+=1
			if(level % 10 == 0)
				savant.kioffBuff+=0.15
			if(level % 20 == 0)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kiskillBuff+=0.05
				savant.kidefBuff+=0.05
			if(level == 50)
				savant.kioffBuff+=0.3
				savant.kidefBuff+=0.3
			if(level == 75)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kioffBuff+=0.3
				savant.kieffusionskill+=2
			if(level == 100)
				savant.genome.add_to_stat("Energy Level",0.05)
				savant.kiskillBuff+=0.3
				savant.kieffusionskill+=3
		effusioncounter=savant.blastcounter+savant.beamcounter+savant.chargedcounter+savant.kiaicounter+savant.guidedcounter+savant.homingcounter+savant.targetedcounter+savant.volleycounter
		if(attackcounter<effusioncounter)
			exp+=KiSkillGains(10*(effusioncounter-attackcounter))
			attackcounter=effusioncounter
	login(var/mob/logger)
		..()


//Basic Skill Mastery Block
/datum/skill/mind/Basic_Blast_Mastery
	skilltype = "Mind Buff"
	name = "Basic Blast Mastery"
	desc = "Improve your proficiency with blast attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand blasts better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over blasts grows! Basic Blast Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.blastskill+=1
			if(level == 30)//learn Energy Barrage
				savant<<"You think you can rapidly fire blasts now!"
				assignverb(/mob/keyable/verb/Energy_Barrage)
				savant.volleyskill+=1
				savant.bonusShots+=1
			if(level == 50)//learn Charged Shot
				savant <<"You think you can make a more powerful blast!"
				assignverb(/mob/keyable/verb/Charged_Shot)
				savant.chargedskill+=1
			if(level == 75)//learn Scattershot
				savant <<"You've learned to fire many blasts at once!"
				assignverb(/mob/keyable/verb/Scattershot)
				savant.homingskill+=1
			if(level == 100)
				savant.blastskill+=5
				savant.bonusShots+=1
				enableskill(/datum/skill/mind/Advanced_Blast_Mastery)
		if(attackcounter<savant.blastcounter)
			exp+=KiSkillGains(10*(savant.blastcounter-attackcounter))
			attackcounter = savant.blastcounter
	login(var/mob/logger)
		..()
		if(level >= 30)
			assignverb(/mob/keyable/verb/Energy_Barrage)
		if(level >= 50)
			assignverb(/mob/keyable/verb/Charged_Shot)
		if(level >= 75)
			assignverb(/mob/keyable/verb/Scattershot)

/datum/skill/mind/Basic_Beam_Mastery
	skilltype = "Mind Buff"
	name = "Basic Beam Mastery"
	desc = "Improve your proficiency with beam attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand beams better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over beams grows! Basic Beam Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.beamskill+=1
			if(level == 30)//learn Masenko
				savant<<"You think you can create a beam that's stronger up close!"
				assignverb(/mob/keyable/verb/Masenko)
			if(level == 50)//learn Makkankosappo
				savant <<"You think you can make a beam that grows in power as it travels!"
				assignverb(/mob/keyable/verb/Makkankosappo)
			if(level == 75)//learn Energy Wave Volley
				savant <<"You've learned to fire many beams at once!"
				assignverb(/mob/keyable/verb/Energy_Wave_Volley)
				savant.volleyskill+=1
				savant.chargedskill+=1
			if(level == 100)
				savant.beamskill+=5
				enableskill(/datum/skill/mind/Advanced_Beam_Mastery)
		if(attackcounter<savant.beamcounter)
			exp+=KiSkillGains(10*(savant.beamcounter-attackcounter))
			attackcounter = savant.beamcounter
	login(var/mob/logger)
		..()
		if(level >= 30)
			assignverb(/mob/keyable/verb/Masenko)
		if(level >= 50)
			assignverb(/mob/keyable/verb/Makkankosappo)
		if(level >= 75)
			assignverb(/mob/keyable/verb/Energy_Wave_Volley)

/datum/skill/mind/Basic_Kiai_Mastery
	skilltype = "Mind Buff"
	name = "Basic Kiai Mastery"
	desc = "Improve your proficiency with kiai attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand kiai attacks better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over kiai attacks grows! Basic Kiai Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.kiaiskill+=1
			if(level == 30)//learn Shockwave
				savant<<"You think you can knock back opponents in all directions!"
				assignverb(/mob/keyable/verb/Shockwave)
			if(level == 50)//learn Deflection
				savant <<"You think you can knock back projectiles fired at you from the front!"
				assignverb(/mob/keyable/verb/Deflection)
			if(level == 75)//learn Explosive Roar
				savant <<"You've learned charge a massive kiai attack!"
				assignverb(/mob/keyable/verb/Explosive_Roar)
				savant.chargedskill+=1
			if(level == 100)
				savant.kiaiskill+=5
				enableskill(/datum/skill/mind/Advanced_Kiai_Mastery)
		if(attackcounter<savant.kiaicounter)
			exp+=KiSkillGains(20*(savant.kiaicounter-attackcounter))
			attackcounter = savant.kiaicounter
	login(var/mob/logger)
		..()
		if(level >= 30)
			assignverb(/mob/keyable/verb/Shockwave)
		if(level >= 50)
			assignverb(/mob/keyable/verb/Deflection)
		if(level >= 75)
			assignverb(/mob/keyable/verb/Explosive_Roar)

/datum/skill/mind/Basic_Volley_Mastery
	skilltype = "Mind Buff"
	name = "Basic Volley Mastery"
	desc = "Improve your proficiency with rapid ki attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand rapid attacks better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over volley attacks grows! Basic Volley Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.volleyskill+=1
			if(level % 20 == 0)
				savant.bonusShots+=1
			if(level == 20)
				savant<<"You can now rapidly fire a continous stream of blasts. The longer you fire, the longer the recharge time."
				assignverb(/mob/keyable/verb/Continuous_Energy_Bullets)
			if(level == 50)
				savant<<"You can now expel energy blasts in all directions!"
				assignverb(/mob/keyable/verb/Spin_Blast)
			if(level == 100)
				savant.volleyskill+=5
				enableskill(/datum/skill/mind/Advanced_Volley_Mastery)
		if(attackcounter<savant.volleycounter)
			exp+=KiSkillGains(20*(savant.volleycounter-attackcounter))
			attackcounter = savant.volleycounter
	login(var/mob/logger)
		..()
		if(level>=20)
			assignverb(/mob/keyable/verb/Continuous_Energy_Bullets)
		if(level >= 50)
			assignverb(/mob/keyable/verb/Spin_Blast)


/datum/skill/mind/Basic_Guided_Mastery
	skilltype = "Mind Buff"
	name = "Basic Guided Mastery"
	desc = "Improve your proficiency with guided ki attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand guided attacks better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over guided attacks grows! Basic Guided Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.guidedskill+=1
			if(level == 30)
				savant<<"You can now form your guided blast into a sharp, spinning disc!."
				assignverb(/mob/keyable/verb/Kienzan)
			if(level == 75)
				savant<<"You can gather a frightening amount of energy into a large, guidable orb."
				assignverb(/mob/keyable/verb/Death_Ball)
			if(level == 100)
				savant.guidedskill+=5
				enableskill(/datum/skill/mind/Advanced_Guided_Mastery)
		if(attackcounter<savant.guidedcounter)
			exp+=KiSkillGains(20*(savant.guidedcounter-attackcounter))
			attackcounter = savant.guidedcounter
	login(var/mob/logger)
		..()
		if(level>=30)
			assignverb(/mob/keyable/verb/Kienzan)
		if(level >= 75)
			assignverb(/mob/keyable/verb/Death_Ball)


/datum/skill/mind/Basic_Homing_Mastery
	skilltype = "Mind Buff"
	name = "Basic Homing Mastery"
	desc = "Improve your proficiency with homing ki attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand homing attacks better!"
		savant<<"Your blast attacks now have a chance to home in on your target!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over homing attacks grows! Basic Homing Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.homingskill+=1
			if(level == 100)
				savant.homingskill+=5
				enableskill(/datum/skill/mind/Advanced_Homing_Mastery)
		if(savant.target&&savant.target!=savant)
			savant.homingcounter++
		if(attackcounter<savant.homingcounter)
			exp+=KiSkillGains(20*(savant.homingcounter-attackcounter))
			attackcounter = savant.homingcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Basic_Targeted_Mastery
	skilltype = "Mind Buff"
	name = "Basic Targeted Mastery"
	desc = "Improve your proficiency with targeted ki attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 5000
	skillcost = 1
	tier = 2
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand targeted attacks better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over homing attacks grows! Basic Targeted Mastery is now level [level]!"
			expbarrier=(5000*1.03**level)
			if(level % 5 == 0)
				savant.targetedskill+=1
			if(level == 30)
				savant<<"You can now direct your Ki Bomb skill to converge on your target! You've learned the Hellzone Grenade!"
				assignverb(/mob/keyable/verb/Hellzone_Grenade)
				savant.homingskill+=1
			if(level == 100)
				savant.targetedskill+=5
				enableskill(/datum/skill/mind/Advanced_Targeted_Mastery)
		if(attackcounter<savant.targetedcounter)
			exp+=KiSkillGains(40*(savant.targetedcounter-attackcounter))
			attackcounter = savant.targetedcounter
	login(var/mob/logger)
		..()
		if(level>=30)
			assignverb(/mob/keyable/verb/Hellzone_Grenade)

/datum/skill/mind/Advanced_Blast_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Blast Mastery"
	desc = "Further improve your proficiency with blast attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand blasts better!"
		attackcounter=savant.blastcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over blasts grows! Advanced Blast Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.blastskill+=2
			if(level == 30)
				savant.bonusShots+=2
			if(level == 75)
				savant.blastskill+=5
			if(level == 100)
				savant.blastskill+=5
				savant.bonusShots+=3
				enableskill(/datum/skill/mind/Perfect_Blast_Mastery)
		if(attackcounter<savant.blastcounter)
			exp+=KiSkillGains(10*(savant.blastcounter-attackcounter))
			attackcounter = savant.blastcounter
	login(var/mob/logger)
		..()


/datum/skill/mind/Advanced_Beam_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Beam Mastery"
	desc = "Further improve your proficiency with beam attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand beams better!"
		attackcounter=savant.beamcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over beams grows! Advanced Beam Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.beamskill+=2
			if(level == 30)
				savant<<"You can now fire an enormous beam of energy!"
				assignverb(/mob/keyable/verb/Massive_Beam)
			if(level == 75)
				savant.beamskill+=5
			if(level == 100)
				savant.beamskill+=5
				enableskill(/datum/skill/mind/Perfect_Beam_Mastery)
		if(attackcounter<savant.beamcounter)
			exp+=KiSkillGains(10*(savant.beamcounter-attackcounter))
			attackcounter = savant.beamcounter
	login(var/mob/logger)
		..()
		if(level >= 30)
			assignverb(/mob/keyable/verb/Massive_Beam)

/datum/skill/mind/Advanced_Kiai_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Kiai Mastery"
	desc = "Further improve your proficiency with kiai attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand kiai attacks better!"
		attackcounter=savant.kiaicounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over kiai attacks grows! Advanced Kiai Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.kiaiskill+=2
			if(level == 75)
				savant.kiaiskill+=5
			if(level == 100)
				savant.kiaiskill+=5
				enableskill(/datum/skill/mind/Perfect_Kiai_Mastery)
		if(attackcounter<savant.kiaicounter)
			exp+=KiSkillGains(20*(savant.kiaicounter-attackcounter))
			attackcounter = savant.kiaicounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Volley_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Volley Mastery"
	desc = "Improve your proficiency with rapid ki attacks, and learn more advanced techniques."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand rapid attacks better!"
		attackcounter=savant.volleycounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over volley attacks grows! Advanced Volley Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.volleyskill+=2
			if(level % 20 == 0)
				savant.bonusShots+=1
			if(level == 75)
				savant.volleyskill+=5
			if(level == 100)
				savant.volleyskill+=5
				enableskill(/datum/skill/mind/Perfect_Volley_Mastery)
		if(attackcounter<savant.volleycounter)
			exp+=KiSkillGains(20*(savant.volleycounter-attackcounter))
			attackcounter = savant.volleycounter
	login(var/mob/logger)
		..()


/datum/skill/mind/Advanced_Guided_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Guided Mastery"
	desc = "Further improve your proficiency with guided ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You think you understand guided attacks better!"
		attackcounter=savant.guidedcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over guided attacks grows! Advanced Guided Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.guidedskill+=2
			if(level == 75)
				savant.guidedskill+=5
			if(level == 100)
				savant.guidedskill+=5
				enableskill(/datum/skill/mind/Perfect_Guided_Mastery)
		if(attackcounter<savant.guidedcounter)
			exp+=KiSkillGains(20*(savant.guidedcounter-attackcounter))
			attackcounter = savant.guidedcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Homing_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Homing Mastery"
	desc = "Further improve your proficiency with homing ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand homing attacks better!"
		attackcounter=savant.homingcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over homing attacks grows! Advanced Homing Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.homingskill+=2
			if(level == 75)
				savant.homingskill+=5
			if(level == 100)
				savant.homingskill+=5
				enableskill(/datum/skill/mind/Perfect_Homing_Mastery)
		if(attackcounter<savant.homingcounter)
			exp+=KiSkillGains(20*(savant.homingcounter-attackcounter))
			attackcounter = savant.homingcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Advanced_Targeted_Mastery
	skilltype = "Mind Buff"
	name = "Advanced Targeted Mastery"
	desc = "Further improve your proficiency with targeted ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand targeted attacks better!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over homing attacks grows! Advanced Targeted Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.targetedskill+=2
			if(level == 75)
				savant.targetedskill+=5
			if(level == 100)
				savant.targetedskill+=5
				enableskill(/datum/skill/mind/Perfect_Targeted_Mastery)
		if(attackcounter<savant.targetedcounter)
			exp+=KiSkillGains(40*(savant.targetedcounter-attackcounter))
			attackcounter = savant.targetedcounter
	login(var/mob/logger)
		..()

//Perfect Skill Mastery Block

/datum/skill/mind/Perfect_Blast_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Blast Mastery"
	desc = "Perfect your proficiency with blast attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected blasts!"
		attackcounter=savant.blastcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over blasts grows! Perfect Blast Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.blastskill+=1
			if(level == 30)
				savant.bonusShots+=2
			if(level == 75)
				savant.blastskill+=2
			if(level == 100)
				savant.blastskill+=3
				savant.bonusShots+=3
		if(attackcounter<savant.blastcounter)
			exp+=KiSkillGains(10*(savant.blastcounter-attackcounter))
			attackcounter = savant.blastcounter
	login(var/mob/logger)
		..()


/datum/skill/mind/Perfect_Beam_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Beam Mastery"
	desc = "Perfect your proficiency with beam attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected beams!"
		attackcounter=savant.beamcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over beams grows! Perfect Beam Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.beamskill+=1
			if(level == 75)
				savant.beamskill+=2
			if(level == 100)
				savant.beamskill+=3
		if(attackcounter<savant.beamcounter)
			exp+=KiSkillGains(10*(savant.beamcounter-attackcounter))
			attackcounter = savant.beamcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Kiai_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Kiai Mastery"
	desc = "Perfect your proficiency with kiai attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected kiai attacks!"
		attackcounter=savant.kiaicounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over kiai attacks grows! Perfect Kiai Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.kiaiskill+=1
			if(level == 75)
				savant.kiaiskill+=2
			if(level == 100)
				savant.kiaiskill+=3
		if(attackcounter<savant.kiaicounter)
			exp+=KiSkillGains(20*(savant.kiaicounter-attackcounter))
			attackcounter = savant.kiaicounter
	login(var/mob/logger)
		..()
/datum/skill/mind/Perfect_Volley_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Volley Mastery"
	desc = "Perfect your proficiency with rapid ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected rapid attacks!"
		attackcounter=savant.volleycounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over volley attacks grows! Perfect Volley Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.volleyskill+=1
			if(level % 20 == 0)
				savant.bonusShots+=1
			if(level == 75)
				savant.volleyskill+=2
			if(level == 100)
				savant.volleyskill+=3
		if(attackcounter<savant.volleycounter)
			exp+=KiSkillGains(20*(savant.volleycounter-attackcounter))
			attackcounter = savant.volleycounter
	login(var/mob/logger)
		..()


/datum/skill/mind/Perfect_Guided_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Guided Mastery"
	desc = "Perfect your proficiency with guided ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected guided attacks!"
		attackcounter=savant.guidedcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over guided attacks grows! Perfect Guided Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.guidedskill+=1
			if(level == 75)
				savant.guidedskill+=2
			if(level == 100)
				savant.guidedskill+=3
		if(attackcounter<savant.guidedcounter)
			exp+=KiSkillGains(20*(savant.guidedcounter-attackcounter))
			attackcounter = savant.guidedcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Homing_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Homing Mastery"
	desc = "Further improve your proficiency with homing ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 10000
	skillcost = 1
	tier = 4
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You understand homing attacks better!"
		attackcounter=savant.homingcounter
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over homing attacks grows! Advanced Homing Mastery is now level [level]!"
			expbarrier=(10000*1.03**level)
			if(level % 5 == 0)
				savant.homingskill+=2
			if(level == 75)
				savant.homingskill+=5
			if(level == 100)
				savant.homingskill+=5
		if(attackcounter<savant.homingcounter)
			exp+=KiSkillGains(20*(savant.homingcounter-attackcounter))
			attackcounter = savant.homingcounter
	login(var/mob/logger)
		..()

/datum/skill/mind/Perfect_Targeted_Mastery
	skilltype = "Mind Buff"
	name = "Perfect Targeted Mastery"
	desc = "Perfect your proficiency with targeted ki attacks."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 100
	expbarrier = 20000
	skillcost = 1
	tier = 6
	enabled = 0
	var/attackcounter
	after_learn()
		savant<<"You've perfected targeted attacks!"
	effector()
		..()
		if(levelup)
			levelup=0
			savant<<"Your mastery over homing attacks grows! Perfect Targeted Mastery is now level [level]!"
			expbarrier=(20000*1.03**level)
			if(level % 5 == 0)
				savant.targetedskill+=1
			if(level == 75)
				savant.targetedskill+=2
			if(level == 100)
				savant.targetedskill+=3
		if(attackcounter<savant.targetedcounter)
			exp+=KiSkillGains(40*(savant.targetedcounter-attackcounter))
			attackcounter = savant.targetedcounter
	login(var/mob/logger)
		..()