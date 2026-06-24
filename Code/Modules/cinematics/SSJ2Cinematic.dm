mob/proc/SSJ2Cinematic()
	poweruprunning=1
	emit_Sound('rockmoving.wav')
	move=0
	dir=SOUTH
	BLASTICON='BlastsAscended.dmi'
	blastR=200
	blastG=200
	blastB=50
	spawn for(var/turf/T in view(src))
		if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
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
	spawn(130)
	overlayList-=I
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
	TransformDustGen(4)
	spawn(30)
	overlayList-='Aurabigbottom.dmi'
	overlaychanged=1
	spawn for(var/turf/T in view(src)) spawn(rand(1,50)) if(prob(1)) createCrater(T,1)