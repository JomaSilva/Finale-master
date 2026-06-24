datum/skill/tree/RankTree
	name = "Rank Tree"
	desc = "Learn special skills through this tree."
	maxtier = 1
	allowedtier = 1
	tier=1
	constituentskills = list(new/datum/skill/rank/RankChat)//General rank skills.
	var/assignedRank
/datum/skill/rank
	common_sense = TRUE //sets these two to the default if not overwritten
	can_forget = TRUE
	teachCost = 2 //base cost to learn each skill. should be changed later on but I just converted the damn thing you have the source code do it faggot

/datum/skill/rank/RankChat
	skilltype = "Misc"
	name = "Rank Chat"
	desc = "If you have a rank, you can get this. Used to speak OOCly between ranks."
	can_forget = TRUE //ALL rank 'SKILLS' should be forgetable. Exceptions could include Giant Form among similar skills.
	common_sense = FALSE //should be teachable, in which case make THIS true, but in the case of RankChat, no.
	tier = 1
	skillcost=0 //Rank skills should be cheap to the rank owner to facilitate learning. 0-1 costs recommended. Skill costs are what the TEACHER pays to learn them. Not the student.
	enabled=1 //NORMALLY ALL RANK SKILLS NEED, --NEEEEEEED-- to be disabled! Rankchat is available to ALL ranks so this is the SOLE exception.
/*																							//(unless, uh, there are other things like this.)
*/
/datum/skill/rank/RankChat/after_learn()
	assignverb(/mob/Admin1/verb/RankChat)
	savant<<"Rankchat Allowed"
/datum/skill/rank/RankChat/before_forget()
	unassignverb(/mob/Admin1/verb/RankChat)
	savant<<"Rankchat disabled."
/datum/skill/rank/RankChat/login(var/mob/logger)
	..()
	assignverb(/mob/Admin1/verb/RankChat)


/datum/skill/rank/Narrate
	skilltype = "Misc"
	name = "Narrate"
	desc = "Narrate for those in view, speaking in a voice decentralized and neutral to your own."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost=0
	enabled=1
/datum/skill/rank/Narrate/after_learn()
	assignverb(/mob/Admin1/verb/Narrate)
	savant<<"Narrate Allowed"
/datum/skill/rank/Narrate/before_forget()
	unassignverb(/mob/Admin1/verb/Narrate)
	savant<<"Narrate Disallowed"
/datum/skill/rank/Narrate/login(var/mob/logger)
	..()
	assignverb(/mob/Admin1/verb/Narrate)

/*
//HOW IS RANKS CATAGORIZED:
//You have the GENERAL RANK TREE (this thing with the huge ass effector)
//then the PLANETARY RANK TREE (PLANETARY being the specific Z level/group (Kai/demon roles are Otherworld.)) (organized in ordered/)
//then INSIDE those trees, a rigorous copy-pasting of enablers. THIS ONLY HAPPENS ONCE IF THE IF(!(savant.Rank==savant.LastRank)) IS SET UP PROPERLY. LastRank = Rank
																								NEEDS TO BE THE LAST THING SET INSIDE THE RANK TO WORK THIS PROPERLY.
*/
mob/var/Rank //all encompassing verb. Used to see if you have a rank.
mob/var/LastRank //to make sure it doesn't keep applying itself and stops itself at the condition.
mob/proc/RankTreeAssign(var/N)
	switch(N)
		if(1)
			getTree(new /datum/skill/tree/Rank/Otherworld)
		if(2)
			getTree(new /datum/skill/tree/Rank/Earth)
		if(3)
			getTree(new /datum/skill/tree/Rank/Space)
//4 was Alien trees. No real need but can be easily added in by copy-pasting code n shit.
		if(5)
			getTree(new /datum/skill/tree/Rank/Namek)
datum/skill/tree/RankTree/growbranches()
	if(savant.Rank!=savant.LastRank&&!assignedRank)
		assignedRank = 1
		spawn(100) assignedRank = 0
		switch(savant.Rank)
			if("Demon Lord")
				savant.RankTreeAssign(1)
			if("Earth Guardian")
				savant.RankTreeAssign(2)
			if("King Of Acronia")
				savant.RankTreeAssign(3)
			if("Arconian Guardian")
				savant.RankTreeAssign(3)
			if("Saibamen Rouge Leader")
				savant.RankTreeAssign(3)
			if("Earth Assistant Guardian")
				savant.RankTreeAssign(2)
			if("Namekian Elder")
				savant.RankTreeAssign(5)
			if("Namekian Grand Elder")
				savant.RankTreeAssign(5)
			if("Grand Kai")
				savant.RankTreeAssign(1)
			if("Supreme Kai")
				savant.RankTreeAssign(1)
			if("King of Vegeta")
				savant.RankTreeAssign(3)
			if("President")
				savant.RankTreeAssign(2)
			if("North Kai")
				savant.RankTreeAssign(1)
			if("South Kai")
				savant.RankTreeAssign(1)
			if("East Kai")
				savant.RankTreeAssign(1)
			if("West Kai")
				savant.RankTreeAssign(1)
			if("Turtle")
				savant.RankTreeAssign(2)
			if("Crane")
				savant.RankTreeAssign(2)
			if("King Yemma")
				savant.RankTreeAssign(1)
			if("Captain/King of Pirates")
				savant.RankTreeAssign(3)
			if("Geti Star King")
				savant.RankTreeAssign(3)
			if("Mutany Leader")
				savant.RankTreeAssign(3)
	..()
	return

mob/Admin1/verb
	Narrate(msg as text)
		set category="Other"
		switch(input(usr,"Global or local?") in list("Cancel","Global","Local"))
			if("Local")
				view(9)<<"<font color=red>[msg]"
			if("Global")
				world<<"<font color=red>[msg]"
	RankChat(msg as text)
		set category="Other"
		for(var/mob/A)
			if((A.Rank||A.Admin)&&A.client)
				A<<"<font size=[A.TextSize]><font color=#FF5500>(RankChat)[usr.name]: [html_encode(msg)]"