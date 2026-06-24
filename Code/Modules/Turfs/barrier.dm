#define ALL_DIR list(1,2,3,4,5,6,7,8,9,10,11,12)

obj
	var/list/NOENTER
	var/list/NOLEAVE
	var/tall = 0
	var/fragile = 0 //can be hurt?
	var/maxarmor = 1 //DETERMINED BY PEAK TECH VALUE OF CREATOR
	var/armor = 1 //CURRENT ARMOR USED FOR DEFENSE
	var/superarmor = 1 //AMOUNT OF DAMAGE WHOLESALE IGNORED (always anything below 75% of cap)
	//todo: add modifiable turf replacement
	var/createDust = 1
	var/tmp/isdestroying = 0

	proc/selectivecollide(mob/M)
		if(tall == 0 && M.isflying)
			return FALSE
		if(M.dir in NOENTER)
			return TRUE
		return FALSE
	proc/selectiveexit(mob/M)
		if(tall == 0 && M.isflying)
			return FALSE
		if(M.dir in NOLEAVE)
			return TRUE
		return FALSE

	proc/superCalc()
		superarmor = 0.75*maxarmor
	proc/takeDamage(var/D)
		superCalc()
		if(D>superarmor)
			armor-=(D-superarmor)
		armor = max(0,armor)
		testDestroy()
	proc/healDamage(var/D)
		if((D+armor)<maxarmor)
			armor+=D
		else
			armor=maxarmor
	proc/testDestroy()
		if(armor<=0&&!isdestroying)
			isdestroying=1
			if(isturf(loc))
				emit_Sound('kiplosion.wav')
				if(createDust == 1)
					createDust(loc,2)
					spawnExplosion(location=loc,strength=(0.5*maxarmor),radius=1)
			deleteMe(src)

obj/barrier
	icon='ForceWall.dmi'
	NOENTER=ALL_DIR
	opacity = 1
	tall = 1
	fragile = 1
	canGrab=0
	IsntAItem=1
obj/barrier/Edges // -- barrier typing will be the most basal type of destroyable barriers
	icon='Edges.dmi'
	canbuild=1
	Savable=0
	opacity = 0
	tall=0
	fragile = 1
	New()
		..()
		spawn(1) if(src) if(!Builder) for(var/turf/A in view(0,src)) if(A.Builder) del(src)
		spawn(1) if(src) for(var/obj/A in view(0,src)) if(!istype(A,/obj/barrier)) if(loc==initial(loc)) del(src)
	Edge1N
		icon_state="1"
		dir=NORTH
		NOENTER=list(SOUTH,SOUTHWEST,SOUTHEAST)
		NOLEAVE=list(NORTH,NORTHWEST,NORTHEAST)
	Edge1W
		icon_state="1"
		dir=WEST
		NOENTER=list(EAST,SOUTHEAST,NORTHEAST)
		NOLEAVE=list(WEST,SOUTHWEST,NORTHWEST)
	Edge1E
		icon_state="1"
		dir=EAST
		NOENTER=list(WEST,SOUTHWEST,NORTHWEST)
		NOLEAVE=list(EAST,SOUTHEAST,NORTHEAST)
	Edge1S
		icon_state="1"
		dir=SOUTH
		NOENTER=list(NORTH,NORTHWEST,NORTHEAST)
		NOLEAVE=list(SOUTH,SOUTHWEST,SOUTHEAST)
	Edge2N
		icon_state="2"
		dir=NORTH
		NOENTER=list(SOUTH,SOUTHWEST,SOUTHEAST)
		NOLEAVE=list(NORTH,NORTHWEST,NORTHEAST)
	Edge2W
		icon_state="2"
		dir=WEST
		NOENTER=list(EAST,SOUTHEAST,NORTHEAST)
		NOLEAVE=list(WEST,SOUTHWEST,NORTHWEST)
	Edge2E
		icon_state="2"
		dir=EAST
		NOENTER=list(WEST,SOUTHWEST,NORTHWEST)
		NOLEAVE=list(EAST,SOUTHEAST,NORTHEAST)
	Edge2S
		icon_state="2"
		dir=SOUTH
		NOENTER=list(NORTH,NORTHWEST,NORTHEAST)
		NOLEAVE=list(SOUTH,SOUTHWEST,SOUTHEAST)
	Edge3N
		icon_state="3"
		dir=NORTH
		NOENTER=list(SOUTH,SOUTHWEST,SOUTHEAST)
		NOLEAVE=list(NORTH,NORTHWEST,NORTHEAST)
	Edge3W
		icon_state="3"
		dir=WEST
		NOENTER=list(EAST,SOUTHEAST,NORTHEAST)
		NOLEAVE=list(WEST,SOUTHWEST,NORTHWEST)
	Edge3E
		icon_state="3"
		dir=EAST
		NOENTER=list(WEST,SOUTHWEST,NORTHWEST)
		NOLEAVE=list(EAST,SOUTHEAST,NORTHEAST)
	Edge3S
		icon_state="3"
		dir=SOUTH
		NOENTER=list(NORTH,NORTHWEST,NORTHEAST)
		NOLEAVE=list(SOUTH,SOUTHWEST,SOUTHEAST)
	Edge4N
		icon_state="4"
		dir=NORTH
		NOENTER=list(SOUTH,SOUTHWEST,SOUTHEAST)
		NOLEAVE=list(NORTH,NORTHWEST,NORTHEAST)
	Edge4W
		icon_state="4"
		dir=WEST
		NOENTER=list(EAST,SOUTHEAST,NORTHEAST)
		NOLEAVE=list(WEST,SOUTHWEST,NORTHWEST)
	Edge4E
		icon_state="4"
		dir=EAST
		NOENTER=list(WEST,SOUTHWEST,NORTHWEST)
		NOLEAVE=list(EAST,SOUTHEAST,NORTHEAST)
	Edge4S
		icon_state="3"
		dir=SOUTH
		NOENTER=list(NORTH,NORTHWEST,NORTHEAST)
		NOLEAVE=list(SOUTH,SOUTHWEST,SOUTHEAST)
	Edge5N
		icon_state="5"
		dir=NORTH
		NOENTER=list(SOUTH,SOUTHWEST,SOUTHEAST)
		NOLEAVE=list(NORTH,NORTHWEST,NORTHEAST)
	Edge5W
		icon_state="5"
		dir=WEST
		NOENTER=list(EAST,SOUTHEAST,NORTHEAST)
		NOLEAVE=list(WEST,SOUTHWEST,NORTHWEST)
	Edge5E
		icon_state="5"
		dir=EAST
		NOENTER=list(WEST,SOUTHWEST,NORTHWEST)
		NOLEAVE=list(EAST,SOUTHEAST,NORTHEAST)
	Edge5S
		icon_state="5"
		dir=SOUTH
		NOENTER=list(NORTH,NORTHWEST,NORTHEAST)
		NOLEAVE=list(SOUTH,SOUTHWEST,SOUTHEAST)
	Edge6N
		icon_state="6"
		dir=NORTH
		NOENTER=list(SOUTH,SOUTHWEST,SOUTHEAST)
		NOLEAVE=list(NORTH,NORTHWEST,NORTHEAST)
	Edge6W
		icon_state="6"
		dir=WEST
		NOENTER=list(EAST,SOUTHEAST,NORTHEAST)
		NOLEAVE=list(WEST,SOUTHWEST,NORTHWEST)
	Edge6E
		icon_state="6"
		dir=EAST
		NOENTER=list(WEST,SOUTHWEST,NORTHWEST)
		NOLEAVE=list(EAST,SOUTHEAST,NORTHEAST)
	Edge6S
		icon_state="6"
		dir=SOUTH
		NOENTER=list(NORTH,NORTHWEST,NORTHEAST)
		NOLEAVE=list(SOUTH,SOUTHWEST,SOUTHEAST)