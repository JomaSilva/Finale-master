mob/var/OBPMod=1

mob/var/Incarnate
mob/proc/CheckIncarnate()
	if(!Created&&client.ReincarnationBonus)
		if(ckey==client.ReincarnationBonus.ckey)
			BP += max((client.ReincarnationBonus.oldBP/(100/BPMod)),2*BPMod) //self-based: bonus de BP baseado so no seu BP anterior (oldBP), sem a media do servidor
			hiddenpotential += client.ReincarnationBonus.oldBP
			if(godki) godki.naturalization = client.ReincarnationBonus.naturalization
			to_chat(src, "You just had a reincarnation bonus applied to this character!")

mob/proc/Reincarnate()
	var/datum/Fusion/MF = my_active_fusion()
	if(Fusee && MF && MF.FType == 3 && MF.Keeper) //passenger in a permanent (Namekian) fusion -> permanently fold your power into the controller
		MF.Keeper.FuseBuff -= MF.KeeperFuseDelta //drop the temporary doubled buff...
		MF.Keeper.BP += BP //...and absorb the partner's BP into the controller (no double-count)
		MF.CompletelyPerm = 1
		MF.OtherReincarnated = 1
		MF.IsActiveForLoser = 0
		to_chat(MF.Keeper, "[src] becomes one with you - their power is now permanently yours.")
	else if(Fusee && MF) //passenger in a temporary fusion -> can't reincarnate yet
		to_chat(usr, "The fusion is temporary! Wait until it's over.")
		return
	var/datum/Fusion/KF = active_fusion_as_keeper()
	if(KF) KF.Defuse(1) //I am the controller leaving this character -> split first so my partner is not stranded
	to_chat(src, "Don't log off. You may lose some bonuses you'd normally have. You must create a new character to claim these bonuses within this login session.")
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