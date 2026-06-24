mob/var
	baseKi=100
	KiMod=1
	kiAmp=1
	KiUnlockPercent = 0.1
	tmp
		baseKiMax=100
		MaxKi=1

mob/proc/updateMaxKi()
	if(BP <=0) return
	baseKiMax=(round(100*(max(log(10,BP)**2.3,1)),1)*KiUnlockPercent)

mob/proc/kicapcheck(var/gap)
	var/check = baseKiMax-gap
	if(check>0) return gap
	if(check<=0) return baseKiMax-baseKi

mob/proc/KiRegen()
	CHECK_TICK
	if(Ki<MaxKi&&stamina>=0&&!KO) //kiregen
		sub_gdki_energy(2)
		if(Ki<=MaxKi*0.1&&stamina>=(maxstamina/10))
			stamina-=(KIregen*staminapercent)/4
			Ki+=KIregen*3*staminapercent
		else if(stamina>=(maxstamina/10))
			Ki+=KIregen*staminapercent/6
			stamina -= (KIregen*staminapercent/MaxKi)/9
		if(med&&MeditateGivesKiRegen)
			Ki+=(KIregen*staminapercent*6 + 0.05) //doubles ki regen, free base value.
			stamina -= (KIregen*staminapercent/MaxKi)/6 //doesn't take into account the base value.
			//Also makes meditation useful for regenning Ki even if you're shit at KIregen, to save on stamina.
		if(IsInFight)
			Ki+=KIregen*staminapercent/2
			stamina -= (KIregen*staminapercent/MaxKi)/8
		else
			Ki+=KIregen*staminapercent
			stamina -= (KIregen*staminapercent/MaxKi)/3
		Ki+=0.1 //No matter what, you get a tiny amount of ki regen.
		Ki=min(MaxKi,Ki)
		if(HasEnergyDrain) Ki-=0.0001*HasEnergyDrain*MaxKi
	else
		if(godki && godki.usage) sub_gdki_energy(1)
	if(extracharge)
		extracharge = max(min(50,extracharge),0)
		Ki+= KIregen*((-(1/100)*(extracharge-25)**2) + 6.25)
		stamina -= (KIregen*staminapercent/MaxKi)/3
		extracharge -= 1