// ============================================================================
// SALA DO TEMPO (Hyperbolic Time Chamber) -- rework completo
//   * O Guardiao da Terra AUTORIZA a entrada (verb Permission em EarthRanks.dm
//     seta M.permission=1; a autorizacao vale para UMA entrada).
//   * Permanencia maxima: HTC_MAX_REAL_MIN minutos reais (= 2 dias de jogo).
//   * Cooldown de 24h REAIS entre visitas (persistido no save via htc_last_visit).
//   * Envelhecimento: +1 ano de idade por dia de jogo la dentro (40 min = +2 anos).
//   * Ganho de BP la dentro multiplicado por DIAS-POR-ANO do calendario
//     (28 dias x 10 meses = 280x) -- 1 dia na sala = 1 ano de treino fora.
//   * Gravidade fixa em 10x (ajustada no Grav() de Gravity.dm).
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define HTC_MAX_REAL_MIN     40      // permanencia maxima em minutos REAIS (= 2 dias de jogo a 20min/dia)
#define HTC_COOLDOWN_HOURS   24      // cooldown entre visitas, em horas REAIS
#define HTC_AGE_PER_GAME_DAY 1       // anos de idade ganhos por DIA DE JOGO dentro da sala
#define HTC_DAYS_PER_MONTH   28      // dias por mes do WorldClock (Days 1..28)
#define HTC_MONTHS_PER_YEAR  10      // meses por ano do WorldClock (Month 1..10)
#define HTC_Z                13      // z-level da sala
#define HTC_ENTRY_LOC        locate(146,160,13) // onde a porta deixa o jogador
#define HTC_EXIT_LOC         locate(125,420,12) // pra onde a saida devolve (Lookout)
#define HTC_TICK             100     // passo do loop de sessao (100 ticks = 10s reais)

mob/var
	htc_last_visit = 0        // world.realtime da ULTIMA entrada (persiste no save -> cooldown sobrevive relog/reboot)
mob/var/tmp
	htc_inside = 0            // sessao ativa (nao salva; re-armada no login por htc_login_check)
	htc_session_start = 0     // world.realtime do inicio DESTA sessao (p/ limite de 40 min)
	htc_warned_left = 0       // ultimo aviso de tempo restante ja dado (10/5/1)

// multiplicador de ganho de BP dentro da sala: dias que 1 ano de jogo tem.
// Aplicado em Attack_Gain / Train_Gain / Blast_Gain / Grav_Gain.
mob/proc/htc_gain_mult()
	if(z == HTC_Z) return HTC_DAYS_PER_MONTH * HTC_MONTHS_PER_YEAR
	return 1

// ticks de realtime que ainda faltam para o cooldown acabar (0 = liberado)
mob/proc/htc_cooldown_left()
	if(!htc_last_visit) return 0
	var/cd = HTC_COOLDOWN_HOURS * 36000 // 1h real = 36000 ticks de world.realtime
	var/left = (htc_last_visit + cd) - world.realtime
	return max(left, 0)

// tentativa de entrada pela porta (chamada pelo turf tohbtc em Turfs.dm)
mob/proc/htc_try_enter()
	if(!client || dead || KO) return
	if(htc_inside) return
	if(permission != 1)
		to_chat(src, "<font color=yellow>Uma barreira magica bloqueia a porta. Apenas o Guardiao da Terra pode autorizar sua entrada na Sala do Tempo.")
		return
	var/left = htc_cooldown_left()
	if(left > 0)
		var/hrs = round(left / 36000)
		var/mins = round((left % 36000) / 600)
		to_chat(src, "<font color=yellow>Seu corpo ainda nao se recuperou da distorcao temporal. Voce podera entrar de novo em [hrs]h[mins]m (tempo real).")
		return
	//entrada liberada: consome a autorizacao e arma o cooldown JA NA ENTRADA (sem re-entrada em loop)
	permission = 0
	htc_last_visit = world.realtime
	EnteredHBTC++
	loc = HTC_ENTRY_LOC
	to_chat(src, "<font color=yellow><b>Voce entra na Sala do Tempo.</b> Um ano se passa aqui a cada dia... Voce pode ficar no maximo [HTC_MAX_REAL_MIN] minutos ([round(HTC_MAX_REAL_MIN/DAY_REAL_MINUTES)] dias). Saia pela porta antes disso!")
	to_chat(view(HTC_EXIT_LOC), "<font color=silver>[src] atravessa a porta da Sala do Tempo.")
	spawn htc_session()

// loop de sessao: envelhece, avisa o tempo restante e expulsa no limite
mob/proc/htc_session()
	set waitfor = 0
	set background = 1
	if(htc_inside) return
	htc_inside = 1
	if(!htc_session_start) htc_session_start = world.realtime
	htc_warned_left = 0
	var/aged = 0 //anos ganhos NESTA sessao (p/ mensagem de saida)
	while(src && loc && z == HTC_Z && !dead)
		sleep(HTC_TICK)
		if(!src || !loc) break
		if(z != HTC_Z) break //saiu pela porta (ou morreu/teleportou): fecha a conta
		if(!client) continue //deslogado la dentro: o relogio dos 40 min segue correndo, mas so envelhece online
		//envelhecimento continuo: 1 ano por dia de jogo => (ticks/600)/DAY_REAL_MINUTES anos por passo
		var/step_years = ((HTC_TICK / 600) / DAY_REAL_MINUTES) * HTC_AGE_PER_GAME_DAY
		Age += step_years
		aged += step_years
		//tempo restante + avisos (10/5/1 min)
		var/elapsed = world.realtime - htc_session_start
		var/left_min = HTC_MAX_REAL_MIN - (elapsed / 600)
		if(left_min <= 0)
			to_chat(src, "<font color=red><b>Seu tempo na Sala do Tempo acabou!</b> A porta o expulsa de volta ao Templo.")
			break
		for(var/w in list(10,5,1))
			if(left_min <= w && htc_warned_left != w && (htc_warned_left == 0 || htc_warned_left > w))
				htc_warned_left = w
				to_chat(src, "<font color=yellow>Sala do Tempo: restam ~[w] minuto\s.")
				break
	//---- fim da sessao ----
	htc_inside = 0
	htc_session_start = 0
	if(src)
		if(z == HTC_Z && loc) loc = HTC_EXIT_LOC //expulso pelo limite (ou sessao morta): devolve ao Lookout
		if(aged >= 0.1)
			to_chat(src, "<font color=yellow>Voce saiu da Sala do Tempo <b>[round(aged,0.1)] ano\s mais velho</b>.")

// relog dentro da sala: retoma a sessao com o RELOGIO ORIGINAL (deslogar nao estica os 40 min)
mob/proc/htc_login_check()
	if(z != HTC_Z || !client) return
	var/elapsed = world.realtime - htc_last_visit
	if(elapsed >= HTC_MAX_REAL_MIN * 600 || elapsed < 0)
		loc = HTC_EXIT_LOC
		to_chat(src, "<font color=yellow>Seu tempo na Sala do Tempo terminou enquanto voce esteve fora.")
		return
	htc_session_start = htc_last_visit
	spawn htc_session()
