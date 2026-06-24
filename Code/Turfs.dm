var/HBTC_Open

var/list/turfsave = list()//turfs that need to be saved are going to be dumped in here

proc/HBTC()
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will remain open for one hour, \
	if you do not exit before then you will be trapped until someone enters the time chamber a, \
	and you will continue aging at ten times the normal rate until you exit"
	sleep(6000)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will be unlocked for 50 more minutes"
	sleep(6000)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will be unlocked for 40 more minutes"
	sleep(6000)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will be unlocked for 30 more minutes"
	sleep(6000)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will be unlocked for 20 more minutes"
	sleep(6000)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will be unlocked for 10 more minutes"
	sleep(3000)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will be unlocked for 5 more minutes"
	sleep(2400)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber will remain unlocked for ONE more minute"
	sleep(600)
	for(var/mob/A in Players) if(A.z==13) A<<"The time chamber exit disappears. You are now trapped"
	HBTC_Open=0
//Idk where to put this stuff for the HBTC. It belongs in its own file but thats just one more .dm with barely any lines of code in it so idk

turf/New()
	..()
	name="ground"
	if(proprietor)
		turfsave.Add(src)
turf/Del()
	if(proprietor)
		turfsave.Remove(src)
	if(istype(src,/turf)) return
	..()
turf/var
	ownerKey=""
	isSpecial=0
	Water
	getWidth = 32
	getHeight = 32
	isHD = 0 //getWidth, getHeight, and isHD are here if you decide to put HD Turfs under /Turfs/ rather than /Turfs/HDTurfs/, which you probably shouldn't do for organization's sake but zzzzz
	canBuild=0 //determines if the certain turf/category will show up in the player build menu. Keep it off for anything that teleports or has very special effects. Water and lava are fine.
	adminBuild //like the above except exclusive to admins
	FlyOverAble
//a '//*' means it needs adjustments. most tiles are not 128x128, but between 256^2 and 160^2 pixels.
turf/proc
	autofill() //Don't worry about this unless its an HD Turf
		set waitfor=0
		if(getWidth&&getHeight)
			var/getHeight2 = getHeight / 32
			var/getWidth2 = getWidth / 32
			icon_state = "[x % getWidth2],[y % getHeight2]"
		else
			icon_state = "[x&1],[y&1]"
	KiWater() for(var/obj/attack/blast/M in view(1,src)) //Should add effects on the water if a blast comes through
		var/image/I=image(icon='KiWater.dmi',dir=M.dir)
		overlays.Add(I)
		spawn(5) overlays.Remove(I)
		break

obj/var
	Admin=1
mob/var
	Space_Breath=0
turf/Other
	Blank
		density=1
		opacity=1
		destroyable=0
		Enter(mob/M)
			if(M.Admin)
				return 1
			else return
	Sky1
		icon='Misc.dmi'
		icon_state="Sky"
		density=0
		destroyable=0
		Enter(mob/M)
			if(ismob(M)) if(M.isflying|!M.density) return 1
			else return 1
	Sky2
		icon='Misc.dmi'
		icon_state="Clouds"
		density=0
		destroyable=0
		Enter(mob/M)
			if(istype(M,/mob))
				if(!usr.flight)
					usr.loc=locate(63,260,9)
					return 1
				else return 1
/*	MountainCave
		density=1
		icon='Turf1.dmi'
		icon_state="mtn cave"*/

turf/Teleporters
	destroyable=0
	isSpecial=1
	icon='TeleporterSparkle.dmi'
	CaveEntrance
		icon='Turf 57.dmi'
		icon_state="13"
		Enter(mob/M)
			if(istype(M))
				M.loc=locate(156,297,23)
	CaveEntrance1
		name = "To Heaven"
		icon='Turf 57.dmi'
		icon_state="13"
		Enter(mob/M)
			if(istype(M))
				M.loc=locate(169,25,10)//From AL to Heaven
	CaveEntrance2
		name = "To Hell"
		icon='Turf 57.dmi'
		icon_state="13"
		Enter(mob/M)
			if(ismob(M))
				M.loc=locate(64,297,9)//From AL to Hell
	CaveEntrance3
		name = "To Checkpoint"
		icon='Turf 57.dmi'
		icon_state="13"
		Enter(mob/M)
			if(ismob(M))
				M.loc=locate(221,235,6)//From Hell to AL
	CaveEntrance4
		name = "To Checkpoint"
		icon='Turf 57.dmi'
		icon_state="13"
		Enter(mob/M)
			if(ismob(M))
				M.loc=locate(146,222,6)//From Heaven to AL
	toeg
		density=1
		Enter(mob/M)
			if(istype(M,/mob)&&usr.permission>=1)
				usr.loc=locate(142,2,12)
				return 1
			else
				usr<<"A mysterious force prevents you from entering"
				return 0
	fromeg
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				usr.loc=locate(128,162,1)
				return 1
			else return 1
	tohbtc
		icon='Door6.dmi'
		icon_state="Closed"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(!usr.flight&&usr.permission==1)
					usr.loc=locate(146,160,13)
					return 1
				else return
	fromhbtc
		icon='Door6.dmi'
		icon_state="Closed"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(!usr.flight)
					usr.loc=locate(125,420,12)
					return 1
				else return 1
	Special
		Teleporter
			density=0
			var/gotox
			var/gotoy
			var/gotoz
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.grabbee) for(var/mob/A in view(1,M)) if(A.name==M.grabbee) A.loc=locate(gotox,gotoy,gotoz)
					usr.loc=locate(gotox,gotoy,gotoz)
				else if(M) M.loc=locate(gotox,gotoy,gotoz)
			New()
				..()
				//turfsave+=src

			Del()
				//turfsave-=src
				..()

mob/var/drinking=0
turf/var/destroyable=1
mob/var/spacewalker
turf
	Arena
		density=1
		AWall1
			icon='arena.dmi'
			icon_state="awall"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall2
			icon='arena.dmi'
			icon_state="awall2"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall3
			icon='arena.dmi'
			icon_state="awall3"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall4
			icon='arena.dmi'
			icon_state="awall4"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall5
			icon='arena.dmi'
			icon_state="awall5"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall6
			icon='arena.dmi'
			icon_state="awall6"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall7
			icon='arena.dmi'
			icon_state="awall7"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall8
			icon='arena.dmi'
			icon_state="awall8"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall9
			icon='arena.dmi'
			icon_state="awall9"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall10
			icon='arena.dmi'
			icon_state="awall10"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AWall11
			icon='arena.dmi'
			icon_state="awall11"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		ASteps
			icon='arena.dmi'
			icon_state="asteps"
			density=0
		AGrass
			icon='arena.dmi'
			icon_state="grass"
			density=0
		AGround
			icon='arena.dmi'
			icon_state="ground"
			density=0
		AGround2
			icon='arena.dmi'
			icon_state="ground2"
			density=0
		AGround3
			icon='arena.dmi'
			icon_state="ground3"
			density=0
		AGround4
			icon='arena.dmi'
			icon_state="ground4"
			density=0
		AGround5
			icon='arena.dmi'
			icon_state="ground5"
			density=0
		ASign
			icon='arena.dmi'
			icon_state="sign"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		AFloor
			icon='arena.dmi'
			icon_state="floor"
			density=0
		AFloorSides
			icon='arena.dmi'
			icon_state="sides"
			density=0
		AFloorBottomSide
			icon='arena.dmi'
			icon_state="bottomside"
			density=0
		AFloorBottom
			icon='arena.dmi'
			icon_state="floorb"
			density=0
		APike1
			icon='arena.dmi'
			icon_state="p1"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		APike2
			icon='arena.dmi'
			icon_state="p2"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		APike3
			icon='arena.dmi'
			icon_state="p3"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1

	Bridge
		icon='Natural.dmi'
		Bridge1V
			icon_state="Wood15"
		Bridge1H
			icon_state="Wood14"
		Bridge2V
			icon_state="Wood6"
		Bridge2H
			icon_state="Wood5"
		Edges
			icon='Edges.dmi'
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
			bridgeN
				icon_state="N"
			bridgeS
				icon_state="S"
			bridgeE
				icon_state="E"
			bridgeW
				icon_state="W"

	CastleFloor
		Wall
			icon='castle_floor.dmi'
			icon_state=""
		Stairs
			icon='castle_floor.dmi'
			icon_state="stairs"
		Top
			icon='castle_floor.dmi'
			icon_state="top"
		TopLeft
			icon='castle_floor.dmi'
			icon_state="top left"
		TopRight
			icon='castle_floor.dmi'
			icon_state="top right"
		Left
			icon='castle_floor.dmi'
			icon_state="left"
		Right
			icon='castle_floor.dmi'
			icon_state="right"
		BottomLeft
			icon='castle_floor.dmi'
			icon_state="bottom left"
		Bottom
			icon='castle_floor.dmi'
			icon_state="bottom"
		BottomRight
			icon='castle_floor.dmi'
			icon_state="bottom right"
		Carpet
			icon='castle_floor.dmi'
			icon_state="carpet"
		StairsLeft
			icon='castle_floor.dmi'
			icon_state="stairs left"
		CarpetStairs
			icon='castle_floor.dmi'
			icon_state="carpet stairs"
		StairsRight
			icon='castle_floor.dmi'
			icon_state="stairs right"
		Ornate
			icon='castle_floor.dmi'
			icon_state="ornate"
		Crystal
			icon='castle_floor.dmi'
			icon_state="crystal"
		Pyramid
			icon='castle_floor.dmi'
			icon_state="pyramid"
		Hover
			icon='castle_floor.dmi'
			icon_state="hover"

	CastleWall
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
		Bottom
			icon='castle_wall.dmi'
			icon_state="bottom"
		RightC
			icon='castle_wall.dmi'
			icon_state="rightc"
		LeftC
			icon='castle_wall.dmi'
			icon_state="leftc"
		Top
			icon='castle_wall.dmi'
			icon_state="top"
		Shield1
			icon='castle_wall.dmi'
			icon_state="shield"
		Shield2
			icon='castle_wall.dmi'
			icon_state="shield top"
		Banner1
			icon='castle_wall.dmi'
			icon_state="banner"
		Banner2
			icon='castle_wall.dmi'
			icon_state="banner top"
		Swords1
			icon='castle_wall.dmi'
			icon_state="swords"
		Swords2
			icon='castle_wall.dmi'
			icon_state="swords top"
		Torch1
			icon='castle_wall.dmi'
			icon_state="torch"
		Torch2
			icon='castle_wall.dmi'
			icon_state="torch top"
		Window1
			icon='castle_wall.dmi'
			icon_state="window"
		Window2
			icon='castle_wall.dmi'
			icon_state="window top"
		Angel
			icon='castle_wall.dmi'
			icon_state="angel"
		DoorTop
			icon='castle_wall.dmi'
			icon_state="door top"
		Middle
			icon='castle_wall.dmi'
			icon_state="middle"
		Curtain
			icon='castle_wall.dmi'
			icon_state="curtain"
		Center
			icon='castle_wall.dmi'
			icon_state="center"
		Right
			icon='castle_wall.dmi'
			icon_state="right"
		Left
			icon='castle_wall.dmi'
			icon_state="left"

	Grass
		icon='Grass.dmi'
		Grass1
			icon_state="Grass1"
		Grass2
			icon_state="Grass15"
		Grass3
			icon_state="Grass8"
		Grass4
			icon_state="Grass10"
		Grass5
			icon_state="Grass4"
		Grass7
			icon_state="Grass3"
		Grass10
			icon_state="Grass25"
		Grass11
			icon_state="Grass5"
		Grass12
			icon_state="Grass6"
		Grass13
			icon_state="Grass2"
		Grass14
			icon_state="Grass14"
		Grass16
			icon_state="Grass11"
		Grass17
			icon_state="Grass16"
		Grass19
			icon_state="Grass19"
		Grass20
			icon_state="Grass20"
		Grass21
			icon_state="Grass21"
		Grass22
			icon_state="Grass22"
		Grass23
			icon_state="Grass23"
		Grass24
			icon_state="Grass24"
		GrassCurves
			Grass17SE
				icon_state="Grass16SE"
			Grass17NE
				icon_state="Grass16NE"
			Grass17SW
				icon_state="Grass16SW"
			Grass17NW
				icon_state="Grass16NW"
			Grass23SE
				icon_state="Grass23SE"
			Grass23NE
				icon_state="Grass23NE"
			Grass23SW
				icon_state="Grass23SW"
			Grass23NW
				icon_state="Grass23NW"
			Grass24SE
				icon_state="Grass24SE"
			Grass24NE
				icon_state="Grass24NE"
			Grass24SW
				icon_state="Grass24SW"
			Grass24NW
				icon_state="Grass24NW"

	Ground
		icon='Ground.dmi'
		Ground1
			icon_state="Ground1"
		Ground2
			icon_state="Ground2"
		Ground3
			icon_state="Ground3"
			density=0
		Ground4
			icon_state="Ground4"
		Ground5
			icon_state="Ground5"
			density=0
		Ground6
			icon_state="Ground6"
		Ground7
			icon_state="Ground7"
		Ground8
			icon_state="Ground8"
		Ground9
			icon_state="Ground9"
		Ground10
			icon_state="Ground10"
		Ground11
			icon_state="Ground11"
		Ground12
			icon_state="Ground12"
		Ground13
			icon_state="Ground13"
		Ground14
			icon_state="Ground14"
		Ground15
			icon_state="Ground15"
		Ground16
			icon_state="Ground16"
		Ground17
			icon_state="Ground17"
		Ground18
			icon_state="Ground18"
		Ground19
			icon_state="Ground19"
		Ground20
			icon_state="Ground20"
		Ground21
			icon_state="Ground21"
		Ground22
			icon_state="Ground22"
		Ground23
			icon_state="Ground23"
		Ground24
			icon_state="Ground24"
		GroundIce
			icon_state="GroundIce1"
		GroundIce1
			icon_state="GroundIce1"
		GroundIce2
			icon_state="GroundIce2"
		GroundIce3
			icon_state="GroundIce3"
		GroundSnow1
			icon_state="GroundSnow1"
		GroundCurves
			Ground10SE
				icon_state="Ground10SE"
			Ground10NE
				icon_state="Ground10NE"
			Ground10NW
				icon_state="Ground10NW"
			Ground10SW
				icon_state="Ground10SW"
			Ground15SE
				icon_state="Ground15SE"
			Ground15NE
				icon_state="Ground15NE"
			Ground15SW
				icon_state="Ground15SW"
			Ground15NW
				icon_state="Ground15NW"
			Ground18SE
				icon_state="Ground18SE"
			Ground18NE
				icon_state="Ground18NE"
			Ground18NW
				icon_state="Ground18NW"
			Ground18SW
				icon_state="Ground18SW"
		GroundEdges
			Ground10EdgeS
				icon_state="Ground10EdgeS"
			Ground10EdgeE
				icon_state="Ground10EdgeE"
			Ground10EdgeN
				icon_state="Ground10EdgeN"
			Ground10EdgeW
				icon_state="Ground10EdgeW"
			Ground15EdgeS
				icon_state="Ground15EdgeS"
			Ground15EdgeE
				icon_state="Ground15EdgeE"
			Ground15EdgeN
				icon_state="Ground15EdgeN"
			Ground15EdgeW
				icon_state="Ground15EdgeW"

	NamekBuildings
		NamekDoor
			density=1
			icon='Namek.dmi'
			icon_state="Closed"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.KB) return
					else
						if(icon_state=="Closed") Open()
						return 1
			proc/Open()
				density=0
				opacity=0
				flick("Opening",src)
				icon_state="Open"
				spawn(50) Close()
			proc/Close()
				density=1
				opacity=1
				flick("Closing",src)
				icon_state="Closed"
		NamekWall
			icon='Namek.dmi'
			icon_state="nhwall"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		NamekRoof
			icon='Namek.dmi'
			icon_state="nhroof"
			density=1
			opacity=1
			Enter(atom/A)
				if(ismob(A))
					if(FlyOverAble) return ..()
					else return
				else return ..()

	NamekIsland
		N001
			icon='New Island Edge.dmi'
			icon_state="001"
			dir=NORTH
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=SOUTH&&A.dir!=SOUTHWEST&&A.dir!=SOUTHEAST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=NORTH|A.icon_state=="Flight") return ..()
				else return ..()
		N002
			icon='New Island Edge.dmi'
			icon_state="002"
			density=0
		N004
			icon='New Island Edge.dmi'
			icon_state="004"
			dir=EAST
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=WEST&&A.dir!=SOUTHWEST&&A.dir!=NORTHWEST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=EAST|A.icon_state=="Flight") return ..()
				else return ..()
		N006
			icon='New Island Edge.dmi'
			icon_state="006"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N007
			icon='New Island Edge.dmi'
			icon_state="007"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		N008
			icon='New Island Edge.dmi'
			icon_state="008"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N010
			icon='New Island Edge.dmi'
			icon_state="010"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		N011
			icon='New Island Edge.dmi'
			icon_state="011"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N012
			icon='New Island Edge.dmi'
			icon_state="012"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N013
			icon='New Island Edge.dmi'
			icon_state="013"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N014
			icon='New Island Edge.dmi'
			icon_state="014"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		N015
			icon='New Island Edge.dmi'
			icon_state="015"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N016
			icon='New Island Edge.dmi'
			icon_state="016"
			dir=WEST
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=EAST&&A.dir!=SOUTHEAST&&A.dir!=NORTHEAST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=WEST|A.icon_state=="Flight") return ..()
				else return ..()
		N019
			icon='New Island Edge.dmi'
			icon_state="019"
			dir=WEST
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=EAST&&A.dir!=SOUTHEAST&&A.dir!=NORTHEAST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=WEST|A.icon_state=="Flight") return ..()
				else return ..()
		N020
			icon='New Island Edge.dmi'
			icon_state="020"
			dir=EAST
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=WEST&&A.dir!=SOUTHWEST&&A.dir!=NORTHWEST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=EAST|A.icon_state=="Flight") return ..()
				else return ..()
		N021
			icon='New Island Edge.dmi'
			icon_state="021"
			dir=NORTH
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=SOUTH&&A.dir!=SOUTHWEST&&A.dir!=SOUTHEAST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=NORTH|A.icon_state=="Flight") return ..()
				else return ..()
		N023
			icon='New Island Edge.dmi'
			icon_state="023"
			dir=NORTHEAST
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=SOUTH&&A.dir!=SOUTHWEST&&A.dir!=SOUTHEAST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=NORTHEAST|A.icon_state=="Flight") return ..()
				else return ..()
		N024
			icon='New Island Edge.dmi'
			icon_state="024"
			dir=NORTHWEST
			Enter(mob/A)
				if(ismob(A)) if(A.client)
					if(A.icon_state=="Flight") return ..()
					else if(A.dir!=SOUTH&&A.dir!=SOUTHWEST&&A.dir!=SOUTHEAST) return ..()
					else return
				else return ..()
			Exit(mob/A)
				if(ismob(A)) if(A.client) if(A.dir!=NORTHWEST|A.icon_state=="Flight") return ..()
				else return ..()
		N025
			icon='New Island Edge.dmi'
			icon_state="025"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		N026
			icon='New Island Edge.dmi'
			icon_state="026"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		N027
			icon='New Island Edge.dmi'
			icon_state="027"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		N028
			icon='New Island Edge.dmi'
			icon_state="028"
			Water=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight|!M.density|M.swim|M.boat|M.KB) return 1
					else return
				else
					KiWater()
					return 1
		NBase
			icon='New Island Edge.dmi'
			icon_state=""
			density=0
		N029
			icon='New Island Edge.dmi'
			icon_state="029"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N030
			icon='New Island Edge.dmi'
			icon_state="030"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		N031
			icon='New Island Edge.dmi'
			icon_state="031"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1

	Roof
		icon='Roofs.dmi'
		density=1
		opacity=1
		Enter(atom/A)
			if(ismob(A))
				if(FlyOverAble) return ..()
				else return
			else return ..()
		Roof1
			icon_state="Roof1"
		Roof1C
			icon_state="Roof1C"
		Roof2
			icon_state="Roof2"
		Roof3
			icon_state="Roof3"
		Roof4
			icon_state="Roof4"
		Roof4C
			icon_state="Roof4C"
		Roof5
			icon_state="Roof5"
		Roof5C
			icon_state="Roof5C"
		Roof6
			icon_state="Roof6"
		Roof6R
			icon_state="Roof6R"
		Roof6G
			icon_state="Roof6G"
		Roof6B
			icon_state="Roof6B"
		Roof6Y
			icon_state="Roof6Y"
		Roof6W
			icon_state="Roof6W"
		Roof7
			icon_state="Roof7"
		Roof8
			icon_state="Roof8"
		Roof9
			icon_state="Roof9"
		Roof10
			icon_state="Roof10"
		Roof11
			icon_state="Roof11"
		Roof12
			icon_state="Roof12"
		Roof13
			icon_state="Roof13"
		Roof14
			icon_state="Roof14"
		Roof15
			icon_state="Roof15"
		Roof16
			icon_state="Roof16"
		Roof17
			icon_state="Roof17"
		Roof18
			icon_state="Roof18"
		Roof19
			icon_state="Roof19"
		Roof20
			icon_state="Roof20"
		Roof21
			icon_state="Roof21"
		Roof22
			icon_state="Roof22"
		Roof23
			icon_state="Roof23"
		Roof24
			icon_state="Roof24"
		Roof25
			icon_state="Roof25"
		Roof26
			icon_state="Roof26"
		Roof27
			icon_state="Roof27"
		Roof28
			icon_state="Roof28"
		Roof29
			icon_state="Roof29"

	SnakeWay
		icon = 'Snake Way.dmi'
		Clouds
			name = "Clouds"
			density = 1
			icon_state = "clouds"
			Enter()
				if(!usr)return
				usr << "You fall down through the clouds to Hell!"
				usr.loc = locate(22,222,3)
				return
		Planet
			name = ""
			density = 1
			icon_state = "planet"
		SnakeWay1
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 1"
		SnakeWay2
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 2"
		SnakeWay3
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 3"
		SnakeWay4
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 4"
		SnakeWay5
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 5"
		SnakeWay6
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 6"
		SnakeWay7
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 7"
		SnakeWay8
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 8"
		SnakeWay9
			name = "Snake Way"
			density = 0
			icon_state = "snakeway 9"

	SpaceStation
		icon='Space.dmi'
		density=1
		bottom
			icon_state="bottom"
		top
			icon_state="top"
		light
			icon_state="light"
		glass1
			icon_state="glass1"
			layer=MOB_LAYER+1
		glasssw
			icon_state="glass sw"
			density=0
			layer=MOB_LAYER+1
		glassne
			icon_state="glass ne"
			density=0
			layer=MOB_LAYER+1
		glassS
			icon_state="glass s"
			layer=MOB_LAYER+1
		bar
			icon_state="bar"
		bar2
			icon_state="bar2"
		bar3
			icon_state="bar3"
		glassnw
			icon_state="glass nw"
			density=0
			layer=MOB_LAYER+1
		glassn
			icon_state="glass n"
			layer=MOB_LAYER+1
		glassse
			icon_state="glass se"
			layer=MOB_LAYER+1
			density=0

	Temple
		TempleFloor
			icon='Turfs Temple.dmi'
			icon_state="floor"
			density=0
		TempleFloor2
			icon='Turfs Temple.dmi'
			icon_state="council"
			density=0
		TempleLB
			icon='Turfs Temple.dmi'
			icon_state="tile"
			density=0
		TempleLT
			icon='Turfs Temple.dmi'
			icon_state="tile3"
			density=0
		TempleRB
			icon='Turfs Temple.dmi'
			icon_state="tile2"
			density=0
		TempleRT
			icon='Turfs Temple.dmi'
			icon_state="tile4"
			density=0
		TempleRoof
			icon='Turfs Temple.dmi'
			icon_state="wall"
			density=1
			opacity=1
			Enter(atom/A)
				if(ismob(A))
					if(FlyOverAble) return ..()
					else return
				else return ..()
		TempleWall
			icon='Turfs Temple.dmi'
			icon_state="council"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		TempleWall2
			icon='Turfs Temple.dmi'
			icon_state="wall2"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1

	Tile
		icon='Tiles.dmi'
		Carpet1
			icon_state="Carpet1"
		Carpet2
			icon_state="Carpet2"
		Carpet3
			icon_state="Carpet3"
		Carpet4
			icon_state="Carpet4"
		Carpet5
			icon_state="Carpet5"
		Carpet6
			icon_state="Carpet6"
		Carpet7
			icon_state="Carpet7"
		Carpet8
			icon_state="Carpet8"
		Tile1
			icon_state="Tile1"
		Tile2
			icon_state="Tile2"
		Tile3
			icon_state="Tile3"
		Tile4
			icon_state="Tile4"
		Tile5
			icon_state="Tile5"
		Tile6
			icon_state="Tile6"
		Tile8
			icon='Natural.dmi'
			icon_state="Wood7"
		Tile9
			icon='Natural.dmi'
			icon_state="Wood17"
		Tile10
			icon_state="Tile10"
		Tile11
			icon_state="Tile11"
		Tile12
			icon_state="Tile12"
		Tile13
			icon_state="Tile13"
		Tile14
			icon_state="Tile14"
		Tile15
			icon='Natural.dmi'
			icon_state="Stone15"
		Tile16
			icon_state="Tile16"
		Tile17
			icon_state="Tile17"
		Tile18
			icon_state="Tile18"
		Tile19
			icon_state="Tile19"
		Tile20
			icon_state="Tile20"
		Tile22
			icon_state="Tile22"
		Tile23
			icon='Natural.dmi'
			icon_state="Wood9"
		Tile24
			icon='Natural.dmi'
			icon_state="Wood12"
		Tile25
			icon_state="Tile25"
		Tile26
			icon_state="Tile26"
		Tile27
			icon_state="Tile27"
		Tile28
			icon='Natural.dmi'
			icon_state="Wood13"
		Tile29
			icon_state="Tile29"
		Tile30
			icon_state="Tile30"
		Tile31
			icon_state="Tile31"
		Tile32
			icon_state="Tile32"
		Tile33
			icon_state="Tile33"
		Tile34
			icon_state="Tile34"
		Tile35
			icon_state="Tile35"
		Tile36
			icon_state="Tile36"
		Tile37
			icon_state="Tile37"
		Tile38
			icon_state="Tile38"
		Tile39
			icon_state="Tile39"
		Tile40
			icon='Natural.dmi'
			icon_state="Wood10"
		Tile41
			icon_state="Tile41"
		Tile42
			icon_state="Tile42"
		Tile43
			icon_state="Tile43"
		Tile44
			icon_state="Tile44"
		Tile45
			icon='Natural.dmi'
			icon_state="Stone10"
		TileWhite icon='White.dmi'
		Tile46
			icon_state="Tile46"
		Tile47
			icon='Natural.dmi'
			icon_state="Wood16"
		Tile48
			icon_state="Tile48"
		Tile49
			icon_state="Tile49"
		Tile50
			icon_state="Tile50"
		Tile51
			icon_state="Tile51"
		Tile52
			icon_state="Tile52"
		Tile53
			icon_state="Tile53"
		Tile54
			icon_state="Tile54"
		Tile55
			icon_state="Tile55"
		Tile56
			icon_state="Tile56"
		Tile57
			icon_state="Tile57"
		Tile58
			icon_state="Tile58"
		Tile59
			icon_state="Tile59"
		Tile60
			icon_state="Tile60"
		Tile61
			icon_state="Tile61"
		Tile62
			icon_state="Tile62"
		Tile63
			icon_state="Tile63"
		Tile64
			icon_state="Tile64"
		Tile65
			icon_state="Tile65"
		Tile66
			icon_state="Tile66"
		Tile67
			icon_state="Tile67"
		Tile68
			icon_state="Tile68"
		Tile69
			icon_state="Tile69"
		Tile70
			icon_state="Tile70"

	Stairs
		icon='Stairs.dmi'
		Stairs1
			icon_state="1"
		Stairs2
			icon_state="2"
		Stairs3
			icon_state="3"
		Stairs4
			icon_state="4"
		Stairs5
			icon_state="5"
		Stairs6
			icon_state="6"
		Stairs7
			icon_state="7"
		Stairs8
			icon_state="8"
		Stairs9
			icon_state="9"
		Stairs10
			icon_state="10"
		Stairs10L
			icon_state="10L"
		Stairs10R
			icon_state="10R"
		Stairs11 // more of a rope ladder than a stair but eh
			icon_state="11"

	UndergroundCaves
		isSpecial=1
		destroyable=0
		icon='CaveEntrances.dmi'
		icon_state="5"
		Underground_E_entrance
			name = "ECaveEntrance1"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(156,299,23)
		Underground_E_entrance2
			name = "ECaveEntrance2"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(17,206,23)
		Underground_E_entrance3
			name = "ECaveEntrance3"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(366,248,23)
		Underground_E_Exit
			name = "ECaveExit1"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(267,388,1)
		Underground_E_Exit2
			name = "ECaveExit2"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(46,353,1)
		Underground_E_Exit3
			name = "ECaveExit3"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(476,346,1)
		Underground_V_Entrance
			name = "VCaveEntrance1"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(157,299,22)
		Underground_V_Exit
			name = "VCaveExit1"
			Enter(mob/M)
				if(istype(M))
					M.loc=locate(142,285,3)

	Wall
		icon='Walls.dmi'
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
		Wall1
			icon_state="Wall1"
		Wall2
			icon_state="Wall2"
		Wall3
			icon_state="Wall3"
		Wall4
			icon_state="Wall4"
		Wall5
			icon_state="Wall5"
		Wall6
			icon_state="Wall6"
		Wall7
			icon_state="Wall7"
		Wall8
			icon_state="Wall8"
		Wall9
			icon_state="Wall9"
		Wall10
			icon_state="Wall10"
		Wall11
			icon_state="Wall11"
		Wall12
			icon_state="Wall12"
		Wall13
			icon_state="Wall13"
		Wall14
			icon_state="Wall14"
		Wall15
			icon_state="Wall15"
		Wall16
			icon_state="Wall16"
		Wall17
			icon_state="Wall17"
		Wall18
			icon_state="Wall18"
		Wall19
			icon_state="Wall19"
		Wall20
			icon_state="Wall20"
		Wall21
			icon_state="Wall21"
		Wall22
			icon_state="Wall22"
		Wall23
			icon_state="Wall23"
		Wall24
			icon_state="Wall24"
		Wall25
			icon_state="Wall25"
		Wall26
			icon_state="Wall26"
		Wall27
			icon_state="Wall27"
		Wall28
			icon_state="Wall28"
		Wall29
			icon_state="Wall29"
		Wall30
			icon_state="Wall30"
		Wall31
			icon_state="Wall31"
		Wall32
			icon_state="Wall32"
		Wall33
			icon_state="Wall33"
		Wall34
			icon_state="Wall34"
		Wall35
			icon_state="Wall35"
		Wall36
			icon_state="Wall36"
		Wall37
			icon_state="Wall37"
		Wall38
			icon_state="Wall38"
		Wall39
			icon_state="Wall39"
		Wall40
			icon_state="Wall40"
		Wall41
			icon_state="Wall41"
		Wall42
			icon_state="Wall42"
		Wall43
			icon_state="Wall43"
		Wall44
			icon_state="Wall44"
		Wall45
			icon_state="Wall45"
		Wall46
			icon_state="Wall46"
		Wall47
			icon_state="Wall47"
		Wall48
			icon_state="Wall48"
		Wall49
			icon_state="Wall49"
		Wall50
			icon_state="Wall50"
		Wall51
			icon_state="Wall51"
		Wall52
			icon_state="Wall52"
		Wall53
			icon_state="Wall53"
		Wall54
			icon_state="Wall54"
		Wall55
			icon_state="Wall55"
		Wall56
			icon_state="Wall56"
		Wall57
			icon_state="Wall57"
		Wall58
			icon_state="Wall58"

	Water
		icon='Waters.dmi'
		Water=1
		destroyable=0
		Enter(atom/movable/O, atom/oldloc)
			return testWaters(O)
		Water1
			icon_state="1"
		Water2
			icon_state="2"
		Water3
			icon_state="3"
		Water5
			icon_state="5"
		Water6
			icon_state="6"
		Water7
			icon_state="7"
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
			//lava can do damage in the future but for right now with how EZ flight still is we can add it in the early-functions update.
		Water8
			icon_state="8"
		Water9
			icon_state="9"
		Water10
			icon_state="10"
		Water11
			icon_state="11"
		Water12
			icon_state="12"
		Water13
			icon_state="13"
		WaterFall
			icon_state="waterfall"
			layer=MOB_LAYER+1
		WaterFall1
			icon_state="waterfall1"
			layer=MOB_LAYER+1
		WaterFall2
			icon_state="waterfall2"
			layer=MOB_LAYER+1
		WaterReal
			icon_state="waterreal"

	decor
		Savable=0
		layer=4
		Rock
			icon='Turfs 2.dmi'
			icon_state="rock"
		LargeRock
			density=1
			icon='turfs.dmi'
			icon_state="rockl"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		firewood
			icon='roomobj.dmi'
			icon_state="firewood"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		WaterRock
			density=1
			icon='turfs.dmi'
			icon_state="waterrock"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		HellRock
			density=1
			icon='turfs.dmi'
			icon_state="hellrock1"
			layer=2
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		HellRock2
			density=1
			icon='turfs.dmi'
			icon_state="hellrock2"
			layer=2
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		HellRock3
			density=1
			icon='turfs.dmi'
			icon_state="hellrock3"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		LargeRock2
			density=1
			icon='turfs.dmi'
			icon_state="terrainrock"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Rock1
			icon='Turf 50.dmi'
			icon_state="1.9"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Rock2
			icon='Turf 50.dmi'
			icon_state="2.0"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Stalagmite
			density=1
			icon='Turf 57.dmi'
			icon_state="44"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Fence
			density=1
			icon='Turf 55.dmi'
			icon_state="woodenfence"
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Rock3
			icon='Turf 57.dmi'
			icon_state="19"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Rock4
			icon='Turf 57.dmi'
			icon_state="20"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Flowers
			icon='Turf 52.dmi'
			icon_state="flower bed"
		Rock6
			icon='Turf 57.dmi'
			icon_state="64"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Bush1
			icon='Turf 57.dmi'
			icon_state="bush"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Whirlpool icon='Whirlpool.dmi'
		Bush2
			icon='Turf 57.dmi'
			icon_state="bushbig1"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Bush3
			icon='Turf 57.dmi'
			icon_state="bushbig2"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Bush4
			icon='Turf 57.dmi'
			icon_state="bushbig3"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Bush5
			icon='Turf 50.dmi'
			icon_state="2.1"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		SnowBush
			icon='Turf 57.dmi'
			icon_state="snowbush"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant12
			icon='Plants.dmi'
			icon_state="plant1"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Table7
			icon='Turf3.dmi'
			icon_state="168"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Table8
			icon='Turf3.dmi'
			icon_state="169"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant11
			icon='Plants.dmi'
			icon_state="plant2"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant10
			icon='Plants.dmi'
			icon_state="plant3"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant1
			density=1
			icon='palmtree20162.png'
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant16
			icon='roomobj.dmi'
			icon_state="flowers"
		Plant15
			icon='roomobj.dmi'
			icon_state="flowers2"
		Plant2
			icon='Turf3.dmi'
			icon_state="plant"
		Plant3
			icon='turfs.dmi'
			icon_state="stump"
		Plant4
			icon='Turf2.dmi'
			icon_state="plant2"
		Plant5
			icon='Turf2.dmi'
			icon_state="plant3"
		Plant13
			icon='turfs.dmi'
			icon_state="bush"
		Plant14
			icon='Turfs 1.dmi'
			icon_state="frozentree"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant18
			icon='Trees.dmi'
			icon_state="Dead Tree1"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant6
			icon='Turfs1.dmi'
			icon_state="1"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant20
			icon='Turfs1.dmi'
			icon_state="2"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant19
			icon='Turfs1.dmi'
			icon_state="3"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant7
			icon='Trees.dmi'
			icon_state="Tree1"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant8
			icon='Turfs 1.dmi'
			icon_state="smalltree"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Plant9
			icon='Turfs 2.dmi'
			icon_state="treeb"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Table9
			icon='Turf 52.dmi'
			icon_state="small table"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		bridgeW
			icon='Misc.dmi'
			icon_state="W"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Chest
			icon='Turf3.dmi'
			icon_state="161"
		HellPot
			icon='turfs.dmi'
			icon_state="flamepot2"
			density=1
			New()
				..()
				var/image/A=image(icon='turfs.dmi',icon_state="flamepot1",pixel_y=32)
				overlays.Add(A)
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Book
			icon='Turf3.dmi'
			icon_state="167"
		Light
			icon='Space.dmi'
			icon_state="light"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Glass
			icon='Space.dmi'
			icon_state="glass1"
			density=1
			layer=MOB_LAYER+1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Table6
			icon='turfs.dmi'
			icon_state="Table"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Table5
			icon='Turfs 2.dmi'
			icon_state="tableL"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Log
			density=1
			New()
				..()
				var/image/A=image(icon='Turf 57.dmi',icon_state="log1",pixel_x=-16)
				var/image/B=image(icon='Turf 57.dmi',icon_state="log2",pixel_x=16)
				overlays.Add(A,B)
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		FancyCouch
			New()
				..()
				var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
				var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
				overlays.Add(A,B)
		Table3
			icon='Turfs 2.dmi'
			icon_state="tableR"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Table4
			icon='Turfs 2.dmi'
			icon_state="tableM"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Jugs
			icon='Turf 52.dmi'
			icon_state="jugs"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Hay
			icon='Turf 52.dmi'
			icon_state="hay"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Clock
			icon='Turf 52.dmi'
			icon_state="clock"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Torch3
			icon='Turf 57.dmi'
			icon_state="83"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1

		Table9
			icon='Turf 52.dmi'
			icon_state="small table"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Waterpot
			icon='Turf 52.dmi'
			icon_state="water pot"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Log
			density=1
			New()
				..()
				var/image/A=image(icon='Turf 57.dmi',icon_state="log1",pixel_x=-16)
				var/image/B=image(icon='Turf 57.dmi',icon_state="log2",pixel_x=16)
				overlays.Add(A,B)
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		FancyCouch
			New()
				..()
				var/image/A=image(icon='Turf 52.dmi',icon_state="couch left",pixel_x=-16)
				var/image/B=image(icon='Turf 52.dmi',icon_state="couch right",pixel_x=16)
				overlays.Add(A,B)
		Stove
			icon='Turf 52.dmi'
			icon_state="stove"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Drawer
			icon='Turf 52.dmi'
			icon_state="drawers"
			density=1
			New()
				..()
				var/image/A=image(icon='Turf 52.dmi',icon_state="drawers top",pixel_y=32)
				overlays.Add(A)
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Bed
			icon='Turf 52.dmi'
			icon_state="bed top"
			New()
				..()
				var/image/A=image(icon='Turf 52.dmi',icon_state="bed",pixel_y=-32)
				overlays.Add(A)
		Torch1
			icon='Turf2.dmi'
			icon_state="168"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Torch2
			icon='Turf2.dmi'
			icon_state="169"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Torch3
			icon='Turf 57.dmi'
			icon_state="83"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		barrel
			icon='Turfs 2.dmi'
			icon_state="barrel"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		chair
			icon='turfs.dmi'
			icon_state="Chair"
		box2
			icon='Turfs 5.dmi'
			icon_state="box"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		HellGate
			icon='Hell gate.dmi'
			icon_state=""
			layer=2
		HellStatue1
			icon='Hell Statue.dmi'
			icon_state=""
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		HellStatue2
			icon='Hell Statue.dmi'
			icon_state="2"
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		PondBlood
			icon='Pond Blood.dmi'
			icon_state=""
			density=1
			Enter(mob/M)
				if(istype(M,/mob))
					if(M.flight) return 1
					else return
				else return 1
		Ladder
			icon='Turf1.dmi'
			icon_state="ladder"
			density=0
		Orb
			icon='Turf1.dmi'
			icon_state="spirit"
			density=0

atom/var
	Builder
	Savable
obj/Surf
	canGrab=0
	layer=2
	Savable=0
	New()
		..()
		spawn(1) if(src) for(var/obj/A in view(0,src)) if(A!=src) if(loc==initial(loc)) del(src)
	icon='Surf.dmi'
	Water1Surf
		icon_state="7"
	Water1SurfN
		icon_state="7N"
	Water2Surf
		icon_state="2"
	Water2Surf2
		icon_state="2N"
	Water3Surf
		icon_state="3"
	Water3Surf2
		icon_state="3N"
	Water5Surf
		icon_state="5"
	Water5SurfN
		icon_state="5N"
	Water7Surf
		icon_state="8"
	Water7SurfN
		icon_state="8N"
	Water8Surf
		icon_state="4"
	Water8Surf2
		icon_state="4N"
	Water9Surf
		icon_state="6"
	Water9Surf2
		icon_state="6N"
	Water10Surf
		icon_state="1"
	Water10SurfN
		icon_state="1N"
	Water11Surf
		icon_state="11"
	Water11SurfN
		icon_state="11N"