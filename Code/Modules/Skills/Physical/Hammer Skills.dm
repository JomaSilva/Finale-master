mob/keyable/combo/hammer/verb/Driving_The_Nail()
	set category = "Skills"
	set desc = "Stun your foe with a heavy blow. Hammer skill. Melee skill."
	if(!("Hammer" in usr.WeaponEQ))
		usr<<"You need a hammer equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Melee skills on CD for [meleeCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<9)
		usr<<"You can't use this now!"
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	spawn MeleeAttack(target,1.25)
	target.AddEffect(/effect/stun/Driving_The_Nail)
	usr.stamina-=9
	usr.meleeCD=8*Eactspeed

mob/keyable/combo/hammer/verb/Toll_The_Bell()
	set category = "Skills"
	set desc = "Charge a nearby foe. Inflicts Vulnerability on staggered foe. Hammer skill. Movement skill."
	if(!("Hammer" in usr.WeaponEQ))
		usr<<"You need a hammer equipped to use this!"
		return
	if(usr.movementCD)
		usr<<"Movement skills on CD for [movementCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<12)
		usr<<"You can't use this now!"
		return
	if(!usr.target||get_dist(usr,target)>4)
		for(var/mob/M in oview(1))
			if(M!=usr)
				target=M
				break
	if(!usr.target)
		usr<<"You have no target."
		return
	else
		if(get_dist(usr,target)>4)
			usr<<"You must be closer to your target to use this!"
			return
	var/lungetime = 6
	usr.movementCD=6*usr.Eactspeed
	usr.stamina-=12
	while(lungetime&&get_dist(usr,target)>1)
		step_towards(usr,target,32)
		sleep(1)
	if(get_dist(usr,target)>1)
		usr<<"Your target evaded your attack."
		return
	else
		if(target.stagger)
			spawn MeleeAttack(target,2.5)
			target.AddEffect(/effect/vulnerability)
		else
			spawn MeleeAttack(target)
			target.AddEffect(/effect/ministun)
	usr.movementCD+=6*usr.Eactspeed

mob/keyable/combo/hammer/verb/Crushing_Blow()
	set category = "Skills"
	set desc = "Smash the foe directly in front of you. If they are vulnerable, knocks them back and damages the two tiles behind them. Hammer skill. AoE skill."
	if(!("Hammer" in usr.WeaponEQ))
		usr<<"You need a hammer equipped to use this!"
		return
	if(usr.AoECD)
		usr<<"Melee AoE skills on CD for [AoECD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<12)
		usr<<"You can't use this now!"
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	usr.dir=get_dir(usr,target)
	var/turf/TA = get_step(usr,usr.dir)
	var/turf/TB = get_step(TA,usr.dir)
	var/turf/TC = get_step(TB,usr.dir)
	var/obj/Crater/impactcrater/ic = new()
	ic.loc = TA
	ic.dir = turn(dir, 180)
	var/counter
	for(var/effect/vulnerability/A in target.effects)
		counter++
	if(counter)
		target.emit_Sound('landharder.ogg')
		spawn MeleeAttack(target,2)
		target.kbdir=usr.dir
		target.kbpow=usr.expressedBP
		target.kbdur=6
		target.AddEffect(/effect/knockback)
		sleep(1)
		var/obj/Crater/impactcrater/id = new()
		id.loc = TB
		id.dir = turn(dir, 180)
		for(var/mob/A in TB)
			spawn MeleeAttack(A)
		sleep(1)
		var/obj/Crater/impactcrater/ie = new()
		ie.loc = TC
		ie.dir = turn(dir, 180)
		for(var/mob/B in TC)
			spawn MeleeAttack(B)
	else
		spawn MeleeAttack(target,1.5)
	usr.stamina-=12
	usr.AoECD=10*Eactspeed


mob/keyable/combo/hammer/verb/Shatter_Armor()
	set category = "Skills"
	set desc = "Deal a heavy blow, ignoring some of your opponent's armor. Hammer skill. Special skill."
	if(!("Hammer" in usr.WeaponEQ))
		usr<<"You need a hammer equipped to use this!"
		return
	if(usr.ultiCD)
		usr<<"Melee special skills on CD for [ultiCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<18)
		usr<<"You can't use this now!"
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*15
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 18*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	usr.AddEffect(/effect/piercing/Shatter_Armor)
	spawn MeleeAttack(target,2)
	target.emit_Sound('strongpunch.wav')