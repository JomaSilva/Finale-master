#define TRUE 1 //tg artifact but also a healthy addition
#define FALSE 0 //why the fuck wasn't TRUE defaulted to 1 anyway?
				 //I'm blaming Tens.
mob/var
	list/learned_skills = list()
	list/disallowed_skills = list()

mob/proc/precheck(datum/skill/S)
	var/precheck=0
	if(S.prereqs.len>0)
		precheck=S.prereqs.len - S.prereqthreshold
		for(var/testfor2 in S.prereqs)
			if(locate(testfor2) in learned_skills)precheck-=1
		if(precheck<=0) return TRUE
		else return FALSE
	else return TRUE


mob/proc/CopySkills(mob/destinationMob)
	for(var/testfor in possessed_trees)
		var/datum/skill/tree/T = testfor
		var/datum/skill/tree/nT = new T.type
		destinationMob.possessed_trees += nT
		for(var/Stest in T.investedskills)
			var/datum/skill/S = Stest
			var/datum/skill/nS = new S.type
			destinationMob.learnSkill(nS, 0, 0)
			destinationMob.skillpoints -= S.skillcost
			nT.invested+=S.skillcost
			nT.investedskills.Add(nS)
			nT.didchange=1

mob/proc/Skill_EXP_Add(stype,n as num)
	var/datum/skill/S = locate(stype) in learned_skills
	if(S)
		S.exp += n

mob/proc/HasSkill(datum/skill/S)
	var/testfor=locate(S) in src.learned_skills
	if(testfor)
		return TRUE
	else return FALSE

mob/proc/canLearnSkill(datum/skill/S)
	if(HasSkill(S)) return FALSE
	if(S.common_sense == TRUE) return TRUE
	if(S.enabled == 0) return FALSE
	for(var/allowedrace in S.compatible_races)
		if(src.Race in allowedrace)	return TRUE
	for(var/allowedclass in S.compatible_classes)
		if(src.Class in allowedclass)	return TRUE
	return FALSE

mob/proc/learnSkill(datum/skill/S, var/baselevel)
	S.learn(src, baselevel)

mob/proc/SWEEP(datum/skill/S)
	var/datum/skill/nS = new S.type
	S.TransferCustomVars(nS)
	for(var/v in nS.vars)
		if(v in S.copylist)nS.vars[v] = S.vars[v]
		else continue
	for(var/c in S.vars)
		if(c==type)continue
		S.vars[c] = nS.vars[c]

//mob/verb/Forget_Skill()
//	set category = "Skills"
//	var/list/Forget=new/list
//	for(var/datum/skill/S in learned_skills) if(S.can_forget == TRUE) Forget.Add(S)
//	Forget.Add("Cancel")
//	var/Choice=input("Forget which skill?") in Forget
//	if(Choice=="Cancel") return
//	for(var/datum/skill/S in learned_skills) if(S==Choice) S.forget()

/*mob/Debug/verb/Regenerate_Skills()
	set category = "Debug"
	switch(input(usr,"Are you sure, this WILL REGENERATE THEIR STATS TOO! (All this does, is for every player, stat race again, generate basic and racial trees, reset stat buffs.)") in list("Yes","No"))
		if("Yes")
			for(var/mob/M in player_list)
				if(M.client)
					M.StatRace(M.Race)
					M.generatetrees(1)
					M.generatetrees(0)

					M.physoffBuff = 0
					M.physdefBuff = 0
					M.techniqueBuff = 0
					M.kioffBuff = 0
					M.kidefBuff = 0
					M.kiskillBuff= 0
					M.speedBuff = 0
					M.magiBuff = 0*/