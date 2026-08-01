// ============================================================================
// BEAMCLASH -- disputa de beams (estilo Kamehameha vs Kamehameha)
//   * Quando DOIS BEAMS (WaveAttack) de donos diferentes colidem e os dois
//     donos ainda estao canalizando, comeca uma DISPUTA em vez da resolucao
//     automatica por BP do Bump().
//   * Cada jogador APERTA ESPACO varias vezes para empurrar o embate (a tecla
//     chega via UseKey "space" -> bcl_press(); Hotkeys.dm).
//   * PODER DE LUTA IMPORTA: cada aperto do mais forte empurra mais -- com o
//     dobro do BP, cada aperto vale 2x (teto BCL_ADV_CAP), entao ele pode
//     apertar bem mais devagar e ainda vencer. Ha tambem uma deriva passiva
//     a favor do mais forte.
//   * A IA sabe: NPC responde beam com beam (contra-ataque) e "aperta" sozinho
//     numa taxa que escala com a inteligencia.
//   * Tela treme para quem esta perto + orbe de choque com barra da disputa,
//     ondas de choque e poeira no ponto de colisao.
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define BCL_TICK            2     // passo do loop da disputa (2 ticks = 0.2s)
#define BCL_PUSH_PER_PRESS  2.2   // forca base de cada aperto de ESPACO (pontos do medidor)
#define BCL_ADV_CAP         6     // teto da vantagem por BP (com 6x+ de BP cada aperto vale 6x)
#define BCL_DRIFT_PER_TICK  0.45  // deriva passiva por tick a favor do lado mais forte
#define BCL_MAX_SECONDS     22    // duracao maxima da disputa; expira -> decide pelo medidor
#define BCL_KI_PER_TICK     0.004 // fracao do MaxKi que CADA lado queima por tick de disputa
#define BCL_PRESS_TICK_CAP  5     // apertos aceitos por tick (anti-macro: 5/0.2s = 25/s)
#define BCL_SHAKE_RANGE     10    // ate quantos tiles da colisao a tela treme
#define BCL_SHAKE_BASE      3     // forca base do tremor (pixels)
#define BCL_NPC_CPS         3.2   // "apertos por segundo" base de um NPC na disputa
#define BCL_NPC_DETECT      7     // distancia em que o NPC percebe um beam vindo
#define BCL_NPC_BEAM_CD     220   // cooldown (ticks) entre contra-beams do NPC
#define BCL_NPC_BEAM_TIME   120   // duracao maxima (ticks) do canal de beam do NPC
#define BCL_NPC_KI_MIN      0.25  // fracao minima de Ki para o NPC tentar o contra-beam
#define BCL_PUSH_STEP       2     // ticks entre cada tile do EMPURRAO pos-vitoria (2 = 0.2s por tile)
#define BCL_PUSH_MAX        30    // tiles maximos do empurrao antes do beam vencedor retomar o voo normal

// ---------------------------------------------------------------------------
// vars
// ---------------------------------------------------------------------------
obj/attack/var/tmp/in_beamclash = 0   // este segmento/cabeca esta preso numa disputa (KHH nao re-anda)
mob/var/tmp
	datum/beamclash/beamclash = null  // disputa em que este mob esta (null = nenhuma)
	bcl_presses = 0                   // apertos de ESPACO acumulados desde o ultimo tick da disputa
mob/npc/var/tmp
	bcl_npc_beam_cd = 0               // world.time do proximo contra-beam permitido

// aperto de ESPACO (roteado pelo UseKey em Hotkeys.dm)
mob/proc/bcl_press()
	if(!beamclash) return
	if(bcl_presses < BCL_PRESS_TICK_CAP) bcl_presses++

// ---------------------------------------------------------------------------
// o orbe de energia no ponto de colisao (com a barra da disputa em maptext)
// ---------------------------------------------------------------------------
obj/beamclash_orb
	icon = '12.dmi'
	icon_state = ""
	density = 0
	mouse_opacity = 0
	layer = MOB_LAYER + 3 //acima de mobs e dos segmentos de beam (sem KI_PLANE: o define vem num include posterior)
	pixel_x = 0
	pixel_y = 0
	maptext_width = 160
	maptext_height = 48

// ---------------------------------------------------------------------------
// inicio: chamado pelo Bump() beam-vs-beam (objects.dm). Retorna 1 se a
// disputa comecou (o Bump entao NAO roda a resolucao automatica).
// ---------------------------------------------------------------------------
proc/bcl_try_start(obj/attack/blast/one, obj/attack/blast/two)
	if(!one || !two || !one.loc || !two.loc) return 0
	if(!one.WaveAttack || !two.WaveAttack) return 0 //disputa e coisa de BEAM canalizado
	var/mob/A = one.proprietor
	var/mob/B = two.proprietor
	if(!istype(A) || !istype(B) || A == B) return 0
	if(A.beamclash || B.beamclash) return 0            // alguem ja esta noutra disputa
	if(!A.beaming || !B.beaming) return 0              // os dois lados precisam estar canalizando
	if(A.KO || B.KO || A.dead || B.dead) return 0
	var/datum/beamclash/C = new
	C.A = A
	C.B = B
	C.headA = one
	C.headB = two
	spawn C.start()
	return 1

// ---------------------------------------------------------------------------
// a disputa em si
// ---------------------------------------------------------------------------
datum/beamclash
	var
		mob/A                  // lado A (dono do beam que deu o Bump)
		mob/B                  // lado B
		obj/attack/blast/headA
		obj/attack/blast/headB
		obj/beamclash_orb/orb
		turf/center
		meter = 50             // 0..100; 100 = A vence, 0 = B vence
		running = 0
		list/shaken = list()   // clients com a tela tremendo (p/ restaurar no fim)

	proc/start()
		set waitfor = 0
		set background = 1
		if(running) return
		running = 1
		A.beamclash = src
		B.beamclash = src
		A.bcl_presses = 0
		B.bcl_presses = 0
		//congela as duas cabecas no lugar (o guard in_beamclash impede o KHH de re-andar)
		headA.in_beamclash = 1
		headB.in_beamclash = 1
		walk(headA, 0)
		walk(headB, 0)
		headA.icon_state = "struggle"
		headB.icon_state = "struggle"
		center = headB.loc //ponto de colisao (a cabeca que levou o Bump)
		//orbe de choque com a cor dos dois blasts misturada
		orb = new(center)
		orb.icon += rgb(round((A.blastR + B.blastR) / 2), round((A.blastG + B.blastG) / 2), round((A.blastB + B.blastB) / 2))
		//avisos
		var/msg = "<font color=#ffcc33><b>DISPUTA DE BEAMS!</b> Os ataques de [A.name] e [B.name] colidem!!"
		for(var/mob/P in view(BCL_SHAKE_RANGE + 3, center))
			if(P.client) to_chat(P, msg)
		if(A.client) to_chat(A, "<font color=#ffee66><b>APERTE ESPACO VARIAS VEZES para empurrar o beam!</b>")
		if(B.client) to_chat(B, "<font color=#ffee66><b>APERTE ESPACO VARIAS VEZES para empurrar o beam!</b>")
		A.emit_Sound('kamehameha_fire.wav')
		B.emit_Sound('kamehameha_fire.wav')
		createShockwavemisc(center, 3)
		clash_loop()

	//vantagem do lado 'mine' sobre 'theirs' pelo poder de luta (1 = iguais; teto BCL_ADV_CAP)
	proc/advantage(mob/mine, mob/theirs)
		var/a = max(mine ? mine.expressedBP : 1, 1)
		var/b = max(theirs ? theirs.expressedBP : 1, 1)
		return min(max(a / b, 1 / BCL_ADV_CAP), BCL_ADV_CAP)

	//"apertos" do tick: player = teclas acumuladas; NPC/sem client = taxa automatica da IA
	proc/side_presses(mob/M)
		if(!M) return 0
		if(M.client)
			var/p = M.bcl_presses
			M.bcl_presses = 0
			return p
		var/intel = 50
		if(istype(M, /mob/npc))
			var/mob/npc/N = M
			intel = N.ai_intelligence
		return (BCL_NPC_CPS * (0.5 + intel / 100)) * (BCL_TICK / 10) //apertos/seg -> apertos/tick

	proc/side_ok(mob/M, obj/attack/blast/H)
		if(!M || M.dead || M.KO) return 0
		if(!H || !H.loc) return 0
		if(!M.beaming) return 0 //soltou a canalizacao: perdeu o lado
		if(M.Ki <= 1) return 0
		return 1

	proc/clash_loop()
		set waitfor = 0
		set background = 1
		var/t = 0
		var/fxtick = 0
		while(running)
			sleep(BCL_TICK)
			t += BCL_TICK
			//---- validade dos dois lados ----
			if(!side_ok(A, headA))
				resolve(B, A, "o beam de [A ? A.name : "?"] perde a firmeza")
				return
			if(!side_ok(B, headB))
				resolve(A, B, "o beam de [B ? B.name : "?"] perde a firmeza")
				return
			//---- custo de sustentar a disputa ----
			A.Ki = max(A.Ki - A.MaxKi * BCL_KI_PER_TICK, 0)
			B.Ki = max(B.Ki - B.MaxKi * BCL_KI_PER_TICK, 0)
			//---- fisica do medidor: apertos x vantagem de BP + deriva passiva ----
			var/advA = advantage(A, B)
			var/advB = advantage(B, A)
			meter += side_presses(A) * BCL_PUSH_PER_PRESS * advA
			meter -= side_presses(B) * BCL_PUSH_PER_PRESS * advB
			meter += (advA - advB) * BCL_DRIFT_PER_TICK //o mais forte empurra sozinho
			meter = min(max(meter, 0), 100)
			ue_clash_tick(src, t) //HAKAI INFUSION: o beam infundido DEVORA o rival a cada 5s (UltraEgo.dm)
			//---- resolucao ----
			if(meter >= 100)
				resolve(A, B, "o poder de [A.name] engole a disputa")
				return
			if(meter <= 0)
				resolve(B, A, "o poder de [B.name] engole a disputa")
				return
			if(t >= BCL_MAX_SECONDS * 10)
				if(meter > 55) resolve(A, B, "a disputa se decide no limite")
				else if(meter < 45) resolve(B, A, "a disputa se decide no limite")
				else draw()
				return
			//---- FX: orbe pulsando + barra, tremor, ondas de choque ----
			fxtick++
			update_orb()
			shake_tick()
			if(fxtick % 5 == 0) //~1x por segundo
				createShockwavemisc(center, rand(1, 2))
				if(prob(60)) createDustmisc(center, 1)
				if(prob(40))
					A.emit_Sound('scouterexplode.ogg')
				A.refresh_combat_tag() //a disputa E combate (mantem tag + musica de batalha)
				B.refresh_combat_tag()

	proc/update_orb()
		if(!orb) return
		//pulso do orbe: cresce com a tensao (quanto mais perto do fim, maior)
		var/tension = 1.6 + abs(meter - 50) / 40 + rand(0, 3) / 10
		var/matrix/mx = matrix()
		mx.Scale(tension, tension)
		animate(orb, transform = mx, time = BCL_TICK)
		//empurra o orbe visualmente na direcao do perdedor (ao longo do eixo do beam A)
		var/push = round((meter - 50) / 50 * 20)
		var/px = 0
		var/py = 0
		switch(headA ? headA.dir : EAST)
			if(EAST) px = push
			if(WEST) px = -push
			if(NORTH) py = push
			if(SOUTH) py = -push
			if(NORTHEAST) { px = push; py = push }
			if(NORTHWEST) { px = -push; py = push }
			if(SOUTHEAST) { px = push; py = -push }
			if(SOUTHWEST) { px = -push; py = -push }
		orb.pixel_x = px
		orb.pixel_y = py
		//barra da disputa (A a esquerda): #### = dominio de A
		var/filled = round(meter / 10)
		var/bar = ""
		for(var/i = 1 to 10)
			bar += (i <= filled ? "#" : "-")
		orb.maptext_x = -64 + px
		orb.maptext_y = 36 + py
		orb.maptext = "<center><font color=#ffee66><b>\[[bar]\]</b></font></center>"

	proc/shake_tick()
		var/str = BCL_SHAKE_BASE + round(abs(meter - 50) / 12) //treme mais forte perto da definicao
		for(var/mob/P in view(BCL_SHAKE_RANGE, center))
			if(!P.client) continue
			shaken |= P.client
			P.client.pixel_x = rand(-str, str)
			P.client.pixel_y = rand(-str, str)

	proc/unshake()
		for(var/client/C in shaken)
			if(!C) continue
			C.pixel_x = 0
			C.pixel_y = 0
		shaken.Cut()

	//W venceu, L perdeu: o beam vencedor EMPURRA o do perdedor de volta, tile a tile,
	//ate o ataque atingir o perdedor (estilo Budokai Tenkaichi / Sparking Zero)
	proc/resolve(mob/W, mob/L, motivo)
		if(!running) return
		running = 0
		var/obj/attack/blast/hW = (W == A) ? headA : headB
		var/obj/attack/blast/hL = (W == A) ? headB : headA
		for(var/mob/P in view(BCL_SHAKE_RANGE + 3, center))
			if(P.client) to_chat(P, "<font color=#ffcc33><b>[W ? W.name : "?"] VENCE a disputa de beams</b> ([motivo]) -- o ataque comeca a EMPURRAR o do rival de volta!!")
		createShockwavemisc(center, 4)
		createDustmisc(center, 2)
		if(W) W.emit_Sound('scouterexplode.ogg')
		//o perdedor perde o canal (mesma receita do reflect de beams do Bump)
		if(L)
			L.beaming = 0
			L.bypass = 0
			L.beamprocrunning = 0
			L.beamisrunning = 0
			L.beamturndelay = 0
			L.turnlock = 0
			L.stopbeaming()
			if(L.client) to_chat(L, "<font color=red><b>Seu beam esta sendo EMPURRADO DE VOLTA!!</b>")
		if(W && hW) hW.BP = W.expressedBP * max(hW.wavemultipl, 1) //a cabeca vencedora carrega o BP atual do dono no impacto
		//vencedor BEAM -> fase de EMPURRAO cinematografico (o orbe/tremor seguem vivos ate o impacto)
		if(hW && hW.loc)
			spawn push_phase(W, L, hW, hL)
			return
		//cabeca vencedora ja sumiu (explodiu no caminho): resolucao direta
		if(hL)
			hL.in_beamclash = 0
			obj_list -= hL
			attack_list -= hL
			hL.loc = null
		cleanup()

	//o EMPURRAO: a cabeca vencedora avanca tile a tile ENGOLINDO o beam do perdedor
	//(a cabeca perdedora recua junto na frente dela) ate acertar o perdedor. O orbe de
	//choque viaja no ponto de contato e a tela continua tremendo -- e o visual de quem
	//esta perdendo que o user pediu (Budokai Tenkaichi / Sparking Zero).
	proc/push_phase(mob/W, mob/L, obj/attack/blast/hW, obj/attack/blast/hL)
		set waitfor = 0
		set background = 1
		//o rastro do beam perdedor congela e desarma (density 0 = nao da Bump): sera engolido tile a tile
		if(L)
			for(var/obj/attack/blast/S in attack_list)
				if(S && S != hW && S != hL && S.loc && S.proprietor == L)
					S.in_beamclash = 1
					walk(S, 0)
					S.density = 0
		if(hL && hL.loc)
			hL.in_beamclash = 1 //fica plantada (KHH/esfera nao re-andam) -- so recua pelo nosso passo
			hL.density = 0
			walk(hL, 0)
		if(orb) orb.maptext = null //disputa decidida: a barra some, o orbe vira a frente do empurrao
		hW.icon_state = "head"
		hW.distance = max(hW.distance, BCL_PUSH_MAX + 5) //alcance renovado: o empurrao nao morre por distancia no meio
		var/steps = 0
		while(hW && hW.loc && steps < BCL_PUSH_MAX)
			steps++
			sleep(BCL_PUSH_STEP)
			if(!hW || !hW.loc) break //acertou algo e explodiu no caminho
			var/turf/next = get_step(hW, hW.dir)
			if(!next || next.density) break //terreno fechou: encerra aqui
			//ENGOLE os segmentos do beam perdedor que estiverem no caminho
			for(var/obj/attack/blast/S in next)
				if(S != hW && S != hL && S.proprietor == L)
					obj_list -= S
					attack_list -= S
					S.loc = null
			//a cabeca perdedora recua um tile a frente (o beam dele sendo empurrado)
			if(hL && hL.loc)
				var/turf/back = get_step(next, hW.dir)
				if(back && !back.density) hL.loc = back
			//o perdedor esta no proximo tile? o Move falha no corpo denso -> Bump -> dano/KB de beam
			var/hitL = (L && L.loc && L.z == next.z && L.x == next.x && L.y == next.y)
			hW.Move(next)
			//orbe/tremor/fx acompanham o ponto de contato
			center = (hW && hW.loc) ? hW.loc : next
			if(orb)
				orb.loc = center
				var/matrix/mx = matrix()
				var/tension = 1.4 + rand(0, 4) / 10
				mx.Scale(tension, tension)
				animate(orb, transform = mx, time = BCL_PUSH_STEP)
			shake_tick()
			if(steps % 3 == 0)
				createShockwavemisc(center, 1)
				if(prob(50)) createDustmisc(center, 1)
			if(hitL) break //o ataque alcancou o perdedor
		//a cabeca perdedora que sobrou some
		if(hL && hL.loc)
			hL.in_beamclash = 0
			obj_list -= hL
			attack_list -= hL
			hL.loc = null
		//o beam vencedor retoma o voo normal (se parou colado no perdedor, continua moendo ele via Bump)
		if(hW && hW.loc)
			hW.in_beamclash = 0
			walk(hW, hW.dir, hW.beamspeed)
		cleanup()

	//empate no tempo maximo: os dois beams detonam no meio
	proc/draw()
		if(!running) return
		running = 0
		for(var/mob/P in view(BCL_SHAKE_RANGE + 3, center))
			if(P.client) to_chat(P, "<font color=#ffcc33><b>Os beams de [A ? A.name : "?"] e [B ? B.name : "?"] explodem em pe de igualdade!!</b>")
		createShockwavemisc(center, 5)
		createDustmisc(center, 3)
		if(A) A.emit_Sound('scouterexplode.ogg')
		if(B) B.emit_Sound('scouterexplode.ogg')
		if(headA)
			headA.in_beamclash = 0
			spawn headA.explode()
		if(headB)
			headB.in_beamclash = 0
			spawn headB.explode()
		for(var/mob/M in list(A, B))
			if(!M) continue
			M.beaming = 0
			M.bypass = 0
			M.beamprocrunning = 0
			M.beamisrunning = 0
			M.beamturndelay = 0
			M.turnlock = 0
			M.stopbeaming()
		cleanup()

	proc/cleanup()
		unshake()
		if(orb)
			var/obj/o = orb
			orb = null
			o.loc = null
		if(A)
			A.beamclash = null
			A.bcl_presses = 0
		if(B)
			B.beamclash = null
			B.bcl_presses = 0

// ---------------------------------------------------------------------------
// IA: contra-beam + canal de beam 100% src-based (o ShootBeam dos players
// depende de usr, que so existe na corrente de verbs do proprio jogador)
// ---------------------------------------------------------------------------
//ha um beam inimigo vindo na nossa direcao?
mob/proc/bcl_incoming_beam()
	for(var/obj/attack/blast/K in view(BCL_NPC_DETECT, src))
		if(!K.WaveAttack || !K.loc || K.in_beamclash) continue
		if(K.proprietor == src || !ismob(K.proprietor)) continue
		if(K.icon_state != "head" && K.icon_state != "struggle" && K.icon_state != "") continue //so a ponta do beam
		var/d2me = get_dir(K, src)
		if(d2me == K.dir || d2me == turn(K.dir, 45) || d2me == turn(K.dir, -45))
			return K
	return null

//dispara e canaliza um beam do NPC na direcao dada
mob/proc/npc_fire_beam(fdir)
	set waitfor = 0
	if(beaming || charging || KO || dead) return
	dir = fdir
	beaming = 1
	canmove = 0 //parado enquanto canaliza (o checkState pina o totalTime com !canmove)
	wavemult = 1
	beamspeed = 1
	maxdistance = 20
	if(!beammods) beammods = Ekioff*Ekiskill*log(10, max(kieffusionskill, 10))*log(10, max(beamskill, 10))
	if("Blast" in icon_states(icon)) flick("Blast", src)
	emit_Sound('kamehameha_fire.wav')
	spawn npc_beam_loop()

mob/proc/npc_beam_loop()
	set waitfor = 0
	set background = 1
	var/started = world.time
	var/cost = 2.5 * BaseDrain
	//numa DISPUTA (beamclash) o canal nao expira pelo tempo -- senao o NPC "desistiria" no meio do clash
	while(beaming && src && loc && !KO && !dead && !KB && Ki > cost && (beamclash || world.time - started < BCL_NPC_BEAM_TIME))
		Ki -= cost
		if(!(locate(/obj/attack/blast) in get_step(src, dir))) //mesmo gate "dontbeam" do ShootBeam
			var/obj/attack/blast/N = new /obj/attack/blast
			N.proprietorloc = loc
			N.icon = beamicon
			N.icon += rgb(blastR, blastG, blastB)
			N.animate_movement = 1
			N.BP = expressedBP * wavemult
			N.wavemultipl = wavemult
			N.dir = dir
			N.transform = dir_matrix[N.dir]
			N.mods = beammods
			N.basedamage = 0.25 * Ekioff * log(10, max(beamskill, 10))
			N.layer = MOB_LAYER + 2
			N.murderToggle = murderToggle
			N.rangemod = 1
			N.proprietor = src
			N.ownkey = name
			N.WaveAttack = 1
			N.beamspeed = beamspeed
			N.icon_state = ""
			N.distance = maxdistance
			N.maxdistance = maxdistance
			N.loc = loc
			N.density = 1
			N.avoidusr = 1
			step(N, N.dir)
		sleep(2)
	//fim do canal (venceu/perdeu a disputa, acabou o ki ou o tempo)
	beaming = 0
	stopbeaming()
	canmove = 1
