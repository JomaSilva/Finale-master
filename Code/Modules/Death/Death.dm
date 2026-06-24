mob
	var
		KeepsBody //If this is 1 you keep your body when dead.
		deathcounter//count of your deaths
		tmp/isdying //prevents death() proc from being repeated over and over.
mob/proc/Death()
	if(isdying) return
	isdying = 1
	Revert()
	if(last_attkd_sig && IsInFight)
		for(var/mob/M in player_list)
			if(last_attkd_sig == M.signature && M.IsInFight && M in LocalFighterList)
				M.killer_stuff(src)
				break
	StopFightingStatus()
	for(var/mob/A in view(src)) if(A.grabbee==src)
		view()<<"[A] is forced to release [A.grabbee]!"
		A.grabbee=null
		A.grabMode=0
		A.attacking=0
	if(!dead&&!istype(src,/mob/npc/Enemy/Zombie))
		for(var/mob/Z in range(40))
			if(istype(Z,/mob/npc/Enemy/Zombie))
				var/zombies=0
				for(var/mob/npc/Enemy/Zombie/A) zombies+=1
				if(zombies<100)
					var/mob/A=new/mob/npc/Enemy/Zombie
					A.BP=BP*2.5
					A.zenni=zenni*0.1
					A.loc=loc
					A.movespeed=rand(1,10)
					A.BP*=A.movespeed
					A.overlayList.Add(overlayList)
					A.overlaychanged=1
					A.name="[name] zombie"
				createZombies(2,peakexBP,x,y,z)
			break
		if(Mutations)
			Mutations=0
			var/amount=rand(2,4)
			while(amount)
				amount-=1
				var/zombies=0
				for(var/mob/npc/Enemy/Zombie/A) zombies+=1
				if(zombies<100)
					var/mob/A=new/mob/npc/Enemy/Zombie
					A.BP=BP*2.5
					A.zenni=zenni*0.1
					A.loc=loc
					A.movespeed=rand(1,10)
					A.BP*=A.movespeed
					A.overlayList.Add(overlayList)
					A.overlaychanged=1
					A.name="[name] zombie"
			createZombies(2,peakexBP,x,y,z)
	var/DidDie=FALSE
	if(!dead)
		GenerateCorpse()
		DidDie = TestDeathRegen()
	Check_Equipment() //can lag
	if(DidDie||dead)
		if(Player)
			KO(-1)
			sleep(20)
			if(!dead)
				for(var/mob/M in view())
					var/deathanger=0
					if(M.check_relation(src,list("Good","Very Good","Love","Rival/Good")) || M.is_friend(src)) deathanger=1
					if(deathanger==1)
						M.Do_Anger_Stuff()
						view(M)<<output("<font color=red>You notice [M] has become EXTREMELY enraged!!!","Chatpane.Chat")
						WriteToLog("rplog","[M] has become EXTREMELY angry    ([time2text(world.realtime,"Day DD hh:mm")])")
			for(var/datum/Body/B in body)
				if(B.lopped)
					B.RegrowLimb()
			spawn Un_KO() //Whether dead or not when death runs, and if not stopped by above circumstances,
			isdying = 0
			if(Planet=="Sealed")
				dead=1
				move = 1
				inteleport=0 //This is only here for the poor saps who die in the BossRush so they can teleport again.
				overlayList-='Halo.dmi'
				overlayList+='Halo.dmi'
				overlaychanged=1
				loc=locate(221,266,7)
				SpreadHeal(100,1,1)
			else if(!dead) //The actual death happens here, if not stopped by above circumstances.
				canAL = 1 //Instant Transmission dudes.
				if(BP<relBPmax) BP+=capcheck(relBPmax*BPTick*600*(1.01-(BP/TopBP))) //3600 = 10 of these to reach a given cap at 1x
				dead=1
				move = 1
				deathcounter++
				overlayList-='Halo.dmi'
				overlayList+='Halo.dmi'
				overlaychanged=1
				reviveTime=36000*log(max(deathcounter,1))
				if(HasSoul)
					loc=locate(187,104,6) //And finally, send them to the death checkpoint...
				else if(!HasSoul)
					loc=locate(187,104,7) //And finally, send them to the death checkpoint...
				SpreadHeal(100,1,1)
				inteleport=0 //This is only here for the poor saps who die in the BossRush so they can teleport again.
			else if(dead)
				move=1
				if(HasSoul)
					loc=locate(187,104,6) //And finally, send them to the death checkpoint...
				else if(!HasSoul)
					loc=locate(187,104,7) //And finally, send them to the death checkpoint...
				SpreadHeal(100,1,1)
				KO(20)
				inteleport=0
		else mobDeath()
		buudead=0
		move = 1
	else
		for(var/datum/Body/B in body)
			if(B.vital) B.health = 30
		dead=0
		buudead=0
		move = 1
		if((Race=="Bio-Android" || (Parent_Race=="Bio-Android")) && (cell3 || was3))
			if(!form3cantrevert)
				flick('flashtrans.dmi',src)
				form3cantrevert=1
				if(!cell2)
					genome.add_to_stat("Battle Power",cell2mult)
					cell2=1
					oicon=icon
				if(!cell3)
					transBuff = cell3mult
					genome.add_to_stat("Battle Power",cell3mult)
					cell3=1
					icon=form3icon
	isdying = 0

mob/proc/ReviveMe()
	SpreadHeal(100,1,1)
	Ki = MaxKi
	stamina = maxstamina
	for(var/datum/Body/B in body)
		if(B.lopped) B.RegrowLimb()
		B.health = B.maxhealth
	if(dead)
		dead=0
		overlayList-='Halo.dmi'
		overlaychanged=1
		SpreadHeal(100,1,1)

proc/Revive(var/mob/M,deathMessage)
	if(M.dead)
		M.ReviveMe()
		M.dead=0
		M.overlayList-='Halo.dmi'
		M.overlaychanged=1
		M:Locate()
		if(!deathMessage) M<<"You've been automagically revived. Enjoy your new life."