mob/keyable/combo/axe/verb/Logsplitter()
	set category = "Skills"
	set desc = "Strike a foe with your axe. Inflicts Bleed. Axe skill. Melee skill."
	if(!("Axe" in usr.WeaponEQ))
		usr<<"You need an axe equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Melee skills on CD for [meleeCD/10] seconds."
		return
	 
	get_me_a_target()
	if(target_check() == FALSE) return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*10
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 10*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	usr.emit_Sound('strongpunch.wav',0.5)
	spawn MeleeAttack(target,3)
	target.AddEffect(/effect/bleed/logsplitter)
	for(var/effect/bleed/logsplitter/b in target.effects)
		if(b.sub_id=="Logsplitter"&&b.active)
			b.damage = usr.axeskill/200
			b.theselection = usr.selectzone
			b.murdertoggle = usr.murderToggle

mob/keyable/combo/axe/verb/Reaver()
	set category = "Skills"
	set desc = "Strike foes in a 3 tile arc. Inflicts more damage to bleeding targets. Axe skill. AoE skill."
	if(!("Axe" in usr.WeaponEQ))
		usr<<"You need an axe equipped to use this!"
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
	usr.dir = get_dir(usr,target)
	usr.updateOverlay(/obj/overlay/effects/flickeffects/reaver)
	var/turf/TA = get_step(usr,usr.dir)
	var/turf/TB = get_step(usr,turn(usr.dir,45))
	var/turf/TC = get_step(usr,turn(usr.dir,-45))
	for(var/mob/A in TA)
		var/bleedcount=0
		for(var/effect/bleed/b in A.effects)
			if(b.active)
				bleedcount++
		if(bleedcount)
			spawn MeleeAttack(A,3*bleedcount)
		else
			spawn MeleeAttack(A,1.5)
	for(var/mob/B in TB)
		var/bleedcount=0
		for(var/effect/bleed/b in B.effects)
			if(b.active)
				bleedcount++
		if(bleedcount)
			spawn MeleeAttack(B,3*bleedcount)
		else
			spawn MeleeAttack(B,1.5)
	for(var/mob/C in TC)
		var/bleedcount=0
		for(var/effect/bleed/b in C.effects)
			if(b.active)
				bleedcount++
		if(bleedcount)
			spawn MeleeAttack(C,3*bleedcount)
		else
			spawn MeleeAttack(C,1.5)

mob/keyable/combo/axe/verb/Headsman()
	set category = "Skills"
	set desc = "Multi hit melee attack, stuns and knocks back. Axe skill. Melee skill."
	if(!("Axe" in usr.WeaponEQ))
		usr<<"You need an axe equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Melee skills on CD for [meleeCD/10] seconds."
		return
	 
	get_me_a_target()
	if(target_check() == FALSE) return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*15
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	usr.target.AddEffect(/effect/stun)
	spawn MeleeAttack(usr.target,1.5)
	sleep(1)
	spawn MeleeAttack(usr.target,1.5)
	sleep(1)
	spawn MeleeAttack(usr.target,2)
	usr.target.kbdir=usr.dir
	usr.target.kbpow=usr.expressedBP
	usr.target.kbdur=5
	usr.target.AddEffect(/effect/knockback)

mob/keyable/combo/axe/verb/Brutal_Cleaver()
	set category = "Skills"
	set desc = "Throw an axe at your target, teleporting to them and striking when it lands. Inflicts Bleeding. Axe skill. Special skill."
	if(!("Axe" in usr.WeaponEQ))
		usr<<"You need an axe equipped to use this!"
		return
	if(usr.ultiCD)
		usr<<"Melee special skills on CD for [ultiCD/10] seconds."
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
			usr<<"Your target is out of range!"
			return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*15
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	var/passbp = expressedBP
	flick("Attack",usr)
	spawn(3)
		if(usr.flight)
			usr.icon_state="Flight"
	var/bcolor='Brutal Cleaver.dmi'
	var/obj/attack/blast/A=new/obj/attack/blast
	emit_Sound('meleemiss2.wav',0.5)
	A.loc=locate(usr.x,usr.y,usr.z)
	A.icon=bcolor
	A.avoidusr=1
	A.density=1
	A.basedamage=1+usr.damage
	A.BP=passbp
	A.physdamage=1
	A.mods=(usr.Ephysoff**2)*usr.Etechnique
	A.murderToggle=usr.murderToggle
	A.proprietor=usr
	A.ownkey=usr.displaykey
	A.dir=usr.dir
	A.ogdir=usr.dir
	spawn A.Burnout()
	walk_towards(A,usr.target,0,32)
	while(A&&A.loc)
		usr.ultiCD+=2
		sleep(1)
	usr.loc=get_step(target,target.dir)
	spawn MeleeAttack(target,3)
	target.AddEffect(/effect/bleed/brutalcleave)
	for(var/effect/bleed/brutalcleave/b in target.effects)
		if(b.sub_id=="Brutalcleave"&&b.active)
			b.damage = usr.axeskill/100
			b.theselection = usr.selectzone
			b.murdertoggle = usr.murderToggle
	usr.ultiCD+=20*usr.Eactspeed