obj/buff/MaxPower
	name = "Max Power"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	blue_effect=1
	persistant=TRUE
obj/buff/MaxPower/Buff()
	lastForm=0
	..()
obj/buff/MaxPower/Loop()
	if(!container.transing)
		//essentially, after you're done transforming, SSJ drains stamina straight up- it will not revert you if you're low on stamina, that'd be your job to safeguard that.
		//it will also drain a tiny amount of ki, and will revert you based on that, so if you use everything you've got, you'll drop out of SSJ.
		//Super Saiyan Drain
		if(container.ssj==1) if(container.ssjdrain)
			if(container.stamina>=container.maxstamina-container.ssjdrain||container.dead)
				if(prob(20)) container.Ki-=(container.MaxKi*container.ssjdrain) //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.ssjdrain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.ssjdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
		//Super Saiyan 2 Drain
		if(container.ssj==2) if(container.ssj2drain)
			if(container.stamina>=container.maxstamina-container.ssj2drain||container.dead)
				if(prob(20)) container.Ki-=(container.MaxKi*container.ssj2drain) //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.ssj2drain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.ssj2drain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
	if(lastForm!=container.ssj)
		lastForm=container.ssj
		sleep container.RemoveHair()
		switch(container.ssj)
			if(1)
				container.ssjBuff=container.ssjmult
				container.trueKiMod = container.ssjenergymod //herans share the saiyans energy boost.
				container.Ki *= container.trueKiMod
				container.updateOverlay(/obj/overlay/hairs/superheran/sh1)
			if(2)
				container.updateOverlay(/obj/overlay/hairs/superheran/sh2)
				container.ssjBuff=container.ssj2mult
				container.trueKiMod = container.ssj2energymod
				container.Ki *= container.trueKiMod
	if(container.godki && container.trans_min_val)
		if(container.godki.usage && container.trans_min_val < container.ssj)
			container.Revert()
	..()
obj/buff/MaxPower/DeBuff()
	container.ssjBuff = 1
	container.Ki = container.Ki / container.trueKiMod
	container.trueKiMod = 1
	sleep container.RemoveHair()
	container.removeOverlay(/obj/overlay/hairs/superheran/sh1)
	container.removeOverlay(/obj/overlay/hairs/superheran/sh2)
	container.updateOverlay(/obj/overlay/hairs/hair)
	if(container.Ki>container.MaxKi*2)
		container.Ki = container.MaxKi*2
	..()

obj/overlay/hairs/superheran
	
	gdki_me()
		icon -= rgb(100,100,100)
		icon += rgb(17, 202, 57)
		icon += rgb(17, 202, 57)
	ungdki_me()
		EffectStart()
	
	sh1
		name = "super heran hair"

		EffectStart()
			icon = container.truehair
			..()
	
	sh2
		name = "super heran 2 hair"
		EffectStart()
			icon = container.truehair
			..()

mob/proc/Max_Power()
	if(!transing)
		transing=1
		attackable=0
		if(ssjdrain>=0.025)
			move=0
			dir=SOUTH
			if(!firsttime) Super_Saiyan_Stats()
			BLASTICON='BlastsAscended.dmi'
			blastR=200
			blastG=200
			blastB=50
			spawn if(src)
				removeOverlay(/obj/overlay/hairs/hair)
				updateOverlay(/obj/overlay/hairs/superheran/sh1)
				sleep(rand(3,10))
				updateOverlay(/obj/overlay/hairs/hair)
				removeOverlay(/obj/overlay/hairs/superheran/sh1)
				sleep(rand(3,10))
				removeOverlay(/obj/overlay/hairs/hair)
				updateOverlay(/obj/overlay/hairs/superheran/sh1)
				sleep(rand(3,10))
				updateOverlay(/obj/overlay/hairs/hair)
				removeOverlay(/obj/overlay/hairs/superheran/sh1)
				for(var/turf/T in view(src))
					if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
					else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,5)
					else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
				spawn EliteGroundGrind()
				var/kiamount=8
				while(kiamount)
					sleep(1)
					var/obj/attack/A=new/obj/attack/blast
					A.icon='36.dmi'
					A.icon_state="36"
					A.icon+=rgb(50,200,200)
					A.loc=locate(x,y,z)
					A.dir=kiamount
					A.BP=expressedBP
					spawn A.Burnout()
					spawn walk(A,A.dir,2)
					if(prob(80)&&!kiamount) kiamount=8
					kiamount-=1
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
			move=1
			spawn for(var/turf/T in view(src)) if(prob(5))
				createCrater(T,1)
		trans=1
		if(!hastrans)
			hastrans=1
			ssjat *= 0.5
		hasssj=1
		overlaychanged=1
		view(src)<<"<font color=green>*A great wave of power emanates from [src] as they unleash their full power!*"
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,1)
		createCrater(loc,5)
		Quake()
		spawn Quake()
		sleep(2000*ssjdrain)
		view(src)<<"<font color=green>*[src]'s hair stands on end and grows!*"
		updateOverlay(/obj/overlay/hairs/superheran/sh1)
		ssj=1
		startbuff(/obj/buff/MaxPower,'SSJIcon.dmi')
		ssjBuff=ssjmult
		transing=0
		attackable=1
mob/proc/True_Max_Power()
	if(!transing)
		transing=1
		attackable=0
		if(ssj2drain>=0.025)
			move=0
			dir=SOUTH
			if(firsttime==1) Super_Saiyan_Stats()
			BLASTICON='BlastsAscended.dmi'
			blastR=200
			blastG=200
			blastB=50
			for(var/turf/T in view(src))
				if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,6)
				else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
				else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
			spawn(rand(40,60)) for(var/turf/T in view(10))
				createLightningmisc(T,3)
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
		spawn for(var/turf/T in view(src)) spawn(rand(1,50)) if(prob(1)) createCrater(T,3)
		hasssj=2
		trans=2
		if(!hastrans2)
			hastrans2=1
			ssj2at*=0.5
		overlayList-='Electric_Red.dmi'
		overlayList+='Electric_Red.dmi'
		overlaychanged=1
		view(6)<<"<font color=green>*A great wave of power emanates from [src] as they unleash their true power!!!*"
		emit_Sound('chargeaura.wav')
		createShockwavemisc(loc,1)
		createCrater(loc,5)
		spawn Quake()
		sleep(2000*ssj2drain)
		view(6)<<"<font color=green>*Red sparks begin to burst around [src]!*"
		ssj=2
		updateOverlay(/obj/overlay/hairs/superheran/sh2)
		ssjBuff=ssj2mult
		transing=0
		attackable=1