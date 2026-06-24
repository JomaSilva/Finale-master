mob/proc/compileRangeMobList()
	var/list/moblist = list()
	if(!target in get_step(src,dir) && !target in get_step(src,turn(dir,-45)) && !target in get_step(src,turn(dir,45)))
		turn_towards(src,target,45)
	for(var/mob/tM in view(1,src))
		//OutputDebug("test [tM]")
		if(tM == src) continue
		if(tM in get_step(src,dir))
		//	OutputDebug("test")
			moblist += tM
		else if(tM in get_step(src,turn(dir,-45)))
		//	OutputDebug("test2")
			moblist += tM
		else if(tM in get_step(src,turn(dir,45)))
		//	OutputDebug("test1")
			moblist += tM
		else if(Etechnique >= 5 && tM in get_step(src,turn(dir,-90)) && tM in get_step(src,turn(dir,90)))
			moblist += tM
		else if(tM in loc)
			moblist += tM
		continue
	//OutputDebug("test3")
	/*for(var/mob/tM in get_step(src,dir))
		moblist += tM
	for(var/mob/tM in get_step(src,turn(dir,-45)))
		OutputDebug("mobhere -45")
		moblist += tM
	for(var/mob/tM in get_step(src,turn(dir,45)))
		moblist += tM*/
	for(var/mob/tM in moblist)
		for(var/mob/p in Party)
			if(tM.name==p&&fftoggle==0)
				moblist -= tM
				break
	return moblist

/*mob/proc/compileRangeMobList() new wip behavior, faster.
	var/list/moblist = list()
	for(var/mob/M in oview(1,src))
		if(M in get_step(src,dir)||M in get_step(src,turn(dir,45))||M in get_step(src,turn(dir,-45)))
			var/check = 1
			for(var/mob/p in Party)
				if(M.name==p&&fftoggle==0)
					check = 0
					break
			if(check==0) continue
			moblist += M
		else continue
	return moblist*/

//First step: Undense players when they enter in combat, to each other. Not anymore, but you can do '|| M.IsInCombat' or something to make it werk.
mob/Cross(atom/movable/O)
	if(ismob(O))
		var/mob/M = O
		if(M.flying)
			return TRUE
	..()
//Second step: Multiply speeds. DONE
//Third step: Add light/medium/heavy. DONE
//Fourth step: add blocking
mob/var/tmp
	last_attk_sig
	last_attkd_sig

	blocking
	block_hold_time

	dash_touch

	dodging


mob/verb/holdblock()
	set instant = 1
	set hidden = 1
	//if(IsInFight)
	var/image/I= image('Attack strength indicator concept.dmi',src,"Block",MOB_LAYER+1)
	overlays += I
	blocking = 1

mob/verb/start_dodge()
	set instant = 1
	set hidden = 1
	if(IsInFight)
		if(!dodging)
			dodging = 1
			sleep(10)
			dodging = 0
			stunCount++
mob/verb/stopblock()
	set instant = 1
	set hidden=1
	if(blocking)
		blocking = 0
		block_hold_time = 0
		var/image/I= image('Attack strength indicator concept.dmi',src,"Block",MOB_LAYER+1)
		overlays -= I
//finally, add dash (lariat, but faster and w/o ki loss. No attack at the end.) (rapid movement is already a thing)
mob/verb/testdash()
	set hidden = 1
	dash_touch++
	spawn(5) dash_touch = 0
	if(dash_touch >= 2)
		dash_touch = 0
		if(HasSkill(/datum/skill/rapidmovement) && hasTime && canfight) rapidProc()

//movement done, right? NAAAAAA
//now its time for stagger/stun
//and indicators
//and etc based on technique and martial arts. (melee attacks and stuff.)
mob/proc/Whiff(Type)
	if(KO || !hasTime) return
	if(Ki>=5 * BaseDrain * weight**2)
		Ki-=5 * BaseDrain * weight**2
	training=1
	missedtrain=0
	Fight()
	var/punchrandomsnd=pick('meleemiss1.wav','meleemiss2.wav','meleemiss3.wav')
	emit_Sound(punchrandomsnd)
	var/testactspeed = Eactspeed * globalmeleeattackspeed
	Train_Gain(10)
	testactspeed /= 2
	attacking=testactspeed * (Type)
	training=0

mob/proc/Fight()
	set waitfor = 0
	if(!attacking)
		//OutputDebug("[src]: Combat Movement (4) proc, line 139.")
		var/prev_state = icon_state
		icon_state = "Attack"
		var/translatenum
		var/peak
		var/matrix/nM = src.transform
		var/origdir = dir
		var/adjustnum1
		var/adjustnum2
		translatenum = 4
		peak = 2
		while(translatenum >= 1)
			nM = src.transform
			var/num
			if(translatenum > peak)
				num += -3
			if(translatenum <= peak)
				num += 3
			translatenum -= 1
			switch(origdir)
				if(NORTH)
					adjustnum1 = -num
				if(SOUTH)
					adjustnum1 = num
				if(EAST)
					adjustnum2 = -num
				if(WEST)
					adjustnum2 = num
				if(NORTHEAST)
					adjustnum1 = -num
					adjustnum2 = -num
				if(NORTHWEST)
					adjustnum1 = -num
					adjustnum2 = num
				if(SOUTHEAST)
					adjustnum1 = num
					adjustnum2 = -num
				if(SOUTHWEST)
					adjustnum1 = num
					adjustnum2 = num
			nM.c += adjustnum2
			nM.f += adjustnum1
			src.transform = nM
			sleep(1)
		icon_state = prev_state
		if(flight)
			icon_state="Flight"

mob/proc/hitProc(var/mob/M,dmg,var/iscrit,var/customFlavor,var/forcehit,type)
	var/hit = 2
	var/bhit = (Etechnique/M.Espeed)*BPModulus(expressedBP,M.expressedBP)*100-M.deflection+accuracy//two perfectly matched players will hit 100% of the time
	if(iscrit) hit = 3
	if(forcehit) hit = 2
	if(!prob(bhit) && !M.blocking) hit = 0
	if(M.dodging)
		M.dodging = 0
		var/kireq = 0.05*M.MaxKi / M.Etechnique
		if(stagger) kireq *= stagger+1
		if(M.Ki >kireq)
			M.Ki-=kireq
			hit = 4
	if(M.blocking)
		hit = 0
		if(dashing)
			hit = 3
		if(M.stagger) dmg *= 2
		if(block_hold_time && M.block_hold_time <= 2 + (dash_cool)) hit = 1
		if(hit==3) M.buildStun += 4 + round(log(1.3,Etechnique))
	//else hit is equal to 2, refers to a failed block
	if(M.countering)
		M.countering--
		hit = 1
	Attack_MasteryGain(1 + type)
	switch(hit)
		if(3)//crit
			dmg*=((rand(15,30) + Etechnique)/10)
			src<<"You critically hit [M]!"
			M<<"[src] critically hits you!"
			Fight()
			createShockwavemisc(loc,2)
			GenerateAttackFlavorText("Attack",M,customFlavor)
			Damage(M,dmg,type)
			Leech(M)
			M.combo_count = 0
			M.buildStun += 10 + round(log(1.3,Etechnique))
			if(M.dashing)
				M.stagger += 1
				spawn(5) M.stagger -= 1
			if(M.buildStun >= 30 + M.Etechnique * 2)
				M.buildStun = 0
				M.stunCount = 100 * type
				M << "[src] stunned you!"
		if(2)//hit
			Fight()
			GenerateAttackFlavorText("Attack",M,customFlavor)
			Damage(M,dmg,type)
			Leech(M)
			M.combo_count = 0
			M.buildStun += 1 + round(log(1.3,Etechnique))
			if(M.dashing)
				M.stagger += 1
				spawn(5) M.stagger -= 1
			if(!dashing)
				//M.stagger += 1
				buildStun -= 2
				//spawn(3) M.stagger -= 1
			if(M.buildStun >= 30 + M.Etechnique * 2)
				M.buildStun = 0
				M.stunCount = min(30 * type,30)
				M << "[src] stunned you!"
		if(1)//counter
			Fight()
			M.GenerateAttackFlavorText("Counter",src)
			M.updateOverlay(/obj/overlay/effects/flickeffects/perfectshield)
			M.updateOverlay(/obj/overlay/effects/flickeffects/blueglow)
			emit_Sound('perfectsoundeffect.ogg')
			emit_Sound('parry.ogg')
			//M.Damage(src,dmg,2)//countering now leaves the opponent open for a long ass time.
			M.Leech(src)
			M.combo_count = 0
			M.stagger = 0
			combo_count = 0
			stunCount = min(60 * type,50)
			src << "[M] stunned you!"
		if(0)//dodge
			if(M.blocking)
				M.GenerateAttackFlavorText("Dodge",src,"blocks")
				Damage(M,dmg/(3 * ((M.block * M.blockmod) - (penetration/2)) * max(1,round( log(1.3,Etechnique) ))),type)
			else
				M.GenerateAttackFlavorText("Dodge",src)
			if(M.riposteon&&prob(M.tactics))
				spawn M.MeleeAttack(src)
				spawn AddExp(M,/datum/mastery/Melee/Tactical_Fighting,10)
			var/punchrandomsnd=pick('meleemiss1.wav','meleemiss2.wav','meleemiss3.wav')
			src.updateOverlay(/obj/overlay/effects/flickeffects/attack)
			createShockwavemisc(M.loc,1)
			emit_Sound('meleeflash.wav')
			emit_Sound(punchrandomsnd)
			if(!M.blocking) flick('Zanzoken.dmi',M)
			combo_count = 0
			stagger+=1
			spawn(3) stagger-=1
		if(4)//combo dodge
			hit = 0//set it back to a technical dodge
			M.GenerateAttackFlavorText("Dodge",src)
			var/punchrandomsnd=pick('meleemiss1.wav','meleemiss2.wav','meleemiss3.wav')
			src.updateOverlay(/obj/overlay/effects/flickeffects/attack)
			createShockwavemisc(M.loc,1)
			emit_Sound('meleeflash.wav')
			emit_Sound(punchrandomsnd)
			if(haszanzo)
				flick('Zanzoken.dmi',M)
				step(M,rand_dir_in_dir(dir),32)
				Move(get_step(src,M.dir),M.dir)
				M.dir = get_dir(M,src)
			else
				step(M,rand_dir_in_dir(dir))
				step(M,rand_dir())
			combo_count = 0
			stunCount += 10

	if(hit>=2&&M.dir==dir&&murderToggle&&M.Tail)
		if(M.hpratio<0.6&&dmg>5)
			view(M)<<"[usr] punches [M]'s tail off!"
			M<<"[usr] punches your tail off!"
			M.Lop_Tail()
	return hit