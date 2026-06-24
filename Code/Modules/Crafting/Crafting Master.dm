//crafting master file, outlines the basic procs and objects of the system
var
	list/globalrecipes = list()
	tmp/recipecheck = 0

proc/Init_Recipes()
	set waitfor = 0
	recipecheck = 1
	var/list/types = list()
	types+=typesof(/obj/items/Plan)
	for(var/A in types)
		var/obj/items/Plan/B = new A
		if(B.canresearch)
			globalrecipes.Add(B)
	recipecheck = 0

mob
	var
		list/planlist = list()//list of learned plans
		trainingmode = 0//don't craft the item, but get a slight boost to exp
	verb
		Check_Recipes()
			set category = "Other"
			var/obj/items/Plan/choice = input(usr,"Which recipe would you like to check?","") as null|anything in usr.planlist
			if(!choice)
				return
			else
				choice.Description()

		Practice_Crafting()
			set category = "Other"
			if(usr.trainingmode)
				usr<<"You will now actually complete your items, losing the training bonus."
				usr.trainingmode = 0
			else
				usr<<"You will now practice crafting, rather than creating items. This gives you a small training bonus."
				usr.trainingmode = 1

obj/items
	var
		quality = 0//quality will determine how "strong" materials are, alongside how "strong" resultant products are
		qualitylabel = ""//text label for the quality, based on numbers
		creator = "None"//used to denote who made things
	New()
		..()
		if(quality)
			switch(quality)
				if(1 to 20)
					qualitylabel = "Shoddy"
				if(21 to 40)
					qualitylabel = "Normal"
				if(41 to 60)
					qualitylabel = "Quality"
				if(61 to 80)
					qualitylabel = "Superior"
				if(81 to 99)
					qualitylabel = "Exquisite"
				if(100)
					qualitylabel = "Fantastic"

obj/items
	Material
		name = "Material"
		desc = "Used in crafting"
		icon = 'Resources.dmi'
		SaveItem=0
		var
			list/categories = list()//list of "types" of materials, used to enable a given material for multiple crafting methods
			list/statvalues = list()//associative list of stat names and numbers, should range from 0-100
			tier = 0//higher tier materials are rarer and stronger
		New()
			quality = rand(1,100)
			..()
			name = "[qualitylabel] [name] (Q[quality])"
			/*switch(quality)
				if(1 to 20)
					name = "<font color=gray>[qualitylabel] [name] (Q[quality])</font>"
				if(21 to 40)
					name = "<font color=white>[qualitylabel] [name] (Q[quality])</font>"
				if(41 to 60)
					name = "<font color=silver>[qualitylabel] [name] (Q[quality])</font>"
				if(61 to 80)
					name = "<font color=teal>[qualitylabel] [name] (Q[quality])</font>"
				if(81 to 99)
					name = "<font color=purple>[qualitylabel] [name] (Q[quality])</font>"
				if(100)
					name = "<font color=red>[qualitylabel] [name] (Q[quality])</font>"*/
			for(var/A in statvalues)
				statvalues[A] = statvalues[A]*(1+(quality-50)/100)
		verb
			Description()
				set category = null
				usr<<"[name]:[desc]"
				usr<<"Quality: [qualitylabel] ([quality])"
				usr<<"Tier: [tier]"
				usr<<"Category:"
				for(var/a in categories)
					usr<<"[a]"
				if(statvalues.len)
					usr<<"Attributes:"
					for(var/b in statvalues)
						usr<<"[b]:[statvalues[b]]"

	Plan//plans are used to craft shit, you learn them and then crafting objects (benches, forges, etc) check against your learned list
		name = "Crafting Plan"
		desc = "Teaches how to craft an item."
		icon = 'Crafting Plan.dmi'
		var
			list/materialtypes = list()//list of material types the plan uses
			createditem = null//path for the item that this plan creates
			createdname = ""//name of the item it makes, used to make shit easier to display
			masterytype = null//what mastery does this fall under
			masteryname = ""//same idea as created name
			requiredlevel = 0//what level in the mastery do you need to learn this?
			tier = 0//mostly used to denote the rarity/strength
			canresearch = 0//can this plan be discovered through research?
			quantity = 1//how many items does this make?
		verb
			Description()
				set category = null
				usr<<"[name]:[desc]"
				usr<<"Is a tier [tier] recipe."
				usr<<"Falls under the [masteryname] mastery, requires level [requiredlevel] to learn."
				usr<<"Used to create: [createdname]"
				for(var/A in src.materialtypes)
					if(A=="Zenni")
						usr<<"Costs [materialtypes["Zenni"]] zenni."
					else
						usr<<"Requires [A] to make."

			Learn()
				set category = null
				for(var/obj/items/Plan/P in usr.planlist)
					if(P.type==src.type)
						usr<<"You already know this plan!"
						return
				if(!masterytype)
					usr.planlist+=src
					usr.contents-=src
					usr<<"You learned the [name]"
				else
					var/check=0
					var/lcheck=0
					for(var/datum/mastery/a in usr.learnedmasteries)
						if(a.type == masterytype&&a.learned)
							check++
							if(a.level >= requiredlevel)
								lcheck++
					if(!check)
						usr<<"You don't know the mastery you need!"
					else if(!lcheck)
						usr<<"Your mastery level is too low to learn this!"
					else
						usr.planlist+=src
						usr.contents-=src
						usr<<"You learned the [name]"

obj/Crafting
	density = 1
	Bolted = 1
	fragile = 1
	var
		masterytype = null
		masteryname = ""
		researchitem = null//what kind of material does research use?
	verb
		Research()
			set category = null
			set src in oview(1)
			var/maxtier = 0
			if(recipecheck)
				usr<<"You can't research at the moment..."
				return
			for(var/datum/mastery/A in usr.learnedmasteries)
				if(A.type == masterytype)
					maxtier+=A.level
					break
			if(!maxtier)
				usr<<"You lack the skill to use this!"
				return
			else
				if(maxtier==100)
					maxtier = 7
				else
					maxtier = min(max(round(maxtier/20+1.5),1),7)
			var/tier = input(usr,"What tier recipe would you like to research? The highest tier you have access to is [maxtier]. Note you need [researchitem] of the tier you choose or higher.","") as num
			if(tier > maxtier)
				usr <<"You cannot create recipes above your max tier."
				return
			var/list/planlist = list()
			for(var/obj/items/Plan/P in globalrecipes)
				if(P.masterytype == src.masterytype&&P.tier == tier)
					var/obj/items/Plan/NP = new P.type
					planlist+= NP
			if(planlist.len == 0)
				usr<<"You don't think you can make a plan of this tier..."
				return
			var/cost = 1000 * (2**tier)
			if(usr.zenni<cost)
				usr<<"You don't have enough money for this research..."
				return
			var/list/mats = list()
			for(var/obj/items/Material/M in usr.contents)
				if((researchitem in M.categories)&&M.tier>=tier)
					mats+=M
			if(mats.len == 0)
				usr<<"You don't have the materials for this research!"
				return
			var/choice = input(usr,"What material would you like to use? Note this will cost you [cost] zenni and consume the material.","") as null|anything in mats
			if(!choice)
				usr<<"You cancel your research."
				return
			else
				usr.zenni-=cost
				usr.contents-=choice
				var/obj/items/Plan/outcome=pick(planlist)
				usr<<"You discovered [outcome.name]!"
				usr.contents+=outcome

		Craft()
			set category = null
			set src in oview(1)
			var/skill = 0
			for(var/datum/mastery/m in usr.learnedmasteries)
				if(m.type==masterytype)
					skill=m.level
			var/list/plans = list()
			for(var/obj/items/Plan/P in usr.planlist)
				if(P.masterytype == src.masterytype)
					plans+=P
			if(plans.len==0)
				usr<<"You have no recipes you can make here."
				return
			var/obj/items/Plan/choice = input(usr,"What recipe would you like to craft?","") as null|anything in plans
			if(!choice)
				return
			var/list/check = list()
			check+=choice.materialtypes
			var/cost
			if("Zenni" in check)
				if(usr.zenni < check["Zenni"])
					usr<<"You need [check["Zenni"]] zenni to make this recipe."
					return
				else
					cost = check["Zenni"]
					check-="Zenni"
			var/statnum = check.len
			var/list/options = list()
			for(var/obj/items/Material/M in usr.contents)
				for(var/A in M.categories)
					if((A in choice.materialtypes)&&M.tier>=choice.tier)
						check-=A
						options+=M
			if(check.len)
				usr<<"You are missing materials for this recipe."
				return
			var/list/uselist = list()
			for(var/B in choice.materialtypes)
				var/list/mlist = list()
				for(var/obj/items/Material/N in options)
					if(B in N.categories)
						mlist+=N
				var/choicem = input(usr,"Which [B] would you like to use?","") as null|anything in mlist
				if(!choicem)
					usr<<"Crafting cancelled."
					return
				uselist+=choicem
				options-=choicem
			if(!ispath(choice.createditem,/obj/items/Equipment))//skipping the quality stuff and just making the item
				var/obj/items/made = new choice.createditem
				usr.zenni-=cost
				for(var/obj/U in uselist)
					usr.contents-=U
				if(!usr.trainingmode)
					usr.contents+=made
					if(made.stackable)
						made.amount=choice.quantity
						made.suffix="[made.amount]"
				else
					made.loc = null
				AddExp(usr,masterytype,50*(choice.tier**1.5)*(1+usr.trainingmode/10))
			var/list/statlist = list()
			var/resqual=0
			for(var/obj/items/Material/O in uselist)
				resqual+=O.quality
				for(var/A in O.statvalues)
					statlist[A] = statlist[A]+O.statvalues[A]
			for(var/C in statlist)
				statlist[C] = statlist[C]/statnum
			resqual/=statnum
			resqual=round(min(resqual,skill*7/choice.tier))
			usr.zenni-=cost
			for(var/obj/U in uselist)
				usr.contents-=U
			var/obj/items/Equipment/result = new choice.createditem
			for(var/D in statlist)
				result.itemstats[D]=round(1+(statlist[D]-50)/100,0.01)//this reads the stat associated with the material stats and then modifies it based on the values of the material stats
			result.quality = resqual
			result.rarity = choice.tier
			result.StatUpdate()
			if(resqual>=50)
				result.enchantslots+=1
			if(resqual>=75)
				result.enchantslots+=1
			if(resqual>=100)
				result.enchantslots+=1
			switch(result.quality)
				if(1 to 20)
					result.qualitylabel = "Shoddy"
					//result.name = "<font color=gray>[result.qualitylabel] [result.name]</font>"
				if(21 to 40)
					result.qualitylabel = "Normal"
					//result.name = "<font color=white>[result.qualitylabel] [result.name]</font>"
				if(41 to 60)
					result.qualitylabel = "Quality"
					//result.name = "<font color=silver>[result.qualitylabel] [result.name]</font>"
				if(61 to 80)
					result.qualitylabel = "Superior"
					//result.name = "<font color=teal>[result.qualitylabel] [result.name]</font>"
				if(81 to 99)
					result.qualitylabel = "Exquisite"
					//result.name = "<font color=purple>[result.qualitylabel] [result.name]</font>"
				if(100)
					result.qualitylabel = "Fantastic"
					//result.name = "<font color=red>[result.qualitylabel] [result.name]</font>"
			result.name = "[result.qualitylabel] [result.name]"
			result.suffix = "[Rarity[result.rarity]]"
			result.creator = "[usr.name]"
			result.creatorsig = usr.signiture
			if(!usr.trainingmode)
				usr.contents+=result
			else
				result.loc = null
			AddExp(usr,masterytype,50*(choice.tier**1.5)*(1+result.quality/100)*(1+usr.trainingmode/10))

var/list/matspawnlist = list()

obj/Raw_Material
	name = "Raw Material"
	icon = 'Resources.dmi'
	Bolted = 1
	SaveItem = 0
	fragile = 1
	density = 1
	var/durability = 10
	var
		spawnmat = null//type of material spawned
		matnum = 1//how many materials does this pop out? randomly adjusted on spawn
		masterytype = null//what gathering mastery corresponds to this node?
		masteryname = ""
		masterylevel = 0//what level mastery do you need to gather?
	New()
		..()
		matnum = rand(1,4)
	verb
		Description()
			set category = null
			set src in view(1)
			usr<<"[name]: Requires level [masterylevel] [masteryname] to gather."
	proc
		Gather()
			if(!loc)
				return
			var/list/tlist = list()
			for(var/turf/T in oview(1))
				tlist+=T
			while(matnum)
				if(tlist.len==0)
					break
				var/test = pick(tlist)
				var/obj/A = new spawnmat
				A.loc = test
				matnum--
			emit_Sound('kiplosion.wav')
			src.loc=null

obj/matspawners
	icon=null
	invisibility=101//hidden objects that can't be interacted with
	var
		materialID
		materialspawncount

	proc
		spawnmaterial(var/obj/Raw_Material/M)
			set background = 1
			while(materialspawncount<=6)
				if(prob(2)) materialspawncount--
				for(var/obj/Planets/P in world)
					var/area/currentArea = GetArea()
					if(P.planetType == currentArea.Planet&&P.planetType in PlanetDisableList)
						return
				var/turf/newloc = locate(rand(15,-15)+x,rand(15,-15)+y,z)
				if(newloc&&newloc.proprietor)
				else
					new M(newloc)
				materialspawncount+=1
				sleep(10)

	New()
		..()
		matspawnlist+=src
		while(worldloading)
			sleep(1)
		sleep(10)
		if(materialID)
			spawnmaterial(materialID)