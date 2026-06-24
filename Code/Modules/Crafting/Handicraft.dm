//objects related to accessory crafting
obj/Crafting
	Craftsman_Bench
		name = "Craftsman Bench"
		icon = 'Turf 52.dmi'
		icon_state = "small table"
		canbuild=1
		fragile = 1
		masterytype = /datum/mastery/Crafting/Handicraft
		masteryname = "Handicraft"
		researchitem = "Gem"

obj/items/Equipment/Accessory/Crafted
	itemstats=list("Lustre","Refraction","Clarity","Dispersion","Density","Workability")

	Backpack
		name="Backpack"
		desc="A pack that goes on your back. Gives extra inventory space."
		icon='Clothes Backpack.dmi'
		rarity=1
		var/invenboost = 10

		StatUpdate()
			invenboost*=(0.5*itemstats["Workability"]+0.5*itemstats["Density"])*(1+(quality-50)/200)
			invenboost=round(invenboost)

		Description()
			..()
			usr<<"<font color=white>Boosts inventory space by [invenboost]</font>"

		equip(var/mob/M)
			..()
			M.inven_max+=invenboost

		unequip(var/mob/M)
			..()
			M.inven_max-=invenboost

	Quartz_Charm
		name = "Quartz Charm"
		desc = "A charm that diffuses incoming energy attacks slightly."
		icon = 'Quartz Charm.dmi'
		rarity = 1
		displayed = 0
		var/eresist = 0.05

		StatUpdate()
			eresist*=(0.5*itemstats["Refraction"]+0.5*itemstats["Dispersion"])*(1+(quality-50)/200)
			eresist=round(eresist,0.001)

		Description()
			..()
			usr<<"<font color=white>Boosts Energy Resistance by [eresist*100]%</font>"

		equip(var/mob/M)
			..()
			M.Resistances["Energy"] = M.Resistances ["Energy"]*(1+eresist)

		unequip(var/mob/M)
			..()
			M.Resistances["Energy"] = M.Resistances ["Energy"]/(1+eresist)

	Material_Sack
		name = "Material Sack"
		desc = "A bag to stash materials in."
		icon = 'Clothes Backpack.dmi'
		rarity = 2
		var/capacity = 20
		var/list/matlist = list()

		StatUpdate()
			capacity*=(0.5*itemstats["Workability"]+0.5*itemstats["Density"])*(1+(quality-50)/200)
			capacity=round(capacity)

		verb/Storage()
			set category = null
			set src in usr
			if(!equipped)
				usr<<"You must equip this bag to use it!"
				return
			var/choice = alert(usr,"Would you like to store or take materials? This sack is holding [matlist.len]/[capacity] items.","","Store","Take")
			switch(choice)
				if("Store")
					var/list/mats = list()
					for(var/obj/items/Material/m in usr.contents)
						mats+=m
					if(mats.len==0)
						usr<<"You have no materials to store!"
						return
					if(matlist.len==capacity)
						usr<<"Your bag is full!"
						return
					var/obj/items/Material/c = input(usr,"Which material would you like to store?","") as null|anything in mats
					if(!c)
						return
					matlist+=c
					usr.contents-=c
				if("Take")
					if(matlist.len==0)
						usr<<"You have no materials to take!"
						return
					if(usr.inven_min==usr.inven_max)
						usr<<"You have no room to take anything!"
						return
					var/obj/items/Material/c = input(usr,"Which material would you like to take?","") as null|anything in matlist
					if(!c)
						return
					usr.contents+=c
					matlist-=c

obj/items/Plan/Handiwork
	masterytype = /datum/mastery/Crafting/Handicraft
	masteryname = "Handicraft"

	Accessory
		Backpack
			name = "Backpack Plan"
			desc = "A pack that goes on your back. Gives extra inventory space."
			materialtypes = list("Fabric","Fabric","Fabric")
			createditem = /obj/items/Equipment/Accessory/Crafted/Backpack
			createdname = "Backpack"
			requiredlevel = 1
			tier = 1
			canresearch = 1

		Quartz_Charm
			name = "Quartz Charm Plan"
			desc = "A charm that diffuses incoming energy attacks slightly."
			materialtypes = list("Gem","Gem","Gem")
			createditem = /obj/items/Equipment/Accessory/Crafted/Quartz_Charm
			createdname = "Quartz Charm"
			requiredlevel = 1
			tier = 1
			canresearch = 1

		Material_Sack
			name = "Material Sack Plan"
			desc = "A sack to store materials in."
			materialtypes = list("Fabric","Fabric","Fabric")
			createditem = /obj/items/Equipment/Accessory/Crafted/Material_Sack
			createdname = "Material Sack"
			requiredlevel = 10
			tier = 2
			canresearch = 1