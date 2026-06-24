/datum/skill/tree/kanassajin
	name="Kanassa-jin Racials"
	desc="Given to all Kanassa-jins at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Kanassa-Jin")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/splitform,new/datum/skill/kanassajin/precognition,new/datum/skill/general/observe,new/datum/skill/kanassajin/Time_Store,\
	new/datum/skill/kanassajin/Chrono_Trigger)

/datum/skill/general/observe
	skilltype = "Ki"
	name = "Observe"
	desc = "Project a mental image of a person you wish to observe, and you can do so from many distances away."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost=0
/datum/skill/general/observe/after_learn()
	assignverb(/mob/keyable/verb/Observe)
	savant<<"You can now observe people!"
/datum/skill/general/observe/before_forget()
	unassignverb(/mob/keyable/verb/Observe)
	savant<<"You've forgotten how to observe!?"
/datum/skill/general/observe/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Observe)
/datum/skill/kanassajin/precognition
	skilltype = "Spirit"
	name = "Precognition"
	desc = "See into the future just a wee bit to dodge incoming blasts."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
/datum/skill/kanassajin/precognition/effector()
	if(!savant.blasting&&savant.move) for(var/obj/attack/blast/A in view(1)) if(A.proprietor!=savant)
		savant.dir=A.dir
		savant.dir=turn(savant.dir,90)
		step(savant,savant.dir)
		break

/datum/skill/kanassajin/precognition/after_learn()
	savant<<"You can see the future!"
/datum/skill/kanassajin/precognition/before_forget()
	savant<<"You've forgotten how to see the future!?"

mob/var/stored_time
/datum/skill/kanassajin/Time_Store
	skilltype = "Spirit"
	name = "Time Store"
	desc = "As you live, store Time Energy within yourself, preventing aging. You can then touch yourself or others to give 'time'. If applied to someone, they gain a temporary speed boost at the price of some age. Stored Time might have other uses too."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	skillcost = 2
	var/last_age = 0
	var/stuckage = 0
	effector()
		if(last_age != Year)
			savant.stored_time += 10 * (Year - last_age)
			last_age = Year
			savant << "You have [savant.stored_time] stored time."
		savant.Age = stuckage
	after_learn()
		last_age = Year
		stuckage = savant.Age
		savant<<"You can manipulate stored time! Your body is also stuck in time!"
		assignverb(/mob/keyable/verb/Time_Touch)
	before_forget()
		assignverb(/mob/keyable/verb/Time_Touch)
		savant<<"You've forgotten how to manipulate stored time."
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Time_Touch)

mob/keyable/verb/Time_Touch()
	set category = "Skills"
	if(!stored_time)
		usr << "You don't have any stored time!"
		return
	var/mob/m = input() as null|mob in view(1)
	if(ismob(m))
		view(m)<<"[usr] touches [m], giving them time! ([stored_time] stored time, need 1 (one year))"
		m.Age += 0.1
		m.TempBuff("Tspeed"=2,30)
		stored_time--

/datum/skill/kanassajin/Chrono_Trigger
	skilltype = "Spirit"
	name = "Chrono Trigger"
	desc = "Using 10 stored time (equal to 10 years worth of time), set a chronoic \"respawn\" point. Upon using this skill again, you'll revert back to that point with however much Ki, Stamina, Age, and Health you had when you set it up, destroying it. This can revert death."
	can_forget = TRUE
	common_sense = FALSE
	tier = 1
	after_learn()
		savant<<"You can manipulate your own time!"
		assignverb(/mob/keyable/verb/Chrono_Trigger)
	before_forget()
		assignverb(/mob/keyable/verb/Chrono_Trigger)
		savant<<"You've forgotten how to manipulate your time."
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Chrono_Trigger)
mob/var/chronoic_point
mob/keyable/verb/Chrono_Trigger()
	set category = "Skills"
	if(chronoic_point)
		view(usr) << "[usr] reverts in time!!"
		var/obj/Chronoic_Point/cp = chronoic_point
		chronoic_point = null
		if(HP < cp.hp) SpreadHeal(cp.hp - HP)
		else if(HP > cp.hp) SpreadDamage(HP - cp.hp)
		Ki = cp.ki
		stamina = cp.stam
		dead = cp.dead
		Age = cp.age
		loc = locate(cp.x,cp.y,cp.z)
		del(cp)
		return
	if(!stored_time >= 100)
		usr << "You don't have enough stored time! ([stored_time] stored time, need 100 (ten years))"
		return
	if(stored_time >= 100 && !chronoic_point)
		stored_time-= 100
		view(usr) << "[usr] focuses..."
		sleep(5)
		view(usr) << "[usr] releases some time!"
		var/obj/Chronoic_Point/cp = new/obj/Chronoic_Point(loc)
		chronoic_point = cp
		cp.hp = HP
		cp.ki = Ki
		cp.stam = stamina
		cp.dead = dead
		cp.age = Age

obj/Chronoic_Point
	density = 0
	SaveItem = 0
	IsntAItem=1
	canGrab = 0
	name = "Chronoic Point"
	icon = 'Spirit Energy.dmi'
	var/hp
	var/ki
	var/stam
	var/dead
	var/age