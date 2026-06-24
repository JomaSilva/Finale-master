mob/keyable/combo/sword/verb/Blade_Rush()
	set category = "Skills"
	set desc = "Rush through your target, striking twice. Sword skill. Melee skills."
	if(!("Sword" in usr.WeaponEQ))
		usr<<"You need a sword equipped to use this!"
		return
	if(usr.meleeCD)
		usr<<"Melee skills on CD for [meleeCD/10] seconds."
		return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*8
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	var/rushdir = get_dir(usr,target)
	updateOverlay(/obj/overlay/effects/flickeffects/bladerush)
	usr.AddEffect(/effect/undense)
	spawn MeleeAttack(target)
	var/turf/T = get_step(usr,rushdir)
	if(!T.density)
		step(usr,rushdir)
	sleep(2)
	spawn MeleeAttack(target)
	T = get_step(usr,rushdir)
	if(!T.density)
		step(usr,rushdir)
	usr.RemoveEffect(/effect/undense)
mob/keyable/combo/sword/verb/Wind_Slice()
	set category = "Skills"
	set desc = "Slash a blade of wind forward. Sword skill. Ranged skill."
	if(!("Sword" in usr.WeaponEQ))
		usr<<"You need a sword equipped to use this!"
		return
	if(usr.rangedCD)
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<4)
		usr<<"You can't use this now!"
		return
	var/passbp = expressedBP
	var/kireq=usr.Ephysoff*BaseDrain*0.4*4
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
	var/bcolor='Zankoukyokuha.dmi'
	bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
	var/obj/attack/blast/A=new/obj/attack/blast
	emit_Sound('meleemiss2.wav')
	A.loc=locate(usr.x,usr.y,usr.z)
	A.icon=bcolor
	A.avoidusr=1
	A.density=1
	A.basedamage=1+usr.damage/2
	A.BP=passbp
	A.physdamage=1
	A.mods=(usr.Ephysoff**2)*usr.Etechnique
	A.murderToggle=usr.murderToggle
	A.proprietor=usr
	A.ownkey=usr.displaykey
	A.dir=usr.dir
	A.ogdir=usr.dir
	spawn A.Burnout()
	walk(A,usr.dir)
	spawn AddExp(usr,/datum/mastery/Melee/Sword_Mastery,5)
	usr.rangedCD=10

mob/keyable/combo/sword/verb/Whirling_Blades()
	set category = "Skills"
	set desc = "Attack all foes around you twice. Sword skill. AoE skill."
	if(!("Sword" in usr.WeaponEQ))
		usr<<"You need a sword equipped to use this!"
		return
	if(usr.AoECD)
		usr<<"Melee AoE skills on CD for [AoECD/10] seconds."
		return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*10
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 10*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	updateOverlay(/obj/overlay/effects/flickeffects/whirlingblades)
	for(var/mob/M in oview(1))
		spawn MeleeAttack(M,0.75)
	sleep(2)
	for(var/mob/M in oview(1))
		spawn MeleeAttack(M,0.75)
	removeOverlay(/obj/overlay/effects/flickeffects/whirlingblades)
	usr.AoECD = round(10*usr.Eactspeed)

mob/keyable/combo/sword/verb/Bladestorm()
	set category = "Skills"
	set desc = "Knock your target back and repeatedly teleport behind them, knocking them back again. Sword skill. Special skill."
	if(!("Sword" in usr.WeaponEQ))
		usr<<"You need a sword equipped to use this!"
		return
	if(usr.ultiCD)
		usr<<"Melee special skills on CD for [ultiCD/10] seconds."
		return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*12
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 15*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	get_me_a_target()
	if(target_check() == FALSE) return
	var/rushnum = round((usr.weaponry+usr.swordskill)/20)
	var/rushcount = 0
	while(rushcount<rushnum)
		rushcount++
		ultiCD+=10
		if(!canmove||usr.KO)
			usr<<"Your attack failed because you can't move!"
			break
		if(usr.z!=target.z)
			usr<<"Your target is out of range!"
			break
		flick('Zanzoken.dmi',usr)
		var/targarea=get_step(target,turn(target.dir,pick(180,135,225)))
		usr.Move(targarea)
		usr.dir=get_dir(usr,target)
		spawn usr.MeleeAttack(target)
		target.kbdir=usr.dir
		target.kbpow=usr.expressedBP
		target.kbdur=4
		target.AddEffect(/effect/knockback)
		emit_Sound('teleport.wav')
		sleep(3)
	usr.ultiCD+=round(10*usr.Eactspeed)