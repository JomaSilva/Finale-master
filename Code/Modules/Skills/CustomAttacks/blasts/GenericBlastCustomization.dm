/obj/skill/CustomAttacks/ki/blast
	var/CanModifyDamage = 1
	var/CanModifySpeed = 1
	var/CanModifyPiercing = 1
	var/CanModifyColor = 1
	var/CanModifyExplode = 1
	var/CanModifyHoming = 1
	var/CanModifyRefire = 1
	var/CanModifyStun = 1
	var/CanModifyKnockback = 1
/obj/skill/CustomAttacks/ki/blast/Customize(var/mob/source)
	..()
	var/list/customizelist = list("Current Customization Points","Name","Outloud Name","Icon")
	if(CanModifyDamage)
		customizelist += "Damage"
	if(CanModifySpeed)
		customizelist += "Speed"
	if(CanModifyPiercing)
		customizelist += "Piercing"
	if(CanModifyHoming)
		customizelist += "Homing"
	if(CanModifyExplode)
		customizelist += "Explode"
	if(CanModifyRefire)
		customizelist += "Refire"
	if(CanModifyStun)
		customizelist += "Stun"
	if(CanModifyKnockback)
		customizelist += "Knockback"
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
			icon_state=input(savant,"Icon state?") as text
		if("Damage")
			switch(alert(savant,"Default or chosen?","","Cancel","Choose","Default"))
				if("Cancel")
				if("Choose")
					var/storeddamage = basedamage
					basedamage = input(savant,"Choose the damage. Every single increase in damage equates to 0.5 allocated CP. Increasing will subtract CP. Decreasing will add CP. Minimum is 1, maximum is 5. This variable is rounded.","Damage.",basedamage) as num
					basedamage = round(basedamage)
					basedamage = min(max(basedamage,1),5)
					if(storeddamage > basedamage)
						UndoPoints(((storeddamage - basedamage)/2))
					else if(storeddamage < basedamage)
						if(EnoughPoints((basedamage - storeddamage)/2))
							SubtractPoints((basedamage - storeddamage)/2)
						else
							savant<<"You do not have enough Customization Points"
							basedamage = storeddamage
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
					MoveDelay = input(savant,"Choose the speed. Every single decrease in move delay equates to 0.5 CP. Decreasing this value will subtract CP. Increasing will add CP. Minimum is 0.5, maximum is 2. This variable is rounded to 0.5.","Speed.",MoveDelay) as num
					MoveDelay = round(MoveDelay,0.5)
					MoveDelay = min(max(MoveDelay,0.5),2)
					if(storedspeed < MoveDelay)
						UndoPoints((storedspeed - MoveDelay)/2)
					else if(storedspeed < MoveDelay)
						if(!(EnoughPoints((MoveDelay - storedspeed)/2)))
							savant<<"You do not have enough Customization Points"
							MoveDelay = storedspeed
						else
							SubtractPoints((MoveDelay - storedspeed)/2)
				if("Default")
					var/storedspeed = MoveDelay
					MoveDelay = 2
					if(storedspeed > MoveDelay)
						UndoPoints((storedspeed - MoveDelay)/2)
		if("Piercing")
			switch(alert(savant,"Piercing or no piercing? This will cost 2 CP, and knockback will be minimal. Cannot be used with Explosion. Does increased damage.","","Cancel","Yes","No"))
				if("Cancel")
				if("Yes")
					if(Explode)
						savant << "Blast is a explosion."
						goto theselect
					if(!Piercer)
						if(EnoughPoints(2))
							Piercer = 1
							SubtractPoints(2)
						else
							savant <<"Not enough points."
				if("No")
					if(Piercer)
						Piercer = 0
						UndoPoints(2)
		if("Explode")
			switch(alert(savant,"Explosion or no explosion? Costs 4 (Additional AOE damage and knockback.) Cannot be used with Piercer.","","Cancel","Yes","No"))
				if("Cancel")
				if("Yes")
					if(Piercer)
						savant << "Blast is a piercer."
						goto theselect
					if(!Explode)
						if(EnoughPoints(4))
							Explode = 1
							SubtractPoints(1)
						else
							savant <<"Not enough points."
				if("No")
					if(Explode)
						Explode = 0
						UndoPoints(4)
		if("Homing")
			switch(alert(savant,"Enable guiding? You can't move while this move is going. Costs 2. Cannot be enabled with Stun.","","Cancel","Yes","No"))
				if("Cancel")
				if("Yes")
					if(Stun)
						savant << "Blast is a stun."
						goto theselect
					if(!Homing)
						if(EnoughPoints(2))
							Homing = 1
							SubtractPoints(1)
						else
							savant <<"Not enough points."
				if("No")
					if(Homing)
						Homing = 0
						UndoPoints(2)
		if("Refire")
			switch(alert(savant,"Change the refire speed?","","Cancel","Yes","No"))
				if("Yes")
					switch(alert(savant,"Default or chosen? How quick is it to fire? This will decrease damage and drain, the faster it is. Will be set to highest w/ stun (I.E. 8, or 8 seconds.).","","Cancel","Choose","Default (0.5)"))
						if("Cancel")
						if("Choose")
							Refire = input(savant,"Choose the speed. Minimum is 0.2, maximum is 8. This variable is rounded to 0.1.","Speed.",MoveDelay) as num
							Refire = round(MoveDelay,0.1)
							Refire = min(max(MoveDelay,0.2),8)
							if(Stun)
								Refire = 8

						if("Default (0.5)")
							Refire = 0.5
							if(Stun)
								Refire = 8
				if("No")
					goto theselect
		if("Stun")
			switch(alert(savant,"Increase drain a bunch, but stuns opponent. Costs 3. Cannot be enabled with Homing. Causes a half second stun to yourself.","","Cancel","Yes","No"))
				if("Cancel")
				if("Yes")
					if(Homing)
						savant << "Blast is a homing."
						goto theselect
					if(!Stun)
						if(EnoughPoints(3))
							Stun = 1
							SubtractPoints(3)
							Refire = 8
						else
							savant <<"Not enough points."
				if("No")
					if(Stun)
						Stun = 0
						Refire = 0.5
						UndoPoints(3)
		if("Color")
			color = input(savant,"Pick the color.","Choose the color.") as color
		if("Done")
			goto thedone
	goto theselect
	thedone