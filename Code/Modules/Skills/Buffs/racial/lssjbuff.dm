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
						to_chat(container, "You are too tired to sustain your form.")
					container.stamina -= trans_drain*max(0.001,container.restssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.

				else
					to_chat(container, "You are too tired to sustain your form.")
					container.Revert()
		//UnRestrained Super Saiyan Drain
		if(container.lssj==2)
			if(container.unrestssjdrain)
				if(container.stamina>=container.maxstamina*container.unrestssjdrain||container.dead)
					if(prob(20)) container.Ki-=(container.unrestssjdrain) //ki takes a small hit regardless.
					if(container.Ki<=container.MaxKi*container.unrestssjdrain)
						container.Revert()
						to_chat(container, "You are too tired to sustain your form.")
					container.stamina -= trans_drain*max(0.001,container.unrestssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else
					to_chat(container, "You are too tired to sustain your form.")
					container.Revert()
		//Legendary Super Saiyan Drain
		if(container.lssj==3)
			if(container.lssjdrain)
				if(container.stamina>=container.maxstamina*container.lssjdrain||container.dead)
					if(prob(20)) container.Ki+=(container.MaxKi*container.lssjdrain)
					//lssj doesn't drain like normal. It adds a small amount of Ki.
					if(container.Ki<=container.MaxKi*container.lssjdrain)
						container.Revert()
						to_chat(container, "You are too tired to sustain your form.")
					container.stamina -= trans_drain*max(0.001,container.lssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else
					to_chat(container, "You are too tired to sustain your form.")
					container.Revert()
		if(container.lssj==4) //Super Saiyan Full Power (Controlled): mesmo comportamento do Full Power (ganha Ki)
			if(container.lssjdrain)
				if(container.stamina>=container.maxstamina*container.lssjdrain||container.dead)
					if(prob(20)) container.Ki+=(container.MaxKi*container.lssjdrain)
					if(container.Ki<=container.MaxKi*container.lssjdrain)
						container.Revert()
						to_chat(container, "You are too tired to sustain your form.")
					container.stamina -= trans_drain*max(0.001,container.lssjdrain)/2
				else
					to_chat(container, "You are too tired to sustain your form.")
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
				container.updateOverlay(/obj/overlay/hairs/hair) //Wrathful mantem o cabelo BASE (sem tint azul)
				container.updateOverlay(/obj/overlay/effects/menacing_aura) //aura ameacadora no corpo (estilo raios do SSJ2)
			if(2)
				container.ssjBuff = container.lssj_form_mult()
				container.trueKiMod = container.ussjenergymod
				container.Ki *= container.trueKiMod
				container.updateOverlay(/obj/overlay/hairs/ssj/ssj1,container.ssjhair)
				container.updateOverlay(/obj/overlay/effects/menacing_aura) //C-Type: mesma aura ameacadora do Wrathful
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
				container.updateOverlay(/obj/overlay/effects/menacing_aura) //Full Power: mesma aura ameacadora do Wrathful
			if(4) //Super Saiyan Full Power (Controlled)
				container.trueKiMod = container.lssjenergymod
				container.Ki *= container.trueKiMod
				container.ssjBuff = container.lssj_form_mult()
				container.updateOverlay(/obj/overlay/hairs/ssj/lssjhair,container.ussjhair,0,100,0)
				container.updateOverlay(/obj/overlay/effects/menacing_aura) //Full Power: mesma aura ameacadora do Wrathful
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
		container.removeOverlay(/obj/overlay/effects/menacing_aura) //tira a aura ameacadora do Wrathful ao reverter
		container.overlayList-='AuraLSSjBig.dmi'
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
	wrathful_music_played = 0 //first-time gates for the Legendary transformation themes (Wrathful / C-Type / Full Power); persist across relog
	ctype_music_played = 0
	fullpower_music_played = 0
	tmp/combatTime = 0 //ticks de combate continuo (GlobalStats ~4/s); alimenta o bonus de combate +0%..+20% das formas Legendary

mob/proc/lssj_form_mult() //multiplicador EFETIVO = max(piso pela maestria, rampa de combate). O COMBATE sobe o mult do MIN ao MAX em ~3 min de luta continua; a maestria so define um PISO (100% de maestria => sempre no max).
	var/lo = 1
	var/hi = 1
	var/mstry = 0
	switch(lssj)
		if(1)
			lo = 1.5
			hi = 10
			mstry = lssj1mastery //Wrathful: 1.5x -> 10x
		if(2)
			lo = 12
			hi = 20
			mstry = lssj2mastery //Super Saiyan C-Type: 12x -> 20x
		if(3)
			lo = 25
			hi = 40
			mstry = lssj3mastery //Super Saiyan Full Power: 25x -> 40x
		if(4)
			return 50 //Super Saiyan Full Power (Controlled): 50x fixo
		else
			return 1
	var/floor_mult = lo + (hi - lo) * mstry / 100 //piso: cresce com a maestria (100% = max)
	var/combat_mult = lo + (hi - lo) * min(combatTime / 720, 1) //combate: rampa MIN->MAX em ~3 min de luta continua (720 ticks @ ~4/s)
	return max(floor_mult, combat_mult)


mob/proc/Restrained_SSj()
	if(!transing)
		if(ssj) return
		transing=1
		if(lssj1mastery >= 50) //dominou 50% do Wrathful -> transformacao instantanea (sem cinematica)
			if(!hasssj) genome.add_to_stat("Battle Power",2)
			hasssj=1
			lssj=1
			if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
			to_chat(view(6), "<font color=#76ff7a>*[src] snaps instantly into the Wrathful state.*")
			transing=0
			return
		if(!wrathful_music_played) //Wrathful (the first Legendary transformation) theme, first time only
			wrathful_music_played=1
			emit_TransformMusic(file("Sounds/Music/22. Broly Evolves   DBS Broly Original Soundtrack.mp3"), 2109) //~211s; file()+full path (runtime)
		attackable=0
		lssj_transform_buildup()
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
				updateOverlay(/obj/overlay/hairs/hair) //Wrathful mantem o cabelo BASE: sem flicker de cabelo azul
				sleep(rand(6,20))
				removeOverlay(/obj/overlay/hairs/ssj/rlssjhair)
				updateOverlay(/obj/overlay/hairs/hair)
				sleep(rand(6,20))
				removeOverlay(/obj/overlay/hairs/hair)
				updateOverlay(/obj/overlay/hairs/hair) //Wrathful mantem o cabelo BASE: sem flicker de cabelo azul
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
			overlaychanged=1
			to_chat(view(src), "<font color=#76ff7a>*The air turns cold and heavy. A crushing, murderous aura erupts from [src], splitting the ground beneath an unspeakable, mounting rage!*")
			emit_Sound('chargeaura.wav')
			spawn Quake()
			spawn Quake()
			createShockwavemisc(loc,4)
			createCrater(loc,5)
			lssj=1 //transforma + ativa o buff JA no climax (antes era so depois do sleep -> parecia que demorava)
			startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
			sleep(8)
			to_chat(view(src), "<font color=#76ff7a>*[src]'s eyes go cold and empty as a monstrous Legendary fury takes hold - the menacing aura howls like a living thing, and everything nearby seems to recoil in terror.*")
		transing=0
		attackable=1

mob/proc/Unrestrained_SSj()
	if(!transing)
		if(ssj) return
		transing=1
		if(lssj2mastery >= 50) //dominou 50% do C-Type -> transformacao instantanea
			lssj=2
			if(!hasssj2) unrestssjat/=2
			hasssj2=1
			if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
			to_chat(view(6), "<font color=#76ff7a>*[src] snaps instantly into the Super Saiyan C-Type form.*")
			transing=0
			return
		if(!ctype_music_played) //Super Saiyan C-Type theme, first time only
			ctype_music_played=1
			emit_TransformMusic(file("Sounds/Music/Dragon Ball Super - Broly's Transformation Theme (HQ Epic Cover).mp3"), 1983) //~198s; file()+full path (the apostrophe in "Broly's" can't live in a 'literal')
		attackable=0
		lssj_transform_buildup()
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
		overlaychanged=1
		to_chat(view(6), "<font color=#76ff7a>*The earth caves as [src]'s aura erupts into a vast, menacing green inferno!*")
		to_chat(view(8), "<font size=[TextSize]><[SayColor]>[src]: RRRAAAAAAAGH!!!")
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,1)
		createCrater(loc,5)
		spawn if(ssj2drain<250) Quake()
		sleep(50)
		to_chat(view(6), "<font color=#76ff7a>*Jagged green sparks crackle violently around [src]!*")
		transing=0
		attackable=1
mob/proc/LSSj()
	if(!transing)
		if(ssj) return
		transing=1
		if(lssj3mastery >= 50) //dominou 50% do Full Power -> transformacao instantanea
			lssj=3
			if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
			to_chat(view(6), "<font color=#76ff7a>*[src] snaps instantly into the Super Saiyan Full Power form.*")
			transing=0
			return
		if(!fullpower_music_played) //Super Saiyan Full Power theme, first time only
			fullpower_music_played=1
			emit_TransformMusic(file("Sounds/Music/Dragon Ball Super Broly - Rage & Sorrow Movie Version.mp3"), 1723) //~172s; file()+full path (runtime)
		attackable=0
		lssj_transform_buildup()
		//Flashy stuff
		emit_Sound('rockmoving.wav')
		for(var/turf/T in view(9,src))
			if(prob(6)) createDustmisc(T,2)
			if(prob(3)) createDustmisc(T,3)
			if(prob(2)) createLightningmisc(T,9)
			if(prob(2)) createLightningmisc(T,5)
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
		to_chat(view(6), "<font color=#76ff7a>*[src]'s hair blazes a deeper, jagged green as the power keeps surging!*")
		to_chat(view(8), "<font size=[TextSize]><[SayColor]>[src]: HRRAAAAAAAAGH!!!")
		overlaychanged=1
		to_chat(view(6), "<font color=#76ff7a>*A monstrous wave of power erupts from [src] as a vast green aura tears the ground apart!*")
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,2)
		createCrater(loc,5)
		animate(usr,time=7,color=rgb(46, 245, 72))
		usr.color = null
		Quake()
		spawn Quake()
		sleep(50)
		to_chat(view(6), "<font color=#76ff7a>*[src]'s aura roars skyward as the legendary power reaches its peak!*")
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
		to_chat(view(8), "<font color=green>*[src] reins in the wild legendary power - now perfectly controlled!*")
		sleep(8)
		lssj=4
		if(!isBuffed(/obj/buff/LSSJ)) startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
		transing=0
		attackable=1
mob/var
	haslssjboost=0

mob/proc/lssj_transform_buildup() //buildup compartilhado das transformacoes Legendary: detritos subindo lentamente + ondas de choque + grito no chat (mais detalhado e mais longo)
	to_chat(view(7), "<font color=#76ff7a>*The ground around [src] trembles violently; loose rocks tear free and drift slowly upward...*")
	for(var/i=1 to 5)
		for(var/j=1 to 2) //1-2 redemoinhos de pedra por ciclo, espalhados -> bem mais espacado
			var/turf/T = locate(x + rand(-5,5), y + rand(-5,5), z)
			if(T && !T.density) createDustmisc(T,3)
		if(prob(55)) createShockwavemisc(loc,1)
		if(prob(45)) Quake()
		sleep(rand(7,11))
	to_chat(view(8), "<font size=[TextSize]><[SayColor]>[src]: RRRAAAAAAAGH!!!")
	to_chat(view(6), "<font color=#76ff7a>*[src] lets out a furious, earth-shaking roar as the legendary power erupts!*")
	createShockwavemisc(loc,2)
	sleep(rand(8,14))
