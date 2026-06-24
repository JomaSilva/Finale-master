//alright so boss mobs:
//they're essentially normal mobs, but way faster, way stronger, and they scale to the average BP.
//at some point they'll probably give more valuables but for now they drop great fucktons of zenni.
//they show up on the Sense tab as ???.


mob/npc/Enemy/Bosses
	isBoss=1
	murderToggle=1
	mindswappable = 0
	BP_Unleechable=1
	absorbable=0
	New()
		..()
		boss_list += src
	Del()
		boss_list -= src
		..()
	NPCTicker()
		..()
		BP = max(AverageBP * 2.8,BP)
		NPCAscension()
	Great_Dragon
		icon = 'Character - Odahviing.dmi'
		pixel_x = -32
		pixel_y = -16
		physoff = 8
		speed = 8
		technique = 8
		isBlaster = 1
	Zombie_God
		icon = 'Zombie Thanatos.dmi'
		zanzoAI = 1
		physoff = 10
		speed = 6
		technique = 6
	Nauscent_Immortal
		icon = 'Avatar.dmi'
		strafeAI = 1
		zanzoAI = 1
		kidef = 9
		physdef = 9
		technique = 6
	Lich
		icon = 'Skeleton.dmi'
		New()
			..()
			overlays += 'Clothes_CelesRobe.dmi'
		strafeAI = 1
		kidef = 8
		physoff = 7
		speed = 7
		technique = 9
		kioffMod = 10
		isBlaster = 1
	Angered_Demigod
		icon = 'New Pale Male Madara.dmi'
		New()
			..()
			overlays += 'BrolyWaistrobe.dmi'
		strafeAI = 1
		kidef = 9
		physdef = 9
		physoff = 7
	Shadow
		icon = 'CoreDemon.dmi'
		kidef = 8
		physdef = 14
		physoff = 14
		strafeAI = 1
		zanzoAI = 1
	Core_Demon
		icon = 'CoreDemon.dmi'
		kidef = 8
		physdef = 10
		physoff = 10
		strafeAI = 1
		zanzoAI = 1
		Del()
			for(var/mob/M in view(5))
				sleep(1)
				M.SpreadHeal(50)
			..()
	Golem
		icon = 'redrobot.dmi'
		physdef = 10
		pixel_x = -16
		pixel_y = -16
		physoff = 7
	Lost_Soldier
		icon = 'BaseWhiteMale.dmi'
		New()
			..()
			overlays += 'Armor, Azure.dmi'
			overlays += 'Mask.dmi'
		physoff = 10
		technique = 9
		strafeAI = 1
		isBlaster = 1
	Dire_Demon
		icon = 'Ice Robot.dmi'
		kidef = 8
		physoff = 8
		speed = 8
		technique = 9
		zanzoAI = 1
	Vampire_Lord
		icon= 'Vampire Lord.dmi'
		physdef = 10
		physoff = 10
		kidef = 10
		technique = 9
		strafeAI = 1
		zanzoAI = 1
		isBlaster = 1
		attackflavors = list("claws at", "rapidly punches", "shouts and tackles", "squeezes some blood out of", "attacks")
		dodgeflavors = list("vanishes out of thin air to avoid","springs high into the air and evades", "crosses his arms and smirks while dodging a blow from", "sidesteps away from")
		counterflavors = list("CROSS COUNTERS","blocks the attack, shouts 'USELESS!', and twists the arm of", "deflects the attack jabs", "catches the incoming punch and bites the arm of", "counters")
	Forest_King
		icon= 'dinomunky.dmi'
		physdef = 10
		physoff = 10
		kidef = 8
		technique = 10
		speed = 6
		strafeAI = 1
		zanzoAI = 1
		isBlaster = 1
		attackflavors = list("shoots vines at", "pincushions", "roars and tackles", "slams his vines towards", "attacks")
		dodgeflavors = list("vanishes out of thin air to avoid","springs high into the air and evades", "curls his vines and shoots away from the attack, avoiding", "sidesteps away from")
		counterflavors = list("CROSS COUNTERS","blocks the attack, and using his vines, slams into the agressor, stunning", "pincushions the attack of", "catches the incoming punch and crushes the arm of", "counters")