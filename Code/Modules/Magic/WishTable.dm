//To add wishes:
//Find a True Wish Power value from below, and stick the new wish option in the same way you see the other ones.
//Then, add a new if("") statement below the switch(input("Make your wish.","", text) in WishList)
//Add the needed code.
//If you need a wish to cancel because of null values, etc, put in 'break' to immediately exit the while() statement, ending the wish proc and letting the user choose again.
//Keep in mind wishes are just the pure energy of Ki being flexibly used by the Dragon.
obj/DB
	proc/GenerateWishList(var/mob/usr)
		var/wishscount = Wishs - WishCount
		var/TrueWishPower = log(max(WishPower/Wishs,1))^2 + 1
		var/list/WishList = list()
		while(wishscount&&!CompletelyInert)
			var/DidWish = 1
			wishscount-=1
			WishList+="Nothing (Waste Wish)"
			WishList+="Panties"
			WishList+="Cancel"
			if(TrueWishPower>=2)
				WishList+="Cash"
				WishList+="Milestones"
				WishList+="Technology"
			if(TrueWishPower>=3)
				WishList+="Revive"
				WishList+="Youth"
				WishList+="Power"
				WishList+="Intelligence"
			if(TrueWishPower>=4)
				WishList+="Make Somebody Else Young"
				WishList+="Give Soul"
				WishList+="Gain Magic"
			if(TrueWishPower>=5)
				WishList+="Heal Planet"
			if(TrueWishPower>=6)
				if(!TurnOffAscension||usr.AscensionAllowed) if(usr.genome.race_percent("Saiyan") >= 25) WishList+="Super Saiyan"
			if(TrueWishPower>=7&&Wishs<=2)
				WishList+="Revive-All"
				WishList+="Kill Somebody"
			if(TrueWishPower>=10)
				WishList+="Immortality"
			var/chosenwish = input("Make your wish.", "", text) in WishList
			switch(chosenwish)
				if("Nothing (Waste Wish)")
					to_chat(view(), "[usr] wishes for nothing!")
					WishPower*=1.1
					to_chat(usr, "You wish for nothing!")
				if("Cancel")
					to_chat(view(), "[usr] cancels [usr]'s wish.")
					break
				else
					var/list/nl = Wish(chosenwish,usr,Earth_Guardian,WishPower)
					if(nl.len)
						WishPower *= max(nl[1],1)
						if(nl[2] == TRUE) break
					else break

			WishCount+=DidWish
proc/Wish(var/wish,mob/originator,E_G,TrueWishPower)
	var/text = "Yes"
	var/wishpower = 1
	switch(wish)
		if("Power")
			to_chat(view(originator), "[originator] wishes for power!")
			if(E_G!=originator.key)
				originator.BP+=originator.capcheck(originator.relBPmax/4)
				//originator.BPMod+=0.2 //slight mod increase!
			else
				to_chat(view(originator), "[originator]'s wish fails because they are the guardian.")
				to_chat(originator, "You cannot increase your power with the Dragon Balls, because the Dragon Balls use your power to increase the power of others, and your power cannot increase your own power.")
				return list(wishpower,TRUE)
		if("Revive")
			to_chat(view(originator), "[originator] wishes to revive somebody!")
			var/summon
			switch(input(originator,"Summon them to you?", "", text) in list ("Yes","No",))
				if("Yes") summon=1
			var/list/deadlist = list()
			for(var/mob/M)
				if(M.dead)
					deadlist+=M
					continue
			if(deadlist.len>=1)
				var/mob/revivespecific = input(originator,"Revive who?","") as null|anything in deadlist
				if(!isnull(revivespecific))
					revivespecific.dead=0
					revivespecific.ReviveMe()
					revivespecific.overlayList-='Halo.dmi'
					revivespecific.overlaychanged=1
					sleep(10)
					if(summon) revivespecific.loc=locate(originator.x,(originator.y-2),originator.z)
					else revivespecific.Locate()
				else
					to_chat(view(), "[originator] cancels [originator]'s wish.")
					return list(wishpower,TRUE)
		if("Revive-All")
			to_chat(view(originator), "[originator] wishes to revive everyone!")
			var/summon
			switch(input(originator,"Summon them to you?", "", text) in list ("Yes","No",))
				if("Yes") summon=1
			for(var/mob/M)
				if(M.dead)
					M.ReviveMe()
					M.overlayList-='Halo.dmi'
					M.overlaychanged=1
					sleep(10)
					if(summon) M.loc=locate(originator.x,(originator.y-2),originator.z)
					else M.Locate()
		if("Immortality")
			if(alert(originator,"Make someone else immortal/mortal?","","Yes","No")=="Yes")
				var/list/personList = list()
				for(var/mob/M)
					if(M.client) personList += M
				var/mob/M = input(originator,"Who?") as null|anything in personList
				if(ismob(M))
					if(!M.immortal)
						M.immortal=1
						to_chat(view(originator), "[originator] wishes for [M] to have immortality!")
						to_chat(M, "You are now immortal.")
					else
						M.immortal=0
						to_chat(view(originator), "[originator] wishes for [M] to be mortal!")
						to_chat(M, "You are now mortal.")
			else if(!originator.immortal)
				originator.immortal=1
				to_chat(view(originator), "[originator] wishes for immortality!")
				to_chat(originator, "You are now immortal.")
			else
				originator.immortal=0
				to_chat(view(originator), "[originator] wishes to be mortal!")
				to_chat(originator, "You are now mortal.")
		if("Make Somebody Else Young")
			var/list/younglist = list()
			for(var/mob/M) if(M.client)
				if(M!=originator)
					younglist+=M
					continue
			if(younglist.len>=1)
				var/mob/revivespecific = input(originator,"Restore youth to who?","") as null|anything in younglist
				if(!isnull(revivespecific))
					revivespecific.Age = 25
					revivespecific.Body = 25
					if("Yes"==alert(originator,"Make extremely young?","","Yes","No"))
						revivespecific.Age = 10
						revivespecific.Body = 10
					to_chat(view(), "[originator] wishes for [revivespecific]'s youth!")
					to_chat(revivespecific, "You are now younger.")
					for(var/obj/overlay/hairs/hair/A in revivespecific.overlayList)
						A.UnGrayMe()
				else
					to_chat(view(), "[originator] cancels [originator]'s wish.")
					return list(wishpower,TRUE)
		if("Youth")
			originator.Age = 25
			originator.Body = 25
			if("Yes"==alert(originator,"Make extremely young?","","Yes","No"))
				originator.Age = 10
				originator.Body = 10
			for(var/obj/overlay/hairs/hair/A in originator.overlayList)
				A.UnGrayMe()
			to_chat(view(originator), "[originator] wishes for youth!")
			to_chat(originator, "You are now younger.")
		if("Cash")
			to_chat(view(originator), "[originator] wishes for zeni!")
			originator.zenni+=50000000
			to_chat(originator, "You recieve millions of zeni.")
		if("Kill Somebody")
			var/list/deadlist = list()
			for(var/mob/M)
				if(!M.dead&&M.client)
					deadlist+=M
					continue
			if(deadlist.len>=1)
				var/mob/revivespecific = input(originator,"Kill who? If their power exceeds the creators power, it won't work! Power : [TrueWishPower]","") as null|anything in deadlist
				if(!isnull(revivespecific))
					if(revivespecific.expressedBP>=TrueWishPower)
						to_chat(view(originator), "[originator] wishes to kill [revivespecific]!")
					else
						to_chat(view(originator), "[originator] wishes to kill [revivespecific]!")
						to_chat(view(originator), "It fails!")
				else
					to_chat(view(originator), "[originator] cancels [originator]'s wish.")
					return list(wishpower,TRUE)
		if("Heal Planet")
			var/list/deadlist = list()
			for(var/obj/Planets/P)
				if(P.isDestroyed)
					deadlist+=P
					continue
			if(deadlist.len>=1)
				var/obj/Planets/revivespecific = input(originator,"Heal what planet? Power : [TrueWishPower]","") as null|anything in deadlist
				if(!isnull(revivespecific))
					revivespecific.isDestroyed = 0
					revivespecific.isBeingDestroyed = 0
					to_chat(view(originator), "[originator] wishes for [revivespecific] to be restored!")
					to_chat(world, "[revivespecific] restored.")
				else
					to_chat(view(originator), "[originator] cancels [originator]'s wish.")
					return list(wishpower,TRUE)
		if("Panties")
			var/list/moblist = new
			for(var/mob/M in mob_list)
				if(M.client)
					moblist += M
			if(moblist.len>=1)
				var/mob/revivespecific = input(originator,"Get panties of whom? If cancel/null, it'll just be generic possibly worn panties.","") as null|anything in moblist
				if(!isnull(revivespecific))
					to_chat(view(originator), "[originator] wishes for [revivespecific]'s panties!")
					var/obj/A=new/obj/items/Panties(locate(originator.x,originator.y,originator.z))
					A.name = "[revivespecific]'s Panties"
				else
					to_chat(view(originator), "[originator] wishes for panties!")
					new/obj/items/Panties(locate(originator.x,originator.y,originator.z))
			else
				to_chat(view(originator), "[originator] wishes for panties!")
				new/obj/items/Panties(locate(originator.x,originator.y,originator.z))
		if("Milestones")
			if(originator.wishedpoints)
				to_chat(originator, "You already have wished Milestones!")
				to_chat(view(originator), "[originator] cancels [originator]'s wish.")

			else
				to_chat(originator, "You wish for Milestones!!")
				originator.wishedpoints += 2
				originator.totalskillpoints += 2
				originator.skillpoints += 2 //grant the spendable pool immediately (matches the admin Reward fix)
				originator.availablepoints += 2
				to_chat(view(originator), "[originator] wishes for Milestones!")
		if("Intelligence")
			to_chat(view(originator), "[originator] wishes for intelligence!!")
			originator.genome.add_to_stat("Tech Modifier",2)
			to_chat(originator, "You wish for intelligence!")
		if("Technology")
			to_chat(view(originator), "[originator] wishes for some research technology!!!")
			var/obj/items/Research_Book/A=new/obj/items/Research_Book(locate(originator.x,originator.y,originator.z))
			A.name = "Technology Blueprints"
			A.IntPower = 100 * originator.techskill**2
			A.techcost+=50*originator.techskill
			to_chat(originator, "You wish for technology!")
		if("Gender Change")
			var/list/moblist = new
			for(var/mob/M in mob_list)
				if(M.client)
					moblist += M
			if(moblist.len>=1)
				var/mob/revivespecific = input(originator,"Change gender of whom? If cancel/null, it'll cancel the wish.","") as null|anything in moblist
				if(!isnull(revivespecific))
					var/Choice=alert(originator,"Choose gender","","Male","Female")
					to_chat(view(originator), "[originator] wishes to change the gender of [revivespecific] to [Choice]!!!")
					to_chat(originator, "You wish for a gender change!")
					switch(Choice)
						if("Female")
							revivespecific.pgender="Female"
							revivespecific.gender = FEMALE
						if("Male")
							revivespecific.pgender="Male"
							revivespecific.gender = MALE
					to_chat(revivespecific, "Your gender has been changed to [Choice].")
					revivespecific.Skin()
				else
					to_chat(view(originator), "[originator] cancels [originator]'s wish.")
					return list(wishpower,TRUE)
			else
				to_chat(view(originator), "[originator] cancels [originator]'s wish.")
				return list(wishpower,TRUE)
		if("Super Saiyan")
			var/badssjwish = 0
			if(!originator.hasssj)
				to_chat(view(originator), "[originator] wishes for Super Saiyan!")
				to_chat(originator, "You wish for Super Saiyan!")
				originator.ssjdrain = 0.02
				spawn originator.SSj()
			else if(!originator.hasssj2)
				var/ssj2exists
				for(var/mob/M)
					if(M.hasssj2)
						ssj2exists = 1

				if(ssj2exists)
					to_chat(view(originator), "[originator] wishes for Super Saiyan 2!")
					to_chat(originator, "You wish for Super Saiyan 2!")
					originator.ssj2drain = 0.03
					spawn originator.SSj2()
				else
					badssjwish = 2
			else
				badssjwish = 1
			if(badssjwish)
				var/approved = 0
				for(var/mob/M)
					if(M.Admin >= 2 && M.client)
						switch(input(M,"[originator] is wishing for Super Saiyan, approve?") in list("Approve","Deny"))
							if("Approve") approved = badssjwish
							if("Deny") approved = 0
						if(approved) WriteToLog("admin","[M]([M.key]) approved [originator]([originator.key]) for 'SSJ' at [time2text(world.realtime,"Day DD hh:mm")]")
						else WriteToLog("admin","[M]([M.key]) denied [originator]([originator.key]) for 'SSJ' at [time2text(world.realtime,"Day DD hh:mm")]")

					else continue
				if(!approved)
					to_chat(view(originator), "[originator] wishes for Super Saiyan, it fails!!")
					to_chat(originator, "You wish for Super Saiyan, it fails!!")
					wishpower = 1.05
				else if(approved == 1)
					originator.ssjdrain = 0.02
					originator.SSj()
				else if(approved == 2)
					originator.ssj2drain = 0.03
					originator.SSj2()
				else
					to_chat(view(originator), "[originator] wishes for Super Saiyan, it fails!!")
					to_chat(originator, "You wish for Super Saiyan, it fails!!")
					wishpower = 1.05
		if("Give Soul")
			var/list/moblist = new
			for(var/mob/M in mob_list)
				if(M.client)
					moblist += M
			if(moblist.len>=1)
				var/mob/revivespecific = input("Give soul to whom?","") as null|anything in moblist
				if(!isnull(revivespecific))
					to_chat(view(originator), "[originator] wishes for a soul for [revivespecific]!!!")
					to_chat(originator, "You wish to give a soul!")
					revivespecific.HasSoul = 1
				else
					to_chat(view(originator), "[originator] cancels [originator]'s wish.")
					return list(wishpower,TRUE)
			else
				to_chat(view(originator), "[originator] cancels [originator]'s wish.")
				return list(wishpower,TRUE)
		if("Give Magic")
			if(!originator.wished_for_magic)
				originator.wished_for_magic = 1
				originator.magiBuff += 4
				originator.word_power=1
				originator.ritual_power=1
			else
				to_chat(view(originator), "[originator] cancels [originator]'s wish.")
				to_chat(originator, "You already wished for this!")
				return list(wishpower,TRUE)
	return list(wishpower,FALSE)
mob/var
	wished_for_magic = 0

//wish wishlist:
//go SSJ (after first SSJ)
//more skillpoints (only once)
//panties
//race change
//gender change (inb4 trannies)
//Kill All
//Tech Skill
//Item
//
obj/items/Panties
	icon = 'Panties.png'
	name = "Panties"
	var/pantsuicon = 'Clothes_pantsuhat.dmi'
	SaveItem=1
	verb/Sniff()
		set category = null
		set src in usr
		if(!equipped) to_chat(view(usr), "[usr] brings [src] up and [usr] sniffs.")
		if(equipped) to_chat(view(usr), "[usr] takes a large and noticable sniff.")
		if(prob(1))
			to_chat(usr, "You sniff [src]. It smells very good.")
		else
			to_chat(usr, "You sniff [src]. It smells like silk?")
	verb/Use()
		set category = null
		set src in usr
		to_chat(view(usr), "[usr] brings [src] up and [usr] puts it on [usr]'s' head.")
		if(!equipped)
			equipped=1
			suffix="*Equipped*"
			usr.updateOverlay(/obj/overlay/clothes/panties,pantsuicon)
			to_chat(usr, "You put on the [src].")
		else
			equipped=0
			suffix=""
			usr.removeOverlay(/obj/overlay/clothes/panties,pantsuicon)
			to_chat(usr, "You take off the [src].")
	verb/Icon()
		set category = null
		set src in usr
		switch(alert(usr,"Custom, Default, or cancel?","","Custom","Default","Cancel"))
			if("Custom")
				pantsuicon = input(usr,"Select the icon.","Icon.",icon) as icon
			if("Default")
				pantsuicon = 'Clothes_pantsuhat.dmi'

obj/overlay/clothes/panties //specific item
	name = "panties" //unique name
	ID = 69699 //unique ID
	icon = 'Clothes_pantsuhat.dmi' //icon