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
#define PSPACE_HOME_Z 26        // z do espaco original (setor 0,0)
#define PSPACE_SIZE 200         // lado da regiao util de um setor gerado
#define PSURF_SIZE 500          // lado da superficie de um planeta procedural (mundo inteiro; 1a visita gera ~250k turfs, alguns segundos)
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

var
	pspace_seed = 0                    // seed da galaxia (persistida no savefile "Galaxy")
	list/pspace_sectors = list()       // "sx,sy" -> /datum/space_sector
	list/pspace_planets = list()       // nome -> /datum/pspace_planet (lookup de gravidade/pouso)
	list/pspace_sector_zs = list()     // z's alocados pra setores (pool)
	list/pspace_surface_zs = list()    // z's alocados pra superficies (pool)
	list/pspace_superdb = null         // 7 entradas list(num, sx, sy, x, y, held) -- persistem no "Galaxy"
	pspace_booted = 0

// ---------------------------------------------------------------------------
// RNG deterministico proprio (LCG mod 134456): rand() do BYOND nao pode ser
// semeado por-geracao sem bagunçar o RNG global do jogo
// ---------------------------------------------------------------------------
datum/pspace_rng
	var/state = 1
	New(s)
		state = round(abs(s)) % 134456
		if(state <= 0) state = 1
	proc/next(max) //1..max
		state = (state * 8121 + 28411) % 134456
		return (state % max) + 1
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
	if(!pspace_seed)
		pspace_seed = rand(1, 134455)
		var/savefile/S = new("Galaxy")
		S["seed"] << pspace_seed
	if(!islist(pspace_superdb) || !pspace_superdb.len) //galaxia nova: espalha as 7 Super Dragon Balls
		pspace_sdb_scatter()
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
			pladata += list(list(D.name, "[S.sx],[S.sy]", "[D.biome]", "[D.gravity]", D.tint, D.pstate, "[D.px]", "[D.py]", "[D.seed]"))
	var/savefile/S = new("Galaxy")
	S["seed"] << pspace_seed
	S["sectors"] << secdata
	S["planets"] << pladata
	S["superdb"] << pspace_superdb

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
		last_visit = 0
		land_x = 0             // ponto de pouso em TERRA (o noise pode por agua no centro)
		land_y = 0
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
// [1] nome | [2] tint planicie | [3] tint flora | [4] inimigo | [5] tint agua ("LAVA" = Water7)
// [6] tint colina | [7] tint montanha | [8] arvores (lista) | [9] plantas colhiveis | [10] mult de minerio
var/list/pspace_biomes = list(
	list("Verdejante", "#ffffff", "#ffffff", /mob/npc/Enemy/Small_Saibaman, "#ffffff", "#c9d69a", "#9a9a8a", list(/obj/Trees/SmallTree), list(/obj/Plants/Orange), 1),
	list("Gelido", "#bcd8f0", "#9fc4e8", /mob/npc/Enemy/Dragon, "#bfe8ff", "#a8c4e0", "#dfeaf5", list(/obj/Trees/SmallTree), list(), 1),
	list("Deserto", "#e8cf7a", "#d8b860", /mob/npc/Enemy/Rat, "#8fd0c8", "#d8b860", "#b89848", list(/obj/Trees/PalmTree1), list(/obj/Plants/Opuntia), 1),
	list("Vulcanico", "#d8836a", "#7a5040", /mob/npc/Enemy/Dragon, "LAVA", "#b86048", "#6a4038", list(/obj/Trees/SmallTree), list(), 2),
	list("Alienigena", "#c9a0e8", "#a878d8", /mob/npc/Enemy/Small_Saibaman, "#b080e0", "#a878d8", "#7858a8", list(/obj/Trees/SmallTree), list(/obj/Plants/Orange), 1),
	list("Sombrio", "#8a93a8", "#6a7388", /mob/npc/Enemy/Zombie, "#5a6378", "#6a7388", "#4a5368", list(/obj/Trees/SmallTree), list(), 2))

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
		S.z = pspace_alloc_z(pspace_sector_zs, PSPACE_MAX_SECTORS, /proc/pspace_unload_sector_on)
		pspace_generate_sector(S)
	S.last_visit = world.time
	return S

//aloca um z de um pool: cria ate o teto, senao recicla o LRU sem players (dono e descarregado via unload_cb)
proc/pspace_alloc_z(list/pool, cap, unload_cb)
	if(pool.len < cap)
		world.maxz++
		pool += world.maxz
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
		WriteToLog("debug","pspace: pool estourou o teto ([cap]) -- novo z [world.maxz]")
		return world.maxz
	call(unload_cb)(bestz, 0) //descarrega o dono de verdade
	return bestz

//descarrega o SETOR que ocupa o z (cb do alloc): devolve last_visit no modo consulta
proc/pspace_unload_sector_on(pz, peek)
	for(var/k in pspace_sectors)
		var/datum/space_sector/S = pspace_sectors[k]
		if(S.z != pz || S.is_home) continue
		if(peek)
			//player na SUPERFICIE de um planeta deste setor: reciclar mataria o obj do
			//planeta e o Stars_Exit da superficie nao teria pra onde voltar (preso!)
			for(var/datum/pspace_planet/D in S.planets)
				if(!D.surface_z) continue
				for(var/mob/M in player_list)
					if(M.client && M.z == D.surface_z) return 999999999
			return S.last_visit
		for(var/o in S.spawned) if(o) del o
		S.spawned.Cut()
		for(var/mob/npc/N in world) if(N.z == pz) del N //NPC orfao que vazou pro espaco do setor
		for(var/datum/pspace_planet/D in S.planets)
			D.pobj = null //os objs morrem no del acima
		S.z = 0 //revisita regenera do seed
		return 0
	return 0

//descarrega a SUPERFICIE que ocupa o z (cb do alloc)
proc/pspace_unload_surface_on(pz, peek)
	for(var/pn in pspace_planets)
		var/datum/pspace_planet/D = pspace_planets[pn]
		if(D.surface_z != pz) continue
		if(peek) return D.last_visit
		for(var/o in D.spawned) if(o) del o
		D.spawned.Cut()
		for(var/mob/npc/N in world) if(N.z == pz) del N //inimigo que vagou pra fora da lista
		D.surface_z = 0
		return 0
	return 0

//gera o conteudo do setor no z dele (deterministico pelo seed)
proc/pspace_generate_sector(datum/space_sector/S)
	var/datum/pspace_rng/R = new(S.seed)
	var/area/SA = locate(/area/pspace_sector)
	//regiao util [1..PSPACE_SIZE]^2: estrelas, com anel de borda que cruza de setor
	for(var/xx = 1 to PSPACE_SIZE)
		for(var/yy = 1 to PSPACE_SIZE)
			CHECK_TICK
			var/turf/T
			if(xx == 1 || yy == 1 || xx == PSPACE_SIZE || yy == PSPACE_SIZE)
				T = new/turf/pspace_edge(locate(xx, yy, S.z))
			else
				T = new/turf/Other/Stars(locate(xx, yy, S.z))
			if(SA) SA.contents += T
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
		spawn(5) if(M) M.pspace_crossing = 0

mob/var/tmp/pspace_crossing = 0

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
	var/datum/pspace_planet/D = P.pdatum
	if(!D.surface_z) //constroi/regenera a superficie (lazy, deterministico)
		if(M.client) to_chat(M, "<font color=#88ccff>Entrando na atmosfera de [D.name]... (primeira visita: mapeando o terreno, aguarde)</font>")
		D.surface_z = pspace_alloc_z(pspace_surface_zs, PSURF_MAX_SURFACES, /proc/pspace_unload_surface_on)
		pspace_generate_surface(D)
	D.last_visit = world.time
	M.loc = locate(max(2, D.land_x + rand(-1, 1)), max(2, D.land_y + rand(-1, 1)), D.surface_z) //pousa em TERRA (o noise pode por lago no centro)
	M.Planet = D.name
	if(M.client) to_chat(M, "<font color=#88ccff><b>[D.name]</b> -- bioma [pspace_biomes[D.biome][1]], gravidade x[D.gravity].[D.gravity > M.GravMastered ? " <font color=red>CUIDADO: acima da sua maestria!</font>" : ""]</font>")

// ---- VALUE NOISE (Fase 2): grade coarse de valores + interpolacao bilinear suavizada ----
//BYOND nao tem Perlin nativo; isto gera relevo continuo deterministico do seed do planeta
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
	//2 oitavas de noise: forma geral (celulas ~16 tiles) + detalhe (celulas ~6 tiles)
	var/c1 = round(PSURF_SIZE / 16) + 2
	var/c2 = round(PSURF_SIZE / 6) + 2
	var/list/g1 = pspace_noise_grid(R, c1)
	var/list/g2 = pspace_noise_grid(R, c2)
	var/list/gstates = list("Grass1","Grass2","Grass3","Grass4","Grass5","Grass6")
	var/list/landspots = list() //amostra de tiles de planicie (spawn de inimigo/pouso)
	var/bestd = 999999 //tile de terra mais perto do centro = ponto de pouso
	var/ctr = round(PSURF_SIZE / 2)
	D.land_x = 0
	D.land_y = 0
	for(var/xx = 1 to PSURF_SIZE)
		if(xx % 8 == 0) sleep(-1) //yield regular: 250k turfs sem engasgar o servidor inteiro
		for(var/yy = 1 to PSURF_SIZE)
			CHECK_TICK
			if(xx == 1 || yy == 1 || xx == PSURF_SIZE || yy == PSURF_SIZE)
				var/turf/T = new/turf/Other/Stars_Exit(locate(xx, yy, D.surface_z)) //borda do planetoide: volta pro espaco
				T.icon = 'Grass.dmi' //com cara de CHAO do bioma (a textura de estrelas na borda ficava horrivel)
				T.icon_state = R.pickfrom(gstates)
				T.color = B[6] //tint de colina: borda levemente distinta comunica "fim do planetoide"
				D.parea.contents += T
				continue
			var/h = pspace_noise_at(g1, c1, (xx - 1) / 16, (yy - 1) / 16) * 0.7 + pspace_noise_at(g2, c2, (xx - 1) / 6, (yy - 1) / 6) * 0.3
			var/turf/T
			if(h < PSURF_H_WATER) //lago (Vulcanico: LAVA com dano)
				if(B[5] == "LAVA")
					T = new/turf/Water/Water7(locate(xx, yy, D.surface_z))
				else
					T = new/turf/Water/Water1(locate(xx, yy, D.surface_z))
					T.color = B[5]
			else if(h < PSURF_H_BEACH) //margem de terra batida
				T = new/turf/Ground/Ground8(locate(xx, yy, D.surface_z))
				T.color = B[6]
			else if(h < PSURF_H_HILL) //PLANICIE: onde a vida acontece
				T = new/turf/Grass(locate(xx, yy, D.surface_z))
				T.icon_state = R.pickfrom(gstates)
				T.color = B[2]
				var/d = (xx - ctr) * (xx - ctr) + (yy - ctr) * (yy - ctr)
				if(d < bestd)
					bestd = d
					D.land_x = xx
					D.land_y = yy
				if(R.next(150) == 1) landspots += locate(xx, yy, D.surface_z) //amostra ~0.7% (mundo 500x500: manter a lista pequena)
				if(R.next(100) <= PSURF_TREE_PROB)
					var/ttype = R.pickfrom(B[8])
					var/obj/tr = new ttype(locate(xx, yy, D.surface_z))
					tr.color = B[3]
					D.spawned += tr
				else if(islist(B[9]) && B[9]:len && R.next(100) <= PSURF_PLANT_PROB)
					var/ptype = R.pickfrom(B[9])
					var/obj/pl = new ptype(locate(xx, yy, D.surface_z))
					D.spawned += pl
			else if(h < PSURF_H_MOUNTAIN) //colina: arvores densas + MINERIOS
				T = new/turf/Grass(locate(xx, yy, D.surface_z))
				T.icon_state = R.pickfrom(gstates)
				T.color = B[6]
				if(R.next(100) <= PSURF_ORE_PROB * B[10])
					var/obj/ore
					if(R.next(4) == 1) ore = new/obj/Raw_Material/Quartz(locate(xx, yy, D.surface_z)) //gemas: 1/4 dos veios
					else ore = new/obj/Raw_Material/Ore(locate(xx, yy, D.surface_z))
					D.spawned += ore
				else if(R.next(100) <= PSURF_TREE_PROB * 2)
					var/ttype = R.pickfrom(B[8])
					var/obj/tr = new ttype(locate(xx, yy, D.surface_z))
					tr.color = B[3]
					D.spawned += tr
			else //montanha: parede densa
				T = new/turf/UnbreakableTurfs/Void_Wall(locate(xx, yy, D.surface_z))
				T.color = B[7]
			D.parea.contents += T
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
// SUPER DRAGON BALLS: 7 esferas gigantes espalhadas em setores aleatorios.
// A POSICAO vive no registro (persistido no "Galaxy"); o obj so existe quando o
// setor esta carregado. Coletar marca held; com as 7 no inventario, o portador
// invoca SUPER SHENRON (1 desejo) e elas se espalham de novo.
// ---------------------------------------------------------------------------
proc/pspace_sdb_scatter() //posicoes NOVAS aleatorias (nao-deterministico de proposito)
	pspace_superdb = list()
	for(var/n = 1 to 7)
		var/sx = 0
		var/sy = 0
		while(abs(sx) + abs(sy) < SDB_MIN_DIST)
			sx = rand(-SDB_MAX_DIST, SDB_MAX_DIST)
			sy = rand(-SDB_MAX_DIST, SDB_MAX_DIST)
		pspace_superdb += list(list(n, sx, sy, rand(20, PSPACE_SIZE - 20), rand(20, PSPACE_SIZE - 20), 0))
	//setor da esfera ja carregado agora (re-espalhamento pos-desejo): poe o obj na hora
	for(var/list/E in pspace_superdb)
		var/datum/space_sector/S = pspace_sectors["[E[2]],[E[3]]"]
		if(S && S.z)
			S.spawned += pspace_sdb_spawn(E, S.z)

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
	desc = "Uma esfera do dragao GIGANTE, do tamanho de um pequeno planetoide. Dizem que as sete invocam um dragao capaz de qualquer coisa."
	pixel_x = -16 //64x64 centrado no tile
	pixel_y = -16
	density = 0
	SaveItem = 0 //a posicao no mundo vive no registro da galaxia; no inventario salva com o dono
	var/sdb_num = 1
	Click()
		if(!usr || !usr.client) return
		if(!loc || ismob(loc)) return //ja esta com alguem
		if(get_dist(usr, src) > 1)
			to_chat(usr, "Chegue mais perto da esfera.")
			return
		var/list/E = pspace_sdb_entry(sdb_num)
		if(E) E[6] = 1 //held: o registro para de spawnar/apontar esta esfera
		loc = usr
		usr.InvenSet()
		to_chat(world, "<font color=#e8b64c><b>[usr] encontrou a Super Dragon Ball de [sdb_num] estrela\s nas profundezas da galaxia!</b></font>", "announce")
		pspace_save()
	verb/Invocar_Super_Shenron()
		set category = null
		set src in usr
		var/mob/U = usr
		var/list/have = list()
		for(var/obj/items/SuperDragonBall/B in U.contents)
			have["[B.sdb_num]"] = B
		if(have.len < 7)
			to_chat(U, "<font color=#e8b64c>Voce sente o poder da esfera... mas so tem [have.len] de 7. O dragao exige todas.</font>")
			return
		var/wish = input(U, "SUPER SHENRON atende UM desejo.", "Super Shenron") as null|anything in list("Riqueza colossal ([FullNum(SDB_WISH_ZENNI)] zenni)", "Reviver um guerreiro caido", "Cancelar")
		if(!wish || wish == "Cancelar") return
		if(wish == "Reviver um guerreiro caido")
			var/list/deads = list()
			for(var/mob/M in player_list)
				if(M.client && M.dead) deads += M
			if(!deads.len)
				to_chat(U, "Nenhum guerreiro caido (online) para reviver.")
				return
			var/mob/T = input(U, "Reviver quem?", "Super Shenron") as null|anything in deads
			if(!T || !T.dead) return
			to_chat(world, "<font color=#e8b64c><b>O ceu de TODA a galaxia escurece... [U] invocou SUPER SHENRON!</b></font>", "announce")
			U.emit_Sound('thunderclap.wav')
			Revive(T, 1)
			T.loc = locate(U.x + 1, U.y, U.z)
			to_chat(world, "<font color=#e8b64c><b>SUPER SHENRON trouxe [T] de volta a vida!</b></font>", "announce")
		else
			to_chat(world, "<font color=#e8b64c><b>O ceu de TODA a galaxia escurece... [U] invocou SUPER SHENRON!</b></font>", "announce")
			U.emit_Sound('thunderclap.wav')
			U.zenni += SDB_WISH_ZENNI
			to_chat(world, "<font color=#e8b64c><b>SUPER SHENRON concedeu riqueza colossal a [U]!</b></font>", "announce")
		//consome as 7 e re-espalha pela galaxia
		for(var/k in have)
			var/obj/B = have[k]
			del B
		pspace_sdb_scatter()
		pspace_save()
		to_chat(world, "<font color=#e8b64c>O desejo foi realizado... e as Super Dragon Balls, drenadas, se espalharam novamente pela galaxia.</font>", "announce")

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
			to_chat(usr, "<font color=#e8b64c>SDB [E[1]] -- [E[6] ? "COLETADA" : "setor ([E[2]],[E[3]]) em ([E[4]],[E[5]])"]</font>")

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
