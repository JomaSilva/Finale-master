mob/var
	participated_ritual=FALSE
	last_rit = 0
	tmp
		list/got_power_count=list()


mob
	proc
		count_got_power()
			if(participated_ritual) return
			var/list/participatorslist = list()
			var/list/tview = view(4)
			var/sapprovedlst
			var/rapprovedlst
			for(var/a = 1, a <= got_power_count.len, a++)
				var/mob/M = got_power_count[a]
				if(M.participated_ritual == FALSE && world.time >= participatorslist[M] + 500)
					var/approved = 0
					check_familiarity(M)
					if(check_familiarity(M) >= 15)
						approved++
					if(check_familiarity(M) >= 50)
						sapprovedlst++
					if(approved)
						if(M.Race == Race)
							rapprovedlst++
						if(M in tview)
							participatorslist += M

			if(participatorslist.len >= 5 || sapprovedlst + rapprovedlst >= 3)//3 other people of the same race and/or 3 other people with high standing, or 5 total people... all must have decent familiarity.
				for(var/A in participatorslist)
					var/mob/M = A
					M.participated_ritual = TRUE
					M.last_rit = Year
				participated_ritual = TRUE
				last_rit = Year
				INITIALIZEGODPROTOCOL(participatorslist)//fuck you this is cool


		INITIALIZEGODPROTOCOL(var/list/L)
			world << "God protocol initializing."
			//Completely intended for a world statement stating that the God ritual is being performed
			//godstuff
			//usr << browse("<script>window.location='https://www.youtube.com/watch?v=[address]';</script>", "window=InvisibleBrowser.invisiblebrowser")
			//was gonna do music but decided not to, let effects do the talking?
			for(var/turf/T in range(4))
				createDustmisc(T,2)
				if(prob(10))
					createLightningmisc(T,10)
			Quake()
			sleep(20)
			for(var/mob/M in L)
				view(M) << "<font color=red size=3>[M] begins to glow with a red hue!!</font>"
				spawn M.updateOverlay(/obj/overlay/gogod)
			sleep(30)
			view(src) << "<font color=red size=3>The red hues collesques onto [src]!!</font>"
			updateOverlay(/obj/overlay/gogod)
			sleep(40)
			view(src) << "<font color=red size=3>[src] rises into the air!!</font>"
			createDustmisc(loc,5)
			createShockwavemisc(loc,1)
			sleep(10)
			createShockwavemisc(loc,1)
			sleep(10)
			createShockwavemisc(loc,1)
			createDustmisc(loc,5)
			sleep(10)
			createShockwavemisc(loc,1)
			sleep(10)
			updateOverlay(/obj/overlay/godhue)
			sleep(15)
			//godstuff complete
			startbuff(/obj/buff/Ritual_God)

/obj/buff/Ritual_God
	name = "Ritual God"
	icon='Electric_Blue.dmi'
	slot=sFORM
	Buff()
		..()
		container.emit_Sound('ssg.wav')
		container << "Your godly power shimmers around you... Check your stats tab, this will last as long as you have God Ki energy!!"
		container.gain_godki(100)
		container.godki_give_mult = godki_boost
		container.godki.usage = 1
		spawn
			animate(container,time=8,color=rgb(255, 81, 0))
			container.color=null
			container.updateOverlay(/obj/overlay/rit_god_aura)
	Loop()
		if(!container.godki?.usage)
			DeBuff()
			return
		..()
	DeBuff()
		container<<"Your godly power vanishes..."
		container.reset_minor_godki()
		container.removeOverlay(/obj/overlay/rit_god_aura)
		..()

obj/overlay/rit_god_aura
	plane = UNDERAURA_LAYER
	name = "godki aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 49
	pixel_x = -34
	o_px = -34
	alpha = 125
	//pixel_y = -34
	//o_py = -34
	var/timer=15
	icon='godhue2.dmi'
	EffectLoop()
		if(container.kiratio > 1)
			alpha = 255
		else
			alpha = 0
		if(container.godki?.usage == 0)
			EffectEnd()

obj/overlay/godhue
	plane = AURA_LAYER
	name = "godki aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 47
	pixel_x = -29
	o_px = -29
	alpha = 125
	//pixel_y = -34
	//o_py = -34
	var/timer=15
	icon='godhue.dmi'
	icon_state = "1"
	EffectStart()
		spawn
			icon_state = "1"
			pixel_x = -29
			o_px = -29
			//pixel_y = -34
			//o_py = -34
			icon_state = ""
			container.overlayList += src
			container.overlays += src
			container.overlaychanged = 1
			icon_state = ""
			while(timer>=1)
				timer--
				pixel_x = -29
				o_px = -29
				//pixel_y = -34
				//o_py = -34
				sleep(1)
			container.overlays -= src
			container.overlayList -= src
			container.overlaychanged = 1
			EffectEnd()
		..()

obj/overlay/gogod
	plane = AURA_LAYER
	name = "godki aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 47
	pixel_x = -24
	o_px = -24
	//pixel_y = -34
	//o_py = -34
	var/timer=7
	icon='godgo.dmi'
	icon_state = "1"
	EffectStart()
		spawn
			icon_state = "1"
			pixel_x = -24
			o_px = -24
			//pixel_y = -34
			//o_py = -34
			icon_state = ""
			container.overlays += src
			container.overlayList += src
			container.overlaychanged = 1
			icon_state = ""
			while(timer>=1)
				timer--
				pixel_x = -24
				o_px = -24
				//pixel_y = -34
				//o_py = -34
				sleep(1)
			container.overlays -= src
			container.overlayList -= src
			container.overlaychanged = 1
			EffectEnd()
		..()