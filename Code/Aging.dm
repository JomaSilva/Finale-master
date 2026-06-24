proc/SaveYear()
	var/savefile/S=new("Year")
	S["Year"]<<Year
	if(!GENGAIN||GENGAIN==0||GENGAIN<=0)
		GENGAIN=(Year/10)
	S["GENGAIN"]<<GENGAIN
	S["CAP"]<<BPCap
	if(!EarthTax)
		EarthTax=1
	S["EarthBank"]<<EarthBank
	if(!VegetaTax)
		VegetaTax=1
	S["VegetaBank"]<<VegetaBank
	if(!EarthBank)
		EarthBank=1
	S["EarthTax"]<<EarthTax
	if(!VegetaBank)
		VegetaBank=1
	S["VegetaTax"]<<VegetaTax
	S["Speed"]<<Yearspeed
proc/LoadYear() if(fexists("Year"))
	var/savefile/S=new("Year")
	S["CAP"]>>BPCap
	S["EarthBank"]>>EarthBank
	if(!EarthBank)
		EarthBank=1
	S["VegetaBank"]>>VegetaBank
	if(!VegetaBank)
		VegetaBank=1
	S["EarthTax"]>>EarthTax
	if(!EarthTax)
		EarthTax=1
	S["VegetaTax"]>>VegetaTax
	if(!VegetaTax)
		VegetaTax=1
	S["Speed"] >> Yearspeed
	S["Year"]>>Year
	S["GENGAIN"]>>GENGAIN
	if(!GENGAIN||GENGAIN==0||GENGAIN<=0)
		GENGAIN=(Year/10)
var/GENGAIN=0.01
var/Yearspeed=1
mob/var
	biologicallyimmortal=0
	AgeDiv=1
	Halfie_Year=0
	taxpayment=0
	BirthYear=0
	Has_Breed=0
	LastYear=0 //The last year they were logged on to the server.
	DeclineMod=1
	hairchanges=0

mob/proc/AgeCheck(var/skipTimeText)
	if(!skipTimeText) src<<checkthetimeidiot()
	if(LastYear==Year||Year-LastYear==0) return
	if(dead && !Planet in list("Heaven","Hell","Afterlife"))returning=1 //And finally, send them to the death checkpoint...
	hiddenpotential = max(AverageBP/15,hiddenpotential)
	hiddenpotential += (BP)*UPMod*(max(Year-LastYear,0.1))
	if(Age<=InclineAge)
		if(!MSWorthy)
			var/check
			for(var/mob/M in player_list)
				if(!M.MSWorthy)
					check++
				else break
			if(prob(1) && prob(check) && hiddenpotential >= BP * 10) MSWorthy = 1
		if(BP<AverageBP)
			hiddenpotential += BP*2*UPMod*(AverageBP/(max(BP,1))*(max(Year-LastYear,0.1)))
		else
			hiddenpotential += BP*UPMod*(max(Year-LastYear,0.1))
		Body=Age
		AgeStatus="Young"
	cap_hp()
	var/newage = Year-BirthYear
	if(SAge<=newage)
		if(!dead&&!IsAVampire)
			Age+=max(Year-LastYear,0)
		if(IsAVampire)
			if(ParanormalBPMult<VampireBPMultMax)
				ParanormalBPMult = min(ParanormalBPMult+(0.1 * max(Year-LastYear,0.1)),VampireBPMultMax)
	if(participated_ritual && last_rit <= Year + 5) participated_ritual = FALSE //Godki ritual only once every 5 years...
	SAge=newage
	LastYear=Year
	if(!Has_Breed&&Age>=Mature_Age)
		Has_Breed=1
		if(N_Breed)contents+=new/obj/Mate1
		if(E_Breed)contents+=new/obj/Mate2
	else if(Age>=DeclineAge) AgeStatus="Old"
	else AgeStatus="Adult"
	if(IsAVampire||immortal||biologicallyimmortal)
		Body=25
	if(!immortal&&!dead&&!IsAVampire&&DeathRegen<2)
		if(Age>=25&&Age<DeclineAge)
			Body=25
		if(DeathRegen)
			Body=min(Age,25)
		else
			if(Age>=DeclineAge&&!dead&&DeathRegen<2&&!biologicallyimmortal)
				Body=25-((Age-DeclineAge)*0.5*DeclineMod)
				GreyHair()
		if(Body<0.1)
			view(src)<<"[src] dies from old age."
			hairchanges=0
			AgeDiv=DeclineAge/Age
			EnteredHBTC=0
			buudead="force"
			Death()
			buudead=0
			sacredwater=0
			might=0
			yemmas=0
			majinized=0
			mystified=0
			unlockPotential=0
			Age=1
			Body=1
mob/proc/GreyHair() if(hair&&Age>=DeclineAge)
	spawn while(hairchanges<round(Age)-round(DeclineAge))
		spawn for(var/obj/overlay/hairs/hair/A in overlayList)
			A.GrayMe()
		sleep(1)