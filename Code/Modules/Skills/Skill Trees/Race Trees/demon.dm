/datum/skill/tree/demon
	name="Demon Racials"
	desc="Given to all Demons at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/namek/bigform,new/datum/skill/demon/soulabsorb,new/datum/skill/general/materialization,new/datum/skill/kai/Revive,\
	new/datum/skill/demon/Devil_Bringer,new/datum/skill/general/invisible, new/datum/skill/demon/lifeabsorb,new/datum/skill/Telepathy)


/datum/skill/demon/soulabsorb
	skilltype = "Magical"
	name = "Soul Absorb"
	desc = "Tear into the very essence of a person and absorb their soul. You can only absorb a soul if the target is knocked out."
	level = 1
	expbarrier = 100
	skillcost = 2
	maxlevel = 1
	can_forget = TRUE
	common_sense = TRUE
	after_learn()
		savant<<"You can now absorb somebody's very soul!"
		assignverb(/mob/keyable/verb/Soul_Absorb)
	before_forget()
		unassignverb(/mob/keyable/verb/Soul_Absorb)
		savant<<"You've forgotten how to eat souls!?"
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Soul_Absorb)

mob/keyable/verb/Soul_Absorb(mob/M in oview(1))
	set category="Skills"
	usr.GainAbsorb(1)
	if(!usr.absorbing&&M.absorbable&&!usr.KO&&usr.Planet!="Sealed")
		usr.absorbing=1
		if(M==usr)
			return
		if(M.KO&&!M.dead&&M.HasSoul)
			M.HasSoul = 0
			usr.AbsorbDatum.absorb(M,2,6)
			usr.Ki+=M.Ki
			usr<<"You feel the resonance of [M]'s soul, you reach into their soul-space and absorb it!"
			M<<"You are in extreme pain from [usr] taking your soul. You no longer have a soul, which can affect some things."
			oview(usr)<<"[usr]([usr.displaykey]) seems to suck the soul straight out of [M]!"
			emit_Sound('absorb.wav')
			usr.genome.add_to_stat("Lifespan",((M.DeclineAge-M.Age)/100))
		else usr<<"They must be knocked out and must not have been already absorbed in the last 5 minutes. They also must have a soul. (This can only be done once.)"
		sleep(20)
		usr.absorbing = 0
		usr<<"You cant use it on your alts."
/datum/skill/demon/lifeabsorb
	skilltype = "Magical"
	name = "Life Suck"
	desc = "Feed on the energies of the other person, increasing your energy, power, and time you'll be in your prime. This is the only type of absorb that doesn't kill the other person, but it does take their decline."
	level = 1
	expbarrier = 100
	skillcost = 2
	maxlevel = 1
	can_forget = TRUE
	teacher=TRUE
	common_sense = TRUE
	login()
		..()
		assignverb(/mob/keyable/verb/Life_Suck)
	after_learn()
		savant<<"You can now feed on somebody's very soul!"
		assignverb(/mob/keyable/verb/Life_Suck)
	before_forget()
		unassignverb(/mob/keyable/verb/Life_Suck)
		savant<<"You've forgotten how to feed on souls!?"

mob/keyable/verb/Life_Suck(mob/M in oview(1))
	set category="Skills"
	if(!usr.absorbing&&M.absorbable&&!usr.KO&&usr.Planet!="Sealed")
		usr.absorbing=1
		if(M==usr)
			usr.absorbing=0
			return
		if(M.KO&&!M.dead)
			if(!M.HasSoul) usr<<"You cant seem to find a soul in this one!"
			else
				spawn M.absorbproc()
				if(usr.techmod<M.techmod)
					usr.genome.add_to_stat("Tech Modifier",1)
				if(usr.techskill<M.techskill)
					usr.techskill+=M.techskill/10
				usr<<"You feel the evil within [M]'s soul as you reach in and absorb it!"
				M<<"You feel drained, as if the life has been sucked out of your body."
				oview(usr)<<"[usr]([usr.displaykey]) seems to suck the life straight out of [M]!"
				var/declinetaken = ((M.DeclineAge-M.Age)/10)
				usr.genome.add_to_stat("Lifespan",(declinetaken/100))
				M.genome.sub_to_stat("Lifespan",(declinetaken/200))
				usr.Ki += M.MaxKi
				if(usr.BP<M.BP)
					usr.BP+=usr.capcheck(((M.BP/M.BPMod)*usr.BPMod)/4)
				if(M.BP<=usr.BP)
					usr.BP+=usr.capcheck((M.BP/M.BPMod)/8)
				if(usr.absorbadd<(((M.BP/2+M.absorbadd)*(M.PowerPcnt/100))*(M.Anger/100)))
					usr.absorbadd+=usr.capcheck(usr.absorbmod*(((M.BP/2+M.absorbadd)*(M.PowerPcnt/100))*(M.Anger/100)))
				usr.emit_Sound('absorb.wav')
				sleep(3000)
				usr.absorbing=0
		else usr<<"They must be knocked out, and must be alive, and you must not have already absorbed in the last 5 minutes."
		usr.absorbing=0
	else usr << "You must be not absorbing, the other person must not have been absorbed."
/datum/skill/demon/Majin
	skilltype = "Form"
	name = "Majin"
	desc = "You become able to channel your anger to further increase your power."
	skillcost = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	maxlevel = 1
	tier = 1
	enabled = 0

/datum/skill/demon/Majin/after_learn()
	savant<<"A dark, devilish power courses through you..."
	assignverb(/mob/keyable/verb/Majin)
/datum/skill/demon/Majin/before_forget()
	savant<<"You breathe easy; it feels like a massive weight has been lifted from your mind as you let go of your Majin form."
	unassignverb(/mob/keyable/verb/Majin)
/datum/skill/demon/Majin/login()
	..()
	assignverb(/mob/keyable/verb/Majin)

/*
obj/Majinize/verb/Majinize/(mob/M in view(1))
	set category="Skills"
	if(M.hasmajin==1)
		usr<<"They already have this."
		return
	else if(usr.majinized<2)
		usr.majinized+=1
		usr<<"You have turned [usr.majinized] people into Majins, you can use this a max of <font color=red>2 times."
		M.hasmajin=1
		M.learnSkill(new /datum/skill/demon/Majin, 0,0)
	else usr<<"You cannot turn more than 2 people into Majins."
	Teachable.dm already covers this ground, we don't need these dummy teaching objects anymore.
*/
/datum/skill/demon/Devil_Bringer
	skilltype = "Ki"
	name = "Devil Bringer"
	desc = "Use your innate Demon abilities to tear into the universe itself, granting you access wherever..."
	level = 1
	expbarrier = 100
	skillcost = 2
	maxlevel = 1
	teacher = TRUE
	can_forget = TRUE
	common_sense = TRUE

/datum/skill/demon/Devil_Bringer/after_learn()
	savant<<"You can teleport!"
	if(savant.Race=="Demon")
		savant<<"Why don't we cause some mayhem in the mortal realm, eh?"
	else
		savant<<"Demonic energy merges with your own as you learn to manipulate space as you please."
	assignverb(/mob/keyable/verb/Devil_Bringer)
/datum/skill/demon/Devil_Bringer/before_forget()
	if(!teacher)
		savant<<"You breathe easy as your devilish hold over space dissipates."
	else
		savant<<"You don't remember how to teleport."
	unassignverb(/mob/keyable/verb/Devil_Bringer)
/datum/skill/demon/Devil_Bringer/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Devil_Bringer)

mob/keyable/verb/Devil_Bringer()
	set category = "Skills"
	if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) return
	if(!usr.KO&&canfight&&!usr.med&&!usr.train&&usr.Ki>=usr.MaxKi&&usr.Planet!="Sealed"&&!usr.inteleport)
		view(6)<<"[usr] seems to be concentrating"
		var/choice = input(usr,"Where would you like to go? A demonic power like this prevents you from entering Heaven.", "", text) in list ("Earth", "Namek", "Vegeta", "Icer Planet", "Arconia", "Desert", "Arlia", "Large Space Station", "Small Space Station", "Afterlife", "Hell","Nevermind",)
		if(choice!="Nevermind")
			usr.Ki=0
			view(6)<<"[usr] tears a hole in reality and suddenly disappears!"
			usr.inteleport=1
			emit_Sound('demonteleport.wav')
			spawn for(var/mob/V in oview(1))
				view(6)<<"[V] suddenly disappears!"
				if(!V.inteleport)
					V.inteleport=1
					while(usr.inteleport)
						sleep(1)
					V.loc = locate(usr.x,usr.y,usr.z)
					V.inteleport=0
					V<<"[usr] brings you with them using teleportation."
					view(6)<<"[V] suddenly appears!"
			GotoPlanet(choice)
			usr.inteleport=0
			emit_Sound('demonteleport.wav')
			spawn(1)
				view(6)<<"[usr] suddenly appears!"
		else return
	else usr<<"You need full ki and total concentration to use this."