datum/skill/tree/Rank/Otherworld
	name = "Otherworld Tree"
	desc = "Mystical Stuff."
	maxtier = 1
	allowedtier = 3
	tier=1
	constituentskills = list(new/datum/skill/kaioken,new/datum/skill/expand,new/datum/skill/rank/Restore_Youth,\
	new/datum/skill/rank/Keep_Body,new/datum/skill/rank/Dead,new/datum/skill/rank/Unlock_Potential,\
	new/datum/skill/general/observe,new/datum/skill/kai/Mystic,new/datum/skill/demon/Majin,new/datum/skill/rank/Reincarnate,\
	new/datum/skill/rank/BusterBarrage,new/datum/skill/general/selfdestruct,new/datum/skill/style/GodStyle,\
	new/datum/skill/rank/SpiritBomb,new/datum/skill/ki/Heal,new/datum/skill/rank/KaiPermission,new/datum/skill/style/DemonStyle,new/datum/skill/Telepathy,\
	new/datum/skill/rank/Kaioshin_Apprenticeship)//kai/demon/mystical rank skills

//O fund() (trees.dm) nao checa duplicata: o Kaio do Norte que JA aprendeu a Spirit Bomb (ou o
//Kaio-ken) com o Sr. Kaioh pagaria Marco por uma copia da mesma tecnica. Esta arvore e a unica
//com skill de DUPLA ORIGEM (NPC + cargo), entao a guarda mora aqui.
datum/skill/tree/Rank/Otherworld/attemptlearn(var/datum/skill/S)
	if(S && savant && savant.HasSkill(S.type))
		to_chat(savant, "Voce ja conhece [S.name].")
		return
	..()

//O treeshrink BASE refunda QUALQUER skill aprendida que combine com um constituinte
//desabilitado -- mesmo a que veio de FORA da arvore. Como o Sr. Kaioh ensina Kaio-ken e
//Spirit Bomb de graca (SkyNPCs.dm) e as duas ficam desabilitadas pra quem nao e Kaio do
//Norte, um Grand Kai/Kaioshin perdia a tecnica que o NPC deu. Aqui so cai o que foi
//comprado NESTA arvore.
datum/skill/tree/Rank/Otherworld/treeshrink()
	testskillprereqs()
	savant.testunlocks()
	for(var/datum/skill/S in savant.learned_skills)
		if(!(locate(S.type) in investedskills)) continue //nao saiu daqui: nao e nosso pra tirar
		if(!S.can_forget) continue
		if(S.tier > allowedtier)
			to_chat(savant, "You don't have enough skill in [src.name] to maintain [S.name]!")
			refund(S)
			continue
		for(var/datum/skill/nS in constituentskills)
			if(nS.type != S.type) continue
			if(nS.enabled == 0 || nS.override == 1)
				to_chat(savant, "Voce perdeu os pre-requisitos de [S.name] e a esqueceu junto.")
				refund(S)
			break

datum/skill/tree/Rank/Otherworld/growbranches()
	savant.LastRank=savant.Rank
	disableskill(/datum/skill/ki/Genkidama) //APOSENTADA: so existe em arvore SALVA (a definicao nova nem lista) -- esconde pra ninguem comprar defunto
	if(savant.Rank!="West Kai") disableskill(/datum/skill/rank/BusterBarrage)
	if(savant.Rank!="East Kai") disableskill(/datum/skill/general/selfdestruct)
	if(savant.Rank!="North Kai") disableskill(/datum/skill/kaioken)
	if(savant.Rank!="North Kai") disableskill(/datum/skill/rank/SpiritBomb) //mesma tecnica que o Sr. Kaioh ensina (SpiritBomb.dm)
	if(savant.Rank!="Supreme Kai") disableskill(/datum/skill/rank/Kaioshin_Apprenticeship) //ex-Kaioshin nao toma mais discipulos
	switch(savant.Rank)
		if("Demon Lord")//like the grand kai
			enableskill(/datum/skill/style/DemonStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/demon/Majin)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/rank/Unlock_Potential)
			enableskill(/datum/skill/rank/Restore_Youth)
			enableskill(/datum/skill/rank/Ritual_of_Might)
		if("King_Of_Hell")//like the supreme kai
			enableskill(/datum/skill/style/DemonStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/demon/Majin)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/general/observe)
		if("Grand Kai") //keeps unlock potential, needs exclusive skill.
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Unlock_Potential)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Restore_Youth)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/rank/KaiPermission)
			enableskill(/datum/skill/rank/Ritual_of_Might)
		if("Supreme Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/kai/Mystic)
			enableskill(/datum/skill/rank/Reincarnate)
			enableskill(/datum/skill/rank/Revive)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/KaiPermission)
			enableskill(/datum/skill/rank/Ritual_of_Might)
			enableskill(/datum/skill/ki/Heal)
			enableskill(/datum/skill/rank/Kaioshin_Apprenticeship) //toma discipulos (KaioshinApprentice.dm)
		if("West Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/BusterBarrage)
			enableskill(/datum/skill/rank/Revive)
		if("East Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/general/selfdestruct)
			enableskill(/datum/skill/rank/BusterShell)
			enableskill(/datum/skill/rank/Revive)
		if("North Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/kaioken)
			enableskill(/datum/skill/rank/SpiritBomb)
			enableskill(/datum/skill/rank/Revive)
		if("South Kai")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/expand)
			enableskill(/datum/skill/rank/Revive)
		if("King Yemma")
			enableskill(/datum/skill/rank/Judge)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/rank/Revive)
	..()

mob/var/kaipermission
/datum/skill/rank/KaiPermission
	skilltype = "Misc"
	name = "Give Permission (Kai)"
	desc = "Give permission to a person to use the facilities of the Kai Loft and/or Hallowed Realm, located in Heaven."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/KaiPermission/after_learn()
	assignverb(/mob/Rank/verb/KaiPermission)
	to_chat(savant, "You give permissions.")
/datum/skill/rank/KaiPermission/before_forget()
	unassignverb(/mob/Rank/verb/KaiPermission)
	to_chat(savant, "You've forgotten how to give permission?")
/datum/skill/rank/KaiPermission/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/KaiPermission)

mob/Rank/verb/KaiPermission(mob/M in view(6))
	set category="Other"
	switch(input("Give permission for [M] to enter the Kai Loft and/or the Hallowed Realm?", "", text) in list ("Kai Loft","Kai Loft and Hallowed Realm","Neither",))
		if("Kai Loft and Hallowed Realm")
			to_chat(usr, "You give [M] permission to enter the Hallowed Realm and Kai Loft.")
			M.kaipermission=2
		if("Kai Loft")
			to_chat(usr, "You give [M] permission to use the Kai Loft.")
			M.kaipermission=1
		if("Neither")
			to_chat(usr, "You deny [M] permission to enter the Kai Loft or use the Hallowed Realm.")
			M.kaipermission=0