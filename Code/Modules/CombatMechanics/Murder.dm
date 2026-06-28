mob/proc/MurderTheFollowing(var/isFinishing,var/mob/M as mob) //isFinishing means if the other player is like up close, I.E. finish proc and attack proc.
	if(finishing)
		to_chat(usr, "You're already finishing someone.")
		return
	if(M&&!M.Player&&!M.client)
		finishing=1
		emit_Sound('groundhit2.wav')
		view(6)<<output("[M] was just killed by [usr]!","Chatpane.Chat")
		chatcast(view(6), "[M] was just killed by [usr]!", "combat")
		if(istype(M,/mob/npc/pet))
			for(var/mob/A in oview()) //A being the friend looking...
				if(M:relation[A.signature] > 60)
					A.Do_Anger_Stuff()
					view(A)<<output("<font color=red>You notice [A] has become enraged!!!","Chatpane.Chat")
					chatcast(view(A), "<font color=red>You notice [A] has become enraged!!!", "combat")
					WriteToLog("rplog","[A] has become angry   	([time2text(world.realtime,"Day DD hh:mm")])")
					continue
		M.mobDeath()
		sleep(Eactspeed)
		finishing=0
		return
	if(isFinishing==0)
		finishing = 1
		to_chat(view(6), "[usr] is threatening [M]'s life! (Even if [M] moves or gets away, in ten seconds [usr] can choose to kill.)")
		for(var/mob/A in oview()) //A being the friend looking...
			var/DyerIsGood=0
			if(A.check_relation(M,list("Good","Very Good")) == TRUE) DyerIsGood=1
			if(DyerIsGood)
				A.Do_Anger_Stuff()
				view(A)<<output("<font color=red>You notice [A] has become enraged!!!","Chatpane.Chat")
				chatcast(view(A), "<font color=red>You notice [A] has become enraged!!!", "combat")
				WriteToLog("rplog","[A] has become angry   	([time2text(world.realtime,"Day DD hh:mm")])")
				continue
		sleep(100)
		if(alert("Kill [M]?","Kill [M]","Yes","No")=="No"||KO||!move)
			to_chat(usr, "You either chose not to kill, or you were forced out of it.")
			return
		if(!M.immortal)
			killer_stuff(M)
			sleep(Eactspeed)
			finishing=0
		else view(6)<<output("[usr] tries to finish [M] off, but they won't die!","Chatpane.Chat")
	else if(isFinishing==1)
		killer_stuff(M)
		sleep(Eactspeed)
		finishing=0

mob/verb/Finish()
	set category="Skills"
	for(var/mob/M in get_step(src,dir)) if(M.attackable&&!med&&!train&&M.KO&&move)
		MurderTheFollowing(0,M)

mob/var/zenkaiReady = 0 //world.realtime when Zenkai may next trigger (1 hour cooldown). PERSISTENT (not tmp) + realtime so a logout/login can't reset it and a world reboot can't wrongly block it.
mob/proc/death_stuff(inputPl)
	gain_zenkai(inputPl) //Zenkai from being KILLED by a stronger foe (inputPl = killer's BP). KO defeats are handled in KO().
	//Onlooker ANGRY
	for(var/mob/A in view()) //A being the friend looking...
		var/DyerIsGood=0
		if(!isNPC)
			if(A.check_relation(src,list("Good","Very Good")) == TRUE || A.is_friend(src)) DyerIsGood=1
			if((DyerIsGood))
				A.Do_Anger_Stuff()
				view(A)<<output("<font color=red>You notice [A] has become EXTREMELY enraged!!!","Chatpane.Chat")
				chatcast(view(A), "<font color=red>You notice [A] has become EXTREMELY enraged!!!", "combat")
				WriteToLog("rplog","[A] has become EXTREMELY angry    ([time2text(world.realtime,"Day DD hh:mm")])")
	emit_Sound('groundhit2.wav')
	buudead=0
	Death()

mob/proc/killer_stuff(var/mob/M)
	if(M.Player)
		view(6,M)<<output("[M] was just killed by [usr]([displaykey])!","Chatpane.Chat")
		chatcast(view(6,M), "[M] was just killed by [usr]([displaykey])!", "combat")
		WriteToLog("rplog","[M] was just killed by [usr]([displaykey])    ([time2text(world.realtime,"Day DD hh:mm")])")
		for(var/mob/A in view()) //A being the friend looking...
			if(A.isNPC && istype(A,/mob/npc/pet))
				var/mob/npc/pet/nP = A
				if(nP.relation["[M.signature]"] > 60)
					nP.owner_ref = M //if you have a pet who likes a person and use them against that person... well they may temporarily not be your pet anymore.
					nP.cur_own_sig = M.signature
					nP.target = src
					nP.get_pissed()
					spawn nP.chaseState()
		M.death_stuff(BP)
		M.friend_harmed_by(usr, ENMITY_FRIEND_KILL) //a rival killing you embitters your nearby friends
		if(!dead) if(King_of_Vegeta==M.key)
			if(Race=="Saiyan")
				to_chat(usr, "By killing the former King Vegeta, you have become the new King Vegeta!")
				to_chat(M, "You have lost your throne and [usr] becomes the new King Vegeta.")
				King_of_Vegeta=key
				Rank_Verb_Assign()
			else for(var/mob/A) if(A.Race=="Saiyan"&&!A.dead) if(A.Prince|A.Princess)
				King_of_Vegeta=A.key
				to_chat(A, "<font color=yellow>The King of Vegeta has been murdered, you have inherited the throne because you are the next in line of the Royal Family of Vegeta!")
				A.Rank_Verb_Assign()
				break
			else King_of_Vegeta=null
		if(!dead) if(Race=="Frost Demon"|Class=="Frost Demon")
			if(Frost_Demon_Lord==M.key)
				to_chat(usr, "You have become the new Frost Demon Lord!")
				to_chat(M, "You have lost your status as Frost Demon Lord to [usr].")
				Frost_Demon_Lord=key
	else if(M) if(isNPC)
		emit_Sound('groundhit2.wav')
		view(6)<<output("[M] was just killed by [usr]!","Chatpane.Chat")
		chatcast(view(6), "[M] was just killed by [usr]!", "combat")
		M.Death()

mob/var/tmp/rageExpire = 0 //world.time at which the current rage spike ends (rage lasts at most 2 minutes)
mob/var/tmp/rageCinematicCD = 0 //world.time gate so the rage cinematic + theme never replay back-to-back
mob/proc/Do_Anger_Stuff()
	var/wasRaging = (rageExpire > world.time) //already mid-rage? then this is just a refresh, not a fresh eruption
	Anger = max(Anger, MaxAnger) //take the HIGHER of current/new rage — never stack, sum, or multiply (kills the 20x anomaly)
	rageExpire = world.time + 1200 //(re)start the 2-minute rage timer (1200 deciseconds)
	StoredAnger=100
	//ENTERING the rage (extremely angry) -> shockwave burst + Gohan's anger theme. BUT if this rage can power them
	//UP a form (SSJ/SSJ2), the transformation owns the moment: skip the anger cinematic and let the transform
	//cinematic + theme play instead (the rage cinematic is ONLY for when the anger unlocks nothing).
	if(!wasRaging && client && !anger_will_transform()) AngerCinematic()

//Would this rage let the character ascend a form right now (so the transformation should own the cinematic)?
//Called right after Do_Anger_Stuff set Anger=MaxAnger, i.e. the character IS "Very Angry", so the Emotion-gated
//first-unlock (Heran) AND an already-unlocked ascension both count. Covers the SSJ/SSJ2 tiers the user named.
mob/proc/anger_will_transform()
	if(TurnOffAscension && !AscensionAllowed) return FALSE
	var/heran = (Race=="Heran" || Parent_Race=="Heran") //Heran RAGE-UNLOCKS its first SSJ/SSJ2 (Transformation Controls.dm)
	var/saiyanish = (Race=="Saiyan" || Parent_Race=="Saiyan" || canSSJ || heran || (genome && genome.race_percent("Saiyan") >= 25))
	if(!saiyanish) return FALSE
	if(ssj==0 && BP>=ssjat && (hasssj || heran)) return TRUE   //-> Super Saiyan (already unlocked, or rage-unlocks it)
	if(ssj==1 && BP>=ssj2at/6 && (hasssj2 || heran)) return TRUE //-> SSJ2 / Ultra SSJ
	return FALSE

//Rage cinematic: a storm of shockwaves erupting AROUND the enraged character + a red aura flash, and the
//Gohan anger theme starts playing (ducks battle music for the track). Fired when a player first becomes
//extremely angry (Do_Anger_Stuff). Non-blocking so it never freezes the player mid-fight.
mob/proc/AngerCinematic()
	set waitfor = 0
	if(!client) return //players only
	if(rageCinematicCD > world.time) return
	rageCinematicCD = world.time + 600
	emit_Sound('chargeaura.wav')
	//file()+full path: a RUNTIME filename does NOT resolve via FILE_DIR, and the apostrophe in "Gohan's" can't live in a 'literal'.
	//emit_RageMusic plays on the dedicated rage channel so a later transformation theme silences it (transform wins).
	emit_RageMusic(file("Sounds/Music/Dragon Ball Z - Gohan's Anger Theme   Epic Rock Cover.mp3"), 2451) //~245s rage theme; ducks battle music
	to_chat(view(src), "<font color=red><b>*[src]'s fury erupts, blasting shockwaves out in every direction!*</b></font>", "combat")
	var/image/I = image(icon='Aurabigcombined.dmi') //a red rage aura flash
	I.plane = 7
	I.color = "#ff2a2a"
	overlayList += I
	overlaychanged = 1
	for(var/cyc = 1 to 6) //waves of shockwaves radiating AROUND them, ground tremors, dust
		createShockwavemisc(loc, rand(2,4))
		spawn for(var/turf/T in view(rand(2,4), src))
			if(prob(18)) createShockwavemisc(T, rand(1,2))
		createDustmisc(loc, rand(1,3))
		if(cyc % 2 == 0) spawn Quake()
		sleep(5)
	createCrater(loc, 2)
	Quake()
	emit_Sound('powerup.wav')
	sleep(20)
	overlayList -= I
	overlaychanged = 1