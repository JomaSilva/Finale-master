mob/var/unlockPotential
mob/var
	hiddenpotential=0
	UPcooldown=0
	UPMod=1
mob/Rank/verb/Unlock_Potential()
	set category="Skills"
	var/mob/M=input("Who?","") as null|mob in view(1)
	if(M) switch(input(M,"[usr] wants to unlock your hidden powers. Do you want to do this?", "",text) in list("No","Yes"))
		if("Yes")
			if(M.unlockPotential!=1)
				view()<<"[usr] uses Unlock Potential on [M]!"
				M.UnlockPotential(UPMod)
			else usr<<"They've already had their potential unlocked!"
		if("No") usr<<"[M] declined your offer."

mob/proc/UnlockPotential(rUPMod)
	if(unlockPotential==0)
		rUPMod = max(UPMod,rUPMod)
		emit_Sound('chargeaura.wav')
		unlockPotential=1
		var/boost=((BPMod)*UPMod*StatRank*(1/5))
		var/awaken_mult = 1
		if(Class == "Awakened Evolution") awaken_mult = 1.8 //Half-Saiyan Awakened Evolution: payoff muito maior ao liberar o potencial
		if(hiddenpotential)
			if(BPRank==1) BPadd += capcheck(hiddenpotential*(1/10)*awaken_mult)
			else BPadd += capcheck(hiddenpotential * (BPRank/5)*awaken_mult)
		BP+=capcheck(hiddenpotential * boost*log(relBPmax)*(1/20)*awaken_mult)
		kiskill+= 0.4
		if(Age>=DeclineAge)
			Body=25
			genome.add_to_stat("Lifespan",(2*rUPMod/10))
		if(Age<=InclineAge)
			Body=25
			InclineAge=(Age/1.1) //Incline is now behind ya!
		genome.add_to_stat("Lifespan",(5*rUPMod/10))