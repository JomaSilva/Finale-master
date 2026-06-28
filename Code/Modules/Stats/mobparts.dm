mob
	proc/TestMobParts()
		set waitfor = 0
		var/Reset = 0
		for(var/datum/Body/BB in body)
			if(BB.parentlimb == null && BB.isnested)
				Reset = 1
				break
		if(Reset||bupdateseed!=bresolveseed)
			if(client)
				for(var/obj/Modules/R in contents)
					if(R.isequipped)
						R.unequip()
					R.remove()
					del(R)
				for(var/datum/Body/X in body)
					del(X)
				sleep(2)
		var/list/operation_list = list()
		if(genome == null)
			operation_list = list(/datum/Body/Head,/datum/Body/Head/Brain,/datum/Body/Torso,/datum/Body/Abdomen,/datum/Body/Organs,/datum/Body/Reproductive_Organs,/datum/Body/Arm,/datum/Body/Arm/Hand,/datum/Body/Arm,/datum/Body/Arm/Hand,/datum/Body/Leg,/datum/Body/Leg/Foot,/datum/Body/Leg,/datum/Body/Leg/Foot)
		else
			operation_list = genome.vital_list + genome.limb_list + genome.extra_limb_list
		if((Race == "Saiyan" || Parent_Race == "Saiyan" || istype(genome, /datum/genetics/Saiyan)) && !(/datum/Body/Tail/Saiyan_Tail in operation_list))
			operation_list += /datum/Body/Tail/Saiyan_Tail //force the Saiyan tail into the body (robust vs genome.extra_limb_list not propagating)
		for(var/i in operation_list)
			var/datum/Body/nB = new i
			//contents += nB
			//Datums cannot be appended to contents.
			body += nB
		var/list/running_counts = list()
		for(var/datum/Body/nB in body)
			running_counts[nB.type] += 1
			if(nB.symmetry_info[1] == 1)
				if(running_counts[nB.type] % 2 == 1)
					nB.name = "Left " + nB.name //left to right
					nB.symmetry_info[2] = "Left"
				else 
					nB.name = "Right " + nB.name
					nB.symmetry_info[2] = "Right"
				if(running_counts[nB.type] > 2)
					nB.name += " [(floor(running_counts[nB.type] - 1) / 2) + 1]"
					nB.symmetry_info[3] = (floor(running_counts[nB.type] - 1) / 2)
		for(var/datum/Body/nB in body)
			for(var/datum/Body/rP in get_Body_Parts(nB.req_parent_limb))
				if(nB.symmetry_info[2] == rP.symmetry_info[2] && rP.symmetry_info[3] == nB.symmetry_info[3])
					nB.parentlimb = rP
		sleep(2)
		if(Race=="Android")
			if(Reset||bupdateseed!=bresolveseed)
				sleep(5)
				Generate_Droid_Parts()
		bupdateseed=bresolveseed
		var/datum/Body/Tail/_T = get_Tail()
		if(_T) //Saiyan-type tail: the body is fully built now, so activate it (login sets mob.Tail=1; Refresh_Overlay adds the visible overlay). Runs after TestMobParts' own waitfor=0/sleep, so the part exists.
			_T.login(src)
			_T.Refresh_Overlay()

	proc/does_Body_Pair_Exist(var/bodytype)
		if(bodytype == null) return FALSE
		var/running_number = 0
		for(var/datum/Body/b in body)
			if(b.type == bodytype)
				running_number++
		return running_number
	proc/get_Body_Part(var/bodytype)
		if(bodytype == null) return FALSE
		for(var/datum/Body/b in body)
			if(b.type == bodytype)
				return b
	proc/get_Body_Parts(var/bodytype)
		var/list/running_list = list()
		if(bodytype == null) return FALSE
		for(var/datum/Body/b in body)
			if(b.type == bodytype)
				running_list += bodytype
		return running_list
	//a premade one for Tail species.
	proc/get_Tail()
		for(var/datum/Body/b in body)
			if(findtext(b.name, "Tail")) //BYOND `in` does NOT substring-match text ("Tail" in "Saiyan Tail" is FALSE); findtext is the real substring check so get_Tail/has_Tail finally work
				return b
	proc/has_Tail()
		if(get_Tail())
			return TRUE
		else
			return FALSE
	proc/is_Tail_Lopped()
		var/datum/Body/b = get_Tail()
		if(b)
			if(b.lopped)
				return TRUE
			else
				return FALSE
		else
			return TRUE
	proc/Lop_Tail()
		var/datum/Body/b = get_Tail()
		if(b)
			if(b.lopped)
				return FALSE
			else
				b.LopLimb()
				return TRUE
		else
			return FALSE
	proc/Grow_Tail()
		var/datum/Body/b = get_Tail()
		if(b)
			if(b.lopped)
				b.RegrowLimb()
				return TRUE
			else
				return FALSE
		else
			return FALSE


datum/Body
	Head
		icon_state = "Head"
		targettype = "head"
		vital = 1
		regenerationrate = 1
		isnested=0
		targetchance = 45
		healthweight = 7
		bodypartType = /obj/bodyparts/Head
		DamageMe(var/number as num, var/nonlethal as num)
			..()
			for(var/datum/Body/Head/Brain/B in savant.body)
				if(nonlethal)
					if(B.health - 0.2*number >= 0.1*B.maxhealth/savant.Ewillpower)//this has to be set lower than the KO threshold, otherwise they'll never get KO'd
						B.health -= (0.2*number)
					else
						B.health = min(0.1*B.maxhealth/savant.Ewillpower,B.health)
				else
					B.health -= (0.2*number)
				B.health = max(-10,B.health)
				if(B.health <= 0 && !nonlethal)//you can't cap the lower bound of health at 0, regen will keep bringing it above the threshold if you do
					B.LopLimb()
		Brain
			icon_state = "Brain"
			vital = 1
			maxeslots=0
			eslots = 0
			regenerationrate = 0.5
			targetable =0
			isnested=1
			targetchance = 30
			bodypartType = /obj/bodyparts/Brain
	Torso
		icon_state = "Torso"
		capacity = 3
		vital = 1
		eslots = 3
		maxeslots=3
		regenerationrate = 2
		isnested=0
		healthweight = 3
		targetchance = 60
		bodypartType = /obj/bodyparts/Torso
		DamageMe(var/number as num, var/nonlethal as num)
			..()
			if(prob(45) && number >= 10)
				if(savant.AbsorbDatum)
					savant.AbsorbDatum.expell()
			for(var/datum/Body/Organs/B in savant.body)
				if(nonlethal)
					if(B.health - 0.2*number >= 0.1*B.maxhealth/savant.Ewillpower)//this has to be set lower than the KO threshold, otherwise they'll never get KO'd
						B.health -= (0.2*number)
					else
						B.health = min(0.1*B.maxhealth/savant.Ewillpower,B.health)
				else
					B.health -= (0.2*number)
				B.health = max(-10,B.health)
				if(B.health <= 0 && !nonlethal)//you can't cap the lower bound of health at 0, regen will keep bringing it above the threshold if you do
					B.LopLimb()
	Abdomen
		icon_state = "Abdomen"
		capacity = 2
		eslots = 3
		maxeslots = 3
		targettype = "abdomen"
		vital = 1
		regenerationrate = 1.5
		isnested=0
		healthweight = 2.5
		targetchance = 55
		bodypartType = /obj/bodyparts/Abdomen
		DamageMe(var/number as num, var/nonlethal as num)
			..()
			if(prob(60) && number >= 10)
				if(savant.AbsorbDatum)
					savant.AbsorbDatum.expell()
	Organs
		icon_state = "Guts"
		capacity = 2
		eslots = 0
		maxeslots=0
		targettype = "chest"
		vital = 1
		regenerationrate = 1
		targetable =0
		isnested=1
		healthweight = 3
		targetchance = 30
		bodypartType = /obj/bodyparts/Guts
	Reproductive_Organs
		icon_state = "SOrgans"
		targettype = "abdomen"
		bodypartType = /obj/bodyparts/SOrgans
		LopLimb()
			..()
			savant.CanMate = 0
		RegrowLimb()
			..()
			savant.CanMate = 1
		capacity = 1
		eslots = 0
		maxeslots=0
		vital = 0
		regenerationrate = 0.5
		isnested=0
		targetchance = 55

	Arm
		icon_state = "Arm"
		targettype = "arm"
		capacity = 2
		eslots = 2
		maxeslots=2
		vital = 0
		regenerationrate = 2
		symmetry_info = list(1,"")
		isnested=0
		targetchance = 80
		healthweight = 0.125
		bodypartType = /obj/bodyparts/Arm
		Hand
			icon_state = "Hands"
			capacity = 1
			maxwslots = 1
			wslots = 1
			vital = 0
			regenerationrate = 2
			isnested=1
			targetchance = 65
			bodypartType = /obj/bodyparts/Hands
	Leg
		icon_state = "Limb"
		targettype = "leg"
		capacity = 2
		eslots = 2
		maxeslots = 2
		symmetry_info = list(1,"")
		vital = 0
		regenerationrate = 2
		isnested=0
		targetchance = 85
		healthweight = 0.125
		bodypartType = /obj/bodyparts/Limb
		Foot
			icon_state = "Foot"
			capacity = 1
			vital = 0
			regenerationrate = 2
			isnested=1
			targetchance = 70
			bodypartType = /obj/bodyparts/Foot
	Tail
		icon_state = "Guts" //temp
		targettype = "abdomen"
		capacity = 0
		eslots = 0
		maxeslots = 0
		symmetry_info = list(0,"",0) //not a paired limb, so no "Left/Right" prefix (was "Left Saiyan Tail"); 3 elements so the parentlimb pass never reads a missing [3]
		vital = 0
		regenerationrate = 0.125
		isnested=0
		targetchance = 25
		healthweight = 0.025
		bodypartType = /obj/bodyparts/Tail
		var
			tailicon = null
			get_Tail_Icon = TRUE
			tailType = /obj/overlay/hairs/tails/saiyantail
		login()
			..()
			if(tailicon == null && get_Tail_Icon == TRUE)
				tailicon = savant.tailicon
			if(lopped)
				savant.Tail = 0
			else
				savant.Tail = 1
			Refresh_Overlay() //also ADD the tail overlay so it renders; OnLogin's body loop calls login() every login -> fixes existing Saiyans
		LopLimb(var/nestedlop)
			if(..(nestedlop) == TRUE)
				return TRUE
			else
				return FALSE
			savant.removeOverlay(tailType)
			savant.Tail = 0
		RegrowLimb()
			..()
			savant.updateOverlay(tailType,tailicon)
			savant.Tail = 1
		proc/Refresh_Overlay()
			if(tailicon == null && get_Tail_Icon == TRUE) //always have an icon to draw
				tailicon = savant.tailicon
			if(!lopped) savant.Tail = 1 //the saiyantail overlay's EffectLoop holds alpha=0 unless mob.Tail is on
			else savant.Tail = 0
			savant.removeOverlay(tailType) //remove the old tail overlay first: updateOverlay's Update only resets the base icon (losing the runtime gold/blue tint), so re-adding forces EffectStart to re-apply the form color (fixes the tail going base/black on relog)
			savant.updateOverlay(tailType,tailicon)



obj/bodyparts
	Click()
		if(src in usr.contents)
			Eat()
		..()
		if(istype(usr,/mob))
			if(get_dist(loc,usr) <= 1 && loc != usr) GetMe(usr)
	proc
		GetMe(var/mob/TargetMob,messageless)
			if(Bolted)
				to_chat(TargetMob, "It is bolted to the ground, you cannot get it.")
				return FALSE
			if(TargetMob)
				if(!TargetMob.KO)
					for(var/turf/G in view(src)) G.gravity=0
					Move(TargetMob)
					if(!messageless)
						to_chat(view(TargetMob), "<font color=teal><font size=1>[TargetMob] picks up [src].")
						WriteToLog("rplog","[TargetMob] picks up [src]    ([time2text(world.realtime,"Day DD hh:mm")])")
					return TRUE
				else
					to_chat(TargetMob, "You cant, you are knocked out.")
					return FALSE
		DropMe(var/mob/TargetMob,messageless)
			if(equipped|suffix=="*Equipped*")
				to_chat(TargetMob, "You must unequip it first")
				return FALSE
			TargetMob.overlayList-=icon
			TargetMob.overlaychanged=1
			loc=TargetMob.loc
			step(src,TargetMob.dir)
			if(!messageless)
				to_chat(view(TargetMob), "<font size=1><font color=teal>[TargetMob] drops [src].")
				WriteToLog("rplog","[TargetMob] drops [src]    ([time2text(world.realtime,"Day DD hh:mm")])")
			return TRUE
	verb
		Get()
			set category=null
			set src in oview(1)
			GetMe(usr)
		Drop()
			set category=null
			set src in usr
			for(var/mob/M in get_step(usr,usr.dir))
				if(M in player_list && M != src)
					if(DropMe(usr,1))
						GetMe(M,1)
						M.contents += src
						WriteToLog("rplog","[usr] gives [src] to [M]   ([time2text(world.realtime,"Day DD hh:mm")])")
						to_chat(view(usr), "<font color=teal><font size=1>[usr] gives [src] to [M]")
						return
			DropMe(usr)
		Eat()
			set category = null
			set src in view(1)
			if(!usr.eating&&usr.CanEat)
				to_chat(usr, "[flavor]")
				to_chat(view(usr), "[usr] eats the [name]")
				usr.Hunger=0
				usr.eating=1
				usr.currentNutrition+=nutrition
				src.deleteMe()
			else
				if(usr.eating)
					to_chat(usr, "You need to wait to eat!")
				if(!usr.CanEat)
					to_chat(usr, "You can't digest food.")
	New()
		..()
		spawn(6000) src.loc = null
	var
		nutrition = 20
		flavor="You eat it and feel your hunger give way... it's somebody's body part!!"
	Head
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Head"
	Brain
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Brain"
	Limb
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Limb"
	Torso
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Torso"
	Abdomen
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Abdomen"
	Hands
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Hands"
	Arm
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Arm"
	SOrgans
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="SOrgans"
	Foot
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Foot"
	Guts
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Guts"
	Tail
		New()
			..()
			pixel_y+=rand(-32,32)
			pixel_x+=rand(-32,32)
		icon='Body Parts Bloody.dmi'
		icon_state="Guts"