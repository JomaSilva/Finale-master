world
	mob = /mob/lobby

client
	proc
		SavePlayer(Path)
			if(!istype(mob, /mob/lobby))
				var savefile/save = new (Path)
				//overlay / vis contents marrying
				var/list/prevoverlays = list()
				prevoverlays = mob.overlays
				for(var/obj/overlay/S in mob.vis_contents)
					if(S.temporary==FALSE)
						mob.overlays.Add(S)
				//
				if(mob)
					save << mob
				/*save["name"] << mob.name
				save["icon"] << mob.icon
				save["overlays"] << mob.overlays
				save["underlays"] << mob.underlays*/
				save["savefile_ver"] << savefile_ver
				mob.overlays = prevoverlays
				return TRUE
			return FALSE

		LoadPlayer(Path)
			if(fexists(Path))
				src << "Loaded!"
				winshow(usr,"characterpane[usr]",0)
				winset(usr,"characterpane[usr]","parent=none")
				var savefile/save = new (Path)
				if(save.name == 0)
					usr << "Savefile corrupted! In later versions it may allow automatic recovery. For now, contact a admin and see if they can fix it. Path: [Path]"
					winshow(usr,"Login_Pane",1)
					winshow(usr,"characterpane",0)
					winshow(usr, "balancewin", 0)
					show_verb_panel=0
					var mob/lobby/A = new
					mob = A
					return FALSE
				else
					save >> mob
					return TRUE
			return FALSE
	var
		tmp/iscreating
mob/lobby
	var/savefiles[3]
	attacking = 1
	attackable = 0
	choreoattk = 1
	Login()
		displaykey = ckey(ckey)
		name = key
		temporary = 1
		lobby_list += src
		world << "[src] has entered the lobby."
		client.show_verb_panel=0
		client.screen -= client.screen
		src << "<BIG>NEW! Report function! Check in the Other tab, available at any point!</BIG>"
		client.Title_Music()
		//player_list += src
		loginTests()
		winshow(usr,"Login_Pane",1)
		winshow(usr,"characterpane",0)

		if(fexists(GetSavePath(1)))
			savefiles[1] = TRUE
		else savefiles[1] = FALSE
		if(fexists(GetSavePath(2)))
			savefiles[2] = TRUE
		else savefiles[2] = FALSE
		if(fexists(GetSavePath(3)))
			savefiles[3] = TRUE
		else savefiles[3] = FALSE

	Logout()
		world << "[src] has left the lobby."
		lobby_list -= src
		del(src) //deletes the lobby player mob. isn't needed anyway since they already either left or is switched to their player.

	verb/loadwindow()
		if(worldloading)
			usr<<"The world is still loading"
			return
		opencharacterwindow()

	verb/startnewcharacter()
		if(worldloading)
			usr<<"The world is still loading"
			return
		if(!savefiles[1])
			create(1)
		else if(!savefiles[2])
			create(2)
		else if(!savefiles[3])
			create(3)
		else
			client << "Character creation failed! Delete a character!"
			return


	verb/showinfopane()
		src<<browse(Intro,"window=Intro;size=500x500")

	verb/dumpsave()
		if(ckey)
			usr << "[ckey(ckey)]"
			usr << "This is your ckey ckey(ckey)-afied. Usually wanna send this toward a head admin's way if you're trying to recover saves or something."


	proc/load(var/N)
		if(client.LoadPlayer(GetSavePath(N)))
		else client << "Load failed!"

	proc/create(var/N)
		if(winexists(usr,"characterpane[usr]"))
			winshow(src,"characterpane[usr]",0)
			winset(usr,"characterpane[usr]","parent=none")
		client.iscreating =1
		var/mob/player = new
		player.name = name
		player.save_path = N
		client.mob = player
		player.client = client

mob
	var/signiture //for compatibility between older versions
	var/last_login = 0
	var/tmp/had_client = 0
	Login()
		..()
		player_list += src
		last_login = round(world.realtime,100)//rounds to 10 seconds
		if(BlankPlayer)
			return
		loc = locate(xco,yco,zco)
		checkclient
		sleep(1)
		if(client)
			had_client = 1
			loginProc()
			updateseed=resolveupdate
		else goto checkclient
	proc/loginProc()
		set waitfor = 0
		winshow(src,"Login_Pane",0)
		winshow(src,"characterpane",0)
		client.TitleMusicOn=0
		client.Music_Fade()
		CHECK()
		client.show_verb_panel=1
		src << "[src] entered the game."
		displaykey = ckey(ckey)
		if(client.iscreating)
			client.iscreating = 0
			New_Character()
			if(client) client.show_verb_panel=1
		else
			if(!Created || Race == "None") //blank/incomplete character (e.g. from a corrupt save) -> route into character creation instead of dropping into the void
				New_Character()
			else
				OnLogin()
			if(client) client.show_verb_panel=1
	Logout()
		if(!isNPC && had_client)
			src << "[src] left the game."
			player_list -= src
			sleep OnLogout()
		//sleep OfflineSave()
		..()
	New_Character()
		..()
		client.show_verb_panel=0
		NewCharacter_Vars()
		NewCharacterStuff()
		OnLogin()
		if(client) client.iscreating=0
	var
		storedname
		save_path = 1
	verb/save()
		set category = "Other"
		set name = "Save"
		Revert()
		Save()

	verb/backtolobby()
		set category = "Other"
		set name= "Back to Lobby"
		sleep Save()
		sleep(2)
		winshow(usr,"Login_Pane",1)
		winshow(usr,"characterpane",0)
		winshow(usr, "balancewin", 0)
		client.show_verb_panel=0
		var mob/lobby/A = new
		client.mob = A
	verb/Backup_Save()
		set category = "Other"
		set name = "Backup Save"
		BSave()
	proc
		Save()
			set waitfor = 0
			var/list/artifactlist = list()
			for(var/obj/Artifacts/A in contents)
				if(A.ContentsDontSave)
					artifactlist += A
					A.loc = usr.loc
			if(Savable)
				xco = x
				yco = y
				zco = z
				storedname = name
				if(client.SavePlayer(GetSavePath(save_path)))
					src << "Saved!"
				var savefile/save = new (GetSavePath(save_path))
				save["name"] << name
				save["icon"] << icon
				save["overlays"] << overlays
				save["underlays"] << underlays
			for(var/obj/A in artifactlist)
				A.Move(usr)
		BSave()
			set waitfor = 0
			var/list/artifactlist = list()
			for(var/obj/Artifacts/A in contents)
				if(A.ContentsDontSave)
					artifactlist += A
					A.loc = usr.loc
			if(Savable)
				xco = x
				yco = y
				zco = z
				storedname = name
				if(client.SavePlayer(GetSaveBckup(save_path)))
					src << "Saved!"
			for(var/obj/A in artifactlist)
				A.Move(usr)
		OfflineSave()
			set waitfor = 0
			var/list/artifactlist = list()
			for(var/obj/Artifacts/A in contents)
				if(A.ContentsDontSave)
					artifactlist += A
					A.loc = usr.loc
			if(Savable&&!istype(src, /mob/lobby))
				xco = x
				yco = y
				zco = z
				storedname = name
				var savefile/save = new (GetSavePath(save_path))
				save << usr
				save["name"] << name
				save["icon"] << icon
				save["overlays"] << overlays
				save["underlays"] << underlays
			for(var/obj/A in artifactlist)
				A.Move(usr)
		GetSavePath(var/spath as num)
// If you want multiple save slots, return a variable here instead
// that contains the path to that particular save.
			if(spath)
			else spath = 1
			if(!ckey)
				return "Save/[displaykey]/save[spath].dbcsav"
			return "Save/[ckey(ckey)]/save[spath].dbcsav"
		GetSaveBckup(var/spath as num)
// If you want multiple save slots, return a variable here instead
// that contains the path to that particular save.
			if(spath)
			else spath = 1
			if(!ckey)
				return "Save/backups/[displaykey]/save[spath].dbcsav"
			return "Save/backups/[ckey(ckey)]/save[spath].dbcsav"

mob
	Read(savefile/F)
		..()
		Move(locate(xco,yco,zco))
	Write(savefile/F)
		xco = x
		yco = y
		zco = z
		storedname = name
		..()
