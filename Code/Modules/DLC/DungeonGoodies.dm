//put the custom dungeon stuff here
//for the Lich Dungeon
turf/RoofWhite
	icon = 'Tiles 1.21.2011.dmi'
	icon_state = "tilewhite"
	density = 1
	opacity = 1
turf/Stairs1
	icon = 'stairs.dmi'
	icon_state = "3"
	density = 1
	opacity = 1
turf/Stairs4
	icon = 'stairs.dmi'
	icon_state = "6"
	density = 0
	opacity = 0

area/dungeon_area
	icon_state=""
	layer=4
	Planet = "Dungeon"
	HasNight=0
	HasDay=0
	HasWeather=0
	HasMoon=0
	AlwaysDay=1
	Inside
		name = "Inside"
		icon = 'IndoorsWeather.dmi'
		InsideArea = 1
mob/npc/Enemy
	Mindless_Lich
		icon = 'Skeleton.dmi'
		New()
			..()
			overlays += 'Clothes_CelesRobe.dmi'
		NPCTicker()
			..()
			BP = max(AverageBP,BP)
			NPCAscension()
		strafeAI = 1
		kidef = 8
		kioff = 6
		physdef = 8
		physoff = 4
		speed = 6
		technique = 8
		kioffMod = 7
		isBlaster = 1
		willpowerMod = 4

	Decaying_Skeleton
		icon = 'Skeleton.dmi'
		New()
			..()
			//overlays += 'Clothes_CelesRobe.dmi'
		NPCTicker()
			..()
			BP = max(AverageBP*0.5,BP)
			NPCAscension()
		strafeAI = 1
		kidef = 7
		kioff =3
		physdef = 9
		physoff = 9
		speed = 4
		technique = 4
		willpowerMod = 3



	Bosses
		Alarato_Lich
			icon = 'Skeleton.dmi'
			New()
				..()
				overlays += 'Clothes_CelesRobe.dmi'
			NPCTicker()
				..()
				BP = max(AverageBP * 4.8,BP)
				NPCAscension()
			strafeAI = 1
			kidef = 10
			kioff = 40
			physdef = 10
			physoff = 10
			speed = 10
			technique = 40
			kioffMod = 40
			isBlaster = 1
			passiveRegen = 1
			willpowerMod = 5

		Vampiric_Immortal
			icon = 'Avatar.dmi'
			New()
				..()
				overlays += 'Clothes_CelesRobe.dmi'
			NPCTicker()
				..()
				BP = max(AverageBP * 4.9,BP)
				NPCAscension()
			strafeAI = 1
			kidef = 30
			physdef = 40
			physoff = 30
			speed = 30
			technique = 30
			kioffMod = 10
			passiveRegen = 5
			willpowerMod = 10

		Master_Of_Zombies
			icon = 'Zombie Thanatos.dmi'
			New()
				..()
				overlays += 'Clothes_CelesRobe.dmi'
			NPCTicker()
				..()
				BP = max(AverageBP * 4.9,BP)
				NPCAscension()
			zanzoAI = 1
			physoff = 40
			physdef = 40
			speed = 20
			technique = 10
			passiveRegen = 2
			willpowerMod = 10


obj/Trap
	icon = 'Traps.dmi'
	mouse_opacity = 0
	icon_state = "hidden"
	canGrab=1
	IsntAItem = 1
	var/sprungstate = "spikes"
	var/effect_t = /effect/bleed
	var/magnitude = 1
	Cross(M)
		..()
		if(ismob(M))
			mouse_opacity = 1
			icon_state = sprungstate
			view(M)<<"You sprung a [sprungstate] trap!"
			spawn(3)
				if(M in range(0))
					M:AddEffect(effect_t)
		return TRUE
	spikes
		//
	muck
		effect_t = /effect/slow
		sprungstate = "muck"
	caltrops
		effect_t = /effect/Alchemy/Health/Damage_Duration
		sprungstate = "caltrops"
		Cross(M)
			..()
			if(ismob(M))
				var/effect/Alchemy/e = locate(/effect/Alchemy/Health/Damage_Duration) in M:effects
				if(e)
					e.duration = 15
					e.magnitude = 1
			return TRUE
	teletrap
		effect_t = null
		sprungstate = "tele"
		var
			goto_x
			goto_y
		Cross(M)
			..()
			if(ismob(M))
				spawn(3)
					if(M in range(0))
						M:Move(locate(goto_x,goto_y,z))
				return TRUE