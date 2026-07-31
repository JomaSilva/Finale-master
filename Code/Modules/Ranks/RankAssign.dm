mob/proc/CheckRank()
	if(Turtle==signature) Turtle=null
	if(Crane==signature) Crane=null
	if(Frost_Demon_Lord==signature) Frost_Demon_Lord=null
	if(Demon_Lord==signature) Demon_Lord=null
	if(Earth_Guardian==signature) Earth_Guardian=null
	if(Assistant_Guardian==signature) Assistant_Guardian=null
	if(Namekian_Elder==signature) Namekian_Elder=null
	if(North_Kai==signature) North_Kai=null
	if(South_Kai==signature) South_Kai=null
	if(East_Kai==signature) East_Kai=null
	if(West_Kai==signature) West_Kai=null
	if(Grand_Kai==signature) Grand_Kai=null
	if(Supreme_Kai==signature) Supreme_Kai=null
	if(King_of_Vegeta==signature) King_of_Vegeta=null
	if(President==signature) President=null
	if(Frost_Demon_Lord==signature) Frost_Demon_Lord=null
	if(King_Of_Hell==signature) King_Of_Hell=null
	if(King_Of_Acronia==signature) King_Of_Acronia=null
	if(Arconian_Guardian==signature) Arconian_Guardian=null
	if(Saibamen_Rouge_Leader==signature) Saibamen_Rouge_Leader=null
	if(King_Yemma==signature) King_Yemma=null
	if(God_Of_Destruction==signature) God_Of_Destruction=null
	if(Angel_Rank==signature) Angel_Rank=null
	if(signature in ksap_list) //personagem novo nao herda o aprendizado de uma signature reciclada
		ksap_list -= signature
		Save_Rank() //grava JA: o savefile RANK so e lido no boot, e um reboot ressuscitaria o vinculo
	mst_purge_sig(signature) //idem para o discipulado mestre-aluno (MasterStudent.dm)
proc/WipeRank()
	if(Turtle!=null) Turtle=null
	if(Crane!=null) Crane=null
	if(Frost_Demon_Lord!=null) Frost_Demon_Lord=null
	if(Demon_Lord!=null) Demon_Lord=null
	if(Earth_Guardian!=null) Earth_Guardian=null
	if(Assistant_Guardian!=null) Assistant_Guardian=null
	if(Namekian_Elder!=null) Namekian_Elder=null
	if(North_Kai!=null) North_Kai=null
	if(South_Kai!=null) South_Kai=null
	if(East_Kai!=null) East_Kai=null
	if(West_Kai!=null) West_Kai=null
	if(Grand_Kai!=null) Grand_Kai=null
	if(Supreme_Kai!=null) Supreme_Kai=null
	if(King_of_Vegeta!=null) King_of_Vegeta=null
	if(President!=null) President=null
	if(Frost_Demon_Lord!=null) Frost_Demon_Lord=null
	if(King_Of_Hell!=null) King_Of_Hell=null
	if(King_Of_Acronia!=null) King_Of_Acronia=null
	if(Arconian_Guardian!=null) Arconian_Guardian=null
	if(Saibamen_Rouge_Leader!=null) Saibamen_Rouge_Leader=null
	if(King_Yemma!=null) King_Yemma=null
	if(God_Of_Destruction!=null) God_Of_Destruction=null
	if(Angel_Rank!=null) Angel_Rank=null
	if(ksap_list.len) ksap_list.Cut() //wipe que apaga o mestre tem que apagar os aprendizes junto
mob/proc/Rank_Verb_Assign() //the //done checkmarks are to keep track of what ranks are fully converted over to the skills system
	if(!signiture || !signature) return
	//APRENDIZ DE KAIOSHIN (KaioshinApprentice.dm): primeiro da cadeia -- a lista abaixo e de ifs sem
	//else, entao qualquer CARGO REAL sobrescreve o titulo. O rq_any_rank cobre ainda os cargos que
	//NAO tem ramo aqui (Frost Demon Lord, Makyo King, Arlian), que senao ficariam exibindo "aprendiz".
	//A guarda de duplicata da RankTree os ramos legados nao tem: sem ela cada login empilha uma no save.
	if((signature in ksap_list) && !rq_any_rank(src))
		if(!(locate(/datum/skill/tree/RankTree) in possessed_trees))
			getTree(new /datum/skill/tree/RankTree)
		Rank="Kaioshin Apprentice"
	if(Crane==signature) //done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Crane"
	if(Turtle==signature) //done
		Rank="Turtle"
		getTree(new /datum/skill/tree/RankTree)
	if(Saibamen_Rouge_Leader==signature) //done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Saibamen Rouge Leader"
	if(Demon_Lord==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Demon Lord"
	if(Grand_Kai==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Grand Kai"
	if(Supreme_Kai==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Supreme Kai"
	if(capt==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Captain/King of Pirates"
	if(King_of_Vegeta==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="King of Vegeta"
	if(North_Elder==signature|South_Elder==signature|West_Elder==signature|East_Elder==signature) //done
		Rank="Namekian Elder"
		getTree(new /datum/skill/tree/RankTree)
	if(Assistant_Guardian==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Earth Assistant Guardian"
	if(Earth_Guardian==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Earth Guardian"
	if(Namekian_Elder==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Namekian Grand Elder"
	if(President==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="President"
	if(King_Of_Acronia==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="King Of Acronia"
	if(Arconian_Guardian==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Arconian Guardian"
	if(Geti==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Geti Star King"
	if(mutany==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="Mutany Leader"
	if(East_Kai==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="East Kai"
	if(King_Yemma==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="King Yemma"
	if(West_Kai==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="West Kai"
	if(South_Kai==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="South Kai"
	if(North_Kai==signature)//done
		getTree(new /datum/skill/tree/RankTree)
		Rank="North Kai"
	if(God_Of_Destruction==signature) //rank NOVO (2026-07-11): por enquanto so titulo, sem poderes (a detalhar)
		getTree(new /datum/skill/tree/RankTree)
		Rank="God of Destruction"
	if(Angel_Rank==signature) //rank NOVO (2026-07-11): por enquanto so titulo, sem poderes (a detalhar)
		getTree(new /datum/skill/tree/RankTree)
		Rank="Angel"
	if(Admin) getTree(new /datum/skill/tree/RankTree)//done (obviously)
	godtongue_check() //rank divino (atual ou recem-ganho) aprende a LINGUA DOS DEUSES -- e nunca esquece (WishTable.dm)
proc/Save_Rank()
	var/savefile/S=new("RANK")
	S["DL"]<<Demon_Lord
	S["EG"]<<Earth_Guardian
	S["KOM"]<<King_Of_Hell
	S["KOA"]<<King_Of_Acronia
	S["AG"]<<Arconian_Guardian
	S["SRL"]<<Saibamen_Rouge_Leader
	S["AG"]<<Assistant_Guardian
	S["NELD"]<<Namekian_Elder
	S["NE"]<<North_Elder
	S["SE"]<<South_Elder
	S["EE"]<<East_Elder
	S["WE"]<<West_Elder
	S["NK"]<<North_Kai
	S["SK"]<<South_Kai
	S["EK"]<<East_Kai
	S["WK"]<<West_Kai
	S["GK"]<<Grand_Kai
	S["SPK"]<<Supreme_Kai
	S["KOV"]<<King_of_Vegeta
	S["PRS"]<<President
	S["TURT"]<<Turtle
	S["Crane"]<<Crane
	S["Yemma"]<<King_Yemma
	S["KOP"]<<capt
	S["ML"]<<mutany
	S["Geti"]<<Geti
	S["Arlian"]<<Arlian
	S["GODR"]<<God_Of_Destruction
	S["ANGR"]<<Angel_Rank
	S["KSAP"]<<ksap_list
	S["RankList"]<<RankList
proc/Load_Rank()
	if(fexists("RANK"))
		var/savefile/S=new("RANK")
		S["DL"]>>Demon_Lord
		S["EG"]>>Earth_Guardian
		S["KOM"]>>King_Of_Hell
		S["KOA"]>>King_Of_Acronia
		S["AG"]>>Arconian_Guardian
		S["SRL"]>>Saibamen_Rouge_Leader
		S["AG"]>>Assistant_Guardian
		S["NELD"]>>Namekian_Elder
		S["NE"]>>North_Elder
		S["SE"]>>South_Elder
		S["EE"]>>East_Elder
		S["WE"]>>West_Elder
		S["NK"]>>North_Kai
		S["SK"]>>South_Kai
		S["EK"]>>East_Kai
		S["WK"]>>West_Kai
		S["GK"]>>Grand_Kai
		S["SPK"]>>Supreme_Kai
		S["KOV"]>>King_of_Vegeta
		S["PRS"]>>President
		S["TURT"]>>Turtle
		S["Crane"]>>Crane
		S["Yemma"]>>King_Yemma
		S["KOP"]>>capt
		S["ML"]>>mutany
		S["Geti"]>>Geti
		S["Arlian"]>>Arlian
		S["GODR"]>>God_Of_Destruction
		S["ANGR"]>>Angel_Rank
		S["KSAP"]>>ksap_list
		if(isnull(ksap_list)) ksap_list=new/list() //save antigo nao tem a chave: lista vazia, zero aprendizes
		S["RankList"]>>RankList
		if(isnull(RankList)) RankList=new/list()
	god_state_load() //estado do God of Destruction (tarefas/duelo) + liga o loop de tarefas (GodOfDestruction.dm)

var
	Turtle //Can make shells up to 10000 kg, can use and teach Kamehameha
	Crane
	Geti


	Frost_Demon_Lord
	Demon_Lord //Can Majinize

	Earth_Guardian //Can make HBTC Keys, can make Dragon Balls if they are Namekian.
	Assistant_Guardian //Can grow Senzu Beans, Can activate Sacred Water Portal.

	King_Of_Hell
	King_Of_Acronia
	Arconian_Guardian
	Saibamen_Rouge_Leader
	King_Yemma

	Namekian_Elder //Can make Dragon Balls. Keeper of 3 Dragon Balls. Can assign Elders.
	North_Elder //Keeper of 1 Dragonball.
	South_Elder //Keeper of 1 Dragonball.
	East_Elder //Keeper of 1 Dragonball.
	West_Elder //Keeper of 1 Dragonball.

	God_Of_Destruction //rank NOVO: Deus da Destruicao (sem poderes ainda -- a detalhar)
	Angel_Rank //rank NOVO: Anjo (sem poderes ainda -- a detalhar). "Angel_Rank" pq ha um turf chamado Angel (Turfs.dm)
	North_Kai //Can teach Kaioken and Spirit Bomb.
	South_Kai //Can teach Body Expansion. (x2 physoff, x1.2 End, /1.2 Spd, -2% Stam per second.)
	East_Kai //Can teach Ki Burst. (x2 Ki Power, -2% Stam per second.)
	West_Kai //Can teach Self Destruction.
	Grand_Kai //Can teleport to Grand Kais.
	Supreme_Kai //Can grant Mystic indefinitely and teleport to Grand Kais.
	Arlian
	capt
	mutany
	King_of_Vegeta //Can tax up to 100 zenni an hour, assign bounties, Can observe People
	//using Crystal Ball. Can invite People to Royal Army and
	//Raise army ranks (by numbers) and decide whether or not to tax People in the army, can also
	//decommission those in the army and give them the rank of former soldier rank ??. Saiyans only.
	list/vegeta_royalty = list("Prince"="","Princess"="")
	list/vegeta_army = list()
	President //Can tax up to 30 zenni an hour, must be elected.
	//Can give Go To HQ verb, can commission and decommission police and
	//decide whether or not to tax exempt police, police retain their rank through retirement.
	//Can assign bounties.

	EarthTax=1 //The amount collected each tax period.
	EarthBank=5000 //Taxes collected.
	Eexempt

	VegetaTax=1
	VegetaBank=10000
	Vexempt
	RankList[]//associative list of signature and name, so we don't have to display numbers

mob/var
	Prince
	Princess
	taxtimer=0
	bounty=0
	RTaxExempt=0
	ETaxExempt=1
var/Ranks={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>

</body><html>"}
mob/verb/Ranks()
	set category="Other"
	Ranks={"<html>
<head><title>Ranks</head></title><body>
<body bgcolor="#000000"><font size=2><font color="#00FFFF"><b><i>
Earth Guardian: [RankList[Earth_Guardian]]<br>
Korin: [RankList[Assistant_Guardian]]<br>
Namekian Elder: [RankList[Namekian_Elder]]<br>
North Kai: [RankList[North_Kai]]<br>
South Kai: [RankList[South_Kai]]<br>
Makyo King: [RankList[King_Of_Hell]]<br>
King Yemma: [RankList[King_Yemma]]<br>
East Kai: [RankList[East_Kai]]<br>
West Kai: [RankList[West_Kai]]<br>
King Of Acronia: [RankList[King_Of_Acronia]]<br>
Arconian Guardian: [RankList[Arconian_Guardian]]<br>
Saibamen Rouge Leader: [RankList[Saibamen_Rouge_Leader]]<br>
Grand Kai: [RankList[Grand_Kai]]<br>
Kaioshin: [RankList[Supreme_Kai]]<br>
God of Destruction: [RankList[God_Of_Destruction]]<br>
Angel: [RankList[Angel_Rank]]<br>
Demon Lord: [RankList[Demon_Lord]]<br>
Frost Demon Lord: [RankList[Frost_Demon_Lord]]<br>
King/Queen of Vegeta: [RankList[King_of_Vegeta]]<br>
President: [RankList[President]]<br>
Turtle Hermit: [RankList[Turtle]]<br>
Crane Hermit: [RankList[Crane]]<br>
Geti Star King/Queen: [RankList[Geti]]<br>
Captain/King of Pirates: [RankList[capt]]<br>
Mutany Leader: [RankList[mutany]]<br><br><br>
</body><html>"}
	if(ksap_list.len) //patronato do Kaioshin: varios donos, entao vai em bloco proprio (KaioshinApprentice.dm)
		Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#e8b64c"><b><i>
*Aprendizes de Kaioshin*<br>
</body><html>"}
		for(var/ksig in ksap_list)
			Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#e8b64c"><b><i>
[RankList[ksig]] (mestre: [RankList[ksap_list[ksig]]])<br>
</body><html>"}
	if(conq_data.len) //dominios planetarios da conquista (PlanetConquest.dm)
		Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#FF8844"><b><i>
*Dominios Planetarios*<br>
</body><html>"}
		for(var/cpl in conq_data)
			var/list/CR = conq_data[cpl]
			if(!islist(CR)) continue
			Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#FF8844"><b><i>
[cpl]: [CR["name"]]<br>
</body><html>"}
	Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#FFCC00"><b><i>
*Vegeta Priviledged*<br>
</body><html>"}
	for(var/A in vegeta_royalty)
		if(vegeta_royalty[A])
			Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#FFCC00"><b><i>
[A] [vegeta_royalty[A]]<br>
</body><html>"}
	for(var/A in vegeta_army)
		Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#FFCC00"><b><i>
[A] [vegeta_army[A][1]] rank [vegeta_army[A][2]]<br>
</body><html>"}
	Ranks+={"<html>
<head><title>Ranks</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#22FF22"><b><i>
<br><br>*Taxes*<br>
Tax on Earth is [EarthTax]z<br>
Tax on Vegeta is [VegetaTax]z<br><br>
<font color="#FFFF00">
Total Players since last reboot: [PlayerCount]<br>
</body><html>"}
	usr<<browse(Ranks,"window=Ranks;size=500x500")