#define TURF_PLANE 0 //was -1 (for a lighting system that isn't compiled in); plane -1 turfs render black on BYOND 516, so keep them on the default plane
turf
	plane = TURF_PLANE
	New()
		..()
		//if(opacity == 1) opaque = 1
		turf_list += src
		var/area/A = loc
		A.my_turf_list += src
		if(!density||!Water)
			if(!istype(src,/turf/build) || proprietor)
				if(!istype(src,/turf/Other/Stars))
					A.rand_one_list.Add(src)
				if(!istype(src,/turf/Other/Sky2))
					A.rand_two_list.Add(src)
		if(isHD&&getWidth&&getHeight)
			spawn autofill()
	Del()
		turf_list -= src
		..()
