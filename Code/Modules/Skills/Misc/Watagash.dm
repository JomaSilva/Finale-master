/datum/skill/Watagashi
	skilltype = "Ki"
	name = "Watagashi"
	desc = "\"No longer will I be useless... and neither will they!\" - Anonymous. Give up your form to power up a player temporarily. Upon buff expiration or player KO, you're left vunerable."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	after_learn()
		assignverb(/mob/keyable/verb/Watagashi)
		savant<<"You can give others your body and power!"
	before_forget()
		unassignverb(/mob/keyable/verb/Watagashi)
		savant<<"You're no longer able to give up your body for somebody else to recieve power."
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Watagashi)

mob/keyable/verb/Watagashi()
	set category = "Skills"
	if(isBuffed(/obj/buff/Watagashi))
		stopbuff(/obj/buff/Watagashi)
	else startbuff(/obj/buff/Watagashi)



obj/buff/Watagashi
	name = "Watagashi"
	icon='SSJIcon.dmi'
	slot=sBUFF //which slot does this buff occupy
	var/werkd =0
	var/tmp/mob/tg_mob=null
	var/list/last_coords = list(0,0,0)
	Buff()
		var/list/mb_lst = list()
		for(var/mob/M in oview(1))
			mb_lst +=M
		mb_lst += "Cancel"
		var/mob/choice = input(usr,"Which mob?") in mb_lst
		if(ismob(choice))
			werkd=1
			last_coords = list(container.x,container.y,container.z)
			container.GotoPlanet("Sealed")
			tg_mob = choice
			tg_mob.startbuff(/obj/buff/Watagash)
		else
			werkd=0
			DeBuff()
		..()
	Loop()
		if(isnull(tg_mob)) DeBuff()
		..()
	DeBuff()
		if(werkd)
			container.loc = locate(last_coords[1],last_coords[2],last_coords[3])
			if(tg_mob) tg_mob.stopbuff(/obj/buff/Watagash)
		..()

obj/buff/Watagash
	name = "Watagash"
	icon='SSJIcon.dmi'
	slot=sBUFF //which slot does this buff occupy
	Buff()
		container.emit_Sound('deathball_charge.wav')
		container.giantFormbuff += 0.45
		container.Tphysoff+=1.1
		container.Tphysdef+=1.1
		container.Tspeed-=0.2
		var/matrix/nM = new
		container.transform = nM.Scale(2,2)
		container<<"You mysteriously increase in size and power!!"
	DeBuff()
		var/matrix/nM = new
		container.transform = nM.Scale(1,1)
		container.giantFormbuff -= 0.45
		container.Tphysoff-=1.1
		container.Tphysdef-=1.1
		container.Tspeed+=0.2
		container<<"You mysteriously decrease in size and power..."
		..()