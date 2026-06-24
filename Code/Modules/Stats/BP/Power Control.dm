mob/var/tmp
	goingssj4
	powerup=0
	powerdown=0
mob/var
	tmp/isconcealed=0
	tmp/canconceal=1
	FlashPoint=0
	icon/AURA='colorablebigaura.dmi'
	icon/ssj4aura = 'AuraNormal.dmi'
	Over = 1
	ki
	isrelaxed=0
	relaxedstate="Ready"
	DUpowerupon = 1
	powermovetimer = 0//decreases power control rate when you move

mob/proc/ClearPowerBuffs()
	overlaychanged=1

mob/proc/AuraCheck()
	if(src.kiratio>1.1 && FlashPoint == 0)
		FlashPoint = 1
		updateOverlay(/obj/overlay/auras/aura)
	else if(src.kiratio<=1 && FlashPoint==1) //without the if() statement, this would run every tick.
		FlashPoint = 0
		usr.overlayList-='snamek Elec.dmi'
		usr.overlayList-='SSj Aura.dmi'
		usr.overlayList-='Sparks LSSj.dmi'
		overlaychanged=1
		removeOverlay(/obj/overlay/auras/aura)

mob/default/verb/ReadyUp()
	set name="Toggle Readiness"
	set category="Skills"
	if(powerMod >= 1)
		src<<"You are relaxed."
		isrelaxed=1
		if(ispoweringdown)ispoweringdown=0
		ClearPowerBuffs()
		AuraCheck()
		powerMod=0.01
	else
		src<<"You are now ready."
		isrelaxed=0
		powerMod=1
mob/default/verb/Power_Revert()
	set name="Revert"
	set category="Skills"
	dblclk++
	spawn(4)
		if(Ki > MaxKi && dblclk==1)
			src<<"You shunt some extra energy."
			Ki -= (Ki/MaxKi) * 10 * (MaxKi/100)
			AuraCheck()
		else
			src<<"You revert forms."
			AuraCheck()
			spawn usr.Revert(2)
			spawn usr.revertIcer()
			spawn usr.ExpandRevert()
			emit_Sound('descend.wav')
		dblclk -= max(dblclk,0)

mob/keyable/verb/Conceal_Power()
	set category="Skills"
	if(canconceal)
		canconceal=0
		if(isconcealed)
			src<<"You are no longer hiding your power. It'll take a minute to conceal yourself again."
			isconcealed=0
			sleep(50)
			canconceal=1
		else
			src<<"You are now hiding your power. It'll take a minute to reveal yourself again."
			isconcealed=1
			sleep(50)
			canconceal=1
	else src<<"You can't do that yet."

mob/proc
	RelaxCheck()
		if(dblclk) spawn(10) dblclk=0
		if(isrelaxed)
			if(Anger>(((MaxAnger-100)/1.66)+100))
				src<<"You can't relax, you're just too angry!"
				src<<"You are now itching for a fight."
				powerMod=1
				isrelaxed=0
			if(!powerMod==0.01)
				isrelaxed=0
			if(relaxedstate!="Relaxed"&&!isconcealed)
				relaxedstate="Relaxed"
			if(relaxedstate!="Concealing Power"&&isconcealed)
				relaxedstate="Concealing Power"
		if(!isrelaxed)
			if(relaxedstate!="Using some power."&&powerMod<1)
				relaxedstate="Using some power."
			else if(isrelaxed&&powerMod>=0.01)
				isrelaxed=0
			else if(powerMod>=1&&relaxedstate!="Using Full Power")
				relaxedstate="Using Full Power"
				isrelaxed=0
			if(powerMod==0.01)
				isrelaxed=1
	CheckPowerMod()
		AuraCheck()
		if(powerMod > 1 && powerMod > kiratio)
			stamina-=((KIregen*staminapercent)/100)
			Ki+=(KIregen*25*staminapercent*powerMod)*(min(Ki/MaxKi,1))//makes it so dropping to low ki will actually make it harder to power back up
		if(Ki>MaxKi)
			if(Ki>(kicapacity*1.1) && !overcharge && prob(25))
				Ki-= (Ki * 0.04) / Ekiskill
				stamina -= 0.0025 * (maxstamina/100) / Ekiskill
				SpreadDamage(0.05 * kiratio / Ekiskill)
			else if(Ki>kicapacity  && !overcharge && prob(25))
				Ki-= (Ki * 0.005) / Ekiskill
				stamina -= 0.0012 * (maxstamina/100)
				SpreadDamage(0.01 * (kiratio/(kicapacity/MaxKi)))//propotion of your ki ratio to you ki capacity multiplier on your max ki, a measure of how "over" you are
			else if(Ki>MaxKi && prob(25))
				if(Ki<kicapacity) overcharge = 0
				Ki-= (Ki * 0.0001) / Ekiskill
				if(dead) Ki-= (Ki * 0.0001) / Ekiskill//double ki reduction if dead.
		else if(Ki<=MaxKi&&overcharge) overcharge=0
		if((kiratio>1&&!KO)) //Ki drain.
			if(baseKi<=baseKiMax) baseKi+=kicapcheck(0.005*BPrestriction*KiMod*powerMod)
		if(kiratio>1&&FuseTimer)
			FuseTimer-= (1 * kiratio) //If you're fused, powering up will fuck with it.

mob/var
	tmp/overcharge = 0 //whether or not the energy you have hurts you/decreases.
	canPower //whether or not you can charge your Ki
	tmp/extracharge = 0

mob/proc/Energy_Draw()
	if(!MeditateGivesKiRegen) return
	is_drawing = 1
	poweruprunning = 1
	if(canPower)
		if(Ki<MaxKi && !adding)
			Ki += (MaxKi / 90)
			stamina -= (maxstamina / 610)
			extracharge +=1
		else if(usr.powerMod < 1)
			if(powermovetimer) usr.powerMod += 0.0025 * (Ekiskill+(kicontrolskill+kigatheringskill)/10)
			else usr.powerMod += 0.01 * (Ekiskill+(kicontrolskill+kigatheringskill)/15)
			if(usr.powerMod > 1)
				usr.powerMod = 1
		else if(!adding && powerupcap >= kiratio)
			if(powermovetimer) Ki += (MaxKi / 200)*((Ekiskill+(kicontrolskill+kigatheringskill)/10)/3 / (3*kiratio))
			else
				if(prob(10) && Ki < 100000) spawn for(var/mob/M in range(screenx))
					M.Quake()
				else if(prob(10) && Ki > 100000) spawn for(var/mob/M in current_area.contents)
					M.Quake()
				Ki += (MaxKi / 100)*((Ekiskill+(kicontrolskill+kigatheringskill)/10)/2.5 / (3*kiratio))
			stamina -= (maxstamina / 590)
			extracharge += 1
		extracharge = min(extracharge,50)
	else
		if(Ki<MaxKi && !adding)
			Ki += (MaxKi / 150)
			stamina -= (maxstamina / 500)
			extracharge +=0.5
		extracharge = min(extracharge,50)

mob/keyable/verb/Power_Control()
	set category="Skills"
	var/numb = input(usr,"Set your percentage of power, from 1 to 100. You can only use this to set your power lower than it is. You can only power up by pressing C. This will slowly bring you down to that level. Cancel by powering up.") as num
	numb = min(numb,100)
	numb = max(1,numb)
	numb /= 100
	while(!is_drawing && usr.powerMod > numb && usr.powerMod > 0)
		usr.powerMod -= 0.01 * (Ekiskill+(kicontrolskill+kigatheringskill)/25)
		usr.powerMod = max(1,usr.powerMod)
	usr.powerMod = numb

mob/default/verb/Start_Draw_Energy()
	set hidden = 1
	Draw_Energy()

mob/var/tmp/dblclk = 0