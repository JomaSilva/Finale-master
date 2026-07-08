#define TURF_PLANE 0 //was -1 (for a lighting system that isn't compiled in); plane -1 turfs render black on BYOND 516, so keep them on the default plane
//z's dos POOLS procedurais ("z" -> 1): os turfs deles sao RECRIADOS aos 250k a cada
//regeneracao de planeta/setor -- ficam FORA das listas de area (poluiam my_turf_list/
//rand lists de areas alheias e nunca saiam = leak). A antiga turf_list global (todos os
//turfs do mundo) foi DELETADA: o unico consumidor era um verb de debug inutilizavel, e o
//"turf_list -= src" no Del varria ~10M de entradas POR TURF substituido (162s por planeta)
var/list/pspace_pool_z = list()

turf
	plane = TURF_PLANE
	New()
		..()
		if(isHD&&getWidth&&getHeight)
			spawn autofill()
		if(pspace_pool_z["[z]"]) return //turf de pool procedural: fora das listas de area
		var/area/A = loc
		A.my_turf_list += src
		if(!density||!Water)
			if(!istype(src,/turf/build) || proprietor)
				if(!istype(src,/turf/Other/Stars))
					A.rand_one_list.Add(src)
				if(!istype(src,/turf/Other/Sky2))
					A.rand_two_list.Add(src)
