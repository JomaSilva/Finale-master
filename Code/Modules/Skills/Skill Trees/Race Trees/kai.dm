/datum/skill/tree/kai
	name="Kai Racials"
	desc="Given to all Kais at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/materialization,new/datum/skill/kai/Revive,new/datum/skill/kai/Teleport,new/datum/skill/Telepathy)

/datum/skill/kai/Mystic
	skilltype = "Form"
	name = "Mystic"
	desc = "Unleash your hidden potential. Your hidden potential is dictated as the strength you didn't have while young, and any reincarnation bonuses."
	skillcost = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	maxlevel = 1
	tier = 1
	enabled = 0

/datum/skill/kai/Mystic/after_learn()
	savant<<"You feel calm and confident as your ki adapts to the new Mystic form you have just learned."
	assignverb(/mob/keyable/verb/Mystic)
/datum/skill/kai/Mystic/before_forget()
	savant<<"You forget how to unleash your Mystic form."
	unassignverb(/mob/keyable/verb/Mystic)
/datum/skill/kai/Mystic/login()
	..()
	assignverb(/mob/keyable/verb/Mystic)

/*
obj/Mystify/verb/Mystify(mob/M in view(1))
	set category="Skills"
	if(M.hasmystic==1)
		usr<<"They already have this."
		return
	else if(usr.mystified<2)
		usr.mystified+=1
		usr<<"You have turned [usr.mystified] people into Mystics, you can use this a max of <font color=red>2 times."
		M.hasmystic=1
		M.learnSkill(new /datum/skill/kai/Mystic, 0,0)
	else usr<<"You cannot turn more than 2 people into Mystics."
	Again, as I said in Demon.dm, don't need this obj. Teachables already cover this ground. Commenting out for any possible future usage.
*/
/datum/skill/kai/Revive
	skilltype = "Ki"
	name = "Revive"
	desc = "Resurrect someone from the dead."
	can_forget = FALSE
	common_sense = FALSE
	skillcost=2
	tier = 2

/datum/skill/kai/Revive/after_learn()
	assignverb(/mob/keyable/verb/Revive)
	savant<<"You can revive!"

/datum/skill/kai/Revive/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Revive)

mob/keyable/verb/Revive()
	set category="Skills"
	if(!usr.dead)
		if(!target) target = input(usr,"Target someone.") as mob in view(1)
		var/mob/M=target
		if(M==usr) usr<<"You cannot revive yourself."
		else if(M.dead)
			switch(input(usr,"This will revive one dead person and bring them back to your location.","",text) in list ("No","Yes",))
				if("Yes")
					usr<<"You revive [M] and bring them to your location!"
					M.ReviveMe()
					M.overlayList-='Halo.dmi'
					M.overlaychanged=1
					M<<"[usr] has brought you back to the living world!"
					M.loc=locate(usr.x,usr.y,usr.z)
		else usr<<"They are not dead."
	else usr<<"You must be alive to revive someone."

/datum/skill/kai/Teleport
	skilltype = "Ki"
	name = "Teleport - Kai Kai"
	desc = "Tap into your reserves of otherwordly energy to instantly teleport to any other planet."
	level = 1
	expbarrier = 100
	skillcost = 2
	maxlevel = 1
	teacher = TRUE
	can_forget = TRUE
	common_sense = TRUE

/datum/skill/kai/Teleport/after_learn()
	savant<<"You can teleport!"
	if(savant.Race=="Kai")
		savant<<"Ready to go stalk the ningen?"
	else
		savant<<"You marvel at your new ability granted from the gods themselves. Space travel has never been easier!"
	assignverb(/mob/keyable/verb/Kai_Kai)
/datum/skill/kai/Teleport/before_forget()
	savant<<"You don't remember how to teleport."
	if(!teacher)savant<<"Guess you're stuck paying for airfare again, eh?"
	unassignverb(/mob/keyable/verb/Kai_Kai)
/datum/skill/kai/Teleport/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Kai_Kai)

mob/var/tmp/inteleport = 0

mob/keyable/verb/Kai_Kai()
	set category = "Skills"
	if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) return
	if(!usr.KO&&canfight&&!usr.med&&!usr.train&&usr.Ki>=usr.MaxKi&&usr.Planet!="Sealed"&&!usr.inteleport)
		view(6)<<"[usr] seems to be concentrating"
		var/choice = input(usr,"Where would you like to go?", "", text) in list ("Earth", "Namek", "Vegeta", "Icer Planet", "Arconia", "Desert", "Arlia", "Large Space Station", "Small Space Station", "Afterlife", "Hell", "Heaven", "Nevermind",)
		if(choice!="Nevermind")
			usr.Ki=0
			view(6)<<"[usr] shouts out 'Kai Kai!' and suddenly disappears!"
			usr.inteleport=1
			emit_Sound('Instant_Pop.wav')
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
			emit_Sound('Instant_Pop.wav')
			spawn(1)
				view(6)<<"[usr] suddenly appears!"
		else return
	else usr<<"You need full ki and total concentration to use this."
