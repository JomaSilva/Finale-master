turf/Click(turf/T)
	if(istype(usr,/mob))
		if(usr.psythre)
			if(!usr.med&&!usr.train)
				if(!usr.KO&&usr.Ki>=700*usr.BaseDrain&&!usr.blasting&&!usr.debuffCD)
					usr.blasting=1
					usr.kidebuffcounter+=5
					usr.Ki-=100*usr.BaseDrain
					var/bicon=usr.bursticon
					bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
					var/image/I=image(icon=bicon,icon_state=usr.burststate)
					usr.overlayList+=I
					usr.overlaychanged=1
					spawn(5) usr.overlayList-=I
					usr.overlaychanged=1
					sleep(usr.Eactspeed)
					var/bcolor=usr.ParalysisIcon
					bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
					var/obj/attack/blast/A=new /obj/attack/blast/
					usr.emit_Sound('absorb.wav')
					spawn A.Burnout()
					A.deflectable=0
					A.paralysis=1
					A.icon=bcolor
					A.icon_state="Paralysis"
					A.loc=locate(usr.x,usr.y,usr.z)
					A.density=1
					A.basedamage=0.1
					A.BP=usr.expressedBP*log(11,max(usr.kidebuffskill,10))
					A.mods=usr.Ekioff*usr.Ekiskill
					A.murderToggle=usr.murderToggle
					A.proprietor=usr
					A.ownkey=usr.displaykey
					A.dir=usr.dir
					spawn A.Burnout()
					usr.Blast_Gain()
					usr.Blast_Gain()
					usr.Blast_Gain()
					usr.Blast_Gain()
					usr.debuffCD = usr.Eactspeed*6
					spawn(usr.debuffCD)
					usr.debuffCD=0
					usr.blasting=0
		if(usr.isbuilding&&usr.buildpath)
			if(!usr.KO&&usr.move&&get_dist(usr,T)<=2)
				if(!T.Exclusive&&T.destroyable&&(T.Free||T.proprietor==usr.ckey))
					usr.BuildATileHere(locate(T.x,T.y,T.z))
					return
turf/DblClick(turf/T)
	if((usr.Ekiskill*(usr.Espeed/2))&&usr.haszanzo)
		var/kireq=(6*usr.BaseDrain)/(usr.Ekiskill*(usr.Espeed/2))
		if(T) if(T.icon && T.z == usr.z&&!T.density&&get_dist(usr,T)<=usr.zanzorange)
			for(var/turf/A in view(0,usr)) if(A==src) return
			if(usr.move&&!usr.Apeshit&&!usr.KB&&!usr.beaming&&!usr.KO&&!usr.med&&!usr.train&&usr.Ki>=(kireq*get_dist(usr,T)))
				if(usr.telestopping)
					usr.telestopping = 0
					usr.telestop()
				flick('Zanzoken.dmi',usr)
				emit_Sound('teleport.wav')
				var/hopdist=get_dist(usr,T)
				var/formerdir=usr.dir
				usr.Move(src)
				usr.dir=formerdir
				usr.Ki-=kireq*hopdist
				usr.zanzochange++
				if(usr.Ki<0) usr.Ki=0

turf/MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
	var/turf/T = over_location
	if(istype(usr,/mob) && isturf(T))
		if(usr.isbuilding&&usr.buildpath)
			if(!usr.KO&&usr.move&&get_dist(usr,T)<=2)
				if(!T.Exclusive&&T.destroyable&&(T.Free||T.proprietor==usr.ckey))
					usr.BuildATileHere(locate(T.x,T.y,T.z))
					return

obj/DblClick(obj/O)
	if(istype(usr,/mob))
		if(usr.isbuilding&&usr.buildpath)
			if(!usr.KO&&usr.move&&get_dist(usr,O)<=2)
				if(!O.Exclusive&&(O.Free||O.proprietor==usr.ckey))
					usr.BuildATileHere(locate(O.x,O.y,O.z))
					return
	..()