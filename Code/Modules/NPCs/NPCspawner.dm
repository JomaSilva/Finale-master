mob/Admin1/verb
	toggleNPCspawns()
		set category = "Admin"
		if(npcspawnson)
			world<<"NPC spawns turned off"
			npcspawnson = 0
		else
			world<<"NPC spawns turned on."
			npcspawnson = 1
	max_NPCs()
		set category = "Admin"
		globalNPCcountmax=input(usr,"choose the max # of NPCs in the game world. this affects spawn rates and does not delete existing NPCs.","") as num
	delete_all_NPCs()
		set category = "Admin"
		switch(alert(usr,"Delete essential NPCs? This will delete clones, spare bodies, and splitforms. The alternative deletes all regular NPCs except for these.","","Yes","No."))
			if("Yes")
				for(var/mob/A)
					if(!A.client)
						del(A)
			if("No.")
				for(var/mob/A)
					if(!A.client&&(A.isNPC))
						del(A)
var/globalNPCcountmax = 20 //only # self-spawned NPCs at a time. Each spawner gets only #/rarity+(other spawner rarities) mobs they can spawn per spawner.

obj/spawners
	icon=null
	invisibility=99
	enemy
		smallsaibaSpawner
			mobID=/mob/npc/Enemy/Small_Saibaman
			rarity = 2
		ratSpawner
			mobID=/mob/npc/Enemy/Rat
			rarity = 2
		dragonSpawner
			mobID=/mob/npc/Enemy/Dragon //for yo spawner of your custom creature, put in the mob id. it goes /mob/[category]/[name] after mobID=
			rarity = 20 //only 5 dragons at a time.
		wolfSpawner
			mobID=/mob/npc/Enemy/Wolf
			rarity = 10 //only 10 wolves at a time
		saibaSpawner
			mobID=/mob/npc/Enemy/Saibaman
			rarity = 5
		SkeleSpawner
			mobID=/mob/npc/Enemy/Skeleton_Knight
			rarity = 5
		batSpawner
			mobID=/mob/npc/Enemy/Bat
	friendly
		bunnySpawner
			mobID=/mob/npc/shy/bunny
			rarity = 2
		frogSpawner
			mobID=/mob/npc/shy/Frog
			rarity = 2
		camelSpawner
			mobID=/mob/npc/shy/Camel
			rarity = 2
		turtleSpawner
			mobID=/mob/npc/shy/turtle
			rarity = 2
		cowSpawner
			mobID=/mob/npc/shy/Cow
		chickenSpawner
			mobID=/mob/npc/shy/Chicken
		squirrelSpawner
			mobID=/mob/npc/shy/Squirrel

		rarity = 2

	var
		npcspawncount
		mobID
		rarity //new variable, dictates how common this NPC is. Wolves/dragons are less common than frogs/bunnies.
	proc
		spawnNPC(var/mob/M)
			set background = 1
			if(npcspawnson==0)
				return
			if(npcspawncount>(globalNPCcountmax/20)) //more mobs than max#/20? (works out to be 5) don't do shit ni&&a
			else
				if(npcspawncount>globalNPCcountmax/rarity)
					return
				for(var/obj/Planets/P in world)
					var/area/currentArea = GetArea()
					if(P.planetType == currentArea.Planet&&P.planetType in PlanetDisableList)
						return
				new M(locate(rand(15,-15)+x,rand(15,-15)+y,z))
				npcspawncount+=1
				globalNPCcount+=1
		commenceSpawn()
			set background = 1
			if(globalNPCcount>=globalNPCcountmax)
				spawn(500) commenceSpawn()
				return
			spawn(400) commenceSpawn()
			if(mobID)
				spawnNPC(mobID)
	New()
		..()///*
		sleep(500)
		while(!maploadcomplete) sleep(1)