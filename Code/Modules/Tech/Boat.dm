mob/var/boat=0
obj/Boat
	density=1
	SaveItem=1
	plane = 6
	cantblueprint=0
	icon='Boat.dmi'
	fragile = 1
	move_delay = 0.1
	var/Speed=1 //divisor of the probability of delay (*100) the pod will have when it moves.
	var/tmp/mob/pilot = null
	var/eject = 0
	var/mob/M
	var/tmp/inuse = 0
	verb
		Sail()
			set category=null
			set src in view(1)
			set background = 1
			var/turf/T = get_step(usr,dir)
			if(T.Water&&!usr.boat&&!inuse)
				usr<<"Anchors away! You set sail!"
				usr.boat=1
				inuse=1
				step(usr,usr.dir)
				usr.density=1
				usr.icon_state="Flight"
				if(!T.Water&&usr.boat)
					eject = 1
					pilot.launchParalysis = 0
					pilot.ship = null
					density = 1
					pilot = null
					usr.boat = 0
					inuse=0
					if(usr.Savable) usr.icon_state=""
				spawn
					pilot = usr
					pilot.ship = src
					density = 0
					eject = 0
					pilot.launchParalysis = 0
					pilot.loc = locate(x,y,z)
					while(!eject&&pilot&&T.Water&&usr.boat)
						sleep(1)
						if(!pilot) return
						loc = locate(pilot.x,pilot.y,pilot.z)
						pilot.ship = src
					pilot.ship = null
					pilot.launchParalysis = 0
					pilot = null
					density = 1
					eject = 0
					inuse=0
				emit_Sound('buku.wav')
			else if(T.Water&&usr.boat)
				eject = 1
				pilot.launchParalysis = 0
				pilot.ship = null
				density = 1
				pilot = null
				inuse=0
				usr.boat = 0
				if(usr.Savable) usr.icon_state=""
				usr<<"You stop sailing."
			else
				usr<<"You can only sail in water!"

	Del()
		if(pilot)
			pilot.ship = null
		spawnExplosion(location=loc,strength=maxarmor,radius=1)
		..()