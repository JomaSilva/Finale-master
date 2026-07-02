// ============================================================================
// PLANET REPUTATION (Sistema 3) -- amizade/inimizade de cada PLANETA com cada player.
//
//  - Matar cidadaos de um planeta -> o povo daquele planeta passa a odiar o player.
//  - Matar um PLAYER que e "inimigo do povo" de um planeta -> o povo passa a gostar de voce.
//  - Derrotar um boss de evento (BossEvents.dm) -> o povo do planeta te aclama como HEROI.
//  - Cidadaos andam por ai (idle_wander_loop do PlanetPopulation) e agora CONVERSAM:
//    papo com contexto de raca/planeta, fofoca sobre o heroi que salvou o planeta e
//    alertas sobre o assassino que anda matando o povo deles.
//  - Player com inimizade MUITO alta (<= REP_HOSTILE) e atacado a vista pelos
//    cidadaos daquele planeta, querendo vinganca.
//
//  Persistencia: savefile "PlanetRep" (sobrevive a reboot). Decaimento lento
//  configuravel por dia in-game (a memoria do povo esfria com o tempo).
// ============================================================================

// ============================== CONFIG ======================================
// ---- deltas de reputacao ----
#define REP_KILL_CITIZEN       -10  // matar um cidadao comum do planeta
#define REP_KILL_ROYAL         -25  // matar o Rei/Principe (realeza doi mais)
#define REP_KILL_VILLAIN_BONUS  40  // matar um PLAYER que e inimigo do povo (rep <= REP_VILLAIN) -> ganha isto em cada planeta que o odiava
// ---- limiares ----
#define REP_VILLAIN            -30  // daqui pra baixo: o povo fofoca/alerta sobre o player
#define REP_HOSTILE            -60  // daqui pra baixo: cidadaos ATACAM o player a vista (vinganca)
#define REP_HERO                50  // daqui pra cima: o povo fofoca sobre o heroi
#define REP_MIN               -200  // piso e teto da escala
#define REP_MAX                200
#define REP_DECAY_PER_DAY        1  // por dia in-game a rep anda isto em direcao a 0 (0 = nunca esquece)
// ---- comportamento social dos cidadaos ----
#define REP_VENGE_RANGE         10  // raio em que um cidadao enxerga um "cacado" e parte pra cima
#define REP_TALK_RANGE           5  // raio pra achar outro cidadao (ou um player) pra conversar perto
#define REP_TALK_PROB           45  // chance (%) de puxar papo a cada ciclo social
#define REP_TALK_MIN_DELAY     100  // ciclo social: espera entre 10s e 25s
#define REP_TALK_MAX_DELAY     250
#define REP_TALK_HERO_PROB      30  // chance (%) do papo ser sobre o heroi do planeta (se existir um)
#define REP_TALK_VILLAIN_PROB   30  // chance (%) do papo ser alerta sobre o vilao do planeta (se existir um)
#define REP_TALK_BOSS_PROB      25  // chance (%) do papo ser sobre o planeta ter sobrevivido a um boss

// ---- falas (%n = nome do player; edite a vontade, sem acentos) ----
var/list/rep_smalltalk_vegeta = list("O nivel de luta dos jovens esta cada vez maior.","Dizem que um Super Saiyajin lendario desperta a cada mil anos...","Treinei na gravidade de Vegeta ate meus musculos gritarem.","A elite acha que manda em tudo por aqui.","Um dia ainda supero a linhagem de baixa classe.")
var/list/rep_smalltalk_earth = list("A cidade anda tao tranquila hoje...","Voce viu o ultimo torneio de artes marciais?","Dizem que existem guerreiros que voam pelos ceus!","A colheita deste ano foi otima.","Minha avo jura que viu um dragao gigante no ceu uma vez.")
var/list/rep_smalltalk_namek = list("Os anciaos protegem as Esferas com a propria vida.","A agua sagrada desta terra nos mantem fortes.","Que o Grande Patriarca nos proteja.","O clima de Namek anda estranho ultimamente...","As tres estrelas de Namek brilharam bonito ontem.")
var/list/rep_reply_lines = list("E verdade...","Dizem por ai.","Tomara que sim.","Nem me fale.","Assim espero.","Quem sabe...")
var/list/rep_hero_lines = list("Ouviu falar de %n? Salvou nosso planeta! Um verdadeiro heroi!","Devo minha vida a %n.","Dizem que %n lutou como um deus para nos proteger.","Se %n aparecer por aqui, pago uma rodada!")
var/list/rep_villain_lines = list("Cuidado... %n anda matando o nosso povo.","Se %n aparecer por aqui, corra e nao olhe pra tras.","Alguem precisa deter %n antes que mais gente morra...","Perdi um amigo para %n. Maldito assassino.")
var/list/rep_venge_lines = list("E %n!! Pelo sangue do nosso povo... VINGANCA!","Voce!! %n!! Voce vai pagar por todos que matou!","MORTE A %n!! Ataquem!!","Nunca esqueceremos o que voce fez, %n!!")
var/list/rep_witness_lines = list("ASSASSINO!! %n matou um dos nossos!!","Alguem ajude!! %n esta nos matando!!","Fujam!! %n nao tem piedade!!")
var/list/rep_saved_vegeta = list("Quase perdemos o planeta para Freeza... nunca esquecerei.","Quando a nave de Freeza pousou, achei que era o fim de Vegeta.")
var/list/rep_saved_namek = list("Freeza quase destruiu Namek atras das Esferas...","Ainda sonho com aquele monstro mudando de forma...")
var/list/rep_saved_earth = list("A Terra quase acabou... androides, monstros... que tempos.","Voce lembra do terror que foi o Cell? Eu me escondi por dias.")
// ============================ FIM DO CONFIG =================================

// rep por planeta: "Planeta" -> lista assoc (ckey do player -> pontuacao)
var/list/planet_rep = list("Vegeta" = list(), "Earth" = list(), "Namek" = list())
var/list/planet_rep_names = list() // ckey -> ultimo nome conhecido (pra fofoca citar o nome)
var/planet_rep_inited = 0

// ---------------------------------------------------------------------------
// API basica
// ---------------------------------------------------------------------------
proc/planet_rep_get(planet, mob/M)
	if(!planet || !M || !M.key) return 0
	if(!(planet in planet_rep)) return 0
	var/list/L = planet_rep[planet]
	var/k = ckey(M.key)
	return (k in L) ? L[k] : 0

proc/planet_rep_label(score)
	if(score >= REP_HERO) return "HEROI do povo"
	if(score >= 15) return "Amigavel"
	if(score <= REP_HOSTILE) return "CACADO pelo povo"
	if(score <= REP_VILLAIN) return "Inimigo do povo"
	if(score <= -10) return "Malvisto"
	return "Neutro"

proc/planet_rep_add(planet, mob/M, delta, reason)
	if(!planet || !M || !M.client || !M.key || !delta) return
	if(!(planet in planet_rep)) return
	var/list/L = planet_rep[planet]
	var/k = ckey(M.key)
	var/old = (k in L) ? L[k] : 0
	var/nu = clamp(old + delta, REP_MIN, REP_MAX)
	L[k] = nu
	planet_rep_names[k] = M.name
	var/pname = (planet == "Earth") ? "Terra" : planet
	// avisos ao player nos cruzamentos de limiar
	if(old > REP_HOSTILE && nu <= REP_HOSTILE)
		to_chat(M, "<font color=red><b>O povo de [pname] agora te CACA! Os cidadaos vao te atacar assim que te virem.</b></font>")
	else if(old > REP_VILLAIN && nu <= REP_VILLAIN)
		to_chat(M, "<font color=red>Sua fama em [pname] apodrece... o povo sussurra seu nome com medo e odio.</font>")
	if(old < REP_HERO && nu >= REP_HERO)
		to_chat(M, "<font color=yellow><b>O povo de [pname] te considera um HEROI!</b></font>")
	planet_rep_save()

// nome do maior heroi (direction=1) ou pior vilao (direction=-1) do planeta, ou null
proc/planet_rep_top_name(planet, direction)
	if(!(planet in planet_rep)) return null
	var/list/L = planet_rep[planet]
	var/best_k = null
	var/best_v = 0
	for(var/k in L)
		var/v = L[k]
		if(direction > 0 && v >= REP_HERO && v > best_v)
			best_k = k
			best_v = v
		else if(direction < 0 && v <= REP_VILLAIN && (v < best_v || !best_k))
			best_k = k
			best_v = v
	if(!best_k) return null
	return (best_k in planet_rep_names) ? planet_rep_names[best_k] : null

// ---------------------------------------------------------------------------
// Hooks de morte
// ---------------------------------------------------------------------------
// um cidadao morreu: quem matou (se foi player) perde rep com o planeta dele
proc/planet_rep_on_citizen_killed(mob/npc/Citizen/C)
	if(!C || !C.pop_planet) return
	// so culpa o lastDamager se o cidadao morreu EM COMBATE (convencao do Death.dm:10): mortes
	// impessoais (destruicao do planeta, limit_life) nao podem culpar um ex-parceiro de treino,
	// ja que lastDamager nunca e limpo. Usa o timestamp do combatTag (a flag pode ficar presa em NPC).
	var/mob/K = (C.IsInFight || world.time <= C.combatTagExpire) ? C.lastDamager : null
	// SO o lastDamager com client conta -- sem fallback largo, pra um boss NPC
	// massacrando cidadaos nao empurrar a culpa pro player que estava por perto
	if(!K || !K.client || K.dead) return
	planet_rep_add(C.pop_planet, K, (C.pop_role == "commoner") ? REP_KILL_CITIZEN : REP_KILL_ROYAL, "citizen-kill")
	// testemunhas gritam e, se o assassino ja e cacado, partem pra vinganca
	var/spoke = 0
	for(var/mob/npc/Citizen/W in oview(8, C))
		if(W.pop_planet != C.pop_planet || W.dead || W.KO) continue
		if(!spoke && prob(70))
			spoke = 1
			W.citizen_say(replacetext(pick(rep_witness_lines), "%n", K.name))
		if(planet_rep_get(C.pop_planet, K) <= REP_HOSTILE && !W.AIRunning && !W.target)
			spawn(rand(3,10)) if(W && !W.target && !W.AIRunning && K && !K.dead) W.foundTarget(K)

// gancho no mobDeath do cidadao (o King chama ..() e passa por aqui tambem)
mob/npc/Citizen/var/tmp/rep_death_counted = 0 //trava: mobDeath e re-entravel (volley de blasts / Finish simultaneo) -> conta a rep UMA vez por morte
mob/npc/Citizen/mobDeath()
	if(!rep_death_counted)
		rep_death_counted = 1
		planet_rep_on_citizen_killed(src)
	..()

// um PLAYER foi morto: se ele era inimigo do povo de algum planeta, o matador ganha a gratidao
mob/var/tmp/pk_rep_taken = 0 //trava: killer_stuff pode rodar 2x na MESMA morte (mesmo padrao do pk_karma_taken); zerado no ReviveMe
proc/planet_rep_on_player_kill(mob/K, mob/V)
	if(!K || !V || !K.client || K == V) return
	if(V.pk_rep_taken) return //a gratidao desta morte ja foi contabilizada
	V.pk_rep_taken = 1
	for(var/pl in planet_rep)
		if(planet_rep_get(pl, V) <= REP_VILLAIN)
			planet_rep_add(pl, K, REP_KILL_VILLAIN_BONUS, "vinganca-do-povo")
			var/pname = (pl == "Earth") ? "Terra" : pl
			to_chat(K, "<font color=yellow>O povo de [pname] celebra a queda de [V.name] pelas suas maos!</font>")

// ---------------------------------------------------------------------------
// Vida social dos cidadaos: conversas + vinganca a vista
// ---------------------------------------------------------------------------
mob/npc/Citizen/proc/citizen_say(msg)
	if(!msg) return
	view(src) << output("<font color=#B8C7DC>[name]: [msg]","Chatpane.Chat")
	chatcast(view(src), "<font color=#B8C7DC>[name]: [msg]", "say")

// escolhe a fala pelo contexto: vilao > heroi > "sobrevivemos ao boss" > papo da raca
mob/npc/Citizen/proc/citizen_context_line()
	var/vname = planet_rep_top_name(pop_planet, -1)
	if(vname && prob(REP_TALK_VILLAIN_PROB))
		return replacetext(pick(rep_villain_lines), "%n", vname)
	var/hname = planet_rep_top_name(pop_planet, 1)
	if(hname && prob(REP_TALK_HERO_PROB))
		return replacetext(pick(rep_hero_lines), "%n", hname)
	if(boss_events && prob(REP_TALK_BOSS_PROB))
		switch(pop_planet)
			if("Vegeta")
				if(boss_events.s1_state == 3) return pick(rep_saved_vegeta)
			if("Namek")
				if(boss_events.s2_state == 3) return pick(rep_saved_namek)
			if("Earth")
				if(boss_events.s3_state == 4 || boss_events.s4_state == 3) return pick(rep_saved_earth)
	switch(pop_planet)
		if("Vegeta") return pick(rep_smalltalk_vegeta)
		if("Namek") return pick(rep_smalltalk_namek)
	return pick(rep_smalltalk_earth)

mob/npc/Citizen/proc/citizen_social_loop()
	set waitfor = 0
	set background = 1
	sleep(rand(50, 150)) // dessincroniza os ciclos entre os NPCs
	while(src && hasAI && !dead && loc) //loc null = removido do mundo (soft-del): encerra e solta a ref pro GC
		sleep(rand(REP_TALK_MIN_DELAY, REP_TALK_MAX_DELAY))
		if(!src || AIRunning || KO || dead || target) continue
		// 1) VINGANCA: um player cacado pelo povo apareceu -> grito de guerra e ataque
		var/found_prey = 0
		for(var/mob/P in oview(REP_VENGE_RANGE, src))
			if(P.client && !P.dead && !P.KO && planet_rep_get(pop_planet, P) <= REP_HOSTILE)
				found_prey = 1
				citizen_say(replacetext(pick(rep_venge_lines), "%n", P.name))
				spawn(5) if(src && !target && !AIRunning && P && !P.dead) foundTarget(P)
				break
		if(found_prey) continue
		// 2) CONVERSA: so puxa papo se tiver plateia (outro cidadao do planeta ou um player perto)
		if(!prob(REP_TALK_PROB)) continue
		var/mob/npc/Citizen/buddy = null
		for(var/mob/npc/Citizen/C2 in oview(REP_TALK_RANGE, src))
			if(C2 != src && C2.pop_planet == pop_planet && !C2.AIRunning && !C2.dead && !C2.KO && !C2.target)
				buddy = C2
				break
		var/audience = buddy ? 1 : 0
		if(!audience)
			for(var/mob/P2 in oview(REP_TALK_RANGE, src))
				if(P2.client)
					audience = 1
					break
		if(!audience) continue
		citizen_say(citizen_context_line())
		if(buddy)
			var/mob/npc/Citizen/B2 = buddy
			spawn(rand(15, 30)) if(B2 && !B2.AIRunning && !B2.dead && !B2.KO) B2.citizen_say(pick(rep_reply_lines))

// ---------------------------------------------------------------------------
// Verb do player: consultar a propria reputacao
// ---------------------------------------------------------------------------
mob/verb/Planet_Reputation()
	set name = "Planet Reputation"
	set category = "Other"
	to_chat(usr, "<b>--- Sua reputacao com os povos ---</b>")
	for(var/pl in planet_rep)
		var/score = planet_rep_get(pl, usr)
		var/pname = (pl == "Earth") ? "Terra" : pl
		to_chat(usr, "[pname]: [score] ([planet_rep_label(score)])")

// ---------------------------------------------------------------------------
// Persistencia + decaimento diario
// ---------------------------------------------------------------------------
proc/planet_rep_save()
	var/savefile/S = new("PlanetRep")
	S["rep_vegeta"] << planet_rep["Vegeta"]
	S["rep_earth"] << planet_rep["Earth"]
	S["rep_namek"] << planet_rep["Namek"]
	S["names"] << planet_rep_names

proc/planet_rep_load()
	if(!fexists("PlanetRep")) return
	var/savefile/S = new("PlanetRep")
	var/list/lv
	var/list/le
	var/list/ln
	var/list/lnames
	S["rep_vegeta"] >> lv
	S["rep_earth"] >> le
	S["rep_namek"] >> ln
	S["names"] >> lnames
	if(istype(lv)) planet_rep["Vegeta"] = lv
	if(istype(le)) planet_rep["Earth"] = le
	if(istype(ln)) planet_rep["Namek"] = ln
	if(istype(lnames)) planet_rep_names = lnames

// a cada dia in-game a rep anda REP_DECAY_PER_DAY em direcao a 0 (o povo esquece devagar)
proc/planet_rep_decay_loop()
	set waitfor = 0
	set background = 1
	var/lastday = Days
	while(1)
		sleep(50)
		if(REP_DECAY_PER_DAY <= 0) continue
		if(Days == lastday) continue
		lastday = Days
		var/changed = 0
		for(var/pl in planet_rep)
			var/list/L = planet_rep[pl]
			var/list/rm = list()
			for(var/k in L)
				var/v = L[k]
				if(v > 0) L[k] = max(0, v - REP_DECAY_PER_DAY)
				else if(v < 0) L[k] = min(0, v + REP_DECAY_PER_DAY)
				if(L[k] != v) changed = 1
				if(!L[k]) rm += k
			for(var/k2 in rm) L -= k2
		if(changed) planet_rep_save()

proc/Planet_Rep_Init()
	set waitfor = 0
	if(planet_rep_inited) return
	planet_rep_inited = 1
	while(worldloading) sleep(1)
	planet_rep_load()
	spawn planet_rep_decay_loop()

// ---------------------------------------------------------------------------
// Verb de admin: consultar/ajustar reputacao
// ---------------------------------------------------------------------------
mob/Admin3/verb/Planet_Rep_Control()
	set category = "Admin"
	var/choice = input(usr, "Reputacao planetaria", "Planet Rep") as null|anything in list("Ver tudo","Ajustar rep de um player","Zerar tudo")
	if(!choice) return
	switch(choice)
		if("Ver tudo")
			for(var/pl in planet_rep)
				to_chat(usr, "<b>[pl]:</b>")
				var/list/L = planet_rep[pl]
				if(!L.len) to_chat(usr, "  (ninguem)")
				for(var/k in L)
					var/nm = (k in planet_rep_names) ? planet_rep_names[k] : k
					to_chat(usr, "  [nm] ([k]): [L[k]] ([planet_rep_label(L[k])])")
		if("Ajustar rep de um player")
			var/list/players = list()
			for(var/mob/M in player_list)
				if(M.client) players += M
			var/mob/T = input(usr, "Qual player?", "Planet Rep") as null|anything in players
			if(!T) return
			var/pl = input(usr, "Qual planeta?", "Planet Rep") as null|anything in list("Vegeta","Earth","Namek")
			if(!pl) return
			var/amt = input(usr, "Delta (ex.: -50 ou 100):", "Planet Rep") as num
			planet_rep_add(pl, T, amt, "admin")
			to_chat(usr, "Rep de [T.name] em [pl]: [planet_rep_get(pl, T)]")
		if("Zerar tudo")
			planet_rep["Vegeta"] = list()
			planet_rep["Earth"] = list()
			planet_rep["Namek"] = list()
			planet_rep_names = list()
			planet_rep_save()
			to_chat(usr, "Reputacao planetaria zerada.")
