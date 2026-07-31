// ============================================================================
// FORMAS DO FROST DEMON (rework 2026-07-10)
//   * Numeracao UNICA 1..7: formas 1-4 = SUPRESSAO (so o Mutante tem),
//     forma 5 = BASE, forma 6 = 1a EVOLUCAO (x10), forma 7 = EVOLUCAO FINAL (x20).
//   * NORMAL: escolhe na criacao a base + 2 evolucoes (3 corpos). Ascensao
//     limitada a FD_ASC_CAP (2.8x) -> topo 20 x 2.8 = 56x (paridade com as
//     formas mais fortes das outras racas).
//   * MUTANTE: nasce na forma 1 (25% do BP) com BP base 4x maior; precisa
//     MASTERIZAR a forma base (motor no icer.dm) pra segurar formas altas.
//     Transformar numa forma que ele NAO segura = cinematica (1a vez) com a
//     aura do C-Type em VERMELHO.
//   * Formas NAO mexem mais no pool de Ki (o sistema antigo dava +Ki na
//     supressao e -Ki na final).
//   * Golden Form continua uma skill separada por cima (FD_GOLDEN_MULT).
// Knobs FD_* no 1A Defines.dm (compartilhados com icer.dm/base.dm/ascension).
// ============================================================================

mob/var
	fd_form = 0            //forma atual 1..7 (0 = personagem de save antigo: fd_login_check migra)
	fd_base_mastery = 0    //maestria da forma base 0-100 (so MUTANTE usa; motor no icer.dm)
	fd_release = 1         //fracao do BP liberada (cai quando o ki descontrola; clamp no powerlevel)
	fd_ki_locked = 0       //1 = controle de ki PERDIDO: Draw_Energy/power-up bloqueados, release caindo
	fd_cine_flags = 0      //bitmask (1<<forma): cinematica grande ja vista naquela forma
	icon/form7icon         //corpo da forma 7 (evolucao final)
	icon/goldicon = 'GoldIcer.dmi' //corpo proprio do Golden (era a form6icon no sistema antigo)
mob/var/tmp
	fd_unstable_since = 0  //world.time em que entrou na forma instavel atual
	fd_engine_last = 0     //ultimo tick do motor (dt real, robusto a cadencia)
	fd_warn_cd = 0         //cooldown dos avisos no chat
	fd_transing = 0        //latch da cinematica de transformacao

mob/proc/fd_is_frost()
	return (Race == "Frost Demon" || Parent_Race == "Frost Demon")
mob/proc/fd_is_mutant()
	return (fd_is_frost() && Class == "Mutant Frost Demon")

//multiplicador de BP de cada forma (transBuff autoritativo no effector do icer.dm)
proc/fd_form_mult(f)
	switch(f)
		if(1) return 0.25
		if(2) return 0.50
		if(3) return 0.75
		if(4) return 0.90
		if(6) return FD_FORM6_MULT
		if(7) return FD_FORM7_MULT
	return 1

proc/fd_form_name(f)
	switch(f)
		if(1) return "1a Forma (supressao 25%)"
		if(2) return "2a Forma (supressao 50%)"
		if(3) return "3a Forma (supressao 75%)"
		if(4) return "4a Forma (supressao 90%)"
		if(6) return "1a Evolucao"
		if(7) return "Forma Black"
	return "Forma Base"

//fator de TEMPO ate perder o controle (mutante em forma instavel): quanto mais perto da
//base, MENOS tempo; as super formas aceleram ainda mais (spec da imagem do design)
proc/fd_form_losstime(f)
	switch(f)
		if(2) return 8
		if(3) return 4
		if(4) return 2
		if(6) return 0.5
		if(7) return 0.25
	return 1 //forma 5 (base)

//ate qual forma o MUTANTE segura PRA SEMPRE (degraus de maestria da imagem do design)
mob/proc/fd_stable_gate()
	if(!fd_is_mutant()) return 7 //nao-mutante nao tem instabilidade
	if(fd_base_mastery >= 100) return 5
	if(fd_base_mastery >= 75) return 4
	if(fd_base_mastery >= 50) return 3
	if(fd_base_mastery >= 25) return 2
	return 1

// ---------------------------------------------------------------------------
// TRANSFORMAR (tecla C 2x) / REVERTER
// ---------------------------------------------------------------------------
//assisted=1 -> despertar guiado por um MESTRE: os limiares valem pela metade (MasterStudent.dm)
mob/proc/Frost_Demon_Forms(assisted = 0)
	if(!fd_is_frost()) return
	if(fd_transing) return
	if(isBuffed(/obj/buff/Golden_Form)) return //Golden por cima: reverta o Golden primeiro
	if(!fd_form) fd_login_check()
	var/next = fd_form + 1
	if(next > 7) return
	var/mst_desc = (assisted || next <= fd_assist_form) ? MST_HALF : 1 //desconto do mestre: vale na 1a vez E nas reentradas ate a forma ja alcancada com ele
	if(next == 6 && BP < FD_FORM6_AT * mst_desc)
		to_chat(src, "<font color=#88ccff>Seu corpo ainda nao esta pronto para evoluir alem da forma base.")
		return
	if(next == 7 && BP < FD_FORM7_AT * mst_desc)
		to_chat(src, "<font color=#88ccff>A sua evolucao final ainda esta alem do seu alcance.")
		return
	fd_transing = 1
	if(fd_is_mutant() && next > fd_stable_gate())
		//forma que ele NAO consegue segurar pra sempre: o poder incontrolavel vem a tona
		if(!(fd_cine_flags & (1 << next))) //1a vez NESTA forma: cinematica grande
			fd_cine_flags |= (1 << next)
			emit_TransformMusic(file("Sounds/Music/battle ost/DBZ- Battle Music 10.mp3"), 850) //1:25
			attackable = 0
			fd_grand_cinematic()
			attackable = 1
		else
			fd_burst_fx()
		to_chat(src, "<font color=#ff6655><b>Este poder e demais para segurar por muito tempo!</b> (maestria da base: [round(fd_base_mastery)]%)")
	fd_form = next
	mst_note_form() //testemunhas por perto registram a forma vista (MasterStudent.dm)
	fd_unstable_since = 0 //o motor no icer.dm re-arma o relogio da forma nova
	emit_Sound('1aura.wav')
	icer_poll_icon()
	to_chat(view(src), "<font color=#cda434>[src] avanca para a [fd_form_name(fd_form)]!")
	fd_transing = 0

mob/proc/revertIcer()
	if(!fd_is_frost()) return
	if(isBuffed(/obj/buff/Golden_Form))
		stopbuff(/obj/buff/Golden_Form)
		return
	if(!fd_form) fd_login_check()
	var/fl = fd_is_mutant() ? 1 : 5 //normal nao tem formas de supressao
	if(fd_form <= fl) return
	fd_form--
	fd_unstable_since = 0
	emit_Sound('descend.wav')
	icer_poll_icon()
	to_chat(view(src), "<font color=#cda434>[src] recua para a [fd_form_name(fd_form)].")

mob/proc/icer_poll_icon()
	if(isBuffed(/obj/buff/Golden_Form)) return //o buff Golden controla o proprio icone
	switch(fd_form)
		if(1) icon = form1icon
		if(2) icon = form2icon
		if(3) icon = form3icon
		if(4) icon = form4icon
		if(6) icon = form6icon
		if(7) icon = form7icon
		else icon = form5icon

// ---------------------------------------------------------------------------
// MIGRACAO de save antigo (sistema cur_icr_form) -- roda no Login e no 1o uso
//   velho: forms 1-4 = escada do dia a dia (form4 = cara padrao), 5 = "true form", 6 = Golden
//   novo:  1-4 = supressao (mutante), 5 = BASE, 6 = 1a evolucao, 7 = final (+goldicon proprio)
// ---------------------------------------------------------------------------
mob/proc/fd_login_check()
	if(!fd_is_frost()) return
	assignverb(/verb/Icer_Form_Settings) //todo Frost Demon tem o menu de formas (era da skill Better Limits, removida)
	if(fd_ki_locked) updateOverlay(/obj/overlay/effects/fd_menacing_red) //overlays morrem no logout: re-veste a aura do descontrole
	if(fd_form) return //ja migrado/criado no sistema novo
	if(form6icon) goldicon = form6icon //o corpo Golden escolhido na criacao antiga
	if(form6icon) form7icon = form6icon //evolucao final: a cara mais epica que ele tinha
	if(form5icon) form6icon = form5icon //1a evolucao: o antigo "true form"
	if(form4icon) form5icon = form4icon //BASE: a cara que ele usava no dia a dia
	fd_form = 5
	fd_release = 1
	fd_ki_locked = 0
	if(!ssj && !lssj) trueKiMod = 1 //o sistema antigo mexia no pool de Ki por forma; o novo NAO mexe
	icer_poll_icon()
	to_chat(src, "<font color=#cda434><b>Suas formas de Frost Demon foram atualizadas!</b> Base + 2 evolucoes[fd_is_mutant() ? " + 4 formas de supressao (voce e um MUTANTE: masterize a forma base!)" : ""]. Use <b>Icer Form Settings</b> (aba Other) para re-escolher os corpos.")

// ---------------------------------------------------------------------------
// FX: aura do C-Type em VERMELHO + cinematica da forma instavel (receita da
// lssj_grand_cinematic, recolorida) + surto curto das repeticoes
// ---------------------------------------------------------------------------
obj/overlay/effects/fd_menacing_red //a aura constante do SSJ C-Type ('god - grey.dmi' tintado), so que VERMELHA
	icon = 'god - grey.dmi'
	color = rgb(255, 80, 60)
	temporary = 0

var/icon/fd_red_aura_cache
proc/fd_red_aura_icon() //'Aurabigcombined.dmi' tintada de vermelho (cache: icon() decodifica o .dmi inteiro)
	if(!fd_red_aura_cache)
		fd_red_aura_cache = icon('Aurabigcombined.dmi')
		fd_red_aura_cache.Blend(rgb(255, 70, 50), ICON_MULTIPLY)
	return fd_red_aura_cache

mob/proc/fd_burst_fx() //transformacao instavel repetida: surto curto (a cinematica grande e so a 1a vez)
	emit_Sound('chargeaura.wav')
	spawn Quake()
	createShockwavemisc(loc, 3)
	createDustmisc(loc, 2)
	var/image/I = image(icon = fd_red_aura_icon())
	I.plane = 7
	overlayList += I
	overlaychanged = 1
	spawn(25)
		if(src)
			overlayList -= I
			overlaychanged = 1

mob/proc/fd_grand_cinematic() //1a transformacao numa forma INSTAVEL: build + surto + climax (timing da Legendary)
	var/turf/Td
	var/image/I
	var/obj/A
	var/cyc
	var/q
	var/amount
	move = 0
	dir = SOUTH
	emit_Sound('rockmoving.wav')
	updateOverlay(/obj/overlay/effects/fd_menacing_red)
	to_chat(view(src), "<font color=#ff6655>*Uma aura VERMELHA e violenta serpenteia em volta de [src] -- um poder incontrolavel comeca a vir a tona...*", "combat")
	for(cyc = 1 to 16) //build lento (~16s): pedras + tornados + raios + tremores
		for(q = 1 to 3)
			Td = locate(x + rand(-8,8), y + rand(-8,8), z)
			if(Td && !Td.density) createDustmisc(Td,2)
		if(prob(55))
			Td = locate(x + rand(-7,7), y + rand(-7,7), z)
			if(Td && !Td.density) createDustmisc(Td,3)
		if(prob(45))
			Td = locate(x + rand(-8,8), y + rand(-8,8), z)
			if(Td) createLightningmisc(Td, pick(2,4,5,9))
		if(cyc % 4 == 0) spawn Quake()
		sleep(10)
	I = image(icon = fd_red_aura_icon()) //surto (~12s): aura grande VERMELHA + feixes de chao + raios
	I.plane = 7
	overlayList += I
	overlaychanged = 1
	emit_Sound('chargeaura.wav')
	to_chat(view(src), "<font color=#ff6655>*O chao se parte -- o poder de [src] rasga o ar como uma coisa viva!*", "combat")
	Quake()
	spawn Quake()
	amount = 8
	while(amount)
		A = new/obj
		A.loc = locate(x,y,z)
		A.icon = 'Electricgroundbeam2.dmi'
		if(amount==8) spawn(rand(1,40)) walk(A,NORTH,2)
		if(amount==7) spawn(rand(1,40)) walk(A,SOUTH,2)
		if(amount==6) spawn(rand(1,40)) walk(A,EAST,2)
		if(amount==5) spawn(rand(1,40)) walk(A,WEST,2)
		if(amount==4) spawn(rand(1,40)) walk(A,NORTHWEST,2)
		if(amount==3) spawn(rand(1,40)) walk(A,NORTHEAST,2)
		if(amount==2) spawn(rand(1,40)) walk(A,SOUTHWEST,2)
		if(amount==1) spawn(rand(1,40)) walk(A,SOUTHEAST,2)
		spawn(50) del(A)
		amount--
	for(cyc = 1 to 12)
		for(q = 1 to 4)
			Td = locate(x + rand(-8,8), y + rand(-8,8), z)
			if(Td && !Td.density) createDustmisc(Td, pick(2,2,2,3))
		if(prob(55))
			Td = locate(x + rand(-9,9), y + rand(-9,9), z)
			if(Td) createLightningmisc(Td, pick(3,5,9))
		if(cyc % 3 == 0) spawn Quake()
		sleep(10)
	to_chat(view(8), "<font size=[TextSize]><[SayColor]>[src]: RRRAAAAAAAAGH!!!") //climax
	createShockwavemisc(loc, 3)
	for(q = 1 to 10)
		Td = locate(x + rand(-6,6), y + rand(-6,6), z)
		if(Td && !Td.density) createDustmisc(Td, pick(2,2,3))
	emit_Sound('aura.wav')
	overlayList -= I
	overlaychanged = 1
	removeOverlay(/obj/overlay/effects/fd_menacing_red) //a aura constante volta quando o motor detectar o descontrole
	createShockwavemisc(loc, 2)
	createCrater(loc, 3)
	move = 1

mob/proc/fd_mastery_msg(step)
	switch(step)
		if(25) to_chat(src, "<font color=#7ec87e><b>Maestria da base 25%:</b> a 2a Forma (supressao 50%) agora e estavel pra sempre.")
		if(50) to_chat(src, "<font color=#7ec87e><b>Maestria da base 50%:</b> a 3a Forma (supressao 75%) agora e estavel pra sempre.")
		if(75) to_chat(src, "<font color=#7ec87e><b>Maestria da base 75%:</b> a 4a Forma (supressao 90%) agora e estavel pra sempre.")
		if(100) to_chat(src, "<font color=#ffd700><b>Maestria da base 100%: a FORMA BASE e sua!</b> Voce pode fica-la pra sempre -- e as formas de supressao agora regeneram Ki passivamente (quanto mais suprimida, mais regenera).")

// ---------------------------------------------------------------------------
// GOLDEN FORM (skill separada; por cima de qualquer forma)
// ---------------------------------------------------------------------------
/obj/buff/Golden_Form
	name = "Golden Form"
	slot=sFORM
	Buff()
		..()
		container.bp_milestone_reach("frost_golden") //MARCO: Golden Form do Frost Demon
		container.updateOverlay(/obj/overlay/icergod)
		container.storedicon = container.icon
		if(container.icer_vars[container.icer_vars[1]] == TRUE)
			icon = container.goldicon
		else
			switch(container.icer_vars[container.icer_vars[2]])
				if(1) icon = container.form1icon
				if(2) icon = container.form2icon
				if(3) icon = container.form3icon
				if(4) icon = container.form4icon
				if(5) icon = container.form5icon
			icon += rgb(container.icer_vars[container.icer_vars[3]][1],container.icer_vars[container.icer_vars[3]][2],container.icer_vars[container.icer_vars[3]][3])
		container.icon = icon
		container.emit_Sound('1aura.wav')
		container.transBuff = FD_GOLDEN_MULT //acima da Evolucao Final (o effector do icer.dm nao mexe enquanto o Golden esta ativo)
		container.Tphysoff+=1.3
		container.Tkioff+=1.2
		container.Tspeed+=1.3
		container.gain_godki(90)
		container.godki.usage = 1
	DeBuff()
		to_chat(container, "Your body releases its golden hue.")
		container.icon = container.storedicon
		container.Tphysoff-=1.2
		container.Tkioff-=1.2
		container.Tspeed-=1.2
		container.transBuff = fd_form_mult(container.fd_form) //volta ao multiplicador da forma atual
		container.reset_minor_godki()
		container.icer_poll_icon()
		..()
	do_first_godki_appearance() return
	do_godki_appearance() return

obj/overlay/icergod
	plane = AURA_LAYER
	name = "icer god aura"
	temporary = 1
	//appearance_flags = PIXEL_SCALE
	ID = 47
	pixel_y = -16
	o_py = -16
	var/timer=16
	icon='friezagod.dmi'
	EffectStart()
		spawn
			icon_state = "1"
			pixel_y = -16
			o_py = -16
			icon_state = ""
			container.overlays += src
			container.overlayList += src
			container.overlaychanged = 1
			icon_state = ""
			while(timer>=1)
				timer--
				pixel_y = -16
				o_py = -16
				sleep(1)
			container.overlays -= src
			container.overlayList -= src
			container.overlaychanged = 1
			EffectEnd()
		..()
