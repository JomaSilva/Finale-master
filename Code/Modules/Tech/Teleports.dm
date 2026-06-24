/*
Telepad
Teleport nullifier
telewatch
*/
obj/Creatables
	Telepad
		icon = 'Transporter Pad.dmi'
		cost=500
		neededtech=70
		desc="Telepads are slim floorbound devices that serve as bases for teleportation. They're what you need to be able to teleport effectively."
		create_type = /obj/items/Telepad
	Omniwatch
		icon = 'Transporter Watch.dmi'
		cost=500
		neededtech=50
		desc="A omni watch does really only one thing- teleport. You can teleport between other watches, or telepads. Works sorta like a Shunkan Ido teleport- it takes longer depending on the distance multiplied by Z-level. You can also wire it to speak to other watches on the same channel, and to give you clothes on clicking."
		create_type = /obj/items/Omniwatch
	Teleport_Nullifier
		icon = 'nullifier.dmi'
		icon_state = "off"
		cost=500
		neededtech=60
		desc="A localized teleport nullifier. Will prevent anyone on the same Z-Level from teleporting for about a minute or so. (This includes yourself!) Can be manually turned off, and they don't require being bolted to work."
		create_type = /obj/items/Teleport_Nullifier
var/list/teleportdest = list()
var/list/nulllist = list()
obj/items
	Teleport_Nullifier
		icon = 'nullifier.dmi'
		icon_state = "off"
		SaveItem = 1
		var/tmp/telenulon = 0
		var/telenulmdur = 1200//2 minutes, maximum dur.
		var/tmp/telenuldur = 0
		New()
			..()
			nulllist += src
			spawn Ticker()
		Del()
			nulllist -= src
			..()
		Click()
			set waitfor = 0
			if(telenulon)
				telenulon = 0
				telenuldur = 0
				view(src) << "[src] turned off!!!"
			else
				telenulon = 1
				view(src) << "[src] turned on!!!"
				telenulmdur = min(100 * round(log(8,usr.techskill)),10)
		proc/Ticker()
			set background = 1
			set waitfor = 0
			if(telenulon)
				telenuldur -= 1
				if(telenuldur <=0)
					telenulon=0
					telenuldur=0
					view(src) << "[src] turned off!!!"
			sleep(1)
			spawn Ticker()
	Omniwatch
		icon = 'Transporter Watch.dmi'
		SaveItem = 1
		var/omnichannel = 0
		var/mastersig = 0
		var/isdnaonly = 0
		var/icon/storedclothesicon = 'Clothes Helmet.dmi'
		New()
			..()
			teleportdest += src
		Del()
			teleportdest -= src
			..()
		verb/Set()
			set category = null
			set src in usr
			if(isdnaonly == 1 && mastersig != usr.signature)
				view(5) << "[src] explodes!"
				del(src)
				return
			else omnichannel = input(usr,"Set the channel.","",omnichannel) as text
		verb/Name()
			set category = null
			set src in usr
			name = input(usr,"Name?","",name) as text
		verb/DNA_Authentication()
			set category = null
			set src in usr
			if(isdnaonly == 1 && mastersig != usr.signature)
				view(5) << "[src] explodes!"
				del(src)
			else
				isdnaonly = 1
				mastersig = usr.signature
		Click()
			switch(input(usr,"Watch Interface:","Watch Options","Done") in list("Done","Teleport","Speak","Henshin!","Henshin Icon"))
				if("Teleport")
					if(isdnaonly == 1 && mastersig != usr.signature)
						view(5) << "[src] explodes!"
						del(src)
						return
					else
						var/telecheck = 0
						for(var/obj/items/Teleport_Nullifier/Tn in nulllist)
							if(Tn.z == usr.z && Tn.telenulon)
								usr << "Teleport failed!"
								telecheck = 1
								break
						if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) telecheck = 1
						if(telecheck) return
						var/list/teleportlist = list()
						for(var/obj/items/I in teleportdest)
							if(istype(I, /obj/items/Omniwatch))
								var/obj/items/Omniwatch/nI = I
								if(nI.omnichannel == omnichannel) teleportlist += nI
							if(istype(I, /obj/items/Telepad))
								var/obj/items/Telepad/nI = I
								if(nI.telechannel == omnichannel && nI.Bolted && nI.x && nI.y && nI.z) teleportlist += nI
						var/obj/items/choice = input(usr,"Select the destination.") as null|anything in teleportlist
						if(isobj(choice))
							usr.updateOverlay(/obj/overlay/effects/flickeffects/teleeffect)
							sleep(20)
							usr.removeOverlay(/obj/overlay/effects/flickeffects/teleeffect)
							if(!isnull(choice))
								if(isturf(choice.loc))
									usr.loc = locate(choice.x,choice.y,choice.z)
								else if(ismob(choice.loc))
									var/mob/nM = choice.loc
									usr.loc = locate(nM.x,nM.y,nM.z)
								else if(isobj(choice.loc))
									var/obj/oj = choice.loc
									if(isturf(oj.loc))
										var/obj/nM = choice.loc
										usr.loc = locate(nM.x,nM.y,nM.z)
									else usr<<"[src]: Failed teleport!"
								else usr<<"[src]: Failed teleport!"
								usr.emit_Sound('Instant_Pop.wav')
				if("Speak")
					if(!usr.KO)
						var/msg = input(usr,"Message","Message") as text
						for(var/obj/O)
							if(istype(O,/obj/items/Omniwatch))
								var/obj/items/Omniwatch/nO = O
								if(ismob(nO.loc)&&omnichannel==nO.omnichannel)
									var/mob/M = nO.loc
									M<<"(Watch)<[usr.SayColor]>[usr] says, '[msg]'"
							if(istype(O,/obj/items/Communicator))
								var/obj/items/Communicator/nO = O
								if(omnichannel in nO.freqlist)
									nO.messagelist+={"<html><head><title></title></head><body><body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>(Watch)<[usr.SayColor]>[usr] says, '[msg]'</font><br></body><html>"}
									if(nO.hasbroadcaster) view(nO) << "(Watch)<[usr.SayColor]>[usr] says, '[msg]'"
				if("Henshin!")
					for(var/mob/M in view(usr))
						var/msg = "Transform!!"
						M<<output("<font size=[M.TextSize]><[usr.SayColor]>[usr.name] shouts, '[html_encode(msg)]'","Chatpane.Chat")
					usr.updateOverlay(/obj/overlay/effects/flickeffects/henshineffect)
					if(usr.HasOverlay(/obj/overlay/clothes/henshin)) usr.removeOverlay(/obj/overlay/clothes/henshin)
					else usr.updateOverlay(/obj/overlay/clothes/henshin,storedclothesicon)
					sleep(20)
					usr.removeOverlay(/obj/overlay/effects/flickeffects/henshineffect)
				if("Henshin Icon")
					usr.removeOverlay(/obj/overlay/clothes/henshin)
					storedclothesicon = input(usr,"Pick some clothing.","Pick a icon.",'Clothes Helmet.dmi') as icon
					pixel_x = input(usr,"Pixel X","",pixel_x) as num
					pixel_y = input(usr,"Pixel Y","",pixel_y) as num


	Telepad
		icon = 'Transporter Pad.dmi'
		SaveItem = 1
		var/telechannel = 0
		New()
			..()
			teleportdest += src
		Del()
			teleportdest -= src
			..()
		verb/Name()
			set category = null
			set src in usr
			name = input(usr,"Name?","",name) as text
		verb/Set()
			set category = null
			set src in oview(1)
			telechannel = input(usr,"Set the teleport channel.") as text
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
		Click()
			maxarmor = usr.intBPcap
			healDamage(maxarmor)
			usr << "Telepad upgraded!"

obj/overlay/effects/flickeffects/teleeffect
	icon = 'sparkleblast.dmi'
	effectduration = 30
	ID = 37812

obj/overlay/clothes/henshin
	icon = 'Clothes Helmet.dmi'
	ID = 37813
obj/overlay/effects/flickeffects/henshineffect
	effectduration = 30
	ID = 37814
	icon = 'windeffect.dmi'