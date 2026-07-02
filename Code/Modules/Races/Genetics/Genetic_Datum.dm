//how this works and why:
//everything should be mutable ala-doctor gero.
//problem: everything could be mutable but how the hell do you pass it on, also issues with fucking gay ass stats
//solution: everyone has one local copy of their race they fuck with
//when they breed, their two copies combine into a new one for the newborn.
//the 'base' races are stored in a global list- could be changed on a fly for "new" races.
//the whoop:
//lol savefile size lmao

var/list/original_genome_list = list()

datum/genetics
	var
		//proto genome variables
		original_genome = 0//THIS MAKES GENOMES NON-FUNCTIONAL FOR INDIVIDUAL USE. Just sayin'.
		//Its ticked ONLY when we need to have a genome that is a "template" genome up for grabs in the global list.
		/*
		original_save_num = 0 //for Aliens
		use_key = "" //For Aliens, used to delete a prototype when unneeded.
		use_num = 0 //For aliens, ticked up when included in a prototype racial build. Ticked down when a character is beleted?
		*/
		//
		list/old_stats = list()
		list/m_stats = list(
			"Physical Offense" = 1,//stats
			"Physical Defense" = 1,
			"Ki Offense" = 1,
			"Ki Defense" = 1,
			"Ki Skill" = 1,
			"Technique" = 1,
			"Speed" = 1,
			"Esoteric Skill" = 1,
			"Skillpoint Mod" = 1,
			"Ascension Mod" = 1,
			"Energy Level" = 1,//KiMod
			"Battle Power" = 1)//BPMod
		list/modifiers = list()
		gender = "Male"
		old_class = null // to prevent classes from stacking
		this_class = null //what class is *this* genome?
		majority_genome = null //what genome is considered "dominant" of the two? initialization variable
	
	proc //basic stats yay
		assign_stats(index)
			switch(index)
				if("poff") assign_poff()
				if("pdef") assign_pdef()
				if("koff") assign_koff()
				if("kdef") assign_kdef()
				if("kskl") assign_kskl()
				if("tech") assign_tech()
				if("sped") assign_sped()
				if("eskl") assign_eskl()
				if("kimd") assign_kimd()
				if("bpmd") assign_bpmd()
				if("skpm") assign_skpm()
				if("asmd") assign_ascension()
				else
					assign_poff()
					assign_pdef()
					assign_koff()
					assign_kdef()
					assign_kskl()
					assign_tech()
					assign_sped()
					assign_eskl()
					assign_kimd()
					assign_bpmd()
					assign_skpm()
					assign_ascension()
			return TRUE
		assign_poff()
			savant.physoff = m_stats["Physical Offense"]
			return
		assign_pdef()
			savant.physdef = m_stats["Physical Defense"]
			return
		assign_koff()
			savant.kioff = m_stats["Ki Offense"]
			return
		assign_kdef()
			savant.kidef = m_stats["Ki Defense"]
			return
		assign_kskl()
			savant.kiskill = m_stats["Ki Skill"]
			return
		assign_tech()
			savant.technique = m_stats["Technique"]
			return
		assign_sped()
			savant.speed = m_stats["Speed"]
			return
		assign_eskl()
			savant.magiskill = m_stats["Esoteric Skill"]
			return
		assign_kimd()
			savant.KiMod = m_stats["Energy Level"]
			return
		assign_bpmd()
			savant.BPMod = m_stats["Battle Power"]
			return
		assign_ascension()
			savant.ascBPmod = m_stats["Ascension Mod"]
			if(savant.ascBPmod == 0)
				savant.ascBPmod = 1
		assign_skpm()
			savant.skillpointMod = m_stats["Skillpoint Mod"]
	var  //now for misc stats
		list/misc_stats = list(
			"Lifespan" = 1,//to decide if the resultant person has immortality, it has to be 10 or more. otherwise it dictates lifespan.
			"Potential" = 1,//how much potential does this person have?
			"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
			"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
			"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
			"Gravity Mod" = 1, //How fast you adjust and train in gravity.
			"Med Mod" = 1, //How fast you train in meditation.
			"Spar Mod" = 1, //How fast you spar.
			"Train Mod" = 1, //How fast you train.
			"Ki Regeneration" = 1,//self explanitory, just really a mod.
			"Anger" = 1, //anger stat, this * 100 = final anger.
			"Zenkai" = 1, //zenkai, the hax stat.
			"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1.
			"Starting BP" = 1,//starting BP seed. several types.
			"Tech Modifier" = 1,//how naturally good you are at technology
		)
			//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
		list/vital_list = list(/datum/Body/Head,/datum/Body/Head/Brain,/datum/Body/Torso,/datum/Body/Abdomen,/datum/Body/Organs,/datum/Body/Reproductive_Organs)
		list/limb_list = list(/datum/Body/Arm,/datum/Body/Arm/Hand,/datum/Body/Arm,/datum/Body/Arm/Hand,/datum/Body/Leg,/datum/Body/Leg/Foot,/datum/Body/Leg,/datum/Body/Leg/Foot)
		list/extra_limb_list = list()
		list/racial_protos = list()
		//racial_protos = list("[Name]" = 100) In reality, it'd be list('/datum/genetics/proto/GENOME' = 100), where 100 is equal to its "percentage"
		list/race_list = list()//when get races is called or the gene is finalized, this is updated.
	New()
		..()
		for(var/a in args)//iterate ALL args: a type-filtered loop dropped PATH args, leaving racial_protos empty for menu-created chars (statXXX pass /datum/genetics/proto/X paths)
			if(istype(a, /datum/genetics))//a live proto instance
				var/datum/genetics/inst = a
				racial_protos["[inst.name]"] = round(100/args.len)
			else if(ispath(a))//a proto TYPE PATH -> resolve the registered instance
				var/datum/genetics/gene = locate(a) in original_genome_list
				if(!gene) //proto not registered (original_genome_list was empty/cleared at startup) -> create & register it now, so build_stats' fetch_race_by_Name also finds it
					gene = new a
					gene.original_genome = 1
					if(!original_genome_list) original_genome_list = list()
					original_genome_list += gene
				if(gene) racial_protos["[gene.name]"] = round(100/args.len)
		if(racial_protos.len == 0)
			original_genome = 1

	proc
		get_races(var/spec)
			var/list/running_list
			for(var/i in racial_protos)
				if(spec)
					if(racial_protos[i]>=spec) //was racial_protos[racial_protos[i]] -- same double-index bug as race_percent (i is a race-name KEY; racial_protos[i] is its percent)
						running_list += 1
				else running_list += i
			if(spec == null) race_list = running_list
			return running_list
		race_percent(var/chk_race)
			if(chk_race in racial_protos)
				return racial_protos[chk_race] //was racial_protos[racial_protos[chk_race]] -- DOUBLE INDEX: racial_protos[chk_race] is the PERCENT (e.g. 100), so racial_protos[100] indexed the list POSITIONALLY -> "list index out of bounds" (~510 throws/session, killing whatever proc called it: statify/powerlevel/anger_will_transform, incl. the NPC AI's per-tick calls). racial_protos maps race-NAME -> percent, so ONE lookup is correct.
		add_race()
			if(args.len == 0)
				return TRUE
			for(var/a in args)//iterate ALL args (type-filtered loop dropped PATH args)
				if(istype(a, /datum/genetics))
					var/datum/genetics/inst = a
					racial_protos["[inst.name]"] = round(100/args.len)
				else if(ispath(a))
					var/datum/genetics/gene = locate(a) in original_genome_list
					if(gene) racial_protos["[gene.name]"] = round(100/args.len)
			refresh_protos()
			return TRUE
		remove_race()
			if(args.len == 0)
				return TRUE
			for(var/datum/genetics/a in args)
				if(racial_protos.len <= 1) return FALSE //no removing the last one!
				if(istype(a))//if its a new object, put it in protos
					racial_protos.Remove("[a.name]")
				if(ispath(a))//if its a reference to an existing prototype, put that in instead.
					var/datum/genetics/gene = locate(a) in original_genome_list
					if(gene) racial_protos.Remove("[gene.name]")
			refresh_protos()
			return TRUE
		refresh_protos()
			for(var/a in racial_protos)
				racial_protos[racial_protos[a]] = racial_protos.len
			build_stats()
			apply_stats()
		assign_misc(index)
			switch(index)
				if("life") assign_life()
				if("ptnl") assign_potential()
				if("rgen") assign_regen()
				if("bred") assign_breed()
				if("krgn") assign_ki_regen()
				if("angr") assign_Anger()
				if("znki") assign_Zenkai()
				if("trmd") assign_TrainMod()
				if("spmd") assign_SparMod()
				if("mdmd") assign_MedMod()
				if("zamd") assign_zanzo()
				if("grmd") assign_gravmod()
				if("rdsp") assign_Race_Description()
				if("spbr") assign_Space_Breath()
				if("tech") assign_Tech_Modifier()
				if("stbp") assign_starting_BP()
				else
					assign_life()
					assign_potential()
					assign_regen()
					assign_breed()
					assign_ki_regen()
					assign_Anger()
					assign_Zenkai()
					assign_TrainMod()
					assign_SparMod()
					assign_MedMod()
					assign_zanzo()
					assign_gravmod()
					assign_Race_Description()
					assign_Space_Breath()
					assign_Tech_Modifier()
					assign_starting_BP()
			return TRUE

		assign_life()
			savant.DeclineMod = (1 / max(misc_stats["Lifespan"],1)) //guard /0: a collapsed/half-applied Lifespan (0 or null) threw Division-by-zero here (~176/session)
			savant.DeclineAge = 60 * (max(misc_stats["Lifespan"],0)**2)
			savant.DeclineAge=round(savant.DeclineAge,0.1)
			if(misc_stats["Lifespan"] > 20)
				savant.biologicallyimmortal = 1
			else
				savant.biologicallyimmortal = 0
		assign_potential()
			savant.UPMod = misc_stats["Potential"]
		assign_regen()
			savant.canheallopped = 0
			//REWORK NAMEKUSEIJIN: sem regeneracao passiva acelerada -- Namekuseijin sofre dano e cura
			//como um Saiyajin normal (nada de regen em combate, membro decepado NAO volta sozinho, sem
			//death-regen). A regeneracao racial agora e a skill ATIVA Namekian_Regeneration
			//(70% do Ki -> restaura um membro; ver Race Trees/namekian.dm).
			if(savant.Race == "Namekian" || savant.Parent_Race == "Namekian")
				savant.fastRegen = 0
				savant.passiveRegen = (0.2 + (misc_stats["Regeneration"] / 50)) / 5 //mesma taxa das racas normais
				savant.activeRegen = 1 + (misc_stats["Regeneration"] / 25)
				savant.DeathRegen = 0
				return
			savant.fastRegen = (misc_stats["Regeneration"] >= 5) //true accelerated-regen passive (Majin/Bio-Android/Frost) -> still heals mid-combat
			if(misc_stats["Regeneration"] >= 5) //races with naturally accelerated regen (Majin/Bio-Android/Frost Demon) keep their fast natural healing
				savant.passiveRegen = 0.2 + (misc_stats["Regeneration"] / 50)
			else //normal races (Human/Saiyan/etc.) heal ~5x slower
				savant.passiveRegen = (0.2 + (misc_stats["Regeneration"] / 50)) / 5
			savant.activeRegen = 1 + (misc_stats["Regeneration"] / 25)
			savant.DeathRegen = round((misc_stats["Regeneration"] / 10))
			if(savant.DeathRegen >= 1)
				savant.canheallopped = 1
		assign_breed()
			switch(ceil(misc_stats["Breed Type"]))
				if(0)
					savant.E_Breed = 1
					savant.N_Breed = 0
				if(1)
					savant.E_Breed = 0
					savant.N_Breed = 1
				if(2)
					savant.E_Breed = 1
					savant.N_Breed = 1
				if(3)
					savant.E_Breed = 0
					savant.N_Breed = 0
		assign_zanzo()
			savant.zanzomod = misc_stats["Zanzoken Mod"]
		assign_gravmod()
			savant.GravMod = misc_stats["Gravity Mod"]
		assign_ki_regen()
			savant.basekiregen = misc_stats["Ki Regeneration"]
		
		assign_Anger()
			savant.baseAnger = 100 * misc_stats["Anger"]

		assign_Zenkai()
			savant.ZenkaiMod = misc_stats["Zenkai"]
		assign_MedMod()
			savant.MedMod = misc_stats["Med Mod"]
		assign_SparMod()
			savant.SparMod = misc_stats["Spar Mod"]
		assign_TrainMod()
			savant.TrainMod = misc_stats["Train Mod"]
		assign_Space_Breath()
			savant.spacebreather = round(misc_stats["Space Breath"])
		assign_Tech_Modifier()
			savant.techmod = misc_stats["Tech Modifier"]
		
		assign_starting_BP()
			if(this_class == "Mutant Frost Demon") //rare powerful variant: always starts at a huge, per-player-random BP
				savant.BP = rand(200000, 700000)
				return
			var/sbp = misc_stats["Starting BP"]
			if(sbp <= 0) sbp = 1 //guard against divide-by-zero / missing seed
			savant.BP = (sbp/10) + (rand((1 / sbp)*100,200*sbp)/100)
			savant.BP = max(1,savant.BP) //starting BP from race seed only (no server AverageBP)
	proc
		stats(index)
			switch(index)
				if("Lifespan") return misc_stats["Lifespan"]
				if("Potential") return misc_stats["Potential"]
				if("Regeneration") return misc_stats["Regeneration"]
				if("Breed Type") return misc_stats["Breed Type"]
				if("Ki Regeneration") return misc_stats["Ki Regeneration"]
				if("Anger") return misc_stats["Anger"]
				if("Zenkai") return misc_stats["Zenkai"]
				if("Space Breath") return misc_stats["Space Breath"]
				if("Starting BP") return misc_stats["Starting BP"]
				if("Tech Modifier") return misc_stats["Tech Modifier"]
				if("Physical Offense")  return m_stats["Physical Offense"]
				if("Physical Defense")  return m_stats["Physical Defense"]
				if("Ki Offense")  return m_stats["Ki Offense"]
				if("Ki Defense")  return m_stats["Ki Defense"]
				if("Ki Skill")  return m_stats["Ki Skill"]
				if("Technique")  return m_stats["Technique"]
				if("Speed")  return m_stats["Speed"]
				if("Esoteric Skill")  return m_stats["Esoteric Skill"]
				if("Skillpoint Mod")  return m_stats["Skillpoint Mod"]
				if("Energy Level")  return m_stats["Energy Level"]
				if("Battle Power")  return m_stats["Battle Power"]
				if("Zanzoken Mod")  return misc_stats["Zanzoken Mod"]
				if("Med Mod")  return misc_stats["Med Mod"]
				if("Gravity Mod")  return misc_stats["Gravity Mod"]
				if("Spar Mod")  return misc_stats["Spar Mod"]
				if("Train Mod")  return misc_stats["Train Mod"]
				if("Ascension Mod")  return m_stats["Ascension Mod"]
		add_to_stat(index,amount,specifier)
			modifiers[index] += amount
			if(specifier)
				return TRUE
			redo_stats(index)
			redo_misc(index)
			return TRUE
		sub_to_stat(index,amount,specifier)
			modifiers[index] -= amount
			if(specifier)
				return TRUE
			redo_stats(index)
			redo_misc(index)
			return TRUE
		//notice there is no multiply/divide functions. the way oldstats work is that we don't actually want to do that.
		//also, notice that there is no updating here: you must call update manually or use the mob's proc do that for you.
	var
		//usable variables for typings
		tmp/mob/savant = null
		name = "Human" //Name of race.
		base_icon = 'White Male.dmi' //what shows up, I guess?
		list/alternate_icon_flags = list("Human") //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
		list/special_icon_list = list() //
	proc

		apply_stats()
			for(var/a in modifiers)
				if(a in m_stats)
					m_stats[a] += modifiers[a]
				if(a in misc_stats)
					misc_stats[a] += modifiers[a]
			assign_stats(null)
			assign_misc(null)
			for(var/a in modifiers)
				if(a in m_stats)
					m_stats[a] -= modifiers[a]
				if(a in misc_stats)
					misc_stats[a] -= modifiers[a]
			apply_old()
		reapply_stats(var/shapeshift) //in case of genetic manipulation. we need to rebuild stats. this is handled per stat. 'shapeshift' is for the special shapeshift case, which only recieves 'safe' stats.
			for(var/a in modifiers)
				if(a in m_stats)
					m_stats[a] += modifiers[a]
				if(a in misc_stats)
					misc_stats[a] += modifiers[a]
			if(shapeshift)
				assign_poff()
				assign_pdef()
				assign_koff()
				assign_kdef()
				assign_kskl()
				assign_tech()
				assign_sped()
				assign_ascension()
				//misc
				assign_breed()
				assign_Anger()
				assign_ki_regen()
				assign_Space_Breath()
				assign_TrainMod()
				assign_SparMod()
				assign_MedMod()
				assign_zanzo()
				assign_gravmod()
			else
				redo_stats(null)
				redo_misc(null)
			for(var/a in modifiers)
				if(a in m_stats)
					m_stats[a] -= modifiers[a]
				if(a in misc_stats)
					misc_stats[a] -= modifiers[a]
			apply_old()
		apply_old()
			if(!old_stats) old_stats = list() //old_stats starts as an EMPTY list(), so `old_stats[1] =` threw "list index out of bounds" (~421/session) on the FIRST apply -> aborted apply_stats mid-chain -> stats left HALF-APPLIED (the root of the later null.expressedBP / null.Ewillpower / Division-by-zero cascade). Grow to 2 slots before assigning by index.
			while(old_stats.len < 2) old_stats += null
			old_stats[1] = m_stats
			old_stats[2] = misc_stats
		//reapply chain
		redo_stats(index)
			if(index)
				if(index in modifiers)
					m_stats[index] += modifiers[index]
			else
				for(var/a in modifiers)
					if(a in m_stats)
						m_stats[a] += modifiers[a]
			switch(index)
				if("poff") assign_poff()//we use assign for core stats since core stats are worked to be safe. If not, rework the code to follow the other ones procedures.
				if("pdef") assign_pdef()//for the record, these are collapsed for my poor fingies.
				if("koff") assign_koff()//they should be self explanitory and if redefinitions happen these helper procs ensure ease of redef.
				if("kdef") assign_kdef()
				if("kskl") assign_kskl()
				if("tech") assign_tech()
				if("sped") assign_sped()
				if("asmd") assign_ascension()
				if("kimd") redo_kimd()
				if("bpmd") redo_bpmd() //These ones aren't safe since they can be modified ingame
				if("skpm") redo_skpm() //Especially this one. I think.
				if(null)
					assign_poff()
					assign_pdef()
					assign_koff()
					assign_kdef()
					assign_kskl()
					assign_tech()
					assign_sped()
					assign_eskl()
					assign_ascension()
					redo_kimd()
					redo_bpmd()
					redo_skpm()
			if(index)
				if(index in modifiers)
					m_stats[index] -= modifiers[index]
			else
				for(var/a in modifiers)
					if(a in m_stats)
						m_stats[a] -= modifiers[a]
			return TRUE
		redo_kimd() //now safe
			var/o_l = list()
			o_l  =old_stats[1]
			var/add = savant.KiMod - o_l["Energy Level"]
			savant.KiMod = m_stats["Energy Level"]
			savant.KiMod += add
			return
		redo_bpmd() //now safe
			var/o_l = list()
			o_l  =old_stats[1]
			var/add = savant.BPMod - o_l["Battle Power"]
			savant.BPMod = m_stats["Battle Power"]
			savant.BPMod += add
			return
		redo_skpm() //now safe
			var/o_l = list()
			o_l  =old_stats[1]
			var/add = savant.skillpointMod - o_l["Skillpoint Mod"]
			savant.skillpointMod = m_stats["Skillpoint Mod"]
			savant.skillpointMod += add
		
		//mainly split up between safe and unsafe: what can or cant be modified ingame.
		redo_misc(index)
			if(index)
				if(index in modifiers)
					misc_stats[index] += modifiers[index]
			else
				for(var/a in modifiers)
					if(a in misc_stats)
						misc_stats[a] += modifiers[a]
			switch(index)
				//safe
				if("bred") assign_breed()
				if("angr") assign_Anger()
				if("krgn") assign_ki_regen()
				if("spbr") assign_Space_Breath()
				if("trmd") assign_TrainMod()
				if("spmd") assign_SparMod()
				if("mdmd") assign_MedMod()
				if("zamd") assign_zanzo()
				if("grmd") assign_gravmod()
				//unsafe
				if("life") redo_life()
				if("ptnl") redo_potential()
				if("rgen") redo_regen()
				//if("tail") redo_tail()
				if("znki") redo_Zenkai()
				if("tech") redo_Tech_Modifier()
				if(null)
					redo_life()
					redo_potential()
					redo_regen()
					redo_Zenkai()
					redo_Tech_Modifier()
					//redo_tail()
					assign_breed()
					assign_ki_regen()
					assign_Anger()
					assign_Space_Breath()
					assign_TrainMod()
					assign_SparMod()
					assign_MedMod()
					assign_zanzo()
					assign_gravmod()
			if(index)
				if(index in modifiers)
					misc_stats[index] -= modifiers[index]
			else
				for(var/a in modifiers)
					if(a in misc_stats)
						misc_stats[a] -= modifiers[a]
			return TRUE

		redo_life()//all below are now 'safe'
			var/o_l = list()
			o_l = old_stats[2]
			savant.DeclineMod = (savant.DeclineMod - o_l["Lifespan"]) + (1 / (misc_stats["Lifespan"]))
			savant.DeclineAge = (savant.DeclineAge - o_l["Lifespan"]) + (60 * (misc_stats["Lifespan"]**2))
			savant.DeclineAge=round(savant.DeclineAge,0.1)
			if(misc_stats["Lifespan"] > 10)
				savant.biologicallyimmortal = 1
			else
				savant.biologicallyimmortal = 0
		redo_potential()
			var/o_l = list()
			o_l  =old_stats[2]
			savant.UPMod = (savant.UPMod - o_l["Potential"]) + misc_stats["Potential"]
		redo_regen()
			var/o_l = list()
			o_l  =old_stats[2]
			savant.canheallopped = 0
			//REWORK NAMEKUSEIJIN: identico ao assign_regen -- o relog (apply_old) nao pode re-conceder
			//fastRegen/DeathRegen a um Namekuseijin (valores ABSOLUTOS aqui, sem a conta de diff)
			if(savant.Race == "Namekian" || savant.Parent_Race == "Namekian")
				savant.fastRegen = 0
				savant.passiveRegen = (0.2 + (misc_stats["Regeneration"] / 50)) / 5
				savant.activeRegen = 1 + (misc_stats["Regeneration"] / 25)
				savant.DeathRegen = 0
				return
			savant.fastRegen = (misc_stats["Regeneration"] >= 5) //true accelerated-regen passive (Majin/Bio-Android/Frost) -> still heals mid-combat
			savant.passiveRegen = (savant.passiveRegen - o_l["Regeneration"]) + (misc_stats["Regeneration"] / 50)
			savant.activeRegen = (savant.activeRegen - o_l["Regeneration"]) + (1 + (misc_stats["Regeneration"] / 25))
			savant.DeathRegen = (savant.DeathRegen - o_l["Regeneration"]) + round((misc_stats["Regeneration"] / 10))
			if(savant.DeathRegen >= 1)
				savant.canheallopped = 1

		redo_Zenkai()
			var/o_l = list()
			o_l  =old_stats[2]
			savant.ZenkaiMod = (savant.ZenkaiMod - o_l["Zenkai"]) + misc_stats["Zenkai"]
		redo_Tech_Modifier()
			var/o_l = list()
			o_l  =old_stats[2]
			savant.techmod = (savant.techmod - o_l["Tech Modifier"]) + misc_stats["Tech Modifier"]
			savant.techmod = min(9,savant.techmod)
	proc //now for the semi-finale- deciding the actual race. we're going the lazy route for now
	//lazy route being taking the largest fat section up top of what race makes up you and assigning that as your primary race
	//then if you have two or more major sections of genetic code you become a hybrid of those two races.
	//stats look basically at the goal. everything else (specially trees) do not. for right now this works.
		decide_Race() //we actually run this on new, somewhat.
			if(racial_protos.len > 1)
				var/majority_point = 0
				majority_genome = null
				var/running_name = "Hybrid"
				var/list/running_list[3]
				for(var/I=1,I <= racial_protos.len,I++)//its possible to have a fuckton of races in your genetics
					var/datum/genetics/race_datum = fetch_race_by_Name("[racial_protos[I]]")
					var/weight = racial_protos[racial_protos[I]]//this'll return the weight of a race. weight is the "proportion" of your genes. like 50% saiyan and 50% human.
					if(weight>= (105/racial_protos.len))//50/50 hybrids will never meet this check. (hopefully)
						if(majority_point < weight * race_datum.prevalance)//this will ensure your race name is equal to the name of the race with a large majority.
							majority_point=weight * race_datum.prevalance //if theres multiple races the race with the largest prevalance value dominates always.
							running_name=race_datum.name//name set to the dominant, majority race.
							majority_genome = race_datum.name//savant will see this as their "father" race.
					else
						running_list[round(min(1,3 - weight/50))] = race_datum.name//alright, we queue up the name for generation of the hybrid racial name
				if(majority_point==0) for(var/A in running_list) //bing bing wahoo we did it lads. simple for() layering the name.
					var/nn = A + running_name
					running_name = nn
				if(majority_genome == 0)
					var/datum/genetics/major_pick = fetch_race_by_Name(pick(racial_protos))
					majority_genome = major_pick.name//we do this funky way instead of pick(racial_protos).name so that the editor doesn't murder us.
				name = running_name //note the NAME is for our eventual coming-on to the user of this given race datum.
			else
				name = fetch_race_by_Name("[racial_protos[1]]").name //if the parts of our biology are singular, just use that singular race lmao
			decide_Class()

		decide_Class(class_override)//this is actually ran
			if(old_class && !class_override) //safety button.
				return old_class
			for(var/I = 1, I <= Class_Spread.len,I++) //so this looks at the class spread for the generated race.
				if(prob(Class_Spread[Class_Spread[I]]))//we run probability checks for each class
					this_class = Class_Spread[I]//bing badda boom they pass it? break the for loop.
					break
				if(I == Class_Spread.len)//only one "class"? we done here, set it and gtfo
					this_class = Class_Spread[I]
			if(class_override)
				this_class = class_override//if, for some reason, you can change classes, you can specify within here.
			old_class = this_class
			return this_class

		rarest_class() //the lowest-weight (rarest) entry in the race's Class_Spread
			var/list/cs = Class_Spread
			if(!cs || !cs.len) //menu-created chars can have an empty genome spread -> fall back to the race proto's
				var/datum/genetics/proto = fetch_race_by_Name(name)
				if(proto) cs = proto.Class_Spread
			if(!cs || !cs.len) return null
			var/rarest = null
			var/minw = null
			for(var/cls in cs)
				if(cls == "None") continue //"None" isn't a real class to force (single-None races would otherwise be blanked)
				var/w = cs[cls]
				if(isnull(minw) || w < minw)
					minw = w
					rarest = cls
			return rarest
				
		finalize_Race()
			if(!savant) return FALSE //no savant, we return.
			if(majority_genome) //hybrids: dominant genome decides race; single-race chars keep the race set in Race()
				savant.Race = "[majority_genome]"
				savant.Parent_Race = "[majority_genome]"
			var/pk = savant.ckey //admin debug: resolve the account key robustly (savant.ckey can be empty if the mob isn't fully bound yet during creation)
			if(!pk && savant.key) pk = ckey(savant.key)
			if(pk && (pk in force_rarest_class)) //backup to the StatRace force: catches paths where the early hook couldn't resolve the race proto
				var/rc = rarest_class()
				if(rc)
					this_class = rc
					old_class = rc
					force_rarest_class -= pk //one-time
					Save_Settings()
			if(this_class) savant.Class = this_class //don't blank a class statmajin/decide_Class already set
			get_races()
			return TRUE
		
		//
		//
		//what you should call:
		//
		//
		post_init_savant()
			if(finalize_Race() == FALSE) return FALSE//we decide the "race" first thing, meaning we actually hafta apply shit here.
			build_stats()//menu-created (non-bred) chars never ran build_stats, so misc_stats stayed at base defaults (Starting BP=1 -> BP~1). Build now so race+class stats actually apply.
			apply_stats()//then stats

		logout()
			if(original_genome) return FALSE
			else
				if(!savant)
					del(src)
				if(usr == savant)
					del(src)
		login(mob/mobbu)
			if(!savant)
				savant = mobbu
		//build() - This is defined in Genetic_Sex.dm, use this to actually finalize stats.
/*
racial boundaries are still kept intact, if you're a hybrid then you get marked as such, but your 'father' race is marked as your largest part. (or the most prevalant if 50/50)
*/

// ---------------------------------------------------------------------------
// Race "carrier" genome subtypes.
// A mob's live genome (mob/var/datum/genetics/genome) is created as one of these
// per-race subtypes, seeded from the matching /datum/genetics/proto/<Race>
// prototype that is passed into New(). They intentionally carry no extra data of
// their own (all stats come from the seeded prototype) and exist purely so the
// many `new/datum/genetics/<Race>(...)` call sites resolve to a real type.
// ---------------------------------------------------------------------------
/datum/genetics/proc/assign_Race_Description()
	// Race description text is applied directly to the mob by its stat<Race>() proc,
	// so this datum-side hook is a no-op kept for the assign_misc() dispatch table.
	return TRUE

/datum/genetics/Alien
/datum/genetics/Android
/datum/genetics/Arlian
/datum/genetics/Artificial
/datum/genetics/BioAndroid
/datum/genetics/Custom
/datum/genetics/Demigod
/datum/genetics/Demon
/datum/genetics/Gray
/datum/genetics/Half_Saiyan
	//Half-Saiyan lineages (class_stats themselves live on the Saiyan proto, read per-ancestor in build_stats).
	//Set on the carrier so BRED Half-Saiyans roll among the three; New Generation is LAST so decide_Class's force-last fallback lands on the standard lineage.
	Class_Spread = list("Future Lineage" = 15,"Awakened Evolution" = 15,"New Generation" = 70)
/datum/genetics/Halfbreed
/datum/genetics/Heran
/datum/genetics/Human
/datum/genetics/Icer
/datum/genetics/Kai
/datum/genetics/Kanassa
/datum/genetics/Majin
/datum/genetics/Makyo
/datum/genetics/Meta
/datum/genetics/Namekian
/datum/genetics/Quarter_Saiyan
/datum/genetics/Saibaman
/datum/genetics/Saiyan
	extra_limb_list = list(/datum/Body/Tail/Saiyan_Tail) //pure Saiyans are born with a tail; TestMobParts reads genome.extra_limb_list directly (build_stats only seeds it for hybrids via majority_genome, which single-race chars never set)
/datum/genetics/Shapeshifter
/datum/genetics/SpiritDoll
/datum/genetics/Tsujin
/datum/genetics/Yardrat
