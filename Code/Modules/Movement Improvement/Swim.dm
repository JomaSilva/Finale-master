mob/var/flight=0
mob/var
	flightspeed
	swim=0
mob/verb
	Swim()
		set category="Skills"
		usr.Deoccupy()
		var/turf/T = get_step(usr,dir)
		if(T.Water&&!swim&&!boat)
			if(!usr.KO)
				usr.flight=0
				usr<<"You start to swim."
				usr.swim=1
				step(usr,usr.dir)
				usr.density=1
				if(usr.Savable) usr.icon_state="Flight"
		else if(swim)
			usr.swim=0
			if(usr.Savable) usr.icon_state=""
			usr<<"You stop swimming."
		else
			usr<<"You can't swim there!"

turf
	proc/testWaters(var/M)
		var/mob/B=locate() in contents
		if(istype(M,/mob))
			if(B) return 0
			if(M:flight|M:swim|M:KB|M:boat) return 1
			else return 0
		if(istype(M,/obj))
			if(B)
				return 0
			else return 1
		else
			KiWater()
			return 1