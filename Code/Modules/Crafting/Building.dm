//deeds and building materials

obj/items/Shop
	Shop_Box
		name = "Shop Box"
		desc = "Place items in here to sell to other players."
		icon='Turf3.dmi'
		icon_state="161"
		var
			list/shoplist = list()//associative list of items and costs
			capacity = 30//eventually will be upgradable
			owner = null//ckey of the owner
			money = 0//how much dosh has been made

		verb
			Bolt()
				set category = null
				set src in view(1)
				if(usr.ckey!=owner)
					usr<<"This isn't yours!"
					return
				var/turf/T = locate(src.x,src.y,src.z)
				if(!Bolted&&T.proprietor!=usr.ckey)
					usr<<"You can only bolt this to your own property!"
					return
				else if(!Bolted)
					usr<<"You bolt the [name]."
					Bolted=1
					return
				else if(Bolted&&shoplist.len==0)
					usr<<"You unbolt the [name]."
					Bolted=0
					return
				else if(Bolted)
					usr<<"You must empty the box to unbolt it!"
					return

			Ownership()
				set category = null
				set src in usr
				if(!owner)
					usr<<"You take ownership of this [name]."
					owner = usr.ckey
				else if(owner&&owner==usr.ckey)
					usr<<"You give up ownership of the [name]."
					owner = null
				else if(owner&&owner!=usr.ckey)
					usr<<"Only the owner can change ownership."
					return

		Click()
			if(!Bolted)
				usr<<"This must be bolted to be used!"
				return
			if(usr.ckey==owner)
				var/choice = alert(usr,"Do you want to add items, remove items, or take money?","","Add","Remove","Money")
				switch(choice)
					if("Nothing")
						return
					if("Add")
						placestart
						if(shoplist.len>=30)
							usr<<"This box has no more room!"
							return
						else
							var/list/placelist = list()
							for(var/obj/items/I in usr.contents)
								placelist+=I
							var/obj/item = input(usr,"Which item would you like to set for sale?","") as null|anything in placelist
							if(!item)
								return
							var/cost = input(usr,"How much do you want to sell [item.name] for?","") as null|num
							if(isnull(cost)||cost<0)
								return
							usr<<"You put [item.name] up for sale, for [cost] zenni."
							shoplist[item] = cost
							usr.contents-=item
							goto placestart
					if("Remove")
						removestart
						if(shoplist.len==0)
							usr<<"There are no items to take!"
							return
						else
							var/obj/item = input(usr,"Which item would you like to remove?","") as null|anything in shoplist
							if(!item)
								return
							usr<<"You withdraw [item.name]."
							usr.contents+=item
							shoplist-=item
							goto removestart
					if("Money")
						if(!money)
							usr<<"There is no money to take!"
						else
							usr<<"You withdraw [money] zenni."
							usr.zenni+=money
							money = 0
			else
				buystart
				var/obj/items/purchase = input(usr,"Which item would you like to buy?","") as null|anything in shoplist
				if(!purchase)
					return
				else
					if(usr.zenni<shoplist[purchase])
						usr<<"You can't afford this..."
						goto buystart
					var/choice = alert(usr,"[shoplist[purchase]] Zenni for: [purchase.name]:[purchase.desc]","Buy","Cancel")
					switch(choice)
						if("Cancel")
							goto buystart
						if("Buy")
							usr.zenni-=shoplist[purchase]
							money+=shoplist[purchase]
							usr.contents+=purchase
							shoplist-=purchase

obj/items/Zenni_Minter
	name = "Zenni Mint"
	desc = "Place Gold or Silver in large amounts to recieve some Zenni from them."
	icon='Lab.dmi'
	icon_state="minter"
	verb/Bolt()
		set category = null
		set src in view(1)
		var/turf/T = locate(src.x,src.y,src.z)
		if(!Bolted&&T.proprietor!=usr.ckey)
			usr<<"You can only bolt this to your own property!"
			return
		else if(!Bolted)
			usr<<"You bolt the [name]."
			Bolted=1
			return
		else if(Bolted)
			usr<<"You unbolt the [name]."
			Bolted=0
			return
		else if(Bolted)
			usr<<"You must empty the box to unbolt it!"
			return
	Click()
		if(!Bolted)
			usr<<"This must be bolted to be used!"
			return
		var/list/itemlist = list()
		var/handilevel = 0
		for(var/datum/mastery/Crafting/Handicraft/L in usr.learnedmasteries)
			handilevel = L.level
			break
		if(handilevel < 25)
			usr << "You need a Handicraft level of 25 or higher to use this."
			return
		bcktohre
		itemlist = list()
		for(var/obj/items/Material/Ore/A in usr.contents)
			if(istype(A,/obj/items/Material/Ore/Gold_Ore)||istype(A,/obj/items/Material/Ore/Silver_Ore))
				itemlist+= A
		if(itemlist.len)
			var/obj/items/Material/Ore/nB = input(usr,"What Ore do you want to use? Zenni Formula: 100 * choice.tier * choice.quality. A gold material will multiply any earnings by your Handicraft level.")
			var/qual = 100 * nB.tier * nB.quality * handilevel
			nB.deleteMe()
			var/obj/Zenni/A=new/obj/Zenni
			A.loc=locate(usr.x,usr.y,usr.z)
			A.zenni=qual
			A.name="[num2text(A.zenni,20)] zenni"
			step(A,usr.dir)
			view(usr)<<"<font size=1><font color=teal>[usr] drops [num2text(zenni,20)] zenni."
			if(A.zenni<1000) A.icon_state="Zenni1"
			else if(A.zenni<10000) A.icon_state="Zenni2"
			else if(A.zenni<99999) A.icon_state="Zenni3"
			else if(A.zenni<100000) A.icon_state="Zenni4"
			AddExp(usr,/datum/mastery/Crafting/Handicraft,qual)
			usr<<"You have successfully created [qual] zenni!"
			goto bcktohre

//quality
obj/items/Plan/Building
	masterytype = /datum/mastery/Crafting/Handicraft
	masteryname = "Handicraft"
	Shop_Box
		name = "Shop Box Plan"
		desc = "Allows you to sell items."
		materialtypes = list("Wood","Ore","Wood")
		createditem = /obj/items/Shop/Shop_Box
		createdname = "Shop Box"
		requiredlevel = 1
		tier = 1
		canresearch = 1

	Zenni_Mint
		name = "Zenni Minter"
		desc = "Allows you to create Zenni from Silver or Gold. This process is not easy, and it requires large amounts of ores. Requires a Handicraft mastery of 25 or greater."
		materialtypes = list("Wood","Ore","Wood")
		createditem = /obj/items/Zenni_Minter
		createdname = "Shop Box"
		requiredlevel = 25
		tier = 1
		canresearch = 1