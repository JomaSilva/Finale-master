//file with all the relevant variables and procs for overhauled equipment
var/list/Rarity = list("<font color=white>Common</font>","<font color=silver>Quality</font>","<font color=yellow>Rare</font>","<font color=lime>Exceptional</font>","<font color=teal>Mythical</font>","<font color=purple>Legendary</font>","<font color=red>Artifact</font>")//1-7, in order

proc/Typesof(var/list/Types)
	var/list/types=list()
	for(var/a in Types)
		types+= typesof(a) - a
	return types

proc/ItemList(var/list/Type,var/Rarity,var/Value)
	var/list/prohib = list(/obj/items/Equipment/Armor/Body,/obj/items/Equipment/Armor/Helmet,/obj/items/Equipment/Armor/Gloves,\
		/obj/items/Equipment/Armor/Boots,/obj/items/Equipment/Armor/Pants,/obj/items/Equipment/Weapon/Sword,/obj/items/Equipment/Weapon/Axe,\
		/obj/items/Equipment/Weapon/Staff,/obj/items/Equipment/Weapon/Spear,/obj/items/Equipment/Weapon/Club,/obj/items/Equipment/Weapon/Hammer,/obj/items/Equipment/Accessory)
	var/list/test = Typesof(prohib)
	var/list/Items= list()
	for(var/a in test)
		Items+=new a
	var/list/DropList=list()
	for(var/obj/items/Equipment/A in Items)
		if(Type)
			for(var/b in Type)
				if(istype(A,b))
					if(!Rarity||(A.rarity<=Rarity))
						if(!Value||(A.value<=Value))
							DropList+=A
							break
		else
			if(!Rarity||(A.rarity<=Rarity))
				if(!Value||(A.value<=Value))
					DropList+=A
	return DropList

mob/var
	aslots = 4
	maxaslots = 4

/obj/items/Equipment
	plane = CLOTHES_LAYER
	SaveItem=1
	New()
		..()
		suffix = "[Rarity[rarity]]"
	var
		list/slots = list()//list of limbs needed to equip the item
		list/parentlimbs = list()//list of limbs the item is equipped to
		list/itemstats = list()
		slotcost = 1//how many slots per limb
		displayed = 1//does the item's overlay get added?
		rarity = 1//how rare is this item? currently 1 - 7, more can be added later
		value = 1//what is this item "worth"?
		lopped = 0//has this item's limbs been lopped?
		creatorsig = null//signature of the creator for procs
		enchantslots = 0//how many enchantments can this item hold?
		list/enchants = list()//what enchantments are on the item?
		list/enchantnames = list()//name of the effects, for descriptions


		//look, putting variables under subtypes DOES help, but with a system like this you definitely want to unify everything (for at the very least booking purposes.)
		//armor
		armored = 0//how much damage the armor reduces
		deflection = 0//how much the armor helps with dodging attacks (like D&D armor class)
		resistance = 1//what proportion of damage does the armor ignore (% damage reduction)

		//weaponstuff
		damage = 0//flat damage boost
		penetration = 0//amount of armor ignored, used if you want armor piercing but not increased damage
		accuracy = 0//how does this modify your chance to hit?
		speed = 1//how much does this affect attacks
		wtype = ""//what type of weapon? used for skills
		block = 0
		list/proceffects = list()//used for on-hit procs



	verb/Description()
		set category = null
		set src in usr
		usr<<"<font color=white>This item possesses the following attributes:</font>"
		usr<<"<font color=white>[name]</font>"
		if(desc)
			usr<<"<font color=white>[desc]</font>"
		usr<<"<font color=white>This item is [Rarity[rarity]], and its value is [value].</font>"
		if(!equipped)
			usr<<"<font color=white>Equips to:</font>"
			if(!slots)usr<<"<font color=white>Accessory</font>"
			for(var/A in slots)
				switch(A)
					if(/datum/Body/Head/Brain)
						usr<<"<font color=white>Brain</font>"
					if(/datum/Body/Head)
						usr<<"<font color=white>Head</font>"
					if(/datum/Body/Torso)
						usr<<"<font color=white>Torso</font>"
					if(/datum/Body/Abdomen)
						usr<<"<font color=white>Abdomen</font>"
					if(/datum/Body/Organs)
						usr<<"<font color=white>Organs</font>"
					if(/datum/Body/Reproductive_Organs)
						usr<<"<font color=white>Reproductive Organs</font>"
					if(/datum/Body/Arm/Hand)
						usr<<"<font color=white>Hand</font>"
					if(/datum/Body/Arm)
						usr<<"<font color=white>Arm</font>"
					if(/datum/Body/Leg/Foot)
						usr<<"<font color=white>Foot</font>"
					if(/datum/Body/Leg)
						usr<<"<font color=white>Leg</font>"
		else
			usr<<"<font color=white>Is equipped to:</font>"
			if(!slots)usr<<"<font color=white>Accessory</font>"
			for(var/datum/Body/B in parentlimbs)
				usr<<"<font color=white>[B.name]</font>"

	verb/Display()
		set category = null
		set src in usr
		switch(alert(usr,"Do you want this item to display on your character?","","Yes","No"))
			if("Yes")
				if(!displayed)
					usr.overlayList+=src
					usr.overlaychanged=1
				displayed = 1
			if("No")
				if(displayed)
					usr.overlayList-=src
					usr.overlaychanged=1
				displayed = 0

	verb/Equip()
		set category = null
		set src in usr
		src.Wear(usr)

	proc/StatUpdate()
		return

	proc/Wear(var/mob/M)
		var/mob/wearer
		if(M)
			wearer=M
		else
			wearer=usr
		if(!equipped)
			var/list/limbs = list()
			var/limbcheck = 0
			if(src.slots.len>=1)//non-accessory equips
				for(var/S in src.slots)
					for(var/datum/Body/L in wearer.body)
						if(L.type == S&&!L.checked&&!L.lopped)
							if(istype(src,/obj/items/Equipment/Armor))
								if(L.eslots>=slotcost)
									limbs+=L
									limbcheck++
									L.checked+=1
									break
							else if(istype(src,/obj/items/Equipment/Weapon))
								if(L.wslots>=slotcost)
									limbs+=L
									limbcheck++
									L.checked+=2
									break
				if(limbcheck>=slots.len)
					for(var/datum/Body/E in limbs)
						if(E.checked == 1)
							E.eslots-=slotcost
						else if(E.checked == 2)
							E.wslots-=slotcost
						parentlimbs+=E
						E.Equipment+=src
						E.checked = 0
					wearer<<"You equip [src.name]!"
					equip(wearer)
				else
					for(var/datum/Body/E in limbs)
						E.checked = 0
					wearer<<"You do not have enough room to equip this item."
			else
				if(wearer.aslots>=slotcost)
					wearer.aslots-=slotcost
					wearer<<"You equip [src.name]!"
					equip(wearer)
		else
			unequip(wearer)
			if(parentlimbs.len>=1)
				for(var/datum/Body/U in parentlimbs)
					for(var/datum/Body/L in wearer.body)
						if(L == U)
							if(istype(src,/obj/items/Equipment/Armor))
								L.eslots+=slotcost
							else if(istype(src,/obj/items/Equipment/Weapon))
								L.wslots+=slotcost
							parentlimbs-=L
							L.Equipment-=src
			else
				wearer.aslots+=slotcost
			wearer<<"You unequip [src.name]!"



	proc/equip(var/mob/M)//this is where stat manipulation happens, we have the limbs in the parentlimb list so we can manipulate directly
		equipped=1
		icon_state=""
		if(displayed)
			M.overlayList+=src
			M.overlaychanged=1

	proc/unequip(var/mob/M)
		equipped=0
		if(displayed)
			M.overlayList-=src
			M.overlaychanged=1

	proc/lopequip(var/datum/Body/L)//for equipping after a lop
		return

	proc/lopunequip(var/datum/Body/L)//for unequipping after a lop
		return

/obj/items/Equipment/Armor
	Description()
		..()
		usr<<"<font color=white>It provides:</font>"
		if(armored)
			usr<<"<font color=white>[armored] Armor</font>"
		if(resistance!=1)
			usr<<"<font color=white>[resistance] Resistance</font>"
		if(deflection)
			usr<<"<font color=white>[deflection] Deflection</font>"
	equip(var/mob/M)
		..()
		for(var/datum/Body/L in parentlimbs)
			L.armor+=armored
			L.resistance*=resistance
		M.deflection+=deflection

	unequip(var/mob/M)
		..()
		for(var/datum/Body/L in parentlimbs)
			if(!L.lopped)
				L.armor-=armored
				L.resistance/=resistance
		if(!lopped)
			M.deflection-=deflection

	lopequip(var/datum/Body/L)//for equipping after a lop
		L.armor+=armored
		L.resistance*=resistance
		var/check=0
		for(var/datum/Body/R in parentlimbs)
			if(!R.lopped)
				check++
		if(check==1)
			lopped=0
			L.savant.deflection+=deflection

	lopunequip(var/datum/Body/L)//for unequipping after a lop
		L.armor-=armored
		L.resistance/=resistance
		var/check=0
		for(var/datum/Body/R in parentlimbs)
			if(!R.lopped)
				check++
		if(!check)
			lopped=1
			L.savant.deflection-=deflection

/obj/items/Equipment/Weapon
	plane = HAT_LAYER+1

	Description()
		..()
		usr<<"<font color=white>It is a [wtype].</font>"
		if(damage)
			usr<<"<font color=white>It deals [damage] damage.</font>"
		if(penetration)
			usr<<"<font color=white>It ignores [penetration] armor.</font>"
		if(accuracy)
			usr<<"<font color=white>It modifies accuracy by [accuracy].</font>"
		if(speed!=1)
			usr<<"<font color=white>It changes your attack delay by [speed*100]%</font>"
		if(block)
			usr<<"<font color=white>It modifies your block by [block].</font>"

	equip(var/mob/M)
		..()
		M.DamageTypes["Physical"] = (M.DamageTypes["Physical"]+damage)
		M.penetration+=penetration
		M.accuracy+=accuracy
		M.hitspeedMod*=speed
		M.block+=block
		if(wtype!="Shield")
			M.weaponeq+=1
		M.WeaponEQ+=wtype
		if(slots.len==2)
			M.twohanding=1
		if(M.weaponeq>0)
			M.unarmed=0
		for(var/e in proceffects)
			M.AddEffect(enchantlist[e],,proceffects[e])

	unequip(var/mob/M)
		..()
		if(!lopped)
			M.DamageTypes["Physical"] = (M.DamageTypes["Physical"]-damage)
			M.penetration-=penetration
			M.accuracy-=accuracy
			M.hitspeedMod/=speed
			M.block-=block
			if(wtype!="Shield")
				M.weaponeq-=1
			M.WeaponEQ-=wtype
			if(slots.len==2)
				M.twohanding=0
			if(M.weaponeq==0)
				M.unarmed = 1
		for(var/e in proceffects)
			M.RemoveEffect(enchantlist[e],,proceffects[e])

	lopequip(var/datum/Body/L)//for equipping after a lop
		var/check=0
		for(var/datum/Body/R in parentlimbs)
			if(!R.lopped)
				check++
		if(check>=parentlimbs.len&&lopped)
			lopped=0
			L.savant.DamageTypes["Physical"] = (L.savant.DamageTypes["Physical"]+damage)
			L.savant.penetration+=penetration
			L.savant.accuracy+=accuracy
			L.savant.hitspeedMod*=speed
			L.savant.block+=block
			if(wtype!="Shield")
				L.savant.weaponeq+=1
			L.savant.WeaponEQ+=wtype
			if(slots.len==2)
				L.savant.twohanding=1
			if(L.savant.weaponeq>0)
				L.savant.unarmed=0

	lopunequip(var/datum/Body/L)//for unequipping after a lop
		var/check=0
		for(var/datum/Body/R in parentlimbs)
			if(!R.lopped)
				check++
		if(!check&&!lopped)
			lopped=1
			L.savant.DamageTypes["Physical"] = (L.savant.DamageTypes["Physical"]-damage)
			L.savant.penetration-=penetration
			L.savant.accuracy-=accuracy
			L.savant.hitspeedMod/=speed
			L.savant.block-=block
			if(wtype!="Shield")
				L.savant.weaponeq-=1
			L.savant.WeaponEQ-=wtype
			if(slots.len==2)
				L.savant.twohanding=0
			if(L.savant.weaponeq==0)
				L.savant.unarmed=1

mob/proc/Check_Equipment()
	deflection = 0
	damage = 0
	penetration = 0
	accuracy = 0
	hitspeedMod = 1
	block=0
	weaponeq=0
	WeaponEQ.Cut()
	for(var/datum/Body/L in body)
		L.eslots = initial(L.eslots)
		L.wslots = initial(L.wslots)
	for(var/obj/items/Equipment/O in contents)
		var/check=0
		for(var/datum/Body/R in O.parentlimbs)
			R.armor = 0
			R.resistance =1
			R.eslots-=O.slotcost
			if(!R.lopped)
				check = 1
				R.armor+=O.armored
				R.resistance*=O.resistance
			else
				check = 0
		if(check) //if anything is lopped, check will be 0 anyways. No parent limbs? Nothing is touched.
			damage+=O.damage
			penetration+=O.penetration
			accuracy+=O.accuracy
			hitspeedMod*=O.speed
			block+=O.block
			if(O.wtype!="")
				weaponeq+=1
				WeaponEQ+=O.wtype
			deflection+=O.deflection

//incomplete, will essentially make sure all character variables are not fucked.
obj/items/Equipment/Accessory

	equip(var/mob/M)
		..()

	unequip(var/mob/M)
		..()
