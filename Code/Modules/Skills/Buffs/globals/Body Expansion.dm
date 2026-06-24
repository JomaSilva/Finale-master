mob/var
	DRenabled=1 //1 if enabled, 0 if not.
	murderToggle=0 //0 for KO or 1 for Kill
	PayTaxes=1
	ASE=1
	expandlevelussj=0
mob/var
	ExpandPower=0
	expandlevel=0
	depandicon
	var/list/BEoverlays=new/list

obj/buff/Expand
	name = "Expand Body"
	slot=sBUFF
	var/lastlevel=69
	var/lastpower=0
	var/firstphysdefbuff = 1
	var/firstphysoffbuff=1
	var/firstspeedbuff=1
	Buff()
		..()
		container.depandicon=container.icon
		if(container.expandlevel==1)container<<"You expand your muscles to the 1st degree!"
		else if(container.expandlevel==2)container<<"You expand your muscles to the 2nd degree!"
		else if(container.expandlevel==3)container<<"You expand your muscles to the 3rd degree!"
		else container<<"You expand your muscles to the [container.expandlevel]th degree!"
	Loop()
		var/doescost=rand(1,3)
		if(doescost==3)container.Ki-=(container.expandlevel/container.Etechnique)
		if(container.Ki<=10)
			container.stopbuff(/obj/buff/Expand)
			return
		if(!container.HellStar&&container.expandlevel==4)
			container<<"Without the Hellstar you lose concentration, slipping back to the 3rd Degree."
			container.expandlevel=3
		if(container.expandlevel!=lastlevel)
			container.expandBuff = 1
			container.Tphysoff -= firstphysoffbuff
			container.Tphysdef -= firstphysdefbuff
			container.Tspeed -= firstspeedbuff
			switch(container.expandlevel)
				if(0)
					firstphysoffbuff=0
					firstphysdefbuff=0
					firstspeedbuff=0
					DeBuff()
					container.expandBuff = 1
					lastpower=0
					return
				if(1)
					container.expandBuff = 1
					lastpower=1.12
					animate(container,time=5,transform = matrix() * 1.15)
					if(container.icon=='White Male.dmi'&&!container.doexpandicon1) container.icon='White Male Muscular.dmi'
					if(container.icon=='Tan Male.dmi'&&!container.doexpandicon1) container.icon='Tan Male Muscular.dmi'
					if(container.doexpandicon1&&container.expandicon) container.icon=container.expandicon
				if(2)
					container.expandBuff = 1
					lastpower=1.25
					animate(container,time=5,transform = matrix() * 1.2)
					if(container.icon=='White Male Muscular.dmi'&&!container.doexpandicon2) container.icon='White Male Muscular 2.dmi'
					if(container.doexpandicon2&&container.expandicon2) container.icon=container.expandicon2
				if(3)
					container.expandBuff = 1
					lastpower=1.50
					animate(container,time=5,transform = matrix() * 1.4)
					if(container.icon=='White Male Muscular 2.dmi'&&!container.doexpandicon3) container.icon='White Male Muscular 3.dmi'
					if(container.doexpandicon3&&container.expandicon3) container.icon = container.expandicon3
				if(4)
					lastpower=1.75
					container.expandBuff = 1.75
					animate(container,time=5,transform = matrix() * 1.6)
					if(container.doexpandicon4&&container.expandicon4) container.icon=container.expandicon4
			firstphysoffbuff = lastpower
			firstphysdefbuff = (1+(lastpower-1)/2)
			firstspeedbuff = 1 - 1/(1+(lastpower-1)/2)
			container.Tphysoff += firstphysoffbuff
			container.Tphysdef += firstphysdefbuff
			container.Tspeed -= firstspeedbuff
		lastlevel=container.expandlevel
		..()
	DeBuff()
		container.icon=container.depandicon
		container.Tphysoff -= firstphysoffbuff
		container.Tphysdef -= firstphysdefbuff
		container.Tspeed += firstspeedbuff
		container.expandBuff = 1
		container.expandlevel = 0
		animate(container,time=5,transform = null)
		lastpower=0
		..()

/datum/skill/expand
	skilltype = "Body Skill"
	name = "Body Expansion"
	desc = "The user learns to use their Ki to expand their muscles."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	maxlevel = 1
	tier = 2
	skillcost = 2
	enabled = 1
/datum/skill/expand/after_learn()
	savant<<"You feel enlightened."
	savant.technique+=0.05
	assignverb(/mob/keyable/verb/Expand_Body)
/datum/skill/expand/before_forget()
	savant<<"You feel lost."
	savant.technique-=0.05
	unassignverb(/mob/keyable/verb/Expand_Body)
/datum/skill/expand/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Expand_Body)

mob/var/tmp/doingexpand=0
mob/keyable/verb/Expand_Body()
	set category="Skills"
	if(KiBladeOn)
		src<<"You can't use this with Ki Blades!"
		return
	var/kireq=(25/Ekiskill)+5
	if(Ki>=kireq&&!doingexpand)
		doingexpand=1
		var/list/choices=new/list
		choices.Add("0th Degree")
		if(Ki>=(((25/Ekiskill)*1)+5)&&expandlevel!=1)choices.Add("1st Degree")
		if(Ki>=(((35/Ekiskill)*2)+5)&&expandlevel!=2)choices.Add("2nd Degree")
		if(Ki>=(((40/Ekiskill)*3)+5)&&expandlevel!=3)choices.Add("3rd Degree")
		if(Ki>=(((35/Ekiskill)*4)+5)&&(src.Race=="Makyo"||Parent_Race=="Makyo")&&HellStar&&expandlevel!=4)choices.Add("4th Degree")
		choices.Add("Cancel")
		var/failedexp
		var/Choice=input("Expand to what degree? (Currently on [expandlevel])") in choices
		if(Choice=="Cancel")
			doingexpand=0
			return
		if(Choice=="0th Degree"&&isBuffed(/obj/buff/Expand))
			expandlevel=0
			stopbuff(/obj/buff/Expand)
			src<<"You relax your body."
			doingexpand=0
			return
		else if(Choice=="0th Degree")
			expandlevel=0
			doingexpand=0
			return
		if(Choice=="1st Degree")
			expandlevel=1
			kireq=(((25/Ekiskill)*1)+5)
		if(Choice=="2nd Degree")
			expandlevel=2
			kireq=(((35/Ekiskill)*2)+5)
		if(Choice=="3rd Degree")
			expandlevel=3
			kireq=(((40/Ekiskill)*3)+5)
		if(Choice=="4th Degree")
			expandlevel=4
			kireq=(((35/Ekiskill)*4)+5)
		if(!isBuffed(/obj/buff/Expand))
			src<<"You begin to expand your body!"
			failedexp = startbuff(/obj/buff/Expand)
		if(!failedexp) //on fail
			expandlevel=0
		Ki-=kireq
		doingexpand=0
	else if(Ki<kireq)src<<"You don't have enough control over your Ki to be able to do that!"

obj/Body_Expand/verb/Expand_Revert()
	set name="Expand Revert"
	set category="Skills"
	if(usr.isBuffed(/obj/buff/Expand)) usr.stopbuff(/obj/buff/Expand)
mob/proc/ExpandRevert()
	if(isBuffed(/obj/buff/Expand)) stopbuff(/obj/buff/Expand)