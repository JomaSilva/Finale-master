//Monster AI
mob/var
	isBlaster // whether or not a specific mob's AI will blast shit.

//idea and some code from Ter13

mob
	OnStep()
		set waitfor = 0
		..()
		if(client && prob(45 * (HP / 100)))
			for(var/mob/npc/nE in viewers(MAX_AGGRO_RANGE,src))
				if(nE.AIAlwaysActive && nE.isNPC && nE.hasAI && nE.allied==0) nE.foundTarget(src)
	npc
		var
			aggro_dist = 30
			strafe_Dist = 3
			keep_dist = 1
			chase_speed = 3
			blast_dist = 5

			zanzoAI = 0
			strafeAI = 0
			allied = 0 //says if a npc will "find" player targets.
			//
			hasAI = 1
			AIRunning=0
			AIAlwaysActive=0
			//
			tmp/turf/aggro_loc
			tmp/turf/home_loc

			//
			list/behavior_vals = list(50,50,50,50) //courage, rage, kindness, and logic, max 100, min 0
			behavior_vals_m = list(1,1,1,1) //modifiers to these behavior values, the above is somewhat randomized, so set these to what you want
			tmp/list/behavior_vals_t = list(0,0,0,0)
			tmp/list/e_behavior_vals = list(0,0,0,0) //expressed values, after modifications
			tmp/bhv_set = 0

			tmp
				keep_track_dmg //simple, the higher this value, the worse it's going for the npc
				keep_track_allies //simple, the higher this value, the better its going for the npc
				list/allies = list()
				keep_track_relation //simplish? this correlates your BP differences.
			
			//courage determines when the mob flees, and if the mob chooses to get involed in beings stronger than it.
			//rage determines anger values for the mob- seeing it's kin get killed, etc will cause strength increases and temporarily higher courage vals.
			//kindness determines mercy- should I kill or should I spare? Also, this will trigger rage modifications at higher values when faced with ally death.
			//logic determines how effective the other emotions are.
			
			
			notSpawned = 1

			tmp/next_attack = 0


		//helper functions
		proc
			foundTarget(var/mob/c)
				if(!src.target && c.client && src.hasAI && !client)
					src.attackable=1
					src.target = c
					aggro_loc = src.loc
					AIRunning=1
					initialState()
					for(var/obj/items/Equipment/E in src.contents)
						if(!E.equipped)
							call(E,"Wear")(src)
					if(isBoss||sim||istype(src,/mob/npc/Splitform))src.chaseState()
					else src.wanderState()
			initialState()
				spawn NPCTicker() //do a initial tick when starting chase
				spawn checkState()
				current_area = GetArea()
				if(current_area)
					current_area.my_npc_list |= src
					current_area.my_mob_list |= src
				return
			lostTarget()
				var
					rng = range(aggro_loc,aggro_dist)
					tmp/mob/trg
					mdist = aggro_dist-1
					d
				//search for combatants within range
				for(var/mob/c in rng)
					if(!c.client || c.KO || c.HP <= 20) continue
					d = get_dist(src,c)
					if(d<mdist||(d==mdist&&rand(1)))
						mdist = d
						trg = c

				//if we found anything, chase, if not, reset
				if(trg && trg.client && src.hasAI)
					src.target = trg
					spawn(1)
					chaseState()
				else
					resetState()

			attack()
				sleep(2)
				IsInFight = 1
				//
				if(get_dist(src,target) < 2)
					if(target.blocking && prob(15)) dashing = 1
					else if(target.choreoattk && prob(15))
						holdblock()
						block_hold_time++
						canmove = 0
					else Attack()
				else if(haszanzo) Attack()
				var/testactspeed = Eactspeed
				testactspeed = Eactspeed * 1.25 / (globalmeleeattackspeed*hitspeedMod)
				if(target.stagger) testactspeed /= 2
				if(combo_count > 3) testactspeed *= 4
				next_attack = world.time + testactspeed
				spawn(testactspeed)
					if(blocking)
						stopblock()

			blast()
				var/bcolor='12.dmi'
				bcolor+=rgb(blastR,blastG,blastB)
				var/obj/attack/blast/A=new/obj/attack/blast/
				emit_Sound('fire_kiblast.wav')
				A.loc=locate(src.x,src.y,src.z)
				A.icon=bcolor
				A.density=0
				spawn(1) if(A) A.density = 1
				A.basedamage=0.5
				A.BP=expressedBP
				A.mods=Ekioff*Ekiskill
				A.murderToggle=src.murderToggle
				A.proprietor=src
				A.dir=src.dir
				walk(A,dir,2)
				spawn A.Burnout()
				next_attack = world.time + 3

			NPCStats()
				set waitfor = 0
				CheckOverlays()
				update_health_bar()
				if(prob(50))
					if(expressedBP > 1000) haszanzo = 1
					statify()
					powerlevel()

		//state functions
		proc
			chaseState()
				set waitfor=0
				var/d = get_dist(src,target)
				var/blastbreak = 0
				var/dashBreak = 0
				while(d>keep_dist && src.hasAI && target)
					//if the Target is out of range or dead, bail out.
					if(!src.target.client)//repetition to ensure AI doesn't attack AI.
						src.lostTarget()
						return 0
					if(get_dist(aggro_loc,src)>aggro_dist*2||(src.target.KO&&!src.isBoss)||(src.target.KO&&src.isBoss&&prob(20)))
						src.lostTarget()
						return 0
					if((e_behavior_vals[1] > 35 || e_behavior_vals[2] >= 75) && monster)
						if(isBlaster && blast_dist >= d && prob(15))
							blastbreak = 1
							break
						if(d <= 10 && d >= 3 && prob(10))
							dashBreak = 1
							break
						//if the path is blocked, take a random step
						if(totalTime >= OMEGA_RATE)
							if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
							totalTime -= OMEGA_RATE
							. = step(src,get_dir(src,target))
							if(!.)
								if(prob(45))
									for(var/turf/T in get_step(src,dir))
										var/turf/nT = get_step(T,dir)
										if(nT.x && nT.y && nT.z && !nT.density)
											emit_Sound('buku.wav')
											loc = locate(nT.x,nT.y,nT.z)
											break
								else
									step_rand(src)
									break
					else
						if(d<=aggro_dist*2)
							//if the path is blocked, take a random step
							if(totalTime >= OMEGA_RATE)
								if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
								totalTime -= OMEGA_RATE
								. = step(src,get_dir(target,src))
								if(!.)
									step_rand(src)
					sleep(chase_speed)
					d = get_dist(src,target)
				if(blastbreak)
					dir = get_dir(src,target)
					blast()
					spawn(1)
						chaseState()
				else if(dashBreak)
					attack()
					spawn(3)
						chaseState()
				else
					attackState()
				return 1

			attackState()
				set waitfor=0
				var/d
				while(target && src.target.HP>0 && src.hasAI && target)
					d = get_dist(src,target)
					//if the Target is too far away, chase
					if(d>src.keep_dist)
						chaseState()
						return
					if((src.target.KO&&!src.isBoss)||(src.target.KO&&src.isBoss&&prob(20)))
						break
					if(zanzoAI && prob(5))
						randattackState()
						return
					if(isBlaster && prob(4))
						strafeState()
						return
					if(HP <= HP - e_behavior_vals[1])
						runawayState()
						return
					if(e_behavior_vals[3]>=75 && target.HP <= 40)
						resetState()//no longer fight if kind and target is damaged sufficiently
						return
					//if the Target is too close, avoid
					if(totalTime >= OMEGA_RATE && !grabParalysis)
						if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
						totalTime -= OMEGA_RATE
						if(d<src.keep_dist)
							//if the path is blocked, take a random step
							. = step_away(src,target)
							if(!.)
								step_rand(src)
						//if we are eligible to attack, do it.
						if(attacking)
							next_attack++
						if(world.time>=next_attack)
							attack()
					sleep(chase_speed)

				//when the loop is done, we've lost the Target
				src.lostTarget()
			strafeState()
				set waitfor=0
				var/d
				while(d <= strafe_Dist && src.hasAI)
					d = get_dist(src,target)
					if(d>src.strafe_Dist + 3)
						chaseState()
						return
					//if the Target is too close, avoid
					if(totalTime >= OMEGA_RATE && !grabParalysis)
						if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
						totalTime -= OMEGA_RATE
						if(d<src.strafe_Dist)
							//if the path is blocked, take a random step
							. = step_away(src,target)
							if(!.)
								step_rand(src)
							//if we are eligible to attack, do it.
						if(world.time>=next_attack)
							dir = get_dir(src,target)
							blast()
					sleep(chase_speed)
					//if the Target is too far away, chase
					if(d >= strafe_Dist || prob(10))
						if(isBlaster)
							dir = get_dir(src,target)
							blast()
						chaseState()
						return
				if(world.time>=next_attack) blast()
				chaseState()

			randattackState()
				set waitfor=0
				var/d
				var/zanzoamount = 3
				while(src.target.HP>0 && !src.target.KO && src.hasAI)
					d = get_dist(src,target)
					if(zanzoamount >= 1)
						zanzoamount -= 1
					else break
					//if the Target is too far away, chase
					if(d>src.keep_dist)
						chaseState()
						return
					//if the Target is too close, avoid
					if(totalTime >= OMEGA_RATE && !grabParalysis)
						if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
						totalTime -= OMEGA_RATE
						if(d<src.keep_dist)
							//if the path is blocked, take a random step
							. = step_away(src,target)
							if(!.)
								step_rand(src)
						//if we are eligible to attack, do it.
						flick('Zanzoken.dmi',src)
						src.loc = pick(block(locate(target.x + 1,target.y + 1,target.z),locate(target.x - 1,target.y - 1,target.z)))
						src.dir = get_dir(src,target)
						if(world.time>=next_attack)
							attack()
					sleep(chase_speed * 5)
				attackState()

			wanderState()
				set waitfor=0
				if(home_loc && src.hasAI)
					var/d = get_dist(src,home_loc)
					var/sd = get_dist(src,target)
					if(sd >= 30)
						resetState()
						return
					while(src.HP>=99 && d <= aggro_dist)
						sd = get_dist(src,target)
						if(sd <= 20)
							if(istype(src,/mob/npc/Enemy))
								chaseState()
								return
						else if(sd >= 30 || sd == null || isnull(target))
							resetState()
							return
						checkState()
						step_rand(src)
						sleep(5)
			runawayState()
				set waitfor=0
				var/d = get_dist(src,target)
				while(src.HP <= 25 && d <= aggro_dist && src.hasAI)
					if(src.HP > 25)
						if(e_behavior_vals[1]>50||d > keep_dist)
							chaseState()
							return
					if(totalTime >= OMEGA_RATE && !grabParalysis)
						if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
						totalTime -= OMEGA_RATE
						if(d<src.keep_dist)
							//if the path is blocked, take a random step
							. = step_away(src,target)
							if(!.)
								step_rand(src)
					sleep(chase_speed)
				resetState()

			resetState()
				set waitfor=0
				if(home_loc && src.hasAI)
					var
						//allow us longer than it should take to get home via distance
						returntime = world.time + get_dist(src,home_loc) * (3 + chase_speed)
					while(world.time<returntime&&src.loc!=home_loc)
						//if the path is blocked, take a random step
						. = step(src,get_dir(src,home_loc))
						if(!.)
							step_rand(src)
							sleep(chase_speed)

				src.target = null
				src.aggro_loc = null
				src.attackable = 0
				IsInFight = 0
				if(KO) spawn Un_KO()
				if(grabber)
					grabber.grabbee=null
					grabber.attacking=0
					grabber.canfight=1
				grabber=null
				grabberSTR=null
				AIRunning=0
				grabParalysis = 0
				for(var/a, a<= behavior_vals.len,a++)//reset behavior pools
					behavior_vals_t[a] = 0
					e_behavior_vals[a] = 0
				SpreadHeal(150,1,1)
				for(var/datum/Body/B in body)
					if(B.lopped) B.RegrowLimb()
					B.health = B.maxhealth
				Ki=MaxKi
				stamina=maxstamina
			
			behavior_check()
				set waitfor=0
				keep_track_allies=0
				for(var/mob/npc/M in view(10))
					if(!M in allies && M.type == type)
						allies+=M
					if(M.HP >= 80) keep_track_allies++
					else keep_track_allies--
					if(M.KO && e_behavior_vals[3] > 55) //increase anger if kindness is sufficient enough
						behavior_vals_t[3]-- //decrease kindness as a result
						behavior_vals_t[2]++
				if(expressedBP && target) keep_track_relation = target.expressedBP / expressedBP
				if(!keep_track_dmg)
					keep_track_dmg = HP
				else
					var/flow = HP - keep_track_dmg
					if(flow < 1 && flow > -1) flow = 0
					flow += keep_track_relation
					if(flow<0)
						flow = min(flow,-1)
						behavior_vals_t[1]+=flow + keep_track_allies*(e_behavior_vals[1]/50) //tick fear and rage
						behavior_vals_t[2]+=2*(-1/flow) //rage is limited by the flow var.
					else
						flow = max(flow,1)
						behavior_vals_t[1]+=flow
						behavior_vals_t[2]-=2*(1/flow)
					keep_track_dmg = HP
				
				


			checkState() //basically a Stats.dm but for NPCs only.
				set waitfor=0
				set background = 1
				spawn while(src && src.AIRunning)
					sleep(5)
					//emotions
					if(prob(60)) behavior_check()
					if(!bhv_set)
						for(var/a=1, a<= behavior_vals.len,a++)
							behavior_vals[a] *= (rand(1,10) / max(1,rand(1,10)))
						bhv_set = 1
					for(var/a=1, a<= behavior_vals.len,a++)
						behavior_vals_t[a] = clamp(behavior_vals_t[a],0,100)
						//behavior_vals[a] = clamp(behavior_vals_t[a],0,100)
					e_behavior_vals[4] = clamp((behavior_vals[4] * behavior_vals_m[4]) + behavior_vals_t[4],0,100)
					e_behavior_vals[1] = round(clamp((behavior_vals[1] * behavior_vals_m[1]) + behavior_vals_t[1],0,100),max(1,e_behavior_vals[4]/2)) //logic rounds off the emotions- 100 logic will mean each emotion can be 0, 50, or 100.
					e_behavior_vals[2] = round(clamp((behavior_vals[2] * behavior_vals_m[2]) + behavior_vals_t[2],0,100),max(1,e_behavior_vals[4]/2)) //less logic means emotions can be a bit more complex.
					e_behavior_vals[3] = round(clamp((behavior_vals[3] * behavior_vals_m[3]) + behavior_vals_t[3],0,100),max(1,e_behavior_vals[4]/2))
					//emotions
					stamina = maxstamina * 0.80
					NPCStats()
					HealthSync()
				while(src && src.AIRunning)
					//
					sleep(chase_speed)
					mobTime += 0.4 
					mobTime += max(log(5,Espeed),0.1) //max prevents negatives from DESTROYING US ALL
					CHECK_TICK
					if(KB || stagger)
						mobTime = 0
					if(slowed)
						mobTime/=2
					if(KO)
						mobTime = 0
					if(paralyzed)
						outToWork = rand(1,12)
						if(!outToWork==12) mobTime = 0
					CHECK_TICK
					totalTime += mobTime //ticker
					
					CHECK_TICK
					if(!canmove)totalTime=0
					if(!move)totalTime=0 //legacy var
					if(gravParalysis)totalTime=0
					if(!ThrowStrength)
						if(KBParalysis) KBParalysis=0
					if(KBParalysis) totalTime=0
					if(Guiding) totalTime = 0
					if(Frozen) totalTime = 0
					if(stagger) totalTime = 0
					if(stunCount >= 1)
						totalTime = 0
						stunCount = max(0,stunCount - 1)
					if(!IsInFight && buildStun)
						buildStun = max(0,buildStun - 1)
					if(blocking)
						block_hold_time++
					else block_hold_time=0
					if(attacking>0)
						canfight=0
						canbeleeched=1
						if(hasTime) attacking = max(0,attacking-0.5)
					else
						attacking=0
						canbeleeched=0
					stagger = max(0,stagger)
					if(post_attack && prob(35)) post_attack = 0
					if(last_dir != dir && stagger)
						if(prob(30+Etechnique)) stagger = max(0,stagger - 1)
					if(stagger && blocking && prob(35+Etechnique)) stagger = max(0,stagger - 1)
					if(!IsInFight && stagger)
						stagger = max(0,stagger - 1)
					if(dash_cool) dash_cool= max(0,dash_cool-1)
					if(rand_step_cool && prob(50)) rand_step_cool=max(0,rand_step_cool-1)
					if(omegastun||launchParalysis) totalTime=0 //all-encompassing stun for style editing, etc.
					if(totalTime) hasTime = 1
					else hasTime = 0
					//Fighting checks
					if(hasTime) canfight = 1
					else canfight = 0
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
					if(prob(15) && grabParalysis && grabber && grabber.is_choking)
						var/dmg = grabber.NormDamageCalc(src) + grabCounter
						damage_m(src,dmg,grabber.selectzone,grabber.murderToggle,grabber.penetration)
					if(omegastun||launchParalysis) totalTime=0 //all-encompassing stun for style editing, etc.
					if(totalTime >= OMEGA_RATE)
						totalTime = OMEGA_RATE
						if(grabParalysis)
							totalTime = 0
							if(grabber)
								var/escapechance=(Ephysoff*expressedBP*3)/grabberSTR
								if(prob(escapechance)||(isBoss && prob(escapechance + 5)))
									grabber.grabbee=null
									attacking=0
									canfight=1
									grabber.attacking=0
									grabber.canfight=1
									grabberSTR=null
									grabParalysis = 0
									view(src)<<output("<font color=#990000>[src] breaks free of [grabber]'s hold!","Chat")
									grabber = null
								else view(src)<<output("<font color=#FFFFFF>[src] struggles against [grabber]'s hold!","Chat")
							else grabParalysis = 0
		New()
			. = ..()
			if(notSpawned) src.home_loc = src.loc