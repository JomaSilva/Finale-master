/datum/skill/tree/spiritdoll
	name="Spirit Doll Racials"
	desc="Given to all Spirit Dolls at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Spirit Doll")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,
		new/datum/skill/spiritdoll/DollRegen,new/datum/skill/spiritdoll/Play,new/datum/skill/general/selfdestruct)
	treegrow()
		if(savant.pitted==1)
			disableskill(/datum/skill/spiritdoll/Play)
		if(savant.pitted==2)
			disableskill(/datum/skill/spiritdoll/DollRegen)
	treeshrink()
		if(savant.pitted==0)
			enableskill(/datum/skill/spiritdoll/Play)
			enableskill(/datum/skill/spiritdoll/DollRegen)

/datum/skill/spiritdoll/DollRegen
	skilltype = "Physical"
	name = "Doll Regeneration"
	desc = "Your parts stitch together faster, giving you a bit of death regen. You can't have Play Hard at the same time."
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	after_learn()
		savant<<"Your body's regeneration changes."
		savant.genome.add_to_stat("Regeneration",10)
		savant.pitted = 1
	before_forget()
		savant<<"Your body's regeneration returns to normal."
		savant.genome.sub_to_stat("Regeneration",10)
		savant.pitted = 0

/datum/skill/spiritdoll/Play
	skilltype = "Physical"
	name = "Play Hard"
	desc = "As your body stresses, it grows stronger. The effects of battle damage returns to you in strength by tens of times. Can't have Doll Regeneration at the same time."
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	after_learn()
		savant<<"Your zenkai increases."
		savant.genome.add_to_stat("Zenkai",3)
		savant.pitted = 2
	before_forget()
		savant<<"Your zenkai returns to normal."
		savant.genome.sub_to_stat("Zenkai",3)
		savant.pitted = 0