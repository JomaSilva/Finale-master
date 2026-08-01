// ============================================================================
// RANK QUESTS -- aquisicao SEM admin + deveres com prazo pra ~16 ranks.
//
//  AQUISICAO (verb "Reivindicar Rank"): rank VAGO + REQUISITOS tematicos
//  (karma/reputacao/raca/BP/God Ki/escada dos Kaios) -> PROVA: luta contra o
//  ESPIRITO DO CARGO (NPC invocado na hora, ~15% acima do seu poder expresso).
//  Vencer = o cargo e seu (anuncio mundial). Perder = cooldown.
//  (Rei de Vegeta continua pelo caminho proprio: matar o Rei NPC como Saiyajin.
//   GoD/Anjo tem sistemas proprios. O Autorank velho foi DELETADO.)
//
//  QUESTS (misto por vocacao, motor unico com prazo estilo GoD):
//   - PODER (Guardiao, Rei de Vegeta, President, Demon Lord, Makyo King,
//     Frost Demon Lord): libertar o planeta se a CONQUISTA o tomou; cacar
//     vilao (protetores) ou HEROI (lordes malignos); destruir planeta
//     procedural (Frost Lord); verba pro cofre da Terra (President).
//   - SABEDORIA (Turtle, Crane, Korin, Grande Anciao, 4 Kaios, Grand Kai,
//     Kaioshin, Yemma): SERVICO -- acumule pontos com visitantes qualificados
//     por perto (vivos TREINANDO pros mestres; almas MORTAS pros ranks do
//     Outro Mundo), contados pelo proprio motor a cada minuto.
//  Cumprir: paga zenni (+karma pros benevolentes), abate 1 falha antiga e soma
//  RENOME. 3 falhas = DESTITUIDO (cargo vago pra quem reivindicar).
//
//  ASCENSAO (o "uma alma, um trono" nao e um beco sem saida): quem JA carrega um
//  cargo tambem usa o "Reivindicar Rank", mas a lista vem filtrada -- so aparecem
//  os cargos que exigem o ATUAL como pre-requisito (a escada dos Kaios: 4 Kaios ->
//  Grand Kai -> Kaioshin). O pedagio e o RENOME: RQ_PROMO_QUESTS tarefas cumpridas
//  no cargo de agora. Subir vaga o degrau de baixo e zera a ficha (novo cargo,
//  novos deveres). A prova do Espirito do Cargo continua valendo.
//
//  Estado persiste no savefile "RankQuests" (flat). Avisos offline reusam o
//  correio da conquista (conq_notify_owner -> entregue no login).
// ============================================================================

// ============================== CONFIG ======================================
//O relogio do jogo corre em DAY_REAL_MINUTES minutos reais por dia (1A Defines.dm):
//com 20, 3 dias in-game = 72h in-game = ~60 min reais. Os prazos seguem o relogio DO
//JOGO, nao o calendario do jogador -- mexer no DAY_REAL_MINUTES arrasta as quests junto.
#define RQ_TASK_DAYS 3            //dias IN-GAME de prazo (e de intervalo entre tarefas)
#define RQ_TASK_INTERVAL (RQ_TASK_DAYS * DAY_REAL_MINUTES MINUTES) //espera ate a proxima tarefa
#define RQ_TASK_DEADLINE (RQ_TASK_DAYS * DAY_REAL_MINUTES MINUTES) //prazo pra cumprir
#define RQ_INGAME_DAY (DAY_REAL_MINUTES MINUTES) //ds REAIS de 1 dia in-game (conversao dos textos)
#define RQ_TASK_RETRY 6000        //re-tentativa (10 min) quando nao ha alvo elegivel
#define RQ_FAILS_MAX 3            //falhas ate a DESTITUICAO
#define RQ_REWARD_ZENNI 100000    //pagamento por tarefa cumprida
#define RQ_REWARD_KARMA 5         //karma pros ranks benevolentes ao cumprir
#define RQ_SERVICE_RANGE 6        //raio (tiles) do servico (discipulos/almas por perto)
#define RQ_SERVICE_CAP 3          //pontos maximos por minuto (3 visitantes contam por vez)
#define RQ_TRIAL_FACTOR 1.15      //BP do Espirito do Cargo = seu expressedBP x isto
#define RQ_TRIAL_TIMEOUT 3000     //ticks (5 min) pra vencer a prova
#define RQ_CLAIM_CD 18000         //ticks (30 min) de cooldown apos FALHAR uma prova
#define RQ_PRESIDENT_CAMPAIGN 250000 //zenni da campanha (cobrado ao VENCER a prova)
#define RQ_PRESIDENT_FUND 150000  //verba que o President deposita no cofre da Terra por tarefa
#define RQ_PROMO_QUESTS 3         //tarefas cumpridas no cargo ATUAL para liberar a ascensao
// ============================ FIM DO CONFIG =================================

var/list/rq_state = list()     //"key" -> assoc: task/target_sig/tname/planet/deadline/next/fails/prog/goal
var/list/rq_trial_busy = list()//"key" -> 1 enquanto uma prova daquele cargo roda
var/rq_inited = 0
mob/var/tmp/rq_claim_cd = 0    //cooldown pessoal apos falhar uma prova
mob/var/tmp/rq_claiming = 0    //numa prova AGORA

//ranks com quest (kov entra nas quests; a aquisicao dele e matar o Rei NPC)
var/list/RQ_ALL = list("turtle","crane","guardian","korin","elder","nkai","skai","ekai","wkai","grandkai","kaioshin","yemma","kov","president","demonlord","makyo","frostlord")
var/list/RQ_CLAIMABLE = list("turtle","crane","guardian","korin","elder","nkai","skai","ekai","wkai","grandkai","kaioshin","yemma","president","demonlord","makyo","frostlord")
var/list/RQ_SKY = list("nkai","skai","ekai","wkai","grandkai","kaioshin","yemma") //pode reivindicar/servir MORTO
var/list/RQ_WISDOM = list("turtle","crane","korin","elder","nkai","skai","ekai","wkai","grandkai","kaioshin","yemma")
var/list/RQ_EVIL = list("demonlord","makyo") //cumprir NAO paga karma bom

// ---------------------------------------------------------------------------
// Mapeamento key <-> global de rank
// ---------------------------------------------------------------------------
proc/rq_get_sig(key)
	switch(key)
		if("turtle") return Turtle
		if("crane") return Crane
		if("guardian") return Earth_Guardian
		if("korin") return Assistant_Guardian
		if("elder") return Namekian_Elder
		if("nkai") return North_Kai
		if("skai") return South_Kai
		if("ekai") return East_Kai
		if("wkai") return West_Kai
		if("grandkai") return Grand_Kai
		if("kaioshin") return Supreme_Kai
		if("yemma") return King_Yemma
		if("kov") return King_of_Vegeta
		if("president") return President
		if("demonlord") return Demon_Lord
		if("makyo") return King_Of_Hell
		if("frostlord") return Frost_Demon_Lord
	return null

proc/rq_set_sig(key, sig)
	switch(key)
		if("turtle") Turtle = sig
		if("crane") Crane = sig
		if("guardian") Earth_Guardian = sig
		if("korin") Assistant_Guardian = sig
		if("elder") Namekian_Elder = sig
		if("nkai") North_Kai = sig
		if("skai") South_Kai = sig
		if("ekai") East_Kai = sig
		if("wkai") West_Kai = sig
		if("grandkai") Grand_Kai = sig
		if("kaioshin") Supreme_Kai = sig
		if("yemma") King_Yemma = sig
		if("kov") King_of_Vegeta = sig
		if("president") President = sig
		if("demonlord") Demon_Lord = sig
		if("makyo") King_Of_Hell = sig
		if("frostlord") Frost_Demon_Lord = sig

proc/rq_display(key)
	switch(key)
		if("turtle") return "Turtle Hermit"
		if("crane") return "Crane Hermit"
		if("guardian") return "Guardiao da Terra"
		if("korin") return "Korin"
		if("elder") return "Grande Anciao de Namek"
		if("nkai") return "Kaio do Norte"
		if("skai") return "Kaio do Sul"
		if("ekai") return "Kaio do Leste"
		if("wkai") return "Kaio do Oeste"
		if("grandkai") return "Grand Kai"
		if("kaioshin") return "Kaioshin"
		if("yemma") return "King Yemma"
		if("kov") return "Rei de Vegeta"
		if("president") return "Presidente da Terra"
		if("demonlord") return "Demon Lord"
		if("makyo") return "Makyo King"
		if("frostlord") return "Frost Demon Lord"
	return key

//ja segura QUALQUER rank? (um cargo por alma; admin pode empilhar na mao se quiser)
proc/rq_any_rank(mob/M)
	if(!M || !M.signature) return 0
	var/s = M.signature
	if(Turtle==s||Crane==s||Earth_Guardian==s||Assistant_Guardian==s||Namekian_Elder==s) return 1
	if(North_Elder==s||South_Elder==s||East_Elder==s||West_Elder==s) return 1
	if(North_Kai==s||South_Kai==s||East_Kai==s||West_Kai==s||Grand_Kai==s||Supreme_Kai==s) return 1
	if(King_Yemma==s||King_of_Vegeta==s||President==s||Demon_Lord==s||King_Of_Hell==s) return 1
	if(Frost_Demon_Lord==s||King_Of_Acronia==s||Arconian_Guardian==s||Saibamen_Rouge_Leader==s) return 1
	if(God_Of_Destruction==s||Angel_Rank==s||capt==s||mutany==s||Geti==s||Arlian==s) return 1
	return 0

// ---------------------------------------------------------------------------
// ASCENSAO: a escada de cargos + o RENOME que a destranca
// ---------------------------------------------------------------------------
//tempo em ds REAIS -> texto no relogio DO JOGO (com o equivalente real entre parenteses)
proc/rq_tempo_txt(ds)
	if(ds < 0) ds = 0
	return "[round(ds / RQ_INGAME_DAY * 24)]h in-game (~[round(ds / 600)] min reais)"

proc/rq_my_key(mob/M) //qual cargo COM DEVERES esta alma carrega ("" = nenhum)
	if(!M || !M.signature) return ""
	for(var/key in RQ_ALL)
		if(rq_get_sig(key) == M.signature) return key
	return ""

//cargos que tem ESTE cargo como pre-requisito. Espelha o rq_requirements: mexer
//aqui sem mexer la (ou vice-versa) cria degrau que aparece mas nunca deixa subir.
proc/rq_promo_targets(key)
	var/list/alvos = list()
	switch(key)
		//os 4 Kaios cardeais: Grand Kai e o degrau natural, e o Kaioshin aceita o
		//atalho de sangue Kai + maestria de God Ki (o rq_requirements julga isso).
		if("nkai","skai","ekai","wkai") alvos = list("grandkai","kaioshin")
		if("grandkai") alvos = list("kaioshin")
	var/list/ret = list()
	for(var/k in alvos)
		if(k in RQ_CLAIMABLE) ret += k //so o que se toma por prova (kov/GoD/Anjo tem caminho proprio)
	return ret

proc/rq_renown(key) //tarefas cumpridas NO CARGO ATUAL (zera a cada troca de cargo)
	var/list/st = rq_state[key]
	if(!islist(st)) return 0
	return st["done"] || 0

proc/rq_promo_ready(key)
	return rq_renown(key) >= RQ_PROMO_QUESTS

//ha degrau acima VAGO agora? (renome nao adianta com o trono ocupado)
//Com M, so conta o degrau que ELE consegue tomar: sem esse filtro o Kaioshin e DEGRAU
//FANTASMA pro Kaio cardeal SEM sangue Kai (o requisito dele e ser Grand Kai ou ter
//sangue Kai + maestria) -- o trono vago que ele nunca tomaria queimava o aviso e fazia
//o "ascensao liberada" mentir. Sem M (dono offline) sobra so a vacancia mesmo.
proc/rq_promo_open(key, mob/M)
	for(var/alvo in rq_promo_targets(key))
		if(rq_get_sig(alvo)) continue //ocupado
		if(M && rq_requirements(alvo, M)) continue //vago, mas fora do alcance dele
		return 1
	return 0

proc/rq_promo_txt(key) //nomes dos degraus acima, para o texto
	var/list/nomes = list()
	for(var/k in rq_promo_targets(key)) nomes += rq_display(k)
	return jointext(nomes, " ou ")

proc/rq_renown_txt(key) //linha de renome, ciente de haver ou nao degrau acima
	if(!rq_promo_targets(key).len) return "Renome: [rq_renown(key)] tarefas cumpridas neste cargo."
	return "Renome: [min(rq_renown(key), RQ_PROMO_QUESTS)]/[RQ_PROMO_QUESTS] para a ascensao."

// ---------------------------------------------------------------------------
// REQUISITOS por rank: null = apto; senao texto do que falta
// ---------------------------------------------------------------------------
proc/rq_requirements(key, mob/M)
	var/kai_blood = (M.Race == "Kai" || M.Parent_Race == "Kai")
	switch(key)
		if("turtle")
			if(M.karma < 25) return "karma 25+ (a escola da Tartaruga forma protetores)"
			if(M.BP < 1000000) return "1M de BP base"
		if("crane")
			if(M.karma > 0) return "karma 0 ou menos (a escola do Grou nao forma santos)"
			if(M.BP < 1000000) return "1M de BP base"
		if("guardian")
			if(!(M.Race == "Namekian" || M.Parent_Race == "Namekian") || M.Class != "Dragon clan") return "ser um Namekuseijin do Cla do Dragao (a tradicao de Kami)"
			if(M.karma < 50) return "karma 50+"
			if(planet_rep_get("Earth", M) < REP_HERO) return "ser HEROI do povo da Terra (reputacao [REP_HERO]+)"
		if("korin")
			if(M.karma < 25) return "karma 25+"
			if(planet_rep_get("Earth", M) < 15) return "ser Amigavel com o povo da Terra (reputacao 15+)"
		if("elder")
			if(M.Race != "Namekian" && M.Parent_Race != "Namekian") return "sangue Namekuseijin"
			if(M.karma < 25) return "karma 25+"
			if(planet_rep_get("Namek", M) < 15) return "ser Amigavel com o povo de Namek (reputacao 15+)"
		if("nkai","skai","ekai","wkai")
			if(!kai_blood && (!M.godki || !M.godki.awakened)) return "despertar o God Ki (ou sangue Kai)"
			if(M.karma < 50) return "karma 50+"
		if("grandkai")
			var/s = M.signature
			if(!(North_Kai==s||South_Kai==s||East_Kai==s||West_Kai==s)) return "ser um dos 4 Kaios cardeais (a escada dos deuses)"
		if("kaioshin")
			var/s = M.signature
			if(Grand_Kai != s && !(kai_blood && M.godki && M.godki.mastery >= GODKI_BLUE_PCT)) return "ser o Grand Kai (ou sangue Kai com maestria de God Ki [GODKI_BLUE_PCT]%+)"
			if(M.karma < 75) return "karma 75+"
		if("yemma")
			if(M.karma < 50) return "karma 50+"
			if(M.deathcounter < 1) return "ja ter MORRIDO ao menos uma vez (conhecer o Outro Mundo)"
			if(M.BP < 5000000) return "5M de BP base"
		if("president")
			if(M.karma < 0) return "karma 0+"
			if(planet_rep_get("Earth", M) < 15) return "ser Amigavel com o povo da Terra (reputacao 15+)"
			if(M.zenni < RQ_PRESIDENT_CAMPAIGN) return "[FullNum(RQ_PRESIDENT_CAMPAIGN)] zenni de campanha"
		if("demonlord")
			if(M.karma > -50) return "karma -50 ou pior (o Inferno exige um coracao PODRE)"
			if(M.BP < 5000000) return "5M de BP base"
		if("makyo")
			if(M.Race != "Makyo" && M.Parent_Race != "Makyo" && M.karma > -50) return "sangue Makyo (ou karma -50 ou pior)"
			if(M.BP < 2000000) return "2M de BP base"
		if("frostlord")
			if(M.Race != "Frost Demon" && M.Parent_Race != "Frost Demon") return "sangue Frost Demon"
			if(M.BP < 10000000) return "10M de BP base (o lorde e o mais forte da estirpe)"
	return null

// ---------------------------------------------------------------------------
// REIVINDICAR RANK: escolha -> requisitos -> PROVA contra o Espirito do Cargo
// ---------------------------------------------------------------------------
mob/npc/Enemy/RankSpirit //o guardiao espiritual do cargo (invocado na prova)
	name = "Espirito do Cargo"
	attackable = 1
	monster = 1
	hasAI = 1
	dropsCorpse = 0
	HasSoul = 0
	mindswappable = 0
	itemrarity = 0
	behavior_vals = list(90, 60, 0, 70) //corajoso, implacavel, sem piedade, taticamente sobrio

mob/verb/Reivindicar_Rank()
	set name = "Reivindicar Rank"
	set category = "Other"
	if(!usr.client || !usr.signature || usr.KO) return
	if(usr.rq_claiming)
		to_chat(usr, "Voce ja esta no meio de uma prova.")
		return
	if(world.time < usr.rq_claim_cd)
		to_chat(usr, "O espirito do cargo ainda zomba da sua ultima derrota ([round((usr.rq_claim_cd - world.time) / 600)] min).")
		return
	//JA TEM CARGO? entao isto vira ASCENSAO: so os degraus acima, e so com renome.
	//(rq_my_key so enxerga os cargos COM DEVERES -- GoD/Anjo/Rei Pirata e cia
	// nao tem escada nem quest, entao pra eles continua valendo "um trono so".)
	var/mykey = rq_my_key(usr)
	if(!mykey && rq_any_rank(usr))
		to_chat(usr, "Voce ja carrega um cargo -- uma alma, um trono.")
		return
	var/list/pool = RQ_CLAIMABLE
	if(mykey)
		pool = rq_promo_targets(mykey)
		if(!pool.len)
			to_chat(usr, "<font color=#e8b64c>[rq_display(mykey)] e o fim da sua escada -- nenhum cargo exige este como pre-requisito. Uma alma, um trono.")
			return
		if(!rq_promo_ready(mykey))
			to_chat(usr, "<font color=#e8b64c>Ainda falta RENOME para almejar algo maior: <b>[rq_renown(mykey)]/[RQ_PROMO_QUESTS]</b> tarefas cumpridas como [rq_display(mykey)]. Sirva ao cargo primeiro. (verb <b>Meu Rank</b>)")
			return
	//lista os VAGOS, marcando o que falta em cada um
	var/list/menu = list()
	for(var/key in pool)
		if(rq_get_sig(key)) continue //ocupado
		if(usr.dead && !(key in RQ_SKY)) continue //morto so reivindica cargos do Outro Mundo
		var/falta = rq_requirements(key, usr)
		menu["[rq_display(key)][falta ? " (FALTA: [falta])" : " -- APTO"]"] = key
	if(!menu.len)
		if(mykey) to_chat(usr, "Nenhum cargo acima de [rq_display(mykey)] esta vago agora.")
		else to_chat(usr, "Nenhum cargo vago ao seu alcance agora[usr.dead ? " (morto, so os cargos do Outro Mundo aparecem)" : ""].")
		return
	var/pick = input(usr, mykey ? "ASCENSAO -- cargos acima de [rq_display(mykey)] (a prova invoca o Espirito do Cargo, ~15% acima do seu poder):" : "Cargos VAGOS (a prova invoca o Espirito do Cargo, ~15% acima do seu poder):", "Reivindicar Rank") as null|anything in menu
	if(!pick) return
	var/key = menu[pick]
	if(rq_get_sig(key)) return //ocupado no meio tempo
	if(rq_my_key(usr) != mykey || (mykey && (!(key in rq_promo_targets(mykey)) || !rq_promo_ready(mykey))))
		to_chat(usr, "<font color=#e8b64c>Seu cargo mudou enquanto a janela estava aberta -- a ascensao foi cancelada.")
		return
	var/falta = rq_requirements(key, usr)
	if(falta)
		to_chat(usr, "<font color=#e8b64c>Ainda nao: [falta].")
		return
	if(rq_trial_busy[key])
		to_chat(usr, "Outra alma ja enfrenta o espirito deste cargo AGORA.")
		return
	if(usr.dead && !(key in RQ_SKY)) return
	switch(alert(usr, "O ESPIRITO DE [uppertext(rq_display(key))] sera invocado para testa-lo (~15% acima do seu poder expresso). Vencer = o cargo e seu[mykey ? ", e o posto de [rq_display(mykey)] fica VAGO (seu renome recomeca do zero)" : ""]. Perder = 30 min de vergonha. Enfrentar?", "Prova do Cargo", "Enfrentar", "Recuar"))
		if("Recuar") return
	if(rq_trial_busy[key] || rq_get_sig(key) || usr.rq_claiming) return
	if(rq_my_key(usr) != mykey || (mykey && (!(key in rq_promo_targets(mykey)) || !rq_promo_ready(mykey)))) //idem: o alert tambem bloqueia
		to_chat(usr, "<font color=#e8b64c>Seu cargo mudou enquanto a janela estava aberta -- a ascensao foi cancelada.")
		return
	spawn rq_trial_run(usr, key, mykey) //mykey vai junto: o degrau tem que continuar de pe no FIM da prova

proc/rq_trial_turf(mob/M) //turf andavel ao lado do desafiante
	for(var/tries = 1 to 20)
		var/turf/T = locate(M.x + rand(-2, 2), M.y + rand(-2, 2), M.z)
		if(T && !T.density && T != M.loc) return T
	return M.loc

proc/rq_trial_run(mob/M, key, mykey = "")
	if(!M || rq_trial_busy[key]) return
	rq_trial_busy[key] = 1
	M.rq_claiming = 1
	var/turf/T = rq_trial_turf(M)
	var/mob/npc/Enemy/RankSpirit/S = new(T)
	S.name = "Espirito de [rq_display(key)]"
	S.icon = npc_pick_body((key == "elder" || key == "guardian") ? "Namekian" : "Human", "male") //Kami era Namekuseijin; o resto assume forma humana
	S.color = "#bfe0ff" //palidez espectral
	S.overlayList += 'Halo.dmi'
	S.overlaychanged = 1
	conq_pin_bp(S, round(M.expressedBP * RQ_TRIAL_FACTOR))
	var/mob/npc/Enemy/RankSpirit/S2 = S
	spawn(10) if(S2 && S2.loc && !S2.dead) conq_pin_bp(S2, round(M.expressedBP * RQ_TRIAL_FACTOR)) //o NPCTicker base so ELEVA BP: re-fixa
	flick('flashtrans.dmi', S)
	to_chat(view(M), "<font color=#e8b64c><b>O ESPIRITO DE [uppertext(rq_display(key))] se materializa diante de [M]!</b> \"Prove que merece o manto.\"</font>")
	S.emit_Sound('1aura.wav')
	var/pz = M.z
	spawn(5) if(S && S.loc && M && !M.dead) S.foundTarget(M)
	var/deadline = world.time + RQ_TRIAL_TIMEOUT
	var/won = 0
	while(1)
		sleep(10)
		if(!S || !S.loc || S.dead || S.KO) //espirito caiu (morto OU nocauteado = vencido)
			won = 1
			break
		if(!M || !M.client || (M.dead && !(key in RQ_SKY) ? 1 : 0) || M.KO || M.z != pz || get_dist(M, S) > 25 || world.time > deadline)
			break
		if(!S.target && !S.AIRunning && M && !M.KO) //espirito ocioso re-engaja
			var/mob/npc/Enemy/RankSpirit/S3 = S
			spawn(1) if(S3 && S3.loc && !S3.target && !S3.AIRunning) S3.foundTarget(M)
	if(S) conq_despawn_npc(S)
	rq_trial_busy -= key
	if(M) M.rq_claiming = 0
	if(!won || !M || !M.client)
		if(M)
			M.rq_claim_cd = world.time + RQ_CLAIM_CD
			to_chat(M, "<font color=#e8b64c>O espirito se desfaz em risos... voce NAO estava a altura do cargo. (novamente em [round(RQ_CLAIM_CD / 600)] min)")
		return
	if(rq_get_sig(key)) return //alguem levou no meio tempo (nao deveria: trava)
	//a prova leva ate 5 min e o rq_loop anda junto: quem foi DESTITUIDO (3a falha) ou
	//perdeu o degrau/renome durante a luta NAO ascende -- senao a punicao do sistema
	//viraria promocao. So o caminho da ASCENSAO revalida: no claim comum nao da pra
	//re-checar requisito, porque MATAR o Espirito paga karma (Enemy/mobDeath) e isso
	//derrubaria justamente Crane/Demon Lord/Makyo, que exigem karma BAIXO.
	if(mykey)
		if(rq_my_key(M) != mykey || !(key in rq_promo_targets(mykey)) || !rq_promo_ready(mykey))
			to_chat(M, "<font color=red><b>O Espirito de [rq_display(key)] caiu, mas o manto se desfaz nas suas maos:</b> voce perdeu o posto de [rq_display(mykey)] (ou o renome dele) durante a prova. A ascensao pertence a quem AINDA carrega o degrau de baixo.")
			return
		//ATENCAO: este re-teste so e seguro enquanto TODO alvo do rq_promo_targets tiver
		//requisito que nao PIORA na luta (hoje: grandkai = so assinatura; kaioshin = karma
		//75+ e maestria, que so SOBEM). Alvo que peca karma BAIXO ou zenni quebra aqui --
		//matar o Espirito paga karma. Se a escada crescer nessa direcao, tire este bloco:
		//o rq_my_key + rq_promo_targets acima ja cobrem o que da pra perder na prova.
		var/falta_fim = rq_requirements(key, M)
		if(falta_fim)
			to_chat(M, "<font color=red><b>O Espirito de [rq_display(key)] caiu, mas o manto se recusa:</b> [falta_fim]. (algo mudou durante a prova)")
			return
	rq_grant(key, M)

proc/rq_grant(key, mob/M)
	//ASCENSAO: subir VAGA o degrau de baixo, seja ele qual for (a escada dos Kaios
	//e o caso classico, mas a regra vale pra qualquer par ligado no rq_promo_targets).
	var/s = M.signature
	for(var/velho in RQ_ALL)
		if(velho == key || rq_get_sig(velho) != s) continue
		if(!(key in rq_promo_targets(velho))) continue //so vaga o DEGRAU DE BAIXO: cargo de outra familia (o trono de Vegeta se toma matando o Rei, fora deste verb) fica com o dono
		rq_set_sig(velho, null)
		rq_state -= velho //ficha do posto antigo morre junto: o proximo dono comeca limpo
		bev_announce("O posto de [rq_display(velho)] esta VAGO -- [M.name] ascendeu a [rq_display(key)]!")
	if(key == "president") M.zenni -= RQ_PRESIDENT_CAMPAIGN //a campanha cobra ao VENCER
	rq_set_sig(key, s)
	RankList[s] = M.name
	rq_state -= key //cargo novo comeca com a ficha limpa
	M.Rank_Verb_Assign()
	Save_Rank()
	rq_save()
	bev_announce("[M.name] venceu o Espirito do Cargo e agora e [uppertext(rq_display(key))]!")
	to_chat(M, "<font color=#e8b64c><b>O manto de [rq_display(key)] e seu.</b> O cargo cobra deveres: acompanhe pelo verb <b>Meu Rank</b>. [RQ_FAILS_MAX] falhas = destituicao.")
	if(rq_promo_targets(key).len)
		to_chat(M, "<font color=#e8b64c>Ha degrau acima deste cargo ([rq_promo_txt(key)]): cumpra <b>[RQ_PROMO_QUESTS]</b> tarefas para ganhar renome e o <b>Reivindicar Rank</b> se abre de novo.")

// ---------------------------------------------------------------------------
// MOTOR DE QUESTS (ticker de 60s; estado persistido em "RankQuests")
// ---------------------------------------------------------------------------
proc/rq_save()
	var/savefile/S = new("RankQuests")
	S["state"] << rq_state

proc/rq_load()
	if(!fexists("RankQuests")) return
	var/savefile/S = new("RankQuests")
	var/list/d
	S["state"] >> d
	if(islist(d)) rq_state = d
	rq_boot_forgive() //o prazo mora em world.realtime: perdoa o tempo de servidor DESLIGADO

//world.realtime e relogio de PAREDE -- anda com o servidor fora do ar. Com o prazo curto
//(RQ_TASK_DAYS dias in-game = ~1h real), qualquer manutencao/wipe/queda maior que isso
//deixava TODA tarefa em voo vencida no primeiro tick pos-boot: falha de graca e anuncio
//global por cargo, empilhando rumo a destituicao sem ninguem ter jogado. Prazo que vence
//com o mundo DE PE nao passa por aqui -- continua caindo normal no rq_loop.
proc/rq_boot_forgive()
	var/mexeu = 0
	for(var/key in RQ_ALL)
		var/list/st = rq_state[key]
		if(!islist(st)) continue
		if(rq_clamp_window(st)) mexeu = 1
		if(!st["task"]) continue
		if(st["deadline"] > world.realtime + 600) continue //ainda sobra prazo: nao mexe
		st["deadline"] = world.realtime + RQ_TASK_DEADLINE
		mexeu = 1
	if(mexeu) rq_save()

//A ficha guarda INSTANTES ABSOLUTOS (world.realtime), entao encurtar os knobs nao encurta
//sozinho a janela ja gravada: quem estava esperando o intervalo VELHO (48h reais) continuava
//com "a proxima chega em ~2735 min". Este teto corta qualquer janela maior que a de hoje --
//vale pra migracao antiga e pra qualquer ajuste futuro de RQ_TASK_DAYS. Devolve 1 se mexeu.
proc/rq_clamp_window(list/st)
	. = 0
	if(!islist(st)) return
	if(st["next"] > world.realtime + RQ_TASK_INTERVAL)
		st["next"] = world.realtime + RQ_TASK_INTERVAL
		. = 1
	if(st["task"] && st["deadline"] > world.realtime + RQ_TASK_DEADLINE)
		st["deadline"] = world.realtime + RQ_TASK_DEADLINE
		. = 1

proc/RankQuests_Init()
	set waitfor = 0
	if(rq_inited) return
	rq_inited = 1
	while(worldloading) sleep(1)
	rq_load()
	spawn rq_loop()

proc/rq_holder_mob(sig)
	for(var/mob/P in player_list)
		if(P && P.client && P.signature == sig) return P
	return null

proc/rq_task_desc(list/st)
	switch(st["task"])
		if("liberar") return "LIBERTAR [st["planet"] == "Earth" ? "a Terra" : st["planet"]] do dominio inimigo (conquista)"
		if("vilao") return "CACAR o vilao [st["tname"]] (elimina-lo enquanto online)"
		if("heroi") return "ESMAGAR o heroi [st["tname"]] (elimina-lo enquanto online)"
		if("planeta") return "DESTRUIR o planeta [st["planet"]]"
		if("verba") return "DEPOSITAR [FullNum(RQ_PRESIDENT_FUND)] zenni no cofre da Terra (verb Meu Rank)"
		if("servico") return "SERVICO: [st["prog"]]/[st["goal"]] pontos (visitantes qualificados a [RQ_SERVICE_RANGE] tiles: vivos TREINANDO pros mestres, almas MORTAS pro Outro Mundo)"
	return "?"

proc/rq_assign(key, list/st)
	var/sig = rq_get_sig(key)
	var/task = ""
	var/planet = ""
	var/target_sig = null
	var/tname = ""
	var/goal = 0
	if(key in RQ_WISDOM) //SABEDORIA: servico de presenca
		task = "servico"
		goal = (key in list("nkai","skai","ekai","wkai","grandkai","kaioshin")) ? 10 : 15
	else //PODER
		var/myplanet = (key == "kov") ? "Vegeta" : ((key == "guardian" || key == "president") ? "Earth" : "")
		if(myplanet && conq_owner_sig(myplanet) && conq_owner_sig(myplanet) != sig) //seu planeta esta DOMINADO: liberte-o
			task = "liberar"
			planet = myplanet
		else if(key == "president") //sem crise: verba pro cofre
			task = "verba"
		else if(key == "frostlord") //o lorde frost destroi um mundo (tributo de medo)
			var/list/vivos = list()
			for(var/pn in pspace_planets)
				var/datum/pspace_planet/D = pspace_planets[pn]
				if(!D || (pn in PlanetDisableList) || (D.pobj && D.pobj.isDestroyed)) continue
				vivos += pn
			if(!vivos.len)
				st["next"] = world.realtime + RQ_TASK_RETRY
				return
			task = "planeta"
			planet = pick(vivos)
		else //protetores cacam VILOES; lordes malignos cacam HEROIS
			var/evil = (key in RQ_EVIL)
			var/list/alvos = list()
			for(var/mob/P in player_list)
				if(!P.client || P.dead || P.signature == sig) continue
				if(evil ? (P.karma >= 50) : (P.isVillain || P.karma <= -50)) alvos += P
			if(!alvos.len)
				st["next"] = world.realtime + RQ_TASK_RETRY
				return
			var/mob/alvo = pick(alvos)
			task = evil ? "heroi" : "vilao"
			target_sig = alvo.signature
			tname = alvo.name
	st["task"] = task
	st["planet"] = planet
	st["target_sig"] = target_sig
	st["tname"] = tname
	st["goal"] = goal
	st["prog"] = 0
	st["deadline"] = world.realtime + RQ_TASK_DEADLINE
	rq_save()
	conq_notify_owner(sig, "<font color=#e8b64c><b>[rq_display(key)]:</b> nova tarefa -- [rq_task_desc(st)]. Prazo: [rq_tempo_txt(RQ_TASK_DEADLINE)]. (verb Meu Rank)</font>")

proc/rq_check_done(key, list/st)
	switch(st["task"])
		if("liberar")
			var/o = conq_owner_sig(st["planet"])
			return (isnull(o) || o == rq_get_sig(key))
		if("vilao","heroi")
			var/mob/T = rq_holder_mob(st["target_sig"]) //online?
			if(!T) //alvo sumiu do jogo: tarefa se anula sem punir
				st["task"] = ""
				st["next"] = world.realtime + RQ_TASK_RETRY
				rq_save()
				return 0
			return T.dead
		if("planeta")
			var/pn = st["planet"]
			var/datum/pspace_planet/D = pspace_planets[pn]
			return (!D || (pn in PlanetDisableList) || (D.pobj && D.pobj.isDestroyed))
		if("verba")
			return st["prog"] >= 1
		if("servico")
			return st["prog"] >= st["goal"]
	return 0

proc/rq_service_tick(key, list/st) //pontos por visitantes qualificados perto do portador
	var/mob/H = rq_holder_mob(rq_get_sig(key))
	if(!H) return
	var/sky = (key in RQ_SKY)
	if(!sky && H.dead) return //mestre morto nao da aula; Kaio/Yemma atende ate morto
	var/pts = 0
	for(var/mob/P in oview(RQ_SERVICE_RANGE, H))
		if(!P.client || P == H) continue
		if(sky ? P.dead : (!P.dead && P.train)) pts++ //Outro Mundo atende ALMAS; mestres contam quem TREINA
		if(pts >= RQ_SERVICE_CAP) break
	if(pts)
		st["prog"] += pts
		if(H.client && st["prog"] < st["goal"] && (st["prog"] % 5 < pts)) to_chat(H, "<font color=#e8b64c>Servico do cargo: [min(st["prog"], st["goal"])]/[st["goal"]].")

proc/rq_complete(key, list/st)
	var/sig = rq_get_sig(key)
	st["fails"] = max((st["fails"] || 0) - 1, 0)
	st["done"] = (st["done"] || 0) + 1 //RENOME: e isto que abre a ascensao
	st["task"] = ""
	st["next"] = world.realtime + RQ_TASK_INTERVAL
	var/mob/H = rq_holder_mob(sig)
	//renome batendo a marca: a escada se abre. O latch CAI enquanto nao houver degrau
	//VAGO E ALCANCAVEL -- senao o unico aviso da tenencia seria gasto num trono que ele
	//nunca poderia tomar, e nada avisaria quando o degrau certo vagasse. Decidido ANTES
	//do rq_save para uma gravacao so cobrir fails/done/task/next + latch.
	var/avisar = 0
	if(rq_promo_targets(key).len && st["done"] >= RQ_PROMO_QUESTS)
		if(!rq_promo_open(key, H)) st["promo_warned"] = 0
		else if(!st["promo_warned"])
			st["promo_warned"] = 1
			avisar = 1
	rq_save()
	if(H)
		H.zenni += RQ_REWARD_ZENNI
		if(!(key in RQ_EVIL)) H.karma = min(H.karma + RQ_REWARD_KARMA, 100)
		to_chat(H, "<font color=#e8b64c><b>Tarefa de [rq_display(key)] CUMPRIDA!</b> +[FullNum(RQ_REWARD_ZENNI)] zenni. Falhas: [st["fails"]]/[RQ_FAILS_MAX]. [rq_renown_txt(key)]")
	else conq_notify_owner(sig, "<font color=#e8b64c><b>Tarefa de [rq_display(key)] CUMPRIDA!</b> A recompensa aguarda seu retorno... (paga na proxima tarefa cumprida online)")
	to_chat(world, "<font color=#e8b64c>[rq_display(key)] cumpriu seu dever para com o universo.</font>", "announce")
	if(avisar)
		var/aviso = "<font color=#e8b64c><b>Seu renome como [rq_display(key)] correu o universo.</b> O caminho para [rq_promo_txt(key)] esta aberto -- use o verb <b>Reivindicar Rank</b> para enfrentar o Espirito do proximo cargo.</font>"
		if(H) to_chat(H, aviso)
		else conq_notify_owner(sig, aviso)

proc/rq_fail(key, list/st)
	var/sig = rq_get_sig(key)
	st["fails"] = (st["fails"] || 0) + 1
	st["task"] = ""
	st["next"] = world.realtime + RQ_TASK_INTERVAL / 2
	rq_save()
	conq_notify_owner(sig, "<font color=red><b>[rq_display(key)]: tarefa FALHADA.</b> Falhas: [st["fails"]]/[RQ_FAILS_MAX].</font>")
	to_chat(world, "<font color=#e8b64c>[rq_display(key)] FALHOU em seu dever ([st["fails"]]/[RQ_FAILS_MAX]).</font>", "announce")
	if(st["fails"] >= RQ_FAILS_MAX) rq_destitute(key, "negligenciou os deveres do cargo")

proc/rq_destitute(key, reason)
	var/sig = rq_get_sig(key)
	if(isnull(sig)) return
	var/nm = RankList[sig] ? RankList[sig] : "O portador"
	rq_set_sig(key, null)
	rq_state -= key
	Save_Rank()
	rq_save()
	var/mob/H = rq_holder_mob(sig)
	if(H)
		H.Rank = ""
		to_chat(H, "<font color=red><b>Voce foi DESTITUIDO do cargo de [rq_display(key)]:</b> [reason].")
	else conq_notify_owner(sig, "<font color=red><b>Voce foi DESTITUIDO do cargo de [rq_display(key)]:</b> [reason].</font>")
	bev_announce("[nm] foi DESTITUIDO do cargo de [rq_display(key)] -- o posto esta VAGO!")

proc/rq_loop()
	set waitfor = 0
	set background = 1
	while(1)
		sleep(600) //1 min
		for(var/key in RQ_ALL)
			var/sig = rq_get_sig(key)
			if(isnull(sig))
				if(rq_state[key]) rq_state -= key
				continue
			var/list/st = rq_state[key]
			if(!islist(st))
				st = list("task" = "", "next" = world.realtime + RQ_TASK_INTERVAL, "fails" = 0, "done" = 0, "prog" = 0, "goal" = 0, "planet" = "", "target_sig" = null, "tname" = "", "deadline" = 0)
				rq_state[key] = st
				rq_save()
			if(rq_clamp_window(st)) rq_save() //ficha gravada com o intervalo VELHO (48h reais) se conserta sozinha aqui, sem esperar reboot
			//PORTADOR OFFLINE: relogio CONGELADO. 11 dos 17 cargos so pontuam com ele no ar
			//(o rq_service_tick sai na hora sem o mob), entao correr prazo na ausencia era
			//3 falhas em ~4h reais e o cargo perdido dormindo. Nada e atribuido nem cobrado
			//enquanto ele nao volta, e o prazo renasce inteiro quando ele voltar.
			if(!rq_holder_mob(sig))
				st["next"] = world.realtime + 600
				if(st["task"]) st["deadline"] = world.realtime + RQ_TASK_DEADLINE
				continue
			if(!st["task"])
				if(world.realtime >= st["next"]) rq_assign(key, st)
				continue
			if(st["task"] == "servico") rq_service_tick(key, st)
			if(rq_check_done(key, st))
				rq_complete(key, st)
				continue
			if(st["task"] && world.realtime > st["deadline"]) rq_fail(key, st)

// ---------------------------------------------------------------------------
// Verb do portador: ver a tarefa / depositar a verba (President)
// ---------------------------------------------------------------------------
mob/verb/Meu_Rank()
	set name = "Meu Rank"
	set category = "Other"
	var/mykey = rq_my_key(usr)
	if(!mykey)
		to_chat(usr, "Voce nao carrega nenhum cargo com deveres. (Reivindicar Rank mostra os vagos.)")
		return
	var/list/st = rq_state[mykey]
	to_chat(usr, "<b>--- [rq_display(mykey)] ---</b>")
	to_chat(usr, "[rq_renown_txt(mykey)]")
	if(rq_promo_targets(mykey).len)
		if(!rq_promo_ready(mykey)) to_chat(usr, "Degrau acima: [rq_promo_txt(mykey)] (faltam [RQ_PROMO_QUESTS - rq_renown(mykey)] tarefas de renome).")
		else if(rq_promo_open(mykey, usr)) to_chat(usr, "<font color=#e8b64c>ASCENSAO LIBERADA: [rq_promo_txt(mykey)] -- use o verb <b>Reivindicar Rank</b>.")
		else if(rq_promo_open(mykey)) to_chat(usr, "<font color=#e8b64c>Ha degrau VAGO acima ([rq_promo_txt(mykey)]), mas voce ainda nao preenche o que ele exige -- o <b>Reivindicar Rank</b> mostra o que falta.")
		else to_chat(usr, "<font color=#e8b64c>Renome suficiente, mas [rq_promo_txt(mykey)] segue OCUPADO -- o trono precisa vagar.")
	else to_chat(usr, "Este e o fim da sua escada -- nenhum cargo exige [rq_display(mykey)] como pre-requisito.")
	if(!islist(st) || !st["task"])
		to_chat(usr, "Sem tarefa no momento. A proxima chega [islist(st) && st["next"] ? "em ~[rq_tempo_txt(st["next"] - world.realtime)]" : "em breve"].")
		if(islist(st)) to_chat(usr, "Falhas: [st["fails"] || 0]/[RQ_FAILS_MAX].")
		return
	to_chat(usr, "Tarefa: [rq_task_desc(st)]")
	to_chat(usr, "Prazo restante: [rq_tempo_txt(st["deadline"] - world.realtime)] | Falhas: [st["fails"] || 0]/[RQ_FAILS_MAX]")
	if(st["task"] == "verba") //o President deposita por aqui
		switch(alert(usr, "Depositar [FullNum(RQ_PRESIDENT_FUND)] zenni no cofre da Terra agora?", "Verba", "Depositar", "Agora nao"))
			if("Depositar")
				if(usr.zenni < RQ_PRESIDENT_FUND)
					to_chat(usr, "Zenni insuficiente.")
					return
				usr.zenni -= RQ_PRESIDENT_FUND
				EarthBank += RQ_PRESIDENT_FUND
				st["prog"] = 1
				rq_save()
				to_chat(usr, "<font color=#e8b64c>Verba depositada -- o cofre da Terra agradece.")
