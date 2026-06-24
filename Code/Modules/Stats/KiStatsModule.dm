//New Ki stats block, these are stats that affect various ki skills and are prerequisites for learning new one

var/GlobalKiExpRate = 1

mob/var
	//this is the block of "general" skills that effect broad categories of ki, the user will need a certain level of these in combination with specific ki skill levels to unlock advanced archetypes
	kiawarenessskill=0//ability to sense ki and recognize what that ki is doing
	kieffusionskill=0//ability to emit ki energy
	kicirculationskill=0//ability to use ki for internal purposes e.g., buffing
	kicontrolskill=0//ability to direct and channel ki
	kiefficiencyskill=0//how efficient the user is with the ki they have
	kigatheringskill=0//how able the user is to build and recover ki
	//this is the block of skill with specific ki archetypes, the user will need levels here to learn advanced techniques
	blastskill=0//blasts
	beamskill=0//beams
	chargedskill=0//charged ki attacks, will effect beam charging and things like death ball
	kiaiskill=0//shockwaves
	guidedskill=0//user-directed attacks
	homingskill=0//homing ki attacks
	targetedskill=0//attacks that originate near a target
	volleyskill=0//attacks that fire ki rapidly
	kibuffskill=0//skills that strengthen you
	kidebuffskill=0//skills that weaken others
	kidefenseskill=0//skills that protect you
	//this is the block of skill usage counters, so that players can accumulate exp for each skill type usage
	blastcounter=0
	beamcounter=0
	chargedcounter=0
	kiaicounter=0
	guidedcounter=0
	homingcounter=0
	targetedcounter=0
	volleycounter=0
	kibuffcounter=0
	kidebuffcounter=0
	kidefensecounter=0
	kbpow
	kbdur
	kbdir
//Here are the procs common to various ki attacks, compiled here for convenience. Procs for projectile attacks are still in the objects.dm

mob/proc/KiKnockback(var/mob/user,strength)//strength is the number of steps back to take
	strength = round(strength)
	kbpow=user.expressedBP
	kbdur=strength
	kbdir=user.dir
	AddEffect(/effect/knockback)

mob/var/tmp/studying = 0//so you can only study 1 target at a time

/mob/keyable/verb/Study_Other()
	set category = "Learning"
	desc = "Study the skill usage of another, allowing you to benefit from their knowledge"
	if(studying)
		usr<<"You stop studying your target."
		studying = 0
		return
	var/list/selection = new/list()
	for(var/mob/M in oview(20))
		if(M.client)
			selection+=M.name
	var/target = input(usr,"Who do you want to study?","",null) as null|anything in selection
	if(!target)
		return
	else
		studying = 1
		usr<<"You begin to study [target]"
		while(studying)
			sleep(10)
			var/range = 0
			for(var/mob/nM in oview(10))
				if(nM.name == target)
					for(var/datum/skill/mind/S in nM.learned_skills)
						for(var/datum/skill/mind/nS in usr.learned_skills)
							if(focusskill && nS.name==S.name && nS.name == focusskill)
								if(nS.level<S.level)
									nS.expbuffer+=50*(S.level-nS.level)*max(1,log(2,nS.level))
							else if(!focusskill && nS.name==S.name)
								if(nS.level<S.level)
									nS.expbuffer+=5*(S.level-nS.level)*max(1,log(2,nS.level))
						sleep(1)
					range+=1
			if(range<=0)
				studying=0

/mob/var/focusskill

/mob/keyable/verb/Focus_Skill(var/datum/skill/mind/S in learned_skills)
	set category = "Learning"
	if(!S)
		usr<<"You have nothing to focus on!"
		return
	focusskill = S.name
	usr<<"You will now focus on learning [focusskill]."

/mob/keyable/verb/Assess_Ki_Skill(mob/M in oview(20))
	set category = "Skills"
	if(usr.kiawarenessskill<=25)
		if(KiTotal()>M.KiTotal())
			usr<<"You sense that they have less ki proficiency than you."
		else if(KiTotal()<M.KiTotal())
			usr<<"You sense that they have greater ki proficiency than you."
		else
			usr<<"You sense that they are equal to you in ki proficiency."
	else if(usr.kiawarenessskill<=50)
		usr<<"You assess their ki proficiencies compared to yours..."
		if(usr.kiawarenessskill>=M.kiawarenessskill)
			usr<<"You are more aware of ki than they are."
		else
			usr<<"You are less aware of ki than they are."
		if(usr.kieffusionskill>=M.kieffusionskill)
			usr<<"You effuse more ki than they do."
		else
			usr<<"You effuse less ki than they do."
		if(usr.kicirculationskill>=M.kicirculationskill)
			usr<<"You circulate more ki than they do."
		else
			usr<<"You circulate less ki than they do."
		if(usr.kicontrolskill>=M.kicontrolskill)
			usr<<"You have better control over ki than them."
		else
			usr<<"You have worse control over ki than them."
		if(usr.kiefficiencyskill>=M.kiefficiencyskill)
			usr<<"You are more efficient with ki than them."
		else
			usr<<"You are less efficient with ki than them."
		if(usr.kigatheringskill>=M.kigatheringskill)
			usr<<"You gather more ki than them."
		else
			usr<<"You gather less ki than them."
	else if(usr.kiawarenessskill>50)
		usr<<"You sense their ki skills are as follows:"
		usr<<"Awareness: [M.kiawarenessskill]"
		usr<<"Effusion: [M.kieffusionskill]"
		usr<<"Circulation: [M.kicirculationskill]"
		usr<<"Control: [M.kicontrolskill]"
		usr<<"Efficiency: [M.kiefficiencyskill]"
		usr<<"Gathering: [M.kigatheringskill]"

mob/var
	writing = 0
	writetime = 0
	writetarget = 0
	writename = ""
	writelevel = 0
	writeexp = 0

/mob/keyable/verb/Write_Teachings()
	set category = "Learning"
	var/list/skillselect = new/list()
	if(!usr.writing)
		for(var/datum/skill/mind/S in usr.learned_skills)
			skillselect+=S.name
		var/datum/skill/mind/A
		A = input(usr,"Which skill would you like to scribe teachings for? You can only make progress scribing while meditating.","",null) as null|anything in skillselect
		if(!A)
			return
		else
			for(var/datum/skill/mind/nA in usr.learned_skills)
				if(A == nA.name)
					if(nA.level == 0)
						usr<<"You have no knowledge to teach!"
						return
					usr.writing=1
					usr.writetarget = nA.level*300
					usr.writename = nA.name
					usr.writelevel = round(nA.level/2)
					usr.writeexp = 2000*max(1,log(2,nA.level))*1.04**nA.level
					usr<<"You begin to write a book on [nA.name]. It will take [usr.writetarget/10] seconds to complete. Meditate to write."
					break
	else
		var/choice = alert("You need [(usr.writetarget-usr.writetime)/10] more seconds to finish your writing. Do you want to continue, or stop writing? You will lose all progress if you stop.","","Continue","Stop")
		switch(choice)
			if("Continue")
				return
			if("Stop")
				usr<<"You stop writing."
				usr.writing=0
				usr.writetime=0
				usr.writetarget=0
				usr.writename=""
				usr.writelevel=0
				usr.writeexp=0

/obj/items/book/Skillbook
	icon = 'Books.dmi'
	SaveItem=1
	stackable=0
	var/level
	var/exp
	var/skillname
	verb/Description()
		set category = null
		usr<<"Read to learn about ki techniques. You must know the relevant skill and be at or below the listed level."
	verb/Study_Book()
		set category = null
		var/count = 0
		for(var/datum/skill/mind/S in usr.learned_skills)
			if(S.name == skillname)
				if(S.level<=level)
					var/gain = S.KiSkillGains(exp)
					S.exp+=gain
					usr<<"Your [skillname] skill gained [gain] experience!"
					del(src)
				else
					usr<<"You can't learn anything from this book"
				count++
				break
		if(!count)
			usr<<"You don't know this skill!"
			return

/mob/Admin3/verb/Set_Skill_Level(mob/M in player_list)
	set category = "Admin"
	var/list/skillselect = new/list()
	for(var/datum/skill/A in M.learned_skills)
		if(A.maxlevel > 1)//only want skills that can actually levle
			skillselect+=A.name//convoluted process to avoid a list of datum/skill/whatever
	var/datum/skill/S
	S = input(usr,"Which skill do you want to edit?","",null) as null|anything in skillselect
	if(!S)
		return
	else
		for(var/datum/skill/B in M.learned_skills)
			if(S == B.name)
				S = B
				break
		var/slevel
		slevel = input("What level do you want to set the skill to? It's currently level [S.level].") as num
		var/sexp
		sexp = input("What exp do you want to set the skill to?") as num
		if(alert(usr,"You sure?","","Yes","No") == "Yes")
			S.level = slevel
			S.exp = sexp
/mob/Admin3/verb/Reward_Skill_Level(mob/M in player_list)
	set category = "Admin"
	var/list/skillselect = new/list()
	for(var/datum/skill/A in M.learned_skills)
		if(A.maxlevel > 1)//only want skills that can actually levle
			skillselect+=A.name//convoluted process to avoid a list of datum/skill/whatever
	var/datum/skill/S
	S = input(usr,"Which skill do you want to improve? You can cancel the levelup by using Set Skill Level to a lower skill than what it is.","",null) as null|anything in skillselect
	if(!S)
		return
	else
		var/slevel
		slevel = input("What level do you want to improve the skill to?") as num
		if(input(usr,"[S] being leveled up to [slevel]. Continue?","","No") in list("Yes","No")=="No") return
		for(var/datum/skill/B in M.learned_skills)
			if(S == B.name)
				var/stored_level = B.level
				while(B.level<slevel)
					B.level++
					stored_level = B.level
					B.levelup=1
					sleep(5)
					if(B.level < stored_level) break //Set skill level can cancel reward skill level.


/mob/proc/KiTotal()
	set waitfor=0
	var/total=0
	for(var/datum/skill/mind/S in learned_skills)
		total+=S.level
	return total