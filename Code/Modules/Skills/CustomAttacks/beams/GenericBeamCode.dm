/obj/skill/CustomAttacks/ki/beam/fire()
	var/kireq=KiReq/(savant.Ekiskill)
	if(savant.beaming)
		savant.canmove = 1
		savant.stopbeaming()
		return
	if(savant.Ki>=kireq)
		if(savant.charging)
			savant.beaming=1
			savant.charging=0
			savant.icon_state="Blast"
			if(icon)
				savant.forceicon=icon
			else
				savant.forceicon='Beam3.dmi'
			emit_Sound(firesound)
			return
		if(!savant.charging&&!savant.KO&&!savant.med&&!savant.train&&savant.canfight)
			emit_Sound(ChargeSound)
			savant.forcestate="origin"
			savant.canmove = 0
			savant.lastbeamcost=KiReq/(savant.Ekiskill*2)
			savant.beamspeed=0.1*MoveDelay*basedamage
			savant.powmod=2.3
			savant.bypass=1
			savant.maxdistance=30
			savant.canfight = 0
			savant.charging=1
			savant.piercer = Piercer
			savant.beamdamage = basedamage*MoveDelay
			savant.beamrgb = color
			spawn savant.addchargeoverlay()
		return
	else
		savant << "You need at least [kireq] Ki!"
		return
	..()
//stop() and charge() isn't modified since the beam code in beams.dm do it for us.
/obj/skill/CustomAttacks/ki/beam
	var/CanModifyDamage = 1
	var/CanModifySpeed = 1
	var/CanModifyPiercing = 1
	var/CanModifyColor = 1
	var/MoveDelay = 1
	var/Piercer = 0

/obj/skill/CustomAttacks/ki/beam/Customize(var/mob/source)
	..()
	var/list/customizelist = list("Current Customization Points","Name","Outloud Name","Icon")
	if(CanModifyDamage)
		customizelist += "Damage"
	if(CanModifySpeed)
		customizelist += "Speed"
	if(CanModifyPiercing)
		customizelist += "Piercing"
	if(CanModifyColor)
		customizelist += "Color"
	customizelist += "Done"
	theselect
	savant = source
	switch(input(savant,"Pick what to customize. Note: While Icons are usually fine, sound files can only be changed by admins.") in customizelist)
		if("Current Customization Points")
			savant << "The available customization points are [CustomizationPoints]."
		if("Name")
			name=input(savant,"Choose the name.","Attack name.",name)
		if("Outloud Name")
			attackname=input(savant,"What will you say outloud?","Outloud name.",attackname)
		if("Icon")
			icon = input(savant,"Choose the icon","Icon.",icon) as icon
		if("Damage")
			switch(alert(savant,"Default or chosen?","","Cancel","Choose","Default"))
				if("Cancel")
				if("Choose")
					var/storeddamage = basedamage
					basedamage = input(savant,"Choose the damage. Every single increase in damage equates to 0.5 CP. Increasing will subtract skillpoints. Decreasing will add skillpoints. Minimum is 1, maximum is 5. This variable is rounded.","Damage.",basedamage) as num
					basedamage = round(basedamage)
					basedamage = min(max(basedamage,1),5)
					if(storeddamage > basedamage)
						UndoPoints(((storeddamage - basedamage)/2))
					else if(storeddamage < basedamage)
						if(!(EnoughPoints((basedamage - storeddamage)/2)))
							savant<<"You do not have enough unallocated skillpoints (You gain skillpoints through raw BP increases or other means.)"
							basedamage = storeddamage
						else
							SubtractPoints((basedamage - storeddamage)/2)
				if("Default")
					var/storeddamage = basedamage
					basedamage = 1
					if(storeddamage > basedamage)
						UndoPoints((storeddamage - basedamage)/2)
		if("Speed")
			switch(alert(savant,"Default or chosen?","","Cancel","Choose","Default"))
				if("Cancel")
				if("Choose")
					var/storedspeed = MoveDelay
					MoveDelay = input(savant,"Choose the speed. Every single decrease in move delay equates to 0.5 allocated skillpoints. Decreasing this value will subtract skillpoints. Increasing will add skillpoints. Minimum is 0.5, maximum is 2. This variable is rounded to 0.5.","Speed.",MoveDelay) as num
					MoveDelay = round(MoveDelay,0.5)
					MoveDelay = min(max(MoveDelay,0.5),2)
					if(storedspeed < MoveDelay)
						UndoPoints((storedspeed - MoveDelay)/2)
					else if(storedspeed < MoveDelay)
						if(EnoughPoints((MoveDelay - storedspeed)/2))
							savant<<"You do not have enough unallocated skillpoints (You gain skillpoints through raw BP increases or other means.)"
							MoveDelay = storedspeed
						else
							SubtractPoints((MoveDelay - storedspeed)/2)
				if("Default")
					var/storedspeed = MoveDelay
					MoveDelay = 2
					if(storedspeed > MoveDelay)
						UndoPoints((storedspeed - MoveDelay)/2)
		if("Piercing")
			switch(alert(savant,"Piercing or no piercing? This will cost 1 skillpoint, and knockback will be minimal.","","Cancel","Yes","No"))
				if("Cancel")
				if("Yes")
					if(!Piercer)
						if(EnoughPoints(1))
							Piercer = 1
							SubtractPoints(1)
						else
							savant <<"Not enough points."
				if("No")
					if(Piercer)
						Piercer = 0
						UndoPoints(1)
		if("Color")
			color = input(savant,"Pick the color.","Choose the color.") as color
		if("Done")
			goto thedone
	goto theselect
	thedone