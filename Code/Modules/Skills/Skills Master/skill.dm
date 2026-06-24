/datum/skill
//	type = "anti bug lol"
	var/skilltype = "Physical" //is it Physical, Ki, or Magic?
	var/name = ""
	var/desc = ""
	var/icon = 'ability.jpg' //NEW: The icon that'll show in the new Skill window.
	var/level = 0 //what level do you start at when you recieve the skill?
	var/exp = 0 //potential option: you start midway through a level and can lose exp like a karma system
	var/expbarrier = 100 //what arbitrary exp barrier is being reached?
	var/maxlevel = 3 //how high can the skill be trained?
	var/can_forget = TRUE //can it be forgotten?
	var/list/compatible_races = list() //what races can learn this skill?
	var/list/compatible_classes = list() //what classes (subraces) can learn this skill? Over-rides races/set list to null if using this.
	var/mob/savant = null //who is the mob with the skill?
	var/teacher = FALSE //is this mob allowed to teach it?
	var/common_sense = FALSE //can anyone/this mob learn it regardless of barriers?
	var/levelup = 0
	var/prereqthreshold = 0 //the higher this is, the fewer prereqs you need
	var/skillcost = 1 //for new trees system- how much did you pay?
	var/tier = 1 //for new trees system- how high up the ladder is it?
	var/list/prereqs = list() //in case of prereq
	var/list/clearlist = list()//for deletion of verbs where necessary
	var/list/copylist = list("tree","skillcost","level","exp","savant","enabled")//this is the vars that sweeping will copy, self explanatory.
	var/enabled = 1 //for new trees system- set to 0 and modify with other skills to establish prereqs
	var/override = 0 //for new trees system: allows blacklisting of not-yet-learned ability.
	var/tmp/effect_started = 0 
	//ex: if you max fly a if(levelup) toggles the enabled value of "Base Jumping" to 1 and gives the player a messages

/datum/skill/proc/learn(var/mob/trainee, var/baselevel)
	trainee.learned_skills.Add(src)
	src.savant = trainee
	src.level = baselevel
	src.after_learn()
	spawn while(savant)
		effect_started = 1
		src.effector()
		sleep(2)

/datum/skill/proc/logout()
	src.savant = null
	//spawn(50) del(src) //comment this fucker out if it causes issues.
/datum/skill/proc/login(var/mob/logger)
	set waitfor = 0
	src.savant = logger
	spawn while(savant)
		effector()
		sleep(2)
/datum/skill/proc/assignverb(var/V)
	savant.verbs += V
	savant.Keyableverbs += V
/datum/skill/proc/unassignverb(var/V)
	savant.verbs -= V
	savant.Keyableverbs -= V

mob/proc/assignverb(var/V) //This doesn't conflict with assignVerb due to captial.
	verbs += V
	Keyableverbs += V
mob/proc/unassignverb(var/V)
	verbs -= V
	Keyableverbs -= V

/datum/skill/proc/afterTeach(var/mob/Source)
	return

/datum/skill/proc/forget(var/forced)
	if(forced)
		src.before_forget()
		for(var/obj/hotkey/H in savant.Hotkeys)
			if(!H.key)
				del(H)
		savant.skillpoints += src.skillcost
		savant.learned_skills.Remove(src)
		del(src)
	if(can_forget == TRUE)
		src.before_forget()
		savant.skillpoints += src.skillcost
		savant.learned_skills.Remove(src)
		del(src)
	else savant << "You can't forget that skill."

/datum/skill/proc/effector()
	set waitfor = 0
	set background = 1
	if(isnull(savant)) return
	level = min(level, maxlevel)
	exp = max(exp, 0)
	if(exp >= expbarrier && level < maxlevel)
		exp = 0
		level += 1
		levelup = 1

/datum/skill/proc/after_learn()
	return
/datum/skill/proc/before_forget()
	return

/datum/skill/proc/getSkillType()
	return "[skilltype]"
/datum/skill/proc/getSkillName()
	return "[name]"

/datum/skill/proc/TransferCustomVars(var/datum/skill/nS) //fill this up with shit in your own skill to save any extra vars between updates
	return

/mob/verb/Check_Skill_Stats()
	set category = "Learning"
	var/list/skillselect = new/list()
	for(var/datum/skill/A in usr.learned_skills)
		//if(A.maxlevel > 1)//only want skills that can actually level
		skillselect+=A.name//convoluted process to avoid a list of datum/skill/whatever
	var/datum/skill/S
	S = input(usr,"Which skill do you want to view?","",null) as null|anything in skillselect
	if(!S)
		return
	else
		for(var/datum/skill/nS in usr.learned_skills)
			if(S == nS.name)
				usr<<"You focus on your skill: [nS.name]"
				usr<<"[nS.desc]"
				usr<<"[nS.skilltype]"
				usr<<"Tier: [nS.tier]"
				usr<<"Level: [nS.level]/[nS.maxlevel]"
				usr<<"Experience: [nS.exp]/[nS.expbarrier]"
				if(nS.teacher)
					usr<<"You may teach others this skill"
				else if(!nS.teacher)
					usr<<"You may not teach others this skill"