/datum/skill/rank/KillDriver
	skilltype = "Ki"
	name = "Kill Driver"
	desc = "A stun attack that does damage in addition to a good stun."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE

/datum/skill/rank/KillDriver/after_learn()
	assignverb(/mob/keyable/verb/KillDriver)
	savant<<"You can fire an [name]!"

/datum/skill/rank/KillDriver/before_forget()
	unassignverb(/mob/keyable/verb/KillDriver)
	savant<<"You've forgotten how to fire an [name]!?"
datum/skill/rank/KillDriver/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/KillDriver)

mob/var/KillDrivericon='BasenioBlast.dmi'
/mob/keyable/verb/KillDriver()
	set category = "Skills"
	if(usr.Ki<50)
		usr<<"You do not yet have enough energy."
		return
	if(!usr.med&&!usr.train)
		if(!usr.KO&&usr.Ki>=50&&!usr.blasting)
			usr.blasting=1
			usr.Ki-=50*BaseDrain
			var/bicon=usr.bursticon
			bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
			var/image/I=image(icon=bicon,icon_state=usr.burststate)
			usr.overlayList+=I
			usr.overlaychanged=1
			spawn(50) usr.overlayList-=I
			spawn(50) usr.overlayList-=I
			spawn(50) usr.overlayList-=I
			usr.overlaychanged=1
			sleep(usr.Eactspeed)
			var/obj/attack/blast/A=new/obj/attack/blast/
			emit_Sound('disc_fire.wav')
			A.Burnout()
			A.paralysis=1
			A.deflectable=0
			A.shockwave=1
			A.icon=KillDrivericon
			A.loc=locate(usr.x,usr.y,usr.z)
			A.density=1
			A.basedamage=0.5
			A.BP=expressedBP
			A.mods=Ekioff*Ekiskill
			A.murderToggle=usr.murderToggle
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.dir=usr.dir
			A.Burnout()
			step(A,usr.dir)
			walk(A,usr.dir,2)
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.blasting=0