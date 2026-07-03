// ============================================================================
// MEDITACAO PROFUNDA -- A DIMENSAO MENTAL (substitui o minigame antigo)
//   * Ao escolher "meditacao profunda" no Meditate, o CORPO continua sentado
//     meditando (um dummy visual identico fica no lugar) e o jogador passa a
//     controlar o personagem DENTRO DA PROPRIA MENTE: um plano branco 100x100
//     ('White.dmi') num z-level proprio.
//   * La dentro ele enfrenta um NPC CLONE de si mesmo (mesmo BP/visual).
//   * Clicar Meditate DE NOVO = acordar: volta pro corpo e NENHUM ferimento
//     sofrido na mente retorna (snapshot de HP/membros/Ki restaurado).
//   * DOIS jogadores meditando lado a lado entram na MESMA dimensao -- sem
//     NPC: so eles, podendo lutar entre si.
//   * Ganho de BP la dentro = 1/4 do normal; gravidade = 1x (a area "Mind
//     Dimension" cai no default do Grav()).
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define MIND_CELL          100   // lado da arena mental (100x100, incluindo as paredes)
#define MIND_MAX_CELLS     8     // maximo de mentes simultaneas (celulas no z mental)
#define MIND_GAIN_MULT     0.25  // ganho de BP dentro da mente = 1/4 do de fora
#define MIND_CLONE_REVIVE  150   // ticks ate o clone derrotado se reerguer (15s)
#define MIND_KO_EJECT      50    // ticks nocauteado dentro da mente ate ser expulso (5s)

// ---------------------------------------------------------------------------
// terreno / area da dimensao mental
// ---------------------------------------------------------------------------
turf/MindFloor
	name = "mente"
	icon = 'White.dmi'
	density = 0
	destroyable = 0 //a mente nao vira cratera
	isSpecial = 1

turf/MindWall
	name = "limite da mente"
	icon = 'White.dmi' //identica ao chao: o limite da mente e invisivel (so esbarra)
	density = 1
	opacity = 0
	destroyable = 0
	isSpecial = 1
	Enter(atom/movable/A) //bloqueia TODO mob (inclusive voando), igual a parede do bolsao Majin
		if(ismob(A)) return 0
		return ..()

area/MindDim
	Planet = "Mind Dimension" //nao esta no switch do Grav() -> cai no else: Planetgrav = 1 (spec: gravidade 1x)
	InsideArea = 1

// ---------------------------------------------------------------------------
// o z-level mental + celulas (construcao preguicosa, padrao do bolsao Majin)
// ---------------------------------------------------------------------------
var/mind_z = 0                       // z da dimensao mental desta sessao do servidor
var/list/mind_cell_busy = list()     // celulas ocupadas (index -> 1)
var/list/mind_cell_built = list()    // celulas ja construidas (turfs criados)
var/area/MindDim/mind_area = null

proc/build_mind_z()
	if(mind_z && mind_z <= world.maxz) return mind_z
	var/iz = world.maxz + 1
	world.maxz = iz
	mind_z = iz
	mind_area = new
	return mind_z

//origem (canto inferior-esquerdo) da celula k, distribuidas em grade com folga de 10 tiles
proc/mind_cell_origin(k)
	var/cols = max(1, round((world.maxx - 2) / (MIND_CELL + 10)))
	var/col = (k - 1) % cols
	var/row = round((k - 1) / cols)
	return list(2 + col * (MIND_CELL + 10), 2 + row * (MIND_CELL + 10))

proc/build_mind_cell(k)
	if("[k]" in mind_cell_built) return 1
	var/list/o = mind_cell_origin(k)
	var/ox = o[1]
	var/oy = o[2]
	if(ox + MIND_CELL - 1 > world.maxx || oy + MIND_CELL - 1 > world.maxy) return 0 //nao cabe no mapa
	for(var/xx = ox to ox + MIND_CELL - 1)
		for(var/yy = oy to oy + MIND_CELL - 1)
			CHECK_TICK
			var/turf/T
			if(xx == ox || yy == oy || xx == ox + MIND_CELL - 1 || yy == oy + MIND_CELL - 1)
				T = new /turf/MindWall(locate(xx, yy, mind_z))
			else
				T = new /turf/MindFloor(locate(xx, yy, mind_z))
			if(mind_area && T) mind_area.contents.Add(T)
	mind_cell_built["[k]"] = 1
	return 1

proc/mind_alloc_cell()
	for(var/k = 1 to MIND_MAX_CELLS)
		if(mind_cell_busy["[k]"]) continue
		if(!build_mind_cell(k)) continue
		mind_cell_busy["[k]"] = 1
		return k
	return 0

proc/mind_free_cell(k)
	if(k) mind_cell_busy["[k]"] = null

// ---------------------------------------------------------------------------
// vars do mob (as NAO-tmp persistem: recuperam um save feito dentro da mente)
// ---------------------------------------------------------------------------
mob/var
	mind_active = 0          //esta (ou o save foi feito) dentro da dimensao mental
	mind_ret_x = 0           //onde o corpo estava meditando (volta pra ca)
	mind_ret_y = 0
	mind_ret_z = 0
	mind_premurder = 0       //murderToggle de antes (dentro da mente ninguem MATA de verdade)
	mind_snap_hp = 100       //snapshot do corpo na entrada: ferimentos mentais NAO voltam
	mind_snap_ki = 0
	mind_snap_stam = 0
	list/mind_snap_limbs = null
mob/var/tmp
	datum/mind_session/mind_session = null
	obj/mind_dummy/mind_dummy_ref = null

//ganho de BP dentro da mente = 1/4 (multiplicado nos *_Gain, igual ao htc_gain_mult)
mob/proc/mind_gain_mult()
	if(mind_z && z == mind_z) return MIND_GAIN_MULT
	return 1

// ---------------------------------------------------------------------------
// o dummy que fica meditando no lugar do corpo
// ---------------------------------------------------------------------------
obj/mind_dummy
	density = 1
	Savable = 0
	var/datum/mind_session/session = null

// ---------------------------------------------------------------------------
// a sessao (uma "mente" aberta; compartilhada se meditarem lado a lado)
// ---------------------------------------------------------------------------
datum/mind_session
	var
		active = 0
		cell = 0
		zlevel = 0
		cx = 0                  //centro da celula
		cy = 0
		list/members = list()
		mob/npc/MindClone/clone = null

	proc/setup()
		cell = mind_alloc_cell()
		if(!cell) return 0
		zlevel = mind_z
		var/list/o = mind_cell_origin(cell)
		cx = o[1] + round(MIND_CELL / 2)
		cy = o[2] + round(MIND_CELL / 2)
		active = 1
		return 1

	proc/add_member(mob/M)
		if(!M) return
		members += M
		if(members.len == 1)
			M.loc = locate(cx - 3, cy, zlevel)
			M.dir = EAST
			spawn(5) spawn_clone(M) //mente solitaria: o desafio e VOCE MESMO
		else
			//outra pessoa entrou na MESMA mente: sem NPC -- so eles (podem lutar entre si)
			if(clone)
				var/mob/npc/MindClone/C = clone
				clone = null
				if(C) del(C)
			M.loc = locate(cx + 3, cy, zlevel)
			M.dir = WEST
			for(var/mob/O in members)
				if(O != M && O.client) to_chat(O, "<font color=#b080ff><b>Outra consciencia adentra a sua mente... e [M.name].</b></font>")
		to_chat(M, "<font color=#b080ff><b>Voce mergulha na propria mente.</b> Aqui nada e real: ferimentos nao voltam com voce. Use <b>Meditate</b> de novo para acordar.</font>")

	proc/remove_member(mob/M)
		members -= M
		for(var/mob/O in members)
			if(O && O.client) to_chat(O, "<font color=#b080ff>A presenca de [M ? M.name : "alguem"] se desfaz da sua mente...</font>")
		if(!members.len) finish()

	proc/finish()
		if(!active) return
		active = 0
		if(clone)
			var/mob/npc/MindClone/C = clone
			clone = null
			if(C) del(C)
		mind_free_cell(cell)
		cell = 0

	//o reflexo: NPC clone identico ao meditador -- construcao AUTOSSUFICIENTE (receita do guardiao
	//Majin: new com loc + espelho manual de stats + statify), SEM makeCopy/genetica (que ja matou
	//esse tipo de spawn duas vezes: runtime na genetica e deadlock de loc)
	proc/spawn_clone(mob/M)
		if(clone || !active || !M) return
		var/oldspawns = npcspawnson //spawn de evento: ignora o toggle de spawns ambientes
		npcspawnson = 1
		var/mob/npc/MindClone/C = new(locate(cx + 3, cy, zlevel))
		npcspawnson = oldspawns
		if(!C || !C.loc)
			to_chat(M, "<font color=#b080ff>O vazio permanece... sua outra metade nao se manifestou.</font>")
			return
		C.name = M.name
		C.gender = M.gender
		C.Race = M.Race
		C.Parent_Race = M.Parent_Race
		C.appearance = M.appearance //espelho perfeito (icone + overlays builtin/roupas + cor/transform)
		C.icon_state = ""
		C.oicon = M.icon
		//CABELO/RABO/OLHOS: nao fazem parte do appearance -- sao objetos /obj/overlay em vis_contents
		//(por isso o reflexo nascia CARECA e de olho padrao). "Assa" o visual atual deles nos overlays
		//do clone: snapshot estatico com a cor do momento, sem compartilhar objetos vivos.
		for(var/obj/overlay/hairs/HO in M.vis_contents)
			C.overlays += HO
		for(var/obj/overlay/eyes/EO in M.vis_contents) //olho com a COR escolhida (eyeicon ja vem tintado)
			C.overlays += EO
		//espelho dos stats de combate, com o MESMO poder expresso (forma atual inclusa)
		C.mind_seed_bp = max(round(M.expressedBP), 1)
		C.BP = C.mind_seed_bp
		C.physoff = M.physoff
		C.physdef = M.physdef
		C.technique = M.technique
		C.kioff = M.kioff
		C.kidef = M.kidef
		C.kiskill = M.kiskill
		C.speed = M.speed
		C.blastR = M.blastR
		C.blastG = M.blastG
		C.blastB = M.blastB
		C.statify()
		C.Ki = C.MaxKi
		C.stamina = C.maxstamina
		C.Anger = 100
		C.staminadeBuff = 100
		C.maxNutrition = 100
		C.currentNutrition = 100
		C.powerlevel()
		C.HP = 100
		C.KO = 0
		C.haszanzo = M.haszanzo
		C.isBlaster = 1
		C.murderToggle = 0 //o reflexo nocauteia, nunca mata
		C.attackable = 1
		C.Savable = 0
		C.dir = WEST
		clone = C
		to_chat(M, "<font color=#b080ff><b>Do vazio branco, VOCE MESMO se ergue diante de voce...</b></font>")
		spawn(10) if(C && M && active && M.client) C.foundTarget(M)
		spawn clone_watch()

	//o reflexo derrotado se reergue (parceiro de treino infinito)
	proc/clone_watch()
		set waitfor = 0
		set background = 1
		while(active && clone)
			sleep(20)
			if(!active || !clone) break
			if(clone.KO)
				var/mob/npc/MindClone/CC = clone
				for(var/mob/P in members)
					if(P.client) to_chat(P, "<font color=#b080ff>Seu reflexo cai... mas a mente nunca descansa.</font>")
				sleep(MIND_CLONE_REVIVE)
				if(!active || clone != CC || !CC) break
				if(CC.KO) spawn CC.Un_KO()
				CC.SpreadHeal(150, 1, 1)
				if(CC.MaxKi) CC.Ki = CC.MaxKi
				for(var/mob/P in members)
					if(P.client) to_chat(P, "<font color=#b080ff><b>Seu reflexo se levanta de novo!</b></font>")
				var/mob/T2 = members.len ? members[1] : null
				if(T2 && T2.client) spawn(5) CC.foundTarget(T2)

// o NPC reflexo
mob/npc/MindClone
	hasAI = 1
	monster = 1          //revida quando provocado (padrao dos NPCs lutadores)
	AIAlwaysActive = 0   //nao caca ninguem sozinho (a sessao o engaja)
	attackable = 1
	mindswappable = 0
	dropsCorpse = 0
	itemrarity = 0
	aggro_dist = 40
	behavior_vals = list(90, 70, 0, 70) //destemido, agressivo, SEM misericordia (e a sua sombra...)
	var/mind_seed_bp = 0
	//BP PINADO no poder do meditador: NAO usa o NPCTicker base (que inflaria pro rand(AverageBP*0.5...))
	NPCTicker()
		set waitfor = 0
		set background = 1
		AIRunning = 1
		if(mind_seed_bp) BP = mind_seed_bp
		BPBoost = 1

// ---------------------------------------------------------------------------
// entrada / saida / vigilancia
// ---------------------------------------------------------------------------
mob/proc/mind_snapshot()
	mind_snap_hp = HP
	mind_snap_ki = Ki
	mind_snap_stam = stamina
	mind_snap_limbs = list()
	for(var/datum/Body/S in body)
		mind_snap_limbs[S.name] = S.health
		mind_snap_limbs["[S.name]__lop"] = S.lopped ? 1 : 0

mob/proc/mind_restore() //devolve o corpo EXATAMENTE como entrou: nada da mente e real
	if(islist(mind_snap_limbs))
		for(var/datum/Body/S in body)
			if(S.name in mind_snap_limbs)
				if(S.lopped && !mind_snap_limbs["[S.name]__lop"]) S.RegrowLimb()
				S.health = min(mind_snap_limbs[S.name], S.maxhealth)
	HP = mind_snap_hp
	if(MaxKi) Ki = min(mind_snap_ki, MaxKi)
	if(maxstamina) stamina = min(mind_snap_stam, maxstamina)
	if(KO) spawn Un_KO()
	mind_snap_limbs = null

mob/proc/mind_enter()
	set waitfor = 0
	if(mind_session || !client || dead || KO) return
	if(!build_mind_z())
		to_chat(src, "Sua mente esta agitada demais para o transe.")
		return
	//meditando ao lado do CORPO de alguem ja em transe? entra na MESMA mente
	var/datum/mind_session/S = null
	for(var/obj/mind_dummy/D in oview(1, src))
		if(D.session && D.session.active)
			S = D.session
			break
	if(!S)
		S = new /datum/mind_session
		if(!S.setup())
			to_chat(src, "Sua mente esta agitada demais para o transe. (sem espaco)")
			return
	//snapshot do corpo (ferimentos mentais NAO retornam)
	mind_snapshot()
	mind_ret_x = x
	mind_ret_y = y
	mind_ret_z = z
	mind_premurder = murderToggle
	murderToggle = 0
	mind_active = 1
	//o corpo continua "meditando": um dummy identico fica no lugar
	var/obj/mind_dummy/D2 = new(loc)
	D2.appearance = appearance
	D2.icon_state = "Meditate"
	D2.name = name
	D2.session = S
	mind_dummy_ref = D2
	//acorda o estado mecanico (dentro da mente ele LUTA) e mergulha
	med = 0
	deepmeditation = 0
	studytech = 0
	icon_state = ""
	emit_Sound('teleport.wav')
	mind_session = S
	S.add_member(src)
	spawn mind_monitor()

//forced: 1 = saida imediata (logout/KO/morte mental), 2 = ja saiu do z por outros meios (nao mexe no loc)
mob/proc/mind_exit(forced = 0)
	var/datum/mind_session/S = mind_session
	mind_session = null
	if(!mind_active && !S) return
	mind_restore() //ferimentos da mente NAO voltam pro corpo
	murderToggle = mind_premurder
	mind_active = 0
	var/tx = mind_ret_x
	var/ty = mind_ret_y
	var/tz = mind_ret_z
	var/obj/mind_dummy/D = mind_dummy_ref
	mind_dummy_ref = null
	if(D)
		tx = D.x
		ty = D.y
		tz = D.z
		del(D)
	if(forced != 2 && tz)
		loc = locate(tx, ty, tz)
	med = 0
	deepmeditation = 0
	icon_state = ""
	if(client)
		to_chat(src, "<font color=#b080ff><b>Voce abre os olhos.</b> O transe termina; seu corpo esta exatamente como o deixou.</font>")
		to_chat(view(src), "<font color=#b080ff>[src] desperta da meditacao.</font>")
	if(S) S.remove_member(src)

//vigia: deslogou / saiu do z / "morreu" / KO na mente -> acorda
mob/proc/mind_monitor()
	set waitfor = 0
	set background = 1
	while(src && mind_session)
		sleep(10)
		if(!src || !mind_session) break
		if(!client)
			mind_exit(1) //deslogou dentro da mente (o Logout tambem cobre; redundancia segura)
			break
		if(mind_session && z != mind_session.zlevel)
			mind_exit(2) //saiu da dimensao por outros meios: acorda sem teleportar
			break
		if(dead) //morte MENTAL nao e real: desfaz e acorda
			dead = 0
			buudead = 0
			mind_exit(1)
			break
		if(KO) //nocauteado na propria mente: e expulso do transe
			var/kot = 0
			while(src && KO && kot < MIND_KO_EJECT)
				sleep(10)
				kot += 10
			if(src && mind_session)
				if(KO) spawn Un_KO()
				to_chat(src, "<font color=#b080ff>Sua consciencia e EXPULSA da propria mente!</font>")
				mind_exit(1)
			break

//logout: restaura o corpo ANTES do save (senao o save congela o personagem dentro da mente)
mob/Logout()
	if(mind_session) mind_exit(1)
	..()

//login: o save foi feito DENTRO da mente (crash/queda)? acorda no corpo com o snapshot restaurado
mob/proc/mind_login_check()
	if(!mind_active) return
	mind_restore()
	murderToggle = mind_premurder
	mind_active = 0
	if(mind_ret_z) loc = locate(mind_ret_x, mind_ret_y, mind_ret_z)
	med = 0
	deepmeditation = 0
	icon_state = ""
	to_chat(src, "<font color=#b080ff>Voce desperta do transe profundo.</font>")
