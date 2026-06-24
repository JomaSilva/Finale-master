mob/var

	tmp
		Healtarget
		solarCD
		blindT
		healCD
mob/keyable/verb/Solar_Flare()
	set category="Skills"
	var/reload
	var/kireq=100*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!solarCD&&canfight)
		usr.Ki-=kireq
		usr.kidebuffcounter+=4
		reload=20*Eactspeed
		if(reload<200)reload=200
		usr.solarCD=reload
		var/distance=round(kidebuffskill/10+max((Ekiskill/2),1),1)
		if(distance<2) distance=2
		for(var/turf/A in view(distance,usr))
			createLightningmisc(A,7)
		sleep(1)
		src<<output(Say("Solar Flare!!"))
		for(var/mob/A in oview(distance,usr))
			if(A!=usr&&!usr.currentlyBlind)
				if(A.dir==get_dir(A,usr)||A.dir==turn(get_dir(A,usr),-45)||A.dir==turn(get_dir(A,usr),45))
					usr.kidebuffcounter+=4
					A<<"You are blinded by [usr]'s Solar Flare!"
					A.blindT=max(round(0.4*kidebuffskill*max((Ekiskill/2),1),1),10)
		sleep(reload)
		usr.solarCD=0
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(solarCD) usr<<"This skill was set on cooldown for [solarCD/10] seconds."

/datum/skill/ki/Afterimage
	skilltype = "Ki"
	name = "Afterimage Technique"
	desc = "The user expends ki to move at extreme speeds. While at first it's difficult and has limited range, skilled users can seemingly teleport."
	level = 1
	expbarrier = 1
	maxlevel = 4
	expbarrier=100
	tier=2
	skillcost = 1
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list()
	var/accum=50

datum/skill/ki/Afterimage/effector()
	..()
	accum++
	if(accum>=50)
		accum=0
		savant.zanzorange=round(1.2*max(savant.Ekiskill,savant.Etechnique)*savant.Espeed,-1)
	if(level<4)
		if(savant.zanzorange>=3 && savant.zanzochange)
			exp+= savant.zanzochange//click.dm has zanzochange info, one zanzo = one exp
			if(prob(20)) savant.zanzochange = 0
	switch(level)
		if(2)
			if(levelup)
				savant << "You can use Zanzoken Combo now! (use the skill to teleport behind a target and attack.)"
				assignverb(/mob/keyable/verb/Zanzoken_Combo)
		if(3)
			if(levelup)
				savant << "You can use Zanzoken Dodge now! (use the skill to immediately teleport to a free tile around you.)"
				assignverb(/mob/keyable/verb/Zanzoken_Dodge)
		if(4)
			if(levelup)
				savant << "You can use Zanzoken Afterimage now! (use the skill to start producing afterimages which may confuse the enemy.)"
				assignverb(/mob/keyable/verb/Zanzoken_Afterimage)
	if(levelup) levelup = 0
datum/skill/ki/Afterimage/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Afterimage_Toggle)
	if(level>=2) assignverb(/mob/keyable/verb/Zanzoken_Combo)
	if(level>=3) assignverb(/mob/keyable/verb/Zanzoken_Dodge)
	if(level>=4) assignverb(/mob/keyable/verb/Zanzoken_Afterimage)
/datum/skill/ki/Afterimage/after_learn()
	savant << "You feel swift. Try clicking a nearby tile."
	savant.haszanzo=1
	assignverb(/mob/keyable/verb/Afterimage_Toggle)
/datum/skill/ki/Afterimage/before_forget()
	savant << "You feel sluggish."
	savant.haszanzo=0
	unassignverb(/mob/keyable/verb/Afterimage_Toggle)
	if(level>=2) unassignverb(/mob/keyable/verb/Zanzoken_Combo)
	if(level>=3) unassignverb(/mob/keyable/verb/Zanzoken_Dodge)
	if(level>=4) unassignverb(/mob/keyable/verb/Zanzoken_Afterimage)
mob/keyable/verb/Afterimage_Toggle()
	set category = "Skills"
	if(usr.haszanzo==0)
		usr.haszanzo=1
		usr<<"You will now use your Afterimage technique (click to use)."
	else
		usr.haszanzo=0
		usr<<"You will no longer use your Afterimage technique."
mob/var
	haszanzo=0
	zanzorange=1
	zanzomod=1
	tmp/zanzochange

/datum/skill/ki/Heal
	skilltype = "Ki"
	name = "Healing Technique"
	desc = "The user expends their ki to slowly heal their target. Not for the unskilled or the unworthy."
	level = 1
	expbarrier = 1
	maxlevel = 0
	tier=1
	skillcost = 1
	enabled=0
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list()
	var/accum

datum/skill/ki/Heal/effector(var/mob/logger)
	..()
	accum++
	if(accum>=5)
		var/kireq=savant.MaxKi/(savant.Ekiskill*10)
		if(savant.Ki>=kireq && savant.Healtarget&&get_dist(savant,savant.Healtarget)<=1)
			savant.Ki-=kireq*savant.BaseDrain
			for(var/mob/M in view(1,savant))
				if(M == savant.Healtarget && M.HP<=100)
					M.SpreadHeal(0.2*savant.Ekiskill)
					if(prob(1) && prob(1) && M.has_Tail()) if(!usr.Tail) usr.Tail_Grow()
		else if(savant.Healtarget)
			usr<<"You stop healing [savant.Healtarget]."
			savant.Healtarget=null
/datum/skill/ki/Heal/login()
	..()
	assignverb(/mob/keyable/verb/Heal)
/datum/skill/ki/Heal/after_learn()
	savant << "You think you might be able to heal others using your Ki."
	assignverb(/mob/keyable/verb/Heal)
/datum/skill/ki/Heal/before_forget()
	savant << "You lose your ability to heal others' wounds."
	unassignverb(/mob/keyable/verb/Heal)
	savant.haszanzo=0


/mob/keyable/verb/Heal()
	set category="Skills"
	var/kireq=usr.MaxKi/(usr.Ekiskill*20)
	var/reload
	if(usr.target && !usr.Healtarget && usr.Ki>=kireq && !usr.healCD)
		reload=15*Eactspeed
		if(reload<30)reload=30
		usr.Healtarget = usr.target
		oview(usr)<<"[usr] begins to heal [usr.Healtarget]."
		usr<<"You begin to heal [usr.Healtarget]."
		sleep(reload)
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(healCD) usr<<"This skill was set on cooldown for [healCD/10] seconds."

mob/var/tmp/sding=0
mob/var/tmp/chargecounter=0

/mob/keyable/verb/Self_Destruct()
	set category="Skills"
	if(sdingtype==2)
		usr<<"You can't use Final Explosion with this."
		return
	if(sding)
		sding=0
		sdingtype=0
		usr.move=0
		if(!grabbee)
			range(20)<<"[usr] lost control of the situation."
			usr.move=1
			return
		var/mob/Mz = grabbee
		range(20)<<"[usr] is blowing the fuck up!"
		usr.emit_Sound('buster_fire.wav')
		for(var/turf/T in orange(4))
			createLightningmisc(T,8)
		var/power=((expressedBP*Ekioff)/(Mz.expressedBP*Mz.Ekidef))
		power *= (5 * chargecounter)
		if(usr.DeathRegen)
			power /= max(log(DeathRegen),1)
		for(var/mob/M in range(3))
			if(M!=usr&&M!=Mz)
				if(M!=Mz)
					M.SpreadDamage(power/get_dist(usr,M))
				if(M.HP<=0)
					if(M.DeathRegen)
						M.buudead=peakexBP/M.expressedBP
					if(M.immortal)
						view(M)<<"[M] is unable to die!"
					spawn M.Death()
					view(M)<<"[M] was killed by [usr]!"
		usr.SpreadDamage(power)
		Ki=0
		Mz.SpreadDamage(power)
		if(Mz.HP<=0)
			if(Mz.DeathRegen)
				Mz.buudead=peakexBP/Mz.expressedBP
			if(Mz.immortal)
				view(Mz)<<"[Mz] is unable to die!"
			spawn
				Mz.Death()
			view(Mz)<<"[Mz] was killed by [usr]!"
		if(chargecounter>20)
			if(prob(75))
				buudead=peakexBP/expressedBP
				spawn usr.Death()
				view(usr)<<"[usr] dies by [usr]'s Self Destruct!"
		Mz=0
		usr.grabbee=null
		usr.move=1
		usr.grabMode = 0
		attacking=0
		//canfight=1
		chargecounter=0
		return
	if(!grabbee)
		usr<<"You need to be grabbing someone!"
		return
	if(KO)
		usr<<"You can't do this while knocked out!"
		return
	if(dead)
		usr<<"Dead people can't use this!"
	else
		chargecounter=1
		usr<<"You are now charging your self destruct!"
		usr<<"Press Self Destruct again to detonate. The longer you charge, the stronger the blast."
		sding=1
		sdingtype=1
		move=0
		spawn(20) if(sding && sdingtype == 1)
			if(grabbee)
				range(20)<<"[usr] begins gathering all the energy around [usr] into [usr]'s body!"
			else
				range(20)<<"[usr] lost control of the situation."
				move=1
				sding=0
				sdingtype=0
				return
			spawn(40) if(sding && sdingtype == 1)
				if(grabbee)
					range(20)<<"The ground begins to shake fiercely around [usr]!"
				else
					range(20)<<"[usr] lost control of the situation."
					move=1
					sding=0
					sdingtype=0
					return
		JINGO
		spawn(25)
			if(sding&&grabbee&&!KO)
				chargecounter+=5
				usr.emit_Sound('aura.wav')
				goto JINGO
			else
				if(sding&&(!grabbee||KO))
					sding=0
					sdingtype=0
					move=1
					range(20)<<"[usr] lost control of the situation."
					return
				else
					return

mob/var/tmp/sdingtype=0
mob/var/tmp/sdingrange=0

/datum/skill/adveff/Final_Explosion
	skilltype = "Ki"
	name = "Final Explosion"
	desc = "Charge up insane amounts of energy, and let it all go in one big explosion. Damage is dependent on how spread out it is, but it's generally less than Self Destruct. Can possibly destroy planets."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=1
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Final_Explosion)

	after_learn()
		assignverb(/mob/keyable/verb/Final_Explosion)
		savant<<"You can now use Final Explosion!"
	before_forget()
		unassignverb(/mob/keyable/verb/Final_Explosion)
		savant<<"You've forgotten how to use Final Explosion!?"


/mob/keyable/verb/Final_Explosion()
	set category="Skills"
	if(sdingtype==1)
		usr<<"You can't use Self Destruct with this."
		return
	if(sding)
		sding=0
		sdingtype=0
		usr.move=1
		grabbee = null
		range(20)<<"[usr] is blowing the fuck up!"
		usr.emit_Sound('buster_fire.wav')
		new /obj/bigboom(loc)
		var/power=((expressedBP*Ekioff)/(100/chargecounter))
		for(var/mob/M in range(sdingrange)) if(M!=usr)
			M.SpreadDamage(DamageCalc(power/get_dist(src,M),M.expressedBP*M.Ekidef,10))
			if(M.HP<=10)
				if(M.DeathRegen)
					buudead=peakexBP/M.expressedBP
				spawn M.Death()
				view(M)<<"[M] was killed by [usr]!"
		SpreadDamage(DamageCalc(power,expressedBP*Ekidef,10))
		Ki= max((Ki - (sdingrange * (MaxKi / 25))),0)
		if(chargecounter>10)
			if(prob(70)||HP<=10||KO)
				if(DeathRegen) buudead=peakexBP/expressedBP
				spawn usr.Death()
				view(usr)<<"[usr] dies by [usr]'s Final Explosion!"
		if(sdingrange>=25 && expressedBP >= 10000000)// > than 10m? blow the planet
			var/area/currentarea=GetArea()
			currentarea.DestroyPlanet(expressedBP)
		move=1
		chargecounter=0
		return
	else
		chargecounter=1
		switch(input(usr,"You pressed Final Explosion, how big do you want the blast to be? WARNING: MAXIMUM RANGE COMBINED WITH HIGH POWERLEVELS (>10m) WILL DESTROY THE PLANET","") in list("Maximum","Midrange","Closerange","Cancel"))
			if("Cancel")
				chargecounter=0
				return
			if("Closerange")
				sdingrange=3
			if("Midrange")
				sdingrange=10
			if("Maximum")
				sdingrange=25
		usr<<"You are now charging your self destruct!"
		usr<<"Press Self Destruct again to detonate. The longer you charge, the stronger the blast."
		sding=1
		sdingtype=2
		move=0
		spawn(20)
			range(20)<<"[usr] begins gathering all the energy around [usr] into [usr]'s body!"
			spawn(40)
				range(20)<<"The ground begins to shake fiercely around [usr]!"
				if(sdingrange>=25 && expressedBP >= 10000000)
					range(20)<<"The energy surrounding [usr] could potentially blow the planet!!"
		JINGO
		spawn(25)
			if(sding)
				chargecounter+=1
				usr.emit_Sound('aura.wav')
				goto JINGO
			else
				chargecounter=0
				return

obj/bigboom
	icon='bigboom.dmi'
	canGrab=0
	mouse_opacity = 0
	pixel_x = -240
	pixel_y = -240
	New()
		..()
		spawn
			sleep(11)
			del(src)