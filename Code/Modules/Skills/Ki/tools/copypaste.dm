//to use on creating blast attacks - completely replaces vanilla blast attack shit. its a wip and should be replaced post-release
mob/proc/Create_Blast(var/basedamage as num,var/deflectMod as num,ispiercer as num,var/permKillbuff as num, var/walk as num,var/icon)
	var/obj/attack/A=new/obj/attack/blast/
	if(!basedamage)
		basedamage=0.5+Ekioff
	if(!deflectMod)
		deflectMod=1
	if(!permKillbuff)
		permKillbuff=0
	if(ispiercer)
		A.piercer=1
	if(!icon)
		icon = BLASTICON
	A.layer=MOB_LAYER+2
	A.density=1
	spawn(3)
		if(A)
			if(!A.WaveAttack)
				A.density = 1 //automagically handles beam density. //lol revising this density needs to be on for the blast to hit shit lol -assfaggot
	A.loc=locate(usr.x,usr.y,usr.z)
	A.icon=icon
	A.icon_state=usr.BLASTSTATE
	A.basedamage=basedamage*Ephysoff
	A.BP=usr.expressedBP
	A.mods=Ekioff*Ekiskill
	A.murderToggle=usr.murderToggle
	A.deflectMod = deflectMod
	A.permKillbuff = permKillbuff
	A.proprietor=usr
	A.ownkey=usr.displaykey
	A.dir=usr.dir
	A.transform *= kiratio
	A.wavemultipl = kiratio
	if(walk)
		walk(A,A.dir,0,5)
		A.Burnout()
	return A

obj/attack/proc/Copy_Blast()
	var/obj/attack/A=new/obj/attack/blast/
	A.layer=MOB_LAYER+2
	A.density=1
	A.loc=locate(x,y,z)
	A.icon=icon
	A.icon_state=icon_state
	A.basedamage=basedamage
	A.BP=BP
	A.mods=mods
	A.dir=dir
	A.transform *= wavemultipl
	A.wavemultipl = wavemultipl
	A.murderToggle=murderToggle
	A.deflectMod = deflectMod
	A.permKillbuff = permKillbuff
	A.proprietor=proprietor
	A.ownkey=ownkey
	A.WaveAttack=WaveAttack
	A.deflected=1
	if(WaveAttack)
		A.distance=distance
	else
		A.Burnout()
	return A