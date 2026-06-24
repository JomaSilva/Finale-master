mob/var/tmp/summoning
obj/var/tmp/summoned=0

obj/DragonObject
	name = "Porunga"
	IsntAItem=1
	var/WishPower
	var/BallID
	icon='Dragon.dmi'
	icon_state="Porunga"
	proc/center()
		var/icon/A = icon(icon)
		pixel_x = (32 - (A.Width()/2))
	verb/Kill()
		set category = null
		set src in view(1)
		if(usr.expressedBP>=WishPower)
			view()<<"[usr] kills [src]! This renders the balls inert!"
			for(var/obj/DB/A)
				if(A.BallID == BallID)
					A.CompletelyInert = 1
			del(src)
		else
			view()<<"[usr] tries to kill [src]!"
			view()<<"It fails!"

obj/DragonStatue
	SaveItem = 1
	name = "Dragon Statue"
	desc = "A statue of a Dragon. A god could possibly create a wishgranting set of balls out of these. Has two functions: Redo and Revive. Anyone can destroy it."
	icon = 'DragonStatue.png'
	cantblueprint=1
	var/BallIcon = 'Dragonballs.dmi'
	var/BallID = null //The actual IDs of the balls. Every set of balls has an ID.
	var/icon/DragonIcon = 'Dragon.dmi'
	var/DragonState = "Shenron"
	var/Wishs = 1 //How many wishes, affects wishpower.
	var/WishPower = 1 //connected to the health and BP of the creator, along with wish count. You can't fake it through expressed BP.
	var/Ballplanet = null //what planet? If its null, it'll spawn on any planetary Z level.
	var/OffTime = 1 //The time in YEARS for the balls to become active again. 0.5 is 5 months, 1 is one whole year. Years/months are 10 months to 1 year. Makes it simple.
	var/ActiveYear = 1.5 //When the balls will be active again. If you destroy the balls and recreate them, you could technically have shorter wishes.
	var/tmp/mob/Creator = null //the creator of the balls.
	var/CreatorSig = null //creator's sig.
	var/title = "THE ETERNAL DRAGON"
	var/inbetween = ", "
	var/dragonname = "SHENRON"
	var/CompletelyInert = 0 //Triggered when the Dragon dies, the Statue dies, or the Creator dies. Saved within the Creators and Statue's variables.
	//If the Statue dies, the inert balls are deleted.
	verb/Destroy_Statue()
		set category = null
		set src in view(1)
		CompletelyInert = 1
		view()<<"[usr] destroys [src]! This renders the balls dead!"
		for(var/obj/DB/A)
			if(A.BallID == BallID)
				del(A)
		del(src)
	verb/Redo()
		set category = null
		set src in view(1)
		if(Creator == usr)
			view()<<"[usr] is reconfiguring the [src]!"
			view()<<"[src] upgraded to [usr.BP]!"
			Wishs = max(min((input(usr,"Set the number of wishes, from 1 to 3.","",1) as num),3),1)
			WishPower = usr.BP
			dragonname = input(usr,"Set the dragon's name. Dragons usually speak in uppercase.","","SHENRON") as text
			title = input(usr,"Set the dragon's title. Leave it blank for nothing.","","THE ETERNAL DRAGON") as text
			backhere
			switch(alert(usr,"Change the icons?","","Yes (Custom)","No","Make it Default"))
				if("Yes (Custom)")
					switch(alert(usr,"Change which icon?","","Cancel","Dragon","Balls"))
						if("Dragon")
							DragonIcon = input(usr,"Set the dragon's icon.","",DragonIcon) as icon
							DragonState = input(usr,"Icon state?","","Shenron") as text
						if("Balls")
							BallIcon = input(usr,"Set the ball icon. Make sure it has 8 icon states, is 32x32, labled '1' '2' and '3' and so on respectively, along with a 'inactive' state.","",BallIcon) as icon
					goto backhere
				if("Make it Default")
					var/area/A = GetArea()
					if(A.Planet!="Namek")
						BallIcon = 'Dragonballs.dmi'
						DragonIcon = 'Dragon.dmi'
						DragonState = "Shenron"
					else
						BallIcon = 'dragonball.dmi'
						DragonIcon = 'Dragon.dmi'
						DragonState = "Porunga"
			RecreateBalls()
	verb/Revive_Set()
		set category = null
		set src in view(1)
		if(Creator == usr&&!usr.dead)
			view()<<"[usr] revived the [src]!"
			CompletelyInert = 0
			var/ballcount
			for(var/obj/DB/A)
				if(A.BallID == BallID)
					ballcount+=1
			if(ballcount<=6)
				RecreateBalls()

	proc/RecreateBalls()
		for(var/obj/DB/A)
			if(A.BallID == BallID)
				del(A)
		var/NeededBallCount = 7
		if(Year>= ActiveYear) ActiveYear = Year + 0.4
		while(NeededBallCount>=1)
			var/obj/DB/A = new()
			A.BallNum = NeededBallCount
			NeededBallCount-=1
			A.loc = usr.loc
			A.name = "[Creator] Dragonballs ([A.BallNum] - [BallID])"
			A.HomeStatue = src
			A.DragonIcon = DragonIcon
			A.DragonState = DragonState
			A.Wishs = Wishs
			A.WishPower = WishPower
			A.Ballplanet = Ballplanet
			A.BallID = BallID
			A.OffTime = OffTime
			A.ActiveYear = ActiveYear
			A.Creator = Creator
			A.title = title
			A.inbetween = inbetween
			A.dragonname = dragonname
			A.IsInactive = 1
			A.Scatter()
	proc/RefreshCreator()
		set background = 1
		set waitfor = 0
		if(Creator == null)
			for(var/mob/M)
				sleep(1)
				if(M.signature == CreatorSig)
					Creator = M
					break
		sleep(100)
		RefreshCreator()

	New()
		..()
		if(!BallID)
			recalcrand
			BallID = rand(1,999)
			for(var/obj/DragonStatue/A)
				if(A.BallID == BallID&&A!=src)
					goto recalcrand
					break
		spawn RefreshCreator()
obj/DB
	SaveItem = 1 //save the balls damn it
	icon = 'Dragonballs.dmi'
	icon_state = "inactive"
	cantblueprint=1
	var/icon/DragonIcon = 'Dragon.dmi'
	var/DragonState = "Shenron"
	var/BallNum = 1
	var/Wishs = 1
	var/tmp/WishCount = 0
	var/WishPower = 1
	var/Ballplanet = null
	var/BallID = 1
	var/OffTime = 1
	var/IsInactive = 1
	var/ActiveYear = 1.5
	var/tmp/mob/Creator = null //the creator of the balls.
	var/tmp/creator_power = 0
	var/title = "THE ETERNAL DRAGON"
	var/inbetween = ", "
	var/dragonname = "SHENRON"
	var/CompletelyInert = 0
	var/obj/DragonStatue/HomeStatue = null
	var/mob/container = null

	verb/Destroy_Ball()
		set category = null
		set src in view(1)
		HomeStatue.CompletelyInert = 1
		view()<<"[usr] destroys [src]! This renders the balls inert!"
		del(src)
	verb/D_Wish()
		set category = null
		set name = "Wish"
		set src in view(1)
		var/ballnum
		for(var/obj/DB/A in view(1,usr))
			if(A.BallID == BallID&&!IsInactive)
				ballnum+=1
		for(var/obj/DragonStatue/A)
			if(A.BallID == BallID)
				DragonIcon = A.DragonIcon
				DragonState = A.DragonState
				Wishs = A.Wishs
				WishPower = A.WishPower
				Ballplanet = A.Ballplanet
				OffTime = A.OffTime
				ActiveYear = A.ActiveYear
				Creator = A.Creator
				title = A.title
				inbetween = A.inbetween
				dragonname = A.dragonname
				IsInactive = A.CompletelyInert
				break
		if(ballnum==7&&!usr.summoning&&!summoned)
			var/exists
			summoned = 1
			for(var/obj/DragonObject/A in view(1,src))
				exists = 1
				break
			if(!exists)
				var/obj/DragonObject/A = new()
				A.icon = DragonIcon
				A.icon_state = DragonState
				A.name = dragonname
				A.WishPower = WishPower
				A.BallID = BallID
				A.center()
				A.loc = locate(src.x,src.y+1,src.z)
				if(title!="")
					inbetween = ", "
				else
					inbetween = "!"
				view(7)<<output("<font size=[4]><font color=red><font face=Old English Text MT>[dragonname] says, 'I AM [dragonname][inbetween][title]! STATE YOUR WISH!'","Chatpane.Chat")
				usr.emit_Sound('dragonballsuse.ogg')
			usr.summoning = 1
			WishCount += GenerateWishList(usr)
			for(var/obj/DragonObject/C in obj_list)
				if(C.BallID == BallID)
					del(C)
			for(var/obj/DB/A in obj_list)
				if(A.BallID == BallID)
					A.IsInactive = 1
					A.ActiveYear = Year + OffTime * (WishCount / Wishs)
					HomeStatue.ActiveYear = Year + OffTime
					A.summoned=0
					A.Scatter()
			usr.emit_Sound('dragonballsdone.ogg')
			usr.summoning = 0
		else
			usr<<"Wish failed!"

	proc/Scatter()
		usr.emit_Sound('db_flying.wav')
		for(var/obj/DragonObject/S in view()) del(S)
		spawn
			var/obj/B=new/obj/attack/blast
			B.loc=locate(x,y,z)
			B.icon='16.dmi'
			B.icon_state="16"
			B.icon+=rgb(255,255,0)
			B.density=0
			B.Pow=20
			B.BP=500000
			spawn()
				step(B,NORTH,1)
				step(B,NORTH,1)
				step(B,NORTH,1)
				step(B,NORTH,1)
				step(B,NORTH,1)
				step(B,NORTH,1)
				walk_rand(B)
				spawn(30) del(B)
		var/area/targetArea
		var/templanet
		if(!Ballplanet)
			templanet = pick("Earth","Namek","Desert","Space") //no ball 'planet' results in the balls being spread accross the entire gameworld
		else templanet = Ballplanet
		for(var/area/A in area_outside_list)
			CHECK_TICK
			if(A.Planet == templanet)
				targetArea = A
		if(targetArea)
			var/turf/temploc = pickTurf(targetArea,2)
			src.loc = (locate(temploc.x,temploc.y,temploc.z))
		return
	proc/Tick()
		set waitfor = 0
		set background = 1
		if(IsInactive == 1)
			if(ActiveYear <= Year&&!CompletelyInert)
				icon_state = "[BallNum]"
				IsInactive = 0
		if(CompletelyInert == 1)
			if(IsInactive == 0)
				IsInactive = 1
		if(CompletelyInert == 0)
			if(!isnull(Creator)&&Creator.dead)
				CompletelyInert = 1
			if(HomeStatue==null)
				del(src)
		if(isnull(Creator))
			spawn
				for(var/obj/DragonStatue/C)
					sleep(1)
					if(C.BallID == src.BallID)
						Creator = C.Creator
						break
		if(!summoned&&/obj/DragonObject in view(1))
			for(var/obj/DB/A in view(1))
				if(A.summoned) break
				for(var/obj/DragonObject/B in view(1))
					if(B.BallID == BallID)
						del(B)
		switch(BallNum)
			if(2)
				pixel_y=9
			if(3)
				pixel_y=-9
			if(4)
				pixel_x=9
			if(5)
				pixel_x=-9
			if(6)
				pixel_x=9
				pixel_y=9
			if(7)
				pixel_x=-9
				pixel_y=-9
		if(!container)
			var/area/getArea = GetArea()
			if(!getArea)
				getArea = GetArea()
			if(getArea && getArea.Planet != Ballplanet)
				if(container) OnRelease()
				Scatter()
		spawn(100) Tick()
	proc/OnGrab()
		Move(container)
		view(container)<<"<font color=teal><font size=1>[container] picks up [src]."
		WriteToLog("rplog","[container] picks up [src]    ([time2text(world.realtime,"Day DD hh:mm")])")
		return

	proc/OnRelease()
		loc=container.loc
		step(src,usr.dir)
		view(container)<<"<font size=1><font color=teal>[container] drops [src]."
		container = null
		return
	verb
		Get()
			set category=null
			set src in oview(1)
			if(usr)
				if(!usr.KO)
					container = usr
					OnGrab()
				else usr<<"You cant, you are knocked out."
		Drop()
			set category=null
			set src in usr
			OnRelease()

	New()
		..()
		spawn(100) Tick()
mob/Admin3/verb/Set_Dragonballs_Active()
	set category = "Admin"
	var/choice = input(usr,"Input ball ID, found by editing and looking at 'BallID' in the corrosponding Dragon Statue.","",1) as num
	for(var/obj/DB/A)
		if(A.BallID == choice)
			A.ActiveYear = Year-0.1
	for(var/obj/DragonStatue/A)
		if(A.BallID == choice)
			A.ActiveYear = Year-0.1
mob/Admin3/verb/Bring_Dragonballs()
	set category = "Admin"
	var/choice = input(usr,"Input ball ID, found by editing and looking at 'BallID' in the corrosponding Dragon Statue.","",1) as num
	for(var/obj/DB/A)
		if(A.BallID == choice)
			A.loc = locate(x,y,z)

mob/Admin3/verb/View_Ball_ID(var/obj/A)
	set hidden = 1
	set category = "Admin"
	if(istype(A,/obj/DB)||istype(A,/obj/DragonStatue))
		usr<<"Ball ID = [A:BallID]"
	return usr << "Not a Dragonball or Dragon Statue."