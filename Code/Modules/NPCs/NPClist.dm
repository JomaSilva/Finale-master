mob
	var
		isNPC=0
		isBoss=0
		movespeed=6
		movetimer=0
		mindswappable = 1
		dummy
		tmp/sim

	Egg
		name="Egg"
		attackable=1
		monster=0
		Player=0
		KO=0
		sim=0
		Egg=1
		icon='Egg.dmi'
		BP=100
		HP=100
		Ki=1
mob/npc
	HasSoul = 0
	isNPC=1
	monster=1
	murderToggle=0
	BP_Unleechable=1
	kidef = 3
	kioff = 1
	physoff = 4
	physdef = 4
	speed = 4
	baseKi= 1000
	Ki = 1000
	technique = 4
	kiskill = 1
	GravMastered = 100
	attackable=1
	Player=0
	KO=0
	sim=0
	move=1
	var/quality=1
	var/itemrarity=0//rarity of random drops, 0 for no drops

	New()
		..()
		NPC_list += src
		if(!npcspawnson) Del()
		while(worldloading || isnull(loc))
			sleep(10)
		current_area = GetArea()
		if(current_area)
			current_area.my_npc_list |= list(src)
			current_area.my_mob_list |= list(src)
		src.contents+=mobDrops
		if(itemrarity)
			var/obj/items/Equipment/item = pick(ItemList(,itemrarity))
			item.loc = src.loc
			src.contents+= item

	Del()
		NPC_list -= src
		..()
	proc/NPCTicker()
		set waitfor=0
		set background=1
		AIRunning=1
		BP = max(BP,rand(AverageBP * 0.5 * quality,BP+AverageBP * 0.001))
		NPCAscension()

	proc/NPCAscension()
		set waitfor=0
		set background = 1
		if(BP>=1000000&&(!TurnOffAscension||AscensionAllowed))
			if(AscensionStarted)
				var/nuBPBoost
				formgain=1
				asc=1
				var/BPprog = (BP/1000000)
				var/BPascenprog = min((BPprog*ascensionmodopf),ascensionmod1) //caps at 5 million. 15 mult cap
				if(BPprog>=74) BPascenprog *= ascensionmod2 //31.875 mult cap
				if(BPprog>=150) BPascenprog *= (((BPprog - 150) / ascensionmod3) + ascensionmodtpf) //127.5 mult cap
				nuBPBoost = min(max(1,BPascenprog),BPBoostCap)
				nuBPBoost *= (GlobalBPBoost * log(ascensionascmodlg,ascBPmod))
				BPBoost = nuBPBoost
	Enemy
		AIAlwaysActive=1
		quality=2
		Zombie
			icon='Zombie.dmi'
			attackable=1
			monster=1
			Mutations = 1
			MutationImmune=1
			mindswappable=0
			HP=100
			BP=1000
			zenni=200
		Rat //food of choice for urban areas. Chance to drop seeds.
			name="Rat"
			icon='rat.dmi'
			attackable=1
			HP=100
			BP=1
			monster=1
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("nudges","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			mobDrops = list(new/obj/items/food/Seed)
			physoff = 4
			physdef = 1

		Dragon
			name="Dragon"
			icon='Dragon2.dmi'
			monster=1
			HasSoul=1
			attackable=1
			monster=1
			HP=100
			BP=105
			zenni=50
			quality=4
			GraspLimbnum=1
			Legnum=1
			attackflavors = list("slams", "claws", "burns","attacks")
			dodgeflavors = list("flys acrobatically out of the way of the attack from","dodges")
			counterflavors = list("intercepts the attack from","counters")
			physoff = 8
			physdef = 8
			movespeed = 2
			itemrarity = 2
		Wolf
			name="Wolf"
			icon='Wolf.dmi'
			attackable=1
			monster=1
			HP=100
			BP=10
			zenni=15
			GraspLimbnum=0
			Legnum=2
			quality=3
			attackflavors = list("bites", "claws", "jumps on","attacks")
			dodgeflavors = list("ducks from the attack of","dodges")
			counterflavors = list("intercepts the attack from","counters")
			mobDrops = list(new/obj/items/Clawed_Talisman)
			physoff = 4
			physdef = 4
		Dino_Munky
			name="Dino Munky"
			icon='dinomunky.dmi'
			Age=31
			SAge=31
			Body=1
			BP=100
			HP=100
			quality=3
			MaxKi=5
			Ki=5
			zenni=100
		Robot
			Race="Robot"
			icon='Gochekbots.dmi'
			icon_state="3"
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=3
			zenni=150
			movespeed=3
		Big_Robot
			Race="Robot"
			icon='Gochekbots.dmi'
			icon_state="4"
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=3
			zenni=200
			movespeed=4
		Hover_Robot
			Race="Robot"
			icon='Gochekbots.dmi'
			icon_state="5"
			attackable=1
			monster=1
			HP=100
			BP=100
			zenni=110
			movespeed=2
		Gremlin
			Race="Gremlin"
			icon='GochekMonster.dmi'
			icon_state="1"
			attackable=1
			monster=1
			HP=100
			BP=100
			zenni=110
			movespeed=2
		Saibaman
			Race="Saibaman"
			icon='Saibaman.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			zenni=120
			itemrarity=1
		Small_Saibaman
			Race="Saibaman"
			icon='Small Saiba.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			zenni=100
			itemrarity=1
		Black_Saibaman
			Race="Saibaman"
			icon='Black Saiba.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			zenni=200
			itemrarity=1
		Mutated_Saibaman
			Race="Saibaman"
			icon='Green Saibaman.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			zenni=100
			itemrarity=1
		Evil_Entity
			Race="???"
			icon='Evil Man.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=4
			zenni=160
			itemrarity=2
		Bandit
			Race="Human"
			icon='Tan Male.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=1
			zenni=100
			itemrarity=1
		Tiger_Bandit
			Race="Tiger Man"
			icon='Tiger Man.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=1
			zenni=100
			itemrarity=1
		Night_Wolf
			Race="Night Wolf"
			icon='Wolf.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=3
			zenni=100
			GraspLimbnum=0
			Legnum=2
		Giant_Robot
			Race="Robot"
			icon='Giant Robot 2.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=4
			zenni=200
		Ice_Dragon
			Race="Robot"
			icon='Ice Robot.dmi'
			attackable=1
			monster=1
			HP=100
			BP=120
			quality=4
			zenni=170
			GraspLimbnum=1
			Legnum=1
			itemrarity=1
		Ice_Flame
			Race="Creature"
			icon='Ice Monster.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=3
			zenni=150
			GraspLimbnum=0
			Legnum=0
		Afterlife_Fighter
			Race="???"
			icon='Tan Male.dmi'
			attackable=1
			monster=1
			HP=100
			BP=100
			quality=2
			zenni=110
			itemrarity=2
		Red_Robot
			icon='Giant Robot.dmi'
			Race="Mechanical Monster"
			attackable=1
			monster=1
			HP=500
			BP=500
			quality=3
			zenni=1000
		Skeleton_Knight
			name="Skeleton Night"
			icon='NPC Skeleton.dmi'
			HasSoul=1
			attackable=1
			monster=1
			HP=100
			BP=80
			zenni=50
			GraspLimbnum=2
			Legnum=2
			quality=3
			physoff = 6
			physdef = 6
			movespeed = 1
			itemrarity = 1
		Bat
			name="Bat"
			icon='Animal Bat.dmi'
			HasSoul=0
			attackable=1
			monster=1
			HP=100
			BP=5
			quality=2
			GraspLimbnum = 0
			Legnum = 0
			itemrarity = 1
		Simulation
			mindswappable=0
			sim = 1
			kidef = 6
			physoff = 6
			physdef = 6
			speed = 6
			behavior_vals = list(100,25,25,100)
			notSpawned = 0
			dropsCorpse = 0
			quality=0
			NPCTicker()
				AIRunning=1
				return //don't change sim bp.
			Click()
				..()
				if(targetmob==usr&&!client)
					del(src)
					usr<<"Simulations cancelled."
					return
			resetState()
				..()
				del(src)
	shy
		aggro_dist = 15
		AIAlwaysActive=1
		monster=0
		bunny
			name="Bunny"
			icon='bunny.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("nudges","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			mobDrops = list(new/obj/items/food/Seed)
			physoff = 4
			physdef = 2

		turtle
			name="Turtle"
			icon='Turtle.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("nudges","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			mobDrops = list(new/obj/items/clothes/turtleshell)
			physoff = 1
			physdef = 8

		Camel //Food of choice for desert areas. Chance to drop seeds.
			name="Camel"
			icon='camel.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("nudges","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			mobDrops = list(new/obj/items/food/Opuntia)
			physoff = 3
			physdef = 3

		Frog
			name="Frog"
			icon='Animal, Frog.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("ribbits the fuck outta","attacks")
			dodgeflavors = list("dodges the fuck outta","dodges")
			counterflavors = list("GOES FULL FUCKING RIBBITO MODE ON","counters")
			physoff = 1
			physdef = 1

		Cow
			name="Cow"
			icon='Animal Cow.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=4
			attackflavors = list("nudges","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			physoff = 3
			physdef = 2

		Chicken
			name="Chicken"
			icon='NPCChicken.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("pecks","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			physoff = 2
			physdef = 1

		Squirrel
			name="Sqiurrel"
			icon='NPCSquirrel.dmi'
			attackable=1
			HP=100
			BP=1
			monster=0
			zenni=5
			GraspLimbnum=0
			Legnum=2
			attackflavors = list("scratches","attacks")
			dodgeflavors = list("moves away from","dodges")
			counterflavors = list("CROSS COUNTERS","counters")
			physoff = 1
			physdef = 1