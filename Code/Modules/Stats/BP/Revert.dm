mob/proc/Revert(var/DontRevertSSJ)
	if(DontRevertSSJ == 0)
		overlayList-='SSj Aura.dmi'
		overlayList-='AuraLSSjBig.dmi'
		overlayList-='Elec.dmi'
		overlayList-='Electric_Blue.dmi'
		overlayList-='ElecAura1.dmi'
		overlayList-='Electric_Yellow.dmi'
		overlayList-='Electric_Red.dmi'
		overlayList-='SSj4_Body.dmi'
		removeOverlay(/obj/overlay/effects/electrictyeffects)
		stopbuff(/obj/buff/SuperSaiyan)
		stopbuff(/obj/buff/LSSJ)
		stopbuff(/obj/buff/snamek)
		stopbuff(/obj/buff/MaxPower)
		stopbuff(/obj/buff/SuperPerfect)
		stopbuff(/obj/buff/Alien_Trans)
		stopbuff(/obj/buff/Werewolf)
		stopbuff(/obj/buff/Giant_Form)
		stopbuff(/obj/buff/Wrathful_State)
		ssjBuff = 1
		ssj=0
		lssj=0
		trans=0
	if(DontRevertSSJ == 2)
		downbuff(/obj/buff/SuperSaiyan)
		downbuff(/obj/buff/LSSJ)
		downbuff(/obj/buff/snamek)
		downbuff(/obj/buff/MaxPower)
		downbuff(/obj/buff/SuperPerfect)
		downbuff(/obj/buff/Alien_Trans)
		downbuff(/obj/buff/Werewolf)
		downbuff(/obj/buff/Giant_Form)
		downbuff(/obj/buff/Wrathful_State)
	poweruprunning=0
	sding=0
	RemoveHair()
	AddHair()
	ExpandRevert()
	ClearPowerBuffs()
	KaiokenRevert()