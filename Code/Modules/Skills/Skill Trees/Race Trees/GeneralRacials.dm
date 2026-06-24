//General racials. Racial trees can pick and choose from these and it'll all usually work.

/datum/skill/general/Hardened_Body
	skilltype = "Physical"
	name = "Hardened Body"
	desc = "Your body becomes slightly harder, allowing yourself to take attacks more easily. P.Def+++"
	can_forget = FALSE
	common_sense = FALSE
	tier = 1
	maxlevel=2
	expbarrier=10000

/datum/skill/general/Hardened_Body/after_learn()
	savant<<"Your body grows a thick layer of leather or padding over the top of your regular skin."
	savant.physdefBuff += 0.2

/datum/skill/general/Hardened_Body/before_forget()
	savant<<"The thick layer of leather that once laid on top of your skin disintergrates, leaving somewhat vunerable skin underneath."
	switch(level)
		if(0)
			savant.physdefBuff -= 0.2
		if(1)
			savant.physdefBuff -= 0.4
		if(2)
			savant.physdefBuff -= 0.6

/datum/skill/general/Hardened_Body/effector()
	..()
	switch(level)
		if(0)
			if(levelup)
				levelup = 0
			exp+=1
		if(1)
			if(levelup)
				levelup = 0
				savant << "Your skin becomes even thicker!."
				savant.physdefBuff += 0.2
			exp+=1
		if(2)
			if(levelup)
				levelup = 0
				savant << "Your skin is as tough as armor now, what have you been eating?"
				savant.physdefBuff += 0.2

/datum/skill/general/LankyLegs
	skilltype = "Physical"
	name = "Taller Legs"
	desc = "Your body becomes slightly taller and skinnier, allowing you to move faster. Tech++, Spd++"
	can_forget = FALSE
	common_sense = FALSE
	tier = 1
	maxlevel=2
	expbarrier=10000

/datum/skill/general/LankyLegs/after_learn()
	savant<<"Your legs contort into a taller shape, and vague definitions of muscle ripple underneath"
	savant.speedBuff += 0.1
	savant.techniqueBuff += 0.1

/datum/skill/general/LankyLegs/before_forget()
	savant<<"The legs that once supported you proudly wither into their previous smaller and weaker shape."
	switch(level)
		if(0)
			savant.speedBuff -= 0.1
			savant.techniqueBuff -= 0.1
		if(1)
			savant.speedBuff -= 0.2
			savant.techniqueBuff -= 0.2
		if(2)
			savant.speedBuff -= 0.3
			savant.techniqueBuff -= 0.3


/datum/skill/general/LankyLegs/effector()
	..()
	switch(level)
		if(0)
			if(levelup)
				levelup = 0
			exp+=1
		if(1)
			if(levelup)
				levelup = 0
				savant << "Your legs become even stronger!."
				savant.speedBuff += 0.1
				savant.techniqueBuff += 0.1
			exp+=1
		if(2)
			if(levelup)
				levelup = 0
				savant << "Your legs have become finely tuned running machines."
				savant.speedBuff += 0.1
				savant.techniqueBuff += 0.1

/datum/skill/general/ProudArms
	skilltype = "Physical"
	name = "Proud Arms"
	desc = "Your arms become gifted with extra strength, allowing you to hit harder. P.Off+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1

/datum/skill/general/ProudArms/after_learn()
	savant<<"Your arms shake outwards, muscle flailing to the surface as your limbs become defined."
	savant.physoffBuff += 0.2

/datum/skill/general/ProudArms/before_forget()
	savant<<"The arms that once supported you proudly wither into their previous smaller and weaker shape."
	savant.physoffBuff -= 0.2

/datum/skill/general/Willed
	skilltype = "Physical"
	name = "Willed"
	desc = "Your mind scrunches up, focused on one task. You won't give up easily, no matter what. StamGain+, Will+, Satiety+"
	can_forget = FALSE
	common_sense = FALSE
	tier = 1

/datum/skill/general/Willed/after_learn()
	savant<<"Your mind hardens as the tasks before you become smaller. What was once a insurmountable mountain looks now like a peaceful trail, dotting up a hill."
	savant.willpowerMod += 0.1
	savant.staminagainMod += 0.1
	savant.satiationMod += 0.1

/datum/skill/general/Willed/before_forget()
	savant<<"Your mind weakens, and the tasks before you become larger than life."
	savant.willpowerMod -= 0.1
	savant.staminagainMod -= 0.1
	savant.satiationMod -= 0.1