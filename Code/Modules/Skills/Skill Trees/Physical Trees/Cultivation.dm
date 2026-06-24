/datum/skill/tree/Cultivation
	name = "Internal Cultivation"
	desc = "Body is my bulwark, Ki is my blade."
	maxtier = 3
	tier=2
	allowedtier = 2
	enabled=0
	constituentskills = list(new/datum/skill/Cultivation/Cultivator,new/datum/skill/Cultivation/Blade_Runner,new/datum/skill/Cultivation/Ki_Knight,new/datum/skill/Sword_Strike,
	new/datum/skill/Cultivation/Ki_Shield,new/datum/skill/Shield_Bash,new/datum/skill/Cultivation/Sharpened_Ki)

	growbranches()
		. = ..()
		if(invested >= 2)
			allowedtier = 3


/datum/skill/Cultivation/Cultivator
	skilltype = "Physical"
	name = "Cultivator"
	desc = "The Ki inside you is normally sealed, but today you'll let it out, just this once. (Disclaimer: by 'once', you mean all the time.) KiOff+, P.Off+"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	after_learn()
		savant<<"Ki flows around you, making it slightly easier to shape and mold. Could you use this as a weapon?"
		//eventually add Ki armor here.
		savant.kioffBuff+=0.2
		savant.physoffBuff+=0.2

	before_forget()
		savant<<"The ki that flowed around you is now waning, its power decreasing."
		savant.kioffBuff-=0.2
		savant.physoffBuff-=0.2

/datum/skill/Cultivation/Blade_Runner
	skilltype = "Ki"
	name = "Blade Runner"
	desc = "You're able to project a small blade from your hands that increases your attack. It will initially drain some Ki."
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/Cultivation/Cultivator)
	tier = 2
	enabled = 0
	skillcost = 2
	expbarrier = 10000
	var/superdrain = 1
	after_learn()
		savant<<"The Ki flowing around you takes shape in the form of a small triangle, coming from your hand."
		//eventually add Ki armor here.
		savant.kioffBuff+=0.1
		savant.physoffBuff+=0.1
		assignverb(/mob/keyable/verb/Ki_Blade)

	before_forget()
		savant<<"You can no longer create a blade with your Ki."
		savant.kioffBuff-=0.1
		savant.physoffBuff-=0.1
		if(savant.KiBladeOn)
			savant.stopbuff(/obj/buff/Ki_Blade)
		unassignverb(/mob/keyable/verb/Ki_Blade)
	effector()
		..()
		if(savant.KiBladeOn)
			switch(level)
				if(0)
					if(levelup)
						levelup=0
					exp+=1
				if(1)
					if(levelup)
						superdrain = 0.5
						levelup = 0
						savant << "Due to your extensive usage of Ki blades, Ki blade drain has been halved!"
					exp+=1
				if(2)
					if(levelup)
						superdrain = 0
						savant << "Due to your extensive usage of Ki blades, Ki blade drain has been eliminated completely!"
						levelup =0
		if(prob(10)) savant.KiBladeDrain = superdrain
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Ki_Blade)

mob/var/tmp
	KiWeaponOn = 0
	KiBladeOn = 0
	KiBladeDrain = 1

mob/keyable/verb/Ki_Blade()
	set desc = "Form a blade from Ki, draining some Ki in the process."
	if(weaponeq)
		src << "You already have a weapon!"
		return
	if(KiBladeOn)
		stopbuff(/obj/buff/Ki_Blade)
	else
		startbuff(/obj/buff/Ki_Blade)
		if(!KiBladeDrain)
			return
		if(Ki >= (MaxKi/10) * KiBladeDrain / KiMod)
			Ki -= (MaxKi/10) * KiBladeDrain / KiMod

obj/overlay/effects/Ki_Blade
	ID = 401
	name = "Ki Blade"
	icon = 'KiSword.dmi'


/obj/buff/Ki_Blade
	name = "Ki Blade"
	slot=sBUFF
	Buff()
		..()
		view(container) << "[container] creates a Ki blade."
		container.initbuff = max((log(8.3,container.Ekioff*10)),0)
		container.Tphysoff += container.initbuff
		container.Tkioff+=container.initbuff
		container.updateOverlay(/obj/overlay/effects/Ki_Blade)
		container.KiBladeOn = 1
		container.KiWeaponOn = 1
		container.emit_Sound('Open.ogg')
	Loop()
		if(container.KO||container.weaponeq) DeBuff()

		..()
	DeBuff()
		container.Tkioff-=container.initbuff
		container.Tphysoff -= container.initbuff
		container.removeOverlay(/obj/overlay/effects/Ki_Blade)
		container.emit_Sound('Close.ogg')
		container.Ki = 0
		container.KiBladeOn = 0
		container.WeaponUseTmp = 0
		view(container) << "[container]'s Ki Blade dissapates."
		..()

/datum/skill/Cultivation/Sharpened_Ki
	skilltype = "Physical"
	name = "Sharpened Ki"
	desc = "Increase your Ki's sharpness, resulting in higher damage output. KiOff+"
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/Cultivation/Cultivator)
	enabled=0
	tier = 2
	after_learn()
		savant<<"The ki that resides within you sharpens."
		//eventually add Ki armor here.
		savant.kioffBuff+=0.2

	before_forget()
		savant<<"The ki that resides inside of you begins to dull."
		savant.kioffBuff-=0.2

/datum/skill/Cultivation/Ki_Knight
	skilltype = "Ki"
	name = "Ki Knight"
	desc = "Using the same idea as before, project a larger blade that does more damage, but drains constantly. You can also change the icon of the blade in Settings!"
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/Cultivation/Blade_Runner)
	tier = 2
	enabled = 0
	skillcost = 1
	expbarrier = 10000
	var/superdrain = 1
	after_learn()
		savant<<"The Ki flowing around you takes shape in the form of a large longsword for you to grip."
		savant.physoffBuff+=0.1
		assignverb(/mob/keyable/verb/Ki_Sword)

	before_forget()
		savant<<"You can no longer create a longsword with your Ki."
		savant.physoffBuff-=0.1
		if(savant.KiSwordOn)
			savant.stopbuff(/obj/buff/Ki_Sword)
		unassignverb(/mob/keyable/verb/Ki_Sword)
	effector()
		..()
		if(savant.KiSwordOn)
			switch(level)
				if(0)
					if(levelup)
						levelup=0
					exp+=1
				if(1)
					if(levelup)
						superdrain = 0.5
						levelup = 0
						savant << "Due to your extensive usage of Ki blades, Ki blade drain has been halved!"
					exp+=1
				if(2)
					if(levelup)
						superdrain = 0
						savant << "Due to your extensive usage of Ki blades, Ki blade drain has been eliminated completely!"
						levelup =0
		if(prob(10)) savant.KiSwordDrain = superdrain
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Ki_Sword)

mob/var
	icon/KiSwordIcon = null
	tmp
		KiSwordOn = 0
		KiSwordDrain = 1

mob/keyable/verb/Ki_Sword()
	set desc = "Form a blade from Ki, draining some Ki in the process."
	if(weaponeq)
		src << "You already have a weapon!"
		return
	if(KiSwordOn)
		stopbuff(/obj/buff/Ki_Sword)
	else
		startbuff(/obj/buff/Ki_Sword)
		if(!KiSwordDrain)
			return
		if(Ki >= (MaxKi/9) * KiSwordDrain / KiMod)
			Ki -= (MaxKi/9) * KiSwordDrain / KiMod

obj/overlay/effects/Ki_Sword
	ID = 407
	name = "Ki Sword"
	icon = 'KiSword.dmi'
	EffectStart()
		..()
		if(container.KiSwordIcon)
			icon = container.KiSwordIcon

/obj/buff/Ki_Sword
	name = "Ki Sword"
	slot=sBUFF
	Buff()
		..()
		view(container) << "[container] creates a Ki Sword."
		container.initbuff = max((log(8,container.Ekioff*10)),0)
		container.Tphysoff += container.initbuff
		container.Tkioff+=container.initbuff
		container.updateOverlay(/obj/overlay/effects/Ki_Sword)
		container.KiSwordOn = 1
		container.KiWeaponOn = 1
		container.emit_Sound('Open.ogg')
	Loop()
		if(container.KO||container.weaponeq) DeBuff()

		..()
	DeBuff()
		container.Tkioff-=container.initbuff
		container.Tphysoff -= container.initbuff
		container.removeOverlay(/obj/overlay/effects/Ki_Sword)
		container.emit_Sound('Close.ogg')
		container.Ki = 0
		container.KiSwordOn = 0
		container.WeaponUseTmp = 0
		view(container) << "[container]'s Ki Blade dissapates."
		..()

/datum/skill/Sword_Strike
	skilltype = "Ki"
	name = "Sword Strike"
	desc = "Deal a sword strike that targets all mobs in front of you at the same time."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	skillcost=0
	maxlevel = 1
	prereqs = list(new/datum/skill/Cultivation/Ki_Knight)
	tier = 2
	enabled = 1
	var/tmp/expbuffer = 0
	after_learn()
		savant<<"Your internal skills have been cultivated further! You've gained a new ability!"
		assignverb(/mob/keyable/verb/Sword_Strike)
	before_forget()
		savant<<"Your cultivation vanishes, alongside a ability to release it."
		unassignverb(/mob/keyable/verb/Sword_Strike)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Sword_Strike)

mob/keyable/verb/Sword_Strike()
	set category = "Skills"
	var/kireq=usr.Ephysoff*4 + 10 * KiSwordDrain + 10 * KiBladeDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		for(var/mob/M in view(1))
			if(get_dist(M.loc,usr.loc)<= 3)
				if(doAttack(M,5,FALSE,FALSE,"twirls giving a damaging slash to"))
					usr.Ki-=kireq

/datum/skill/Cultivation/Ki_Shield
	skilltype = "Ki"
	name = "Ki Shield"
	desc = "You're able to project a shield from your hands that increases your defense and attack a bit. It will initially drain some Ki."
	can_forget = TRUE
	common_sense = FALSE
	prereqs = list(new/datum/skill/Cultivation/Blade_Runner)
	tier = 2
	enabled = 0
	skillcost = 2
	expbarrier = 10000
	var/superdrain = 1
	after_learn()
		savant<<"The Ki flowing around you takes shape in the form of a small disc, coming from your hand."
		//eventually add Ki armor here.
		savant.kioffBuff+=0.1
		assignverb(/mob/keyable/verb/Ki_Shield)

	before_forget()
		savant<<"You can no longer create a shield with your Ki."
		savant.kioffBuff-=0.1
		savant.KiShieldOn = 0
		unassignverb(/mob/keyable/verb/Ki_Shield)
	effector()
		..()
		if(savant.KiShieldOn)
			switch(level)
				if(0)
					if(levelup)
						levelup=0
					exp+=1
				if(1)
					if(levelup)
						superdrain = 0.5
						levelup = 0
						savant << "Due to your extensive usage of Ki shields, Ki shield drain has been halved!"
					exp+=1
				if(2)
					if(levelup)
						superdrain = 0
						savant << "Due to your extensive usage of Ki shield, Ki shield drain has been eliminated completely!"
						levelup =0
		if(prob(10)) savant.KiBladeDrain = superdrain
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Ki_Shield)

mob/var/tmp
	KiShieldOn = 0
	KiShieldDrain = 1

mob/keyable/verb/Ki_Shield()
	set category = "Skills"
	set desc = "Form a shield from Ki, draining some Ki in the process."
	if(KiShieldOn)
		KiShieldOn = 0
	else
		KiShieldOn = 1
		updateOverlay(/obj/overlay/effects/Ki_Shield)
		if(!KiShieldDrain)
			if(Ki >= (MaxKi/10) * KiShieldDrain / KiMod)
				Ki -= (MaxKi/10) * KiShieldDrain / KiMod
			else Ki = 0
		view(usr) << "[usr] creates a Ki Shield."
		var/initbuff = max((log(8.3,container.Ekioff*10)),0)
		Tphysdef += initbuff
		Tkidef += initbuff
		container.emit_Sound('Open.ogg')
		while(KiShieldOn && !usr.med)
			sleep(1)
			if(usr.KO)
				KiShieldOn = 0
				break
		Tphysdef -= initbuff
		Tkidef -= initbuff
		removeOverlay(/obj/overlay/effects/Ki_Shield)
		container.emit_Sound('Close.ogg')

obj/overlay/effects/Ki_Shield
	ID = 403
	name = "Ki Shield"
	icon = 'KiShield.dmi'
	EffectLoop()
		..()
		if(!container.KiShieldOn)
			EffectEnd()

/datum/skill/Shield_Bash
	skilltype = "Ki"
	name = "Shield Bash"
	desc = "Deal a damaging stun to your target."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	skillcost=0
	maxlevel = 1
	prereqs = list(new/datum/skill/Cultivation/Ki_Shield)
	tier = 3
	enabled = 1
	var/tmp/expbuffer = 0
	after_learn()
		savant<<"Your internal skills have been cultivated further! You've gained a new ability!"
		assignverb(/mob/keyable/verb/Shield_Bash)
	before_forget()
		savant<<"Your cultivation vanishes, alongside a ability to release it."
		unassignverb(/mob/keyable/verb/Shield_Bash)
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Shield_Bash)

mob/keyable/verb/Shield_Bash()
	set category = "Skills"
	var/kireq=usr.Ephysoff*4 + 10 * KiSwordDrain + 10 * KiBladeDrain
	if(!usr.med&&usr.KiShieldOn&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.basicCD+=15
		for(var/mob/M in view(1))
			if(get_dist(M.loc,usr.loc)<= 3)
				if(doAttack(M,5,FALSE,FALSE,"uses the shield to bash"))
					usr.Ki-=kireq