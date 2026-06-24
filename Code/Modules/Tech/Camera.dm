obj/Creatables
	Camera
		icon='PDA.dmi'
		icon_state=""
		cost=500
		neededtech=20 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Place it down, bolt it, set a frequency and you can view it from a PDA, Camera Computer, or a Master Communicator."
		create_type = /obj/items/Camera
	Camera_Computer
		icon='Computer.dmi'
		icon_state="Computer"
		cost=1500
		neededtech=20 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Can view cameras from anywhere. Needs the corrosponding camera frequency."
		create_type = /obj/items/Camera_Computer
	PDA
		icon='PDA.dmi'
		icon_state=""
		cost=400
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Same as a book, but is current year. Also, serves as a portable Bounty Computer if you upgrade it. Can also view any cameras placed."
		create_type = /obj/items/PDA

/*
**PDA Features**
You can write anything on it
You can view bounties on the Planet, and eventually across the galaxy
You can view bounty hunters on the Planet, and eventually across the galaxy
*/
var/list/GlobalLibrary
obj/items/PDA
	icon='PDA.dmi'
	stackable=0
	var/notes={"<html>
<head><title>Notes</title></head><body bgcolor="#000000"><font size=2><font color="#0099FF"></b><!-- write text between <p>, </b> to break (outside of <p>), <strong> bold, <i> italics.--></body><html>"}
	var/list/freqlist = list()
	var/DNA
	verb/Name()
		set category=null
		name=input("") as text
	verb/View()
		set category=null
		set src in view(1)
		usr<<browse(notes,"window=Notes;size=500x500")
	verb/Frequencies()
		set category = null
		set src in view(1)
		switch(input(usr,"Add or remove a frequency?") in list("Add","Subtract","Check","Cancel"))
			if("Add")
				freqlist.Add(input(usr,"Type a frequency") as text)
			if("Subtract")
				freqlist.Cut(input(usr,"Type a frequency") as text)
			if("Check")
				for(var/A in freqlist)
					usr << "[A]"
	verb/View_Cameras()
		set category = null
		set src in view(1)
		if(!DNA == usr.signature)
			usr << "Wrong signature!"
			return
		var/list/camera_list = list()
		for(var/obj/items/Camera/A in item_list)
			if(A.frequency in freqlist)
				camera_list += A
		camera_list += "Cancel"
		var/obj/items/Camera/nA = input(usr,"Select a camera","Camera","Cancel") in camera_list
		usr.client.perspective=EYE_PERSPECTIVE
		usr.client.eye=nA
	verb/Reset_View()
		set category = null
		set src in view(1)
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=usr
		usr.observingnow=0
	verb/Toggle_DNA_Lock()
		set category = null
		if(DNA)
			DNA = null
			usr << "DNA unlocked."
		else
			usr << "DNA locked"
			DNA = usr.signature
	verb/Input()
		set category=null
		notes=input(usr,"Notes","Notes",notes) as message
	verb/Upload_to_Library()
		set category=null
		var/uploads=new/list()
		for(var/obj/items/Book/B in usr.contents)
			uploads+=B
		if(isnull(uploads))
			usr<<"You have no books to upload!"
			return
		var/obj/items/Book/choice=input(usr,"You can upload a book to the global library for future generations. Choose which book you'd like to upload.","",null) as null|anything in uploads
		if(!choice)
			return
		else
			var/obj/items/Book/A = new(choice)
			A.name = choice.name
			A.book = choice.book
			GlobalLibrary[A.name] = A
	verb/Print_from_Library()
		set category=null
		var/choice=input(usr,"You can print a book from the global library. Choose which book you'd like to print.","",null) as null|anything in GlobalLibrary
		if(!choice)
			return
		else
			var/obj/items/Book/B = GlobalLibrary[choice]
			var/obj/items/Book/C = new/obj/items/Book
			C.loc = usr.loc
			C.name = B.name
			C.book = B.book
			C.SaveItem=1


obj/items/Camera
	icon='PDA.dmi'
	stackable=0
	var/frequency = 00000
	verb/Frequencies()
		set category = null
		set src in view(1)
		frequency = input(usr,"Type a frequency","Frequency","00000") as text

obj/items/Camera_Computer
	icon='PDA.dmi'
	stackable=0
	var/DNA
	var/frequency = 00000
	verb/Frequency()
		set category = null
		set src in view(1)
		frequency = input(usr,"Type a frequency","Frequency","00000") as text
	verb/Toggle_DNA_Lock()
		set category = null
		set src in view(1)
		if(DNA)
			DNA = null
			usr << "DNA unlocked."
		else
			usr << "DNA locked"
			DNA = usr.signature
	verb/View_Cameras()
		set category = null
		set src in view(1)
		if(!DNA == usr.signature)
			usr << "Wrong signature!"
			return
		var/list/camera_list = list()
		for(var/obj/items/Camera/A in item_list)
			if(A.frequency == frequency)
				camera_list += A
		camera_list += "Cancel"
		var/obj/items/Camera/nA = input(usr,"Select a camera","Camera","Cancel") in camera_list
		usr.client.perspective=EYE_PERSPECTIVE
		usr.client.eye=nA
	verb/Reset_View()
		set category = null
		set src in view(1)
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=usr
		usr.observingnow=0