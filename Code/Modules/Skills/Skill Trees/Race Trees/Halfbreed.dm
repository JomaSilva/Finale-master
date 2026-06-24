//Halfbreed is unused for now.
/datum/skill/tree/halfbreed
	name="Halfbreed Racials"
	desc="Given to all Half-breeds at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	var/first_time
	compatible_races = list("Half-Breed")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/expand,new/datum/skill/general/regenerate)
	var/dewitonce
	treegrow()
		if(savant.Parent_Race=="Tsujin")
			if(savant.pitted==1)
				disableskill(/datum/skill/tsujin/Against)
			if(savant.pitted==2)
				disableskill(/datum/skill/tsujin/Biggest_Brain)
			if(!first_time && is_learned(/datum/skill/tsujin/Monster_of_Tech))
				first_time = 1
				savant.contents += new/obj/items/companion_obj/Intercepter_Core
	treeshrink()
		if(savant.Parent_Race=="Tsujin")
			if(savant.pitted==0)
				enableskill(/datum/skill/tsujin/Against)
				enableskill(/datum/skill/tsujin/Biggest_Brain)

/datum/skill/tree/halfbreed/growbranches()
	if(savant.Parent_Race == "Gray")
		for(var/datum/skill/gray/meditatepower/S in savant.learned_skills)
			if(S.level==3)
				enableskill(/datum/skill/fullpower)
	if(savant.Parent_Race=="Meta")
		meta_ability()
	if(!dewitonce)
		dewitonce=1
		if(savant.SaiyanType)
			savant.getTree(/datum/skill/tree/saiyan/SaiyanFormMastery)
		if(savant.ChangieType)
			savant.getTree(/datum/skill/tree/frostdemon)
		if(savant.SPType)
			savant.getTree(/datum/skill/tree/heran)
		if(savant.Parent_Race == "Alien" || savant.Parent_Race=="") savant.getTree(/datum/skill/tree/alien)
		if(savant.Parent_Race == "Bio-Android")
			constituentskills += new/datum/skill/general/bioabsorb
			constituentskills += new/datum/skill/namek/bigform
		if(savant.Parent_Class == "Arlian")
			constituentskills += new/datum/skill/arlian/Stick
			constituentskills += new/datum/skill/arlian/Supa
		if(savant.Parent_Race == "Demigod")
			constituentskills += new/datum/skill/RiftTeleport
			constituentskills += new/datum/skill/demon/soulabsorb
			constituentskills += new/datum/skill/general/observe
		if(savant.Parent_Race == "Demon")
			constituentskills += new/datum/skill/general/invisible
			constituentskills += new/datum/skill/Telepathy
			constituentskills += new/datum/skill/demon/soulabsorb
			constituentskills += new/datum/skill/demon/lifeabsorb
			constituentskills += new/datum/skill/demon/Devil_Bringer
		if(savant.Parent_Race == "Gray")
			constituentskills += new/datum/skill/gray/meditatepower
			if(savant.Class=="Hermano")
				constituentskills += new/datum/skill/gray/brainpower
				enableskill(/datum/skill/gray/brainpower)
		if(savant.Parent_Race == "Human")
			constituentskills +=new/datum/skill/human/Jack_Of_Trades
			constituentskills +=new/datum/skill/human/Intelligent_Man
			constituentskills +=new/datum/skill/human/Martial_Prowessor
		if(savant.Parent_Race == "Kai")
			constituentskills +=new/datum/skill/Telepathy
			constituentskills +=new/datum/skill/kai/Teleport
			constituentskills +=new/datum/skill/kai/Revive
		if(savant.Parent_Race == "Majin")
			constituentskills +=new/datum/skill/general/buuabsorb
			constituentskills +=new/datum/skill/general/splitform
			constituentskills +=new/datum/skill/general/regenerate
		if(savant.Parent_Race == "Makyo")
			constituentskills +=new/datum/skill/expand
			constituentskills +=new/datum/skill/conjure
			constituentskills +=new/datum/skill/makyo/Moon
			constituentskills +=new/datum/skill/makyo/Sun
		if(savant.Parent_Race == "Meta")
			constituentskills +=new/datum/skill/rank/Fusion_Dance
			constituentskills +=new/datum/skill/meta/Stunlock
			constituentskills +=new/datum/skill/meta/Great_Robotic_Alliance
		if(savant.Parent_Class == "Shapeshifter")
			constituentskills +=new/datum/skill/general/PermanentImitation
			constituentskills +=new/datum/skill/general/imitation
		if(savant.Parent_Race == "Tsujin")
			constituentskills +=new/datum/skill/tsujin/Biggest_Brain
			constituentskills +=new/datum/skill/tsujin/Against
			constituentskills +=new/datum/skill/tsujin/Monster_of_Tech
			constituentskills +=new/datum/skill/tsujin/Conditioning
			constituentskills +=new/datum/skill/tsujin/Guru_Of_Determination
	..()
	return