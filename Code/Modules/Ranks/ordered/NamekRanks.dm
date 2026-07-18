datum/skill/tree/Rank/Namek
	name = "Namek Tree"
	desc = "Skills based on Namek figures."
	maxtier = 1
	allowedtier = 1
	tier=1
	constituentskills = list(new/datum/skill/rank/Appoint_Elder,\
	new/datum/skill/rank/Keep_Body,new/datum/skill/rank/Dead,new/datum/skill/rank/Unlock_Potential,\
	new/datum/skill/style/NamekStyle,new/datum/skill/ki/Heal,new/datum/skill/Telepathy)//namekian based ranks
/*							with Namek's culture, all Elders are capable of the same things. A criacao das Esferas do Dragao NAO e mais dos ranks:
											ela e o segredo do CLA DO DRAGAO (arvore racial Namek, ver namekian.dm).
*/
datum/skill/tree/Rank/Namek/growbranches()
	if(savant.Rank!="Namekian Elder") disableskill(/datum/skill/Telepathy)
	disableskill(/datum/skill/rank/MakeDragonballs) //LEGADO: a skill saiu dos ranks Elder (agora e do Cla do Dragao) -- desliga instancias que sobraram em arvores salvas
	switch(savant.Rank)
		if("Namekian Elder")
			enableskill(/datum/skill/style/NamekStyle)
			enableskill(/datum/skill/rank/Makkankosappo)
			enableskill(/datum/skill/Enkumei)
			enableskill(/datum/skill/rank/Unlock_Potential)
			enableskill(/datum/skill/Telepathy)
			enableskill(/datum/skill/ki/Heal)
		if("Namekian Grand Elder")
			enableskill(/datum/skill/Enkumei)
			enableskill(/datum/skill/style/NamekStyle)
			enableskill(/datum/skill/rank/Appoint_Elder)
			enableskill(/datum/skill/rank/Unlock_Potential)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/ki/Heal)
	savant.LastRank=savant.Rank
	..()

/datum/skill/rank/Appoint_Elder
	skilltype = "Misc"
	name = "Appoint a Elder"
	desc = "Appoint a Elder, to the position of North, West, East, or South elder."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/Appoint_Elder/after_learn()
	assignverb(/mob/Rank/verb/Appoint_Elder)
	to_chat(savant, "You can appoint Elders!")
/datum/skill/rank/Appoint_Elder/before_forget()
	unassignverb(/mob/Rank/verb/Appoint_Elder)
	to_chat(savant, "You've forgotten how to appoint Elders?")
/datum/skill/rank/Appoint_Elder/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Appoint_Elder)

mob/Rank/verb/Appoint_Elder(var/mob/M in view(1))
	set category="Skills"
	if(M!=usr&&M.client&&M.Rank=="Namekian Elder")
		if(alert(usr,"Make [M] into a Elder?","","Yes","No")=="Yes")
			if(alert(M,"Become a Elder?","","Yes","No")=="Yes")
				switch(input(usr,"Which Namekian Elder rank?","","Generic") in list("North","South","East","West","Generic"))
					if("North")
						North_Elder=key
					if("South")
						South_Elder=key
					if("West")
						West_Elder=key
					if("East")
						East_Elder=key
				M.Rank="Namekian Elder"
				M.getTree(new /datum/skill/tree/RankTree)
			else to_chat(usr, "[M] has declined your offer.")