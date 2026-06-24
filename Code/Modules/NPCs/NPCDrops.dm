mob/var/list/mobDrops = new/list
obj/var
	dropProbability = 1

mob/proc/NPCDrop()
	for(var/obj/N in src.contents)
		if(istype(N,/obj/items/Equipment))
			var/obj/items/Equipment/M=N
			if(M.equipped)
				M.Wear(src)
		if(prob(15*N.dropProbability))
			sleep(1)
			N.loc = locate(src.x,src.y,src.z)
		sleep(1)