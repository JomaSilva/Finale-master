/datum/skill/tree/Spirit
	name = "Strength of Spirit"
	desc = "General Spiritual Ability"
	maxtier = 10
	tier=0
	constituentskills = list(new/datum/skill/SpiritUnleashed,new/datum/skill/heartsea,new/datum/skill/upper,new/datum/skill/lower,new/datum/skill/GreaterWill,\
		new/datum/skill/Spirit_Ball,new/datum/skill/Spirit_Fist)
	allowedtier=1
	growbranches()
		if(invested>=1&&invested<4)
			allowedtier=3
		if(invested>=4)
			allowedtier=4
		if(invested>=4)
			enabletree(/datum/skill/tree/Magic)
		if(savant.gravitatecheck)
			savant.gravitatecheck=0
			if(savant.gravitate==0)
				whitelist(/datum/skill/upper)
				whitelist(/datum/skill/lower)
			if(savant.gravitate==1)
				blacklist(/datum/skill/lower)
			if(savant.gravitate==2)
				blacklist(/datum/skill/upper)
			if(savant.gravitate)
				enableskill(/datum/skill/GreaterWill)
		..()
		return
mob/var/gravitate
mob/var/gravitatecheck

/datum/skill/SpiritUnleashed
	skilltype = "Sprit Buff"
	name = "Spirit Unleashed"
	desc = "Your fighting spirit awakens! Your willpower increases, and you feel your stamina increase marginally!"
	can_forget = FALSE
	common_sense = TRUE
	teacher=TRUE
	skillcost=1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You feel your spirit well up inside you!."
		savant.willpowerMod+=0.1
		savant.maxstamina+=10

mob/var/MeditateGivesKiRegen=1 //Manually set to 0 on character creation.

/datum/skill/DeepBreathing
	skilltype = "Spirit Buff"
	name = "Deep Breathing"
	desc = "The user forms a habit of breathing exercises that calms the nerves, improves the senses, and keeps one motivated. KiMod+, Will+"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	skillcost = 1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You feel more at ease as air flows through you."
		savant.genome.add_to_stat("Energy Level",0.05)
		savant.willpowerMod+=0.05
	before_forget()
		savant<<"Due to neglect, you forget your deep breathing routine. However, you forogt it so well that, for half a minute, you forgot how to breath and nearly fall over."
		savant.genome.sub_to_stat("Energy Level",0.05)
		savant.willpowerMod-=0.05

/datum/skill/heartsea
	skilltype = "Sprit Buff"
	name = "Heart-Sea"
	desc = "The user manifests a bastion of Ki below their heart. KiMod++"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	skillcost=1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You feel centered."
		savant.genome.add_to_stat("Energy Level",0.3)
	before_forget()
		savant<<"Your Heart-Sea dissipates, and with it, your grasp on self."
		savant.genome.sub_to_stat("Energy Level",0.3)

/datum/skill/upper
	skilltype = "Spirit Buff"
	name = "Upper Gravitation"
	desc = "The user focuses their free-flowing Ki towards their head. KiOff+, P.Off-, KiMod+"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	prereqs = list(new/datum/skill/heartsea)
	enabled = 0
	maxlevel = 1
	tier = 2
	after_learn()
		savant<<"You feel elevated."
		savant.kioffBuff+=0.1
		savant.physoffBuff-=0.2
		savant.genome.add_to_stat("Energy Level",0.09)
		savant.gravitate=1
		savant.gravitatecheck=1
	before_forget()
		savant<<"You lose your heightened self."
		savant.kioffBuff-=0.1
		savant.physoffBuff+=0.2
		savant.genome.add_to_stat("Energy Level",0.09)
		savant.gravitate=0
		savant.gravitatecheck=1

/datum/skill/lower
	skilltype = "Spirit Buff"
	name = "Lower Gravitation"
	desc = "The user focuses their free-flowing Ki towards their groin. P.Off+, KiOff-, KiMod+"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	prereqs = list(new/datum/skill/heartsea)
	enabled = 0
	maxlevel = 1
	tier = 2
	after_learn()
		savant<<"You feel grounded."
		savant.physoffBuff+=0.1
		savant.kioffBuff-=0.2
		savant.genome.add_to_stat("Energy Level",0.05)
		savant.gravitate=2
		savant.gravitatecheck=1
	before_forget()
		savant<<"You lose your grounded self."
		savant.physoffBuff-=0.1
		savant.kioffBuff+=0.2
		savant.genome.sub_to_stat("Energy Level",0.05)
		savant.gravitate=0
		savant.gravitatecheck=1

/datum/skill/ControlledBreathing
	skilltype = "Spirit Buff"
	name = "Controlled Breathing"
	desc = "Modifying the original breathing routine, the user works new, advanced breathing exercises into their martial arts techniques. KiMod+, Will+, Tech+"
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list(new/datum/skill/DeepBreathing)
	enabled = 0
	maxlevel = 1
	skillcost = 1
	after_learn()
		savant<<"You steady your breathing even more, and your body reaps the benefits."
		savant.genome.add_to_stat("Energy Level",0.1)
		savant.willpowerMod+=0.1
		savant.techniqueBuff+=0.05
		spawn(15)
			savant.emit_Sound('hamon.wav')
		savant<<"Eh? You felt a rather bizarre energy flow through you while inhaling..."
		savant.willpowerMod+=0.05
	before_forget()
		savant<<"You slack off on your new breathing routine and forget how to do it properly. Its useless to you unless you can remember how to do it."
		savant.genome.sub_to_stat("Energy Level",0.1)
		savant.willpowerMod-=0.15
		savant.techniqueBuff-=0.05

/datum/skill/GreaterWill
	skilltype = "Spirit Buff"
	name = "Greater Willpower"
	desc = "The user's spiritual prowess grants them further willpower bonuses. KiMod+, Will+"
	can_forget = TRUE
	common_sense = TRUE
	enabled = 0
	maxlevel = 1
	skillcost = 2
	tier = 3
	after_learn()
		savant<<"Your spirit fills you with will."
		savant.genome.add_to_stat("Energy Level",0.05)
		savant.willpowerMod+=0.1
	before_forget()
		savant<<"The spirit supporting your willpower faulters, you've lost some determination it seems."
		savant.genome.sub_to_stat("Energy Level",0.05)
		savant.willpowerMod-=0.1

/datum/skill/HamonBreathing
	skilltype = "Ki"
	name = "Hamon Breathing"
	desc = "The hidden potential of your breathing exercises unlocks! You can heal yourself slightly with your strengthed breathing. Your healing is impacted by your willpower. KiMod++, Will+"
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list(new/datum/skill/ControlledBreathing)
	enabled = 0
	expbarrier = 10
	maxlevel = 1
	skillcost = 2
	tier = 3
	var/accum
	after_learn()
		savant.emit_Sound('hamon.wav')
		savant<<"You feel your entire being ripple with energy as you breath."
		savant.genome.add_to_stat("Energy Level",0.3)
		savant.willpowerMod+=0.1
		assignverb(/mob/keyable/verb/HamonBreathing)
	before_forget()
		savant<<"You haven't been keeping up with your breathing technique, thus you've forgotten your Hamon breathing ability."
		savant.genome.add_to_stat("Energy Level",0.3)
		savant.willpowerMod-=0.1
		if(level >= 2)
			savant.genome.sub_to_stat("Energy Level",0.1)
			savant.willpowerMod-=0.05
		unassignverb(/mob/keyable/verb/HamonBreathing)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/HamonBreathing)
	effector()
		..()
		switch(level)
			if(0)
				if(levelup)
					levelup=0
				if(savant.HBCount)
					savant.HBCount-=1
					exp+=1
			if(1)
				if(levelup)
					levelup=0
					savant<<"Your Hamon breathing has improved a bit!"
					savant.HBCost=12
					expbarrier=60
				if(savant.HBCount)
					savant.HBCount-=1
					exp+=1
			if(2)
				if(levelup)
					levelup=0
					savant<<"Your Hamon breathing has improved greatly!"
					savant.HBCost=5
					savant.genome.add_to_stat("Energy Level",0.1)
					savant.willpowerMod+=0.05
					expbarrier=60
				if(savant.HBCount)
					savant.HBCount=0

mob/var
	tmp/HBCount = 0
	HBCost = 25
	tmp/HBOn = 0
	tmp/HBcooldown = 0

mob/keyable/verb/HamonBreathing()
	set category = "Skills"
	set name = "Hamon Breathing"
	var/kireq=usr.MaxKi/(usr.HBCost)
	if(usr.Ki>=kireq && usr.HP<100 && !usr.blasting && !usr.KO)
		if(!usr.HBOn)
			usr<<"You use your Hamon breathing to heal!"
			oview(usr)<<"[usr] deeply inhales and is covered in a bizarre light!"
			//usr.canfight=0
			HBOn=1
			HBcooldown = 180 - hamon_skill*8
			spawn
				while(HBcooldown >= 0)
					HBcooldown -= 10
					sleep(10)
				HBOn=0
			HBCount+=1
			usr.hamon_skill_buffer += 1
			if(usr.hamon_skill_buffer >= 25 && !usr.hamon_skill)
				usr.hamon_skill_buffer = 0
				usr.hamon_skill += 1
				oview(usr)<<"<font color=yellow>[usr]'s body suddenly ripples, [usr]'s strength deepening! You can learn hamon!</font>"
			emit_Sound('hamonhealing.wav')
			usr.Ki-=kireq
			usr.SpreadHeal(1*willpowerMod+hamon_skill)
			//usr.canfight=1
		else if(usr.HBOn)
			usr<<"Your Hamon Breathing is on cooldown. ([HBcooldown] seconds)"
	else if(usr.Ki<=kireq) usr<<"You have no energy left to use Hamon. This requires atleast [kireq] energy to use."
	else usr<<"You cannot use Hamon breathing to heal you right now."

/datum/skill/Spirit_Ball
	skilltype = "Spirit Attack"
	name = "Spirit Gun"
	desc = "You can create and fire a small Spirit Ball, dealing decent amounts of damage. This attack comes straight from your Stamina however, not your Ki. KiMod+, Will+"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled = 0
	maxlevel = 2
	prereqs = list(new/datum/skill/GreaterWill)
	expbarrier = 10
	skillcost = 1
	tier = 3
	after_learn()
		savant<<"Your spirit that fills your body begins to bubble. There are martial applications to this..."
		savant.genome.add_to_stat("Energy Level",0.05)
		savant.willpowerMod+=0.1
		assignverb(/mob/keyable/verb/Spirit_Gun)
	before_forget()
		savant<<"The spirit once at the surface faulters, you've lost some determination it seems."
		savant.genome.sub_to_stat("Energy Level",0.05)
		savant.willpowerMod-=0.1
		if(level >= 2)
			savant.genome.sub_to_stat("Energy Level",0.05)
			savant.willpowerMod-=0.1
		savant.SpiritBallCost = 2
		savant.SpiritBallDamage = 1
		unassignverb(/mob/keyable/verb/Spirit_Gun)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Spirit_Gun)
	effector()
		..()
		switch(level)
			if(0)
				if(levelup)
					levelup=0
				if(savant.SpiritBallFireCount)
					savant.SpiritBallFireCount-=1
					exp+=1
			if(1)
				if(levelup)
					levelup=0
					savant<<"Your spirit abilities have increased a bit!"
					savant.SpiritBallCost/=2
					savant.SpiritBallDamage*=2
					expbarrier=20
				if(savant.SpiritBallFireCount)
					savant.SpiritBallFireCount-=1
					exp+=1
			if(2)
				if(levelup)
					levelup=0
					savant<<"Your spirit abilities have increased a bunch!"
					savant.SpiritBallCost/=2
					savant.SpiritBallDamage*=1.25
					savant.genome.add_to_stat("Energy Level",0.05)
					savant.willpowerMod+=0.1
					expbarrier=20
				if(savant.SpiritBallFireCount)
					savant.SpiritBallFireCount=0

mob/var
	tmp/SpiritBallFireCount = 0
	SpiritBallCost = 2
	SpiritBallDamage = 1

mob/keyable/verb/Spirit_Gun()
	set category = "Skills"
	var/kireq=angerBuff*usr.Ephysoff*SpiritBallCost*10
	if(!usr.med&&!usr.train&&!usr.KO&&usr.stamina>=kireq&&!usr.basicCD&&usr.canfight)
		var/passbp = 0
		var/reload=usr.Eactspeed/6
		if(reload<0.1)reload=0.1
		usr.basicCD+=reload+45
		SpiritBallFireCount+=1
		usr.stamina-=kireq
		passbp=usr.expressedBP * SpiritBallDamage
		usr.Attack_Gain()
		var/bcolor='Blast - Spiraling Ki.dmi'
		bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
		var/obj/attack/blast/A=new/obj/attack/blast
		emit_Sound('fire_kiblast.wav')
		A.loc=locate(usr.x,usr.y,usr.z)
		A.icon=bcolor
		A.icon_state=usr.BLASTSTATE
		A.density=1
		A.basedamage=1 * SpiritBallDamage
		A.BP=passbp
		A.mods=usr.Ekioff*usr.Ekiskill*usr.Ephysoff
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		walk(A,usr.dir)
		A.Burnout()

/datum/skill/Spirit_Fist
	skilltype = "Spirit Attack"
	name = "Spirit Fist"
	desc = "You can create and fire a small Spirit Fist, dealing decent amounts of damage from close range. This attack comes straight from your Stamina however, not your Ki. KiMod+, Will+"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled = 0
	maxlevel = 2
	prereqs = list(new/datum/skill/GreaterWill)
	expbarrier = 10
	skillcost = 1
	tier = 3
	after_learn()
		savant<<"Your spirit that fills your body begins to bubble. There are martial applications to this..."
		savant.physoffMod+=0.05
		savant.willpowerMod+=0.1
		assignverb(/mob/keyable/verb/Spirit_Fist)
	before_forget()
		savant<<"The spirit once at the surface faulters, you've lost some determination it seems."
		savant.physoffMod-=0.05
		savant.willpowerMod-=0.1
		if(level >= 2)
			savant.physoffMod-=0.05
			savant.willpowerMod-=0.1
		savant.SpiritFistCost = 2
		savant.SpiritFistDamage = 1
		unassignverb(/mob/keyable/verb/Spirit_Fist)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Spirit_Fist)
	effector()
		..()
		switch(level)
			if(0)
				if(levelup)
					levelup=0
				if(savant.SpiritFistFireCount)
					savant.SpiritFistFireCount-=1
					exp+=1
			if(1)
				if(levelup)
					levelup=0
					savant<<"Your spirit abilities have increased a bit!"
					savant.SpiritFistCost/=2
					savant.SpiritBallDamage*=2
					expbarrier=20
				if(savant.SpiritFistFireCount)
					savant.SpiritFistFireCount-=1
					exp+=1
			if(2)
				if(levelup)
					levelup=0
					savant<<"Your spirit abilities have increased a bunch!"
					savant.SpiritFistCost/=2
					savant.SpiritFistDamage*=1.25
					savant.physoffMod+=0.05
					savant.willpowerMod+=0.1
					expbarrier=20
				if(savant.SpiritFistFireCount)
					savant.SpiritFistFireCount=0

mob/var
	tmp/SpiritFistFireCount = 0
	SpiritFistCost = 2
	SpiritFistDamage = 1

mob/keyable/verb/Spirit_Fist()
	set category = "Skills"
	var/kireq=angerBuff*usr.Ephysoff*SpiritFistCost
	if(!usr.med&&!usr.train&&!usr.KO&&usr.stamina>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=45
		if(MeleeAttack(SpiritFistDamage*3,TRUE))
			SpiritFistFireCount+=1
			usr.stamina-=kireq