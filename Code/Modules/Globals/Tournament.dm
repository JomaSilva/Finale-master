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

// ---- TORNEIO DO OUTRO MUNDO (so mortos; arena no ceu, z6) ----
#define TRNH_ARENA_X1 117       // vertice esquerdo da arena celeste
#define TRNH_ARENA_Y1 140       // vertice inferior
#define TRNH_ARENA_X2 126       // vertice direito
#define TRNH_ARENA_Y2 148       // vertice superior
#define TRNH_ARENA_Z  6         // z do Outro Mundo
#define TRNH_BOSS_CHANCE 45     // % de cada vaga de NPC ser um VILAO CLASSICO ja derrotado (Freeza, Cell...)

var/datum/tournament/tournament = null          // torneio da TERRA em andamento (null = nenhum)
var/datum/tournament/tournament_heaven = null   // torneio do OUTRO MUNDO em andamento

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
// Helpers de arena (a geometria em si vive no datum: in_arena/fighter_spot/rest_turf)
// ---------------------------------------------------------------------------
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
proc/trn_spawn_fighter(avgbp, turf/spawnT)
	var/turf/T = spawnT
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
		//---- parametros do torneio (a subclasse /heaven sobrescreve) ----
		tlabel = "TORNEIO"          // prefixo dos anuncios
		arena_x1 = TRN_ARENA_X1
		arena_y1 = TRN_ARENA_Y1
		arena_x2 = TRN_ARENA_X2
		arena_y2 = TRN_ARENA_Y2
		arena_z = TRN_ARENA_Z
		list/seats = null           // cadeiras fixas list(list(x,y,dir),...); null = anel em volta da arena

	proc/announce(msg)
		bev_announce("[tlabel]: [msg]")

	//---- geometria/elegibilidade parametrizadas -------------------------------
	proc/in_arena(mob/M)
		if(!M || !M.loc) return 0
		return (M.z == arena_z && M.x >= arena_x1 && M.x <= arena_x2 && M.y >= arena_y1 && M.y <= arena_y2)

	proc/fighter_spot(side) //posicoes iniciais frente a frente, sempre DENTRO da arena
		var/acx = round((arena_x1 + arena_x2) / 2)
		var/acy = round((arena_y1 + arena_y2) / 2)
		for(var/off = 3 to 10)
			var/tx = (side == 1) ? acx - off : acx + off
			if(tx < arena_x1 + 1 || tx > arena_x2 - 1) break //nao nasce na borda/fora (arena celeste e pequena)
			var/turf/T = locate(tx, acy, arena_z)
			if(T && !T.density) return T
		return locate(acx, acy, arena_z)

	proc/rest_turf() //um lugar livre na BEIRADA (fora do retangulo) para plateia/espera
		for(var/tries = 1 to 40)
			var/tx
			var/ty
			switch(rand(1,4))
				if(1) //norte
					tx = rand(arena_x1, arena_x2); ty = arena_y2 + rand(2,5)
				if(2) //sul
					tx = rand(arena_x1, arena_x2); ty = arena_y1 - rand(2,5)
				if(3) //leste
					tx = arena_x2 + rand(2,5); ty = rand(arena_y1, arena_y2)
				if(4) //oeste
					tx = arena_x1 - rand(2,5); ty = rand(arena_y1, arena_y2)
			var/turf/T = locate(tx, ty, arena_z)
			if(T && !T.density) return T
		return locate(round((arena_x1+arena_x2)/2), arena_y2 + 3, arena_z)

	proc/rest_place(mob/M) //onde os participantes esperam entre as lutas (Terra: beirada; Ceu: CADEIRAS)
		if(!M) return
		if(seats) //cadeiras fixas: senta na primeira livre, virado pra arena
			for(var/list/S in seats)
				var/turf/T = locate(S[1], S[2], arena_z)
				if(!T) continue
				var/taken = 0
				for(var/mob/O in T) taken = 1
				if(taken) continue
				M.loc = T
				M.dir = S[3]
				return
		var/turf/T2 = rest_turf()
		if(T2) M.loc = T2

	proc/eligible(mob/M) //quem recebe o CONVITE (Terra: vivos na Terra)
		return (!M.dead && M.Planet == "Earth")

	proc/still_eligible(mob/M) //ainda pode participar quando o torneio comeca
		return !M.dead

	proc/player_ok(mob/M) //condicao "de pe" de um PLAYER durante a luta (Ceu: os lutadores SAO mortos)
		return !M.dead

	proc/signup_text()
		return "O Torneio de Artes Marciais comecou as inscricoes! Jogadores na Terra: respondam ao convite. (fecha em [round(TRN_SIGNUP_TICKS/600)] min)"

	proc/invite_text()
		return "O TORNEIO DE ARTES MARCIAIS vai comecar! Lutas 1v1 ate a final. Premios: 1o lugar [FullNum(TRN_PRIZE_1)]z, 2o [FullNum(TRN_PRIZE_2)]z, 3o [FullNum(TRN_PRIZE_3)]z. Deseja participar?"

	proc/spawn_filler(avgbp) //NPC que preenche vaga (o Ceu pode escalar VILOES classicos)
		return trn_spawn_fighter(avgbp, rest_turf())

	// mensagem so para os envolvidos (participantes + espectadores de camera)
	proc/tell(msg)
		for(var/mob/M in (entrants + watchers))
			if(M && M.client) to_chat(M, "<font color=#e0a030>[msg]")

	proc/invite(mob/M)
		set waitfor = 0
		if(!M || !M.client) return
		var/ans = alert(M, invite_text(), "Torneio de Artes Marciais", "Participar", "Ignorar")
		if(ans != "Participar") return
		if(state != "signup")
			to_chat(M, "<font color=yellow>As inscricoes do torneio ja fecharam.")
			return
		if(entrants.len >= TRN_BRACKET)
			to_chat(M, "<font color=yellow>As [TRN_BRACKET] vagas do torneio ja foram preenchidas!")
			return
		if(!M.client || !still_eligible(M) || (M in entrants)) return
		entrants += M
		to_chat(M, "<font color=yellow><b>Inscricao confirmada!</b> Voce sera levado a arena quando o torneio comecar.")
		announce("[M.name] se inscreveu! ([entrants.len]/[TRN_BRACKET])")

	proc/trn_run() //"run" e palavra reservada no BYOND 516
		set waitfor = 0
		set background = 1
		//---- 1) inscricoes ----
		announce(signup_text())
		for(var/mob/M in player_list)
			if(M && M.client && eligible(M) && !istype(M, /mob/lobby))
				spawn invite(M)
		sleep(TRN_SIGNUP_TICKS)
		state = "running"
		//limpa inscritos que sumiram/perderam a condicao na espera
		var/list/valid = list()
		for(var/mob/M in entrants)
			if(M && M.client && still_eligible(M)) valid += M
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
			var/mob/npc/Enemy/TourneyFighter/F = spawn_filler(avgbp)
			if(!F) break
			npcs += F
			bracket += F
		bracket = shuffle(bracket)
		//---- 3) apresenta o bracket e posiciona todo mundo na plateia ----
		announce("As inscricoes fecharam! [entrants.len] jogador(es) e [npcs.len] convidado(s) disputam o titulo!")
		var/lineup = ""
		for(var/mob/M in bracket) lineup += "[lineup == "" ? "" : ", "][M.name]"
		tell("Chaveamento das OITAVAS: [lineup]")
		for(var/mob/M in bracket)
			rest_place(M)
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
		A.loc = fighter_spot(1)
		B.loc = fighter_spot(2)
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
			if(!A.flight && !in_arena(A))
				tell("[A.name] pisou fora da arena! RING-OUT!")
				winner = B
				break
			if(!B.flight && !in_arena(B))
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
			rest_place(A)
		if(fighter_ok(B))
			trn_heal(B)
			rest_place(B)
		fighter_a = null
		fighter_b = null
		return winner

	proc/fighter_ok(mob/M)
		if(!M || !M.loc) return 0
		if(istype(M, /mob/npc)) return !M.dead //NPC construto: so precisa existir
		if(!M.client) return 0 //player deslogado
		return player_ok(M) //Terra: vivo; Ceu: MORTO (reviveu no meio = W.O.)

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
		if(tournament_heaven == src) tournament_heaven = null

// ---------------------------------------------------------------------------
// TORNEIO DO OUTRO MUNDO -- so MORTOS participam; arena celeste (z6) com
// CADEIRAS fixas em volta; vagas de NPC podem ser VILOES classicos derrotados.
// ---------------------------------------------------------------------------
datum/tournament/heaven
	tlabel = "TORNEIO DO OUTRO MUNDO"
	arena_x1 = TRNH_ARENA_X1
	arena_y1 = TRNH_ARENA_Y1
	arena_x2 = TRNH_ARENA_X2
	arena_y2 = TRNH_ARENA_Y2
	arena_z = TRNH_ARENA_Z
	var/list/boss_used = list() //viloes ja escalados NESTE torneio (sem Freeza duplo)

	New()
		..()
		//as CADEIRAS da plateia (1 a cada 2 tiles), todas viradas pra arena:
		seats = list()
		for(var/yy = 154, yy >= 140, yy -= 2) seats += list(list(109, yy, EAST))  //fileira esquerda
		for(var/xx = 111, xx <= 125, xx += 2) seats += list(list(xx, 156, SOUTH)) //fileira de cima
		for(var/xx = 111, xx <= 125, xx += 2) seats += list(list(xx, 138, NORTH)) //fileira de baixo
		for(var/yy = 154, yy >= 140, yy -= 2) seats += list(list(128, yy, WEST))  //fileira direita

	eligible(mob/M) //convite: SO quem esta morto (a alma ja esta no Outro Mundo)
		return M.dead

	still_eligible(mob/M)
		return M.dead

	player_ok(mob/M) //durante a luta o lutador continua morto; reviveu no meio = fora (W.O.)
		return M.dead

	signup_text()
		return "O Torneio de Artes Marciais DO OUTRO MUNDO abriu as inscricoes! Almas do alem: respondam ao convite. (fecha em [round(TRN_SIGNUP_TICKS/600)] min)"

	invite_text()
		return "O TORNEIO DO OUTRO MUNDO vai comecar! So os MORTOS podem lutar. Lutas 1v1 ate a final -- e dizem que lendas do passado aparecem por la... Premios: 1o [FullNum(TRN_PRIZE_1)]z, 2o [FullNum(TRN_PRIZE_2)]z, 3o [FullNum(TRN_PRIZE_3)]z. Deseja participar?"

	spawn_filler(avgbp) //algumas vagas viram VILOES CLASSICOS que ja foram derrotados (eles estao mortos, afinal)
		if(prob(TRNH_BOSS_CHANCE))
			var/list/R = trnh_boss_roster()
			R -= boss_used
			if(R.len)
				var/vname = pick(R)
				var/mob/npc/Enemy/TourneyFighter/V = trnh_spawn_boss_cameo(vname, avgbp)
				if(V)
					boss_used += vname
					announce("Uma presenca sinistra entra na chave... <b>[vname]</b> vai lutar no torneio!")
					return V
		return ..()

	//quais viloes de evento JA FORAM DERROTADOS (BossEvents.dm persiste o estado das sagas)
	proc/trnh_boss_roster()
		var/list/R = list()
		if(!boss_events) return R
		if(boss_events.s1_state == 3 || boss_events.s2_state == 3) R += "Freeza"
		if(boss_events.s3_state >= 1 && boss_events.s3_state != 6 && !boss_events.a17_alive) R += "Androide 17"
		if(boss_events.s3_state >= 1 && boss_events.s3_state != 6 && !boss_events.a18_alive) R += "Androide 18"
		if(boss_events.s3_state == 4) R += "Cell" //4 = destruido DE VEZ (5 = Super Perfeito ainda vivo)
		if(boss_events.s4_state == 3) R += "Majin Boo"
		return R

	//o cameo: um TourneyFighter com a CARA do vilao (icones/nomes espelham os bosses de evento),
	//mas com BP na media dos inscritos (regra do torneio) e as travas de torneio normais
	proc/trnh_spawn_boss_cameo(vname, avgbp)
		var/turf/T = rest_turf()
		if(!T) return null
		var/oldspawns = npcspawnson
		npcspawnson = 1
		var/mob/npc/Enemy/TourneyFighter/M = new(T)
		npcspawnson = oldspawns
		if(!istype(M) || !M.loc) return null
		M.gender = (vname == "Androide 18") ? "female" : "male"
		M.pgender = M.gender
		M.Race = "Human" //construto do alem: o pipeline Humano e o mesmo que os proprios bosses de evento usavam
		M.Parent_Race = "Human"
		M.Class = "Normal"
		M.spawnPlanet = "Afterlife"
		M.StatRace("Human", 1)
		M.race_genome_post_init()
		M.name = vname
		switch(vname) //mesmos visuais dos bosses de evento (literais: os defines BEV_* vem num include posterior)
			if("Freeza")
				M.icon = 'Changling - Form 1.dmi'
			if("Androide 17")
				M.icon = 'NewPaleMale.dmi'
				npc_apply_hair(M, "Long", 10, 10, 10)
			if("Androide 18")
				M.icon = 'NewPaleFemale.dmi'
				npc_apply_hair(M, "Long", 255, 222, 120) //loira via codigo
			if("Cell")
				M.icon = 'Bio Android 3.dmi' //forma perfeita
			if("Majin Boo")
				M.icon = 'MajinForm5.dmi'
		M.oicon = M.icon
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
		M.haszanzo = 1
		M.ai_intelligence = rand(70, 90) //lendas lutam melhor que a media
		M.ai_aggression = rand(65, 90)
		return M

// ---------------------------------------------------------------------------
// Gatilho mensal (chamado pelo WorldClock na virada de mes) + verbs
// ---------------------------------------------------------------------------
proc/Tourney_Month_Check()
	set waitfor = 0
	if(!tournament) //torneio da TERRA (vivos)
		tournament = new /datum/tournament()
		tournament.trn_run()
	if(!tournament_heaven) //torneio do OUTRO MUNDO (mortos)
		tournament_heaven = new /datum/tournament/heaven()
		tournament_heaven.trn_run()

// assistir a luta atual pela camera de um dos lutadores (aba Other) -- cobre os DOIS torneios
mob/verb/Assistir_Torneio()
	set category = "Other"
	set name = "Assistir Torneio"
	//qual torneio? (se os dois estiverem rolando, pergunta)
	var/datum/tournament/T = null
	var/terra_on = (tournament && tournament.state != "done")
	var/ceu_on = (tournament_heaven && tournament_heaven.state != "done")
	if(terra_on && ceu_on)
		switch(input(usr, "Assistir qual torneio?", "Assistir Torneio") in list("Torneio da Terra","Torneio do Outro Mundo","Cancelar"))
			if("Torneio da Terra") T = tournament
			if("Torneio do Outro Mundo") T = tournament_heaven
			else return
	else if(terra_on) T = tournament
	else if(ceu_on) T = tournament_heaven
	if(!T)
		to_chat(usr, "Nao ha nenhum torneio acontecendo agora.")
		return
	if(usr == T.fighter_a || usr == T.fighter_b)
		to_chat(usr, "Voce ESTA na luta! Concentre-se!")
		return
	var/list/opts = list()
	if(T.fighter_a) opts += "Camera: [T.fighter_a.name]"
	if(T.fighter_b) opts += "Camera: [T.fighter_b.name]"
	opts += "Parar de assistir"
	opts += "Cancelar"
	var/choice = input(usr, "O torneio esta na fase: [T.round_name != "" ? T.round_name : "inscricoes"]. Assistir pela camera de quem?", "Assistir Torneio") in opts
	if(choice == "Cancelar") return
	if(choice == "Parar de assistir")
		usr.client.perspective = MOB_PERSPECTIVE
		usr.client.eye = usr
		usr.trn_watching = 0
		if(tournament) tournament.watchers -= usr
		if(tournament_heaven) tournament_heaven.watchers -= usr
		to_chat(usr, "Voce para de assistir o torneio.")
		return
	var/mob/cam = null
	if(T.fighter_a && choice == "Camera: [T.fighter_a.name]") cam = T.fighter_a
	else if(T.fighter_b && choice == "Camera: [T.fighter_b.name]") cam = T.fighter_b
	if(!cam)
		to_chat(usr, "Essa luta ja acabou.")
		return
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = cam
	usr.trn_watching = 1
	T.watchers |= usr
	to_chat(usr, "<font color=yellow>Voce esta assistindo pela visao de [cam.name]. (a camera segue as proximas lutas; use este verb ou Reset View para parar)")

// admin: forcar/cancelar torneio (teste)
mob/Admin3/verb/Iniciar_Torneio()
	set category = "Admin"
	switch(input(usr, "Iniciar qual torneio?", "Torneio") in list("Terra","Outro Mundo","Ambos","Cancelar"))
		if("Terra")
			if(tournament) { to_chat(usr, "O torneio da Terra ja esta em andamento."); return }
			tournament = new /datum/tournament()
			tournament.trn_run()
		if("Outro Mundo")
			if(tournament_heaven) { to_chat(usr, "O torneio do Outro Mundo ja esta em andamento."); return }
			tournament_heaven = new /datum/tournament/heaven()
			tournament_heaven.trn_run()
		if("Ambos")
			Tourney_Month_Check()
		else return
	to_chat(usr, "Torneio iniciado na marra.")

mob/Admin3/verb/Cancelar_Torneio()
	set category = "Admin"
	if(!tournament && !tournament_heaven)
		to_chat(usr, "Nao ha torneio rolando.")
		return
	switch(input(usr, "Cancelar qual torneio?", "Torneio") in list("Terra","Outro Mundo","Ambos","Cancelar"))
		if("Terra")
			if(!tournament) { to_chat(usr, "Nao ha torneio da Terra rolando."); return }
			tournament.announce("O torneio foi CANCELADO pela organizacao!")
			tournament.cleanup()
		if("Outro Mundo")
			if(!tournament_heaven) { to_chat(usr, "Nao ha torneio do Outro Mundo rolando."); return }
			tournament_heaven.announce("O torneio foi CANCELADO pelo proprio Enma!")
			tournament_heaven.cleanup()
		if("Ambos")
			if(tournament)
				tournament.announce("O torneio foi CANCELADO pela organizacao!")
				tournament.cleanup()
			if(tournament_heaven)
				tournament_heaven.announce("O torneio foi CANCELADO pelo proprio Enma!")
				tournament_heaven.cleanup()
		else return
	to_chat(usr, "Torneio cancelado e limpo.")
