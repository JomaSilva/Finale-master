mob/proc/deflectmessage() view(9)<<"[src] deflects the blast!"
mob/proc/reflectmessage() view(9)<<"<font color=red>[src] reflects the blast!"
mob/var
	paralyzed
	paralysistime=0
	hasForcefield
	obj/items/Forcefield/forcefieldID = null
#define KI_PLANE 6
obj/attack/
	Pow=50
	IsntAItem=1
	invisibility = 101
	move_delay = 0.1
	var
		element = "Energy"
		Homing_Tendency = 1
		maxdistance=30
		distance=30
		deflectMod= 1
		permKillbuff = 0
		inaccuracy=0
		kishock=0
		kiforceful=0
		kiinterfere=0
		linear=1//does the beam need to follow a straight line, or can the head be in any tile's direction?
		deflected = 0//is this a deflected blast? if so, delet it when it hits something
		homeTarget = null
obj/var
	Pow=1
	mods=1
	guided = 0
	homingchance=0//used to track chance of homing in on the target, set in the skill the blast came from
	ogdir=1
	//kbrange=8//how close to the user the target has to be for beams to knock back:obsolete
	selectzone
	physdamage=0//use physical damage calcs, defaults to ki damage
	avoidusr=0//does the attack damage the user, defaults to yes
	beamspeed=1
	rangemod = 1
	tmp
		proprietorloc = 0
		homingloc
		basedamage=1
		maxdamage=0
		stoopme = 0 //for explosion causers
obj
	move_delay = 0.2
obj/var/WaveAttack
mob/var/WaveIcon='Mutant Aaya.dmi'

var
	list/dir_matrix = list(matrix(0,-1,0,1,0,0),matrix(0,1,0,-1,0,0),null,matrix(1,0,0,0,1,0),
						   matrix(0.99999,-0.707107,0,0.99999,0.707107,0),matrix(0.99999,0.707107,0,-0.99999,0.707107,0),null,
						   matrix(-1,0,0,0,-1,0),matrix(-0.99999,-0.707107,0,0.99999,-0.707107,0),matrix(-0.99999,0.707107,0,-0.99999,-0.707107,0))

var/globalKiDamage = 2

obj/attack/var
	wavemultipl=1
	confirmback=0//is there a segment behind?
	confirmfront=0//is there another segment in front already?
	userbeaming=0//if this beam is directly next to the user, are they still beaming? if so, we should be a midsection and not a tail

obj/attack/blast
	plane = KI_PLANE
	var/scalefactor = 1

	proc/OnSucCollWMob(mob/M) //something for custom blasts to call when they need to do something unique to the mob if it hits.
		return

	New()
		..()
		icon_state="end"
		invisibility = 0
		spawn(2)
			if(src)
				if(WaveAttack)
					icon_state = "tail"
					KHH()
		spawn(1)
			if(src)
				var/icon/I = icon(icon)
				var/W = I.Width()
				var/H = I.Height()
				pixel_x=-((W/2)-16)
				pixel_y=-((H/2)-16)
				var/TD = sqrt(W**2 + H**2)
				scalefactor = TD / W
	Move()
		while((TimeStopped&&!CanMoveInFrozenTime) && src)
			sleep(1)
		if(!WaveAttack && !stoopme)
			. = ..()
			if(!.) //act like distance ran out and goo
				spawn explode()
				src.loc=null//move to null so the garbage collector can handle it when it has time
				obj_list-=src
				attack_list-=src
				return
		else if(distance&&src.loc && !stoopme)
			var/oldloc=src.loc
			var/hastail=0
			var/hasorigin=0
			if(homeTarget)
				var/testdir = get_dir(src,homeTarget)
				if(testdir == src.dir || testdir == turn(src.dir,-45) || testdir == turn(src.dir, 45))
					dir = testdir
			..()
			if(homeTarget) if(loc == GetTurf(homeTarget))
				explode()
				return
			if(loc!=oldloc && !stoopme)
				distance--
				for(var/obj/attack/M in get_step(src,get_opposite_dir(src)))
					if(M!=src)
						if(M.proprietor==proprietor&&M.WaveAttack)//if there's already a beam bit behind, no reason to make one
							hastail=1
				for(var/mob/M in get_step(src,get_opposite_dir(src)))
					if(M==proprietor&&M.beaming)
						hasorigin=1
				if(!hastail)
					var/obj/attack/blast/A=new/obj/attack/blast
					A.proprietorloc=src.proprietorloc
					A.icon=src.icon
					if(hasorigin)
						A.icon_state="origin"
					else
						A.icon_state="tail"
					A.animate_movement=1
					A.density=0
					A.BP=src.BP
					A.dir=src.dir
					A.mods=src.mods
					A.transform = transform
					A.element = element
					A.wavemultipl = wavemultipl
					A.basedamage = src.basedamage
					A.layer=src.layer
					A.murderToggle=src.murderToggle
					A.proprietor=src.proprietor
					A.ownkey=src.ownkey
					A.WaveAttack=1
					A.loc=oldloc
					A.piercer=src.piercer
					A.distance=src.distance
					A.homeTarget = homeTarget
					if(!linear)
						spawn A.Burnout(20)
		else
			if(stoopme) explode()
			src.loc=null//move to null so the garbage collector can handle it when it has time
			obj_list-=src
			attack_list-=src
			return

	Crossed(mob/M)
		if(istype(M,/mob))
			if(proprietor)
				proprietor.beamcounter+=2
			for(var/obj/attack/B in get_step(src,get_opposite_dir(src)))
				if(B!=src&&B.proprietor==proprietor&&B.WaveAttack)
					B.icon_state="head"
					B.plane=KI_PLANE
					B.density=1
					B.BP=proprietor.expressedBP
					B.mods=proprietor.beammods
					B.murderToggle=proprietor.murderToggle
					walk(B,B.dir,B.beamspeed)
			obj_list-=src
			attack_list-=src
			src.loc=null//removes the beam segment they cross
		if(istype(M,/obj/attack))
			var/obj/attack/R=M
			sleep(1)
			if(R.BP*R.mods*R.basedamage>BP*mods*basedamage)
				sleep(6-(mods*basedamage)/(R.mods*R.basedamage))
				obj_list-=src
				attack_list-=src
				src.loc=null
			else
				sleep(6-(R.mods*R.basedamage)/(mods*basedamage))
				obj_list-=R
				attack_list-=R
				R.loc=null
		else if(istype(M,/obj))
			var/obj/Q = M
			if(Q.fragile && !Q.density && prob(45))
				Q.takeDamage(BP)


	proc/KHH()
		//Beams
		while(src&&src.loc && !stoopme)
			sleep(2)
			CHECK_TICK
			//making the end of the trail look a certain way...
			//if(icon_state!="struggle") //new

			//calc beam homing
			/*if(prob(Homing_Tendency - (3-proprietor.kiskill) * 10))
				if(proprietor.target in view())
					if(get_dir(src,proprietor.target)==turn(dir,45)||get_dir(src,proprietor.target)==turn(dir,-45)||get_dir(src,proprietor.target)==dir)
						dir = get_dir(src,proprietor.target)*/
			//
			confirmback=0
			confirmfront=0
			var/hasorigin=0
			for(var/obj/attack/M in get_step(src,src.dir)) //shit needs to be fixed - only checks front and back now, and so we only care if there is a beam there that is ours
				if(M!=src)
					if(M.proprietor==proprietor&&M.WaveAttack)
						confirmfront=1
			for(var/obj/attack/M in get_step(src,get_opposite_dir(src)))
				if(M!=src)
					if(M.proprietor==proprietor&&M.WaveAttack&&M.dir==src.dir)
						confirmback=1
			for(var/mob/M in get_step(src,get_opposite_dir(src)))
				if(M==proprietor&&M.beaming&&M.dir==dir)
					confirmback=1
					hasorigin=1
			if(!confirmback&&confirmfront)
				plane=KI_PLANE
				if(icon_state!="end")
					icon_state="end"
				plane = AURA_LAYER
				density=0
				sleep(1+rand(1,3))
				obj_list-=src
				attack_list-=src
				src.loc=null//tails will automatically remove themselves one at a time until it's just the head, which should burn out on its own
			else if(!confirmfront)
				if(confirmback)
					if(icon_state!="head"&&icon_state!="struggle")
						icon_state="head"
					plane=KI_PLANE
					density=1
					if(proprietor && get_dist(src,proprietor) >= 1)
						proprietor.tmphead = src
					//BP=proprietor.expressedBP
					mods=proprietor.beammods*(rangemod**(maxdistance-distance))
					murderToggle=proprietor.murderToggle//so the damage and lethality can change as the user's stats change
					walk(src,src.dir,beamspeed)//we want each beam object to decide if it should move, while the rest stay where they are
				else
					obj_list-=src
					attack_list-=src
					src.loc=null
			else if(hasorigin)
				plane=KI_PLANE
				if(icon_state!="origin")
					icon_state="origin"
				density=0
			else
				plane=KI_PLANE
				if(icon_state!="tail")
					icon_state="tail"
				density=0
			/*if(!linear && !confirmfront)
				if(confirmback)
					if(icon_state!="head"&&icon_state!="struggle")
						icon_state="head"
					plane=KI_PLANE
					density=1
					BP=proprietor.expressedBP
					mods=proprietor.beammods*(rangemod**(maxdistance-distance))
					murderToggle=proprietor.murderToggle//so the damage and lethality can change as the user's stats change
					walk(src,src.dir,beamspeed)//we want each beam object to decide if it should move, while the rest stay where they are
				else
					obj_list-=src
					attack_list-=src
					src.loc=null*/
	Bump(mob/M)
		if(M!=proprietor||!avoidusr)
			if(!WindmillShuriken)
				if(WaveAttack)
					icon_state="struggle"
				var/explodeme
				if(istype(M,/mob))
					for(var/obj/attack/blast/Z in view(1,src)) if(guided&&Z.guided)
						if(Z!=src)
							obj_list-=Z
							attack_list-=Z
							Z.loc=null
					if(M.attackable)
						if(M.isNPC&&!M.KO)
							if(proprietor)
								proprietor.Blast_Gain(3,1)//blast gain was nerfed, but here if you're hitting someone, you get yo gains back.
							var/mob/npc/mN = M
							if(mN.monster && !mN.AIRunning)
								mN.foundTarget(proprietor)
						else if(proprietor&&!M.KO)
							M.kidefensecounter++
							proprietor.Blast_Gain(5,1)
							proprietor.Leech(M)
							if(WaveAttack)
								proprietor.beamcounter+=3
							else
								proprietor.blastcounter+=3
						var/dmg
						if(!physdamage)
							dmg=DamageCalc(mods*6*globalKiDamage,(M.Ekidef**2*max(M.Etechnique,M.Ekiskill)),basedamage,maxdamage)
						else
							element = "Physical"
							dmg=DamageCalc(mods*6*globalmeleeattackdamage,(M.Ephysdef**2*max(M.Etechnique,M.Ekiskill)),basedamage,maxdamage)
						if(dmg==0)dmg+=basedamage*0.02
						dmg = ArmorCalc(dmg,M.Esuperkiarmor,FALSE)
						M.damage_armor(dmg)
						dmg /= log(4,max(M.kidefenseskill,4))
						var/deflectchance
						if(!physdamage)
							deflectchance=((M.Ekidef*max(M.expressedBP,1)*max(M.Ekiskill,M.Etechnique)*max(M.kidefenseskill/10,1))/(BP*mods*basedamage)) //kiskill does impact deflection
						else
							deflectchance=((M.Ephysdef*max(M.expressedBP,1)*max(M.Ekiskill,M.Etechnique))/max(BP*mods*basedamage,0.01))
						if(!deflectable) deflectchance=0
						if(M.shielding&&!mega)deflectchance=max((deflectchance*2),5)
						if(M.shielding&&dmg)M.shieldexpense=dmg
						if(M.blocking)
							dmg /= 2 * log(4,max(M.kidefenseskill,4))
							deflectchance *= 2
						if(M.KO||M.stagger) deflectchance=0
						if(paralysis)
							M.paralyzed=1
							if(!M.paralysistime) M.paralysistime=min(max(5,(M.Ekidef*max(M.Etechnique,M.Ekiskill)*BPModulus(BP,M.expressedBP))),10)
							M<<"<font color=Purple>You have been paralyzed! ([M.paralysistime] seconds)"
							if(paralysis==2&&!M.KO&&!M.hasForcefield)
								if(M.HP<=15/(BP/((M.Ekidef*max(M.expressedBP,1)*max(M.Ekiskill,M.Etechnique))*10))||M.expressedBP<100&&M.Ekidef<3)
									spawn M.KO()
									view(M)<<"<font color=Purple>[M] has been stunned!"
						if(M.ResistCheck(dmg,"[element]")*BPModulus(BP,M.expressedBP) < 10)
							explodeme = 1
							stoopme = 1
						else if(prob(deflectchance/2)&&M.Ki>=5&&M.DRenabled)
							M.kidefensecounter+=4
							M.dir=dir
							M.dir=pick(turn(M.dir,135),turn(M.dir,-135))
							step(M,M.dir)
							return 1
						else if(prob(deflectchance)&&M.Ki>=5&&M.DRenabled)
							M.kidefensecounter++
							if((M.Race=="Android"&&proprietor!=M||M.Race=="Cyborg"&&proprietor!=M)&&!physdamage)
								view(M)<<"[M] absorbs the blast!"
								M.Ki+=100
								obj_list-=src
								attack_list-=src
								src.loc=null
							else if(prob(20))
								M.Ki-=5*M.BaseDrain
								view(M)<<"[M] reflects the blast!"
								density=1
								if(!WaveAttack)
									var/obj/attack/A = Copy_Blast()
									walk(A,M.dir)
									obj_list-=src
									attack_list-=src
									src.loc=null
								else
									if(proprietor)
										proprietor.beaming = 0
										proprietor.bypass=0
										proprietor.beamprocrunning=0
										proprietor.beamisrunning=0
										proprietor.beamturndelay=0
										proprietor.turnlock=0
										proprietor.stopbeaming()
									walk(src,M.dir,beamspeed)
							//	if(M.zanzoskill>=100&&proprietor) for(var/mob/Z in view(M))
							//		if(Z.name==proprietor)
							//			spawn flick('Zanzoken.dmi',M)
							//			if(Z.dir==NORTH|Z.dir==NORTHEAST) M.loc=locate(Z.x,Z.y-1,Z.z)
							//			if(Z.dir==SOUTH|Z.dir==NORTHWEST) M.loc=locate(Z.x,Z.y+1,Z.z)
							//			if(Z.dir==EAST|Z.dir==SOUTHEAST) M.loc=locate(Z.x-1,Z.y,Z.z)
							//			if(Z.dir==WEST|Z.dir==SOUTHWEST) M.loc=locate(Z.x+1,Z.y,Z.z)
							//			M.dir=Z.dir
							else
								M.Ki-=5*M.BaseDrain
								view(M)<<"[M] deflects the blast!"
								density=1
								if(!WaveAttack)
									var/obj/attack/A = Copy_Blast()
									walk(A,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,NORTHWEST))
									obj_list-=src
									attack_list-=src
									src.loc=null
								else
									walk(src,pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,NORTHWEST),beamspeed)
								//if(M.zanzoskill>=100&&proprietor) for(var/mob/Z in view(M))
								//	if(Z.name==proprietor)
								//		spawn flick('Zanzoken.dmi',M)
								//		if(Z.dir==NORTH|Z.dir==NORTHEAST) M.loc=locate(Z.x,Z.y-1,Z.z)
								//		if(Z.dir==SOUTH|Z.dir==NORTHWEST) M.loc=locate(Z.x,Z.y+1,Z.z)
								//		if(Z.dir==EAST|Z.dir==SOUTHEAST) M.loc=locate(Z.x-1,Z.y,Z.z)
								//		if(Z.dir==WEST|Z.dir==SOUTHWEST) M.loc=locate(Z.x+1,Z.y,Z.z)
								//		M.dir=Z.dir
						else //new
							if(M.hasForcefield&&isobj(M.forcefieldID))
								spawn M.updateOverlay(/obj/overlay/effects/flickeffects/forcefield)
								M.forcefieldID.takeDamage(dmg*BPModulus(BP))
							else if(M.hasForcefield)
								spawn M.updateOverlay(/obj/overlay/effects/flickeffects/forcefield)
								for(var/obj/Modules/Forcefield_Generator/F in M)
									if(F.isequipped&&F.functional&&F.elec_energy>=100)
										F.elec_energy-=100
										F.integrity-=(dmg*BPModulus(BP,M.expressedBP))
							else if(M.blastabsorb&&get_dir(M,src)==M.dir)
								spawn M.updateOverlay(/obj/overlay/effects/flickeffects/forcefield)
								for(var/obj/Modules/Energy_Capacitor/G in M)
									if(G.isequipped&&G.functional)
										G.integrity-=(dmg*BPModulus(BP,M.expressedBP)/10)
								M.Ki+=(dmg*BPModulus(BP,M.expressedBP)*10)
								//if(M.Ki>M.MaxKi) already handled in Power Control.dm
									//M.SpreadDamage(M.Ki/M.MaxKi)
							else
								M.DamageLimb(M.ResistCheck(dmg,"[element]")*BPModulus(BP,M.expressedBP),selectzone,murderToggle,5)
								OnSucCollWMob(M)
								M.Add_Anger()
								if(kishock)
									spawn KiShock(M,dmg*BPModulus(BP,M.expressedBP))
								if(kiinterfere)
									spawn Interfere(M,dmg*BPModulus(BP,M.expressedBP))
								if(prob(5)&& dmg>2 && M.Tail &&proprietor.murderToggle&&M.dir==dir)
									view(M)<<"[proprietor] blasts [M]'s tail off!"
									M<<"[proprietor] blasts your tail off!"
									M.Lop_Tail()
								if(WaveAttack)
									if(maxdistance-distance<=2&&dmg*BPModulus(BP,M.expressedBP)>0.25&&!M.KB)//if the target is sufficiently strong, they should be able to walk through beams
										var/kbstr = round(dmg*BPModulus(BP,M.expressedBP),1)
										spawn Knockback(M,kbstr)
									else if(maxdistance-distance<=4&&dmg*BPModulus(BP,M.expressedBP)>0.5&&!M.KB)//harder to knock back at range
										var/kbstr = round(0.5*dmg*BPModulus(BP,M.expressedBP),1)
										spawn Knockback(M,kbstr)
									spawn(1) MiniStun(M)
								else if(kiforceful&&dmg*BPModulus(BP,M.expressedBP)>0.5&&!M.KB&&get_dist(proprietor,M)<=5&&proprietor.knockback)
									var/kbstr = round(0.75*dmg*BPModulus(BP,M.expressedBP),1)
									spawn Knockback(M,kbstr)
								if(M.KO&&M.HP<=5)
									if(M.Player)
										if(!M.KO) M<<"You have been defeated by [proprietor]'s blast!"
										if(!locate(/obj/Crater/destroyed) in range(3)) createCrater(loc,1)
										if(murderToggle|piercer)
											if(proprietor!=usr)
												view(M)<<"[M] was killed by [proprietor]([ownkey])!"
												if(M.DeathRegen)
													M.buudead = BP/M.peakexBP
												if(piercer) M.buudead=0
												spawn if(!M.KO) M.KO()
												if(proprietor) proprietor.MurderTheFollowing(M)
											else M.KO()
										else M.KO()
									if(M.monster)
										view(M)<<"[M] was killed by [proprietor]([ownkey])!"
										if(BP>=500) if(!locate(/obj/Crater/destroyed) in range(3)) createCrater(loc,1)
										M.mobDeath()
							if(piercer)
								density=0
								spawn(1) density=1
							if(mega) createCrater(loc,3)
							if(shockwave)
								var/kbdist=round(5+(M.Ekiskill/2))
								if(kbdist>20) kbdist=20
								M.dir=turn(dir,180)
								while(kbdist)
									var/turf/Z = locate(/turf) in get_step(M,M.dir)
									if(isturf(Z) && Z.Resistance<=BP && prob(15))
										createDust(Z,1)
										Z.Destroy()
									if(BP>100000 && prob(25))
										if(isturf(Z) && BP>(Z.Resistance))
											createDust(Z,2)
											Z.Destroy()
									if(BP>1000000 && prob(15))
										for(var/turf/T in view(1,M))
											if(BP>(T.Resistance) && prob(40))
												createDust(T,1)
												T.Destroy()
									step_away(M,src)
									sleep(1)
									kbdist-=1
				else if(istype(M,/obj/attack))
					if((M.dir!=dir&&M.proprietor!=proprietor)||deflected) //New line...: && keps you from destroying your own blasts
						var/obj/attack/R=M//typecasting so the compiler knows the blast/beam has these variables
						var/sfirsttime=0
						strugglestart
						if(!R||!R.loc||!src||!src.loc)
							return
						if(proprietor&&src.loc&&R.loc)
							proprietor.Blast_Gain(0.5)
							if(WaveAttack)
								proprietor.beamcounter+=1
							else
								proprietor.blastcounter+=1
						var/beam_strg_mod = BPModulus(BP*mods*basedamage,R.BP*R.mods*R.basedamage) + sfirsttime
						if(WaveAttack)
							icon_state="struggle"
							if(beam_strg_mod > 20 || (sfirsttime==0 && beam_strg_mod > 3))
								obj_list-=R
								attack_list-=R
								R.loc=null
								return 1
							else if(beam_strg_mod < -15 || (sfirsttime==0 && beam_strg_mod > 3))
								obj_list-=src
								attack_list-=src
								src.loc=null
							else
								sleep(2)
								sfirsttime++
								goto strugglestart

						else
							if(beam_strg_mod > 1.3)
								obj_list-=R
								attack_list-=R
								R.loc=null
								return 1
							else if(beam_strg_mod < 0.7)
								obj_list-=src
								attack_list-=src
								src.loc=null
							else
								obj_list-=src
								attack_list-=src
								src.loc=null
								obj_list-=R
								attack_list-=R
								R.loc=null
					else
						return
				else if(istype(M,/turf))
					var/turf/L=M
					if(L.density) explodeme = 1
					else if(isturf(L) && L.Resistance<=BP && prob(65))
						stoopme = 1
				else if(istype(M,/obj))
					var/obj/Q = M
					if(Q.fragile || Q.density) explodeme = 1
				if(!WaveAttack)
					if(explodeme) explode()
			//Windmill Shurikens...
			else
				if(istype(M,/mob))
					if(M.attackable)
						if(proprietor) proprietor.blastcounter+=2
						var/dmg=DamageCalc(mods*globalKiDamage,(M.Ekidef*max(M.Etechnique,M.Emagiskill)),basedamage,maxdamage)
						if(dmg==0)dmg+=basedamage*0.05
						if(M.shielding&&dmg)M.shieldexpense=dmg/3
						damage_m(M,dmg,selectzone,murderToggle,3)
						if(M.HP<=5&&M.KO)
							if(M.Player) M.KO()
							else
								view(M)<<"[M] was killed by [proprietor]([ownkey])!"
								M.mobDeath()
				var/sdir=rand(1,8)
				if(sdir==1) walk(src,NORTH)
				if(sdir==2) walk(src,SOUTH)
				if(sdir==3) walk(src,EAST)
				if(sdir==4) walk(src,WEST)
				if(sdir==5) walk(src,NORTHEAST)
				if(sdir==6) walk(src,NORTHWEST)
				if(sdir==7) walk(src,SOUTHEAST)
				if(sdir==8) walk(src,SOUTHWEST)
		..()
obj/proc
	blasthoming(var/mob/M)
		set waitfor = 0
		if(!M)
			return
		while(src&&src.loc)
			sleep(4)
			if(M in oview(5,src))
				if(prob(homingchance))
					step_towards(src,M)
			sleep(4)
	/*Beam_Walk()
		set waitfor = 0
		if(!src)
			return
		while(src&&src.loc)*/

obj/proc/spawnspread()
	set waitfor = 0
	spawn
		sleep(4)
		switch(dir)
			if(NORTH)
				step(src, pick(NORTHWEST,NORTH,NORTHEAST))
			if(NORTHEAST)
				step(src, pick(NORTH,NORTHEAST,EAST))
			if(EAST)
				step(src, pick(NORTHEAST,EAST,SOUTHEAST))
			if(SOUTHEAST)
				step(src, pick(EAST,SOUTHEAST,SOUTH))
			if(SOUTH)
				step(src, pick(SOUTHEAST,SOUTH,SOUTHWEST))
			if(SOUTHWEST)
				step(src, pick(SOUTH,SOUTHWEST,WEST))
			if(WEST)
				step(src, pick(SOUTHWEST,WEST,NORTHWEST))
			if(NORTHWEST)
				step(src, pick(WEST,NORTHWEST,NORTH))
		if(ogdir)
			step(src,ogdir)

obj/proc/spreadbehind()
	set waitfor = 0
	switch(dir)
		if(NORTH)
			step(src, pick(SOUTHEAST,SOUTH,SOUTHWEST))
		if(NORTHEAST)
			step(src, pick(SOUTH,SOUTHWEST,WEST))
		if(EAST)
			step(src, pick(SOUTHWEST,WEST,NORTHWEST))
		if(SOUTHEAST)
			step(src, pick(WEST,NORTHWEST,NORTH))
		if(SOUTH)
			step(src, pick(NORTHWEST,NORTH,NORTHEAST))
		if(SOUTHWEST)
			step(src, pick(NORTH,NORTHEAST,EAST))
		if(WEST)
			step(src, pick(NORTHEAST,EAST,SOUTHEAST))
		if(NORTHWEST)
			step(src, pick(EAST,SOUTHEAST,SOUTH))

obj/attack/proc/Burnout(var/burnouttime)
	set waitfor=0
	set background=1
	if(!burnouttime) burnouttime=50
	while(burnouttime>=1 && src)
		sleep(1)
		while(!TimeStopped&&!CanMoveInFrozenTime) sleep(1)
		burnouttime--
	if(src)
		explode()

obj/attack/blast/proc/Knockback(var/mob/M,strength)//strength is the number of steps back to take
	M.kbpow=(mods*BP/1.5)
	M.kbdur=min(strength,10)//10 tile knockback maximum seems fine
	M.kbdir=src.dir
	M.AddEffect(/effect/knockback)

obj/attack/blast/proc/MiniStun(var/mob/M)
	if(M.expressedBP*M.Ekidef*M.Ekiskill<BP*mods*globalKiDamage*basedamage)
		M.AddEffect(/effect/ministun)
obj/attack/blast/proc/BlastControl(walk)//proc for adding random movement to blasts, based on blast skill and ki control
	var/firstdir = src.dir
	if(inaccuracy<=0)
		return//blasts have perfect accuracy, no need to run the loop
	while(src&&src.loc)
		sleep(2)
		if(prob(inaccuracy))
			var/wobble=pick(turn(src.dir,45),turn(src.dir,-45))
			walk(src,wobble)
		sleep(1)
		if(!walk)
			walk(src,firstdir)
		else
			walk(src,0)
mob/var/tmp
	kishocked=0
	kiinterfered=0

obj/attack/blast/proc/KiShock(var/mob/M,dmg)
	if(M.kishocked||dmg<=1)
		return
	var/timer=max(round(mods,1),40)
	M.kishocked=1
	spawn M.updateOverlay(/obj/overlay/effects/kishockaura)
	while(timer && M)
		if(proprietor.murderToggle)
			M.SpreadDamage(0.1*dmg)
		else
			M.SpreadDamage(0.1*dmg,0)
		timer--
		sleep(2)
	spawn M.removeOverlay(/obj/overlay/effects/kishockaura)
	M.kishocked=0

obj/attack/blast/proc/Interfere(var/mob/M,dmg)
	if(M.kiinterfered||dmg<=1)
		return
	var/timer=max(round(mods,1),40)
	M.kiinterfered=1
	spawn M.updateOverlay(/obj/overlay/effects/interfereaura)
	dmg=min(dmg,20)
	M.DrainMod*=dmg
	while(timer)
		timer--
		sleep(10)
	spawn M.removeOverlay(/obj/overlay/effects/interfereaura)
	M.DrainMod/=dmg
	M.kiinterfered=0