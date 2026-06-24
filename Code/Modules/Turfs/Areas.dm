//Z Levels: These are every current Z Level and the planet/space it is assigned to
//1 = Earth
//2 = Namek
//3 = Vegeta
//4 = Icer Planet
//5 = Arconia
//6 = Afterlife (What we call Checkpoint)
//7 = Sealed Zone
//8 = Desert / Vampa
//9 = Hell
//10 = Heaven
//11 = Hera
//12 = Lookout
//13 = HBTC
//14 = Makyo Star
//15 = HBTC
//16 = HBTC
//17 = HBTC
//18 = HBTC
//19 = Big Geti Star
//20 = Negative Earth
//21 = Arlia
//22 = Vegeta Cave
//23 = Earth Cave
//24 = Interdimension
//25 = Dead-But-Not-Really Realm (Vore Hell)
//26 = Space
//27 = Small Space Station
//28 = Large Space Station
//29 = Title Screen
//30 = Character Creation
area
	name = "Outside"
	icon='Weather.dmi' //default icon
	var/Planet //only used for 'planetary' areas/areas you can enter
	var/PlayersCanSpawn = 1 //used for areas you can't spawn into, set to a 0 value if a player can't spawn in the area.

	var/InsideArea = 0
	var/Biome_Type = "Plains" //just a dummy variable for now, might do something wen seasons.
	var/area/parent_area = null //if a area needs a parent
	var/issubarea //if a area is a subarea.
	var/isdestroyed = 0

	var/exclude //if a area should be excluded from selection

	var/rift_type = /obj/Rift/Rift
	var/rift_rarity = 1

	Outside
		icon_state = "Outside"
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		exclude = 1
		allowedWeatherTypes = list()

		Inside
			exclude = 1
	plane = WEATHER_LAYER
	var/tmp
		list/my_mob_list = list()
		list/my_player_list = list()
		list/my_turf_list = list()
		list/my_npc_list = list()

		//rand lists
		list/rand_one_list = list()
		list/rand_two_list = list()


area
	Entered(atom/movable/Obj,atom/OldLoc)
		if(ismob(Obj)&&Planet)
			Obj:Planet = Planet
			Obj:CheckTime()
			if(Obj in player_list) my_player_list|=Obj
			else my_npc_list |= Obj
			my_mob_list|=Obj
		..()
	Exited(atom/movable/O)
		if(ismob(O))
			var/testpath
			if(name == "Inside") testpath = text2path(("[copytext(src.type,length(src.type) - 8)]"))
			else testpath = locate(text2path(("[src.type]" + "/Inside")))
			if(my_player_list.len && testpath)
				var/area/a = locate(testpath)
				if(!O in a)
					a.my_player_list -= O
					my_player_list -= O
			my_player_list-=O
			my_mob_list-=O
			my_npc_list-=O
		..()
	New()
		..()
		area_list += src
		if(name!="Inside"|!InsideArea && !exclude)
			area_outside_list += src
			AreaTime()
		else
			if(!exclude) area_inside_list += src
		spawn
			while(worldloading)
				sleep(1)
			if(src)
				var/amount = rift_rarity
				while(amount >= 1)
					amount--
					var/turf/T = pickTurf(src,2)
					new rift_type(T)

		Ticker()
	Del()
		area_list -= src
		area_outside_list -= src
		..()
var/list/active_o_play_areas = list("Vegeta","Earth","Arconia","Namek","Icer Planet","Desert","Afterlife","Heaven","Hell","Interdimension","Arlia","Large Space Station","Small Space Station")
area
	Vegeta
		icon_state=""
		layer=4
		Planet = "Vegeta"
		allowedWeatherTypes = list("Blood Rain","Fog","Smog")
		Inside //Placed where built things are, so it doesnt have weather inside.
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Earth
		icon_state=""
		layer=4
		Planet = "Earth"
		allowedWeatherTypes = list("Rain","Snow","Fog","Storm","Blizzard") //todo: add earth subareas
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Kanzabar
		icon_state=""
		layer=4
		Planet = "Kanzabar"
		allowedWeatherTypes = list("Rain","Snow","Fog","Storm","Blizzard")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Arconia
		icon_state=""
		layer=4
		Planet = "Arconia"
		allowedWeatherTypes = list("Rain","Snow","Fog","Storm","Blizzard")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Namek
		icon_state=""
		layer=4
		Planet = "Namek"
		allowedWeatherTypes = list("Namek Rain","Fog","Storm")
		HasMoon=0
		HasNight=0
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Icer
		icon_state=""
		layer=4
		Planet = "Icer Planet"
		allowedWeatherTypes = list("Snow","Fog","Storm","Blizzard")
		HasMoon=0
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Space
		icon_state=""
		layer=4
		PlayersCanSpawn = 0
		Planet = "Space"
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		CanHellstar=0
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Desert
		name = "Vampa"
		icon_state=""
		layer=4
		Planet = "Desert"
		allowedWeatherTypes = list("Sandstorm","Smog")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	afterlifeareas
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		AlwaysDay=1
		Afterlife
			icon_state=""
			layer=4
			Planet = "Afterlife"
			Inside
				name = "Inside"
				icon = 'IndoorsWeather.dmi'
				InsideArea = 1
		Heaven
			icon_state=""
			layer=4
			Planet = "Heaven"
			Inside
				name = "Inside"
				icon = 'IndoorsWeather.dmi'
				InsideArea = 1
		Hell
			icon_state=""
			layer=4
			Planet = "Hell"
			Inside
				name = "Inside"
				icon = 'IndoorsWeather.dmi'
				InsideArea = 1
		BR
			icon_state=""
			layer=4
			PlayersCanSpawn=0
			Planet = "Hell"
			Inside
				name = "Inside"
				icon = 'IndoorsWeather.dmi'
				InsideArea = 1
			Enter(mob/M)
				if(!usr.BRAllowed)
					usr << "A strange force plucks you away from the area!?"
					usr.loc=locate(460,267,9)
					return 0
				else return 1
	Interdimension
		icon_state=""
		layer=4
		Planet = "Interdimension"
		HasNight=0
		HasDay=0
		HasWeather=1
		CanHellstar=0
		HasMoon=0
		AlwaysDay=1
		rift_type = /obj/Rift/Interdimensional_Rift
		rift_rarity = 10
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Hera
		icon_state=""
		layer=4
		Planet = "Hera"
		allowedWeatherTypes = list("Snow","Fog","Storm","Blizzard")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Lookout
		icon_state=""
		layer=4
		Planet = "Earth"
		PlayersCanSpawn = 0
		HasWeather=0
		exclude = 1
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Hyperbolic_Time_Chamber
		icon_state=""
		layer=4
		Planet = "Hyperbolic Time Dimension"
		PlayersCanSpawn = 0
		HasNight=0
		HasDay=0
		CanHellstar=0
		HasWeather=1
		AlwaysDay=1
		allowedWeatherTypes = list("Rain","Snow","Fog","Storm","Smog","Blood Rain","Blizzard","Sandstorm")
		HasMoon=0
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	//
	Big_Geti_Star
		icon_state=""
		layer=4
		Planet = "Big Gete Star"
		HasDay=0
		HasWeather=1
		AlwaysDay=1
		allowedWeatherTypes = list("Fog","Smog")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Negative_Earth
		icon_state=""
		layer=4
		Planet = "Negative Earth"
		HasDay=0
		CanHellstar=0
		HasWeather=1
		allowedWeatherTypes = list("Storm","Smog","Blood Rain","Blizzard","Sandstorm")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Arlia
		icon_state=""
		layer=4
		Planet = "Arlia"
		allowedWeatherTypes = list("Rain","Fog","Storm","Smog","Sandstorm")
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Inbetween_Realm
		icon_state=""
		layer=4
		Planet = "Inbetween Realm"
		PlayersCanSpawn = 0 //can be changed later if Vore Hell becomes more of a place.
		HasNight=0
		HasDay=0
		CanHellstar=0
		HasWeather=0
		HasMoon=0
		AlwaysDay=1
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Void
		icon_state="Void"
		layer=4
		Planet = "Void"
		HasNight=0
		HasDay=0
		HasWeather=0
		currentWeather = "Void"
		IsWeathering=1
		HasMoon=0
		AlwaysDay=1
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	God_Realm
		icon_state=""
		layer=4
		Planet = "God Realm"
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		AlwaysDay=1
		rift_type = /obj/Rift/GodKi_Rift
		rift_rarity = 45
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Large_Space_Station
		icon_state=""
		layer=4
		Planet = "Large Space Station"
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		AlwaysDay=1
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Small_Space_Station
		icon_state=""
		layer=4
		Planet = "Small Space Station"
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		AlwaysDay=1
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
	Makyo_Star
		icon_state=""
		layer=4
		Planet = "Makyo Star"
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0
		AlwaysHellstar=1
		AlwaysDay=1
		Inside
			name = "Inside"
			icon = 'IndoorsWeather.dmi'
			InsideArea = 1
/*
			if(src.spawnPlanet=="Earth")
				loc=locate(74,239,1)
			else if(src.spawnPlanet=="Namek")
				loc=locate(125,200,2)
			else if(src.spawnPlanet=="Vegeta")
				loc=locate(128,283,3)
			else if(src.spawnPlanet=="Arconia")
				loc=locate(212,192,5)
			else if(src.spawnPlanet=="Icer Planet")
				loc=locate(261,297,4)
			else if(src.spawnPlanet=="Arlia")
				loc=locate(100,255,21)
			else if(src.spawnPlanet=="Heaven")
				loc=locate(175,115,10)
			else if(src.spawnPlanet=="Hell")
				loc=locate(65,258,9)
			else if(src.spawnPlanet=="Large Space Station")
				loc=locate(226,233,26)
			else if(src.spawnPlanet=="Small Space Station")
				loc=locate(53,158,28)
			else if(src.spawnPlanet=="Big Gete Star")
				loc=locate(190,240,19)
			else if(src.spawnPlanet=="Interdimension")
				loc=locate(205,250,24)
			else if(src.spawnPlanet=="Afterlife")
				loc=locate(175,125,6)
			else if(src.dead)
				loc=locate(175,125,6)
				*/