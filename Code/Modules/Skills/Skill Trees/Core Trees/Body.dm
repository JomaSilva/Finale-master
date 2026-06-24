datum/skill/tree/Body
	name = "Strength of Body"
	desc = "General Physical Ability"
	maxtier = 10
	allowedtier = 1
	tier=0
	constituentskills = list(new/datum/skill/expand,new/datum/skill/ki/Afterimage,\
		new/datum/skill/rapidmovement,new/datum/skill/training,\
		new/datum/skill/evasive,new/datum/skill/drills,new/datum/skill/qingqong,new/datum/skill/grace,\
		new/datum/skill/physical,new/datum/skill/bulk,new/datum/skill/barrel,new/datum/skill/arm,\
		new/datum/skill/boxing,new/datum/skill/force,new/datum/skill/precision,\
		new/datum/skill/preparedness,new/datum/skill/blocking,,new/datum/skill/bprecision,new/datum/skill/Ki_Control/Planet_Destroy,new/datum/skill/Small_Boxer,\
		new/datum/skill/Bigtime_Boxer,new/datum/skill/MartialSkill/Kicker,new/datum/skill/MartialSkill/Beserker)

mob/var/bodyreadiness //global var for body's "raw muscle"
mob/var/bodyskill //global var for body's "physical skill"
mob/var/didbodychange

/datum/skill/tree/Body/growbranches()
	if(invested>=4)allowedtier = 2
	if(invested>=7)allowedtier = 3
	if(savant.didbodychange)
		savant.didbodychange=0
		if(savant.bodyreadiness>2)
			enabletree(/datum/skill/tree/Bodybuilding)
		if(savant.bodyskill>2)
			enabletree(/datum/skill/tree/MartialSkill)
			if(savant.weaponeq)
				enabletree(/datum/skill/tree/WeaponsExpert)
		if(savant.bodyskill>=2&&savant.bodyreadiness>=2)
			enabletree(/datum/skill/tree/Cultivation)
			savant.mastery_enable(/datum/mastery/Melee/Armed_Combat)
	..()
	return

/datum/skill/tree/Body/prunebranches()
	if(invested<4)allowedtier = 1
	if(savant.didbodychange)
		savant.didbodychange=0
		if(savant.bodyreadiness<=2)
			disabletree(/datum/skill/tree/Bodybuilding)
		if(savant.bodyskill<=2)
			disabletree(/datum/skill/tree/MartialSkill)
		if(savant.bodyskill<2||savant.bodyskill<2)
			disabletree(/datum/skill/tree/Cultivation)
			savant.mastery_remove(/datum/mastery/Melee/Armed_Combat)
	..()
	return

/datum/skill/training
	skilltype = "Body Buff"
	name = "Basic Training"
	desc = "The user hones their body. P.Off+, P.Def+, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 1
/datum/skill/training/after_learn()
	savant<<"You feel stronger."
	savant.physoffBuff+=0.1
	savant.physdefBuff+=0.1
	savant.techniqueBuff+=0.05
	savant.bodyskill+=1
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/training/before_forget()
	savant<<"You feel weaker."
	savant.physoffBuff-=0.1
	savant.physdefBuff-=0.1
	savant.techniqueBuff-=0.05
	savant.bodyskill-=1
	savant.bodyreadiness-=1
	savant.didbodychange=1

//speed buffs

/datum/skill/evasive
	skilltype = "Body Buff"
	name = "Evasion Training"
	desc = "The user practices agile movement. Spd+, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/training)
/datum/skill/evasive/after_learn()
	savant<<"You feel faster."
	savant.speedBuff+=0.05
	savant.techniqueBuff+=0.05
	savant.bodyskill+=1
	savant.didbodychange=1
/datum/skill/evasive/before_forget()
	savant<<"You feel slower."
	savant.speedBuff-=0.05
	savant.techniqueBuff-=0.1
	savant.bodyskill-=1
	savant.didbodychange=1

/datum/skill/drills
	skilltype = "Body Buff"
	name = "Speed Drills"
	desc = "The user undergoes intense training to improve the quality of their legs.\nAllows you to do a very rudimentary Rush Attack, the Lariat. Spd+, P.Off+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/evasive)
/datum/skill/drills/after_learn()
	savant<<"You feel ready to run"
	assignverb(/mob/keyable/verb/Lariat)
	savant.speedBuff+=0.1
	savant.physoffBuff+=0.1
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/drills/before_forget()
	savant<<"You feel slow."
	unassignverb(/mob/keyable/verb/Lariat)
	savant.speedBuff-=0.1
	savant.physoffBuff-=0.1
	savant.bodyreadiness-=1
	savant.didbodychange=1
datum/skill/drills/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Lariat)


/datum/skill/qingqong
	skilltype = "Body Buff"
	name = "Light Skill"
	desc = "The user practices running up elevated planks for better control over their balance. Spd+, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/evasive)
/datum/skill/qingqong/after_learn()
	savant<<"You feel more in control."
	savant.speedBuff+=0.05
	savant.techniqueBuff+=0.25
	savant.bodyskill+=1
	savant.didbodychange=1
/datum/skill/qingqong/before_forget()
	savant<<"You feel like you wasted your time."
	savant.speedBuff-=0.05
	savant.techniqueBuff-=0.25
	savant.bodyskill-=1
	savant.didbodychange=1

/datum/skill/grace
	skilltype = "Body Buff"
	name = "External Grace"
	desc = "The user learns to move like the wind and hit like a motherfucker. Spd+, Tech+, P.Off+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 2
	enabled = 0
	prereqs = list(new/datum/skill/qingqong)
	after_learn()
		savant<<"You feel as light as a feather."
		savant.speedBuff+=0.1
		savant.techniqueBuff+=0.2
		savant.physoffBuff+=0.1
		savant.bodyskill+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You feel bloated."
		savant.speedBuff-=0.1
		savant.techniqueBuff-=0.2
		savant.physoffBuff-=0.1
		savant.bodyskill-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/Falling_Kick)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to coordinate a basic kicking attack! FALLING KICK!! This attack does more damage to flying opponents!"
					assignverb(/mob/keyable/verb/Falling_Kick)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Falling_Kick)
//punchman buffs, physical is shared between defense+offense+technique
/datum/skill/MartialSkill/Kicker
	skilltype = "Physical"
	name = "Kicker"
	desc = "The user learns to move like the wind and hit like a motherfucker. Foot edition. Spd+, Tech+, P.Off+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	enabled = 0
	maxlevel=3
	prereqs = list(new/datum/skill/grace)
	expbarrier = 100
	after_learn()
		savant<<"You kick really good."
		savant.speedBuff+=0.1
		savant.techniqueBuff+=0.2
		savant.physoffBuff+=0.1
		savant.bodyskill+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You feel more lost."
		savant.speedBuff-=0.1
		savant.techniqueBuff-=0.2
		savant.physoffBuff-=0.1
		savant.bodyskill-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/Kickup)
		unassignverb(/mob/keyable/verb/Dropkick)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to execute a nasty kicking attack! KICKUP!!! This delivers a stun to grounded opponents!"
					assignverb(/mob/keyable/verb/Kickup)
			if(3)
				if(levelup)
					savant << "You're able to do a dropkick attack towards the opponent! DROPKICK!!! You'll move in a straight line when using this attack!"
					assignverb(/mob/keyable/verb/Dropkick)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Kickup)
		if(level >= 3) assignverb(/mob/keyable/verb/Dropkick)
//defensive buffs

/datum/skill/bulk
	skilltype = "Body Buff"
	name = "Bulk"
	desc = "The user spends some time bulking up instead of working on practical muscle.\nCaution: this has some ramifications for your speed. P.Def++, Spd-"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/physical)
/datum/skill/bulk/after_learn()
	savant<<"You feel swole."
	savant.physdefBuff+=0.4
	savant.speedBuff-=0.1
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/bulk/before_forget()
	savant<<"You feel lean."
	savant.physdefBuff-=0.4
	savant.speedBuff+=0.1
	savant.bodyreadiness-=1
	savant.didbodychange=1


/datum/skill/barrel
	skilltype = "Body Buff"
	name = "Built like a Barrel"
	desc = "The user goes the extra mile for their bulk.\nCaution: this has some ramifications for your speed. P.Def+++, P.Off+, Spd-"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 3
	tier = 2
	enabled = 0
	maxlevel = 3
	prereqs = list(new/datum/skill/bulk)
	after_learn()
		savant<<"You feel massive."
		savant.physoffBuff+=0.1
		savant.physdefBuff+=0.6
		savant.speedBuff-=0.15
		savant.bodyreadiness+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You feel puny."
		savant.physoffBuff-=0.1
		savant.physdefBuff-=0.6
		savant.speedBuff+=0.15
		savant.bodyreadiness-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/Seismic_Press)
		unassignverb(/mob/keyable/verb/Gigantic_Spike)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to really press into people! GIGANTIC SPIKE!!"
					assignverb(/mob/keyable/verb/Seismic_Press)
			if(3)
				if(levelup)
					savant << "You're able to manipulate your opponent however you want! GIGANTIC SPIKE!!"
					assignverb(/mob/keyable/verb/Gigantic_Spike)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Seismic_Press)
		if(level >= 3) assignverb(/mob/keyable/verb/Gigantic_Spike)
//punchman buffs, physical is shared between defense+offense+technique
/datum/skill/MartialSkill/Beserker
	skilltype = "Physical"
	name = "Beserker"
	desc = "Increase your physical defense and offense even more, at a small price to Ki. Physoff++ Physdef++ Kiskill- Kioff-"
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	enabled = 0
	prereqs = list(new/datum/skill/barrel)
	expbarrier = 100
	maxlevel=3
	after_learn()
		savant<<"You puff out your chest a bit more."
		savant.physoffBuff+=0.2
		savant.physdefBuff+=0.7
		savant.kiskillBuff-=0.1
		savant.bodyreadiness+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You puff out your chest a bit less..."
		savant.physoffBuff-=0.2
		savant.physdefBuff-=0.7
		savant.kiskillBuff+=0.1
		savant.bodyreadiness-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/Power_Drag)
		unassignverb(/mob/keyable/verb/Revenge_Demon)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to drag a motherfucker across the ground! POWER DRAG!!"
					assignverb(/mob/keyable/verb/Power_Drag)
			if(3)
				if(levelup)
					savant << "You're able to do a short, nasty combo! REVENGE DEMON!!"
					assignverb(/mob/keyable/verb/Revenge_Demon)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Power_Drag)
		if(level >= 3) assignverb(/mob/keyable/verb/Revenge_Demon)

/datum/skill/physical
	skilltype = "Body Buff"
	name = "Muscle Training"
	desc = "The user works on their gains. P.Off+, P.Def+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/training)
/datum/skill/physical/after_learn()
	savant<<"You feel strong."
	savant.physoffBuff+=0.15
	savant.physdefBuff+=0.15
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/physical/before_forget()
	savant<<"You feel lazy."
	savant.physoffBuff-=0.15
	savant.physdefBuff-=0.15
	savant.bodyreadiness-=1
	savant.didbodychange=1

/datum/skill/arm
	skilltype = "Body Buff"
	name = "Punch Training"
	desc = "The user practices their striking abilities. P.Off++, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/physical)
/datum/skill/arm/after_learn()
	savant<<"You're getting a grip on punching."
	savant.physoffBuff+=0.3
	savant.techniqueBuff+=0.1
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/arm/before_forget()
	savant<<"You lose some precision."
	savant.physoffBuff-=0.3
	savant.techniqueBuff-=0.1
	savant.bodyreadiness-=1
	savant.didbodychange=1

/datum/skill/boxing
	skilltype = "Body Buff"
	name = "Boxing"
	desc = "The user learns the basics of fist-to-fist combat. P.Off+, P.Def+, Tech++"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 2
	tier = 2
	enabled = 0
	prereqs = list(new/datum/skill/arm)
	after_learn()
		savant<<"You punch real good."
		savant.physoffBuff+=0.1
		savant.physdefBuff+=0.05
		savant.techniqueBuff+=0.3
		savant.bodyskill+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You feel lost."
		savant.physoffBuff-=0.1
		savant.physdefBuff-=0.05
		savant.techniqueBuff-=0.3
		savant.bodyskill-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/One_Two)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to coordinate a basic combo attack! ONE, TWO!!"
					assignverb(/mob/keyable/verb/One_Two)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/One_Two)
//punchman buffs, physical is shared between defense+offense+technique
/datum/skill/Small_Boxer
	skilltype = "Physical"
	name = "Small Boxer"
	desc = "Increase your physical defense and offense even more, at a small price to Ki. Physoff+ Tech+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	enabled = 0
	maxlevel=3
	prereqs = list(new/datum/skill/boxing)
	expbarrier = 100
	after_learn()
		savant<<"You punch really good."
		savant.physoffBuff+=0.2
		savant.techniqueBuff+=0.4
		savant.bodyskill+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You feel more lost."
		savant.physoffBuff-=0.2
		savant.techniqueBuff-=0.4
		savant.bodyskill-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/One_Two_Five)
		unassignverb(/mob/keyable/verb/Two_One_Four)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to execute a better combination attack! ONE, TWO, FIVE!!"
					assignverb(/mob/keyable/verb/One_Two_Five)
			if(3)
				if(levelup)
					savant << "You're able to do a short, but effective combination attack! TWO, ONE, FOUR!!"
					assignverb(/mob/keyable/verb/Two_One_Four)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/One_Two_Five)
		if(level >= 3) assignverb(/mob/keyable/verb/Two_One_Four)
//punchman buffs, physical is shared between defense+offense+technique
/datum/skill/Bigtime_Boxer
	skilltype = "Physical"
	name = "Bigtime Boxer"
	desc = "Increase your physical defense and offense even more, at a small price to Ki. Physoff+ Physdef+ Tech+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	enabled = 0
	maxlevel=3
	prereqs = list(new/datum/skill/Small_Boxer)
	expbarrier = 100
	after_learn()
		savant<<"You puff out your chest a bit more."
		savant.physoffBuff+=0.3
		savant.physdefBuff+=0.1
		savant.techniqueBuff+=0.3
		savant.bodyskill+=1
		savant.didbodychange=1
	before_forget()
		savant<<"You feel lost."
		savant.physoffBuff-=0.3
		savant.physdefBuff-=0.1
		savant.techniqueBuff-=0.3
		savant.bodyskill-=1
		savant.didbodychange=1
		unassignverb(/mob/keyable/verb/KO_Punch)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to deliver a single nasty punch capable of one-hitting people! KO PUNCH!!"
					assignverb(/mob/keyable/verb/KO_Punch)
		levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/KO_Punch)

/datum/skill/force
	skilltype = "Body Buff"
	name = "Explosive Force"
	desc = "The user learns to throw their weight into blows. P.Off++, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/arm)
/datum/skill/force/after_learn()
	savant<<"You punch real hard."
	savant.physoffBuff+=0.3
	savant.techniqueBuff+=0.05
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/force/before_forget()
	savant<<"You feel weak."
	savant.physoff-=0.3
	savant.technique-=0.05
	savant.bodyreadiness-=1
	savant.didbodychange=1

//technique buffs

/datum/skill/precision
	skilltype = "Body Buff"
	name = "Muscular Precision"
	desc = "The user improves their coordination. P.Off+, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/physical)
/datum/skill/precision/after_learn()
	savant<<"Your body is a machine."
	savant.physoffBuff+=0.05
	savant.techniqueBuff+=0.2
	savant.bodyreadiness+=1
	savant.didbodychange=1
/datum/skill/precision/before_forget()
	savant<<"You feel gangly and uncoordinated."
	savant.physoffBuff-=0.05
	savant.techniqueBuff-=0.2
	savant.bodyreadiness-=1
	savant.didbodychange=1

/datum/skill/blocking
	skilltype = "Body Buff"
	name = "Basic Blocking"
	desc = "The user improves their active defense. P.Def+, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/precision)
/datum/skill/blocking/after_learn()
	savant<<"Your can catch some blows."
	savant.physdefBuff+=0.2
	savant.techniqueBuff+=0.1
	savant.bodyskill+=1
	savant.didbodychange=1
/datum/skill/blocking/before_forget()
	savant<<"You feel unprepared."
	savant.physoffBuff-=0.2
	savant.techniqueBuff-=0.1
	savant.bodyskill-=1
	savant.didbodychange=1

/datum/skill/preparedness
	skilltype = "Body Buff"
	name = "Preparedness"
	desc = "The user improves their all-around ability to respond to threats. P.Def+, Tech+, Spd+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 0
	prereqs = list(new/datum/skill/precision)
/datum/skill/preparedness/after_learn()
	savant<<"You can feel the attacks coming."
	savant.physdefBuff+=0.05
	savant.techniqueBuff+=0.25
	savant.speedBuff+=0.05
	savant.bodyskill+=1
	savant.didbodychange=1
/datum/skill/preparedness/before_forget()
	savant<<"You feel unready."
	savant.physdefBuff-=0.05
	savant.techniqueBuff-=0.25
	savant.speedBuff-=0.05
	savant.bodyskill-=1
	savant.didbodychange=1

/datum/skill/bprecision
	skilltype = "Body Buff"
	name = "Brutal Precision"
	desc = "Precision for the sake of precision. Tech+++, KiMod+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 2
	skillcost = 1
	enabled = 0
	prereqs = list(new/datum/skill/preparedness)
/datum/skill/bprecision/after_learn()
	savant<<"Your mind tingles with new sensation."
	savant.techniqueBuff+=0.5
	savant.genome.add_to_stat("Energy Level",0.1)
	savant.bodyskill+=1
	savant.didbodychange=1
/datum/skill/bprecision/before_forget()
	savant<<"You feel lost."
	savant.techniqueBuff-=0.5
	savant.genome.sub_to_stat("Energy Level",0.1)
	savant.bodyskill-=1
	savant.didbodychange=1