/datum/skill/rank/DeathBall
	skilltype = "Ki"
	name = "Death Ball"
	desc = "A guided ball blast. Very destructive, but also it drains a lot! Very accurate too, but you can't make this non-lethal. You can charge it up to four times its regular strength."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/rank/DeathBall/after_learn()
	assignverb(/mob/keyable/verb/Death_Ball)
	savant<<"You can fire an [name]!"

/datum/skill/rank/DeathBall/before_forget()
	unassignverb(/mob/keyable/verb/Death_Ball)
	savant<<"You've forgotten how to fire an [name]!?"
datum/skill/rank/DeathBall/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Death_Ball)

/mob/keyable/verb/Death_Ball()
	set category="Skills"
	var/KiReq = 150 * BaseDrain
	if(usr.Guiding)
		usr.Guiding=0
	else if(charging)
		charging = 0
	else if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=KiReq&&!usr.blasting&&!basicCD&&canfight)
			usr.blasting=1
			usr.move =0
			usr.Guiding=1
			usr.charging = 1
			basicCD += 15
			usr.icon_state="Planet Destroyer"
			var/movestrength = 1
			usr.emit_Sound('deathball_charge.wav')
			usr.Ki-=KiReq
			usr.blastcounter++
			//
			var/bicon=usr.bursticon
			bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
			var/image/C=image(icon=bicon,icon_state=usr.burststate)
			usr.overlayList+=C
			usr.overlaychanged=1
			spawn(50)
				usr.overlayList-=C
				usr.overlaychanged=1
			//
			var/obj/attack/A=new/obj/attack/blast
			var/icon/I = icon('deathball2017purple2.dmi')
			var/matrix/nA = new
			A.pixel_x = round(((32 - I.Width()) / 2),1)
			A.pixel_y = round(((32 - I.Height()) / 2),1)
			A.icon=I
			A.transform = nA
			A.plane = 6
			A.loc = locate(usr.x,usr.y+1,usr.z)
			A.density=1
			A.basedamage=40
			A.BP=expressedBP
			A.homingchance=0
			A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
			A.murderToggle=usr.murderToggle
			A.inaccuracy = max(50-Ekiskill*10-kicontrolskill-blastskill-guidedskill,0)
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.dir=usr.dir
			A.kishock=usr.kishock
			A.kiforceful=usr.kiforceful
			A.kiinterfere=usr.kiinterfere
			while(charging && A && movestrength < 4)
				sleep(15)
				movestrength += 1
				usr.Ki-=KiReq / 3
				KiReq += movestrength * 10
				usr.blastcounter++
				A.basedamage=10 * movestrength
				nA.Scale(1+movestrength/4,1+movestrength/4)
				A.transform = nA
				usr.emit_Sound('chargeincrease.ogg')
			if(A)
				spawn(usr.Ekioff*usr.Ekiskill*40) if(A) del(A)
				A.loc = get_step(usr,usr.dir)
				usr.emit_Sound('Blast.wav')
				//spawn A.BlastControl(1)
				spawn A.Burnout(1200)
				if(usr.target&&usr.target!=usr)
					spawn A.blasthoming(usr.target)
				//walk(A,A.dir)
				spawn while(A&&usr.Guiding)
					if(A&&A.loc)
						A.dir = usr.dir
					sleep(usr.Eactspeed/5)
				while(A&&A.loc&&usr.Guiding)
					sleep(usr.Eactspeed/5)
					usr.Blast_Gain()
					usr.blastcounter+=3
					usr.guidedcounter+=3
					step(A,A.dir)
			usr.Guiding = 0
			A.Burnout()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.icon_state="Planet Destroyer"
			usr.blasting=0
			usr.move = 1
			usr.Guiding = 0
			A.Burnout()