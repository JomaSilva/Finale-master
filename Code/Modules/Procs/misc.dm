var/list/dir_to_angle = list("1" = 90, "4" = 0,"2" = 270,"8" = 180,"5" = 45,"6" = 315,"10" = 225,"9" = 135) //idea by Ter13
proc/turn_towards(atom/movable/ref, atom/targ, angle=45) //step, courtesy of Hiead: http://www.byond.com/forum/post/134338
	if(!angle || !ref || !targ || !istype(ref,/atom))
		return 0
	. = get_dir(ref, targ) //the dot is a inbuilt variable to verbs/procs. in this case, the period is set to the 'target' direction
	angle = round(angle,45)
	if(ref.dir == .) return TRUE
	else
		var/endAngle = dir_to_angle["[.]"]
		var/startAngle = dir_to_angle["[ref.dir]"]
		if(!startAngle + 180 <= endAngle)
			angle = -angle
		ref.dir = turn(ref.dir, angle)
		return TRUE

proc/cutout(text1,text2) //faulty proc, need to fix it.
	. = ""
	if(findtext(text1,text2)!=1)
		. = copytext(text1,1,findtext(text1,text2))
		. += copytext(text1,findlasttext(text1,text2),0)
	else
		. = copytext(text1,findlasttext(text1,text2),0)
	return .

proc/rand_dir()//will just pick a random dir. dir = rand(1,8) doesn't work because directions (in order of NSEW) are 1 (N) 2 (S) 4 (E) 8 (W). Diagonals are additions of the two directions.
//so NE is 1+4 (5) NW is 1+8 (9) SE 2+4 (6) SW 2+8(10)
	switch(rand(1,8))
		if(1) return NORTH
		if(2) return NORTHEAST
		if(3) return EAST
		if(4) return SOUTHEAST
		if(5) return SOUTH
		if(6) return SOUTHWEST
		if(7) return WEST
		if(8) return NORTHWEST

proc/rand_dir_in_dir(dir) //will pick a direction (diagonally forward left/right or forward) Ter13 would be disappointed...
	switch(dir)
		if(NORTH) return pick(NORTH,NORTHEAST,NORTHWEST)
		if(SOUTH) return pick(SOUTH,SOUTHWEST,SOUTHEAST)
		if(EAST) return pick(EAST,NORTHEAST,SOUTHEAST)
		if(WEST) return pick(WEST,SOUTHWEST,NORTHWEST)
		if(NORTHEAST) return pick(NORTH,NORTHEAST,EAST)
		if(NORTHWEST) return pick(NORTH,WEST,NORTHWEST)
		if(SOUTHEAST) return pick(SOUTH,SOUTHEAST,EAST)
		if(SOUTHWEST) return pick(SOUTH,SOUTHWEST,WEST)