obj/ShootingStar
	density=0
	layer=MOB_LAYER+1
	icon='Shooting Star.dmi'
	New()
		..()
		spawn ShootingStar()
obj/DBVTitle
	icon='DBV.dmi'
obj/proc/ShootingStar()
	spawn(300) if(src) del(src)
	var/image/I=image(icon='Shooting Star.dmi',icon_state="tail")
	var/dirr=rand(1,4)
	if(dirr==1)
		x-=10
		y+=rand(-2,2)
		I.pixel_y-=32
		overlays+=I
		walk(src,NORTH,1)
	if(dirr==2)
		x+=10
		y+=rand(-2,2)
		I.pixel_y+=32
		overlays+=I
		walk(src,SOUTH,1)
	if(dirr==3)
		x-=10
		y+=rand(-2,2)
		I.pixel_x-=32
		overlays+=I
		walk(src,EAST,1)
	if(dirr==4)
		x+=10
		y+=rand(-2,2)
		I.pixel_x+=32
		overlays+=I
		walk(src,WEST,1)
mob/var/destroyable
mob/Bump(mob/A)
	testPlanetbump(A)
	if(isturf(A))
		var/turf/T = A
		if(T.Water)
			if(T.testWaters(src))
				return ..()
	if(istype(A,/mob)) if(Apeshit|monster|isNPC)
		if(Apeshitskill<10)
			dir = get_dir(src,A)
			spawn MeleeAttack()
		if(sim&&A.HP<=15)
			usr<<"Simulator: Simulation cancelled due to safety protocols."
			del(src)
	if(istype(A,/obj/attack))
		A.Bump(src)