mob/var/AdvEffusion=0
/*/datum/skill/tree/AdvEffusion
	name = "Advanced Effusion"
	desc = "Supreme Energy Projection, Supreme Energy Manipulation"
	maxtier = 3
	tier=3
	allowedtier=3
	enabled=0
	constituentskills = list(new/datum/skill/general/splitform,new/datum/skill/general/selfdestruct,new/datum/skill/general/observe,new/datum/skill/adveff/VoidShout)
	can_refund = TRUE

/datum/skill/tree/Rudeff/mod()
	savant.AdvEffusion=1
	..()
/datum/skill/tree/Rudeff/demod()
	savant.AdvEffusion=0
	..()

/datum/skill/tree/AdvEffusion/growbranches()
	if(savant.Class=="Kai")
		enabletree(/datum/skill/tree/kai)
	if(savant.Class=="Demon")
		enabletree(/datum/skill/tree/demon)
	..()
	return*/

/datum/skill/general/selfdestruct
	skilltype = "Ki"
	name = "Self Destruct"
	desc = "Kill yourself, dealing major damage to a opponent."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1

/datum/skill/general/selfdestruct/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Self_Destruct)

/datum/skill/general/selfdestruct/after_learn()
	assignverb(/mob/keyable/verb/Self_Destruct)
	savant<<"You can now suicide!"
/datum/skill/general/selfdestruct/before_forget()
	unassignverb(/mob/keyable/verb/Self_Destruct)
	savant<<"You've forgotten how to use Self Destruct!?"


/datum/skill/adveff/VoidShout
	skilltype = "Ki"
	name = "Void Shout"
	desc = "Scream into the cosmos, creating a small portal to Interdimension. Requires 40 billion expressed BP to accomplish."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 3
	skillcost=2
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Void_Shout)

	after_learn()
		assignverb(/mob/keyable/verb/Void_Shout)
		savant<<"You can now use Void Shout!"
	before_forget()
		unassignverb(/mob/keyable/verb/Void_Shout)
		savant<<"You've forgotten how to use Void Shout!?"


/mob/keyable/verb/Void_Shout()
	set category="Skills"
	if(Planet=="Interdimension"||expressedBP<4e010)
		usr << "You can't use Void Shout right now. (40 billion BP and not already in Interdimension.)"
		return
	view(usr)<<"[usr] starts screaming!"
	Quake()
	sleep(40)
	Quake()
	view(usr)<<"[usr]'s screams open up a small temporary portal!"
	var/obj/InterdimensionPortal/nP = new(get_step(usr,usr.dir))
	step(nP,dir)


obj/InterdimensionPortal
	icon = 'blue portal.dmi'
	density = 0
	canGrab=0
	pixel_x = -34
	pixel_y = -34
	IsntAItem=1
	mouse_opacity = 0
	var/lifespan = 30
	New()
		..()
		spawn Ticker()
	proc/Ticker()
		set background = 1
		lifespan -= 1
		if(lifespan<=0)
			del(src)
		sleep(10)
		spawn Ticker()
		return
	Cross(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/M = Obstacle
			var/area/targetArea
			for(var/area/A in area_outside_list)
				CHECK_TICK
				if(istype(A,/area/Interdimension))
					targetArea = A
					break
			if(targetArea)
				var/turf/temploc = pickTurf(targetArea,1)
				M.loc = (locate(temploc.x,temploc.y,temploc.z))
			else return FALSE //noarea? failed move.
		..()