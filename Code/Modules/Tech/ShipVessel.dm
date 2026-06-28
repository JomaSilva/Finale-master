// =============================================================================
// CAPITAL SHIP  — a top-tier buildable starship.
//   * Built from the tech window (highest tier). Owner sets a PASSWORD on build.
//   * Touch it / click it -> (password) -> teleported to its INTERIOR on a fresh
//     z-level: a 100x100 room with a hull floor ("bottom") and indestructible
//     hull walls ("top") that block walking, flight and vision.
//   * You appear by the central Teleporter (Bigteleporter2013). Step onto it
//     -> prompt -> leave the ship where it currently is.
//   * Top-left room has a "Ship Control" computer (right-click): observe / pilot
//     / launch. While observing or piloting, CLICK the ship to return to your
//     character inside the bridge. Piloting into a planet auto-lands.
//   * The ship has HP (armor): outsiders can attack it (Destroy verb); when it
//     blows, everyone inside is thrown clear.
// =============================================================================

#define SHIP_INTERIOR_SIZE 100
#define SHIP_PAD_X 50
#define SHIP_PAD_Y 50

// ---- interior turfs (from Icons/Turfs/Space.dmi) ----
turf/ShipFloor
	name = "deck"
	icon = 'Space.dmi'
	icon_state = "bottom"

turf/ShipWall
	name = "hull"
	desc = "Solid starship hull."
	icon = 'Space.dmi'
	icon_state = "top"
	density = 1
	opacity = 1 //can't see behind it
	Enter(atom/movable/A) //indestructible: blocks ALL mobs, walking or flying (a plain density wall lets flyers pass)
		if(ismob(A)) return 0
		return ..()

// ---- piloting state on the mob ----
var/list/ship_interior_zs = list() //every dynamically-built ship-interior z this session, so logout/save can avoid stranding a player on a volatile interior z

mob/var/tmp
	piloting_ship = 0
	obj/PlayerShip/piloted_ship = null
	obj/PlayerShip/current_ship = null //the ship whose interior you're standing in (null when outside or piloting)
	pilot_old_invis = 0
	pilot_old_spacesuit = 0
	pilot_old_flight = 0
	turf/pilot_return_loc = null //the exact helm-computer tile to drop the body back on when you stop piloting

// ---- the buildable (auto-appears in the tech window, filtered by neededtech) ----
obj/Creatables
	Capital_Ship
		name = "Capital Ship"
		icon = 'Ship.dmi'
		desc = "A massive personal starship: walk inside, take the bridge, and launch to space. The most advanced craft you can build."
		cost = 2000000
		neededtech = 55 //highest tier (Fortress is 45). Tunable.
		create_type = /obj/PlayerShip
		Click()
			var/obj/A = ..()
			if(istype(A, /obj/PlayerShip))
				var/obj/PlayerShip/S = A
				S.owner_ckey = usr.ckey
				S.maxarmor = max(usr.intBPcap * 5, 1000) //tanky; scales with the builder's tech, like bases
				S.armor = S.maxarmor
				var/sp = input(usr, "Set a password for your ship. Others must enter it to board (the owner never needs it). Leave blank for no password.", "Ship Password") as text|null
				S.ship_pass = sp ? sp : "" //null (cancel) = no password

// ---- the ship's EXTERIOR object (parked on a planet / flies in space) ----
obj/PlayerShip
	name = "Capital Ship"
	desc = "A personal starship. Touch or click it to board; the bridge computer inside lets you observe, pilot, or launch."
	icon = 'Ship.dmi'
	icon_state = ""
	pixel_x = -48 //the 128x138 (4x4-tile) sprite anchors bottom-left; shift it left so the loc/dense tile sits under the DOOR (hitbox = the visible door)
	pixel_y = 0
	density = 1
	plane = 6
	SaveItem = 1
	IsntAItem = 1
	canGrab = 0
	Bolted = 1     //anchored
	fragile = 1    //destructible via the obj armor/takeDamage system
	var/owner_ckey = ""
	var/ship_pass = ""  //password the owner sets at build; non-owners must enter it to board (own string var; obj/var/password is an unrelated list)
	var/tmp/interior_z = 0   //the interior's z-level (regenerated per world session, lazily on first boarding)
	var/tmp/building = 0     //guard so two simultaneous boardings don't both build the interior
	var/tmp/launching = 0
	var/tmp/mob/pilot_mob = null

	// --- clicking the ship: if you're piloting/observing IT, return to your character inside; else board (with password) ---
	Click()
		if(!usr || !usr.client || !ismob(usr)) return ..()
		if((usr.piloting_ship && usr.piloted_ship == src) || (usr.observingnow && usr.client.eye == src))
			return_to_interior(usr) //click the ship while at the helm/observing -> back to your body on the bridge
			return
		if(get_dist(usr, src) <= 6) //the sprite is many tiles but only one is dense, so clicking it is the reliable way to board
			board(usr)
			return
		..()

	// --- board (entrance, also from mob/Bump): password gate, then drop them inside ---
	proc/board(mob/M)
		set waitfor = 0 //don't block the Bump caller while the interior is (lazily) built
		if(!M || !M.client) return
		if(M.piloting_ship && M.piloted_ship == src) return //already at this ship's helm -> never board it into its own interior
		if(M.current_ship == src) return //already standing inside this ship
		if(M.ckey != owner_ckey && ship_pass && ship_pass != "") //owner is exempt; others must know the password
			var/entered = input(M, "[name] is locked. Enter the password:", "Ship Password") as text|null
			if(entered != ship_pass)
				M << "<font color=red>Incorrect password.</font>"
				return
		place_in_interior(M)
		if(M) M << "<font color=#88ccff>You board the [name]. The bridge is in the far corner.</font>"

	// --- put a mob inside the interior (no password) -- used by board() and return_to_interior() ---
	proc/place_in_interior(mob/M)
		if(!M || !M.client) return
		var/iz = get_interior_z()
		if(!iz || !M || !M.client) return
		M.loc = locate(SHIP_PAD_X, SHIP_PAD_Y - 1, iz) //appear just south of the central pad
		M.current_ship = src

	// --- return from observe/pilot to your character, standing on the bridge ---
	proc/return_to_interior(mob/M)
		if(!M) return
		if(M.piloting_ship && M.piloted_ship == src) //piloting_ship is a 0/1 flag; the ship object is piloted_ship
			var/turf/ret = M.pilot_return_loc //the exact helm tile saved when they took control
			end_pilot(M) //restores invisibility/spacesuit/flight/view AND stops pilot_follow (so it can't re-grab the camera)
			if(ret && (ret.z in ship_interior_zs)) M.loc = ret //put the body back EXACTLY where it left the computer (not the entrance)
			else place_in_interior(M) //fallback (helm tile gone) -> central pad
			M.pilot_return_loc = null
		else if(M.client) //was observing -> they're already inside, just reset the camera (don't move them)
			M.client.eye = M
			M.client.perspective = MOB_PERSPECTIVE
			M.observingnow = 0
		if(M.client) M << "<font color=#88ccff>You return to the bridge.</font>"

	proc/get_interior_z()
		if(interior_z && interior_z <= world.maxz) return interior_z //already built this session
		if(building) //another boarding is mid-build -> wait for it instead of building a second copy
			while(building) sleep(1)
			return interior_z
		build_interior() //sets interior_z
		return interior_z

	proc/build_interior()
		building = 1
		var/iz = world.maxz + 1
		world.maxz = iz //create a fresh empty z-level
		ship_interior_zs |= iz
		var/sz = min(SHIP_INTERIOR_SIZE, world.maxx, world.maxy) //fit within the world bounds
		//floor everywhere, indestructible hull on the border
		for(var/xx = 1 to sz)
			for(var/yy = 1 to sz)
				CHECK_TICK //yield while laying ~10k turfs so the loop-check watchdog (world.loop_checks=1) can't abort the build
				if(xx == 1 || yy == 1 || xx == sz || yy == sz)
					new /turf/ShipWall(locate(xx, yy, iz))
				else
					new /turf/ShipFloor(locate(xx, yy, iz))
		//central exit teleporter
		var/obj/ShipExitPad/pad = new(locate(SHIP_PAD_X, SHIP_PAD_Y, iz))
		pad.ship_ref = src
		//top-left control room (its left & top sides ARE the hull border; add an inner right + bottom wall with a doorway)
		var/ry = sz - 14 //bottom row of the room
		for(var/yy = ry to sz)
			new /turf/ShipWall(locate(14, yy, iz)) //room's right wall
		for(var/xx = 1 to 14)
			if(xx == 8) continue //doorway south into the main deck
			new /turf/ShipWall(locate(xx, ry, iz)) //room's bottom wall
		var/obj/ShipControl/ctrl = new(locate(5, sz - 5, iz)) //the bridge computer, inside the room
		ctrl.ship_ref = src
		interior_z = iz //set BEFORE clearing the guard so a waiting boarder sees the finished z
		building = 0
		return iz

	// --- LAUNCH: planet -> space over 10 seconds, like the Spacepod ---
	proc/do_launch(mob/user)
		if(launching) return
		var/area/nA = src.GetArea()
		if(!nA || nA.Planet == "Space")
			if(user) user << "[name]: The ship is already in space."
			return
		launching = 1
		view(src) << "<font color=#88ccff>[name]: Launch sequence initiated. ETA 10 seconds.</font>"
		sleep(100) //10 seconds
		var/launched = 0
		for(var/obj/Planets/P in planet_list)
			if(P.planetType == nA.Planet)
				var/list/sT = list()
				for(var/turf/T in view(2, P)) sT += T
				if(sT.len)
					loc = pick(sT)
					launched = 1
				break
		if(launched) view(src) << "<font color=#88ccff>[name]: Now in space. Take the bridge and pilot the ship.</font>"
		else view(src) << "<font color=red>[name]: Launch aborted - no space lane to this planet.</font>"
		launching = 0

	// --- PILOT: the ship follows the (invisible) pilot mob, who is co-located with it ---
	proc/pilot_follow()
		set waitfor = 0
		set background = 1
		while(pilot_mob && pilot_mob.piloting_ship && pilot_mob.piloted_ship == src && pilot_mob.client)
			loc = locate(pilot_mob.x, pilot_mob.y, pilot_mob.z) //the ship rides wherever the pilot goes (incl. an auto-land teleport)
			pilot_mob.client.eye = src
			sleep(1)
		if(pilot_mob) end_pilot(pilot_mob) //pilot dropped out (logout etc.) -> clean up

	proc/end_pilot(mob/M)
		if(!M) return
		M.piloting_ship = 0
		M.piloted_ship = null
		M.invisibility = M.pilot_old_invis
		M.spacesuit = M.pilot_old_spacesuit
		M.flight = M.pilot_old_flight //restore pre-pilot flight state
		M.isflying = M.pilot_old_flight
		if(M.client)
			M.client.eye = M
			M.client.perspective = MOB_PERSPECTIVE
		M.observingnow = 0
		if(pilot_mob == M) pilot_mob = null

	// --- disembark from the interior teleporter: step off onto the ship's exterior location ---
	proc/disembark(mob/M)
		if(!M) return
		var/turf/dest = ship_free_turf_around(src)
		if(!dest) dest = locate(src.x, src.y, src.z)
		if(dest) M.loc = dest
		M.current_ship = null //they're outside the ship now
		M << "<font color=#88ccff>You step off the [name].</font>"

	// --- HP / destruction: outsiders attack the ship; when it blows, everyone inside is thrown clear ---
	verb/Destroy()
		set name = "Destroy"
		set category = null
		set src in view(6)
		if(usr.ckey == owner_ckey)
			usr << "You won't attack your own ship. (Use it normally, or it can be destroyed by others.)"
			return
		takeDamage(usr.expressedBP / 7 * usr.Ephysoff)
		view(src) << "<font color=red>[usr] strikes the [name]! (Hull [round(100 * armor / max(maxarmor,1))]%)</font>"

	testDestroy() //override: eject everyone inside before the hull blows
		if(armor <= 0 && !isdestroying)
			var/turf/blowout = ship_free_turf_around(src)
			if(!blowout) blowout = locate(src.x, src.y, src.z)
			if(pilot_mob) end_pilot(pilot_mob)
			if(interior_z)
				for(var/mob/M in world)
					if(M.client && M.z == interior_z)
						M.loc = blowout
						M.current_ship = null
						M << "<font color=red>The [name] is destroyed! You're thrown clear!</font>"
		..() //parent does the explosion + deleteMe

	Del()
		if(pilot_mob) end_pilot(pilot_mob)
		..()

// ---- central interior teleporter (Bigteleporter2013.dmi): step onto it to leave ----
obj/ShipExitPad
	name = "Teleporter"
	desc = "Step onto the pad to leave the ship."
	icon = 'Bigteleporter2013.dmi'
	icon_state = ""
	density = 0
	IsntAItem = 1
	NotSavable = 1
	var/tmp/obj/PlayerShip/ship_ref
	Crossed(atom/movable/A) //fires when a mob steps onto the pad (they spawn one tile south, so it never triggers on arrival)
		if(ismob(A))
			var/mob/M = A
			if(M.client && ship_ref)
				if(alert(M, "Leave the ship?", "Teleporter", "Yes", "No") == "Yes")
					ship_ref.disembark(M)
		..()

// ---- bridge control computer (Computer.dmi) ----
obj/ShipControl
	name = "Ship Control"
	desc = "The bridge computer. Right-click for ship options."
	icon = 'Computer.dmi'
	icon_state = "Computer"
	density = 1
	IsntAItem = 1
	NotSavable = 1
	var/tmp/obj/PlayerShip/ship_ref

	verb/Observe()
		set name = "observe"
		set src in oview(1)
		set category = null
		if(!ship_ref) return
		usr.observingnow = 1
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = ship_ref
		usr << "<font color=#88ccff>You watch the ship from outside. Click the ship to return to the bridge.</font>"

	verb/Pilot()
		set name = "pilot"
		set src in oview(1)
		set category = null
		if(!ship_ref) return
		if(ship_ref.pilot_mob && ship_ref.pilot_mob != usr)
			usr << "Someone else is already at the helm."
			return
		usr.pilot_old_invis = usr.invisibility
		usr.pilot_old_spacesuit = usr.spacesuit
		usr.pilot_old_flight = usr.flight
		usr.pilot_return_loc = usr.loc //remember the exact helm spot so the body returns HERE, not the entrance pad
		usr.invisibility = 101 //you become an invisible passenger riding the ship
		usr.spacesuit = 1 //survive space while at the helm
		usr.flight = 1 //count as flying so the ship crosses water (turf testWaters() lets flyers pass)
		usr.isflying = 1
		usr.piloting_ship = 1
		usr.piloted_ship = ship_ref
		usr.current_ship = null //they leave the interior to ride/steer the exterior ship
		usr.observingnow = 1
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = ship_ref
		usr.loc = locate(ship_ref.x, ship_ref.y, ship_ref.z) //ride the ship
		ship_ref.pilot_mob = usr
		usr << "<font color=#88ccff>You take the helm. Move to steer the ship; fly into a planet to land. Click the ship to return to the bridge.</font>"
		spawn ship_ref.pilot_follow()

	verb/Launch()
		set name = "launch"
		set src in oview(1)
		set category = null
		if(!ship_ref) return
		ship_ref.do_launch(usr)

// ---- helper: a free, non-dense turf next to an atom (for disembarking / blowout) ----
proc/ship_free_turf_around(atom/A)
	if(!A) return null
	for(var/turf/T in orange(1, A))
		if(T.density) continue
		var/blocked = 0
		for(var/atom/O in T)
			if(O.density) { blocked = 1; break }
		if(!blocked) return T
	return null
