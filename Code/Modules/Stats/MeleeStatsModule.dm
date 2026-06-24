//Stats block for melee masteries
mob/var
	tactics = 0//skill with Tactics-based abilities, alongside the combo system
	weaponry = 0//general skill with weapons
	styling = 0//how much have you mastered combat styles?
	//skill with the four style archetypes
	assaultskill = 0
	guardedskill = 0
	tacticalskill = 0
	swiftskill = 0
	//skill with the various weapons
	unarmedskill = 0
	swordskill = 0
	axeskill = 0
	staffskill = 0
	spearskill = 0
	clubskill = 0
	hammerskill = 0
	//combat style skill, 1 hand, 2 hand, dool wield
	onehandskill = 0
	twohandskill = 0
	dualwieldskill = 0

mob
	Attack_Gain(mult)
		..()
		Attack_MasteryGain(mult)
	
	proc/Attack_MasteryGain(mult)
		if(!mult)
			mult=1
		AddExp(src,/datum/mastery/Melee/Basic_Training,30*mult)
		AddExp(src,/datum/mastery/Melee/Body_Mastery,15*mult)
		AddExp(src,/datum/mastery/Melee/Tactical_Fighting,15*mult)
		if(weaponeq>0)
			AddExp(src,/datum/mastery/Melee/Armed_Combat,30*mult)
			if("Sword" in WeaponEQ)
				AddExp(src,/datum/mastery/Melee/Sword_Mastery,15*mult/weaponeq)
			if("Axe" in WeaponEQ)
				AddExp(src,/datum/mastery/Melee/Axe_Mastery,15*mult/weaponeq)
			if("Staff" in WeaponEQ)
				AddExp(src,/datum/mastery/Melee/Staff_Mastery,15*mult/weaponeq)
			if("Spear" in WeaponEQ)
				AddExp(src,/datum/mastery/Melee/Spear_Mastery,15*mult/weaponeq)
			if("Club" in WeaponEQ)
				AddExp(src,/datum/mastery/Melee/Club_Mastery,15*mult/weaponeq)
			if("Hammer" in WeaponEQ)
				AddExp(src,/datum/mastery/Melee/Hammer_Mastery,15*mult/weaponeq)
			if(weaponeq==2)
				AddExp(src,/datum/mastery/Melee/Dual_Wielding,10*mult)
			else if(weaponeq==1)
				if(twohanding)
					AddExp(src,/datum/mastery/Melee/Two_Handed_Mastery,15*mult)
				else
					AddExp(src,/datum/mastery/Melee/One_Handed_Fighting,15*mult)
		else
			AddExp(src,/datum/mastery/Melee/Unarmed_Fighting,15*mult)