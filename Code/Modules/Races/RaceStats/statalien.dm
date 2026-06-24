mob/proc/statalien()
	if(!genome)
		healmod=1.5
		AlienCustomization()
		if(prob(10))	RaceDescription="Aliens are scattered all over the Planets of Vegeta, Namek, Arconia, and a few other little Planets. Aliens come in all shapes and sizes- they're not static opponents, which makes them extremely powerful. They have a few subtypes, but if you're not a subtype, your stats could be anything. Non-subtypes can at any point learn certain skills from the game that will become their own racial skill, such as body expand (Zarbon), Time Freeze (Guldo), regeneration or unlock potential (Namekian skills), self destruct, Burst or Observe (Kanassajin skills), Imitation (Demonic skill), and many others."
mob/proc/AlienCustomization()
	//if(Class=="Arlian"||Class=="Kanassa-Jin") return
	givepowerchance -= 0.2
	healmod -= 0.2
	
	var/statboosts = 15
	var/list/choiceslist = list()
	var/list/modified_list = list(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	goback
	choiceslist = list()
	if(statboosts<=0) choiceslist.Add("Done")
	if(statboosts>=1) choiceslist.Add("Add A Stat")
	if(statboosts<=9) choiceslist.Add("Subtract A Stat")
	switch(input(usr,"You, an alien, has the option of increasing different stats. Choose to add/subtract stats until you have a statboost of 0.") in choiceslist)
		if("Done")
			goto end
		if("Add A Stat")
			addchoicestart
			var/list/addchoiceslist = list()
			addchoiceslist.Add("Done")
			if(statboosts>=1)
				if(modified_list[1]==0) addchoiceslist.Add("See Invisible")
				if(modified_list[2]<8) addchoiceslist.Add("physoffMod")
				if(modified_list[3]<6) addchoiceslist.Add("intelligence")
				if(modified_list[4]<8) addchoiceslist.Add("physdefMod")
				if(modified_list[5]<8) addchoiceslist.Add("kioffMod")
				if(modified_list[6]<8) addchoiceslist.Add("kidefMod")
				if(modified_list[7]<8) addchoiceslist.Add("speedMod")
				if(modified_list[8]<8) addchoiceslist.Add("techniqueMod")
				if(modified_list[9]<8) addchoiceslist.Add("kiskillMod")
				if(modified_list[10]<8) addchoiceslist.Add("skillpointMod")
				if(modified_list[18]<8) addchoiceslist.Add("Magic Skill")
				if(modified_list[19]==0) addchoiceslist.Add("Space Breath")
				if(modified_list[20]==0) addchoiceslist.Add("Breed Type")
			if(statboosts>=2)
				if(modified_list[11]<4) addchoiceslist.Add("BP mod")
				if(modified_list[12]<8) addchoiceslist.Add("Zenkai")
				if(modified_list[13]<3) addchoiceslist.Add("Death Regen")
				if(modified_list[14]<3) addchoiceslist.Add("Lifespan")
				if(modified_list[15]<3) addchoiceslist.Add("Misc. Mods")
				if(modified_list[16]<3) addchoiceslist.Add("Anger")
				if(modified_list[17]<3) addchoiceslist.Add("Ascension")
			switch(input(usr,"Pick a stat to add.","","Done") in addchoiceslist)
				if("Done")
					goto goback
				if("See Invisible")
					statboosts-=1
					modified_list[1]++
					see_invisible = 1
					thirdeye = 1
				if("physoffMod")
					statboosts-=1
					modified_list[2]++
				if("intelligence")
					statboosts-=1
					modified_list[3]++
				if("physdefMod")
					statboosts-=1
					modified_list[4]++
				if("kioffMod")
					statboosts-=1
					modified_list[5]++
				if("kidefMod")
					statboosts-=1
					modified_list[6]++
				if("speedMod")
					statboosts-=1
					modified_list[7]++
				if("techniqueMod")
					statboosts-=1
					modified_list[8]++
				if("kiskillMod")
					statboosts-=1
					modified_list[9]++
				if("skillpointMod")
					statboosts-=1
					modified_list[10]++
				if("BP mod")
					statboosts-=2
					modified_list[11]++
				if("Zenkai")
					statboosts-=2
					modified_list[12]++
				if("Death Regen")
					statboosts-=2
					modified_list[13]++
				if("Lifespan")
					statboosts-=2
					modified_list[14]++
				if("Misc. Mods")
					statboosts-=2
					modified_list[15]++
				if("Anger")
					statboosts-=2
					modified_list[16]++
				if("Ascension")
					statboosts-=2
					modified_list[17]++
				if("Magic Skill")
					statboosts-=1
					modified_list[18]++
				if("Space Breath")
					statboosts-=1
					modified_list[19]++
				if("Breed Type")
					statboosts-=1
					modified_list[20]++
			goto addchoicestart
		if("Subtract A Stat")
			subtractchoicestart
			var/list/addchoiceslist = list()
			addchoiceslist.Add("Done")
			if(statboosts<10)
				if(modified_list[1]==1) addchoiceslist.Add("See Invisible")
				if(modified_list[2]>0) addchoiceslist.Add("physoffMod")
				if(modified_list[3]>0) addchoiceslist.Add("intelligence")
				if(modified_list[4]>0) addchoiceslist.Add("physdefMod")
				if(modified_list[5]>0) addchoiceslist.Add("kioffMod")
				if(modified_list[6]>0) addchoiceslist.Add("kidefMod")
				if(modified_list[7]>0) addchoiceslist.Add("speedMod")
				if(modified_list[8]>0) addchoiceslist.Add("techniqueMod")
				if(modified_list[9]>0) addchoiceslist.Add("kiskillMod")
				if(modified_list[10]>0) addchoiceslist.Add("skillpointMod")
				if(modified_list[18]>0) addchoiceslist.Add("Magic Skill")
				if(modified_list[19]==1) addchoiceslist.Add("Space Breath")
				if(modified_list[20]==1) addchoiceslist.Add("Breed Type")
			if(statboosts<=8)
				if(modified_list[11]>0) addchoiceslist.Add("BP mod")
				if(modified_list[12]>0) addchoiceslist.Add("Zenkai")
				if(modified_list[13]>0) addchoiceslist.Add("Death Regen")
				if(modified_list[14]>0) addchoiceslist.Add("Lifespan")
				if(modified_list[15]>0) addchoiceslist.Add("Misc. Mods")
				if(modified_list[16]>0) addchoiceslist.Add("Anger")
				if(modified_list[17]>0) addchoiceslist.Add("Ascension")
			switch(input(usr,"Pick a stat to subtract.","","Done") in addchoiceslist)
				if("Done")
					goto goback
				if("See Invisible")
					statboosts+=1
					see_invisible = 0
					modified_list[1]--
					thirdeye = 0
				if("physoffMod")
					statboosts+=1
					modified_list[2]--
				if("intelligence")
					statboosts++
					modified_list[3]--
				if("physdefMod")
					statboosts+=1
					modified_list[4]--
				if("kioffMod")
					statboosts+=1
					modified_list[5]--
				if("kidefMod")
					statboosts+=1
					modified_list[6]--
				if("speedMod")
					statboosts+=1
					modified_list[7]--
				if("techniqueMod")
					statboosts+=1
					modified_list[8]--
				if("kiskillMod")
					statboosts+=1
					modified_list[9]--
				if("skillpointMod")
					statboosts+=1
					modified_list[10]--
				if("BP mod")
					statboosts+=2
					modified_list[11]--
				if("Zenkai")
					statboosts+=2
					modified_list[12]--
				if("Death Regen")
					statboosts+=2
					modified_list[13]--
				if("Lifespan")
					statboosts+=2
					modified_list[14]--
				if("Misc. Mods")
					statboosts+=2
					modified_list[15]--
				if("Anger")
					statboosts+=2
					modified_list[16]--
				if("Ascension")
					statboosts+=2
					modified_list[17]--
				if("Magic Skill")
					statboosts+=1
					modified_list[18]--
				if("Space Breath")
					statboosts+=1
					modified_list[19]--
				if("Breed Type")
					statboosts+=1
					modified_list[20]--
			goto subtractchoicestart
	end
	if(!genome)
		var/datum/genetics/proto/genome_proto = new/datum/genetics/proto/Alien
		//each prototype with a unique genome yeee
		genome_proto.name = "Alien [ckey] Genome [rand(1,100)]"
		while(fetch_race_by_Name(genome_proto.name))
			genome_proto.name += "[rand(1,100)]"
		genome_proto.m_stats["Physical Offense"] = 1 + modified_list[2]*0.2
		genome_proto.m_stats["Physical Defense"] = 1 + modified_list[4]*0.2
		genome_proto.m_stats["Ki Offense"] = 1 + modified_list[5]*0.2
		genome_proto.m_stats["Ki Defense"] = 1 + modified_list[6]*0.2
		genome_proto.m_stats["Ki Skill"] = 1 + modified_list[9]*0.2
		genome_proto.m_stats["Technique"] = 1 + modified_list[8]*0.2
		genome_proto.m_stats["Speed"] = 1 + modified_list[7]*0.2
		genome_proto.m_stats["Esoteric Skill"] = 0.1 + modified_list[18]
		genome_proto.m_stats["Skillpoint Mod"] = 1 + modified_list[10]*0.2
		genome_proto.m_stats["Ascension Mod"] = 7 + modified_list[17]
		genome_proto.m_stats["Battle Power"] = 1.6 + modified_list[11]*0.2
		genome_proto.m_stats["Energy Level"] = 1.2 + modified_list[9]*0.2
		genome_proto.misc_stats["Lifespan"] = 1 + modified_list[14]
		genome_proto.misc_stats["Potential"] = 1 + modified_list[15]*0.25
		genome_proto.misc_stats["Regeneration"] = 8 + modified_list[13]*2
		genome_proto.misc_stats["Zanzoken Mod"] = (modified_list[15]*0.25)+1.5
		genome_proto.misc_stats["Gravity Mod"] = (modified_list[15]*0.25)+1
		genome_proto.misc_stats["Med Mod"] = (modified_list[15]*0.25)+1.5
		genome_proto.misc_stats["Spar Mod"] = (modified_list[15]*0.25)+2
		genome_proto.misc_stats["Train Mod"] = (modified_list[15]*0.25)+1
		genome_proto.misc_stats["Ki Regeneration"] = 1 + modified_list[9]*0.2
		genome_proto.misc_stats["Anger"] = 1.5 + modified_list[16] * 0.5
		genome_proto.misc_stats["Zenkai"] = 1 + modified_list[12]
		genome_proto.misc_stats["Space Breath"] = modified_list[19]
		genome_proto.misc_stats["Starting BP"] = 1 + modified_list[11]*20
		genome_proto.misc_stats["Tech Modifier"] = 3 + modified_list[3]
		genome_proto.misc_stats["Breed Type"] = modified_list[20]
		genome_proto.original_genome = 1
		//genome_proto.original_save_num = save_path
		//genome_proto.use_num += 1
		//genome_proto.use_key = "[ckey]"
		original_genome_list.Add(genome_proto)
		genome = new/datum/genetics/Alien(genome_proto)

/datum/genetics/proto/Alien
	name = "Alien" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Alien","Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1,//stats
		"Physical Defense" = 1,
		"Ki Offense" = 1,
		"Ki Defense" = 1,
		"Ki Skill" = 1,
		"Technique" = 1,
		"Speed" = 1,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1,
		"Ascension Mod" = 7,
		"Energy Level" = 1,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 1,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
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
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 25,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.