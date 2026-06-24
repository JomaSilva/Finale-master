//placed objects that generate items

obj/Container
	var/list/Type = null//what type of items? null for any
	var/Rarity = null//up to what rarity? null for any
	var/Value = null//up to what value? null for any
	var/number = 1//how many items?
	Bolted=1
	SaveItem=0//most of these will just refresh on reboot, special ones can be hand-placed and made to save
	New()
		..()
		while(number)
			var/obj/items/Equipment/item = pick(ItemList(Type,Rarity,Value))
			item.loc=src.loc
			src.contents+= item
			number--
	Click()
		..()
		if(istype(usr,/mob))
			if(get_dist(usr,src)<=1)
				Loot()

	verb/Loot()
		set category = null
		set src in view(1)
		if(usr.inven_min>=usr.inven_max)
			usr<<"You have no room!"
			return
		if(src.contents.len<1)
			usr<<"It's empty."
			return
		var/get = input(usr,"What would you like to take?","",null) as null|anything in src.contents
		if(!get)
			return
		else
			usr.contents+=get
			src.contents-=get
	verb/Put()
		set category = null
		set src in view(1)
		var/list/items = list()
		for(var/obj/items/A in usr.contents)
			if(!A.equipped)
				items+=A
		var/put = input(usr,"What would you like to place?","",null) as null|anything in items
		if(!put)
			return
		else
			usr.contents-=put
			src.contents+=put
			if(usr.CheckInventory()==TRUE)return
			usr.inven_min--
			usr.InvenSet()

obj/Container//container list
	Chest
		name="Chest"
		icon='Turf3.dmi'
		icon_state="161"
		Rarity = 2
		New()
			number = rand(1,3)
			..()

var/globalcontainermax = 1

turf/itemspawners
	isSpecial=1
	icon=null
	Chestspawner
		containerID = /obj/Container/Chest

	var
		containerID
		containerspawncount

	proc
		spawnContainer(var/obj/Container/M)
			set background = 1
			set waitfor = 0
			if(containerspawncount>globalcontainermax)
			else
				new M(locate(rand(15,-15)+x,rand(15,-15)+y,z))
				containerspawncount+=1
		commenceSpawn()
			set background = 1
			set waitfor = 0
			spawn(10)
				if(src && istype(src,/turf/itemspawners))
					commenceSpawn()
					if(containerID)
						spawnContainer(containerID)
	New()
		..()
		sleep(10)
		while(!maploadcomplete) sleep(1)
		if(istype(src,/turf/itemspawners)) commenceSpawn()
