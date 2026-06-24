datum/mastery/Crafting
	icon = 'Ability.dmi'
	types = list("Mastery","Crafting")
	battle = 0

	expscale(num)
		if(!savant)
			return
		var/gain = num*gexprate*savant.craftexprate
		if(lifeskillcap&&level>=lifeskillcap)
			gain = 0
		return gain

	Smithing
		name = "Smithing"
		desc = "Heat and beat metals into weapons and armor."
		lvltxt = "Getting better at smithing lets you craft and research higher tier items.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your smithing skill improves! Your Smithing is now level [level]!"

	Handicraft
		name = "Handicraft"
		desc = "Shape various materials into accessories."
		lvltxt = "Getting better at handicraft lets you craft and research higher tier items.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your handicraft skill improves! Your Handicraft is now level [level]!"

	Alchemy
		name = "Alchemy"
		desc = "Produce potent potions and poisons."
		lvltxt = "The maximum strength and duration of your potions and poisons improves with each level."
		visible = 1

		levelstat()
			..()
			savant<<"Your alchemy skill improves! Your Alchemy is now level [level]!"

	Enchanting
		name = "Enchanting"
		desc = "Empower equipment with magical effects, or strip the effects from existing items."
		lvltxt = "Getting better at enchanting lets you enchant, disenchant, and research higher tier effects.\nLevel 10: Tier 2, Level 30: Tier 3\nLevel 50: Tier 4, Level 70: Tier 5\nLevel 90: Tier 6, Level 100: Tier 7"
		visible = 1

		levelstat()
			..()
			savant<<"Your enchanting skill improves! Your Enchanting is now level [level]!"

	Technology
		name = "Technology"
		desc = "Use the power of SCIENCE to discover new technology and improve existing items."
		lvltxt = "Improving your Technology mastery will enable you to create more advanced tech."
		visible = 1

		acquire()
			..()
			savant.techskill=1

		remove()
			..()
			savant.techskill-=level

		levelstat()
			..()
			savant<<"Your technology skill improves! Your Technology is now level [level]!"
			savant.techskill++