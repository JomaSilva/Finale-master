var/WolfFormBPMult=4
var/NormalBPMult=1.2

mob
	var
		IsAWereWolf=0
		WolfFormIcon = 'Demon, Wolf.dmi'
	proc
		WolfBite(var/mob/TargetMob,turnChoice)
			if(src.IsAWereWolf==0) return FALSE
			var/phystechcalc
			var/opponentphystechcalc
			if(Ephysoff<1||Etechnique<1)
				phystechcalc = Ephysoff*Etechnique
			if(TargetMob.Ephysoff<1||TargetMob.Etechnique<1)
				opponentphystechcalc = TargetMob.Ephysoff*TargetMob.Etechnique
			var/dmg=DamageCalc((phystechcalc),(opponentphystechcalc),Ephysoff*3)
			TargetMob.SpreadDamage(dmg*BPModulus(expressedBP,TargetMob.expressedBP)*2,0,null)
			if(turnChoice=="Yes")
				if(TargetMob.HP>=10&&prob(40))
					spawn TargetMob.Werewolfify()
			if(TargetMob.HP<5&&murderToggle)
				view(TargetMob) << "[TargetMob] was killed by [usr], the werewolf!"
				spawn TargetMob.Death()
			return TRUE
		Werewolfify()
			if(IsAVampire==0&&IsAWereWolf==0)
				IsAWereWolf = 1
				if(HP<50) SpreadHeal(50)
				else SpreadHeal(100)
				assignverb(/mob/keyable/verb/Bite)
				ParanormalBPMult = NormalBPMult
				contents += new/obj/Werewolf
				return TRUE
			else return FALSE
		UnWerewolf()
			if(IsAWereWolf==1)
				IsAWereWolf = 0
				if(HP>50) SpreadDamage(50)
				else SpreadDamage(99)
				usr.stopbuff(/obj/buff/Werewolf)
				unassignverb(/mob/keyable/verb/Bite)
				ParanormalBPMult = 1
				for(var/obj/Werewolf/W in contents)
					del(W)
				return TRUE
			else return FALSE

obj/items/Clawed_Talisman
	name = "Clawed Talisman"
	icon = 'Item, Clawed Talisman.dmi'
	dropProbability = 0.25
	verb/Eat()
		set category = null
		set src in view(1)
		if(!usr.IsAWereWolf&&usr.CanEat&&!usr.IsAVampire)
			usr.Werewolfify()
			view(usr)<<"[usr] has become a Werewolf!!!"
			usr.startbuff(/obj/buff/Werewolf)
			del(src)
		else
			usr<<"The talisman simply passes through your system. It cannot do anything for you."

obj/Artifacts/Silver_Chalice
	//parent_type = /obj/items //This allows obj/Artifact to access ALL procedures and variables of /item.
	name = "Silver Chalice"
	icon = 'Foods.dmi'
	icon_state="Silver Chalice"
	Unmovable = 1

	verb/Drink()
		set category = null
		set src in oview(1)
		if(usr.IsAWereWolf&&usr.CanEat)
			usr.UnWerewolf()
			view(usr)<<"[usr] has been cured of Lycanthropy!!!"
			usr.stopbuff(/obj/buff/Werewolf)
		else
			usr<<"The liquids simply pass through your system. The chalice cannot do anything for you."
mob/var
	iswolfform=0
	wolfdrain=0.015

obj/buff/Werewolf
	name = "Werewolf"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	Buff()
		lastForm=0
		container.iswolfform=1
		..()
	Loop()
		if(!container.transing)
			if(container.iswolfform==1) if(container.wolfdrain)
				if(container.stamina>=container.maxstamina-container.wolfdrain)
					if(container.MysticPcnt==1) container.Ki-=(container.MaxKi*container.wolfdrain) //ki takes a small hit regardless.
					if(container.Ki<=container.MaxKi*container.wolfdrain)
						container.Revert()
						container<<"You are too tired to sustain your form."
					container.stamina -= trans_drain*max(0.001,container.wolfdrain)/2 //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
		if(lastForm!=container.iswolfform)
			lastForm=container.iswolfform
			sleep container.RemoveHair()
			switch(container.iswolfform)
				if(1)
					container.originalicon = container.icon
					container.ParanormalBPMult= WolfFormBPMult
					container.icon=container.WolfFormIcon
					container.updateOverlay(/obj/overlay/effects/electrictyeffects/spc)
		..()
	DeBuff()
		container.ParanormalBPMult = NormalBPMult
		sleep container.RemoveHair()
		container.iswolfform=0
		container.icon=container.originalicon
		container.removeOverlay(/obj/overlay/effects/electrictyeffects/spc)
		if(container.hair) container.updateOverlay(/obj/overlay/hairs/hair)
		..()

obj/Werewolf/verb/Turn()
	set category = "Skills"
	if(!usr.isBuffed(/obj/buff/Werewolf))
		usr.emit_Sound('chargeaura.wav')
		usr.startbuff(/obj/buff/Werewolf)
	else
		usr.stopbuff(/obj/buff/Werewolf)