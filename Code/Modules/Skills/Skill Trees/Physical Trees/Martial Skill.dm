/datum/skill/tree/MartialSkill
	name = "Martial Arts"
	desc = "Hone your technique."
	maxtier = 3
	tier=2
	allowedtier = 3
	enabled=0
	constituentskills = list(new/datum/skill/MartialSkill/MartialArts,new/datum/skill/MartialSkill/Green_Dean,new/datum/skill/MartialSkill/Catflex,new/datum/skill/flow,new/datum/skill/Relentless_Strikes,new/datum/skill/Burst,\
	new/datum/skill/MartialSkill/Dragon_Sweep,new/datum/skill/MartialSkill/Reflexes_Training,new/datum/skill/MartialSkill/Zanzoken_Rush,new/datum/skill/namek/SaibaPUNCH,\
	new/datum/skill/MartialSkill/Special_Multihit,new/datum/skill/MartialSkill/Wolf_Fang_Fist,new/datum/skill/MartialSkill/Wolf_Hurricane,new/datum/skill/clarity,new/datum/skill/Brutal_Clarity,new/datum/skill/Tao_of_Art)
	mod()
		..()
		savant.mastery_enable(/datum/mastery/Melee/Tactical_Fighting)
	demod()
		savant.mastery_remove(/datum/mastery/Melee/Tactical_Fighting)
		..()
	growbranches()
		..()
		if(invested > 4)
			enabletree(/datum/skill/tree/Assassain)

/datum/skill/MartialSkill/Green_Dean
	skilltype = "Physical"
	name = "Green Dean"
	desc = "The world around you becomes more apparent. In your Martial Arts, you begin to take more from nature. Tech++"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	level=1
	maxlevel = 2
	after_learn()
		savant<<"The moves of other animals and creatures influence your art."
		savant.techniqueBuff += 0.3
	before_forget()
		savant<<"The world around you has no hold on your movements."
		savant.techniqueBuff -= 0.3
		unassignverb(/mob/keyable/verb/Dash_Attack)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to pick up faster movements! You can use Dash Attack!"
					assignverb(/mob/keyable/verb/Dash_Attack)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Dash_Attack)

/datum/skill/MartialSkill/Catflex
	skilltype = "Physical"
	name = "Catflex"
	desc = "You notice the cats around you being able to always land on their feet. In addition, the reflexes they show is astounding! Perhaps you can mimic that? Tech+, Spd+"
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/MartialSkill/Green_Dean)
	tier = 2
	enabled = 0
	maxlevel = 2
	after_learn()
		savant<<"The moves of the cat seep into your dodges and weavings."
		savant.techniqueBuff += 0.2
		savant.speedBuff += 0.1
		savant.dodgeflavors += "whips away from"
	before_forget()
		savant<<"No longer can 'catlike' be a moniker of your movements."
		savant.techniqueBuff -= 0.2
		savant.speedBuff -= 0.1
		savant.dodgeflavors -= "whips away from"
		unassignverb(/mob/keyable/verb/Flip)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to dodge grabs!"
					assignverb(/mob/keyable/verb/Flip)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Flip)

/datum/skill/MartialSkill/Tiger_Paw
	skilltype = "Physical"
	name = "Tiger Paw"
	desc = "You notice the tigers around you being able to savagely strike anything! Perhaps you can mimic that? Tech+, P.Off+"
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/MartialSkill/Green_Dean)
	tier = 2
	enabled = 0
	maxlevel = 2
	after_learn()
		savant<<"The moves of the tiger seep into your attacks and techniques."
		savant.techniqueBuff += 0.2
		savant.physoffBuff += 0.1
		savant.attackflavors += "strikes, Ki claws out at"
		savant.dodgeflavors += "heavily dodges"
	before_forget()
		savant<<"No longer are you similar to a tiger in movements."
		savant.techniqueBuff -= 0.2
		savant.physoffBuff -= 0.1
		savant.attackflavors -= "strikes, Ki claws out at"
		savant.dodgeflavors -= "heavily dodges"
		unassignverb(/mob/keyable/verb/Takedown)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to takedown people (deals bonus damage to flying opponents)!"
					assignverb(/mob/keyable/verb/Takedown)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Takedown)

/datum/skill/MartialSkill/Dragon_Sweep
	skilltype = "Physical"
	name = "Dragon Sweep"
	desc = "You notice the dragons around you can sweep their tail to disorient foes. Perhaps you can mimic that? Tech+, P.Off+"
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/MartialSkill/Green_Dean)
	tier = 2
	enabled = 0
	maxlevel = 2
	after_learn()
		savant<<"The dragon's sweep has been ingrained into you."
		savant.techniqueBuff += 0.2
		savant.physoffBuff += 0.1
		savant.attackflavors += "sweeps outwards, leg catching"
	before_forget()
		savant<<"You no longer need the Dragon's Sweep."
		savant.techniqueBuff -= 0.2
		savant.physoffBuff -= 0.1
		savant.attackflavors -= "sweeps outwards, leg catching"
		unassignverb(/mob/keyable/verb/Stun_Attack)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to stun people!!"
					assignverb(/mob/keyable/verb/Stun_Attack)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Stun_Attack)

/datum/skill/MartialSkill/Reflexes_Training
	skilltype = "Physical"
	name = "Train Reflexes"
	desc = "You further push your reflexes, granting additional mobility and ability. Tech+, P.Off+, Spd+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	maxlevel = 2
	after_learn()
		savant<<"Your dodges and attacks become more flexible."
		savant.techniqueBuff += 0.1
		savant.physoffBuff += 0.1
		savant.speedBuff += 0.1
		savant.attackflavors += "bends skillfully, arm flying at"
		savant.dodgeflavors += "bends away from"
	before_forget()
		savant<<"Your dodges and attacks become less flexible."
		savant.techniqueBuff -= 0.1
		savant.physoffBuff -= 0.1
		savant.speedBuff -= 0.1
		savant.attackflavors -= "bends skillfully, arm flying at"
		savant.dodgeflavors -= "bends away from"
		unassignverb(/mob/keyable/verb/Spin_Attack)
	effector()
		..()
		if(level < maxlevel) if(prob(50)) exp++
		switch(level)
			if(2)
				if(levelup)
					savant << "You're able to spin around in a circle!"
					assignverb(/mob/keyable/verb/Spin_Attack)
					levelup=0
	login(mob/logger)
		..()
		if(level >= 2) assignverb(/mob/keyable/verb/Spin_Attack)
//And this one for Technique.
/datum/skill/clarity
	skilltype = "Technique Buff"
	name = "Clarity"
	desc = "Your Ki flows all around you. You don't need to direct it, and your experienced body will flow with it. Ki Skill+, Technique+++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You start circulating your Ki."
		savant.kiskillBuff+=0.15
		savant.techniqueBuff+=1
	before_forget()
		savant<<"You stop circulating your Ki."
		savant.kiskillBuff-=0.15
		savant.techniqueBuff-=1

/datum/skill/Brutal_Clarity
	skilltype = "Technique Buff"
	name = "Brutal Clarity"
	desc = "\"Empty your mind, be formless, shapeless — like water. Now you put water in a cup, it becomes the cup; You put water into a bottle it becomes the bottle; You put it in a teapot it becomes the teapot. Now water can flow or it can crash. Be water, my friend.\". Technique+++ Gain a buff that increases your technique and power."
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	prereqs = list(new/datum/skill/clarity)
	tier = 3
	after_learn()
		savant<<"You start circulating your Ki."
		savant.techniqueBuff+=2
		assignverb(/mob/keyable/verb/Brutal_Clarity)
	before_forget()
		savant<<"You stop circulating your Ki."
		savant.techniqueBuff-=2
		unassignverb(/mob/keyable/verb/Brutal_Clarity)
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Brutal_Clarity)

mob/keyable/verb/Brutal_Clarity()
	set category = "Skills"
	desc = "Bring your power inside yourself, increasing technique and strength!"
	if(!isBuffed(/obj/buff/Brutal_Clarity)&&!usr.KO)
		usr<<"You start to flow!"
		usr.startbuff(/obj/buff/Brutal_Clarity)
	else if(isBuffed(/obj/buff/Brutal_Clarity))
		usr<<"Your flow fades."
		usr.stopbuff(/obj/buff/Brutal_Clarity)

/obj/buff/Brutal_Clarity
	name = "Brutal Clarity"
	slot=sBUFF
	Buff()
		..()
		container.emit_Sound('1aura.wav')
		container.initdrain = 5
		container.initbuff = 5
		container.DrainMod*=container.initdrain
		container.Ttechnique+=container.initbuff
		container.buffsBuff= 3
	DeBuff()
		container.DrainMod/=container.initdrain
		container.Ttechnique-=container.initbuff
		container.buffsBuff= 1
		..()

/datum/skill/Tao_of_Art
	skilltype = "Technique Buff"
	name = "Tao of Art"
	desc = "Your body is hardened, but soft. It's able to redirect any blow... Master of technique. Master of all. Technique++++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	prereqs = list(new/datum/skill/Brutal_Clarity)
	tier = 4
	after_learn()
		savant<<"Your technique has reached the endgame."
		savant.techniqueBuff+=5
	before_forget()
		savant<<"Your body lessens its flow..."
		savant.techniqueBuff-=5