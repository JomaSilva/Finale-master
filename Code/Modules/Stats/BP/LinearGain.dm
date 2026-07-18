// ============================================================================
// GANHO LINEAR DE BP + MARCOS DE PODER
//   * O ganho de BP NAO escala mais com o proprio BP (o antigo relBPmax na
//     formula fazia o treino COMPOR como juros: quanto maior o BP, maior o
//     ganho -> bola de neve; a Sala do Tempo x280 explodia 100k em bilhoes).
//   * Agora TODA fonte de treino usa bp_gain_base(): uma BASE FIXA global
//     x BPMod (raca/classe) x multiplicador de MARCOS. Crescimento LINEAR e
//     previsivel: dobrar o tempo de treino = dobrar o ganho.
//   * MARCOS: o multiplicador so sobe quando o personagem rompe um marco da
//     PROPRIA raca (virar SSJ, forma perfeita do bio, Golden do Frost, niveis
//     de Ascensao das racas sem forma, etc.). Nao empilha: vale o MAIOR.
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
var/linearGainBase = 1000 //a BASE fixa de ganho (substitui o relBPmax nas formulas de treino).
                          //Calibrada p/ um personagem novo render ~igual ao ritmo antigo do early game;
                          //o ritmo TOTAL continua escalando por BPTick global, mods de atividade e marcos.

//tabela dos MARCOS (tag -> multiplicador ABSOLUTO de ganho; vale o maior atingido)
var/list/BP_MILESTONES = list(\
	/*Saiyajins e racas canSSJ*/ "ssj" = 2, "ussj" = 2.5, "ssj2" = 3, "ssj3" = 4, "ssj4" = 5, "ssj4fp" = 6,\
	/*Legendary (escada lssj)*/ "lssj1" = 2, "lssj2" = 4, "lssj3" = 6, "lssj4" = 6,\
	/*Bio-Androide*/ "bio1" = 1.5, "bio2" = 2, "bio3" = 3, "bio_ssj2" = 4,\
	/*Majin (saga)*/ "majin2" = 2, "majin3" = 3,\
	/*Frost Demon*/ "frost_final" = 2, "frost_golden" = 3,\
	/*racas SEM forma (Human/Gray/Kai/Demigod...): a Ascensao e o marco*/ "asc5" = 2, "asc10" = 3, "asc20" = 4,\
	/*universais*/ "potential" = 1.5, "godki" = 5, "blue" = 6)

mob/var
	bp_milestone_mult = 1            //multiplicador de marcos vigente (persiste no save)
	list/bp_milestones_done = null   //tags ja atingidas (anuncio 1x; persiste)

//a base de ganho da vez: fixa x raca/classe x marcos (nada de BP proprio aqui!)
mob/proc/bp_gain_base()
	return linearGainBase * max(BPMod, 0.1) * bp_milestone_mult

//rompeu um marco: registra e sobe o multiplicador se for o maior ja visto
mob/proc/bp_milestone_reach(tag)
	if(!BP_MILESTONES || !BP_MILESTONES[tag]) return
	if(!islist(bp_milestones_done)) bp_milestones_done = list()
	if(tag in bp_milestones_done) return
	bp_milestones_done += tag
	var/m = BP_MILESTONES[tag]
	if(m > bp_milestone_mult)
		bp_milestone_mult = m
		if(client) to_chat(src, "<font color=#ffd24a><b>MARCO DE PODER!</b> Seu corpo rompeu um novo patamar: todo ganho de poder agora e <b>x[m]</b>.</font>", "system")

//marcos de ASCENSAO (racas sem forma): chamado pelo Auto_Gain/SmoothGains quando o BPBoost cresce
mob/proc/bp_milestone_check_ascension()
	if(BPBoost >= 20) bp_milestone_reach("asc20")
	else if(BPBoost >= 10) bp_milestone_reach("asc10")
	else if(BPBoost >= 5) bp_milestone_reach("asc5")

//RETROATIVO (login): o hook errado do "godki" (na criacao do datum-conteiner) deu x5 pra personagens
//recem-criados -- se o marco existe mas o God Ki NUNCA despertou de verdade (tier < 1), remove e
//recalcula o multiplicador a partir dos marcos legitimos restantes
mob/proc/bp_milestone_login_fix()
	if(!islist(bp_milestones_done)) return
	if(("godki" in bp_milestones_done) && (!godki || !godki.awakened))
		bp_milestones_done -= "godki"
		var/m = 1
		for(var/tag in bp_milestones_done)
			if(BP_MILESTONES[tag] > m) m = BP_MILESTONES[tag]
		bp_milestone_mult = m
		to_chat(src, "<font color=#ffd24a>Um marco de poder ilegitimo foi re-selado (ganho atual: x[m]).</font>")
