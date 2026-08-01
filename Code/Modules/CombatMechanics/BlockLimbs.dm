// ============================================================================
// BLOQUEIO COM OS MEMBROS (tecla ALT)
//   * Aparar um golpe joga o dano REDUZIDO inteiro no BRACO ou PERNA que aparou,
//     ignorando a zona mirada -- mesmo que o ataque fosse para a cabeca.
//   * Membro QUEBRADO (vida abaixo do limiar) ou DECEPADO nao apara mais nada:
//     sai do rodizio.
//   * Quanto mais bracos/pernas quebrados, MAIOR a chance da guarda CEDER e o
//     golpe passar inteiro. Sem nenhum membro inteiro nao da nem pra entrar em
//     guarda.
//   MAOS e PES ficam de fora da conta: sao membros aninhados (isnested) do braco
//   e da perna -- contar os dois dobraria o numero de "membros quebrados".
// ============================================================================

// ============================== CONFIG ======================================
#define BLOCK_BROKEN_PCT 0.2   //fracao da vida abaixo da qual o membro esta QUEBRADO (mesmo limiar do "Broken" do Injuries.dm)
#define BLOCK_FAIL_PER_LIMB 25 //% de chance da guarda CEDER por membro quebrado/decepado (com os 4 fora nem da pra bloquear)
#define BLOCK_ARM_WEIGHT 3     //peso do braco no sorteio de quem apara...
#define BLOCK_LEG_WEIGHT 1     //...e da perna (apara-se muito mais com os bracos)
#define BLOCK_MSG_DELAY 30     //ticks entre avisos (anti-spam no meio da troca de socos)
// ============================ FIM DO CONFIG =================================

mob/var/tmp
	block_fail_msg = 0  //world.time do proximo aviso de "a guarda cedeu"
	block_break_msg = 0 //...e do proximo aviso de membro quebrado ao aparar
	block_raise_msg = 0 //...e do proximo aviso de "nao da pra erguer a guarda" (janela SEPARADA: o spam do golpe aparado engolia a recusa do ALT e a tecla parecia morta)

//e um membro de BLOQUEIO? (so braco/perna INTEIRO -- mao e pe sao aninhados neles)
proc/block_is_limb(datum/Body/B)
	if(!B) return 0
	if(istype(B, /datum/Body/Arm/Hand) || istype(B, /datum/Body/Leg/Foot)) return 0
	return istype(B, /datum/Body/Arm) || istype(B, /datum/Body/Leg)

mob/proc/block_limb_ok(datum/Body/B) //ainda da pra aparar com ele?
	if(!block_is_limb(B) || B.lopped) return 0
	return B.health >= B.maxhealth * BLOCK_BROKEN_PCT

mob/proc/block_limbs_ok() //quantos bracos/pernas ainda aparam
	. = 0
	for(var/datum/Body/B in body)
		if(block_limb_ok(B)) . += 1

mob/proc/block_limbs_down() //quantos estao QUEBRADOS ou decepados
	. = 0
	for(var/datum/Body/B in body)
		if(!block_is_limb(B)) continue
		if(B.lopped || B.health < B.maxhealth * BLOCK_BROKEN_PCT) . += 1

mob/proc/block_fail_chance()
	return min(block_limbs_down() * BLOCK_FAIL_PER_LIMB, 100)

//sorteia QUEM apara este golpe: braco pesa mais que perna, so entra membro inteiro
mob/proc/block_pick_limb()
	var/list/pool = list()
	var/total = 0
	for(var/datum/Body/B in body)
		if(!block_limb_ok(B)) continue
		var/peso = istype(B, /datum/Body/Arm) ? BLOCK_ARM_WEIGHT : BLOCK_LEG_WEIGHT
		pool[B] = peso
		total += peso
	if(!total) return null
	var/roll = rand(1, total)
	for(var/datum/Body/B in pool)
		roll -= pool[B]
		if(roll <= 0) return B
	return null

mob/proc/block_warn(txt) //aviso limitado: o hitProc roda a cada soco da sequencia
	if(world.time < block_fail_msg) return
	block_fail_msg = world.time + BLOCK_MSG_DELAY
	to_chat(src, txt)

mob/proc/block_warn_raise(txt) //aviso de ERGUER a guarda: janela propria, senao a recusa do ALT sai muda
	if(world.time < block_raise_msg) return
	block_raise_msg = world.time + BLOCK_MSG_DELAY
	to_chat(src, txt)

//A guarda aguenta ESTE golpe? Chamado pelo hitProc uma vez por acerto: substitui
//o antigo "if(M.blocking)" em todos os pontos, entao guarda que cede vira acerto.
mob/proc/block_holds()
	if(!blocking || KO) return 0 //nocauteado ja esta exposto por outro caminho: nem avisa
	if(!block_limbs_ok())
		block_warn("<font color=purple><b>Seus membros estao quebrados demais -- sua guarda DESABA!</b></font>")
		stopblock() //DERRUBA a guarda de verdade: ficar nela so paga os custos (canfight=0, sem revidar,
		            //esquiva do Ultra Instinct desligada, overlay de Block mentindo) sem aparar nada
		return 0
	if(prob(block_fail_chance()))
		block_warn("<font color=purple><b>Sua guarda CEDE -- membro quebrado nao segura o golpe!</b></font>")
		return 0
	return 1

//o membro que aparou acabou de QUEBRAR com o impacto? avisa (e ele sai do rodizio sozinho)
mob/proc/block_check_broken(datum/Body/B)
	if(!B || B.lopped) return
	if(B.health >= B.maxhealth * BLOCK_BROKEN_PCT) return
	if(world.time < block_break_msg) return
	block_break_msg = world.time + BLOCK_MSG_DELAY
	to_chat(src, "<font color=purple><b>Seu [B] cede sob o impacto -- nao da mais para aparar golpe com ele!</b></font>")
