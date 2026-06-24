mob/keyable/verb //Beserker skills. More controlling than grab skills, less damage, larger drain.
	Revenge_Demon() //Two-strikes, with a 1 tile throw.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*15
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					var/hdkb = knockbackon
					knockbackon = 0
					if(doAttack(target,null,null,null,"punches",1))
						var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Large-A.ogg','punch_hvy.wav','hit_l.wav','strongkick.wav','strongpunch.wav')
						usr.emit_Sound(punchrandomsnd,volume=0.33)
						AttackMultiple(target,2,null,null,", aiming for the face, jabs",1)
						view(src)<<"<font color=red>[src] throws [target] forward!</font>"
						target.ThrowMe(dir,1)
						target.ThrowStrength = (expressedBP/2)*Ephysoff*Etechnique
						var/base=Ephysoff
						var/phystechcalc
						var/opponentphystechcalc
						if(Ephysoff>1||Etechnique>1)
							phystechcalc = Ephysoff+Etechnique
						if(grabbee.Ephysoff>1||grabbee.Etechnique>1)
							opponentphystechcalc = grabbee.Ephysoff+grabbee.Etechnique
						var/dmg = DamageCalc((phystechcalc),(opponentphystechcalc),base)
						damage_mob(target,dmg*BPModulus(expressedBP,target.expressedBP)/4)
					else
						stagger += 1
						spawn(4) stagger -= 1
					knockbackon = hdkb
					target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Gigantic_Spike() //Slams a person into a wall or ground after picking them up. Basically a clothesline. Requires a 2 grab.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*12
		get_me_a_grab(1)
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.grabbee)
			basicCD += 15
			usr.Ki-=kireq
			if(grabMode==2)
				var/rushSpeed=round(0.4*move_delay,0.1)
				var/dist = round(Espeed + Etechnique + Ephysoff)
				var/rushdir = dir
				var/dmg = 1
				while(dist)
					dist--
					dmg++
					if(!canmove)
						src<<"Your rush fails since you can't move!"
						break
					for(var/turf/T in view(1))
						if(T.density && get_dir(src,T) == dir)
							dmg+=2
							if(T.destroyable && T.Resistance <= expressedBP)
								createDust(T,1)
								emit_Sound('kiplosion.wav')
								T.Destroy()
							else
								dmg+=2
								break
					step(src,rushdir)
					sleep(rushSpeed)
				if(grabbee in view(1))
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Large-A.ogg','punch_hvy.wav','hit_l.wav','strongkick.wav','strongpunch.wav')
					emit_Sound(punchrandomsnd)
					AttackMultiple(target,16+dmg,1,null,"slams",null,3)
					for(var/turf/T in view(Ephysoff/2 + 1))
						if(expressedBP>=T.Resistance)
							createDust(T,1)
							T.Destroy()
				else
					stagger += 1
					src<<"You failed because you missed the enemy. You're stunned!"
					sleep(4)
					stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must have a grabbed person (press grab twice), be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Power_Drag() //Drags a person across the ground dealing damage. Requires a 2 grab
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*12
		get_me_a_grab(1)
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.grabbee)
			basicCD += 15
			usr.Ki-=kireq
			//OutputDebug("Power Drag 0")
			if(grabMode==2)
				grabbee.stagger+=1
				//OutputDebug("Power Drag 1")
				var/rushSpeed=round(0.1*move_delay,0.1)
				var/dist = round(Espeed + Etechnique + Ephysoff)
				var/m_dist = dist
				var/rushdir = dir
				while(dist>0)
					//OutputDebug("Power Drag 2")
					dist--
					if(!canmove)
						src<<"Your rush fails since you can't move!"
						break
					step(src,rushdir)
					spawn AttackMultiple(grabbee,5,null,null,"drags",m_dist)
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Small-A.ogg','ARC_BTL_CMN_Hit_Small-B.ogg','hit_s.wav','weakkick.wav')
					usr.emit_Sound(punchrandomsnd)
					sleep(rushSpeed)
				//OutputDebug("Power Drag 3")
				if(!grabbee)
					stagger += 1
					src<<"You fell because you lost the enemy. You're stunned!"
					sleep(4)
					stagger -= 1
				grabbee.stagger-=1
				//OutputDebug("Power Drag 4")
			sleep(15)
			attacking = 0
		else usr<<"You must have a grabbed person (press grab twice), be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Seismic_Press() //Deals damage to a opponent, stunning them severely and damaging turfs in a radius.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*18
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					AttackMultiple(target,15,null,null,"heavily slams",1)
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Large-A.ogg','punch_hvy.wav','hit_l.wav','strongkick.wav','strongpunch.wav')
					usr.emit_Sound(punchrandomsnd,0.33)
					emit_Sound('kiplosion.wav')
					for(var/turf/T in view(Ephysoff))
						if(expressedBP>=T.Resistance)
							createDust(T,1)
							T.Destroy()
					target.stagger -= 1
					target.stunCount += 20
			sleep(15)
			
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."