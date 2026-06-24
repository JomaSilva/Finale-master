/*/datum/skill/rank/GuidedBall
	skilltype = "Ki"
	name = "Guided Ball"
	desc = "A guided ball blast."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/rank/GuidedBall/after_learn()
	assignverb(/mob/keyable/verb/GuidedBall)
	savant<<"You can fire an [name]!"

/datum/skill/rank/GuidedBall/before_forget()
	unassignverb(/mob/keyable/verb/GuidedBall)
	savant<<"You've forgotten how to fire an [name]!?"
datum/skill/rank/GuidedBall/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/GuidedBall)*/

mob/var/GuideBombIcon='30.dmi'
/mob/keyable/verb/Guided_Ball()
	set category = "Skills"
	if(!usr.KO&&!usr.med&&!usr.train&&!usr.blasting&&!usr.Guiding&&usr.canfight)
		if(usr.Ki>=50*BaseDrain)
			usr.blasting=1
			usr.Guiding=1
			usr.icon_state="Planet Destroyer"
			emit_Sound('basicbeam_chargeoriginal.wav')
			spawn(50) usr.icon_state=""
			usr.Ki-=600*BaseDrain
			usr.move=0
			var/bcolor=GuideBombIcon
			bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
			var/obj/attack/blast/A=new/obj/attack/blast
			A.loc=locate(usr.x,(usr.y+1),usr.z)
			var/turf/T = A.loc
			if(T)
				if(T.density)
					del(A)
					sleep(10)
					usr.Guiding = 0
					usr.blasting=1
					return
			A.icon=bcolor
			sleep(5)
			if(A)
				A.density=1
				A.basedamage=15
				A.BP=expressedBP
				A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))
				A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
				A.murderToggle=usr.murderToggle
				A.inaccuracy = max(50-Ekiskill*10-kicontrolskill-blastskill-guidedskill,0)
				A.proprietor=usr
				A.ownkey=usr.displaykey
				A.dir=usr.dir
				A.kishock=usr.kishock
				A.kiforceful=usr.kiforceful
				A.kiinterfere=usr.kiinterfere
				spawn A.BlastControl(1)
				spawn A.Burnout(1200)
				if(usr.target&&usr.target!=usr)
					spawn A.blasthoming(usr.target)
			usr.move=1
			usr.blasting=0
			usr.Blast_Gain()
			usr.Blast_Gain()
			sleep(usr.Eactspeed/8)
			if(A&&A.loc)
				A.density=0
				step(A,usr.dir)
				step(A,usr.dir)
				if(A) A.density=1
				emit_Sound('burning_fire.wav')
			spawn while(A&&usr.Guiding)
				if(A&&A.loc)
					A.dir = usr.dir
				sleep(usr.Eactspeed/10)
			while(A&&A.loc&&usr.Guiding)
				sleep(usr.Eactspeed/10)
				usr.Blast_Gain()
				usr.blastcounter++
				usr.guidedcounter++
				step(A,A.dir)
			usr.Guiding = 0
			A.Burnout()
		else usr<<"You dont have enough energy."
	else if(usr.Guiding)
		usr.Guiding=0

mob/var/DEATHBALLICON='deathball2017purple2.dmi'
mob/var/tmp/Guiding //Using a guided ability or not...