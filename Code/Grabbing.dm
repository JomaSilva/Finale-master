mob/verb/Steal()
	set category="Skills"
	var/list/steallist = list()
	for(var/mob/M in get_step(src,dir)) if(!KO&&M.KO&&canfight&&M.attackable&&!Apeshit)
		steallist += M
	var/mob/choice = input(usr,"Who to steal from?") as null|mob in steallist
	if(!isnull(choice))
		var/mob/M = choice
		if(M.KO)
			var/list/grabList = list()
			for(var/obj/items/A in M.contents)
				if(equipped|suffix=="*Equipped*") continue
				if(A.canGrab&&!A.IsntAItem)
					grabList += A
			grabList += "Zenni"
			var/choice2 = input(usr,"Steal what?") as null|anything in grabList
			if(isobj(choice2))
				var/obj/items/realchoice = choice2
				if(realchoice.DropMe(M,1))
					realchoice.GetMe(usr,1)
					usr.contents += realchoice
					WriteToLog("rplog","[usr] steals [realchoice] from [M]   ([time2text(world.realtime,"Day DD hh:mm")])")
					view(usr) << "<font color=teal><font size=1>[usr] steals [realchoice] from [M]!"
					return
			else if(choice == "Zenni")
				view(usr)<<"[src]([displaykey]) steals [M]'s zenni! ([M.zenni]z)"
				zenni+=M.zenni
				M.zenni=0
		else usr<<"They must be knocked out to steal this."
	//stealing needs a rework
mob/var/tmp
	mob/grabbee //who is grabbing you
	grabberSTR //the strength of the person grabbing you.
	obj/objgrabbee
	grabMode = 0 //0 is not grabbing, 1 is throwing/latch on, 2 is picking up

	is_choking = 0 //wether or not you are choking someone.

obj/items/Click()
	..()
	if(istype(usr,/mob))
		if(get_dist(loc,usr) <= 1 && loc != usr && !Bolted)
			Get()
			usr.inven_min++
			usr.InvenSet()

mob/verb
	Grab()
		set category="Skills"
		if(is_stretched && !stretch_bring)
			stretch_bring = 1
			return
		else if(is_stretched)
			stretch_bring = 0
			return
		if(!grabbee&&!objgrabbee)
			grabMode = 0
			grabbee = null
			objgrabbee = null
		if(grabMode==2)
			if(grabbee||objgrabbee)
				grabMode = 0
				if(grabbee)
					usr<<"You release [grabbee]."
					emit_Sound('groundhit.wav')
					is_choking = 0
					//canfight=1
					grabbee.grabParalysis = 0
					grabbee.grabberSTR=null
					grabbee.grabber = null
					grabbee=null
				if(objgrabbee)
					usr<<"You release [objgrabbee]."
					emit_Sound('groundhit.wav')
					//canfight=1
					objgrabbee=null
				return
		if(grabMode==1)
			if(grabbee||objgrabbee)
				if(grabbee)
					usr<<"You pick up [grabbee]."
					grabMode = 2
					grabbee.grabberSTR*=1.5
				if(objgrabbee)
					if(usr.CheckInventory()==TRUE)return
					if(usr.inven_min<usr.inven_max)
						usr<<"You pick up [objgrabbee]."
						grabMode = 2
						usr.inven_min++
						usr.InvenSet()
						spawn objgrab()
					else
						usr<<"You have no space in your inventory."
						return
				return
		if(KO||attacking||!canfight) return
		if(ismob(target) && !isnull(target)) if(can_stretch_arms && target in view(screenx,src) && get_dist(target.loc,src.loc)>=3)
			stretch_arms(target)
			return
		var/list/grabList = list()
		for(var/obj/A in get_step(src,dir)) if(!istype(A,/obj/attack/blast)) if(A.canGrab&&!A.IsntAItem)
			grabList += A
		for(var/obj/A in loc) if(!istype(A,/obj/attack/blast)) if(A.canGrab&&!A.IsntAItem&&isturf(A.loc))
			grabList += A
		for(var/mob/A in get_step(src,dir)) if(A != src)
			grabList += A
		var/obj/A
		if(grabList.len>=2)
			A = input(src,"Grab what?") as null|anything in grabList
			usr.inven_min++
			usr.InvenSet()
		else if(grabList.len == 1)
			A = grabList[1]
			usr.inven_min++
			usr.InvenSet()
		else
			return
		if(A.type == null)
			return
		if(istype(A,/obj))
			if(A.Bolted)
				src<<"It is bolted to the ground, you cannot get it."
				return
		if(istype(A,/obj/Zenni))
			usr<<"You pick up [A]."
			oview(usr)<<"<font size=1><font color=teal>[usr] picks up [A.zenni]z."
			WriteToLog("rplog","[usr] picks up [A.zenni]z    ([time2text(world.realtime,"Day DD hh:mm")])")
			usr.zenni+=A.zenni
			del(A)
			return
		if(istype(A,/obj/items))
			if(src)
				if(!KO)
					A:GetMe(usr)
					if(A == /obj/items/Nav_System)
						src.hasnav=1
				else usr<<"You can't, you are knocked out."
			return
		if(istype(A,/obj/Modules))
			if(src)
				if(!KO)
					//for(var/turf/G in view(A)) G.gravity=0
					A.Move(src)
					if(A == /obj/items/Nav_System)
						src.hasnav=1
					view(src)<<"<font color=teal><font size=1>[src] picks up [A]."
					WriteToLog("rplog","[usr] picks up [A]    ([time2text(world.realtime,"Day DD hh:mm")])")
				else usr<<"You can't, you are knocked out."
			return
		if(A.type in typesof(/obj/Artifacts))
			var/obj/Artifacts/C = A
			if(C.Unmovable)
				src<<"It is still. You cannot get it."
				return
			if(src)
				if(!KO)
					C.container = usr
					C.OnGrab()
				else usr<<"You can't, you are knocked out."
			return
		if(istype(A,/obj)) //If grab doesn't work on mobs/objs, change it to A.type in typesof(/obj) or A.type in typesof(/mob)
			if(!objgrabbee)
				usr<<"You latch on to [A]! You can throw [A] by moving!"
				objgrabbee=A
				grabMode = 1
				//canfight=0
				return
		if(istype(A,/mob)) //See above
			var/mob/M = A
			if(!grabbee&&!M.grabber)
				usr<<"You grab [M]! You can throw [M] by moving!"
				M.totalTime = 0
				emit_Sound('mediumpunch.wav')
				grabbee=M
				M.grabber = src
				M.grabberSTR=(Ephysoff*expressedBP)
				grabMode = 1
				M.grabParalysis = 1
				spawn grab()
				//canfight=0
				return
mob/proc/grab()
	while(grabbee && grabMode)
		grabbee.grabberSTR=(Ephysoff*expressedBP)
		if(grabMode==2)
			grabbee.dir=turn(dir,180)
		grabbee.grabParalysis = 1
		if(KO||grabbee.z!=usr.z||totalTime==0||(grabMode==1 && !grabbee in get_step(src,dir)))
			view()<<"[usr] is forced to release [grabbee]!"
			emit_Sound('groundhit2.wav')
			grabbee.grabberSTR=null
			grabbee.grabber = null
			//grabbee.canfight=1
			grabbee.grabParalysis = 0
			is_choking = 0
			grabMode=0
			//canfight=1
			grabbee=null
		if(grabMode==2) grabbee.loc=locate(x,y,z)
		sleep(1)
	grabMode=0
	if(grabbee) grabbee.grabParalysis = 1
	is_choking = 0
	//canfight=1
mob/proc/objgrab()
	while(objgrabbee)
		objgrabbee.loc=locate(x,y,z)
		if(KO)
			view()<<"[usr] is forced to release [objgrabbee]!"
			emit_Sound('mediumpunch.wav')
			objgrabbee=null
		sleep(1)

obj/items
	var/amount=1
	suffix="1"
	verb
		Get()
			set category=null
			set src in oview(1)
			if(Bolted)
				usr<<"It is bolted to the ground, you cannot get it."
				return FALSE
			if(usr.CheckInventory()==TRUE)return
			usr.inven_min++
			usr.InvenSet()
			if(stackable)
				var/obj/items/object = locate(text2path("[src.type]")) in usr.contents
				if(object) //could find previous type of object
					object.addAmount(src.amount)
					src.amount = 0
					del(src)
			GetMe(usr)
		Drop_All() //will drop every single of the stacked object
			set category=null
			set src in usr
			src.Move(usr.loc)
		Drop(n=0 as num)
			set category=null
			set src in usr
			for(var/mob/M in get_step(usr,usr.dir))
				if(M in player_list && M != src)
					if(DropMe(usr,1))
						GetMe(M,1)
						M.contents += src
						WriteToLog("rplog","[usr] gives [src] to [M]   ([time2text(world.realtime,"Day DD hh:mm")])")
						view(usr) << "<font color=teal><font size=1>[usr] gives [src] to [M]"
						return
			if(n>src.amount)n=src.amount //if it's above the items amount
			if(n<=0)n=1 //if it's below 0
			if(src.amount==n)
				DropMe(usr)
			else
				src.removeAmount(n)
				var/obj/items/O = new src.type
				O.addAmount(n-1) //n-1 because objects default amounts are 1
				O.loc=usr.loc
			if(usr.CheckInventory()==TRUE)return
			usr.inven_min--
			usr.InvenSet()


	proc
		GetMe(var/mob/TargetMob,messageless)
			if(Bolted)
				TargetMob<<"It is bolted to the ground, you cannot get it."
				return FALSE
			if(TargetMob)
				if(TargetMob.inven_min<TargetMob.inven_max)
					if(!TargetMob.KO)
						//for(var/turf/G in view(src)) G.gravity=0
						Move(TargetMob)
						if(!messageless)
							view(TargetMob)<<"<font color=teal><font size=1>[TargetMob] picks up [src]."
							WriteToLog("rplog","[TargetMob] picks up [src]    ([time2text(world.realtime,"Day DD hh:mm")])")
						return TRUE
					else
						TargetMob<<"You cant, you are knocked out."
						return FALSE
				TargetMob<<"You have no space in your inventory."
				return


		DropMe(var/mob/TargetMob,messageless)
			if(equipped|suffix=="*Equipped*")
				TargetMob<<"You must unequip it first"
				return FALSE
			TargetMob.overlayList-=icon
			TargetMob.overlaychanged=1
			loc=TargetMob.loc
			step(src,TargetMob.dir)
			if(!messageless)
				view(TargetMob)<<"<font size=1><font color=teal>[TargetMob] drops [src]."
				WriteToLog("rplog","[TargetMob] drops [src]    ([time2text(world.realtime,"Day DD hh:mm")])")

			return TRUE
		Condense()
			if(stackable)
				var/obj/items/object = locate(text2path("[src.type]")) in usr.contents
				if(object&&object!=src) //could find previous type of object
					object.addAmount(src.amount)
					del(src)
					return TRUE
			else
				return FALSE
	proc
		addAmount(n as num)
			if(!src.stackable)return
			src.amount+=n
			src.suffix="[src.amount]"
		removeAmount(n as num)
			if(!src.stackable)return
			if(n == 0) n = 1
			//if(src.amount < n)
			//	n = src.amount
			src.amount-=n
			if(src.amount<=0)
				DropMe(usr)

			else
				src.suffix="[src.amount]"

	New()
		..()
		if(!src.stackable)src.suffix=""

mob/proc/get_me_a_grab(grb_type)
	if(grabbee) return TRUE
	var/list/grabList = list()
	for(var/mob/A in get_step(src,dir)) if(A != src)
		grabList += A
	if(grabList.len)
		var/mob/M = pick(grabList)
		if(!grabbee&&!M.grabber)
			usr<<"You grab [M]! You can throw [M] by moving!"
			spawn grab()
			emit_Sound('mediumpunch.wav')
			grabbee=M
			M.grabber = src
			M.grabberSTR=(Ephysoff*expressedBP)
			grabMode = 1
			M.grabParalysis = 1
			//canfight=0
			if(grb_type)
				usr<<"You pick up [grabbee]."
				grabMode = 2
				grabbee.grabberSTR*=1.5
			return TRUE
	return FALSE
