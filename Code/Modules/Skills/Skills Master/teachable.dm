datum/skill
	var/wastaught=FALSE
	var/teachCost//how much it takes to learn the skill if taught-used by ranks.

mob/default/verb/Teach_Skill()
	set category = "Learning"
	var/list/Teach=new/list
	var/list/Targets=new/list
	for(var/datum/skill/S in learned_skills)
		if(S.teacher==TRUE)Teach.Add(S)
	var/datum/skill/Choice=input("Teach which Skill?") in Teach
	for(var/mob/M in view(1))
		if(M!=src&&!(Choice.type in M.learned_skills))Targets.Add(M.name)
	Targets.Add("Cancel")
	var/mob/Choice2=input("To who?") in Targets
	if(Choice2=="Cancel")return
	for(var/datum/skill/nS in learned_skills)
		if(nS==Choice)
			for(var/mob/nM in view(1))
				if(nM.name==Choice2)
					nM.Study(nS,src)
	sleep(60)
	return

mob/default/verb/Forget_Studied_Skill()
	set category = "Learning"
	var/list/Forget=new/list
	for(var/datum/skill/S in learned_skills)
		if(S.wastaught==TRUE)Forget.Add(S)
	Forget.Add("Cancel")
	var/Choice=input("Forget which Skill?") in Forget
	if(Choice=="Cancel")return
	for(var/datum/skill/nS in learned_skills)
		if(nS==Choice)
			nS.forget()
			return

mob/proc/Study(var/datum/skill/S, var/mob/Teacher)
	var/teachingcost
	var/list/Options=new/list
	Options.Add("Yes")
	Options.Add("No")
	if(!S.teachCost)
		teachingcost = S.skillcost
	else teachingcost = S.teachCost
	if(canLearnSkill(S) || S.teacher == TRUE)
		if(skillpoints>=teachingcost)
			var/Choice=input("Do you want to learn [S.name]? It costs [teachingcost] and you have [src.skillpoints]. Learning won't remove skillpoints, however.\n[S.desc]") in Options
			if(Choice=="Yes")
				Teacher << "[src] learned [S.name]!"
				src << "You learned [S.name]!"
				var/datum/skill/nS = new S.type
				nS.teacher=FALSE
				nS.wastaught=TRUE
				src.learnSkill(nS, 0, 0)
				nS.afterTeach(Teacher)
				return TRUE
			if(Choice=="No")
				Teacher << "[src] chose not to learn [S.name]."
				src << "You chose not to learn [S.name]."
				return FALSE //returns true/false depending on success
		else
			src << "You do not have enough points for [S.name]."
			Teacher << "[src] did not have enough points for [S.name]."
			return FALSE
	else
		src << "You cannot learn [S.name]."
		Teacher << "[src] cannot learn [S.name]."
		return FALSE

mob/proc/SStudy(var/datum/skill/S, var/mob/Teacher)
	var/teachingcost
	var/list/Options=new/list
	Options.Add("Yes")
	Options.Add("No")
	if(!S.teachCost)
		teachingcost = S.skillcost
	else teachingcost = S.teachCost
	if(canLearnSkill(S) || S.teacher == TRUE)
		if(skillpoints>=teachingcost)
			var/Choice=input("Do you want to learn [S.name]? It costs [teachingcost] and you have [src.skillpoints]. Learning won't remove skillpoints, however.\n[S.desc]") in Options
			if(Choice=="Yes")
				view(src) << "[src] learned [S.name]!"
				var/datum/skill/nS = new S.type
				nS.teacher=FALSE
				nS.wastaught=TRUE
				src.learnSkill(nS, 0, 0)
				nS.afterTeach(Teacher)
				return TRUE
			if(Choice=="No")
				src << "You chose not to learn [S.name]!"
				return FALSE //returns true/false depending on success
		else
			view(src) << "[src] do not have enough points for [S.name]!"
			return FALSE
	else
		view(src) << "[src] cannot learn [S.name]!"
		return FALSE