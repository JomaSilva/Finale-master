proc/magnitude_calc(var/stored_energy,var/magnitude,var/delimiter) //delimiter: M.Emagiskill * M.Magic
	var/amount = max((stored_energy - (delimiter)) * magnitude * (1/(3*sqrt(stored_energy*2))),0.1)
	if(amount > 2) amount = log(2,amount) + 1
	return amount

proc/effect_price_lookup(index)
	switch(index) //if something should be other than 1.25, include it here.
		if("e_appear") return 1.25
		if("e_disappear") return 1.25
		if("e_empower") return 1.25
		if("e_empower_p") return 1.25
		if("e_depower") return 1.8
		if("e_density") return 1.25
		if("e_icon") return 1.25
		if("e_activate_ritual") return 1.25
		if("e_pacify") return 1.25
		if("e_heal") return 1.25
		if("e_regenerate") return 1.25
		if("e_resurrect") return 1.25
		if("e_feed") return 2
		if("e_anger") return 2
		if("e_power_magic") return 2
		if("e_intelligence") return 2
		if("e_silence") return 3
		//manipulation good for now
		//destruction
		if("e_damage") return 2
		if("e_burn") return 4
		if("e_poison") return 5
		if("e_destroy") return 6
		if("e_consume") return 5
		//dimensional
		if("e_summon") return 2
		if("e_portal") return 4
		if("e_teleport") return 3
		if("e_polymorph") return 2.5
		if("e_timestop") return 5
		if("e_zombification") return 3
	return 1.25

proc/take_a_t_m_energy(atom/movable/source,atom/movable/nO)
	var/Magic
	Magic += max(0,convert_norm_to_magic_e(nO.stored_energy))
	Magic += max(0,convert_elec_to_mag_e(nO.elec_energy))
	Magic += nO.Magic
	Magic += max(0,convert_ki_to_magic_e(nO.Ki))
	nO.stored_energy -= nO.stored_energy
	nO.elec_energy -= nO.elec_energy
	nO.Magic -= nO.Magic
	nO.Ki -= nO.Ki
	return Magic

obj/Ritual/proc
	visual_activation()
		switch(icon_state)
			if("main1") icon_state = "1"
			if("main2") icon_state = "2"
			if("main3") icon_state = "3"
			if("main4") icon_state = "4"
			if("main5") icon_state = "5"
			if("main6") icon_state = "6"
			if("shade1") icon_state = "actshade1"
			if("shade2") icon_state = "actshade2"
			if("shade3") icon_state = "actshade3"
			if("shade4") icon_state = "actshade4"
			if("shade5") icon_state = "actshade5"
			if("shade6") icon_state = "actshade6"
			else icon_state = "activated"
		return
	visual_deactivation()
		switch(icon_state)
			if("1") icon_state = "main1"
			if("2") icon_state = "main2"
			if("3") icon_state = "main3"
			if("4") icon_state = "main4"
			if("5") icon_state = "main5"
			if("6") icon_state = "main6"
			if("actshade1") icon_state = "shade1"
			if("actshade2") icon_state = "shade2"
			if("actshade3") icon_state = "shade3"
			if("actshade4") icon_state = "shade4"
			if("actshade5") icon_state = "shade5"
			if("actshade6") icon_state = "shade6"
			if("activated") icon_state = ""
		return

var
	list/e_spell_index = list("e_speed","e_physoff","e_technique","e_kioff","e_magic","e_kiregen","e_appear","e_disappear","e_empower","e_empower_p","e_depower",
		"e_density","e_icon","e_activate_ritual","e_pacify","e_heal","e_regenerate","e_resurrect","e_power_magic","e_intelligence","e_damage","e_feed","e_anger","e_burn","e_poison",
		"e_destroy","e_consume","e_summon","e_portal","e_teleport","e_timestop","e_zombification","e_change_time","e_seal","e_etherial_form","e_telepathy",
		"e_change_weather","e_blutz_emit","e_full_moon","e_hell_star","e_day_noon","e_night_mid","e_vampirification","e_werewolfication","e_change_time","e_seal_s","e_give_soul_body",
		"e_take_soul_body","e_soul_rip","e_soul_restore")

	list/t_spell_index = list("t_tar_p_all_r","t_tar_p","t_tar_p_all_p","t_tar_m_w","t_tar_m_all_r","t_tar_p_w","t_tar_m_all_p","t_tar_m","t_tar_o_all_r","t_tar_o","t_tar_o_all_p",
		"t_tar_o_w","t_tar_r_all_r","t_tar_r","t_tar_r_all_p","t_tar_r_w","t_duplicate","t_funnel")

	list/p_spell_index = list("p_magnify","p_dissociate","p_disappear","p_add","p_subtract","p_siphon","p_sunlight_magnify","p_makyo_magnify","p_moonlight_magnify")

//items have three effects, take feather for instance:
//Beginning effect: burn for energy (small ritual change, either fuel, a requirement, or minor adjustments to the ritual.), so basically nothing
//Middle effect: target player in view (medium ritual change, usually a focus or something like that)
//End effect: enhance speed (large ritual change, only one, basically the point of the ritual)

//alright fuckers: you want to make a spell? here's how:
//1. conceptually figure out where the effect should end up (the school)
// a. if it's manipulating generally unexciting shit, manipulation.
// b. if it's destroying or otherwise expending energy outwards, destruction.
// c. if it's exotic or should be hard to do, dimensional.
//2. create effect, the general proc is:
/*e_kiregen(magnitude)
		if(target_check(2) == FALSE) return
		var/mob/M = r_target
		var/list/t_l = list("Tkiregen"=magnitude_calc(Magic,magnitude,M.Emagiskill * M.Magic))
		spawn M.TempBuff(t_l,1000 * magnitude) //1k seconds
		//then any visual effects
*/
//now, M.TempBuff() does not have every effect under the roof, you need to pop into base.dm in stats folder to see what it accepts.
//keep in mind the proc should be defined as /obj/Ritual/proc, and the key traits that are passed down is:
//Magic, invoker, magnitude, and thats it. Notice there are no references to the item/spell used.
//MAGNITUDE AND STORED_ENERGY SHOULD NEVER BE NEGATIVE!
//3. after creating the effect, add it to the correct index, and add it to the spell random list.
//4. finally, if you think your spell should multiply the cost by more/less than 1.25x, pop over to rituals.dm to add it to the cost index.
//5. done
//go over to magic_items.dm to add a ingredient with the spell index to see it possibly ingame. A word will automatically be assigned to it in new/reinitialized worlds.
