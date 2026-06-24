//whenever we make a new damage type, we should add it to these lists
var/list/GlobalDamageTypes = list("Physical",\
								"Energy",\
								"Fire",\
								"Ice",\
								"Shock",\
								"Poison",\
								"Dark",\
								"Holy",\
								"Almighty")

mob/var/list/DamageTypes = list("Physical" = 2,\
								"Energy" = 1,\
								"Fire" = 0,\
								"Ice" = 0,\
								"Shock" =0,\
								"Poison" =0,\
								"Dark" = 0,\
								"Holy" = 0,\
								"Almighty" = 0)//associative list of the player's damage values, these are flat values


mob/var/list/Resistances = list("Physical" = 1,\
								"Energy" = 1,\
								"Fire" = 1,\
								"Ice" = 1,\
								"Shock" =1,\
								"Poison" =1,\
								"Dark" = 1,\
								"Holy" = 1,\
								"Almighty" = 1)//associative list of the player's resistances, these are multipliers, e.g. 2 resist is 50% damage reduction

mob/proc/DtypeCheck()
	for(var/A in GlobalDamageTypes)
		if(isnull(DamageTypes[A]))
			DamageTypes[A] = 0
		if(isnull(Resistances[A]))
			Resistances[A] = 1

mob/var/typeoverride = null//variable for converting all damage to a particular type

mob/proc/Resistance(var/dmg,var/mob/M,sovrde)
	var/result = 0//we'll sum each of the damage components, then multiply by the dmg variable
	var/avg = 0
	for(var/a in DamageTypes)
		var/dtype = a
		if(typeoverride)
			dtype = typeoverride
		var/dam = M.ResistCheck(DamageTypes[a],dtype)//to account for type conversion
		if(!sovrde)
			if(dtype == "Physical")
				var/phystechcalc
				var/opponentphystechcalc
				if(!Ephysoff||!Etechnique||Ephysoff<1||Etechnique<1)
					phystechcalc = Ephysoff+Etechnique
				else
					phystechcalc = log(3,(Ephysoff**2)*log(3,(Etechnique)))+2
				if(!M.Ephysoff||!M.Etechnique||M.Ephysoff<1||M.Etechnique<1)
					opponentphystechcalc = M.Ephysdef+M.Etechnique
				else
					opponentphystechcalc = log(3,(M.Ephysoff**2)*log(3,(M.Etechnique)))+2
				dam=DamageCalc((phystechcalc),(opponentphystechcalc),dam)
			else if(dtype == "Energy")
				dam=DamageCalc(((Ekioff**2)*Ekiskill),((M.Ekidef**2)*M.Ekiskill),dam)
		result+=dam
		if(round(dam) >= 1) avg++
	var/outcome = dmg*(result/avg)
	return outcome




mob/proc/ResistCheck(var/dmg,var/dtype)
	if(!dtype)
		dtype = "Physical"
	var/resist = Resistances[dtype]
	var/result = dmg/resist
	return result