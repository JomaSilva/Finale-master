obj/buff/LSSJ
	name = "Legendary Super Saiyan"
	icon='SSJIcon.dmi'
	slot=sFORM
	var/lastForm=0
	var/depandHere
	var/pastAngerMod
	blue_effect=1
	persistant=TRUE
obj/buff/LSSJ/Buff()
	container.depandicon = container.icon
	..()
obj/buff/LSSJ/Loop()
	if(!container.transing)
		//restrained Super Saiyan Drain
		if(container.lssj==1)
			if(container.restssjdrain)
				if(container.stamina>=container.maxstamina*container.restssjdrain||container.dead)
					if(prob(20)) container.Ki-=(container.restssjdrain) //ki takes a small hit regardless.
					if(container.Ki<=container.MaxKi*container.restssjdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.restssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.

				else
					container<<"You are too tired to sustain your form."
					container.Revert()
		//UnRestrained Super Saiyan Drain
		if(container.lssj==2)
			if(container.unrestssjdrain)
				if(container.stamina>=container.maxstamina*container.unrestssjdrain||container.dead)
					if(prob(20)) container.Ki-=(container.unrestssjdrain) //ki takes a small hit regardless.
					if(container.Ki<=container.MaxKi*container.unrestssjdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.unrestssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else
					container<<"You are too tired to sustain your form."
					container.Revert()
		//Legendary Super Saiyan Drain
		if(container.lssj==3)
			if(container.lssjdrain)
				if(container.stamina>=container.maxstamina*container.lssjdrain||container.dead)
					if(prob(20)) container.Ki+=(container.MaxKi*container.lssjdrain)
					//lssj doesn't drain like normal. It adds a small amount of Ki.
					if(container.Ki<=container.MaxKi*container.lssjdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.lssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else
					container<<"You are too tired to sustain your form."
					container.Revert()
		if(container.lssj==4) //Super Saiyan Full Power (Controlled): mesmo comportamento do Full Power (ganha Ki)
			if(container.lssjdrain)
				if(container.stamina>=container.maxstamina*container.lssjdrain||container.dead)
					if(prob(20)) container.Ki+=(container.MaxKi*container.lssjdrain)
					if(container.Ki<=container.MaxKi*container.lssjdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.lssjdrain)/2
				else
					container<<"You are too tired to sustain your form."
					container.Revert()
		if(container.lssj) //Form Rising: maestria cresce em forma + mantem o ssjBuff vivo (maestria + bonus de combate)
			switch(container.lssj)
				if(1) container.lssj1mastery = min(100, container.lssj1mastery + 0.0116)
				if(2) container.lssj2mastery = min(100, container.lssj2mastery + 0.0116)
				if(3) container.lssj3mastery = min(100, container.lssj3mastery + 0.0116)
			container.ssjBuff = container.lssj_form_mult()
	if(container.lssj!=lastForm)
		lastForm=container.lssj
		for(var/obj/overlay/hairs/ssj/X in container.overlayList)
			container.removeOverlay(X)
		if(pastAngerMod)
			container.angerMod = pastAngerMod
			pastAngerMod = 0
		container.RemoveHair()
		switch(container.lssj)
			if(1)
				container.ssjBuff = container.lssj_form_mult()
				container.trueKiMod = container.rssjenergymod
				container.Ki *= container.trueKiMod
				container.updateOverlay(/obj/overlay/hairs/ssj/rlssjhair,container.hair,0,0,100)
			if(2)
				container.ssjBuff = container.lssj_form_mult()
				container.trueKiMod = container.ussjenergymod
				container.Ki *= container.trueKiMod
				container.updateOverlay(/obj/overlay/hairs/ssj/ssj1,container.ssjhair)
				if(!container.canRSSJ)
					pastAngerMod = container.angerMod
					container.angerMod /= 10
				if(container.doexpandicon2)
					container.icon = container.expandicon2
				if(container.icon=='White Male.dmi'&&!container.doexpandicon2) container.icon = 'White Male Muscular 2.dmi'
			if(3)
				container.trueKiMod = container.lssjenergymod
				container.Ki *= container.trueKiMod
				if(container.doexpandicon3)
					container.icon = container.expandicon3
				if(container.icon=='White Male Muscular 2.dmi'|container.icon=='White Male.dmi'&&!container.doexpandicon3) container.icon = 'White Male Muscular 3.dmi'
				container.ssjBuff = container.lssj_form_mult()
				container.updateOverlay(/obj/overlay/hairs/ssj/lssjhair,container.ussjhair,0,100,0)
			if(4) //Super Saiyan Full Power (Controlled)
				container.trueKiMod = container.lssjenergymod
				container.Ki *= container.trueKiMod
				container.ssjBuff = container.lssj_form_mult()
				container.updateOverlay(/obj/overlay/hairs/ssj/lssjhair,container.ussjhair,0,100,0)
	if(container.godki && container.trans_min_val)
		if(container.godki.usage && container.trans_min_val < container.lssj-1)
			container.Revert()
	..()
obj/buff/LSSJ/DeBuff()
	if(container.lssj)
		lastForm=0
		container.Ki = container.Ki / container.trueKiMod
		container.trueKiMod = 1
		container.ssjBuff=1
		if(pastAngerMod) container.angerMod = pastAngerMod
		if(container.lssj==2||container.lssj==3||container.lssj==4)
			container.icon = container.depandicon
		container.overlayList-=container.ssjhair
		container.overlayList-=container.ussjhair
		for(var/obj/overlay/hairs/ssj/X in container.overlayList)
			container.removeOverlay(X)
		container.updateOverlay(/obj/overlay/hairs/hair)
		container.lssj=0
	..()
mob/var
	rssj=0
	urssj=0
	lssj=0
	restssjat=1000000
	unrestssjat=3000000
	lssjat=50000000
	restssjmult=3
	unrestssjmult=8
	lssjmult=16
	restssjmod=1
	unrestssjmod=1.5
	lssjmod=2
	restssjdrain=0.005
	unrestssjdrain=0.015
	lssjdrain=0.01
	rssjenergymod = 1.3
	ussjenergymod = 2
	lssjenergymod = 4
	lssj1mastery = 0 //Form Rising: maestria por-forma (0-100). Cada forma Legendary escala do multiplicador base ao maximo.
	lssj2mastery = 0
	lssj3mastery = 0
	tmp/combatTime = 0 //ticks de combate continuo (GlobalStats ~4/s); alimenta o bonus de combate +0%..+20% das formas Legendary

mob/proc/lssj_form_mult() //Form Rising: multiplicador EFETIVO = (base->max conforme a maestria da forma) * (1 + bonus de combate ate +20%)
	switch(lssj)
		if(1) . = 1.5 + (10 - 1.5) * lssj1mastery / 100 //Wrathful: 1.5x -> 10x
		if(2) . = 12 + (20 - 12) * lssj2mastery / 100 //Super Saiyan C-Type: 12x -> 20x
		if(3) . = 25 + (40 - 25) * lssj3mastery / 100 //Super Saiyan Full Power: 25x -> 40x
		if(4) . = 50 //Super Saiyan Full Power (Controlled): 50x fixo
		else
			return 1
	. *= 1 + min(combatTime / 720, 1) * 0.2 //bonus de combate continuo: +0% a +20% ao longo de ~180s (720 ticks @ ~4/s)


mob/proc/Restrained_SSj()
	if(!transing)
		if(ssj) return
		transing=1
		attackable=0
		if(restssjdrain>=0.015)
			move=0
			dir=SOUTH
			if(!firsttime) Super_Saiyan_Stats()
			BLASTICON='BlastsAscended.dmi'
			emit_Sound('rockmoving.wav')
			blastR=200
			blastG=200
			blastB=50
			spawn if(src)
				removeOverlay(/obj/overlay/hairs/hair)
				updateOverlay(/obj/overlay/hairs/ssj/rlssjhair,hair,0,0,100)
				sleep(rand(6,20))
				removeOverlay(/obj/overlay/hairs/ssj/rlssjhair)
				updateOverlay(/obj/overlay/hairs/hair)
				sleep(rand(6,20))
				removeOverlay(/obj/overlay/hairs/hair)
				updateOverlay(/obj/overlay/hairs/ssj/rlssjhair,hair,0,0,100)
				sleep(rand(6,20))
				removeOverlay(/obj/overlay/hairs/ssj/rlssjhair)
				updateOverlay(/obj/overlay/hairs/hair)
			for(var/turf/T in view(src))
				if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
				else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
				else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
			spawn for(var/turf/T in view(10))
				createLightningmisc(T,3)
			var/amount=8
			sleep(50)
			var/image/I=image(icon='Aurabigcombined.dmi')
			I.plane = 7
			overlayList+=I
			overlaychanged=1
			spawn(130) overlayList-=I
			overlaychanged=1
			sleep(100)
			Quake()
			spawn Quake()
			while(amount)
				var/obj/A=new/obj
				A.loc=locate(x,y,z)
				A.icon='Electricgroundbeam.dmi'
				if(amount==8) spawn walk(A,NORTH,2)
				if(amount==7) spawn walk(A,SOUTH,2)
				if(amount==6) spawn walk(A,EAST,2)
				if(amount==5) spawn walk(A,WEST,2)
				if(amount==4) spawn walk(A,NORTHWEST,2)
				if(amount==3) spawn walk(A,NORTHEAST,2)
				if(amount==2) spawn walk(A,SOUTHWEST,2)
				if(amount==1) spawn walk(A,SOUTHEAST,2)
				spawn(50) del(A)
				amount-=1
			spawn for(var/turf/T in view(10))
				createLightningmisc(T,3)
			spawn(20) createCrater(loc,3)
			spawn for(var/turf/T in view(src)) if(prob(5)) createCrater(T,1)
			move=1
		if(!Apeshit)
			move=1
			if(!hasssj)
				genome.add_to_stat("Battle Power",2)
			hasssj=1
			overlayList-='SSj Aura.dmi'
			overlayList+='SSj Aura.dmi'
			overlaychanged=1
			view(src)<<"<font color=yellow>*A great wave of power emanates from [src] as a yellow aura bursts around them!*"
			emit_Sound('chargeaura.wav')
			spawn Quake()
			spawn Quake()
			createShockwavemisc(loc,4)
			createCrater(loc,5)
			sleep(50)
			view(src)<<"<font color=yellow>*[src]'s hair becomes more ridged and turns blue!*"
			lssj=1
			startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
		transing=0
		attackable=1

mob/proc/Unrestrained_SSj()
	if(!transing)
		if(ssj) return
		transing=1
		attackable=0
		if(unrestssjdrain>=0.025)
			move=0
			dir=SOUTH
			if(firsttime==1) Super_Saiyan_Stats()
			BLASTICON='BlastsAscended.dmi'
			emit_Sound('rockmoving.wav')
			blastR=200
			blastG=200
			blastB=50
			for(var/turf/T in view(src))
				if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
				else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
				else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
			spawn(rand(40,60)) for(var/turf/T in view(10))
				var/image/W=image(icon='Lightning flash.dmi',layer=MOB_LAYER+1)
				T.overlays+=W
				spawn(2) T.overlays-=W
			var/amount=16
			sleep(50)
			var/image/I=image(icon='Aurabigcombined.dmi')
			I.plane = 7
			overlayList+=I
			overlaychanged=1
			spawn(130) overlayList-=I
			overlaychanged=1
			sleep(100)
			Quake()
			Quake()
			Quake()
			spawn Quake()
			spawn SSj2GroundGrind()
			while(amount)
				var/obj/A=new/obj
				A.loc=locate(x,y,z)
				A.icon='Electricgroundbeam2.dmi'
				if(amount==8) spawn(rand(1,50)) walk(A,NORTH,2)
				if(amount==7) spawn(rand(1,50)) walk(A,SOUTH,2)
				if(amount==6) spawn(rand(1,50)) walk(A,EAST,2)
				if(amount==5) spawn(rand(1,50)) walk(A,WEST,2)
				if(amount==4) spawn(rand(1,50)) walk(A,NORTHWEST,2)
				if(amount==3) spawn(rand(1,50)) walk(A,NORTHEAST,2)
				if(amount==2) spawn(rand(1,50)) walk(A,SOUTHWEST,2)
				if(amount==1) spawn(rand(1,50)) walk(A,SOUTHEAST,2)
				spawn(50) del(A)
				amount-=1
			spawn(20) createCrater(loc,3)
			move=1
			spawn for(var/turf/T in view(src)) spawn(rand(1,50)) if(prob(1)) createCrater(T,3)
		sleep(0)
		lssj=2
		if(!hasssj2)
			unrestssjat/=2
		hasssj2=1
		if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
		overlayList-='Elec.dmi'
		overlayList+='Elec.dmi'
		overlaychanged=1
		var/ssjcolor = "yellow"
		if(godki && godki.usage) ssjcolor = "blue"
		view(6)<<"<font color=[ssjcolor]>*A great wave of power emanates from [src] as a [ssjcolor] aura bursts around them!*"
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,1)
		createCrater(loc,5)
		spawn if(ssj2drain<250) Quake()
		sleep(50)
		view(6)<<"<font color=[ssjcolor]>*Blue sparks begin to burst around [src]!*"
		transing=0
		attackable=1
mob/proc/LSSj()
	if(!transing)
		if(ssj) return
		transing=1
		attackable=0
		//Flashy stuff
		emit_Sound('rockmoving.wav')
		for(var/turf/T in view(24,src))
			if(prob(20)) createDustmisc(T,2)
			if(prob(1)) createDustmisc(T,3)
			if(prob(1)) createLightningmisc(T,9)
			if(prob(1)) createLightningmisc(T,5)
		var/image/I=image(icon='Aurabigcombined.dmi')
		I.plane = 7
		overlayList+=I
		overlaychanged=1
		spawn(50) overlayList-=I
		overlaychanged=1
		//---
		sleep(0)
		lssj=3
		if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
		var/ssjcolor = "yellow"
		if(godki && godki.usage) ssjcolor = "blue"
		view(6)<<"<font color=[ssjcolor]>*[src]'s hair spikes even further and turns green!*"
		overlayList-='Elec.dmi'
		overlayList-='Electric_Blue.dmi'
		overlayList+='Electric_Blue.dmi'
		overlaychanged=1
		view(6)<<"<font color=[ssjcolor]>*A great wave of power emanates from [src] as a green aura bursts around them!*"
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,2)
		createCrater(loc,5)
		animate(usr,time=7,color=rgb(46, 245, 72))
		usr.color = null
		Quake()
		spawn Quake()
		sleep(50)
		view(6)<<"<font color=[ssjcolor]>*[src]'s aura spikes upward as their power becomes maximum!*"
		transing=0
		attackable=1
mob/proc/LSSj_Controlled() //Super Saiyan Full Power (Controlled): 50x; so apos masterizar 100% o Full Power (lssj=3)
	if(!transing)
		if(lssj!=3) return //precisa estar em Super Saiyan Full Power
		if(lssj3mastery < 100) return //precisa ter masterizado 100% o Full Power
		transing=1
		attackable=0
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,2)
		spawn Quake()
		view(8)<<"<font color=green>*[src] reins in the wild legendary power - now perfectly controlled!*"
		sleep(8)
		lssj=4
		if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
		transing=0
		attackable=1
mob/var
	haslssjboost=0