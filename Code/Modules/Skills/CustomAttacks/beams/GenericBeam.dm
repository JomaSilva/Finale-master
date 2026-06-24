/datum/skill/CustomAttacks/ki/beam/Beam
	name="Beam"
	desc="A customizable beam attack."
	prereqs = list(new/datum/skill/ki/Ki_Wave)
	can_forget = TRUE
	common_sense = TRUE
	teacher = TRUE
	enabled = 0
	skillcost=1
	var/list/attachedobject = list() //list that will update with each custom beam. //ignore, replaced with contents

/obj/skill/CustomAttacks/ki/beam/Beam
	name="Beam"
	desc="A customizable beam attack."
	usecost = 1
	attacktype = 1
	firetype = 1
	attackname = "HAAAAAAAAA!"
	firesound = 'basicbeam_fire.wav'
	ChargeSound = 'basicbeam_chargeoriginal.wav'
	icon = 'Beam3.dmi'
	var/attachedverb
	var/storedname="Beam" //verb deletion/update purposes
	var/storeddesc="A customizable beam attack."

/datum/skill/CustomAttacks/ki/beam/Beam/login(var/mob/logger)
	for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in logger.contents)
		S.Update()
	logger.verbs += /verb/Create_Beam
	logger.verbs += /verb/Remove_Beam
	..()

/datum/skill/CustomAttacks/ki/beam/Beam/logout()
	..()

/datum/skill/CustomAttacks/ki/beam/Beam/afterTeach(var/mob/Source)
	Source:teachBeam(savant)
	return

mob/proc/teachBeam(var/mob/Tm)
	if(Tm.createdbeamamount>=Tm.maxcreatedbeamamount)
		Tm <<"Your maximum beam count is [Tm.maxcreatedbeamamount]! You currently have [Tm.createdbeamamount]! Delete a few old beams."
		return
	var/list/tempobjlist = list() //Code is lifted a bit from Yota (http://www.byond.com/forum/?post=164966, look at the bottom!)
	for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in src.contents)
		tempobjlist += S
	var/tempnumb
	for(var/S in tempobjlist)
		tempnumb+=1
	var/obj/skill/CustomAttacks/ki/beam/Beam/choice = input(src,"You can directly teach custom attacks. Teach which beam?")as null|anything in tempobjlist
	if(isnull(choice))
		src <<"No beam."
		Tm <<"[src] didn't give you any preset beams."
		return
	else 
		var/obj/skill/CustomAttacks/ki/beam/Beam/A = new/obj/skill/CustomAttacks/ki/beam/Beam
		A = choice
		A.savant = Tm
		Tm.contents += A
		Tm.customattacks += A
		Tm.createdbeamamount+=1
		for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in Tm.contents)
			S.Update()
		Tm << "Created [A]!"

mob/var/createdbeamamount
mob/var/maxcreatedbeamamount = 8 //maximum custom beams is eight, why not?

/verb/Create_Beam()
	set category = "Learning"
	if(usr.createdbeamamount>=usr.maxcreatedbeamamount)
		usr <<"Your maximum beam count is [usr.maxcreatedbeamamount]! You currently have [usr.createdbeamamount]! Delete a few old beams."
		return
	var/obj/skill/CustomAttacks/ki/beam/Beam/A = new/obj/skill/CustomAttacks/ki/beam/Beam
	A.savant = usr
	usr.contents += A
	usr.customattacks += A
	if(usr.createdbeamamount)
		A.name = "Beam [usr.createdbeamamount]"
		A.storedname = "Beam [usr.createdbeamamount]"
	usr.createdbeamamount+=1
	for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in usr.contents)
		S.Update()
	usr << "Created [A]!"

/verb/Remove_Beam()
	set category = "Learning"
	var/list/tempobjlist = list() //Code is lifted a bit from Yota (http://www.byond.com/forum/?post=164966, look at the bottom!)
	for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in usr.contents)
		tempobjlist += S
	var/tempnumb
	for(var/S in tempobjlist)
		tempnumb+=1
	var/obj/skill/CustomAttacks/ki/beam/Beam/choice = input(usr,"Which beam?")as null|anything in tempobjlist
	if(isnull(choice))
		usr <<"No beam."
	else
		choice.removeverbs()
		del(choice)
		usr.createdbeamamount-=1

/datum/skill/CustomAttacks/ki/beam/Beam/after_learn()
	savant << "You feel like you can modify a beam."
	var/obj/skill/CustomAttacks/ki/beam/Beam/A = new/obj/skill/CustomAttacks/ki/beam/Beam
	A.savant = savant
	savant.contents += A
	savant.customattacks += A
	assignverb(/verb/Create_Beam)
	assignverb(/verb/Remove_Beam)
	A.Update()
	savant.createdbeamamount+=1

/datum/skill/CustomAttacks/ki/beam/Beam/before_forget()
	savant << "Your beam feels unchangable and ridged in construction."
	for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in savant.contents)
		S.removeverbs()
		savant.contents -= S
		savant.customattacks -= S
		del(S)
	savant.createdbeamamount=0
	unassignverb(/verb/Create_Beam)
	unassignverb(/verb/Remove_Beam)

/obj/skill/CustomAttacks/ki/beam/Beam/Customize()
	removeverbs() //If modified, it must be removed first!!
	..()
	Update()

/obj/skill/CustomAttacks/ki/beam/Beam/proc/removeverbs()
	src.verbs -= new/obj/skill/CustomAttacks/ki/beam/Beam/proc/Beam (src, storedname, storeddesc)
	src.verbs -= attachedverb
	attachedverb = null

/obj/skill/CustomAttacks/ki/beam/Beam/Update()
	removeverbs()
	var/verb/CustomBeam = new/obj/skill/CustomAttacks/ki/beam/Beam/proc/Beam (src, name, desc)
	attachedverb = CustomBeam
	src.verbs += CustomBeam
	storedname = name
	storeddesc = desc
	..()

/obj/skill/CustomAttacks/ki/beam/Beam/proc/Beam()
	set category = "Skills"
	centerSelf()
	fire()