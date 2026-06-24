mob/var/tmp/lastexplosionflingid
obj/var/tmp/lastexplosionflingid
//
obj/explosions
	//icon = 'Explosion2.dmi'
	icon_state = ""
	canGrab = 0
	IsntAItem = 1
	fragile=0
	plane = 8
	var/over = 0
	layer = MOB_LAYER
	var/harmful = 1
	var/strength = 10
	var/radius = 2
	var/animlast = 5 //How long does the animation last?
	var/expLast = 9 //How long does the explosion last?
	var/id
	var/radioactive = 0
	var/gibbify = 0
	var/list/flunglist = list()

	New()
		..()
		id = rand(1,9999)
		spawn(1) Ticker()
	proc/Ticker()
		set background = 1
		if(!icon)
			icon = 'Explosion2.dmi'
			var/icon/I = icon(icon)
			var/icwidth = I.Width()
			var/icheight = I.Height()
			if(icwidth==32&&icheight==32)
			else
				pixel_x = round(((32 - icwidth) / 2))
				pixel_y = round(((32 - icheight) / 2))
		sleep(1)
		animlast--
		spawn
			sleep(animlast)
			icon = null
		spawn
			sleep(expLast)
			src.loc = null
		explosion()

	EMPBoom
		harmful = 0
		strength = 50
		radius = 8
		animlast = 3 //How long does the animation last?
		expLast = 5 //How long does the explosion last?
		icon = 'Explosion5.dmi'
		explosion_M_throw(mob/M,dist)
			..()
			if(M.Race=="Android")
				M.stamina *= 0.30
			for(var/obj/Modules/S in M.contents)
				S.elec_energy -= S.elec_energy
		explosion_I_throw(obj/I,dist)
			if(istype(I,/obj/Modules)) I:elec_energy -= I:elec_energy

	SonicBoom
		harmful = 0
		strength = 50
		radius = 6
		animlast = 3 //How long does the animation last?
		expLast = 5 //How long does the explosion last?
		icon = 'Explosion5.dmi'
		explosion_M_throw(mob/M,dist)
			..()
			if(M.Race!="Android")
				var/dmg = DamageCalc(BPModulus(strength,M.expressedBP),(M.Ephysoff+M.Etechnique),40)
				dmg =(dmg/1.5)
				M.SpreadDamage(dmg)
	SmokeBoom
		harmful = 0
		strength = 0
		radius = 0
		animlast = 300 //How long does the animation last?
		expLast = 300 //How long does the explosion last?
		icon = 'fogcloud.dmi'
		New()
			..()
			var/matrix/M = matrix()
			M.Scale(8,8)
			src.transform = M

	ToxicBoom
		harmful = 0
		strength = 10
		radius = 3
		animlast = 3 //How long does the animation last?
		expLast = 5 //How long does the explosion last?
		icon = 'Explosion6.dmi'
		explosion_M_throw(mob/M,dist)
			..()
			M.Mutations+=1


proc/spawnExplosion(location,icon,strength,radius)
	if(!isnum(strength))
		strength = 10
	if(!icon)
		icon = 'Explosion2.dmi'
	if(!isnum(radius))
		radius = 2
	if(!location)
		return FALSE
	var/obj/explosions/nE = new(location)
	if(icon == 'Explosion2.dmi')
		var/matrix/nM = new
		nM.Scale(radius,radius)
		nE.transform = nM
	nE.strength = strength
	nE.icon = icon
	nE.radius = radius
	return nE

proc/spawnExplosionType(type,strength,location,radius)
	if(!isnum(strength))
		strength = 10
	if(!isnum(radius))
		radius = 2
	if(!location)
		return FALSE
	if(!type) return FALSE
	var/obj/explosions/nE = new type(location)
	nE.strength = strength
	nE.radius = radius
	return nE


proc/trange(var/Dist=0,var/turf/Center=null)//alternative to range (ONLY processes turfs and thus less intensive)
	if(Center==null) return

	//var/x1=((Center.x-Dist)<1 ? 1 : Center.x-Dist)
	//var/y1=((Center.y-Dist)<1 ? 1 : Center.y-Dist)
	//var/x2=((Center.x+Dist)>world.maxx ? world.maxx : Center.x+Dist)
	//var/y2=((Center.y+Dist)>world.maxy ? world.maxy : Center.y+Dist)

	var/turf/x1y1 = locate(((Center.x-Dist)<1 ? 1 : Center.x-Dist),((Center.y-Dist)<1 ? 1 : Center.y-Dist),Center.z)
	var/turf/x2y2 = locate(((Center.x+Dist)>world.maxx ? world.maxx : Center.x+Dist),((Center.y+Dist)>world.maxy ? world.maxy : Center.y+Dist),Center.z)
	return block(x1y1,x2y2)
obj/explosions/proc/explosion_I_throw(obj/O,dist,throw_dir)
	if(O.IsntAItem||O!=src||ismob(O.loc)||O.lastexplosionflingid==id)
	else
		O.lastexplosionflingid=id
		if(O.Bolted&&harmful)
			spawn O.takeDamage(strength)
		if(!O.Bolted&&harmful) spawn O.takeDamage(strength)

obj/explosions/proc/explosion_M_throw(mob/M,dist,throw_dir)
	if(M.lastexplosionflingid==id)
	else
		M.lastexplosionflingid=id
		emit_Sound('scouterexplode.ogg')
		var/testback=(rand(1,(2*BPModulus(strength,M.expressedBP)))/M.Ephysdef)
		testback = round(testback,1)
		testback = min(testback,15)
		var/dmg = DamageCalc(BPModulus(strength,M.expressedBP),((M.Ephysoff+M.Etechnique) * dist))
		if(testback>1&&strength)
			M.kbpow = strength
			M.kbdir = throw_dir
			M.kbdur = testback
			spawn M.AddEffect(/effect/knockback)
		if(harmful)
			dmg =(dmg/1.5)
			M.SpreadDamage(dmg)
			if(gibbify)
				for(var/datum/Body/S in M.body)
					if(!S.lopped)
						S.health -= dmg

		if(radioactive)
			M.Mutations+=1
obj/explosions/proc/damage_turf(turf/T,dist,throw_dir)
	if(T.Resistance&&harmful)
		if(T.Resistance<=(strength / dist))
			if(prob(80))
				createDust(T,1)
				T.Destroy()

obj/explosions/proc/explosion()
	set waitfor = 0
	var/list/bndlst = list()
	var/turf/epicenter = loc
	over = 1
	//var/boomcount=0
	for(var/obj/explosions/A in loc)//one explosion per turf, not elegant but keeps 70 from killing the serb
		if(!A.over)
			A.strength += strength/2
			A.radius += radius/2
		return
	//spawn(0)
	//WriteToLog("rplog","Explosion with size ([radius], [max_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
	var/start = world.timeofday
	if(!epicenter) return
	var/max_range = max(radius)
	if(radius <= 3) //a view() might be less expensive than bounding memes- need to test
		bndlst += oview(radius)
	else
		bound_x = -(((max_range*32) - 32)/2)
		bound_y = -(((max_range*32) - 32)/2)
		bound_height = max_range
		bound_width = max_range
		bndlst = bounds()
	for(var/atom/I in bndlst)
		var/dist = get_dist(epicenter, I)
		if(dist < radius / 2)		dist = 1
		else if(dist >= radius / 2 && dist <= radius / (3/4))	dist = 2
		else if(dist > radius / (3/4))	dist = 3
		else dist = 1

		//--- THROW ITEMS AROUND ---

		var/throw_dir = get_dir(epicenter,I)
		if(istype(I,/obj))
			explosion_I_throw(I,dist,throw_dir)
		if(istype(I,/mob))
			explosion_M_throw(I,dist,throw_dir)
		if(istype(I,/turf))
			damage_turf(I,dist,throw_dir)
		return
	createDust(loc,2 + round(min(max_range,6)/3))
	createCrater(loc,4)
	if(max_range>5) createDustmisc(loc,4)
	var/took = (world.timeofday-start)/10
	if(took > 2) WriteToLog("debug","### DEBUG: Explosion with size ([radius], [max_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z]) took [took] seconds.")

	return 1
//var/explosion_switch = 0
/*mob/Debug/verb/explosion_switch()
	set category = "Debug"
	if(explosion_switch) explosion_switch = 0
	else explosion_switch = 1
	usr << "[explosion_switch]"

mob/Debug/verb/test_explosion()
	set category = "Debug"
	spawnExplosion(get_step(src,dir),null,1,3)*/