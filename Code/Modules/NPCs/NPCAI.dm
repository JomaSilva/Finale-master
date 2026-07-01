//Monster AI
mob/var
	isBlaster // whether or not a specific mob's AI will blast shit.

//idea and some code from Ter13

mob
	OnStep()
		set waitfor = 0
		..()
		if(client && prob(75 * (HP / 100)))
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
			tmp/ai_powered_up = 0
			tmp/ai_next_chat = 0
			tmp/ai_powerup_tier = 0 //how many times this fight the NPC has surged (capped escalation)
			tmp/ai_powerup_cd = 0 //world.time gate between surges
			tmp/npc_stats_inited = 0 //one-time heavy stat init done
			tmp/reaggro_running = 0 //a passive re-aggro sweep is already running
			tmp/state_alive = 0      //bumped by every live state-proc iteration; the watchdog re-enters a state if this stops advancing (the state thread died)
			tmp/last_state_alive = -1
			tmp/state_stall = 0
			tmp/ai_freeze_log_cd = 0 //rate-limit the freeze diagnostic dump to DEBUG.log
			tmp/stuck_notime = 0    //consecutive ticks engaged with NO action-time (hasTime=0); a long run = FROZEN


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
					if(isBoss||sim||istype(src,/mob/npc/Splitform)||monster) src.chaseState() //hostile mobs ENGAGE directly instead of passively wandering off
					else src.wanderState()
			initialState()
				NPCInitStats() //MaxKi/maxstamina/willpower must exist before the fight - Ki & stamina abilities depend on them
				spawn NPCTicker() //do a initial tick when starting chase
				spawn checkState()
				current_area = GetArea()
				if(current_area)
					current_area.my_npc_list |= src
					current_area.my_mob_list |= src
				return
			lostTarget()
				//the CURRENT target is still valid and merely DISPLACED (ZanzoClash/rush/throw fling the NPC far from aggro_loc)?
				//keep fighting it -- do NOT fall through to a spurious reset, which full-heals to 100% and drops the NPC to idle.
				if(target && target.client && !target.KO && target.HP > 20 && get_dist(src,target) <= aggro_dist*2)
					spawn(1) chaseState()
					return
				var/rng = range(src,aggro_dist) //search the NPC's CURRENT position, not the stale aggro_loc where it first engaged
				var/tmp/mob/trg
				var/mdist = aggro_dist-1
				var/d
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
					spawn(1) chaseState()
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
				testactspeed = Eactspeed * 0.6 / (globalmeleeattackspeed*hitspeedMod) //more aggressive: ~2x faster swings (was 1.25)
				if(target.stagger) testactspeed /= 2
				if(combo_count > 3) testactspeed *= 2 //smaller post-combo cooldown so it keeps pressuring (was *4)
				next_attack = world.time + testactspeed
				spawn(testactspeed)
					if(blocking)
						stopblock()
					canmove = 1 //ALWAYS restore movement after a swing/brace. The choreoattk branch above sets canmove=0 and NOTHING else in the NPC combat path ever restores it, so a single 15% brace pinned the action clock (checkState: if(!canmove)totalTime=0) forever -> the NPC kept spinning in-state (watchdog saw no stall) but never attacked or turned to face you. THIS was the residual "stands facing nothing after a while" freeze.

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

			npc_combat_chat(var/msg)
				if(world.time < ai_next_chat) return
				var/cooldown = isBoss ? 30 : 50
				ai_next_chat = world.time + cooldown
				view(src) << output("<font color=#FFCC00>[src.name]: [msg]","Chatpane.Chat")
				chatcast(view(src), "<font color=#FFCC00>[src.name]: [msg]", "say")

			npc_power_up()
				if(ai_powerup_cd && world.time < ai_powerup_cd) return //rate-limited tiers, not a one-shot
				if(ai_powerup_tier >= (isBoss ? 3 : 4)) return //capped escalation (bosses cap one tier lower - they already start at ~2.8x average BP)
				ai_powered_up = 1
				ai_powerup_tier++
				ai_powerup_cd = world.time + 150
				var/spike = (ai_powerup_tier >= 3) ? 1.6 : 1.4 //a last-ditch surge hits harder
				behavior_vals_t[2] = min(behavior_vals_t[2] + 50, 100)
				behavior_vals_t[1] = min(behavior_vals_t[1] + 40, 100)
				NPCAscension()
				BP = round(BP * spike)
				expressedBP = round(expressedBP * spike)
				if(MaxKi) Ki = MaxKi //a surge refills the tank so it can immediately use Ki abilities
				createDustmisc(loc,3)
				createShockwavemisc(loc,2)
				emit_Sound('powerup.wav')
				var/pmsg = (ai_powerup_tier >= 3) ? "[src.name] is pushed to the brink and ERUPTS with power!" : "[src.name] powers up!"
				view(src) << output("<font color=#FF8800><b>[pmsg]</b></font>","Chatpane.Chat")
				chatcast(view(src), "<font color=#FF8800><b>[pmsg]</b></font>", "say")
				npc_try_transform() //Saiyan-type NPCs that already have a form unlocked may go Super Saiyan here
				ai_next_chat = world.time + 20

			NPCInitStats() //one-time: give the NPC a real Ki pool, stamina and willpower like a player
				if(npc_stats_inited)
					if(!MaxKi) statify()
					return
				if(Ewillpower < 1) Ewillpower = 1
				if(!maxstamina) maxstamina = 100
				statify() //compute MaxKi / effective stats / willpower
				powerlevel()
				if(!MaxKi) MaxKi = baseKi
				Ki = MaxKi
				stamina = maxstamina
				maxNutrition = 100
				currentNutrition = 100 //full nutrition for NPCs (default 50 nerfs them); they don't starve mid-fight
				npc_stats_inited = 1

			NPCStaminaTick() //real stamina: drains under sustained combat, recovers between exchanges
				if(!maxstamina) maxstamina = 100
				if(IsInFight)
					stamina = max(0,stamina - maxstamina * 0.006 * max(staminadrainMod,0.1))
				else
					stamina = min(maxstamina,stamina + maxstamina * 0.02 * max(staminagainMod,0.1))

			npc_defensive_check(d) //a smart fighter guards when pressured instead of standing and eating hits
				if(!target) return
				if(blocking)
					if(!stagger && HP > 40 && prob(40)) stopblock() //drop the guard once the pressure is off
					return
				if(d <= 1 && (stagger >= 2 || HP <= 35) && e_behavior_vals[4] >= 35 && prob(35))
					holdblock()
					spawn(rand(8,18)) if(blocking) stopblock() //auto-release so it never gets stuck guarding

			npc_kiai() //get-off-me ki burst: knock adjacent foes back to break melee pressure
				if(kiaionCD || Ki < 40 * BaseDrain) return
				Ki -= 40 * BaseDrain
				kiaionCD = max(round(4000/(Ekiskill*10+kieffusionskill+kiaiskill+1)),10)
				flick("Blast",src)
				emit_Sound('scouterexplode.ogg')
				for(var/mob/M in oview(1,src))
					if(M == src) continue
					var/strength = round((Ekioff*10+Ekiskill*10+kieffusionskill+kiaiskill)/(max(M.Ekiskill,M.Etechnique)*10+max(M.Ekidef,M.Ephysdef)*10+M.kicirculationskill+M.kicontrolskill+1)*BPModulus(expressedBP,M.expressedBP))
					strength = max(strength,3)
					spawn if(M && M.loc) M.KiKnockback(src,strength)
				spawn(kiaionCD) kiaionCD = 0

			npc_try_transform() //OPT-IN by data: only NPCs that ALREADY have the form (player clones / scripted Saiyans) ever transform; a no-op for normal mobs
				if(transing || ssj) return
				if(!(Race == "Saiyan" || Parent_Race == "Saiyan" || Race == "Heran" || Parent_Race == "Heran")) return
				if(!hasssj) return //never forced onto a random monster
				if(Ki < MaxKi * 0.25) return
				firsttime = 1 //skip the player-facing cinematic for an NPC
				SSj()

			npc_combat_action(d) //resource- & personality-aware action picker (kiai / grab / blast / barrage / melee)
				if(!target) return
				var/ki_ratio = MaxKi > 0 ? (Ki / MaxKi) : 1
				var/power_ratio = (expressedBP > 0 && target.expressedBP > 0) ? (target.expressedBP / expressedBP) : 1
				var/rage = e_behavior_vals[2]
				var/logic = e_behavior_vals[4]
				dir = get_dir(src,target)
				if(d <= 1 && ki_ratio <= 0.3 && stagger && !kiaionCD && Ki >= 40 * BaseDrain) //cornered & low Ki -> make space
					npc_kiai()
					if(prob(40)) npc_combat_chat(pick("Get back!","Away from me!","Enough!"))
					return
				if(isBlaster && ki_ratio > 0.2 && d >= 2) //ranged poke; reckless (low logic) blasts more often
					var/blast_chance = 20 + (power_ratio >= 1.2 ? 35 : 0) + max(0,(50 - logic)/2)
					if(prob(blast_chance))
						blast()
						return
				if(d < 2 && rage >= 45 && Ki >= 10 * BaseDrain && !attacking && prob(45)) //melee flurry -- fires more often now that NPCs punch instead of grab
					BarrageAttack(,,,,rand(2,4),2)
					next_attack = world.time + max(6,round(Eactspeed))
					if(prob(isBoss ? 45 : 30)) npc_combat_chat(pick("RAAAH!","Disappear!","I'll finish this!","Take THIS!"))
					return
				attack()
				if(prob(isBoss ? 45 : 25))
					npc_combat_chat(pick("HIYAH!","Take that!","Is that all?!","Pathetic!","You call that fighting?!"))

			NPCStats()
				set waitfor = 0
				CheckOverlays()
				update_health_bar()
				if(expressedBP > 1000) haszanzo = 1
				statify() //keep MaxKi/effective stats current so Ki regen + ability gates read real numbers
				powerlevel()

		//state functions
		proc
			chaseState()
				set waitfor=0
				var/d = get_dist(src,target)
				var/blastbreak = 0
				var/dashBreak = 0
				while(d>keep_dist && src.hasAI && target)
					state_alive++
					//if the Target is out of range or dead, bail out.
					if(!src.target.client)//repetition to ensure AI doesn't attack AI.
						src.lostTarget()
						return 0
					if((get_dist(aggro_loc,src)>aggro_dist*2 && get_dist(src,target)>aggro_dist)||(src.target.KO&&!src.isBoss)||(src.target.KO&&src.isBoss&&prob(20))) //leash: give up ONLY if the NPC wandered far from home AND the target is far -- a ZanzoClash/throw that displaces the NPC but keeps the target adjacent must NOT trip this
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
								. = step(src,get_dir(src,target)) //close in on the target instead of backing toward the map edge
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
					state_alive++
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
					if(HP <= 25 && e_behavior_vals[1] < 35) //flee only when genuinely low HP AND low courage (old "HP <= HP - courage" was always false)
						runawayState()
						return
					if(e_behavior_vals[3]>=75 && target.HP <= 40)
						resetState()//no longer fight if kind and target is damaged sufficiently
						return
					// Power-up when losing badly or clearly outmatched
					if(HP <= 45 || (expressedBP > 0 && target.expressedBP >= expressedBP * 1.5))
						npc_power_up() //tiered escalation when losing badly or outmatched
					npc_defensive_check(d) //guard / shake off pressure when staggered or hurt
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
							npc_combat_action(d) //resource- & personality-aware: kiai / grab / blast / barrage / melee
					sleep(chase_speed)

				//when the loop is done, we've lost the Target
				if(target && (target.KO || target.HP <= 0) && IsInFight)
					if(prob(isBoss ? 70 : 40))
						npc_combat_chat(pick("Too easy.","As expected.","You never stood a chance.","Know your place!","Don't waste my time."))
				src.lostTarget()
			strafeState()
				set waitfor=0
				if(!target)
					resetState()
					return
				var/d = get_dist(src,target)
				while(d <= strafe_Dist && src.hasAI)
					state_alive++
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
				spawn(1) chaseState()

			randattackState()
				set waitfor=0
				if(!target)
					resetState()
					return
				var/d
				var/zanzoamount = 3
				while(src.target.HP>0 && !src.target.KO && src.hasAI)
					state_alive++
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
						if(!target) break //don't deref target.x on a target that vanished mid-loop (a runtime error would kill this proc)
						src.loc = pick(block(locate(target.x + 1,target.y + 1,target.z),locate(target.x - 1,target.y - 1,target.z)))
						src.dir = get_dir(src,target)
						if(world.time>=next_attack)
							attack()
					sleep(chase_speed * 5)
				spawn(1) attackState()

			wanderState()
				set waitfor=0
				if(!target)
					resetState()
					return
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
					state_alive++
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
					//allow us longer than it should take to get home via distance
					var/returntime = world.time + get_dist(src,home_loc) * (3 + chase_speed)
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
				ai_powered_up = 0
				ai_powerup_tier = 0
				ai_powerup_cd = 0
				for(var/a, a<= behavior_vals.len,a++)//reset behavior pools
					behavior_vals_t[a] = 0
					e_behavior_vals[a] = 0
				SpreadHeal(150,1,1)
				for(var/datum/Body/B in body)
					if(B.lopped) B.RegrowLimb()
					B.health = B.maxhealth
				Ki=MaxKi
				stamina=maxstamina
				//passive re-aggro: a parked hostile NPC still notices a player who walks up and STANDS STILL
				//(OnStep only fires on the player's own movement, so a motionless player used to leave the NPC asleep)
				if(hasAI && monster && !allied && AIAlwaysActive && !reaggro_running)
					reaggro_running = 1
					spawn
						while(src && !AIRunning && !target)
							sleep(20)
							if(!src || AIRunning || target) break
							for(var/mob/M in oview(aggro_dist,src))
								if(M.client && !M.KO && M.HP > 20)
									foundTarget(M)
									break
						reaggro_running = 0
			
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
						if(IsInFight && prob(isBoss ? 60 : 30))
							npc_combat_chat(pick("You'll pay for that!","No!!","That was my comrade!","I'll make you regret this!"))
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
						if(IsInFight && flow < -5 && prob(isBoss ? 50 : 25))
							if(HP <= 30)
								npc_combat_chat(pick("I won't fall here!","Gah... you're stronger than I thought!","Is this... the end?!"))
							else
								npc_combat_chat(pick("Tch!","That hurt...","You'll regret that!","Not bad."))
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
							behavior_vals[a] *= (rand(8,13) / 10) //mild personality variation (~0.8x-1.3x); was 0.1x-10x which turned ~half the mobs into cowards that flee to the corner
						bhv_set = 1
					for(var/a=1, a<= behavior_vals.len,a++)
						behavior_vals_t[a] = clamp(behavior_vals_t[a],0,100)
						//behavior_vals[a] = clamp(behavior_vals_t[a],0,100)
					e_behavior_vals[4] = clamp((behavior_vals[4] * behavior_vals_m[4]) + behavior_vals_t[4],0,100)
					e_behavior_vals[1] = round(clamp((behavior_vals[1] * behavior_vals_m[1]) + behavior_vals_t[1],0,100),max(1,e_behavior_vals[4]/2)) //logic rounds off the emotions- 100 logic will mean each emotion can be 0, 50, or 100.
					e_behavior_vals[2] = round(clamp((behavior_vals[2] * behavior_vals_m[2]) + behavior_vals_t[2],0,100),max(1,e_behavior_vals[4]/2)) //less logic means emotions can be a bit more complex.
					e_behavior_vals[3] = round(clamp((behavior_vals[3] * behavior_vals_m[3]) + behavior_vals_t[3],0,100),max(1,e_behavior_vals[4]/2))
					//emotions
					NPCStats()
					KiRegen() //NPCs now regenerate Ki like players (gated internally by stamina)
					NPCStaminaTick() //stamina now actually drains/regens instead of being pinned at 80%
					BuffLoop() //active forms/buffs (SSJ/Kaioken/etc.) now actually cost the NPC Ki & stamina
					if(combatTag && world.time >= combatTagExpire) clear_combat_tag()
					if(Anger > 100) Anger = max(100,Anger - 1)
					HealthSync()
				while(src && src.AIRunning)
					//
					sleep(chase_speed)
					//WATCHDOG: AIRunning is on but if NO state proc has iterated for ~3 ticks, the state machine
					//DIED (a runtime error silently aborted the proc, or a waitfor=0 handoff dropped the last loop).
					//This loop is guaranteed alive whenever AIRunning=1, so re-enter a state to un-freeze the NPC.
					if(target && hasAI && !client && !KO)
						if(state_alive == last_state_alive)
							state_stall++
							if(state_stall >= 3)
								state_stall = 0
								spawn(1) chaseState()
						else
							state_stall = 0
						last_state_alive = state_alive
					//SAFETY NET for the canmove freeze: canmove has NO restore path inside the NPC combat loop
					//(only attack()'s choreo-brace ever sets it =0), so a clientless fighter that hits canmove=0
					//would pin its action clock (if(!canmove)totalTime=0 below) forever. NPCs never channel beams
					//or charge, so while engaged and not grabbing/grabbed/held it is always safe to force it back on.
					if(!canmove && !client && target && AIRunning && !grabber && !grabbee && !beaming && !charging && !Guiding && !Frozen)
						canmove = 1
					mobTime += 0.4 
					mobTime += max(log(5,Espeed),0.1) //max prevents negatives from DESTROYING US ALL
					CHECK_TICK
					if(KB || stagger >= 3)
						mobTime = 0
					if(slowed)
						mobTime/=2
					if(KO)
						mobTime = 0
					if(paralyzed)
						outToWork = rand(1,12)
						if(outToWork != 12) mobTime = 0 //fixed precedence: was (!outToWork)==12 (always false) -> paralyzed NPCs froze forever
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
					//stagger no longer touches the action clock (players don't lock on stagger either); it only decays below + the >=3 mobTime skip above. THE core fix for NPCs that froze while pressured.
					if(stunCount >= 1) //mirror the PLAYER stun: only a 7/12 chance to lose the action this tick, so a stunned NPC still fights back ~5/12 of the time instead of standing frozen
						outToWork = rand(1,12)
						if(outToWork <= 7) totalTime = 0
						stunCount = max(0,stunCount - (IsInFight ? 1 : 3))
					if(!IsInFight && buildStun)
						buildStun = max(0,buildStun - 1)
					if(blocking)
						block_hold_time++
					else block_hold_time=0
					if(attacking>0)
						canfight=0
						canbeleeched=1
						attacking = max(0,attacking-1) //ALWAYS recover from a swing (even while stun-pressured); the hasTime-gate left 'attacking' stuck high under a stunlock, so testAttack() blocked the NPC forever = punching bag
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
					else if(stagger && prob(45 + Etechnique)) stagger = max(0,stagger - 1) //in-combat recovery: a real fighter shakes off stagger
					if(dash_cool) dash_cool= max(0,dash_cool-1)
					if(rand_step_cool && prob(50)) rand_step_cool=max(0,rand_step_cool-1)
					if(omegastun||launchParalysis) totalTime=0 //all-encompassing stun for style editing, etc.
					if(totalTime) hasTime = 1
					else hasTime = 0
					//FREEZE DETECTOR + AUTO-RECOVER (debug): a clientless NPC engaged (target+AIRunning, not KO) whose action
					//clock can't advance (hasTime=0) for ~30 straight ticks is FROZEN by a stuck soft-lock. Dump every flag
					//to DEBUG.log (throttled) so the true culprit is visible, then clear the whole lock family to un-freeze.
					if(target && AIRunning && !KO && !dead && !client)
						if(!hasTime) stuck_notime++
						else stuck_notime = 0
						if(stuck_notime >= 30)
							stuck_notime = 0
							if(world.time >= ai_freeze_log_cd)
								ai_freeze_log_cd = world.time + 30
								ai_debug_dump("engaged-but-no-actionclock")
							canmove = 1
							stagger = 0
							stunCount = 0
							buildStun = 0
							paralyzed = 0
							gravParalysis = 0
							KBParalysis = 0
							omegastun = 0
							launchParalysis = 0
							Guiding = 0
							Frozen = 0
							if(!grabber) grabParalysis = 0
							totalTime = OMEGA_RATE
							hasTime = 1
							spawn(1) chaseState()
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
					if(stagger >= 3) canfight = 0 //only HEAVY stagger blocks fighting (players don't lock on light stagger; this was an NPC-only punching-bag penalty)
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
//DEBUG: append a full combat-AI state snapshot to DEBUG.log (readable from disk in the game directory).
//Fired automatically by the freeze detector, and on demand by the DBG NPC AI verb.
mob/npc/proc/ai_debug_dump(reason)
	WriteToLog("debug","[time2text(world.realtime,"Day DD hh:mm:ss")] NPC-AI [src.name] ([src.type]) reason=[reason]")
	WriteToLog("debug","  engage: AIRunning=[AIRunning] target=[target] hasAI=[hasAI] KO=[KO] dead=[dead] IsInFight=[IsInFight] combatTag=[combatTag] state_alive=[state_alive] stall=[state_stall] stuck=[stuck_notime]")
	WriteToLog("debug","  clock:  canmove=[canmove] move=[move] canfight=[canfight] hasTime=[hasTime] attacking=[attacking] totalTime=[totalTime] mobTime=[mobTime] next_attack=[next_attack] now=[world.time]")
	WriteToLog("debug","  locks:  stagger=[stagger] stunCount=[stunCount] buildStun=[buildStun] paralyzed=[paralyzed] grabParalysis=[grabParalysis] KB=[KB] KBParalysis=[KBParalysis] gravParalysis=[gravParalysis] Guiding=[Guiding] Frozen=[Frozen] omegastun=[omegastun] launchParalysis=[launchParalysis]")
	WriteToLog("debug","  grab:   grabber=[grabber] grabbee=[grabbee] grabMode=[grabMode] objgrabbee=[objgrabbee] med=[med] charging=[charging] train=[train] blocking=[blocking] beaming=[beaming] blasting=[blasting] volleying=[volleying] sding=[sding]")
	WriteToLog("debug","  stats:  HP=[HP] Ki=[round(Ki)]/[round(MaxKi)] stam=[round(stamina)]/[round(maxstamina)] BP=[BP] expBP=[expressedBP] dir=[dir]")
