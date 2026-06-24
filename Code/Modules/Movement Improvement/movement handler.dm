mob/var
	const
		OMEGA_RATE=1 //this determines how much needs to be accumulated to move
		DISABLED = 0
		MAXIMUM_TIME = 10 //maximum total time
mob/var
	mobTime = 0
	tmp
		moveDir = DISABLED
		last_dir = 0
		totalTime = 0
		curdir = 0
		goaldir = 0
		randir = 0
		outToWork = 0
		busyWithFun = 0
		gravParalysis = 0
		KBParalysis = 0
		grabParalysis = 0
		launchParalysis = 0
		ctrlParalysis = 0//triggered only on Oozaru.
		hasTime = 1 //triggered when 0 time, set to 1 when Totaltime > 1 or the Totaltime -= OMEGA_RATE part happens.
		stillTimer
		stagger=0
		stunCount = 0//how many ticks you're down for
		buildStun = 0//how close you are to a stun.
		turnlock=0//stops people from turning, for things like beams
		grabCounter = 0 //gets to 20 and even weak players will get free
		dizzy = 0//random chance to stop movement
		slowed=0
		mob/grabber = null
		afk = 0 //self explanitory, measure if the player is considered inactive or not.

mob/proc
	unitimer()
		set waitfor = 0
		set background = 1
		while(src && key && !LoggingOut)
			if(BP==0) goto unitimerend //instead of CANCELING unitimer, ensures if your 0 bp gets fixed you can move again.
			//blind handling
			if(LoggingOut) return
			blindHandle()
			if(!x|!y|!z|Guiding) if(key) loc=locate(returnx,returny,returnz)
			if(x&&y&&z)
				returnx=x
				returny=y
				returnz=z
			mobTime += 0.3 //its so high because step_size is lower.
			mobTime += max(log(3.6,Epspeed),0.1) //max prevents negatives from DESTROYING US ALL
			if(dashing) mobTime += 0.5*Epspeed
			//if(flight) density = 0 causes all sorts of wonky stuff, just add special calls in the bump proc for walls. (tile hierachies need to be redone anyways)
			if(flight&&!flightspeed) mobTime += 0.25
			if(flight&&flightspeed) mobTime += max(log(8,Espeed),0.40)
	//buffs to delays border//do not cross//buffs to delays border//
			if(HP>0&&!undelayed) mobTime*=HP/100 //Damage delay
			if(weight>1) mobTime-=weight*(1/Espeed) //Weight delay
			if(Planetgrav+gravmult>GravMastered) mobTime-=max(log((((Planetgrav+gravmult)/(GravMastered)))**2),2) //Grav delay
			if(bigform||expandlevel) mobTime -= 0.1 //Buff delay
			if(swim)
				mobTime-=0.3 //Swim Delay
				AddExp(src,/datum/mastery/Life/Swimming,1)
			if(is_drawing) mobTime -= 0.8 //Powerup Delay
			if(HellStar&&Race=="Makyo"||Race=="Demon"||Parent_Race=="Makyo"||usr.Parent_Race=="Demon") mobTime += 0.2 //Insane Makyo/Demon speed increase
			if(mobTime < 0.1) mobTime = 0.1 //proxy nerf to fastboys
	//delays to status effects border//do not cross//delays to status effects border//
			CHECK_TICK
			if(KO)
				mobTime = 0
			if(KB || stagger)
				mobTime = 0
				if(med || train)
					if(med)
						src<<"You stop meditating."
						med=0
						deepmeditation = 0
						canfight=1
						icon_state=""
					if(train)
						src<<"You stop meditating."
						train=0
						canfight=1
						icon_state=""
			if(paralyzed)
				outToWork = rand(1,12)
				if(outToWork<=11) mobTime = 0
			if(movementCD)
				movementCD--
				if(movementCD<0)
					movementCD=0
			if(rangedCD)
				rangedCD--
				if(rangedCD<0)
					rangedCD=0
			if(counterCD)
				counterCD--
				if(counterCD<0)
					counterCD=0
			if(specialCD)
				specialCD--
				if(specialCD<0)
					specialCD=0
			if(ultiCD)
				ultiCD--
				if(ultiCD<0)
					ultiCD=0
			if(buffCD)
				buffCD--
				if(buffCD<0)
					buffCD=0
			if(slowed || stagger)
				mobTime/=2
			if(rapidmovement && mobTime)
				//if(totalTime<4) totalTime=4
				busyWithFun = rand(1,3)
				if(busyWithFun==2)
					goaldir = get_dir(src,src.target)
					randir=rand_dir()
					step(src,randir)
					step(src,goaldir)
					goaldir = get_dir(src,src.target)
					src.dir=goaldir
					step(src,src.dir)
					src.Attack()
			if(!canmove)mobTime=0
			if(!move)mobTime=0 //legacy var
			if(gravParalysis)mobTime=0
			if(!ThrowStrength && !KB)
				if(KBParalysis) KBParalysis=0
			if(KBParalysis) mobTime=0
			if(Guiding) mobTime = 0
			if(Frozen) mobTime = 0
			if(gavepower) gavepower = max(0,gavepower - 1)
			if(stunCount >= 1)
				outToWork = rand(1,12)
				if(outToWork<=7) mobTime = 0
				stunCount = max(0,stunCount - 1)
			if(!IsInFight && buildStun) buildStun = max(0,buildStun - 1)
			stagger = max(0,stagger)
			if(post_attack && prob(35)) post_attack = 0
			if(last_dir != dir && stagger) if(prob(40+Etechnique)) stagger = max(0,stagger - 1)
			if(stagger && blocking && prob(35+Etechnique)) stagger = max(0,stagger - 1)
			if(blocking) block_hold_time++
			else block_hold_time=0
			if(!IsInFight && stagger) stagger = max(0,stagger - 1)
			if(dash_cool) dash_cool= max(0,dash_cool-1)
			if(basicCD >= 1) basicCD = max(0, basicCD-1)//because fucking decimals thats why
			else basicCD = 0
			if(rand_step_cool && prob(50)) rand_step_cool=max(0,rand_step_cool-1)
			if(omegastun||launchParalysis) mobTime=0 //all-encompassing stun for style editing, etc.
			if(mobTime) hasTime = 1
			else hasTime = 0
			if(timestopCD) timestopCD=max(0,timestopCD - 1)
			totalTime += mobTime //ticker
			//Fighting checks
			if(hasTime) canfight = 1
			else canfight = 0
			if(attacking>0)
				canfight=0
				canbeleeched=1
				if(hasTime) attacking = max(0,attacking-0.5)
			else
				attacking = 0
				canbeleeched=0
			if(shdboxcl >= 1) shdboxcl--
			else shdboxcl = 0
			if(blocking) canfight = 0
			if(grabMode) canfight = 0
			if(grabbee) canfight = 0
			if(grabber) canfight = 0
			if(objgrabbee) canfight = 0
			if(med) canfight = 0
			if(charging) canfight = 0
			if(beaming) canfight = 0
			if(train) canfight = 0
			//if(basicCD) canfight = 0
			if(blasting) canfight = 0
			if(volleying) canfight = 0
			//if(eshotCD) canfight = 0
			if(sding) canfight = 0
			if(passive_block) canfight = 0
			if(stagger) canfight = 0
			//
			mobTime=0
			curdir = src.stepAction()
			CHECK_TICK
			if(prob(5) && grabParalysis && grabber && grabber.is_choking)
				var/dmg = grabber.NormDamageCalc(src) + grabCounter
				dmg /= 20
				dmg *=BPModulus(grabber.expressedBP,expressedBP)
				damage_m(src,dmg,grabber.selectzone,grabber.murderToggle,grabber.penetration)
			if(curdir)
				last_dir = dir
				src.dir=curdir
				if(ctrlParalysis)
					curdir = 0
				if(TimeStopped&&!CanMoveInFrozenTime)
					curdir = 0
				for(var/obj/o in src.loc)
					if(o.selectiveexit(src))
						curdir=0
				for(var/obj/o in get_step(src,src.dir))
					if(o.selectivecollide(src))
						curdir=0
			CHECK_TICK
			while(totalTime >= OMEGA_RATE) //switched back to while, under pixel movement it works better.
				DOESEXIST
				usr.HandleLevel()//moderate performance boost- only handle level when people are ticking
				totalTime -= OMEGA_RATE
				if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME //wipes out excessive fastboys speed buffer
				if(curdir)
					if(outToWork>=10&&paralyzed) src<<"You manage to move despite your paralysis."
					src.Deoccupy()
					src.removeOverlay(/obj/overlay/AFK)
					stillTimer=0
					if(grabParalysis)
						if(!grabParalysis) grabber = null
						if(!grabber) grabParalysis = null
						if(!grabbee || !grabber) grabParalysis = 0
						if(grabber)
							var/escapechance=(Etechnique*expressedBP)/grabberSTR
							if(get_dist(src,grabber) >= 2) escapechance=9999//far away man
							escapechance/=BPModulus(grabberSTR,expressedBP)
							escapechance *= stamina/maxstamina
							escapechance *= grabber.maxstamina/grabber.stamina
							if(grabber.grabMode == 2) escapechance *= 2
							grabCounter += Ephysoff/10
							grabCounter += Ephysdef/25
							grabber.stamina -= min(0.10 * escapechance,2)
							if(Race=="Majin") escapechance *= 5
							if(prob(escapechance * grabCounter)) grabCounter+=2
							if(grabCounter>=20/escapechance)
								grabCounter = 0
								grabber.grabbee=null
								attacking=0
								canfight=1
								grabber.is_choking = 0
								grabber.attacking=0
								//grabber.canfight=1
								grabberSTR=null
								grabParalysis = 0
								view(src)<<output("<font color=#990000>[src] breaks free of [grabber]'s hold!","Chat")
								grabber = null
							else
								view(src)<<output("<font color=#FFFFFF>[src] struggles against [grabber]'s hold!","Chat")
								grabCounter += 1
								grabCounter += Etechnique/5

						else grabParalysis = 0
					else if(!isStepping)
						if(!dirlock)
							step(src,curdir)
							OnStep()
						else
							var/facing=src.dir
							step(src,curdir)
							OnStep()
							src.dir=facing
				else
					if(client)
						powermovetimer=max(0,powermovetimer-1)
						stillTimer = client.inactivity
						if((stillTimer > 1200) || afk)
							src.updateOverlay(/obj/overlay/AFK)
						else
							src.removeOverlay(/obj/overlay/AFK)
						//if(stillTimer > 15 && dashing)
							//StopDash()


			if(client && client.inactivity >= 1200)
				afk = 1
			else afk = 0
			var/turf/T = loc
			if(!T)
				goto unitimerend
			if(!T.Water&&swim)
				usr.density=1
				usr.swim=0
				if(usr.Savable) usr.icon_state=""
				usr<<"You stop swimming."
			if(!T.Water&&boat)
				density = 1
				usr.boat = 0
				if(usr.Savable) usr.icon_state=""
				usr<<"You stop sailing."
			unitimerend
			sleep(1)//values under 1 don't work. it's rounded up back to 1.

atom/movable/proc/OnStep() //called whenever the player moves.
	return

mob/var/tmp
	tstopblind=0
	currentlyBlind = 0

mob/proc/blindHandle()
	set background = 1
	set waitfor = 0
	if(blindT)
		currentlyBlind += 1
		if(prob(10) * Ewillpower) blindT=max(blindT-1,0) //vision handling
	if(blindT==0)
		currentlyBlind -= 1
	//
	/*if(deepmeditation) currentlyBlind += 1*/
	//
	if(TimeStopped&&!CanMoveInFrozenTime)
		currentlyBlind += 1
		tstopblind++
		if(CanViewFrozenTime)
			currentlyBlind -= 1
			tstopblind--
		if(TimeStopperBP<=expressedBP)
			if(expressedBP>=5e+010)
				CanMoveInFrozenTime = 1
				if(!CanViewFrozenTime)
					currentlyBlind -= 1
					tstopblind--
	if(!TimeStopped)
		CanMoveInFrozenTime = 0
		if(tstopblind)
			currentlyBlind-=tstopblind
			tstopblind=0
	if(currentlyBlind>=1)
		sight = 1
	else if(currentlyBlind<=0)
		sight = 0

obj/overlay/AFK
	plane = 7
	name = "aura"
	ID = 5
	icon = 'AFK.dmi'

mob/verb/Toggle_Strafe()
	set hidden = 1
	set category = "Skills"
	if(dirlock)
		dirlock = 0
	else
		dirlock = 1