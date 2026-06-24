proc/createCrater(loc,magnitude)
	if(!loc) return
	magnitude = clamp(magnitude,1,5)
	switch(magnitude)
		if(1) new/obj/Crater/destroyed(loc)
		if(2) new/obj/Crater/BurntCrater(loc)
		if(3) new/obj/Crater/BigCrater(loc)
		if(4) new/obj/Crater/boom(loc)
		if(5) new/obj/Crater/slam(loc)

/*obj/destroyed*/
/*obj/BigCrater*/
/*obj/impactcrater*/
obj/Crater
	IsntAItem = 1
	New()
		..()
		var/matrix/M = matrix()
		M.Scale(1/10,1/10)
		src.transform = M
		animate(src,time = 6,transform = null)
		spawn
			sleep(500)
			deleteMe(src)
	destroyed
		icon='Craters2.dmi'
		canGrab=0
		icon_state="2"
		mouse_opacity = 0
		pixel_x = -32
		pixel_y = -32

	boom
		icon='Craters2.dmi'
		canGrab=0
		icon_state="6"
		mouse_opacity = 0
		pixel_x = -32
		pixel_y = -32
	slam
		icon='Craters2.dmi'
		canGrab=0
		icon_state="1"
		mouse_opacity = 0
		pixel_x = -32
		pixel_y = -32
	BurntCrater
		icon='Craters2.dmi'
		canGrab=0
		mouse_opacity = 0
		icon_state="3"
		pixel_x = -32
		pixel_y = -32

	BigCrater
		icon='Craters2.dmi'
		canGrab=0
		mouse_opacity = 0
		pixel_x = -32
		pixel_y = -32

	impactcrater
		icon = 'craterkb.dmi'
		icon_state = "crater"
		mouse_opacity = 0
		canGrab = 0
		pixel_x = -20
		pixel_y = -16

obj/impactditch
	icon = 'craterseries.dmi'
	icon_state = "crater"
	mouse_opacity = 0
	canGrab = 0
	IsntAItem

	New()
		..()
		spawn(350)
			src.deleteMe()