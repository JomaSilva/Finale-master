mob/proc/InjectionChoice()
	var/list/CreateList = list()
	if(usr.techskill>=25) CreateList += "Youthenasia"
	if(usr.techskill>=30) CreateList += "LSD"
	if(usr.techskill>=35) CreateList += "RAGE"
	if(usr.techskill>=40) CreateList += "Steroids"
	if(usr.techskill>=65) CreateList += "Insta-Death"
	if(usr.techskill>=50) CreateList += "Steroids v2"
	if(usr.techskill>=70) CreateList += "RAGE v2"
	if(usr.techskill>=70) CreateList += "T-Virus Injection"
	if(usr.techskill>=30) CreateList += "Tail Injection"
	if(usr.techskill>=75) CreateList += "Shapeshifter's Cure"
	CreateList += "Cancel"
	switch(input(usr,"Injections are temporary effects with sometimes permanent consequences. All injections have a tiny chance of mutating you.","","Cancel") in CreateList)
		if("Youthenasia")
			switch(input("De-ages you, instead of extending decline. (Will turn you into a child again!) Costs 75000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=75000)
						usr.zenni-=75000

						var/obj/A=new/obj/items/Injections/Youthenasia(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("LSD")
			switch(input("LSD. Doesn't do anything real for right now, but it does give a temporary Ki and Magic boost. Costs 25000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=25000)
						usr.zenni-=25000

						var/obj/A=new/obj/items/Injections/LSD(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("RAGE")
			switch(input("Sends you into a drug-filled rage. Isn't really that strong. Costs 50000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=50000)
						usr.zenni-=50000

						var/obj/A=new/obj/items/Injections/RAGE(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("Steroids")
			switch(input("Gives you a small on-demand BP boost, at the cost of 1 year of your lifespan. Costs 50000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=50000)
						usr.zenni-=50000

						var/obj/A=new/obj/items/Injections/Steroids(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("Insta-Death")
			switch(input("Will kill you. This ensures death. Costs 25000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=25000)
						usr.zenni-=25000

						var/obj/A=new/obj/items/Injections/Insta_Death(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("Steroids v2")
			switch(input("Better version of the regular steroids. Gives you a better BP boost for a year of your lifespan. Costs 75000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=75000)
						usr.zenni-=75000
						var/obj/A=new/obj/items/Injections/Steroids_v2(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("RAGE v2")
			switch(input("Better version of RAGE. Will take a month of lifespan, but in exchange gives you better anger, a small BP boost (smaller than Steroids), and it heals you a bit. Costs 75000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=75000)
						usr.zenni-=75000
						var/obj/A=new/obj/items/Injections/RAGE_v2(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("T-Virus Injection")
			switch(input("Gives you a guarenteed mutation and death. Can be injected into KO'd opponents or creatures. Costs 100000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=100000)
						usr.zenni-=100000
						var/obj/A=new/obj/items/Injections/T_Virus_Injection(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("Tail Injection")
			switch(input("Gives tails to races that can have tails if they didn't have one. Will KO you and bring you to half health. Costs 100000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=100000)
						usr.zenni-=100000
						var/obj/A=new/obj/items/Injections/Tail_Injection(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"
		if("Shapeshifter's Cure")
			switch(input("Cures permanently shapeshifted shapeshifters. They probably won't take this willingly. Costs 150000 zenni.","",text) in list("Yes","No",))
				if("Yes")
					if(usr.zenni>=150000)
						usr.zenni-=150000
						var/obj/A=new/obj/items/Injections/Shapeshifters_Cure(locate(usr.x,usr.y,usr.z))
						A.techcost+=cost
						A.maxarmor = usr.intBPcap
						A.armor = usr.intBPcap
					else usr<<"You dont have enough money"



obj/items
	Injections
		icon = 'Item, Needle.dmi'
		stackable=1
		SaveItem=1
		IsntAItem=1
		cantblueprint=1
		verb/Consume()
			set category = null
			set src in view(1)
			if(usr.Race=="Android")
				usr<<"You're an android, you cannot use this."
				return FALSE
			if(prob(10))
				usr.Mutations+=1
			view(usr)<<"[usr] injects a mysterious needle!"
			return TRUE
		Youthenasia
			cantblueprint=1
			IsntAItem=0
			desc = "De-ages you, instead of extending decline. (Will turn you into a child again!)"
			Consume()
				if(!(..())) return
				if(usr.Age>=10) usr.Age = 10
				del(src)
				return
		LSD
			cantblueprint=1
			IsntAItem=0
			desc = "LSD. Doesn't do anything real for right now, but it does give a temporary Ki and Magic boost."
			Consume()
				if(!(..())) return
				if(prob(10))
					view(usr)<<"[usr] injects insane amounts of LSD into their system and falls over. Blood sprays from their eye sockets and their mouth foams as their body begins to fall apart. What the fuck."
					usr.KO()
					sleep(50)
					usr.Death()
					del(src)
				else
					usr.TempBuff(list("Tmagi"=1,"Tkiregen"=1),500)
					del(src)
				return
		RAGE
			cantblueprint=1
			IsntAItem=0
			desc = "Sends you into a drug-filled rage. Isn't really that strong. Can't give SSJ."
			Consume()
				if(!(..())) return
				usr.Anger =(((usr.MaxAnger-100)/2.4)+100)
				usr.anger_ssj = 0
				spawn(1000)
					if(usr) usr.anger_ssj = 1
				view(usr)<<"[usr] goes into a drug filled rage!"

				del(src)
				return
		RAGE_v2
			cantblueprint=1
			IsntAItem=0
			desc = "Better version of RAGE. Will take a month of lifespan, but in exchange gives you better anger, a small BP boost (smaller than Steroids), and it heals you a bit. Can't give SSJ."
			Consume()
				if(!(..())) return
				usr.genome.sub_to_stat("Lifespan",0.01)
				usr.Anger=(((usr.MaxAnger-100)/1.24)+100)
				usr.anger_ssj = 0
				spawn(2000)
					if(usr) usr.anger_ssj = 1
				usr.SpreadHeal(25)
				usr.BP += usr.capcheck(usr.relBPmax*(1/800))
				view(usr)<<"[usr] flies into a major drug filled rage!"

				del(src)
				return
		Steroids
			cantblueprint=1
			IsntAItem=0
			desc = "Gives you a small on-demand BP boost, at the cost of of your lifespan."
			Consume()
				if(!(..())) return
				usr.genome.sub_to_stat("Lifespan",0.01)
				usr.BP += usr.capcheck(usr.relBPmax*(1/100))
				view(usr)<<"[usr] uses a steroid!!"
				del(src)
				return
		Steroids_v2
			cantblueprint=1
			IsntAItem=0
			desc = "Better version of the regular steroids. Gives you a better BP boost for a year of your lifespan."
			Consume()
				if(!(..())) return
				usr.genome.sub_to_stat("Lifespan",0.03)
				usr.BP += usr.capcheck(usr.relBPmax*(1/50))
				view(usr)<<"[usr] uses a steroid!!"
				del(src)
				return

		Insta_Death
			cantblueprint=1
			IsntAItem=0
			desc = "Will kill you. This ensures death."
			Consume()
				Inject(usr)
			verb/Inject_Mob(var/mob/M in view(1))
				set category = null
				set src in usr
				M << "[usr] is injecting you with something!"
				var/prevHP = usr.HP
				sleep(100)
				if(usr.HP>=prevHP&&!usr.KO&&M in view(1))
					Inject(M)
			proc/Inject(var/mob/TargetMob)
				if(prob(10))
					TargetMob.Mutations+=1
				view(TargetMob)<<"[usr] injects a mysterious needle into [TargetMob]!"
				spawn del(src)
				if(prob(90)&&usr.HP<100)
					view(TargetMob)<<"[TargetMob] becomes comatose!"
					TargetMob.KO()
					sleep(50)
					TargetMob.Death()
				else if(usr.HP<100)
					TargetMob << "It... didn't work?"
					sleep(100)
					TargetMob.Death()
				else if(prob(10))
					TargetMob << "The injection fails to kill you!"
				return
		T_Virus_Injection
			cantblueprint=1
			IsntAItem=0
			name = "T-Virus Injection"
			desc = "Gives you a guarenteed mutation and death. Can be injected into KO'd opponents or creatures."
			Consume()
				if(!(..())) return
				Inject(usr)
			verb/Inject_Mob(var/mob/M in view(1))
				set category = null
				set src in usr
				if(!M.KO) return
				M << "[usr] is injecting you with something!"
				var/prevHP = usr.HP
				sleep(100)
				if(usr.HP>=prevHP&&!usr.KO&&M in view(1))
					Inject(M)
					M.Mutations+=1
			proc/Inject(var/mob/TargetMob)
				if(prob(10))
					TargetMob.Mutations+=1
				view(TargetMob)<<"[usr] injects a mysterious needle into [TargetMob]!"
				spawn del(src)
				if(prob(90)&&usr.HP<100)
					TargetMob.KO(10)
					view(TargetMob)<<"[TargetMob] becomes comatose!"
					sleep(50)
					spawn createZombies(10,TargetMob.peakexBP,TargetMob.x,TargetMob.y,TargetMob.z)
					TargetMob.Death()
				else if(usr.HP<100)
					TargetMob << "It... didn't work?"
					sleep(100)
					spawn createZombies(10,TargetMob.peakexBP,TargetMob.x,TargetMob.y,TargetMob.z)
					TargetMob.Death()
				else if(prob(10))
					TargetMob << "The injection fails to kill you!"
				return
		Tail_Injection
			cantblueprint=1
			IsntAItem=0
			name = "Tail Injection"
			desc = "Saiyans and Half saiyans can use this to grow their tail back. Other races won't notice anything."
			Consume()
				if(!(..())) return
				if(usr.has_Tail() && !usr.Tail)
					usr.Tail_Grow()
					spawn usr.KO()
					spawn usr.SpreadDamage(45)
				del(src)
				return
