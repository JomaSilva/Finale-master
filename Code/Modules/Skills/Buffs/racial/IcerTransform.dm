mob/var
	cur_icr_form = 1

	canf5
	f5=0
	f5at=150000000
	f5mult=4
/*
obj/buff/Frost_Demon_Forms
	name = "Frieza Clan Form"
	icon='SSJIcon.dmi'
	slot=sFORM
	var/lastForm=0
obj/buff/Frost_Demon_Forms/Buff()
	*/
//obj/buff/SuperSaiyan/Loop()
mob/proc/Frost_Demon_Forms()
	if(Race=="Frost Demon"||Parent_Race=="Frost Demon")
		if(cur_icr_form > 1)
			switch(icer_limit_forms)
				if(1) cur_icr_form = 1
				if(2) cur_icr_form -= 2
				if(3) cur_icr_form -= 1
			cur_icr_form = max(1,cur_icr_form)
			icer_poll_icon()
			return
		if(cur_icr_form == 1 && canf5)
			cur_icr_form = 0
			transBuff = f5mult
			trueKiMod = 1
			icer_poll_icon()
mob/proc/revertIcer()
	if(Race=="Frost Demon"||Parent_Race=="Frost Demon")
		if(isBuffed(/obj/buff/Golden_Form))
			stopbuff(/obj/buff/Golden_Form)
		else if(cur_icr_form == 0)
			cur_icr_form = 1
		else if(icer_limit_forms == 1)
			cur_icr_form = 4
		else if(icer_limit_forms == 2)
			cur_icr_form++
			cur_icr_form = min(4,cur_icr_form)
			if(cur_icr_form == 3)
				cur_icr_form++
		else if(icer_limit_forms == 3)
			cur_icr_form += 1
			cur_icr_form = min(4,cur_icr_form)
		icer_poll_icon()

mob/proc/icer_poll_icon()
	var/form = 5 - cur_icr_form + isBuffed(/obj/buff/Golden_Form)
	switch(form)
		if(1) icon = form1icon
		if(2) icon = form2icon
		if(3) icon = form3icon
		if(4) icon = form4icon
		if(5) icon = form5icon
		if(6) icon = form6icon

/obj/buff/Golden_Form
	name = "Golden Form"
	slot=sFORM
	Buff()
		..()
		container.updateOverlay(/obj/overlay/icergod)
		container.storedicon = container.icon
		if(container.icer_vars[container.icer_vars[1]] == TRUE)
			icon = container.form6icon
		else
			switch(container.icer_vars[container.icer_vars[2]])
				if(1) icon = container.form1icon
				if(2) icon = container.form1icon
				if(3) icon = container.form3icon
				if(4) icon = container.form4icon
				if(5) icon = container.form5icon
			icon += rgb(container.icer_vars[container.icer_vars[3]][1],container.icer_vars[container.icer_vars[3]][2],container.icer_vars[container.icer_vars[3]][3])
		container.icon = icon
		container.emit_Sound('1aura.wav')
		container.cur_icr_form = 0
		container.transBuff = container.f5mult
		container.trueKiMod = 1
		container.icer_poll_icon()
		container.Tphysoff+=1.3
		container.Tkioff+=1.2
		container.Tspeed+=1.3
		container.gain_godki(90)
		container.godki.usage = 1
	DeBuff()
		container<<"Your body releases its golden hue."
		container.icon = container.storedicon
		container.transBuff=1
		container.Tphysoff-=1.2
		container.Tkioff-=1.2
		container.Tspeed-=1.2
		container.cur_icr_form = 1
		container.transBuff = 1
		container.trueKiMod = 1
		container.reset_minor_godki()
		container.icer_poll_icon()
		..()
	do_first_godki_appearance() return
	do_godki_appearance() return

obj/overlay/icergod
	plane = AURA_LAYER
	name = "icer god aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 47
	pixel_y = -16
	//pixel_y = -34
	o_py = -16
	var/timer=16
	icon='friezagod.dmi'
	EffectStart()
		spawn
			icon_state = "1"
			pixel_y = -16
			o_py = -16
			//pixel_y = -34
			//o_py = -34
			icon_state = ""
			container.overlays += src
			container.overlayList += src
			container.overlaychanged = 1
			icon_state = ""
			while(timer>=1)
				timer--
				pixel_y = -16
				o_py = -16
				//pixel_y = -34
				//o_py = -34
				sleep(1)
			container.overlays -= src
			container.overlayList -= src
			container.overlaychanged = 1
			EffectEnd()
		..()