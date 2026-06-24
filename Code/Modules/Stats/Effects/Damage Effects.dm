mob/var/tmp/buffOn=0 //basic var to test if you have a buff effect on or not
effect
	bleed
		id="Bleed"
		var/damage = 1
		var/theselection = null
		var/murdertoggle = 1
		Ticked(mob/target,tick,time=world.time)
			target.DamageLimb(damage,theselection,murdertoggle,45)
			target.updateOverlay(/obj/overlay/effects/flickeffects/bleeding)
		logsplitter
			sub_id="Logsplitter"
			duration = 100//10 seconds by default
			tick_delay = 5//ticks every half a second, so 20 ticks
			Added(mob/target,time=world.time)
				..()
			Removed(mob/target,time=world.time)
				..()
			Ticked(mob/target,tick,time=world.time)
				target.DamageLimb(damage,theselection,murdertoggle,100)
				target.updateOverlay(/obj/overlay/effects/flickeffects/bleeding)
		brutalcleave
			sub_id="Brutalcleave"
			duration = 100//10 seconds by default
			tick_delay = 5//ticks every half a second, so 20 ticks
			Added(mob/target,time=world.time)
				..()
			Removed(mob/target,time=world.time)
				..()
			Ticked(mob/target,tick,time=world.time)
				target.DamageLimb(damage,theselection,murdertoggle,100)
				target.updateOverlay(/obj/overlay/effects/flickeffects/bleeding)

	buff
		artifact
			bladeofevilsbane //as the name implies, this is intended for the Master Sword
				id="Blade of Evil's Bane"
				sub_id="Bladeofevilsbane"
				duration = 600//60 seconds
				Added(mob/target,time=world.time)
					..()
					target.MSPower+=4
					target.swordskill+=2
					target.updateOverlay(/obj/overlay/effects/flickeffects/BoEB)
					target.buffOn=1
				Removed(mob/target,time=world.time)
					..()
					target.MSPower-=4
					target.swordskill+=2
					target.removeOverlay(/obj/overlay/effects/flickeffects/BoEB)
					target.buffOn=0
					target << "<font color=yellow>The Master Sword's power subsides."
				Ticked(mob/target,tick,time=world.time)
					target.updateOverlay(/obj/overlay/effects/flickeffects/BoEB)