obj/Creatables
	Chalk
		icon='magic_items.dmi'
		icon_state = "chalk"
		cost=10
		neededtech=1 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Chalk is a incredibly useful magic tool that allows you to transmute catalysts into various reactions. Limited uses."
		create_type = /obj/items/Chalk
		Description()
			set category =null
			if(usr.Emagiskill <= 1) usr<<"Chalk allows you to create funny little drawings on the ground."
			else usr<<"Chalk is a incredibly useful magic tool that allows you to transmute catalysts into various reactions. Limited uses."
	Wand
		icon='magic_items.dmi'
		icon_state = "wand"
		cost=1000
		neededtech=1 //Deletes itself from contents if the usr doesnt have the needed tech
		neededmag = 2.5
		desc = "A wand is a magical tool that allows someone to control the output of their spells."
		create_type = /obj/items/Equipment/Weapon/Staff/Wand
	Staff
		icon='magic_items.dmi'
		icon_state = "staff"
		cost=1000
		neededtech=1 //Deletes itself from contents if the usr doesnt have the needed tech
		neededmag = 3
		create_type = /obj/items/Equipment/Weapon/Staff/Magic_Staff
		desc = "A staff is a magical tool that augments and helps control the output of spells."

	Predictor
		icon='magic_items.dmi'
		icon_state = "checker"
		cost=1000
		neededtech=1 //Deletes itself from contents if the usr doesnt have the needed tech
		neededmag = 2
		create_type = /obj/items/Predictor
		desc = "Limited uses, based on magic power. Allows you to check the ritual cost of a specific ritual and it's energy amount. Will let you also destroy a ritual if it's just about to start up."
	Magic_Sifter
		name="Magic Sifter"
		icon = 'magic_circles.dmi'
		icon_state = "shield-cult"
		cost=100
		neededtech=3
		neededmag=1.01
		SaveItem=0
		create_type = /obj/Magic_Sifter
		desc = "Magic Sifters will give you ingredients to use in rituals."
	
	Ingredient_Crystal
		name="Ingredient Crystal"
		icon = 'magic_items.dmi'
		icon_state = "blue_crystal"
		cost=5000
		neededtech=10
		neededmag=2
		SaveItem=0
		create_type = /obj/Magic_Sifter
		desc = "Ingredient Crystals will collect all ingredients in a 10 tile radius, and store them efficiently inside them. But only while bolted"

	Ingredient_Bag
		name="Ingredient Bag"
		icon = 'ingrbag.dmi'
		icon_state = "ingred_satchel"
		cost=5000
		neededtech=5
		neededmag=1.01
		SaveItem=0
		create_type = /obj/items/Ingredient_Bag
		desc = "Ingredient Bags are like ingredient crystals, except without the limitless storage (up to 20 items), and portable. However, if you retrieve an ingredient over a ritual, it will automatically add that ingredient to the ritual."

obj
	items
		Chalk
			icon='magic_items.dmi'
			icon_state = "chalk"
			SaveItem = 1
			stackable=0
			var/uses = 10
			verb/Draw()
				set category=null
				set src in usr
				if(usr.Emagiskill <= 1)
					view(usr)<<"[usr] scrawls a funny little drawing on the ground. Funny [usr]. Haha."
					var/obj/a = new(usr.loc)
					a.SaveItem = 0
					a.IsntAItem = 1
					a.icon = 'magic_circles.dmi'
					a.icon_state = pick("golem","golem2")
					uses-=1
				else
					var/trued
					switch(input(usr,"Pick a ritual to draw. If you don't know any ritual types, Freeform is the type to use.","Ritual Types","Cancel") in list("Cancel","Destruction","Manipulation","Dimensional","Freeform"))
						if("Cancel") return
						if("Destruction")trued= usr.draw_destruction_rit_index()
						if("Manipulation")trued= usr.draw_manipulation_rit_index()
						if("Dimensional")trued= usr.draw_dimensional_rit_index()
						if("Freeform")
							var/obj/Ritual/r = new/obj/Ritual(usr.loc)
							trued=1
							switch(input(usr,"Custom icon? It'll use a blank state and a \"activated\" state.","","No") in list("No","Yes"))
								if("Yes")
									r.icon = input(usr) as icon
									r.customic = TRUE
								else
									r.customic = FALSE
									icon_state = pick("main1","main2","main3","main4","main5","main6")
					if(trued)
						view(usr)<<"[usr] draws a complex drawing on the ground."
						uses-=1
		Predictor
			icon='magic_items.dmi'
			icon_state = "checker"
			SaveItem = 1
			stackable=0
			var/uses = 10
			verb/Use()
				set category=null
				set src in usr
				if(usr.Emagiskill <= 1)
					view(usr)<<"[usr] taps the ground. Funny [usr]. Haha."
					uses-=1
				else
					//var/trued
					var/obj/Ritual/targ_rit = null
					for(var/obj/Ritual/nR in usr.loc)
						if(nR)
							targ_rit = nR
							break
					if(targ_rit)
						var/costs
						var/energ
						energ = targ_rit.Magic
						costs = targ_rit.ritual_cost
						bckbeg
						switch(input(usr,"This ritual has (estimate) [energ] magic energy. Ritual Cost (estimate): [costs]","Predictor: [targ_rit]") in list("Destroy","Recalculate Cost","Recalculate Energy","Cancel"))
							if("Cancel")
								return
							if("Destroy")
								if(!targ_rit.is_going || targ_rit.cancelable) del(targ_rit)
								if(prob(100-usr.Emagiskill*5)) uses-=1
								return
							if("Recalculate Cost")
								costs = targ_rit.check_cost()
								if(prob(100-usr.Emagiskill*15)) uses-=1
								goto bckbeg
							if("Recalculate Energy")
								energ = targ_rit.check_energy(usr)
								if(prob(100-usr.Emagiskill*15)) uses-=1
								goto bckbeg
		Ingredient_Crystal
			name="Ingredient Crystal"
			icon = 'magic_items.dmi'
			icon_state = "blue_crystal"
			SaveItem = 1
			cantblueprint=0
			verb/Bolt()
				set category=null
				set src in oview(1)
				if(x&&y&&z&&!Bolted)
					switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
						if("Yes")
							view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
							Bolted=1
							boltersig=usr.signature
				else if(Bolted&&boltersig==usr.signature)
					switch(input("Unbolt?","",text) in list("Yes","No",))
						if("Yes")
							view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
							Bolted=0
			var/list/ingredient_list = list()
			verb/Store_All()
				set category = null
				set src in oview(1)
				if(Bolted)
					for(var/obj/items/Material/A in view(10))
						ingredient_list[A.type] += 1
						A.deleteMe()
				else usr<<"Needs to be bolted"
			verb/Retrieve()
				set category = null
				set src in oview(1)
				if(Bolted)
					goback
					var/list/test_list = ingredient_list
					test_list += "Cancel"
					var/input = input(usr,"Which ingredient?") in test_list
					if(input != "Cancel")
						ingredient_list[input] -= 1
						new input(loc)
						if(ingredient_list[input] == 0)
							ingredient_list -= input
						goto goback
				else usr<<"Needs to be bolted"
		Ingredient_Bag
			name="Ingredient Bag"
			icon = 'ingrbag.dmi'
			icon_state = "ingred_satchel"
			SaveItem = 1
			cantblueprint=0
			var/max_items = 20
			var/cur_items = 0
			var/list/ingredient_list = list()
			verb/Store_All()
				set category = null
				set src in oview(1)
				for(var/obj/items/Material/A in view(3))
					if(max_items > cur_items)
						ingredient_list[A.type] += 1
						cur_items++
						A.deleteMe()
			verb/Retrieve()
				set category = null
				set src in oview(1)
				goback
				var/list/test_list = ingredient_list
				test_list += "Cancel"
				var/input = input(usr,"Which ingredient? If you're over a ritual, it will automatically add it to the ritual.") in test_list
				if(input != "Cancel")
					ingredient_list[input] -= 1
					new input(loc)
					if(ingredient_list[input] == 0)
						ingredient_list -= input
					for(var/obj/Ritual/nR in view(0))
						nR.add_components(input)
						break
					goto goback
					


		Equipment/Weapon/Staff/Wand
			name="Magic Wand"
			icon = 'magic_items.dmi'
			icon_state = "wand"
			desc="A short, carved rod used for fighting with magic spells. Can control the output of spells."
			rarity=4
			damage=0.75
			accuracy=4
			speed=0.95
			verb/Mana_Control()
				set src in usr
				if(equipped) if(usr.Rmagiskill >= 2)
					usr.mana_setting = round(max(min(input(usr,"What percent of mana should you use for every spell? (1 to 100)") as num,100),0))
					usr.mana_setting /= 100
			unequip(mob/M)
				..()
				M.mana_setting = 0.08
		
		Equipment/Weapon/Staff/Magic_Staff
			name="Staff"
			icon = 'magic_items.dmi'
			icon_state = "staff"
			desc="A piece of carved wood, used for fighting with magic spells. Can control and augment spells."
			rarity=5
			damage=0.75
			accuracy=2
			speed=0.95
			verb/Mana_Control()
				set src in usr
				if(equipped)
					if(usr.Rmagiskill >= 2)
						usr.mana_setting = round(max(min(input(usr,"What percent of mana should you use for every spell? (1 to 100)") as num,100),0))
						usr.mana_setting /= 100
			equip(mob/M)
				..()
				M.magiBuff++
			unequip(mob/M)
				..()
				M.mana_setting = 0.08
				M.magiBuff--
mob/var
	known_ritual_de_types = list("Cancel")
	known_ritual_ma_types = list("Cancel")
	known_ritual_dm_types = list("Cancel")

mob/proc
	draw_destruction_rit_index()
		var/type_to_draw = input(usr,"Which type?","Ritual Drawing") in known_ritual_de_types
		if(type_to_draw != "Cancel")
			new type_to_draw(usr.loc)
			return TRUE
	draw_manipulation_rit_index()
		var/type_to_draw = input(usr,"Which type?","Ritual Drawing") in known_ritual_ma_types
		if(type_to_draw != "Cancel")
			new type_to_draw(usr.loc)
			return TRUE
	draw_dimensional_rit_index()
		var/type_to_draw = input(usr,"Which type?","Ritual Drawing") in known_ritual_dm_types
		if(type_to_draw != "Cancel")
			new type_to_draw(usr.loc)
			return TRUE

obj/Magic_Sifter
	density=1
	SaveItem=1
	cantblueprint=0
	icon = 'magic_circles.dmi'
	icon_state = "shield-cult"
	var/DrillRate=1
	var/DrillSpeed=1
	Magic = 100
	var/Resources=0
	var/bonus=0
	var/bonusmult=1
	var/death_timer = 0
	New()
		set background = 1
		..()
		while(src)
			if(DrillRate>0)
				Resources+=0.15*DrillRate*GlobalResourceGain * bonusmult
			if(DrillRate>5)
				DrillRate=5
			if(DrillSpeed>5)
				DrillSpeed=5
			if(Magic >= 100 * DrillSpeed)
				Magic -= 2 * (Magic/100)
			if(Resources>DrillRate)
				Resources = DrillRate
				bonus=1
				bonusmult=1
			else
				Magic -= 1
				if(Magic <= 0) death_timer++
				if(death_timer >= 3) deleteMe()
				bonus=0

			sleep(500/DrillSpeed)
	Del()
		if(Resources)

			view(src)<<"<font size=1><font color=teal>[src] blows and drops ingredients!"
			while(round(Resources))
				Resources--
				if(prob(50)) return_random_ingredient()
				sleep(1)
			Resources = 0
		..()
	Click()
		if(Resources>0)
			Resources = min(5,Resources)
			usr<<"<font color=yellow><b>You withdraw [FullNum(Resources)] ingredients. ([FullNum(DrillSpeed+1)] Speed & [FullNum(DrillRate+1)] Rate) ([Magic] mana remaining.)"
			while(round(Resources))
				Resources--
				return_random_ingredient()
				sleep(1)
			Resources=0
			if(bonus)
				usr<<"<font color=yellow><b> Your sifter has tried to withdraw past the cap, 250k. You have bonus sifter gains for the next ten cycles as long as you don't continue to withdraw."
				bonusmult = 2
			else
				usr<<"<font color=yellow><b> Bonus ended."
				bonusmult = 1
		else
			usr<<"<font color=yellow><b>There are no resources left at this moment."
	verb/Scuff()
		set src in oview(1)
		set category=null
		del(src)
	verb/Recharge()
		set src in oview(1)
		set category=null
		var/amount = round(max(0,min(usr.Magic,input(usr,"Input however much magic into this sifter. It'll take one mana per [50/DrillSpeed] second(s). It's max cap for mana (before it starts leaking it) is [100*DrillSpeed] magic.") as num)))
		Magic += amount
		usr.Magic -= amount
		view(src)<<"<font color=blue size=2>[src]: [amount] mana added.</font>"
	verb/Upgrade()
		set src in oview(1)
		set category=null
		var/list/Choices=new/list
		if(DrillSpeed<5) Choices.Add("Speed")
		if(DrillRate<5) Choices.Add("Rate")
		Choices.Add("Cancel")
		var/A=input("Upgrade what?") in Choices
		if(A=="Cancel") return
		if(A=="Rate")
			var/Opt=input("How much Magic to add?") as num
			Opt = min(max(round(Opt),0),50000)
			if(usr.Magic<Opt)
				usr<<"You do not have enough Magic ([FullNum(Opt)]z)"
				return
			DrillRate+=(Opt/1000)*usr.Emagiskill
			usr.Magic-=Opt
			usr<<"Rate increased ([FullNum(DrillRate+1)]z)."
		if(A=="Speed")
			var/Opt=input("How much Magic to add?") as num
			Opt = min(max(round(Opt),0),50000)
			if(usr.Magic<Opt)
				usr<<"You do not have enough Magic ([FullNum(Opt)]z)"
				return
			DrillSpeed+=(Opt/1000)*usr.Emagiskill
			usr.Magic-=Opt
			usr<<"Speed increased ([FullNum(DrillSpeed+1)]x)."
