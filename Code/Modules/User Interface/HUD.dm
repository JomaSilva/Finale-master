mob/proc
	HudUpdate()
		set waitfor = 0
		set background = 1
		for(var/obj/screen/s in usr.contents)//shrink dem file sizes. Important for unfucking savefiles (part 1.)
			del(s)
		zone_sel = new /obj/screen/zone_sel()
		zone_sel.update_icon(src)
		damage_indct = new /obj/screen/damage_indct()
		damage_indct.update_icon(src)
		client.screen+=damage_indct
		client.screen+=zone_sel
		while(client)
			sleep(3)
			if(!damage_indct) //self-heal: if the paperdoll obj was ever deleted/nulled, recreate it instead of
				damage_indct = new /obj/screen/damage_indct() //crashing this loop on a null ref (which froze the
				client.screen += damage_indct                 //indicator -> wounds stopped matching the Body tab)
			damage_indct.update_icon(src) //was update_icon() with no arg, which hit the `if(source) else return` guard and never refreshed -> the limb paperdoll froze on its initial (often pre-body-init) state, showing healthy arms/legs as purple/Broken
			var/nonzeroki=usr.MaxKi
			if(nonzeroki<=0)
				nonzeroki=1
			var/echpee=usr.HP
			var/kee=usr.Ki
			var/beepee=usr.expressedBP
			if(!usr.expressedBP)
				beepee=1
			var/bptext = "[FullNum(round(beepee,1),100)]"
			if(!usr.scouteron) bptext = "???" //no scouter equipped = your own power level reads as ??? in the HUD
			var/percentKI = usr.Ki/max(nonzeroki,1)
			var/percentSTA = usr.staminapercent
			if(client&&client.HPWindowToggle==2)
				if(client)//both of these are fuckhuge monstrosities for a reason: every time winset() is used, it resends the ENTIRE SKIN FILE to the client. Minimize winset, save lives.
					winset(usr,null,\
						"HealthWindow.HPNum.text=[echpee];HealthWindow.KINum.text=[kee];HealthWindow.BPNum.text=[bptext];HealthWindow.HPPercent.text=[round(usr.HP)]%;HealthWindow.KIPercent.text=[round(percentKI*100)]%;HealthWindow.BPPercent.text=[round(usr.netBuff*100)]%")
			if(client&&client.HPWindowToggle==1)
				if(client) winset(usr, null,\
						"hppane.kinum.text=[round(kee)];hppane.bpnumpane.text=\"[bptext] BP\";hppane.hppercpane.text=[round(usr.HP)]%;hppane.kipercpane.text=[round(percentKI*100)]%;hppane.powerpcntpane.text=\"[round(usr.netBuff*100)]% BP\";hppane.stpercpane.text=[round(percentSTA*100)]%;hppane.currentnutid.text=[round((currentNutrition/maxNutrition)*100)]%;hppane.NameNFile.text=\"Name: [name]   File [save_path]\"")
	HudUpdateBars()
		set waitfor = 0
		set background = 1
		while(client)
			sleep(3)
			var/nonzeroki=usr.MaxKi
			if(nonzeroki<=0)
				nonzeroki=1
			var/echpee=usr.HP
			var/percentSTA
			var/percentKI = round(usr.Ki,1)/max(nonzeroki,1)
			var/percentGKI = 0
			if(godki && godki.energy)
				percentGKI = round(godki.energy,1)/max(godki.max_energy,1)
			percentSTA = usr.staminapercent
			if(client&&client.HPWindowToggle == 1 && (isnull(kibar) || isnull(staminabar)))
				staminabar = new /obj/screen/healthbar/maskbar/StBar()
				kibar = new /obj/screen/healthbar/maskbar/KiBar()
				client.screen+=staminabar
				client.screen+=kibar
			if(client&&client.HPWindowToggle==2)
				staminabar = null
				kibar = null
				gkibar = null
				if(client) winset(usr, null,\
					"HealthWindow.HPBar.value=[echpee];HealthWindow.KIBar.value=[percentKI*100];HealthWindow.STBar.value=[percentSTA*100]")
			if(client&&client.HPWindowToggle==1)
				spawn staminabar.setValue(percentSTA,3)
				spawn kibar.setValue(percentKI,3)
				if(godki && godki.energy && isnull(gkibar))
					gkibar = new /obj/screen/healthbar/maskbar/gkibar()
					client.screen+=gkibar
				if(godki && godki.energy) gkibar.setValue(100)
				else if(!isnull(gkibar))
					gkibar = null
		/*
Some people may be wondering: Why the fucking if(client)'s?
Answer: You get this:

runtime error: bad client
proc name: HudUpdateBars (/mob/proc/HudUpdateBars)
  source file: HUD.dm,28
  usr: (src)
  src: me [Author's Note: (my client name)] (/mob/player)
  src.loc: the sky (16,15,32) (/turf/build/sky)
  call stack:
me (/mob/player): HudUpdateBars()
me (/mob/player): Stats()
me (/mob/player): callLogin()

If you want to make this more efficient, figure out a solution for THAT shit. Fuck.
		*/

mob/
	var
		tmp/obj/screen/healthbar/maskbar/StBar/staminabar = null
		tmp/obj/screen/healthbar/maskbar/KiBar/kibar = null
		tmp/obj/screen/healthbar/maskbar/gkibar/gkibar = null

/obj/screen

	//standard_indicators
	appearance_flags = PIXEL_SCALE
	New()
		..()
		var/matrix/M = matrix()
		M.Scale(3,2)
		src.transform = M