datum/godki//REWORK 2026-07-18: os TIERS morreram -- a progressao divina agora e uma MAESTRIA 0-100% muito lenta (ganha com God Ki ligado, 2x em combate; ver GODKI_* no 1A Defines)
	var
		mastery = 0 //MAESTRIA de God Ki 0-100: 0 = SSJ Deus / 33 = Blue / 50 = Royale (Elite) ou Kaioken-Blue (Normal/Low-Class) / 70 = pode aprender UI/Destruicao
		awakened = 0 //1 = despertou o God Ki (o antigo "tier >= 1")
		tier = 0 //LEGADO: slot de MIGRACAO de saves antigos -- CheckGodki converte tier->mastery (1=0/2=33/3=50/4=66) e zera. Nao usar pra mais nada.
		energy = 0
		max_energy = 0 //pool de energia divina: escala com a maestria (GODKI_ENERGY_BASE + mastery x GODKI_ENERGY_PER_PCT)

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

		godki_mult = 1//multiplicador do God Ki cru: 2 + maestria/33 + % de energia (paridade com o antigo 1+tier)

		points = 37 //pontos de especializacao (fortitude/power/body); +GODKI_POINTS_PER_MILESTONE a cada marco de maestria (33/50/70/100)
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
			max_energy = max(50,((GODKI_ENERGY_BASE + mastery * GODKI_ENERGY_PER_PCT) * energy_mod) + energy_buff)

		calc_efficiency()
			efficiency = (b_efficiency*m_efficiency*tm_efficiency) + t_efficiency + tt_efficiency
		calc_mult()
			if(energy)
				//despertos: paridade com o antigo 1+tier (0%=2, 33%=3, 66%=4, 100%=~5); ritual (usage sem despertar) fica no 1+energia como antes
				godki_mult = (awakened ? 2 + (mastery / GODKI_BLUE_PCT) : 1) + godki_mult_mod
				godki_mult = godki_mult + round(energy / max_energy,0.01)
				if(adjust_me)
					godki_mult += transform_adjust
			else
				godki_mult = 1
		//teto de SSJ empilhavel DENTRO do God Ki, pela maestria: <33% nada (so o SSG),
		//33%+ SSJ1 (Blue), 50%+ USSJ (Royale) SO pra Elite/Kaio. Prodigial nunca empilha
		//(o caminho dele e o Mistico/Beast). Ritual (usage SEM despertar) segue livre como
		//sempre foi. Le godki_ssj_cap como teto absoluto da elite (knob admin).
		gk_trans_cap()
			if(!savant) return 0
			if(!awakened) return 10 //deus TEMPORARIO de ritual: sem restricao de forma (comportamento antigo)
			if(savant.Class == "Prodigial") return 0
			if(mastery < GODKI_BLUE_PCT) return 0
			if(mastery < GODKI_ROYALE_PCT) return 1
			if(savant.Class == "Elite" || savant.Class == "Kaio") return godki_ssj_cap
			return 1
		refresh()
			calc_energy()
			calc_efficiency()
			calc_mult()
			energy = min(energy, max_energy) //migracao tier->maestria pode ter deixado energia acima do pool novo
			if(savant)
				savant.trans_min_val = gk_trans_cap()
				if(energy == 0 && usage)
					usage=0
					savant.removeOverlay(/obj/overlay/auras/gk)
					savant.emit_Sound('descend.wav')
					to_chat(savant, "You run out of your God Ki energy, it no longer replacing Ki.")
				if(usage != inusg && savant)
					inusg = usage
					if(usage && awakened)
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
	hakai_disables_saves = 0 //nonfunctional for now

mob/var
	datum/godki/godki = null
mob/proc
	train_godki(mult)
		if(godki && godki.awakened && godki.usage)
			AddExp(src,/datum/mastery/Godki,mult)
			switch(godki.focus)
				if("Fortitude") AddExp(src,/datum/mastery/fortitude,mult)
				if("Power") AddExp(src,/datum/mastery/power,mult)
				if("Body") AddExp(src,/datum/mastery/body,mult)
	//MOTOR DA MAESTRIA (chamado no GlobalStats, ~0.3s/ciclo): so cresce com God Ki LIGADO; combate dobra
	godki_mastery_tick()
		if(!godki || !godki.awakened || !godki.usage) return
		if(godki.mastery >= 100) return
		var/g = GODKI_MASTERY_TICK
		if(combatTag) g *= GODKI_MASTERY_COMBAT_MULT
		var/_old = godki.mastery
		godki.mastery = min(godki.mastery + g, 100)
		godki_mastery_milestone(_old, godki.mastery)
	//cruzou um marco de maestria: pontos de especializacao + cena + anuncio do que destravou
	godki_mastery_milestone(oldv, newv)
		for(var/m in list(GODKI_BLUE_PCT, GODKI_ROYALE_PCT, GODKI_UIUE_LEARN_PCT, 100))
			if(oldv < m && newv >= m)
				godki.points += GODKI_POINTS_PER_MILESTONE
				spawn GodkiIncreaseScene()
				switch(m)
					if(GODKI_BLUE_PCT)
						if(Class == "Prodigial") to_chat(src, "<font color=#cba6ff><b>Seu ki divino amadurece ([m]%): o Mistico com God Ki agora expressa x32!</b></font>")
						else to_chat(src, "<font color=#33ccff><b>Seu ki divino amadurece ([m]%): o Super Saiyajin BLUE esta ao seu alcance!</b></font>")
					if(GODKI_ROYALE_PCT)
						if(Class == "Prodigial") to_chat(src, "<font color=#cba6ff><b>Maestria [m]%: algo BESTIAL espreita no fundo do seu potencial... uma raiva profunda com o God Ki ligado o despertara.</b></font>")
						else if(Class == "Elite" || Class == "Kaio") to_chat(src, "<font color=#66aaff><b>Maestria [m]%: o SUPER SAIYAN ROYALE (a evolucao do Blue) esta ao alcance do seu sangue de elite!</b></font>")
						else to_chat(src, "<font color=#ff6666><b>Maestria [m]%: seu corpo agora aguenta o KAIOKEN (ate x[GODKI_KAIOKEN_CAP]) por cima do Blue!</b></font>")
					if(GODKI_UIUE_LEARN_PCT)
						to_chat(src, "<font color=#e8e8ff><b>Maestria [m]%: seu corpo esta pronto pros segredos dos Anjos e dos Deuses da Destruicao (Ultra Instinct / Power of Destruction).</b></font>")
					if(100)
						to_chat(src, "<font color=#ffd700><b>Maestria TOTAL do God Ki.</b></font>")
	regen_godki(mult)
		if(godki)
			if(godki.awakened)
				godki.gainenergy(mult)
	sub_gdki_energy(mult)
		if(godki && godki.energy >= 1)
			godki.removeenergy(mult * (1 + ssj + lssj + trans))
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
		if(godki.tier > 0) //MIGRACAO de saves antigos: tier -> maestria (1=0% SSG / 2=33% Blue / 3=50% Royale / 4=66%) -- roda 1x e zera o slot
			godki.awakened = 1
			var/_gm = 66
			switch(godki.tier)
				if(1) _gm = 0
				if(2) _gm = GODKI_BLUE_PCT
				if(3) _gm = GODKI_ROYALE_PCT
			godki.mastery = max(godki.mastery, _gm)
			godki.tier = 0
			to_chat(src, "<font color=#33ccff>Seu God Ki foi convertido pro novo sistema de MAESTRIA: [round(godki.mastery)]%.</font>")
		if(godki.awakened && !godki.initial)
			godki.initial = 1
			assignverb(/mob/keyable/verb/God_Ki)
			assignverb(/mob/keyable/verb/God_Ki_Focus)
			if(NoAscension)
				godki.adjust_me = 1

mob/keyable/verb
	God_Ki()
		set category = "Skills"
		if(SaiyanLineage == "Primal Saiyan") //Primal nao acessa SSG/Blue; o God Ki canaliza o Limit Breaker a partir do SSJ4 Full Power masterizado
			if(ssj==5 && ssj4fpmastery>=100 && hasFPLB)
				SSj4FPLB()
			else
				to_chat(usr, "Your primal blood rejects God Ki - you can only break your limit from a fully mastered Super Saiyan 4 Full Power.")
			return
		if(godki)
			if(!godki.usage)
				if(Class == "Prodigial" && !HasSkill(/datum/skill/kai/Mystic)) //Prodigial: o ki divino so flui por um potencial ja liberado
					to_chat(usr, "<font color=#cba6ff>Seu sangue Prodigial rejeita o ki divino cru -- so com o potencial liberado (Mistico) seu corpo pode canaliza-lo.")
					return
				if(buffoutput[1] != "None") animate(src,time=8,color=rgb(14, 130, 238))
				else animate(src,time=8,color=rgb(255, 81, 0))
				spawn(1) color=null
				godki.usage = 1
				to_chat(usr, "You begin using God Ki energy, which will start being used to replace Ki, increasing your power.")
				emit_Sound('ssg.wav')
				createShockwavemisc(loc,2)
				for(var/obj/overlay/B in src.overlayList)B.EffectLoop()
				godki.refresh() //recalcula o teto de SSJ permitido pela MAESTRIA (trans_min_val)
				if(ssj > trans_min_val || (lssj && lssj-1 > trans_min_val))
					Revert()
			else
				godki.usage = 0
				removeOverlay(/obj/overlay/auras/gk)
				emit_Sound('descend.wav')
				to_chat(usr, "You shut off your God Ki energy, it no longer replacing Ki.")
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
					if(Angel_Rank == container.signature) //aura branca dos ANJOS: pelo RANK, nao mais por tier
						icon = 'god - grey.dmi'
						added_color[1] += 245
						added_color[2] += 245
						added_color[3] += 245
						container.blastR = 240
						container.blastG = 240
						container.blastB = 240
					else if(God_Of_Destruction == container.signature) //aura purpura dos DEUSES DA DESTRUICAO: pelo RANK
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
	// Escada divina (destravada pela MAESTRIA nas portas de transformacao):
	// Super Saiyan God 22x (0%), Blue/Rose 32x (33%), Royale/Rose 2 56x (50%, so Elite/Kaio via USSJ).
	if(!godki || !godki.usage || !godki.awakened) return 0
	if(Class == "Prodigial") //Prodigial NAO tem SSG/Blue: o ki divino flui pelo MISTICO (22x -> 32x aos 33%) e culmina no BEAST (56x, raiva aos 50%)
		if(beast_form) return 56
		if(isBuffed(/obj/buff/Mystic)) return (godki.mastery >= GODKI_BLUE_PCT) ? 32 : 22
		return 0 //god ki ligado sem Mistico ativo: cai no godki_mult cru
	if(ssj == 0 && lssj == 0) return 22          // Super Saiyan God (no regular SSJ stacked)
	if(max(ssj,lssj) >= godki_ssj_cap) return 56 // Super Saiyan Royale / Rose 2 (USSJ em God Ki: so Elite/Kaio aos 50%; Legendary chega via LSSJ)
	return 32                                     // Super Saiyan Blue / Rose
