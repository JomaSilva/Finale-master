//plant objects for crafting
obj/Raw_Material/
	Fiber_Grass
		name = "Fiber Grass"
		icon = 'Fiber Grass.dmi'
		spawnmat = /obj/items/Material/Plant/Plant_Fiber
		masterytype = /datum/mastery/Life/Harvesting
		masteryname = "Harvesting"
		masterylevel = 1

obj/matspawners
	Fiber_Grass
		materialID = /obj/Raw_Material/Fiber_Grass

obj/items/Material/Plant
	categories = list("Fabric")
	statvalues = list("Hardness" = 50,"Weight" = 50,"Density" = 50,"Workability" = 50)

	Plant_Fiber
		name = "Plant Fiber"
		desc = "Plant fibers that act as a fabric."
		icon = 'Plant Fiber.dmi'
		tier = 1
		statvalues = list("Hardness" = 20,"Weight" = 35,"Density" = 45,"Workability" = 50)