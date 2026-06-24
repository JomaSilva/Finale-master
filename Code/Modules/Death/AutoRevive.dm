mob/Admin3/verb/TurnAutoReviveOn()
	set category="Admin"
	set name="Auto Revive On"
	if(AutoReviveOn)
		AutoReviveOn=0
		world<<"Auto Revive Off"
		return
	if(!AutoReviveOn)
		AutoReviveOn=1
		world<<"Auto Revive On"
		return
mob/Admin3/verb/Restart_Auto_Revive()
	set category="Admin"
	set name="Revive all / Start Auto Revive"
	world.AutoRevive()
world/proc
	AutoRevive()
		if(AutoReviveOn)
			WriteToLog("admin","Autorevived all at [time2text(world.realtime,"Day DD hh:mm")]")
			for(var/mob/M in player_list)
				Revive(M)
				WriteToLog("admin","Autorevived [M] at [time2text(world.realtime,"Day DD hh:mm")]")
		while(autorevivetimer>=1)
			autorevivetimer-=1
			sleep(1)
		if(autorevivetimer==0)
			autorevivetimer=18000
			AutoRevive()
obj/Crandal/verb/CheckRevive()
	set category="Other"
	set name="Check Revive"
	if(AutoReviveOn)
		if(autorevivetimer==18000)
			world.AutoRevive()
		usr<<"Revive in [autorevivetimer/10] seconds."
	else
		usr << "Auto revive turned off."