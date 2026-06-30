var
	list/FusionDatabase = list()
	//--- Fusion Energy: drains over time. base drain 1/sec; a transformation adds (form mult / 50) per sec. ---
	FUSION_DANCE_ENERGY = 900   //Fusion Dance: 900 energy = 15 min at base drain
	FUSION_POTARA_ENERGY = 1800 //Potara Fusion: 1800 energy = 30 min at base drain
	FUSION_COOLDOWN = 36000     //1h per-player cooldown after a fusion ends (world.realtime is in deciseconds)
	//--- legacy globals (kept declared; the new logic no longer uses them) ---
	DanceMod = 1.5
	PotaraMod = 2.5
	FuseTimeMin = 7000
	FuseTimeMax = 36000

mob
	var
		FuseBuff //additive BP added to the controller so base BP = (BP_keeper + BP_loser) * 2
		FuseDanceMod =1 //legacy: base.dm reads FuseDanceMod*FPotaraMod for fusionBuff; kept at 1 (fusion power now comes from FuseBuff)
		FPotaraMod =1   //legacy: idem
		FuseTimer = 0   //legacy (unused)
		PotaraTimer     //legacy (unused)
		FDanceClothes = 'Clothes_FusionPads.dmi'
		PotaraEarringIcon = 'potara.dmi'
		FDanceSkill = 0.25 //legacy (unused)
		fusing=0
		tmp/mob/Fusee = null
		isnamekd=0
		tmp/FusionEnergy = 0      //mirror of the active fusion datum, for display
		tmp/FusionEnergyMax = 0   //mirror of the active fusion datum, for display
		fusion_cooldown_until = 0 //world.realtime until which this player cannot fuse again (persistent)
		tmp/fusing_now = 0 //synchronous in-progress guard (closes the Potara double-fuse race)

mob/proc/current_form_mult() //the fused warrior's live transformation multiplier (drives the fusion-energy drain)
	var/g = 0
	if(godki && godki.usage) g = god_form_mult() //God forms (SSJG 22x / Blue-Rose 32x / Evolved 56x) live in god_form_mult, not ssjBuff
	return max(g ? g : (ssjBuff * transBuff * formsBuff), 1)

mob/proc/fusion_fresh_body() //a Fusion is a brand-new person: restore every limb to whole (no inherited lost limbs)
	for(var/datum/Body/B in body)
		if(B.lopped) B.RegrowLimb()
		B.health = B.maxhealth

mob/proc/fusion_snapshot_lopped() //record which limbs are missing so Defuse can re-apply them (no free regen exploit)
	var/list/L = list()
	for(var/datum/Body/B in body)
		if(B.lopped) L += "[B.type]"
	return L

mob/proc/fusion_restore_lopped(var/list/types) //re-sever the limbs that were missing before the fusion
	if(!types || !types.len) return
	for(var/datum/Body/B in body)
		if("[B.type]" in types)
			B.lopped = 1
			B.health = 0
			B.status = "Missing"

mob/proc/fusion_on_cooldown()
	return (world.realtime < fusion_cooldown_until)

mob/proc/in_active_fusion()
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.IsActiveForKeeper && F.KeeperSig == signature) return 1
		if(F.IsActiveForLoser && F.LoserSig == signature) return 1
	return 0

mob/proc/my_active_fusion()
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.IsActiveForKeeper || F.IsActiveForLoser)
			if(F.KeeperSig == signature || F.LoserSig == signature) return F
	return null

mob/proc/active_fusion_as_keeper()
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.IsActiveForKeeper && F.KeeperSig == signature) return F
	return null

mob/proc/defuse_on_downed() //"Getting downed will separate the fusion" (called from KO())
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.KeeperSig == signature || F.LoserSig == signature)
			if(F.IsActiveForKeeper || F.IsActiveForLoser)
				if(F.FType == 3) continue //Namekian fusion is permanent - a KO does not split it
				F.Defuse(1)

datum/Fusion
	var/tmp/mob/Keeper
	var/KeeperSig
	var/tmp/mob/Loser
	var/LoserSig
	var/LoserContributedBP
	var/IsActiveForKeeper
	var/IsActiveForLoser
	var/LoseItFlag
	var/FuseName
	var/OldName
	var/FType
	//
	var/PowerEqual = 1 //Any number greater or lower will cause the transformation's power to decrease. Below <0.5 will mean the fusion itself will become botched.
	var/FusionSkill = 1
	//
	var/OtherReincarnated
	var/LoserBackupLoc
	var/CompletelyPerm
	//--- new fusion model ---
	var/FusedBaseBP = 0      //(BP_keeper + BP_loser) * 2, snapshot at fuse time (symmetric)
	var/KeeperFuseDelta = 0  //amount currently added to the Keeper's FuseBuff (= FusedBaseBP - Keeper.BP)
	var/FusionEnergy = 0     //authoritative remaining energy
	var/FusionEnergyMax = 0  //0 for permanent (Namekian) fusions
	var/tmp/EnergyRunning = 0 //guard so only one drain loop runs (tmp so a server reboot can't freeze a saved fusion)
	var/KeeperOrigSpace = 0  //the controller's spacebreather before fusing (restored on defuse)
	var/list/KeeperLoppedTypes //limbs missing before fusing, re-applied on defuse
	//
	//Customization stuff
	var/icon/FuseIcon
	var/icon/OldIcon
	var/list/FuseOverlays = list()
	var/icon/FuseHair
	var/icon/oldHair
	var/icon/FuseHairSSJ
	var/icon/oldHairSSJ
	var/icon/FuseHairUSSJ
	var/icon/oldHairUSSJ
	var/icon/FuseHairSSJ2
	var/icon/oldHairSSJ2
	var/icon/FuseHairSSJ3
	var/icon/oldHairSSJ3
	var/list/FuseHairColor = list()
	var/list/oldhaircolor = list()
	//
	proc/Customize()
		customizehome
		switch(input(Keeper,"Customize what? Hair is custom icon only (I.E. no hair selection window.)") in list("Name","Icon","Add overlay","Hair","SSJ Hair","USSJ Hair","SSJ2 Hair","SSJ3 Hair","Hair Color","Done"))
			if("Name")
				FuseName = input(Keeper,"What is your name, Fused Warrior?") as text
			if("Add overlay")
				var/icon/I = input(Keeper,"Add overlay. It'll be bottom-middle-centered.") as icon
				if(isnull(I))
				else
					var/image/A = image(I)
					A.pixel_x = round(((32 - I.Width()) / 2),1)
					FuseOverlays += A
			if("Hair")
				FuseHair = input(Keeper,"Add a hair. It won't be centered.") as icon
			if("SSJ Hair")
				FuseHairSSJ = input(Keeper,"Add a hair. It won't be centered.") as icon
			if("USSJ Hair")
				FuseHairUSSJ = input(Keeper,"Add a hair. It won't be centered.") as icon
			if("SSJ2 Hair")
				FuseHairSSJ2 = input(Keeper,"Add a hair. It won't be centered.") as icon
			if("SSJ3 Hair")
				FuseHairSSJ3 = input(Keeper,"Add a hair. It won't be centered.") as icon
			if("Hair Color")
				var/rgbsuccess
				rgbsuccess= input(Keeper,"Change hair color.") as color
				var/list/oldrgb
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
				while(!oldrgb)
					sleep(1)
					oldrgb=hrc_hex2rgb(rgbsuccess,1)
				FuseHairColor+=oldrgb[1]
				FuseHairColor+=oldrgb[3]
				FuseHairColor+=oldrgb[2]
			if("Icon")
				FuseIcon = input(Keeper,"Choose a icon. It won't be centered.") as icon
			if("Done")
				goto theend
		goto customizehome
		theend
	proc/doOverlays()
		OldName = Keeper.name
		if(!FuseName && Loser)
			var/lenglos = length(Loser.name)
			var/namecontrlos = copytext(Loser.name,round(lenglos/2))
			var/lengkep = length(Keeper.name)
			var/namecontrkep = copytext(Keeper.name,round(lengkep/2))
			FuseName = "[namecontrkep][namecontrlos]"
			if(!FuseName)
				FuseName = "[Keeper.name] Potara Fusion"
		else if(!FuseName)
			FuseName = "[Keeper.name] Potara Fusion"
		Keeper.name = FuseName
		if(FuseIcon)
			OldIcon = Keeper.icon
			Keeper.icon = FuseIcon
		if(FuseHair)
			oldHair = Keeper.hair
			Keeper.hair = FuseHair
		if(FuseHairSSJ)
			oldHairSSJ = Keeper.ssjhair
			Keeper.ssjhair = FuseHairSSJ
		if(FuseHairUSSJ)
			oldHairUSSJ = Keeper.ussjhair
			Keeper.ussjhair = FuseHairUSSJ
		if(FuseHairSSJ2)
			oldHairSSJ2 = Keeper.ssj2hair
			Keeper.ssj2hair = FuseHairSSJ2
		if(FuseHairSSJ3)
			oldHairSSJ3 = Keeper.ssj3hair
			Keeper.ssj3hair = FuseHairSSJ3
		if(FuseHairColor.len>=1)
			oldhaircolor = list()
			oldhaircolor+=Keeper.hairred
			oldhaircolor+=Keeper.hairblue
			oldhaircolor+=Keeper.hairgreen
			Keeper.hairred=FuseHairColor[1]
			Keeper.hairblue=FuseHairColor[2]
			Keeper.hairgreen=FuseHairColor[3]
		if(FuseHair||FuseHairColor)
			Keeper.RemoveHair()
			Keeper.AddHair()
		Keeper.overlayList += FuseOverlays
		Keeper.overlaychanged=1
		if(FType==1) Keeper.updateOverlay(/obj/overlay/clothes/FusionPads)
		if(FType==2) Keeper.updateOverlay(/obj/overlay/clothes/PotaraEarrings)
	proc/undoOverlays()
		if(!isnull(OldName)) Keeper.name = OldName
		Keeper.overlayList -= FuseOverlays
		Keeper.overlaychanged=1
		if(FuseIcon)
			Keeper.icon = OldIcon
		if(FuseHair)
			Keeper.hair = oldHair
		if(FuseHairSSJ)
			Keeper.ssjhair = oldHairSSJ
		if(FuseHairUSSJ)
			Keeper.ussjhair = oldHairUSSJ
		if(FuseHairSSJ2)
			Keeper.ssj2hair = oldHairSSJ2
		if(FuseHairSSJ3)
			Keeper.ssj3hair = oldHairSSJ3
		if(FuseHairColor.len>=1)
			Keeper.hairred=oldhaircolor[1]
			Keeper.hairblue=oldhaircolor[2]
			Keeper.hairgreen=oldhaircolor[3]
		if(FuseHair||FuseHairColor)
			Keeper.RemoveHair()
			Keeper.AddHair()
		if(FType==1) Keeper.removeOverlay(/obj/overlay/clothes/FusionPads)
		if(FType==2) Keeper.removeOverlay(/obj/overlay/clothes/PotaraEarrings)
	//
	New()
		..()
		FusionDatabase += src

	proc/CheckOnline()
		for(var/mob/M in mob_list)
			if(M.signature==KeeperSig)
				Keeper = M
			if(M.signature==LoserSig)
				Loser = M
			if(Keeper&&Loser)
				break
		if(ismob(Loser)&&ismob(Keeper))
			Loser.Fusee = Keeper

	proc/Fuse()
		CheckOnline()
		if(!(Keeper && Loser)) return
		//--- BP: the fusion's base power = both fighters' BP summed, then doubled ---
		FusedBaseBP = (Keeper.BP + Loser.BP) * 2
		KeeperFuseDelta = FusedBaseBP - Keeper.BP
		Keeper.FuseBuff += KeeperFuseDelta
		//--- Fusion Energy (Dance/Potara are temporary; Namekian is permanent) ---
		switch(FType)
			if(1) FusionEnergyMax = FUSION_DANCE_ENERGY
			if(2) FusionEnergyMax = FUSION_POTARA_ENERGY
			else  FusionEnergyMax = 0
		FusionEnergy = FusionEnergyMax
		Keeper.FusionEnergy = FusionEnergy
		Keeper.FusionEnergyMax = FusionEnergyMax
		//--- brand-new person: whole body (temporary) + only Vacuum Breathing carries over ---
		KeeperLoppedTypes = Keeper.fusion_snapshot_lopped()
		Keeper.fusion_fresh_body()
		KeeperOrigSpace = Keeper.spacebreather
		if(Loser.spacebreather) Keeper.spacebreather = 1
		if(FType==3) Loser.isnamekd = 1
		//--- park the Loser as a sealed spectator passenger ---
		Loser.verblist |= /verb/Set_Fusion_View
		Loser.verbs += /verb/Set_Fusion_View
		LoserBackupLoc = Loser.loc
		Loser.Fusee = Keeper
		IsActiveForKeeper = 1
		IsActiveForLoser = 1
		sleep(5)
		if(!(IsActiveForKeeper && Keeper && Loser)) return //defused (e.g. KO) during the brief setup window
		Loser.GotoPlanet("Sealed")
		Customize()
		if(!(IsActiveForKeeper && Keeper)) return //defused during the blocking customize prompt
		doOverlays()
		if(FusionEnergyMax > 0) spawn EnergyLoop()

	proc/Defuse(var/Forced)
		CheckOnline()
		if(CompletelyPerm) return
		if(FType == 3 && !Forced) return //Namekian fusion is permanent unless forced (admin) or made core-permanent below
		//--- passenger reincarnated out of a permanent (Namek) fusion -> option to bake it in for good ---
		if(Keeper && IsActiveForKeeper && FType == 3 && OtherReincarnated)
			var/choice = "Yes"
			if(Keeper.client) choice = alert(Keeper,"Your fusion is permanent and your partner reincarnated. Make this truly permanent? (OOC: it becomes part of your core character - not even Admins can undo it.)","","No","Yes")
			if(choice == "Yes")
				CompletelyPerm = 1
				Keeper.BP = FusedBaseBP //bake the full fused power into real BP
				Keeper.FuseBuff -= KeeperFuseDelta
				Keeper.FusionEnergy = 0
				Keeper.FusionEnergyMax = 0
				return
		//--- restore the controller ---
		if(Keeper && IsActiveForKeeper)
			Keeper.FuseBuff -= KeeperFuseDelta
			Keeper.FusionEnergy = 0
			Keeper.FusionEnergyMax = 0
			undoOverlays()
			Keeper.spacebreather = KeeperOrigSpace //don't leak Vacuum Breathing past the fusion
			Keeper.fusion_restore_lopped(KeeperLoppedTypes) //re-apply limbs that were missing before fusing
			IsActiveForKeeper = 0
			Keeper.fusion_cooldown_until = world.realtime + FUSION_COOLDOWN
			to_chat(Keeper, "<font color=yellow>You split back apart!</font>")
		//--- restore the passenger ---
		if(Loser && IsActiveForLoser)
			Loser.verblist -= /verb/Set_Fusion_View
			Loser.verbs -= /verb/Set_Fusion_View
			if(Loser.client && Loser.observingnow)
				Loser.client.perspective = MOB_PERSPECTIVE
				Loser.client.eye = Loser
				Loser.observingnow = 0
			Loser.loc = LoserBackupLoc ? LoserBackupLoc : (Keeper ? locate(Keeper.x,Keeper.y,Keeper.z) : Loser.loc)
			Loser.Fusee = null
			Loser.isnamekd = 0
			IsActiveForLoser = 0
			Loser.fusion_cooldown_until = world.realtime + FUSION_COOLDOWN
		return TRUE

	proc/EnergyLoop() //drains the fusion energy in real time; defuses when it hits 0
		if(EnergyRunning) return
		EnergyRunning = 1
		var/lastrt = world.realtime
		while(IsActiveForKeeper && FusionEnergy > 0 && Keeper)
			sleep(10) //~1s tick; exact drain uses the realtime delta so fps/lag do not distort it
			if(!IsActiveForKeeper || !Keeper) break
			var/nowrt = world.realtime
			var/dt = (nowrt - lastrt) / 10 //seconds elapsed (world.realtime is in deciseconds)
			lastrt = nowrt
			if(dt <= 0) continue
			var/fm = Keeper.current_form_mult()
			var/drainrate = 1 + (fm > 1 ? fm / 50 : 0) //base 1/sec; a form adds form_mult/50
			FusionEnergy -= drainrate * dt
			Keeper.FusionEnergy = max(FusionEnergy, 0)
			Keeper.FusionEnergyMax = FusionEnergyMax
			if(FusionEnergy <= 0)
				to_chat(Keeper, "<font color=yellow>Your fusion runs out of energy and splits apart!</font>")
				Defuse()
				break
		EnergyRunning = 0

	proc/PassControl() //hand control of the fused warrior to the other player (symmetric: same power)
		CheckOnline()
		if(!(Keeper && Loser && IsActiveForKeeper && IsActiveForLoser)) return
		if(!Loser.client) return //the other half must be online to take over
		var/mob/oldK = Keeper
		var/mob/oldL = Loser
		var/turf/bodyloc = locate(oldK.x, oldK.y, oldK.z)
		//--- strip the fused identity + BP + temporary traits from the old controller ---
		undoOverlays()
		oldK.FuseBuff -= KeeperFuseDelta
		oldK.FusionEnergy = 0
		oldK.FusionEnergyMax = 0
		oldK.spacebreather = KeeperOrigSpace
		oldK.fusion_restore_lopped(KeeperLoppedTypes)
		//--- swap roles ---
		Keeper = oldL
		Loser = oldK
		var/tmpsig = KeeperSig
		KeeperSig = LoserSig
		LoserSig = tmpsig
		//--- seal the old controller as the new spectator passenger ---
		Loser.verblist |= /verb/Set_Fusion_View
		Loser.verbs |= /verb/Set_Fusion_View
		LoserBackupLoc = bodyloc
		Loser.Fusee = Keeper
		if(Loser.client && Loser.observingnow)
			Loser.client.perspective = MOB_PERSPECTIVE
			Loser.client.eye = Loser
			Loser.observingnow = 0
		Loser.GotoPlanet("Sealed")
		//--- bring the new controller out into the body ---
		Keeper.verblist -= /verb/Set_Fusion_View
		Keeper.verbs -= /verb/Set_Fusion_View
		Keeper.Fusee = null
		if(Keeper.client && Keeper.observingnow)
			Keeper.client.perspective = MOB_PERSPECTIVE
			Keeper.client.eye = Keeper
			Keeper.observingnow = 0
		Keeper.loc = bodyloc
		KeeperFuseDelta = FusedBaseBP - Keeper.BP
		Keeper.FuseBuff += KeeperFuseDelta
		Keeper.FusionEnergy = max(FusionEnergy, 0)
		Keeper.FusionEnergyMax = FusionEnergyMax
		KeeperLoppedTypes = Keeper.fusion_snapshot_lopped()
		Keeper.fusion_fresh_body()
		KeeperOrigSpace = Keeper.spacebreather
		if(oldK.spacebreather) Keeper.spacebreather = 1
		doOverlays()
		to_chat(Keeper, "<font color=yellow>You take control of the fused warrior!</font>")
		to_chat(Loser, "<font color=yellow>You hand control of the fused warrior to your partner.</font>")

	proc/MessageFusors(var/source,var/msg) //1 == Keeper, 2 == Loser
		if(!source)
			return
		switch(source)
			if(1)
				if(IsActiveForLoser)
					Loser << output("[msg]")
			if(2)
				if(IsActiveForKeeper)
					Keeper << output("[msg]")

mob/Admin3/verb/Delete_Fusion_Database()
	set category = "Admin"
	var/choice = alert(usr,"Delete the entire database, or just one? Deleting all will defuse everyone!","","Cancel","One","All")
	switch(choice)
		if("All")
			to_chat(usr, "Defusing everyone! Offline characters will have their stats fudged!")
			for(var/datum/Fusion/F)
				if(F.IsActiveForKeeper||F.IsActiveForLoser)
					F.Defuse(1)
				to_chat(world, "Deleted [F.FuseName]")
				del(F)
			FusionDatabase = list()

		if("One")
			var/choice2 = input(usr,"Which one?") in FusionDatabase
			for(var/datum/Fusion/F)
				if(F==choice2)
					if(F.IsActiveForKeeper||F.IsActiveForLoser)
						F.Defuse(1)
					to_chat(world, "Deleted [F.FuseName]")
					FusionDatabase -= F
					del(F)
					break

mob/Admin2/verb/Reset_Fusion(var/mob/M)
	set category = "Admin"
	var/choice = alert(usr,"Make sure to use this on the other part of the fusion too! Also ask a level 3 to delete the fusion entirely as well from the database if you know it's malfunctioning.","","Cancel","OK")
	switch(choice)
		if("OK")
			to_chat(usr, "Just in case, the fusion will attempt to defuse itself on it's own!")
			for(var/datum/Fusion/F)
				if(F.KeeperSig==signature||F.LoserSig==signature)
					if(F.IsActiveForKeeper||F.IsActiveForLoser)
						F.Defuse(1)
			M.FuseBuff = 0
			M.FuseDanceMod = 1
			M.FPotaraMod = 1
			M.FusionEnergy = 0
			M.FusionEnergyMax = 0
			M.fusion_cooldown_until = 0
			M.verblist -= /verb/Set_Fusion_View
			M.verbs -= /verb/Set_Fusion_View
			M.Fusee = null

mob/proc/CheckFusion(var/RemoveReference)
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.KeeperSig==signature) F.Keeper = src
		if(F.LoserSig==signature) F.Loser = src
	if(RemoveReference==1)
		for(var/datum/Fusion/F in FusionDatabase)
			if(F.KeeperSig==signature && F.IsActiveForKeeper) //only the CONTROLLER logging out reverts the fused look (relog re-applies it)
				F.undoOverlays()
	else if(RemoveReference==2)
		for(var/datum/Fusion/F in FusionDatabase)
			if(F.KeeperSig==signature && F.IsActiveForKeeper)
				F.Keeper = src
				F.doOverlays()
				F.EnergyRunning = 0 //clear any stale (reboot-saved) guard so the drain loop actually restarts
				if(F.FusionEnergyMax > 0) spawn F.EnergyLoop()
			else if(F.LoserSig==signature && F.IsActiveForLoser)
				F.Loser = src
				Fusee = F.Keeper //re-link the spectator so Set_Fusion_View works after a relog
		if(!in_active_fusion()) //un-strand: loaded inside the Sealed zone but no longer fused -> go home
			var/turf/T = src.loc
			if(isturf(T))
				var/area/AR = T.loc //a turf loc IS its area in this engine
				if(AR && AR.Planet == "Sealed" && spawnPlanet) spawn(10) GotoPlanet(spawnPlanet)
	else for(var/datum/Fusion/F in FusionDatabase)
		if(F.KeeperSig==signature||F.LoserSig==signature)
			if(F.IsActiveForKeeper||F.IsActiveForLoser)
				F.Defuse()
			if(RemoveReference==1)
				if(F.Keeper == src)
					F.Keeper = null
				if(F.Loser == src)
					F.Loser = null


//(FuseCheck removed - the energy drain is handled by datum/Fusion/EnergyLoop)


verb/Set_Fusion_View()
	set category = "Other"
	if(!usr.observingnow&&usr.Fusee&&usr.Fusee.client)
		usr.client.perspective=EYE_PERSPECTIVE
		usr.client.eye=usr.Fusee.client.mob
		usr.observingnow=1
	else
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=usr
		usr.observingnow=0

mob/verb/Pass_Fusion_Control()
	set category = "Other"
	set name = "Pass Fusion Control"
	var/datum/Fusion/F = active_fusion_as_keeper()
	if(!F)
		to_chat(usr, "You are not in control of a fusion.")
		return
	if(!F.Loser || !F.Loser.client)
		to_chat(usr, "Your other half is not available to take control.")
		return
	F.PassControl()

mob/proc/Fuse(var/mob/M,var/FuType)
	if(in_active_fusion() || M.in_active_fusion() || fusing_now || M.fusing_now) return //guard: closes the Potara double-loop race + any double-fuse
	fusing_now = 1
	M.fusing_now = 1
	var/FusionExists
	if(M.name == name)
		M.name += "1"
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.KeeperSig==signature&&F.LoserSig==M.signature)
			if(F.FType == FuType)
				if(!F.IsActiveForKeeper&&!F.IsActiveForLoser)
					FusionExists = 1
					F.Fuse()
					break
		sleep(1)
	if(!FusionExists) //no fusion exists
		var/datum/Fusion/F = new
		F.KeeperSig = signature
		F.LoserSig = M.signature
		F.FType = FuType
		F.Fuse()
	fusing_now = 0 //fusion resolved (or aborted); release the in-progress guard
	M.fusing_now = 0

obj/Namekian_Fusion/verb/Namekian_Fusion()
mob/keyable/verb/Namekian_Fusion()
	set name = "Fusion"
	set category="Skills"
	var/mob/M=input("Who?") as null|mob in oview(1)
	if(!M) return
	if(M==usr) return
	if(M.Race!="Namekian") return
	if(usr.Race!="Namekian") return
	if(fusing) return
	if(usr.in_active_fusion() || M.in_active_fusion())
		to_chat(usr, "One of you is already fused!")
		return
	if(usr.fusion_on_cooldown() || M.fusion_on_cooldown())
		to_chat(usr, "One of you is still on fusion cooldown (1 hour after a fusion ends).")
		return
	usr.fusing=1
	switch(input(M,"[usr] wishes to permanently fuse with you. [usr] will control the fused being.", "", text) in list ("No", "Yes",))
		if("Yes")
			to_chat(view(9), "<font color=yellow>[usr] fuses with [M]!")
			usr.Fuse(M,3) //initiator (usr) controls
	usr.fusing=0

mob/var/Wearing_Potara_Earrings

obj/items/Potara_Earring
	name = "Potara Earring (Left)"
	icon = 'potaraleft.dmi'
	desc = "Potara earrings: pair two, wear them, and touching another wearer fuses you. Potara fusion lasts about 30 minutes (more Fusion Energy than the Dance). Whoever initiates controls; control can be passed."
	SaveItem = 1
	verb
		Pair_Earring(var/obj/items/Potara_Earring/A in view())
			set category = null
			set src in usr
			if(A)
				if(istype(A,/obj/items/Potara_Earring))
					if(PairedEarring)
						if(PairedEarring.PairedEarring == src)
							to_chat(usr, "The earrings are already paired!")
					A.PairedEarring = src
					PairedEarring = src
					A.icon = 'potararight.dmi'
					icon = 'potaraleft.dmi'
			else
				to_chat(usr, "You need another Potara Earring to pair it!")
		Remove_Pair()
			set category = null
			set src in usr
			if(PairedEarring)
				PairedEarring.PairedEarring = null
				PairedEarring = null
				icon = 'potaraleft.dmi'
				to_chat(usr, "Paired earring removed.")
		Check_Pair()
			set category = null
			set src in usr
			if(PairedEarring)
				to_chat(usr, "The potara earring rings true... if you wish to fuse, you must wear it while on the same Z-level as the other earring!")
			else
				to_chat(usr, "The potara earring rings falsely... if you wish to fuse, you must pair it with another earring! Kaioshins start with two.")
		Equip()
			set category = null
			set src in usr
			if(equipped)
				equipped=0
				suffix=""
				usr.removeOverlay(/obj/overlay/clothes/PotaraEarring)
				usr.Wearing_Potara_Earrings = 0
				if(usr.Wearing_Potara_Earrings == 2)
					usr.Wearing_Potara_Earrings = 1
					usr.removeOverlay(/obj/overlay/clothes/PotaraEarrings)
					usr.removeOverlay(/obj/overlay/clothes/PotaraEarring)
					if(icon=='potararight.dmi')
						usr.updateOverlay(/obj/overlay/clothes/PotaraEarring,'potaraleft.dmi')
					else
						usr.updateOverlay(/obj/overlay/clothes/PotaraEarring,'potararight.dmi')
			else if(PairedEarring)
				equipped=1
				suffix="*Equipped*"
				if(!usr.Wearing_Potara_Earrings)
					usr.updateOverlay(/obj/overlay/clothes/PotaraEarring,icon)
					spawn checkEarringDist()
					usr.Wearing_Potara_Earrings = 1
				else
					usr.Wearing_Potara_Earrings = 2
					usr.removeOverlay(/obj/overlay/clothes/PotaraEarring)
					usr.updateOverlay(/obj/overlay/clothes/PotaraEarrings)
				to_chat(usr, "If you go near another player with the other paired earring, you'll slam together and fuse! The player with the right earring controls the body!")
			else
				equipped=1
				suffix="*Equipped*"
				if(!usr.Wearing_Potara_Earrings)
					usr.updateOverlay(/obj/overlay/clothes/PotaraEarring,icon)
					usr.Wearing_Potara_Earrings = 1
				else
					usr.Wearing_Potara_Earrings = 2
					usr.removeOverlay(/obj/overlay/clothes/PotaraEarring)
					usr.updateOverlay(/obj/overlay/clothes/PotaraEarrings)
				to_chat(usr, "Your earrings aren't paired, so there won't be a fusion.")
	proc
		checkEarringDist()
			if(!equipped) return
			var/mob/Fusee
			for(var/mob/M in view())
				if(M.Wearing_Potara_Earrings)
					for(var/obj/items/Potara_Earring/A in M.contents)
						if(PairedEarring == A&&A.equipped)
							if(M == src.loc)
							else
								Fusee = M
							break
						sleep(1)
				sleep(1)
			if(Fusee)
				var/mob/Fusor = src.loc
				if(Fusee==Fusor)
					return
				if(ismob(Fusee)&&ismob(Fusor))
					if(Fusor.fusion_on_cooldown() || Fusee.fusion_on_cooldown())
						to_chat(Fusor, "One of you is still on fusion cooldown (1 hour after a fusion ends).")
						IsFusing = 0
						return
					if(Fusor.in_active_fusion() || Fusee.in_active_fusion())
						IsFusing = 0
						return
					IsFusing = 1
					var/distance = round(get_dist(Fusor,Fusee))
					walk_to(Fusor,Fusee,distance)
					walk_to(Fusee,Fusor,distance)
					sleep(40)
					Fusor.emit_Sound('fusion.wav')
					IsFusing = 0
					equipped = 0
					Fusor.removeOverlay(/obj/overlay/clothes/PotaraEarring)
					Fusor.Fuse(Fusee,2) //the one who initiates (walks in) controls; use Pass Fusion Control to switch
					return
				else to_chat(usr, "Neither the [Fusor] or [Fusee] were mobs!")
			sleep(50)
			checkEarringDist()

obj/overlay/clothes/PotaraEarrings //specific item
	name = "PotaraEarrings" //unique name
	ID = 347 //unique ID
	icon = 'potara.dmi'
	//icon_state = "yadda"  //icon state if you need it
	EffectStart() //started after all vars are set.
		icon = container.PotaraEarringIcon
		..() //calls the original proc after you do everything.

obj/overlay/clothes/PotaraEarring //specific item
	name = "PotaraEarrings" //unique name
	ID = 347 //unique ID
	icon = 'potaraleft.dmi'
	//icon_state = "yadda"  //icon state if you need it potararight.dmi


obj/items/Potara_Earring/var
	tmp/obj/items/Potara_Earring/PairedEarring = null
	IsFusing = 0
	EarringID=1 //Used to find a pairred earring


obj/Fusion_dance/verb/Fusion_Dance()
	set category="Skills"
	if(usr.in_active_fusion())
		to_chat(usr, "You're already fused!")
		return
	var/mob/M=input("Who?") as null|mob in oview(1)
	if(!M) return
	if(M==usr) return
	if(M.in_active_fusion())
		to_chat(usr, "[M] is already fused!")
		return
	if(usr.fusion_on_cooldown() || M.fusion_on_cooldown())
		to_chat(usr, "One of you is still on fusion cooldown (1 hour after a fusion ends).")
		return
	switch(input(M,"[usr] wishes to do the Fusion Dance with you. [usr] will control the fused warrior.", "", text) in list ("No", "Yes",))
		if("Yes")
			to_chat(view(9), "<font color=yellow>[usr] fuses with [M]!")
			usr.emit_Sound('fusion.wav')
			usr.Fuse(M,1) //initiator (usr) controls