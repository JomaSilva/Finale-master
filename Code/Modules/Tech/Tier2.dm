obj/Creatables
	Simulator
		icon='Space.dmi'
		icon_state="terminal"
		cost=50000
		neededtech=45 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Simulators create mobs for you to defeat."
		create_type = /obj/items/Simulator
	Dragon_Radar
		icon='Misc2.dmi'
		icon_state="Radar"
		cost=150000
		neededtech=40
		desc="Dragon Radars let you locate any item, provided you set the radar to that item in the first place."
		create_type = /obj/items/Radar

	Power_Drill
		icon='Drill Giant.dmi'
		name = "Drill"
		cost=100000
		neededtech=30 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Power Drills let you create large amounts of cash without needing to dig yourself."
		create_type = /obj/Power_Drill
	Rebreather
		icon='Clothes, Ninja Mask.dmi'
		name = "Rebreather"
		cost=100000
		neededtech=30 //Deletes itself from contents if the usr doesnt have the needed tech
		desc="Rebreathers let you breathe in space."
		create_type = /obj/items/Rebreather
	Forcefield
		icon='Lab.dmi'
		icon_state="Computer 1"
		name = "Force Field"
		cost=150000
		neededtech=33
		desc="Forcefields will absorb incoming Ki attacks at the price of it's own armor."
		create_type = /obj/items/Forcefield
	Stungun
		icon='Item, Blaster.dmi'
		icon_state="Blaster Big"
		name = "Stun Gun"
		cost=150000
		neededtech=45
		desc="Stunguns can stun people, instantly KOing them. Naturally, this doesn't work on people with high health above 100 BP, and are not relaxed. Each shot is pretty expensive too. Best used on already weakened or downed opponents."
		create_type = /obj/items/Stungun
	Detonator
		icon='Cell Phone.dmi'
		name = "Detonator"
		cost=150000
		neededtech=33
		desc="Detonators can remotely trigger any bombs if given the right code."
		create_type = /obj/items/Detonator
	First_Aid_Kit
		icon='FirstAid.dmi'
		cost=100
		neededtech=30
		desc="A kit filled with various medical supplies. Can be used to heal, and has multiple uses."
		create_type = /obj/items/First_Aid_Kit
obj/items
	Simulator
		layer=MOB_LAYER+10
		SaveItem=1
		stackable=0
		New()
			..()
			while(src)
				if(NanoCore&&Health<MaxHealth)
					Health+=NanoCore
					if(Health>=MaxHealth)
						Health=MaxHealth
						view(src)<<"[src]: Nanites activated. Energy fully restored."
					else view(src)<<"[src]: Nanites activated. Energy partially restored."
				sleep(6000)
		icon='Space.dmi'
		icon_state="terminal"
		density=1
		var/maxbp=500
		var/Energy=1
		var/MaxEnergy=1
		var/Health=1
		var/MaxHealth=1
		var/NanoCore=0 //Recovers its own energy.
		verb/Info()
			set src in oview(1)
			set category=null
			usr<<"Armor: [Health*100] / [MaxHealth*100]"
			usr<<"Energy: [Energy*100] / [MaxEnergy*100]"
			usr<<"Sim Power: [round(maxbp)]"
			if(NanoCore) usr<<"Nano Regeneration: [NanoCore]"
			usr<<"Cost to make: [techcost]z"
		verb/Upgrade()
			set src in oview(1)
			set category=null
			if(usr.KO) return
			var/cost=0
			var/list/Choices=new/list
			Choices.Add("Cancel")
			if(usr.zenni>=500*(maxbp/500)) Choices.Add("Simulation Power ([500*(maxbp/500)]z)")
			if(usr.zenni>=1000*MaxEnergy) Choices.Add("Energy Expansion ([1000*MaxEnergy]z)")
			if(usr.zenni>=100*MaxHealth) Choices.Add("Durability ([100*MaxHealth]z)")
			if(usr.zenni>=3000*(NanoCore+1)&&usr.techskill>=5) Choices.Add("Nano Regeneration ([3000*(NanoCore+1)]z)")
			var/A=input("Upgrade what?") in Choices
			if(A=="Cancel") return
			if(A=="Simulation Power ([500*(maxbp/500)]z)")
				cost=500*(maxbp/500)
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Simulation power increased."
				maxbp*=2
			if(A=="Energy Expansion ([1000*MaxEnergy]z)")
				cost=1000*MaxEnergy
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Core expanded. Full energy restored."
				MaxEnergy+=1
				Energy=MaxEnergy
			if(A=="Durability ([100*MaxHealth]z)")
				cost=100*MaxHealth
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Durability increased. Armor fully restored"
				MaxHealth+=1
				Health=MaxHealth
			if(A=="Nano Regeneration ([3000*(NanoCore+1)]z)")
				cost=3000*(NanoCore+1)
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Nano Regeneration Increased."
				NanoCore+=1
			usr<<"Cost: [cost]z"
			usr.zenni-=cost
			tech+=1
			techcost+=cost
		verb/Start()
			set category=null
			set src in oview(1)
			if(Energy>=0.1)
				for(var/mob/M in NPC_list) if(M.name=="[usr] Simulation")
					M.deleteMe()
					usr<<"Simulations cancelled."
					return
			var/mob/npc/Enemy/Simulation/x
			x=new(loc)
			x.icon=usr.icon
			x.overlays=usr.overlays
			Energy-=0.1
			x.BP=usr.BP
			x.expressedBP=usr.expressedBP
			if(x.BP>maxbp) x.BP=maxbp
			if(x.BP<1) x.BP=1
			x.HP=100
			x.MaxAnger=100
			x.kidef = usr.Ekidef
			x.physdef=usr.Ephysdef + 1
			x.speed=usr.Espeed
			x.physoff=usr.Ephysoff + 1
			x.technique =usr.Etechnique
			x.movespeed=5
			x.sim=1
			x.name="[usr.name] Simulation"
			x.Owner=usr.key
			spawn step(x,SOUTH)
			spawn x.foundTarget(usr)
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
	food/Simulation_Meat
		icon='corpse.dmi'
		nutrition=3
		flavor="It's... simulation meat. How the hell did you harvest this? Tastes good though. The fruit of fuckin victory."

	Rebreather
		icon='Clothes, Ninja Mask.dmi'
		NotSavable=1
		verb/Equip()
			set category=null
			set src in usr
			if(equipped==0)
				equipped=1

				suffix="*Equipped*"
				usr.spacesuit+=1
				usr.overlayList+=icon
				usr.overlaychanged=1
				usr<<"You put on the [src]."
			else
				equipped=0
				suffix=""
				usr.spacesuit-=1
				usr.overlayList-=icon
				usr.overlaychanged=1
				usr<<"You take off the [src]."
	Forcefield
		icon='Lab.dmi'
		icon_state="Computer 1"
		name = "Force Field"
		stackable=0
		SaveItem = 1
		verb/Equip()
			set category=null
			set src in usr
			if(equipped==0)
				equipped=1
				usr.hasForcefield=1
				usr.forcefieldID = src
				suffix="*Equipped*"
				usr<<"You turn on the [src]."
			else
				equipped=0
				usr.hasForcefield=0
				usr.forcefieldID = null
				suffix=""
				usr<<"You turn off the [src]."
		superCalc()
			superarmor = 0.05*maxarmor
		testDestroy()
			if(armor<=0)
				if(ismob(src.loc)&&equipped)
					var/mob/M = src.loc
					M.hasForcefield=0
					M.forcefieldID = null
					step(src,M.dir)
				var/destroycheck=0
				for(var/turf/T in loc)
					if(!T.destroyable)
						destroycheck++
				if(!destroycheck)
					new/turf/Ground/Ground8(src.loc)
				emit_Sound('kiplosion.wav')
				spawnExplosion(location=src.loc)
				del(src)
		Del()
			if(ismob(src.loc)&&equipped)
				var/mob/M = src.loc
				M.hasForcefield=0
				M.forcefieldID = null
			..()
	Detonator
		icon='Cell Phone.dmi'
		name = "Detonator"
		SaveItem = 1
		stackable=0
		var/code
		var/countdown
		var/isCanceled
		var/running
		verb/Set()
			set category=null
			set src in usr
			code = input(usr,"Set the code. Any bombs with this code will go off.") as text
			countdown = input(usr,"Set the countdown in seconds. If the detonator is running, it will have a suffix and 'Use' will cancel.") as num
		verb/Cancel()
			set category=null
			set src in usr
			isCanceled=1
			sleep(30)
			isCanceled=0
			return
		verb/Use()
			set category=null
			set src in usr
			if(running)
				isCanceled=1
				sleep(30)
				isCanceled=0
				return
			spawn while(countdown)
				sleep(10)
				countdown-=1
				running = 1
				if(isCanceled)
					isCanceled=0
					running = 0
					return
				if(countdown<=0)
					countdown=0
					running=0
					isCanceled=0
					for(var/obj/items/Bomb/B in world)
						if(B.code == code)
							B.explode()
	Stungun
		icon='Item, Blaster.dmi'
		icon_state="Blaster Big"
		name = "Stun Gun"
		stackable=0
		var
			BlasterR=0
			BlasterG=0
			BlasterB=0
		var/used = 0 //stun guns have 1 ammo, not upgradable except for stun strength.
		var/strength = 100 //stun guns can down anyone under 100 BP instantly regardless of HP- but raw stats are the counter to this. Later on you want to upgrade this, and over 100 BP the HP threshold is a whopping 15.
		New()
			..()
			BlasterR=rand(0,255)
			BlasterG=rand(0,255)
			BlasterB=rand(0,255)
		verb/Reload()
			set category=null
			set src in usr
			var/cost=0
			var/list/Choices=new/list
			Choices.Add("Cancel")
			if(usr.zenni>=100*log(usr.intBPcap)) Choices.Add("Reload ([100*log(usr.intBPcap)]z)")
			var/A=input("Upgrade what?") in Choices
			if(A=="Cancel") return
			if(A=="Reload ([100*log(usr.intBPcap)]z)")
				cost=100*log(usr.intBPcap)
				if(usr.zenni<cost)
					usr<<"You do not have enough money ([cost]z)"
					return
				usr<<"Reloaded."
			usr<<"Cost: [cost]z"
			usr.zenni-=cost
		verb/Use()
			set category=null
			set src in usr
			if(!usr.med&&!usr.train&&!usr.KO&&!usr.blasting&&used==0)
				usr.blasting=1
				used = 1
				var/obj/attack/blast/A=new/obj/attack/blast/
				A.loc=locate(usr.x,usr.y,usr.z)
				A.icon='23.dmi'
				A.icon_state="23"
				A.icon+=rgb(BlasterR,BlasterG,BlasterB)
				A.density=1
				A.paralysis=2
				A.BP=strength
				A.murderToggle=0
				if(prob(1))
					A.BP*=10
				walk(A,usr.dir)
				spawn(100)
					usr.blasting=0
		Click()
			var/cost=100*log(usr.intBPcap)
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			strength = usr.intBPcap
			usr << "[src]: Upgraded to [strength]!"

	First_Aid_Kit
		icon='FirstAid.dmi'
		SaveItem = 1
		stackable=1
		var/mloc
		var/uloc
		var/counter
		var/prevHP
		var/uses=10
		verb/First_Aid(mob/M in view(1))
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
					usr.SpreadHeal(4,0,0)
					counter--
				usr.bandaging=0
				if(uses)
					uses--
					usr<<"You have [uses] uses left."
					return
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
					M.SpreadHeal(4,1,0)
					counter--
				usr.bandaging=0
				if(uses)
					usr<<"You have [uses] uses left."
					uses--
					return
				del(src)

obj/Power_Drill
	density=1
	SaveItem=1
	cantblueprint=0
	icon = 'Drill Giant.dmi'
	name = "Drill"
	pixel_x=-22
	var/list/storedmats = list()
	New()
		set background = 1
		..()
		while(src)
			if(storedmats.len<30)
				var/attempt = 1
				var/obj/items/Material/m
				while(attempt)
					var/item = pick(typesof(/obj/items/Material) - typesof(/obj/items/Material/Alchemy/Misc))
					m = new item
					if(!Sub_Type(item))
						if(m.quality>50||m.tier>4)
						else
							attempt = Sub_Type(item)
					sleep(1)
				storedmats+=m
			sleep(300)

	Click()
		if(get_dist(usr,src)>1)
			return
		if(storedmats.len>0)
			clickstart
			var/obj/items/Material/m = input(usr,"What would you like to take from the drill?","") as null|anything in storedmats
			if(!m)
				return
			else
				usr.contents+=m
				storedmats-=m
				goto clickstart
		else
			usr<<"There are no materials to withdraw!"
			return


mob/Admin3/verb/Change_Resource_Gains()
	set category = "Admin"
	GlobalResourceGain = input(usr,"Gain mult","",GlobalResourceGain) as num