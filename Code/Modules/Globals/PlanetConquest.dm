// ============================================================================
// CONQUISTA DE PLANETAS -- dominio territorial por players, base do futuro
// sistema de quests dos ranks (Rei de Vegeta, Guardiao da Terra, Korin...).
//
//  COMO CONQUISTA (bandeira + invasao):
//   - O verb "Conquistar Planeta" finca a Bandeira de Conquista onde o player
//     esta. Isso dispara ONDAS de defensores escalando com o BP expresso do
//     invasor + um LIDER na onda final. Vencer todas as ondas com a bandeira
//     de pe = planeta dominado.
//   - Pre-feitos habitados (Terra/Vegeta/Namek): defensores sao CIDADAOS da
//     raca do planeta (pipeline real do PlanetPopulation). Procedurais:
//     guarnicao da fauna do bioma (mais fraca).
//   - Defensor NOCAUTEADO conta como vencido -- da pra conquistar SEM MATAR.
//
//  ALINHAMENTO (depende da reputacao):
//   - MATAR defensor nativo derruba reputacao com o povo + karma (vilania).
//     KO nao custa nada (conquista de "maos limpas").
//   - HEROI do povo (rep >= REP_HERO) reivindica o planeta PACIFICAMENTE,
//     sem luta, se ele nao tiver dono.
//   - Tomar o planeta de um dono que o povo ODEIA (rep <= REP_VILLAIN) =
//     LIBERTACAO: o povo recompensa o novo soberano.
//
//  POSSE: tributo em zenni por hora real (coleta na bandeira), spawn no
//  dominio (pre-feito seta spawnPlanet; procedural via gancho no Locate) e
//  fama (anuncio mundial + aba Ranks + Nav).
//
//  CONTESTACAO: invadir planeta dominado avisa o dono (na hora ou no login)
//  e a guarnicao luta POR ELE (sem custo de rep para o desafiante). Qualquer
//  um MENOS o invasor pode ARRANCAR a bandeira de invasao (canal de
//  CONQ_RIP_SECS s interrompido por dano/movimento) e frustrar a conquista.
//
//  Persistencia: savefile "Conquest" (flat, sem datums -- some no wipe).
//  Bandeiras sao re-fincadas no boot (pre-feitos) e na regeneracao da
//  superficie procedural (conq_on_surface_ready).
// ============================================================================

// ============================== CONFIG ======================================
#define CONQ_MIN_BP_POP   5000000 // BP expresso minimo pra invadir planeta HABITADO
#define CONQ_MIN_BP_PROC   250000 // BP expresso minimo pra invadir planeta procedural
#define CONQ_MAX_DOMAINS        3 // dominios simultaneos por player
#define CONQ_PLAYER_CD      18000 // ticks (30 min) entre tentativas de conquista do MESMO player
#define CONQ_TIMEOUT         6000 // ticks (10 min) pra invasao inteira -- estourou, os defensores venceram
#define CONQ_WAVE_BREATHER     80 // ticks (8s) de respiro entre ondas
#define CONQ_RIP_SECS           8 // segundos de canal pra ARRANCAR uma bandeira de invasao
#define CONQ_LEADER_FACTOR   0.95 // BP do LIDER (pre-feito) = isto x BP expresso do invasor
#define CONQ_CHAMP_FACTOR    0.80 // BP do CAMPEAO da fauna (procedural)
#define CONQ_DEF_BP_FLOOR    5000 // piso de BP de qualquer defensor
#define CONQ_TRIB_POP        1000 // zenni por hora real de dominio HABITADO
#define CONQ_TRIB_PROC        250 // zenni por hora real de dominio procedural
#define CONQ_TRIB_CAP_H        24 // teto de acumulo do tributo (horas reais)
#define CONQ_REP_KILL_DEF      -6 // rep por MATAR um defensor nativo (KO nao custa)
#define CONQ_REP_KILL_LEAD    -15 // rep por MATAR o lider nativo
#define CONQ_REP_CLAIM         10 // rep ganha na reivindicacao pacifica (heroi)
#define CONQ_REP_LIBERATE      40 // rep ganha ao tomar o planeta de um TIRANO (rep dele <= REP_VILLAIN)
#define CONQ_REP_DEFEND        15 // rep ganha por ARRANCAR a bandeira de um invasor (planeta sem dono)

// ondas: list(qtd, fator de BP) -- o lider/campeao entra JUNTO na ultima onda
var/list/conq_waves_pop = list(list(4, 0.30), list(4, 0.50), list(2, 0.45))
var/list/conq_waves_proc = list(list(3, 0.30), list(1, 0.50))
// ============================ FIM DO CONFIG =================================

var/list/conq_data = list()      // "Planeta" -> list("sig","name","ckey","since","collect","fx","fy")
var/list/conq_notify = list()    // "[signature]" -> lista de recados offline (perdeu/defendeu dominio)
var/list/conq_invasions = list() // "Planeta" -> /datum/conq_invasion ATIVA
var/conq_inited = 0

mob/var/conq_spawn = ""          // dominio PROCEDURAL escolhido como spawn (persiste no save do char)
mob/var/tmp/conq_busy = 0        // invasao em andamento por este player
mob/var/tmp/conq_next_try = 0    // cooldown pessoal entre tentativas
mob/var/tmp/conq_ripping = 0     // canalizando o arranque de uma bandeira

// ---------------------------------------------------------------------------
// API basica (outros sistemas -- quests dos ranks -- consultam por aqui)
// ---------------------------------------------------------------------------
proc/conq_premade(pl)
	return (pl == "Earth" || pl == "Vegeta" || pl == "Namek")

proc/conq_owner_sig(pl) //signature do dono, ou null
	if(!pl) return null
	var/list/R = conq_data[pl]
	return islist(R) ? R["sig"] : null

proc/conq_owner_name(pl)
	if(!pl) return null
	var/list/R = conq_data[pl]
	return islist(R) ? R["name"] : null

proc/conq_owns_any(sig) //este signature domina ALGUM planeta? (gate de compra da criacao de esferas do Cla do Dragao)
	if(!sig) return 0
	for(var/pl in conq_data)
		var/list/R = conq_data[pl]
		if(islist(R) && R["sig"] == sig) return 1
	return 0

proc/conq_owner_tag(pl) //sufixo pro Nav/listagens
	if(!pl) return ""
	var/list/R = conq_data[pl]
	if(!islist(R)) return ""
	return " &middot; <span style='color:#e8b64c'>Dominio de [html_encode(R["name"])]</span>"

proc/conq_count_owned(sig)
	var/n = 0
	for(var/pl in conq_data)
		var/list/R = conq_data[pl]
		if(islist(R) && R["sig"] == sig) n++
	return n

//o planeta deixou de existir? (pre-feito explodido / procedural destruido ou de outra galaxia)
proc/conq_planet_gone(pl)
	if(!pl) return 1
	if(conq_premade(pl)) return bev_planet_destroyed(pl)
	var/datum/pspace_planet/D = pspace_planets[pl]
	if(!D) return 1
	if(pl in PlanetDisableList) return 1
	if(D.pobj && D.pobj.isDestroyed) return 1
	return 0

proc/conq_tribute_rate(pl)
	return conq_premade(pl) ? CONQ_TRIB_POP : CONQ_TRIB_PROC

proc/conq_tribute_pending(pl)
	var/list/R = conq_data[pl]
	if(!islist(R)) return 0
	var/hours = (world.realtime - R["collect"]) / 36000
	if(hours < 0) hours = 0
	return round(min(hours, CONQ_TRIB_CAP_H) * conq_tribute_rate(pl))

proc/conq_pname(pl)
	return (pl == "Earth") ? "Terra" : pl

// ---------------------------------------------------------------------------
// Persistencia (savefile "Conquest" -- so listas flat, NUNCA datums)
// ---------------------------------------------------------------------------
proc/conq_save()
	var/savefile/S = new("Conquest")
	S["domains"] << conq_data
	S["notify"] << conq_notify

proc/conq_load()
	if(!fexists("Conquest")) return
	var/savefile/S = new("Conquest")
	var/list/d
	var/list/n
	S["domains"] >> d
	S["notify"] >> n
	if(islist(d)) conq_data = d
	if(islist(n)) conq_notify = n

proc/Conq_Init()
	set waitfor = 0
	if(conq_inited) return
	conq_inited = 1
	while(worldloading) sleep(1)
	pspace_boot() //garante o registro dos planetas procedurais antes de validar
	conq_load()
	conq_validate_all()
	conq_place_premade_flags()
	spawn conq_watch_loop()

//apaga as bandeiras de um planeta (coleta ANTES de deletar: del mexe no obj_list em plena iteracao)
proc/conq_drop_flags(pl, keep_invasion)
	var/list/doomed = list()
	for(var/obj/Conquest_Flag/F in obj_list)
		if(F && F.loc && F.planet == pl && !(keep_invasion && F.invasion_flag)) doomed += F
	for(var/obj/Conquest_Flag/F in doomed) del F

//varre os dominios: planeta destruido/sumido = dominio perdido (avisa o ex-dono)
proc/conq_validate_all()
	var/list/rm = list()
	for(var/pl in conq_data)
		if(conq_planet_gone(pl)) rm += pl
	for(var/pl in rm)
		var/list/R = conq_data[pl]
		conq_data -= pl
		conq_drop_flags(pl, 0)
		if(islist(R)) conq_notify_owner(R["sig"], "<font color=red>Seu dominio [conq_pname(pl)] foi DESTRUIDO. O territorio se perdeu.</font>")
	if(rm.len) conq_save()

proc/conq_watch_loop()
	set waitfor = 0
	set background = 1
	while(1)
		sleep(600)
		conq_validate_all()
		//WATCHDOG: invasao cuja rotina morreu num runtime error nao pode trancar o planeta pra sempre
		var/list/stale = list()
		for(var/pl in conq_invasions)
			var/datum/conq_invasion/I = conq_invasions[pl]
			if(!I || I.done || (I.deadline && world.time > I.deadline + 600)) stale += pl
		for(var/pl in stale)
			var/datum/conq_invasion/I = conq_invasions[pl]
			if(I && !I.done) conq_invasion_end(I, 0, "a invasao se dissipou")
			else conq_invasions -= pl

//recado pro dono: na hora se online, guardado pro login se nao
proc/conq_notify_owner(sig, msg)
	if(isnull(sig) || !msg) return
	for(var/mob/P in player_list)
		if(P && P.client && P.signature == sig)
			to_chat(P, msg)
			return
	var/list/q = conq_notify["[sig]"]
	if(!islist(q)) q = list()
	q += msg
	conq_notify["[sig]"] = q
	conq_save()

mob/proc/conq_login_check() //chamado na cadeia do Login
	var/list/q = conq_notify["[signature]"]
	if(islist(q) && q.len)
		for(var/m in q) to_chat(src, m)
		conq_notify -= "[signature]"
		conq_save()
	if(conq_spawn) //dominio-spawn ainda e seu?
		var/list/R = conq_data[conq_spawn]
		if(!islist(R) || R["sig"] != signature) conq_spawn = ""

// ---------------------------------------------------------------------------
// A BANDEIRA (claim permanente OU bandeira de invasao em andamento)
// ---------------------------------------------------------------------------
obj/Conquest_Flag
	name = "Bandeira de Conquista"
	icon = 'ConquestFlag.dmi'
	density = 0
	var/planet = ""
	var/owner_sig = null
	var/owner_name = ""
	var/invasion_flag = 0 // 1 = invasao em andamento (arrancavel); 0 = claim de dominio

	Click()
		if(!usr || !usr.client || usr.dead || usr.KO) return
		if(get_dist(usr, src) > 1)
			to_chat(usr, "Chegue mais perto da bandeira.")
			return
		if(invasion_flag)
			var/datum/conq_invasion/I = conq_invasions[planet]
			if(I && I.invader == usr)
				to_chat(usr, "<font color=#e8b64c>Sua invasao de [conq_pname(planet)] esta em andamento -- defenda a bandeira!</font>")
				return
			rip_attempt(usr)
			return
		var/list/R = conq_data[planet]
		if(!islist(R))
			to_chat(usr, "Esta bandeira nao reivindica mais nada.")
			return
		if(R["sig"] != usr.signature)
			to_chat(usr, "<font color=#e8b64c>Dominio de <b>[R["name"]]</b> desde [time2text(R["since"], "DD/MM/YYYY")]. Use <b>Conquistar Planeta</b> para desafiar a posse.</font>")
			return
		var/opt = input(usr, "Seu dominio de [conq_pname(planet)]. Tributo acumulado: [conq_tribute_pending(planet)] zenni.", "Dominio") as null|anything in list("Coletar tributo", "Definir como meu spawn", "Abandonar dominio")
		if(!opt || !usr || usr.dead || get_dist(usr, src) > 1) return
		switch(opt)
			if("Coletar tributo")
				var/amt = conq_tribute_pending(planet)
				if(amt < 1)
					to_chat(usr, "O tributo ainda esta se acumulando ([conq_tribute_rate(planet)] zenni/hora real).")
					return
				usr.zenni += amt
				R["collect"] = world.realtime
				conq_save()
				to_chat(usr, "<font color=yellow>Voce coleta <b>[amt]</b> zenni de tributo de [conq_pname(planet)].</font>")
			if("Definir como meu spawn")
				if(conq_premade(planet))
					usr.spawnPlanet = planet
					usr.conq_spawn = ""
					to_chat(usr, "<font color=#88ccff>Seu planeta natal agora e [conq_pname(planet)] -- voce renasce aqui.</font>")
				else
					usr.conq_spawn = planet
					to_chat(usr, "<font color=#88ccff>Voce renascera em [planet] enquanto for o soberano (se a superficie estiver descarregada, o spawn cai no padrao).</font>")
			if("Abandonar dominio")
				switch(alert(usr, "Abandonar o dominio de [conq_pname(planet)]? A posse se perde na hora.", "Abandonar", "Sim", "Nao"))
					if("Nao") return
				var/pl = planet
				conq_data -= pl
				conq_save()
				if(usr.conq_spawn == pl) usr.conq_spawn = ""
				to_chat(world, "<font color=#e8b64c>[usr.name] abandonou o dominio de [conq_pname(pl)].</font>", "announce")
				del src

	//arrancar a bandeira de INVASAO: canal, interrompido por dano ou movimento
	proc/rip_attempt(mob/M)
		if(!M || !M.client || M.dead || M.KO || M.conq_ripping) return
		if(!invasion_flag || !loc) return
		M.conq_ripping = 1
		view(src) << output("<font color=#e8b64c><b>[M] agarra a bandeira de invasao e comeca a arranca-la do chao!</b></font>", "Chatpane.Chat")
		chatcast(view(src), "<font color=#e8b64c><b>[M] agarra a bandeira de invasao e comeca a arranca-la do chao!</b></font>", "combat")
		var/turf/T0 = M.loc
		var/tag0 = M.combatTagExpire
		var/ok = 1
		for(var/i = 1 to CONQ_RIP_SECS)
			sleep(10)
			if(!M || M.dead || M.KO || !src || !loc || !invasion_flag)
				ok = 0
				break
			if(M.loc != T0)
				to_chat(M, "<font color=red>Voce se moveu -- a bandeira continua fincada.</font>")
				ok = 0
				break
			if(M.combatTagExpire != tag0)
				to_chat(M, "<font color=red>O combate interrompe o arranque!</font>")
				ok = 0
				break
			if(i < CONQ_RIP_SECS && i % 3 == 0) to_chat(M, "<font color=#e8b64c>A bandeira cede... ([i]/[CONQ_RIP_SECS]s)</font>")
		if(M) M.conq_ripping = 0
		if(!ok) return
		var/datum/conq_invasion/I = conq_invasions[planet]
		if(!I || I.done) return
		I.ripped = 1
		//recompensa: defendeu um povo sem dono (o povo agradece)
		if(I.premade && I.native && M && M.client)
			planet_rep_add(I.planet, M, CONQ_REP_DEFEND, "defendeu-a-invasao")
		view(src) << output("<font color=yellow><b>[M ? M.name : "Alguem"] ARRANCA a bandeira de invasao! A conquista fracassa!</b></font>", "Chatpane.Chat")
		chatcast(view(src), "<font color=yellow><b>[M ? M.name : "Alguem"] ARRANCA a bandeira de invasao!</b></font>", "combat")

//cor estavel por dono (o banner e branco de proposito -- o tint marca o dono)
proc/conq_flag_color(sig)
	var/list/pal = list("#d84040", "#3f7fd8", "#3fae5c", "#c8b830", "#9a5fd0", "#d87f2f")
	var/t = "[sig]"
	var/n = 0
	for(var/i = 1 to length(t)) n += text2ascii(t, i)
	return pal[(n % pal.len) + 1]

//re-finca a bandeira de um dominio num z carregado (boot pre-feito / regen procedural)
proc/conq_place_flag(pl, zz)
	if(!pl || !zz) return
	var/list/R = conq_data[pl]
	if(!islist(R)) return
	for(var/obj/Conquest_Flag/F in obj_list)
		if(F && F.planet == pl && !F.invasion_flag && F.loc) return //ja esta de pe
	var/turf/T = locate(R["fx"], R["fy"], zz)
	if(!T || T.density)
		if(conq_premade(pl)) T = planet_spawn_turf(pl) //fallback do pre-feito (SpawnPoints); procedural cai no ponto de pouso
		else
			var/datum/pspace_planet/D = pspace_planets[pl]
			T = D ? locate(max(2, D.land_x), max(2, D.land_y), zz) : null
	if(!T) return
	var/obj/Conquest_Flag/F = new(T)
	F.planet = pl
	F.owner_sig = R["sig"]
	F.owner_name = R["name"]
	F.name = "Dominio de [R["name"]]"
	F.color = conq_flag_color(R["sig"])

proc/conq_place_premade_flags()
	for(var/pl in conq_data)
		if(!conq_premade(pl)) continue
		conq_place_flag(pl, (pl == "Earth") ? 1 : (pl == "Namek") ? 2 : 3)

//gancho no fim da geracao de superficie procedural (ProceduralSpace.dm)
proc/conq_on_surface_ready(datum/pspace_planet/D)
	if(!D || !D.surface_z) return
	if(!conq_data[D.name]) return
	conq_place_flag(D.name, D.surface_z)

// ---------------------------------------------------------------------------
// O VERB: Conquistar Planeta
// ---------------------------------------------------------------------------
mob/verb/Conquistar_Planeta()
	set name = "Conquistar Planeta"
	set category = "Other"
	if(!usr.client || !usr.signature || usr.dead || usr.KO) return
	if(usr.conq_busy)
		to_chat(usr, "Voce ja esta no meio de uma conquista.")
		return
	var/area/A = usr.GetArea()
	var/pl = A ? A.Planet : null
	if(!pl) pl = usr.Planet
	var/premade = conq_premade(pl)
	var/datum/pspace_planet/D = premade ? null : (pl ? pspace_planets[pl] : null)
	if(!premade && !D)
		to_chat(usr, "Este lugar nao pode ser conquistado -- pise na superficie de um planeta.")
		return
	if(premade && !(istype(A) && A.Planet == pl && A.PlayersCanSpawn))
		to_chat(usr, "Va para a area aberta do planeta para fincar a bandeira.")
		return
	if(!premade && !istype(A, /area/pspace_planet))
		to_chat(usr, "Va para a superficie do planeta para fincar a bandeira.")
		return
	if(conq_planet_gone(pl))
		to_chat(usr, "Nao ha nada para dominar num planeta morto.")
		return
	var/list/R = conq_data[pl]
	if(islist(R) && R["sig"] == usr.signature)
		to_chat(usr, "[conq_pname(pl)] ja e seu dominio.")
		return
	if(conq_invasions[pl])
		to_chat(usr, "Ja ha uma invasao em andamento em [conq_pname(pl)].")
		return
	if(conq_count_owned(usr.signature) >= CONQ_MAX_DOMAINS)
		to_chat(usr, "Voce ja rege [CONQ_MAX_DOMAINS] dominios -- abandone um para conquistar outro.")
		return
	if(world.time < usr.conq_next_try)
		to_chat(usr, "Suas forcas ainda se reorganizam da ultima campanha ([round((usr.conq_next_try - world.time) / 600)] min).")
		return
	var/minbp = premade ? CONQ_MIN_BP_POP : CONQ_MIN_BP_PROC
	if(usr.expressedBP < minbp)
		to_chat(usr, "Voce e fraco demais para subjugar este mundo (poder minimo: [num2text(minbp, 12)]).")
		return
	//REIVINDICACAO PACIFICA: heroi do povo + planeta sem dono = o povo aceita
	if(premade && !islist(R) && planet_rep_get(pl, usr) >= REP_HERO)
		switch(alert(usr, "O povo de [conq_pname(pl)] te considera um HEROI e aceitaria seu dominio SEM DERRAMAR SANGUE. Reivindicar pacificamente?", "Conquista", "Reivindicar em paz", "Invadir a forca", "Cancelar"))
			if("Reivindicar em paz")
				conq_claim_peaceful(usr, pl)
				return
			if("Cancelar") return
	else
		var/aviso = premade ? "As forcas de defesa de [conq_pname(pl)] vao responder em ondas. MATAR defensores mancha sua reputacao com o povo (nocautear nao)." : "A fauna selvagem de [pl] vai defender o territorio em ondas."
		if(islist(R)) aviso = "O planeta pertence a <b>[R["name"]]</b> -- a guarnicao lutara por ele e ele sera avisado. [premade ? "Sem custo de reputacao contra a guarnicao de um ocupante." : ""]"
		switch(alert(usr, "Invadir [conq_pname(pl)]? [aviso] Fuga, morte ou a bandeira arrancada = fracasso.", "Conquista", "Invadir", "Cancelar"))
			if("Cancelar") return
	if(!usr || usr.dead || usr.KO || usr.conq_busy || conq_invasions[pl]) return //re-checa apos o dialogo
	conq_invasion_start(usr, pl, premade, D)

proc/conq_claim_peaceful(mob/M, pl)
	if(!M || !M.client || conq_data[pl] || conq_invasions[pl]) return
	var/obj/Conquest_Flag/F = new(M.loc)
	F.planet = pl
	F.owner_sig = M.signature
	F.owner_name = M.name
	F.name = "Dominio de [M.name]"
	F.color = conq_flag_color(M.signature)
	conq_data[pl] = list("sig" = M.signature, "name" = M.name, "ckey" = ckey(M.key), "since" = world.realtime, "collect" = world.realtime, "fx" = F.x, "fy" = F.y)
	conq_save()
	planet_rep_add(pl, M, CONQ_REP_CLAIM, "reivindicacao-pacifica")
	bev_announce("O povo de [conq_pname(pl)] aclama [M.name] como protetor e soberano do planeta!")
	to_chat(M, "<font color=yellow>Clique na sua bandeira para coletar tributo, definir spawn ou abandonar o dominio.</font>")
	WriteToLog("rplog", "[M.name] reivindicou [pl] pacificamente   ([time2text(world.realtime, "Day DD hh:mm")])")

// ---------------------------------------------------------------------------
// A INVASAO
// ---------------------------------------------------------------------------
datum/conq_invasion
	var
		planet = ""
		premade = 0
		native = 1     // 1 = defesa do proprio povo/fauna; 0 = guarnicao do dono atual
		pz = 0         // z do campo de batalha (sair dele = fuga)
		deadline = 0
		base_bp = 0    // piso do BP de referencia (snapshot do inicio; anti-cheese de reverter)
		kills = 0      // defensores NATIVOS mortos (so registro/log)
		ripped = 0
		done = 0
		old_owner_sig = null
		old_owner_name = ""
		old_owner_ckey = ""
		tmp/mob/invader = null
		tmp/obj/Conquest_Flag/flag = null
		tmp/list/wave_mobs = list()

	proc/fail_reason()
		if(ripped) return "a bandeira foi arrancada"
		if(!invader || !invader.client) return "o invasor desapareceu"
		if(invader.dead) return "o invasor foi morto"
		if(invader.z != pz) return "o invasor fugiu do planeta"
		if(!flag || !flag.loc) return "a bandeira caiu"
		if(world.time > deadline) return "os defensores resistiram ate o fim"
		return null

proc/conq_invasion_start(mob/M, pl, premade, datum/pspace_planet/D)
	var/datum/conq_invasion/I = new
	I.planet = pl
	I.premade = premade
	I.invader = M
	var/list/R = conq_data[pl]
	if(islist(R))
		I.native = 0
		I.old_owner_sig = R["sig"]
		I.old_owner_name = R["name"]
		I.old_owner_ckey = R["ckey"]
	conq_invasions[pl] = I
	M.conq_busy = 1
	M.conq_next_try = world.time + CONQ_PLAYER_CD
	spawn conq_invasion_run(I)

proc/conq_invasion_run(datum/conq_invasion/I)
	set waitfor = 0
	var/mob/M = I.invader
	if(!M || !M.loc)
		conq_invasion_end(I, 0, "sem invasor")
		return
	var/obj/Conquest_Flag/F = new(M.loc)
	F.planet = I.planet
	F.invasion_flag = 1
	F.owner_sig = M.signature
	F.owner_name = M.name
	F.name = "bandeira de invasao de [M.name]"
	F.color = conq_flag_color(M.signature)
	I.flag = F
	I.pz = M.z
	I.deadline = world.time + CONQ_TIMEOUT
	I.base_bp = max(M.expressedBP, 1)
	var/pname = conq_pname(I.planet)
	if(I.premade)
		bev_announce("[M.name] fincou a bandeira de INVASAO em [pname]! As forcas de defesa respondem!")
	else
		to_chat(world, "<font color=#e8b64c><b>[M.name] fincou a bandeira de conquista em [pname]! A fauna selvagem se ergue em defesa do territorio!</b></font>", "announce")
	if(!isnull(I.old_owner_sig))
		conq_notify_owner(I.old_owner_sig, "<font color=red><b>Seu dominio [pname] esta sendo INVADIDO por [M.name]! Arranque a bandeira dele ou reze pela guarnicao.</b></font>")
	WriteToLog("rplog", "[M.name] iniciou a invasao de [I.planet]   ([time2text(world.realtime, "Day DD hh:mm")])")
	sleep(30) //tensao antes da primeira onda
	var/list/waves = I.premade ? conq_waves_pop : conq_waves_proc
	var/datum/pspace_planet/D = I.premade ? null : pspace_planets[I.planet]
	for(var/w = 1 to waves.len)
		var/why = I.fail_reason()
		if(why)
			conq_invasion_end(I, 0, why)
			return
		var/list/wv = waves[w]
		var/final_wave = (w == waves.len)
		var/bpref = max((M && M.client) ? M.expressedBP : 0, I.base_bp)
		I.wave_mobs = list()
		for(var/i = 1 to wv[1])
			var/turf/T = conq_spawn_turf_near(F)
			var/mob/npc/N = I.premade ? conq_make_defender(I.planet, T, max(round(bpref * wv[2]), CONQ_DEF_BP_FLOOR), 0, I) : conq_make_beast(D, T, max(round(bpref * wv[2]), CONQ_DEF_BP_FLOOR), 0)
			if(N)
				I.wave_mobs += N
				flick('flashtrans.dmi', N)
			sleep(2)
		if(final_wave) //o lider entra junto com a ultima onda
			var/turf/TL = conq_spawn_turf_near(F)
			var/lfac = I.premade ? CONQ_LEADER_FACTOR : CONQ_CHAMP_FACTOR
			var/mob/npc/L = I.premade ? conq_make_defender(I.planet, TL, max(round(bpref * lfac), CONQ_DEF_BP_FLOOR), 1, I) : conq_make_beast(D, TL, max(round(bpref * lfac), CONQ_DEF_BP_FLOOR), 1)
			if(L)
				I.wave_mobs += L
				flick('flashtrans.dmi', L)
		view(F) << output("<font color=#e8b64c><b>Onda [w]/[waves.len] de defensores![final_wave ? " O LIDER da defesa entra na batalha!" : ""]</b></font>", "Chatpane.Chat")
		chatcast(view(F), "<font color=#e8b64c><b>Onda [w]/[waves.len] de defensores![final_wave ? " O LIDER da defesa entra na batalha!" : ""]</b></font>", "combat")
		for(var/mob/npc/N2 in I.wave_mobs) //sic inicial no invasor
			var/mob/npc/N3 = N2
			spawn(rand(1, 5)) if(N3 && N3.loc && !N3.target && !N3.AIRunning && M && !M.dead) N3.foundTarget(M)
		while(1) //espera a onda cair (morto OU nocauteado = vencido)
			sleep(10)
			why = I.fail_reason()
			if(why)
				conq_invasion_end(I, 0, why)
				return
			var/standing = 0
			for(var/mob/npc/W in I.wave_mobs)
				if(!W || !W.loc || W.dead || W.KO) continue
				standing++
				if(!W.target && !W.AIRunning && M && M.client && !M.dead && !M.KO && M.z == I.pz) //defensor ocioso re-engaja
					var/mob/npc/W2 = W
					spawn(1) if(W2 && W2.loc && !W2.target && !W2.AIRunning) W2.foundTarget(M)
			if(!standing) break
		conq_wave_cleanup(I, 0) //nocauteados recuam
		if(!final_wave)
			view(F) << output("<font color=#e8b64c>Os defensores caidos sao arrastados para longe... a proxima onda se aproxima!</font>", "Chatpane.Chat")
			chatcast(view(F), "<font color=#e8b64c>Os defensores caidos sao arrastados para longe... a proxima onda se aproxima!</font>", "combat")
			sleep(CONQ_WAVE_BREATHER)
	conq_invasion_end(I, 1, null)

proc/conq_invasion_end(datum/conq_invasion/I, victory, why)
	if(!I || I.done) return
	I.done = 1
	conq_invasions -= I.planet
	var/mob/M = I.invader
	if(M) M.conq_busy = 0
	conq_wave_cleanup(I, 1)
	var/pname = conq_pname(I.planet)
	if(!victory)
		if(I.flag) del I.flag
		I.flag = null
		to_chat(world, "<font color=#e8b64c>A invasao de [pname][M ? " por [M.name]" : ""] FRACASSOU -- [why].</font>", "announce")
		if(!isnull(I.old_owner_sig)) conq_notify_owner(I.old_owner_sig, "<font color=yellow>Seu dominio [pname] RESISTIU a invasao[M ? " de [M.name]" : ""]!</font>")
		WriteToLog("rplog", "invasao de [I.planet] fracassou ([why])   ([time2text(world.realtime, "Day DD hh:mm")])")
		return
	if(!M || !M.client) //venceu mas sumiu no ultimo instante: ninguem reivindica
		if(I.flag) del I.flag
		I.flag = null
		return
	conq_drop_flags(I.planet, 1) //a bandeira do dono antigo cai (a de invasao vira o novo claim)
	//LIBERTACAO: tomou o planeta de um dono que o povo odiava
	if(I.premade && I.old_owner_ckey)
		var/list/L = planet_rep[I.planet]
		var/oldrep = (islist(L) && (I.old_owner_ckey in L)) ? L[I.old_owner_ckey] : 0
		if(oldrep <= REP_VILLAIN)
			planet_rep_add(I.planet, M, CONQ_REP_LIBERATE, "libertacao")
			to_chat(M, "<font color=yellow><b>O povo de [pname] celebra a queda do tirano [I.old_owner_name]!</b></font>")
	conq_data[I.planet] = list("sig" = M.signature, "name" = M.name, "ckey" = ckey(M.key), "since" = world.realtime, "collect" = world.realtime, "fx" = I.flag ? I.flag.x : M.x, "fy" = I.flag ? I.flag.y : M.y)
	conq_save()
	if(I.flag)
		I.flag.invasion_flag = 0
		I.flag.owner_sig = M.signature
		I.flag.owner_name = M.name
		I.flag.name = "Dominio de [M.name]"
	if(!isnull(I.old_owner_sig)) conq_notify_owner(I.old_owner_sig, "<font color=red><b>Voce PERDEU o dominio de [pname] para [M.name]!</b></font>")
	bev_announce("[pname] CAIU! [M.name] e o novo soberano do planeta!")
	to_chat(M, "<font color=yellow>Clique na sua bandeira para coletar tributo, definir spawn ou abandonar o dominio.</font>")
	WriteToLog("rplog", "[M.name] conquistou [I.planet] ([I.kills] defensores mortos)   ([time2text(world.realtime, "Day DD hh:mm")])")

//turf andavel perto da bandeira (defensores nao nascem em cima do invasor)
proc/conq_spawn_turf_near(obj/Conquest_Flag/F)
	if(!F || !F.loc) return null
	for(var/tries = 1 to 30)
		var/turf/T = locate(F.x + rand(-5, 5), F.y + rand(-5, 5), F.z)
		if(T && !T.density && get_dist(T, F) >= 2) return T
	return F.loc

proc/conq_wave_cleanup(datum/conq_invasion/I, all)
	if(!I || !islist(I.wave_mobs)) return
	for(var/mob/npc/W in I.wave_mobs)
		if(!W || !W.loc) continue
		if(W.dead) continue //mortos ja passaram pelo mobDeath
		if(!all && !W.KO) continue
		conq_despawn_npc(W)
	if(all) I.wave_mobs = list()

proc/conq_despawn_npc(mob/npc/M)
	if(!M) return
	M.hasAI = 0
	M.target = null
	citizen_list -= M
	NPC_list -= M
	M.loc = null //soft-del: loops de IA morrem no proximo tick (&& loc) e o GC recolhe

// ---------------------------------------------------------------------------
// DEFENSORES
// ---------------------------------------------------------------------------
//pre-feito: cidadao-soldado da raca do planeta (pipeline real de raca/classe)
mob/npc/Citizen/Defender
	pop_role = "defender"
	idle_wandering = 0
	var/conq_native = 1  // 0 = guarnicao DO DONO atual (matar nao mexe na rep)
	var/conq_leader = 0
	var/tmp/datum/conq_invasion/conq_inv = null

	mobDeath()
		rep_death_counted = 1 //NUNCA usa o gancho generico de cidadao -- delta proprio abaixo
		if(conq_native)
			var/mob/K = (IsInFight || world.time <= combatTagExpire) ? lastDamager : null
			if(K && K.client && !K.dead)
				planet_rep_add(pop_planet, K, conq_leader ? CONQ_REP_KILL_LEAD : CONQ_REP_KILL_DEF, "matou-defensor")
				K.lose_npc_kill_karma()
		if(conq_inv && !conq_inv.done) conq_inv.kills++
		..()

proc/conq_make_defender(pl, turf/T, bp, leader, datum/conq_invasion/I)
	if(!T) return null
	var/race = (pl == "Vegeta") ? "Saiyan" : (pl == "Namek") ? "Namekian" : "Human"
	var/class = (race == "Saiyan") ? "Elite" : (race == "Namekian") ? "Warrior clan" : "Peak Human"
	var/g = (race == "Namekian") ? "male" : pick("male", "male", "female")
	var/mob/npc/Citizen/Defender/M = init_citizen(T, /mob/npc/Citizen/Defender, race, class, pl, bp, g)
	if(!M) return null
	M.conq_native = I ? I.native : 1
	M.conq_leader = leader
	M.conq_inv = I
	var/rn = npc_random_name(race)
	switch(race)
		if("Saiyan")
			M.name = leader ? "General [rn]" : "Soldado [rn]"
			npc_apply_hair(M, pick(g == "female" ? saiyan_hair_f : saiyan_hair_m), 0, 0, 0)
			npc_wear_armor_icon(M, leader ? 'Armor_Elite.dmi' : pick('Armor 8.dmi', 'Armor Bardock.dmi', 'Nappa Armor.dmi'), 0)
			if(leader) npc_wear_simple(M, /obj/items/clothes/Vegetacape)
		if("Namekian")
			M.name = leader ? "Anciao Guerreiro [rn]" : "Guerreiro [rn]"
			npc_apply_hair(M, "Bald", 0, 0, 0)
			npc_wear_simple(M, /obj/items/clothes/Namekjacket)
			if(prob(50)) npc_wear_simple(M, /obj/items/clothes/NamekianScarf)
		else
			M.name = leader ? "Campeao [rn]" : "Miliciano [rn]"
			npc_apply_hair(M, pick(g == "female" ? human_hair_f : human_hair_m), rand(0, 255), rand(0, 255), rand(0, 255))
			if(g == "female") npc_wear_simple(M, /obj/items/clothes/Gifemale)
			else
				npc_wear_simple(M, /obj/items/clothes/Gi_Top)
				npc_wear_simple(M, /obj/items/clothes/Gi_Bottom)
	return M

//procedural: fera do bioma com BP fixado (o NPCTicker base so ELEVA ate AverageBP -- fixamos depois)
proc/conq_make_beast(datum/pspace_planet/D, turf/T, bp, champ)
	if(!D || !T) return null
	var/etype = pspace_biomes[D.biome][4]
	var/oldspawns = npcspawnson
	npcspawnson = 1 //mob/npc/New deleta o mob com spawns ambientes desligados
	var/mob/npc/E = new etype
	npcspawnson = oldspawns
	if(!E) return null
	E.loc = T
	conq_pin_bp(E, bp)
	//o New() do mob/npc destrava DEPOIS que o loc chega e chama o NPCTicker base, que so ELEVA
	//o BP (max com AverageBP) -- re-fixamos 1s depois pra onda nao nascer inflada num server forte
	var/mob/npc/E2 = E
	spawn(10) if(E2 && E2.loc && !E2.dead) conq_pin_bp(E2, bp)
	if(champ) E.name = "Guardiao de [D.name]"
	return E

//fixa o BP de um NPC generico (espelho do bev_pin_bp, sem o tipo de boss)
proc/conq_pin_bp(mob/npc/M, bp)
	if(!M) return
	M.BP = bp
	M.BPBoost = 1
	M.statify()
	M.Ki = M.MaxKi
	M.staminadeBuff = 100
	M.maxNutrition = 100
	M.currentNutrition = 100
	M.Anger = 100
	M.stamina = M.maxstamina
	M.powerlevel()

// ---------------------------------------------------------------------------
// SPAWN NO DOMINIO (procedural -- pre-feito usa o spawnPlanet normal)
// ---------------------------------------------------------------------------
//gancho do Locate(): 1 = spawnou no dominio; 0 = segue o fluxo padrao
proc/conq_spawn_try(mob/M)
	if(!M || !M.conq_spawn) return 0
	var/pl = M.conq_spawn
	var/list/R = conq_data[pl]
	if(!islist(R) || R["sig"] != M.signature)
		M.conq_spawn = "" //dominio perdido
		return 0
	var/datum/pspace_planet/D = pspace_planets[pl]
	if(!D) return 0
	if(!D.surface_z)
		if(!D.generating) pspace_gen_request(D, null) //aquece pro proximo spawn
		to_chat(M, "<font color=#88ccff>Seu dominio [pl] esta com a superficie descarregada -- mapeando; por ora, spawn padrao.</font>")
		return 0
	var/turf/T = locate(R["fx"], R["fy"], D.surface_z)
	if(!T || T.density) T = locate(max(2, D.land_x), max(2, D.land_y), D.surface_z)
	if(!T) return 0
	M.loc = T
	M.Planet = pl
	to_chat(M, "<font color=#88ccff>Voce desperta em seu dominio: <b>[pl]</b>.</font>")
	return 1

// ---------------------------------------------------------------------------
// Verbs de consulta / admin
// ---------------------------------------------------------------------------
mob/verb/Meus_Dominios()
	set name = "Meus Dominios"
	set category = "Other"
	var/n = 0
	to_chat(usr, "<b>--- Seus dominios planetarios ---</b>")
	for(var/pl in conq_data)
		var/list/R = conq_data[pl]
		if(!islist(R) || R["sig"] != usr.signature) continue
		n++
		var/sp = (usr.spawnPlanet == pl || usr.conq_spawn == pl) ? " &middot; SPAWN" : ""
		to_chat(usr, "[conq_pname(pl)] -- desde [time2text(R["since"], "DD/MM/YYYY")] &middot; tributo acumulado: [conq_tribute_pending(pl)] zenni[sp]")
	if(!n) to_chat(usr, "(nenhum -- finque sua bandeira com o verb Conquistar Planeta)")

mob/Admin3/verb/Conquest_Control()
	set category = "Admin"
	var/choice = input(usr, "Dominios planetarios", "Conquest") as null|anything in list("Ver tudo", "Conceder dominio", "Remover dominio", "Zerar tudo")
	if(!choice) return
	switch(choice)
		if("Ver tudo")
			if(!conq_data.len) to_chat(usr, "(nenhum dominio)")
			for(var/pl in conq_data)
				var/list/R = conq_data[pl]
				to_chat(usr, "[pl]: [R["name"]] (sig [R["sig"]]) desde [time2text(R["since"], "DD/MM/YYYY")] &middot; tributo [conq_tribute_pending(pl)]z")
		if("Conceder dominio")
			var/list/players = list()
			for(var/mob/P in player_list)
				if(P.client) players += P
			var/mob/T = input(usr, "Qual player?", "Conquest") as null|anything in players
			if(!T) return
			var/pl = input(usr, "Nome exato do planeta (Earth/Vegeta/Namek ou procedural):", "Conquest") as text|null
			if(!pl) return
			if(!conq_premade(pl) && !pspace_planets[pl])
				to_chat(usr, "Planeta desconhecido: [pl]")
				return
			conq_data[pl] = list("sig" = T.signature, "name" = T.name, "ckey" = ckey(T.key), "since" = world.realtime, "collect" = world.realtime, "fx" = 0, "fy" = 0)
			conq_save()
			if(conq_premade(pl)) conq_place_flag(pl, (pl == "Earth") ? 1 : (pl == "Namek") ? 2 : 3)
			else
				var/datum/pspace_planet/D = pspace_planets[pl]
				if(D && D.surface_z) conq_place_flag(pl, D.surface_z)
			to_chat(usr, "[pl] concedido a [T.name].")
			conq_notify_owner(T.signature, "<font color=yellow><b>[conq_pname(pl)] foi declarado seu dominio!</b></font>")
		if("Remover dominio")
			var/pl = input(usr, "Qual planeta?", "Conquest") as null|anything in conq_data
			if(!pl) return
			conq_data -= pl
			conq_save()
			conq_drop_flags(pl, 0)
			to_chat(usr, "Dominio de [pl] removido.")
		if("Zerar tudo")
			conq_data = list()
			conq_notify = list()
			conq_save()
			var/list/doomed = list()
			for(var/obj/Conquest_Flag/F in obj_list)
				if(F && F.loc) doomed += F
			for(var/obj/Conquest_Flag/F in doomed) del F
			to_chat(usr, "Todos os dominios foram apagados.")
