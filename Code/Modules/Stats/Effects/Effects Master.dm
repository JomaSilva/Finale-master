#define PRESERVE_NONE 0
#define PRESERVE_WORLDTIME 1
#define PRESERVE_REALTIME 2

mob
	var
		list/effects = list()		 //list of all effects affecting the mob
		save_worldtime
		save_realtime
		tmp
			list/effect_registry = list() //a readable hashmap of effects sorted by their [id] and [id].[sub_id]
	proc
		AddEffect(effect/e,time=world.time,tier) //mob redirect for effect.Add()
			if(!isnull(e))
				var/effect/E = new e
				E.tier=tier
				E.Add(src,time)

		RemoveEffect(effect/e,time=world.time,tier) //mob redirect for effect.Remove()
			for(var/effect/E in effects)
				if(istype(E,e)&&(!tier||E.tier==tier))
					E.Remove(src,time)

	Read(savefile/F)
		..() //default action causes the mob to be read from the savefile.
		var/list/l = effects //store the old effects list
		var/timeoffset = (world.time-save_worldtime) //calculate the world time offset
		var/realoffset = (world.realtime-save_realtime) + timeoffset //calculate the real time offset
		for(var/effect/a in effects)
			a.Removed(src)
		effects = list() //set effects to a new list
		for(var/effect/e in l) //loop over the old effects, and add them back to the mob with a backdated time argument.
			switch(e.preserve) //we're swapping out our if statement to a switch.
				if(PRESERVE_WORLDTIME)
					e.Add(src,e.start_time+timeoffset) //use regular time offset for worldtime preservation
				if(PRESERVE_REALTIME)
					e.Add(src,e.start_time+realoffset) //use real time offset for realtime preservation

	Write(savefile/F)
		save_worldtime = world.time //store the current world time right before saving
		save_realtime = world.realtime //store the current real time right before saving
		..() //default action causes the mob to be written to the savefile.

effect
	var
		id
		sub_id = "global"
		ogsub = null
		tier = 0

		active = 0	   //whether the current effect is still active
		start_time = 0   //The time that the effect was added to the target

		duration = 1#INF //for timed and ticker effects (lifetime of timed and ticker effects)

		tick_delay = 0   //for ticker effects (delay between ticks)
		ticks = 0		//for ticker effects (current number of ticks passed)

		stacks = 1	   //for stacking effects (current number of stacks)
		max_stacks = 1   //for stacking effects (maximum number of stacks)

		preserve = PRESERVE_WORLDTIME
	proc
		Add(mob/target,time=world.time)
			set hidden = 0 //this is not necessary or used in any way. It is merely a temporary bugfix for this bizarre "resolved" bug: http://www.byond.com/forum/?post=2188467
			if(world.time-time>duration)
				return 0
			var/list/registry = target.effect_registry
			var/uid
			if(tier)
				if(!ogsub)
					ogsub = sub_id
				sub_id = "[ogsub] [tier]"
			if(id&&sub_id)
				uid = "[id].[sub_id]" //create the unique id

				var/effect/e = registry[uid] //check the target's registry for a matching effect by unique id
				if(e && !Override(target,e,time)) //if we found an effect matching our uniqueid, we tell this effect to attempt to override it. If it fails, we return 0
					return 0
			if(id)
				var/list/group = registry[id] //get the current id group.
				if(!group)
					//if there is nothing matching the current effect id group
					registry[id] = src
				else if(istype(group))
					//if there is already a list of effects in the id group, add this effect to the group
					group += src
				else if(istype(group,/effect))
					//if there is a single effect in the id group, make it a list with the item and this effect in it.
					registry[id] = list(group,src)
				else
					//if there is something else in place, fail to add this effect. (Possibly adding class immunities via a string?)
					return 0

			//Add() hasn't returned yet, so this effect is going to be added to the registry via unique id and the target's effects list.
			if(uid)
				registry[uid] = src
			target.effects += src

			active = 1
			start_time = time

			Added(target,time) //call the Added() hook.

			if(active)
				if(duration<1#INF) //if the effect has a duration
					if(tick_delay) //and the effect has a tick delay, initiate the ticker.
						Ticker(target,time)
					else //otherwise, initiate the timer
						Timer(target,time)
				else if(tick_delay)
					Ticker(target,time)
			else
				Remove()
				return 0

			return 1 //return success

		Override(mob/target,effect/overriding,time=world.time)
			if(max_stacks>1 && max_stacks==overriding.max_stacks) //check if the max number of stacks match between the two and are greater than 1
				Stack(target,overriding) //stack up the two effects.
			overriding.Overridden(target,src,time) //this is our old code. Cancel the old one, and allow the new one to be added.
			overriding.Cancel(target,time)
			return 1

		Stack(mob/target,effect/overriding)
			stacks = min(stacks + overriding.stacks, max_stacks) //set this element's stacks to the old effect's stacks, then replace it.

		Timer(mob/target,time=world.time)
			set waitfor = 0 //make this not block the interpreter
			while(active&&world.time<start_time+duration) //continue to wait until the effect is no longer active, or the timer has expired.
				sleep(min(10,start_time+duration-world.time)) //wait a maximum of 1 second. This is to prevent already-canceled effects from hanging out in the scheduler for too long.
			Expire(target,world.time)

		Ticker(mob/target,time=world.time)
			set waitfor = 0
			while(active&&world.time<start_time+duration)
				Ticked(target,++ticks,world.time) //call the Ticked() hook. This is another override that allows you to define what these ticker effects will do every time they tick.
				sleep(min(tick_delay,start_time+duration-world.time)) //sleep for the minimum period
			Expire(target,world.time)

		Reset(mob/target,time=world.time)
			start_time = time

		Cancel(mob/target,time=world.time)
			if(active)
				active = 0
				Canceled(target,time)
				if(!active)
					Remove(target,time)

		Remove(mob/target,time=world.time)
			var/list/registry = target.effect_registry
			if(id&&sub_id)
				var/uid = "[id].[sub_id]"

				//some complex logic to test whether this object is actually in the registry. Fail out if the data isn't right.
				if(registry[uid]==src)
					registry -= uid //remove the uid of the object from the registry

			if(id)
				var/list/group = registry[id]
				if(istype(group)) //if the id group is a list
					group -= src
					if(group.len==1) //if the removal of this effect left the list at length 1, we need to reset the id registry to be the item at group index 1 instead of a list.
						registry[id] = group[1]
					else if(group.len==0) //if the removal of this effect left the list at length 0 (this shouldn't happen), we need to remove the id registry from the registry entirely.
						registry -= id
				else if(group==src) //otherwise, we need to remove the entire id registry
					registry -= id

			//remove the effect from the list and the registry
			target.effects -= src

			Removed(target,time) //call the Removed() hook and return success

			active = 0
			return 1

		Expire(mob/target,time=world.time)
			if(active) //only actually do this if the effect is currently marked as active.
				active = 0
				Expired(target,time)
				if(!active)
					Remove(target,time)

		Added(mob/target,time=world.time) //Added() is called when an effect is added to a target.

		Ticked(mob/target,tick,time=world.time) //Ticked() is called when a ticker effect successfully reaches a new tick.

		Removed(mob/target,time=world.time) //Removed() is called when an effect is removed from a target.

		Overridden(mob/target,effect/override,time=world.time) //Overridden() is called when an effect overrides another existing effect.

		Expired(mob/target,time=world.time) //Expired() is called when a timed or a ticker effect successfully reaches the end of its duration.

		Canceled(mob/target,time=world.time) //Canceled() is called when an effect has been manually canceled via Cancel().