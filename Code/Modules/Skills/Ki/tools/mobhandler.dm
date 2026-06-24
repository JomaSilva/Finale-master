
mob/proc/AddChargeOverlay()
	var/obj/I=new/obj
	I.layer=MOB_LAYER+99
	I.plane=7
	I.icon='BlastCharges.dmi'
	I.icon_state=ChargeState
	I.icon+=rgb(blastR,blastG,blastB)
	overlayList+=I
	overlaychanged=1
	spawn
		sleep(10)
		while(blasting) sleep(1)
		overlayList-=I
		overlaychanged=1
		if(I) del(I)

mob/proc/addchargeoverlay() //duped for now since ton of other file rely on it
	var/obj/I=new/obj
	I.layer=MOB_LAYER+99
	I.plane=7
	I.icon='BlastCharges.dmi'
	I.icon_state=ChargeState
	I.icon+=rgb(blastR,blastG,blastB)
	overlayList+=I
	overlaychanged=1
	spawn
		sleep(10)
		while(charging) sleep(1)
		overlayList-=I
		overlaychanged=1
		if(I) del(I)