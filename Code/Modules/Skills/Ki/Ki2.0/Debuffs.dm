mob/var
	tmp/debuffCD = 0
/mob/keyable/verb/Paralysis()
	set category = "Skills"
	if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=700*BaseDrain&&!usr.blasting&&!debuffCD)
			usr.blasting=1
			usr.kidebuffcounter+=5
			usr.Ki-=700*BaseDrain
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
			var/obj/attack/blast/A=new /obj/attack/blast/
			usr.emit_Sound('absorb.wav')
			A.Burnout()
			A.deflectable=0
			A.paralysis=1
			A.icon=bcolor
			A.icon_state="Paralysis"
			A.loc=locate(usr.x,usr.y,usr.z)
			A.density=1
			A.basedamage=0.1
			A.BP=expressedBP*log(10,max(kidebuffskill,10))
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
			debuffCD = usr.Eactspeed*6
			spawn(debuffCD)
			debuffCD=0
			usr.blasting=0

/mob/keyable/verb/Shackle()
	set category = "Skills"
	if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=900&&!usr.blasting&&usr.target&&!debuffCD)
			usr.blasting=1
			usr.kidebuffcounter+=6
			usr.Ki-=900*BaseDrain
			var/timer = round(Ekiskill+kidebuffskill/10, 1)
			spawn target.updateOverlay(/obj/overlay/effects/interfereaura)
			var/debuff = max(1/log(10,Ekiskill*kidebuffskill/10),0.5)
			if(target.Tspeed-debuff>0.1)
				target.Tspeed-= debuff
			else
				debuff = target.Tspeed-0.1
				target.Tspeed-= debuff
			debuffCD=usr.Eactspeed*10
			usr.blasting=0
			while(timer)
				timer--
				sleep(10)
			target.Tspeed+= debuff
			spawn target.removeOverlay(/obj/overlay/effects/interfereaura)
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			spawn(debuffCD)
			debuffCD=0
		else if(debuffCD)
			usr<<"You can't do this yet!"
		else if(!usr.target)
			usr<<"You need a target to use this."
		else
			usr<<"You cannot do this right now."
