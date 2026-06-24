/datum/skill/tree/Wrestling
	name = "Wrestling"
	desc = "Learn how to better grab people. (PHYSOFF + TECH)"
	maxtier = 3
	tier=3
	enabled=0
	allowedtier = 1
	constituentskills = list(new/datum/skill/Wrestling/Grabber,new/datum/skill/Wrestling/Superstar,new/datum/skill/Wrestling/Rasslin,new/datum/skill/Wrestling/Main_Event)
	growbranches()
		..()
		allowedtier = min(invested + 1,6)

/datum/skill/Wrestling/Grabber
	skilltype = "Physical"
	name = "Grabber"
	desc = "Your technique related to grabs increases. PhysOff+ PhysDef+ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"The moves of other animals and creatures influence your art."
		savant.physdefBuff += 0.1
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"The world around you has no hold on your movements."
		savant.physdefBuff -= 0.1
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Hold)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to hold an opponent! You can use Hold!"
					assignverb(/mob/keyable/verb/Hold)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Hold)

/datum/skill/Wrestling/Superstar
	skilltype = "Physical"
	name = "Super Star"
	desc = "Grabbing becomes an art to you! You're an artist, the coolest of your kind... YOU'RE A SUPER STAR! PhysOff+ Tech+++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"The moves of other animals and creatures influence your art."
		savant.physoffBuff += 0.1
		savant.techniqueBuff += 0.4
	before_forget()
		savant<<"The world around you has no hold on your movements."
		savant.physoffBuff -= 0.1
		savant.techniqueBuff -= 0.4
		unassignverb(/mob/keyable/verb/Clench)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to damage opponents better in grabs! You can use Clench!"
					assignverb(/mob/keyable/verb/Clench)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Clench)

/datum/skill/Wrestling/Rasslin
	skilltype = "Physical"
	name = "Rasslin'"
	desc = "Your grabbing technique becomes a bit more savage in nature. PhysOff++ Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"The moves of other animals and creatures influence your art."
		savant.physoffBuff += 0.2
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"The world around you has no hold on your movements."
		savant.physoffBuff -= 0.2
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Power_Slam)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to severely slam opponents in a grab! You can use Power Slam!"
					assignverb(/mob/keyable/verb/Power_Slam)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Power_Slam)

/datum/skill/Wrestling/Main_Event
	skilltype = "Physical"
	name = "Main Event"
	desc = "OH SHIT! THE WWE SUPER STAR IS REELING UP FOR A NEW MOVE... Using your skills, further your wrestling career, with a legendary move called the Suplex. Physoff++ Tech++++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 3
	expbarrier = 100
	maxlevel = 2
	after_learn()
		savant<<"Your body begins to itch... It itches for your enemies lying broken on the ground!!"
		savant.physoffBuff += 0.2
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"You no longer begin to itch... the Suplex is no more..."
		savant.physoffBuff -= 0.2
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Suplex)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "IIIIITS THE MAIN EVENT! THE WWE SUPER STAR... HE'S PICKING UP HIS OPPONENT... OH! OH! ITS A FUCKIN SUPLEX! You can Suplex!"
					assignverb(/mob/keyable/verb/Suplex)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Suplex)