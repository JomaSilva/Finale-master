mob/var
	currentNutrition = 50 //This is the stored food value- points from here are slowly transferred into stamina depending on the user variables.
	Metabolism = 1 //How fast the above transfers into stamina, also effects your drain.
	Hunger //Whether or not the user is hungry- hits 1 when stamina hits 25% or 1 when currentNutrition hits 0. Some kind of fat-system for over-eaters is planned.
	maxNutrition = 50
	partplant = 0
	StamBPGainMod = 1//how much your gains are affected by stamina

mob/var/tmp
	NutritionFilled
	HungerMessage

mob/proc/CheckNutrition()
	set waitfor = 0
	set background = 1
	if(client)//temp line for NPCs until NPC hunger/animals n shit is added.
		if(!Player)
			stamina = maxstamina
		if(stamina<(maxstamina/2)&&(Race=="Majin"||Race=="Bio-Android"))
			stamina=(maxstamina/2)
		if(stamina>maxstamina)
			stamina=maxstamina
		if(prob(1)&&prob(1)&&prob(1)&&!HungerMessage)
			Hunger=0
			HungerMessage=1
			spawn(1000)
				HungerMessage=0
		if(!dead&&Planet!="Sealed"&&z!=25)
			spawn((30*Metabolism))
				stamina-= (1.5*dashingMod*globalstamdrain*(Metabolism/2))/max(200*Ewillpower*concealedBuff*Estaminamod,0.01)
				if(IsInFight)
					stamina -= (((2*globalstamdrain*dashingMod)/max(150*Ewillpower*Estaminamod,0.01)))
		else if(Planet=="Sealed")
			stamina = maxstamina
		else if(dead)
			stamina = 0.5*maxstamina
		else
			stamina = 0
		if(immortal) stamina = max(maxstamina/2,stamina)
		if(stamina>0) staminadeBuff = min((101.047 - ((1.047^(maxstamina/stamina))*0.008*(maxstamina/stamina)/Estaminamod)),100)
		spawn CheckStomach()
		if(Senzu>4) Senzu=4
		if(prob(2)&&Senzu) Senzu-=1
		if(Senzu<0) Senzu=0
		if(partplant&&med&&!IsInFight&&prob(10))//nameks get nutrition from water.
			var/waterNearby
			for(var/turf/T in view(1))
				if(T.Water)
					waterNearby+=1
			if(currentNutrition<maxNutrition)
				currentNutrition+=waterNearby * (maxNutrition*0.01)
		if(eating&&!eat)
			eat=rand(1,3)*10
			spawn(eat/Metabolism)
				usr.eating=0
				usr.eat=0
				usr<<"You feel you can eat more food again."
		StamBPGainMod = min(max(stamina/(maxstamina*0.5),0.5),1.25)
		///*
		if(stamina/maxstamina < 0.05)
			stamina_sound_accum += 1
			if(prob(25) && stamina_sound_accum >= 100)
				stamina_sound_accum = 0
				emit_Sound_to('hunger.ogg',src)
		if(stamina<1&&!dead)
			if (currentNutrition>0)
				stamina = 1
			else
				SpreadDamage(abs(stamina) * stamina_accum)
				stamina_accum += stamina
				stamina_accum = min(stamina_accum,10)
				stamina = 0
				if(prob(Ewillpower) && prob(Ewillpower * 5))
					stamina += 2
				/*if(!KO)
					spawn usr.KO(-1)
					view()<<"[usr] is knocked out from hunger!!"
					spawn(300)
						if(stamina<=1)
							view()<<"[usr] died from starvation!!"
							stamina=maxstamina
							usr.Death()
						else
							usr.Un_KO()*///Trying rebalanced stamina with no death
		if(stamina<0)
			stamina=0
mob/var/tmp
	stamina_accum = 0
	stamina_sound_accum = 0
var/globalstamdrain = 1