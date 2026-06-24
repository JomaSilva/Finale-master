mob/proc/doAttack(mob/M,addeddamage,iscrit,vampdamage,customFlavor,isBarrage,Type,kboverride,multd)
	var/dmg=1
	if(!Type) Type = 1
	dmg = attackCalcs(M,addeddamage,vampdamage,isBarrage,Type) * BPModulus(expressedBP,M.expressedBP)
	if(umulti && prob(50) && !multd)
		doAttack(M,addeddamage,iscrit,vampdamage,customFlavor,isBarrage,Type,kboverride,TRUE)
	if(!isBarrage) combo_count++
	if(M.attackable&&!inregen&&!ctrlParalysis&&!med&&!train&&!KO&&move&&(usr.Ki>=(weight*weight*1.5*BaseDrain)))
		var/testactspeed = Eactspeed
		testactspeed /= 3 * globalmeleeattackspeed * hitspeedMod
		testactspeed *= Type
		if(isNPC) testactspeed = Eactspeed * 1.25 * hitspeedMod
		commonAttackProcs(M,testactspeed)
		attack_Echo(M)
		M.attack_Echoed(src)
		var/hit = hitProc(M,dmg,iscrit,customFlavor,Type)
		if(!M.isNPC&&!isNPC)
			last_attk_sig = M.signature
			M.last_attkd_sig = signature
		if(knockbackon&&!M.KB&&hit&&!kboverride)
			var/check = (Ephysoff+Etechnique)/(M.Ephysdef+M.Etechnique) * BPModulus(expressedBP,M.expressedBP)
			if(Type == 1)
				if(check > 3 && prob(check * 10)) spawn Impact(M,dmg,0,max(flight,1))
				else if(prob(check * 20)) spawn Impact(M,1,1,max(flight,1))
			else
				spawn Impact(M,((dmg + Ephysoff*2 + 1) * check))
		if(M.client)
			if(src.Mutations && (hit == 2 || hit == 3))
				if(prob(10 * src.Mutations))
					M.Mutations+=1
		if(M.stagger) testactspeed /= 2
		if(combo_count > 3) testactspeed *= 4
		attacking+=testactspeed
		if(isBarrage && hit)
			return 2
		return TRUE

mob/proc/AttackMultiple(var/mob/M,var/addeddamage,var/iscrit,var/vampdamage,var/customFlavor,var/isBarrage)
	var/dmg=1
	dmg = attackCalcs(M,addeddamage,iscrit,vampdamage,0,1) * BPModulus(expressedBP,M.expressedBP)
	if(isBarrage) dmg /= isBarrage
	if(M.attackable&&!inregen&&!ctrlParalysis&&!med&&!train&&!KO&&move&&(usr.Ki>=(weight*weight*1.5*BaseDrain)))
		commonAttackProcs(M,1,1)
		hitProc(M,dmg,iscrit,customFlavor,1)
		var/testactspeed = Eactspeed
		testactspeed /= 3 * globalmeleeattackspeed * hitspeedMod
		attacking+=testactspeed
		return TRUE

mob/proc/commonAttackProcs(var/mob/M,testactspeed,barrage)
	if(!testactspeed)
		testactspeed = Eactspeed * globalmeleeattackspeed
		testactspeed /= 2
		if(isNPC) testactspeed = Eactspeed * 1.25 * hitspeedMod
	var/attackingNPC = FALSE
	if(M.isNPC||!M.client)
		attackingNPC=TRUE
	var/defendingNPC = FALSE
	if(isNPC||!src.client)
		defendingNPC=TRUE
	M.IsInFight=1
	M.StartFightingStatus()
	IsInFight=1
	StartFightingStatus()
	dir = get_dir(loc,M.loc)
	if(Ki>=1&&!KO&&!Apeshit)
		Ki-=angerBuff*weight*weight*1.5*BaseDrain
	if(Anger>100)
		Anger-=((MaxAnger-100)/8000)
	canbeleeched=1
	if(!rand_step_cool && !M.rand_step_cool && !barrage && knockbackon && !M.KO && M.dir == get_dir(M,src))
		var/nu = 1
		if(M.expressedBP >= 1000 && expressedBP >= 1000 && M.haszanzo && haszanzo) nu = rand(5,11)
		createShockwavemisc(loc,abs(nu-7))
		if(nu > 1)
			flick('Zanzoken.dmi',M)
			flick('Zanzoken.dmi',src)
			emit_Sound('teleport.wav')
			rand_step_cool += 50
			M.rand_step_cool += 50
			var/token_strength
			if(M.expressedBP >= 10000 && expressedBP >= 10000 && M.knockbackon)
				token_strength++
				if(M.expressedBP >= 100000 && expressedBP >= 100000) token_strength++
				if(M.expressedBP >= 1.00e+008 && expressedBP >= 1.00e+008) token_strength++
				var/list/tlist = list()
				for(var/turf/z in view(nu,src))
					tlist+=z
				var/amo = 2
				while(amo >= 1)
					if(prob(50)) amo--
					if(tlist.len)
						var/turf/T = pick(tlist)
						createShockwavemisc(T,abs(nu-7))
				spawn for(var/turf/T in tlist)
					if(prob(55)) sleep(1)
					else if(prob(45)&&!T.isSpecial&&!T.proprietor && T.Resistance <= expressedBP)
						if(prob(65)) createDust(T,1)
						T.Destroy()
					else if(prob(5)&&token_strength>2)
						if(prob(65)) createDustmisc(T,3)
						if(prob(65)) createDustmisc(T,2)
					else if(prob(5))
						if(prob(65)) createDustmisc(T,3)
					else if(prob(4)&&token_strength>3)
						if(prob(65)) createLightningmisc(T,2)
				if(token_strength>2)
					Quake()
					if(prob(65)) createCrater(loc,1)
				if(token_strength>3)
					Quake()
					if(prob(65)) createDustmisc(loc,1)
		rand_step_cool += 50
		M.rand_step_cool += 50
		Move(tele_rand_turf_at_range(src,nu))
		if(M.target == src) M.Move(get_step(src,src.dir))
		dir = get_dir(src,M)
		if(M.target == src) M.dir = get_dir(M,src)
	if(!minuteshot)
		if(!defendingNPC)
			if(npc_sparring&&attackingNPC)
				Attack_Gain(1/2 * 5)
				Attack_Gain(dungeonGains * 5)
			else Attack_Gain(2 * 5)
		else if(!attackingNPC)
			M.Attack_Gain(1/4 * (M.BP / BP))
			if(isBoss)
				M.Attack_Gain(1 * (M.BP / BP))
	else if(!barrage)
		if(!defendingNPC)
			Train_Gain(testactspeed/20 * (M.BP / BP) * 25)
			if(!attackingNPC)
				Train_Gain(testactspeed/20 * (M.BP / BP) * 25)
	if(!minuteshot)
		minuteshot=1
		spawn(300) minuteshot=0
	M.Add_Anger(3)
	Add_Anger()

mob/proc/attack_Echo(var/mob/nM)
	if(out_mobs.len)
		for(var/mob/npc/pet/M in range(10))
			if(M.cur_own_sig == signature && M.attack_settings[1])
				M.foundTarget(nM)
				break


mob/proc/attack_Echoed(var/mob/nM)
	if(out_mobs.len)
		for(var/mob/npc/pet/M in range(10))
			if(M.cur_own_sig == signature && M.attack_settings[2])
				M.foundTarget(nM)
				break
