mob/var
	//---------------
	snamek=0
	snamekat=2000000
	snamekmult=5
	snamekdrain= 0.015

mob/proc/snamek()
	if(Race=="Namekian")
		if(snamek&&expressedBP>=snamekat)
			emit_Sound('chargeaura.wav')
			animate(src,time=7,color=rgb(255,255,255))
			color = null
			createDustshock(loc,3)
			createCrater(loc,5)
			startbuff(/obj/buff/snamek)

obj/buff/snamek
	name = "Super Namekian"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	blue_effect=1
	persistant=TRUE
obj/buff/snamek/Buff()
	lastForm=0
	..()
obj/buff/snamek/Loop()
	if(!container.transing)
		if(container.snamek==1) if(container.snamekdrain)
			if(container.stamina>=container.maxstamina*container.snamekdrain||container.dead)
				if(prob(20)) container.Ki-=container.snamekdrain*container.BaseDrain //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.snamekdrain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.snamekdrain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
			else container.Revert()
	if(lastForm!=container.snamek)
		lastForm=container.snamek
		switch(container.snamek)
			if(1)
				container.transBuff=container.snamekmult
				container.trueKiMod = 2
				container.Ki *= container.trueKiMod
				container.overlayList+='snamek Elec.dmi'
				container.overlaychanged=1
	..()
obj/buff/snamek/DeBuff()
	container.transBuff = 1
	container.Ki = container.Ki / container.trueKiMod
	container.trueKiMod = 1
	container.overlayList-='snamek Elec.dmi'
	..()