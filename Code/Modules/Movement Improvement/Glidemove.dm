//Source code: http://www.byond.com/forum/?post=1573076 by Ter13
///*
#define MOVE_SLIDE 1
#define MOVE_JUMP 2
#define MOVE_TELEPORT 4

#define TILE_WIDTH  32
#define TILE_HEIGHT 32
#define TICK_LAG    0.25 //set to (10 / world.fps) a define is faster, though

atom/movable
	appearance_flags = LONG_GLIDE //make diagonal and horizontal moves take the same amount of time
	var
		move_delay = 0 //how long between self movements this movable should be forced to wait.
		tmp
			next_move = 0 //the world.time value of the next allowed self movement
			last_move = 0 //the world.time value of the last self movement
			move_dir = 0 //the direction of the current/last movement
			move_flags = 0 //the type of the current/last movement
			area/current_area = null //current area
			isStepping = 0
			CanMoveInFrozenTime = 0
	Move(atom/NewLoc,Dir=0)
		var/time = world.time
		if(next_move>time)
			return 0
		if(istype(src,/obj/attack/blast))
			if(src:WaveAttack)
				plane = 6
		if(!NewLoc) //if the new location is null, treat this as a failed slide and an edge bump.
			move_dir = Dir
			move_flags = MOVE_SLIDE
			isStepping = 0
		else if(isturf(loc)&&isturf(NewLoc)) //if this is a movement between two turfs
			isStepping = 1
			var/dx = NewLoc.x - x //get the distance delta
			var/dy = NewLoc.y - y
			if(z==NewLoc.z&&abs(dx)<=1&&abs(dy)<=1) //if only moving one tile on the same layer, mark the current move as a slide and figure out the move_dir
				move_dir = 0
				move_flags = MOVE_SLIDE
				if(dx>0) move_dir |= EAST
				else if(dx<0) move_dir |= WEST
				if(dy>0) move_dir |= NORTH
				else if(dy<0) move_dir |= SOUTH
			else //jumping between z levels or more than one tile is a jump with no move_dir
				move_dir = 0
				move_flags = MOVE_JUMP
				isStepping = 0
		else //moving into or out of a null location or another atom other than a turf is a teleport with no move_dir
			move_dir = 0
			move_flags = MOVE_TELEPORT
			isStepping = 0
		glide_size = TILE_WIDTH / max(move_delay,TICK_LAG) * TICK_LAG //set the glide size
		. = ..() //perform the movement
		isStepping = 0
		last_move = time //set the last movement time
		if(.)
			isStepping = 0
			next_move = time+move_delay
			if(BB.len)
				bounds_move()
		else
			isStepping = 0
mob
	Move(atom/NewLoc,Dir=0)
		if(isobj(ship))
			ship.Move(NewLoc,Dir)
		..()
//So: about this 'pixelOBJ'
//Reason it exists: pixelOBJ is used to force the entire project into pixel-movement at runtime due to its smaller stepsize.
//This makes shit smoother and we don't have to change from tile movement.
obj/pixelOBJ
	step_size = 4

//*/