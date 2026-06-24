#define ui_zonesel "EAST-4.5:28,NORTH-1.5:28"
mob
	var
		tmp/obj/screen/zone_sel/zone_sel = null
		selectzone = "chest"

/obj/screen/zone_sel
	name = "damage zone"
	icon = 'screen_midnight.dmi'
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"
	appearance_flags = PIXEL_SCALE
	New()
		..()
		var/matrix/M = matrix()
		M.Scale(2,2)
		src.transform = M

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				/*switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"
				*/
	if(old_selecting != selecting)
		update_icon()
	switch(selecting)
		if("r_leg")
			usr.selectzone = "leg"
		if("r_arm")
			usr.selectzone = "arm"
		if("l_leg")
			usr.selectzone = "leg"
		if("l_arm")
			usr.selectzone = "arm"
		if("chest")
			usr.selectzone = "chest"
		if("groin")
			usr.selectzone = "abdomen"
		if("head")
			usr.selectzone = "head"
		else
			usr.selectzone = "chest"
	return 1

/obj/screen/zone_sel/proc/update_icon()
	overlays.Cut()
	overlays += image('zone_sel.dmi', "[selecting]")