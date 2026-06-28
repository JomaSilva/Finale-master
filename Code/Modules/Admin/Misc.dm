mob/Admin3/verb/TakeVerb(mob/M in world)
	set name = "Take Verb"
	set category = "Admin"
	var/varVerb = input("What verb would you like to take from [M:name]?","Take Verb") in M:verbs + list("Cancel")
	if(varVerb != "Cancel")
		M:verbs -= varVerb
mob/Admin3/verb
	Make_Illegal_Race()
		set category="Admin"
		var/list/A=new/list
		A.Add("Saiyan")
		A.Add("Saibamen")
		A.Add("Tsujin")
		A.Add("Alien")
		A.Add("Yardrat")
		A.Add("Kannassa-jin")
		A.Add("Heran")
		A.Add("Kai")
		A.Add("Demon")
		A.Add("Demi-Kai")
		A.Add("Human")
		A.Add("Uchiha")
		A.Add("Shape-Shifter")
		A.Add("Makyo")
		A.Add("LSSJ")
		A.Add("Arlian")
		A.Add("Meta")
		A.Add("Frost Demon")
		A.Add("Namekian")
		A.Add("Bio-Android")
		A.Add("Cyborg")
		A.Add("Omega SP")
		A.Add("Elite Saiyan")
		A.Add("Android")
		A.Add("Majin")
		A.Add("Gray")
		A.Add("Cancel")
		A -= Illegal
		var/Choice=input("Choose Race","",text) in A
		switch(Choice)
			if("Saiyan")
				cansai=0
			if("Majin")
				canmajin=0
			if("LSSJ")
				canlegendary=0
			if("Heran")
				canheran=0
			if("Omega SP")
				canomega=0
			if("Elite Saiyan")
				canelite=0
			if("Saibamen")
				cansaib=0
			if("Tsujin")
				canintel=0
			if("Alien")
				canalien=0
			if("Yardrat")
				canyardrat=0
			if("Kannassa-jin")
				cankan=0
			if("Kai")
				cankai=0
			if("Demon")
				candemon=0
			if("Demi-Kai")
				canDemigod=0
			if("Human")
				canhuman=0
			if("Uchiha")
				canuchiha=0
			if("Shape-Shifter")
				canshape=0
			if("Makyo")
				canmakyo=0
			if("Arlian")
				canarl=0
			if("Meta")
				canmeta=0
			if("Frost Demon")
				canchangie=0
			if("Namekian")
				cannamek=0
			if("Bio-Android")
				canbio=0
			if("Android")
				candroid=0
			if("Gray")
				cangray=0
		to_chat(world, "<b><font color=yellow>Admins just made [Choice] an illegal race")
		Illegal.Add(Choice)
		Save_Ban()
	Make_Legal_Race()
		set category="Admin"
		var/list/A=new/list
		A += Illegal
		A += "Cancel"
		var/Choice=input("Choose Race","",text) in A
		switch(Choice)
			if("LSSJ")
				canlegendary=1
			if("Majin")
				canmajin=1
			if("Saiyan")
				cansai=1
			if("Omega SP")
				canomega=1
			if("Elite Saiyan")
				canelite=1
			if("Saibamen")
				cansaib=1
			if("Tsujin")
				canintel=1
			if("Alien")
				canalien=1
			if("Heran")
				canheran=1
			if("Yardrat")
				canyardrat=1
			if("Kannassa-jin")
				cankan=1
			if("Kai")
				cankai=1
			if("Demon")
				candemon=1
			if("Demi-Kai")
				canDemigod=1
			if("Human")
				canhuman=1
			if("Uchiha")
				canuchiha=2
			if("Shape-Shifter")
				canshape=1
			if("Makyo")
				canmakyo=1
			if("Arlian")
				canarl=1
			if("Meta")
				canmeta=1
			if("Frost Demon")
				canchangie=1
			if("Namekian")
				cannamek=1
			if("Bio-Android")
				canbio=1
			if("Android")
				candroid=1
			if("Gray")
				cangray=1
		to_chat(world, "<b><font color=yellow>Admins just made [Choice] a legal race")
		Illegal.Remove(Choice)
		Save_Ban()
	View_Illegal_Races()
		set category = "Admin"
		if(Illegal)
			Illegal+="Exit"
			var/Choice=input("View Illegal Races") in Illegal
			if(Choice=="Exit")
				return
proc/Save_Ban()
	var/savefile/S=new("BANS")
	S["Bans"]<<Bans
	S["Illegal"]<<Illegal
proc/Load_Ban()
	if(fexists("BANS"))
		var/savefile/S=new("BANS")
		S["Bans"]>>Bans
proc/Save_Illegal()
	var/savefile/S=new("Illegal")
	S["Illegal"]<<Illegal
proc/Load_Illegal()
	if(fexists("Illegal"))
		var/savefile/S=new("Illegal")
		S["Illegal"]>>Illegal
		if(Illegal.Find(md5("Saiyan")))
			cansai=0
		if(Illegal.Find(md5("Majin")))
			canmajin=0
		if(Illegal.Find(md5("Saibamen")))
			cansaib=0
		if(Illegal.Find(md5("Tsujin")))
			canintel=0
		if(Illegal.Find(md5("Alien")))
			canalien=0
		if(Illegal.Find(md5("Yardrat")))
			canyardrat=0
		if(Illegal.Find(md5("Kannassa-jin")))
			cankan=0
		if(Illegal.Find(md5("Half-Breed")))
			canhyb=0
		if(Illegal.Find(md5("Kai")))
			cankai=0
		if(Illegal.Find(md5("Demon")))
			candemon=0
		if(Illegal.Find(md5("Omega SP")))
			canomega=0
		if(Illegal.Find(md5("Elite Saiyan")))
			canelite=0
		if(Illegal.Find(md5("Demi-Kai")))
			canDemigod=0
		if(Illegal.Find(md5("Human")))
			canhuman=0
		if(Illegal.Find(md5("Heran")))
			canheran=0
		if(Illegal.Find(md5("Shape-Shifter")))
			canshape=0
		if(Illegal.Find(md5("Makyo")))
			canmakyo=0
		if(Illegal.Find(md5("Arlian")))
			canarl=0
		if(Illegal.Find(md5("Meta")))
			canmeta=0
		if(Illegal.Find(md5("Frost Demon")))
			canchangie=0
		if(Illegal.Find(md5("Namekian")))
			cannamek=0
		if(Illegal.Find(md5("LSSJ")))
			canlegendary=0
		if(Illegal.Find(md5("Bio-Android")))
			canbio=0
		if(Illegal.Find(md5("Android")))
			candroid=0
		if(Illegal.Find(md5("Gray")))
			cangray=0
		if(Illegal.Find(md5("Uchiha")))
			canuchiha=0

/proc/message_admins(var/msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	for(var/mob/M in mob_list)
		if(M.Admin)
			M << msg

//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
mob/Admin1/verb/cmd_admin_pm_context(mob/M as mob in view(usr))
	set category = null
	set name = "Admin PM Mob"
	if(!Admin)
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M,null)

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
mob/Admin1/verb/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!Admin)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/targetlist = list()
	for(var/client/T)
		if(T.mob)
			targetlist += T.mob
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in targetlist|null
	cmd_admin_pm(target,null)

mob/proc/cmd_ahelp_reply(var/mob/whom)
	if(Mutes.Find(key))
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return
	var/client/C
	if(istype(whom,/mob))
		C = whom.client
	else
		for(var/client/Cl)
			if(ckey(Cl.ckey) == ckey(whom))
				C = Cl
	if(!C)
		if(Admin)	to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
		return
	message_admins("[key_name_admin(src)] has started replying to [key_name(C, 0, 0)]'s admin help.")
	var/msg = input(src,"Message:", "Private message to [key_name(C, 0, 0)]") as text|null
	if(!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name(C, 0, 0)]'s admin help.")
		return
	cmd_admin_pm(C.mob, msg)

mob/proc/cmd_admin_pm(var/mob/whom, msg)
	if(Mutes.Find(key))
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return

	var/client/C
	if(istype(whom,/mob))
		C = whom.client
	else
		for(var/client/Cl)
			if(ckey(Cl.ckey) == ckey(whom))
				C = Cl
	if(!C)
		if(Admin)	to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
		else		adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [key_name(C, 0, 0)]") as text|null

		if(!msg)	return
		if(!C)
			if(Admin)	to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			else		adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if(C.mob.Admin)
		if(Admin)	//both are admins
			to_chat(C, "<font color='red'>Admin PM from-<b>[key_name(src, C, 1)]</b>: [msg]</font>")
			to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(C, src, 1)]</b>: [msg]</font>")

		else		//recipient is an admin but sender is not
			to_chat(C, "<font color='red'>Reply PM from-<b>[key_name(src, C, 1)]</b>: [msg]</font>")
			to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: [msg]</font>")

	else
		if(Admin)	//sender is an admin but recipient is not. Do BIG RED TEXT
			to_chat(C, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
			to_chat(C, "<font color='red'>Admin PM from-<b>[key_name(src, C, 0)]</b>: [msg]</font>")
			to_chat(C, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")
			to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(C, src, 1)]</b>: [msg]</font>")
			spawn()	//so we don't hold the invoker proc up
				var/sender = src
				var/sendername = key
				var/reply = input(C, msg,"Admin PM from-[sendername]", "") as text|null		//show message and await a reply
				if(C && reply)
					if(sender)
						C.mob.cmd_admin_pm(src,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return

		else		//neither are admins
			to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
			return
	WriteToLog("admin","PM: [key_name(src)]->[key_name(C)]: [msg] [time2text(world.realtime,"Day DD hh:mm")]")

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/mob/X in mob_list)
		if(X.Admin && X.key!=key && X.key!=C.key)	//check client/X is an admin and isn't the sender or recipient
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;[key_name(C, X, 0)]:</B> \blue [msg]</font>") //inform X

mob/proc/adminhelp(msg as text)
	if(client)
		client.adminhelp(msg)

/client/verb/adminhelp(msg as text)
	set category = "Other"
	set name = "Adminhelp"

	//handle muting and automuting
	if(Mutes.Find(key))
		to_chat(src, "<span class='danger'>Error: Admin-PM: You cannot send adminhelps (Muted).</span>")
		return

	if(!mob)	return						//this doesn't happen
	var/original_msg = msg
	msg = "<span class='adminnotice'><b><font color=red>HELP: </font><A HREF='?priv_msg=[ckey];ahelp_reply=1'>[key_name(src)]</A>:</b> [msg]</span>"

	//send this msg to all admins
	var/admemeheard = 0
	for(var/mob/X in mob_list)
		if(X.Admin)
			X << msg
			admemeheard += 1


	//show it to the person adminhelping too
	to_chat(src, "<span class='adminnotice'>PM to-<b>Admins</b>: [original_msg]</span>")

	//send it to irc if nobody is on and tell us how many were on

	WriteToLog("admin","HELP: [key_name(src)]: [original_msg] - heard by [admemeheard] non-AFK admins. [time2text(world.realtime,"Day DD hh:mm")]")
	return

/obj/Teleporter
	density = 0
	mouse_opacity = 0
	SaveItem=0
	var/destinationx
	var/destinationy
	var/destinationz
	New()
		..()
		for(var/obj/Teleporter/S in loc)
			if(S!=src)
				S.deleteMe()
	Cross(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/M = Obstacle
			if(isnull(destinationx)||isnull(destinationy)||isnull(destinationz))
			else M.loc = locate(destinationx,destinationy,destinationz)
		..()

mob/Admin3/verb/Create_Teleporter()
	set category = "Admin"
	to_chat(usr, "Teleporter will be created where you are at. Please input the destination coordinates.")
	var/obj/Teleporter/nT = new(loc)
	nT.destinationx = input(usr,"Input coordinates for X.") as num
	nT.destinationy = input(usr,"Input coordinates for Y.") as num
	nT.destinationz = input(usr,"Input coordinates for Z.") as num
	nT.SaveItem = 1
	switch(input(usr,"Change its icon to something custom?","") in list("Yes","Naw"))
		if("Yes")
			nT.icon = input(usr,"Input the icon.") as icon
			nT.icon_state = input(usr,"Input the icon state.") as text
			nT.pixel_x = input(usr,"Input the pixel x offset.") as num
			nT.pixel_y = input(usr,"Input the pixel y offset.") as num
	switch(input(usr,"Make it right clickable?","") in list("Yes","Naw"))
		if("Yes")
			mouse_opacity = 1

mob/Admin3/verb/Delete_Teleporter()
	set category = "Admin"
	var/list/name_list = list()
	var/list/tele_list = list()
	for(var/obj/Teleporter/nT in obj_list)
		var/a_nam = "[nT]: location: [nT.x] [nT.y] [nT.z]."
		name_list += a_nam
		tele_list[a_nam] = nT
	name_list += "Cancel"
	var/a_ind = input(usr,"Which teleporter?","") in name_list
	if(a_ind != "Cancel")
		var/obj/Teleporter/aT = tele_list[a_ind]
		del(aT)

mob/Admin3/verb/OOC_Anonymous()
	set category = "Admin"
	if(OOC_anon)
		OOC_anon = 0
		to_chat(world, "OOC is no longer anonymous")
	else
		OOC_anon = 1
		to_chat(world, "OOC is now anonymous (you don't see charcter names in OOC)")

mob/Admin2/verb/Force_All_Backup_Save()
	set category = "Admin"
	for(var/mob/M in player_list)
		if(M.loggedin)
			M.BSave()