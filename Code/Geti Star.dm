var
	ghetto_star_exist = 1
	ghetto_star_own = 0
	ghetto_star_last_check = 0

mob/var
	stored_class=""
	stored_race=""
mob/npc/Clone
	hasAI=1
	isNPC=1
	notSpawned=0
	genome = new/datum/genetics/Meta(/datum/genetics/proto/Meta)
	RaceDescription="Meta Description: The Robotic-like lifeforms that inhabit the Big Gete Star, they are nearly as advanced as Tsujins and use a Core Computer to create organic copies of themselves, being able to inhabit the copy at will, although the copies are not very strong. Not only are they intellectual, but they are great at using energy. Their power is quite high as well, and their skills also excel above normal races."

	Click()
		if((displaykey==usr.key||displaykey==usr.displaykey) && !client)
			var/list/Choices=new/list
			Choices.Add("Destroy")
			Choices.Add("Follow")
			Choices.Add("Attack Target")
			Choices.Add("Attack Nearest")
			Choices.Add("Reset Observe")
			Choices.Add("Cancel")
			switch(input("Choose Option","",text) in Choices)
				if("Reset Observe")
					usr.client.perspective=MOB_PERSPECTIVE
					usr.client.eye=usr
					usr.observingnow=0
				if("Attack Nearest")
					hasAI = 1
					for(var/mob/nE in range(MAX_AGGRO_RANGE,usr))
						if(nE!=usr && nE!=src)foundTarget(nE)
				if("Destroy")
					del(src)
				if("Follow")
					var/d = get_dist(src, usr)
					AIRunning=1
					hasAI=1
					while(AIRunning==1 && usr && hasAI)
						sleep(5)
						if(d >= 2)
							if(prob(20)) step_rand(src)
							else step_towards(src,usr)
						d = get_dist(src,usr)

				if("Stop")
					AIRunning=0
					hasAI=0
				if("Attack Target")
					hasAI = 1
					var/mob/choice = input(usr,"Choose mob") as null|mob in view(usr)
					if(choice!=usr && choice!=src && !isnull(choice)) foundTarget(choice)
obj/Core_Computer
	icon='bigcomputer.dmi'
	density=1
	SaveItem=1
	fragile=1
	maxarmor = 300000000
	armor = 300000000 //300 million
	New()
		..()
		for(var/obj/Core_Computer/CC)
			if(CC!=src)
				var/sav
				sav = ghetto_star_exist
				del(CC)
				ghetto_star_exist = sav
		if(!ghetto_star_exist) del(src)
		if(ghetto_star_own)
			controller = ghetto_star_own
		var/icon/I = icon(icon)
		pixel_x = round(((-32) / 2),1)
		pixel_y = round(((-32) / 2),1)
		icon = I
	var/controller //who controls the star
	var/destroyed
	var/resurrection=1
	var/didRandRes=0
	var/eternalGetistar = 0 //if the person who owns it, owns it forever.
	Click() //Lets you assimilate with the computer.
		if(get_dist(src,usr)>=3 && src.z != usr.z) return
		if(!controller)
			if(!ghetto_star_own)
				view(src,9) << "CORE REBOOTING..."
				usr.contents+=new /obj/Meta_Inhabit
				usr.dir=NORTH
				view(src,9) << "Geti Star: Welcome [usr]. Please enjoy your eternal life."
				controller = usr.signature
				ghetto_star_own = usr.signature
				ghetto_star_last_check = world.realtime
			else
				controller = ghetto_star_own
				view(src,9) << "CORE REBOOTING...."
				if(controller != usr.signature && world.realtime >= ghetto_star_last_check + 172800 && !eternalGetistar) //if you leave the Ghetto Star alone for 2 days...
					view(src,9) << "Geti Star: <font color=red>USER ABANDONMENT PROTCOL ACTIVATED</font>"
					sleep(10)
					view(src,9) << "Geti Star: <font color=red>NEW USER REGISTERED.</font>"
					usr.contents+=new /obj/Meta_Inhabit
					usr.dir=NORTH
					view(src,9) << "Geti Star: Welcome [usr]. Please enjoy your eternal life."
					ghetto_star_own = usr.signature
					ghetto_star_last_check = world.realtime
					controller = usr.signature
				else if(controller == usr.signature)
					view(src,9) << "Geti Star: Welcome [usr]. Please enjoy your eternal life."
				else usr << "The Core does not allow you access."
		else if(controller!=usr.signature)
			if(world.realtime >= ghetto_star_last_check + 172800 && !eternalGetistar) //if you leave the Ghetto Star alone for 2 days...
				view(src,9) << "Geti Star: <font color=red>USER ABANDONMENT PROTCOL ACTIVATED</font>"
				sleep(10)
				view(src,9) << "Geti Star: <font color=red>NEW USER REGISTERED.</font>"
				usr.contents+=new /obj/Meta_Inhabit
				usr.dir=NORTH
				view(src,9) << "Geti Star: Welcome [usr]. Please enjoy your eternal life."
				ghetto_star_own = usr.signature
				ghetto_star_last_check = world.realtime
				controller = usr.signature
			else usr<<"The Core does not allow you access."
		else if(controller==usr.signature)
			ghetto_star_own = usr.signature
			ghetto_star_last_check = world.realtime
			maxarmor = max(maxarmor,usr.intBPcap)
			var/list/Choices=new/list
			Choices.Add("Create Body")
			Choices.Add("Create Meta")
			Choices.Add("Observe Meta")
			Choices.Add("Disassimilate")
			Choices.Add("Mindswap")
			Choices.Add("Cancel")
			switch(input("Choose Option","",text) in Choices)
				if("Create Body")
					usr.makeCopy(1,"Meta","Clone",/mob,1)
				if("Create Meta")
					usr.makeCopy(1,"Meta","Clone",/mob/npc/Clone,FALSE)
				if("Observe Meta")
					var/list/Metas=new/list
					for(var/mob/npc/Clone/A) if(A.displaykey==usr.displaykey||A.displaykey==usr.key) Metas.Add(A)
					var/Choice=input("Observe which?") in Metas
					for(var/mob/npc/Clone/A) if(Choice==A)
						usr.client.perspective=EYE_PERSPECTIVE
						usr.client.eye=A
				if("Destroy All Metas")
					for(var/mob/npc/Clone/A)
						if(!A.client) del(A)
				if("Disassimilate")
					controller=null
				if("Mindswap")
					var/list/Metas=new/list
					for(var/mob/A in view(10)) if(!A.client&&!A.isNPC&&(A.displaykey==usr.displaykey||A.displaykey==usr.key)) Metas.Add(A)
					Metas += "Cancel"
					var/Choice=input("Mindswap with which?") in Metas
					for(var/mob/A in Metas) if(Choice==A)
						usr.client.MindSwap(A)
	Del()
		ghetto_star_exist = 0
		for(var/mob/npc/Clone/Q)
			view(Q)<<"[Q] has lost its core computer!"
			del(Q)
		..()


mob/proc/MetaRepair()
	overlayList+='MetaRepair.dmi'
	overlaychanged=1
	while(HP<100&&Ki>=MaxKi*0.1&&!KO)
		sleep(20)
		SpreadHeal(10,1,1)
		Ki-=MaxKi*0.01
	overlayList-='MetaRepair.dmi'
	overlaychanged=1
	return TRUE
mob/Admin3/verb/Blendicon(mob/A in world)
	set category="Admin"
	var/icon/I=new(A.oicon)
	var/grrr=input("Add, Subtract, MultiBPy. 1 to 3") as num
	var/rr=input("Red") as num
	var/gg=input("Green") as num
	var/bb=input("Blue") as num
	var/eh=input("Alpha") as num
	if(grrr==1) I.Blend(rgb(rr,gg,bb,eh),ICON_ADD)
	else if(grrr==2) I.Blend(rgb(rr,gg,bb,eh),ICON_SUBTRACT)
	else I.Blend(rgb(rr,gg,bb,eh),ICON_MULTIPLY)
	A.icon=I

obj/items/Tiny_Rock
	icon = 'magic_items.dmi'
	icon_state = "dark_seed_inert"


obj/Meta_Inhabit //need to add bodyswapping back in eventually
	var/tmp/hasbody
	var/bodysig
	proc/checkcontroller()
		for(var/obj/Core_Computer/S in obj_list)
			if(S.controller == usr.signature)
				return TRUE
		Return_To_Body()
		del(src)
	verb/Go_To_Geti()
		set category="Other"
		if(!checkcontroller()) return
		if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) return
		if(!usr.KO&&usr.canfight&&!usr.med&&!usr.train&&usr.Ki>=usr.MaxKi&&!usr.inteleport)
			view(6)<<"[usr] is decomposing!!!!"
			usr.Ki=0
			view(6)<<"[usr] decomposes into light particles!!"
			usr.inteleport=1
			var/obj/geti
			var/list/objlist = list()
			for(var/obj/Core_Computer/S in obj_list)
				if(S.controller == usr.signature)
					objlist += S
					break
			for(var/obj/items/Tiny_Rock/S in obj_list)
				objlist += S
			objlist += "Cancel"
			geti = input(usr,"Go to the Geti Star or a sleeper Geti.","Teleport","Cancel") in objlist
			if(geti!="Cancel") usr.loc = locate(geti.x,geti.y - 1,geti.z)
			usr.inteleport=0
	verb/Sleeper_Geti()
		set category="Other"
		if(!checkcontroller()) return
		if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) return
		if(!usr.KO&&usr.canfight&&!usr.med&&!usr.train&&usr.Ki>=usr.MaxKi*0.9&&!usr.inteleport)
			new/obj/items/Tiny_Rock(usr.loc)
	verb/Inhabit()
		set category="Skills"
		if(!checkcontroller()) return
		if(!hasbody)
			var/list/PeopleList=new/list
			PeopleList+="Cancel"
			for(var/mob/P in oview(usr)) if(!P.client && !istype(P,/mob/npc)) PeopleList.Add(P.name)
			var/Choice=input("Take which body?") in PeopleList
			if(Choice=="Cancel")
			else
				for(var/mob/M in oview(usr))
					if(M.name==Choice)
						if(!M.KO&&!hasbody)
							//mindswap
							if(!(/obj/Meta_Inhabit in M.contents))
								var/obj/Meta_Inhabit/A = new
								M.contents += A
								if(hasbody) A.hasbody = hasbody
								else A.hasbody = usr
								if(bodysig) A.bodysig = bodysig
								else A.bodysig = usr.signature
								M.Savable=1
							else
								for(var/obj/Meta_Inhabit/A in M.contents)
									if(!A.hasbody)
										if(hasbody) A.hasbody = hasbody
										else A.hasbody = usr
									if(!A.bodysig)
										if(bodysig) A.bodysig = bodysig
										else A.bodysig = usr.signature
									M.Savable=1
							usr.client.MindSwap(M)

							break
						else
							usr<<"They can't be knocked out." //needs to be reworked.
							break
		else
			usr<<"You need to be in your true body."
	verb/Return_To_Body()
		set category = "Other"
		if(hasbody)
			usr.client.MindSwap(hasbody)
			hasbody = null
			bodysig = null
		else
			if(bodysig)
				for(var/mob/M)
					if(M.signature == bodysig&&!M.client)
						usr.client.MindSwap(M)
						hasbody = null
						bodysig = null
						break
		if(!checkcontroller()) return