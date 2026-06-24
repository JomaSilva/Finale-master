mob/keyable/combo/spear/verb/Lunge()
	set category = "Skills"
	set desc = "Lunge at a nearby foe, slowing them. Spear skill. Movement skill."
	if(!("Spear" in usr.WeaponEQ))
		usr<<"You need a spear equipped to use this!"
		return
	if(usr.movementCD)
		usr<<"Movement skills on CD for [movementCD/10] seconds."
		return
	 
	if(!usr.target||get_dist(usr,target)>6)
		for(var/mob/M in oview(6))
			if(M!=usr)
				target=M
				break
	if(!usr.target)
		usr<<"You have no target."
		return
	else
		if(get_dist(usr,target)>6)
			usr<<"You must be closer to your target to use this!"
			return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*5
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 5*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	var/lungetime = 8//we'll give 7 steps worth in case the target is moving
	while(lungetime&&get_dist(usr,target)>1)
		step_towards(usr,target,32)
		sleep(1)
	if(get_dist(usr,target)>1)
		usr<<"Your target evaded your lunge."
		return
	else
		spawn MeleeAttack(target,2)
		target.AddEffect(/effect/slow/Lunge)
		usr.movementCD+=4*usr.Eactspeed

mob/keyable/combo/spear/verb/Javelin_Toss()
	set category = "Skills"
	set desc = "Throw a spear. Homes in on your target if they are slowed. Spear skill. Ranged skill."
	if(!("Spear" in usr.WeaponEQ))
		usr<<"You need a spear equipped to use this!"
		return
	if(usr.rangedCD)
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<7)
		usr<<"You can't use this now!"
		return
	var/passbp = expressedBP
	var/kireq=usr.Ephysoff*BaseDrain*0.4*10
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
	var/bcolor='Javelin Throw.dmi'
	bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
	var/obj/attack/blast/A=new/obj/attack/blast
	usr.emit_Sound('meleemiss2.wav',0.5)
	A.loc=locate(usr.x,usr.y,usr.z)
	A.icon=bcolor
	A.avoidusr=1
	A.density=1
	A.basedamage=1+usr.damage/4
	A.BP=passbp
	A.physdamage=1
	A.mods=(usr.Ephysoff**2)*usr.Etechnique
	A.murderToggle=usr.murderToggle
	A.proprietor=usr
	A.ownkey=usr.displaykey
	A.dir=usr.dir
	A.ogdir=usr.dir
	spawn A.Burnout()
	if(usr.target&&usr.target.slowed)
		walk_towards(A,target)
	else walk(A,usr.dir)
	spawn AddExp(usr,/datum/mastery/Melee/Spear_Mastery,5)
	usr.rangedCD=10

mob/keyable/combo/spear/verb/Compass_Rose()
	set category = "Skills"
	set desc = "Attack in each of the cardinal directions. Spear skill. AoE skill."
	if(!("Spear" in usr.WeaponEQ))
		usr<<"You need a spear equipped to use this!"
		return
	if(usr.AoECD)
		usr<<"Melee AoE skills on CD for [AoECD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<14)
		usr<<"You can't use this now!"
		return
	var/turf/TA = get_step(usr,NORTH)
	var/turf/TB = get_step(usr,SOUTH)
	var/turf/TC = get_step(usr,EAST)
	var/turf/TD = get_step(usr,WEST)
	updateOverlay(/obj/overlay/effects/flickeffects/compassrose)
	spawn(3) removeOverlay(/obj/overlay/effects/flickeffects/compassrose)
	for(var/mob/A in TA)
		spawn MeleeAttack(A,1.5)
	for(var/mob/B in TB)
		spawn MeleeAttack(B,1.5)
	for(var/mob/C in TC)
		spawn MeleeAttack(C,1.5)
	for(var/mob/D in TD)
		spawn MeleeAttack(D,1.5)
	usr.stamina-=14
	usr.AoECD=10*usr.Eactspeed

mob/keyable/combo/spear/verb/High_Jump()
	set category = "Skills"
	set desc = "Jump and impale a nearby foe, slowing them and dealing heavy damage. Spear skill. Special skill."
	if(!("Spear" in usr.WeaponEQ))
		usr<<"You need a spear equipped to use this!"
		return
	if(usr.ultiCD)
		usr<<"Melee special skills on CD for [ultiCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<12)
		usr<<"You can't use this now!"
		return
	if(!usr.target||get_dist(usr,target)>8)
		for(var/mob/M in oview(1))
			if(M!=usr)
				target=M
				break
	if(!usr.target)
		usr<<"You have no target."
		return
	else
		if(get_dist(usr,target)>8)
			usr<<"Your target is out of range!"
			return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*12
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 20*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	flick("Attack",usr)
	spawn(3)
		if(usr.flight)
			usr.icon_state="Flight"
	usr.emit_Sound('buku.wav',0.5)
	sleep(2)
	usr.emit_Sound('buku_land.wav',0.5)
	usr.loc=get_step(target,turn(target.dir,180))
	spawn MeleeAttack(target,3)
	target.AddEffect(/effect/slow/High_Jump)
	usr.stamina-=12
	usr.ultiCD=20*usr.Eactspeed