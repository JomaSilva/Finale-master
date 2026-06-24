/datum/skill/tree
	skilltype = null
	common_sense = FALSE
	compatible_races = list()
	compatible_classes = list()
	tier=0 //trees use this to sort into pages
	copylist = list("type","skillcost","level","exp","savant","enabled","teacher","investedskills","invested","allowedtier") //trees have a few extra copies.
	var/didchange = 0 //did something change?
	var/invested = 0 //for buffs & stat mods & unlocks
	var/allowedtier = 1 //how high are you?
	var/maxtier = 1 //how high can you go?
	var/list/banlist = list() //disallows
	var/list/investedskills = list() //what skills does it have to make you forget
	var/list/constituentskills = list() //what skills can it give you
	var/can_refund = FALSE //can you sell the whole thing back?

/datum/skill/tree/proc/testskillprereqs()
	var/precheck
	//world << "[name] the tree reporting for duty! I had [invested] skillpoints in me, which was reset to 0..."
	invested=0
	for(var/datum/skill/nS in investedskills)
		invested+=nS.skillcost
	for(var/datum/skill/S in constituentskills)
		if(locate(S.type) in savant.learned_skills) continue
		if(S.type in banned_skill_list)
			S.enabled = 0
			continue
		if(S.prereqs.len > 0)
			precheck = S.prereqs.len - S.prereqthreshold
			for(var/datum/skill/nS in S.prereqs)
				if(locate(nS.type) in savant.learned_skills)
					precheck-=1
			if(precheck<=0&&S.enabled==0)
				if(allowedtier >= S.tier) savant<<"You can now acquire Skill [S.name]!"
				S.enabled = 1
			else if(precheck>0&&S.enabled==1)
				if(allowedtier >= S.tier) savant<<"You can no longer acquire Skill [S.name]."
				S.enabled = 0
	for(var/datum/skill/S in savant.learned_skills)
		if(S.prereqs.len > 0)
			precheck = S.prereqs.len - S.prereqthreshold
			for(var/datum/skill/nS in S.prereqs)
				if(locate(nS.type) in savant.learned_skills)precheck-=1
			if(precheck<=0&&S.enabled==0)
				S.enabled = 1
			if(precheck>0&&S.enabled==1)
				S.enabled = 0
	//world << "[name]: Now I have [invested]!!"
	return


/datum/skill/tree/login(var/mob/logger)
	..()
	src.savant = logger
	updateconstituents()
	return


/datum/skill/tree/proc/acquire(var/mob/trainee)
	src.enabled=1
	trainee.possessed_trees.Add(src)
	src.savant = trainee
	src.onacquire()
	return
/datum/skill/tree/proc/onacquire()
	mod()
	savant.testunlocks()
	return

/datum/skill/tree/proc/mod()
	return
/datum/skill/tree/proc/demod()
	savant<<"You lost your ability to use [src.name], and with it, a huge chunk of power!"
	purge(src)
	return
/datum/skill/tree/proc/purge()
	for(var/datum/skill/S in savant.learned_skills)
		if((S.can_forget == TRUE)&&locate(S.type) in src.investedskills)
			refund(S,1)
	for(var/datum/skill/tree/T in savant.possessed_trees)if(T!=src)T.didchange=1
	del(src)
	return

/datum/skill/tree/proc/refund(var/datum/skill/S,var/bypass)
	invested-=S.skillcost
	investedskills.Remove(S)
	S.forget()
	treeshrink()
	didchange=1

/datum/skill/tree/proc/fund(var/datum/skill/S)
	var/datum/skill/nS = new S.type
	if(!savant && ismob(usr)) savant = usr
	//world << "savant = [usr]|[savant]."
	savant.learnSkill(nS, 0, 0)
	savant.skillpoints -= S.skillcost
	invested+=S.skillcost
	investedskills.Add(nS)
	didchange=1
	return

/datum/skill/tree/proc/treegrow()//use this to advance tiers based on various factors
	//world << "treegrow"
	testskillprereqs()
	savant.testunlocks()
	return

/datum/skill/tree/proc/treeshrink() //automatically refunds skills if tier drops
	testskillprereqs()
	savant.testunlocks()
	for(var/datum/skill/S in savant.learned_skills)
		if(locate(S.type) in investedskills && S.tier > allowedtier && S.can_forget)
			savant<<"You don't have enough skill in [src.name] to maintain [S.name]!"
			refund(S)
		for(var/datum/skill/nS in constituentskills)
			if(nS.type == S.type)
				if(nS.enabled == 0 && S.can_forget)
					savant<<"You forgot the prereqs for skill [S.name] and forgot it as well."
					refund(S)
				if(nS.override == 1 && S.can_forget)
					savant<<"You learned a skill incompatible for [S.name] and as a result forgot it."
					refund(S)
	return

/datum/skill/tree/proc/growbranches() //place any enabling in here - trees are enabled by default, but advanced trees should start as "0"
	testskillprereqs()
	return

/datum/skill/tree/proc/prunebranches()
	testskillprereqs()
	return

/datum/skill/tree/proc/enabletree(var/datum/skill/tree/path)
	if(!(locate(path) in savant.allowed_trees))
		var/datum/skill/tree/nT = new path
		nT.savant = savant
		nT.enabled=1
		savant<<"You can now acquire the Skilltree [nT.name]!"
		savant.allowed_trees.Add(nT)
	for(var/datum/skill/tree/T in savant.allowed_trees)
		if(istype(T,path)&&T.enabled==0)
			T.enabled=1
			savant<<"You can now acquire the Skilltree [T.name]!"
	return

/datum/skill/tree/proc/disabletree(var/datum/skill/tree/path1)
	for(var/datum/skill/tree/T in savant.allowed_trees)
		if(istype(T,path1)&&T.enabled==1)
			T.enabled=0
			savant<<"You can no longer acquire the Skilltree [T.name]."
	return

datum/skill/tree/proc/blacklist(var/datum/skill/S)
	for(var/datum/skill/nS in constituentskills)
		if(nS.type==S)
			nS.override=1
datum/skill/tree/proc/whitelist(var/datum/skill/S)
	for(var/datum/skill/nS in constituentskills)
		if(nS.type==S)
			nS.override=0
datum/skill/tree/proc/enableskill(var/datum/skill/S)
	for(var/datum/skill/nS in constituentskills)
		if(nS.type==S)
			if(!nS.enabled) savant<<"You can now learn [nS.name]!"
			nS.enabled=1
datum/skill/tree/proc/disableskill(var/datum/skill/S)
	for(var/datum/skill/nS in constituentskills)
		if(nS.type==S)
			if(nS.enabled) savant<<"You can no longer learn [nS.name]"
			nS.enabled=0
datum/skill/tree/proc/is_enabled(var/datum/skill/S)
	for(var/datum/skill/nS in constituentskills)
		if(nS.type==S)
			if(nS.enabled) return TRUE
			else return FALSE

datum/skill/tree/proc/is_learned(var/datum/skill/S)
	set waitfor = 0
	if(locate(S) in savant.learned_skills)
		return TRUE
	return FALSE

datum/skill/tree/proc/updateconstituents()
	set background = 1
	set waitfor = 0
	//
	var/datum/skill/tree/nT = new type
	var/list/newtreeskills = list()
	//var/list/removetreeskills = list() skills that aren't in a tree's default constituent skills anymore post update are not cared about to ensure player character safety. (for right now)
	for(var/datum/skill/nS in nT.constituentskills)
		var/hasequal
		for(var/datum/skill/oS in src.constituentskills)
			if(istype(oS,nS.type))
				hasequal = 1
				break
		if(hasequal)
			continue
		else
			newtreeskills += nS
	if(newtreeskills.len >= 1)
		for(var/N in newtreeskills)
			constituentskills += N
	testskillprereqs()