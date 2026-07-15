// ============================================================================
// ULTRA INSTINCT -- a tecnica dos Anjos (convertida do jogo antigo do dono).
//
//  APRENDIZADO (cadeia de ensino):
//   - So aprende quem for ENSINADO por um Anjo (o rank Angel sempre possui o
//     Ultra Instinto) ou por alguem que aprendeu na cadeia. Verb "Ensinar
//     Ultra Instinct" (adjacente). Requisito do aluno: God Ki tier 1+.
//
//  DUAS PROFICIENCIAS:
//   - REAL (ui_prof_real 0-100): a maestria permanente. Cresce por USO EM
//     COMBATE (tag de combate com a skill/forma ativa + bonus por esquiva
//     bem-sucedida). Destrava as habilidades por faixa:
//       0%+  Autonomous Evasion (a passiva do verb toggle)
//       20%+ Ultra Instinct -Sign-        (forma 60x)
//       40%+ Accelerated Battle           (esquiva TAMBEM enquanto carrega ki)
//       60%+ Perfected Ultra Instinct     (forma 66x)
//       80%+ Godly Display                (ativa: dash que marca + rajada)
//   - ATUAL (ui_prof 0-100): a precisao do momento -- e o que ESCALA a chance
//     de esquiva. DRENA com a passiva ligada e nas formas (o instinto cansa o
//     corpo: quanto mais longa a luta, menos preciso). NAO recupera com tag de
//     combate; fora de combate recupera bem devagar (so com a passiva
//     desligada e fora de forma), ate o teto da REAL.
//
//  FORMAS (exclusivas com formas raciais -- ativar UI reverte SSJ/racial e
//  vice-versa; a PASSIVA, por outro lado, funciona em QUALQUER forma):
//   - Sign 60x / Perfected 66x, dreno de ki PERMANENTE, e transformar RENOVA
//     a precisao atual (Sign -> 80%, Perfected -> 100%), que decai dali.
//
//  Persistencia: ui_learned/ui_prof_real/ui_prof/ui_form sao vars normais do
//  mob (entram no save do personagem); verbs re-atribuidos no login.
// ============================================================================

// ============================== CONFIG ======================================
#define UI_MULT_SIGN 60           //multiplicador do Ultra Instinct -Sign-
#define UI_MULT_PERF 66           //multiplicador do Perfected Ultra Instinct
#define UI_PROF_SIGN_START 80     //precisao ATUAL ao entrar no Sign
#define UI_PROF_PERF_START 100    //precisao ATUAL ao entrar no Perfected
#define UI_UNLOCK_SIGN 20         //maestria REAL que destrava o Sign
#define UI_UNLOCK_ACCEL 40        //destrava Accelerated Battle (esquiva durante carga de ki)
#define UI_UNLOCK_PERF 60         //destrava o Perfected
#define UI_UNLOCK_GD 80           //destrava o Godly Display
#define UI_EVADE_MELEE_PCT 0.45   //chance de esquiva automatica = precisao atual x isto (melee; 100% = 45%)
#define UI_EVADE_BLAST_PCT 0.30   //idem contra ataques de ki (100% = 30%)
#define UI_EVADE_BONUS 0.05       //+5% de Tphysoff e Tspeed por esquiva (5s, empilha)
#define UI_EVADE_BUFF_TICKS 50    //duracao de cada pilha do bonus (5s)
#define UI_EVADE_STACK_MAX 5      //teto de pilhas simultaneas
#define UI_DRAIN_ACTIVE 0.5       //precisao ATUAL perdida por SEGUNDO com a passiva ligada (fora de forma)
#define UI_DRAIN_FORM 0.35        //precisao ATUAL perdida por segundo TRANSFORMADO
#define UI_REGEN_PROF 0.25        //precisao recuperada por segundo FORA de combate (passiva desligada, sem forma)
#define UI_REAL_PER_SEC 0.04      //maestria REAL por segundo de uso em combate (~40min de luta = 100%)
#define UI_REAL_PER_EVADE 0.2     //maestria REAL por esquiva automatica bem-sucedida
#define UI_KI_DRAIN_SIGN 0.35     //% do MaxKi drenada por segundo no Sign (dreno permanente)
#define UI_KI_DRAIN_PERF 0.5      //idem no Perfected
#define UI_GD_RANGE 10            //alcance do dash do Godly Display (tiles)
#define UI_GD_MARK_TICKS 50       //duracao da marca e da janela do 2o cast (5s)
#define UI_GD_HITS 10             //golpes leves divididos entre os marcados
#define UI_GD_HIT_MULT 0.5        //dano de cada golpe = NormDamageCalc x isto
#define UI_GD_BLOCK_MULT 0.35     //bloquear protege dos GOLPES (dano x isto) -- mas nao da marca do avanco
#define UI_GD_KI_PCT 8            //custo em % do MaxKi -- SO no segundo cast
#define UI_GD_PROF_COST 10        //precisao ATUAL consumida no segundo cast
#define UI_GD_CD 600              //cooldown (1 min) apos a rajada OU a janela expirar
#define UI_TICKSECS 0.3           //duracao aproximada de 1 ciclo do GlobalStats (sleep(3))
#define UI_OMEN_MUSIC_DS 2400     //janela (4min) do tema do despertar: ducka musica de combate/rage pelo periodo
#define UI_PERF_MUSIC_DS 2400     //janela do tema do PRIMEIRO Perfected Ultra Instinct
// ============================ FIM DO CONFIG =================================

mob/var
	ui_learned = 0     //aprendeu o Ultra Instinto (persiste no save)
	ui_prof_real = 0   //maestria REAL 0-100 (persiste; destrava habilidades)
	ui_prof = 0        //precisao ATUAL 0-100 (persiste; drena com uso)
	ui_form = 0        //0 = base | 1 = Sign | 2 = Perfected (persiste: relog mantem a forma)
	ui_omen_cine = 0   //cinematica do DESPERTAR (1a vez no Sign) ja vista (persiste)
	ui_perf_theme = 0  //tema do PRIMEIRO Perfected ja tocado (persiste)
mob/var/tmp
	ui_active = 0          //passiva (Autonomous Evasion) ligada
	ui_evade_stacks = 0    //pilhas do bonus pos-esquiva vivas
	ui_evade_msg_cd = 0    //anti-spam das falas de esquiva de ki
	ui_transing = 0        //latch da cinematica de transformacao
	ui_gd_window = 0       //ate quando vale o 2o cast do Godly Display
	ui_gd_cd = 0           //cooldown do Godly Display
	ui_gd_marked_until = 0 //ate quando ESTE mob esta marcado por um Godly Display
	list/ui_gd_marks = null

// ---------------------------------------------------------------------------
// Aprendizado: verbs + login + ensino em cadeia
// ---------------------------------------------------------------------------
mob/proc/ui_give_verbs()
	verbs += /mob/keyable/verb/Ultra_Instinct
	verbs += /mob/keyable/verb/Ultra_Instinct_Form
	verbs += /mob/keyable/verb/Godly_Display
	verbs += /mob/keyable/verb/Ensinar_Ultra_Instinct
	Keyableverbs += /mob/keyable/verb/Ultra_Instinct
	Keyableverbs += /mob/keyable/verb/Ultra_Instinct_Form
	Keyableverbs += /mob/keyable/verb/Godly_Display

mob/proc/ui_login_check()
	if(Angel_Rank && Angel_Rank == signature && !ui_learned && !ue_learned) //o Anjo SEMPRE possui o Ultra Instinto (mas paths sao exclusivos: quem ja trilha a Destruicao nao recebe)
		ui_learned = 1
		to_chat(src, "<font color=#eef2ff><b>Como Anjo, o Ultra Instinto e parte de voce.</b> (verbs na aba Skills)")
	if(!ui_learned) return
	ui_prof_real = clamp(ui_prof_real, 0, 100)
	ui_prof = clamp(ui_prof, 0, 100)
	ui_give_verbs()
	if(ui_form && !isBuffed(/obj/buff/UltraInstinct)) //relogou transformado: re-veste a forma (padrao Legendary)
		startbuff(/obj/buff/UltraInstinct, 'SSJIcon.dmi')

mob/keyable/verb/Ensinar_Ultra_Instinct()
	set category = "Other"
	set name = "Ensinar Ultra Instinct"
	var/mob/T2 = usr
	if(!T2.ui_learned) return
	if(T2.dead || T2.KO) return
	var/list/cands = list()
	for(var/mob/P in oview(1, T2))
		if(P.client && !P.dead && !P.KO && !P.ui_learned) cands += P
	if(!cands.len)
		to_chat(T2, "Nenhum discipulo elegivel ao seu lado (adjacente, vivo, sem o Ultra Instinto).")
		return
	var/mob/S = input(T2, "Ensinar o Ultra Instinto a quem?", "Ultra Instinct") as null|anything in cands
	if(!S || !S.client || S.ui_learned || get_dist(T2, S) > 1) return
	if(S.ue_learned) //PATHS EXCLUSIVOS: quem trilha a Destruicao nao pode trilhar o Instinto
		to_chat(T2, "<font color=#cfd8ff>[S] ja trilha o caminho do ULTRA EGO -- os dois paths nao coexistem num mesmo corpo.")
		to_chat(S, "<font color=#cfd8ff>Seu corpo ja pertence a Destruicao. O Instinto jamais o aceitara.")
		return
	if(!S.godki || S.godki.tier < 1) //corpo mortal nao suporta o instinto dos anjos
		to_chat(T2, "<font color=#cfd8ff>[S] ainda nao sente o Ki Divino -- o corpo mortal nao suporta o instinto dos anjos (God Ki tier 1+).")
		to_chat(S, "<font color=#cfd8ff>Voce ainda nao esta pronto para o Ultra Instinto: desperte o Ki Divino primeiro.")
		return
	switch(alert(S, "[T2.name] se oferece para te ensinar o ULTRA INSTINTO -- a tecnica dos Anjos. Aceitar o treinamento?", "Ultra Instinct", "Aceitar", "Recusar"))
		if("Recusar")
			to_chat(T2, "[S] recusou o treinamento.")
			return
	if(!S || !T2 || S.ui_learned || get_dist(T2, S) > 1) return
	to_chat(view(T2), "<font color=#cfd8ff><b>[T2] guia [S] no caminho do Ultra Instinto...</b> \"Esvazie a mente. Deixe o corpo lutar por voce.\"")
	sleep(50)
	if(!S || !T2 || S.ui_learned) return
	S.ui_learned = 1
	S.ui_give_verbs()
	to_chat(S, "<font color=#eef2ff><b>Voce aprendeu o ULTRA INSTINTO!</b> Ative a Esquiva Autonoma pelo verb Ultra Instinct (aba Skills). A maestria cresce com o USO em combate.")
	to_chat(T2, "<font color=#cfd8ff>[S] agora carrega o instinto dos anjos -- e tambem podera ensinar.")
	WriteToLog("rplog","[T2] ensinou Ultra Instinct a [S]   ([time2text(world.realtime,"Day DD hh:mm")])")

// ---------------------------------------------------------------------------
// Maestria REAL: ganho + anuncios de destravamento
// ---------------------------------------------------------------------------
mob/proc/ui_real_gain(amount)
	if(ui_prof_real >= 100 || amount <= 0) return
	var/before = ui_prof_real
	ui_prof_real = min(ui_prof_real + amount, 100)
	if(before < UI_UNLOCK_SIGN && ui_prof_real >= UI_UNLOCK_SIGN)
		to_chat(src, "<font color=#eef2ff><b>ULTRA INSTINCT -SIGN- destravado!</b> ([UI_UNLOCK_SIGN]% de maestria) Use Ultra Instinct Transform.")
	if(before < UI_UNLOCK_ACCEL && ui_prof_real >= UI_UNLOCK_ACCEL)
		to_chat(src, "<font color=#eef2ff><b>ACCELERATED BATTLE destravado!</b> ([UI_UNLOCK_ACCEL]%) Seu corpo agora esquiva ATE enquanto voce carrega ataques de ki.")
	if(before < UI_UNLOCK_PERF && ui_prof_real >= UI_UNLOCK_PERF)
		to_chat(src, "<font color=#eef2ff><b>PERFECTED ULTRA INSTINCT destravado!</b> ([UI_UNLOCK_PERF]%)")
	if(before < UI_UNLOCK_GD && ui_prof_real >= UI_UNLOCK_GD)
		to_chat(src, "<font color=#eef2ff><b>GODLY DISPLAY destravado!</b> ([UI_UNLOCK_GD]%) Dash que marca inimigos + rajada dividida (verb na aba Skills).")

// ---------------------------------------------------------------------------
// ESQUIVA AUTONOMA -- o nucleo. Chamada pelos ganchos de melee (hitProc) e de
// ki (colisao de blast). Retorna 1 = o ataque foi evitado.
// ---------------------------------------------------------------------------
proc/ui_try_evade(mob/M, kind)
	if(!M || !M.ui_learned) return 0
	if(M.KO || M.dead) return 0
	if(!M.ui_active && !M.ui_form) return 0 //passiva desligada e fora de forma: nada
	if(M.med || M.train) return 0
	if(M.blocking) return 0 //quem BLOQUEIA se comprometeu com a guarda -- o corpo nao desvia
	//ACCELERATED BATTLE: sem ela, carregar um ataque de ki te deixa exposto
	if((M.charging || M.beaming || M.genki_charging) && M.ui_prof_real < UI_UNLOCK_ACCEL) return 0
	var/chance = M.ui_prof * (kind == "blast" ? UI_EVADE_BLAST_PCT : UI_EVADE_MELEE_PCT)
	if(!prob(chance)) return 0
	M.ui_evade_stack()
	M.ui_real_gain(UI_REAL_PER_EVADE) //o reflexo bem-sucedido ensina o corpo
	return 1

//bonus temporario por esquiva: +5% Tphysoff/Tspeed por 5s, empilhando (remocao exata)
mob/proc/ui_evade_stack()
	if(ui_evade_stacks >= UI_EVADE_STACK_MAX) return
	ui_evade_stacks++
	var/doff = Ephysoff * UI_EVADE_BONUS
	var/dspd = Espeed * UI_EVADE_BONUS
	Tphysoff += doff
	Tspeed += dspd
	spawn(UI_EVADE_BUFF_TICKS)
		if(src)
			Tphysoff -= doff
			Tspeed -= dspd
			ui_evade_stacks = max(ui_evade_stacks - 1, 0)

//visual da esquiva de ki: zanzoken + passo lateral (mesma semantica do desvio de deflect)
proc/ui_blast_evade_fx(mob/M, obj/attack/A)
	if(!M) return
	flick('Zanzoken.dmi', M)
	if(A)
		M.dir = A.dir
		M.dir = pick(turn(M.dir, 135), turn(M.dir, -135))
		step(M, M.dir)
	if(world.time >= M.ui_evade_msg_cd)
		M.ui_evade_msg_cd = world.time + 30
		view(M) << output("<font color=#cfd8ff>O corpo de [M] se move sozinho -- o ataque corta o vazio!</font>", "Chatpane.Chat")
		chatcast(view(M), "<font color=#cfd8ff>O corpo de [M] se move sozinho -- o ataque corta o vazio!</font>", "combat")

// ---------------------------------------------------------------------------
// TICK (GlobalStats, ~0.3s): dreno, recuperacao e crescimento por uso
// ---------------------------------------------------------------------------
mob/proc/ui_instinct_tick()
	if(!ui_learned) return
	//1) uso drena a precisao ATUAL (o instinto cansa o corpo)
	if(ui_form) ui_prof = max(ui_prof - UI_DRAIN_FORM * UI_TICKSECS, 0)
	else if(ui_active) ui_prof = max(ui_prof - UI_DRAIN_ACTIVE * UI_TICKSECS, 0)
	//2) maestria REAL cresce com uso EM COMBATE
	if((ui_active || ui_form) && (combatTag || IsInFight))
		ui_real_gain(UI_REAL_PER_SEC * UI_TICKSECS)
	//3) recuperacao: NUNCA com tag de combate; devagar, so com tudo desligado (ue_active: o kit emprestado do GoD drena a MESMA precisao)
	if(!combatTag && !IsInFight && !ui_active && !ui_form && !ue_active)
		if(ui_prof < ui_prof_real) ui_prof = min(ui_prof + UI_REGEN_PROF * UI_TICKSECS, ui_prof_real)
		else if(ui_prof > ui_prof_real) ui_prof = max(ui_prof - UI_REGEN_PROF * UI_TICKSECS, ui_prof_real) //o excesso da forma escoa de volta ao real
	//4) formas: dreno de ki PERMANENTE
	if(ui_form)
		Ki -= MaxKi * ((ui_form == 2) ? UI_KI_DRAIN_PERF : UI_KI_DRAIN_SIGN) / 100 * UI_TICKSECS
		if(Ki <= 1)
			Ki = 1
			to_chat(src, "<font color=#cfd8ff>Seu ki se esgota -- o corpo nao sustenta mais o instinto.")
			ui_form_revert()

// ---------------------------------------------------------------------------
// O VERB TOGGLE (Autonomous Evasion) -- "assim como brutal clarity etc"
// ---------------------------------------------------------------------------
mob/keyable/verb/Ultra_Instinct()
	set category = "Skills"
	set name = "Ultra Instinct"
	if(!usr.ui_learned) return
	if(usr.ui_form)
		to_chat(usr, "<font color=#cfd8ff>Transformado, o instinto ja guia seu corpo por completo.")
		return
	usr.ui_active = !usr.ui_active
	if(usr.ui_active)
		to_chat(usr, "<font color=#cfd8ff><b>Voce esvazia a mente -- o corpo passa a se mover sozinho.</b> Precisao atual: [round(usr.ui_prof, 1)]% (drena com o uso; desligue para preservar).")
		to_chat(view(usr), "<font color=#cfd8ff>Os olhos de [usr] ficam distantes e serenos...</font>")
	else
		to_chat(usr, "<font color=#cfd8ff>Voce recolhe o instinto, preservando a precisao ([round(usr.ui_prof, 1)]%).")

// ---------------------------------------------------------------------------
// FORMAS: Sign (60x) e Perfected (66x) -- exclusivas com formas raciais
// VISUAL (ambas): aura UIAurafixed + fagulhas UI_Dots + olhos prateados +
// cabelo -- estilo Goku vira o cabelo UI proprio; os demais ficam iguais a
// base no Sign e prateados no Perfected.
// ---------------------------------------------------------------------------
obj/overlay/effects/ui_aura //a aura do Ultra Instinto (ja colorida no .dmi)
	icon = 'UIAurafixed.dmi'
	temporary = 0

obj/overlay/effects/ui_dots //as fagulhas prateadas orbitando o corpo
	icon = 'UI_Dots.dmi'
	temporary = 0

//olhos cinza/prateados (icone do olho padrao banhado de prata; cache global)
var/icon/ui_eye_cache
proc/ui_eye_icon()
	if(!ui_eye_cache)
		ui_eye_cache = icon('Eyes_Black.dmi')
		ui_eye_cache.Blend(rgb(190, 196, 208), ICON_ADD)
	return ui_eye_cache

obj/overlay/eyes/ui_eyes
	ID = 31460
	name = "ui eyeballs"
	EffectStart()
		icon = ui_eye_icon()
		..()

//cabelos das formas (fora de /hairs/ssj de proposito: o tint de God Ki nao suja a prata)
obj/overlay/hairs/uisign //estilo Goku no -Sign-
	name = "ultra instinct hair"
	EffectStart()
		icon = 'Hair_UltraInstinct.dmi'
		..()

obj/overlay/hairs/uiperf //estilo Goku no Perfected
	name = "mastered ultra instinct hair"
	EffectStart()
		icon = 'Hair_MasteredUltraInstinct.dmi'
		..()

obj/overlay/hairs/uisilver //Perfected sem estilo Goku: o cabelo BASE banhado de prata
	name = "silvered hair"
	EffectStart()
		icon = container.hair
		icon += rgb(185, 190, 200)
		..()

//chamado pelo AddHair() quando ui_form esta ativo (HairObject.dm)
mob/proc/ui_apply_hair()
	if(!hair) return //careca continua careca
	if(hairtypeSaved == "Goku")
		updateOverlay((ui_form == 2) ? /obj/overlay/hairs/uiperf : /obj/overlay/hairs/uisign)
	else if(ui_form == 2)
		updateOverlay(/obj/overlay/hairs/uisilver)
	else
		updateOverlay(/obj/overlay/hairs/hair) //Sign: os outros estilos ficam iguais a base

//olhos: aplica/restaura (quem subiu olho custom mantem o proprio)
mob/proc/ui_apply_eyes()
	if(hascustomeye) return
	removeOverlay(/obj/overlay/eyes/default_eye)
	updateOverlay(/obj/overlay/eyes/ui_eyes)

mob/proc/ui_restore_eyes()
	removeOverlay(/obj/overlay/eyes/ui_eyes)
	if(!hascustomeye) RefreshEyes()

// ---------------------------------------------------------------------------
// CINEMATICA DO DESPERTAR (1a vez no -Sign-): receita da fd_grand_cinematic,
// com a aura grande AZULADA, o efeito UI Powerup no corpo e o tema do Omen.
// ---------------------------------------------------------------------------
var/icon/ui_blue_aura_cache
proc/ui_blue_aura_icon() //'Aurabigcombined.dmi' tintada de azul (cache: icon() decodifica o .dmi inteiro)
	if(!ui_blue_aura_cache)
		ui_blue_aura_cache = icon('Aurabigcombined.dmi')
		ui_blue_aura_cache.Blend(rgb(95, 145, 255), ICON_MULTIPLY)
	return ui_blue_aura_cache

mob/proc/ui_grand_cinematic()
	var/turf/Td
	var/image/I
	var/image/P
	var/obj/A
	var/cyc
	var/q
	var/amount
	move = 0
	dir = SOUTH
	emit_TransformMusic(file("Sounds/Music/Ui forms/omen/Ultimate Battle Theme Official Guitar Version - Full Song Montage Montaje.mp3"), UI_OMEN_MUSIC_DS)
	emit_Sound('rockmoving.wav')
	updateOverlay(/obj/overlay/effects/ui_dots)
	to_chat(view(src), "<font color=#aebfe8>*O ar em volta de [src] esfria... fagulhas prateadas comecam a flutuar, e o chao treme baixinho.*", "combat")
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
	I = image(icon = ui_blue_aura_icon()) //surto (~10s): aura grande AZUL + UI Powerup no corpo + feixes de chao
	I.plane = 7
	overlayList += I
	P = image(icon = 'UI Powerup.dmi')
	P.pixel_x = -44 //efeito de 120px de largura centralizado no tile de 32
	P.plane = 7
	overlayList += P
	overlaychanged = 1
	emit_Sound('chargeaura.wav')
	to_chat(view(src), "<font color=#aebfe8>*Uma coluna de luz azul-prateada engole [src] -- a pressao do ar dobra os joelhos de quem assiste!*", "combat")
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
	createShockwavemisc(loc, 3) //climax: a onda de choque... e o SILENCIO
	for(q = 1 to 10)
		Td = locate(x + rand(-6,6), y + rand(-6,6), z)
		if(Td && !Td.density) createDustmisc(Td, pick(2,2,3))
	emit_Sound('aura.wav')
	overlayList -= I
	overlayList -= P
	overlaychanged = 1
	to_chat(view(src), "<font color=#eef2ff><b>*... e entao, silencio. A poeira paira no ar. Os olhos de [src] se abrem -- prateados.*</b>", "combat")
	createShockwavemisc(loc, 2)
	createCrater(loc, 3)
	move = 1

mob/proc/ui_form_revert()
	if(isBuffed(/obj/buff/UltraInstinct)) stopbuff(/obj/buff/UltraInstinct)
	else if(ui_form && !LoggingOut) ui_form = 0 //estado orfao (sem buff): limpa

mob/keyable/verb/Ultra_Instinct_Form()
	set category = "Skills"
	set name = "Ultra Instinct Transform"
	if(!usr.ui_learned || usr.ui_transing) return
	if(usr.ui_form)
		usr.ui_form_revert()
		return
	if(usr.dead || usr.KO || usr.med || usr.train) return
	if(usr.ui_prof_real < UI_UNLOCK_SIGN)
		to_chat(usr, "Sua maestria ([round(usr.ui_prof_real, 1)]%) ainda nao alcanca o Ultra Instinct -Sign- ([UI_UNLOCK_SIGN]%). Use a Esquiva Autonoma em combate para evoluir.")
		return
	var/stage = 1
	if(usr.ui_prof_real >= UI_UNLOCK_PERF)
		var/c = input(usr, "Qual forma?", "Ultra Instinct") as null|anything in list("Ultra Instinct -Sign- ([UI_MULT_SIGN]x)", "Perfected Ultra Instinct ([UI_MULT_PERF]x)")
		if(!c || usr.ui_form || usr.dead || usr.KO) return
		if(findtext(c, "Perfected")) stage = 2
	if(usr.Ki < usr.MaxKi * 0.2)
		to_chat(usr, "Ki insuficiente -- o Ultra Instinto drena energia continuamente (minimo 20% do maximo).")
		return
	if(usr.ue_form) usr.ue_form_revert() //instinto e ego nao coexistem (UltraEgo.dm)
	if(usr.ssj || usr.lssj || usr.ssjBuff != 1 || usr.transBuff != 1) //EXCLUSIVO: derruba a forma racial antes
		to_chat(view(usr), "<font color=#cfd8ff>[usr] abandona a forma anterior -- a aura muda por completo...</font>")
		usr.Revert()
	if(!usr.ui_omen_cine) //o DESPERTAR: cinematica grande + tema do Omen, uma unica vez na vida
		usr.ui_omen_cine = 1
		usr.ui_transing = 1
		usr.ui_grand_cinematic()
		usr.ui_transing = 0
		if(!usr || usr.dead || usr.KO) //caiu no meio do despertar: limpa as fagulhas da cinematica
			if(usr) usr.removeOverlay(/obj/overlay/effects/ui_dots)
			return
	usr.ui_form = stage
	usr.ui_prof = (stage == 2) ? UI_PROF_PERF_START : UI_PROF_SIGN_START //a forma RENOVA a precisao
	if(stage == 2 && !usr.ui_perf_theme) //tema do PRIMEIRO Perfected Ultra Instinct (uma unica vez na vida)
		usr.ui_perf_theme = 1
		usr.emit_TransformMusic(file("Sounds/Music/Ui forms/Perfect/Dragon Ball Super Moro Arc   Ultra Instinct Perfected! (Norihito Sumitomo)   By Gladius.mp3"), UI_PERF_MUSIC_DS)
	usr.startbuff(/obj/buff/UltraInstinct, 'SSJIcon.dmi')

obj/buff/UltraInstinct
	name = "Ultra Instinct"
	slot = sFORM
	Buff()
		..()
		container.formsBuff = (container.ui_form == 2) ? UI_MULT_PERF : UI_MULT_SIGN
		flick('flashtrans.dmi', container)
		container.updateOverlay(/obj/overlay/effects/ui_aura)
		container.updateOverlay(/obj/overlay/effects/ui_dots)
		container.ui_apply_eyes() //olhos cinza/prateados em ambas as formas
		container.RemoveHair()
		container.AddHair() //AddHair ve o ui_form e aplica o cabelo da forma (ui_apply_hair)
		container.emit_Sound('1aura.wav')
		if(container.ui_form == 2)
			to_chat(view(container), "<font color=#eef2ff><b>[container] alcanca o ULTRA INSTINTO PERFEITO!</b> Cabelos e olhos prateados -- cada movimento e absoluto.")
		else
			to_chat(view(container), "<font color=#aebfe8><b>O instinto desperta em [container] -- ULTRA INSTINCT -SIGN-!</b> Seus olhos brilham em prata.")
	Loop()
		if(!container.ui_form)
			DeBuff()
		else
			container.formsBuff = (container.ui_form == 2) ? UI_MULT_PERF : UI_MULT_SIGN //re-afirma o multiplicador
			if(container.ssjBuff != 1 || container.transBuff != 1 || container.ue_form) //forma racial ou Ultra Ego por cima: UI NAO empilha
				to_chat(container, "<font color=#cfd8ff>A outra transformacao expulsa o estado de Ultra Instinto.")
				DeBuff()
		..()
	DeBuff()
		container.formsBuff = 1
		container.removeOverlay(/obj/overlay/effects/ui_aura)
		container.removeOverlay(/obj/overlay/effects/ui_dots)
		if(!container.LoggingOut) //no logout a forma PERSISTE (padrao Legendary): so a queda real zera
			container.ui_form = 0
			container.RemoveHair()
			container.AddHair() //cabelo base de volta
			container.ui_restore_eyes()
			to_chat(container, "<font color=#cfd8ff>O Ultra Instinto se dissipa.")
		..()

// ---------------------------------------------------------------------------
// GODLY DISPLAY -- dash que atravessa e marca; 2o cast desfere a rajada
// ---------------------------------------------------------------------------
mob/keyable/verb/Godly_Display()
	set category = "Skills"
	set name = "Godly Display"
	var/mob/U = usr
	if(!U.ui_learned) return
	if(U.ui_prof_real < UI_UNLOCK_GD)
		to_chat(U, "Godly Display exige [UI_UNLOCK_GD]% de maestria real (voce: [round(U.ui_prof_real, 1)]%).")
		return
	if(U.dead || U.KO || U.med || U.train || U.grabber) return
	if(!U.ui_active && !U.ui_form)
		to_chat(U, "Ative o Ultra Instinto primeiro.")
		return
	//SEGUNDO CAST dentro da janela: a rajada -- 10 golpes divididos entre os marcados
	if(world.time <= U.ui_gd_window && islist(U.ui_gd_marks))
		var/list/targets = list()
		for(var/mob/V in U.ui_gd_marks)
			if(V && V.loc && !V.dead && V.z == U.z && world.time <= V.ui_gd_marked_until && get_dist(U, V) <= 15) targets += V
		if(!targets.len)
			to_chat(U, "Nenhum alvo marcado ao alcance.")
			return
		var/kicost = U.MaxKi * UI_GD_KI_PCT / 100 //o custo SO existe no segundo cast
		if(U.Ki < kicost)
			to_chat(U, "Ki insuficiente ([UI_GD_KI_PCT]% do maximo).")
			return
		U.Ki -= kicost
		U.ui_prof = max(U.ui_prof - UI_GD_PROF_COST, 0) //a exibicao divina cobra do corpo
		U.ui_gd_window = 0
		U.ui_gd_marks = null
		U.ui_gd_cd = world.time + UI_GD_CD
		to_chat(view(U), "<font color=#eef2ff><b>[U] desaparece -- e o ceu desaba sobre seus inimigos!</b></font>")
		spawn U.ui_gd_flurry(targets)
		return
	//PRIMEIRO CAST: o avanco
	if(world.time < U.ui_gd_cd)
		to_chat(U, "Godly Display em recarga ([round((U.ui_gd_cd - world.time) / 10)]s).")
		return
	spawn U.ui_gd_rush()

mob/proc/ui_gd_rush()
	var/d = dir
	var/marked = 0
	ui_gd_marks = list()
	to_chat(view(src), "<font color=#cfd8ff><b>[src] avanca como um raio prateado!</b></font>")
	for(var/i = 1 to UI_GD_RANGE)
		var/turf/T = get_step(src, d)
		if(!T || T.density) break
		for(var/mob/V in T) //marca quem for ATRAVESSADO (bloquear NAO protege da marca)
			if(V == src || V.dead || !V.attackable) continue
			V.ui_gd_marked_until = world.time + UI_GD_MARK_TICKS
			ui_gd_marks |= V
			marked++
			to_chat(V, "<font color=#cfd8ff>Algo atravessa voce como um vulto -- [src] marcou seus movimentos!")
		loc = T //atravessa tudo, inclusive corpos
		if(i % 2) flick('Zanzoken.dmi', src)
		sleep(1)
	ui_gd_window = world.time + UI_GD_MARK_TICKS
	if(marked)
		to_chat(src, "<font color=#eef2ff>[marked] alvo\s marcado\s. Use Godly Display DE NOVO em ate 5s para desferir os [UI_GD_HITS] golpes.")
	else
		to_chat(src, "<font color=#cfd8ff>Ninguem no caminho do avanco.")
	spawn(UI_GD_MARK_TICKS + 2) //janela fechou sem o 2o cast: expira e entra em recarga (sem custo)
		if(src && ui_gd_window && world.time > ui_gd_window)
			ui_gd_window = 0
			ui_gd_marks = null
			ui_gd_cd = world.time + UI_GD_CD
			to_chat(src, "<font color=#cfd8ff>A janela do Godly Display se fecha.")

mob/proc/ui_gd_flurry(list/targets)
	if(!islist(targets) || !targets.len) return
	for(var/h = 1 to UI_GD_HITS)
		var/mob/V = targets[((h - 1) % targets.len) + 1]
		if(!V || !V.loc || V.dead || V.z != z) continue
		var/turf/T = get_step(V, pick(NORTH, SOUTH, EAST, WEST))
		if(T && !T.density) loc = T //teleporta ao lado do alvo a cada golpe
		dir = get_dir(src, V)
		flick('Zanzoken.dmi', src)
		var/dmg = NormDamageCalc(V) * UI_GD_HIT_MULT
		if(V.blocking) dmg *= UI_GD_BLOCK_MULT //bloquear protege dos golpes em si
		V.lastDamager = src
		damage_m(V, dmg, pick("torso", "torso", "head"), murderToggle, 2)
		V.refresh_combat_tag()
		refresh_combat_tag()
		sleep(1)
	updateOverlay(/obj/overlay/effects/flickeffects/attack)
