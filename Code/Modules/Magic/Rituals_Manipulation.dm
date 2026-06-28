//the 'e' in the front stands for effect.
//the 'p' stands for prep, i.e. effects with no target.

obj/Ritual/proc
	p_magnify(magnitude)
		magnification *= magnitude
	p_dissociate(magnitude)
		magnification /= magnitude
	p_disappear(magnitude)
		invisibility = round((sqrt(Magic) * magnitude) / 10)
	p_add(magnitude)
		magnification += magnitude
	p_subtract(magnitude)
		magnification -= magnitude
		magnification = max(0.01,magnification)

	p_moonlight_magnify(magnitude)
		var/area/target_area = GetArea()
		switch(target_area.daylightcycle)
			if(6) magnification *= magnitude
			if(7) magnification *= magnitude * 2
			if(8) magnification *= magnitude * 4
			if(9) magnification *= magnitude * 2
			if(10) magnification *= magnitude
			else magnification *= magnitude * 0.25
		if(target_area.daylightcycle >= 6)
			if(target_area.mooncycle == 4) magnification *= magnitude * 1.15
			if(target_area.mooncycle == 5) magnification *= magnitude * 3
			if(target_area.mooncycle == 6) magnification *= magnitude * 1.15

	p_sunlight_magnify(magnitude)
		var/area/target_area = GetArea()
		switch(target_area.daylightcycle)
			if(1) magnification *= magnitude
			if(2) magnification *= magnitude * 3
			if(3) magnification *= magnitude * 5
			if(4) magnification *= magnitude * 3
			if(5) magnification *= magnitude
			else magnification *= magnitude * 0.25

	p_makyo_magnify(magnitude)
		var/area/target_area = GetArea()
		switch(target_area.IsHellstar)
			if(1) magnification *= magnitude * 3
			if(2) magnification *= magnitude * 5
			if(3) magnification *= magnitude * 3
			else magnification *= magnitude * 0.5

obj/Ritual/proc
	t_duplicate(magnitude)
		tietary_add++
		tietary_add_modifier = 1 * magnitude

	t_funnel(magnitude)
		for(var/obj/Ritual/M in oview(magnitude,src))
			Magic += M.Magic / (100 / magnitude)
			M.Magic -=  M.Magic / (100 / magnitude)

obj/Ritual/proc
	e_speed(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tspeed"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,10 * magnitude) //1k seconds
		//then any visual effects
	e_physoff(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tphysoff"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
	e_physdef(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tphysdef"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
	e_technique(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Ttechnique"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
	e_kioff(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tkioff"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
	e_kidef(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tkidef"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
	e_magic(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tmagi"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
	e_kiregen(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("Tkiregen"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects

	e_appear(magnitude)
		if(target_check() == FALSE) return 666
		var/bool = check_target()
		if(bool != 4 && bool != FALSE)
			var/atom/M = r_target
			var/amount = magnitude_calc(Magic,magnitude,0)
			M.invisibility -= round(amount)
			M.invisibility = max(0,invisibility)

	e_disappear(magnitude)
		if(target_check() == FALSE) return 666
		var/bool = check_target()
		if(bool != 4 && bool != FALSE)
			var/atom/M = r_target
			var/amount = magnitude_calc(Magic,magnitude,0)
			M.invisibility += round(amount)
			M.invisibility = max(0,invisibility)
			if(ismob(r_target))
				var/mob/nM= r_target
				var/list/t_l = list("Invisibility"=amount)
				spawn nM.TempBuff(t_l,100 * magnitude) //1k seconds


	e_empower(magnitude)
		if(target_check() == FALSE) return 666
		if(istype(r_target,/obj))
			var/obj/nR = r_target
			nR.stored_energy += convert_mag_to_norm_e(Magic)
		else
			if(target_check(2) == FALSE) return
			var/mob/M = r_target
			var/amount = magnitude_calc(Magic,magnitude,0)
			var/list/t_l = list("BP"=amount)
			M.TempBuff(t_l,1000 * magnitude)

	e_empower_p(magnitude)
		if(target_check() == FALSE) return 666
		if(istype(r_target,/obj))
			var/obj/nR = r_target
			//world << "4test"
			nR.stored_energy += convert_mag_to_norm_e(Magic)
		else
			//world << "4test"
			if(target_check(2) == FALSE) return
			var/mob/M = r_target
			var/amount = magnitude_calc(Magic,magnitude,0)
			M.BP += M.capcheck(amount)

	e_depower(magnitude) //there is no permanent version for a reason.
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("BP"= -(BP * 0.01 * magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic)))
		M.TempBuff(t_l,1000 * magnitude)

	e_density(magnitude)
		if(target_check() == FALSE) return 666
		var/atom/M = r_target
		if(M.density) M.density = 0
		else M.density = 1
		if(ismob(M))
			var/mob/nM= M
			var/list/t_l = list("Density")
			spawn nM.TempBuff(t_l,10*magnitude) //1k seconds
		//then any visual effects

	e_icon(magnitude)
		if(target_check() == FALSE) return 666
		var/atom/M = r_target
		var/amount = magnitude_calc(Magic,magnitude,0)
		var/oldicon = input(invoker,"Select the icon","") as icon
		M.overlays += oldicon
		sleep(amount*10)
		M.overlays -=oldicon

	e_power(magnitude)
		if(target_check() == FALSE) return 666
		if(istype(r_target,/obj))
			var/obj/nR = r_target
			nR.elec_energy += convert_mag_to_elec_e(Magic * magnitude)
		else
			if(target_check(2) == FALSE) return 666
			var/mob/M = r_target
			var/amount = magnitude_calc(Magic,magnitude,0)*(M.MaxKi/100)*2
			M.Ki += amount
			M.overcharge = 1

	e_power_magic(magnitude)
		if(target_check() == FALSE) return 666
		if(istype(r_target,/atom/movable))
			var/obj/nR = r_target
			nR.Magic += Magic + (1 + log(magnitude))

	e_power_ki(magnitude)
		if(target_check() == FALSE) return 666
		if(istype(r_target,/atom/movable))
			r_target.Ki += convert_mag_to_ki_e(Magic * magnitude)

	e_activate_ritual(magnitude)
		if(target_check(5) == FALSE) return 666
		if(istype(r_target,/obj/Ritual))
			var/obj/Ritual/nR = r_target
			nR.Magic += Magic * (1 + log(magnitude))
			nR.activate_ritual(invoker)

	e_pacify(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("pacify")
		M.TempBuff(t_l,10 * magnitude)

	e_heal(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		M.SpreadHeal(magnitude,1,1)

	e_regenerate(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		M.SpreadHeal(magnitude/3,1,1)
		var/time = log(3,magnitude)
		spawn while(round(time))
			time--
			if(prob(40 + time))
				var/list/limbselection = list()
				for(var/datum/Body/C in M.body)
					sleep(1)
					if(C.health < C.maxhealth)
						limbselection += C
				var/datum/Body/choice = pick(limbselection)
				if(!isnull(choice)&&!choice.artificial)
					if(choice.lopped)
						choice.RegrowLimb()
			sleep(10)
	e_resurrect(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		M.ReviveMe()

	e_feed(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		M.stamina = min(M.stamina + (Magic / M.maxstamina) * (3*sqrt(Magic)),M.maxstamina)

	e_anger(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		M.Anger = min(M.Anger + (magnitude * (M.MaxAnger - 100)),M.maxstamina)
		M.StoredAnger+=10
	e_intelligence(magnitude)
		if(target_check(2) == FALSE) return 666
		var/mob/M = r_target
		var/list/t_l = list("intelligence"=magnitude_calc(Magic,magnitude,0))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds

	e_change_weather(magnitude)
		if(target_check() == FALSE) return 666
		var/weatherpick = rand(1,min(magnitude,9))
		if(weatherpick==1 || magnitude==0) return
		else
			var/area/target_area = r_target.GetArea()
			target_area.IsWeathering = 1
			switch(weatherpick)
				if(1) target_area.currentWeather = "Rain"
				if(2) target_area.currentWeather = "Snow"
				if(3) target_area.currentWeather = "Fog"
				if(4) target_area.currentWeather = "Smog"
				if(5) target_area.currentWeather = "Blood Rain"
				if(6) target_area.currentWeather = "Blizzard"
				if(7) target_area.currentWeather = "Sandstorm"
				if(8) target_area.currentWeather = "Namek Rain"
				if(9) target_area.IsWeathering = 0
	e_blutz_emit(magnitude)
		if(target_check() == FALSE) return 666
		for(var/mob/M in view(magnitude,r_target))
			if(!M.Apeshit && !M.is_Tail_Lopped() && M.Tail && (M.Race=="Saiyan" || M.canSSJ || M.Parent_Race == "Saiyan"))
				to_chat(view(M), "[M] becomes irradiated with Blutzwaves!")
				if(M.hasssj && prob(60))//canSSJ is a var ticked by Baby absorbs.
					M.GoldenApeshit()
				else
					M.Apeshit()
	e_full_moon()
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		var/area/target_area = r_target.GetArea()
		if(target_area.daylightcycle <= 5)
			target_area.mooncycle = 4
		if(target_area.daylightcycle >= 6)
			target_area.mooncycle = 5

	e_hell_star()
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		var/area/target_area = r_target.GetArea()
		target_area.IsHellstar = 1
		target_area.testHellstar()

	e_day_noon()
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		var/area/target_area = r_target.GetArea()
		target_area.daylightcycle = 3

	e_night_mid()
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		var/area/target_area = r_target.GetArea()
		target_area.daylightcycle = 8

	e_seal(magnitude)
		if(target_check() == FALSE) return 666
		var/amount = ((Magic - (r_target.Magic)) * magnitude) + log(1.2,invoker.expressedBP * magnitude)
		if(ismob(r_target))
			var/mob/M = r_target
			to_chat(view(12,M), "[M] is sucked into the dead zone!!")
			M.SealedLocation = locate(M.x,M.y,M.z)
			M.SealMob(amount,0)
		else return 666

	e_seal_s(magnitude)
		if(target_check() == FALSE) return 666
		var/amount = ((Magic - (r_target.Magic)) * magnitude) + log(1.2,invoker.expressedBP * magnitude)
		if(ismob(r_target))
			var/mob/M = r_target
			var/obj/items/SealingItem/target_container = locate(/obj/items/SealingItem) in view()
			if(target_container)
				to_chat(view(12,M), "[M] is sucked into the dead zone!!")
				M.SealedLocation = locate(M.x,M.y,M.z)
				M.SealMob(amount,1)
				target_container.Sealed = M
				target_container.SealedSig = M.signature
			else
				to_chat(view(12,invoker), "[invoker] and [M] is sucked into the dead zone due to nothing to hold the energies in!!!")
				M.SealedLocation = locate(M.x,M.y,M.z)
				M.SealMob(amount/2,0)
				invoker.SealedLocation = locate(invoker.x,invoker.y,invoker.z)
				invoker.SealMob(amount/2,0)
		else return 666

	e_etherial_form(magnitude)
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		var/list/t_l = list("etherial_form"=list(x,y,z))
		spawn invoker.TempBuff(t_l,100*magnitude_calc(Magic,magnitude,0)) //1k seconds
		var/newloc = r_target.GetTurf()
		invoker.Move(newloc)

	e_telepathy(magnitude)
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		var/message = input(invoker,"Message?","Ritual Telepathy") as text
		if(ismob(r_target))
			var/mob/M = r_target
			M<<output("<font size=[M.TextSize]><font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'","Chatpane.Chat")
			chatcast(M, "<font size=[M.TextSize]><font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'", "say")
			invoker<<output("<font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'","Chatpane.Chat")
			chatcast(invoker, "<font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'", "say")
			WriteToLog("rplog","(Telepathy to [M])[invoker]: [message]   ([time2text(world.realtime,"Day DD hh:mm")])")
		else
			view(magnitude,r_target)<<output("<font size=[invoker.TextSize]><font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'","Chatpane.Chat")
			chatcast(view(magnitude,r_target), "<font size=[invoker.TextSize]><font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'", "say")
			if(!invoker in view(magnitude,r_target)) invoker<<output("<font face=Old English Text MT><font color=red>[invoker] says in telepathy, '[html_encode(message)]'","Chatpane.Chat")
			WriteToLog("rplog","(Telepathy to [r_target])[invoker]: [message]   ([time2text(world.realtime,"Day DD hh:mm")])")

	e_silence(magnitude)
		if(target_check() == FALSE) return 666
		//var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		if(ismob(r_target))
			var/mob/M = r_target
			var/list/t_l = list("silence")
			spawn M.TempBuff(t_l,100*magnitude_calc(Magic,magnitude,0)) //1k seconds
		else return 666

	e_give_soul_body()
		if(target_check() == FALSE) return 666
		if(ismob(r_target))
			var/mob/M = r_target
			M.KeepsBody=1
		else return 666

	e_take_soul_body()
		if(target_check() == FALSE) return 666
		if(ismob(r_target))
			var/mob/M = r_target
			M.KeepsBody=0
		else return 666

//dimensional rituals
obj/Ritual
	Research_Word
		icon_state = "main3"
		activator_word = "cerebrus"
		ritual_cost = 5000
		typing = "Manipulation"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Frog_Brain,/obj/items/Material/Alchemy/Misc/Essence_Of_Time)
		ritual_effect(mob/u)
			//if(target_check(2) == FALSE && !invoker) return
			to_chat(invoker, "<font color=blue><font size=2>An etherial voice calls to you...</font></font>")
			sleep(10)
			var/ind = rand(1,3)
			var/known_types = 0
			if(!ind) ind = pick(1,2,3)
			retry
			if(known_types == 3)
				to_chat(invoker, "<font color=blue><font size=3>???: error() : word_knowledge == power_words.length() : return mob/proc/Affirmation()</font></font>")
				sleep(20)
				if(invoker)
					to_chat(invoker, "<font color=blue><font size=3>???: output(\"Congratulations.\")</font></font>")
			switch(ind)
				if(1)
					var/knownlist = list()
					for(var/a, a <= invoker.known_words.len,a++)
						var/na = invoker.known_words[invoker.known_words[a]]
						if(na in p_power_words)
							knownlist += na
					var/lucky_word
					var/list/resultant_list = p_power_words - knownlist
					if(resultant_list.len)
						lucky_word = pick(resultant_list)
						to_chat(invoker, "<font color=blue><font size=3>???: [lucky_word] : [power_words_p_activations[lucky_word]]</font></font>")
						invoker.known_words += power_words_p_activations[lucky_word]
						invoker.known_words[power_words_p_activations[lucky_word]] = lucky_word
					else
						to_chat(invoker, "<font color=blue size=3>???: error() : known_words >= available_p_words : proc: return src:ritual_effect() - known_power_words_p_activations")
						ind = rand(2,3)
						known_types++
						goto retry

				if(2)
					var/knownlist = list()
					for(var/a, a <= invoker.known_words.len,a++)
						var/na = invoker.known_words[invoker.known_words[a]]
						if(na in t_power_words)
							knownlist += na
					var/lucky_word
					var/list/resultant_list = t_power_words - knownlist
					if(resultant_list.len)
						lucky_word = pick(resultant_list)
						to_chat(invoker, "<font color=blue><font size=3>???: [lucky_word] : [power_words_t_activations[lucky_word]]</font></font>")
						invoker.known_words += power_words_t_activations[lucky_word]
						invoker.known_words[power_words_t_activations[lucky_word]] = lucky_word
					else
						to_chat(invoker, "<font color=blue size=3>???: error() : known_words >= available_t_words : proc: return src:ritual_effect() - known_power_words_t_activations")
						ind = pick(1,3)
						known_types++
						goto retry

				if(3)
					var/knownlist = list()
					for(var/a, a <= invoker.known_words.len,a++)
						var/na = invoker.known_words[invoker.known_words[a]]
						if(na in e_power_words)
							knownlist += na
					var/lucky_word
					var/list/resultant_list = e_power_words - knownlist
					if(resultant_list.len)
						lucky_word = pick(resultant_list)
						to_chat(invoker, "<font color=blue><font size=3>???: [lucky_word] : [power_words_e_activations[lucky_word]]</font></font>")
						invoker.known_words += power_words_e_activations[lucky_word]
						invoker.known_words[power_words_e_activations[lucky_word]] = lucky_word
					else
						to_chat(invoker, "<font color=blue size=3>???: error() : known_words >= available_e_words : proc: return src:ritual_effect() - known_power_words_e_activations")
						ind = rand(1,2)
						known_types++
						goto retry

	Research_Ingredient
		icon_state = "main3"
		activator_word = "ingredious"
		ritual_cost = 2000
		typing = "Manipulation"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Frog_Brain,/obj/items/Material/Alchemy/Misc/Beetle_Eye)
		ritual_effect(mob/u)
			//if(target_check(2) == FALSE && !invoker) return
			to_chat(invoker, "<font color=blue><font size=2>An etherial voice calls to you...</font></font>")
			sleep(10)
			var/atom/movable/input = input(u,"Select the object to view a effect of it.") as obj|mob in view(10,src)
			var/ind = rand(1,3)
			if(!ind) ind = pick(1,2,3)
			switch(ind)
				if(1)
					to_chat(invoker, "<font color=blue><font size=3>???: [input] : r_eff:[input.mag_effects[1]]</font></font>")
				if(2)
					to_chat(invoker, "<font color=blue><font size=3>???: [input] : r_eff:[input.mag_effects[2]]</font></font>")
				if(3)
					to_chat(invoker, "<font color=blue><font size=3>???: [input] : r_eff:[input.mag_effects[3]]</font></font>")
			to_chat(invoker, "<font color=blue><font size=3>???: [input] : magic_[input.Magic]</font></font>")
			if(istype(input,/obj/items/Material/Alchemy))
				ind = rand(1,4)
				switch(ind)
					if(1)
						to_chat(invoker, "<font color=blue><font size=3>???: [input] : eff_[input:Effects[1]]</font></font>")
					
					if(2)
						to_chat(invoker, "<font color=blue><font size=3>???: [input] : eff_[input:Effects[2]]</font></font>")

					if(3)
						to_chat(invoker, "<font color=blue><font size=3>???: [input] : eff_[input:Effects[3]]</font></font>")

					if(4)
						to_chat(invoker, "<font color=blue><font size=3>???: [input] : eff_[input:Effects[4]]</font></font>")
				invoker.ingredientlist[input:ingredtype] = 2**(ind-1)
				to_chat(invoker, "<font color=blue><font size=3>???: [input] : magni_[input:magnitude]</font></font>")
				to_chat(invoker, "<font color=blue><font size=3>???: [input] : dura_[input:duration]</font></font>")
			if(istype(input,/obj/items/Material/Enchanting/Catalyst))
				invoker.knownenchants+=input:studyenchant
				to_chat(invoker, "<font color=blue><font size=3>???: [input] : eff_[input:enchantment]</font></font>")
			if(istype(input,/obj/items/Material/Enchanting/Source))
				invoker << "<font color=blue><font size=3>???: [input] : energy_[input:statvalues["Energy"]]</font></font>"


	Materialize_Item
		icon_state = "shade2"
		activator_word = "energy collesque"
		ritual_cost = 1500
		typing = "Manipulation"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Gillyweed,/obj/items/Material/Alchemy/Misc/Aconite)
		ritual_effect(mob/u)
			//if(target_check(2) == FALSE && !invoker && !u) return
			spawn switch(input(u,"Make what?","","Cancel") in list("Clothes","Weight","Weapon","Cancel"))
				if("Clothes")
					var/obj/A=new/obj/items/clothes/Gi_Top(locate(u.x,u.y,u.z))
					A.techcost+=10
					if(alert(u,"Custom name?","","Yes","No")=="Yes")
						A.name = input(u,"Name.") as text
					if(alert(u,"Custom icon?","","Yes","No")=="Yes")
						A.icon = input("Pick the icon",'Clothes_Cape.dmi') as icon
					var/RED=input("How much red?") as num
					var/GREEN=input("green...") as num
					var/BLUE=input("blue...") as num
					A.icon+=rgb(RED,GREEN,BLUE)
				if("Weapon")
					var/list/wep_typ_list = list()
					wep_typ_list += typesof(/obj/items/Equipment/Weapon)
					wep_typ_list -= /obj/items/Equipment/Weapon/Sword
					wep_typ_list -= /obj/items/Equipment/Weapon/Axe
					wep_typ_list -= /obj/items/Equipment/Weapon/Staff
					wep_typ_list -= /obj/items/Equipment/Weapon/Spear
					wep_typ_list -= /obj/items/Equipment/Weapon/Club
					wep_typ_list -= /obj/items/Equipment/Weapon/Hammer
					wep_typ_list -= /obj/items/Equipment/Weapon/Sword/Rebellion
					wep_typ_list -= /obj/items/Equipment/Weapon/Sword/Sparda
					wep_typ_list -= /obj/items/Equipment/Weapon/Sword/Yamato
					wep_typ_list += "Cancel"
					var/choice = input(u,"Type?","Materialize Weapon") in wep_typ_list
					if(choice == "Cancel") return 666
					else new choice(loc)
				if("Weight")
					var/obj/items/Weight/A=new/obj/items/Weight
					A.name="Weighted Cape"
					if(alert(u,"Custom name?","","Yes","No")=="Yes")
						A.name = input(u,"Name.") as text
					A.icon='Clothes_Cape.dmi'
					if(alert(u,"Custom icon?","","Yes","No")=="Yes")
						A.icon = input("Pick the icon",'Clothes_Cape.dmi') as icon
					var/RED=input("How much red?") as num
					var/GREEN=input("green...") as num
					var/BLUE=input("blue...") as num
					A.icon+=rgb(RED,GREEN,BLUE)
					A.pounds=max(min(round(input(u,"How many pounds? [u.intBPcap*u.Emagiskill] is your maximum.") as num,1),u.intBPcap*u.Emagiskill),1)
					u.contents+=A

//enhance/enchant equipment spell
