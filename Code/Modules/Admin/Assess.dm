proc/AssessMob(var/mob/M,var/mob/usr)
	usr<<"<font color=blue>Name=[M.name] (Key [M.displaykey])"
	usr<<"<font color=blue>True Age=[M.SAge]"
	usr<<"<font color=blue>Physical Age=[M.Age]"
	usr<<"<font color=blue>Decline=[M.DeclineAge]"
	usr<<"<font color=blue>Race=[M.Race]"
	usr<<"<font color=blue>Class=[M.Class]"
	usr<<"<font color=blue>Gender=[M.pgender]"
	usr<<"<font color=blue>Emotion=[M.Emotion] (+[round(M.Anger-100)]%)"
	usr<<"<font color=blue>Body=[M.Body]"
	usr<<"<font color=blue>Current Power=[FullNum((round(M.expressedBP)),20)] / [FullNum((round(M.BP)),20)] ([M.BPMod])"
	usr<<"<font color=blue>Damage=[FullNum((round(100-M.HP)),20)]%"
	usr<<"<font color=blue>Energy=[FullNum(M.Ki)] / [FullNum(M.MaxKi)] ([M.KiMod])"
	usr<<"<font color=blue>Stamina=[FullNum(M.stamina)] / [FullNum(M.maxstamina)]"
	usr<<"<font color=blue>Physical Offence=[round(M.Ephysoff)] ([M.physoff])"
	usr<<"<font color=blue>Ki Offence=[round(M.Ekioff)] ([M.kioff])"
	usr<<"<font color=blue>Speed=[round(M.Espeed)] ([M.speedMod])"
	usr<<"<font color=blue>Ki Defence=[round(M.Ekidef)] ([M.kidefMod])"
	usr<<"<font color=blue>Physical Defence=[round(M.Ephysdef)] ([M.physdefMod])"
	usr<<"<font color=blue>Technique=[round(M.Etechnique)] ([M.techniqueMod])"
	usr<<"<font color=blue>Energy Regeneration=([M.kiregenMod])"
	usr<<"<font color=blue>Zenkai=([M.ZenkaiMod])"
	usr<<"<font color=blue>Grav Mastered=[round(M.GravMastered)] ([M.GravMod])"
	usr<<"<font color=blue>Training =[M.TrainMod]x"
	usr<<"<font color=blue>Meditate =[M.MedMod]x"
	usr<<"<font color=blue>Sparring =[M.SparMod]x"
	usr<<"<font color=blue>Anger=+[M.MaxAnger-100]% Power"
	usr<<"<font color=blue>Stored Anger=+[M.StoredAnger] Power"
	usr<<"<font color=blue>	-Ki Skill=[M.Ekiskill]"
	usr<<"<font color=blue>	-Healing=[M.healskill] ([M.healmod])"
	usr<<"<font color=blue>	-Tech Skill=[round(M.techskill)] ([M.techmod])"
	usr<<"<font color=yellow>Unlock Mod=[M.UPMod]"
	usr<<"<font color=yellow>Hidden Potential =[FullNum((round(M.hiddenpotential)),20)]"
	usr<<"<font color=yellow>Absorbed Potential =[FullNum((round(M.absorbadd)),20)]"
	usr<<"<font color=yellow>Zenkai Potential =[FullNum((round(M.zenkaiStore)),20)]"

	if(M.Race=="Half-Breed")
		if(M.SPType)
			usr<<"<font color=blue>They are a Heran type Hybrid, and so they have two transformations."
			usr<<"<font color=blue>Full Power @ [FullNum((round(M.ssjat)),20)] ([M.ssjmult])"
			usr<<"<font color=blue>True Full Power @ [FullNum((round(M.ssj2at)),20)] ([M.ssj2mult])"
		if(M.SaiyanType)
			usr<<"<font color=blue>They are a Saiyan type Hybrid, so they have the Super Saiyan transformations."
			usr<<"<font color=blue>SSj @ [FullNum((round(M.ssjat)),20)], form mult ([M.ssjmult])"
			usr<<"<font color=blue>SSj2 @ [FullNum((round(M.ssj2at)),20)], form mult ([M.ssj2mult])"
			usr<<"<font color=blue>SSj3 @ [num2text((round(M.ssj3at)),20)], form mult ([M.ssj3mult])"
		if(M.LSSJType)
			usr<<"<font color=blue>They are a LSSJ Type, and so they have LSSJ Transformations."
			usr<<"<font color=blue>Restrained SSj @ [num2text((round(M.restssjat)),20)], form mult ([M.restssjmult])"
			usr<<"<font color=blue>Unrestrained SSj @ [num2text((round(M.unrestssjat)),20)], form mult ([M.unrestssjmult])"
			usr<<"<font color=blue>Legendary SSj @ [num2text((round(M.lssjat)),20)], form mult ([M.lssjmult])"
		if(M.ChangieType)
			usr<<"<font color=blue>They are a Frost Demon Type, and so they have Frost Demon Transformations. They have [M.icer_limit_forms] limiting forms."
			usr<<"<font color=blue>Form 5 @ [num2text((round(M.f5at)),20)]"
			usr<<"<font color=blue>Form 5 mult [M.f5mult]"
	if(M.Race=="Heran")
		usr<<"<font color=blue>Full Power @ [num2text((round(M.ssjat)),20)] ([M.ssjmod])"
		usr<<"<font color=blue>True Full Power @ [num2text((round(M.ssj2at)),20)] ([M.ssj2mod])"
	if(M.Race=="Saiyan" || M.Parent_Race == "Saiyan")
		if(M.Class!="Legendary")
			usr<<"<font color=blue>SSj @ [num2text((round(M.ssjat)),20)], form mult ([M.ssjmult])"
			usr<<"<font color=blue>SSj2 @ [num2text((round(M.ssj2at)),20)], form mult ([M.ssj2mult])"
			usr<<"<font color=blue>SSj3 @ [num2text((round(M.ssj3at)),20)], form mult ([M.ssj3mult])"
		else if(M.Class=="Legendary")
			usr<<"<font color=blue>Restrained SSj @ [num2text((round(M.restssjat)),20)], form mult ([M.restssjmult])"
			usr<<"<font color=blue>Unrestrained SSj @ [num2text((round(M.unrestssjat)),20)], form mult ([M.unrestssjmult])"
			usr<<"<font color=blue>Legendary SSj @ [num2text((round(M.lssjat)),20)], form mult ([M.lssjmult])"
		if(M.Race=="Saiyan")
			usr<<"<font color=blue>SSj4 @ [num2text((round(M.ssj4at)),20)], form mult ([M.ssj4mult])"
	if(M.Race=="Namekian")
		usr<<"<font color=blue>supernamek @ [num2text((round(M.snamekat)),20)]"
		usr<<"<font color=blue>snamek x[num2text((round(M.snamekmult)),20)]"
	if(M.Race=="Frost Demon")
		usr<<"<font color=blue>They have [M.icer_limit_forms] limiting forms."
		usr<<"<font color=blue>Form 5 @ [num2text((round(M.f5at)),20)]"
		usr<<"<font color=blue>Form 5 mult [M.f5mult]"

obj/Assess/verb/Assess(mob/M in world)
	set category="Other"
	AssessMob(M,usr)
mob/Admin2/verb
	Assess(mob/M in world)
		set category="Admin"
		AssessMob(M,usr)