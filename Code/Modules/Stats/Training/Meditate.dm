mob/proc/Med_Gain(multi)
	if(BP<relBPmax)
		if(!multi) multi = 1
		if(BP<10)
			if(KiUnlockPercent==1||prob(12))
				if(prob(11)) BP += 1
		var/mult=global_med_gain*multi
		var/amount = capcheck(relBPmax*BPTick*mult*Egains*MedMod*(1/24)) //1/24 = 24 hours to reach a given cap at 1x
		if(train_med_to_hp)
			hiddenpotential+= amount/4
		else BP+= amount
		if(hiddenpotential>=BP)
			BP += capcheck(hiddenpotential*BPTick*(1/30))
		else
			BP += capcheck(hiddenpotential*BPTick*(1/50))
	if(baseKi<=baseKiMax)baseKi+=kicapcheck(0.005*MedMod*BPrestriction*KiMod*baseKiMax/baseKi)

mob/default/verb/Meditate()
	set category="Skills"
	if(!blasting&&!flight&&!KO&&!swim&&!boat)
		if(train)
			Train()
		if(!med)
			usr<<"You begin meditating."
			if(!train&&alert(usr,"Deep meditation? You'll be interrupted by noise but you'll get more gains. This will also consume a little stamina.","","Sure","No.")=="Sure")
				deepmeditation = 1
				train=0
			train=0
			dir=SOUTH
			//canfight=0
			med=1
			icon_state="Meditate"
		else
			usr<<"You stop meditating."
			med=0
			deepmeditation = 0
			//canfight=1
			icon_state=""

mob/proc/medproc() if(client)
	if(med) if(!KO)
		if(powerupsoundon&&beamsoundon&&flysoundon)
			if(deepmeditation)
				if(prob(1)) medruincount+=1
				if(medruincount>=10)
					medruincount=0
					src << "The sounds around you are disrupting your meditation."
					src << "You're pulled out of deep meditation."
					deepmeditation = 0
		if(studyenchant)
			if(studyenchanttimer>0)
				studyenchanttimer--
			else
				usr<<"You've learned how to use the [studyenchant] enchantment!"
				knownenchants+=studyenchant
				studyenchant=""
				studyenchanttimer=0
				AddExp(src,/datum/mastery/Crafting/Enchanting,1000)
		medbal -= 0.01//should take approximately 10 minutes to decay now
		medbal = min(medbal,100)
		medbal = max(medbal,0)
		if(deepmeditation)
			updateOverlay(/obj/overlay/medicon)
			if(winget(usr, "balancewin", "is-visible")=="false")
				winshow(usr, "balancewin", 1)
			else
				winset(usr,null,"balancewin.balbar1.value=[medtargbal];balancewin.balbar2.value=[medbal]")
			stamina -= 0.008
		else
			removeOverlay(/obj/overlay/medicon)
			winshow(usr, "balancewin", 0)
			medbal = 0
			Med_Gain(1/100)
			medtargbal = 50
			medruincount=0
		if(prob(1))
			switch(rand(1,4))
				if(1) medtargbal += 1
				if(2) medtargbal += 2
				if(3) medtargbal -= 1
				if(4) medtargbal -= 2
			medtargbal = min(medtargbal,60)
			medtargbal = max(medtargbal,30)
		if(medbal >= medtargbal-5 && medbal <= medtargbal+5)
			if(medbal <= medtargbal-2 && medbal >= medtargbal+2)
				Med_Gain(1)
			else if(medbal <= medtargbal-1 && medbal >= medtargbal+1)
				Med_Gain(2)
			else
				Med_Gain(1/2)
		if(medbal <= medtargbal-5)
			if(medbal >= medtargbal-20)
				Med_Gain(1/2)
			else if(medbal >= medtargbal-35)
				Med_Gain(1/4)
		if(Ki<MaxKi&&!expandlevel&&medbal<70)
			Ki+=KIregen
			if(HP<100)
				SpreadHeal(1*HPregen)
				HP=min(HP,100)
		if(medbal>=70)
			Ki-=KIregen * 4
			stamina -= 0.005
		if(writing)
			writetime++
			if(writetime>=writetarget)
				var/obj/items/book/Skillbook/A = new/obj/items/book/Skillbook
				A.name = writename
				A.suffix = "Level [writelevel]"
				A.skillname = writename
				A.level = writelevel
				A.exp = writeexp
				src.contents+=A
				src<<"You have finished writing!"
				writing=0
				writetime=0
				writetarget=0
				writename=""
				writelevel=0
				writeexp=0

	else
		if(icon_state=="Meditate") icon_state = ""
		winshow(usr, "balancewin", 0)
		removeOverlay(/obj/overlay/medicon)
		medruincount=0

mob/var
	med=0
	deepmeditation=0
	tmp
		medbal = 0 //min 0, max 100
		medtargbal = 50 //range is 40 - 60
		adding = 0
		medruincount = 0
		is_drawing=0
		started_draw

mob/default/verb/Draw_Energy()
	set category = "Skills"
	if(started_draw)
		if(med&&deepmeditation)
			Add_Bal()
			return
		else
			Energy_Draw()
		adding = 1
		spawn(6) adding = 0
	else
		started_draw = 1
		if(med&&deepmeditation)
			Add_Bal()
			return
		else if(canPower && stamina > 1)
			updateOverlay(/obj/overlay/auras/aura)
			usr.overlaychanged=1
			emit_Sound('chargeaura.wav')
			Energy_Draw()
		dblclk+=1
		if(dblclk>=2&&DUpowerupon)
			dblclk=0
			Transformations_Activate()
			src<<"You attempt to transform."
		spawn (10) dblclk=0
		adding = 1
		poweruprunning = 1
		spawn(5) adding = 0

mob/default/verb/Stop_Draw_Energy()
	set hidden = 1
	set category = "Skills"
	if(med&&deepmeditation)
		Add_Bal()
		return
	FlashPoint = 1
	poweruprunning = 0
	started_draw = 0
	is_drawing=0
	AuraCheck()


mob/verb/Add_Bal()
	set category = null
	set hidden = 1
	if(med&&deepmeditation&&!adding)
		medbal += 1
		if(Ki<MaxKi)
			Ki += (MaxKi / 110)
			stamina -= (maxstamina / 600)
	adding = 1
	spawn(7) adding = 0

mob/default/verb/Expel_Bal()
	set category = null
	set hidden = 1
	if(med&&deepmeditation&&!adding&&medbal)
		medbal = 0
		view(src)<<"[src] expelled some energy!"
		Ki -= (MaxKi / 5)
	adding = 1
	spawn(7) adding = 0

obj/overlay/medicon
	plane = 7
	name = "aura"
	ID = 5
	icon = 'medicon.dmi'

mob/keyable/verb/Ki_Targets()
	set category="Skills"
	set waitfor = 0
	set background = 1
	if(shdboxcl)
		usr<<"A cooldown for Ki targets is set. [shdboxcl/10] seconds."
		return
	if(shdbox)
		shdbox = 0
		usr << "You are no longer shadowboxing||Ki targeting."
		return
	if(!move || !hasTime) return
	med = 1
	usr << "You are Ki targeting. Balls of your Ki will appear around you. Every time you click on one, a blast will be sent towards it, rewarding you with some blasting gains. This is more effective than meditation. You must still be meditating to do this. You can't do this in deep meditation."
	shdbox=1
	while(shdbox && med && !deepmeditation)
		if(!move || !hasTime) break
		var/turf/T = tele_rand_turf_in_view(src,4)
		new/obj/training_obj/Ki_Target(T,signature)
		sleep(35)
	shdbox=0

obj/training_obj/Ki_Target
	defgains = 10
	var/sign = ""
	icon = '14.dmi'
	mouse_opacity = 1
	New(loc,sig)
		..()
		sign = sig
		spawn Ticker()
		spawn(50) deleteMe()
	TrainHit(mob/tnr)
		if(sign == tnr.signature)
			var/gainscale=max((1-(tnr.BP/TopBP))**2,0.2)
			tnr.Train_Gain(defgains*gainscale)
		deleteMe()
	proc/Ticker()
		set background = 1
		set waitfor = 0
		while(src)
			dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)
			step(src,dir)
			sleep(5)
	Click()
		if(sign == usr.signature)
			missile('5.dmi',usr,src)
			usr.Blast_Gain(1,TRUE)
			for(var/datum/skill/mind/nS in usr.learned_skills)
				if(usr.focusskill && nS.name == usr.focusskill)
					if(nS.level<100)
						nS.KiSkillGains(5)
					break
			deleteMe()