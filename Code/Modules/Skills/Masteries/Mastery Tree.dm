var
	list/globalmasteries = list()//this list will be populated every boot with all the masteries in the game, player mastery lists will be checked against this to see if they need masteries added/removed
	mupdate = 0//upticked each time mastery updates are called

mob/var
	tmp/checking=0//to keep masteries from double checking

proc/Init_Masteries()//this populates the global mastery list will all "real" masteries
	set waitfor = 0
	var/list/types = list()
	types+=typesof(/datum/mastery)
	for(var/A in types)
		var/datum/mastery/B = new A
		//world << "[B] [B.name] added to global."
		if(B.visible||B.hidden)
			globalmasteries.Add(A)

mob/Admin3/verb/Reinitialize_Masteries()
	set category = "Admin"
	mupdate++
	usr<<"Masteries will now update."
	for(var/mob/M in player_list)
		M.Check_Masteries()


mob/proc/Check_Masteries()//this checks the player's masteries against the global list, and either adds or removes masteries to make sure they're consistent
	set background = 1
	if(checking)
		return
	checking=1
	while(worldloading)
		sleep(5)
	//world << "Done loading?"
	for(var/datum/mastery/A in src.masteries)
		var/counter = 0
		A.capout()
		for(var/B in globalmasteries)
			if(A.type == B)
				counter++
				break
		if(!counter)
			A.remove()
			del(A)
		if(A.update<mupdate)
			Replace_Mastery(A)
			del(A)
	for(var/C in globalmasteries)
		var/counter = 0
		for(var/datum/mastery/D in src.masteries)
			if(D.type == C)
				counter++
				break
		if(!counter)
			var/datum/mastery/E = new C
			src.masteries.Add(E)
			E.savant = src
			E.update = mupdate
	for(var/datum/mastery/F in src.masteries)//we're looping again once we're sure the player has all the masteries they need, not the most efficient but it also ensures that we don't miss any
		//world << "[F] [F.name], [F.tier], [F.learned] local masteries"
		F.savant = src
		for(var/A in usr.masteryverbs)
			assignVerb(A)
			verbs += A
			Keyableverbs += A
		if(F.tier==0&&!F.learned)//all tier 0 masteries are "default" and should be automatically learned
			F.acquire(src)
	checking=0

mob/proc/Replace_Mastery(datum/mastery/M)
	set background = 1
	var/tmpexp = 0
	if(!M.learned)
		var/datum/mastery/B = new M.type
		B.update = mupdate
		if(M.available)
			B.available = 1
		if(M.visible)
			B.visible = 1
		src.masteries.Add(B)
	else
		tmpexp = M.exp
		var/datum/mastery/B = new M.type
		B.update = mupdate
		if(M.available)
			B.available = 1
		if(M.visible)
			B.visible = 1
		M.remove()
		src.masteries.Add(B)
		B.acquire(src)
		B.expgain(tmpexp,1)



mob/var
	insights = 2//insights are used to learn masteries, you spend them to unlock and gain them from mastering and other things

mob/verb
	Masteries()
		set category = "Learning"
		if(!usr||inAwindow) return FALSE
		winshow(usr,"MasteryWindow", 1)
		usr.inAwindow = 1
		usr.updateMastery = 1
		Mastery_Window_Int()
		contents += new/obj/masterywindow

mob/proc
	CloseMasteryWindow()
		set waitfor = 0
		spawn
			winshow(usr,"MasteryWindow", 0)
			usr.updateMastery = 1
			usr.inAwindow = 0

	Mastery_Window_Int()
		if(!src) return FALSE
		if(!src.inAwindow) return FALSE
		if(updateMastery)
			updateMastery= 0
			winset(src,"MasteryWindow.MasteryGrid","cells=0")
			winset(src,"MasteryWindow.insightlabel","text=\"Insights: [src.insights]\"")
			winset(src,"MasteryWindow.texplabel","text=\"Total Exp: [FullNum(src.totalexp)]\"")
			winset(src,"MasteryWindow.gexplabel","text=\"Global Exp: [FullNum(src.gexp)]\"")
			var/count = 0
			var/list/Learned = list()
			var/list/Available = list()
			var/list/Unavailable = list()
			for(var/datum/mastery/A in src.masteries)//we have to make a dummy object to interact with in the window which represents our mastery
				if(A.visible||(A.learned && !A.hidden))
					var/obj/mastery/dummymastery/B = new
					B.MasteryType = A
					B.name = A.name
					if(A.locked)
						B.name = "[B.name] (Locked)"
					B.icon = A.icon
					B.desc = A.desc
					B.exp = A.exp
					B.maxlvl = A.maxlvl
					B.tier = A.tier
					B.reqtxt = A.reqtxt
					if(A.learned)
						B.icon_state = "learned"
					else if(A.available)
						B.icon_state = "unlearned"
					else
						B.icon = 'Ability.dmi'
						B.icon_state = "unavailable"
					if(A.learned)
						Learned+=B
					else if(A.available)
						Available+=B
					else
						Unavailable+=B
			for(var/C in Learned)
				src << output(C,"MasteryWindow.MasteryGrid: [++count]")
			for(var/D in Available)
				src << output(D,"MasteryWindow.MasteryGrid: [++count]")
			for(var/E in Unavailable)
				src << output(E,"MasteryWindow.MasteryGrid: [++count]")
			winset(src,"MasteryWindow.MasteryGrid","cells=[count]")
		spawn(10) Mastery_Window_Int()

	CloseMasteryChoiceWindow()
		set waitfor = 0
		spawn
			winshow(usr,"MasteryChoice", 0)
			usr.updateMastery = 1
			usr.checkingMastery = 0

	Mastery_Choice_Int(datum/mastery/M)
		if(!M) return FALSE
		if(!src) return FALSE
		if(!src.inAwindow) return FALSE
		winset(src,"MasteryChoice.masteryname","text=\"[M.name]\"")
		winset(src,"MasteryChoice.tierlabel","text=\"Tier: [M.tier]\"")
		winset(src,"MasteryChoice.masterylevel","text=\"Level: [M.level]/[M.maxlvl]\"")
		winset(src,"MasteryChoice.explabel","text=\"Exp: [FullNum(M.exp)]/[FullNum(M.nxtlvl)]\"")
		winset(src,"MasteryChoice.expbar","value=[100*(M.exp-M.prevlvl)/(M.nxtlvl-M.prevlvl)]")
		winset(src,"MasteryChoice.masterydescription","text=\"[M.desc]\"")
		winset(src,"MasteryChoice.lvluplabel","text=\"[M.lvltxt]\"")
		winset(src,"MasteryChoice.masteryreqs","text=\"[M.reqtxt]\"")
		if(M.learned)
			winset(src,"MasteryChoice.learnedlabel","text=\"Learned\"")
		else if(M.available&&!M.nocost)
			winset(src,"MasteryChoice.learnedlabel","text=\"Unlearned\"")
		else if(M.available&&M.nocost)
			winset(src,"MasteryChoice.learnedlabel","text=\"Unlearned (FREE)\"")
		else
			winset(src,"MasteryChoice.learnedlabel","text=\"Unavailable\"")
		var/obj/mastery/dummyicon/A = new
		A.icon = M.icon
		if(M.learned)
			A.icon_state = "learned"
		else if(M.available)
			A.icon_state = "unlearned"
		else
			A.icon_state = "unavailable"
		src << output(A,"MasteryChoice.masteryicon")
		spawn(10) Mastery_Choice_Int()

obj/masterywindow
	verb/DoneButton()
		set category = null
		set hidden = 1
		set waitfor = 0
		usr.CloseMasteryWindow()//causes a infinite cross reference loop otherwise
		if(usr.checkingMastery)
			usr.CloseMasteryChoiceWindow()
		spawn del(src)

obj/masterychoice
	var/datum/mastery/Choice = null
	verb/DoneButtonM()
		set category = null
		set hidden = 1
		set waitfor = 0
		usr.CloseMasteryChoiceWindow()//causes a infinite cross reference loop otherwise
		spawn del(src)

	verb/LearnButton()
		set category = null
		set hidden = 1
		set waitfor = 0
		if(!Choice) return//exception handling, this should never end up null
		if(Choice.learned)
			usr<<"You already know this mastery!"
		else if(!Choice.learned&&Choice.available&&(usr.insights>=1||Choice.nocost))
			usr<<"You learn [Choice.name]!"
			Choice.acquire(usr)
		else if(!Choice.learned&&!Choice.available)
			usr<<"You don't know how to learn this mastery!"
		else
			usr<<"You lack the insight to learn this!"
		usr.updateMastery = 1
		usr.CloseMasteryChoiceWindow()//causes a infinite cross reference loop otherwise
		spawn del(src)

	verb/AllocateButton()
		set category = null
		set hidden = 1
		set waitfor = 0
		if(!Choice) return
		if(Choice.locked)
			usr<<"This skill is currently locked, preventing EXP gain."
			return
		if(Choice.level>=Choice.maxlvl)
			usr<<"This skill is already at maximum level."
			return
		if(Choice.learned&&Choice.battle)
			var/gain = input(usr,"How much Global EXP would you like to add? You currently have [usr.gexp] available.","",null) as num
			if(!gain||gain<0)
				return
			if(gain>usr.gexp)
				usr<<"You can't add more EXP than you have available!"
				return
			if(gain>0)
				if(Choice.exp+gain<=Choice.nxtlvl)
					Choice.expgain(gain,1)
					usr.gexp-=gain
					usr<<"You add [gain] exp to [Choice.name]!"
				else
					while(gain>0&&Choice.level<Choice.maxlvl)
						var/diff = Choice.nxtlvl - Choice.exp
						if(gain>diff)
							Choice.expgain(diff,1)
							usr.gexp-=diff
							gain-=diff
						else
							Choice.expgain(gain,1)
							usr.gexp-=gain
							gain = 0
						sleep(1)
					usr<<"You add [gain] exp to [Choice.name]!"
		else
			usr<<"You cannot apply Global EXP to this skill."
		usr.updateMastery = 1
		usr.CloseMasteryChoiceWindow()//causes a infinite cross reference loop otherwise
		spawn del(src)

	verb/LockButton()
		set category = null
		set hidden = 1
		set waitfor = 0
		if(!Choice) return
		if(!Choice.learned)
			usr<<"You don't know this mastery!"
			return
		else if(Choice.learned&&Choice.locked)
			usr<<"You unlock [Choice.name], enabling EXP gain."
			Choice.locked=0
		else if(Choice.learned&&!Choice.locked)
			usr<<"You lock [Choice.name], disabling EXP gain."
			Choice.locked=1
		usr.updateMastery = 1
		usr.CloseMasteryChoiceWindow()//causes a infinite cross reference loop otherwise
		spawn del(src)

obj/mastery/dummymastery
	var
		datum/mastery/MasteryType = null
		exp = 0
		maxlvl = 0
		tier = 0
		available = 0
		learned = 0
		reqtxt = ""
	Click()
		if(!usr.checkingMastery)
			usr.checkingMastery = 1
			winshow(usr,"MasteryChoice", 1)
			usr.Mastery_Choice_Int(MasteryType)
			for(var/obj/masterychoice/B in usr.contents)
				del(B)
			var/obj/masterychoice/A = new/obj/masterychoice
			A.Choice = MasteryType
			usr.contents += A

obj/mastery/dummyicon
	icon = ""
	icon_state = ""

mob/var
	updateMastery = 0
	tmp/checkingMastery = 0