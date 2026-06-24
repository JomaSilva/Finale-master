/*
savant << "You can use Zanzoken Combo now! (use the skill to teleport behind a person and attack.)"
savant << "You can use Zanzoken Dodge now! (use the skill to immediately teleport to a free tile around you.)"
savant << "You can use Zanzoken Afterimage now! (use the skill to start producing afterimages which may confuse the enemy.)"
*/
mob/var/tmp/afterimaging=0
mob/keyable/verb
	Zanzoken_Combo()
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*4
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(zanzorange + 2))
				flick('Zanzoken.dmi',src)
				var/turf/tT = get_step(target,get_dir(src,target))
				if(!tT.density)
					Move(tT,dir)
					dir = get_dir(src,target)
					usr.emit_Sound('teleport.wav')
				else
					Move(target.loc,target.dir)
			attacking = 0
		else usr<<"You must be combat ready and have at least [kireq] ki. Also, your maximum zanzoken combo distance is [zanzorange + 2]."
	Zanzoken_Dodge()
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*4
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			flick('Zanzoken.dmi',src)
			Move(tele_rand_turf_in_view(src,zanzorange),dir)
			usr.emit_Sound('teleport.wav')
			//attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Zanzoken_Afterimage()
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*0.4
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			if(!unarmed&&(weaponeq>1||twohanding))
				usr<<"You need a free hand to use this!"
				return
			if(usr.buffCD)
				usr<<"Melee buff skills on CD for [buffCD/10] seconds."
				return
			if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<15)
				usr<<"You can't use this now!"
				return
			flick('Zanzoken.dmi',usr)
			usr.emit_Sound('teleport.wav')
			basicCD += 15
			usr.AddEffect(/effect/illusion/Afterimage)
			usr.Ki-=kireq
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

obj/temp_obj
	IsntAItem = 1
	mouse_opacity = 0
	New()
		..()
		sleep(60)
		deleteMe()

mob/keyable/verb //boxing skills
	One_Two() //boxing skill, jab + cross
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
					AttackMultiple(target,null,null,null,"jabs",1)
				sleep(2)
				if(target in view(1))
					var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
					usr.emit_Sound(punchrandomsnd,0.33)
					AttackMultiple(target,5,null,null,"crosses",1)
				target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	One_Two_Five() //boxing skill, jab + cross + uppercut
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
					AttackMultiple(target,null,null,null,"jabs",1)
				sleep(1)
				var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				usr.emit_Sound(punchrandomsnd,0.33)
				if(target in view(1)) AttackMultiple(target,4,null,null,"crosses",1)
				sleep(2)
				punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				usr.emit_Sound(punchrandomsnd)
				if(target in view(1)) AttackMultiple(target,6,null,null,"uppercuts",1)
				target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	KO_Punch() //boxing skill, just a uppercut, does a bunch of damage.
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
					doAttack(target,16,1,null,"KO Punches",null,3)
				target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Two_One_Four() //boxing skill, cross + jab + uppercut
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*9
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			if(target in view(1))
				target.stagger += 1
				var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				emit_Sound(punchrandomsnd,0.33)
				AttackMultiple(target,2,null,null,"crosses",1)
				sleep(2)
				punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				emit_Sound(punchrandomsnd,0.33)
				if(target in view(1)) AttackMultiple(target,5,null,null,"jabs",1)
				sleep(1)
				punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
				emit_Sound(punchrandomsnd,0.33)
				if(target in view(1)) AttackMultiple(target,7,null,null,"uses the right arm to uppercut",1)
				target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."

mob/keyable/verb //Kicking skills
	Dropkick() //dash- on success it stuns the opponent, on failure it stuns you. 4 tile range, semi-straight line. (tracks)
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*15
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			basicCD += 15
			usr.Ki-=kireq
			get_me_a_target()
			var/rushSpeed=round(0.4*move_delay,0.1)
			var/succ = 0
			var/dist = round(Espeed + Etechnique + Ephysoff/2)
			var/targ_override
			if(get_dist(src,target)>=dist+1)
				targ_override = 1
			var/rushdir = dir
			var/dmg=10
			var/mob/m_rf
			while(dist)
				dist--
				dmg--
				if(!canmove)
					src<<"Your rush fails since you can't move!"
					break
				step(src,rushdir)
				if(target in view(1))
					succ = 1
					break
				if(targ_override)
					for(var/mob/M in oview(1))
						m_rf=M
						succ=1
						break
				if(dist==0)
					src<<"All this moving is exhausting..."
					break
				sleep(rushSpeed)
			if(succ)
				if(target in view(1))
					doAttack(target,20+dmg,1,null,"dropkicks",null,3)
				if(m_rf)
					doAttack(m_rf,20+dmg,1,null,"dropkicks",null,3)
			else
				stagger += 1
				src<<"You fell because you missed the enemy. You're stunned!"
				sleep(4)
				stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Falling_Kick() //attack, that on success grounds you and the opponent with extra damage.
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
					if(doAttack(target,null,null,null,"kicks",1))
						if(target.flight)
							AttackMultiple(target,4,null,null,"slams",1)
					else
						stagger += 1
						spawn(4) stagger -= 1
					target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Kickup() //if the person is grounded, staggers them.
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
					if(doAttack(target,3,1,null,"kicks upwards",null,3))
						sleep(2)
				target.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."