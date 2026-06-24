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
				WishList+="Skillpoints"
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
					view()<<"[usr] wishes for nothing!"
					WishPower*=1.1
					usr<<"You wish for nothing!"
				if("Cancel")
					view()<<"[usr] cancels [usr]'s wish."
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
			view(originator)<<"[originator] wishes for power!"
			if(E_G!=originator.key)
				originator.BP+=originator.capcheck(originator.relBPmax/4)
				//originator.BPMod+=0.2 //slight mod increase!
			else
				view(originator)<<"[originator]'s wish fails because they are the guardian."
				originator<<"You cannot increase your power with the Dragon Balls, because the Dragon Balls use your power to increase the power of others, and your power cannot increase your own power."
				return list(wishpower,TRUE)
		if("Revive")
			view(originator)<<"[originator] wishes to revive somebody!"
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
					view()<<"[originator] cancels [originator]'s wish."
					return list(wishpower,TRUE)
		if("Revive-All")
			view(originator)<<"[originator] wishes to revive everyone!"
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
						view(originator)<<"[originator] wishes for [M] to have immortality!"
						M<<"You are now immortal."
					else
						M.immortal=0
						view(originator)<<"[originator] wishes for [M] to be mortal!"
						M<<"You are now mortal."
			else if(!originator.immortal)
				originator.immortal=1
				view(originator)<<"[originator] wishes for immortality!"
				originator<<"You are now immortal."
			else
				originator.immortal=0
				view(originator)<<"[originator] wishes to be mortal!"
				originator<<"You are now mortal."
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
					view()<<"[originator] wishes for [revivespecific]'s youth!"
					revivespecific<<"You are now younger."
					for(var/obj/overlay/hairs/hair/A in revivespecific.overlayList)
						A.UnGrayMe()
				else
					view()<<"[originator] cancels [originator]'s wish."
					return list(wishpower,TRUE)
		if("Youth")
			originator.Age = 25
			originator.Body = 25
			if("Yes"==alert(originator,"Make extremely young?","","Yes","No"))
				originator.Age = 10
				originator.Body = 10
			for(var/obj/overlay/hairs/hair/A in originator.overlayList)
				A.UnGrayMe()
			view(originator)<<"[originator] wishes for youth!"
			originator<<"You are now younger."
		if("Cash")
			view(originator)<<"[originator] wishes for zeni!"
			originator.zenni+=50000000
			originator<<"You recieve millions of zeni."
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
						view(originator)<<"[originator] wishes to kill [revivespecific]!"
					else
						view(originator)<<"[originator] wishes to kill [revivespecific]!"
						view(originator)<<"It fails!"
				else
					view(originator)<<"[originator] cancels [originator]'s wish."
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
					view(originator)<<"[originator] wishes for [revivespecific] to be restored!"
					world << "[revivespecific] restored."
				else
					view(originator)<<"[originator] cancels [originator]'s wish."
					return list(wishpower,TRUE)
		if("Panties")
			var/list/moblist = new
			for(var/mob/M in mob_list)
				if(M.client)
					moblist += M
			if(moblist.len>=1)
				var/mob/revivespecific = input(originator,"Get panties of whom? If cancel/null, it'll just be generic possibly worn panties.","") as null|anything in moblist
				if(!isnull(revivespecific))
					view(originator)<<"[originator] wishes for [revivespecific]'s panties!"
					var/obj/A=new/obj/items/Panties(locate(originator.x,originator.y,originator.z))
					A.name = "[revivespecific]'s Panties"
				else
					view(originator)<<"[originator] wishes for panties!"
					new/obj/items/Panties(locate(originator.x,originator.y,originator.z))
			else
				view(originator)<<"[originator] wishes for panties!"
				new/obj/items/Panties(locate(originator.x,originator.y,originator.z))
		if("Skillpoints")
			if(originator.wishedpoints)
				originator<<"You already have wished skillpoints!"
				view(originator)<<"[originator] cancels [originator]'s wish."

			else
				originator<<"You wish for skillpoints!!"
				originator.wishedpoints += 2
				originator.totalskillpoints += 2
				view(originator)<<"[originator] wishes for skillpoints!"
		if("Intelligence")
			view(originator)<<"[originator] wishes for intelligence!!"
			originator.genome.add_to_stat("Tech Modifier",2)
			originator<<"You wish for intelligence!"
		if("Technology")
			view(originator)<<"[originator] wishes for some research technology!!!"
			var/obj/items/Research_Book/A=new/obj/items/Research_Book(locate(originator.x,originator.y,originator.z))
			A.name = "Technology Blueprints"
			A.IntPower = 100 * originator.techskill**2
			A.techcost+=50*originator.techskill
			originator<<"You wish for technology!"
		if("Gender Change")
			var/list/moblist = new
			for(var/mob/M in mob_list)
				if(M.client)
					moblist += M
			if(moblist.len>=1)
				var/mob/revivespecific = input(originator,"Change gender of whom? If cancel/null, it'll cancel the wish.","") as null|anything in moblist
				if(!isnull(revivespecific))
					var/Choice=alert(originator,"Choose gender","","Male","Female")
					view(originator)<<"[originator] wishes to change the gender of [revivespecific] to [Choice]!!!"
					originator<<"You wish for a gender change!"
					switch(Choice)
						if("Female")
							revivespecific.pgender="Female"
							revivespecific.gender = FEMALE
						if("Male")
							revivespecific.pgender="Male"
							revivespecific.gender = MALE
					revivespecific << "Your gender has been changed to [Choice]."
					revivespecific.Skin()
				else
					view(originator)<<"[originator] cancels [originator]'s wish."
					return list(wishpower,TRUE)
			else
				view(originator)<<"[originator] cancels [originator]'s wish."
				return list(wishpower,TRUE)
		if("Super Saiyan")
			var/badssjwish = 0
			if(!originator.hasssj)
				view(originator)<<"[originator] wishes for Super Saiyan!"
				originator<<"You wish for Super Saiyan!"
				originator.ssjdrain = 0.02
				spawn originator.SSj()
			else if(!originator.hasssj2)
				var/ssj2exists
				for(var/mob/M)
					if(M.hasssj2)
						ssj2exists = 1

				if(ssj2exists)
					view(originator)<<"[originator] wishes for Super Saiyan 2!"
					originator<<"You wish for Super Saiyan 2!"
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
					view(originator)<<"[originator] wishes for Super Saiyan, it fails!!"
					originator<<"You wish for Super Saiyan, it fails!!"
					wishpower = 1.05
				else if(approved == 1)
					originator.ssjdrain = 0.02
					originator.SSj()
				else if(approved == 2)
					originator.ssj2drain = 0.03
					originator.SSj2()
				else
					view(originator)<<"[originator] wishes for Super Saiyan, it fails!!"
					originator<<"You wish for Super Saiyan, it fails!!"
					wishpower = 1.05
		if("Give Soul")
			var/list/moblist = new
			for(var/mob/M in mob_list)
				if(M.client)
					moblist += M
			if(moblist.len>=1)
				var/mob/revivespecific = input("Give soul to whom?","") as null|anything in moblist
				if(!isnull(revivespecific))
					view(originator)<<"[originator] wishes for a soul for [revivespecific]!!!"
					originator<<"You wish to give a soul!"
					revivespecific.HasSoul = 1
				else
					view(originator)<<"[originator] cancels [originator]'s wish."
					return list(wishpower,TRUE)
			else
				view(originator)<<"[originator] cancels [originator]'s wish."
				return list(wishpower,TRUE)
		if("Give Magic")
			if(!originator.wished_for_magic)
				originator.wished_for_magic = 1
				originator.magiBuff += 4
				originator.word_power=1
				originator.ritual_power=1
			else
				view(originator)<<"[originator] cancels [originator]'s wish."
				originator << "You already wished for this!"
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
		if(!equipped) view(usr)<<"[usr] brings [src] up and [usr] sniffs."
		if(equipped) view(usr)<<"[usr] takes a large and noticable sniff."
		if(prob(1))
			usr<<"You sniff [src]. It smells very good."
		else
			usr<<"You sniff [src]. It smells like silk?"
	verb/Use()
		set category = null
		set src in usr
		view(usr)<<"[usr] brings [src] up and [usr] puts it on [usr]'s' head."
		if(!equipped)
			equipped=1
			suffix="*Equipped*"
			usr.updateOverlay(/obj/overlay/clothes/panties,pantsuicon)
			usr<<"You put on the [src]."
		else
			equipped=0
			suffix=""
			usr.removeOverlay(/obj/overlay/clothes/panties,pantsuicon)
			usr<<"You take off the [src]."
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