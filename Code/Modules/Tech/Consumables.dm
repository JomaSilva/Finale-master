obj/Creatables
	Blood_Bag
		icon='Item, DNA Extractor.dmi'
		cost=75000
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "A blood bag is a basic container used to store liquid blood indefinitely. Only has positives for Vampires."
		create_type = /obj/items/Blood_Bag

	Nutrient_Pill
		icon='Antivirus.dmi'
		icon_state="red"
		cost=20
		neededtech=3 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "A gross alternative that feeds you at least. Harder to eat than regular food."
		create_type = /obj/items/food/Nutrient_Pill


obj/items
	Blood_Bag
		icon='Item, DNA Extractor.dmi'
		var/hasBlood
		Click()
			if(!hasBlood)
				if(alert(usr,"Give blood to the bloodbag? Will only work if you're a Non-Android and Non-Vampire. Will also take a bit of HP.","","Yes","No")=="Yes")
					if(!usr.Race=="Android"&&!usr.IsAVampire)
						view(usr)<<"[usr] fills [src] with blood."
						hasBlood=1
						suffix = "*Filled*"
						usr.SpreadDamage(10)
						return
			else
				if(alert(usr,"Consume blood in the bloodbag? Will only work if you're a Vampire.","","Yes","No")=="Yes")
					if(usr.IsAVampire)
						view(usr)<<"[usr] drinks from the [src]."
						hasBlood=0
						suffix = ""
						usr.currentNutrition+= 30
						usr.stamina += 10
						usr.SpreadHeal(10)
						return
	food/Nutrient_Pill
		icon='Antivirus.dmi'
		icon_state="red"
		nutrition=5
		stackable=1
		flavor = "Disgusting... but it gets the job done."
		Eat()
			set category=null
			set src in view(1)
			if(!usr.eating&&usr.Race!="Android"&&!usr.Senzu)
				usr<<"[flavor]"
				view(usr)<<"[usr] eats the [name]"
				usr.Hunger=0
				usr.eating=1
				usr.Senzu=1
				usr.currentNutrition+=nutrition
				del(src)
			else
				if(usr.eating)
					usr<<"You need to wait to eat!"