var/Intro={"<html>
<head><title>Welcome to Dragonball Climax</head></title><body><body bgcolor="#000000"><font size=2><font color="#0099FF"><html>
<center><h1>Server Info</h1></center>
<br>
<br>
<hr>
Host: [world.host]
<br>
"}
var/WritingIntro=0
var/writingChrono=0
var/fixing=0
mob/Admin3/verb/EditIntro()
	set category="Admin"
	for(var/mob/M) if(M.Admin) M<<"[usr] is editing the intro..."
	Intro=input(usr,"Edit!","Edit Intro",Intro) as message
	for(var/mob/F) if(F.Admin) F<<"[usr] is done editing the intro..."
	SaveIntro()
	LoadIntro()
proc/SaveIntro()
	var/savefile/S=new("Intro")
	S["Intro"]<<Intro
proc/LoadIntro() if(fexists("Intro"))
	var/savefile/S=new("Intro")
	S["Intro"]>>Intro
obj/Crandal
	IsntAItem=1
mob/default
	verb/Change_Icon()
		set category = "Other"
		set name = "Change Icon"
		var/list/thinglist =list()
		thinglist+="Cancel"
		for(var/obj/O in view(usr))
			if(!O.IsntAItem)
				thinglist+=O
		for(var/mob/A in view(usr))
			thinglist+=A
		var/choice = input(usr,"Change what icon?") as null|anything in thinglist
		if(isobj(choice))
			var/obj/nO = choice
			nO.icon = input(usr,"Choose the icon. If you're wanting to change your own icon to a default one, select a dummy icon here and choose the \"Default\" option there.") as icon
			nO.icon_state = input(usr,"State?") as text
			nO.pixel_x = input(usr,"pixel x") as num
			nO.pixel_y = input(usr,"pixel y") as num
		if(ismob(choice))
			usr<<"This will only change the current form, and may not be permanent! Use 'Change Form Icon' to permanently change base forms!"
			var/mob/nM = choice //new variable declaration to hold a reference to choice.
			if(nM.client)
				if(alert(nM,"[usr] wants to change your icon. Accept?","","Yes","No")=="Yes")
					if(alert(usr,"Change [nM]'s icon to a default?","","Default","No")=="Default")
						nM.Skin()
					else
						nM.icon = input(usr,"Choose the icon.") as icon
						nM.icon_state = input(usr,"State?") as text
					view(usr)<<"[usr] changed [nM]'s icon."
				else
					view(usr)<<"[nM] denied the icon change."
			else
				nM.icon = input(usr,"Choose the icon.") as icon
				nM.icon_state = input(usr,"State?") as text
			nM.overlaychanged=1

mob/default/verb/Rename(atom/movable/A in view(usr))
	set category = "Other"
	set name = "Rename"
	if(istype(A,/obj))
		var/obj/O = A
		if(O.IsntAItem) return
	if(istype(A,/datum/skill)||istype(A,/datum/Body))
		return
	var/Change=input(usr,"What name?","Name change.",A.name) as text
	if(!Change)
		usr<<"You cannot change this to a blank name"
		return
	if(istype(A,/mob))
		var/mob/M = A
		if(M.client&&M!=usr)
			spawn switch(input(M,"[usr] wishes to change your name to [Change]", "", text) in list ("Yes","No"))
				if("Yes")
					M.name=Change
					view(usr)<<"<b>[M] accepted the rename."
				if("No")
					view(usr)<<"<b>[M] refused the rename."
					return
		else
			M.name=Change
	else A.name=Change