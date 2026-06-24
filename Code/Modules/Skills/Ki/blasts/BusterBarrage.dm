/datum/skill/rank/BusterBarrage
	skilltype = "Ki"
	name = "Buster Barrage"
	desc = "A absolute wave of blasts, this fucker will guarentee destroy anything in your path."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=0

/datum/skill/rank/BusterBarrage/after_learn()
	assignverb(/mob/keyable/verb/BusterBarrage)
	savant<<"You can fire an [name]!"

/datum/skill/rank/BusterBarrage/before_forget()
	unassignverb(/mob/keyable/verb/BusterBarrage)
	savant<<"You've forgotten how to fire an [name]!?"
datum/skill/rank/BusterBarrage/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/BusterBarrage)
mob/var/tmp/firstfire
mob/var/tmp/USEDUNDERLAY
mob/var/BusterBarrageIcon='Brolly1.dmi'
/mob/keyable/verb/BusterBarrage()
	set category="Skills"
	if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=1)
			if(!usr.blasting)
				usr.blasting=1
				USEDUNDERLAY=BusterBarrageIcon
				USEDUNDERLAY+=rgb(usr.blastR,usr.blastG,usr.blastB)
				usr.overlayList+=USEDUNDERLAY
				usr.overlaychanged=1
				spawn while(usr.blasting)
					if(usr.Ki>=1&&!usr.KO&&!usr.med&&!usr.train)
						usr.Ki-=1*BaseDrain
						if(!firstfire)
							usr<<"<font size=1>Press it again to stop firing."
							firstfire=1
						usr.emit_Sound('fire_kiblast.wav')
						var/obj/attack/blast/A = usr.Create_Blast()
						spawn(3) if(A)
							A.x+=rand(-1,1)
							A.y+=rand(-1,1)
						var/dir=rand(1,8)
						if(dir==1) A.dir=NORTH
						if(dir==2) A.dir=SOUTH
						if(dir==3) A.dir=EAST
						if(dir==4) A.dir=WEST
						if(dir==5) A.dir=NORTHWEST
						if(dir==6) A.dir=NORTHEAST
						if(dir==7) A.dir=SOUTHWEST
						if(dir==8) A.dir=SOUTHEAST
						walk(A,A.dir,rand(1,2))
						spawn((usr.kiskill*50*usr.kioff)) if(A) del(A)
						usr.Blast_Gain()
						sleep(usr.Eactspeed/4)
						var/obj/attack/blast/B = usr.Create_Blast()
						dir=rand(1,8)
						if(dir==1) B.dir=NORTH
						if(dir==2) B.dir=SOUTH
						if(dir==3) B.dir=EAST
						if(dir==4) B.dir=WEST
						if(dir==5) B.dir=NORTHWEST
						if(dir==6) B.dir=NORTHEAST
						if(dir==7) B.dir=SOUTHWEST
						if(dir==8) B.dir=SOUTHEAST
						spawn(3) if(B)
							B.x+=rand(-1,1)
							B.y+=rand(-1,1)
						spawn(1) usr.emit_Sound('fire_kiblast.wav')
						walk(B,B.dir,rand(1,2))
						spawn((usr.kiskill*50*usr.kioff)) if(B) del(B)
						usr.Blast_Gain()
						sleep(usr.Eactspeed/2)
					else
						usr.overlayList-=USEDUNDERLAY
						usr.overlaychanged=1
						usr.blasting=0
						firstfire=0
			else
				usr.overlayList-=USEDUNDERLAY
				usr.overlaychanged=1
				usr.blasting=0
				firstfire=0

