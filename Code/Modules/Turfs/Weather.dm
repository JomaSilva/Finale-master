area
	mouse_opacity = 0
	var
		daylightcycle=0 // 3 hours of daylight, 3 hours of night. 2 of dawn/dusk.
		//>inb4 ITS EIGHT HOURS!
		//not if theres a dedicated midnight/peak daylight time :^)
		mooncycle = 0
		//mooncycle increments by 1, max is 5, 8 is the last phase before it loops back. 1 is new moon
		weatherprobability = 25 //probability of percent that there will be weather change of some kind.
		//
		HasNight=1
		HasDay=1
		HasWeather=1
		AlwaysDay=0
		//self explanatory, if HasDay is ticked off, night will loop back into night. If HasNight is ticked off, day will loop back into day.
		//Both ticked off will result in dusk only.
		//weather events will not happen if hasweather is 0
		HasMoon=1
		//potential moon busting shanagians here
		IsHellstar=0
		CanHellstar=1//variable for anything that *shouldn't* have the Makyo Star.
		AlwaysHellstar=1 //"always" hellstar level 2.
		//
		list/allowedWeatherTypes = list("Rain","Snow","Fog")
		list/possibleWeatherTypes = list("Rain","Snow","Fog","Storm","Smog","Blood Rain","Blizzard","Sandstorm","Namek Rain")
		//
		tmp/IsWeathering = 0 //weather (geddit?) or not weather is going on
		currentWeather = "" //current weather
		tmp/prevweather

	proc
		AreaTime(isforced)
			set waitfor = 0
			// basic cycling
			daylightcycle = max(1,daylightcycle)
			mooncycle = max(1,mooncycle)
			daylightcycle+=1
			if(daylightcycle==6)
				mooncycle += 1
			if(mooncycle >= 9 || !HasMoon) mooncycle = 1
			//
			//enable checks
			if(HasDay && HasNight)
				if(daylightcycle >= 11) daylightcycle = 1
			else if(HasNight)
				daylightcycle = max(6,daylightcycle)
				if(daylightcycle >= 11) daylightcycle = 6
			else if(HasDay)
				if(daylightcycle >= 6) daylightcycle = 1
			else
				daylightcycle = 11
			if(planet_death_stage < 4 && planet_death_stage)
				daylightcycle = max(6,daylightcycle)
				if(daylightcycle >= 11) daylightcycle = 6
			//
			//weather
			prevweather = null //ensure weather gets updated
			if(prob(weatherprobability) && HasWeather)
				if(IsWeathering)
					IsWeathering = 0
				else
					IsWeathering = 1
					currentWeather = pick(allowedWeatherTypes)
					if(!currentWeather in possibleWeatherTypes) IsWeathering = 0

			//
			if(IsHellstar<3 && IsHellstar) IsHellstar += 1
			else IsHellstar = 0
			testHellstar()
			//
			//syncing w/ inside areas
			for(var/area/A in area_inside_list)
				if(istype(A,src.type))
					A.IsHellstar=IsHellstar //only thing inside areas get is hellstar bonuses
			//
			if(!isforced)
				spawn(max((rand(5000,7000) / max(Yearspeed,1)),100))
					AreaTime()

		Ticker()
			set waitfor = 0
			if(my_player_list.len && name == "Inside")
				var/area/a = locate(text2path(("[copytext(src.type,length(src.type) - 8)]")))
				a?.my_player_list |= my_player_list
				my_player_list |= a?.my_player_list //sync lists. Outside of vegeta should track those inside vegeta.
			if(!death_proc_running && planet_dying)
				death_proc_running = 1
				if(planet_death_stage <= 3) spawn Planet_Death(AverageBP)
				else spawn DestroyPlanet(AverageBP)
			if(src in area_inside_list)
				daylightcycle=0
				mooncycle = 0
				HasWeather= 0
				HasMoon= 0
			if(TimeStopped)
				if(!IsWeathering)
					icon_state = "Time Stop"
			if(IsWeathering && prevweather != currentWeather)
				prevweather = currentWeather
				switch(currentWeather)
					if("Tornado")
						if(daylightcycle>=6) icon_state = "Night Rain"
						else icon_state = "Rain"
					if("Storm")
						if(daylightcycle>=6) icon_state = "Night Rain"
						else icon_state = "Rain"
					if("Rain")
						if(daylightcycle>=6) icon_state = "Night Rain"
						else icon_state = "Rain"
					if("Snow")
						if(daylightcycle>=6) icon_state = "Night Snow"
						else icon_state = "Rain"
					if("Fog")
						icon_state = "Fog"
					if("Void")
						icon_state = "Void"
					if("Smog")
						icon_state = "Smog"
					if("Blood Rain")
						if(daylightcycle>=6) icon_state = "Night Blood Rain"
						else icon_state = "Blood Rain"
					if("Blizzard")
						icon_state = "Blizzard"
					if("Sandstorm")
						icon_state = "Sandstorm"
					if("Namek Rain")
						if(daylightcycle>=6) icon_state = "Night Namek Rain"
						else icon_state = "Namek Rain"
					if("Destruction")
						icon_state ="Rising Rocks"
			else if(!IsWeathering && prevweather != icon_state)
				if(daylightcycle==11 && AlwaysDay) icon_state=""
				else if(daylightcycle>=6) icon_state = "Dark"
				else if(daylightcycle==5) icon_state = "Sunset"
				else if(daylightcycle==1) icon_state = "Sunrise"
				else icon_state = ""
				prevweather = icon_state
			spawn(rand(10,15)) Ticker()

mob/var/previousTime
mob/var/tmp/currentDaylight = 1
mob/var/tmp/currentMoonlight = 1
mob/var/tmp/messageDelay = 0//you have 10 seconds of message delay, helps with moving between builtinside/outside tiles repeatedly.
mob/proc/CheckTime()
	if(!current_area) return
	if(!client) return
	if(previousTime != current_area.daylightcycle)
		previousTime = current_area.daylightcycle
		currentDaylight = current_area.daylightcycle
		currentMoonlight = current_area.mooncycle
		HellStar = current_area.IsHellstar
		if(messageDelay) return
		messageDelay = 1
		spawn(10)	messageDelay = 0
		if(!current_area.HasNight && !current_area.HasDay)
			if(!current_area.AlwaysDay)
				src<<"<font color=#663300>It's twilight..."
			else
				src << "<font color=#663300>It's light out."
		else if(currentDaylight>=6)
			if(currentMoonlight==5)
				if(currentDaylight == 6) src<<"<font color=red>The full moon is rising..."
				else if(currentDaylight == 10) src<<"<font color=red>The full moon is setting..."
				else src<<"<font color=red>The full moon is out..."
				if(Osetting && !Apeshit && Tail && Race == "Saiyan")
					if(current_area.name!="Inside")
						view(src)<<"[src] looks at the full moon!"
						if(hasssj && prob(60) && (Race=="Saiyan" || canSSJ || Parent_Race=="Saiyan"))//canSSJ is a var ticked by Baby absorbs.
							GoldenApeshit()
						else
							Apeshit()
				else src<<"You try your best not to look..."
			else if(currentMoonlight!=1)
				if(currentDaylight == 6) src<<"<font color=red>The moon is rising..."
				else if(currentDaylight == 10) src<<"<font color=red>The moon is setting..."
				else src<<"<font color=red>The moon is out..."
			if(currentDaylight==7||currentDaylight==9)
				src<<"<font color=#001a66>It's nighttime..."
			switch(currentDaylight)
				if(8)
					src<<"<font color=#001a66>It's midnight..."
				if(6)
					src<<"<font color=#001a66>It's early nighttime..."
				if(10)
					src<<"<font color=#001a66>It's late nighttime..."
		else
			switch(currentDaylight)
				if(1)
					src<<"<font color=blue>Sun is rising."
				if(2)
					src<<"<font color=blue>It's the early morning."
				if(3)
					src<<"<font color=blue>It's high noon."
				if(4)
					src<<"<font color=blue>It's the afternoon."
				if(5)
					src<<"<font color=red>Sun is setting."
		switch(HellStar)
			if(1)
				src<<"<font size=2><font color=red>The Makyo Star begins to pass by the Planet..."
			if(2)
				src<<"<font size=2><font color=red>The Makyo Star is passing by the planet..."
			if(3)
				src<<"<font size=2><font color=red>The Makyo Star is leaving the reach of the Planet..."

	doWeatherEffects()

mob/proc/doWeatherEffects()
	switch(current_area.currentWeather)
		if("Storm")
			if(prob(1))
				var/list/tlist = list()
				tlist += oview()
				tlist -= typesof(/area)
				if(tlist.len)
					var/atom/t = pick(tlist)
					if(isturf(t))
						createLightningmisc(t,10)
					else createLightningmisc(t.loc,10)
		if("Tornado")
			if(prob(1)&&prob(60))
				var/list/tlist = list()
				tlist += oview()
				tlist -= typesof(/area)
				if(tlist.len)
					var/atom/t = pick(tlist)
					if(isturf(t))
						createDustmisc(t,3)
					else createDustmisc(t.loc,3)