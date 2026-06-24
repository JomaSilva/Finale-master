mob/keyable/verb //assassin skills (precise)
	Shock()//Deals damage, and then stuns the opponent, while also dealing a bit of damage to a specific limb over a short period.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*8
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
					usr.emit_Sound(punchrandomsnd,0.33)
					if(AttackMultiple(target,2,null,null,"sticks a fist into",1))
						var/a = 2
						var/mob/oldt = target
						spawn while(a > 0 && oldt)
							damage_mob(oldt,1 + Ephysoff/2 + Etechnique/2)
							a--
							sleep(15)
				sleep(2)
				target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Reverb() //An attack, that on success, causes more damage to the opponent over time.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*12
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
					usr.emit_Sound(punchrandomsnd,0.33)
					if(AttackMultiple(target,2,null,null,"shoots a flying fist, brimming with energy, at",1))
						var/a = 3
						var/mob/oldt = target
						spawn while(a > 0 && oldt)
							oldt.SpreadDamage(5 + Ephysoff + Etechnique,murderToggle)
							a--
							sleep(20)
				sleep(2)
				target.stagger -= 1
			sleep(20)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Precise_Explosion() //Attacks the targeted limb with a attack that may axplode it
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*15
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 20
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
					emit_Sound(punchrandomsnd,0.33)
					if(AttackMultiple(target,2,null,null,"sticks a finger into",1))
						var/mob/oldt = target
						sleep(20)
						damage_mob(oldt,70 + Ephysoff + Etechnique)
				target.stagger -= 1
			sleep(20)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Hokuto_Hyakuretsu_Ken() //ATATATATATATATATATATATATATATATA-wawawa. Barrages an enemy with attacks. If success, a small probability check happens and MORE DAMAGE is delivered.
		set category="Skills"
		set desc = "Rapidly strike a foe based on your unarmed skill. Unarmed skill. Special skill."
		if(!unarmed&&(weaponeq>1||twohanding))
			usr<<"You need a free hand to use this!"
			return
		if(usr.ultiCD)
			usr<<"Melee special skills on CD for [ultiCD/10] seconds."
			return
		if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<18)
			usr<<"You can't use this now!"
			return
		if(!usr.target||get_dist(usr,target)>1)
			for(var/mob/M in oview(1))
				if(M!=usr)
					target=M
					break
		if(!usr.target)
			usr<<"You have no target."
			return
		else
			if(get_dist(usr,target)>1)
				usr<<"You must be next to your target to use this!"
				return
		target.AddEffect(/effect/stun/Hundred_Fists)
		var/beatdown = round(usr.unarmedskill/5)
		while(beatdown)
			spawn MeleeAttack(target,0.4)
			beatdown--
			sleep(1)
		usr.stamina-=18
		usr.ultiCD=18*Eactspeed
		var/kireq=usr.Ephysoff*BaseDrain*20
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 30
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(1))
				target.stunCount += 100
				if(BarrageAttack(0,0,0,"shouts\"ATA\" while punching",100,1))
					var/dmg = NormDamageCalc(target)
					damage_mob(target,dmg)
					sleep(10)
					damage_mob(target,70)
			sleep(30)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

mob/keyable/verb //assassin skills (brutal/stealthy. Relies on not being in combat and deals bonus damage if invisible)
	Cutthroat() //simple surprise skill, deals more damage if not in combat
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*15
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 25
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
					emit_Sound(punchrandomsnd,0.33)
					if(!IsInFight) AttackMultiple(target,1+Etechnique,null,null,"severely cuts",0)
					else AttackMultiple(target,null,null,null,"cuts",0)
				target.stagger -= 1
			sleep(25)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Backstab() //another surprise skill, relies on being behind a opponent.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*15
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 30
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(2))
				step(src,get_dir(src,target))
				if(target in view(1))
					target.stagger += 1
					var/dmg = 0
					var/crit = 0
					if(!IsInFight) dmg+=Etechnique/2
					if(dir == target.dir)
						dmg+=Etechnique/2
						crit = 1
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
					usr.emit_Sound(punchrandomsnd,0.33)
					AttackMultiple(target,dmg,crit,null,"backstabs",0)
				target.stagger -= 1
			sleep(30)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Sneak() //Not actually doing any damage, it temporarily gives you an invisiblity buff. 10 seconds + technique
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*12
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight&&!invisibility)
			basicCD += 60
			usr.Ki-=kireq
			TempBuff(list("invisibility"),10 + Etechnique)
			sleep(60)
			//attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Trip() //Stuns and debuffs a opponent if they're on the ground, doesn't count as being in combat.
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
					if(!target.flight)
						target.stunCount+=30
						target.SpreadDamage(1+Etechnique,0)
						view(src)<<"<font color=red size=2>[src] trips [target]!!!</font>"
					target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."