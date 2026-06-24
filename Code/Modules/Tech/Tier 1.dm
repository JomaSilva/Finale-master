obj/Creatables
	Fishing_Pole
		icon='FishingPole.dmi'
		cost=10
		neededtech=1 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Fishing rods lets you catch food with little issue."
		create_type = /obj/items/FishingPole
	Key
		icon='key.dmi'
		cost=100
		neededtech=5
		desc="Keys let you enter passworded Doors without having to enter in the password every time. They also let you set passwords on doors!"
		create_type = /obj/items/Key
	Weights
		icon='Clothes_ShortSleeveShirt.dmi'
		cost=250
		neededtech=10
		desc="Weighs you down and improves training."
		create_type = /obj/items/Weight
	Shovel
		icon='Shovel.dmi'
		cost=15
		neededtech=3
		desc="Allows you to dig. Slowly..."
		create_type = /obj/items/Shovel
	Hand_Drill
		icon='Drill Hand.dmi'
		cost=250
		neededtech=10
		desc="Allows you to dig a bit faster."
		create_type = /obj/items/Hand_Drill
	/*Shuriken
		icon='Windmill Shuriken.dmi'
		cost=250
		neededtech=15
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/A=new/obj/items/Windmill_Shuriken(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You don't have enough money."
		verb/Description()
			set category =null
			usr<<"Can be thrown for damage, and can be upgraded."*/
	Books
		icon='Books.dmi'
		cost=10
		neededtech=10 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Books! Functionally useless, but are technically shitpost-pads."
		create_type = /obj/items/Book

	/*Saibaman_Seed
		icon='Saiba Seed.dmi'
		cost=100
		neededtech=12 //Deletes itself from contents if the usr doesnt have the needed tech
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/A=new/obj/items/Saibaman_Seed(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
				A.SBP=1000000
			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A braindead Saibaman in a pod. What's not to love?"*/
	PDA
		icon='PDA.dmi'
		icon_state=""
		cost=400
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Same as a book, but is current year. Also, serves as a portable Bounty Computer if you upgrade it."
		create_type = /obj/items/PDA
	Artificial_Moon
		icon='Moon.dmi'
		icon_state="Off"
		cost=1500
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Pretty to look at. Gives off King Kong vibes for some reason."
		create_type = /obj/items/Artificial_Moon
	Punching_Bag
		icon='PunchingBag.dmi'
		cost=1500
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Punching this will double your training gains."
		create_type = /obj/items/Punching_Bag

	Punching_Machine
		icon='punchmachine.dmi'
		cost=1500
		neededtech=15 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Punching this will broadcast your per-punch damage. (And how much you can lift.)"
		create_type = /obj/items/Punching_Machine
		Click()
			var/obj/items/Punching_Machine/A = ..()
			if(A) A.pbagBP = usr.intBPcap
	Bandages
		icon='Bandage.dmi'
		cost=100
		neededtech=15
		desc="Slowly heal wounds using bandages. Must stay still while using, and can be used on others."
		create_type = /obj/items/Bandages
obj/var/list/password = list()
mob/var/tmp/bandaging = 0
obj
	items
		Weight
			icon='Clothes_ShortSleeveShirt.dmi'
			equipped=0
			stackable=0
			name = "Weights"
			var/pounds = 1

			verb/Equip()
				set category=null
				set src in usr
				var/hasoneon=0
				for(var/obj/items/Weight/G in usr.contents) if(G!=src&&G.equipped) hasoneon=1
				if(!hasoneon)
					if(!equipped)
						equipped=1
						usr.Weighted=pounds
						suffix="Equipped"
						usr.overlayList+=icon
						usr.overlaychanged=1
						usr<<"You put on the [src]."
					else
						equipped=0
						usr.Weighted=0
						usr.weight=1
						suffix=""
						usr.overlayList-=icon
						usr.overlaychanged=1
						usr<<"You take off the [src]."
				else usr<<"You already have one on."
			verb/Upgrade()
				set category=null
				set src in usr
				pounds = max(log(10,usr.intBPcap) * (usr.peakexBP*usr.Ephysoff*5),pounds)
				if(!equipped)
				else
					usr.Weighted=pounds
				view(usr)<<"Weighted Clothing changed to [pounds] pounds."
			verb/Icon()
				set category=null
				set src in usr
				if(!equipped)
					switch(alert(usr,"Default?","","Default","Custom","Cancel"))
						if("Custom")
							icon = input("Icon") as icon
						if("Default")
							icon = 'Clothes_ShortSleeveShirt.dmi'

		Key
			var/upgraded=0
			icon='key.dmi'
			SaveItem=1
			stackable=0
			dropProbability=10
			Click()
				if(password.len == 0)
					var/Choice=alert(usr,"Enter in a password?","","Yes","No")
					switch(Choice)
						if("Yes")
							usr<<"Enter a password."
							password+=input(usr,"Enter the password.","",text) as text
				else if(!upgraded&&password.len>=1)
					var/Choice=alert(usr,"You already have a password set on this. It's [password[1]]. Choose a new one?","","Yes","No")
					switch(Choice)
						if("Yes")
							usr<<"Enter a password."
							password=input(usr,"Enter the password.","",text) as text
				else
					var/Choice=alert(usr,"Add another password to the list?","","Yes","No", "Remove One")
					switch(Choice)
						if("Remove One")
							usr<<"Enter a password to be removed from the list."
							password-=input(usr,"Enter the password.","",text) as text
						if("Yes")
							usr<<"Enter a password."
							password+=input(usr,"Enter the password.","",text) as text
			verb/Check_Passwords()
				set category = null
				set src in view(1)
				if(!password)
					usr<<"You don't have any passwords on this key."
				if(password&&upgraded==0)
					var/P
					for(var/S in password)
						P+=1
						usr<<"Password [P]:[S]."
				if(password&&upgraded==1)
					usr<<"You have [password.len] password(s) on this key."
					var/P
					for(var/S in password)
						P+=1
						usr<<"Password [P]:[S]."
			verb/Upgrade()
				set category = null
				set src in view(1)
				if(upgraded==0)
					var/Choice=alert(usr,"The Key upgrade allows you to store multiple keys in it. It costs 1,000 zenni to upgrade this item. Do so?","","Yes","No")
					switch(Choice)
						if("Yes")
							if(usr.zenni>=1000)
								usr<<"Upgraded."
								upgraded=1
							else
								usr<<"You don't have enough Zenni. (You need 1,000)."
				else
					usr<<"You've already upgraded this item."
			verb/Set_Password_On_Door(var/turf/build/Door/A in view(1))
				set category = null
				set src in view(1)
				if(istype(A,/turf/build/Door)&&A.proprietor==usr.ckey)
					A.seccode = input(usr,"Input the password","") as text
		Shovel
			icon='Shovel.dmi'
			SaveItem = 1
			stackable=0
			verb/Equip()
				set category=null
				set src in usr
				if(equipped==0)
					suffix="*Equipped*"
					usr<<"<b>You equip your shovel.</b>"
					equipped=1
				else
					suffix=""
					usr.hasdrill=0
					usr<<"<b>You unequip your shovel.</b>"
					equipped=0
			verb/Dig()
				set category="Skills"
				usr<<"You begin digging for resources (see Items tab)."
				usr.dig=1
				while(src.equipped && usr.dig)
					if(!usr.beaming&&!usr.charging&&!usr.flight&&!usr.KO&&usr.canfight)
						if(usr.dig)
							if(usr.Ki>=10)
								usr.Ki-=rand(5,10)*max(log(10,usr.MaxKi),1)*usr.BaseDrain
								if(rand(1,100)>=80)
									usr.zenni+=round((usr.techmod),1) * GlobalResourceGain
									usr.techxp+=usr.techmod
								else
									var/attempt = 1
									var/obj/items/Material/m
									while(attempt)
										var/item = pick(typesof(/obj/items/Material) - typesof(/obj/items/Material/Alchemy/Misc))
										m = new item
										if(!Sub_Type(item))
											if(m.quality>50||m.tier>4) break
											else
												attempt = Sub_Type(item)
										else break
										sleep(1)
									m.Move(usr.loc)
							else
								usr<<"You stop digging."
								usr.dig=0
					else break
					sleep(50)
				usr<<"You stop digging."
				usr.dig=0
		Hand_Drill
			icon='Drill Hand.dmi'
			SaveItem = 1
			stackable=0
			var/upgraded = 0
			verb/Power_Switch()
				set category=null
				set src in usr
				if(equipped==0)
					suffix="*Equipped*"
					usr.hasdrill=1
					if(upgraded) usr.hasdrill = 2
					usr<<"<b>You turn on your Hand Drill. This will enable more zenni obtained while digging."
					equipped=1
				else
					suffix=""
					usr.hasdrill=0
					usr<<"<b>You turn off your Hand Drill."
					equipped=0
			verb/Dig()
				set category="Skills"
				usr<<"You begin digging for resources (see Items tab)."
				usr.dig=1
				while(src.equipped && usr.dig)
					var/nm = 1
					if(!usr.beaming&&!usr.charging&&!usr.flight&&!usr.KO&&usr.canfight)
						if(usr.dig)
							if(usr.Ki>=3)
								usr.Ki-=rand(1,3)*max(log(9,usr.MaxKi),1)*usr.BaseDrain
								if(usr.hasdrill==2)nm++
								if(rand(1,100)>=80)
									usr.zenni+=round((usr.techmod),1) * GlobalResourceGain * nm
									usr.techxp+=usr.techmod
								else
									var/attempt = 1
									var/obj/items/Material/m
									while(attempt)
										var/item = pick(typesof(/obj/items/Material) - typesof(/obj/items/Material/Alchemy/Misc))
										m = new item
										if(!Sub_Type(item))
											if(m.quality>50||m.tier>4) break
											else
												attempt = Sub_Type(item)
										else break
										sleep(1)
									m.Move(usr.loc)
							else
								usr<<"You stop digging."
								usr.dig=0
					else break
					sleep(30 - (nm*5))
				usr<<"You stop digging."
				usr.dig=0
			verb/Upgrade()
				set category=null
				set src in usr
				if(upgraded) return
				if(equipped==0)
					if(alert(usr,"Upgrade for 7000 zenni?","","Yes","No")=="Yes"&&!upgraded && usr.techskill > 30)
						if(usr.zenni>=7000)
							usr.zenni -= 7000
							icon = 'Drill Hand 2.dmi'
							upgraded = 1
							usr<<"<b>Hand Drill upgraded."
						else
							usr << "Not enough zenni."
							return
				else
					if(alert(usr,"Upgrade for 7000 zenni?","","Yes","No")=="Yes"&&!upgraded && usr.techskill > 30)
						if(usr.zenni>=7000)
							usr.zenni -= 7000
							icon = 'Drill Hand 2.dmi'
							upgraded = 1
							usr.hasdrill=2
							usr<<"<b>Hand Drill upgraded."
						else
							usr << "Not enough zenni."
							return
		Artificial_Moon
			icon='Moon.dmi'
			icon_state="Off"
			SaveItem = 1
			var/mooning
			verb/Moon()
				set category=null
				set src in oview(1)
				if(!mooning)
					mooning=1
					icon_state="On"
					view(usr)<<"[usr] activates an artificial moon!"
					while(mooning)
						sleep(5)
						for(var/mob/M in view(src))
							if(M.genome.race_percent("Saiyan") >= 50)
								if(!M.Apeshit&&M.Tail)
									M<<"You catch a glimpse of the moon."
									M.Apeshit()
							else if(M.Race=="Saiyan")
								if(!M.Apeshit&&M.Tail)
									M<<"You catch a glimpse of the moon!"
									M.Apeshit()
									if(M.hasssj)
										spawn(100)
										M.Apeshit_Revert()
										M.GoldenApeshit()
						spawn(100) del(src)
				else usr<<"It has already been activated..."
			verb/Upgrade_Moon()
				set category=null
				set src in oview(1)
				var/cost = 1000000
				if(usr.zenni<cost&&usr.techskill>=50)
					usr<<"You do not have enough money ([cost]z) or your tech skill isn't high enough (50 tech needed.)"
					return
				if(usr.zenni>cost)
					var/confirm=alert(usr,"Pay 1 million zeni?","","Yes","No")
					switch(confirm)
						if("Yes")
							usr.zenni-=cost
							usr.contents += new/obj/items/Black_Moon
							del(src)

		Black_Moon
			icon='Moon2.dmi'
			icon_state="Off"
			SaveItem = 1
			var/mooning
			verb/Moon()
				set category=null
				set src in oview(1)
				if(!mooning)
					mooning=1
					icon_state="On"
					view(usr)<<"[usr] activates an artificial moon!"
					while(mooning)
						sleep(5)
						for(var/mob/M in view(src))
							if(M.Race=="Saiyan"&&!M.hasssj|M.genome.race_percent("Saiyan") >= 50)
								if(!M.Apeshit&&M.Tail)
									M<<"You catch a glimpse of the black moon!"
									M.Apeshit()
							else if(M.Race=="Saiyan"&&M.hasssj)
								if(!M.Apeshit&&M.Tail)
									M<<"You catch a glimpse of the black moon!"
									M.GoldenApeshit()
						spawn(100) del(src)
				else usr<<"It has already been activated..."
		Punching_Bag
			icon='PunchingBag.dmi'
			fragile=1
			SaveItem = 1
			stackable=0
			var/pbagHP = 100
			var/pbagBP = 10
			Click()
				switch(alert(usr,"[src]: Heal (1000 zenni) or change icon? Punching Bag is at [pbagHP]%, armor at [armor]/[maxarmor]","","Heal","Change Icon"))
					if("Heal")
						if(usr.zenni>=1000)
							usr.zenni-=1000
							healDamage(maxarmor)
							pbagHP = 100
							if(pbagBP<usr.expressedBP) pbagBP = usr.expressedBP
							icon_state = ""
					if("Change Icon")
						switch(alert(usr,"Default or custom?","","Default","Custom","Cancel"))
							if("Default")
								icon = 'PunchingBag.dmi'
							if("Custom")
								icon = input(usr,"Choose the punching bag icon.") as icon
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
		Punching_Machine
			icon='punchmachine.dmi'
			fragile=1
			SaveItem = 1
			stackable=0
			var/pbagHP = 100
			var/pbagBP = 10
			Click()
				if(alert(usr,"[src]: Heal (1000 zenni) or change icon? Punching Bag is at [pbagHP]%, armor at [armor]/[maxarmor]","","Heal","Change Icon"))
					if("Heal")
						if(usr.zenni>=1000)
							usr.zenni-=1000
							healDamage(maxarmor)
							pbagHP = 100
							if(pbagBP<usr.expressedBP) pbagBP = usr.expressedBP
							icon_state = ""
					if("Change Icon")
						switch(alert(usr,"Default or custom?","","Default","Custom","Cancel"))
							if("Default")
								icon = 'punchmachine.dmi'
							if("Custom")
								icon = input(usr,"Choose the punching bag icon.") as icon
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
		Bandages
			icon='Bandage.dmi'
			SaveItem = 1
			stackable=1
			var/mloc
			var/uloc
			var/counter
			var/prevHP
			verb/Bandage(mob/M in view(1))
				set category=null
				set src in usr
				if(usr.bandaging)
					usr<<"You are currently bandaging someone!"
					return
				if(usr.KO)
					usr<<"You can't use this while unconscious!"
					return
				if(M==usr)
					usr<<"You begin bandaging yourself. Don't move."
					mloc=usr.loc
					usr.bandaging=1
					counter=10
					prevHP=usr.HP
					while(usr.bandaging&&counter&&!usr.KO)
						sleep(5)
						if(mloc!=usr.loc)
							usr<<"You moved, and your bandaging has failed"
							usr.bandaging=0
							break
						if(prevHP>usr.HP)
							usr<<"Being damaged interrupted you!"
							usr.bandaging=0
							break
						usr.SpreadHeal(2,0,0)
						counter--
					usr.bandaging=0
					del(src)
				else
					usr<<"You begin bandaging [M.name]. If either of you move, this will fail."
					M<<"[usr.name] is bandaging you. If either of you move, this will fail."
					uloc=usr.loc
					mloc=M.loc
					usr.bandaging=1
					counter=20
					prevHP=usr.HP
					while(usr.bandaging&&counter&&!usr.KO)
						sleep(5)
						if(mloc!=M.loc)
							usr<<"[M.name] moved, and your bandaging has failed."
							M<<"You moved, and [usr.name]'s bandaging has failed."
							usr.bandaging=0
							break
						if(uloc!=usr.loc)
							usr<<"You moved, and your bandaging has failed."
							M<<"[usr.name] moved, and [usr.name]'s bandaging has failed."
							usr.bandaging=0
							break
						if(prevHP>usr.HP)
							usr<<"Being damaged interrupted you!"
							usr.bandaging=0
							break
						M.SpreadHeal(2,1,0)
						counter--
					usr.bandaging=0
					del(src)