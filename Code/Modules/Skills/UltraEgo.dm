// ============================================================================
// ULTRA EGO -- POWER OF DESTRUCTION (o espelho do Ultra Instinct, convertido
// do jogo antigo do dono). Mesma logica do UI, disciplina oposta:
//
//  APRENDIZADO (cadeia de ensino): so aprende quem for ENSINADO por um GOD OF
//  DESTRUCTION (o portador do titulo sempre possui o Power of Destruction) ou
//  por alguem da cadeia. Requisito do aluno: God Ki tier 1+. Perder o titulo
//  NAO desaprende.
//
//  DUAS ENERGIAS (mesma logica das proficiencias do UI):
//   - DESTRUCTION ENERGY REAL (ue_energy_real 0-100): maestria permanente,
//     cresce por USO EM COMBATE. Destrava por faixa:
//       0%+  Aura of Destruction (o toggle)
//       20%+ Destroyer Form            (forma 60x)
//       40%+ Unbound Ego               (BP por membro FERIDO)
//       60%+ Ultra Ego                 (forma 66x)
//       80%+ Hakai Infusion            (ki attacks infundidos de Hakai)
//   - ATUAL (ue_energy 0-100): escala TODOS os bonus da aura. Drena com a
//     aura ligada e nas formas; NAO recupera com tag de combate; fora de
//     combate recupera devagar ate o teto da real.
//
//  AURA OF DESTRUCTION (toggle): quem te acerta MELEE sofre recuo (1% do dano
//  + bonus pela energia); ataque de KI que te acerta perde 20% (+bonus); 15%
//  de reducao de dano (+bonus); e UMA vez por luta o golpe FATAL e negado --
//  voce fica de pe por um fio, a aura estoura e detona a DESTRUCTION
//  EXPLOSION (50% do ultimo golpe recebido + bonus) em area.
//
//  UNBOUND EGO (passiva 40%+, ativa com aura/forma ligada): cada membro
//  FERIDO da ate +5% de BP (quanto mais perto de quebrar, maior o bonus;
//  quebrou/decepou = perde o bonus daquele membro). TODOS os 6 membros no
//  pico ao mesmo tempo = +20% extra + restaura 25% de Ki e Stamina (1x por
//  luta). Vegeta approves.
//
//  FORMAS (exclusivas com formas raciais, UI e Fury): Destroyer 60x /
//  Ultra Ego 66x, dreno de ki permanente, transformar RENOVA a energia
//  atual (80% / 100%).
//
//  HAKAI INFUSION (ativa 80%+): 1 min de ki attacks infundidos -- +5% de
//  penetracao, deflect do alvo cortado pela metade, e em DISPUTA DE BEAMS o
//  seu beam DEVORA o rival a cada 5s (dreno de ki + empurrao no medidor).
//  Custo 5% do Ki; recarga 30s apos acabar.
// ============================================================================

// ============================== CONFIG ======================================
#define UE_MULT_DESTROYER 60      //multiplicador da Destroyer Form
#define UE_MULT_ULTRA 66          //multiplicador do Ultra Ego
#define UE_ENERGY_D_START 80      //energia ATUAL ao entrar na Destroyer Form
#define UE_ENERGY_U_START 100     //energia ATUAL ao entrar no Ultra Ego
#define UE_UNLOCK_DESTROYER 20    //energia REAL que destrava a Destroyer Form
#define UE_UNLOCK_EGO 40          //destrava o Unbound Ego
#define UE_UNLOCK_ULTRA 60        //destrava o Ultra Ego
#define UE_UNLOCK_HKI 80          //destrava a Hakai Infusion
#define UE_RECOIL_BASE 1          //recuo no atacante melee: % do dano causado...
#define UE_RECOIL_PER_EN 0.04     //...+ isto x energia atual (100 = +4% -> 5% total)
#define UE_KIEAT_BASE 20          //ataque de ki que te acerta perde % de forca...
#define UE_KIEAT_PER_EN 0.15      //...+ isto x energia (100 = +15% -> 35% total)
#define UE_DR_BASE 15             //reducao de dano geral %...
#define UE_DR_PER_EN 0.10         //...+ isto x energia (100 = +10% -> 25% total)
#define UE_EXP_BASE 50            //Destruction Explosion: % do ultimo golpe recebido...
#define UE_EXP_PER_EN 0.5         //...+ isto x energia (100 = +50% -> 100% do golpe)
#define UE_EXP_RANGE 3            //raio (tiles) da explosao
#define UE_EGO_PART_MAX 5         //Unbound Ego: bonus maximo de BP por membro (%)
#define UE_EGO_PEAK_MISSING 0.9   //membro no "pico" = perdeu 90%+ da vida (sem quebrar)
#define UE_EGO_ALL_BONUS 20       //todos os membros no pico = % extra de BP
#define UE_EGO_RESTORE 25         //...e restaura % de Ki e Stamina (1x por luta)
#define UE_DRAIN_ACTIVE 0.5       //energia ATUAL perdida por SEGUNDO com a aura ligada (fora de forma)
#define UE_DRAIN_FORM 0.35        //energia ATUAL perdida por segundo TRANSFORMADO
#define UE_REGEN 0.25             //energia recuperada por segundo FORA de combate (tudo desligado)
#define UE_REAL_PER_SEC 0.04      //energia REAL por segundo de uso em combate
#define UE_REAL_PER_PROC 0.1      //energia REAL por proc da aura (recuo/ki devorado)
#define UE_KI_DRAIN_D 0.35        //% do MaxKi por segundo na Destroyer Form
#define UE_KI_DRAIN_U 0.5         //idem no Ultra Ego
#define UE_HKI_KI_PCT 5           //custo da Hakai Infusion (% do MaxKi)
#define UE_HKI_DUR 600            //duracao da infusao (1 min)
#define UE_HKI_CD 300             //recarga (30s) contada do FIM da infusao
#define UE_HKI_PEN_MULT 1.05      //+5% de penetracao de defesa nos ataques infundidos
#define UE_HKI_DEFLECT_MULT 0.5   //deflect do alvo x isto contra ataques infundidos
#define UE_HKI_CLASH_KI 0.05      //DISPUTA DE BEAMS: fracao do MaxKi drenada do rival a cada pulso de 5s
#define UE_HKI_CLASH_PUSH 8       //...e pontos do medidor empurrados a favor do infundido
#define UE_TICKSECS 0.3           //duracao aproximada de 1 ciclo do GlobalStats
#define UE_DESTROYER_MUSIC_DS 2400 //janela (4min) do tema da PRIMEIRA Destroyer Form
#define UE_ULTRA_MUSIC_DS 2400     //janela do tema do PRIMEIRO Ultra Ego (toca junto com a cinematica)
//GOD_PATH_BOOST (0.25) e GOD_PATH_BORROW (0.25) moram no 1A Defines.dm: GodOfDestruction.dm (Ranks) compila antes deste arquivo
// ============================ FIM DO CONFIG =================================

mob/var
	ue_learned = 0      //aprendeu o Power of Destruction (persiste no save)
	ue_energy_real = 0  //Destruction Energy REAL 0-100 (persiste; destrava habilidades)
	ue_energy = 0       //Destruction Energy ATUAL 0-100 (persiste; escala os bonus)
	ue_form = 0         //0 = base | 1 = Destroyer | 2 = Ultra Ego (persiste no relog)
	ue_ultra_cine = 0   //cinematica do PRIMEIRO Ultra Ego ja vista (persiste)
	ue_destroyer_theme = 0 //tema da PRIMEIRA Destroyer Form ja tocado (persiste)
mob/var/tmp
	ue_transing = 0         //latch da cinematica de transformacao
	ue_active = 0           //Aura of Destruction ligada
	ue_ego_mult = 1         //multiplicador do Unbound Ego (lido pelo powerlevel; recalculado no tick)
	ue_deathsave_used = 0   //death-save ja gasto NESTA luta (reseta quando a tag cai)
	ue_restore_used = 0     //restauracao do Unbound Ego ja gasta NESTA luta
	ue_last_hit = 0         //dano do ultimo golpe recebido (alimenta a Destruction Explosion)
	ue_infuse_until = 0     //Hakai Infusion ativa ate...
	ue_infuse_cd = 0        //proxima infusao permitida em...
	ue_proc_msg_cd = 0      //anti-spam das falas da aura

// ---------------------------------------------------------------------------
// Aprendizado: verbs + login + ensino em cadeia (GoD e o Anjo desta escola)
// ---------------------------------------------------------------------------
mob/proc/ue_give_verbs()
	verbs += /mob/keyable/verb/Power_of_Destruction
	verbs += /mob/keyable/verb/Ultra_Ego_Form
	verbs += /mob/keyable/verb/Hakai_Infusion
	verbs += /mob/keyable/verb/Ensinar_Power_of_Destruction
	Keyableverbs += /mob/keyable/verb/Power_of_Destruction
	Keyableverbs += /mob/keyable/verb/Ultra_Ego_Form
	Keyableverbs += /mob/keyable/verb/Hakai_Infusion

mob/proc/ue_login_check()
	if(god_is_god(src) && !ue_learned && !ui_learned) //GoD SEM path: o titulo desperta o Power of Destruction (vira o path dele)
		ue_learned = 1
		to_chat(src, "<font color=#e07a9a><b>Como God of Destruction, o Power of Destruction e parte de voce.</b> (verbs na aba Skills)")
	if(!ue_learned) return //GoD do path do Instinto usa o kit EMPRESTADO (verbs via god_apply_powers)
	ue_energy_real = clamp(ue_energy_real, 0, 100)
	ue_energy = clamp(ue_energy, 0, 100)
	ue_give_verbs()
	if(ue_form && !isBuffed(/obj/buff/UltraEgo)) //relogou transformado: re-veste a forma (padrao Legendary)
		startbuff(/obj/buff/UltraEgo, 'SSJIcon.dmi')

mob/keyable/verb/Ensinar_Power_of_Destruction()
	set category = "Other"
	set name = "Ensinar Power of Destruction"
	var/mob/T2 = usr
	if(!T2.ue_learned) return
	if(T2.dead || T2.KO) return
	var/list/cands = list()
	for(var/mob/P in oview(1, T2))
		if(P.client && !P.dead && !P.KO && !P.ue_learned) cands += P
	if(!cands.len)
		to_chat(T2, "Nenhum discipulo elegivel ao seu lado (adjacente, vivo, sem o Power of Destruction).")
		return
	var/mob/S = input(T2, "Ensinar o Power of Destruction a quem?", "Ultra Ego") as null|anything in cands
	if(!S || !S.client || S.ue_learned || get_dist(T2, S) > 1) return
	if(S.ui_learned) //PATHS EXCLUSIVOS: quem trilha o Instinto nao pode trilhar a Destruicao
		to_chat(T2, "<font color=#e07a9a>[S] ja trilha o caminho do ULTRA INSTINCT -- os dois paths nao coexistem num mesmo corpo.")
		to_chat(S, "<font color=#e07a9a>Seu corpo ja pertence ao Instinto. O Ego jamais o aceitara.")
		return
	if(!S.godki || !S.godki.awakened || S.godki.mastery < GODKI_UIUE_LEARN_PCT) //a energia da destruicao consome corpos mortais: maestria de God Ki 70%+
		to_chat(T2, "<font color=#e07a9a>O corpo de [S] ainda nao suporta a energia da destruicao -- exige maestria de God Ki [GODKI_UIUE_LEARN_PCT]%+.")
		to_chat(S, "<font color=#e07a9a>Voce ainda nao esta pronto para o Power of Destruction: domine o Ki Divino ate [GODKI_UIUE_LEARN_PCT]% de maestria primeiro.")
		return
	switch(alert(S, "[T2.name] se oferece para te ensinar o POWER OF DESTRUCTION -- a tecnica dos Deuses da Destruicao. Aceitar o treinamento?", "Ultra Ego", "Aceitar", "Recusar"))
		if("Recusar")
			to_chat(T2, "[S] recusou o treinamento.")
			return
	if(!S || !T2 || S.ue_learned || get_dist(T2, S) > 1) return
	to_chat(view(T2), "<font color=#e07a9a><b>[T2] guia [S] no caminho da destruicao...</b> \"Nao apague a dor. USE a dor. O ego e a arma.\"")
	sleep(50)
	if(!S || !T2 || S.ue_learned) return
	S.ue_learned = 1
	S.ue_give_verbs()
	to_chat(S, "<font color=#f2b9cb><b>Voce aprendeu o POWER OF DESTRUCTION!</b> Ative a Aura of Destruction pelo verb Power of Destruction (aba Skills). A energia cresce com o USO em combate.")
	to_chat(T2, "<font color=#e07a9a>[S] agora carrega a energia da destruicao -- e tambem podera ensinar.")
	WriteToLog("rplog","[T2] ensinou Power of Destruction a [S]   ([time2text(world.realtime,"Day DD hh:mm")])")

// ---------------------------------------------------------------------------
// Energia REAL: ganho + anuncios de destravamento
// ---------------------------------------------------------------------------
mob/proc/ue_real_gain(amount)
	if(!ue_learned) return //kit EMPRESTADO (GoD do Instinto) nao acumula energia real
	if(ue_energy_real >= 100 || amount <= 0) return
	var/before = ue_energy_real
	ue_energy_real = min(ue_energy_real + amount, 100)
	if(before < UE_UNLOCK_DESTROYER && ue_energy_real >= UE_UNLOCK_DESTROYER)
		to_chat(src, "<font color=#f2b9cb><b>DESTROYER FORM destravada!</b> ([UE_UNLOCK_DESTROYER]% de energia) Use Ultra Ego Transform.")
	if(before < UE_UNLOCK_EGO && ue_energy_real >= UE_UNLOCK_EGO)
		to_chat(src, "<font color=#f2b9cb><b>UNBOUND EGO destravado!</b> ([UE_UNLOCK_EGO]%) Com a aura/forma ligada, cada membro FERIDO te deixa mais forte -- ate +[UE_EGO_PART_MAX]% por membro (+[UE_EGO_ALL_BONUS]% com todos no limite).")
	if(before < UE_UNLOCK_ULTRA && ue_energy_real >= UE_UNLOCK_ULTRA)
		to_chat(src, "<font color=#f2b9cb><b>ULTRA EGO destravado!</b> ([UE_UNLOCK_ULTRA]%)")
	if(before < UE_UNLOCK_HKI && ue_energy_real >= UE_UNLOCK_HKI)
		to_chat(src, "<font color=#f2b9cb><b>HAKAI INFUSION destravada!</b> ([UE_UNLOCK_HKI]%) Infunda seus ataques de ki com a energia da destruicao (verb na aba Skills).")

// ---------------------------------------------------------------------------
// FATOR DO KIT (paths do God of Destruction):
//   1.25 = GoD que trilha a DESTRUICAO (tudo amplificado em 25%)
//   1    = Power of Destruction normal
//   0.25 = GoD que trilha o INSTINTO (kit EMPRESTADO pelo titulo, sem formas,
//          rodando na PRECISAO do Ultra Instinct dele)
//   0    = nao tem o kit
// ---------------------------------------------------------------------------
proc/ue_kit_factor(mob/M)
	if(!M) return 0
	if(M.ue_learned) return god_is_god(M) ? (1 + GOD_PATH_BOOST) : 1
	if(M.ui_learned && god_is_god(M)) return GOD_PATH_BORROW
	return 0

proc/ue_has_kit(mob/M)
	return ue_kit_factor(M) > 0

//energia efetiva: o GoD do Instinto canaliza o kit pela PROFICIENCIA do UI
proc/ue_eff_energy(mob/M)
	return M.ue_learned ? M.ue_energy : M.ui_prof

proc/ue_eff_real(mob/M)
	return M.ue_learned ? M.ue_energy_real : M.ui_prof_real

//a aura esta valendo? (toggle ligado OU transformado)
proc/ue_aura_on(mob/M)
	if(!M || !ue_has_kit(M)) return 0
	if(M.dead) return 0
	return (M.ue_active || M.ue_form)

// ---------------------------------------------------------------------------
// AURA OF DESTRUCTION -- ganchos de dano
// ---------------------------------------------------------------------------
//reducao de dano geral (funil damage_m: melee/efeitos). Registra o ultimo golpe pra explosao.
proc/ue_aura_mitigate(mob/M, dmg)
	if(!ue_aura_on(M) || dmg <= 0) return dmg
	var/f = ue_kit_factor(M)
	dmg *= max(1 - (UE_DR_BASE + ue_eff_energy(M) * UE_DR_PER_EN) * f / 100, 0.1)
	M.ue_last_hit = dmg
	M.ue_real_gain(UE_REAL_PER_PROC * 0.25) //apanhar com a aura tambem ensina (fracao)
	return dmg

//colisao de ki: o ataque PERDE forca (ki devorado) + reducao de dano + penetracao da infusao
proc/ue_blast_mitigate(mob/M, obj/attack/A, dmg)
	if(dmg <= 0) return dmg
	//HAKAI INFUSION do atirador: penetracao de defesa (mesmo contra alvos sem aura)
	if(A && istype(A.proprietor, /mob))
		var/mob/P = A.proprietor
		if(P.ue_infuse_until > world.time) dmg *= 1 + (UE_HKI_PEN_MULT - 1) * ue_kit_factor(P)
	if(ue_aura_on(M))
		var/f = ue_kit_factor(M)
		var/en = ue_eff_energy(M)
		dmg *= max(1 - (UE_KIEAT_BASE + en * UE_KIEAT_PER_EN) * f / 100, 0.1) //o ataque perde ki ao tocar a aura
		dmg *= max(1 - (UE_DR_BASE + en * UE_DR_PER_EN) * f / 100, 0.1)      //e a reducao de dano geral
		M.ue_last_hit = dmg
		M.ue_real_gain(UE_REAL_PER_PROC)
		if(world.time >= M.ue_proc_msg_cd)
			M.ue_proc_msg_cd = world.time + 50
			view(M) << output("<font color=#e07a9a>A aura de destruicao de [M] DEVORA parte do ataque!</font>", "Chatpane.Chat")
			chatcast(view(M), "<font color=#e07a9a>A aura de destruicao de [M] DEVORA parte do ataque!</font>", "combat")
	return dmg

//recuo no atacante MELEE (gancho no hitProc: M = vitima com aura, K = atacante, dmg = dano causado)
proc/ue_melee_recoil(mob/M, mob/K, dmg)
	if(!ue_aura_on(M) || !K || K == M || K.dead || dmg <= 0) return
	var/recoil = dmg * (UE_RECOIL_BASE + ue_eff_energy(M) * UE_RECOIL_PER_EN) * ue_kit_factor(M) / 100
	if(recoil <= 0) return
	damage_m(K, recoil, "torso", 0, 0)
	M.ue_real_gain(UE_REAL_PER_PROC)
	if(world.time >= M.ue_proc_msg_cd)
		M.ue_proc_msg_cd = world.time + 50
		to_chat(K, "<font color=#e07a9a>A aura de destruicao de [M] QUEIMA seus golpes!</font>")

//deflect do alvo contra ataques infundidos (gancho na colisao, mexe na deflectchance)
proc/ue_infuse_deflect(obj/attack/A, deflectchance)
	if(!A || !istype(A.proprietor, /mob)) return deflectchance
	var/mob/P = A.proprietor
	if(P.ue_infuse_until > world.time) return deflectchance * max(1 - (1 - UE_HKI_DEFLECT_MULT) * ue_kit_factor(P), 0) //GoD da Destruicao corta mais fundo; kit emprestado corta so 25% do corte
	return deflectchance

//o GOLPE FATAL negado (gancho no topo do Death): 1x por luta, estoura a aura e detona a explosao
mob/proc/ue_deathsave_try()
	if(!ue_active || dead || ue_deathsave_used) return 0 //so o TOGGLE segura a morte (a forma nao tem o seguro)
	if(!ue_has_kit(src)) return 0
	ue_deathsave_used = 1
	ue_active = 0 //a aura e forcosamente encerrada
	removeOverlay(/obj/overlay/effects/ue_aura_pas)
	for(var/datum/Body/B in body) //fica de pe por um fio (nada de cura de verdade)
		if(B.lopped) continue
		B.health = max(B.health, B.maxhealth * 0.05)
	to_chat(src, "<font color=#f2b9cb><b>A Aura of Destruction NEGA o golpe fatal!</b> Voce fica de pe por um fio -- e ela ESTOURA.")
	view(src) << output("<font color=#e07a9a><b>A aura de [src] estoura numa DESTRUCTION EXPLOSION!</b></font>", "Chatpane.Chat")
	chatcast(view(src), "<font color=#e07a9a><b>A aura de [src] estoura numa DESTRUCTION EXPLOSION!</b></font>", "combat")
	spawn ue_destruction_explosion()
	return 1

mob/proc/ue_destruction_explosion()
	var/dmg = ue_last_hit * (UE_EXP_BASE + ue_eff_energy(src) * UE_EXP_PER_EN) * ue_kit_factor(src) / 100
	createShockwavemisc(loc, 3)
	emit_Sound('scouterexplode.ogg')
	flick('flashtrans.dmi', src)
	if(dmg <= 0) return
	for(var/mob/V in oview(UE_EXP_RANGE, src))
		if(V.dead || !V.attackable) continue
		V.lastDamager = src
		damage_m(V, dmg, "torso", murderToggle, 2)
		V.refresh_combat_tag()
	createCrater(loc, 2)

// ---------------------------------------------------------------------------
// UNBOUND EGO -- BP por membro ferido (recalculado no tick; powerlevel le ue_ego_mult)
// ---------------------------------------------------------------------------
mob/proc/ue_ego_update()
	if(ue_eff_real(src) < UE_UNLOCK_EGO || !ue_aura_on(src))
		ue_ego_mult = 1
		return
	var/f = ue_kit_factor(src)
	var/mult = 0
	var/parts = 0
	var/peaks = 0
	for(var/datum/Body/B in body)
		if(istype(B, /datum/Body/Tail)) continue //a cauda fica de fora (o spec conta bracos/pernas/cabeca/torso)
		parts++
		if(B.lopped || B.health <= 0) continue //quebrado/decepado: o bonus daquele membro se perde
		var/missing = 1 - B.health / max(B.maxhealth, 1)
		mult += min(missing / UE_EGO_PEAK_MISSING, 1) * UE_EGO_PART_MAX / 100
		if(missing >= UE_EGO_PEAK_MISSING) peaks++
	if(parts && peaks >= parts) //TODOS os membros no pico (e nenhum quebrado)
		mult += UE_EGO_ALL_BONUS / 100
		if(!ue_restore_used)
			ue_restore_used = 1
			Ki = min(Ki + MaxKi * UE_EGO_RESTORE * f / 100, MaxKi)
			stamina = min(stamina + maxstamina * UE_EGO_RESTORE * f / 100, maxstamina)
			to_chat(src, "<font color=#f2b9cb><b>UNBOUND EGO no limite!</b> A dor vira poder puro -- Ki e Stamina restaurados!")
			view(src) << output("<font color=#e07a9a>[src] sorri em meio aos ferimentos -- a aura de destruicao INCHA!</font>", "Chatpane.Chat")
			chatcast(view(src), "<font color=#e07a9a>[src] sorri em meio aos ferimentos -- a aura de destruicao INCHA!</font>", "combat")
	ue_ego_mult = 1 + mult * f

// ---------------------------------------------------------------------------
// TICK (GlobalStats, ~0.3s): dreno, recuperacao, crescimento, Unbound Ego
// ---------------------------------------------------------------------------
mob/proc/ue_tick()
	if(!ue_has_kit(src)) return
	//1) uso drena a energia ATUAL (kit emprestado do GoD do Instinto: drena a PRECISAO do UI)
	if(ue_learned)
		if(ue_form) ue_energy = max(ue_energy - UE_DRAIN_FORM * UE_TICKSECS, 0)
		else if(ue_active) ue_energy = max(ue_energy - UE_DRAIN_ACTIVE * UE_TICKSECS, 0)
	else if(ue_active)
		ui_prof = max(ui_prof - UE_DRAIN_ACTIVE * UE_TICKSECS, 0)
	//2) energia REAL cresce com uso EM COMBATE (so quem trilha o path)
	if(ue_learned && (ue_active || ue_form) && (combatTag || IsInFight))
		ue_real_gain(UE_REAL_PER_SEC * UE_TICKSECS)
	//3) recuperacao: NUNCA com tag de combate; devagar, so com tudo desligado
	if(!combatTag && !IsInFight)
		if(ue_deathsave_used) ue_deathsave_used = 0 //a luta acabou: o seguro re-arma
		if(ue_restore_used) ue_restore_used = 0
		if(ue_learned && !ue_active && !ue_form)
			if(ue_energy < ue_energy_real) ue_energy = min(ue_energy + UE_REGEN * UE_TICKSECS, ue_energy_real)
			else if(ue_energy > ue_energy_real) ue_energy = max(ue_energy - UE_REGEN * UE_TICKSECS, ue_energy_real)
	//4) formas: dreno de ki PERMANENTE (kit emprestado nao tem formas)
	if(ue_form)
		Ki -= MaxKi * ((ue_form == 2) ? UE_KI_DRAIN_U : UE_KI_DRAIN_D) / 100 * UE_TICKSECS
		if(Ki <= 1)
			Ki = 1
			to_chat(src, "<font color=#e07a9a>Seu ki se esgota -- o Ultra Ego desmorona.")
			ue_form_revert()
	//5) Unbound Ego: recalcula o multiplicador
	ue_ego_update()

// ---------------------------------------------------------------------------
// O VERB TOGGLE (Aura of Destruction)
// ---------------------------------------------------------------------------
obj/overlay/effects/ue_aura_pas //a aura da passiva ('god - grey.dmi' carmesim)
	icon = 'god - grey.dmi'
	color = rgb(200, 60, 90)
	temporary = 0

mob/keyable/verb/Power_of_Destruction()
	set category = "Skills"
	set name = "Power of Destruction"
	if(!ue_has_kit(usr)) return
	if(usr.ue_form)
		to_chat(usr, "<font color=#e07a9a>Transformado, a destruicao ja reveste seu corpo por completo.")
		return
	usr.ue_active = !usr.ue_active
	if(usr.ue_active)
		usr.updateOverlay(/obj/overlay/effects/ue_aura_pas)
		to_chat(usr, "<font color=#e07a9a><b>Voce se reveste na AURA OF DESTRUCTION.</b> Energia atual: [round(ue_eff_energy(usr), 1)]% (drena com o uso; desligue para preservar).[usr.ue_learned ? "" : " <font color=#c060ff>(canalizada pelo titulo a [GOD_PATH_BORROW * 100]% de eficiencia)</font>"]")
		to_chat(view(usr), "<font color=#e07a9a>Uma aura carmesim e faminta se acende em volta de [usr]...</font>")
	else
		usr.removeOverlay(/obj/overlay/effects/ue_aura_pas)
		usr.ue_ego_mult = 1
		to_chat(usr, "<font color=#e07a9a>Voce recolhe a aura, preservando a energia ([round(ue_eff_energy(usr), 1)]%).")

// ---------------------------------------------------------------------------
// FORMAS: Destroyer (60x) e Ultra Ego (66x)
// ---------------------------------------------------------------------------
obj/overlay/effects/ue_aura_destroyer //roxo profundo da Destroyer Form
	icon = 'god - grey.dmi'
	color = rgb(140, 55, 215)
	temporary = 0

obj/overlay/effects/ue_aura_ultra //roxo vivo do Ultra Ego
	icon = 'god - grey.dmi'
	color = rgb(180, 85, 255)
	temporary = 0

obj/overlay/hairs/uepurple //cabelo do Ultra Ego: o BASE do jogador tingido de roxo
	name = "ultra ego hair"
	EffectStart()
		icon = container.hair
		icon += rgb(140, 50, 190)
		..()

//chamado pelo AddHair() quando ue_form esta ativo (HairObject.dm)
//SO o ULTRA EGO pinta o cabelo de roxo -- a Destroyer Form mantem o cabelo base
//(a maior diferenca visual entre as duas formas: cabelo + cinematica de ativacao)
mob/proc/ue_apply_hair()
	if(!hair) return //careca continua careca
	if(ue_form == 2) updateOverlay(/obj/overlay/hairs/uepurple)
	else updateOverlay(/obj/overlay/hairs/hair)

// ---------------------------------------------------------------------------
// CINEMATICA DO PRIMEIRO ULTRA EGO: receita do despertar do UI, em ROXO --
// aura grande purpura + o efeito 'UI Powerup.dmi' TINGIDO de roxo no corpo.
// A Destroyer Form NAO tem isto (so o surto rapido): cabelo + cinematica sao
// a diferenca visual entre as duas formas.
// ---------------------------------------------------------------------------
var/icon/ue_purple_aura_cache
proc/ue_purple_aura_icon() //'Aurabigcombined.dmi' tintada de roxo (cache)
	if(!ue_purple_aura_cache)
		ue_purple_aura_cache = icon('Aurabigcombined.dmi')
		ue_purple_aura_cache.Blend(rgb(165, 70, 255), ICON_MULTIPLY)
	return ue_purple_aura_cache

mob/proc/ue_grand_cinematic()
	var/turf/Td
	var/image/I
	var/image/P
	var/obj/A
	var/cyc
	var/q
	var/amount
	move = 0
	dir = SOUTH
	emit_TransformMusic(file("Sounds/Music/UE forms/Ultra ego/Dragon Ball Super Granolah Arc   Ultra Ego, Unbound   By Gladius.mp3"), UE_ULTRA_MUSIC_DS)
	emit_Sound('rockmoving.wav')
	to_chat(view(src), "<font color=#c98ae8>*O ar em volta de [src] PESA... a energia da destruicao vaza do corpo dele como calor de forja, e o chao comeca a rachar.*", "combat")
	for(cyc = 1 to 12) //build (~12s): poeira + raios + tremores crescendo
		for(q = 1 to 3)
			Td = locate(x + rand(-8,8), y + rand(-8,8), z)
			if(Td && !Td.density) createDustmisc(Td,2)
		if(prob(50))
			Td = locate(x + rand(-7,7), y + rand(-7,7), z)
			if(Td && !Td.density) createDustmisc(Td,3)
		if(prob(45))
			Td = locate(x + rand(-8,8), y + rand(-8,8), z)
			if(Td) createLightningmisc(Td, pick(2,4,5,9))
		if(cyc % 4 == 0) spawn Quake()
		sleep(10)
	I = image(icon = ue_purple_aura_icon()) //surto (~10s): aura grande ROXA + UI Powerup roxo no corpo + feixes de chao
	I.plane = 7
	overlayList += I
	P = image(icon = 'UI Powerup.dmi')
	P.pixel_x = -44 //efeito de 120px de largura centralizado no tile de 32
	P.plane = 7
	P.color = rgb(180, 85, 255) //o MESMO efeito do UI, pintado de roxo
	overlayList += P
	overlaychanged = 1
	emit_Sound('chargeaura.wav')
	to_chat(view(src), "<font color=#c98ae8>*Uma coluna de luz PURPURA irrompe de [src] -- a propria destruicao tomando forma!*", "combat")
	Quake()
	spawn Quake()
	amount = 8
	while(amount)
		A = new/obj
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
	for(cyc = 1 to 10)
		for(q = 1 to 4)
			Td = locate(x + rand(-8,8), y + rand(-8,8), z)
			if(Td && !Td.density) createDustmisc(Td, pick(2,2,2,3))
		if(prob(50))
			Td = locate(x + rand(-9,9), y + rand(-9,9), z)
			if(Td) createLightningmisc(Td, pick(3,5,9))
		if(cyc % 3 == 0) spawn Quake()
		sleep(10)
	to_chat(view(8), "<font size=[TextSize]><[SayColor]>[src]: HAAAAAAAAAH!!!") //climax: o EGO nao conhece silencio
	createShockwavemisc(loc, 3)
	for(q = 1 to 10)
		Td = locate(x + rand(-6,6), y + rand(-6,6), z)
		if(Td && !Td.density) createDustmisc(Td, pick(2,2,3))
	emit_Sound('aura.wav')
	overlayList -= I
	overlayList -= P
	overlaychanged = 1
	to_chat(view(src), "<font color=#f2b9cb><b>*O cabelo de [src] queima em purpura -- o ULTRA EGO encara o mundo com um sorriso.*</b>", "combat")
	createShockwavemisc(loc, 2)
	createCrater(loc, 3)
	move = 1

mob/proc/ue_form_revert()
	if(isBuffed(/obj/buff/UltraEgo)) stopbuff(/obj/buff/UltraEgo)
	else if(ue_form && !LoggingOut) ue_form = 0 //estado orfao (sem buff): limpa

mob/keyable/verb/Ultra_Ego_Form()
	set category = "Skills"
	set name = "Ultra Ego Transform"
	if(!usr.ue_learned || usr.ue_transing) return
	if(usr.ue_form)
		usr.ue_form_revert()
		return
	var/stage = 1
	if(usr.ue_energy_real >= UE_UNLOCK_ULTRA) //com o Ultra Ego destravado o verb pergunta; o C duplo vai direto na melhor
		var/c = input(usr, "Qual forma?", "Ultra Ego") as null|anything in list("Destroyer Form ([UE_MULT_DESTROYER]x)", "Ultra Ego ([UE_MULT_ULTRA]x)")
		if(!c || usr.ue_form || usr.dead || usr.KO) return
		if(findtext(c, "Ultra Ego")) stage = 2
	usr.ue_transform_to(stage)

mob/proc/ue_quick_transform() //C DUPLO: direto na MELHOR forma destravada
	ue_transform_to((ue_energy_real >= UE_UNLOCK_ULTRA) ? 2 : 1)

//nucleo da transformacao (verb com menu e C duplo caem aqui)
mob/proc/ue_transform_to(stage)
	if(!ue_learned || ue_transing || ue_form) return
	if(dead || KO || med || train) return
	if(ue_energy_real < UE_UNLOCK_DESTROYER)
		to_chat(src, "Sua energia REAL ([round(ue_energy_real, 1)]%) ainda nao alcanca a Destroyer Form ([UE_UNLOCK_DESTROYER]%). Use a Aura of Destruction em combate para evoluir.")
		return
	if(stage == 2 && ue_energy_real < UE_UNLOCK_ULTRA) stage = 1
	if(Ki < MaxKi * 0.2)
		to_chat(src, "Ki insuficiente -- o Ultra Ego drena energia continuamente (minimo 20% do maximo).")
		return
	if(isBuffed(/obj/buff/GodFury))
		to_chat(src, "<font color=#e07a9a>A Furia do Deus ja canaliza a destruicao -- recolha-a primeiro.")
		return
	if(ui_form) ui_form_revert() //instinto e ego nao coexistem
	if(ssj || lssj || ssjBuff != 1 || transBuff != 1) //EXCLUSIVO: derruba a forma racial antes (SSJ Blue etc.)
		to_chat(view(src), "<font color=#e07a9a>[src] abandona a forma anterior -- a aura muda por completo...</font>")
		Revert()
	if(stage == 2 && !ue_ultra_cine) //o PRIMEIRO Ultra Ego: cinematica grande + tema (a Destroyer nao tem)
		ue_ultra_cine = 1
		ue_transing = 1
		ue_grand_cinematic()
		ue_transing = 0
		if(dead || KO) return
	if(stage == 1 && !ue_destroyer_theme) //tema da PRIMEIRA Destroyer Form (uma unica vez na vida)
		ue_destroyer_theme = 1
		emit_TransformMusic(file("Sounds/Music/UE forms/Destroyer/Dragon Ball Z Dokkan Battle PHY God of Destruction Toppo Active Skill OST (High Quality).mp3"), UE_DESTROYER_MUSIC_DS)
	ue_form = stage
	ue_energy = (stage == 2) ? UE_ENERGY_U_START : UE_ENERGY_D_START //a forma RENOVA a energia
	startbuff(/obj/buff/UltraEgo, 'SSJIcon.dmi')

//multiplicador da forma: o GoD que trilha a DESTRUICAO tem as formas amplificadas em 25%
proc/ue_form_mult(mob/M, stage)
	var/base = (stage == 2) ? UE_MULT_ULTRA : UE_MULT_DESTROYER
	if(M && M.ue_learned && god_is_god(M)) base *= 1 + GOD_PATH_BOOST
	return base

obj/buff/UltraEgo
	name = "Ultra Ego"
	slot = sFORM
	Buff()
		..()
		container.formsBuff = ue_form_mult(container, container.ue_form)
		flick('flashtrans.dmi', container)
		container.removeOverlay(/obj/overlay/effects/ue_aura_pas) //a aura da passiva da lugar a da forma
		container.updateOverlay((container.ue_form == 2) ? /obj/overlay/effects/ue_aura_ultra : /obj/overlay/effects/ue_aura_destroyer)
		container.RemoveHair()
		container.AddHair() //AddHair ve o ue_form e aplica o cabelo roxo (ue_apply_hair)
		container.emit_Sound('1aura.wav')
		if(container.ue_form == 2)
			to_chat(view(container), "<font color=#f2b9cb><b>[container] desperta o ULTRA EGO!</b> Uma aura magenta pulsa com fome de batalha -- a dor so o fara mais forte.")
		else
			to_chat(view(container), "<font color=#e07a9a><b>[container] assume a DESTROYER FORM!</b> A energia da destruicao reveste seu corpo em purpura.")
	Loop()
		if(!container.ue_form)
			DeBuff()
		else
			container.formsBuff = ue_form_mult(container, container.ue_form) //re-afirma o multiplicador
			if(container.ssjBuff != 1 || container.transBuff != 1 || container.ui_form) //racial ou UI por cima: nao empilha
				to_chat(container, "<font color=#e07a9a>A outra transformacao expulsa o Ultra Ego.")
				DeBuff()
		..()
	DeBuff()
		container.formsBuff = 1
		container.removeOverlay(/obj/overlay/effects/ue_aura_destroyer)
		container.removeOverlay(/obj/overlay/effects/ue_aura_ultra)
		container.ue_ego_mult = 1
		if(!container.LoggingOut) //no logout a forma PERSISTE (padrao Legendary): so a queda real zera
			container.ue_form = 0
			container.RemoveHair()
			container.AddHair() //cabelo base de volta
			to_chat(container, "<font color=#e07a9a>O Ultra Ego se recolhe.")
		..()

// ---------------------------------------------------------------------------
// HAKAI INFUSION -- ki attacks infundidos por 1 min
// ---------------------------------------------------------------------------
mob/keyable/verb/Hakai_Infusion()
	set category = "Skills"
	set name = "Hakai Infusion"
	if(!ue_has_kit(usr)) return
	if(ue_eff_real(usr) < UE_UNLOCK_HKI)
		to_chat(usr, "Hakai Infusion exige [UE_UNLOCK_HKI]% de energia real (voce: [round(ue_eff_real(usr), 1)]%).")
		return
	if(usr.dead || usr.KO || usr.med || usr.train) return
	if(usr.ue_infuse_until > world.time)
		to_chat(usr, "Seus ataques ja estao infundidos ([round((usr.ue_infuse_until - world.time) / 10)]s restantes).")
		return
	if(world.time < usr.ue_infuse_cd)
		to_chat(usr, "Hakai Infusion em recarga ([round((usr.ue_infuse_cd - world.time) / 10)]s).")
		return
	var/kicost = usr.MaxKi * UE_HKI_KI_PCT / 100
	if(usr.Ki < kicost)
		to_chat(usr, "Ki insuficiente ([UE_HKI_KI_PCT]% do maximo).")
		return
	usr.Ki -= kicost
	usr.ue_infuse_until = world.time + UE_HKI_DUR
	usr.ue_infuse_cd = usr.ue_infuse_until + UE_HKI_CD //recarga conta do FIM
	flick('flashtrans.dmi', usr)
	to_chat(usr, "<font color=#f2b9cb><b>HAKAI INFUSION!</b> Por 1 minuto seus ataques de ki carregam a energia da destruicao: +penetracao, dificil de defletir, e beams DEVORAM rivais em disputa.")
	to_chat(view(usr), "<font color=#e07a9a>As maos de [usr] passam a verter uma luz purpura e faminta...</font>")

//DISPUTA DE BEAMS: pulso de 5s do lado infundido (chamado do clash_loop; knobs moram AQUI)
proc/ue_clash_tick(datum/beamclash/C, t)
	if(!C || t % 50 != 0) return //a cada 5s (50 ticks) de disputa
	var/mob/A = C.A
	var/mob/B = C.B
	if(!A || !B) return
	var/ainf = (A.ue_infuse_until > world.time)
	var/binf = (B.ue_infuse_until > world.time)
	if(ainf == binf) return //ninguem (ou os dois): sem dreno liquido
	var/mob/W = ainf ? A : B
	var/mob/L = ainf ? B : A
	var/f = ue_kit_factor(W) //GoD da Destruicao devora 25% mais; kit emprestado devora a 25%
	var/dreno = L.MaxKi * UE_HKI_CLASH_KI * f
	L.Ki = max(L.Ki - dreno, 0)
	W.Ki = min(W.Ki + dreno / 2, W.MaxKi) //metade do ki devorado alimenta o infundido
	C.meter += (ainf ? 1 : -1) * UE_HKI_CLASH_PUSH * f
	C.meter = min(max(C.meter, 0), 100)
	to_chat(W, "<font color=#f2b9cb>Seu Hakai DEVORA o beam de [L.name]!")
	to_chat(L, "<font color=#e07a9a><b>O beam infundido de [W.name] esta devorando o seu!</b> EMPURRE!")
