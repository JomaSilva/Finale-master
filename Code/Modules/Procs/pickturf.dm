proc/pickTurf(var/area/targetArea,var/Mode)
	set background = 1
	. = null
	switch(Mode)
		if(1)
			if(!targetArea.rand_one_list.len)
				sleep(-1)
				if(!targetArea.rand_one_list.len) return
			var/turf/A = pick(targetArea.rand_one_list)
			if(isturf(A))
				. = A
		if(2)
			if(!targetArea.rand_two_list.len)
				sleep(-1)
				if(!targetArea.rand_two_list.len) return
			var/turf/A = pick(targetArea.rand_two_list)
			if(isturf(A))
				. = A
	if(isturf(.) && !isnull(.))
		return .
	else return FALSE

proc/tele_rand_turf_in_view(mob/u,range)
	set background = 1
	var/turf/pickedTurf = null
	var/turflist = list()
	for(var/turf/T in view(range,u))
		if(!T.density)
			turflist+=T
	if(!length(turflist)) return FALSE //nenhum turf valido (ex.: preso entre paredes): pick() de lista vazia estourava
	return pickedTurf = pick(turflist)

proc/tele_rand_turf_at_range(mob/u,range)
	set background = 1
	var/turf/pickedTurf = null
	var/turflist = list()
	for(var/turf/T in view(range,u))
		if(!T.density && get_dist(u,T)>=range)
			turflist+=T
	if(!length(turflist)) return FALSE //sem turf na distancia pedida: pick() vazio estourava (12x no log)
	return pickedTurf = pick(turflist)