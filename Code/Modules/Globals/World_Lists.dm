var
	list/area_list = list()
	list/area_outside_list = list() //areas considered 'outside'
	list/area_inside_list = list() //areas considered 'inside'
	list/area_sub_list = list() //for areas inside areas. (not inside areas, talking biomes and etc.)
//areas have a my_mob_list and a my_player_list, only updates on Enter() / Exit()
//areas also have a sub_area_list.
	list/obj_list = list() //all objects
	list/item_list = list() // all item objects
	list/attack_list = list() //all attack objects
	list/turf_list = list() //all turfs
	list/planet_list = list() //all planets
	list/mob_list = list() //list of all mobs.
//
	list/client_list = list() //clients (they're /client atoms)
	list/player_list = list() //player controlled mobs
	list/lobby_list = list() //list of lobby mobs.
	list/NPC_list = list() //list of all npcs
	list/Pet_list = list()
	list/boss_list = list()