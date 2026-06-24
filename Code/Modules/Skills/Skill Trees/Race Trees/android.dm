/datum/skill/tree/android
	name="Android Racials"
	desc="Given to all Androids at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Android")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/invisible,new/datum/skill/general/selfdestruct,new/datum/skill/general/androidabsorb)


/datum/skill/general/androidabsorb
	skilltype="Physical"
	name="Absorb"
	desc="Grab someone, then bring them into yourself, giving yourself a power boost."
	can_forget = FALSE
	common_sense = FALSE

/datum/skill/general/androidabsorb/after_learn()
	savant.contents+=new/obj/Absorb_Android
	savant<<"You can absorb others!"