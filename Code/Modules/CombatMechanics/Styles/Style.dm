/datum/style
	//parent_type = /atom
	var
		name="Basic Style"
		desc="A basic martial style."
		mob/savant
		physoff = 1 //Physical stats should be editable- but very minutely- compared to 'mindbased' ones.
		physdef = 1
		technique = 1
		kioff = 1
		kidef = 1 //One skillpoint in here might be 0.01 of a change. x5 difference.
		kiskill = 1 //One skillpoint in here might be 0.05 of a change.
		speed = 1
		magi = 1 //Magic skill is improved VIA learning and improving preset magic styles.
		kiregen=1
		staminamod = 1 //purely visual- what the player sees, but drain/gain is calculated from this.

		editable = 1 //usually 1, but on creation the style will check your unallocated points with it's allocated points.
		//If you don't have enough unallocated points, you can't edit the style.
		//If you do, you can 'pay' for the style, paying the difference between what was it was when learned and what it is then.
		// or if you lost skillpoints, what it was when you made it, effectively 'recommitting' your skillpoints.

		//Editable shit below. All values multiply the original percents as a 'buff'.
		//Represents 'points' being put into each skil.
		defaultphysoff = 1 //Defaults are low limits. Never put these below 1, lets people have more skillpoints and generally breaks things.
		defaultphysdef = 1
		defaultechnique = 1
		defaultkioff = 1
		defaultkidef = 1
		defaultkiskill = 1
		defaultspeed = 1
		defaultkiregen=1
		defaultsstaminamod = 1

		staminadrain = 1
		staminagain = 1
		//All in all, any balance changes here needs let players reallocate if a server updates and rebalances these.
		allocatedpoints = 0
		initialpoints = 0 //when this becomes a active style, how many points did you spend for it to get there?
		learncost = 0 //allocated points to learn the skill. set in preset styles
		//
		list/attackTextlist = list()
		list/dodgeTextlist = list()
		list/counterTextlist = list()
		stanceONtext = "shifts stances!" //stance on/off text, emitted as "[usr] [text]!"
		stanceOFFtext = "shifts stances!"

		mastery_Percent = 0 //mastery percent, not changable yet.
		mastery_Cap = 5 //beginning cap, not changable yet
		mastery_buffer = 0 //how frequently this updates, not a changable stat yet, this just stores the number that counts up to 100
		
	New()
		..()
		if(learncost && !initialpoints && !allocatedpoints) initialpoints = learncost
	Del()
		styleReset()
		..()
/datum/style/Default //used when currentStyle = new/datum/style/Default is done. Ensures theres always a blank slate to switch back to.
var
	changedstyles = 0 //forever increasing value- if a mob's own value does not match this or the three below, it will trigger basically a 'talent reset'
	physicalchangevalue = 0.02
	mentalchangevalue = 0.01
	abstractchangevalue = 0.01

/datum/style/proc/UpdateStyle()
	staminadrain = staminamod
	staminagain = 1/staminamod
	physoff = max(physoff,1)
	physdef = max(physdef,1)
	technique = max(technique,1)
	kioff = max(kioff,1)
	kidef = max(kidef,1)
	kiskill = max(kiskill,1)
	speed = max(speed,1)
	kiregen=max(kiregen,1)
	staminamod = max(staminamod,1)
	//
	physoff = max(physoff,1+((defaultphysoff-1)*savant.personalphysicalchangevalue))
	physdef = max(physdef,1+((defaultphysdef-1)*savant.personalphysicalchangevalue))
	technique = max(technique,1+((defaultechnique-1)*savant.personalmentalchangevalue))
	kioff = max(kioff,1+((defaultkioff-1)*savant.personalphysicalchangevalue))
	kidef = max(kidef,1+((defaultkidef-1)*savant.personalphysicalchangevalue))
	kiskill = max(kiskill,1+((defaultkiskill-1)*savant.personalmentalchangevalue))
	speed = max(speed,1+((defaultspeed-1)*savant.personalphysicalchangevalue))
	kiregen=max(kiregen,1+((defaultkiregen-1)*savant.personalabstractchangevalue))
	staminamod = max(staminamod,1+((defaultsstaminamod-1)*savant.personalabstractchangevalue))

	allocatedpoints = max(learncost,allocatedpoints)

//admin stuff, move to new file (when we have dedicated admin command categories) please
mob/Admin3/verb/ChangedStyles()
	set category = "Admin"
	var/choice = input("Change style balance?") in list("Yes","No")
	switch(choice)
		if("Yes")
			switch(input("Which style set to change?") in list("Physical (Physoff, Kidef...)","Mental (Kiskill, Technique...)","Abstract (Magi, Kiregen, Willpower)"))
				if("Physical (Physoff, Kidef...)")
					var/temporary = input("Input new physical change value. (Default is 0.01)") as num
					if(temporary!=physicalchangevalue)
						changedstyles += 1
						physicalchangevalue = temporary
				if("Mental (Kiskill, Technique...)")
					var/temporary = input("Input new mental change value. (Default is 0.05)") as num
					if(temporary!=physicalchangevalue)
						changedstyles += 1
						mentalchangevalue = temporary
				if("Abstract (Kiregen, Stamina)")
					var/temporary = input("Input new abstract change value. (Default is 0.025)") as num
					if(temporary!=physicalchangevalue)
						changedstyles += 1
						abstractchangevalue = temporary
		if("No")
			return
//end of admin stuff

/datum/style/proc/styleReset()
	physoff = defaultphysoff
	physdef = defaultphysdef
	technique = defaultechnique
	kioff = defaultkioff
	kidef = defaultkidef
	kiskill = defaultkiskill
	speed = defaultspeed
	//magi = defaultphysoff
	kiregen=defaultkiregen
	staminamod = defaultsstaminamod
	staminadrain = staminamod
	staminagain = 1/staminamod
	allocatedpoints = initialpoints
	learncost = initialpoints
	//note: this does not delete flavortext. Yippe!
	if(savant) savant.styleReset(initialpoints)

mob/proc/styleReset(var/init) //Called whenever a style is removed
	physoffStyle = 1
	physdefStyle = 1
	techniqueStyle = 1
	kioffStyle = 1
	kidefStyle = 1
	kiskillStyle = 1
	speedStyle = 1
	magiStyle = 1
	kiregenStyle=1
	staminadrainStyle = 1
	staminagainStyle = 1
	allocatedpoints=init
	availablepoints=totalskillpoints - init
mob
	verb
		Pick_Current_Style()
			set category = "Learning"
			usr.PickStyle()
		Edit_Current_Style()
			set category = "Learning"
			usr.StyleWindowOpen()
mob/verb
	Learn_Available_Styles()
		set category = "Learning"
		usr.viewavailablestyles()
mob/proc/PickStyle()
	var/list/pickstylelist = list()
	pickstylelist += "No style."
	for(var/datum/style/S in activeStyles)
		pickstylelist += S
	var/datum/style/choice = input("Which style?")as null|anything in pickstylelist
	if(isnull(choice))
	else if(choice == "No style.")
		if(prob(1))
			view()<<"<font color=yellow size=3>HE HAS NO GRACE</font>"
			view()<<"<font color=yellow size=3>THIS KONG HAS</font>"
			view()<<"<font color=yellow size=3>A FUNNY FACE</font>"
		view()<<"[usr] [currentStyle.stanceOFFtext]!"
		currentStyle = null
	else
		currentStyle = choice
		view()<<"[usr] [currentStyle.stanceONtext]!"

mob/proc/viewavailablestyles()
	var/list/pickstylelist = list()
	for(var/datum/style/S in availableStyles)
		pickstylelist += S
	var/choice = input("Which style?")as null|anything in pickstylelist
	var/datum/style/nS = choice
	if(isnull(choice))
	else
		nS.learn()

datum/style/proc/learn()
	if(learncost < savant.availablepoints)
		switch(input("Learn? Costs [learncost] points. You have [savant.availablepoints].")in list("Yes","No"))
			if("Yes")
				savant.allocatedpoints += learncost
				allocatedpoints = learncost
				if(!src in savant.styleList)
					savant.styleList.Add(src)
				savant.activeStyles.Add(src)
				savant.availableStyles.Cut(src)
			if("No")
				return


mob
	var
		isInStyleConfig = 0
		physoffStyle = 1
		physdefStyle = 1
		techniqueStyle = 1
		kioffStyle = 1
		kidefStyle = 1
		kiskillStyle = 1
		speedStyle = 1
		magiStyle = 1
		kiregenStyle=1
		staminadrainStyle = 1 // see below
		staminagainStyle = 1 //when designing styles, these will always be a inverse relationship - more drain = more stamina gain, and the reverse.