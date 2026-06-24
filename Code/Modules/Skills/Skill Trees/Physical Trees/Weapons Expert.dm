mob/var/SwordEquipped
datum/skill/tree/WeaponsExpert
	name = "Weapons Expert"
	desc = "Develop and enhance your skills with melee weapons."
	maxtier = 3
	tier=1
	enabled=0
	allowedtier = 2 //make sure to change this if you change weapon tiers.
	constituentskills = list(new/datum/skill/Tree_Mastery,new/datum/skill/Swordmaster,new/datum/skill/Swordsinger,new/datum/skill/Bodybuilding/Sword_Routine,new/datum/skill/Bodybuilding/Weighted_Sword_Style)
	mod()
		..()
		savant.mastery_enable(/datum/mastery/Melee/Armed_Combat)
	demod()
		savant.mastery_remove(/datum/mastery/Melee/Armed_Combat)
		..()

datum/skill/Swordmaster
	skilltype = "Melee Buff"
	name = "Sword Master"
	desc = "Harness your skills with the blade. P.Off+++, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	expbarrier = 10000

mob/var/GotWeaponBuff = 0

datum/skill/Swordmaster/after_learn() //after_learn() only happens once, you're looking for effector() and a datum var that checks and tracks if you equipped something.
	savant<<"Your sword swings feel lighter and more precise."
	if(savant.weaponeq>=1&&savant.GotWeaponBuff==0)
		savant.GotWeaponBuff = 1
		savant.physoffBuff+=0.3
		savant.techniqueBuff+=0.1
datum/skill/Swordmaster/before_forget()
	savant<<"You let go of the way of the blade."
	switch(level)
		if(0) if(savant.GotWeaponBuff==1)
			savant.GotWeaponBuff = 0
			savant.physoffBuff-=0.3
			savant.techniqueBuff-=0.1
		if(1) if(savant.GotWeaponBuff==1)
			savant.GotWeaponBuff = 0
			savant.physoffBuff-=0.5
			savant.techniqueBuff-=0.2
datum/skill/Swordmaster/effector()
	..()
	if(savant.GotWeaponBuff==1)
		exp+=1
	switch(level)
		if(0)
			if(savant.weaponeq>=1&&savant.GotWeaponBuff==0)
				savant<<"Your sword makes you feel stronger."
				savant.GotWeaponBuff = 1
				savant.physoffBuff+=0.3
				savant.techniqueBuff+=0.1
			if(savant.weaponeq==0&&savant.GotWeaponBuff==1)
				savant<<"Your lack of weapon limits your body in some way?"
				savant.GotWeaponBuff = 0
				savant.physoffBuff-=0.3
				savant.techniqueBuff-=0.1
		if(1)
			if(levelup)
				levelup = 0
				savant<<"Your sword skill has evolved."
				if(savant.weaponeq>=1&&savant.GotWeaponBuff==1)
					savant.GotWeaponBuff = 0
					savant.physoffBuff-=0.3
					savant.techniqueBuff-=0.1
			if(savant.weaponeq>=1&&savant.GotWeaponBuff==0)
				savant<<"Your sword makes you feel stronger."
				savant.GotWeaponBuff = 1
				savant.physoffBuff+=0.5
				savant.techniqueBuff+=0.2
			if(savant.weaponeq==0&&savant.GotWeaponBuff==1)
				savant<<"Your weapon is missing from your grip, your body is not in it's natural state."
				savant.GotWeaponBuff = 0
				savant.physoffBuff-=0.5
				savant.techniqueBuff-=0.2
//make sure to call logger(var/mob/logger) if you're gonna add any verbs, like below.
mob/var/TreeEquipped
mob/var/GotTreeBuff
datum/skill/Tree_Mastery
	name = "Tree Mastery"
	desc = "Begin learning the Way of the Tree. Essentially, gain the ability to pluck trees out of the ground, and channel Ki though them, allowing you to fight and do interesting things with them."
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 3
	tier = 2
	expbarrier = 10000

verb/Pluck_Tree(var/obj/Trees/A in view(1))
	set category = "Skills"
	if(istype(A,/obj/Trees))
		if(A.IsEquipped)
		else
			A.density=0
			A.IsEquipped = 1
			A.Savable = 1
			A.Move(usr.contents)
verb/Throw_Tree(var/obj/Trees/A in usr.contents)
	set category = "Skills"
	var/choice
	if(A.IsEquipped == 1)
		choice = alert(usr,"Ride it?","","Yes","No")
	if(choice == "Yes")
		A.Move(locate(usr.x,usr.y,usr.z))
		spawn while(A.ThrowMe(usr.dir,30)!=1)
			usr.Move(locate(A.x,A.y,A.z),A.dir)
			A.density=1
			sleep(1)
	else
		A.density=1
		A.Move(locate(usr.x,usr.y,usr.z))
		A.ThrowMe(usr.dir,30)

verb/Equip_Tree(var/obj/Trees/A in usr.contents)
	set category = "Skills"
	if(A.IsEquipped&&usr.TreeEquipped)
		usr.TreeEquipped = 0
		A.suffix=""
		A.IsEquipped = 0
	else
		A.IsEquipped = 1
		A.suffix="*Equipped*"
		usr.TreeEquipped = 1

datum/skill/Tree_Mastery/after_learn()
	savant<<"The way of the Tree has imprinted within you."
	assignverb(/verb/Pluck_Tree)
	..()
datum/skill/Tree_Mastery/before_forget()
	savant<<"The forgotten Tree information has left a dull mark in your mind, your body now only viewing trees as nothing more but another resource."
	switch(level)
		if(0)
			unassignverb(/verb/Pluck_Tree)
		if(1)
			unassignverb(/verb/Equip_Tree)
			if(savant.GotTreeBuff==1)
				savant.GotTreeBuff = 0
				savant.physoffBuff-=0.4
				savant.techniqueBuff-=0.1
		if(2)
			unassignverb(/verb/Throw_Tree)
			if(savant.GotTreeBuff==1)
				savant.GotTreeBuff = 0
				savant.physoffBuff-=0.7
				savant.techniqueBuff-=0.1
	for(var/obj/Trees/A in savant.contents)
		if(A.IsEquipped&&savant.TreeEquipped)
			savant.TreeEquipped = 0
			A.IsEquipped = 0
			A.density=1
		A.Move(locate(savant.x,savant.y,savant.z))
datum/skill/Tree_Mastery/login(var/mob/logger)
	..()
	switch(level)
		if(0)
			assignverb(/verb/Pluck_Tree)
		if(1)
			assignverb(/verb/Pluck_Tree)
			assignverb(/verb/Equip_Tree)
		if(2)
			assignverb(/verb/Pluck_Tree)
			assignverb(/verb/Equip_Tree)
			assignverb(/verb/Throw_Tree)
datum/skill/Tree_Mastery/effector()
	..()
	if(/obj/Trees in savant.contents)
		exp+=1
	switch(level)
		if(1)
			if(levelup)
				levelup = 0
				assignverb(/verb/Equip_Tree)
				savant<<"You feel more powerful wielding a mighty tree!"
			if(savant.TreeEquipped==1&&savant.GotTreeBuff==0)
				savant<<"Your tree makes you feel stronger."
				savant.GotTreeBuff = 1
				savant.physoffBuff+=0.4
				savant.techniqueBuff+=0.1
			if(savant.TreeEquipped==0&&savant.GotTreeBuff==1)
				savant<<"Your tree is missing from your grip, your body is not in it's natural state."
				savant.GotTreeBuff = 0
				savant.physoffBuff-=0.4
				savant.techniqueBuff-=0.1
		if(2)
			if(levelup)
				levelup = 1
				assignverb(/verb/Throw_Tree)
				savant<<"Anything can be a projectile... Anything."
				if(savant.TreeEquipped==1&&savant.GotTreeBuff==1)
					savant.GotTreeBuff = 0
					savant.physoffBuff-=0.1
					savant.techniqueBuff-=0.1
				if(savant.TreeEquipped==1&&savant.GotTreeBuff==0)
					savant<<"Your tree makes you feel so much stronger."
					savant.GotTreeBuff = 1
					savant.physoffBuff+=0.7
					savant.techniqueBuff+=0.1
				if(savant.TreeEquipped==0&&savant.GotTreeBuff==1)
					savant<<"Your tree is missing from your grip, you are uncomfortable."
					savant.GotTreeBuff = 0
					savant.physoffBuff-=0.7
					savant.techniqueBuff-=0.1

datum/skill/Swordsinger
	skilltype = "Melee Buff"
	name = "Sword Speak"
	desc = "When holding a sword, your technique increases the longer you hold a blade. It resets upon unequipping your sword, and builds up to a maximum of three charges. Tech+"
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 2
	expbarrier = 10000
	var/tmp/booster
	var/tmp/boost
	var/tmp/boosting
	var/tmp/delay
	after_learn()
		savant<<"You seem a bit stronger."
		savant.staminagainMod += 0.1
		savant.techniqueBuff += 0.1
	before_forget()
		savant.staminagainMod -= 0.1
		savant.techniqueBuff -= 0.1
		savant << "Your strength is lost..."
		if(boost) savant.Ttechnique -= boost
	effector()
		..()
		if(!delay || world.time <= delay) return
		else delay = world.time + 2
		if(savant.weaponeq && prob(10))
			if(boosting) return
			boosting=1
			booster++
			booster = min(booster,30)
			var/nboost = 1 + (booster/100)
			if(nboost != boost)
				if(boost) savant.Ttechnique -= boost
				savant.Ttechnique += nboost
				boost = nboost
			boosting = 0
		if(!savant.weaponeq)
			booster = 0

/datum/skill/Bodybuilding/Weighted_Sword_Style
	skilltype = "Physical"
	name = "Weighted Sword Style"
	desc = "If your knockback is on, you gain a small physical offense boost. If it's off, your gains increase but your physical offense is worse. +Stamina Gain."
	tier=2
	skillcost = 1
	prereqs = list(new/datum/skill/Swordmaster)
	var/tmp/boost
	var/tmp/boosted
	var/tmp/pstsetting
	after_learn()
		savant<<"You feel your sword weighing you down..."
		savant.staminagainMod += 0.1
	before_forget()
		savant<<"Your sword style no longer seems to do the trick anymore."
		savant.staminagainMod -= 0.1
		if(boost) savant.Ttechnique -= boost
		switch(level)
			if(2)
				savant.techniqueBuff -= 0.1
				savant.physoffBuff -= 0.4
				savant.speedBuff -= 0.2
			if(3)
				savant.techniqueBuff -= 0.2
				savant.physoffBuff -= 0.4
				savant.speedBuff -= 0.2
	effector()
		..()
		if(!savant.knockback && savant.SwordEquipped) exp += 1
		switch(level)
			if(1)
				if(levelup) levelup = 0
				boost = 1.1
			if(2)
				boost = 1.2
				if(levelup)
					levelup = 0
					savant << "Your muscles feel stronger."
					savant.techniqueBuff += 0.1
					savant.physoffBuff += 0.2
					savant.speedBuff += 0.1
			if(3)
				boost = 1.4
				if(levelup)
					levelup = 0
					savant << "Your muscles feel stronger."
					savant.techniqueBuff += 0.1
					savant.physoffBuff += 0.2
					savant.speedBuff += 0.1
		if(!savant.SwordEquipped)
			if(boosted) //just bring it back to normal
				if(!savant.knockback)
					savant.Tphysoff *= boost
					savant.tgains /= boost
				else if(savant.knockback)
					savant.Tphysoff /= boost
					savant.tgains *= boost
		else
			if(!boosted)
				boosted = boost
				if(!savant.knockback && savant.SwordEquipped)
					savant.Tphysoff /= boost
					savant.tgains *= boost
				else if(savant.knockback && savant.SwordEquipped)
					savant.Tphysoff *= boost
					savant.tgains /= boost
				pstsetting = savant.knockback
			else if(boosted && pstsetting != savant.knockback)
				//reset
				if(pstsetting && savant.SwordEquipped)
					savant.Tphysoff /= boosted
					savant.tgains *= boosted
				else if(pstsetting && savant.SwordEquipped)
					savant.Tphysoff *= boosted
					savant.tgains /= boosted
				//reset
				if(!savant.knockback && savant.SwordEquipped)
					savant.Tphysoff /= boost
					savant.tgains *= boost
				else if(savant.knockback && savant.SwordEquipped)
					savant.Tphysoff *= boost
					savant.tgains /= boost
				boosted = boost
				pstsetting = savant.knockback

/datum/skill/Bodybuilding/Sword_Routine
	skilltype = "Physical"
	name = "Sword Routine (I)"
	desc = "Slowly grind your skills as a swordsman."
	tier=2
	skillcost = 1
	prereqs = list(new/datum/skill/Swordmaster)
	var/boost
	before_forget()
		savant<<"Your workout routine no longer seems to do the trick anymore."
		switch(level)
			if(2)
				savant.techniqueBuff -= 1
				savant.physoffBuff -= 1
				savant.speedBuff -= 0.5
			if(3)
				savant.techniqueBuff -= 2
				savant.physoffBuff -= 1.5
				savant.speedBuff -= 1
	effector()
		..()
		if(savant.train || savant.IsInFight)
			if(savant.weaponeq)exp += 1
		switch(level)
			if(1) if(levelup) levelup = 0
			if(2)
				if(levelup)
					levelup = 0
					savant << "Your muscles feel stronger."
					savant.techniqueBuff += 1
					savant.physoffBuff += 1
					savant.speedBuff += 0.5
			if(3)
				if(levelup)
					levelup = 0
					savant << "Your muscles feel stronger."
					savant.techniqueBuff += 1
					savant.physoffBuff += 0.5
					savant.speedBuff += 0.5