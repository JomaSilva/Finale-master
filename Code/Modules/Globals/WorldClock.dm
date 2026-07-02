// ============================================================================
// CONFIG DO RELOGIO -- quanto tempo REAL dura 1 dia in-game.
// O dia tem 23 ticks de hora (Hours 1 -> 24). Com 20 min: ~52s reais por hora.
// O Yearspeed (verb de admin Year_Speed) continua ACELERANDO tudo por cima disto.
// (Antes o tick era fixo em 10s/hora -> 1 dia durava so ~3min50s.)
// ============================================================================
#define DAY_REAL_MINUTES 20

proc/WorldClock()
	set background = 1
	while(1)
		if(Yearspeed==0||!Yearspeed)
			Yearspeed=1
		Hours = min((Hours+1),24)
		sync_area_daylight() //o dia/noite VISUAL agora segue o relogio (Hours) -- antes era um ciclo proprio dessincronizado (Weather.dm)
		if(Hours>=24)
			Hours=1
			Days+=1
			if(Days>=29)
				Month+=1
				Days=1
				listedDaysuffix = "st"
				listedDay = DayNames[Days]
				if(Month>=11)
					Month=1
				listedMonth = MonthNames[Month]
				Year+=0.1
				//world<<"It is now month [listedMonth] of Age [round(Year)]"
				Calculate_Day()
				Years()
				spawn Tourney_Month_Check() //Torneio de Artes Marciais: convite mensal na Terra (Tournament.dm)
			else
				Calculate_Day()
				to_chat(world, "It is now [listedDay], [listedMonth] the [Days][listedDaysuffix]")
		sleep(max(10,round((DAY_REAL_MINUTES * 600 / 23) / max(Yearspeed,1))))

proc/Calculate_Day()
	if(Days<=7)
		switch(Days)
			if(1) listedDaysuffix = "st"
			if(2) listedDaysuffix = "nd"
			if(3) listedDaysuffix = "rd"
			else listedDaysuffix = "th"
		listedDay = DayNames[Days]
	else if(Days<=14)
		listedDay = DayNames[Days-7]
		listedDaysuffix = "th"
	else if(Days<=21)
		if(Days==21)
			listedDaysuffix = "st"
		else listedDaysuffix = "th"
		listedDay = DayNames[Days-14]
	else if(Days<=28)
		switch(Days-21)
			if(1) listedDaysuffix = "nd"
			if(2) listedDaysuffix = "rd"
			else listedDaysuffix = "th"
		listedDay = DayNames[Days-21]
	listedMonth = MonthNames[Month]

proc/WorldSubClocks()
	set background = 1
	while(1)
		if(!NPCcheckrunning)
			NPCcheckrunning = 1
			checkNPCs()
		sleep(500)

proc/checkNPCs()
	set background = 1
	NPCcheckrunning = 1
	globalNPCcount=NPC_list.len
	NPCcheckrunning = 0

var/globalNPCcount
var/NPCcheckrunning
var/Hours =1
var/Days =1
var/DayNames = list("Suntag", "Veindin", "Thordin", "Kaidin", "Dedin", "Fradin", "Sondin")
var/listedDay = "Suntag"
var/listedDaysuffix = "st"
var/Month =1
var/Year=1
var/MonthNames = list("Luty","Sakavik","Frieze","Saiya","Augustus","Plant","Yule","Propositus","Zenkin","Alacritas")
var/listedMonth = "Luty"
proc/Years()
	set background = 1
	GENGAIN=(Year/10)
	world<<checkthetimeidiot()
	spawn for(var/mob/M in player_list) if(M.client)
		sleep(1)
		spawn M.AgeCheck(1)

mob/verb/Sense_Time()
	set category="Other"
	usr<<checkthetimeidiot()

mob/Admin3/verb/Advance_Month()
	set category="Admin"
	Month+=1
	Year+=0.1
	Days=1
	listedDaysuffix = "st"
	listedDay = DayNames[Days]
	if(Month>=11)
		Month=1
	listedMonth = MonthNames[Month]
	Years()
	spawn Tourney_Month_Check() //mes avancado na marra tambem dispara o torneio
	for(var/area/A in area_outside_list) A.AreaTime(1)
proc/checkthetimeidiot()
	return "It is now [listedDay], the [Days][listedDaysuffix] of [listedMonth], Age [round(Year)]"