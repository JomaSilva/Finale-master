obj/Creatables
	Regenerator
		icon='regeneratoricon.png'
		cost=75000
		neededtech=35 //Deletes itself from contents if the usr doesnt have the needed tech
		pixel_x =-13
		desc="Regenerators let you slowly regenerate HP, Ki, and a very small amount of Stamina."
		create_type = /obj/items/Regenerator
	Energy_Drain_Gloves
		icon='Clothes_Gloves.dmi'
		cost=1000
		neededtech=15
		desc="Increases Max Energy gain, increases Energy drain."
		create_type = /obj/items/Energy_Drain_Gloves

	Energy_Drain_Boots
		icon='Clothes_Boots.dmi'
		cost=1000
		neededtech=15
		desc="Increases Max Energy gain, increases Energy drain."
		create_type = /obj/items/Energy_Drain_Boots

	Scouter
		icon='Scouter.dmi'
		icon_state="Ammo"
		cost=8000
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Scouters let you view the power of others around you, communicate, and more."
		create_type = /obj/items/Scouter
	Medical_Scanner
		icon='Lab2.dmi'
		icon_state="WallDisplayA"
		cost=10000
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Medical Scanners let you scan others or yourself for information about biologies."
		create_type = /obj/items/Medical_Scanner
	Boat
		icon='Boat.dmi'
		icon_state=""
		cost=20000
		neededtech=20 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Boats allow you to sail across the open waters freely."
		create_type = /obj/Boat
	Boat_Placed
		icon='Boat.dmi'
		icon_state=""
		cost=20000
		neededtech=999
		var/count=0
		SaveItem=0
		desc="Boats allow you to sail across the open waters freely."
		create_type = /obj/Boat

obj/items
	Regenerator
		icon = 'regenerator.dmi'
		icon_state = "base"
		pixel_x =-13
		SaveItem=1
		fragile=1
		stackable=0
		New()
			..()
			spawn Ticker()
		proc/Ticker()
			set background = 1
			set waitfor = 0
			spawn if(src)
				if(usable&&Bolted)
					var/mobinview = 0
					for(var/mob/M in view(0,src))
						mobinview=1
						spawn(10)
							M.inregen = 0
						if(M.HP<100&&Energy>=0.002&&M.Player&&!M.inteleport)
							if(Energy>=0)
								M.dir=SOUTH
								M.inregen = 1
								spawn(20)
									M.SpreadHeal(3*round(efficiency/2,1),1)
									if(M.Ki<=M.MaxKi)
										if((M.Ki+=1*efficiency)>=M.MaxKi) M.Ki=M.MaxKi
										else M.Ki += 1*efficiency
									Energy-=0.002*efficiency
									if(injuryheal)
										if(prob(5))
											if(M.Mutations)
												M.Mutations-=1
												view(src)<<"[src]: Mutation found within [M]. Removed."
										if(prob(min(max(efficiency,1),100)))
											var/list/limbselection = list()
											for(var/datum/Body/C in M.body)
												if(C.artificial) continue
												if(C.health >= 0.991 * C.maxhealth) continue

												if(C.health < C.maxhealth || C.lopped)
													limbselection += C
											if(limbselection.len>=1)
												var/datum/Body/choice = pick(limbselection)
												if(!isnull(choice))
													if(choice.lopped)
														choice.RegrowLimb()
													else
														choice.health += 1*efficiency
														choice.health = min(choice.health,choice.maxhealth)
							if(Energy<=0)
								view(src)<<"[src]: Battery has been completely drained."
								usable=0
								M.inregen = 0
								overlays -= podlayer
						else if(M.HP>=100)
							var/turf/T
							for(T in view(1))
								if(T.density==0)
									if(T == orange(1))
										break
							if(T&&!(T.loc==M.loc))
								M.loc = locate(T)
								view(src)<<"[src]: Ejecting [M]."
					for(var/turf/T in view(0,src)) if(T.gravity>10*Durability&&usable)
						usable=0
						view(src)<<"The [src] is crushed by the force of the gravity!"
						overlays -= podlayer
					if(prob(NanoCore*0.1)&&Energy<MaxEnergy*0.1)
						view(src)<<"[src]: Nanite Regeneration activated. Battery fully recharged."
						Energy=MaxEnergy
					if(mobinview)
						overlays -= overlays
						overlays += podlayer
						plane= 6
					else
						plane= 0
						overlays -= podlayer
				else if(prob(NanoCore*0.1))
					usable=1
					view(src)<<"[src]: Nanite Regeneration activated. Damage fully restored."
				else if(Energy>=0&&Bolted)
					usable=1
					view(src)<<"[src]: Operational."
				sleep(10)
			spawn(20) Ticker()
		plane= 0
		var/podlayer = icon('regenerator.dmi',"tank")
		var/usable=1
		var/efficiency=1
		var/Durability=1
		var/Energy=1
		var/MaxEnergy=1
		var/NanoCore=0
		var/injuryheal
		verb/Info()
			set src in oview(1)
			set category=null
			usr<<"Battery Life: [Energy*100] / [MaxEnergy*100]"
			usr<<"Regeneration: +[efficiency]%"
			usr<<"Durability: [Durability*10]x"
			if(NanoCore) usr<<"Nano Regeneration: [NanoCore]"
			usr<<"Cost to make: [techcost]z"
		verb/Upgrade()
			set src in oview(1)
			set category=null
			thechoices
			if(usr.KO) return
			var/cost=0
			var/list/Choices=new/list
			Choices.Add("Cancel")
			if(usr.zenni>=250*MaxEnergy) Choices.Add("Recharge ([500*MaxEnergy]z)")
			if(usr.zenni>=500*MaxEnergy) Choices.Add("Battery Life ([500*MaxEnergy]z)")
			if(usr.zenni>=1000*efficiency) Choices.Add("Recovery Speed ([1000*efficiency]z)")
			if(usr.zenni>=1000*Durability) Choices.Add("Durability ([1000*Durability]z)")
			if(usr.zenni>=5000&&!injuryheal) Choices.Add("Heal Injuries (5000z)")
			if(usr.zenni>=2000*(NanoCore+1)&&usr.techskill>=6) Choices.Add("Nano Regeneration ([2000*(NanoCore+1)]z)")
			var/A=input("Upgrade what?") in Choices
			if(A=="Cancel") return
			if(A=="Heal Injuries (5000z)")
				cost=5000
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
				injuryheal = 1
			if(A=="Recharge ([500*MaxEnergy]z)")
				cost=250*MaxEnergy
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
				usr<<"Battery recharged."
				Energy=MaxEnergy
			if(A=="Battery Life ([500*MaxEnergy]z)")
				cost=500*MaxEnergy
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
				usr<<"Battery expanded and recharged."
				MaxEnergy+=1
				Energy=MaxEnergy
			if(A=="Recovery Speed ([1000*efficiency]z)")
				cost=1000*efficiency
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
				usr<<"Healing Speed increased."
				efficiency+=1
			if(A=="Durability ([1000*Durability]z)")
				cost=1000*Durability
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
				usr<<"Durability increased and fully repaired"
				Durability+=1
				if(!usable)
					usable=1
					icon_state="middle"
			if(A=="Nano Regeneration ([2000*(NanoCore+1)]z)")
				cost=2000*(NanoCore+1)
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
				usr<<"Nanite Regeneration increased."
				NanoCore+=1
			usr<<"Cost: [cost]z"
			usr.zenni-=cost
			tech+=1
			techcost+=cost
			goto thechoices
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
						Bolted=1
						boltersig=usr.signiture
	Radar
		icon='Misc2.dmi'
		icon_state="Radar"
		SaveItem=1
		stackable=0
		var/radarType
		verb/Locate()
			set category=null
			set src in view(1)
			for(var/obj/O in obj_list)
				if(O.z==usr.z&&istype(O,radarType))
					if(istype(O,/obj/DB))
						var/obj/DB/nD = O
						if(!nD.IsInactive) view(src)<<"<font color=green>------------<br>Dragonball found at ([O.x],[O.y],[O.z])"
					else
						view(src)<<"<font color=green>------------<br>[O] found at ([O.x],[O.y],[O.z])"
		verb/Set_Type(obj/O as obj in view(2))
			set category = null
			set src in view(1)
			view(usr)<<"[usr] set the [src]'s radar type to [O]"
			radarType = O.type
mob/var/HasEnergyDrain=0
obj/items
	Energy_Drain_Gloves
		icon='Clothes_Gloves.dmi'
		NotSavable=1
		New()
			..()
			spawn Ticker()
		proc/Ticker()
			if(equipped && loc)
				var/mob/user = loc
				user.Ki -= 2 * user.BaseDrain
			spawn(10) Ticker()
		verb/Equip()
			set category=null
			set src in usr
			for(var/obj/items/Energy_Drain_Gloves/A in usr.contents) if(A!=src&&A.suffix=="*Equipped*")
				usr<<"You already have one equipped."
				return
			if(equipped==0)
				equipped=1
				suffix="*Worn*"
				usr.overlayList+=icon
				usr.overlaychanged=1
				usr.BPrestriction+=1.25
				usr.genome.add_to_stat("Energy Level",0.05)
				usr.HasEnergyDrain+=1
				usr<<"You put on the [src]."
			else
				equipped=0
				if(suffix=="*Worn*")
					usr.BPrestriction-=1.25
					usr.genome.sub_to_stat("Energy Level",0.05)
				suffix=""
				usr.overlayList-=icon
				usr.overlaychanged=1
				usr.HasEnergyDrain-=1
				usr<<"You take off the [src]."
	Energy_Drain_Boots
		icon='Clothes_Boots.dmi'
		NotSavable=1
		New()
			..()
			spawn Ticker()
		proc/Ticker()
			if(equipped && loc)
				var/mob/user = loc
				user.Ki -= 2 * user.BaseDrain
			spawn(10) Ticker()
		verb/Equip()
			set category=null
			set src in usr
			for(var/obj/items/Energy_Drain_Boots/A in usr.contents) if(A!=src&&A.suffix=="*Equipped*")
				usr<<"You already have one equipped."
				return
			if(equipped==0)
				equipped=1
				suffix="*Worn*"
				usr.overlayList+=icon
				usr.overlaychanged=1
				usr.BPrestriction+=1.25
				usr.genome.add_to_stat("Energy Level",0.05)
				usr.HasEnergyDrain+=1
				usr<<"You put on the [src]."
			else
				equipped=0
				if(suffix=="*Worn*")
					usr.BPrestriction-=1.25
					usr.genome.sub_to_stat("Energy Level",0.05)
				suffix=""
				usr.overlayList-=icon
				usr.overlaychanged=1
				usr.HasEnergyDrain-=1
				usr<<"You take off the [src]."
	Scouter
		icon='Scouter.dmi'
		SaveItem=1
		stackable=0
		var/channel = 1
		var/maxscan=500
		verb
			Scouter_Speak(msg as text)
				set category=null
				set src in usr
				for(var/obj/O)
					if(istype(O,/obj/items/Scouter))
						var/obj/items/Scouter/nO = O
						if(nO.suffix&&ismob(nO.loc)&&channel==nO.channel)
							var/mob/M = nO.loc
							M<<"(Scouter)<[usr.SayColor]>[usr] says, '[msg]'"
					if(istype(O,/obj/Spacepod))
						var/obj/Spacepod/nO = O
						if(channel==nO.link)
							view(O)<<"(Scouter)<[usr.SayColor]>[usr] says, '[msg]'"
					if(istype(O,/obj/items/Communicator))
						var/obj/items/Communicator/nO = O
						if(channel in nO.freqlist)
							nO.messagelist+={"<html><head><title></title></head><body><body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>(Scouter)<[usr.SayColor]>[usr] says, '[msg]'</font><br></body><html>"}
							if(nO.hasbroadcaster) view(nO) << "(Scouter)<[usr.SayColor]>[usr] says, '[msg]'"
			Change_Channel(chann as text)
				set category = null
				set src in usr
				channel = chann
			Equip()
				set category=null
				set src in usr
				if(!usr.scouteron)
					usr.scouteron=1

					usr<<"You put on the [src]."
					usr.overlayList+=icon
					usr.overlaychanged=1
					suffix="*Equipped*"
				else
					usr.scouteron=0
					usr<<"You take off the [src]."
					usr.overlayList-=icon
					usr.overlaychanged=1

					suffix=""
			Scan(mob/M in view(usr))
				set category=null
				set src in usr
				var/accuracy
				if(M.BP<1000) accuracy=10
				else if(M.BP<10000) accuracy=100
				else if(M.BP<100000) accuracy=1000
				else if(M.BP<1000000) accuracy=10000
				else if(M.BP<10000000) accuracy=100000
				else accuracy=1000000
				if(usr.scouteron)
					if(M.BP<maxscan)
						usr<<"<font color=green><br>-----<br>Scanning..."
						sleep(20)
						usr<<"<font color=green>Battle Power: [num2text((round(M.BP,accuracy)),20)]<br>-Scan Complete-"
						if(M.Race=="Saiyan") usr<<"<font color=green>Records show this [M.Race] was born with [M.FirstYearPower] Battle Power."
					else
						usr<<"<font color=green><br>-----<br>Scanning..."
						sleep(20)
						usr<<"<font color=green>..."
						sleep(20)
						usr<<"<font color=green>Battle Power: [num2text((round((M.BP+rand(10,accuracy)),accuracy)),20)]<br>-Scan Complete-"
						if(M.Race=="Saiyan") usr<<"<font color=green>Records show this [M.Race] was born with [M.FirstYearPower] Battle Power."
						view(usr)<<"<font color=red>*[usr]'s scouter explodes!*"
						usr.scouteron=0
						usr.overlayList-=icon
						suffix=""
						del(src)
				else usr<<"You must equip the scouter."
			Upgrade()
				set category=null
				set src in view(1)
				if(usr.KO) return
				if((usr.techmod*usr.intBPcap)>maxscan)

					maxscan=usr.techmod*usr.intBPcap
					view(6)<<"[usr] upgrades the scouters max scan to [num2text((round(maxscan)),20)]"
				else usr<<"This is already beyond any of your machine skills."
			Scan_Planet()
				set category=null
				for(var/mob/M)
					var/accuracy
					if(M.BP<1000) accuracy=10
					else if(M.BP<10000) accuracy=100
					else if(M.BP<100000) accuracy=1000
					else if(M.BP<1000000) accuracy=10000
					else if(M.BP<10000000) accuracy=100000
					else accuracy=1000000
					if(usr.scouteron&&M.Player&&M.key!=usr.key&&M.BP>=100&&M.z==usr.z)
						if(M.BP<=maxscan) usr<<"<font color=green>[num2text((round(M.BP,accuracy)),20)] at ([M.x],[M.y])"
						else usr<<"<font color=green>Immeasurable BP at ([M.x],[M.y])"
	Medical_Scanner
		icon='Lab2.dmi'
		icon_state="WallDisplayA"
		SaveItem=1
		stackable=0
		var/maxscan=500
		verb/Scan_Other(var/mob/M in view(2))
			set category = null
			set src in view(1)
			scanperson(M)
		Click()
			scanperson(usr)
		proc/scanperson(var/mob/targetmob)
			view(src)<<"<font color=gray>Physical Age=[targetmob.Age]"
			view(src)<<"<font color=gray>Old Age At=[targetmob.DeclineAge]"
			view(src)<<"<font color=gray>Race=[targetmob.Race] - [targetmob.Class]"
			view(src)<<"<font color=gray>Gender=[targetmob.pgender]"
			view(src)<<"<font color=gray>Damage=[FullNum((round(100-targetmob.HP)),20)]%"
			view(src)<<"<font color=gray>Energy=[FullNum(targetmob.Ki)]"
			view(src)<<"<font color=gray>Grav Mastered=[round(targetmob.GravMastered)]"
			for(var/datum/Body/S in targetmob.body)
				if(!S.lopped&&!S.artificial)
					view(src)<<"<font color=gray>[S.name] is at [S.health] out of [S.maxhealth]"
				else
					view(src)<<"<font color=gray>[S.name] is missing!"
			if(targetmob.Mutations)
				view(src)<<"[targetmob.Mutations] Mutation(s) found!"
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
						Bolted=1
						boltersig=usr.signiture
			else if(Bolted&&boltersig==usr.signiture)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
						Bolted=0