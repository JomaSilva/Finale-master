mob/var
	BPBoost = 1 //BP boost that is ONLY to be used with ascension related things. Dynamic.

	BPBoostCap = 20 //teto da Ascensao (era 200): as racas SEM formas chegam a no maximo 20x. OBS: a var e POR-MOB e persiste no save -- por isso a formula do Auto_Gain/NPCAscension tambem crava min(...,20) (pega personagens antigos salvos com 200).
	//Var that should be modified. On character creation this might be set to a formula that takes your BPmod and mults it by a hundred or something.

	//Now, this variable below controls the RATE it inflates an individual's BP. Humans, for instance, will have a var of 0.5. I.E. their BPBoost will grow at half
	//the rate as someone else, like say a Demon or Namek. This does not change the amount of -raw- bp it takes to get to 100% BP Boost. (Always should be around 75m gib or take.)
	AscensionRate = 1

	AscensionAllowed = 0
	//Admins can turn this on a mob to ignore the global "turn off ascension" flag. If so, they gain transformations, power, etc like normal.

	NoAscension
	//For Saiyans only.

//legacy vars
	gain1=0
	form=0
	gain2=0
	gain3=0
	formgain=0
	hasussj=0
	ascBPmod = 2
	tmp/BPincreasing = 0
//legacy vars end



var/
	TurnOffAscension = 0
	//turns off ascension entirely. Effective for transforming races as well.
	AscensionStarted
	//Variable that dictates if ascension will start or not. Automatically toggled on when Sands hit, can be manually toggled on.
	GlobalBPBoost = 1
	//This is a global BP boost that affects ALL races that have a BP boost. Lets Admins change non-SSJ races BP for fairness easily.
	TransformedBPBoost = 1
	//Localized BP boost that affects all races that DON'T have a BP boost.
	//
	//NPCs have their own ascension proc, so these variables corrospond to different portions of ascension calcs. Could be made into a customization proc.
	ascensionmod1 = 17
	ascensionmodopf = 3

	ascensionmod2 = 2.150

	ascensionmod3 = 23
	ascensionmodtpf = 4

	ascensionascmodlg = 2
	//
mob/Admin3
	verb
		Change_Ascension()
			set category = "Admin"
			var/choice = input(usr,"Change what? Turning off ascension disables SSJ transformations and transformations like it!") in list("Toggle ascension.","Global non-transforming BP boosts.","Global transforming BP boosts.","Canel")
			switch(choice)
				if("Toggle ascension.")
					if(TurnOffAscension)
						to_chat(world, "Ascension has been enabled.")
						TurnOffAscension = 0
						WriteToLog("admin","[usr]([key]) turned on ascension.")
					else
						to_chat(world, "Ascension has been disabled. Note: Leaving this on for too long will cause jumps in power if it gets turned back on.")
						TurnOffAscension = 1
						WriteToLog("admin","[usr]([key]) turned off ascension.")
				if("Global non-transforming BP boosts.")
					GlobalBPBoost = input(usr,"Select the global BP boost for non-transforming races like Humans and Grays. The default is 1.","",GlobalBPBoost) as num
					WriteToLog("admin","[usr]([key]) set the global BP boost for non-transforming races to [GlobalBPBoost].")
				if("Global transforming BP boosts.")
					TransformedBPBoost = input(usr,"Select the global BP boost for transforming races like Saiyans. The default is 1.","",TransformedBPBoost) as num
					WriteToLog("admin","[usr]([key]) set the global BP boost for transforming races to [TransformedBPBoost].")

mob/proc/Auto_Gain()
	set waitfor = 0
	if(bio_lab_born && bio_stage == 1) //LARVA de bio-androide: a carapaca SUPRIME a Ascensao (senao o BPBoost de ate ~317x montava sobre a restricao e a larva nascia um monstro em vez de expressar so 10% do base)
		BPBoost = 1
		return
	if(Class == "Corrupted Majin" && !NoAscension) //classe COM transformacoes (regra do Saiyajin/Bio: forma e Ascensao nao se somam) -- RETROATIVO: normaliza chars antigos com boost salvo no primeiro tick
		NoAscension = 1
		BPBoost = 1
	if(BPBoost > 20) BPBoost = 20 //teto 20x RETROATIVO: o Auto_Gain nunca REDUZIA o BPBoost (as branches so sobem) -- sem isto, players antigos com 127x-317x salvos ficariam acima do teto pra sempre
	bp_milestone_check_ascension() //MARCOS das racas sem forma: BPBoost 5/10/20 sobem o ganho linear (LinearGain.dm)
	var/BPprog = 0
	if(Race=="Frost Demon"||Parent_Race=="Frost Demon") BPprog = 15
	if(BP>=1000000 || BPprog==15)
		if((!TurnOffAscension||AscensionAllowed))
			if((BPprog==15||(!NoAscension&&AscensionStarted))&&!BPincreasing)
				var/nuBPBoost
				formgain=1
				asc=1
				BPprog = max((BP/1000000),BPprog)
				var/BPascenprog = min((BPprog*ascensionmodopf),ascensionmod1) //caps at 5 million. 15 mult cap
				if(BPprog>=74) BPascenprog *= ascensionmod2 //31.875 mult cap
				if(BPprog>=150) BPascenprog *= (((BPprog - 150) / ascensionmod3) + ascensionmodtpf) //127.5 mult cap
				nuBPBoost = min(max(1,BPascenprog),BPBoostCap,20) //teto 20x cravado: BPBoostCap persiste no save (chars antigos vieram com 200)
				nuBPBoost *= (GlobalBPBoost * log(ascensionascmodlg,ascBPmod))
				if(nuBPBoost>=(1.1*BPBoost))//smoothing code. goal is this: if you were to jump from a bpboost of like 2 to suddenly 5, it'll instead slowly increment by 0.01 every second, making the transition a bit smoother.
					if(!BPincreasing)
						BPincreasing = 1
						SmoothGains(nuBPBoost)
					else return
				else if(nuBPBoost>=BPBoost) BPBoost = nuBPBoost

			else if(NoAscension&&AscensionStarted&&!BPincreasing)
				BPBoost = TransformedBPBoost
	else
		BPBoost = 1

mob/proc/SmoothGains(var/TargetBPBoost)
	set waitfor = 0
	while(BPBoost<TargetBPBoost)
		if(NoAscension) //virou NoAscension no meio do smoothing (ex.: gate do Corrupted Majin re-zerou o boost): aborta, senao o alvo nunca e alcancado e BPincreasing fica preso em 1
			BPincreasing = 0
			return
		BPBoost += (0.001 * max(1,(BP/100000)))
		if(BPBoost>=TargetBPBoost)
			BPBoost=TargetBPBoost
			BPincreasing = 0
			return
		sleep(100)