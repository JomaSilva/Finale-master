mob/var/tmp/fastRegen = 0 //set in assign_regen(): 1 for races with a true accelerated-regen passive (keeps healing while In Battle)
mob/verb/Injure(var/mob/targetmob in view(1))
	set category = "Skills"
	if(usr.KO)
		return
	if(!targetmob.KO&&usr!=targetmob)
		to_chat(usr, "The target must be knocked out!")
		return
	if(alert(usr,"Injure [targetmob]? Cutting off a limb needs a much, much higher BP/offense advantage. If you get enough damage on a limb, it'll fall off anyways. You're selecting the [selectzone]","","Yes","No")=="Yes")
		var/list/targetlimblist = list()
		for(var/datum/Body/S in targetmob.body)
			if(S.lopped==0&&S.targetable&&S.targettype==selectzone)
				targetlimblist+=S
		if(selectzone=="abdomen"&&!targetmob.has_Tail() && targetmob.Tail) targetlimblist += "Tail"
		var/datum/Body/targetlimb = pick(targetlimblist)
		if(!isnull(targetlimb)&&targetlimb!="Tail")
			if(targetlimb.vital)
				targetlimb.DamageMe(usr.Ephysoff*BPModulus(expressedBP,targetmob.expressedBP))
				if(targetlimb.lopped) to_chat(view(usr), "[targetmob]'s [targetlimb] was ripped off by [usr]!!")
				else to_chat(view(usr), "[targetmob]'s [targetlimb] was damaged by [usr]!!")
			else //need a smaller oompf to rip off somebodys arm
				targetlimb.DamageMe(usr.Ephysoff*BPModulus(expressedBP,targetmob.expressedBP)*5)
				if(targetlimb.lopped) to_chat(view(usr), "[targetmob]'s [targetlimb] was ripped off by [usr]!!")
				else to_chat(view(usr), "[targetmob]'s [targetlimb] was damaged by [usr]!!")
		else if(targetlimb=="Tail")
			if(BPModulus(expressedBP,targetmob.expressedBP) * (Ephysoff/targetmob.Ephysdef))
				targetlimb = get_Tail()
				targetlimb.DamageMe(usr.Ephysoff*BPModulus(expressedBP,targetmob.expressedBP)*5)
				if(targetlimb.lopped) to_chat(view(usr), "[targetmob]'s [targetlimb] was ripped off by [usr]!!")
				else to_chat(view(usr), "[targetmob]'s [targetlimb] was damaged by [usr]!!")
				targetmob.Apeshit_Revert()

mob/proc/DamageLimb(var/damage as num,var/theselection,var/enemymurderToggle as num,var/penetration as num)
	set waitfor=0
	if(damage == 0)
		return
	if(!penetration)
		penetration = 0
	var/list/limbselection = list()
	for(var/datum/Body/C in src.body)
		if(C.lopped==0&&((C.targettype==theselection&&prob(C.targetchance))||prob(C.targetchance/4)&&C.targetable)&&!C.isnested)
			limbselection += C
	if(limbselection.len>=1)
		var/datum/Body/choice = pick(limbselection)
		if(!isnull(choice))
			if(enemymurderToggle==0)
				choice.DamageMe(damage,1,penetration)
			else
				choice.DamageMe(damage,0,penetration)

mob/proc/HealLimb(var/damage as num,var/theselection)
	set waitfor=0
	if(damage == 0)
		return
	var/list/limbselection = list()
	for(var/datum/Body/C in src.body)
		if(C.lopped==0&&C.targettype==theselection)
			limbselection += C
	if(limbselection.len>=1)
		var/datum/Body/choice = pick(limbselection)
		if(!isnull(choice))
			choice.HealMe(damage)
mob/proc/SpreadDamage(var/damage as num, var/enemymurderToggle as num, var/element as text)
	set waitfor = 0
	if(damage == 0) return
	if(!element)
		element = "Physical"
	damage *= Resistances[element]
	var/list/limbselection = list()
	for(var/datum/Body/C in src.body)
		if(C.lopped==0&&(C.targetable||(prob(10)&&C.vital)))
			limbselection += C
	if(limbselection.len <= 0) return
	var/givendamage = 0
	var/totallimbs = limbselection.len
	while(givendamage < totallimbs)
		if(limbselection.len == 0) break
		var/datum/Body/choice = pick(limbselection)
		if(!isnull(choice))
			if(enemymurderToggle)
				choice.DamageMe(damage,0)
			else if(enemymurderToggle==0)
				choice.DamageMe(damage,1)
			else
				choice.DamageMe(damage,0)
			givendamage += 1
			limbselection -= choice

mob/proc/SpreadHeal(HealAmount,FocusVitals,HealArtificial)
	set waitfor = 0
	if(HealAmount == 0) return
	var/list/vitalselection = list()
	for(var/datum/Body/C in src.body)
		if(C.lopped==0&&C.vital&&C.health<=C.maxhealth*0.7)
			if(HealArtificial&&C.artificial)
				vitalselection += C
			else if(!C.artificial)
				vitalselection += C
	if(vitalselection.len >= 1 && FocusVitals)
		var/givenheal = 0
		var/totallimbs = vitalselection.len
		while(givenheal < totallimbs)
			if(vitalselection.len == 0) break
			var/datum/Body/choice = pick(vitalselection)
			if(!isnull(choice))
				choice.HealMe(HealAmount)
				givenheal += 1
				vitalselection -= choice
	else
		var/list/limbselection = list()
		for(var/datum/Body/C in src.body)
			if(C.lopped==0&&C.targetable&&C.health<C.maxhealth)
				if(HealArtificial&&C.artificial)
					limbselection += C
				else if(!C.artificial)
					limbselection += C
		if(limbselection.len >= 1)
			var/givenheal = 0
			var/totallimbs = limbselection.len
			while(givenheal < totallimbs)
				if(limbselection.len == 0) break
				var/datum/Body/choice = pick(limbselection)
				if(!isnull(choice))
					choice.HealMe(HealAmount)
					givenheal += 1
					limbselection -= choice


mob/var/tmp/prevHealth = null
mob/var
	tmp/vitalKOd = 0
	healthmod = 1//multiplies limb health

mob/proc/Check_Damage() //return 0 if 100%, 1 if injured, 2 if critical, 3 if super-dooper-crit. Any severely injuried vitals will immediately return 3.
	set waitfor = 0
	//before we even start to calc the individual stats, we need to see if we can shortcut with a return
	if(HP == 100 || HP ~= 100 || HP >= 99.9) return 0
	//with this too.
	if(HP >= 85) return 1
	//now calc
	var/healthtotal = 0
	var/healthmax = 0
	var/limbcount = 0
	var/damagedlimbcount = 0
	var/ssupdmlmbcnt = 0
	zenkaicount=0
	for(var/datum/Body/S in body)
		if(!S.lopped&&!isnull(S.health))
			if(S.health<S.maxhealth)
				damagedlimbcount += 1
				if(S.health<0.4*S.maxhealth)
					ssupdmlmbcnt += 1
					if(S.vital)
						ssupdmlmbcnt += 1 //so one vital limb low can almost put you into what is considered to be 'critical status'
						if(S.health<0.2*S.maxhealth)
							ssupdmlmbcnt += 1
				if(S.health<0.1*S.maxhealth && S.vital)
					return 3

		limbcount += 1//we want lopped limbs to contribute to health as well, it makes no sense for a person with no limbs to be "healthy"
		healthtotal += S.health  * S.healthweight //healthweight means limbs matter less than torso.
		healthmax += S.maxhealth * S.healthweight
	if(limbcount)
		healthtotal /= healthmax
		healthtotal *= 100
		HP = round(healthtotal,0.01)
		if(HP < 99.9 || damagedlimbcount)
			if(ssupdmlmbcnt >= 3)
				if(ssupdmlmbcnt >= 6)//two limbs crit, three limbs majorly damaged, or a bunch of limbs very damaged will return 3
					return 3
				return 2
			return 1
		else return 0



//TRUE when a large share of the body is BROKEN (<20% limb HP, the "Broken" state) or RIPPED OFF (lopped). Used by
//gain_zenkai() to grant the stronger 15% / 3x-base-BP Zenkai when you're defeated while extremely injured.
mob/proc/extremely_injured()
	var/total = 0
	var/wrecked = 0
	var/lopcount = 0
	for(var/datum/Body/S in body)
		total++
		if(S.lopped)
			wrecked++
			lopcount++
		else if(S.maxhealth > 0 && S.health < 0.2*S.maxhealth)
			wrecked++
	if(!total) return FALSE
	if(lopcount >= 2) return TRUE //two or more limbs ripped clean off is brutal enough on its own
	return (wrecked / total) >= zenkaiInjuryFraction

mob/var/tmp
	limbregenbuffer = 0

	dmg_status = 0
	dmg_mrk = 0

mob/var
	//
	passiveRegen = 0.05 //never 0.
	canheallopped = 0
	// used only by people with the Regenerate verb anyways.
	activeRegen = 1 //modifier to enhance Regenerate's effects.
	tmp/zenkaicount = 0//how many limbs should be giving zenkai
	//


mob/proc/HealthSync()
	set waitfor =0
	if(client||target)
		var/healthtotal = 0
		var/limbcount = 0
		var/vitalcount = 0
		var/coreDead = 0
		var/coreBroken = 0
		zenkaicount=0
		for(var/datum/Body/S in body)
			S.health = max(-5,S.health)//bottoming out at 0 often makes a regen source tick before it lops
			if(S.maxhealth!=100*healthmod*S.maxhpmod)
				var/wasfull = S.health >= S.maxhealth //a healthy limb should stay full when its max changes
				S.maxhealth = 100*healthmod*S.maxhpmod
				if(wasfull) S.health = S.maxhealth //fixes the whole body showing "Slightly Injured" on every login (max grew but health didn't follow)
			if(!S.lopped&&!isnull(S.health))
				if(S.health<=0)
					spawn S.LopLimb()
				if(S.health<S.maxhealth)
					if(client)//these indicators don't matter for NPCs
						if(S.health>=0.8*S.maxhealth)
							S.limbstatus = "<font color=lime>Slightly Injured"
						else if(S.health>=0.6*S.maxhealth)
							S.limbstatus = "<font color=yellow>Injured"
						else if(S.health>=0.4*S.maxhealth)
							S.limbstatus = "<font color=#FF9900>Seriously Injured"
						else if(S.health>=0.2*S.maxhealth)
							S.limbstatus = "<font color=red>Critically Injured"
						else if(S.health<0.2*S.maxhealth)
							S.limbstatus = "<font color=purple>Broken"
						S.status = "Damaged [S.health]"
					if(!S.artificial&&S.regenerationrate&&(!combatTag||fastRegen))
						if(prob(10)||(prob(20)&&S.vital))
							S.health += 0.1 * S.regenerationrate
				else if(S.health>=S.maxhealth)
					if(client)
						S.limbstatus = "<font color=green>Healthy"
						S.status = "100%"
					S.health = min(S.maxhealth,S.health)
			else if(S.status != "Missing") spawn S.LopLimb()
			//HP is the plain MEAN of each remaining part's health% (no weighting, user request). A lopped/destroyed
			//part is excluded (it's gone - hidden from the Body tab, purple on the paperdoll); the lethal danger of
			//losing one lives entirely in the core-vital KO/death checks below, not in a permanent HP drag.
			if(!S.lopped)
				limbcount += 1
				healthtotal += round((S.health / max(S.maxhealth,1)) * 100, 0.01)
			if(S.vital)
				vitalcount += 1
				if(S.health<=(0.3*S.maxhealth)&&!S.lopped) zenkaicount++
			//the three CORE vitals (head/torso/abdomen) gate consciousness and life directly
			if(S.type == /datum/Body/Head || S.type == /datum/Body/Torso || S.type == /datum/Body/Abdomen)
				if(S.lopped || S.health <= 0) coreDead++
				else if(S.health < 0.2 * S.maxhealth) coreBroken++
		if(limbcount) HP = round(healthtotal / limbcount, 0.01)
		//DEATH: a core vital destroyed ("lethal") = instant death. Regen-skin races (canheallopped) instead drop into a coma
		//and regrow it - unless ALL THREE core vitals are gone at once, which still kills them.
		if(coreDead >= 1 && (!canheallopped || coreDead >= 3) && !KB)
			Death()
		else if(coreBroken >= 1 || coreDead >= 1)
			//a core vital in the "broken" band (or a destroyed one on a regen-skin race) = instant KO / coma until it heals
			if(!KO && !vitalKOd)
				KO(-1)
				vitalKOd = 1
				to_chat(src, "<font color=red>A vital part of your body gives out - you collapse, unconscious.</font>", "combat")
		else if(vitalKOd)
			//core vitals recovered above the broken line -> wake from the coma
			if(KO) Un_KO()
			vitalKOd = 0
		if(prob(5)&&(!combatTag||fastRegen)) //no passive trickle-heal while In Battle, unless a true regen-passive race
			if(prob(1))
				SpreadHeal(1)
		if(passiveRegen && (!combatTag || fastRegen)) //no passive healing while In Battle, UNLESS your race has a true regen passive
			if(prob(75) && HP < 99.99) SpreadHeal(0.1 * passiveRegen)
			if(canheallopped&&(prob(5*activeRegen)||prob(2*DeathRegen)))
				limbregenbuffer += 1
				stamina -= 0.5 * (maxstamina/100)
			if(limbregenbuffer >= 25)
				limbregenbuffer -= 25
				var/list/limbselection = list()
				for(var/datum/Body/C in body)
					sleep(1)
					if(C.health < C.maxhealth)
						limbselection += C
				if(limbselection.len)
					var/datum/Body/choice = pick(limbselection)
					if(!isnull(choice)&&!choice.artificial)
						if(choice.lopped)
							choice.RegrowLimb()

	/*proc/CheckHealth()//Covered above
		set background = 1
		set waitfor = 0
		if(savant && !savant.client)
			if(savant.isNPC && istype(savant,/mob/npc))
				var/mob/npc/nN = savant
				if(nN.AIRunning == 0) goto checkEnd
		if(savant)
			health = max(0,health)
			if(!lopped&&!isnull(health))
				if(health<=0)
					spawn LopLimb()
				if(health<maxhealth&&savant)
					if(savant.client)//these indicators don't matter for NPCs
						if(health>=0.8*maxhealth)
							limbstatus = "<font color=lime>Slightly Injured"
						else if(health>=0.6*maxhealth)
							limbstatus = "<font color=yellow>Injured"
						else if(health>=0.4*maxhealth)
							limbstatus = "<font color=#FF9900>Seriously Injured"
						else if(health>=0.2*maxhealth)
							limbstatus = "<font color=red>Critically Injured"
						else if(health<0.2*maxhealth)
							limbstatus = "<font color=purple>Broken"
						status = "Damaged [health]"
					if(savant)
						if(!artificial||regenerationrate)
							if(prob(15)||(prob(50)&&vital)||savant.KO)
								health += 0.1 * regenerationrate
				else if(health>=maxhealth&&savant.client)
					limbstatus = "<font color=green>Healthy"
					status = "100%"
					health = min(maxhealth,health)
			else if(status != "Missing") spawn LopLimb()
		sleep(7)
		checkEnd
		if(savant && !savant.client)
			sleep(13)
		spawn CheckHealth()*/