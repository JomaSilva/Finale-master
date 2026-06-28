//targeting procs, the 't' stands for targeting
obj/Ritual/proc
	check_target()
		if(r_target)
			if(istype(r_target,/obj/Ritual)) return 5
			if(istype(r_target,/obj)) return 3//would use a switch here, but have to put constants in the if statements then.
			if(istype(r_target,/mob)) return 2
			if(istype(r_target,/turf)) return 1
			return 4
		else return FALSE

	pick_rand_target(index)
		if(!index) index = pick(1,2,3,5)
		var/list/rand_list = list()
		switch(index)
			if(1)
				for(var/turf/M in view(10,src))
					rand_list += M
			if(2)
				//var/list/rand_list = list()
				for(var/mob/M in view(10,src))
					rand_list += M
				//r_target = pick(rand_list)
			if(3)
				//var/list/rand_list = list()
				for(var/obj/M in view(10,src))
					rand_list += M
				//r_target = pick(rand_list)
			if(4)
				r_target = src
			if(5)
				//var/list/rand_list = list()
				for(var/obj/Ritual/M in view(10,src))
					rand_list += M
				//r_target = pick(rand_list)
		if(rand_list.len)
			r_target = pick(rand_list)
		else return FALSE
		return r_target

	target_check(tocheck) //ensures we have a target
		if(check_target() == tocheck || (tocheck == 0 && check_target()))
			//world << "3atest"
			Magic /= sqrt(get_dist(r_target,src))
			if(r_target.z != z || r_target.z - z != 0)
				Magic /= (abs(r_target.z - z) + 3)
			return TRUE
		else
			//world << "3btest"
			return pick_rand_target(tocheck)

	t_tar_p_w()
		var/list/moblist = list()
		for(var/mob/M in player_list)
			moblist += M
		r_target = input(invoker, "Select a mob in the world.") as mob in moblist

	t_tar_m_w()
		var/list/moblist = list()
		for(var/mob/M in mob_list)
			moblist += M
		r_target = input(invoker, "Select a mob in the world.") as mob in moblist

	t_tar_o_w()
		var/list/objlist = list()
		for(var/obj/M in obj_list)
			if(!IsntAItem && !istype(M,/obj/Ritual)) objlist += M
		r_target = input(invoker, "Select a object in the world.") as mob in objlist

	t_tar_r_w()
		var/list/objlist = list()
		for(var/obj/Ritual/M in obj_list)
			objlist += M
		r_target = input(invoker, "Select a Ritual in the world.") as mob in objlist

	t_tar_p()
		//world << "12test"
		var/list/moblist = list()
		for(var/mob/M in view(10,src))
			if(M.client)
				//world << "12a[M]test"
				moblist += M
		//world << "moblist: [moblist], o[moblist.len], r[r_target], c[invoker]"
		r_target = input(invoker, "Select a mob in view.") as mob in moblist

	t_tar_p_all_r(magnitude=5)
		for(var/mob/M in view(magnitude,src))
			if(M.client)
				multiple_targets += M
				r_target = M
	t_tar_m_all_r(magnitude=5)
		for(var/mob/M in view(magnitude,src))
			multiple_targets += M
			r_target = M
	t_tar_m_all_v(magnitude=25)
		for(var/mob/M in view(magnitude,src))
			multiple_targets += M
			r_target = M
	t_tar_m()
		var/list/moblist = list()
		for(var/mob/M in view(10,src))
			moblist += M
		r_target = input(invoker, "Select a mob in view.") as mob in moblist
	t_tar_p_all_p()
		var/area/A = GetArea()
		for(var/mob/M in A.my_player_list)
			if(M.client)
				multiple_targets += M
				r_target = M
	t_tar_m_all_p()
		var/area/A = GetArea()
		for(var/mob/M in A.my_mob_list)
			multiple_targets += M
			r_target = M

	t_tar_o_all_r(magnitude=5)
		for(var/obj/M in view(magnitude,src))
			if(!IsntAItem && !istype(M,/obj/Ritual))
				multiple_targets += M
				r_target = M
	t_tar_o()
		var/list/objlist = list()
		for(var/obj/M in view(10,src))
			if(!IsntAItem && !istype(M,/obj/Ritual)) objlist += M
		r_target = input(usr, "Select a object in view.") as obj in objlist
	t_tar_o_all_p() //~might~ be laggy, don't use if you can.
		var/area/A = GetArea()
		for(var/obj/M in A)
			if(!IsntAItem && !istype(M,/obj/Ritual))
				multiple_targets += M
				r_target = M

	t_tar_r_all_r(magnitude=5)
		for(var/obj/Ritual/M in oview(magnitude,src))
			multiple_targets += M
			r_target = M
	t_tar_r()
		var/list/objlist = list()
		for(var/obj/Ritual/M in oview(10,src))
			objlist += M
		r_target = input(invoker, "Select a Ritual in view.") as obj in objlist
	t_tar_r_all_p()
		var/area/A = GetArea()
		for(var/obj/Ritual/M in A)
			if(M != src)
				multiple_targets += M
				r_target = M

	t_tar_t_all_v(magnitude=25)
		for(var/turf/T in view(magnitude,src))
			multiple_targets += T
			r_target = T

obj/Magic_Portal
	icon = 'LightPortal.dmi'
	var/list/othercoords = list(0,0,0)
	pixel_x = -34
	pixel_y = -34
	canGrab=0
	density = 0
	var/lifespan = 30
	New()
		..()
		spawn Ticker()
	proc/Ticker()
		set background = 1
		lifespan -= 1
		if(lifespan<=0)
			del(src)
		for(var/mob/M in view(0,locate(src.x,src.y,src.z)))
			if(othercoords.len==3)
			else
				sleep(10)
				spawn Ticker()
				return
			var/theloc = locate(othercoords[1],othercoords[2],othercoords[3])
			var/list/possibleplaces = list()
			for(var/turf/A in oview(1,theloc))
				possibleplaces+=A
			rechoose
			var/turf/choice = pick(possibleplaces)
			if(isturf(choice))
				M.loc = locate(choice.x,choice.y,choice.z)
			else goto rechoose
		sleep(10)
		spawn Ticker()
		return

//effects
obj/Ritual/proc
	e_summon(magnitude)
		if(target_check() == FALSE) return 666
		if(istype(r_target,/atom/movable))
			var/offset = 30 - magnitude
			offset = max(0,offset)
			var/nx = max(1,min(x + rand(-offset,offset),499))
			var/ny = max(1,min(y + rand(-offset,offset),499))
			var/atom/movable/n_target = r_target
			n_target.loc = locate(nx,ny,z)
		else return 666

	e_portal(magnitude)
		if(target_check() == FALSE) return 666
		var/list/oldloc = list(rand(x+1,x-1),rand(y+1,y-1),usr.z)
		var/list/newloc = list(0,0,0)
		newloc[1] = round(input(invoker,"Input the X coordinate.") as num,1)
		newloc[2] = round(input(invoker,"Input the Y coordinate.") as num,1)
		newloc[3] = round(input(invoker,"Input the Z coordinate.") as num,1)
		var/obj/Magic_Portal/A = new
		A.othercoords = newloc
		A.loc = locate(oldloc[1],oldloc[2],oldloc[3])
		var/obj/Magic_Portal/B = new
		B.othercoords = oldloc
		B.loc = locate(newloc[1],newloc[2],newloc[3])
		A.lifespan += magnitude
		B.lifespan += magnitude

	e_teleport(magnitude)
		if(target_check() == FALSE) return 666
		var/offset = 30 - magnitude
		offset = max(0,offset)
		var/nx = max(1,min(r_target.x + rand(-offset,offset),499))
		var/ny = max(1,min(r_target.y + rand(-offset,offset),499))
		invoker.Move(locate(nx,ny,r_target.z))

	e_polymorph(magnitude)
		if(target_check(2) == FALSE) return 666
		var/amount 
		if(ismob(r_target))
			var/mob/M = r_target
			amount = log(1.3,max(Magic - (M.Emagiskill * M.Magic),1.1)) * magnitude
			var/list/t_l = list("polymorph"=pick('AnimalFrog.dmi','Animal Cow.dmi','dog.dmi','NPCChicken.dmi','NPCSheep.dmi'))
			spawn M.TempBuff(t_l,amount)
		else return 666
	
	e_timestop(magnitude)
		if(target_check() == FALSE) return 666
		var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		TimeStopped=1
		TimeStopDuration += ((amount**2)) * 10
		if(ismob(r_target))
			var/mob/M = r_target
			if(TimeStopperBP<=Magic + (r_target.Magic))
				TimeStopperBP =Magic + (r_target.Magic)
			if(!M.CanMoveInFrozenTime)
				var/list/t_l = list("timestop"=1)
				spawn M.TempBuff(t_l,((amount**2)) * 10)
		//TrackTimeStop(durationTime)
	e_zombification(magnitude)
		if(target_check() == FALSE) return 666
		var/amount = log(1.2,max(Magic + (r_target.Magic),1.1)) * magnitude
		if(ismob(r_target))
			var/mob/M = r_target
			if(prob(magnitude - M.Emagiskill*20))
				M.buudead = (Magic - (M.Emagiskill * M.Magic)) / 100
				M.Death()
				var/zombies=0
				for(var/mob/npc/Enemy/Zombie/A) zombies+=1
				if(zombies<100)
					var/mob/A=new/mob/npc/Enemy/Zombie
					A.BP=M.BP*2.5
					A.zenni=M.zenni*0.1
					A.loc=M.loc
					A.movespeed=rand(1,10)
					A.BP*=M.movespeed
					A.overlayList.Add(M.overlayList)
					A.overlaychanged=1
					A.name="[M.name] zombie"
			else
				M.SpreadDamage(35,1)
		createZombies(amount,r_target.Magic + Magic,r_target.x,r_target.y,r_target.z)
	
	e_vampirification(magnitude)
		if(target_check(2) == FALSE) return 666
		var/amount = log(3,max(Magic + (r_target.Magic),1.1)) * magnitude
		if(ismob(r_target))
			var/mob/M = r_target
			M.Vampirification()
			M.ParanormalBPMult += amount
			M.ParanormalBPMult = min(VampireBPMultMax,M.ParanormalBPMult)
		else return 666
	
	e_werewolfication(magnitude)
		if(target_check(2) == FALSE) return 666
		if(ismob(r_target))
			var/mob/M = r_target
			M.Werewolfify()
		else return 666
	
	e_change_time(magnitude)
		if(target_check(2) == FALSE) return 666
		var/weatherpick = rand(1,min(magnitude,9))
		if(magnitude==0) return
		else
			var/area/target_area = r_target.GetArea()
			target_area.daylightcycle += weatherpick
	
	e_soul_rip()
		if(target_check(2) == FALSE) return 666
		if(ismob(r_target))
			var/mob/M = r_target
			if(M.HasSoul)
				to_chat(view(M.screenx,M), "<font size=3 color=red>[M]'s soul is ripped out!</font>")
				M.HasSoul=0
				if(prob(100 - M.Emagiskill*5))
					M.buudead = (Magic - (M.Emagiskill * M.Magic)) / 100
					M.Death()
				else
					M.SpreadDamage(100,1)
			else M.SpreadDamage(90,1)
		else return 666

	e_soul_restore(magnitude)
		if(target_check() == FALSE) return 666
		if(ismob(r_target))
			var/mob/M = r_target
			to_chat(view(M.screenx,M), "<font size=3 color=red>[M]'s soul is restored!!</font>")
			M.HasSoul=1
			M.SpreadHeal(25,1)
		else return 666
	
	e_godki_ritual(magnitude)
		if(target_check() == FALSE) return 666
		if(ismob(r_target))
			var/mob/M = r_target
			to_chat(view(M.screenx,M), "<font size=3 color=red>[M] begins to shimmer!!!</font>")
			M.INITIALIZEGODPROTOCOL(list(null))
		else return 666

//dimensional rituals
obj/Ritual
	Ritual_of_Conjure_Demon
		icon_state = "shade6"
		activator_word = "xisxisxis"
		ritual_cost = 8000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Dragon_Blood,/obj/items/Material/Alchemy/Misc/Essence_Of_Space)
		ritual_effect(mob/u)
			var/magnitude = sqrt(Magic) * 2
			var/list/Demons=new/list
			for(var/mob/Demon) if(Demon.client) if(Demon.Race=="Demon") Demons.Add(Demon)
			var/mob/Choice=pick(Demons)
			Choice.ConjureX=Choice.x
			Choice.ConjureY=Choice.y
			Choice.ConjureZ=Choice.z
			Choice.Conjurer=u.key
			var/image/I=image(icon='Black Hole.dmi',icon_state="full")
			u.contents += new/obj/Conjure
			flick(I,Choice)
			Choice.loc=locate(x,y-1,z)
			flick(I,Choice)
			spawn(1) step(Choice,SOUTH)
			to_chat(oview(u), "[u] conjures the demon [Choice] to do his bidding!")
			var/amount = round(magnitude_calc(Magic,magnitude*u.Emagiskill,Choice.Magic))
			var/HoldPower
			spawn
				var/Reason
				switch(input(Choice,"[u] summoned you, choose a reward using the magical power.", "", text) in list ("Grant Power", "Unlock Potential", "Restore Youth"))
					if("Grant Power")
						HoldPower=max(convert_norm_to_magic_e(Magic),1) * (1/(3*sqrt(Magic)))
						Reason="power"
					if("Unlock Potential")
						Reason="Unlock Potential"
					if("Restore Youth")
						Reason="Restore Youth"
				if(Reason=="power")
					Choice.BP+=Choice.capcheck(round((HoldPower*0.25),1))
				if(Reason=="Unlock Potential")
					Choice.UnlockPotential(1)
				if(Reason=="Restore Youth")
					if(Choice.Age >= 18)
						Choice.Age=max(18,Choice.Age-amount)
						Choice.Body=max(18,Choice.Age-amount)
					Choice.genome.add_to_stat("Lifespan",amount / 10)
	Ritual_of_Might_Creation
		icon_state = "shade5"
		activator_word = "minmax"
		ritual_cost = 10000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Silverush,/obj/items/Material/Alchemy/Misc/Essence_Of_Space)
		ritual_effect(mob/u)
			if(target_check(2) == FALSE && !invoker) return
			invoker.contents += new/obj/items/food/Might_Fruit

	Research_Ritual
		icon_state = "main3"
		activator_word = "ars cerebrus cortex magnifica magica"
		ritual_cost = 500000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Microchip,/obj/items/Material/Alchemy/Misc/Essence_Of_Time,/obj/items/Material/Alchemy/Misc/Angel_Tear,/obj/items/Material/Alchemy/Misc/Moonseed,/obj/items/Material/Alchemy/Misc/Eel_Eye)
		ritual_effect(mob/u)
			if(target_check(2) == FALSE && !invoker) return
			to_chat(invoker, "<font color=blue><font size=2>An etherial voice calls to you...</font></font>")
			sleep(10)
			var/list/lucky_list = list()
			lucky_list += typesof(/obj/Ritual)
			lucky_list -= /obj/Ritual
			for(var/a in invoker.known_ritual_de_types)
				lucky_list -= a
			for(var/a in invoker.known_ritual_dm_types)
				lucky_list -= a
			for(var/a in invoker.known_ritual_ma_types)
				lucky_list -= a
			if(lucky_list.len)
				var/lucky_word = pick(lucky_list)
				var/obj/Ritual/nR = new lucky_word(null)
				to_chat(invoker, "<font color=blue><font size=3>???: [lucky_word] : [nR.typing] : [nR.activator_word]</font></font>")
				for(var/a in nR.req_ingredients)
					to_chat(invoker, "<font color=blue><font size=3>???: REQUIRES : [a]</font></font>")
				switch(nR.typing)
					if("Destruction") invoker.known_ritual_de_types += lucky_word
					if("Dimensional") invoker.known_ritual_dm_types += lucky_word
					if("Manipulation") invoker.known_ritual_ma_types += lucky_word
				del(nR)
			else to_chat(invoker, "<font color=blue><font size=3>???: error() : error_code=='teach_invalid' : creature:ritual_knowledge == maximum</font></font>")
	Wish
		icon_state = "main6"
		activator_word = "Eno, Owt, Eerht, Ruof, I eralced a bmuht raw!!"
		ritual_cost = 10000000
		typing = "Manipulation"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Essence_Of_Time,/obj/items/Material/Alchemy/Misc/Fae_Dust,/obj/items/Material/Alchemy/Misc/Essence_Of_Space,/obj/items/Material/Alchemy/Misc/Dragon_Blood,/obj/items/Material/Alchemy/Animal/Blood)
		ritual_effect(mob/u)
			var/list/WishList = list()
			var/TrueWishPower = log(Magic)
			var/text = "Cancel"
			WishList+="Nothing (Waste Wish)"
			WishList+="Panties"
			WishList+="Cancel"
			if(TrueWishPower>=2)
				WishList+="Cash"
				WishList+="Milestones"
				WishList+="Technology"
			if(TrueWishPower>=3)
				WishList+="Revive"
				WishList+="Youth"
				WishList+="Power"
				WishList+="Intelligence"
				WishList+="Gain Magic"
			if(TrueWishPower>=4)
				WishList+="Make Somebody Else Young"
				WishList+="Give Soul"
			if(TrueWishPower>=5)
				WishList+="Heal Planet"
				if(!TurnOffAscension||u.AscensionAllowed) if(u.genome.race_percent("Saiyan") >= 25) WishList+="Super Saiyan"
			if(TrueWishPower>=7)
				WishList+="Revive-All"
				WishList+="Kill Somebody"
			if(TrueWishPower>=10)
				WishList+="Immortality"
			var/chosenwish = input(invoker,"Make your wish.", "", text) in WishList
			switch(chosenwish)
				if("Cancel")
					to_chat(view(invoker), "[invoker] cancels [invoker]'s wish.")
					Magic += ritual_cost / 2
				else Wish(chosenwish,invoker,1,Magic*273.15)
	Interdimensional_Escape
		icon_state = "main3"
		activator_word = "teg em eht kucf attuo ereh"
		ritual_cost = 1000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Essence_Of_Space,/obj/items/Material/Alchemy/Misc/Beetle_Eye)
		ritual_effect()
			new/obj/InterdimensionPortal(loc)
	Pocket_Dimension
		icon_state = "main3"
		activator_word = "what hef vasanum"
		ritual_cost = 500
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Essence_Of_Space,/obj/items/Material/Alchemy/Misc/Moonseed)
		ritual_effect()
			if(invoker)
				qustin
				switch(input(invoker,"Put or take an item from storage?") in list("Cancel","Put","Take"))
					if("Cancel") return
					if("Put")
						var/list/item_list = list()
						for(var/obj/items/a in invoker)
							if(!a.equipped)
								item_list += a
						item_list += "Cancel"
						var/choice = input(invoker,"Which item?","Items") in item_list
						if(choice!="Cancel")
							var/obj/na = choice
							invoker.pocket_dim_holdings+=na
							na.Move(locate(1+rand(1,5),1+rand(1,5),31))
					if("Take")
						var/list/item_list = list()
						item_list = invoker.pocket_dim_holdings
						item_list += "Cancel"
						var/choice = input(invoker,"Which item?","Items") in item_list
						if(choice!="Cancel")
							var/obj/na = choice
							invoker.pocket_dim_holdings-=na
							na.Move(invoker)
				goto qustin
			else return 666
	Bag_of_Holding
		icon_state = "main3"
		activator_word = "storage r us"
		ritual_cost = 10000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Essence_Of_Space,/obj/items/Material/Alchemy/Misc/Moonseed,/obj/items/Material/Alchemy/Misc/Fae_Dust,/obj/items/Material/Alchemy/Misc/Mercury)
		ritual_effect()
			new/obj/items/Equipment/Accessory/Bagohlding(loc)
	
	Ritual_Of_Fusion
		icon_state = "main3"
		activator_word = "fyujon ha"
		ritual_cost = 2500
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Fae_Dust,/obj/items/Material/Alchemy/Animal/Liver,/obj/items/Material/Alchemy/Misc/Flitter_Fly)
		ritual_effect()
			var/list/moblist = list()
			for(var/mob/A in oview(5,invoker))
				if(A.client)
					moblist+=A
			moblist+="Cancel"
			var/mob/choice = input(usr,"Fuse with whom? You will be in control.") in moblist
			if(choice!="Cancel")
				invoker.Fuse(choice,1)
			else return 666
	
	Ritual_Of_Majin
		icon_state = "main3"
		activator_word = "bibidi babadi boop"
		ritual_cost = 35000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Fae_Dust,/obj/items/Material/Alchemy/Animal/Blood,/obj/items/Material/Alchemy/Misc/Cursed_Blood,/obj/items/Material/Alchemy/Misc/Demon_Horn,/obj/items/Material/Alchemy/Misc/Minor_Aspect_of_God)
		ritual_effect()
			var/list/moblist = list()
			for(var/mob/A in view(5,invoker))
				if(A.client)
					moblist+=A
			moblist+="Cancel"
			var/mob/choice = input(usr,"Make whom temporarily majin?") in moblist
			if(choice!="Cancel")
				invoker.startbuff(/obj/buff/Majin)
			else return 666
	
	Summon_Combatant
		icon_state = "main3"
		activator_word = "fite me scrub"
		ritual_cost = 1500
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Flitter_Fly,/obj/items/Material/Alchemy/Animal/Liver,/obj/items/Material/Alchemy/Misc/Hair,/obj/items/Material/Alchemy/Animal/Blood,/obj/items/Material/Alchemy/Misc/Fae_Dust)
		ritual_effect()
			var/list/rand_list = typesof(/mob/npc/Enemy/Bosses)
			var/choice = pick(rand_list)
			new choice(loc)
	
	Create_Spirit_Doll
		icon_state = "main3"
		activator_word = "spiritus creatus"
		ritual_cost = 5000
		typing = "Dimensional"
		req_ingredients = list(/obj/items/Material/Alchemy/Misc/Hair,/obj/items/Material/Alchemy/Animal/Liver,/obj/items/Material/Alchemy/Animal/Blood,/obj/items/Material/Alchemy/Misc/Fae_Dust)
		ritual_effect()
			spirit_creator_list.len++
			spirit_creator_list[spirit_creator_list.len] = list(x,y,z)

//summon dungeon

mob/var
	Conjurer
	ConjureX=1
	ConjureY=1
	ConjureZ=1

	list/pocket_dim_holdings = list()

obj/Conjure
	verb/DeConjure()
		set category="Skills"
		var/list/Demons=new/list
		for(var/mob/Demon) if(Demon.client) if(Demon.Conjurer==usr.key) Demons.Add(Demon)
		Demons += "Cancel"
		var/mob/Choice=input("Send back which Demon?") in Demons
		if(ismob(Choice))
			to_chat(Choice, "[usr] has sent you back from whence you came.")
			var/image/I=image(icon='Black Hole.dmi',icon_state="full")
			flick(I,Choice)
			Choice.loc=locate(Choice.ConjureX,Choice.ConjureY,Choice.ConjureZ)
			flick(I,Choice)
		del(src)