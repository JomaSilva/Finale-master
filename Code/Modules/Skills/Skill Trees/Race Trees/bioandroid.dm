/datum/skill/tree/bioandroid
	name="Bio-Android Racials"
	desc="Given to all Bio-Androids at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Bio-Android")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/bioabsorb,new/datum/skill/namek/bigform,new/datum/skill/general/materialization,\
	new/datum/skill/expand,new/datum/skill/general/regenerate)

/datum/skill/general/bioabsorb
	skilltype="Physical"
	name="Tail Absorb"
	desc="Engulf someone with your tail, then bring them into yourself, giving yourself a power boost."
	can_forget = FALSE
	common_sense = FALSE

/datum/skill/general/bioabsorb/after_learn()
	savant.contents+=new/obj/Bio_Absorb
	savant<<"You can absorb others!"
