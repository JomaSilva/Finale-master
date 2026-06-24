effect
	Potion
		id = "Potion Sickness"
		duration = 3000
		Removed(mob/target,time=world.time)
			..()
			target.potionlist.Cut()
	Poison
		id = "Poison Applied"
		duration = 3000
		Removed(mob/target,time=world.time)
			..()
			target.poisonlist.Cut()
	Alchemy
		var/magnitude = 0//how strong is the effect, determined by ingredients
		Added(mob/target,time=world.time)//we want to wait until magnitude is set before we finish adding the effect
			while(!magnitude)
				sleep(1)
			if(magnitude>100)
				magnitude=100
			else if(magnitude<0)
				magnitude=0
			..()
		Health
			id = "Health"
			Instant
				sub_id = "Instant"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.SpreadHeal(magnitude/5)
			Duration
				sub_id = "Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.SpreadHeal(magnitude/duration)
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.healthmod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.healthmod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.healthmod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.healthmod*=1+magnitude/100
			Damage
				sub_id = "Damage"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.SpreadDamage(magnitude/5,,"Poison")
			Damage_Duration
				sub_id = "Damage Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.SpreadDamage(magnitude/duration,,"Poison")
		Energy
			id = "Energy"
			Instant
				sub_id = "Instant"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.Ki+=0.01*magnitude*target.MaxKi
			Duration
				sub_id = "Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.Ki+=0.01*magnitude*target.MaxKi/duration
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.TMaxKi*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.TMaxKi/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.TMaxKi/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.TMaxKi*=1+magnitude/100
			Damage
				sub_id = "Damage"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.Ki-=target.MaxKi*(magnitude/100)
			Damage_Duration
				sub_id = "Damage Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.Ki-=target.MaxKi*(magnitude/(duration*100))
		Stamina
			id = "Stamina"
			Instant
				sub_id = "Instant"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.stamina+=0.01*magnitude*target.maxstamina
			Duration
				sub_id = "Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.stamina+=0.01*magnitude*target.maxstamina/duration
			Damage
				sub_id = "Damage"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.stamina-=target.maxstamina*(magnitude/100)
			Damage_Duration
				sub_id = "Damage Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.stamina-=target.maxstamina*(magnitude/(duration*100))
		Magic
			id = "Magic"
			Instant
				sub_id = "Instant"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.Magic+=magnitude*target.MaxKi
			Duration
				sub_id = "Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.Magic+=magnitude/duration
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.mana_cap_mod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.mana_cap_mod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.mana_cap_mod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.mana_cap_mod*=1+magnitude/100
			Damage
				sub_id = "Damage"
				duration = 10
				Added(mob/target,time=world.time)
					..()
					target.Magic-=(magnitude/100)
			Damage_Duration
				sub_id = "Damage Duration"
				duration = 20
				tick_delay = 5
				Ticked(mob/target,tick,time=world.time)
					target.Magic-=(magnitude/(duration*100))
		Phys_Off
			id = "Phys Off"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.physoffMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.physoffMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.physoffMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.physoffMod*=1+magnitude/100
		Phys_Def
			id = "Phys Def"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.physdefMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.physdefMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.physdefMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.physdefMod*=1+magnitude/100
		Ki_Off
			id = "Ki Off"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.kioffMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.kioffMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.kioffMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.kioffMod*=1+magnitude/100
		Ki_Def
			id = "Ki Def"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.kidefMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.kidefMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.kidefMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.kidefMod*=1+magnitude/100
		Technique
			id = "Technique"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.techniqueMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.techniqueMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.techniqueMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.techniqueMod*=1+magnitude/100
		Ki_Skill
			id = "Ki Skill"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.kiskillMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.kiskillMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.kiskillMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.kiskillMod*=1+magnitude/100
		Speed
			id = "Speed"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.speedMod*=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.speedMod/=1+magnitude/100
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.speedMod/=1+magnitude/100
				Removed(mob/target,time=world.time)
					..()
					target.speedMod*=1+magnitude/100
		Phys_Res
			id = "Phys Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Physical"]=target.Resistances["Physical"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Physical"]=target.Resistances["Physical"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Physical"]=target.Resistances["Physical"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Physical"]=target.Resistances["Physical"]*(1+magnitude/100)
		Energy_Res
			id = "Energy Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Energy"]=target.Resistances["Energy"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Energy"]=target.Resistances["Energy"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Energy"]=target.Resistances["Energy"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Energy"]=target.Resistances["Energy"]*(1+magnitude/100)
		Fire_Res
			id = "Fire Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Fire"]=target.Resistances["Fire"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Fire"]=target.Resistances["Fire"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Fire"]=target.Resistances["Fire"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Fire"]=target.Resistances["Fire"]*(1+magnitude/100)
		Ice_Res
			id = "Ice Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Ice"]=target.Resistances["Ice"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Ice"]=target.Resistances["Ice"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Ice"]=target.Resistances["Ice"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Ice"]=target.Resistances["Ice"]*(1+magnitude/100)
		Shock_Res
			id = "Shock Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Shock"]=target.Resistances["Shock"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Shock"]=target.Resistances["Shock"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Shock"]=target.Resistances["Shock"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Shock"]=target.Resistances["Shock"]*(1+magnitude/100)
		Poison_Res
			id = "Poison Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Poison"]=target.Resistances["Poison"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Poison"]=target.Resistances["Poison"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Poison"]=target.Resistances["Poison"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Poison"]=target.Resistances["Poison"]*(1+magnitude/100)
		Holy_Res
			id = "Holy Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Holy"]=target.Resistances["Holy"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Holy"]=target.Resistances["Holy"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Holy"]=target.Resistances["Holy"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Holy"]=target.Resistances["Holy"]*(1+magnitude/100)
		Dark_Res
			id = "Dark Res"
			Buff
				sub_id = "Buff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Dark"]=target.Resistances["Dark"]*(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Dark"]=target.Resistances["Dark"]/(1+magnitude/100)
			Debuff
				sub_id = "Debuff"
				duration = 50
				Added(mob/target,time=world.time)
					..()
					target.Resistances["Dark"]=target.Resistances["Dark"]/(1+magnitude/100)
				Removed(mob/target,time=world.time)
					..()
					target.Resistances["Dark"]=target.Resistances["Dark"]*(1+magnitude/100)