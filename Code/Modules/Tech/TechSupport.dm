mob
	var
		techskill = 0
		techxp = 0
		techmod=1
		techrate=0 //applies to androids, how much they are upgraded
		usedtechrate=0//variable to stop androids from gaining infinitely off of one upgrade.

		intBPcap //techskill * relBPmax * int mod / (average BP*2). 200 relBPmax 100 average 30 tech 4 int mod = 240
		intAsc = 1 //if(AscensionStarted) intBPcap = intAsc * intBPcap. where intASc = (Average BP/1 mil ^ 2) * int mod

		techup = 8

mob/proc/Check_Tech()
	set waitfor = 0
	//temp proc to just demystify stats.dm
	if(techskill<8)
		intBPcap = (relBPmax * techmod) / max((11/max(log(1.1,max(techskill,1)),1))*techmod,1)
	else
		intBPcap = (max(log(8,max(techskill,1)),1) * relBPmax * techmod) / max(log(max(techskill*techmod,1)),1)

	intBPcap = max(relBPmax * 8, intBPcap)

	if(AscensionStarted&&!TurnOffAscension) intAsc = max(min((((AverageBP*AverageBPMod)/1000000) ^ 2),400) * techmod,1)
	else intAsc = 1
	intBPcap = intAsc * intBPcap
	if(techskill<=99) techup = (8 * techMult * (techskill**2))/techmod
	if(techxp >= sqrt(2 * techskill))
		AddExp(src,/datum/mastery/Crafting/Technology,sqrt(techxp))
		techxp -= sqrt(2 * techskill)

obj/Creatables
	var/neededtech=1
	var/cost=1
	var/neededmag = 0
	var/create_type = null
	var/do_toxic_waste
	IsntAItem=1
	SaveItem=0
	New()
		..()
		suffix="[cost]z"
		if(cost==1) del(src)
	verb/Description()
		set category =null
		usr<<"[name]: [desc]"
	Click()
		if(usr.zenni>=cost)
			usr.zenni-=cost
			var/obj/A=new create_type(locate(usr.x,usr.y,usr.z))
			if(A.desc == "") A.desc = desc
			if(do_toxic_waste) new/obj/items/Toxic_Waste(usr.loc)
			A.techcost+=cost
			A.fragile = 1
			A.maxarmor = usr.intBPcap
			A.armor = usr.intBPcap
			return A
		else usr<<"You dont have enough money"
		return FALSE


	Crate
		name="Chest"
		icon='Turf3.dmi'
		desc="Chests let you store stuff in them."
		create_type= /obj/Container/Crate
		icon_state="161"
		cost=50
		neededtech=3
		SaveItem=0
obj/Container//container list
	Crate
		name="Chest"
		icon='Turf3.dmi'
		icon_state="161"
		SaveItem=1
		number=0

mob/var/list/ocontents=new/list
mob/default/verb/Colorize(obj/O in view())
	set category="Other"
	if(O.IsntAItem) return
	switch(input("Add or Subtract color?", "", text) in list ("Add", "Subtract",))
		if("Add")
			var/rred=input("How much red?") as num
			var/ggreen=input("How much green?") as num
			var/bblue=input("How much blue?") as num
			O.icon=O.icon
			O.icon+=rgb(rred,ggreen,bblue)
		if("Subtract")
			var/rred=input("How much red?") as num
			var/ggreen=input("How much green?") as num
			var/bblue=input("How much blue?") as num
			O.icon=O.icon
			O.icon-=rgb(rred,ggreen,bblue)

mob/var/tmp/targetmob=null
obj/var/Bolted
obj/var/boltersig
obj/var/IsntAItem=0
obj
	items
		fragile=1
		cantblueprint=0
		verb/Destroy()
			set category = null
			set src in view(0)
			takeDamage(usr.expressedBP/7 * usr.Ephysoff)
			if(fragile&&(armor<=usr.intBPcap||proprietor==usr.key))
				takeDamage(maxarmor)
		Research_Book
			icon='Books.dmi'
			SaveItem=1
			cantblueprint=1
			var/IntPower
			verb/Research()
				set category=null
				set src in view(1)
				AddExp(usr,/datum/mastery/Crafting/Technology,25*IntPower)
				del(src)

		Enhancer
			icon='PDA.dmi'
			SaveItem=1
			var/IntPower
			verb/Enhance(mob/M in view(1))
				set category="Skills"
				if(M.Race=="Android")
					if(M.techrate<(usr.intBPcap/1.1))
						usr<<"You upgrade [M]'s Tech Rating to [usr.intBPcap]."
						M<<"[usr] upgrades your Tech Rating to [usr.intBPcap]."
						oview(usr)<<"[usr] upgrades [M]'s Tech Rating to [usr.intBPcap], Increasing their BP and Energy levels"
						M.techrate=usr.intBPcap
						usr.techxp+=25
					else
						if(M.techrate<(usr.intBPcap))
							usr<<"[M]'s tech rating is just fine it seems. Maybe you need to learn a bit more?"
						else usr<<"You dont have the knowledge to upgrade [M], they are too advanced."
				else usr<<"They have to be an android for you to upgrade them."
obj/var/cantblueprint=1

obj/proc/CheckObjects()
	set waitfor=0
	if(isturf(loc))
	else return
	var/count
	var/list/objlist = list()
	for(var/obj/O in loc)
		count++
		objlist += O
	if(count >= 8)
		for(var/obj/O in objlist)
			if(O.IsntAItem && prob(60)) del(O)
			if(prob(70)) step_rand(O)
			sleep(2)
mob
	OnStep()
		set waitfor = 0
		..()
		if(client && prob(15))
			for(var/obj/O in orange(usr))
				O.CheckObjects()
				break

//TODO:
/*
	Bounty Computer
	Call Bounty Drone
	Ki Jammer
	turret
	ships

redo: saibaman seeds
add gravity ss13 noises.
redo: shurikens

cloning/genetics update:
Cloning Tank
DNA Container

baby update:
	modules
		Body Swap (Baby) //half done, needs implementation and testing
		Firewall //needs to be done

MODULES:

	Antigravity//Done
	Auto Repair//Done
	BP Scanner//Done
	Blast Absorb//Done
	Breath in Space//Done
	Brute//Done
	Cyber Charge//Done
	Cybernetic Armor//Done
	Drone AI
	Extendo Arm
	Force Field Module//Done
	Generator//Done
	Giant Version
	Grab Absorb//Done
	Laser Beam//Done
	Manual Absorb//Android Racial
	Overdrive//Done
	Rebuild
	Scrap Absorb//Android Racial
	Scrap Repair//Done
	Time Normalizer//Done
*/