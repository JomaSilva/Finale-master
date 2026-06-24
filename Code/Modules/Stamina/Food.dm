mob/var/tmp/GrowingBean
mob/Rank/verb
	Grow_Senzu_Bean()
		set category="Skills"
		if(!GrowingBean)
			GrowingBean=1
			usr<<"You start growing a Senzu bean, this will take a minute..."
			sleep(600)
			var/obj/A=new/obj/items/food/Senzu
			A.loc=locate(x,(y-1),z)
			usr<<"All done."
			GrowingBean=0
		else usr<<"You must wait til you grow this one first."
mob/var
	Senzu
	fishing
	CanEat = 1

obj/items/food
	cantblueprint=1
	stackable=1

	Senzu
		icon='Senzu Bean.dmi'
		name="Senzu"
		var/Increase=4
		var/division=1
		nutrition=10
		proc/sensuuse(var/mob/M)
			for(var/datum/Body/C in M.contents)
				if(C.health < 100&&!C.lopped)
					C.health = 25 * Increase
			M.SpreadHeal(min((M.HP + 25 )* Increase,100))
		New()
			..()
			pixel_x+=rand(-16,16)
			pixel_y+=rand(-16,16)
		Eat()
			if(!usr.KO&&usr.CanEat&&usr.Senzu+Increase<=4)
				usr.Senzu+=Increase
				sensuuse(usr)
				usr<<"You eat a Senzu Bean"
				view(usr)<<"[usr] pops a Senzu Bean into his mouth."
			else if(usr.Senzu+Increase<4)
				usr<<"You have to wait a little bit."
			else if(usr.KO) usr<<"You cant eat a Senzu while unconscious"
			else if(!usr.CanEat) usr << "You can't digest food."
			..()
		verb
			Throw(mob/M in oview(usr))
				set category=null
				view(usr)<<"[usr] throws a Senzu to [M]"
				missile('Senzu.dmi',usr,M)
				sleep(2)
				view(usr)<<"[M] catches the Senzu"
				Move(M)
			Use_on(mob/M in oview(1))
				set category=null
				if(M.KO)
					view(usr)<<"[usr] gives a Senzu to [M]"
					M.icon_state=""
					M.Un_KO()
					sensuuse(usr)
					M.Senzu+=Increase
					del(src)
				else usr<<"You can only use this on an unconscious person."
			Split()
				set category=null
				view(usr)<<"[usr] Splits a senzu in half"
				var/amount=2
				while(amount)
					var/obj/items/food/Senzu/A=new/obj/items/food/Senzu
					A.division=division*2
					A.Increase=Increase*0.5
					A.name="1/[A.division] Senzu"
					usr.contents+=A
					amount-=1
				del(src)
			Plant()
				set category=null
				loc=locate(usr.x,usr.y,usr.z)
				view(src)<<"[usr] Plants a senzu bean in the ground..."
				while(x&&y&&z)
					sleep(100)
					if(prob(0.1))
						var/blarg=name
						division*=0.5
						Increase*=2
						if(division>1) name="1/[division] Senzu"
						else
							icon='Senzu.dmi'
							name="Senzu"
						view(src)<<"The [blarg] grows into a [name]..."
	corpse
		icon='corpse.dmi'
		nutrition=10
		flavor="Ughhh... raw meat."
		cookable=1
		cookskill=20
		cooktype=/obj/items/food/Cooked_Meat

	Cooked_Meat
		icon='food.dmi'
		icon_state="meatcooked"
		nutrition=30
		mobkilled="meat"

	Charred_Food
		icon='Food Burned.dmi'
		nutrition=5
		flavor="This food is burned. Disgusting."

obj/items/food
	New()
		..()
		spawn ticker()

	Click()
		if(src in usr.contents)
			Eat()
		..()
	proc/ticker()
		set background =1
		while(timetospoil && willspoil)
			timetospoil--
			sleep(1)
		if(willspoil) deleteMe()
	verb
		Eat()
			set category = null
			set src in view(1)
			if(!usr.eating&&usr.CanEat)
				usr<<"[flavor]"
				view(usr)<<"[usr] eats the [name]"
				usr.Hunger=0
				usr.eating=1
				usr.currentNutrition+=nutrition
				if(usr.currentNutrition>usr.maxNutrition)
					usr<<"You ate too much... and you throw up a little. It isn't visible, but it might be a good idea to eat a little lighter next time."
				if(planttype&&prob(25))
					var/obj/items/food/A=new/obj/items/food/Seed
					A.planttype=planttype
					usr.contents+=A
				del(src)
			else
				if(usr.eating)
					usr<<"You need to wait to eat!"
				if(!usr.CanEat)
					usr<<"You can't digest food."

		Cook()
			set category=null
			set src in usr
			if(cooking)
				return
			var/fireNearby
			for(var/turf/T in view(1))
				if(T.fire)
					fireNearby=1
			for(var/obj/nF in view(1))
				if(nF.isFire)
					fireNearby=1
			if(!cookable)
				usr<<"You don't think this can be cooked."
				return
			if(cookable&&usr.CookingSkill<cookskill)
				usr<<"You are not skilled enough to cook this. You need [cookskill] cooking skill."
				return
			if(fireNearby)
				cooking=1
				usr<<"It'll take a minute to cook it."
				spawn(100)
					if(prob(40+max(usr.CookingSkill-cookskill,0)))
						usr<<"The [name] is cooked!"
						var/obj/items/food/A=new cooktype
						A.nutrition*=(1+(usr.CookingSkill/100))
						if(mobkilled)
							A.name = name
							A.mobkilled = mobkilled
							A.flavor="The taste of [mobkilled] permeates throughout the meat... It's delicious, and filling!" //can't define this fucker during runtime, has to be done here.
						usr.contents+=A
						AddExp(usr,/datum/mastery/Life/Cooking,50*cookskill)
						cooking=0
						del(src)
					else
						usr<<"You ended up burning the [name]..."
						var/obj/A=new/obj/items/food/Charred_Food
						usr.contents+=A
						AddExp(usr,/datum/mastery/Life/Cooking,50)
						cooking=0
						del(src)
	var
		nutrition = 2
		flavor="You eat it and feel your hunger give way... It's delicious!"
		planttype
		mobkilled
		timetospoil = 200000 //100000 game ticks = spoil
		willspoil = 0
		cookable=0//can you cook this?
		cooktype=null//what pops out when you cook?
		cookskill=1//how skilled do you need to be to cook this?
		cooking=0//toggle this while cooking to prevent duplication
obj/Creatables
	Fridge
		icon = 'refridgerator.dmi'
		cost=15000
		neededtech=13
		desc = "Refridgerators let you store food items for long periods of time."
		create_type = /obj/items/Fridge

obj/items/Fridge
	icon = 'refridgerator.dmi'
	SaveItem = 1
	density=1
	var/list/storedfood = list()
	verb
		Deposit_Food()
			set category = null
			set src in oview(1)
			if(!Bolted) return
			var/list/foodlist = list()
			for(var/obj/items/food/F in usr.contents)
				foodlist += F
			var/obj/items/food/nF = input(usr,"Food to store. It'll degrade 50% slower") as null|anything in foodlist
			if(!isnull(nF))
				nF.DropMe(usr)
				nF.loc = locate(src)
				contents += nF
				storedfood += nF
		Withdraw_Food()
			set category = null
			set src in oview(1)
			if(!Bolted) return
			var/obj/items/food/nF = input(usr,"Food to grab. It'll degrade 50% quicker") as null|anything in storedfood
			if(!isnull(nF))
				if(locate(nF) in contents)
					nF.GetMe(usr)
					usr.contents += nF
					storedfood -= nF
		Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
						Bolted=1
						boltersig=usr.signiture
			else if(Bolted&&boltersig==usr.signiture)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
						Bolted=0
		Customize()
			set category = null
			set src in oview(1)
			switch(input(usr,"Customize what?") in list("Icon","Name","Defaults","Cancel"))
				if("Icon")
					icon = input(usr,"Pick the icon.") as icon
					icon_state = input(usr,"Icon state?") as text
					pixel_x = input(usr,"Pixel x?") as num
					pixel_y = input(usr,"Pixel y?") as num
				if("Name")
					name = input(usr,"Pick the name") as text
				if("Defaults")
					icon = 'refridgerator.dmi'
					name = "Fridge"