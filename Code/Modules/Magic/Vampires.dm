//Vampires work off the stamina system.

//if(!usr.CanEat&&Race!="Android") CanEat designates 'normal' food as unconsumable. Need to always cross-check with Android, as Androids also tick the variable.

var/VampireBPMultMax=3.5
var/VampireBPMultMin=1.2
var/VampBiteCooldown=300 //300 seconds.

mob
	var
		IsAVampire=0
		ParanormalBPMult=1
		tmp/vampcooldown = 0
	proc
		VampBite(var/mob/TargetMob,turnChoice)
			if(src.IsAVampire==0) return FALSE
			if(!vampcooldown&&prob(5))
				vampcooldown = VampBiteCooldown
				ParanormalBPMult += 0.1
				stamina += 20
				ParanormalBPMult = max(min(VampireBPMultMax,ParanormalBPMult),1)
				spawn Vamp_Cooldown()
			currentNutrition+= 40
			var/phystechcalc
			var/opponentphystechcalc
			if(Ephysoff<1||Etechnique<1)
				phystechcalc = Ephysoff*Etechnique
			if(TargetMob.Ephysoff<1||TargetMob.Etechnique<1)
				opponentphystechcalc = TargetMob.Ephysoff*TargetMob.Etechnique
			var/dmg=DamageCalc((phystechcalc),(opponentphystechcalc),Ephysoff*3)
			TargetMob.SpreadDamage(dmg*BPModulus(expressedBP,TargetMob.expressedBP)*2,0,null)
			if(turnChoice=="Yes")
				if(TargetMob.HP>=10&&prob(30))
					spawn TargetMob.Vampirification()
			if(TargetMob.HP<5&&murderToggle)
				view(TargetMob) << "[TargetMob] was killed by [usr], the vampire!"
				spawn TargetMob.Death()
			return TRUE
		Vampirification()
			if(IsAVampire==0&&IsAWereWolf==0)
				IsAVampire = 1
				spawn AddExp(usr,/datum/mastery/Hidden/Vampirism,100)
				if(HP<50) SpreadHeal(50)
				else SpreadHeal(100)
				for(var/datum/Body/B in body)
					if(B.lopped) B.RegrowLimb()
					B.health = B.maxhealth
				spawn(10) Ki=MaxKi
				enable_visibility(/datum/mastery/Hidden/Vampirism)
				assignverb(/mob/keyable/verb/Bite)
				//willpowerMod += 0.5
				world << "test"
				ParanormalBPMult += 0.2
				ParanormalBPMult = min(1.2,VampireBPMultMin)
				CanEat = 0
				return TRUE
			else return FALSE
		UnVampire()
			if(IsAVampire)
				IsAVampire = 0
				mastery_remove(/datum/mastery/Hidden/Vampirism)
				if(HP>50) SpreadDamage(50)
				else SpreadDamage(99)
				//willpowerMod -= 0.5
				ParanormalBPMult = 1
				unassignverb(/mob/keyable/verb/Bite)
				CanEat = 1
				return TRUE
			else return FALSE

		Vamp_Cooldown()
			set background = 1
			spawn while(vampcooldown)
				vampcooldown-=1
				if(vampcooldown<=0)
					vampcooldown = 0
					return
				sleep(10)
//Bite is applied to both vampires and werewolves. EXP code for using the verb goes in their respective bite procs
mob/keyable/verb/Bite()
	set category ="Skills"
	var/mob/TargetMob
	for(var/mob/M in get_step(src,dir))
		TargetMob = M
		break
	if(isnull(TargetMob)) return
	if(TargetMob.dead==1)
		usr<<"You can't bite dead people, they lack nutrients."
		return
	if(usr.IsAVampire)
		var/turnChoice = alert(usr,"Turn them?","","Yes","No")
		VampBite(TargetMob,turnChoice)
	else if(usr.IsAWereWolf)
		var/turnChoice = alert(usr,"Turn them?","","Yes","No")
		WolfBite(TargetMob,turnChoice)
	else
		unassignverb(/mob/keyable/verb/Bite)


obj/Artifacts/Blood_Chalice
	//parent_type = /obj/items //This allows obj/Artifact to access ALL procedures and variables of /item.
	name = "Blood Chalice"
	icon = 'Foods.dmi'
	icon_state="Blood Chalice"
	Unmovable = 1

	verb/Drink()
		set category = null
		set src in oview(1)
		if(!usr.IsAVampire&&usr.CanEat&&!usr.IsAWereWolf)
			usr.Vampirification()
			view(usr)<<"[usr] has become a Vampire!!!"
		else
			usr<<"The liquids simply pass through your system. The chalice cannot do anything for you."

obj/Artifacts/White_Chalice
	//parent_type = /obj/items //This allows obj/Artifact to access ALL procedures and variables of /item.
	name = "White Chalice"
	icon = 'Foods.dmi'
	icon_state="White Chalice"
	Unmovable = 1
	verb/Drink()
		set category = null
		set src in oview(1)
		if(usr.IsAVampire&&!usr.CanEat)
			usr.UnVampire()
			view(usr)<<"[usr] has been cured of Vampirism!!!"
		else
			usr<<"The liquids simply pass through your system. The chalice cannot do anything for you."