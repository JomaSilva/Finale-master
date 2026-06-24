mob/Admin2/verb/Ages()
	set category="Admin"
	for(var/mob/M) if(M.client) usr<<"[M]: [round(M.Age)] ([round(M.DeclineAge)] Decline)"

mob/OwnerAdmin/verb/Delete_File()
	set category = "Admin"
	switch(input("Which file do you wish to delete?","") in list ("Saves","Ranks","Map","Items"))
		if("Saves") fdel ("Save/")
		if("Ranks") fdel ("RANK")
		if("Map") fdel ("MapSave")
		if("Items") fdel ("ItemSave")

mob/OwnerAdmin/verb/Update_DMB(var/F as file)
	set category = "Admin"
	switch(alert(usr,"Are you sure?","","Yes","No"))
		if("Yes")
			fcopy(F,"Dragonball Climax.dmb")
			switch(alert(usr,"Reboot?","","Yes","No"))
				if("Yes")
					Restart()

mob/OwnerAdmin/verb/Update_File(var/F as file)
	set category = "Admin"
	switch(alert(usr,"Are you sure?","","Yes","No"))
		if("Yes")
			var/text = input(usr,"Target file.") as text
			if(fexists(text))
				fcopy(F,text)
				switch(alert(usr,"Reboot?","","Yes","No"))
					if("Yes")
						Restart()

mob/OwnerAdmin/verb/Restore_Save_Backup()
	set category = "Admin"
	switch(alert(usr,"Are you sure? You need the slot number of the original save.","","Yes","No"))
		if("Yes")
			var/mobkey = input(usr,"Input the mob key. It must be exact, and you must retrieve the ckey.") as text
			var/spath = input(usr,"Input the mob path num (1 to 3).") as num
			fcopy("Save/backups/[mobkey]/save[spath].dbcsav","Save/[mobkey]/save[spath].dbcsav")


mob/OwnerAdmin/verb/Restore_Map_Save_Backup()
	set category = "Admin"
	switch(alert(usr,"Are you sure? The current map will not be saved, and will be overwritten.","","Yes","No"))
		if("Yes")
			BMapLoad()

mob/OwnerAdmin/verb/Save_Map_Backup()
	set category = "Admin"
	switch(alert(usr,"Save the map to 'MapSaveBck' in the directory?","","Yes","No"))
		if("Yes")
			BMapSave()

mob/verb/Download_Save()
	set category = null
	set hidden = 1
	var savefile/F = new (GetSavePath(save_path))
	switch(alert(usr,"You're trying to download [F]. Accept? Savefiles are downloaded like this typically for backup purposes.","","Yes","No"))
		if("Yes")
			usr<<"You accepted the file"
			usr<<ftp(F)
		if("No") usr<<"You declined the file"
mob/Admin1/verb
	TransferFile(F as file,M as mob in world)
		set hidden = 1
		switch(alert(M,"[usr] is trying to send you [F] ([File_Size(F)]). Accept?","","Yes","No"))
			if("Yes")
				usr<<"[M] accepted the file"
				M<<ftp(F)
			if("No") usr<<"[M] declined the file"
	Make_Item_Save(obj/nF in view(10))
		set category = "Admin"
		nF.SaveItem = 1

mob/Admin3/verb
	Mutate(mob/M in world)
		set category = "Admin"
		set name = "Mutate"
		switch(input("Are you sure? This randomly adds or subtracts from their mods, may increase their BP by exponential levels, and make them extremely powerful.", "Mutate", text) in list ("Yes","Cancel"))
			if("Yes")
				M.AdminMutate()
			if("Cancel")
				return
	Delete_Player_Save(mob/M in world)
		set category = "Admin"
		if(!M.client) return
		switch(input("Are you sure?", "Delete", text) in list ("Yes","Cancel"))
			if("Yes")
				if(fexists(GetSavePath(M.save_path))) fdel(GetSavePath(M.save_path))
				world<<"[usr] deleted [M.displaykey]'s save."
				del(M)
			if("Cancel")
				return
	Server_Description()
		set category = "Admin"
		server_desc = input(usr,"What will show up on the hub/pager for your server name?","Server Name/Description",server_desc) as text
		world.status="[world.status] Dragonball Climax: Hosting: [world.host], version [gameversion]:[server_desc]"
	Delete_All_of_Type()
		set category = "Admin"
		set background = 1
		switch(input("Are you sure?", "Delete", text) in list ("Yes","Cancel"))
			if("Yes")
				switch(input("Types:","Delete","Cancel") in list("Trees","Plants","Reincarnation Trees","Custom","Spacepod","Cancel"))
					if("Custom")
						var/deltype = text2path(input(usr,"Enter the type path perfectly."))
						if(deltype)
							for(var/obj/A in world)
								sleep(0.5)
								if(istype(A,deltype))
									A.deleteMe()
					if("Trees")
						for(var/obj/Trees/P in world)
							P.deleteMe()
					if("Plants")
						for(var/obj/Plants/P in world)
							P.deleteMe()
					if("Reincarnation Trees")
						for(var/obj/Reincarnation_Tree/A in world)
							A.deleteMe()
					if("Spacepod")
						for(var/obj/Spacepod/A in world)
							A.deleteMe()
					if("Planet")
						for(var/obj/Planets/A in world)
							A.deleteMe()

mob/Admin2/verb/View_Skill_Stats()
	set category = "Admin"
	var/list/moblist = new
	for(var/mob/M in mob_list)
		moblist += M
	var/mob/choice = input(usr,"Choose a mob.") as null|anything in moblist
	if(ismob(choice))
		switch(alert(usr,"Tree or Skills.","","Trees","Skills","No"))
			if("Trees")
				var/list/treelist = list()
				for(var/datum/skill/tree/T in choice.possessed_trees)
					treelist += T
				var/datum/skill/tree/sT = input(usr,"Which tree?") as null|anything in treelist
				if(isnull(sT)) return
				else if(istype(sT,/datum/skill/tree))
					usr << "Tree Name: [sT.name]"
					usr << "Tree Desc: [sT.desc]"
					usr << "Tree Max Tier:[sT.maxtier]"
					usr << "Tree Enabled:[sT.enabled]"
					switch(input(usr,"Manipulate?") in list("Cancel","Delete","Toggle Enabled","Reset"))
						if("Delete")
							del(sT)
						if("Toggle Enabled")
							if(sT.enabled)
								sT.enabled = 0
							else sT.enabled = 1
						if("Reset")
							sT.constituentskills = initial(sT.constituentskills)
					for(var/datum/skill/A in sT.constituentskills)
						usr << "Skill Name: [A.name]"
						usr << "Skill Enabled: [A.enabled]"
						switch(input(usr,"Manipulate?") in list("Cancel","Delete","Toggle Enabled"))
							if("Delete")
								del(A)
							if("Toggle Enabled")
								if(A.enabled)
									A.enabled = 0
								else A.enabled = 1
			if("Skills")
				for(var/datum/skill/A in learned_skills)
					usr << "Skill Name: [A.name]"
					usr << "Skill Enabled: [A.enabled]"
					usr << "Skill Level: [A.level]"
					usr << "Skill Exp: [A.exp]"
					switch(input(usr,"Manipulate?") in list("Cancel","Delete","Toggle Enabled"))
						if("Delete")
							del(A)
						if("Toggle Enabled")
							if(A.enabled)
								A.enabled = 0
							else A.enabled = 1
				return
	else
		return