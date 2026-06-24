mob/var
	tmp/absorbing=0
	absorbable=1
	absorbadd=0 //An amount added to your BP, equal to 50% of the absorbed person's BP...
	absorbmod=1 //percentage of bp obtained, 1=100%
	HasSoul = 1
	absorbrecently = 0 //will eventually factor in somehow below. NPCs will give lower gains than people...
	//eating NPCs then people won't incur penalties but eating loads of NPCs and people respectively will incur some penalties.

mob/proc/absorbproc() //to make sure you cant be absorbed a for some time.
	absorbable=0
	sleep(3000)
	absorbable=1

obj/Absorb_Android
	var/tmp/action
	verb/Energy_Drain(mob/M in oview(1))
		set category="Skills"
		usr.GainAbsorb(1)
		if(!usr.absorbing&&M.absorbable&&!usr.KO&&usr.Planet!="Sealed")
			usr.absorbing=1
			if(M.KO&&!M.dead)
				if(M.Race=="Android") if(!M.dead)
					usr<<"You absorb [M], and [M]'s materials siphon into you!"
					M<<"<font color=red>STRUCTUAL INTEGRITY FAILURE"
					oview(usr)<<"[usr]([usr.displaykey]) absorbs [M]!"
					usr.emit_Sound('Electricity-sound.ogg')
					usr.AbsorbDatum.absorb(M,2,6)
					usr.Ki+=M.Ki
					if(usr.Ki>usr.MaxKi) usr.Ki=usr.MaxKi
				else if(!M.dead)
					usr<<"You begin absorbing [M]'s energy"
					oview(usr)<<"[usr]([usr.displaykey]) begins draining [M] of their energy!"
					usr.emit_Sound('absorb.wav')
					usr.overlayList+='AbsorbSparks.dmi'
					usr.overlaychanged=1
					M.overlayList+='AbsorbSparks.dmi'
					M.overlaychanged=1
					var/prehp = usr.HP
					action = 1
					while(action)
						if(prehp > usr.HP) break
						if(usr.KO) break
						var/breakme = 1
						for(var/mob/A in oview(1)) if(A==M)
							breakme = 0
							usr.Ki+=M.Ki*0.1
							M.Ki-=M.Ki*0.1
							usr.overcharge = 1
							if(M.Player)
								usr.absorbadd+=(M.BP/50)+M.absorbadd*(M.PowerPcnt/100)*(M.Anger/100)
							else
								usr.absorbadd+=(usr.relBPmax*BPTick*1/250)
							if(M.Ki<M.MaxKi*0.1) spawn M.Death()
						if(breakme) break
						sleep(7)
					usr.overlayList-='AbsorbSparks.dmi'
					usr.overlaychanged=1
					M.overlayList-='AbsorbSparks.dmi'
					M.overlaychanged=1
					usr.absorbing = 0
					action = 0
					if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(5*usr.KiMod)
				else usr << "They're dead. Can't absorb them."
			else usr<<"They must be knocked out, and must be alive, and must not have been already absorbed in the last 5 minutes."
		else if(usr.absorbing&&action)
			action = 0
			usr.absorbing = 0
		else usr << "Unable to absorb."


	verb/A_Expel()
		set name = "Expel"
		set category = "Skills"
		usr.Absorb_Expel()
obj/Buu_Absorb
	verb/Absorb(mob/M in oview(1))
		set category="Skills"
		usr.GainAbsorb(3)
		usr.AbsorbDeterminesBP = 1
		if(!usr.absorbing&&M.absorbable&&!usr.KO&&usr.Planet!="Sealed")
			usr.absorbing=1
			if(M.KO&&!M.dead)
				M.buudead="force"
				var/ismajor = usr.AbsorbDatum:absorb(M,2,6)
				M<<"[usr]([usr.displaykey]) absorbs you!"
				oview(usr)<<"[usr]([usr.displaykey]) absorbed [M]!"
				usr.currentNutrition += 50
				if(ismajor)
					M.buudead=0
					usr.SpreadHeal(100,1,0)
					usr.Ki = usr.MaxKi
					usr.Ki+=M.Ki
					usr.overcharge = 1
				usr.emit_Sound('absorb.wav')
			else usr<<"They must be knocked out, and must be alive, and must not have been absorbed already in the last 5 minutes."
		sleep(20)
		usr.absorbing=0
	verb/Bu_Expel()
		set name = "Expel"
		set category = "Skills"
		usr.Absorb_Expel()
obj/Bio_Absorb
	verb/Absorb(mob/M in oview(1))
		set category="Skills"
		usr.GainAbsorb(2)
		usr.AbsorbDeterminesBP = 1
		if(!usr.absorbing&&M.absorbable&&!usr.KO&&usr.Planet!="Sealed")
			usr.absorbing=1
			if(M.KO&&!M.dead)
				M.buudead="force"
				var/canachieve
				if((usr.Race=="Bio-Android"|| (usr.Parent_Race=="Bio-Android"))&&!usr.cell2)
					if(M.Player&&M.BP>=15000000||usr.expressedBP>=usr.cell2at)
						usr<<"You can reach form 2 in this absorption. (If Ascension is turned on. It has to be marked as a Major absorb.)"
						canachieve = 1
				if((usr.Race=="Bio-Android"|| (usr.Parent_Race=="Bio-Android"))&&!usr.cell3)
					if(M.Player&&M.BP>=20000000||usr.expressedBP>=usr.cell3at)
						usr<<"You can reach form 3 in this absorption. (If Ascension is turned on. It has to be marked as a Major absorb.)"
						canachieve = 1
				var/ismajor = usr.AbsorbDatum.absorb(M)
				usr.currentNutrition += 50
				usr<<"You absorb [M]!"
				M<<"[usr]([usr.displaykey]) absorbs you!"
				oview(usr)<<"[usr]([usr.displaykey]) absorbed [M]!"
				if(ismajor)
					M.buudead=0
					usr.SpreadHeal(100,1,0)
					usr.Ki = usr.MaxKi
					usr.Ki+=M.Ki
					usr.overcharge = 1
					usr.emit_Sound('deathball_charge.wav')
					if(TurnOffAscension&&!usr.AscensionAllowed) return
					if(!usr.cell2)
						if(M.Player&&M.BP>=15000000||usr.expressedBP>=usr.cell2at||canachieve)
							usr.transBuff = usr.cell2mult
							usr.genome.add_to_stat("Battle Power",usr.cell2mult)
							usr.cell2=1
							usr.oicon=usr.icon
							usr.icon=usr.form2icon
							usr.imperfecttranscinematic()
					else if(!usr.cell3)
						if(M.Player&&M.BP>=20000000||usr.expressedBP>=usr.cell3at||canachieve)
							usr.transBuff = usr.cell3mult
							usr.genome.add_to_stat("Battle Power",usr.cell3mult)
							usr.was3=1
							usr.cell3=1
							usr.icon=usr.form3icon
							usr.perfecttranscinematic()
				else
					usr.emit_Sound('absorb.wav')
			else usr<<"They must be knocked out, and must be alive, and must not have been absorbed already in the last 5 minutes."
		sleep(20)
		usr.absorbing=0
	verb/B_Expel()
		set name = "Expel"
		set category = "Skills"
		usr.Absorb_Expel()


mob/proc/Absorb_Expel()
	switch(input(usr,"Expel how many? People absorbed must be online in order for them to be returned properly without admin intervention!") in list("All","One","Cancel"))
		if("All")
			if(AbsorbDatum)
				AbsorbDatum.expellall()
				AbsorbBP = 0
				AbsorbDatum = null
		if("One")
			if(AbsorbDatum)
				AbsorbDatum.expell(src)

mob/var
	AbsorbDeterminesBP = 0 //Always on for Majin/Bios. Your normal BP is averaged out with your absorbed BP. This should result in a nerf to absorption.
	//You absorb to compensate, not as a goddamn training method. (Bios -can- be different though.)
	AbsorbBP = 0 //Added on to regular BP. If above is ticked, your BP is decided by 'BP + AbsorbBP / 2' I.E. the average. This only matters for -major- absorptions.
	datum/Absorbs/AbsorbDatum = null
	tmp
		absorber_timeout = 0
	absorber_effectiveness = 1

mob/proc/GainAbsorb(var/canTakeBodies)
	if(isnull(AbsorbDatum))
		AbsorbDatum = new /datum/Absorbs
		AbsorbDatum.container = src
	else
		if(canTakeBodies == 1)
			AbsorbDatum.WillTakeBody = 0
		if(canTakeBodies == 2)
			AbsorbDatum.WillTakeBody = 1
		if(canTakeBodies == 3)
			AbsorbDatum.WillTakeBody = 2

mob/Admin2/verb/Reset_Absorption(var/mob/M)
	set category = "Admin"
	if(M.AbsorbDatum)
		M.AbsorbDatum.expellall()
		AbsorbBP = 0
		AbsorbDatum = null

var/list/expelled_people = list() //list of sigs of people who need to be expelled, checked on login.

datum/Absorbs
	var/mob/container
	var/list/MajorAbsorbSigs = list()
	var/list/absorboverlays = list()
	var/MajorAbsorbBP
	var/WillTakeBody =1
	var/LastMajorAbsorbSig
	var/LastMajorAbsorbBP

	proc
		expell(mob/cnt)
			if(cnt) container = cnt
			if(isnull(container)) return FALSE
			if(MajorAbsorbSigs.len==0) return FALSE
			if(!LastMajorAbsorbSig)
				LastMajorAbsorbSig = MajorAbsorbSigs[MajorAbsorbSigs.len]
				if(!LastMajorAbsorbSig) return FALSE
			var/gotout
			for(var/mob/M in player_list)
				if(M.signature == LastMajorAbsorbSig)
					gotout = 1
					if(M.dead || M.Planet=="Sealed")
						Revive(M,1)
						//M.loc = locate(container.loc)
						M.loc = locate(container.x,container.y,container.z)
						M << "You've been regurgitated."
						spawn M.KO()
						oview(M) << "[M] was thrown up!"
						step(M,container.dir)
						MajorAbsorbSigs -= M.signature
					else if(M)
						switch(alert(M,"Would you like to be regurgitated by [M], despite being alive? This will teleport you to them, and KO you!","Regurgitation","Yes","No"))
							if("Yes")
								Revive(M,1)
								//M.loc = locate(container.loc)
								M.loc = locate(container.x,container.y,container.z)
								M << "You've been regurgitated."
								spawn M.KO()
								oview(M) << "[M] was thrown up!"
								step(M,container.dir)
								MajorAbsorbSigs -= M.signature
					break
			if(!gotout)
				expelled_people += LastMajorAbsorbSig
			container.removeOverlays(absorboverlays)
			container.AbsorbBP = max(container.AbsorbBP-LastMajorAbsorbBP,0)
			if((container.cell2||container.cell3)&&container.Class!="Majin-Type"&&!container.form3cantrevert)
				if(container.cell2&&!container.cell3)
					container.transBuff = 1
					container.genome.sub_to_stat("Battle Power",container.cell2mult)
					container.cell2=0
					container.icon=container.oicon
				if(container.cell2&&container.cell3)
					container.transBuff = container.cell2mult
					container.genome.sub_to_stat("Battle Power",container.cell3mult)
					container.cell3=0
					container.icon=container.oicon
			MajorAbsorbBP -= LastMajorAbsorbBP
			if(MajorAbsorbSigs.len==0) return TRUE
			if(!MajorAbsorbBP) return TRUE
			LastMajorAbsorbSig = MajorAbsorbSigs[MajorAbsorbSigs.len]
			LastMajorAbsorbBP = MajorAbsorbBP / (MajorAbsorbSigs.len)
			return TRUE
		expellall()
			if(isnull(container)) return FALSE
			if(!LastMajorAbsorbSig) return FALSE
			if(MajorAbsorbSigs.len==0) return FALSE
			for(var/mob/M in player_list)
				if(M.signature in MajorAbsorbSigs)
					if(M.dead || M.Planet=="Sealed")
						M.loc = locate(container.x,container.y,container.z)
						Revive(M,1)
						spawn M.KO()
						M << "You've been regurgitated."
						oview(M) << "[M] was thrown up!"
						M.loc = locate(container.x,container.y,container.z)
						step(M,container.dir)
						MajorAbsorbSigs -= M.signature
			expelled_people += MajorAbsorbSigs
			container.removeOverlays(absorboverlays)
			container.AbsorbBP = max(container.AbsorbBP-MajorAbsorbBP,0)
			if((container.cell2||container.cell3)&&container.Class!="Majin-Type"&&!container.form3cantrevert)
				if(container.cell2&&!container.cell3)
					container.genome.sub_to_stat("Battle Power",container.cell2mult)
					container.cell2=0
					container.icon=container.oicon
				if(container.cell2&&container.cell3)
					container.genome.sub_to_stat("Battle Power",container.cell3mult)
					container.genome.sub_to_stat("Battle Power",container.cell2mult)
					container.cell2=0
					container.cell3=0
					container.icon=container.oicon
			MajorAbsorbSigs = list()
			MajorAbsorbBP = 0
			LastMajorAbsorbSig = null
			LastMajorAbsorbBP = null
			return TRUE
		absorb(var/mob/M,upscaler,downscaler)
			var/ismajor = FALSE
			var/choice
			var/activing = 0
			spawn(300)
				if(activing) container.absorber_timeout = 1
			if(WillTakeBody)
				sleep choice = alert(container,"Make this mob a major absorb? If you do, your BP will average out with the mob, and at a later point you may expell the mob. This acts like a seal. Biodroids will ascend to the next form per major absorb. This doesn't work on NPCs.","","Yes","No")
			activing = 1
			if(choice=="Yes")
				ismajor = TRUE
			if(container.absorber_timeout)
				ismajor = FALSE
				container.absorber_timeout=0
				return
			if(ismajor && M.client)
				LastMajorAbsorbBP = M.BP
				LastMajorAbsorbSig = M.signature
				if(WillTakeBody==2)
					container.removeOverlays(absorboverlays)
					absorboverlays = container.HasOverlays(M,/obj/overlay/clothes)
					container.duplicateOverlays(absorboverlays)
				MajorAbsorbSigs+=M.signature
				MajorAbsorbBP += LastMajorAbsorbBP
				container.AbsorbBP += LastMajorAbsorbBP
				M.GotoPlanet("Sealed",0)
				spawn
					M << "You have been marked as a Major absorb. This means you're technically alive, but 'sealed.' Reincarnate to make this permanent, or be online when the other player regurgitates you. You can also choose to die."
					if(alert(M,"Would you like to die?","","Fuck Yeah","Nah")=="Fuck Yeah")
						M.buudead = "force"
						spawn M.Death()
				spawn M.KO()
				spawn M.absorbproc()
			else
				container.absorber_effectiveness *= 0.9
				spawn(6000) container.absorber_effectiveness /= 0.9
				if(WillTakeBody==2) M.buudead=6
				spawn(10) M.Death()
				spawn M.absorbproc()
				if(!downscaler)
					downscaler = 5
				if(!upscaler)
					upscaler = 1.8
				if(!M.isNPC)
					if(container.BP<M.BP)
						container.absorbadd+=container.capcheck((container.absorber_effectiveness * (M.BP/M.BPMod)*container.BPMod)/(downscaler/upscaler))
					if(M.BP<=container.BP)
						container.absorbadd+=container.capcheck(container.absorber_effectiveness * (M.BP/M.BPMod)/downscaler)
					if(container.absorbadd<((container.absorber_effectiveness * (M.BP/1+M.absorbadd))*(M.Anger/100)))
						container.absorbadd+=((container.absorber_effectiveness * (M.BP/1+M.absorbadd))*(M.Anger/100))
				else
					container.absorbadd+=container.capcheck(container.relBPmax*(1/300)*container.Egains*container.absorber_effectiveness*upscaler)/downscaler
			return ismajor