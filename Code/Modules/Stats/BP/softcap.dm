var
	BPCap = 1000
	HardCap = 1000
	CapType = 1
	CapRate = 1 //1 = 1 filled cap/24 hours on meditate-much more than a doubling a day on average for a softcap
	GainsRate = 1 //whenever capcheck() is called, this will increase the number put into it by this amount. Not recommended to be changed. For the impatient.
	prevcap = 1
	timecapboost = 1 //new feature: timecap makes things less dependent on server bp (both stronk and weak.)
	timecaprate = 0.25 //differenciation between caprate and timecap rate makes this easier
	catchupcap = 2
	relcaprate = 1


mob/Admin3/verb
	Cap_Settings()
		set category = "Admin"
		switch(input(usr,"What setting to change?","Cap Settings","Cancel") in list("Cancel","Cap Type","Hardcap Amount","Cap Multiplier","Gains Rate","Edit Cap","Cap Catchup","Timecap Rate","Relative BP Caps"))
			if("Cap Type")
				if(CapType == 1) usr<<"World BP Cap is a Hardcap (1)."
				if(CapType == 2) usr<<"World BP Cap is a Softcap (2)."
				if(CapType == 2.5) usr<<"World BP Cap is a Softcap (2) w/o Skew."
				if(CapType == 3) usr<<"World BP Cap is a Timecap (3)."
				var/multiplier=input("Enter 1 for a Hardcap and 2 for a Softcap, 3 for a Timecap. 2.5 for softcap without skew. Softcap without skew is for testing purposes!") as num
				if(multiplier == 2)
					CapType = 2
					world<<"<b><font color=yellow>World BP Cap has been changed to a Softcap."
				else if(multiplier == 2.5)
					CapType = 2.5
					world<<"<b><font color=yellow>World BP Cap has been changed to a Softcap without skew."
				else if(multiplier == 1)
					CapType = 1
					world<<"<b><font color=yellow>World BP Cap has been changed to a Hardcap."
				else
					CapType = 3
					world<<"<b><font color=yellow>World BP Cap has been changed to a Timecap."
			if("Hardcap Amount")
				usr<<"Hardcap is at [HardCap]."
				var/multiplier=input(usr,"Enter a number for the hardcap. (1 = 1 BP)","",HardCap) as num
				HardCap=multiplier
				world<<"<b><font color=yellow>World BP Hardcap has been changed to [HardCap]"
				WriteToLog("admin","[usr]([key]) changed global BP cap to [HardCap] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Cap Multiplier")
				usr<<"Cap multiplier is at [CapRate]."
				var/multiplier=input(usr,"Enter a number for the cap-mult.","",CapRate) as num
				CapRate=multiplier
				world<<"<b><font color=yellow>World BP Cap Rate has been changed to [CapRate]"
				WriteToLog("admin","[usr]([key]) changed Cap Rate to [CapRate] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Gains Rate")
				usr<<"Gains rate is at [GainsRate]."
				var/multiplier=input(usr,"Enter a number for the gains-rate. This will multiply all resulting gains by this number.","",GainsRate) as num
				GainsRate=multiplier
				world<<"<b><font color=yellow>World BP Gains Rate has been changed to [GainsRate]"
				WriteToLog("admin","[usr]([key]) changed Gains Rate to [GainsRate] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Edit Cap")
				usr<<"BP Softcap is [BPCap]"
				var/newcap=input(usr,"Enter a number for the cap.","",BPCap) as num
				BPCap = newcap
				WriteToLog("admin","[usr]([key]) changed Softcap to [BPCap] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Cap Catchup")
				usr<<"BP Softcap is [BPCap]"
				var/newcap=input(usr,"Manipulate catchup. 0 will disable it. 2 is the norm. The equation is based on a logarithm. That means higher = close to 1, lower = farther away from 1.","",catchupcap) as num
				catchupcap = newcap
				WriteToLog("admin","[usr]([key]) changed Cap Catchup to [catchupcap] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Timecap Rate")
				usr<<"Timecap rate is [timecaprate]"
				var/newcap=input(usr,"Time cap rate is the rate the timecap will grow. At 1x, it'll double once per day. At 0.5x, it'll go up to 1.5x per day. The calc is (normal cap) + (timecap), in which the timecap is slowly increased by '1/24 * Time cap rate' of the (normalcap).","",timecaprate) as num
				timecaprate = newcap
				WriteToLog("admin","[usr]([key]) changed Time cap rate to [timecaprate] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Relative BP Caps")
				usr<<"Relative BP Cap rate is [relcaprate]"
				var/newcap=input(usr,"Relative cap rate increases everyone's relative cap by this amount. Generally don't put a multiplier that would increase it past the normal cap.","",relcaprate) as num
				relcaprate = newcap
				WriteToLog("admin","[usr]([key]) changed Relative cap rate to [relcaprate] at [time2text(world.realtime,"Day DD hh:mm")]")
proc/powercap() //operation: fix garbage get money
	if(CapType == 1)
		BPCap = HardCap
	if(CapType == 2)
		CHECK_TICK
		var/skewmod
		if(BPSkew<0)
			skewmod=(1-BPSkew)
		else
			skewmod=1
		var/ncap = (AverageBP * AverageBPMod * 2 * CapRate * skewmod) //(AverageBP*AverageBPMod)+(CapRate*AverageBP*AverageBPMod)//-(BP/BPMod),0))
		//if(prevcap<ncap) - now that the average is stored, we don't need this, and it also causes some cap bugs
		BPCap = ncap
		prevcap = BPCap
	if(CapType == 2.5)
		CHECK_TICK
		/*var/skewmod
		if(BPSkew<0)
			skewmod=(1-BPSkew)
		else
			skewmod=1*/
		var/ncap = (AverageBP * AverageBPMod * 2 * CapRate/* * skewmod*/) //(AverageBP*AverageBPMod)+(CapRate*AverageBP*AverageBPMod)//-(BP/BPMod),0))
		//if(prevcap<ncap) - now that the average is stored, we don't need this, and it also causes some cap bugs
		BPCap = ncap
		prevcap = BPCap
	if(CapType == 3)
		//take the old soft cap
		CHECK_TICK
		var/skewmod
		if(BPSkew<0)
			skewmod=(1-BPSkew)
		else
			skewmod=1
		var/ncap = (AverageBP * AverageBPMod * 2 * CapRate * skewmod) + timecapboost
		timecapboost += (ncap / 86000) * timecaprate//very slow, but essentially as this feeds back into ncap, and stays, the cap should grow no matter what.
		//now feed it through some calcs
		timecapboost = min((AverageBP * AverageBPMod * 2 * CapRate * skewmod) * 2,timecapboost) //does limit itself.
		BPCap = ncap
		prevcap = BPCap