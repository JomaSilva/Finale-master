//objects related to ores
obj/Raw_Material/
	Ore
		name = "Ore Chunk"
		icon = 'Plain Rock.dmi'
		spawnmat = null
		masterytype = /datum/mastery/Life/Mining
		masteryname = "Mining"
		masterylevel = 1

		New()
			var/tried = 0
			while(!tried)
				var/spawned = pick(typesof(/obj/items/Material/Ore))
				if(Sub_Type(spawned))
					continue
				else
					spawnmat = spawned
					tried=1
			..()

obj/matspawners
	Ore
		materialID = /obj/Raw_Material/Ore

obj/items/Material/Ore
	categories = list("Ore")
	statvalues = list("Hardness" = 50,"Weight" = 50,"Density" = 50,"Workability" = 50)

	Iron_Ore
		name = "Iron Ore"
		desc = "A common ore used in smithing."
		icon = 'Ore.dmi'
		tier = 1
		statvalues = list("Hardness" = 40,"Weight" = 55,"Density" = 45,"Workability" = 40)

	Silver_Ore
		name = "Silver Ore"
		desc = "A valuable ore sometimes used as currency. Large amounts can be crafted into small amounts of Zenni."
		icon = 'Silver Rock.dmi'
		tier = 2
		statvalues = list("Hardness" = 35,"Weight" = 50,"Density" = 55,"Workability" = 65)

	Gold_Ore
		name = "Gold Ore"
		desc = "A very valuable ore sometimes used as currency. Large amounts can be crafted into decent amounts of Zenni."
		icon = 'Gold rock.dmi'
		tier = 3
		statvalues = list("Hardness" = 25,"Weight" = 55,"Density" = 60,"Workability" = 60)

	Blacksteel_Ore
		name = "Blacksteel Ore"
		desc = "A strong ore with many uses."
		icon = 'Black Rock.dmi'
		tier = 3
		statvalues = list("Hardness" = 60,"Weight" = 55,"Density" = 65,"Workability" = 60)

	Orichalcum_Ore
		name = "Orichalcum Ore"
		desc = "A strange ore with supernatural properties."
		icon = 'Red Rock 2.dmi'
		tier = 4
		statvalues = list("Hardness" = 65,"Weight" = 45,"Density" = 70,"Workability" = 65)

//GEM LINE
obj/Raw_Material/
	Quartz
		name = "Quartz Chunk"
		icon = 'White rock.dmi'
		spawnmat = null
		masterytype = /datum/mastery/Life/Mining
		masteryname = "Mining"
		masterylevel = 1

		New()
			var/tried = 0
			while(!tried)
				var/spawned = pick(typesof(/obj/items/Material/Gem))
				if(Sub_Type(spawned))
					continue
				else
					spawnmat = spawned
					tried=1
			..()

obj/matspawners
	Quartz
		materialID = /obj/Raw_Material/Quartz

obj/items/Material/Gem
	categories = list("Gem","Focus")
	statvalues = list("Lustre" = 50,"Refraction" = 50,"Clarity" = 50,"Dispersion" = 50)

	Quartz
		name = "Quartz"
		desc = "A common gem with little value."
		icon = 'Quartz.dmi'
		tier = 1
		statvalues = list("Lustre" = 40,"Refraction" = 30,"Clarity" = 35,"Dispersion" = 30)

	Ruby
		name = "Ruby"
		desc = "A red gem associated with power."
		icon = 'Quartz.dmi'
		tier = 2
		statvalues = list("Lustre" = 45,"Refraction" = 40,"Clarity" = 55,"Dispersion" = 35)

		New()
			..()
			var/icon/i = icon(icon)
			i.Blend(rgb(50,200,200),ICON_SUBTRACT)
			icon = i

	Sapphire
		name = "Sapphire"
		desc = "A blue gem that is considered valuable."
		icon = 'Quartz.dmi'
		tier = 3
		statvalues = list("Lustre" = 45,"Refraction" = 45,"Clarity" = 60,"Dispersion" = 40)

		New()
			..()
			var/icon/i = icon(icon)
			i.Blend(rgb(200,200,50),ICON_SUBTRACT)
			icon = i

	Emerald
		name = "Emerald"
		desc = "A green gem associated with calmness."
		icon = 'Quartz.dmi'
		tier = 4
		statvalues = list("Lustre" = 55,"Refraction" = 45,"Clarity" = 65,"Dispersion" = 50)

		New()
			..()
			var/icon/i = icon(icon)
			i.Blend(rgb(200,50,200),ICON_SUBTRACT)
			icon = i