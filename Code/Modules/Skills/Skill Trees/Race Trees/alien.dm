/datum/skill/tree/alien
	name="Alien Racials"
	desc="Given to all Aliens at the start. After 4 skillpoints invested into the tree, all consitituant skills are locked. (These skills will only be obtainable outside of learning.)"
	maxtier=2
	tier=0
	allowedtier=2
	enabled=1
	can_refund = FALSE
	compatible_races = list("Alien","Half-Breed")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,new/datum/skill/general/stoptime,new/datum/skill/demon/soulabsorb,\
	new/datum/skill/expand,new/datum/skill/general/imitation,new/datum/skill/general/regenerate,new/datum/skill/general/timefreeze,\
	new/datum/skill/general/invisible,new/datum/skill/Perfect_Metabolism/*,new/datum/skill/Body_Change*/)

/datum/skill/tree/alien/growbranches()
	if(invested >= 3 || (invested && savant.Class!="None"))
		for(var/datum/skill/S in constituentskills)
			disableskill(S.type)

/datum/skill/tree/alien/prunebranches()
	if((invested <= 3 && savant.Class=="None") || (!invested && savant.Class!="None"))
		for(var/datum/skill/S in constituentskills)
			enableskill(S.type)

/datum/skill/alien/transformation
	skilltype = "Transformation"
	name = "Alien Transformation"
	desc = "Transform into the peak of your species!!"
	can_forget = FALSE
	common_sense = FALSE
	tier = 2
	skillcost = 2
	after_learn()
		savant.hasayyform = 2
		savant<<"You can transform!"

/datum/skill/general/imitation
	skilltype = "Physical"
	name = "Imitation"
	desc = "Disguise yourself as somebody else!"
	can_forget = TRUE
	common_sense = FALSE
	tier = 1

/datum/skill/general/imitation/after_learn()
	savant.contents+=new/obj/Imitation
	savant<<"You can disguse yourself!"

/datum/skill/general/imitation/before_forget()
	for(var/obj/D in savant.contents)
		if(D.name=="Imitation")
			del(D)
	savant<<"You've forgotten how to disguise yourself!?"

/datum/skill/general/regenerate
	skilltype = "Ki"
	name = "Regenerate"
	desc = "Regenerate some damage, using energy in the process. You can target a limb to specify the healing process."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost = 2

	after_learn()
		assignverb(/mob/keyable/verb/Regenerate)
		savant.genome.add_to_stat("Regeneration",5)
		savant<<"You can now regenerate from attacks!"
	before_forget()
		unassignverb(/mob/keyable/verb/Regenerate)
		savant.genome.sub_to_stat("Regeneration",5)
		savant<<"You've forgotten how to regenerate!?"
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Regenerate)

/mob/keyable/verb/Regenerate()
	set category = "Skills"
	var/stamreq = 5 * (maxstamina/100)
	if(regen)
		regen = 0
	else
		if(stamina > stamreq && !KO && !med && !train && canfight && !basicCD)
			basicCD += 15
			regen = 1
			usr << "You start regenerating. Stay still to continue regernating."
			var/oldloc = loc
			while(regen && stamina > stamreq && !KO && !med && !train && canfight && canmove && oldloc == usr.loc && HP < 100)
				stamina -= stamreq
				SpreadHeal(5 * (activeRegen+1))
				HealLimb(5 * (activeRegen+1),selectzone)
				for(var/datum/Body/V in contents)
					if(V.lopped&&V.targettype==selectzone)
						V.RegrowLimb()
						break
				sleep(35)
			usr << "You stop regenerating."
			oldloc = null
			sleep(15)
			regen = 0

/datum/skill/general/timefreeze
	skilltype = "Ki"
	name = "Time Skip"
	desc = "Stop Time for a few people around you."
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 2
	tier = 1

/datum/skill/general/timefreeze/after_learn()
	assignverb(/mob/keyable/verb/Freeze)
	savant<<"You can freeze time for a few individuals!"
/datum/skill/general/timefreeze/before_forget()
	unassignverb(/mob/keyable/verb/Freeze)
	savant<<"You've forgotten how to freeze time!"
/datum/skill/general/timefreeze/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Freeze)

/datum/skill/Perfect_Metabolism
	skilltype = "Ki"
	name = "Perfect Metabolism"
	desc = "You can survive off of just water now. Hunger seems to have vanished."
	can_forget = FALSE
	common_sense = FALSE
	teacher=FALSE
	tier = 1
	skillcost = 2

/datum/skill/Perfect_Metabolism/after_learn()
	savant.partplant = 1
	savant<<"You can survive off of water now!"

/datum/skill/general/invisible
	skilltype = "Ki"
	name = "Invisibility"
	desc = "Become invisibile."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost = 2
	var/pstseeinvis
	after_learn()
		assignverb(/mob/keyable/verb/Invisibility)
		pstseeinvis = savant.see_invisible
		savant<<"You can now become invisible!"
	before_forget()
		unassignverb(/mob/keyable/verb/Invisibility)
		savant<<"You've forgotten how to become invisible!?"
		savant.see_invisible = pstseeinvis
	login(var/mob/logger)
		..()
		savant.see_invisible = pstseeinvis
		assignverb(/mob/keyable/verb/Invisibility)

mob/var/tmp/invising
mob/var/tmp/pstinvising = 0

mob/keyable/verb/Invisibility()
	set category="Skills"
	set waitfor = 0
	set background = 1
	if(!invising)
		invising=1
		pstinvising = 0
		if(!see_invisible)
			see_invisible = 1
		else pstinvising = 1
		usr<<"You are invisible."
		spawn
			while(invising)
				sleep(10)
				usr.Ki-=1 *BaseDrain
				usr.invisibility = 1
				if(prob(10)&&usr.invisskill<225)
					usr.invisskill+=1
				if(usr.Ki<10)
					invising=0
					usr.invisibility = 0
					usr<<"You can no longer sustain the invisibility."
			if(pstinvising == 0)
				see_invisible = 0
			usr.invisibility = 0
			usr<<"You are no longer invisible."
	else
		invising=0
		if(pstinvising == 0)
			see_invisible = 0
		usr.invisibility = 0

obj/Invisibility
	New()
		..()
		del(src)