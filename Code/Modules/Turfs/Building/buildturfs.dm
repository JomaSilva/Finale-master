turf/build
	Free=0
	var/wasoutside
	New()
		isbuilt=1
		addtoinside()
		..()
	Del()
		..()

	proc/addtoinside()
		set waitfor = 0
		set background = 1
		var/area/oA = GetArea()
		if(!wasoutside) spawn for(var/area/A in area_inside_list)
			sleep(1)
			if(A.Planet == oA.Planet && A != oA)
				A.contents.Add(src)
		else if(wasoutside) spawn for(var/area/A in area_outside_list)
			sleep(1)
			if(A.Planet == oA.Planet && A != oA)
				A.contents.Add(src)
	SecurityWall
		icon='turfs.dmi'
		icon_state="SecurityWall"
		opacity=1
		density=1
	bottom
		icon='Space.dmi'
		icon_state="bottom"
		density=1
	top
		icon='Space.dmi'
		icon_state="top"
		density=1
		opacity=1
	wall
		icon='Turf1.dmi'
		icon_state="wall"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	wallz
		icon='turfs.dmi'
		icon_state="tile5"
		density=1
		opacity=0
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	floorz
		icon='Turfs 15.dmi'
		icon_state="floor6"
	grassz1
		icon='NewTurf.dmi'
		icon_state="grass c"
	grassz2
		icon='turfs.dmi'
		icon_state="grass"
	grassz3
		icon='Turfs 12.dmi'
		icon_state="grass4"
	grassz4
		icon='Turfs 12.dmi'
		icon_state="grass5"
	bridge
		icon='turfs.dmi'
		icon_state="bridgemid2"
	browndirt
		icon='Turfs 1.dmi'
		icon_state="dirt"
	browncrack
		icon='Turfs 1.dmi'
		icon_state="crack"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	browncave
		icon='Turfs 1.dmi'
		icon_state="cave"
	Vegetastairs
		icon='Turfs 1.dmi'
		icon_state="stairs"
	lightgrass
		icon='NewTurf.dmi'
		icon_state="grass d"
	earthgrass
		icon='Turfs 1.dmi'
		icon_state="grass"
	lightrockground
		icon='FloorsLAWL.dmi'
		icon_state="Flagstone"
	earthstairs1
		icon='Turfs 1.dmi'
		icon_state="earthstairs"
	cliff
		icon='Turfs 1.dmi'
		icon_state="cliff"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	namekstonewall
		icon='turfs.dmi'
		icon_state="wall8"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	shinystairs
		icon='Turfs 1.dmi'
		icon_state="stairs2"
	steelwall
		icon='Turfs 3.dmi'
		icon_state="cliff"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	darktiles
		icon='turfs.dmi'
		icon_state="tile9"
	icecliff
		icon='Turfs 4.dmi'
		icon_state="ice cliff"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	icefloor
		icon='Turfs 4.dmi'
		icon_state="ice cliff"
	icecave
		icon='Turfs 4.dmi'
		icon_state="ice cave"
		opacity=1
	coolflooring
		icon='Turfs 4.dmi'
		icon_state="cooltiles"
	Vegetarockwall
		icon='Turfs 4.dmi'
		icon_state="wall"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Vegetawater
		icon='Misc.dmi'
		icon_state="Water"
		density=1
		Water=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight|!M.density|M.swim|M.boat) return 1
				else return
			else
				KiWater()
				return 1
	Namekstairs
		icon='Turfs 1.dmi'
		icon_state="stairs1"
	earthrockwall
		icon='Turfs 1.dmi'
		icon_state="wall"
		density=1
	SSFloor
		icon='FloorsLAWL.dmi'
		icon_state="SS Floor"
	tourneytiles
		icon='Turfs 2.dmi'
		icon_state="tourneytiles"
	brickwall
		icon='turfs.dmi'
		icon_state="tile1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	brickwall2
		icon='Turfs 2.dmi'
		icon_state="brick2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Namekgrass
		icon='FloorsLAWL.dmi'
		icon_state="Grass Namek"
	Namekwater
		icon='turfs.dmi'
		icon_state="nwater"
		density=1
		Water=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight|!M.density|M.swim|M.boat) return 1
				else return
			else
				KiWater()
				return 1
	sky
		icon='Misc.dmi'
		icon_state="Sky"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	afterlifesky
		icon='Misc.dmi'
		icon_state="Clouds"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Vegetaparchedground
		icon='FloorsLAWL.dmi'
		icon_state="Flagstone Vegeta"
	Vegetaparcheddirt
		icon='Turfs 2.dmi'
		icon_state="dirt"
	woodfloor
		icon='Turfs 1.dmi'
		icon_state="woodenground"
	snow
		icon='FloorsLAWL.dmi'
		icon_state="Snow"
	sand
		icon='Turfs 1.dmi'
		icon_state="sand"
	tilefloor
		icon='Turfs 1.dmi'
		icon_state="ground"
	dirt
		icon='Turfs 1.dmi'
		icon_state="dirt"
	NormalGrass
		icon='Turfs 2.dmi'
		icon_state="grass"
	Water
		icon='Turfs 1.dmi'
		icon_state="water"
		Water=1
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight|!M.density|M.swim|M.boat) return 1
				else return
			else
				KiWater()
				return 1
	Floor
		icon='Turfs 12.dmi'
		icon_state="floor2"
	Floor2
		icon='Turfs 12.dmi'
		icon_state="floor4"
	Ice
		icon='Turfs 12.dmi'
		icon_state="ice"
	Tile2
		icon='FloorsLAWL.dmi'
		icon_state="Tile"
	Lava
		icon='turfs.dmi'
		icon_state="lava"
		density=1
		fire=1
		Water=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	GirlyCarpet
		icon='Turfs 12.dmi'
		icon_state="Girly Carpet"
	WoodFloor2
		icon='Turfs 12.dmi'
		icon_state="Wood_Floor"
	Btile
		icon='turfs.dmi'
		icon_state="roof4"
		density=1
	StoneFloor
		icon='Turfs 12.dmi'
		icon_state="stonefloor"
	GraniteSlab
		icon='Turfs.dmi'
		icon_state="roof2"
		density=1
		opacity=1
	BlackMarble
		icon='turfs.dmi'
		icon_state="tile10"
	Steps
		icon='Turfs 12.dmi'
		icon_state="Steps"
	AluminumFloor
		icon='Turfs 12.dmi'
		icon_state="Aluminum Floor"
	Desert
		icon='Turfs 12.dmi'
		icon_state="desert"
	Water2
		icon='NewTurf.dmi'
		icon_state="stillwater"
		Water=1
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight|!M.density|M.swim|M.boat) return 1
				else return
			else
				KiWater()
				return 1
	Stone2
		icon='Turfs 14.dmi'
		icon_state="Stone"
	Dirt
		icon='Turfs 14.dmi'
		icon_state="Dirt"
		layer=OBJ_LAYER-1
	fanceytile
		icon='turfs.dmi'
		icon_state="tile7"
	fanceywall
		icon='turfs.dmi'
		icon_state="wall6"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	grass2
		icon='Turfs 17.dmi'
		icon_state="grass"
	wall6
		icon='turfs.dmi'
		icon_state="wall6"
		opacity=0
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	wooden
		icon='Turfs18.dmi'
		icon_state="wooden"
	diagwooden
		icon='Turfs18.dmi'
		icon_state="diagwooden"
	stone
		icon='Turfs18.dmi'
		icon_state="stone"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	jwall
		icon='Turfs 19.dmi'
		icon_state="jwall"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	OPACITYBLOCK
		density=1
		opacity=1
	darkdesert
		icon='Turf1.dmi'
		icon_state="dark desert"
		density=0
	o1
		icon='Turf1.dmi'
		icon_state="light desert"
		density=0
	o2
		icon='Turf1.dmi'
		icon_state="very dark desert"
		density=0
	o12
		icon='Turf2.dmi'
		icon_state="146"
	o16
		icon='Turf2.dmi'
		icon_state="150"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	o26
		icon='Turf2.dmi'
		icon_state="160"
	o43
		icon='Turfs 12.dmi'
		icon_state="Brick_Floor"
	o44
		icon='Turfs 12.dmi'
		icon_state="Stone Crystal Path"
	o45
		icon='Turfs 12.dmi'
		icon_state="Stones"
	o46
		icon='Turfs 12.dmi'
		icon_state="Black Tile"
	o47
		icon='Turfs 12.dmi'
		icon_state="Dirty Brick"
	o49
		icon='Turfs 14.dmi'
		icon_state="Grass"
	o54
		icon='Turfs 7.dmi'
		icon_state="Sand"
	o55
		icon='Turfs 12.dmi'
		icon_state="floor4"
	o56
		icon='Turfs 8.dmi'
		icon_state="Sand"
	Door //also: see code in doors.dm (identical password code.)
		var/seccode
		density = 0
		opacity = 0
		New()
			..()
			Close()
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.KB) return
				if(icon_state=="Open"||icon_state=="Opening") return 1
				else
					if(icon_state=="Closed")
						if(seccode)
							if(M.client)
								var/skipguess
								for(var/obj/items/Key/K in M.contents)
									if(K.password.len >=1)
										if(seccode in K.password)
											skipguess = 1
											break
								if(skipguess)
									Open()
									return 1
								var/guess = input(M,"What's the password?") as text
								if(guess==seccode)
									Open()
									return 1
							else return
						else
							Open()
							density = 0
							opacity = 0
							return 1
		Click()
			..()
			if(icon_state=="Closed")
				if(seccode)
					if(usr.client)
						var/skipguess
						for(var/obj/items/Key/K in usr.contents)
							if(K.password.len >=1)
								if(seccode in K.password)
									skipguess = 1
									break
						if(skipguess)
							Open()
							return 1
						else
							for(var/mob/M in view(15,src))
								if(M.client)
									M<<"**[usr] knocks on the door!**"
					else return
				else
					Open()
					return 1
			else
				Close()
		proc/Open()
			density=0
			opacity=0
			flick("Opening",src)
			icon_state="Open"
			spawn(50) Close()
		proc/Close()
			if(icon_state=="Closed"&&density&&opacity) return
			density=1
			opacity=1
			flick("Closing",src)
			icon_state="Closed"
		Door1
			icon='Door1.dmi'
			New()
				..()
				icon_state="Closed"
				Close()
		Door2
			icon='Door2.dmi'
			New()
				..()
				icon_state="Closed"
				Close()
		Door3
			icon='Door3.dmi'
			New()
				..()
				icon_state="Closed"
				Close()
		Door4
			icon='Door4.dmi'
			New()
				..()
				icon_state="Closed"
				Close()
		Door5
			icon='Turfs 9.dmi'
			New()
				..()
				icon_state="Closed"
				Close()
	arenawallcentright
		icon='arena.dmi'
		icon_state="awall"
		density=1
	arenawallcentleft
		icon='arena.dmi'
		icon_state="awall2"
		density=1
	arenawall
		icon='arena.dmi'
		icon_state="awall4"
		density=1
	arenawall2
		icon='arena.dmi'
		icon_state="awall5"
		density=1
	arenaground
		icon='arena.dmi'
		icon_state="ground"
	arenafloor
		icon='arena.dmi'
		icon_state="floor"
	arenasteps
		icon='arena.dmi'
		icon_state="asteps"
	metalroofa
		icon='metaltiles1.dmi'
		icon_state="metalroofa"
		density=1
		opacity=1
	metalroofb
		icon='metaltiles1.dmi'
		icon_state="metalroofb"
		density=1
		opacity=1
	metalroofc
		icon='metaltiles1.dmi'
		icon_state="metalroofc"
		density=1
		opacity=1
	metalwalla
		icon='metaltiles1.dmi'
		icon_state="metalwalla"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	metalwallb
		icon='metaltiles1.dmi'
		icon_state="metalwallb"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	metalfloora
		icon='metaltiles1.dmi'
		icon_state="metalfloora"
	metalfloorb
		icon='metaltiles1.dmi'
		icon_state="gratingfloorb"
	Roof
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof"
		density=1
		opacity=1
	Roof2
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-5"
		density=1
		opacity=1
	Roof3
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-1"
		density=1
		opacity=1
	Roof4
		icon='Tiles 1.21.2011.dmi'
		icon_state="Roof-2"
		density=1
		opacity=1
	Roof5
		icon='Tiles 1.21.2011.dmi'
		icon_state="23"
		density=1
		opacity=1
	Roof6
		icon='Tiles 1.21.2011.dmi'
		icon_state="24"
		density=1
		opacity=1
	woodfloor3
		icon='Turfs18.dmi'
		icon_state="wooden"
	stonewall
		icon='Turfs18.dmi'
		icon_state="stone"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	roof7
		icon='turf5.dmi'
		icon_state="Floor"
		density=1
		opacity=1
	teracotta
		icon='turf5.dmi'
		icon_state="teracotta"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	sidewalk
		icon='turf5.dmi'
		icon_state="Sidewalk"
	Roof_Tile_1
		icon='Turfs 96.dmi'
		icon_state="roof3"
		density=1
		opacity=1
	Roof_Tile_2
		icon='Turfs 96.dmi'
		icon_state="roof4"
		density=1
		opacity=1
	Roof_Tile_3
		icon='Turfs 96.dmi'
		icon_state="roof2"
		density=1
		opacity=1
	Roof_Tile_4
		icon='Turfs 96.dmi'
		icon_state="roof"
		density=1
		opacity=1
	Roof_Tile_5
		icon='Turfs 96.dmi'
		icon_state="roof42"
		density=1
		opacity=1
	Roof_Tile_6
		icon='Turfs 96.dmi'
		icon_state="roof7"
		density=1
		opacity=1
	Roof_Tile_6
		icon='Turfs 96.dmi'
		icon_state="roof6"
		density=1
		opacity=1
	Wall_Tile_1
		icon='Turfs 96.dmi'
		icon_state="wall5"
		density=1
	Wall_Tile_2
		icon='Turfs 96.dmi'
		icon_state="wall4"
		density=1
	Wall_Tile_3
		icon='turfs66.dmi'
		icon_state="wall"
		density=1
	Wall_Tile_4
		icon='Turfs 7.dmi'
		icon_state="Wall"
		density=1
	Wall_Tile_5
		icon='Turfs Temple.dmi'
		icon_state="wall"
		density=1
	Wall_Tile_6
		icon='Turfs Temple.dmi'
		icon_state="wall2"
		density=1
	Floor_Tile_1
		icon='Turf 57.dmi'
		icon_state="59"
	Floor_Tile_2
		icon='Turf 57.dmi'
		icon_state="60"
	Floor_Tile_3
		icon='Turf 57.dmi'
		icon_state="106"
	Vegetawater
		icon='Misc.dmi'
		icon_state="Water"
		density=1
		Water=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight|!M.density|M.swim|M.boat) return 1
				else return
			else
				KiWater()
				return 1
	Grass11
		icon='Turfs 1.dmi'
		icon_state="Grass 50"
	GroundHell2 //*
		icon='HellGround2017.dmi'
		getWidth = 192
		getHeight = 192
		isHD = 1
	WaterHD1 //*
		icon='WaterBlue2017.dmi'
		getWidth = 192
		getHeight = 192
		icon_state = "0,0"
		Water=1
		isHD = 1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	WaterHD2 //*
		icon='WaterBlue22017.dmi'
		icon_state = "0,0"
		getWidth = 124
		getHeight = 124
		Water=1
		isHD = 1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	WaterHD3 //*
		icon='CartoonWater2017.dmi'
		getWidth = 128
		getHeight = 128
		Water=1
		isHD = 1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	WaterToxic //*
		icon='ToxicWater.dmi'
		getWidth = 192
		getHeight = 192
		icon_state = "0,0"
		Water=1
		isHD = 1
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
	LavaHD //*
		icon='Lava2017.dmi'
		getWidth = 128
		getHeight = 128
		Water=1
		isHD = 1
		icon_state="0,0"
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
		isHD = 1
	GrassHD2
		icon='BigGrass.dmi'
		getWidth = 128
		getHeight = 128
		isHD = 1
	GrassHD3
		icon='BigGrassandDirtTurf.dmi'
		getWidth = 192
		getHeight = 192
		isHD = 1
	DirtHD1
		icon='BigDirtTurf2.dmi'
		getWidth = 128
		getHeight = 128
		isHD = 1
	DirtHD2
		icon='BigDirtTurfs.dmi'
		getWidth = 128
		getHeight = 128
		isHD = 1
	IceHD1
		icon='BigIceTurf.dmi'
		getWidth = 128
		getHeight = 128
		isHD = 1
	IceHD2
		icon='BigIceTurf2.dmi'
		getWidth = 192
		getHeight = 192
		isHD = 1
	IceHD3
		icon='BigIceTurf3.dmi'
		getWidth = 192
		getHeight = 192
		isHD = 1
	SandHD1
		icon='BigSandTurf.dmi'
		getWidth = 128
		getHeight = 128
		isHD = 1
	SnowHD1
		icon='BigSnowandRockTurf.dmi'
		getWidth = 192
		getHeight = 192
		isHD = 1
	SnowHD2
		icon='BigSnowTurf.dmi'
		getWidth = 192
		getHeight = 192
		isHD = 1
	SkyHD
		icon='hdsky3.dmi'
		getHeight = 64
		getWidth = 64
		Water = 1
		isHD = 1
		Enter(mob/M)
			if(ismob(M)) if(M.isflying|!M.density) return ..()
			else return ..()
	SkyHD2
		icon='yelsky.dmi'
		getHeight = 512
		getWidth = 512
		Water = 1
		isHD = 1
		Enter(mob/M)
			if(ismob(M))
				if(M.isflying|!M.density)
					return ..()
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