// ============================================================================
// LABORATORIOS DE DNA -- humanos inteligentes constroem tecnologia de outra era.
//
//  BUILD: personagem HUMANO com techskill (inteligencia) >= DNL_INT_REQ constroi:
//   - LAB 1 (Android Lab, icone Lab.dmi "lab1"): transforma VOCE em androide.
//       * Androide de ABSORCAO (1M zenni): ganha o verb "Absorb Ki" -- postura
//         parada que SUGA todo ataque de ki recebido (beam/blast/teleguiado),
//         sem dano, recuperando Ki; agarrando alguem, rouba o Ki direto do alvo.
//         BP base vira 1M (ou +1M se voce ja passou disso).
//       * Androide de ENERGIA INFINITA (2M zenni): stamina nunca acaba, Ki se
//         regenera sozinho a vontade e nao precisa mais comer.
//         BP base vira 2M (ou +2M se ja passou disso).
//       Icone, itens e skills SE MANTEM (a maquina reconstroi o corpo por dentro).
//   - LAB 2 (Bio-Android Lab, icone "lab2"): cria um BIO-ANDROIDE jogavel.
//       * O dono ganha o verb "Extract DNA": usar em players NOCAUTEADOS coleta
//         uma amostra da raca deles (vira item no inventario).
//       * Clicar no lab abre um menu HTML: escolha ate 4 DNAs -> inicia a gestacao
//         (1 MES in-game). Destruir o lab cancela o processo.
//       * Ao ficar pronto, a criatura MATA o criador -- e o jogador passa a jogar
//         com o Bio-Androide: BP base = 50% do jogador mais forte entre os DNAs.
//       * Nasce como LARVA (CellLarva.dmi, so 5% do BP); apos 1 dia in-game vira
//         Bio Android 1 (100%).
//       * Evolui absorvendo (major absorb): 1 ANDROIDE ou 3 JOGADORES -> cinematica
//         longa (efeitos do Demon Evolve) com overlay bioto2/bioto3 -> Bio Android
//         2 (BP x2) e depois a FORMA PERFEITA Bio Android 3 (BP x4).
//       * DNA Saiyajin entre os usados -> Zenkai + transformacoes de Super Saiyajin
//         (mas bio-androide e careca: sem cabelo dourado, so aura/raios).
// ============================================================================

// ============================== CONFIG ======================================
#define DNL_INT_REQ 70                 // techskill ("inteligencia") minimo para construir
#define DNL_ANDROID_ABSORB_COST 1000000    // zenni: androide de absorcao
#define DNL_ANDROID_INFINITE_COST 2000000  // zenni: androide de energia infinita
#define DNL_ANDROID_ABSORB_BP 1000000      // BP do androide de absorcao (vira OU soma; ver dnl_apply_android_bp)
#define DNL_ANDROID_INFINITE_BP 2000000    // BP do androide de energia infinita
#define DNL_ABSORB_KI_PER_HIT 0.06     // fracao do MaxKi recuperada por ataque de ki sugado
#define DNL_ABSORB_GRAB_DRAIN 0.03     // fracao do MaxKi do ALVO roubada por tick no grab
#define DNL_LAB_HEALTH 8               // golpes para destruir um laboratorio
#define DNL_BIO_BREW_MONTHS 0.1        // gestacao do bio-androide: 0.1 Year = 1 MES in-game
#define DNL_BIO_BP_SHARE 0.5           // BP inicial = esta fracao do doador mais forte
//DNL_BIO_LARVA_RESTRICT (larva expressa 1/N do base) mora em "Code\1A Defines.dm": o teto duro do powerlevel (base.dm) tambem o usa e os includes sao re-ordenados alfabeticamente
#define DNL_BIO_MAX_DNA 4              // maximo de DNAs por fornada
#define DNL_BIO_EVO_PLAYERS 10         // absorver 10 JOGADORES evolui...
#define DNL_BIO_EVO_NPC_WEIGHT 0.5     // ...NPC vale METADE de um player (20 NPCs = 1 evolucao)
#define DNL_BIO_EVO_ANDROIDS 1         // ...ou 1 ANDROIDE de verdade (o atalho classico do Cell)
#define DNL_BIO_EVO2_MULT 2            // 1a evolucao: BP base x2
#define DNL_BIO_EVO3_MULT 4            // forma perfeita: BP base x4
#define DNL_LARVA_ICON 'CellLarva.dmi'
#define DNL_BIO1_ICON 'Bio Android 1.dmi'
#define DNL_BIO2_ICON 'Bio Android 2.dmi'
#define DNL_BIO3_ICON 'Bio Android 3.dmi'
#define DNL_EVO2_OVERLAY 'bioto2.dmi'
#define DNL_EVO3_OVERLAY 'bioto3.dmi'
// ============================ FIM DO CONFIG =================================

mob/var
	// ---- Lab 1 ----
	android_class = ""          // "" | "absorb" | "infinite" (persiste)
	tmp/ki_absorb_stance = 0    // postura Absorb Ki ativa
	tmp/dnl_inf_running = 0
	tmp/dnl_absorb_msg_cd = 0
	// ---- Lab 2 ----
	has_dna_extractor = 0       // construiu um Lab 2 -> tem o verb (persiste)
	bio_lab_born = 0            // este personagem E um bio-androide de laboratorio
	bio_stage = 0               // 1 larva, 2 imperfeito (Bio1), 3 semi (Bio2), 4 perfeito (Bio3)
	bio_abs_players = 0         // contadores de absorcao p/ evolucao
	bio_abs_androids = 0
	bio_saiyan_dna = 0          // um dos DNAs era Saiyajin
	bio_mature_realtime = 0     // world.realtime em que a larva amadurece
	bio_ssj2_by_death = 0       // o SSJ2 do bio DESPERTOU pela morte (unica via legitima; persiste)
	tmp/bio_evolving = 0
	tmp/bio_ssj2_awakening = 0  // latch: recompondo o corpo na cinematica do despertar (segura mortes re-entrantes)

// ---------------------------------------------------------------------------
// CONSTRUCAO -- via ANDROID CREATION MAINFRAME (arvore de tech; Android_Creation.dm).
// O antigo verb Build_DNA_Lab ficava na aba "Tech", que a UI HTML nova NAO renderiza
// (por isso os labs "nao apareciam") -- o mainframe agora e o caminho: compre na
// arvore de tech, aparafuse (Bolt) e instale o laboratorio em cima dele.
// (O verb mora AQUI e nao em Android_Creation.dm porque usa o define DNL_INT_REQ.)
// ---------------------------------------------------------------------------
obj/items/Android_Creation_Mainframe/verb/Instalar_Laboratorio()
	set name = "Instalar Laboratorio"
	set category = null
	set src in oview(1)
	if(!Bolted)
		to_chat(usr, "Aparafuse o mainframe no chao primeiro (verb Bolt).")
		return
	if(!(usr.Race == "Human" || usr.Parent_Race == "Human"))
		to_chat(usr, "So a engenhosidade HUMANA concebe maquinas assim.")
		return
	if(usr.techskill < DNL_INT_REQ)
		to_chat(usr, "Voce precisa de pelo menos [DNL_INT_REQ] de inteligencia (Tech Skill) para instalar o laboratorio. (Atual: [round(usr.techskill)])")
		return
	var/choice = input(usr, "Instalar qual laboratorio? (o mainframe e consumido na instalacao)", "DNA Lab") as null|anything in list("Lab 1 - Android Lab (transforma VOCE em androide)","Lab 2 - Bio-Android Lab (cria um bio-androide de DNAs)","Cancelar")
	if(!choice || choice == "Cancelar") return
	if(!Bolted || !isturf(loc)) return //re-checa: o input bloqueia e alguem pode ter desaparafusado/carregado o mainframe
	var/turf/T = loc
	if(findtext(choice, "Lab 1"))
		var/obj/DNALab/Android/L = new(T)
		L.owner_sig = usr.signature
		L.owner_name = usr.name
		to_chat(view(usr), "<font color=#66ddff>[usr] ergue um Android Lab sobre o mainframe!</font>")
	else
		var/obj/DNALab/Bio/L = new(T)
		L.owner_sig = usr.signature
		L.owner_name = usr.name
		to_chat(usr, "<font color=#66ddff>Para coletar amostras, construa um <b>DNA CONTAINER</b> na janela de tech e use-o em players nocauteados.</font>")
		to_chat(view(usr), "<font color=#66ddff>[usr] ergue um Bio-Android Lab sobre o mainframe!</font>")
	del(src) //o mainframe vira o laboratorio

// ---------------------------------------------------------------------------
// O objeto laboratorio (base)
// ---------------------------------------------------------------------------
obj/DNALab
	icon = '64x64tech.dmi' //'Lab.dmi' NAO tem os states lab1/lab2 (virava o quadriculado de icone quebrado)
	density = 1
	SaveItem = 1
	IsntAItem = 1
	cantblueprint = 1
	var/owner_sig = ""
	var/owner_name = ""
	var/health = DNL_LAB_HEALTH

	verb/Attack_Lab()
		set name = "Attack Lab"
		set category = null
		set src in oview(1)
		if(usr.KO || usr.dead) return
		health--
		usr.emit_Sound('groundhit2.wav')
		to_chat(view(src), "<font color=orange>[usr] golpeia [src]! ([max(health,0)]/[DNL_LAB_HEALTH])</font>")
		if(health <= 0)
			on_destroyed(usr)
			to_chat(view(src), "<font color=red><b>[src] e reduzido a sucata por [usr]!</b></font>")
			del(src)

	verb/Demolish_Lab()
		set name = "Demolish (owner)"
		set category = null
		set src in oview(1)
		if(usr.signature != owner_sig)
			to_chat(usr, "Este laboratorio nao e seu.")
			return
		var/confirm = input(usr, "Demolir o proprio laboratorio?", "DNA Lab") in list("Nao","Sim")
		if(confirm != "Sim") return
		on_destroyed(usr)
		to_chat(view(src), "[usr] demole [src].")
		del(src)

	proc/on_destroyed(mob/destroyer) //sobrescrito pelo Lab 2 pra cancelar a gestacao

// ---------------------------------------------------------------------------
// LAB 1 -- Android Lab
// ---------------------------------------------------------------------------
obj/DNALab/Android
	name = "Android Lab"
	icon_state = "android_pod" //o pod de conversao (mesmo visual do mainframe que o gerou)

	Click()
		if(!usr || !usr.client || get_dist(usr, src) > 1) return
		if(usr.android_class)
			to_chat(usr, "Seu corpo ja foi convertido. A maquina nao tem mais nada a lhe oferecer.")
			return
		if(usr.KO || usr.dead) return
		var/choice = input(usr, {"Converter seu corpo em androide? O icone, itens e skills se mantem.
- ABSORCAO ([DNL_ANDROID_ABSORB_COST] zenni): suga ataques de ki com o verb Absorb Ki; BP base vira [DNL_ANDROID_ABSORB_BP] (ou soma, se ja for maior).
- ENERGIA INFINITA ([DNL_ANDROID_INFINITE_COST] zenni): stamina infinita, ki auto-regenerante, nunca mais come; BP base vira [DNL_ANDROID_INFINITE_BP] (ou soma)."}, "Android Lab") as null|anything in list("Androide de Absorcao","Androide de Energia Infinita","Cancelar")
		if(!choice || choice == "Cancelar") return
		var/cost = (choice == "Androide de Absorcao") ? DNL_ANDROID_ABSORB_COST : DNL_ANDROID_INFINITE_COST
		var/obj/Zenni/Z = locate(/obj/Zenni) in usr.contents
		if(!Z || Z.zenni < cost)
			to_chat(usr, "Voce precisa de [cost] zenni. (Voce tem [Z ? Z.zenni : 0].)")
			return
		Z.zenni -= cost
		if(choice == "Androide de Absorcao") usr.dnl_become_android("absorb")
		else usr.dnl_become_android("infinite")

mob/proc/dnl_apply_android_bp(amount)
	//BP menor que o valor -> VIRA o valor; ja maior -> SOMA o valor
	if(BP < amount) BP = amount
	else BP += amount

mob/proc/dnl_become_android(class)
	android_class = class
	spacebreather = 1 //maquinas nao respiram
	flick('flashtrans.dmi', src)
	emit_Sound('powerup.wav')
	if(class == "absorb")
		dnl_apply_android_bp(DNL_ANDROID_ABSORB_BP)
		assignverb(/mob/keyable/verb/Absorb_Ki)
		to_chat(src, "<font color=#66ddff><b>A maquina desmonta e reconstroi cada celula sua. Voce agora e um ANDROIDE DE ABSORCAO -- use Absorb Ki para sugar os ataques de ki dos inimigos.</b></font>")
	else
		dnl_apply_android_bp(DNL_ANDROID_INFINITE_BP)
		dnl_start_infinite()
		to_chat(src, "<font color=#66ddff><b>Um nucleo de energia perpetua pulsa no seu peito. Voce agora e um ANDROIDE DE ENERGIA INFINITA -- stamina e ki jamais se esgotarao, e fome e coisa do passado.</b></font>")
	to_chat(view(src), "<font color=#66ddff>*[src] emerge da maquina... diferente.*</font>")
	statify()
	powerlevel()

// nucleo infinito: repoe stamina/nutricao e regenera ki continuamente
mob/proc/dnl_start_infinite()
	set waitfor = 0
	if(dnl_inf_running) return
	dnl_inf_running = 1
	while(src && android_class == "infinite" && !dead)
		sleep(5)
		stamina = maxstamina
		currentNutrition = maxNutrition
		if(Ki < MaxKi) Ki = min(MaxKi, Ki + MaxKi * 0.02)
	dnl_inf_running = 0

// ---- postura ABSORB KI (androide de absorcao) ----
mob/keyable/verb/Absorb_Ki()
	set category = "Skills"
	if(usr.android_class != "absorb") return
	if(usr.ki_absorb_stance)
		usr.ki_absorb_stance = 0
		usr.canmove = 1
		to_chat(usr, "<font color=#66ddff>Voce desativa os coletores de energia e volta a se mover.</font>")
		return
	if(usr.KO || usr.dead || usr.med || usr.train) return
	usr.ki_absorb_stance = 1
	to_chat(view(usr), "<font color=#66ddff>*[usr] finca os pes e abre os coletores de energia -- pronto para SUGAR qualquer ataque de ki!*</font>")
	spawn usr.dnl_stance_loop()

mob/proc/dnl_stance_loop()
	set waitfor = 0
	while(src && ki_absorb_stance && !dead)
		canmove = 0 //parado ate desligar o verb
		if(KO)
			ki_absorb_stance = 0
			break
		//agarrando alguem: rouba o Ki direto do alvo
		if(grabbee && ismob(grabbee))
			var/mob/vict = grabbee
			if(vict.Ki > 0)
				var/steal = min(vict.Ki, vict.MaxKi * DNL_ABSORB_GRAB_DRAIN)
				vict.Ki = max(vict.Ki - steal, 0)
				Ki = min(MaxKi * 2, Ki + steal)
				if(world.time >= dnl_absorb_msg_cd)
					dnl_absorb_msg_cd = world.time + 50
					to_chat(view(src), "<font color=#66ddff>*[src] drena o ki de [vict]!*</font>")
					vict << "<font color=red>Sua energia esta sendo sugada por [src]!</font>"
		sleep(3)
	canmove = 1

// chamado pelo Bump dos ataques de ki (objects.dm): o ataque foi SUGADO
mob/proc/dnl_absorb_ki_attack(obj/attack/blast/A)
	Ki = min(MaxKi * 2, Ki + MaxKi * DNL_ABSORB_KI_PER_HIT)
	flick('flashtrans.dmi', src)
	if(world.time >= dnl_absorb_msg_cd)
		dnl_absorb_msg_cd = world.time + 30
		to_chat(view(src), "<font color=#66ddff>*[src] ABSORVE o ataque de ki, convertendo-o em energia!*</font>")

// ---------------------------------------------------------------------------
// LAB 2 -- Bio-Android Lab
// ---------------------------------------------------------------------------
obj/items/DNA_Sample
	name = "DNA Sample"
	icon = 'props.dmi'
	icon_state = "Closed"
	var/dna_race = ""
	var/dna_donor = ""
	var/dna_sig = ""
	var/dna_bp = 0
	var/list/donor_verbs = list() // snapshot dos verbs de skill do doador na coleta (o bio nasce sabendo)

//-------- DNA CONTAINER: a FERRAMENTA de coleta (craftavel na janela de tech) --------
//O extrator nao e mais dado de graca ao construir o Lab 2: o jogador CRIA o container.
//As amostras coletadas ficam guardadas DENTRO dele.
obj/Creatables/DNA_Container
	icon = 'props.dmi'
	icon_state = "Closed"
	cost = 50000
	neededtech = 50
	allowedRaces = list("Human") //so HUMANOS veem na janela de tech (mesma regra do mainframe)
	desc = "Recipiente criogenico para amostras de DNA. Use-o em players NOCAUTEADOS para extrair e armazenar o DNA deles; leve as amostras ao Bio-Android Lab."
	create_type = /obj/items/DNA_Container

obj/items/DNA_Container
	name = "DNA Container"
	icon = 'props.dmi'
	icon_state = "Closed"
	desc = "Extrai e armazena amostras de DNA de alvos nocauteados."
	verb/Extract_DNA()
		set name = "Extract DNA"
		set category = null
		set src in usr //precisa estar CARREGANDO o container
		//monta a lista de alvos NOS BRACOS DO VERB (o filtro "in oview(1)" no argumento de verb
		//de ITEM avalia o centro de forma traicoeira -- player valido nao aparecia na lista)
		var/list/targets = list()
		for(var/mob/T in oview(1, usr))
			if(!T.KO) continue //so nocauteados
			if(!T.client && !T.isNPC) continue //corpo sem vida propria (projecoes/bonecos)
			if(!T.Race || T.Race == "") continue //constructos sem raca definida
			targets += T
		if(!targets.len)
			to_chat(usr, "Nenhum alvo valido ao alcance: o alvo precisa estar <b>NOCAUTEADO</b> a 1 tile de voce (player ou NPC com raca).")
			return
		var/mob/M = null
		if(targets.len == 1) M = targets[1]
		else M = input(usr, "Extrair o DNA de quem?", "DNA Container") as null|anything in targets
		if(!M) return
		if(!M.KO || get_dist(usr, M) > 1) //re-valida: o input bloqueia e o alvo pode ter acordado/saido
			to_chat(usr, "O alvo escapou do alcance do extrator.")
			return
		var/obj/items/DNA_Sample/S = new
		S.dna_race = M.Race
		S.dna_donor = M.name
		S.dna_sig = M.signature
		S.dna_bp = M.BP
		if(islist(M.Keyableverbs)) S.donor_verbs = M.Keyableverbs.Copy() //tecnicas do doador congeladas na amostra
		S.name = "DNA: [M.Race] ([M.name])"
		S.suffix = ""
		S.loc = src //a amostra fica guardada DENTRO do container
		to_chat(usr, "<font color=#66ddff>Amostra coletada e armazenada no container: [M.Race] de [M.name].</font>")
		to_chat(M, "<font color=red>[usr] extraiu uma amostra do seu DNA!</font>")
	verb/Ver_Amostras()
		set name = "Ver Amostras"
		set category = null
		set src in usr
		var/n = 0
		for(var/obj/items/DNA_Sample/S in src)
			n++
			to_chat(usr, "<font color=#66ddff>[n]. [S.name]</font>")
		if(!n) to_chat(usr, "O container esta vazio.")

//a amostra pertence ao jogador? (direto no inventario OU dentro de um container carregado)
proc/dnl_sample_owned(obj/items/DNA_Sample/S, mob/U)
	if(!S || !U) return 0
	if(S.loc == U) return 1
	if(istype(S.loc, /obj/items/DNA_Container) && S.loc:loc == U) return 1
	return 0

obj/DNALab/Bio
	name = "Bio-Android Lab"
	icon_state = "advregen" //o tanque de incubacao avancado
	var/brewing = 0
	var/brew_ready_year = 0
	var/creator_sig = ""
	var/brew_strongest_bp = 0
	var/brew_has_saiyan = 0
	var/list/brew_verbs = list() // uniao (sem duplicatas) das tecnicas de TODOS os DNAs da fornada
	var/list/tmp/menu_selected = list() //amostras marcadas no menu (refs; tmp)

	New()
		..()
		spawn(50) brew_ticker()

	on_destroyed(mob/destroyer)
		if(brewing)
			brewing = 0
			to_chat(world, "<font color=#e0a030>O Bio-Android Lab de [owner_name] foi destruido -- o experimento em gestacao morreu com ele.</font>", "announce")

	proc/brew_ticker()
		set waitfor = 0
		set background = 1
		while(src)
			sleep(100)
			if(!brewing) continue
			if(Year + 0.001 < brew_ready_year) continue
			//pronto: espera o criador estar ONLINE para o momento fatidico
			for(var/mob/P in player_list)
				if(P.client && !P.dead && P.signature == creator_sig)
					brewing = 0
					dnl_bio_hatch(P, src)
					break

	Click()
		if(!usr || !usr.client || get_dist(usr, src) > 1) return
		if(usr.signature != owner_sig)
			to_chat(usr, "O painel esta trancado no DNA de [owner_name].")
			return
		show_menu(usr)

	proc/show_menu(mob/U)
		var/html = {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
body{margin:0;background:#081018;color:#cfe6f2;font-family:Segoe UI,Tahoma,sans-serif;padding:16px}
h1{font-size:20px;color:#59d0ff;letter-spacing:2px;margin:0 0 4px 0}
.sub{color:#6f93a8;font-size:12px;margin-bottom:14px}
.dna{background:#0d1c2a;border:1px solid #1d3a52;border-radius:6px;padding:8px 12px;margin:6px 0}
.dna a{color:#59d0ff;text-decoration:none;font-weight:bold}
.sel{border-color:#59d0ff;background:#12283c}
.race{color:#9fdcff;font-weight:bold}
.start{display:inline-block;margin-top:14px;padding:10px 22px;background:#0f4f2f;color:#8effb8;border:1px solid #2f8f5f;border-radius:6px;text-decoration:none;font-weight:bold}
.warn{color:#c66;font-size:12px;margin-top:10px}
</style></head><body>
<h1>BIO-ANDROID LAB</h1>
<div class='sub'>Selecione ate [DNL_BIO_MAX_DNA] amostras de DNA do seu inventario. Gestacao: 1 mes in-game.</div>"}
		if(brewing)
			html += "<div class='dna sel'><b>EXPERIMENTO EM GESTACAO...</b> A criatura estara pronta em breve. Proteja o laboratorio: destrui-lo cancela TUDO.</div>"
		else
			//amostras soltas no inventario E dentro de DNA Containers carregados
			var/list/samples = list()
			for(var/obj/items/DNA_Sample/S in U.contents) samples += S
			for(var/obj/items/DNA_Container/C in U.contents)
				for(var/obj/items/DNA_Sample/S in C) samples += S
			var/found = 0
			for(var/obj/items/DNA_Sample/S in samples)
				found++
				var/is_sel = (S in menu_selected)
				html += "<div class='dna[is_sel ? " sel" : ""]'><span class='race'>[S.dna_race]</span> — doador: [S.dna_donor] · <a href='byond://?src=\ref[src];pick=\ref[S]'>[is_sel ? "remover" : "usar este DNA"]</a></div>"
			if(!found)
				html += "<div class='dna'>Nenhuma amostra. Construa um <b>DNA Container</b> na janela de tech e use o <b>Extract DNA</b> dele em players nocauteados.</div>"
			html += "<div class='sub'>Selecionados: [menu_selected.len]/[DNL_BIO_MAX_DNA]</div>"
			if(menu_selected.len >= 1)
				html += "<a class='start' href='byond://?src=\ref[src];start=1'>INICIAR A CRIACAO</a>"
			html += "<div class='warn'>Aviso: ao nascer, a criatura MATARA seu criador — e voce passara a joga-la.</div>"
		html += "</body></html>"
		U << browse(html, "window=BioLab;size=520x480")

	Topic(href, href_list)
		..()
		if(!usr || usr.signature != owner_sig) return
		if(brewing) return
		if(href_list["pick"])
			var/obj/items/DNA_Sample/S = locate(href_list["pick"])
			if(!dnl_sample_owned(S, usr)) return //no inventario OU dentro de um DNA Container carregado
			if(S in menu_selected) menu_selected -= S
			else if(menu_selected.len < DNL_BIO_MAX_DNA) menu_selected += S
			show_menu(usr)
		if(href_list["start"])
			if(menu_selected.len < 1) return
			brew_strongest_bp = 0
			brew_has_saiyan = 0
			brew_verbs = list()
			for(var/obj/items/DNA_Sample/S in menu_selected)
				if(!dnl_sample_owned(S, usr)) continue
				var/donor_bp = S.dna_bp
				for(var/mob/P in player_list) //BP ATUAL do doador se estiver online (senao o da coleta)
					if(P.signature == S.dna_sig)
						donor_bp = max(donor_bp, P.BP)
						break
				brew_strongest_bp = max(brew_strongest_bp, donor_bp)
				if(S.dna_race == "Saiyan" || S.dna_race == "Half-Saiyan") brew_has_saiyan = 1
				for(var/V in S.donor_verbs)
					if(!(V in brew_verbs)) brew_verbs += V //2+ doadores com o MESMO verb -> entra 1 vez so
				del(S)
			menu_selected = list()
			creator_sig = usr.signature
			brewing = 1
			brew_ready_year = Year + DNL_BIO_BREW_MONTHS
			to_chat(view(src), "<font color=#66ddff><b>*O tanque central de [src] se fecha e algo comeca a CRESCER la dentro...*</b></font>")
			usr << browse(null, "window=BioLab")

// ---------------------------------------------------------------------------
// O NASCIMENTO: a criatura mata o criador e o jogador passa a joga-la
// ---------------------------------------------------------------------------
proc/dnl_bio_hatch(mob/creator, obj/DNALab/Bio/L)
	if(!creator || !creator.client) return
	var/strongest = max(L.brew_strongest_bp, 100)
	var/has_saiyan = L.brew_has_saiyan
	to_chat(world, "<font color=#e0a030><b>O tanque do Bio-Android Lab de [L.owner_name] se rompe... A CRIATURA DESPERTOU -- e sua primeira acao foi matar o proprio criador!</b></font>", "announce")
	to_chat(view(L), "<font color=red><b>*A criatura atravessa o peito de [creator] com a cauda. [creator.name] esta morto... mas seus olhos continuam abertos, agora DENTRO da criatura.*</b></font>")
	creator.loc = locate(L.x, L.y, L.z)
	//o "criador" morre como persona: o MESMO mob (mesmo save) renasce como o bio-androide
	creator.Revert()
	creator.clearbuffs()
	creator.name = "Bio-Androide de [creator.name]"
	creator.genome = null
	creator.Race = "Bio-Android"
	creator.Parent_Race = "Bio-Android"
	creator.Class = "None" //Cell-type
	creator.StatRace("Bio-Android", 1)
	creator.race_genome_post_init()
	creator.generatetrees(1) //arvores raciais do bio-androide (skills de absorcao nativas)
	creator.generatetrees(0)
	creator.RemoveHair() //bio-androide e SEMPRE careca
	creator.hair = "Bald"
	//poder: 50% do doador mais forte; nasce LARVA com so 5% acessivel
	creator.BP = max(round(strongest * DNL_BIO_BP_SHARE), 1)
	creator.bio_lab_born = 1
	creator.bio_stage = 1
	creator.bio_abs_players = 0
	creator.bio_abs_androids = 0
	creator.bio_saiyan_dna = has_saiyan
	if(has_saiyan)
		creator.canSSJ = 1 //DNA Saiyajin: Zenkai (has_zenkai le canSSJ) + SSJ
		creator.hasssj = 1 //ja NASCE com o SSJ1 (NAO masterizado): sem despertar por raiva -- transforma assim que tiver o BP (ssjat)
		to_chat(creator, "<font color=#ffd24a>Celulas SAIYAJIN pulsam no seu nucleo: o Zenkai e o proprio SUPER SAIYAJIN ja correm no seu DNA (maestria zero -- treine a forma).</font>")
	//tecnicas dos DOADORES: o bio nasce sabendo os verbs de skill de todos de quem tem DNA (uniao sem duplicatas)
	var/vgot = 0
	if(L && islist(L.brew_verbs))
		for(var/V in L.brew_verbs)
			if(!(V in creator.verbs))
				creator.verbs += V
				vgot++
			if(!(V in creator.Keyableverbs)) creator.Keyableverbs += V
	if(vgot) to_chat(creator, "<font color=#66ddff>Memorias musculares fluem do DNA: voce nasce dominando <b>[vgot]</b> tecnicas dos seus doadores.</font>")
	creator.icon = DNL_LARVA_ICON
	creator.oicon = DNL_LARVA_ICON
	creator.form2icon = DNL_BIO2_ICON
	creator.form3icon = DNL_BIO3_ICON
	creator.BPrestriction = DNL_BIO_LARVA_RESTRICT //larva: ~5% do poder
	creator.bio_mature_realtime = world.realtime + DAY_REAL_MINUTES * 600 //1 dia in-game
	creator.statify()
	creator.powerlevel()
	creator.Ki = creator.MaxKi //VIRAR bio = Ki em exatamente 100% (o Ki absoluto do corpo antigo estourava a barra em ate 500%)
	spawn creator.dnl_larva_watch()
	to_chat(creator, "<font color=#66ddff><b>Voce abre os olhos pela primeira vez. Fraco. Uma LARVA. Em 1 dia sua carapaca se rompera... e o mundo conhecera o que voce realmente e.</b></font>")

//o AMADURECIMENTO em si (idempotente): chamado pelo watcher, pelo login E pelo fallback do powerlevel
mob/proc/dnl_larva_mature()
	if(!bio_lab_born || bio_stage != 1 || dead || bio_evolving) return
	bio_evolving = 1 //latch: watcher + fallback podem disparar juntos
	bio_stage = 2
	BPrestriction = 1
	icon = DNL_BIO1_ICON
	oicon = DNL_BIO1_ICON
	flick('flashtrans.dmi', src)
	emit_Sound('powerup.wav')
	statify()
	powerlevel()
	Ki = MaxKi //nova forma = Ki em 100% exatos
	to_chat(view(src), "<font color=#66ddff><b>*A carapaca larval de [src] se rompe -- uma criatura de carapaca esverdeada emerge, inteira!*</b></font>")
	to_chat(src, "<font color=#66ddff><b>Sua forma imperfeita esta completa: 100% do seu poder foi liberado.</b></font>")
	bio_evolving = 0

//larva -> Bio Android 1 apos 1 dia in-game. O watcher e a via NORMAL, mas ele morre com
//uma morte/runtime e so re-armava no login -- por isso ha tambem o FALLBACK no powerlevel
//(base.dm, bloco do teto da larva), que roda todo tick e nao tem como "morrer".
mob/proc/dnl_larva_watch()
	set waitfor = 0
	while(src && bio_lab_born && bio_stage == 1 && !dead)
		sleep(100)
		if(world.realtime >= bio_mature_realtime)
			dnl_larva_mature()
			break

// ---------------------------------------------------------------------------
// EVOLUCAO por absorcao (1 androide OU 3 jogadores) -- chamada do Absorption.dm
// ---------------------------------------------------------------------------
mob/proc/bio_note_absorb(mob/M)
	if(!bio_lab_born || bio_evolving || bio_stage < 2 || bio_stage >= 4) return
	if(!M) return
	if(M.android_class || M.Race == "Android" || M.Parent_Race == "Android") bio_abs_androids++
	else if(M.isNPC) bio_abs_players += DNL_BIO_EVO_NPC_WEIGHT //NPC vale METADE de um player (20 NPCs = evolucao)
	else bio_abs_players++
	var/need_p = DNL_BIO_EVO_PLAYERS - bio_abs_players
	if(bio_abs_androids >= DNL_BIO_EVO_ANDROIDS || bio_abs_players >= DNL_BIO_EVO_PLAYERS)
		bio_abs_androids = 0
		bio_abs_players = 0
		spawn BioLabEvolve()
	else
		to_chat(src, "<font color=#66ddff>Seu nucleo processa a nova biomassa... (faltam [max(need_p,0)] jogadores -- NPC vale [DNL_BIO_EVO_NPC_WEIGHT] -- OU 1 androide para a evolucao)</font>")

//cinematica de evolucao: efeitos/ritmo do Demon Evolve + overlay bioto2/bioto3 + mensagens no chat
mob/proc/BioLabEvolve()
	if(bio_evolving || bio_stage < 2 || bio_stage >= 4) return
	bio_evolving = 1
	var/target_stage = bio_stage + 1
	poweruprunning = 1
	move = 0
	dir = SOUTH
	emit_Sound('rockmoving.wav')
	//tema PROPRIO por forma: Semi-Perfect Cell (bio 2) / Perfect Cell (bio 3) -- file()+caminho completo, os nomes tem apostrofo/parenteses (nao vivem num 'literal')
	if(target_stage == 3) emit_TransformMusic(file("Sounds/Music/bio forms/Semi-Perfect Cell Theme(Shunsuke Kikuchi).mp3"), 470) //~47s
	else emit_TransformMusic(file("Sounds/Music/bio forms/Perfect Cell's Theme (From  Dragon Ball Z ).mp3"), 1920) //~3min12
	to_chat(view(src), "<font color=#7fe07f>*O corpo de [src] INCHA e borbulha -- a biomassa absorvida esta reescrevendo sua forma!*</font>", "combat")
	to_chat(src, "<font color=#7fe07f><b>SIM... SIM! O poder deles agora e SEU. Sua evolucao comeca!</b></font>", "system")
	//overlay de metamorfose (bioto2/bioto3) durante TODA a cinematica
	var/image/MORPH = image(icon = (target_stage == 3) ? DNL_EVO2_OVERLAY : DNL_EVO3_OVERLAY)
	MORPH.plane = 7
	overlayList += MORPH
	overlaychanged = 1
	// --- fase 1: pedras/tornados/raios (~16s), igual ao Demon Evolve ---
	for(var/cyc = 1 to 16)
		spawn for(var/turf/T in view(9,src))
			if(get_dist(T,src) < 3) continue
			if(prob(5)) createDustmisc(T, 2)
			else if(prob(4)) createDustmisc(T, 3)
			else if(prob(3)) createLightningmisc(T, rand(2,4))
		if(cyc % 4 == 0) spawn Quake()
		if(cyc == 8) to_chat(view(src), "<font color=#7fe07f>*Placas de carapaca racham e se reformam maiores sobre o corpo de [src]...*</font>", "combat")
		sleep(10)
	// --- fase 2: aura + feixes de chao em 8 direcoes (~12s) ---
	var/image/I = image(icon='Aurabigcombined.dmi')
	I.plane = 7
	overlayList += I
	overlaychanged = 1
	emit_Sound('chargeaura.wav')
	Quake()
	spawn Quake()
	var/amount = 8
	while(amount)
		var/obj/A = new/obj
		A.loc = locate(x,y,z)
		A.icon = 'Electricgroundbeam2.dmi'
		if(amount==8) spawn(rand(1,40)) walk(A,NORTH,2)
		if(amount==7) spawn(rand(1,40)) walk(A,SOUTH,2)
		if(amount==6) spawn(rand(1,40)) walk(A,EAST,2)
		if(amount==5) spawn(rand(1,40)) walk(A,WEST,2)
		if(amount==4) spawn(rand(1,40)) walk(A,NORTHWEST,2)
		if(amount==3) spawn(rand(1,40)) walk(A,NORTHEAST,2)
		if(amount==2) spawn(rand(1,40)) walk(A,SOUTHWEST,2)
		if(amount==1) spawn(rand(1,40)) walk(A,SOUTHEAST,2)
		spawn(50) del(A)
		amount--
	to_chat(view(src), "<font color=#7fe07f>*A silhueta de [src] muda por completo dentro do casulo de luz!*</font>", "combat")
	for(var/cyc = 1 to 12)
		spawn for(var/turf/T in view(10,src))
			if(get_dist(T,src) < 3) continue
			if(prob(6)) createDustmisc(T, 2)
			else if(prob(5)) createDustmisc(T, 3)
			else if(prob(4)) createLightningmisc(T, rand(3,6))
		if(cyc % 3 == 0) spawn Quake()
		sleep(10)
	// --- climax ---
	createShockwavemisc(loc, 3)
	createCrater(loc, 3)
	emit_Sound('aura.wav')
	overlayList -= I
	overlayList -= MORPH
	overlaychanged = 1
	if(target_stage == 3)
		icon = DNL_BIO2_ICON
		oicon = DNL_BIO2_ICON
		cell2 = 1 //os sistemas nativos (reverter/expelir) enxergam a forma
		BP *= DNL_BIO_EVO2_MULT
		to_chat(view(src), "<font color=#7fe07f><b>*A poeira baixa: [src] atingiu sua forma SEMI-PERFEITA!*</b></font>", "combat")
		to_chat(src, "<font color=#7fe07f><b>Seu poder base DOBROU. Mas voce sente... que ainda nao e a forma final.</b></font>", "system")
	else
		icon = DNL_BIO3_ICON
		oicon = DNL_BIO3_ICON
		cell3 = 1
		form3cantrevert = 1 //a forma perfeita e permanente
		BP *= DNL_BIO_EVO3_MULT
		to_chat(view(src), "<font color=#7fe07f><b>*Uma figura esguia e serena emerge da luz: [src] alcancou a FORMA PERFEITA.*</b></font>", "combat")
		to_chat(src, "<font color=#7fe07f><b>PERFEICAO. Seu poder base QUADRUPLICOU.</b></font>", "system")
	bio_stage = target_stage
	statify()
	powerlevel()
	Ki = MaxKi //nova forma = Ki em 100% exatos (a barra estourava junto com o salto de BP)
	createShockwavemisc(loc, 2)
	move = 1
	poweruprunning = 0
	bio_evolving = 0
	emit_Sound('powerup.wav')

// ---------------------------------------------------------------------------
// SSJ2 DO BIO-ANDROIDE -- desperta MORRENDO, nao por raiva.
// Requisitos NA HORA DA MORTE: BP suficiente pro SSJ2 + FORMA PERFEITA
// (bio_stage 4) + SSJ1 100% dominado. A morte e CANCELADA (hook no topo do
// Death() em Death.dm): ele se recompoe NO MESMO LUGAR e transforma com uma
// cinematica propria, bem mais curta que a dos Saiyajins.
// ---------------------------------------------------------------------------
mob/proc/bio_ssj2_death_check() //retorna 1 = esta morte foi convertida no despertar (o Death() aborta)
	if(!bio_lab_born || !bio_saiyan_dna || !canSSJ) return 0
	if(bio_ssj2_awakening) return 1 //ja esta se recompondo: segura mortes re-entrantes durante a cinematica
	if(bio_ssj2_by_death) return 0 //so acontece UMA vez
	if(bio_stage < 4) return 0 //precisa da FORMA PERFEITA (bio 3)
	if(ssj1mastery < 100) return 0 //precisa do SSJ1 completamente dominado
	if(BP < ssj2at / max(ssjmult, 1)) return 0 //precisa do BP pro SSJ2 (mesma regua da via saiyajin)
	if(mind_z && z == mind_z) return 0 //morte na dimensao mental nao e real
	bio_ssj2_awakening = 1
	bio_ssj2_by_death = 1
	spawn bio_ssj2_awaken()
	return 1

mob/proc/bio_ssj2_awaken()
	set waitfor = 0
	//recompoe o corpo NO LUGAR da morte (o Death() ja foi abortado)
	KO = 0
	SpreadHeal(200, 1, 1)
	for(var/datum/Body/B in body)
		if(!B.lopped) B.health = B.maxhealth
	Ki = MaxKi
	if(maxstamina) stamina = maxstamina
	canmove = 1
	move = 1
	canfight = 1
	attacking = 0
	blocking = 0
	icon_state = ""
	//cinematica CURTA (~8s) propria do bio
	to_chat(view(8, src), "<font color=#7fe07f><b>*O corpo destrocado de [src]... esta se RECOMPONDO?! O nucleo bio-androide se recusa a morrer!*</b></font>", "combat")
	emit_Sound('rockmoving.wav')
	spawn Quake()
	for(var/cyc = 1 to 4)
		spawn for(var/turf/T in view(6, src))
			if(get_dist(T, src) < 2) continue
			if(prob(8)) createLightningmisc(T, rand(2,5))
			else if(prob(5)) createDustmisc(T, 2)
		if(cyc == 2)
			to_chat(view(8, src), "<font color=#ffd24a>*Relampagos DOURADOS rasgam a carapaca de [src] -- a MORTE acendeu o que faltava no DNA Saiyajin!*</font>", "combat")
			emit_Sound('chargeaura.wav')
		if(HP < 50) SpreadHeal(100, 1, 1) //se apanhar no meio da recomposicao, o nucleo re-cura
		spawn Quake()
		sleep(20)
	createShockwavemisc(loc, 4)
	createCrater(loc, 3)
	to_chat(src, "<font color=#ffd24a><b>Voce MORREU... e voltou. O SUPER SAIYAJIN 2 e seu.</b></font>", "system")
	if(!hasssj2) ssj2at /= 2 //mesmo desconto de despertar da via saiyajin
	hasssj2 = 1
	SSj2() //aplica a forma de verdade (o guard interno passa: bio_ssj2_by_death=1; a cinematica saiyajin e pulada pra bio)
	refresh_combat_tag()
	bio_ssj2_awakening = 0

// ---------------------------------------------------------------------------
// Re-hooks de login (verbs/loops persistentes)
// ---------------------------------------------------------------------------
mob/proc/dnl_login_check()
	if(android_class == "absorb") assignverb(/mob/keyable/verb/Absorb_Ki)
	if(android_class == "infinite") spawn dnl_start_infinite()
	//extrator: agora e o item DNA Container (o verb vive no item; nada a re-armar no login)
	if(Race == "Bio-Android" || Parent_Race == "Bio-Android") //RETROATIVO: bios de saves antigos entram na regra NoAscension
		NoAscension = 1
		BPBoost = 1 //mata o boost de Ascensao salvo (~317x); com NoAscension o Auto_Gain nao o re-cria
	if(bio_lab_born && bio_saiyan_dna)
		if(!hasssj) hasssj = 1 //RETROATIVO: bio com DNA Saiyajin ja "nasce" com o SSJ1 (sem despertar por raiva)
		if(hasssj2 && !bio_ssj2_by_death) //RETROATIVO: SSJ2 pego pela via saiyajin (raiva pulava os estagios) e ILEGITIMO no bio
			hasssj2 = 0
			if(ssj >= 2) Revert()
			to_chat(src, "<font color=#ffd24a>Seu nucleo re-sela o Super Saiyajin 2: no seu corpo ele so desperta atraves da MORTE (forma perfeita + SSJ1 dominado + poder suficiente).</font>")
	if(bio_lab_born && bio_stage == 1)
		//RETROATIVO: larvas nascidas ANTES do fix entram na regra atual ao logar --
		//expressa 10% do base (BPrestriction novo) e ZERO Ascensao (BPBoost salvo/em
		//transicao morre aqui; o gate no Auto_Gain mantem em 1 enquanto for larva)
		BPrestriction = DNL_BIO_LARVA_RESTRICT
		BPBoost = 1
		if(!bio_mature_realtime) bio_mature_realtime = world.realtime + DAY_REAL_MINUTES * 600 //save antigo sem o timer: arma agora
		statify()
		powerlevel()
		spawn dnl_larva_watch()
