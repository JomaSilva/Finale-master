/*effect
	MSTick
		id = "Master Sword Ticker"
		tick_delay = 20
		Ticked(mob/target,tick,time=world.time)
			for(var/obj/items/Equipment/Weapon/Sword/Master_Sword/A in target)
				var/subtractedpower = A.chargedPower * 0.0001
				A.chargedPower -= subtractedpower
				A.chargedPower = max(0,A.chargedPower)
				target.expressedAdd -= subtractedpower
				target.expressedAdd = max(0,target.expressedAdd)*/