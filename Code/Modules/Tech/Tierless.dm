obj/Creatables
	var/enabled = 1
	var/mob/container
	var/list/allowedRaces = list()
	/*Core_Computer
		cost=100000
		neededtech=15
		allowedRaces = list("Tsujin","Meta")
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/Core_Computer(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You don't have enough money."
		verb/Description()
			set category =null
			usr<<"Lets you create countless bodies to inhabit. Tsujin/Meta only."*//*
	Central_Computer
		icon = 'bigcomputer.dmi'
		cost=5000000
		neededtech=200
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost

				var/obj/A=new/obj/Core_Computer(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You don't have enough money."
		verb/Description()
			set category =null
			usr<<"Lets you create countless bodies to inhabit. Available to all races."*/