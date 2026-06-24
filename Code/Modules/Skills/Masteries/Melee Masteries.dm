/datum/mastery/Melee
	icon = 'Ability.dmi'//to be replaced by the general melee icon
	types = list("Mastery","Melee")//all ki skills will by default have the "Melee" type

	Basic_Training
		name = "Basic Training"
		desc = "Master your body. This is the path to improve some unique masteries. Trained by combat."
		lvltxt = "Per level: Tactics, Weaponry, Styling +0.2.\nEvery 5 Levels: Limb Health +1%"
		visible = 1
		nxtmod = 0.25
		var/added
		acquire(mob/M)//similar to the after_learn() proc for skills, these effects are applied as soon as the mastery is acquired
			..()
			savant.tactics+=0.2
			savant.weaponry+=0.2
			savant.styling+=0.2

		remove()
			if(!savant)
				return
			savant.healthmod-=0.01*round(level/5)
			savant.tactics-=0.2*level
			savant.weaponry-=0.2*level
			savant.styling-=0.2*level
			if(level >= 75)
				savant.willpowerMod-=0.1
				savant.staminagainMod-=0.1
			if(level >= 100)
				savant.willpowerMod-=0.2
				savant.staminagainMod-=0.2
				savant.technique-=0.2
			..()

		levelstat()
			..()
			savant<<"Your martial training improves! Basic Training is now level [level]!"
			savant.tactics+=0.2
			savant.weaponry+=0.2
			savant.styling+=0.2
			if(level % 5 == 0)
				savant.healthmod+=0.01
			if(level == 50 || (level >= 50 && !added))
				savant<<"Your martial training improves! You can now train by placing shadows on the ground and fighting them!"
				added = 1
				addverb(/mob/keyable/verb/Shadowboxing)
			if(level == 75)
				savant.willpowerMod+=0.1
				savant.staminagainMod+=0.1
			if(level == 100)
				savant.willpowerMod+=0.2
				savant.staminagainMod+=0.2
				savant.technique+=0.2

	Body_Mastery
		name = "Body Mastery"
		desc = "Master your body even further. Gained by getting enough Body skills. Trained by combat."
		lvltxt = "Every 2 levels: Physical Offense, Physical Defense, Speed +1"
		visible = 1
		tier=1
		nxtmod = 0.25
		req_sp = 40

		remove()
			if(!savant)
				return
			savant.physoffBuff-=0.1*round(level/5)
			savant.physdefBuff-=0.1*round(level/5)
			savant.speedBuff-=0.1*round(level/5)
			if(level >= 75)
				savant.willpowerMod-=0.1
				savant.staminagainMod-=0.1
			if(level >= 100)
				savant.willpowerMod-=0.2
				savant.staminagainMod-=0.2
				savant.techniqueBuff-=0.2
			..()

		levelstat()
			..()
			savant<<"Your martial training improves! Body Mastery is now level [level]!"
			savant.physoffBuff+=0.1*round(level/2)
			savant.physdefBuff+=0.1*round(level/2)
			savant.speedBuff+=0.1*round(level/2)
			if(level == 75)
				savant.willpowerMod+=0.1
				savant.staminagainMod+=0.1
			if(level == 100)
				savant.willpowerMod+=0.2
				savant.staminagainMod+=0.2
				savant.techniqueBuff+=0.2
	
	Tactical_Fighting
		name = "Tactical Fighting"
		desc = "You've learned the importance of strategy in combat, focusing on positioning and coordinating your strikes."
		lvltxt = "Per level: Tactics +0.3, Weaponry, Styling +0.1"
		reqtxt = "You must reach Level 50 Basic Training to learn to fight tactically."
		visible = 1
		tier = 1
		nxtmod = 0.5

		acquire(mob/M)
			..()
			savant<<"You begin to fight tactically!"
			savant.tactics+=0.3
			savant.weaponry+=0.1
			savant.styling+=0.1

		remove()
			if(!savant)
				return
			savant.tactics-=0.3*level
			savant.weaponry-=0.1*level
			savant.styling-=0.1*level
			if(level >= 30)
				removeverb(/mob/keyable/verb/Riposte_Toggle)
				savant.riposteon=0
			if(level >= 75)
				savant.willpowerMod-=0.1
			//if(level == 100)
				//savant.multilevel-=1
			//savant.combomax=max(savant.combomax,0)
			..()

		levelstat()
			..()
			savant<<"Your understanding of tactical combat deepens. Tactical Fighting is now level [level]!"
			savant.tactics+=0.3
			savant.weaponry+=0.1
			savant.styling+=0.1
			if(level == 30)
				savant<<"You've learned to take advantage of openings in your opponent's attacks. You may now riposte after dodging, using the opening to launch your own attack."
				addverb(/mob/keyable/verb/Riposte_Toggle)
				savant.riposteon=1
			if(level == 50)
				enable(/datum/mastery/Melee/Unarmed_Fighting)
				enable(/datum/mastery/Melee/Dual_Wielding)
				enable(/datum/mastery/Melee/Two_Handed_Mastery)
				enable(/datum/mastery/Melee/One_Handed_Fighting)
			if(level == 75)
				savant.willpowerMod+=0.1
				savant<<"You can now do a tactical kickflip, knocking your opponent back and launching you back as well."
				addverb(/mob/keyable/combo/verb/Kickflip)
			//if(level == 100)
				//savant<<"Your mastery of Tactical Fighting allows your to attack twice in the span of an instant! You may now strike multiple times at once!"
				//savant.multilevel+=1

	Armed_Combat
		name = "Armed Combat"
		desc = "You understand the value in honing your skills with you weapon of choice. You begin to specialize in fighting with weapons."
		lvltxt = "Per level: Weaponry +0.3, Styling, Tactics +0.1"
		reqtxt = "You must reach Level 50 Basic Training to become proficient in armed combat."
		visible = 1
		tier = 1
		nxtmod = 0.5

		acquire(mob/M)
			..()
			savant<<"Your practice with weaponry improves!"
			savant.tactics+=0.1
			savant.weaponry+=0.3
			savant.styling+=0.1

		remove()
			if(!savant)
				return
			savant.tactics-=0.1*level
			savant.weaponry-=0.3*level
			savant.styling-=0.1*level
			..()

		levelstat()
			..()
			savant<<"Your skill with weapons improves. Armed Combat is now level [level]!"
			savant.tactics+=0.1
			savant.weaponry+=0.3
			savant.styling+=0.1
			if(level == 25)
				enable(/datum/mastery/Melee/Sword_Mastery)
				enable(/datum/mastery/Melee/Axe_Mastery)
				enable(/datum/mastery/Melee/Staff_Mastery)
				enable(/datum/mastery/Melee/Spear_Mastery)
				enable(/datum/mastery/Melee/Club_Mastery)
				enable(/datum/mastery/Melee/Hammer_Mastery)

	Dual_Wielding
		name = "Dual Wielding"
		desc = "Fighting with two weapons is a complex, yet powerful fighting style. You have begun to master fighting with two weapons, and your penalty when using two weapons lessens."
		lvltxt = "Per level: Dual Wield Skill +0.4"
		reqtxt = "You must reach Level 50 Tactical Fighting to practice dual wielding."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with dual wielding improves!"
			savant.dualwieldskill+=0.4

		remove()
			if(!savant)
				return
			savant.dualwieldskill-=0.4*level
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with two weapons! Dual Wielding is now level [level]!"
			savant.dualwieldskill+=0.4

	Two_Handed_Mastery
		name = "Two Handed Mastery"
		desc = "Fighting with massive two handed weapons is a difficult task. You have begun to master fighting with two handed weapons, increasing your damage bonus."
		lvltxt = "Per level: Two Handed Skill +0.4"
		reqtxt = "You must reach Level 50 Tactical Fighting to practice two handed fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with two handed fighting improves!"
			savant.twohandskill+=0.4

		remove()
			if(!savant)
				return
			savant.twohandskill-=0.4*level
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with two handed weapons! Two Handed Mastery is now level [level]!"
			savant.twohandskill+=0.4

	One_Handed_Fighting
		name = "One Handed Fighting"
		desc = "Fighting with a single one handed weapon allows for skillful usage of your off hand. You have begun to master fighting with a single weapon, increasing your damage bonus."
		lvltxt = "Per level: One Handed Skill +0.4"
		reqtxt = "You must reach Level 50 Tactical Fighting to practice one handed fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with one handed fighting improves!"
			savant.onehandskill+=0.4

		remove()
			if(!savant)
				return
			savant.onehandskill-=0.4*level
			if(level >= 75)
				savant.ohmulti-=1
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with one handed weapons! One Handed Fighting is now level [level]!"
			savant.onehandskill+=0.4
			if(level == 75)
				savant<<"You can now use your free hand to launch an extra unarmed blow alongside your regular attacks!"
				savant.ohmulti+=1

	Unarmed_Fighting
		name = "Unarmed Fighting"
		desc = "Fighting unarmed is the purest form of martial expression. You have begun to master fighting unarmed, improving your damage and innate penetration, and allowing you to attack swiftly."
		lvltxt = "Per level: Unarmed Skill +0.4"
		reqtxt = "You must reach Level 50 Tactical Fighting to specialize in unarmed fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with unarmed fighting improves!"
			savant.unarmedskill+=0.4

		remove()
			if(!savant)
				return
			savant.unarmedskill-=0.4*level
			if(level >= 30)
				savant.unarmedpen-=1
			if(level >= 50)
				savant.umulti-=1
			if(level >= 75)
				savant.unarmedpen-=1
			if(level == 100)
				savant.umulti-=1
			..()

		levelstat()
			..()
			savant<<"You better understand fighting unarmed! Unarmed Fighting is now level [level]!"
			savant.unarmedskill+=0.4
			if(level == 30)
				savant<<"Your mighty fists harden through training. Your blows now penetrate armor slightly."
				savant.unarmedpen+=1
			if(level == 50)
				savant<<"The speed of your fists has become immense! You may now strike an additional time when striking multiple times and unarmed!"
				savant.umulti+=1
			if(level == 75)
				savant<<"Your fists are like iron. Your unarmed penetration has increased!"
				savant.unarmedpen+=1
			if(level == 100)
				savant<<"Your punches have become a blur! You strike an additional time when striking multiple times and unarmed!"
				savant.umulti+=1

	Sword_Mastery
		name = "Sword Mastery"
		desc = "You begin to focus on fighting with swords. Swords lend themselves to quick attacks and easy repositioning."
		lvltxt = "Per level: Sword Skill +0.4\nLevel 20: Blade Rush\nLevel 40: Wind Slice\nLevel 60: Whirling Blades\nLevel 90: Bladestorm"
		reqtxt = "You must reach Level 25 Armed Combat to practice sword fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with swords improves!"
			savant.swordskill+=0.4

		remove()
			if(!savant)
				return
			savant.swordskill-=0.4*level
			removeverb(/mob/keyable/combo/sword/verb/Blade_Rush)
			removeverb(/mob/keyable/combo/sword/verb/Wind_Slice)
			removeverb(/mob/keyable/combo/sword/verb/Whirling_Blades)
			removeverb(/mob/keyable/combo/sword/verb/Bladestorm)
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with swords! Sword Mastery is now level [level]!"
			savant.swordskill+=0.4
			if(level == 20)
				savant<<"You can now dash through your opponent, blade first. You learned Blade Rush!"
				addverb(/mob/keyable/combo/sword/verb/Blade_Rush)
			if(level == 40)
				savant<<"You can now slash fast enough to create a blast of wind! You learned Wind Slice!"
				addverb(/mob/keyable/combo/sword/verb/Wind_Slice)
			if(level == 60)
				savant<<"You can now strike all opponents around you in the blink of an eye! You learned Whirling Blades!"
				addverb(/mob/keyable/combo/sword/verb/Whirling_Blades)
			if(level == 90)
				savant<<"You can now knock a single foe into a brutal knockback combo. You learned Bladestorm!"
				addverb(/mob/keyable/combo/sword/verb/Bladestorm)

	Axe_Mastery
		name = "Axe Mastery"
		desc = "You begin to focus on fighting with axes. Axes lend themselves to heavy attacks and crippling bleeding."
		lvltxt = "Per level: Axe Skill +0.4\nLevel 20: Logsplitter\nLevel 40: Reaver\nLevel 60: Headsman\nLevel 90: Brutal Cleaver"
		reqtxt = "You must reach Level 25 Armed Combat to practice axe fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with axes improves!"
			savant.axeskill+=0.4

		remove()
			if(!savant)
				return
			savant.axeskill-=0.4*level
			removeverb(/mob/keyable/combo/axe/verb/Logsplitter)
			removeverb(/mob/keyable/combo/axe/verb/Reaver)
			removeverb(/mob/keyable/combo/axe/verb/Headsman)
			removeverb(/mob/keyable/combo/axe/verb/Brutal_Cleaver)
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with axes! Axe Mastery is now level [level]!"
			savant.axeskill+=0.4
			if(level == 20)
				savant<<"You can now slice your opponents with a heavy downward chop, causing them to bleed. You learned Logsplitter!"
				addverb(/mob/keyable/combo/axe/verb/Logsplitter)
			if(level == 40)
				savant<<"You can now cleave opponents in an arc in front of you, doing more damage the heavier their bleeding! You learned Reaver!"
				addverb(/mob/keyable/combo/axe/verb/Reaver)
			if(level == 60)
				savant<<"You can now chop an opponent three times in rapid succession, stunning them then sending them flying! You learned Headsman!"
				addverb(/mob/keyable/combo/axe/verb/Headsman)
			if(level == 90)
				savant<<"You can now hurl an axe at your opponent, then instantly appear next to them to unleash a heavy blow. You learned Brutal Cleaver!"
				addverb(/mob/keyable/combo/axe/verb/Brutal_Cleaver)

	Staff_Mastery
		name = "Staff Mastery"
		desc = "You begin to focus on fighting with staffs. Staffs lend themselves to countering attacks and redirecting opponents."
		lvltxt = "Per level: Staff Skill +0.4\nLevel 20: Spinning Strike\nLevel 40: Pole Vault\nLevel 60: Flexible Defense\nLevel 90: Around The World"
		reqtxt = "You must reach Level 25 Armed Combat to practice staff fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with staffs improves!"
			savant.staffskill+=0.4

		remove()
			if(!savant)
				return
			savant.staffskill-=0.4*level
			removeverb(/mob/keyable/combo/staff/verb/Spinning_Strike)
			removeverb(/mob/keyable/combo/staff/verb/Pole_Vault)
			removeverb(/mob/keyable/combo/staff/verb/Flexible_Defense)
			removeverb(/mob/keyable/combo/staff/verb/Around_The_World)
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with staffs! Staff Mastery is now level [level]!"
			savant.staffskill+=0.4
			if(level == 20)
				savant<<"You can now confuse your opponents with a spinning staff attack, making them dizzy. You learned Spinning Strike!"
				addverb(/mob/keyable/combo/staff/verb/Spinning_Strike)
			if(level == 40)
				savant<<"You can now leap to a nearby opponent with your staff, doing more damage and stunning if they are dizzy or not facing you! You learned Pole Vault!"
				addverb(/mob/keyable/combo/staff/verb/Pole_Vault)
			if(level == 60)
				savant<<"You can now adopt a defensive posture, automatically countering up to 5 attacks for 5 seconds! You learned Flexible Defense!"
				addverb(/mob/keyable/combo/staff/verb/Flexible_Defense)
			if(level == 90)
				savant<<"You can now swing your staff in a circle, dealing heavy damage and shunting back foes who are dizzy or facing away. You learned Around The World!"
				addverb(/mob/keyable/combo/staff/verb/Around_The_World)

	Spear_Mastery
		name = "Spear Mastery"
		desc = "You begin to focus on fighting with spears. Spears lend themselves to attacking at great distance."
		lvltxt = "Per level: Spear Skill +0.4\nLevel 20: Lunge\nLevel 40: Javelin Toss\nLevel 60: Compass Rose\nLevel 90: High Jump"
		reqtxt = "You must reach Level 25 Armed Combat to practice spear fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with spears improves!"
			savant.spearskill+=0.4

		remove()
			if(!savant)
				return
			savant.spearskill-=0.4*level
			removeverb(/mob/keyable/combo/spear/verb/Lunge)
			removeverb(/mob/keyable/combo/spear/verb/Javelin_Toss)
			removeverb(/mob/keyable/combo/spear/verb/Compass_Rose)
			removeverb(/mob/keyable/combo/spear/verb/High_Jump)
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with spears! Spear Mastery is now level [level]!"
			savant.spearskill+=0.4
			if(level == 20)
				savant<<"You can now lunge at your opponents, slowing their movements. You learned Lunge!"
				addverb(/mob/keyable/combo/spear/verb/Lunge)
			if(level == 40)
				savant<<"You can now throw spears at your opponent that home in if they're slowed! You learned Javelin Toss!"
				addverb(/mob/keyable/combo/spear/verb/Javelin_Toss)
			if(level == 60)
				savant<<"You can thrust spears in all four cardinal directions! You learned Compass Rose!"
				addverb(/mob/keyable/combo/spear/verb/Compass_Rose)
			if(level == 90)
				savant<<"You can swiftly leap at your opponent, impaling and slowing them. You learned High Jump!"
				addverb(/mob/keyable/combo/spear/verb/High_Jump)

	Club_Mastery
		name = "Club Mastery"
		desc = "You begin to focus on fighting with clubs. Clubs lend themselves to knocking foes around."
		lvltxt = "Per level: Club Skill +0.4\nLevel 20: Staggering Impact\nLevel 40: Grand Slam\nLevel 60: Leaping Smash\nLevel 90: Earthquake"
		reqtxt = "You must reach Level 25 Armed Combat to practice club fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with clubs improves!"
			savant.clubskill+=0.4

		remove()
			if(!savant)
				return
			savant.clubskill-=0.4*level
			removeverb(/mob/keyable/combo/club/verb/Staggering_Impact)
			removeverb(/mob/keyable/combo/club/verb/Grand_Slam)
			removeverb(/mob/keyable/combo/club/verb/Leaping_Smash)
			removeverb(/mob/keyable/combo/club/verb/Earthquake)
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with clubs! Club Mastery is now level [level]!"
			savant.clubskill+=0.4
			if(level == 20)
				savant<<"You can now slam your club into your opponent, staggering them. You learned Staggering Impact!"
				addverb(/mob/keyable/combo/club/verb/Staggering_Impact)
			if(level == 40)
				savant<<"You can now smash the foes in front of you, dealing extra damage and knocking back staggered foes! You learned Grand Slam!"
				addverb(/mob/keyable/combo/club/verb/Grand_Slam)
			if(level == 60)
				savant<<"You can leap at your foes, doing extra damage if they are staggered or knocked back! You learned Leaping Smash!"
				addverb(/mob/keyable/combo/club/verb/Leaping_Smash)
			if(level == 90)
				savant<<"You can slam the ground in front of you, creating a massive crater and shunting foes back. You learned Earthquake!"
				addverb(/mob/keyable/combo/club/verb/Earthquake)

	Hammer_Mastery
		name = "Hammer Mastery"
		desc = "You begin to focus on fighting with hammers. Hammers lend themselves to crushing and stunning foes."
		lvltxt = "Per level: Hammer Skill +0.4\nLevel 20: Driving The Nail\nLevel 40: Toll The Bell\nLevel 60: Crushing Blow\nLevel 90: Shatter Armor"
		reqtxt = "You must reach Level 25 Armed Combat to practice hammer fighting."
		visible = 1
		tier = 2

		acquire(mob/M)
			..()
			savant<<"Your proficiency with hammers improves!"
			savant.hammerskill+=0.4

		remove()
			if(!savant)
				return
			savant.hammerskill-=0.4*level
			removeverb(/mob/keyable/combo/hammer/verb/Driving_The_Nail)
			removeverb(/mob/keyable/combo/hammer/verb/Toll_The_Bell)
			removeverb(/mob/keyable/combo/hammer/verb/Crushing_Blow)
			removeverb(/mob/keyable/combo/hammer/verb/Shatter_Armor)
			..()

		levelstat()
			..()
			savant<<"You better understand fighting with hammers! Hammer Mastery is now level [level]!"
			savant.hammerskill+=0.4
			if(level == 20)
				savant<<"You can now strike your opponent with great force, stunning them. You learned Driving The Nail!"
				addverb(/mob/keyable/combo/hammer/verb/Driving_The_Nail)
			if(level == 40)
				savant<<"You can now jump to your target with a mighty swing, making them vulnerable to physical damage if they are stunned or staggered. You learned Toll The Bell!"
				addverb(/mob/keyable/combo/hammer/verb/Toll_The_Bell)
			if(level == 60)
				savant<<"You can viciously hammer your foe, knocking them back and dealing damage to all foes in a line if your target is vulnerable! You learned Crushing Blow!"
				addverb(/mob/keyable/combo/hammer/verb/Crushing_Blow)
			if(level == 90)
				savant<<"You can now devastate your opponent with an immense swing, ignoring a significant amount of armor. You learned Shatter Armor!"
				addverb(/mob/keyable/combo/hammer/verb/Shatter_Armor)