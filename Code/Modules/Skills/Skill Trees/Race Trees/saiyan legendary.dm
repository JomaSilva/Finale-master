/datum/skill/tree/lssj
	name="Legendary Mastery"
	desc="Given to all Legandary Super Saiyans after first transforming."
	maxtier=2
	allowedtier =3
	tier=0
	enabled=0
	can_refund = FALSE
	compatible_races = list("Saiyan")
	constituentskills = list(new/datum/skill/forms/ssj,new/datum/skill/forms/mssj,new/datum/skill/forms/lssjm,new/datum/skill/forms/ssj/DirectSSJ,new/datum/skill/lssj/Limitless_Energy,new/datum/skill/lssj/Legendary_Power)

/datum/skill/tree/lssj/growbranches()
	..()
	if(savant.lssj==3)
		allowedtier = 4

/datum/skill/tree/lssj/effector()
	..()
	if(!savant.ismssj)
		if(!savant.HasSkill(/datum/skill/forms/mssj))
			for(var/datum/skill/forms/F in savant.learned_skills)
				switch(F.name)
					if("Super Saiyan Mastery")
						if(F.level==3)
							enableskill(/datum/skill/forms/mssj)

//Legendary masterys to make it faster.
/datum/skill/lssj/Legendary_Power
	skilltype = "Mind Buff"
	name = "Legendary Power"
	desc = "As a Legendary Super Saiyan, your power is maximum! And now, your maximum power is maximum! This doubles your ki capacity... And your drain."
	can_forget = TRUE
	common_sense = FALSE
	compatible_races = list("Saiyan")
	skillcost = 2
	tier = 2
	after_learn()
		savant<<"Your energy flow is overwhelming!"
		savant.kicapacityMod*=2
		savant.PDrainMod*=2
	before_forget()
		savant<<"Your maximum power is no longer maximum?"
		savant.kicapacityMod/=2
		savant.PDrainMod/=2

/datum/skill/lssj/Limitless_Energy
	skilltype = "Mind Buff"
	name = "Limitless Energy"
	desc = "Your Legendary Super Saiyan form bursts with energy! You now gain even more ki in this form!"
	can_forget = TRUE
	common_sense = FALSE
	compatible_races = list("Saiyan")
	skillcost = 2
	tier = 2
	after_learn()
		savant<<"Your ki erupts!"
		savant.lssjenergymod *= 1.5
		savant.lssjdrain *= 2
		savant.lssjmult+=15
	before_forget()
		savant<<"Your ki is weak."
		savant.lssjenergymod /= 1.5
		savant.lssjdrain /= 2
		savant.lssjmult-=15


/datum/skill/forms/lssjm
	skilltype = "Super Saiyan Form"
	name = "Mastered Legendary Super Saiyan"
	desc = "The user starts to master the Legendary form, with the end result of almost eliminating the drain, and increasing the power a bit."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	compatible_races = list("Saiyan")
	maxlevel = 2
	tier = 4
	enabled=0
	level = 0
	exp = 0
	expbarrier = 10000

/datum/skill/forms/lssjm/effector()
	..()
	switch(level)
		if(0)
			if(levelup == 1)
				levelup = 0
			if(savant.kiratio>1&&savant.lssj>=2)
				exp+=1*savant.kiratio
		if(1)
			if(levelup == 1)
				levelup = 0
				savant<<"You've almost mastered Legendary Super Saiyan!"
				savant.lssjmult+=5
				savant.lssjdrain-=0.002
				savant.lssjenergymod *= 1.1
			expbarrier=100000
			if(savant.kiratio>1&&savant.lssj>=2)
				exp+=1+(savant.kiratio/2)
		if(2)
			if(levelup == 1)
				levelup = 0
				savant<<"You've mastered Legendary Super Saiyan!"
				savant.lssjmult+=5
				savant.lssjdrain-=0.003
				savant.lssjenergymod *= 1.1
			if(savant.kiratio>1&&savant.lssj>=2)
				exp+=1*savant.kiratio
		if(3)
			if(levelup == 1)
				levelup = 0
				savant<<"You've done it!"