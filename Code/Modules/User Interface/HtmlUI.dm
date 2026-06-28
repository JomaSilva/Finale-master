// =============================================================================
// HTML / CSS UI FRAMEWORK  — modern browser-rendered panels (DU-style).
//   The character panel rendered in a BYOND browser window, dark themed, with
//   four tabs (Stats / Items / Other / Skills) read from the real character.
//   Reusable theme (UI_CSS) + helpers (ui_sec/ui_row/ui_qual) so the rest of
//   the game's windows can follow the same pattern.
//   Auto-opens on login (onceStats -> OpenStatsUI); toggle with the
//   "Stats Panel (HTML)" verb. Re-renders only when a value changed (cached
//   last_stats_html) so it doesn't flicker / reset scroll while idle.
// =============================================================================

// The <meta IE=edge> is ESSENTIAL: without it BYOND's embedded browser falls
// back to an ancient engine and flexbox/modern CSS breaks.
var/UI_CSS = {"
<meta http-equiv='X-UA-Compatible' content='IE=edge'>
<style>
 *{box-sizing:border-box}
 html,body{margin:0;padding:0}
 body{background:#0f1115;color:#d6d9df;font-family:'Segoe UI',Tahoma,sans-serif;font-size:13px}
 .wrap{padding:10px 12px}
 .tabs{display:flex;gap:6px;margin-bottom:10px;flex-wrap:wrap}
 .tab{background:#1b1e25;color:#9aa0ab;padding:6px 13px;border-radius:7px;text-decoration:none;font-weight:bold;font-size:12px}
 .tab.on{background:#2b303a;color:#ffffff}
 .sec{color:#6f7681;font-size:10px;font-weight:bold;letter-spacing:1.5px;margin:15px 0 5px}
 .row{display:flex;justify-content:space-between;align-items:baseline;padding:5px 2px;border-bottom:1px solid #1b1e25}
 .k{color:#c4c8d0}
 .v{font-weight:bold;color:#f2f4f8;text-align:right;white-space:nowrap}
 .hi{color:#56c271} .lo{color:#cf8a55} .av{color:#c9b85a}
 .mut{color:#7a8089;font-weight:normal}
</style>
"}

mob/var/tmp
	statsUIopen = 0
	statsUItab = "Stats"
	last_stats_html = ""

// ---- HTML helpers (reusable across panels) ---------------------------------
proc/ui_sec(title)
	return "<div class='sec'>[title]</div>"
proc/ui_row(label, value, vclass)
	return "<div class='row'><span class='k'>[label]</span><span class='v [vclass]'>[value]</span></div>"

// High / Average / Low qualifier for a stat compared to the character's own mean
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

// ---- page assembly: tab bar + the active tab -------------------------------
mob/proc/BuildStatsHTML()
	var/list/h = list()
	h += "<div class='tabs'>"
	for(var/t in list("Stats","Items","Other","Skills"))
		h += "<a class='tab[statsUItab==t ? " on" : ""]' href='byond://?src=\ref[src];statsTab=[t]'>[t]</a>"
	h += "</div>"
	switch(statsUItab)
		if("Items")  h += ui_tab_items()
		if("Other")  h += ui_tab_other()
		if("Skills") h += ui_tab_skills()
		else         h += ui_tab_stats()
	return "<html><head>[UI_CSS]</head><body><div class='wrap'>[jointext(h, "")]</div></body></html>"

// ---- STATS tab -------------------------------------------------------------
mob/proc/ui_tab_stats()
	var/list/h = list()
	h += ui_sec("POWER")
	if(scouteron)
		h += ui_row("BATTLE POWER", "[FullNum(round(expressedBP))] <span class='mut'>(base [FullNum(round(BP))])</span>", "")
	else
		h += ui_row("BATTLE POWER", "??? <span class='mut'>(no scouter)</span>", "")
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

// ---- ITEMS tab (inventory + equipped) --------------------------------------
mob/proc/ui_tab_items()
	var/list/h = list()
	h += ui_sec("INVENTORY")
	h += ui_row("Zenni", "[FullNum(zenni)]", "")
	h += ui_row("Space", "[inven_min] / [inven_max]", "")
	h += ui_sec("CARRIED")
	var/found = 0
	for(var/obj/o in src)
		if(!(istype(o, /obj/items) || istype(o, /obj/Trees) || istype(o, /obj/Artifacts) || istype(o, /obj/DB) || istype(o, /obj/Spacepod) || istype(o, /obj/Boat) || istype(o, /obj/bodyparts)))
			continue
		found++
		var/tag = ""
		if(istype(o, /obj/items/Equipment))
			var/obj/items/Equipment/e = o
			if(e.equipped) tag = "<span class='hi'>equipped</span>"
		h += ui_row(html_encode(o.name), tag, "mut")
	if(!found)
		h += "<div class='row'><span class='mut'>Your pockets are empty.</span></div>"
	return jointext(h, "")

// ---- OTHER tab (body / forms / world) --------------------------------------
mob/proc/ui_tab_other()
	var/list/h = list()
	h += ui_sec("BODY")
	for(var/datum/Body/b in body)
		if(b.status == "Missing") continue
		var/pct = round((b.health / max(b.maxhealth,1)) * 100)
		var/cls = pct >= 66 ? "hi" : (pct <= 33 ? "lo" : "av")
		h += ui_row(html_encode(b.name), "[round(b.health)]/[round(b.maxhealth)] <span class='mut'>([pct]%)</span>", cls)

	h += ui_sec("FORMS &amp; MULTIPLIERS")
	h += ui_row("Total BP Mult", "[round(expressedBP / max(BP,1), 0.01)]x", "")
	if(round(ssjBuff, 0.01) != 1)   h += ui_row("Form (SSJ ladder)", "[round(ssjBuff, 0.01)]x", "")
	if(round(transBuff, 0.01) != 1) h += ui_row("Transformation", "[round(transBuff, 0.01)]x", "")
	if(round(formsBuff, 0.01) != 1) h += ui_row("Forms", "[round(formsBuff, 0.01)]x", "")
	if(godki && godki.usage)        h += ui_row("God Ki", "[round((god_form_mult() || godki.godki_mult), 0.01)]x", "")
	if(round(angerBuff, 0.01) != 1) h += ui_row("Anger", "[round(angerBuff, 0.01)]x", "")
	if(KaiokenMastery > 1)          h += ui_row("Kaio-Ken Mastery", "x[round(KaiokenMastery, 0.1)]", "")

	h += ui_sec("WORLD")
	h += ui_row("Planet", html_encode("[Planet]"), "")
	h += ui_row("Location", "[x], [y], [z]", "mut")
	h += ui_row("Gravity", "[Planetgrav + gravmult]x", "")
	h += ui_row("Lag-O-Meter", "[world.cpu]%", "")
	return jointext(h, "")

// ---- SKILLS tab (ki / melee / weapon levels) -------------------------------
mob/proc/ui_tab_skills()
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

// ---- open / refresh / close ------------------------------------------------
mob/verb/Stats_Panel_HTML()
	set name = "Stats Panel (HTML)"
	set category = "Other"
	if(statsUIopen)
		statsUIopen = 0
		winshow(src, "DUStats", 0)
	else
		OpenStatsUI()

mob/proc/OpenStatsUI()
	if(!client) return
	var/wasopen = statsUIopen
	statsUIopen = 1
	last_stats_html = BuildStatsHTML()
	src << browse(last_stats_html, "window=DUStats;size=340x660;can-resize=1;title=Character") //open DIRECTLY so the first open is never blocked by the close-guard
	if(!wasopen) spawn StatsUILoop()

mob/proc/StatsUILoop()
	set waitfor = 0
	set background = 1
	while(src && client && statsUIopen)
		sleep(10) //~1s (the initial render already happened in OpenStatsUI)
		RefreshStatsUI()

mob/proc/RefreshStatsUI()
	if(!client || !statsUIopen) return
	if(winget(src, "DUStats", "is-visible") == "false") //player closed it with the X -> stop refreshing (don't re-open it)
		statsUIopen = 0
		return
	var/html = BuildStatsHTML()
	if(html == last_stats_html) return //nothing changed -> skip the re-render (no flicker / no scroll reset)
	last_stats_html = html
	src << browse(html, "window=DUStats;size=340x660;can-resize=1;title=Character")

// ---- href routing: clicking a tab in the page comes back here --------------
mob/Topic(href, list/href_list)
	if(href_list["statsTab"])
		statsUItab = href_list["statsTab"]
		last_stats_html = "" //force a re-render on the tab change
		RefreshStatsUI()
		return
	..()
