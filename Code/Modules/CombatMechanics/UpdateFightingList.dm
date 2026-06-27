//This proc compiles a list of everyone nearby who is currently fighting if YOU'RE fighting, every 10 seconds. This can be used to see whose fighting you.
mob/var/tmp/IsInFight
mob/var/tmp/list/LocalFighterList = list()
mob/var/tmp/highestebp = 0
mob/var/tmp/highestbp = 0
mob/var/tmp/combatTag = 0 //"In Battle" DISPLAY + battle-music flag ONLY (separate from the IsInFight mechanics flag); lasts combat_tag_duration after the last hit
mob/var/tmp/combatTagExpire = 0 //world.time when combatTag expires; refreshed on every hit dealt or received
var/combat_tag_duration = 900 //how long the combat tag lasts after the last hit, in deciseconds (900 = 1 min 30 s)
mob/proc/refresh_combat_tag() //(re)start the 90s display/music combat tag on ANY hit dealt or received. Deliberately does NOT set IsInFight, so the long tag never drags combat-speed / Ki-regen / stun / skill-gain mechanics along with it.
	combatTag = 1
	combatTagExpire = world.time + combat_tag_duration
mob/proc/clear_combat_tag() //end the display/music combat tag now (on 90s expiry, or KO/death/logout)
	combatTag = 0
	stop_battle_music()
mob/proc/UpdateFightingStatus()
	if(IsInFight)
		setcombatspeed()
		if(LocalFighterList.len <= 2 && !target)
			for(var/mob/M in LocalFighterList)
				if(M != src)
					M = target
					break
		spawn(100)
			IsInFight=0
	else
		StopFightingStatus()
mob/proc/StartFightingStatus() //called on every attack in attack.dm.
	if(attacking)
		UpdateFightingStatus() //doing it in this order ensures that the list is cleared before updating it again.
		if(!IsInFight)
			sense_hud_softinit()
		IsInFight=1
		for(var/mob/M in view())
			if(M.IsInFight&&!(M in LocalFighterList))//prevents duping
				LocalFighterList += M
				if(M.BP > highestbp)
					highestbp = M.BP
				if(M.expressedBP > highestebp)
					highestebp = M.expressedBP
mob/proc/StopFightingStatus()
	LocalFighterList = list()
	last_attkd_sig = 0
	last_attk_sig = 0
	IsInFight=0
	clear_combat_tag() //also end the display/music "In Battle" tag (KO/death/logout end it at once)
	highestebp = 0
	highestbp = 0
	speedDIFF = 1
	combo_count = 0
	sense_hud_softdenit()

//combat speed handler
//--> Epspeed = (Espeed/speedDIFF) <-- this is how speedDIFF feeds back into equations
//

mob/proc/setcombatspeed()
	set background = 1
	if(highestebp)
		speedDIFF = highestebp / expressedBP
		speedDIFF = min(max(speedDIFF,0.1),5) //LINEAR brutal BP gap (was log-dampened + capped at 3x); bounded [0.1x,5x] — brutal but still playable