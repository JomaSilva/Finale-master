/datum/skill/tree/Bodybuilding
	name = "Advanced Bodybuilding"
	desc = "Learn to better train your body."
	maxtier = 3
	tier=2
	enabled=0
	allowedtier = 1
	constituentskills = list(new/datum/skill/Bodybuilding/Harder_Body,new/datum/skill/Bodybuilding/God_Bod,new/datum/skill/Bodybuilding/Workout_Routine,\
	new/datum/skill/Bodybuilding/One_Hundred,new/datum/skill/Bodybuilding/TheHolyTrinity,new/datum/skill/Bodybuilding/Grace,new/datum/skill/Bodybuilding/Workout_Routine_Three,new/datum/skill/stalwart,new/datum/skill/Ultradense_Body,new/datum/skill/Atomic_Point,\
	new/datum/skill/Bodybuilding/Workout_Routine_Two,new/datum/skill/Bodybuilding/One_Training,new/datum/skill/Bodybuilding/One_Punch,new/datum/skill/Blow,new/datum/skill/Power,new/datum/skill/Infinite_Strength)

/datum/skill/tree/Bodybuilding/growbranches()
	if(invested>=1&&invested<4)
		allowedtier=2
	if(invested>=4)
		allowedtier=3
		enabletree(/datum/skill/tree/Wrestling)
	if(invested>=6)
		allowedtier=4

/datum/skill/tree/Bodybuilding/prunebranches()
	if(invested<4&&invested>=1)
		allowedtier=2
	if(invested<1)
		allowedtier=1

/datum/skill/Bodybuilding/Harder_Body
	skilltype = "Physical"
	name = "Harder Body"
	desc = "Your body becomes much harder, allowing yourself to take attacks more easily. P.Def++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	after_learn()
		to_chat(savant, "Your body grows a thick layer of padding over the top of your regular skin.")
		savant.physdefBuff += 0.3
	before_forget()
		to_chat(savant, "The thick layer of padding that once laid on top of your skin disintergrates, leaving somewhat vunerable skin underneath.")
		savant.physdefBuff -= 0.3

/datum/skill/Bodybuilding/God_Bod
	skilltype = "Physical"
	name = "God 'Bod"
	desc = "Y-you're fucking stacked. You no longer have a mere 'six pack' or whatever those mortals call it. /fit/ certified. P.Off+, P.Def+, Spd+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	after_learn()
		to_chat(savant, "Your body molds into it's utter peak.")
		savant.physdefBuff += 0.1
		savant.physoffBuff += 0.1
		savant.speedBuff += 0.1
	before_forget()
		to_chat(savant, "Your body falls from the peak, and you feel intense sorrow. /fit/ disapproves.")
		savant.physdefBuff -= 0.1
		savant.physoffBuff -= 0.1
		savant.speedBuff -= 0.1

/datum/skill/Bodybuilding/Workout_Routine
	skilltype = "Physical"
	name = "Workout Routine"
	desc = "Whatever it is you're doing, it's making you less tired from doing everything else... StamGain+, Will+, Satiety+"
	can_forget = TRUE
	common_sense = FALSE
	maxlevel = 0
	tier = 2
	after_learn()
		to_chat(savant, "You feel your stamina slowly rising...")
		savant.staminagainMod += 0.1
		savant.willpowerMod += 0.1
		savant.satiationMod += 0.1
	before_forget()
		to_chat(savant, "Your workout routine no longer seems to do the trick anymore.")
		savant.staminagainMod -= 0.1
		savant.willpowerMod -= 0.1
		savant.satiationMod -= 0.1

/datum/skill/Bodybuilding/One_Hundred
	skilltype = "Physical"
	name = "One Hundred"
	desc = "One hundred pushups! One hundred situps! One hundred squats! Ten kilometer run, every single day!"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	var/storedBP
	var/hiddenpot
	after_learn()
		to_chat(savant, "Whatever stamina issues you had, you no longer have. Also, you seem a bit stronger?")
		storedBP = max(1,savant.BP*0.01)
		savant.BP+=storedBP
		hiddenpot = (savant.relBPmax*2)
		savant.hiddenpotential += hiddenpot
		savant.staminagainMod += 0.1
		savant.physoffBuff += 0.5
		savant.physdefBuff += 0.5
		savant.speedBuff += 0.5
	before_forget()
		savant.BP -= storedBP
		savant.safetyBP -= storedBP
		savant.hiddenpotential = min(0,savant.hiddenpotential - hiddenpot)
		savant.staminagainMod -= 0.1
		savant.physoffBuff -= 0.5
		savant.physdefBuff -= 0.5
		savant.speedBuff -= 0.5

/datum/skill/Bodybuilding/TheHolyTrinity
	skilltype = "Physical"
	name = "The Holy Trinity"
	desc = "From your hugeness, a faint whisper has begun in your ear! It's time to choose..."
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	skillcost = 2
	maxlevel = 2
	expbarrier = 100
	var/TrinityType = null
	after_learn()
		to_chat(savant, "Choose which of the Trinity you wish to represent.")
		switch(input(savant,"Which Trinity do you represent? All: Stamina+, Van-sama: Physdef+++, Physoff+, Decline+, Ricardo: Physdef++, Physoff++, Decline++,Aniki: Physdef+, Physoff+++, Decline+","Trinity Selection","Van-sama") in list("Van-sama","Ricardo","Aniki"))
			if("Van-sama")
				to_chat(savant, "The effects of Van-sama's wisdom have been imparted onto you.")
				savant.staminagainMod += 0.1
				savant.physdefBuff += 0.3
				savant.physoffBuff += 0.1
				savant.genome.add_to_stat("Lifespan",0.10)
				TrinityType = "Van-sama"
			if("Ricardo")
				to_chat(savant, "The effects of Ricardo's youthfulness have been imparted onto you.")
				savant.staminagainMod += 0.1
				savant.physdefBuff += 0.2
				savant.physoffBuff += 0.2
				savant.genome.add_to_stat("Lifespan",0.15)
				TrinityType = "Ricardo"
			if("Aniki")
				to_chat(savant, "The effects of Aniki's wisdom have been imparted onto you.")
				savant.staminagainMod += 0.1
				savant.physdefBuff += 0.1
				savant.physoffBuff += 0.3
				savant.genome.add_to_stat("Lifespan",0.10)
				TrinityType = "Aniki"
	before_forget()
		to_chat(savant, "The effects of your chosen Trinity vanish.")
		switch(TrinityType)
			if("Van-sama")
				savant.staminagainMod -= 0.1
				savant.physdefBuff -= 0.3
				savant.physoffBuff -= 0.1
				savant.genome.sub_to_stat("Lifespan",0.10)
			if("Ricardo")
				savant.staminagainMod += 0.1
				savant.physdefBuff -= 0.2
				savant.physoffBuff -= 0.2
				savant.genome.sub_to_stat("Lifespan",0.15)
			if("Aniki")
				savant.staminagainMod -= 0.1
				savant.physdefBuff -= 0.1
				savant.physoffBuff -= 0.3
				savant.genome.sub_to_stat("Lifespan",0.10)
		if(level >= 2)
			switch(TrinityType)
				if("Van-sama") unassignverb(/mob/keyable/verb/Taunt)
				if("Aniki") unassignverb(/mob/keyable/verb/Counter_Taunt)
				if("Ricardo") unassignverb(/mob/keyable/verb/Slap)
		TrinityType = null
	login(mob/logger)
		..()
		logger.trinitytype = TrinityType
		if(level >= 2)
			switch(TrinityType)
				if("Van-sama") assignverb(/mob/keyable/verb/Taunt)
				if("Aniki") assignverb(/mob/keyable/verb/Counter_Taunt)
				if("Ricardo") assignverb(/mob/keyable/verb/Slap)
	effector()
		..()
		switch(level)
			if(1)
				if(levelup) levelup = 0
				if(savant.IsInFight) exp++
			if(2)
				if(levelup)
					levelup = 0
					switch(TrinityType)
						if("Van-sama") assignverb(/mob/keyable/verb/Taunt)
						if("Aniki") assignverb(/mob/keyable/verb/Counter_Taunt)
						if("Ricardo") assignverb(/mob/keyable/verb/Slap)
					to_chat(savant, "The Trinity has bestowed upon you a gift.")
		return

mob/var
	trinitytype = ""
mob/keyable/verb/Taunt()
	set category = "Skills"
	var/kireq=usr.Ephysoff*usr.BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD += 10
		to_chat(viewers(usr), "<font color=red><font size = 3>[usr]: Fuck you!</font></font>")
		for(var/mob/M in view(10))
			if(M.target && M != usr && prob(100 - (M.Ewillpower * 20)))
				M.target = usr
				to_chat(M, "<font color=red><font size = 3>[usr] irritates you too much! Your target is them!")
		sleep(10)
	else to_chat(usr, "You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki.")

mob/keyable/verb/Slap()
	set category = "Skills"
	var/kireq=usr.Ephysoff*usr.BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD += 10
		to_chat(viewers(usr), "<font color=red><font size = 3>[usr]: You like this, baby?</font></font>")
		for(var/mob/M in view(10))
			if(M.target && M != usr && prob(100 - (M.Ewillpower * 25)))
				M.stagger+=1
				spawn(15) M.stagger-=1
				to_chat(M, "<font color=red><font size = 3>[usr] slaps his bum, stunning you for a second!")
		sleep(10)
	else to_chat(usr, "You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki.")

mob/keyable/verb/Counter_Taunt()
	set category = "Skills"
	var/kireq=usr.Ephysoff*usr.BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD += 10
		to_chat(viewers(usr), "<font color=red><font size = 3>[usr]: Oh yeah? Well fuck you too buddy!</font></font>")
		for(var/mob/M in view(10))
			if(M == usr.target && prob(100 - (M.Ewillpower * 22)))
				to_chat(M, "<font color=red><font size = 3>[usr] deals some mental damage to you!!")
				var/dmg = attackCalcs(M,0,0,0,2) * BPModulus(expressedBP,M.expressedBP) * 0.25
				damage_mob(M,dmg)
		sleep(10)
	else to_chat(usr, "You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki.")

/datum/skill/Bodybuilding/Grace
	skilltype = "Physical"
	name = "Grace"
	desc = "Depending on your Trinity, gain a unique passive ability. Van-sama: Increased defense the lower your health is. Ricardo: Gain increased regeneration. Also willpower and technique depending on your health and ki. Aniki: Increased offense the lower your health is."
	tier=4
	skillcost = 0
	prereqs = list(new/datum/skill/Bodybuilding/TheHolyTrinity)
	var/boost
	var/boosting
	var/TrinityType = null
	after_learn()
		switch(savant.trinitytype)
			if("Van-sama")
				to_chat(savant, "The effects of Van-sama's wisdom have been imparted onto you.")
				savant.willpowerMod += 0.05
				savant.staminagainMod += 0.1
				savant.genome.add_to_stat("Lifespan",0.5)
				TrinityType = "Van-sama"
			if("Ricardo")
				to_chat(savant, "The effects of Ricardo's youthfulness have been imparted onto you.")
				savant.staminagainMod += 0.05
				savant.willpowerMod += 0.05
				savant.genome.add_to_stat("Regeneration",1)
				savant.genome.add_to_stat("Lifespan",0.10)
				TrinityType = "Ricardo"
			if("Aniki")
				to_chat(savant, "The effects of Aniki's wisdom have been imparted onto you.")
				savant.staminagainMod += 0.05
				savant.willpowerMod += 0.1
				savant.genome.add_to_stat("Lifespan",0.5)
				TrinityType = "Aniki"
	before_forget()
		to_chat(savant, "The effects of your chosen Trinity vanish.")
		switch(TrinityType)
			if("Van-sama")
				savant.willpowerMod -= 0.05
				savant.staminagainMod -= 0.1
				savant.genome.sub_to_stat("Lifespan",0.5)
				if(boost) savant.Tphysoff -= boost
			if("Ricardo")
				savant.willpowerMod -= 0.05
				savant.staminagainMod -= 0.05
				savant.genome.add_to_stat("Regeneration",1)
				savant.genome.sub_to_stat("Lifespan",0.10)
				if(boost)
					savant.Ttechnique -= boost
					savant.willpowerMod -= boost
			if("Aniki")
				savant.willpowerMod -= 0.1
				savant.staminagainMod -= 0.05
				savant.genome.sub_to_stat("Lifespan",0.5)
				if(boost) savant.Tphysdef -= boost
	effector()
		..()
		switch(TrinityType)
			if("Van-sama")
				if(boosting) return
				boosting=1
				var/nboost = 2 - (round(savant.HP)/100)
				if(nboost != boost)
					if(boost) savant.Tphysoff -= boost
					savant.Tphysoff += nboost
					boost = nboost
				boosting = 0
			if("Ricardo")
				if(boosting) return
				boosting=1
				var/nboost = 2 - (round(savant.HP)/100)
				if(nboost != boost)
					if(boost)
						savant.Ttechnique -= boost
						savant.willpowerMod -= boost
					savant.Ttechnique += nboost
					savant.willpowerMod += nboost
					boost = nboost
				boosting = 0
			if("Aniki")
				if(boosting) return
				boosting=1
				var/nboost = 2 - (round(savant.HP)/100)
				if(nboost != boost)
					if(boost) savant.Tphysdef -= boost
					savant.Tphysdef += nboost
					boost = nboost
				boosting = 0

/datum/skill/Bodybuilding/One_Punch
	skilltype = "Physical"
	name = "One Punch"
	desc = "When fighting a foe, the longer you don't attack, the more damage your next attack will do. Also, gain some more hidden potential and physical offense."
	tier=3
	skillcost = 1
	prereqs = list(new/datum/skill/Bodybuilding/One_Hundred)
	can_forget = TRUE
	common_sense = FALSE
	var/storedBP
	var/hiddenpot
	var/tmp/boost
	var/tmp/boosting
	var/tmp/booster
	var/tmp/delay
	after_learn()
		to_chat(savant, "You seem a bit stronger.")
		storedBP = max(1,savant.BP*0.01)
		savant.BP+=storedBP
		hiddenpot = (savant.relBPmax*0.5)
		savant.hiddenpotential += hiddenpot
		savant.staminagainMod += 0.1
	before_forget()
		savant.BP -= storedBP
		savant.safetyBP -= storedBP
		savant.hiddenpotential = min(0,savant.hiddenpotential - hiddenpot)
		savant.staminagainMod -= 0.1
		if(boost) savant.Tphysoff -= boost
	effector()
		..()
		if(!delay || world.time <= delay) return
		else delay = world.time + 2
		if(savant.IsInFight && prob(10))
			if(boosting) return
			boosting=1
			booster++
			booster = min(booster,30)
			var/nboost = 1 + (booster/100)
			if(nboost != boost)
				if(boost) savant.Tphysoff -= boost
				savant.Tphysoff += nboost
				boost = nboost
			boosting = 0
		if((savant.attacking && !savant.train) || !savant.IsInFight)
			booster = 0

/datum/skill/Bodybuilding/One_Training
	skilltype = "Physical"
	name = "One Training"
	desc = "Gain a increase to an attack proportional to how long you've trained before that fight. Also, gain some more hidden potential and physical offense."
	tier=2
	skillcost = 1
	prereqs = list(new/datum/skill/Bodybuilding/One_Hundred)
	can_forget = TRUE
	common_sense = FALSE
	var/storedBP
	var/hiddenpot
	var/tmp/boost
	var/tmp/boosting
	var/tmp/delay
	var/booster
	after_learn()
		to_chat(savant, "You seem a bit stronger.")
		storedBP = max(1,savant.BP*0.01)
		savant.BP+=storedBP
		hiddenpot = (savant.relBPmax*0.5)
		savant.hiddenpotential += hiddenpot
		savant.staminagainMod += 0.1
	before_forget()
		savant.BP -= storedBP
		savant.safetyBP -= storedBP
		savant.staminagainMod -= 0.1
		savant.hiddenpotential = min(0,savant.hiddenpotential - hiddenpot)
		if(boost) savant.Tphysoff -= boost
	effector()
		..()
		if(!delay || world.time <= delay) return
		else delay = world.time + 2
		if(savant.train && prob(10))
			if(boosting) return
			boosting=1
			booster++
			booster = min(booster,30)
			var/nboost = 1 + (booster/100)
			if(nboost != boost)
				if(boost) savant.Tphysoff -= boost
				savant.Tphysoff += nboost
				boost = nboost
			boosting = 0
		if((savant.attacking && !savant.train) || savant.grabbee)
			booster = 0

/datum/skill/Bodybuilding/Workout_Routine_Two
	skilltype = "Physical"
	name = "Workout Routine (II)"
	desc = "Increase your stamina gain, willpower, and nutrition gain. Also, by training (sparring or boxing) you can slowly increase your physical stats some more."
	tier=2
	skillcost = 1
	prereqs = list(new/datum/skill/Bodybuilding/Workout_Routine)
	var/boost
	after_learn()
		to_chat(savant, "You feel your stamina slowly rising...")
		savant.staminagainMod += 0.1
		savant.willpowerMod += 0.1
		savant.satiationMod += 0.1
	before_forget()
		to_chat(savant, "Your workout routine no longer seems to do the trick anymore.")
		savant.staminagainMod -= 0.1
		savant.willpowerMod -= 0.1
		savant.satiationMod -= 0.1
		switch(level)
			if(2)
				savant.physdefBuff -= 0.5
				savant.physoffBuff -= 0.5
				savant.speedBuff -= 0.5
			if(3)
				savant.physdefBuff -= 1
				savant.physoffBuff -= 1
				savant.speedBuff -= 1
	effector()
		..()
		if(savant.train || savant.IsInFight) exp += 1
		switch(level)
			if(1) if(levelup) levelup = 0
			if(2)
				if(levelup)
					levelup = 0
					to_chat(savant, "Your muscles feel stronger.")
					savant.physdefBuff += 0.5
					savant.physoffBuff += 0.5
					savant.speedBuff += 0.5
			if(3)
				if(levelup)
					levelup = 0
					to_chat(savant, "Your muscles feel stronger.")
					savant.physdefBuff += 0.5
					savant.physoffBuff += 0.5
					savant.speedBuff += 0.5

/datum/skill/Bodybuilding/Workout_Routine_Three
	skilltype = "Physical"
	name = "Workout Routine (III)"
	desc = "Instead of increasing stamina, this is another chance to continue increasing your stats by training (sparring or boxing)."
	tier=3
	skillcost = 1
	prereqs = list(new/datum/skill/Bodybuilding/Workout_Routine_Two)
	before_forget()
		to_chat(savant, "Your workout routine no longer seems to do the trick anymore.")
		switch(level)
			if(2)
				savant.physdefBuff -= 1
				savant.physoffBuff -= 1
				savant.speedBuff -= 1
			if(3)
				savant.physdefBuff -= 2
				savant.physoffBuff -= 2
				savant.speedBuff -= 2
	effector()
		..()
		if(savant.train || savant.IsInFight) exp += 1
		switch(level)
			if(1) if(levelup) levelup = 0
			if(2)
				if(levelup)
					levelup = 0
					to_chat(savant, "Your muscles feel stronger.")
					savant.physdefBuff += 1
					savant.physoffBuff += 1
					savant.speedBuff += 1
			if(3)
				if(levelup)
					levelup = 0
					to_chat(savant, "Your muscles feel stronger.")
					savant.physdefBuff += 1
					savant.physoffBuff += 1
					savant.speedBuff += 1