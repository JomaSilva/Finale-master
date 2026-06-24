/obj/attack/proc
	explode()
		spawn spawnExplosion(loc,null,BP,max(1,round(log(8,BP)/2)))
		if(mega)
			createCrater(loc,3)
		stoopme=1
		src.loc=null//move to null so the garbage collector can handle it when it has time
		obj_list-=src
		attack_list-=src
		deleteMe()
		return

proc/createShockwavemisc(loc,s)
	if(!loc) return
	s = clamp(s,1,4)
	switch(s)
		if(1) new/obj/meff/shockwave/one(loc)
		if(2) new/obj/meff/shockwave/two(loc)
		if(3) new/obj/meff/shockwave/five(loc)
		if(4) new/obj/meff/shockwave(loc)

/obj/meff/shockwave
	icon = 'Shockwavecustom64.dmi'
	pixel_x = -16
	pixel_y = -16
	five
		icon = 'Shockwavecustom512.dmi'
		pixel_x = -240
		pixel_y = -240
	one
		icon = 'Shockwavecustom128.dmi'
		pixel_x = -48
		pixel_y = -48
	two
		icon = 'Shockwavecustom256.dmi'
		pixel_x = -112
		pixel_y = -112
	
	canGrab=0
	New()
		..()
		spawn(5) if(src) deleteMe()