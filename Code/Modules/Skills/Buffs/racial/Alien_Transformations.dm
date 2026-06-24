mob/var
	ayyform2at = 20000000
	ayyform1at = 1000000
	ayyform1mult = 2
	ayyform2mult = 4
	hasayyform=0
	ayyform1drain = 0.010
	ayyform2drain = 0.015

mob/proc/Alien_Trans()
	if(hasayyform)
		if(ssj==1&&expressedBP>=ayyform2at&&hasayyform==2)
			ssj=2
			emit_Sound('chargeaura.wav')
			createShockwavemisc(loc,2)
			createCrater(loc,5)
		if(!ssj&&expressedBP>=ayyform1at)
			ssj=1
			createShockwavemisc(loc,1)
			createCrater(loc,5)
			startbuff(/obj/buff/Alien_Trans)
			emit_Sound('chargeaura.wav')


obj/buff/Alien_Trans
	name = "Alien Transformation"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	blue_effect=1
	persistant=TRUE
obj/buff/Alien_Trans/Buff()
	lastForm=0
	..()
obj/buff/Alien_Trans/Loop()
	if(!container.transing)
		if(container.ssj==1) if(container.ayyform1drain)
			if(container.stamina>=container.maxstamina-container.ayyform1drain||container.dead)
				if(prob(20)) container.Ki-=(container.MaxKi*container.ayyform1drain) //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.ayyform1drain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.ayyform1drain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
		if(container.ssj==2) if(container.ayyform2drain)
			if(container.stamina>=container.maxstamina-container.ayyform2drain)
				if(prob(20)) container.Ki-=(container.MaxKi*container.ayyform2drain||container.dead) //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.ayyform2drain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.ayyform2drain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
	if(lastForm!=container.ssj)
		lastForm=container.ssj
		switch(container.ssj)
			if(1)
				container.transBuff=container.ayyform1mult
				container.trueKiMod = container.ssjenergymod
				container.Ki *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects/spc)
			if(2)
				container.transBuff=container.ayyform2mult
				container.trueKiMod = container.ssjenergymod
				container.Ki *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects/spc)
	if(container.godki && container.trans_min_val)
		if(container.godki.usage && container.trans_min_val < container.ssj)
			container.Revert()
	..()
obj/buff/Alien_Trans/DeBuff()
	container.transBuff = 1
	container.Ki = container.Ki / container.trueKiMod
	container.removeOverlay(/obj/overlay/effects/electrictyeffects/spc)
	container.trueKiMod = 1
	if(container.Ki>container.MaxKi*2)
		container.Ki = container.MaxKi*2
	..()