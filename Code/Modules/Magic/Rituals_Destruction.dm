obj/Ritual/proc
	p_siphon(magnitude)
		var/obj/Ritual/targetritual
		for(var/obj/Ritual/M in oview(magnitude*0.1 + 1))
			targetritual = M
		var/totalenergy = targetritual.Magic
		var/totaltime = 1000 / max(1,magnitude)
		var/tickr = 1
		if(totalenergy && totaltime)
			while(targetritual && targetritual.Magic>0)
				Magic += totalenergy / 10
				targetritual.Magic -= totalenergy / 10
				to_chat(view(src), "[src] thrums with energy!!")
				tickr++
				if(tickr>=10) break
				sleep(totaltime)
		to_chat(view(src), "[targetritual] dissipates!!")
		del(targetritual)


obj/Ritual/proc
	e_damage(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/amount = log(1.3,max(Magic - (M.Emagiskill * M.Magic),1.1) * magnitude)
		M.SpreadDamage(amount,1)
		//then any visual effects

	e_burn(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/amount = log(1.5,max(Magic - (M.Emagiskill * M.Magic),1.1) * magnitude)
		var/time = min(magnitude*5,100)
		while(time)
			time--
			M.SpreadDamage(amount / magnitude,1)
			//then any visual effects
			sleep(1)
		return TRUE
	e_poison(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/amount = log(1.9,max(Magic - (M.Emagiskill * M.Magic),1.1) * magnitude)
		var/time = min(magnitude*10,100)
		var/totaltime = time
		while(time)
			time--
			M.SpreadDamage(amount/totaltime,1)
			//then any visual effects
			sleep(10)
		//then any visual effects

	e_destroy(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		if(prob(magnitude - M.Emagiskill*20))
			M.buudead = (Magic - (M.Emagiskill * M.Magic)) / 100
			M.Death()
		else
			M.SpreadDamage(25,1)
		//then any visual effects

	e_consume(magnitude)
		if(target_check() == FALSE) return 666
		var/atom/movable/M = r_target
		if(M.Magic || M.stored_energy || M.elec_energy || M.Ki) Magic += take_a_t_m_energy(src,M)
		else return
		if(ismob(M))
			var/mob/nM = M
			if(prob(100 - nM.Emagiskill*15))
				nM.buudead = (Magic - (nM.Emagiskill * nM.Magic)) / 100
				nM.Death()
			else
				nM.SpreadDamage(40,1)
		else
			del(M)
		//then any visual effects

//dimensional rituals
obj/Ritual
	Fuel_Ritual
		icon_state = "main6"
		activator_word = "burn energy"
		ritual_cost = 100
		typing = "Destruction"
		ritual_effect(mob/u)
			//if(target_check(5) == FALSE && !u) return
			var/obj/Ritual/tR
			var/list/rit_list = list()
			for(var/obj/Ritual/nR in oview(5))
				rit_list += nR
			tR = input(invoker,"Which ritual do you want to fuel?","Ritual Fueling") in rit_list
			tR.Magic+=Magic
			Magic=0
	Mana_Gathering
		icon_state = "main6"
		activator_word = "give energy"
		ritual_cost = 300
		typing = "Destruction"
		ritual_effect(mob/u)
			//if(target_check(5) == FALSE && !u) return
			invoker.Magic += Magic
			Magic=0
	Sacrifice
		icon_state = "main6"
		activator_word = "x'loth evig em htgnerts"
		ritual_cost = 200
		typing = "Destruction"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Night_Princess)
		ritual_effect(mob/u)
			//if(target_check(2) == FALSE && !u) return
			var/mob/M
			for(var/mob/cM in ingredients)
				if(cM) M = cM
			M.buudead=7
			spawn(10) M.Death()
			spawn M.absorbproc()
			var/downscaler = 5
			var/upscaler = 1.8
			if(!M.isNPC)
				invoker.absorbadd+=((M.BP/1+M.absorbadd)*(M.Anger/100))
			else
				invoker.absorbadd+=invoker.capcheck(invoker.relBPmax*(1/400)*invoker.Egains*upscaler)/downscaler
	Realm_Destroy
		icon_state = "main6"
		activator_word = "DOOM"
		ritual_cost = 1000000
		typing = "Destruction"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Silverush,/obj/items/Material/Alchemy/Misc/Essence_Of_Space,/obj/items/Material/Alchemy/Misc/Essence_Of_Time,/obj/items/Material/Alchemy/Misc/Dragon_Blood)
		ritual_effect(mob/u)
			var/obj/Planets/currentP
			for(var/obj/Planets/P in planet_list)
				if(P.planetType==usr.Planet)
					currentP = P.planetType
					if(!P.destroyAble||usr.Planet=="Space"||!canplanetdestroy)
						to_chat(usr, "You can't use Planet Destroy here.")
						return
					break
			if(!currentP)
				to_chat(usr, "You can't use Planet Destroy here.")
				return
			switch(input(u,"Destroy this Planet?","",text) in list("No","Yes"))
				if("Yes")
					//var/zz=usr.z
					var/mexpressedBP = Magic * invoker.Emagiskill + invoker.Magic + invoker.Ki
					for(var/obj/Planets/P in planet_list)
						if(P.planetType==currentP)
							P.isBeingDestroyed = 1
							break
					to_chat(view(src), "<font color=yellow>*[src] begins focusing energy*")
					WriteToLog("rplog","[invoker] blew up [currentP] with planet destroy!!!   ([time2text(world.realtime,"Day DD hh:mm")])")
					emit_Sound('deathball_charge.wav')
					var/obj/attack/blast/A=new/obj/attack/blast
					A.icon='15.dmi'
					A.icon_state="15"
					A.density=1
					A.loc=locate(x,y+1,z)
					sleep(100)
					if(A)
						A.icon='16.dmi'
						A.icon_state="16"
						sleep(10)
						walk(A,SOUTH,3)
						spawn(30) if(A)
							var/obj/B=new/obj
							B.icon='Giant Hole.dmi'
							B.loc=A.loc
							del(A)
						var/area/currentarea=GetArea()
						currentarea.DestroyPlanet(mexpressedBP)
	CBT
		icon_state = "main6"
		activator_word = "BALLSTRETCHER"
		ritual_cost = 100
		typing = "Destruction"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Octopus_Juice,/obj/items/Material/Alchemy/Misc/Nux_Myristica)
		ritual_effect(mob/u)
			var/list/moblist = list()
			for(var/mob/M in mob_list)
				moblist += M
			r_target = input(invoker, "Select a mob.") as mob in moblist
			var/mob/M = r_target
			damage_m(M,200,"abdomen",0,1)
			to_chat(view(M), "<font color=purple>Uma dor lancinante atravessa o corpo de [M] -- o ritual esmaga seus orgaos por dentro!") //texto explicito removido (limpeza de conteudo adulto, mesma leva do purge de 2026-06)

//Karthus's Avatar during Godki.
//candy beam