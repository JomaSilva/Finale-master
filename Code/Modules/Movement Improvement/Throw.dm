mob/OnStep()
	spawn
		if(grabMode==1)
			if(grabbee)
				usr<<"You throw [grabbee]"
				oview(usr)<<"[usr] throws [grabbee]!!"
				grabbee.grabberSTR=null
				grabbee.grabber = null
				var/testback=( (Ephysoff*((rand(3,(5*BPModulus(expressedBP,grabbee.expressedBP)))/1.8))) / max(((grabbee.Ephysdef*grabbee.Etechnique)/2),0.1) ) //use a similar equation to the KB equation found in attack.dm
				testback = round(testback,1)
				testback = min(testback,15)
				attacking=0
				//canfight=1
				grabbee.kbpow = (expressedBP/2)*Ephysoff*Etechnique
				grabbee.kbdir = dir
				grabbee.kbdur = testback
				grabbee.AddEffect(/effect/knockback)
				var/base=Ephysoff
				var/phystechcalc
				var/opponentphystechcalc
				if(Ephysoff>1||Etechnique>1)
					phystechcalc = Ephysoff+Etechnique
				if(grabbee.Ephysoff>1||grabbee.Etechnique>1)
					opponentphystechcalc = grabbee.Ephysoff+grabbee.Etechnique
				var/dmg = DamageCalc((phystechcalc),(opponentphystechcalc),base)
				damage_mob(grabbee,dmg*BPModulus(expressedBP,grabbee.expressedBP)/4)
				grabbee.attacking=0
				grabMode = 0
				sleep(10)
				grabMode=0
				attacking=0
				//canfight=1
				grabbee=null
			if(objgrabbee)
				usr<<"You throw [objgrabbee]"
				oview(usr)<<"[usr] throws [objgrabbee]!!"
				var/testback=(rand(2,(log(expressedBP)**3)))
				testback = min(testback,20)
				testback = round(testback,1)
				objgrabbee.ThrowStrength = (expressedBP/2)*Ephysoff*Etechnique
				attacking=0
				//canfight=1
				objgrabbee.ThrowMe(dir,testback)
				grabMode=0
				attacking=0
				//canfight=1
				objgrabbee=null
				sleep(10)
				grabMode=0
				attacking=0
				//canfight=1
				objgrabbee=null
		else if(grabMode==2)
			if(grabbee&&grabbee.isNPC && prob(15))
				var/escapechance=(grabbee.Ephysoff*grabbee.expressedBP*10)/grabbee.grabberSTR
				if(grabbee.isBoss) escapechance *= 2
				if(prob(escapechance))
					view(src)<<output("<font color=#990000>[grabbee] breaks free of [src]'s hold!","Chat")
					grabbee.attacking=0
					//grabbee.canfight=1
					attacking=0
					canfight=1
					grabbee.grabberSTR=null
					grabbee.grabber = null
					grabbee.grabParalysis = 0
					grabbee=null
				else view(src)<<output("<font color=#FFFFFF>[grabbee] struggles against [src]'s hold!","Chat")
	..()

atom/movable/proc/ThrowMe(var/srcDir,var/distance)
	set waitfor = 0
	if(IsBeingThrown) return
	IsBeingThrown = 1
	ThrowDistLeft = distance
	o_emit_Sound('throw.ogg',0.3)
	ThrowOldLoc = locate(src.x,src.y,src.z)
	var/testbackwaslarge
	if(ThrowDistLeft>=5)
		testbackwaslarge = 1
	spawn
		if(ismob(src))
			emit_Sound_to('throw.ogg',src,0.3)
			src:KB=1
			src:KBParalysis = 1
			spawn(100) src:KBParalysis = 0
			for(var/iconstates in icon_states(icon))
				if(iconstates == "KB")
					icon_state = "KB"
			while(ThrowDistLeft>0&&src&&IsBeingThrown)
				while(TimeStopped&&!CanMoveInFrozenTime)
					sleep(1)
				for(var/turf/T in oview(1,src))
					if(get_dir(src,T) == srcDir && T.density)
						if(T.Resistance <= ThrowStrength && T.destroyable) T.Destroy()
						else
							ThrowDistLeft=0
							src:icon_state=""
						break
				for(var/atom/movable/T in oview(1,src))
					if(get_dir(src,T) == srcDir)
						if(T.density)
							ThrowStrength = ThrowStrength / 4
							if(ismob(T))
								IsBeingThrown=0
								T:ThrowStrength = ThrowStrength
								T:SpreadDamage(1*BPModulus(ThrowStrength,T:expressedBP))
								spawn T:ThrowMe(ThrowDir,ThrowDistLeft+1)
							if(isobj(T))
								T:ThrowStrength = ThrowStrength
								spawn T:ThrowMe(ThrowDir,ThrowDistLeft)
							ThrowDistLeft = 0
							break
				if(ThrowDistLeft>0&&!isStepping)
					step(src,srcDir,10)
					ThrowDistLeft-=1
					if(ThrowStrength > 600)
						var/obj/impactditch/ic = new(loc)
						ic.dir = srcDir
				sleep(1)
			if(src:target)
				src.dir = get_dir(src.loc,src:target.loc)
			src:KB=0
			src:KBParalysis = 0
			if(!src:KO)
				src:icon_state=""
			else if(src:KO)
				src:icon_state = "KO"
		else if(isobj(src))
			while(ThrowDistLeft>0&&src)
				while(TimeStopped&&!CanMoveInFrozenTime)
					sleep(1)
				for(var/turf/T in oview(1))
					if(get_dir(src,T) == srcDir)
						if(T.Resistance <= ThrowStrength && T.destroyable)
							createDust(T,1)
							emit_Sound('kiplosion.wav')
							T.Destroy()
						else
							ThrowDistLeft=0
							src:icon_state=""
						break
				for(var/atom/movable/T in oview(1))
					if(get_dir(src,T) == srcDir)
						if(T.density)
							ThrowStrength = ThrowStrength / 4
							if(ismob(T))
								IsBeingThrown=0
								T:ThrowStrength = ThrowStrength
								T:SpreadDamage(1*BPModulus(ThrowStrength,T:expressedBP))
								spawn T:ThrowMe(ThrowDir,ThrowDistLeft+1)
							if(isobj(T))
								T:ThrowStrength = ThrowStrength
								spawn T:ThrowMe(ThrowDir,ThrowDistLeft)
							ThrowDistLeft = 0
							break
				if(ThrowDistLeft>0&&!isStepping)
					step(src,srcDir,10)
					ThrowDistLeft-=1
					if(ThrowStrength > 600)
						var/obj/impactditch/ic = new(loc)
						ic.dir = srcDir
				sleep(1)
		if(testbackwaslarge)
			emit_Sound('landharder.ogg')
			var/obj/Crater/impactcrater/ic = new()
			ic.loc = locate(src.x,src.y,src.z)
			ic.dir = get_dir(ic.loc,ThrowOldLoc)
			spawn for(var/turf/T in oview(1,src))
				CHECK_TICK
				if(!istype(T,/turf/Other/Stars))
					if(ThrowStrength>=T.Resistance)
						createDust(T,1)
						emit_Sound('kiplosion.wav')
						T.Destroy()
		ThrowStrength = null
		ThrowDir = null
		ThrowOldLoc = null
		IsBeingThrown = null
	return 1 //returns 1 immediately.

atom/movable/var/tmp/ThrowStrength
atom/movable/var/tmp/ThrowDistLeft
atom/movable/var/tmp/ThrowDir
atom/movable/var/tmp/ThrowOldLoc
atom/movable/var/tmp/IsBeingThrown
/*
atom/movable/Bump(atom/Obstacle)
	if(ThrowStrength)
		if(!(isturf(Obstacle)))
			ThrowStrength = ThrowStrength / 2
			if(ismob(Obstacle))
				Obstacle:ThrowMe(ThrowDir,ThrowDistLeft)
				Obstacle:ThrowStrength = ThrowStrength
				Obstacle:SpreadDamage(10*BPModulus(ThrowStrength,Obstacle:expressedBP))
			if(isobj(Obstacle))
				Obstacle:ThrowMe(ThrowDir,ThrowDistLeft)
				Obstacle:ThrowStrength = ThrowStrength
			ThrowMe(ThrowDir,ThrowDistLeft)
	..()
*/