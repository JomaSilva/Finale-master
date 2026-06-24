datum/skill/tree/Rank/Space
	name = "Space Tree"
	desc = "Skills based on popular space figures."
	maxtier = 6
	allowedtier = 6
	tier=1
	constituentskills = list(new/datum/skill/rank/Fusion_Dance,new/datum/skill/general/splitform,\
	new/datum/skill/rank/Taxes,new/datum/skill/rank/BusterBarrage,\
	new/datum/skill/rank/KillDriver,new/datum/skill/style/SaiyanStyle,new/datum/skill/style/AlienStyle,\
	new/datum/skill/rank/Holy_Shortcut,new/datum/skill/ki/Heal,new/datum/skill/rank/SuperiorSeal,new/datum/skill/rank/Detect_Shard,new/datum/skill/rank/GalicGun,new/datum/skill/rank/Death_Beam)
	//Vegeta & important Space figures. (King o' Pirates, King o Vegeta, Geti Star King, and Arconian King. Basically, royalty big deal ranks
//										that don't fit into above.)
datum/skill/tree/Rank/Space/growbranches()
	switch(savant.Rank)
		if("Captain/King of Pirates")
			enableskill(/datum/skill/rank/Death_Beam)
			enableskill(/datum/skill/style/AlienStyle)
			enableskill(/datum/skill/rank/DeathBall)
		if("Geti Star King")
			enableskill(/datum/skill/general/splitform)
			enableskill(/datum/skill/rank/DeathBall)
			enableskill(/datum/skill/rank/Paralysis)
			enableskill(/datum/skill/style/AlienStyle)
			enableskill(/datum/skill/rank/Fusion_Dance)
		if("King of Vegeta")
			enableskill(/datum/skill/rank/Taxes)
			enableskill(/datum/skill/rank/FinalFlash)
			enableskill(/datum/skill/style/SaiyanStyle)
			enableskill(/datum/skill/rank/GalicGun)
		if("King Of Acronia")
			enableskill(/datum/skill/rank/KillDriver)
			//enableskill(/datum/skill/rank/GuidedBall)
			enableskill(/datum/skill/style/AlienStyle)
		if("Arconian Guardian")
			enableskill(/datum/skill/rank/SuperiorSeal)
			enableskill(/datum/skill/ki/Heal)
			enableskill(/datum/skill/rank/Holy_Shortcut)
			enableskill(/datum/skill/style/AlienStyle)
			enableskill(/datum/skill/rank/Detect_Shard)
	savant.LastRank=savant.Rank
	..()

//Arconian Guardian
datum/skill/rank/Holy_Shortcut
	skilltype = "Ki"
	name = "Holy Shortcut"
	desc = "Your connection to the Master Emerald allows you to enter and exit the Holy Summit as you please. The method is a secret to everyone, but it causes you to feel an urge to laugh..?"
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost = 0
	enabled = 0

/datum/skill/rank/Holy_Shortcut/after_learn()
	assignverb(/mob/Rank/verb/Holy_Shortcut)
	savant<<"A bizarre energy washes over you, and you suddenly learn a hidden shortcut to the Holy Summit!"
/datum/skill/rank/Holy_Shortcut/before_forget()
	unassignverb(/mob/Rank/verb/Holy_Shortcut)
	savant<<"You no longer remember the Holy Shortcut. However, you forget it too well; you forgot how to chuckle as a result."
/datum/skill/rank/Holy_Shortcut/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Holy_Shortcut)

mob/Rank/verb/Holy_Shortcut()
	set category="Skills"
	if(!usr.KO&&canfight&&!usr.med&&!usr.train&&usr.Ki>=(usr.MaxKi/2))
		view(6)<<"[usr] folds their arms and smirks..?"
		var/choice = input("You feel a mental connection between the Holy Summit and the world outside of it. Where would you like to go?", "", text) in list ("Holy Summit", "Arconia", "Nevermind",)
		if(choice=="Nevermind")
			view(6)<<"[usr] suddenly..! Wait, no, [usr] just stops smirking and just stands there."
		else
			usr.Ki=(usr.Ki/2)
			view(6)<<"[usr] chuckles and vanishes!!"
			emit_Sound('Instant_Pop.wav')
			for(var/mob/V in oview(1))
				view(6)<<"[V] suddenly disappears!"
				spawn(5)
					V.loc = locate(usr.x,usr.y,usr.z)
					V<<"[usr] brings you with them using...chuckling?."
					spawn(10) view(6)<<"[V] suddenly appears!"
			if(choice=="Holy Summit")
				loc=locate(44,210,31)
			else if(choice=="Arconia")
				loc=locate(340,270,5)
			emit_Sound('Instant_Pop.wav')
			spawn(1)
				view(6)<<"[usr] suddenly appears!"
	else usr<<"You lack the sufficient Ki required to chuckle. Either that or you refused to stand still like some eight year-old hyped up on sugar."

datum/skill/rank/Detect_Shard
	skilltype = "Ki"
	name = "Emerald Detection"
	desc = "Your link to the Emerald allows you to detect its energy. If a trace of the Emerald's energy is on the same planet as you, you can trace its coordinates."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost = 0
	enabled = 0

/datum/skill/rank/Detect_Shard/after_learn()
	assignverb(/mob/Rank/verb/Detect_Shard)
	savant<<"The great Emerald's power allows you to feel!"
/datum/skill/rank/Detect_Shard/before_forget()
	unassignverb(/mob/Rank/verb/Detect_Shard)
	savant<<"Your connection with the Emerald vanishes!"
/datum/skill/rank/Detect_Shard/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Detect_Shard)

mob/Rank/verb/Detect_Shard()
	set category="Skills"
	usr<<"The Master Emerald is no more; there is nothing to detect."
