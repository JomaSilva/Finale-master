mob/proc/statdemi()
	Race="Demigod"
	if(Class=="None") Class=input(usr,"Which class?","","") in list("Ogre","Demigod","Genie")
	switch(Class)
		if("Demigod")
			givepowerchance=1
			WaveIcon='Beam2.dmi'
			bursticon='All.dmi'
			ChargeState="8"
			burststate="2"
			BLASTICON='1.dmi'
			BLASTSTATE="1"
			CBLASTICON='18.dmi'
			CBLASTSTATE="18"
			GravMastered=50
			if(!genome)
				genome = new/datum/genetics/Demigod(/datum/genetics/proto/Demigod)
				genome.this_class = "Demigod"
		if("Ogre")
			givepowerchance=1
			WaveIcon='Beam3.dmi'
			bursticon='All.dmi'
			burststate="2"
			var/chargo=rand(1,9)
			ChargeState="[chargo]"
			BLASTICON='31.dmi'
			BLASTSTATE="31"
			CBLASTICON='35.dmi'
			CBLASTSTATE="35"
			GravMastered=60
			if(!genome)
				genome = new/datum/genetics/Demigod(/datum/genetics/proto/Demigod)
				genome.this_class = "Ogre"
		if("Genie")
			givepowerchance=2
			ChargeState="9"
			bursticon='All.dmi'
			burststate="2"
			BLASTSTATE="19"
			CBLASTSTATE="20"
			BLASTICON='19.dmi'
			CBLASTICON='20.dmi'
			GravMastered=23
			see_invisible=1
			if(!genome)
				genome = new/datum/genetics/Demigod(/datum/genetics/proto/Demigod)
				genome.this_class = "Genie"
	RaceDescription="Demigods are either a very very strong varient of some race, or living beings that live in the otherworld to assist the Gods. Genies, Ogres, and Human Demigods all can throw their weight under one specific banner- as a mighty Demigod. Demigods don't have any transformations, but they boast the HIGHEST BP mod in the game. Their stats are lower than Humans, and they don't get any other advantages. Demigod is by far the most straight forward race to play."
	Makkankoicon='Makkankosappo4.dmi'


/datum/genetics/proto/Demigod
	name = "Demigod" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human","Demigod") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1.2,//stats
		"Physical Defense" = 1,
		"Ki Offense" = 1.2,
		"Ki Defense" = 1,
		"Ki Skill" = 1.2,
		"Technique" = 1.2,
		"Speed" = 1.5,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1.2,
		"Ascension Mod" = 5.1,
		"Energy Level" = 1.4,//KiMod
		"Battle Power" = 3)//BPMod
	misc_stats = list(
		"Lifespan" = 30,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1.5,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 5, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 2, //How fast you train in meditation.
		"Spar Mod" = 2, //How fast you spar.
		"Train Mod" = 4, //How fast you train.
		"Ki Regeneration" = 1.2,//self explanitory, just really a mod.
		"Anger" = 1.4, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 0,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 50,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("Ogre" = 33,"Demigod" = 33,"Genie" = 33)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	class_stats = list(
		"Ogre" = list(
			"Physical Offense" = 1.5,
			"Physical Defense" = 1.5,
			"Technique" = 1,
			"Ki Offense" = 1,
			"Ki Defense" = 1.2,
			"Ki Skill" = 0.8,
			"Speed" = 1,
			"Esoteric Skill" = 0.5,
			"Ascension Mod" = 5.2,
			"Skillpoint Mod" = 1,
			"Battle Power" = 3.2,
			"Energy Level" = 1.4,
			"Potential" = 3,
			"Spar Mod" = 3,
			"Train Mod" = 3,
			"Anger" = 1.6
		),
		"Genie" = list(
			"Battle Power" = 2.9,
			"Physical Offense" = 0.5,
			"Physical Defense" = 3,
			"Technique" = 2,
			"Ki Offense" = 0.5,
			"Ki Defense" = 1,
			"Ki Skill" = 1,
			"Speed" = 1,
			"Energy Level" = 2,
			"Ascension Mod" = 4.9,
			"Esoteric Skill" = 2,
			"Skillpoint Mod" = 1.5,
			"Anger" = 1.2,
			"Tech Modifier" = 2,
			"Ki Regeneration" = 2
		)
	)