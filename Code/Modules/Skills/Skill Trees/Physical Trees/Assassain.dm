/datum/skill/tree/Assassain
	name = "Assassain"
	desc = "Learn how to use precison strikes to defeat an opponent. (TECH)"
	maxtier = 3
	tier=3
	enabled=0
	allowedtier = 1
	constituentskills = list(new/datum/skill/Assassain/Precise_Arts,new/datum/skill/Assassain/Reverbrate,new/datum/skill/Assassain/Omae_Wa_Moe,new/datum/skill/Assassain/Hokuto_no_Shinken,\
		new/datum/skill/Assassain/Cutthroat,new/datum/skill/Assassain/Backstab,new/datum/skill/Assassain/Sneak,new/datum/skill/Assassain/Trip)

	growbranches()
		..()
		allowedtier = min(invested + 1,6)

/datum/skill/Assassain/Precise_Arts
	skilltype = "Physical"
	name = "Precise Arts"
	desc = "Your technique related to grabs increases. PhysOff+ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"You notice your strikes do more damage when you become more precise with them."
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"Your strikes become imprecise."
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Shock)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to cause some nice damage to a opponent. You can use Shock!"
					assignverb(/mob/keyable/verb/Shock)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Shock)

/datum/skill/Assassain/Reverbrate
	skilltype = "Physical"
	name = "Reverbrate"
	desc = "Through your technique, let your attacks echo throughout the opponent Tech+++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"Your fists begin to echo."
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.4
	before_forget()
		savant<<"Your fists lose their echo."
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.4
		unassignverb(/mob/keyable/verb/Reverb)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to damage opponents over time! You can use Reverb!"
					assignverb(/mob/keyable/verb/Reverb)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Reverb)

/datum/skill/Assassain/Omae_Wa_Moe
	skilltype = "Physical"
	name = "Omae Wa Moe"
	desc = "Your attacks can start severely damaging specific limbs. PhysOff++ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"Your fists' echo increases."
		savant.physoffBuff += 0.2
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"Your fists' echo begins to vanish..."
		savant.physoffBuff -= 0.2
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Precise_Explosion)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to severely damage individual limbs of opponents! You can use Precise Explosion!"
					assignverb(/mob/keyable/verb/Precise_Explosion)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Precise_Explosion)

/datum/skill/Assassain/Hokuto_no_Shinken
	skilltype = "Physical"
	name = "Hokuto no Shinken"
	desc = "You've learned to increase the efficiency and speed of your strikes, allowing you to down a opponent with 100 attacks. Physoff++ Tech++++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"The killer move of the Hokuto Series is within your grasp."
		savant.physoffBuff += 0.2
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"You lose the Hokuto no Shinken prized technique."
		savant.physoffBuff -= 0.2
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Hokuto_Hyakuretsu_Ken)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "ATATATATATATATATATATATATAwawa... You can use an attack that severely damages an opponent, AND THEN AFTER THE ATTACK WILL DAMAGE THEM AGAIN! Hokuto no Shinken Deadly Technique: Hokuto Hyakuretsu Ken!!"
					assignverb(/mob/keyable/verb/Hokuto_Hyakuretsu_Ken)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Hokuto_Hyakuretsu_Ken)
//
//
//
//
//
/datum/skill/Assassain/Cutthroat
	skilltype = "Physical"
	name = "Cutthroat"
	desc = "You learn to take out opponents unexpectedly. PhysOff+ PhysDef+ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"Your clever nature manifests into a more deadly and sneaky one."
		savant.physdefBuff += 0.1
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"You no longer are so cutthroat."
		savant.physdefBuff -= 0.1
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Cutthroat)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to really hurt an offguard opponent! You can use Cutthroat!"
					assignverb(/mob/keyable/verb/Cutthroat)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Cutthroat)

/datum/skill/Assassain/Backstab
	skilltype = "Physical"
	name = "Backstab"
	desc = "Assassinating becomes more of an art at this point... Use an attack that does major damage if the opponent isn't facing you! PhysOff+++ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"The art of assassination leaves its mark."
		savant.physoffBuff += 0.4
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"You lose a mark of death."
		savant.physoffBuff -= 0.4
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Backstab)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to damage opponents from behind! You can use Backstab!"
					assignverb(/mob/keyable/verb/Backstab)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Backstab)

/datum/skill/Assassain/Sneak
	skilltype = "Physical"
	name = "Sneak"
	desc = "Your stealthy nature begins to manifest. PhysOff+ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"Your stealthy nature manifests."
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"Your stealthy nature disappates."
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Sneak)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to turn invisible! You can use Sneak!"
					assignverb(/mob/keyable/verb/Sneak)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Sneak)

/datum/skill/Assassain/Trip
	skilltype = "Physical"
	name = "Trip"
	desc = "Your ruthless nature manifests in your fighting style, letting you temporarily stun a opponent by playing dirty. Physoff+ Tech++++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"Your legs get shifty."
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.4
	before_forget()
		savant<<"You no longer feel the need to play dirty."
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.4
		unassignverb(/mob/keyable/verb/Trip)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "Your feet start dancing! You can Trip!"
					assignverb(/mob/keyable/verb/Trip)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Trip)