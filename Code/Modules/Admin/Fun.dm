mob/Admin3/verb/Boot_An_Ass(mob/M in world)
	set category="Admin"
	M.Boots()

mob/proc/Boots()
	var/obj/A=new(locate(x+rand(20,-20),y+rand(20,-20),z))
	missile('boot.png',A,src)
	emit_Sound('Boot to the Head.ogg')
	view(src)<<"[src] is hit by a boot!"

mob/Admin3/verb/Boot_All_Asses()
	set category="Admin"
	for(var/mob/M in player_list)
		M.Boots()

/*
Unblockable
Has a chance to decrease the opponents ki as well because of limb damage.
Drains a static amount of the usr's ki plus an additional 10%
Moves in a zig-zag pattern to confuse targets and make it harder to dodge
*/
obj/var/deflectable=1

mob/Admin1/verb/FindItem()
	set category="Admin"
	set name = "Find Item"
	var/list/objlist = list()
	for(var/obj/A)
		if(!A.loc) continue
		objlist+=A
	var/obj/choice = input(usr,"Which item?","") as null|anything in objlist
	if(!isnull(choice))
		usr<<"Object is at [choice.x],[choice.y],[choice.z]."
mob/Admin2/verb/TeleportItem()
	set category="Admin"
	set name = "Teleport Item To Me"
	var/list/objlist = list()
	for(var/obj/A)
		if(!A.loc) continue
		objlist+=A
	var/obj/choice = input(usr,"Which item?","") as null|anything in objlist
	if(!isnull(choice))
		choice.loc = locate(x,y,z)

mob/Admin2/verb/TeleportToItem()
	set category="Admin"
	set name = "Teleport To Item"
	var/list/objlist = list()
	for(var/obj/A)
		if(!A.loc) continue
		objlist+=A
	var/obj/choice = input(usr,"Which item?","") as null|anything in objlist
	if(!isnull(choice))
		usr.loc = locate(choice.x,choice.y,choice.z)

mob/Admin3/verb/TeleportAllOfItem()
	set category="Admin"
	set name = "Teleport Items To Me"
	var/list/objlist = list()
	for(var/obj/A)
		if(!A.loc) continue
		objlist+=A
	var/obj/choice = input(usr,"Which item?","") as null|anything in objlist
	if(!isnull(choice))
		for(var/obj/A)
			if(A.type == choice.type)
				A.loc = locate(x,y,z)
mob/Admin3/verb/Toggele_April_Fools()
	set category="Admin"
	if(aprilfoolson)
		aprilfoolson = 0
		world << "AF mode off."
	else
		aprilfoolson = 1
		world << "AF mode on."