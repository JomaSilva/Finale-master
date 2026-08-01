mob/var
	legendary=0

	hasssj=0
	ssj=0
	ssjat=1500000 //1.5 million. This is the base BP req.
	ssjadd=50000000
	ssjmult=2
	ssjdrain=0.025 //1/4 of a stamina point per second. That's what this represents. It's not 0.25, we're pre-dividing it by 10 for 1 tenth of a second.
	ssjmod=1
	ssj1mastery=0 //maestria do SSJ1 (0-100). Sobe em DEGRAUS pela %: 2x ->(66%) 4x ->(100%) 6x. Ao 100% = Super Saiyajin completamente dominado (ismssj).
	ssjmasteryMigrated=0 //flag de migracao unica: converte o progresso antigo (niveis de skill) em maestria % no primeiro login
	ssj1base=2 //base (tier 1) do SSJ1 por raca/nerf: 2 normal, 1.35 Half/diluido/canSSJ. Capturada 1x; o degrau base usa este valor (mestre vai ao topo normal 6x)
	ssj2base=4 //base do SSJ2 (4 normal, 1.75 nerfado)
	ssj3base=16 //base do SSJ3 (16 normal, 2 nerfado)
	ssjBaseCaptured=0 //flag: ja capturei as bases por-raca/nerf
	ultrassjenabled=0
	ultrassjat=750000000 //750mil for ultassj.
	ultrassjmult=3 //so sobrevive para as racas NERFADAS/canSSJ (1.45): o grade normal deriva de ssj1base
	ultrassjdrain=0.050
	ssj_grade_active=0 //grade em que o jogador ESTA agora (0/2/3). NAO-tmp: ssj e salvo, o grade tem que acompanhar
	ssj_grade_seen=0   //bitmask dos grades cuja cinematica de primeira vez ja rodou
	ssjGradesMigrated=0 //flag 1x da migracao do USSJ comprado para os GRADES
	ssj_grade_sel=0    //grade SELECIONADO no toggle (0 = nenhum -- default, senao o SSJ2 fica trancado)
	firsttime=0
	ssj1_music_played=0 //first-transformation theme flags; persist in saves so each plays only once ever (like ssj3firsttime)
	ssj2_music_played=0
	blue_music_played=0
	ssj4_music_played=0
	legprimal_lssj_music_played=0 //Primal Legendary's "Legendary Super Saiyan" (ssj=2) theme, first time only
	trans=0
	hastrans=0
	hastrans2=0

	hasssj2=0
	ssj2=0
	ssj2at=3.5e009//3.5billion BP for ssj2. It looks like alot, but SSJ is a 50x multiplier. You'd need a base BP of 70,000,000 to get SSJ2, which is less than DU's req actually.
	ssj2add=50000000
	ssj2mult=4
	ssj2drain=0.040
	ssj2mod=1
	ssj2mastery=0 //maestria do SSJ2 (0-100). Degraus: 4x ->(50%) 6x ->(75%) 8x ->(100%) 10x.

	ssj3firsttime=1
	ssj3able=0
	ssj3hitreq=0
	ssj3=0
	ssj3at=2e010//20 billion. (about 150 million)
	ssj3mult=16
	ssj3drain=0.075
	ssj3mod=1
	ssj3mastery=0 //maestria do SSJ3 (0-100). Degraus: 16x ->(100%) 20x.

	ssj4at=1.0e011//100 billion EXPRESSOS durante o Golden Oozaru (gate secundario; com o raw novo isso passa sozinho)
	rawssj4at = 15000000000 //REWORK 2026-07-10: SSJ4 na casa dos 10/20 BILHOES de BP base (a criacao sorteia 0.9-1.3x -> 13.5B-19.5B; era 200M). Retro: ssj4_gate_login_fix
	hasssj4
	ssj4hair = 'Hair_SSj4.dmi'
	ssj4mult=20 //SSJ4 base (escala ate ssj4maxmult conforme a maestria do SSJ4)
	ssj4maxmult=40 //SSJ4 com 100% de maestria
	ssj4fpmult=32 //SSJ4 Full Power base (estagio acima do SSJ4)
	ssj4fpmaxmult=50 //SSJ4 Full Power com 100% de maestria
	ssj4fplbmult=56 //SSJ4 Limit Breaker (God Form, multiplicador fixo)
	ssj4mastery=0 //maestria do SSJ4 (0-100); ao 100% libera o Full Power
	ssj4fpmastery=0 //maestria do SSJ4 Full Power (0-100); ao 100% libera a COMPRA do Limit Breaker
	hasSSJ4FP=0 //liberou a forma SSJ4 Full Power (ao masterizar 100% o SSJ4)
	legp_m2=0 //Primal Legendary: maestria do SSJ2 ("Legendary Super Saiyan"), 6x->9x
	legp_m3=0 //Primal Legendary: maestria do SSJ3 ("Legendary Super Saiyan 2/3"), 9x->18x

	ssjenergymod = 2 //USSJ doesn't have a energy increase, it uses SSJ's energy mod.
	//'ussjenergymod' refers therefore to unrestrained super saiyan's mod.
	ssj2energymod = 3
	ssj3energymod = 3.5
	ssj4energymod = 4.5 //energy for days in SSJ4.

	//
obj/buff/SuperSaiyan
	name = "Super Saiyan"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
	blue_effect=1
	persistant=TRUE
obj/buff/SuperSaiyan/Buff()
	lastForm=0
	..()
//Dreno de Ki das formas SSJ: fracao do MaxKi consumida por ciclo do BuffLoop (~4x/seg), multiplicada pelo drain da forma (ssjdrain/ssj2drain/ssj3drain...).
//Ex.: SSJ3 nao-masterizado ssj3drain=0.075 -> 0.075*0.4 = 3% do MaxKi por ciclo do BuffLoop (~0.8x/seg) -> ~2.4%/seg, idle ~25s. Aumente TRANS_KI_DRAIN para drenar mais rapido.
#define TRANS_KI_DRAIN 0.4
obj/buff/SuperSaiyan/Loop()
	if(!container.transing)
		switch(container.ssj)
		//essentially, after you're done transforming, SSJ drains stamina straight up- it will not revert you if you're low on stamina, that'd be your job to safeguard that.
		//it will also drain a tiny amount of ki, and will revert you based on that, so if you use everything you've got, you'll drop out of SSJ.
			//Super Saiyan Drain
			if(1) if(container.ssjdrain)
				if(container.stamina>=container.maxstamina*container.ssjdrain||container.dead)
					container.Ki-=container.MaxKi*container.ssjdrain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo, escala com o drain da forma (nao-masterizada drena mais; maestria reduz ssjdrain)
					if(container.Ki<=container.MaxKi*container.ssjdrain)
						container.tooTiredRevert()
					container.stamina -= trans_drain*max(0.001,container.ssjdrain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert(0)
			//Ultra Super Saiyan Drain
			if(1.5) if(container.ultrassjdrain)
				if(container.stamina>=container.maxstamina*container.ultrassjdrain||container.dead)
					container.Ki-=container.MaxKi*container.ultrassjdrain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo
					if(container.Ki<=container.MaxKi*container.ultrassjdrain)
						container.tooTiredRevert()
					container.stamina -= trans_drain*max(0.001,container.ultrassjdrain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert(0)
			//Super Saiyan 2 Drain
			if(2) if(container.ssj2drain)
				if(container.stamina>=container.maxstamina*container.ssj2drain||container.dead)
					container.Ki-=container.MaxKi*container.ssj2drain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo
					if(container.Ki<=container.MaxKi*container.ssj2drain)
						container.tooTiredRevert()
					container.stamina -= trans_drain*max(0.001,container.ssj2drain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert(0)
			//Super Saiyan 3 Drain
			if(3) if(container.ssj3drain)
				if(container.stamina>=container.maxstamina*container.ssj3drain||container.dead)
					container.Ki-=container.MaxKi*container.ssj3drain*TRANS_KI_DRAIN //dreno de Ki = % do MaxKi por ciclo
					if(container.Ki<=container.MaxKi*container.ssj3drain)
						container.tooTiredRevert()
					container.stamina -= trans_drain*max(0.001,container.ssj3drain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
				else container.Revert(0)
			if(3.5) if(container.ssj3drain) //LSSJ3 (Primal Legendary): dreno estilo SSJ3
				if(container.stamina>=container.maxstamina*container.ssj3drain||container.dead)
					container.Ki-=container.MaxKi*container.ssj3drain*TRANS_KI_DRAIN
					if(container.Ki<=container.MaxKi*container.ssj3drain)
						container.tooTiredRevert()
					container.stamina -= trans_drain*max(0.001,container.ssj3drain)
				else container.Revert(0)
			//Super Saiyan 4 Tail Check + Energy Gain
			if(4)
				if(!container.Tail)
					to_chat(view(container), "[container]'s tail was lost, reverting them from SSJ4!")
					DeBuff()
				if(prob(15)) container.Ki+=0.002 * container.MaxKi //ki gains a bit of energy.
				//there is no stamina loss from SSJ4.
				if(container.ssj4mastery < 100) //maestria do SSJ4 cresce na forma; ao 100% libera o Full Power automaticamente
					container.ssj4mastery = min(100, container.ssj4mastery + 0.0116) //~3h de uso continuo para masterizar (buff Loop ~0.8x/s)
					container.ssjBuff = container.ssj_effective_mult()
				if(container.ssj4mastery >= 100 && !container.hasSSJ4FP) //FORA do <100: libera o Full Power sempre que estiver 100% (mesmo se ja entrou em 100%, ex.: save antigo)
					container.hasSSJ4FP = 1
					container.testunlocks()
					to_chat(container, "<font color=#ffcc33>You have completely mastered Super Saiyan 4! Super Saiyan 4 Full Power is now available - transform again to ascend.</font>")
			if(5)
				if(!container.Tail)
					to_chat(view(container), "[container]'s tail was lost, reverting them from SSJ4 Full Power!")
					DeBuff()
				if(prob(15)) container.Ki+=0.002 * container.MaxKi //SSJ4 Full Power: sem dreno de stamina
				if(container.ssj4fpmastery < 100) //maestria do Full Power; ao 100% libera a COMPRA do Limit Breaker
					container.ssj4fpmastery = min(100, container.ssj4fpmastery + 0.0099) //~3.5h de uso continuo (forma mais dificil de dominar)
					container.ssjBuff = container.ssj_effective_mult()
					if(container.ssj4fpmastery >= 100)
						container.testunlocks()
						if(!container.hasFPLB)
							to_chat(container, "<font color=#ff66cc>You have completely mastered Super Saiyan 4 Full Power! You may now learn the Super Saiyan 4 Limit Breaker.</font>")
			if(6)
				if(!container.Tail)
					to_chat(view(container), "[container]'s tail was lost, reverting them from SSJ4 Limit Breaker!")
					DeBuff()
				if(prob(15)) container.Ki+=0.002 * container.MaxKi //SSJ4 Limit Breaker: sem dreno de stamina
		if(container.ssj >= 1 && container.ssj <= 3.5 && container.Ki <= container.MaxKi*0.02) //Ki esgotado: reverte qualquer SSJ1-3.5, INCLUSIVE masterizada (que tem dreno 0 e nao roda o bloco de dreno acima)
			container.tooTiredRevert()
		if(container.Class != "Legendary Primal Saiyan" && !container.FutureLineage && (!container.canSSJ || container.bio_lab_born)) //SSJ1/2/3 padrao: a maestria (%) cresce na forma. O BIO de laboratorio (canSSJ=1) PRECISA ganhar maestria: dominar o SSJ1 (100%) e requisito do despertar do SSJ2 dele
			switch(container.ssj)
				if(1)
					container.ssj1_mastery_tick(0.0174) //~2h de uso continuo (forma mais facil)
				if(1.5)
					container.ssj1_mastery_tick(0.0174 * SSJ_GRADE_MASTERY_RATE) //dentro de um GRADE a maestria do SSJ1 rende METADE:
					                                                             //sem isto o jogador viveria no grade (3x/4x) e nunca chegaria aos 100%/6x
				if(2)
					if(container.ssj2mastery < 100)
						container.ssj2mastery = min(100, container.ssj2mastery + 0.0116) //~3h
						container.recompute_saiyan_form_mults()
						if(container.ssj2mastery >= 100)
							container.testunlocks() //SSJ2 100% -> cascade em supersaiyan.dm libera o SSJ3
				if(3)
					if(container.ssj3mastery < 100)
						container.ssj3mastery = min(100, container.ssj3mastery + 0.0099) //~3.5h
						container.recompute_saiyan_form_mults()
						if(container.ssj3mastery >= 100)
							container.testunlocks()
		if(container.Class == "Legendary Primal Saiyan") //Primal Legendary: maestria das formas que escalam (SSJ2/SSJ3); SSJ4/FP usam ssj4mastery/ssj4fpmastery
			if(container.ssj == 2) container.legp_m2 = min(100, container.legp_m2 + 0.0116)
			else if(container.ssj == 3) container.legp_m3 = min(100, container.legp_m3 + 0.0116)
		if(container.ssj) container.ssjBuff = container.ssj_effective_mult() //mantem o ssjBuff vivo: reflete a maestria atual + aplica o piso (forma anterior +2x)
	if(lastForm!=container.ssj)
		container.mst_note_form() //testemunhas por perto registram a forma vista (MasterStudent.dm)
		var/_oldTKM = container.trueKiMod //keep Ki% on EVERY form change: remember the old form's ki multiplier before it is reset
		lastForm=container.ssj
		container.remove_ussj_body() //changed form: drop the USSJ muscular body back to the saved base icon (no-op if not swapped)
		container.RemoveHair()
		container.overlayList-='Elec.dmi'
		container.overlayList-='Electric_Blue.dmi'
		container.overlayList-='ElecAura1.dmi'
		container.overlayList-='SSj4_Body.dmi'
		container.overlayList-='Electric_Yellow.dmi'
		container.removeOverlay(/obj/overlay/effects/electrictyeffects)
		container.removeOverlay(/obj/overlay/body/saiyan/saiyan4body) //limpa overlays de corpo ao trocar de forma (evita SSJ4/FPLB sobrepostos)
		container.removeOverlay(/obj/overlay/body/saiyan/saiyan5body)
		container.removeOverlay(/obj/overlay/effects/ssj4lb_sparks)
		container.removeOverlay(/obj/overlay/effects/ssj4lb_lightning)
		container.AddHair()
		container.MaxKi = container.MaxKi / container.trueKiMod
		container.trueKiMod = 1
		switch(container.ssj)
			if(1)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssjenergymod
				container.MaxKi *= container.trueKiMod
				//if(container.ssjdrain<=0.010) container.updateOverlay(/obj/overlay/hairs/ssj/ssj1fp)
				//else container.updateOverlay(/obj/overlay/hairs/ssj/ssj1)
			if(1.5)
				//if(container.ssjdrain<=0.010) container.updateOverlay(/obj/overlay/hairs/ssj/ssj1fp)
				//else container.updateOverlay(/obj/overlay/hairs/ssj/ussj)
				container.trueKiMod = container.ssjenergymod
				container.MaxKi *= container.trueKiMod
				container.ssjBuff = container.ssj_effective_mult()
				container.updateOverlay(/obj/overlay/effects/electrictyeffects/reg_elec)
				container.apply_ussj_body() //USSJ: bulk the body to its muscular skin (by skin tone)
			if(2)
				//container.updateOverlay(/obj/overlay/hairs/ssj/ssj2)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssj2energymod
				container.MaxKi *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects)
			if(3)
				//container.updateOverlay(/obj/overlay/hairs/ssj/ssj3)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssj3energymod
				container.MaxKi *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects)
				container.overlayList-='ElecAura1.dmi'
				container.overlayList+='ElecAura1.dmi' //eletricidade visivel do SSJ3 (pedido do user), como o SSJ2 tem
				container.overlayList-='Electric_Blue.dmi'
				container.overlayList+='Electric_Blue.dmi'
			if(3.5) //LSSJ3 (Primal Legendary)
				container.ssjBuff = container.ssj_effective_mult()
				container.trueKiMod = container.ssj3energymod
				container.MaxKi *= container.trueKiMod
				container.updateOverlay(/obj/overlay/effects/electrictyeffects)
			if(4)
				container.updateOverlay(/obj/overlay/body/saiyan/saiyan4body)
				container.ssjBuff=container.ssj_effective_mult()
				container.trueKiMod = container.ssj4energymod
				container.MaxKi *= container.trueKiMod
			if(5) //SSJ4 Full Power
				container.updateOverlay(/obj/overlay/body/saiyan/saiyan5body)
				container.ssjBuff=container.ssj_effective_mult()
				container.trueKiMod = container.ssj4energymod
				container.MaxKi *= container.trueKiMod
			if(6) //SSJ4 Limit Breaker (God Form)
				container.updateOverlay(/obj/overlay/body/saiyan/saiyan5body)
				container.updateOverlay(/obj/overlay/effects/ssj4lb_sparks) //aura constante do Limit Breaker
				container.updateOverlay(/obj/overlay/effects/ssj4lb_lightning)
				container.ssjBuff=container.ssj_effective_mult()
				container.trueKiMod = container.ssj4energymod
				container.MaxKi *= container.trueKiMod
		if(_oldTKM) //keep the SAME Ki% across the form change (up OR down) by scaling Ki with the MaxKi/trueKiMod change
			container.Ki = container.Ki * container.trueKiMod / _oldTKM
	if(container.godki && container.godki.usage) //teto da maestria: SSJ acima do permitido derruba a forma (fecha ate o Blue-por-raiva abaixo dos 33%; ritual tem cap 10 = livre)
		if(container.trans_min_val < container.ssj)
			container.Revert()
	..()
obj/buff/SuperSaiyan/Delevel()
	if(container.ssj == 1.5)
		container.ssj = 1
		container.ssj_grade_active = 0 //saiu do grade: nao deixa grade fantasma pra proxima entrada
	else if(container.ssj == 3.5) container.ssj = 3
	else container.ssj--
	if(container.ssj < 1) DeBuff()
obj/buff/SuperSaiyan/DeBuff()
	container.ssjBuff = 1
	container.ssj_grade_active = 0
	var/_oldTKM = container.trueKiMod //keep Ki% when fully reverting to base
	container.MaxKi = container.MaxKi / container.trueKiMod
	container.trueKiMod = 1
	container.RemoveHair()
	container.overlayList-='Electric_Yellow.dmi'
	container.overlayList-='Elec.dmi'
	container.removeOverlay(/obj/overlay/body/saiyan/saiyan4body)
	container.removeOverlay(/obj/overlay/body/saiyan/saiyan5body)
	container.removeOverlay(/obj/overlay/effects/ssj4lb_sparks)
	container.removeOverlay(/obj/overlay/effects/ssj4lb_lightning)
	container.updateOverlay(/obj/overlay/hairs/hair)
	container.removeOverlay(/obj/overlay/effects/electrictyeffects)
	container.remove_ussj_body() //fully reverted: restore the pre-USSJ base body icon
	if(container.ssj==1.5)
		if(container.expandlevelussj>0)
			sleep(0)
			container.ExpandRevert()
	if(_oldTKM > 1) //keep the same Ki% relative to base MaxKi when dropping to base (logout scales down, relog's buff re-add scales back up -> consistent)
		container.Ki = container.Ki / _oldTKM
	if(container.Ki>container.MaxKi*2)
		container.Ki = container.MaxKi*2
	..()

mob/proc/SSj()
	if(!transing)
		if(Class == "Prodigial" && godki && godki.usage) return //Prodigial NAO tem Blue: o caminho divino dele e o Mistico/Beast (catch-all de TODAS as portas)
		if(cantSustainForm(ssjdrain)) return //sem Ki pra sustentar: nao vira SSJ1
		Revert()
		transing=1
		if(godki && godki.usage)
			if(!blue_music_played) //SSJ1 while in God Ki = Super Saiyan Blue: Blue theme from the START (first time only)
				blue_music_played=1
				emit_TransformMusic('Dragon Ball Z Dokkan Battle AGL LR Super Saiyan Blue Goku & Vegeta Intro OST (Extended).mp3', 6236) //Blue theme: plays to everyone nearby + ducks listeners' battle music for the track (~10.4min)
		else
			if(!ssj1_music_played) //first regular Super Saiyan: SSJ1 theme from the START
				ssj1_music_played=1
				emit_TransformMusic('Dragon Ball Z Dokkan Battle TEQ LR SSJ Goku Revival OST (Extended).mp3', 6107) //SSJ1 theme (~10.2min)
		attackable=0
		var/ssjcolor = "yellow"
		if(godki && godki.usage) ssjcolor = "blue"
		if(godki && godki.usage) to_chat(view(8), "<font color=#33ccff>[src]: We Saiyans have no limits!</font>") //fala ao virar Blue (Super Saiyajin em modo God Ki)
		poweruprunning=1
		if(!firsttime)
			SSJCinematic()
			Super_Saiyan_Stats()
			poweruprunning=0
		if(!Apeshit)
			if(!hasssj)
				ssjat/=2
			poweruprunning=0
			hasssj=1
			emit_Sound('powerup.wav')
			spawn Quake()
			createShockwavemisc(loc,1)
			to_chat(view(src), "<font color=[ssjcolor]>*A great wave of power emanates from [src]!*")
			spawn if(ssjdrain==0.025) Quake()
			sleep(1000*ssjdrain)
			spawn if(ssjdrain>0.01) Quake()
			emit_Sound('chargeaura.wav')
			if(Race == "Bio-Android" || Parent_Race == "Bio-Android" || bio_lab_born) //bio-androide nao tem cabelo: descricao PROPRIA da transformacao
				to_chat(view(src), "<font color=[ssjcolor]>*As placas da carapaca de [src] estalam e uma aura dourada EXPLODE ao seu redor -- o poder Saiyajin em seu DNA desperta!*")
			else
				to_chat(view(src), "<font color=[ssjcolor]>*[src]'s hair stands on end and turns [ssjcolor]!*")
			ssj=1
			bp_milestone_reach("ssj") //MARCO: primeiro Super Saiyajin
			if(godki && godki.usage) bp_milestone_reach("blue") //MARCO: Super Saiyajin BLUE (SSJ em God Ki)
			createCrater(loc,5)
			
			spawn startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
			if(!AscensionStarted)
				AscensionStarted = 1
				to_chat(world, "Ascension has started.")
		transing=0
		attackable=1
		poweruprunning=0
mob/var/ussj_saved_icon = null //base body icon stashed while USSJ swaps it for the muscular skin (so revert restores it); persistent so a relog mid-USSJ still reverts right

//USSJ bulks the body up: swap the standard male skin to its muscular variant, picked by skin tone (white/pale, tan, black).
mob/proc/apply_ussj_body()
	if(ussj_saved_icon) return //already swapped this transformation
	var/musc = null
	if(icon == 'White Male.dmi' || icon == 'BaseWhiteMale.dmi') musc = 'White Male Muscular 3.dmi'
	else if(icon == 'Tan Male.dmi' || icon == 'BaseTanMale.dmi') musc = 'Tan Male Muscular.dmi'
	else if(icon == 'Black Male.dmi' || icon == 'BaseBlackMale.dmi') musc = 'BlackMaleMuscular3.dmi'
	if(musc)
		ussj_saved_icon = icon
		icon = musc

mob/proc/remove_ussj_body()
	if(!ussj_saved_icon) return
	icon = ussj_saved_icon
	ussj_saved_icon = null

//GRADES DO SSJ1 (o antigo Ultra Super Saiyan). O typepath e o estado ssj=1.5 foram MANTIDOS de
//proposito: 1.5 e valor semantico em dois motores fora daqui (godki_ssj_cap do Super Saiyan Royale
//e o teto trans_min_val do Loop), alem de carregar cabelo, aura, eletricidade, corpo musculoso,
//dreno proprio e o Delevel 1.5->1 sem nenhuma linha extra.
mob/proc/Ultra_SSj(grade = 0)
	if(!transing)
		if(Class == "Prodigial" && godki && godki.usage) return //Prodigial nao acessa o Royale (catch-all)
		if(ssj>=2) return
		if(!grade) //sem grade explicito (dispatcher/DirectSSJ): resolve pelo seletor e clampa no desbloqueado
			grade = ssj_grade_sel ? ssj_grade_sel : ssj_grade_unlocked()
			if(!grade) grade = 2
			if(ssj_grade_unlocked()) grade = min(grade, ssj_grade_unlocked())
		if(godki && godki.usage) grade = 2 //SUPER SAIYAN ROYALE: o caminho divino so tem o Grade 2
		if(cantSustainForm((grade >= 3) ? SSJ_GRADE3_DRAIN : SSJ_GRADE2_DRAIN)) return //testa ANTES de commitar o grade
		ssj_grade_active = grade
		recompute_saiyan_form_mults() //acerta o ultrassjdrain do grade escolhido
		transing=1
		attackable=0
		var/ssjcolor = "yellow"
		if(godki?.usage) ssjcolor = "blue"
		var/ussjcolor = "gold"
		if(godki?.usage) ussjcolor = "royal blue"
		if(!(ssj_grade_seen & (1 << grade))) //bits DISJUNTOS: com a mascara crua, 2 & 3 = 2 e o Grade 3 nunca estreava
			ssj_grade_seen |= (1 << grade)
			UltraSSJCinematic()
		hasussj=1 //legado: varias telas/gates antigos ainda leem esta flag
		to_chat(view(src), "<font color=[ssjcolor]>*[src] begins to power up beyond their Super Saiyan power*")
		emit_Sound('chargeaura.wav')
		spawn Quake()
		sleep(1000*ultrassjdrain)
		spawn Quake()
		emit_Sound('aura.wav')
		to_chat(view(src), "<font color=[ssjcolor]>*[src]'s Super Saiyan power becomes a more spikey [ussjcolor]!* (Grade [grade])")
		ssj=1.5
		bp_milestone_reach("ussj") //MARCO: Ultra SSJ
		if(godki && godki.usage) bp_milestone_reach("blue") //MARCO: Blue Evolution (USSJ em God Ki)
		createCrater(loc,3)
		if(!isBuffed(/obj/buff/SuperSaiyan))
			startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
		transing=0
		attackable=1
		spawn(100) overlayList-='SSj Aura.dmi'
mob/proc/SSj2()
	if(!transing)
		if(FutureLineage) return //Future Lineage: forma unica (SSJ1 em estagios), nao acessa SSJ2
		if(Class == "Prodigial" && godki && godki.usage) return //Prodigial nao empilha SSJ no God Ki (catch-all)
		if(bio_lab_born && !bio_ssj2_by_death) //BIO de laboratorio: o SSJ2 dele SO desperta morrendo com os 3 requisitos (DNALabs.dm) -- nenhuma via de raiva/arvore vale
			hasssj2 = 0 //desfaz qualquer hasssj2 concedido por engano pelas vias saiyajin (era o pulo direto pro 8x)
			to_chat(src, "<font color=#ffd24a>O Super Saiyajin 2 nao responde... seu nucleo bio exige um gatilho mais extremo que a raiva.</font>")
			return
		if(ssj>=3) return
		if(cantSustainForm(ssj2drain)) return
		transing=1
		if(godki && godki.usage)
			if(!blue_music_played) //SSJ2 while in God Ki = Super Saiyan Blue: Blue theme from the START (first time only)
				blue_music_played=1
				emit_TransformMusic('Dragon Ball Z Dokkan Battle AGL LR Super Saiyan Blue Goku & Vegeta Intro OST (Extended).mp3', 6236) //Blue theme: plays to everyone nearby + ducks listeners' battle music for the track (~10.4min)
		else if(Class=="Legendary Primal Saiyan") //for the Primal Legendary, ssj=2 IS the "Legendary Super Saiyan" form -> its own theme (not the normal SSJ2 one)
			if(!legprimal_lssj_music_played)
				legprimal_lssj_music_played=1
				emit_TransformMusic(file("Sounds/Music/10's.mp3"), 2899) //~290s; file()+full path (the apostrophe in "10's" can't live in a 'literal')
		else
			if(!ssj2_music_played) //first regular Super Saiyan 2: SSJ2 theme from the START
				ssj2_music_played=1
				emit_TransformMusic('Dragon Ball Z   Day Of Fate Unmei No Hi (Hironobu Kageyama)   By Gladius.mp3', 2623) //SSJ2 theme (~4.4min)
		attackable=0
		var/ssjcolor = "yellow"
		if(godki?.usage) ssjcolor = "blue"
		ultrassjenabled=0
		if(ssj_grade_sel) //o SSJ2 desliga os grades: limpa o seletor junto, senao o toggle passa a mentir
			ssj_grade_sel = 0
			to_chat(src, "<font color=yellow>Seu seletor de SSJ Grade foi zerado -- o SSJ2 nao empilha com os grades.")
		if(ssj2drain>=0.036&&firsttime==1&&!bio_lab_born) //bio: a cinematica do SSJ2 dele e a do despertar por morte (curta, em DNALabs.dm), nao a saiyajin
			Super_Saiyan_Stats()
			SSJ2Cinematic()
			poweruprunning=0
		if(!legendary)
			if(!hasssj2) ssj2at/=2
			hasssj2=1
			overlayList-='Elec.dmi'
			overlayList+='Elec.dmi'
			emit_Sound('powerup.wav')
			spawn Quake()
			createShockwavemisc(loc,3)
			to_chat(view(6), "<font color=[ssjcolor]>*A great wave of power emanates from [src] as a [ssjcolor] aura bursts around them!*")
			spawn if(ssj2drain==0.025) Quake()
			sleep(600 * ssj2drain)
			emit_Sound('chargeaura.wav')
			spawn if(ssj2drain>0.01) Quake()
			ssj=2
			bp_milestone_reach("ssj2") //MARCO: SSJ2
			if(godki && godki.usage) bp_milestone_reach("blue") //MARCO: Blue (SSJ2 em God Ki)
			createCrater(loc,5)
			if(!isBuffed(/obj/buff/SuperSaiyan))
				startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
			to_chat(view(6), "<font color=[ssjcolor]>*Blue sparks begin to burst around [src]!*")
		transing=0
		attackable=1
/obj/overlay/auras/transform_aura
	pixel_x = -24
	o_px = -24
	icon = 'transformaura.dmi'

mob/proc/SSj3()
	if(!transing)
		if(FutureLineage) return //Future Lineage: forma unica (SSJ1 em estagios), nao acessa SSJ3
		if(firsttime==2) Super_Saiyan_Stats()
		if(ssj>=4) return
		if(cantSustainForm(ssj3drain)) return
		transing=1
		attackable=0
		poweruprunning=1
		SSJ3Cinematic()
		//---
		var/ssjcolor = "yellow"
		if(godki && godki.usage) ssjcolor = "blue"
		move=1
		overlayList-='ss3transformaurafinal.dmi'
		overlayList-='Elec.dmi'
		overlayList-='Electric_Blue.dmi'
		removeOverlay(/obj/overlay/effects/electrictyeffects)
		updateOverlay(/obj/overlay/effects/electrictyeffects)
		//prep phase over
		var/ismastered3
		for(var/datum/skill/forms/F in learned_skills) //might need to be changed-would save resources if made a variable. But again, more confusing ass variables, ugh.
			switch(F.name)
				if("Super Saiyan Three")
					if(F.level==3)
						ismastered3=1
		if(!ismastered3)
			updateOverlay(/obj/overlay/auras/transform_aura)
			sleep(100)
			if(!ssj3firsttime) to_chat(view(6), "<font color=[ssjcolor]>*A great wave of power emanates from [src] as a [ssjcolor] aura bursts around them!*")
			spawn for(var/mob/M in player_list)
				if(M.Planet == src.Planet)
					M.Quake()
			sleep(100)
			if(!ssj3firsttime) to_chat(view(8), "<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHH!!!!")
			spawn for(var/mob/M in player_list)
				if(M.Planet == src.Planet)
					M.Quake()
			spawn Quake()
			to_chat(view(8), "<font color=[ssjcolor]>*[src]'s screams die down!!*")
			if(!ssj3firsttime) sleep(2000*ssj3drain)
			if(powerMod<=1) removeOverlay(/obj/overlay/auras/aura)
		createShockwavemisc(loc,4)
		emit_Sound('powerup.wav')
		spawn Quake()
		createCrater(loc,5)
		sleep(10)
		if(!isBuffed(/obj/buff/SuperSaiyan))
			startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
		ssj=3
		bp_milestone_reach("ssj3") //MARCO: SSJ3
		to_chat(view(6), "<font color=[ssjcolor]>*[src]'s aura spikes upward as their hair grows longer!*")
		emit_Sound('chargeaura.wav')
		if(ssj3firsttime)
			ssj3firsttime=0
		poweruprunning=0
		transing=0
		attackable=1
mob/proc/ssj4_form_mult() //multiplicador atual do tier SSJ4 conforme a forma e a maestria acumulada
	switch(ssj)
		if(4) . = ssj4mult + (ssj4maxmult - ssj4mult) * ssj4mastery / 100
		if(5) . = ssj4fpmult + (ssj4fpmaxmult - ssj4fpmult) * ssj4fpmastery / 100
		if(6) . = ssj4fplbmult
		else . = 1
	//(Legendary Primal NAO passa por aqui: ssj_effective_mult desvia pro legprimal_form_mult, que ja tem o LSSJ4 22-44x proprio)

mob/proc/LSSj3_Primal() //Primal Legendary: Legendary Super Saiyan 3 (ssj=3.5, acima do LSSJ2; animacao verde propria)
	if(Class != "Legendary Primal Saiyan") return
	if(transing) return
	if(ssj != 3) return
	transing=1
	attackable=0
	emit_Sound('powerup.wav')
	createShockwavemisc(loc,3)
	spawn Quake()
	to_chat(view(8), "<font color=#2ef548 size=[TextSize]>[src]: HAAAAAAAAAAAHHHHHHH!!!!")
	animate(src,time=6,color=rgb(46,245,72))
	spawn(12) color=null
	sleep(8)
	createShockwavemisc(loc,2)
	createCrater(loc,5)
	ssj=3.5
	bp_milestone_reach("ssj3") //MARCO: LSSJ3 Primal (equivale ao SSJ3)
	emit_Sound('chargeaura.wav')
	to_chat(view(6), "<font color=#2ef548>*[src]'s green aura erupts as they ascend to Legendary Super Saiyan 3!*")
	transing=0
	attackable=1

mob/proc/legprimal_form_mult() //Imagem 24: ladder do Primal Legendary (Form Rising = maestria base->max * (1 + bonus de combate ate +20%))
	switch(ssj)
		if(1) . = 3 //Super Saiyan C-Type (Z)
		if(2) . = 6 + (9 - 6) * legp_m2 / 100 //Legendary Super Saiyan
		if(3) . = 9 + (12 - 9) * legp_m3 / 100 //Legendary Super Saiyan 2
		if(3.5) . = 18 //Legendary Super Saiyan 3
		if(4) . = 22 + (44 - 22) * ssj4mastery / 100 //Legendary Super Saiyan 4
		if(5) . = 34 + (52 - 34) * ssj4fpmastery / 100 //Legendary Super Saiyan 4FP
		if(6) . = 60 //Legendary Super Saiyan 4LB (God Form)
		else
			return 1
	. *= 1 + min(combatTime / 720, 1) * 0.2 //Form Rising: bonus de combate continuo +0%..+20%

mob/var/tmp/tooTiredMsg = 0 //rate-limit do aviso "too tired" (evita spam quando o Ki acaba)
mob/proc/tooTiredRevert() //reverte por falta de Ki e mostra o aviso no maximo 1x a cada ~5s (evita o spam de chat)
	Revert(0) //arg explicito 0 = reversao TOTAL (nao depender de null==0)
	if(!tooTiredMsg)
		tooTiredMsg = 1
		to_chat(src, "You are too tired to sustain your form.")
		spawn(50) tooTiredMsg = 0

mob/proc/cantSustainForm(drain) //TRUE se falta Ki pra sustentar uma forma; avisa (rate-limited). Evita transformar-e-reverter em loop. Bloqueia tambem com Ki <2% mesmo em forma masterizada (dreno 0).
	if(Ki <= MaxKi*max(drain, 0.02))
		if(!tooTiredMsg)
			tooTiredMsg = 1
			to_chat(src, "You don't have enough Ki to sustain that form right now.")
			spawn(50) tooTiredMsg = 0
		return TRUE
	return FALSE

mob/proc/stepped_mastery_mult(mastery, list/tiers) //maestria em DEGRAUS por %: o tier k (1=base) ativa em maestria >= k/n*100%; o tier MAXIMO so em 100%. Ex. SSJ1 [2,4,6]: 2x ate 66%, 4x ate 100%, 6x em 100%.
	var/n = tiers.len
	if(n < 1) return 1
	var/idx = 1
	for(var/k = 2 to n)
		if(mastery >= k * 100 / n) //k*100/n e divisao em ponto flutuante (ex. 2*100/3 = 66.67)
			idx = k
	return tiers[idx]

mob/proc/ssj1_mult() return stepped_mastery_mult(ssj1mastery, list(ssj1base, 6))         //SSJ1: base (2x) ate 99% -> 6x SO aos 100% (o degrau de 4x virou os GRADES)

//---- GRADES DO SSJ1 -------------------------------------------------------------
//Nao se compram com Marco: bastam SSJ_GRADE2_PCT / SSJ_GRADE3_PCT de maestria no SSJ1.
//Aos 100% o proprio SSJ1 vira 6x e os dois grades ficam obsoletos -- e a ideia.
//usa a ESCADA SAIYAJIN padrao? O Heran monta a escada dele por CIMA do ssjmult (HeranBuff.dm),
//entao mexer nos multiplicadores dele pelo motor do SSJ destroi o Max Power dominado.
mob/proc/ssj_ladder_user()
	if(Race == "Heran" || Parent_Race == "Heran") return 0
	if(Class == "Legendary" || Class == "Legendary Primal Saiyan" || FutureLineage) return 0
	if(canSSJ) return 0 //bypass (Baby/Reibi) e bio de laboratorio: escada nerfada fixa, sem grades e sem migracao
	if(Race == "Saiyan" || Parent_Race == "Saiyan") return 1
	if(genome && genome.race_percent("Saiyan") >= 25) return 1
	return 0

mob/proc/ssj_grade_unlocked() //0 = nenhum; 2 ou 3 = MAIOR grade liberado
	if(!ssj_ladder_user()) return 0
	if(canSSJ) return 0 //bypass (Baby/Reibi) e bio de laboratorio: ficam com o nerf fixo, sem grades
	if(ssj1mastery >= SSJ_GRADE3_PCT) return 3
	if(ssj1mastery >= SSJ_GRADE2_PCT) return 2
	return 0

//Derivado do ssj1base (2 normal / 1.35 diluido) e NAO cravado em 3/4: as racas nerfadas
//teriam um grade mais forte que o proprio SSJ1 delas e o nerf de sangue sumiria.
mob/proc/ssj_grade_mult(g)
	if(!g) return 0
	if(canSSJ) return ultrassjmult //bypass mantem o 1.45 fixo de sempre
	return ssj1base * ((g >= 3) ? SSJ_GRADE3_FACTOR : SSJ_GRADE2_FACTOR)

//multiplicador do grade em que o jogador ESTA (com fallback: 3 portas de entrada e saves
//legados podem deixar ssj=1.5 sem grade, e ai o BP colapsaria pra 0)
mob/proc/ssj_grade_active_mult()
	var/g = ssj_grade_active
	if(!g) g = ssj_grade_unlocked()
	if(!g) g = 2
	return ssj_grade_mult(g)

//SSJ2 efetivo: piso = MAIOR entre o SSJ1 e o grade DESBLOQUEADO, +2x
mob/proc/ssj2_effective_mult()
	var/m1 = canSSJ ? ssjmult : ssj1_mult()
	var/m2 = canSSJ ? ssj2mult : ssj2_mult()
	return max(m2, max(m1, ssj_grade_mult(ssj_grade_unlocked())) + 2)

//teto usado pelos GATES de BP (nao pelo poder): quem passava aos 66% pelo 4x do SSJ1
//continua passando pelo grade equivalente, senao o rework tranca portas que ja estavam abertas
mob/proc/ssj1_gate_mult()
	if(canSSJ) return ssjmult
	return max(ssj1_mult(), ssj_grade_mult(ssj_grade_unlocked()))

//LOGIN-FIX dos GRADES: aposenta a skill comprada (devolvendo os Marcos), herda quem ja tinha o
//USSJ, re-arma o verb (ele vinha do login() da skill morta) e normaliza saves sujos.
mob/proc/ssj_grade_login_check()
	if(!ssj_ladder_user()) return //Heran/Legendary/Future/nao-Saiyajin: o recompute la embaixo destruiria a escada deles
	if(!ssjGradesMigrated)
		for(var/datum/skill/tree/T in possessed_trees) //devolve os Marcos gastos na skill aposentada
			for(var/datum/skill/S in T.investedskills)
				if(S.type != /datum/skill/forms/ussj) continue
				T.invested -= S.skillcost
				T.investedskills -= S
				break
		for(var/datum/skill/S in learned_skills)
			if(S.type != /datum/skill/forms/ussj) continue
			S.logout() //para o "spawn while(savant)" da skill antes de descartar -- senao sobra loop orfao pinando o mob
			S.savant = src //o logout() ACABOU de zerar o savant e o forget() escreve em savant.skillpoints: sem isto e runtime que derruba o OnLogin inteiro. O del() de dentro do forget mata o loop na mesma passada, sem sleep no meio
			S.forget() //forget() PURO: o forget(1) roda o bloco forcado E cai no can_forget de novo (reembolso duplo)
			break
		if(hasussj && ssj1mastery < SSJ_GRADE2_PCT) ssj1mastery = SSJ_GRADE2_PCT //quem ja tinha o USSJ nao perde a forma
		ssjGradesMigrated = 1 //LATCHA so no FIM: se algo estourar no meio, o proximo login tenta de novo (latchar antes perdia a heranca do USSJ pra sempre)
	if(ssj == 1.5 && !ssj_grade_active) //o clearbuffs do logout zera o grade mas deixa ssj=1.5: volta no grade ESCOLHIDO
		ssj_grade_active = ssj_grade_sel ? ssj_grade_sel : max(ssj_grade_unlocked(), 2)
	if(godki && godki.usage && ssj_grade_active > 2) ssj_grade_active = 2 //o Royale so tem Grade 2 (relog/Ritual/Rift nao passam pelo verb God Ki)
	if(ssj_grade_sel > ssj_grade_unlocked()) ssj_grade_sel = ssj_grade_unlocked()
	ultrassjenabled = (ssj_grade_sel != 0)
	if(ssj_grade_unlocked()) assignverb(/mob/keyable/verb/Toggle_USSJ) //verbs nao sobrevivem ao logout
	else unassignverb(/mob/keyable/verb/Toggle_USSJ)
	recompute_saiyan_form_mults()

//tick da maestria do SSJ1 (chamado pelo Loop: taxa cheia no SSJ1, metade dentro de um grade)
mob/proc/ssj1_mastery_tick(rate)
	if(ssj1mastery >= 100) return
	var/antes = ssj1mastery
	ssj1mastery = min(100, ssj1mastery + rate)
	recompute_saiyan_form_mults()
	if(ssj1mastery >= SSJ_GRADE2_PCT && antes < SSJ_GRADE2_PCT)
		assignverb(/mob/keyable/verb/Toggle_USSJ)
		to_chat(src, "<font color=yellow><b>SSJ GRADE 2 liberado!</b> Escolha o grade em <i>Toggle SSJ Grades</i> (aba Other) e transforme a partir do Super Saiyajin.")
	if(ssj1mastery >= SSJ_GRADE3_PCT && antes < SSJ_GRADE3_PCT)
		to_chat(src, "<font color=yellow><b>SSJ GRADE 3 liberado!</b> Mais poder bruto que o Grade 2 -- e um dreno bem pior.")
	if(ssj1mastery >= 100 && !ismssj) //100%: Super Saiyajin completamente dominado
		ismssj = 1
		ssjmod = 2
		unrestssjmult += 5
		lssjmult += 10
		restssjmult += 5
		ssj2mod = 10
		to_chat(src, "You've mastered Super Saiyan completely! O SSJ1 agora vale 6x -- os grades ficaram para tras.")
		testunlocks()
mob/proc/ssj2_mult() return stepped_mastery_mult(ssj2mastery, list(ssj2base, 6, 8, 10))  //SSJ2: base ->(50%) 6x ->(75%) 8x ->(100%) 10x
mob/proc/ssj3_mult() return ssj3base //SSJ3: multiplicador FIXO (16 normal / 2 nerfado) -- a maestria NAO sobe o poder, so alivia um pouco o dreno (ver ssj3drain)

mob/proc/recompute_saiyan_form_mults() //sincroniza ssjmult/ssj2mult/ssj3mult e os drenos com a maestria % atual (usados no gating fora da forma e no switch de dreno do buff)
	if(!ssj_ladder_user()) return //Heran/Legendary/Primal/Future/canSSJ tem escada PROPRIA montada por cima do ssjmult -- reescrever aqui a destroi
	if(!ssjBaseCaptured) //captura 1x a base por-raca/nerf antes de qualquer sobrescrita (valores nerfados 1.35/1.75/2 ficam abaixo das bases normais 2/4/16)
		ssjBaseCaptured = 1
		if(ssjmult < 2) ssj1base = ssjmult
		if(ssj2mult < 4) ssj2base = ssj2mult
		if(ssj3mult < 16) ssj3base = ssj3mult
	ssjmult = ssj1_mult()
	ssj2mult = ssj2_mult()
	ssj3mult = ssj3_mult()
	ssjdrain = stepped_mastery_mult(ssj1mastery, list(0.025, 0.015, 0)) //dreno em degraus, zera no 100% (forma sustentavel quando dominada)
	var/gr = ssj_grade_active ? ssj_grade_active : ssj_grade_sel //dreno do grade: NUNCA zera (forma de forca bruta)
	if(gr) ultrassjdrain = (gr >= 3) ? SSJ_GRADE3_DRAIN : SSJ_GRADE2_DRAIN
	ssj2drain = stepped_mastery_mult(ssj2mastery, list(0.040, 0.030, 0.020, 0))
	ssj3drain = stepped_mastery_mult(ssj3mastery, list(0.075, 0.065, 0.055)) //SSJ3 NUNCA fica sustentavel: a maestria so alivia (66% -> 0.065, 100% -> 0.055) e mesmo dominado segue o PIOR dreno de todas as formas SSJ (USSJ 0.048, SSJ2 cru 0.040)

mob/proc/future_ssj_mult() //Future SSJ: cada 10% de maestria = +2x em degraus (0-9% = 2x ... 90%+ = 20x)
	return min(2 + round(futuressjmastery / 10) * 2, 20)

mob/proc/ssj_effective_mult() //multiplicador EFETIVO do SSJ com piso: nunca cai abaixo de (forma anterior + 2x), ate a forma atual superar naturalmente
	if(FutureLineage && ssj == 1)
		return future_ssj_mult()
	if(Class == "Legendary Primal Saiyan") //Primal Legendary usa o ladder proprio (Imagem 24)
		return legprimal_form_mult()
	var/m1 = canSSJ ? ssjmult : ssj1_mult() //canSSJ (bypass): usa o valor nerfado fixo (sem maestria); demais usam o degrau pela %
	var/m3 = canSSJ ? ssj3mult : ssj3_mult()
	switch(ssj)
		if(1) . = m1
		if(1.5) . = ssj_grade_active_mult() //GRADE 2/3: sem piso -- o SSJ1 dominado (6x) supera os dois de proposito
		if(2) . = ssj2_effective_mult() //piso = max(SSJ1, maior grade DESBLOQUEADO) + 2x
		if(3) . = max(m3, ssj2_effective_mult() + 2) //usa o SSJ2 EFETIVO: com o piso novo, o cru deixaria o SSJ3 nerfado mais fraco que o SSJ2
		if(4) . = max(ssj4_form_mult(), m3 + 2)
		if(5) . = max(ssj4_form_mult(), ssj4maxmult + 2)
		if(6) . = max(ssj4_form_mult(), ssj4fpmaxmult + 2)
		else . = 1

mob/proc/SSj4()
	if(SaiyanLineage != "Primal Saiyan") return //SSJ4 e exclusivo da linhagem Primal Saiyan
	//if(legendary)//no more ssj4 for legendary, they've been rebalanced
	//	return actually lssj < ssj4 still, if lssj gets anger rework and doesn't die with fucktons of energy then it'd work.
	if(!transing)
		if(ssj) Revert()
		if(godki && godki.usage && godki_ssj_cap <= 3)
			godki.usage = 0
			return
		transing=1
		if(!ssj4_music_played) //primeira transformacao em SSJ4: tema do GT desde o inicio (toca so uma vez, persiste no save)
			ssj4_music_played=1
			emit_TransformMusic('Dragon Ball GT   Super Saiyan 4 Theme (Gladius & Akihito Tokunaga)   By Gladius.mp3', 2935) //SSJ4 theme (~4.9min)
		attackable=0
		sleep(0)
		src.Revert()
		src.canRevert=0
		emit_Sound('powerup.wav')
		createShockwavemisc(loc,3)
		if(firsttime<=3)
			firsttime = 4
			BP+=capcheck(10000000)//your base gets stronger too. Nice.
			move=0
			dir=SOUTH
			BLASTICON='BlastsAscended.dmi'
			blastR=200
			blastG=200
			blastB=50
			for(var/turf/T in view(src))
				if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
				else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
				else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
			var/amount=32
			sleep(50)
			var/image/I=image(icon='Aurabigcombined.dmi')
			I.plane = 7
			overlayList+=I
			spawn(130) overlayList-=I
			sleep(100)
			while(amount)
				var/obj/A=new/obj
				A.loc=locate(x,y,z)
				A.icon='Electricgroundbeam2.dmi'
				if(amount==8) spawn(rand(1,100)) walk(A,NORTH,2)
				if(amount==7) spawn(rand(1,100)) walk(A,SOUTH,2)
				if(amount==6) spawn(rand(1,100)) walk(A,EAST,2)
				if(amount==5) spawn(rand(1,100)) walk(A,WEST,2)
				if(amount==4) spawn(rand(1,100)) walk(A,NORTHWEST,2)
				if(amount==3) spawn(rand(1,100)) walk(A,NORTHEAST,2)
				if(amount==2) spawn(rand(1,100)) walk(A,SOUTHWEST,2)
				if(amount==1) spawn(rand(1,100)) walk(A,SOUTHEAST,2)
				spawn(100) del(A)
				amount-=1
			move=1
		sleep(10)
		ssj=4
		bp_milestone_reach("ssj4") //MARCO: SSJ4
		hasssj4=1
		testunlocks() //reavalia desbloqueios (o Limit Breaker agora depende de masterizar 100% o Full Power)
		if(!isBuffed(/obj/buff/SuperSaiyan))
			startbuff(/obj/buff/SuperSaiyan,'SSJIcon.dmi')
		emit_Sound('chargeaura.wav')
		ssjBuff=ssj_effective_mult()
		transing=0
		attackable=1

mob/proc/SSj4FP() //Super Saiyan 4 Full Power (estagio acima do SSJ4; liberado ao masterizar 100% o SSJ4)
	if(SaiyanLineage != "Primal Saiyan") return
	if(transing) return
	if(ssj != 4) return //precisa estar em SSJ4
	if(!hasSSJ4FP) return //precisa ter masterizado 100% o SSJ4
	if(!Tail) return
	transing=1
	attackable=0
	to_chat(view(8), "<font color=#ffcc33 size=[TextSize]>[src]: HAAAAAAAAAAAAAAAHHHHHHHHHH!!!!")
	emit_Sound('powerup.wav')
	createShockwavemisc(loc,3)
	spawn Quake()
	animate(src,time=6,color=rgb(255,200,40))
	spawn(12) color=null
	sleep(8)
	createShockwavemisc(loc,2)
	createCrater(loc,5)
	ssj=5
	bp_milestone_reach("ssj4fp") //MARCO: SSJ4 Full Power
	ssjBuff=ssj_effective_mult()
	emit_Sound('chargeaura.wav')
	to_chat(view(6), "<font color=#ffcc33>*A surge of golden power explodes around [src] as they reach Full Power!*")
	transing=0
	attackable=1

mob/proc/SSj4FPLB() //Super Saiyan 4 Limit Breaker (God Form: estagio acima do Full Power, multiplicador 56)
	if(SaiyanLineage != "Primal Saiyan") return
	if(transing) return
	if(ssj != 5) return //precisa estar em SSJ4 Full Power
	if(!hasFPLB) return //precisa ter comprado a skill do Limit Breaker
	if(!Tail) return
	transing=1
	attackable=0
	to_chat(view(8), "<font color=red size=[TextSize]>[src]: HAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHH!!!!")
	emit_Sound('powerup.wav')
	createShockwavemisc(loc,3)
	spawn Quake()
	animate(src,time=6,color=rgb(255,40,40))
	spawn(12) color=null
	sleep(8)
	createShockwavemisc(loc,2)
	createCrater(loc,5)
	ssj=6
	ssjBuff=ssj_effective_mult()
	emit_Sound('chargeaura.wav')
	to_chat(view(6), "<font color=red>*A blinding crimson aura erupts around [src] as they shatter their limit!*")
	transing=0
	attackable=1

//REWORK do gate do SSJ4 (2026-07-10): rawssj4at e POR PERSONAGEM (sorteado na criacao e salvo) --
//saves antigos carregam ~180-260M; re-sorteia UMA vez na faixa nova (13.5B-19.5B). Chamado no Login.dm.
mob/proc/ssj4_gate_login_fix()
	if(rawssj4at && rawssj4at < 1000000000)
		rawssj4at = initial(rawssj4at) * rand(9,13)/10
