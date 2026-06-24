/datum/skill/tree/makyo
	name="Makyo Racials"
	desc="Given to all Makyos at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Makyo")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/conjure,new/datum/skill/expand,new/datum/skill/makyo/Sun,new/datum/skill/makyo/Moon,new/datum/skill/makyo/Above_All,new/datum/skill/makyo/Supreme_Magic)



/datum/skill/makyo/Sun
	skilltype = "misc"
	name = "Sun"
	desc = "As a makyo, the Makyo Star empowers you. Gain the same boost with the Sun, but at a somewhat smaller rate."
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	level = 1
	expbarrier = 10000
	maxlevel = 4
	after_learn()
		savant<<"The sun shall empower you!!"
		for(var/datum/skill/tree/T in savant.possessed_trees)
			if(src in T.constituentskills)
				for(var/datum/skill/nS in T.constituentskills)
					if(nS.type==/datum/skill/makyo/Moon)
						if(nS.enabled) savant<<"You can no longer learn [nS.name]!"
						nS.enabled=0
						break
				break

	before_forget()
		savant<<"The sun abandones thee..."
	effector()
		..()
		if(levelup)
			levelup=0
			savant << "Your \"ONE\" skill is level [level]!"
			expbarrier = 10000 * (2 ** level)
		if(!locate(/datum/skill/makyo/Above_All) in savant.learned_skills)
			switch(savant.currentDaylight)
				if(1)
					savant.ssjBuff = 1.2 + level
				if(2)
					savant.ssjBuff = 1.6 + level
				if(3)
					savant.ssjBuff = 2 + level
					if(level<maxlevel) exp++
				if(4)
					savant.ssjBuff = 1.6 + level
				if(5)
					savant.ssjBuff = 1.2 + level

/datum/skill/makyo/Moon
	skilltype = "misc"
	name = "Moon"
	desc = "As a makyo, the Makyo Star empowers you. Gain a magical boost with the Moon."
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	level = 1
	expbarrier = 10000
	maxlevel = 4
	after_learn()
		savant<<"The moon shall empower you!!"
		for(var/datum/skill/tree/T in savant.possessed_trees)
			if(src in T.constituentskills)
				for(var/datum/skill/nS in T.constituentskills)
					if(nS.type==/datum/skill/makyo/Sun)
						if(nS.enabled) savant<<"You can no longer learn [nS.name]!"
						nS.enabled=0
						break
				break
	before_forget()
		savant<<"The moon abandones thee..."
	effector()
		..()
		if(levelup)
			levelup=0
			savant << "Your \"MONE\" skill is level [level]!"
			expbarrier = 10000 * (2 ** level)
		switch(savant.currentDaylight)
			if(6 to 10)
				savant.ssjBuff = 1.2 + level
		if(savant.currentDaylight >= 6)
			switch(savant.currentMoonlight==5)
				if(2)savant.Tmagimon = 1.2
				if(3)savant.Tmagimon = 1.6
				if(4)savant.Tmagimon = 2
				if(5)savant.Tmagimon = 3
				if(6)savant.Tmagimon = 2
				if(7)savant.Tmagimon = 1.6
				if(8)savant.Tmagimon = 1.2

mob/var/hellstar_disabled = 1

/datum/skill/makyo/Above_All
	skilltype = "misc"
	name = "Sun"
	desc = "Sacrifice your Makyo Star boost for a massive gains and BP boost while under Daylight. However, as a price, you'll also have less BP than normal during nighttime."
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	level = 1
	expbarrier = 10000
	maxlevel = 5
	var/gaingot = 0
	after_learn()
		savant<<"The sun shall empower you further beyond!!"
		savant.hellstar_disabled=0

	before_forget()
		savant<<"The sun abandones thee..."
	effector()
		..()
		if(levelup)
			levelup=0
			savant << "Your Almighty \"ONE\" skill is level [level]!"
			expbarrier = 10000 * (3 ** level)
		if(savant.currentDaylight != 3)
			if(gaingot)
				savant.tgains /= 5
				gaingot = 0
		switch(savant.currentDaylight)
			if(1)
				savant.ssjBuff = 1.2 + level
				if(savant.Ki < savant.MaxKi*2.5)
					savant.Ki += 0.0005 * savant.MaxKi * level //passive Ki boost
				savant.overcharge = 1
			if(2)
				savant.ssjBuff = 1.6 + level
				if(savant.Ki < savant.MaxKi*2.5)
					savant.Ki += 0.0006 * savant.MaxKi * level //passive Ki boost
				savant.overcharge = 1
			if(3)
				savant.ssjBuff = 2 + level
				if(level<maxlevel) exp++
				if(!gaingot)
					savant.tgains *= 5
					gaingot = 1
				if(savant.Ki < savant.MaxKi*2.5)
					savant.Ki += 0.0009 * savant.MaxKi * level //passive Ki boost
				savant.overcharge = 1
			if(4)
				savant.ssjBuff = 1.6 + level
				if(savant.Ki < savant.MaxKi*2.5)
					savant.Ki += 0.0006 * savant.MaxKi * level //passive Ki boost
				savant.overcharge = 1
			if(5)
				savant.ssjBuff = 1.2 + level
				if(savant.Ki < savant.MaxKi*2.5)
					savant.Ki += 0.0005 * savant.MaxKi * level //passive Ki boost
				savant.overcharge = 1

/datum/skill/makyo/Supreme_Magic
	skilltype = "misc"
	name = "Supreme Magic"
	desc = "Immediately gain some more magical mastery. The moon increases your magic passively."
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	level = 1
	expbarrier = 10000
	maxlevel = 4
	after_learn()
		savant<<"The moon shall empower you!!"
		savant.magiBuff++
	before_forget()
		savant<<"The moon abandones thee..."
		savant.magiBuff--
	effector()
		..()
		if(levelup)
			levelup=0
			savant << "Your Supreme \"MONE\" skill is level [level]!"
			expbarrier = 10000 * (3 ** level)
		if(savant.currentDaylight >= 6)
			switch(savant.currentMoonlight==5)
				if(2) if(prob(10)) savant.Magic += 1 + level
				if(3) if(prob(20)) savant.Magic += 1 + level
				if(4) if(prob(45)) savant.Magic += 1 + level
				if(6) savant.Magic += 1 + level
				if(5) if(prob(45)) savant.Magic += 1 + level
				if(7) if(prob(20)) savant.Magic += 1 + level
				if(8) if(prob(10)) savant.Magic += 1 + level