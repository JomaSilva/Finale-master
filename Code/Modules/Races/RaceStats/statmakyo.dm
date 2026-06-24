mob/proc/statmakyo()
	RaceDescription="Makyo are fanged humanoids with a deep connection to demons, and they are prone to transformation. They're quite violent when a certain star is near, and have a reputation for their strong Ki attacks. One of the Kai thought it was a good idea to drop them on a planet with a bunch of bugs, for some reason."
	if(!genome)
		genome = new/datum/genetics/Makyo(/datum/genetics/proto/Makyo)

/datum/genetics/proto/Makyo
	name = "Makyo" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Makyo","Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 2,//stats
		"Physical Defense" = 1,
		"Ki Offense" = 1,
		"Ki Defense" = 1.5,
		"Ki Skill" = 1,
		"Technique" = 1,
		"Speed" = 1.5,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1,
		"Ascension Mod" = 6,
		"Energy Level" = 0.8,//KiMod
		"Battle Power" = 1.4)//BPMod
	misc_stats = list(
		"Lifespan" = 1,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 2,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 2, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 5, //How fast you adjust and train in gravity.
		"Med Mod" = 1.2, //How fast you train in meditation.
		"Spar Mod" = 1.5, //How fast you spar.
		"Train Mod" = 1.1, //How fast you train.
		"Ki Regeneration" = 1,//self explanitory, just really a mod.
		"Anger" = 1.5, //anger stat, this * 100 = final anger.
		"Zenkai" = 0.6, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 50,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	list/Class_Spread = list("None" = 100)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)