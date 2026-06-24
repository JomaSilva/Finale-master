//this is where skill in the kiai archetype will be

mob/var/tmp/kiaiing = 0
mob/var/tmp/kiaionCD = 0

mob/keyable/verb/Kiai()
	set category = "Skills"
	desc = "Knock back targets directly in front of you"
	var/kireq = 50*usr.BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!kiaionCD&&canfight)
		usr.Ki-=kireq
		kiaionCD = max(round(1000/(usr.Ekiskill*10+usr.kieffusionskill+kiaiskill)),10)//cooldown is affected by general ki skill, effusion skill, and kiai skill
		usr.Blast_Gain()
		var/mobaff = 0
		usr.kiaicounter++
		flick("Blast",usr)
		for(var/mob/M in get_step(src,src.dir))
			var/strength = round(((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)/(max(M.Ekiskill,M.Etechnique)*10+max(M.Ekidef,M.Ephysdef)*10+M.kicirculationskill+M.kicontrolskill))*BPModulus(usr.expressedBP,M.expressedBP))
			strength = max(strength,3)
			spawn M.KiKnockback(src,strength)
			mobaff++
			usr.kiaicounter++
		for(var/mob/M in get_step(src,turn(src.dir,-45)))
			var/strength = round(((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)/(max(M.Ekiskill,M.Etechnique)*10+max(M.Ekidef,M.Ephysdef)*10+M.kicirculationskill+M.kicontrolskill))*BPModulus(usr.expressedBP,M.expressedBP))
			spawn M.KiKnockback(src,strength)
			mobaff++
			usr.kiaicounter++
		for(var/mob/M in get_step(src,turn(src.dir,45)))
			var/strength = round(((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)/(max(M.Ekiskill,M.Etechnique)*10+max(M.Ekidef,M.Ephysdef)*10+M.kicirculationskill+M.kicontrolskill))*BPModulus(usr.expressedBP,M.expressedBP))
			spawn M.KiKnockback(src,strength)
			mobaff++
			usr.kiaicounter++
		if(!mobaff)
			var/bcolor='Daitoppa.dmi'
			bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
			var/obj/attack/blast/A=new/obj/attack/blast
			usr.emit_Sound('fire_kiblast.wav')
			A.loc=locate(usr.x,usr.y,usr.z)
			A.icon=bcolor
			A.invisibility = 1
			A.avoidusr=1
			A.density=1
			A.basedamage=0.5*Ekioff*log(10,max(blastskill,10))
			A.BP=expressedBP
			A.mods=usr.Ekioff*usr.Ekiskill*log(10,max(usr.kieffusionskill,2))*log(10,max(usr.blastskill,2))
			A.murderToggle=usr.murderToggle
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.dir=usr.dir
			A.ogdir=usr.dir
			spawn A.Burnout()
			walk(A,usr.dir)
		usr.emit_Sound('scouterexplode.ogg')
		kiaiing=1
		sleep(kiaionCD)
		kiaiing=0
		kiaionCD=0
	else
		usr<<"You can't use this now!"

mob/keyable/verb/Shockwave()
	set category = "Skills"
	desc = "Knock back targets adjacent to you"
	var/kireq = 40*usr.BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!kiaionCD&&canfight)
		usr.Ki-=kireq
		kiaionCD = max(round(4000/(usr.Ekiskill*10+usr.kieffusionskill+kiaiskill)),10)//cooldown is affected by general ki skill, effusion skill, and kiai skill
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.kiaicounter+=2
		flick("Blast",usr)
		for(var/mob/M in oview(1))
			var/strength = round((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)/(max(M.Ekiskill,M.Etechnique)*10+max(M.Ekidef,M.Ephysdef)*10+M.kicirculationskill+M.kicontrolskill)*BPModulus(usr.expressedBP,M.expressedBP))
			strength = max(strength,3)
			spawn M.KiKnockback(src,strength)
			usr.kiaicounter+=2
		for(var/obj/attack/nA in oview(2))
			if(BPModulus(expressedBP,nA.BP) >= 1 || (usr.Ekioff+usr.Ekiskill+(usr.kieffusionskill+usr.kiaiskill / 10) * 2) >= nA.mods + nA.basedamage)
				nA.loc=null//move to null so the garbage collector can handle it when it has time
				obj_list-=nA
				attack_list-=nA
		emit_Sound('scouterexplode.ogg')
		kiaiing=1
		sleep(kiaionCD)
		kiaiing=0
		kiaionCD=0
	else
		usr<<"You can't use this now!"

mob/keyable/verb/Deflection()
	set category = "Skills"
	desc = "Deflect blasts and beams in front of you"
	var/kireq = 80*usr.BaseDrain
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!kiaionCD&&canfight)
		usr.Ki-=kireq
		kiaionCD = max(round(8000/(usr.Ekiskill*10+usr.kieffusionskill+kiaiskill)),10)//cooldown is affected by general ki skill, effusion skill, and kiai skill
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.kiaicounter+=4
		flick("Blast",usr)
		var/repeater = 3
		while(repeater)
			for(var/obj/attack/M in get_step(src,src.dir))
				var/strength = round(((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)*usr.expressedBP)/(M.BP*M.mods))
				if(strength>1)
					walk(M,get_opposite_dir(M))
				usr.kiaicounter+=4
			for(var/obj/attack/M in get_step(src,turn(src.dir,-45)))
				var/strength = round(((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)*usr.expressedBP)/(M.BP*M.mods))
				if(strength>1)
					walk(M,get_opposite_dir(M))
				usr.kiaicounter+=4
			for(var/obj/attack/M in get_step(src,turn(src.dir,45)))
				var/strength = round(((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)*usr.expressedBP)/(M.BP*M.mods))
				if(strength>1)
					walk(M,get_opposite_dir(M))
				usr.kiaicounter+=4
			emit_Sound('scouterexplode.ogg')
			repeater--
			sleep(2)
		kiaiing=1
		sleep(kiaionCD)
		kiaiing=0
		kiaionCD=0
	else
		usr<<"You can't use this now!"
mob/keyable/verb/Explosive_Roar()
	set category = "Skills"
	desc = "Charge your ki and unleash it as a massive shockwave to knock back targets"
	var/kireq = 50*usr.BaseDrain
	var/charge= 0
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!kiaionCD&&canfight&&!charging)
		usr<<"You begin charging your roar! Use again to release!"
		usr.charging = 1
		kiaiing=1
		emit_Sound('kame_charge.wav')
		while(usr.charging && usr.Ki >= kireq && charge <= 29)
			sleep(10)
			charge++
			usr.Ki-=kireq + (kireq / 10) * charge
			usr.emit_Sound('chargeincrease.ogg')
		if(!usr.med&&!usr.train&&!usr.KO&&canfight&&!usr.KB&&!usr.stagger)
			usr.Blast_Gain()
			usr.Blast_Gain()
			charge = min(charge,5)
			usr.kiaicounter+=charge
			flick("Blast",usr)
			for(var/mob/M in oview(max(charge-1,1)))
				var/strength = round((usr.Ekioff*10+usr.Ekiskill*10+usr.kieffusionskill+usr.kiaiskill)/(max(M.Ekiskill,M.Etechnique)*10+max(M.Ekidef,M.Ephysdef)*10+M.kicirculationskill+M.kicontrolskill)*BPModulus(usr,M)*charge)
				spawn M.KiKnockback(src,strength)
				usr.kiaicounter+=charge
			for(var/obj/attack/nA in oview(max(charge-1,1)))
				if(BPModulus(expressedBP,nA.BP) >= 1 || (usr.Ekioff+usr.Ekiskill+(usr.kieffusionskill+usr.kiaiskill / 10) * 2) >= nA.mods + nA.basedamage)
					nA.loc=null//move to null so the garbage collector can handle it when it has time
					obj_list-=nA
					attack_list-=nA
			emit_Sound('scouterexplode.ogg')
		kiaionCD = max(round(12000/(usr.Ekiskill*10+usr.kieffusionskill+kiaiskill)),10)//cooldown is affected by general ki skill, effusion skill, and kiai skill
		sleep(kiaionCD)
		kiaiing=0
		kiaionCD=0
	else if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!kiaionCD&&canfight&&usr.charging)
		usr<<"You unleash your roar!"
		usr.charging = 0
	else
		usr<<"You can't use this now!"