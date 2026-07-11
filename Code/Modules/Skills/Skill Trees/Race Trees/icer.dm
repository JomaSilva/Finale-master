// ============================================================================
// ARVORE RACIAL DO FROST DEMON + MOTOR DAS FORMAS (rework 2026-07-10)
//   O effector roda todo tick de stats e:
//   * aplica o transBuff AUTORITATIVO da forma atual (fd_form_mult);
//   * MUTANTE: acumula maestria da base (em forma 5+), roda o relogio de
//     instabilidade (forma acima do que ele segura -> perde o controle do ki ->
//     liberacao de BP despenca ate o piso), recupera em forma estavel e, com
//     100% de maestria, transforma as formas de supressao em BATERIA de ki.
//   Knobs FD_* no 1A Defines.dm. Formas/cinematica no IcerTransform.dm.
// ============================================================================
/datum/skill/tree/frostdemon
	name="Frost Demon Racials"
	desc="Given to all Frost Demons at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Frost Demon","Half-Breed")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,new/datum/skill/icer/Golden_Form)
	growbranches()
		if(savant.KOcount >= 100 && savant.Age > 10 && savant.BP >= godki_at * 0.9) enableskill(/datum/skill/icer/Golden_Form)
		if(savant.KOcount >= 500 && savant.BP >= godki_at * 0.1) enableskill(/datum/skill/icer/Golden_Form)
		..()
	effector()
		var/mob/S = savant
		if(!S || !S.fd_is_frost()) return
		if(!S.fd_form) S.fd_login_check() //save antigo que escapou do Login
		//multiplicador da forma (todo tick, igual as outras racas fazem com o ssjBuff)
		if(!S.isBuffed(/obj/buff/Golden_Form))
			S.transBuff = fd_form_mult(S.fd_form)
		if(!S.fd_is_mutant()) return //normal: base + evolucoes, sem instabilidade
		//---- MOTOR DO MUTANTE ----
		var/dt = 3 //fallback (~0.3s); dt real e robusto a cadencia do loop
		if(S.fd_engine_last) dt = min(max(world.time - S.fd_engine_last, 1), 50)
		S.fd_engine_last = world.time
		var/gate = S.fd_stable_gate()
		//maestria da base: cresce SEGURANDO o poder de verdade (forma 5 ou acima)
		if(S.fd_form >= 5 && !S.KO && !S.dead && S.fd_base_mastery < 100)
			var/oldm = S.fd_base_mastery
			S.fd_base_mastery = min(100, S.fd_base_mastery + FD_MASTERY_PER_MIN * dt / 600)
			for(var/step in list(25, 50, 75, 100))
				if(oldm < step && S.fd_base_mastery >= step) S.fd_mastery_msg(step)
		if(S.fd_form <= gate) //forma ESTAVEL: recupera o controle
			S.fd_unstable_since = 0
			if(S.fd_release < 1)
				S.fd_release = min(1, S.fd_release + (FD_RELEASE_RECOVER_PCT / 100) * dt / 10)
			if(S.fd_ki_locked && S.fd_release >= 1)
				S.fd_ki_locked = 0
				S.removeOverlay(/obj/overlay/effects/fd_menacing_red)
				to_chat(S, "<font color=#7ec87e><b>Seu ki se acalma -- voce recuperou o controle do seu poder.</b>")
			//BATERIA: 100% de maestria = supressao regenera ki passivo (mais suprimida = mais regen)
			if(S.fd_base_mastery >= 100 && S.fd_form < 5 && S.Ki < S.MaxKi && !S.dead)
				S.Ki = min(S.MaxKi, S.Ki + S.MaxKi * (FD_REGEN_PCT / 100) * (5 - S.fd_form) * dt / 10)
		else //forma ACIMA do que ele segura: o relogio corre
			if(!S.fd_unstable_since)
				S.fd_unstable_since = world.time
			var/limit = FD_LOSS_SECS_F5 * fd_form_losstime(S.fd_form) * (1 + S.fd_base_mastery / 50) * 10 //ticks; maestria ALONGA o fusivel (100% = 3x)
			if(!S.fd_ki_locked)
				if(world.time - S.fd_unstable_since >= limit)
					S.fd_ki_locked = 1
					S.updateOverlay(/obj/overlay/effects/fd_menacing_red)
					S.emit_Sound('chargeaura.wav')
					to_chat(S, "<font color=#ff5544><b>SEU KI SAIU DO CONTROLE!</b> Voce nao consegue mais reunir energia -- e seu poder vai comecar a VAZAR. Recue para uma forma de supressao estavel!")
				else if(world.time - S.fd_unstable_since >= limit * 0.6 && world.time >= S.fd_warn_cd)
					S.fd_warn_cd = world.time + 100
					to_chat(S, "<font color=#ffcc55>Seu ki treme -- o controle esta escapando...")
			else if(S.fd_release > FD_RELEASE_FLOOR) //controle perdido: a liberacao despenca ate o piso
				S.fd_release = max(FD_RELEASE_FLOOR, S.fd_release - (FD_RELEASE_DECAY_PCT / 100) * dt / 10)
				if(world.time >= S.fd_warn_cd)
					S.fd_warn_cd = world.time + 150
					to_chat(S, "<font color=#ff5544>Seu poder esta VAZANDO! (liberacao: [round(S.fd_release * 100)]%)")

mob/var/list/icer_vars = list("Form 6 Seperate Icon"=1,"Form 6 base"=1,"Form 6 color"=list(231,228,62),"Form 6 Aura"='transformaura.dmi') //chaves antigas mantidas (compat de save); hoje descrevem o GOLDEN

//menu de formas (atribuido a todo Frost Demon no fd_login_check/criacao)
verb/Icer_Form_Settings()
	set category = "Other"
	if(!usr.fd_is_frost()) return
	switch(input(usr,"O que deseja ajustar? (Re-escolher corpos REVERTE voce para a forma inicial.)","Formas","Cancelar") in list("Re-escolher corpos das formas","Atributos do Golden","Cancelar"))
		if("Re-escolher corpos das formas")
			usr.formchoose("Frost Demon") //re-abre o picker da criacao (slots por classe); aplica e reverte pra forma inicial
			usr.icer_poll_icon()
		if("Atributos do Golden")
			switch(input(usr,"O Golden pode usar um icone proprio, ou uma das suas formas (1 a 5) recolorida. A aura do Golden tambem e ajustavel aqui.") in list("Usar icone proprio","Usar uma forma como base","Cor","Aura do Golden","Cancelar"))
				if("Cor")
					var/newrgb=input("Escolha uma cor.","Cor",0) as color
					var/list/oldrgb=0
					oldrgb=hrc_hex2rgb(newrgb,1)
					while(!oldrgb)
						sleep(1)
						oldrgb=hrc_hex2rgb(newrgb,1)
					usr.icer_vars["Form 6 color"][1] = oldrgb[1]
					usr.icer_vars["Form 6 color"][2] = oldrgb[2]
					usr.icer_vars["Form 6 color"][3] = oldrgb[3]
				if("Usar icone proprio")
					usr.icer_vars["Form 6 Seperate Icon"] = TRUE
					to_chat(usr, "O Golden agora usa o icone proprio (goldicon).")
				if("Usar uma forma como base")
					usr.icer_vars["Form 6 Seperate Icon"] = FALSE
					usr.icer_vars["Form 6 base"]=round(min(max(input(usr,"Numero da forma (1 a 5) que o Golden usa como base.","",1) as num,1),5))
				if("Aura do Golden")
					switch(input(usr,"Aura padrao ou icone custom?","","Cancelar") in list("Cancelar","Custom","Padrao"))
						if("Custom")
							if(!usr.can_upload_icon()) return //upload de icone: so admin
							usr.icer_vars["Form 6 Aura"] = input(usr,"","Aura do Golden",usr.icer_vars["Form 6 Aura"]) as icon
						if("Padrao") usr.icer_vars["Form 6 Aura"] = 'transformaura.dmi'
	usr.icer_poll_icon()

/datum/skill/icer/Golden_Form
	skilltype="Ki"
	name="Golden Form"
	desc="Tap into your Golden Form, granting you an even higher boost than your final evolution. In addition, it'll give you God Ki energy (but not anything else) temporarily. Has a high strain on the body."
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 1
	enabled=0

	after_learn()
		assignverb(/mob/keyable/verb/Golden_Form)
		to_chat(savant, "Your body shimmers a bit, releasing a hue of gold light. The power within explodes, and a new godly tone empowers your body!")
	login()
		..()
		assignverb(/mob/keyable/verb/Golden_Form)

mob/keyable/verb/Golden_Form()
	set category = "Skills"
	if(isBuffed(/obj/buff/Golden_Form))
		startbuff(/obj/buff/Golden_Form)
	else stopbuff(/obj/buff/Golden_Form)
