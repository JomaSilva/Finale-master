//split up the supersaiyan related skills and regular saiyan skills.
mob/var
	SSJInspired = 0
	DeathAngered = 0
	tmp
		anger_ssj = 1

/datum/skill/tree/saiyan/SaiyanFormMastery/growbranches()
	if(!acquiredSSJtrees)
		if(savant.hasssj)
			acquiredSSJtrees=1
			savant.saiyantreeget(2)
	..()
	return

/datum/skill/tree/saiyan/SaiyanFormMastery/effector() //todo: make saiyan forms at first more restricted. SSJ4 included, but it's obtaining procs are not listed here.
	//essentially: make reg. SSJ admin gib/global voting only, togglable of course. (First SSJ either via admin command, no need for interaction here, voting will need a framework.)
	//if the above is on, and the SSJ is gibbed, then subsequent SSJs can be locally voted. (global var ticked when above is true.)
	//admins would toggle off the above variable after SSJ 'season' is over, and then anyone can get it through the normal canon methods.)
	//need to add inspire and brute forcing it by the way. (powering up after you've spent time with a SSJ, if you're around a SSJ it's easier, otherwise you need anger.)
	//inspire requires anger w/o a SSJ in sight, inspire has a decently sized 'power up req' you also need to hit in base form AND while powered up (thinking around 4-5 million, which is less than Gohan's estimated PL when he popped it.)
	//If U6 Saiyans ever get added: their power up req would be 1.2x complete ascension beepee. (U6 Saiyans would be like DU saiyans- low SSJ mults, but high base BP.)
	..()
	if(savant)
		if(savant.hasssj && !savant.HasSkill(/datum/skill/forms/ssj)) //SSJ liberado -> comeca a Maestria Super Saiyajin automaticamente (sem gastar ponto), inclusive em personagens antigos
			savant.learnSkill(new/datum/skill/forms/ssj, 0)
			savant << "You begin to feel your body adapt to the Super Saiyan form... your mastery will now grow as you use it."
		if(prob(5) && savant.ssj && !savant.transing && !savant.isBuffed(/obj/buff/SuperSaiyan) && !savant.isBuffed(/obj/buff/Werewolf))
			savant.ssj = 0
		if(savant.Class=="Legendary" && savant.anger_ssj) if(!TurnOffAscension||savant.AscensionAllowed)
			if(!savant.hasssj&&savant.expressedBP>=savant.restssjat&&savant.BP>=savant.restssjat*0.8 && savant.canRSSJ)
				switch(savant.Emotion)
					if("Very Angry")
						savant.hasssj=1
						usr.restssjat*=0.5
						savant.Restrained_SSj()
					if("Angry")
						if(savant.expressedBP>=(savant.restssjat*1.5))
							savant.hasssj=1
							savant.Restrained_SSj()
					if("Annoyed")
						if(savant.expressedBP>=(savant.restssjat*2.2))
							savant.hasssj=1
							savant.Restrained_SSj()
			else if(!savant.hasssj&&savant.expressedBP>=savant.unrestssjat&&savant.BP>=savant.unrestssjat*0.8 && !savant.canRSSJ)
				if("Very Angry")
					savant.hasssj=1
					usr.unrestssjat*=0.5
					savant.Unrestrained_SSj()
				if("Angry")
					if(savant.expressedBP>=(savant.unrestssjat*1.5))
						savant.hasssj=1
						savant.Unrestrained_SSj()
				if("Annoyed")
					if(savant.expressedBP>=(savant.unrestssjat*2.2))
						savant.hasssj=1
						savant.Unrestrained_SSj()
		if(!(savant.Class=="Legendary") && savant.anger_ssj) if(!TurnOffAscension||savant.AscensionAllowed) //super sand regular angers (for SSJ 1 and 2. 3 is gained through mastery...)
			if(!savant.hasssj&&savant.expressedBP>=savant.ssjat&&savant.BP>=savant.ssjat*0.8)
				switch(savant.Emotion)
					if("Very Angry")
						savant.SSj()
						savant.hasssj=1
					if("Angry")
						if((savant.ssjat)*1.2<=savant.BP || prob(savant.SSJInspired * 1.25))
							savant.SSj()
							savant.hasssj=1
					if("Annoyed")
						if((savant.ssjat*2.2)<=savant.BP || prob(savant.SSJInspired))
							savant.SSj()
							savant.hasssj=1
			if(!savant.FutureLineage&&!savant.hasssj2&&savant.ssj&&savant.BP>=((savant.ssj2at/savant.ssjmult)*0.3))
				if(savant.ssj2at<=savant.expressedBP)
					switch(savant.Emotion)
						if("Very Angry")
							savant.hasssj2=1
							savant.SSj2()
						if("Angry")
							if((savant.ssj2at*1.2/savant.ssjmult)<=savant.BP || prob((savant.SSJInspired - 25) * 1.25))
								savant.hasssj2=1
								savant.SSj2()
						if("Annoyed")
							if((savant.ssj2at*2.2/savant.ssjmult)<=savant.BP || prob((savant.SSJInspired - 25) * 1.25))
								savant.hasssj2=1
								savant.SSj2()
				else if((savant.ssj2at/1.3)<=savant.expressedBP&&savant.ismssj&&savant.BP>=((savant.ssj2at/savant.ssjmult)*0.7))
					switch(savant.Emotion)
						if("Very Angry")
							savant.hasssj2=1
							savant.SSj2()
						if("Angry")
							if(((savant.ssj2at/1.3)*1.1/savant.ssjmult)<=savant.BP || prob((savant.SSJInspired - 25) * 1.25))
								savant.hasssj2=1
								savant.SSj2()
						if("Annoyed")
							if(((savant.ssj2at/1.3)*2.2/savant.ssjmult)<=savant.BP || prob((savant.SSJInspired - 25) * 1.25))
								savant.hasssj2=1
								savant.SSj2()



/datum/skill/tree/SuperSaiyanMastery
	name = "Super Saiyan Forms"
	desc = "O Super Saiyajin base agora e dominado automaticamente. Aqui voce desbloqueia as formas superiores (SSJ2, SSJ3 e suas maestrias)."
	maxtier =6
	tier=2
	enabled=0
	constituentskills = list(new/datum/skill/forms/ssj,new/datum/skill/forms/ssj/DirectSSJ,new/datum/skill/forms/ussj,new/datum/skill/forms/mssj,new/datum/skill/forms/mssj2,new/datum/skill/forms/ssj3,new/datum/skill/forms/ssj3m,new/datum/skill/forms/ssj4fplb)
	can_refund = FALSE
	allowedtier=6

mob/var/ismssj
/datum/skill/tree/SuperSaiyanMastery/growbranches()
	..()
	if(savant)
		if(savant.hasssj4 && savant.SaiyanLineage=="Primal Saiyan") //Primal com SSJ4 -> libera a skill do Limit Breaker pra compra
			enableskill(/datum/skill/forms/ssj4fplb)
		if(savant.ismssj) //maestria completa (natural) libera a Transformacao Direta para compra
			enableskill(/datum/skill/forms/ssj/DirectSSJ)
		if(savant.hasssj2&&savant.ismssj)
			if(!savant.HasSkill(/datum/skill/forms/mssj2))
				enableskill(/datum/skill/forms/mssj2)
			var/datum/skill/forms/ssj3/twF = locate(/datum/skill/forms/ssj3) in savant.learned_skills
			if(twF && twF.level==3)
				enableskill(/datum/skill/forms/ssj3m)
			var/datum/skill/forms/mssj2/thF = locate(/datum/skill/forms/mssj2) in savant.learned_skills
			if(thF && thF.level==3)
				enableskill(/datum/skill/forms/ssj3)

/datum/skill/forms/ssj
	skilltype = "Super Saiyan Form"
	name = "Super Saiyan Mastery"
	desc = "Begin mastering Super Saiyan, which will unlock new forms down the road."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	maxlevel = 3
	tier = 1
	enabled=0 //skill auto-concedida ao liberar SSJ (fica fora da loja; nao custa ponto)
	expbarrier=2000
/datum/skill/forms/ssj/effector()
	..()
	if(savant.FutureLineage) //Future Lineage: progride em 10 estagios (cada estagio = +2x, ate 20x) em vez dos niveis de maestria normais; nunca recebe USSJ/SSJ2/SSJ3
		if(savant.ssj==1 && savant.futureSSJStage < 10)
			savant.futureSSJExp += 1
			if(savant.futureSSJExp >= 800)
				savant.futureSSJExp = 0
				savant.futureSSJStage += 1
				savant.ssjBuff = min(2 + savant.futureSSJStage * 2, 20) //atualiza o multiplicador ao vivo enquanto transformado
				savant << "<font color=#66ccff>Your Future Super Saiyan grows stronger! Stage [savant.futureSSJStage]/10 reached (power x[min(2 + savant.futureSSJStage * 2, 20)])!</font>"
		return
	switch(level)
		if(0)
			if(levelup == 1)
				levelup=0
			if(savant.ssj==1 || savant.lssj)
				exp+=1
		if(1)
			if(levelup == 1)
				levelup=0
				savant<<"You're getting close to something... Super Saiyan Mastery is now level [level]!"
				expbarrier=3000
				savant.ssjdrain=0.020
				savant.restssjdrain = 0.004
				savant.unrestssjdrain=0.010
			if(savant.ssj==1 || savant.lssj)
				exp+=1
		if(2)
			if(levelup == 1)
				levelup=0
				savant<<"Your body is getting used to Super Saiyan. Super Saiyan Mastery is now level [level]!"
				expbarrier=9000
				savant.ssjdrain=0.015
				savant.ssjmult=4 //SSJ1 mastery raises the multiplier (2 -> 4 -> 6)
				savant.restssjdrain = 0.002
				savant.unrestssjdrain=0.008
				if(!savant.hasussj) //USSJ agora libera NATURALMENTE na maestria 2/3 (era a skill comprada 'ussj')
					savant.hasussj=1
					savant.ultrassjenabled=1
					savant.assignverb(/mob/keyable/verb/Toggle_USSJ)
					savant<<"You feel like you are able to go somewhat beyond the regular Super Saiyan."
					savant<<"USSJ is enabled! Power up past 750 million as a Super Saiyan to access it."
			if(savant.ssj==1 || savant.lssj)
				exp+=1
		if(3)
			if(levelup == 1)
				levelup=0
				savant<<"Super Saiyan is almost effortless now. Super Saiyan Mastery is now level [level]!"
				if(!savant.ismssj) //maestria completa de Super Saiyajin agora e NATURAL (era a skill comprada 'mssj')
					savant.ismssj=1
					savant<<"You've mastered Super Saiyan completely!"
					savant.ssjmult=6
					savant.ssjdrain=0
					savant.ssjmod=2
					savant.unrestssjmult += 5
					savant.lssjmult+=10
					savant.unrestssjdrain=0
					savant.restssjdrain=0
					savant.restssjmult+=5
					savant.ssj2mod=10
					if(savant.hasssj2&&savant.ssj2drain<300)
						savant<<"In addition, your Super Saiyan 2 form will improve faster."
					savant.testunlocks()
				else
					savant.ssjdrain=0.005
					savant.ssjmult=6 //SSJ1 fully mastered: x6
					savant.restssjdrain = 0.001
					savant.unrestssjdrain=0.005

/datum/skill/forms/ssj/login(var/mob/logger)
	..()
	if(logger.hasussj)
		logger.assignverb(/mob/keyable/verb/Toggle_USSJ)
/datum/skill/forms/ssj/DirectSSJ
	skilltype = "Super Saiyan Form"
	name = "Direct Transformation"
	desc = "After mastering Super Saiyan, you can directly transform into any available form instantly, without having to go through every form."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	prereqs = list(new/datum/skill/forms/ssj) //pre-req agora e a Maestria SSJ natural (mssj nao precisa mais ser comprada)
	tier = 1
	enabled=0
	after_learn()
		savant << "You're able to go instantly to whatever form you desire."
		assignverb(/mob/keyable/verb/DirectSSJ)
		savant << "Remember: 1 is regular SSJ, 1.5 is USSJ, 2 is SSJ2, 3 is SSJ3, and 4 is SSJ4."
	before_forget()
		savant << "How the fuck did you forget this? (Direct SSJ unlearned, either a bug or a unupdated description.)"
		unassignverb(/mob/keyable/verb/DirectSSJ)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/DirectSSJ)
	effector()
		return

mob/keyable
	verb
		DirectSSJ()
			set category = "Skills"
			set name = "Super Saiyan"
			var/SSJchoice
			if(Class!="Legendary")
				SSJchoice = round(input(usr,"Input a number from 1-4. Only accepts whole numbers or 1.5","") as num,0.5)
				if(usr.ssj==SSJchoice) return
			if(Class=="Legendary")
				SSJchoice = round(input(usr,"Input a number from 1-4. You're a Legendary, so 1 is Restrained, 2 is SSJ, and 3 is LSSJ.","") as num)
				if(usr.lssj==SSJchoice) return
			if(!usr.Apeshit&&Class!="Legendary"&&usr.hasssj)
				if(isBuffed(/obj/buff/SuperSaiyan) && SSJchoice < ssj)
					switch(SSJchoice)
						if(1) if(usr.hasssj&&usr.expressedBP>=usr.ssjat)
							ssj = 1
						if(1.5) if((usr.expressedBP*usr.ssjmult)>=usr.ultrassjat)
							ssj = 1.5
						if(2)
							if((usr.expressedBP*usr.ssjmult)>=usr.ssj2at&&!usr.ultrassjenabled)
								if(usr.hasssj2)
									usr.ssj = 2
						if(3)
							if((usr.expressedBP*usr.ssj2mult)>=usr.ssj3at)
								if(usr.ssj3able)
									ssj = 3
						if(4)
							if(!usr.goingssj4)
								usr.goingssj4=1
								if(usr.hasssj4&&!usr.Apeshit&&BP>=rawssj4at) usr.SSj4()
								spawn(10) usr.goingssj4=0
				else switch(SSJchoice)
					if(1)
						if(usr.hasssj&&usr.expressedBP>=usr.ssjat)
							usr.SSj()
					if(1.5)
						if((usr.expressedBP*usr.ssjmult)>=usr.ultrassjat)
							if(usr.hasussj&&usr.ultrassjenabled)
								usr.startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
								usr.Ultra_SSj()
					if(2)
						if((usr.expressedBP*usr.ssjmult)>=usr.ssj2at&&!usr.ultrassjenabled)
							if(usr.hasssj2)
								usr.startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
								usr.SSj2()
					if(3)
						if((usr.expressedBP*usr.ssj2mult)>=usr.ssj3at)
							if(usr.ssj3able)
								usr.startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
								usr.SSj3()
					if(4)
						if(!usr.goingssj4)
							usr.goingssj4=1
							if(usr.hasssj4&&!usr.Apeshit&&BP>=rawssj4at) usr.SSj4()
							spawn(10) usr.goingssj4=0
			else if(usr.Apeshit) usr<<"You're currently Oozaru, and golden/brown Oozaru is automatic. No need for this verb until you're normal again."
			else if(usr.hasssj)
				usr.Revert()
				switch(SSJchoice)
					if(1)
						if(usr.hasssj&&usr.expressedBP>=usr.restssjat)
							usr.Restrained_SSj()
					if(2)
						if(usr.BP>=usr.unrestssjat)
							usr.startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
							usr.Unrestrained_SSj()
					if(3)
						if(usr.BP>=usr.lssjat)
							usr.startbuff(/obj/buff/LSSJ,'SSJIcon.dmi')
							usr.LSSj()
					if(4)
						if(!usr.goingssj4)
							usr.goingssj4=1
							if(usr.hasssj4&&!usr.Apeshit&&BP>=rawssj4at) usr.SSj4()
							spawn(10) usr.goingssj4=0
		Toggle_USSJ()
			set category = "Other"
			var/isenabledussj
			if(usr.ultrassjenabled)
				isenabledussj="is disabled"
				usr.ultrassjenabled=0
			else if(usr.BP>=usr.ssj2at*0.5/usr.ssjmult)
				isenabledussj="is enabled"
				usr.ultrassjenabled=1
			else
				usr<<"You do not meet the requirements for USSJ, you need [usr.ssj2at*0.5/usr.ssjmult] BP"
				isenabledussj="is disabled"
				usr.ultrassjenabled=0
			usr<<"USSJ [isenabledussj]"
mob/var/activatedUSSJ

/datum/skill/forms/ussj
	skilltype = "Super Saiyan Form"
	name = "Ultra Super Saiyan"
	desc = "The user pushes Ki into every muscle within the user's body, increasing power - and drain, of the Super Saiyan form. Has lower speed."
	skillcost = 1
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/forms/ssj)
	maxlevel = 1
	tier = 2
	enabled=0
	expbarrier=15000

/datum/skill/forms/ussj/effector()
	..()
	switch(level)
		if(0)
			if(savant.ssj==1.5)
				exp+=1
			if(exp>=2500&&exp<=5000)
				savant.ultrassjdrain = 0.043
			else if(exp<=10000)
				savant.ultrassjdrain = 0.038
			else
				savant.ultrassjdrain = 0.033
		if(1)
			if(levelup)
				usr<<"You just mastered USSJ!"
				levelup = 0
				savant.ultrassjdrain = 0.027

/datum/skill/forms/mssj
	skilltype = "Super Saiyan Form"
	name = "Mastered Super Saiyan"
	desc = "The user achieves a bit more than the strength of Ultra Super Saiyan, except without any drain or speed reductions."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	//prereqs = list(new/datum/skill/forms/ssj)
	maxlevel = 1
	tier = 3
	enabled=0

/datum/skill/forms/ussj/after_learn()
	savant << "You feel like you are able to go somewhat beyond the regular Super Saiyan."
	savant.ultrassjenabled=1
	savant << "USSJ is enabled"
	savant.hasussj=1
	assignverb(/mob/keyable/verb/Toggle_USSJ)
	savant << "In order to access Ultra Super Saiyan, power up past 750 million as a Super Saiyan, and have more than [savant.ssj2at*0.5/savant.ssjmult] BP."

/datum/skill/forms/ussj/before_forget()
	savant << "Super Saiyan seems fine enough, no need for Ultra Super Saiyan anymore, right?"
	savant.ultrassjenabled=0
	savant.hasussj=0
	unassignverb(/mob/keyable/verb/Toggle_USSJ)

/datum/skill/forms/ussj/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Toggle_USSJ)

/datum/skill/forms/mssj/after_learn()
	savant << "You've mastered Super Saiyan completely!"
	savant.ismssj=1
	savant.ssjmult=6
	savant.ssjdrain=0
	savant.ssjmod=2
	savant.unrestssjmult += 5
	savant.lssjmult+=10
	savant.unrestssjdrain=0
	savant.restssjdrain=0
	savant.restssjmult+=5
	savant.ssj2mod=10
	if(savant.hasssj2&&savant.ssj2drain<300)
		savant << "In addition, your Super Saiyan 2 form will improve faster."

/datum/skill/forms/mssj2
	skilltype = "Super Saiyan Form"
	name = "Mastered Super Saiyan 2"
	desc = "The user masters Super Saiyan 2, almost eliminating the drain, and increasing the power a bit."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	maxlevel = 3
	tier = 4
	enabled=0
	level = 0
	exp = 0
	expbarrier = 10000

/datum/skill/forms/mssj2/effector()
	..()
	switch(level)
		if(0)
			if(levelup == 1)
				levelup = 0
			if(savant.kiratio>1&&(savant.ssj==2||savant.ssj==1))
				exp+=1*savant.kiratio
		if(1)
			if(levelup == 1)
				levelup = 0
				savant<<"You have become aware of another evolution."
				savant<<"You've almost mastered Super Saiyan 2!"
				savant.ssj2mult=6
				savant.ssj2drain=0.30
			expbarrier=100000
			if(savant.kiratio>1&&(savant.ssj==2||savant.ssj==1))
				exp+=1+(savant.kiratio/2)
		if(2)
			if(levelup == 1)
				levelup = 0
				savant<<"It's within your grasp! The next evolution of Super Saiyan!"
				savant<<"You've mastered Super Saiyan 2! It's drain is that of a newly born Super Saiyan."
				savant.ssj2mult=8
				savant.ssj2drain=0.25
			if(savant.kiratio>1&&(savant.ssj==2||savant.ssj==1))
				exp+=1*savant.kiratio
		if(3)
			if(levelup == 1)
				levelup = 0
				savant<<"You've done it! You've unlocked something beyond an Ascended Super Saiyan."
				savant.ssj2mult=10 //SSJ2 fully mastered: x10

/datum/skill/forms/ssj3
	skilltype = "Super Saiyan Form"
	name = "Super Saiyan Three"
	desc = "The user pushes the Super Saiyan form far beyond the state of Super Saiyan 2 to achieve greatness."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	maxlevel = 3
	tier = 5
	enabled=0
	expbarrier=1000

/datum/skill/forms/ssj3/after_learn()
	savant << "AND THIS... IS TO GO EVEN FURTHER BEYOND!"
	savant.ssj3able=1
	savant << "In order to access Super Saiyan 3, power up past 400 million."

/datum/skill/forms/ssj3/effector()
	..()
	switch(level)
		if(0)
			if(savant.kiratio>1&&savant.ssj==3)
				exp+=1
		if(1)
			if(levelup == 1)
				levelup = 0
				savant<<"You have become aware of another evolution."
			expbarrier=100000
			if(savant.kiratio>1&&savant.ssj==3)
				exp+=1.5*savant.kiratio
		if(2)
			if(levelup == 1)
				levelup = 0
				savant<<"It's within your grasp! The next evolution of Super Saiyan 3!"
			expbarrier=200000
			if(savant.kiratio>1&&savant.ssj==3)
				exp+=1*savant.kiratio
		if(3)
			if(levelup == 1)
				levelup = 0
				savant<<"You can learn Mastered Super Saiyan 3 now"

/datum/skill/forms/ssj3m
	skilltype = "Super Saiyan Form"
	name = "Mastered Super Saiyan 3"
	desc = "Almost eliminates the drain of Super Saiyan 3, and increases it's power a little bit."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	maxlevel = 1
	tier = 6
	enabled=0

/datum/skill/forms/ssj3m/after_learn()
	savant << "You just mastered Super Saiyan 3!"
	savant.ssj3mult=20
	savant.ssj3drain=0.50

/datum/skill/forms/ssj4fplb
	skilltype = "Super Saiyan Form"
	name = "Super Saiyan 4 Limit Break"
	desc = "Break past the limits of Super Saiyan 4. Once learned, transform again while in SSJ4 to ascend to its Full Power Limit Breaker form (Primal Saiyan only)."
	skillcost = 1
	can_forget = FALSE
	common_sense = FALSE
	maxlevel = 1
	tier = 3
	enabled=0
	after_learn()
		savant << "You feel you can shatter the very limits of Super Saiyan 4!"
		savant.hasFPLB=1
	before_forget()
		savant.hasFPLB=0
	effector()
		return