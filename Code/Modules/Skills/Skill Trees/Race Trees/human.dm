/datum/skill/tree/human
	name="Human Racials"
	desc="Given to all Humans at the start."
	maxtier=4
	tier=0
	allowedtier = 4
	enabled=1
	can_refund = FALSE
	compatible_races = list("Human")
	constituentskills = list(new/datum/skill/human/Complete_Will,new/datum/skill/general/Hardened_Body,\
	new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,new/datum/skill/human/Jack_Of_Trades,\
	new/datum/skill/human/Intelligent_Man,new/datum/skill/human/Martial_Prowessor)
	var/acquiredFormMastery

/datum/skill/human/Complete_Will
	skilltype = "Physical"
	name = "Complete Will"
	desc = "As a human, your willpower can get to insane proportions, granting you the ability to go days without food. StamGain++, Will++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	after_learn()
		savant<<"Your willpower increases a bunch."
		savant.willpowerMod += 0.3
		savant.staminagainMod += 0.3
	before_forget()
		savant<<"Your willpower finds itself weak."
		savant.willpowerMod -= 0.3
		savant.staminagainMod -= 0.3

/datum/skill/human/Jack_Of_Trades
	skilltype = "Physical"
	name = "Jack of Trades"
	desc = "As a human, you can do anything. Likewise, your ability to do everything increases. Perhaps if you meditate on what you've learned... Stats+++"
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 2
	tier = 2
	maxlevel = 2
	expbarrier = 15000
	after_learn()
		savant<<"Your abilities increase."
		savant.physoffBuff += 0.1
		savant.physdefBuff += 0.1
		savant.techniqueBuff += 0.1
		savant.kioffBuff += 0.1
		savant.kidefBuff += 0.1
		savant.kiskillBuff += 0.1
		savant.speedBuff += 0.1
		savant.magiBuff += 0.1
	before_forget()
		savant<<"Your abilities find themselves a bit weaker."
		switch(level)
			if(0)
				savant.physoffBuff -= 0.1
				savant.physdefBuff -= 0.1
				savant.techniqueBuff -= 0.1
				savant.kioffBuff -= 0.1
				savant.kidefBuff -= 0.1
				savant.kiskillBuff -= 0.1
				savant.speedBuff -= 0.1
				savant.magiBuff -= 0.1
			if(1)
				savant.physoffBuff -= 0.3
				savant.physdefBuff -= 0.3
				savant.techniqueBuff -= 0.3
				savant.kioffBuff -= 0.3
				savant.kidefBuff -= 0.3
				savant.kiskillBuff -= 0.3
				savant.speedBuff -= 0.3
				savant.magiBuff -= 0.3
			if(2)
				savant.physoffBuff -= 0.6
				savant.physdefBuff -= 0.6
				savant.techniqueBuff -= 0.6
				savant.kioffBuff -= 0.6
				savant.kidefBuff -= 0.6
				savant.kiskillBuff -= 0.6
				savant.speedBuff -= 0.6
				savant.magiBuff -= 0.5

/datum/skill/human/Jack_Of_Trades/effector()
	..()
	switch(level)
		if(0)
			if(levelup)
				levelup = 0
			if(savant.med)
				exp+=1
		if(1)
			if(levelup)
				levelup = 0
				savant << "You have gained insight into the world! As a human, you can do anything. Likewise, your ability to do everything increases even further."
				savant.physoffBuff += 0.2
				savant.physdefBuff += 0.2
				savant.techniqueBuff += 0.2
				savant.kioffBuff += 0.2
				savant.kidefBuff += 0.2
				savant.kiskillBuff += 0.2
				savant.speedBuff += 0.2
				savant.magiBuff += 0.2
			if(savant.med)
				exp+=1
		if(2)
			if(levelup)
				levelup = 0
				savant << "Your insight has reached its peak! As a human, you can do anything. Likewise, your ability to do everything increases even beyond normal."
				savant.physoffBuff += 0.3
				savant.physdefBuff += 0.3
				savant.techniqueBuff += 0.3
				savant.kioffBuff += 0.3
				savant.kidefBuff += 0.3
				savant.kiskillBuff += 0.3
				savant.speedBuff += 0.3
				savant.magiBuff += 0.2
			if(savant.med)
				exp+=1

/datum/skill/human/Intelligent_Man
	skilltype = "Physical"
	name = "Intelligent Man"
	desc = "Humans can be pretty darn smart, but only if they choose to be. If you do focus on your brain, you might find other things lacking. TechMod*, P.Def-, KiOff-"
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 2
	tier = 2
	after_learn()
		savant<<"Your intelligence reaches a new maximum."
		savant.genome.add_to_stat("Tech Modifier",2)
		savant.physdefBuff -= 0.1
		savant.kioffBuff -= 0.1
	before_forget()
		savant<<"The world feels a bit dimmer."
		savant.genome.sub_to_stat("Tech Modifier",2)
		savant.physdefBuff += 0.1
		savant.kioffBuff += 0.1

/datum/skill/human/Martial_Prowessor
	skilltype = "Physical"
	name = "Martial Prowessor"
	desc = "Gain additional technique, which is natural to your race. Perhaps if you focus and meditate on your technique... Tech++++"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 2
	tier = 1
	maxlevel = 3
	expbarrier = 10000
	after_learn()
		savant<<"Your martial technique increases."
		savant.technique += 0.1
	before_forget()
		savant<<"Your martial technique decreases."
		switch(level)
			if(0)
				savant.technique -= 0.1
			if(1)
				savant.technique -= 0.25
			if(2)
				savant.technique -= 0.45
			if(3)
				savant.technique -= 0.75

/datum/skill/human/Martial_Prowessor/effector()
	..()
	switch(level)
		if(0)
			if(levelup)
				levelup = 0
			if(savant.med)
				exp+=1
		if(1)
			if(levelup)
				levelup = 0
				savant << "Your martial technique increases further!"
				savant.technique += 0.15
			if(savant.med)
				exp+=1
		if(2)
			if(levelup)
				levelup = 0
				savant << "Your martial technique increases to new heights!."
				savant.technique += 0.2
			if(savant.med)
				exp+=1
		if(3)
			if(levelup)
				levelup = 0
				savant << "Your martial technique increases even further beyond!."
				savant.technique += 0.3
			if(savant.med)
				exp+=1
