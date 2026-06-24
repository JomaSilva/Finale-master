//Cyborgs are just regular races with modules.
//Androids are just basically Humans with some bonuses and preincluded modules.

atom/movable/var
	elec_energy = 0 //electricity it starts with
	elec_energy_max = 0 //maximum electricity this can hold

mob
	var
		list/EquippedModules = list()
		exchange=0
		blastabsorb=0
		tmp/buster = 0
		tmp/bustercharge = 0
		tmp/assimilating = 0
		tmp/lasering=0
		tmp/mgun=0
		tmp/hmissile=0

obj/Modules
	icon = 'Modules.dmi'
	icon_state = "2"
	cantblueprint=0
	elec_energy = 100
	elec_energy_max = 100
	var/datum/Body/parent_limb = null
	var/isequipped = 0
	var/functional = 1
	var/integrity = 100
	var/mob/savant = null
	var/allowedlimb = null
	var/requireartificial = 0
	var/requireorganic = 0
	var/canuninstall = 1 //for built-in body systems and the like
	var/requiredupgrade = null //can use to make tiered upgrades
	var/requiredslots = 1//allows for variable capacity costs, defaults to 1
	var/disallowedupgrade = null //prevents installation if this module is installed
	var/requirelopped = 0//only works on a lopped limb

	proc/place(var/datum/Body/targetlimb,var/mob/target)
		if(targetlimb)
			for(var/datum/Body/A in target.body)
				if(A==targetlimb&&A.capacity>=requiredslots)
					savant=target
					isequipped = 1
					parent_limb = A
					A.capacity -= requiredslots
					A.Modules += src
					return TRUE
		return FALSE

	proc/remove()
		if(parent_limb)
			isequipped = 0
			parent_limb.capacity += requiredslots
			parent_limb.Modules -= src
			parent_limb = null
			savant=null
			return TRUE
		return FALSE

	proc/equip()
		suffix = "*Equipped*"
		isequipped = 1
	proc/unequip()
		suffix = ""
		isequipped = 0

	proc/logout()
		savant = null
	proc/login(var/mob/logger)
		savant = logger
	proc/Ticker()
		set background = 1
		sleep(10)
		spawn Ticker()
		if(elec_energy>=elec_energy_max)
			elec_energy = elec_energy_max
		if(elec_energy<0)
			elec_energy = 0
		if(integrity<=0)
			functional=0
		else if(integrity>0)
			functional=1
	verb
		Get()
			set category=null
			set src in oview(1)
			GetMe(usr)
		Drop()
			set category=null
			set src in usr
			DropMe(usr)
		Check_Requirements()
			set category = null
			set src in usr
			if(requiredslots>=0)
				usr<<"Requires [requiredslots] free capacity"
			else
				usr<<"Provides [abs(requiredslots)] free capacity"
			if(!canuninstall)
				usr<<"Once installed, cannot be removed"
			if(allowedlimb)
				var/datum/Body/A=allowedlimb
				usr<<"Can only be installed in [initial(A.name)]"
			if(requireartificial)
				usr<<"Requires an artificial limb"
			if(requireorganic)
				usr<<"Requires an organic limb"
			if(requiredupgrade)
				var/obj/Modules/B=requiredupgrade
				usr<<"Requires [initial(B.name)] to be installed in the limb first"
			if(disallowedupgrade)
				var/obj/Modules/C=disallowedupgrade
				usr<<"Cannot be installed with [initial(C.name)]"

	proc
		GetMe(var/mob/TargetMob)
			if(Bolted)
				TargetMob<<"It is bolted to the ground, you cannot get it."
				return FALSE
			if(TargetMob)
				if(!TargetMob.KO)
					for(var/turf/G in view(src)) G.gravity=0
					Move(TargetMob)
					view(TargetMob)<<"<font color=teal><font size=1>[TargetMob] picks up [src]."
					WriteToLog("rplog","[TargetMob] picks up [src]    ([time2text(world.realtime,"Day DD hh:mm")])")
					return TRUE
				else
					TargetMob<<"You cant, you are knocked out."
					return FALSE
		DropMe(var/mob/TargetMob)
			if(isequipped|suffix=="*Equipped*")
				usr<<"You must unequip it first"
				return FALSE
			TargetMob.overlayList-=icon
			TargetMob.overlaychanged=1
			loc=TargetMob.loc
			step(src,TargetMob.dir)
			view(TargetMob)<<"<font size=1><font color=teal>[TargetMob] drops [src]."
			return TRUE
	New()
		..()
		src.savant = usr
		Ticker()

obj/items/Repair_Kit
	icon = 'PDA.dmi'
	verb/Repair()
		set category = null
		set src in view(1)
		var/prevHP = usr.HP
		var/prevloc = usr.loc
		usr<<"This will take a moment, don't move or take further damage!"
		sleep(100)
		if(usr.HP>=prevHP&&usr.loc==prevloc&&!usr.KO)
			for(var/datum/Body/C in usr.body)
				if(C.health < C.maxhealth&&C.artificial)
					C.health += 10
					C.health = min(C.health, C.maxhealth)
			view(usr)<<"[usr] repairs themselves!"
			del(src)
		return

obj/items/Mechanical_Kit
	icon = 'PDA.dmi'
	verb/Install_Module(mob/T in view(1))
		set category = null
		set src in view(1)
		if(!T.KO&&T!=usr)
			var/agree = alert(T,"[usr] wants to install something into you. Do you accept?","","Yes","No")
			if(agree=="No")
				usr<<"[T] does not agree to your installation."
				return
		var/list/installchoice = list()
		var/obj/Modules/B=null
		for(var/obj/Modules/A in usr.contents)
			if(!A.isequipped)
				installchoice+=A
		if(installchoice.len>=1)
			B=input(usr,"Which module do you want to install?","",null) as null|anything in installchoice
			if(!B)
				return
		else
			usr<<"You have no modules to install!"
			return
		var/list/limbselection = list()
		for(var/datum/Body/C in T.body)
			limbselection += C
		var/datum/Body/choice = input(usr,"Choose the limb to attach the module to.","",null) as null|anything in limbselection
		if(!isnull(choice))
			if(istype(choice,/datum/Body))
			else return
			if(B.allowedlimb)
				if(choice.type==B.allowedlimb)
				else
					usr<<"This module cannot be installed in this limb!"
					return
			if(choice.artificial >= B.requireartificial&&!choice.artificial >= B.requireorganic&&choice.lopped==B.requirelopped)//first check tests if the limb is artificial and required to be, second checks orgainic (not artificial) and required to be
			else
				usr<<"This limb is not biologically compatible with this module!"
				return
			if(B.requiredupgrade)
				var/prereq=0
				for(var/obj/Modules/M in choice.Modules)
					if(M.type==B.requiredupgrade)
						prereq+=1
				if(prereq>=1)
				else
					usr<<"You lack the prerequisites to install this!"
					return
			if(B.disallowedupgrade)
				var/disallow=0
				for(var/obj/Modules/M in choice.Modules)
					if(M.type==B.disallowedupgrade)
						disallow+=1
				if(disallow==0)
				else
					usr<<"This module is incompatible with a currently installed module"
					return
			if(B.requiredslots>choice.capacity)
				usr<<"There is not enough room for this module"
				return
			B.place(choice,T)
			T.EquippedModules += B
			spawn(1)
			B.equip()
			spawn(1)
			B.savant=T
			usr<<"Module Installed"
	verb/Uninstall_Module(mob/T in view(1))
		set category = null
		set src in view(1)
		if(!T.KO&&T!=usr)
			var/agree = alert(T,"[usr] wants to uninstall something from you. Do you accept?","","Yes","No")
			if(agree=="No")
				usr<<"[T] does not agree to your uninstallation."
				return
		var/list/uninstalllimb = list()
		var/list/uninstallchoice = list()
		var/obj/Modules/B=null
		var/datum/Body/U=null
		for(var/datum/Body/L in T.body)
			if(L.Modules.len>=1)
				uninstalllimb+=L
		if(uninstalllimb.len>=1)
			U=input(usr,"Which limb do you want to uninstall from?","",null) as null|anything in uninstalllimb
			if(!U)
				return
		else
			usr<<"You have no modules to uninstall!"
			return
		for(var/obj/Modules/A in U.Modules)
			if(A.isequipped&&A.canuninstall)
				uninstallchoice+=A
		if(uninstallchoice.len>=1)
			B=input(usr,"Which module do you want to uninstall?","",null) as null|anything in uninstallchoice
			if(!B)
				return
		else
			usr<<"You have no modules to uninstall!"
			return
		B.unequip()
		B.remove()
		B.logout()
		B.login(T)
		T.EquippedModules -= B
		usr<<"Module Uninstalled"
	verb/Check_Module_Energy(mob/T in view(1))
		set category = null
		set src in view(1)
		for(var/obj/Modules/A in T.contents)
			if(A.elec_energy_max)
				view(src)<<"<font color=gray>[A.name] is at [A.elec_energy] out of [A.elec_energy_max]"
	verb/Check_Module_Health(mob/T in view(1))
		set category = null
		set src in view(1)
		for(var/obj/Modules/A in T.contents)
			if(A.integrity)
				view(src)<<"<font color=gray>[A.name] is at [A.integrity] out of 10"
			else
				view(src)<<"<font color=gray>[A.name] is non-functional! (Functioning equal to [A.functional])"
	verb/Scan_Limb(mob/T in view(1))
		set category = null
		set src in view(1)
		for(var/datum/Body/Z in T.body)
			if(!Z.lopped&&Z.artificial)
				view(src)<<"<font color=gray>[Z.name] is at [Z.health] out of [Z.maxhealth]"


obj/Modules/Infinite_Energy_Core
	elec_energy_max = 1e+010
	Ticker()
		if(isequipped&&functional&&savant)
			elec_energy=elec_energy_max
			spawn
				for(var/obj/Modules/A in savant)
					if(A.elec_energy<A.elec_energy_max)
						elec_energy-=(A.elec_energy_max - A.elec_energy)*0.1
						A.elec_energy+=(A.elec_energy_max - A.elec_energy)*0.1
				if(savant.stamina<savant.maxstamina)
					elec_energy-=(savant.maxstamina - savant.stamina)*0.1
					savant.stamina+=(savant.maxstamina - savant.stamina)*0.1
				if(savant.Ki<savant.MaxKi)
					elec_energy-=(savant.maxstamina - savant.stamina)*0.1
					savant.Ki+=(savant.MaxKi - savant.Ki)*0.01
		sleep(100)
		..()

obj/Modules/Repair_Core
	desc = "Automatically repairs modules. The more expansive the damage, the more energy it takes. A non-functioning module for instance will take a tenth of this modules power. If you're an android or cyborg, this also helps fix limbs."
	elec_energy_max = 1000
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
							if(!isnull(choice)&&prob(10))
								if(choice.lopped&&prob(1))
									choice.RegrowLimb()
								else
									choice.health += 1
									choice.health = min(choice.health,choice.maxhealth)
		done
		..()

obj/Modules/Energy_Core
	desc="Slowly gives you Ki back from energy production"
	elec_energy_max = 10000
	elec_energy = 100
	Ticker()
		if(isequipped&&functional&&savant)
			spawn
				if(savant.Ki < savant.MaxKi)
					if(elec_energy>=1)
						elec_energy-=1
						savant.Ki+=savant.MaxKi*0.01

		..()

obj/Modules/Mega_Buster
	allowedlimb = /datum/Body/Arm/Hand
	var/ogartificial = 0
	var/power = 1
	var/range = 1
	var/rapid = 1
	var/charge = 0
	desc="An energy cannon that replaces the user's hand. Reduces the durability of that hand, but enables the user to fire blasts at a target."
	icon='Mega Buster.dmi'
	elec_energy_max = 1000
	elec_energy = 1000

	equip()
		parent_limb.maxhealth *=0.75
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		if(parent_limb.health>parent_limb.maxhealth)
			parent_limb.health=parent_limb.maxhealth
		..()
	unequip()
		parent_limb.maxhealth /= 0.75
		parent_limb.artificial=ogartificial
		..()

	verb/Upgrade_Buster()
		desc="Upgrade your buster's abilities!"
		thechoices
		if(usr.KO) return
		var/cost=0
		var/list/Choices=new/list
		Choices.Add("Cancel")
		if(usr.zenni>=10*src.elec_energy_max&&usr.techskill>=src.elec_energy_max/100)
			Choices.Add("Max Energy ([10*src.elec_energy_max]z)")
		if(usr.zenni>=100000*src.power&&usr.techskill>=src.power*25)
			Choices.Add("Power ([100000*src.power]z)")
		if(usr.zenni>=100000*src.range&&usr.techskill>=src.range*25)
			Choices.Add("Range ([100000*src.range]z)")
		if(usr.zenni>=100000*src.rapid&&usr.techskill>=src.rapid*25)
			Choices.Add("Rapid ([100000*src.rapid]z)")
		if(!src.charge&&usr.zenni>=1000000&&usr.techskill>=60)
			Choices.Add("Charged Shots ([1000000]z)")
		var/A=input("Upgrade what?") in Choices
		if(A=="Cancel") return
		if(A=="Max Energy ([10*src.elec_energy_max]z)")
			cost=10*src.elec_energy_max
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Energy increased!"
				src.elec_energy_max += 1000
		if(A=="Power ([100000*src.power]z)")
			cost=100000*src.power
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Power increased!"
				src.power += 1
		if(A=="Range ([100000*src.range]z)")
			cost=100000*src.range
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Range increased!"
				src.range += 1
		if(A=="Rapid ([100000*src.rapid]z)")
			cost=100000*src.rapid
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Rapid increased!"
				src.rapid += 1
		if(A=="Charged Shots ([1000000]z)")
			cost=1000000
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Charged Shots enabled!"
				src.charge = 1
		usr<<"Cost: [cost]z"
		usr.zenni-=cost
		goto thechoices

	verb/Check_Buster_Stats()
		desc="Check the stats of your buster"
		usr<<"Your buster has [src.elec_energy] out of [src.elec_energy_max] charge remaining"
		usr<<"Your buster's statistics are: Power: [src.power], Range: [src.range], Rapid: [src.rapid]"
		if(charge)
			usr<<"You can charge your buster's shots"
		if(!charge)
			usr<<"You cannot charge your buster's shots"

	verb/Shoot_Buster()
		set category="Skills"
		desc="Fire your buster, using some energy in the process"
		if(isequipped&&functional)
			if(!charge)
				if(elec_energy>=100)
					if(!usr.med&&!usr.train&&!usr.KO&&!usr.buster)
						usr.buster=1
						src.elec_energy -= 100
						var/obj/attack/blast/A=new/obj/attack/blast/
						A.loc=locate(usr.x, usr.y, usr.z)
						A.icon='Blast5.dmi'
						A.density=1
						A.basedamage = src.power/5
						A.mods = usr.Etechnique*usr.techmod
						A.BP = usr.BP
						A.murderToggle=usr.murderToggle
						A.proprietor=usr
						A.ownkey=usr.displaykey
						A.dir=usr.dir
						A.Burnout(10*src.range)
						if(usr.target)
							step(A,get_dir(A,usr.target))
							walk(A,get_dir(A,usr.target))
						else
							walk(A,usr.dir)
						usr.icon_state = "Attack"
						usr.updateOverlay(/obj/overlay/effects/MegaBusterEffect)
						usr.emit_Sound('KIBLAST.WAV')
						sleep(10/src.rapid)
						usr.removeOverlay(/obj/overlay/effects/MegaBusterEffect)
						usr.icon_state = ""
						usr.buster=0
					else
						return
				else
					usr<<"Your buster is out of energy!"
					return
			else if(charge)
				if(!usr.bustercharge)
					usr.bustercharge = 1
				else if(usr.bustercharge)
					if(elec_energy>=100)
						if(!usr.med&&!usr.train&&!usr.KO&&!usr.buster)
							usr.buster=1
							src.elec_energy -= 100
							var/obj/attack/blast/A=new/obj/attack/blast/
							A.loc=locate(usr.x, usr.y, usr.z)
							if(usr.bustercharge>2)
								A.icon='Blast4.dmi'
							else
								A.icon='Blast5.dmi'
							A.density=1
							A.basedamage = src.power*usr.bustercharge/5
							A.mods = usr.Etechnique*usr.techmod
							A.BP = usr.BP
							A.murderToggle=usr.murderToggle
							A.proprietor=usr
							A.ownkey=usr.displaykey
							A.dir=usr.dir
							A.Burnout(10*src.range*usr.bustercharge)
							if(usr.target)
								step(A,get_dir(A,usr.target))
								walk(A,get_dir(A,usr.target))
							else
								walk(A,usr.dir)
							usr.icon_state = "Attack"
							usr.updateOverlay(/obj/overlay/effects/MegaBusterEffect)
							usr.emit_Sound('KIBLAST.WAV')
							spawn(10/src.rapid)
							usr.removeOverlay(/obj/overlay/effects/MegaBusterEffect)
							usr.icon_state = ""
							usr.buster=0
							usr.bustercharge=0
						else
							return
					else
						usr<<"Your buster is out of energy!"
						return
		else
			usr<<"Your buster is not equiped!"
			return

	Ticker()
		if(isequipped&&functional)
			if(elec_energy<elec_energy_max)
				elec_energy += 50
			if(savant)
				if(savant.bustercharge>0)
					if(savant.bustercharge>2)
						savant.updateOverlay(/obj/overlay/effects/MegaBusterCharge)
						savant.poweruprunning = 1
					if(savant.bustercharge<4)
						savant.bustercharge += 1
				else if(!savant.bustercharge)
					savant.removeOverlay(/obj/overlay/effects/MegaBusterCharge)
					savant.poweruprunning = 0
				if(savant.lasering&&(savant.charging||savant.beaming))
					if(elec_energy>10000/savant.techskill)
						elec_energy-=10000/savant.techskill
					else
						savant.stopbeaming()
		..()

obj/overlay/effects/MegaBusterEffect
	icon = 'Mega Buster.dmi'
	icon_state = "Attack"

obj/overlay/effects/MegaBusterCharge
	icon = 'GivePower.dmi'

obj/Modules/Cybernetic_Upgrade
	allowedlimb = null
	requireorganic = 1
	icon = 'Body Parts Bloodless.dmi'
	var/ogartificial = 0
	desc="Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities"

	equip()
		parent_limb.maxhealth*=1.25
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		savant.genome.sub_to_stat("Energy Level",0.05)
		savant.kiskillMod /= 1.01
		savant.kioffMod /= 1.05
		if(parent_limb.health>parent_limb.maxhealth)
			parent_limb.health=parent_limb.maxhealth
		..()

	unequip()
		parent_limb.maxhealth/=1.25
		parent_limb.artificial=ogartificial
		savant.genome.add_to_stat("Energy Level",0.05)
		savant.kiskillMod *= 1.01
		savant.kioffMod *= 1.05
		..()
	Torso
		name="Cybernetic Torso Upgrade"
		icon_state = "Torso"
		allowedlimb = /datum/Body/Torso
	Abdomen
		name="Cybernetic Abdomen Upgrade"
		icon_state = "Abdomen"
		allowedlimb = /datum/Body/Abdomen
	HandL
		name="Cybernetic Hand Upgrade L"
		icon_state = "Hands"
		allowedlimb = /datum/Body/Arm/Hand
	HandR
		name="Cybernetic Hand Upgrade R"
		icon_state = "Hands"
		allowedlimb = /datum/Body/Arm/Hand
	ArmL
		name="Cybernetic Arm Upgrade L"
		icon_state = "Arm"
		allowedlimb = /datum/Body/Arm
	ArmR
		name="Cybernetic Arm Upgrade R"
		icon_state = "Arm"
		allowedlimb = /datum/Body/Arm
	LegL
		name="Cybernetic Leg Upgrade L"
		icon_state = "Limb"
		allowedlimb = /datum/Body/Leg
	LegR
		name="Cybernetic Leg Upgrade R"
		icon_state = "Limb"
		allowedlimb = /datum/Body/Leg
	FootL
		name="Cybernetic Foot Upgrade L"
		icon_state = "Foot"
		allowedlimb = /datum/Body/Leg/Foot
	FootR
		name="Cybernetic Foot Upgrade R"
		icon_state = "Foot"
		allowedlimb = /datum/Body/Leg/Foot

obj/Modules/Metabolic_Interchange
	allowedlimb = /datum/Body/Organs
	requireorganic = 1
	var/ogartificial = 0
	desc = "Interconnects the digestive system and power supply. Energy drains will be regularly counteracted by increasing hunger. Can be toggled on and off at will."
	elec_energy_max = 1000
	elec_energy = 100

	equip()
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		..()

	unequip()
		parent_limb.artificial=ogartificial
		..()

	verb/Metabolic_Exchange()
		set category = "Skills"
		desc="Converts nutrition into ki."
		if(isequipped&&functional)
			if(usr.currentNutrition>0&&usr.Ki<usr.MaxKi&&usr.exchange==0)
				usr.exchange=1//I defined this variable for the mob at the top of the DM, it tells us if we should be converting or not
				usr<<"You begin converting nutrition into ki!"
			else
				usr.exchange=0
				usr<<"You are not converting nutriton"
		else
			usr<<"You don't have this equiped!"

	Ticker()
		if(isequipped&&functional)
			if(savant)
				if(savant.exchange==1&&savant.currentNutrition>0&&savant.Ki<savant.MaxKi)
					savant.Ki+=0.003*savant.MaxKi
					savant.currentNutrition-=0.01
				else
					savant.exchange=0
		..()

obj/Modules/Metabolic_Autonomer
	allowedlimb = /datum/Body/Organs
	requireorganic = 1
	var/ogartificial = 0
	var/breakme
	desc = "Automatically consumes food via short range teleportation."
	elec_energy_max = 1000
	elec_energy = 100

	equip()
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		..()

	unequip()
		parent_limb.artificial=ogartificial
		..()

	verb/Metabolic_Reset()
		set category = null
		set src in usr
		desc="Resets the Autonomer in case of issue."
		if(isequipped&&functional)
			if(usr.currentNutrition>0&&usr.Ki<usr.MaxKi&&breakme==1)
				breakme=0
				usr<<"You reset this module."
		else
			usr<<"You don't have this equiped!"

	Ticker()
		if(isequipped&&functional)
			if(savant)
				if(savant.currentNutrition<=0&&savant.stamina<savant.maxstamina*0.1)
					for(var/obj/items/food/S in savant.contents)
						usr.currentNutrition += S.nutrition
						if(prob(25))
							breakme = 1
							usr << "Metabolic Autonomer Module broken. Please reset."
						usr << "Food consumed."
						break
		..()

obj/Modules/Repair_Nanobots
	allowedlimb = /datum/Body/Torso
	requireorganic = 1
	var/ogartificial = 0
	desc = "Repairs organic limbs at the cost of ki. Can be toggled on and off."
	elec_energy_max = 1000
	elec_energy = 100

	equip()
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		..()

	unequip()
		parent_limb.artificial=ogartificial
		..()

	verb/Nano_Repair()
		set category = "Skills"
		desc="Converts ki into health."
		if(isequipped&&functional)
			if(usr.Ki>0&&usr.HP<100&&usr.exchange==0)
				usr.exchange=1//I defined this variable for the mob at the top of the DM, it tells us if we should be converting or not
				usr<<"You begin to regenerate!"
			else
				usr.exchange=0
				usr<<"You stop regenerating"
		else
			usr<<"You don't have this equiped!"

	Ticker()
		if(isequipped&&functional)
			if(savant)
				if(prob(5))
					savant.SpreadHeal(0.1,null,1)
				if(savant.exchange==1&&savant.Ki>0&&savant.HP<100)
					savant.Ki-=0.02*savant.MaxKi
					savant.SpreadHeal(0.5,null,1)
				else
					savant.exchange=0
		..()
obj/Modules/Rebreather_Module
	allowedlimb = /datum/Body/Torso
	requireorganic = 0
	var/ogartificial = 0
	var/ogspacebreather=0
	desc = "Hold your breath. Goes in your torso"
	elec_energy_max = 100
	elec_energy = 100
	equip()
		ogartificial = parent_limb.artificial
		ogspacebreather=savant.spacebreather
		savant.spacebreather=1
		parent_limb.artificial=1
		..()

	unequip()
		ogspacebreather=savant.spacebreather
		savant.spacebreather=0
		parent_limb.artificial=ogartificial
		..()

obj/Modules/Levitation_Systems
	allowedlimb = /datum/Body/Leg
	requireartificial = 1
	var/ogartificial = 0
	var/tmp/isactive = 0
	elec_energy_max = 1000
	elec_energy = 100
	desc = "Defy gravity for FREE*. Install in an artificial leg. *Note: Not actually free, uses energy from the module."

	verb/Levitate()
		set category = "Skills"
		if(isequipped&&functional)
			if(usr&&usr.flight&&isactive)
				usr.freeflight=0
				usr.flight = 0
				if(usr.Savable) usr.icon_state=""
				usr<<"You land back on the ground."
				usr.isflying=0
				isactive=0
			else if(src.elec_energy>5&&!usr.KO&&!isactive)
				usr.Deoccupy()
				usr.freeflight=1
				usr.flight=1
				usr.swim=0
				usr.isflying=1
				isactive=1
				usr<<"You begin to levitate through your module."
				if(usr.Savable) usr.icon_state="Flight"
			else
				usr<<"You are unable to levitate"
				isactive=0

	Ticker()
		if(parent_limb)
			if(!parent_limb.artificial)
				unequip()
				remove()
		if(isequipped&&functional)
			if(savant&&savant.flight&&isactive)
				if(usr.Savable) savant.icon_state="Flight"
				if(elec_energy>5)
					elec_energy-=5
				else
					savant.freeflight=0
					savant.flight=0
					savant.isflying=0
					isactive=0
					savant<<"Your levitation systems have run out of energy, sending you to the ground!"
			if(elec_energy<elec_energy_max)
				elec_energy+=1
		..()
obj/Modules/Rocket_Punch
	allowedlimb = /datum/Body/Arm/Hand
	var/ogartificial = 0
	var/power = 1
	var/range = 1
	desc="A detachable hand propelled at extreme speeds. Enables one to punch from afar."
	icon='rocketpunch.dmi'
	elec_energy_max = 100
	elec_energy = 100

	equip()
		parent_limb.maxhealth*=1.11
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		if(parent_limb.health>parent_limb.maxhealth)
			parent_limb.health=parent_limb.maxhealth
		..()
	unequip()
		parent_limb.maxhealth /= 1.11
		parent_limb.artificial=ogartificial
		..()
	verb/Upgrade_RocketPunch()
		desc="Make your Rocket pack more Punch!"
		thechoices
		if(usr.KO) return
		var/cost=0
		var/list/Choices=new/list
		Choices.Add("Cancel")
		if(usr.zenni>=10000*src.power&&usr.techskill>=src.power*10)
			Choices.Add("Power ([10000*src.power]z)")
		if(usr.zenni>=100000*src.range&&usr.techskill>=src.range*25)
			Choices.Add("Range ([100000*src.range]z)")
		var/A=input("Upgrade what?") in Choices
		if(A=="Cancel") return
		if(A=="Power ([10000*src.power]z)")
			cost=10000*src.power
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Power increased!"
				src.power += 1
		if(A=="Range ([100000*src.range]z)")
			cost=100000*src.range
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
			else
				usr<<"Range increased!"
				src.range += 1
		usr<<"Cost: [cost]z"
		usr.zenni-=cost
		goto thechoices

	verb/Check_RocketPunch()
		set category="Other"
		desc="Check the stats of your Rocket Punch"
		usr<<"Your manly fist's statistics are: Power: [src.power], Range: [src.range]"

	verb/ROCKETO_PUNCH()
		set category="Skills"
		desc="Fire your fist, to punch someone."
		if(isequipped&&functional)
			if(elec_energy>=100)
				if(!usr.med&&!usr.train&&!usr.KO&&!usr.buster)
					usr.buster=1
					src.elec_energy -= 99
					var/obj/attack/blast/A=new/obj/attack/blast/
					A.loc=locate(usr.x, usr.y, usr.z)
					A.icon='rocketpunch.dmi'
					A.density=1
					A.basedamage = src.power
					A.physdamage = 1
					A.mods = usr.Etechnique*usr.techmod
					A.BP = usr.BP
					A.murderToggle=usr.murderToggle
					A.proprietor=usr
					A.ownkey=usr.displaykey
					A.dir=usr.dir
					A.Burnout()
					if(usr.target)
						step(A,get_dir(A,usr.target))
						walk(A,get_dir(A,usr.target))
					else
						walk(A,usr.dir)
					usr.icon_state = "Attack"
					usr.emit_Sound('rockmoving.WAV')
					sleep(5)
					usr.icon_state = ""
					usr.buster=0
				else
					usr<<"You can't do this right now!"
					return
			else
				usr<<"You need to wait for your fist!"
				return
		else
			usr<<"Your fist is not equiped!"
			return

	Ticker()
		if(elec_energy<elec_energy_max)
			elec_energy += 1
		..()

obj/Modules/Advanced_Targeting_Systems
	allowedlimb = /datum/Body/Head/Brain
	desc = "Enhance your sensory pathways with cybernetic technology, enabling a built-in set of scanning functions."
	equip()
		savant.scouteron=1
		..()
	unequip()
		savant.scouteron=0
		..()
	Ticker()
		if(savant)
			if(!savant.scouteron)
				savant.scouteron = 1
		..()
	verb/Assess_Target(mob/M in view(usr))
		var/accuracy = 1
		if(isequipped&&functional)
			usr<<"<font color=green><br>-----<br>Scanning..."
			sleep(10)
			usr<<"<font color=green>Battle Power: [num2text((round(M.BP,accuracy)),20)]<br>-Scan Complete-"
			if(M.Race=="Saiyan") usr<<"<font color=green>Records show this [M.Race] was born with [M.FirstYearPower] Battle Power."
			usr<<"<font color=green>Target Statistics:"
			usr<<"<font color=green>Physical Offense - [M.Ephysoff]"
			usr<<"<font color=green>Physical Defense - [M.Ephysdef]"
			usr<<"<font color=green>Ki Offense - [M.Ekioff]"
			usr<<"<font color=green>Ki Defense - [M.Ekidef]"
			usr<<"<font color=green>Technique - [M.Etechnique]"
			usr<<"<font color=green>Ki Skill - [M.Ekiskill]"
			usr<<"<font color=green>Speed - [M.Espeed]"
			var/Threat=0
			if(usr.Ephysoff>=usr.Ekioff)
				Threat = (usr.expressedBP/M.expressedBP)*(usr.Ephysoff/M.Ephysdef)*(usr.Etechnique/M.Etechnique)
			else
				Threat = (usr.expressedBP/M.expressedBP)*(usr.Ekioff/M.Ekidef)*(usr.Ekiskill/M.Ekiskill)
			if(Threat>2)
				usr<<"<font color=green>Threat Level: None"
			else if(Threat>1.1)
				usr<<"<font color=yellow>Threat Level: Weak"
			else if(Threat>0.9)
				usr<<"<font color=white>Threat Level: Standard"
			else if(Threat>0.5)
				usr<<"<font color=#FF9900>Threat Level: Strong"
			else if(Threat>0.1)
				usr<<"<font color=red>Threat Level: Dangerous"
			else
				usr<<"<font color=purple>Threat Level: Overwhelming"
		else
			usr<<"Your targetting systems are not functional currently!"

obj/Modules/Hydraulic_Force_Multiplier
	desc = "Improve the force your muscles can output with advanced hydraulics originating from your abdomen. Requires artifical abdominal support to function. Also makes your body more fragile by exposing limbs to greater force transfer."
	allowedlimb = /datum/Body/Abdomen
	requireartificial=1
	var/ogartificial = 0

	equip()
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		savant.physoffMod *= 1.2
		savant.physdefMod /= 1.15
		savant.kidefMod /= 1.15
		..()

	unequip()
		parent_limb.artificial=ogartificial
		savant.physoffMod /= 1.2
		savant.physdefMod *= 1.15
		savant.kidefMod *= 1.15
		..()

	Ticker()
		if(parent_limb)
			if(!parent_limb.artificial)
				unequip()
				remove()
		..()
obj/Modules/Forcefield_Generator
	desc="Generate a field that shields you from energy attacks. Requires energy for each deflection. Too much usage can overload the module, destroying it and the limb it is embedded within."
	elec_energy_max = 10000
	elec_energy = 0
	takeDamage(var/D)
		superCalc()
		if(D>superarmor)
			armor-=(D-superarmor)
		armor = max(0,armor)
		if(armor>0) integrity = armor/maxarmor
		else integrity = 0
	superCalc()
		superarmor = 0.08*maxarmor
	Ticker()
		if(isequipped&&functional)
			if(savant)
				savant.hasForcefield=1
				savant.forcefieldID=src
				if(integrity<=0)
					functional=0
				if(!functional&&parent_limb)
					savant<<"Your forcefield generator has overloaded and exploded, taking the limb with it and damaging you!"
					savant.SpreadDamage(10)
					savant.emit_Sound('kiplosion.wav')
					spawnExplosion(location=savant.loc)
					savant.hasForcefield=0
					parent_limb.LopLimb()
		..()

obj/Modules/Matter_Assimilator
	desc="Deconstruct the matter of whomever you are grabbing, converting that matter into energy for yourself."
	allowedlimb=/datum/Body/Arm/Hand
	verb/Matter_Assimilation()
		set category = "Skills"
		if(isequipped&&functional)
			if(usr.grabMode==2&&usr.grabbee&&usr.assimilating==0)
				usr<<"You begin assimilating [usr.grabbee]'s matter!"
				usr.grabbee<<"[usr] begins assimilating your matter!"
				usr.assimilating=1
				while(usr.grabMode==2&&usr.grabbee&&usr.assimilating==1)
					var/dmg=((usr.Ephysoff/usr.grabbee.Ephysdef)*BPModulus(usr.expressedBP, usr.grabbee.expressedBP)/10)
					usr.grabbee.SpreadDamage(dmg)
					usr.SpreadHeal(dmg,0,1)
					if(usr.Ki<usr.MaxKi)
						usr.Ki+=min(dmg,usr.MaxKi)
					if(usr.stamina<usr.maxstamina)
						usr.stamina+=min(dmg, usr.maxstamina)
					sleep(5)
				usr.assimilating=0
			else if(usr.grabMode==2&&usr.grabbee&&usr.assimilating==1)
				usr.grabbee<<"[usr] stops assimilating your matter!"
				usr<<"You stop assimilating [usr.grabbee]'s matter!"
				usr.assimilating=0
			else
				usr<<"You must be holding a target to assimilate their matter!"
		else
			usr<<"Your module is either uninstalled or broken!"

obj/Modules/Limiter_Overload
	desc="Remove the limiters on your artificial limbs, greatly increasing your power at the cost of damaging your limbs and modules from the increased load"
	allowedlimb=/datum/Body/Torso
	elec_energy_max=200
	verb/Limiter_Overload()
		set category = "Skills"
		if(isequipped&&functional&&!usr.KO&&!usr.limiteroverload)
			usr<<"You remove the limits to your power usage. OVERDRIVE ENGAGED"
			usr.limiteroverload=1
			usr.startbuff(/obj/buff/limiteroverload)
		else if(usr.isBuffed(/obj/buff/limiteroverload))
			usr<<"You relimit your power expenditure"
			usr.stopbuff(/obj/buff/limiteroverload)
			usr.limiteroverload=0
		else
			usr.limiteroverload=0
obj/Modules/Energy_Capacitor
	desc="Convert the energy from ki-based attacks into usable energy for your body. WARNING: Module can overload if too much energy is absorbed, and will explode. Install in a hand."
	allowedlimb=/datum/Body/Arm/Hand
	equip()
		savant.blastabsorb=1
		..()
	unequip()
		savant.blastabsorb=0
		..()
	Ticker()
		if(isequipped&&functional)
			if(savant)
				savant.blastabsorb=1
				if(integrity<=0)
					functional=0
				if(!functional&&parent_limb)
					savant<<"Your energy capacitor has overloaded and exploded, taking the limb with it and damaging you!"
					savant.SpreadDamage(10)
					savant.emit_Sound('kiplosion.wav')
					spawnExplosion(location=savant.loc)
					savant.blastabsorb=0
					parent_limb.LopLimb()
		..()
obj/Modules/Refractor_Upgrade
	desc="Install a refractor into your buster, enabling you to fire a concentrated beam of energy."
	allowedlimb=/datum/Body/Arm/Hand
	requiredupgrade=/obj/Modules/Mega_Buster
	disallowedupgrade=/obj/Modules/Refractor_Upgrade
	requiredslots=0
	verb/Refractor_Laser()
		set category = "Skills"
		var/energyreq=10000/usr.techskill
		if(isequipped&&functional)
			if(usr.beaming)
				usr.canmove = 1
				usr.stopbeaming()
				usr.removeOverlay(/obj/overlay/effects/MegaBusterCharge)
				return
			for(var/obj/Modules/Mega_Buster/M in parent_limb.Modules)
				if(M.elec_energy>=energyreq)
					if(usr.charging)
						usr.beaming=1
						usr.lasering=1
						usr.charging=0
						return
					if(!usr.charging&&!usr.KO&&!usr.med&&!usr.train&&usr.canfight)
						usr.icon_state="Blast"
						usr.forceicon='Beam3.dmi'
						usr.canmove = 0
						usr.lastbeamcost=0
						usr.beammods = usr.Etechnique*usr.techmod
						usr.beamspeed=1
						usr.powmod=1
						usr.maxdistance=30
						//usr.canfight = 0
						usr.lasering=1
						usr.charging=1
						usr.piercer=1
						usr.updateOverlay(/obj/overlay/effects/MegaBusterCharge)
					return
				else src << "Your buster is out of energy!"
obj/Modules/Abdominal_Machinegun
	desc="German science is the greatest in the world! Installs a machinegun into your abdomen, allowing you to open fire!"
	allowedlimb=/datum/Body/Abdomen
	elec_energy_max=500
	verb/Fire_Machinegun()
		set category = "Skills"
		if(isequipped&&functional)
			if(!usr.mgun&&!usr.KO&&!usr.med&&!usr.train&&usr.canfight)
				usr<<"You open fire with your abdominal machinegun!"
				usr.mgun=1
				usr.updateOverlay(/obj/overlay/effects/AbMachinegun)
				while(usr.mgun&&elec_energy>=1&&!usr.KO&&!usr.med&&!usr.train&&usr.canfight)
					elec_energy-=5
					var/obj/attack/blast/A=new/obj/attack/blast/
					A.loc=locate(usr.x, usr.y, usr.z)
					A.icon='Bullet 3.dmi'
					A.density=1
					A.basedamage = 1
					A.physdamage = 1
					A.mods = usr.Etechnique*usr.techmod
					A.BP = usr.BP
					A.murderToggle=usr.murderToggle
					A.proprietor=usr
					A.ownkey=usr.displaykey
					A.dir=usr.dir
					A.ogdir=usr.dir
					A.Burnout(20)
					A.spawnspread()
					walk(A,A.dir)
					sleep(2)
				usr.mgun=0
				usr.removeOverlay(/obj/overlay/effects/AbMachinegun)
				usr<<"You stop firing your machinegun."
			if(usr.mgun)
				usr<<"You stop firing your machinegun."
				usr.mgun=0
				usr.removeOverlay(/obj/overlay/effects/AbMachinegun)
		else
			usr<<"Your machinegun is not functional!"

obj/overlay/effects/AbMachinegun
	icon = 'Abdominal_Machinegun.dmi'

obj/Modules/Portable_Missile_Launcher
	desc = "Install a portable homing missile system, complete with self-replenishing missiles."
	elec_energy_max = 200

	verb/Missile_Salvo()
		set category = "Skills"
		set src in usr
		if(isequipped&&functional)
			if(usr.target)
				if(!usr.hmissile)
					if(elec_energy>=100)
						elec_energy-=100
						usr.hmissile=1
						var/i=0
						for(i, i<7, i++)
							usr.emit_Sound('RPGshot.ogg',0.33)
							var/obj/attack/blast/A=new/obj/attack/blast/
							A.loc=locate(usr.x, usr.y, usr.z)
							A.icon='Missile Small.dmi'
							A.density=1
							A.avoidusr=1
							A.basedamage = 4
							A.physdamage = 1
							A.mods = usr.Etechnique*usr.techmod
							A.BP = usr.BP
							A.murderToggle=usr.murderToggle
							A.proprietor=usr
							A.ownkey=usr.displaykey
							A.dir=usr.dir
							spawn A.Burnout(50)
							if(usr.dir==get_dir(usr,usr.target))
								A.spawnspread()
							else
								A.spreadbehind()
								step_away(A,usr)
							walk_towards(A,usr.target)
							sleep(2)
						usr.hmissile=0
						i=0
					else
						usr<<"Your missiles are not fully replenished!"
						return
				else
					usr<<"You are currently firing missiles!"
					return
			else
				usr<<"You need a target!"
				return
		else
			usr<<"Your module is not in working condition."
			return

	Ticker()
		if(isequipped&&functional)
			if(elec_energy<elec_energy_max)
				elec_energy+=1
		..()

obj/Modules/Prosthetic_Limb
	allowedlimb = null
	requirelopped = 1
	requiredslots = 0
	disallowedupgrade = /obj/Modules/Prosthetic_Limb
	var/ogartificial = 0
	desc="Replace a lost limb with an inferior version. Reduces the limb's stats."
	equip()
		parent_limb.maxhealth*=0.5
		ogartificial = parent_limb.artificial
		parent_limb.artificial=1
		parent_limb.lopped=0
		parent_limb.health=parent_limb.maxhealth
		savant.genome.sub_to_stat("Energy Level",0.05)
		savant.kiskillMod /= 1.01
		savant.kioffMod /= 1.05
		if(parent_limb.health>parent_limb.maxhealth)
			parent_limb.health=parent_limb.maxhealth
		..()

	unequip()
		parent_limb.maxhealth/=0.5
		parent_limb.artificial=ogartificial
		savant.genome.add_to_stat("Energy Level",0.05)
		savant.kiskillMod *= 1.01
		savant.kioffMod *= 1.05
		parent_limb.lopped=1
		..()

obj/Creatables
	Repair_Kit
		icon='PDA.dmi'
		cost=10000
		neededtech=20
		desc = "A collection of various tools and spare parts used to repair artificial limbs."
		create_type = /obj/items/Repair_Kit

	Mechanical_Kit
		icon='PDA.dmi'
		cost=10000
		neededtech=20
		desc = "A mechanical kit is needed to instal modules and uninstall them."
		create_type = /obj/items/Mechanical_Kit