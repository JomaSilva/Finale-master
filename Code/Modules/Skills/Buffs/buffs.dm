obj/buff
	//parent_type = /atom
	IsntAItem=1
	//
	name = "buff"
	icon='iconless.dmi'
	var/subicon1
	var/subicon2 //storage
	var/slot=sNULL //which slot does this buff occupy
	var/inlistcheck //checks if in list
	var/mob/container //who is the guy using the object
	var/did_godki = 0
	var/list/incompatiblebuffs = list(new/obj/buff/Oozaru,new/obj/buff/Oozaru/SuperOozaru) //list of incompatible buffs. e.g. giant form + oozaru, body expand + oozaru... generally anything + oozaru. (it's also the default.)
	var/blue_effect = 0
	var/persistant = FALSE //Will this persist between login/logoff?
	Del()
		if(src in container.bufflist) DeBuff()
		..()

	emit_Sound(var/snd,volume)
		if(container)
			var/targvol
			for(var/mob/M in view(container))
				if(M.client)
					if(volume != null) targvol = M.client.clientvolume * volume
					else targvol = M.client.clientvolume
					M << sound(snd,volume=targvol)
		..()
obj/buff/proc/Buff(var/icontext, var/icontext2, var/icontext3)
	src.icon=icontext
	if(icontext2)src.subicon1=icontext2
	if(icontext3)src.subicon2=icontext3
	container.buffoutput.Insert(slot,"[name]")
	container.buffoutput.Cut((slot+1),(slot+2))
	container.bufflist.Add(src)
	if(blue_effect) godki_effector(TRUE)

obj/buff/proc/Delevel()
	DeBuff()
	return

obj/buff/proc/Loop()
	for(var/obj/buff/B in container.bufflist)
		if(istype(B,src))inlistcheck++
		else
			if(B.slot == src.slot)src.DeBuff()
	if(blue_effect) godki_effector(FALSE)
	//godki_un_effector(FALSE)
	return

obj/buff/proc/godki_effector(i)
	if(!did_godki && container?.godki.usage)
		did_godki = 1
		if(i == TRUE) do_first_godki_appearance()
		if(i == FALSE) do_godki_appearance()
		return TRUE
	return FALSE

obj/buff/proc/do_first_godki_appearance() //do godki appearance when godki'd prebuff (SSG to SSB)
	ASSERT(!isnull(container))
	container.emit_Sound('ssb.wav')
	container.updateOverlay(/obj/overlay/goblue)
	spawn
		animate(container,time=6,color=rgb(226, 243, 253))
		sleep(1)
		container.color = null

obj/buff/proc/do_godki_appearance() //do godki appearance when used midbuff (SSJ to SSB)
	ASSERT(!isnull(container))
	container.updateOverlay(/obj/overlay/goblue)
	spawn
		animate(container,time=6,color=rgb(226, 243, 253))
		sleep(1)
		container.color = null

/*
obj/buff/proc/godki_un_effector(i)
	if(did_godki && !container.godki.usage && i == FALSE)
		did_godki = 0
		un_first_godki_appearance()
		un_godki_appearance()
	return FALSE*/

obj/buff/proc/DeBuff()
	for(var/obj/buff/B in container.bufflist)
		if(istype(B,src))
			container.buffoutput.Insert(B.slot,"None")
			container.buffoutput.Cut((B.slot+1),(slot+2))
			container.bufflist.Remove(B)
			del(B)
			del(src)
			return
	container.bufflist -= src
	del(src)
	return
obj/buff/proc/Login()
	container.buffoutput.Insert(slot,"[name]")
	container.buffoutput.Cut((slot+1),(slot+2))
	container.bufflist |= src
	return
//mobhandler below

mob/var/list/bufflist = list()
mob/var/list/buffoutput = list("None","None","None")
mob/var/tmp/buffloopdelay

mob/proc/startbuff(obj/buff/B, var/icontext, var/icontext2, var/icontext3)
	var/obj/buff/nB = new B
	nB.container = src
	for(var/obj/buff/check in bufflist)
		if(nB.slot == check.slot)
			del(nB)
			return FALSE
		if(nB.type in check.incompatiblebuffs)
			del(nB)
			return FALSE
	if(!(nB in bufflist))
		nB.Buff(icontext, icontext2, icontext3)
		return TRUE
	else
		del(nB)
		return FALSE

mob/proc/stopbuff(obj/buff/B)
	for(var/obj/buff/check in bufflist)
		if(istype(check,B))
			check.DeBuff()
			return TRUE
	return FALSE

mob/proc/downbuff(obj/buff/B)
	for(var/obj/buff/check in bufflist)
		if(istype(check,B))
			check.Delevel()
			return TRUE
	return FALSE


mob/proc/clearbuffs()
	for(var/obj/buff/B in src.bufflist)
		B.DeBuff()

mob/proc/BuffLoop()
	buffloopdelay++
	if(buffloopdelay>=5)
		buffloopdelay=0
		for(var/obj/buff/B in src.bufflist) spawn if(B) B.Loop()

mob/proc/isBuffed(obj/buff/B)
	for(var/obj/buff/nB in bufflist)
		if(nB.type==B)
			return TRUE
	return FALSE

mob/verb/Clear_Buffs()
	set category = "Other"
	usr.clearbuffs()
	usr<<"Buffs Cleared"

var/trans_drain = 0.2
mob/Admin3/verb/Trans_Drain()
	set category = "Admin"
	trans_drain = input(usr,"Stamina drain mod for transformations. Default is 0.2x","Drain",trans_drain) as num
