obj/buff/SuperPerfect
	name = "Super Perfect"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	blue_effect=1
	persistant=TRUE
obj/buff/SuperPerfect/Buff()
	lastForm=0
	..()
obj/buff/SuperPerfect/Loop()
	if(!container.transing)
		if(container.ssj==1) if(container.cell4drain)
			if(container.stamina>=container.maxstamina-container.cell4drain||container.dead)
				if(prob(20)) container.Ki-=(container.MaxKi*container.cell4drain) //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.cell4drain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.cell4drain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
	if(lastForm!=container.ssj)
		lastForm=container.ssj
		sleep container.RemoveHair()
		switch(container.ssj)
			if(1)
				container.originalicon = container.icon
				container.ssjBuff=container.cell4mult
				container.trueKiMod = container.ssjenergymod
				container.Ki *= container.trueKiMod
				container.icon=container.form4icon
				container.updateOverlay(/obj/overlay/hairs/SuperPerfect/sp1)
				container.updateOverlay(/obj/overlay/effects/electrictyeffects/spc)
	..()
obj/buff/SuperPerfect/DeBuff()
	container.ssjBuff = 1
	container.Ki = container.Ki / container.trueKiMod
	container.trueKiMod = 1
	sleep container.RemoveHair()
	container.icon=container.originalicon
	container.removeOverlay(/obj/overlay/hairs/SuperPerfect/sp1)
	container.removeOverlay(/obj/overlay/effects/electrictyeffects/spc)
	if(container.hair) container.updateOverlay(/obj/overlay/hairs/hair)
	if(container.Ki>container.MaxKi*2)
		container.Ki = container.MaxKi*2
	..()

mob/var
	//----------------
	cell2at=400000000 //400 million. Should be able to do form 3 to 4 after this pretty soon basically.
	cell2=0
	cell2mult=2

	cell3at=750000000 //750 million.
	cell3=0
	cell3mult=4

	cell4=0
	cell4at=3e+009
	cell4mult=8 //this is the only temp form, others are perm.
	cell4drain=0.010

	was3 //for biodroids
	form3cantrevert //for biodroids
//-----------------------------------------------------------------------

obj/overlay/hairs/SuperPerfect/sp1
	name = "super perfect hair"
	EffectStart()
		icon = container.truehair
		..()
obj/overlay/effects/electrictyeffects/spc
	icon = 'snamek Elec.dmi'
mob/proc/Cell4()
	if(!ssj&&cell3==1&&(expressedBP>=cell4at||hastrans)&&form3cantrevert)
		ssj=1
		hastrans=1
		emit_Sound('chargeaura.wav')
		startbuff(/obj/buff/SuperPerfect)
		animate(src,time=7,color=rgb(243, 240, 46))
		color = null
		createShockwavemisc(loc,1)
		createCrater(loc,5)