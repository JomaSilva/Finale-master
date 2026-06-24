mob/var
	jirenskill = 1

//TIERED SKILLS//
//see: Modules/Multi-Stage Moves/skill.dm

/datum/skill/fullpower
	skilltype = "Ki"
	name = "Full Power"
	desc = "As a product of extreme ki mastery, a competent Gray is able to focus their power until it begins to grow exponentially.\nObtain this skill to begin that process."
	level = 0
	expbarrier = 100
	maxlevel = 2
	skillcost=2
	enabled = 0
	exp = 1
	can_forget = FALSE
	common_sense = FALSE
	compatible_races = list("Gray")
	var/kiblock=1000
	var/tmp/lastki=0
	var/tmp/diffki=0

/datum/skill/fullpower/effector()
	..()
	switch(level)
		if(0)
			if(levelup == 1)
				levelup = 0
			diffki=(savant.Ki-lastki)
			if(savant.Ki!=lastki&&diffki<0) kiblock-=(-1*diffki)
			lastki=savant.Ki
			if(kiblock<=0)
				kiblock = round(1000/exp)
				exp+=1
		if(1)
			if(levelup == 1)
				levelup = 0
				savant << "After much practice, you have mastered Full Power!"
				assignverb(/mob/keyable/verb/Full_Power)
			if(savant.isBuffed(/obj/buff/FullPower))
				if(savant.jirenskill<100)
					savant.jirenskill+=0.5
				savant.Ki-=round(100/savant.jirenskill,1)*savant.BaseDrain
				if(savant.Ki<=(savant.MaxKi/20))
					savant<<"You're too tired to concentrate your aura."
					savant.stopbuff(/obj/buff/FullPower)

datum/skill/fullpower/login(var/mob/logger)
	..()
	if(level >= 1)
		assignverb(/mob/keyable/verb/Full_Power)


/datum/skill/fullpower/after_learn()
	switch(level)
		if(0) savant << "You are on the verge of learning to focus your power. You should try burning up Ki to get a grip on this skill."
		if(1)
			assignverb(/mob/keyable/verb/Full_Power)
			savant.jirenskill = 1

/datum/skill/fullpower/before_forget()
	..()

mob/keyable/verb/Full_Power()
	set category="Skills"
	if(isBuffed(/obj/buff/FullPower)) stopbuff(/obj/buff/FullPower)
	else if(src.Ki<(MaxKi/20))
		src<<"You're too tired to concentrate your aura."
		return
	else
		usr<<"You begin intensely concentrating your aura using strange alien powers."
		animate(usr,time=7,color=rgb(233, 93, 93))
		startbuff(/obj/buff/FullPower,'Aura FullPower.dmi')
		usr.color = null
		createShockwavemisc(usr.loc,1)
		createCrater(usr.loc,5)
		return

/obj/buff/FullPower
	name = "Full Power"
	slot=sFORM
	Buff()
		..()
		container.overlayList+=icon
		container.overlaychanged=1
		container.emit_Sound('1aura.wav')
		if(AscensionStarted)
			container.transBuff=2
		container.Tphysoff+=1.2
		container.Tkioff+=1.2
		container.Tspeed+=1.2
	DeBuff()
		container<<"You relax your aura."
		container.overlayList-=icon
		container.overlayList-=icon
		container.overlaychanged=1
		container.transBuff=1
		container.Tphysoff-=1.2
		container.Tkioff-=1.2
		container.Tspeed-=1.2
		..()