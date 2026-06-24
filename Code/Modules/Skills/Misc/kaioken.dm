
mob/var
	KaiokenMastery=1
	tmp
		charging=0
		firable=0
		kaioamount=1

//TIERED SKILLS//
//see: Modules/Multi-Stage Moves/skill.dm

/datum/skill/kaioken
	skilltype = "Ki"
	name = "Kaio-ken"
	desc = "The user synchronizes their Ki with their body, forcing it to multiply dramatically, regardless of the consequences."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher = TRUE
	var/tmp/kaiotest

/datum/skill/kaioken/effector()
	..()
	switch(level)
		if(0)
			if(levelup == 1)
				levelup = 0
			if(savant.KaiokenMastery>3) exp += 1
			kaiotest = rand(1,33)
			if(kaiotest==33&&savant.KaiokenMastery<=3)
				savant << "Your body feels like it's tearing itself apart from the inside..."
				savant.SpreadDamage(35/(2*savant.KaiokenMastery))
				savant.KaiokenMastery += 0.5
		if(1)
			if(levelup == 1)
				savant << "You feel as if a power is roiling just beneath your skin."
				assignverb(/verb/Kaioken)
				levelup = 0
			if(savant.KaioPcnt != 1)
				if(savant.KaiokenMastery>=10) exp+=1
		if(2)
			if(levelup == 1)
				levelup = 0
				savant << "Your Kaioken power feels more accessible."
				assignverb(/verb/Kaioken_Settings)
			if(savant.KaioPcnt != 1)
				exp+=1

datum/skill/kaioken/login(var/mob/logger)
	..()
	if(level >= 1)
		assignverb(/verb/Kaioken)
	if(level >= 2)
		assignverb(/verb/Kaioken_Settings)
		if(logger.Kaioken1Set)
			assignverb(/verb/Kaioken_1)
		if(logger.Kaioken2Set)
			assignverb(/verb/Kaioken_2)
		if(logger.Kaioken3Set)
			assignverb(/verb/Kaioken_3)

/datum/skill/kaioken/before_forget()
	if(level>0)
		if(savant.KaioPcnt != 1) savant.KaiokenRevert()
		unassignverb(/verb/Kaioken)
		savant << "You can't seem to remember how to use Kaio-ken."
		savant.KaiokenMastery = 1
	if(level>1)
		unassignverb(/verb/Kaioken_Settings)
		unassignverb(/verb/Kaioken_1)
		unassignverb(/verb/Kaioken_2)
		unassignverb(/verb/Kaioken_3)

/datum/skill/kaioken/after_learn()
	switch(level)
		if(0) savant << "You feel a bit crimson."
		if(1)
			assignverb(/verb/Kaioken)
			savant.KaiokenMastery+=3
		if(2)
			assignverb(/verb/Kaioken)
			assignverb(/verb/Kaioken_Settings)

verb/Kaioken()
	set category="Skills"
	if(usr.KaioPcnt != 1) usr.KaiokenRevert()
	else if(usr.KaioPcnt == 1&&!usr.powerup&&!usr.KO)
		usr.kaioamount=input("Kaioken multiple. (You have Kaioken x[usr.KaiokenMastery] mastered)") as num
		if(usr.kaioamount > 100)
			usr.kaioamount = 100
		usr.SetKaioken()

verb/Kaioken_1()
	set category="Skills"
	if(usr.KaioPcnt != 1) usr.KaiokenRevert()
	else if(usr.KaioPcnt == 1&&!usr.powerup&&!usr.KO)
		usr.kaioamount = usr.Kaioken1Set
		usr.SetKaioken()

verb/Kaioken_2()
	set category="Skills"
	if(usr.KaioPcnt != 1) usr.KaiokenRevert()
	else if(usr.KaioPcnt == 1&&!usr.powerup&&!usr.KO)
		usr.kaioamount = usr.Kaioken2Set
		usr.SetKaioken()

verb/Kaioken_3()
	set category="Skills"
	if(usr.KaioPcnt != 1) usr.KaiokenRevert()
	else if(usr.KaioPcnt == 1&&!usr.powerup&&!usr.KO)
		usr.kaioamount = usr.Kaioken3Set
		usr.SetKaioken()


mob/proc/SetKaioken()
	if(src.KaioPcnt == 1&&!src.powerup&&!src.KO)
		KaioPcnt=1
		if(!src.kaioamount)
			src.KaiokenRevert()
			return
		if(src.powerMod>1)
			src << "You must revert any power up buffs before using Kaioken."
			return
		if(src.kaioamount<2) src.kaioamount=2 //Kaioken is natively a x2 boost. Further multipliers don't affect this. x20 for instance is just a x20 multiplier.
		src.kaioamount=round(src.kaioamount)
		if(src.kaioamount>100) src.kaioamount = 100
		if(isBuffed(/obj/buff/Kaioken))
			view(src)<<"A bright red aura bursts all around [src]."
			if(src.kaioamount<3)
				view(src)<<"<font size=[src.TextSize]><[src.SayColor]>[src]: KAIOKEN!!!"
			else
				view(src)<<"<font size=[src.TextSize]><[src.SayColor]>[src]: KAIOKEN TIMES [src.kaioamount]!!!"
			emit_Sound('kaioken.wav')
		else startbuff(/obj/buff/Kaioken)
			//with the re-multiplying of powers, kaioken has been buffed to a real multiplier.
			//src.kaioamount=(((src.kaioamount**1/2)/4.536)+1) //equation made in geogebra, at 20x it'll give a 2x boost in power.

/obj/buff/Kaioken
	name = "Kaioken"
	icon='Electric_Blue.dmi'
	slot=sAURA
	Buff()
		..()
		container.updateOverlay(/obj/overlay/auras/kaioaura,container.kaioaura)
		view(container)<<"A bright red aura bursts all around [container]."
		if(container.kaioamount<3)
			view(container)<<"<font size=[container.TextSize]><[container.SayColor]>[container]: KAIOKEN!!!"
		else
			view(container)<<"<font size=[container.TextSize]><[container.SayColor]>[container]: KAIOKEN TIMES [container.kaioamount]!!!"
		container.emit_Sound('kaioken.wav')
		container.poweruprunning=1
		container.KaioPcnt=container.kaioamount //Kaiopercent
	Loop()
		if(container.KaioPcnt != 1)
			if(container.KO) container.KaiokenRevert()
			else if(container.Ki>(100/container.KiMod)&&!container.KO)
				container.Ki-=0.05*(container.kaioamount/container.KaiokenMastery)*container.BaseDrain
				container.SpreadDamage(max((container.kaioamount/container.KaiokenMastery*3),1)*0.1*(container.ssj+1)*max(log(container.kaioamount),1)) //last part makes drain a bit larger for fags with SSJ esque shit
				container.stamina-=(container.kaioamount/container.KaiokenMastery)*0.03*(container.ssj+1)*(container.staminadrainMod)
				if(container.KaiokenMastery<20) container.KaiokenMastery+=0.001*container.kaioamount //kaioken is long as fuck to master before x20
				else
					container.KaiokenMastery+=0.00001*container.kaioamount //kaioken is long as fuck to master after x20.
					container.KaiokenMastery = min(container.KaiokenMastery,50) //max mastery is 50x, so you can use x100 without dying maybe
			else
				src<<"You are too tired to continue using Kaioken."
				if(container.kaioamount>container.KaiokenMastery*2)
					view(src)<<"[src] suddenly explodes!"
					if(!container.dead) spawn container.Body_Parts()
					else spawn container.Death()
				container.KaiokenRevert()
			container.KaioPcnt=container.kaioamount //Kaiopercent
	DeBuff()
		container.KaioPcnt=1
		container.kaioamount=1
		container<<"You stop using Kaioken."
		..()

mob/var
	Kaioken1Set
	Kaioken2Set
	Kaioken3Set
	kaioaura = 'Aura, Kaioken, Big.dmi'

obj/overlay/auras/kaioaura
	name = "Kaioken Aura"
	icon = 'Aura, Kaioken, Big.dmi'
	presetAura=TRUE
	ScaleMe=0
	EffectLoop()
		set background = 1
		set waitfor = 0
		if(lastpowermod!=container.KaioPcnt)
			if(limiter<=0)
				if(prob(25))
					limiter = 10
					lastpowermod = container.KaioPcnt
					ScaleAura()
			else limiter--
		..()
mob/proc/KaiokenRevert() if(src)
	if(src.KaioPcnt > 1)
		if(!KO)
			src<<"You stop using Kaioken."
		else
			src<<"You are too tired to continue using Kaioken."
			if(kaioamount>KaiokenMastery*1.6)
				view(src)<<"[src] suddenly explodes!"
				if(!dead) spawn Body_Parts()
				else spawn Death()
		KaioPcnt=1
		src.removeOverlay(/obj/overlay/auras/kaioaura)
		poweruprunning=0
		kaioamount=1
		stopbuff(/obj/buff/Kaioken)
		emit_Sound('descend.wav')

verb/Kaioken_Settings()
	set category="Other"
	choiceset
	switch(input("What do you want to change?") in list("Add Kaioken shortcut.","Remove Kaioken shortcut.","Modify Kaioken shortcut","Change Kaioken aura.","Cancel"))
		if("Add Kaioken shortcut.")
			var/choice2=input("What setting will this Kaioken be at?") as num
			if(choice2>=usr.KaiokenMastery)
				choice2 = usr.KaiokenMastery
			else if(choice2<=1)
				usr <<"Invalid number."
				goto choiceset
			usr << "Kaioken shortcut set to [choice2]"
			switch(input("Add Kaioken shortcut to skills?") in list("Yes","No"))
				if("Yes")
					if(!usr.Kaioken1Set)
						usr.Kaioken1Set = choice2
						usr.verbs += /verb/Kaioken_1
					else if(!usr.Kaioken2Set)
						usr.Kaioken2Set = choice2
						usr.verbs += /verb/Kaioken_2
					else if(!usr.Kaioken3Set)
						usr.Kaioken3Set = choice2
						usr.verbs += /verb/Kaioken_3
					else
						usr<<"You already have 3 set Kaioken verbs."
			goto choiceset
		if("Remove Kaioken shortcut.")
			switch(input("Which Kaioken shortcut?") in list("Kaioken 1","Kaioken 2","Kaioken 3","Cancel"))
				if("Kaioken 1")
					if(usr.Kaioken1Set)
						usr.Kaioken1Set = null
						usr.verbs -= /verb/Kaioken_1
				if("Kaioken 2")
					if(usr.Kaioken2Set)
						usr.Kaioken2Set = null
						usr.verbs -= /verb/Kaioken_2
				if("Kaioken 3")
					if(usr.Kaioken3Set)
						usr.Kaioken3Set = null
						usr.verbs -= /verb/Kaioken_3
			goto choiceset
		if("Modify Kaioken shortcut")
			var/choice1=input("Which Kaioken shortcut?") in list("Kaioken 1","Kaioken 2","Kaioken 3","Cancel")
			var/choice2=input("What setting will this Kaioken be at?") as num
			switch(choice1)
				if("Kaioken 1")
					if(usr.Kaioken1Set)
						usr.Kaioken1Set = choice2
				if("Kaioken 2")
					if(usr.Kaioken2Set)
						usr.Kaioken2Set = choice2
				if("Kaioken 3")
					if(usr.Kaioken3Set)
						usr.Kaioken3Set = choice2
			goto choiceset
		if("Change Kaioken aura.")
			switch(input("Restore to default or pick a custom one?") in list("Default.","Custom.","Cancel"))
				if("Default.")
					usr.kaioaura = 'Aura, Kaioken, Big.dmi'
				if("Custom.")
					usr.kaioaura = input("Select the image.") as icon
			goto choiceset
		if("Cancel")
			return