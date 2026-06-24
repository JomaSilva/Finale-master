mob/var
	canSSJ = 0 //This is a 'bypass' var that allows any race to use SSJ. If this is ticked to 1, SSJ is weaker.
	canRSSJ = 1 //This is for Legendaries and their specialization- ticking it to 0 means they 'skip' RSSJ.
mob/proc/Transformations_Activate()
	usr.Frost_Demon_Forms()
	if(TurnOffAscension&&!AscensionAllowed) return
	if(!usr.MysticPcnt==1||!usr.MajinPcnt==1) return
	if(usr.Race=="Heran"||usr.Parent_Race=="Heran")
		if(!usr.ssj&&!usr.hasssj&&usr.BP>=usr.ssjat&&usr.Emotion=="Very Angry")
			if(usr.godki && usr.godki.usage)
				if(trans_min_val < 1) return
			hasssj = 1
			usr.Max_Power()
		if(!usr.ssj&&usr.hasssj&&usr.expressedBP>=usr.ssjat)
			if(usr.godki && usr.godki.usage)
				if(trans_min_val < 1) return
			usr.Max_Power()
		if(usr.ssj==1&&usr.expressedBP>=usr.ssj2at)
			if(usr.hasssj2&&usr.expressedBP>=usr.ssj2at)
				if(usr.godki && usr.godki.usage)
					if(trans_min_val < 2) return
				usr.True_Max_Power()
			else if(usr.Emotion=="Very Angry"&&usr.BP>=usr.ssj2at)
				if(usr.godki && usr.godki.usage)
					if(trans_min_val < 2) return
				hasssj2 = 1
				usr.True_Max_Power()
	if(usr.Race=="Saiyan"|usr.genome.race_percent("Saiyan") >= 25||usr.Parent_Race=="Saiyan"||usr.canSSJ && !Apeshit)
		if(usr.canSSJ) usr.nerfSSJ()
		if(!(usr.Class=="Legendary"))
			if(usr.MysticPcnt==1&&usr.MajinPcnt==1)
				//SUPER Saiyan 3
				if(usr.ssj==2&&usr.expressedBP>=usr.ssj3at)
					if(usr.ssj3able)
						if(usr.godki && usr.godki.usage)
							if(trans_min_val < 3) return
						usr.SSj3()
				//SUPER Saiyan 2
				if(usr.ssj==1&&usr.expressedBP>=usr.ssj2at&&!usr.ultrassjenabled)
					if(usr.hasssj2&&usr.expressedBP>=usr.ssj2at)
						if(usr.godki && usr.godki.usage)
							if(trans_min_val < 2) return
						usr.SSj2()
				//ULTRA SUPER Saiyan
				if(usr.ssj==1&&usr.expressedBP>=usr.ultrassjat&&usr.BP>=usr.ssj2at/50)
					if(usr.hasussj&&usr.ultrassjenabled)
						if(usr.godki && usr.godki.usage)
							if(trans_min_val < 1.5) return
						usr.Ultra_SSj()
				//SUPER Saiyan 1
				if(usr.ssj==0&&usr.expressedBP>=usr.ssjat)
					if(usr.hasssj&&usr.expressedBP>=usr.ssjat)
						if(usr.godki && usr.godki.usage)
							if(trans_min_val < 1) return
						usr.ExpandRevert()
						usr.SSj()
		if((usr.Class=="Legendary"))//We don't need to stick usr.Parent_Race=="Saiyan" here, because its already nested lel.
			if(usr.MysticPcnt==1&&usr.MajinPcnt==1)
				// LSSJ
				if(usr.lssj==2&&usr.BP>=usr.lssjat) //BP, not expressed. Since LSSJ's expressed BP is fucking insane, it makes more sense to restrict based on raw BP (can't be really faked.)
					if(usr.hasssj)
						if(usr.godki && usr.godki.usage)
							if(trans_min_val < 2) return
						usr.LSSj()
				// Unrestrained SSJ
				if((usr.lssj==1 || !canRSSJ)&&usr.BP>=usr.unrestssjat)
					if(usr.hasssj)
						if(usr.godki && usr.godki.usage)
							if(trans_min_val < 1) return
						usr.Unrestrained_SSj()
				// restrained SSJ
				if(usr.lssj==0 && canRSSJ)
					if(usr.expressedBP>=usr.restssjat)
						if(usr.hasssj)
							usr.Restrained_SSj()
	usr.Cell4()
	usr.snamek()
	usr.Alien_Trans()
//tmp verb - make it keyable?
mob/Transform
	verb
		Transform()
			set category = "Skills"
			usr.Transformations_Activate()

mob/proc/nerfSSJ()
	ssjmult = 1.35
	ultrassjmult = 1.45
	ssj2mult = 1.75
	ssj3mult = 2
	ssj4mult = 1.75
	Omult=1.5
	restssjmult=1.15
	unrestssjmult=1.4
	lssjmult=2