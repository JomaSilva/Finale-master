//So the problem with many things is that bounding boxes can be a pain in the ass to do. SO, let's make a system that simplifies it.

/obj/bounding_box
	//Climax specific anti-object variables, somewhat unneccessary?.
	IsntAItem = 1
	canGrab = 0
	//To ensure nobody can 'find' this.
	mouse_opacity = 0
	invisibility = 101
	//Still might show up on /obj lists. Eh.
	density = 0
	var/id
	var/atom/movable/container = null
	New(loc,list/L[2],cont)
		..()
		if(cont)
			container = cont
			for(var/atom/movable/O in bounds(src))
				container.BBCross(src,O)
		return set_bounds(L)
	Del()
		if(container)
			for(var/atom/movable/O in bounds(src))
				container.BBUnCross(src,O)
		..()

	proc/set_bounds(list/L[2])//probably not laggy anyways but still
		set waitfor = 0
		set background = 1
		//don't set these if you disagree with the meth'
		if(!isnull(L[1]))
			bound_width = 32 * L[1]
		if(!isnull(L[2]))
			bound_height =  32 * L[2]
		if(bound_width != 32)
			bound_x = round((32 - (32 * L[1])) / 2,1)
		if(bound_height != 32)
			bound_y = round((32 - (32 * L[2])) / 2,1)
		return src

	Crossed(O)
		if(container)
			container.BBCross(src,O)
		..()
	Uncrossed(O)
		if(container)
			container.BBUnCross(src,O)
		..()

atom/movable
	var/list/BB = list()
	proc
		BBCross(obj/BB,argl)
			. = TRUE
		BBUnCross(obj/BB,argl)
			. = TRUE
//do if(BB.len) bounds_move() or let this proc do it instead.
		trigg_bounds()
			if(BB.len) bounds_move()
		bounds_move()
			set waitfor = 0
			set background = 1
			for(var/obj/A in BB)
				A.Move(loc)
		bounding_box_create(loc,list/scaler)
			BB += new/obj/bounding_box(loc,scaler,src)