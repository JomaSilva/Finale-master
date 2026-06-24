
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
mob/Debug/verb/RemoveTileOverlays()
	set category = "Debug"
	var/Choice=alert("Are you fucking sure? This will lag the game for a whopping 5 to 10 minutes depending on hardware.","","Yes","No")
	switch(Choice)
		if("No")
			return //RETURN MOTHERFUCKER THIS WAS A MISTAAAAAAAAAAAAAAAAAAKE
	CleanTurfOverlays()
mob/Debug/verb/Start_Cleaner()
	set category = "Debug"
	Cleaner()

mob/Debug/verb/Dump_Global_Verbs()
	set category="Debug"
	for(var/S)
		file("Debug-Global-Vars-Dump")<<"[S]"

proc/OutputDebug(var/text as text)
	world << "D E B U G : [text]"
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
		M<<"Skills forcibly updated by [usr]"
	world<<"[usr] updated skills."
	usr<<"Skills updated."
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
		usr << "[message]"
*/
