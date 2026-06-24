/*
mob
	var/tmp/plscrash = 0
	verb
		plscrash()
			if(plscrash)
				plscrash = 0
			else plscrash = 1*/
obj/overlay/hairs
	plane = HAIR_LAYER
	name = "hair"
	ID = 3
	var/gdkid = 0
	var/prevgdki = 0
	var/list/added_color = list(0,0,0)
	var/list/prev_color = list(0,0,0)
	proc/gdki_me()
		return

	proc/ungdki_me()
		return

	EffectLoop()
		if(container.Apeshit)
			alpha = 1
		else alpha = 255
		if(container.godki)
			if(container.godki?.usage==1 && !gdkid)
				gdkid = 1
				gdki_me()
				icon -= rgb(prev_color[1],prev_color[2],prev_color[3])
				icon += rgb(added_color[1],added_color[2],added_color[3])
			if(gdkid && container.godki?.usage==0)
				gdkid = 0
				ungdki_me()
				EffectStart()
		..()
	EffectStart()
		. = ..()
		if(container.godki?.usage==1 && !gdkid)
			gdkid = 1
			gdki_me()
			icon -= rgb(prev_color[1],prev_color[2],prev_color[3])
			icon += rgb(added_color[1],added_color[2],added_color[3])
	hair
		name = "Regular Hair"
		var/Grayed

		/*removeOverlay()
			world << "I am [src.name]/[src] DYING (removeOverlay) for duty, sir! My layer is [layer] and my plane is [plane]!"
			if(container.plscrash) CRASH("nani?")
			..()*/
		//EffectEnd()
		//	world << "I am [src.name]/[src] DYING (End) for duty, sir! My layer is [layer] and my plane is [plane]!"
		//	..()

		//Del()
		//	world << "I am [src.name]/[src] DYING (del) for duty, sir! My layer is [layer] and my plane is [plane]!"
		//	..()

		gdki_me()
			if(container.godki.tier == godki_cap)
				added_color[1] += 245
				added_color[2] += 245
				added_color[3] += 245
				prevgdki=3
			else if(container.godki.tier == godki_cap - 1)
				added_color[1] += 163
				added_color[3] += 136
				prevgdki=2
			else
				added_color[1] += 226
				added_color[2] += 51
				added_color[3] += 28
				prevgdki=1
		ungdki_me()
			if(prevgdki == 3)
				added_color[1] -= 245
				added_color[2] -= 245
				added_color[3] -= 245
			else if(prevgdki == 2)
				added_color[1] -= 163
				added_color[3] -= 136
			else
				added_color[1] -= 226
				added_color[2] -= 51
				added_color[3] -= 28
		EffectStart()
			icon = container.hair
			startGray()
			icon += rgb(added_color[1],added_color[2],added_color[3])
			..()

		proc
			GrayMe()
				if(icon)
					added_color[1] += 4
					added_color[2] += 4
					added_color[3] += 4
					Grayed+=1
			startGray()
				while(Grayed)
					if(icon)
						added_color[1] += 4
						added_color[2] += 4
						added_color[3] += 4
			UnGrayMe()
				while(Grayed)
					Grayed-=1
					if(!isnull(color))
						added_color[1] -= 4
						added_color[2] -= 4
						added_color[3] -= 4
					sleep(1)
				EffectStart()
mob/proc/Hair(var/forcechoose)
	hair=null
	if(forcechoose|Race=="Saiyan"|Race=="Meta"|Race=="Ogre"|Race=="Genie"|Race=="Heran"|Race=="Spirit Doll"|Race=="Cyborg"|Race=="Kanassa-Jin"|Race=="Demigod"|Race=="Makyo"|Race=="Kai" | Race=="Demon" | Race=="Tsujin" | Race=="Android" | Race=="Human" | Race=="Alien"|Race=="Yardrat"|Race=="Arlian"|Race=="Gray")
		alert("Choose a hair color. Saiyan hair created from here will always be black.")
		var/rgbsuccess
		rgbsuccess=input("Choose a color.","Color",0) as color
		var/list/oldrgb
		oldrgb=hrc_hex2rgb(rgbsuccess,1)
		while(!oldrgb)
			sleep(1)
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
		hairred=oldrgb[1]
		hairblue=oldrgb[3]
		hairgreen=oldrgb[2]
		if(Race=="Saiyan")
			hairred=0
			hairblue=0
			hairgreen=0
		if(Race=="Heran")
			var/icon/Playericon='Hair_Raditz.dmi'
			Playericon += rgb(oldrgb[1],oldrgb[2],oldrgb[3])
			truehair=Playericon
		HairChoice()
		AddHair()

var/hairObjectList = list()

mob/proc/RemoveHair()
	//set waitfor = 1
	//set background = 0
	removeOverlay(/obj/overlay/hairs/hair)
	removeOverlay(/obj/overlay/hairs/ssj/ssj1)
	removeOverlay(/obj/overlay/hairs/ssj/ssj1fp)
	removeOverlay(/obj/overlay/hairs/ssj/ssj2)
	removeOverlay(/obj/overlay/hairs/ssj/ssj3)
	removeOverlay(/obj/overlay/hairs/ssj/ssj4)
	removeOverlay(/obj/overlay/hairs/ssj/ussj)
	removeOverlay(/obj/overlay/hairs/ssj/rlssjhair)
	removeOverlay(/obj/overlay/hairs/ssj/lssjhair)
	return TRUE

mob/proc/AddHair()
	if(!ssj&&!lssj)
		updateOverlay(/obj/overlay/hairs/hair)
	switch(ssj)
		if(1)
			if(ssjdrain<=0.010)
				updateOverlay(/obj/overlay/hairs/ssj/ssj1fp)
			else updateOverlay(/obj/overlay/hairs/ssj/ssj1)
		if(1.5)
			updateOverlay(/obj/overlay/hairs/ssj/ussj)
		if(2)
			updateOverlay(/obj/overlay/hairs/ssj/ssj2)
		if(3)
			updateOverlay(/obj/overlay/hairs/ssj/ssj3)
		if(4)
			updateOverlay(/obj/overlay/hairs/ssj/ssj4)
	switch(lssj)
		if(1)
			updateOverlay(/obj/overlay/hairs/ssj/rlssjhair,hair,0,0,100)
		if(2)
			updateOverlay(/obj/overlay/hairs/ssj/ssj1,ssjhair)
		if(3)
			updateOverlay(/obj/overlay/hairs/ssj/lssjhair,ussjhair,0,100,0)
