//plans and craftable items for smithing

obj/Crafting
	Forge
		name = "Forge"
		icon = 'Turf 52.dmi'
		icon_state = "forge"
		canbuild=1
		masterytype = /datum/mastery/Crafting/Smithing
		masteryname = "Smithing"
		researchitem = "Ore"

obj/items/Equipment/Armor/Crafted
	itemstats=list("Hardness","Weight","Density","Workability")
	StatUpdate()
		armored*=(0.5*itemstats["Hardness"]+0.5*itemstats["Density"])*(1+(quality-50)/200)*(1+rarity/2)
		deflection*=(0.5*itemstats["Workability"]+0.5*(1-log(10,itemstats["Weight"])))*(1+(quality-50)/200)*(1+rarity/2)
	Body
		icon='Clothes Kung Fu Shirt.dmi'
		slots=list(/datum/Body/Torso,/datum/Body/Abdomen,/datum/Body/Arm,/datum/Body/Arm)

		Reinforced_Shirt
			name = "Reinforced Shirt"
			desc = "A shirt reinforced with metal banding."
			armored = 2

	Helmet
		icon='Hat.dmi'
		slots=list(/datum/Body/Head)

		Wooden_Helmet
			name = "Wooden Helmet"
			desc = "A helmet made from wood and metal bands."
			armored = 1

	Gloves
		icon='Clothes_Gloves.dmi'
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)

		Banded_Gloves
			name = "Banded Gloves"
			desc = "Gloves reinforced with metal bands."
			armored = 1

	Boots
		icon='Clothes_Boots.dmi'
		slots=list(/datum/Body/Leg/Foot,/datum/Body/Leg/Foot)

		Banded_Boots
			name = "Banded Boots"
			desc = "Boots reinforced with metal bands."
			armored = 1
	Pants
		icon='Clothes_Pants.dmi'
		slots=list(/datum/Body/Leg,/datum/Body/Leg)

		Reinforced_Pants
			name = "Reinforced Pants"
			desc = "Pants reinforced with metal banding."
			armored = 2

obj/items/Equipment/Weapon/Crafted
	slots=list(/datum/Body/Arm/Hand)
	weapon=1
	itemstats=list("Hardness","Weight","Density","Workability")
	StatUpdate()
		damage*=itemstats["Hardness"]*(1+(quality-50)/200)*(1+rarity/2)
		accuracy*=itemstats["Workability"]*(1+(quality-50)/200)*(1+rarity/2)
		penetration*=itemstats["Density"]*(1+(quality-50)/200)*(1+rarity/2)
		speed*=max(1-log(10,itemstats["Weight"]*(1+(quality-50)/200)),0.1)
		block*=itemstats["Density"]*(1+(quality-50)/200)*(1+rarity/2)
	Sword
		icon='Sword_Trunks.dmi'
		wtype="Sword"

		Long_Sword
			name="Long Sword"
			desc="A sword with a long blade."
			icon='Sword_Trunks.dmi'
			damage=1
			accuracy=1
			penetration=1

		Greatsword
			slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
			name = "Greatsword"
			desc = "A large sword requiring two hands to use."
			damage = 2
			penetration = 3
			speed = 1.1
	Axe
		icon='Axe.dmi'
		wtype="Axe"

		Hand_Axe
			name = "Hand Axe"
			desc = "An axe that fits in your hand."
			damage = 1.5
			accuracy = 1
			penetration = 0.5

		Lumber_Axe
			slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
			name = "Lumber Axe"
			desc = "An axe for chopping wood. Takes two hands."
			damage = 3
			penetration = 1
			speed = 1.1
	Staff
		icon='Roshi Stick.dmi'
		wtype="Staff"

		Short_Staff
			name = "Short Staff"
			desc = "A short staff for combat."
			damage = 0.5
			accuracy = 1.5
			speed = 0.95

		Long_Staff
			slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
			name = "Long Staff"
			desc = "A long staff requiring two hands."
			damage = 1
			accuracy = 2
			penetration = 1
			speed = 0.95
	Spear
		icon='spear.dmi'
		wtype="Spear"

		Short_Spear
			name = "Short Spear"
			desc = "A short spear. Pairs well with a shield."
			damage = 0.5
			penetration = 2
			accuracy = 1

		Long_Spear
			slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
			name = "Long Spear"
			desc = "A long spear. Uses two hands."
			damage = 1.5
			penetration = 3
			accuracy = 1
	Club
		icon='Club.dmi'
		wtype="Club"

		Thick_Club
			name = "Thick Club"
			desc = "A tree branch used as a weapon."
			damage = 1.5
			speed = 1.05

		Heavy_Club
			slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
			name = "Heavy Club"
			desc = "A heavy, reinforced hunk of wood."
			damage = 3.5
			penetration = 1
			speed = 1.15
	Hammer
		icon='Hammer.dmi'
		wtype="Hammer"

		Craftsman_Hammer
			name = "Craftsman Hammer"
			desc = "A small hammer often used by craftsmen."
			damage = 1
			penetration = 2

		Sledgehammer
			slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
			name = "Sledgehammer"
			desc = "A heavy hammer, often swung overhead."
			damage = 2
			penetration = 4
			speed = 1.1
	Shield
		icon='ShieldGrey.dmi'
		wtype="Shield"

		Targe
			name = "Targe"
			desc = "A small shield affixed to the forearm."
			block = 4

obj/items/Plan/Smithing
	masterytype = /datum/mastery/Crafting/Smithing
	masteryname = "Smithing"
	Weapon
		Sword
			Long_Sword
				materialtypes = list("Ore","Ore","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Sword/Long_Sword
				createdname = "Long Sword"

				Tier_1
					name = "T1 Long Sword Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Long Sword Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Long Sword Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Long Sword Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

			Greatsword
				materialtypes = list("Ore","Ore","Ore","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Sword/Greatsword
				createdname = "Greatsword"

				Tier_1
					name = "T1 Greatsword Plan"
					requiredlevel = 5
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Greatsword Plan"
					requiredlevel = 15
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Greatsword Plan"
					requiredlevel = 35
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Greatsword Plan"
					requiredlevel = 55
					tier = 4
					canresearch = 1
		Axe
			Hand_Axe
				materialtypes = list("Ore","Ore","Wood","Wood")
				createditem = /obj/items/Equipment/Weapon/Crafted/Axe/Hand_Axe
				createdname = "Hand Axe"

				Tier_1
					name = "T1 Hand Axe Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Hand Axe Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Hand Axe Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Hand Axe Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

			Lumber_Axe
				materialtypes = list("Ore","Ore","Ore","Wood","Wood")
				createditem = /obj/items/Equipment/Weapon/Crafted/Axe/Lumber_Axe
				createdname = "Lumber Axe"

				Tier_1
					name = "T1 Lumber Axe Plan"
					requiredlevel = 5
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Lumber Axe Plan"
					requiredlevel = 15
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Lumber Axe Plan"
					requiredlevel = 35
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Lumber Axe Plan"
					requiredlevel = 55
					tier = 4
					canresearch = 1
		Staff
			Short_Staff
				materialtypes = list("Ore","Wood","Wood","Wood")
				createditem = /obj/items/Equipment/Weapon/Crafted/Staff/Short_Staff
				createdname = "Short Staff"

				Tier_1
					name = "T1 Short Staff Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Short Staff Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Short Staff Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Short Staff Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

			Long_Staff
				materialtypes = list("Ore","Wood","Wood","Wood","Wood")
				createditem = /obj/items/Equipment/Weapon/Crafted/Staff/Long_Staff
				createdname = "Long Staff"

				Tier_1
					name = "T1 Long Staff Plan"
					requiredlevel = 5
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Long Staff Plan"
					requiredlevel = 15
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Long Staff Plan"
					requiredlevel = 35
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Long Staff Plan"
					requiredlevel = 55
					tier = 4
					canresearch = 1
		Spear
			Short_Spear
				materialtypes = list("Ore","Wood","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Spear/Short_Spear
				createdname = "Short Spear"

				Tier_1
					name = "T1 Short Spear Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Short Spear Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Short Spear Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Short Spear Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

			Long_Spear
				materialtypes = list("Ore","Wood","Wood","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Spear/Long_Spear
				createdname = "Long Spear"

				Tier_1
					name = "T1 Long Spear Plan"
					requiredlevel = 5
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Long Spear Plan"
					requiredlevel = 15
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Long Spear Plan"
					requiredlevel = 35
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Long Spear Plan"
					requiredlevel = 55
					tier = 4
					canresearch = 1
		Club
			Thick_Club
				materialtypes = list("Wood","Wood","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Club/Thick_Club
				createdname = "Thick Club"

				Tier_1
					name = "T1 Thick Club Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Thick Club Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Thick Club Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Thick Club Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

			Heavy_Club
				materialtypes = list("Ore","Wood","Wood","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Club/Heavy_Club
				createdname = "Heavy Club"

				Tier_1
					name = "T1 Heavy Club Plan"
					requiredlevel = 5
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Heavy Club Plan"
					requiredlevel = 15
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Heavy Club Plan"
					requiredlevel = 35
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Heavy Club Plan"
					requiredlevel = 55
					tier = 4
					canresearch = 1
		Hammer
			Craftsman_Hammer
				materialtypes = list("Ore","Ore","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Hammer/Craftsman_Hammer
				createdname = "Craftsman Hammer"

				Tier_1
					name = "T1 Craftsman Hammer Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Craftsman Hammer Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Craftsman Hammer Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Craftsman Hammer Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

			Sledgehammer
				materialtypes = list("Ore","Ore","Ore","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Hammer/Sledgehammer
				createdname = "Sledgehammer"

				Tier_1
					name = "T1 Sledgehammer Plan"
					requiredlevel = 5
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Sledgehammer Plan"
					requiredlevel = 15
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Sledgehammer Plan"
					requiredlevel = 35
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Sledgehammer Plan"
					requiredlevel = 55
					tier = 4
					canresearch = 1
		Shield
			Targe
				materialtypes = list("Ore","Wood","Wood","Fabric")
				createditem = /obj/items/Equipment/Weapon/Crafted/Shield/Targe
				createdname = "Targe"

				Tier_1
					name = "T1 Targe Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Targe Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Targe Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Targe Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1
	Armor
		Body
			Reinforced_Shirt
				materialtypes = list("Ore","Fabric","Fabric","Fabric")
				createditem = /obj/items/Equipment/Armor/Crafted/Body/Reinforced_Shirt
				createdname = "Reinforced Shirt"

				Tier_1
					name = "T1 Reinforced Shirt Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Reinforced Shirt Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Reinforced Shirt Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Reinforced Shirt Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

		Helmet
			Wooden_Helmet
				materialtypes = list("Ore","Wood","Fabric","Fabric")
				createditem = /obj/items/Equipment/Armor/Crafted/Helmet/Wooden_Helmet
				createdname = "Wooden Helmet"

				Tier_1
					name = "T1 Wooden Helmet Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Wooden Helmet Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Wooden Helmet Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Wooden Helmet Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

		Gloves
			Banded_Gloves
				materialtypes = list("Ore","Fabric","Fabric","Fabric")
				createditem = /obj/items/Equipment/Armor/Crafted/Gloves/Banded_Gloves
				createdname = "Banded Gloves"

				Tier_1
					name = "T1 Banded Gloves Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Banded Gloves Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Banded Gloves Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Banded Gloves Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

		Boots
			Banded_Boots
				materialtypes = list("Ore","Ore","Fabric","Fabric")
				createditem = /obj/items/Equipment/Armor/Crafted/Boots/Banded_Boots
				createdname = "Banded Boots"

				Tier_1
					name = "T1 Banded Boots Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Banded Boots Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Banded Boots Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Banded Boots Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1

		Pants
			Reinforced_Pants
				materialtypes = list("Ore","Fabric","Fabric","Fabric")
				createditem = /obj/items/Equipment/Armor/Crafted/Pants/Reinforced_Pants
				createdname = "Reinforced Pants"

				Tier_1
					name = "T1 Reinforced Pants Plan"
					requiredlevel = 1
					tier = 1
					canresearch = 1

				Tier_2
					name = "T2 Reinforced Pants Plan"
					requiredlevel = 10
					tier = 2
					canresearch = 1

				Tier_3
					name = "T3 Reinforced Pants Plan"
					requiredlevel = 30
					tier = 3
					canresearch = 1

				Tier_4
					name = "T4 Reinforced Pants Plan"
					requiredlevel = 50
					tier = 4
					canresearch = 1