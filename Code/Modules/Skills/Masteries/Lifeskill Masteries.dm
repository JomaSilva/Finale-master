mob/var
	ForagingSkill=0
	FarmingSkill=0
	FishingSkill=0
	CookingSkill=0

/datum/mastery/Life
	icon = 'Ability.dmi'
	types = list("Mastery","Life")
	battle = 0

	expscale(num)
		if(!savant)
			return
		var/gain = round(max(1,num*max(0.1,gexprate*savant.lifeexprate)))
		if(lifeskillcap&&level>=lifeskillcap)
			gain = 0
		return gain

	Fishing
		name = "Fishing"
		desc = "Master the art of catching food out of the water. Maximally comfy."
		lvltxt = "Getting better at fishing improves your odds of catching fish, alongside increasing the types of fish you can catch.\nLevel 15: Trout\nLevel 35:Salmon"
		visible = 1

		acquire(mob/M)
			..()
			savant.FishingSkill+=1

		remove()
			if(!savant)
				return
			savant.FishingSkill-=level
			..()

		levelstat()
			..()
			savant<<"You're on your way to becoming a fishing master! Your Fishing is now level [level]!"
			savant.FishingSkill+=1
			if(level == 15)
				savant<<"You now have a chance to catch Trout!"
			if(level == 35)
				savant<<"You now have a chance to catch Salmon!"

	Cooking
		name = "Cooking"
		desc = "Become the world's next top chef! Mastering cooking enables you to succeed at cooking more often, and cook more complex food."
		lvltxt = "Getting better at cooking reduces your chance of burning food and unlocks better foods to cook."
		visible = 1

		acquire(mob/M)
			..()
			savant.CookingSkill+=1

		remove()
			if(!savant)
				return
			savant.CookingSkill-=level
			..()

		levelstat()
			..()
			savant<<"You're on your way to becoming a master chef! Your Cooking is now level [level]!"
			savant.CookingSkill+=1

	Foraging
		name = "Foraging"
		desc = "Your ability to forage affects how much food you can gather from plants."
		lvltxt = "Getting better at foraging increases how much food you can gather, and what you can gather from."
		visible = 1

		acquire(mob/M)
			..()
			savant.ForagingSkill+=1

		remove()
			if(!savant)
				return
			savant.ForagingSkill-=level
			..()

		levelstat()
			..()
			savant<<"You're becoming more skilled with foraging! Your Foraging is now level [level]!"
			savant.ForagingSkill+=1

	Farming
		name = "Farming"
		desc = "Live the humble life of a farmer, growing plants for food and other uses."
		lvltxt = "Getting better at farming increases how fast your crops grow, and what you can grow."
		visible = 1

		acquire(mob/M)
			..()
			savant.FarmingSkill+=1

		remove()
			if(!savant)
				return
			savant.FarmingSkill-=level
			removeverb(/mob/keyable/verb/Appraise_Plant)
			..()

		levelstat()
			..()
			savant<<"You're learning the ways of the farmer! Your Farming is now level [level]!"
			savant.FarmingSkill+=1
			if(level==10)
				addverb(/mob/keyable/verb/Appraise_Plant)

	Swimming
		name = "Swimming"
		desc = "Get better at splashing around in the water, in the hopes of not drowning."
		lvltxt = "Getting better at swimming decreases how much energy it consumes."
		visible = 1

		remove()
			if(!savant)
				return
			savant.swimmastery-=(level-1)/100
			..()

		levelstat()
			..()
			savant<<"You're getting better at swimming! Your Swimming is now level [level]!"
			savant.swimmastery+=0.01

	Mining
		name = "Mining"
		desc = "Extract ores by punching rocks."
		lvltxt = "Getting better at mining lets you punch harder rocks.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your mining skill improves! Your Mining is now level [level]!"

	Woodcutting
		name = "Woodcutting"
		desc = "Chop down trees with your fists."
		lvltxt = "Getting better at woodcutting lets you punch sturdier trees.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your woodcutting skill improves! Your Woodcutting is now level [level]!"

	Harvesting
		name = "Harvesting"
		desc = "Punch materials out of plants."
		lvltxt = "Getting better at harvesting lets you punch more complex plants.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your harvesting skill improves! Your Harvesting is now level [level]!"

	Skinning
		name = "Skinning"
		desc = "Deconstruct corpses for materials."
		lvltxt = "Getting better at skinning lets you skin more powerful creatures.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your skinning skill improves! Your Skinning is now level [level]!"

//verbs go down here

mob/keyable/verb/Appraise_Plant()
	var/list/plantlist = list()
	for(var/obj/Plants/p in view(3))
		plantlist+=p
	var/obj/Plants/P = input(usr,"Which plant would you like to appraise?","",null) in plantlist
	if(!P)
		return
	usr<<"You judge the plant as follows..."
	usr<<"[P.growthPercent]% grown."
	if(P.growthPercent>=0.5)
		usr<<"Ready to harvest."
		if(usr.ForagingSkill>=10)
			usr<<"You guess you can harvest [round(P.harvestYield * P.growthPercent * max(usr.ForagingSkill/10,1),1)] items."
	else
		usr<<"Not ready to harvest"
	if(P.planter&&usr.FarmingSkill>=20)
		usr<<"This crop was planted."
