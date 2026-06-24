mob/var/tmp/Frozen

//should be overhauled in the ~~future.~~ NOW!

mob/keyable/verb/Freeze()
	set category = "Skills"
	if(usr.Ki <= usr.MaxKi * 0.25)
		usr << "You can't use Time Freeze!"
		return
	usr.overlayList+='TimeFreeze.dmi'
	usr.overlaychanged=1
	spawn(10) usr.overlayList-='TimeFreeze.dmi'
	usr.overlaychanged=1
	for(var/mob/A in oview(usr)) if(!A.Frozen&&A.client)
		sleep(10)
		usr.Ki*=0.5
		A.Frozen=1
		missile('TimeFreeze.dmi',usr,A)
		A.overlayList+='TimeFreeze.dmi'
		A.overlaychanged=1
		usr.emit_Sound('timestop.wav')
		spawn((20*usr.Ekiskill)/A.Ephysoff) //Time stop like here can't be really broken out of, basically a superior paralysis.
			A.Frozen=0
			A.overlayList-='TimeFreeze.dmi'
			A.overlaychanged=1

//Now for global time stop.
var/TimeStopped
//Everything stops when time is truly stopped.
var/TimeStopperBP
//Specific mobs above the BP of the time stopper and above a certain number can flex outta time.
var/TimeStopDuration
//Duration of the time stop. Further time stops increase the duration, they don't set it.

/datum/skill/general/stoptime
	skilltype = "Ki"
	name = "Time Stop"
	desc = "Cause the world to halt still. Air particles and individual raindrops frozen midair. Not even light moves. Comes with a massive drawback: it takes 1/4th of your Ki per time stop, and people above 50 billion and your own BP can circumvent time itself."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost = 3

/datum/skill/general/stoptime/after_learn()
	assignverb(/mob/keyable/verb/Stop)
	savant.CanViewFrozenTime = 1
	savant<<"Hahahahaha! The power of \[Za-Warudo\] is in my possesion..."
/datum/skill/general/stoptime/before_forget()
	unassignverb(/mob/keyable/verb/Stop)
	savant<<"N-nani!? Bakana!? I've lost Za-Warudo!?"
/datum/skill/general/stoptime/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Stop)

mob/var/TimeStopSkill = 1
mob/var/CanViewFrozenTime = 0
mob/var/timestopCD = 0

mob/keyable/verb/Stop()
	set category = "Skills"
	if(timestopCD||KO) return
	if(Ki >= MaxKi * 0.25)
		Ki -= MaxKi * 0.25
	else
		usr << "Not enough Ki."
		return
	var/durationTime = 10 * TimeStopSkill
	if(TimeStopDuration&&TimeStopped)
		view(usr)<<"<font size=(usr.TextSize+3)><font color=red>[name] says, 'ZA WARUDO!!'"
		TimeStopDuration += ((durationTime**2)/(durationTime+TimeStopDuration))
		TimeStopSkill = min(TimeStopSkill*1.1,11)
		if(TimeStopperBP<=expressedBP)
			TimeStopperBP = expressedBP
		CanMoveInFrozenTime = 1
		TrackTimeStop(durationTime)
		timestopCD = round(3000/TimeStopSkill + 10 + (round(log(TimeStopDuration)) * 2))
	else
		var/previousHP = HP
		view(usr)<<"<font size=(usr.TextSize+3)><font color=red>[name]  says, 'ZA...'"
		view(usr)<<"<font size=3><font color=red><font face=Old English Text MT>-[name] is stopping time!"
		sleep(30)
		if(!KO&&!previousHP<HP)
			view(usr)<<"<font size=(usr.TextSize+4)><font color=red>[name] says, 'WARUDO!!'"
			usr.emit_Sound('timestop.wav')
			TimeStopped = 1
			TimeStopSkill = min(TimeStopSkill*1.1,11)
			TimeStopDuration += durationTime
			TimeStopperBP = expressedBP
			timestopCD = round(3000/TimeStopSkill + 10 + (round(log(TimeStopDuration)) * 2))
			CanMoveInFrozenTime = 1
			sight &= ~BLIND    // turn off the blind bit
			TrackTimeStop(durationTime)

mob/proc/TrackTimeStop(var/Duration)
	Duration = round(Duration,1)
	while(Duration)
		sleep(1)
		Duration-=1
		if(Duration<=0)
			sleep(2)
			Duration = 0
			CanMoveInFrozenTime = 0
			if(TimeStopped||blindT)
				sight |= BLIND     // turn on the blind bit
			break

/datum/skill/general/time_teleport
	skilltype = "Ki"
	name = "Time Teleport"
	desc = "Stop time, and move to a location, To everyone else, it is instant. (Time Stop for 2 seconds. Non-trainable.)"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost = 3
	after_learn()
		assignverb(/mob/keyable/verb/Tele_Stop)
		savant.CanViewFrozenTime = 1
		savant<<"You begin to be able to move swiftly in stopped time..."
	before_forget()
		unassignverb(/mob/keyable/verb/Tele_Stop)
		savant<<"Time feels like moving through the bottom of a pool..."
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Tele_Stop)

mob/var/tmp/telestopping = 0
mob/keyable/verb/Tele_Stop()
	set category = "Skills"
	if(!telestopping)
		view(usr)<<"<font size=(usr.TextSize+3)><font color=red>[name] shifts forward a bit."
		usr<<"The next time you use Zanzoken, Time Teleport will be used instead."
		telestopping=1
	else
		view(usr)<<"<font size=(usr.TextSize+3)><font color=red>[name] relaxs a bit."
		usr<<"The next time you use Zanzoken, the regular skill will happen."
		telestopping=0
mob/proc/telestop() //triggered in click.dm during zanzoken
	if(timestopCD||KO) return
	if(Ki >= MaxKi * 0.1)
		Ki -= MaxKi * 0.1
	else
		usr << "Not enough Ki."
		return
	var/durationTime = 20
	if(!TimeStopDuration&&!TimeStopped)
		if(!KO)
			view(usr)<<"<font size=(usr.TextSize+3)><font color=red> [name] says, ' ZA...'"
			view(usr)<<"<font size=3><font color=red><font face=Old English Text MT>-[name] is stopping time!"
			sleep(10)
			view(usr)<<"<font size=(usr.TextSize+4)><font color=red>[name] says, 'WARUDO!!'"
			usr.emit_Sound('timestop.wav')
			TimeStopped = 1
			TimeStopSkill = min(TimeStopSkill*1.1,11)
			TimeStopDuration += durationTime
			TimeStopperBP = expressedBP
			timestopCD = 3000/TimeStopSkill + 10 + (round(log(TimeStopDuration)) * 2)
			CanMoveInFrozenTime = 1
			sight &= ~BLIND    // turn off the blind bit
			TrackTimeStop(durationTime)