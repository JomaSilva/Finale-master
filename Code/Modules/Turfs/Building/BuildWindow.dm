
mob/proc
	Build_Window_Int()
		if(!isobj(TileSelection)||isnull(TileSelection))
			var/obj/BuildWindowTmp/A = new
			A.name = "wall"
			A.icon = 'Turf1.dmi'
			A.icon_state = "wall"
			A.buildtype = /turf/build/wall
			TileSelection = A
			buildwindowtmpobjects += A

		if(!isobj(DecorSelection)||isnull(DecorSelection))
			var/obj/BuildWindowTmp/A = new
			A.name = "flowers"
			A.icon = 'Turfs 1.dmi'
			A.icon_state = "flowers"
			A.buildtype = /obj/buildables/flowers
			DecorSelection = A
			buildwindowtmpobjects += A

		if(!isobj(BarrierSelection)||isnull(BarrierSelection))
			var/obj/BuildWindowTmp/A = new
			A.name = "Edge1N"
			A.icon = 'Edges.dmi'
			A.icon_state = "1"
			A.buildtype = /obj/barrier/Edges/Edge1N
			BarrierSelection = A
			buildwindowtmpobjects += A

		if(!isnull(CTileSelection))
			var/obj/BuildWindowTmp/A = new
			A.name = "Tile"
			A.icon = CTileSelection.icon
			A.icon_state = CTileSelection.icon_state
			buildwindowtmpobjects += A
			winset(usr,"BuildListWindow.CustomTileGrid","cells=0")
			usr << output(A,"BuildListWindow.CustomTileGrid")
			winset(usr,"BuildListWindow.CustomTileLabel","text=\"C-Tile: [A.name]\"")

		if(!isnull(CDecorSelection))
			var/obj/BuildWindowTmp/A = new
			A.name = "Decor"
			A.icon = CDecorSelection.icon
			A.icon_state =CDecorSelection.icon_state
			buildwindowtmpobjects += A
			winset(usr,"BuildListWindow.CustomDecorGrid","cells=0")
			usr << output(A,"BuildListWindow.CustomDecorGrid")
			winset(usr,"BuildListWindow.CustomDecorLabel","text=\"C-Decor: [A.name]\"")

		if(!isnull(CBarrierSelection))
			var/obj/BuildWindowTmp/A = new
			A.name = "Barrier"
			A.icon =  CBarrierSelection.icon
			A.icon_state = CBarrierSelection.icon_state
			buildwindowtmpobjects += A
			winset(usr,"BuildListWindow.CustomBarrierGrid","cells=0")
			usr << output(A,"BuildListWindow.CustomBarrierGrid")
			winset(usr,"BuildListWindow.CustomBarrierLabel","text=\"C-Barrier: [A.name]\"")

		winset(usr,"BuildListWindow.BarrierGrid","cells=0")
		winset(usr,"BuildListWindow.DecorGrid","cells=0")
		winset(usr,"BuildListWindow.TileGrid","cells=0")
		usr << output(BarrierSelection,"BuildListWindow.BarrierGrid")
		usr << output(DecorSelection,"BuildListWindow.DecorGrid")
		usr << output(TileSelection,"BuildListWindow.TileGrid")
		winset(usr,"BuildListWindow.TileLabel","text=\"Tile: [TileSelection.name]\"")
		winset(usr,"BuildListWindow.DecorLabel","text=\"Decor: [DecorSelection.name]\"")
		winset(usr,"BuildListWindow.BarrierLabel","text=\"Barrier: [BarrierSelection.name]\"")


	Close_Build_Window()
		contents -= /obj/buildwindow
		winshow(usr, "BuildListWindow",0)
		buildwindowtmpobjects = list()
		inAwindow = 0
		isbuilding = 0
		iscustombuilding = 0

	Build_Window_selectType(buildtype,typetype,inname,inicon,inicon_state)
		var/obj/BuildWindowTmp/A = new
		A.name = inname
		A.icon = inicon
		A.icon_state = inicon_state
		A.buildtype = buildtype
		switch(typetype)
			if(1)
				TileSelection = A
			if(2)
				DecorSelection = A
			if(3)
				BarrierSelection = A

	selection_Window_Int(typetype)
		Close_Build_Window()
		usr.inAwindow = 1
		isbuilding = 0
		winshow(usr, "MultipurposeGrid",1)
		winset(usr,"MultipurposeGrid.multipurposegrid","cells=0")
		winset(usr,"MultipurposeGrid.multipurposelabel","text=\"Click on a tile/object to select that object for the build slot.\"")
		var/count0 = 0
		switch(typetype)
			if(1)
				var/targpath = /turf/build
				for(var/T in typesof(targpath))
					if(initial(T?:canbuild)&&techskill>=initial(T?:techlevel)&&T!=/turf/build&&!isnull(initial(T?:icon)))
						var/obj/BuildWindowSelect/C = new
						C.name = initial(T?:name)
						C.icon = initial(T?:icon)
						C.icon_state = initial(T?:icon_state)
						C.buildtype = T
						C.typetype = typetype
						usr << output(C,"MultipurposeGrid.multipurposegrid: [++count0]")
						buildwindowtmpobjects += C
					else continue
			if(2)
				for(var/O in typesof(/obj/buildables,/obj/Alchemy/Alchemy_Station,/obj/Enchanting/Enchanting_Table,/obj/Crafting/Forge,/obj/Crafting/Craftsman_Bench,/obj/Technology/Research_Station))
					if(initial(O?:canbuild)&&techskill>=initial(O?:techlevel)&&O!=/obj/buildables&&!isnull(initial(O?:icon)))
						var/obj/BuildWindowSelect/C = new
						C.name = initial(O?:name)
						C.icon = initial(O?:icon)
						C.icon_state = initial(O?:icon_state)
						C.buildtype = O
						C.typetype = typetype
						usr << output(C,"MultipurposeGrid.multipurposegrid: [++count0]")
						buildwindowtmpobjects += C
					else continue
			if(3)
				for(var/O in typesof(/obj/barrier))
					if(initial(O?:canbuild)&&techskill>=initial(O?:techlevel)&&O!=/obj/barrier&&!isnull(initial(O?:icon)))
						var/obj/BuildWindowSelect/C = new
						C.name = initial(O?:name)
						C.icon = initial(O?:icon)
						C.icon_state = initial(O?:icon_state)
						C.buildtype = O
						C.typetype = typetype
						usr << output(C,"MultipurposeGrid.multipurposegrid: [++count0]")
						buildwindowtmpobjects += C
					else continue

	selection_Window_Close()
		winshow(usr, "MultipurposeGrid",0)
		inAwindow = 0
		isbuilding = 0
		iscustombuilding = 0
		Build_Window_Int()
		winshow(usr, "BuildListWindow",1)
		usr.inAwindow = 1
		contents += new/obj/buildwindow


mob/verb
	OpenBuildWindow()
		set category = null
		set hidden = 1
		if(!usr||!buildable||inAwindow) return FALSE
		winshow(usr, "BuildListWindow",1)
		usr.inAwindow = 1
		isbuilding = 0
		Build_Window_Int()
		contents += new/obj/buildwindow

	Change_Layer(obj/O as obj in world)
		set hidden = 1
		if(O.proprietor != usr.ckey) return
		var/layer = input(usr,"What layer would you like this object to be on?",O.layer) as num
		if(layer > 1000) layer = 1000
		if(layer < 3) layer = 3
		O.layer = layer
mob/var/tmp
	obj/BuildWindowCustm/CTileSelection = null
	obj/BuildWindowCustm/CDecorSelection = null
	obj/BuildWindowCustm/CBarrierSelection = null
	iscustombuilding = 0
	obj/BuildWindowTmp/TileSelection = null
	obj/BuildWindowTmp/DecorSelection = null
	obj/BuildWindowTmp/BarrierSelection = null
	buildbrushsize = 0
	list/buildwindowtmpobjects = list()
	buildinout = 0

obj/buildwindow
	IsntAItem = 1
	verb
		buildwindowdone()
			set hidden = 1
			usr.Close_Build_Window()
			winshow(usr, "SkillTreeWindow",0)
			usr.inAwindow = 0
			usr.iscustombuilding = 0
			usr.isbuilding = 0
			usr.buildwindowtmpobjects = list()

		buildwindowtoggle()
			set hidden = 1
			if(usr.buildbrushsize) usr.buildbrushsize = 0
			else usr.buildbrushsize = 1
			var/text1 = "1x1"
			var/txt2 = "Inside"
			if(usr.buildbrushsize)
				text1 = "3x3"
			if(usr.buildinout)
				txt2 = "Outside"
			winset(usr,"BuildListWindow.brushinoutlabel","text=\"Brush Size: [text1]\nTiles are [txt2]!\"")

		buildwindowtoggleio()
			set hidden = 1
			if(usr.buildinout) usr.buildinout = 0
			else usr.buildinout = 1
			var/text1 = "1x1"
			var/txt2 = "Inside"
			if(usr.buildbrushsize)
				text1 = "3x3"
			if(usr.buildinout)
				txt2 = "Outdoors"
			winset(usr,"BuildListWindow.brushinoutlabel","text=\"Brush Size: [text1]\nTiles are [txt2]!\"")

		buildwindowchange3() //Barrier Change Type
			set hidden = 1
			usr.selection_Window_Int(3)

		buildwindowchange2()
			set hidden = 1
			usr.selection_Window_Int(2)

		buildwindowchange1()
			set hidden = 1
			usr.selection_Window_Int(1)

		buildwindowchange4()
			set hidden = 1
			usr.CTileSelection = new
			usr.CTileSelection.icon = input(usr,"","Choose a Icon") as icon
			if(usr.CTileSelection.icon)
				var/icon/nI = icon(usr.CTileSelection.icon)
				var/testH = nI.Height()
				var/testW = nI.Width()
				if(isnull(testH)||isnull(testW))
					usr.CTileSelection = null
					return
				if(testW!=32||testH!=32)
					usr.CTileSelection = null
					usr << "Tile icons can't be bigger or smaller than 32 by 32."
					return
			usr.CTileSelection.icon_state = input(usr,"Icon state?") as text
			if(alert(usr,"Is this tile a door? Doors need a 'Open' state and a 'Closed' state! ","","Yes","No")=="Yes")
				usr.CTileSelection.isDoor = 1
			else if(alert(usr,"Is this tile a wall? (Dense, but can see through.)","","Yes","No")=="Yes")
				usr.CTileSelection.isWall = 1
			else if(alert(usr,"Is this tile a roof? (Dense, can't see through.)","","Yes","No")=="Yes")
				usr.CTileSelection.isRoof = 1
			usr.Build_Window_Int()

		buildwindowchange5()
			set hidden = 1
			usr.CDecorSelection = new
			usr.CDecorSelection.icon = input(usr,"","Choose a Icon") as icon
			if(usr.CDecorSelection.icon)
				var/icon/nI = icon(usr.CDecorSelection.icon)
				var/testH = nI.Height()
				var/testW = nI.Width()
				if(isnull(testH)||isnull(testW))
					usr.CDecorSelection = null
					return
				if(testW>512||testH>=512)
					usr.CDecorSelection = null
					usr << "Decor icons can't be bigger than 512 pixels."
					return
			usr.CDecorSelection.icon_state = input(usr,"Icon state?") as text
			usr.CDecorSelection.name = input(usr,"Name?") as text
			usr.Build_Window_Int()

		buildwindowchange6()
			set hidden = 1
			usr.CBarrierSelection = new
			usr.CBarrierSelection.icon = input(usr,"","Choose a Icon") as icon
			usr.CBarrierSelection.icon_state = input(usr,"Icon state?") as text
			if(usr.CBarrierSelection.icon)
				var/icon/nI = icon(usr.CBarrierSelection.icon)
				var/testH = nI.Height()
				var/testW = nI.Width()
				if(isnull(testH)||isnull(testW))
					usr.CBarrierSelection = null
					return
				if(testW>512||testH>=512)
					usr.CBarrierSelection = null
					usr << "Barrier icons can't be bigger than 512 pixels."
					return
			switch(input(usr,"Select a direction for the barrier. (Note: North/South are basically the same. Use south if you know what you're doing.)") in list("Cancel","North","West","East","South"))
				if("North")
					usr.CBarrierSelection.dir = NORTH
					usr.CBarrierSelection.barrierN_E =list(SOUTH,SOUTHWEST,SOUTHEAST)
					usr.CBarrierSelection.barrierN_L =list(NORTH,NORTHWEST,NORTHEAST)
				if("West")
					usr.CBarrierSelection.dir = WEST
					usr.CBarrierSelection.barrierN_E =list(EAST,SOUTHEAST,NORTHEAST)
					usr.CBarrierSelection.barrierN_L =list(WEST,SOUTHWEST,NORTHWEST)
				if("South")
					usr.CBarrierSelection.dir = SOUTH
					usr.CBarrierSelection.barrierN_E =list(NORTH,NORTHWEST,NORTHEAST)
					usr.CBarrierSelection.barrierN_L =list(SOUTH,SOUTHWEST,SOUTHEAST)
				if("East")
					usr.CBarrierSelection.dir = EAST
					usr.CBarrierSelection.barrierN_E =list(WEST,SOUTHWEST,NORTHWEST)
					usr.CBarrierSelection.barrierN_L =list(EAST,SOUTHEAST,NORTHEAST)
			usr.Build_Window_Int()

		buildwindow1()
			set hidden = 1
			usr.iscustombuilding = 0
			usr.buildpath = usr.TileSelection.buildtype
			usr << "Building on! Set!"
			usr.isbuilding = 1

		buildwindow2()
			set hidden = 1
			usr.iscustombuilding = 0
			usr.buildpath = usr.DecorSelection.buildtype
			usr << "Building on! Set!"
			usr.isbuilding = 1

		buildwindow3()
			set hidden = 1
			usr.iscustombuilding = 0
			usr.buildpath = usr.BarrierSelection.buildtype
			usr << "Building on! Set!"
			usr.isbuilding = 1

		buildwindow4()
			set hidden = 1
			usr.buildpath = /turf/build/wall
			usr.iscustombuilding = 1
			usr << "Building on! Set!"
			usr.isbuilding = 1

		buildwindow5()
			set hidden = 1
			usr.buildpath = /obj/buildables/flowers
			usr.iscustombuilding = 2
			usr << "Building on! Set!"
			usr.isbuilding = 1

		buildwindow6()
			set hidden = 1
			usr.buildpath = /obj/barrier
			usr.iscustombuilding = 3
			usr << "Building on! Set!"
			usr.isbuilding = 1

		Change_Layer()
			set hidden = 1
			var/list/objlist = list()
			for(var/obj/uO in view(3))
				if(uO.proprietor == usr.ckey)
					objlist += uO
			if(objlist.len)
				var/obj/O = input(usr,"Which object?") as null|anything in objlist
				if(isobj(O))
					var/nlayer = input(usr,"What layer would you like this object to be on?","",O.layer) as num
					if(nlayer > 1000) nlayer = 1000
					if(nlayer < 3) nlayer = 3
					O.layer = nlayer


obj/BuildWindowTmp
	name = "Tile"
	var/buildtype
	IsntAItem=1

obj/BuildWindowSelect
	name = "Tile"
	var/buildtype
	var/typetype
	IsntAItem=1
	Click()
		usr.Build_Window_selectType(buildtype,typetype,name,icon,icon_state)
		usr.selection_Window_Close()

obj/BuildWindowCustm
	name = "Custom"
	IsntAItem=1
	var/typetype
	//Tiles
	var/isDoor
	var/isWall
	var/isRoof
	//Barriers
	//dir (Direction for barriers)
	var/list/barrierN_E = list() //(No Enter list.)
	var/list/barrierN_L = list()//(No Leave list.)




/*
window "MultipurposeGrid"
	elem "MultipurposeGrid"
	elem "multipurposelabel"
		type = LABEL
		text = " TEXT:"
	elem "multipurposegrid"
		type = GRID
window "BuildListWindow"
	elem "BuildListWindow"
	elem "BarrierChange"
		type = BUTTON
		text = "Change"
		command = "buildwindowchange3"
	elem "DecorChange"
		type = BUTTON
		text = "Change"
		command = "buildwindowchange2"
	elem "TileChange"
		type = BUTTON
		text = "Change"
		command = "buildwindowchange1"
	elem "custom_barrier_icon"
		type = BUTTON
		text = "Icon"
		command = "buildwindowchange6"
	elem "custom_decor_icon"
		type = BUTTON
		text = "Icon"
		command = "buildwindowchange5"
	elem "custom_tile_icon"
		type = BUTTON
		text = "Icon"
		command = "buildwindowchange4"
	elem "custom_barrier_build"
		type = BUTTON
		text = "Build"
		command = "buildwindow6"
	elem "custom_decor_build"
		type = BUTTON
		text = "Build"
		command = "buildwindow5"
	elem "custom_tile_build"
		type = BUTTON
		text = "Build"
		command = "buildwindow4"
	elem "barrier_build"
		type = BUTTON
		text = "Build"
		command = "buildwindow3"
	elem "decor_build"
		type = BUTTON
		text = "Build"
		command = "buildwindow2"
	elem "tile_build"
		type = BUTTON
		text = "Build"
		command = "buildwindow1"
	elem "CustomBarrierGrid"
		type = GRID
	elem "CustomDecorGrid"
		type = GRID
	elem "CustomBarrierLabel"
		type = LABEL
		text = "C-Barrier:"
	elem "CustomDecorLabel"
		type = LABEL
		text = "C-Decor:"
	elem "CustomTileLabel"
		type = LABEL
		text = "C-Tile:"
	elem "CustomTileGrid"
		type = GRID
	elem "BarrierGrid"
		type = GRID
	elem "DecorGrid"
		type = GRID
	elem "BarrierLabel"
		type = LABEL
		text = "Barrier:"
	elem "DecorLabel"
		type = LABEL
		text = "Decor:"
	elem "TileLabel"
		type = LABEL
		text = "Tile:"
	elem "TileGrid"
		type = GRID
	elem "donebutton"
		type = BUTTON
		text = "Done"
		command = "buildwindowdone"
*/