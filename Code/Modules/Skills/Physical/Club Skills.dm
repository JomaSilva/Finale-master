mob/keyable/combo/club/verb/Staggering_Impact()
	set category = "Skills"
	set desc = "Smash a foe, staggering them. Club skill. Melee skill."
	if(!("Club" in usr.WeaponEQ))
		usr<<"You need a club equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Melee skills on CD for [meleeCD/10] seconds."
		return
	 
	get_me_a_target()
	if(target_check() == FALSE) return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*10
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 8*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	spawn MeleeAttack(target,2)
	target.AddEffect(/effect/stagger/Staggering_Impact)

mob/keyable/combo/club/verb/Grand_Slam()
	set category = "Skills"
	set desc = "Smash all foes in three tile arc, knocking them back if they're staggered. Club skill. AoE skill."
	if(!("Club" in usr.WeaponEQ))
		usr<<"You need a club equipped to use this!"
		return
	if(usr.AoECD)
		usr<<"Melee AoE skills on CD for [AoECD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<13)
		usr<<"You can't use this now!"
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*13
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 13*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	var/turf/TA = get_step(usr,usr.dir)
	var/turf/TB = get_step(usr,turn(usr.dir,45))
	var/turf/TC = get_step(usr,turn(usr.dir,-45))
	for(var/mob/A in TA)
		if(A.stagger)
			spawn MeleeAttack(A,3)
			A.kbdir=usr.dir
			A.kbpow=usr.expressedBP
			A.kbdur=8
			A.AddEffect(/effect/knockback)
		else
			spawn MeleeAttack(A,1.5)
	for(var/mob/B in TB)
		if(B.stagger)
			spawn MeleeAttack(B,3)
			B.kbdir=usr.dir
			B.kbpow=usr.expressedBP
			B.kbdur=8
			B.AddEffect(/effect/knockback)
		else
			spawn MeleeAttack(B,1.5)
	for(var/mob/C in TC)
		if(C.stagger)
			spawn MeleeAttack(C,3)
			C.kbdir=usr.dir
			C.kbpow=usr.expressedBP
			C.kbdur=8
			C.AddEffect(/effect/knockback)
		else
			spawn MeleeAttack(C,1.5)
mob/keyable/combo/club/verb/Leaping_Smash()
	set category = "Skills"
	set desc = "Leap to a nearby target, doing bonus damage if they are staggered or knocked back. Club skill. Movement skill."
	if(!("Club" in usr.WeaponEQ))
		usr<<"You need a club equipped to use this!"
		return
	if(usr.movementCD)
		usr<<"Movement skills on CD for [movementCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<9)
		usr<<"You can't use this now!"
		return
	if(!usr.target||get_dist(usr,target)>5)
		for(var/mob/M in oview(1))
			if(M!=usr)
				target=M
				break
	if(!usr.target)
		usr<<"You have no target."
		return
	else
		if(get_dist(usr,target)>5)
			usr<<"You must be closer to your target to use this!"
			return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*9
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	flick("Attack",usr)
	spawn(3)
		if(usr.flight)
			usr.icon_state="Flight"
	emit_Sound('buku.wav')
	sleep(2)
	emit_Sound('buku_land.wav')
	usr.loc=get_step(target,target.dir)
	if(target.stagger||target.KB)
		spawn MeleeAttack(target,3)
	else
		spawn MeleeAttack(target,1)
	target.AddEffect(/effect/slow)
	usr.stamina-=9
	usr.movementCD=15*Eactspeed

mob/keyable/combo/club/verb/Earthquake()
	set category = "Skills"
	set desc = "Smash the ground in front of you in a 3x3 area. Club skill. Special skill."
	if(!("Club" in usr.WeaponEQ))
		usr<<"You need a club equipped to use this!"
		return
	if(usr.ultiCD)
		usr<<"Melee special skills on CD for [ultiCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<18)
		usr<<"You can't use this now!"
		return
	if(!usr.target||get_dist(usr,target)>2)
		for(var/mob/M in oview(1))
			if(M!=usr)
				target=M
				break
	if(!usr.target)
		usr<<"You have no target."
		return
	else
		if(get_dist(usr,target)>2)
			usr<<"You must be next to your target to use this!"
			return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*18
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	usr.dir = get_dir(usr,target)
	var/turf/T = get_step(usr,usr.dir)
	var/obj/Crater/impactcrater/ic = new()
	ic.loc = T
	ic.dir = turn(dir, 180)
	ic.transform*=3
	emit_Sound('landharder.ogg')
	for(var/mob/A in view(1,T))
		if(A==usr)
			continue
		else
			spawn MeleeAttack(A,1.5)
			step_away(A,T)