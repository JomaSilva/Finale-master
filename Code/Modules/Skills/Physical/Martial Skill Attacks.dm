mob/var
	rushmod = 1
	rushmax = 1
	tmp/currush = 0

/datum/skill/MartialSkill/Zanzoken_Rush
	skilltype = "Physical"
	name = "Zanzoken Rush"
	desc = "Using principles of both the Lariat and Afterimage techniques, you appear next to your opponent and strike! Practice can increase the number of subsequent attacks"
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/drills,new/datum/skill/ki/Afterimage)
	tier = 3
	enabled = 0
	exp = 0
	expbarrier = 100
	maxlevel = 3
	after_learn()
		savant<<"You can now appear next to your target!"
		assignverb(/mob/keyable/verb/Zanzoken_Rush)
	before_forget()
		savant<<"You forget how to appear next to your target!"
		unassignverb(/mob/keyable/verb/Zanzoken_Rush)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Zanzoken_Rush)
	effector()
		..()
		switch(level)
			if(0)
				if(levelup)
					levelup = 0
				if(savant.currush)
					exp+=1
			if(1)
				if(levelup)
					levelup = 0
					savant.rushmod = 2
					savant<<"You feel as if you can appear twice!"
				if(savant.currush)
					exp+=1
			if(2)
				if(levelup)
					levelup = 0
					savant.rushmod = 3
					savant<<"You think you can appear three times now!"
				if(savant.currush)
					exp+=1
			if(3)
				if(levelup)
					levelup = 0
					savant.rushmod = 4
					savant<<"You can appear an astounding four times!"

mob/keyable/verb/Zanzoken_Rush()
	set category = "Skills"
	var
		staminaReq=angerBuff*5/(usr.Ephysoff+usr.Etechnique)*BaseDrain
		rushcount = 0
		jumpspeed = usr.Eactspeed*globalmeleeattackspeed / 2
		zrcd = jumpspeed*20
		targarea
	get_me_a_target()
	if(usr.Ki>=staminaReq&&usr.target&&usr.target!=usr&&get_dist(usr,usr.target)<20&&!usr.KO&&usr.currush<1)
		usr<<"You attempt to appear next to your target!"
		Ki-=staminaReq
		usr.rushmax=max(round(usr.rushmod*log(usr.Espeed)), 1)
		usr.currush=1
		while(rushcount<usr.rushmax)
			rushcount++
			if(!canmove||usr.KO)
				usr<<"Your attack failed because you can't move!"
				break
			if(usr.z!=target.z)
				usr<<"Your target is out of range!"
				break
			flick('Zanzoken.dmi',usr)
			targarea=locate(target.x+pick(-1,1),target.y+pick(-1,1),target.z)
			usr.Move(targarea)
			if(usr.loc!=targarea)
				usr<<"Your attack was stopped by an obstacle!"
				break
			usr.dir=get_dir(usr,target)
			usr.MeleeAttack()
			view(3,target)<<"[usr] appears and strikes [target]!"
			emit_Sound('teleport.wav')
			sleep(jumpspeed)
		usr.currush=2
		sleep(zrcd)
		usr.currush=0
		rushcount=0
	else if(!usr.target||get_dist(usr,usr.target)>=12||usr.target==usr)
		usr << "You need a valid target..."
	else if(usr.Ki<=staminaReq)
		usr << "You need at least [staminaReq] Ki to use this skill."
	else if(usr.currush==1)
		usr << "You are already using this skill!"
	else if(usr.currush==2)
		usr << "You are still exhausted from your rush..."


/datum/skill/MartialSkill/Special_Multihit
	skilltype = "Physical"
	name = "Special: Multihit"
	desc = "A special multihit attack that crowds the opponent's body with punches."
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	enabled = 1
	exp = 0
	expbarrier = 100
	maxlevel = 3
	after_learn()
		savant<<"You can now barrage your opponent with blows!"
		assignverb(/mob/keyable/verb/Special_Multihit)
	before_forget()
		savant<<"You forget how to barrage your opponent with blows!"
		unassignverb(/mob/keyable/verb/Special_Multihit)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Special_Multihit)

mob/keyable/verb/Special_Multihit()
	set category = "Skills"
	var/kireq=usr.Ephysoff*BaseDrain*6
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		var/amount = min(10,Etechnique * 2)
		if(BarrageAttack(2,FALSE,FALSE,"fires a punch at",amount,2))
			usr.Ki-=kireq
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

/datum/skill/MartialSkill/Wolf_Fang_Fist
	skilltype = "Physical"
	name = "Special: Wolf Fang Fist"
	desc = "Mimic a wolf, repeatedly attacking an opponent with sharp blows.."
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	enabled = 1
	exp = 0
	expbarrier = 100
	maxlevel = 3
	after_learn()
		savant<<"You can now punch with the ferocity of the wolf! You learned Wolf Fang Fist!"
		assignverb(/mob/keyable/verb/Wolf_Fang_Fist)
	before_forget()
		savant<<"You forget how to use the Wolf Fang Fist!!"
		unassignverb(/mob/keyable/verb/Wolf_Fang_Fist)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Wolf_Fang_Fist)

mob/keyable/verb/Wolf_Fang_Fist()
	set category = "Skills"
	set desc = "Punch your foe 3 times in rapid succession, knocking them back. Unarmed skill. Melee skill."
	var/kireq=usr.Ephysoff*10*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		if(!unarmed&&(weaponeq>1||twohanding))
			usr<<"You need a free hand to use this!"
			return
		if(usr.meleeCD)
			usr<<"Melee skills on CD for [meleeCD/10] seconds."
			return
		if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<8)
			usr<<"You can't use this now!"
			return
		get_me_a_target()
		if(!usr.target)
			usr<<"You have no target."
			return
		else
			if(get_dist(usr,target)>1)
				usr<<"You must be next to your target to use this!"
				return
		usr.basicCD+=15
		target.AddEffect(/effect/stun)
		spawn MeleeAttack(target,0.5)
		sleep(1)
		spawn MeleeAttack(target,0.5)
		sleep(1)
		spawn MeleeAttack(target)
		target.kbdir=usr.dir
		target.kbpow=usr.expressedBP
		target.kbdur=4
		target.AddEffect(/effect/knockback)
		usr.stamina-=8
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

/datum/skill/MartialSkill/Wolf_Hurricane
	skilltype = "Physical"
	name = "Special: Wolf Fang Hurricane"
	desc = "Similarly to the Wolf Fang Fist, the Wolf Fang Hurricane is a flurry of blows. Except, in this case, it's more of a combination attack."
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	enabled = 1
	skillcost = 0
	prereqs = list(new/datum/skill/MartialSkill/Wolf_Fang_Fist)
	exp = 0
	expbarrier = 100
	maxlevel = 3
	after_learn()
		savant<<"You can now use the Wolf Fang Hurricane!"
		assignverb(/mob/keyable/verb/Wolf_Fang_Hurricane)
	before_forget()
		savant<<"You forget how to use the Wolf Fang Hurricane!!"
		unassignverb(/mob/keyable/verb/Wolf_Fang_Hurricane)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Wolf_Fang_Hurricane)

mob/keyable/verb/Wolf_Fang_Hurricane()
	set category = "Skills"
	var/kireq=usr.Ephysoff*9*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		var/saveknock = knockbackon
		knockbackon = 0
		usr.Ki-=kireq
		if(target in view(1))
			if(doAttack(target,2,null,null,"fires a wolf-like punch at",null,3,1))
				Impact(target,1,1)
				step(src,get_dir(src,target))
				var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				usr.emit_Sound(punchrandomsnd,0.33)
				AttackMultiple(target,2,null,null,"slams a cupped fist into",0)
				Impact(target,1,1)
				step(src,get_dir(src,target))
				punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				usr.emit_Sound(punchrandomsnd,0.33)
				AttackMultiple(target,2,null,null,"kicks vertically, stunning",0)
				Impact(target,1,1)
				step(src,get_dir(src,target))
				knockbackon = saveknock
				punchrandomsnd=pick('ARC_BTL_CMN_Hit_Large-A.ogg','punch_hvy.wav','hit_l.wav','strongkick.wav','strongpunch.wav')
				usr.emit_Sound(punchrandomsnd,0.33)
				doAttack(target,2,null,null,"throws a fist, almost shaped like a fang into",null,1)
		knockbackon = saveknock
		attacking = 0
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
mob/keyable/verb/Dash_Attack()
	set category = "Skills"
	var/kireq=usr.Ephysoff*8*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		usr.Ki-=kireq
		//var/justincase=0
		var/flighted = 0
		var/rushSpeed=round(0.7*move_delay,0.1)
		var/succ = 0
		var/dist = round(Espeed + Etechnique + Ephysoff) + 5
		var/rushdir = dir
		if(flightability > 1)
			flighted = 3
			if(!flight)
				flighted=1
				start_flying()
				start_superflight()
			else if(!flightspeed)
				flighted=2
				start_superflight()
		while(dist)
			dist--
			if(!canmove)
				src<<"Your rush fails since you can't move!"
				break
			step(src,rushdir)
			for(var/mob/M in oview(1))
				doAttack(target,20,1,null,"dropkicks",null,3)
				succ=1
			if(dist==0)
				src<<"All this moving is exhausting..."
				break
			sleep(rushSpeed)
		if(!succ)
			stagger += 1
			src<<"You fell because you missed the enemy. You're stunned!"
			sleep(4)
			stagger -= 1
		switch(flighted)
			if(1)
				stop_superflight()
				stop_flying()
			if(2)
				stop_superflight()
		attacking = 0
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

mob/keyable/verb/Flip()
	set category = "Skills"
	var/kireq=usr.Ephysoff*12*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=5
		usr.Ki-=kireq
		if(grabParalysis)
			if(!grabbee) grabParalysis = 0
			if(grabber)
				var/escapechance=(Ephysoff*expressedBP*4)/grabberSTR
				escapechance *= stamina/maxstamina
				escapechance *= grabber.maxstamina/grabber.stamina
				if(grabber.grabMode == 2) escapechance *= 2
				grabber.stamina -= min(0.10 * escapechance,2)
				if(Race=="Majin") escapechance *= 6
				if(prob(escapechance * grabCounter))
					grabCounter = 0
					grabber.grabbee=null
					attacking=0
					canfight=1
					grabber.is_choking = 0
					grabber.attacking=0
					//grabber.canfight=1
					grabberSTR=null
					grabParalysis = 0
					view(src)<<output("<font color=7#FFFF00>[src] flips free of [grabber]'s hold!","Chat")
					var/dmg = NormDamageCalc(grabber) + grabCounter
					damage_mob(grabber,dmg)
					grabber = null
				else
					view(src)<<output("<font color=#FFFFFF>[src] struggles against [grabber]'s hold!","Chat")
					grabCounter += 5

			else grabParalysis = 0
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

mob/keyable/verb/Spin_Attack()
	set category = "Skills"
	var/kireq=usr.Ephysoff*15*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		usr.Ki-=kireq
		var/amount = 0
		for(var/mob/M in view(1))
			if(M!=usr)
				amount += 1
				if(amount > 2) break
				doAttack(M)
		attacking = 0
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

mob/keyable/verb/Stun_Attack()
	set category = "Skills"
	var/kireq=usr.Ephysoff*20*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		usr.Ki-=kireq
		get_me_a_target()
		if(target in view(10))
			RushAttack(target,1.2)
			if(target in view(1))
				if(MeleeAttack())
					target.stunCount+=25
		RushComplete=0
		attacking = 0
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
mob/keyable/verb/Takedown()
	set category = "Skills"
	var/kireq=usr.Ephysoff*20*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		var/mob/t_m = null
		get_me_a_target()
		t_m = target
		if(t_m)
			usr.Ki-=kireq
			var/tdmg = 1
			if(t_m.flight)
				view(src)<<"[t_m] is taken down by [src]!!"
				tdmg++
				t_m.stunCount+=35
				t_m.flight = 0
			else
				view(src)<<"[t_m] is taken down by [src]!!"
			var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
			usr.emit_Sound(punchrandomsnd,0.33)
			var/dmg = NormDamageCalc(t_m) * tdmg
			damage_mob(t_m,dmg)
	else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."