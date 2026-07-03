// ============================================================================
// GENKIDAMA / SPIRIT BOMB -- ensinada pelo Sr. Kaioh (karma 100%; SkyNPCs.dm)
//   * Carga: o personagem para no lugar com a ESFERA CRESCENDO em cima da
//     cabeca. Se o icone base tiver a animacao "2H Overhead Charge"
//     (NewPaleMale.dmi), ela e usada; senao o personagem fica parado.
//   * Arremesso: a esfera voa EM LINHA RETA atropelando tudo e todos no
//     caminho (nao explode ao acertar: ATRAVESSA causando dano), esmaga
//     terreno destrutivel e deixa um RASTRO DE CHAO DESTRUIDO (so terra).
//   * No fim da distancia (ou numa parede indestrutivel) ela DETONA em area.
//   * Colidir com um BEAM forca um BEAMCLASH (mesmo a Genkidama nao sendo
//     beam) -- integracao em BeamClash.dm via is_genkidama.
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define GK_KI_FRAC       0.5   // fracao do MaxKi consumida pela carga completa
#define GK_CHARGE_TICKS  40    // iteracoes da carga (x sleep(2) = ~8s)
#define GK_DISTANCE      28    // tiles percorridos antes de detonar
#define GK_STEP_DELAY    3     // ticks entre passos da esfera (maior = mais lenta/pesada)
#define GK_POWMULT       3     // multiplicador de poder (mods) da esfera
#define GK_BASEDMG       3     // dano-base da esfera (cada "atropelo")
#define GK_SCALE         2     // escala visual da esfera arremessada
#define GK_BOOM_RANGE    3     // raio (tiles) do dano da detonacao final
#define GK_DRAG_BP_RESIST 2    // alvo com expressedBP > (BP da esfera x isto) e forte demais pra ser ARRASTADO (so leva o dano)
#define GK_ICON          'Icons/Techniques/Ball - Spirit Bomb.dmi'

obj/attack/var/is_genkidama = 0 //marca a esfera p/ o BeamClash (beam vs Genkidama = disputa)
mob/var/tmp/genki_charging = 0

// ---------------------------------------------------------------------------
// skill (ensinada pelo Sr. Kaioh; nao compravel, nao esquecivel)
// ---------------------------------------------------------------------------
/datum/skill/ki/Genkidama
	skilltype = "Ki"
	name = "Genkidama"
	desc = "A Bomba Espiritual do Sr. Kaioh: reuna a energia de todos os seres vivos numa esfera colossal e arremesse-a, varrendo tudo no caminho."
	can_forget = FALSE
	common_sense = TRUE
	skillcost = 0
	enabled = 0 //nao aparece em arvore: so o Sr. Kaioh ensina

/datum/skill/ki/Genkidama/after_learn()
	assignverb(/mob/keyable/verb/Genkidama)
	to_chat(savant, "<font color=#66ccff>Voce aprendeu a <b>Genkidama</b>! (verb na aba Skills)</font>")

/datum/skill/ki/Genkidama/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Genkidama)

mob/keyable/verb/Genkidama()
	set category = "Skills"
	desc = "Reuna a energia dos seres vivos e arremesse a Bomba Espiritual"
	if(usr.genki_charging)
		to_chat(usr, "Voce ja esta reunindo energia!")
		return
	if(usr.KO || usr.dead || usr.charging || usr.beaming || usr.med || usr.train || !usr.canfight)
		to_chat(usr, "Voce nao pode reunir energia agora.")
		return
	if(usr.Ki < usr.MaxKi * GK_KI_FRAC)
		to_chat(usr, "Voce precisa de pelo menos [round(GK_KI_FRAC*100)]% do seu Ki para a Genkidama!")
		return
	spawn usr.genki_charge()

// ---------------------------------------------------------------------------
// carga: parado, esfera crescendo sobre a cabeca
// ---------------------------------------------------------------------------
mob/proc/genki_charge()
	set waitfor = 0
	if(genki_charging) return
	genki_charging = 1
	canmove = 0
	var/oldstate = icon_state
	//pose de carga: NewPaleMale tem a animacao "2H Overhead Charge"; os outros icones ficam parados
	var/haspose = ("2H Overhead Charge" in icon_states(icon))
	if(haspose) icon_state = "2H Overhead Charge"
	to_chat(view(src), "<font color=#66ccff><b>[src] ergue as maos para o ceu, reunindo a energia de todos os seres vivos!</b></font>")
	emit_Sound('kame_charge.wav')
	//a esfera sobre a cabeca (vis_contents: acompanha o mob; cresce com a carga)
	var/obj/genki_ball_fx/ball = new
	vis_contents += ball
	var/matrix/mx = matrix()
	mx.Scale(GK_SCALE, GK_SCALE)
	animate(ball, transform = mx, time = GK_CHARGE_TICKS * 2) //cresce ao longo da carga inteira
	var/drain = (MaxKi * GK_KI_FRAC) / GK_CHARGE_TICKS
	var/ok = 1
	for(var/i = 1 to GK_CHARGE_TICKS)
		sleep(2)
		if(!src || KO || dead || !loc || Ki < drain)
			ok = 0
			break
		Ki -= drain
		if(prob(20)) createShockwavemisc(loc, 1) //a pressao da energia agita o ar
	//fim da carga
	vis_contents -= ball
	if(ball) del(ball)
	if(haspose && icon_state == "2H Overhead Charge") icon_state = oldstate
	canmove = 1
	genki_charging = 0
	if(!ok || !src || KO || dead)
		if(src) to_chat(src, "<font color=#cc4444>A energia se dissipa... a Genkidama falhou.</font>")
		return
	genki_throw()

obj/genki_ball_fx //a esfera de carga sobre a cabeca
	icon = GK_ICON
	icon_state = ""
	pixel_y = 34
	density = 0
	mouse_opacity = 0
	layer = MOB_LAYER + 4

// ---------------------------------------------------------------------------
// arremesso + voo em linha reta
// ---------------------------------------------------------------------------
mob/proc/genki_throw()
	to_chat(view(src), "<font color=#66ccff><b>[src] ARREMESSA A GENKIDAMA!!</b></font>")
	emit_Sound('kamehameha_fire.wav')
	flick("Blast", src)
	var/obj/attack/blast/genkidama/G = new
	G.proprietor = src
	G.ownkey = displaykey
	G.BP = expressedBP
	G.mods = Ekioff * Ekiskill * log(10, max(kieffusionskill, 10)) * GK_POWMULT
	G.basedamage = GK_BASEDMG
	G.murderToggle = murderToggle
	G.dir = dir
	var/matrix/gm = matrix()
	gm.Scale(GK_SCALE, GK_SCALE)
	G.transform = gm
	G.loc = get_step(src, dir)
	if(!G.loc) G.loc = loc
	spawn G.genki_travel()

obj/attack/blast/genkidama
	icon = GK_ICON
	is_genkidama = 1
	piercer = 1        //atravessa: nao para no primeiro alvo
	density = 1
	avoidusr = 1
	layer = MOB_LAYER + 3
	var/traveled = 0
	var/list/dragged = list() //quem a esfera capturou: e ARRASTADO junto ate a detonacao
	New()
		..()
		spawn(1) if(src) icon_state = "" //o New() base seta "end" (estado de blast comum) que nao existe no .dmi da esfera

	//movimento proprio por loc direto (nao usa walk/Move: o Move de blast explode ao ter o passo bloqueado)
	proc/genki_travel()
		set waitfor = 0
		set background = 1
		while(src && loc && traveled < GK_DISTANCE)
			genki_hold_dragged() //os capturados ficam PRESOS na esfera (mesmo parada num BeamClash)
			if(in_beamclash) //plantada numa DISPUTA contra um beam: espera o BeamClash resolver
				sleep(5)
				continue
			var/turf/next = get_step(src, dir)
			if(!next) break //borda do mapa: detona
			//BEAMCLASH: a esfera alcancou a CABECA de um beam inimigo -> forca a disputa
			var/clashed = 0
			for(var/obj/attack/blast/K in next)
				if(K.WaveAttack && K.density && K.proprietor != proprietor && !K.in_beamclash && !in_beamclash)
					if(bcl_try_start(K, src)) //K deu "o Bump" logico; a esfera e o lado B
						clashed = 1
						break
			if(clashed) continue
			//terreno denso: esmaga se for destrutivel, senao detona aqui
			if(next.density)
				if(!next.isSpecial && !next.proprietor && next.Resistance <= BP)
					createDust(next, 1)
					next.Destroy()
				else
					break
			loc = next
			traveled++
			genki_hold_dragged() //arrasta os capturados junto com o passo
			//atropela quem entrar na frente (dano 1x) e CAPTURA: vai sendo arrastado ate a explosao
			for(var/mob/M in loc)
				if(M in dragged) continue //ja capturado: nao re-atropela a cada passo
				genki_hit(M)
				genki_catch(M)
			//RASTRO: o chao por onde passa vira terra destruida
			var/turf/T = loc
			if(T && !T.isSpecial && !T.proprietor && T.Resistance <= BP)
				if(prob(85)) T.Destroy()
				if(prob(20)) createDust(T, 1)
			for(var/turf/TA in orange(1, src)) //espalha um pouco pros lados
				if(!TA.isSpecial && !TA.proprietor && TA.Resistance <= BP && prob(30))
					TA.Destroy()
			if(prob(12)) emit_Sound('chargeaura.wav')
			sleep(GK_STEP_DELAY)
		if(src && loc) genki_detonate()

	//captura um alvo atropelado: ele passa a ser ARRASTADO pela esfera ate a detonacao
	proc/genki_catch(mob/M)
		if(!M || M == proprietor || M.dead || !M.loc) return
		if(M in dragged) return
		if(M.expressedBP > BP * GK_DRAG_BP_RESIST) //forte demais: aguenta firme no lugar (so leva o dano)
			to_chat(M, "<font color=#66ccff>Voce crava os pes no chao e resiste ao arrasto da GENKIDAMA!</font>")
			return
		dragged += M
		to_chat(M, "<font color=#66ccff><b>A GENKIDAMA te engole e ARRASTA junto com ela!!</b></font>")
		to_chat(view(src), "<font color=#66ccff>[M] e arrastado(a) pela Genkidama!!</font>")

	//mantem os capturados grudados na esfera (chamado a cada passo/espera do voo)
	proc/genki_hold_dragged()
		if(!dragged.len || !loc) return
		for(var/mob/M in dragged)
			if(!M || !M.loc || M.dead) //sumiu/morreu no caminho: solta
				dragged -= M
				continue
			if(M.loc != loc) M.loc = loc

	//dano de "atropelo" num mob (espelha o essencial do Bump de blast, sem explodir)
	proc/genki_hit(mob/M)
		if(!M || M == proprietor || !M.attackable || M.dead) return
		if(M.ki_absorb_stance && proprietor != M) //androide de absorcao: suga um NACO da esfera (ela continua)
			M.dnl_absorb_ki_attack(src)
			return
		if(istype(proprietor, /mob))
			M.lastDamager = proprietor
			M.refresh_combat_tag()
			proprietor.refresh_combat_tag()
			if(!M.isNPC && !M.KO) proprietor.Blast_Gain(3 * proprietor.fight_gain_mult(M), 1)
		var/dmg = DamageCalc(mods*6*globalKiDamage, (M.Ekidef**2*max(M.Etechnique,M.Ekiskill)), basedamage, maxdamage)
		if(dmg == 0) dmg += basedamage * 0.02
		dmg = ArmorCalc(dmg, M.Esuperkiarmor, FALSE)
		M.damage_armor(dmg)
		dmg /= log(4, max(M.kidefenseskill, 4))
		M.DamageLimb(M.ResistCheck(dmg,"[element]")*BPModulus(BP,M.expressedBP), null, murderToggle, 5)
		M.Add_Anger()
		spawn MiniStun(M)
		if(M.isNPC)
			var/mob/npc/mN = M
			if(mN.monster && !mN.AIRunning && istype(proprietor, /mob)) mN.foundTarget(proprietor)
		to_chat(M, "<font color=#66ccff>A GENKIDAMA passa por cima de voce!!</font>")

	//detonacao final: explosao em area + cratera (os ARRASTADOS estao no epicentro e comem tudo)
	proc/genki_detonate()
		if(!src || !loc) return
		var/turf/C = loc
		genki_hold_dragged() //garante os capturados no epicentro
		to_chat(view(9, C), "<font color=#66ccff><b>A GENKIDAMA DETONA!!!</b></font>")
		if(istype(proprietor, /mob)) proprietor.emit_Sound('scouterexplode.ogg')
		createShockwavemisc(C, 5)
		createDustmisc(C, 3)
		createCrater(C, 3)
		for(var/mob/M in view(GK_BOOM_RANGE, C))
			genki_hit(M)
		for(var/mob/M in dragged) //solta os arrastados (ja comeram a explosao acima, estao no centro)
			if(M && M.client) to_chat(M, "<font color=#66ccff>A explosao finalmente te solta...</font>")
		dragged.Cut()
		for(var/turf/T in view(2, C))
			if(!T.isSpecial && !T.proprietor && T.Resistance <= BP && prob(70))
				T.Destroy()
		obj_list -= src
		attack_list -= src
		loc = null
