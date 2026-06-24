mob/lobby/proc/refreshwindow(var/W)
	var/chartext=list("Empty","Empty","Empty")
	var/icon/nocharacter = 'BaseWhiteMale.dmi'
	var/icon/iconlist[3]
	var/nametext=list("No Character","No Character","No Character")
	var/obj/viewer/a = new
	a.icon = nocharacter
	iconlist[1] = a
	iconlist[2] = a
	iconlist[3] = a

	if(fexists(GetSavePath(1)))
		var/nameicon[4]
		nameicon = getSaveNameandIcon(GetSavePath(1))
		chartext[1] = "Load"
		var/obj/viewer = new
		viewer.icon = nameicon[2]
		viewer.overlays = nameicon[3]
		viewer.underlays = nameicon[4]
		iconlist[1] = viewer
		nametext[1] = "Name: [nameicon[1]], Status:"

	if(fexists(GetSavePath(2)))
		var/nameicon[4]
		nameicon = getSaveNameandIcon(GetSavePath(2))
		chartext[2] = "Load"
		var/obj/viewer = new
		viewer.icon = nameicon[2]
		viewer.overlays = nameicon[3]
		viewer.underlays = nameicon[4]
		iconlist[2] = viewer
		nametext[2] = "Name: [nameicon[1]], Status:"

	if(fexists(GetSavePath(3)))
		var/nameicon[4]
		nameicon = getSaveNameandIcon(GetSavePath(3))
		chartext[3] = "Load"
		var/obj/viewer = new
		viewer.icon = nameicon[2]
		viewer.overlays = nameicon[3]
		viewer.underlays = nameicon[4]
		iconlist[3] = viewer
		nametext[3] = "Name: [nameicon[1]], Status:"

	winset(usr,"[W].multipurpose1","text=[chartext[1]]")
	winset(usr,"[W].multipurpose2","text=[chartext[2]]")
	winset(usr,"[W].multipurpose3","text=[chartext[3]]")
	winset(usr,"[W].label1","text=\"[nametext[1]]\"")
	winset(usr,"[W].label2","text=\"[nametext[2]]\"")
	winset(usr,"[W].label3","text=\"[nametext[3]]\"")
	src<<output(iconlist[1],"[W].charactergrid1:1,1")
	src<<output(iconlist[2],"[W].charactergrid2:1,1")
	src<<output(iconlist[3],"[W].charactergrid3:1,1")
	checkwindow
	spawn(5)
		if(winexists(usr,W))
			goto checkwindow
		else
			del(iconlist[1])
			del(iconlist[2])
			del(iconlist[3])


mob/lobby/proc/getSaveNameandIcon(Path)
	if(fexists(Path))
		var savefile/save = new (Path)
		var/list/nameicon[4]
		save["name"] >> nameicon[1]
		save["icon"] >> nameicon[2]
		save["overlays"] >> nameicon[3]
		save["underlays"] >> nameicon[4]
		return nameicon

obj/viewer
	IsntAItem=1

mob/lobby/proc/opencharacterwindow()
	winclone(usr,"characterpane","characterpane[usr]")
	refreshwindow("characterpane[usr]")
	winshow(usr,"characterpane[usr]",1)

mob/lobby/verb
	loadchar1()
		set hidden = 1
		load(1)

	loadchar2()
		set hidden = 1
		load(2)

	loadchar3()
		set hidden = 1
		load(3)

	delete1()
		set hidden = 1
		deletecharacter(1)

	delete2()
		set hidden = 1
		deletecharacter(2)

	delete3()
		set hidden = 1
		deletecharacter(3)


mob/lobby/proc/deletecharacter(var/N)
	switch(alert("Delete this file?","","Yes","No"))
		if("Yes")
			if(fexists(GetSavePath(N)))
				fdel(GetSavePath(N))
				savefiles[N] = FALSE
				client <<"Delete successful."
				if(winexists(usr,"characterpane[usr]"))
					winshow(src,"characterpane[usr]",0)
					winset(usr,"characterpane[usr]","parent=none")
				//delete_Custom_Proto("[ckey]",N)
				spawn(5) opencharacterwindow()
				if(fexists(GetSavePath(1)))
					savefiles[1] = TRUE
				else savefiles[1] = FALSE
				if(fexists(GetSavePath(2)))
					savefiles[2] = TRUE
				else savefiles[2] = FALSE
				if(fexists(GetSavePath(3)))
					savefiles[3] = TRUE
				else savefiles[3] = FALSE
				return
			client<<"Delete failed! Contact server admin for manual deletion! (Or the savefile doesn't exist anyway.)"