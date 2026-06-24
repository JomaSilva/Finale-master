mob/var/Pregnant=0
mob/var/Parent=""
mob/var
	Parent_End=0
	canqs=0
	localrver = 0
	Parent_BP=0
	Parent_BPMod=0
	Parent_Ki=0
	Husband_BP=0
	Parent_Icon
	Parent_Race=""
	Father_Race=""
	Husband_Race=""
	Parent_Class=""
	Planet=""
	BP_Unleechable=0

//No need to add a "Check Multikeying" verb that People have on games
//This stops multikeying, This is actually the right way to do it.
//If you're doing it a different way, you're probably using "continue" in some part of it
var/list/IP_Address[] = new()//Teporary logging of IP Addresses
var/Maximum_Addresses_Allowed = 4//Only 2 person on at a time
//You can change how many People are allowed at a time by changing the number.
//Never set to 0, otherwise no one can login

client
	New()
		if(address)//If the person logging in has a address, because when you host your address is null and makes this entire thing mess up
			if(IP_Address.Find("[computer_id]") && IP_Address["[computer_id]"]>0)
				IP_Address["[computer_id]"]++//Add how many People on that address
				if(IP_Address["[computer_id]"]>Maximum_Addresses_Allowed)//Checks to see how many can login, also checks if the person is exempted from Multikey blocking.
					src<<"<font color=red>You can only have a maximum of [Maximum_Addresses_Allowed] keys on at a time per computer.</font>"//Message they get before being booted
					del(src)//Obivious...
			else
				IP_Address["[computer_id]"] += 1//When they login, they're going to have a character logged in anyway if they're not trying to multikey
		..()
	Del()
		if(address && IP_Address.Find("[computer_id]"))
			IP_Address["[computer_id]"]--//Subtract the People so they can log out and login with a different key or the same key
			if(IP_Address["[computer_id]"]<=0)//Check it
				IP_Address -= "[computer_id]"//Take their address out of it
		..()
mob/Admin3
	verb
		Change_Addresses_Allowed(n as num)
			set hidden = 1
			if(!n) n = 1
			if(n <= 0) n = 1
			Maximum_Addresses_Allowed = n
			world<<"<b>>Announcement<</b> - [Maximum_Addresses_Allowed] People can be logged in at a time with the same computer, as declared by [usr]"
mob/var
	GetPops=0
	list/verblist = list()

world
	proc
		Auto_Save()
			set background = 1
			save_char
			for(var/mob/M in mob_list) // every player in world
				if(M.client&&M.Player)
					M.Save()
			spawn(3000) goto save_char //Call autosave every 5 mins

var/list/Players=new/list //Contains the key of all who have logged in since the last reboot.
var/PlayerCount=0 //The total amount of Players who logged in since the last reboot, no repeats.
mob
	var
		Created
		Owner=0
		undelayed=0
		truehair
		returnx
		returny
		heran=0
		ver
		returnz
		screenx=22
		screeny=20
		FLIGHTAURA='Flight Aura.dmi'

obj/var/tmp/podmoving

mob/verb/Screen_Size()
	set category="Other"
	screenx=input("Enter the width of the screen, limits are 30, for now.") as num
	screeny=input("Enter the height of the screen.") as num
	if(screenx<1) screenx=1
	if(screeny<1) screeny=1
	if(screenx>30) screenx=30
	if(screeny>30) screeny=30
	client.view="[screenx]x[screeny]"
mob/var/FirstYearPower
mob/var/RaceDescription
mob/var/loggedin = 1
var/Majin
var/Bio
var/Legendary
var/temporary=0
var/cansetage=0

mob/var/tmp/Cyborg
mob
	proc/NewCharacter_Vars()
		CheckRank()
		move=1
		canmove=1 //ensure fresh characters aren't stuck (canmove is otherwise only set by attacks)
		attackable=1
		if(signiture) signature = signiture //compatibility between older versions
		attacking=0
		displaykey=ckey(key) //was 'displaykey=key'; keep it canonical so it matches ckey(ckey) used elsewhere and the save path stays consistent
		statstab=1
		CheckGodki()
		FirstYearPower=round(BP)
		BirthYear=Year
		LastYear=BirthYear
		client.view="[screenx]x[screeny]"
		OBPMod=BPMod
		EnergyCalibrate()
		BirthYear=Year
		if(client) client.show_map=1
		Savable=1
		loggedin=1
		CheckTime()
		for(var/datum/skill/tree/S in src.allowed_trees) S.login(src)
		for(var/datum/skill/S in src.learned_skills) S.login(src)
		for(var/datum/skill/tree/S in src.possessed_trees) S.login(src)
	var
		xco
		yco
		zco

mob/proc/loginTests()
	CHECK_TICK
	client.show_verb_panel=0
	loc=locate(16,13,29)
	client.show_map=1
	if(client) if(Players&&!Players.Find(key))
		PlayerCount+=1
		Players.Add(key)
	if(findtext(key,"Guest")&&findtext(key,"1"))
		src<<"Please create a BYOND Account, or if you already have one use a current one. Guest accounts are TEMPORARY. ANY LOGIN COULD BE YOUR LAST CONSIDERING YOUR SAVE FILES!"
		src<<"If you do not heed this warning, the Admins will laugh at you when you eventually migrate to an actual account and wish for your savefile back."
		//del(src)
		//return
	if(!Admin&&client) if(Bans) if(Bans.Find(client.address)|Bans.Find(key))
		src<<"<font size=5><font color=red>YOU ARE BANNED."
		del(src)
		return

mob/var/SLogoffOverride = 0
//Here's the deal with SLogoffOverride- don't fucking tick it. You change it, and you're dead to me. -Assfaggot
//Essentially logging off/logging in is incredibly important to keep shit from going sideways, this makes it so that NONE of that happens.
//Used only when changing minds, and reincarnating. SLogoffOverride also saves the offending mob.

mob/var/BlankPlayer = 0
//Blank'd player. May be used.

mob/var/MobSave = 0
//use for NPCs only to prevent weird bugs.
mob/var/tmp/LoggingOut=0 //only ticked when logging out.


mob/proc/OnLogout()
	if(key &&!(client in client_list))
		key = null
	if(isNPC) return
	if(SLogoffOverride||!Player)
		return
	if(!Created||z==30||z==31)
		del(src)
		return
	if(LoggingOut) return
	LoggingOut = 1
	DoLogoutStuff()
	loggedin=0
	OfflineSave()
	current_area?.my_mob_list -= src
	current_area?.my_player_list -= src
	loc = null //then null it
	key = null
	ckey = null
	name = null
	contents = null
	Savable = null
	SaveMob = null
	mob_list -= src
	player_list -= src
mob/proc/DoLogoutStuff()
	if(isNPC) return
	src.updateseed=resolveupdate
	clearbuffs()
	StopFightingStatus()
	for(var/obj/dungeon/nD in dun_list)nD.kick_player(src)
	for(var/obj/hotkey/H in src.Hotkeys)H.logout()
	for(var/datum/skill/S in src.learned_skills) S.logout()
	for(var/obj/Artifacts/S in src.contents)
		S.logout()
		if(S in src.contents && S.CantKeep)
			S.OnRelease()
			S.Move(locate(x,y,z))
	for(var/datum/skill/tree/S in src.allowed_trees) S.logout()
	for(var/datum/skill/tree/S in src.possessed_trees) S.logout(src)
	for(var/mob/A) if(A.Admin && A.client) if(src) A<<"[name]([displaykey]) logged out"
	for(var/obj/DB/A in contents) A.Scatter()
	for(var/obj/Modules/A in contents) A.logout()
	for(var/datum/Body/A in body) A.logout()
	for(var/obj/buff/A in src) if(!A.persistant) A.DeBuff()
	for(var/mob/npc/pet/nP in out_mobs) nP.comp_obj_ref.remove_linked_mob() //remove mobs
	CheckFusion(1)
	clearbuffs()
	checkReibi()
	for(var/obj/DB/O in contents) O.loc=locate(x,y,z)
	for(var/mob/npc/Splitform/Z) if(Z.displaykey==key)
		del(Z)
		splitformCount=0
	LastYear=Year
	src.clearbuffs()

mob/proc
	OnLogin(var/skipspecial)
		if(BlankPlayer)
			return
		CheckFusion(2)
		Savable=1
		if(isnull(skipspecial))
			CHECK_TICK
			for(var/datum/Body/A in body) A.login(src)
			for(var/obj/Modules/A in contents) A.login(src)
			for(var/obj/hotkey/H in src.Hotkeys)H.login(src)
			for(var/datum/skill/tree/S in src.allowed_trees) S.login(src)
			for(var/datum/skill/S in src.learned_skills) S.login(src)
			for(var/obj/Artifacts/S in src.contents) S.login(src)
			for(var/datum/skill/tree/S in src.possessed_trees) S.login(src)
			verbs+=verblist
			if(KO)
				KO = 0
				KO(10, 1)
			if(signiture) signature = signiture //compatibility between older versions
			if(!signature)
				var/pt1=num2text(rand(1,999),3)
				var/insert1=num2text(rand(50,99),2)
				var/pt2=num2text(rand(1,999),3)
				var/insert2=num2text(rand(20,30),2)
				signature=addtext(pt1,insert1,pt2,insert2)
			if(isSealed) spawn TestEscape()
			spawn
				if(absorber_effectiveness!=1)
					spawn(9000) absorber_effectiveness=1
				if(z == 25)
					if(deathregentimer)
						sleep(deathregentimer)
						deathregentimer=0
					if(deathregenx&&deathregeny&&deathregenz)
						loc = locate(deathregenx,deathregeny,deathregenz)
					else GotoPlanet(spawnPlanet)
				if(signature in expelled_people)
					GotoPlanet(spawnPlanet)
					expelled_people -= signature
				if(signature in sealed_released_sigs)
					GotoPlanet(spawnPlanet)
					expelled_people -= signature
			checkReibi()
			if(switchx|switchy|switchz)
				Created=1
				loc=locate(switchx,switchy,switchz)
			if(client) client.view="[screenx]x[screeny]"
			spawn if(Apeshit)
				Apeshit_Revert()
				Apeshit()
			spawn CheckStyle()
			var/hasZenni
			for(var/obj/Zenni/Z in src.contents) hasZenni = 1
			if(!hasZenni) contents+=new/obj/Zenni

			check_hotkeys()
		if(client) if(src.client.address == world.address||src.key == world.host)
			Owner_Admin_Give()
			Admin=6
			Owner=1
		CHECK_TICK
		if(storedname) name = storedname
		Player=1
		loggedin=1
		if(GravMastered>gravitycap)
			GravMastered=gravitycap
		overlayList-='Blast Charging.dmi'
		overlaychanged=1
		verbs+=typesof(/mob/default/verb)
		Keyableverbs+=typesof(/mob/default/verb)
		Check_Equipment() //can lag
		CheckGodki()
		if(IsAVampire||IsAWereWolf)
			assignverb(/mob/keyable/verb/Bite)
		if(needs_manual_custom) //Handles logging into clones for the first time.
			CustomizeFurther()
			StatRace(Race)
			if(Race=="Android") Generate_Droid_Parts()
			NewCharacter_Vars()
			NewCharacterStuff()
			HandleLevel()
			generatetrees(1)
			generatetrees(0)
		//else generatetrees(1)
		Rank_Verb_Assign()
		invisibility=0
		current_area = GetArea()
		AdminCheck()
		AgeCheck()
		CheckGodki()
		CheckTime()
		if(Created && (isnull(loc) || z == 29 || z == 30)) //limbo recovery: never leave a finished character in the lobby/creation void or at a null location
			if(!spawnPlanet) spawnPlanet = "Earth"
			GotoPlanet(spawnPlanet,1)
			if(isnull(loc) || z == 29 || z == 30) //still stuck? hard fallback to ANY enabled spawnpoint
				for(var/obj/SpawnPoint/SP in obj_list)
					if(!SP.Disabled)
						loc = locate(SP.x,SP.y,SP.z)
						break
			current_area = GetArea()
		spawn(5) TryStats()
		CheckIncarnate()
		update_my_contact()
		spawn(10) if(reincarnationver != localrver) do_reincarnation()

mob/verb/DBGState()
	set category = "Other"
	set name = "DBG State"
	src << "MOVE: canmove=[canmove] move=[move] turnlock=[turnlock] gravParalysis=[gravParalysis] Guiding=[Guiding] Frozen=[Frozen] KBParalysis=[KBParalysis] omegastun=[omegastun]"
	src << "GRAV: mobTime=[mobTime] totalTime=[totalTime] Planetgrav=[Planetgrav] gravmult=[gravmult] GravMastered=[GravMastered]"
	src << "ANGER: Anger=[Anger] MaxAnger=[MaxAnger] baseAnger=[baseAnger] Ewillpower=[Ewillpower] angerMod=[angerMod] Emotion=[Emotion]"
	src << "POS: z=[z] x=[x] y=[y] Race=[Race] dead=[dead]"
