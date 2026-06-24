/datum/skill/style/CraneStyle
	skilltype = "Body Buff"
	name = "Crane Style"
	desc = "Learn how to accurately strike and attack foes, hitting them in the most vital of areas."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=1
	enabled=0
//	var/datum/style/attachedstyle //as a reminder: include this if you're getting errors.

	after_learn()
		savant<<"You feel more complex in both body and movement."
		attachedstyle = new /datum/style/CraneStyle
		savant.styleList.Add(attachedstyle)
		savant.availableStyles += attachedstyle
		attachedstyle.savant = savant

	before_forget()
		savant<<"You feel like something neccessary was removed from your form."
		savant.styleList.Cut(attachedstyle)
		del(attachedstyle)


/datum/style/CraneStyle
	name="Crane Style"
	desc="Accurately strike and attack foes, hitting them in the most vital of areas."
	//Default stats
	defaultphysoff = 5
	defaultphysdef = 1
	defaultechnique = 2
	defaultkioff = 2
	defaultkidef = 1
	defaultkiskill = 1
	defaultspeed = 1
	defaultkiregen=1
	defaultsstaminamod = 3
	//
	learncost = 5 //what you need to pay to actually USE the style, in the form of allocated points.
	allocatedpoints = 8 //total value of all points added up minus 9

	attackTextlist = list("flat finger strikes","precise kicks","vollyball fists","narrowly pokes")
	dodgeTextlist = list("flips out of the way from","dodges to the left from","dodges to the right from","ducks down")
	counterTextlist = list("narrowly misses the oncoming strike, before ramming an attack into","skirts the attack, cracking a pointed fist into","takes the attack nearly head on")