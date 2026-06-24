mob/var
	asc=0
mob/proc/Super_Saiyan_Stats()
	firsttime+=1
	genome.add_to_stat("Battle Power",0.1)

mob/proc/Quake()
	for(var/mob/M in view(src))
		if(M.client)
			M.client.Quake()

client/proc/Quake()
	set background = 1
	set waitfor = 0
	var/duration = 30
	while(duration>=1)
		duration--
		pixel_x=rand(-8,8)
		pixel_y=rand(-8,8)
		sleep(1)
	pixel_x=0
	pixel_y=0

mob/var/tmp/transing

mob/proc/TransformDustGen(var/amount)
	set waitfor=0
	while(amount)
		amount -= 1
		spawn
			var/obj/A = new(loc)
			A.icon = 'DamagedGround.dmi'
			spawn while(prob(80))
				sleep(25)
				step_rand(A)
			spawn(100) del(A)
	return


mob/proc/SSj2GroundGrind()
	for(var/turf/T in view(2,src))
		if(prob(20)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
	for(var/turf/T in view(4,src))
		if(prob(20)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
	for(var/turf/T in view(6,src))
		if(prob(20)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
	for(var/turf/T in view(8,src))
		if(prob(20)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
mob/proc/EliteGroundGrind()
	for(var/turf/T in view(2,src))
		if(prob(10)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
	for(var/turf/T in view(4,src))
		if(prob(10)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
	for(var/turf/T in view(6,src))
		if(prob(10)) sleep(1)
		var/image/I=image(icon='Dirt.dmi',dir=rand(1,8))
		I.pixel_x+=rand(-16,16)
		I.pixel_y+=rand(-16,16)
		if(prob(50)) T.overlays+=I
		spawn(600) if(I)
			T.overlays-=I
			del(I)
mob/var
	ChangieType=0
	SaiyanType=0
	SPType=0
	LSSJType=0
	AlienT=0