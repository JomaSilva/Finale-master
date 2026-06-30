mob
	move_delay = 0.5
	var
		totalskillpoints = 1
		skillpoints = 1
		skillpointMod = 1
		physoff = 1
		physdef = 1
		technique = 1
		kioff = 1
		kidef = 1
		kiskill = 1
		speed = 1
		magiskill = 1
		baseAnger = 1
		maxstamina = 100 //max stamina
		stamina = 100 //current stamina, set to default max

		lastgain = 1
		//multipliers
		//stats
		physoffMod = 1
		physdefMod = 1
		techniqueMod = 1
		kioffMod = 1
		kidefMod = 1
		kiskillMod = 1
		speedMod = 1
		magiMod = 1
		//
		kiregenMod=1
		basekiregen=1
		kicapacityMod = 1

		//for transformations and the like that affect energy- you're changing this mod...
		trueKiMod = 1
		//The reason why I seperate these is to prevent any loss of data that might be possible through the various procs that
		//affect transformations.


		//Add and subtract these. Despite the mod in front. (It's confusing, yes.)
		TwillpowerMod=1
		Ewillpower=1
		willpowerMod=1 //affects HP/Ki regen and stat decreases due to hunger and energy loss -Not 'stylable' but rare things can increase this.
		staminadrainMod = 1 //affects how much stamina is drained by activities.
		staminagainMod = 1 //affects how much max stamina is got from rare cases of stamina training.
		satiationMod = 1 //affects how much eating replenishes stamina.
		mana_cap_mod = 1
		angerMod = 1
		//addition/subtraction
		physoffBuff = 0
		physdefBuff = 0
		techniqueBuff = 0
		kioffBuff = 0
		kidefBuff = 0
		kiskillBuff = 0
		speedBuff = 0
		magiBuff = 0

		HPregenbuff = 1
		//
		kiarmor=0
		//ki armor in general is a 'global' damage -reduction- (not elimination) based on your ki. as you get hit.
		//superkiarmor is used as this. buut it decreases every time its used based on the damage, to which it slowly increases again to at least your 'ki armor' level, your mod helps with how much oomph is there
		superkiarmor=0
		superkiarmorMod=1

		actspeed = 20 //standard action speed = 20 where 20 is 2 seconds

		knockback = 1 //knockback toggle

		concealeddeBuff=1 //concealing debuffs your ki regen
		concealedBuff=1 //but buffs your passive stamina decreases.

		//for gates/consequences. this can be built back up.
		kicapacity_remove = 1 //mult, 0.01 would make max ki 1% what it was.
		phys_remove = 1 //same as above, for phys
		bp_remove = 1 //again, same as above, for overall bp.

		tmp
			staminapercent = 1 //percentage of maxstamina and current stamina.
			statstamina //stats stop being affected at 80% stamina debuff to prevent brokage

			//Temporary boosts - last until (at least) logoff or what have ye (cannot last past logoff) -
			Tphysoff = 1
			Tphysdef = 1
			Ttechnique = 1
			Tkioff = 1
			Tkidef = 1
			Tkiskill = 1
			Tmagi = 1
			Tmagimon = 1
			Tspeed = 1
			Tkiregen = 1
			THPregen = 1
			TMaxKi = 1
			//Raw stats, to separate your number from the scaled value
			Rphysoff = 1
			Rphysdef = 1
			Rtechnique = 1
			Rkioff = 1
			Rkidef = 1
			Rkiskill = 1
			Rmagiskill = 1
			Rspeed = 1
			//
			Ephysoff=1
			Ephysdef=1
			Etechnique=1
			Ekioff=1
			Ekidef=1
			Ekiskill=1
			Epspeed = 1 //your final - but relative- movement speed.
			Espeed = 1//your personal speed stat, not affected by others, but affects Epspeed.
			Emagiskill=1
			Estaminamod = 1
			speedDIFF = 1 //When fighting a very stronk ass player, your movement and combat speed will take hits based off of this.
			KIregen
			HPregen=0
			Eactspeed //calculates real action speed
			Esuperkiarmor //first armor variable
			dashingMod //for speedy.dm dashing status
			MagicCap = 2000
			omegastun //adminstrative-level stun. Use this if you don't want your player to be doing things in a menu or something.
			hdnptltoBP = 1
			//spdcheck = 0//stop speed from infinitely increasing in combat, wew

mob/proc/statify()
	set waitfor = 0
	CHECK_TICK
	if(BP==0) return
	staminapercent = max(stamina,1)/maxstamina
	statstamina = max(min(1,staminadeBuff),0.8)
	if(staminapercent<= 0.05 && !dead) maxstamina += abs((0.0001*Estaminamod)) //passive slow increase in stamina when its low.
	maxstamina = min(200 * abs(Estaminamod),maxstamina)//cap it to a sensible level
	if(isconcealed)
		concealeddeBuff=0.5
		concealedBuff=1.5
	else
		concealeddeBuff=1
		concealedBuff=1
	Ewillpower= max(TwillpowerMod * willpowerMod,0.1)
	Estaminamod = staminagainMod*staminadrainStyle*satiationMod*Ewillpower
	Rspeed = (max(speed,0.1)*max(speedMod,0.1) + max(speedBuff*Tspeed,0.1))*speedStyle*min(max(staminapercent*Ewillpower,0.75),1)
	Espeed = statCap(Rspeed)
	if(!IsInFight)
		speedDIFF = 1
	if(dashing)
		dashingMod=1
		dashingMod=1 / (Espeed + 1)
	else dashingMod=1
	splitformdeBuff=min((1+splitformMastery)/(1+splitformCount),1)
	// news stats are calculated like this: ((base * mod) + buff) * everything else
	Rphysoff = (max(physoff,0.1)*max(physoffMod,0.1) + max(physoffBuff+Tphysoff,0.1)) * physoffStyle*min(max(statstamina*Ewillpower,0.6),1)*max(0.01,phys_remove)//offence/defence will suffer at low stamina. it also grows with expressed BP, but it is NOT TRAINABLE.
	Rphysdef = (max(physdef,0.1)*max(physdefMod,0.1) + max(physdefBuff+Tphysdef,0.1)) * physdefStyle*min(max(statstamina*Ewillpower,0.6),1)
	Rtechnique = (max(technique,0.1)*max(techniqueMod,0.1) + max(techniqueBuff+Ttechnique,0.1)) * techniqueStyle
	Rkioff = (max(kioff,0.1)*max(kioffMod,0.1) + max(kioffBuff+Tkioff,0.1)) * kioffStyle*min(max(statstamina*Ewillpower,0.6),1)
	Rkidef = (max(kidef,0.1)*max(kidefMod,0.1) + max(kidefBuff+Tkidef,0.1)) * kidefStyle*min(max(statstamina*Ewillpower,0.6),1)
	Rkiskill = (max(kiskill,0.1)*max(kiskillMod,0.1) + max(kiskillBuff+Tkiskill,0.1)) * kiskillStyle
	Rmagiskill = (max(magiskill,0.1)*max(magiMod,0.1) + max(magiBuff+Tmagi,0.1))*Tmagimon * magiStyle
	//
	if(kiarmor && superkiarmor <= kiarmor * globalkiarmormod)
		superkiarmor++
	Esuperkiarmor = min(max((superkiarmor*superkiarmorMod),0),100)//keep between 0 and 100
	//
	Ephysoff = statCap(Rphysoff) //it's far too easy to get above 10 with a stat with a insane amount of skills. Solution? Cap 'em dynamically.
	Ephysdef = statCap(Rphysdef)
	Etechnique = statCap(Rtechnique)
	Ekioff = statCap(Rkioff)
	Ekidef = statCap(Rkidef)
	Ekiskill = statCap(Rkiskill)
	Emagiskill = statCap(Rmagiskill)
	Epspeed = (Espeed/(speedDIFF*dashingMod))
	Eactspeed = min(max(actspeed/max(log(10,max(log(10,max((((log(10.15,Espeed)**2)+1)*((log(10,max(Ekiskill/2,Etechnique/2.125))**2)+1)*hpratio*kiratio),0.1))*3,1))*4,1),5),22) //testing nerf to Speed. Log(Espeed)**2 + 1 to action speed.
	updateMaxKi() //ki stuff below here
	hdnptltoBP = (max(hiddenpotential,1)/max(BP,1))
	var/hdnptlmod = 1
	if(hdnptltoBP>1)
		hdnptlmod = max(log(4,hdnptltoBP),1) //shouldn't affect other stats, just power up shit. (uub mode)
	MaxAnger=max(120,hdnptlmod*Ewillpower*angerMod*baseAnger) + legendaryAngerBonus //floor so a missing/collapsed baseAnger can't force permanent "Very Angry"; + bonus da skill Legendary Anger (+100 = +1x ao teto, cap 2x -> 3x)
	MaxKi = baseKi*KiMod*kiAmp*trueKiMod*hdnptlmod*max(0.01,kicapacity_remove)*TMaxKi
	kicapacity = 1.3*kicapacityMod*max((MaxKi*max(log(8,max((kicirculationskill/10)*(kigatheringskill/10),1)*KiMod*hdnptlmod*max(Ekiskill,0.1)),1))*OozaruBuff,1.3*MaxKi)
	powerupcap = max((1.4*max(log(7,max((kicirculationskill/10)*(kicontrolskill/10),1)*KiMod*kicapacityMod*hdnptlmod*max(Ekiskill,0.1)),1))*OozaruBuff,1.4) //makes power capacity n shit dynamic.
	KIregen = (kiregenMod*basekiregen*kiregenStyle*trueKiMod*hdnptlmod*Tkiregen*Ekiskill*max(Emagiskill,Etechnique)*(MaxKi/100)*(statstamina*5)*concealeddeBuff*log(10,max(kigatheringskill,10)))/900 //always involves ki skill and bounced over technique or magical skill, whichever is greater
	if(HP>25 && HP < 99.99 && (!combatTag||fastRegen) && (stamina > 0 || currentNutrition > 0)) SpreadHeal(0.001 * Ephysdef * max(staminapercent*10,1) * HPregenbuff * THPregen) //no free passive heal while BOTH starving (0 nutrition) AND out of stamina -- otherwise charging Ki out of combat regenerated the body for free (HealthRegen() is inert because HPregen is always 0, so this is the ONLY passive regen and it had no energy gate)
	if(HP<=25 && (!combatTag||fastRegen) && (stamina > 0 || currentNutrition > 0)) SpreadHeal(0.02 * THPregen) //regen slowly if under 100, but not while both starving and out of stamina
	HP = max(HP,0)
	MagicCap = 2000 * Emagiskill * mana_cap_mod
	if(Magic > MagicCap) Magic -= 1 * log(9,Magic)
	HealthRegen()
	KiRegen()
	BaseDrain()
	if(rand(1,10)==10)AuraCheck()
	//gravity dump
	Grav()
	Grav_Gain()
	//movement stuff
	if(Epspeed < 0)
		Epspeed = 0 //Espeed under 0 should be impossible. Checking shit anyway.
	if(KO&&icon_state == "")
		icon_state = "KO"
	else if(!KO&&icon_state == "KO")
		icon_state = ""
	//godki
	if(godki)
		godki.refresh()
		if(godki.usage)
			KIregen *= (godki.efficiency + (godki.energy / 100))
		else if(godki.tier)
			regen_godki(1)
			if(med) regen_godki(1)
		if(godki.godki_regen_go)
			regen_godki(godki.efficiency)


mob/proc/HealthRegen()
	CHECK_TICK
	if(HP<100&&stamina>=0&&!KO&&(!combatTag||fastRegen)) //hpregen
		SpreadHeal(HPregen*staminapercent*0.1)
		if(immortal) SpreadHeal(HPregen*staminapercent)
		stamina-=(HPregen*staminapercent*2)

	//TEMP LINE FOR TESTERS
	//DO NOT CROSS UNLESS SHIT IS DONE
	/*
Short analysis: because of the mods, there shouldn't (?) be a reason to why the physoff/def is changed during stat conversion.
Most transformations and etc should change the BUFF values not the actual values. <-- note that you ADD and SUBTRACT to Buff, and MULTIPLY and DIVIDE to Mod.
		By segregating them you prevent the loss of any information. ex: 2x physoff *buff* aura -> +5 physoff *buff* technique -> 0.5x physoff *buff* when aura is released -->
		-5 physoff *buff* when technique ends --> permanent loss of 2.5 physoff in the buff value, while with an initial 2, 2 * 2 * 2 * 0.5 * 0.5 = 2 in *mod*
Examples of this shit is already found in the skills Auron already made.
Safe way of converting: Divide the number that the original skill changes by 1,000, and then divide THAT number by 5. Done.
E.G. jar increases end a bunch, approx 500. New values would be approx +=0.1 for it.
KEEP IN MIND THAT THE STAT SYSTEM IS DESIGNED FOR -LOW- STATS. A STR stat of 10 is stupidly huge.

mob/var REPLACE THE BELOW AS IF THEY WEREN'T TRAINABLE, THESE ARE PERM MODIFICATIONS THAT CHANGE YOUR BUILD.
IMPORTANT: INSTEAD OF FUCKING WITH STAT MODS, MOST OF THE TIME A SIMPLE BP BUFF WILL DO.

DONE	Str=1
DONE	Spd=1
DONE	End=1
DONE	Offense=1 hit %, BOTH ARE DEFUNCT DUE TO TECHNIQUE. REPLACE THESE WITH TECHNIQUE INTO ONE VAR. Speed is also a factor in dodging now.
DONE	Defense=1 dodge %
	//see above
DONE	StrMod=1
DONE	SpdMod=1
DONE	EndMod=1
DONE	OffenseMod=1
DONE	DefenseMod=1
	THE BELOW ARE KI RELATED MODS. ONCE KI ATTACKS ARE PORTED/FIXED, THIS WILL BECOME DEFUNCT
	Pow=1 //Ki power. Replace with kioff and/or kioffMod when appropriate.
	Res=1 //Resistance to spiritual attacks, Delet Res and change ResMod into kidefmod.
	ResMod
	PowMod
	*/