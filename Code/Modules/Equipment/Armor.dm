//list of various armor under the new equipment system
//relevant variables:
//armored: flat damage reduction for equipped limbs, additive
//deflection: flat boost to dodge rate, additive
//protection: percent damage reduction, multiplicative
obj/items/Equipment/Armor//basic armor type templates, feel free to vary them from this
	Body
		icon='Clothes Kung Fu Shirt.dmi'
		slots=list(/datum/Body/Torso,/datum/Body/Abdomen,/datum/Body/Arm,/datum/Body/Arm)
	Helmet
		icon='Hat.dmi'
		slots=list(/datum/Body/Head)
		plane = HAT_LAYER
	Gloves
		icon='Clothes_Gloves.dmi'
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
	Boots
		icon='Clothes_Boots.dmi'
		slots=list(/datum/Body/Leg/Foot,/datum/Body/Leg/Foot)
	Pants
		icon='Clothes_Pants.dmi'
		slots=list(/datum/Body/Leg,/datum/Body/Leg)

obj/items/Equipment/Armor/Body
	Leather_Jacket
		name="Leather Jacket"
		desc="A jacket made of leather. Offers minimal defense."
		icon='Clothes_Jacket.dmi'
		armored=1
	Gi
		name="Gi"
		desc="A shirt worn by marital artists. Is very flexible."
		icon='Clothes_GiTop.dmi'
		deflection=1

	Fighting_Shirt
		name="Fighting Shirt"
		desc="A shirt commonly worn while fighting with martial arts."
		rarity=2
		armored=1
		deflection=1

	Heros_Clothes
		name="Hero's Clothes"
		desc="Light attire designed in the image of an ancient hero. It has been blessed with divine protection."
		icon='Clothes_Heros_Tunic.dmi'
		rarity=7
		armored=2
		resistance=4
		deflection=5

	Female_Gi
		name="Female Gi"
		desc="A shirt worn by female marital artists. Is very flexible."
		icon='Suraya Gi Two Piece.dmi'
		deflection=1

	Kimono
		name="Kimoni"
		desc="Traditional garb for those from the East."
		icon='Jiraya Chill Clothe black + blue.dmi'
		rarity=2
		armored=1
		deflection=2

	Torso_Armor
		name="Protector's Plate"
		desc="Unique bit of light armor that a diligent protector wears."
		icon='Nier Torso.dmi'
		rarity=4
		armored=2
		deflection=2

obj/items/Equipment/Armor/Helmet
	Hat
		name="Hat"
		desc="A simple hat, keeps sun off your head."
		deflection=1
	Hood
		name="Hood"
		desc="A thick hood. Provides some defense agains the elements."
		icon='Clothes_Hood.dmi'
		armored=1

	Headband
		name="Headband"
		desc="A headband commonly worn by fighters. It makes you feel fast!"
		icon='Clothes_Headband.dmi'
		rarity=2
		deflection=2

	Heros_Cap
		name="Hero's Cap"
		desc="A cap resembling a hat once worn by a legendary hero. In addition to being easy to move around in, the cap has been blessed with divine protection."
		icon='Clothes_Heros_Hat.dmi'
		rarity=7
		armored=2
		resistance=2
		deflection=3

	Tech_Helmet
		name="Tech Helmet"
		desc="A rare looking piece of tech."
		icon='TechHelm(1).dmi'
		rarity=3
		deflection=2
		armored=1

	Witch_Hat
		name="Witch Hat"
		desc="A very cute looking witch hat."
		icon='Marisa Hat.dmi'
		rarity=3
		deflection=3

	Predator_Helmet
		name="Predator Helmet"
		desc="Helmet of a unique alien that lusts for the thrill of the hunt."
		icon='PredatorMask.dmi'
		rarity=4
		armored=3

obj/items/Equipment/Armor/Gloves
	Leather_Gloves
		name="Leather Gloves"
		desc="Gloves made of leather. They look cool."
		armored=1

	Wristbands
		name="Wristbands"
		desc="Bands for your wrists."
		icon='Clothes_Wristband.dmi'
		deflection=1

	Sturdy_Gloves
		name="Sturdy Gloves"
		desc="Gloves made of a sturdy material."
		rarity=2
		armored=1
		deflection=1

	Predator_Bracer
		name="Predator Bracer"
		desc="Bracer that belong to a true hunter."
		icon='PredatorWristBracerR.dmi'
		rarity=4
		armored=2
		deflection=2

	Power_Wristbands
		name="Power Wristbands"
		desc="Comfortable Wristbands."
		icon='Wristbands.dmi'
		rarity=2
		deflection=2

	Chains
		name="Chains"
		desc="Edgy but kinda cool..."
		icon='Chained Arms.dmi'
		rarity=3
		deflection=2
		armored=2

obj/items/Equipment/Armor/Boots
	Work_Boots
		name="Work Boots"
		desc="Tough boots made to last."
		armored=1

	Running_Shoes
		name="Running Shoes"
		desc="Shoes made for running."
		icon='Clothes_Shoes.dmi'
		deflection=1

	Sturdy_Boots
		name="Sturdy Boots"
		desc="Boots made of a sturdy material."
		rarity=2
		armored=1
		deflection=1

	Saiyan_Boots
		name="Comfy Boots"
		desc="Comfortable and durable boots...Why are they here?."
		icon='Clothes, Saiyan Shoes.dmi'
		rarity=4
		armored=2
		deflection=2

	Zangya_Boots
		name="Gold Boots"
		desc="Somewhat Regal looking boots."
		icon='Zangya Boots.dmi'
		rarity=5
		armored=1
		deflection=3

obj/items/Equipment/Armor/Pants
	Thick_Pants
		name="Thick Pants"
		desc="Pants made of thick fabric."
		armored=1

	Track_Pants
		name="Track Pants"
		desc="Pants made for running in."
		deflection=1

	Durable_Pants
		name="Durable Pants"
		desc="Pants made to be durable."
		rarity=2
		armored=1
		deflection=1

	Leather_Pants
		name="Leather Pants"
		desc="Stylish looking pants"
		icon='Leather pants white strips.dmi'
		rarity=3
		armored=2
		deflection=1