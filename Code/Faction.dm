mob/verb/CreateFaction()
	set category="Other"
	usr<<"Faction created."
	var/obj/Faction/A=new/obj/Faction
	A.factioncode=rand(1,1000000000)
	A.leader=1
	contents+=A
mob/var/obj/faction_ref
obj/Faction
	var/version=0 //Version goes up when leader changes something...
	var/rank=1 //2, 3... 4, leader....
	var/factioncode
	var/notes
	var/leader=0
	suffix="Rank 1" //Changes in faction update...
	verb/Name()
		set category=null
		if(rank>=4|leader)
			version+=1
			name=input("") as text
		else usr<<"This is for the faction leader only."
	verb/SwitchLeader(mob/M in world)
		set category=null
		if(leader)
			for(var/obj/Faction/A in M.contents) if(A.factioncode==factioncode)
				leader=0
				A.leader=1
				M<<"[usr] has made you the new leader of the faction..."
				usr<<"You are no longer the leader of this faction, you have given it to [M]"
			else usr<<"You can only make someone else the leader if you are the leader in the first Place."
	verb/Boot(mob/M in world)
		set category=null
		for(var/obj/Faction/A in M.contents) if(A.factioncode==factioncode)
			M<<"You have been booted from the [name] by [usr.name]"
			del(A)
	verb/Rank(mob/M in world)
		set category=null
		for(var/obj/Faction/A in M.contents) if(A.factioncode==factioncode)
			if(A.rank<rank|leader)
				usr<<"[M] is currently rank [A.rank]"
				A.rank=input("Input a rank between 1 and 4, 1 will have only basic commands, 2 will be able to recruit, 3 will be able to boot those who are lower than them, level 4 has the same powers as the leader. All ranks can rank other members but only if that members rank is lower than theirs, and they cant set the rank past what their rank is.") as num
				if(A.rank>rank&&!leader) A.rank=rank
				A.suffix="Rank [A.rank]"
			else usr<<"You cant do anything ast them their rank is higher than yours."
	verb/Icon(A as icon)
		set category=null
		if(leader)
			icon=A
			var/state=input("Enter an icon_state if any") as text
			icon_state=state
			version+=1
		else usr<<"This is for the faction leader only."
	verb/EditNotes()
		set category=null
		if(leader)
			version+=1
			notes=input("") as text
		else usr<<"This is for the leader only."
	verb/Recruit(mob/M in view(usr))
		set category=null
		if(rank>=2|leader)
			switch(input(M,"Join [name]?","",text) in list("Yes","No",))
				if("Yes")
					var/obj/Faction/A=new/obj/Faction
					A.icon=icon
					A.name=name
					A.version=version
					A.rank=1
					A.factioncode=factioncode
					A.notes=notes
					M.contents+=A
					M<<"You have recieved the faction badge of this guild, it is electronic and will update itself when it gets near another member that has a higher badge version than you. It also functions as a communicator."
					view(M)<<"[M] is now a member of the [name]"
				else view(M)<<"Has declined to join the [name]"
		else usr<<"This is for rank 2 or above."
	verb/Leave()
		set category=null
		del(src)
	verb/Notes()
		set category=null
		usr<<notes
	verb/MembersOnline()
		set category=null
		for(var/mob/M) for(var/obj/Faction/A in M.contents) if(A.factioncode==factioncode) usr<<"[M] ([M.displaykey])"
	verb/Speak(A as text)
		set category=null
		oview(usr)<<"<font color=#FF0000><font size=1>[usr] speaks into a faction badge..."
		oview(usr)<<"<[usr.SayColor]>[usr.name]: [A]"
		for(var/mob/M) for(var/obj/Faction/F in M.contents) if(F.factioncode==factioncode) M<<"<[usr.SayColor]><b>(Faction)[usr]: [A]"
mob/proc/FactionUpdate()
	for(var/obj/Faction/F in contents) for(var/mob/M in view(src))
		for(var/obj/Faction/A in M.contents) if(F.factioncode==A.factioncode)
			if(A.version>F.version)
				F.name=A.name
				F.icon=A.icon
				F.version=A.version
				F.notes=A.notes
				src<<"[M]'s faction ([A.name]) is a higher version than your faction ([F.name]), your faction has automatically been updated to their version."