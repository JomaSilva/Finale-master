mob/var/tmp/kienzanCD

/*/datum/skill/ki/kienzan
	skilltype = "Ki"
	name = "Destructo Disc"
	desc = "The user learns to concentrate their Ki into a blisteringly sharp disc."
	level = 1
	tier=1
	expbarrier = 1
	maxlevel = 0
	skillcost = 2
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list()

datum/skill/ki/kienzan/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Destructo_Disc)
/datum/skill/ki/kienzan/after_learn()
	savant << "You feel a new power welling up inside you."
	assignverb(/mob/keyable/verb/Destructo_Disc)
/datum/skill/ki/kienzan/before_forget()
	savant << "You can't remember how to use Destructo Disc!"
	unassignverb(/mob/keyable/verb/Destructo_Disc)*/

mob/keyable/verb/Kienzan()
	set category="Skills"
	var/kireq=100*BaseDrain
	if(!usr.KO&&!usr.med&&!usr.train&&!usr.blasting&&!usr.Guiding&&usr.canfight)
		if(usr.Ki>=kireq)
			usr.blasting=1
			usr.Guiding=1
			usr.icon_state="Planet Destroyer"
			var/bicon=usr.bursticon
			bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
			var/image/I=image(icon='Kienzan.dmi')
			I.icon+=rgb(usr.blastR,usr.blastG,usr.blastB)
			I.pixel_y+=18
			usr.overlayList+=I
			usr.overlaychanged=1
			usr.Blast_Gain()
			usr.Blast_Gain()
			sleep(2*usr.Eactspeed)
			usr.overlayList-=I
			usr.overlaychanged=1
			usr.icon_state=""
			usr.Ki-=kireq
			usr.move=0
			var/bcolor='Kienzan.dmi'
			bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
			var/obj/attack/blast/A=new/obj/attack/blast
			usr.emit_Sound('disc_fire.wav')
			A.loc=locate(usr.x,(usr.y+1),usr.z)
			A.icon=bcolor
			sleep(5)
			if(A)
				A.density=1
				A.basedamage=25
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
				spawn A.ZigZag()
				if(usr.target&&usr.target!=usr)
					spawn A.blasthoming(usr.target)
				spawn A.Burnout(1200)
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
				usr.emit_Sound('burning_fire.wav')
			spawn while(A&&usr.Guiding)
				if(A&&A.loc)
					A.dir = usr.dir
				sleep(usr.Eactspeed/10)
			while(A&&A.loc&&usr.Guiding)
				sleep(usr.Eactspeed/8)
				usr.Blast_Gain()
				usr.guidedcounter+=2
				step(A,A.dir)
			usr.Guiding = 0
		else usr<<"You dont have enough energy."
	else if(usr.Guiding)
		usr.Guiding=0

obj/proc/ZigZag()
	spawn while(src)
		if(dir==NORTH|dir==SOUTH)
			if(src) pixel_x+=16
			sleep(1)
			if(src) pixel_x-=16
			sleep(1)
			if(src) pixel_x-=16
			sleep(1)
			if(src) pixel_x+=16
		else if(dir==EAST|dir==WEST)
			if(src) pixel_y+=16
			sleep(1)
			if(src) pixel_y-=16
			sleep(1)
			if(src) pixel_y-=16
			sleep(1)
			if(src) pixel_y+=16
		else sleep(1)