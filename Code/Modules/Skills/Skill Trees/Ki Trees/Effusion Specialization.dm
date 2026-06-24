//skill tree for picking a specialization and expanding on it
/datum/skill/tree/effusionspec
	name = "Effusive Specialty"
	desc = "Unique Ki Effects"
	skilltype = null
	common_sense = FALSE
	tier=1
	allowedtier = 4
	maxtier = 4
	enabled = 0
	constituentskills = list(new/datum/skill/effusionspec/Forceful_Ki,new/datum/skill/effusionspec/Ki_Shock,new/datum/skill/effusionspec/Interference,\
	new/datum/skill/mind/Basic_Guided_Mastery, new/datum/skill/mind/Basic_Homing_Mastery,\
	new/datum/skill/mind/Basic_Targeted_Mastery, new/datum/skill/mind/Advanced_Volley_Mastery,new/datum/skill/mind/Advanced_Guided_Mastery,\
	new/datum/skill/mind/Advanced_Homing_Mastery,new/datum/skill/mind/Perfect_Volley_Mastery,\
	new/datum/skill/mind/Perfect_Guided_Mastery,new/datum/skill/mind/Perfect_Homing_Mastery,\
	new/datum/skill/mind/Perfect_Targeted_Mastery, new/datum/skill/mind/Basic_Volley_Mastery)

/datum/skill/tree/effusionspec/growbranches()
	if(savant.effspec==0)
		enableskill(/datum/skill/effusionspec/Ki_Shock)
		enableskill(/datum/skill/effusionspec/Interference)
		enableskill(/datum/skill/effusionspec/Forceful_Ki)
		enableskill(/datum/skill/effusionspec/Ki_Shock)
	if(savant.volleyskill>=1)
		enableskill(/datum/skill/mind/Basic_Volley_Mastery)
	if(savant.guidedskill>=1)
		enableskill(/datum/skill/mind/Basic_Guided_Mastery)
	if(savant.homingskill>=1)
		enableskill(/datum/skill/mind/Basic_Homing_Mastery)
	if(savant.targetedskill>=1)
		enableskill(/datum/skill/mind/Basic_Targeted_Mastery)
	..()

/datum/skill/tree/effusionspec/prunebranches()
	if(savant.effspec==1)
		disableskill(/datum/skill/effusionspec/Ki_Shock)
		disableskill(/datum/skill/effusionspec/Interference)
	if(savant.effspec==2)
		disableskill(/datum/skill/effusionspec/Forceful_Ki)
		disableskill(/datum/skill/effusionspec/Interference)
	if(savant.effspec==3)
		disableskill(/datum/skill/effusionspec/Ki_Shock)
		disableskill(/datum/skill/effusionspec/Forceful_Ki)
	..()
mob/var
	effspec//which route did you choose?
	kiforceful=0
	kishock=0
	kiinterfere=0

/datum/skill/effusionspec/Forceful_Ki
	skilltype = "Mind Buff"
	name = "Forceful Ki"
	desc = "Your ki attacks erupt with force! You begin to knock foes back with every blow! You can only choose one effusion specialization."
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	expbarrier = 0
	skillcost = 1
	tier = 0
	after_learn()
		savant<<"You begin to knock foes back with every blow!"
		savant.effspec=1
		savant.kiforceful=1
	before_forget()
		savant<<"Your blows blow foes back a little less."
		savant.effspec=0
		savant.kiforceful=0

/datum/skill/effusionspec/Ki_Shock
	skilltype = "Mind Buff"
	name = "Ki Shock"
	desc = "Your ki attacks crackle with energy! Your attacks leave behind residual energy, causing damage! You can only choose one effusion specialization."
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	expbarrier = 0
	skillcost = 1
	tier = 0
	after_learn()
		savant<<"Your attacks leave behind residual energy, causing damage!"
		savant.effspec=2
		savant.kishock=1
	before_forget()
		savant<<"Your attacks no longer leave behind that strong residual energy..."
		savant.effspec=0
		savant.kishock=0

/datum/skill/effusionspec/Interference
	skilltype = "Mind Buff"
	name = "Interference"
	desc = "Your ki attacks seem to dampen energy! You increase your target's drain from ki attacks! You can only choose one effusion specialization."
	can_forget = FALSE
	common_sense = TRUE
	maxlevel = 1
	expbarrier = 0
	skillcost = 1
	tier = 0
	after_learn()
		savant<<"You increase your target's drain from ki attacks!"
		savant.effspec=3
		savant.kiinterfere=1
	before_forget()
		savant<<"Your targets no longer find themselves leaking ki..."
		savant.effspec=0
		savant.kishock=0
