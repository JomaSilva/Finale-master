mob/var/firstssjdone = 0 //var ticked when the first SSJ is born.

mob/proc/SSJCinematic()
	move=0
	dir=SOUTH
	BLASTICON='BlastsAscended.dmi'
	blastR=200
	blastG=200
	blastB=50
	emit_Sound('rockmoving.wav')
	spawn if(src)
		//sleep RemoveHair()
		src.removeOverlay(/obj/overlay/hairs/hair)
		src.updateOverlay(/obj/overlay/hairs/ssj/ssj1)
		sleep(rand(3,10))
		//RemoveHair()
		src.removeOverlay(/obj/overlay/hairs/ssj/ssj1)
		src.updateOverlay(/obj/overlay/hairs/hair)
		sleep(rand(3,10))
		//RemoveHair()
		src.removeOverlay(/obj/overlay/hairs/hair)
		src.updateOverlay(/obj/overlay/hairs/ssj/ssj1)
		sleep(rand(3,10))
		//RemoveHair()
		src.removeOverlay(/obj/overlay/hairs/ssj/ssj1)
		src.updateOverlay(/obj/overlay/hairs/hair)
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
			A.dir=max(kiamount,1)
			A.BP=expressedBP
			A.mods=Ekioff*Ekiskill
			A.murderToggle=usr.murderToggle
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
//
	spawn(100)
		if(!firstssjdone)
			firstssjdone = 1
			var/image/BD=image(icon='ssjrage.dmi')
			BD.plane = 7
			overlayList+=BD
			overlaychanged=1
			spawn(600)
				var/image/BD2=image(icon='ssjrage.dmi')
				overlayList-=BD2
				overlayList-=BD
				overlaychanged=1 //double check, because if BD still exists, we can use the BD reference,
				//if it doesn't we need to create a new reference. Because we're not modifying the image, we can just create this identical copy
	sleep(100)