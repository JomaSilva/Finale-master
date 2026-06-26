proc/DamageCalc(upscalar, downscalar, basedamage, maxdamage) //'var/' is implicit
			//maxdamage is purely optional and placed at the end for this reason
	if(!downscalar)
		downscalar=1 //kept getting division by 0 errors, so I put this in -assfaggot
	var/calc=(upscalar/downscalar)*basedamage
	if(maxdamage) return min(calc,maxdamage)
	else return calc

mob/proc/NormDamageCalc(mob/M)
	var/base = 1 * globalmeleeattackdamage
	var/dmg=2
	var/phystechcalc
	var/opponentphystechcalc
	//if(Ephysoff<1||Etechnique<1)
	phystechcalc = Ephysoff+(Etechnique/1.25)
	//else
	//phystechcalc = log(3,(Ephysoff**2)*log(3,(Etechnique)))+2
	//if(M.Ephysoff<1||M.Etechnique<1)
	opponentphystechcalc = M.Ephysdef+(M.Etechnique/1.25)
	//else
		//opponentphystechcalc = log(3,(M.Ephysoff**2)*log(3,(M.Etechnique)))+2
	return dmg=DamageCalc((phystechcalc),(opponentphystechcalc),base)

proc/ArmorCalc(var/damage, var/armor, var/truearmor)
	switch(truearmor)
			//truearmor = "reduces damage proportional to armor calc" = 1
			//falsearmor = "tests to see if damage is sufficiently high" = 0
		if(TRUE)
			if(armor == 0) return damage
			else
				return damage * (1 - (armor / 2))
			//armor = armor / 100
			//armor = 1 / (1.7 * armor + 1) //at 99% armor, reduces damage to 0.336x
			//return max(damage * armor,0) + (damage * (1/5))
		if(FALSE)
			if(damage>armor) return damage
			else return 0
// Tunable clamp on how much a BP difference swings combat (damage, hit chance, knockback).
// Was a piecewise linear-then-exponential curve with an UNBOUNDED strong side (a 10x stronger
// fighter dealt 10x, etc.) plus a weird >2x-weaker "floor of 1.0" cliff. Now a single linear
// ratio clamped both ends, so the BP gap maps to combat power smoothly and predictably.
var/bpmod_min = 0.2 //floor: even a far weaker attacker still lands ~20% (no zero-damage)
var/bpmod_max = 5   //ceiling: a far stronger attacker tops out at 5x (prevents one-shot blowouts)
proc/BPModulus(var/yourBP, var/theirBP)
	if(ismob(yourBP))
		var/mob/nM  = yourBP
		yourBP = nM.expressedBP
	if(ismob(theirBP))
		var/mob/nM  = theirBP
		theirBP = nM.expressedBP
	if(!yourBP||!theirBP) return 1
	if(theirBP==0) return 999
	if(yourBP==0) return 0
	return max(min(round((yourBP/theirBP),0.05),bpmod_max),bpmod_min) //linear, clamped both ends

mob/var
	deflection = 0
	damage = 0
	penetration = 0
	accuracy = 0
	hitspeedMod = 1
	block = 0
	blockmod = 1

mob/proc/attackCalcs(var/mob/M,var/addeddamage,var/vampdamage,var/isBarrage,Type)
	var/dmg
	if(isnull(M)||M==src) return
	//
	if(!M.Ephysoff||!M.Ephysdef||!M.Etechnique||!M.Espeed||!M.BP)
		return//safety check, attack keeps crashing with null values when npcs attack
	for(var/I, I <= args.len, I++)
		I = max(1,I)
		switch(I)
			if(1) M = args[1]
			if(2) addeddamage = args[2]
			if(3) vampdamage = args[3]
			if(4) isBarrage = args[4]
			if(5) Type = args[5]
		if(I > 5) break
	dmg=NormDamageCalc(M)
	dmg=Resistance(dmg,M,1)
	if(isnum(addeddamage)) dmg += addeddamage
	if(isBarrage) dmg /= isBarrage
	if(dashing) dmg += 2
	dmg+=compareStyles(M)
	dmg+=damage//flat damage from weapons
	if(dmg<1)dmg=1 //minimum 1 damage
	if(M.dashing) dmg*=1.25
	if(dir == M.dir) dmg*=1.5
	dmg += Type
	if(M.IsAVampire||M.IsAWereWolf)
		if(isnum(vampdamage)) if(vampdamage) dmg *= vampdamage
		if(attackWithCross) dmg *= 2
	else if(dir == turn(M.dir, 45)||dir == turn(M.dir, -45)) dmg*=1.4
	else if(dir == turn(M.dir, 90)||dir == turn(M.dir, -90)) dmg*=1.2
	if(weaponeq)
		dmg*=1+(weaponry/200)
		if("Sword" in WeaponEQ)
			dmg*=1+(swordskill/(200*weaponeq))
		if("Axe" in WeaponEQ)
			dmg*=1+(axeskill/(200*weaponeq))
		if("Staff" in WeaponEQ)
			dmg*=1+(staffskill/(200*weaponeq))
		if("Spear" in WeaponEQ)
			dmg*=1+(spearskill/(200*weaponeq))
		if("Club" in WeaponEQ)
			dmg*=1+(clubskill/(200*weaponeq))
		if("Hammer" in WeaponEQ)
			dmg*=1+(hammerskill/(200*weaponeq))
	if(!globalmeleeantispeed) globalmeleeantispeed = 1
	dmg *=  min(((globalmeleeantispeed * Eactspeed)/10),1) //speed nerf- lower speeds equals higher damage.
	dmg /= ((Etechnique*2 + Ephysdef*2)/10)//technique nerf- will start subtracting damage and a defense nerf- will also start subtracting damage.
	return dmg
mob/proc/AccuracyCalc(var/mob/M)
	if(!M)
		return 0
	else
		var/hit = (Etechnique/M.Espeed)*BPModulus(expressedBP,M.expressedBP)*100-M.deflection+accuracy//two perfectly matched players will hit 100% of the time
		//var/crit = (Espeed/M.Etechnique)*BPModulus(expressedBP,M.expressedBP)//1% crit chance on perfectly matched players
		//var/counter = (M.Etechnique/Espeed)*BPModulus(M.expressedBP,expressedBP)//1% counter chance, essentially a critical dodge
		if(M.KO||M.med||M.train||!M.mobTime)
			hit = 100
		if(prob(hit))
			//if(prob(crit))
			//	return 3 //crit confirmed
			//else
			//	return 2 //just a hit
			return 2
		else
			//if(prob(counter))
			//	return 1 //countered
			//else
			return 0 //miss
var/leechSelfCap = 0.01 //per-hit leech is capped to this fraction of YOUR OWN BP (not the victim's). Tunable.
mob/proc/Leech(var/mob/M)
	if(client)
		if(M.client)
			if(M.BP>BP*1.2&&!M.BP_Unleechable&&BP<relBPmax) //gate: only leech while the foe is still >20% stronger (the gap "earns" it); once you close the gap it stops
				var/lgain = capcheck(log(UPMod*SparMod)*(M.BP/7000)*(rand(1,10)/4))
				if(isHV && BoostActive && BoostMult) //essentially, if H/V system active, and conditions are met, at least double gains.
					if(isnull(BoostTarget))
						if(HVAlign && BoostTargMultiple) if(HVAlign != M.HVAlign) lgain+=capcheck(BoostMult*(M.BP/550)*(rand(1,10)/3))
						else lgain+=capcheck(BoostMult*(M.BP/550)*(rand(1,10)/3))
					else if(BoostTarget == M.signature)
						lgain+=capcheck(BoostMult*(M.BP/550)*(rand(1,10)/3))
				BP += min(lgain, BP*leechSelfCap) //CAP: a single leech hit can never exceed leechSelfCap of your own BP, so it scales off you, not the (much stronger) victim
			if(M.GravMastered>GravMastered&&!M.BP_Unleechable&&GravMastered<gravitycap)
				GravMastered+=(M.GravMastered-GravMastered)*(1-(GravMastered/M.GravMastered))*0.05*GlobalGravGain
			if(M.godki && godki && M.godki.tier >= godki.tier)
				train_godki(M.godki.tier)
		else
			if(M.BP>BP*1.2&&!M.BP_Unleechable&&Leeching&&M.canbeleeched&&BP<relBPmax)
				Train_Gain(8*dungeonGains)

mob/proc/Damage(var/mob/M,var/dmg,type)
	var/punchrandomsnd
	var/ntp = min(3,type + min(1,combo_count))
	switch(ntp)
		if(1)
			punchrandomsnd=pick('ARC_BTL_CMN_Hit_Small-A.ogg','ARC_BTL_CMN_Hit_Small-B.ogg','hit_s.wav','weakkick.wav')
		if(2)
			punchrandomsnd=pick('ARC_BTL_CMN_Hit_Midle-A.ogg','punch_med.wav','mediumpunch.wav','mediumkick.wav','hit_m.wav')
		if(3)
			punchrandomsnd=pick('ARC_BTL_CMN_Hit_Large-A.ogg','punch_hvy.wav','hit_l.wav','strongkick.wav','strongpunch.wav')
	updateOverlay(/obj/overlay/effects/flickeffects/attack)
	o_emit_Sound('meleeflash.wav')
	emit_Sound_to(punchrandomsnd,M)
	emit_Sound_to(punchrandomsnd,usr)
	damage_mob(M,dmg)

mob/proc/damage_mob(mob/M,dmg)
	dmg = ArmorCalc(dmg, M.Esuperkiarmor, TRUE)
	if(M.Esuperkiarmor) M.damage_armor(dmg)
	M.DamageLimb(dmg,src.selectzone,src.murderToggle,src.penetration)

proc/damage_m(mob/M,dmg,selectzone,murderToggle,penetration,armorscaler = TRUE)
	dmg = ArmorCalc(dmg,M.Esuperkiarmor,armorscaler)
	if(M.Esuperkiarmor) M.damage_armor(dmg)
	M.DamageLimb(dmg,selectzone,murderToggle,penetration)


mob/proc/damage_armor(dmg)
	superkiarmor -= max((dmg * (superkiarmor / 100)),1)
		//NOTES:

			//DamageCalc
	//very simple organizational tool- instead of mashing up numbers manually, you have a nice ordered box
	//to put them in. Calculates the ratio of compared stats, yours (upscalar) and theirs (downscalar) or *any other numbers* that
	//may affect damage, and then multiplies the product by an intended base damage.
	//why is this nice?
	//because now you can untether things from stats and bp directly and still get a systematically similar result.

			//ArmorCalc
	//armor not yet implemented in any meaningful way.
	//the final form of damage calculation in objects should look like:
	//var/Damage=DamageCalc([src.stats],[M.stats],[out of 100])
	//Damage = ArmorCalc(Damage,(superarmor*SarmorMod),FALSE)
	//Damage = ArmorCalc(Damage,armor,TRUE)
	//M.HP -= Damage*BPModulus

			//BPModulus
	//if the denominator is zero, cancel out for safety reasons and just give them the FAT DAMAGE.
	//linear equation has a minimum of 0.1 or 10% damage and scales with your ratio.
	//linear equation feeds into a logarithm of base 2 that, while still scaling at a healthy rate,
	//does not overwhelm weaker players so dramatically as the linear equation would.
	//This means a person with 5000 BP hits a person with 2000 BP at 2x instead of 2.5x, and a person with 1000 BP at
	//2.75x instead of 5x. While BP will still be a principle deciding factor, in this way a person with very targeted & high stats
	//can still possibly compete with people who are substantially stronger.
	//if strong people don't feel strong enough, drop the logarithm's cofactor down to something below 2 and calculate the 2nd intercept
	//for log(1.8,[calcs]) it would be (theirBP/yourBP)<=2.672, for example.
	//- this is a bit confusing, so for non math fags, go into desmos and type log'shift + _'x + 1 for the first line
	//then just type x for a second line
	//your first and second intercepts will be shown as points intercepting the x line.
////////////////////////
//ADDITIONAL EQUATIONS//
////////////////////////
//Drain Calc
mob/var/tmp/BaseDrain = 1
mob/var/tmp/DrainMod = 1 //option to modify base drain without fucking the other bits
mob/var/PDrainMod = 1//for permanent drain changes
mob/proc/BaseDrain()
	var/num = max(MaxKi,1)
	BaseDrain = sqrt(num/140)*PDrainMod*globalKiDrainMod*DrainMod / log(9,max(kiefficiencyskill,5))
//After a certain max ki, small drains don't do shit. Hopefully this helps with that.