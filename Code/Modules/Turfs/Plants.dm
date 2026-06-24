obj/Turfs
	canGrab=0
	Apples
		icon='Turf3.dmi'
		icon_state="163"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1

obj/Trees
	canGrab = 0
	Savable=0
	fragile=1
	plane=8
	createDust=0
	var/IsEquipped
	New()
		..()
		spawn(1) if(src) if(!Builder) for(var/turf/A in view(0,src)) if(A.Builder) del(src)
		spawn(1) if(src) for(var/obj/A in view(0,src)) if(A!=src) if(loc==initial(loc)) del(src)
		var/icon/I = icon(icon,icon_state)
		pixel_x = 16 - I.Width()/2
		del(I)
	verb/Drop()
		set category=null
		set src in usr
		DropMe(usr)
	proc/DropMe(var/mob/TargetMob)
		if(IsEquipped)
			suffix=""
			IsEquipped = 0
		if(equipped|suffix=="*Equipped*")
			TargetMob<<"You must unequip it first"
			return FALSE
		TargetMob.overlayList-=icon
		TargetMob.overlaychanged=1
		loc=TargetMob.loc
		Savable = 0
		step(src,TargetMob.dir)
		view(TargetMob)<<"<font size=1><font color=teal>[TargetMob] drops [src]."
		return TRUE
	AppleTree
		name = "Apple Tree"
		icon='DecTrees.dmi'
		icon_state="apple"
		density=1
		plane = 8
		var/appleCount = 10
		verb/Pick_Apple()
			set category = null
			set src in oview(1)
			if(appleCount)
				appleCount-=1
				new/obj/items/food/Apple(locate(usr.x,usr.y,usr.z))
				view(usr) << "[usr] picks an apple."
		New()
			..()
			spawn CheckApples()
		proc/CheckApples()
			spawn(500)
				if(appleCount<10&&prob(50))
					appleCount+=3
					CheckApples()
	Oaktree
		icon='Oak.dmi'
		icon_state="1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Oaktree2
		icon='Oak.dmi'
		icon_state="2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Oaktree3
		icon='Oak.dmi'
		icon_state="3"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	SmallOak
		icon='Oak.dmi'
		icon_state="2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	SmallTree
		icon='DecTrees.dmi'
		icon_state="1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	SmallBush
		icon='DecTrees.dmi'
		icon_state="2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PalmTreeRight
		icon='Palm.dmi'
		icon_state="1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PalmTreeLeft
		icon='Palm.dmi'
		icon_state="2"
		density=1
		New()
			..()
			var/icon/I = icon(icon)
			pixel_x = I.Width()/2 - 16
			del(I)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PalmTree1
		icon='Palm.dmi'
		icon_state="3"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PalmTree2
		icon='Palm.dmi'
		icon_state="4"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PineTree
		icon='Pine.dmi'
		icon_state="1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PineSmTree
		icon='Pine.dmi'
		icon_state="2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	SmallPine
		icon='Turf 58.dmi'
		icon_state="2"
		density=1
		New()
			..()
			var/image/A=image(icon='Turf 58.dmi',icon_state="1",pixel_y=0,pixel_x=-32,layer=50)
			var/image/B=image(icon='Turf 58.dmi',icon_state="0",pixel_y=-32,pixel_x=0,layer=50)
			var/image/C=image(icon='Turf 58.dmi',icon_state="3",pixel_y=32,pixel_x=-32,layer=50)
			var/image/D=image(icon='Turf 58.dmi',icon_state="4",pixel_y=32,pixel_x=0,layer=50)
			overlays.Add(A,B,C,D)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	RedTree
		icon='RedTree.dmi'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	BigHousePlant
		density=1
		icon='Turf 52.dmi'
		icon_state="plant bottom"
		New()
			..()
			var/image/A=image(icon='Turf 52.dmi',icon_state="plant top",pixel_y=32,pixel_x=0,layer=50)
			overlays.Add(A)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Oak
		density=1
		New()
			..()
			var/image/A=image(icon='turfs.dmi',icon_state="1",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='turfs.dmi',icon_state="2",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='turfs.dmi',icon_state="3",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='turfs.dmi',icon_state="4",pixel_y=32,pixel_x=16,layer=50)
			var/image/E=image(icon='turfs.dmi',icon_state="5",pixel_y=64,pixel_x=-16,layer=50)
			var/image/F=image(icon='turfs.dmi',icon_state="6",pixel_y=64,pixel_x=16,layer=50)
			overlays.Add(A,B,C,D,E,F)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	RoundTree
		density=1
		New()
			..()
			var/image/A=image(icon='turfs.dmi',icon_state="01",pixel_y=0,pixel_x=-16,layer=50)
			var/image/B=image(icon='turfs.dmi',icon_state="02",pixel_y=0,pixel_x=16,layer=50)
			var/image/C=image(icon='turfs.dmi',icon_state="03",pixel_y=32,pixel_x=-16,layer=50)
			var/image/D=image(icon='turfs.dmi',icon_state="04",pixel_y=32,pixel_x=16,layer=50)
			overlays.Add(A,B,C,D)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Tree
		density=1
		icon='turfs.dmi'
		icon_state="bottom"
		New()
			..()
			var/image/B=image(icon='turfs.dmi',icon_state="middle",pixel_y=32,pixel_x=0,layer=50)
			var/image/C=image(icon='turfs.dmi',icon_state="top",pixel_y=64,pixel_x=0,layer=50)
			overlays.Add(B,C)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	Palm
		density=1
		icon='Trees2.dmi'
		icon_state="1"
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	LargePine
		icon='Tree Good.dmi'
		icon_state="0"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	LargePineSnow
		icon='Tree Snow.dmi'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	LargePineRed
		density=1
		icon='Tree Red.dmi'
		icon_state=""
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	LargePineTeal
		icon='Tree Teal.dmi'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	TallBush
		density=1
		icon='Turf3.dmi'
		icon_state="tallPlantbottom"
		density=1
		New()
			..()
			var/image/A=image(icon='Turf3.dmi',icon_state="tallPlanttop",pixel_y=32,layer=50)
			overlays.Add(A)
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree
		density=1
		icon='Namek Tree.dmi'
		icon_state=""
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree1
		icon='Trees Namek.dmi'
		icon_state="1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree2
		icon='Trees Namek.dmi'
		icon_state="2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree3
		icon='Trees Namek.dmi'
		icon_state="3"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree4Tall
		icon='NamekTrees.dmi'
		icon_state="A 1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree4Small
		icon='NamekTrees.dmi'
		icon_state="A 2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree5Tall
		icon='NamekTrees2.dmi'
		icon_state="A 1"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	NamekTree5Small
		icon='NamekTrees2.dmi'
		icon_state="A 2"
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	PinkTree
		icon='lowrespinktree.png'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	DeadTree1
		icon='deadtree2016.png'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	DeadTree2
		icon='deadtree20162.png'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	DeadTreeSnow
		icon='deadtreesnow.png'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	JungleTree
		icon='jungletree4.dmi'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	JungleTree2
		icon='jungletree3.png'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
	JungleTree3
		icon='jungletree.png'
		icon_state=""
		density=1
		Enter(mob/M)
			if(istype(M,/mob))
				if(M.flight) return 1
				else return
			else return 1
obj/Plants
	//tracking variables, no modify
	var/growthPercent = 0
	var/harvestAmount = 0
	var/growthMeter = 0
	var/currentstage = 1
	var/initialStage = 1 //starting stage, can modify if a initial stage is something you don't want to see.
	//
	var/harvestYield = 1 //how much each harvest gibs of the specific food.
	var/growthSpeed = 1 //mod that determines the next day it'll grow. RNG'd a bit, but not by much.
	var/gotostageMeter = 2 //how many ticks it takes to get to the next stage. each tick is a ingame day.
	var/maxstage = 4 //number of stages in the icon

	name = "Farmable Plant"
	desc = "Set the description on yo plants! -Assfag"

	icon = 'potatos.dmi'
	icon_state = "stage 1" //plants can have several stages
	var/planter = ""
	SaveItem = 0
	density = 0
	plane = 8
	createDust=0
	canGrab = 0
	var/obj/items/food/outputitem = null //output item
	Click()
		if(get_dist(loc,usr.loc)<=1)
			Pick()

	New()
		..()
		src.Tick()

	verb/Pick()
		set background = 1
		set category = null
		set src in view(1)
		if(Harvest())
			view(usr)<<"[usr] harvested [name]"
		else
			view(usr)<<"[usr] tried to pick a crop that wasn't ready yet, destroying it."


	proc/Harvest()
		set background = 1
		if(growthPercent>=0.50)
			harvestAmount = round(harvestYield * growthPercent * max(usr.ForagingSkill/10,1),1)
			AddExp(usr,/datum/mastery/Life/Foraging,50*harvestAmount)
			if(src.planter==usr.signiture)
				AddExp(usr,/datum/mastery/Life/Farming,50*harvestAmount)
			while(harvestAmount)
				var/obj/items/food/A = new outputitem
				A.loc = locate(rand(x-1,x+1),rand(y-1,y+1),z)
				harvestAmount -= 1
				sleep(1)
			harvestAmount = 0
			currentstage = initialStage
			growthPercent = 0
			icon_state = "stage [currentstage]"
			return TRUE
		else
			spawn(1) del(src)
			return FALSE

	proc/Tick()
		set background = 1
		while(src)
			if(Yearspeed==0||!Yearspeed)
				Yearspeed=1
			if(currentstage!=maxstage)
				growthMeter += 1 * growthSpeed
				if(growthMeter >= gotostageMeter)
					growthMeter = 0
					currentstage = min((currentstage + 1),maxstage)
					if(icon_state!="stage [currentstage]")
						icon_state = "stage [currentstage]"
					growthPercent = currentstage / maxstage
			sleep(max(10,(100/Yearspeed)))

obj/Plants
	Wheat
		name = "Wheat"
		icon = 'wheat.dmi'
		desc = "A rather common plant that grows in forest or field areas."
		maxstage = 8
		growthSpeed = 1.2
		harvestYield = 3
		outputitem = /obj/items/food/Wheat_Straw
	Orange
		name = "Orange Root"
		icon = 'carrot.dmi'
		desc = "Much rarer, the Orange Root is a curious fruit that grows and eventually buds from the ground."
		maxstage = 4
		growthSpeed = 1
		harvestYield = 2
		outputitem = /obj/items/food/Orange
	Opuntia
		name = "Cacti Root"
		icon = 'beetroot.dmi'
		desc = "A desert plant, capable of growing in harsh and dry climates."
		maxstage = 4
		growthSpeed = 1
		harvestYield = 2
		outputitem = /obj/items/food/Opuntia

	Tree_Of_Might
		name = "Tree of Might"
		icon = 'MightTree.dmi'
		desc = "The legendary Tree of Might is only meant to be grown by the Gods and harvested for their energy. When one eats a fruit, their energy can rise up to fifteen times the norm."
		maxstage = 3
		growthSpeed = 0.5
		initialStage = 2
		harvestYield = 5
		gotostageMeter = 1
		var/SuperChargeMe = 0
		outputitem = /obj/items/food/Might_Fruit

		New()
			..()
			for(var/obj/Plants/Tree_Of_Might/A in world)
				if(A != src) del(A)
		Tick()
			..()
			var/area/hopefulArea = GetArea()
			if(!isarea(hopefulArea))
				hopefulArea = hopefulArea.GetArea()
			else if(isnull(hopefulArea)) return

			if(hopefulArea.Planet=="Heaven"||hopefulArea.Planet=="Hell")
				SuperChargeMe = 1
			else SuperChargeMe = 0
		Harvest()
			var/area/a = GetArea()
			if(growthPercent>=1 && !a.planet_dying)
				harvestAmount = harvestYield * growthPercent
				while(harvestAmount)
					var/obj/items/food/Might_Fruit/A = new outputitem
					A.loc = locate(rand(x-1,x+1),rand(y-1,y+1),z)
					if(SuperChargeMe)
						A.SuperChargeMe = 1
					harvestAmount -= 1
					sleep(1)
				harvestAmount = 0
				currentstage = initialStage
				icon_state = "stage [currentstage]"
				if(!istype(a,/area/afterlifeareas))
					a.planet_dying = 1
					a.Planet_Death(AverageBP) //difference between Planet Destroy and Planet Death. The former is immediate destruction, the latter is slow destruction.
				return TRUE
			else
				return FALSE

	Yemma_Tree
		name = "Yemma Tree"
		icon = 'TreeYemma.dmi'
		desc = "This tree, named after the Judge of the Afterlife, produces a sweet fruit, which is popular among afterlife denizens."
		maxstage = 4
		growthSpeed = 0.5
		initialStage = 3
		harvestYield = 5
		gotostageMeter = 1
		outputitem = /obj/items/food/Yemma_Fruit

/*
obj/items/food/transformables
	proc/Mold()

	verb/Transform_Food()
		set hidden = 0
		set src in usr
		//future update: food you can turn into preset items with an average of 30 nutrition.
		//food can also be transformed into a 30 nutrition item with a custom icon and name.
*/

obj/items/food
	Wheat_Straw
		name = "Wheat Straw"
		icon='Misc3.dmi'
		icon_state = "Wheat"
		nutrition = 1
		flavor = "Pah! It tastes like grass! You might need to refine it to be a bit more tasty."
		verb/Refine()
			set category=null
			set src in usr
			usr << "You refine the Wheat. You get some wheat dust from it."
			usr.contents += new /obj/items/food/Wheat_Flour
			del(src)
		verb/Seed()
			set category=null
			set src in usr
			usr << "You seed the Wheat. You get some seeds from it."
			usr.contents += new /obj/items/food/Seed
			usr.contents += new /obj/items/food/Seed
			usr.contents += new /obj/items/food/Seed
			del(src)
	Wheat_Flour
		name = "Wheat Flour"
		icon='Misc3.dmi'
		icon_state = "Dust"
		nutrition = 2
		flavor = "Puh! It tastes like dry dust! You need to refine it further!"
		verb/Refine()
			set category=null
			set src in usr
			usr << "You refine the wheat dust and make food out of it."
			switch(alert(usr,"Customize the food? You can choose its name, icon, and flavor. Otherwise the default is bread.","","No","Yes"))
				if("No")
					usr.contents += new /obj/items/food/Bread
					del(src)
				if("Yes")
					var/obj/items/food/Bread/A = new /obj/items/food/Bread
					A.flavor = input(usr,"Type its flavor!",A.flavor) as text
					A.name = input(usr,"Type its name!","",A.name) as text
					A.icon = input(usr,"Choose its icon!","",A.icon) as icon
					A.icon_state = input(usr,"Icon state?","",A.icon_state) as text
					usr.contents += A
					del(src)
	Bread
		name = "Wheat Bread"
		icon='Misc3.dmi'
		icon_state = "Bread"
		flavor="Soft and chewy... this is some good wheat bread! Fills you right up too!"
		nutrition = 30
	Might_Fruit
		icon='Might Fruit.dmi'
		var/power=1
		nutrition=6
		var/SuperChargeMe = 0
		flavor="Lacking on sugars, the Might Fruit tastes more like the dryness of power. A hint of Banana too?"
		planttype = "Might"
		willspoil=0
		Eat()
			if(!usr.might)
				usr.might=1
				usr<<"You eat the Might Fruit and feel your strength miraculously increase."
				if(usr.BP<usr.relBPmax) usr.BP += usr.capcheck((usr.relBPmax/5))
				if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(5*usr.KiMod)
				usr.Ki+=(usr.MaxKi*1500)/100 //Turles had at the very least a 15x power increase from eating the Fruit from the Tree of Might.
				usr.overcharge = 1
				if(SuperChargeMe)
					usr << "The Might Fruit was grown in a Heaven or Hell biome! The power contained within skyrockets!"
					view(usr) << "[usr]'s power increases even further than fifteen times."
					usr.Ki+=(usr.MaxKi*1000)/100
					//if(usr.BP<usr.relBPmax) usr.BP += usr.capcheck((usr.relBPmax/20))
					//usr.BPadd += (usr.BP/2)
					usr.CooldownAmount+=(usr.BP/2)
					usr.PowerCooldown(usr.BP/2)
				usr.Senzu+=1
				if(usr.Senzu>=3)
					view(usr)<<"[usr] is greatly weakened by eating too many boosting food!"
					usr.SpreadDamage(25)
					usr.Ki *=0.25
			else
				usr<<"You eat it, but nothing happens."
			..()
	Apple_Of_Eden
		icon='Might Fruit.dmi'
		var/power=1
		nutrition=6
		flavor="Each bite is fruity perfection, with energy too!"
		willspoil=0
		Eat()
			spawn(10) del(src)
			if(!usr.eden)
				usr.eden=1
				usr<<"You eat the Apple of Eden and feel faster and more durable."
				//if(usr.BP<usr.relBPmax) usr.BP += usr.capcheck((usr.relBPmax/20))
				if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(3*usr.KiMod)
				usr.overcharge = 1
				usr.Ki+=(usr.MaxKi*8)
				//if(usr.Senzu>=3)
				//	view(usr)<<"[usr] is greatly weakened by eating too many boosting food!"
				//	usr.HP *=0.25
				//	usr.Ki *=0.25
			else
				usr<<"You eat the Apple of Eden and feel the energy."
				if(usr.BP<usr.relBPmax) usr.BP += usr.capcheck((usr.relBPmax/35))
				if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(1*usr.KiMod)
				usr.overcharge = 1
				usr.Ki+=(usr.MaxKi*9)
			..()
	Apple
		icon='Misc3.dmi'
		icon_state="Apple"
		var/power=1
		nutrition=6
		planttype="Apple"
		flavor="Each bite is fruity perfection."
		verb/Refine()
			set category=null
			set src in usr
			usr << "You refine the apple and make food out of it."
			view(usr)<<"[usr] refines the apple into candy!"
			switch(alert(usr,"Customize the food? You can choose its name, icon, and flavor. Otherwise the default is candy.","","No","Yes"))
				if("No")
					usr.contents += new /obj/items/food/Candy
					del(src)
				if("Yes")
					var/obj/items/food/Candy/A = new /obj/items/food/Candy
					A.flavor = input(usr,"Type its flavor!",A.flavor) as text
					A.name = input(usr,"Type its name!","",A.name) as text
					A.icon = input(usr,"Choose its icon!","",A.icon) as icon
					A.icon_state = input(usr,"Icon state?","",A.icon_state) as text
					usr.contents += A
					del(src)
	Candy
		icon='Foods.dmi'
		icon_state="Candy Cane"
		var/power=1
		nutrition=6
		flavor="Sweet to a T, it incoporates the apples natural sugars perfectly."
	Orange
		icon='Foods.dmi'
		icon_state="Orange"
		var/power=1
		nutrition=8
		planttype="Orange"
		flavor="Absurdly sour, but theres a pleasing taste within. Overall, a pretty good snack!"
		verb/Refine()
			set category=null
			set src in usr
			usr << "You refine the Orange and make food out of it."
			view(usr)<<"[usr] refines the Orange fruit into juice!"
			switch(alert(usr,"Customize the food? You can choose its name, icon, and flavor. Otherwise the default is juice.","","No","Yes"))
				if("No")
					usr.contents += new /obj/items/food/Juice
					del(src)
				if("Yes")
					var/obj/items/food/Juice/A = new /obj/items/food/Juice
					A.flavor = input(usr,"Type its flavor!",A.flavor) as text
					A.name = input(usr,"Type its name!","",A.name) as text
					A.icon = input(usr,"Choose its icon!","",A.icon) as icon
					A.icon_state = input(usr,"Icon state?","",A.icon_state) as text
					usr.contents += A
					del(src)
	Juice
		icon='Foods.dmi'
		icon_state="Juice"
		nutrition=10
		flavor="All the best parts of the flavor roll into one smooth drink. You can't get anything better than a drink like this!"

	Yemma_Fruit
		icon='Yemma Fruit.dmi'
		var/power=1
		nutrition=10
		planttype="Yemma"
		flavor="The fruit's soury bits get out of the way, but regardless they're nearly as good as apples."
		Eat()
			if(usr.yemmas<3)
				usr<<"Wow, these things taste good! You feel a bit stronger now."
				usr.yemmas+=1
				//if(usr.BP<usr.relBPmax) usr.BP += usr.capcheck((usr.relBPmax/1000))
				if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(10*usr.KiMod)
			else
				usr<<"Nothing happens... but they are a decent snack."
			..()
		verb/Refine()
			set category=null
			set src in usr
			usr << "You refine the Yemma and make food out of it."
			view(usr)<<"[usr] refines the Yemma fruit into ice cream!"
			switch(alert(usr,"Customize the food? You can choose its name, icon, and flavor. Otherwise the default is ice cream.","","No","Yes"))
				if("No")
					usr.contents += new /obj/items/food/Ice_Cream
					del(src)
				if("Yes")
					var/obj/items/food/Ice_Cream/A = new /obj/items/food/Ice_Cream
					A.flavor = input(usr,"Type its flavor!",A.flavor) as text
					A.name = input(usr,"Type its name!","",A.name) as text
					A.icon = input(usr,"Choose its icon!","",A.icon) as icon
					A.icon_state = input(usr,"Icon state?","",A.icon_state) as text
					usr.contents += A
					del(src)
	Ice_Cream
		icon='Foods.dmi'
		icon_state = "Vanilla Ice Cream"
		var/power=1
		nutrition=11
		flavor="Holy crap! The Vanilla Ice Cream flows down your throat, like a nectar of the gods! Truly life has blessed you!"
		New()
			..()
			icon_state = pick(prob(50); "Vanilla Ice Cream",prob(45); "Chocolate Ice Cream", prob(5); "Strawberry Ice Cream")
			flavor="Holy crap! The [icon_state] flows down your throat, like a nectar of the gods! Truly life has blessed you!"
		Eat()
			//if(usr.BP<usr.relBPmax) usr.BP += usr.capcheck((usr.relBPmax/1100))
			if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(2*usr.KiMod)
			..()
	Opuntia
		icon='Foods.dmi'
		icon_state = "Fruit"
		var/power=1
		nutrition=9
		planttype="Opuntia"
		flavor="The desert fruit leaves much to be desired, but you can't deny that the underlying sweetness under the hint of soury goodness doesn't have merit."

	Seed
		icon='Saiba Seed.dmi'
		flavor="You have to be frank... with some salt it'd be delicious. Without, it's just plain weird."
		New()
			..()
			nameSeed()
		proc/nameSeed()
			if(planttype) name = "[planttype] Seed"
			name = "Seed"
		verb/Plant()
			set category = null
			set src in view(1)
			var/turf/T = get_step(usr,dir)
			var/ratemod = 1+usr.FarmingSkill/25
			if(T.Water)
				usr<<"You drop the seed in the water. It sinks to the bottom. You may be forgetting a crucial element in planting..."
				del(src)
			else
				switch(planttype)
					if("Might")
						//var/area/a = GetArea()
						var/type = /obj/Plants/Tree_Of_Might
						if(locate(type) in obj_list)
							usr<<"Planting seed. It'll take a bit to grow."
							sleep(10)
							spawnExplosion(loc,null,usr.expressedBP/2,3)
							usr<<"The plant explodes!"
						else
							usr<<"Planting seed. It'll take a bit to grow."
							var/obj/Plants/Tree_Of_Might/A = new
							A.loc = locate(usr.x,usr.y,usr.z)
							A.SaveItem = 1
							A.planter = usr.signature
					if("Yemma")
						usr<<"Planting seed. It'll take a bit to grow."
						var/obj/Plants/Yemma_Tree/A = new
						A.loc = locate(usr.x,usr.y,usr.z)
						A.SaveItem = 1
						A.planter = usr.signiture
						A.growthSpeed*=ratemod
					if("Apple")
						usr<<"Planting seed."
						var/obj/Trees/AppleTree/A = new
						A.loc = locate(usr.x,usr.y,usr.z)
						A.SaveItem = 1
					if("Orange")
						usr<<"Planting seed. It'll take a bit to grow."
						var/obj/Plants/Orange/A = new
						A.loc = locate(usr.x,usr.y,usr.z)
						A.SaveItem=1
						A.planter = usr.signiture
						A.growthSpeed*=ratemod
						usr<<"Orange root planted!"
					if("Opuntia")
						usr<<"Planting seed. It'll take a bit to grow."
						var/obj/Plants/Opuntia/A = new
						A.loc = locate(usr.x,usr.y,usr.z)
						A.SaveItem=1
						A.planter = usr.signiture
						A.growthSpeed*=ratemod
						usr<<"Opuntia root planted!"
					if(null)
						var/obj/Plants/Wheat/A = new
						A.loc = locate(usr.x,usr.y,usr.z)
						A.SaveItem=1
						A.planter = usr.signiture
						A.growthSpeed*=ratemod
						usr<<"A grass grows in place of a fruit."
				AddExp(usr,/datum/mastery/Life/Farming,100)
				del(src)
		verb/Description()
			set category = null
			set src in view(1)
			usr<<"Plant a seed, and you'll grow a bit of the fruit specified. This is a [planttype] seed."
