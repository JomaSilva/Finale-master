mob/var/reviveTime = 36000
obj/Artifacts/var/CantKeep
obj/Artifacts/RevivalShard
	name = "Revival Shard"
	desc = {"\n
	This shard will give you the ability to resurrect yourself from the dead. It requires your dead energy in order to operate, however.\n
	Even it materializing was a miracle. Depending on how many of these you have, you will slowly begin to become unethereal,\n
	which upon full life materialization will grant you resurrection automatically.\n
	Otherworldly beings may gain a simple power boost from this."}
	icon = 'reviveshards.dmi'
	SaveItem = 0
	var/shardNumber = 1
	var/cooldown = 36000 //cooldown, 1 hour before each shard can be used again after dropping it. This ticks down by 1 every tenth of a second.
	var/tmp/GotBoost = 0
	cantblueprint=1
	CantKeep=1
	ContentsDontSave=1
	verb/CheckRevive()
		set category = null
		usr<<"[container.reviveTime/(10*shardNumber)] seconds remaining."
	Drop()
		set category=null
		set src in usr
		OnRelease(1)
	New()
		..()
		sleep(-1)
		for(var/obj/Artifacts/RevivalShard/A in obj_list)
			if(A!=src && A.name==name)
				name = "Revival Shard [rand(1,100)]"//keep those names seperate
				break
		Scatter()
obj/Artifacts/RevivalShard/OnGrab()
	var/shardnum
	for(var/obj/Artifacts/RevivalShard/A in container.contents)
		shardnum+=1
		A.shardNumber+=1
	..()

obj/Artifacts/RevivalShard/OnRelease(var/fromhand)
	if(container)
		for(var/obj/Artifacts/RevivalShard/A in container.contents)
			A.shardNumber-=1
		if(GotBoost)
			switch(container.Race)
				if("Kai")
					GotBoost = 0
					container.ArtifactsBuff/=1.3
				if("Demon")
					GotBoost = 0
					container.ArtifactsBuff/=1.2
				if("Demigod")
					GotBoost = 0
					container.ArtifactsBuff/=1.1
	shardNumber = 1
	..()
	if(!fromhand||isnull(fromhand)||fromhand == 0)
		src.Scatter()
obj/Artifacts/RevivalShard/logout()
	OnRelease()
	..()

obj/Artifacts/RevivalShard/proc/Scatter()
	set waitfor = 0
	set background = 1
	var/area/targetArea
	var/planetpick = pick("Afterlife","Heaven","Hell")
	for(var/area/afterlifeareas/A in area_outside_list)
		if(A.Planet == planetpick)
			targetArea = A
	if(targetArea)
		var/turf/temploc = pickTurf(targetArea,2)
		if(temploc) src.loc = locate(temploc.x,temploc.y,temploc.z)
	return


mob/Admin3/verb/Toggle_Revival_Shards()
	set category = "Admin"
	switch(alert(usr,"Toggle Revival Shards on or off? If you toggle them on/off, it'll make some new Revival Shards for you or delete them!","","Toggle On","Toggle Off"))
		if("Toggle On")
			RevivalShardsEnabled = 1
			var/obj/Artifacts/RevivalShard/A = new()
			var/obj/Artifacts/RevivalShard/B = new()
			var/obj/Artifacts/RevivalShard/C = new()
			A.Scatter()
			B.Scatter()
			C.Scatter()
		if("Toggle Off")
			RevivalShardsEnabled = 0

obj/Artifacts/RevivalShard/ArtifactLoop()
	set waitfor = 0
	set background = 1
	if(!RevivalShardsEnabled)
		if(container)
			OnRelease()
		Del(src)
	if(container&&!GotBoost)
		switch(container.Race)
			if("Kai")
				GotBoost = 1
				container.ArtifactsBuff*=1.3
			if("Demon")
				GotBoost = 1
				container.ArtifactsBuff*=1.2
			if("Demigod")
				GotBoost = 1
				container.ArtifactsBuff*=1.1
	if(container&&(!container.dead||container.Planet!="Afterlife"&&container.Planet!="Heaven"&&container.Planet!="Hell"))
		OnRelease()
	if(container&&shardNumber>=1)
		shardNumber = min(max(shardNumber,0),3)
		container.reviveTime -= 1*shardNumber
		if(container.reviveTime<=0)
			Revive(container)
			OnRelease()
	..()