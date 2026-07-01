// ============================================================================
// BOSS EVENTS (Sistema 2) -- bosses que surgem quando players batem marcos de BP BASE.
//
//   Saga 1: Freeza no Planeta Vegeta  (gatilho: Saiyajin com 20k de BP base)
//   Saga 2: Freeza em Namek           (gatilho: qualquer player com 100k)
//   Saga 3: Androides 17/18 + Cell    (gatilho: qualquer player com 10M)
//   Saga 4: Majin Boo na Terra        (gatilho: qualquer player com 1,5B)
//
// COMO FUNCIONA:
//  - O controller (/datum/boss_events) roda um loop a cada BEV_TICK ticks:
//    detecta a virada do dia in-game (mudanca da global Days do WorldClock),
//    checa os marcos de BP em player_list, anuncia no chat global (aba Events)
//    e agenda o spawn em DIAS IN-GAME (1 dia ~= 3min50s com Yearspeed 1).
//  - Cada marco dispara UMA unica vez (latch persistido no savefile "BossEvents");
//    reboot nao re-dispara nem perde eventos pendentes; boss ativo re-spawna
//    na forma salva.
//  - Bosses usam o MESMO pipeline de raca/classe dos players (como o
//    PlanetPopulation.dm), com BP PINADO (NPCTicker proprio; sem NPCAscension,
//    sem power-up de tier) para o BP anunciado ser o BP real.
//  - Planet Destroy do boss replica o EFEITO do verb do player (que e preso a
//    usr): anima a carga, seta P.isBeingDestroyed e chama area.DestroyPlanet().
//    Matar (ou nocautear durante a carga de 30s) o boss ABORTA a destruicao.
// ============================================================================

// ============================== CONFIG ======================================
// ---- geral ----
#define BEV_TICK            10   // periodo do loop do controller (10 ticks = 1s)
#define BEV_BOSS_AGGRO_DIST 40   // raio de aggro dos bosses de evento
#define BEV_PD_CHARGE       300  // ticks carregando o Planet Destroy (30s: janela p/ matar/nocautear e interromper)
#define BEV_PD_RETRY        1200 // se a carga foi interrompida por KO, tenta de novo depois disto (2 min)

// ---- gatilhos (sempre no BP BASE do player) ----
#define BEV_M1_TRIGGER_BP 20000        // Saga 1: um SAIYAJIN atinge isto
#define BEV_M2_TRIGGER_BP 100000       // Saga 2: qualquer player
#define BEV_M3_TRIGGER_BP 10000000     // Saga 3: qualquer player (10M)
#define BEV_M4_TRIGGER_BP 1500000000   // Saga 4: qualquer player (1,5B)

// ---- delays em DIAS IN-GAME ----
#define BEV_M1_DAYS_MIN 3   // Freeza chega em Vegeta em 3..5 dias (sorteado)
#define BEV_M1_DAYS_MAX 5
#define BEV_M2_DAYS 7       // Freeza chega em Namek em 7 dias
#define BEV_CELL_DELAY_DAYS 2   // Cell aparece 2 dias depois dos androides
#define BEV_CELL_RETURN_DAYS 1  // Cell volta 1 dia depois de cada absorcao
#define BEV_M4_DAYS 7       // Boo desperta 7 dias depois do marco

// ---- BPs dos bosses ----
#define BEV_FREEZA1_BP 530000            // Freeza de Vegeta (nao transforma)
var/list/BEV_FREEZA2_BPS = list(530000, 1000000, 2000000, 3000000, 4000000) // BP por forma (Namek)
#define BEV_ANDROID_BP 100000000         // Androides 17 e 18 (100M cada)
var/list/BEV_CELL_BPS = list(150000000, 500000000, 3500000000, 5000000000)  // Cell: forma 1..4 (150M/500M/3,5B/5B)
#define BEV_BUU_BP 30000000000           // Majin Boo (30B)

// ---- timers de luta (ticks; 600 = 1 minuto) ----
#define BEV_FREEZA1_FIGHT_TIMER 3600   // 6 min de LUTA ate o Freeza usar Planet Destroy em Vegeta
#define BEV_FREEZA1_IDLE_TIMER  10800  // 18 min sem ninguem enfrenta-lo -> destroi mesmo assim
#define BEV_FREEZA2_FINAL_TIMER 3000   // 5 min na forma final ate a Planet Destruction em Namek
#define BEV_CELL_REVIVE_DELAY   600    // 1 min p/ o Cell voltar depois de morto na forma 3

// ---- mecanica das formas / absorcao ----
// Freeza (Namek) transforma quando a fracao de vida da BODY PART MAIS FERIDA cai ao limiar da forma atual:
var/list/BEV_FREEZA2_THRESHOLDS = list(0.70, 0.50, 0.35, 0.25) // forma 1->2, 2->3, 3->4, 4->final
#define BEV_FREEZA2_TRANSFORM_HEAL 0.5 // ao transformar, cura 50% do dano levado (membro a 80% volta pra 90%)
#define BEV_CELL_FLEE_HP 40            // Cell foge pra absorver quando o HP dele cai a isto (%; so formas 1 e 2)

// ---- planetas / spawn ----
#define BEV_FREEZA1_PLANET "Vegeta"
#define BEV_FREEZA2_PLANET "Namek"
#define BEV_CELL_PLANET    "Earth"
#define BEV_BUU_PLANET     "Earth"

// ---- icones ----
#define BEV_FREEZA1_ICON 'Changling - Form 1.dmi'
var/list/BEV_FREEZA2_ICONS = list('Changling - Form 1.dmi','Changling - Form 2.dmi','Changling - Form 3.dmi','Changeling Form 4.dmi','Changeling Frieza 100% 3.dmi')
var/list/BEV_CELL_ICONS = list('Bio Android 1.dmi','Bio Android 2.dmi','Bio Android 3.dmi','Bio Android 3.dmi') // forma 4 = mesma 3 + raios de SSJ2
#define BEV_A17_ICON 'NewPaleMale.dmi'
#define BEV_A18_ICON 'NewPaleFemale.dmi'
#define BEV_BUU_ICON 'MajinForm5.dmi'
// cabelo dos androides (Hair_Long.dmi e grayscale escuro; o tinte e ADITIVO -> o rgb define a cor)
#define BEV_A17_HAIR_R 10
#define BEV_A17_HAIR_G 10
#define BEV_A17_HAIR_B 10
#define BEV_A18_HAIR_R 255   // loiro "via codigo" da 18
#define BEV_A18_HAIR_G 222
#define BEV_A18_HAIR_B 120
// ============================ FIM DO CONFIG =================================

var/bev_enabled = 1                       // interruptor mestre (verb de admin)
var/datum/boss_events/boss_events = null  // singleton do controller

// anuncio global: chat legado + aba "Events" (categoria announce) do chat HTML
proc/bev_announce(msg)
	to_chat(world, "<font color=#e0a030><b>[msg]</b></font>", "announce")

// o planeta ainda existe e pode receber o evento?
proc/bev_planet_ok(planet)
	for(var/obj/Planets/P in planet_list)
		if(P.planetType == planet)
			return (!P.isDestroyed && P.destroyAble)
	return 0

proc/bev_planet_destroyed(planet)
	for(var/obj/Planets/P in planet_list)
		if(P.planetType == planet)
			return P.isDestroyed
	return 0

// fracao de vida (0..1) da body part mais ferida (decepada conta como 0)
proc/bev_worst_limb_frac(mob/M)
	if(!M) return 1
	var/worst = 1
	for(var/datum/Body/S in M.body)
		if(S.lopped)
			worst = 0
			continue
		var/f = (S.maxhealth > 0) ? (S.health / S.maxhealth) : 1
		if(f < worst) worst = f
	return worst

proc/bev_is_saiyan(mob/M)
	return (M.Race == "Saiyan" || M.Parent_Race == "Saiyan")

// ---------------------------------------------------------------------------
// O mob base dos bosses de evento
// ---------------------------------------------------------------------------
mob/npc/Enemy/EventBoss
	isBoss = 1
	murderToggle = 1        // um boss de verdade pode matar
	hasAI = 1
	AIAlwaysActive = 1      // caca players a vista
	monster = 1
	attackable = 1
	mindswappable = 0
	dropsCorpse = 0         // sem "Freeza Meat" no chao
	isBlaster = 1
	aggro_dist = BEV_BOSS_AGGRO_DIST
	ai_no_powerup = 1       // BP anunciado = BP real (sem surto de tier); Ki volta via rechargeState
	behavior_vals = list(95, 80, 0, 90) // destemido, brutal, SEM misericordia, taticamente esperto
	var
		bev_id = ""         // "freeza_vegeta" / "freeza_namek" / "a17" / "a18" / "cell" / "boo"
		boss_seed_bp = 0    // BP pinado (re-assegurado a cada engage pelo NPCTicker)
		tmp/bev_notified = 0 // ja avisou o controller da morte/despawn (evita rota dupla)

	// BP fixo do evento: NAO chama o NPCTicker base (AverageBP) nem NPCAscension (BPBoost ate 200x p/ BP >= 1M)
	NPCTicker()
		set waitfor = 0
		set background = 1
		AIRunning = 1
		if(boss_seed_bp) BP = boss_seed_bp
		BPBoost = 1

	mobDeath()
		if(!bev_notified)
			bev_notified = 1
			if(boss_events) boss_events.on_boss_death(src)
		..()

// ---------------------------------------------------------------------------
// Factory: boss com raca/classe REAIS (mesma receita do PlanetPopulation.dm)
// ---------------------------------------------------------------------------
proc/init_event_boss(turf/T, race, class, planet, bp, mgender, bicon, nname, bevid)
	if(!T) return null
	// spawn de EVENTO ignora o toggle de spawns ambientes (checagem sincrona no mob/npc/New)
	var/oldspawns = npcspawnson
	npcspawnson = 1
	var/mob/npc/Enemy/EventBoss/M = new(T)
	npcspawnson = oldspawns
	if(!istype(M)) return null
	M.bev_id = bevid
	M.name = nname
	M.gender = mgender
	M.pgender = mgender
	M.Race = race
	M.Parent_Race = race
	M.Class = class            // pre-setada (nao-"None") -> statfrost/statmajin/stathuman respeitam e pulam o sorteio
	M.spawnPlanet = planet
	if(race == "Saiyan") M.SaiyanLineage = "Saiyan"
	M.StatRace(race, 1)        // genoma + classe (sem input() em mob sem client -- verificado)
	M.race_genome_post_init()  // finalize_Race -> build_stats -> apply_stats (limbs vem do mob/New via TestMobParts)
	M.icon = bicon             // icone do boss, DEPOIS do pipeline (o pipeline nao seta icone em mob sem client)
	M.oicon = bicon
	bev_pin_bp(M, bp)
	return M

// pina o BP e normaliza os fatores que o powerlevel() le (mesma normalizacao dos citizens)
proc/bev_pin_bp(mob/npc/Enemy/EventBoss/M, bp)
	if(!M) return
	M.boss_seed_bp = bp
	M.BP = bp
	M.BPBoost = 1
	M.statify()            // MaxKi / stats efetivos a partir do BP novo
	M.Ki = M.MaxKi
	M.staminadeBuff = 100
	M.maxNutrition = 100
	M.currentNutrition = 100
	M.Anger = 100
	M.stamina = M.maxstamina
	M.powerlevel()

// remove um boss do mundo SEM contar como morte (absorcao/fuga/fim de evento)
proc/bev_despawn(mob/npc/Enemy/EventBoss/M, fx)
	if(!M) return
	M.bev_notified = 1
	M.hasAI = 0
	M.AIRunning = 0
	M.target = null
	if(fx && M.loc)
		flick('Zanzoken.dmi', M)
		createDustmisc(M.loc, 2)
	M.loc = null
	spawn(2) if(M) M.deleteMe()

// ---------------------------------------------------------------------------
// O controller
// ---------------------------------------------------------------------------
// estados de saga: 0=inativo | 1=anunciado, contando dias | 2=boss ativo | 3=boss derrotado (vitoria)
//                  4=evento consumado (planeta destruido) | 5=(so Cell) revivendo em 1 min | 6=cancelado (planeta ja nao existia)
datum/boss_events
	var
		// latches dos marcos (persistidos: cada um dispara UMA unica vez)
		m1_fired = 0
		m2_fired = 0
		m3_fired = 0
		m4_fired = 0
		// contagens regressivas em dias in-game (-1 = nada pendente)
		m1_days = -1
		m2_days = -1
		cell_days = -1        // dias ate o Cell aparecer (depois dos androides)
		cell_return_days = -1 // dias ate o Cell voltar de uma absorcao
		m4_days = -1
		// estado das sagas
		s1_state = 0
		s2_state = 0
		s2_form = 1           // forma atual do Freeza de Namek (1..5)
		s3_state = 0
		s3_cell_form = 1      // forma atual do Cell (1..4; 4 = "Super Perfeito" 5B + raios)
		a17_alive = 0
		a18_alive = 0
		s4_state = 0
		// runtime (nao persistido)
		tmp/mob/npc/Enemy/EventBoss/boss1
		tmp/mob/npc/Enemy/EventBoss/boss2
		tmp/mob/npc/Enemy/EventBoss/cell
		tmp/mob/npc/Enemy/EventBoss/a17
		tmp/mob/npc/Enemy/EventBoss/a18
		tmp/mob/npc/Enemy/EventBoss/boss4
		tmp/last_day_seen = 0
		tmp/loop_running = 0
		tmp/s1_engaged = 0    // Freeza de Vegeta ja entrou em combate
		tmp/s1_spawn_time = 0
		tmp/s1_deadline = 0   // world.time em que ele casta o Planet Destroy
		tmp/s1_casting = 0
		tmp/s2_deadline = 0   // world.time limite da forma final em Namek
		tmp/s2_casting = 0
		tmp/s3_revive_at = 0  // world.time do retorno do Cell 5B

	// ---------------------------- loop principal ----------------------------
	proc/Loop()
		set waitfor = 0
		set background = 1
		if(loop_running) return
		loop_running = 1
		last_day_seen = Days
		while(1)
			sleep(BEV_TICK)
			if(!bev_enabled) continue
			// um erro de runtime NAO pode matar o loop silenciosamente (licao do freeze da IA)
			try
				if(Days != last_day_seen) // virada de dia in-game (inclui o rollover 28 -> 1 do mes)
					last_day_seen = Days
					day_tick()
				check_triggers()
				monitor()
			catch(var/exception/e)
				WriteToLog("debug","BossEvents: erro no loop: [e] ([e.file]:[e.line])")

	// ------------------------- marcos de BP (base) --------------------------
	proc/check_triggers()
		if(m1_fired && m2_fired && m3_fired && m4_fired) return
		for(var/mob/M in player_list)
			if(!M || !M.client || M.dead || istype(M, /mob/lobby)) continue
			if(!m1_fired && M.BP >= BEV_M1_TRIGGER_BP && bev_is_saiyan(M)) fire_m1(M)
			if(!m2_fired && M.BP >= BEV_M2_TRIGGER_BP) fire_m2(M)
			if(!m3_fired && M.BP >= BEV_M3_TRIGGER_BP) fire_m3(M)
			if(!m4_fired && M.BP >= BEV_M4_TRIGGER_BP) fire_m4(M)

	proc/fire_m1(mob/M)
		m1_fired = 1
		if(!bev_planet_ok(BEV_FREEZA1_PLANET)) // Vegeta ja nao existe: marco consumido sem evento
			s1_state = 6
			save_state()
			return
		m1_days = rand(BEV_M1_DAYS_MIN, BEV_M1_DAYS_MAX)
		s1_state = 1
		bev_announce("O poder crescente dos Saiyajins chamou uma atencao terrivel... Freeza se aproxima do Planeta Vegeta! Ele chegara em [m1_days] dias.")
		save_state()

	proc/fire_m2(mob/M)
		m2_fired = 1
		if(!bev_planet_ok(BEV_FREEZA2_PLANET))
			s2_state = 6
			save_state()
			return
		m2_days = BEV_M2_DAYS
		s2_state = 1
		bev_announce("Freeza partiu em direcao a Namek atras das Esferas do Dragao! Ele chegara em [m2_days] dias.")
		save_state()

	proc/fire_m3(mob/M)
		m3_fired = 1
		if(!bev_planet_ok(BEV_CELL_PLANET))
			s3_state = 6
			save_state()
			return
		s3_state = 1
		spawn_androids()
		cell_days = BEV_CELL_DELAY_DAYS
		save_state()

	proc/fire_m4(mob/M)
		m4_fired = 1
		if(!bev_planet_ok(BEV_BUU_PLANET))
			s4_state = 6
			save_state()
			return
		m4_days = BEV_M4_DAYS
		s4_state = 1
		bev_announce("Uma presenca maligna e ancestral comeca a despertar... Algo terrivel acontecera em [m4_days] dias.")
		save_state()

	// -------------------------- virada de dia -------------------------------
	proc/day_tick()
		if(s1_state == 1 && m1_days > 0)
			m1_days--
			if(m1_days <= 0) spawn_freeza_vegeta()
			else save_state()
		if(s2_state == 1 && m2_days > 0)
			m2_days--
			if(m2_days <= 0) spawn_freeza_namek(s2_form)
			else save_state()
		if(s3_state == 1 && cell_days > 0)
			cell_days--
			if(cell_days <= 0) spawn_cell(1)
			else save_state()
		if(s3_state == 3 && cell_return_days > 0) // Cell fora, absorvendo
			cell_return_days--
			if(cell_return_days <= 0) spawn_cell(s3_cell_form)
			else save_state()
		if(s4_state == 1 && m4_days > 0)
			m4_days--
			if(m4_days <= 0) spawn_boo()
			else save_state()

	// --------------------------- spawns das sagas ---------------------------
	proc/spawn_freeza_vegeta(resume)
		if(!bev_planet_ok(BEV_FREEZA1_PLANET))
			s1_state = 6
			save_state()
			return
		var/mob/npc/Enemy/EventBoss/B = init_event_boss(planet_spawn_turf(BEV_FREEZA1_PLANET), "Frost Demon", "Mutant Frost Demon", BEV_FREEZA1_PLANET, BEV_FREEZA1_BP, "male", BEV_FREEZA1_ICON, "Freeza", "freeza_vegeta")
		if(!B) return
		boss1 = B
		s1_state = 2
		s1_engaged = 0
		s1_casting = 0
		s1_spawn_time = world.time
		s1_deadline = 0
		if(resume) bev_announce("Freeza continua no Planeta Vegeta... e seu ultimato ainda esta de pe!")
		else bev_announce("A nave de Freeza pousou! FREEZA esta no Planeta Vegeta -- e ele nao pretende deixar pedra sobre pedra!")
		save_state()

	proc/spawn_freeza_namek(form, resume)
		if(!bev_planet_ok(BEV_FREEZA2_PLANET))
			s2_state = 6
			save_state()
			return
		if(form < 1) form = 1
		if(form > BEV_FREEZA2_BPS.len) form = BEV_FREEZA2_BPS.len
		var/mob/npc/Enemy/EventBoss/B = init_event_boss(planet_spawn_turf(BEV_FREEZA2_PLANET), "Frost Demon", "Mutant Frost Demon", BEV_FREEZA2_PLANET, BEV_FREEZA2_BPS[form], "male", BEV_FREEZA2_ICONS[form], "Freeza", "freeza_namek")
		if(!B) return
		boss2 = B
		s2_form = form
		s2_state = 2
		s2_casting = 0
		s2_deadline = 0
		if(s2_form >= BEV_FREEZA2_BPS.len) // reboot no meio da forma final: reinicia o timer de 5 min
			s2_deadline = world.time + BEV_FREEZA2_FINAL_TIMER
		if(resume) bev_announce("Freeza ainda esta em Namek cacando as Esferas do Dragao!")
		else bev_announce("Freeza chegou a Namek atras das Esferas do Dragao! Os Namekuseijins estao em perigo!")
		save_state()

	proc/spawn_androids()
		var/mob/npc/Enemy/EventBoss/M17 = init_event_boss(planet_spawn_turf(BEV_CELL_PLANET), "Human", "Normal", BEV_CELL_PLANET, BEV_ANDROID_BP, "male", BEV_A17_ICON, "Androide 17", "a17")
		if(M17)
			npc_apply_hair(M17, "Long", BEV_A17_HAIR_R, BEV_A17_HAIR_G, BEV_A17_HAIR_B)
			M17.Race = "Android" // cosmetico (o genoma ja foi construido); nao afeta os stats
			a17 = M17
			a17_alive = 1
		var/mob/npc/Enemy/EventBoss/M18 = init_event_boss(planet_spawn_turf(BEV_CELL_PLANET), "Human", "Normal", BEV_CELL_PLANET, BEV_ANDROID_BP, "female", BEV_A18_ICON, "Androide 18", "a18")
		if(M18)
			npc_apply_hair(M18, "Long", BEV_A18_HAIR_R, BEV_A18_HAIR_G, BEV_A18_HAIR_B) // loira via codigo
			M18.Race = "Android"
			a18 = M18
			a18_alive = 1
		bev_announce("Duas maquinas assassinas surgiram na Terra: os ANDROIDES 17 e 18 estao espalhando destruicao!")

	proc/spawn_cell(form, resume)
		if(!bev_planet_ok(BEV_CELL_PLANET))
			s3_state = 6
			save_state()
			return
		if(form < 1) form = 1
		if(form > BEV_CELL_BPS.len) form = BEV_CELL_BPS.len
		var/mob/npc/Enemy/EventBoss/B = init_event_boss(planet_spawn_turf(BEV_CELL_PLANET), "Human", "Normal", BEV_CELL_PLANET, BEV_CELL_BPS[form], "male", BEV_CELL_ICONS[form], "Cell", "cell")
		if(!B) return
		B.Race = "Bio-Android" // cosmetico
		if(form >= 4) B.updateOverlay(/obj/overlay/effects/electrictyeffects) // raios de SSJ2 (renderiza sem client)
		cell = B
		s3_cell_form = form
		s3_state = 2
		switch(form)
			if(1)
				if(resume) bev_announce("Cell continua a solta na Terra!")
				else bev_announce("Uma criatura aterrorizante emergiu na Terra... CELL esta cacando os androides!")
			if(2) bev_announce("CELL RETORNOU! Seu corpo mudou... ele esta muito mais poderoso do que antes!")
			if(3) bev_announce("CELL RETORNOU em sua forma perfeita! Um poder monstruoso emana dele!")
			if(4) bev_announce("IMPOSSIVEL... CELL VOLTOU DA MORTE! Raios cortam o ar ao redor de seu corpo -- este e o seu poder maximo!")
		save_state()

	proc/spawn_boo(resume)
		if(!bev_planet_ok(BEV_BUU_PLANET))
			s4_state = 6
			save_state()
			return
		var/mob/npc/Enemy/EventBoss/B = init_event_boss(planet_spawn_turf(BEV_BUU_PLANET), "Majin", "Corrupted Majin", BEV_BUU_PLANET, BEV_BUU_BP, "male", BEV_BUU_ICON, "Majin Boo", "boo")
		if(!B) return
		boss4 = B
		s4_state = 2
		if(resume) bev_announce("Majin Boo continua a espalhar o caos pela Terra!")
		else bev_announce("O selo foi quebrado... MAJIN BOO despertou na Terra! Corram!")
		save_state()

	// ------------------------ monitoramento por tick ------------------------
	proc/monitor()
		// ---- Saga 1: Freeza em Vegeta (timer de luta -> Planet Destroy) ----
		if(s1_state == 2)
			if(!boss1) // ref perdida sem aviso de morte (limpeza externa): encerra como vitoria
				s1_state = 3
				save_state()
			else
				if(!s1_engaged && boss1.target) // primeira vez que alguem o enfrenta: comeca o timer da luta
					s1_engaged = 1
					s1_deadline = world.time + BEV_FREEZA1_FIGHT_TIMER
					bev_announce("A batalha contra Freeza comecou no Planeta Vegeta! Derrotem-no antes que ele perca a paciencia!")
				var/dl = s1_engaged ? s1_deadline : (s1_spawn_time + BEV_FREEZA1_IDLE_TIMER)
				if(!s1_casting && world.time >= dl)
					s1_casting = 1
					spawn cast_planet_destroy(boss1, BEV_FREEZA1_PLANET, 1)
				if(bev_planet_destroyed(BEV_FREEZA1_PLANET)) // consumado
					bev_announce("O PLANETA VEGETA FOI DESTRUIDO POR FREEZA... A raca Saiyajin quase foi extinta.")
					bev_despawn(boss1, 1)
					boss1 = null
					s1_state = 4
					save_state()
		// ---- Saga 2: Freeza em Namek (escada de formas + timer final) ----
		if(s2_state == 2)
			if(!boss2)
				s2_state = 3
				save_state()
			else
				if(s2_form < BEV_FREEZA2_BPS.len && !boss2.KO) // nocauteado nao transforma (janela de finalizacao)
					if(bev_worst_limb_frac(boss2) <= BEV_FREEZA2_THRESHOLDS[s2_form])
						freeza_transform()
				if(s2_form >= BEV_FREEZA2_BPS.len && s2_deadline && !s2_casting && world.time >= s2_deadline)
					s2_casting = 1
					spawn cast_planet_destroy(boss2, BEV_FREEZA2_PLANET, 2)
				if(bev_planet_destroyed(BEV_FREEZA2_PLANET))
					bev_announce("NAMEKUSEI FOI DESTRUIDO... Freeza riu enquanto o planeta explodia.")
					bev_despawn(boss2, 1)
					boss2 = null
					s2_state = 4
					save_state()
		// ---- Saga 3: Cell (fuga p/ absorver + retorno da morte) ----
		if(s3_state == 2 && cell)
			if(s3_cell_form <= 2 && !cell.KO && cell.HP <= BEV_CELL_FLEE_HP)
				var/mob/npc/Enemy/EventBoss/victim = null
				if(a17 && a17_alive) victim = a17
				else if(a18 && a18_alive) victim = a18
				if(victim) cell_absorb(victim)
				// sem androide vivo: ele NAO evolui -- luta ate o fim na forma atual
		if(s3_state == 5 && world.time >= s3_revive_at)
			spawn_cell(4)

	// Freeza (Namek) avanca de forma: novo icone, novo BP, cura 50% do dano levado
	proc/freeza_transform()
		if(!boss2 || s2_form >= BEV_FREEZA2_BPS.len) return
		s2_form++
		// regenera: membros decepados voltam; os demais curam 50% do que perderam
		for(var/datum/Body/S in boss2.body)
			if(S.lopped) S.RegrowLimb()
			else S.health = min(S.maxhealth, S.health + (S.maxhealth - S.health) * BEV_FREEZA2_TRANSFORM_HEAL)
		boss2.HealthSync()
		// visual + poder
		flick('Zanzoken.dmi', boss2)
		createDustmisc(boss2.loc, 3)
		createShockwavemisc(boss2.loc, 2)
		boss2.emit_Sound('powerup.wav')
		boss2.icon = BEV_FREEZA2_ICONS[s2_form]
		boss2.oicon = boss2.icon
		bev_pin_bp(boss2, BEV_FREEZA2_BPS[s2_form]) // tambem enche o Ki (transformar renova o folego)
		if(s2_form >= BEV_FREEZA2_BPS.len)
			s2_deadline = world.time + BEV_FREEZA2_FINAL_TIMER
			bev_announce("FREEZA ATINGIU SUA FORMA FINAL EM NAMEK! Voces tem [round(BEV_FREEZA2_FINAL_TIMER/600)] minutos para derrota-lo antes que ele destrua o planeta!")
		else
			bev_announce("Freeza TRANSFORMOU-SE! Sua nova forma pulsa com um poder ainda maior! (Forma [s2_form])")
		save_state()

	// Cell ferido foge e absorve um androide; volta mais forte em BEV_CELL_RETURN_DAYS dia(s)
	proc/cell_absorb(mob/npc/Enemy/EventBoss/victim)
		if(!cell || !victim) return
		var/vname = victim.name
		if(victim == a17)
			a17 = null
			a17_alive = 0
		else
			a18 = null
			a18_alive = 0
		bev_despawn(victim, 1)
		bev_despawn(cell, 1)
		cell = null
		s3_cell_form++            // 2 ou 3
		s3_state = 3              // fora do mundo, "digerindo"
		cell_return_days = BEV_CELL_RETURN_DAYS
		bev_announce("Ferido, CELL desapareceu na Terra... e encontrou [vname]! Ele absorveu o androide e se esconde para completar sua evolucao!")
		save_state()

	// ------------------------- morte de um boss -----------------------------
	proc/on_boss_death(mob/npc/Enemy/EventBoss/B)
		if(!B) return
		switch(B.bev_id)
			if("freeza_vegeta")
				boss1 = null
				abort_planet_destroy(BEV_FREEZA1_PLANET)
				s1_state = 3
				bev_announce("FREEZA FOI DERROTADO! O Planeta Vegeta esta a salvo!")
				save_state()
			if("freeza_namek")
				boss2 = null
				abort_planet_destroy(BEV_FREEZA2_PLANET)
				s2_state = 3
				bev_announce("FREEZA FOI DERROTADO EM NAMEK! As Esferas do Dragao estao seguras!")
				save_state()
			if("a17")
				a17 = null
				a17_alive = 0
				bev_announce("O Androide 17 foi destruido!")
				save_state()
			if("a18")
				a18 = null
				a18_alive = 0
				bev_announce("A Androide 18 foi destruida!")
				save_state()
			if("cell")
				cell = null
				if(s3_cell_form == 3) // morto na forma perfeita: volta em 1 min como Super Perfeito (5B + raios)
					s3_state = 5
					s3_revive_at = world.time + BEV_CELL_REVIVE_DELAY
					bev_announce("Cell foi morto... mas algo esta errado. Uma celula sobreviveu a explosao...")
				else
					s3_state = 4
					if(s3_cell_form >= 4) bev_announce("CELL FOI DESTRUIDO DE VEZ! A Terra esta finalmente livre de sua ameaca!")
					else bev_announce("CELL FOI DESTRUIDO antes de completar sua evolucao! A Terra esta a salvo!")
				save_state()
			if("boo")
				boss4 = null
				s4_state = 3
				bev_announce("MAJIN BOO FOI DESTRUIDO! A paz retorna a Terra... por enquanto.")
				save_state()

	// ---------------- Planet Destroy programatico (sem usr) -----------------
	// replica o corpo do verb do player: anima a carga, seta isBeingDestroyed e
	// chama area.DestroyPlanet(). Matar o boss ANTES do commit aborta tudo.
	proc/cast_planet_destroy(mob/npc/Enemy/EventBoss/B, planet, saga)
		set waitfor = 0
		if(!B || B.dead || !B.loc) return
		if(!bev_planet_ok(planet) || !canplanetdestroy) return // respeita o kill-switch do admin
		bev_announce("[B.name] comecou a concentrar uma energia COLOSSAL... ele vai destruir o planeta [planet == "Earth" ? "Terra" : planet]!")
		to_chat(view(B), "<font color=yellow>*[B.name] begins focusing their energy on destroying the planet!*")
		WriteToLog("rplog","[B.name] (boss de evento) iniciou o Planet Destroy em [planet]   ([time2text(world.realtime,"Day DD hh:mm")])")
		B.emit_Sound('deathball_charge.wav')
		var/obj/attack/blast/A = new/obj/attack/blast
		A.icon = '15.dmi'
		A.icon_state = "15"
		A.density = 0
		A.loc = locate(B.x, B.y + 1, B.z)
		sleep(BEV_PD_CHARGE) // 30s de carga: matar OU nocautear o boss aqui interrompe o ataque
		if(!B || B.dead || B.KO || !B.loc)
			if(A) del(A)
			if(B && B.KO)
				bev_announce("O ataque de [B.name] foi INTERROMPIDO! Ele foi nocauteado antes de liberar a energia!")
				// re-arma o timer da saga pra ele tentar de novo em alguns minutos
				if(saga == 1)
					s1_casting = 0
					s1_deadline = world.time + BEV_PD_RETRY
				else if(saga == 2)
					s2_casting = 0
					s2_deadline = world.time + BEV_PD_RETRY
			return
		flick('Zanzoken.dmi', B)
		if(A)
			A.icon = '16.dmi'
			A.icon_state = "16"
			sleep(10)
			walk(A, SOUTH, 3)
			spawn(30)
				if(A)
					var/obj/H = new/obj
					H.icon = 'Giant Hole.dmi'
					H.loc = A.loc
					del(A)
		for(var/obj/Planets/P in planet_list)
			if(P.planetType == planet)
				P.isBeingDestroyed = 1
				break
		var/area/AR = B.GetArea()
		if(AR) AR.DestroyPlanet(B.expressedBP)
		// o DestroyPlanet tem um pavio interno de ~5 min antes do commit final;
		// se o boss morrer nesse meio-tempo, on_boss_death -> abort_planet_destroy salva o planeta.

	// desfaz uma destruicao EM ANDAMENTO (boss morto antes do commit final)
	proc/abort_planet_destroy(planet)
		for(var/obj/Planets/P in planet_list)
			if(P.planetType == planet && P.isBeingDestroyed && !P.isDestroyed)
				P.isBeingDestroyed = 0
				for(var/area/A in area_list)
					if(A.Planet == planet)
						A.planet_dying = 0
						A.planet_death_stage = 0
						A.death_proc_running = 0
						A.IsWeathering = 0
				bev_announce("A energia mortal se dissipa... o planeta esta A SALVO!")
				return 1
		return 0

	// -------------------- persistencia (savefile "BossEvents") --------------
	proc/save_state()
		var/savefile/S = new("BossEvents")
		S["m1_fired"] << m1_fired
		S["m2_fired"] << m2_fired
		S["m3_fired"] << m3_fired
		S["m4_fired"] << m4_fired
		S["m1_days"] << m1_days
		S["m2_days"] << m2_days
		S["cell_days"] << cell_days
		S["cell_return_days"] << cell_return_days
		S["m4_days"] << m4_days
		S["s1_state"] << s1_state
		S["s2_state"] << s2_state
		S["s2_form"] << s2_form
		S["s3_state"] << s3_state
		S["s3_cell_form"] << s3_cell_form
		S["a17_alive"] << a17_alive
		S["a18_alive"] << a18_alive
		S["s4_state"] << s4_state

	proc/load_state()
		if(!fexists("BossEvents")) return
		var/savefile/S = new("BossEvents")
		S["m1_fired"] >> m1_fired
		S["m2_fired"] >> m2_fired
		S["m3_fired"] >> m3_fired
		S["m4_fired"] >> m4_fired
		S["m1_days"] >> m1_days
		S["m2_days"] >> m2_days
		S["cell_days"] >> cell_days
		S["cell_return_days"] >> cell_return_days
		S["m4_days"] >> m4_days
		S["s1_state"] >> s1_state
		S["s2_state"] >> s2_state
		S["s2_form"] >> s2_form
		S["s3_state"] >> s3_state
		S["s3_cell_form"] >> s3_cell_form
		S["a17_alive"] >> a17_alive
		S["a18_alive"] >> a18_alive
		S["s4_state"] >> s4_state
		// null-guards (chave ausente no savefile deixa null)
		if(isnull(m1_fired)) m1_fired = 0
		if(isnull(m2_fired)) m2_fired = 0
		if(isnull(m3_fired)) m3_fired = 0
		if(isnull(m4_fired)) m4_fired = 0
		if(isnull(m1_days)) m1_days = -1
		if(isnull(m2_days)) m2_days = -1
		if(isnull(cell_days)) cell_days = -1
		if(isnull(cell_return_days)) cell_return_days = -1
		if(isnull(m4_days)) m4_days = -1
		if(isnull(s1_state)) s1_state = 0
		if(isnull(s2_state)) s2_state = 0
		if(isnull(s2_form) || s2_form < 1) s2_form = 1
		if(isnull(s3_state)) s3_state = 0
		if(isnull(s3_cell_form) || s3_cell_form < 1) s3_cell_form = 1
		if(isnull(a17_alive)) a17_alive = 0
		if(isnull(a18_alive)) a18_alive = 0
		if(isnull(s4_state)) s4_state = 0

	// re-poe no mundo os bosses que estavam ativos quando o servidor caiu/reiniciou
	proc/respawn_active_bosses()
		if(s1_state == 2) spawn_freeza_vegeta(1)
		if(s2_state == 2) spawn_freeza_namek(s2_form, 1)
		if(s3_state >= 1 && s3_state <= 2)
			if(a17_alive && !a17)
				var/mob/npc/Enemy/EventBoss/M17 = init_event_boss(planet_spawn_turf(BEV_CELL_PLANET), "Human", "Normal", BEV_CELL_PLANET, BEV_ANDROID_BP, "male", BEV_A17_ICON, "Androide 17", "a17")
				if(M17)
					npc_apply_hair(M17, "Long", BEV_A17_HAIR_R, BEV_A17_HAIR_G, BEV_A17_HAIR_B)
					M17.Race = "Android"
					a17 = M17
			if(a18_alive && !a18)
				var/mob/npc/Enemy/EventBoss/M18 = init_event_boss(planet_spawn_turf(BEV_CELL_PLANET), "Human", "Normal", BEV_CELL_PLANET, BEV_ANDROID_BP, "female", BEV_A18_ICON, "Androide 18", "a18")
				if(M18)
					npc_apply_hair(M18, "Long", BEV_A18_HAIR_R, BEV_A18_HAIR_G, BEV_A18_HAIR_B)
					M18.Race = "Android"
					a18 = M18
		if(s3_state == 2) spawn_cell(s3_cell_form, 1)
		if(s3_state == 5) spawn_cell(4) // o timer de 1 min nao sobrevive ao reboot: ele simplesmente ja volta

	// zera TUDO (verb de admin): despawna bosses vivos e apaga o savefile
	proc/reset_all()
		bev_despawn(boss1)
		bev_despawn(boss2)
		bev_despawn(cell)
		bev_despawn(a17)
		bev_despawn(a18)
		bev_despawn(boss4)
		boss1 = null; boss2 = null; cell = null; a17 = null; a18 = null; boss4 = null
		m1_fired = 0; m2_fired = 0; m3_fired = 0; m4_fired = 0
		m1_days = -1; m2_days = -1; cell_days = -1; cell_return_days = -1; m4_days = -1
		s1_state = 0; s2_state = 0; s2_form = 1
		s3_state = 0; s3_cell_form = 1; a17_alive = 0; a18_alive = 0
		s4_state = 0
		s1_engaged = 0; s1_casting = 0; s1_deadline = 0; s2_casting = 0; s2_deadline = 0; s3_revive_at = 0
		if(fexists("BossEvents")) fdel("BossEvents")

// ---------------------------------------------------------------------------
// Boot (chamado do Initialize() no World.dm)
// ---------------------------------------------------------------------------
proc/Boss_Events_Init()
	set waitfor = 0
	if(boss_events) return
	boss_events = new
	while(worldloading) sleep(1) // mob/npc/New() tambem espera o worldloading: nao corre na frente
	boss_events.load_state()
	boss_events.respawn_active_bosses()
	spawn boss_events.Loop()

// ---------------------------------------------------------------------------
// Verbs de admin (status / teste / reset)
// ---------------------------------------------------------------------------
mob/Admin1/verb/Boss_Events_Status()
	set category = "Admin"
	if(!boss_events)
		to_chat(usr, "BossEvents: controller nao iniciado.")
		return
	var/datum/boss_events/E = boss_events
	to_chat(usr, "<b>--- Boss Events (ligado: [bev_enabled]) ---</b>")
	to_chat(usr, "Saga 1 Freeza/Vegeta: fired=[E.m1_fired] state=[E.s1_state] dias=[E.m1_days] engajou=[E.s1_engaged]")
	to_chat(usr, "Saga 2 Freeza/Namek: fired=[E.m2_fired] state=[E.s2_state] dias=[E.m2_days] forma=[E.s2_form]")
	to_chat(usr, "Saga 3 Cell: fired=[E.m3_fired] state=[E.s3_state] forma=[E.s3_cell_form] dias_cell=[E.cell_days] dias_volta=[E.cell_return_days] 17vivo=[E.a17_alive] 18viva=[E.a18_alive]")
	to_chat(usr, "Saga 4 Boo: fired=[E.m4_fired] state=[E.s4_state] dias=[E.m4_days]")
	to_chat(usr, "Dia in-game atual: [Days] (mes [Month])")

mob/Admin3/verb/Boss_Events_Control()
	set category = "Admin"
	if(!boss_events)
		to_chat(usr, "BossEvents: controller nao iniciado.")
		return
	var/choice = input(usr, "Boss Events -- controle/teste", "Boss Events") as null|anything in list("Ligar/Desligar sistema","Avancar 1 dia (so eventos)","Forcar: Freeza (Vegeta)","Forcar: Freeza (Namek)","Forcar: Androides + Cell","Forcar: Majin Boo","RESETAR TUDO")
	if(!choice) return
	var/datum/boss_events/E = boss_events
	switch(choice)
		if("Ligar/Desligar sistema")
			bev_enabled = !bev_enabled
			to_chat(usr, "BossEvents agora esta [bev_enabled ? "LIGADO" : "DESLIGADO"].")
		if("Avancar 1 dia (so eventos)")
			E.day_tick()
			to_chat(usr, "day_tick() executado.")
		if("Forcar: Freeza (Vegeta)")
			if(E.m1_fired) to_chat(usr, "Saga 1 ja disparou (use RESETAR TUDO para re-testar).")
			else E.fire_m1(usr)
		if("Forcar: Freeza (Namek)")
			if(E.m2_fired) to_chat(usr, "Saga 2 ja disparou (use RESETAR TUDO para re-testar).")
			else E.fire_m2(usr)
		if("Forcar: Androides + Cell")
			if(E.m3_fired) to_chat(usr, "Saga 3 ja disparou (use RESETAR TUDO para re-testar).")
			else E.fire_m3(usr)
		if("Forcar: Majin Boo")
			if(E.m4_fired) to_chat(usr, "Saga 4 ja disparou (use RESETAR TUDO para re-testar).")
			else E.fire_m4(usr)
		if("RESETAR TUDO")
			var/confirm = input(usr, "Tem certeza? Isso despawna os bosses e zera todos os marcos.", "Boss Events") in list("Nao","Sim")
			if(confirm == "Sim")
				E.reset_all()
				to_chat(usr, "BossEvents resetado.")
