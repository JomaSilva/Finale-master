mob/var
	DeathRegen = 0
	DeathRegenTmp = 0
	deathregenx = 0
	deathregeny = 0
	deathregenz = 0
	deathregening=0

	deathregentimer=0

mob/proc/TestDeathRegen() //true if dead, false if not dead.
	if(Race=="Android")
		var/obj/A
		for(var/obj/Super_Computer/S in obj_list)
			if(S.controller == signature&&S.resurrection)
				A = S
				overlayList-='Halo.dmi'
				overlaychanged=1
				if(zenkaiStore)
					zenkaiStore /= 5
				src<<"<font color=red>Your memories have been saved and implanted into a new body. Your old body was terminated or reached expiration."
				ReviveMe()
				WriteToLog("rplog","[src] was rebuilt. ([time2text(world.realtime,"Day DD hh:mm")])")
				loc = locate(A.x,A.y,A.z)
				return FALSE
	var/obj/CC
	for(var/obj/Core_Computer/S in obj_list)
		if(client && ((isnull(S.controller)&&prob(1)&&prob(10)&&!S.didRandRes)||S.controller == signature)&&S.resurrection&&!istype(src,/mob/lobby))
			CC = S
			S.didRandRes = 1
			overlayList-='Halo.dmi'
			overlaychanged=1
			if(zenkaiStore)
				zenkaiStore /= 5
			src<<"<font color=red>[CC]: Your memories have been saved and implanted into a new body. Your old body was terminated or reached expiration."
			ReviveMe()
			S.controller = signature
			WriteToLog("rplog","[src] was rebuilt. ([time2text(world.realtime,"Day DD hh:mm")])")
			loc = locate(CC.x,CC.y,CC.z)
			return FALSE
	if(DeathRegenTmp)
		if(DeathRegenTmp>=0.5)
			DeathRegenTmp-=0.1
			deathregening=1
		else
			DeathRegenTmp = 0
			return TRUE
		if(reconstructable)
			for(var/obj/Modules/Reconstruction_Core/R in contents)
				R.canreconstruct=0
	if(!DeathRegen && !DeathRegenTmp)
		return TRUE
	if(buudead)
		if(buudead=="force")
			return TRUE
		if(immortal)
		else if(buudead>=DeathRegen)
			return TRUE
	SpreadHeal(100,1,0)
	deathregening=1
	if(zenkaiStore)
		zenkaiStore /= 5
	stamina = maxstamina
	var/xx=x
	deathregenx = xx
	var/yy=y
	deathregeny = yy
	var/zz=z
	deathregenz = zz
	stamina = maxstamina * 0.2
	loc=locate(100,100,25)
	if(alert(src,"You have the option of coming back through death regeneration. Would you like to do so? If you choose No, you will be sent to the afterlife.","","Yes","No")=="No") return TRUE
	for(var/datum/Body/B in body)
		if(B.lopped)
			B.RegrowLimb()
	if(ZenkaiMod) zenkaicount+=DeathRegen*5 //holy cow this is strong as shit
	if(DeathRegen>=10||immortal)
		icon_state=""
		var/amount=4
		var/obj/A=new/obj
		var/obj/B=new/obj
		var/obj/C=new/obj
		var/obj/D1=new/obj
		var/obj/D2=new/obj
		var/obj/D3=new/obj
		var/obj/D4=new/obj
		while(amount)
			amount-=1
			D1.icon='Body Parts.dmi'
			D1.icon_state="Limb"
			var/limbdir=rand(1,4)
			if(limbdir==1)A.dir=NORTH
			if(limbdir==2)A.dir=SOUTH
			if(limbdir==3)A.dir=WEST
			if(limbdir==4)A.dir=EAST
			D1.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
			D2.icon='Body Parts.dmi'
			D2.icon_state="Limb"
			limbdir=rand(1,4)
			if(limbdir==1)A.dir=NORTH
			if(limbdir==2)A.dir=SOUTH
			if(limbdir==3)A.dir=WEST
			if(limbdir==4)A.dir=EAST
			D2.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
			D3.icon='Body Parts.dmi'
			D3.icon_state="Limb"
			limbdir=rand(1,4)
			if(limbdir==1)A.dir=NORTH
			if(limbdir==2)A.dir=SOUTH
			if(limbdir==3)A.dir=WEST
			if(limbdir==4)A.dir=EAST
			D3.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
			D4.icon='Body Parts.dmi'
			D4.icon_state="Limb"
			limbdir=rand(1,4)
			if(limbdir==1)A.dir=NORTH
			if(limbdir==2)A.dir=SOUTH
			if(limbdir==3)A.dir=WEST
			if(limbdir==4)A.dir=EAST
			D4.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
			if(amount==1)
				A.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
				B.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
				C.loc=locate(x+rand(-3,3),y+rand(-3,3),z)
				A.icon='Body Parts.dmi'
				A.icon_state="Head"
				B.icon='Body Parts.dmi'
				B.icon_state="Torso"
				C.icon='Body Parts.dmi'
				C.icon_state="Guts"
		src<<"You will regenerate in 10 seconds."
		WriteToLog("rplog","[src] will regenerate in 10 seconds    ([time2text(world.realtime,"Day DD hh:mm")])")
		deathregentimer=100
		sleep(100)
		deathregentimer=0
		spawn walk_towards(A,src,2)
		spawn walk_towards(B,src,2)
		spawn walk_towards(C,src,2)
		spawn walk_towards(D1,src,2)
		spawn walk_towards(D2,src,2)
		spawn walk_towards(D3,src,2)
		spawn walk_towards(D4,src,2)
		spawn(10)
			del(A)
			del(B)
			del(C)
			del(D1)
			del(D2)
			del(D3)
			del(D4)
		loc=locate(rand(xx+1,xx-1),rand(yy+1,xx-1),zz)
		deathregening=0
		return FALSE
	else if(DeathRegen>=6)
		//Begin the regeneration cycle.
		var/amount=5
		while(amount)
			sleep(1)
			amount-=1
			var/obj/A=new/obj
			A.icon='Majin1.dmi'
			A.icon_state="chunk1"
			A.loc=locate(x+rand(-5,5),y+rand(-5,5),z)
		src<<"You will regenerate in 30 seconds."
		WriteToLog("rplog","[src] will regenerate in 30 seconds    ([time2text(world.realtime,"Day DD hh:mm")])")
		deathregentimer=300
		sleep(300)
		loc=locate(rand(xx+1,xx-1),rand(yy+1,xx-1),zz)
		for(var/obj/A in view(src)) if(A.icon=='Majin1.dmi')
			spawn walk_towards(A,src,2)
			spawn(100) del(A)
		sleep(100)
		icon_state=""
		deathregening=0
		return FALSE //End the cycle and do not continue
	else if(DeathRegen>=4)
		loc=locate(250,250,25)
		src<<"You will regenerate in 1 minutes."
		WriteToLog("rplog","[src] will regenerate in 1 minute    ([time2text(world.realtime,"Day DD hh:mm")])")
		deathregentimer=600
		sleep(600)
		loc=locate(rand(xx+1,xx-1),rand(yy+1,xx-1),zz)
		deathregening=0 //
		return FALSE
	else if(DeathRegen>=2)
		src<<"You will regenerate in 2 minutes."
		WriteToLog("rplog","[src] will regenerate in 2 minutes    ([time2text(world.realtime,"Day DD hh:mm")])")
		deathregentimer=1200
		sleep(1200)
		loc=locate(rand(xx+1,xx-1),rand(yy+1,xx-1),zz)
		deathregening=0 //
		return FALSE
	else if(DeathRegen)
		src<<"You will regenerate in 4 minutes."
		WriteToLog("rplog","[src] will regenerate in 4 minutes    ([time2text(world.realtime,"Day DD hh:mm")])")
		deathregentimer=2400
		sleep(2400)
		loc=locate(rand(xx+1,xx-1),rand(yy+1,xx-1),zz)
		deathregening=0 //
		return FALSE