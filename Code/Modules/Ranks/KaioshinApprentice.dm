// ============================================================================
// APRENDIZ DE KAIOSHIN -- o rank de PATRONATO do Kaioshin (2026-07-31)
//   * O Kaioshin (rank "Supreme Kai") toma discipulos de QUALQUER raca pelo
//     verb "Nomear Aprendiz" (skill Kaioshin Apprenticeship, no kit do posto).
//     Nao e um trono: e um vinculo mestre-aluno, ate KSAP_MAX ao mesmo tempo.
//   * O aprendiz ganha uma ARVORE PROPRIA com um RECORTE do saber divino --
//     Cura, Telepatia, Observar e Ver Mortos -- que ele COMPRA com Marcos.
//     Fica de FORA tudo que e prerrogativa do cargo: Mistico, Estilo dos
//     Deuses, Reviver, Reencarnar, Restaurar Juventude, Ritual do Poder,
//     Liberar Potencial e as permissoes do Outro Mundo.
//   * O vinculo MORRE com o mestre: trono vago, outro Kaioshin no trono, ou o
//     proprio aprendiz assumindo um cargo real (formatura). Checado no login E
//     ao vivo pelo laco ksap_gate() da arvore. Ao cair, o kit e desaprendido e
//     os Marcos gastos VOLTAM -- ninguem perde investimento.
//   * Persiste na chave "KSAP" do savefile RANK (assoc APRENDIZ -> MESTRE),
//     sempre por SIGNATURE (nunca key/name, que mudam).
//   * De proposito FORA de dois sistemas: do motor de quests (RankQuests.dm --
//     patronato nao tem tarefa com prazo nem destituicao por falha, e o
//     aprendiz precisa poder reivindicar um cargo real depois) e da Lingua dos
//     Deuses (WishTable.dm -- godtongue e IRREVERSIVEL e so de rank divino).
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define KSAP_MAX       3  // aprendizes simultaneos que um mesmo Kaioshin pode guiar
#define KSAP_RANGE     4  // distancia (tiles) para nomear um discipulo
#define KSAP_GATE_TICK 20 // passo do vigia do vinculo, em ticks (20 = 2s)

var/list/ksap_list = list() //assoc: signature do APRENDIZ -> signature do MESTRE que o nomeou

// O KIT DO APRENDIZ. Esta lista e o contrato do rank: quem quiser mexer no que
// um aprendiz pode aprender mexe AQUI -- e espelha na constituentskills da
// arvore logo abaixo (o motor de arvores casa por typepath, e enableskill em
// skill fora da constituentskills e um no-op SILENCIOSO).
proc/ksap_kit()
	return list(/datum/skill/ki/Heal,/datum/skill/Telepathy,/datum/skill/general/observe,/datum/skill/rank/Dead)

// ---------------------------------------------------------------------------
// Consultas
// ---------------------------------------------------------------------------
proc/ksap_is(sig)
	if(!sig) return 0
	return (sig in ksap_list)

//quantos discipulos este mestre guia agora
proc/ksap_count(mestre_sig)
	var/n = 0
	if(!mestre_sig) return 0
	for(var/s in ksap_list)
		if(ksap_list[s] == mestre_sig) n++
	return n

//POR QUE o vinculo caiu -- null = esta valido. Unica fonte da verdade: o gate ao
//vivo e o login usam esta mesma triagem, entao os dois contam a MESMA historia.
proc/ksap_bond_reason(mob/M)
	if(!M || !M.signature) return "o vinculo se perdeu"
	if(!ksap_is(M.signature)) return "o vinculo se desfez"
	if(!Supreme_Kai) return "o trono do Kaioshin esta vago"
	if(ksap_list[M.signature] != Supreme_Kai) return "o Kaioshin que o iniciou nao ocupa mais o trono"
	if(rq_any_rank(M)) return "voce assumiu um cargo proprio e esta formado" //nao e mais aprendiz: e colega
	return null

proc/ksap_bond_ok(mob/M)
	return !ksap_bond_reason(M)

//varre a lista e derruba TODO vinculo cujo mestre nao esta mais no trono -- inclusive
//dos aprendizes OFFLINE. Sem isto a entrada zumbi continuaria ocupando vaga no
//KSAP_MAX, aparecendo no painel de Ranks, e ressuscitaria intacta se o ex-mestre
//reconquistasse o trono antes do aprendiz logar.
proc/ksap_prune()
	if(!ksap_list.len) return
	var/list/mortos = list()
	for(var/s in ksap_list)
		if(!Supreme_Kai || ksap_list[s] != Supreme_Kai) mortos += s
	for(var/s in mortos)
		ksap_revoke(s, !Supreme_Kai ? "o trono do Kaioshin esta vago" : "o Kaioshin que o iniciou nao ocupa mais o trono")

// ---------------------------------------------------------------------------
// Concessao e revogacao
// ---------------------------------------------------------------------------
proc/ksap_grant(mob/M, mestre_sig)
	if(!M || !M.signature || !mestre_sig) return 0
	if(rq_any_rank(M)) return 0 //quem ja tem trono nao e aprendiz (o verb ja barra; aqui cobre o painel do admin)
	if(ksap_count(mestre_sig) >= KSAP_MAX) return 0
	ksap_list[M.signature] = mestre_sig
	RankList[M.signature] = M.name //o RankList do admin Give Rank nunca roda (condicao morta): gravamos aqui
	M.Rank = "Kaioshin Apprentice"
	if(!(locate(/datum/skill/tree/RankTree) in M.possessed_trees)) M.getTree(new /datum/skill/tree/RankTree)
	M.RankTreeAssign(4) //arvore do aprendiz -- direto, sem depender do latch de 10s do RankTree (o gate sobe no onacquire dela)
	M.testunlocks()
	Save_Rank() //o savefile RANK so e LIDO no boot: grava agora ou um reboot engole a nomeacao
	return 1

proc/ksap_revoke(sig, reason, mob/M)
	if(!sig || !(sig in ksap_list)) return 0
	ksap_list -= sig
	Save_Rank()
	if(!M)
		for(var/mob/P in player_list)
			if(P.signature == sig)
				M = P
				break
	if(M) M.ksap_strip(reason)
	return 1

//tira o titulo e desfaz SO o kit comprado NESTA arvore, devolvendo os Marcos.
//NAO usa refund()/treeshrink() do motor de proposito: o ramo da constituinte
//desabilitada (trees.dm:126-130) varre learned_skills INTEIRO sem checar de que
//arvore a skill veio -- levaria junto a Cura/Telepatia/Observar/Ver Mortos que o
//jogador tivesse comprado na arvore RACIAL, num cargo antigo ou aprendido de um
//mestre -- e ainda le S.type/S.can_forget DEPOIS do del(S) do forget(), soltando
//runtime em serie no DEBUG.log.
mob/proc/ksap_strip(reason)
	var/devolvido = 0
	var/list/possuidas = list()
	for(var/datum/skill/tree/Rank/KaioshinApprentice/T in possessed_trees)
		possuidas += T //coleta antes: o laco abaixo mexe em possessed_trees
	for(var/datum/skill/tree/Rank/KaioshinApprentice/T in possuidas)
		if(!T.savant) T.savant = src
		while(1) //um por passada: forget() deleta o datum e o del some com ele de QUALQUER lista (inclusive de um .Copy())
			var/datum/skill/alvo = null
			for(var/datum/skill/S in T.investedskills)
				if(S.type in ksap_kit())
					alvo = S
					break
			if(!alvo) break
			T.investedskills -= alvo //sai da lista ANTES do forget: a proxima passada nao o reencontra
			if(!alvo.can_forget) continue //kit futuro com skill inesquecivel: nao mexe no Marco dela
			if(!alvo.savant) alvo.savant = src //strip no meio do login: o savant das SKILLS ainda nao foi restaurado
			T.invested -= alvo.skillcost         //e o forget desreferencia savant no unassignverb (verb ficaria colado)
			devolvido = 1
			alvo.forget() //devolve o Marco, roda o before_forget (tira o verb) e deleta o datum
		for(var/P in ksap_kit())
			T.disableskill(P)
		ksap_ui_solta(T)
		possessed_trees -= T
		T.savant = null //mata o loop do gate (while(savant)) e solta o datum
	//a copia que o getTree deixa na VITRINE de arvores cai junto: senao vira card fantasma
	//re-adquirivel -- e uma arvore vazia que nunca mais sai (can_refund=FALSE). Nela NAO se roda
	//disableskill: o growbranches nunca a tocou, e Telepatia/Observar nascem enabled=1, o que
	//renderia um segundo "You can no longer learn X" pro jogador.
	var/list/vitrine = list()
	for(var/datum/skill/tree/Rank/KaioshinApprentice/AT in allowed_trees)
		vitrine += AT
	for(var/datum/skill/tree/Rank/KaioshinApprentice/AT in vitrine)
		ksap_ui_solta(AT)
		allowed_trees -= AT
		AT.savant = null
	if(Rank == "Kaioshin Apprentice") //um cargo real ja teria sobrescrito o titulo no Rank_Verb_Assign
		Rank = ""
		LastRank = ""
	if(client && reason)
		to_chat(src, "<font color=#e8b64c><b>Seu aprendizado com o Kaioshin chegou ao fim:</b> [reason].[devolvido ? " Os Marcos investidos voltaram para voce." : ""]")

//a janela de Skills pode estar ABERTA nesta arvore quando o vinculo cai. Zerar so o CurrentTree
//deixaria o refresh (SkillTreesWindow.dm:60-92) chamando PopulateSkillWindow(null); e o IsLearning
//preso em 1 mataria todo clique de skill pelo resto da sessao. Devolve a UI pra lista de arvores.
mob/proc/ksap_ui_solta(datum/skill/tree/T)
	if(CurrentTree != T) return
	CurrentTree = null
	IsLearning = 0
	LearnSkillMode = 0
	updateWindow = 0
	last_skill_html = ""
	last_tree_html = ""
	if(WhichSkillWindow == 2)
		WhichSkillWindow = 1
		if(client)
			winshow(src,"SkillsListWindow",0)
			winshow(src,"SkillTreeWindow",1)
			RenderTreeBrowser()

//login: o vinculo pode ter caducado enquanto o aprendiz esteve fora.
//RODA ANTES do Rank_Verb_Assign (que so SETA Rank, nunca limpa).
mob/proc/ksap_login_check()
	ksap_prune() //limpa de uma vez os vinculos de mestres que ja cairam (inclusive de quem esta offline)
	if(signature && ksap_is(signature))
		var/motivo = ksap_bond_reason(src)
		if(motivo) ksap_revoke(signature, motivo, src)
	else if(Rank == "Kaioshin Apprentice") //vinculo desfeito enquanto estava offline
		ksap_strip("o vinculo se desfez enquanto voce esteve fora")

// ---------------------------------------------------------------------------
// A ARVORE DO APRENDIZ (slot 4 do RankTreeAssign)
// ---------------------------------------------------------------------------
datum/skill/tree/Rank/KaioshinApprentice
	name = "Aprendiz de Kaioshin"
	desc = "O recorte do saber divino que um Kaioshin confia a um discipulo."
	maxtier = 2
	allowedtier = 2 //a Telepatia e tier 2: com allowedtier 1 ela some da vitrine
	tier = 1
	constituentskills = list(new/datum/skill/ki/Heal,new/datum/skill/Telepathy,\
	new/datum/skill/general/observe,new/datum/skill/rank/Dead)//espelho de ksap_kit()
	enabled = 0
	can_refund = FALSE
	var/tmp/gate_on = 0 //o loop de vigia ja esta rodando? (idempotencia: ele e ligado em varios pontos)

//---- travas da arvore -------------------------------------------------------
//Depois do strip a arvore sai do possessed_trees mas a JANELA em tela continua com
//os cards clicaveis (a UI so redesenha por evento). Sem estas tres travas: o fund()
//do motor ressuscita o savant a partir do usr (trees.dm:100) e vende a skill divina
//numa arvore que o jogador nao possui mais -- e o HandleLevel ainda devolve o Marco,
//porque so soma o invested das arvores que ESTAO no possessed_trees.
datum/skill/tree/Rank/KaioshinApprentice/proc/ksap_viva()
	return (savant && (src in savant.possessed_trees))

datum/skill/tree/Rank/KaioshinApprentice/attemptlearn(var/datum/skill/S)
	if(!ksap_viva()) return
	..()

datum/skill/tree/Rank/KaioshinApprentice/attemptforget(var/datum/skill/S)
	if(!ksap_viva()) return
	..()

datum/skill/tree/Rank/KaioshinApprentice/fund(var/datum/skill/S)
	if(!ksap_viva()) return
	..()

//as duas de baixo rodam DEPOIS do input() do motor (attemptlearn chama treegrow, attemptforget
//chama refund) -- e o vinculo pode ter caido com a caixa de dialogo aberta. Sem elas o motor
//desreferencia savant nulo e a pilha morre antes do IsLearning=0, travando todo clique de skill.
datum/skill/tree/Rank/KaioshinApprentice/treegrow()
	if(!ksap_viva()) return
	..()

datum/skill/tree/Rank/KaioshinApprentice/refund(var/datum/skill/S, var/bypass)
	if(!ksap_viva() || !S) return
	..()

//O encolhimento do motor (trees.dm:126-130) refunda QUALQUER skill aprendida cujo
//tipo case com uma constituinte desabilitada -- sem olhar de que arvore ela veio.
//Esta arvore desabilita as proprias constituintes de proposito quando o vinculo cai,
//entao ela e a candidata numero um a apagar a Cura/Telepatia/Observar/Ver Mortos que
//o jogador comprou na arvore racial, num cargo antigo ou aprendeu de um mestre.
//Aqui o encolhimento so re-sincroniza (o allowedtier desta arvore e fixo em 2: o ramo
//de queda de tier do motor seria codigo morto de qualquer jeito).
datum/skill/tree/Rank/KaioshinApprentice/treeshrink()
	if(!savant) return
	testskillprereqs()
	savant.testunlocks()

datum/skill/tree/Rank/KaioshinApprentice/growbranches()
	if(savant.Rank == "Kaioshin Apprentice" && ksap_bond_ok(savant))
		for(var/P in ksap_kit())
			enableskill(P)
	else
		for(var/P in ksap_kit())
			disableskill(P)
	savant.LastRank = savant.Rank //PENULTIMA linha: comita o rank so depois de aplicar o kit
	..()

//GATE VIVO: o aprendizado cai no mesmo instante em que o mestre perde o trono,
//sem esperar o proximo login de ninguem.
//Loop PROPRIO em vez de effector() porque o acquire() do motor NAO liga o laco de
//effector (so /datum/skill/proc/login liga) -- uma arvore concedida no meio da sessao
//ficaria sem vigia ate o relog. Ligado no onacquire (cobre o ksap_grant, o
//RankTreeAssign(4) e qualquer rota futura de getTree) e no login; gate_on garante um
//laco so por datum, e o teste de possessed_trees mata a copia da vitrine de arvores.
datum/skill/tree/Rank/KaioshinApprentice/proc/ksap_gate()
	set waitfor = 0
	set background = 1
	if(gate_on) return
	gate_on = 1
	while(savant)
		sleep(KSAP_GATE_TICK)
		if(!savant) break
		if(!(src in savant.possessed_trees)) break //copia da vitrine ou arvore ja solta: nada a vigiar
		if(savant.Rank != "Kaioshin Apprentice" && !ksap_is(savant.signature)) continue
		var/motivo = ksap_bond_reason(savant)
		if(!motivo) continue
		var/mob/M = savant
		var/sig = M.signature
		ksap_prune() //derruba de uma vez todos os discipulos do mestre caido, online ou nao
		if(sig && ksap_is(sig)) ksap_revoke(sig, motivo, M)
		else if(M.Rank == "Kaioshin Apprentice") M.ksap_strip(motivo)
		break //o strip solta a arvore do jogador: nao ha mais o que vigiar
	gate_on = 0 //DEPOIS do laco, para cobrir todo break -- senao um relog no mesmo datum nunca religaria o vigia

datum/skill/tree/Rank/KaioshinApprentice/onacquire()
	..()
	ksap_gate() //acquire() do motor nao liga laco nenhum -- este e o unico ponto por onde TODA aquisicao passa

datum/skill/tree/Rank/KaioshinApprentice/login(var/mob/logger)
	..()
	ksap_gate()

// ---------------------------------------------------------------------------
// A SKILL DO MESTRE (habilitada so para o rank "Supreme Kai", em OtherworldRanks.dm)
// ---------------------------------------------------------------------------
/datum/skill/rank/Kaioshin_Apprenticeship
	skilltype = "Misc"
	name = "Kaioshin Apprenticeship"
	desc = "Tome discipulos de qualquer raca e confie a eles o recorte do saber divino que cabe a um aprendiz: cura, telepatia, observacao e a visao dos mortos. Ha um limite de discipulos simultaneos, e o vinculo acaba quando voce deixa o trono."
	can_forget = TRUE
	common_sense = TRUE
	teacher = FALSE //tomar discipulos e do cargo: nao se repassa pelo Teach_Skill
	tier = 1
	skillcost = 0
	enabled = 0

/datum/skill/rank/Kaioshin_Apprenticeship/after_learn()
	assignverb(/mob/Rank/verb/Nomear_Aprendiz)
	assignverb(/mob/Rank/verb/Dispensar_Aprendiz)
	to_chat(savant, "Voce pode tomar discipulos.")
/datum/skill/rank/Kaioshin_Apprenticeship/before_forget()
	unassignverb(/mob/Rank/verb/Nomear_Aprendiz)
	unassignverb(/mob/Rank/verb/Dispensar_Aprendiz)
	to_chat(savant, "Voce nao guia mais discipulos.")
/datum/skill/rank/Kaioshin_Apprenticeship/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Nomear_Aprendiz)
	assignverb(/mob/Rank/verb/Dispensar_Aprendiz)

// ---------------------------------------------------------------------------
// Verbs do Kaioshin
// ---------------------------------------------------------------------------
mob/Rank/verb/Nomear_Aprendiz()
	set category="Skills"
	set name="Nomear Aprendiz"
	if(!signature || Supreme_Kai != signature)
		to_chat(src, "<font color=yellow>Apenas o Kaioshin no trono pode tomar discipulos.")
		return
	if(dead || KO) return
	if(ksap_count(signature) >= KSAP_MAX)
		to_chat(src, "<font color=yellow>Voce ja guia [KSAP_MAX] aprendizes. Dispense um antes de tomar outro.")
		return
	var/list/cands = list()
	for(var/mob/P in oview(KSAP_RANGE, src))
		if(!P.client || P.dead || P.KO || !P.signature) continue
		if(P == src || ksap_is(P.signature) || rq_any_rank(P)) continue
		cands += P
	if(!cands.len)
		to_chat(src, "<font color=yellow>Ninguem por perto pode ser seu aprendiz (precisa ser um jogador vivo, sem cargo proprio e ainda sem mestre).")
		return
	var/mob/S = input(src, "Tomar quem como Aprendiz de Kaioshin?", "Aprendiz de Kaioshin") as null|anything in cands
	if(!S || !S.client || !S.signature) return
	if(get_dist(src,S) > KSAP_RANGE || ksap_is(S.signature) || rq_any_rank(S)) return
	if(ksap_count(signature) >= KSAP_MAX) return
	switch(alert(S, "[name] se oferece para te tomar como APRENDIZ DE KAIOSHIN. Voce podera aprender a Tecnica de Cura e outros segredos dos deuses -- mas o vinculo termina se seu mestre deixar o trono.", "Aprendiz de Kaioshin", "Aceitar", "Recusar"))
		if("Recusar")
			to_chat(src, "[S] recusou o aprendizado.")
			return
	//revalida TUDO depois do alert: o mundo anda enquanto a caixa espera resposta
	if(!S || !S.client || !S.signature || ksap_is(S.signature) || rq_any_rank(S)) return
	if(Supreme_Kai != signature || ksap_count(signature) >= KSAP_MAX) return
	if(get_dist(src,S) > KSAP_RANGE) return
	ksap_grant(S, signature)
	to_chat(view(src), "<font color=#e8b64c><b>[src] toma [S] como Aprendiz de Kaioshin.</b>")
	to_chat(S, "<font color=#e8b64c><b>Voce e agora um Aprendiz de Kaioshin.</b> A arvore <i>Aprendiz de Kaioshin</i> se abriu na sua janela de Skills -- gaste Marcos nela para aprender o que seu mestre permite.")
	WriteToLog("rplog","[src] tomou [S] como Aprendiz de Kaioshin   ([time2text(world.realtime,"Day DD hh:mm")])")

mob/Rank/verb/Dispensar_Aprendiz()
	set category="Skills"
	set name="Dispensar Aprendiz"
	if(!signature || Supreme_Kai != signature)
		to_chat(src, "<font color=yellow>Apenas o Kaioshin no trono guia discipulos.")
		return
	var/list/meus = list()
	var/i = 0
	for(var/s in ksap_list)
		if(ksap_list[s] != signature) continue
		i++
		meus["[i]. [RankList[s] ? RankList[s] : "aprendiz desconhecido"]"] = s
	if(!meus.len)
		to_chat(src, "<font color=yellow>Voce nao guia nenhum aprendiz.")
		return
	var/escolha = input(src, "Dispensar qual aprendiz? (ele perde o kit e recebe os Marcos de volta)", "Aprendiz de Kaioshin") as null|anything in meus
	if(!escolha || !meus[escolha]) return
	if(Supreme_Kai != signature) return
	var/asig = meus[escolha]
	var/anome = RankList[asig] ? RankList[asig] : "seu aprendiz" //a chave do menu vem numerada ("1. Fulano"): nao ecoa no chat
	ksap_revoke(asig, "seu mestre o dispensou")
	to_chat(src, "<font color=#e8b64c>Voce dispensou [anome].")
	WriteToLog("rplog","[src] dispensou o Aprendiz de Kaioshin [anome]   ([time2text(world.realtime,"Day DD hh:mm")])")
