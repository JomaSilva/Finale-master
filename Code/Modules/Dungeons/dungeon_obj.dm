//todo:
//-dungeon finding
//-dungeon names appear on screen on entering
//-(later on) multi-level dungeons
//-(later on) player managed semi-perma dungeons
var/list/dun_list = list()

obj/dungeon
	name = "Dungeon"//Name.
	icon = 'dungeon_entrances.dmi' //icon on overworld, preferably 32 by 32.
	IsntAItem=1
	density = 0
	var
		//Variables that don't do anything yet
		levels = 1 //levels, i.e. how many 'floors'. Maximum of 3, but floors aren't implemented yet.
		//Variables that do stuff.
		afk_time = 3000 //How many seconds/10 can people be AFK until they get booted from the dungeon? Absently training or meditating counts! Typing cancels. Set to 0 to disable AFK booting.
		repeatable = 1 //Can people clear your dungeon over and over? (People with the same signatures can't clear the same dungeon over and over with this on.)
		reward_BP = list(1.12,"mult") //the 'reward BP' for a dungeon. Second part is 'add' or 'mult'.
		cooldown = 1250 //cooldown if repeatable is true
		targetBP = 0 //if you want this dungeon to only appear at certain server BP levels.
		list/allowed_areas = list() //if you want this dungeon to only appear in certain areas (allowed_areas.len >= 1 is the same as true)
		multiple_players = 0 //How many players at once? 0 for no limit. This is why AFK booting is important!
		start_coord[2]//coordinates of the dungeon's entrance, this is where people will go to. you don't need a z value.
		map_file = "simpledungeon.dmm"
		timer = 3 //timer for dungeons= starts at 1, ticks down to 0, at 0 it deletes.
		semi_perm = 0 //Manual spawn only- dungeons with this ticked will not be spawned in randomly. Only manually placed dungeons can have this ticked.
		////
		////Don't configure these variables.
		dungeon_coord[3]//coordinates of the dungeon in the game world.
		//
		dungeon_quadrant = 3 //quadrants follow the rules of math quadrants, 1 is top right, 2 is top left, 3 is bottom left, 4 is bottom right.
		//
		dmm_suite/suite = null
		reserved_z = 0 //reserved z level.
		id = 0
		tmp
			active = 0 //active dungeon?
			is_reloading = 0 //is this dungeon in the process of reloading?
			list
				players[] = list()
	Cross(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/O = Obstacle
			if(multiple_players)
				if(players.len >= multiple_players) player_enter(O)
			else player_enter(O)
		..()
	New()
		..()
		dun_list += src
		id = rand(1,2000) + rand(1,2000) + (rand(1,10) * rand(1,10))
	Del()
		dun_list -= src
		..()
	proc

		player_enter(mob/player)
			if(is_reloading) return FALSE
			if(player_teleport_entrance(player))
				players += player
				active = 1
				return TRUE
			else
				//OutputDebug("tele fail [start_coord.len] [start_coord[1]] [start_coord[2]] [reserved_z]")
				return FALSE

		check_players()
			for(var/mob/p in player_list)
				verify_here(p)
				if(p.client.inactivity >= afk_time)
					kick_player(p)

		verify_here(mob/p)
			if(p.z != reserved_z)
				p.in_Dungeon = 0
				players -= p
				return FALSE
			else
				if(!p in players)
					players += p
					p.in_Dungeon = 1
				return TRUE

		player_teleport_entrance(mob/player)
			if(start_coord.len && start_coord[1] && start_coord[2] && reserved_z)
				switch(dungeon_quadrant)
					if(1) player.loc = locate(start_coord[1] + 250,start_coord[2] + 250,reserved_z)
					if(2) player.loc = locate(start_coord[1],start_coord[2] + 250,reserved_z)
					if(3) player.loc = locate(start_coord[1],start_coord[2],reserved_z)
					if(4) player.loc = locate(start_coord[1] + 250,start_coord[2],reserved_z)
				player.in_Dungeon = 1
				return TRUE
			return FALSE

		player_teleport_out(mob/player)
			if(dungeon_coord.len && dungeon_coord[1] && dungeon_coord[2] && dungeon_coord[3])
				player.loc = locate(dungeon_coord[1],dungeon_coord[2],dungeon_coord[3])
				player.in_Dungeon = 0
				return TRUE
			else
				player.Locate()
				player.in_Dungeon = 0
				return FALSE

		kick_players()
			check_players()
			for(var/mob/p in players)
				player_teleport_out(p)

		kick_player(mob/p)
			if(p in players)
				player_teleport_out(p)

		dungeon_delete()
			kick_players()
			active = 0
			del(src)

		dungeon_reset()
			kick_players()
			active = 0
			suite.read_map(file2text("Maps/dungeons/[map_file]"),1,1,reserved_z)

		tickloop()
			set waitfor=0
			if(prob(25) && active) check_players() //possible lag maker here
			sleep(-1)
			sleep(1)
			tickloop()

		dungeon_initialize()
			set waitfor = 0
			set background = 1
			spawn
				var/a = check_dun_map_index_template(map_file)
				if(a)
					is_reloading = 1
					var/n = world.maxz+1
					suite = new()
					suite.read_map(file2text("Maps/dungeons/[map_file]"),1,1,reserved_z)
					for(var/obj/dungeon_exit/DE in dun_exits)
						if(DE.z == n) DE.linked_dun = src
					var/area/ar = locate(/area/dungeon_area)
					for(var/turf/T in ar.my_turf_list)
						if(T == n) T.Resistance = AverageBP * AverageBPMod * 5
					reserved_z = n
					is_reloading = 0
					spawn tickloop()
					return TRUE
				else
					del(src)
					return FALSE

		dungeon_load(var/list/savelist)
			name = savelist["name"]
			levels = savelist["levels"]
			targetBP = savelist["targetBP"]
			allowed_areas = savelist["allowed_areas"]
			reward_BP = savelist["reward_BP"]
			repeatable = savelist["repeatable"]
			cooldown = savelist["cooldown"]
			afk_time = savelist["afk_time"]
			multiple_players = savelist["multiple_players"]
			start_coord = savelist["start_coord"]
			map_file = savelist["map_file"]
			icon_state = savelist["icon"]
			timer = savelist["timer"]
			semi_perm = savelist["semi_perm"]
			dungeon_initialize()

		clear(mob/p)
			if(reward_BP[2] == "mult")
				p.BP += p.capcheck(reward_BP[1]*p.BP)
			if(reward_BP[2] == "add")
				p.BP += p.capcheck(reward_BP[1])
			dungeon_reset()
			is_reloading = 1
			if(!repeatable)
				dungeon_delete()
			if(cooldown)
				sleep(cooldown)
				is_reloading = 0
var/list/dun_exits =list()
obj/dungeon_exit
	IsntAItem=1
	density = 0
	name = "Dungeon"//Name.
	icon = 'dungeon_entrances.dmi' //icon on overworld, preferably 32 by 32.
	var
		obj/dungeon/linked_dun = null
		isClearingExit = 0
	New()
		..()
		dun_exits += src
	Del()
		dun_exits -= src
		..()
	Cross(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/O = Obstacle
			if(linked_dun)
				if(isClearingExit) linked_dun.clear(O)
				else linked_dun.kick_player(O)
		..()
mob/var/tmp/in_Dungeon = 0

obj
	items
		Dungeon_Needle
			icon='dungeon_finder.dmi'
			SaveItem=1
			cantblueprint=1
			var/delay=0
			var/can_locate_makyo_port
			New()
				..()
				spawn while(delay>=1)
					sleep(1)
					delay--
			verb/Upgrade()
				set category=null
				set src in view(1)
				if(!can_locate_makyo_port)
					switch(input("Allows you to locate makyo portals. Costs 25000 zenni.","",text) in list("Yes","No",))
						if("Yes")
							if(usr.zenni>=25000)
								usr.zenni-=25000
								can_locate_makyo_port=1
							else usr<<"You dont have enough money"
				else
					view(src)<<"<font color=yellow><font size=3>Dungeon Needle: FIRMWARE ALREADY AT MAXIMUM CAPACITY."
			verb/Point()
				set category=null
				set src in view(1)
				if(delay)
					view(usr)<<"<font color=yellow><font size=3>Dungeon Needle: ERROR: LOW POWER, PLEASE WAIT [round(delay/10)] SECONDS!"
					return
				else
					for(var/obj/dungeon/DE in dun_list)
						if(DE.z != usr.z)
							delay = 2400
							view(usr)<<"<font color=yellow><font size=3>Dungeon Needle: DUNGEON [DE] ID [DE.id] AT ? LONG ? LAT [area_z_num_to_string(DE.z)] DIM. USER DIMENSIONS ARE [usr.x] LONG [usr.y] LAT [area_z_num_to_string(usr.z)] DIM."
						else
							if(DE.reserved_z != usr.z)
								delay = 1200
								view(usr)<<"<font color=yellow><font size=3>Dungeon Needle: DUNGEON [DE] ID [DE.id] IN AREA. DIRECTION IS [dir_num_to_string(get_dir(usr,DE))]."
							else
								delay = 600
								for(var/obj/dungeon_exit/nDE in dun_exits)
									if(nDE.z == usr.z && nDE.linked_dun && nDE.isClearingExit)
										view(usr)<<"<font color=yellow><font size=3>Dungeon Needle: INSIDE DUNGEON: TARGET EXIT IN AREA. DIRECTION IS [dir_num_to_string(get_dir(usr,nDE))]."
									else
										view(usr)<<"<font color=yellow><font size=3>Dungeon Needle: INSIDE DUNGEON: ENTRANCE IN AREA. DIRECTION IS [dir_num_to_string(get_dir(usr,DE))]."
					if(can_locate_makyo_port)
						for(var/obj/MakyoGate/DE in obj_list)
							if(DE.z != usr.z)
								view(usr)<<"<font color=green>------------<br>Radar: MAKYO PARTICLES AT ? LONG ? LAT [area_z_num_to_string(DE.z)] DIM. USER DIMENSIONS ARE [usr.x] LONG [usr.y] LAT [area_z_num_to_string(usr.z)] DIM."
							else
								view(usr)<<"<font color=green>------------<br>Radar: MAKYO PARTICLES IN AREA. DIRECTION IS [dir_num_to_string(get_dir(usr,DE))]"
						delay = 1200
				spawn while(delay>=1)
					sleep(1)
					delay--
obj/Creatables
	Dungeon_Needle
		icon='dungeon_finder.dmi'
		desc = "Will point you in the general direction and area of a dungeon, but not the actual coordinates."
		cost=50000
		neededtech=25
		create_type = /obj/items/Dungeon_Needle