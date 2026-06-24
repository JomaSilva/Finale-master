mob/var
	bursticon
	burststate
	beamicon = 'Beam3.dmi'
	tmp
		rangemod=1//determines how much power the beam gains/loses per step
		volley = 0 //lets you fire a barrage of beams
		bypass=0
		beaming=0
		beamspeed=1
		powmod=1
		lastbeamcost=0
		oldlstbeam = 0
		maxbeamcost=0
		wavemult=1
		chargedelay=1
		maxdistance=20
		piercer=0
		canmove=1
		beamhoming=0
		forceicon=""
		forcestate="origin"
		var/tmp/obj/attack/blast/tmphead = null
		accum
		beamdamage
		beamrgb
		beamprocrunning=0 // test var, used for the proc ShootBeam()
		beammods
		beamturndelay=0//keeps you from spinning in circles with a beam going, 1 move every 2 seconds by default, eactspeed moves it down to a minimum of .5 seconds-ish
		cur_atk_element
mob/proc/AreYaBeamingKid()
	if(!KO&&!med&&!train)
		if(accum==0)
			chargedelay/=log(10,max(chargedskill+beamskill,10))
		accum++
		if(charging&&accum % 3 == 0)
			if(!maxbeamcost)
				lastbeamcost /= 10
				maxbeamcost = lastbeamcost * 3
				oldlstbeam = lastbeamcost
				tmphead=null
			if(Ki>=lastbeamcost)
				Ki-=(lastbeamcost)
				wavemult*=(3**(-1*wavemult/log(10,max(chargedskill,10)))+1)
				lastbeamcost*=1.001
				lastbeamcost = min(lastbeamcost,maxbeamcost)
				Blast_Gain()
			else
				stopcharging()
			if(accum>=10*chargedelay/3)
				updateOverlay(/obj/overlay/effects/chargeaura)
		if(!charging&&accum>=10*chargedelay/3)
			accum = 0
			removeOverlay(/obj/overlay/effects/chargeaura)
			if(beaming) spawn ShootBeam(cost)
			else
				beamprocrunning=0
				beamisrunning=0
	else if(charging||beaming)
		beamprocrunning=0
		beamisrunning=0
		stopcharging()
		stopbeaming()
mob/proc/ShootBeam()
	if(beamprocrunning)
		return FALSE //returns FALSE if it's already running, useful for debugging
	beamprocrunning=1
	beamisrunning=1
	var/lastdir
	var/tmpdbeam=0
	while(beaming)
		CHECK_TICK
		if(KB)
			stopbeaming()
		if(beamturndelay)
			turnlock=1//prevent the user from moving
		else
			turnlock=0
		if(charging)charging=0
		var/finalcost = lastbeamcost
		if(!isnull(tmphead)) finalcost = oldlstbeam / 5
		if(tmpdbeam>=1) tmpdbeam= max(0,tmpdbeam-1)
		if(Ki>=(finalcost/4)*BaseDrain&&!KO) //Fiddling around with it, beams need to in general do more damage and drain less.
			Ki-=(finalcost/4)*BaseDrain
			beamcounter++
			Blast()
			Blast_Gain()
			var/dontbeam=0
			if(src.dir!=lastdir)
				beamturndelay = round(src.Eactspeed,1) / 2//5 loops a second, so an Eactspeed of 20 means 2 seconds per turn
			var/obj/nB = locate(/obj/attack/blast) in get_step(src,dir)
			if(nB)
				if(isobj(tmphead))
					dontbeam++
					tmphead.BP = expressedBP*wavemult
					tmphead.wavemultipl = wavemult
					tmphead.element = cur_atk_element
					tmphead.transform = dir_matrix[tmphead.dir]
					tmphead.transform *= wavemult
				else if(nB.dir == dir && nB.proprietor != src)
					var/mob/M = nB.proprietor
					if(!isnull(M.tmphead))
						var/obj/attack/blast/nnB = M.tmphead
						nnB.BP=(M.expressedBP*M.wavemult)+(expressedBP*wavemult)
						nnB.wavemultipl = M.wavemult + wavemult
						var/dmg1
						if(beamdamage)
							dmg1 = beamdamage
						else dmg1=0.25*Ekioff*log(10,max(beamskill,10))
						var/dmg2
						if(M.beamdamage)
							dmg2 = M.beamdamage
						else dmg2=0.25*M.Ekioff*log(10,max(M.beamskill,10))
						var/dmg = dmg1 + dmg2
						nnB.basedamage = dmg * 2
						dontbeam++
				else if(nB.dir == dir && nB.proprietor == src)
					dontbeam++
			if(isnull(tmphead)) dontbeam=0
			if(dontbeam==0&&!tmpdbeam)
				tmpdbeam=0
				var/obj/attack/blast/A=new/obj/attack/blast
				A.proprietorloc=src.loc
				if(bypass)
					A.icon=forceicon
					A.icon_state=forcestate
				else
					A.icon=WaveIcon
				A.animate_movement=1
				if(beamrgb)
					A.icon+= beamrgb
				else A.icon+=rgb(blastR,blastG,blastB)
				A.density=0
				A.BP=expressedBP*wavemult
				A.wavemultipl = wavemult
				A.dir=src.dir
				A.element = cur_atk_element
				//
				var/icon/I = icon(A.icon,null,EAST)
				var/W = I.Width()
				var/H = I.Height()
				A.icon = I
				var/TD = sqrt(W**2 + H**2)
				A.scalefactor = TD / W
				/*var/matrix/nM = matrix()
				nM.Scale(wavemult * A.scalefactor,wavemult)
				A.transform = nM*/
				A.transform = dir_matrix[A.dir]
				A.transform *= wavemult
				//
				A.Homing_Tendency = (wavemult*usr.Ekioff) //For beams only!
				if(!beammods)
					beammods=Ekioff*Ekiskill*log(10,max(kieffusionskill,10))*log(10,max(beamskill,10))
				A.mods=beammods*powmod
				if(beamdamage)
					A.basedamage = beamdamage * 2
				else A.basedamage=0.25*Ekioff*log(10,max(beamskill,10))
				A.layer=MOB_LAYER+2
				A.murderToggle=murderToggle
				A.rangemod=rangemod
				if(usr) A.proprietor=usr
				if(usr.target&&!beamhoming && A.Homing_Tendency<=(usr.Ekiskill + usr.kicontrolskill/100 * usr.homingskill/100)) beamhoming = 1
				if(beamhoming && usr.target in view(usr.screenx,usr))//need different beam homing solution
					A.linear=0
					A.homeTarget = target.loc
					//OutputDebug("dir: [usr.dir], target: [usr.target], dir: [get_dir(usr,usr.target)], testdir: [testdir], turn 2: [turn(usr.dir, 45)], turn 1: [turn(usr.dir,-45)]")
					//A.homeTarget = usr.target
					//A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))
					//spawn A.blasthoming()
				A.ownkey=displaykey
				A.WaveAttack=1
				A.beamspeed=beamspeed
				A.icon_state = ""
				A.piercer=piercer
				A.distance=maxdistance
				A.maxdistance=maxdistance
				A.loc=src.loc
				A.density=1
				A.avoidusr=1
				A.kishock=usr.kishock
				A.kiforceful=usr.kiforceful
				A.kiinterfere=usr.kiinterfere
				if(!volley)
					step(A,A.dir)
				else
					volleycounter++
					var/tmploc = get_step(src,pick(turn(A.dir,-45),A.dir,turn(A.dir,45)))
					if(proprietor in get_step(tmploc,turn(A.dir,180)))
						tmploc = get_step(tmploc,A.dir)
						tmpdbeam=2
					A.loc = tmploc
					step(A,A.dir)

				//spawn(maxdistance) A.loc=null the object is going to handle this with its move proc//this needs to incorporate speed to accomodate varying tile movement, like glide


			if(prob(50)) wavemult*=0.99
			wavemult = max(1,wavemult)
			lastdir=src.dir
			if(beamturndelay)
				beamturndelay--
		else
			bypass=0
			beamprocrunning=0
			beamisrunning=0
			beamturndelay=0
			turnlock=0
			stopbeaming()
		sleep(2)
	//stopbeaming()

mob/proc/stopbeaming()
	icon_state=""
	//canfight=1
	beaming=0
	rangemod=1
	volley = 0
	lastbeamcost=1
	wavemult=1
	beamhoming=0
	chargedelay=1
	canmove=1
	accum=0
	beamisrunning=0
	//world << "heres"
	tmphead=null
	beamprocrunning=0
	beamdamage=0
	beamrgb = 0
	beamturndelay=0
	maxbeamcost=0
	turnlock=0

mob/proc/stopcharging()
	icon_state=""
	//canfight=1
	charging=0
	canmove=1
	accum=0
	beamdamage=0
	maxbeamcost=0
	tmphead=null
	beamrgb = 0

/datum/skill/ki/Ki_Wave
	skilltype = "Ki"
	name = "Ki Wave"
	desc = "The user learns to concentrate their ki into a beam."
	level = 0
	expbarrier = 100
	maxlevel = 0
	can_forget = TRUE
	common_sense = TRUE
	skillcost=1
	prereqs = list()

datum/skill/ki/Ki_Wave/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Ki_Wave)

/datum/skill/ki/Ki_Wave/after_learn()
	savant << "You feel like you can focus your ki into a beam."
	assignverb(/mob/keyable/verb/Ki_Wave)

/datum/skill/ki/Ki_Wave/before_forget()
	savant << "You lose focus."
	unassignverb(/mob/keyable/verb/Ki_Wave)


mob/keyable/verb/Ki_Wave()
	set category = "Skills"
	desc = "Fire a concentrated energy wave"
	var/kireq=10*usr.BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			beaming=1
			charging=0
			usr.emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.forceicon=usr.beamicon
			usr.emit_Sound('kame_charge.wav')
			canmove = 0
			lastbeamcost=10*BaseDrain//base drain will end up multiplying in each cycle, making beams burn you out much quicker
			beamspeed=1
			powmod=1
			maxdistance=30
			//canfight = 0
			charging=1
			bypass=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"

mob/keyable/verb/Masenko()
	set category = "Skills"
	desc = "Fire an energy wave that loses power as it travels"
	var/kireq=30*usr.BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			beaming=1
			charging=0
			usr.emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.forceicon='BeamMasenko.dmi'
			usr.emit_Sound('kame_charge.wav')
			canmove = 0
			lastbeamcost=30*BaseDrain//base drain will end up multiplying in each cycle, making beams burn you out much quicker
			beamspeed=1
			powmod=1.5
			maxdistance=20
			//canfight = 0
			charging=1
			rangemod=0.95
			bypass=1
			chargedelay = 2
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"

mob/keyable/verb/Makkankosappo()
	set category = "Skills"
	desc = "Fire an energy wave that gains power was it travels"
	var/kireq=20*usr.BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			beaming=1
			charging=0
			usr.emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.forceicon='BeamStaticBeam.dmi'
			usr.emit_Sound('kame_charge.wav')
			canmove = 0
			lastbeamcost=30*BaseDrain//base drain will end up multiplying in each cycle, making beams burn you out much quicker
			beamspeed=1
			powmod=1.3
			maxdistance=40
			//canfight = 0
			charging=1
			rangemod=1.03
			bypass=1
			chargedelay = 6
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"

mob/keyable/verb/Energy_Wave_Volley()
	set category = "Skills"
	desc = "Fire a continuous volley of energy waves"
	var/kireq=10*usr.BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			beaming=1
			charging=0
			usr.emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.forceicon=usr.beamicon
			usr.emit_Sound('kame_charge.wav')
			canmove = 0
			lastbeamcost=10*BaseDrain//base drain will end up multiplying in each cycle, making beams burn you out much quicker
			beamspeed=1
			powmod=1
			maxdistance=20
			//canfight = 0
			charging=1
			volley = 1
			bypass=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"

mob/keyable/verb/Massive_Beam()
	set category = "Skills"
	desc = "Fire a powerful energy wave"
	var/kireq=15*usr.BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			usr.icon_state="Blast"
			beaming=1
			charging=0
			usr.emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			usr.forceicon='Beam11.dmi'
			usr.emit_Sound('kame_charge.wav')
			canmove = 0
			lastbeamcost=150*BaseDrain//base drain will end up multiplying in each cycle, making beams burn you out much quicker
			beamspeed=0.5
			powmod=4
			wavemult=2
			maxdistance=30
			//canfight = 0
			charging=1
			bypass=1
			chargedelay=5
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"

mob/var/Dodompaicon='Dodompa.dmi'

/datum/skill/ki/Boom_Wave
	skilltype = "Ki"
	name = "Boom Wave"
	desc = "A short-range, highly concentrated take on energy waves. While it is generally stronger, it takes significantly more Ki to maintain.\nUnskilled fighters will struggle to even charge it."
	level = 0
	expbarrier = 100
	maxlevel = 0
	tier=2
	can_forget = TRUE
	common_sense = TRUE
	enabled=0
	skillcost=2
	prereqs = list(new/datum/skill/bfocus)

datum/skill/ki/Boom_Wave/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Boom_Wave)

/datum/skill/ki/Boom_Wave/after_learn()
	savant << "You think you're ready to attempt to use a Boom Wave."
	savant.kiskill+=0.05
	assignverb(/mob/keyable/verb/Boom_Wave)

/datum/skill/ki/Boom_Wave/before_forget()
	savant << "You feel dull."
	savant.kiskill-=0.05
	unassignverb(/mob/keyable/verb/Boom_Wave)

mob/keyable/verb/Boom_Wave()
	set category = "Skills"
	var/kireq=15*BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		return
	if(usr.Ki>=kireq)
		if(charging)
			beaming=1
			charging=0
			return
		if(!charging&&!KO&&!med&&!train&&canfight)
			//usr.icon_state="Blast"
			forceicon='Beam4.dmi'
			forcestate="origin"
			canmove = 0
			lastbeamcost=15/(Ekiskill*2)
			beamspeed=0.2
			powmod=2.3
			bypass=1
			maxdistance=5
			//canfight = 0
			charging=1
			spawn usr.addchargeoverlay()
		return
	else src << "You need at least [kireq] Ki!"