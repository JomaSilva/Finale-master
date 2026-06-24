//list of accessories under the new equipment system

obj/items/Equipment/Accessory
	icon='Holy Pendant.dmi'

	Backpack
		name="Backpack"
		desc="A pack that goes on your back. Gives extra inventory space."
		icon='Clothes Backpack.dmi'
		equip(var/mob/M)
			..()
			M.inven_max+=10

		unequip(var/mob/M)
			..()
			M.inven_max-=10


	Bagohlding
		name="Bag of Holding"
		desc="A bag of holding gives you a bit more inventory space and allows you to put any amount of items inside of it."
		icon='Clothes Backpack.dmi'
		SaveItem=1
		var/list/pocket_dim_holding = list()
		verb/Manipulate()
			set category = null
			set src in view(1)
			qustin
			switch(input(usr,"Put or take an item from storage?") in list("Cancel","Put","Take"))
				if("Cancel") return
				if("Put")
					var/list/item_list = list()
					for(var/obj/items/a in usr)
						if(!a.equipped)
							item_list += a
					item_list += "Cancel"
					var/choice = input(usr,"Which item?","Items") in item_list
					if(choice!="Cancel")
						var/obj/na = choice
						pocket_dim_holding+=na
						na.Move(locate(1+rand(1,5),1+rand(1,5),31))
				if("Take")
					var/list/item_list = list()
					item_list = pocket_dim_holding
					item_list += "Cancel"
					var/choice = input(usr,"Which item?","Items") in item_list
					if(choice!="Cancel")
						var/obj/na = choice
						pocket_dim_holding-=na
						na.Move(usr)
			goto qustin
		equip(var/mob/M)
			..()
			M.inven_max+=10

		unequip(var/mob/M)
			..()
			M.inven_max-=10

	Stone_Mask
		name="Stone Mask"
		desc="A bizarre mask from ancient times. Upon contact with blood, stone tendrils erupt from the back of it."
		icon='stonemask.dmi'
		rarity=7
		value=8101987
	Majoras_Mask
		name="Majora's Mask"