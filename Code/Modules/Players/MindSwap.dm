//todo: fix
client/proc/MindSwap(var/mob/TargetMob)
	if(isnull(TargetMob))
		OutputDebug("Line 4 of MindSwap.dm- no TargetMob set! Call the proc right!")
		return FALSE
	if(TargetMob.client)
		OutputDebug("Line 7 of MindSwap.dm- TargetMob already has a client at the time of calling! Use a different proc to swap minds between players!")
		return FALSE
	if(isnull(mob))
		OutputDebug("Line 10 of Mindswap.dm- No client mob to mindswap with!")
		return
	if(TargetMob.isNPC || istype(TargetMob,/mob/npc))
		var/mob/npc/nNPC = TargetMob
		nNPC.isNPC = 0
		nNPC.hasAI = 0
		nNPC.AIRunning = 0

	//save the old user into a backup directory j u s t  i n  c a s e
	var savefile/save = new ("Save/backups/mindswap_backups/[key]/save[mob.save_path]-[mob.name].dbcsav")
	CHECK_TICK
	save << mob
	//
	var/mob/oldMob = mob
	TargetMob.SLogoffOverride = 1
	mob.SLogoffOverride = 1
	mob.SaveMob = 1 //Save the mob. All mobs with 'SLogoffOverride' are all saved anyways, but this doublechecks it.
	TargetMob.SaveMob = 0 //Target mob shall no longer be treated as a NPC.
	TargetMob.monster = 0 //just in case: client doesn't swap into a AI running mob.
	TargetMob.isNPC = 0 //
	TargetMob.save_path = mob.save_path
	mob.BlankPlayer = 1
	TargetMob.BlankPlayer = 1
	mob = TargetMob //switch mobs.
	sleep(5)//exploit possibility here: it takes five seconds for the SLogoffOverride var to be ticked back for the target mob.
	//won't fix until it becomes a prudent issue :^)
	TargetMob.SLogoffOverride = 0
	TargetMob.BlankPlayer = 0
	TargetMob.Savable=1
	TargetMob.Player = 1
	sleep(2)
	if(TargetMob.client) TargetMob.OnLogin(1)
	if(TargetMob.client) TargetMob.Save()
	//
	if(istype(oldMob,/mob/npc))
		var/mob/npc/nNPC = oldMob
		nNPC.isNPC = 1
		nNPC.hasAI = 1
	//

//from Xooxer, source post: http://www.byond.com/forum/post/269111#comment1150696
client/proc
	BSwapBckup()
		var savefile/save = new ("Save/backups/bodyswap_backups/[key]/save[mob.save_path]-[mob.name].dbcsav")
		save << mob

	BodySwap(var/mob/char)
		set waitfor = 0
		if(!char.client)
			OutputDebug("Line 48 of Mindswap.dm- No client mob to bodyswap with!")
			return

		var/mob/TempMob = new() // Create a new temporary mob
		//
		//BDYSWP Protections
		//
		BSwapBckup()
		if(char.client)
			char.client.BSwapBckup()
		//
		mob.SLogoffOverride = 1
		mob.SaveMob = 1 //Save the mob. All mobs with 'SLogoffOverride' are all saved anyways, but this doublechecks it.
		mob.BlankPlayer = 1
		mob.last_mind = src
		//
		char.SLogoffOverride = 1
		char.SaveMob = 1
		char.BlankPlayer = 1
		char.last_mind = char.client
		//
		//

		if(fexists(mob.GetSavePath(mob.save_path)))
			fdel(mob.GetSavePath(mob.save_path))

		if(fexists(mob.GetSavePath(char.save_path)))
			fdel(mob.GetSavePath(char.save_path))

		var/mob/oldmob = mob

		TempMob.BlankPlayer = 1
		mob = TempMob

		char.client.clientswap(oldmob)//other player goes first

		clientswap(char) //then us

		del(TempMob)

	clientswap(var/mob/sM)
		set waitfor = 0
		mob = sM
		//sM.key = key
		sleep(1)
		sM.SLogoffOverride = 0
		sM.SaveMob = 0
		sM.BlankPlayer = 0
		sM.OnLogin(1)

mob/var/last_mind