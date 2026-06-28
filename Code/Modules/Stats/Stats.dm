mob
	proc/TryStats()
		if(istype(src,/mob/lobby))
			return
		if(client?.iscreating)
			return
		if(StatsRunning)
			return
		if(!client)
			return
		StatsRunning = 1
		spawn Stats()
		spawn GlobalStats()
		spawn unitimer()
		spawn onceStats()
		spawn(30) equipment_Checker()
		updateseed=resolveupdate

mob/proc/equipment_Checker()
	set background = 1
	while(src)
		Check_Equipment()
		sleep(1200)

mob/proc/GlobalStats()
	set waitfor = 0
	//set background = 1
	while(src)
		if(!AverageRunning) spawn ServerAverage()
		DOESEXIST
		CHECK_TICK
		if(LoggingOut) return
		CheckNutrition()
		CheckOverlays()
		RelaxCheck()//
		statify()
		if(client && world.time >= nextMilestoneTick) //idle milestone accrual: HandleLevel otherwise only runs on movement ticks, so a player powering up in place never converted BP->milestones until they moved
			nextMilestoneTick = world.time + 10 //~1s throttle (world.time is deciseconds)
			HandleLevel()
		OverlayLoop()//
		AreYaBeamingKid()
		powerlevel()
		CheckPowerMod()
		Check_Tech()
		HealthSync()
		CheckTime()
		BuffLoop()
		if(IsInFight) combatTime = min(combatTime + 1, 720) //bonus de combate das formas Legendary: sobe ate +20% em ~180s de luta continua
		else combatTime = max(combatTime - 2, 0) //decai 2x mais rapido fora de combate
		if(combatTag && client && !battle_music_on) start_battle_music() //start the local battle-music playlist whenever the combat tag is up (incl. on being hit/blasted); the loop self-stops when the tag clears
		CheckGodki()
		accrue_friendship()
		CheckSSj3Learn()
		if(isSealed) spawn TestEscape()
		if(isNPC)
			sleep(2)
		sleep(3)
		//spawn GlobalStats()


mob/proc/onceStats()
	set waitfor = 0
	//set background = 1
	if(client)
		spawn TabDeciderLoop()
		spawn HudUpdate()
		spawn HudUpdateBars()
		spawn(3) soundUpdate() //small delay, optimization shit essentially.
		spawn Check_Masteries()
		sense_hud_init()

		spawn(25) OpenStatsUI() //auto-open the new HTML character panel on login
		spawn sense_hud_update()
		spawn(5) CheckTyping()

mob/var
	tmp/StatsRunning = 0
	viewstats=1
	BPrestriction=1
	hasnav=0
	CurrentAnger="Calm"
	AATarget
	BPChange
	HellStar=0
//var/World_BP_Cap=1000000
//var/World_BP_Cap_Setting=0
var/firstcleaner=1
var/Day
var/TimeCycle

mob/var
	hasshenron=0
	hasporunga=0
	Hell=0
	hasmegaburst
	hashomingfinisher
	Walkthroughwalls
	exempt
	hascore
	spacebreather
	safetyBP
mob/var/tmp
	highdamage
	lowenergy
	highfatigue
	eat
	returning
	spacetime = 100

mob/proc/Stats()
	set waitfor = 0
	//set background = 1
	while(src)
		var/sleep_tiem = 2
		if(LoggingOut) return
		if(TimeStopped&&!CanMoveInFrozenTime&&expressedBP>=6.0e+010) CanMoveInFrozenTime = 1
		//BP Ranking...
		if(LoggingOut) return
		spawn StatRank()
		if(!name)
			name = "[rand(1,1000)]" //fix for no names
		if(!signature)
			var/pt1=num2text(rand(1,999),3)
			var/insert1=num2text(rand(50,99),2)
			var/pt2=num2text(rand(1,999),3)
			var/insert2=num2text(rand(20,30),2)
			signature=addtext(pt1,insert1,pt2,insert2)
		if(!signiture)
			signiture = signature
		if(isNPC)
			sleep(20)
		if(expandlevel==0)
			expandBuff=1
		if(absorbadd > 0 && BP < relBPmax)
			BP+=capcheck(abs((0.0001*absorbadd)))
			absorbadd-=(0.0001*absorbadd)
			absorbadd = max(absorbadd,0)
			absorbadd = min(absorbadd,BPCap)
		if(src.loc==null||src.x>=501||src.y>=501||src.z==29||src.z==30)
			if(src.loggedin)src.Locate()
		current_area = GetArea()

		if(!attacking && !minuteshot && prob(1)) IsInFight = 0
		if(client && combatTag && world.time >= combatTagExpire) clear_combat_tag() //the display/music "In Battle" tag lasts combat_tag_duration (90s) past the last hit dealt or received
		//Gains Buffer
		if(!Gaintimer||minuteshot)
			if(Buffertimer<=3000)
				Buffertimer++
				BPBuffer+=relBPmax*BPTick*Egains*(1/35)
				if(BPBuffer>relBPmax)
					BPBuffer=relBPmax
		else
			Gaintimer--
		if(hiddenpotential < 0)
			hiddenpotential = abs(hiddenpotential)
		hiddenpotential = min(hiddenpotential,TopBP)
		if(zenkaiStore < 0)
			zenkaiStore = abs(zenkaiStore)
		if(!has_zenkai()) zenkaiStore = 0 //non-Saiyan-DNA races have no Zenkai at all
		if(!dead && !deathregening && has_zenkai())
			if(ZenkaiMod<=1&&prob(1))
				zenkaiStore *= (abs(0.99*ZenkaiMod))
			if(zenkaicount && prob(65))
				zenkaiStore += (abs(0.25*BPTick*zenkaicount*BP*max((log(ZenkaiMod)),1)))
			if(zenkaiTimer > 0 && zenkaiStore > 0)
				zenkaiTimer -= 1
			if(zenkaiStore > 0 && zenkaiTimer <= 0 && HP >= 80 && !KO)
				BP+=capcheck(abs((0.0005*zenkaiStore)))
				zenkaiStore-=(0.0005*zenkaiStore) //WOW THIS WAS A HARD THING TO DO, A VEVEVERY HARD
				zenkaiStore = max(zenkaiStore,0)
			else if(zenkaiStore > 0 && zenkaiTimer <= 0)
				BP+=capcheck(abs((0.000025*zenkaiStore)))
				zenkaiStore-=(0.000025*zenkaiStore) //WOW THIS WAS A HARD THING TO DO, A VEVEVERY HARD
				zenkaiStore = max(zenkaiStore,0)
			if(zenkaiStore == 0)
				zenkaiTimer = 200
			else if(zenkaiStore)
				zenkaiStore = min(zenkaiStore,BPCap)
		if(angercooldown)
			angercooldown -= 1
			angercooldown = max(angercooldown,0)
		if(BP<0)
			BP=1
		if(safetyBP > BP)
			BP = safetyBP
		else
			safetyBP = BP
		safetyBP = abs(safetyBP)
		if(HP<=0)
			HP = 0
			if(!KO)
				KO()
			else if(!dead)
				spawn(10)
					if(HP<=1)
						spawn Death()
		if(Mutations&&!MutationImmune)
			if(Race=="Android")
				Mutations=0
			SpreadDamage(0.005*Mutations)
		if(isnull(icon))
			icon = oicon
		if(train || med || minuteshot)
			kicapacity_remove = min((kicapacity_remove + 0.005),1)
			phys_remove = min((phys_remove + 0.005),1)
			bp_remove = min((bp_remove + 0.005),1)
		//Walking into space
		if(Planet=="Space"&&!current_area.InsideArea)
			if(!spacesuit&&!ship&&!spacewalker&&!spacebreather&&!inpod&&!Space_Breath)
				spacetime--
				if(!spacetime)
					view()<<"[src] suffocates and dies!"
					spawn Death()
		else if(spacetime!=100)
			spacetime=100
		//Negative age prevention.
		if(client)
			if(Age<1) Age=1
			if(SAge<1) SAge=1
			if(Body<1) Body=1
		if(ssj<4&&!IsAVampire&&!immortal&&!biologicallyimmortal)
			var/tmpdeclinediv
			if(Age<=InclineAge)
				tmpdeclinediv = Age/InclineAge
				Body=Age
			else if(Age>=DeclineAge&&!dead&&DeathRegen<2)
				Body=25-((Age-DeclineAge)*0.5*DeclineMod)
				tmpdeclinediv=DeclineAge/Age
				if(Body<0.1)
					Body=4
					view(src)<<"[src] dies from old age."
					EnteredHBTC=0
					buudead=1
					Death()
					buudead=0
					might=0
					yemmas=0
					majinized=0
					mystified=0
					unlockPotential=0
					Age=4
			else
				tmpdeclinediv = 1
			if(tmpdeclinediv!=1) AgeDiv=((-0.5*tmpdeclinediv+2)*(0.5*tmpdeclinediv+1)) - 1.25
		else
			AgeDiv=1
			Body = 25
		Auto_Gain() //ascension stuff, need to change later
		//Age thing
		if(Age<=10) Body=Age
		if(icon_state=="KB")
			spawn(4)
				icon_state=""
		//Apeshit SSj4 thingy
		if(Apeshit)
			//if(Apeshitskill < 10) Apeshitskill+=0.01
			usr.canRevert=1
			if(prob(1)) if(golden&&hasssj&&!hasssj4&&expressedBP>=ssj4at&&BP>=rawssj4at)
				usr<<"You feel calmer."
				spawn
					Apeshit_Revert()
					SSj4()
		//Afterlife Return Timer...
		if(client)
			if(dead) if(Planet&&Planet!="Afterlife"&&Planet!="Heaven"&&Planet!="Hell"&&Planet!="Sealed")
				if(KeepsBody)
					if(Ki<=(MaxKi/6))
						if(!returning)
							returning=1
							usr<<"Your spirit is waving and your time in the Material World is coming to a close."
						if(returning)
							if(prob(5))
								SpreadHeal(100,1,1)
								view(usr)<<"[src]'s time in the living world has expired."
								if(HasSoul)
									loc=locate(187,104,6) //And finally, send them to the death checkpoint...
								else if(!HasSoul)
									loc=locate(187,104,7) //And finally, send them to the death checkpoint...
								returning=0
								sleep(1)
				else if(!KeepsBody)
					SpreadHeal(100,1,1)
					view(usr)<<"[src] cannot exist outside of the Afterlife."
					if(HasSoul)
						loc=locate(187,104,6) //And finally, send them to the death checkpoint...
					else if(!HasSoul)
						loc=locate(187,104,7) //And finally, send them to the death checkpoint...
					returning=0
					sleep(1)

		//Anger display text...
		if(CurrentAnger!=Emotion)
			CurrentAnger=Emotion
			view(usr)<<"<font color=#FF0000>[usr] appears [Emotion]"
		//If the King is dead...
		if(King_of_Vegeta==name) if(dead)
			usr<<"You are no longer King of Vegeta, since you are dead."
			King_of_Vegeta=null
		//Absorbtion decline...
		if(absorbadd>BP&&!lssj) absorbadd*=0.95
		if(prob(0.5)) if(!absorbable) absorbable=1
		//High damage / low energy notifiers
		if(!highdamage&&HP<=20)
			view(usr)<<"<font color=red>You notice [usr] has become highly damaged..."
			highdamage=1
		if(highdamage&&HP>20) highdamage=0
		if(!lowenergy&&Ki<=MaxKi*0.2)
			view(usr)<<"<font color=red>You notice [usr] has become very drained..."
			lowenergy=1
		if(lowenergy&&Ki>MaxKi*0.2) lowenergy=0
		if(!highfatigue&&stamina<maxstamina*0.2)
			view(usr)<<"<font color=red>You notice [usr] has become very fatigued..."
			highfatigue=1
		if(!highfatigue&&stamina>maxstamina*0.2) highfatigue=0
		if(KO)
			//regen=0
			if(Anger>=120)
				if(prob(1)&&prob(1)||(prob(1)&&Ewillpower>=1.5&&prob(1*Ewillpower)))
					view(usr)<<"<font color=red>[usr] willed themself back up!"
					SpreadHeal(10)
					vitalKOd = 0
					spawn Un_KO(1)


		if(Ki<0) Ki=0
		//Hell Star
		if(hellstar_disabled==1 && Race=="Makyo"|Race=="Demon"|Parent_Race=="Makyo"|Parent_Race=="Demon")
			if(HellStar)
				if(Ki < MaxKi*2.5)
					Ki += 0.0025 * MaxKi //passive Ki boost
				overcharge = 1
			if(!Hell&&HellStar)
				Hell=1
				if(Race=="Makyo"||Parent_Race=="Makyo")
					HellstarBuff=1.5
					usr<<"<font color=yellow>You feel your power increase greatly from the Makyo Star."
				else
					HellstarBuff=1.25
					usr<<"<font color=red>You feel your power increase a bit from the Makyo Star."
			if(Hell&&!HellStar)
				Hell=0
				HellstarBuff=1
				if(Race=="Makyo"||Parent_Race=="Makyo")
					usr<<"<font color=yellow>You feel your power decrease greatly from the depature of the Makyo Star."
				else usr<<"<font color=red>You feel your power decrease a bit from the depature of the Makyo Star."
		///
		///
		///



		///

		///

		///
		//Paralysis
		if(paralyzed)
			if(paralysistime)
				paralysistime-=1
				if(paralysistime<=0) paralysistime=0
			else
				usr<<"<font color=Purple>The paralysis wears off..."
				paralyzed=0
		//Makes sure that the Supreme Kai can grant Mystic indefinitely.
		if(prob(1)) if(Supreme_Kai==key) mystified=0
		if(client)
			if(Weighted>0)
				weight= max(min((Weighted/(max((expressedBP*Ephysoff*10),1))),2),1)
				BPrestriction = weight
			if(Weighted<=0)
				weight = 1
				BPrestriction = 1
			if(!invenrunning)
				spawn CondenseLoop()
		trainproc()
		//Meditate
		medproc()
		//Gravity
		if(Planetgrav<1) Planetgrav=1
		if(gravmult<0) gravmult=0
		if(swim)
			if(Ki>MaxKi*0.01)
				if(icon_state!="Flight") icon_state="Flight"
				if(!boat) Swim_Gain()
				if(swimmastery<=0.99&&!boat)
					swimmastery += 0.001
					Ki-=max(1+(MaxKi*0.001*(KiMod/(100*swimmastery))),1)
				if(Ki<0) Ki=0
			else
				usr<<"You stop swimming."
				density=1
				swim=0
				Ki=0
				if(Savable) icon_state=""
		if(flight)
			if(!freeflight)
				if(Ki>5)
					Flight_Gain()
					Ki-=max((35/(usr.flightability))+((450*usr.flightspeed)/(usr.flightability)),1)
					if(icon_state!="Flight") icon_state="Flight"
				else
					usr.density=1
					usr.flight=0
					if(usr.Savable) usr.icon_state=""
					usr.isflying=0
					emit_Sound('buku_land.wav')
					usr.overlayList-=usr.FLIGHTAURA
					usr.overlaychanged=1
					usr<<"You're exhausted."
					density=1
					flight=0
		if(current_area && current_area.isdestroyed && client)
			for(var/obj/Planets/P in world)
				if(P.planetType==Planet)
					var/list/randTurfs = list()
					for(var/turf/T in view(1,P))
						randTurfs += T
					var/turf/rT = pick(randTurfs)
					src.loc = locate(rT.x,rT.y,rT.z)
		//Anger Decline
		if(rageExpire && world.time >= rageExpire) //rage lasts at most 2 minutes, then snaps back to calm (1x)
			rageExpire = 0
			Anger = 100
			if(client) src << "<font color=#888888>Your rage fades and you feel calm again.</font>"
		if(Anger>MaxAnger) Anger=MaxAnger //hard cap at MaxAnger (was MaxAnger*10 — that, plus stacking, caused the 12x/20x buffs)
		if(Anger>100) Anger-=((MaxAnger-100)/8000)
		if(Anger<100) Anger=100
		if(Anger<(((MaxAnger-100)/5)+100)) Emotion="Calm"
		if(Anger>(((MaxAnger-100)/5)+100)) Emotion="Annoyed"
		if(Anger>=(((MaxAnger-100)/2.5)+100)) Emotion="Slightly Angry"
		if(Anger>=(((MaxAnger-100)/1.66)+100)) Emotion="Angry"
		if(Anger>=(((MaxAnger-100)/1.25)+100)) Emotion="Very Angry"
		if(StoredAnger==100 && prob(1) && prob(1)) StoredAnger--
		else if(StoredAnger>50 && prob(1)) StoredAnger--
		else if(prob(1) * prob(50/max(1,StoredAnger))) StoredAnger++
		StoredAnger = min(StoredAnger,100)

		//
		/*if(LastKO>=1)
			LastKO-=1*(Anger/100)
			if(LastKO<=0)
				LastKO = 0
				src<<output("<font color=red>[src]'s' anger recharged.","Chatpane.Chat")*/
		//Power Correction
		if(techrate)
			if(usedtechrate<techrate)
				BP+=capcheck((techrate-usedtechrate)*(1/40)*BPTick)
				usedtechrate=techrate
		if(prob(1) && client) //I made this code off of a dime, but it needs to be moved somewhere else that doesn't probably check itself every tick.
			var/ssj_capable
			if(usr.Race=="Heran"||usr.Parent_Race=="Heran"||usr.Race=="Saiyan"||usr.Parent_Race=="Saiyan")
				ssj_capable = 1
			for(var/mob/M in oview())
				sleep(1)
				if(M?.client)
					//
					if(M.ssj && !hasssj && ssj_capable && prob(10) && SSJInspired < 25)
						usr << "<font color=blue>The super form from [M] has inspired you a little to try harder!"
						SSJInspired += 1
						SSJInspired = min(SSJInspired,25)
						if(SSJInspired == 25)
							usr << "<font color=blue>Alright... you've seem to have a inkling on how to achieve a transformation! (Maximum inspiration reached. Keep angering.)"
					if(M.ssj == 2 && hasssj && !hasssj2 && ssj_capable && prob(10) && SSJInspired < 50)
						usr << "<font color=blue>The super 2 form from [M] has inspired you a little to try harder!"
						SSJInspired += 1
						SSJInspired = min(SSJInspired,50)
						if(SSJInspired == 50)
							usr << "<font color=blue>Alright... you've seem to have a inkling on how to achieve a transformation! (Maximum inspiration reached. Keep angering. Form 2 capable.)"
		//RoSaT
		if(Planet=="Hyperbolic Time Dimension")
			HBTCTime-=sleep_tiem
			HBTCTime = max(0,HBTCTime)
			HBTCMod=25//massive increase
			var/hbtctimetest = abs(HBTCTime - 36000)
			switch(hbtctimetest)
				if(3000) usr<<"You have been in the Time Chamber for 30 days."
				if(6000) usr<<"You have been in the Time Chamber for 60 days."
				if(9000) usr<<"You have been in the Time Chamber for 90 days."
				if(12000) usr<<"You have been in the Time Chamber for 120 days."
				if(15000) usr<<"You have been in the Time Chamber for 150 days."
				if(18000) usr<<"You have been in the Time Chamber for 180 days."
				if(21000) usr<<"You have been in the Time Chamber for 210 days."
				if(24000) usr<<"You have been in the Time Chamber for 240 days."
				if(27000) usr<<"You have been in the Time Chamber for 270 days."
				if(30000) usr<<"You have been in the Time Chamber for 300 days."
				if(33000) usr<<"You have been in the Time Chamber for 330 days."
				if(36000)
					loc=locate(154,152,12)
					usr<<"You have spent an entire year in the room."
					Age+=1
					SAge+=1
					HBTCTime=36000
		else HBTCMod=1
		sleep(sleep_tiem)

var/get=0.000000000001
//It also affects s.
proc/Save_Gains()
	var/savefile/S=new("GAIN")
	S["Hardcap"]<<HardCap
	S["Captype"]<<CapType
	S["Caprate"]<<CapRate
	S["STATS"]<<showstats
proc/Load_Gains()
	if(fexists("GAIN"))
		var/savefile/S=new("GAIN")
		S["Hardcap"]>>HardCap
		S["Captype"]>>CapType
		S["Caprate"]>>CapRate
		S["STATS"]>>showstats