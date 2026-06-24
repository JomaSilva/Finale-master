//objects related to wood... heh
obj/Raw_Material/
	Lumber_Tree
		name = "Oak Tree"
		icon = 'Oak.dmi'
		icon_state = "1"
		plane = 9
		spawnmat = /obj/items/Material/Wood/Oak_Wood
		masterytype = /datum/mastery/Life/Woodcutting
		masteryname = "Woodcutting"
		masterylevel = 1

		New()
			var/tried = 0
			while(!tried)
				var/spawned = pick(typesof(/obj/items/Material/Wood))
				if(Sub_Type(spawned))
					continue
				else
					spawnmat = spawned
					tried=1
			..()
			var/icon/I = icon('Oak.dmi')
			pixel_x = round(((32 - I.Width()) / 2),1)
			icon = I

obj/matspawners
	Oak_Tree
		materialID = /obj/Raw_Material/Lumber_Tree

obj/items/Material/Wood
	categories = list("Wood")
	statvalues = list("Hardness" = 50,"Weight" = 50,"Density" = 50,"Workability" = 50)

	Oak_Wood
		name = "Oak Wood"
		desc = "A common wood used in crafting."
		icon = 'Plain lumber.dmi'
		tier = 1
		statvalues = list("Hardness" = 40,"Weight" = 30,"Density" = 50,"Workability" = 35)

	Ash_Wood
		name = "Ash Wood"
		desc = "A white wood valued for its density."
		icon = 'Ash Wood.dmi'
		tier = 2
		statvalues = list("Hardness" = 45,"Weight" = 30,"Density" = 60,"Workability" = 40)

	Dark_Wood
		name = "Dark Wood"
		desc = "A dark wood associated with the supernatural."
		icon = 'Dark Wood.dmi'
		tier = 3
		statvalues = list("Hardness" = 55,"Weight" = 35,"Density" = 65,"Workability" = 45)

	Gold_Wood
		name = "Gold Wood"
		desc = "A strange wood with properties similar to gold."
		icon = 'Gold Wood.dmi'
		tier = 4
		statvalues = list("Hardness" = 50,"Weight" = 40,"Density" = 70,"Workability" = 60)