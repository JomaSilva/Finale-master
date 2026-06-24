mob/proc/StyleWindowOpen()
	if(currentStyle)
	else return FALSE
	if(totalskillpoints<allocatedpoints)
		alert("You have more allocated points than you do skillpoints. You will be unable to edit this style until you regain what was lost.")
		return FALSE
	if(currentStyle.allocatedpoints > currentStyle.learncost)
		switch(input(usr,"There is a difference between the allocated points [currentStyle.allocatedpoints] and the actual learn cost [currentStyle.learncost]. Pay it to edit the style.")in list("Yes","No"))
			if("Yes")
				if(usr.availablepoints > currentStyle.allocatedpoints-currentStyle.learncost)
					usr.allocatedpoints += currentStyle.allocatedpoints-currentStyle.learncost
					usr.availablepoints -= currentStyle.allocatedpoints-currentStyle.learncost
					currentStyle.learncost = currentStyle.allocatedpoints
					processpoints()
				else return FALSE
			if("No")
				return FALSE
	contents += new/obj/stylewindow
	omegastun = 1 //keeps users from doing shit when they're fighting.
	winshow(usr, "stylewindow",1)
	StyleConfigRefreshDisplay()
//Style Config buttons.
mob/proc/StyleConfigChangeName()
	currentStyle.name = input("Change it's name.") as text
mob/proc/StyleConfigChangeDesc()
	currentStyle.desc = input("Change it's description.") as text
//flavor
mob/proc/StyleConfigFlavorChange(var/list/L)
	var/list/flavorlists = list()
	selectflavor
	flavorlists -= flavorlists
	flavorlists += "Add flavor"
	flavorlists += "Remove flavor"
	flavorlists += "Done"
	flavorlists += L
	switch(input("Select Item")as anything in flavorlists)
		if("Add flavor")
			L += input("Type in the flavor: When outloud, the format is '(you) (flavortext) (mob)!'.")
		if("Remove flavor")
			flavorlists -= flavorlists
			flavorlists += "Done"
			flavorlists += L
			var/choice = input("Which one to remove?")as anything in flavorlists
			if(choice!="Done")
				L-=choice
		if("Done")
			return L
	goto selectflavor
mob/proc/StyleConfigAttackFlavor()
	currentStyle.attackTextlist = StyleConfigFlavorChange(currentStyle.attackTextlist)
mob/proc/StyleConfigDodgeFlavor()
	currentStyle.dodgeTextlist = StyleConfigFlavorChange(currentStyle.dodgeTextlist)
mob/proc/StyleConfigCounterFlavor()
	currentStyle.counterTextlist = StyleConfigFlavorChange(currentStyle.counterTextlist)
//flavorend

mob/proc/StyleConfigDoneButton()
	verbs -= typesof(/obj/stylewindow/verb)
	omegastun = 0
	winshow(src, "stylewindow",0)
mob/var/tmp/clearedline
mob/proc/StyleConfigRefreshDisplay()
	if(!currentStyle)
		return FALSE
	//name and desc
	winset(usr,"stylewindow.stylename","text=\"[currentStyle.name]:[currentStyle.desc]\"")
	//stat labels
	winset(usr,"stylewindow.physofflabel","text=\"Phys Off:[currentStyle.physoff]\"")
	winset(usr,"stylewindow.physdeflabel","text=\"Phys Def:[currentStyle.physdef]\"")
	winset(usr,"stylewindow.kiofflabel","text=\"Ki Off:[currentStyle.kioff]\"")
	winset(usr,"stylewindow.kideflabel","text=\"Ki Def:[currentStyle.kidef]\"")
	winset(usr,"stylewindow.techlabel","text=\"Technique:[currentStyle.technique]\"")
	winset(usr,"stylewindow.kiskilllabel","text=\"Ki Skill:[currentStyle.kiskill]\"")
	winset(usr,"stylewindow.speedlabel","text=\"Speed:[currentStyle.speed]\"")
	winset(usr,"stylewindow.kiregenlabel","text=\"Ki Regen:[currentStyle.kiregen]\"")
	winset(usr,"stylewindow.staminalabel","text=\"Stamina:[currentStyle.staminamod]\"")
	//allocated stat labels
	winset(usr,"stylewindow.unallocatedlabel","text=\"Unallocated Skillpoints:[availablepoints]\"")
	winset(usr,"stylewindow.allocatedlabel","text=\"Allocated Skillpoints:[currentStyle.allocatedpoints]\"")
	//outputline (to show stuff like errors)
	if(winget(usr,"stylewindow.outputline","text")!=""&&!clearedline)
		clearedline = 1
		spawn(100)
			clearedline = 0
			winset(usr,"stylewindow.outputline","text=")
	spawn(10) if(omegastun&&currentStyle) StyleConfigRefreshDisplay()
mob/proc/StyleConfigResetStyle()
	currentStyle.styleReset()
//Buttons are essentially just GUI verbs. Can't directly run buttons into procs, since that is (apparently) a security risk.
obj/stylewindow/verb
	StyleNameButton()
		set hidden = 1
		usr.StyleConfigChangeName()
	StyleDescButton()
		set hidden = 1
		usr.StyleConfigChangeDesc()
	AttackFlavorButton()
		set hidden = 1
		usr.StyleConfigAttackFlavor()
	DodgeFlavorButton()
		set hidden = 1
		usr.StyleConfigDodgeFlavor()
	CounterFlavorButton()
		set hidden = 1
		usr.StyleConfigCounterFlavor()
	DoneButton()
		set hidden = 1
		usr.StyleConfigDoneButton()
		del(src)
	PickStyleButton()
		set hidden = 1
		usr.PickStyle()
	ResetButton()
		set hidden = 1
		usr.StyleConfigResetStyle()

//no other way to deal with buttons unfortunately. subtracting buttons
	Subtractphysoff()
		set hidden = 1
		usr.StyleConfigModify(-1,"physoff")
	Subtractphysdef()
		set hidden = 1
		usr.StyleConfigModify(-1,"physdef")
	Subtracttech()
		set hidden = 1
		usr.StyleConfigModify(-1,"tech")
	Subtractkioff()
		set hidden = 1
		usr.StyleConfigModify(-1,"kioff")
	Subtractkidef()
		set hidden = 1
		usr.StyleConfigModify(-1,"kidef")
	Subtractkiskill()
		set hidden = 1
		usr.StyleConfigModify(-1,"kiskill")
	Subtractspeed()
		set hidden = 1
		usr.StyleConfigModify(-1,"speed")
	Subtractkiregen()
		set hidden = 1
		usr.StyleConfigModify(-1,"kiregen")
	Subtractstamina()
		set hidden = 1
		usr.StyleConfigModify(-1,"stamina")

//adding buttons
	Addphysoff()
		set hidden = 1
		usr.StyleConfigModify(1,"physoff")
	Addphysdef()
		set hidden = 1
		usr.StyleConfigModify(1,"physdef")
	Addtech()
		set hidden = 1
		usr.StyleConfigModify(1,"tech")
	Addkioff()
		set hidden = 1
		usr.StyleConfigModify(1,"kioff")
	Addkidef()
		set hidden = 1
		usr.StyleConfigModify(1,"kidef")
	Addkiskill()
		set hidden = 1
		usr.StyleConfigModify(1,"kiskill")
	Addspeed()
		set hidden = 1
		usr.StyleConfigModify(1,"speed")
	Addkiregen()
		set hidden = 1
		usr.StyleConfigModify(1,"kiregen")
	Addstamina()
		set hidden = 1
		usr.StyleConfigModify(1,"stamina")

mob/proc
	StyleConfigThrow(var/R)
		switch(R)
			if(1)
				winset(usr,"stylewindow.outputline","text=\"Can't go below the default! (Usually 1)\"")
				return
			if(2)
				winset(usr,"stylewindow.outputline","text=\"Not enough points!\"")
				return
			if(3)
				winset(usr,"stylewindow.outputline","text=\"Check your masteries! You need masteries to increase styles!\"")
				return
	StyleConfigModify(var/points,var/statchanged)
		processpoints()
		if((totalskillpoints)<(allocatedpoints+points))//so: why not use available points? well, in quick math scenarios, available points may not be updated in time.
			StyleConfigThrow(2)
			return
		if(points > 0&&currentStyle.mastery_Percent >= (currentStyle.allocatedpoints / 2))
			currentStyle.mastery_Percent -= currentStyle.allocatedpoints / 2
		else if(points<0)
			if(currentStyle.mastery_Cap >= (currentStyle.allocatedpoints / 2)) currentStyle.mastery_Percent += currentStyle.allocatedpoints / 2
		else
			StyleConfigThrow(3)
			return
		switch(statchanged)
			if("physoff")
				if(currentStyle.physoff+(points * personalphysicalchangevalue)<(1+((currentStyle.defaultphysoff-1) * personalphysicalchangevalue)))
					StyleConfigThrow(1)
					return
			if("physdef")
				if(currentStyle.physdef+(points * personalphysicalchangevalue)<(1+((currentStyle.defaultphysdef-1) * personalphysicalchangevalue)))
					StyleConfigThrow(1)
					return
			if("tech")
				if(currentStyle.technique+(points * personalmentalchangevalue)<(1+((currentStyle.defaultechnique-1) * personalmentalchangevalue)))
					StyleConfigThrow(1)
					return
			if("kioff")
				if(currentStyle.kioff+(points * personalphysicalchangevalue)<(1+((currentStyle.defaultkioff-1) * personalphysicalchangevalue)))
					StyleConfigThrow(1)
					return
			if("kidef")
				if(currentStyle.kidef+(points * personalphysicalchangevalue)<(1+((currentStyle.defaultkidef-1) * personalphysicalchangevalue)))
					StyleConfigThrow(1)
					return
			if("kiskill")
				if(currentStyle.kiskill+(points * personalmentalchangevalue)<(1+((currentStyle.defaultkiskill-1) * personalmentalchangevalue)))
					StyleConfigThrow(1)
					return
			if("speed")
				if(currentStyle.speed+(points * personalphysicalchangevalue)<(1+((currentStyle.defaultspeed-1) * personalphysicalchangevalue)))
					StyleConfigThrow(1)
					return
			if("kiregen")
				if(currentStyle.kiregen+(points * personalabstractchangevalue)<(1+((currentStyle.defaultkiregen-1) * personalabstractchangevalue)))
					StyleConfigThrow(1)
					return
			if("stamina")
				if(currentStyle.staminamod+(points * personalabstractchangevalue)<(1+((currentStyle.defaultsstaminamod-1) * personalabstractchangevalue)))
					StyleConfigThrow(1)
					return
		switch(statchanged)
			if("physoff")
				currentStyle.physoff += (points * personalphysicalchangevalue)
				allocatedpoints += points
			if("physdef")
				currentStyle.physdef += (points * personalphysicalchangevalue)
				allocatedpoints += points
			if("tech")
				currentStyle.technique += (points * personalmentalchangevalue)
				allocatedpoints += points
			if("kioff")
				currentStyle.kioff += (points * personalphysicalchangevalue)
				allocatedpoints += points
			if("kidef")
				currentStyle.kidef += (points * personalphysicalchangevalue)
				allocatedpoints += points
			if("kiskill")
				currentStyle.kiskill += (points * personalmentalchangevalue)
				allocatedpoints += points
			if("speed")
				currentStyle.speed += (points * personalphysicalchangevalue)
				allocatedpoints += points
			if("kiregen")
				currentStyle.kiregen += (points * personalabstractchangevalue)
				allocatedpoints += points
			if("stamina")
				currentStyle.staminamod += (points * personalabstractchangevalue)
				allocatedpoints += points
		currentStyle.allocatedpoints += points
		currentStyle.learncost = currentStyle.allocatedpoints
		processpoints()