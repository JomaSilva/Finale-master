/datum/skill/tree/saibaman
	name="Saibaman Racials"
	desc="Given to all Saibamen at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Saibamen")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
		new/datum/skill/general/selfdestruct,new/datum/skill/namek/SaibaPUNCH,new/datum/skill/saiba/devious,new/datum/skill/saiba/Acid_Spit,new/datum/skill/saiba/growth)

/datum/skill/saiba/Acid_Spit
	skilltype = "misc"
	name = "Acid Spit"
	desc = "Vomit a projectile of poison damage towards a foe. The person it hits will become inflicted with short term poison damage."
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	after_learn()
		assignverb(/mob/keyable/verb/Acid_Spit)
		savant<<"You feel poisonous"
	before_forget()
		unassignverb(/mob/keyable/verb/Acid_Spit)
		savant<<"Your poison fades..."
	login()
		..()
		assignverb(/mob/keyable/verb/Acid_Spit)

/datum/skill/saiba/growth
	skilltype = "misc"
	name = "Growth Spurt"
	desc = "A Saibaman never stops growing. And whenever they grow, their power increases, just a little bit. Use this verb to gain some physical age, but a massive temporary energy increase in exchange. KiMod+"
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	after_learn()
		savant.genome.add_to_stat("Energy Level",0.5)
		assignverb(/mob/keyable/verb/Growth_Spurt)
		savant<<"You feel ready to grow even further! You've learned Growth Spurt!"
	before_forget()
		savant.genome.sub_to_stat("Energy Level",0.05)
		unassignverb(/mob/keyable/verb/Growth_Spurt)
		savant<<"Your intent to grow lessens."
	login()
		..()
		assignverb(/mob/keyable/verb/Growth_Spurt)

mob/keyable/verb/Growth_Spurt()//extreme fuckin shanagians here.
	set category = "Skills"
	switch(input(usr,"This will cost you a month of age, in exchange you will gain roughly two times you Max Ki and get some gains to boot.") in list("Yes","No"))
		if("Yes")
			if(IsAVampire||immortal||biologicallyimmortal||dead||DeathRegen<2)
				usr << "You have some circumstance blocking you from using this! (Immortal, dead, or large amounts of Death Regeneration.)"
				return
			Age+=0.1
			Ki+=MaxKi*2
			Attack_Gain(5)
/datum/skill/saiba/devious
	skilltype = "misc"
	name = "Devious"
	desc = "As a Saibaman, you're naturally crafty. Gain some Technique and the ability to use some... underhanded methods. (Rock Paper Scissors, which punishes the opponent depending on conditions.) Tech+"
	can_forget = TRUE
	common_sense = TRUE
	teacher = TRUE
	tier = 2
	skillcost=2
	var/tmp/rps
	after_learn()
		savant.techniqueBuff+= 0.5
		assignverb(/mob/keyable/verb/Rock_Paper_Scissors)
		savant<<"You feel mischievous"
	before_forget()
		savant.techniqueBuff-= 0.5
		unassignverb(/mob/keyable/verb/Rock_Paper_Scissors)
		savant<<"Your intent to cause mischief fades..."
	login()
		..()
		assignverb(/mob/keyable/verb/Rock_Paper_Scissors)
mob/keyable/verb/Rock_Paper_Scissors()
	set category = "Skills"
	var/datum/skill/saiba/devious/S = locate(/datum/skill/saiba/devious) in learned_skills
	if(S && S.rps)
		switch(S.rps)
			if(1)//Rock
				if(target in view(2))
					step_towards(src,target)
					step_towards(src,target)
					if(!target.attacking) src.doAttack(M=target,addeddamage=10)
					else src.doAttack(M=target)
			if(2)//Paper
				if(target in view(2))
					step_towards(src,target)
					step_towards(src,target)
					if(target.attacking) src.doAttack(M=target,addeddamage=10)
					else src.doAttack(M=target)
			if(3)//Scissors
				if(target in view(2))
					step_towards(src,target)
					step_towards(src,target)
					if(target.blocking) src.doAttack(M=target,addeddamage=10)
					else src.doAttack(M=target)

		S.rps = 0

	else
		var/n = input(usr,"Type 1, 2, or 3. The next time you use this verb, it'll use either Rock, Paper, or Scissors. Rock punishes players who aren't attacking. Paper punishes players who are. Scissors punishes players who are blocking.") as num
		n = min(3,n)
		n = max(1,n)
		n = round(n)
		S.rps=n



/datum/skill/namek/SaibaPUNCH
	skilltype = "Ki"
	name = "Falcon Punch!"
	desc = "FALCON.... PAWUNCH!!!"
	can_forget = FALSE
	common_sense = TRUE
	teacher = TRUE
	tier = 2
	skillcost=2
	after_learn()
		assignverb(/mob/keyable/verb/Falcon_Punch)
		savant<<"You feel fire in your hands!"
	before_forget()
		unassignverb(/mob/keyable/verb/Falcon_Punch)
		savant<<"Your firey hands fade..."
	login()
		..()
		assignverb(/mob/keyable/verb/Falcon_Punch)

mob/keyable/verb/Falcon_Punch()
	set category = "Skills"
	var/mob/target
	for(var/mob/M in get_step(usr,usr.dir))
		target = M
		break
	if(ismob(target) && target.attackable)
		var/kireq=4*usr.Ephysoff*(maxstamina/100) //BaseDrain problem with basedrain is that it scales with Ki, if you're switching things to drain directly stamina, don't use this.
		if(!usr.med&&!usr.train&&!usr.KO&&usr.stamina>=kireq&&!usr.basicCD&&usr.canfight)
			usr.basicCD+=30
			view(usr)<<output("<font size=[usr.TextSize+1]><font color=red><font face=Old English Text MT>-[usr] yells, 'FALCON...!'","Chatpane.Chat")
			emit_Sound('chargepn.wav',2)
			sleep(10)
			view(usr)<<output("<font size=[usr.TextSize+1]><font color=red><font face=Old English Text MT>-[usr] yells, 'PUUUUUUUNCH!!'","Chatpane.Chat")
			emit_Sound('falcon.wav',2)
			emit_Sound('thud.wav',2)
			usr.stamina-=kireq
			usr.move = 1
			var/base=Ephysoff*8 * globalmeleeattackdamage
			var/phystechcalc
			var/opponentphystechcalc
			if(Ephysoff<1||Etechnique<1)
				phystechcalc = Ephysoff*Etechnique
			if(target.Ephysoff<1||target.Etechnique<1)
				opponentphystechcalc = target.Ephysoff*target.Etechnique
			var/dmg=DamageCalc((phystechcalc),(opponentphystechcalc),base)
			damage_mob(target,dmg*BPModulus(usr.expressedBP,target.expressedBP))
			usr.BP+=usr.capcheck((target.BP/550)*(rand(1,10)/3))
			target.BP+=target.capcheck((usr.BP/550)*(rand(1,10)/3))
			spawn spawnExplosion(target.loc,strength=usr.expressedBP/2)