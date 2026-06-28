// =============================================================================
// HTML / CSS UI FRAMEWORK  — modern browser-rendered character panel (DU-style).
//   EMBEDDED into the stat-panel slot: skin.dmf's "Infopane.Info" control was
//   switched from INFO to BROWSER, and we render the whole panel into it.
//   Content tabs (Stats/Items/Equip/Body/Forms/Ki/People/World) read real vars;
//   verb tabs (Skills/Other/Learning/Admin) list the player's verbs as buttons
//   that run via winset(command=...). Re-renders only on change (no flicker).
//   (Verbs also remain reachable from the top "Commands" menu as a safety net.)
// =============================================================================

#define UI_BROWSER "Infopane.Info" //the embedded BROWSER control we render the panel into

// The <meta IE=edge> is ESSENTIAL or BYOND's embedded browser runs an ancient
// engine and flexbox/modern CSS breaks.
var/UI_CSS = {"
<meta http-equiv='X-UA-Compatible' content='IE=edge'>
<style>
 *{box-sizing:border-box}
 html,body{margin:0;padding:0}
 body{background:#0f1115;color:#d6d9df;font-family:'Segoe UI',Tahoma,sans-serif;font-size:13px}
 .wrap{padding:9px 11px}
 .tabs{display:flex;gap:5px;margin-bottom:9px;flex-wrap:wrap}
 .tab{background:#1b1e25;color:#9aa0ab;padding:5px 11px;border-radius:7px;text-decoration:none;font-weight:bold;font-size:11px}
 .tab.on{background:#2b303a;color:#ffffff}
 .sec{color:#6f7681;font-size:10px;font-weight:bold;letter-spacing:1.5px;margin:14px 0 5px}
 .row{display:flex;justify-content:space-between;align-items:baseline;padding:5px 2px;border-bottom:1px solid #1b1e25}
 .k{color:#c4c8d0}
 .v{font-weight:bold;color:#f2f4f8;text-align:right;white-space:nowrap}
 .hi{color:#56c271} .lo{color:#cf8a55} .av{color:#c9b85a}
 .mut{color:#7a8089;font-weight:normal}
 .verbs{display:flex;flex-wrap:wrap;gap:6px;margin-top:4px}
 .verb{background:#1b1e25;color:#d6d9df;padding:7px 11px;border-radius:6px;text-decoration:none;font-size:12px}
 .verb:hover{background:#33a0e0;color:#fff}
 .vsearch{width:100%;background:#1b1e25;color:#f2f4f8;border:1px solid #2b303a;border-radius:6px;padding:7px 10px;font-size:12px;margin:2px 0 6px;outline:none;display:block}
 .vsearch:focus{border-color:#33a0e0}
 .hud{padding:5px 7px}
 .hr{display:flex;align-items:center;gap:7px;margin:3px 0}
 .hl{width:22px;font-weight:bold;font-size:11px}
 .hb{flex:1;height:11px;background:#1b1e25;border-radius:5px;overflow:hidden;border:1px solid #2b303a}
 .hf{height:100%;border-radius:5px}
 .hv{min-width:84px;text-align:right;font-weight:bold;font-size:11px;color:#f2f4f8;white-space:nowrap}
 .tier{display:flex;align-items:center;gap:8px;margin:5px 0;border-bottom:1px solid #1b1e25;padding-bottom:5px}
 .tlbl{width:46px;color:#6f7681;font-size:10px;font-weight:bold;letter-spacing:1px;flex-shrink:0}
 .trow{display:flex;flex-wrap:wrap;gap:6px;flex:1}
 .tcard{background:#1b1e25;color:#e8e8e8;padding:8px 12px;border-radius:7px;text-decoration:none;font-size:12px;border:1px solid #2b303a}
 .tcard:hover{background:#2b303a;border-color:#33a0e0}
 .tnone{color:#5a6068;font-size:11px;font-style:italic}
 .irow{display:flex;justify-content:space-between;align-items:center;padding:5px 2px;border-bottom:1px solid #1b1e25;gap:6px}
 .iname{color:#e8e8e8;flex:1}
 .ibtns{display:flex;gap:4px;flex-shrink:0}
 .ibtn{background:#1b1e25;color:#aab2bd;padding:3px 8px;border-radius:5px;text-decoration:none;font-size:10px;border:1px solid #2b303a}
 .ibtn:hover{background:#33a0e0;color:#fff}
 .ion{background:#23402a;color:#9fe0a8}
 .ides:hover{background:#c0392b;border-color:#c0392b}
</style>
"}

mob/var/tmp
	statsUItab = "Stats"
	last_stats_html = ""
	statsUIrunning = 0

// ---- HTML helpers (reusable across panels) ---------------------------------
proc/ui_sec(title)
	return "<div class='sec'>[title]</div>"
proc/ui_row(label, value, vclass)
	return "<div class='row'><span class='k'>[label]</span><span class='v [vclass]'>[value]</span></div>"
proc/ui_qual(val, mean)
	if(mean <= 0) return "av"
	if(val >= mean * 1.2) return "hi"
	if(val <= mean * 0.8) return "lo"
	return "av"
proc/ui_qual_label(val, mean)
	switch(ui_qual(val, mean))
		if("hi") return "High"
		if("lo") return "Low"
	return "Average"

// How many times the NORMAL rate you're currently gaining BP. Universal factors
// (area/Time-Chamber via Egains, stamina) times the dominant gain path: weights
// (regular training) OR gravity-training (incl. the low-gravity accustom buff),
// each normalized to a plain weight=1 / gravity=1 session.
// Mirrors the ACTUAL passive Grav_Gain() loop: per tick you gain
//   relBPmax*BPTick*TrainMod*Egains*GlobalGravGain*(effgrav/gravGainDiv).
// We report that rate as a MULTIPLE of a 1x-gravity / neutral-area baseline
// (effgrav=1, Egains=1): the relBPmax*BPTick*TrainMod*gravGainDiv terms all
// cancel, leaving Egains*GlobalGravGain*effgrav. Gravity is LINEAR, so 10x
// gravity reads ~10x. Worn weights (1-2x) multiply your training gain on top.
mob/proc/bp_gain_mult()
	var/area = max(Egains, 0) * max(StamBPGainMod, 0) * max(GainsRate, 0) //region/HBTC/stamina/training boosts
	var/grav = Planetgrav + gravmult
	var/effgrav = grav
	if(GravMastered > grav) effgrav += (GravMastered - grav) * gravAccustomWeight //low-gravity acclimation buff
	if(grav < 1) effgrav = 0 //true zero-g (space) trains nothing
	var/gmult = area * max(GlobalGravGain, 0) * effgrav //passive gravity gain vs the 1x neutral baseline
	var/wmult = (weight > 1) ? weight : 1 //weights multiply TRAINING gain (1-2x)
	return round(max(gmult, 0.01) * wmult, 0.01)

// ---- page assembly: tab bar + active tab -----------------------------------
//Tabs that a SKILL added at runtime (e.g. Sense). A skill registers its tab name via register_html_tab();
//the HTML UI then shows it and renders it through mob/proc/ui_tab_<name>() automatically - so any future
//skill that creates a panel just needs to register a name + provide a matching ui_tab_ proc.
mob/var/list/html_skill_tabs = null

mob/proc/register_html_tab(tabname)
	if(!tabname) return
	if(!html_skill_tabs) html_skill_tabs = list()
	html_skill_tabs |= tabname

mob/proc/render_skill_tab(tabname)
	var/pn = "ui_tab_[lowertext(replacetext("[tabname]", " ", ""))]" //"Sense" -> ui_tab_sense ; "Known People" -> ui_tab_knownpeople
	if(hascall(src, pn)) return call(src, pn)()
	return ui_sec(html_encode("[tabname]")) + "<div class='mut' style='padding:8px'>(this panel has no detailed view yet)</div>"

mob/proc/BuildStatsHTML()
	var/list/tabs = list("Stats","Items","Equip","Body","Forms","Ki","People","World","Skills","Other","Learning")
	if(Admin) tabs += "Admin"
	if(html_skill_tabs && html_skill_tabs.len) tabs += html_skill_tabs //skill-added panels (Sense, etc.)
	var/list/h = list()
	h += "<div class='tabs'>"
	for(var/t in tabs)
		h += "<a class='tab[statsUItab==t ? " on" : ""]' href='byond://?src=\ref[src];statsTab=[t]'>[t]</a>"
	h += "</div>"
	switch(statsUItab)
		if("Items")    h += ui_tab_items()
		if("Equip")    h += ui_tab_equip()
		if("Body")     h += ui_tab_body()
		if("Forms")    h += ui_tab_forms()
		if("Ki")       h += ui_tab_ki()
		if("People")   h += ui_tab_people()
		if("World")    h += ui_tab_world()
		if("Skills")   h += ui_tab_verbs("Skills")
		if("Other")    h += ui_tab_verbs("Other")
		if("Learning") h += ui_tab_verbs("Learning")
		if("Admin")    h += ui_tab_verbs("Admin")
		else
			if(html_skill_tabs && (statsUItab in html_skill_tabs)) h += render_skill_tab(statsUItab)
			else h += ui_tab_stats()
	return "<html><head>[UI_CSS]</head><body><div class='wrap'>[jointext(h, "")]</div></body></html>"

// ---- STATS -----------------------------------------------------------------
mob/proc/ui_tab_stats()
	var/list/h = list()
	h += ui_sec("POWER")
	if(scouteron)
		h += ui_row("BATTLE POWER", "[FullNum(round(expressedBP))] <span class='mut'>(base [FullNum(round(BP))])</span>", "")
	else
		h += ui_row("BATTLE POWER", "??? <span class='mut'>(no scouter)</span>", "")
	var/gm = bp_gain_mult()
	var/_grav = Planetgrav + gravmult
	var/_eff = _grav
	if(GravMastered > _grav) _eff += (GravMastered - _grav) * gravAccustomWeight
	var/gtxt = "[_grav]x grav"
	if(_eff > _grav) gtxt += " (+acclim &rarr; [round(_eff,0.1)])" //low-grav acclimation pushes the effective gravity up
	if(weight > 1) gtxt += " &middot; [round(weight,0.01)]x weights"
	h += ui_row("BP GAIN", "[gm]x <span class='mut'>([gtxt])</span>", gm >= 1.5 ? "hi" : (gm < 0.9 ? "lo" : ""))
	h += ui_row("HEALTH", "[round(HP)]%", HP >= 66 ? "hi" : (HP <= 33 ? "lo" : "av"))
	h += ui_row("ENERGY (KI)", "[FullNum(round(Ki))] / [FullNum(round(MaxKi))] <span class='mut'>[round((Ki / max(MaxKi,1)) * 100)]%</span>", "")
	h += ui_row("STAMINA", "[round(staminapercent * 100)]%", "")
	if(godki && godki.energy > 0 && godki.max_energy > 0)
		h += ui_row("GOD KI", "[FullNum(round(godki.energy))] / [FullNum(round(godki.max_energy))]", "")
	h += ui_sec("ATTRIBUTES")
	var/list/atts = list(
		"Physical Offense" = Rphysoff, "Physical Defense" = Rphysdef,
		"Ki Offense" = Rkioff,         "Ki Defense" = Rkidef,
		"Technique" = Rtechnique,      "Ki Skill" = Rkiskill,
		"Speed" = Rspeed,              "Esoteric" = Rmagiskill)
	var/mean = 0
	for(var/k in atts) mean += atts[k]
	mean /= max(atts.len, 1)
	for(var/k in atts)
		h += ui_row(k, "[round(atts[k] * 10)] <span class='mut'>([ui_qual_label(atts[k], mean)])</span>", ui_qual(atts[k], mean))
	h += ui_row("Willpower", "[Ewillpower]", "")
	h += ui_row("Intelligence", "[round(techmod * 10)]", "")
	h += ui_sec("STATE")
	h += ui_row("STATUS", combatTag ? "In Battle" : "Out of Danger", combatTag ? "lo" : "hi")
	h += ui_row("EMOTION", html_encode("[Emotion] / [relaxedstate]"), "")
	if(currentStyle) h += ui_row("STYLE", html_encode(currentStyle.name), "")
	h += ui_sec("PROGRESS &amp; CURRENCY")
	h += ui_row("GRAVITY", "[Planetgrav + gravmult]x <span class='mut'>([round(GravMastered)] mastered)</span>", "")
	h += ui_row("NUTRITION", "[round((currentNutrition / max(maxNutrition,1)) * 100)]%", "")
	h += ui_row("MILESTONES", "[skillpoints] / [totalskillpoints]", "")
	h += ui_row("ZENNI", "[FullNum(zenni)]", "")
	h += ui_row("LOCATION", "[x], [y], [z]", "mut")
	return jointext(h, "")

// ---- ITEMS -----------------------------------------------------------------
mob/proc/ui_tab_items()
	var/list/h = list()
	h += ui_sec("INVENTORY")
	h += ui_row("Zenni", "[FullNum(zenni)]", "")
	h += ui_row("Space", "[inven_min] / [inven_max]", "")
	h += ui_sec("CARRIED")
	//GROUP identical items so stacks show as one row with a count. Stackable items (food, etc.) merge
	//into a single obj carrying `amount` (the stack size); plain duplicates are separate objs of the same
	//type. Either way we collapse them to "Name &times;N". Equipped items stay a separate group.
	var/list/reps = list()   //group key -> representative obj (buttons act on it)
	var/list/counts = list() //group key -> total quantity
	var/list/order = list()  //first-seen order so the list is stable
	for(var/obj/o in src)
		if(!(istype(o, /obj/items) || istype(o, /obj/Trees) || istype(o, /obj/Artifacts) || istype(o, /obj/DB) || istype(o, /obj/Spacepod) || istype(o, /obj/Boat) || istype(o, /obj/bodyparts)))
			continue
		var/qty = 1
		if(istype(o, /obj/items))
			var/obj/items/it = o
			if(it.amount > 1) qty = it.amount //a merged stackable stack
		var/key = "[o.type]|[o.name]|[o.equipped]"
		if(key in reps)
			counts[key] += qty
		else
			reps[key] = o
			counts[key] = qty
			order += key
	if(!order.len)
		h += "<div class='row'><span class='mut'>Your pockets are empty.</span></div>"
		return jointext(h, "")
	for(var/key in order)
		var/obj/o = reps[key]
		var/qty = counts[key]
		var/list/btns = list()
		var/has_drop = 0
		for(var/V in o.verbs) //expose ALL of the item's own verbs as buttons (Equip, Upgrade, Icon, ...)
			var/vpath = "[V]"
			var/vname = copytext(vpath, findlasttext(vpath, "/") + 1) //the verb's proc name, e.g. "Upgrade"
			if(vname == "Drop") has_drop = 1
			var/cls = "ibtn"
			var/label = replacetext(vname, "_", " ")
			if(vname == "Equip" && o.equipped) //the Equip verb toggles; reflect the current state
				cls = "ibtn ion"
				label = "Unequip"
			btns += "<a class='[cls]' href='byond://?src=\ref[src];itemverb=[vname];iref=\ref[o]'>[html_encode(label)]</a>"
		if(!has_drop) btns += "<a class='ibtn' href='byond://?src=\ref[src];itemact=drop;iref=\ref[o]'>Drop</a>"
		btns += "<a class='ibtn ides' href='byond://?src=\ref[src];itemact=destroy;iref=\ref[o]'>Destroy</a>"
		var/nm = html_encode(o.name)
		if(qty > 1) nm += " <span class='mut'>&times;[qty]</span>"
		h += "<div class='irow'><span class='iname'>[nm]</span><span class='ibtns'>[jointext(btns, "")]</span></div>"
	return jointext(h, "")

// ---- EQUIPMENT -------------------------------------------------------------
mob/proc/ui_tab_equip()
	var/list/h = list()
	h += ui_sec("COMBAT")
	h += ui_row("Damage", "[damage]", "")
	h += ui_row("Penetration", "[penetration]", "")
	h += ui_row("Accuracy", "[accuracy]", "")
	h += ui_row("Deflection", "[deflection]", "")
	h += ui_row("Attack Delay", "[round(hitspeedMod * 100)]%", "")
	h += ui_sec("ACCESSORIES")
	var/found = 0
	for(var/obj/items/Equipment/Accessory/A in contents)
		if(A.equipped)
			found++
			h += ui_row(html_encode(A.name), "<span class='hi'>equipped</span>", "mut")
	if(!found) h += "<div class='row'><span class='mut'>Nothing equipped.</span></div>"
	return jointext(h, "")

// ---- BODY ------------------------------------------------------------------
mob/proc/ui_tab_body()
	var/list/h = list()
	h += ui_sec("LIMBS")
	for(var/datum/Body/b in body)
		if(b.lopped || b.status == "Missing") continue //torn-off limbs vanish from the list (they show purple on the paperdoll)
		var/pct = round((b.health / max(b.maxhealth,1)) * 100)
		var/cls = pct >= 66 ? "hi" : (pct <= 33 ? "lo" : "av")
		h += ui_row(html_encode(b.name), "[round(b.health)]/[round(b.maxhealth)] <span class='mut'>([pct]%)</span> &mdash; <span class='mut'>[injury_word(pct)]</span>", cls)
	return jointext(h, "")

//Injury level word matching the Body tab / limbstatus thresholds (Injuries.dm) and the paperdoll colour bands.
proc/injury_word(pct)
	if(pct >= 100) return "Healthy"
	if(pct >= 80)  return "Slightly Injured"
	if(pct >= 60)  return "Injured"
	if(pct >= 40)  return "Seriously Injured"
	if(pct >= 20)  return "Critically Injured"
	return "Broken"

proc/sense_dir_word(d)
	switch(d)
		if(NORTH) return "N"
		if(SOUTH) return "S"
		if(EAST) return "E"
		if(WEST) return "W"
		if(NORTHEAST) return "NE"
		if(NORTHWEST) return "NW"
		if(SOUTHEAST) return "SE"
		if(SOUTHWEST) return "SW"
	return "?"

// ---- SENSE (HTML mirror of StatSense; this is the tab the Sense skill registers) -------------------
mob/proc/ui_tab_sense()
	var/list/h = list()
	h += ui_sec("SENSE")
	if(!gotsense)
		h += "<div class='mut' style='padding:8px'>You cannot sense ki yet.</div>"
		return jointext(h, "")
	var/list/shown = list()
	//nearby (same z, within 15 tiles): a precise read of power + health
	if(current_area)
		for(var/mob/D in current_area.contents)
			if(D == src || D.isconcealed || D.Race == "Android") continue
			if(D.expressedBP <= 5) continue
			if(D.z != z || get_dist(src, D) > 15) continue
			shown |= D
			var/nm = check_familiarity(D) ? html_encode(D.name) : "<span class='mut'>??? ([D.signature])</span>"
			h += ui_row(nm, "[round((D.expressedBP/max(expressedBP,1))*100,1)]% pwr <span class='mut'>&middot; [round(D.HP)]% hp</span>", "")
	//gotsense2: planet-wide directional read
	if(gotsense2)
		for(var/mob/D in player_list)
			if(D == src || (D in shown) || D.isconcealed || D.Race == "Android") continue
			if(D.expressedBP <= 5 || D.z != z) continue
			shown |= D
			var/nm = check_familiarity(D) ? html_encode(D.name) : "<span class='mut'>??? ([D.signature])</span>"
			h += ui_row(nm, "[round((D.expressedBP/max(expressedBP,1))*100,1)]% pwr <span class='mut'>&middot; [get_dist(src,D)] tiles [sense_dir_word(get_dir(src,D))]</span>", "")
	//gotsense3: galaxy-wide rough location of powerful beings
	if(gotsense3)
		for(var/mob/D in player_list)
			if(D == src || (D in shown) || D.Race == "Android") continue
			if(D.expressedBP <= 5000000) continue
			shown |= D
			var/nm = check_familiarity(D) ? html_encode(D.name) : "<span class='mut'>??? ([D.signature])</span>"
			h += ui_row(nm, "[round((D.BP/max(BP,1))*100,1)]% pwr <span class='mut'>&middot; (?,?,z[D.z])</span>", "")
	if(!shown.len)
		h += "<div class='mut' style='padding:8px'>You sense no notable presences.</div>"
	return jointext(h, "")

// ---- FORMS & MASTERY -------------------------------------------------------
mob/proc/ui_tab_forms()
	var/list/h = list()
	h += ui_sec("ACTIVE MULTIPLIERS")
	h += ui_row("Total BP Mult", "[round(expressedBP / max(BP,1), 0.01)]x", "")
	if(round(ssjBuff, 0.01) != 1)   h += ui_row("Form (SSJ ladder)", "[round(ssjBuff, 0.01)]x", "")
	if(round(transBuff, 0.01) != 1) h += ui_row("Transformation", "[round(transBuff, 0.01)]x", "")
	if(round(formsBuff, 0.01) != 1) h += ui_row("Forms", "[round(formsBuff, 0.01)]x", "")
	if(godki && godki.usage)        h += ui_row("God Ki", "[round((god_form_mult() || godki.godki_mult), 0.01)]x", "")
	if(round(angerBuff, 0.01) != 1) h += ui_row("Anger", "[round(angerBuff, 0.01)]x", "")
	if(KaiokenMastery > 1)          h += ui_row("Kaio-Ken Mastery", "x[round(KaiokenMastery, 0.1)]", "")
	if(islist(buffoutput) && buffoutput.len >= 3)
		h += ui_sec("BUFFS")
		h += ui_row("Buff", html_encode("[buffoutput[1]]"), "mut")
		h += ui_row("Aura", html_encode("[buffoutput[2]]"), "mut")
		h += ui_row("Form", html_encode("[buffoutput[3]]"), "mut")
	return jointext(h, "")

// ---- KI / MELEE / WEAPON LEVELS --------------------------------------------
mob/proc/ui_tab_ki()
	var/list/h = list()
	h += ui_sec("KI ABILITY")
	h += ui_row("Awareness", "[kiawarenessskill]", "")
	h += ui_row("Effusion", "[kieffusionskill]", "")
	h += ui_row("Circulation", "[kicirculationskill]", "")
	h += ui_row("Control", "[kicontrolskill]", "")
	h += ui_row("Efficiency", "[kiefficiencyskill]", "")
	h += ui_row("Gathering", "[kigatheringskill]", "")
	h += ui_row("Flight", "[flightability]", "")
	h += ui_sec("KI TECHNIQUES")
	h += ui_row("Blast", "[blastskill]", "")
	h += ui_row("Beam", "[beamskill]", "")
	h += ui_row("Kiai", "[kiaiskill]", "")
	h += ui_row("Charged", "[chargedskill]", "")
	h += ui_row("Guided", "[guidedskill]", "")
	h += ui_row("Homing", "[homingskill]", "")
	h += ui_row("Targeted", "[targetedskill]", "")
	h += ui_row("Volley", "[volleyskill]", "")
	h += ui_row("Buff / Debuff", "[kibuffskill] / [kidebuffskill]", "")
	h += ui_row("Defense", "[kidefenseskill]", "")
	h += ui_sec("MELEE")
	h += ui_row("Tactics", "[tactics]", "")
	h += ui_row("Weaponry", "[weaponry]", "")
	h += ui_row("Unarmed", "[unarmedskill]", "")
	h += ui_row("One-Handed", "[onehandskill]", "")
	h += ui_row("Two-Handed", "[twohandskill]", "")
	h += ui_row("Dual Wield", "[dualwieldskill]", "")
	h += ui_sec("WEAPONS")
	h += ui_row("Sword", "[swordskill]", "")
	h += ui_row("Axe", "[axeskill]", "")
	h += ui_row("Staff", "[staffskill]", "")
	h += ui_row("Spear", "[spearskill]", "")
	h += ui_row("Club", "[clubskill]", "")
	h += ui_row("Hammer", "[hammerskill]", "")
	return jointext(h, "")

// ---- KNOWN PEOPLE ----------------------------------------------------------
mob/proc/ui_tab_people()
	var/list/h = list()
	h += ui_sec("KNOWN PEOPLE")
	var/found = 0
	for(var/sig in known_contact_list)
		var/obj/Contact/c = known_contact_list[sig]
		if(!istype(c)) continue
		found++
		var/fpts = friendship["[c.signature]"]
		h += ui_row(html_encode(c.name), html_encode("[acquaintance_label(fpts)] ([round(fpts)])"), "")
		h += "<div class='row'><span class='mut'>&nbsp;&nbsp;[html_encode("[c.c_race] / [c.c_class]")]</span></div>"
	if(!found) h += "<div class='row'><span class='mut'>You haven't met anyone memorable yet.</span></div>"
	return jointext(h, "")

// ---- WORLD -----------------------------------------------------------------
mob/proc/ui_tab_world()
	var/list/h = list()
	h += ui_sec("LOCATION")
	h += ui_row("Planet", html_encode("[Planet]"), "")
	h += ui_row("Coordinates", "[x], [y], [z]", "mut")
	h += ui_row("Gravity", "[Planetgrav + gravmult]x <span class='mut'>([round(GravMastered)] mastered)</span>", "")
	h += ui_sec("SERVER")
	h += ui_row("Lag-O-Meter", "[world.cpu]%", "")
	h += ui_row("Players Online", "[length(player_list)]", "")
	if(Admin)
		h += ui_sec("ADMIN")
		h += ui_row("BP Cap", "[FullNum(BPCap)]", "")
	return jointext(h, "")

// ---- VERB tabs (clickable buttons that run the verb) -----------------------
mob/proc/ui_tab_verbs(category)
	var/list/h = list()
	h += ui_sec(uppertext(category))
	var/found = 0
	var/list/vh = list()
	var/list/seen = list()
	for(var/V in verbs)
		if(V:category != category) continue
		var/vname = "[V:name]"
		if(findtext(vname, "Face ") == 1) continue //hide the 8 directional "Face North/South/..." verbs that clutter Skills
		if(vname in seen) continue
		seen += vname
		found++
		vh += "<a class='verb' href='byond://?src=\ref[src];runverb=[url_encode(vname)]'>[html_encode(vname)]</a>"
	for(var/obj/O in src) //obj-based skills (SplitForm, Buu Absorb, ...) live as verbs on carried objects, not on the mob
		for(var/V in O.verbs)
			if(V:category != category) continue
			var/vname = "[V:name]"
			if(vname in seen) continue
			seen += vname
			found++
			vh += "<a class='verb' href='byond://?src=\ref[src];runverb=[url_encode(vname)]'>[html_encode(vname)]</a>"
	if(!found)
		h += "<div class='row'><span class='mut'>No actions here.</span></div>"
		return jointext(h, "")
	//live client-side filter — type to narrow the verb list (the panel only re-browses when content
	//changes, and the verb list is static, so the box keeps its text/focus while you type).
	h += "<input id='vsearch' class='vsearch' type='text' autocomplete='off' placeholder='Filtrar [found] verbs...' oninput='vflt()' onkeyup='vflt()'>"
	h += "<div id='vlist' class='verbs'>[jointext(vh, "")]</div>"
	h += "<div id='vnone' class='tnone' style='display:none'>Nenhum verb encontrado.</div>"
	h += {"<script>
function vflt(){
 var b=document.getElementById('vsearch'); var list=document.getElementById('vlist');
 if(!b||!list){return;}
 var q=b.value.toLowerCase(); var a=list.getElementsByTagName('a'); var n=0;
 for(var i=0;i<a.length;i++){
  var el=a.item(i); var t=(el.innerText||el.textContent||'').toLowerCase();
  var show=(t.indexOf(q)>=0); el.style.display=show?'':'none'; if(show){n++;}
 }
 var none=document.getElementById('vnone'); if(none){none.style.display=(n==0)?'':'none';}
}
</script>"}
	return jointext(h, "")

// ---- render loop (into the embedded browser) -------------------------------
mob/proc/OpenStatsUI()
	if(!client || statsUIrunning) return
	statsUIrunning = 1
	StatsUILoop()

mob/proc/StatsUILoop()
	set waitfor = 0
	set background = 1
	while(src && client)
		RefreshStatsUI()
		sleep(8) //~0.8s; only re-renders when a value changed (see below)
	statsUIrunning = 0

mob/proc/RefreshStatsUI()
	if(!client) return
	var/html = BuildStatsHTML()
	if(html == last_stats_html) return //nothing changed -> skip the re-render (no flicker / no scroll reset)
	last_stats_html = html
	src << browse(html, "window=[UI_BROWSER]")

// ---- embedded HTML HUD (top-left hppane strip; HUD mode 4) ------------------
proc/hud_bar(label, value, pct, lcolor, c1, c2)
	pct = min(max(pct, 0), 100)
	return "<div class='hr'><span class='hl' style='color:[lcolor]'>[label]</span><div class='hb'><div class='hf' style='width:[pct]%;background:linear-gradient(to right,[c1],[c2])'></div></div><span class='hv'>[value]</span></div>"

mob/proc/BuildHudHTML()
	var/hp = round(HP)
	var/kipct = round((Ki / max(MaxKi,1)) * 100)
	var/stpct = round(staminapercent * 100)
	var/bppct = round(netBuff * 100)
	var/bptxt = scouteron ? "[FullNum(round(expressedBP))]" : "???"
	var/list/h = list()
	h += hud_bar("HP", "[hp]%", hp, "#ff6b6b", "#ff5b5b", "#a51d1d")
	h += hud_bar("KI", "[FullNum(round(Ki))] <span class='mut'>[kipct]%</span>", kipct, "#6fb6ff", "#4f9bff", "#1d5aa5")
	h += hud_bar("ST", "[stpct]%", stpct, "#f0dd55", "#e8d44d", "#9c8112")
	h += hud_bar("BP", "[bptxt] <span class='mut'>[bppct]%</span>", min(bppct, 100), "#c58bff", "#b06bff", "#6a2fa5")
	return "<html><head>[UI_CSS]</head><body><div class='hud'>[jointext(h, "")]</div></body></html>"

mob/proc/HudHtmlLoop()
	set waitfor = 0
	set background = 1
	var/last = ""
	while(src && client)
		sleep(4) //~0.4s
		if(!client || client.HPWindowToggle != 4) continue //only render the HTML HUD in mode 4
		var/html = BuildHudHTML()
		if(html == last) continue //re-render only on change
		last = html
		src << browse(html, "window=hppane.hudbrowser")

// ---- SKILL TREES window (embedded in SkillTreeWindow.treebrowser) -----------
mob/var/tmp/last_tree_html = ""

mob/proc/BuildTreeHTML()
	// replicate PopulateTreeWindow()'s per-mode listing, but as HTML cards
	var/list/TreeList = list()
	if(GetTreeMode == 1) //Get: allowed trees you don't already own — dedup + skip BY TYPE (like PopulateTreeWindow)
		for(var/datum/skill/tree/A in allowed_trees)
			if(A in possessed_trees) continue
			var/flag = 0
			if(locate(A.type) in TreeList) flag = 1       //already listed this type
			if(locate(A.type) in possessed_trees) flag = 1 //you already own this type
			if(A.enabled == 0 || A.override == 1) flag = 1
			if(!flag) TreeList += A
	else //Enter (0) / Refund (2): trees you own (deduped by type)
		for(var/datum/skill/tree/A in possessed_trees)
			var/flag = 0
			if(locate(A.type) in TreeList) flag = 1
			if(A.enabled == 0 || A.override == 1) flag = 1
			if(GetTreeMode == 2 && A.can_refund == FALSE) flag = 1
			if(!flag) TreeList += A
	var/list/byTier = list()
	for(var/t in list(6,5,4,3,2,1,0)) byTier["[t]"] = list()
	for(var/datum/skill/tree/A in TreeList)
		var/tk = "[A.tier]"
		if(byTier[tk]) byTier[tk] += A
	var/list/h = list()
	for(var/t in list(6,5,4,3,2,1,0))
		var/list/trees = byTier["[t]"]
		h += "<div class='tier'><div class='tlbl'>Tier [t]</div><div class='trow'>"
		if(!trees.len)
			h += "<span class='tnone'>&mdash;</span>"
		for(var/datum/skill/tree/A in trees)
			h += "<a class='tcard' href='byond://?src=\ref[src];treeget=\ref[A]'>[html_encode(A.name)]</a>"
		h += "</div></div>"
	return "<html><head>[UI_CSS]</head><body><div class='wrap'>[jointext(h, "")]</div></body></html>"

mob/proc/RenderTreeBrowser()
	if(!client) return
	var/html = BuildTreeHTML()
	if(html == last_tree_html) return
	last_tree_html = html
	src << browse(html, "window=SkillTreeWindow.treebrowser")

// ---- SKILLS sub-window (the per-tree skills; SkillsListWindow.skillbrowser) -
mob/var/tmp/last_skill_html = ""

mob/proc/BuildSkillHTML()
	var/datum/skill/tree/T = CurrentTree
	if(!T) return "<html><head>[UI_CSS]</head><body><div class='wrap'><div class='tnone'>No tree open.</div></div></body></html>"
	var/list/SkillList = list()
	if(!LearnSkillMode) //LEARN: tree skills you don't have yet (mirrors PopulateSkillWindow, deduped by type)
		for(var/datum/skill/A in T.constituentskills)
			if(locate(A.type) in learned_skills) continue
			if(A.enabled == 0 || A.override == 1) continue
			if(A.tier > T.allowedtier) continue
			if(locate(A.type) in SkillList) continue
			SkillList += A
	else //FORGET: learned skills you can refund
		for(var/datum/skill/A in T.investedskills)
			if(!(locate(A.type) in learned_skills)) continue
			if(A.can_forget == FALSE) continue
			if(locate(A.type) in SkillList) continue
			SkillList += A
	var/list/byTier = list()
	for(var/t in list(6,5,4,3,2,1,0)) byTier["[t]"] = list()
	for(var/datum/skill/A in SkillList)
		var/tk = "[A.tier]"
		if(byTier[tk]) byTier[tk] += A
	var/list/h = list()
	h += "<div class='sec'>[html_encode(T.name)] &mdash; [LearnSkillMode ? "FORGET mode" : "LEARN mode"]</div>"
	for(var/t in list(6,5,4,3,2,1,0))
		var/list/sk = byTier["[t]"]
		h += "<div class='tier'><div class='tlbl'>Tier [t]</div><div class='trow'>"
		if(!sk.len) h += "<span class='tnone'>&mdash;</span>"
		for(var/datum/skill/A in sk)
			h += "<a class='tcard' href='byond://?src=\ref[src];skillact=\ref[A]'>[html_encode(A.name)]</a>"
		h += "</div></div>"
	return "<html><head>[UI_CSS]</head><body><div class='wrap'>[jointext(h, "")]</div></body></html>"

mob/proc/RenderSkillBrowser()
	if(!client) return
	var/html = BuildSkillHTML()
	if(html == last_skill_html) return
	last_skill_html = html
	src << browse(html, "window=SkillsListWindow.skillbrowser")

// ---- href routing: tab clicks + verb buttons -------------------------------
mob/Topic(href, list/href_list)
	if(href_list["chatReady"]) //the HTML chat page finished loading -> replay the backlog, then go live
		if(!chatUIready) FlushChat()
		return
	if(href_list["statsTab"])
		statsUItab = href_list["statsTab"]
		last_stats_html = "" //force re-render on tab change
		RefreshStatsUI()
		return
	if(href_list["runverb"])
		var/cmd = replacetext(href_list["runverb"], " ", "-") //BYOND's command form hyphenates spaces ("Learn Skill" -> "Learn-Skill"); passing the spaced name made it read word 2 as a bad arg
		winset(src, null, "command=[cmd]")
		return
	if(href_list["itemverb"]) //run one of the item's OWN verbs (Equip/Upgrade/Icon/...)
		var/obj/O = locate(href_list["iref"])
		var/vn = href_list["itemverb"]
		if(O && (O in contents) && hascall(O, vn))
			call(O, vn)() //invoke the verb directly on the item (set src in usr is bypassed; usr=player)
			last_stats_html = "" //the item may have changed (equipped/upgraded) -> re-render
			RefreshStatsUI()
		return
	if(href_list["itemact"]) //generic Drop / Destroy fallbacks
		var/obj/O = locate(href_list["iref"])
		if(O && (O in contents))
			switch(href_list["itemact"])
				if("equip") //the item's own Equip verb toggles equip/unequip (Equipment->Wear, Weights, etc.)
					if(hascall(O, "Equip")) call(O, "Equip")()
				if("drop")
					if(O.equipped) src << "Unequip [O] first."
					else if(hascall(O, "Drop")) call(O, "Drop")() //some items (Trees/Zenni) have special Drop logic
					else
						O.loc = loc
						step(O, dir)
						view(src) << "<font size=1 color=teal>[src] drops [O].</font>"
				if("destroy")
					if(O.equipped) src << "Unequip [O] first."
					else
						view(src) << "<font size=1 color=teal>[src] destroys [O].</font>"
						del(O)
			last_stats_html = "" //inventory changed -> re-render the Items tab
			RefreshStatsUI()
		return
	if(href_list["treeget"]) //clicked a skill-tree card -> mirror DummyTree.Click() per the current GetTreeMode
		var/datum/skill/tree/A = locate(href_list["treeget"])
		if(istype(A) && !IsLearning)
			IsLearning = 1
			if(GetTreeMode == 1)
				if(A in allowed_trees) getTree(A)
			else if(GetTreeMode == 2)
				if(A in possessed_trees) A.attemptrefund(0)
			else
				if(A in possessed_trees)
					CurrentTree = A
					SkillWindowOpen()
			updateWindow = 0
			IsLearning = 0
			last_tree_html = "" //the card set may have changed -> force a re-render
			RenderTreeBrowser()
		return
	if(href_list["skillact"]) //clicked a skill card in the SkillsListWindow -> mirror DummySkill.Click()
		var/datum/skill/A = locate(href_list["skillact"])
		if(istype(A) && CurrentTree && !IsLearning)
			IsLearning = 1
			if(LearnSkillMode)
				for(var/datum/skill/S in CurrentTree.investedskills)
					if(S == A && S.can_forget) { CurrentTree.attemptforget(S); break }
			else
				for(var/datum/skill/S in CurrentTree.constituentskills)
					if(S == A) { CurrentTree.attemptlearn(S); break }
			updateWindow = 0
			IsLearning = 0
			last_skill_html = ""
			RenderSkillBrowser()
		return
	..()
