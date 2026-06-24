proc/createDust(loc,magnitude)
	set waitfor = 0
	set background = 1
	while(magnitude >= 1)
		magnitude--
		if(prob(35)) spawn new/obj/Dust(loc)
		else spawn new/obj/Rock(loc)

proc/createDustmisc(loc,s)
	set waitfor = 0
	set background = 1
	if(!loc) return
	s = clamp(s,1,5)
	switch(s)
		if(1) new/obj/meff/Explosion(loc)
		if(2) new/obj/meff/Rising(loc)
		if(3) new/obj/meff/Tornado(loc)
		if(4) new/obj/Dust/bigcloud(loc)
		if(5) new/obj/meff/shiny(loc)
		if(6) new/obj/Rock(loc)
		if(7) new/obj/Dust(loc)
proc/createDustshock(loc,magnitude)
	set waitfor = 0
	set background = 1
	var/list/dirlist = list(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
	while(magnitude >= 1)
		magnitude--
		var/obj/a = new/obj/Dust/sd(loc)
		. = pick(dirlist)
		a.dir = .
		dirlist -= .
	return TRUE
proc/createLightningmisc(loc,s)
	set waitfor = 0
	set background = 1
	if(!loc) return
	s = clamp(s,1,10)
	switch(s)
		if(10) new/obj/Lightning/Brief(loc)
		if(9) new/obj/Lightning/ElectricB(loc)
		if(8) new/obj/Lightning/SD(loc)
		if(7) new/obj/Lightning/Flare(loc)
		if(6) new/obj/Lightning/Red(loc)
		if(5) new/obj/Lightning/Elite(loc)
		if(4) new/obj/Lightning/Electric(loc)
		if(3) new/obj/Lightning/Flash(loc)
		if(2) new/obj/Lightning/SSJ(loc)
		if(1) new/obj/Lightning(loc)
obj/Rock
	canGrab=1
	density=0
	icon='dust.dmi'
	fragile = 1
	createDust = 0
	New()
		..()
		switch(rand(1,15))
			if(1 to 13)
				icon = 'Gardening.dmi'
				icon_state = "Rock5"
			if(14)
				icon = 'Rocks.dmi'
				icon_state = "Rock1"
				density=1
			if(15)
				icon = 'Rocks.dmi'
				icon_state = "Rock5"
				density=1
				opacity = 1
		spawn(30000) deleteMe()
obj/Dust
	canGrab=0
	density=0
	icon='dust.dmi'
	var/steptimer=6
	proc/ticker()
		set waitfor = 0
		set background = 1
		dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
		while(src && steptimer >= 1)
			steptimer--
			if(steptimer <= 0)
				obj_list -= src
				loc = null
				deleteMe()
				return
			sleep(10)
			step(src,dir)
		deleteMe()
	sd
		ticker()
			set waitfor = 0
			set background = 1
			//dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
			while(src && steptimer >= 1)
				steptimer--
				if(steptimer <= 0)
					obj_list -= src
					loc = null
					deleteMe()
					return
				sleep(10)
				step(src,dir)
			deleteMe()
	New()
		..()
		spawn ticker()
	bigcloud
		icon='dustcloud2018.png'
		steptimer=10
		pixel_x = -624
		pixel_y = -344
		ticker()
			set waitfor=0
			while(src)
				if(steptimer <= 0) deleteMe()
				sleep(10)
				steptimer--
				var/icon/I = new(icon)
				switch(rand(1,2))
					if(1) icon = I.Turn(180)
					if(2) icon = I.Flip(EAST)
obj/Lightning
	canGrab=0
	IsntAItem = 1
	icon='Lightning.dmi'
	New()
		..()
		spawn(rand(100,200)) if(src) deleteMe()
	Brief
		canGrab=0
		icon='Lightning.dmi'
		New()
			..()
			spawn(rand(10,50)) if(src) deleteMe()
	Electric
		canGrab=0
		icon='Electric_Yellow.dmi'
	SSJ
		canGrab=0
		icon='SSj Lightning.dmi'
	Flash
		canGrab=0
		icon='Lightning flash.dmi'
		New()
			..()
			spawn(2) if(src) deleteMe()
	Elite
		icon='DelayedElectricBlue.dmi'
	ElectricB
		icon='Electric_Blue.dmi'
	Red
		icon='Electric_Red.dmi'
	Flare
		icon='Lightning flash.dmi'
		New()
			..()
			spawn(10) if(src) deleteMe()
	SD
		icon='Lightning flash.dmi'
		New()
			..()
			spawn(50) if(src) deleteMe()
obj/Explosion
	canGrab=0
	icon='Explosion.dmi'
	New()
		..()
		for(var/obj/Explosion/A in view(0,src)) if(A!=src) A.deleteMe()
		pixel_x=rand(-8,8)
		pixel_y=rand(-8,8)
		spawn(rand(4,6)) if(src) deleteMe()
obj/Tornado
	canGrab=0
	icon='Tornado.dmi'
	New()
		..()
		spawn(rand(100,200)) if(src) deleteMe()

obj/meff
	IsntAItem = 1
	mouse_opacity = 0
	Explosion
		canGrab=0
		icon='Explosion.dmi'
		New()
			..()
			for(var/obj/Explosion/A in view(0,src)) if(A!=src) A.deleteMe()
			pixel_x=rand(-8,8)
			pixel_y=rand(-8,8)
			spawn(rand(4,6)) if(src) deleteMe()
	Tornado
		canGrab=0
		icon='Tornado.dmi'
		New()
			..()
			spawn(rand(100,200)) if(src) deleteMe()
	Rising
		canGrab=0
		icon='Rising Rocks.dmi'
		New()
			..()
			spawn(rand(100,400)) if(src) deleteMe()
	shiny
		canGrab=0
		icon='beamaxis.dmi'
		pixel_x = -32
		pixel_y = -32
		New()
			..()
			spawn(rand(10,30)) if(src) deleteMe()

obj/overlay/effects/electrictyeffects
	name = "Electricty effect (sparks off of SSJ2/3/4, Perfect Cell, and etc.)"
	ID = 9
	icon = 'Electric_Blue.dmi'
	var/changeme = 1
	EffectLoop()
		if(prob(10) && container && changeme)
			switch(container.trueKiMod)
				if(1 to 2)
					icon = 'Electric_Blue.dmi'
				if(2 to 3)
					icon = 'snamek Elec.dmi'
				else
					icon = 'Electric_Yellow.dmi'
		..()
	reg_elec
		name = "Electricty effect (sparks off of SSJ2/3/4, Perfect Cell, and etc.)"
		ID = 9
		icon = 'Elec.dmi'
		changeme = 0