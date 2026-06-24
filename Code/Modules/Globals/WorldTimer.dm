var
	globalcycle=0
	//globalcycle increments by 1. 10 resets it.
proc/WorldTime()
	set waitfor = 0
	globalcycle += 1
	if(globalcycle >= 11) globalcycle = 1
	spawn
		var/zombies = 0
		for(var/mob/npc/Enemy/Zombie/Z in mob_list)
			zombies+=1
			sleep(1)
		if(zombies&&zombies<100)
			var/mob/exampleZombie
			for(var/mob/npc/Enemy/Zombie/Z in mob_list)
				exampleZombie = Z
				break
			if(ismob(exampleZombie))
				createZombies(10,exampleZombie.BP,exampleZombie.x,exampleZombie.y,exampleZombie.z)
	if(globalcycle == 5)
		if(area_outside_list.len)
			var/list/tA_outside_list = list()
			for(var/area/tA in area_outside_list) //only about 10-15~ or so areas in this list at a time, pretty lag-free.
				if(tA.CanHellstar && !tA.IsHellstar) tA_outside_list += tA
			var/area/tA = pick(tA_outside_list)
			tA.IsHellstar = 1
	spawn(max((6000 / Yearspeed),100))
		WorldTime()
		//every 10 or so minutes


proc/Restart()
	world<<"<b><font color=yellow><font size=4>Restarting World"
	for(var/mob/M in player_list)
		if(M.client)
			M.clearbuffs()
			M.DoLogoutStuff()
			M.Save()
	for(var/obj/dungeon/D in dun_list)
		D.dungeon_delete()
	SaveWorld()
	world<<"<b><font color=yellow><font size=4>Rebooting..."
	world.Reboot()