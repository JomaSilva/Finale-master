/datum/skill/tree/heran
	name="Heran Racials"
	desc="Given to all Herans at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Heran")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,new/datum/skill/heran/Heran_Power,\
	new/datum/skill/general/regenerate,new/datum/skill/heran/MstedTMXPWR,new/datum/skill/heran/MstedMXPWR,new/datum/skill/heran/Energy_Blues,new/datum/skill/heran/Psycho_Thread)

	growbranches()
		..()
		if(savant.hasssj) enableskill(/datum/skill/heran/MstedMXPWR)
		if(savant.hasssj2) enableskill(/datum/skill/heran/MstedTMXPWR)
/datum/skill/tree/heran/effector()
	..()
	if(savant)
		if(!TurnOffAscension||savant.AscensionAllowed)
			
			if(!savant.hasssj&&savant.BP>=savant.ssjat)
				switch(savant.Emotion)
					if("Very Angry")
						savant.hasssj=1
						allowedtier = 3
						savant.Max_Power()
					if("Angry")
						if((savant.ssjat*1.3)<=savant.BP || prob(savant.SSJInspired * 1.25))
							savant.hasssj=1
							allowedtier = 3
							savant.Max_Power()
					if("Annoyed")
						if((savant.ssjat*2.2)<=savant.BP || prob(savant.SSJInspired * 1.25))
							savant.hasssj=1
							allowedtier = 3
							savant.Max_Power()
			if(!savant.hasssj2&&savant.ssj2at/50<=savant.BP&&savant.ssj)
				switch(savant.Emotion)
					if("Very Angry")
						savant.hasssj2=1
						allowedtier = 5
						savant.True_Max_Power()
					if("Angry")
						if((savant.ssj2at*1.2/50)<=savant.BP || prob((savant.SSJInspired - 25) * 1.25))
							savant.hasssj2=1
							allowedtier = 5
							savant.True_Max_Power()
					if("Annoyed")
						if((savant.ssj2at*2/50)<=savant.BP || prob((savant.SSJInspired - 25) * 1.25))
							savant.hasssj2=1
							allowedtier = 5
							savant.True_Max_Power()

/datum/skill/heran/Heran_Power
	skilltype = "Heran Form"
	name = "Heran Power"
	desc = "From your own Zenkai, supercharge your energy during a fight for an explosive increase in power!"
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	tier = 1
	level = 1
	maxlevel = 7
	var/tmp/ki_boost_buffer = 0
	effector()
		..()
		if(levelup)
			levelup = 0
			expbarrier = 10 ** (level+1)
			savant << "Your zenkai grows even further! Level [level] reached!"
		if(savant.IsInFight)
			if(savant.expressedBP < savant.highestebp)
				ki_boost_buffer++
				exp++
			if(ki_boost_buffer > 10*level)
				ki_boost_buffer-=10*level
				exp+=savant.SparMod ** level
				savant.Attack_Gain(level+savant.ZenkaiMod/40)
				savant.Ki += 10 * savant.BaseDrain

	after_learn()
		savant << "Your power begins to throbs every time your fists matches another..."

	before_forget()
		savant << "Your power fades."

/datum/skill/heran/MstedMXPWR
	name="Mastered Max Power"
	desc="Master your max power transformation, gradually reducing the drain and increasing the multiplier by a bit."
	tier=3
	skillcost = 2
	can_forget = FALSE
	common_sense = FALSE
	enabled=0
	expbarrier=2000

/datum/skill/heran/MstedTMXPWR
	name="Mastered true Max Power"
	desc="Master your true max power transformation, gradually reducing the drain and increasing the multiplier by a bit."
	tier=5
	skillcost = 2
	can_forget = FALSE
	common_sense = FALSE
	enabled=0
	expbarrier=4000

/datum/skill/heran/MstedMXPWR/effector()
	..()
	switch(level)
		if(0)
			if(levelup)
				levelup = 0
			if(savant.ssj)
				exp+=1
		if(1)
			if(levelup)
				levelup = 0
				savant << "You've just accomplished a milestone in your efforts to master your transformation!"
				savant.ssjmult*=1.2
				savant.ssjdrain = 0.20
				expbarrier=4000
			if(savant.ssj)
				exp+=1
		if(2)
			if(levelup)
				levelup = 0
				savant << "You've just accomplished a milestone in your efforts to master your transformation!"
				savant.ssjmult*=1.4
				savant.ssjdrain = 0.10
				expbarrier=8000
			if(savant.ssj)
				exp+=1
		if(3)
			if(levelup)
				levelup = 0
				savant << "You've just completely mastered your transformation!!"
				savant.ssjmult*=1.2
				savant.ssjdrain = 0.01

/datum/skill/heran/TMstedMXPWR/effector()
	..()
	switch(level)
		if(0)
			if(levelup)
				levelup = 0
			if(savant.ssj)
				exp+=1
		if(1)
			if(levelup)
				levelup = 0
				savant << "You've just accomplished a milestone in your efforts to master your transformation!"
				savant.ssj2mult*=1.2
				savant.ssj2drain = 0.25
				expbarrier=5000
			if(savant.ssj==2)
				exp+=1
		if(2)
			if(levelup)
				levelup = 0
				savant << "You've just accomplished a milestone in your efforts to master your transformation!"
				savant.ssj2mult*=1.4
				savant.ssj2drain = 0.15
				expbarrier=8000
			if(savant.ssj==2)
				exp+=1
		if(3)
			if(levelup)
				levelup = 0
				savant << "You've just completely mastered your transformation!!"
				savant.ssj2mult*=1.2
				savant.ssj2drain = 0.05


/datum/skill/heran/Energy_Blues
	name="Energy Blues"
	desc="Increase your energy modifiers, allowing you to power up even further."
	tier=1
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE

	after_learn()
		savant << "Your energy mod in general have increased!"
		savant.ssjenergymod = 3
		savant.ssj2energymod = 4
		savant.kicapacityMod *= 2
		savant.genome.add_to_stat("Energy Level",2)

/datum/skill/heran/Psycho_Thread
	name="Psycho Thread"
	desc="A racial ability the race of Hera has is to manipulate strings. Created by subconciousness, these are normally mundane and undetectable. Under conditions, you can create them wherever. They're great at stunning enemies."
	tier=1
	skillcost = 1
	can_forget = TRUE
	common_sense = FALSE

	after_learn()
		savant << "You can use Psycho Threads, just click on the ground to place them."
		assignverb(/mob/keyable/verb/Psycho_Thread)
		savant.psythre=1
	before_forget()
		savant << "You've forgotten Psycho Threads..."
		unassignverb(/mob/keyable/verb/Psycho_Thread)
		savant.psythre=0
	login(var/mob/logger)
		..()
		savant.psythre=1
		assignverb(/mob/keyable/verb/Psycho_Thread)
mob/var/tmp/psythre=0

mob/keyable/verb/Psycho_Thread()
	set category = "Skills"
	if(usr.psythre)
		usr.psythre = 0
		usr << "Psycho Thread disabled."
	else
		usr.psythre = 1
		usr << "Psycho Thread enabled."