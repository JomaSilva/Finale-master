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

// ============================================================================
// PEAK AGE por raca (anos): DeclineAge = peak (declinio/cabelo grisalho comeca);
// LIFESPAN = peak * 1.5 -- o DeclineMod e calibrado (100/peak) pra o Body cair
// de 25 a 0 em exatamente peak*0.5 anos => morte de velhice em peak*1.5.
// 0 = NAO ENVELHECE (Majin). Bio-Android herda o MAIOR peak dos DNAs doadores.
// ============================================================================
proc/race_peak_age(r)
	switch(r)
		if("Human") return 50            //lifespan 75
		if("Saiyan", "Legendary Saiyan") return 80 //lifespan 120
		if("Half-Saiyan", "Half-Breed") return 70
		if("Quarter-Saiyan") return 60
		if("Frost Demon") return 2000    //lifespan 3000
		if("Majin") return 0             //nao envelhece (sem peak, sem limite)
		if("Namekian") return 200        //lifespan 300
		if("Android") return 200
		if("Kai") return 75000
		if("Demon") return 75000
		if("Demigod") return 10000       //sangue divino diluido
		if("Makyo") return 5000          //demonios da Estrela Makyo
		if("Gray") return 300            //raca misteriosa
		if("Yardrat") return 150         //sabios do Instant Transmission
		if("Tsujin") return 130          //extensao de vida por tecnologia
		if("Kanassa-Jin") return 120     //psiquicos
		if("Alien") return 100
		if("Shapeshifter") return 100
		if("Heran") return 90            //raca guerreira, queima rapido
		if("Arlian") return 40           //insetoides de vida curta
		if("Saibamen") return 10         //armas cultivadas descartaveis
		if("Spirit Doll") return 200     //constructo
		if("Meta") return 200            //corpo artificial
	return 100 //raca fora da tabela: padrao generoso

mob/var/up_life_bonus = 0 //Unlock Potential estende a vida (fracao do peak; persistido)

//re-deriva DeclineAge/DeclineMod/imortalidade da TABELA (usado na criacao, no login e no Unlock Potential)
mob/proc/age_table_apply()
	var/peak = race_peak_age(Race)
	if(Race == "Bio-Android" || Parent_Race == "Bio-Android") //bio: MAIOR peak entre os DNAs doadores (sem piso proprio)
		peak = 0
		if(genome && genome.racial_protos)
			for(var/rn in genome.racial_protos)
				peak = max(peak, race_peak_age("[rn]"))
		if(!peak) peak = 100 //sem doador com idade (so Majin/nenhum): padrao
	if(!peak) //Majin: imortal biologico, nunca declina
		biologicallyimmortal = 1
		DeclineAge = 999999
		DeclineMod = 0
		return
	biologicallyimmortal = 0
	DeclineAge = round(peak * (1 + up_life_bonus), 0.1)
	DeclineMod = 100 / peak //morte de velhice ~= peak * 1.5

mob/proc/age_table_login_fix() //personagens criados antes da tabela sincronizam no login
	if(!client) return
	age_table_apply()

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
	if(Class == "Awakened Evolution") //Half-Saiyan Awakened Evolution: potencial oculto se acumula mais rapido (identidade Mystic/Ultimate)
		hiddenpotential += (BP)*UPMod*(max(Year-LastYear,0.1))*1.5
	else
		hiddenpotential += (BP)*UPMod*(max(Year-LastYear,0.1))
	if(Age<=InclineAge)
		if(!MSWorthy)
			var/check
			for(var/mob/M in player_list)
				if(!M.MSWorthy)
					check++
				else break
			if(prob(1) && prob(check) && hiddenpotential >= BP * 10) MSWorthy = 1
		if(Class == "Awakened Evolution") //Awakened Evolution: bonus de jovem tambem amplificado
			hiddenpotential += BP*UPMod*(max(Year-LastYear,0.1))*1.5
		else
			hiddenpotential += BP*UPMod*(max(Year-LastYear,0.1)) //bonus extra de jovem, baseado no proprio BP e potencial (sem media do servidor)
		Body=Age
		AgeStatus="Young"
	cap_hp()
	var/newage = Year-BirthYear
	if(SAge<=newage)
		if(!dead&&!IsAVampire&&!god_is_god(src)) //GOD OF DESTRUCTION nao envelhece enquanto porta o titulo
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
			to_chat(view(src), "[src] dies from old age.")
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
			//unlockPotential NAO reseta: o despertar do potencial e 1x POR PERSONAGEM, mesmo renascendo de velhice
			Age=1
			Body=1
mob/proc/GreyHair() if(hair&&Age>=DeclineAge)
	spawn while(hairchanges<round(Age)-round(DeclineAge))
		spawn for(var/obj/overlay/hairs/hair/A in overlayList)
			A.GrayMe()
		sleep(1)