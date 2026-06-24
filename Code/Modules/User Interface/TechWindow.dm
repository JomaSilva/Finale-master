mob/proc
	OpenTechWindow()
		set category = null
		set hidden = 1
		if(!usr||inAwindow) return FALSE
		winshow(usr,"miscwindow", 1)
		usr.inAwindow = 1
		usr.updateTech = 1
		Tech_Window_Int()
		contents += new/obj/techwindow

mob/proc
	CloseTechWindow()
		set waitfor = 0
		spawn
			winset(usr,null,"miscwindow.misclabel.text=;miscwindow.maingrid.cells=0")
			winshow(usr,"miscwindow", 0)
			creatablesList = list()
			for(var/obj/Creatables/A in contents)
				A.deleteMe()
			for(var/obj/techwindow/B in contents)
				B.deleteMe()
			usr.updateTech = 1
			usr.inAwindow = 0

	Tech_Window_Int()
		if(!usr) return FALSE
		if(!usr.inAwindow) return FALSE
		if(isturf(loc))
		else return
		var/nomorebuilding = 0
		var/count2
		for(var/obj/O in loc)
			count2++
		if(count2 >= 8)
			nomorebuilding = 1
		if(updateTech)
			updateTech= 0
			creatablesList = list()
			winset(usr,"miscwindow.maingrid","cells=0")
			for(var/obj/Creatables/A in contents) del(A)
			if(!nomorebuilding)
				for(var/A in typesof(/obj/Creatables))
					new A(src)
					creatablesList.Add(A)
				for(var/obj/Creatables/A in contents)
					var/deleteflag = 0
					if(techskill<A.neededtech|name=="Creatables"|Rmagiskill<A.neededmag)
						deleteflag=1
					if(!deleteflag&&Race&&A.allowedRaces) for(var/S in A.allowedRaces)
						deleteflag = 1
						if(S == Race)
							deleteflag = 0
							break
					if(deleteflag)
						del(A)
				var/count = 0
				for(var/obj/Creatables/A in contents)
					usr << output(A,"miscwindow.maingrid: [++count]")
				winset(usr,"miscwindow.maingrid","cells=[count]")
			else
				winset(usr,"miscwindow.misclabel","text=\"Too many items underneath!\"")
		if(!nomorebuilding)
			if(techskill<=99) winset(usr,"miscwindow.misclabel","text=\"Tech [techskill]\"")
			else winset(usr,"miscwindow.misclabel","text=\"Tech [techskill]: Capped\"")
		else
			winset(usr,"miscwindow.misclabel","text=\"Too many items underneath!\"")
		spawn(10) Tech_Window_Int()

obj/techwindow
	verb/DoneButton()
		set category = null
		set hidden = 1
		set waitfor = 0
		usr.CloseTechWindow()//causes a infinite cross reference loop otherwise
		spawn del(src)


mob/var
	updateTech = 0
	tmp/list/creatablesList = list()