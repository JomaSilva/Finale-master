mob/proc/perfecttranscinematic()
	transing=1
	attackable=0
	move=0
	var/image/BD=image(icon='bioto3.dmi')
	BD.plane = 7
	overlayList+=BD
	emit_Sound('rockmoving.wav')
	spawn for(var/turf/T in view(src))
		if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
		else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
		else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
	spawn for(var/turf/T in view(10))
		createLightningmisc(T,3)
	sleep(50)
	spawn for(var/mob/M in player_list)
		if(M.Planet == usr.Planet)
			M.Quake()
	spawn SSj2GroundGrind()
	Quake()
	spawn Quake()
	spawn for(var/turf/T in view(10))
		createLightningmisc(T,3)
	spawn(20) createCrater(loc,3)
	move=1
	spawn for(var/turf/T in view(src)) if(prob(5))
		createCrater(T,1)
	transing=0
	attackable=1
	move=1