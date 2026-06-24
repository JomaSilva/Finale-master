//objects related to potion/poison making, follows a different system than item crafting

var
	list/alchemyeffectlist = list("Healing" = /effect/Alchemy/Health/Instant,\
								"Mending" = /effect/Alchemy/Health/Duration,\
								"Vitality" = /effect/Alchemy/Health/Buff,\
								"Withering" = /effect/Alchemy/Health/Debuff,\
								"Poisonous" = /effect/Alchemy/Health/Damage,\
								"Toxic" = /effect/Alchemy/Health/Damage_Duration,\
								"Energizing" = /effect/Alchemy/Energy/Instant,\
								"Innervating" = /effect/Alchemy/Energy/Duration,\
								"Focusing" = /effect/Alchemy/Energy/Buff,\
								"Distracting" = /effect/Alchemy/Energy/Debuff,\
								"Draining" = /effect/Alchemy/Energy/Damage,\
								"Sapping" = /effect/Alchemy/Energy/Damage_Duration,\
								"Vitalizing" = /effect/Alchemy/Stamina/Instant,\
								"Invigorating" = /effect/Alchemy/Stamina/Duration,\
								"Tiring" = /effect/Alchemy/Stamina/Damage,\
								"Exhausting" = /effect/Alchemy/Stamina/Damage_Duration,\
								"Strengthening" = /effect/Alchemy/Phys_Off/Buff,\
								"Diminishing" = /effect/Alchemy/Phys_Off/Debuff,\
								"Fortifying" = /effect/Alchemy/Phys_Def/Buff,\
								"Crumbling" = /effect/Alchemy/Phys_Def/Debuff,\
								"Effusing" = /effect/Alchemy/Ki_Off/Buff,\
								"Limiting" = /effect/Alchemy/Ki_Off/Debuff,\
								"Powering" = /effect/Alchemy/Ki_Def/Buff,\
								"Weakening" = /effect/Alchemy/Ki_Def/Debuff,\
								"Flourishing" = /effect/Alchemy/Technique/Buff,\
								"Fumbling" = /effect/Alchemy/Technique/Debuff,\
								"Skillful" = /effect/Alchemy/Ki_Skill/Buff,\
								"Inept" = /effect/Alchemy/Ki_Skill/Debuff,\
								"Hastening" = /effect/Alchemy/Speed/Buff,\
								"Slowing" = /effect/Alchemy/Speed/Debuff,\
								"Hardening" = /effect/Alchemy/Phys_Res/Buff,\
								"Softening" = /effect/Alchemy/Phys_Res/Debuff,\
								"Deflecting" = /effect/Alchemy/Energy_Res/Buff,\
								"Attracting" = /effect/Alchemy/Energy_Res/Debuff,\
								"Smothering" = /effect/Alchemy/Fire_Res/Buff,\
								"Drying" = /effect/Alchemy/Fire_Res/Debuff,\
								"Warming" = /effect/Alchemy/Ice_Res/Buff,\
								"Freezing" = /effect/Alchemy/Ice_Res/Debuff,\
								"Insulating" = /effect/Alchemy/Shock_Res/Buff,\
								"Conducting" = /effect/Alchemy/Shock_Res/Debuff,\
								"Immunizing" = /effect/Alchemy/Poison_Res/Buff,\
								"Infecting" = /effect/Alchemy/Poison_Res/Debuff,\
								"Sanctifying" = /effect/Alchemy/Holy_Res/Buff,\
								"Sinful" = /effect/Alchemy/Holy_Res/Debuff,\
								"Enshrouding" = /effect/Alchemy/Dark_Res/Buff,\
								"Defiling" = /effect/Alchemy/Dark_Res/Debuff,\
								"Magicing" = /effect/Alchemy/Magic/Instant,\
								"Magicfying" = /effect/Alchemy/Magic/Duration,\
								"Enchanting" = /effect/Alchemy/Magic/Buff,\
								"Dischanting" = /effect/Alchemy/Magic/Debuff,\
								"Managing" = /effect/Alchemy/Magic/Damage,\
								"Manafying" = /effect/Alchemy/Magic/Damage_Duration)
	list/alchemyprototypes = list()//this will be where the "prototypes" for alchemy objects are stored, to store the randomized effects
	list/alchemyplants = list()
	list/alchemyparts = list()
	alchloaded = 0


proc/Init_Alchemy()//this will create the set of random effects on alchemy items for each wipe
	set background = 1
	if(isnull(alchemyprototypes)) alchemyprototypes = list()
	if(alchemyprototypes.len)
		for(var/obj/items/Material/Alchemy/Plant/P in alchemyprototypes)
			alchemyplants+=P
		for(var/obj/items/Material/Alchemy/Animal/A in alchemyprototypes)
			alchemyparts+=A
	else
		var/list/types = list()
		var/list/picklist = list()
		picklist+=alchemyeffectlist
		types+=typesof(/obj/items/Material/Alchemy)
		for(var/A in types)
			if(!Sub_Type(A))
				var/obj/items/Material/Alchemy/B = new A
				while(B.Effects.len<4) //stop with sleep stuff in init, we don't need eet. (LET THE LAG JUST HAPPEN)
					if(picklist.len<4)//safety check so we don't get stuck in a loop on the last effects
						picklist+=alchemyeffectlist
					var/picked=0
					while(!picked)
						var/effect=pick(picklist)
						if(!(effect in B.Effects))
							B.Effects+=effect
							picklist-=effect
							picked=1
				B.Magic = rand(10,200)
				alchemyprototypes+=B
				if(istype(B,/obj/items/Material/Alchemy/Plant))
					alchemyplants+=B
				if(istype(B,/obj/items/Material/Alchemy/Animal))
					alchemyparts+=B
	alchloaded=1
mob/var
	list/potionlist = list()//current potion will be stored here
	list/poisonlist = list()//current poison will be stored here
	list/ingredientlist = list()//here's where we'll keep the ingredients a player has used, alongside how many effects they know on those ingredients
//this is an associative list between ingredients and the effects in the ingredients' effect lists, in order, represented with a bit flag
//Effect 1 = 1; Effect 2 = 2; Effect 3 = 4; Effect 4 = 8; the sum of these values is what will be associated with the ingredient in the list
//Effects 1+2 = 3; Effects 1+3 = 5; Effects 1+4 = 9; Effects 2+3 = 6; Effects 2+4 = 10; Effects 3+4 = 12
//Effects 1+2+3 = 7; Effects 1+2+4 = 11; Effects 1+3+4 = 13; Effects 2+3+4 = 14; Effects 1+2+3+4 = 15

obj/Alchemy
	Alchemy_Station
		name = "Alchemy Station"
		desc = "A place to brew potions and poisons."
		icon = 'Turf 52.dmi'
		icon_state = "water pot"
		density=1
		canbuild=1
		Bolted=1
		var
			masterytype = /datum/mastery/Crafting/Alchemy
			masteryname = "Alchemy"
		verb
			Study_Ingredient()
				set category = null
				set src in oview(1)
				var/list/studylist = list()
				for(var/obj/items/Material/Alchemy/A in usr.contents)
					if(!usr.ingredientlist[A.ingredtype])
						studylist+=A
				if(studylist.len==0)
					usr<<"You have no ingredients to study!"
				else
					var/obj/items/Material/Alchemy/choice = input(usr,"Which ingredient would you like to study? You can learn one effect from it, alongside its general properties.","") as null|anything in studylist
					if(!choice)
						return
					else
						var/effect = rand(1,4)//randomly pick which effect to learn
						usr<<"[choice.name]:[choice.desc]"
						usr<<"Magnitude: [choice.magnitude]"
						usr<<"Duration: [choice.duration]"
						usr<<"Effect: [choice.Effects[effect]]"
						usr.ingredientlist[choice.ingredtype] = 2**(effect-1)
						AddExp(usr,masterytype,100)
						usr.contents-=choice
			Brew()
				set category = null
				set src in oview(1)
				var/list/ingreds = list()
				for(var/obj/items/Material/Alchemy/A in usr.contents)
					ingreds+=A
				if(ingreds.len<2)
					usr<<"You need at least 2 ingredients to brew!"
					return
				var/level
				for(var/datum/mastery/M in usr.learnedmasteries)
					if(M.type == masterytype)
						level = M.level
				var/itemtype = input(usr,"Would you like to brew a potion or a poison? Potions are consumed for their effects, poisons are applied with attacks.","") as null|anything in list("Potion","Poison")
				if(!itemtype)
					return
				var/list/useingreds = list()
				while(useingreds.len<4)
					var/obj/items/Material/Alchemy/using = input(usr,"Which ingredient would you like to use? This is ingredient [useingreds.len+1] out of a maximum of 4. Note you need at least 2 ingredients to brew, and they cannot be of the same type.","") as null|anything in ingreds
					if(!using&&useingreds.len<2)
						usr<<"Brewing cancelled."
						return
					else if(!using)
						break
					var/repeat
					for(var/obj/items/Material/Alchemy/B in useingreds)
						if(using.type == B.type)
							usr<<"You are already using this ingredient type!"
							repeat = 1
							break
					if(!repeat)
						useingreds+=using
						ingreds-=using
					sleep(1)
				var/cont = input(usr,"Would you like to continue with your selected ingredients?","") in list("Yes","No")
				if(cont == "No")
					return
				var/mag = 0
				var/dur = 0
				var/list/peffects = list()
				for(var/obj/items/Material/Alchemy/C in useingreds)
					mag+=C.magnitude
					dur+=C.duration
					for(var/E in C.Effects)
						peffects[E] = peffects[E]+1//counting the number of times an effect occurs on our ingredients
				for(var/obj/items/Material/Alchemy/R in useingreds)//adding to known effects here
					var/known = usr.ingredientlist[R.ingredtype]
					var/list/effectnum = list()
					if(known in list(1,3,5,9,7,11,13,15))
						effectnum+=1
					if(known in list(2,3,6,10,7,11,14,15))
						effectnum+=2
					if(known in list(4,5,6,12,7,13,14,15))
						effectnum+=3
					if(known in list(8,9,10,12,11,13,14,15))
						effectnum+=4
					var/counter = 0
					for(var/E in R.Effects)
						counter++
						if(peffects[E]>=2&&!(counter in effectnum))
							effectnum+=counter
					var/known2=0
					for(var/a in effectnum)
						known2+=2**(a-1)
					usr.ingredientlist[R.ingredtype] = known2
				mag/=useingreds.len
				dur/=useingreds.len
				usr.contents-=useingreds
				var/list/ueffects = list()//here's where we drop in the effects for the item
				for(var/e1 in peffects)
					if(peffects[e1]==4)
						ueffects+=e1//if it's on all 4 ingredients, it goes in
						peffects-=e1
				if(ueffects.len<4)
					for(var/e2 in peffects)
						if(ueffects.len>=4)
							break
						if(peffects[e2]==3)
							ueffects+=e2
							peffects-=e2
				if(ueffects.len<4)
					for(var/e3 in peffects)
						if(ueffects.len>=4)
							break
						if(peffects[e3]==2)
							ueffects+=e3
							peffects-=e3
				if(ueffects.len<1)
					usr<<"Your brewing failed, it seems you did not have any matching effects."
					return
				else
					if(itemtype == "Potion")
						var/obj/items/Alchemy/Potion/O = new
						O.magnitude = min(mag,level)
						O.duration = min(dur,level)
						for(var/u in ueffects)
							O.Effects[u] = alchemyeffectlist[u]//back converting the effect names into actual effects in the list
						for(var/n in O.Effects)
							O.name = "[n] Potion"
							break
						usr.contents+=O
						usr<<"You've successfully brewed a potion!"
					else if(itemtype == "Poison")
						var/obj/items/Alchemy/Poison/O = new
						O.magnitude = min(mag,level)
						O.duration = min(dur,level)
						for(var/u in ueffects)
							O.Effects[u] = alchemyeffectlist[u]//back converting the effect names into actual effects in the list
						for(var/n in O.Effects)
							O.name = "[n] Poison"
						usr.contents+=O
						usr<<"You've successfully brewed a poison!"
					AddExp(usr,masterytype,10*(mag+dur))

obj/items/Material
	Alchemy
		icon = 'Alchemy Material.dmi'
		categories = list("Alchemy")
		techcost = 40
		var
			list/Effects = list()//contains the effects of the material, balanced around 4 at max
			ingredtype = ""//what is the base name of this?
			magnitude = 0//stronger ingredients will have higher magnitude to contribute
			duration = 0//same as above
		New()
			ingredtype = name
			..()
			magnitude*=(1+(quality-50)/100)
			duration*=(1+(quality-50)/100)
			for(var/obj/items/Material/Alchemy/A in alchemyprototypes)
				if(A.type == src.type)
					src.Effects=A.Effects
					src.Magic = A.Magic
					break
		Description()
			..()
			if(src.ingredtype in usr.ingredientlist)//has the player learned about this ingredient?
				usr<<"---Alchemy Stats---"
				usr<<"Magnitude: [magnitude]"
				usr<<"Duration: [duration]"
				var/known = usr.ingredientlist[ingredtype]
				usr<<"Known effects:"
				if(known in list(1,3,5,9,7,11,13,15))
					usr<<"[Effects[1]]"
				if(known in list(2,3,6,10,7,11,14,15))
					usr<<"[Effects[2]]"
				if(known in list(4,5,6,12,7,13,14,15))
					usr<<"[Effects[3]]"
				if(known in list(8,9,10,12,11,13,14,15))
					usr<<"[Effects[4]]"
			else
				usr<<"You do not know the properties of this material."
		Plant
			desc = "A plant with alchemical properties"
			Basil
				name = "Basil"
				magnitude = 10
				duration = 10
			Oregano
				name = "Oregano"
				magnitude = 20
				duration = 20
			Aloe
				name = "Aloe"
				magnitude = 30
				duration = 30
			Clover
				name = "Clover"
				magnitude = 50
				duration = 20
			Fern
				name = "Fern"
				magnitude = 20
				duration = 50
			Sage
				name = "Sage"
				magnitude = 65
				duration = 30
			Lavender
				name = "Lavender"
				magnitude = 40
				duration = 70
			Mint
				name = "Mint"
				magnitude = 70
				duration = 50
			Thyme
				name = "Thyme"
				magnitude = 60
				duration = 60
			Yarrow
				name = "Yarrow"
				magnitude = 80
				duration = 10
			Dandelion
				name = "Dandelion"
				magnitude = 50
				duration = 100
				mag_effects = list("p_magnify","t_tar_m","e_kidef")
				Magic = 30
			Thistle
				name = "Thistle"
				magnitude = 100
				duration = 30
		Animal
			desc = "An animal part with alchemical properties"
			Liver
				name = "Liver"
				magnitude = 20
				duration = 40
				mag_effects = list("p_magnify","t_tar_m","e_technique")
				Magic = 10
			Spleen
				name = "Spleen"
				magnitude = 45
				duration = 30
			Brain
				name = "Brain"
				magnitude = 50
				duration = 50
				mag_effects = list("p_subtract","t_tar_m","e_consume")
				Magic = 30
			Blood
				name = "Blood"
				magnitude = 70
				duration = 20
			Bile
				name = "Bile"
				magnitude = 15
				duration = 90
			Stomach
				name = "Stomach"
				magnitude = 35
				duration = 55
			Tendon
				name = "Tendon"
				magnitude = 55
				duration = 70
			Lung
				name = "Lung"
				magnitude = 40
				duration = 80
			Bladder
				name = "Bladder"
				magnitude = 65
				duration = 35
			Intestine
				name = "Intestine"
				magnitude = 10
				duration = 100
			Heart
				name = "Heart"
				magnitude = 100
				duration = 35
			Gallstone
				name = "Gallstone"
				magnitude = 100
				duration = 100


obj/Raw_Material/
	Herbs
		name = "Herbs"
		icon = 'jungleplant32x32.dmi'
		spawnmat = null//set on new
		masterytype = /datum/mastery/Life/Harvesting
		masteryname = "Harvesting"
		masterylevel = 1

		New()
			..()
			while(!alchloaded)
				sleep(1)
			var/obj/tmpplant = pick(alchemyplants)
			spawnmat = tmpplant.type

	Preserved_Pocket
		name = "Preserved Pocket"
		icon = 'mining.dmi'
		icon_state = "goliath_hide"
		spawnmat = null//set on new
		masterytype = /datum/mastery/Life/Harvesting
		masteryname = "Harvesting"
		masterylevel = 1

		New()
			..()
			while(!alchloaded)
				sleep(1)
			spawnmat = pick(typesof(/obj/items/Material/Alchemy/Misc) - /obj/items/Material/Alchemy/Misc)


obj/matspawners
	Herbs
		materialID = /obj/Raw_Material/Herbs

	Preserved_Pocket
		materialID = /obj/Raw_Material/Preserved_Pocket

obj/items/Alchemy
	icon = 'Alchemy Bottle.dmi'
	verb
		Description()
			set category = null
			usr<<"[name]"
			usr<<"Magnitude: [magnitude]"
			usr<<"Duration: [duration] seconds"
			usr<<"Effects include:"
			for(var/a in Effects)
				usr<<"[a]"
	var
		list/Effects = list()//where the effects are stored, balanced around 4 on an item
		magnitude = 0//how strong are the effects, should range from 0-100, formulas on the effects themselves account for this
		duration = 0//how long do they last, if they are over time
	Potion//potions are applied to the user
		verb/Drink()
			set category = null
			set src in usr
			for(var/effect/Potion/P in usr.effects)
				usr<<"You cannot consume another potion yet!"
				return
			usr<<"You drink the potion!"
			for(var/a in Effects)
				spawn usr.AddEffect(Effects[a])
				sleep(1)
				for(var/effect/Alchemy/e in usr.effects)
					if(e.type == Effects[a])
						e.duration = duration*10
						e.magnitude = magnitude
			usr.potionlist+=src
			usr.AddEffect(/effect/Potion)
			usr.contents-=src
	Poison//poisons are applied on melee attacks, only one poison can be active at once
		verb/Apply()
			set category = null
			set src in usr
			for(var/effect/Poison/P in usr.effects)
				usr<<"You cannot apply more poison yet!"
				return
			usr<<"You apply the poison!"
			usr.poisonlist+=src
			usr.AddEffect(/effect/Poison)
			usr.contents-=src
		proc/Affect(mob/M)
			M<<"You are poisoned!"
			for(var/a in Effects)
				spawn M.AddEffect(Effects[a])
				sleep(1)
				for(var/effect/Alchemy/e in M.effects)
					if(e.type == Effects[a])
						e.duration = duration*10
						e.magnitude = magnitude