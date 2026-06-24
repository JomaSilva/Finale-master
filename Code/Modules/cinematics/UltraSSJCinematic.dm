mob/proc/UltraSSJCinematic()
	poweruprunning=1
	move=0
	dir=SOUTH
	if(firsttime==1) Super_Saiyan_Stats()
	BLASTICON='BlastsAscended.dmi'
	emit_Sound('rockmoving.wav')
	blastR=200
	blastG=200
	blastB=50
	if(Class == "Elite")
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
			A.mods=Ekioff*Ekiskill
			spawn A.Burnout()
			spawn walk(A,A.dir,2)
			if(prob(80)&&!kiamount) kiamount=8
			kiamount-=1
	else
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
	TransformDustGen(4)
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
	poweruprunning=0