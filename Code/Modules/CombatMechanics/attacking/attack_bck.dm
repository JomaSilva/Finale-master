mob/var
	canbeleeched=0
	knockbackon = 1
	attack_flavor = 1
	do_dash = 0
	tmp
		//
		minuteshot_ig_ki = 1
		//
		dash_cool = 0
		choreoattk = 0
		post_attack = 0
		attacked_stun = 0
		combo_count = 0
		//
		rand_step_cool = 0
		//
		pressing_space = 0
		//
		choke_cooldown = 0
		//this means you can do less timing and more focusing on other things (i.e. spam to win)
//

mob/verb/attackspaced()
	set hidden = 1
	if(typing) return
	Attack()


mob/verb/Dash_Flight_Toggle()
	set category = "Other"
	if(do_dash)
		do_dash = 0
		usr << "You won't fly during homing or rushes. --Speed"
	else
		do_dash = 1
		usr << "You'll fly during homing or rushes. ++Speed (with drain)"
//
mob/verb/Attack()
	set category="Skills"
	if(pressing_space) return
	else pressing_space = 1
	if(grabbee && !is_choking && !is_stretched && !choke_cooldown)
		is_choking = 1
		emit_Sound('mediumpunch.wav')
		view(usr)<<"<b><font color=red>[usr] is choking [grabbee]!!!"
		choke_cooldown = 1
		spawn(5) choke_cooldown = 0//because sometimes this goes by very fast
		pressing_space=0
		return
	else if(grabbee && !is_stretched && !choke_cooldown)
		is_choking = 0
		choke_cooldown = 1
		spawn(5) choke_cooldown = 0
		view(usr)<<"<b><font color=red>[usr] is no longer choking [grabbee]!"
		pressing_space=0
		return
	else if(is_stretched)
		view(usr)<<"<b><font color=red>[usr] slams [grabbee] into the ground!!"
	if(KBcanCancel && KBParalysis && !kbcanceled)
		if(Ki >= MaxKi * 0.05)
			Ki -= MaxKi * 0.05
			kbcanceled = 1
			KBcanCancel = 0
			KBParalysis = 0
			pressing_space = 0
			return
	//OutputDebug("[src]: Attack, line 172.")
	if(testAttack() == FALSE) return FALSE
	if(choreoattk)
		pressing_space=0
		return
	else choreoattk = 1
	get_me_a_target()
	var/skip_delays = 0
	var/move_boost = 1
	if(dashing) move_boost *=2
	if(target && (get_dist(src.loc,target.loc) >= 2 || curdir) && get_dist(src.loc,target.loc) < 15 && !post_attack && !dash_cool)
		var/calc = (Espeed / target.Espeed) * BPModulus(expressedBP,target.expressedBP)
		dash_cool=2
		skip_delays=1
		if(Ki >= 15 * BaseDrain)
			Ki -= 15 * BaseDrain
			if(haszanzo && get_dist(src.loc,target.loc) < 6 * calc)
				var/turf/nT = pick(oview(1,target))
				if(isturf(nT))
					src.Move(nT)
					src.dir=get_dir(src,target)
					flick('Zanzoken.dmi',usr)
					emit_Sound('teleport.wav')
			else
				if(flightability > 1)
					RushAttack(target,1.5 * calc*move_boost)
				else RushAttack(target,1.25 * calc*move_boost)
				RushComplete = 0
	else if(target && get_dist(src.loc,target.loc) <= 3 && get_dist(src.loc,target.loc) > 1)
		skip_delays=1
		if(haszanzo && !dash_cool)
			dash_cool=2
			if(Ki >= 10 * BaseDrain)
				Ki -= 10 * BaseDrain
				var/turf/nT = pick(oview(1,target))
				nT = nT.GetTurf()
				src.Move(nT)
				src.dir=get_dir(src,target)
				flick('Zanzoken.dmi',usr)
				emit_Sound('teleport.wav')
		else
			step(src,get_dir(src,target),32*move_boost)
			dir = get_dir(src,target)
	else
		if(target && get_dist(src.loc,target.loc) < 15)
			step(src,get_dir(src,target),32*move_boost)
			dir = get_dir(src,target)
		if(!target)
			var/mob/M = null
			for(var/mob/nM in view(10))
				if(ismob(M))
					if(get_dist(src,M) > get_dist(src,nM))
						M = nM
				else M = nM
			skip_delays=1
			step(src,get_dir(src,M),32*move_boost)
			if(dashing && get_dist(src,M) >= 2)
				if(Ki >= 15 * BaseDrain && haszanzo && get_dist(src.loc,target.loc) > 2)
					Ki -= 15 * BaseDrain
					var/turf/nT = pick(oview(1,M))
					nT = nT.GetTurf()
					src.Move(nT)
					src.dir=get_dir(src,M)
					flick('Zanzoken.dmi',usr)
					emit_Sound('teleport.wav')
	if(dashing) updateOverlay(/obj/overlay/attackaura,image('Attack strength indicator concept.dmi',src,"Heavy",MOB_LAYER+1))
	else updateOverlay(/obj/overlay/attackaura,image('Attack strength indicator concept.dmi',src,"Light",MOB_LAYER+1))
	if(combat_queue.len >= 1 && !isNPC)
		pressing_space=0
		//updateOverlay(/obj/overlay/effects/flickeffects/attack_indicat_l)
		var/obj/hotkey/H = combat_queue[1]
		combat_queue.Remove(H)
		combat_queue -= H
		combat_queue.Cut(1,1)//FUCK combat queue holy shit it just aint cutting shit from the list
		for(var/verb/V in H.storeverb)
			call(src,V)()
			break
		post_attack = 1
		choreoattk = 0
		//attacking=0
		pressing_space=0
		return
	if(combo_count > 2)
		dashing = 1
	var/dash_delay = 0
	if(dashing) dash_delay += 2
	combo_count = 0
	if(!skip_delays)
		sleep(max(1,dash_delay+5 - (speedDIFF * log(1.9,Espeed + Etechnique))))
		if(curdir && get_dist(src,target)>1) step(src,get_dir(src,target),32)
		if(target) src.dir=get_dir(src,target)
	choreoattk = 0
	if(testAttack() == FALSE) return FALSE
	MeleeAttack(null,null,null,null,1 + dash_delay)
	post_attack = 1
	choreoattk = 0
	//attacking=0
	pressing_space=0
	if(combo_count > 2 || dashing)
		combo_count = 0

/obj/overlay/attackaura
	EffectStart()
		..()
		spawn(5)
			EffectEnd()
mob/proc/testAttack()
	if(attacking || !isnull(grabbee) || !hasTime || blocking || !canfight || KO || istype(src,/mob/lobby))
		choreoattk = 0
		pressing_space=0
		return FALSE
	return TRUE
/*mob/verb/Auto_Attack()
	set category="Skills"
	if(!usr.AutoAttack)
		usr<<"<b><font color=yellow>You start auto attacking."
		usr.AutoAttack=1
		return
	if(usr.AutoAttack)
		usr.AutoAttack=0
		usr<<"<b><font color=yellow>You stop auto attacking."
		return*/
mob/verb/Knockback()
	set category="Other"
	if(!usr.knockbackon)
		usr<<"<b><font color=yellow>Knockback on."
		oview(usr)<<"[usr]'s fists shove with a bit more weight!"
		usr.knockbackon=1
		return
	if(usr.knockbackon)
		usr.knockbackon=0
		usr<<"<b><font color=yellow>Knockback off."
		oview(usr)<<"[usr]'s fists shove with a bit less weight!"
		return

mob/proc/RandLimbInjury()
	for(var/datum/Body/B in body)
		if(!B.lopped)
			B.health -= 10

mob/proc/get_me_a_target()
	if(!target)
		var/gotgotten=0
		for(var/mob/M in get_step(src,dir))
			if(!M in Party)
				target = M
				gotgotten=1
				break
		if(!gotgotten)
			for(var/mob/M in oview(1))
				if(!M in Party)
					target = M
					gotgotten=1
					break
		if(!gotgotten)
			for(var/mob/M in oview(2))
				if(!M in Party)
					target = M
					gotgotten=1
					break
	return target