obj/Creatables
	Virus_Synth
		icon='Lab.dmi'
		icon_state = "mod3"
		cost=75000
		neededtech=22 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="A virus synthesizer allows you to create various viruses that modify your body or those around you. Or make Anti-viruses."
		create_type = /obj/items/Virus_Synth

obj/items
	Virus_Synth
		icon='Lab.dmi'
		icon_state = "mod3"
		SaveItem = 1
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
		verb/Synthesis()
			set category = null
			set src in oview(1)
			if(!Bolted)
				usr << "You need to bolt [name] before you can use it!"
				return
			var/list/SynthList = list()
			if(usr.techskill>=75) SynthList += "Anti-Virus"
			if(usr.techskill>=65) SynthList += "Virus"
			if(usr.techskill>=25) SynthList += "Injections"
			SynthList += "Cancel"

			switch(input(usr,"What do you want to Synthesize?","","Cancel") in SynthList)
				if("Virus")
					var/list/CreateList = list()
					if(usr.techskill>=65) CreateList += "Virus Alfa"
					if(usr.techskill>=70) CreateList += "Virus Bravo"
					if(usr.techskill>=75) CreateList += "Virus Charlie"
					if(usr.techskill>=75) CreateList += "Virus Delta"
					if(usr.techskill>=80) CreateList += "Virus Echo"
					if(usr.techskill>=85) CreateList += "Virus Foxtrot"
					if(usr.techskill>=85) CreateList += "Virus Golf"
					if(usr.techskill>=90) CreateList += "Virus Hotel"
					if(usr.techskill>=90) CreateList += "Virus India"
					if(usr.techskill>=95) CreateList += "Virus Daybreaker"
					if(usr.techskill>=100) CreateList += "Virus November"
					CreateList += "Cancel"
					switch(input(usr,"What do you want to Synthesize? All viruses, unless otherwise stated, can only be taken once and are permanent. Also, taking a Virus has a small chance of making you a carrier of the Plague. Something you won't know until you die.","","Cancel") in CreateList)
						if("Virus Alfa")
							switch(input("Virus Alfa increases your intelligence to the maximum. Costs 50000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=50000)
										usr.zenni-=50000
										var/obj/A=new/obj/items/Viruses/Virus_Alfa(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Bravo")
							switch(input("Virus Bravo heals your health to the maximum, and increases defenses. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000
										var/obj/A=new/obj/items/Viruses/Virus_Bravo(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Charlie")
							switch(input("Virus Charlie brings your Ki and Stamina to the maximum, and extends stamina a little bit, and increases your KiMod a bit. Costs 50000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=50000)
										usr.zenni-=50000

										var/obj/A=new/obj/items/Viruses/Virus_Charlie(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Delta")
							switch(input("Virus Delta increases Ki regen a bit, but decreases Ki Offense a bit as well. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000

										var/obj/A=new/obj/items/Viruses/Virus_Delta(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Echo")
							switch(input("Virus Echo increases HP regen a bit, but decreases Phy Defense a bit as well. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000

										var/obj/A=new/obj/items/Viruses/Virus_Echo(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Foxtrot")
							switch(input("Virus Foxtrot increases lifespan a bunch. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000
										var/obj/A=new/obj/items/Viruses/Virus_Foxtrot(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Golf")
							switch(input("Virus Golf increases strength and speed a bit. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000
										var/obj/A=new/obj/items/Viruses/Virus_Golf(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Hotel")
							switch(input("Virus Hotel increases technique and Ki abilities a bit. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000
										var/obj/A=new/obj/items/Viruses/Virus_Hotel(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus India")
							switch(input("Virus India gives you temporary death regeneration. Costs 75000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=75000)
										usr.zenni-=75000

										var/obj/A=new/obj/items/Viruses/Virus_India(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus Daybreaker")
							switch(input("Virus Daybreaker turns people into Vampires. Costs 75000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=75000)
										usr.zenni-=75000
										var/obj/A=new/obj/items/Viruses/Virus_Daybreaker(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Virus November")
							switch(input("Gives you the ability to move in time. Costs 5000000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=5000000)
										usr.zenni-=5000000
										var/obj/A=new/obj/items/Viruses/Virus_November(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"

				if("Anti-Virus")
					var/list/CreateList = list()
					if(usr.techskill>=75) CreateList += "Anti-Virus Delta"
					if(usr.techskill>=75) CreateList += "Anti-Virus Echo"
					if(usr.techskill>=80) CreateList += "Anti-Virus Juliett"
					if(usr.techskill>=95) CreateList += "Anti-Virus Kilo"
					/*if(usr.techskill>=85) CreateList += "Anti-Virus Lima"*/
					if(usr.techskill>=90) CreateList += "Anti-Virus Mike"
					if(usr.techskill>=95) CreateList += "Anti-Virus Daybreaker"
					CreateList += "Cancel"
					switch(input(usr,"What do you want to Synthesize? Anti-Viruses can be taken multiple times. Medical ones can have side effects.","","Cancel") in CreateList)
						if("Anti-Virus Delta")
							switch(input("Cures the Delta Virus. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000

										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Delta(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Anti-Virus Echo")
							switch(input("Cures the Echo Virus. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000

										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Echo(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Anti-Virus Juliett")
							switch(input("Will eradicate a Zombie Plague, but the energy will kill your body in doing so. Costs 75000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=75000)
										usr.zenni-=75000

										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Juliett(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Anti-Virus Kilo")
							switch(input("Will completely cure you of any mutations. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000

										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Kilo(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Anti-Virus Lima")
							switch(input("Anti-Virus Lima heals some damage. Has a chance to grow back limbs. Costs 25000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000
										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Lima(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Anti-Virus Mike")
							switch(input("Anti-Virus Mike heals HP hugely, Stamina and Ki completely. Doesn't have a chance to regrow limbs. Costs 50000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=25000)
										usr.zenni-=25000
										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Mike(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
						if("Anti-Virus Daybreaker")
							switch(input("Anti-Virus Daybreaker cures vampirism. Costs 100000 zenni.","",text) in list("Yes","No",))
								if("Yes")
									if(usr.zenni>=100000)
										usr.zenni-=100000
										var/obj/A=new/obj/items/Anti_Virus/Anti_Virus_Daybreaker(locate(usr.x,usr.y,usr.z))
										A.techcost+=cost
										A.maxarmor = usr.intBPcap
										A.armor = usr.intBPcap
									else usr<<"You dont have enough money"
				if("Injections")
					usr.InjectionChoice()
	Viruses
		icon = 'Poison Injection.dmi'
		SaveItem=1
		IsntAItem=1
		stackable=1
		var/CompletelyBeneficial = 0
		verb/Consume()
			set category = null
			set src in usr
			if(usr.Race=="Android")
				usr<<"You're an android, you cannot use this."
				return FALSE
			if(usr.VirusesConsumed.len)
				if(src.type in usr.VirusesConsumed)
					usr<<"You've already consumed this virus."
					return FALSE
			if(prob(25)||usr.Mutations>=4)
				usr.Mutations+=1
				if(CompletelyBeneficial||usr.Mutations>=3)
					usr.Mutations+=1
					if(prob(25)||usr.Mutations>=5)
						usr.buudead = "force"
						view(usr)<<"[usr] begins to fucking die!!"
						spawn usr.Death()
						return FALSE
			view(usr)<<"[usr] injects a mysterious needle!"
			usr.VirusesConsumed+=src.type
			return TRUE
		Virus_Alfa
			name = "Virus Alfa"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					if(usr.techmod<4)
						usr.genome.add_to_stat("Tech Modifier",2)
						usr<<"Intelligence increased."
					else if(usr.techmod>=4)
						usr.genome.add_to_stat("Tech Modifier",1)
						usr<<"Intelligence increased."
					else if(usr.techmod>=7)
						usr<<"You seem to already be too smart for this"
					del(src)
				else return
			proc/Use(mob/M in view(1))
				if(M in usr.out_mobs || M.KO || M == usr)
					if(M.Race=="Android")
						M<<"[M]: Android, it cannot use this."
						return FALSE
					if(M.VirusesConsumed.len)
						if(src.type in M.VirusesConsumed)
							M<<"[M]: already consumed this virus."
							return FALSE
					if(prob(25))
						M.Mutations+=1
						if(CompletelyBeneficial||M.Mutations>=3)
							M.Mutations+=1
							if(prob(25) && M.Mutations>=5)
								M.buudead = "force"
								view(M)<<"[M]'s mutations overload the body, causing immediate death!"
								spawn M.Death()
								return FALSE
					view(M)<<"[M] injects a mysterious needle!"
					M.VirusesConsumed+=src.type
					if(M.techmod<4)
						M.genome.add_to_stat("Tech Modifier",2)
						usr<<"[M]: Intelligence increased."
					else if(M.techmod>=4)
						M.genome.add_to_stat("Tech Modifier",1)
						usr<<"[M]: Intelligence increased."
					else if(M.techmod>=7)
						usr<<"[M] seems to already be too smart for this"
					del(src)
				else return
		Virus_Bravo
			name = "Virus Bravo"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"Health and Defense increased."
					usr.physdefBuff += 0.15
					usr.kidefBuff += 0.15
					del(src)
				else return
		Virus_Charlie
			name = "Virus Charlie"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"Ki and Stamina increased."
					usr.maxstamina += 50
					usr.Ki = usr.MaxKi
					usr.stamina = usr.maxstamina
					usr.genome.add_to_stat("Energy Level",1)
					del(src)
				else return
		Virus_Delta
			name = "Virus Delta"
			IsntAItem=0
			cantblueprint=1
			Consume()
				if(..())
					usr<<"Ki Regen increased."
					usr.kiregenMod += 1
					usr.kidefBuff -= 1.15
					usr.kioffBuff -= 1.15
					del(src)
				else return
		Virus_Echo
			name = "Virus Echo"
			IsntAItem=0
			cantblueprint=1
			Consume()
				if(..())
					usr<<"Regeneration increased."
					usr.HPregenbuff += 2
					usr.physdefBuff -= 1.25
					del(src)
				else return
		Virus_Foxtrot
			name = "Virus Foxtrot"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"Lifespan increased."
					usr.genome.add_to_stat("Lifespan",3)
					del(src)
				else return
		Virus_Golf
			name = "Virus Golf"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"Strength and speed increased."
					usr.physoffBuff += 0.5
					usr.speedBuff += 0.5
					del(src)
				else return
		Virus_Hotel
			name = "Virus Hotel"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"Technique and Ki increased."
					usr.techniqueBuff += 0.5
					usr.kioffBuff += 0.5
					usr.kidefBuff += 0.5
					del(src)
				else return
		Virus_India
			name = "Virus India"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"Temporary death regeneration achieved. You can resurrected from 10 more deaths. Each death will weaken [src]'s effectiveness."
					usr.DeathRegenTmp = 1
					del(src)
				else return
		Virus_Daybreaker
			name = "Virus Daybreaker"
			IsntAItem=0
			cantblueprint=1
			Consume()
				if(..())
					usr<<"You've become a vampire!"
					usr.Vampirification()
					del(src)
				else return
		Virus_November
			name = "Virus November"
			IsntAItem=0
			cantblueprint=1
			CompletelyBeneficial = 1
			Consume()
				if(..())
					usr<<"You've become able to move in stopped time!"
					usr.CanMoveInFrozenTime = 1
					del(src)
				else return

	Anti_Virus
		icon = 'Antivirus.dmi'
		SaveItem=1
		IsntAItem=1
		stackable=1
		var/counterVirus = null
		verb/Consume()
			set category = null
			set src in view(1)
			if(usr.Race=="Android")
				usr<<"You're an android, you cannot use this."
				return
			view(usr)<<"[usr] consumes a mysterious object!"
			if(counterVirus)
				for(var/S in usr.VirusesConsumed)
					if(counterVirus==S)
						usr.VirusesConsumed-=S
						return TRUE
			else
				return TRUE
			return FALSE
		Anti_Virus_Delta
			IsntAItem=0
			cantblueprint=1
			counterVirus = /obj/items/Viruses/Virus_Delta
			Consume()
				if(..())
					usr<<"Ki Regen reset."
					usr.kiregenMod -= 1
					usr.kidefBuff += 1.15
					usr.kioffBuff += 1.15
					del(src)
				else return
		Anti_Virus_Echo
			IsntAItem=0
			cantblueprint=1
			counterVirus = /obj/items/Viruses/Virus_Echo
			Consume()
				if(..())
					usr<<"Regeneration increased."
					usr.HPregenbuff -= 2
					usr.physdefBuff += 1.25
					del(src)
				else return
		Anti_Virus_Juliett
			IsntAItem=0
			cantblueprint=1
			Consume()
				..()
				view(usr)<<"[usr] sacrifices [usr] to destroy every Zombie!"
				for(var/mob/npc/Enemy/Zombie/A in NPC_list)
					A.Death()
					sleep(1)
				usr.Mutations=0
				usr.Death(usr)
				del(src)
				return
		Anti_Virus_Kilo
			IsntAItem=0
			cantblueprint=1
			Consume()
				..()
				if(prob(25))
					usr << "Cure failed."
					return
				var/nummut = rand(1,3)
				usr.Mutations -= nummut
				usr.Mutations = max(usr.Mutations,0)
				usr << "[min(nummut,usr.Mutations)] mutations destroyed."
				del(src)
				return
		Anti_Virus_Lima
			IsntAItem=0
			cantblueprint=1
			Consume()
				..()
				if(!usr.Senzu)
					usr.Senzu = 4
					usr.HP = 100
					for(var/datum/Body/C in usr.body)
						if(C.health < 100||C.lopped)
							C.health = 100
							if(C.lopped)
								C.RegrowLimb()
								C.health = 100
				else usr << "You're still under the effects of a healing medicine."
				del(src)
				return
		Anti_Virus_Mike
			IsntAItem=0
			cantblueprint=1
			Consume()
				..()
				usr <<"You must stand still and cannot take damage for 10 seconds!"
				var/prevHP = usr.HP
				var/prevloc = usr.loc
				sleep(100)
				if(usr.HP>=prevHP&&usr.loc==prevloc&&!usr.KO)
					if(!usr.Senzu)
						usr.Senzu = 4
						usr.Ki = usr.MaxKi
						usr.stamina = usr.maxstamina
						usr.SpreadHeal(100)
					else usr << "You're still under the effects of a healing medicine."
					del(src)
				return
		Anti_Virus_Daybreaker
			counterVirus = "Virus Daybreaker"
			IsntAItem=0
			cantblueprint=1
			Consume()
				..()
				usr << "You've been cured of Vampirism!"
				usr.UnVampire()
				del(src)
				return
mob/var
	list/VirusesConsumed= list()