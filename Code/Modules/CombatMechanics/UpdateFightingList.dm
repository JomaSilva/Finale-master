//This proc compiles a list of everyone nearby who is currently fighting if YOU'RE fighting, every 10 seconds. This can be used to see whose fighting you.
mob/var/tmp/IsInFight
mob/var/tmp/list/LocalFighterList = list()
mob/var/tmp/highestebp = 0
mob/var/tmp/highestbp = 0
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
		if(speedDIFF > 1) speedDIFF = max(log(speedDIFF),1)
		if(speedDIFF < 1) speedDIFF = 1 / (1.03 ** (expressedBP / highestebp))
		speedDIFF = min(max(speedDIFF,0.25),3)