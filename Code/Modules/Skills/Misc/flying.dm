
/datum/skill/flying
	skilltype = "Ki"
	name = "Flight"
	desc = "The user learns to propel themself into the air with a controlled flow of Ki."
	level = 0
	expbarrier = 50
	maxlevel = 3
	can_forget = TRUE
	common_sense = TRUE
	teacher = TRUE
	tier = 2
	skillcost = 0
	var/tmp/lastdir = 0

/datum/skill/flying/effector()
	..()
	switch(level)
		if(0)
			if(levelup == 1)
				levelup = 0
			if(savant.dir != lastdir) exp += 1
			lastdir = savant.dir
		if(1)
			if(levelup == 1)
				savant << "You feel like you could fly if you tried hard enough. It seems like it'll be hard to do, at first."
				levelup = 0
				assignverb(/mob/keyable/verb/Fly)
			if(savant.flight == TRUE)
				exp += 0.01
				if(savant.flightability < 50) savant.flightability += 0.1
		if(2)
			if(levelup == 1)
				savant << "You feel ready to fly at greater speeds, though it may be taxing on your Ki... Seems like you wont get any more out of training normal flight."
				assignverb(/mob/keyable/verb/Superflight)
				levelup = 0
			if(savant.flight == TRUE && savant.flightspeed == TRUE && savant.flightability < 100) savant.flightability += 0.1
			if(savant.flight&&savant.flightspeed&&savant.flightability>=100)
				exp+=0.01
		if(3)
			if(levelup == 1)
				savant<<"You feel as though you can fly with enough speed to leave the planet!"
				assignverb(/mob/keyable/verb/Space_Flight)
				levelup = 0


/datum/skill/flying/login(var/mob/logger)
	..()
	if(level >= 1)
		assignverb(/mob/keyable/verb/Fly)
	if(level >= 2)
		assignverb(/mob/keyable/verb/Superflight)
	if(level >= 3)
		assignverb(/mob/keyable/verb/Space_Flight)

/datum/skill/flying/before_forget()
	if(level>0)
		unassignverb(/mob/keyable/verb/Fly)
		unassignverb(/mob/keyable/verb/Superflight)
		savant.flightability = 1
		if(level >= 3)
			unassignverb(/mob/keyable/verb/Space_Flight)
		savant << "You can't seem to remember how to fly."
/datum/skill/flying/after_learn()
	switch(level)
		if(0) savant << "Your Ki makes your steps feel light."
		if(1)
			assignverb(/mob/keyable/verb/Fly)
			savant.flightability = 25
		if(2)
			assignverb(/mob/keyable/verb/Fly)
			assignverb(/mob/keyable/verb/Superflight)
			savant.flightability = 75

mob/keyable/verb
	Fly()
		set category="Skills"
		var/kiReq = (80/(usr.flightability)+((450*usr.flightspeed)/(usr.flightability)))
		if(kiReq < 1) kiReq = 0
		if(usr.flight)
			stop_flying()
			usr<<"You land back on the ground."
			usr.emit_Sound('buku_land.wav')
		else if(usr.Ki>=kiReq&&!usr.KO)
			start_flying()
			usr<<"You start to hover."
			usr.emit_Sound('buku.wav')
		else usr<<"You are too tired to fly."
mob/keyable/verb
	Superflight()
		set category="Skills"
		if(!usr.flightspeed)
			start_superflight()
			usr<<"Flight speed set to fast."
		else
			stop_superflight()
			usr<<"Flight speed set to normal."

mob/proc/start_flying()
	Deoccupy()
	if(flightspeed) overlayList+=FLIGHTAURA
	overlaychanged=1
	flight=1
	swim=0
	isflying=1
	if(Savable) icon_state="Flight"

mob/proc/stop_flying()
	flight=0
	if(Savable) icon_state=""
	isflying=0
	overlayList-=FLIGHTAURA
	overlaychanged=1

mob/proc/start_superflight()
	flightspeed=1
	if(flight)
		overlayList-=FLIGHTAURA
		overlayList+=FLIGHTAURA
		overlaychanged=1

mob/proc/stop_superflight()
	flightspeed=0
	overlayList-=FLIGHTAURA
	overlaychanged=1