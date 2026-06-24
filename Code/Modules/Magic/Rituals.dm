//rituals are freeform, their effects vary depending on ingredients.
/obj/Ritual
	icon = 'magic_circles.dmi'
	icon_state = null
	IsntAItem = 1
	density = 0
	SaveItem = 1
	var
		//openSlots = 5 //how many slots are open? Unneeded, ingredients var is capped to 5 anyways
		ritual_cost = 700 //what's the cost? (energy cost)
		tmp
			list/ingredients = list() //up to 5~ ingredients, 1,2, have beg effects activate, 3/4 middle, 5 end effects activate.
			atom/movable/r_target = null //current target of the ritual, used as a reference but always converted into target 'type'. Dynamic if multiple targets
			list/multiple_targets = list()
			mob/invoker = null
			is_going = 0 //if the ritual is going
			cancelable = 0 //if the ritual is cancelable while going
			magnification = 1
			pre_magnification = 1
		list/req_ingredients = list() //list of required ingredients
		//needs magical power to operate, usually supplied either from outer rituals or within
		//ritual type can be "Manipulate" (magic stuff) "Destruction" (offensive) "Dimensional" (transportation/weird upper level shit)
		activator_word = "Ritual of reality, activate" //key word to 'activate' the ritual. can be changed whenever
		typing = "Manipulation"
		can_research = 1
		customic=1
		//spell/effect specific variables
		tmp
			majority_element = "Arcane"

			tietary_add = 1//how many times does this ritual go?
			tietary_add_modifier= 50 //how many ticks does it take to happen again?

	New()
		..()
		if(!icon_state && customic==FALSE) icon_state = pick("main1","main2","main3","main4","main5","main6")

	verb
		scuff()
			set category = null
			set src in oview(1)
			if(is_going) return FALSE
			else
				del(src)
		add_ingredients()
			set category = null
			set src in oview(1)
			backherepls
			var/list/ingredientlist = list()
			for(var/obj/items/O in view(1,src))
				ingredientlist += O
				if(O in ingredients) ingredientlist -= O
			for(var/mob/O in view(1,src))
				ingredientlist += O
			if(ingredientlist.len == 0) return
			ingredientlist += "Cancel"
			var/atom/movable/input = input(usr,"Select an ingredient to add. Ingredient must be no more than 1 tile away.","Ingredients") in ingredientlist
			if(input == "Cancel") return
			if(get_dist(src,input)<=1)
				if(ingredients.len <= 4)
					if(ismob(input))
						var/mob/M = input
						if(alert(usr,"You're adding a mob to the ingredients! This will kill them. Mob: [input]","","Ok","Cancel")=="Ok" && !M.dead) add_components(input)
					else add_components(input)
			goto backherepls

		remove_ingredients()
			set category = null
			set src in oview(1)
			backherepls
			var/list/ingredientlist = list()
			for(var/O in ingredients)
				ingredientlist += O
			if(ingredientlist.len == 0) return
			ingredientlist += "Cancel"
			var/atom/movable/input = input(usr,"Select an ingredient to remove.","Ingredients") in ingredientlist
			if(input == "Cancel") return
			remove_component(input)
			goto backherepls

		give_mana()
			set category = null
			set src in oview(1)
			if(usr.Magic)
				switch(input(usr,"How much? You have [usr.Magic] magic energy. It has [Magic].","Mana Give") in list("100%","75%","50%","25%","10%","5%","Cancel","A precise amount."))
					if("Cancel") return
					if("100%")
						var/amount = usr.Magic * 1
						usr.Magic -= amount
						Magic += amount
					if("75%")
						var/amount = usr.Magic * 0.75
						usr.Magic -= amount
						Magic += amount
					if("50%")
						var/amount = usr.Magic * 0.50
						usr.Magic -= amount
						Magic += amount
					if("25%")
						var/amount = usr.Magic * 0.25
						usr.Magic -= amount
						Magic += amount
					if("10%")
						var/amount = usr.Magic * 0.10
						usr.Magic -= amount
						Magic += amount
					if("5%")
						var/amount = usr.Magic * 0.05
						usr.Magic -= amount
						Magic += amount
					if("A precise amount.")
						var/amount = min(usr.Magic,max(0,input(usr,"Input a number. You have [usr.Magic] magic energy.","",0) as num))
						usr.Magic -= amount
						Magic += amount
			else
				usr<<"You don't have any magic to give to this ritual."
				return

	proc/
		toggle_component(var/atom/movable/O)
			if(is_going) return FALSE
			if(O in ingredients)
				remove_component(O)
			else if(ingredients.len <= 4)
				add_components(O)

		add_components(var/atom/movable/O)
			if(is_going) return FALSE
			ingredients += O
			ingredients[O] = locate(O.x,O.y,O.z) //after adding a component, it's position is recorded.
			return TRUE

		remove_component(var/atom/movable/O)
			if(is_going) return FALSE
			if(O in ingredients)
				ingredients -= O
				return TRUE
			else if(O.type in ingredients)
				for(var/atom/nO in ingredients)
					if(istype(nO,O.type))
						ingredients -= nO
						return TRUE
			else return FALSE

		check_cost()
			if(activator_word != "Ritual of reality, activate") return ritual_cost
			var/indL = 1
			var/prospective_cost = ritual_cost
			while(indL <= ingredients.len)
				var/obj/items/I = ingredients[indL]
				if(I)
					if(!ingredients[I] == locate(I.x,I.y,I.z))
						ingredients -= I
						continue
					var/t_ind
					switch(ingredients.len)
						if(1 to 2) t_ind = 1
						if(3) t_ind = indL
						if(4)
							switch(indL)
								if(1 to 2) t_ind = 1
								if(3) t_ind = 2
								if(4) t_ind = 3
						if(5)
							switch(indL)
								if(1 to 2) t_ind = 1
								if(3 to 4) t_ind = 2
								if(5) t_ind = 3
					prospective_cost += I.Magic * effect_price_lookup(I.mag_effects[t_ind])
					prospective_cost *= effect_price_lookup(I.mag_effects[t_ind])
				indL++
			return prospective_cost

		check_energy(var/mob/u)
			var/indL = 1
			var/prospective_cost = Magic
			while(indL <= ingredients.len)
				var/obj/items/I = ingredients[indL]
				if(I)
					if(!ingredients[I] == locate(I.x,I.y,I.z))
						ingredients -= I
						continue
					//var/t_ind
					//switch(indL)
					//	if(1 to 2) t_ind = 1
					//	if(3 to 4) t_ind = 2
					//	if(5) t_ind = 3
					if(u) prospective_cost += I.Magic * u.Emagiskill
					else prospective_cost += I.Magic
					prospective_cost += convert_norm_to_magic_e(I.stored_energy)
					prospective_cost += convert_elec_to_mag_e(I.elec_energy)
				indL++
			return prospective_cost

		check_components()
			//
			if(ingredients.len < 3 && activator_word == "Ritual of reality, activate") return FALSE
			if(activator_word != "Ritual of reality, activate" && ingredients.len) return TRUE
			else if(activator_word != "Ritual of reality, activate") return FALSE
			var/indL = 1
			while(indL <= ingredients.len)
				var/obj/items/I = ingredients[indL]
				if(I)
					if(!ingredients[I] == locate(I.x,I.y,I.z))
						ingredients -= I
						continue
					var/t_ind
					switch(ingredients.len)
						if(1 to 2)t_ind = 1
						if(3) t_ind = indL
						if(4)
							switch(indL)
								if(1 to 2) t_ind = 1
								if(3) t_ind = 2
								if(4) t_ind = 3
						if(5)
							switch(indL)
								if(1 to 2) t_ind = 1
								if(3 to 4) t_ind = 2
								if(5) t_ind = 3
					ritual_cost += I.Magic * effect_price_lookup(I.mag_effects[t_ind])
					ritual_cost *= effect_price_lookup(I.mag_effects[t_ind])
				indL++
			return TRUE
			//

		activate_ritual(var/user)
			if(is_going) return FALSE
			else is_going = 1
			if(ismob(user)) invoker = user
			pre_magnification = magnification
			var/list/ingredienttypelist = list()
			for(var/atom/movable/O in ingredients)
				ingredienttypelist += O.type
				//world << "add [O.type]"
				Magic += take_a_t_m_energy(src,O)
				var/mob/M = O
				if(ismob(M)) Magic /= M.DeathRegen 
			var/reqcheck = 1
			if(req_ingredients.len)
				var/list/newlist = ingredienttypelist
				newlist &= req_ingredients
				/*for(var/a in req_ingredients)
					world<<"req [a]"
				for(var/a in ingredienttypelist)
					world<<"have [a]"
				for(var/a in newlist)
					world<<"res [a]"*/
				if(newlist.len == req_ingredients.len)
					reqcheck = 1
				else
					reqcheck = 0
			//check_components()
			var/twocheck = 0
			twocheck = check_components()
			//world << "[ritual_cost] [Magic] [reqcheck] [twocheck]"
			if(ritual_cost <= Magic && reqcheck && twocheck)
				Magic -= ritual_cost
				cancelable = 1
				//world << "gothere [Magic]"
				sleep(10)
				visual_activation()
				sleep(10)
				if(TimeStopped)
					while(TimeStopDuration)
						sleep(1)
				//world << "gothere [Magic] 2"
				if(ritual_effect(invoker) == 666) dissapate()
				//world << "gothere [Magic] 3"
				sleep(10)
				post_ritual()
				burn_Items()
				burn_Mobs()
				is_going=0
				cancelable=0
				return TRUE
			else
				visual_activation()
				sleep(10)
				burn_Items()
				burn_Mobs()
				dissapate() //rituals dissapating can do unpredictable shit
				sleep(10)
				post_ritual()
				is_going=0
				cancelable=0
				return TRUE
			is_going=0
		burn_Items()
			for(var/obj/O in ingredients)
				ingredients -= O
				//del(O)
				O.deleteMe()
			return

		burn_Mobs()
			for(var/mob/M in ingredients)
				ingredients -= M
				if(M.isNPC)
					M.mobDeath()
				else
					if(prob(100 - M.Emagiskill*10))
						M.buudead = 90 / M.Emagiskill
						M.Death()
					else
						M.SpreadDamage(110,1)
			return

		dissapate()
			var/maxener = Magic
			for(var/a, a <= 10, a++)
				if(Magic <= 0) break
				if(prob(10)) del(src)
				var/didloseenergy = cause_Chaos(loc,Magic)
				if(didloseenergy)
					Magic -= didloseenergy
				else Magic-= (maxener * 0.1)
				Magic = max(0,Magic)
				sleep(10)
			return TRUE

		ritual_effect(var/mob/u) //modify this for preset rituals
			return choose_Effects()

		post_ritual()
			visual_deactivation()
			tietary_add = 1
			is_going = 0
			cancelable = 0
			magnification = pre_magnification
			return