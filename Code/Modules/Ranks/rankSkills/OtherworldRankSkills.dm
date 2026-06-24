
/datum/skill/rank/Restore_Youth
	skilltype = "Misc"
	name = "Restore Youth"
	desc = "Bring someone to the prime of their youth!"
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/Restore_Youth/after_learn()
	assignverb(/mob/Rank/verb/Restore_Youth)
	savant<<"You can restore somebody's youth!"
/datum/skill/rank/Restore_Youth/before_forget()
	unassignverb(/mob/Rank/verb/Restore_Youth)
	savant<<"You've forgotten how to restore a peron's youth!"
/datum/skill/rank/Restore_Youth/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Restore_Youth)

/datum/skill/rank/Keep_Body
	skilltype = "Misc"
	name = "Keep Body"
	desc = "Allow someone to keep their form and energy contained while dead."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/Keep_Body/after_learn()
	assignverb(/mob/Rank/verb/Keep_Body)
	savant<<"You can let someone keep their body while dead!"
/datum/skill/rank/Keep_Body/before_forget()
	unassignverb(/mob/Rank/verb/Keep_Body)
	savant<<"You've forgotten how to make someone able to keep their body!"
/datum/skill/rank/Keep_Body/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Keep_Body)

/datum/skill/rank/Dead
	skilltype = "Misc"
	name = "View Dead"
	desc = "Allows you to view who online is dead. Or, you could, y'know, look at their goddamn Halo."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/Dead/after_learn()
	assignverb(/mob/Admin1/verb/Dead)
	savant<<"You can keep track of the dead!"
/datum/skill/rank/Dead/before_forget()
	unassignverb(/mob/Admin1/verb/Dead)
	savant<<"You've forgotten how to keep track of the dead?"
/datum/skill/rank/Dead/login(var/mob/logger)
	..()
	assignverb(/mob/Admin1/verb/Dead)

/datum/skill/rank/Unlock_Potential
	skilltype = "Misc"
	name ="Unlock Potential"
	desc = "Allows you to increase the BP of somebody massively."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost =0
	enabled=0

/datum/skill/rank/Unlock_Potential/after_learn()
	assignverb(/mob/Rank/verb/Unlock_Potential)
	savant<<"You can unlock potential!"
/datum/skill/rank/Unlock_Potential/before_forget()
	unassignverb(/mob/Rank/verb/Unlock_Potential)
	savant<<"You've forgotten how to unlock potential!"
/datum/skill/rank/Unlock_Potential/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Unlock_Potential)

/datum/skill/rank/Reincarnate
	skilltype = "Misc"
	name ="Reincarnate"
	desc = "Reshape somebodys soul, and let them be reborn. Not only does this give them a fresh start at life, but it technically wipes everything, letting bad be reborn as good... or the reverse."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost =0
	enabled=0

/datum/skill/rank/Reincarnate/after_learn()
	assignverb(/mob/Rank/verb/Reincarnate_Mob)
	savant<<"You can reincarnate!"
/datum/skill/rank/Reincarnate/before_forget()
	unassignverb(/mob/Rank/verb/Reincarnate_Mob)
	savant<<"You've forgotten how to reincarnate!?"
/datum/skill/rank/Reincarnate/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Reincarnate_Mob)

/datum/skill/rank/Judge
	skilltype = "Misc"
	name ="Judge"
	desc = "When people first come to Checkpoint, they are judged. This is that ability. Choose whether or not someone is sent to Heaven or Hell."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost =0
	enabled=0

/datum/skill/rank/Judge/after_learn()
	assignverb(/mob/Rank/verb/Go_To_Heaven_Or_Hell)
	savant<<"You can judge!"
/datum/skill/rank/Judge/before_forget()
	unassignverb(/mob/Rank/verb/Go_To_Heaven_Or_Hell)
	savant<<"You've forgotten how to judge!?"
/datum/skill/rank/Judge/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Go_To_Heaven_Or_Hell)

/datum/skill/rank/Revive
	skilltype = "Misc"
	name ="Revive"
	desc = "Resurrect people from the dead. If it is somebody's second time getting resurrected like this, you must trade your life to do it."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost =2
	enabled=0
	after_learn()
		assignverb(/mob/Rank/verb/Revive)
		savant<<"You can Revive!"
	before_forget()
		unassignverb(/mob/Rank/verb/Revive)
		savant<<"You've forgotten how to Revive!?"
	login(var/mob/logger)
		..()
		assignverb(/mob/Rank/verb/Revive)

/datum/skill/rank/Ritual_of_Might
	skilltype = "Misc"
	name ="Ritual of Might"
	desc = "Create a fruit capable of dooming a planet for a power increase."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost =2
	enabled=0
	after_learn()
		savant<<"You feel your magic well up inside you!."
		savant.known_ritual_dm_types += /obj/Ritual/Ritual_of_Might_Creation
		savant.magiBuff+=0.5
		savant<<"You can now create the Fruit of the Tree of Might!"
		savant<<"The magic words are 'minmax'. You need the Essence of Space and Silverush."
	before_forget()
		savant<<"Your magic vanishes..."
		savant.known_ritual_dm_types += /obj/Ritual/Ritual_of_Might_Creation
		savant.magiBuff-=0.5

//Grand Kai
mob/Rank/verb/Restore_Youth()
	set category="Skills"
	var/mob/M=input("Which mob?","Mob") as null|mob in view(1)
	if(!M) return
	var/age=input("Restore them to what age? Between 0 and 25") as num
	if(age<0) age=0
	if(age>25) age=25
	switch(input(M,"(Offerer=[usr]) Do you want your age to be restored to [age] years?", "", text) in list ("No", "Yes",))
		if("Yes")
			M.Age=age
			M.Body=age
		if("No") usr<<"[M] declined your offer."
//All Kais
mob/Rank/verb/
	Go_To_Planet()
		set category="Skills"
		switch(input("Go to Planet", "", text) in list ("North","South","East","West","Grand","None",))
			if("North") loc=locate(170,280,9)
			if("South") loc=locate(170,50,9)
			if("East") loc=locate(260,160,9)
			if("West") loc=locate(100,180,9)
			if("Grand")
				if(Grand_Kai==key|Supreme_Kai==key) loc=locate(90,250,8)
				else usr<<"Only Supreme or Grand Kai can teleport there."
//King Yemma
mob/Rank/verb/
	Go_To_Heaven_Or_Hell()
		set category="Skills"
		switch(input("Go to Planet", "", text) in list ("Hell","Heaven","None",))
			if("Hell") loc=locate(64,290,9)
			if("Heaven") loc=locate(175,140,10)

mob/Rank/verb/Keep_Body(mob/M in view(src))
	set category="Other"
	if(!M.KeepsBody)
		M.KeepsBody=1
		usr<<"You have made it so [M] will keep their body when they die."
	else
		M.KeepsBody=0
		usr<<"You have made it so [M] will not keep their body when they die."
mob/Rank/verb/Reincarnate_Mob(mob/M in oview(usr))
	set name = "Reincarnate"
	set category="Skills"
	if(M.dead)
		switch(input(M,"[usr] has offered to help reincarnate you into another body and mind, this will purify your spirit and erase your memories, starting your life in the living world all over a. Do you want to do this?", "", text) in list ("Yes", "No",))
			if("Yes") spawn M.Reincarnate()
			if("No") view(M)<<"[M] declines being reincarnated."
	else usr<<"They are not dead..."

mob/Admin1/verb
	Dead()
		set category="Admin"
		for(var/mob/M) if(M.dead) usr<<"<font color=green>[M] is dead."

mob/Rank/verb/Revive()
	set name = "Revive"
	set category = "Skills"
	if(usr.dead)
		usr << "You can't be dead to use this!"
		return
	var/list/rezList = list()
	for(var/mob/M in get_step(usr,usr.dir))
		if(M.dead)
			rezList += M
	if(rezList.len==0) return
	if(rezList.len==1)
		var/mob/M = rezList[1]
		WriteToLog("admin","[usr]([key]) revived [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		view(usr)<<"[usr] has resurrected [M.name] from the dead!"
		M.ReviveMe()
		M.KO=0
		M.SpreadHeal(100)
		M.stamina = M.maxstamina
		M.move=1
		M.ResurrectedCount+=1
		M.icon_state=""
		M.overlayList-='Halo.dmi'
		M.overlaychanged=1
		if(M.ResurrectedCount>1)
			view(usr)<<"[usr] trades [usr]'s life for the resurrection!"
			usr.dead=1
			usr.overlayList+='Halo.dmi'
			usr.overlaychanged=1
	if(rezList.len>=2)
		rezList += "Cancel"
		var/choice = input(usr,"Multiple mobs are here. Resurrect who?") as null|anything in rezList
		if(ismob(choice))
			var/mob/M = choice
			WriteToLog("admin","[usr]([key]) revived [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
			view(usr)<<"[usr] has resurrected [M.name] from the dead!"
			M.ReviveMe()
			M.KO=0
			M.SpreadHeal(100)
			M.stamina = M.maxstamina
			M.move=1
			M.ResurrectedCount+=1
			M.icon_state=""
			M.overlayList-='Halo.dmi'
			M.overlaychanged=1
			if(M.ResurrectedCount>1)
				view(usr)<<"[usr] trades [usr]'s life for the resurrection!"
				usr.dead=1
				usr.overlayList+='Halo.dmi'
				usr.overlaychanged=1
		else return

mob/var
	ResurrectedCount