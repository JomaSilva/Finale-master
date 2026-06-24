var
	list/templates = list()
proc/dun_map_index_templates()
	var/list/templist = list()
	templates = list()
	templist = flist("Maps/dungeons/")
	for(var/i = 1, i <= templist.len, i++)
		//OutputDebug("gethere1 repeat")
		//OutputDebug("gethere1 repeat: [templist[i]]")
		if(templist[i] == "donotenable.txt") continue
		if(findtext(templist[i],".txt"))
		//	OutputDebug("gethere1 indexed [templist[i]]")
			templates += copytext(templist[i],1,-4)//index file
		else continue
	return

proc/check_dun_map_index_template(var/name)
	if(fexists("Maps/dungeons/"+name))
		return TRUE
	return FALSE

mob/Admin3/verb/Dungeon_Manipulation()
	set category = "Admin"
	switch(input(usr,"What operation? To add a dungeon, ensure it's in the 'Maps/dungeons/' directory.") in list("Add dungeon template.","Remove a dungeon template.","Check templates.","Remove a dungeon.","Add a dungeon.","Reset dungeon.","Create dungeon template from Z-Level.","Cancel"))
		if("Add dungeon template.")
			var/F = input(usr, "Select a file.") as file
			var/text = input(usr,"Target file name? Make sure there is a .dmm or .txt at the end. This is automatically placed into the dungeons directory.") as text
			fcopy(F,"Maps/dungeons/" + text)
		if("Remove a dungeon template.")
			var/text = input(usr,"Target file name? Make sure there is a .dmm at the end. This is automatically searched in the dungeons directory.") as text
			if(fexists("Maps/dungeons/" + text))
				fdel("Maps/dungeons/" + text)
		if("Check templates.")
			dun_map_index_templates()
			check_valid_dungeons()
		if("Remove a dungeon.")
			var/list/cuslist = dun_list
			cuslist += "Cancel"
			var/obj/dungeon/nD = input(usr,"Select a dungeon.") in cuslist
			if("Cancel"!=nD&&istype(nD,/obj/dungeon))
				nD.dungeon_delete()

		if("Add a dungeon.")
			mob_dungeon_Add()
		if("Reset dungeon.")
			var/list/cuslist = dun_list
			cuslist += "Cancel"
			var/obj/dungeon/nD = input(usr,"Select a dungeon.") in cuslist
			if("Cancel"!=nD&&istype(nD,/obj/dungeon))
				nD.dungeon_reset()
		if("Create dungeon template from Z-Level.")
			var/targZ = input(usr,"Target Z-Level? This will capture the entire z-level! Dungeons must be 125x125, and should have a respective 'dungeon' coded into the dungeon map index!") as num
			if(targZ && world.maxz >= targZ)
				var/dunname = input(usr,"Name? .dmm will be automatically appended to the end of the file.") as text
				var/dmm_suite/suite = new()
				file("Maps/dungeons/[dunname].dmm") << suite.write_map(locate(1,1,targZ),locate(125,125,targZ),16) //DMM_IGNORE_PLAYERS

mob/proc/mob_dungeon_Add()
	var/file = input(usr,"File name of dungeon txt file? Do not include .map or .txt! Make sure both .map and .txt files exist properly or your dungeon may glitch!") as text
	if(fexists("Maps/dungeons/" + file + ".txt"))
		var/adx = input(usr,"What x coordinate?") as num
		var/ady = input(usr,"What y coordinate?") as num
		var/adz = input(usr,"What z coordinate?") as num
		var/obj/dungeon/nD =  new(locate(adx,ady,adz))
		var/list/dun_save_list = json_decode(file2text("Maps/dungeons/" + file + ".txt"))
		nD.dungeon_coord[1] = adx
		nD.dungeon_coord[2] = ady
		nD.dungeon_coord[3] = adz
		nD.dungeon_load(dun_save_list)

proc/add_Dungeon(var/loca,var/name = null)
	var/list/coordinates = list(0,0,0)
	if(isnull(loca)) return FALSE
	if(isturf(loca))
		var/turf/t = loca
		coordinates[1] = t.x
		coordinates[2] = t.y
		coordinates[3] = t.z
	else
		coordinates = loca
		if(coordinates.len != 3) return FALSE
	if(fexists("Maps/dungeons/" + name + ".txt"))
		var/obj/dungeon/nD =  new(locate(coordinates[1],coordinates[2],coordinates[3]))
		var/list/dun_save_list = json_decode(file2text("Maps/dungeons/" + name + ".txt"))
		nD.dungeon_coord[1] = coordinates[1]
		nD.dungeon_coord[2] = coordinates[2]
		nD.dungeon_coord[3] = coordinates[3]
		nD.dungeon_load(dun_save_list)

proc/sift_valid_dungeon_maps()
	var/list/valid_dungeons = list()
	//OutputDebug("sift here0")
	dun_map_index_templates()
	//OutputDebug("sift here1")
	//OutputDebug("sift here1 [templates.len]")
	for(var/i = 1, i <= templates.len, i++)
	//	OutputDebug("sift here2.5[templates[i]]")
		if(templates[i] == "donotenable.txt") continue
		var/dun_save_list = json_decode(file2text("Maps/dungeons/" + templates[i] + ".txt"))
	//	OutputDebug("sift here3.5")
		valid_dungeons.len++
	//	OutputDebug("sift here4.5")
		valid_dungeons[i] = dun_save_list
		valid_dungeons[i]["dungeon_file_name"] = templates[i]
		//OutputDebug("[i] : [valid_dungeons[i]]")
	//OutputDebug("sift here2")
	//for(var/I in valid_dungeons)
	//	OutputDebug("[I]")
	//OutputDebug("sift here3")
	return valid_dungeons

proc/check_valid_dungeons()
	var/list/valid_dungeons = sift_valid_dungeon_maps()
	//OutputDebug("sift here4")
	if(isnull(valid_dungeons)||!valid_dungeons.len)
	//	OutputDebug("gethere valid")
		return FALSE
	for(var/i = 1,i <= valid_dungeons.len, i++)
	//	OutputDebug("dungeon 2:[valid_dungeons[i]]")
		if(validate_dungeon(valid_dungeons[i]))
			//OutputDebug("removing dungeon:[valid_dungeons[i]]")
			valid_dungeons -= valid_dungeons[i]
	//for(var/I in valid_dungeons)
	//	OutputDebug("[I]")
	return valid_dungeons

proc/validate_dungeon(list/dngn_eval)
	//OutputDebug("removing dungeon: test 1: [dngn_eval["map_file"]] and [findtext(dngn_eval["map_file"],".map",-4)]")
	//OutputDebug("removing dungeon: test 1: [dngn_eval["map_file"]] and [fexists("Maps/dungeons/"+dngn_eval["map_file"])]")
	if(findtext(dngn_eval["map_file"],".dmm",-4)&&fexists("Maps/dungeons/[dngn_eval["map_file"]]"))
	//	OutputDebug("removing dungeon: test 2: [dungeon_bpcheck(dngn_eval["targetBP"])] and [dngn_eval["targetBP"]]")
		if(!dungeon_bpcheck(dngn_eval["targetBP"])) return FALSE
		if(dngn_eval["semi_perm"]) return FALSE
		return TRUE
	return FALSE

proc/dungeon_bpcheck(num)
	if(AverageBP >= num) return TRUE
	else return FALSE