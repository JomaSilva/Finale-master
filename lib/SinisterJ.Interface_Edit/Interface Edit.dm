//The ignore list contains all the variables you dont want being edited under any circumstances
#define DEBUG
var/list/EditIgnore=list("EditVar","Editing","InEdit","locs","bounds","key","ckey","step_x","step_y","step_size","bound_x","bound_y","bound_width","bound_height","glide_size","screen_loc","animate_movement","pixel_step_size","see_infrared","client","maptext_x","maptext_y","color","blend_move","appearance","alpha","transform","maptext_height","maptext_width","vars","verbs","maptext","override","pixel_z","pixel_y","pixel_x","mouse_opacity","mouse_drop_zone","mouse_drop_pointer","mouse_drag_pointer","mouse_over_pointer","luminosity","text","suffix","tag","desc")

//This list is an index of lists not tied to any datum, by having them here you are capable of editing them with the "Edit_Lists" verb
var/list/Index=list("ListOne"=ListOne,"ListTwo"=ListTwo)
var/list/ListOne = list()
var/list/ListTwo = list()

mob //Define it under any which mob you'd like
	proc
		EditSetName()//Sets the top bars information on what you are editing
			var/G=""
			for(var/I=1 to EditVar.len)
				G="[G][EditVar[I]]/"
			src<<output("[G]","EditPage.SelectedOut")

		EditSearchProc(T as text) //This proc allows you to use the search and automatic search functions - Important, Optional, Remove only if you are removing the search function
			var/list/L=list()
			var/R=GetEditing()
			if(R=="Index")
				R=Index
			if(!istype(R,/list))
				if(istype(R,/datum)||istype(R,/atom))
					var/datum/r=R
					R=r.vars
				else
					var/datum/G=GetEditing(1)
					R=G.vars
			for(var/M in R)
				if(findtext(M,T))
					L+=M
			UpdateEdit(L,1)

		AutoSearchEdit() //This proc starts the moment you use "Edit", it will periodically poll the search bar for any changes and search accordingly - Optional, remove if you are removing the search function
			set background=1
			var/T=""
			for(var/I=0 to 999999)//Search for 55 and a half hours if need be
				if(!InEdit)
					break
				var/t=winget(usr,"EditPage.Search","text")
				if(T!=t)
					T=t
					if(T!="")
						EditSearchProc(T)
					else
						var/datum/G=GetEditing()
						if(G=="Index")
							G=Index
						else
							if(istype(G,/datum)||istype(G,/atom))
								G=G.vars
							else
								EditVar.len--
								G=GetEditing(1)
						UpdateEdit(G,1)
				sleep(2)

		GetEditing(N=0)//This proc checks to insure the code is editing the correct thing - Important, Required
			var/datum/I=EditVar[1]//I initializes as the first thing you chose to edit
			for(var/C=2 to EditVar.len-N)//Loops from the second selection in the list on to its end
				if(I=="Index")
					I=Index[EditVar[C]]
				else
					if(istype(I,/list))
						I=I[EditVar[C]]
					else
						I=I.vars[EditVar[C]]//I becomes the variable in the previous I
			return I

		UpdateEditVerbs(N as num)//This proc controls when you have the edit-related verbs - Important, Required
			if(N)
				verbs+=typesof(/mob/Edit/verb)
			else
				verbs-=typesof(/mob/Edit/verb)

		UpdateEdit(A,N=0)//This proc updates the interface - Important, Required
			winset(src,"EditPage.VarGrid","cells=0x0")
			var/list/L
			if(istype(A,/list))
				L=A
				if(!N)
					Editing=L
			else
				var/atom/B=A
				L=B.vars
				Editing=B
				winset(src,"EditPage.Search","text=")
			EditSetName()
			var/E="No"
			if(N)
				E="Yes"
			var/r=1
			var/c=0
			for(var/X in L)
				if(X in EditIgnore)
					continue
				src<<output("<a style=text-decoration:none; href=?src=\ref[src];action=Var;special=[E];vari=[X]>[X]</a>","EditPage.VarGrid:[++c],[r]")
				if(c==4)
					c=0
					r++
			if(!N&&istype(A,/list))
				usr<<output("<a style=text-decoration:none;color:#A5FFB1'highlight-color:#A5FFB1; href=?src=\ref[src];action=Var;vari=Add>Add</a>","EditPage.VarGrid:[++c],[r]")
				if(c==4)
					c=0
					r++
				if(length(Editing))
					src<<output("<a style=text-decoration:none;color:#FFA5A5'highlight-color:#FFA5A5; href=?src=\ref[src];action=Var;vari=Remove>Remove</a>","EditPage.VarGrid:[++c],[r]")

	Edit
		verb
			EditSearch(T as text) //This is for when you use the search bar, Important, Optional
				set hidden=1
				EditSearchProc(T)

			EditBack() // This is for going back a step if you are editing something within another thing - Important, Required
				set hidden=1
				EditVar.len--
				var/list/A=GetEditing()
				if(A==Editing)
					EditVar.len--
				Editing=GetEditing()
				if(Editing=="Index")
					UpdateEdit(Index,1)
				else
					UpdateEdit(Editing)
				src<<output(null,"EditPage.VarName")
				src<<output(null,"EditPage.VarValue")
				winset(src,"EditPage.Search","focus=true")
				if(EditVar.len==1)
					winset(src,"EditPage.BackBut","is-visible=false")
				sleep()

			ChangeValue(T as text)//Wouldnt be much of an edit if it didnt make any changes. All the "Value" buttons use this - Important, Required
				set hidden=1
				var/G="[key] edited [EditVar[1]]"
				for(var/I=2 to EditVar.len)
					G+="/[EditVar[I]]"
				var/datum/R=GetEditing()
				if(isnull(R))
					R="null"
				G+=" from [R] to "
				var/Value
				var/L=GetEditing(1)
				if(istype(L,/list))
					if(T=="Text")
						L[EditVar[EditVar.len]]=input("Enter new value","Text",L[EditVar[EditVar.len]]) as text
					if(T=="Num")
						L[EditVar[EditVar.len]]=input("Enter new value","Number",L[EditVar[EditVar.len]]) as num
					if(T=="Type")
						L[EditVar[EditVar.len]]=input("Enter new type:","Type",L[EditVar[EditVar.len]]) in typesof(/obj,/mob,/area,/turf,/datum)
					if(T=="Icon")
						L[EditVar[EditVar.len]]=input("Choose a new icon:","Icon",L[EditVar[EditVar.len]]) as icon
					if(T=="Null")
						if(alert("Are you sure you want to clear this variable?","Null","Yes","No")=="Yes")
							L[EditVar[EditVar.len]]=null
					if(T=="Default")
						L[EditVar[EditVar.len]]=initial(L[EditVar[EditVar.len]])
					if(T=="File")
						L[EditVar[EditVar.len]]=input("Choose a new file:","File",L[EditVar[EditVar.len]]) as file
					if(T=="Loc")
						var/atom/Z=GetEditing(1)
						Z[EditVar[EditVar.len]]=input("Select reference:","Reference",L[EditVar[EditVar.len]]) as mob|obj|turf|area in world
					Value=L[EditVar[EditVar.len]]
				else
					if(T=="Text")
						Editing.vars[EditVar[EditVar.len]]=input("Enter new value","Text",Editing.vars[EditVar[EditVar.len]]) as text
					if(T=="Num")
						Editing.vars[EditVar[EditVar.len]]=input("Enter new value","Number",Editing.vars[EditVar[EditVar.len]]) as num
					if(T=="Type")
						Editing.vars[EditVar[EditVar.len]]=input("Enter new type:","Type",Editing.vars[EditVar[EditVar.len]]) in typesof(/obj,/mob,/area,/turf,/datum)
					if(T=="Icon")
						Editing.vars[EditVar[EditVar.len]]=input("Choose a new icon:","Icon",Editing.vars[EditVar[EditVar.len]]) as icon
					if(T=="Null")
						if(alert("Are you sure you want to clear this variable?","Null","Yes","No")=="Yes")
							Editing.vars[EditVar[EditVar.len]]=null
					if(T=="Default")
						Editing.vars[EditVar[EditVar.len]]=initial(Editing.vars[EditVar[EditVar.len]])
					if(T=="File")
						Editing.vars[EditVar[EditVar.len]]=input("Choose a new file:","File",Editing.vars[EditVar[EditVar.len]]) as file
					if(T=="Loc")
						var/atom/Z=GetEditing(1)
						Z.vars[EditVar[EditVar.len]]=input("Select reference:","Reference",Editing.vars[EditVar[EditVar.len]]) as mob|obj|turf|area in world
					Value=Editing.vars[EditVar[EditVar.len]]
					if(EditVar[EditVar.len]=="name")
						EditSetName()
				if(isnull(Value))
					src<<output("null","EditPage.VarValue")
				else
					src<<output("[Value]","EditPage.VarValue")
				G+="[Value]"
				WriteToLog("admin","[time2text(world.realtime)]: [G]<BR>")

			CloseEdit()//Closes the window and resets it's appearance - Important, Required
				set hidden=1
				Editing=null
				InEdit=0
				EditVar=list()
				src<<output(null,"EditPage.SelectedOut")
				src<<output(null,"EditPage.VarName")
				src<<output(null,"EditPage.VarValue")
				winset(src,null,"EditPage.SelectedOut.background-color=#B4B4B4;EditPage.VarName.background-color=#B4B4B4;EditPage.VarValue.background-color=#B4B4B4")
				winset(src,"EditPage.VarGrid","cells=0x0")
				winset(src,"EditPage.BackBut","is-visible=false")
				UpdateEditVerbs(0)

	var/tmp
		//All these variables are important and required. ALSO MAKE THEM FUCKING TEMPORARY YOU RETARD
		InEdit=0//To let the system know youre editing
		list/Editing//Your current target
		list/EditVar=list()//List containing your targets
	Admin3 //addition for Climax
		verb
			Edit(atom/A in world)// This verb exists to give you a "Right Click" option for chosing your edit target - Optional as long as you use the Double Click call
				set category="Admin"
				Editing=A
				EditVar=list()
				EditVar+=A
				winset(src,null,"EditPage.SelectedOut.background-color=#F0F0F0;EditPage.Search.background-color=#F0F0F0")
				src<<output("[A.name]","EditPage.SelectedOut")
				src<<output(null,"EditPage.VarValue")
				src<<output(null,"EditPage.VarName")
				winset(src,"EditPage.BackBut","is-visible=false")
				winset(src,"EditPage.Search","focus=true")
				UpdateEdit(A)
				if(!InEdit)
					winset(src,"EditPage","is-visible=true")
					InEdit=1
					UpdateEditVerbs(1)
					AutoSearchEdit()

			Edit_Lists()//Allows you to edit lists not within any datum as long as they are defined within "Index"
				set category="Admin"
				UpdateEdit(Index,1)
				Editing=Index
				EditVar=list()
				EditVar=list("Index"=Index)
				winset(src,"EditPage","is-visible=true")
				winset(src,"EditPage.Search","focus=true")
				InEdit=1
				UpdateEditVerbs(1)
				AutoSearchEdit()

client
	DblClick(atom/A)//This gives you a "Double click" method of selecting your edit target after the panel is open- Optional
		var/mob/M=src.mob
		if(M.InEdit)
			M.Editing=A
			M.EditVar=list()
			M.EditVar+=A
			winset(src,null,"EditPage.SelectedOut.background-color=#F0F0F0;EditPage.Search.background-color=#F0F0F0")
			src<<output("[A.name]","EditPage.SelectedOut")
			src<<output(null,"EditPage.VarValue")
			src<<output(null,"EditPage.VarName")
			winset(src,"EditPage.BackBut","is-visible=false")
			M.UpdateEdit(A)
		..()

	Topic(href,href_list[])//This allows you to select the variable you wish to edit from the list - Important, Required
		switch(href_list["action"])
			if("Var")
				var/mob/U=src.mob
				if(href_list["vari"]=="Add")
					var/L=U.GetEditing()
					var/Z
					if(!istype(L,/list))
						L=U.GetEditing(1)
						Z=1
					var/I
					switch(input(src,"What is the new variable in the list?","Add to list")in list("Text","Number","Icon","File","Reference","Cancel"))
						if("Cancel")
							return
						if("Text")
							I=input(src,"What is the name of the new variable in the list?","Add to list")as text
						if("Number")
							I=input(src,"What is the name of the new variable in the list?","Add to list")as num
						if("Icon")
							I=input(src,"Which icon is the new variable in the list?","Add to list")as icon
						if("File")
							I=input(src,"Which file is the new variable in the list?","Add to list")as file
						if("Reference")
							I=input("Select reference for the new variable?","Add to list") as mob|obj|turf|area in world
					L+=I
					var/H="[U.EditVar[2]]"
					for(var/V=3 to U.EditVar.len)
						if(V==U.EditVar.len&&Z)
							continue
						H+="/[U.EditVar[V]]"
					WriteToLog("admin","[time2text(world.realtime)]: [key] added [I] to [H]<BR>")
					U<<output(I,"EditPage.VarName")
					U<<output("null","EditPage.VarValue")
					U.UpdateEdit(L)
					return
				if(href_list["vari"]=="Remove")
					U<<output(null,"EditPage.VarName")
					U<<output(null,"EditPage.VarValue")
					var/L=U.GetEditing()
					var/Z
					if(!istype(L,/list))
						L=U.GetEditing(1)
						Z=1
					var/I=input(src,"What variable would you like to remove from the list?","Remove from list")in L+list("Cancel")
					if(I!="Cancel")
						L-=I
						var/H="[U.EditVar[2]]"
						for(var/V=3 to U.EditVar.len)
							if(V==U.EditVar.len&&Z)
								continue
							H+="/[U.EditVar[V]]"
						WriteToLog("admin","[time2text(world.realtime)]: [key] removed [I] to [H]<BR>")
						U.UpdateEdit(L)
					return
				if(href_list["special"]=="Yes")
					var/H=U.GetEditing()
					if(!istype(H,/list)&&!istype(H,/datum)&&!istype(H,/atom)&&H!="Index")
						U.EditVar.len--
					U.EditVar+=href_list["vari"]
					H=U.GetEditing()
					if(istype(H,/list)||istype(H,/datum)||istype(H,/atom))
						U.UpdateEdit(H)
						winset(src,"EditPage.Search","focus=true")
						winset(U,"EditPage.BackBut","is-visible=true")
						U<<output(null,"EditPage.VarName")
						U<<output(null,"EditPage.VarValue")
						winset(U,null,"EditPage.VarName.background-color=#B4B4B4;EditPage.VarValue.background-color=#B4B4B4")
						return
				U<<output("[href_list["vari"]]","EditPage.VarName")
				var/Value
				if(istype(U.Editing,/list))
					Value=U.Editing[href_list["vari"]]
				else
					Value=U.Editing.vars[href_list["vari"]]
				if(U.EditVar.len>1)
					var/datum/I=U.GetEditing()
					if(U.Editing!=I)
						var/PrevValue
						if(U.EditVar[U.EditVar.len-1]=="Index")
							PrevValue=Index
						else
							PrevValue=U.Editing.vars[U.EditVar[U.EditVar.len]]
						if(!istype(PrevValue,/atom)&&!istype(PrevValue,/datum)&&!istype(PrevValue,/list)&&PrevValue!="Index")
							U.EditVar.len--
				U.EditVar+=href_list["vari"]
				winset(U,null,"EditPage.VarName.background-color=#F0F0F0;EditPage.VarValue.background-color=#F0F0F0")
				if(istype(Value,/datum)||istype(Value,/list)||istype(Value,/atom))
					winset(src,"EditPage.Search","focus=true")
					winset(src,"EditPage.Search","text=")
					winset(src,"EditPage.BackBut","is-visible=true")
					U.UpdateEdit(U.GetEditing())
					U<<output(null,"EditPage.VarName")
					winset(U,null,"EditPage.VarName.background-color=#B4B4B4;EditPage.VarValue.background-color=#B4B4B4")
				var/L=U.GetEditing(1)
				if(istype(L,/list))
					Value=L[U.EditVar[U.EditVar.len]]
				if(isnull(Value))
					U<<output("null","EditPage.VarValue")
				else
					U<<output("[Value]","EditPage.VarValue")
		.=..()