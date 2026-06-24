mob/var
	blastcount
	tmp
		blasting=0//to check if they're using a blast
		basicCD
		scatterCD
		eshotCD
		barrageCD
		targetedCD
		canfight=1 //important: refreshes whether or not you can do other things! DO NOT MANUALLY CHANGE, IT IS HANDLED IN MOVEMENT HANDLER.
		dirlock=0
		volleying=0
		kitargeting=0

/*/datum/skill/ki/blast
	skilltype = "Ki"
	name = "Ki Emission"
	desc = "The user learns to emit Ki from their body in a semisolid form.\n(practice makes perfect)"
	level = 0
	expbarrier = 1
	maxlevel = 0
	skillcost = 1
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list()
	var/hasbeenenabled=0
	var/accum
datum/skill/ki/blast/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Ki_Blast)

/datum/skill/ki/blast/after_learn()
	savant << "You can feel something bubbling in your palm."
	assignverb(/mob/keyable/verb/Ki_Blast)

/datum/skill/ki/blast/before_forget()
	savant << "You can't remember how to use Ki Blast skills!"
	unassignverb(/mob/keyable/verb/Ki_Blast)*///essentially legacy content at this point

mob/keyable/verb/Basic_Blast()
	set category = "Skills"
	desc = "A basic projectile formed from the user's ki"
	var/kireq=10*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!basicCD&&canfight)
		var/passbp = 0
		blasting=1
		blastcount+=1
		var/reload=Eactspeed/5
		if(reload<3)reload=3
		basicCD+=reload
		usr.Ki-=kireq
		passbp=expressedBP
		usr.Blast_Gain()
		usr.blastcounter++
		var/bcolor=usr.BLASTICON
		bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
		var/obj/attack/blast/A=new/obj/attack/blast
		usr.emit_Sound('fire_kiblast.wav')
		A.loc=locate(usr.x,usr.y,usr.z)
		A.icon=bcolor
		A.icon_state=usr.BLASTSTATE
		A.avoidusr=1
		A.density=1
		A.basedamage=1*Ekioff*log(10,max(blastskill,10))
		A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))//until you learn homing, your shots won't home at all
		A.BP=passbp
		A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		A.ogdir=usr.dir
		A.inaccuracy = max(50-Ekiskill*10-kicontrolskill-blastskill,0)
		A.kishock=usr.kishock
		A.kiforceful=usr.kiforceful
		A.kiinterfere=usr.kiinterfere
		spawn A.Burnout()
		walk(A,usr.dir)
		spawn A.BlastControl()
		if(usr.target&&usr.target!=usr)
			spawn A.blasthoming(usr.target)
		usr.icon_state="Blast"
		spawn(3) usr.icon_state=""
		blasting=0


mob/keyable/verb/Charged_Shot()
	set category = "Skills"
	desc = "A charged version of the basic blast."
	var/kireq=50*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!basicCD&&canfight)
		var/passbp = 0
		blastcount+=1
		basicCD+=20
		usr.Ki-=kireq
		passbp=expressedBP*1.2
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.blastcounter+=5
		usr.chargedcounter+=5
		blasting=1
		var/bcolor='20.dmi'
		bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
		usr.updateOverlay(/obj/overlay/effects/flickeffects/kicharge)
		usr.removeOverlay(/obj/overlay/effects/flickeffects/kicharge)
		var/obj/attack/blast/A=new/obj/attack/blast
		usr.emit_Sound('fire_kiblast.wav')
		A.loc=locate(usr.x,usr.y,usr.z)
		A.icon=bcolor
		A.icon_state=usr.BLASTSTATE
		A.avoidusr=1
		A.density=1
		A.basedamage=2*Ekioff*log(10,max(blastskill,10))*globalKiDamage
		A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))//until you learn homing, your shots won't home at all
		A.BP=passbp
		A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		A.ogdir=usr.dir
		A.inaccuracy = max(50-Ekiskill*10-kicontrolskill-blastskill,0)
		A.kishock=usr.kishock
		A.kiforceful=usr.kiforceful
		A.kiinterfere=usr.kiinterfere
		spawn A.Burnout()
		step(A,usr.dir)
		walk(A,usr.dir)
		spawn A.BlastControl()
		if(usr.target&&usr.target!=usr)
			spawn A.blasthoming(usr.target)
		usr.icon_state="Blast"
		spawn(3) usr.icon_state=""
		blasting=0
mob/var/bonusShots
mob/keyable/verb/Scattershot()
	set category = "Skills"
	desc = "Unleash several blasts at once!"
	var/amount=8+bonusShots+round(log(usr.blastskill))+round(log(usr.volleyskill))
	var/kireq=amount*40*BaseDrain
	var/curdir=usr.dir
	var/reload
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!barrageCD&&canfight)
		dirlock=1
		reload=Eactspeed*5
		if(reload<2)reload=2
		usr.barrageCD=reload
		usr.Ki-=kireq
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.blastcounter+=amount
		usr.homingcounter+=amount
		usr.volleycounter+=amount
		blasting=1
		usr.icon_state="Blast"
		var/bicon=usr.BLASTICON
		bicon+=rgb(usr.blastR,usr.blastG,usr.blastB)
		while(amount)
			blastcount+=1
			var/obj/attack/blast/A=new/obj/attack/blast
			usr.emit_Sound('KIBLAST.WAV')
			A.icon=bicon
			spawn A.Burnout()
			A.avoidusr=1
			A.basedamage=1.2*Ekioff*log(10,max(blastskill,10))*globalKiDamage
			A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))
			A.BP=expressedBP
			A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
			A.icon_state=usr.BLASTSTATE
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.loc=locate(usr.x,usr.y,usr.z)
			A.density=1
			A.dir=curdir
			A.ogdir=usr.dir
			A.murderToggle=usr.murderToggle
			A.inaccuracy = max(50-Ekiskill*10-kicontrolskill-blastskill,0)
			A.kishock=usr.kishock
			A.kiforceful=usr.kiforceful
			A.kiinterfere=usr.kiinterfere
			spawn A.BlastControl()
			if(usr.target&&usr.target!=usr)
				spawn A.blasthoming(usr.target)
			var/randdir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
			step(A,randdir)
			step(A,randdir)
			step(A,randdir)
			walk(A,curdir)
			amount-=1
			sleep(2)
		dirlock=0
		spawn(3) usr.icon_state=""
		blasting=0
		sleep(reload)
		usr.barrageCD=0
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(barrageCD) usr<<"This skill was set on cooldown for [barrageCD/10] seconds."

mob/keyable/verb/Energy_Barrage()
	set category = "Skills"
	desc = "Fire a barrage of energy blasts"
	var/amount=10+bonusShots+round(log(usr.blastskill))+round(log(usr.volleyskill))
	var/kireq=amount*15*BaseDrain
	var/curdir=usr.dir
	var/reload
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!barrageCD&&canfight)
		dirlock=1
		reload=Eactspeed*2
		if(reload<2)reload=2
		usr.barrageCD=reload
		usr.Ki-=kireq
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.blastcounter+=amount
		usr.volleycounter+=amount
		blasting=1
		usr.icon_state="Blast"
		var/bicon=usr.BLASTICON
		bicon+=rgb(usr.blastR,usr.blastG,usr.blastB)
		while(amount)
			blastcount+=1
			var/obj/attack/blast/A=new/obj/attack/blast
			usr.emit_Sound('KIBLAST.WAV')
			A.icon=bicon
			spawn A.Burnout()
			A.avoidusr=1
			A.basedamage=0.8*Ekioff*log(10,max(blastskill,10))*globalKiDamage
			A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))
			A.BP=expressedBP
			A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
			A.icon_state=usr.BLASTSTATE
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.loc=locate(usr.x,usr.y,usr.z)
			step(A,curdir)
			A.density=1
			A.dir=curdir
			A.ogdir=usr.dir
			A.murderToggle=usr.murderToggle
			A.inaccuracy = max(60-Ekiskill*10-kicontrolskill-blastskill,0)
			A.kishock=usr.kishock
			A.kiforceful=usr.kiforceful
			A.kiinterfere=usr.kiinterfere
			spawn A.BlastControl()
			if(usr.target&&usr.target!=usr)
				spawn A.blasthoming(usr.target)
			step(A,curdir)
			walk(A,curdir)
			amount-=1
			sleep(2)
		dirlock=0
		spawn(3) usr.icon_state=""
		blasting=0
		sleep(reload)
		usr.barrageCD=0
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(barrageCD) usr<<"This skill was set on cooldown for [barrageCD/10] seconds."

mob/keyable/verb/Continuous_Energy_Bullets()
	set category = "Skills"
	desc = "Fire an endless barrage of energy blasts"
	var/kireq=30*BaseDrain
	var/duration=0
	var/reload
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!barrageCD&&canfight)
		canmove=0
		//canfight=0
		usr.barrageCD=1
		usr.Ki-=kireq
		usr.Blast_Gain()
		blasting=1
		volleying=1
		usr.icon_state="Blast"
		var/bicon=usr.BLASTICON
		bicon+=rgb(usr.blastR,usr.blastG,usr.blastB)
		while(volleying&&!usr.KO&&usr.Ki>kireq)
			if(duration % 3 == 0)
				usr.Blast_Gain()
				usr.blastcounter++
				usr.volleycounter++
			usr.Ki-=kireq
			if(usr.Ki<kireq)
				usr.Ki=0
			blastcount+=1
			var/obj/attack/blast/A=new/obj/attack/blast
			usr.emit_Sound('KIBLAST.WAV')
			A.icon=bicon
			spawn A.Burnout()
			A.basedamage=0.7*Ekioff*log(10,max(blastskill,10))*globalKiDamage
			A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))
			A.BP=expressedBP
			A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
			A.icon_state=usr.BLASTSTATE
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.loc=locate(usr.x,usr.y,usr.z)
			step(A,usr.dir)
			A.density=1
			A.dir=curdir
			A.ogdir=usr.dir
			A.murderToggle=usr.murderToggle
			A.inaccuracy = max(100-Ekiskill*10-kicontrolskill-blastskill,0)
			A.kishock=usr.kishock
			A.kiforceful=usr.kiforceful
			A.kiinterfere=usr.kiinterfere
			spawn A.BlastControl()
			if(usr.target&&usr.target!=usr)
				spawn A.blasthoming(usr.target)
			step(A,pick(turn(curdir,-45),curdir,turn(curdir,45)))
			walk(A,curdir)
			duration+=1
			kireq=max(log(duration),1)*300*BaseDrain
			sleep(1)
		reload=50
		if(reload<2)reload=2
		usr.barrageCD=reload
		canmove=1
		//canfight=1
		blasting=0
		volleying=0
		spawn(3) usr.icon_state=""
		sleep(reload)
		usr.barrageCD=0
	else if(volleying)
		usr.volleying=0
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(barrageCD) usr<<"This skill was set on cooldown for [barrageCD/10] seconds."

mob/keyable/verb/Spin_Blast()
	set category = "Skills"
	desc = "Fire an endless barrage of energy blasts in all directions"
	var/kireq=50*BaseDrain
	var/duration=0
	var/reload
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!barrageCD&&canfight)
		canmove=0
		canfight=0
		usr.barrageCD=1
		usr.Ki-=kireq
		usr.Blast_Gain()
		blasting=1
		volleying=1
		usr.icon_state="Blast"
		var/bicon=usr.BLASTICON
		bicon+=rgb(usr.blastR,usr.blastG,usr.blastB)
		while(volleying&&!usr.KO&&usr.Ki>kireq)
			if(duration % 3 == 0)
				usr.Blast_Gain()
				usr.blastcounter++
				usr.volleycounter++
			usr.Ki-=kireq
			if(usr.Ki<kireq)
				usr.Ki=0
			blastcount+=1
			var/obj/attack/blast/A=new/obj/attack/blast
			usr.emit_Sound('KIBLAST.WAV')
			A.icon=bicon
			spawn A.Burnout()
			A.basedamage=1.1*Ekioff*log(10,max(blastskill,10))*globalKiDamage
			A.homingchance=(min(usr.Ekiskill*usr.kicontrolskill*usr.homingskill/100,100))
			A.BP=expressedBP
			A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
			A.icon_state=usr.BLASTSTATE
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.loc=locate(usr.x,usr.y,usr.z)
			A.density=1
			A.dir=curdir
			A.ogdir=usr.dir
			A.murderToggle=usr.murderToggle
			A.inaccuracy = max(100-Ekiskill*10-kicontrolskill-blastskill,0)
			A.kishock=usr.kishock
			A.kiforceful=usr.kiforceful
			A.kiinterfere=usr.kiinterfere
			spawn A.BlastControl()
			if(usr.target&&usr.target!=usr)
				spawn A.blasthoming(usr.target)
			step_rand(A)
			A.dir = get_step_rand(A)
			walk(A,dir)
			duration+=1
			kireq=max(log(duration),1)*500*BaseDrain
			if(duration % 2 == 0)
				sleep(1)
		reload=80
		if(reload<2)reload=2
		usr.barrageCD=reload
		canmove=1
		canfight=1
		blasting=0
		volleying=0
		spawn(3) usr.icon_state=""
		sleep(reload)
		usr.barrageCD=0
	else if(volleying)
		usr.volleying=0
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(barrageCD) usr<<"This skill was set on cooldown for [barrageCD/10] seconds."

mob/keyable/verb/Ki_Bomb()
	set name = "Ki Minefield"
	set category = "Skills"
	desc = "Surround your enemy with a field of ki blasts!!"
	var/amount=7+bonusShots+round(log(max(usr.blastskill,1)))+round(log(max(usr.targetedskill,1)))
	var/kireq=amount*15*BaseDrain
	var/curdir=usr.dir
	var/reload
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!targetedCD&&canfight&&usr.target)
		if(usr.target in oview(20))
			reload=Eactspeed*5
			if(reload<20)reload=20
			usr.targetedCD=reload
			usr.Ki-=kireq
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.blastcounter+=amount
			usr.targetedcounter+=amount*3
			usr.volleycounter+=amount
			blasting=1
			kitargeting=1
			usr.icon_state="Blast"
			var/bicon=usr.BLASTICON
			bicon+=rgb(usr.blastR,usr.blastG,usr.blastB)
			sleep(5)
			while(amount)
				blastcount+=1
				var/obj/attack/blast/A=new/obj/attack/blast
				usr.emit_Sound('KIBLAST.WAV')
				A.icon=bicon
				spawn A.Burnout(40)
				A.basedamage=2*Ekioff*log(10,max(blastskill,10))*globalKiDamage
				A.homingchance=0
				A.BP=expressedBP
				A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
				A.icon_state=usr.BLASTSTATE
				A.proprietor=usr
				A.ownkey=usr.displaykey
				A.loc=locate(pick(target.x+2,target.x+1,target.x-1,target.x-2),pick(target.y+2,target.y+1,target.y-1,target.y-2),usr.z)
				A.density=1
				A.dir=curdir
				A.ogdir=usr.dir
				A.murderToggle=usr.murderToggle
				A.inaccuracy = 0
				A.kishock=usr.kishock
				A.kiforceful=usr.kiforceful
				A.kiinterfere=usr.kiinterfere
				amount-=1
				sleep(1)
			spawn(3) usr.icon_state=""
			sleep(reload)
			blasting=0
			kitargeting=0
			usr.targetedCD=0
		else
			usr<<"Your target is not in range!"
	else if(!usr.target) usr<<"You need a target to use this!"
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(targetedCD) usr<<"This skill was set on cooldown for [targetedCD/10] seconds."

mob/keyable/verb/Hellzone_Grenade()
	set category = "Skills"
	desc = "Surround your enemy with a field of ki blasts which then converge on them!"
	var/amount=7+bonusShots+round(log(max(usr.blastskill,1)))+round(log(max(usr.targetedskill,1)))
	var/kireq=amount*50*BaseDrain
	var/curdir=usr.dir
	var/reload
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!targetedCD&&canfight&&usr.target)
		if(usr.target in oview(20))
			reload=Eactspeed*10
			if(reload<20)reload=20
			usr.targetedCD=reload
			usr.Ki-=kireq
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.blastcounter+=amount
			usr.targetedcounter+=amount*3
			usr.volleycounter+=amount
			usr.homingcounter+=amount
			blasting=1
			kitargeting=1
			usr.icon_state="Blast"
			var/bicon=usr.BLASTICON
			bicon+=rgb(usr.blastR,usr.blastG,usr.blastB)
			sleep(5)
			while(amount)
				blastcount+=1
				var/obj/attack/blast/A=new/obj/attack/blast
				usr.emit_Sound('KIBLAST.WAV')
				A.icon=bicon
				spawn A.Burnout(40)
				A.basedamage=4*Ekioff*log(10,max(blastskill,10))*globalKiDamage
				A.homingchance=100
				A.BP=expressedBP
				A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
				A.icon_state=usr.BLASTSTATE
				A.proprietor=usr
				A.ownkey=usr.displaykey
				A.loc=locate(pick(target.x+2,target.x+1,target.x-1,target.x-2),pick(target.y+2,target.y+1,target.y-1,target.y-2),usr.z)
				A.density=1
				A.dir=curdir
				A.ogdir=usr.dir
				A.murderToggle=usr.murderToggle
				A.inaccuracy = 0
				A.kishock=usr.kishock
				A.kiforceful=usr.kiforceful
				A.kiinterfere=usr.kiinterfere
				amount-=1
				spawn(10) A.blasthoming(usr.target)
				sleep(1)
			spawn(3) usr.icon_state=""
			sleep(reload)
			blasting=0
			kitargeting=0
			usr.targetedCD=0
		else
			usr<<"Your target is not in range!"
	else if(!usr.target) usr<<"You need a target to use this!"
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(targetedCD) usr<<"This skill was set on cooldown for [targetedCD/10] seconds."

mob/keyable/verb/Scattering_Bullet()
	set category = "Skills"
	var/maxdistance
	var/reload
	var/kireq=60*BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!scatterCD&&canfight)
		reload=20*Eactspeed
		if(reload<70)reload=70
		var/mob/M
		if(target&&get_dist(src,target)<=30)M=target
		else
			src<<"You need a valid target..."
			return
		usr.scatterCD=reload
		usr.Ki-=kireq*BaseDrain
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		var/bcolor='28.dmi'
		bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
		var/balls=round(2*(Ekiskill+(Ephysoff/3))+2,1)+bonusShots
		if(balls<1) balls=1
		maxdistance=round(balls/2,1)
		while(balls)
			blastcount+=1
			balls-=1
			var/obj/attack/blast/A=new/obj/attack/blast/
			usr.emit_Sound('burning_fire.wav')
			A.target=M
			A.loc=locate(usr.x,usr.y,usr.z)
			var/random2=rand(1,16)
			if(random2==1) step(A,NORTH)
			if(random2==2) step(A,SOUTH)
			if(random2==3) step(A,EAST)
			if(random2==4) step(A,WEST)
			if(random2==5) step(A,NORTHWEST)
			if(random2==6) step(A,NORTHEAST)
			if(random2==7) step(A,SOUTHWEST)
			if(random2==8) step(A,SOUTHEAST)
			spawn flick("Attack",usr)
			A.icon='28.dmi'
			A.icon+=rgb(usr.blastR,usr.blastG,usr.blastB)
			A.icon_state="28"
			A.basedamage=1
			A.BP=expressedBP
			A.mods=Ekioff*Ekiskill
			A.murderToggle=usr.murderToggle
			A.proprietor=usr.name
			A.ownkey=usr.displaykey
			spawn(600) if(A) del(A)
			var/distance=rand(1,maxdistance)
			var/randomdirection=rand(1,8)
			while(distance)
				distance-=1
				if(A)
					if(prob(5)) sleep(1)
					if(randomdirection==1) step(A,NORTH)
					if(randomdirection==2) step(A,SOUTH)
					if(randomdirection==3) step(A,EAST)
					if(randomdirection==4) step(A,WEST)
					if(randomdirection==5) step(A,NORTHWEST)
					if(randomdirection==6) step(A,NORTHEAST)
					if(randomdirection==7) step(A,SOUTHWEST)
					if(randomdirection==8) step(A,SOUTHEAST)
		sleep(round(20/Ekiskill,0.1))
		for(var/obj/attack/blast/C) if(C.z==usr.z&&C.proprietor==usr.name)
			C.density=1
			if(C.target) spawn walk_towards(C,C.target)
		sleep(reload)
		usr.scatterCD=0
		usr.icon_state="Blast"
		spawn(3) usr.icon_state=""
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(scatterCD) usr<<"This skill was set on cooldown for [scatterCD/10] seconds."

mob/keyable/verb/Energy_Shot()
	set category = "Skills"
	var/reload
	var/kireq=50*BaseDrain
	if(!KO&&Ki>=kireq&&!eshotCD&&canfight)
		reload=Eactspeed*4
		if(reload<7)reload=7
		usr.eshotCD=reload
		usr.Ki-=kireq*BaseDrain
		usr.speedMod/=1.3
		var/bicon=usr.bursticon
		bicon+=rgb(usr.AuraR,usr.AuraG,usr.AuraB)
		var/image/I=image(icon=bicon,icon_state=usr.burststate)
		usr.overlayList+=I
		usr.overlaychanged=1
		//canfight=0
		usr.mobTime-=0.4
		spawn(Eactspeed*2) usr.overlayList-=I
		usr.overlaychanged=1
		usr.mobTime-=0.4
		sleep(Eactspeed*2)
		var/bcolor=usr.CBLASTICON
		bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
		var/obj/attack/blast/A=new/obj/attack/blast/
		usr.emit_Sound('eyebeam_fire.wav')
		A.Burnout()
		A.icon=bcolor
		A.icon_state=usr.CBLASTSTATE
		A.loc=locate(usr.x,usr.y,usr.z)
		A.density=1
		A.BP=expressedBP
		A.mods=Ekioff*Ekiskill
		A.basedamage=2.5
		A.dir=usr.dir
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		step(A,usr.dir)
		walk(A,usr.dir)
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		//canfight=1
		usr.speedMod*=1.3
		sleep(reload)
		usr.eshotCD=0
		usr.icon_state="Blast"
		spawn(3) usr.icon_state=""
	else if(usr.Ki<=kireq) usr<<"This requires atleast [kireq] energy to use."
	else if(eshotCD) usr<<"This skill was set on cooldown for [eshotCD/10] seconds."