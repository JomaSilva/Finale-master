var/lifeskillcap = 0//level cap set on lifeskills and crafting, 0 is no cap

mob/var
	list/masteries = list()//a list of all the masteries a mob possesses
	list/masteryverbs = list()//a list of all the verbs awarded by masteries
	list/learnedmasteries = list()//a list of the masteries a mob has learned
	totalexp = 0//how much exp the character has, used to determine BP
	gexp = 0//amount of general exp the character has, can be put into any skill
	accgexp = 0//how much gexp has your character accumulated?
	exprate = 1//rate that the mob gains exp, used in scaling calcs; make sure to multiply this
	gexpcap = 0.6//how much gexp can you get, as a proportion of the current exp cap
	adaptation = 1//rate at which you catch up to opponents
	lifeexprate = 1
	craftexprate = 1

/datum/mastery//the idea of the mastery datum is a container for exp that levels up and can be easily toggled on/off without constantly checking things
	var
		name = ""//self-explanatory
		desc = "A mastery."//description the player will see in the mastery window
		lvltxt = "Grow in power!"//list of level up bonuses
		icon = 'Ability.dmi'//icon that will display in the mastery window
		icon_state = "learned"//state for toggling between learned and unlearned
		list/types = list("Mastery")//list of types the mastery falls under, useful for grouping, by default is a "Mastery"
		reqtxt = "Learned by default."//description of the requirements to learn, be as specific as you want
		level = 1
		exp = 0//as it says, this will increment as you use the mastery and contribute to your BP; does not get set to 0 on levelup
		nxtmod = 1//multiplies the amount of exp needed for the next level
		nxtlvl = 1000//exp needed for level up, once you pass this threshold levelup() is called
		prevlvl = 0//exp for previous level, used for display purposes
		maxlvl = 100//level cap for the mastery, can be whatever you want
		tier = 0//used to denote the power of the mastery conceptually, tier 0 are learned by default
		battle = 1//does this mastery count toward total exp and by extension BP
		visible = 0//does this show up in the mastery list? tick to 1 for actual masteries
		available = 0//can the player learn this mastery currently?
		learned = 0//is the mastery currently learned?
		nocost = 0//is this mastery free? set to 1 to not require or refund insight
		locked = 0//has the player locked their exp gain?
		update = 0//this will be ticked to 1 when a mastery needs to be replaced
		hidden = 0//can be used to hide a mastery
		mob/savant = null//who does the mastery belong to?
		req_sp = 0 //merging with Trees. How many skillpoints do I need total to progress? (Skillpoints aren't removed, you just need to hit this threshold)
	proc
		expscale(num)//scales the gained exp by a variety of factors, separated here for easy manipulation per mastery
			if(!savant)
				return
			var/gain = round(max(1,num*savant.exprate*gexprate+savant.Egains))//can add whatever modifiers you want here to scale the exp, the final result is what's added to the mastery
			return gain

		expgain(num,ovr)//gives exp to the mastery, only modify exp by calling this
			if(!savant)
				return
			if(locked)
				return
			var/gain
			if(!ovr)
				gain = round(max(1,expscale(num)))
			else
				gain = num
			if(level<maxlvl)
				exp+=gain
				if(battle)
					savant.totalexp+=gain
			else if(level >= maxlvl && exp > nxtlvl)
				capout()
			while(exp>=nxtlvl && level<maxlvl)//this loop will probably only run once, but in case you get two or more level's worth of exp, here it is
				levelup()
			if(level>=maxlvl&&exp>nxtlvl)
				//var/reduce = exp-nxtlvl
				exp=nxtlvl

		capout()
			if(level>=maxlvl && exp > nxtlvl)
				//var/diff = exp - nxtlvl
				exp = nxtlvl

		levelup()//sets exp for the next level, increments level
			if(level+1<maxlvl)//we only want to increase the exp requirement if the next level isn't the max level
				prevlvl=nxtlvl
				nxtlvl+= round(1000*(level**0.5)*nxtmod)
			level++
			levelstat()

		levelstat()//modify stats/effects on levelup; two primary approaches here, continuous and breakpoint: continuous - stat is some function of level, breakpoint - stat is added at a given level
			if(!savant)
				return
			if(level == maxlvl&&battle)//mastering a battle mastery gives you an insight to learn a new mastery
				savant.insights++
				savant<<"You've gained insight!"
			//if(level == N) stat - if level is equal to N: used to give something at a specific level
			//if(level % X == 0) stat - if level is evenly divisible by X: used to give something every X levels
			//stat+=f(level) - modify a stat by some fuction f of the current level

		acquire(mob/M)//proc for adding the mastery to a mob, do things on learn here
			savant = M
			learned = 1
			M.learnedmasteries+=src
			if(!nocost&&tier>0)
				savant.insights--

		enable(datum/mastery/M)//to directly enable other masteries
			if(!savant)
				return
			for(var/datum/mastery/S in savant.masteries)
				if(istype(S,M))
					S.available = 1
					savant<<"You may now learn [S.name]!"
		make_visible(datum/mastery/M)//to directly enable other masteries
			if(!savant)
				return
			for(var/datum/mastery/S in savant.masteries)
				if(istype(S,M))
					S.visible = 1
		make_invisible(datum/mastery/M)//to directly enable other masteries
			if(!savant)
				return
			for(var/datum/mastery/S in savant.masteries)
				if(istype(S,M))
					S.visible = 0

		remove()//if you need to remove a mastery, for some reason, make sure to remove all bonuses here: also resets it to the default state
			if(!savant)
				return
			if(battle)
				savant.totalexp-=exp
				if(level==maxlvl)
					savant.insights--
			if(!nocost&&tier>0)
				savant.insights++
			if(battle) savant<<"You've lost access to your [name] mastery! Your total exp has decreased by [exp] as a consequence!"
			else savant<<"You've lost access to your [name] mastery!"
			savant = null
			learned = 0
			exp = initial(exp)
			level = initial(level)
			nxtlvl = initial(nxtlvl)

		addverb(var/V)
			savant.verbs+=V
			savant.Keyableverbs+=V
			savant.masteryverbs+=V

		removeverb(var/V)
			savant.verbs-=V
			savant.Keyableverbs-=V
			savant.masteryverbs-=V

proc/AddExp(var/mob/M, var/A, num)//generic exp proc, looks in mob M for a mastery of type A to give num exp to
	for(var/datum/mastery/B in M.learnedmasteries)
		if(istype(B,A) && (!B.req_sp || (B.req_sp >= 1 && B.req_sp <= M.totalskillpoints)))
			B.expgain(num)

mob/proc/enable_visibility(datum/mastery/M)
	var/datum/mastery/S = locate(M) in masteries
	if(S)
		S.visible = 1

mob/proc/disable_visibility(datum/mastery/M)
	var/datum/mastery/S = locate(M) in masteries
	if(S)
		S.visible = 0

mob/proc/mastery_enable(datum/mastery/M)
	var/datum/mastery/S = locate(M) in masteries
	if(S)
		S.available = 1
		src<<"You may now learn [S.name]!"

mob/proc/mastery_disable(datum/mastery/M)
	var/datum/mastery/S = locate(M) in masteries
	if(S)
		S.available = 0
		src<<"You cannot learn [S.name]!"

mob/proc/mastery_remove(datum/mastery/M)
	var/datum/mastery/S = locate(M) in masteries
	if(S)
		S.remove()
		src<<"You forgot [S.name]!"
var
	gexprate = 1//global exp rate

mob/Admin3/verb/Edit_Masteries(mob/M in player_list)
	set category="Admin"
	var/list/masteryselect = new/list()
	for(var/datum/mastery/A in M.masteries)
		masteryselect+=A
	var/datum/mastery/S
	S = input(usr,"Which mastery do you want to edit?","",null) as null|anything in masteryselect
	if(!S)
		return
	else
		switch(alert(usr,"What do you want to edit?","","Exp","Availability","Learned"))
			if("Exp")
				var/gain=input(usr,"How much exp? The skill currently has [S.exp]/[S.nxtlvl].","",null) as num
				S.expgain(gain,1)
			if("Availability")
				switch(alert(usr,"Make this mastery available to learn? Availability is currently [S.available].","","Yes","No","Cancel"))
					if("Yes")
						S.available = 1
					if("No")
						S.available = 0
					if("Cancel")
						return
			if("Learned")
				switch(alert(usr,"Learn or unlearn this mastery?","","Learn","Unlearn","Cancel"))
					if("Learn")
						if(!S.learned)
							S.acquire(M)
						else
							usr<<"[M.name] already knows this!"
					if("Unlearn")
						if(S.learned)
							S.remove()
						else
							usr<<"[M.name] doesn't know this!"
					if("Cancel")
						return

mob/Admin3/verb
	Global_EXP_Rate()
		set category="Admin"
		var/rate = input(usr,"What do you want to set the global exp rate to? Current rate is [gexprate]","",null) as num
		if(rate)
			gexprate = rate
			world<<"Global EXP rate set to [gexprate]"

	Lifeskill_Level_Cap()
		set category="Admin"
		var/rate = input(usr,"What do you want to set the Lifeskill Level Cap to? Current cap is [lifeskillcap]. Set to 0 for no cap.","",null) as num
		if(rate)
			rate = max(rate,0)
			lifeskillcap = rate
			world<<"Lifeskill Level Cap set to [lifeskillcap]"

/*mob/default/verb/Skill_Information()
	set category = "Other"
	var/list/choice = list()
	for(var/A in usr.)
		choice+=A:name
	var/selection = input(usr,"Which skill would you like to see the description of?","") as null|anything in choice
	if(!selection)
		return
	else
		for(var/A in usr.masteryverbs)
			if(A:name==selection)
				usr<<"[A:name]:[A:desc]"*/
