/datum/skill/CustomAttacks/ki/blast/Blast
	name="Blast"
	desc="A customizable blast attack."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled = 0
	tier=2
	skillcost=1
	var/list/attachedobject = list() //list that will update with each custom beam. //ignore, replaced with contents

/obj/skill/CustomAttacks/ki/blast/Blast
	name="Blast"
	desc="A customizable blast attack."
	usecost = 1
	attacktype = 1
	firetype = 1
	attackname = "HAAAAAAAAA!"
	firesound = 'fire_kiblast.wav'
	icon = '28.dmi'
	icon_state = "28"
	var/attachedverb
	var/storedname="Blast" //verb deletion/update purposes
	var/storeddesc="A customizable blast attack."

/datum/skill/CustomAttacks/ki/blast/Blast/login(var/mob/logger)
	for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in logger.contents)
		S.Update()
	logger.verbs += /verb/Create_Blast
	logger.verbs += /verb/Remove_Blast
	..()

/datum/skill/CustomAttacks/ki/blast/Blast/logout()
	..()

mob/var/createdblastamount
mob/var/maxcreatedblastamount = 8 //maximum custom blasts is eight, why not?

/verb/Create_Blast()
	set category = "Learning"
	if(usr.createdblastamount>=usr.maxcreatedblastamount)
		usr <<"Your maximum blast count is [usr.maxcreatedblastamount]! You currently have [usr.createdblastamount]! Delete a few old blasts."
		return
	var/obj/skill/CustomAttacks/ki/blast/Blast/A = new/obj/skill/CustomAttacks/ki/blast/Blast
	A.savant = usr
	usr.contents += A
	usr.customattacks += A
	if(usr.createdblastamount)
		A.name = "Blast [usr.createdblastamount]"
		A.storedname = "Blast [usr.createdblastamount]"
	usr.createdblastamount+=1
	for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in usr.contents)
		S.Update()
	usr << "Created [A]!"

/verb/Remove_Blast()
	set category = "Learning"
	var/list/tempobjlist = list() //Code is lifted a bit from Yota (http://www.byond.com/forum/?post=164966, look at the bottom!)
	for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in usr.contents)
		tempobjlist += S
	var/tempnumb
	for(var/S in tempobjlist)
		tempnumb+=1
	var/obj/skill/CustomAttacks/ki/blast/Blast/choice = input(usr,"Which blast?")as null|anything in tempobjlist
	if(isnull(choice))
		usr <<"No blast."
	else
		choice.removeverbs()
		del(choice)
		usr.createdblastamount-=1

/datum/skill/CustomAttacks/ki/blast/Blast/after_learn()
	savant << "You feel like you can modify a blast."
	var/obj/skill/CustomAttacks/ki/blast/Blast/A = new/obj/skill/CustomAttacks/ki/blast/Blast
	A.savant = savant
	savant.contents += A
	usr.customattacks += A
	assignverb(/verb/Create_Blast)
	assignverb(/verb/Remove_Blast)
	A.Update()
	savant.createdblastamount+=1

/datum/skill/CustomAttacks/ki/blast/Blast/before_forget()
	savant << "Your blasts feels unchangable and ridged in construction."
	for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in savant.contents)
		S.removeverbs()
		savant.contents -= S
		usr.customattacks -= S
		del(S)
	savant.createdblastamount=0
	unassignverb(/verb/Create_Blast)
	unassignverb(/verb/Remove_Blast)

/obj/skill/CustomAttacks/ki/blast/Blast/Customize()
	removeverbs() //If modified, it must be removed first!!
	..()
	Update()

/obj/skill/CustomAttacks/ki/blast/Blast/proc/removeverbs()
	src.verbs -= new/obj/skill/CustomAttacks/ki/blast/Blast/proc/Blast (src, storedname, storeddesc)
	src.verbs -= attachedverb
	attachedverb = null

/obj/skill/CustomAttacks/ki/blast/Blast/Update()
	removeverbs()
	var/verb/CustomBlast = new/obj/skill/CustomAttacks/ki/blast/Blast/proc/Blast (src, name, desc)
	attachedverb = CustomBlast
	src.verbs += CustomBlast
	storedname = name
	storeddesc = desc
	..()

/obj/skill/CustomAttacks/ki/blast/Blast/proc/Blast()
	set category = "Skills"
	fire()

/obj/skill/CustomAttacks/ki/blast/Blast/fire()
	if(Homing)
		homingFire()
	else nonHomingFire()