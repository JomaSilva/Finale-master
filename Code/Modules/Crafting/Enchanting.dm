//objects related to enchantments
var/list/enchantlist = list("Vitality" = /effect/Enchantment/General/Health/Buff,\
							"Focusing" = /effect/Enchantment/General/Energy/Buff,\
							"Strengthening" = /effect/Enchantment/General/Phys_Off/Buff,\
							"Fortifying" = /effect/Enchantment/General/Phys_Def/Buff,\
							"Effusing" = /effect/Enchantment/General/Ki_Off/Buff,\
							"Powering" = /effect/Enchantment/General/Ki_Def/Buff,\
							"Flourishing" = /effect/Enchantment/General/Technique/Buff,\
							"Skillful" = /effect/Enchantment/General/Ki_Skill/Buff,\
							"Hastening" = /effect/Enchantment/General/Speed/Buff,\
							"Hardening" = /effect/Enchantment/General/Phys_Res/Buff,\
							"Deflecting" = /effect/Enchantment/General/Energy_Res/Buff,\
							"Smothering" = /effect/Enchantment/General/Fire_Res/Buff,\
							"Warming" = /effect/Enchantment/General/Ice_Res/Buff,\
							"Insulating" = /effect/Enchantment/General/Shock_Res/Buff,\
							"Immunizing" = /effect/Enchantment/General/Poison_Res/Buff,\
							"Sanctifying" = /effect/Enchantment/General/Holy_Res/Buff,\
							"Enshrouding" = /effect/Enchantment/General/Dark_Res/Buff,\
							"Sharpening" = /effect/Enchantment/Weapon/Phys_Dam/Buff,\
							"Crackling" = /effect/Enchantment/Weapon/Energy_Dam/Buff,\
							"Scorching" = /effect/Enchantment/Weapon/Fire_Dam/Buff,\
							"Freezing" = /effect/Enchantment/Weapon/Ice_Dam/Buff,\
							"Shocking" = /effect/Enchantment/Weapon/Shock_Dam/Buff,\
							"Sickening" = /effect/Enchantment/Weapon/Poison_Dam/Buff,\
							"Purifying" = /effect/Enchantment/Weapon/Holy_Dam/Buff,\
							"Corrupting" = /effect/Enchantment/Weapon/Dark_Dam/Buff)//here is where enchantment names will be associated with effects

mob/var
	list/knownenchants = list()
	studyenchant = ""//what enchantment are you studying currently?
	studyenchanttimer = 0//how long do you have left to study?

obj/Enchanting
	Enchanting_Table
		name = "Enchanting Table"
		desc = "A table for learning, applying, and removing enchantments."
		icon = 'furnature.dmi'
		icon_state = "37"
		density = 1
		canbuild=1
		fragile = 1
		Bolted = 1
		var
			masterytype = /datum/mastery/Crafting/Enchanting
			masteryname = "Enchanting"

		verb
			Study_Enchantment()
				set category = null
				set src in oview(1)
				var/list/studylist = list()
				if(usr.studyenchant)
					var/cont = alert(usr,"You are currently studying and have [usr.studyenchanttimer/10] seconds left to understand it. Would you like to study a different enchantment, losing all progress?","","Yes","No")
					if(cont=="No")
						return
					if(cont=="Yes")
						usr.studyenchant = ""
						usr.studyenchanttimer = 0
				for(var/obj/items/Material/Enchanting/Catalyst/A in usr.contents)
					if(!(A.enchantment in usr.knownenchants))
						studylist+=A
				if(studylist.len==0)
					usr<<"You have no catalysts to study!"
				else
					var/obj/items/Material/Enchanting/Catalyst/choice = input(usr,"Which catalyst would you like to study? You can learn what enchantment it confers if you meditate long enough while studying it.","") as null|anything in studylist
					if(!choice)
						return
					else
						usr.studyenchant=choice.enchantment
						usr.studyenchanttimer=18000/max(choice.tier,1)
						usr<<"You begin to study the [choice.name]'s magic. It will take you [usr.studyenchanttimer/10] seconds of meditation to complete your study"
			Enchant()
				set category = null
				set src in oview(1)
				var/list/itemlist = list()
				var/enchlevel = 0
				for(var/datum/mastery/Crafting/Enchanting/L in usr.learnedmasteries)
					enchlevel = L.level
				for(var/obj/items/Equipment/E in usr.contents)
					if(E.enchantslots>=1)
						itemlist+=E
				if(itemlist.len==0)
					usr<<"You have no items that can be enchanted! Items must have an open enchantment slot (q50 crafted items or higher)."
					return
				var/list/catalist = list()
				for(var/obj/items/Material/Enchanting/Catalyst/A in usr.contents)
					if(A.enchantment in usr.knownenchants)
						catalist+=A
				if(catalist.len==0)
					usr<<"You have no catalysts that you know how to use available."
					return
				var/list/sourcelist = list()
				for(var/obj/items/Material/Enchanting/Source/B in usr.contents)
					sourcelist+=B
				if(sourcelist.len==0)
					usr<<"You do not have an available source!"
					return
				var/list/focuslist = list()
				for(var/obj/items/Material/C in usr.contents)
					if("Focus" in C.categories)
						focuslist+=C
				if(focuslist.len==0)
					usr<<"You do not have an available focus!"
					return
				var/obj/items/Equipment/choice = input(usr,"Which item would you like to enchant?","") as null|anything in itemlist
				if(!choice)
					return
				for(var/obj/items/Material/Enchanting/Catalyst/D in catalist)
					if(D.enchanttype&&!istype(choice,D.enchanttype))
						catalist-=D
				if(catalist.len==0)
					usr<<"You have no catalysts compatible with this item type."
					return
				var/obj/items/Material/Enchanting/Catalyst/enchant = input(usr,"Which catalyst would you like to use? Note that [choice.name] can only support enchantments of tier [choice.rarity] or lower.","") as null|anything in catalist
				if(!enchant)
					return
				var/obj/items/Material/Enchanting/Source/source = input(usr,"Which source would you like to use? Your source must have Strength equal to or greater than the tier of enchantment you would like to create.","") as null|anything in sourcelist
				if(!source)
					return
				var/obj/items/Material/focus = input(usr,"Which focus would you like to use? The clarity of your focus must be at least 10x the tier of your enchantment.","") as null|anything in focuslist
				if(!focus)
					return
				var/maxtier = min(round(min(enchant.statvalues["Strength"],source.statvalues["Energy"]/10,focus.statvalues["Clarity"]/10,choice.rarity)),min(max(round(enchlevel/20+1.5),1),7))
				if(maxtier<1)
					usr<<"This set of items is not powerful enough to produce an enchantment!"
					return
				var/createtier = input(usr,"What tier of [enchant.enchantment] enchantment would you like to apply? Your current set of materials can produce up to a [maxtier] tier enchantment (minimum of 1).","") as null|num
				if(!createtier)
					return
				createtier = round(max(createtier, 1))
				choice.enchants[enchant.enchantment] = createtier
				choice.enchantnames+="[enchant.enchantment] [createtier]"
				choice.enchantslots-=1
				usr.contents-=list(enchant,source,focus)
				AddExp(usr,/datum/mastery/Crafting/Enchanting,100*createtier)
				usr<<"You have successfully enchanted your [choice.name] with a tier [createtier] [enchant.enchantment] enchantment!"

			Disenchant()
				set category = null
				set src in oview(1)
				var/list/itemlist = list()
				var/enchlevel = 0
				for(var/datum/mastery/Crafting/Enchanting/L in usr.learnedmasteries)
					enchlevel = L.level
				for(var/obj/items/Equipment/E in usr.contents)
					if(E.enchants.len>0)
						itemlist+=E
				if(itemlist.len==0)
					usr<<"You have no items that can be disenchanted!"
					return
				var/list/catalist = list()
				for(var/obj/items/Material/Enchanting/Catalyst/A in usr.contents)
					if(A.enchantment in usr.knownenchants)
						catalist+=A
				if(catalist.len==0)
					usr<<"You have no catalysts that you know how to use available."
					return
				var/list/sourcelist = list()
				for(var/obj/items/Material/Enchanting/Source/B in usr.contents)
					sourcelist+=B
				if(sourcelist.len==0)
					usr<<"You do not have an available source!"
					return
				var/list/focuslist = list()
				for(var/obj/items/Material/C in usr.contents)
					if("Focus" in C.categories)
						focuslist+=C
				if(focuslist.len==0)
					usr<<"You do not have an available focus!"
					return
				var/obj/items/Equipment/choice = input(usr,"Which item would you like to disenchant?","") as null|anything in itemlist
				if(!choice)
					return
				for(var/obj/items/Material/Enchanting/Catalyst/D in catalist)
					if(D.enchanttype&&!istype(choice,D.enchanttype))
						catalist-=D
				if(catalist.len==0)
					usr<<"You have no catalysts compatible with this item type."
					return
				var/list/disenchlist = list()
				for(var/a in choice.enchants)
					if(a in usr.knownenchants)
						disenchlist+=a
				if(disenchlist.len==0)
					usr<<"You don't know how to remove any of these enchantments!"
					return
				var/disenchant = input(usr,"Which enchantment would you like to remove?","") as null|anything in disenchlist
				if(!disenchant)
					return
				for(var/obj/items/Material/Enchanting/Catalyst/D1 in catalist)
					if(D1.enchantment!=disenchant||D1.statvalues["Strength"]<choice.enchants[disenchant])
						catalist-=D1
				if(catalist.len==0)
					usr<<"You have no catalysts able to remove this enchantment."
					return
				for(var/obj/items/Material/Enchanting/Source/D2 in sourcelist)
					if(D2.statvalues["Energy"]/10<choice.enchants[disenchant])
						sourcelist-=D2
				if(sourcelist.len==0)
					usr<<"You have no sources powerful enough to remove this enchantment."
					return
				for(var/obj/items/Material/D3 in focuslist)
					if(D3.statvalues["Clarity"]/10<choice.enchants[disenchant])
						focuslist-=D3
				if(focuslist.len==0)
					usr<<"You have no focus powerful enough to remove this enchantment."
					return
				var/obj/items/Material/Enchanting/Catalyst/enchant = input(usr,"Which catalyst would you like to use?","") as null|anything in catalist
				if(!enchant)
					return
				var/obj/items/Material/Enchanting/Source/source = input(usr,"Which source would you like to use?","") as null|anything in sourcelist
				if(!source)
					return
				var/obj/items/Material/focus = input(usr,"Which focus would you like to use?","") as null|anything in focuslist
				if(!focus)
					return
				var/maxtier = min(round(min(enchant.statvalues["Strength"],source.statvalues["Energy"]/10,focus.statvalues["Clarity"]/10,choice.rarity)),min(max(round(enchlevel/20+1.5),1),7))
				if(maxtier<choice.enchants[disenchant])
					usr<<"Your enchantment skill is not high enough to disenchant this effect!"
					return
				AddExp(usr,/datum/mastery/Crafting/Enchanting,100*choice.enchants[disenchant])
				choice.enchantnames-="[disenchant] [choice.enchants[disenchant]]"
				choice.enchants-=disenchant
				choice.enchantslots+=1
				usr.contents-=list(enchant,source,focus)
				usr<<"You have successfully disenchanted your [choice.name], removing the [disenchant] effect!"

obj/items/Material
	Enchanting//Catalysts and Sources will be here, Foci are things like gems
		Catalyst
			icon = 'Crystal.dmi'
			categories = list("Catalyst")
			statvalues = list("Strength" = 1)//strength limits what tier the enchantment can be
			tier = 1//what is the "base" tier of the enchantment? should be the same as the default "Strength"
			Magic = 70
			mag_effects = list("p_magnify","t_tar_m","e_burn")
			var/enchantment = ""//what is the name of the enchantment this catalyst can confer?
			var/enchanttype = null//can specify whether this can only be applied to weapons, armor, etc.
			New()
				..()
				tier = rand(1,7)//for now
				statvalues["Strength"]=statvalues["Strength"]*tier
				name = "Tier [tier] [name]"
			Description()
				..()
				if(!(enchantment in usr.knownenchants))
					usr<<"You feel some strange power in this."
				else
					usr<<"This object can confer the [enchantment] enchantment."
			Vital_Shard
				name = "Vital Shard"
				enchantment = "Vitality"

			Focus_Shard
				name = "Focus Shard"
				enchantment = "Focusing"

			Strength_Shard
				name = "Strength Shard"
				enchantment = "Strengthening"

			Fortitude_Shard
				name = "Fortitude Shard"
				enchantment = "Fortifying"

			Effusive_Shard
				name = "Effusive Shard"
				enchantment = "Effusing"

			Power_Shard
				name = "Power Shard"
				enchantment = "Powering"

			Flourish_Shard
				name = "Flourish Shard"
				enchantment = "Flourishing"

			Skill_Shard
				name = "Skill Shard"
				enchantment = "Skillful"

			Haste_Shard
				name = "Haste Shard"
				enchantment = "Hastening"

			Hard_Shard
				name = "Hard Shard"
				enchantment = "Hardening"

			Deflect_Shard
				name = "Deflect Shard"
				enchantment = "Deflecting"

			Smother_Shard
				name = "Smother Shard"
				enchantment = "Smothering"

			Warm_Shard
				name = "Warm Shard"
				enchantment = "Warming"

			Insulated_Shard
				name = "Insulated Shard"
				enchantment = "Insulating"

			Immune_Shard
				name = "Immune Shard"
				enchantment = "Immunizing"

			Sanctified_Shard
				name = "Sanctified Shard"
				enchantment = "Sanctifying"

			Enshrouded_Shard
				name = "Enshrouded Shard"
				enchantment = "Enshrouding"

			Sharp_Shard
				name = "Sharp Shard"
				enchantment = "Sharpening"

			Crackling_Shard
				name = "Crackling Shard"
				enchantment = "Crackling"

			Scorched_Shard
				name = "Scorched Shard"
				enchantment = "Scorching"

			Frozen_Shard
				name = "Frozen Shard"
				enchantment = "Freezing"

			Shocked_Shard
				name = "Shocked Shard"
				enchantment = "Shocking"

			Sickened_Shard
				name = "Sickened Shard"
				enchantment = "Sickening"

			Purified_Shard
				name = "Purified Shard"
				enchantment = "Purifying"

			Corrupted_Shard
				name = "Corrupted Shard"
				enchantment = "Corrupting"
		Source
			icon = 'Corrupted Crystal.dmi'
			categories = list("Source")
			statvalues = list("Energy" = 10)//the source needs an energy equal to or greater than 10x the tier of the enchantment
			mag_effects = list("p_magnify","t_tar_m","e_burn")
			Magic = 60
			Charged_Stone
				name = "Charged Stone"
				Magic = 10
			Powered_Stone
				name = "Powered Stone"
				statvalues = list("Energy" = 20)
				Magic = 30
			Pulsing_Stone
				name = "Pulsing Stone"
				statvalues = list("Energy" = 30)
				Magic = 60
			Energized_Stone
				name = "Energized Stone"
				statvalues = list("Energy" = 40)
				Magic = 90
			Ionized_Stone
				name = "Ionized Stone"
				statvalues = list("Energy" = 50)
				Magic = 120

obj/Raw_Material/
	Source_Stone
		name = "Charged Stone"
		icon = 'Red Rock.dmi'
		spawnmat = null
		masterytype = /datum/mastery/Life/Mining
		masteryname = "Mining"
		masterylevel = 1

		New()
			var/tried = 0
			while(!tried)
				var/spawned = pick(typesof(/obj/items/Material/Enchanting/Source))
				if(Sub_Type(spawned))
					continue
				else
					spawnmat = spawned
					tried=1
			..()

	Catalyst_Stone
		name = "Vital Shard"
		icon = 'Shiny Rock.dmi'
		spawnmat = null
		masterytype = /datum/mastery/Life/Mining
		masteryname = "Mining"
		masterylevel = 1

		New()
			var/tried = 0
			while(!tried)
				var/spawned = pick(typesof(/obj/items/Material/Enchanting/Catalyst))
				if(Sub_Type(spawned))
					continue
				else
					spawnmat = spawned
					tried=1
			..()