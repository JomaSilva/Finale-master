/datum/skill/tree/gray
	name="Gray Racials"
	desc="Given to all Grays at the start."
	maxtier=2
	allowedtier=2
	tier=0
	enabled=1
	can_refund = FALSE
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/fullpower,new/datum/skill/expand,new/datum/skill/gray/meditatepower,new/datum/skill/gray/brainpower)

/datum/skill/tree/gray/effector()
	..()
	for(var/datum/skill/gray/meditatepower/S in savant.learned_skills)
		if(S.level==3)
			enableskill(/datum/skill/fullpower)
	if(savant.Class=="Hermano")
		enableskill(/datum/skill/gray/brainpower)

/datum/skill/gray/meditatepower
	name="Meditate Power"
	desc="Gain extra power while meditating. In addition, this unlocks more skills down the line, for both Hermanos and Grays."
	enabled = 1
	skillcost = 2
	tier = 1
	can_forget = FALSE
	common_sense = FALSE
	maxlevel = 3
	expbarrier = 8000

	after_learn()
		savant<<"Whenever you meditate, and feel one with your power, a small pulse is felt."
		savant.MedMod*=2

	effector()
		..()
		switch(level)
			if(0)
				if(levelup)
					levelup = 0
				if(savant.med)
					exp+=2
			if(1)
				if(levelup)
					levelup = 0
					savant << "The small pulse felt when meditating grows larger. Perhaps if you meditate some more..."
				if(savant.med)
					exp+=1
			if(2)
				if(levelup)
					levelup = 0
					savant << "You're slowly getting used to the pulse, which is now releasing power at a fast rythmn..."
					savant.MedMod*=1.1
				if(savant.med)
					exp+=1
			if(3)
				if(levelup)
					levelup = 0
					savant << "The floodgates have opened. You've unlocked some monsterous power!"
					savant.genome.add_to_stat("Ascension Mod",3)
					savant.genome.add_to_stat("Battle Power",3)
					savant.genome.sub_to_stat("Potential",1)
				if(savant.med && prob(10))
					if(savant.BP<savant.relBPmax)
						savant.BP+=savant.capcheck(savant.relBPmax*BPTick*(1/35))

/datum/skill/gray/brainpower
	name="Brain Power"
	desc="Gain more power while meditating. You have a buff that only increases when your intelligence increases."
	enabled = 0
	skillcost = 2
	tier = 1
	can_forget = FALSE
	common_sense = FALSE
	expbarrier = 8000

/datum/skill/gray/brainpower/after_learn()
	savant<<"Your head hurts, as your brain slowly grows and elongates your inner skull. A flurry of power rushes out every pulse of brain-growth... perhaps you could take advantage of this?"
	savant.MedMod*=1.1
	savant.genome.add_to_stat("Battle Power",0.1)

/datum/skill/gray/brainpower/effector()
	..()
	if(savant.med && prob(15))
		if(savant.BP<savant.relBPmax)
			savant.BP+=savant.capcheck(savant.relBPmax*BPTick*max(log(4,savant.techskill*10),1)*(1/75))