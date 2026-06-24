//This is the actual mastery tree for Godki. Only appears after Tier 1 Godki has been earned.
//While Godki.dm shares many similarities with the Mastery system, certain features are impossible or hard to reproduce effectively.
//Also, mob vars reeee...
/datum/mastery
	Godki
		name = "God Ki"
		desc = "Master your Godhood. Comes with neat bonuses at the end."
		lvltxt = "Per level: God Ki Efficiency Buff +1%.\nEvery 10 Levels: God Ki Efficiency Mod +50%\nLevel 20: Skill: God Ki Flare\nLevel 30: Skill: Conserve God Ki\nLevel 45: Gain a specialization."
		reqtxt = "You must gain God Ki to train this mastery."
		visible = 0 //Hidden masteries aren't visible dummy
		hidden = 1 //So that its invisible from mastery lists
		types = list("Mastery","Godki")
		nxtmod = 3
		var/wasimmortal

		acquire(mob/M)//similar to the after_learn() proc for skills, these effects are applied as soon as the mastery is acquired
			..()
			savant.CheckGodki()

		levelstat()
			..()
			savant<<"Your martial training improves! Basic Training is now level [level]!"
			savant.godki.t_efficiency+=0.01
			if(level % 10 == 0)
				savant.godki.m_efficiency+=0.5
			if(level == 20)
				savant<<"You can use the skill God Ki Flare! This allows you to increase your God Ki multiplier at the cost of higher drain."
			if(level == 30)
				savant<<"You can use the skill Conserve God Ki! This allows you to make your God Ki multiplier act as if you were always at 100% energy. However, the actual God Ki drain is increased."
			if(level == 45)
				savant<<"You now can now master specializations of God Ki. Remember, you have 37 * God Ki Tier levels to distribute between the two. Choose which one to focus on wisely."
				savant<<"The first God Ki Specialization is one of fortitude. Maximize efficiency and reduce drain to prolong your ability to use God Ki. At level 50, as long as you're at 100% Ki, you'll gain God Ki energy while using it."
				savant<<"The second God Ki Specialization is one of power. Maximize your multiplier and maximum energy to ensure victory. At level 50, you can start using temporarily using the God of Destruction mode."
				savant<<"The third God Ki Specialization is one of body. Increasing God Ki will improve your body itself, increasing all stats even further than what they are. At level 50, gain four extra skillpoints."
				savant<<"As a reminder, fighting other players will increase your God Ki tier."
				make_visible(/datum/mastery/fortitude)
				make_visible(/datum/mastery/power)
				make_visible(/datum/mastery/body)
			if(level == 100)
				if(savant.biologicallyimmortal) wasimmortal = 1
				savant.biologicallyimmortal = 1
				savant.godki.naturalization = TRUE
				savant<<"You've mastered all there is to God Ki!"

	fortitude
		name = "God Fortitude"
		desc = "Maximize efficiency and reduce drain to prolong your ability to use God Ki. At level 50, as long as you're at 100% Ki, you'll gain God Ki energy while using it."
		lvltxt = "Per level: Efficiency Buff +1%, Maximum Energy +1%. \nLevel 50: Active God Ki Energy Regeneration"
		reqtxt = "You must reach Level 45 God Ki to become proficient in God Fortitude."
		visible = 0 //Hidden masteries aren't visible dummy
		hidden = 1 //So that its invisible from mastery lists
		types = list("Mastery","Godki")
		tier = 1
		nocost=1
		nxtmod = 0.5

		levelstat()
			..()
			savant<<"Your fortitude with God Ki increases!! Level [level] reached."
			savant.godki.energy_mod+=0.01
			savant.godki.t_efficiency+=0.01
			savant.godki.points--
			if(level == 50)
				savant<<"Your God Ki can regenerate even in usage!"
				savant.godki.godki_regen_go = 1
		expgain(num,ovr)
			if(savant.godki.points >= 1)
				..(num,ovr)
			else return

	power
		name = "God Power"
		desc = "Maximize your multiplier and maximum energy to ensure victory. At level 50, you can start using temporarily using the God of Destruction mode."
		lvltxt = "Per level: Multiplier Mod +1%, Maximum Energy +5. \nLevel 50: Hakaishin"
		reqtxt = "You must reach Level 45 God Ki to become proficient in God Power."
		visible = 0 //Hidden masteries aren't visible dummy
		hidden = 1 //So that its invisible from mastery lists
		types = list("Mastery","Godki")
		tier = 1
		nocost=1
		nxtmod = 0.5

		levelstat()
			..()
			savant<<"Your Power increases under the influence of God Ki!! Level [level] reached."
			savant.godki.godki_mult+=0.01
			savant.godki.energy_buff+=5
			savant.godki.points--
			if(level == 50)
				savant<<"You can activate Hakaishin!! This is a temporary version of the God of Destruction exclusive transformation."
				savant.godki.canhakaishin = 1
		expgain(num,ovr)
			if(savant.godki.points >= 1)
				..(num,ovr)
			else return
	body
		name = "God Body"
		desc = "Increasing God Ki will improve your body itself, increasing all stats even further than what they are. At level 50, gain four extra skillpoints."
		lvltxt = "Every 10 levels: All stats +1%, Maximum Energy +1%, Efficiency Buff +1%, Multiplier Mod +1%. \nLevel 50: Gain 4 skillpoints."
		reqtxt = "You must reach Level 45 God Ki to become proficient in God Body."
		visible = 0 //Hidden masteries aren't visible dummy
		hidden = 1 //So that its invisible from mastery lists
		types = list("Mastery","Godki")
		tier = 1
		nocost=1
		nxtmod = 0.5

		expgain(num,ovr)
			if(savant.godki.points >= 1)
				..(num,ovr)
			else return

		levelstat()
			..()
			savant<<"Your Body is empowered with God Ki!! Level [level] reached."
			if(level % 10 == 0)
				savant.godki.energy_mod+=0.01
				savant.godki.godki_mult+=0.01
				savant.godki.t_efficiency+=0.01
			savant.godki.points--
			if(level == 50)
				savant<<"Your God Ki can regenerate even in usage!"
				savant.godki.godki_regen_go = 1