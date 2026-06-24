mob/Admin3/verb/Reinitialize_Bodies()
	set name = "Reinitialize Bodies"
	set category="Admin"
	for(var/mob/M in mob_list)
		if(M.client)
			for(var/obj/Modules/R in M.contents)
				if(R.isequipped)
					R.unequip()
				R.remove()
				del(R)
			for(var/obj/items/Equipment/E in M.contents)
				if(E.equipped)
					E.Wear(M)
			for(var/datum/Body/X in M.body)
				del(X)
			M.TestMobParts()
			sleep(5)
			M.Generate_Droid_Parts()
	bresolveseed+=1
	usr << "body update seed = [bresolveseed]. (this means everyone who logs in whose local bresolveseed var != here will also have their parts reinitialized)"
var/bresolveseed

mob
	var
		GraspLimbnum=1
		Legnum=1
		bupdateseed
		list/body = list()

datum/Body
	parent_type = /atom/movable
	icon = 'Body Parts Bloodless.dmi'
	var
		health = 100
		maxhealth = 100
		limbstatus = ""
		symmetry_info = list(0,"", 0)
		req_parent_limb = null
		capacity = 1
		maxeslots = 1
		maxhpmod = 1
		maxwslots = 0
		eslots = 1//how many pieces of equipment can use this limb
		wslots = 0//how many weapons can this limb hold, used for hands mostly
		armor = 0//how protected is the limb?
		resistance = 1//proportion of damage ignored
		tmp/checked=0//used in equipping items
		artificial = 0
		regenerationrate = 1
		vital = 0
		lopped =0
		status = ""
		targettype = "chest" //hud selector matches up with this
		bodypartType = /obj/bodyparts/Head//what does it spawn when lopped?
		targetable = 1
		targetchance = 100
		mob/savant = null
		isnested=0
		datum/Body/parentlimb=null
		list/Equipment = list()
		healthweight = 1 //a 'weight', arms should be less important to health than your head is. higher num == more important weight, therefore will be shown in HP totals better.

	New()
		..()
		spawn
			src.savant = usr

	proc/logout()
		savant = null

	proc/login(var/mob/logger)
		savant = logger
		if(!src in savant.body)
			savant.body += src

	proc/CheckCapacity(var/number as num)
		if(isnum(number))
			if(capacity - number >= 0)
				return capacity - number
			else
				return FALSE

	proc/DamageMe(var/number as num, var/nonlethal as num, var/penetration as num)
		number -= max(armor-penetration,0)
		if(nonlethal)
			if(health - number >= 0.1*maxhealth/savant.Ewillpower)//this has to be set lower than the KO threshold, otherwise they'll never get KO'd
				health -= (number)
			else
				health = min(0.1*maxhealth/savant.Ewillpower,health)
		else
			health -= (number)
		health = max(-10,health)
		if(health <= 0 && !nonlethal)//you can't cap the lower bound of health at 0, regen will keep bringing it above the threshold if you do
			src.LopLimb()
		return lopped

	proc/HealMe(var/number as num)
		health += (number)
		health = max(1,health)
		health = min(health,maxhealth)

	proc/LopLimb(var/nestedlop)
		if(!lopped)
			if(!savant) return FALSE
			if(nestedlop) //if the lopping was because of a parent limb being removed.
				view(savant) << "[savant]'s [src] goes with it!"
			else view(savant) << "[savant]'s [src] was lopped off!"
			SpawnLop()
			lopped = 1
			health = 0
			savant.Ki-=0.2*savant.MaxKi
			savant.Ki = max(savant.Ki,0)
			status = "Missing"
			for(var/datum/Body/Z in savant.body)//rather than constantly check in the limb, I suspect this is where most of the lag comes from
				if(src==Z.parentlimb&&!Z.lopped)
					Z.LopLimb(1)
			savant.updateOverlay(/obj/overlay/effects/flickeffects/bloodspray)
			spawn(5)
			savant.removeOverlay(/obj/overlay/effects/flickeffects/bloodspray)
			spawn
				for(var/obj/Modules/M in Modules)
					M.unequip()
				for(var/obj/items/Equipment/E in Equipment)
					E.lopunequip(src)
		else return FALSE
		return TRUE
	proc/RegrowLimb()
		for(var/datum/Body/Z in savant.body)
			if(Z.status == "Missing"&&src.isnested&&Z==src.parentlimb)
				return
			if(Z.status == "Missing"&&Z.isnested==1&&src==Z.parentlimb)
				Z.RegrowLimb()
		view(savant) << "[savant]'s [src] regrew!"
		lopped = 0
		health = 0.7*maxhealth
		status = "Damaged [health]"
		spawn
			for(var/obj/Modules/M in Modules)
				M.equip()
			for(var/obj/items/Equipment/E in Equipment)
				E.lopequip(src)
	proc/SpawnLop()
		if(savant && bodypartType)
			new bodypartType(savant.loc)
	var/list/Modules = list()

mob/proc/Body_Parts()
	for(var/datum/Body/I in body)
		if(I.bodypartType)
			var/obj/bodyparts/A = new I.bodypartType
			A.dir=pick(NORTH,SOUTH,EAST,WEST)
			A.name="[src]'s [A]"
			A.loc=loc
			A.x+=rand(-8,8)
	Death()