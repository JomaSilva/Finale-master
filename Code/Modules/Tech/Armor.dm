obj/Creatables
	Armor
		icon='Armor_Elite.dmi'
		icon_state=""
		cost=1000
		neededtech=10 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Armor is a protective layer that helps reduce incoming damage. Despite this, it's boosts start becoming minor."
		create_type = /obj/items/Armor
obj/items/Armor
	icon='Clothes_Armor1.dmi'
	NotSavable=1
	stackable = 0
	var/armorincrease=2
	var/armordecrease=2
	verb/Description()
		set category=null
		usr<<"This armor increases endurance to [armorincrease*100]%, and reduces speed to [100/armordecrease]%"
	verb/Equip()
		set category=null
		set src in usr
		for(var/obj/items/Armor/A in usr.contents) if(A.equipped&&A!=src)
			usr<<"You already have armor equipped."
			return
		if(!equipped)
			equipped=1
			suffix="*Equipped*"
			usr.updateOverlay(/obj/overlay/clothes/Armor,icon)
			usr<<"You put on the [src]."
			usr.physdefBuff+=armorincrease
			usr.speedBuff-=armordecrease
		else
			equipped=0
			suffix=""
			usr.removeOverlay(/obj/overlay/clothes/Armor,icon)
			usr<<"You take off the [src]."
			usr.physdefBuff-=armorincrease
			usr.speedBuff+=armordecrease
	verb/Upgrade()
		set category=null
		set src in  usr
		if(!equipped)
			if(usr.KO) return
			var/cost=0
			var/list/Choices=new/list
			Choices.Add("Cancel")
			if(usr.zenni>=45000&&armorincrease!=2.25) Choices.Add("Increased Protection (45000z)")
			if(usr.zenni>=50000&&armordecrease!=1.25) Choices.Add("Microfiber (50000z)")
			var/A=input("Upgrade what?") in Choices
			if(A=="Cancel") return
			if(A=="Microfiber (50000z)")
				cost=50000
				if(input(usr,"The microfiber cloth upgrade will cause the speed decrease to be minimized to 80% instead of 50%.","","Sure") in list("Sure","Naw") == "Naw") return
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Armor upgraded"
				armordecrease=1.25
			if(A=="Increased Protection (45000z)")
				cost=45000
				if(input(usr,"The amount of protection the armor gives you is increased a bit. (200% to 225%)","","Sure") in list("Sure","Naw") == "Naw") return
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Armor upgraded"
				armorincrease=1.25
		else usr<<"You can't change armor stats while it's equipped!"
	verb/Icon()
		set category = null
		set src in usr
		if(!equipped)
			switch(input(usr,"Default or custom?","","default") in list("default","custom","cancel"))
				if("custom")
					icon = input(usr,"Input armor icon.","",'Clothes_Armor1.dmi') as icon
				if("default")
					icon = 'Clothes_Armor1.dmi'
					var/list/Styles=new/list
					if(usr.techskill>3)
						Styles.Add("Plain")
						Styles.Add("Single Pad")
					if(usr.techskill>4)
						Styles.Add("Rit")
						Styles.Add("Full Rit")
					if(usr.techskill>5) Styles.Add("Elite Armor")
					if(usr.techskill>10)
						Styles.Add("Yardrat Style")
						Styles.Add("Blue Style")
						Styles.Add("Bardock Style")
						Styles.Add("Raditz Style")
						Styles.Add("Gin Style")
						Styles.Add("Plating Style")
						Styles.Add("Turles Style")
						Styles.Add("Azure Style")
						Styles.Add("Nappa Style")
					var/Z=input("What style?") in Styles
					if(src)
						switch(Z)
							if("Plain")
								icon='Clothes_Armor2.dmi'
							if("Single Pad")
								icon='Clothes_Armor1.dmi'
							if("Rit")
								icon='Armor_Rit2.dmi'
							if("Full Rit")
								icon='Armor_Rit1.dmi'
							if("Elite Armor")
								icon='Armor_Elite.dmi'
							if("Yardrat Style")
								icon='Armor Yardrat.dmi'
							if("Blue Style")
								icon='BlueArmor.dmi'
							if("Bardock Style")
								icon='Armor Bardock.dmi'
							if("Raditz Style")
								icon='RaditzArmorTobiUchiha.dmi'
							if("Gin Style")
								icon='GinsDynastyArmorRed.dmi'
							if("Plating Style")
								icon='Armor 8.dmi'
							if("Turles Style")
								icon='TurlesArmorTobiUchiha.dmi'
							if("Nappa Style")
								icon='Nappa Armor.dmi'
							if("Azure Style")
								icon='Armor, Azure.dmi'
		else usr<<"You can't change armor appearance while it's equipped! (to avoid Overlay issues.)"

obj/overlay/clothes/Armor
	ID=332
	//unique ID.
	//Nothing else is needed. Icon and etc are set manually.