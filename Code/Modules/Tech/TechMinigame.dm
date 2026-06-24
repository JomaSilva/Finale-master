obj/items/Research_Station/verb
	Research()
		set category = null
		set src in view(1)
		if(!usr||usr.inAwindow) return FALSE
		winshow(usr,"miscwindow", 1)
		usr.inAwindow = 1
		usr.updateresearch = 1
		usr.Research_Window_Int()
		usr.contents += new/obj/researchwindow

mob/proc
	CloseResearchWindow()
		set waitfor = 0
		winset(usr,"miscwindow.misclabel","text=")
		winset(usr,"miscwindow.maingrid","cells=0")
		winshow(usr,"miscwindow", 0)
		for(var/obj/researchbuttons/A in contents)
			del(A)
		for(var/obj/researchwindow/A in contents) del(A)
		contents -= /obj/researchwindow
		usr.inAwindow = 0

	Research_Window_Int()
		if(!usr) return FALSE
		if(!usr.inAwindow) return FALSE
		if(updateresearch)
			updateresearch= 0
			researchableslist = list()
			for(var/obj/researchbuttons/A in contents) del(A)
			winset(usr,"miscwindow.maingrid","cells=0")
			var/amount = 32
			var/acreated =0 
			while(acreated < amount)
				acreated += 1
				var/obj/researchbuttons/A = new(src)
				researchableslist.Add(A)
			var/count = 0
			for(var/obj/researchbuttons/A in contents)
				usr << output(A,"miscwindow.maingrid: [++count]")
			winset(usr,"miscwindow.maingrid","cells=[count]")
		if(techskill<=99) winset(usr,"miscwindow.misclabel","text=\"Tech [techskill]: [techxp]\"")
		else winset(usr,"miscwindow.misclabel","text=\"Tech [techskill]: Capped\"")
		spawn(10) Research_Window_Int()

obj/researchwindow
	IsntAItem=1
	verb/DoneButton()
		set category = null
		set hidden = 1
		set waitfor = 0
		spawn del(src)
		usr.CloseResearchWindow()//causes a infinite cross reference loop otherwise

obj/researchbuttons
	name = "Click Me!"
	icon = 'GochekPods.dmi'
	icon_state = "off"
	New()
		..()
		spawn Ticker()
	proc/Ticker()
		if(icon_state == "on") icon_state = "off"
		if(prob(10))
			if(icon_state == "off") icon_state = "on"
		spawn(rand(10,50)) Ticker()
	Click()
		if(icon_state == "on")
			icon_state = "off"
			if(usr&&usr.techskill<=99) usr.techxp += (log(1.5,(usr.techup / usr.techskill)) * usr.techskill)

mob/var
	tmp/updateresearch = 0
	tmp/list/researchableslist = list()