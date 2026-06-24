datum/godki//this could be converted to a mastery but generally you wouldn't want this limited to an insight, nor does it have the normal gimmicks of a mastery. (tier 0 freebie if anything), also clutter mob variable bad >:(
	var
		tier = 0 //what Godki tier are you at? tier 0 - basic bitch you don't have godki, tier 1, Goku/Vegeta pre ToP level. tier 2, Goku/Vegeta/Toppo/Jiren...
		// tier 'cap' - 1, GoD, tier 'cap', Angel. (cap is 4 right now.)
		//these are relatively loose tiers but the maxtier global variable will be used to calculate Hakai ability.
		energy = 0
		max_energy = 0 //max energy = tier * 100 * energy_mod. thats it.

		b_efficiency = 1 //how efficient is god-ki to ki? 'base' value.
		t_efficiency = 0//buff
		m_efficiency = 1 //modifier

		tmp/tt_efficiency = 0 //temp buff
		tmp/tm_efficiency = 1 //temp mod

		efficiency = 1 //expressed efficiency. efficiency is multiplied by tier. use this for numbers

		naturalization = FALSE //whether or not Godki is natural. Natural Godki masters faster and some features are added. (Like giving people Godki and so on.)
		//Naturalization happens either intrinsically for Kaios/Demons, or half breeds with Kaio/Demon ancestry. Alternatively, Admins can give naturalization.
		//Naturalization can be earned after GoD tier.
		//(this is your Rose variable)
		//Transferable between Reincarnations.
		
		//hakaishin
		canhakaishin = 0 //can you go Hakaishin form
		canhakai = 0 //can you go HAKAI
		canreverse = 0 //can you reverse hakai
		//
		energy_mod = 1
		energy_buff = 0

		drain_mod = 1
		godki_mult_mod = 0
		godki_regen_go = 0
		//energystuff
		adjust_me = FALSE
		transform_adjust = 4//transforming races get an extra 4x multiplier when in usage.

		godki_mult = 1//equal to tier + 1.

		exp_buffer = 0
		max_exp = 1000
		points = 37
		focus = "Fortitude"
		tmp
			energy_buffer = 0
			drain_buffer = 0
		usage = 0 //are you using Godki?
		tmp/inusg = 0
		tmp/initial = 0
		tmp/mob/savant = null

	proc
		calc_energy()
			max_energy = max(50,(tier * 100 * energy_mod) + energy_buff)

		calc_efficiency()
			efficiency = (b_efficiency*m_efficiency*tm_efficiency) + t_efficiency + tt_efficiency
		calc_mult()
			if(energy)
				godki_mult = 1 + tier + godki_mult_mod
				godki_mult = godki_mult + round(energy / max_energy,0.01)
				if(adjust_me)
					godki_mult += transform_adjust
			else
				godki_mult = 1
		calc_level()
			if(tier < max_godki_tier)
				if(exp_buffer >= max_exp)
					exp_buffer-=max_exp
					if(max_godki_tier>tier)
						tier++
						points += 37
						savant.GodkiIncreaseScene()
					if(savant) savant.test_godki()
					refresh()
					max_exp = 1000 ** (tier+1)
		refresh()
			calc_energy()
			calc_efficiency()
			calc_mult()
			calc_level()
			if(savant)
				savant.trans_min_val = min(godki_ssj_cap,tier)
				if(energy == 0 && usage)
					usage=0
					savant.removeOverlay(/obj/overlay/auras/gk)
					savant.emit_Sound('descend.wav')
					savant << "You run out of your God Ki energy, it no longer replacing Ki."
				if(usage != inusg && savant)
					inusg = usage
					if(usage && tier)
						savant.updateOverlay(/obj/overlay/auras/gk)
					else savant.removeOverlay(/obj/overlay/auras/gk)

		gainenergy(mult=1)
			energy_buffer+= mult * efficiency
			if(energy_buffer >= 25)
				energy++
				energy_buffer -= 25
				energy = min(max_energy,energy)

		removeenergy(mult=1)
			drain_buffer+= 1*mult
			drain_buffer+= (savant.ssj + savant.lssj + savant.trans)
			if(drain_buffer >= 50 * efficiency * drain_mod)
				if(efficiency < 10) energy--
				drain_buffer -= 50 * efficiency * drain_mod
var
	godki_cap = 4
	hakai_disables_saves = 0 //nonfunctional for now

mob/var
	datum/godki/godki = null
mob/proc
	train_godki(mult)
		if(godki && godki.tier < max_godki_tier && godki.usage && godki.tier)
			godki.exp_buffer+= (1+godki.tier) * mult
			AddExp(src,/datum/mastery/Godki,mult)
			switch(godki.focus)
				if("Fortitude") AddExp(src,/datum/mastery/fortitude,mult)
				if("Power") AddExp(src,/datum/mastery/power,mult)
				if("Body") AddExp(src,/datum/mastery/body,mult)
	test_godki()
		if(godki.tier >= (godki_cap - 1))
			GoD_Test()
		if(godki.tier == godki_cap)
			Angel_Test()
	regen_godki(mult)
		if(godki)
			if(godki.tier >= 1)
				godki.gainenergy(mult)
	sub_gdki_energy(mult)
		if(godki && godki.energy >= 1)
			godki.removeenergy(mult * (1 + ssj + lssj + trans))
	GoD_Test()
		godki.naturalization = TRUE
		return
	Angel_Test()
		return
	GodkiIncreaseScene()
		emit_Sound('ssg.wav')
		createShockwavemisc(loc,3)
		Quake()
		sleep(15)
		createShockwavemisc(loc,2)
		Quake()
		return
	CheckGodki()
		if(isnull(godki))
			godki = new/datum/godki
			godki.b_efficiency = godki_mod
			unassignverb(/mob/keyable/verb/God_Ki)
			unassignverb(/mob/keyable/verb/God_Ki_Focus)
		godki.savant = src
		if(godki.tier && !godki.initial)
			godki.initial = 1
			assignverb(/mob/keyable/verb/God_Ki)
			assignverb(/mob/keyable/verb/God_Ki_Focus)
			if(NoAscension)
				godki.adjust_me = 1

mob/keyable/verb
	God_Ki()
		set category = "Skills"
		if(godki)
			if(!godki.usage)
				if(!blue_music_played) //first time turning blue (God Ki) -> play the SSJ Blue theme from the START
					blue_music_played=1
					emit_Sound('Dragon Ball Z Dokkan Battle AGL LR Super Saiyan Blue Goku & Vegeta Intro OST (Extended).mp3')
				if(buffoutput[1] != "None") animate(src,time=8,color=rgb(14, 130, 238))
				else animate(src,time=8,color=rgb(255, 81, 0))
				spawn(1) color=null
				godki.usage = 1
				usr << "You begin using God Ki energy, which will start being used to replace Ki, increasing your power."
				emit_Sound('ssg.wav')
				createShockwavemisc(loc,2)
				for(var/obj/overlay/B in src.overlayList)B.EffectLoop()
				if(ssj > godki_ssj_cap)
					Revert()
			else
				godki.usage = 0
				removeOverlay(/obj/overlay/auras/gk)
				emit_Sound('descend.wav')
				usr << "You shut off your God Ki energy, it no longer replacing Ki."
		else
			godki = new/datum/godki
			unassignverb(/mob/keyable/verb/God_Ki)
			CheckGodki()
	God_Ki_Focus()
		set category = "Other"
		if(godki)
			godki.focus = input(usr,"What will you focus on in God Ki? Fortitude, Power, or Body?") in list("Fortitude","Power","Body")
		else
			godki = new/datum/godki
			unassignverb(/mob/keyable/verb/God_Ki_Focus)
			CheckGodki()

obj/overlay/auras/gk
	plane = AURA_LAYER
	name = "godki aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 47
	ScaleMe = 0
	presetAura=1
	icon='god.dmi'
	var/oR
	var/oG
	var/oB
	ScaleAura()
		return
	EffectStart()
		. = ..()
		if(container.ssj || container.lssj)
			icon = container.sgkoverlay
		oR=container.blastR
		oG=container.blastG
		oB=container.blastB
	EffectLoop()
		if(icolor != prevcolor)
			if(!isnull(prevcolor)) icon -= prevcolor
			if(!isnull(icolor)) icon += icolor
			prevcolor = icolor
		if(setSSJ != max(container.ssj,container.lssj)) lstgdki=0
		if(lstgdki == 0 && container.godki.usage)
			lstgdki = 1
			icolor = null
			if(container.ssj==0 && container.lssj==0)
				icon = container.gkoverlay
				container.blastR = 240
				container.blastG = 96
				container.blastB = 52
				if(isnull(container.csgkoverlay))
					var/list/added_color = list(0,0,0)
					if(container.godki.tier == godki_cap)
						icon = 'god - grey.dmi'
						added_color[1] += 245
						added_color[2] += 245
						added_color[3] += 245
						container.blastR = 240
						container.blastG = 240
						container.blastB = 240
					else if(container.godki.tier == godki_cap - 1)
						icon = 'god - grey.dmi'
						added_color[1] += 163
						added_color[3] += 136
						container.blastR = 163
						container.blastG = 9
						container.blastB = 136
					icolor = rgb(clamp(added_color[1],0,255),clamp(added_color[2],0,255),clamp(added_color[3],0,255))
				else
					icolor = null
					icon = container.csgkoverlay
			else
				container.blastR = 51
				container.blastG = 145
				container.blastB = 221
				icon = container.sgkoverlay
		if(!container.godki.usage)
			EffectEnd()
		..()
	EffectEnd()
		container.blastR=oR
		container.blastG=oG
		container.blastB=oB
		. = ..()


obj/overlay/goblue
	plane = AURA_LAYER
	name = "godki aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 47
	pixel_x = -24
	o_px = -24
	//pixel_y = -34
	//o_py = -34
	var/timer=7
	icon='bluego.dmi'
	icon_state = "1"
	EffectStart()
		spawn
			icon_state = "1"
			pixel_x = -24
			o_px = -24
			//pixel_y = -34
			//o_py = -34
			icon_state = "first"
			container.overlays += src
			container.overlayList += src
			//container.overlayList += src
			container.overlaychanged = 1
			icon_state = "first"
			while(timer>=1)
				timer--
				pixel_x = -24
				o_px = -24
				//pixel_y = -34
				//o_py = -34
				sleep(1)
			container.overlays -= src
			container.overlayList -= src
			container.overlaychanged = 1
			EffectEnd()
		..()
mob/proc/god_form_mult()
	// Flat BP multiplier for an active God form, or 0 when not in one.
	// Mirrors the form chart: Super Saiyan God 22x, Super Saiyan Blue/Rose 32x,
	// Super Saiyan Blue Evolved / Rose 2 (Angel tier) 56x.
	if(!godki || !godki.usage || !godki.tier) return 0
	if(ssj == 0 && lssj == 0) return 22          // Super Saiyan God (no regular SSJ stacked)
	if(godki.tier >= godki_cap) return 56         // Blue Evolved / Rose 2
	return 32                                     // Super Saiyan Blue / Rose
