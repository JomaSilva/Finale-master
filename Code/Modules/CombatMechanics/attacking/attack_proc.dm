mob/proc/MeleeAttack(addeddamage,iscrit,vampdamage,customFlavor,Type)//default behavior treats all of these as null.
	if(attacking || grabbee || !hasTime || blocking) return
	//
	var/list/objlist = list()
	//var/list/turflist = list()
	for(var/obj/B in get_step(src,dir)) //temp for testing
		if(B.fragile || istype(B,/obj/Raw_Material)) objlist += B
	var/turf/T = get_step(src,dir)
	//
	var/dmg=1
	//StartFightingStatus()
	if(!Type) Type = 1 // Type determines if the attack is Light, Medium, or Heavy.
	var/list/moblist = list()
	moblist = compileRangeMobList()
	//OutputDebug("[src]: Attack (3) proc, line 15.")
	if(moblist.len>=1)
		//
		var/mob/M = null
		if(target in moblist)
			M = target
		else
			M = pick(moblist)
			if(prob(60) &&!target in view(6)) target = M
		if(doAttack(M,addeddamage,iscrit,vampdamage,customFlavor,null,Type))
			return M
	for(var/obj/B in objlist) //temp for testing
		if(istype(B,/obj/Raw_Material))
			var/obj/Raw_Material/L = B
			for(var/datum/mastery/W in src.learnedmasteries)
				if(W.type == L.masterytype&&W.level>=L.masterylevel)
					attacking+=1
					Fight()
					var/punchrandomsnd=pick('punch_med.wav','mediumpunch.wav','mediumkick.wav')
					o_emit_Sound('meleeflash.wav')
					emit_Sound_to(punchrandomsnd,usr)
					if(L.durability)
						L.durability-=round(min(2+W.level-L.masterylevel,4))
						L.durability=max(L.durability,0)
						if(L.durability >= 8) view(L)<<"[L] makes a chunky sound."
						else if(L.durability) view(L)<<"[L] makes a cracking sound."
						else view(L)<<"[L] makes a crumbling sound."
					else
						W.expgain(L.masterylevel*10)
						//AddEffect(/effect/exhaustion)
						L.Gather()
					var/testactspeed = Eactspeed * globalmeleeattackspeed
					attacking=testactspeed/2
					return TRUE
		else if(!med&&!train&&move&&(usr.Ki>=10)) //damage handling while target is KO'd
			if(!attacking)
				Ki-=10 * BaseDrain
				Fight()
				var/punchrandomsnd=pick('punch_med.wav','mediumpunch.wav','mediumkick.wav')
				o_emit_Sound('meleeflash.wav')
				emit_Sound_to(punchrandomsnd,usr)
				var/testactspeed = Eactspeed * globalmeleeattackspeed
				B.takeDamage(expressedBP)
				Train_Gain(4)
				if(isNPC)
					testactspeed = Eactspeed
				attacking=testactspeed/3
				if(B&&B.type==/obj/training_obj)
					var/obj/training_obj/tbj = B
					Attack_MasteryGain(1)
					tbj.TrainHit(src)
				if(B&&B.type==/obj/items/Punching_Bag)
					if(B.icon_state != "Destroyed")
						flick("Hit",B)
						var/gainscale=max((1-(BP/TopBP))**2,0.2)
						Train_Gain(7*gainscale)
						Attack_MasteryGain(1)
						B:pbagHP -= 1*(expressedBP/B:pbagBP)
						if(B:pbagHP<=0)
							B.icon_state = "Destroyed"
				else if(B&&B.type==/obj/items/Punching_Machine)
					if(B.icon_state != "Destroyed")
						flick("Hit",B)
						var/gainscale=max((1-(BP/TopBP))**2,0.2)
						Train_Gain(5*gainscale)
						Attack_MasteryGain(1)
						B:pbagHP -= 1*(expressedBP/B:pbagBP)
						var/base=3 * globalmeleeattackdamage
						if(dashing) base *= 1.15
						var/phystechcalc
						if(Ephysoff<1||Etechnique<1)
							phystechcalc = Ephysoff+Etechnique
						else
							phystechcalc = log(3,(Ephysoff**2)*Etechnique)+2
						dmg=DamageCalc((phystechcalc),1,base)
						view(src)<<"<font size=2><font color=green>[src]: Punch damage: [dmg], Punch Lift Calculation: [log(10,usr.expressedBP) * (usr.expressedBP*usr.Ephysoff*5)]</font>"
						if(B:pbagHP<=0)
							flick("machdes",B)
							B.icon_state = "Destroyed"
				return TRUE
	if(T && !med&&!train&&move&&(usr.Ki>=10)) //damage handling while target is KO'd
		if(T.Resistance&&T.density)
			if(!attacking)
				Fight()
				var/punchrandomsnd=pick('punch_hvy.wav','punch_med.wav','mediumpunch.wav','mediumkick.wav','strongkick.wav','strongpunch.wav')
				o_emit_Sound('meleeflash.wav')
				emit_Sound_to(punchrandomsnd,usr)
				var/testactspeed = Eactspeed * globalmeleeattackspeed
				if(T.Resistance<=expressedBP)
					if(prob(34))
						createDust(T,1)
						emit_Sound('kiplosion.wav')
						T.Destroy()
				if(isNPC)
					testactspeed = Eactspeed
				Train_Gain(3.5)
				attacking=testactspeed/3
				return TRUE
	Whiff(Type)
	return FALSE
mob/var/tmp
	KB=0
	kbcanceled
	KBcanCancel

mob/proc/BarrageAttack(var/addeddamage,var/iscrit,var/vampdamage,var/customFlavor,attackNum=1,delay=2)
	if(attacking || grabbee) return
	//var/dmg=1
	//StartFightingStatus()
	var/list/moblist = list()
	moblist = compileRangeMobList()
	if(moblist.len>=1)
		//
		var/mob/M = null
		if(target in moblist)
			M = target
		else M = pick(moblist)
		var/firstBarrage
		var/testactspeed = Eactspeed * globalmeleeattackspeed
		var/first_atk_num = attackNum
		var/cur_atk_num = 0
		while(attackNum)
			attackNum--
			cur_atk_num++
			if(!ismob(M) || isnull(M))
				attackNum = 0
				break
			if(cur_atk_num > first_atk_num) break
			if(get_dist(M,src)>=2) break
			if(!firstBarrage)
				if(doAttack(M,addeddamage,iscrit,vampdamage,customFlavor,first_atk_num,null,1) >= 2)
					firstBarrage = 1
				else attackNum = 0
			else
				attacking++
				spawn AttackMultiple(M,addeddamage,iscrit,vampdamage,customFlavor,first_atk_num)
			if(M.blocking) break
			sleep(delay)
		M.stagger = 0
		sleep(testactspeed)
		attacking=0
	//attacking=0