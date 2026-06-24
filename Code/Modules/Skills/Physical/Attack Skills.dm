mob/var/tmp
	riposteon=0
	//cooldowns, they're handled in the unitimer under the movement handler.dm
	meleeCD=0//cooldown for melee attack skills, doesn't hinder normal attacks
	movementCD=0//cooldown for movement skills
	rangedCD=0//cooldown for ranged weapon attacks
	AoECD=0//cooldown for aoe melee weapon attacks
	counterCD=0//cooldown for counter-based skills
	buffCD=0//cooldown for short-term buff effects
	specialCD=0//cooldown for special skills that dont fit existing categories (sealing, etc)
	ultiCD=0//cooldown for "ultimate" skills for each set

mob/proc/target_check()
	if(!usr.target)
		usr<<"You have no target."
		return FALSE
	else
		if(get_dist(usr,target)>1)
			usr<<"You must be next to your target to use this!"
			return FALSE
	return TRUE

mob/keyable/verb/Riposte_Toggle()
	set category = "Other"
	if(usr.riposteon)
		usr<<"You will no longer attack after dodging."
		usr.riposteon=0
	else
		usr<<"You will attempt to attack after dodging."
		usr.riposteon=1

mob/keyable/combo/verb/Kickflip()
	set category = "Skills"
	set desc = "Flip off of your foe, stepping backwards and knocking them back. Movement skill."
	if(usr.movementCD)
		usr<<"Movement skills on CD for [movementCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med)
		usr<<"You can't use this now!"
		return
	var/tgtcount = 0
	for(var/mob/M in get_step(usr,usr.dir))
		tgtcount++
		var/distcalc = ((usr.Ephysoff+usr.Etechnique)/max(M.Ephysoff+M.Etechnique,0.1))*BPModulus(usr.expressedBP, M.expressedBP)
		distcalc = min(distcalc,10)
		if(distcalc>=1)
			M.kbpow=usr.expressedBP
			M.kbdur=distcalc
			M.kbdir=usr.dir
			M.AddEffect(/effect/knockback)
	if(!tgtcount)
		usr<<"You need someone in front of you to use this!"
		return
	else
		usr.canfight-=1
		var/dist=3
		var/stepdir = turn(usr.dir,180)
		while(dist>0)
			step(usr,stepdir)
			dist--
			sleep(1)
		usr.dir = turn(stepdir,180)
		usr.canfight+=1
		usr.movementCD = max(round(60/max((usr.Espeed+usr.Etechnique)/10,1),1),20)