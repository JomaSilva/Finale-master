effect
	slow
		id = "Slow"
		duration = 10
		Added(mob/target,time=world.time)
			..()
			target.slowed += 1
		Removed(mob/target,time=world.time)
			..()
			target.slowed -= 1
		Lunge
			sub_id = "Lunge"
			duration = 40
		High_Jump
			sub_id = "High Jump"
			duration = 50

	stagger
		id = "Stagger"
		duration = 10
		Added(mob/target,time=world.time)
			..()
			target.stagger += 1
		Removed(mob/target,time=world.time)
			..()
			target.stagger -= 1
		Staggering_Impact
			sub_id = "Staggering Impact"
			duration = 40

	knockback
		id = "Knockback"
		tick_delay = 1
		var
			dir = 0
			pow = 1
		Added(mob/target,time=world.time)
			..()
			target.KB += 1
			target.canfight -= 1
			dir = target.kbdir
			pow = target.kbpow
			duration = min(target.kbdur,30)//maxes out at 30 tiles
			if("KB" in icon_states(target.icon))
				target.icon_state = "KB"
			target.emit_Sound('throw.ogg')
			target.kbdir=0
			target.kbpow=1
			target.kbdur=0
		Removed(mob/target,time=world.time)
			..()
			target.KB -= 1
			target.canfight += 1
			target.icon_state = ""
			if(!(locate(/obj/Crater/impactcrater) in target.loc))
				var/obj/Crater/impactcrater/ic = new()
				if(target && target.loc)
					ic.loc = locate(target.x,target.y,target.z)
					ic.dir = turn(dir, 180)
			target.emit_Sound('landharder.ogg')

		Ticked(mob/target,tick,time=world.time)
			while(TimeStopped&&!target.CanMoveInFrozenTime)
				sleep(1)
			var/turf/T = get_step(target,dir)
			if(T&&T.density)
				if(pow>=(T.Resistance)&&T.destroyable)
					spawn T.Destroy()
					createDust(T,1)
					target.emit_Sound('landharder.ogg')
				else
					target.SpreadDamage(duration,0)
					duration=0
			for(var/obj/O in get_step(target,dir))
				if(O.fragile)
					O.takeDamage(pow)
			for(var/mob/M in get_step(target,dir))
				if(M&&M!=target)
					M.SpreadDamage(duration,0)
					target.SpreadDamage(duration,0)
					duration=0
			if(!target.isStepping)
				if(step(target,dir,16))
					step(target,dir,16)

	stun
		id = "Stun"
		duration = 10
		Added(mob/target,time=world.time)
			..()
			target.stagger += 1
			target.canfight -=1
		Removed(mob/target,time=world.time)
			..()
			target.stagger -= 1
			target.canfight +=1
		Driving_The_Nail
			sub_id= "Driving The Nail"
			duration = 30
		Hundred_Fists
			sub_id= "Hundred Fists"
			duration = 40

	ministun
		id = "Stun"
		sub_id = "Ministun"
		duration = 2
		Added(mob/target,time=world.time)
			..()
			target.stagger += 1
		Removed(mob/target,time=world.time)
			..()
			target.stagger -= 1

	undense
		id = "Undense"
		Added(mob/target,time=world.time)
			..()
			target.density = 0
		Removed(mob/target,time=world.time)
			..()
			target.density = 1

	dizzy
		id = "Dizzy"
		duration = 20
		tick_delay = 5
		Added(mob/target,time=world.time)
			..()
			target.dizzy+=1
		Removed(mob/target,time=world.time)
			..()
			target.dizzy-=1
		Ticked(mob/target,tick,time=world.time)
			step_rand(target)