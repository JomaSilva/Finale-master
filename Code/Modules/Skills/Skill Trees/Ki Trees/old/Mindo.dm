/*/datum/skill/tree/Mind
	name = "Strength of Mind"
	desc = "General Mental Ability"
	maxtier = 10
	tier=0
	constituentskills = list(
		new/datum/skill/sense,new/datum/skill/flying,
		new/datum/skill/ki/blast,new/datum/skill/CustomAttacks/ki/blast/Blast,
		new/datum/skill/focus,new/datum/skill/mindling,
		new/datum/skill/flow,new/datum/skill/stalwart,
		new/datum/skill/clarity,new/datum/skill/bclarity,
		new/datum/skill/force,new/datum/skill/nforce,
		new/datum/skill/spaceflight)

mob/var/penskill=0

/datum/skill/tree/Mind/growbranches()
	if(invested>=3)
		allowedtier=3
		enabletree(/datum/skill/tree/Ki_Control)
	if(invested>=5)
		enabletree(/datum/skill/tree/Rudeff)
		enabletree(/datum/skill/tree/Introspection)
	..()
	return

/datum/skill/tree/Mind/prunebranches()
	if(invested<5)
		disabletree(/datum/skill/tree/Rudeff)
		disabletree(/datum/skill/tree/Introspection)
	if(invested<3)
		allowedtier=1
	..()
	return
*/
mob/var/KiSpecialty=0
/datum/skill/Ki_Specialty
	skilltype = "Mind Buff"
	name = "Ki Specialty"
	desc = "When you invest into this, you're allowing your body to go beyond 50 mastery in any given Ki department. Also, you'll gain boosts to Ki level based on BP, similar to skillpoints. KiSkill+"
	can_forget = TRUE
	common_sense = TRUE
	skillcost = 2
	maxlevel = 1
	enabled=0
	tier = 1
	after_learn()
		savant<<"You feel somewhat more focused."
		savant.KiSpecialty = 1
		savant.kiskillBuff+=0.1
	before_forget()
		savant.KiSpecialty = 0
		savant.kiskillBuff-=0.1

/datum/skill/bclarity
	skilltype = "Mind Buff"
	name = "Brutal Clarity"
	desc = "The user learns to take the world apart a bit better. KiOff++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=0
	maxlevel = 1
	tier = 2
/datum/skill/bclarity/after_learn()
	savant<<"You're starting to get a feel for where you need to hit things to take them apart."
	savant.kioffBuff+=0.4
	//savant.penskill+=1
/datum/skill/bclarity/before_forget()
	savant<<"Your mind feels dull."
	savant.kioffBuff-=0.4
	//savant.penskill-=1

/datum/skill/mindling
	skilltype = "Mind Buff"
	name = "Mindling"
	desc = "The user habitually neglects their body to further their mind.\nIntensifies your ki, but at what cost? KiOff++, KiDef++, KiSkill++, P.Off-, P.Def-"
	can_forget = TRUE
	common_sense = TRUE
	skillcost = 2
	maxlevel = 1
	tier = 1
/datum/skill/mindling/after_learn()
	savant<<"You feel intense."
	savant.kioffBuff+=0.3
	savant.kidefBuff+=0.3
	savant.kiskillBuff+=0.3
	savant.physoffBuff-=0.15
	savant.physdefBuff-=0.2
/datum/skill/mindling/before_forget()
	savant<<"Your body begins to recover."
	savant.kioffBuff-=0.3
	savant.kidefBuff-=0.3
	savant.kiskillBuff-=0.3
	savant.physoffBuff+=0.15
	savant.physdefBuff+=0.2

/datum/skill/force
	skilltype = "Mind Buff"
	name = "Force of Will"
	desc = "The user enhances their force of will through intense concentration. KiOff+++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	skillcost = 2
	maxlevel = 1
	tier = 2
/datum/skill/force/after_learn()
	savant<<"You feel powerful."
	savant.kioffBuff+=0.6
/datum/skill/force/before_forget()
	savant<<"You feel drained."
	savant.kioffBuff-=0.6

/datum/skill/nforce
	skilltype = "Mind Buff"
	name = "Natural Power"
	desc = "The user manifests their power in the world, further developing their Ki but also enhancing their physical abilities. KiOff++, P.Off+, Spd+"
	can_forget = TRUE
	common_sense = TRUE
	skillcost = 1
	maxlevel = 1
	enabled = 0
	prereqs = list(new/datum/skill/force)
	tier = 2
/datum/skill/nforce/after_learn()
	savant<<"You feel somewhat more focused."
	savant.kioffBuff+=0.4
	savant.physoffBuff+=0.1
	savant.speedBuff+=0.05
/datum/skill/nforce/before_forget()
	savant<<"You feel somewhat less focused."
	savant.kioffBuff-=0.4
	savant.physoffBuff-=0.1
	savant.speedBuff-=0.05

/datum/skill/spaceflight
	skilltype = "Ki"
	name = "Spaceflight"
	desc = "Instead of needing strictly a pod, fly up to space on your own."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	skillcost = 1
	maxlevel = 1
	enabled = 0
	prereqs = list(new/datum/skill/flying)
	tier = 3
	after_learn()
		assignverb(/mob/keyable/verb/Space_Flight)
		savant << "You learned how to fly to space!"
		..()
	before_forget()
		unassignverb(/mob/keyable/verb/Space_Flight)
		savant << "You learned how to fly to space!"
		..()
	login()
		..()
		assignverb(/mob/keyable/verb/Space_Flight)

mob/keyable/verb/Space_Flight()
	set category = "Skills"
	if(Ki>=600&&expressedBP>=2000&&flightability!=1)
		usr << "You lift off from the ground. This'll take a second"
		view(usr) << "[usr] lifts off from the ground, intent on going to space!"
		icon_state = "Flight"
		var/pastHP = HP
		var/area/A = GetArea()
		if(A.name == "Inside")
			view(usr) << "[usr] bumps [usr]s head on the ceiling!"
			icon_state = ""
		else
			sleep(50)
			if(!HP>=pastHP||KO)
				view(usr) <<"[usr] was damaged, canceling spaceflight!"
				return
			for(var/obj/Planets/P in world)
				if(P.planetType==usr.Planet)
					var/list/randTurfs = list()
					for(var/turf/T in view(1,P))
						randTurfs += T
					var/turf/rT = pick(randTurfs)
					src.loc = locate(rT.x,rT.y,rT.z)
					icon_state = ""
					break
	else usr << "You need 600 Ki, 2,000 BP, and the ability to fly to use this."