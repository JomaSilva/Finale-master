// ============================================================================
// TORNEIO DE ARTES MARCIAIS -- evento mensal na Terra
//   * A cada mes do jogo, todos os jogadores NA TERRA recebem o convite.
//   * So acontece se PELO MENOS 1 player aceitar; as 16 vagas das oitavas sao
//     completadas com NPCs (Humano/Saiyajin/Namekuseijin/Frost Demon) com BP
//     aleatorio em torno da MEDIA dos players inscritos, Zanzoken e ki basico.
//   * Bracket 1v1: oitavas -> quartas -> semifinal -> final (NPC vs NPC rola).
//   * RING-OUT: sair do retangulo da arena SEM estar voando = derrota imediata.
//   * Premios: 1o lugar 1.000.000z, 2o 500.000z, 3o (cada semifinalista) 250.000z.
//   * Quem nao esta lutando assiste da beirada; verb "Assistir Torneio" (aba
//     Other) mostra a luta pela camera de um dos lutadores.
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define TRN_ARENA_X1 220        // vertice esquerdo da arena
#define TRN_ARENA_Y1 11         // vertice inferior
#define TRN_ARENA_X2 276        // vertice direito
#define TRN_ARENA_Y2 68         // vertice superior
#define TRN_ARENA_Z  1          // z da arena (Terra)
#define TRN_BRACKET  16         // vagas das oitavas
#define TRN_SIGNUP_TICKS 1500   // janela de inscricao (1500 = 2,5 min reais)
#define TRN_MATCH_MAX 2400      // duracao maxima da luta (2400 = 4 min) -> decide por % de HP
#define TRN_COUNTDOWN 5         // contagem regressiva (segundos) antes de cada luta
#define TRN_BREAK_TICKS 100     // pausa entre lutas (100 = 10s)
#define TRN_PRIZE_1 1000000     // premio do campeao
#define TRN_PRIZE_2 500000      // premio do vice
#define TRN_PRIZE_3 250000      // premio de CADA semifinalista derrotado (3o lugar)
#define TRN_NPC_BP_MIN 60       // BP do NPC = media dos players x rand(MIN..MAX)/100
#define TRN_NPC_BP_MAX 140
#define TRN_NPC_BP_FLOOR 500    // BP minimo de um NPC do torneio

var/datum/tournament/tournament = null   // torneio em andamento (null = nenhum)

// nomes de Frost Demon (as outras racas reusam os pools do PlanetPopulation.dm)
var/list/trn_frost_names = list("Frieza","Cooler","Frost","Chilled","Kuriza","Glacien","Polaris","Arctica","Iceberg","Snowre","Frigor","Zero")

// ---------------------------------------------------------------------------
// vars de torneio nos mobs
// ---------------------------------------------------------------------------
mob/npc/var
	tourney_lock = 0                 // 1 = lutador de torneio: a IA SO encara tourney_opponent (guards no NPCAI.dm)
	tmp/mob/tourney_opponent = null  // oponente designado da luta atual
mob/var/tmp
	trn_watching = 0                 // esta assistindo pela camera de um lutador

// ---------------------------------------------------------------------------
// O NPC lutador (mesma receita do EventBoss, mas nocauteia em vez de matar)
// ---------------------------------------------------------------------------
mob/npc/Enemy/TourneyFighter
	murderToggle = 0        // luta de torneio: derruba, nao mata
	hasAI = 1
	AIAlwaysActive = 0      // NUNCA caca gente por conta propria (so o oponente designado)
	monster = 1
	attackable = 1
	mindswappable = 0
	dropsCorpse = 0
	isBlaster = 1           // habilidades basicas de ki (blast/barrage via npc_combat_action)
	zanzoAI = 1             // usa aproximacao Zanzoken na luta
	tourney_lock = 1
	behavior_vals = list(85, 65, 0, 65) // corajoso, agressivo, SEM misericordia, esperto
	var/tourney_seed_bp = 0

	// BP fixo do torneio: nada de escala por AverageBP nem NPCAscension
	NPCTicker()
		set waitfor = 0
		set background = 1
		AIRunning = 1
		if(tourney_seed_bp) BP = tourney_seed_bp
		BPBoost = 1

// engaja o lutador NPC contra o oponente designado (espelha o foundTarget, sem exigir client)
mob/npc/proc/tourney_engage(mob/foe)
	if(!foe || !hasAI || KO || dead) return
	tourney_opponent = foe
	tourney_lock = 1
	attackable = 1
	target = foe
	aggro_loc = loc
	dir = get_dir(src,foe)
	if(!AIRunning)
		AIRunning = 1
		initialState()
		chaseState()

// fim de luta: o NPC baixa a guarda e espera parado
mob/npc/proc/tourney_standdown()
	target = null
	tourney_opponent = null
	AIRunning = 0
	IsInFight = 0
	walk(src,0)
	if(KO) spawn Un_KO()

// ---------------------------------------------------------------------------
// Helpers de arena
// ---------------------------------------------------------------------------
proc/trn_in_arena(mob/M)
	if(!M || !M.loc) return 0
	return (M.z == TRN_ARENA_Z && M.x >= TRN_ARENA_X1 && M.x <= TRN_ARENA_X2 && M.y >= TRN_ARENA_Y1 && M.y <= TRN_ARENA_Y2)

// um lugar livre na BEIRADA (fora do retangulo) para plateia/espera
proc/trn_ring_turf()
	for(var/tries = 1 to 40)
		var/tx; var/ty
		switch(rand(1,4))
			if(1) //norte
				tx = rand(TRN_ARENA_X1, TRN_ARENA_X2); ty = TRN_ARENA_Y2 + rand(2,5)
			if(2) //sul
				tx = rand(TRN_ARENA_X1, TRN_ARENA_X2); ty = TRN_ARENA_Y1 - rand(2,5)
			if(3) //leste
				tx = TRN_ARENA_X2 + rand(2,5); ty = rand(TRN_ARENA_Y1, TRN_ARENA_Y2)
			if(4) //oeste
				tx = TRN_ARENA_X1 - rand(2,5); ty = rand(TRN_ARENA_Y1, TRN_ARENA_Y2)
		var/turf/T = locate(tx, ty, TRN_ARENA_Z)
		if(T && !T.density) return T
	return locate(round((TRN_ARENA_X1+TRN_ARENA_X2)/2), TRN_ARENA_Y2 + 3, TRN_ARENA_Z)

// posicoes iniciais dos dois lutadores (frente a frente no centro)
proc/trn_fighter_spot(side)
	var/cx = round((TRN_ARENA_X1 + TRN_ARENA_X2) / 2)
	var/cy = round((TRN_ARENA_Y1 + TRN_ARENA_Y2) / 2)
	for(var/off = 4 to 10)
		var/turf/T = locate(side == 1 ? cx - off : cx + off, cy, TRN_ARENA_Z)
		if(T && !T.density) return T
	return locate(cx, cy, TRN_ARENA_Z)

// cura de intervalo: HP/membros (sem regenerar membro DECEPADO de player!), Ki e folego
proc/trn_heal(mob/M)
	if(!M) return
	if(M.KO) spawn M.Un_KO()
	M.SpreadHeal(150,1,1)
	for(var/datum/Body/B in M.body)
		if(!B.lopped) B.health = B.maxhealth
	if(M.MaxKi) M.Ki = M.MaxKi
	if(M.maxstamina) M.stamina = M.maxstamina

// ---------------------------------------------------------------------------
// Fabrica do NPC lutador (pipeline de raca real, igual bosses/citizens)
// ---------------------------------------------------------------------------
proc/trn_spawn_fighter(avgbp)
	var/turf/T = trn_ring_turf()
	if(!T) return null
	var/race = pick("Human","Saiyan","Namekian","Frost Demon")
	var/mgender = (race == "Namekian" || race == "Frost Demon") ? "male" : pick("male","male","female")
	var/class = "Normal"
	switch(race)
		if("Saiyan") class = pick("Normal","Normal","Low-Class","Elite")
		if("Human") class = pick("Normal","Normal","Peak Human")
		if("Namekian") class = pick("Warrior clan","Warrior clan","Dragon clan")
		if("Frost Demon") class = "Frost Demon"
	var/oldspawns = npcspawnson //spawn de evento ignora o toggle de spawns ambientes
	npcspawnson = 1
	var/mob/npc/Enemy/TourneyFighter/M = new(T)
	npcspawnson = oldspawns
	if(!istype(M)) return null
	M.gender = mgender
	M.pgender = mgender
	M.Race = race
	M.Parent_Race = race
	M.Class = class            // pre-setada -> os stat<Race>() pulam o sorteio/input()
	M.spawnPlanet = "Earth"
	if(race == "Saiyan") M.SaiyanLineage = "Saiyan"
	M.StatRace(race, 1)
	M.race_genome_post_init()
	//corpo/visual por raca
	switch(race)
		if("Frost Demon")
			M.icon = 'Changling - Form 1.dmi'
			M.name = pick(trn_frost_names)
		if("Namekian")
			M.icon = npc_pick_body(race, mgender)
			M.name = npc_random_name("Namekian")
			if(prob(60)) npc_wear_simple(M, /obj/items/clothes/Namekjacket)
		if("Saiyan")
			M.icon = npc_pick_body(race, mgender)
			M.name = npc_random_name("Saiyan")
			npc_apply_hair(M, pick(mgender == "female" ? saiyan_hair_f : saiyan_hair_m), 0, 0, 0)
			npc_wear_armor_icon(M, 'Armor 8.dmi', 1)
		else
			M.icon = npc_pick_body(race, mgender)
			M.name = npc_random_name("Human")
			npc_apply_hair(M, pick(mgender == "female" ? human_hair_f : human_hair_m), rand(0,255), rand(0,255), rand(0,255))
			if(mgender == "female") npc_wear_simple(M, /obj/items/clothes/Gifemale)
			else
				npc_wear_simple(M, /obj/items/clothes/Gi_Top)
				npc_wear_simple(M, /obj/items/clothes/Gi_Bottom)
	M.oicon = M.icon
	//BP aleatorio em torno da media dos players inscritos
	var/bp = max(round(avgbp * rand(TRN_NPC_BP_MIN, TRN_NPC_BP_MAX) / 100), TRN_NPC_BP_FLOOR)
	M.tourney_seed_bp = bp
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
	M.haszanzo = 1 //todos os NPCs do torneio tem Zanzoken
	M.ai_intelligence = rand(45,85)
	M.ai_aggression = rand(50,85)
	return M

// ---------------------------------------------------------------------------
// O controller do torneio
// ---------------------------------------------------------------------------
datum/tournament
	var
		state = "signup"            // "signup" / "running" / "done"
		list/entrants = list()      // players inscritos
		list/npcs = list()          // NPCs criados (limpos no final)
		list/watchers = list()      // espectadores com camera ligada
		mob/fighter_a = null        // luta atual
		mob/fighter_b = null
		mob/finalist_1 = null       // os dois da FINAL (p/ premiar o vice depois)
		mob/finalist_2 = null
		round_name = ""

	proc/announce(msg)
		bev_announce("TORNEIO: [msg]")

	// mensagem so para os envolvidos (participantes + espectadores de camera)
	proc/tell(msg)
		for(var/mob/M in (entrants + watchers))
			if(M && M.client) to_chat(M, "<font color=#e0a030>[msg]")

	proc/invite(mob/M)
		set waitfor = 0
		if(!M || !M.client) return
		var/ans = alert(M, "O TORNEIO DE ARTES MARCIAIS vai comecar! Lutas 1v1 ate a final. Premios: 1o lugar [FullNum(TRN_PRIZE_1)]z, 2o [FullNum(TRN_PRIZE_2)]z, 3o [FullNum(TRN_PRIZE_3)]z. Deseja participar?", "Torneio de Artes Marciais", "Participar", "Ignorar")
		if(ans != "Participar") return
		if(state != "signup")
			to_chat(M, "<font color=yellow>As inscricoes do torneio ja fecharam.")
			return
		if(entrants.len >= TRN_BRACKET)
			to_chat(M, "<font color=yellow>As [TRN_BRACKET] vagas do torneio ja foram preenchidas!")
			return
		if(M.dead || !M.client || (M in entrants)) return
		entrants += M
		to_chat(M, "<font color=yellow><b>Inscricao confirmada!</b> Voce sera levado a arena quando o torneio comecar.")
		announce("[M.name] se inscreveu! ([entrants.len]/[TRN_BRACKET])")

	proc/trn_run() //"run" e palavra reservada no BYOND 516
		set waitfor = 0
		set background = 1
		//---- 1) inscricoes ----
		announce("O Torneio de Artes Marciais comecou as inscricoes! Jogadores na Terra: respondam ao convite. (fecha em [round(TRN_SIGNUP_TICKS/600)] min)")
		for(var/mob/M in player_list)
			if(M && M.client && !M.dead && M.Planet == "Earth" && !istype(M, /mob/lobby))
				spawn invite(M)
		sleep(TRN_SIGNUP_TICKS)
		state = "running"
		//limpa inscritos que sumiram/morreram na espera
		var/list/valid = list()
		for(var/mob/M in entrants)
			if(M && M.client && !M.dead) valid += M
		entrants = valid
		if(!entrants.len)
			announce("Nenhum lutador se inscreveu... o torneio deste mes foi CANCELADO.")
			cleanup()
			return
		//---- 2) media de BP dos players -> NPCs de preenchimento ----
		var/avgbp = 0
		for(var/mob/M in entrants) avgbp += M.expressedBP
		avgbp = max(round(avgbp / entrants.len), TRN_NPC_BP_FLOOR)
		var/list/bracket = list()
		bracket += entrants
		while(bracket.len < TRN_BRACKET)
			var/mob/npc/Enemy/TourneyFighter/F = trn_spawn_fighter(avgbp)
			if(!F) break
			npcs += F
			bracket += F
		bracket = shuffle(bracket)
		//---- 3) apresenta o bracket e posiciona todo mundo na beirada ----
		announce("As inscricoes fecharam! [entrants.len] jogador(es) e [npcs.len] convidado(s) disputam o titulo!")
		var/lineup = ""
		for(var/mob/M in bracket) lineup += "[lineup == "" ? "" : ", "][M.name]"
		tell("Chaveamento das OITAVAS: [lineup]")
		for(var/mob/M in bracket)
			var/turf/T = trn_ring_turf()
			if(M && T) M.loc = T
		sleep(50)
		//---- 4) rodadas ----
		var/list/rn = list("OITAVAS DE FINAL","QUARTAS DE FINAL","SEMIFINAL","FINAL")
		var/ri = 1
		var/list/alive = bracket
		var/list/semi_losers = list()
		while(alive.len > 1)
			round_name = (ri <= rn.len) ? rn[ri] : "RODADA [ri]"
			announce("Comecam as [round_name]! ([alive.len] lutadores)")
			if(alive.len == 2) //guarda os finalistas p/ premiar o vice no fim
				finalist_1 = alive[1]
				finalist_2 = alive[2]
			var/list/next_round = list()
			var/mnum = 0
			for(var/i = 1, i + 1 <= alive.len, i += 2)
				mnum++
				var/mob/A = alive[i]
				var/mob/B = alive[i+1]
				var/mob/W = run_match(A, B, mnum)
				var/mob/L = (W == A) ? B : A
				if(W)
					next_round += W
					if(alive.len == 4 && L) semi_losers += L //perdedores da semi = 3o lugar
				sleep(TRN_BREAK_TICKS)
			if(alive.len % 2) //numero impar (W.O. em serie): o ultimo passa direto
				var/mob/bye = alive[alive.len]
				next_round += bye
				tell("[bye ? bye.name : "?"] avanca sem lutar (chave incompleta).")
			alive = next_round
			ri++
			if(!alive.len) break
		//---- 5) premiacao ----
		var/mob/champ = alive.len ? alive[1] : null
		if(champ)
			announce("O CAMPEAO do Torneio de Artes Marciais e... [champ.name]!!!")
			award(champ, TRN_PRIZE_1, "CAMPEAO")
		var/mob/vice = (finalist_1 == champ) ? finalist_2 : finalist_1 //vice = o perdedor da final
		if(vice && vice != champ) award(vice, TRN_PRIZE_2, "vice-campeao")
		for(var/mob/L in semi_losers) award(L, TRN_PRIZE_3, "3o lugar")
		cleanup()

	proc/award(mob/M, amount, place)
		if(!M) return
		announce("[M.name] ([place]) leva [FullNum(amount)] zeni!")
		if(M.client)
			M.zenni += amount
			to_chat(M, "<font color=yellow><b>Voce recebeu [FullNum(amount)] zeni de premio do torneio!</b>")

	// uma luta 1v1; retorna o vencedor
	proc/run_match(mob/A, mob/B, mnum)
		//W.O.: lutador sumiu/morreu/deslogou antes da luta
		var/aok = fighter_ok(A)
		var/bok = fighter_ok(B)
		if(!aok && !bok) return A //dupla ausencia: avanca o primeiro por sorteio da chave
		if(!aok)
			tell("[round_name] - Luta [mnum]: [B ? B.name : "?"] vence por W.O.!")
			return B
		if(!bok)
			tell("[round_name] - Luta [mnum]: [A ? A.name : "?"] vence por W.O.!")
			return A
		fighter_a = A
		fighter_b = B
		//prepara: cura total + posiciona frente a frente
		trn_heal(A)
		trn_heal(B)
		A.loc = trn_fighter_spot(1)
		B.loc = trn_fighter_spot(2)
		A.dir = EAST
		B.dir = WEST
		announce("[round_name] - Luta [mnum]: [A.name] VS [B.name]!")
		rebind_watchers()
		for(var/c = TRN_COUNTDOWN, c >= 1, c--)
			tell("[c]...")
			sleep(10)
		tell("<b>COMECEM!</b>")
		//solta os NPCs um contra o outro
		if(istype(A, /mob/npc))
			var/mob/npc/nA = A
			nA.tourney_engage(B)
		if(istype(B, /mob/npc))
			var/mob/npc/nB = B
			nB.tourney_engage(A)
		//---- monitor da luta ----
		var/mob/winner = null
		var/t = 0
		while(!winner && t < TRN_MATCH_MAX)
			sleep(5)
			t += 5
			//sumiu/morreu/deslogou = derrota
			if(!fighter_ok(A)) { winner = B; break }
			if(!fighter_ok(B)) { winner = A; break }
			//nocaute = derrota (dupla: decide por HP)
			if(A.KO && B.KO) { winner = (A.HP >= B.HP) ? A : B; break }
			if(A.KO) { winner = B; break }
			if(B.KO) { winner = A; break }
			//RING-OUT: fora da arena SEM voar = derrota na hora
			if(!A.flight && !trn_in_arena(A))
				tell("[A.name] pisou fora da arena! RING-OUT!")
				winner = B
				break
			if(!B.flight && !trn_in_arena(B))
				tell("[B.name] pisou fora da arena! RING-OUT!")
				winner = A
				break
			//re-engaja NPC que perdeu o alvo (a cada ~3s)
			if(t % 30 == 0)
				if(istype(A, /mob/npc))
					var/mob/npc/nA = A
					if(!nA.AIRunning || !nA.target) nA.tourney_engage(B)
				if(istype(B, /mob/npc))
					var/mob/npc/nB = B
					if(!nB.AIRunning || !nB.target) nB.tourney_engage(A)
		if(!winner) //tempo esgotado: decide por % de vida
			winner = (A.HP >= B.HP) ? A : B
			tell("TEMPO ESGOTADO! Os juizes decidem por pontos...")
		var/mob/loser = (winner == A) ? B : A
		announce("[winner.name] vence a luta [winner && loser ? "contra [loser.name]" : ""]!")
		//encerra: NPCs baixam a guarda, todos curados e de volta a beirada
		if(istype(A, /mob/npc))
			var/mob/npc/nA = A
			nA.tourney_standdown()
		if(istype(B, /mob/npc))
			var/mob/npc/nB = B
			nB.tourney_standdown()
		if(fighter_ok(A))
			trn_heal(A)
			A.loc = trn_ring_turf()
		if(fighter_ok(B))
			trn_heal(B)
			B.loc = trn_ring_turf()
		fighter_a = null
		fighter_b = null
		return winner

	proc/fighter_ok(mob/M)
		if(!M || !M.loc || M.dead) return 0
		if(!istype(M, /mob/npc) && !M.client) return 0 //player deslogado
		return 1

	// espectadores de camera acompanham automaticamente a luta atual
	proc/rebind_watchers()
		for(var/mob/W in watchers)
			if(!W || !W.client) continue
			if(W == fighter_a || W == fighter_b) //chegou a vez dele lutar: devolve a visao propria
				W.client.perspective = MOB_PERSPECTIVE
				W.client.eye = W
				W.trn_watching = 0
				continue
			if(fighter_a)
				W.client.perspective = EYE_PERSPECTIVE
				W.client.eye = fighter_a
				W.trn_watching = 1

	proc/cleanup()
		state = "done"
		//desliga as cameras dos espectadores
		for(var/mob/W in watchers)
			if(W && W.client)
				W.client.perspective = MOB_PERSPECTIVE
				W.client.eye = W
			if(W) W.trn_watching = 0
		watchers.Cut()
		//remove os NPCs convidados
		for(var/mob/npc/Enemy/TourneyFighter/F in npcs)
			if(!F) continue
			F.hasAI = 0
			F.AIRunning = 0
			F.loc = null
			spawn(10) if(F) del(F)
		npcs.Cut()
		fighter_a = null
		fighter_b = null
		if(tournament == src) tournament = null

// ---------------------------------------------------------------------------
// Gatilho mensal (chamado pelo WorldClock na virada de mes) + verbs
// ---------------------------------------------------------------------------
proc/Tourney_Month_Check()
	set waitfor = 0
	if(tournament) return //ja tem um rolando
	tournament = new /datum/tournament()
	tournament.trn_run()

// assistir a luta atual pela camera de um dos lutadores (aba Other)
mob/verb/Assistir_Torneio()
	set category = "Other"
	set name = "Assistir Torneio"
	if(!tournament || tournament.state == "done")
		to_chat(usr, "Nao ha nenhum torneio acontecendo agora.")
		return
	if(usr == tournament.fighter_a || usr == tournament.fighter_b)
		to_chat(usr, "Voce ESTA na luta! Concentre-se!")
		return
	var/list/opts = list()
	if(tournament.fighter_a) opts += "Camera: [tournament.fighter_a.name]"
	if(tournament.fighter_b) opts += "Camera: [tournament.fighter_b.name]"
	opts += "Parar de assistir"
	opts += "Cancelar"
	var/choice = input(usr, "O torneio esta na fase: [tournament.round_name != "" ? tournament.round_name : "inscricoes"]. Assistir pela camera de quem?", "Assistir Torneio") in opts
	if(choice == "Cancelar") return
	if(choice == "Parar de assistir")
		usr.client.perspective = MOB_PERSPECTIVE
		usr.client.eye = usr
		usr.trn_watching = 0
		tournament.watchers -= usr
		to_chat(usr, "Voce para de assistir o torneio.")
		return
	var/mob/cam = null
	if(tournament.fighter_a && choice == "Camera: [tournament.fighter_a.name]") cam = tournament.fighter_a
	else if(tournament.fighter_b && choice == "Camera: [tournament.fighter_b.name]") cam = tournament.fighter_b
	if(!cam)
		to_chat(usr, "Essa luta ja acabou.")
		return
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = cam
	usr.trn_watching = 1
	tournament.watchers |= usr
	to_chat(usr, "<font color=yellow>Voce esta assistindo pela visao de [cam.name]. (a camera segue as proximas lutas; use este verb ou Reset View para parar)")

// admin: forcar/cancelar torneio (teste)
mob/Admin3/verb/Iniciar_Torneio()
	set category = "Admin"
	if(tournament)
		to_chat(usr, "Ja existe um torneio em andamento.")
		return
	Tourney_Month_Check()
	to_chat(usr, "Torneio iniciado na marra.")

mob/Admin3/verb/Cancelar_Torneio()
	set category = "Admin"
	if(!tournament)
		to_chat(usr, "Nao ha torneio rolando.")
		return
	tournament.announce("O torneio foi CANCELADO pela organizacao!")
	tournament.cleanup()
	to_chat(usr, "Torneio cancelado e limpo.")
