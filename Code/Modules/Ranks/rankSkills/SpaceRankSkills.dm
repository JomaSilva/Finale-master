
/datum/skill/rank/Taxes //needs overhaul
	skilltype = "Misc"
	name = "Taxes"
	desc = "Learn the ultimate power that brings all to their knees- accounting. Using your rule, learn how to make the chumps below you learn who they pay."
	can_forget = TRUE
	common_sense = TRUE
	tier = 1
	skillcost=1
	enabled=0

/datum/skill/rank/Taxes/after_learn()
	if(savant.Rank =="King of Vegeta")
		assignverb(/mob/RTax/verb/Vegeta_Taxes)
		assignverb(/mob/RTax/verb/Collect_Vegeta_Taxes)
		assignverb(/mob/RTax/verb/Exempt_Vegeta_Taxes)
	else if(savant.Rank =="President")
		assignverb(/mob/ETax/verb/Earth_Taxes)
		assignverb(/mob/ETax/verb/Collect_Earth_Taxes)
		assignverb(/mob/ETax/verb/Exempt_Earth_Taxes)
	savant<<"You can add numbers together!"
/datum/skill/rank/Taxes/before_forget()
	unassignverb(/mob/RTax/verb/Vegeta_Taxes)
	unassignverb(/mob/RTax/verb/Collect_Vegeta_Taxes)
	unassignverb(/mob/RTax/verb/Exempt_Vegeta_Taxes)
	unassignverb(/mob/ETax/verb/Earth_Taxes)
	unassignverb(/mob/ETax/verb/Collect_Earth_Taxes)
	unassignverb(/mob/ETax/verb/Exempt_Earth_Taxes)
	savant<<"You've forgotten how to do basic fucking math!?"
/datum/skill/rank/Taxes/login(var/mob/logger)
	..()
	if(savant.Rank =="King of Vegeta")
		assignverb(/mob/RTax/verb/Vegeta_Taxes)
		assignverb(/mob/RTax/verb/Collect_Vegeta_Taxes)
		assignverb(/mob/RTax/verb/Exempt_Vegeta_Taxes)
	else if(savant.Rank =="President")
		assignverb(/mob/ETax/verb/Earth_Taxes)
		assignverb(/mob/ETax/verb/Collect_Earth_Taxes)
		assignverb(/mob/ETax/verb/Exempt_Earth_Taxes)


mob/RTax/verb
	Vegeta_Taxes()
		set name="Vegeta Managament"
		set category="Other"
		switch(input(usr,"You can set a person as royalty (either Prince, Princess, or simple lordship- only lordship can be undone completely.), or set them as a rank inside the army. You can also set taxes. Vegeta's Taxes are at [VegetaTax]z.") in list("Royalty","Army","Taxes","Cancel"))
			if("Taxes")
				usr<<"Vegeta's Taxes are at [VegetaTax]z."
				var/Mult=input("Enter a number for tax rate. This will increase or decrease across Vegeta. (1 = 1z)") as num
				VegetaTax=Mult
			if("Royalty")
				var/mob/M = input(usr,"Select a mob in view. Selecting yourself will cancel the operation.") as mob in view(10)
				if(M != src)
					switch(input(usr,"Promote as princess, prince, or lordship? Or demote?") in list("Cancel","Demote","Prince","Princess","Lordship"))
						if("Demote")
							for(var/A in vegeta_royalty)
								if(vegeta_royalty[A] == M.name)
									vegeta_royalty[A] = null
									if(A == "Lordship") vegeta_royalty -= A
						if("Prince")
							var/didit
							var/cnt
							for(var/A in vegeta_royalty)
								if(vegeta_royalty[A] == null && A == "Prince")
									vegeta_royalty[A] = M.name
									didit=1
									M.Prince=1
									break
								else if(A == "Prince") cnt++
							if(!didit)
								M.Prince=1
								vegeta_royalty["Prince [cnt]"] = M.name
						if("Princess")
							var/didit
							var/cnt
							for(var/A in vegeta_royalty)
								if(vegeta_royalty[A] == null && A == "Princess")
									vegeta_royalty[A] = M.name
									didit=1
									M.Princess=1
									break
								else if(A == "Princess") cnt++
							if(!didit)
								M.Princess=1
								vegeta_royalty["Princess [cnt]"] = M.name
						if("Lordship")
							var/didit
							var/cnt
							for(var/A in vegeta_royalty)
								if(vegeta_royalty[A] == null && A == "Lordship")
									vegeta_royalty[A] = M.name
									didit=1
									break
								else if(A == "Lordship") cnt++
							if(!didit)
								if(cnt)
									vegeta_royalty["Lordship [cnt]"] = M.name
								else vegeta_royalty["Lordship"] = M.name

			if("Army")
				var/mob/M = input(usr,"Select a mob in view. Selecting yourself will cancel the operation.") as mob in view(10)
				if(M != src)
					switch(input(usr,"Add or remove from army? Promote allows you to type in the rank. Curate List lets you remove entries from the Army registry manually.") in list("Cancel","Add","Remove","Promote","Curate List"))
						if("Add")
							vegeta_army["Soldier [vegeta_army.len]"] = list(M.name,"Private")
						if("Remove")
							for(var/a in vegeta_army)
								if(vegeta_army[a][1] == M.name)
									vegeta_army -= a
						if("Promote")
							for(var/a in vegeta_army)
								if(vegeta_army[a][1] == M.name)
									vegeta_army[a][2] = input(usr,"Promote to? Current Rank: [vegeta_army[a][2]]") as text
									break
						if("Curate List")
							var/list/curles = list()
							for(var/a in vegeta_army) curles += vegeta_army[a][1]
							curles += "Cancel"
							var/madman = input(usr,"Delete what item?") in curles
							if(madman != "Cancel")
								for(var/a in vegeta_army)
									if(vegeta_army[a][1] == madman) vegeta_army-=a
	Collect_Vegeta_Taxes()
		set category="Other"
		usr<<"Vegeta's bank has [VegetaBank]z."
		var/Mult=input("Enter a number to deduct from the bank. (1 = 1z)") as num
		if(Mult<=VegetaBank)
			VegetaBank-=Mult
			usr.zenni+=Mult
	Exempt_Vegeta_Taxes(mob/M in world)
		set category="Other"
		M.RTaxExempt=1

/datum/skill/rank/Fusion_Dance //needs overhaul, as it has learning curves, and EG shouldn't teach it. Maybe a Kai?
	skilltype = "Fusion"
	name = "Fusion Dance"
	desc = "Learn a powerful- but temporary- means of fusing one person with another, increasing their power significantly, and seperating when it wears off."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=1
	enabled=0

/datum/skill/rank/Fusion_Dance/after_learn()
	savant.contents+=new/obj/Fusion_dance
	savant<<"You can fuse!!"
/datum/skill/rank/Fusion_Dance/before_forget()
	for(var/obj/D in savant.contents)
		if(D==/obj/Fusion_dance)
			del(D)
	savant<<"You've forgotten how to 'do the dance'!?"