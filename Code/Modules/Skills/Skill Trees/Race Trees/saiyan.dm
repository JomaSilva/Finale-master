/datum/skill/tree/saiyan/SaiyanRacial
	name="Saiyan Racials"
	desc="Given to all Saiyans at the start."
	maxtier=1
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Saiyan","Half-Saiyan")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,new/datum/skill/lssj/Legendary_Anger,new/datum/skill/saiyan/Saiyan_Power)
	var/acquiredFormMastery
	var/gotlegendchoice = 0
//regular SSJ skills are in supersaiyan.dm in the same folder as this.
	growbranches()
		if(savant.Class == "Legendary" && !gotlegendchoice)
			enableskill(/datum/skill/lssj/Legendary_Anger)
			gotlegendchoice=1
		if(!acquiredFormMastery)
			acquiredFormMastery = 1
			savant.saiyantreeget(1)
		..()
		return
mob/proc/saiyantreeget(var/N)
	switch(N)
		if(1)
			getTree(new /datum/skill/tree/saiyan/SaiyanFormMastery)
		if(2)
			if(!(Class=="Legendary"))
				getTree(new /datum/skill/tree/SuperSaiyanMastery)
			if(Class=="Legendary"||LSSJType)
				getTree(new /datum/skill/tree/lssj)

//Legendary masterys to make it faster.
/datum/skill/lssj/Legendary_Anger
	skilltype = "Mind Buff"
	name = "Legendary Anger"
	desc = "You're a legend, but there is actually two types of legendaries. Sacrifice your first form for a immense anger, zenkai, sparring boost. After ascension, the anger, zenkai, and sparring boost is increased further. But, training, meditation, blast mods, and BP mod, Physicals are decreased heavily."
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 1
	enabled=0
	tier = 2
	var/has_post_ascension = 0
	after_learn()
		savant<<"Your anger... it's astonishing!!"
		savant.canRSSJ = 0
		savant.angerMod = 500
		savant.genome.add_to_stat("Zenkai",5)
		savant.genome.add_to_stat("Spar Mod",2)
		savant.genome.sub_to_stat("Train Mod",0.1)
		savant.genome.sub_to_stat("Med Mod",0.1)
		savant.genome.sub_to_stat("Physical Offense",0.2)
		savant.genome.sub_to_stat("Physical Defense",0.2)
		savant.genome.sub_to_stat("Energy Level",0.5)
		savant.genome.sub_to_stat("Battle Power",2)
	effector()
		if(savant.BP>=1000000 && AscensionStarted && !has_post_ascension)
			has_post_ascension = 1
			savant.angerMod = 2000
			savant.genome.add_to_stat("Zenkai",5)
			savant.genome.add_to_stat("Spar Mod",3)
		..()

/datum/skill/tree/saiyan/SaiyanFormMastery
	name="Saiyan Form Evolution"
	desc="Master your Oozarou state- and possibly more."
	maxtier=1
	tier=1
	allowedtier = 3
	enabled=0
	can_refund = FALSE
	var/acquiredSSJtrees
	constituentskills = list(new/datum/skill/forms/OozarouRevert,new/datum/skill/forms/OozarouSight,new/datum/skill/forms/OozarouMastery,new/datum/skill/forms/Wrathful_State)
	can_refund = FALSE

/datum/skill/forms/OozarouRevert
	skilltype = "Saiyan Form"
	name = "Revert Oozarou"
	desc = "You're aware of it. The beast lurking inside every Saiyan warrior. It's the first step to dominance over it. Learning this skill will let you revert from the form at higher levels of mastery."
	skillcost = 1
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	enabled=1

/datum/skill/forms/OozarouRevert/after_learn()
	savant<<"You've learned how to revert from Oozarou!"
	savant.contents +=new/obj/ApeshitRevert

/datum/skill/forms/OozarouRevert/before_forget()
	savant<<"You've forgotten how to revert from Oozarou!"
	for(var/obj/X in savant.contents)
		if(X == /obj/ApeshitRevert)
			savant.contents -= X

/datum/skill/forms/OozarouMastery
	skilltype = "Saiyan Form"
	name = "Master Oozaru"
	desc = "You know it exists, and you know how to prevent it. You know how to get out of it, but you can't. You just don't have control. But you're on the verge of figuring it out..."
	skillcost = 1
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/forms/OozarouRevert,new/datum/skill/forms/OozarouSight)
	tier = 2
	enabled=0

/datum/skill/forms/OozarouMastery/after_learn()
	savant<<"You've learned how to control Oozarou!"
	if(savant.Apeshitskill>=10)
		savant<< "You mastered Oozarou after you could control it!! A small Willpower boost is gained in addition."
		savant.willpowerMod += 0.1
	savant.Apeshitskill += 10
	savant.Omult*=1.05

/datum/skill/forms/OozarouMastery/before_forget()
	savant<<"You've forgotten how to master Oozarou!"
	if(savant.Apeshitskill>=20)
		savant<< "The willpower boost from Mastering Oozarou is also taken away."
		savant.willpowerMod -= 0.1
	savant.Apeshitskill -= 10
	savant.Omult/=1.05

/datum/skill/forms/OozarouSight
	skilltype = "Saiyan Form"
	name = "Moon Lookage"
	desc = "You know what triggers it- it's the moon. Allow yourself the ability to choose to look at the moon or not, thus eliminating risks."
	skillcost = 1
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	enabled=1

/datum/skill/forms/OozarouSight/after_learn()
	savant<<"You've learned how to avert your eyes!"
	savant.contents +=new/obj/ApeshitSetting

/datum/skill/forms/OozarouSight/before_forget()
	savant<<"You've forgotten how to avert your eyes!"
	for(var/obj/X in savant.contents)
		if(X == /obj/ApeshitSetting)
			savant.contents -= X

/datum/skill/forms/Wrathful_State
	skilltype = "Saiyan Form"
	name = "Wrathful State"
	desc = "The main issue with the Oozaru State is that it's big and bulky. All that extra speed in close quarters combat is lost due to efficiency of movement. Compress the power of Oozaru into a smaller package that you can activate whenever. There is a price to this, however..."
	skillcost = 1
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/forms/OozarouMastery)
	tier = 2
	enabled=0

/datum/skill/forms/Wrathful_State/after_learn()
	savant<<"You've learned Wrathful State!"
	assignverb(/mob/keyable/verb/Wrathful_State)

/datum/skill/forms/Wrathful_State/before_forget()
	savant<<"You've forgotten Wrathful State!"
	unassignverb(/mob/keyable/verb/Wrathful_State)

/datum/skill/forms/Wrathful_State/login(mob/logger)
	..()
	assignverb(/mob/keyable/verb/Wrathful_State)


/datum/skill/saiyan/Saiyan_Power
	skilltype = "Saiyan Form"
	name = "Saiyan Power"
	desc = "This one lets you maximize your usage of Zenkai. Normally Zenkai is already pretty strong, but this will let you get stronger by fighting in combat. The longer you're in a fight, the more passive gains you'll get..."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	tier = 1
	level = 1
	maxlevel = 7
	var/tmp/gains_boost_buffer = 0
	effector()
		..()
		if(levelup)
			levelup = 0
			expbarrier = 10 ** (level+1)
			savant << "Your zenkai grows even further! Level [level] reached!"
		if(savant.IsInFight)
			if(savant.BP < savant.highestbp)
				gains_boost_buffer++
				exp++
			if(gains_boost_buffer > 10*level)
				gains_boost_buffer-=10*level
				exp+=savant.SparMod ** level
				savant.Attack_Gain(level+savant.ZenkaiMod/10)

	after_learn()
		savant << "Your power begins to throbs every time your fists matches another..."

	before_forget()
		savant << "Your power fades."