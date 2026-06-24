obj/Creatables
	/*Sword
		icon='Sword_Trunks.dmi'
		icon_state="base"
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Sword(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area."
	Axe
		icon='Axe.dmi'
		icon_state="Attack"
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Axe(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area. Axes can chop trees down."
	Staff
		icon='Roshi Stick.dmi'
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Staff(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area."

	Spear
		icon='spear.dmi'
		icon_state="Item"
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Spear(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area."
	Club
		icon='Club.dmi'
		icon_state="Attack"
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Club(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area."
	Hammer
		icon='Hammer.dmi'
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Hammer(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area."

	Cross
		icon='Item Cross.dmi'
		icon_state = "Item"
		cost=1000
		neededtech=11 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/items/Weapons/Cross(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost

			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A weapon will commonly increase your attack while decreasing a stat in another area."*/
obj/var/weapon = 0
obj/items/Weapons
	icon='Sword_Trunks.dmi'
	desc="Weapons can bring to the table a lot of unique buffs that generally increase your physical attack at the price of some speed and technique."
	IsntAItem=1
	weapon=1
	stackable=0
	var/Power = 1
	var/Speed = 1
	var/weaponattackflavors = list("slices")
	var/weaponcounterflavors = list("parries")
	verb/Icon()
		set category = null
		set src in usr
		if(!suffix)
			switch(input(usr,"Default or custom?","","default") in list("default","custom","cancel"))
				if("custom")
					icon = input(usr,"Input weapon icon.","",'Sword_Trunks.dmi') as icon
				if("default")
					icon = 'Sword_Trunks.dmi'
		else usr<<"You can't change weapon appearance while it's equipped! (to avoid Overlay issues.)"
	verb/Equip()
		set category=null
		set src in usr
		for(var/obj/A in usr.contents) if(A.weapon&&A!=src&&(A.suffix=="*Equipped*"||A.equipped))
			usr<<"You already have a weapon equipped."
			return FALSE
		if(usr.KiWeaponOn)
			usr<<"You already have a weapon equipped."
			return FALSE
		if(!suffix)
			suffix="*Equipped*"
			usr.overlayList+=icon
			usr.overlaychanged=1
			usr.SwordEquipped=1
			usr.weaponattackflavors = weaponattackflavors
			usr.weaponcounterflavors = weaponcounterflavors
			usr<<"You put on the [src]."
			equipped=1
		else if(suffix)
			suffix=null
			usr.overlayList-=icon
			usr.overlaychanged=1
			usr.SwordEquipped=0
			usr.weaponattackflavors = initial(usr.weaponattackflavors)
			usr.weaponcounterflavors = initial(usr.weaponcounterflavors)
			usr<<"You take off the [src]."
			equipped=0
		return TRUE
	verb/Flavor()
		set category=null
		set src in usr
		usr << "You will need to re-equip your weapon in order to update the flavor text."
		switch(input(usr,"Which flavor?","","Attack") in list("Attack","Counter","Cancel"))
			if("Attack")
				switch(input(usr,"Remove or Add?","","Add") in list("Remove","Add","Cancel"))
					if("Add")
						weaponattackflavors += input(usr,"Type a flavor. It'll appear as \"[usr]'flavor''mob'!\"") as text
					if("Remove")
						var/list/flavors = list()
						for(var/S in weaponattackflavors)
							flavors += S
						flavors += "Cancel"
						var/choice = input(usr,"Choose a flavor to remove.") as null|anything in flavors
						if(istext(choice))
							weaponattackflavors -= choice
			if("Counter")
				switch(input(usr,"Remove or Add?","","Add") in list("Remove","Add","Cancel"))
					if("Add")
						weaponcounterflavors += input(usr,"Type a flavor. It'll appear as \"[usr]'flavor''mob'!\"") as text
					if("Remove")
						var/list/flavors = list()
						for(var/S in weaponcounterflavors)
							flavors += S
						flavors += "Cancel"
						var/choice = input(usr,"Choose a flavor to remove.") as null|anything in flavors
						if(istext(choice))
							weaponcounterflavors -= choice

obj/items/Weapons
	Sword
		icon='Sword_Trunks.dmi'
		desc="Swords increase your raw physical offense, but decrease your technique and a bit of speed."
		Power=1.3
		Speed=1.2
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod*=Power
				usr.techniqueMod/=Speed
				usr.speedMod/=Speed
			else
				usr.physoffMod/=Power
				usr.techniqueMod*=Speed
				usr.speedMod*=Speed

	Axe
		icon='Axe.dmi'
		desc="Axes increase your raw physical offense, but decrease a bunch of technique. Also destroys trees!"
		Power=1.35
		Speed=1.3
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod*=Power
				usr.techniqueMod/=Speed
			else
				usr.physoffMod/=Power
				usr.techniqueMod*=Speed
		verb/Chop_Tree()
			set category=null
			set src in usr
			var/list/treelist = list()
			for(var/obj/Trees/O in view())
				treelist += O
			treelist += "cancel"
			var/choice = input(usr,"Destroy which tree?","","cancel") as null|anything in treelist
			if(isobj(choice))
				del(choice)
			else return

	Staff
		icon='Roshi Stick.dmi'
		desc="Staves increase your raw technique, but decrease a bit of offense."
		Power=1.3
		Speed=1.2
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod/=Power
				usr.techniqueMod*=Speed
			else
				usr.physoffMod*=Power
				usr.techniqueMod/=Speed

	Spear
		icon='spear.dmi'
		desc="Spears increase your raw offense, but decrease a bit of speed."
		Power=1.35
		Speed=1.3
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod*=Power
				usr.speedMod/=Speed
			else
				usr.physoffMod/=Power
				usr.speedMod*=Speed

	Club
		icon='Club.dmi'
		desc="Clubs increase your raw offense, but decrease a bit of speed and technique. Swords do the same, but this is a bit more apparent."
		Power=1.4
		Speed=1.3
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod*=Power
				usr.techniqueMod/=Speed
				usr.speedMod/=Speed
			else
				usr.physoffMod/=Power
				usr.techniqueMod*=Speed
				usr.speedMod*=Speed
	Hammer
		icon='Hammer.dmi'
		desc="Hammers increase your raw offense, but decrease technique."
		Power=1.35
		Speed=1.25
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod*=Power
				usr.techniqueMod/=Speed
			else
				usr.physoffMod/=Power
				usr.techniqueMod*=Speed
	Cross
		icon='Item Cross.dmi'
		desc="Crosses increase your raw offense a little bit, and subtracts a little speed. Effective against Werewolves and Vampires."
		Power=1.1
		Speed=1.1
		IsntAItem=0
		Equip()
			set category=null
			set src in usr
			if(!(..())) return
			if(equipped)
				usr.physoffMod*=Power
				usr.speedMod/=Speed
				usr.attackWithCross = 1
			else
				usr.physoffMod/=Power
				usr.speedMod*=Speed
				usr.attackWithCross = 0