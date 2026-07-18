// ============================================================================
// ESPACO PROCEDURAL (Fase 1)
//   * Encostar na BORDA do espaco (z26 ou de um setor) leva pro setor vizinho
//     num grid infinito (sx, sy); o setor central (0,0) e o espaco original.
//   * Cada setor e gerado por SEED deterministica (mesma galaxia entre boots,
//     via savefile "Galaxy" -- o wipe-servidor.bat apaga e nasce outra galaxia).
//   * Setores tem 2-4 planetas procedurais (nome/bioma/gravidade/cor gerados),
//     POUSAVEIS: a superficie e um z de bioma com flora, inimigos e a borda de
//     saida (turf Stars_Exit existente -- volta pro espaco ao lado do planeta).
//   * Z-levels NAO podem ser deletados no BYOND: setores e superficies vivem em
//     POOLS reciclados (LRU sem players) -- revisitar regenera IDENTICO (seed).
//   * Nav System (ui_tab_nav) mostra o setor atual e os vizinhos explorados.
// Ganchos externos: testPlanetbump (Planets.dm), Grav() (Gravity.dm),
// ui_tab_nav (HtmlUI.dm), wipe-servidor.bat ("Galaxy").
// ============================================================================
//PSPACE_HOME_Z (z26, o espaco original) mora no 1A Defines.dm: o Launch do PlanetTech.dm tambem usa
#define PSPACE_SIZE 200         // lado da regiao util de um setor gerado
#define PSURF_SIZE 500          // lado da superficie de um planeta procedural (mundo inteiro; 1a visita gera ~250k turfs, alguns segundos)
#define PSPACE_GEN_TICKCAP 92   // % de tick que a geracao pode ocupar antes de ceder (o CHECK_TICK por tile + lagstopsleep escalonado derrubava o ritmo pra ~3%)
#define PSPACE_GEN_COLSTRIDE 8    // pouso (alguem ESPERANDO): colunas entre checagens de yield -- rapido, tolera tick estourado por ~5s
#define PSPACE_PREGEN_COLSTRIDE 1 // pre-aquecimento em background: dorme 1 tick POR COLUNA -- invisivel no Lag-O-Meter (o ritmo do pouso em background dava 400% de tick)
#define PSPACE_GEN_TIMEOUT 900    // 90s SEM PROGRESSO (o gerador da heartbeat no latch por coluna) = proc morto -- watchdog destrava e recomeca
#define PSPACE_BOOT_MAX 20        // teto de planetas gerados no BOOT (dd.exe e 32-bit: ~250k turfs residentes por planeta; alem disto ficam por demanda)
#define PSPACE_MAX_SECTORS 12   // pool de z's de setor (recicla o mais antigo sem players)
#define PSURF_MAX_SURFACES 10   // pool de z's de superficie
#define PSPACE_MIN_PLANETS 2    // planetas por setor (min)
#define PSPACE_MAX_PLANETS 4    // planetas por setor (max)
#define PSURF_TREE_PROB 5       // % de chance de arvore por tile de PLANICIE (dobra na colina)
#define PSURF_PLANT_PROB 2      // % de chance de planta colhivel por tile de planicie
#define PSURF_ORE_PROB 3        // % de chance de minerio por tile de COLINA (x ore_mult do bioma)
#define PSURF_ENEMY_MIN 12      // inimigos por planeta (min; escalado pro mundo 500x500)
#define PSURF_ENEMY_MAX 20      // inimigos por planeta (max)
// relevo (value noise 0..1): abaixo de agua vira lago, acima de montanha vira parede
#define PSURF_H_WATER 0.32
#define PSURF_H_BEACH 0.38
#define PSURF_H_HILL 0.75
#define PSURF_H_MOUNTAIN 0.86

// ---- SUPER DRAGON BALLS ----
#define SDB_MIN_DIST 2      // distancia minima |sx|+|sy| do setor central (forca exploracao)
#define SDB_MAX_DIST 8      // raio maximo do espalhamento
#define SDB_HINT_RANGE 2    // o Nav acusa "sinal dourado" a ate isto de distancia (Chebyshev)
#define SDB_WISH_ZENNI 5000000 // desejo de riqueza
#define SDB_CLAIM_TICKS 100    // canal (10s) pra reivindicar uma esfera SEM dono
#define SDB_CONTEST_TICKS 3000 // disputa (5 min): tempo que o ladrao precisa segurar a esfera de outro dono
#define SDB_CONTEST_RANGE 6    // raio (tiles) que o disputante precisa manter da esfera durante a disputa

var
	pspace_seed = 0                    // seed da galaxia (persistida no savefile "Galaxy")
	list/pspace_sectors = list()       // "sx,sy" -> /datum/space_sector
	list/pspace_planets = list()       // nome -> /datum/pspace_planet (lookup de gravidade/pouso)
	list/pspace_sector_zs = list()     // z's alocados pra setores (pool)
	list/pspace_surface_zs = list()    // z's alocados pra superficies (pool)
	list/pspace_superdb = null         // 7 entradas list(num, sx, sy, x, y, held_legado, owner_sig, owner_name) -- persistem no "Galaxy"
	sdb_benef_sig = null               // TRANSFERENCIA: quem ENTREGOU as 7 esferas (o pedido pessoal do dragao vai PRA ELE) -- persiste no "Galaxy"
	sdb_benef_name = ""
	list/sdb_contest = list()          // esferas em DISPUTA agora ("num" -> 1); estado vivo, reboot limpa
	pspace_booted = 0
	pspace_world_ready = 0             // 0 = startup gerando os planetas: o lobby BLOQUEIA load/new ate ficar 1
	pspace_startup_progress = ""       // "3/7" -- mostrado na mensagem de espera do lobby
	psurf_pool_cap = PSURF_MAX_SURFACES // teto DINAMICO do pool de superficies (o startup residente aumenta)

obj/var/tmp/pspace_wild = 0 //flora/minerio GERADO pelo terreno (nao conta como coisa de jogador no snapshot)

var/list/pspace_sleepers = list() //planetas onde o jogo SABE que ha save de jogador (prioridade do startup; persiste no "Galaxy")

// ---------------------------------------------------------------------------
// RNG deterministico proprio (Wichmann-Hill: 3 LCGs pequenos combinados).
// NAO trocar por um LCG grande: numeros do DM sao FLOAT 32 (mantissa 2^24) --
// um state*8121 chega a ~1e9, perde precisao e ENVIESA os residuos baixos
// (medido: next(100)<=10 dava 17% num trecho e 2% noutro; flora quase nao
// nascia e os acentos de chao listravam). Aqui todo produto fica < 5.3M =
// exato em float; periodo ~7e12. rand() do BYOND nao pode ser semeado
// por-geracao sem bagunçar o RNG global do jogo.
// ---------------------------------------------------------------------------
datum/pspace_rng
	var/s1 = 1
	var/s2 = 2
	var/s3 = 3
	New(s)
		var/v = round(abs(s))
		s1 = (v % 30268) + 1
		s2 = (round(v / 100) % 30306) + 1
		s3 = (round(v / 10000) % 30322) + 1
	proc/next(max) //1..max
		s1 = (s1 * 171) % 30269
		s2 = (s2 * 172) % 30307
		s3 = (s3 * 170) % 30323
		var/u = s1 / 30269 + s2 / 30307 + s3 / 30323
		u -= round(u) //parte fracionaria: uniforme em [0,1)
		return min(max, round(u * max) + 1)
	proc/pickfrom(list/L)
		if(!L || !L.len) return null
		return L[next(L.len)]

proc/pspace_mix_seed(sx, sy) //seed do setor: deterministica a partir da galaxia + coords
	var/a = (sx * 379 + sy * 8887 + pspace_seed) % 134456
	if(a < 0) a += 134456
	return a + 1

// ---------------------------------------------------------------------------
// BOOT lazy: carrega/cria a seed da galaxia no primeiro cruzamento de borda.
// A galaxia DESCOBERTA persiste (Fase 3): setores nomeados e planetas conhecidos
// voltam entre boots (codificados FLAT no savefile -- nunca serializar os datums,
// que carregam refs vivas de area/obj/mob).
// ---------------------------------------------------------------------------
proc/pspace_boot()
	if(pspace_booted) return
	pspace_booted = 1
	var/list/secdata = null
	var/list/pladata = null
	if(fexists("Galaxy"))
		var/savefile/S = new("Galaxy")
		S["seed"] >> pspace_seed
		S["sectors"] >> secdata
		S["planets"] >> pladata
		S["superdb"] >> pspace_superdb
		S["sdb_benef_sig"] >> sdb_benef_sig
		S["sdb_benef_name"] >> sdb_benef_name
		var/list/slp = null
		S["sleepers"] >> slp
		if(islist(slp)) pspace_sleepers = slp
	if(!pspace_seed)
		pspace_seed = rand(1, 134455)
		var/savefile/S = new("Galaxy")
		S["seed"] << pspace_seed
	if(!islist(pspace_superdb) || !pspace_superdb.len) //galaxia nova: espalha as 7 Super Dragon Balls
		pspace_sdb_scatter()
	else //MIGRACAO: registros antigos de 6 campos (sem claim) ganham dono vazio
		for(var/list/E in pspace_superdb)
			if(E.len < 7) E += null
			if(E.len < 8) E += ""
	//o setor central (0,0) e o espaco original
	var/datum/space_sector/home = new
	home.sx = 0
	home.sy = 0
	home.z = PSPACE_HOME_Z
	home.name = "Setor Central"
	home.is_home = 1
	pspace_sectors["0,0"] = home
	//reconstroi a galaxia descoberta (setores descarregados: z=0, regeneram do seed ao visitar)
	if(islist(secdata))
		for(var/list/sd in secdata)
			if(!islist(sd) || sd.len < 3) continue
			var/datum/space_sector/S2 = new
			S2.sx = text2num(sd[1])
			S2.sy = text2num(sd[2])
			S2.name = sd[3]
			S2.seed = pspace_mix_seed(S2.sx, S2.sy)
			pspace_sectors["[S2.sx],[S2.sy]"] = S2
	spawn(600) pspace_cache_ticker() //snapshot periodico das construcoes
	if(islist(pladata))
		for(var/list/pd in pladata)
			if(!islist(pd) || pd.len < 9) continue
			var/datum/space_sector/owner = pspace_sectors["[pd[2]]"]
			if(!owner) continue
			var/datum/pspace_planet/D = new
			D.name = pd[1]
			D.sector = owner
			D.biome = text2num(pd[3])
			D.gravity = text2num(pd[4])
			D.tint = pd[5]
			D.pstate = pd[6]
			D.px = text2num(pd[7])
			D.py = text2num(pd[8])
			D.seed = text2num(pd[9])
			if(pd.len >= 10) D.player_named = text2num(pd[10]) //batismo ja usado (saves antigos: 9 campos)
			pspace_planets[D.name] = D
			owner.planets += D

//salva a galaxia descoberta (chamado ao criar setor novo; barato -- poucos setores)
proc/pspace_save()
	var/list/secdata = list()
	var/list/pladata = list()
	for(var/k in pspace_sectors)
		var/datum/space_sector/S = pspace_sectors[k]
		if(S.is_home) continue
		secdata += list(list("[S.sx]", "[S.sy]", S.name))
		for(var/datum/pspace_planet/D in S.planets)
			pladata += list(list(D.name, "[S.sx],[S.sy]", "[D.biome]", "[D.gravity]", D.tint, D.pstate, "[D.px]", "[D.py]", "[D.seed]", "[D.player_named]"))
	var/savefile/S = new("Galaxy")
	S["seed"] << pspace_seed
	S["sectors"] << secdata
	S["planets"] << pladata
	S["superdb"] << pspace_superdb
	S["sdb_benef_sig"] << sdb_benef_sig
	S["sdb_benef_name"] << sdb_benef_name
	S["sleepers"] << pspace_sleepers

// ---------------------------------------------------------------------------
// DATUMS
// ---------------------------------------------------------------------------
datum/space_sector
	var
		sx = 0
		sy = 0
		z = 0            // 0 = descarregado (regenera do seed quando visitado)
		seed = 0
		name = ""
		is_home = 0
		last_visit = 0
		tmp/generating = 0      // geracao em andamento (latch anti-corrida/anti-recycle)
		list/planets = list()   // /datum/pspace_planet
		list/spawned = list()   // objs criados no z do setor (limpos no recycle)

datum/pspace_planet
	var
		name = ""
		biome = ""             // indice na tabela de biomas
		gravity = 1
		tint = ""              // cor "#rrggbb" do planeta/da flora
		pstate = ""            // icon_state de Planets.dmi usado no espaco
		px = 0                 // posicao no setor
		py = 0
		seed = 0
		surface_z = 0          // 0 = superficie nao construida/reciclada
		tmp/generating = 0     // superficie sendo gerada AGORA (timestamp com heartbeat; latch anti-corrida/anti-recycle)
		tmp/gen_priority = 0   // 1 = tem jogador ESPERANDO pousar: geracao no ritmo rapido (0 = pre-aquecimento leve)
		last_visit = 0
		land_x = 0             // ponto de pouso em TERRA (o noise pode por agua no centro)
		land_y = 0
		player_named = 0       // batismo: o PRIMEIRO player a pousar pode nomear o planeta (1 = direito ja usado)
		list/land_spots = null // candidatos de pouso (x*1000+y): pousa longe de inimigos
		datum/space_sector/sector = null
		obj/Planets/Procedural/pobj = null
		area/pspace_planet/parea = null    // area propria (Planet = nome; reusada entre regens)
		list/spawned = list()  // objs+mobs da superficie (limpos no recycle)

// ---------------------------------------------------------------------------
// TABELAS DE GERACAO
// ---------------------------------------------------------------------------
var/list/pspace_name_a = list("Zar","Kel","Vor","Nam","Tsu","Bar","Ori","Gal","Xen","Mor","Tal","Ryu","Kae","Dor","Ves")
var/list/pspace_name_b = list("da","ko","ri","mu","ta","ze","no","va","li","sha","gar","dun","pex","or","ul")
var/list/pspace_name_c = list("nia","los","dar","mia","tek","rus","via","don","xis","prime","IV","VII","Menor","Maior","X")

//biomas -- indices da linha:
// [1] nome | [2] tint planicie | [3] tint flora (30% das copas) | [4] inimigo | [5] tint agua ("LAVA" = Water7)
// [6] tint colina | [7] tint montanha | [8] POOL de arvores (o kit sorteia 1-2 especies POR PLANETA) | [9] plantas colhiveis | [10] mult de minerio
var/list/pspace_biomes = list(
	list("Verdejante", "#ffffff", "#ffffff", /mob/npc/Enemy/Small_Saibaman, "#ffffff", "#c9d69a", "#9a9a8a", list(/obj/Trees/SmallTree, /obj/Trees/pspace/GoodTree, /obj/Trees/pspace/PineTree, /obj/Trees/pspace/JungleTree, /obj/Trees/Oaktree), list(/obj/Plants/Orange), 1),
	list("Gelido", "#bcd8f0", "#9fc4e8", /mob/npc/Enemy/Dragon, "#bfe8ff", "#a8c4e0", "#dfeaf5", list(/obj/Trees/pspace/SnowTree, /obj/Trees/pspace/PineTree, /obj/Trees/SmallTree), list(), 1),
	list("Deserto", "#e8cf7a", "#d8b860", /mob/npc/Enemy/Rat, "#8fd0c8", "#d8b860", "#b89848", list(/obj/Trees/PalmTree1), list(/obj/Plants/Opuntia), 1),
	list("Vulcanico", "#d8836a", "#7a5040", /mob/npc/Enemy/Dragon, "LAVA", "#b86048", "#6a4038", list(/obj/Trees/pspace/AshTree, /obj/Trees/pspace/CrimsonTree), list(), 2),
	list("Alienigena", "#c9a0e8", "#a878d8", /mob/npc/Enemy/Small_Saibaman, "#b080e0", "#a878d8", "#7858a8", list(/obj/Trees/pspace/NamekTall, /obj/Trees/pspace/NamekTall2, /obj/Trees/pspace/NamekSmall, /obj/Trees/pspace/TealTree, /obj/Trees/pspace/AlienShroom), list(/obj/Plants/Orange), 1),
	list("Sombrio", "#8a93a8", "#6a7388", /mob/npc/Enemy/Zombie, "#5a6378", "#6a7388", "#4a5368", list(/obj/Trees/pspace/CrimsonTree, /obj/Trees/pspace/AshTree, /obj/Trees/SmallTree), list(), 2))

var/list/pspace_planet_states = list("Earth", "Namek", "Vegeta", "Arlia", "Arconia", "Icer Planet")

proc/pspace_gen_name(datum/pspace_rng/R)
	var/nm = "[R.pickfrom(pspace_name_a)][R.pickfrom(pspace_name_b)][R.pickfrom(pspace_name_c)]"
	if(pspace_planets[nm]) nm = "[nm] [R.next(899) + 100]" //colisao de nome: sufixo numerico
	return nm

proc/pspace_gen_tint(datum/pspace_rng/R) //tint aleatorio claro (pro planeta no espaco)
	return rgb(120 + R.next(135), 120 + R.next(135), 120 + R.next(135))

// ---------------------------------------------------------------------------
// AREAS
// ---------------------------------------------------------------------------
area/pspace_sector //todos os setores compartilham: e "Space" pra todos os sistemas
	name = "Deep Space"
	Planet = "Space"
	exclude = 1
	HasWeather = 0
	HasNight = 0
	HasDay = 0
	HasMoon = 0
	PlayersCanSpawn = 0

area/pspace_planet //UMA instancia por planeta procedural (new): Planet = nome dele
	name = "Outside"
	exclude = 1
	HasWeather = 0
	HasMoon = 0
	PlayersCanSpawn = 0

// ---------------------------------------------------------------------------
// GRAVIDADE: lookup dos planetas procedurais (gancho no fim do switch do Grav())
// ---------------------------------------------------------------------------
proc/pspace_planet_grav(pl)
	if(!pl || !pspace_planets.len) return null
	var/datum/pspace_planet/D = pspace_planets[pl]
	if(D) return D.gravity
	return null

// ---------------------------------------------------------------------------
// SETORES: obter/criar/reciclar/gerar
// ---------------------------------------------------------------------------
proc/pspace_get_sector(sx, sy)
	pspace_boot()
	var/key = "[sx],[sy]"
	var/datum/space_sector/S = pspace_sectors[key]
	if(!S)
		S = new
		S.sx = sx
		S.sy = sy
		S.seed = pspace_mix_seed(sx, sy)
		var/datum/pspace_rng/R = new(S.seed)
		S.name = "Setor [R.pickfrom(pspace_name_a)][R.pickfrom(pspace_name_b)]"
		pspace_sectors[key] = S
	if(!S.z && !S.is_home) //precisa de um z: pool ou recycle
		//outro jogador ja esta gerando: espera COM PRAZO (o gerador pode ter morrido no meio --
		//relog do requerente deleta a pilha inteira SEM runtime; o latch travava pra sempre)
		while(S.generating && world.time - S.generating < PSPACE_GEN_TIMEOUT)
			sleep(5)
		if(S.generating) //estagnado alem do prazo: watchdog destrava e gera de novo
			WriteToLog("debug","pspace: geracao do setor [S.name] estagnada -- watchdog destravou")
			S.generating = 0
			S.z = 0
		if(!S.z)
			S.generating = world.time //timestamp: o watchdog reconhece latch morto
			try
				S.z = pspace_alloc_z(pspace_sector_zs, PSPACE_MAX_SECTORS, /proc/pspace_unload_sector_on)
				pspace_generate_sector(S)
			catch(var/exception/e)
				WriteToLog("debug","pspace: geracao do setor [S.name] FALHOU: [e] ([e.file]:[e.line])")
				S.z = 0
			S.generating = 0
	S.last_visit = world.time
	return S

//aloca um z de um pool: cria ate o teto, senao recicla o LRU sem players (dono e descarregado via unload_cb)
proc/pspace_alloc_z(list/pool, cap, unload_cb)
	if(pool.len < cap)
		world.maxz++
		pool += world.maxz
		pspace_pool_z["[world.maxz]"] = 1 //turfs deste z ficam FORA das listas de area (TurfOnNew.dm)
		return world.maxz
	//recicla: z do pool sem NENHUM client, cujo dono esta ha mais tempo sem visita
	var/bestz = 0
	var/bestvisit = 0
	for(var/pz in pool)
		var/busy = 0
		for(var/mob/M in player_list)
			if(M.client && M.z == pz)
				busy = 1
				break
		if(busy) continue
		var/lv = call(unload_cb)(pz, 1) //1 = so consultar last_visit
		if(lv >= 999999999) continue //dono marcado como intocavel (ex.: setor com player na SUPERFICIE de um planeta dele)
		if(!bestz || lv < bestvisit)
			bestz = pz
			bestvisit = lv
	if(!bestz) //todos ocupados: cresce alem do teto (memoria > quebrar exploracao)
		world.maxz++
		pool += world.maxz
		pspace_pool_z["[world.maxz]"] = 1
		WriteToLog("debug","pspace: pool estourou o teto ([cap]) -- novo z [world.maxz]")
		return world.maxz
	call(unload_cb)(bestz, 0) //descarrega o dono de verdade
	return bestz

//LIMPEZA EM LOTE de um z do pool. NUNCA del em massa aqui: cada del no BYOND faz uma
//cacada GLOBAL de referencias, e o obj/Del ainda paga obj_list -= src (varredura linear
//da lista global POR OBJETO; item_list idem) -- descarregar uma superficie com milhares
//de flora/minerio CONGELAVA o mundo por minutos sem processar tick (o world.time para
//junto, entao o log jurava "5s"). Aqui: tudo que RENASCE da seed (spawned/pspace_wild)
//sai por loc=null (GC por refcount, sem cacada) e obj_list/item_list sao RECONSTRUIDAS
//em uma unica passada; del de verdade sobra so pro punhado de coisa de jogador (maquina
//com Ticker while(src), nave, item largado -- que virariam zumbi com loc=null).
proc/pspace_z_wipe(pz, list/spawned)
	if(spawned)
		for(var/obj/o in spawned) if(o) o.pspace_wild = 1 //conteudo gerado: caminho barato (renasce na regen)
		spawned.Cut()
	var/list/okeep = list()
	var/list/hard = list() //os poucos que precisam de del real
	for(var/obj/O in obj_list)
		if(!O) continue
		if(O.z != pz)
			okeep += O
			continue
		if(O.pspace_wild) O.loc = null //GC coleta; plantas/blasts saem dos proprios loops via loc
		else hard += O
	obj_list = okeep
	var/list/ikeep = list() //item_list: mesma reconstrucao (o caminho GC nao roda Del() = ninguem faria o -=)
	for(var/obj/items/I in item_list)
		if(I && !(I.z == pz && I.pspace_wild)) ikeep += I
	item_list = ikeep
	for(var/obj/o in hard)
		if(!o) continue
		if(istype(o, /obj/items)) o:amount = 1 //pilha: o Del() de items so DECREMENTA amount>1 e o obj sobrevivia no z reciclado
		del o
	for(var/mob/npc/N in mob_list.Copy()) //mob_list, NUNCA "in world" (varre TODOS os atomos do mundo, turfs inclusos)
		if(N && N.z == pz) del N //poucos: cidadaos/monstros precisam de del real (loops de IA seguram a ref)

//descarrega o SETOR que ocupa o z (cb do alloc): devolve last_visit no modo consulta
proc/pspace_unload_sector_on(pz, peek)
	for(var/k in pspace_sectors)
		var/datum/space_sector/S = pspace_sectors[k]
		if(S.z != pz || S.is_home) continue
		if(peek)
			if(S.generating) return 999999999 //NUNCA reciclar um z sendo gerado (duas geracoes no mesmo z = caos)
			//player na SUPERFICIE de um planeta deste setor: reciclar mataria o obj do
			//planeta e o Stars_Exit da superficie nao teria pra onde voltar (preso!)
			for(var/datum/pspace_planet/D in S.planets)
				if(!D.surface_z) continue
				for(var/mob/M in player_list)
					if(M.client && M.z == D.surface_z) return 999999999
			return S.last_visit
		pspace_z_wipe(pz, S.spawned) //limpeza em LOTE (del em massa congelava o mundo por minutos)
		for(var/datum/pspace_planet/D in S.planets)
			D.pobj = null //solta a ultima ref -> o GC coleta o obj do planeta
		S.z = 0 //revisita regenera do seed
		return 0
	return 0

//descarrega a SUPERFICIE que ocupa o z (cb do alloc)
proc/pspace_unload_surface_on(pz, peek)
	for(var/pn in pspace_planets)
		var/datum/pspace_planet/D = pspace_planets[pn]
		if(D.surface_z != pz) continue
		if(peek)
			if(D.generating) return 999999999 //superficie sendo gerada AGORA: reciclar = duas geracoes brigando pelo z (horda de NPC duplicada, terreno misturado)
			return D.last_visit
		pspace_builds_snapshot(D) //construcoes dos jogadores sobrevivem ao recycle (re-aplicadas na regen)
		pspace_z_wipe(pz, D.spawned) //limpeza em LOTE (del em massa congelava o mundo por minutos)
		D.surface_z = 0
		return 0
	return 0

//gera o conteudo do setor no z dele (deterministico pelo seed)
proc/pspace_generate_sector(datum/space_sector/S)
	var/datum/pspace_rng/R = new(S.seed)
	var/area/SA = locate(/area/pspace_sector)
	var/gen_t0 = world.time
	//regiao util [1..PSPACE_SIZE]^2: estrelas, com anel de borda que cruza de setor
	for(var/xx = 1 to PSPACE_SIZE)
		if(xx % PSPACE_GEN_COLSTRIDE == 0 && world.tick_usage > PSPACE_GEN_TICKCAP) sleep(world.tick_lag) //cede 1 tick por LOTE de colunas (igual a superficie)
		for(var/yy = 1 to PSPACE_SIZE)
			if(xx == 1 || yy == 1 || xx == PSPACE_SIZE || yy == PSPACE_SIZE)
				new/turf/pspace_edge(locate(xx, yy, S.z))
			else
				new/turf/Other/Stars(locate(xx, yy, S.z))
	if(SA) SA.contents.Add(block(locate(1, 1, S.z), locate(PSPACE_SIZE, PSPACE_SIZE, S.z))) //area em UM bloco
	//planetas (se ainda nao existem os datums; num setor reciclado eles ja existem)
	if(!S.planets.len)
		var/n = PSPACE_MIN_PLANETS + R.next(PSPACE_MAX_PLANETS - PSPACE_MIN_PLANETS + 1) - 1
		for(var/i = 1 to n)
			var/datum/pspace_planet/D = new
			D.sector = S
			D.seed = (S.seed * 31 + i * 977) % 134456 + 1
			var/datum/pspace_rng/PR = new(D.seed)
			D.name = pspace_gen_name(PR)
			D.biome = PR.next(pspace_biomes.len)
			D.pstate = PR.pickfrom(pspace_planet_states)
			D.tint = pspace_gen_tint(PR)
			//gravidade: maioria leve, cauda pesada (com o esmagamento, planeta 40x+ e zona de morte)
			var/gr = PR.next(100)
			if(gr <= 55) D.gravity = PR.next(5)
			else if(gr <= 85) D.gravity = 5 + PR.next(10)
			else if(gr <= 97) D.gravity = 15 + PR.next(25)
			else D.gravity = 40 + PR.next(40)
			D.px = 20 + PR.next(PSPACE_SIZE - 40)
			D.py = 20 + PR.next(PSPACE_SIZE - 40)
			pspace_planets[D.name] = D
			S.planets += D
	//instancia os objs dos planetas
	for(var/datum/pspace_planet/D in S.planets)
		var/obj/Planets/Procedural/P = new(locate(D.px, D.py, S.z))
		P.planetType = D.name
		P.name = D.name
		P.planetIcon = 'Planets.dmi'
		P.planetState = D.pstate
		P.icon = P.planetIcon
		P.icon_state = D.pstate
		P.color = D.tint
		P.pdatum = D
		if(D.name in PlanetDisableList) //foi DESTRUIDO numa sessao passada: renasce destruido (a lista persiste via PerWipeSettings)
			P.isDestroyed = 1
			P.icon = null
			P.density = 0
		D.pobj = P
		S.spawned += P
	//Super Dragon Ball escondida neste setor? (entrada viva = ainda nao coletada)
	if(islist(pspace_superdb))
		for(var/list/E in pspace_superdb)
			if(!E[6] && E[2] == S.sx && E[3] == S.sy)
				S.spawned += pspace_sdb_spawn(E, S.z)
	pspace_save() //persiste a galaxia descoberta (nomes de setor + planetas conhecidos)
	WriteToLog("debug","pspace: setor [S.name] ([S.sx],[S.sy]) gerado em [(world.time - gen_t0) / 10]s")

// ---------------------------------------------------------------------------
// CRUZAMENTO DE BORDA
// ---------------------------------------------------------------------------
proc/pspace_cross(mob/M, edge_dir)
	if(!M || !M.client) return //so player puxa geracao (NPC/projetil nao abre setor)
	pspace_boot()
	var/datum/space_sector/cur = pspace_sector_for_z(M.z)
	if(!cur) return
	var/nx = cur.sx
	var/ny = cur.sy
	switch(edge_dir)
		if(NORTH) ny++
		if(SOUTH) ny--
		if(EAST) nx++
		if(WEST) nx--
	if(!M.pspace_crossing) //latch: o Entered pode disparar mais de uma vez no mesmo passo
		M.pspace_crossing = 1
		to_chat(M, "<font color=#88ccff>Cruzando pro setor ([nx], [ny])...</font>")
		var/datum/space_sector/dest = pspace_get_sector(nx, ny) //pode GERAR (alguns segundos)
		if(!dest || (!dest.z && !dest.is_home))
			M.pspace_crossing = 0
			return
		var/dz = dest.is_home ? PSPACE_HOME_Z : dest.z
		//chega na borda OPOSTA, posicao proporcional ao longo do eixo
		var/dsize = dest.is_home ? min(world.maxx, world.maxy) : PSPACE_SIZE
		var/csize = cur.is_home ? min(world.maxx, world.maxy) : PSPACE_SIZE
		var/tx = M.x
		var/ty = M.y
		switch(edge_dir)
			if(NORTH)
				ty = 3
				tx = max(3, min(dsize - 2, round(M.x * dsize / csize)))
			if(SOUTH)
				ty = dsize - 2
				tx = max(3, min(dsize - 2, round(M.x * dsize / csize)))
			if(EAST)
				tx = 3
				ty = max(3, min(dsize - 2, round(M.y * dsize / csize)))
			if(WEST)
				tx = dsize - 2
				ty = max(3, min(dsize - 2, round(M.y * dsize / csize)))
		M.loc = locate(tx, ty, dz)
		to_chat(M, "<font color=#88ccff><b>[dest.name] ([nx], [ny])</b> -- [dest.is_home ? "espaco conhecido" : "[dest.planets.len] corpo\s celeste\s no sensor"].</font>")
		if(!dest.is_home) spawn(10) pspace_pregen_sector(dest) //PRE-AQUECE as superficies em background: pousar vira instantaneo
		spawn(5) if(M) M.pspace_crossing = 0

mob/var/tmp/pspace_crossing = 0
mob/var/tmp/pspace_noland_until = 0 //graca anti-rebump: acabou de SAIR de um planeta (borda/decolagem) -> nao re-pousa sem querer
mob/var/tmp/pspace_noland_msg = 0   //rate-limit da dica

//qual setor e este z? (home/setor gerado; null = nao e espaco)
proc/pspace_sector_for_z(z)
	if(z == PSPACE_HOME_Z) return pspace_sectors["0,0"]
	for(var/k in pspace_sectors)
		var/datum/space_sector/S = pspace_sectors[k]
		if(S.z == z) return S
	return null

//borda de um setor gerado
turf/pspace_edge
	icon = 'spacebck.dmi'
	destroyable = 0
	New()
		..()
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	Entered(atom/movable/O)
		..()
		if(!ismob(O)) return
		var/mob/M = O
		var/ed = 0
		if(y >= PSPACE_SIZE) ed = NORTH
		else if(y <= 1) ed = SOUTH
		else if(x >= PSPACE_SIZE) ed = EAST
		else if(x <= 1) ed = WEST
		if(ed) pspace_cross(M, ed)

//montanha dos planetas procedurais: parede densa e permanente, SOBREVOAVEL (igual as
//rochas dos mapas canonicos). O Void_Wall usado antes tinha state PRETO ('Hell turf.dmi')
//e opacity=1 -- alem do tile preto, a opacidade pintava de preto a visao atras da
//cordilheira (as "zonas pretas" que apareciam nos planetas)
turf/pspace_mountain
	icon = 'JEFcliff.dmi'
	icon_state = ""
	density = 1
	opacity = 0
	destroyable = 0
	Enter(atom/movable/O)
		if(ismob(O))
			var/mob/M = O
			if(M.flight) return 1
			return 0
		return 1

//borda do espaco ORIGINAL (z26): as pontas do mapa .dmm viram fronteira
turf/Other/Stars/Entered(atom/movable/O)
	..()
	if(z != PSPACE_HOME_Z || !ismob(O)) return
	var/mob/M = O
	var/ed = 0
	if(y >= world.maxy - 1) ed = NORTH
	else if(y <= 2) ed = SOUTH
	else if(x >= world.maxx - 1) ed = EAST
	else if(x <= 2) ed = WEST
	if(ed) pspace_cross(M, ed)

// ---------------------------------------------------------------------------
// PLANETA PROCEDURAL (obj no espaco) + POUSO
// ---------------------------------------------------------------------------
obj/Planets/Procedural
	isMoving = 0     //parado: nav e pouso previsiveis (e o wander dos quadrantes nao vale aqui)
	destroyAble = 1
	var/datum/pspace_planet/pdatum = null

proc/pspace_land(mob/M, obj/Planets/Procedural/P)
	if(!M || !P || !P.pdatum) return
	//GRACA ANTI-REBUMP: sair do planeta (borda/decolagem) solta o mob COLADO no obj (view(1,P));
	//um passo na direcao que ele ja segurava dava Bump -> re-pouso involuntario "na frente dos bichos"
	if(M.pspace_noland_until > world.time)
		if(M.client && world.time >= M.pspace_noland_msg)
			M.pspace_noland_msg = world.time + 30
			to_chat(M, "<font color=#88ccff>Voce acabou de deixar a orbita -- afaste-se e encoste de novo para pousar.</font>")
		return
	var/datum/pspace_planet/D = P.pdatum
	if(D.generating) //JA esta sendo mapeado (Bump dispara varias vezes): nao gera 2x nem pousa num mapa pela metade
		if(world.time - D.generating > PSPACE_GEN_TIMEOUT) //WATCHDOG: o gerador morreu no meio -- destrava e recomeca
			WriteToLog("debug","pspace: geracao de [D.name] estagnada ha [(world.time - D.generating) / 10]s -- watchdog destravou")
			D.generating = 0
			D.surface_z = 0 //mapa pela metade: regenera do zero
		else
			D.gen_priority = 1 //encostou num planeta em PRE-AQUECIMENTO: acelera a geracao ao vivo
			if(M.client && world.time >= M.pspace_noland_msg)
				M.pspace_noland_msg = world.time + 30
				to_chat(M, "<font color=#88ccff>Ainda mapeando o terreno de [D.name] -- um instante...</font>")
			return
	if(!D.surface_z) //constroi/regenera num WORKER destacado: quem pediu pousa sozinho ao final
		if(M.client) to_chat(M, "<font color=#88ccff>Entrando na atmosfera de [D.name]... (mapeando o terreno, aguarde em orbita)</font>")
		pspace_gen_request(D, M)
		return
	D.last_visit = world.time
	//ponto de pouso SEGURO: tenta candidatos de planicie sem inimigo por perto (senao cai no central)
	var/turf/spot = locate(max(2, D.land_x), max(2, D.land_y), D.surface_z)
	if(islist(D.land_spots) && D.land_spots.len)
		for(var/attempt = 1 to min(8, D.land_spots.len))
			var/enc = pick(D.land_spots)
			var/turf/cand = locate(round(enc / 1000), enc % 1000, D.surface_z)
			if(!cand) continue
			var/hostiles = 0
			for(var/mob/npc/N in range(8, cand))
				hostiles = 1
				break
			if(!hostiles)
				spot = cand
				break
	M.loc = spot
	M.Planet = D.name
	if(M.client) to_chat(M, "<font color=#88ccff><b>[D.name]</b> -- bioma [pspace_biomes[D.biome][1]], gravidade x[D.gravity].[D.gravity > M.GravMastered ? " <font color=red>CUIDADO: acima da sua maestria!</font>" : ""]</font>")
	if(M.client && !D.player_named) //BATISMO: o direito e do PRIMEIRO player a pisar no mundo
		D.player_named = 1
		pspace_save()
		spawn(2) pspace_offer_name(M, D)

//dispara a geracao da superficie num proc DESTACADO do requerente. A geracao inline morria
//JUNTO com o mob (relog no meio deletava a pilha inteira SEM runtime error) e o latch
//"generating" travava pra sempre -- todo pouso seguinte via "Ainda mapeando..." eterno.
var/pspace_gen_active = 0 //geracoes de superficie RODANDO agora (fila global)

proc/pspace_gen_request(datum/pspace_planet/D, mob/M)
	if(!D || D.generating || D.surface_z) return
	D.generating = world.time //timestamp: o watchdog reconhece latch morto
	D.gen_priority = M ? 1 : 0 //com requerente = ritmo rapido; pre-aquecimento = leve
	spawn(0)
		//FILA GLOBAL: um rush de logins disparava N geracoes SIMULTANEAS e esmagava o tick --
		//no maximo 2 por vez; as demais esperam na fila (com heartbeat pro watchdog)
		while(pspace_gen_active >= 2)
			D.generating = world.time
			sleep(10)
		pspace_gen_active++
		var/ok = 0
		try
			D.surface_z = pspace_alloc_z(pspace_surface_zs, psurf_pool_cap, /proc/pspace_unload_surface_on)
			pspace_generate_surface(D)
			ok = 1
		catch(var/exception/e)
			WriteToLog("debug","pspace: geracao de [D.name] FALHOU: [e] ([e.file]:[e.line])")
			D.surface_z = 0
		pspace_gen_active--
		D.generating = 0
		D.gen_priority = 0
		if(!ok || !M) return
		//quem pediu e continuou colado no planeta pousa sozinho; quem se afastou so recebe o aviso
		if(M.client && D.pobj && M.z == D.pobj.z && get_dist(M, D.pobj) <= 2)
			pspace_land(M, D.pobj)
		else if(M.client)
			to_chat(M, "<font color=#88ccff>[D.name] mapeado. Encoste de novo para pousar.</font>")

//PRE-AQUECIMENTO: ao entrar num setor, as superficies dos planetas dele sao mapeadas em
//background (um por vez) -- quando o jogador chega no planeta, o pouso e instantaneo
var/pspace_pregen_busy = 0
proc/pspace_pregen_sector(datum/space_sector/S)
	if(!S || S.is_home || pspace_pregen_busy) return //um pre-aquecimento por vez no servidor
	pspace_pregen_busy = 1
	for(var/datum/pspace_planet/D in S.planets)
		if(!S.z) break //setor foi reciclado no meio tempo
		if(D.surface_z || D.generating) continue
		if(D.pobj && D.pobj.isDestroyed) continue //destruido: sem superficie
		var/haspl = 0
		for(var/mob/PM in player_list)
			if(PM && PM.client && PM.z == S.z)
				haspl = 1
				break
		if(!haspl) break //ninguem mais no setor: nao gasta CPU
		pspace_gen_request(D, null)
		while(D.generating) sleep(10)
	pspace_pregen_busy = 0

//BATISMO: o primeiro jogador a pousar num mundo procedural escolhe o nome dele
proc/pspace_offer_name(mob/M, datum/pspace_planet/D)
	if(!M || !M.client || !D) return
	var/nm = input(M, "Voce e o primeiro ser a pisar neste mundo! Que nome ele recebera? (Cancele para manter '[D.name]')", "Batizar o planeta", D.name) as text|null
	if(!nm || !D || !M) return
	nm = html_encode(nm)
	while(length(nm) && copytext(nm, 1, 2) == " ") nm = copytext(nm, 2) //trim
	while(length(nm) && copytext(nm, length(nm)) == " ") nm = copytext(nm, 1, length(nm))
	if(nm == D.name) return
	if(length(nm) < 3 || length(nm) > 24)
		to_chat(M, "<font color=#e8b64c>Nome invalido (3 a 24 caracteres). O planeta continua [D.name].</font>")
		return
	if(pspace_planets[nm])
		to_chat(M, "<font color=#e8b64c>Ja existe um planeta com esse nome. O planeta continua [D.name].</font>")
		return
	for(var/obj/Planets/PL in planet_list) //nomes canonicos (Earth/Vegeta/...) colidem com o switch do Grav()
		if(PL && PL.planetType == nm)
			to_chat(M, "<font color=#e8b64c>Esse nome pertence a um mundo conhecido. O planeta continua [D.name].</font>")
			return
	pspace_rename_planet(D, nm, M)

proc/pspace_rename_planet(datum/pspace_planet/D, newname, mob/M)
	var/old = D.name
	pspace_planets -= old
	D.name = newname
	pspace_planets[newname] = D //a gravidade/pouso fazem lookup por NOME: re-chavear e obrigatorio
	pspace_builds_migrate(old, newname) //cache de construcoes acompanha o batismo
	if(old in pspace_sleepers)
		pspace_sleepers -= old
		pspace_sleepers += newname
	if(D.pobj)
		D.pobj.name = newname
		D.pobj.planetType = newname
	if(D.parea) D.parea.Planet = newname
	for(var/mob/X in mob_list) //quem ja esta NO planeta (M.Planet alimenta o Grav())
		if(X && X.Planet == old) X.Planet = newname
	pspace_save()
	to_chat(world, "<font color=#e8b64c><b>[M ? M.name : "Alguem"] batizou um novo mundo: [old] agora se chama [newname]!</b></font>", "events")
	WriteToLog("debug","pspace: planeta [old] renomeado para [newname] por [M ? M.name : "?"]")

// ---------------------------------------------------------------------------
// POSICAO PERSISTENTE: xco/yco/zco salvos apontavam pra um z de POOL que nao
// sobrevive a reboot/recycle -- o load caia no spawn da raca (ou num mundo
// ERRADO se o z foi reciclado). Salvamos o CONTEXTO (planeta ou setor) no
// Write() do mob e reconstruimos no login (geracao deterministica: o terreno
// volta identico, entao o x/y salvo continua valendo).
// ---------------------------------------------------------------------------
mob/var/pspace_ctx_planet = ""  //deslogou na SUPERFICIE deste planeta procedural
mob/var/pspace_ctx_insector = 0 //deslogou no ESPACO de um setor procedural
mob/var/pspace_ctx_sx = 0
mob/var/pspace_ctx_sy = 0

mob/proc/pspace_ctx_set() //chamado no mob/Write (roda em TODO save)
	pspace_ctx_planet = ""
	pspace_ctx_insector = 0
	pspace_ctx_sx = 0
	pspace_ctx_sy = 0
	if(!z || !pspace_booted) return
	for(var/pn in pspace_planets)
		var/datum/pspace_planet/D = pspace_planets[pn]
		if(D && D.surface_z == z)
			pspace_ctx_planet = D.name
			if(!(D.name in pspace_sleepers)) //o startup prioriza mundos com gente dormindo
				pspace_sleepers += D.name
				if(pspace_sleepers.len > 16) pspace_sleepers.Cut(1, 2) //rolante: os 16 mais recentes
				pspace_save()
			return
	var/datum/space_sector/S = pspace_sector_for_z(z)
	if(S && !S.is_home)
		pspace_ctx_insector = 1
		pspace_ctx_sx = S.sx
		pspace_ctx_sy = S.sy

proc/pspace_login_restore(mob/M)
	if(!M || !M.client) return
	if(!M.pspace_ctx_planet && !M.pspace_ctx_insector) return
	var/tx = M.xco
	var/ty = M.yco
	spawn(10) //worker destacado (nao morre com relog) + 1s pro OnLogin assentar antes do teleporte
		pspace_boot()
		if(M && M.client && M.pspace_ctx_planet) //dormiu na superficie de um planeta
			var/datum/pspace_planet/D = pspace_planets[M.pspace_ctx_planet]
			if(!D || (D.name in PlanetDisableList))
				to_chat(M, "<font color=#e8b64c>O mundo onde voce dormiu ([M.pspace_ctx_planet]) nao existe mais...</font>")
				M.pspace_ctx_planet = ""
				return
			if(D.sector) pspace_get_sector(D.sector.sx, D.sector.sy) //recarrega o setor: o planeta precisa existir no espaco (decolagem/orbita)
			if(!D.surface_z)
				to_chat(M, "<font color=#88ccff>Remapeando [D.name] -- voce voltara ao ponto onde estava...</font>")
				pspace_gen_request(D, null) //null: o teleporte de volta e NOSSO (nao e pouso)
				D.gen_priority = 1 //mas o jogador esta esperando: ritmo rapido
				while(D && D.generating) sleep(10)
			if(!M || !M.client || !D || !D.surface_z) return
			var/turf/T = locate(max(2, min(PSURF_SIZE - 1, tx)), max(2, min(PSURF_SIZE - 1, ty)), D.surface_z)
			if(!T) return
			if(T.density) T = locate(max(2, D.land_x), max(2, D.land_y), D.surface_z) //deslogou voando sobre montanha: volta pelo pouso
			M.loc = T
			M.Planet = D.name
			D.last_visit = world.time
			to_chat(M, "<font color=#88ccff>Voce acorda em <b>[D.name]</b>, onde havia parado.</font>")
		else if(M && M.client && M.pspace_ctx_insector) //dormiu a deriva no espaco de um setor
			var/datum/space_sector/S = pspace_get_sector(M.pspace_ctx_sx, M.pspace_ctx_sy)
			if(!M || !M.client || !S || !S.z) return
			M.loc = locate(max(2, min(PSPACE_SIZE - 1, tx)), max(2, min(PSPACE_SIZE - 1, ty)), S.z)
			to_chat(M, "<font color=#88ccff>Voce desperta a deriva em <b>[S.name]</b> ([S.sx], [S.sy]).</font>")

// ---------------------------------------------------------------------------
// CACHE DE CONSTRUCOES ("PlanetCache"): o TERRENO regenera da seed (deterministico,
// ~5s -- mais rapido que carregar .dmm), mas o que os JOGADORES construiram
// (turf/build + obj/buildables) e salvo FLAT por planeta e re-aplicado apos
// cada regeneracao. Snapshot: no unload do pool, no shutdown e a cada 5 min.
// ---------------------------------------------------------------------------
//maquinas de tech que persistem INTEIRAS no PlanetCache (serializacao nativa do savefile:
//upgrades/energia/conteudo sobrevivem). Todas ja nascem com SaveItem=1 (design do MapSave)
proc/pspace_is_machine(obj/O)
	return (istype(O, /obj/Technology) || istype(O, /obj/DNALab) || istype(O, /obj/items/Gravity) || istype(O, /obj/items/Clone_Machine) || istype(O, /obj/items/Regenerator) || istype(O, /obj/items/Simulator) || istype(O, /obj/items/Radar))

proc/pspace_builds_snapshot(datum/pspace_planet/D, list/pre_objs = null)
	if(!D || !D.surface_z) return
	var/list/tdata = list()
	for(var/turf/build/T in turfsave) //todo turf construido entra na turfsave (buildable.dm)
		if(T.z != D.surface_z) continue
		tdata += list(list("[T.type]", T.x, T.y, T.icon, "[T.icon_state]", T.density, T.opacity, "[T.proprietor]", T.Resistance))
	var/list/odata = list() //mobilias construidas
	var/list/pdata = list() //plantacoes (com estagio de crescimento)
	var/list/rdata = list() //arvores plantadas
	var/list/vdata = list() //naves/pods estacionados
	var/list/mdata = list() //maquinas de tech (bench/gravidade/labs/clonagem...): objs INTEIROS
	//pre_objs: o cache_ticker passa a lista JA filtrada do z (varrer a obj_list inteira POR
	//planeta custava ~100ms x N planetas residentes = solavanco de segundos a cada 5 min)
	for(var/obj/O in (islist(pre_objs) ? pre_objs : obj_list))
		if(!O || O.z != D.surface_z || O.pspace_wild) continue //flora do TERRENO renasce da seed
		if(istype(O, /obj/buildables))
			odata += list(list("[O.type]", O.x, O.y, O.icon, "[O.icon_state]", O.density, O.dir, "[O.name]", "[O.proprietor]"))
		else if(istype(O, /obj/Plants))
			var/obj/Plants/P = O
			pdata += list(list("[P.type]", P.x, P.y, P.currentstage, P.growthMeter, P.growthPercent, "[P.planter]"))
		else if(istype(O, /obj/Trees))
			rdata += list(list("[O.type]", O.x, O.y, "[O.color]"))
		else if(istype(O, /obj/Spacepod))
			var/obj/Spacepod/V = O
			vdata += list(list("[V.type]", V.x, V.y, V.dir, "[V.name]", "[V.channel]", "[V.link]", V.Speed))
		else if(pspace_is_machine(O))
			O.saved_x = O.x //padrao MapSave: as coords viajam DENTRO do obj serializado
			O.saved_y = O.y
			mdata += O
	if(!tdata.len && !odata.len && !pdata.len && !rdata.len && !vdata.len && !mdata.len && !fexists("PlanetCache")) return
	var/savefile/S = new("PlanetCache")
	S["b_[D.name]"] << tdata
	S["o_[D.name]"] << odata
	S["p_[D.name]"] << pdata
	S["r_[D.name]"] << rdata
	S["v_[D.name]"] << vdata
	S["m_[D.name]"] << mdata

proc/pspace_builds_restore(datum/pspace_planet/D)
	if(!D || !D.surface_z || !fexists("PlanetCache")) return
	var/savefile/S = new("PlanetCache")
	var/list/tdata = null
	var/list/odata = null
	S["b_[D.name]"] >> tdata
	S["o_[D.name]"] >> odata
	var/n = 0
	if(islist(tdata))
		for(var/list/e in tdata)
			if(!islist(e) || e.len < 9) continue
			var/tp = text2path(e[1])
			if(!tp) continue
			var/turf/base = locate(e[2], e[3], D.surface_z)
			if(!base) continue
			var/uic = base.icon //o chao regenerado vira o underlay (mesma logica do BuildATileHere)
			var/ust = base.icon_state
			var/turf/build/T = new tp(locate(e[2], e[3], D.surface_z))
			T.icon = e[4]
			T.icon_state = e[5]
			T.density = e[6]
			T.opacity = e[7]
			T.proprietor = e[8]
			T.Resistance = e[9]
			T.underlays += image(uic, icon_state = ust)
			turfsave.Add(T)
			n++
	if(islist(odata))
		for(var/list/e in odata)
			if(!islist(e) || e.len < 9) continue
			var/tp = text2path(e[1])
			if(!tp) continue
			var/obj/O = new tp(locate(e[2], e[3], D.surface_z))
			O.icon = e[4]
			O.icon_state = e[5]
			O.density = e[6]
			O.dir = e[7]
			O.name = e[8]
			O.proprietor = e[9]
			n++
	//AREA CONSTRUIDA e zona do jogador: flora/pedra selvagem que a seed rolou em cima de
	//turf construido ou de mobilia SOME (plantas/arvores "arrancadas" voltavam DENTRO da
	//base a cada boot -- a seed regenera o mato, mas construcao marca o chao como domado)
	for(var/list/zone in list(tdata, odata))
		if(!islist(zone)) continue
		for(var/list/e in zone)
			if(!islist(e) || e.len < 3) continue
			var/turf/BT = locate(e[2], e[3], D.surface_z)
			if(!BT) continue
			for(var/obj/W in BT)
				if(W && W.pspace_wild)
					obj_list -= W
					item_list -= W
					W.loc = null //GC coleta (mesma receita do wipe)
	var/list/pdata = null
	var/list/rdata = null
	var/list/vdata = null
	S["p_[D.name]"] >> pdata
	S["r_[D.name]"] >> rdata
	S["v_[D.name]"] >> vdata
	if(islist(pdata)) //plantacoes: voltam no MESMO estagio de crescimento
		for(var/list/e in pdata)
			if(!islist(e) || e.len < 7) continue
			var/tp = text2path(e[1])
			if(!tp) continue
			var/obj/Plants/P = new tp(locate(e[2], e[3], D.surface_z))
			P.currentstage = e[4]
			P.growthMeter = e[5]
			P.growthPercent = e[6]
			P.planter = e[7]
			P.icon_state = "stage [P.currentstage]"
			n++
	if(islist(rdata)) //arvores plantadas
		for(var/list/e in rdata)
			if(!islist(e) || e.len < 4) continue
			var/tp = text2path(e[1])
			if(!tp) continue
			var/obj/O = new tp(locate(e[2], e[3], D.surface_z))
			if(e[4] && e[4] != "null") O.color = e[4]
			n++
	if(islist(vdata)) //naves/pods estacionados (o LINK do Call_Ship sobrevive)
		for(var/list/e in vdata)
			if(!islist(e) || e.len < 8) continue
			var/tp = text2path(e[1])
			if(!tp) continue
			var/obj/Spacepod/V = new tp(locate(e[2], e[3], D.surface_z))
			V.dir = e[4]
			V.name = e[5]
			V.channel = e[6]
			V.link = e[7] //o New sorteia link novo: restaura o original (senao o Call_Ship perde a nave)
			V.Speed = e[8]
			n++
	var/list/mdata = null
	S["m_[D.name]"] >> mdata
	if(islist(mdata)) //maquinas INTEIRAS (o >> ja recriou os objs com upgrades/energia/conteudo)
		for(var/obj/M in mdata)
			if(!M) continue
			M.loc = locate(max(2, M.saved_x), max(2, M.saved_y), D.surface_z)
			if(istype(M, /obj/items/Gravity)) //campo NAO sobrevive ao reboot: caches antigos traziam caixas fantasma na BB (bounds() estourava e travava o Click) -- volta DESLIGADA e limpa
				var/obj/items/Gravity/GM = M
				GM.BB = list()
				GM.Grav = 0
				GM.overlays.Cut()
			if(hascall(M, "Ticker")) spawn call(M, "Ticker")() //o >> NAO roda New(): religa o loop interno (gravidade/regenerator)
			n++
	if(n) WriteToLog("debug","pspace: [n] construcoes/plantas/naves restauradas em [D.name]")

proc/pspace_builds_migrate(oldname, newname) //planeta batizado: o cache muda de chave
	if(!fexists("PlanetCache")) return
	var/savefile/S = new("PlanetCache")
	for(var/pref in list("b", "o", "p", "r", "v", "m"))
		var/list/data = null
		S["[pref]_[oldname]"] >> data
		if(islist(data)) S["[pref]_[newname]"] << data
		S.dir.Remove("[pref]_[oldname]")

proc/pspace_shutdown_save() //shutdown: snapshot de toda superficie carregada
	for(var/pn in pspace_planets)
		var/datum/pspace_planet/D = pspace_planets[pn]
		if(D && D.surface_z && !D.generating) pspace_builds_snapshot(D)

world/Del()
	pspace_shutdown_save()
	..()

proc/pspace_cache_ticker() //snapshot periodico (crash do servidor nao come a casa de ninguem)
	set waitfor = 0
	while(1)
		sleep(3000) //5 min
		//UMA varredura da obj_list para TODOS os planetas (por planeta era ~100ms x N residentes)
		var/list/perz = list() //"z" -> objs de jogador naquele z
		var/i = 0
		for(var/obj/O in obj_list)
			if(++i % 8192 == 0) sleep(world.tick_lag) //nunca segura o tick
			if(!O || O.pspace_wild || !O.z) continue
			if(istype(O, /obj/buildables) || istype(O, /obj/Plants) || istype(O, /obj/Trees) || istype(O, /obj/Spacepod) || pspace_is_machine(O))
				var/k = "[O.z]"
				if(!perz[k]) perz[k] = list()
				var/list/L = perz[k]
				L += O
		for(var/pn in pspace_planets)
			var/datum/pspace_planet/D = pspace_planets[pn]
			if(D && D.surface_z && !D.generating)
				pspace_builds_snapshot(D, perz["[D.surface_z]"] || list())
				sleep(5)

// ---- STARTUP: no boot do servidor, gera a superficie de TODOS os planetas ja
// conhecidos em poder total ANTES de liberar o login -- quem deslogou num planeta
// volta direto pro lugar, sem espera, e um rush de logins nao dispara geracoes ----
proc/pspace_startup()
	set waitfor = 0
	pspace_boot()
	var/list/todo = list()
	//PRIORIDADE: mundos onde o jogo SABE que ha jogador com save (eles precisam estar prontos ANTES do spawn)
	for(var/pname in pspace_sleepers)
		var/datum/pspace_planet/D = pspace_planets[pname]
		if(!D || D.surface_z || (D in todo)) continue
		if(D.name in PlanetDisableList) continue
		todo += D
	for(var/pn in pspace_planets) //depois os demais explorados
		var/datum/pspace_planet/D = pspace_planets[pn]
		if(!D || D.surface_z || (D in todo)) continue
		if(D.name in PlanetDisableList) continue //destruido: sem superficie
		todo += D
	if(todo.len > PSPACE_BOOT_MAX) //teto de memoria (dd 32-bit): corta os SEM save (o resto fica por demanda)
		WriteToLog("debug","pspace: startup com [todo.len] planetas conhecidos -- gerando os [PSPACE_BOOT_MAX] prioritarios")
		todo.Cut(PSPACE_BOOT_MAX + 1)
	psurf_pool_cap = max(PSURF_MAX_SURFACES, todo.len + 4) //os do boot ficam residentes + folga pra exploracao nova
	var/total = todo.len
	var/done = 0
	pspace_startup_progress = "0/[total]"
	for(var/datum/pspace_planet/D in todo)
		if(D.sector) pspace_get_sector(D.sector.sx, D.sector.sy) //setor carregado: orbita/decolagem funcionam
		if(!D.surface_z && !D.generating)
			pspace_gen_request(D, null)
			D.gen_priority = 1 //poder total: o servidor esta vazio durante o boot
			while(D && D.generating) sleep(5)
		done++
		pspace_startup_progress = "[done]/[total]"
	pspace_world_ready = 1
	pspace_startup_progress = ""
	WriteToLog("debug","pspace: startup completo -- [done] planeta\s prontos; login liberado")
	if(done) to_chat(world, "<font color=#e8b64c><b>Universo gerado ([done] mundo\s). Login liberado!</b></font>")

// ---- DLL DE TERRENO (jandirus_noise.dll, fonte em Tools\jandirus_noise.c) ----
//fBm de 4 oitavas em C: classifica o mapa INTEIRO (250k tiles) numa chamada (~15ms vs
//segundos do noise em DM). Se a DLL faltar/falhar, cai automaticamente pro noise em DM.
var/pspace_dll_ok = 1 //auto-desliga no primeiro erro (nao fica tentando a cada planeta)

proc/pspace_dll_surface(seed, size)
	if(!pspace_dll_ok) return null
	if(!fexists("jandirus_noise.dll"))
		pspace_dll_ok = 0
		WriteToLog("debug","pspace: jandirus_noise.dll nao encontrada -- usando o noise em DM")
		return null
	var/map = null
	try
		map = call_ext("jandirus_noise.dll", "surface_map")("[seed]", "[size]", "[PSURF_H_WATER]", "[PSURF_H_BEACH]", "[PSURF_H_HILL]", "[PSURF_H_MOUNTAIN]")
	catch(var/exception/e)
		pspace_dll_ok = 0
		WriteToLog("debug","pspace: call_ext na DLL de noise falhou ([e]) -- usando o noise em DM")
		return null
	if(!istext(map) || length(map) < size * size)
		pspace_dll_ok = 0
		WriteToLog("debug","pspace: DLL de noise devolveu resposta invalida -- usando o noise em DM")
		return null
	return map

// ---- VALUE NOISE (Fase 2): grade coarse de valores + interpolacao bilinear suavizada ----
//BYOND nao tem Perlin nativo; isto gera relevo continuo deterministico do seed do planeta
//(FALLBACK: usado quando a DLL acima nao esta disponivel)
proc/pspace_noise_grid(datum/pspace_rng/R, cells)
	var/list/g = new/list(cells * cells)
	for(var/i = 1 to cells * cells)
		g[i] = R.next(1000) / 1000
	return g

proc/pspace_noise_at(list/g, cells, fx, fy) //fx/fy em "coordenada de celula" (0..cells-1 float)
	var/gx = min(round(fx), cells - 2) //round(v) de 1 arg = floor no DM
	var/gy = min(round(fy), cells - 2)
	var/tx = fx - gx
	var/ty = fy - gy
	tx = tx * tx * (3 - 2 * tx) //smoothstep
	ty = ty * ty * (3 - 2 * ty)
	var/v00 = g[gy * cells + gx + 1]
	var/v10 = g[gy * cells + gx + 2]
	var/v01 = g[(gy + 1) * cells + gx + 1]
	var/v11 = g[(gy + 1) * cells + gx + 2]
	var/a = v00 + (v10 - v00) * tx
	var/b = v01 + (v11 - v01) * tx
	return a + (b - a) * ty

//superficie (Fase 2): RELEVO por noise (lago/praia/planicie/colina/montanha), flora e
//plantas colhiveis por bioma, minerios nas colinas, inimigos que escalam, anel de saida
proc/pspace_generate_surface(datum/pspace_planet/D)
	var/datum/pspace_rng/R = new(D.seed)
	var/list/B = pspace_biomes[D.biome]
	if(!D.parea) //area propria: Planet = nome (gravidade/area-lists/planet-death funcionam)
		D.parea = new/area/pspace_planet
		D.parea.Planet = D.name
		D.parea.name = "Outside"
	//mapa classificado pela DLL (1 chamada, ~15ms); fallback = 2 oitavas de noise em DM
	var/dllmap = pspace_dll_surface(D.seed, PSURF_SIZE)
	var/c1 = 0
	var/c2 = 0
	var/list/g1 = null
	var/list/g2 = null
	if(!dllmap)
		c1 = round(PSURF_SIZE / 16) + 2
		c2 = round(PSURF_SIZE / 6) + 2
		g1 = pspace_noise_grid(R, c1)
		g2 = pspace_noise_grid(R, c2)
	//---- KIT DE TERRENO por planeta: familias/states REAIS dos planetas canonicos, sorteados
	//da seed DENTRO do arquetipo do bioma (planetas do mesmo bioma ficam diferentes entre si) ----
	var/list/gr_verde = list("Grass1","Grass2","Grass3","Grass4","Grass5","Grass6","Grass14") //Grass19/20 sao BRANCOS (neve): salpicavam branco na planicie
	var/list/gr_terra = list("Ground1","Ground2","Ground4","Ground6","Ground7","Ground8","Ground9","Ground12","Ground13","Ground16")
	var/list/gr_gelo = list("GroundIce1","GroundIce2","GroundIce3","GroundSnow1")
	var/list/wa_states = list("1","2","3","6","9","10","12","13") //so os AZUIS: os states 5 (lilas), 8 (verde neon) e 11 (cinza) sem tint pareciam chao -- cor exotica vem do cross-mix/alien
	var/plains_icon = 'Grass.dmi'
	var/list/plains_states = gr_verde
	var/plains_tint = null
	var/hill_icon = 'Ground.dmi'
	var/list/hill_states = gr_terra
	var/hill_tint = null
	var/beach_icon = 'Ground.dmi'
	var/list/beach_states = list("Ground2","Ground7","Ground8")
	var/beach_tint = null
	var/water_icon = 'Waters.dmi'
	var/water_tint = null
	var/water_lava = 0
	var/mount_tint = B[7]
	var/tree_prob = PSURF_TREE_PROB //densidade de arvores por bioma (mundo-jardim = floresta; deserto = rara)
	//cada bioma sorteia uma FAMILIA de terreno (assets reais de Icons/Turfs) -- planetas do
	//mesmo bioma variam de verdade: deserto dourado vs vermelho, mundo Namek vs grama tintada...
	switch(B[1])
		if("Verdejante")
			tree_prob = PSURF_TREE_PROB * 2 //mundo-jardim tipo Terra: bem arborizado
			switch(R.next(10))
				if(1 to 6) //gramados canonicos da Terra (Grass.dmi)
				if(7 to 8) //grama fechada de selva
					plains_icon = 'Turfs 2.dmi'
					plains_states = list("grass")
				else //vegetacao de outro mundo (tint)
					plains_tint = pspace_gen_tint(R)
		if("Gelido")
			water_tint = "#bfe8ff"
			beach_tint = "#cfe0ee"
			hill_tint = "#dfeaf5"
			switch(R.next(10))
				if(1 to 4) //gelo/neve canonicos
					plains_icon = 'Ground.dmi'
					plains_states = gr_gelo
					hill_states = gr_gelo
				if(5 to 7) //NEVE profunda a perder de vista
					plains_icon = 'Turf Snow.dmi'
					plains_states = list("Middle snow")
					hill_states = gr_gelo
				else //tundra azulada
					plains_tint = "#bcd8f0"
					hill_tint = "#a8c4e0"
		if("Deserto")
			tree_prob = 1 //palmeiras raras (oasis)
			switch(R.next(10))
				if(1 to 4) //deserto DOURADO (Dirt.dmi: familias de areia)
					plains_icon = 'Dirt.dmi'
					plains_states = list("Sand2","Sand3","Sand5","Sand7")
					hill_icon = 'Dirt.dmi'
					hill_states = list("Dirt1","Dirt5","Dirt6")
					beach_tint = "#e0c070"
				if(5 to 7) //deserto VERMELHO marciano
					plains_icon = 'Dirt.dmi'
					plains_states = list("Sand9","Sand14","Sand16")
					hill_icon = 'Dirt.dmi'
					hill_states = list("Dirt3","Dirt6","Dirt12")
					beach_tint = "#c88858"
					mount_tint = "#8a5040"
				else //terra batida classica
					plains_icon = 'Ground.dmi'
					plains_states = gr_terra
					if(R.next(10) <= 5) plains_tint = "#e8cf7a"
					hill_tint = "#c8a858"
					beach_tint = "#e0c070"
		if("Vulcanico")
			tree_prob = 1 //quase esteril
			water_lava = 1
			switch(R.next(10))
				if(1 to 4) //planicies de CINZA (Turfs1.dmi)
					plains_icon = 'Turfs1.dmi'
					plains_states = list("ash","ash2","ash3","ash4","ash5")
					hill_icon = 'Turfs1.dmi'
					hill_states = list("hellground","hellground2","hellground3","hellground4","hellground5")
					beach_icon = 'Turfs1.dmi'
					beach_states = list("dirt","dirt2","dirt3")
				if(5 to 7) //rocha infernal com veios de lava fria
					plains_icon = 'Turfs1.dmi'
					plains_states = list("hellground","hellground2","hellground3","hellground4","hellground5")
					hill_icon = 'Turfs1.dmi'
					hill_states = list("lava","lava2","lava3","lava4","lava5") //rocha de lava ESCURA (o liquido e o lago)
					beach_icon = 'Turfs1.dmi'
					beach_states = list("ash","ash2","ash3")
				else //terra tostada classica
					plains_icon = 'Ground.dmi'
					plains_states = gr_terra
					plains_tint = (R.next(10) <= 5) ? "#b87858" : "#8a6a5a"
					hill_tint = "#7a5040"
		if("Alienigena")
			switch(R.next(10))
				if(1 to 4) //mundo estilo NAMEK: grama teal + agua VERDE animada
					plains_icon = 'Turfs 2.dmi'
					plains_states = list("ngrass")
					water_icon = 'Turfs 2.dmi'
					wa_states = list("nwater")
					hill_tint = "#4a9890"
				if(5 to 7) //grama de cor impossivel (tint forte E a identidade)
					plains_tint = pspace_gen_tint(R)
					hill_tint = pspace_gen_tint(R)
					water_tint = pspace_gen_tint(R)
				else //solo estranho tintado
					plains_icon = 'Ground.dmi'
					plains_states = gr_terra
					plains_tint = pspace_gen_tint(R)
					hill_tint = pspace_gen_tint(R)
					water_tint = pspace_gen_tint(R)
		if("Sombrio")
			water_tint = "#4a5368"
			switch(R.next(10))
				if(1 to 4) //rocha escura morta (Turfs1.dmi)
					plains_icon = 'Turfs1.dmi'
					plains_states = list("hellground","hellground2","hellground3","hellground4","hellground5")
					hill_icon = 'Turfs1.dmi'
					hill_states = list("ash","ash2","ash3")
					beach_icon = 'Turfs1.dmi'
					beach_states = list("dirt","dirt2")
				if(5 to 7) //grama morta acinzentada
					plains_tint = "#8a93a8"
					hill_tint = "#5a6378"
				else //terra palida
					plains_icon = 'Ground.dmi'
					plains_states = gr_terra
					plains_tint = "#8a93a8"
					hill_tint = "#5a6378"
	//CROSS-MIX: ~25% dos planetas roubam a AGUA de outro mundo (agua rosa no deserto etc.)
	if(!water_lava && R.next(100) <= 25) water_tint = pspace_gen_tint(R)
	if(R.next(100) <= 20) mount_tint = pspace_gen_tint(R) //montanhas de rocha exotica
	//CONSISTENCIA: cada planeta fixa 1 state PRINCIPAL + 1 acento por camada (85/15) --
	//o sorteio por tile entre states de cores diferentes fazia xadrez/listras no chao
	var/plains_main = R.pickfrom(plains_states)
	var/plains_alt = R.pickfrom(plains_states)
	var/hill_main = R.pickfrom(hill_states)
	var/hill_alt = R.pickfrom(hill_states)
	var/beach_state = R.pickfrom(beach_states) //UM tipo de areia por planeta (era 3 por tile = xadrez)
	var/wsa = R.pickfrom(wa_states) //1 visual de agua dominante + 1 raro
	var/wsb = R.pickfrom(wa_states)
	//ARVORES: 1 especie principal + 1 acento POR PLANETA (do pool do bioma); 30% das copas
	//ganham a cor da flora do bioma (Alienigena: cor impossivel aleatoria)
	var/tree_main = R.pickfrom(B[8])
	var/tree_alt = R.pickfrom(B[8])
	var/tree_tint = null
	if(R.next(10) <= 3) tree_tint = (B[1] == "Alienigena") ? pspace_gen_tint(R) : B[3]
	var/list/landspots = list() //amostra de tiles de planicie (spawn de inimigo/pouso)
	var/bestd = 999999 //tile de terra mais perto do centro = ponto de pouso
	var/ctr = round(PSURF_SIZE / 2)
	var/gen_t0 = world.time
	D.land_x = 0
	D.land_y = 0
	D.land_spots = list()
	for(var/xx = 1 to PSURF_SIZE)
		D.generating = world.time //HEARTBEAT: o watchdog so destrava gerador que PAROU de progredir
		if(D.gen_priority) //alguem esperando pousar: ritmo rapido (tolera tick estourado por ~5s)
			if(xx % PSPACE_GEN_COLSTRIDE == 0 && world.tick_usage > PSPACE_GEN_TICKCAP) sleep(world.tick_lag)
		else //pre-aquecimento em background: 1 tick de sono POR COLUNA (invisivel no servidor; escala ao vivo se alguem encostar)
			if(xx % PSPACE_PREGEN_COLSTRIDE == 0) sleep(world.tick_lag)
		for(var/yy = 1 to PSURF_SIZE)
			//classe do tile: 1 agua, 2 praia, 3 planicie, 4 colina, 5 montanha
			//(classificada ANTES da borda: o anel de wrap se pinta da classe local do noise)
			var/tc = 3
			if(dllmap)
				switch(text2ascii(dllmap, (xx - 1) * PSURF_SIZE + yy)) //indice 1-based: (xx-1)*size + yy
					if(87) tc = 1 //'W'
					if(66) tc = 2 //'B'
					if(80) tc = 3 //'P'
					if(72) tc = 4 //'H'
					else tc = 5   //'M'
			else
				var/h = pspace_noise_at(g1, c1, (xx - 1) / 16, (yy - 1) / 16) * 0.7 + pspace_noise_at(g2, c2, (xx - 1) / 6, (yy - 1) / 6) * 0.3
				if(h < PSURF_H_WATER) tc = 1
				else if(h < PSURF_H_BEACH) tc = 2
				else if(h < PSURF_H_HILL) tc = 3
				else if(h < PSURF_H_MOUNTAIN) tc = 4
				else tc = 5
			if(xx == 1 || yy == 1 || xx == PSURF_SIZE || yy == PSURF_SIZE)
				var/turf/T = new/turf/Other/Stars_Exit(locate(xx, yy, D.surface_z)) //borda do planetoide: da a VOLTA (wrap)
				switch(tc) //VISUAL da classe do noise (o contorno uniforme destoava do terreno vizinho)
					if(1)
						T.icon = water_lava ? 'Waters.dmi' : water_icon
						T.icon_state = water_lava ? "7" : wsa
						if(!water_lava && water_tint) T.color = water_tint
					if(2)
						T.icon = beach_icon
						T.icon_state = beach_state
						T.color = beach_tint ? beach_tint : hill_tint
					if(3)
						T.icon = plains_icon
						T.icon_state = plains_main
						if(plains_tint) T.color = plains_tint
					if(4)
						T.icon = hill_icon
						T.icon_state = hill_main
						if(hill_tint) T.color = hill_tint
					else
						T.icon = 'JEFcliff.dmi'
						T.icon_state = ""
						if(mount_tint) T.color = mount_tint
				continue
			var/turf/T
			if(tc == 1) //lago (Vulcanico: LAVA com dano)
				if(water_lava)
					T = new/turf/Water/Water7(locate(xx, yy, D.surface_z))
				else
					T = new/turf/Water(locate(xx, yy, D.surface_z))
					T.icon = water_icon //familias exoticas (nwater de Namek etc.)
					T.icon_state = (R.next(100) <= 90) ? wsa : wsb //agua dominante + detalhe raro
					if(water_tint) T.color = water_tint
			else if(tc == 2) //margem de terra batida (UM tipo de areia por planeta)
				T = new/turf/Ground(locate(xx, yy, D.surface_z))
				T.icon = beach_icon
				T.icon_state = beach_state
				if(beach_tint) T.color = beach_tint
				else T.color = hill_tint
			else if(tc == 3) //PLANICIE: onde a vida acontece
				T = new/turf(locate(xx, yy, D.surface_z))
				T.icon = plains_icon
				T.icon_state = (R.next(100) <= 85) ? plains_main : plains_alt //chao consistente + acento
				if(plains_tint) T.color = plains_tint
				var/d = (xx - ctr) * (xx - ctr) + (yy - ctr) * (yy - ctr)
				if(d < bestd)
					bestd = d
					D.land_x = xx
					D.land_y = yy
				if(R.next(150) == 1)
					landspots += locate(xx, yy, D.surface_z) //amostra ~0.7% (mundo 500x500: manter a lista pequena)
					if(D.land_spots.len < 15) D.land_spots += (xx * 1000 + yy) //candidatos de pouso seguro
				if(R.next(100) <= tree_prob)
					var/ttype = (R.next(100) <= 85) ? tree_main : tree_alt //1 especie dominante + acento
					var/obj/tr = new ttype(locate(xx, yy, D.surface_z))
					if(tree_tint) tr.color = tree_tint
					tr.pspace_wild = 1
					D.spawned += tr
				else if(islist(B[9]) && B[9]:len && R.next(100) <= PSURF_PLANT_PROB)
					var/ptype = R.pickfrom(B[9])
					var/obj/pl = new ptype(locate(xx, yy, D.surface_z))
					pl.pspace_wild = 1
					D.spawned += pl
			else if(tc == 4) //colina: arvores densas + MINERIOS
				T = new/turf(locate(xx, yy, D.surface_z))
				T.icon = hill_icon
				T.icon_state = (R.next(100) <= 85) ? hill_main : hill_alt
				if(hill_tint) T.color = hill_tint
				if(R.next(100) <= PSURF_ORE_PROB * B[10])
					var/obj/ore
					if(R.next(4) == 1) ore = new/obj/Raw_Material/Quartz(locate(xx, yy, D.surface_z)) //gemas: 1/4 dos veios
					else ore = new/obj/Raw_Material/Ore(locate(xx, yy, D.surface_z))
					ore.pspace_wild = 1
					D.spawned += ore
				else if(R.next(100) <= tree_prob * 2)
					var/ttype = (R.next(100) <= 85) ? tree_main : tree_alt
					var/obj/tr = new ttype(locate(xx, yy, D.surface_z))
					if(tree_tint) tr.color = tree_tint
					tr.pspace_wild = 1
					D.spawned += tr
			else //montanha: parede densa sobrevoavel (Void_Wall era PRETO + opacity: zonas pretas)
				T = new/turf/pspace_mountain(locate(xx, yy, D.surface_z))
				if(mount_tint) T.color = mount_tint
	//area em UM bloco (250k `contents +=` um-a-um custavam mais que os proprios turfs)
	D.parea.contents.Add(block(locate(1, 1, D.surface_z), locate(PSURF_SIZE, PSURF_SIZE, D.surface_z)))
	if(!D.land_x) //planeta 100% agua/rocha (raro): pousa no centro mesmo
		D.land_x = ctr
		D.land_y = ctr
	//inimigos nativos em tiles de PLANICIE (tipo do bioma; escalam pelo NPCTicker e dao +5 karma)
	var/n = PSURF_ENEMY_MIN + R.next(PSURF_ENEMY_MAX - PSURF_ENEMY_MIN + 1) - 1
	var/oldspawns = npcspawnson
	npcspawnson = 1 //mob/npc/New deleta o mob com spawns ambientes desligados
	for(var/i = 1 to n)
		var/etype = B[4]
		var/mob/npc/E = new etype
		var/turf/spot = landspots.len ? R.pickfrom(landspots) : locate(D.land_x, D.land_y, D.surface_z)
		E.loc = spot
		D.spawned += E
	npcspawnson = oldspawns
	pspace_builds_restore(D) //re-aplica as construcoes dos jogadores por cima do terreno
	conq_on_surface_ready(D) //re-finca a bandeira de dominio, se o planeta tiver dono (PlanetConquest.dm)
	WriteToLog("debug","pspace: superficie de [D.name] ([B[1]]) gerada em [(world.time - gen_t0) / 10]s ([D.spawned.len] objs)")

// ---------------------------------------------------------------------------
// NAV: infos de setor + MAPA DA GALAXIA pro ui_tab_nav (HtmlUI.dm)
// ---------------------------------------------------------------------------
proc/pspace_nav_header(z)
	var/datum/space_sector/S = pspace_sector_for_z(z)
	if(!S) return ""
	var/h = "<div class='mut' style='padding:4px 8px'><b>[S.name] ([S.sx], [S.sy])</b>"
	var/list/dirs = list("N" = list(0, 1), "S" = list(0, -1), "L" = list(1, 0), "O" = list(-1, 0))
	var/viz = ""
	for(var/dn in dirs)
		var/list/dd = dirs[dn]
		var/datum/space_sector/V = pspace_sectors["[S.sx + dd[1]],[S.sy + dd[2]]"]
		viz += " &middot; [dn]: [V ? "[V.name]" : "<span class='mut'>inexplorado</span>"]"
	h += "<br><span class='mut' style='font-size:10px'>[viz]</span></div>"
	//radar de Super Dragon Ball: sinal dourado a ate SDB_HINT_RANGE setores
	if(islist(pspace_superdb))
		for(var/list/E in pspace_superdb)
			if(E[6]) continue //coletada: sem sinal
			var/dist = max(abs(E[2] - S.sx), abs(E[3] - S.sy))
			if(dist <= SDB_HINT_RANGE)
				h += "<div style='padding:2px 8px;color:#e8b64c;font-size:10px'><b>&#10022; Sinal DOURADO anomalo</b> no setor ([E[2]], [E[3]])[dist == 0 ? " -- NESTE setor, perto de ([E[4]], [E[5]])!" : ""]</div>"
	h += pspace_nav_map(S)
	return h

// ---------------------------------------------------------------------------
// SUPER DRAGON BALLS: 7 esferas do tamanho de PLANETOIDES espalhadas pela
// galaxia -- grandes demais pra carregar: voce REIVINDICA (claim) cada uma.
//  - Sem dono: canal de 10s ao lado dela = sua (anuncio mundial).
//  - De OUTRO dono: DISPUTA -- o dono e avisado (na hora ou no login) e o
//    ladrao precisa SEGURAR a esfera por 5 min (morrer/KO/sair = fracassa).
//  - Com as 7, invoque SUPER SHENRON ao lado de qualquer uma -- mas so quem
//    fala a LINGUA DOS DEUSES (rank divino atual/passado ou sangue divino;
//    godtongue, WishTable.dm). Sem a lingua? TRANSFIRA as 7 pra quem fale:
//    o pedido PESSOAL (riqueza/poder) vai pro DOADOR (beneficiario).
//  - Desejos: riqueza, reviver, e STRONGEST IN THE UNIVERSE (a vida por 2x
//    o maior BP do jogo -- 1 ano de prazo, sem revive).
// ---------------------------------------------------------------------------
proc/pspace_sdb_scatter() //posicoes NOVAS aleatorias + claims e transferencia LIMPOS
	pspace_superdb = list()
	sdb_benef_sig = null
	sdb_benef_name = ""
	for(var/n = 1 to 7)
		var/sx = 0
		var/sy = 0
		while(abs(sx) + abs(sy) < SDB_MIN_DIST)
			sx = rand(-SDB_MAX_DIST, SDB_MAX_DIST)
			sy = rand(-SDB_MAX_DIST, SDB_MAX_DIST)
		pspace_superdb += list(list(n, sx, sy, rand(20, PSPACE_SIZE - 20), rand(20, PSPACE_SIZE - 20), 0, null, ""))
	//setor da esfera ja carregado agora (re-espalhamento pos-desejo): poe o obj na hora
	for(var/list/E in pspace_superdb)
		var/datum/space_sector/S = pspace_sectors["[E[2]],[E[3]]"]
		if(S && S.z)
			S.spawned += pspace_sdb_spawn(E, S.z)

//re-espalha SO a posicao de UMA esfera (migracao do inventario antigo), mantendo o dono
proc/pspace_sdb_relocate(list/E)
	var/sx = 0
	var/sy = 0
	while(abs(sx) + abs(sy) < SDB_MIN_DIST)
		sx = rand(-SDB_MAX_DIST, SDB_MAX_DIST)
		sy = rand(-SDB_MAX_DIST, SDB_MAX_DIST)
	E[2] = sx
	E[3] = sy
	E[4] = rand(20, PSPACE_SIZE - 20)
	E[5] = rand(20, PSPACE_SIZE - 20)
	E[6] = 0
	var/datum/space_sector/S = pspace_sectors["[sx],[sy]"]
	if(S && S.z)
		S.spawned += pspace_sdb_spawn(E, S.z)

proc/sdb_owned_count(sig)
	var/n = 0
	if(!islist(pspace_superdb) || isnull(sig)) return 0
	for(var/list/E in pspace_superdb)
		if(E.len >= 7 && E[7] == sig) n++
	return n

//MIGRACAO do sistema antigo (esferas no inventario -> claim) + lingua dos deuses (cadeia do Login)
mob/proc/sdb_login_check()
	godtongue_check() //rank divino atual (ou sangue divino) aprende a lingua -- e nunca esquece
	var/changed = 0
	var/list/velhas = list() //coleta ANTES de deletar (del muta o contents em plena iteracao)
	for(var/obj/items/SuperDragonBall/B in contents) velhas += B
	if(velhas.len) pspace_boot()
	for(var/obj/items/SuperDragonBall/B in velhas)
		var/list/E = pspace_sdb_entry(B.sdb_num)
		if(E)
			E[7] = signature
			E[8] = name
			pspace_sdb_relocate(E)
			changed = 1
		del B
	if(changed)
		InvenSet()
		to_chat(src, "<font color=#e8b64c><b>Suas Super Dragon Balls voltaram ao espaco</b> -- grandes demais pra carregar. Elas agora sao SUAS por claim (radar dourado no Nav); outros podem tentar toma-las.")
		pspace_save()

proc/pspace_sdb_spawn(list/E, z)
	var/obj/items/SuperDragonBall/B = new(locate(E[4], E[5], z))
	B.sdb_num = E[1]
	B.icon_state = "[E[1]]"
	B.name = "Super Dragon Ball ([E[1]] estrela\s)"
	return B

proc/pspace_sdb_entry(num)
	if(!islist(pspace_superdb)) return null
	for(var/list/E in pspace_superdb)
		if(E[1] == num) return E
	return null

obj/items/SuperDragonBall
	icon = 'SuperDragonball.dmi'
	icon_state = "1"
	name = "Super Dragon Ball"
	desc = "Uma esfera do dragao do tamanho de um PLANETOIDE -- impossivel de carregar. Reivindique-a (claim) para torna-la sua."
	pixel_x = -16 //64x64 centrado no tile
	pixel_y = -16
	density = 0
	SaveItem = 0 //a posicao vive no registro da galaxia; o obj so existe com o setor carregado
	var/sdb_num = 1
	Click() //REIVINDICAR: sem dono = canal de 10s; com dono = DISPUTA de 5 min (o dono e avisado)
		if(!usr || !usr.client || usr.dead || usr.KO) return
		if(!loc) return
		if(get_dist(usr, src) > 2)
			to_chat(usr, "Chegue mais perto da esfera.")
			return
		var/list/E = pspace_sdb_entry(sdb_num)
		if(!E || E.len < 8) return
		if(E[7] == usr.signature)
			to_chat(usr, "<font color=#e8b64c>A Super Dragon Ball de [sdb_num] estrela\s ja e SUA. ([sdb_owned_count(usr.signature)]/7) Com as 7, use Invocar Super Shenron ao lado de qualquer uma.</font>")
			return
		if(sdb_contest["[sdb_num]"])
			to_chat(usr, "Esta esfera ja esta em DISPUTA.")
			return
		if(isnull(E[7]) || E[7] == "")
			spawn sdb_claim_channel(usr)
		else
			spawn sdb_contest_channel(usr, E)

	proc/sdb_claim_channel(mob/M) //esfera SEM dono: canal curto colado nela
		if(sdb_contest["[sdb_num]"]) return
		sdb_contest["[sdb_num]"] = 1
		to_chat(view(src), "<font color=#e8b64c>[M] poe as maos na Super Dragon Ball de [sdb_num] estrela\s, reivindicando-a...</font>")
		var/ok = 1
		for(var/i = 1 to round(SDB_CLAIM_TICKS / 10))
			sleep(10)
			if(!M || M.dead || M.KO || !src || !loc || get_dist(M, src) > SDB_CONTEST_RANGE)
				ok = 0
				break
		sdb_contest -= "[sdb_num]"
		if(!ok)
			if(M) to_chat(M, "A reivindicacao falhou.")
			return
		var/list/E = pspace_sdb_entry(sdb_num)
		if(!E || (E[7] && E[7] != "")) return
		E[7] = M.signature
		E[8] = M.name
		pspace_save()
		to_chat(world, "<font color=#e8b64c><b>[M] REIVINDICOU a Super Dragon Ball de [sdb_num] estrela\s! ([sdb_owned_count(M.signature)]/7)</b></font>", "announce")

	proc/sdb_contest_channel(mob/M, list/E) //esfera de OUTRO dono: disputa longa, dono avisado
		if(sdb_contest["[sdb_num]"]) return
		sdb_contest["[sdb_num]"] = 1
		var/oldsig = E[7]
		var/oldname = E[8]
		to_chat(world, "<font color=#e8b64c><b>[M] tenta TOMAR a Super Dragon Ball de [sdb_num] estrela\s de [oldname]!</b> A disputa leva [round(SDB_CONTEST_TICKS / 600)] minutos.</font>", "announce")
		conq_notify_owner(oldsig, "<font color=red><b>[M.name] esta tomando sua Super Dragon Ball de [sdb_num] estrela\s -- setor ([E[2]],[E[3]]), em ([E[4]],[E[5]])! Voce tem [round(SDB_CONTEST_TICKS / 600)] minutos para DEFENDE-LA.</b></font>")
		var/ok = 1
		var/t = 0
		while(t < SDB_CONTEST_TICKS)
			sleep(10)
			t += 10
			if(!M || M.dead || M.KO || !src || !loc || get_dist(M, src) > SDB_CONTEST_RANGE)
				ok = 0
				break
			if(E[7] != oldsig) //dono mudou no meio (admin/reset): disputa sem objeto
				ok = 0
				break
			if(t % 600 == 0 && M.client) to_chat(M, "<font color=#e8b64c>Segurando a esfera... [round((SDB_CONTEST_TICKS - t) / 600)] min restando.</font>")
		sdb_contest -= "[sdb_num]"
		if(!ok)
			to_chat(world, "<font color=#e8b64c>A tentativa de tomar a esfera de [sdb_num] estrela\s FRACASSOU -- [oldname] mantem o claim.</font>", "announce")
			conq_notify_owner(oldsig, "<font color=yellow>Sua Super Dragon Ball de [sdb_num] estrela\s esta SEGURA.</font>")
			return
		E[7] = M.signature
		E[8] = M.name
		if(sdb_benef_sig) //um claim tomado A FORCA quebra a transferencia pendente
			sdb_benef_sig = null
			sdb_benef_name = ""
		pspace_save()
		to_chat(world, "<font color=#e8b64c><b>[M] TOMOU a Super Dragon Ball de [sdb_num] estrela\s de [oldname]! ([sdb_owned_count(M.signature)]/7)</b></font>", "announce")
		conq_notify_owner(oldsig, "<font color=red><b>Voce PERDEU a Super Dragon Ball de [sdb_num] estrela\s para [M.name].</b></font>")

	verb/Invocar_Super_Shenron() //ao lado de qualquer esfera SUA, com as 7 reivindicadas + a lingua dos deuses
		set category = null
		set src in oview(2)
		var/mob/U = usr
		if(!U.client || U.dead || U.KO) return
		var/owned = sdb_owned_count(U.signature)
		if(owned < 7)
			to_chat(U, "<font color=#e8b64c>Voce sente o poder da esfera... mas reivindicou [owned] de 7. O dragao exige TODAS.</font>")
			return
		if(!U.godtongue_check())
			to_chat(U, "<font color=#e8b64c>Voce grita para os ceus... e NADA acontece. So a LINGUA DOS DEUSES desperta o Super Shenron -- ranks divinos (atuais ou passados) a conhecem. Ou TRANSFIRA as esferas pra alguem que fale (verb Transferir Super Esferas).</font>")
			return
		//TRANSFERENCIA: o pedido pessoal vai pro DOADOR (beneficiario), nao pro porta-voz
		var/mob/benef = null
		if(sdb_benef_sig && sdb_benef_sig != U.signature)
			for(var/mob/P in player_list)
				if(P.client && P.signature == sdb_benef_sig)
					benef = P
					break
		var/list/wmenu = list("Riqueza colossal ([FullNum(SDB_WISH_ZENNI)] zenni)", "Reviver um guerreiro caido", "Strongest in the Universe (a VIDA por poder)")
		if(kai_body_wish_ok(U) && !sdb_benef_sig) wmenu += "Corpo de um Saiyajin (Zero Mortals)" //o desejo do Zamasu: privilegio proprio do Kaioshin (nao vai pra beneficiario)
		wmenu += "Cancelar"
		var/wish = input(U, "SUPER SHENRON atende UM desejo[benef ? " -- em nome de [benef.name]" : ""].", "Super Shenron") as null|anything in wmenu
		if(!wish || wish == "Cancelar") return
		if(sdb_benef_sig && sdb_benef_sig != U.signature && !benef && wish != "Reviver um guerreiro caido")
			to_chat(U, "<font color=#e8b64c>O beneficiario ([sdb_benef_name]) precisa estar ONLINE para receber o pedido.</font>")
			return
		var/mob/alvo = benef ? benef : U
		if(wish == "Reviver um guerreiro caido")
			var/list/deads = list()
			for(var/mob/M2 in player_list)
				if(M2.client && M2.dead && !M2.aged_out) deads += M2 //morte de VELHICE nem o Super Shenron reverte
			if(!deads.len)
				to_chat(U, "Nenhum guerreiro caido (online) que possa voltar.")
				return
			var/mob/T = input(U, "Reviver quem?", "Super Shenron") as null|anything in deads
			if(!T || !T.dead) return
			sdb_announce_summon(U)
			Revive(T, 1)
			T.loc = locate(U.x + 1, U.y, U.z)
			to_chat(world, "<font color=#e8b64c><b>SUPER SHENRON trouxe [T] de volta a vida!</b></font>", "announce")
		else if(wish == "Corpo de um Saiyajin (Zero Mortals)")
			var/list/saiyans = list()
			for(var/mob/S in player_list)
				if(!S.client || S.dead || S == U) continue
				if(S.Race == "Saiyan" || S.Race == "Legendary Saiyan" || S.Parent_Race == "Saiyan") saiyans += S
			if(!saiyans.len)
				to_chat(U, "Nenhum Saiyajin (online) digno de fornecer o molde.")
				return
			var/mob/molde = input(U, "O corpo de QUAL Saiyajin voce deseja vestir?", "Zero Mortals") as null|anything in saiyans
			if(!molde || !molde.client) return
			sdb_announce_summon(U)
			kai_take_saiyan_body(U, molde)
		else if(wish == "Strongest in the Universe (a VIDA por poder)")
			var/conf = alert(alvo, "Trocar TODO o seu lifespan por poder absoluto? Voce vivera SO MAIS 1 ANO -- com o DOBRO do maior BP do jogo -- e dessa morte nao ha revive, apenas reencarnacao.", "Super Shenron", "ACEITO O PRECO", "Recusar")
			if(conf != "ACEITO O PRECO")
				to_chat(U, "O desejo foi recusado[benef ? " por [alvo.name]" : ""].")
				return
			sdb_announce_summon(U)
			sw_strongest_wish(alvo)
		else
			sdb_announce_summon(U)
			alvo.zenni += SDB_WISH_ZENNI
			to_chat(world, "<font color=#e8b64c><b>SUPER SHENRON concedeu riqueza colossal a [alvo]!</b></font>", "announce")
		pspace_sdb_scatter() //consome os claims (e a transferencia) e re-espalha
		pspace_save()
		to_chat(world, "<font color=#e8b64c>O desejo foi realizado... e as Super Dragon Balls, drenadas, se espalharam novamente pela galaxia.</font>", "announce")

proc/sdb_announce_summon(mob/U)
	to_chat(world, "<font color=#e8b64c><b>O ceu de TODA a galaxia escurece... [U] invocou SUPER SHENRON na lingua dos deuses!</b></font>", "announce")
	if(U) U.emit_Sound('thunderclap.wav')

//TRANSFERIR a guarda das 7 pra quem fala a lingua (o pedido pessoal beneficia o DOADOR)
mob/verb/Transferir_Super_Esferas()
	set name = "Transferir Super Esferas"
	set category = "Other"
	if(!usr.client || usr.dead) return
	if(sdb_owned_count(usr.signature) < 7)
		to_chat(usr, "Voce precisa das 7 Super Dragon Balls reivindicadas para transferir a guarda. ([sdb_owned_count(usr.signature)]/7)")
		return
	var/list/cands = list()
	for(var/mob/P in oview(1, usr))
		if(P.client && !P.dead) cands += P
	if(!cands.len)
		to_chat(usr, "Chame o guardiao escolhido para o seu lado (adjacente).")
		return
	var/mob/R = input(usr, "Transferir o claim das 7 esferas pra quem? O pedido PESSOAL do dragao vira pra VOCE (beneficiario).", "Super Esferas") as null|anything in cands
	if(!R || !R.client || get_dist(usr, R) > 1) return
	if(!R.godtongue_check(1)) to_chat(usr, "<font color=#e8b64c>AVISO: [R.name] tambem NAO fala a lingua dos deuses -- ele(a) nao conseguira invocar o dragao.</font>")
	switch(alert(R, "[usr.name] quer confiar as 7 SUPER DRAGON BALLS a voce, para invocar o dragao EM NOME DELE(A) -- o pedido pessoal beneficia [usr.name]. Aceitar a guarda?", "Super Esferas", "Aceitar", "Recusar"))
		if("Recusar")
			to_chat(usr, "[R] recusou a guarda das esferas.")
			return
	if(sdb_owned_count(usr.signature) < 7) return //re-checa apos o dialogo
	for(var/list/E in pspace_superdb)
		if(E.len >= 8 && E[7] == usr.signature)
			E[7] = R.signature
			E[8] = R.name
	sdb_benef_sig = usr.signature
	sdb_benef_name = usr.name
	pspace_save()
	to_chat(world, "<font color=#e8b64c><b>[usr] confiou as 7 Super Dragon Balls a [R]!</b></font>", "announce")
	to_chat(R, "<font color=#e8b64c>Voce carrega a guarda das 7. Invoque o SUPER SHENRON ao lado de qualquer uma -- o pedido pessoal ira para [usr.name].</font>")

//placar publico das esferas (quem tem quantas -- sem revelar ONDE estao)
mob/verb/Super_Esferas_Status()
	set name = "Super Esferas"
	set category = "Other"
	pspace_boot()
	var/list/tally = list()
	var/livres = 0
	if(islist(pspace_superdb))
		for(var/list/E in pspace_superdb)
			if(E.len >= 8 && E[7] && E[8])
				if(tally[E[8]]) tally[E[8]]++
				else tally[E[8]] = 1
			else livres++
	to_chat(usr, "<b>--- SUPER DRAGON BALLS ---</b>")
	for(var/nm in tally)
		to_chat(usr, "<font color=#e8b64c>[nm]: [tally[nm]] esfera\s</font>")
	to_chat(usr, "Sem dono: [livres]")
	to_chat(usr, "Suas: [sdb_owned_count(usr.signature)]/7[usr.godtongue ? " -- voce FALA a lingua dos deuses" : " -- voce NAO fala a lingua dos deuses (ranks divinos falam; ou transfira a guarda)"]")
	if(sdb_benef_sig) to_chat(usr, "Guarda transferida: o pedido pessoal ira para [sdb_benef_name].")

//visao de admin: seed, pools, setores descobertos e seus planetas
mob/Admin3/verb/Galaxy_Status()
	set category = "Admin"
	pspace_boot()
	to_chat(usr, "<font color=yellow>== GALAXIA == seed [pspace_seed] | setores descobertos: [pspace_sectors.len - 1] | pools: setor [pspace_sector_zs.len]/[PSPACE_MAX_SECTORS], superficie [pspace_surface_zs.len]/[PSURF_MAX_SURFACES] | world.maxz [world.maxz]</font>")
	for(var/k in pspace_sectors)
		var/datum/space_sector/S = pspace_sectors[k]
		if(S.is_home) continue
		var/pl = ""
		for(var/datum/pspace_planet/D in S.planets)
			pl += "[pl ? ", " : ""][D.name] (x[D.gravity], [pspace_biomes[D.biome][1]][(D.name in PlanetDisableList) ? ", DESTRUIDO" : ""][D.surface_z ? ", superficie z[D.surface_z]" : ""])"
		to_chat(usr, "[S.name] ([S.sx],[S.sy]) [S.z ? "carregado z[S.z]" : "descarregado"] -- [pl ? pl : "sem planetas"]")
	if(islist(pspace_superdb))
		for(var/list/E in pspace_superdb)
			to_chat(usr, "<font color=#e8b64c>SDB [E[1]] -- [E[6] ? "LIMBO do sistema antigo (dono nao relogou)" : "setor ([E[2]],[E[3]]) em ([E[4]],[E[5]])"][E.len >= 8 && E[7] ? " -- CLAIM de [E[8]]" : " -- sem dono"]</font>")

//recupera esferas perdidas (portador sumiu etc.): apaga TODAS e re-espalha
mob/Admin3/verb/Galaxy_SuperDB_Reset()
	set category = "Admin"
	pspace_boot()
	switch(input(usr, "Apagar TODAS as Super Dragon Balls (mundo e inventarios) e re-espalhar?", "Super DB Reset") in list("Nao", "Sim"))
		if("Nao") return
	for(var/obj/items/SuperDragonBall/B in world) del B
	pspace_sdb_scatter()
	pspace_save()
	to_chat(usr, "Super Dragon Balls re-espalhadas.")
	WriteToLog("rplog","[usr] re-espalhou as Super Dragon Balls   ([time2text(world.realtime,"Day DD hh:mm")])")

//mapa 7x7 da galaxia centrado no setor atual: dourado = voce, claro = explorado
//(nome + n de planetas, vermelho se todos destruidos), escuro = inexplorado
proc/pspace_nav_map(datum/space_sector/S)
	var/h = "<div style='padding:2px 8px 8px 8px'><table style='border-collapse:collapse'>"
	for(var/dy = 3 to -3 step -1)
		h += "<tr>"
		for(var/dx = -3 to 3)
			var/cx = S.sx + dx
			var/cy = S.sy + dy
			var/datum/space_sector/V = pspace_sectors["[cx],[cy]"]
			var/cell = "<td style='width:56px;height:34px;text-align:center;border:1px solid #262b35;font-size:9px;"
			if(V && cx == S.sx && cy == S.sy) //setor atual
				cell += "background:#2a2413;border-color:#e8b64c;color:#e8b64c'><b>[V.is_home ? "CENTRAL" : html_encode(V.name)]</b><br>([cx],[cy])"
			else if(V)
				var/pn = V.planets.len
				var/alldead = pn > 0
				for(var/datum/pspace_planet/D in V.planets)
					if(!(D.name in PlanetDisableList)) alldead = 0
				cell += "background:#151820;color:[alldead ? "#c05050" : "#8b919c"]'>[V.is_home ? "Central" : html_encode(V.name)]<br>[V.is_home ? "" : "[pn] planeta\s"]"
			else
				cell += "background:#0b0d11;color:#3a3f47'>&middot;"
			h += "[cell]</td>"
		h += "</tr>"
	h += "</table><div class='mut' style='font-size:9px;margin-top:3px'>Mapa da galaxia: dourado = voce &middot; claro = explorado &middot; vermelho = planetas destruidos &middot; escuro = inexplorado</div></div>"
	return h
