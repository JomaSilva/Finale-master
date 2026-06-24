proc/statCap(var/stattocap)
	if(stattocap <= 2.182) return stattocap
	var/value = (11-(10*1.78**(-stattocap/10)))//diminishing returns, 10 points is now worth 6, 20 is worth 8.4, so on
	if(stattocap > 39.93) value = ((sqrt(stattocap-35)) / (stattocap - 25)) + 9.67
	//value = min(40,value)
	return value


mob/Admin1
	verb
		Global_Points()
			set name = "Global - Give all skill points."
			set category = "Admin"
			var/REWARD=input("How much?","This will give skill points to everyone!")as num
			if(REWARD<0||REWARD>10000)
				src<<"You cant do that!"
			else
				globalpoints+=REWARD

mob/Admin3
	verb
		BP_Lists()
			set category = "Admin"
			switch(input(usr,"Which command? Remove will remove a player from the BP list, Reset will completely delete BP lists, and exclude will exclude a player from the list. BP List determines the cap.","Cancel") in list("Cancel","Reset","Exclude","Remove"))
				if("Remove")
					var/list/Choices = BPList.Copy()
					Choices.Add("Cancel")
					var/Person=input("Remove which player?") in Choices
					if(Person=="Cancel")
						return
					else
						BPList.Remove(Person)
						BPModList.Remove(Person)
						KiTotalList.Remove(Person)
						LastTimeList.Remove(Person)
				if("Exclude")
					var/mob/M = input(usr,"Select player mob") in player_list
					if(M.exclusion)
						usr<<"Returned to lists"
						M.exclusion = 0
					else if(!M.exclusion)
						usr<<"Excluded"
						M.exclusion = 1
				if("Reset")
					queuedeletion = 1
proc/absolutelyfuckingdestroybplist()
	BPList.Cut()
	BPModList.Cut()
	KiTotalList.Cut()
	LastTimeList.Cut()
	clearlist(BPList)
	clearlist(BPModList)
	clearlist(KiTotalList)
	clearlist(LastTimeList)
	for(var/bpa in BPList)
		BPList.Remove(bpa)
	for(var/bma in BPModList)
		BPList.Remove(bma)
	for(var/kia in KiTotalList)
		BPList.Remove(kia)
	for(var/lasa in LastTimeList)
		BPList.Remove(lasa)
	BPList=new/list()
	BPModList=new/list()
	KiTotalList=new/list()
	LastTimeList=new/list()
mob/var/StatRank=2
mob/var/BPRank=2
mob/var
	Smartest=2
	Fastest=2
	Holdrank
	KiTotal
	tmp/TotalPlayers
	exclusion=0
var
	tmp/AverageRunning=0//we're only going to have the proc run once, no need for every client to run it
	AverageBP=1
	AverageBPMod=1
	AverageKiLevel=1
	BPSD=1//standard deviation in BP
	BPSkew=0//how skewed the server BP distribution is, used to adjust caps
	TopBP=1
	BPList[0]
	BPModList[0]
	KiTotalList[0]
	LastTimeList[0]
	queuedeletion
proc/ServerAverage()
	set background = 1
	if(AverageRunning||worldloading)
		return
	else AverageRunning=1
	if(!RankList)
		RankList = list()
	spawn
		while(AverageRunning)
			var/Amount=1
			var/Average=1
			var/AverageBPPMod=1
			var/AverageKi=1
			/*for(var/ln,ln<=LastTimeList.len,ln++)//declares the ln - (length) var, every time the for loop goes, it'll do a conditional with ln <= length of LastTime list, and increase it.
				var/ck = LastTimeList[ln] //declares the ck (ckey) var, because the list with the ln var with only return the ckey- we're dealing with a index, not associations
				var/lt = LastTimeList[ck] //finally retrieves the association, I.E. the most important part.
				world << "[lt] = [world.realtime]"
				if(lt + (86400 * 2) >= world.realtime) //lt is equal to the realtime var that was retrieved when they last logged in. We want them to be removed after two days. REALTIME IS A BIG NUMBER.
					LastTimeList -= ck //finally, using the ck (remember, this refers to ckey) var, we remove the ckey in question from all lists
					BPList -= ck
					BPModList -= ck
					KiTotalList -= ck
					//SafetyBPList -= ck //at the time of writing, safetyBP was not in use, but essentially you'd want to remove stuff from it too.
					*/
			for(var/mob/A in player_list)
				if(reincarnationver != A.localrver) continue
				if(!istype(A,/mob/lobby)&&!A.exclusion)
					if(!(ckey(A.key) in BPList)||!(ckey(A.key) in BPModList))
						BPList[ckey(A.key)] = A.BP
						BPModList[ckey(A.key)] = A.BPMod
					else if(BPList[ckey(A.key)]<A.BP)
						BPList[ckey(A.key)] = A.BP
						BPModList[ckey(A.key)] = A.BPMod
					LastTimeList[ckey(A.key)] = A.last_login
					if(!(ckey(A.key) in KiTotalList))
						KiTotalList[ckey(A.key)] = A.KiTotal
					else if(KiTotalList[ckey(A.key)]<A.KiTotal)
						KiTotalList[ckey(A.key)] = A.KiTotal
					if(A.signature&&!(A.signature in RankList))
						RankList[A.signature] = A.name
					if(A.signature&&RankList[A.signature] != A.name)
						RankList[A.signature] = A.name
					if(RankList[null]!="")
						RankList[null]=""
			//world << "BP list [BPList] len [BPList.len]"
			if(BPList)
				Amount=BPList?.len
			for(var/X in BPList)
				//world << "average added"
				Average+=BPList[X]
				if(BPList[X]>TopBP)
					//world << "top set"
					TopBP=BPList[X]
			for(var/Y in BPModList)
				//world << "mod done"
				AverageBPPMod+=BPModList[Y]
			for(var/Z in KiTotalList)
				//world << "ki done"
				AverageKi+=KiTotalList[Z]
			if(Amount<1)
				Amount=1
				sleep(10)
				continue
			Average/=Amount
			AverageBPPMod/=Amount
			AverageBPMod=AverageBPPMod
			AverageBP=Average/AverageBPMod
			AverageKiLevel=AverageKi/Amount
			//world << "calcs done. [Amount], [Average] [AverageBPMod]"
			var/tempsd=0
			var/tempskew=0
			for(var/V in BPList)//sd and skew calcs
				tempsd+=((BPList[V]-AverageBP)**2)
				tempskew+=((BPList[V]-AverageBP)**3)
			BPSD=((tempsd/Amount)**0.5)
			BPSkew=((tempskew/(BPSD**3))/Amount)
			powercap()
			sleep(10)
			if(queuedeletion)
				absolutelyfuckingdestroybplist()
				queuedeletion = 0
mob/proc/StatRank()
	set background = 1
	//Stat Ranks
	var/StrongerStats=1
	for(var/mob/A in player_list)
		var/TheirStats=(A.Ephysoff)*(A.Ephysdef)*(A.Espeed)*(A.Ekiskill)*(A.Ekidef)*(A.Etechnique)*(A.Ekiskill) //magiskill is not a strongpoint necessarily
		var/YourStats=(Ephysoff)*(Ephysdef)*(Espeed)*(Ekiskill)*(Ekidef)*(Etechnique)*(Ekiskill)
		if(TheirStats+1>YourStats+1) StrongerStats+=1
	if(src.Holdrank==0)
		StatRank=StrongerStats
	//BP Ranks
	var/StrongerBPs=1
	var/HigherSpeed=1
	var/IntelHigh=1
	for(var/mob/A in player_list)
		if(!istype(A,/mob/lobby))
			if(A.BP+1>BP+1) StrongerBPs+=1
			if(A.Espeed+1>Espeed+1) HigherSpeed+=1
			if(A.techskill+1>techskill+1) IntelHigh+=1
	Smartest=IntelHigh
	BPRank=StrongerBPs
	Fastest=HigherSpeed
	KiTotal=KiTotal()
	if(BPRank==1)
		TopBP = BP

mob/var/PowerRanks={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
Name: ( BP Rank ) ( Stat Rank )
</body><html>"}
mob/Admin2/verb/PowerRanks()
	set hidden = 1
	set category="Other"
	for(var/mob/M) if(M.client) PowerRanks+={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
<br>[M.name]: ( [M.BPRank] ) ( [M.StatRank] )
</body><html>"}
	usr<<browse(PowerRanks,"window=...;size=400x400")
	PowerRanks={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
Name: ( BP Rank ) ( Stat Rank )
</body><html>"}

mob/proc
	BPRankInfo(var/mode) //1- returns largest BP. other modes soon.
		switch(mode)
			if(1)
				for(var/mob/M in mob_list)
					if(M.client&&M.BPRank==1)
						return M.expressedBP