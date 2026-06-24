//this'll be a wip, but eventually we should have a settings datum for global savings. Below is a dirty way of doing it.
proc/Save_Settings()
	var/savefile/P=new("PersistantSettings")
	var/savefile/T=new("PerWipeSettings")
	//per wipe settings
	T["autorevivetimer"]<<autorevivetimer
	T["globalpoints"]<<globalpoints
	T["Hours"]<<Hours
	T["Days"]<<Days
	T["Month"]<<Month
	T["FusionDatabase"]<<FusionDatabase
	T["AscensionStarted"]<<AscensionStarted
	T["PlanetDisableList"]<<PlanetDisableList
	T["bresolveseed"]<<bresolveseed
	T["BPList"]<<BPList
	T["BPModList"]<<BPModList
	T["KiTotalList"]<<KiTotalList
	T["LastTimeList"]<<LastTimeList
	T["BPSD"]<<BPSD
	T["BPSkew"]<<BPSkew
	T["EmeraldInAltar"]<<EmeraldInAltar
	T["hasSword"]<<hasSword
	T["timecapboost"]<<timecapboost
	T["expelled_people"]<<expelled_people
	T["sealed_released_sigs"]<<sealed_released_sigs
	T["techMult"] << techMult
	T["ghetto_star_exist"] << ghetto_star_exist
	T["ghetto_star_own"] << ghetto_star_own
	T["ghetto_star_last_check"] << ghetto_star_last_check
	T["reibi_list"] << reibi_list
	T["p_power_words"] << p_power_words
	T["t_power_words"] << t_power_words
	T["e_power_words"] << e_power_words
	T["power_words_p_activations"] << power_words_p_activations
	T["power_words_t_activations"] << power_words_t_activations
	T["power_words_e_activations"] << power_words_e_activations
	T["generatedspells"] << generatedspells
	T["legend_poll"] << legend_poll
	T["reincarnationver"] << reincarnationver
	T["alchemyprototypes"]<<alchemyprototypes
	T["mupdate"]<<mupdate
	//
	P["world.fps"]<<world.fps
	P["Dragonball_Start"]<<Dragonball_Start
	P["Maximum_Addresses_Allowed"]<<Maximum_Addresses_Allowed
	P["TurnOffAscension"]<<TurnOffAscension
	P["GlobalBPBoost"]<<GlobalBPBoost
	P["TransformedBPBoost"]<<TransformedBPBoost
	P["GotoSpawnpoint"]<<GotoSpawnpoint
	P["AutorankOn"]<<AutorankOn
	P["WipeRanks"]<<WipeRanks
	P["AutoReviveOn"]<<AutoReviveOn
	P["npcspawnson"]<<npcspawnson
	P["RevivalShardsEnabled"]<<RevivalShardsEnabled
	P["mapenabled"]<<mapenabled
	P["GlobalWishMod"]<<GlobalWishMod
	P["GlobalBallTimeMod"]<<GlobalBallTimeMod
	P["GlobalBPBoost"]<<GlobalBPBoost
	P["GlobalGravGain"]<<GlobalGravGain
	P["globalKiDamage"]<<globalKiDamage
	P["KOMult"]<<KOMult
	P["BreedFunnies"]<< BreedFunnies
	P["RapeSet"] << RapeSet
	P["buildable"] << buildable
	P["canplanetdestroy"]<<canplanetdestroy
	P["gravitycap"]<<gravitycap
	P["uploadlimted"]<<uploadlimted
	P["globalmeleeattackdamage"]<<globalmeleeattackdamage
	P["GlobalResourceGain"]<<GlobalResourceGain
	P["globalmeleeattackspeed"]<<globalmeleeattackspeed
	P["globalKiDrainMod"]<<globalKiDrainMod
	P["globalfoodmod"]<<globalfoodmod
	P["globalstamdrain"]<<globalstamdrain
	P["trainmult"] << trainmult
	P["GlobalKiExpRate"] << GlobalKiExpRate
	P["GlobalLibrary"] << GlobalLibrary
	P["catchupcap"] << catchupcap
	P["GainsRate"] << GainsRate
	P["gravBalance"] << gravBalance
	P["globalkiarmormod"] << globalkiarmormod
	P["OOC_anon"] << OOC_anon
	P["banned_skill_list"] << banned_skill_list
	P["global_spar_gain"] << global_spar_gain
	P["global_train_gain"] << global_train_gain
	P["global_med_gain"] << global_med_gain
	P["train_med_to_hp"] << train_med_to_hp
	P["npc_sparring"] << npc_sparring
	P["global_net_cap"] << global_net_cap
	P["server_desc"] << server_desc
	P["godki_at"] << godki_at
	P["godki_ssj_cap"] << godki_ssj_cap
	P["max_godki_tier"] << max_godki_tier
	P["godki_cap"] << godki_cap
	P["gt_mode"] << gt_mode
	P["client_save_list"] << client_save_list
	P["GlobalEXPRate"] << gexprate
	P["LifeskillCap"] << lifeskillcap
	P["original_genome_list"] << original_genome_list
	saveRacials(P)
	//
	var/savefile/B = new("Bank_Save")
	B["BankHolders"] << BankHolders
proc/Load_Settings()
	set waitfor = 0
	set background = 1
	if(fexists("PersistantSettings"))//persistant settings
		var/savefile/P=new("PersistantSettings")
		P["Maximum_Addresses_Allowed"]>>Maximum_Addresses_Allowed
		P["GotoSpawnpoint"]>>GotoSpawnpoint
		P["AutorankOn"]>>AutorankOn
		P["WipeRanks"]>>WipeRanks
		P["AutoReviveOn"]>>AutoReviveOn
		P["npcspawnson"]>>npcspawnson
		P["mapenabled"]>>mapenabled
		P["RevivalShardsEnabled"]>>RevivalShardsEnabled
		P["GlobalWishMod"]>>GlobalWishMod
		P["GlobalBallTimeMod"]>>GlobalBallTimeMod
		P["GlobalBPBoost"]>>GlobalBPBoost
		P["GlobalGravGain"]>>GlobalGravGain
		P["globalKiDamage"]>>globalKiDamage
		P["GlobalBPBoost"]>>GlobalBPBoost
		P["globalmeleeattackdamage"]>>globalmeleeattackdamage
		P["GlobalResourceGain"]>>GlobalResourceGain
		P["TransformedBPBoost"]>>TransformedBPBoost
		P["TurnOffAscension"]>>TurnOffAscension
		P["KOMult"]>>KOMult
		P["BreedFunnies"]>> BreedFunnies
		P["RapeSet"] >> RapeSet
		P["buildable"] >> buildable
		P["canplanetdestroy"]>>canplanetdestroy
		P["gravitycap"]>>gravitycap
		P["uploadlimted"]>>uploadlimted
		P["globalmeleeattackspeed"]>>globalmeleeattackspeed
		P["globalKiDrainMod"]>>globalKiDrainMod
		P["globalfoodmod"]>>globalfoodmod
		P["globalstamdrain"]>>globalstamdrain
		P["world.fps"]>>world.fps
		P["trainmult"]>>trainmult
		P["GlobalKiExpRate"] >> GlobalKiExpRate
		P["GlobalLibrary"] >> GlobalLibrary
		P["Dragonball_Start"] >> Dragonball_Start
		P["catchupcap"] >> catchupcap
		P["GainsRate"] >> GainsRate
		P["gravBalance"] >> gravBalance
		P["globalkiarmormod"] >> globalkiarmormod
		P["OOC_anon"] >> OOC_anon
		P["banned_skill_list"] >> banned_skill_list
		P["global_spar_gain"] >> global_spar_gain
		P["global_train_gain"] >> global_train_gain
		P["global_med_gain"] >> global_med_gain
		P["train_med_to_hp"] >> train_med_to_hp
		P["npc_sparring"] >> npc_sparring
		P["global_med_gain"] >> global_med_gain
		P["global_net_cap"] >> global_net_cap
		P["server_desc"] >> server_desc
		P["client_save_list"] >> client_save_list
		P["GlobalEXPRate"] >> gexprate
		if(isnull(gexprate)) gexprate = 1
		P["LifeskillCap"] >> lifeskillcap
		P["godki_at"] >> godki_at
		P["godki_ssj_cap"] >> godki_ssj_cap
		P["max_godki_tier"] >> max_godki_tier
		P["godki_cap"] >> godki_cap
		P["gt_mode"] >> gt_mode
		P["original_genome_list"] >> original_genome_list
		if(isnull(GlobalLibrary)) GlobalLibrary=new/list()
		loadRacials(P)

	if(fexists("PerWipeSettings"))//per wipe settings
		var/savefile/T=new("PerWipeSettings")
		T["globalpoints"]>>globalpoints
		T["autorevivetimer"]>>autorevivetimer
		T["Hours"]>>Hours
		T["Days"]>>Days
		T["Month"]>>Month
		T["FusionDatabase"]>>FusionDatabase
		T["AscensionStarted"]>>AscensionStarted
		T["PlanetDisableList"]>>PlanetDisableList
		T["BPList"]>>BPList
		T["BPModList"]>>BPModList
		T["KiTotalList"]>>KiTotalList
		T["LastTimeList"]>>LastTimeList
		T["BPSD"]>>BPSD
		T["BPSkew"]>>BPSkew
		T["EmeraldInAltar"] >> EmeraldInAltar
		T["hasSword"] >> hasSword
		T["timecapboost"]>>timecapboost
		T["expelled_people"]>>expelled_people
		T["sealed_released_sigs"]>>sealed_released_sigs
		T["techMult"] >> techMult
		T["ghetto_star_exist"] >> ghetto_star_exist
		T["ghetto_star_own"] >> ghetto_star_own
		T["ghetto_star_last_check"] >> ghetto_star_last_check
		T["reibi_list"] >> reibi_list
		T["p_power_words"] >> p_power_words
		T["t_power_words"] >> t_power_words
		T["e_power_words"] >> e_power_words
		T["power_words_p_activations"] >> power_words_p_activations
		T["power_words_t_activations"] >> power_words_t_activations
		T["power_words_e_activations"] >> power_words_e_activations
		T["generatedspells"] >> generatedspells
		T["global_net_cap"] >> global_net_cap
		T["legend_poll"] >> legend_poll
		T["reincarnationver"] >> reincarnationver
		T["mupdate"]>>mupdate
		T["alchemyprototypes"]>>alchemyprototypes
		if(isnull(reincarnationver)) reincarnationver=0
		if(isnull(BPList)) BPList=new/list()
		if(isnull(BPModList)) BPModList=new/list()
		if(isnull(KiTotalList)) KiTotalList=new/list()
		if(isnull(LastTimeList)) LastTimeList=new/list()
	if(fexists("Bank_Save"))
		var/savefile/B = new("Bank_Save")
		B["BankHolders"] >> BankHolders

mob/OwnerAdmin/verb
	Delete_Bank_Saves()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) deleted bank saves.")
		fdel("Bank_Save")
	Normal_Wipe_Server()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) used the wipe server verb")
		BPList=new/list()
		BPModList=new/list()
		KiTotalList=new/list()
		LastTimeList=new/list()
		world<<"<font color=yellow>[usr] is Ruining the server..."
		sleep(15)
		fdel("Save/")
		fdel("RANK")
		fdel("Year")
		fdel("PerWipeSettings")
		fdel("MobSave")
		fdel("ItemSave")
		fdel("MapSave")
		fdel("Bank_Save")
		sleep(1)
		world<<"<b><big><font color=yellow>Ruin Complete."
		sleep(1)
		world.Reboot()
	Wipe_Clean_Server()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) used the Clean Wipe Server verb")
		for(var/mob/M)
			M.Savable=0
			BPList.Remove(M)
			BPModList.Remove(M)
		world<<"<font color=yellow>[usr] is Ruining the server..."
		fdel("Save/")
		fdel("RANK")
		fdel("PerWipeSettings")
		fdel("PersistantSettings")
		fdel("Illegal")
		fdel("GAIN")
		fdel("ItemSave")
		fdel("MapSave")
		fdel("Year")
		fdel("MobSave")
		fdel("Bank_Save")
		world<<"<b><big><font color=yellow>Ruin Complete."
		world.Reboot()
var
	OOC_anon
	GlobalBallTimeMod = 1
	GlobalWishMod = 1
	RevivalShardsEnabled = 1
	autorevivetimer=18000
	GotoSpawnpoint = 1 //1 on, 0 off.
	canbio=0 //
	canlegendary=1 //Legendary Saiyan unlocked from the start (no admin action needed)
	candroid=0 //
	canDemigod=1 //
	canheran=1
	canalbino=1
	cansai=1 //
	canmakyo=1	//
	canhuman=1 //
	candemon=1 //
	cankai=1 //
	cannamek=1 //
	canintel=1 //
	canalien=1 //
	canchangie=1 //
	canhyb=1 //
	canyardrat=1 //
	canshape=1 //
	candoll=0 //
	cankan=1 //
	canogre=1 //
	cansaib=1 //
	canpirate=0 //
	cangeni=1 //
	canarl=1 //
	canuchiha=2 //
	canmeta=1 //
	canelite=1
	canomega=1
	candrag=1
	canmajin=1
	cangray=1
	canhermano=1
	AutorankOn=1
	WipeRanks
	AutoReviveOn=1
	npcspawnson=1
	globalpoints=0
	mapenabled=1
	EmeraldInAltar=1
	hasSword=1
	list/legend_sig = list()
	legend_pre_ssj=1
	legend_overrider=1

proc/loadRacials(var/savefile/P)
	P["canbio"]>>canbio
	P["canlegendary"]>>canlegendary
	P["candroid"]>>candroid
	P["canDemigod"]>>canDemigod //
	P["canheran"]>>canheran
	P["canalbino"]>>canalbino
	P["cansai"]>>cansai //
	P["canmakyo"]>>canmakyo	//
	P["canhuman"]>>canhuman //
	P["candemon"]>>candemon //
	P["cankai"]>>cankai //
	P["cannamek"]>>cannamek
	P["canintel"]>>canintel //
	P["canalien"]>>canalien //
	P["canchangie"]>>canchangie //
	P["canhyb"]>>canhyb //
	P["canyardrat"]>>canyardrat //
	P["canshape"]>>canshape //
	P["candoll"]>>candoll //
	P["cankan"]>>cankan //
	P["canogre"]>>canogre //
	P["cansaib"]>>cansaib //
	P["canpirate"]>>canpirate //
	P["cangeni"]>>cangeni //
	P["canarl"]>>canarl //
	P["canmeta"]>>canmeta
	P["canuchiha"]>>canuchiha
	P["canelite"]>>canelite
	P["canomega"]>>canomega
	P["candrag"]>>candrag
	P["canmajin"]>>canmajin
	P["cangray"]>>cangray
	P["canhermano"]>>canhermano
	P["legend_sig"]>>legend_sig
	P["legend_pre_ssj"]>>legend_pre_ssj
	P["legend_overrider"]>>legend_overrider
proc/saveRacials(savefile/P)
	P["canbio"]<<canbio
	P["canlegendary"]<<canlegendary
	P["candroid"]<<candroid
	P["canDemigod"]<<canDemigod //
	P["canheran"]<<canheran
	P["canalbino"]<<canalbino
	P["cansai"]<<cansai //
	P["canmakyo"]<<canmakyo	//
	P["canhuman"]<<canhuman //
	P["candemon"]<<candemon //
	P["cankai"]<<cankai //
	P["cannamek"]<<cannamek
	P["canintel"]<<canintel //
	P["canalien"]<<canalien //
	P["canchangie"]<<canchangie //
	P["canhyb"]<<canhyb //
	P["canyardrat"]<<canyardrat //
	P["canshape"]<<canshape //
	P["candoll"]<<candoll //
	P["cankan"]<<cankan //
	P["canogre"]<<canogre //
	P["cansaib"]<<cansaib //
	P["canpirate"]<<canpirate //
	P["cangeni"]<<cangeni //
	P["canarl"]<<canarl //
	P["canmeta"]<<canmeta
	P["canelite"]<<canelite
	P["canomega"]<<canomega
	P["candrag"]<<candrag
	P["canmajin"]<<canmajin
	P["cangray"]<<cangray
	P["canhermano"]<<canhermano
	P["canuchiha"]<<canuchiha
	P["legend_sig"]<<legend_sig
	P["legend_pre_ssj"]<<legend_pre_ssj
	P["legend_overrider"]<<legend_overrider
/*var
	globals/globals = new()
globals //GLOBALS not GLOBAL, global.[x] is a built in var, globals is this datum.
	AlwaysSaved
		var
			GotoSpawnpoint = 1 //1 on, 0 off.
	SometimesSaved
		var
			canbio=1 //
			canlegendary=1 //
			candroid=1 //
			canDemigod=1 //
			canheran=1
			canalbino=1
			cansai=1 //
			canmakyo=1	//
			canhuman=1 //
			candemon=1 //
			cankai=1 //
			cannamek=1 //
			canintel=1 //
			canalien=1 //
			canchangie=1 //
			canhyb=1 //
			canyardrat=1 //
			canshape=1 //
			candoll=1 //
			cankan=1 //
			canogre=1 //
			cansaib=1 //
			canpirate=0 //
			cangeni=1 //
			canarl=1 //
			canmeta=1 //
			canelite=1
			canomega=1
			candrag=1
			canmajin=1
			cangray=1
			canhermano=1
			AutorankOn=1
			WipeRanks
			AutoReviveOn=1
			npcspawnson
			globalpoints
	tmp
*/