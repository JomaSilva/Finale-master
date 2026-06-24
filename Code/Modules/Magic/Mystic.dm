mob/var
	MysticMod=2.5
	hasmystic
	tmp/mysticing
	mystified=0
	MysticPcnt=1
	MysticAdded = 0

mob/keyable/verb/Mystic()
	set category="Skills"
	if(!usr.mysticing)
		usr.mysticing=1
		if(isBuffed(/obj/buff/Mystic))
			stopbuff(/obj/buff/Mystic)
		else
			startbuff(/obj/buff/Mystic)
		sleep(20)
		usr.mysticing=0

obj/overlay/effects/MysticEffect
	name = "Mystic Electricty effect"
	ID = 13
	icon = 'Electric_Mystic.dmi'

/obj/buff/Mystic
	name = "Mystic"
	icon='Electric_Blue.dmi'
	slot=sFORM
	var/storedpower
	Buff()
		..()
		container<<"<font color=yellow> You unleash your godly Mystic form."
		container.Revert()
		sleep container.RemoveHair()
		if(!container.Apeshit)
			container.updateOverlay(/obj/overlay/hairs/hair)
		container.updateOverlay(/obj/overlay/effects/MysticEffect)
		if(container.hasssj)
			container.MysticMod = container.ssjmult
		if(container.hasssj2)
			container.MysticMod = 1.1*container.ssj2mult
		container.MysticPcnt=container.MysticMod
		container.MysticAdded = container.hiddenpotential
		container.BPadd += container.MysticAdded
		container.emit_Sound('chargeaura.wav')
	DeBuff()
		container<<"<font color=yellow> You stop using your Mystic power."
		container.removeOverlay(/obj/overlay/effects/MysticEffect)
		container.MysticPcnt=1
		container.BPadd -= container.MysticAdded
		..()