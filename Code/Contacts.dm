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
	else
		var/obj/Contact/A=contact_list["[signature]"]
		A.name="[name] ([displaykey])"
		A.overlays = overlays
		for(var/bc in vis_contents)
			sleep(1)
			A.overlays += bc
		A.icon = icon

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
		var/obj/Contact/O = known_contact_list["[M.signature]"]
		O.familiarity["[M.signature]"]++
		known_contact_list["[M.signature]"] = contact_list["[M.signature]"]
		return TRUE

mob/var/list/known_contact_list =list()
var/list/contact_list = list()

obj/Contact
	var/list/familiarity=list()
	var/list/relation=list()
	var/signature=""
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
				else usr<<"You need 15 or more familiarity"
			if("Rival/Good")
				if(familiarity["[usr.signature]"]>=15)
					relation["[usr.signature]"]="Rival/Good"
				else usr<<"You need 15 or more familiarity"
			if("Good")
				if(familiarity["[usr.signature]"]>=50)
					relation["[usr.signature]"]="Good"
				else usr<<"You need 50 or more familiarity"
			if("Bad")
				if(familiarity["[usr.signature]"]>=10)
					relation["[usr.signature]"]="Bad"
				else usr<<"You need 10 or more familiarity"
			if("Very Good")
				if(familiarity["[usr.signature]"]>=100)
					relation["[usr.signature]"]="Very Good"
				else usr<<"You need 100 or more familiarity"
			if("Very Bad")
				if(familiarity["[usr.signature]"]>=20)
					relation["[usr.signature]"]="Very Bad"
				else usr<<"You need 20 or more familiarity"
			if("Love")
				if(familiarity["[usr.signature]"]>=200)
					relation["[usr.signature]"]="Love"
				else usr<<"You need 200 or more familiarity"
			if("Hate")
				if(familiarity["[usr.signature]"]>=50)
					relation["[usr.signature]"]="Hate"
				else usr<<"You need 50 or more familiarity"