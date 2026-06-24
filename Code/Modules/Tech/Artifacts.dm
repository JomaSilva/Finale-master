obj/Artifacts
	//parent_type = /obj/items //This allows obj/Artifact to access ALL procedures and variables of /item.
	name = "Artifact"
	icon = 'ControlChip.dmi'
	var/mob/container = null
	var/Unmovable
	var/ContentsDontSave //for when you have temporary objects that shouldn't be stuck in a persons contents.
	New()
		..()
		spawn ArtifactLoop()


obj/Artifacts/proc/OnGrab()
	Move(container)
	view(container)<<"<font color=teal><font size=1>[container] picks up [src]."
	WriteToLog("rplog","[container] picks up [src]    ([time2text(world.realtime,"Day DD hh:mm")])")
	return

obj/Artifacts/proc/OnRelease()
	OnUnEquip()
	container.overlayList-=icon
	loc=locate(container.x,container.y,container.z)
	step(src,container.dir)
	view(container)<<"<font size=1><font color=teal>[container] drops [src]."
	container = null
	return

obj/Artifacts/proc/logout()
	container = null

obj/Artifacts/proc/login(var/mob/logger)
	container = logger

obj/Artifacts/proc/ArtifactLoop()
	set waitfor = 0
	set background = 1
	sleep(1)
	spawn ArtifactLoop()

obj/Artifacts/proc/OnEquip()
	return

obj/Artifacts/proc/OnUnEquip()
	if(equipped|suffix=="*Equipped*")
		suffix = ""
		equipped = 0
	return

obj/Artifacts
	verb
		Get()
			set category=null
			set src in oview(1)
			if(Bolted)
				src<<"It is bolted to the ground, you cannot get it."
				return
			if(Unmovable)
				src<<"It is still. You cannot get it."
				return
			if(usr&&!container)
				if(!usr.KO)
					container = usr
					OnGrab()
				else usr<<"You cant, you are knocked out."
		Drop()
			set category=null
			set src in usr
			OnRelease()
/*
proc/HandleArtifacts()
	set background = 1
	CHECK_TICK
	spawn for(var/obj/Artifacts/A in world)
		sleep(1)
		CHECK_TICK
		spawn A.ArtifactLoop()
		sleep(1)*/