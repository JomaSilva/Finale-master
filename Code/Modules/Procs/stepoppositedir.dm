proc/step_opposite(var/mob/Ref,var/Moved,var/Speed)
//meant to be used as a way to step in the opposite direction away from a mob
	if(!istype(Moved,/obj/)&&!istype(Moved,/mob/))
		return FALSE
	if(!istype(Ref,/obj/)&&!istype(Ref,/mob/))
		return FALSE
	var/oppositedir
	switch(Ref.dir)
		if(NORTH)
			oppositedir = SOUTH
		if(SOUTH)
			oppositedir = NORTH
		if(EAST)
			oppositedir = WEST
		if(WEST)
			oppositedir = EAST
		if(NORTHWEST)
			oppositedir = SOUTHEAST
		if(SOUTHEAST)
			oppositedir = NORTHWEST
		if(NORTHEAST)
			oppositedir = SOUTHWEST
		if(SOUTHWEST)
			oppositedir = NORTHEAST
	if(step(Moved,oppositedir,Speed))
		return TRUE
	else return FALSE

proc/get_opposite_dir(var/atom/movable/Ref)//like above, except only used to get the direction opposite the current direction
	var/oppositedir
	switch(Ref.dir)
		if(NORTH)
			oppositedir = SOUTH
		if(SOUTH)
			oppositedir = NORTH
		if(EAST)
			oppositedir = WEST
		if(WEST)
			oppositedir = EAST
		if(NORTHWEST)
			oppositedir = SOUTHEAST
		if(SOUTHEAST)
			oppositedir = NORTHWEST
		if(NORTHEAST)
			oppositedir = SOUTHWEST
		if(SOUTHWEST)
			oppositedir = NORTHEAST
	return oppositedir