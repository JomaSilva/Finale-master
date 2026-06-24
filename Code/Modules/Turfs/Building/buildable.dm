obj/Creatables
	Wall_Repair
		icon = 'smalldish.dmi'
		cost=75000
		neededtech=15
		desc="Automatically heals all barriers in its range every minute. Will not bring back already destroyed barriers. Turf walls don't have health! Use Wall Upgrader for walls!"
		create_type = /obj/items/Wall_Repair
	Wall_Upgrader
		icon = 'upgrader.dmi'
		cost=80000
		neededtech=20
		desc="Automatically heals all barriers. Upon manual activation (click it.) it'll upgrade all objects in range, including itself."
		create_type = /obj/items/Wall_Upgrader
	Portable_Repairer
		icon = 'Controller.dmi'
		cost=80000
		neededtech=25
		desc="Heal barriers on the fly! Heals all barriers in a small radius around you."
		create_type = /obj/items/Portable_Repairer
	Destructor
		icon = 'Drill Hand 3.dmi'
		cost=80000
		neededtech=20
		desc="Destroy barriers and tiles in a small radius around you. This will destroy most items in the game!"
		create_type = /obj/items/Destructor
	Bolter
		icon = 'Item, Blaster.dmi'
		icon_state = "Blaster Big"
		cost = 60000
		neededtech = 20
		desc="Bolters can be used to bolt things you own down. Also is a gun."
		create_type = /obj/items/Guns/Bolter
	Recreator
		icon = 'Item, Blaster.dmi'
		icon_state = "Blaster Big"
		cost = 75000
		neededtech = 30
		desc="Recreators use resources to recreate sections of tiles. Activate it via clicking it, selecting two points. It'll save just the turfs and buildable objects in those two points. You can download, and upload, this savefile. It'll cost 10 zenni per turf, 100 zenni per build object. Maximum 30 by 30 size."
		create_type = /obj/items/Recreator
obj/items
	Wall_Repair
		icon = 'smalldish.dmi'
		desc = "Automatically heals all walls in its range every minute. Will not bring back already destroyed walls."
		SaveItem=1
		fragile=1
		density=1
		New()
			..()
			Ticker()
		proc/Ticker()
			set waitfor = 0
			set background = 1
			var/obj/overlay/effects/Z = new
			Z.icon = 'Shockwavecustom128.dmi'
			Z.pixel_x = -48
			Z.pixel_y = -48
			overlays += Z
			flick("1",Z)
			sleep(5)
			overlays -= Z
			del(Z)
			for(var/obj/M in range(15,src))
				if(M.fragile)
					healDamage(maxarmor)
			sleep(600)
			spawn Ticker()
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
						Bolted=1
						boltersig=usr.signature
			else if(Bolted&&boltersig==usr.signature)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
						Bolted=0
	Wall_Upgrader
		icon = 'upgrader.dmi'
		desc = "Automatically heals all barriers. Upon manual activation (click it.) it'll upgrade all objects in range, including itself."
		SaveItem=1
		fragile=1
		density=1
		New()
			..()
			Ticker()
		proc/Ticker()
			set waitfor = 0
			set background = 1
			for(var/obj/M in range(15,src))
				if(M.fragile)
					healDamage(maxarmor)
			sleep(600)
			spawn Ticker()
		Click()
			var/obj/overlay/effects/Z = new
			Z.icon = 'Shockwavecustom128.dmi'
			Z.pixel_x = -48
			Z.pixel_y = -48
			overlays += Z
			flick("1",Z)
			sleep(5)
			overlays -= Z
			del(Z)
			for(var/obj/M in range(15,src))
				if(M.fragile)
					M.maxarmor = usr.intBPcap
					healDamage(M.maxarmor)
			for(var/turf/T in range(15,src))
				if(T.Resistance<usr.intBPcap)
					T.Resistance=usr.intBPcap
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
						Bolted=1
						boltersig=usr.signature
			else if(Bolted&&boltersig==usr.signature)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
						Bolted=0
	Portable_Repairer
		icon = 'Controller.dmi'
		desc = "Upon manual activation (click it.) it'll heal all objects in range, including itself."
		SaveItem=1
		Click()
			var/obj/overlay/effects/Z = new
			Z.icon = 'Shockwavecustom64.dmi'
			Z.pixel_x = -16
			Z.pixel_y = -16
			overlays += Z
			flick("1",Z)
			sleep(5)
			overlays -= Z
			del(Z)
			for(var/obj/M in range(1,src))
				if(M.fragile)
					healDamage(M.maxarmor)
	Destructor
		icon = 'Drill Hand 3.dmi'
		desc = "Destroy barriers and tiles in a small radius around you, for a small cost (5000 zenni) This will destroy most items in the game!"
		Click()
			set waitfor = 0
			if(usr.zenni<=4999)
				return
			else
				usr.zenni-=5000
			if(!src in usr) return
			var/obj/overlay/effects/Z = new
			Z.icon = 'Shockwavecustom64.dmi'
			Z.pixel_x = -16
			Z.pixel_y = -16
			usr.overlayList+=Z
			usr.overlaychanged = 1
			flick("1",Z)
			sleep(5)
			usr.overlayList-=Z
			usr.overlaychanged = 1
			del(Z)
			for(var/obj/M in view(1,usr))
				sleep(1)
				if(M==src && !isturf(M.loc)) continue
				if(M.fragile&&(M.armor<=usr.intBPcap||M.proprietor==usr.key))
					M.takeDamage(maxarmor*5)
			emit_Sound('kiplosion.wav')
			for(var/turf/T in range(1,usr))
				if(T.Resistance<=usr.intBPcap||T.proprietor==usr.key)
					createDust(T,1)
					T.Destroy()
	Guns/Bolter
		New()
			..()
			BlasterR=rand(0,255)
			BlasterG=rand(0,255)
			BlasterB=rand(0,255)
		icon='Ki_Blaster.dmi'
		fireType = "Energy"
		BulletIcon='23.dmi'
		power=1
		powerlevel=100
		BulletState="23"
		Click()
			set category=null
			if(!usr.med&&!usr.train&&!usr.KO&&!usr.blasting&&reserve>=1)
				usr.blasting=1
				var/obj/attack/blast/A=new/obj/attack/blast/
				A.loc=locate(usr.x,usr.y,usr.z)
				A.icon=BulletIcon
				A.icon_state=BulletState
				A.icon+=rgb(BlasterR,BlasterG,BlasterB)
				A.density=1
				if(knockback) A.shockwave=1
				if(stun) A.paralysis=1
				A.Pow=power
				A.BP=powerlevel
				A.murderToggle=0
				if(prob(critical))
					A.BP*=10
				walk(A,usr.dir)
				reserve-=1
				spawn(150/refire)
				usr.blasting=0
				if(reserve<1) usr<<"[src]: Out of energy!"
		verb/Bolt(var/obj/O in oview(1))
			set category=null
			if(O.proprietor == usr.ckey)
				if(O.x&&O.y&&O.z&&!O.Bolted)
					switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
						if("Yes")
							view(src)<<"<font size=1>[usr] bolts the [O] to the ground."
							O.Bolted=1
							O.boltersig=usr.signature
				else if(O.Bolted&&O.boltersig==usr.signature)
					switch(input("Unbolt?","",text) in list("Yes","No",))
						if("Yes")
							view(src)<<"<font size=1>[usr] unbolts the [O] from the ground."
							O.Bolted=0
	Recreator
		icon='Ki_Blaster.dmi'
		var/tmp/x1y1
		var/tmp/x2y2
		var/list/saveloc = list()
		var/tmp/saving=0
		//var/save_loc = "Save/.../[id].objsav"
		var/id=0
		var/savkey=0
		var/soverride=0
		var/moneecost = 0
		var/can_load = 0
		New()
			..()
			if(!id) id = rand(1,10000)
			if(can_load) spawn(1000) can_load = 0
		Click()
			set category=null
			if(savkey && savkey == usr.ckey || soverride)
			else if(!savkey)
				usr << "Recreator tuned to your soul. (Can be used on alts with same ckey.)"
				savkey = usr.ckey
			else
				usr << "Recreator not tuned to your soul"
				return
			if(can_load)
				usr << "Loaded map recently."
				return
			if(saving)
				if(x1y1)
					x2y2 = usr.loc
					switch(input("x2 y2 set. Save? Pressing no will reset this. [desc]") in list("Yes","No"))
						if("Yes")
							if(get_dist(x1y1,x2y2) > 30)
								saving = 0
								usr << "Too far away [get_dist(x1y1,x2y2)]"
								return
							saveloc = list(usr.x,usr.y,usr.z)
							var/amount=0
							moneecost=0
							fdel("Save/[savkey]/[id].objsav")
							var/savefile/F=new("Save/[savkey]/[id].objsav")
							var/list/L=new/list
							for(var/turf/T in block(x1y1,x2y2))
								if(T.proprietor == usr.ckey)
									L += T
									moneecost+=10
									amount++
								for(var/obj/buildables/O in T.contents)
									if(O.loc == T)
										L += T
										moneecost+=100
										amount++
							L["monee"] = moneecost
							L["saveloc"] = saveloc
							F<<L
							usr<<"Tiles/Objs Saved ([amount]) (Zenni: )"
						if("No")
							saving = 0
							return
				else
					x1y1 = usr.loc
					usr << "x1y1 set."
					return
			if(!fexists("Save/[savkey]/[id].objsav"))
				var/list/oplist = list()
				oplist += "Yes"
				oplist += "No"
				var/nudisc = "[desc]"
				if(Admin>=2)
					nudisc = " Uploading will overwrite. Make sure the file extension is .objsav. Unlinking will let others 'remake' this. Unlinking is permanent. [desc]"
					oplist += "Upload"
					oplist += "Upload and Unlink"
				switch(input("File doesn't exist. New? [nudisc]") in oplist)
					if("Yes")
						x1y1 = null
						x2y2 = null
						saving=1
						usr<<"Click on this again to set coordinates. Maximum distance between blocks is 30 tiles (about one view screen.)"
					if("Upload")
						var/savefile/F=new("Save/[savkey]/[id].objsav")
						F << input(usr,"Upload a file.")
						F["monee"] >> moneecost
						F["saveloc"] >> saveloc
					if("Upload and Unlink")
						var/savefile/F=new("Save/[savkey]/[id].objsav")
						F << input(usr,"Upload a file.")
						F["monee"] >> moneecost
						F["saveloc"] >> saveloc
						soverride=1
			else
				switch(input("File exists. It costs [moneecost]. Load? Must be 40 tiles away or less to load.") in list("Yes","No","Delete file","Download"))
					if("Yes")
						if(get_dist(usr,locate(saveloc[1],saveloc[2],saveloc[3])) > 40 || saveloc[3] != usr.z)
							usr << "Too far."
							return
						if(usr.zenni < moneecost)
							usr << "It costs [moneecost] zenni."
							return
						usr.zenni -= moneecost
						var/savefile/F=new("Save/[savkey]/[id].objsav")
						var/list/L=new/list
						F>>L
						can_load=1
						spawn(1000) can_load = 0
						WriteToLog("admin","[usr] [usr.ckey] loaded a map at [usr.loc].")
					if("Delete file")
						fdel("Save/[savkey]/[id].objsav")
					if("Download")
						var/savefile/F=new("Save/[savkey]/[id].objsav")
						usr<<ftp(F)
turf/wall
	Free=1
	Exclusive=1
	density=1

mob/var/tmp
	isbuilding = 0
	buildstate = 0
	buildpath

var/builtobjects=0
mob/var/buildon
mob/var/tmp/upgrading
obj/var
	canbuild
	techlevel
	buildcost
	Resistance=20
	BUILDRES=1
	BUILDPASS
	BUILDOWNER
turf/var
	Free=1
	Exclusive=0
	Resistance=20
	password
	proprietor
	isbuilt

turf/var/fire=0
turf/build/var/canbuild=1
turf/build/var/techlevel
turf/build/var/buildcost
obj/buildables/var/fire
obj/var/Exclusive=0 //can you build on it at all
obj/var/Free=1 //can you build at it without ownership
obj/var/isFire

atom/var
	lightme
	lightradius
	lightintensity

mob/proc/BuildATileHere(var/turf/location,subbuild)
	set waitfor = 0
	if(isnull(location)||!buildable) return FALSE
	var/Btemp
	for(var/turf/S in view(0,usr))
		Btemp = image(S.icon,S.icon_state)
	builtobjects+=1

	if(buildbrushsize && !subbuild)
		for(var/turf/T in range(1,location))
			BuildATileHere(T,1)
	if(iscustombuilding)
		switch(iscustombuilding)
			if(1)
				var/obj/built
				if(CTileSelection.isDoor) built = new/turf/build/Door(location)
				else built = new /turf/build(location)
				built.icon = CTileSelection.icon
				built.icon_state = CTileSelection.icon_state
				built.underlays += Btemp
				if(CTileSelection.isWall||CTileSelection.isRoof)
					built.density = 1
					built.opacity=0
					if(CTileSelection.isRoof)
						built.opacity=1
				built.proprietor=usr.ckey
				built.Resistance = intBPcap
				turfsave.Add(built)
			if(2)
				var/obj/built = new/obj/buildables
				built.loc = location
				built.icon = CDecorSelection.icon
				built.icon_state = CDecorSelection.icon_state
				built.proprietor=usr.ckey
				built.SaveItem = 1
				built.maxarmor = intBPcap
				built.armor = intBPcap
				built.fragile = 1
			if(3)
				var/obj/barrier/built
				if(CBarrierSelection.barrierN_E.len)
					built = new/obj/barrier/Edges
					built.tall = 0
					built.dir = CBarrierSelection.dir
					built.NOENTER = CBarrierSelection.barrierN_E
					built.NOLEAVE = CBarrierSelection.barrierN_L
				else
					built = new
					built.tall = 0
				built.loc = location
				built.icon = CBarrierSelection.icon
				built.icon_state = CBarrierSelection.icon_state
				built.proprietor=usr.ckey
				built.SaveItem = 1
				built.maxarmor = intBPcap
				built.fragile = 1
				built.armor = intBPcap
	else
		var/obj/P = buildpath
		var/obj/built = new P(location)
		built.proprietor=usr.ckey
		if(isturf(built))
			var/turf/build/nB = built
			for(var/obj/O in location)
				if(istype(O,/obj/buildables)||istype(O,/obj/barrier))
					if(O.proprietor==usr.ckey)
						del(O)
			built.underlays += Btemp
			var/area/A = GetArea()
			if(!usr.buildinout&&A.name=="Inside")
				A.contents.Add(built)
			if(usr.buildinout&&A.name=="Outside")
				A.contents.Add(built)
				nB.wasoutside = 1
			built.Resistance = intBPcap
			if(nB.isHD&&nB.getWidth&&nB.getHeight)
				spawn nB.autofill()
			turfsave.Add(built)
		else
			built.maxarmor = intBPcap
			built.armor = intBPcap
			built.fragile = 1
			built.SaveItem = 1