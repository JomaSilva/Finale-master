/datum/skill/sense
	skilltype = "Ki"
	name = "Sense"
	desc = "The user senses their surroundings."
	level = 1
	expbarrier = 1000
	skillcost = 0
	maxlevel = 1
	can_forget = FALSE
	common_sense = TRUE
	teacher = TRUE
	tier = 1

mob/var/gotsense=0
mob/var/gotsense2=0
mob/var/gotsense3=0
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DO NOT CALL stat() IN A PROC OUTSIDE OF THE INBUILT Stat() PROC- it does nothing and it creates a runtime error. Reminder because I didn't know this. //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/skill/sense/effector()
	..()
	if(savant.kiawarenessskill>=1&&!savant.gotsense)
		to_chat(savant, "You feel a faint presence with a feeling familiar to your own energy. You focus and pickup similar traces of this sensation as you start to understand how to sense ki.")
		assignverb(/mob/keyable/verb/Sense)
		savant.gotsense=1
	if(savant.kiawarenessskill>=20&&!savant.gotsense2)
		to_chat(savant, "After training your ability to sense and measure ki, you begin to feel traces of energy coming from all across the very planet!")
		assignverb(/mob/keyable/verb/Sense_Planet)
		savant.gotsense2=1
		to_chat(savant, "Despite your skill in picking up ki signatures, you don't think this is the extent of your prowess...Could it be possible to sense beings from an even further distance?")
	if(savant.kiawarenessskill>=60&&!savant.gotsense3)
		to_chat(savant, "You begin to focus intensively...its faint, but you can pinpoint the location of beings across the galaxy! It doesn't look like training your sensing ability will be of much use anymore.")
		assignverb(/mob/keyable/verb/Sense_Galaxy)
		savant.gotsense3=1
//when God Ki happens, there should be a 4th level of Sense that can detect people using God Ki.

/datum/skill/sense/login(var/mob/logger)
	..()
	if(savant.gotsense)
		assignverb(/mob/keyable/verb/Sense)
	if(savant.gotsense2)
		assignverb(/mob/keyable/verb/Sense_Planet)
	if(savant.gotsense3)
		assignverb(/mob/keyable/verb/Sense_Galaxy)

mob/keyable/verb/Sense(mob/M in view(usr))
	set category="Skills"
	var/range=((500/(usr.Ekiskill*usr.kiawarenessskill))) //Sensing accuracy. Now based on ki awareness, perfect sensing won't come until higher levels
	if(range<1) range=0 //Perfection of accurate sensing.
	to_chat(usr, "<br>")
	if(M.Race=="Android"|M.Race=="Meta") to_chat(usr, "You cant sense any energy from [M]...")
	else if((((M.BP+1)/(usr.BP+1))*100)>500) to_chat(usr, "[M] is more than 500% your power.")
	else to_chat(usr, "[M] is around [round((((M.BP+1)/(usr.BP+1))*100)+rand((0-range),range))]% your power.")
	if (gotsense2)
		to_chat(usr, "[M.Emotion], [round(M.Age)] year old [M.BodyType] [M.Race]")
		to_chat(usr, "<br>")
		if(usr.Ekiskill*usr.kiawarenessskill>100)
			var/damage=round((100-M.HP)+rand((0-range),range))
			to_chat(usr, "[damage]% damaged.")
			var/energy=round(((M.Ki*100)/M.MaxKi)+rand((0-range),range))
			to_chat(usr, "[energy]% energy.")
	else return
	if (gotsense3)
		if(usr.thirdeye|usr.snamek|usr.Race=="Kanassa-Jin"||Admin)
			to_chat(usr, "<br>")
			to_chat(usr, "Decline at age [round(M.DeclineAge)]")
			to_chat(usr, "True age is [round(M.SAge)]")
			to_chat(usr, "Body is at [round(M.Body*4)]% of its full potential")
			to_chat(usr, "Ki skill is [round(M.Ekiskill)]")
			if(M.KaiokenMastery>1) to_chat(usr, "Mastered Kaioken times [round(M.KaiokenMastery)]")
			to_chat(usr, "Mastered [round(M.GravMastered)]x gravity")
			to_chat(usr, "Hidden potential is at [hiddenpotential+rand((0-range),range)].")
			to_chat(usr, "[M]'s anger is +[round(M.MaxAnger-100)]%")
			to_chat(usr, "[M] has [round(M.MaxKi)] Max Energy.")
			to_chat(usr, "[M] has [round(M.Ephysoff)] Physical Offense")
			to_chat(usr, "[M] has [round(M.Ephysdef)] Defense")
			to_chat(usr, "[M] has [round(M.Ekioff)] Ki Offense")
			to_chat(usr, "[M] has [round(M.Ekidef)] Ki Defense")
			to_chat(usr, "[M] has [round(M.Espeed)] Speed")
			to_chat(usr, "[M] has [round(M.Etechnique)] Technique")
			to_chat(usr, "[M] has [round(M.Ewillpower)] Willpower")
			to_chat(usr, "[M] has [round(M.kiregenMod,0.1)]x Energy Recovery Rate")
		else if(usr.Rank=="Earth Guardian"|usr.Rank=="Earth Assistant Guardian"|usr.Rank=="Namekian Elder"|usr.Race=="Kai"|usr.Race=="Demon")
			to_chat(usr, "<br>")
			to_chat(usr, "True age is [round(M.SAge)]")
			to_chat(usr, "Body is at [round(M.Body*4)]% of its full potential")
			to_chat(usr, "Mastered [round(M.GravMastered)]x gravity")
			to_chat(usr, "Hidden potential is at [hiddenpotential+rand((0-range),range)].")
			to_chat(usr, "[M]'s anger is +[round(M.MaxAnger-100)]%")
			to_chat(usr, "[M] has [round(M.MaxKi)] Max Energy.")
			to_chat(usr, "[M] has [round(M.Ewillpower)] Willpower")

mob/keyable/verb/Sense_Planet()
	set category="Skills"
	var/approved
	for(var/mob/M in current_area.contents) if(M.key!=usr.key&&M.BP>=1000&&M.Race!="Android")
		if(check_familiarity(M)) approved=1
		if(approved) to_chat(usr, "<br>[M.name]([M.Race])([M.x],[M.y]): [round(((M.BP+1)/(usr.BP+1))*100)]% your power.")
		else if((((M.BP+1)/(usr.BP+1))*100)>500) to_chat(usr, "<br>([M.Race])([M.x],[M.y]): Power beyond your comprehension.")
		else to_chat(usr, "<br>([M.Race])([M.x],[M.y]): [round((M.BP/usr.BP)*100)]% your power.")

mob/keyable/verb/Sense_Galaxy()
	set category="Skills"
	var/approved
	for(var/mob/M in player_list) if(M.key!=usr.key&&M.BP>=5000000&&M.Race!="Android")
		if(check_familiarity(M)) approved=1
		if(approved) to_chat(usr, "You sense [M.name] ([M.Race]) at (z[M.z])")
		else to_chat(usr, "You sense someone ([M.Race]) at (z[M.z])")