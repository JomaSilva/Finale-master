mob/var/OBPMod=1

mob/var/Incarnate
mob/proc/CheckIncarnate()
	if(!Created&&client.ReincarnationBonus)
		if(ckey==client.ReincarnationBonus.ckey)
			BP += max(((AverageBP+client.ReincarnationBonus.oldBP)/(100/BPMod)),2*BPMod)
			hiddenpotential += client.ReincarnationBonus.oldBP
			if(godki) godki.naturalization = client.ReincarnationBonus.naturalization
			src << "You just had a reincarnation bonus applied to this character!"

mob/proc/Reincarnate()
	if(Fusee&&!FuseTimer)
		Fusee << "[src] made the fusion permanent."
		Fusee.BP += BP
		for(var/datum/Fusion/F)
			if(F.KeeperSig==signature||F.LoserSig==signature)
				if(F.IsActiveForKeeper||F.IsActiveForLoser)
					F.OtherReincarnated = 1
					F.IsActiveForLoser = 0
	else if(FuseTimer)
		usr << "The fusion is temporary! Wait until it's over."
		return
	src << "Don't log off. You may lose some bonuses you'd normally have. You must create a new character to claim these bonuses within this login session."
	do_reincarnation()
mob/proc/do_reincarnation()
	var/Reincarnator/A = new
	A.ckey = ckey
	A.oldBP = BP
	if(godki) A.naturalization = godki.naturalization
	src.client.ReincarnationBonus = A
	fdel(GetSavePath(src.save_path))
	SLogoffOverride = 1
	winshow(src,"Login_Pane",1)
	winshow(src,"characterpane",0)
	client.show_verb_panel=0
	var mob/lobby/B = new
	client.mob = B
	del(src)
	return
client
	var/Reincarnator/ReincarnationBonus = null

Reincarnator //You only get your old BP as potential.
	var/ckey
	var/oldBP
	var/naturalization

var/reincarnationver = 0

mob/Admin3/verb/Reincarnate_Wipe()
	set category ="Admin"
	switch(input(usr,"This will wipe only the characters. BP list (averages) and caps will be reset. Characters being wiped will have their reincarnation bonus applied to this character.","","No") in list("Yes","No"))
		if("Yes")
			reincarnationver++
			for(var/mob/M in player_list)
				spawn M.do_reincarnation()
			absolutelyfuckingdestroybplist()
			BPCap = 1
			HardCap = 1
			prevcap = 1
			timecapboost = 1