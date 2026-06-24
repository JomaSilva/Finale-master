//We minecraft now


obj/Creatables
	Crafting_Bench
		icon = 'craftingbench.png'
		cost=500
		neededtech=4
		desc = "A crafting bench lets you make various items. It also lets you make clothes manually out of Zenni. (This is the only way to make custom clothes!)"
		create_type = /obj/items/Crafting_Bench
obj
	items
		Crafting_Bench
			icon = 'craftingbench.png'
			desc = "A crafting bench lets you make various items. It also lets you make clothes manually out of Zenni. (This is the only way to make custom clothes!)"
			name = "Crafting Bench"
			SaveItem=1
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
			verb/Craft()
				set category=null
				set src in view(1)
				if(!Bolted)
					usr << "You need to bolt [name] before you can use it!"
					return
				switch(input(usr,"Which function of the crafting bench will you use?","","Cancel") in list("Clothes","Items","Cancel"))
					if("Items")
						switch(input(usr,"Craft which item?","","Cancel") in list("Comb","Eye Dye","Loom","Trash Bin","Research Station","Cancel"))
							if("Comb")
								if(usr.zenni>=100)
									usr.zenni-=100
									var/obj/A=new/obj/items/Comb(locate(usr.x,usr.y,usr.z))
									A.techcost+=100
								else usr<<"You dont have enough money"
							if("Eye Dye")
								if(usr.zenni>=100)
									usr.zenni-=100
									var/obj/A=new/obj/items/Eye_Dye(locate(usr.x,usr.y,usr.z))
									A.techcost+=100
								else usr<<"You dont have enough money"
							if("Loom")
								if(usr.zenni>=100)
									usr.zenni-=100
									var/obj/A=new/obj/items/Loom(locate(usr.x,usr.y,usr.z))
									A.techcost+=100
								else usr<<"You dont have enough money"
							if("Trash Bin")
								if(usr.zenni>=100)
									usr.zenni-=100
									var/obj/A=new/obj/items/Trash_Bin(locate(usr.x,usr.y,usr.z))
									A.techcost+=100
								else usr<<"You dont have enough money"
					if("Clothes")
						var/area/hopefulArea = GetArea()
						if(!isarea(hopefulArea))
							hopefulArea = hopefulArea.GetArea()
						else if(isnull(hopefulArea)) return

						usr.ClothingChoice()
		Comb
			icon = 'Item - Comb.dmi'
			name = "Comb"
			desc = "A more lorefriendly way to change your hair."
			verb/Change_Hair()
				set category=null
				set src in view(1)
				usr.Hair(1)
		Eye_Dye
			icon = 'Item, Needle.dmi'
			name = "Eye Dye"
			desc = "Change the color of your own eyeballs. We Eyeball Z now."
			verb/Change_Eye_Color()
				set category=null
				set src in view(1)
				usr.overlayList-='Eyes_Black.dmi'
				usr.overlaychanged=1
				usr.Eyes()
				usr.overlaychanged=1
		Loom
			icon = 'loom.png'
			name = "Loom"
			desc = "Make your own clothing! Make sure you have a icon on hand or else it'll just look like a tank top! You can't change the icon of tank tops."
			SaveItem=1
			verb/Make_Clothing()
				set category=null
				set src in view(1)
				var/obj/items/clothes/A = new
				A.desc = "A piece of clothing."
				A.name = "clothing"
				A.icon = input(usr,"Pick some clothing.","Pick a icon.",'Clothes_TankTop.dmi') as icon
				A.name = input(usr,"Name?","Pick a name.","clothing") as text
				A.loc = locate(usr.x,usr.y,usr.z)

		Trash_Bin
			icon = 'trashbin.png'
			name = "Trash"
			desc = "Destroy items. Cannot destroy anything that isn't a item or module."
			SaveItem=1
			verb/Destroy_Item()
				set category = null
				set src in view(1)
				var/list/trashList = list()
				for(var/obj/items/A in usr.contents)
					if(A.equipped|A.suffix=="*Equipped*")
						continue
					else
						trashList += A
				for(var/obj/Modules/A in usr.contents)
					if(A.isequipped|A.suffix=="*Equipped*")
						continue
					else
						trashList += A
				var/obj/choice = input(usr,"Select a item to destroy. You will never be able to get this specific item back!","",null) as null|anything in trashList
				if(isobj(choice))
					view(usr)<<"[usr] threw the [choice] into the trash!"
					del(choice)

turf/decor
	Fire
		name="fire"
		icon='Turf 57.dmi'
		icon_state="82"
		density=1
		fire=1