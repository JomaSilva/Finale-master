var
	list/FusionDatabase = list()
	DanceMod = 1.5
	PotaraMod = 2.5
	FuseTimeMin = 7000 //a little more than ten minutes is the minimum fusion time
	FuseTimeMax = 36000 //lasts 1 hour at most.

mob
	var
		FuseBuff
		FuseDanceMod =1
		FPotaraMod =1
		FuseTimer = 0
		PotaraTimer //Automagically set to FuseTimeMax when it matters, but it's nice as a reminder. Potara timers take after God ki.
		FDanceClothes = 'Clothes_FusionPads.dmi'
		PotaraEarringIcon = 'potara.dmi'
		FDanceSkill = 0.25 //caps at 1.25. Increases by 0.25 each time you fuse.
		fusing=0
		tmp/mob/Fusee = null
		isnamekd=0

proc/FusionEquation(var/InputBP)
	return max((FuseTimeMax / (log(InputBP)/5.5)),FuseTimeMin)

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
				sleep rgbsuccess= input(Keeper,"Change hair color.") as color
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
			sleep Keeper.RemoveHair()
			Keeper.AddHair()
		Keeper.overlayList += FuseOverlays
		Keeper.overlaychanged=1
		if(FType==1) Keeper.updateOverlay(/obj/overlay/clothes/FusionPads)
		if(FType==2) Keeper.updateOverlay(/obj/overlay/clothes/PotaraEarrings)
	proc/undoOverlays()
		Keeper.name = OldName
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
			sleep Keeper.RemoveHair()
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
		if(Keeper&&Loser)
			LoserContributedBP = Loser.BP
			Keeper.FuseBuff += LoserContributedBP
			switch(FType)
				if(1)
					Keeper.FDanceSkill += min((Keeper.FDanceSkill+0.25),1.5)
					Loser.FDanceSkill += min((Loser.FDanceSkill+0.25),1.5)
					FusionSkill = (Keeper.FDanceSkill + Loser.FDanceSkill)/2
					PowerEqual = Keeper.expressedBP / Loser.expressedBP
					PowerEqual = min(2,PowerEqual)
					PowerEqual = (-((PowerEqual-1)**2) + 1)
					if(PowerEqual<=0.05)
						Keeper << "You botched the fusion! Your power needs to be within two times each other!"
						Loser << "You botched the fusion! Your power needs to be within two times each other!"
					else PowerEqual = 1
					Keeper.FuseDanceMod += DanceMod * FusionSkill
					Keeper.FuseTimer = FusionEquation(Keeper.expressedBP)
					if(FusionSkill<1)
						Keeper << "You botched the fusion! You need to try it again in order to get it right!"
						Loser << "You botched the fusion! You need to try it again in order to get it right!"
					spawn Keeper.FuseCheck()
				if(2)
					Keeper.FPotaraMod+= PotaraMod
				if(3)
					Loser.isnamekd = 1
					Keeper <<"You feel [Loser] deep inside you. Is this the true dose?"
			Loser.verblist += /verb/Set_Fusion_View
			Loser.verbs += /verb/Set_Fusion_View
			LoserBackupLoc = Loser.loc
			Loser.Fusee = Keeper
			IsActiveForKeeper = 1
			IsActiveForLoser = 1
			sleep(5)
			Loser.GotoPlanet("Sealed")
			Customize()
			doOverlays()
		else return

	proc/Defuse(var/Forced)
		CheckOnline()
		if(CompletelyPerm)
			return
		if(Keeper&&Loser&&IsActiveForLoser&&IsActiveForKeeper)
			switch(FType)
				if(1)//Dance
					Keeper.FuseBuff -= LoserContributedBP
					Keeper.FuseDanceMod -= DanceMod * FusionSkill
					IsActiveForKeeper = 0
					undoOverlays()
				if(2)//Potara
					if(LoseItFlag||Forced)
						Keeper.FuseBuff -= LoserContributedBP
						Keeper.FPotaraMod-= PotaraMod
						IsActiveForKeeper = 0
						undoOverlays()
				if(3)//NamekFusion
					if(LoseItFlag||Forced)
						Keeper.FuseBuff -= LoserContributedBP
						IsActiveForKeeper = 0
						Loser.isnamekd = 0
						undoOverlays()
			if(LoseItFlag||FType==1||Forced)
				Loser.verblist -= /verb/Set_Fusion_View
				Loser.verbs -= /verb/Set_Fusion_View
				Loser.loc = locate(Keeper.x,Keeper.y,Keeper.z)
				Loser.Fusee = null
				IsActiveForLoser = 0
		if(Keeper&&IsActiveForKeeper)
			if(FType!=1&&OtherReincarnated)
				var/choice = alert(usr,"Your fusion is technically permanent, and the other person has reincarnated. Do you want to cancel the potential defuse and make this truly permanent? (OOC: Changes will be part of your core character.) Even Admins can't undo this!","","No","Yes")
				if(choice=="Yes")
					CompletelyPerm = 1
					Keeper.FuseBuff -= LoserContributedBP
					if(FType==2)
						Keeper.FPotaraMod -= PotaraMod
						LoserContributedBP *= PotaraMod
					Keeper.BP += LoserContributedBP
					return
			switch(FType)
				if(1)//Dance
					Keeper.FuseBuff -= LoserContributedBP
					Keeper.FuseDanceMod -= DanceMod * FusionSkill * PowerEqual
					IsActiveForKeeper = 0
					undoOverlays()
				if(2)//Potara
					if(LoseItFlag||Forced)
						Keeper.FuseBuff -= LoserContributedBP
						Keeper.FPotaraMod-= PotaraMod
						IsActiveForKeeper = 0
						undoOverlays()
				if(3)//NamekFusion
					if(LoseItFlag||Forced)
						Keeper.FuseBuff -= LoserContributedBP
						IsActiveForKeeper = 0
						undoOverlays()
		if(Loser&&IsActiveForLoser)
			if(LoseItFlag||FType==1||Forced)
				Loser.verblist -= /verb/Set_Fusion_View
				Loser.verbs -= /verb/Set_Fusion_View
				Loser.loc = LoserBackupLoc
				Loser.Fusee = null
				IsActiveForLoser = 0
		return TRUE

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
			usr << "Defusing everyone! Offline characters will have their stats fudged!"
			for(var/datum/Fusion/F)
				if(F.IsActiveForKeeper||F.IsActiveForLoser)
					F.Defuse(1)
				world << "Deleted [F.FuseName]"
				del(F)
			FusionDatabase = list()

		if("One")
			var/choice2 = input(usr,"Which one?") in FusionDatabase
			for(var/datum/Fusion/F)
				if(F==choice2)
					if(F.IsActiveForKeeper||F.IsActiveForLoser)
						F.Defuse(1)
					world << "Deleted [F.FuseName]"
					FusionDatabase -= F
					del(F)
					break

mob/Admin2/verb/Reset_Fusion(var/mob/M)
	set category = "Admin"
	var/choice = alert(usr,"Make sure to use this on the other part of the fusion too! Also ask a level 3 to delete the fusion entirely as well from the database if you know it's malfunctioning.","","Cancel","OK")
	switch(choice)
		if("OK")
			usr << "Just in case, the fusion will attempt to defuse itself on it's own!"
			for(var/datum/Fusion/F)
				if(F.KeeperSig==signature||F.LoserSig==signature)
					if(F.IsActiveForKeeper||F.IsActiveForLoser)
						F.Defuse(1)
			M.FuseBuff = 1
			M.FuseDanceMod = 1
			M.FPotaraMod = 1
			M.verblist -= /verb/Set_Fusion_View
			M.verbs -= /verb/Set_Fusion_View
			M.Fusee = null

mob/proc/CheckFusion(var/RemoveReference)
	for(var/datum/Fusion/F in FusionDatabase)
		if(F.KeeperSig==signature) F.Keeper = src
		if(F.LoserSig==signature) F.Loser = src
	if(RemoveReference==1)
		for(var/datum/Fusion/F in FusionDatabase)
			if(F.KeeperSig==signature||F.LoserSig==signature)
				if(F.FType==1)
					F.undoOverlays()
	else if(RemoveReference==2)
		for(var/datum/Fusion/F in FusionDatabase)
			if(F.KeeperSig==signature)
				F.Keeper = src
				F.doOverlays()
				if(FuseTimer >= 1) FuseCheck()
	else for(var/datum/Fusion/F in FusionDatabase)
		if(F.KeeperSig==signature||F.LoserSig==signature)
			if(F.IsActiveForKeeper||F.IsActiveForLoser)
				F.Defuse()
			if(RemoveReference==1)
				if(F.Keeper == src)
					F.Keeper = null
				if(F.Loser == src)
					F.Loser = null


mob/proc/FuseCheck()
	while(FuseTimer)
		sleep(1)
		FuseTimer-=1
	if(FuseTimer<=0)
		CheckFusion()


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

mob/proc/Fuse(var/mob/M,var/FuType)
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

obj/Namekian_Fusion/verb/Namekian_Fusion()
mob/keyable/verb/Namekian_Fusion()
	set name = "Fusion"
	set category="Skills"
	var/mob/M=input("Who?") as null|mob in oview(1)
	if(!M) return
	if(M==usr) return
	if(M.Race!="Namekian") return
	if(fusing) return
	usr.fusing=1
	switch(input(M,"[usr] wishes to do a fusion with you, you will receive the offerer's power.", "", text) in list ("No", "Yes",))
		if("Yes")
			view(9)<<"<font color=yellow>[usr] fuses with [M]!"
			M.Fuse(usr,3)
	usr.fusing=0

mob/var/Wearing_Potara_Earrings

obj/items/Potara_Earring
	name = "Potara Earring (Left)"
	icon = 'potaraleft.dmi'
	desc = "Read the fine print: These things make you fuse with somebody else PERMANENTLY. Only admins can defuse people who have Namekian Fused and Potara Fused!"
	SaveItem = 1
	verb
		Pair_Earring(var/obj/items/Potara_Earring/A in view())
			set category = null
			set src in usr
			if(A)
				if(istype(A,/obj/items/Potara_Earring))
					if(PairedEarring)
						if(PairedEarring.PairedEarring == src)
							usr<<"The earrings are already paired!"
					A.PairedEarring = src
					PairedEarring = src
					A.icon = 'potararight.dmi'
					icon = 'potaraleft.dmi'
			else
				usr << "You need another Potara Earring to pair it!"
		Remove_Pair()
			set category = null
			set src in usr
			if(PairedEarring)
				PairedEarring.PairedEarring = null
				PairedEarring = null
				icon = 'potaraleft.dmi'
				usr << "Paired earring removed."
		Check_Pair()
			set category = null
			set src in usr
			if(PairedEarring)
				usr << "The potara earring rings true... if you wish to fuse, you must wear it while on the same Z-level as the other earring!"
			else
				usr << "The potara earring rings falsely... if you wish to fuse, you must pair it with another earring! Kaioshins start with two."
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
				usr << "If you go near another player with the other paired earring, you'll slam together and fuse! The player with the right earring controls the body!"
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
				usr<<"Your earrings aren't paired, so there won't be a fusion."
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
					IsFusing = 1
					var/distance = round(get_dist(Fusor,Fusee))
					walk_to(Fusor,Fusee,distance)
					walk_to(Fusee,Fusor,distance)
					sleep(40)
					Fusor.emit_Sound('fusion.wav')
					IsFusing = 0
					equipped = 0
					Fusor.removeOverlay(/obj/overlay/clothes/PotaraEarring)
					if(icon == 'potararight.dmi')
						Fusor.Fuse(Fusee,2)
					else
						Fusee.Fuse(Fusor,2)
					return
				else usr<<"Neither the [Fusor] or [Fusee] were mobs!"
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
	if(usr.FuseTimer)
		usr <<"You're already fused!"
		return
	var/mob/M=input("Who?") as null|mob in oview(1)
	if(!M) return
	if(M==usr) return
	switch(input(M,"[usr] wishes to do the Fusion Dance with you, you will receive the offerer's power.", "", text) in list ("No", "Yes",))
		if("Yes")
			view(9)<<"<font color=yellow>[usr] fuses with [M]!"
			usr.emit_Sound('fusion.wav')
			M.Fuse(usr,1)