effect
	vulnerability
		id = "Vulnerability"
		duration = 40
		var/magnitude = 0.75//25% reduced resistance at 0 resist
		Added(mob/target,time=world.time)
			..()
			target.Resistances["Physical"]=target.Resistances["Physical"]*magnitude
		Removed(mob/target,time=world.time)
			..()
			target.Resistances["Physical"]=target.Resistances["Physical"]/magnitude

	exhaustion
		id = "Exhaustion"
		max_stacks = 20
		Added(mob/target,time=world.time)
			..()
			target.lifeexprate*=(0.90**stacks)
		Removed(mob/target,time=world.time)
			..()
			target.lifeexprate/=(0.90**stacks)

	blind
		id = "Blind"
		duration = 10
		var/magnitude
		Added(mob/target,time=world.time)//we want to wait until magnitude is set before we finish adding the effect
			while(!magnitude)
				sleep(1)
			if(magnitude>100)
				magnitude=100
			else if(magnitude<0)
				magnitude=0
			..()
		Added(mob/target,time=world.time)
			..()
			target.blindT+=3*magnitude
			target.accuracy-=50
		Removed(mob/target,time=world.time)
			..()
			target.blindT-=3*magnitude
			target.accuracy+=50