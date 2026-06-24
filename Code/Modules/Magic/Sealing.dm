//Z level 7 is yo area for universal sealage. The reason why the Dead Zone and Mafuba Jars and etc would be combined is just to allow OOC/slightly IC character interactions.
//The point of sealing is to stop interaction, but in a game, this shouldn't be a thing.
//Seals allow the sealed to observe their container, and speak through it.
//In the case of the Dead Zone, you are not able to speak through a container, but instead given more chances to escape.
//(since Garlic Jr. managed to obtain enough power to escape confinement. Hard limit of 40 billion, e.g. dimensional shit fails after 35 billion.)
//(Individual seals may fail before then depending on the user's power and container durability.)
//(Works like a scale. A seal based entirely on container durability would be set to the hard limit, but could easily break due to outside actions.)
//(Meanwhile, a user power based seal would have their expressed BP as the set limit, and can't be broken easily due to outside actions.)
//(Tradeoff is that the user's power is the expressed BP limit, the prisoner simply has to power up past it to escape.)
area
	EmptyArea //Sealed Grounds.
		name = "Sealed Grounds"
		icon_state=""
		layer=4
		Planet = "Sealed"
		PlayersCanSpawn = 1
		HasNight=0
		HasDay=0
		HasWeather=0
		HasMoon=0

mob/var
	isSealed = 0
	SealerBP = 0
	SealedContainerDur = 0
	SealedLocation
	SealHP = 100
	sealercontainersig
mob
	proc
		SealMob(var/SealingPersonBP,var/ContainerDur)
			isSealed = 1
			if(SealingPersonBP==0)
				SealerBP = 4.0e010 //40 billion. Stored in scientific notation for values past 2^31.
			else SealerBP = SealingPersonBP
			if(ContainerDur>0)
				SealedContainerDur = ContainerDur
			else
				SealedContainerDur = 0
			SealedLocation = locate(src.x,src.y,src.z)
			GotoPlanet("Sealed")
			spawn(1) TestEscape()

		TestEscape()
			set waitfor = 0
			if(BPModulus(expressedBP,SealerBP)>=1.25)
				UnSealMob()
			if(expressedBP > SealerBP)
				if(SealHP>=1) SealHP -= 0.001/SealedContainerDur
				else UnSealMob()
			if(SealedContainerDur<1&&SealedContainerDur!=0)
				sleep(1)
				var/hassealitem
				for(var/obj/items/SealingItem/O in world)
					sleep(1)
					if(sealercontainersig == O.signature)
						hassealitem = 1
				if(!hassealitem)
					SealedContainerDur = 0.25
				if(SealHP==100) src << "Your seal has weakened! You will return to the regular world if it isn't fixed!"
				if(SealHP>=1) SealHP -= 0.001/SealedContainerDur
				else UnSealMob()
			if(Planet!="Sealed")
				GotoPlanet("Sealed")
			if(!isSealed)
				UnSealMob()
		UnSealMob()
			if(isnull(SealedLocation)) src.GotoPlanet(spawnPlanet)
			else src.loc = locate(SealedLocation)
			SealedLocation = null
			SealedContainerDur = null
			SealerBP = null
			SealHP = 100
			isSealed = 0

var/list/sealed_released_sigs = list()

obj/Creatables
	Sealing_Jar
		icon = 'SealingJar.dmi'
		icon_state = "Open"
		cost=10000
		neededtech=10
		desc = "Sealing Jars are jars that are required for various sealing techniques. Suffice to say, if you don't have a sealing technique, you don't need it."
		create_type = /obj/items/SealingItem
obj/items
	SealingItem
		name = "Sealing Jar"
		desc = "A object to be used with a sealing technique."
		icon = 'SealingJar.dmi'
		icon_state = "Open"
		SaveItem = 1
		var/tmp/mob/Sealed = null
		var/tmp/mob/SealedSig = null
		var/signature = null
		var/SealedContainerDur = 1
		verb/Destroy_Container()
			set category = null
			set src in usr
			if(Sealed)
				Sealed.UnSealMob()
				Sealed = null
				SealedSig = null
			del(src)
		verb/Change_Container_Icon()
			set category = null
			set src in usr
			switch(alert(usr,"Default or custom icon? Remember, your custom sealing jar icon must have a \"Open\" state, and a \"Closed\" state.","","Default","Custom","Cancel"))
				if("Default")
					icon = 'SealingJar.dmi'
				if("Custom")
					icon = input(usr,"Sealing jar icon.","Choose the icon.") as icon
		proc/damagecontainer(dmg)
			dmg = max(dmg,0.5)
			SealedContainerDur -= 0.01*dmg

		proc/checkdur()
			set waitfor = 0
			if(Sealed)
				icon_state = "Closed"
				Sealed.SealedContainerDur = SealedContainerDur
				Sealed.SealedLocation = locate(src.x,src.y,src.z)
			if(SealedSig&&!Sealed&&prob(5))
				for(var/mob/M in mob_list)
					if(SealedSig==M.signature)
						Sealed = M
			if(SealedSig && SealedContainerDur <= 0)
				if(Sealed)
					Sealed.UnSealMob()
					SealedSig = null
				else
					sealed_released_sigs += SealedSig
			sleep(50)
			checkdur()

		New()
			..()
			signature = "[rand(1,9999)]"
			spawn(10) checkdur()
		Del()
			if(Sealed)
				spawn Sealed.UnSealMob()
			else if(SealedSig) sealed_released_sigs += SealedSig
			..()
//Mafuba
/datum/skill/rank/Mafuba/after_learn()
	assignverb(/mob/Rank/verb/Mafuba)
	savant<<"You learned the Mafuba!!"
/datum/skill/rank/Mafuba/before_forget()
	unassignverb(/mob/Rank/verb/Mafuba)
	savant<<"You've forgotten how to do the Mafuba?"
/datum/skill/rank/Mafuba/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Mafuba)

/mob/Rank/verb/Mafuba()
	set category = "Skills"
	var/list/SealingItems = list()
	for(var/obj/items/SealingItem/A in view())
		SealingItems.Add(A)
	var/obj/items/SealingItem/choice = input(usr,"Select the sealing item.","") as null|anything in SealingItems
	if(isnull(choice))
		src << "Canceled Mafuba."
		return
	var/mob/thesealed = input(usr,"Who to seal? This will take much of your HP!") as null|mob in view()
	if(isnull(thesealed))
		src << "Canceled Mafuba"
		return
	else
		var/obj/attack/blast/MafubaBlast/A  = new
		A.loc = locate(usr.x,usr.y,usr.z)
		step(A,usr.dir)
		A.density=1
		A.basedamage=0.1
		A.BP=expressedBP
		A.mods=Ekioff*Ekiskill
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		A.targetcontainer = choice
		spawn(70) del(A)
		walk_to(A,thesealed)
		spawn A.checkradius(thesealed)
		thesealed.sealercontainersig = choice.signature
		choice.Sealed = thesealed
		choice.SealedSig = thesealed.signature
		SpreadDamage(90)
		if(HP<=0)
			src.Death()

obj/attack/blast/MafubaBlast
	icon = 'Mafuba.dmi'
	var/SealStrength = 0
	var/DidSeal
	var/obj/items/SealingItem/targetcontainer = null
	proc/checkradius(var/mob/M)
		if(get_dist(src.loc,M.loc)<= 1)
			var/obj/MafubaEffect/B = new
			B.targetcontainer = targetcontainer
			B.loc = locate(src.x,src.y,src.z)
			DidSeal = 1
			M.SealMob(SealStrength,1)
			M.SealedLocation = locate(M.x,M.y,M.z)
			targetcontainer.Sealed = M
			targetcontainer.SealedSig = M.signature
			view()<<"[M] got sealed by the Mafuba!"
			spawn(5) del(src)
		sleep(2)
		checkradius(M)
obj/MafubaEffect
	icon = 'Mafuba.dmi'
	icon_state = "return"
	density = 0
	plane = 8
	var/obj/items/SealingItem/targetcontainer = null
	New()
		..()
		spawn(1) check()
	proc/check()
		if(targetcontainer&&1<=get_dist(src.loc,targetcontainer.loc))
			step(src,get_dir(src.loc,targetcontainer.loc))
		else if(targetcontainer)
			icon_state = "home"
			spawn(6) del(src)
		spawn(1) check()

//Deadzone
/datum/skill/rank/DeadZone/after_learn()
	assignverb(/mob/Rank/verb/Open_Dead_Zone)
	savant<<"You learn how to open the fabric of reality itself to banish evil."
/datum/skill/rank/DeadZone/before_forget()
	unassignverb(/mob/Rank/verb/Open_Dead_Zone)
	savant<<"You've forgotten how to command reality to banish evil!"
/datum/skill/rank/DeadZone/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Open_Dead_Zone)

/mob/Rank/verb/Open_Dead_Zone()
	set category = "Skills"
	if(/obj/DeadZone in view())
		return
	if(usr.Ki>=MaxKi/1.1)
	else
		usr<<"You don't have enough Ki."
		return
	view(6)<<"[usr] rips open reality and a portal to the dead zone appears!!"
	emit_Sound('NEWSKILL.WAV')
	var/obj/DeadZone/A  = new
	A.loc = locate(usr.x,usr.y+5,usr.z)
	A.makerBP = expressedBP
	if(usr.Ki>=MaxKi/1.1)
		usr.Ki -= MaxKi/1.1

obj/DeadZone
	var/makerBP
	icon='Portal.dmi'
	icon_state="center"
	New()
		..()
		var/image/A=image(icon='Portal.dmi',icon_state="n")
		var/image/B=image(icon='Portal.dmi',icon_state="e")
		var/image/C=image(icon='Portal.dmi',icon_state="s")
		var/image/D=image(icon='Portal.dmi',icon_state="w")
		var/image/E=image(icon='Portal.dmi',icon_state="ne")
		var/image/F=image(icon='Portal.dmi',icon_state="nw")
		var/image/G=image(icon='Portal.dmi',icon_state="sw")
		var/image/H=image(icon='Portal.dmi',icon_state="se")
		A.pixel_y+=32
		B.pixel_x+=32
		C.pixel_y-=32
		D.pixel_x-=32
		E.pixel_y+=32
		E.pixel_x+=32
		F.pixel_y+=32
		F.pixel_x-=32
		G.pixel_y-=32
		G.pixel_x-=32
		H.pixel_y-=32
		H.pixel_x+=32
		overlays+=A
		overlays+=B
		overlays+=C
		overlays+=D
		overlays+=E
		overlays+=F
		overlays+=G
		overlays+=H
		emit_Sound('rockmoving.wav')
		spawn while(src)
			sleep(1)
			for(var/mob/M in oview(12,src)) if(prob(20)&&!M.expandlevel)
				M.move=1
				step_towards(M,src)
			for(var/mob/M in view(0,src))
				view(12,src)<<"[M] is sucked into the dead zone!!"
				M.SealMob(makerBP,0)
			spawn(100) del(src)


//Sealing
/datum/skill/rank/SuperiorSeal/after_learn()
	assignverb(/mob/Rank/verb/Seal_Mob)
	savant<<"You learn how to make flexible seals. Seal by selecting a mob, and a ritual will be generated using your Ki as magic energy."
/datum/skill/rank/SuperiorSeal/before_forget()
	unassignverb(/mob/Rank/verb/Seal_Mob)
	savant<<"You've forgotten how to make seals!?"
/datum/skill/rank/SuperiorSeal/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Seal_Mob)

/mob/Rank/verb/Seal_Mob()
	set category = "Skills"
	var/choice = input(usr,"Select a mob in view. A ritual will target them. The sealing effect will be effective somewhat up to your BP, as long as the generated item is kept safe.") as null|mob in view()
	if(isnull(choice))
		usr << "You choose not to seal anything."
		return
	var/obj/items/SealingItem/B = new
	B.loc = locate(usr.x,usr.y,usr.z)
	var/obj/Ritual/nR = new(loc)
	nR.visual_activation()
	nR.SaveItem = 0
	nR.Magic += Magic * Emagiskill
	Magic -= Magic
	nR.Magic += convert_ki_to_magic_e(Ki) * Emagiskill
	Ki-=Ki
	nR.invoker = src
	var/emag = Emagiskill
	var/magnitude = max(1,log(7,nR.Magic*10)) * emag
	sleep(10)
	nR.r_target = choice
	nR.do_tietary("e_seal_s",magnitude)
	sleep(10)
	nR.post_ritual()
	del(nR)
	return