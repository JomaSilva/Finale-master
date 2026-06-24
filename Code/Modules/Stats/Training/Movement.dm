mob/proc/Swim_Gain()
	if(BP<relBPmax&&lastdir!=dir)
		BP+=capcheck(relBPmax*BPTick*(1/30)) //24
		lastdir=dir

mob/proc/Flight_Gain()
	var/lastloc
	if(BP<relBPmax&&lastloc!=loc)
		BP+=capcheck(relBPmax*BPTick*(1/24)) //12 hours
		lastloc=loc
	if(baseKi<=baseKiMax)baseKi+=kicapcheck(0.001*KiMod*baseKiMax/baseKi)