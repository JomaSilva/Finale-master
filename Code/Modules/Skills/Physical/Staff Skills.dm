mob/keyable/combo/staff/verb/Spinning_Strike()
	set category = "Skills"
	set desc = "Strike a foe so hard they become dizzy. Staff skill. Melee skill."
	if(!("Staff" in usr.WeaponEQ))
		usr<<"You need a staff equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Melee skills on CD for [meleeCD/10] seconds."
		return
	 
	var/kireq=usr.Ephysoff*BaseDrain*0.4*5
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 5*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	spawn MeleeAttack(target)
	target.AddEffect(/effect/dizzy)
	target.dir = usr.dir
	usr.meleeCD=6*usr.Eactspeed

mob/keyable/combo/staff/verb/Pole_Vault()
	set category = "Skills"
	set desc = "Leap to a nearby target, stunning them if they are dizzy or facing away. Staff skill. Movement skill."
	if(!("Staff" in usr.WeaponEQ))
		usr<<"You need a staff equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Movement skills on CD for [movementCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<8)
		usr<<"You can't use this now!"
		return
	if(!usr.target||get_dist(usr,target)>4)
		for(var/mob/M in oview(4))
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
	var/kireq=usr.Ephysoff*BaseDrain*0.4*8
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 10*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	flick("Attack",usr)
	spawn(3)
		if(usr.flight)
			usr.icon_state="Flight"
	usr.emit_Sound('buku.wav',volume=0.5)
	sleep(1)
	usr.emit_Sound('buku_land.wav',volume=0.5)
	usr.loc=get_step(target,target.dir)
	if(usr.dir!=turn(target.dir,180)||target.dizzy)
		spawn MeleeAttack(target,2.5)
		spawn target.AddEffect(/effect/stun)
	else
		spawn MeleeAttack(target)
	usr.movementCD=10*Eactspeed

mob/keyable/combo/staff/verb/Flexible_Defense()
	set category = "Skills"
	set desc = "Counter attacking foes up to 5 times for the next 5 seconds. Staff skill. Temporary buff skill."
	if(!("Staff" in usr.WeaponEQ))
		usr<<"You need a staff equipped to use this!"
		return
	if(usr.counterCD)
		usr<<"Counter skills on CD for [counterCD/10] seconds."
		return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*15
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 20*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	emit_Sound('parry.ogg')
	usr.AddEffect(/effect/counter/Flexible_Defense)
	usr.counterCD=20*Eactspeed

mob/keyable/combo/staff/verb/Around_The_World()
	set category = "Skills"
	set desc = "Attack all foes around you, stunning them if they are dizzy or facing away. Otherwise slow them. Staff skill. Special skill."
	if(!("Staff" in usr.WeaponEQ))
		usr<<"You need a staff equipped to use this!"
		return
	if(usr.ultiCD)
		usr<<"Melee special skills on CD for [ultiCD/10] seconds."
		return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*5
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	for(var/mob/A in oview(1))
		spawn MeleeAttack(A,2)
		if(A.dizzy||usr.dir!=turn(target.dir,180))
			step_away(A,usr)
			sleep(1)
			step_away(A,usr)
			A.AddEffect(/effect/stun)
		else
			A.AddEffect(/effect/slow)
	usr.ultiCD=15*Eactspeed