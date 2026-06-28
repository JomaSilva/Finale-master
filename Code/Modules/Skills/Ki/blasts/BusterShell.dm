/datum/skill/rank/BusterShell
	skilltype = "Ki"
	name = "Buster Shell"
	desc = "A multiball blast."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/rank/BusterShell/after_learn()
	assignverb(/mob/keyable/verb/BusterShell)
	to_chat(savant, "You can fire an [name]!")

/datum/skill/rank/BusterShell/before_forget()
	unassignverb(/mob/keyable/verb/BusterShell)
	to_chat(savant, "You've forgotten how to fire an [name]!?")
datum/skill/rank/BusterShell/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/BusterShell)

mob/var/BusterShellIcon='deathball.dmi'
/mob/keyable/verb/BusterShell()
	set category="Skills"
	if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=4&&!usr.blasting)
			usr.blasting=1
			usr.Ki-=4+BaseDrain
			var/bicon=usr.bursticon
			bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
			var/image/I=image(icon=bicon,icon_state=usr.burststate)
			usr.overlayList+=I
			usr.overlaychanged=1
			spawn(50) usr.overlayList-=I
			spawn(50) usr.overlayList-=I
			spawn(50) usr.overlayList-=I
			usr.overlaychanged=1
			sleep(usr.Eactspeed*2)
			var/balls=0
			while(balls<4)
				usr.emit_Sound('burning_fire.wav')
				balls+=1
				var/obj/attack/blast/A=new/obj/attack/blast/
				spawn(usr.Ekioff*usr.Ekiskill) if(A) del(A)
				A.icon=usr.DEATHBALLICON
				A.icon+=rgb(usr.blastR,usr.blastG,usr.blastB)
				A.icon_state="small"
				A.dir=usr.dir
				A.mega=1
				A.loc=locate(usr.x,usr.y,usr.z)
				step(A,A.dir)
				A.density=1
				A.basedamage=0.5
				A.BP=expressedBP
				A.mods=Ekioff*Ekiskill
				A.murderToggle=usr.murderToggle
				A.proprietor=usr
				A.ownkey=usr.displaykey
				A.dir=usr.dir
				A.Burnout()
				spawn A.BusterShell()
				A.density=0
				spawn walk(A,usr.dir,2)
				A.density=1
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.blasting=0

obj/proc/BusterShell()
	while(src)
		if(dir==NORTH|dir==SOUTH)
			x+=1
			sleep(1)
			x-=1
		else
			y+=1
			sleep(1)
			y-=1
		sleep(1)