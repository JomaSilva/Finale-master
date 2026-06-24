mob/var/tmp/nokill
mob/var/hasSplitform
mob/npc/Splitform
	var/function = 0
	notSpawned=0
	mindswappable=0
	var/timelimit = 1000
	AIAlwaysActive=1
	hasAI=0
	attackable = 1
	var/mob/master=null
	New()
		..()
		emit_Sound('groundrecover.wav')
		spawn while(src)
			sleep(10)
			timelimit -= 10
			checkState()
			if(HP<=0||(HP<=8&&KO))
				view(src)<<"[src] has been defeated."
				del(src)
			if(isnull(master) || timelimit<=0)
				del(src)
	Del()
		if(master)
			master.splitformCount=max(0,master.splitformCount-1)
		..()
	Click()
		if(displaykey==usr.key)
			var/list/Choices=new/list
			Choices.Add("Follow")
			Choices.Add("Stop")
			Choices.Add("Attack Target")
			Choices.Add("Attack Nearest")
			Choices.Add("Destroy Splitforms")
			Choices.Add("Cancel")
			switch(input("Choose Option","",text) in Choices)
				if("Attack Nearest")
					hasAI = 1
					function=0
					for(var/mob/nE in range(MAX_AGGRO_RANGE,usr))
						if(nE!=usr && nE!=src)foundTarget(nE)
				if("Destroy Splitforms") for(var/mob/npc/Splitform/A in NPC_list) if(A.displaykey==usr.key) del(A)
				if("Follow")
					function=1
					var/d = get_dist(src, usr)
					while(function==1 && usr)
						sleep(5)
						if(d >= 2)
							if(prob(20)) step_rand(src)
							else step_towards(src,usr)
						d = get_dist(src,usr)
				if("Stop")
					hasAI = 0
					function=0
				if("Attack Target")
					hasAI = 1
					function=0
					var/list/chooselist = list()
					for(var/mob/nE in oview(src))
						chooselist += nE
					chooselist += "Cancel"
					var/mob/choice = input(usr,"Choose mob") as null|mob in chooselist
					if(ismob(choice))
						if(choice!=src)
							foundTarget(choice)
				if("Cancel")
					function=0
	lostTarget()
		resetState()
	resetState()
		set waitfor=0
		src.target = null
		Ki=MaxKi
		stamina=maxstamina
obj/SplitForm
	var/Splitformskill=1
	verb/SplitForm()
		set category="Skills"
		var/Splitforms=0
		usr.splitformCount=0
		for(var/mob/npc/Splitform/Z) if(Z.displaykey==usr.key)
			Splitforms+=1
			usr.splitformCount+=1
		if(Splitforms<Splitformskill)
			if(prob(50/(Splitformskill*5)))
				usr<<"Your Split form skill has increased.."
				Splitformskill+=1
				usr.splitformMastery+=0.2
			usr.Ki-=usr.MaxKi*(0.5/Splitformskill)
			var/mob/npc/Splitform/nS = usr.makeCopy(2,usr.Race,"None",/mob/npc/Splitform,FALSE)
			nS.master = usr
			nS.checkState()
			nS.loc = locate(usr.x,usr.y,usr.z)
			step(nS,usr.dir)
		else usr<<"You do not have the skill to create this many Splitforms."

mob/var/tmp/splitformCount
mob/var/splitformMastery