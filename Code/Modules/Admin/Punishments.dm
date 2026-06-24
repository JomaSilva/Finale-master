mob/Admin3/verb/Take_Skill(mob/M in world)
	set category="Admin"
	set name = "Take"
	var/varPackList = list()
	if(locate(/obj) in M:contents)
		for(var/obj/O in M:contents)
			varPackList += O
	else
		src << "[M:name] has an empty pack!"
		return
	var/varPackItem = input("Pick an item from [M:name]'s pack","Check Pack") in varPackList + list("Cancel")
	if(varPackItem != "Cancel")
		if(alert("Would you like to delete [varPackItem:name] from [M:name]'s contents?","[varPackItem:name]","Yes","No") == "Yes")
			del(varPackItem)
			WriteToLog("admin","[usr]([key]) has deleted [varPackItem:name] from [M:name]'s inventory. [time2text(world.realtime,"Day DD hh:mm")]")

mob/Admin1/verb
	Ban()
		set category="Admin"
		var/ChoiceName
		var/ChoiceKey
		var/ChoiceIP
		var/ChoiceCID
		var/list/PeopleList=new/list
		PeopleList+="Cancel"
		for(var/mob/P) if(P.client) PeopleList.Add(P.key)
		var/Choice=input("Ban who?") in PeopleList
		if(Choice=="Cancel") return
		var/Reason=input("Ban them for what reason?") as text
		for(var/mob/A)
			if(A.client&&A.key==Choice)
				ChoiceName="[A.name]"
				ChoiceKey="[A.key]"
				ChoiceIP="[A.client.address]"
				ChoiceCID="[A.client.computer_id]"
		Bans.Add(ChoiceKey,ChoiceIP)
		world<<"[ChoiceName]([ChoiceKey]) has been banned for [Reason]."
		WriteToLog("admin","[usr]([key]) BANNED [ChoiceName]([ChoiceKey]) for '[Reason]' at [time2text(world.realtime,"Day DD hh:mm")]")
		for(var/mob/M)
			if(M.key==ChoiceKey)
				del(M)
		for(var/mob/V) if(V.client&&V!=usr&&V.key!=ChoiceKey)
			var/MatchingIPs=V.client.address
			if(ChoiceIP==MatchingIPs&&ChoiceCID!=V.client.computer_id)
				world<<"--[V]([V.key]) has been banned (multikey)."
				Bans.Add(V.key)
				del(V)
		Save_Ban()
	UnBan()
		set category="Admin"
		if(Bans)
			Bans.Remove("Cancel")
			Bans+="Cancel"
			var/Choice=input("UnBan who?") in Bans
			if(Choice=="Cancel") return
			if(alert(usr,"Silent unban?","","Yes","No")=="No")
				world<<"[key] unbanned [Choice]."
			WriteToLog("admin","[usr]([key]) UNBANNED [Choice] at [time2text(world.realtime,"Day DD hh:mm")]")
			Bans.Remove(Choice)
			Save_Ban()