/*Hidden Masteries are, as the name implies, very rare, and they should only be given out to one player on the server.
Said player is then expected to teach the mastery to certain, worthy individuals. These
should unlock through applications and major IC development. While they should offer new abilities and skills, they may
also provide increases in various stats.*/

/datum/mastery/Hidden
	Vampirism
		name = "Vampirism"
		desc = "Your newly tainted blood bursts with power as moonlight shines above you...This is the path to rejecting one's own humanity."
		lvltxt = "Per level: Phys Off, Phys Def, Speed +0.2\n Level 1: Bite\n Level 4: Vampiric Regeneration\n Level 7: Nocturnal Senses\n Level 10: Shapeshift\n Level 20:Blood Drain\n Level 30: Vapor Freeze\n Level 40: Space Ripper Stingy Eyes\n Level 50: Zombification\n Level 60: Mist Form\n Level 75: Flesh Buds\n Level 100: Create Blood Chalice"
		reqtxt = "You must become a vampire either through the Stone Mask or a Blood Chalice to utilize vampiric power."
		visible = 0 //Hidden masteries aren't visible dummy
		hidden = 1 //So that its invisible from mastery lists
		tier = 1
		battle = 0
		nocost = 0
		acquire(mob/M)
			..()
			visible=1
			savant.physoffBuff+=0.2
			savant.physdefBuff+=0.2
			savant.speedBuff+=0.2
			savant<<"Your blood boils as darkness taints your soul!"
			sleep(20)
			savant<<"What a horrible night to have a curse."
		remove()
			if(!savant)
				return
			savant<<"You manage to fight off your blood-stained curse and clinge to what humanity you still have..."
			savant.physoffBuff-=0.2*level
			savant.physdefBuff-=0.2*level
			savant.speedBuff-=0.2*level
			removeverb(/mob/keyable/verb/Bite)
/*			removeverb(/mob/keyable/verb/Vampiric_Regeneration)
			removeverb(/mob/keyable/verb/Nocturnal_Senses)
			removeverb(/mob/keyable/verb/Shapeshift)
			removeverb(/mob/keyable/verb/Blood_Drain)
			removeverb(/mob/keyable/verb/Vapor_Freeze)
			removeverb(/mob/keyable/verb/Space_Ripper_Stingy_Eyes)
			removeverb(/mob/keyable/verb/Zombification)
			removeverb(/mob/keyable/verb/Mist_Form)
			removeverb(/mob/keyable/verb/Flesh_Buds)
			removeverb(/mob/keyable/verb/Create_Blood_Chalice)*/
			..()

		levelstat()
			..()
			savant<<"Your vampiric blood grows even stronger! Vampirism is now level [level]!"
			savant.physoffBuff+=0.2
			savant.physdefBuff+=0.2
			savant.speedBuff+=0.2
			if(level == 1)
				savant<<"Sharp, pointed fangs burst from your gums, perfect for digging into a person's flesh. You can now use Bite!"
				addverb(/mob/keyable/verb/Bite)
/*			if(level == 4)
				savant<<"Using the blood you've acquired, you can now heal yourself from the brink of death! You've learned Vampiric Regeneration!"
				addverb(/mob/keyable/verb/Vampiric_Regeneration)
			if(level == 7)
				savant<<"Your supernatural blood has bolstered your senses, allowing you to sniff out and detect nearby organisms. You learned Nocturnal Senses!"
				addverb(/mob/keyable/verb/Nocturnal_Senses)
			if(level == 10)
				savant<<"By utuilizing dark magic inherited by your cursed blood, you can now Shapeshift into a creature of the night!"
				addverb(/mob/keyable/verb/Shapeshift)
			if(level == 20)
				savant<<"Ripple flows throughout the liquid around you, condensing it into a versatile weapon! You've learned Ripple Cutter!"
				addverb(/mob/keyable/verb/Blood_Drain)
			if(level == 30)
				savant<<"The Ripple is pulsating within your body, granting you the ability to launch an unyielding barrage of Ripple-charged punches! You've learned Sendo Overdrive!"
				addverb(/mob/keyable/verb/Vapor_Freeze)
			if(level == 40)
				savant<<"The Ripple is pulsating within your body, granting you the ability to launch an unyielding barrage of Ripple-charged punches! You've learned Sendo Overdrive!"
				addverb(/mob/keyable/verb/Space_Ripper_Stingy_Eyes)
			if(level == 50)
				savant<<"The Ripple is pulsating within your body, granting you the ability to launch an unyielding barrage of Ripple-charged punches! You've learned Sendo Overdrive!"
				addverb(/mob/keyable/verb/Zombification)
			if(level == 60)
				savant<<"The Ripple is pulsating within your body, granting you the ability to launch an unyielding barrage of Ripple-charged punches! You've learned Sendo Overdrive!"
				addverb(/mob/keyable/verb/Mist_Form)
			if(level == 75)
				savant<<"The Ripple is pulsating within your body, granting you the ability to launch an unyielding barrage of Ripple-charged punches! You've learned Sendo Overdrive!"
				addverb(/mob/keyable/verb/Flesh_Buds)
			if(level == 100)
				savant<<"The Ripple is pulsating within your body, granting you the ability to launch an unyielding barrage of Ripple-charged punches! You've learned Sendo Overdrive!"
				addverb(/mob/keyable/verb/Create_Blood_Chalice)*/