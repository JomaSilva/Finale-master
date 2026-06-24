mob/var
	tmp
		west=0
		north=0
		east=0
		south=0
		wpress=0
		npress=0
		epress=0
		spress=0
mob/default/verb
	Face_North()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=NORTH
	Face_South()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=SOUTH
	Face_West()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=WEST
	Face_East()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=EAST
	Face_Northwest()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=NORTHWEST
	Face_Northeast()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=NORTHEAST
	Face_Southwest()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=SOUTHWEST
	Face_Southeast()
		set hidden = 1
		set category="Skills"
		if(!turnlock) src.dir=SOUTHEAST
mob/verb
	unorth()
		set name="unorth"
		set hidden=1
		set instant=1
		if(!turnlock)
			src.north=1
			src.npress=1
	usouth()
		set hidden=1
		set instant=1
		if(!turnlock)
			src.south=1
			src.spress=1

	ueast()
		set hidden=1
		set instant=1
		if(!turnlock)
			src.east=1
			src.epress=1
	uwest()
		set hidden=1
		set instant=1
		if(!turnlock)
			src.west=1
			src.wpress=1
	northup()
		set hidden=1
		set instant=1
		if(!turnlock||npress) src.north=0
	southup()
		set hidden=1
		set instant=1
		if(!turnlock||spress) src.south=0
	eastup()
		set hidden=1
		set instant=1
		if(!turnlock||epress) src.east=0
	westup()
		set hidden=1
		set instant=1
		if(!turnlock||wpress) src.west=0

mob/proc
	stepAction()
		if(north)
			if(west) return 9
			else if(east) return 5
			else return 1
		else if(south)
			if(west) return 10
			else if(east) return 6
			else return 2
		else if(west) return 8
		else if(east) return 4
		else return 0