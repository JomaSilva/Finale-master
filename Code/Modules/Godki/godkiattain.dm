var
	godki_at = 2.5e+008 //at 250 million base BP, you get Godki.
	godki_ssj_cap = 1.5 //teto ABSOLUTO de ssj/ayyform dentro do God Ki (1.5 = USSJ, o Royale da elite)

	godki_boost = 2.5 //races get a permanent increase to base BP...

	gt_boost = 3 //admins can designate people as "gt only", which gives them a 7.5x boost to power. (transforming * gt_boost, they get the godki_transform values)

	gt_mode = 0 //disables godki

mob/var
	godki_mod = 1 //affects rate of acquisition of godki, after acquiring godki, in which all things are useless, this means nothing except a initial boost to efficiency, and at values > 1 a small visual appearance difference. (rose)

	godki_gt_mode = 0

	godki_give_mult = 0 //mult/mod for the godki_boost given.

	trans_min_val = 1//teto de SSJ empilhavel no God Ki AGORA (godki.gk_trans_cap(): maestria <33 = 0, 33+ = 1, 50+ = 1.5 so Elite/Kaio; Prodigial sempre 0)

mob/proc
	gain_godki(var/energygain,force = FALSE)
		if(godki_gt_mode || gt_mode) return
		godki.energy+=energygain*godki_mod
		if(BP < godki_at && force == FALSE) return
		godki.energy = max(100,godki.max_energy)
		get_godki()

	reset_minor_godki()
		if(!godki.awakened && godki.energy)
			godki.usage = 0
			godki.energy = 0
	get_godki()
		if(!godki.awakened && godki.energy >= 100)
			godki.awakened = 1
			bp_milestone_reach("godki") //MARCO: DESPERTAR real do God Ki. O hook antigo ficava no new/datum/godki, que e so o CONTEINER criado pra todo mundo no login
			godki.b_efficiency = godki_mod
			godki_give_mult = godki_boost
			if(SaiyanLineage == "Primal Saiyan") godki_give_mult = 0 //Primal: God Ki so ativa o SSJ4 Limit Breaker, sem boost de BP base
			if(Race == "Kai" || Race=="Demon" || Parent_Race=="Demon" || Parent_Race == "Kai" || Father_Race == "Kai" || Father_Race == "Demon")
				godki.mastery = max(godki.mastery, GODKI_KAIDEMON_START_PCT) //sangue divino ja desperta com o nivel do Blue dominado
				godki.naturalization = TRUE
			enable_visibility(/datum/mastery/Godki)
			CheckGodki()
		else return
	lose_godki()
		godki.awakened = 0 //a maestria fica (conhecimento) -- so o despertar e revogado
		disable_visibility(/datum/mastery/Godki)
		godki_give_mult=0
		godki.energy = 0
		CheckGodki()

mob/Admin3/verb
	Godki_Settings()
		set category = "Admin"
		switch(input(usr,"What to change? God Ki is attainable at [godki_at] base BP. Temporary version via Ritual possible at any base. God Ki SSJ cap is [godki_ssj_cap]. Gt Mode: [gt_mode] (1 = On). Gt Mode being on will disable God Ki and mostly remove God Ki (Bonuses from mastery still remain.). A progressao divina e a MAESTRIA 0-100% (0=SSG, [GODKI_BLUE_PCT]=Blue, [GODKI_ROYALE_PCT]=Royale/Kaioken-Blue/Beast, [GODKI_UIUE_LEARN_PCT]=UI/Destruicao). (Angel/God of Destruction sao RANKS dados por admin, sem ligacao com God Ki.)") in list("Cancel",\
			"God Ki At","Heal God Ki Energy","Modify God Ki Stats (Mob)","GT Mode","God Ki SSJ cap"))

			if("God Ki At")
				godki_at = input(usr,"This will prevent anyone under this base BP level from gaining \"true\" godki until this point. Rituals do not give God Ki, but they give a God Ki base boost if they are at the requirement.","",godki_at) as num
			if("Heal God Ki Energy")
				var/mob/M = input(usr,"This will give a player the maximum amount of God Ki energy. This will not trigger anything.") as mob in player_list
				M.godki.energy = godki.max_energy
			if("Modify God Ki Stats (Mob)")
				var/mob/M = input(usr,"Select a mob.") as mob in player_list
				switch(input(usr,"Change what? Mastery - a progressao divina 0-100% (destrava Blue/[GODKI_BLUE_PCT], Royale-Kaioken-Beast/[GODKI_ROYALE_PCT], UI-Destruicao/[GODKI_UIUE_LEARN_PCT]). Efficiency - how fast God Ki energy goes down. You can also give energy, which can ascend them to God Ki if they meet the reqs. Also, you can straight up force godki. Finally, you can toggle GT Mode, which disables God Ki for them but gives them base multipliers for God Ki and a GT boost.") in list("Mastery","Efficiency","Gain Energy","Force God Ki","Naturalization","GT Mode","Cancel"))
					if("Give God Ki Energy")
						var/godkinum = input(usr,"This will give a player a certain amount of God Ki energy. If they have not awakened yet, and meet the BP requirement, they will awaken God Ki.") as num
						M.gain_godki(godkinum)
					if("Mastery")
						var/_old = M.godki.mastery
						M.godki.mastery = clamp(input(usr,"Maestria de God Ki (0-100)?","",M.godki.mastery) as num, 0, 100)
						if(M.godki.mastery > 0 && !M.godki.awakened) M.gain_godki(100,TRUE) //dar maestria a quem nem despertou = forca o despertar
						if(M.godki.mastery > _old) M.godki_mastery_milestone(_old, M.godki.mastery)
					if("Efficiency")
						M.godki.b_efficiency = input(usr,"Change the efficiency?","",M.godki.b_efficiency) as num
					if("Force God Ki")
						M.gain_godki(100,TRUE)
					if("Naturalization")
						if(M.godki.naturalization)
							M.godki.naturalization = 0
							to_chat(usr, "God naturalization off.")
						else
							M.godki.naturalization = 1
							to_chat(usr, "God naturalization on.")
					if("GT Mode")
						if(M.godki_gt_mode)
							M.godki_gt_mode = 0
							to_chat(usr, "God Ki GT mode disabled")
						else
							M.godki_gt_mode = 1
							M.lose_godki()
							to_chat(usr, "God Ki GT mode enabled")
			if("GT Mode")
				if(gt_mode)
					to_chat(world, "<font color=yellow size=4>GT Mode turned off... God Ki attainable.</font>")
					gt_mode=0
				else
					gt_mode=1
					to_chat(world, "<font color=yellow size=4>GT Mode turned on... No way to gain God Ki!</font>")
			if("God Ki SSJ cap")
				godki_ssj_cap = input(usr,"The maximum level of SSJ players can get to while in God Ki. SSJ4 Blue is not supported.", godki_ssj_cap) as num
				to_chat(world, "<font color=yellow size=4>Players can use only up to SSJ [godki_ssj_cap] while in God Ki.</font>")


