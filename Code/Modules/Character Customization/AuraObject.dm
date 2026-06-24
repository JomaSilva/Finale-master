mob/var
	setAuracenter
	form1aura ='SSj Aura.dmi'
	formussjaura ='SSj Aura.dmi'
	form2aura ='SSj Aura.dmi'
	form3aura ='SSj Aura.dmi'
	form4aura ='SSj Aura.dmi'
	form5aura ='SSj Aura.dmi'

	gkaura = 'FieryGod.dmi'//for regular boys.
	csgkaura = null //if you have a custom godki aura, it'll overwrite this one.
	sgkaura = 'FieryGodBlue.dmi'//for blue boys

	gkoverlay = 'god.dmi'//for regular boys.
	csgkoverlay = null //if you have a custom godki overlay, it'll overwrite this one.
	sgkoverlay = 'god blue.dmi'//for blue boys

obj/overlay/auras
	plane = AURA_LAYER
	name = "aura"
	temporary = 1
	appearance_flags = PIXEL_SCALE
	ID = 5
	var/setSSJ
	var/setNJ
	var/presetAura
	var/centered
	var/lastSSJ
	var/scale = list(1,1) //MULTIPLICITIVE- a value of 2, 3, would turn a 32 by 32 icon into a 64x96 icon.
	var/prevscale = list(1,1)
	var/lstgdki=0
	var/centy = 0
	var/lastpowermod
	var/storedicon
	var/ScaleMe = 1
	var/tmp/limiter = 10
	var/prevcolor
	var/icolor

obj/overlay/auras/aura
	name = "Regular Aura"
	centerAura()
		..()
		if(!container.godki?.usage) icolor = rgb(container.AuraR,container.AuraG,container.AuraB)

obj/overlay/auras/proc/centerAura() //todo: convert to matrixes
	set background = 1
	set waitfor = 0
	var/icon/A = icon(icon)
	var/pixelList = list(0,0)
	var/iconwidth = A.Width()
	var/iconheight = A.Height()
	if(container.Over)
		plane = AURA_LAYER
	else plane = UNDERAURA_LAYER
	if(!lastpowermod)
		lastpowermod = 1
	var/image/I = image(A)
	if(container.setAuracenter)
		pixelList = I.center(container.setAuracenter)
	else if(iconwidth!=32||iconheight!=32)
		pixelList = I.center("center-bottom")
	A = I
	icon = A
	if(pixelList)
		centered=1
		o_px = pixelList[1] + container.pixel_x
		o_py = pixelList[2] + container.pixel_y
		centy = pixelList[2] + container.pixel_y

obj/overlay/auras/proc/ScaleAura()
	set background = 1
	set waitfor = 0
	var/scalewidth = 1
	var/scaleheight = 1
	if(scale[1]&&scale[2]&&lastpowermod) //matrix scaling is focused on the icon's center already
		scalewidth = round((((1.4 ** (scale[1] * lastpowermod)) / 8 ) + 0.825),0.25)
		scaleheight = round((((1.4 ** (scale[2] * lastpowermod)) / 8 ) + 0.825),0.25)
		prevscale = scale
	if(scalewidth > 2) scalewidth = log(2.5,scalewidth - 1) + 2
	if(scaleheight > 2) scaleheight = log(2.5,scaleheight - 1) + 2
	var/matrix/nM = new
	nM.Scale(scalewidth,scaleheight) //even though we want the scaling to be center-bottom (or whatever the person set it to be)
	animate(src,time = 5,transform = nM)
	o_py = (centy) * scaleheight

obj/overlay/auras/EffectStart()
	if(icon)
		presetAura=1
		storedicon = icon
	centerAura()
	..()
	transform /= 5
	spawn(1)
		animate(src,time = 5,transform = null)
obj/overlay/auras/EffectLoop()
	set background = 1
	set waitfor = 0
	if(lastpowermod!=container.kiratio && ScaleMe)
		if(limiter<=0)
			if(prob(60))
				limiter = 5
				lastpowermod = container.kiratio
				ScaleAura()
		else limiter--

	if(presetAura)
	else
		if(icolor != prevcolor)
			if(isnum(prevcolor)) icon -= prevcolor
			if(isnum(icolor)) icon += icolor
			prevcolor = icolor
		if(!prevscale == scale)
			ScaleAura()
			prevscale = scale
		if(!icon)
			icon = container.AURA
			centerAura()
		if(lstgdki == 0 && container.godki?.usage)
			lastSSJ = 0
			setNJ=0
			lstgdki = 1
		else if(lstgdki == 1 && !container.godki?.usage)
			lastSSJ = 0
			setNJ=0
			lstgdki = 0
		if((container.ssj>0&&lastSSJ!=container.ssj)||(container.lssj>0&&container.lssj!=lastSSJ))
			setSSJ=1
			setNJ=0
			if(container.ssj)
				lastSSJ=container.ssj
			if(container.lssj)
				lastSSJ=container.lssj
			storedicon = null
			switch(container.ssj)
				if(1)
					icon = container.form1aura
					scale = list(1,1)
				if(2)
					icon = container.form2aura
					scale = list(1,1.25)
				if(3)
					icon = container.form3aura
					scale = list(1.25,1.5)
				if(4)
					icon = container.form4aura
					scale = list(1.5,1.75)
				if(1.5)
					icon = container.formussjaura
					scale = list(1.25,1)
			switch(container.lssj)
				if(1)
					icon = container.form1aura
					scale = list(1,1)
				if(2)
					icon = container.form2aura
					scale = list(1,1.25)
				if(3)
					icon = container.form3aura
					scale = list(1.25,1.5)
			if(container.godki?.usage)
				icon = container.sgkaura
				icolor = null
			centerAura()
			ScaleAura()
		else if(!setNJ&&!container.ssj&&!container.lssj)
			lastSSJ=0
			setNJ=1
			scale = list(1,1)
			setSSJ=0
			if(container.godki?.usage)
				icon = container.gkaura
				icolor = null
				if(container.icer_vars["Form 6 Aura"] && container.isBuffed(/obj/buff/Golden_Form)) icon = container.icer_vars["Form 6 Aura"]
				else if(isnull(container.csgkaura))
					var/list/added_color = list(0,0,0)
					if(container.godki.tier == godki_cap)
						icon = 'god - grey.dmi'
						added_color[1] += 245
						added_color[2] += 245
						added_color[3] += 245
					else if(container.godki.tier == godki_cap - 1)
						icon = 'god - grey.dmi'
						added_color[1] += 163
						added_color[3] += 136
					icolor = rgb(clamp(added_color[1],0,255),clamp(added_color[2],0,255),clamp(added_color[3],0,255))
				else
					icon = container.csgkaura
					icolor = null
			else
				icon = container.AURA
				icolor = null
			storedicon = null
			centerAura()
			ScaleAura()
	..()
	return

mob/verb/ChangeAura()
	set name = "Change Aura"
	set category="Other"
	if(!usr||inAwindow) return FALSE
	winshow(usr,"miscwindow", 1)
	usr.inAwindow = 1
	var/currentlyusing
	for(var/obj/A in contents) if(istype(A,/obj/aurachoice)) currentlyusing=1
	var/howmany=0
	var/count = 0
	winset(usr,"miscwindow.maingrid","cells=0")
	if(!currentlyusing) while(howmany<19)
		sleep(1)
		howmany+=1
		var/obj/A=new/obj/aurachoice
		if(howmany==1) A.icon='SandAura.dmi'
		if(howmany==2) A.icon='CustomAura.dmi'
		if(howmany==3) A.icon='Aura Normal.dmi'
		if(howmany==4) A.icon='AuraKiia.dmi'
		if(howmany==5) A.icon='FlameAura.dmi'
		if(howmany==6) A.icon='snamek Elec.dmi'
		if(howmany==7) A.icon='Mutant Aura.dmi'
		if(howmany==8) A.icon='LightningAura.dmi'
		if(howmany==9) A.icon='colorablebigaura.dmi'
		if(howmany==10) A.icon='Aura 2.dmi'
		if(howmany==11) A.icon='aura blanco.dmi'
		if(howmany==12) A.icon='Aura godtest.dmi'
		if(howmany==13) A.icon='Black Demonflame.dmi'
		if(howmany==14) A.icon='captainfalconaura.dmi'
		if(howmany==15) A.icon='dragon fire power up2.dmi'
		if(howmany==16) A.icon='greengodaura.dmi'
		if(howmany==17) A.icon='transformaura.dmi'
		if(howmany==18) A.icon='vermarUIaura2.dmi'
		if(howmany==19) A.icon='NormalTallAura.dmi'
		A.icon_state="[howmany]"
		contents+=A
		usr << output(A,"miscwindow.maingrid: [++count]")
	contents += new/obj/aurawindowverbs
	winset(usr,"miscwindow.maingrid","cells=[count]")
	winset(usr,"miscwindow.misclabel","text=\"Pick a aura.\"")
mob/var/tmp/aurachoice=0
obj/aurachoice/Click()
	if(!usr.aurachoice)
		usr.aurachoice=0
		usr<<"Aura Chosen."
		usr.AURA=icon
		usr.AURA+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
		for(var/obj/aurachoice/A in usr.contents) if(A!=src) del(A)
		spawn(20) del(src)
		winshow(usr,"miscwindow", 0)
		usr.inAwindow = 0
obj/aurawindowverbs
	verb/DoneButton()
		set category = null
		set hidden = 1
		winshow(usr,"miscwindow", 0)
		usr.inAwindow = 0
		for(var/obj/aurachoice/A in usr.contents) if(A!=src) del(A)
		spawn(20) del(src)
		del(src)