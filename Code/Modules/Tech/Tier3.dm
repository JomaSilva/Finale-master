obj/Creatables
	Gravity
		icon='Scan Machine.dmi'
		icon_state=""
		cost=500000
		neededtech=50 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Gravitys shunt out massive amounts of force around it. The force may be harmful to you, but it makes for some excellent training grounds."
		create_type = /obj/items/Gravity
	Spacepod
		icon='Spacepod.dmi'
		icon_state=""
		cost=100000
		neededtech=40 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Spacepods allow you to fly out into space and visit other worlds."
		create_type = /obj/Spacepod
	Spacepod_Placed
		icon='Spacepod.dmi'
		icon_state=""
		cost=100000
		neededtech=999 //Deletes itself from contents if the usr doesnt have the needed tech
		var/count=0
		SaveItem=0
		desc="Spacepods allow you to fly out into space and visit other worlds."
		create_type = /obj/Spacepod
		Click()
			if(count)
				usr<<"This doesn't work anymore..."
				return
			if(..()) count++
	Nav_System
		icon='Space.dmi'
		icon_state="terminal"
		cost=550000
		neededtech=55 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Nav systems automatically collect and categorize all planets capable of hosting sentient life, along with a autopilot and Space GPS."
		create_type = /obj/items/Nav_System
	Clone_Machine
		icon='Turfs 1.dmi'
		icon_state="Healing Tank"
		cost=10000000
		neededtech=100 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Have you ever gotten old by a lot? It sucks. Well, if you use a DNA cloning device, store the device, and then use it here, you can get a younger self! Caution: Younger Self may be self-aware. Younger Self also will not have most of it's power at time of collection."
		create_type = /obj/items/Clone_Machine
		Click()
	Super_Computer
		icon='Computer.dmi'
		icon_state="Computer"
		cost=5000000
		neededtech=100 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="A super computer to deal with ALL of your robot armies!"
		create_type = /obj/Super_Computer
	Emitter
		icon='Moon2.dmi'
		icon_state="Off"
		cost=5000000
		neededtech=100 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Emits massive amounts of Blutzwaves, the phenomena, which at regular levels will drive a Saiyan into their Oozaru! This emits much, much more than that."
		create_type = /obj/items/Emitter

	Bio_Field
		icon='BioField.dmi'
		cost=750000
		neededtech=80 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="A small tower that emits specialized waves that heal everyone nearby it. (Range is 20)"
		create_type = /obj/items/Bio_Field


obj/items
	Emitter
		icon='Moon2.dmi'
		icon_state="On"
		stackable=1
		var/mooning
		verb/Activate()
			set category=null
			set src in oview(1)
			if(!mooning)
				mooning=1
				flick("Turning",src)
				icon_state="On"
				view(usr)<<"[usr] activates the emitter!"
				while(mooning)
					sleep(5)
					for(var/mob/M in view(src))
						if(M.Race=="Saiyan" && !M.transing)
							if(!M.has_Tail()) M.Tail_Grow()
							if(!M.Apeshit&&M.hasssj)
								M.GoldenApeshit()
								usr<<"You feel angry!"
								usr.canRevert=1
								spawn(200)
								if(M.expressedBP>=M.ssj4at&&M.BP>=M.rawssj4at&&!M.transing)
									M.Apeshit_Revert()
									M.SSj4()
									usr<<"You feel calmer..."
					spawn(300) del(src)
			else usr<<"It has already been activated..."
	Bio_Field
		icon='BioField.dmi'
		SaveItem=1
		density=1
		stackable=0
		New()
			..()
			spawn Ticker()
		proc/Ticker()
			set waitfor = 0
			set background = 1
			for(var/mob/M in range(20))
				if(M.HP<100)
					M.SpreadHeal(20)
					M<<"You feel healthier thanks to the bio field"
			sleep(300)
			spawn Ticker()
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Bolt this to the ground so nobody can pick it up?","",text) in list("Yes","No"))
					if("Yes")
						Bolted=1
						view(src)<<"[usr] bolts the [src] to the ground."
						boltersig=usr.signature
			else if(Bolted&&boltersig==usr.signature)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
						Bolted=0
	Equalizer_Field
		icon='BioField.dmi'
		SaveItem=1
		density=1
		stackable=0
obj/Super_Computer
	density=1
	icon = 'Computer.dmi'
	icon_state="Computer"
	name = "Super Computer"
	pixel_x=-22
	SaveItem=1
	cantblueprint=0
	canGrab = 1
	var/controller //who controls the star
	var/destroyed
	var/resurrection=0
	var/superrename=0
	verb/Encrypt() //Lets you assimilate with the computer.
		set src in oview(1)
		set category=null
		if(!controller)
			controller=input(usr,"Put in the control key. Don't forget this!","","1") as text
		else usr<<"The Super Computer has already been encrypted."
	verb/Use()
		set src in oview(1)
		set category=null
		if(!controller || controller == input(usr,"Put in the password.") as text)
			var/list/Choices=new/list
			Choices.Add("Make Body")
			Choices.Add("Mindswap")
			Choices.Add("Make Droid")
			Choices.Add("Destroy All Androids")
			Choices.Add("Decrypt")
			Choices.Add("Upgrade")
			Choices.Add("Bolt")
			Choices.Add("Cancel")
			switch(input("Choose Option","",text) in Choices)
				if("Mindswap")
					var/list/Metas=new/list
					for(var/mob/A in view(10)) if(!A.client&&!A.isNPC&&(A.displaykey==usr.displaykey||A.displaykey==usr.key)) Metas.Add(A)
					Metas += "Cancel"
					var/Choice=input("Mindswap with which?") in Metas
					for(var/mob/A in Metas) if(Choice==A)
						usr.client.MindSwap(A)
				if("Make Body")
					usr.makeCopy(4,"Android","None",/mob,1)
				if("Make Droid")
					usr.makeCopy(4,"Android","None",/mob/npc/Clone,FALSE)
				if("Destroy All Androids")
					for(var/mob/npc/Clone/A in NPC_list)
						if(!A.client) del(A)
				if("Decrypt")
					controller=null
				if("Bolt")
					if(canGrab)
						canGrab = 0
						view(src) << "[src] has been bolted."
					else
						view(src) << "[src] has been unbolted."
						canGrab = 1
				if("Upgrade")
					var/list/upgrades=new/list
					if(!superrename) upgrades.Add("Super-Rename")
					if(!resurrection) upgrades.Add("Android Resurrection")
					upgrades.Add("Repair")
					upgrades.Add("Upgrade Armor")
					upgrades.Add("Cancel")
					switch(input("Choose Option","",text) in upgrades)
						if("Super-Rename")
							if(alert(usr,"This takes 25000 zenni. You will be able to rename planets.","","Yes","No")=="Yes")
								if(usr.zenni<=25000)
									usr.zenni-=25000
									superrename=1
								else
									usr<<"You don't have enough Zenni."
									return
						if("Android Resurrection")
							if(alert(usr,"This takes 75000 zenni. You will be able to resurrect androids, or be resurrected by this computer. This is automatic, and it only happens upon death.","","Yes","No")=="Yes")
								if(usr.zenni<=75000)
									usr.zenni-=75000
									resurrection=1
								else
									usr<<"You don't have enough Zenni."
									return
						if("Repair")
							if(alert(usr,"This takes no zenni. You will be able to repair this machine.","","Yes","No")=="Yes")
								healDamage(maxarmor)
						if("Upgrade Armor")
							if(alert(usr,"This takes 50000 zenni. You will be able to upgrade this machine a bit higher than you're normally able to.","","Yes","No")=="Yes")
								if(usr.zenni<=50000)
									usr.zenni-=50000
									maxarmor = usr.intBPcap*1.2
								else
									usr<<"You don't have enough Zenni."
									return
		else
			usr<<"You do not know the encryption key."