mob/var
	list/possessed_trees = list()
	list/allowed_trees = list()
	tmp/inAwindow = 0


mob/proc/HandleLevel()
	DOESEXIST
	processpoints()
	var/total
	for(var/datum/skill/tree/N in possessed_trees)
		total+=N.invested
	DOESEXIST
	total+=skillpoints
	if(total<totalskillpoints)
		var/gained = totalskillpoints - total //catch up FULLY in one call so admin/global/wish gifts and big BP jumps register at once (was +1 per call, which made gifts trickle in only while moving)
		skillpoints += gained
		src<<"You've gained [gained] Milestone[gained>1?"s":""]!"
	else if(total>totalskillpoints&&skillpoints>0)
		var/lost = min(skillpoints, total-totalskillpoints) //only happens if the cap genuinely dropped (e.g. skillpointMod fell); never below 0
		skillpoints -= lost
		src<<"You've lost [lost] Milestone[lost>1?"s":""] due to losing raw power."

/mob/proc/getTree(datum/skill/tree/T)
	var/datum/skill/tree/nT = new T.type
	if(!(locate(T.type) in src.allowed_trees))
		nT.savant = src
		nT.enabled=1
		src.allowed_trees.Add(nT)
	else nT=null
	T.acquire(src)
	return

mob/proc/treerot()
	for(var/datum/skill/tree/T in allowed_trees)
		for(var/datum/skill/tree/nT in possessed_trees)
			if(istype(nT,T)&&!T.enabled)
				nT.demod()
				testunlocks()
	for(var/datum/skill/tree/T in allowed_trees)
		if(!T.enabled)T.purge()

mob/proc/generatetrees(GenerateRacials = null)
	if(GenerateRacials == null || GenerateRacials == 0)
		getTree(new /datum/skill/tree/Body)
		getTree(new /datum/skill/tree/Mind)
		getTree(new /datum/skill/tree/Spirit)
		//getTree(new /datum/skill/tree/Custom_Attacks)
	else
		var/r_race = Parent_Race
		if(r_race=="Saiyan")//Race=="Half-Saiyan"
			getTree(new /datum/skill/tree/saiyan/SaiyanRacial)
		//if(r_race=="Half-Breed")
		//	getTree(new /datum/skill/tree/halfbreed)
		if(r_race=="Meta")
			getTree(new /datum/skill/tree/meta)
		if(r_race=="Human")
			getTree(new /datum/skill/tree/human)
			if(Class=="Shapeshifter")
				getTree(new /datum/skill/tree/shapeshifter)
		if(r_race=="Android")
			getTree(new /datum/skill/tree/android)
		if(r_race=="Alien")
			getTree(new /datum/skill/tree/alien)
			if(Class=="Arlian")
				getTree(new /datum/skill/tree/arlian)
			if(Class=="Kanassa-Jin")
				getTree(new /datum/skill/tree/kanassajin)
		if(r_race=="Gray")
			getTree(new /datum/skill/tree/gray)
		if(r_race=="Bio-Android")
			getTree(new /datum/skill/tree/bioandroid)
		if(r_race=="Demigod")
			getTree(new /datum/skill/tree/demigod)
		if(r_race=="Demon")
			getTree(new /datum/skill/tree/demon)
		if(r_race=="Frost Demon")
			getTree(new /datum/skill/tree/frostdemon)
		if(r_race=="Kai")
			getTree(new /datum/skill/tree/kai)
		if(r_race=="Heran")
			getTree(new /datum/skill/tree/heran)
		if(r_race=="Majin")
			getTree(new /datum/skill/tree/majin)
		if(r_race=="Makyo")
			getTree(new /datum/skill/tree/makyo)
		if(r_race=="Namekian")
			getTree(new /datum/skill/tree/namek)
		if(r_race=="Saibamen")
			getTree(new /datum/skill/tree/saibaman)
		if(r_race=="Spirit Doll")
			getTree(new /datum/skill/tree/spiritdoll)
		if(r_race=="Tsujin")
			getTree(new /datum/skill/tree/tsujin)
		if(r_race=="Yardrat")
			getTree(new /datum/skill/tree/yardrat)

mob/proc/TREESWEEP(datum/skill/tree/T)
	var/datum/skill/tree/nT = new T.type
	T.TransferCustomVars(nT)
	for(var/v in nT.vars)
		if(v in T.copylist)nT.vars[v] = T.vars[v]
		else continue
	for(var/c in T.vars)
		if(c==type)continue
		T.vars[c] = nT.vars[c]
	for(var/datum/skill/S in T.investedskills)
		src.SWEEP(S)
	T.didchange=1