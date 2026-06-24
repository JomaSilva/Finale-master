#define HPHUD "hphud"
#define KIHUD "hphud"
mob
	var/
		/*tmp/list/leftoversense = list()
		tmp/list/huds = list()
		tmp/list/otherhuds = list()
		tmp/obj/screen/bubbl
		tmp/list/otherbub = list()
		tmp/list/gothlist=list()
		tmp/list/gotblist=list()*/
		tmp/obj/screen/healthbar/maskbar/bubb = null
		tmp/obj/screen/healthbar/maskbar/bubb2 = null
		sense_on = 0
	proc
		sense_hud_init()
			bubb = new/obj/screen/healthbar/maskbar/enemy_hp(src)
			bubb2 = new/obj/screen/healthbar/maskbar/enemy_ki(src)
			update_health_bar()
		sense_hud_softinit()
			vis_contents += bubb
			vis_contents += bubb2
		sense_hud_softdenit()
			vis_contents -= bubb
			vis_contents -= bubb2
		sense_hud_denit()
			bubb.deleteMe()
			bubb2.deleteMe()
		sense_hud_update()
			set waitfor =0
			set background = 1
			//return
			while(src && client)
				update_health_bar()
				sleep(3)
/*				//if(target && client && get_dist(src,target)<=20) gimmie_health_bar(target)
				if(gotsense) //we want this to loop as long as the container can sense and exists.
					if(sense_on)
						Update()
					else
						DeUpdate()
				overlaychanged=1
				sleep(3)//eh, lazy update please
				*/

/*		Update()
			set waitfor = 0
			set background = 1
			var/list/combined_list = list()
			combined_list += current_area.my_player_list
			for(var/mob/npc/Enemy/Bosses/B in current_area.my_npc_list) combined_list+= B
			for(var/mob/npc/B in range(screenx)) combined_list+= B
			combined_list -= src
			for(var/mob/M in combined_list)
				if(get_dist(src,M) >= screenx - 5 && ((istype(M,/mob/npc) && !istype(M,/mob/npc/Enemy/Bosses)) || gotsense2==0)) continue
				if(get_dist(src,M) < screenx - 5 && M == target) gimmie_health_bar(M)
				if(!isnull(M.bubbl)) gimmie_bub(M)
				else M.sense_hud_init()
			for(var/mob/M in gothlist) if(!M in combined_list) remove_health_bar(M)
			for(var/mob/M in gotblist) if(!M in combined_list) remove_bub(M)
		DeUpdate()
			if(gothlist.len)
				for(var/mob/M in gothlist)
					remove_health_bar(M)
			if(gotblist.len)
				for(var/mob/M in gotblist)
					remove_bub(M)*/
		update_health_bar()
			if(isnull(bubb) || isnull(bubb2))
				bubb = new/obj/screen/healthbar/maskbar/enemy_hp(src)
				bubb2 = new/obj/screen/healthbar/maskbar/enemy_ki(src)
				vis_contents += bubb
				vis_contents += bubb2
			bubb.setValue(HP/100,3)
			bubb2.setValue(Ki/MaxKi,3)
			///world << "image updated."
		/*gimmie_health_bar(var/mob/M) if(client)
			for(var/I in otherhuds[M])
				client.images -= I
			otherhuds[M] = list(M.huds[HPHUD],M.huds[KIHUD])
			for(var/I in otherhuds[M])
				client << I
				//world << "client updated."

		remove_health_bar(var/mob/M) if(client)
			client.images -= otherhuds[M]
			otherhuds[M] = list(null,null)

		create_bubb()
			bubbl = new/obj/screen
			bubbl.icon = 'SenseBubble.dmi'
			bubbl.color = rgb(blastR,blastG,blastB)
			bubbl.maptext = "<font size=1>[name]</font>"
			bubbl.maptext_width = 48
			bubbl.name = name
		gimmie_bub(var/mob/M) if(client)
			set waitfor = 0
			set background = 1
			client.images -= otherbub[M]
			var/obj/screen/nBubb = new/obj/screen(src)
			if(isnull(M.bubbl))
				M.create_bubb()
			nBubb.icon = M.bubbl.icon
			nBubb.color = M.bubbl.color
			var/targ_dist = get_dist(src,M)
			nBubb.maptext = M.bubbl.maptext + "([targ_dist])"
			nBubb.maptext_width = 48
			nBubb.name = M.bubbl.name
			var/bpsc = BPModulus(M.expressedBP,expressedBP) * sqrt(max(0.01,M.Ki/M.MaxKi)) * M.HP/100
			var/matrix/nM = matrix()
			nM.Scale(max(0.25,min(4,bpsc)),max(0.25,min(4,bpsc)))
			if(targ_dist >= 5)
				targ_dist = 5
				var/angle = arctan(M.x - x, M.y-y)
				nM.Translate(targ_dist * cos(angle)*32,targ_dist * sin(angle)*32)
				nBubb.transform = nM
				otherbub[M] = image(nBubb,src)
			else
				nBubb.transform = nM
				otherbub[M] = image(nBubb,M)
			client.images += otherbub[M]
		remove_bub(var/mob/M) if(client)
			client.images -= otherbub[M]
			otherbub[M] = null
		*/

//Ter13 snippetted. Snippet Sunday #16 (Masking)
/obj/screen/healthbar
	maskbar
		appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
		mouse_opacity = 0
		icon = 'health_enemy.dmi'
		pixel_y = 10
		enemy_hp
			width = 24
			height = 2

		enemy_ki
			width = 27
			height = 2
			btype = "KI"
		StBar
			width = 60
			height = 3
			btype = "HUD"
			icon = 'StaBar.dmi'
			screen_loc = "WEST+2,NORTH"
			mouse_opacity = 0
		KiBar
			width = 60
			height = 3
			btype = "HUD"
			icon = 'KiBar.dmi'
			screen_loc = "WEST+2,NORTH-1"
			mouse_opacity = 0
		gkibar
			width = 60
			height = 3
			btype = "HUD"
			icon = 'GKiBar.dmi'
			screen_loc = "WEST+2,NORTH-2"
			mouse_opacity = 0
		var
			obj/foreground
			obj/background
			obj/fill
			obj/mask
			width = 0
			supaMode = 0
			initSupa = ""
			initCrit = ""
			critMode = 0
			height = 0
			orientation = EAST
			btype = "HP"
		New()
			Build()
			vis_contents.Add(mask,foreground)
			//world << "created 2"
			..()
		Del()
			vis_contents.Remove(mask,foreground)
			background.vis_contents -= fill
			mask.vis_contents -= background
			..()
		proc
			Build()
				cust_build()
				background.vis_contents += fill
				mask.vis_contents += background
				//world << "created"
			cust_build()
				switch(btype)
					if("HP")
						foreground = new/obj/screen/healthbar/maskpart/fg(null,icon)
						background = new/obj/screen/healthbar/maskpart/bg(null,icon)
						fill = new/obj/screen/healthbar/maskpart/fill1(null,icon)
						mask = new/obj/screen/healthbar/maskpart/mask1(null,icon)
					if("KI")
						foreground = new/obj/screen/healthbar/maskpart/fg2(null,icon)
						background = new/obj/screen/healthbar/maskpart/bg2(null,icon)
						fill = new/obj/screen/healthbar/maskpart/fill2(null,icon)
						mask = new/obj/screen/healthbar/maskpart/mask2(null,icon)
					if("HUD")
						foreground = new/obj/screen/healthbar/maskpart/fg3(null,icon)
						background = new/obj/screen/healthbar/maskpart/bg3(null,icon)
						fill = new/obj/screen/healthbar/maskpart/fill1(null,icon)
						mask = new/obj/screen/healthbar/maskpart/mask1(null,icon)
				initSupa = fill.icon_state
				initCrit = background.icon_state

			setValue(ratio=1.0,duration=0)
				//constrain the ratio between 0 and 1
				if(ratio > 1)
					supaMode = 1
				else if(ratio <= 0)
					critMode = 1
				else
					supaMode = 0
					critMode = 0
				switch(btype)
					if("HP")
						if(supaMode) fill.icon_state = "bar1sup"
						else fill.icon_state = initSupa
						if(critMode) background.icon_state = "bg1crit"
						else background.icon_state = initCrit
					else if("KI")
						if(supaMode) fill.icon_state = "bar2sup"
						else fill.icon_state = initSupa
						if(critMode) background.icon_state = "bg2crit"
						else background.icon_state = initCrit
					else if("HUD")
						if(supaMode) fill.icon_state = "extra"
						else fill.icon_state = "bar1"
						if(critMode) background.icon_state = "empty"
						else background.icon_state = "bg"
				ratio = min(max(ratio,0),1)
				//apply orientation factors for fill bar offsets
				var/fx = 0, fy = 0
				switch(orientation)
					if(EAST)
						fx = -1
					if(WEST)
						fx = 1
					if(SOUTH)
						fy = 1
					if(NORTH)
						fy = -1
				//calculate the offset of the fill bar.
				var/invratio = 1-ratio
				var/epx = width * invratio * fx
				var/epy = height * invratio * fy

				//apply the offset to the fill bar
				if(duration)
					//if a time value has been supplied, animate the transition from the current position
					animate(fill,pixel_w=epx,pixel_z=epy,time=duration)
				else
					//if a time value has not been supplied, instantly set to the new position
					fill.pixel_w = epx
					fill.pixel_z = epy
	maskpart
		plane = FLOAT_PLANE
		layer = FLOAT_LAYER
		bg
			icon_state = "bg1"
			appearance_flags = KEEP_TOGETHER
			blend_mode = BLEND_MULTIPLY
		fg
			icon_state = "fg1"
		bg2
			icon_state = "bg2"
			appearance_flags = KEEP_TOGETHER
			blend_mode = BLEND_MULTIPLY
		fg2
			icon_state = "fg2"
		fill1
			icon_state = "bar1"
		fill2
			icon_state = "bar2"
		mask1
			icon_state = "mask"
		mask2
			icon_state = "mask2"
		bg3
			icon_state = "bg"
			appearance_flags = KEEP_TOGETHER
			blend_mode = BLEND_MULTIPLY
		fg3
			icon_state = "fg"
		New(loc,icon)
			src.icon = icon
mob/var/tmp/senseset=0
mob/var/tmp/prevlen = 0
mob/var/tmp/hplimiter = 0
mob/proc
	StatSense()
		/*if(leftoversense.len)
			for(var/mob/D in leftoversense)
				if(D.isNPC)
					if(istype(D,/mob/npc/Enemy/Bosses))
					else continue
				if(D)
					stat(D)
					stat("Power","[round((D.expressedBP/max(expressedBP,1))*100,1)]%")
					stat("Health"," [num2text(round(D.HP))]%")
					stat("Energy"," [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%")
		if(gotsense3)
			for(var/mob/D in player_list)
				if(D.Race=="Android")
				else if(D.expressedBP > 5000000)
					if(D)
						stat(D)
						stat("Power","[round((D.BP/BP)*100,1)]%")
						stat("Health"," [num2text(round(D.HP))]%")
						stat("Energy"," [round(D.Ki*1)]    ([round((D.Ki/D.MaxKi)*100,0.1)])%")
						stat("Rough Location","(?,?,[D.z])")*/
		/*var/range=((500/(usr.Ekiskill*usr.kiawarenessskill))) //Sensing accuracy. Now based on ki awareness, perfect sensing won't come until higher levels
		range = round(range/10)
		if(range<1) range=0 //Perfection of accurate sensing.
		*/
		if(!current_area) return
		if(!statpanel("Sense")) return
		var/list/nl = list()
		nl = current_area.contents
		var/list/didlist = list()
		didlist = player_list
		didlist -= src
		nl -= src
		if(gotsense && target && get_dist(src,target) <= 15 && target.z == z)
			nl -= target
			didlist -= target
			stat(target)
			stat("Power","[round((target.expressedBP/max(expressedBP,1))*100,1)]%")
			stat("Health"," [num2text(round(target.HP))]%")
			stat("Energy"," [round(target.Ki*1)]     ([round((target.Ki/target.MaxKi)*100,0.1)])%")
			stat("")
		for(var/mob/D in nl)
			if(D.isconcealed) continue
			if(D.Race=="Android") continue
			if(D.expressedBP <= 5) continue
			didlist -= D
			if(gotsense && get_dist(src,D)<=15)
				if(D)
					if(check_familiarity(D)) stat("[D.name]:","[D.signature]")
					else stat("???:","[D.signature]")
					stat("Power","[round((D.expressedBP/max(expressedBP,1))*100,1)]%")
					stat("Health"," [num2text(round(D.HP))]%")
					stat("Energy"," [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%")
					stat("")
			else if(gotsense2)
				if(D.isNPC && istype(D, /mob/npc/Enemy/Bosses)) continue
				if(D)
					//stat(D)
					if(check_familiarity(D)) stat("[D.name]:","[D.signature]")
					else stat("???:","[D.signature]")
					stat("Power","[round((D.expressedBP/max(expressedBP,1))*100,1)]%")
					switch(get_dir(src,D))
						if(NORTH) stat("Distance","[get_dist(src,D)] (North)")
						if(SOUTH) stat("Distance","[get_dist(src,D)] (South)")
						if(EAST) stat("Distance","[get_dist(src,D)] (East)")
						if(NORTHEAST) stat("Distance","[get_dist(src,D)] (Northeast)")
						if(SOUTHEAST) stat("Distance","[get_dist(src,D)] (Southeast)")
						if(WEST) stat("Distance","[get_dist(src,D)] (West)")
						if(NORTHWEST) stat("Distance","[get_dist(src,D)] (Northwest)")
						if(SOUTHWEST) stat("Distance","[get_dist(src,D)] (Southwest)")
					stat("Health"," [num2text(round(D.HP))]%")
					stat("Energy"," [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%")
					stat("")
		for(var/mob/M in didlist)
			if(gotsense3 && M.expressedBP > 5000000)
				//stat(D)
				if(check_familiarity(M)) stat("[M.name]:","[M.signature]")
				else stat("???:","[M.signature]")
				stat("Power","[round((M.BP/BP)*100,1)]%")
				stat("Health"," [num2text(round(M.HP))]%")
				stat("Energy"," [round(M.Ki*1)]    ([round((M.Ki/M.MaxKi)*100,0.1)])%")
				stat("Rough Location","(?,?,[M.z])")
				stat("")
		/*switch(sense_on)
			if(1)
				if(!senseset)
					senseset=1
					winshow(usr,"sensewindow",1)
			if(0)
				if(senseset)
					senseset=0
					winshow(usr,"sensewindow",0)
				if(!statpanel("Sense")) return
		var/list/stat_list = list()
		var/grid_index = 0
		stat_list += current_area.my_mob_list
		winset(usr,"sensewindow.grid2","cells=0")
		if(target in stat_list)
			var/mob/D = target
			grid_index++
			if(!D.Race=="Android"&&!D.Race=="Meta")
				switch(sense_on)
					if(1)
						usr << output(D,"sensewindow.grid2: 0,1")
						var/dirbit = ""
						if(kiawarenessskill>=20)
							switch(get_dir(src,D))
								if(NORTH) dirbit = "[get_dist(src,D)] (North)"
								if(SOUTH) dirbit = "[get_dist(src,D)] (South)"
								if(EAST) dirbit = "[get_dist(src,D)] (East)"
								if(NORTHEAST) dirbit = "[get_dist(src,D)] (Northeast)"
								if(SOUTHEAST) dirbit = "[get_dist(src,D)] (Southeast)"
								if(WEST) dirbit = "[get_dist(src,D)] (West)"
								if(NORTHWEST) dirbit = "[get_dist(src,D)] (Northwest)"
								if(SOUTHWEST) dirbit = "[get_dist(src,D)] (Southwest)"
						usr << output("Power: [round((D.expressedBP/max(expressedBP,1))*100,1)]%\n[dirbit]\nHealth: [num2text(round(D.HP))]%\nEnergy: [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%","sensewindow.grid2: 0,2")
					if(0)
						stat(D)
						//var/dexp = rand(-range,range) * (D.expressedBP/100) + D.expressedBP
						stat("Power","[round((D.expressedBP/max(expressedBP,1))*100,1)]%")
						if(kiawarenessskill>=20)
							switch(get_dir(src,D))
								if(NORTH) stat("Distance","[get_dist(src,D)] (North)")
								if(SOUTH) stat("Distance","[get_dist(src,D)] (South)")
								if(EAST) stat("Distance","[get_dist(src,D)] (East)")
								if(NORTHEAST) stat("Distance","[get_dist(src,D)] (Northeast)")
								if(SOUTHEAST) stat("Distance","[get_dist(src,D)] (Southeast)")
								if(WEST) stat("Distance","[get_dist(src,D)] (West)")
								if(NORTHWEST) stat("Distance","[get_dist(src,D)] (Northwest)")
								if(SOUTHWEST) stat("Distance","[get_dist(src,D)] (Southwest)")
							stat("Health"," [num2text(round(D.HP))]%")
							stat("Energy"," [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%")
			stat_list -= target
		for(var/mob/D in stat_list)
			if(D.isconcealed) continue
			if(D.Race=="Android"&&!D.Race=="Meta") continue
			if(D.expressedBP <= 5) continue
			if(gotsense && get_dist(src,D)<=15)
				if(D) switch(sense_on)
					if(1)
						grid_index++
						usr << output(D,"sensewindow.grid2: [grid_index],1")
						var/dirbit = ""
						usr << output("Power: [round((D.expressedBP/max(expressedBP,1))*100,1)]%\n[dirbit]\nHealth: [num2text(round(D.HP))]%\nEnergy: [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%","sensewindow.grid2: [grid_index],2")
					if(0)
						stat(D)
						stat("Power","[round((D.expressedBP/max(expressedBP,1))*100,1)]%")
						stat("Health"," [num2text(round(D.HP))]%")
						stat("Energy"," [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%")
			else if(gotsense2)
				if(!istype(D,/mob/npc/Enemy/Bosses) && D.isNPC) continue
				if(D) switch(sense_on)
					if(1)
						grid_index++
						usr << output(D,"sensewindow.grid2: [grid_index],1")
						var/dirbit = ""
						if(kiawarenessskill>=20)
							switch(get_dir(src,D))
								if(NORTH) dirbit = "[get_dist(src,D)] (North)"
								if(SOUTH) dirbit = "[get_dist(src,D)] (South)"
								if(EAST) dirbit = "[get_dist(src,D)] (East)"
								if(NORTHEAST) dirbit = "[get_dist(src,D)] (Northeast)"
								if(SOUTHEAST) dirbit = "[get_dist(src,D)] (Southeast)"
								if(WEST) dirbit = "[get_dist(src,D)] (West)"
								if(NORTHWEST) dirbit = "[get_dist(src,D)] (Northwest)"
								if(SOUTHWEST) dirbit = "[get_dist(src,D)] (Southwest)"
						usr << output("Power: [round((D.expressedBP/max(expressedBP,1))*100,1)]%\n[dirbit]\nHealth: [num2text(round(D.HP))]%\nEnergy: [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%","sensewindow.grid2: [grid_index],2")
					if(0)
						//stat(D)
						stat("Name","[D.name]")
						stat("Power","[round((D.expressedBP/max(expressedBP,1))*100,1)]%")
						if(kiawarenessskill>=20)
							switch(get_dir(src,D))
								if(NORTH) stat("Distance","[get_dist(src,D)] (North)")
								if(SOUTH) stat("Distance","[get_dist(src,D)] (South)")
								if(EAST) stat("Distance","[get_dist(src,D)] (East)")
								if(NORTHEAST) stat("Distance","[get_dist(src,D)] (Northeast)")
								if(SOUTHEAST) stat("Distance","[get_dist(src,D)] (Southeast)")
								if(WEST) stat("Distance","[get_dist(src,D)] (West)")
								if(NORTHWEST) stat("Distance","[get_dist(src,D)] (Northwest)")
								if(SOUTHWEST) stat("Distance","[get_dist(src,D)] (Southwest)")
						stat("Health"," [num2text(round(D.HP))]%")
						stat("Energy"," [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%")
		if(gotsense3)
			for(var/mob/D in player_list)
				if(D.Race=="Android"&&!D.Race=="Meta")
				else if(D.expressedBP > 5000000 && D.z != z)
					if(D) switch(sense_on)
						if(1)
							grid_index++
							usr << output(D,"sensewindow.grid2: [grid_index],1")
							var/dirbit = ""
							if(usr.Ekiskill*usr.kiawarenessskill > 450)
								dirbit = "Rough Location: (?,?,[D.current_area])"
							else dirbit ="Rough Location: (?,?,[D.z])"
							usr << output("Power: [round((D.expressedBP/max(expressedBP,1))*100,1)]%\n[dirbit]\nHealth: [num2text(round(D.HP))]%\nEnergy: [round(D.Ki*1)]     ([round((D.Ki/D.MaxKi)*100,0.1)])%","sensewindow.grid2: [grid_index],2")
						if(0)
							//stat(D)
							stat("Name","[D.name]")
							stat("Power","[round((D.BP/BP)*100,1)]%")
							stat("Health"," [num2text(round(D.HP))]%")
							stat("Energy"," [round(D.Ki*1)]    ([round((D.Ki/D.MaxKi)*100,0.1)])%")
							if(usr.Ekiskill*usr.kiawarenessskill > 450)
								stat("Rough Location","(?,?,[D.current_area])")
							else stat("Rough Location","(?,?,[D.z])")*/
/*
mob/verb
	Sense_Window_Toggle()
		set category = "Other"
		if(sense_on)
			sense_on=0
			usr << "Sense window off."
		else
			sense_on=1
			usr << "Sense window on."*/