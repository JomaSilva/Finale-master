mob/var
	legendary=0

	hasssj=0
	ssj=0
	ssjat=1500000 //1.5 million. This is the base BP req.
	ssjadd=50000000
	ssjmult=2
	ssjdrain=0.025 //1/4 of a stamina point per second. That's what this represents. It's not 0.25, we're pre-dividing it by 10 for 1 tenth of a second.
	ssjmod=1
	ultrassjenabled=0
	ultrassjat=750000000 //750mil for ultassj.
	ultrassjmult=3
	ultrassjdrain=0.050
	ultrassjspeed=1.5
	ultrassjstrength=1.5
	hasultrassj
	firsttime=0
	ssj1_music_played=0 //first-transformation theme flags; persist in saves so each plays only once ever (like ssj3firsttime)
	ssj2_music_played=0
	blue_music_played=0
	ssj4_music_played=0
	trans=0
	hastrans=0
	hastrans2=0

	hasssj2=0
	ssj2=0
	ssj2at=3.5e009//3.5billion BP for ssj2. It looks like alot, but SSJ is a 50x multiplier. You'd need a base BP of 70,000,000 to get SSJ2, which is less than DU's req actually.
	ssj2add=50000000
	ssj2mult=4
	ssj2drain=0.040
	ssj2mod=1

	ssj3firsttime=1
	ssj3able=0
	ssj3hitreq=0
	ssj3=0
	ssj3at=2e010//20 billion. (about 150 million)
	ssj3mult=16
	ssj3drain=0.075
	ssj3mod=1

	ssj4at=1.0e011//100 billion. As Golden Oozarou (SSJ x50 * x10 from Oozarou, but nerfed down to 500x) it's really only 200 mil base BP.
	rawssj4at = 200000000 //200 mil
	hasssj4
	ssj4hair = 'Hair_SSj4.dmi'
	ssj4mult=20 //SSJ4 base (escala ate ssj4maxmult conforme a maestria do SSJ4)
	ssj4maxmult=40 //SSJ4 com 100% de maestria
	ssj4fpmult=32 //SSJ4 Full Power base (estagio acima do SSJ4)
	ssj4fpmaxmult=50 //SSJ4 Full Power com 100% de maestria
	ssj4fplbmult=56 //SSJ4 Limit Breaker (God Form, multiplicador fixo)
	ssj4mastery=0 //maestria do SSJ4 (0-100); ao 100% libera o Full Power
	ssj4fpmastery=0 //maestria do SSJ4 Full Power (0-100); ao 100% libera a COMPRA do Limit Breaker
	hasSSJ4FP=0 //liberou a forma SSJ4 Full Power (ao masterizar 100% o SSJ4)

	ssjenergymod = 2 //USSJ doesn't have a energy increase, it uses SSJ's energy mod.
	//'ussjenergymod' refers therefore to unrestrained super saiyan's mod.
	ssj2energymod = 3
	ssj3energymod = 3.5
	ssj4energymod = 4.5 //energy for days in SSJ4.

	//
obj/buff/SuperSaiyan
	name = "Super Saiyan"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	blue_effect=1
	persistant=TRUE
obj/buff/SuperSaiyan/Buff()
	lastForm=0
	..()
//Dreno de Ki das formas SSJ: fracao do MaxKi consumida por ciclo do BuffLoop (~4x/seg), multiplicada pelo drain da forma (ssjdrain/ssj2drain/ssj3drain...).
//Ex.: SSJ3 nao-masterizado ssj3drain=0.075 -> 0.075*0.4 = 3% do MaxKi por ciclo do BuffLoop (~0.8x/seg) -> ~2.4%/seg, idle ~25s. Aumente TRANS_KI_DRAIN para drenar mais rapido.
#define TRANS_KI_DRAIN 0.4
obj/buff/SuperSaiyan/Loop()
	if(!container.transing)
		switch(container.ssj)
		//essentially, after you're done transforming, SSJ drains stamina straight up- it will not revert you if you're low on stamina, that'd be your job to safeguard that.
		//it will also drain a tiny amount of ki, and will revert you based on that, so if you use everything you've got, you'll drop out of SSJ.
			//Super Saiyan Drain
			if(1) if(container.ssjdrain)
				if(container.stamina>=container.maxstamina*container.ssjdrain||container.dead)
					container.Ki-=container.MaxKi*container.ssjdrain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo, escala com o drain da forma (nao-masterizada drena mais; maestria reduz ssjdrain)
					if(container.Ki<=container.MaxKi*container.ssjdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.ssjdrain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert()
			//Ultra Super Saiyan Drain
			if(1.5) if(container.ultrassjdrain)
				if(container.stamina>=container.maxstamina*container.ultrassjdrain||container.dead)
					container.Ki-=container.MaxKi*container.ultrassjdrain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo
					if(container.Ki<=container.MaxKi*container.ultrassjdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.ultrassjdrain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert()
			//Super Saiyan 2 Drain
			if(2) if(container.ssj2drain)
				if(container.stamina>=container.maxstamina*container.ssj2drain||container.dead)
					container.Ki-=container.MaxKi*container.ssj2drain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo
					if(container.Ki<=container.MaxKi*container.ssj2drain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.ssj2drain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert()
			//Super Saiyan 3 Drain
			if(3) if(container.ssj3drain)
				if(container.stamina>=container.maxstamina*container.ssj3drain||container.dead)
					container.Ki-=container.MaxKi*container.ssj3drain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo
					if(container.Ki<=container.MaxKi*container.ssj3drain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.ssj3drain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert()
			//Super Saiyan 4 Tail Check + Energy Gain
			if(4)
				if(!container.Tail)
					view(container) << "[container]'s tail was lost, reverting them from SSJ4!"
					DeBuff()
				if(prob(15)) container.Ki+=0.002 * container.MaxKi //ki gains a bit of energy.
				//there is no stamina loss from SSJ4.
				if(container.ssj4mastery < 100) //maestria do SSJ4 cresce na forma; ao 100% libera o Full Power automaticamente
					container.ssj4mastery = min(100, container.ssj4mastery + 0.0116) //~3h de uso continuo para masterizar (buff Loop ~0.8x/s)
					container.ssjBuff = container.ssj_effective_mult()
					if(container.ssj4mastery >= 100 && !container.hasSSJ4FP)
						container.hasSSJ4FP = 1
						container.testunlocks()
						container << "<font color=#ffcc33>You have completely mastered Super Saiyan 4! Super Saiyan 4 Full Power is now available - transform again to ascend.</font>"
			if(5)
				if(!container.Tail)
					view(container) << "[container]'s tail was lost, reverting them from SSJ4 Full Power!"
					DeBuff()
				if(prob(15)) container.Ki+=0.002 * container.MaxKi //SSJ4 Full Power: sem dreno de stamina
				if(container.ssj4fpmastery < 100) //maestria do Full Power; ao 100% libera a COMPRA do Limit Breaker
					container.ssj4fpmastery = min(100, container.ssj4fpmastery + 0.0099) //~3.5h de uso continuo (forma mais dificil de dominar)
					container.ssjBuff = container.ssj_effective_mult()
					if(container.ssj4fpmastery >= 100)
						container.testunlocks()
						if(!container.hasFPLB)
							container << "<font color=#ff66cc>You have completely mastered Super Saiyan 4 Full Power! You may now learn the Super Saiyan 4 Limit Breaker.</font>"
			if(6)
				if(!container.Tail)
					view(container) << "[container]'s tail was lost, reverting them from SSJ4 Limit Breaker!"
					DeBuff()
				if(prob(15)) container.Ki+=0.002 * container.MaxKi //SSJ4 Limit Breaker: sem dreno de stamina
		if(container.ssj) container.ssjBuff = container.ssj_effective_mult() //mantem o ssjBuff vivo: reflete a maestria atual + aplica o piso (forma anterior +2x)
	if(lastForm!=container.ssj)
		var/_oldTKM = container.trueKiMod //keep Ki% on EVERY form change: remember the old form's ki multiplier before it is reset
		lastForm=container.ssj
		container.RemoveHair()
		container.overlayList-='Elec.dmi'
		container.overlayList-='Electric_Blue.dmi'
		container.overlayList-='SSj4_Body.dmi'
		container.overlayList-='Electric_Yellow.dmi'
		container.removeOverlay(/obj/overlay/effects/electrictyeffects)
		container.removeOverlay(/obj/overlay/body/saiyan/saiyan4body) //limpa overlays de corpo ao trocar de forma (evita SSJ4/FPLB sobrepostos)
		container.removeOverlay(/obj/overlay/body/saiyan/saiyan5body)
		container.removeOverlay(/obj/overlay/effects/ssj4lb_sparks)
		container.removeOverlay(/obj/overlay/effects/ssj4lb_lightning)
		container.AddHair()
		container.MaxKi = container.MaxKi / container.trueKiMod
		container.trueKiMod = 1
		switch(container.ssj)
			if(1)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssjenergymod
				container.MaxKi *= container.trueKiMod
				//if(container.ssjdrain<=0.010) container.updateOverlay(/obj/overlay/hairs/ssj/ssj1fp)
				//else container.updateOverlay(/obj/overlay/hairs/ssj/ssj1)
			if(1.5)
				//if(container.ssjdrain<=0.010) container.updateOverlay(/obj/overlay/hairs/ssj/ssj1fp)
				//else container.updateOverlay(/obj/overlay/hairs/ssj/ussj)
				container.trueKiMod = container.ssjenergymod
				container.MaxKi *= container.trueKiMod
				container.ssjBuff = container.ssj_effective_mult()
				container.updateOverlay(/obj/overlay/effects/electrictyeffects/reg_elec)
			if(2)
				//container.updateOverlay(/obj/overlay/hairs/ssj/ssj2)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssj2energymod
				container.MaxKi *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects)
			if(3)
				//container.updateOverlay(/obj/overlay/hairs/ssj/ssj3)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssj3energymod
				container.MaxKi *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects)
			if(4)
				container.updateOverlay(/obj/overlay/body/saiyan/saiyan4body)
				container.ssjBuff=container.ssj_effective_mult()
				container.trueKiMod = container.ssj4energymod
				container.MaxKi *= container.trueKiMod
			if(5) //SSJ4 Full Power
				container.updateOverlay(/obj/overlay/body/saiyan/saiyan5body)
				container.ssjBuff=container.ssj_effective_mult()
				container.trueKiMod = container.ssj4energymod
				container.MaxKi *= container.trueKiMod
			if(6) //SSJ4 Limit Breaker (God Form)
				container.updateOverlay(/obj/overlay/body/saiyan/saiyan5body)
				container.updateOverlay(/obj/overlay/effects/ssj4lb_sparks) //aura constante do Limit Breaker
				container.updateOverlay(/obj/overlay/effects/ssj4lb_lightning)
				container.ssjBuff=container.ssj_effective_mult()
				container.trueKiMod = container.ssj4energymod
				container.MaxKi *= container.trueKiMod
		if(_oldTKM) //keep the SAME Ki% across the form change (up OR down) by scaling Ki with the MaxKi/trueKiMod change
			container.Ki = container.Ki * container.trueKiMod / _oldTKM
	if(container.godki && container.trans_min_val)
		if(container.godki.usage && container.trans_min_val < container.ssj)
			container.Revert()
	..()
obj/buff/SuperSaiyan/Delevel()
	if(container.ssj == 1.5) container.ssj = 1
	else container.ssj--
	if(container.ssj < 1) DeBuff()
obj/buff/SuperSaiyan/DeBuff()
	container.ssjBuff = 1
	var/_oldTKM = container.trueKiMod //keep Ki% when fully reverting to base
	container.MaxKi = container.MaxKi / container.trueKiMod
	container.trueKiMod = 1
	container.RemoveHair()
	container.overlayList-='Electric_Yellow.dmi'
	container.overlayList-='Elec.dmi'
	container.removeOverlay(/obj/overlay/body/saiyan/saiyan4body)
	container.removeOverlay(/obj/overlay/body/saiyan/saiyan5body)
	container.removeOverlay(/obj/overlay/effects/ssj4lb_sparks)
	container.removeOverlay(/obj/overlay/effects/ssj4lb_lightning)
	container.updateOverlay(/obj/overlay/hairs/hair)
	container.removeOverlay(/obj/overlay/effects/electrictyeffects)
	if(container.ssj==1.5)
		if(container.expandlevelussj>0)
			sleep(0)
			container.ExpandRevert()
	if(_oldTKM > 1) //keep the same Ki% relative to base MaxKi when dropping to base (logout scales down, relog's buff re-add scales back up -> consistent)
		container.Ki = container.Ki / _oldTKM
	if(container.Ki>container.MaxKi*2)
		container.Ki = container.MaxKi*2
	..()

mob/proc/SSj()
	if(!transing)
		Revert()
		transing=1
		if(godki && godki.usage)
			if(!blue_music_played) //SSJ1 while in God Ki = Super Saiyan Blue: Blue theme from the START (first time only)
				blue_music_played=1
				emit_Sound('Dragon Ball Z Dokkan Battle AGL LR Super Saiyan Blue Goku & Vegeta Intro OST (Extended).mp3')
		else
			if(!ssj1_music_played) //first regular Super Saiyan: SSJ1 theme from the START
				ssj1_music_played=1
				emit_Sound('Dragon Ball Z Dokkan Battle TEQ LR SSJ Goku Revival OST (Extended).mp3')
		attackable=0
		var/ssjcolor = "yellow"
		if(godki && godki.usage) ssjcolor = "blue"
		if(godki && godki.usage) view(8)<<"<font color=#33ccff>[src]: We Saiyans have no limits!</font>" //fala ao virar Blue (Super Saiyajin em modo God Ki)
		poweruprunning=1
		if(!firsttime)
			SSJCinematic()
			Super_Saiyan_Stats()
			poweruprunning=0
		if(!Apeshit)
			if(!hasssj)
				ssjat/=2
			poweruprunning=0
			hasssj=1
			emit_Sound('powerup.wav')
			spawn Quake()
			createShockwavemisc(loc,1)
			view(src)<<"<font color=[ssjcolor]>*A great wave of power emanates from [src]!*"
			spawn if(ssjdrain==0.025) Quake()
			sleep(1000*ssjdrain)
			spawn if(ssjdrain>0.01) Quake()
			emit_Sound('chargeaura.wav')
			view(src)<<"<font color=[ssjcolor]>*[src]'s hair stands on end and turns [ssjcolor]!*"
			ssj=1
			createCrater(loc,5)
			
			spawn startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
			if(!AscensionStarted)
				AscensionStarted = 1
				world << "Ascension has started."
		transing=0
		attackable=1
		poweruprunning=0
mob/proc/Ultra_SSj()
	if(!transing)
		if(ssj>=2) return
		transing=1
		attackable=0
		var/ssjcolor = "yellow"
		if(godki?.usage) ssjcolor = "blue"
		var/ussjcolor = "gold"
		if(godki?.usage) ussjcolor = "royal blue"
		if(ultrassjdrain>=0.049)
			ultrassjdrain=0.048
			UltraSSJCinematic()
		if(!hasussj)
			ultrassjat/=2
		hasussj=1
		view(src)<<"<font color=[ssjcolor]>*[src] begins to power up beyond their Super Saiyan power*"
		emit_Sound('chargeaura.wav')
		spawn Quake()
		sleep(1000*ultrassjdrain)
		spawn Quake()
		emit_Sound('aura.wav')
		view(src)<<"<font color=[ssjcolor]>*[src]'s Super Saiyan power becomes a more spikey [ussjcolor]!*"
		ssj=1.5
		createCrater(loc,3)
		if(!isBuffed(/obj/buff/SuperSaiyan))
			startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
		transing=0
		attackable=1
		spawn(100) overlayList-='SSj Aura.dmi'
mob/proc/SSj2()
	if(!transing)
		if(FutureLineage) return //Future Lineage: forma unica (SSJ1 em estagios), nao acessa SSJ2
		if(ssj>=3) return
		transing=1
		if(godki && godki.usage)
			if(!blue_music_played) //SSJ2 while in God Ki = Super Saiyan Blue: Blue theme from the START (first time only)
				blue_music_played=1
				emit_Sound('Dragon Ball Z Dokkan Battle AGL LR Super Saiyan Blue Goku & Vegeta Intro OST (Extended).mp3')
		else
			if(!ssj2_music_played) //first regular Super Saiyan 2: SSJ2 theme from the START
				ssj2_music_played=1
				emit_Sound('Dragon Ball Z   Day Of Fate Unmei No Hi (Hironobu Kageyama)   By Gladius.mp3')
		attackable=0
		var/ssjcolor = "yellow"
		if(godki?.usage) ssjcolor = "blue"
		ultrassjenabled=0
		if(ssj2drain>=0.036&&firsttime==1)
			Super_Saiyan_Stats()
			SSJ2Cinematic()
			poweruprunning=0
		if(!legendary)
			if(!hasssj2) ssj2at/=2
			hasssj2=1
			overlayList-='Elec.dmi'
			overlayList+='Elec.dmi'
			emit_Sound('powerup.wav')
			spawn Quake()
			createShockwavemisc(loc,3)
			view(6)<<"<font color=[ssjcolor]>*A great wave of power emanates from [usr] as a [ssjcolor] aura bursts around them!*"
			spawn if(ssj2drain==0.025) Quake()
			sleep(600 * ssj2drain)
			emit_Sound('chargeaura.wav')
			spawn if(ssj2drain>0.01) Quake()
			ssj=2
			createCrater(loc,5)
			if(!isBuffed(/obj/buff/SuperSaiyan))
				startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
			view(6)<<"<font color=[ssjcolor]>*Blue sparks begin to burst around [usr]!*"
		transing=0
		attackable=1
/obj/overlay/auras/transform_aura
	pixel_x = -24
	o_px = -24
	icon = 'transformaura.dmi'

mob/proc/SSj3()
	if(!transing)
		if(FutureLineage) return //Future Lineage: forma unica (SSJ1 em estagios), nao acessa SSJ3
		if(firsttime==2) Super_Saiyan_Stats()
		if(ssj>=4) return
		transing=1
		attackable=0
		poweruprunning=1
		SSJ3Cinematic()
		//---
		var/ssjcolor = "yellow"
		if(godki && godki.usage) ssjcolor = "blue"
		move=1
		overlayList-='ss3transformaurafinal.dmi'
		overlayList-='Elec.dmi'
		overlayList-='Electric_Blue.dmi'
		removeOverlay(/obj/overlay/effects/electrictyeffects)
		updateOverlay(/obj/overlay/effects/electrictyeffects)
		//prep phase over
		var/ismastered3
		for(var/datum/skill/forms/F in learned_skills) //might need to be changed-would save resources if made a variable. But again, more confusing ass variables, ugh.
			switch(F.name)
				if("Super Saiyan Three")
					if(F.level==3)
						ismastered3=1
		if(!ismastered3)
			updateOverlay(/obj/overlay/auras/transform_aura)
			sleep(100)
			if(!ssj3firsttime) view(6)<<"<font color=[ssjcolor]>*A great wave of power emanates from [usr] as a [ssjcolor] aura bursts around them!*"
			spawn for(var/mob/M in player_list)
				if(M.Planet == usr.Planet)
					M.Quake()
			sleep(100)
			if(!ssj3firsttime) view(8)<<"<font size=[TextSize]><[SayColor]>[usr]: AAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHH!!!!"
			spawn for(var/mob/M in player_list)
				if(M.Planet == usr.Planet)
					M.Quake()
			spawn Quake()
			view(8)<<"<font color=[ssjcolor]>*[usr]'s screams die down!!*"
			if(!ssj3firsttime) sleep(2000*ssj3drain)
			if(powerMod<=1) removeOverlay(/obj/overlay/auras/aura)
		createShockwavemisc(loc,4)
		emit_Sound('powerup.wav')
		spawn Quake()
		createCrater(loc,5)
		sleep(10)
		if(!isBuffed(/obj/buff/SuperSaiyan))
			startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
		ssj=3
		view(6)<<"<font color=[ssjcolor]>*[usr]'s aura spikes upward as their hair grows longer!*"
		emit_Sound('chargeaura.wav')
		if(ssj3firsttime)
			ssj3firsttime=0
		poweruprunning=0
		transing=0
		attackable=1
mob/proc/ssj4_form_mult() //multiplicador atual do tier SSJ4 conforme a forma e a maestria acumulada
	switch(ssj)
		if(4) . = ssj4mult + (ssj4maxmult - ssj4mult) * ssj4mastery / 100
		if(5) . = ssj4fpmult + (ssj4fpmaxmult - ssj4fpmult) * ssj4fpmastery / 100
		if(6) . = ssj4fplbmult
		else . = 1
	if(Class == "Legendary Primal Saiyan" && ssj == 4) . *= 1.5 //Primal lendario: SSJ4 base reforcado

mob/proc/ssj_effective_mult() //multiplicador EFETIVO do SSJ com piso: nunca cai abaixo de (forma anterior + 2x), ate a forma atual superar naturalmente
	if(FutureLineage && ssj == 1)
		return min(2 + futureSSJStage * 2, 20)
	switch(ssj)
		if(1) . = ssjmult
		if(1.5) . = ultrassjmult //USSJ: valor fixo 3x entre SSJ1 e SSJ2, SEM piso. SSJ1 masterizado (6x) supera (canon: Full Power > Ultra SSJ). So um boost de forca inicial.
		if(2) . = max(ssj2mult, ssjmult + 2)
		if(3) . = max(ssj3mult, ssj2mult + 2)
		if(4) . = max(ssj4_form_mult(), ssj3mult + 2)
		if(5) . = max(ssj4_form_mult(), ssj4maxmult + 2)
		if(6) . = max(ssj4_form_mult(), ssj4fpmaxmult + 2)
		else . = 1

mob/proc/SSj4()
	if(SaiyanLineage != "Primal Saiyan") return //SSJ4 e exclusivo da linhagem Primal Saiyan
	//if(legendary)//no more ssj4 for legendary, they've been rebalanced
	//	return actually lssj < ssj4 still, if lssj gets anger rework and doesn't die with fucktons of energy then it'd work.
	if(!transing)
		if(ssj) Revert()
		if(godki && godki.usage && godki_ssj_cap <= 3)
			godki.usage = 0
			return
		transing=1
		if(!ssj4_music_played) //primeira transformacao em SSJ4: tema do GT desde o inicio (toca so uma vez, persiste no save)
			ssj4_music_played=1
			emit_Sound('Dragon Ball GT   Super Saiyan 4 Theme (Gladius & Akihito Tokunaga)   By Gladius.mp3')
		attackable=0
		sleep(0)
		usr.Revert()
		usr.canRevert=0
		emit_Sound('powerup.wav')
		createShockwavemisc(loc,3)
		if(firsttime<=3)
			firsttime = 4
			BP+=capcheck(10000000)//your base gets stronger too. Nice.
			move=0
			dir=SOUTH
			BLASTICON='BlastsAscended.dmi'
			blastR=200
			blastG=200
			blastB=50
			for(var/turf/T in view(src))
				if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
				else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
				else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
			var/amount=32
			sleep(50)
			var/image/I=image(icon='Aurabigcombined.dmi')
			I.plane = 7
			overlayList+=I
			spawn(130) overlayList-=I
			sleep(100)
			while(amount)
				var/obj/A=new/obj
				A.loc=locate(x,y,z)
				A.icon='Electricgroundbeam2.dmi'
				if(amount==8) spawn(rand(1,100)) walk(A,NORTH,2)
				if(amount==7) spawn(rand(1,100)) walk(A,SOUTH,2)
				if(amount==6) spawn(rand(1,100)) walk(A,EAST,2)
				if(amount==5) spawn(rand(1,100)) walk(A,WEST,2)
				if(amount==4) spawn(rand(1,100)) walk(A,NORTHWEST,2)
				if(amount==3) spawn(rand(1,100)) walk(A,NORTHEAST,2)
				if(amount==2) spawn(rand(1,100)) walk(A,SOUTHWEST,2)
				if(amount==1) spawn(rand(1,100)) walk(A,SOUTHEAST,2)
				spawn(100) del(A)
				amount-=1
			move=1
		sleep(10)
		ssj=4
		hasssj4=1
		testunlocks() //reavalia desbloqueios (o Limit Breaker agora depende de masterizar 100% o Full Power)
		if(!isBuffed(/obj/buff/SuperSaiyan))
			startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
		emit_Sound('chargeaura.wav')
		ssjBuff=ssj_effective_mult()
		transing=0
		attackable=1

mob/proc/SSj4FP() //Super Saiyan 4 Full Power (estagio acima do SSJ4; liberado ao masterizar 100% o SSJ4)
	if(SaiyanLineage != "Primal Saiyan") return
	if(transing) return
	if(ssj != 4) return //precisa estar em SSJ4
	if(!hasSSJ4FP) return //precisa ter masterizado 100% o SSJ4
	if(!Tail) return
	transing=1
	attackable=0
	view(8)<<"<font color=#ffcc33 size=[TextSize]>[src]: HAAAAAAAAAAAAAAAHHHHHHHHHH!!!!"
	emit_Sound('powerup.wav')
	createShockwavemisc(loc,3)
	spawn Quake()
	animate(src,time=6,color=rgb(255,200,40))
	spawn(12) color=null
	sleep(8)
	createShockwavemisc(loc,2)
	createCrater(loc,5)
	ssj=5
	ssjBuff=ssj_effective_mult()
	emit_Sound('chargeaura.wav')
	view(6)<<"<font color=#ffcc33>*A surge of golden power explodes around [src] as they reach Full Power!*"
	transing=0
	attackable=1

mob/proc/SSj4FPLB() //Super Saiyan 4 Limit Breaker (God Form: estagio acima do Full Power, multiplicador 56)
	if(SaiyanLineage != "Primal Saiyan") return
	if(transing) return
	if(ssj != 5) return //precisa estar em SSJ4 Full Power
	if(!hasFPLB) return //precisa ter comprado a skill do Limit Breaker
	if(!Tail) return
	transing=1
	attackable=0
	view(8)<<"<font color=red size=[TextSize]>[src]: HAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHH!!!!"
	emit_Sound('powerup.wav')
	createShockwavemisc(loc,3)
	spawn Quake()
	animate(src,time=6,color=rgb(255,40,40))
	spawn(12) color=null
	sleep(8)
	createShockwavemisc(loc,2)
	createCrater(loc,5)
	ssj=6
	ssjBuff=ssj_effective_mult()
	emit_Sound('chargeaura.wav')
	view(6)<<"<font color=red>*A blinding crimson aura erupts around [src] as they shatter their limit!*"
	transing=0
	attackable=1
