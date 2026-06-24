obj/items/Clone_Machine
	SaveItem=1
	New()
		..()
		while(src)
			if(!Reviving) for(var/mob/A) if(A.client) if(A==Initiator&&Energy>=1&&A.dead)
				Reviving=1
				view(src)<<"[src]: Cloning session activated. Revival in [10/Speed] minutes."
				A<<"Your cloning machine has detected your fatality, it is attempting to resurrect you."
				A<<"This will take [10/Speed] minutes."
				sleep(6000/Speed)
				if(prob(50/Failure)) if(A) A<<"The cloning process failed."
				else if(A)
					A.loc=locate(x,y,z)
					A.dir=SOUTH
					view(src)<<"[src]: Cloning successful."
					A.ReviveMe()
					Reviving=0
					Energy-=1
					view(src)<<"[round((Energy/MaxEnergy)*100)]% Energy remaining."
				break
			sleep(100)
	icon='Turfs 1.dmi'
	icon_state="Healing Tank"
	layer=MOB_LAYER+1
	density=1
	var/tmp/Reviving
	var/Failure=1 //Divisor of the 50% chance of cloning failure.
	var/Speed=1 //How long it takes before cloning is completed.
	var/Health=1 //How easily the tank is destroyed.
	var/MaxHealth=1
	var/Energy=2
	var/MaxEnergy=2
	var/Encryption=1
	var/Initiator
	verb/Clone()
		set src in oview(1)
		set category=null
		if(!Reviving)
			Reviving=1
			var/list/dna_list = list()
			for(var/obj/items/dna_container/ndn in usr.contents)
				dna_list += ndn
			var/obj/items/dna_container/ndna = input(usr,"Select the DNA container.","","") as null|obj in dna_list
			if(ndna)
				view(src)<<"[src]: Cloning session activated. Clone completing in [10/Speed] minutes."
				sleep(6000/Speed)
				if(prob(50/Failure))
					view(src)<<"The cloning process failed."
					Reviving=0
				else
					view(src)<<"[src]: Cloning successful."
					Reviving=0
					var/mob/mZ = new
					mZ.loc = locate(1,1,32)
					var/pt1=num2text(rand(1,999),3)
					var/insert1=num2text(rand(50,99),2)
					var/pt2=num2text(rand(1,999),3)
					var/insert2=num2text(rand(20,30),2)
					mZ.signature=addtext(pt1,insert1,pt2,insert2)
					mZ.Parent_Race = ndna.parrace
					mZ.Father = ndna.dname
					mZ.Race = ndna.dnarace
					mZ.Class = ndna.dnaclass
					mZ.hair = ndna.hair
					mZ.icon = ndna.dicon
					mZ.name = ndna.dname + " Clone"
					mZ.needs_manual_custom = 1
					mZ.Savable=1
					mZ.move=1
					mZ.Player=0
					mZ.clone = 1
					Energy-=1
					mZ.loc = locate(src.x,src.y,src.z)
					view(src)<<"[round((Energy/MaxEnergy)*100)]% Energy remaining."
	verb/Mindswap()
		set src in oview(1)
		set category=null
		var/list/Metas=new/list
		for(var/mob/A in view(10)) if(!A.client&&!A.isNPC&&(A.displaykey==usr.displaykey||A.displaykey==usr.key)) Metas.Add(A)
		Metas += "Cancel"
		var/Choice=input("Mindswap with which?") in Metas
		for(var/mob/A in Metas) if(Choice==A)
			usr.client.MindSwap(A)
	verb/Program()
		set src in oview(1)
		set category=null
		var/Guess
		if(Password)
			Guess=input("You must know the password to reset the machine.") as text
			if(Guess!=Password)
				usr<<"Access denied."
				return
		Initiator=usr
		usr<<"Reset to clone [usr] if fatality occurs."
	verb/Info()
		set src in oview(1)
		set category=null
		usr<<"Armor: [Health*100] / [MaxHealth*100]"
		usr<<"Energy: [Energy*100] / [MaxEnergy*100]"
		usr<<"Cloning Speed: [Speed]"
		usr<<"Failure Chance: [round(50/Failure)]"
		if(Password) usr<<"Password Encryption: [Encryption]"
		usr<<"Cost to make: [techcost]z"
	verb/Upgrade()
		set src in oview(1)
		set category=null
		if(usr.KO) return
		var/cost=0
		var/list/Choices=new/list
		Choices.Add("Cancel")
		if(usr.zenni>=1000*Speed) Choices.Add("Clone Time ([1000*Speed]z)")
		if(usr.zenni>=1000*Failure) Choices.Add("Chance of Failure ([1000*Failure]z)")
		if(usr.zenni>=1000*MaxEnergy) Choices.Add("Battery Expansion ([1000*MaxEnergy]z)")
		if(usr.zenni>=100*MaxHealth) Choices.Add("Durability ([100*MaxHealth]z)")
		if(usr.zenni>=1000&&!Password) Choices.Add("Security Password (1000z)")
		if(usr.zenni>=200*Encryption&&Password) Choices.Add("Encryption ([200*Encryption]z)")
		var/A=input("Upgrade what?") in Choices
		if(A=="Cancel") return
		if(A=="Encryption ([200*Encryption]z)")
			cost=200*Encryption
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Password Encryption level increased."
			Encryption+=1
		if(A=="Security Password (1000z)")
			cost=1000
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			Password=input("Set the machine's permanent access code.") as text
			usr<<"Password set."
		if(A=="Clone Time ([1000*Speed]z)")
			cost=1000*Speed
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Clone Time decreased."
			Speed+=1
		if(A=="Chance of Failure ([1000*Failure]z)")
			cost=1000*Failure
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Clone Failure Chance decreased."
			Failure+=1
		if(A=="Battery Expansion ([1000*MaxEnergy]z)")
			cost=1000*MaxEnergy
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Energy Core expanded. Full Energy restored."
			MaxEnergy+=1
			Energy=MaxEnergy
		if(A=="Durability ([100*MaxHealth]z)")
			cost=100*MaxHealth
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Durability increased. Full Armor restored."
			MaxHealth+=1
			Health=MaxHealth
		usr<<"Cost: [cost]z"
		usr.zenni-=cost
		tech+=1
		techcost+=cost

obj/Creatables
	DNA_Container
		icon='Item, DNA Extractor.dmi'
		desc="A DNA container is used to input DNA into a cloning machine so that the person's body may be used."
		cost=100000
		create_type = /obj/items/dna_container
		neededtech=60 //Deletes itself from contents if the usr doesnt have the needed tech

obj/items
	dna_container
		name = "DNA Container"
		icon='Item, DNA Extractor.dmi'
		var/hasDNA
		var/parrace
		var/dnarace
		var/dnaclass
		var/hair
		var/dicon
		var/dname
		Click()
			if(!hasDNA)
				if(alert(usr,"Give DNA to the container?","","Yes","No")=="Yes")
					if(usr.clone)
						usr << "Can't clone a clone."
						return
					view(usr)<<"[usr] fills [src] with DNA."
					hasDNA=usr.signature
					dnarace=usr.Race
					dnaclass=usr.Class
					parrace=usr.Parent_Race
					hair = usr.hair
					dicon = usr.icon
					dname = usr.name
					suffix = "*Filled*"
					return
				else
					var/mob/cM
					for(var/mob/M in get_step(usr,usr.dir))
						if(M.client) cM = M
					if(cM && (cM.KO||alert(cM,"Give DNA to the container?","","Yes","No")=="Yes"))
						if(cM.clone)
							usr << "Can't clone a clone."
							return
						view(usr)<<"[src] is filled with [cM]'s DNA."
						hasDNA=cM.signature
						parrace=cM.Parent_Race
						dnarace=cM.Race
						dnaclass=cM.Class
						suffix = "*Filled*"
						return
			else
				usr << "Already has DNA."
				if(alert(usr,"Clear?","","Yes","no")=="Yes")
					hasDNA = 0
					parrace= 0
					dnarace= 0
					dnaclass= 0
					suffix = ""
		//could be redone later. half assed way of doing it rn -king