/*obj/Creatables
	Solar_Cell
		icon='Modules.dmi'
		icon_state = "2"
		cost=10000
		neededtech=20
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/A=new/obj/Modules/Solar_Cell(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"This device is usually pre-installed in androids. Solar Cells are pretty shit, they only charge you up to 80% stamina."*/
obj/Creatables
	Recharge_Station
		icon = 'DroidPod.dmi'
		cost=100000
		neededtech=10
		desc = "Recharge stations are capable of bringing you up to 100% pretty quickly. Too bad they aren't portable."
		create_type = /obj/items/Recharge_Station
/*	Researcher_AI
		icon = 'Modules.dmi'
		icon_state = "2"
		cost=500000
		neededtech=70
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/A=new/obj/Modules/Researcher_AI(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A Researcher AI allows you to research tech on the fly, giving you small amounts of tech XP."
	Basic_Repair_Core
		icon = 'Modules.dmi'
		icon_state = "2"
		cost=5000
		neededtech=20
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/A=new/obj/Modules/Basic_Repair_Core(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A not very good repair core used as a supplement for normal celluar regeneration processes."
	Time_Stop_Inhibitor
		icon = 'Modules.dmi'
		icon_state = "2"
		cost=5000
		neededtech=100
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/A=new/obj/Modules/Time_Stop_Inhibitor(locate(usr.x,usr.y,usr.z))
				A.techcost+=cost
			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"A time stop inhibitor prevents you from being frozen from localized timestop and global timestops. Takes shitloads of energy."
	Reinforced_Frame
		icon = 'Modules.dmi'
		icon_state = "2"
		cost=5000000
		neededtech=70
		Click()
			if(usr.zenni>=cost)
				usr.zenni-=cost
				var/obj/AA=new/obj/Modules/Reinforced_Frame/Head(locate(usr.x,usr.y,usr.z))
				var/obj/A=new/obj/Modules/Reinforced_Frame/Torso(locate(usr.x,usr.y,usr.z))
				var/obj/B=new/obj/Modules/Reinforced_Frame/Abdomen(locate(usr.x+1,usr.y,usr.z))
				var/obj/C=new/obj/Modules/Reinforced_Frame/HandL(locate(usr.x+1,usr.y,usr.z))
				var/obj/D=new/obj/Modules/Reinforced_Frame/HandR(locate(usr.x,usr.y+1,usr.z))
				var/obj/E=new/obj/Modules/Reinforced_Frame/ArmL(locate(usr.x,usr.y+1,usr.z))
				var/obj/F=new/obj/Modules/Reinforced_Frame/ArmR(locate(usr.x-1,usr.y,usr.z))
				var/obj/G=new/obj/Modules/Reinforced_Frame/LegL(locate(usr.x-1,usr.y,usr.z))
				var/obj/H=new/obj/Modules/Reinforced_Frame/LegR(locate(usr.x,usr.y-1,usr.z))
				var/obj/I=new/obj/Modules/Reinforced_Frame/FootL(locate(usr.x,usr.y-1,usr.z))
				var/obj/J=new/obj/Modules/Reinforced_Frame/FootR(locate(usr.x+1,usr.y+1,usr.z))
				var/obj/K=new/obj/Modules/Reinforced_Frame/Reproductive_Organs(locate(usr.x+1,usr.y+1,usr.z))
				AA.techcost+=500000
				A.techcost+=500000
				B.techcost+=500000
				C.techcost+=500000
				D.techcost+=500000
				E.techcost+=500000
				F.techcost+=500000
				G.techcost+=500000
				H.techcost+=500000
				I.techcost+=500000
				J.techcost+=500000
				K.techcost+=500000
			else usr<<"You dont have enough money"
		verb/Description()
			set category =null
			usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
*/
obj/Modules/Time_Stop_Inhibitor
	desc = "An item that prevents you from being frozen from localized timestop and global timestops. Takes shitloads of energy."
	elec_energy_max = 10000
	elec_energy = 10000
	Ticker()
		if(isequipped&&functional&&savant)
			if(TimeStopped&&!CanMoveInFrozenTime)
				if(elec_energy>=elec_energy_max)
					elec_energy = 0
					savant << "You can move in the frozen time."
					CanMoveInFrozenTime=1
					spawn(300)
						savant << "Your time is up."
						CanMoveInFrozenTime=0
				else CanMoveInFrozenTime = 0
			else if(!TimeStopped) CanMoveInFrozenTime = 0
		sleep(100)
		..()

obj/Modules/Solar_Cell
	desc = "An item that recharges various things while installed. Very slow."
	elec_energy_max = 1000
	Ticker()
		if(isequipped&&functional)
			elec_energy=min(elec_energy+10,elec_energy_max)
			spawn
			if(savant&&elec_energy>0)
				for(var/obj/Modules/A in savant)
					if(A.elec_energy<A.elec_energy_max)
						elec_energy-=max((A.elec_energy_max - A.elec_energy)*0.01,1)
						A.elec_energy+=(A.elec_energy_max - A.elec_energy)*0.01
				if(savant.stamina<=0.8*savant.maxstamina&&savant.Race=="Android")
					elec_energy-=max((savant.maxstamina - savant.stamina)*0.01,1)
					savant.stamina+=(savant.maxstamina - savant.stamina)*0.1
		sleep(100)
		..()

obj/Modules/Basic_Repair_Core
	desc = "Automatically repairs modules. The more expansive the damage, the more energy it takes. A non-functioning module for instance will take all of this module's power. If you're an android or cyborg, this also helps fix limbs."
	elec_energy_max = 100
	elec_energy = 10
	Ticker()
		if(isequipped&&functional&&savant)
			spawn
				if(elec_energy >= 10)
					for(var/obj/Modules/A in savant)
						if(integrity<99)
							integrity+=1
							elec_energy -= 10
							goto done
				if(elec_energy >= 100)
					for(var/obj/Modules/A in savant)
						if(!functional)
							functional=1
							integrity=100
							elec_energy -= 100
							goto done
						spawn
							var/list/limbselection = list()
							for(var/datum/Body/C in savant.body)
								if(C.health < C.maxhealth&&C.artificial)
									limbselection += C
							if(limbselection.len>=1)
								var/datum/Body/choice = pick(limbselection)
								if(!isnull(choice)&&prob(5))
									if(choice.lopped)
									else
										choice.health += 1
										choice.health = min(choice.health,choice.maxhealth)
		done
		..()

obj/Modules/Researcher_AI
	desc = "This module will provide a minute boost to tech skill learning."
	icon = 'Modules.dmi'
	icon_state = "2"
	elec_energy_max = 100
	elec_energy = 10
	Ticker()
		if(isequipped&&functional&&savant)
			elec_energy-=1
			savant.techxp+=1
			sleep(500)
		..()

obj/Modules/Android_Frame
	allowedlimb = null
	requireartificial = 1
	canuninstall = 0
	requiredslots = 0
	icon = 'Body Parts Bloodless.dmi'
	var/oghealth = 100
	var/ogartificial = 0
	desc="Basic frame for androids. Enhances body durability, but limits the flow of ki."

	equip()
		parent_limb.maxhealth*=1.5
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		savant.genome.sub_to_stat("Energy Level",0.1)
		savant.kiskillMod /= 1.05
		savant.kioffMod /= 1.1
		if(parent_limb.health>parent_limb.maxhealth)
			parent_limb.health=parent_limb.maxhealth
		..()

	unequip()
		parent_limb.maxhealth/=1.5
		parent_limb.artificial=ogartificial
		savant.genome.add_to_stat("Energy Level",0.1)
		savant.kiskillMod *= 1.05
		savant.kioffMod *= 1.1
		..()
	Head
		name="Basic Head Frame"
		icon_state = "Head"
		allowedlimb = /datum/Body/Head
	Torso
		name="Basic Torso Frame"
		icon_state = "Torso"
		allowedlimb = /datum/Body/Torso
	Abdomen
		name="Basic Abdomen Frame"
		icon_state = "Abdomen"
		allowedlimb = /datum/Body/Abdomen
	Hand
		name="Basic Hand Frame"
		icon_state = "Hands"
		allowedlimb = /datum/Body/Arm/Hand
	Arm
		name="Basic Arm Frame"
		icon_state = "Arm"
		allowedlimb = /datum/Body/Arm
	Leg
		name="Basic Leg Frame"
		icon_state = "Limb"
		allowedlimb = /datum/Body/Leg
	Foot
		name="Basic Foot Frame"
		icon_state = "Foot"
		allowedlimb = /datum/Body/Leg/Foot
	Reproductive_Organs
		name="Basic Functional Extensions"
		icon_state = "SOrgans"
		allowedlimb = /datum/Body/Reproductive_Organs

obj/Modules/Reinforced_Frame
	allowedlimb = null
	requireartificial = 1
	canuninstall = 0
	icon = 'Body Parts Bloodless.dmi'
	var/oghealth = 100
	var/ogartificial = 0
	desc="Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
	Ticker()
		if(requiredupgrade&&parent_limb)
			var/prereq=0
			for(var/obj/Modules/M in parent_limb.Modules)
				if(istype(M,requiredupgrade))
					prereq+=1
			if(prereq<1)
				savant<<"Your [src.name] has been uninstalled, as a dependancy is missing"
				unequip()
				remove()
		..()
	equip()
		parent_limb.maxhealth*=1.25
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		savant.genome.sub_to_stat("Energy Level",0.1)
		savant.kiskillMod /= 1.05
		savant.kioffMod /= 1.1
		if(parent_limb.health>parent_limb.maxhealth)
			parent_limb.health=parent_limb.maxhealth
		..()

	unequip()
		parent_limb.maxhealth/=1.25
		parent_limb.artificial=ogartificial
		savant.genome.add_to_stat("Energy Level",0.1)
		savant.kiskillMod *= 1.05
		savant.kioffMod *= 1.1
		..()
	Head
		name="Reinforced Head Frame"
		icon_state = "Head"
		allowedlimb = /datum/Body/Head
		requiredupgrade = /obj/Modules/Android_Frame/Head
		disallowedupgrade = /obj/Modules/Reinforced_Frame/Head
	Torso
		name="Reinforced Torso Frame"
		icon_state = "Torso"
		allowedlimb = /datum/Body/Torso
		requiredupgrade = /obj/Modules/Android_Frame/Torso
		disallowedupgrade = /obj/Modules/Reinforced_Frame/Torso
	Abdomen
		name="Reinforced Abdomen Frame"
		icon_state = "Abdomen"
		allowedlimb = /datum/Body/Abdomen
		requiredupgrade = /obj/Modules/Android_Frame/Abdomen
		disallowedupgrade = /obj/Modules/Reinforced_Frame/Abdomen
	HandL
		name="Reinforced Hand Frame L"
		icon_state = "Hands"
		allowedlimb = /datum/Body/Arm/Hand
		requiredupgrade = /obj/Modules/Android_Frame/Hand
		disallowedupgrade = /obj/Modules/Reinforced_Frame/HandL
	HandR
		name="Reinforced Hand Frame R"
		icon_state = "Hands"
		allowedlimb = /datum/Body/Arm/Hand
		requiredupgrade = /obj/Modules/Android_Frame/Hand
		disallowedupgrade = /obj/Modules/Reinforced_Frame/HandR
	ArmL
		name="Reinforced Arm Frame L"
		icon_state = "Arm"
		allowedlimb = /datum/Body/Arm
		requiredupgrade = /obj/Modules/Android_Frame/Arm
		disallowedupgrade = /obj/Modules/Reinforced_Frame/ArmL
	ArmR
		name="Reinforced Arm Frame R"
		icon_state = "Arm"
		allowedlimb = /datum/Body/Arm
		requiredupgrade = /obj/Modules/Android_Frame/Arm
		disallowedupgrade = /obj/Modules/Reinforced_Frame/ArmR
	LegL
		name="Reinforced Leg Frame L"
		icon_state = "Limb"
		allowedlimb = /datum/Body/Leg
		requiredupgrade = /obj/Modules/Android_Frame/Leg
		disallowedupgrade = /obj/Modules/Reinforced_Frame/LegL
	LegR
		name="Reinforced Leg Frame R"
		icon_state = "Limb"
		allowedlimb = /datum/Body/Leg
		requiredupgrade = /obj/Modules/Android_Frame/Leg
		disallowedupgrade = /obj/Modules/Reinforced_Frame/LegR
	FootL
		name="Reinforced Foot Frame L"
		icon_state = "Foot"
		allowedlimb = /datum/Body/Leg/Foot
		requiredupgrade = /obj/Modules/Android_Frame/Foot
		disallowedupgrade = /obj/Modules/Reinforced_Frame/FootL
	FootR
		name="Reinforced Foot Frame R"
		icon_state = "Foot"
		allowedlimb = /datum/Body/Leg/Foot
		requiredupgrade = /obj/Modules/Android_Frame/Foot
		disallowedupgrade = /obj/Modules/Reinforced_Frame/FootR
	Reproductive_Organs
		name="Reinforced Functional Extensions"
		icon_state = "SOrgans"
		allowedlimb = /datum/Body/Reproductive_Organs
		disallowedupgrade = /obj/Modules/Reinforced_Frame/Reproductive_Organs

obj/Modules/Reconstruction_Core
	desc="A microprocessor installed in an artificial brain that is connected to various systems. On destruction of vital body systems, will attempt to rebuild those systems using their scraps. Requires prolonged maintenance after usage."
	allowedlimb = /datum/Body/Head/Brain
	disallowedupgrade = /obj/Modules/Reconstruction_Core
	requireartificial = 1
	elec_energy_max=1000
	var/ogdr=0
	var/ogdrtmp=0
	var/canreconstruct=1
	verb/Calibrate_Reconstruction_Core()
		set category = null
		set src in usr
		var/calibrating=0 //no need for tmp in verbs
		if(isequipped&&functional&&!calibrating)
			usr<<"Maintenance processes engaged. Please wait..."
			calibrating=1
			spawn(6000)
			usr<<"Maintenance complete. Reconstruction core functional"
			calibrating=0
			canreconstruct=1
		else if(isequipped&&functional&&calibrating)
			usr<<"Calibration in progress..."
		else
			usr<<"ERROR: NONFUNCTIONAL UNIT"
	remove()
		if(savant)
			savant.reconstructable=0
			savant.DeathRegenTmp=ogdrtmp
		..()
	Ticker()
		if(isequipped&&functional&&savant)
			if(!savant.reconstructable&&canreconstruct&&!savant.deathregening)
				savant.reconstructable=1
				savant.DeathRegenTmp=1
			else if(savant.reconstructable&&!canreconstruct&&!savant.deathregening)
				savant.reconstructable=0
				savant.DeathRegenTmp=ogdrtmp
		else if(isequipped&&!functional&&savant)
			savant.reconstructable=0
			savant.DeathRegenTmp=ogdrtmp
		..()

mob/var/reconstructable=0

mob/proc/Generate_Droid_Parts() //meant to be used ONCE on character creation for droids.
	set background = 1
	if(client&&Race=="Android")
		src<<"Initializing systems, please stand by."
		var/obj/Modules/Solar_Cell/A = new
		A.loc = src
		var/list/limbselection = list()
		for(var/datum/Body/C in body)
			if(C.capacity>=1)
				limbselection += C
		var/datum/Body/choice = pick(limbselection)
		if(!isnull(choice))
			limbselection -= choice
			A.place(choice)
			EquippedModules += A
			A.equip()
			A.logout()
			A.login(src)
		var/obj/Modules/Basic_Repair_Core/B = new
		B.loc = src
		var/datum/Body/choice2 = pick(limbselection)
		if(!isnull(choice2))
			B.place(choice2)
			EquippedModules += B
			B.equip()
			B.logout()
			B.login(src)

		var/obj/Modules/Android_Frame/Head/D = new
		var/obj/Modules/Android_Frame/Torso/E = new
		var/obj/Modules/Android_Frame/Abdomen/F = new
		var/obj/Modules/Android_Frame/Reproductive_Organs/G = new
		var/obj/Modules/Android_Frame/Hand/DA = new
		var/obj/Modules/Android_Frame/Arm/EA = new
		var/obj/Modules/Android_Frame/Leg/FA = new
		var/obj/Modules/Android_Frame/Foot/GA = new
		var/obj/Modules/Android_Frame/Hand/DB = new
		var/obj/Modules/Android_Frame/Arm/EB = new
		var/obj/Modules/Android_Frame/Leg/FB = new
		var/obj/Modules/Android_Frame/Foot/GB = new
		D.loc = src
		E.loc = src
		F.loc = src
		G.loc = src
		DA.loc = src
		DB.loc = src
		EA.loc = src
		EB.loc = src
		FA.loc = src
		FB.loc = src
		GA.loc = src
		GB.loc = src
		for(var/datum/Body/X in body)
			switch(X.type)
				if(/datum/Body/Head)
					X.vital=0
					D.place(X)
					D.parent_limb=X
					sleep(2)
					src.EquippedModules += D
					D.equip()
					D.logout()
					D.login(src)
				if(/datum/Body/Torso)
					X.vital=0
					E.place(X)
					E.parent_limb=X
					sleep(2)
					src.EquippedModules += E
					E.equip()
					E.logout()
					E.login(src)
				if(/datum/Body/Abdomen)
					X.vital=0
					F.place(X)
					F.parent_limb=X
					sleep(2)
					src.EquippedModules += F
					F.equip()
					F.logout()
					F.login(src)
				if(/datum/Body/Reproductive_Organs)
					G.place(X)
					G.parent_limb=X
					sleep(2)
					src.EquippedModules += G
					G.equip()
					G.logout()
					G.login(src)
				if(/datum/Body/Arm/Hand)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Left")
						DA.place(X)
						DA.parent_limb=X
						sleep(2)
						src.EquippedModules += DA
						DA.equip()
						DA.logout()
						DA.login(src)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Right")
						DB.place(X)
						DB.parent_limb=X
						sleep(2)
						src.EquippedModules += DB
						DB.equip()
						DB.logout()
						DB.login(src)
				if(/datum/Body/Arm)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Left")
						EA.place(X)
						EA.parent_limb=X
						sleep(2)
						src.EquippedModules += EA
						EA.equip()
						EA.logout()
						EA.login(src)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Right")
						EB.place(X)
						EB.parent_limb=X
						sleep(2)
						src.EquippedModules += EB
						EB.equip()
						EB.logout()
						EB.login(src)
				if(/datum/Body/Leg/Foot)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Left")
						GA.place(X)
						GA.parent_limb=X
						sleep(2)
						src.EquippedModules += GA
						GA.equip()
						GA.logout()
						GA.login(src)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Right")
						GB.place(X)
						GB.parent_limb=X
						sleep(2)
						src.EquippedModules += GB
						GB.equip()
						GB.logout()
						GB.login(src)
				if(/datum/Body/Leg)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Left")
						FA.place(X)
						FA.parent_limb=X
						sleep(2)
						src.EquippedModules += FA
						FA.equip()
						FA.logout()
						FA.login(src)
					if(X.symmetry_info[3] == 0 && X.symmetry_info[2] == "Right")
						FB.place(X)
						FB.parent_limb=X
						sleep(2)
						src.EquippedModules += FB
						FB.equip()
						FB.logout()
						FB.login(src)
				if(/datum/Body/Head/Brain)
					X.artificial=1
					sleep(2)
				if(/datum/Body/Organs)
					X.artificial=1
					X.name = "Systems"
					sleep(2)
		sleep(2)
		src<<"All systems nominal."

obj/items/Recharge_Station
	desc = "When provided power, this station will be able to provide power to androids and cyborg modules."
	icon = 'DroidPod.dmi'
	pixel_y = -20
	SaveItem = 1
	elec_energy = 100
	elec_energy_max = 100
	var/tier = 1
	var/maxtier = 6
	var/efficiency = 0.5
	var/solarupgrade = 0
	verb/Upgrade()
		set category = null
		set src in view(1)
		switch(alert(usr,"Upgrade what?","","Efficiency","Tier","Solars"))
			if("Solars")
				if(solarupgrade)
					usr << "You already have this upgrade!"
					return
				else
					if(alert(usr,"Pay 100000 zenni for this upgrade? You have [usr.zenni] zenni.","","Yes","No")=="Yes")
						if(usr.zenni>=100000)
							usr.zenni-=100000
							solarupgrade = 1
							view(usr) << "Recharge Station upgraded."
						else
							usr<<"Not enough zenni!"
							return
			if("Tier")
				if(tier>=maxtier)
					usr << "You can't upgrade this any further!"
					return
				else
					if(alert(usr,"Pay [10000*tier] zenni for this upgrade? You have [usr.zenni] zenni.","","Yes","No")=="Yes")
						if(usr.zenni>=10000*tier)
							usr.zenni-=10000*tier
							tier += 1
							view(usr) << "Recharge Station upgraded."
						else
							usr<<"Not enough zenni!"
							return
			if("Efficiency")
				if(efficiency>=4)
					usr<<"You can't upgrade this any further!"
					return
				else
					if(alert(usr,"Pay [20000*efficiency] zenni for this upgrade? You have [usr.zenni] zenni.","","Yes","No")=="Yes")
						if(usr.zenni>=20000*efficiency)
							usr.zenni-=20000*efficiency
							efficiency += 0.5
							view(usr) << "Recharge Station upgraded."
						else
							usr<<"Not enough zenni!"
							return
	verb/Bolt()
		set category = null
		set src in view(1)
		switch(alert(usr,"Bolt? Currently its [Bolted]. (1 == Bolted, 0 == Free.) This machine will only work while bolted.","","Bolt","Unbolt","Cancel"))
			if("Bolt")
				Bolted = 1
				view(usr) << "Recharge Station bolted."
			if("Unbolt")
				Bolted = 0
				view(usr) << "Recharge Station unbolted."
	verb/Check_Energy()
		set category = null
		set src in view(1)
		usr<<"This station has [elec_energy] energy of a maximum of [elec_energy_max]."

	New()
		..()
		spawn Ticker()
	proc/Ticker()
		set waitfor=0
		set background = 1
		sleep(1)
		if(elec_energy<0)
			elec_energy = 0
		if(Bolted)
			for(var/mob/M in view(0))
				if(elec_energy<=0)
					break
				sleep(1)
				if(M.Race=="Android"&&M.stamina<M.maxstamina)
					sleep(1)
					M.stamina+= 1 * efficiency
					elec_energy -= 5 / efficiency
				if(M.Race=="Android"&&M.Ki<M.MaxKi)
					sleep(1)
					M.Ki+= 1 * efficiency * M.MaxKi / 1000
					elec_energy -= 5 / efficiency
				spawn for(var/obj/Modules/S in M.contents)
					if(S.elec_energy<S.elec_energy_max)
						S.elec_energy += 10 * efficiency
						elec_energy -= 10 / efficiency
					S.elec_energy = min(S.elec_energy,S.elec_energy_max)
					if(S.integrity<1)
						S.integrity=1
					if(!S.functional)
						S.functional=1
				break
			if(solarupgrade)
				elec_energy += 1 * tier
			if(tier>=2)
				elec_energy_max = 100 * tier**2
				elec_energy += tier
		sleep(10)
		spawn Ticker()