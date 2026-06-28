mob/var/zenkaiStore = 0
mob/var/zenkaiTimer = 0
mob/var/tmp/zenkaiWarn = 0 //world.realtime gate for the 'Zenkai on cooldown' notice (rate-limit + post-grant suppression)
var/zenkaiInjuryFraction = 0.45 //share of body parts that must be Broken/lopped to count as "extremely injured" (bumps a defeat's Zenkai to 15% of the foe's BP and a 3x-base-BP ceiling)
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
//death_stuff (Murder.dm) so both routes obey the same reward: 10% of the foe's BP, capped at 2x your own (base) BP,
//once per hour, Saiyan-DNA only. If your body is extremely injured at that moment (large part Broken or ripped off),
//the brush with death squeezes out more: 15% of the foe's BP and a higher 3x-base-BP ceiling.
mob/proc/gain_zenkai(enemyBP)
	if(!enemyBP || enemyBP <= BP) return //only a stronger enemy triggers Zenkai
	if(dead) return
	if(!has_zenkai()) return //Saiyan DNA only
	if(world.realtime < zenkaiReady) //the 1h cooldown is still ticking (realtime = wall-clock, survives logout/reboot)
		if(client && world.realtime >= zenkaiWarn) //defeated by a stronger foe but Zenkai isn't recharged yet -> warn (rate-limited)
			zenkaiWarn = world.realtime + 300
			var/left = max(zenkaiReady - world.realtime, 0)
			var/mins = round(left / 600)
			var/cdtxt = (mins >= 1) ? "give it roughly [mins] more minute(s)" : "barely a moment more"
			to_chat(src, "<font color=#b07a38>Your body reaches for a Zenkai, but it hasn't recovered from the last one and refuses to surge again so soon ([cdtxt]).</font>", "combat")
		return
	var/pcnt = 0.1 //10% of the foe's BP...
	var/capmult = 2 //...capped so one Zenkai never banks more than 2x your own base BP
	if(extremely_injured())
		pcnt = 0.15 //battered to the brink -> 15% of the foe's BP...
		capmult = 3 //...and a higher 3x base-BP ceiling
	var/raw = pcnt*enemyBP //10%/15% of the foe's BP
	var/cap = BP*capmult //ceiling: 2x/3x your own base BP -- the MOST a single Zenkai can bank
	zenkaiStore += min(raw, cap) //bank the RAW amount; the relBPmax-respecting cap is applied later (Stats.dm). Do NOT wrap in capcheck.
	zenkaiReady = world.realtime + 36000 //1-hour realtime cooldown
	zenkaiWarn = world.realtime + 600 //don't nag about cooldown for ~1 min after a grant (a KO then the killing blow in one sequence)
	if(client) to_chat(src, zenkai_message(min(raw, cap), raw >= cap), "combat") //notice scales with gained/baseBP; max-tier when the ceiling binds; no numbers

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
	if(tmp_activ_gains>0)
		mult *= max(1,min(25,tmp_activ_gains/10))
		tmp_activ_gains=max(0,tmp_activ_gains-25)
	if(Planetgrav+gravmult>GravMastered) GravMastered+=(0.00001*(Planetgrav+gravmult)*GravMod*GlobalGravGain)
	if(BP<relBPmax)
		if(BP<10)
			if(KiUnlockPercent==1||prob(50))
				if(prob(1)&&prob(50)) BP += 1
		BP+=capcheck(BPTick*relBPmax*Etechnique*SparMod*Egains*weight*mult) // 1/2 = 20 mins to reach a given cap at 1x and 1 hit/tick
		if(hiddenpotential>=BP)
			BP += capcheck(hiddenpotential*BPTick*(1/6))
		else
			BP += capcheck(hiddenpotential*BPTick*(1/12))
	if(prob(20))
		maxstamina+=0.01*weight

mob/proc/Blast_Gain(mult,ignoreminuteshot)
	var/bgains = BPTick*relBPmax*Ekiskill*Egains*mult //an hour to hit cap at a rate of 1 shot/tick //made way slower, but when blasts hit you get bp.
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