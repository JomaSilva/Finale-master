mob/
	var
		tmp/angercooldown = 0
	verb
		Anger_Me()
			set category = "Other"
			if(angercooldown)
				usr << "You can't anger right now, it's too recent to another anger."
				return
			var/choice = alert(usr,"Anger yourself? You have [StoredAnger] stored anger. You will get a small boost, but it'll be broadcasted locally and put in the RP log, and it'll cost some Stored Anger for any level. Annoyed is technically free, but if you have any Stored Anger it'll take 10 of it.","","No","Yes")
			if(choice=="No")
				return
			var/reason = input(usr,"What's the reason?","","'X' ate the last oreo cookie.") as text
			//var/voters
			//var/votersyes
			var/angerlevel = input(usr,"Select the level. Annoyed costs 10 stored anger or whatever you have, Slightly Angry costs 30, Angry costs 50. Death Anger levels require 100 stored anger. (Only built up by fighting and whatnot.)","","Annoyed") in list("Annoyed","Slightly Angry","Angry","Very Angry")
			switch(angerlevel)
				if("Annoyed")
					if(StoredAnger > 0)
						Anger =(((MaxAnger-100)/4.25)+100)
						Emotion="Annoyed"
						angercooldown+=500
						StoredAnger = max(StoredAnger - 10,0)
						Ki += (MaxKi/10)
					else
						usr<<"No anger!"
						return
				if("Slightly Angry")
					if(StoredAnger > 30)
						Anger=(((MaxAnger-100)/1.7)+100)
						Emotion="Slightly Angry"
						angercooldown+=500
						StoredAnger = max(StoredAnger - 30,0)
						Ki += (MaxKi/5)
					else
						usr << "Anger not above 30!"
						return
				if("Angry")
					if(StoredAnger > 50)
						Anger=(((MaxAnger-100)/1.30)+100)
						Emotion="Angry"
						angercooldown+=500
						StoredAnger = max(StoredAnger - 50,0)
						Ki += (MaxKi/2)
					else
						usr << "Anger not above 50!"
						return
				if("Very Angry")
					if(StoredAnger == 100)
						Anger=MaxAnger+=100
						Emotion="Very Angry"
						angercooldown = 1000
						StoredAnger = max(StoredAnger - 50,0)
						Ki += MaxKi
					else
						usr << "Anger not equal to 100!"
						return

			WriteToLog("rplog","[usr] used the Anger Me verb, at level [Emotion] with the reasoning: [reason]   ([time2text(world.realtime,"Day DD hh:mm")])")
			for(var/mob/M in range(screenx,src))
				if(M.client)
					M<<output("<font size=[M.TextSize]><font color=red>*[name] got [Emotion] because [reason]!!!*","Chatpane.Chat")
					M.TestListeners("<font size=[M.TextSize]><font color=red>*[name] got [Emotion] because [reason]!!!*","Chatpane.Chat")
			for(var/mob/C in mob_list)
				if(C.Admin&&C.key!=src.key&&C.Spying)
					C<<output("<font size=[C.TextSize]><font color=yellow>(RP Spy)*[name] got [Emotion] because [reason]!!*(RP Spy)","Chatpane.Chat")