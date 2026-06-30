// =====================================================================
// OTHER WORLD / "CEU" TALK NPCs  (z6) -- King Kai e Enma Daioh.
// SEM IA: nao andam, nao lutam, nao podem ser atacados/mortos nem
// mindswapados. Ficam parados so pra conversar. Sao colocados no boot
// por codigo (idempotente), igual a Vegeta City -- nao ficam salvos no
// .dmm, entao todo boot recria fresco.
// =====================================================================
mob/npc/Talker
	hasAI = 0            // sem IA de combate (NPCAI so age em hasAI=1)
	AIAlwaysActive = 0
	monster = 0
	attackable = 0       // fixos do cenario: nao da pra atacar/matar
	move = 0             // nao se movem
	density = 1          // solidos: o player esbarra, nao atravessa
	mindswappable = 0
	HasSoul = 0
	BP_Unleechable = 1
	itemrarity = 0       // sem drops

	KingKai
		name = "King Kai"
		gender = "male"
		icon = 'DBZ.dmi'
		New()
			..()
			// trava no frame 1 OLHANDO PRA BAIXO: extrai uma imagem estatica
			// (dir SOUTH, frame 1, parado) do estado "King Kaio" do DBZ.dmi -> nao anima mais.
			// moving=1: o estado "King Kaio" so tem frames de MOVIMENTO (movement=1 no .dmi); moving=0 pedia o frame PARADO (inexistente) -> icone VAZIO/invisivel.
			icon = icon('DBZ.dmi', "King Kaio", SOUTH, 1, 1)
			dir = SOUTH

	EnmaDaioh
		name = "Enma Daioh"
		gender = "male"
		icon = 'Enma.dmi'   // 96x96, 1 estado (convertido de Images/Enma.png)
		pixel_x = -32        // icone tem 96 de largura -> centraliza a figura sobre o tile
		New()
			..()
			dir = SOUTH

	Korin
		name = "Korin"
		gender = "male"
		icon = 'DBZ.dmi'
		New()
			..()
			// trava no frame 1 OLHANDO PRA BAIXO (estado "Korin" do DBZ.dmi) -> nao anima mais.
			// moving=1: "Korin" tambem so tem frames de MOVIMENTO (movement=1); moving=0 deixava o Korin invisivel pelo mesmo motivo do King Kai.
			icon = icon('DBZ.dmi', "Korin", SOUTH, 1, 1)
			dir = SOUTH

var/sky_npcs_built = 0
proc/Build_Sky_NPCs()
	set waitfor = 0
	if(sky_npcs_built) return
	sky_npcs_built = 1
	while(worldloading) sleep(1) // espera o boot/mapa terminar: o New() de mob/npc tem um while(worldloading) que travaria a criacao
	place_sky_talker(/mob/npc/Talker/KingKai,  42, 336, 6)
	place_sky_talker(/mob/npc/Talker/EnmaDaioh, 176, 134, 6)
	place_sky_talker(/mob/npc/Talker/Korin,      142, 63, 12) //Korin na Torre (z12)
	//Barreira espiritual nas portas de Snake Way: bloqueadas ate o Enma liberar o treino com o King Kai.
	place_kaio_gate(176, 137, 6)
	place_kaio_gate(177, 137, 6)
	place_kaio_gate(177, 91, 6)
	place_kaio_gate(176, 91, 6)

proc/place_sky_talker(ntype, px, py, pz)
	var/turf/T = locate(px, py, pz)
	if(!T) return // z/coord nao existe nesse boot
	for(var/mob/npc/Talker/E in T) // ja tem esse Talker nesse tile? nao duplica
		if(istype(E, ntype)) return
	new ntype(T)

proc/place_kaio_gate(px, py, pz)
	var/turf/T = locate(px, py, pz)
	if(!T) return // z/coord nao existe nesse boot
	for(var/obj/barrier/kaio_gate/G in T) return // idempotente: nao duplica a barreira
	new /obj/barrier/kaio_gate(T)

// =====================================================================
// ALINHAMENTO / KARMA  +  JULGAMENTO DO ENMA  +  REVIVE POR ZENI
// karma: <0 = mau (coracao maligno), 0 = neutro, >0 = bom (persistente).
//  - matar um PLAYER inocente (karma>=0)      -> karma NEGATIVO
//  - matar um PLAYER de karma negativo (vilao) -> karma POSITIVO
// Ao MORRER o personagem vai pro Outro Mundo (z6) e fala com o Enma:
//  - karma < 0  -> "coracao maligno" -> Inferno, preso por tempo
//    proporcional ao karma (100% mau = 1h). Cumprida a pena, karma reseta
//    pra NEUTRO e ele volta pro Outro Mundo.
//  - neutro/bom -> fica no Outro Mundo (ceu): pode treinar com o Sr. Kaioh
//    OU pagar Zeni ao Enma pra reviver (debuff de BP 25% por 1h).
// =====================================================================
var/const/ZENI_REVIVE_COST = 1000000 //"quantia alta" pra reviver via Enma (tunavel)

mob/var
	karma = 0                     //alinhamento moral (PERSISTENTE: sem tmp)
	hell_lockout_until = 0        //world.realtime ate quando fica preso no Inferno
	zeni_revive_debuff_until = 0  //world.realtime ate quando o BP fica em 25% (revive por Zeni)
	kaiTrainingAllowed = 0        //Enma liberou a alma a cruzar a barreira espiritual rumo ao King Kai (resetado no ReviveMe)
	tmp/pk_karma_taken = 0        //trava: killer_stuff pode rodar 2x na mesma morte -> nao conta karma 2x (zerado no ReviveMe)
	tmp/lastGateMsg = 0           //world.time: rate-limit da mensagem "fale com o Enma" da barreira espiritual

//----- karma ao matar um PLAYER (chamado no killer_stuff; src = o assassino) -----
mob/proc/gain_kill_karma(var/mob/victim)
	if(!victim || !victim.Player || victim == src) return
	if(victim.pk_karma_taken) return //o karma desta morte ja foi contabilizado
	victim.pk_karma_taken = 1
	if(victim.karma < 0) //matou um vilao (karma negativo) -> ganha karma POSITIVO
		karma = min(karma + 20, 100)
		to_chat(src, "<font color=#88ccff>You struck down a wicked soul. Your heart grows lighter. (Karma: [karma])</font>")
	else //matou um inocente -> ganha karma NEGATIVO
		karma = max(karma - 20, -100)
		to_chat(src, "<font color=#cc4444>You took an innocent life. Darkness seeps into your heart. (Karma: [karma])</font>")

//----- conversa com o Enma (chamado no Click do Enma; src = quem clicou) -----
mob/proc/enma_interact()
	if(!dead)
		to_chat(src, "<font color=#d8a0ff><b>Enma Daioh</b> booms: \"The living have no business at my desk! Begone until your time comes!\"</font>")
		return
	if(karma < 0) //coracao maligno -> Inferno
		enma_judge_to_hell()
		return
	//bom ou neutro: permanece no ceu; revive com Zeni ou vai treinar com o Sr. Kaioh
	to_chat(src, "<font color=#d8a0ff><b>Enma Daioh</b> reads your file: \"A balanced soul. You may rest in the Other World.\"</font>")
	var/revopt = "Return to life (pay [ZENI_REVIVE_COST] Zeni)"
	var/trainopt = "Go train with King Kai"
	var/reincopt = "Reincarnate into a new life (reborn at 10% of your power)"
	var/stayopt = "Stay a while"
	var/choice = input(src, "What will you do?", "Enma Daioh") in list(revopt, trainopt, reincopt, stayopt)
	if(choice == revopt) enma_zeni_revive()
	else if(choice == reincopt) enma_reincarnate()
	else if(choice == trainopt)
		//Enma libera a passagem pela barreira espiritual; sem teleporte: King Kai fica em (42,336,6) z6 e o player vai ATE LA andando por Snake Way.
		kaiTrainingAllowed = 1
		to_chat(src, "<font color=#76ff7a><b>Enma Daioh</b> stamps your file: \"Very well - the spirit barrier will part for you. King Kai's planet lies at the very end of Snake Way. Make the journey on your own two feet. Best start walking!\"</font>")

//----- mandado pro Inferno (src = o condenado) -----
mob/proc/enma_judge_to_hell()
	var/frac = min(abs(karma) / 100, 1) //karma -100 = 100% mau = pena maxima
	var/lockdur = max(round(frac * 36000), 600) //36000 ds = 1h ; piso de 1 min
	hell_lockout_until = world.realtime + lockdur
	to_chat(src, "<font color=#cc2222><b>Enma Daioh</b> SLAMS down his stamp: \"Your heart is BLACK with malice! There is only one place for the likes of you... HELL!\"</font>")
	to_chat(src, "<font color=#cc2222>You are imprisoned in Hell for [round(lockdur/600)] minute(s). Serve your sentence and your soul will be wiped clean.</font>")
	loc = locate(65,258,9) //Inferno (z9)

//----- revive pagando Zeni - metodo 2 (src = quem revive) -----
mob/proc/enma_zeni_revive()
	if(zenni < ZENI_REVIVE_COST)
		to_chat(src, "<font color=#d8a0ff><b>Enma Daioh</b>: \"You can't afford the trip back! Return when you have [ZENI_REVIVE_COST] Zeni.\"</font>")
		return
	zenni -= ZENI_REVIVE_COST
	zeni_revive_debuff_until = world.realtime + 36000 //debuff de 1h
	to_chat(src, "<font color=#d8a0ff><b>Enma Daioh</b> stamps your file: \"Back to the land of the living with you!\"</font>")
	to_chat(src, "<font color=#cc8844>Your body is frail from the journey - your power is capped at 25% for 1 hour.</font>")
	Revive(src, "Enma Daioh sends your soul back into your body!")

//----- reencarnar via Enma (src = quem reencarna) -> novo personagem (nova raca, ou a mesma) com 10% do BP atual -----
mob/proc/enma_reincarnate()
	var/conf = alert(src, "Reincarnation severs you from this life FOREVER. Your current character is gone, and you are reborn as a new soul - a new race if you wish, or the same - with only 10% of your current power. Do not log off until you've made the new character. Proceed?", "Enma Daioh", "Reincarnate", "Cancel")
	if(conf != "Reincarnate") return
	to_chat(src, "<font color=#d8a0ff><b>Enma Daioh</b>: \"A soul that chooses to begin anew... so be it. Go - be reborn, and carry but an echo of who you were.\"</font>")
	Reincarnate(0.1) //recria o personagem; CheckIncarnate semeia o novo BP em 10% do antigo

//----- treino com o Sr. Kaioh (src = quem clicou) -----
mob/proc/kingkai_interact()
	if(!dead)
		to_chat(src, "<font color=#76ff7a><b>King Kai</b> laughs: \"You're still alive! You can't train on my planet until you've kicked the bucket. ...Wanna hear a joke while you're here?\"</font>")
		return
	to_chat(src, "<font color=#76ff7a><b>King Kai</b>: \"Welcome to my little planet! The gravity here is 10 times Earth's - train hard and you'll return to life stronger than ever. Mind you don't step on Bubbles!\"</font>")

//----- checagem periodica (chamada no loop de Stats; src = player conectado) -----
mob/proc/afterlife_alignment_check()
	if(hell_lockout_until) //cumprindo pena no Inferno?
		if(world.realtime >= hell_lockout_until) //pena cumprida
			hell_lockout_until = 0
			karma = 0 //alma limpa -> volta a ser NEUTRO
			to_chat(src, "<font color=#cccccc>Your sentence in Hell is served. Your heart is wiped clean - you drift back to the Other World as a neutral soul.</font>")
			if(z != 6) loc = locate(187,104,6) //de volta ao checkpoint, perto do Enma
		else if(z != 9) //ainda preso, mas fora do Inferno -> de volta pro Inferno
			loc = locate(65,258,9)
	if(zeni_revive_debuff_until && world.realtime >= zeni_revive_debuff_until) //o debuff de BP expirou
		zeni_revive_debuff_until = 0
		to_chat(src, "<font color=#88ff88>Your full strength returns to you.</font>")

//----- Click handlers dos NPCs (usr = quem clicou) -----
mob/npc/Talker/EnmaDaioh/Click()
	var/mob/P = usr
	if(!istype(P) || !P.client) return
	if(get_dist(src, P) > 2)
		to_chat(P, "You need to get closer to Enma Daioh to speak with him.")
		return
	P.enma_interact()

mob/npc/Talker/KingKai/Click()
	var/mob/P = usr
	if(!istype(P) || !P.client) return
	if(get_dist(src, P) > 2)
		to_chat(P, "You need to get closer to King Kai to speak with him.")
		return
	P.kingkai_interact()

mob/npc/Talker/Korin/Click()
	var/mob/P = usr
	if(!istype(P) || !P.client) return
	if(get_dist(src, P) > 2)
		to_chat(P, "You need to get closer to Korin to speak with him.")
		return
	to_chat(P, "<font color=#e0c060><b>Korin</b> twirls his staff: \"Made it all the way up the Tower, huh? Train hard and maybe - MAYBE - I'll part with a Senzu bean.\"</font>")
