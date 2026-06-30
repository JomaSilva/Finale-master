
mob/var
	BP = 1 //REAL BP
	BPMod = 1 //Multiply/Divide this.

	BPadd = 0 //When you want to add on to BP, but not actually affect real BP.
	BPBuffer = 0//Built up gains so that RP doesn't make you forever behind
	Gaintimer = 0//Set whenever capcheck is called to see if the player has gained recently
	Buffertimer = 0//Counter for how long you've been accumulating gains

	PowerPcnt = 100
	KaioPcnt = 1
	HellstarBuff = 1
	expandBuff = 1
	ssjBuff = 1
	transBuff = 1
	giantFormbuff = 1
	formsBuff = 1 //eventually this will replace all above that are buffs that take up the 'form' slot.
	buffsBuff = 1 //eventually this will replace all above that are buffs that take up the 'buff' slot.
	aurasBuff = 1 //eventually this will replace all above that are buffs that take up the 'aura' slot.
	gravFelt = 1 //this var is for gravity calculation, determined by planet gravity alone. needs seperate var because in planet grav case 1=0 (earth grav = 1). When moons/space stuff is introduced,
	//this variable will need to be written out, will not be the bare minimum gravity. Bare minimum gravity always needs to set gravFelt to 0 for grav equations to make sense.
	splitformdeBuff //debuffs player depending on splitform count

	kicapacity = 1.25//this is the var that directly determines if you are being hurt by the amount of ki you have concentrated in yourself.

	bgains = 1 //ADD OR SUBTRACT THIS. Manipulates player gains.

	MagAdd = 0

	powerupcap = 1.6//for Power Up buff
	haspupunderlay //store if icon is being used here
	pupunderlay //store icon itself here

	staminadeBuff=1 //debuff w/ stamina, only becomes really apparent late when stamina is in low 20s.

	tmp
		powerMod = 1
		gateBuff = 1
		powerModTarget = 1
//		kiBuff
		buffBuff
		deBuff
		statusBuff
		angerBuff
		gravBuff
		formBuff
		OozaruBuff = 1
		fusionBuff
		ArtifactsBuff = 1
		netBuff //sum of variable buffs - not including constants like gravity or form
		nnetBuff = 1
		expressedBP
		relBPmax
		tBPmax
		tailgain = 1
		kiratio
		hpratio
		staminaratio
		expressedAdd = 0 //when you want to add directly to expressed BP.
		peakexBP //if, say, you want to check what the expressedBP of a regener minus health loss.
		being_supressed = 0//based off of equalizer fields.
		tgains = 1 //ADD OR SUBTRACT THIS. Temporarily manipulates player gains.
		Egains = 1 //expressed gains mult. Seems we have one too many things affecting gains, mind as well keep them here.
		regionalGains = 1 //gains affected by region, must always remain a tmp variable, currently only used in Gravity.dm for the makyo star.
		TMagAdd = 0
		breakpowerloop //for power control
		ispoweringdown //for power control


//POWER EQUATIONS GOGOGO
mob/proc/powerlevel()
	set waitfor = 0
	if(BP==0)return
	CHECK_TICK
	kiratio = max((Ki/MaxKi),0.6)
	hpratio = max((HP/100),0.6)
	CHECK_TICK
	staminaratio = max((staminadeBuff/100),0.3)
//	kiBuff = kiBuff //all universal power modifiers
	buffBuff = expandBuff * giantFormbuff * buffsBuff * ArtifactsBuff * eyeBuff//buff chunk 1, gets capped
	CHECK_TICK
	formBuff = ssjBuff * transBuff * formsBuff * gateBuff * HellstarBuff//buff chunk 2 does not get capped
	CHECK_TICK
	deBuff = 1/max((weight*BPrestriction*splitformdeBuff),1) //anything in the divisor
	statusBuff = (kiratio*hpratio*staminaratio) //Ki overcharge is now PURELY LINEAR: Ki% == multiplier (100%=1x, 200%=2x, 300%=3x...). Was max(kiratio, min(kiratio**powerMult,2)) which inflated the 100-200% band (150%->1.66x, 175%->2x) before going linear above 200%. (hpratio/staminaratio still modulate when hurt/tired; at full HP/stamina the Ki bonus == Ki% exactly.)
	fusionBuff = max(FuseDanceMod * FPotaraMod,1)
	CHECK_TICK
	angerBuff = min(Anger/100, 2 + legendaryAngerBonus/100) //anger -> BP multiplier, CAPPED at 2x (or 3x for LSSJ with the Legendary Anger skill: legendaryAngerBonus=100 -> +1x). Was uncapped (Anger/100, up to MaxAnger/100), so boosted rage stacked to ~4x+ and ballooned BP on top of the Ki overcharge (the "rage + 230% Ki -> 10x" the player saw was rage, not Ki)
	gravFelt = 1
	gravFelt = GravMastered/max(1,(Planetgrav+gravmult))
	expressedAdd =  HVBPExpAdd + MagAdd + TMagAdd
	CHECK_TICK
	if(gravFelt>1)
		gravFelt = log(gravFelt)
		gravFelt = gravFelt**2
		if(gravFelt==0) gravFelt = 1
		else
			gravFelt/=(40*gravBalance)
			gravFelt+=1
	else
		gravFelt = 1 / (((-log(gravFelt)**1.6)/10)+1) //much kinder. at 1/1000th grav mastery compared to grav felt, expressed BP is halved. Can be buffed by raising the exponent to a even power.
		//don't make the exponent another decimal though other than 1.2 and 1.6 if you don't know what you're doing.
	gravBuff=gravFelt
	CHECK_TICK
	netBuff =  deBuff * statusBuff * AgeDiv * buffBuff * max(bp_remove,0.01)
	//if(godki && godki.transform_adjust) netBuff *= formBuff
	nnetBuff = netCap(netBuff)
	// base BP calc
	var/tempBP = BP + BPadd + FuseBuff + HVBPAdd + CooldownAmount + majin_absorb_bp
	if(AbsorbDeterminesBP&&AbsorbBP) tempBP = (tempBP + AbsorbBP) / 2
	else tempBP = tempBP + AbsorbBP
	//
	CHECK_TICK
	if(isconcealed&&expressedBP>=5)
		expressedBP = 5
	else
		tempBP += additiveBoost(fusionBuff) //keeps the boosts from multiplying each other. (read: impossible to balance :^))
		tempBP += additiveBoost(MysticPcnt)
		tempBP += additiveBoost(MajinPcnt)
		tempBP += additiveBoost(gravBuff)
		tempBP += additiveBoost(aurasBuff)
		tempBP += additiveBoost(KaioPcnt)
		//tempBP += additiveBoost(buffBuff)
		tempBP += additiveBoost(ParanormalBPMult)
		tempBP *= (BPBoost * formBuff)
		if(godki_gt_mode)
			tempBP *= godki_boost * gt_boost
			if(godki.adjust_me) tempBP *= godki.transform_adjust
		else
			if(godki && godki.usage)
				var/gfm = god_form_mult()
				if(gfm) tempBP *= gfm / max(ssjBuff,1) //God forms set the TOTAL form multiplier (SSJG 22x / Blue-Rose 32x / Evolved 56x), replacing the SSJ factor
				else tempBP *= godki.godki_mult
			if(godki_give_mult && SaiyanLineage != "Primal Saiyan") tempBP *= godki_give_mult //Primal nao recebe o boost de BP do God Ki (o God Ki dele so ativa o SSJ4 Limit Breaker)
		expressedBP = (round(max((tempBP),1) * nnetBuff * angerBuff) + expressedAdd) * powerMod
		if(zeni_revive_debuff_until && world.realtime < zeni_revive_debuff_until) expressedBP = round(expressedBP * 0.25) //debuff do revive por Zeni: BP em 25% por 1h

	relBPmax = BP * (1 + UPMod) * relcaprate //PERSONAL ceiling from own BP+Potential (no server AverageBP). relcaprate = global growth-speed knob.
	//server BPCap clamp removed - individual progression
	relBPmax *= BPMod

	if(HVBPAddEnd) relBPmax = BP

	peakexBP = max(expressedBP / (AgeDiv * deBuff * statusBuff),expressedBP)
	var/relgains = 1 //gains from own training, not closing gap to server average
	if(0) //server-average catch-up removed
		relgains = log(2,relgains)
	relgains = max(min(relgains,10),0.1)
	if(0) //server-average catch-up removed
		relgains *= 2
	Egains = HBTCMod * regionalGains * trainmult * relgains * bgains * tgains * tailgain
	if(isHV && BoostActive && BoostMult) Egains *= BoostMult

	if(!IsCooldownRunning&&!CooldownRunning&&CooldownAmount)
		spawn PowerCooldown()
	if(IsCooldownRunning&&!CooldownRunning)
		spawn PowerCooldown()

mob/var
	IsCooldownRunning
	tmp/CooldownRunning
	CooldownAmount
	tmp/highGainbuffer=0

mob/proc
	additiveBoost(var/boostmult)
		return ((BP * boostmult) - BP)
	capcheck(var/gap)
		if(!relBPmax) return 0
		//world << "DEBUG: gap: [gap]"
		//var/relativity = (1-(BP/relBPmax))
		Gaintimer=50
		Buffertimer=0
		gap *= StamBPGainMod
		//DIMINISHING RETURNS at very high BP: every gain source feeds capcheck a `gap` proportional to relBPmax
		//(which is proportional to BP), so the raw gain scales with BP -> in the billions a single tick adds
		//billions (absurd, esp. with 500x gravity + weights stacked). Above bpGainSoftcap we damp the gain so
		//it stops scaling with BP. strength 1 = gain ~constant past the cap (linear growth); 0.5 = sqrt; 0 = off.
		if(bpGainSoftcap > 0 && bpGainSoftStrength > 0 && BP > bpGainSoftcap)
			gap *= (bpGainSoftcap / BP) ** bpGainSoftStrength
		//world << "DEBUG: gap: [gap]"
		if(BPBuffer)
			if(BPBuffer-gap>0)
				gap+=BPBuffer
				BPBuffer-=gap
			else
				gap+=BPBuffer
				BPBuffer=0
		var/supergains = GainsRate
		var/check = relBPmax-(gap + BP)
		if(0) supergains *= catchupcap //server-average catch-up removed
		/*if(BP < AverageBP/10 && catchupcap > 1) //too unstable, it worked but it works too well.
			highGainbuffer += rand(1,10) * min(AverageBP/BP,5)
			if(highGainbuffer >= 50)
				supergains *= max(1,log(catchupcap,min(AverageBP/BP,20)))
				highGainbuffer -= 25
				highGainbuffer = max(0,highGainbuffer)*/
		if(0) //server-average above-average penalty removed
			supergains /= (BP/AverageBP)**2
		if(check>0)
			return max(min(gap * supergains,(relBPmax-BP)*1.25),0)
		if(check<=0) return max(0,relBPmax - BP)
	PowerCooldown()
		set background = 1
		CooldownRunning = 1
		if(CooldownAmount)
			IsCooldownRunning = 1
			spawn
				while(CooldownAmount >= 1)
					CooldownRunning = 1
					if(CooldownAmount<=0)
						CooldownAmount = 0
						break
					CooldownAmount -= (CooldownAmount/1000)
					sleep(10)
				CooldownRunning = 0
				CooldownAmount = 0
				IsCooldownRunning = 0
		else
			IsCooldownRunning = 0
			CooldownRunning = 0
			return
	netCap(var/stattocap)
		if(stattocap>2)
			var/value = log(max(1.01,global_net_cap),stattocap)
			return min(value,10)
		return stattocap