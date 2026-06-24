/datum/skill/tree/tsujin
	name="Tsujin Racials"
	desc="Given to all Tsujins at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Tsujin")
	var/first_time
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
		new/datum/skill/tsujin/Biggest_Brain,new/datum/skill/tsujin/Against,new/datum/skill/tsujin/Monster_of_Tech,new/datum/skill/tsujin/Conditioning,new/datum/skill/tsujin/Guru_Of_Determination)
	treegrow()
		if(savant.pitted==1)
			disableskill(/datum/skill/tsujin/Against)
		if(savant.pitted==2)
			disableskill(/datum/skill/tsujin/Biggest_Brain)
		if(!first_time && is_learned(/datum/skill/tsujin/Monster_of_Tech))
			first_time = 1
			savant.contents += new/obj/items/companion_obj/Intercepter_Core
	treeshrink()
		if(savant.pitted==0)
			enableskill(/datum/skill/tsujin/Against)
			enableskill(/datum/skill/tsujin/Biggest_Brain)

mob/var/pitted = 0

/datum/skill/tsujin/Biggest_Brain
	skilltype = "Physical"
	name = "Biggest Brain"
	desc = "Increase your intelligence by a whopping 1/2 of what it was. (This is a lot.) This will disable Against the Odds."
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	expbarrier = 12000
	after_learn()
		savant<<"Your brain mass increases."
		savant.pitted = 1
		savant.genome.add_to_stat("Tech Modifier",5)
	before_forget()
		savant<<"Your brain mass decreases."
		savant.pitted = 0
		savant.genome.sub_to_stat("Tech Modifier",5)

/datum/skill/tsujin/Against
	skilltype = "Physical"
	name = "Against the Odds"
	desc = "You work on your strength, despite the racial odds against you. Maybe one day you'll amount to something? Disables Biggest Brain"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	expbarrier = 12000
	after_learn()
		savant<<"Your strength increases."
		savant.genome.add_to_stat("Battle Power",0.4)
		savant.genome.add_to_stat("Ascension Mod",0.5)
		savant.genome.add_to_stat("Energy Level",0.2)
		savant.pitted = 2
	before_forget()
		savant<<"Your strength decreases."
		savant.genome.sub_to_stat("Battle Power",0.1)
		savant.genome.sub_to_stat("Ascension Mod",3)
		savant.genome.sub_to_stat("Energy Level",0.2)
		savant.pitted = 0


/datum/skill/tsujin/Monster_of_Tech
	skilltype = "Physical"
	name = "Monster of Technology"
	desc = "Increase your intelligence a bit more, and gain the ability to create a companion. Also, you're able to create some unique androids. (Int+, Tech abilities.)"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 2
	maxlevel = 1
	expbarrier = 12000
	enabled=0
	prereqs = list(new/datum/skill/tsujin/Biggest_Brain)
	after_learn()
		savant<<"Your brain mass increases."
		savant.pitted = 1
		savant.genome.add_to_stat("Tech Modifier",1)
	before_forget()
		savant<<"Your brain mass decreases."
		savant.pitted = 0
		savant.genome.sub_to_stat("Tech Modifier",1)

/datum/skill/tsujin/Conditioning
	skilltype = "Physical"
	name = "Conditioning"
	desc = "Despite your determination, your body simply fails. The world tells you your body will amount to nothing. It's time to change that. (All stats +++)"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	expbarrier = 12000
	enabled=0
	prereqs = list(new/datum/skill/tsujin/Against)
	after_learn()
		savant<<"Your bodies capabilities begin to increase."
		savant.genome.add_to_stat("Battle Power",0.1)
		savant.genome.add_to_stat("Ascension Mod",0.5)
		savant.genome.add_to_stat("Energy Level",0.1)

		savant.physoffMod *= 1.25
		savant.physdefMod *= 1.25
		savant.techniqueMod *= 1.5
		savant.kioffMod *= 1.25
		savant.kidefMod *= 1.25
		savant.kiskillMod *= 1.35
		savant.speedMod *= 1.20
		savant.magiMod *= 1.5
		savant.genome.add_to_stat("Skillpoint Mod",0.1)
	
	before_forget()
		savant<<"Your bodies capabilities decrease."
		savant.genome.sub_to_stat("Battle Power",0.1)
		savant.genome.sub_to_stat("Ascension Mod",0.5)
		savant.genome.sub_to_stat("Energy Level",0.1)
		savant.physoffMod /= 1.25
		savant.physdefMod /= 1.25
		savant.techniqueMod /= 1.5
		savant.kioffMod /= 1.25
		savant.kidefMod /= 1.25
		savant.kiskillMod /= 1.35
		savant.speedMod /= 1.20
		savant.magiMod /= 1.5
		savant.genome.sub_to_stat("Skillpoint Mod",0.1)

/datum/skill/tsujin/Guru_Of_Determination
	skilltype = "Physical"
	name = "Guru of Determination"
	desc = "Tsujins are weak, but they're pretty smart. This is a generalization of the race. Whether or not you've fulfilled this stereotype, the racial identity of Tsujins are not a innate feature. They are a product of a instinctual understanding of their own weakness... and their determination to change it. (All stats +, Willpower Mod ++++, Skillpoint Mod +, Zenkai +, Hidden Potential Mod +++)"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 3
	maxlevel = 1
	expbarrier = 12000
	enabled=0
	prereqthreshold = 1
	prereqs = list(new/datum/skill/tsujin/Monster_of_Tech,new/datum/skill/tsujin/Conditioning)
	after_learn()
		savant<<"Your life begins to take a turn."
		savant.genome.add_to_stat("Battle Power",0.1)
		savant.genome.add_to_stat("Ascension Mod",0.5)
		savant.genome.add_to_stat("Energy Level",0.1)

		savant.physoffMod *= 1.25
		savant.physdefMod *= 1.25
		savant.techniqueMod *= 1.5
		savant.kioffMod *= 1.25
		savant.kidefMod *= 1.25
		savant.kiskillMod *= 1.35
		savant.speedMod *= 1.20
		savant.magiMod *= 1.5
		savant.genome.add_to_stat("Skillpoint Mod",0.1)

	before_forget()
		savant<<"Your life slows down..."
		savant.genome.sub_to_stat("Battle Power",0.1)
		savant.genome.sub_to_stat("Ascension Mod",3)
		savant.genome.sub_to_stat("Energy Level",0.1)
		savant.physoffMod /= 1.25
		savant.physdefMod /= 1.25
		savant.techniqueMod /= 1.5
		savant.kioffMod /= 1.25
		savant.kidefMod /= 1.25
		savant.kiskillMod /= 1.35
		savant.speedMod /= 1.20
		savant.magiMod /= 1.5
		savant.genome.sub_to_stat("Skillpoint Mod",0.1)
