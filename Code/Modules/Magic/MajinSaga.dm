// =============================================================================
// MAJIN SAGA — Majin absorption rework (pocket dimension) + the Corrupted Majin
// multi-form transformation saga (Kai-absorb -> Form1 -> rage Form2 + NPC clone ->
// absorb clone Form3 -> absorb 3 players Form4 -> Pure Form). One big system.
//
// ABSORPTION REWORK (any Majin): an absorbed player is NOT killed; they are sent to
// this Majin's private pocket z-level ALIVE. While absorbed the Majin gains 10% of
// their BP, all their skill verbs, and their clothes. If the absorbed dies in the
// pocket OR the Majin is KO'd, that person ESCAPES and the Majin loses those gains.
// =============================================================================

#define MAJIN_POCKET_SIZE 11

mob/var
	// --- saga form (persist across logout) ---
	majin_saga_form = 0       // 0 base, 1 Kai-absorbed, 2 rage, 3 clone-absorbed, 4 three-players
	majin_kai_absorbed = 0
	majin_clone_sig = ""      // signature this Majin stamps on its spawned NPC clone
	majin_form3_players = 0   // player absorbs counted while in Form3 (toward Form4)
	majin_pure_unlocked = 0
	majin_color = null        // the colour the Majin chose at creation, re-applied to each form icon
	tmp/majin_saga_busy = 0
	tmp/in_pure_form = 0
	tmp/pure_running = 0
	// --- pocket-dimension absorption ---
	majin_absorb_bp = 0       // sum of 10%-of-BP from everyone currently absorbed (added to tempBP, base.dm)
	tmp/majin_pocket_z = 0    // this Majin's pocket z-level (0 = not built)
	list/majin_absorbed = null // list of /datum/MajinAbsorbed
	// --- on the absorbed player ---
	tmp/mob/absorbed_into = null // the Majin currently holding this player (null = free)
	is_majin_saga_clone = 0   // set on the spawned NPC clone
	saga_master_sig = ""      // the clone remembers which Majin spawned it

datum/MajinAbsorbed
	var/sig                  // absorbed player's signature
	var/mob/who              // live ref while online
	var/bp_bonus = 0         // 10% of their BP we granted
	var/list/added_verbs = list() // skill verbs we copied onto the Majin
	var/list/clothes = list()     // clothes overlays we copied

mob/proc/is_corrupted_majin()
	return (Race == "Majin" || Parent_Race == "Majin") && Class == "Corrupted Majin"

// ---- pocket dimension --------------------------------------------------------
mob/proc/build_majin_pocket()
	if(majin_pocket_z && majin_pocket_z <= world.maxz) return majin_pocket_z
	var/iz = world.maxz + 1
	world.maxz = iz
	majin_interior_zs |= iz
	var/sz = min(MAJIN_POCKET_SIZE, world.maxx, world.maxy)
	for(var/xx = 1 to sz)
		for(var/yy = 1 to sz)
			CHECK_TICK
			if(xx == 1 || yy == 1 || xx == sz || yy == sz) new /turf/ShipWall(locate(xx, yy, iz))
			else new /turf/ShipFloor(locate(xx, yy, iz))
	majin_pocket_z = iz
	return iz

var/list/majin_interior_zs = list() // all live pocket z-levels (so a logout inside can be intercepted)

// ---- the absorption (replaces the Majin's old Buu_Absorb behaviour) ----------
mob/proc/majin_absorb(mob/M)
	if(!M || M == src) return
	if(majin_saga_busy) return
	// absorbing your OWN spawned clone (once it has been beaten) advances the saga to Form 3
	if(M.is_majin_saga_clone && M.saga_master_sig == signature)
		if(!(M.KO || M.dead || M.HP <= 15)) { to_chat(src, "You must defeat your other half before you can take it back."); return }
		emit_Sound('absorb.wav')
		to_chat(view(src), "<font color=#d050c0>*[src] devours the lesser Majin!*</font>", "combat")
		del(M)
		if(is_corrupted_majin() && majin_saga_form == 2) majin_advance_form(3, "super majin")
		return
	if(!(M.KO) || M.dead) { to_chat(src, "They must be knocked out and alive."); return }
	if(M.isNPC) { to_chat(src, "There is nothing worth taking from them."); return }
	if(isnull(majin_absorbed)) majin_absorbed = list()
	// build/record the absorption
	var/datum/MajinAbsorbed/rec = new
	rec.sig = M.signature
	rec.who = M
	rec.bp_bonus = round(M.BP * 0.1)
	majin_absorb_bp += rec.bp_bonus
	// copy their skill verbs
	for(var/V in M.Keyableverbs)
		if(!(V in verbs))
			verbs += V
			Keyableverbs += V
			rec.added_verbs += V
	// copy their clothes overlays
	rec.clothes = HasOverlays(M, /obj/overlay/clothes)
	duplicateOverlays(rec.clothes)
	majin_absorbed += rec
	// stuff them into the pocket dimension, alive
	var/iz = build_majin_pocket()
	M.absorbed_into = src
	M.loc = locate(round(MAJIN_POCKET_SIZE/2), round(MAJIN_POCKET_SIZE/2), iz)
	M.KO = 0 // alive and conscious inside the pocket, free to act and to die here
	M.icon_state = ""
	emit_Sound('absorb.wav')
	SpreadHeal(100, 1, 0)
	Ki = MaxKi
	overcharge = 1
	to_chat(M, "<font color=#d050c0>[src] absorbs you! You are trapped inside them, alive — escape by being freed, by their defeat, or by dying here.</font>", "system")
	to_chat(src, "<font color=#d050c0>You absorb [M] — their power, their skills and their garb are yours while they remain inside you.</font>", "system")
	to_chat(oview(src), "<font color=#d050c0>[src] absorbs [M]!</font>", "combat")
	// --- saga advancement on absorb ---
	if(is_corrupted_majin())
		if((M.Race == "Kai" || M.Parent_Race == "Kai") && !majin_kai_absorbed && majin_saga_form == 0)
			majin_kai_absorbed = 1
			majin_advance_form(1, null) // Kai absorb -> Form 1
		else if(majin_saga_form == 3)
			majin_form3_players++
			to_chat(src, "<font color=#d050c0>Players consumed in this form: [majin_form3_players]/3.</font>", "system")
			if(majin_form3_players >= 3) majin_advance_form(4, "super 2 transformation")

mob/proc/majin_release(datum/MajinAbsorbed/rec, escaped)
	if(!rec) return
	majin_absorb_bp = max(majin_absorb_bp - rec.bp_bonus, 0)
	for(var/V in rec.added_verbs)
		verbs -= V
		Keyableverbs -= V
	if(rec.clothes.len) removeOverlays(rec.clothes)
	var/mob/M = rec.who
	if(!M) for(var/mob/P in player_list) if(P.signature == rec.sig) { M = P; break }
	if(M)
		M.absorbed_into = null
		if(M.z == majin_pocket_z) // they're inside MY pocket -> spill them out next to me
			M.loc = locate(src.x, src.y, src.z)
			step(M, dir)
			spawn M.KO()
			to_chat(M, "<font color=#d050c0>You spill back out into the world.</font>", "system")
	if(majin_absorbed) majin_absorbed -= rec

mob/proc/majin_release_by_mob(mob/M) // an absorbed player died inside -> free them, Majin loses their gains
	if(!majin_absorbed) return
	for(var/datum/MajinAbsorbed/rec in majin_absorbed.Copy())
		if(rec.who == M || rec.sig == M.signature)
			majin_release(rec, 1)
			return

mob/proc/majin_escape_all()
	if(!majin_absorbed || !majin_absorbed.len) return
	for(var/datum/MajinAbsorbed/rec in majin_absorbed.Copy())
		majin_release(rec, 1)
	to_chat(src, "<font color=#d050c0>Everyone you held inside has broken free!</font>", "system")

// ---- saga form advancement ---------------------------------------------------
mob/proc/majin_form_icon(form)
	switch(form)
		if(1) return 'Majin - Form 1.dmi'
		if(2) return 'Majin - Form 2.dmi'
		if(3) return 'Majin - Form 3.dmi'
		if(4) return 'Majin - Form 4.dmi'
	return icon

mob/proc/majin_apply_form_icon(form)
	var/ic = majin_form_icon(form)
	if(!ic) return
	icon = ic
	if(majin_color) icon += majin_color // keep the colour chosen at creation

mob/proc/majin_advance_form(newform, animstate)
	if(majin_saga_busy) return
	if(newform <= majin_saga_form) return
	majin_saga_busy = 1
	MajinSagaCinematic(newform, animstate)
	majin_saga_form = newform
	majin_apply_form_icon(newform)
	if(genome) genome.add_to_stat("Battle Power", 1) // each stage is a real step up in power
	majin_saga_busy = 0
	switch(newform)
		if(1) to_chat(src, "<font color=#d050c0><b>The Kai's essence reshapes you — you have taken your first true Majin Form.</b></font>", "system")
		if(2)
			to_chat(src, "<font color=#d050c0><b>Grief and fury split your very being apart!</b></font>", "system")
			majin_spawn_clone()
		if(3) to_chat(src, "<font color=#d050c0><b>You devour your other half and surge into a Super Majin!</b></font>", "system")
		if(4)
			to_chat(src, "<font color=#d050c0><b>Three souls fuel your ascension — you have reached your ultimate form.</b></font>", "system")
			majin_check_pure_unlock()

// ---- the cinematic (slow, lightning, shockwaves; plays a named dmi animation) -
mob/proc/MajinSagaCinematic(newform, animstate)
	poweruprunning = 1
	move = 0
	dir = SOUTH
	emit_Sound('rockmoving.wav')
	emit_TransformMusic('Super Buu Theme (FULL).mp3', 1730) //~173s; the Majin saga Form 1-4 transformations
	to_chat(view(src), "<font color=#d050c0>*A wave of pink energy detonates around [src]!*</font>", "combat")
	for(var/cyc = 1 to 14)
		spawn for(var/turf/T in view(rand(3,7), src))
			if(prob(9)) createLightningmisc(T, rand(2,5))
			else if(prob(10)) createDustmisc(T, 2)
		if(cyc % 4 == 0) spawn Quake()
		sleep(10)
	var/image/I = image(icon='Aurabigcombined.dmi')
	I.plane = 7
	overlayList += I
	overlaychanged = 1
	emit_Sound('chargeaura.wav')
	Quake()
	spawn Quake()
	createShockwavemisc(loc, 3)
	createCrater(loc, 3)
	// play the named animation baked into the destination form's .dmi, then settle on it
	var/destic = majin_form_icon(newform)
	if(destic && animstate)
		icon = destic
		if(majin_color) icon += majin_color
		flick(animstate, src)
		sleep(15)
	for(var/cyc = 1 to 10)
		spawn for(var/turf/T in view(rand(4,8), src))
			if(prob(15)) createLightningmisc(T, rand(3,6))
		if(cyc % 3 == 0) spawn Quake()
		sleep(10)
	createShockwavemisc(loc, 2)
	overlayList -= I
	overlaychanged = 1
	move = 1
	poweruprunning = 0
	emit_Sound('powerup.wav')

// ---- the NPC clone spawned on Form 2 -----------------------------------------
mob/npc/MajinClone // a hostile other-half: copies the player's stats/skills, must be beaten + absorbed
	hasAI = 1
	AIAlwaysActive = 1
	monster = 1
	Player = 0

mob/proc/majin_spawn_clone()
	var/mob/npc/MajinClone/clone = makeCopy(2, Race, Class, /mob/npc/MajinClone, TRUE)
	if(!clone) return
	clone.name = name
	clone.is_majin_saga_clone = 1
	clone.saga_master_sig = signature
	majin_clone_sig = signature
	clone.icon = 'Majin - Form 1.dmi'
	if(majin_color) clone.icon += majin_color
	clone.nokill = 0       // it CAN be defeated (then absorbed)
	clone.temporary = 0    // doesn't auto-clean
	clone.hasAI = 1
	clone.AIAlwaysActive = 1
	clone.loc = locate(src.x, src.y, src.z)
	step(clone, turn(dir, 180))
	clone.target = src
	spawn clone.foundTarget(src)
	to_chat(view(src), "<font color=#d050c0>*A second Majin tears its way out of [src]!*</font>", "combat")

// ---- PURE FORM ---------------------------------------------------------------
mob/proc/majin_check_pure_unlock()
	if(majin_pure_unlocked) return
	if(majin_saga_form != 4) return
	if(BP < ssj3at / 10) return // "near the SSJ3 minimum for Saiyans" = the base SSJ3 gate (ssj3at/10)
	if(majin_absorbed && majin_absorbed.len) return // must have LOST all absorptions (e.g. from a KO)
	majin_pure_unlocked = 1
	verbs += /mob/keyable/verb/Pure_Form
	emit_Sound('powerup.wav')
	to_chat(src, "<font color=#ff70d0><b>Stripped of everything you stole, your own raw power awakens. A new skill, Pure Form, is yours.</b></font>", "system")

mob/keyable/verb/Pure_Form()
	set category = "Skills"
	if(!usr.majin_pure_unlocked) return
	if(usr.in_pure_form) { to_chat(usr, "You are already in your Pure Form."); return }
	if(usr.majin_saga_form != 4) return
	if(usr.majin_saga_busy) return
	usr.majin_enter_pure()

mob/proc/majin_enter_pure()
	majin_saga_busy = 1
	MajinSagaCinematicPure()
	in_pure_form = 1
	transBuff = 18 // 18x BP
	icon = 'MajinForm11.dmi'
	if(majin_color) icon += majin_color
	majin_saga_busy = 0
	to_chat(src, "<font color=#ff70d0><b>You have become your Pure Form — every scrap of borrowed power burned away for your own.</b></font>", "system")
	if(!pure_running) { pure_running = 1; spawn majin_pure_loop() }

mob/proc/majin_pure_loop()
	while(in_pure_form && src)
		sleep(12)
		Ki -= MaxKi * 0.02
		stamina -= maxstamina * 0.015
		if(Ki <= 0 || stamina <= 0 || KO)
			majin_revert_pure()
			break
	pure_running = 0

mob/proc/majin_revert_pure()
	if(!in_pure_form) return
	in_pure_form = 0
	transBuff = 1
	majin_apply_form_icon(4) // back to Form 4
	to_chat(src, "<font color=#d050c0>Your Pure Form burns out and you sink back to your prior shape.</font>", "system")

mob/proc/MajinSagaCinematicPure()
	poweruprunning = 1
	move = 0
	emit_Sound('rockmoving.wav')
	emit_TransformMusic('Buu Is Fighting.mp3', 1060) //~106s; plays EVERY time Pure Form is activated
	to_chat(view(src), "<font color=#ff70d0>*[src]'s flesh boils and shrinks as a pure, ancient power surfaces!*</font>", "combat")
	icon = 'MajinForm11.dmi'
	if(majin_color) icon += majin_color
	flick("kid trans", src)
	for(var/cyc = 1 to 12)
		spawn for(var/turf/T in view(rand(3,7), src))
			if(prob(14)) createLightningmisc(T, rand(3,6))
		if(cyc % 3 == 0) spawn Quake()
		sleep(10)
	createShockwavemisc(loc, 3)
	createCrater(loc, 3)
	move = 1
	poweruprunning = 0
	emit_Sound('powerup.wav')
