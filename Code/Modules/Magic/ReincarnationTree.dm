obj/Reincarnation_Tree
	desc = "Click on this tree to reincarnate."
	icon = 'lowresorangetree.png'
	IsntAItem=1
	SaveItem=1
	var/afterlifefruitgen = 0
	var/afterlifefruitnum = 0

	New()
		..()
		var/icon/I = icon(icon,icon_state)
		pixel_x = 16 - I.Width()/2

	Click()
		if(istype(usr,/mob))
			if(usr.Race=="Kai"||usr.Race=="Demon")
				switch(alert(usr,"Pick a Yemma fruit? There is [afterlifefruitnum] fruits left.","","Yes","No")=="Yes")
					if("Yes")
						if(afterlifefruitnum>=1)
							var/obj/A=new/obj/items/food/Apple_Of_Eden
							usr.contents+=A
							view(usr) << "[usr] picks fruit from the tree of life."
						else usr << "No fruit!"
						..()
						return
			ReincarnateTree(usr)
		..()

	proc/ReincarnateTree(var/mob/M)
		switch(alert(M,"You have chosen to reincarnate. You will never regain this character if you reincarnate. Do so?","","Yes","No"))
			if("Yes")
				view(M) << "[M] reincarnates."
				M.Reincarnate()
				if(afterlifefruitgen)
					afterlifefruitnum += 1

obj/Holy_Fountain
	desc = "A fountain filled with pure holy water"
	icon = 'Holy Fountain.dmi'
	IsntAItem=1
	Click()
		switch(alert(usr, "A never ending stream of water flows gracefully from the holy fountain. The water is clear and untouched. Do you want to drink from the fountain?","","Yes","No"))
			if("Yes")
				usr << "You sip from the fountain..."
				sleep(20)
				if(usr.IsAVampire==1||usr.IsAWereWolf==1||usr.Race=="Demon")
					usr << "While it seemed like normal water at first, the after taste is repulsive. You gag a bit..."
					sleep(20)
					usr << "You convulse and cough up blood! Drinking Holy Water is awful for someone like you!"
					usr.SpreadDamage(20,0)
				else
					usr << "The water is very refreshing."
					sleep(20)
					usr << "Wait, no...to call it refreshing would be the understatement of the century! Your nutritional values are off the charts! Its like a V8 combined with every element of the food pyramid!! Your nutrition is completely restored (assuming you have a body)!"
					usr.currentNutrition = usr.maxNutrition
					return
				sleep(30)
			if("No")
				usr << "You decide against drinking from the fountain."