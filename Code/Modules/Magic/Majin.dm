mob/var
	MajinMod=1.2
	hasmajin
	tmp/majining
	majinized=0 //how many People you have turned mystic/majin, max of 3.
	MajinPcnt=1
	MajinAdd

mob/keyable/verb/Majin()
	set category="Skills"
	if(!usr.majining)
		usr.majining=1
		if(isBuffed(/obj/buff/Majin))
			stopbuff(/obj/buff/Majin)
		else
			startbuff(/obj/buff/Majin)
		sleep(20)
		usr.majining=0

obj/overlay/effects/MajinEffect
	name = "Majin Electricty effect"
	ID = 17
	icon = 'Electric_Majin.dmi'

/obj/buff/Majin
	name = "Majin"
	icon='Electric_Majin.dmi'
	slot=sFORM
	var/storedpower
	Buff()
		..()
		container<<"<font color=yellow>You channel your inner demons into your Majin form."
		container.MajinPcnt=container.MajinMod
		container.MajinAdd = ((container.BP*container.MajinMod*(container.MaxAnger/100))/10)
		container.BPadd += container.MajinAdd
		container.angerMod/=1.2
		container.physoffMod*=1.3
		container.kiregenMod+=0.5
		container.updateOverlay(/obj/overlay/effects/MajinEffect)
		container.emit_Sound('chargeaura.wav')
	DeBuff()
		container<<"<font color=yellow>Your rage subsides as you calm down."
		container.BPadd -= container.MajinAdd
		container.MajinPcnt=1
		container.angerMod*=1.2
		container.physoffMod/=1.3
		container.kiregenMod-=0.5
		container<<"You stop using your Majin power."
		container.removeOverlay(/obj/overlay/effects/MajinEffect)
		..()