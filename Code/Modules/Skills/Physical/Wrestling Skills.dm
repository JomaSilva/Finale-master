mob/keyable/verb //wrestling skills. Unique in that it doesn't need a target, just a grabbee. Damages based on selectzone
	Clench() //Damage an opponent in a grab- in the future this should activate the stuffs in CQC.dm. Also destroys some grab escape stacks. 
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*9
		get_me_a_grab()
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.grabbee)
			basicCD += 15
			usr.Ki-=kireq
			grabbee.stagger += 1
			var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
			emit_Sound(punchrandomsnd)
			AttackMultiple(grabbee,4,null,null,"clenches",1)
			grabbee.grabCounter = max(0,grabCounter-4)
			grabbee.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must have a grabbed person (press grab twice), be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Hold() //Mainly destroys grab stacks, stuns a opponent.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*12
		get_me_a_grab()
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.grabbee)
			basicCD += 15
			usr.Ki-=kireq
			grabbee.grabCounter = max(0,grabCounter-15)
			var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
			emit_Sound(punchrandomsnd)
			AttackMultiple(grabbee,null,null,null,"squeezes",1)
			grabbee.stunCount += 50
			sleep(15)
			attacking = 0
		else usr<<"You must have a grabbed person (press grab twice), be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Power_Slam() //Deals major damage to a grabbed person.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*20
		get_me_a_grab()
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.grabbee)
			basicCD += 15
			usr.Ki-=kireq
			grabbee.stagger += 1
			var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
			emit_Sound(punchrandomsnd)
			doAttack(grabbee,10,1,null,"flips and <font color=yellow>POWER SLAMS</font>",null,3)
			grabbee.stagger -= 1
			sleep(15)
			attacking = 0
		else usr<<"You must have a grabbed person (press grab twice), be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
	Suplex() //Suplex. Deals major damage then a stun.
		set category="Skills"
		var/kireq=usr.Ephysoff*BaseDrain*15
		get_me_a_grab()
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.grabbee)
			basicCD += 15
			usr.Ki-=kireq
			grabbee.stagger += 1
			var/punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
			emit_Sound(punchrandomsnd)
			AttackMultiple(grabbee,5,null,null,"<font color=yellow size=5>SUPLEXES,</font>",1)
			grabbee.stagger -= 1
			grabbee.stunCount += 20
			sleep(15)
			attacking = 0
		else usr<<"You must have a grabbed person (press grab twice), be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."