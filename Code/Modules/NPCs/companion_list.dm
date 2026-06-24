obj/Creatables
	Pkball
		name = "Pee-Kay Ball"
		icon = 'Companion.dmi'
		icon_state = "Pball"
		desc = "A ball whose ability is to capture the DNA of fallen foes and recreate them into a customizable and trainable servant."
		neededtech = 45
		cost = 100000
		create_type = /obj/items/companion_obj/Pkball

	Intercepter_Core
		name = "Intercepter Core"
		icon = 'Companion.dmi'
		icon_state = "Pball"
		desc = "The Intercepter Core is a unique capsule that creates a small intelligent drone capable of shooting down Ki blasts."
		neededtech = 60
		cost = 120000
		create_type = /obj/items/companion_obj/Intercepter_Core

	Doll_Core
		name = "Doll Core"
		icon = 'Companion.dmi'
		icon_state = "Pball"
		desc = "The Doll Core is a very unique capsule with a human-type specimen capable of great growth, but is quite weak. It's intelligence is quite high."
		neededtech = 55
		cost = 120000
		create_type = /obj/items/companion_obj/Doll_Core

	Saibaman_Capsule
		name = "Saibaman Capsule"
		icon = 'Companion.dmi'
		icon_state = "Pball"
		desc = "Requires also a seed food item. The Saibaman Capsule creates a genetically grown super warrior stronger than many men. It's loyal- but it's also vicious."
		neededtech = 60
		cost = 90000
		create_type = /obj/items/companion_obj/Saibaman_Capsule
		Click()
			var/obj/items/food/Seed/s = locate(/obj/items/food/Seed) in usr.contents
			if(s)
				if(..()) usr.contents -= s
			else return
	Pet_Food
		name = "Pet Food"
		icon = 'Companion.dmi'
		icon_state = "Pball"
		desc = "Give it to an out companion or a companion inside a capturer to increase their intelligence."
		cost = 100000
		neededtech = 45
		create_type = /obj/items/Pet_Food
obj/items
	Pet_Food
		name = "Pet Food"
		icon = 'Companion.dmi'
		icon_state = "Pball"
		proc/Use()
			set category = null
			set src in usr
			for(var/mob/npc/pet/M in view(1,usr))
				if(M.owner_ref == src && alert(usr,"Increase companion intelligence?","","Sure","No")=="Sure")
					M.techmod+=3
					del(src)
					break

obj/items/companion_obj
	Pkball
		name = "Capture Ball"
		icon_state = "Pball"
		verb/Capture()
			set category = null
			set src in usr
			if(linked_mob_type)
				usr << "Already have a mob type."
				return
			var/mob/trg = null
			for(var/mob/npc/M in get_step(src,dir))
				if(!istype(M,/mob/npc/pet) && !M.sim && M.quality && M.KO)
					trg = M
					break
			if(trg)
				linked_mob_type = /mob/npc/pet
				linked_mob_name = trg.name
				linked_mob_icon = trg.icon
				linked_mob_bp = trg.BP
			else usr<<"No target!"

	Intercepter_Core
		name = "Intercepter Core"
		icon_state = "Pball"
		linked_mob_type = /mob/npc/pet/Interceptor
		linked_bp_mod = 0.5
		linked_mob_intelligence = 4
		linked_mob_behavior = list(1,1,1,2)//courage, rage, kindness, and logic, min 0.1, do not set to 0.
	Saibaman_Capsule
		name = "Saibaman Capsule"
		icon_state = "Pball"
		linked_mob_type = /mob/npc/pet/Saibaman
		linked_mob_bp = 1000
		linked_bp_mod = 0.8
		linked_mob_intelligence = 2
		linked_mob_behavior = list(0.8,2,0.2,0.8)
	Doll_Core
		name = "Doll Capsule"
		icon_state = "Pball"
		linked_mob_type = /mob/npc/pet/Doll
		linked_mob_bp = 1
		linked_bp_mod = 0.7
		linked_mob_intelligence = 8
		linked_mob_behavior = list(0.9,0.5,2,0.8)

mob/npc/pet
	var/list/attack_settings = list(0,0)
	Click()
		..()
		if(owner_ref!=usr)
			usr<<"This is not your [name]."
			return
		var/list/cmd_list = list("Cancel")
		cmd_list += "Change Name"
		cmd_list += "Change Icon"
		cmd_list += "Default Icon"
		if(techmod >= 1)
			cmd_list += "Follow/Stay"
			cmd_list += "Attack"
		if(techmod >= 2) cmd_list += "Kill"
		if(techmod >= 3 && relation["[usr.signature]"]>20) cmd_list += "Attack When I Do"
		if(techmod >= 4 && relation["[usr.signature]"]>20) cmd_list += "Attack when I am attacked"
		if(techmod >= 6) cmd_list += "Destroy"
		if(techmod >= 7) cmd_list += "Grab"
		if(techmod >= 7) cmd_list += "Drop"
		if(techmod >= 7) cmd_list += "Speak"
		if(techmod >= 7) cmd_list += "Unequip all equipment"
		if(techmod >= 7) cmd_list += "Equip all equipment"
		if(techmod >= 7) cmd_list += "Wear Clothing"
		if(techmod >= 8) cmd_list += "Manage Catchphrases"
		var/cmd = input(usr,"What command?") in cmd_list
		switch(cmd)
			if("Change Name") name=input() as text
			if("Change Icon") icon=input() as icon
			if("Default Icon") icon = initial(icon)
			if("Follow/Stay")
				if(setting)
					setting=0
					usr<<"You tell [src] to stay."
				else
					setting=1
					usr<<"You tell [src] to follow."
			if("Attack")
				var/mob/M = input(usr,"Select a mob to attack") as null|mob in view(5)
				if(ismob(M))
					if(target)
						target = null
						resetState()
						sleep(5)
					foundTarget(M)
			if("Kill")
				var/mob/M = input(usr,"Select a mob to kill.") as null|mob in view(5)
				if(ismob(M))
					murderToggle = 1
					if(target)
						target = null
						resetState()
						sleep(5)
					foundTarget(M)
			if("Attack When I Do")
				if(attack_settings[1]) attack_settings[1] = 0
				else attack_settings[1] = 1
			if("Attack when I am attacked")
				if(attack_settings[2]) attack_settings[2] = 0
				else attack_settings[2] = 1
			if("Destroy")
				var/atom/M = input(usr,"Select a object or turf to destroy.") as null|turf|obj in view(1)
				dir = get_dir(src,M)
				Attack()
			if("Speak")
				var/msg = input() as text
				sayType(msg,3)
			if("Drop")
				var/obj/items/nO = input(usr,"Which item? It has to be an item type object.") as null|obj in contents
				if(istype(nO,/obj/items) && !isnull(nO))
					var/tst = 1
					if(nO.amount > 1) tst = round(max(input(usr,"How many?") as num,0))
					usr = src
					nO.Drop(tst)
			if("Wear Clothing")
				var/obj/items/clothes/nO = input(usr,"Which item? It has to be an clothing item type object.") as null|obj in contents
				if(istype(nO,/obj/items/clothes) && !isnull(nO))
					usr = src
					nO.Equip()
			if("Grab")
				var/obj/items/nO = input(usr,"Which item? It has to be an item type object.") as null|obj in view(5,usr)
				if(istype(nO,/obj/items) && !isnull(nO))
					item_Targ = nO
					usr = src
					src.pickupItem()
			if("Unequip all equipment")
				for(var/obj/items/Equipment/E in src.contents)
					if(E.equipped)
						call(E,"Wear")(src)
			if("Equip all equipment")
				for(var/obj/items/Equipment/E in src.contents)
					if(!E.equipped)
						call(E,"Wear")(src)
			if("Manage Catchphrases")
				switch(input(usr,"Which catchphrase? Or, modify your title, name usage, or if catchphrases are done at all.","Catchphrases","Cancel") in list("Title","Refer Name?","Shutup","Attack Catch","Idle Catch","Follow Catch","Anger Catch","Cancel"))
					if("Attack Catch") attackcatch = edit_catch_list(attackcatch)
					if("Idle Catch") idlecatch = edit_catch_list(idlecatch)
					if("Follow Catch") followcatch = edit_catch_list(followcatch)
					if("Anger Catch") angercatch = edit_catch_list(angercatch)
					if("Title")
						default_title = input(usr,"What will your title be?") as text
					if("Refer Name?")
						if(alert(usr,"Use name instead of title?","Name","Yes","No")=="Yes") use_name=1
						else use_name=0
					if("Shutup")
						if(alert(usr,"Silence?","Silence","Yes","No")=="Yes") shutup=1
						else shutup=0
				sync_catch()
	techmod = 1
	chase_speed = 1
	Interceptor
		attackable=1
		attacking=1
		density=1
		icon='Interceptor.dmi'
		BP=1
		HP=100
		MaxKi=5
		Ki=5
		GravMastered=100
		MaxAnger=105
		BPMod=1
		KiMod=1
		techmod = 6
		kiregenMod=1
		GravMod=1
		ZenkaiMod=1
		movespeed=1
		f_keep_dist = 2
		New()
			..()
			spawn InterceptorAI()
		proc/InterceptorAI()
			spawn while(src)
				sleep(15)
				for(var/obj/attack/blast/A in view(9)) if(A.proprietor!=owner_ref)
					var/obj/B=new/obj
					B.icon='InterceptorBlast.dmi'
					B.icon+=rgb(blastR,blastG,blastB)
					missile(B,src,A)
					if(A) del(A)

	Saibaman
		attackable=1
		attacking=1
		density=1
		icon='Saibaman.dmi'
		BP=1000
		HP=100
		MaxKi=5
		Ki=5
		GravMastered=100
		MaxAnger=105
		BPMod=1
		KiMod=1
		techmod = 3
		kiregenMod=1
		GravMod=1
		ZenkaiMod=1
		movespeed=1
		f_keep_dist = 2

	Doll
		attackable=1
		attacking=1
		density=1
		icon='Doll.dmi'
		BP=1
		HP=100
		MaxKi=100
		Ki=100
		GravMastered=25
		MaxAnger=120
		BPMod=1
		KiMod=2
		techmod = 7
		kiregenMod=2
		GravMod=2
		ZenkaiMod=2
		movespeed=1
		f_keep_dist = 2