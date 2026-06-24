var
	godki_at = 2.5e+008 //at 250 million base BP, you get Godki.
	godki_ssj_cap = 1.5 //you cannot go past ssj/ayyform 1.5x while using godki energy.
	max_godki_tier = 4 //maximum tier players can reach

	kaiodemon_init_tier = 2 // initial tier for kaio/demons is two.

	godki_boost = 2.5 //races get a permanent increase to base BP...

	gt_boost = 3 //admins can designate people as "gt only", which gives them a 7.5x boost to power. (transforming * gt_boost, they get the godki_transform values)

	gt_mode = 0 //disables godki

mob/var
	godki_mod = 1 //affects rate of acquisition of godki, after acquiring godki, in which all things are useless, this means nothing except a initial boost to efficiency, and at values > 1 a small visual appearance difference. (rose)

	godki_gt_mode = 0

	godki_give_mult = 0 //mult/mod for the godki_boost given.

	trans_min_val = 1//equal to min(godki_ssj_cap,godki.tier)

mob/proc
	gain_godki(var/energygain,force = FALSE)
		if(godki_gt_mode || gt_mode) return
		godki.energy+=energygain*godki_mod
		if(BP < godki_at && force == FALSE) return
		godki.energy = max(100,godki.max_energy)
		get_godki()

	reset_minor_godki()
		if(godki.tier == 0 && godki.energy)
			godki.usage = 0
			godki.energy = 0
	get_godki()
		if(godki.tier == 0 && godki.energy == 100)
			godki.tier = 1
			godki.b_efficiency = godki_mod
			godki_give_mult = godki_boost
			if(Race == "Kai" || Race=="Demon" || Parent_Race=="Demon" || Parent_Race == "Kai" || Father_Race == "Kai" || Father_Race == "Demon")
				godki.tier = kaiodemon_init_tier
				godki.naturalization = TRUE
			enable_visibility(/datum/mastery/Godki)
			CheckGodki()
		else return
	lose_godki()
		godki.tier = 0
		disable_visibility(/datum/mastery/Godki)
		godki_give_mult=0
		godki.energy = 0
		CheckGodki()

mob/Admin3/verb
	Godki_Settings()
		set category = "Admin"
		switch(input(usr,"What to change? God Ki is attainable at [godki_at] base BP. Temporary version via Ritual possible at any base. God Ki SSJ cap is [godki_ssj_cap]. Max tier is [max_godki_tier]. Gt Mode: [gt_mode] (1 = On). Gt Mode being on will disable God Ki and mostly remove God Ki (Bonuses from mastery still remain.). God Ki utter cap is [godki_cap]. Anyone at that tier or [godki_cap-1] tier will be a Angel or GoD.") in list("Cancel",\
			"God Ki At","Heal God Ki Energy","Modify God Ki Stats (Mob)","GT Mode","Max Attainable God Ki Tier","God Ki Tier Cap","God Ki SSJ cap"))

			if("God Ki At")
				godki_at = input(usr,"This will prevent anyone under this base BP level from gaining \"true\" godki until this point. Rituals do not give God Ki, but they give a God Ki base boost if they are at the requirement.","",godki_at) as num
			if("Heal God Ki Energy")
				var/mob/M = input(usr,"This will give a player the maximum amount of God Ki energy. This will not trigger anything.") as mob in player_list
				M.godki.energy = godki.max_energy
			if("Modify God Ki Stats (Mob)")
				var/mob/M = input(usr,"Select a mob.") as mob in player_list
				switch(input(usr,"Change what? Tier - determines max energy and multiplier. Efficiency - how fast God Ki energy goes down. You can also give energy, which can ascend them to God Ki if they meet the reqs. Also, you can straight up force godki. Finally, you can toggle GT Mode, which disables God Ki for them but gives them base multipliers for God Ki and a GT boost.") in list("Tier","Efficiency","Gain Energy","Force God Ki","Naturalization","GT Mode","Cancel"))
					if("Give God Ki Energy")
						var/godkinum = input(usr,"This will give a player a certain amount of God Ki energy. If they're at Tier 0, and meet the BP requirement, they will gain the first tier of God Ki.") as num
						M.gain_godki(godkinum)
					if("Tier")
						M.godki.tier = input(usr,"Change the tier?","",M.godki.tier) as num
						if(M.godki.tier >= 1) M.get_godki()
						else M.lose_godki()
					if("Efficiency")
						M.godki.b_efficiency = input(usr,"Change the efficiency?","",M.godki.b_efficiency) as num
					if("Force God Ki")
						M.gain_godki(100,TRUE)
					if("Naturalization")
						if(M.godki.naturalization)
							M.godki.naturalization = 0
							usr << "God naturalization off."
						else
							M.godki.naturalization = 1
							usr << "God naturalization on."
					if("GT Mode")
						if(M.godki_gt_mode)
							M.godki_gt_mode = 0
							usr << "God Ki GT mode disabled"
						else
							M.godki_gt_mode = 1
							M.lose_godki()
							usr << "God Ki GT mode enabled"
			if("GT Mode")
				if(gt_mode)
					world << "<font color=yellow size=4>GT Mode turned off... God Ki attainable.</font>"
					gt_mode=0
				else
					gt_mode=1
					world << "<font color=yellow size=4>GT Mode turned on... No way to gain God Ki!</font>"
			if("Max Attainable God Ki Tier")
				max_godki_tier = input(usr,"The maximum amount of God Ki Tier players can level up to.","",max_godki_tier) as num
				world << "<font color=yellow size=4>Players can level God Ki up to a max of [max_godki_tier]! The absolute cap is [godki_cap]</font>"
			if("God Ki Tier Cap")
				godki_cap = input(usr,"The absolute cap of God Ki tiers. This determines when players can get into Angel and GoD.","",godki_cap) as num
				world << "<font color=yellow size=4>Players can level God Ki up to a max of [max_godki_tier]! The absolute cap is [godki_cap]</font>"
			if("God Ki SSJ cap")
				godki_ssj_cap = input(usr,"The maximum level of SSJ players can get to while in God Ki. SSJ4 Blue is not supported.", godki_ssj_cap) as num
				world << "<font color=yellow size=4>Players can use only up to SSJ [godki_ssj_cap] while in God Ki.</font>"


