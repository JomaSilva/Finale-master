mob/var/zenkaiStore = 0
mob/var/zenkaiTimer = 0
mob/var/tmp/zenkaiWarn = 0 //world.realtime gate for the 'Zenkai on cooldown' notice (rate-limit + post-grant suppression)
var/zenkaiInjuryFraction = 0.45 //share of body parts that must be Broken/lopped to count as "extremely injured" (bumps a defeat's Zenkai to 15% of the foe's BP and a 3x-base-BP ceiling)
var/zenkaiCapSSJ3Mid = 0.25 //APOSENTADORIA do Zenkai: para de funcionar quando o BP base alcanca ~o BP pessoal de liberar o SSJ3. Se o requisito pessoal (ssj3LearnReq) ainda nao foi rolado, teto = ssj3at x isto (0.25 = o ponto MEDIO da formula do CheckSSj3Learn: ssj3at/10 x rand 2.0-3.0). Vale pra TODAS as racas/classes com Zenkai

//o teto de BP alem do qual o Zenkai nao surge mais (~"BP pessoal necessario pro SSJ3")
mob/proc/zenkai_bp_ceiling()
	if(ssj3LearnReq > 0) return ssj3LearnReq //requisito pessoal ja rolado (CheckSSj3Learn): usa ele exato
	return ssj3at * zenkaiCapSSJ3Mid //fallback pra quem nunca rola o requisito (racas fora do CheckSSj3Learn)
// Zenkai is a passive EXCLUSIVE to Saiyan DNA (Saiyan, Half-Saiyan, Primal/Legendary lineages, Saiyan-blooded)
// plus Cell-type Bio-Androids who carry Saiyan cells. Every other race has NO Zenkai whatsoever.
mob/proc/has_zenkai()
	if(Race=="Bio-Android" || Parent_Race=="Bio-Android") return TRUE
	if(Race=="Saiyan" || Parent_Race=="Saiyan") return TRUE
	if(Race=="Half-Saiyan" || Parent_Race=="Half-Saiyan") return TRUE
	if(canSSJ) return TRUE //gained Saiyan power (Baby absorb, etc.)
	if(SaiyanLineage) return TRUE //Primal Saiyan and other Saiyan lineages
	if(genome && genome.race_percent("Saiyan") >= 25) return TRUE
	return FALSE

//Zenkai grant for being DEFEATED (knocked out OR killed) by a STRONGER foe. Shared by the KO proc (KO.dm) and
//death_stuff (Murder.dm) so both routes obey the same reward, paid IN FULL at the moment of defeat (no bank):
//10% of the foe's BP straight into base BP, once per hour, Saiyan-DNA only. CEILING is on the FINAL base BP:
//one Zenkai can at most DOUBLE your current base (gain capped at +1x base). If your body is extremely injured
//at that moment (large part Broken or ripped off), the brush with death squeezes out more: 15% of the foe's BP
//and the final base may at most TRIPLE (gain capped at +2x base).
//OBS: no caminho de MORTE isto roda via killer_stuff -> death_stuff ANTES de dead=1 (Death.dm), entao o guard
//if(dead) nao bloqueia -- ele so impede Zenkai de luta no Outro Mundo (ja morto, ex: torneio do ceu).
mob/proc/gain_zenkai(enemyBP) //enemyBP = the foe's EFFECTIVE power (expressedBP, form-inclusive) -- NOT base BP
	var/myPower = max(expressedBP, BP) //compare EFFECTIVE power on BOTH sides: a transformed foe with a lower BASE BP still counts as "stronger". Using base BP here is why high-base builds (notably Primal Saiyan) got no Zenkai from a transformed opponent.
	if(!enemyBP || enemyBP <= myPower) return //only a genuinely stronger (effective) enemy triggers Zenkai
	if(dead) return
	if(mind_z && z == mind_z) return //dentro da DIMENSAO MENTAL nada e real: ferimento mental nao gera Zenkai
	if(!has_zenkai()) return //Saiyan DNA only
	if(BP >= zenkai_bp_ceiling() && Class != "Kaio") //APOSENTADO: alcancou ~o BP pessoal do SSJ3 -- o corpo nao arranca mais forca das derrotas. EXCECAO: a classe Kaio (corpo do desejo divino) tem Zenkai SEM limite (WishTable.dm)
		if(client && world.realtime >= zenkaiWarn)
			zenkaiWarn = world.realtime + 600
			to_chat(src, "<font color=#b07a38>Your body no longer surges back from defeat -- it has grown past what a Zenkai can teach it.</font>", "combat")
		return
	if(world.realtime < zenkaiReady) //the 1h cooldown is still ticking (realtime = wall-clock, survives logout/reboot)
		if(client && world.realtime >= zenkaiWarn) //defeated by a stronger foe but Zenkai isn't recharged yet -> warn (rate-limited)
			zenkaiWarn = world.realtime + 300
			var/left = max(zenkaiReady - world.realtime, 0)
			var/mins = round(left / 600)
			var/cdtxt = (mins >= 1) ? "give it roughly [mins] more minute(s)" : "barely a moment more"
			to_chat(src, "<font color=#b07a38>Your body reaches for a Zenkai, but it hasn't recovered from the last one and refuses to surge again so soon ([cdtxt]).</font>", "combat")
		return
	var/pcnt = 0.1 //10% of the foe's BP...
	var/capmult = 2 //...teto no BP FINAL: um Zenkai normal pode no maximo DOBRAR o seu BP base atual
	if(extremely_injured())
		pcnt = 0.15 //battered to the brink -> 15% of the foe's BP...
		capmult = 3 //...extremamente ferido (45%+ do corpo Broken/arrancado): o BP final pode no maximo TRIPLICAR
	var/raw = pcnt*enemyBP //10%/15% of the foe's BP
	var/cap = BP*(capmult-1) //teto do GANHO = (multiplo final - 1) x base: dobrar -> ganho max +1x base; triplicar -> +2x base. Ex: base 5k vs inimigo 150k -> normal +5k (vira 10k), extremely injured +10k (vira 15k)
	var/gained = min(raw, cap)
	if(client) to_chat(src, zenkai_message(gained, raw >= cap), "combat") //mensagem ANTES do BP mudar (os tiers usam gained/BP com o base antigo); escala com o tamanho do surto, sem numeros
	BP += gained //SEM BANCO (2026-07-04): o Zenkai cai INTEIRO na hora da derrota, direto no BP base -- sem capcheck (e recompensa, nao treino). O zenkaiStore antigo "comia" o ganho (clamp no BPCap legado=1000 + gotejamento via capcheck que evaporava a diferenca); em Stats.dm sobrou so um flush de migracao pra saves que ainda tem banco guardado.
	zenkaiReady = world.realtime + 36000 //1-hour realtime cooldown
	zenkaiWarn = world.realtime + 600 //don't nag about cooldown for ~1 min after a grant (a KO then the killing blow in one sequence)

//Player-facing Zenkai notice, scaled to how big the surge was RELATIVE to current base BP (gained/BP),
//never a number. `maxed` = the 2x/3x base-BP ceiling was hit, i.e. the largest Zenkai possible.
mob/proc/zenkai_message(gained, maxed)
	var/prop = gained / max(BP, 1)
	if(maxed)
		return "<font color=#ffd24a><b>ZENKAI!</b> Dragged back from the brink of death, your body blazes with the very greatest surge it could ever hold. There is nothing more it could possibly have drawn in; you feel utterly remade.</font>"
	if(prop >= 1)
		return "<font color=#f3c84e><b>ZENKAI!</b> A colossal rush tears through your broken body. Your power swells far past what it was.</font>"
	if(prop >= 0.5)
		return "<font color=#e6bd55><b>Zenkai!</b> A strong surge floods you as you recover, and you rise back notably stronger than before.</font>"
	if(prop >= 0.2)
		return "<font color=#d4b25c>A Zenkai runs through your mending body. You feel meaningfully stronger than you were.</font>"
	return "<font color=#c2a564>A faint Zenkai flickers through you, knitting your body back a touch stronger.</font>"

// ============================================================================
// GANHOS POR LUTAR COM ALGUEM MAIS FORTE (substitui o antigo "leech" de BP)
// Lutar contra um oponente X vezes mais forte multiplica os GANHOS normais de
// spar/luta por X (proporcional ao gap de poder EXPRESSO), com TETO de 2x:
//   oponente 1.2x mais forte -> 1.2x de ganhos;  2x ou mais -> 2x (teto).
// (o piso REAL e 1.0x, nao 1.2x: 1.05x mais forte ja rende 1.05x. O piso de 1.2x
//  existe SO no ramo do mestre, abaixo.)
// Oponente igual ou mais fraco = 1x (nunca reduz abaixo do normal).
// ============================================================================
var/fight_gain_cap = 2 //teto do multiplicador de ganhos por gap de poder
var/master_gain_cap = MST_GAIN_CAP //teto contra o PROPRIO mestre (MasterStudent.dm)

mob/proc/fight_gain_mult(mob/M)
	if(!M || M == src) return 1
	//TREINAR COM O MESTRE (MasterStudent.dm): teto maior e escala pela razao dos BPs
	//BASE -- o expressedBP e distorcido por forma, raiva, supressao, Ki% e KO, e o
	//"mestre 3x mais forte = 3x de ganho" so e estavel comparando o poder de verdade.
	var/mine = max(expressedBP, 1)
	var/theirs = max(M.expressedBP, 1)
	var/geral = min(max(theirs / mine, 1), fight_gain_cap)
	if(mst_is_my_master(M))
		var/r = max(M.BP, 1) / max(BP, 1)
		var/bonus = (r < MST_GAIN_FLOOR) ? 1 : min(r, master_gain_cap) //LINEAR ate o teto
		return max(geral, bonus) //o MAIOR dos dois: ter mestre nunca pode PIORAR o ganho
	return geral

mob/proc/Add_Anger(mult)
	if(!mult)
		mult=1
	if(prob(1*mult)) StoredAnger++
mob/var/tmp
	attacking=0
	finishing=0
	minuteshot
	inregen=0
mob/var
	attackWithCross
	rivalisssj
	StoredAnger=0//maxs out at 100
	hitcountermain=0
	ZTimes=0
	dead=0
	KO=0
	FirstKO=0
	tmp/buudead=0
	CanRegen=0
	unarmedpen=0
	unarmeddam=0
	umulti=0
	ohmulti=0
	dwmult=0.5
	thmult=1.25
	ohmult=1
	tmp/multicounter=0
	tmp/multitimer=0
	tmp/multicooling=0
	countering=0
	list/attackeffects = list()
mob/proc/Blast()
	if(attacking)
		if("Blast" in icon_states(icon))
			flick("Blast",src)
	spawn(3)
		if(flight)
			icon_state="Flight"
mob/proc/Attack_Gain(mult)
	if(!mult)
		mult=1
	mult*=global_spar_gain
	mult*=htc_gain_mult() //Sala do Tempo: 1 dia la = 1 ano de treino (x280; TimeChamber.dm)
	mult*=mind_gain_mult() //Dimensao Mental: ganhos a 1/4 (MindMeditate.dm)
	if(tmp_activ_gains>0)
		mult *= max(1,min(25,tmp_activ_gains/10))
		tmp_activ_gains=max(0,tmp_activ_gains-25)
	if(Planetgrav+gravmult>GravMastered) GravMastered+=(0.00001*(Planetgrav+gravmult)*GravMod*GlobalGravGain)
	if(BP<relBPmax)
		if(BP<10)
			if(KiUnlockPercent==1||prob(50))
				if(prob(1)&&prob(50)) BP += 1
		BP+=capcheck(BPTick*bp_gain_base()*Etechnique*SparMod*Egains*weight*mult) // 1/2 = 20 mins to reach a given cap at 1x and 1 hit/tick
		if(hiddenpotential>=BP)
			BP += capcheck(hiddenpotential*BPTick*(1/6))
		else
			BP += capcheck(hiddenpotential*BPTick*(1/12))
	if(prob(20))
		maxstamina+=0.01*weight

mob/proc/Blast_Gain(mult,ignoreminuteshot)
	if(!mult) mult=1 //o default so era aplicado DEPOIS de bgains usar mult (null zerava o ganho)
	mult*=htc_gain_mult() //Sala do Tempo: ganho multiplicado (TimeChamber.dm)
	mult*=mind_gain_mult() //Dimensao Mental: ganhos a 1/4 (MindMeditate.dm)
	var/bgains = BPTick*bp_gain_base()*Ekiskill*Egains*mult //an hour to hit cap at a rate of 1 shot/tick //made way slower, but when blasts hit you get bp.
	var/kgains = 0.055*BPrestriction*KiMod*baseKiMax/baseKi
	var/amount = bgains
	var/kamount = kgains
	var/gainscale=max(1-(BP/TopBP),0.5)
	if(prob(15))
		gainscale = 1
	if(!mult)
		mult=1
	if(lastdir!=dir)
		missedtrain=0
		lastdir=dir
		spawn(1000)//soft reset
			lastdir=null
			missedtrain=0
	else missedtrain++
	amount /= gainscale*(1+log(max(1,missedtrain)))
	if(missedtrain) tmp_activ_gains++
	else if(tmp_activ_gains>0)
		amount *= max(1,min(25,tmp_activ_gains/10))
		tmp_activ_gains=max(0,tmp_activ_gains-25)
	if(!minuteshot || ignoreminuteshot)
		minuteshot = 1
		minuteshot_ig_ki=1
		spawn(450) minuteshot=0
		amount *= 0.5
		kamount *= 0.15
		if(baseKi<=baseKiMax && kamount)baseKi+=kicapcheck(kamount)
	else if(!ignoreminuteshot)
		minuteshot_ig_ki+=2
		tmp_activ_gains++
		var/detractor = log(1.3,max(2,minuteshot_ig_ki))
		amount *= 0.18 / detractor
		kamount *= 0.2 / detractor
	if(baseKi<=baseKiMax && kamount)baseKi+=kicapcheck(kamount)
	if(train_med_to_hp)
		hiddenpotential+= amount/15
		cap_hp()
	else
		if(BP<relBPmax && amount) BP+=capcheck(amount)