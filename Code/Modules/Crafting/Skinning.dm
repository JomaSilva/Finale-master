//mob materials that can drop
mob
	var
		list/skinlist = list(/obj/items/Material/Corpse/Hide,/obj/items/Material/Corpse/Bone)//basic list of drops
		skinlevel=1//level for skinning the mob's corpse

obj/items/Material/Corpse//mob materials
	categories = list("Corpse")
	statvalues = list("Hardness" = 50,"Weight" = 50,"Density" = 50,"Workability" = 50)
	Hide
		name = "Hide"
		desc = "Skin from some creature."
		icon = 'Hide.dmi'
		tier = 1
		categories = list("Corpse","Fabric","Leather")
		statvalues = list("Hardness" = 30,"Weight" = 25,"Density" = 45,"Workability" = 60)
		New()
			..()
			tier = rand(1,4)
			for(var/a in statvalues)
				statvalues[a] = round(statvalues[a]*(1+(tier-1)/15))
	Bone
		name = "Bone"
		desc = "Bone from some creature."
		icon = 'Horn.dmi'
		tier = 1
		categories = list("Corpse","Wood","Bone")
		statvalues = list("Hardness" = 60,"Weight" = 45,"Density" = 35,"Workability" = 55)
		New()
			..()
			tier = rand(1,4)
			for(var/a in statvalues)
				statvalues[a] = round(statvalues[a]*(1+(tier-1)/15))