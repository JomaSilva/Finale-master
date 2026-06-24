mob/var/deposited_zenni=0
mob/proc
	Bank()
		usr<<"You have [usr.deposited_zenni] zenni in your account."
		switch(input("What now?","",text) in list("Nothing","Deposit","Withdraw"))
			if("Deposit")
				var/amount=input("How much do you want to put in?") as num
				amount = round(amount)
				if(amount>usr.zenni) amount = usr.zenni
				else if(amount<1) alert("You must atleast put in 1 zenni.")
				else
					if(amount>usr.zenni) amount=usr.zenni
					alert("You have deposited [amount] zenni into the bank.")
					usr.deposited_zenni+=amount
					usr.zenni-=amount
			if("Withdraw")
				var/amount=input("How much do you want to withdraw? You have [usr.deposited_zenni] zenni in your account.") as num
				amount = round(amount)
				if(amount>usr.deposited_zenni) amount = usr.deposited_zenni
				else if(amount<0) alert("You must atleast take out 0 zenni.")
				else
					usr.deposited_zenni-=amount
					usr.zenni+=amount

obj/Bank
	icon ='tech.dmi'
	icon_state = "compdown"
	name = "Bank"
	IsntAItem=1
	canGrab = 0
	verb/Bank()
		set category = null
		set src in oview(1)
		usr.Bank()

	verb/Deposit_Item()
		set category = null
		set waitfor = 0
		set background = 1
		set src in oview(1)
		var/datum/Bank_Item_Holder/TargetHolder = null
		for(var/datum/Bank_Item_Holder/A)
			if(A.ownerckey == usr.ckey)
				TargetHolder = A
				break
		if(isnull(TargetHolder))
			var/datum/Bank_Item_Holder/nBIH = new
			nBIH.ownerckey = usr.ckey
			TargetHolder = nBIH
			BankHolders += nBIH

		if(TargetHolder)
			var/list/gibList = list()
			for(var/obj/items/A in usr.contents)
				gibList += A
			for(var/obj/Modules/A in usr.contents)
				gibList += A
			gibList += "Cancel"
			bankstart
			var/obj/choice = input(usr,"What item to deposit?","","Cancel") as null|anything in gibList
			if(isobj(choice))
				if(istype(choice,/obj/items))
					if(choice:DropMe(usr))
						view(usr)<<"[usr] deposits [choice]."
						TargetHolder.AddItem(choice)
						goto bankstart
					else usr<<"Failed to deposit item."
				if(istype(choice,/obj/Modules))
					if(choice:DropMe(usr))
						view(usr)<<"[usr] deposits [choice]."
						TargetHolder.AddItem(choice)
						goto bankstart
					else usr<<"Failed to deposit item."
		else return

	verb/Retrieve_Item()
		set category = null
		set waitfor = 0
		set background = 1
		set src in oview(1)
		var/datum/Bank_Item_Holder/TargetHolder = null
		for(var/datum/Bank_Item_Holder/A)
			if(A.ownerckey == usr.ckey)
				TargetHolder = A
				break
		if(isnull(TargetHolder))
			usr << "ERROR: No bank account present! Despoit an item before you take one out!"
			return
		else
			var/list/gibList = list()
			for(var/obj/A in TargetHolder.itemswithin)
				gibList += A
			gibList += "Cancel"
			var/obj/choice = input(usr,"What item to retrieve?","","Cancel") as null|anything in gibList
			if(isobj(choice))
				TargetHolder.RemoveItem(choice,usr)
				if(istype(choice,/obj/items))
					if(choice:GetMe(usr))
					else usr<<"Failed to completely retrieve item. It's on the ground."
				if(istype(choice,/obj/Modules))
					if(choice:GetMe(usr))
					else usr<<"Failed to completely retrieve item. It's on the ground."


var/list/BankHolders = list()

datum/Bank_Item_Holder
	parent_type = /atom/movable
	var/list/itemswithin = list()
	var/ownerckey = ""
	var/wipenow = 0
	//SaveItem=1

	New()
		set background = 1
		set background = 1
		..()
		spawn
			if(wipenow)
				for(var/obj/A in itemswithin)
					del(A)
				del(src)
			for(var/obj/A in itemswithin)
				A.loc = locate(0,0,34)
				A.loc = src

	proc/AddItem(var/obj/A)
		itemswithin += A
		A.loc = locate(0,0,34)
		A.loc = src

	//proc/Enter()
	//	return 1
	//proc/Cross()
	//	return 1

	proc/RemoveItem(var/obj/A,var/mob/TargetMob)
		itemswithin -= A
		A.loc = locate(TargetMob.x,TargetMob.y,TargetMob.z)

	proc/Wipe()
		for(var/obj/A in itemswithin)
			del(A)
		del(src)