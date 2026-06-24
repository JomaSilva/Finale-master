//mob/Admin2/verb/Change_Custom_Attack_Sound(var/mob/M)
//	set category = "Admin"
//	var/list/templist = list()
//	for(var/obj/skill/CustomAttacks/S in M.contents)
//		templist += S
//	var/obj/skill/CustomAttacks/choice = input("Which Custom Attack?") as anything in templist
//	if(isnull(choice))
//		usr<<"Cancelled."
//	else
//		var/choice2 = input("Input a sound file. (WAV or OGG only! Keep it small, other players will be constantly downloading this!)") as sound
//		var/choice3 = input("Which sound variable?") in list("Fire sound.","Charge sound.","Cancel")
//		switch(choice3)
//			if("Fire sound.")
//				choice.firesound = choice2
//			if("Charge sound.")
//				choice.ChargeSound = choice2

mob/special/verb/Toggle_Admin_Verbs()
	set category = "Admin"
	if(!averbcheck)
		verbs-=typesof(/mob/Admin3/verb)
		verbs-=typesof(/mob/OwnerAdmin/verb)
		verbs-=typesof(/mob/Admin2/verb)
		verbs-=typesof(/mob/Admin1/verb)
		averbcheck = 1
	else
		AdminCheck()
		averbcheck = 0
var/Dragonball_Start=0
mob/Admin2/verb/Dragonball_Start()
	set category = "Admin"
	switch(input(usr,"Dragonball Start means that during character creation, your character will NOT get any average-based boosts or basic boosts. Everyone starts at BP of 1.") in list("Sure","No"))
		if("Sure")
			Dragonball_Start=1
		if("No")
			Dragonball_Start=0

var/list/banned_skill_list = list()

mob/Admin3/verb/S_Disable_Skill()
	set category = "Admin"
	var/list/skill_list = list()
	skill_list += typesof(/datum/skill)
	skill_list -= typesof(/datum/skill/tree)
	for(var/a in skill_list)
		if(a in banned_skill_list) skill_list -= a
	skill_list += "Cancel"
	var/a_indx = input(usr,"Select the skill to disable. If nothing is there, that means all skills are banned.","Banned Skills: Disable","Cancel") in skill_list
	if(a_indx == "Cancel") return
	banned_skill_list += a_indx

mob/Admin3/verb/S_Enable_Skill()
	set category = "Admin"
	var/list/skill_list = list()
	for(var/a in banned_skill_list)
		skill_list += a
	skill_list += "Cancel"
	var/a_indx = input(usr,"Select the skill to enable. If nothing is there, that means all skills are not banned.","Banned Skills: Enable","Cancel") in skill_list
	if(a_indx == "Cancel") return
	banned_skill_list -= a_indx