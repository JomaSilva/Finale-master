mob/proc/makeCopy(var/type,var/targetRace,var/targetClass,var/mobType,var/sentient)//sentient means: copy skills over, this copy is meant to be played.
	//copias sao SEMPRE dirigidas por jogador/evento (splitform, clone da mente, saga Majin, Geti/Tier3):
	//ignoram o toggle de spawns ambientes -- mob/npc/New() DELETA o mob na hora se npcspawnson=0 (e a
	//flag persiste no save de settings!), o que matava o makeCopy com um runtime em AssignDupeVars(null)
	//ERA TUDO usr: em contexto de engine (clone da saga Majin dispara pela RAIVA via Death.dm) usr e
	//null/errado -- null.expressedBP matava o proc e o clone NUNCA spawnava. src = o mob sendo copiado.
	var/oldspawns = npcspawnson
	npcspawnson = 1
	var/mob/z = new mobType
	npcspawnson = oldspawns
	AssignDupeVars(z)

	if(targetRace||targetClass)
		z.Race=targetRace
		z.Class=targetClass
		z.genome = new/datum/genetics/Artificial(fetch_race_by_Name("[targetRace]"))
		//ancora a classe no genoma da copia (o decide_Class do finalize nao re-rola por cima);
		//"None" com a MESMA raca do original espelha a classe dele (splitform)
		var/anchor_class = (targetClass && targetClass != "None") ? targetClass : ((targetRace == Race && Class != "None") ? Class : null)
		if(anchor_class)
			z.Class = anchor_class
			z.genome.this_class = anchor_class
			z.genome.old_class = anchor_class
	switch(type)
		if(1) //meta
			z.name="[name] Meta-#[rand(1,1000)]"
			var/icon/I= icon(icon)
			I.Blend(rgb(50,100,200,255),ICON_MULTIPLY)
			z.icon=I
			z.oicon=I
			z.Age=1
			z.Father = name
			z.spacebreather=1
		if(2) //splitform
			z.BP = expressedBP/2
			z.loc=locate(x+rand(-1,1),y+rand(-1,1),src.z)
			z.name="[name] Copy"
			if(Race=="Bio-Android")
				z.overlayList.Remove(z.overlayList)
				z.overlaychanged=1
				z.icon='Cell Jr.dmi'
			if(Race=="Tsujin"|Class=="Tsujin") z.icon='GochekAndroid.dmi'
			else z.icon = icon
			if(!z.genome && genome) z.genome = new genome.type(fetch_race_by_Name("[genome.majority_genome ? genome.majority_genome : Race]"))
			z.attackable = 1
			z.temporary=1
		if(3) //clone
			z.name="[name] (Clone)"
			var/icon/I= icon(icon)
			z.icon=I
			z.oicon=I
			z.Father = name
		if(4) // droid
			z.name="[name] Android Body Model-#[rand(1,1000)]"
			z.icon='GochekAndroid.dmi'
			z.Age=1
			z.Father = name
			z.genome = new/datum/genetics/Android(/datum/genetics/proto/Android)
			z.spacebreather=1
	if(sentient)
		//z.totalskillpoints = totalskillpoints
		switch(type)
			if(1) z.BP = BP * 0.5
			if(3) z.BP = BP * 0.15
			if(4) z.BP = BP * 0.25
		//CopySkills(z)
		z.needs_manual_custom = 1
	z.Savable=1
	z.nokill=1
	z.move=1
	z.displaykey = src.key
	z.Player=0
	z.oicon=z.icon
	z.BirthYear=Year
	z.overlayList = overlayList.Copy() //Copy(): a lista era COMPARTILHADA -- mudar a aura/overlay de um mudava o outro
	z.overlays = z.overlayList
	z.clone = 1
	z.loc=locate(x,y,src.z)
	if(z.genome)
		//era "savant = src" (o ORIGINAL!): o post_init aplicava os stats do genoma DA COPIA no
		//jogador -- assign_starting_BP RESETAVA o BP dele (os runtimes antigos da genetica matavam
		//o proc antes disso e "protegiam"; consertados, a bomba armou). A copia e a dona do genoma.
		var/keepBP = z.BP //o assign_starting_BP setaria o BP da copia pro inicial da classe
		z.genome.savant = z
		z.genome.post_init_savant()
		z.BP = keepBP
	step(z,dir)
	return z
mob/var/needs_manual_custom = 0
mob/var/clone = 0
mob/var/clone_degeneration = 0
mob/proc/AssignDupeVars(var/mob/A) //We have to manually add everything that is important to dupes.
	var/pt1=num2text(rand(1,999),3)
	var/insert1=num2text(rand(50,99),2)
	var/pt2=num2text(rand(1,999),3)
	var/insert2=num2text(rand(20,30),2)
	A.signature=addtext(pt1,insert1,pt2,insert2)
	A.AuraR= AuraR
	A.AuraG= AuraG
	A.AuraB= AuraB
	A.blastR= blastR
	A.blastG= blastG
	A.blastB= blastB
	A.AURA= AURA
	A.ssj4aura= ssj4aura
	A.see_in_dark=see_in_dark
	A.actspeed=actspeed
	A.TextSize=TextSize
	A.originalicon = originalicon
	A.biologicallyimmortal= biologicallyimmortal
	A.attackable=1
	A.SayColor=SayColor
	A.bursticon=bursticon
	A.burststate=burststate
	A.CBLASTICON=CBLASTICON
	A.CBLASTSTATE=CBLASTSTATE
	A.BLASTICON=BLASTICON
	A.BLASTSTATE=BLASTSTATE
	A.InclineAge=InclineAge
	A.Makkankoicon=Makkankoicon
	A.WaveIcon=WaveIcon
	A.healmod=healmod
	A.zanzomod=zanzomod
	A.BPMod=BPMod
	A.MaxAnger=MaxAnger
	A.KiMod=KiMod
	A.MaxKi=MaxKi
	A.physoffMod=physoffMod
	A.Created = 1
	A.kiregenMod=kiregenMod
	A.ZenkaiMod=ZenkaiMod
	A.TrainMod=TrainMod
	A.MedMod=MedMod
	A.SparMod=SparMod
	A.BP=BP
	A.Body=Body
	A.Age=Age
	A.SAge=0
	A.GravMastered=GravMastered
	A.GravMod=GravMod
	A.techskill=techskill
	A.techmod=techmod