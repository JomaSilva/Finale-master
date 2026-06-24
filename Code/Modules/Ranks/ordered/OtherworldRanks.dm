datum/skill/tree/Rank/Otherworld
	name = "Otherworld Tree"
	desc = "Mystical Stuff."
	maxtier = 1
	allowedtier = 3
	tier=1
	constituentskills = list(new/datum/skill/kaioken,new/datum/skill/expand,new/datum/skill/rank/Restore_Youth,\
	new/datum/skill/rank/Keep_Body,new/datum/skill/rank/Dead,new/datum/skill/rank/Unlock_Potential,\
	new/datum/skill/general/observe,new/datum/skill/kai/Mystic,new/datum/skill/demon/Majin,new/datum/skill/rank/Reincarnate,\
	new/datum/skill/rank/BusterBarrage,new/datum/skill/general/selfdestruct,new/datum/skill/style/GodStyle,\
	new/datum/skill/rank/SpiritBomb,new/datum/skill/ki/Heal,new/datum/skill/rank/KaiPermission,new/datum/skill/style/DemonStyle,new/datum/skill/Telepathy)//kai/demon/mystical rank skills

datum/skill/tree/Rank/Otherworld/growbranches()
	savant.LastRank=savant.Rank
	if(savant.Rank!="West Kai") disableskill(/datum/skill/rank/BusterBarrage)
	if(savant.Rank!="East Kai") disableskill(/datum/skill/general/selfdestruct)
	if(savant.Rank!="North Kai") disableskill(/datum/skill/kaioken)
	switch(savant.Rank)
		if("Demon Lord")//like the grand kai
			enableskill(/datum/skill/style/DemonStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/demon/Majin)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/rank/Unlock_Potential)
			enableskill(/datum/skill/rank/Restore_Youth)
			enableskill(/datum/skill/rank/Ritual_of_Might)
		if("King_Of_Hell")//like the supreme kai
			enableskill(/datum/skill/style/DemonStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/demon/Majin)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/general/observe)
		if("Grand Kai") //keeps unlock potential, needs exclusive skill.
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Unlock_Potential)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Restore_Youth)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/rank/KaiPermission)
			enableskill(/datum/skill/rank/Ritual_of_Might)
		if("Supreme Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/kai/Mystic)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/KaiPermission)
			enableskill(/datum/skill/rank/Ritual_of_Might)
			enableskill(/datum/skill/ki/Heal)
		if("West Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/BusterBarrage)
			enableskill(/datum/skill/rank/Revive)
		if("East Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/general/selfdestruct)
			enableskill(/datum/skill/rank/BusterShell)
			enableskill(/datum/skill/rank/Revive)
		if("North Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/kaioken)
			enableskill(/datum/skill/rank/SpiritBomb)
			enableskill(/datum/skill/rank/Revive)
		if("South Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/expand)
			enableskill(/datum/skill/rank/Revive)
		if("King Yemma")
			enableskill(/datum/skill/rank/Judge)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/Revive)
	..()

mob/var/kaipermission
/datum/skill/rank/KaiPermission
	skilltype = "Misc"
	name = "Give Permission (Kai)"
	desc = "Give permission to a person to use the facilities of the Kai Loft and/or Hallowed Realm, located in Heaven."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/KaiPermission/after_learn()
	assignverb(/mob/Rank/verb/KaiPermission)
	savant<<"You give permissions."
/datum/skill/rank/KaiPermission/before_forget()
	unassignverb(/mob/Rank/verb/KaiPermission)
	savant<<"You've forgotten how to give permission?"
/datum/skill/rank/KaiPermission/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/KaiPermission)

mob/Rank/verb/KaiPermission(mob/M in view(6))
	set category="Other"
	switch(input("Give permission for [M] to enter the Kai Loft and/or the Hallowed Realm?", "", text) in list ("Kai Loft","Kai Loft and Hallowed Realm","Neither",))
		if("Kai Loft and Hallowed Realm")
			usr<<"You give [M] permission to enter the Hallowed Realm and Kai Loft."
			M.kaipermission=2
		if("Kai Loft")
			usr<<"You give [M] permission to use the Kai Loft."
			M.kaipermission=1
		if("Neither")
			usr<<"You deny [M] permission to enter the Kai Loft or use the Hallowed Realm."
			M.kaipermission=0