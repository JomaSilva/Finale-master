
mob/var/tmp/debugCommandsadded

mob/Admin3/verb/AddDebugCommands()
	set category = "Admin"
	if(!debugCommandsadded)
		verbs+=typesof(/mob/Debug/verb)
		debugCommandsadded=1
	else
		verbs-=typesof(/mob/Debug/verb)
		debugCommandsadded=0

mob/Debug/verb/spawnNPC()
	set category = "Debug"
	var/list/list1=new/list
	list1+=typesof(/mob)
	var/Choice=input("Spawn What?") in list1
	var/mob/M = new Choice
	M.loc = locate(x,y-1,z)
mob/Debug/verb/Profile_Servidor()
	set category = "Debug"
	set desc = "Perfila o servidor por 60s e mostra o TOP de CPU (tambem vai pro DEBUG.log)"
	to_chat(usr, "<b>Perfilando o servidor por 60 segundos... (Lag-O-Meter agora: [world.cpu]%)</b>")
	world.Profile(PROFILE_START)
	spawn(600)
		var/pjson = world.Profile(PROFILE_REFRESH, format = "json")
		world.Profile(PROFILE_STOP)
		if(!istext(pjson))
			to_chat(usr, "Profiler indisponivel nesta versao do BYOND.")
			return
		text2file(pjson, "profile_live_[world.realtime].json") //JSON completo pra analise fina
		var/list/data = json_decode(pjson)
		if(!islist(data)) return
		var/r = "== PROFILE 60s (cpu final [world.cpu]%): top 15 por CPU propria =="
		var/list/used = list()
		for(var/i = 1 to 15)
			var/list/best = null
			for(var/list/p in data)
				if(p in used) continue
				if(!best || p["self"] > best["self"]) best = p
			if(!best || best["self"] <= 0) break
			used += list(best)
			r += "\n[best["self"]]s self | [best["calls"]] calls | [best["name"]]"
		WriteToLog("debug", r)
		to_chat(usr, "<font color=#e8b64c><pre>[r]</pre></font>")

mob/Debug/verb/Start_Cleaner()
	set category = "Debug"
	Cleaner()

mob/Debug/verb/Dump_Global_Verbs()
	set category="Debug"
	for(var/S)
		file("Debug-Global-Vars-Dump")<<"[S]"

proc/OutputDebug(var/text as text)
	to_chat(world, "D E B U G : [text]")
	WriteToLog("debug","D E B U G : [text] ([time2text(world.realtime,"Day DD hh:mm")])")

//can stay as a temp variable
var/resolveupdate=0
mob/var/tmp/updateseed=0
//

mob/proc/UpdateSkills()
	src.updateseed=resolveupdate
	for(var/datum/skill/tree/T in src.allowed_trees)
		src.TREESWEEP(T)
	for(var/datum/skill/S in src.learned_skills)
		src.SWEEP(S)

mob/Debug/verb/ForceUpdateSkills()
	set category="Debug"
	resolveupdate++
	for(var/mob/M in player_list)
		M.UpdateSkills()
		to_chat(M, "Skills forcibly updated by [usr]")
	to_chat(world, "[usr] updated skills.")
	to_chat(usr, "Skills updated.")
	WriteToLog("admin","[usr] forcibly updated skills at [time2text(world.realtime,"Day DD hh:mm")]")
	sleep(10000)

mob/Debug/verb/Test_Explosion()
	set category="Debug"
	var/strength1 = input(usr,"strength") as num
	var/radius1 = input(usr,"radius") as num
	spawnExplosion(location=loc,strength=strength1,radius=radius1)

mob/Debug/verb/Reinitialize_Alchemy()
	set category="Debug"
	alchemyprototypes = list()
	var/list/types = list()
	var/list/picklist = list()
	picklist+=alchemyeffectlist
	types+=typesof(/obj/items/Material/Alchemy)
	for(var/A in types)
		if(!Sub_Type(A))
			var/obj/items/Material/Alchemy/B = new A
			while(B.Effects.len<4) //stop with sleep stuff in init, we don't need eet. (LET THE LAG JUST HAPPEN)
				if(picklist.len<4)//safety check so we don't get stuck in a loop on the last effects
					picklist+=alchemyeffectlist
				var/picked=0
				while(!picked)
					var/effect=pick(picklist)
					if(!(effect in B.Effects))
						B.Effects+=effect
						picklist-=effect
						picked=1
			B.Magic = rand(10,200)
			alchemyprototypes+=B
			if(istype(B,/obj/items/Material/Alchemy/Plant))
				alchemyplants+=B
			if(istype(B,/obj/items/Material/Alchemy/Animal))
				alchemyparts+=B
	alchloaded=1
/*
mob/default
	var
		debug_Show = 1
	verb
		debug_Show()
			set category = "Other"

mob/proc/outputDebug(message)
	if(debug_Show)
		to_chat(usr, "[message]")
*/
