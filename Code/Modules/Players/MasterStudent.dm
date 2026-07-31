// ============================================================================
// MESTRE E ALUNOS -- discipulado entre jogadores (2026-07-31)
//   * Verb "Convidar Aluno" (aba Learning): de frente para outro jogador, com
//     no minimo MST_BP_RATIO vezes o BP BASE dele, voce o convida. Um aluno tem
//     UM mestre; um mestre tem ate MST_MAX_STUDENTS alunos.
//   * Aba "Alunos": quem e seu mestre, quem sao seus alunos, e os botoes de
//     dispensar / abandonar (molde da aba Known People).
//   * TREINAR COM O MESTRE RENDE MAIS: o bonus por lutar com alguem mais forte
//     (fight_gain_mult, combatgains.dm) tem teto 2x no geral; contra o proprio
//     mestre o teto sobe para MST_GAIN_CAP e a escala e LINEAR pela razao dos
//     BPs BASE (mestre 3x mais forte = 3x de ganho), com piso MST_GAIN_FLOOR.
//   * DESPERTAR ASSISTIDO: o mestre ajuda o aluno a alcancar a PRIMEIRA vez de
//     uma forma, cortando os requisitos pessoais dele pela metade (MST_HALF).
//     So vale para forma que o aluno JA VIU outro jogador usar (registro de
//     testemunha) ou que o MESTRE possui, sendo da mesma raca/linhagem.
//     Forma de RAIVA: o mestre escreve uma provocacao (sai como fala) e o aluno
//     decide se aquilo o tirou do serio -- se sim, a raiva sobe e ele desperta.
//     Forma sem raiva: o mestre escreve um ENSINAMENTO e o aluno diz se
//     entendeu. Sem os requisitos (ja pela metade), a tentativa FALHA em cena.
//   * Estado no savefile proprio "MASTER" (assoc ALUNO -> MESTRE), sempre por
//     SIGNATURE. O registro de testemunhas mora no proprio mob (lista de
//     strings, entra no save sozinha).
// TODOS os numeros de ajuste ficam neste bloco (os compartilhados com o
// combatgains.dm estao no 1A Defines.dm).
// ============================================================================
#define MST_MAX_STUDENTS 5   // alunos simultaneos por mestre
#define MST_RAGE_MINUTES 2   // duracao (min reais) da raiva acesa pela provocacao do mestre
#define MST_TEACH_COOLDOWN 3000 // ticks (5 min) entre tentativas de despertar no MESMO aluno

var/list/mst_list = list()  //assoc: signature do ALUNO -> signature do MESTRE
var/list/mst_names = list() //assoc: signature -> nome (so exibicao; sobrevive ao logout do dono)

mob/var
	list/mst_seen_forms = null //assoc: tag da forma -> signature de quem voce viu usando (NAO tmp: persiste)
	mst_teach_cd = 0           //cooldown de tentativa de despertar (NAO tmp: relogar nao zera)
	fd_assist_form = 0         //maior forma de Frost Demon alcancada COM mestre: o desconto vale de novo ate ela

// ---------------------------------------------------------------------------
// Persistencia (savefile proprio, lido no boot junto com Load_Rank)
// ---------------------------------------------------------------------------
proc/mst_save()
	var/savefile/S = new("MASTER")
	S["MST"] << mst_list
	S["MSTN"] << mst_names

proc/mst_load()
	if(!fexists("MASTER")) return
	var/savefile/S = new("MASTER")
	S["MST"] >> mst_list
	if(isnull(mst_list)) mst_list = new/list()
	S["MSTN"] >> mst_names
	if(isnull(mst_names)) mst_names = new/list()

// ---------------------------------------------------------------------------
// Consultas
// ---------------------------------------------------------------------------
proc/mst_master_sig(aluno_sig)
	if(!aluno_sig) return null
	return mst_list[aluno_sig]

proc/mst_count(mestre_sig)
	var/n = 0
	if(!mestre_sig) return 0
	for(var/s in mst_list)
		if(mst_list[s] == mestre_sig) n++
	return n

proc/mst_name_of(sig)
	if(!sig) return "alguem"
	return mst_names[sig] ? mst_names[sig] : "alguem"

//acha o mob VIVO de uma signature (nao ha indice global: varredura linear, use com parcimonia)
proc/mst_mob_of(sig)
	if(!sig) return null
	for(var/mob/P in player_list)
		if(P.signature == sig) return P
	return null

//M e o MEU mestre? (lido pelo fight_gain_mult a cada golpe: mantenha barato)
mob/proc/mst_is_my_master(mob/M)
	if(!M || !signature || !M.signature) return 0
	return (mst_list[signature] == M.signature)

//o BP do candidato a mestre da conta do aluno? (BP BASE dos dois lados -- o expressedBP
//e distorcido por forma, raiva, supressao, KO e Ki%, e o gate ficaria instavel)
proc/mst_bp_ok(mob/mestre, mob/aluno)
	if(!mestre || !aluno) return 0
	return (max(mestre.BP,1) >= max(aluno.BP,1) * MST_BP_RATIO)

// ---------------------------------------------------------------------------
// Vinculo
// ---------------------------------------------------------------------------
proc/mst_bind(mob/mestre, mob/aluno)
	if(!mestre || !aluno || !mestre.signature || !aluno.signature) return 0
	if(mst_list[aluno.signature]) return 0
	if(mst_count(mestre.signature) >= MST_MAX_STUDENTS) return 0
	mst_list[aluno.signature] = mestre.signature
	mst_names[aluno.signature] = aluno.name
	mst_names[mestre.signature] = mestre.name
	mst_save() //o savefile so e LIDO no boot: grava agora ou um reboot engole o vinculo
	aluno.mst_tab_on()
	mestre.mst_tab_on()
	return 1

proc/mst_unbind(aluno_sig, reason)
	if(!aluno_sig || !mst_list[aluno_sig]) return 0
	var/mestre_sig = mst_list[aluno_sig]
	mst_list -= aluno_sig
	mst_save()
	var/mob/A = mst_mob_of(aluno_sig)
	var/mob/M = mst_mob_of(mestre_sig)
	if(A && A.client)
		to_chat(A, "<font color=#9fd2ff>[reason]</font>")
		A.mst_ui_refresh()
	if(M && M.client)
		to_chat(M, "<font color=#9fd2ff>Seu discipulado com [mst_name_of(aluno_sig)] terminou.</font>")
		M.mst_ui_refresh()
	return 1

//personagem novo herdando uma signature reciclada nao herda mestre nem alunos (chamado do CheckRank)
proc/mst_purge_sig(sig)
	if(!sig) return
	var/mexeu = 0
	if(mst_list[sig])
		mst_list -= sig
		mexeu = 1
	var/list/orfaos = list()
	for(var/s in mst_list)
		if(mst_list[s] == sig) orfaos += s
	for(var/s in orfaos)
		mst_list -= s
		mexeu = 1
	if(mst_names[sig])
		mst_names -= sig
		mexeu = 1
	if(mexeu) mst_save()

mob/proc/mst_login_check()
	if(!signature) return
	if(mst_list[signature] || mst_count(signature))
		mst_names[signature] = name //nome pode ter mudado desde o ultimo login
		mst_tab_on()

mob/proc/mst_tab_on()
	if(!client) return
	register_html_tab("Alunos")

mob/proc/mst_ui_refresh()
	if(!client) return
	last_stats_html = "" //o painel so redesenha quando a STRING muda
	RefreshStatsUI()

// ---------------------------------------------------------------------------
// REGISTRO DE TESTEMUNHA -- "eu ja vi alguem fazer isso"
// Chamado pelos detectores de troca de forma dos buffs raciais (uma linha em
// cada), entao dispara SO na troca de degrau, nunca por tick.
// ---------------------------------------------------------------------------
mob/proc/mst_form_tag()
	if(fd_is_frost())
		if(fd_form == 6) return "frost6"
		if(fd_form == 7) return "frost7"
		return null
	if(Race == "Heran" || Parent_Race == "Heran")
		if(ssj == 1) return "heran1"
		if(ssj == 2) return "heran2"
		return null
	if(Class == "Legendary")
		switch(lssj)
			if(1) return "lssj1"
			if(2) return "lssj2"
			if(3) return "lssj3"
		return null
	if(snamek) return "snamek"
	if(hasayyform && ssj) return (ssj >= 2 ? "alien2" : "alien1")
	//O Bio-Androide usa a MESMA var ssj para a forma dele (Super Perfect): separa pelo
	//BUFF, nao pela raca -- um bio com DNA saiyajin que vira SSJ DE VERDADE deve contar
	if(isBuffed(/obj/buff/SuperPerfect)) return null
	//o Legendary Primal tambem reaproveita ssj com outra semantica (ssj 2 = LSSJ, 3 = LSSJ2)
	if(Class == "Legendary Primal Saiyan") return null
	switch(ssj)
		if(1) return "ssj"
		if(2) return "ssj2"
		if(3) return "ssj3"
		if(4) return "ssj4"
	return null

//quem MUDOU de forma registra a demonstracao nas TESTEMUNHAS ao redor
mob/proc/mst_note_form()
	if(!client || !signature) return //so demonstracao de jogador conta
	var/tag = mst_form_tag()
	if(!tag) return
	for(var/mob/W in oview(MST_WITNESS_RANGE, src))
		if(!W.client || W == src || !W.signature) continue
		if(!islist(W.mst_seen_forms)) W.mst_seen_forms = list()
		W.mst_seen_forms[tag] = signature

mob/proc/mst_saw_form(tag)
	if(!tag || !islist(mst_seen_forms)) return 0
	return (mst_seen_forms[tag] ? 1 : 0)

// ---------------------------------------------------------------------------
// AS FORMAS ENSINAVEIS
// So entram formas cujo destravamento e um REQUISITO PESSOAL (poder, e as vezes
// raiva). Ficam de fora, de proposito: Super Namekuseijin e as formas Alien
// (sao SKILL comprada com Marcos, nao despertar), SSJ4/Full Power/Limit Breaker
// e LSSJ Controlado (dependem de MAESTRIA ou da lua/Oozaru), Bio de laboratorio
// e saga Majin (eventos), e Ultra Instinto / Ultra Ego (ja tem ensino proprio).
// ---------------------------------------------------------------------------
mob/proc/mst_is_saiyan_ladder()
	if(Class == "Legendary" || Race == "Heran" || Parent_Race == "Heran") return 0
	if(Race == "Saiyan" || Parent_Race == "Saiyan" || canSSJ) return 1
	if(genome && genome.race_percent("Saiyan") >= 25) return 1
	return 0

proc/mst_form_name(tag)
	switch(tag)
		if("ssj")    return "Super Saiyajin"
		if("ssj2")   return "Super Saiyajin 2"
		if("ssj3")   return "Super Saiyajin 3"
		if("lssj1")  return "Super Saiyajin Lendario (Contido)"
		if("heran1") return "Max Power"
		if("heran2") return "True Max Power"
		if("frost6") return "Primeira Evolucao"
		if("frost7") return "Forma Black"
	return tag

proc/mst_form_needs_rage(tag)
	switch(tag)
		if("ssj","ssj2","ssj3","lssj1","heran1","heran2") return 1
	return 0

//o aluno PODE despertar esta forma? (raca/linhagem certa e ainda nao a possui)
mob/proc/mst_form_open(tag)
	switch(tag)
		if("ssj")    return (mst_is_saiyan_ladder() && !hasssj)
		if("ssj2")   return (mst_is_saiyan_ladder() && !FutureLineage && !(bio_lab_born && !bio_ssj2_by_death) && hasssj && !hasssj2)
		if("ssj3")   return (mst_is_saiyan_ladder() && !FutureLineage && hasssj2 && !ssj3able)
		if("lssj1")  return (Class == "Legendary" && canRSSJ && !hasssj)
		if("heran1") return ((Race == "Heran" || Parent_Race == "Heran") && !hasssj)
		if("heran2") return ((Race == "Heran" || Parent_Race == "Heran") && hasssj && !hasssj2)
		if("frost6") return (fd_is_frost() && fd_form == 5)
		if("frost7") return (fd_is_frost() && fd_form == 6)
	return 0

//o MESTRE conhece esta forma? (para o gate "mesma raca e ja tem a forma")
mob/proc/mst_form_known(tag)
	switch(tag)
		if("ssj")    return (mst_is_saiyan_ladder() && hasssj)
		if("ssj2")   return (mst_is_saiyan_ladder() && hasssj2)
		if("ssj3")   return (mst_is_saiyan_ladder() && ssj3able)
		if("lssj1")  return (Class == "Legendary" && hasssj)
		if("heran1") return ((Race == "Heran" || Parent_Race == "Heran") && hasssj)
		if("heran2") return ((Race == "Heran" || Parent_Race == "Heran") && hasssj2)
		if("frost6") return (fd_is_frost() && fd_form >= 6)
		if("frost7") return (fd_is_frost() && fd_form >= 7)
	return 0

//o aluno esta no degrau ANTERIOR? (o jogo so deixa ascender de uma forma para a
//seguinte -- o despertar assistido respeita a mesma escada)
mob/proc/mst_form_stance(tag)
	switch(tag)
		if("ssj","heran1")   return (ssj == 0)
		if("ssj2","heran2")  return (ssj == 1)
		if("ssj3")           return (ssj == 2)
		if("lssj1")          return (lssj == 0)
		if("frost6","frost7") return 1 //o proprio Frost_Demon_Forms cuida do degrau
	return 0

//Requisito PESSOAL de poder, ja com o corte do mestre (fator = MST_HALF).
//Compara sempre o BP BASE contra o requisito de USO da forma (o mesmo que o
//Transformation Controls.dm cobra para entrar nela). O expressedBP e inflado por
//Ki carregado, raiva e supressao -- gate instavel e farmavel (bastaria encher o Ki
//para "despertar" uma forma insustentavel).
//Excecao: o SSJ3 nao tem requisito de USO proprio para destravar -- o requisito
//pessoal dele e o ssj3LearnReq sorteado por personagem (Friendship.dm), entao e
//ELE que e cortado pela metade.
mob/proc/mst_form_power_ok(tag, fator)
	switch(tag)
		if("ssj")    return (BP >= ssjat * fator)
		if("ssj2")   return (BP >= (ssj2at / 6) * fator)
		if("ssj3")   return (BP >= mst_ssj3_req() * fator && ssj2mastery >= 50) //maestria NAO e requisito de poder: fica inteira
		if("lssj1")  return (BP >= ssjat * fator)
		if("heran1") return (BP >= ssjat * fator)
		if("heran2") return (BP >= (ssj2at / 6) * fator)
		if("frost6") return (BP >= FD_FORM6_AT * fator)
		if("frost7") return (BP >= FD_FORM7_AT * fator)
	return 0

//requisito pessoal do SSJ3 (sorteado 1x por personagem em CheckSSj3Learn); quem
//ainda nao rolou usa o ponto medio da mesma formula, igual ao zenkai_bp_ceiling
mob/proc/mst_ssj3_req()
	if(ssj3LearnReq > 0) return ssj3LearnReq
	return ssj3at * 0.25

//a proc canonica da forma (ou o motor de transformacao) vai RECUSAR? Checado ANTES,
//para nao anunciar um despertar que nao vai acontecer -- e, principalmente, para nao
//acender a raiva do aluno num caminho que nunca poderia dar certo.
mob/proc/mst_form_blocked(tag)
	if(transing || Apeshit) return 1
	if(TurnOffAscension && !AscensionAllowed) return 1 //ascensao desligada pelo servidor vale para o mestre tambem
	if(MysticPcnt != 1 || MajinPcnt != 1) return 1     //Mistico/Majin ligado trava qualquer transformacao (Transformation Controls.dm)
	//GOD KI: os tetos de maestria vivem no Transformations_Activate, nao dentro das
	//procs de forma -- sem espelhar aqui, o mestre furaria a escada divina e o buff
	//so derrubaria a forma no tick seguinte, deixando o destrave de graca.
	if(godki && godki.usage)
		switch(tag)
			if("ssj","lssj1","heran1")
				if(godki.mastery < GODKI_BLUE_PCT) return 1
			if("ssj2","heran2")
				if(trans_min_val < 2) return 1
			if("ssj3")
				if(trans_min_val < 3) return 1
	switch(tag)
		if("ssj")
			if(Class == "Prodigial" && godki && godki.usage) return 1
			return mst_no_ki(ssjdrain)
		if("ssj2")
			if(FutureLineage) return 1 //linhagem Future tem forma unica: nao acessa SSJ2/SSJ3
			if(bio_lab_born && !bio_ssj2_by_death) return 1 //bio de laboratorio so ganha SSJ2 morrendo
			if(Class == "Prodigial" && godki && godki.usage) return 1
			return mst_no_ki(ssj2drain)
		if("ssj3")
			if(FutureLineage) return 1
			return mst_no_ki(ssj3drain)
	return 0

//mesma condicao do cantSustainForm, SEM o to_chat dele: a explicacao mecanica seca
//chegaria antes da cena de fracasso e entregaria o motivo que o RP esconde
mob/proc/mst_no_ki(drain)
	return (Ki <= MaxKi * max(drain, 0.02))

//assinatura do estado de forma: se nao mudar depois da chamada, a proc canonica recusou
mob/proc/mst_form_state()
	return "[ssj]|[lssj]|[fd_form]"

//Dispara a PRIMEIRA transformacao pela porta canonica: cinematica, musica, flags
//de posse E o corte permanente do limiar (ssjat/=2, ssj2at/=2, hastrans...) ficam
//por conta dessas procs.
//NAO setar as flags aqui: elas sao o que faz a proc saber que e a PRIMEIRA vez.
//Cravar hasssj antes de SSj() pulava o "if(!hasssj) ssjat/=2" e o aluno terminava
//com uma forma que nao conseguia reentrar (limiar cheio, BP pela metade).
mob/proc/mst_form_apply(tag)
	switch(tag)
		if("ssj")             SSj()
		if("ssj2")            SSj2()
		if("ssj3")            SSj3()
		if("lssj1")           Restrained_SSj()
		if("heran1")          Max_Power()
		if("heran2")          True_Max_Power()
		if("frost6","frost7") Frost_Demon_Forms(1) //assisted=1: FD_FORM6_AT/FD_FORM7_AT valem pela metade
	return

//Fecha o que a proc canonica NAO fez. Roda so depois de confirmado que a forma mudou.
//SSj()/SSj2()/Max_Power()/True_Max_Power() cortam o proprio limiar na primeira vez;
//SSj3(), Restrained_SSj() e o Frost NAO -- sem isto o aluno desperta com metade do BP
//e nunca mais consegue REENTRAR na forma que acabou de aprender.
mob/proc/mst_form_seal(tag)
	switch(tag)
		if("ssj3")
			ssj3able = 1 //SSj3() nao marca posse: quem marca sao as vias de destrave
			ssj3at *= 0.5
		if("heran2")
			hasssj2 = 1 //True_Max_Power() seta hasssj=2, nunca hasssj2 (quem seta e sempre o chamador)
		if("lssj1")
			ssjat *= 0.5 //Restrained_SSj() nao toca no limiar
		if("frost6","frost7")
			fd_assist_form = max(fd_assist_form, fd_form) //o desconto vira PERMANENTE ate esta forma (o limiar e #define)
	return

//lista de formas que ESTE mestre pode oferecer a ESTE aluno
proc/mst_teachable(mob/mestre, mob/aluno)
	var/list/out = list()
	if(!mestre || !aluno) return out
	for(var/tag in list("ssj","ssj2","ssj3","lssj1","heran1","heran2","frost6","frost7"))
		if(!aluno.mst_form_open(tag)) continue
		//gate do conhecimento: o aluno JA VIU alguem usar, OU o mestre e da mesma
		//linhagem e ja tem a forma
		if(!aluno.mst_saw_form(tag) && !mestre.mst_form_known(tag)) continue
		out += tag
	return out

// ---------------------------------------------------------------------------
// Raiva acesa pela provocacao do mestre
// ---------------------------------------------------------------------------
mob/proc/mst_ignite_anger()
	//"Irritado" na escada de Stats.dm: Anger >= 100 + (MaxAnger-100)/1.66
	var/alvo = 100 + ((MaxAnger - 100) / 1.66)
	if(Anger < alvo) Anger = alvo
	Emotion = "Angry" //o loop de Stats so recalcula no proximo tick: crava agora para o gate ver
	rageExpire = world.time + (MST_RAGE_MINUTES * 600)

// ---------------------------------------------------------------------------
// VERBS (universais e com gate por dentro: verb concedido em runtime morre no
// logout, e /mob/default/verb e re-dado sozinho em todo login)
// ---------------------------------------------------------------------------
//quem esta no tile para o qual eu OLHO
mob/proc/mst_front_targets()
	var/list/out = list()
	for(var/mob/P in get_step(src, dir))
		if(P == src || !P.client || !P.signature) continue
		out += P
	return out

mob/default/verb/Convidar_Aluno()
	set category = "Learning"
	set name = "Convidar Aluno"
	if(dead || KO) return
	if(!signature)
		to_chat(src, "<font color=yellow>Voce ainda nao tem uma identidade formada.")
		return
	if(mst_count(signature) >= MST_MAX_STUDENTS)
		to_chat(src, "<font color=yellow>Voce ja guia [MST_MAX_STUDENTS] alunos.")
		return
	var/list/frente = mst_front_targets()
	if(!frente.len)
		to_chat(src, "<font color=yellow>Fique de frente para o jogador que voce quer como aluno.")
		return
	var/mob/A = frente.len == 1 ? frente[1] : input(src, "Convidar quem como aluno?", "Mestre e Aluno") as null|anything in frente
	if(!A || !A.client || !A.signature) return
	if(mst_list[A.signature])
		to_chat(src, "<font color=yellow>[A] ja tem um mestre.")
		return
	if(A.dead || A.KO)
		to_chat(src, "<font color=yellow>[A] nao esta em condicoes de ouvir voce.")
		return
	if(!mst_bp_ok(src, A))
		to_chat(src, "<font color=yellow>Voce precisa de pelo menos [MST_BP_RATIO]x o poder base de [A] para ter algo a ensinar. (voce: [FullNum(round(BP))] / ele: [FullNum(round(A.BP))])")
		return
	to_chat(A, "<font color=#9fd2ff><b>[src] se oferece para ser seu mestre.</b></font>")
	mst_ask_student(A)

//pergunta ao ALUNO sem congelar o mestre (alert bloqueia o proc que o chama)
mob/proc/mst_ask_student(mob/A)
	set waitfor = 0
	if(!A || !A.client) return
	switch(alert(A, "[name] se oferece para ser seu mestre. Treinar e lutar com seu mestre rende MUITO mais poder, e ele podera te ajudar a despertar novas transformacoes. Aceitar?", "Mestre e Aluno", "Aceitar", "Recusar"))
		if("Recusar")
			to_chat(src, "<font color=yellow>[A] recusou seu discipulado.")
			to_chat(A, "<font color=yellow>Voce recusa o discipulado.")
			return
	//revalida TUDO: o mundo anda enquanto a caixa espera resposta
	if(!A || !A.client || !A.signature || !signature) return
	if(mst_list[A.signature]) return
	if(get_dist(src, A) > MST_RANGE)
		to_chat(src, "<font color=yellow>[A] se afastou demais.")
		return
	if(!mst_bp_ok(src, A))
		to_chat(src, "<font color=yellow>A diferenca de poder entre voces ja nao e o bastante.")
		return
	if(mst_count(signature) >= MST_MAX_STUDENTS) return
	if(!mst_bind(src, A)) return
	to_chat(view(src), "<font color=#9fd2ff><b>[A] passa a ser aluno de [src].</b></font>")
	to_chat(A, "<font color=#9fd2ff>Trocar golpes com seu mestre agora rende ate [MST_GAIN_CAP]x mais poder. A aba <b>Alunos</b> mostra o vinculo.</font>")
	mst_ui_refresh()
	A.mst_ui_refresh()
	WriteToLog("rplog","[src] tomou [A] como aluno   ([time2text(world.realtime,"Day DD hh:mm")])")

mob/default/verb/Ajudar_A_Transformar()
	set category = "Learning"
	set name = "Ajudar a Transformar"
	if(dead || KO || !signature) return
	if(world.time < mst_teach_cd)
		to_chat(src, "<font color=yellow>Voce ainda esta se recompondo da ultima tentativa.")
		return
	var/list/frente = mst_front_targets()
	var/mob/A = null
	for(var/mob/P in frente)
		if(P.signature && mst_list[P.signature] == signature)
			A = P
			break
	if(!A)
		to_chat(src, "<font color=yellow>Fique de frente para um aluno seu.")
		return
	var/list/tags = mst_teachable(src, A)
	if(!tags.len)
		to_chat(src, "<font color=yellow>Nao ha nada que voce possa despertar em [A] agora -- ou ele nunca viu essa forma, ou voce nao a possui, ou ele ja passou desse degrau.")
		return
	var/list/menu = list()
	for(var/t in tags)
		menu[mst_form_name(t)] = t
	var/escolha = input(src, "Qual forma voce quer despertar em [A]?", "Ajudar a Transformar") as null|anything in menu
	if(!escolha || !menu[escolha]) return
	var/tag = menu[escolha]
	var/raiva = mst_form_needs_rage(tag)
	var/msg = input(src, raiva ? "O que voce diz para tirar [A] do serio? (sai como fala do seu personagem)" : "Explique a [A] como a transformacao funciona. (sai como fala do seu personagem)", "Ajudar a Transformar") as null|text
	if(!msg) return
	msg = copytext(msg, 1, 500)
	//revalida depois das caixas
	if(!A || !A.client || get_dist(src, A) > 1 || mst_list[A.signature] != signature) return
	if(!(tag in mst_teachable(src, A))) return
	mst_teach_cd = world.time + MST_TEACH_COOLDOWN
	sayType(msg, 3) //a mensagem do mestre sai como FALA do personagem
	A.mst_ask_awaken(src, tag, msg, raiva)

//a janela do ALUNO (proc do aluno, waitfor=0: nao congela o mestre)
mob/proc/mst_ask_awaken(mob/T2, tag, msg, raiva)
	set waitfor = 0
	if(!T2 || !client) return
	var/pergunta = raiva ? \
		"[T2.name] te diz:\n\n\"[msg]\"\n\nIsso te tirou do serio?" : \
		"[T2.name] te ensina:\n\n\"[msg]\"\n\nVoce entendeu como a transformacao funciona?"
	switch(alert(src, pergunta, mst_form_name(tag), raiva ? "Perdi a cabeca" : "Entendi", "Nao"))
		if("Nao")
			to_chat(T2, "<font color=yellow>[src] nao se abalou com suas palavras.")
			return
	//revalida: o mundo anda enquanto a caixa espera
	if(!T2 || !client || !signature || mst_list[signature] != T2.signature) return
	if(get_dist(src, T2) > 1) return
	if(!mst_form_open(tag))
		if(T2) to_chat(T2, "<font color=yellow>Alguma coisa mudou em [src] no meio da conversa: essa forma ja nao esta em aberto.")
		return
	if(!mst_form_stance(tag))
		to_chat(view(src), "<font color=#cfd8ff>*[src] tenta acompanhar [T2], mas nao esta na forma certa para dar esse passo.*</font>")
		return
	//o auxilio do mestre corta o requisito pessoal PELA METADE
	if(!mst_form_power_ok(tag, MST_HALF) || mst_form_blocked(tag))
		mst_awaken_fail(T2, raiva, mst_form_needs_rage(tag) ? mst_no_ki(0.02) : 0)
		return
	//a raiva so acende quando o despertar VAI acontecer -- senao toda tentativa fadada
	//ao fracasso viraria um buff de raiva de graca a cada cooldown
	if(raiva) mst_ignite_anger()
	var/antes = mst_form_state()
	mst_form_apply(tag)
	if(mst_form_state() == antes) //a proc canonica recusou na ultima hora: nao minta na cena
		mst_awaken_fail(T2, raiva)
		return
	mst_form_seal(tag) //flags e cortes de limiar que a proc canonica nao faz sozinha
	to_chat(view(src), "<font color=#ffe9a8><b>*Guiado por [T2], [src] alcanca algo que ainda nao era seu...*</b></font>")
	WriteToLog("rplog","[T2] despertou [mst_form_name(tag)] em [src]   ([time2text(world.realtime,"Day DD hh:mm")])")

//falhou: o aluno nao tinha os requisitos nem com o corte pela metade
mob/proc/mst_awaken_fail(mob/T2, raiva, semki)
	if(semki) //corpo vazio de ki: a cena diz ISSO, nao "falta poder" (o motivo importa pro RP)
		to_chat(view(src), "<font color=#cfd8ff>*[src] tenta puxar de dentro alguma coisa que ja nao esta la. O corpo range, vazio, e o impulso morre antes de comecar.*</font>")
		to_chat(src, "<font color=#cfd8ff>Nao e forca que falta agora -- e <b>energia</b>. Voce esta esgotado demais para segurar qualquer forma.</font>")
		if(T2) to_chat(T2, "<font color=#cfd8ff>[src] esta exausto demais. Deixe-o recuperar o ki antes de tentar de novo.</font>")
		return
	if(raiva)
		to_chat(view(src), "<font color=#cfd8ff>*O sangue de [src] ferve, o ar em volta chia e o chao treme sob os pes dele -- e entao tudo se desfaz. [src] arqueja, com a sensacao de ter esbarrado numa parede que nao consegue ver.*</font>")
		to_chat(src, "<font color=#cfd8ff>Voce sentiu. Estava ali, ao alcance da mao... e escapou. <b>Ainda falta alguma coisa em voce.</b></font>")
	else
		to_chat(view(src), "<font color=#cfd8ff>*[src] fecha os olhos e tenta seguir cada palavra de [T2]. O corpo enrijece, a respiracao trava -- e nada acontece.*</font>")
		to_chat(src, "<font color=#cfd8ff>Voce entendeu o caminho, mas seu corpo ainda nao consegue percorre-lo. <b>Falta alguma coisa em voce.</b></font>")
	if(T2) to_chat(T2, "<font color=#cfd8ff>[src] chega perto, mas nao atravessa. Ainda nao e a hora dele.</font>")

// ---------------------------------------------------------------------------
// ABA "Alunos"
// ---------------------------------------------------------------------------
mob/proc/ui_tab_alunos()
	var/list/h = list()
	h += ui_sec("MEU MESTRE")
	var/msig = signature ? mst_list[signature] : null
	if(msig)
		var/mob/M = mst_mob_of(msig)
		var/estado = M ? "presente" : "ausente"
		var/razao = M ? "[round(max(M.BP,1)/max(BP,1),0.1)]x seu poder" : "-"
		h += "<div class='row'><span class='k'>[html_encode(mst_name_of(msig))]<br><span class='mut'>[estado] &middot; [razao]</span></span>"
		h += "<span class='v'><a class='ibtn' href='byond://?src=\ref[src];mstleave=1'>Abandonar</a></span></div>"
		h += "<div class='row'><span class='mut'>Trocar golpes com seu mestre rende ate [MST_GAIN_CAP]x de poder por golpe seu (a partir de [MST_GAIN_FLOOR]x de diferenca de poder base, subindo com a distancia entre voces).</span></div>"
	else
		h += "<div class='row'><span class='mut'>Voce nao tem mestre. Fique de frente para alguem [MST_BP_RATIO]x mais forte e peca para ele te convidar.</span></div>"
	h += ui_sec("MEUS ALUNOS")
	var/achou = 0
	for(var/asig in mst_list)
		if(mst_list[asig] != signature) continue
		achou++
		var/mob/A = mst_mob_of(asig)
		var/sub = A ? "presente &middot; [FullNum(round(A.BP))] de poder base" : "ausente"
		h += "<div class='row'><span class='k'>[html_encode(mst_name_of(asig))]<br><span class='mut'>[sub]</span></span>"
		h += "<span class='v'><a class='ibtn' href='byond://?src=\ref[src];mstdrop=[asig]'>Dispensar</a></span></div>"
	if(!achou) h += "<div class='row'><span class='mut'>Voce ainda nao tem alunos. Use <b>Convidar Aluno</b> na aba Learning, de frente para o jogador.</span></div>"
	return jointext(h, "")
