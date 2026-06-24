mob/var
	train=0
	dig = 0
	tmp/training=0
	tmp/missedtrain=0
	tmp/tmp_activ_gains=0
	gotbodyexpand
mob/proc/Train_Gain(var/mult)
	if(!mult) mult = 1
	mult*=global_train_gain
	if(BP<relBPmax)
		if(BP<10)
			if(KiUnlockPercent==1||prob(25))
				if(prob(10)) BP += 1
		var/amount = relBPmax*BPTick*TrainMod*Egains*weight*(1/9)*mult
		if(missedtrain) tmp_activ_gains++
		else if(tmp_activ_gains>0)
			amount *= min(25,tmp_activ_gains/10)
			tmp_activ_gains=max(0,tmp_activ_gains-25)
		if(train_med_to_hp)
			hiddenpotential+= amount/4
			cap_hp()
		else BP+= capcheck(amount)
		if(hiddenpotential>=BP)
			BP += capcheck(hiddenpotential*BPTick*(1/32))
		else
			BP += capcheck(hiddenpotential*BPTick*(1/64))
	if(prob(10))
		maxstamina+=0.01*weight
	if(baseKi<=baseKiMax)baseKi+=kicapcheck(0.001*TrainMod*BPrestriction*KiMod*baseKiMax/baseKi)

mob/proc/cap_hp()
	if(!Age<=InclineAge &&!BP < AverageBP)
		hiddenpotential = min(TopBP * 5,hiddenpotential)
		hiddenpotential = max(TopBP / 25,hiddenpotential)
		if(BP>AverageBP*1.5) hiddenpotential = min(TopBP / 2,hiddenpotential)
/*
mob/verb/Dig()
	set category="Skills"
	if(!beaming&&!charging&&!flight&&!KO&&canfight)
		if(!dig&&Ki>=1)
			usr<<"You begin digging for resources (see Items tab)."
			dig=1
			return
	if(dig)
		usr<<"You stop digging."
		dig=0
		return*/

/*mob/default/verb/Train()
	set category="Skills"
	if(!blasting&&!flight&&!KO)
		if(med)
			Meditate()
		if(!train&&Ki>=1)
			usr<<"You begin training."
			dir=SOUTH
			train=1
			canfight=0
			if(Savable) icon_state="Train"
		else
			usr<<"You stop training."
			train=0
			canfight=1
			if(Savable) icon_state=""
*/

mob/default/verb/Train()
	set category = "Skills"
	if(!blasting&&!flight&&!KO)
		if(med)
			Meditate()
		if(!train&&Ki>=1)
			usr<<"You begin training. Press ctrl + a directional key (facing a different direction) continue training."
			train=1
			//canfight=0
			dir = SOUTH
		else
			usr<<"You stop training."
			train=0
			//canfight=1
mob/var/tmp/lastdir = 0
mob/proc/trainproc() if(client)
	if(train)
		if(stamina>=0.01*weight*weight&&!KO)
			stamina-=0.01*weight*weight
			if(lastdir!=dir&&!attacking)
				lastdir = dir
				if(icon_state=="Train") icon_state=""
				Whiff(1)
				attacking=0
			else if(lastdir==dir&&!attacking&&training==0)
				missedtrain++
				training=1
				if(missedtrain>=2)
					var/gainscale=max(1-(BP/TopBP),0.2)
					if(prob(80))
						gainscale = 1
					Train_Gain(6/(1+log(missedtrain))*gainscale)
					icon_state="Train"
					dir = SOUTH
				spawn(40)
				training=0
		else
			usr<<"You stop training."
			if(icon_state=="Train") icon_state=""
			train=0
			move=1
	else if(icon_state=="Train") icon_state=""

mob/var/tmp/shdbox=0
mob/var/tmp/shdboxcl=0
mob/keyable/verb/Shadowboxing()
	set category = "Skills"
	if(shdboxcl)
		usr<<"A cooldown for shadowboxing is set. [shdboxcl/10] seconds."
		return
	if(shdbox)
		shdbox = 0
		shdboxcl = 35
		usr << "You are no longer shadowboxing||Ki targeting."
		return
	if(!move || !hasTime) return
	usr << "You are shadowboxing. Shadows around you will appear. Every time you hit one, you'll get more gains than from regular training."
	shdbox=1
	while(shdbox)
		if(!move || !hasTime) break
		var/turf/T = tele_rand_turf_in_view(src,4)
		new/obj/training_obj/Shadow(T,signature)
		sleep(35)
	shdbox=0

obj/training_obj
	IsntAItem=1
	canGrab=0
	mouse_opacity=0
	density = 0
	var/defgains = 5
	proc/TrainHit(mob/tnr)
		var/gainscale=max((1-(tnr.BP/TopBP))**2,0.2)
		tnr.Train_Gain(defgains*gainscale)
	
	Shadow
		defgains = 10
		var/sign = ""
		icon = 'shadow.dmi'
		New(loc,sig)
			..()
			sign = sig
			spawn(50) deleteMe()
		TrainHit(mob/tnr)
			if(sign == tnr.signature)
				..()
				deleteMe()