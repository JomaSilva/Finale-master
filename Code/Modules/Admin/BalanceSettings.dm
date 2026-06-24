var/globalmeleeantispeed=1
var/trainmult = 1
mob/Admin2/verb/Balance_Settings()
	set category = "Admin"
	switch(input(usr,"Which settings? Most are NOT toggled. They will tell you what their default is.","Balanced Settings", "Cancel") in list("Cancel","Train","Ki Attack Damage","Ki Drain", \
		"Melee Damage", "Melee Speed","Melee Anti-Speed","Stamina Drain","Grav Gain","Food Stamina Gain","Ki Exp Rate","Resource Gains","grav Balance","power Mult","globalkiarmormod","Tech Gains Mult","Net Cap",\
		"Spar Gains","Train Gains","Med Gains","Blast Gains","Train Meditation To Hidden Potential","NPC Sparring","Legends Pre-Ascension","Legends Override"))
		if("Train") trainmult = input(usr,"Set the current train mult. Normally 1x.","",trainmult) as num
		if("Ki Attack Damage") globalKiDamage = input("Put in the Ki attack mult. 5x is default.","",globalKiDamage) as num
		if("Ki Drain") globalKiDrainMod = input(usr,"Global Ki drain mod. Normally 1x","",globalKiDrainMod) as num
		if("Melee Damage") globalmeleeattackdamage = input(usr,"Melee attack damage. Normally 0.75x","",globalmeleeattackdamage) as num
		if("Melee Speed") globalmeleeattackspeed = input(usr,"Melee attack speed. Normally 1x","",globalmeleeattackspeed) as num
		if("Melee Anti-Speed") globalmeleeantispeed = input(usr,"Set the global melee-anti speed. (Normally 1x)","", globalmeleeantispeed) as num
		if("Stamina Drain") globalstamdrain = input(usr,"Set the global stamina drain. (Normally 1x)","", globalstamdrain) as num
		if("Grav Gain") GlobalGravGain = input("Gravity gains multiplier? It's normally 1x.","",GlobalGravGain) as num
		if("Food Stamina Gain") globalfoodmod = input(usr,"Set the global food mod. (Normally 1x)","", globalfoodmod) as num
		if("Ki Exp Rate")
			var/kirate = input("What do you want to change the rate to? The current rate is [GlobalKiExpRate].","",GlobalKiExpRate) as num
			GlobalKiExpRate = kirate
			usr<<"Ki Exp Rate set to [GlobalKiExpRate]"
		if("Resource Gains") GlobalResourceGain = input(usr,"Gain mult","",GlobalResourceGain) as num
		if("grav Balance") gravBalance = input(usr,"grav mult, norm is 1x","",gravBalance) as num
		if("power Mult") powerMult = input(usr,"power mult, norm is [initial(powerMult)]x","",powerMult) as num
		if("globalkiarmormod") globalkiarmormod = input(usr,"armor mult, determines how much damage is absorbed by armor. [initial(globalkiarmormod)]x","",globalkiarmormod) as num
		if("Tech Gains Mult") techMult = input(usr,"Technology Gains mult. Determines how much it takes to get to the next level. (Lower num = faster.) [initial(techMult)]x","",techMult) as num
		if("Net Cap") global_net_cap = input(usr,"Net cap base. Determines what the limiting factor for Netbuff is.. (Lower num = bigger netbuff softcap.) [initial(global_net_cap)]x","",global_net_cap) as num
		if("Spar Gains") global_spar_gain = input(usr,"Sparring gains mult [initial(global_spar_gain)]x","",global_spar_gain) as num
		if("Train Gains") global_train_gain = input(usr,"Training gains mult [initial(global_train_gain)]x","",global_train_gain) as num
		if("Med Gains") global_med_gain = input(usr,"Meditating gains mult [initial(global_med_gain)]x","",global_med_gain) as num
		if("Blast Gains") global_blast_gain = input(usr,"Blasting gains mult [initial(global_blast_gain)]x","",global_blast_gain) as num
		if("Train Meditation To Hidden Potential")
			if(train_med_to_hp)
				train_med_to_hp = 0
				world << "Training and meditation no longer is going to HP instead."
			else
				train_med_to_hp = 1
				world << "Training and meditation is now going to HP instead."
		if("NPC Sparring")
			if(npc_sparring)
				npc_sparring = 0
				world << "Sparring gains with NPCs no longer use player to player calcs."
			else
				npc_sparring = 1
				world << "Sparring gains with NPCs use player to player calcs (reduced)."
		if("Legends Pre-Ascension")
			if(legend_pre_ssj)
				legend_pre_ssj = 0
				world << "Legends cannot be made pre-ascension. Override exists, legends must be active to be the only one."
			else
				legend_pre_ssj = 1
				world << "Legends can be made pre-ascension."
		if("Legends Override")
			if(legend_overrider)
				legend_overrider = 0
				world << "Override does not exist, legends do not need to be active to be the only one."
			else
				legend_overrider = 1
				world << "Override exists, legends must be active to be the only one."
var/techMult = 1 //manipulates how fast tech xp is gained.
var/powerMult = 1.25
var/gravBalance = 1
var/globalKiDrainMod = 1
var/globalmeleeattackdamage = 0.75
var/globalmeleeattackspeed = 1
var/GlobalGravGain = 1
var/globalfoodmod = 1
var/GlobalResourceGain = 3
var/globalkiarmormod = 1
var/global_net_cap = 1.8
var/global_spar_gain = 1
var/global_train_gain = 1
var/global_blast_gain = 1
var/global_med_gain = 1
var/train_med_to_hp = 0
var/npc_sparring = 0