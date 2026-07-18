// ============================================================================
// GOD OF DESTRUCTION -- conversao do titulo do jogo antigo do dono (2026-07-11)
//   * O TITULO e o rank God_Of_Destruction (RankAssign.dm) -- 1 portador por vez,
//     dado pelo admin (Give Rank) ou conquistado em DUELO FORMAL.
//   * Habilidades (versao unica, sem "paths"): sem envelhecer, respira no vacuo,
//     Hakai (agarrao executor), God's Temper (surto ao apanhar sem bloquear),
//     Destruction God's Fury (feixe amarelo quebra-guarda no torso), Power Flick
//     (peteleco), Energy Nullification (anula ataques de ki), Destroyer Sphere
//     (orbe roxo com Hakai no contato) e a transformacao FURY (72x, aura roxa).
//   * Perdeu o titulo = perde TUDO na hora (verbs removidos, Fury cai).
//   * TAREFAS automaticas: destruir um planeta procedural sorteado OU eliminar
//     um vilao marcado, com prazo -- falhar GOD_TASK_FAILS_MAX vezes = destituido.
//   * DUELO: desafio a cada 2 dias reais (desafiante precisa de God Ki tier 1+),
//     2 adiamentos por semana, o 3o = covardia = perde o titulo; 7 dias de
//     carencia apos ganhar; vitoria por nocaute/morte transfere o titulo.
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define GOD_FURY_MULT 72          // multiplicador da transformacao Fury
#define GOD_HAKAI_TORSO_PCT 15    // Hakai exige torso do alvo abaixo de 15% do maximo
#define GOD_HAKAI_BP_FRAC 0.75    // ...e alvo com BP expresso <= 75% do seu (25% mais fraco)
//GOD_HAKAI_REVIVE_MULT mora no 1A Defines.dm (SkyNPCs.dm compila antes deste arquivo)
#define GOD_TEMPER_HITS 10        // danos seguidos SEM bloquear para disparar o God's Temper
#define GOD_TEMPER_PCT 0.10       // +10% de off/def fisico no surto
#define GOD_TEMPER_TICKS 100      // duracao do surto (100 = 10s)
#define GOD_TEMPER_CD 300         // cooldown entre surtos (30s)
#define GOD_FURYBEAM_KI 40        // custo (x BaseDrain) do Destruction God's Fury
#define GOD_SPHERE_KI 60          // custo (x BaseDrain) da Destroyer Sphere
#define GOD_NULLIFY_CD 3000       // cooldown do Energy Nullification (3000 ds = 5 min REAIS via world.realtime)
#define GOD_NULLIFY_RANGE 8       // raio da anulacao
#define GOD_DUEL_INTERVAL 1728000 // 2 dias reais entre duelos (em ds de world.realtime)
#define GOD_DUEL_GRACE 6048000    // carencia de 7 dias reais apos ganhar o titulo
#define GOD_DUEL_POSTPONE_MAX 2   // adiamentos permitidos por janela semanal
#define GOD_DUEL_WEEK 6048000     // janela semanal dos adiamentos (7 dias reais)
// (o gate do desafiante e ter o God Ki DESPERTO -- os tiers de God Ki morreram no rework de maestria 2026-07-18)
#define GOD_DUEL_TIMEOUT 6000     // duracao maxima do duelo (10 min); estourou = o Deus retem o titulo
#define GOD_TASK_INTERVAL 1728000 // tarefa nova a cada 2 dias reais
#define GOD_TASK_DEADLINE 1728000 // prazo real para cumprir a tarefa
#define GOD_TASK_FAILS_MAX 3      // falhas acumuladas que destituem o Deus
#define GOD_TASK_VILLAIN_KARMA -50 // karma <= isto marca um jogador como "ameaca ao equilibrio"

// ---------------------------------------------------------------------------
// estado global (persistido no savefile GoDState)
// ---------------------------------------------------------------------------
var
	god_title_since = 0    // world.realtime de quando o portador atual assumiu (carencia)
	god_duel_last = 0      // realtime do ultimo duelo/adiamento (intervalo de 2 dias)
	god_postpones = 0      // adiamentos usados na janela semanal
	god_postpone_week = 0  // inicio da janela semanal
	god_duel_busy = 0      // duelo acontecendo AGORA (nao persiste de proposito: crash no meio = destrava)
	god_task_type = ""     // "" = sem tarefa | "planet" | "vilao"
	god_task_target = ""   // nome do planeta procedural OU assinatura do vilao
	god_task_tname = ""    // nome de exibicao do alvo
	god_task_deadline = 0  // realtime limite
	god_task_next = 0      // realtime da proxima tarefa
	god_task_fails = 0     // falhas acumuladas
	god_loop_on = 0        // latch do loop de tarefas

mob/var
	hakai_mark = 0 //vitima de Hakai: o proximo revive pago no Enma custa GOD_HAKAI_REVIVE_MULT x (limpo no ReviveMe)
mob/var/tmp
	god_temper_armed = 0   //1 so no portador do titulo: liga o hook barato do damage_m
	god_temper_hits = 0
	god_temper_on = 0
	god_temper_cd = 0
	god_temper_off = 0     //quanto foi somado (pra remover exato)
	god_temper_def = 0
	god_nullify_next = 0   //world.realtime do proximo Energy Nullification

proc/god_is_god(mob/M)
	return (M && M.signature && God_Of_Destruction == M.signature)

proc/god_holder() //mob ONLINE do portador (null se offline/sem portador)
	if(!God_Of_Destruction) return null
	for(var/mob/M in player_list)
		if(M.client && M.signature == God_Of_Destruction) return M
	return null

// ---------------------------------------------------------------------------
// ganhar / perder o titulo
// ---------------------------------------------------------------------------
proc/god_gain_title(mob/M, via)
	if(!M) return
	God_Of_Destruction = M.signature
	RankList[M.signature] = M.name
	god_title_since = world.realtime
	god_postpones = 0
	god_postpone_week = world.realtime
	god_task_type = ""
	god_task_fails = 0
	god_task_next = world.realtime + GOD_TASK_INTERVAL
	M.Rank_Verb_Assign()
	M.god_apply_powers()
	//PATHS (UltraEgo.dm): sem path = o titulo desperta o Power of Destruction; path do Instinto = kit
	//emprestado a 25% (verbs no god_apply_powers); path da Destruicao = kit inteiro amplificado em 25%
	if(!M.ue_learned && !M.ui_learned)
		M.ue_learned = 1
		M.ue_give_verbs()
		to_chat(M, "<font color=#e07a9a><b>O Power of Destruction desperta em voce.</b> (verbs na aba Skills)")
	else if(M.ui_learned && !M.ue_learned)
		to_chat(M, "<font color=#c060ff><b>Seu Instinto agora canaliza a Destruicao:</b> voce ganha a Aura of Destruction e a Hakai Infusion a [round(GOD_PATH_BORROW * 100)]% de eficiencia, movidas pela sua PRECISAO (verbs na aba Skills, enquanto portar o titulo).")
	else if(M.ue_learned)
		to_chat(M, "<font color=#c060ff><b>O trono reconhece seu caminho:</b> todas as habilidades do Power of Destruction sao AMPLIFICADAS em [round(GOD_PATH_BOOST * 100)]% enquanto portar o titulo.")
	god_state_save()
	bev_announce("[M.name] [via ? via : "foi coroado(a)"] GOD OF DESTRUCTION! Que os desequilibrados temam.")
	to_chat(M, "<font color=#c060ff><b>Voce agora e um GOD OF DESTRUCTION.</b> Mantenha o equilibrio do universo: cumpra as tarefas (verb GoD Status) ou sera destituido. Voce nao envelhece e respira no vacuo enquanto portar o titulo.")

proc/god_lose_title(reason)
	var/mob/M = god_holder()
	var/oldname = (God_Of_Destruction && RankList[God_Of_Destruction]) ? RankList[God_Of_Destruction] : "O Deus"
	God_Of_Destruction = null
	god_task_type = ""
	god_state_save()
	if(M)
		M.god_strip_powers()
		to_chat(M, "<font color=#c060ff><b>Voce foi DESTITUIDO do titulo de God of Destruction.</b> ([reason]) Todo o poder do cargo se esvai do seu corpo.")
	bev_announce("[oldname] perdeu o titulo de GOD OF DESTRUCTION! ([reason])")

//aplica os poderes passivos + verbs do titulo (chamado ao ganhar e no login)
mob/proc/god_apply_powers()
	god_temper_armed = 1
	spacebreather = 1 //respira no vacuo
	verbs += /mob/keyable/verb/God_Hakai
	verbs += /mob/keyable/verb/God_Power_Flick
	verbs += /mob/keyable/verb/God_Fury_Beam
	verbs += /mob/keyable/verb/God_Destroyer_Sphere
	verbs += /mob/keyable/verb/God_Energy_Nullification
	verbs += /mob/keyable/verb/God_Fury
	Keyableverbs += /mob/keyable/verb/God_Hakai
	Keyableverbs += /mob/keyable/verb/God_Power_Flick
	Keyableverbs += /mob/keyable/verb/God_Fury_Beam
	Keyableverbs += /mob/keyable/verb/God_Destroyer_Sphere
	Keyableverbs += /mob/keyable/verb/God_Energy_Nullification
	Keyableverbs += /mob/keyable/verb/God_Fury
	if(ui_learned && !ue_learned) //path do INSTINTO: o titulo EMPRESTA o kit da destruicao (25% -- UltraEgo.dm)
		verbs += /mob/keyable/verb/Power_of_Destruction
		verbs += /mob/keyable/verb/Hakai_Infusion
		Keyableverbs += /mob/keyable/verb/Power_of_Destruction
		Keyableverbs += /mob/keyable/verb/Hakai_Infusion

//"perde todas as habilidades ao perder o titulo" -- remocao imediata e total
mob/proc/god_strip_powers()
	god_temper_armed = 0
	if(genome) spacebreather = round(genome.misc_stats["Space Breath"]) //volta ao da raca
	if(isBuffed(/obj/buff/GodFury)) stopbuff(/obj/buff/GodFury)
	if(!ue_learned) //o kit EMPRESTADO da destruicao morre com o titulo (quem trilha o path fica com o seu)
		ue_active = 0
		ue_infuse_until = 0
		ue_ego_mult = 1
		removeOverlay(/obj/overlay/effects/ue_aura_pas)
		verbs -= /mob/keyable/verb/Power_of_Destruction
		verbs -= /mob/keyable/verb/Hakai_Infusion
		Keyableverbs -= /mob/keyable/verb/Power_of_Destruction
		Keyableverbs -= /mob/keyable/verb/Hakai_Infusion
	verbs -= /mob/keyable/verb/God_Hakai
	verbs -= /mob/keyable/verb/God_Power_Flick
	verbs -= /mob/keyable/verb/God_Fury_Beam
	verbs -= /mob/keyable/verb/God_Destroyer_Sphere
	verbs -= /mob/keyable/verb/God_Energy_Nullification
	verbs -= /mob/keyable/verb/God_Fury
	Keyableverbs -= /mob/keyable/verb/God_Hakai
	Keyableverbs -= /mob/keyable/verb/God_Power_Flick
	Keyableverbs -= /mob/keyable/verb/God_Fury_Beam
	Keyableverbs -= /mob/keyable/verb/God_Destroyer_Sphere
	Keyableverbs -= /mob/keyable/verb/God_Energy_Nullification
	Keyableverbs -= /mob/keyable/verb/God_Fury

//login: re-arma poderes do portador (verbs nao persistem) / garante que ex-portador nao tem nada
mob/proc/god_login_check()
	if(god_is_god(src))
		god_apply_powers()
		if(god_task_type) to_chat(src, "<font color=#c060ff><b>GoD:</b> tarefa pendente -- [god_task_desc()]. Prazo: [god_time_left(god_task_deadline)].")
	else if(god_temper_armed || (/mob/keyable/verb/God_Hakai in verbs))
		god_strip_powers()

proc/god_time_left(deadline)
	var/left = max(deadline - world.realtime, 0)
	return "[round(left / 36000)]h[round((left % 36000) / 600)]min"

// ---------------------------------------------------------------------------
// HAKAI (nucleo compartilhado: verb de agarrao + Destroyer Sphere)
// ---------------------------------------------------------------------------
mob/proc/god_hakai_try(mob/M, via)
	if(!god_is_god(src)) return 0
	if(!M || M == src || M.dead || !M.attackable) return 0
	//criterio 1: torso abaixo de GOD_HAKAI_TORSO_PCT% do maximo
	var/datum/Body/T = null
	for(var/datum/Body/S in M.body)
		if(istype(S, /datum/Body/Torso)) { T = S; break }
	if(!T || T.maxhealth <= 0) return 0
	if(T.health / T.maxhealth > GOD_HAKAI_TORSO_PCT / 100) return 0
	//criterio 2: pelo menos 25% mais fraco que voce AGORA
	if(M.expressedBP > expressedBP * GOD_HAKAI_BP_FRAC) return 0
	god_hakai_execute(M, via)
	return 1

mob/proc/god_hakai_execute(mob/M, via)
	to_chat(view(M), "<font color=#c060ff><b>[src]: HAKAI!</b> O corpo de [M] se desfaz em particulas de luz violeta...")
	createShockwavemisc(M.loc, 2)
	createDustmisc(M.loc, 2)
	emit_Sound('scouterexplode.ogg')
	spawn Quake()
	if(M.client)
		M.hakai_mark = 1 //o Enma cobra o dobro pra trazer de volta o que um Deus apagou
		M.lastDamager = src
		spawn M.Death()
	else if(istype(M, /mob/npc))
		var/mob/npc/N = M
		spawn N.mobDeath()
	else
		spawn del(M)

//HAKAI (verb): movimento de AGARRAO -- executa quem voce esta agarrando (ou o alvo colado a frente)
mob/keyable/verb/God_Hakai()
	set category = "Skills"
	if(!god_is_god(usr)) return
	var/mob/M = usr.grabbee
	if(!M) for(var/mob/P in get_step(usr, usr.dir)) { M = P; break }
	if(!M)
		to_chat(usr, "<font color=#c060ff>Agarre (ou encoste em) sua vitima primeiro.")
		return
	if(!usr.god_hakai_try(M, "Hakai"))
		to_chat(usr, "<font color=#c060ff>[M] ainda resiste a Destruicao: o torso precisa estar abaixo de [GOD_HAKAI_TORSO_PCT]% e o poder ao menos 25% abaixo do seu.")

//POWER FLICK (verb): agarra e peteleca pra longe (2x o dano de um golpe pesado sem carga)
mob/keyable/verb/God_Power_Flick()
	set category = "Skills"
	if(!god_is_god(usr)) return
	var/mob/M = usr.grabbee
	if(!M)
		to_chat(usr, "<font color=#c060ff>Voce precisa estar AGARRANDO alguem para o peteleco.")
		return
	//solta o agarrao e aplica o peteleco
	usr.grabbee = null
	M.grabber = null
	M.grabParalysis = 0
	usr.is_choking = 0
	usr.attacking = 0
	var/dmg = usr.NormDamageCalc(M) * 2 //2x um pesado sem carga
	to_chat(view(M), "<font color=#c060ff>[usr] da um PETELECO em [M] -- o impacto atravessa o corpo inteiro!")
	emit_Sound('scouterexplode.ogg')
	damage_m(M, dmg, "torso", usr.murderToggle, 2)
	M.kbdir = usr.dir
	M.kbpow = usr.expressedBP
	M.kbdur = 9
	M.AddEffect(/effect/knockback)

// ---------------------------------------------------------------------------
// DESTRUCTION GOD'S FURY -- feixe amarelo de dedo: carga 3x, quebra a guarda,
// acerta o TORSO direto
// ---------------------------------------------------------------------------
obj/attack/blast/godfury
	deflectable = 0
	OnSucCollWMob(mob/M)
		if(M.blocking)
			M.blocking = 0 //atravessa e DESLIGA o bloqueio
			to_chat(M, "<font color=#ffd700>O feixe do Deus atravessa sua guarda como se ela nao existisse!")

mob/keyable/verb/God_Fury_Beam()
	set category = "Skills"
	set name = "Destruction God's Fury"
	if(!god_is_god(usr)) return
	if(usr.KO || usr.med || usr.train || usr.blasting) return
	if(usr.Ki < GOD_FURYBEAM_KI * usr.BaseDrain)
		to_chat(usr, "Voce precisa de [GOD_FURYBEAM_KI * usr.BaseDrain] de Ki.")
		return
	usr.blasting = 1
	usr.Ki -= GOD_FURYBEAM_KI * usr.BaseDrain
	flick("Blast", usr)
	sleep(max(round(usr.Eactspeed / 3), 1)) //"carga" 3x mais rapida que o normal
	var/obj/attack/blast/godfury/A = new
	usr.emit_Sound('fire_kiblast.wav')
	A.icon = '12.dmi'
	A.icon += rgb(255, 215, 0) //amarelo do Deus
	A.loc = locate(usr.x, usr.y, usr.z)
	A.density = 1
	A.basedamage = 1.5
	A.BP = usr.expressedBP
	A.mods = usr.Ekioff * usr.Ekiskill
	A.selectzone = "torso" //direto no torso, sem sorteio de membro
	A.murderToggle = usr.murderToggle
	A.proprietor = usr
	A.ownkey = usr.displaykey
	A.dir = usr.dir
	spawn A.Burnout()
	step(A, A.dir)
	walk(A, A.dir, 2)
	usr.Blast_Gain()
	usr.blasting = 0

// ---------------------------------------------------------------------------
// DESTROYER SPHERE -- orbe roxo com a energia da Destruicao: carga 3x e HAKAI
// no contato (mesmos criterios do agarrao)
// ---------------------------------------------------------------------------
obj/attack/blast/goddestroyer
	deflectable = 0
	OnSucCollWMob(mob/M)
		var/mob/P = proprietor
		if(istype(P) && P.god_hakai_try(M, "Destroyer Sphere"))
			return //alvo apagado: o dano normal do impacto e detalhe

mob/keyable/verb/God_Destroyer_Sphere()
	set category = "Skills"
	set name = "Destroyer Sphere"
	if(!god_is_god(usr)) return
	if(usr.KO || usr.med || usr.train || usr.blasting) return
	if(usr.Ki < GOD_SPHERE_KI * usr.BaseDrain)
		to_chat(usr, "Voce precisa de [GOD_SPHERE_KI * usr.BaseDrain] de Ki.")
		return
	usr.blasting = 1
	usr.Ki -= GOD_SPHERE_KI * usr.BaseDrain
	flick("Blast", usr)
	to_chat(view(usr), "<font color=#c060ff>[usr] condensa uma esfera de pura DESTRUICAO...")
	sleep(max(round(usr.Eactspeed / 3), 1)) //carga 3x mais rapida
	var/obj/attack/blast/goddestroyer/A = new
	usr.emit_Sound('kamehameha_fire.wav')
	A.icon = '12.dmi'
	A.icon += rgb(160, 60, 220) //roxo da Destruicao
	A.loc = locate(usr.x, usr.y, usr.z)
	A.density = 1
	A.basedamage = 2
	A.BP = usr.expressedBP
	A.mods = usr.Ekioff * usr.Ekiskill
	A.murderToggle = usr.murderToggle
	A.proprietor = usr
	A.ownkey = usr.displaykey
	A.dir = usr.dir
	spawn A.Burnout()
	step(A, A.dir)
	walk(A, A.dir, 2)
	usr.Blast_Gain()
	usr.blasting = 0

// ---------------------------------------------------------------------------
// ENERGY NULLIFICATION -- apaga ataques de ki mais fracos que voce (CD 5 min)
// ---------------------------------------------------------------------------
mob/keyable/verb/God_Energy_Nullification()
	set category = "Skills"
	set name = "Energy Nullification"
	if(!god_is_god(usr)) return
	if(world.realtime < usr.god_nullify_next)
		to_chat(usr, "<font color=#c060ff>A anulacao retorna em [god_time_left(usr.god_nullify_next)].")
		return
	var/n = 0
	for(var/obj/attack/A in view(GOD_NULLIFY_RANGE, usr))
		if(A.proprietor == usr) continue
		if(A.BP < usr.expressedBP) //"contem menos energia que voce possui agora"
			obj_list -= A
			attack_list -= A
			A.loc = null
			n++
	if(n)
		usr.god_nullify_next = world.realtime + GOD_NULLIFY_CD
		createShockwavemisc(usr.loc, 3)
		usr.emit_Sound('scouterexplode.ogg')
		to_chat(view(usr), "<font color=#c060ff>[usr] ergue a mao -- [n] ataque\s de ki simplesmente DEIXAM DE EXISTIR.")
	else
		to_chat(usr, "<font color=#c060ff>Nenhum ataque anulavel por perto (so consome o poder se anular algo).")

// ---------------------------------------------------------------------------
// GOD'S TEMPER -- 10 danos seguidos sem bloquear: surto de +10% off/def por 10s
// (hook barato no damage_m: so roda pra quem tem god_temper_armed)
// ---------------------------------------------------------------------------
mob/proc/god_temper_hit()
	if(blocking) { god_temper_hits = 0; return }
	god_temper_hits++
	if(god_temper_hits < GOD_TEMPER_HITS || god_temper_on || world.time < god_temper_cd) return
	god_temper_hits = 0
	god_temper_on = 1
	god_temper_cd = world.time + GOD_TEMPER_CD
	god_temper_off = Ephysoff * GOD_TEMPER_PCT
	god_temper_def = Ephysdef * GOD_TEMPER_PCT
	Tphysoff += god_temper_off
	Tphysdef += god_temper_def
	updateOverlay(/obj/overlay/effects/god_fury_aura)
	to_chat(view(src), "<font color=#c060ff><b>A ira do Deus transborda!</b> [src] pulsa com poder redobrado!")
	spawn(GOD_TEMPER_TICKS)
		if(src)
			Tphysoff -= god_temper_off
			Tphysdef -= god_temper_def
			god_temper_off = 0
			god_temper_def = 0
			god_temper_on = 0
			if(!isBuffed(/obj/buff/GodFury)) removeOverlay(/obj/overlay/effects/god_fury_aura)

// ---------------------------------------------------------------------------
// FURY -- a transformacao do Deus (72x), aura roxa justa e continua
// ---------------------------------------------------------------------------
obj/overlay/effects/god_fury_aura //a aura "colada no corpo" ('god - grey.dmi' tintado de roxo)
	icon = 'god - grey.dmi'
	color = rgb(190, 80, 255)
	temporary = 0

obj/buff/GodFury
	name = "Fury"
	slot = sFORM
	Buff()
		..()
		container.formsBuff = GOD_FURY_MULT //formsBuff: livre de conflito (transBuff e das formas raciais)
		container.updateOverlay(/obj/overlay/effects/god_fury_aura)
		container.emit_Sound('1aura.wav')
		to_chat(view(container), "<font color=#c060ff><b>[container] desperta a FURIA da Destruicao!</b> Uma aura violeta densa envolve seu corpo!")
	Loop()
		if(!god_is_god(container)) DeBuff() //perdeu o titulo transformado: a forma MORRE na hora
		..()
	DeBuff()
		container.formsBuff = 1
		container.removeOverlay(/obj/overlay/effects/god_fury_aura)
		to_chat(container, "<font color=#c060ff>A Furia se recolhe.")
		..()

mob/keyable/verb/God_Fury()
	set category = "Skills"
	set name = "Fury"
	if(!god_is_god(usr)) return
	if(usr.ue_form || usr.ui_form) //Fury nao empilha com Ultra Ego/Instinct (todos escrevem formsBuff)
		to_chat(usr, "<font color=#c060ff>Recolha a outra forma antes de despertar a Furia.")
		return
	if(usr.isBuffed(/obj/buff/GodFury)) usr.stopbuff(/obj/buff/GodFury)
	else usr.startbuff(/obj/buff/GodFury, 'SSJIcon.dmi')

// ---------------------------------------------------------------------------
// DUELO FORMAL pelo titulo
// ---------------------------------------------------------------------------
mob/verb/Desafiar_God_of_Destruction()
	set category = "Other"
	set name = "Desafiar God of Destruction"
	if(!God_Of_Destruction)
		to_chat(usr, "Nao ha God of Destruction para desafiar.")
		return
	if(god_is_god(usr))
		to_chat(usr, "Voce E o God of Destruction.")
		return
	if(usr.dead || usr.KO) return
	if(!usr.godki || !usr.godki.awakened)
		to_chat(usr, "<font color=#c060ff>So quem despertou o God Ki pode desafiar um Deus.")
		return
	if(god_duel_busy)
		to_chat(usr, "Um duelo pelo titulo ja esta acontecendo.")
		return
	if(world.realtime - god_title_since < GOD_DUEL_GRACE)
		to_chat(usr, "<font color=#c060ff>O novo Deus esta em periodo de carencia. Desafios abrem em [god_time_left(god_title_since + GOD_DUEL_GRACE)].")
		return
	if(world.realtime - god_duel_last < GOD_DUEL_INTERVAL)
		to_chat(usr, "<font color=#c060ff>O trono so aceita desafios a cada 2 dias. Proximo em [god_time_left(god_duel_last + GOD_DUEL_INTERVAL)].")
		return
	var/mob/G = god_holder()
	if(!G)
		to_chat(usr, "<font color=#c060ff>O Deus esta ausente do plano fisico (offline). Tente quando ele estiver presente.")
		return
	god_duel_busy = 1
	to_chat(usr, "Seu desafio foi entregue. Aguarde a resposta do Deus...")
	//janela semanal dos adiamentos
	if(world.realtime - god_postpone_week > GOD_DUEL_WEEK)
		god_postpone_week = world.realtime
		god_postpones = 0
	var/resp = alert(G, "[usr.name] desafia voce FORMALMENTE pelo titulo de God of Destruction! Regras: sem fusao; apenas armas e roupas. Adiar pela 3a vez na semana e COVARDIA (perde o titulo). Adiamentos usados: [god_postpones]/[GOD_DUEL_POSTPONE_MAX].", "DESAFIO PELO TITULO", "Aceitar agora", "Adiar")
	if(!god_is_god(G) || usr.dead) //algo mudou durante o alert
		god_duel_busy = 0
		return
	if(resp == "Adiar")
		god_postpones++
		god_duel_last = world.realtime //adiamento consome o desafio da janela de 2 dias
		if(god_postpones > GOD_DUEL_POSTPONE_MAX)
			god_duel_busy = 0
			god_lose_title("covardia: 3o adiamento na semana")
			to_chat(usr, "<font color=#c060ff>O Deus fugiu do seu desafio pela 3a vez -- e caiu em desgraca. O trono esta VAGO.")
			god_state_save()
			return
		god_state_save()
		bev_announce("O GOD OF DESTRUCTION adiou o desafio de [usr.name]. ([god_postpones]/[GOD_DUEL_POSTPONE_MAX] adiamentos na semana)")
		god_duel_busy = 0
		return
	god_duel_run(G, usr)

proc/god_duel_run(mob/G, mob/C)
	set waitfor = 0
	set background = 1
	bev_announce("DUELO PELO TITULO DE GOD OF DESTRUCTION: [G.name] (Deus) VS [C.name] (desafiante)! Sem fusao; apenas armas e roupas. Nocaute decide!")
	//arena do torneio da Terra (reuso da geometria TRN_*)
	var/turf/spotA = locate(round((TRN_ARENA_X1 + TRN_ARENA_X2) / 2) - 4, round((TRN_ARENA_Y1 + TRN_ARENA_Y2) / 2), TRN_ARENA_Z)
	var/turf/spotB = locate(round((TRN_ARENA_X1 + TRN_ARENA_X2) / 2) + 4, round((TRN_ARENA_Y1 + TRN_ARENA_Y2) / 2), TRN_ARENA_Z)
	trn_heal(G)
	trn_heal(C)
	G.loc = spotA
	C.loc = spotB
	G.dir = EAST
	C.dir = WEST
	for(var/c = 5, c >= 1, c--)
		to_chat(G, "<font color=#c060ff><b>[c]...</b>")
		to_chat(C, "<font color=#c060ff><b>[c]...</b>")
		sleep(10)
	to_chat(G, "<font color=#c060ff><b>COMECEM!</b>")
	to_chat(C, "<font color=#c060ff><b>COMECEM!</b>")
	var/mob/winner = null
	var/t = 0
	while(!winner && t < GOD_DUEL_TIMEOUT)
		sleep(5)
		t += 5
		if(!G || !G.client || G.dead) { winner = C; break }
		if(!C || !C.client || C.dead) { winner = G; break }
		if(G.KO && C.KO) { winner = (G.HP >= C.HP) ? G : C; break }
		if(G.KO) { winner = C; break }
		if(C.KO) { winner = G; break }
	if(!winner) winner = G //tempo esgotado: o desafiante falhou em derrubar o Deus
	god_duel_last = world.realtime
	god_duel_busy = 0
	if(winner == C && C && C.client)
		bev_announce("[C.name] DERROTOU o God of Destruction em duelo formal!!")
		var/mob/oldG = god_holder()
		if(oldG) oldG.god_strip_powers()
		God_Of_Destruction = null
		god_gain_title(C, "conquistou em DUELO o titulo de")
	else
		bev_announce("O GOD OF DESTRUCTION defendeu seu titulo contra [C ? C.name : "o desafiante"]!")
		god_state_save()
	//pos-duelo: cura os dois e devolve ao mundo (spawn racial)
	if(G && G.client) { trn_heal(G); G.GotoPlanet(G.effective_spawn_planet(), 1) }
	if(C && C.client) { trn_heal(C); C.GotoPlanet(C.effective_spawn_planet(), 1) }

// ---------------------------------------------------------------------------
// TAREFAS -- o Deus mantem o equilibrio ou perde o trono
// ---------------------------------------------------------------------------
proc/god_task_desc()
	if(god_task_type == "planet") return "DESTRUIR o planeta [god_task_tname]"
	if(god_task_type == "vilao") return "ELIMINAR a ameaca [god_task_tname]"
	return "nenhuma"

mob/verb/GoD_Status()
	set category = "Other"
	set name = "GoD Status"
	var/holder = (God_Of_Destruction && RankList[God_Of_Destruction]) ? RankList[God_Of_Destruction] : "trono VAGO"
	var/txt = "<font color=#c060ff><b>GOD OF DESTRUCTION:</b> [holder]<br>"
	if(God_Of_Destruction)
		txt += "Tarefa: [god_task_desc()][god_task_type ? " (prazo: [god_time_left(god_task_deadline)])" : ""]<br>"
		txt += "Falhas acumuladas: [god_task_fails]/[GOD_TASK_FAILS_MAX]<br>"
		txt += "Adiamentos na semana: [god_postpones]/[GOD_DUEL_POSTPONE_MAX]<br>"
		var/gr = (god_title_since + GOD_DUEL_GRACE) - world.realtime
		var/iv = (god_duel_last + GOD_DUEL_INTERVAL) - world.realtime
		if(gr > 0) txt += "Carencia de desafios: [god_time_left(god_title_since + GOD_DUEL_GRACE)]<br>"
		else if(iv > 0) txt += "Proximo desafio possivel em: [god_time_left(god_duel_last + GOD_DUEL_INTERVAL)]<br>"
		else txt += "<b>O trono ACEITA desafios agora</b> (exige God Ki desperto).<br>"
	to_chat(usr, txt)

proc/god_task_loop()
	set waitfor = 0
	set background = 1
	if(god_loop_on) return
	god_loop_on = 1
	while(1)
		sleep(600) //1 min real
		if(!God_Of_Destruction) continue
		if(!god_task_type)
			if(world.realtime >= god_task_next) god_task_new()
			continue
		//tarefa ativa: cumprida?
		if(god_task_type == "planet")
			var/datum/pspace_planet/D = pspace_planets[god_task_target]
			var/done = 0
			if(!D) done = 1 //planeta sumiu do registro: considera resolvido
			else if(D.pobj && D.pobj.isDestroyed) done = 1
			else if(god_task_target in PlanetDisableList) done = 1
			if(done)
				god_task_complete()
				continue
		else if(god_task_type == "vilao")
			var/found = 0
			for(var/mob/M in player_list)
				if(M.signature == god_task_target)
					found = 1
					if(M.dead) god_task_complete()
					break
			if(!found) //vilao deslogou: tarefa se anula sem punir o Deus
				god_task_type = ""
				god_task_next = world.realtime + 6000 //re-sorteia em ~10min
				var/mob/G0 = god_holder()
				if(G0) to_chat(G0, "<font color=#c060ff><b>GoD:</b> a ameaca fugiu do plano fisico. Nova tarefa em breve.")
				god_state_save()
			continue
		//prazo estourou?
		if(world.realtime >= god_task_deadline)
			god_task_fails++
			var/mob/G = god_holder()
			if(G) to_chat(G, "<font color=#c060ff><b>GoD: TAREFA FALHADA</b> ([god_task_desc()]). Falhas: [god_task_fails]/[GOD_TASK_FAILS_MAX].")
			bev_announce("O God of Destruction FALHOU em manter o equilibrio... ([god_task_fails]/[GOD_TASK_FAILS_MAX])")
			god_task_type = ""
			god_task_next = world.realtime + GOD_TASK_INTERVAL
			if(god_task_fails >= GOD_TASK_FAILS_MAX)
				god_lose_title("negligencia: [GOD_TASK_FAILS_MAX] tarefas falhadas")
			god_state_save()

proc/god_task_new()
	//1) vilao online marcado (isVillain ou karma muito negativo)
	var/list/vils = list()
	for(var/mob/M in player_list)
		if(!M.client || M.dead) continue
		if(M.signature == God_Of_Destruction) continue
		if(M.isVillain || M.karma <= GOD_TASK_VILLAIN_KARMA) vils += M
	if(vils.len)
		var/mob/V = pick(vils)
		god_task_type = "vilao"
		god_task_target = V.signature
		god_task_tname = V.name
	else
		//2) planeta procedural vivo sorteado
		var/list/cands = list()
		for(var/pn in pspace_planets)
			var/datum/pspace_planet/D = pspace_planets[pn]
			if(D && D.pobj && !D.pobj.isDestroyed && !(pn in PlanetDisableList)) cands += pn
		if(!cands.len)
			god_task_next = world.realtime + 6000 //nada elegivel: tenta em ~10min
			return
		god_task_target = pick(cands)
		god_task_tname = god_task_target
		god_task_type = "planet"
	god_task_deadline = world.realtime + GOD_TASK_DEADLINE
	god_state_save()
	var/mob/G = god_holder()
	if(G) to_chat(G, "<font color=#c060ff><b>GoD: NOVA TAREFA</b> -- [god_task_desc()]. Prazo: [god_time_left(god_task_deadline)]. Falhar corroi o trono.")

proc/god_task_complete()
	var/mob/G = god_holder()
	if(G) to_chat(G, "<font color=#c060ff><b>GoD: TAREFA CUMPRIDA</b> ([god_task_desc()]). O equilibrio agradece.")
	bev_announce("O God of Destruction manteve o equilibrio do universo. ([god_task_desc()])")
	god_task_type = ""
	god_task_fails = max(god_task_fails - 1, 0) //bom servico abate uma falha antiga
	god_task_next = world.realtime + GOD_TASK_INTERVAL
	god_state_save()

// ---------------------------------------------------------------------------
// persistencia do estado
// ---------------------------------------------------------------------------
proc/god_state_save()
	var/savefile/S = new("GoDState")
	S["since"] << god_title_since
	S["dlast"] << god_duel_last
	S["postp"] << god_postpones
	S["pweek"] << god_postpone_week
	S["ttype"] << god_task_type
	S["ttarg"] << god_task_target
	S["tname"] << god_task_tname
	S["tdead"] << god_task_deadline
	S["tnext"] << god_task_next
	S["tfail"] << god_task_fails

proc/god_state_load()
	if(fexists("GoDState"))
		var/savefile/S = new("GoDState")
		S["since"] >> god_title_since
		S["dlast"] >> god_duel_last
		S["postp"] >> god_postpones
		S["pweek"] >> god_postpone_week
		S["ttype"] >> god_task_type
		S["ttarg"] >> god_task_target
		S["tname"] >> god_task_tname
		S["tdead"] >> god_task_deadline
		S["tnext"] >> god_task_next
		S["tfail"] >> god_task_fails
	if(isnull(god_task_type)) god_task_type = ""
	spawn(50) god_task_loop()
