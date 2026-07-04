mob/verb/Set_Contact()
	set category=null
	set src in view(10)
	usr.known_contact_list["[signature]"] = contact_list["[signature]"]

mob/proc/update_my_contact()
	if(isnull(contact_list["[signature]"]))
		var/obj/Contact/A=new/obj/Contact
		contact_list["[signature]"] = A
		A.name="[name] ([displaykey])"
		A.signature = "[signature]"
		A.overlays = overlays
		for(var/bc in vis_contents)
			sleep(1)
			A.overlays += bc
		A.icon = icon
		A.c_race = Race
		A.c_class = Class
		A.c_gender = pgender
		A.c_age = round(Age)
		A.last_snap = world.time
		A.portrait_ver++
		A.portrait_cache = null
	else
		var/obj/Contact/A=contact_list["[signature]"]
		if(world.time < A.last_snap + 600) return //re-fotografa no maximo 1x/min (a proximidade chama isto direto)
		A.name="[name] ([displaykey])"
		A.overlays = overlays
		for(var/bc in vis_contents)
			sleep(1)
			A.overlays += bc
		A.icon = icon
		A.c_race = Race
		A.c_class = Class
		A.c_gender = pgender
		A.c_age = round(Age)
		A.last_snap = world.time
		A.portrait_ver++ //a "foto" mudou: invalida o retrato e o cache de envio dos clients
		A.portrait_cache = null

//RETRATO "como visto da ultima vez": achata o snapshot do Contact (icone + overlays) num /icon
//pra aba People (HTML). Cache invalidado quando o update_my_contact re-fotografa.
proc/contact_portrait(obj/Contact/A)
	if(!istype(A)) return null
	if(A.portrait_cache) return A.portrait_cache
	var/icon/P
	if(A.icon) P = new(A.icon, "", SOUTH, 1)
	else return null
	for(var/o in A.overlays) //entradas de overlays sao appearances: le-se icon/icon_state via cast de image
		var/image/im = o
		if(!im || !im.icon) continue
		var/icon/OI = new(im.icon, "[im.icon_state]", SOUTH, 1)
		P.Blend(OI, ICON_OVERLAY)
	P.Scale(64, 64)
	A.portrait_cache = P
	return P

//envia o retrato pro client (1x por versao da foto; nome do arquivo = ct<signature>.png)
client/var/list/ct_rsc_ver = null
mob/proc/ui_people_rsc(obj/Contact/c)
	if(!client || !istype(c)) return 0
	var/icon/P = contact_portrait(c)
	if(!P) return 0
	if(!islist(client.ct_rsc_ver)) client.ct_rsc_ver = list()
	if(client.ct_rsc_ver["[c.signature]"] != "[c.portrait_ver]")
		client.ct_rsc_ver["[c.signature]"] = "[c.portrait_ver]"
		src << browse_rsc(P, "ct[c.signature].png")
	return 1

mob/proc/check_relation(var/mob/M,list/L)
	if(isnull(known_contact_list["[M.signature]"])) return FALSE
	else
		var/obj/Contact/O = known_contact_list["[M.signature]"]
		if(O.relation["[M.signature]"] in L) return TRUE

mob/proc/check_familiarity(var/mob/M)
	if(isnull(known_contact_list["[M.signature]"])) return FALSE
	else
		var/obj/Contact/O = known_contact_list["[M.signature]"]
		return O.familiarity["[M.signature]"]

mob/proc/add_familiarity(var/mob/M)
	if(isnull(contact_list["[M.signature]"])) return FALSE
	else
		var/obj/Contact/O = contact_list["[M.signature]"]
		known_contact_list["[M.signature]"] = O
		O.familiarity["[M.signature]"]++
		spawn(0) M.update_my_contact() //refresh their "as last seen" snapshot in the background
		return TRUE

mob/var/list/known_contact_list =list()
var/list/contact_list = list()

obj/Contact
	var/list/familiarity=list()
	var/list/relation=list()
	var/signature=""
	var/c_race = "?" //basic-info snapshot, refreshed by update_my_contact()
	var/c_class = "?"
	var/c_gender = "?"
	var/c_age = 0
	var/portrait_ver = 0            //versao da "foto" (bump a cada re-fotografada; controla o re-envio pros clients)
	var/tmp/icon/portrait_cache = null //retrato achatado (icone+overlays) da ULTIMA vez visto -- cache de servidor
	var/tmp/last_snap = 0           //world.time da ultima re-fotografada (a proximidade re-chama; max 1x/min)
	canGrab=0
	IsntAItem = 1
	New()
		..()
		obj_list -= src
		if(ismob(loc)) del(src)
		if(signature != "") contact_list["[signature]"] = src
	verb/Delete()
		set category=null
		usr.known_contact_list -= src
	verb/Relation()
		set category=null
		switch(input(usr,"What's your relation? Rival requires 15 familiarity. Good requires 50. Bad requires 10. Very Good requires 100. Very Bad requires 20. Love requires 200. Hate requires 50.") in list("Love","Very Good","Good","Rival/Good","Rival/Bad","Neutral","Bad","Very Bad","Hate"))
			if("Neutral")
				relation["[usr.signature]"]="Neutral"
			if("Rival/Bad")
				if(familiarity["[usr.signature]"]>=15)
					relation["[usr.signature]"]="Rival/Bad"
				else to_chat(usr, "You need 15 or more familiarity")
			if("Rival/Good")
				if(familiarity["[usr.signature]"]>=15)
					relation["[usr.signature]"]="Rival/Good"
				else to_chat(usr, "You need 15 or more familiarity")
			if("Good")
				if(familiarity["[usr.signature]"]>=50)
					relation["[usr.signature]"]="Good"
				else to_chat(usr, "You need 50 or more familiarity")
			if("Bad")
				if(familiarity["[usr.signature]"]>=10)
					relation["[usr.signature]"]="Bad"
				else to_chat(usr, "You need 10 or more familiarity")
			if("Very Good")
				if(familiarity["[usr.signature]"]>=100)
					relation["[usr.signature]"]="Very Good"
				else to_chat(usr, "You need 100 or more familiarity")
			if("Very Bad")
				if(familiarity["[usr.signature]"]>=20)
					relation["[usr.signature]"]="Very Bad"
				else to_chat(usr, "You need 20 or more familiarity")
			if("Love")
				if(familiarity["[usr.signature]"]>=200)
					relation["[usr.signature]"]="Love"
				else to_chat(usr, "You need 200 or more familiarity")
			if("Hate")
				if(familiarity["[usr.signature]"]>=50)
					relation["[usr.signature]"]="Hate"
				else to_chat(usr, "You need 50 or more familiarity")