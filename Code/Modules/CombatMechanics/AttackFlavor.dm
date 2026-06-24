mob/var/list
	attackflavors = list("attacks")
	dodgeflavors = list("dodges")
	counterflavors = list("counters")
	weaponattackflavors = list("slices")
	weaponcounterflavors = list("parries") //no need for weapon 'dodge', since you don't 'slash' out of an attack, still body movement.

mob/var
	IsUsingWeapon
	tmp/WeaponUseTmp
	tmp/flvlog
mob/proc/GenerateAttackFlavors()
	var/list/flavorlist[3][]
	flavorlist[1] = attackflavors
	flavorlist[2] = dodgeflavors
	flavorlist[3] = counterflavors
	if(IsUsingWeapon||WeaponUseTmp)
		flavorlist[1] = weaponattackflavors
		flavorlist[2] = dodgeflavors
		flavorlist[3] = weaponcounterflavors
	if(currentStyle)
		flavorlist[1] += currentStyle.attackTextlist
		flavorlist[2] += currentStyle.dodgeTextlist
		flavorlist[3] += currentStyle.counterTextlist
		if (IsUsingWeapon||WeaponUseTmp)
			flavorlist[1] += currentStyle.attackTextlist
			flavorlist[2] += currentStyle.dodgeTextlist
			flavorlist[3] += currentStyle.counterTextlist
	return flavorlist

customFlavor
mob/proc/GenerateAttackFlavorText(var/attacktype,var/mob/M as mob,var/customflavor)
	var/list/flavorlist[][] = src.GenerateAttackFlavors()
	var/textstring = ""
	var/attackcolor = "red"
	var/list/tempvar = list()
	switch(attacktype)
		if(null)
			tempvar = flavorlist[1]
			var/randompick = tempvar.len
			textstring = flavorlist[1][rand(1,randompick)]
			if(customflavor) textstring = customflavor
			textstring = "[src] [textstring] [M]!"
		if("Attack")//okay, so I wanted to go null|"Attack" but it gave me "expected a constant expression" error. Thus, the seperate nature.
			tempvar = flavorlist[1]
			var/randompick = tempvar.len
			textstring = flavorlist[1][rand(1,randompick)]
			if(customflavor) textstring = customflavor
			textstring = "[src] [textstring] [M]!"
		if("Dodge")
			tempvar = flavorlist[2]
			var/randompick = tempvar.len
			textstring = flavorlist[2][rand(1,randompick)]
			attackcolor = "white"
			if(customflavor) textstring = customflavor
			textstring = "[src] [textstring] [M]!"
		if("Counter")
			tempvar = flavorlist[3]
			var/randompick = tempvar.len
			textstring = flavorlist[3][rand(1,randompick)]
			attackcolor = "yellow"
			if(customflavor) textstring = customflavor
			textstring = "[src] [textstring] [M]!"
	if(textstring == "")
	else
		if(isNPC)
			M.OutputAttack(textstring,attackcolor)
		else OutputAttack(textstring,attackcolor)
mob/proc/OutputAttack(var/S as text, var/C)
	if(usr.attack_flavor) view(usr)<<output("<font size=1 color=[C]>[S]!</font>","Chatpane.Chat")
	else view(usr)<<output("<font size=1 color=[C]>[S]!</font>","Attackpane.Chat")
