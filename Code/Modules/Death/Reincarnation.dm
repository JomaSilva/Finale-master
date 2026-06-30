mob/var/OBPMod=1

mob/var/Incarnate
mob/proc/CheckIncarnate()
	if(!Created&&client.ReincarnationBonus)
		if(ckey==client.ReincarnationBonus.ckey)
			var/Reincarnator/R = client.ReincarnationBonus
			if(R.startBPMult > 0) //reencarnacao via Enma: renasce com uma FRACAO do BP antigo (comeca pequeno e cresce de novo), sem o despejo de potential
				BP = max(BP, round(R.oldBP * R.startBPMult))
				to_chat(src, "<font color=#d8a0ff>You are reborn, carrying a faint echo of your past power. (Reincarnation)</font>")
			else
				BP += max((R.oldBP/(100/BPMod)),2*BPMod) //self-based: bonus de BP baseado so no seu BP anterior (oldBP), sem a media do servidor
				hiddenpotential += R.oldBP
				to_chat(src, "You just had a reincarnation bonus applied to this character!")
			if(godki) godki.naturalization = R.naturalization
			client.ReincarnationBonus = null //consumido uma unica vez -> nao re-aplica nem vaza pra um proximo personagem da mesma conta

mob/proc/Reincarnate(var/bpmult = 0)
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
	do_reincarnation(bpmult)
mob/proc/do_reincarnation(var/bpmult = 0)
	var/Reincarnator/A = new
	A.ckey = ckey
	A.oldBP = BP
	A.startBPMult = bpmult //>0 -> o novo personagem comeca com essa fracao do BP antigo (reencarnacao via Enma = 0.1)
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
	var/startBPMult = 0 //>0 -> reencarnacao via Enma: o novo personagem nasce com essa fracao do oldBP (0.1 = 10%), em vez do bonus legado

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