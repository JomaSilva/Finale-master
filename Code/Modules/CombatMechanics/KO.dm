mob/var/LastKO=0
mob/var/KOTimer
mob/var/KOcount
mob/Admin3/verb/Set_KO_Time_Mult()
	set category = "Admin"
	KOMult = input(usr,"Set the KO timer mult. Normal time is 400 seconds divided by your Ephysdef.","",1) as num

var/KOMult = 1

mob/proc/KO(var/KOtimer, var/ForceKO)
	set waitfor = 0
	set background = 1
	//if(Race=="Android"&&prob(95)&&!ForceKO)
		//HP = 1
		//return
	/*else if(!ForceKO&&!LastKO&&move==1||prob((1*Anger)/(LastKO+1))&&move==1)
		view(src)<<output("<font color=red>[src] has become angry, and has attained second wind!!","Chatpane.Chat")
		HP=100
		Anger=(((MaxAnger-100)/1.11)+100)
		LastKO=1600
		KOTimer=0
		return*/
	/*else */
	if(Player&&!KO/*&&ForceKO*/)
		for(var/mob/M in oview())
			if(M.check_relation(src,list("Very Good","Love")) == TRUE || M.is_friend(src))
				M.Do_Anger_Stuff() //capped, non-stacking, 2-minute rage (was M.Anger+=... which stacked)
				view(M)<<output("<font color=red>[M] has become very angry!!!","Chatpane.Chat")
				WriteToLog("rplog","[M] has become very angry    ([time2text(world.realtime,"Day DD hh:mm")])")
			if(M.check_relation(src,list("Good","Rival/Good")) == TRUE) M.StoredAnger+=20
		if(lastDamager) friend_harmed_by(lastDamager, ENMITY_FRIEND_KO) //a rival KO'd you in view of your friends -> their hatred grows
		var/mob/koFoe = lastDamager //typed handle: lastDamager is declared typeless, so read its BP through a mob ref
		if(koFoe) gain_zenkai(koFoe.BP) //Zenkai ALSO triggers on being KNOCKED OUT by a stronger foe (not only on death); the 1h cooldown stops a follow-up finishing blow from granting it twice
		//---
		if(Savable) icon_state="KO"
		emit_Sound('groundhit2.wav')
		view(src)<<output("[src] is knocked out!","Chatpane.Chat")
		WriteToLog("rplog","[src] is knocked out!    ([time2text(world.realtime,"Day DD hh:mm")])")
		KO=1
		LastKO=10000/Anger
		if(ForceKO)
			LastKO*= 0.5
		//KOTimer+=1
		train=0
		med=0
		KOcount++
		StopFightingStatus()
		if(prob(10))
			if(AbsorbDatum)
				AbsorbDatum.expell()
		if(flight)
			usr.flight=0
			if(usr.Savable) usr.icon_state=""
			usr<<"You land back on the ground."
			usr.flightspeed=0
			usr.overlayList-=usr.FLIGHTAURA
			overlaychanged=1
			usr.isflying=0
			emit_Sound('buku_land.wav')
			usr.overlayList-=usr.FLIGHTAURA
			overlaychanged=1
		for(var/obj/DB/D in contents)
			D.OnRelease()
		if(ssjdrain<=0.10&&ssj==1)
			Revert(1)
		else Revert()
		ClearPowerBuffs()
		blasting=0
		overlayList-='Blast Charging.dmi'
		overlaychanged=1
		firable=1
		//Stone Mask functionality
		for(var/obj/items/Equipment/Accessory/Stone_Mask/A in usr)
			if(A.equipped)
				view(usr)<<"<font color=yellow>Stone tendrils sprout from [usr]'s mask, stabbing directly into their head!</font>"
				sleep(20)
				if(!usr.IsAVampire&&usr.CanEat&&!usr.IsAWereWolf)
					createShockwavemisc(loc,4)
					sleep(30)
					Un_KO()
					view(usr)<<"<font color=yellow>[usr] stands as a bizarre light emanates from their body!!</font>"
					createDustmisc(loc,5)
					sleep(30)
					createLightningmisc(loc,6)
					usr.Vampirification()
					view(usr)<<"<font color=red>[usr] has become a Vampire!!!</font>"
					break
				else if(usr.IsAVampire) //If you're some gay vampire trying to make a fashion statement with ancient rock masks, nothing will happen. Since you're undead, you still live too.
					usr<<"Due to already being a vampire, the Stone Mask has no effect on you. Those tendrils still sting though..."
					break
				else //if for whatever reason the Stone Mask does literally nothing to you and you're not a vamp, you die bro.
					usr<<"A strange energy courses through your body, though nothing of note happens. Perhaps its from the stone tendrils tearing into your brain. Have you noticed the blood loss yet?"
					sleep(20)
					usr<<"<font color=red>Your grip on reality begins to fade...It seems your story will end here.</font>"
					sleep(30)
					Death()
					break
				break
		if(KOtimer>0)
			spawn(10*KOtimer*KOMult)
			Un_KO()
		else if(!KOtimer)
			spawn(rand(2000,2500)*KOMult) //~5x longer KO recovery to match the slower natural healing
			Un_KO()
	else if(isNPC)
		KO=1
		move=0
		emit_Sound('groundhit2.wav')
		view(src)<<output("[src] is knocked out!","Chatpane.Chat")
		spawn(rand(3000,5000)) //~5x longer NPC KO recovery
		Un_KO()
mob/proc/Un_KO(var/angery)
	if(Player&&KO)
		move=1
		attackable=1
		if(Savable) icon_state=""
		attacking=0
		blasting=0
		SpreadHeal(25,1,1)
		if(angery)
			Anger-=0.5*MaxAnger
		else
			view(src)<<output("[src] regains consciousness.","Chatpane.Chat")
			if(KOTimer>1)
				if(prob(5))
					StoredAnger+=10
					usr<<"[usr] gets angry from being knocked out so much!"
					LastKO=100000
					KOTimer=0
			if(KOTimer>3)
				if(prob(15))
					StoredAnger+=10
					usr<<"[usr] gets angry from being knocked out so much!"
					LastKO=100000
					KOTimer=0
		ClearPowerBuffs()
		KO=0
	if((isNPC)&&KO)
		KO=0
		SpreadHeal(25,1,1)
		move=1
		view(src)<<output("[src] regains consciousness.","Chatpane.Chat")
		step_rand(src)