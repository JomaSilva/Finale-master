/obj/Ritual
	proc/
		//effects
		choose_Effects()
			for(var/indL, indL <= ingredients.len, indL++)
				indL = max(indL,1)
				//world << "gothere, chooseeffects: [Magic] [indL]"
				var/atom/movable/I = ingredients[indL]
				if(I)
					var/t_ind
					if(ingredients.len == 5)
						switch(indL)
							if(1 to 2) t_ind = 1
							if(3 to 4) t_ind = 2
							if(5) t_ind = 3
					else if(ingredients.len==4)
						switch(indL)
							if(1 to 2) t_ind = 1
							if(3) t_ind = 2
							if(4) t_ind = 3
					else
						t_ind = indL
					var/magnitude = min(Magic,1)
					magnitude *= magnification
					magnitude = max(round(log(4,magnitude),0.1),0)
					//world << "gothere, chooseeffects, 2: [Magic] [indL]"
					if(!isnull(I.mag_effects[t_ind]))
						switch(t_ind)
							if(1)
								//world << "gothere, chooseeffects, primary: [Magic] [indL] primary"
								do_primary(I.mag_effects[t_ind],rit_en_conv(I.Magic + Magic))
							if(2)
								//world << "gothere, chooseeffects, secondary: [Magic] [indL] secondary"
								do_secondary(I.mag_effects[t_ind],rit_en_conv(I.Magic + Magic))
							if(3)
								while(tietary_add)
									tietary_add--
									//could add spell effects here, based on element.
									//fire: fireball icon missiles to target, does a small explosion, then the spell effect happens.
									//world << "gothere, chooseeffects, tietary: [Magic] [indL] tietary"
									if(do_tietary(I.mag_effects[t_ind],rit_en_conv(I.Magic + Magic)) == 666) return 666
									if(tietary_add) sleep(tietary_add_modifier)
			return TRUE
		rit_en_conv(var/num)
			return sqrt(num * invoker.Emagiskill)
		do_primary(index,magnitude)
			//world << "p index [index], mag [magnitude]"
			switch(index)
				if("p_magnify") p_magnify(magnitude)
				if("p_dissociate") p_dissociate(magnitude)
				if("p_disappear") p_disappear(magnitude)
				if("p_add") p_add(magnitude)
				if("p_subtract") p_subtract(magnitude)
				if("p_siphon") p_siphon(magnitude)
				if("p_moonlight_magnify") p_moonlight_magnify(magnitude)
				if("p_sunlight_magnify") p_sunlight_magnify(magnitude)
				if("p_makyo_magnify") p_makyo_magnify(magnitude)
		do_secondary(index,magnitude)
			//world << "t index [index], mag [magnitude] invoker [invoker]"
			switch(index)
				//targeting
				if("t_tar_p_all_r") t_tar_p_all_r(magnitude) //players
				if("t_tar_p") t_tar_p()
				if("t_tar_p_all_p") t_tar_p_all_p() //p means planetwide targeting
				if("t_tar_p_w") t_tar_p_w() //w means world targeting (i.e. serverwide)


				if("t_tar_m_all_r") t_tar_m_all_r(magnitude) //mobs
				if("t_tar_m") t_tar_m()
				if("t_tar_m_all_p") t_tar_m_all_p()
				if("t_tar_m_w") t_tar_m_w()

				if("t_tar_o_all_r") t_tar_o_all_r(magnitude) //obj
				if("t_tar_o") t_tar_o()
				if("t_tar_o_all_p") t_tar_o_all_p()
				if("t_tar_o_w") t_tar_o_w()

				if("t_tar_r_all_r") t_tar_r_all_r(magnitude) //rituals
				if("t_tar_r") t_tar_r()
				if("t_tar_r_all_p") t_tar_r_all_p()
				if("t_tar_r_w") t_tar_r_w()

				//if("t_tar_t_all_v") t_tar_t_all_v(magnitude) //turfs
				//other misc
				if("t_duplicate") t_duplicate(magnitude) //duplicates the spell
				if("t_funnel") t_funnel(magnitude) //funnels other rituals into it
		do_tietary(index,magnitude)
			//world << "e index [index], mag [magnitude] invoker [invoker]"
			var/a = max(multiple_targets.len,1)
			while(a >= 1)
				if(multiple_targets.len)
					r_target = multiple_targets[a]
				a--
				switch(index)
					if("e_speed") e_speed(magnitude)
					if("e_physoff") e_physoff(magnitude)
					if("e_physdef") e_physdef(magnitude)
					if("e_technique") e_technique(magnitude)
					if("e_kioff") e_kioff(magnitude)
					if("e_kidef") e_kidef(magnitude)
					if("e_magic") e_magic(magnitude)
					if("e_kiregen") e_kiregen(magnitude)
					if("e_appear") e_appear(magnitude)
					if("e_disappear") e_disappear(magnitude)
					if("e_empower") e_empower(magnitude)
					if("e_empower_p") e_empower_p(magnitude)
					if("e_depower") e_depower(magnitude)
					if("e_density") e_density(magnitude)
					if("e_icon") e_icon(magnitude)
					if("e_activate_ritual") e_activate_ritual(magnitude)
					if("e_pacify") e_pacify(magnitude)
					if("e_heal") e_heal(magnitude)
					if("e_regenerate") e_regenerate(magnitude)
					if("e_feed") e_feed(magnitude)
					if("e_anger") e_anger(magnitude)
					if("e_power_magic") e_power_magic(magnitude)
					if("e_intelligence") e_intelligence(magnitude)
					if("e_change_weather") e_change_weather(magnitude)
					if("e_blutz_emit") e_blutz_emit(magnitude)
					if("e_full_moon") e_full_moon()
					if("e_hell_star") e_hell_star()
					if("e_day_noon") e_day_noon()
					if("e_night_mid") e_night_mid()
					if("e_seal") e_seal(magnitude)
					if("e_etherial_form") e_etherial_form(magnitude)
					if("e_telepathy") e_telepathy(magnitude)
					if("e_vampirification") e_vampirification(magnitude)
					if("e_werewolfication") e_werewolfication(magnitude)
					if("e_change_time") e_change_time(magnitude)
					if("e_seal_s") e_seal_s(magnitude)
					if("e_silence") e_silence(magnitude)
					if("e_give_soul_body") e_give_soul_body()
					if("e_take_soul_body") e_give_soul_body()
					//manipulation good for now
					//destruction
					if("e_damage") e_damage(magnitude)
					if("e_burn") e_burn(magnitude)
					if("e_poison") e_poison(magnitude)
					if("e_destroy") e_destroy(magnitude)
					if("e_consume") e_consume(magnitude)
					//dimensional
					if("e_resurrect") e_resurrect(magnitude)
					if("e_summon") e_summon(magnitude)
					if("e_portal") e_portal(magnitude)
					if("e_teleport") e_teleport(magnitude)
					if("e_polymorph") e_polymorph(magnitude)
					if("e_timestop") e_timestop(magnitude)
					if("e_zombification") e_zombification(magnitude)
					if("e_soul_rip") e_soul_rip()
					if("e_soul_restore") e_soul_restore()
					//
					if("e_godki_ritual") e_godki_ritual()