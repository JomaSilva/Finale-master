// =============================================================================
// DEMON EVOLVE — a Demon who picked the DemonForm1 body and reaches 1,000,000 base
// BP unlocks the "Evolve" skill. Evolving runs a slow lightning/shockwave cinematic
// (Super Janemba theme), PERMANENTLY swaps the body to a chosen final demon form,
// and grants +1,000,000 BP. One-time, irreversible.
// =============================================================================
mob/var
	demon_can_evolve = 0    //Evolve verb unlocked (persists in savefile)
	demon_evolved = 0       //already evolved (persists)
	tmp/demon_evolving = 0  //cinematic in progress

// Polled from the periodic Stats loop (next to CheckSSj3Learn). Cheap for non-demons.
mob/proc/CheckDemonEvolve()
	if(demon_evolved) return
	if(!(Race == "Demon" || Parent_Race == "Demon")) return
	if(demon_can_evolve) // relog safety: ensure the Evolve verb is present
		if(!(/mob/keyable/verb/Evolve in verbs)) verbs += /mob/keyable/verb/Evolve
		return
	if(icon != 'DemonForm1.dmi') return // only the DemonForm1 lineage can evolve
	if(BP < 1000000) return
	demon_can_evolve = 1
	verbs += /mob/keyable/verb/Evolve
	emit_Sound('powerup.wav')
	to_chat(src, "<font color=#c060f0><b>A monstrous power claws its way up from within you. A new skill, Evolve, is within your grasp.</b></font>", "system")
	src << browse({"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'></head>
<body style='margin:0;background:#0c0710;color:#e7d6f2;font-family:Segoe UI,Tahoma,sans-serif;text-align:center;padding:34px'>
<div style='font-size:26px;font-weight:bold;color:#c060f0;letter-spacing:2px'>EVOLUTION AWAITS</div>
<p style='color:#a98fc0;margin-top:18px'>Your demonic blood has reached a threshold of raw power.</p>
<p>Use the <b style='color:#d8a0ff'>Evolve</b> skill to undergo a permanent metamorphosis.</p>
<p style='color:#80506a;font-size:12px;margin-top:22px'>There is no turning back.</p>
</body></html>"}, "window=DemonEvolve;size=460x300")

mob/keyable/verb/Evolve()
	set category = "Skills"
	if(usr.demon_evolved)
		to_chat(usr, "You have already evolved.")
		return
	if(!usr.demon_can_evolve || usr.demon_evolving) return
	var/choice = input(usr, "Choose the form you will become. This is PERMANENT.", "Evolve") in list("Crimson Devil (DemonForm4)","Black Devil (DemonForm4 black)","Shadow Fiend (DemonForm3 black)","Cancel")
	if(!choice || choice == "Cancel") return
	var/newicon = 'DemonForm4.dmi'
	if(findtext(choice, "Black Devil")) newicon = 'DemonForm4black.dmi'
	else if(findtext(choice, "Shadow Fiend")) newicon = 'DemonForm3_black.dmi'
	usr.DemonEvolveCinematic(newicon)

mob/proc/DemonEvolveCinematic(newicon)
	if(demon_evolving || demon_evolved) return
	demon_evolving = 1
	poweruprunning = 1
	move = 0
	dir = SOUTH
	emit_Sound('rockmoving.wav')
	emit_TransformMusic('Dragon Ball Z Dokkan Battle - PHY LR Super Janemba OST (Extended).mp3', 600) // ~60s, ducks listeners' battle music
	to_chat(view(src), "<font color=#b048d0>*A black aura coils around [src] as something monstrous begins to surface...*</font>", "combat")
	// --- slow build: pedras subindo (foco) + tornados + raios espalhados + tremores (~16s) ---
	for(var/cyc = 1 to 16)
		spawn for(var/turf/T in view(9,src))
			if(get_dist(T,src) < 3) continue //espaca: nada colado no personagem
			if(prob(5)) createDustmisc(T, 2) //pedrinhas subindo (foco)
			else if(prob(4)) createDustmisc(T, 3) //tornados de pedra (bastante)
			else if(prob(3)) createLightningmisc(T, rand(2,4))
		if(cyc % 4 == 0) spawn Quake()
		sleep(10)
	// --- the rising surge: aura overlay + quakes + 8-way ground beams (~12s) ---
	var/image/I = image(icon='Aurabigcombined.dmi')
	I.plane = 7
	overlayList += I
	overlaychanged = 1
	emit_Sound('chargeaura.wav')
	Quake()
	spawn Quake()
	var/amount = 8
	while(amount)
		var/obj/A = new/obj
		A.loc = locate(x,y,z)
		A.icon = 'Electricgroundbeam2.dmi'
		if(amount==8) spawn(rand(1,40)) walk(A,NORTH,2)
		if(amount==7) spawn(rand(1,40)) walk(A,SOUTH,2)
		if(amount==6) spawn(rand(1,40)) walk(A,EAST,2)
		if(amount==5) spawn(rand(1,40)) walk(A,WEST,2)
		if(amount==4) spawn(rand(1,40)) walk(A,NORTHWEST,2)
		if(amount==3) spawn(rand(1,40)) walk(A,NORTHEAST,2)
		if(amount==2) spawn(rand(1,40)) walk(A,SOUTHWEST,2)
		if(amount==1) spawn(rand(1,40)) walk(A,SOUTHEAST,2)
		spawn(50) del(A)
		amount--
	for(var/cyc = 1 to 12)
		spawn for(var/turf/T in view(10,src))
			if(get_dist(T,src) < 3) continue //espaca
			if(prob(6)) createDustmisc(T, 2) //pedrinhas (foco)
			else if(prob(5)) createDustmisc(T, 3) //tornados (bastante)
			else if(prob(4)) createLightningmisc(T, rand(3,6))
		if(cyc % 3 == 0) spawn Quake()
		sleep(10)
	// --- climax: shockwave + crater + the irreversible body change ---
	createShockwavemisc(loc, 3)
	createCrater(loc, 3)
	emit_Sound('aura.wav')
	overlayList -= I
	overlaychanged = 1
	icon = newicon // PERMANENT new body (mob.icon is saved)
	BP += 1000000  // reward power
	demon_evolved = 1
	demon_can_evolve = 0
	verbs -= /mob/keyable/verb/Evolve
	createShockwavemisc(loc, 2)
	move = 1
	poweruprunning = 0
	demon_evolving = 0
	emit_Sound('powerup.wav')
	to_chat(src, "<font color=#c060f0><b>Your evolution is complete. You have become something far darker.</b></font>", "system")
	to_chat(view(src), "<font color=#b048d0>*The dust clears, revealing [src]'s monstrous new form.*</font>", "combat")
