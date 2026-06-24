effect
	counter
		id = "Counter"
		Flexible_Defense
			sub_id = "Flexible Defense"
			duration = 50
			tick_delay = 5
			Added(mob/target,time=world.time)
				..()
				target.countering+=5
				target.updateOverlay(/obj/overlay/effects/flickeffects/blueglow)
			Removed(mob/target,time=world.time)
				..()
				target.countering=0
				target.removeOverlay(/obj/overlay/effects/flickeffects/blueglow)
			Ticked(mob/target,tick,time=world.time)
				target.updateOverlay(/obj/overlay/effects/flickeffects/blueglow)
	piercing
		id = "Piercing"
		Shatter_Armor
			sub_id = "Shatter Armor"
			duration = 30
			Added(mob/target,time=world.time)
				..()
				target.penetration+=10
			Removed(mob/target,time=world.time)
				..()
				target.penetration-=10
	illusion
		id = "Illusion"
		Afterimage
			sub_id = "Afterimage"
			duration = 50
			tick_delay = 5
			Added(mob/target,time=world.time)
				..()
				target.deflection+=20
			Removed(mob/target,time=world.time)
				..()
				target.deflection-=20
			Ticked(mob/target,tick,time=world.time)
				var/turf/T = locate(target.x,target.y,target.z)
				var/image/afterimage=image(icon=target,icon_state=target.icon_state,dir=target.dir)
				T.overlays+=afterimage
				spawn(10) T.overlays-=afterimage
	Godki
		id = "Godki"
		var/magnitude
		Added(mob/target,time=world.time)//we want to wait until magnitude is set before we finish adding the effect
			while(!magnitude)
				sleep(1)
			if(magnitude>100)
				magnitude=100
			else if(magnitude<0)
				magnitude=0
			..()
		Efficiency
			sub_id = "Efficiency"
			duration = 50
			tick_delay = 5
			Added(mob/target,time=world.time)
				..()
				target.godki.t_efficiency+=magnitude
			Removed(mob/target,time=world.time)
				..()
				target.godki.t_efficiency-=magnitude
		Energy
			sub_id = "Energy"
			duration = 50
			tick_delay = 5
			Added(mob/target,time=world.time)
				..()
				target.godki.energy+=10*magnitude
			Removed(mob/target,time=world.time)
				..()
				target.godki.energy-=10*magnitude
		Tier
			sub_id = "Tier"
			duration = 50
			tick_delay = 5
			Added(mob/target,time=world.time)
				..()
				target.godki.tier+=1
			Removed(mob/target,time=world.time)
				..()
				target.godki.tier-=1
/*for(var/a in Effects) Do something like this for magnitudes.
	spawn usr.AddEffect(Effects[a])
	sleep(1)
	for(var/effect/Alchemy/e in usr.effects)
		if(e.type == Effects[a])
			e.duration = duration*10
			e.magnitude = magnitude*/