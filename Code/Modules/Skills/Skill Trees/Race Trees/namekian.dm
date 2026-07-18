/datum/skill/tree/namek
	name="Namek Racials"
	desc="Given to all Nameks at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Namekian")
	//REWORK: o antigo /datum/skill/general/regenerate (cura canalizada + Regeneration+5) saiu da arvore --
	//a regeneracao Namekuseijin agora e a Namekian_Regeneration (ativa, 70% do Ki), dada DE GRACA a raca toda
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/namek/bigform,new/datum/skill/demon/soulabsorb,new/datum/skill/general/materialization,\
	new/datum/skill/namek/fusion,new/datum/skill/namek/SuperNamek,new/datum/skill/namek/Stretchy_Arms,\
	new/datum/skill/rank/MakeDragonballs)
mob/var/hassoulabsorb=1
/datum/skill/tree/namek/effector()
	if(savant.hassoulabsorb&&savant.Race=="Namekian"&&savant.Class!="Dragon clan")
		disableskill(/datum/skill/demon/soulabsorb)
		savant.hassoulabsorb = 0
	//CLA DO DRAGAO: a criacao das esferas so aparece pra compra quando ha ONDE usa-la
	//(Guardiao da Terra ou dono de um planeta conquistado). Perdeu o posto/planeta = some
	//da loja; quem JA comprou mantem o conhecimento (o proprio verb trava o local da estatua).
	if(savant.Class == "Dragon clan" && savant.signature && (savant.signature == Earth_Guardian || conq_owns_any(savant.signature)))
		enableskill(/datum/skill/rank/MakeDragonballs)
	else
		disableskill(/datum/skill/rank/MakeDragonballs)
	..()
/datum/skill/namek/SuperNamek
	skilltype = "Form"
	name = "Super Namekian"
	desc = "Unlock what you might call \"Peak Namekian Perfection!\"! You need to be around two million in order to use this."
	can_forget = FALSE
	common_sense = FALSE
	tier = 2
	skillcost=2
	after_learn()
		savant.snamek=1
		to_chat(savant, "Power up past two million and let the sparks fly, baby!")

// ============================================================================
// CRIACAO DAS ESFERAS DO DRAGAO -- o segredo do CLA DO DRAGAO (rework 2026-07-18)
// A skill saiu dos ranks Namekian Elder/Grand Elder e virou compra da arvore
// racial Namek: so um Namekuseijin do Cla do Dragao que tenha ONDE usa-la
// (Guardiao da Terra ou dono de um planeta conquistado) ve a skill na loja --
// gate vivo no effector() da arvore, logo acima. A ESTATUA em si so pode ser
// erguida na Terra (sendo o Guardiao) ou num planeta dominado (bandeira de
// conquista) -- gate no proprio verb, que tambem cobre instancias da skill
// herdadas de saves antigos dos ranks Elder.
// (typepath /datum/skill/rank/ MANTIDO por compatibilidade com savefiles que
// ja possuem a skill aprendida pelo sistema antigo -- nao renomear)
// ============================================================================
/datum/skill/rank/MakeDragonballs
	skilltype = "Misc"
	name = "Make Dragon Statue"
	desc = "O segredo mais profundo do Cla do Dragao: moldar uma Estatua do Dragao e dar vida a um set de Esferas. A estatua so pode ser erguida na Terra (sendo o Guardiao da Terra) ou num planeta que voce dominou."
	can_forget = FALSE //conhecimento de uma vida (e o treeshrink nao pode devolver a skill sozinho quando o gate fecha)
	common_sense = FALSE
	teacher = FALSE //nao se ensina: ou o cla sabe, ou nao sabe
	tier = 2 //custa 2 Milestones (regra da casa: skillcost = tier)
	enabled = 0 //destravada pelo effector da arvore racial (Cla do Dragao + Guardiao/dono de planeta)
	compatible_races = list("Namekian")
	compatible_classes = list("Dragon clan")

/datum/skill/rank/MakeDragonballs/after_learn()
	assignverb(/mob/Rank/verb/Create_Dragon_Statue)
	to_chat(savant, "You can make dragon statues!")
/datum/skill/rank/MakeDragonballs/before_forget()
	unassignverb(/mob/Rank/verb/Create_Dragon_Statue)
	to_chat(savant, "You've forgotten how to make dragon statues!")
/datum/skill/rank/MakeDragonballs/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Create_Dragon_Statue)

mob/Rank/verb/Create_Dragon_Statue()
	set category="Other"
	set name="Create Dragon Statue"
	//gate 1: so o Cla do Dragao carrega o segredo (a compra ja filtra, mas o verb pode ter vindo de save antigo dos ranks Elder)
	if(!(Race == "Namekian" || Parent_Race == "Namekian") || Class != "Dragon clan")
		to_chat(src, "<font color=yellow>Apenas Namekuseijins do Cla do Dragao carregam o segredo da criacao das Esferas do Dragao.")
		return
	//gate 2: SOMENTE na Terra sendo o Guardiao, ou num planeta que voce conquistou
	var/area/getarea = GetArea()
	var/pl = getarea ? getarea.Planet : null
	if(!pl)
		to_chat(src, "<font color=yellow>Nao ha um mundo aqui para ancorar um set de esferas.")
		return
	if(pl == "Earth")
		if(!signature || Earth_Guardian != signature)
			to_chat(src, "<font color=yellow>Somente o Guardiao da Terra pode erguer uma Estatua do Dragao na Terra.")
			return
	else if(!signature || conq_owner_sig(pl) != signature)
		to_chat(src, "<font color=yellow>Voce so pode erguer uma Estatua do Dragao num planeta que dominou (bandeira de conquista) -- ou na Terra, se for o Guardiao.")
		return
	var/obj/DragonStatue/A = new
	A.Ballplanet = pl
	A.WishPower = BP
	A.loc = locate(x,y,z)
	A.Creator = src
	A.CreatorSig = src.signature
	//DESEJO SUPREMO opcional: o criador pode GRAVAR o Strongest in the Universe no set (compra na criacao)
	if(zenni >= SW_WISH_PRICE)
		switch(alert(src, "Gravar o desejo STRONGEST IN THE UNIVERSE nestas esferas por [FullNum(SW_WISH_PRICE)] zenni? Quem pedir troca TODO o proprio lifespan por 2x o maior BP do jogo -- e vive so mais 1 ano, sem revive (apenas reencarnacao).", "Desejo Supremo", "Gravar", "Nao"))
			if("Gravar")
				zenni -= SW_WISH_PRICE
				A.HasStrongestWish = 1
				to_chat(src, "<font color=#e8b64c><b>O desejo supremo foi gravado nas esferas deste set.</b> ([FullNum(SW_WISH_PRICE)] zenni)")
	else
		to_chat(src, "<font color=#888>Com [FullNum(SW_WISH_PRICE)] zenni voce poderia gravar o desejo supremo (Strongest in the Universe) na criacao do set.")

/datum/skill/namek/fusion
	skilltype = "Form"
	name = "Fusion- Namek Style"
	desc = "Ask someone if they'd like to fuse. If so, they will recieve your power and you will be sent to the Sealed Realm."
	can_forget = FALSE
	common_sense = FALSE
	skillcost=2
	tier = 2
	login(var/logger)
		..()
		assignverb(/mob/keyable/verb/Namekian_Fusion)
	after_learn()
		assignverb(/mob/keyable/verb/Namekian_Fusion)
		to_chat(savant, "You can fuse!")

	before_forget()
		unassignverb(/mob/keyable/verb/Namekian_Fusion)
		to_chat(savant, "You can't fuse!")

/datum/skill/namek/Stretchy_Arms
	skilltype = "Form"
	name = "Stretchy Arms"
	desc = "Unleash your inner Gumby... by pressing grab, if you have a target, your arms will track down your foe and keep them still while you can freely move around."
	can_forget = FALSE
	common_sense = FALSE
	tier = 2
	skillcost=1
	after_learn()
		savant.can_stretch_arms=1
		to_chat(savant, "Target a opponent, press grab, and your arms will fly at them! Block (alt) to let go, grab to bring them towards you, attack to do a grab-attack, turning the grab into a regular grab.")

// ============================================================================
// REWORK NAMEKUSEIJIN -- Namekian Regeneration (skill racial ATIVA, de graca)
// Namekuseijin nao tem mais regeneracao passiva acelerada (assign_regen os trata
// como um Saiyajin normal: nada de cura em combate, membro decepado nao volta
// sozinho). Em troca, TODO Namekuseijin tem esta skill:
//  - Custa NAMEK_REGEN_KI_COST (fracao do Ki MAXIMO: sempre 70% da barra,
//    independe do tamanho do pool de ki).
//  - Se houver membro(s) DECEPADO(s): restaura 1 deles (aleatorio se 2+). Regenerar
//    um braco/perna traz JUNTO a mao/pe daquele membro; se so a mao/pe foi perdida,
//    so ela volta.
//  - Sem membro decepado: cura o membro MAIS FERIDO para 100%.
// Concedida em statnamek() (criacao) e no Login (personagens ja existentes).
// ============================================================================
#define NAMEK_REGEN_KI_COST 0.7 // fracao do MaxKi consumida (0.7 = 70% da barra)
#define NAMEK_REGEN_CD 100      // cooldown em ticks (100 = 10s) so pra nao spammar o botao

mob/var/tmp/namek_regen_cd = 0

mob/keyable/verb/Namekian_Regeneration()
	set name = "Namekian Regeneration"
	set category = "Skills"
	if(!(usr.Race == "Namekian" || usr.Parent_Race == "Namekian")) return
	if(usr.KO || usr.dead || usr.med || usr.train)
		to_chat(usr, "<font color=yellow>Voce nao consegue se concentrar para regenerar agora.")
		return
	if(world.time < usr.namek_regen_cd)
		to_chat(usr, "<font color=yellow>Seu corpo ainda esta se recompondo!")
		return
	var/cost = usr.MaxKi * NAMEK_REGEN_KI_COST
	if(usr.Ki < cost)
		to_chat(usr, "<font color=yellow>Voce precisa de [round(NAMEK_REGEN_KI_COST*100)]% do seu Ki para regenerar! ([round(cost)] de Ki)")
		return
	//escolhe o alvo: PREFERENCIA para membro decepado (aleatorio se houver 2+); senao o mais ferido.
	//um membro decepado cujo PAI tambem foi decepado (a mao de um braco perdido) nao e escolhido
	//separado -- ele volta junto com o pai.
	var/list/lopped_roots = list()
	var/datum/Body/worst = null
	var/worstfrac = 1
	for(var/datum/Body/S in usr.body)
		if(S.lopped)
			if(S.parentlimb && S.parentlimb.lopped) continue
			lopped_roots += S
		else if(S.maxhealth > 0)
			var/f = S.health / S.maxhealth
			if(f < worstfrac)
				worstfrac = f
				worst = S
	var/datum/Body/target_limb = null
	if(lopped_roots.len) target_limb = pick(lopped_roots)
	else if(worst && worstfrac < 0.999) target_limb = worst
	if(!target_limb)
		to_chat(usr, "Seu corpo ja esta inteiro.")
		return
	usr.Ki -= cost
	usr.namek_regen_cd = world.time + NAMEK_REGEN_CD
	if(target_limb.lopped)
		target_limb.RegrowLimb()
		target_limb.health = target_limb.maxhealth //volta INTEIRO (RegrowLimb sozinho deixaria em 70%)
		for(var/datum/Body/C in usr.body) //a mao/pe (filhos diretos) do membro regenerado brota junto
			if(C.lopped && C.parentlimb == target_limb)
				C.RegrowLimb()
				C.health = C.maxhealth
		to_chat(view(usr), "<font color=#66FF66><b>*O corpo de [usr] borbulha e um novo [target_limb.name] brota no lugar do perdido!*</b></font>")
	else
		target_limb.health = target_limb.maxhealth
		to_chat(view(usr), "<font color=#66FF66>*[usr] concentra seu ki e regenera seu [target_limb.name]!*</font>")
	usr.emit_Sound('powerup.wav')
	createDustmisc(usr.loc, 1)
	usr.HealthSync()
	usr.powerlevel()

mob/var
	can_stretch_arms = 0

	tmp
		is_stretched = 0
		stretch_bring = 0

mob/proc/stretch_arms(var/mob/M)
	set waitfor = 0
	is_stretched = 1
	grabMode = 2
	grabParalysis = 1
	var/grabbedsucc = 0
	var/obj/attack/namek_arm/nA = new
	nA.icon = 'namekarm.dmi'
	nA.icon_state = "end"
	var/i
	while(!blocking)
		i++
		if(i>25) break
		var/d = get_dist(M.loc,nA.loc)
		if(d>1) step_towards(nA,M,20)
		else
			M.grabParalysis = 1
			grabbedsucc = 1
			break
		sleep(1)
	if(grabbedsucc)
		M.grabberSTR = (Ephysoff*expressedBP) / 3
		M.grabber = src
		grabbee = M
		var/bringing =0
		while(M.grabParalysis && !blocking && grabbee)
			if(stretch_bring && !bringing)
				bringing = 1
				spawn
					var/rushSpeed=round(0.3*move_delay,0.1)
					var/justincase=0
					while(get_dist(src,M)>1 && grabbee)
						justincase+=1
						if(!canmove)
							to_chat(src, "You're unable to move them any closer!")
							break
						step(M,get_dir(M,src))
						if(justincase==50 || !grabbee)
							to_chat(src, "You're unable to move them any closer!")
							break
						sleep(rushSpeed)
					stretch_bring = 0
					bringing = 0
			if(KO||grabbee.z!=usr.z||totalTime==0)
				to_chat(view(), "[usr] is forced to release [grabbee]!")
				emit_Sound('groundhit2.wav')
				grabbee.grabberSTR=null
				grabbee.attacking=0
				//grabbee.canfight=1
				grabbee.grabParalysis = 0
				is_choking = 0
				grabMode=0
				//canfight=1
				attacking=0
				grabbee=null
				grabbee.grabber = null
				break
	grabMode = 0
	grabParalysis = 0
	is_stretched = 0
	del(nA)
obj/attack/namek_arm
	var/didmydirchange
	Move()
		var/oldloc = loc
		didmydirchange = dir
		if(..())
			var/obj/attack/namek_arm = new(oldloc)
			namek_arm.icon = 'namekarm.dmi'
			if(didmydirchange != dir)
				if(dir == turn(didmydirchange,90)) namek_arm.icon_state = "right turn"
				if(dir == turn(didmydirchange,-90)) namek_arm.icon_state = "left turn"
			else namek_arm.icon_state = ""

