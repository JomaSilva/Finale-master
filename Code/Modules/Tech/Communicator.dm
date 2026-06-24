/obj/Creatables
	Communicator
		icon = 'Computer.dmi'
		icon_state = "Computer"
		cost=100000
		neededtech=25
		desc = "A master communicator is capable of recieving messages from all machines capable of sending them, on multiple frequencies."
		create_type = /obj/items/Communicator

/obj/items/Communicator
	name = "Master Communicator"
	icon = 'Computer.dmi'
	icon_state = "Computer"
	SaveItem=1
	pixel_x = -16
	density = 1
	var/list/freqlist = list()
	var/list/messagelist = {"<html>
<head><title>Communicator</title></head><body>
<body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>
</body><html>"}
	var/hasbroadcaster
	var/megaphone
	var/megaphonecooldown
	var/canmegaphone=1
	var/hascamera=0
	var/cooldownstack
	var/cooldowndown
	var/siglock
	New()
		..()
		spawn Ticker()
	proc/Ticker()
		set waitfor=0
		if(megaphone)
			if(megaphonecooldown)
				megaphonecooldown -= 1
				megaphonecooldown = max(0,megaphonecooldown)
				if(megaphonecooldown == 0)
					canmegaphone = 1
			if(cooldowndown&&canmegaphone)
				cooldowndown -= 1
				if(cooldowndown == 0)
					cooldownstack -= 1
					if(cooldownstack >= 1) cooldowndown = 600
					cooldownstack = max(0,cooldownstack)
				cooldownstack = max(0,cooldowndown)
		spawn(1) Ticker()
	verb/Upgrades()
		set category=null
		set src in oview(1)
		var/list/CreateList = list()
		if(usr.techskill>=35 && usr.zenni >= 100000 && !megaphone) CreateList += "Megaphone"
		if(usr.techskill>=40 && usr.zenni >= 100000 && !hasbroadcaster) CreateList += "Broadcaster"
		if(usr.techskill>=45 && usr.zenni >= 150000 && !hascamera) CreateList += "Camera"
		CreateList += "Cancel"
		switch(input(usr,"What upgrade do you want?") in CreateList)
			if("Megaphone")
				switch(input("Megaphones can shout messages across the entire universe, but with a one minute timer whose delay increases every minute you use it. Costs 100000 zenni.","",text) in list("Yes","No",))
					if("Yes")
						if(usr.zenni>=100000)
							usr.zenni-=100000
							megaphone = 1
						else usr<<"You dont have enough money"
			if("Broadcaster")
				switch(input("The broadcaster upgrade makes messages be shouted out loud at the console. Costs 100000 zenni.","",text) in list("Yes","No",))
					if("Yes")
						if(usr.zenni>=100000)
							usr.zenni-=100000
							hasbroadcaster = 1
						else usr<<"You dont have enough money"
			if("Camera")
				switch(input("The broadcaster upgrade makes messages be shouted out loud at the console. Costs 100000 zenni.","",text) in list("Yes","No",))
					if("Yes")
						if(usr.zenni>=150000)
							usr.zenni-=150000
							hascamera = 1
						else usr<<"You dont have enough money"
	verb/Bolt()
		set category=null
		set src in oview(1)
		if(x&&y&&z&&!Bolted)
			switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
				if("Yes")
					view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
					Bolted=1
					boltersig=usr.signature
		else if(Bolted&&boltersig==usr.signature)
			switch(input("Unbolt?","",text) in list("Yes","No",))
				if("Yes")
					view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
					Bolted=0
	verb/Frequencies()
		set category = null
		set src in oview(1)
		switch(input(usr,"Add or remove a frequency?") in list("Add","Subtract","Check","Cancel"))
			if("Add")
				freqlist.Add(input(usr,"Type a frequency") as text)
			if("Subtract")
				freqlist.Cut(input(usr,"Type a frequency") as text)
			if("Check")
				for(var/A in freqlist)
					usr << "[A]"
	verb/DNA_Lock()
		set category = null
		set src in oview(1)
		if(siglock != usr.signature) return
		if(!siglock) siglock = usr.signature
		else siglock = null
	verb/Send(var/msg as text)
		set category = null
		set src in oview(1)
	//	if(siglock != usr.signature) return
		for(var/obj/O in world)
			if(istype(O,/obj/items/Omniwatch))
				var/obj/items/Omniwatch/nO = O
				if(ismob(nO.loc)&&nO.omnichannel in freqlist)
					var/mob/M = nO.loc
					M<<"(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
					return
			if(istype(O,/obj/Rocketship))
				var/obj/Rocketship/nO = O
				if(nO.channel in freqlist)
					view(nO)<<"(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
					return
			if(istype(O,/obj/items/clothes/Spacesuit))
				var/obj/items/clothes/Spacesuit/nO = O
				if(nO.suffix&&ismob(nO.loc)&&nO.channel in freqlist)
					var/mob/M = nO.loc
					M<<"(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
					return
			if(istype(O,/obj/items/Scouter))
				var/obj/items/Scouter/nO = O
				if(nO.suffix&&ismob(nO.loc)&&nO.channel in freqlist)
					var/mob/M = nO.loc
					M<<"(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
					return
			if(istype(O,/obj/Spacepod))
				var/obj/Spacepod/nO = O
				if(nO.link in freqlist)
					view(O)<<"(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
					return
			if(istype(O,/obj/items/Communicator))
				var/obj/items/Communicator/nO = O
				for(var/n in freqlist)
					if(n in nO.freqlist)
						messagelist+={"<html><head><title></title></head><body><body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>(Communications)<[usr.SayColor]>[usr] says, '[msg]'</font><br></body><html>"}
						if(hasbroadcaster) view(nO) << "(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
						break
	verb/Megaphone(var/msg as text)
		set category = null
		set src in oview(1)
		if(megaphone)
			if(canmegaphone)
				canmegaphone = 0
				for(var/mob/M in player_list)
					M << "(Communications)<[usr.SayColor]>[usr] says, '[msg]'"
				cooldownstack += 1
				megaphonecooldown = 600 * cooldownstack
				cooldowndown = 600
		else
			usr << "You need the upgrade."
			return
	verb/Camera()
		set category = null
		set src in oview(1)
		if(hascamera)
			if(!siglock == usr.signature)
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
		else
			usr << "No upgrade!"
			return

	verb/Communication_History()
		set category = null
		set src in oview(1)
		if(siglock != usr.signature) return
		usr<<browse(messagelist,"window=Log;size=500x500")

	verb/Reset_View()
		set category = null
		set src in view(1)
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=usr
		usr.observingnow=0