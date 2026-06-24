/datum/skill/tree
	proc/meta_ability()
		if(prob(1)&&prob(1))
			enableskill(new/datum/skill/rank/Fusion_Dance)
		if(!savant)
			return
		savant.meta_ability()

	meta
		name="Meta Racials"
		desc="Given to all Metamorians at the start."
		maxtier=2
		tier=0
		enabled=1
		allowedtier=2
		can_refund = FALSE
		compatible_races = list("Meta")
		constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
		new/datum/skill/rank/Fusion_Dance,new/datum/skill/meta/Stunlock,new/datum/skill/meta/Great_Robotic_Alliance)
		effector()
			..()
			meta_ability()

mob
	var/tmp/repairprotocolactivated = 0
	proc/meta_ability()
		if(HP<25) if(prob(1))
			if(!repairprotocolactivated)
				usr<<"Repair Protocol Activated."
				repairprotocolactivated = 1
				spawn MetaRepair()
		if(HP>=90&&repairprotocolactivated)
			sleep(400)
			repairprotocolactivated = 0


/datum/skill/meta/Stunlock
	skilltype = "misc"
	name = "Stunlock"
	desc = "Shoot a fast stunning projectile capable of knocking back others several tiles."
	can_forget = TRUE
	common_sense = TRUE
	teacher = TRUE
	tier = 2
	skillcost=2
	var/tmp/rps
	after_learn()
		savant.kiskillBuff+= 0.5
		assignverb(/mob/keyable/verb/Stunlock)
		savant<<"You feel capable of great stun hatred!"
	before_forget()
		savant.kiskillBuff-= 0.5
		unassignverb(/mob/keyable/verb/Stunlock)
		savant<<"Your intent to stun fades..."
	login()
		..()
		assignverb(/mob/keyable/verb/Stunlock)

mob/keyable/verb/Stunlock()
	set category = "Skills"
	if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=300*BaseDrain&&!usr.blasting&&!debuffCD)
			usr.blasting=1
			usr.kidebuffcounter+=2
			usr.Ki-=300*BaseDrain
			var/bicon=usr.bursticon
			bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
			var/image/I=image(icon=bicon,icon_state=usr.burststate)
			usr.overlayList+=I
			usr.overlaychanged=1
			spawn(5) usr.overlayList-=I
			usr.overlaychanged=1
			sleep(usr.Eactspeed)
			var/bcolor=ParalysisIcon
			bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
			var/obj/attack/blast/A=new /obj/attack/blast
			emit_Sound('absorb.wav')
			A.Burnout()
			A.deflectable=0
			A.paralysis=1
			A.icon=bcolor
			A.kiforceful=1
			A.icon_state="Paralysis"
			A.loc=locate(usr.x,usr.y,usr.z)
			A.density=1
			A.basedamage=0.1
			A.BP=expressedBP*log(11,max(kidebuffskill,10))
			A.mods=Ekioff*Ekiskill
			A.murderToggle=usr.murderToggle
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.dir=usr.dir
			A.Burnout()
			walk(A,usr.dir,2)
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			debuffCD = usr.Eactspeed*7
			spawn(debuffCD)
			debuffCD=0
			usr.blasting=0

/datum/skill/meta/Great_Robotic_Alliance
	skilltype = "Physical"
	name = "Great Robotic Alliance"
	desc = "Metamorians are best described as living robots. Their unique biology is not unlike human-sized transformers. Once upon a time, Metamorians were of many species. You may gain the traits of one of the three main races in the Metamorian Robotic Alliance."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	var/chosen
	proc/choose()
		switch(input(savant,"Choose a house to belong to. The Heuristic Tree will grant you Intellgience, Technique and Speed, along with some magical skill. The Great Sea Nanos were a waterborn tribe adept with Ki, and so will you. The Treaded Ones are a durable tribe with a emphasis on martial combat.") in list("The Heuristic Tree","Great Sea Nanos","Treaded Ones"))
			if("The Heuristic Tree")
				chosen = 1
				savant.techniqueBuff += 0.5
				savant.speedBuff += 0.5
				savant.genome.add_to_stat("Tech Modifier",3)
				savant.magiBuff += 3
			if("Great Sea Nanos")
				chosen = 2
				savant.kioffBuff += 1
				savant.kidefBuff += 1
				savant.kiskillBuff += 0.5
			if("Treaded Ones")
				chosen = 3
				savant.physoffBuff += 1
				savant.physdefBuff += 1
				savant.speedBuff += 0.5

	after_learn()
		choose()
		savant << "You have chosen..."
	before_forget()
		switch(chosen)
			if(1)
				savant.techniqueBuff -= 0.5
				savant.speedBuff -= 0.5
				savant.genome.add_to_stat("Tech Modifier",3)
				savant.magiBuff -= 3
			if(2)
				savant.kioffBuff -= 1
				savant.kidefBuff -= 1
				savant.kiskillBuff -= 0.5
			if(3)
				savant.physoffBuff -= 1
				savant.physdefBuff -= 1
				savant.speedBuff -= 0.5
		savant << "You lose your tribe..."
	login(var/mob/logger)
		..()
		if(!chosen)
			choose()