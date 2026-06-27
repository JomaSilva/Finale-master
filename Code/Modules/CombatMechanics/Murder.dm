mob/proc/MurderTheFollowing(var/isFinishing,var/mob/M as mob) //isFinishing means if the other player is like up close, I.E. finish proc and attack proc.
	if(finishing)
		usr <<"You're already finishing someone."
		return
	if(M&&!M.Player&&!M.client)
		finishing=1
		emit_Sound('groundhit2.wav')
		view(6)<<output("[M] was just killed by [usr]!","Chatpane.Chat")
		if(istype(M,/mob/npc/pet))
			for(var/mob/A in oview()) //A being the friend looking...
				if(M:relation[A.signature] > 60)
					A.Do_Anger_Stuff()
					view(A)<<output("<font color=red>You notice [A] has become enraged!!!","Chatpane.Chat")
					WriteToLog("rplog","[A] has become angry   	([time2text(world.realtime,"Day DD hh:mm")])")
					continue
		M.mobDeath()
		sleep(Eactspeed)
		finishing=0
		return
	if(isFinishing==0)
		finishing = 1
		view(6)<<"[usr] is threatening [M]'s life! (Even if [M] moves or gets away, in ten seconds [usr] can choose to kill.)"
		for(var/mob/A in oview()) //A being the friend looking...
			var/DyerIsGood=0
			if(A.check_relation(M,list("Good","Very Good")) == TRUE) DyerIsGood=1
			if(DyerIsGood)
				A.Do_Anger_Stuff()
				view(A)<<output("<font color=red>You notice [A] has become enraged!!!","Chatpane.Chat")
				WriteToLog("rplog","[A] has become angry   	([time2text(world.realtime,"Day DD hh:mm")])")
				continue
		sleep(100)
		if(alert("Kill [M]?","Kill [M]","Yes","No")=="No"||KO||!move)
			usr << "You either chose not to kill, or you were forced out of it."
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
				WriteToLog("rplog","[A] has become EXTREMELY angry    ([time2text(world.realtime,"Day DD hh:mm")])")
	emit_Sound('groundhit2.wav')
	buudead=0
	Death()

mob/proc/killer_stuff(var/mob/M)
	if(M.Player)
		view(6,M)<<output("[M] was just killed by [usr]([displaykey])!","Chatpane.Chat")
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
				usr<<"By killing the former King Vegeta, you have become the new King Vegeta!"
				M<<"You have lost your throne and [usr] becomes the new King Vegeta."
				King_of_Vegeta=key
				Rank_Verb_Assign()
			else for(var/mob/A) if(A.Race=="Saiyan"&&!A.dead) if(A.Prince|A.Princess)
				King_of_Vegeta=A.key
				A<<"<font color=yellow>The King of Vegeta has been murdered, you have inherited the throne because you are the next in line of the Royal Family of Vegeta!"
				A.Rank_Verb_Assign()
				break
			else King_of_Vegeta=null
		if(!dead) if(Race=="Frost Demon"|Class=="Frost Demon")
			if(Frost_Demon_Lord==M.key)
				usr<<"You have become the new Frost Demon Lord!"
				M<<"You have lost your status as Frost Demon Lord to [usr]."
				Frost_Demon_Lord=key
	else if(M) if(isNPC)
		emit_Sound('groundhit2.wav')
		view(6)<<output("[M] was just killed by [usr]!","Chatpane.Chat")
		M.Death()

mob/var/tmp/rageExpire = 0 //world.time at which the current rage spike ends (rage lasts at most 2 minutes)
mob/proc/Do_Anger_Stuff()
	Anger = max(Anger, MaxAnger) //take the HIGHER of current/new rage — never stack, sum, or multiply (kills the 20x anomaly)
	rageExpire = world.time + 1200 //(re)start the 2-minute rage timer (1200 deciseconds)
	StoredAnger=100