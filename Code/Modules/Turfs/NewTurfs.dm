//a '//*' means it needs adjustments. most tiles are not 128x128, but between 256^2 and 160^2 pixels.
turf/proc/Destroy()
	set waitfor = 0
	if(src.destroyable)//need to overhaul building anyway w-wew
		sleep(2)
		if(prob(25)) createDust(src,1) //src (o TILE), nao loc: loc de turf e a AREA -- a poeira nascia invisivel dentro dela
		var/area/currentArea = GetArea()
		//var/hasgravity = src.gravity
		var/turf/T = new/turf/Ground/Ground8(locate(x,y,z))
		//T.gravity = hasgravity
		//if(hasgravity)
			//T.overlays.Add(image(icon='Gravity Field.dmi',layer=MOB_LAYER+4))
		if(currentArea.name=="Inside")
			for(var/area/A in area_list)
				if(A.name!="Inside"&&A.Planet==currentArea.Planet)
					A.contents.Add(T)
					break

turf/UnbreakableTurfs
	Void_Wall
		icon = 'Hell turf.dmi'
		density = 1
		opacity = 1
		destroyable=0
turf/Other
	Stars
		icon='spacebck.dmi'
		icon_state="1"
		destroyable=0
		New()
			..()
			icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	Stars_Exit
		icon='spacebck.dmi'
		icon_state="1"
		destroyable=0
		New()
			..()
			icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
		Enter(atom/movable/O)
			if(ismob(O))
				var/mob/M = O
				//LOOP DO PLANETA: encostar na borda leva pro LADO OPOSTO (planeta redondo) --
				//vale pros mapas canonicos E pras superficies procedurais (aneis na borda do mundo).
				//Sair pro espaco agora e SO decolando de nave (Launch).
				var/nx = x
				var/ny = y
				if(x <= 3) nx = world.maxx - 3
				else if(x >= world.maxx - 2) nx = 4
				if(y <= 3) ny = world.maxy - 3
				else if(y >= world.maxy - 2) ny = 4
				if(nx != x || ny != y)
					M.loc = locate(nx, ny, z)
					return 0 //ja atravessou pro outro lado; o passo na borda nao acontece
				//Stars_Exit FORA da borda do mundo (uso legado no interior de algum mapa): sai pro espaco como antes
				if(M.isNPC && !M.client) return 0
				for(var/obj/Planets/P in world)
					if(P.planetType==M.Planet)
						var/list/randTurfs = list()
						for(var/turf/T in view(1,P))
							randTurfs += T
						var/turf/rT = pick(randTurfs)
						O.loc = locate(rT.x,rT.y,rT.z)
						M.pspace_noland_until = world.time + 80
						break
			..()

turf/HDTurfs
	isHD = 1
	//For sorted sake.
	//For working HD tiles: Make sure they're stated like "0,0" "0,1" and so on, 0,0 being the northwest corner.
	//set getWidth to tile width. Set getHeight to tile height. make isHD = 1, be habbi.
	GroundHell2 //*
		icon='HellGround2017.dmi'
		getWidth = 192
		getHeight = 192
	WaterHD1 //*
		icon='WaterBlue2017.dmi'
		getWidth = 192
		getHeight = 192
		icon_state = "0,0"
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	WaterHD2 //*
		icon='WaterBlue22017.dmi'
		icon_state = "0,0"
		getWidth = 124
		getHeight = 124
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	WaterHD3 //*
		icon='CartoonWater2017.dmi'
		getWidth = 128
		getHeight = 128
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	WaterToxic //*
		icon='ToxicWater.dmi'
		getWidth = 192
		getHeight = 192
		icon_state = "0,0"
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	LavaHD //*
		icon='Lava2017.dmi'
		getWidth = 128
		getHeight = 128
		Water=1
		icon_state = "0,0"
		fire=1
		Enter(atom/movable/O, atom/oldloc)
			if(istype(O,/mob))
				if(testWaters(O))
					O:SpreadDamage(1)
					if(O:HP == 0)
						O:Death()
					return 1
				else return 0
			else return testWaters(O)
	GrassHD1
		icon='BigGrassTurf2.dmi'
		getWidth = 96
		getHeight = 96
	GrassHD2
		icon='BigGrass.dmi'
		getWidth = 128
		getHeight = 128
	GrassHD3
		icon='BigGrassandDirtTurf.dmi'
		getWidth = 192
		getHeight = 192
	DirtHD1
		icon='BigDirtTurf2.dmi'
		getWidth = 128
		getHeight = 128
	DirtHD2
		icon='BigDirtTurfs.dmi'
		getWidth = 128
		getHeight = 128
	IceHD1
		icon='BigIceTurf.dmi'
		getWidth = 128
		getHeight = 128
	IceHD2
		icon='BigIceTurf2.dmi'
		getWidth = 192
		getHeight = 192
	IceHD3
		icon='BigIceTurf3.dmi'
		getWidth = 192
		getHeight = 192
	SandHD1
		icon='BigSandTurf.dmi'
		getWidth = 128
		getHeight = 128
	SnowHD1
		icon='BigSnowandRockTurf.dmi'
		getWidth = 192
		getHeight = 192
	SnowHD2
		icon='BigSnowTurf.dmi'
		getWidth = 192
		getHeight = 192
	InbetweenDimension //old turf
		icon='dimensiontile.dmi'
		getHeight = 64
		getWidth = 64
	InbetweenDimension1
		icon='dimensiontile2.dmi'
		getHeight = 256
		getWidth = 256
	InbetweenDimension2
		icon='dimensiontile3.dmi'
		getHeight = 256
		getWidth = 256
	InbetweenDimensionIntermission
		icon='dimensiontile4.dmi'
		getHeight = 256
		getWidth = 256
	Void //*
		icon='voidturf.dmi'
		getWidth = 1024
		getHeight = 1024
	SkyHD
		icon='hdsky3.dmi'
		getHeight = 64
		getWidth = 64
		Water = 1
		destroyable=0
		Enter(mob/M)
			if(ismob(M)) if(M.isflying|!M.density) return ..()
			else return ..()
	SkyHD2
		icon='yelsky.dmi'
		getHeight = 512
		getWidth = 512
		Water = 1
		destroyable=0
		Enter(mob/M)
			if(ismob(M))
				if(M.isflying|!M.density)
					return ..()
				else
					to_chat(usr, "You fall through the clouds and land in Hell!")
					M.loc=locate(63,260,9)
					return 1
			else return ..()
	VegetaWaterHD
		icon='vegetawater.dmi'
		icon_state="0,0"
		isHD = 1
		getHeight = 128
		getWidth = 128
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	NamekWaterHD
		icon='namekwater.dmi'
		icon_state="0,0"
		isHD = 1
		getHeight = 128
		getWidth = 128
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
turf
	Water8
		icon='namekwater.dmi'
		icon_state="0,0"
		isHD = 1
		getHeight = 128
		getWidth = 128
		Water=1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)

	Water7
		icon='Lava2017.dmi'
		icon_state="0,0"
		isHD = 1
		getHeight = 128
		getWidth = 128
		Water=1 //sure you can swim in lava :^)
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	Water1
		icon_state="1"
		icon='Waters.dmi'
		Water=1
		destroyable=0
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	Water2
		icon_state="2"
		icon='Waters.dmi'
		Water=1
		destroyable=0
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	Water3
		icon_state="3"
		icon='Waters.dmi'
		Water=1
		destroyable=0
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
turf/Other
	Lava
		icon='Lava2017.dmi'
		icon_state="0,0"
		Water=1
		Water=1
		fire=1
		getHeight = 128
		getWidth = 128
		Enter(mob/M)
			return ..()
			//if(ismob(M)&&prob(5))
				//M<<"You fell in the lava and died"
				//spawn M.Death()
