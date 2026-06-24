mob/proc
	TempBuff(var/list/TempList,delayAmount)
		set waitfor = 0
		set background = 1
		spawn
			for(var/S in TempList)
				switch(S)
					if("Tphysoff")
						AddMagDurEffect(/effect/general/Tphysoff,TempList[S],delayAmount)
					if("Tphysdef")
						AddMagDurEffect(/effect/general/Tphysdef,TempList[S],delayAmount)
					if("Ttechnique")
						AddMagDurEffect(/effect/general/Ttechnique,TempList[S],delayAmount)
					if("Tkioff")
						AddMagDurEffect(/effect/general/Tkioff,TempList[S],delayAmount)
					if("Tkidef")
						AddMagDurEffect(/effect/general/Tkidef,TempList[S],delayAmount)
					if("Tmagi")
						AddMagDurEffect(/effect/general/Tmagi,TempList[S],delayAmount)
					if("Tspeed")
						AddMagDurEffect(/effect/general/Tspeed,TempList[S],delayAmount)
					if("Tkiregen")
						AddMagDurEffect(/effect/general/Tkiregen,TempList[S],delayAmount)
					if("BP")
						AddMagDurEffect(/effect/general/BP,TempList[S],delayAmount)
					if("Density")
						AddMagDurEffect(/effect/general/Density,TempList[S],delayAmount)
					if("passify")
						AddMagDurEffect(/effect/general/passify,TempList[S],delayAmount)
					if("intelligence")
						AddMagDurEffect(/effect/general/Intelligence,TempList[S],delayAmount)
					if("polymorph")
						var/effect/general/polymorph/E =new /effect/general/polymorph
						E.special_icon = TempList[S]
						E.magnitude = 1
						E.duration = delayAmount
						E.Add(src,world.time)
					if("timestop")
						AddMagDurEffect(/effect/general/Timestop,TempList[S],delayAmount)
					if("etherial_form")
						AddMagDurEffect(/effect/general/etherial_form,TempList[S],delayAmount)
					if("silence")
						AddMagDurEffect(/effect/general/silence,TempList[S],delayAmount)
					if("invisibility")
						AddMagDurEffect(/effect/general/invisibility,TempList[S],delayAmount)

mob
	proc
		AddMagDurEffect(effect/e,Magnitude,Duration) //mob redirect for effect.Add()
			if(!isnull(e))
				var/effect/general/E = new e
				E.tier=0 //unused
				E.Add(src,world.time)
				E.magnitude = Magnitude + 0
				E.duration = Duration
				return E

effect
	general
		var/magnitude
		Added(mob/target,time=world.time)//we want to wait until magnitude is set before we finish adding the effect
			while(!magnitude)
				sleep(1)
			if(magnitude>100)
				magnitude=100
			else if(magnitude<0)
				magnitude=0
			..()
		
		
		Tphysoff
			sub_id = "Tphysoff"
			Added(mob/target,time=world.time)
				..()
				target.Tphysoff += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tphysoff -= magnitude
		Tphysdef
			sub_id = "Tphysdef"
			Added(mob/target,time=world.time)
				..()
				target.Tphysdef += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tphysdef -= magnitude
		Ttechnique
			sub_id = "Ttechnique"
			Added(mob/target,time=world.time)
				..()
				target.Ttechnique += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Ttechnique -= magnitude
		Tkioff
			sub_id = "Tkioff"
			Added(mob/target,time=world.time)
				..()
				target.Tkioff += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tkioff -= magnitude
		Tkidef
			sub_id = "Tkidef"
			Added(mob/target,time=world.time)
				..()
				target.Tkidef += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tkidef -= magnitude
		Tmagi
			sub_id = "Tmagi"
			Added(mob/target,time=world.time)
				..()
				target.Tmagi += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tmagi -= magnitude
		
		Tspeed
			sub_id = "Tspeed"
			Added(mob/target,time=world.time)
				..()
				target.Tspeed += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tspeed -= magnitude
		Tkiregen
			sub_id = "Tkiregen"
			Added(mob/target,time=world.time)
				..()
				target.Tkiregen += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tkiregen -= magnitude
		
		BP
			sub_id = "BP"
			Added(mob/target,time=world.time)
				..()
				target.TMagAdd += magnitude
			Removed(mob/target,time=world.time)
				..()
				target.Tkiregen -= magnitude
		Density
			sub_id = "Density"
			Added(mob/target,time=world.time)
				..()
				target.density = 1
			Removed(mob/target,time=world.time)
				..()
				if(target.density) target.density = 0
				else target.density = 1
		Intelligence
			sub_id = "Intelligence"
			Added(mob/target,time=world.time)
				..()
				target.genome.add_to_stat("Tech Modifier",magnitude)
			Removed(mob/target,time=world.time)
				..()
				target.genome.sub_to_stat("Tech Modifier",magnitude)
		polymorph
			sub_id = "polymorph"
			var/special_icon
			Added(mob/target,time=world.time)
				..()
				target.passive_block = 1
				if(target.icon != special_icon)
					target.oicon = target.icon
					target.icon = special_icon
			Removed(mob/target,time=world.time)
				..()
				target.passive_block = 0
				target.icon = target.oicon
		Timestop
			sub_id = "Timestop"
			Added(mob/target,time=world.time)
				..()
				target.CanMoveInFrozenTime=magnitude
			Removed(mob/target,time=world.time)
				..()
				if(target.CanMoveInFrozenTime) target.CanMoveInFrozenTime=0
				else target.CanMoveInFrozenTime=1
		silence
			sub_id = "silence"
			Added(mob/target,time=world.time)
				..()
				target.is_silenced=1
			Removed(mob/target,time=world.time)
				..()
				target.is_silenced=0
		passify
			sub_id = "passify"
			Added(mob/target,time=world.time)
				..()
				target.passive_block = 1
			Removed(mob/target,time=world.time)
				..()
				target.passive_block = 0
		invisibility
			sub_id = "invisibility"
			Added(mob/target,time=world.time)
				..()
				target.invisibility=1
			Removed(mob/target,time=world.time)
				..()
				target.invisibility=0
		etherial_form
			sub_id = "etherial_form"
			var/list/recorded_loc = list(1,1,1)
			Added(mob/target,time=world.time)
				..()
				target.passive_block = 1
				target.alpha = 120
				target.attackable=0
				recorded_loc = list(target.x,target.y,target.z)
			Removed(mob/target,time=world.time)
				..()
				target.passive_block = 0
				target.alpha = 255
				target.attackable=1
				target.loc = locate(recorded_loc[1],recorded_loc[2],recorded_loc[3])

mob/var
	tmp/passive_block