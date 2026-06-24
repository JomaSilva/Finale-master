mob/proc/statmeta()
	RaceDescription="Meta Description: The Robotic-like lifeforms that inhabit the Big Gete Star, they are nearly as advanced as Tsujins and use a Core Computer to create organic copies of themselves, being able to inhabit the copy at will, although the copies are not very strong. Not only are they intellectual, but they are great at using energy. Their power is quite high as well, and their skills also excel above normal races."
	if(!genome)
		genome = new/datum/genetics/Meta(/datum/genetics/proto/Meta)

/datum/genetics/proto/Meta
	name = "Meta" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1,//stats
		"Physical Defense" = 2,
		"Ki Offense" = 1,
		"Ki Defense" = 2,
		"Ki Skill" = 1,
		"Technique" = 1,
		"Speed" = 2.4,
		"Esoteric Skill" = 0.1,
		"Skillpoint Mod" = 1,
		"Ascension Mod" = 6,
		"Energy Level" = 0.8,//KiMod
		"Battle Power" = 1.5)//BPMod
	misc_stats = list(
		"Lifespan" = 32,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 0.5,//how much potential does this person have?
		"Regeneration" = 10, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 0, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 10, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 5, //How fast you adjust and train in gravity.
		"Med Mod" = 1, //How fast you train in meditation.
		"Spar Mod" = 2, //How fast you spar.
		"Train Mod" = 1.5, //How fast you train.
		"Ki Regeneration" = 2,//self explanitory, just really a mod.
		"Anger" = 1.2, //anger stat, this * 100 = final anger.
		"Zenkai" = 0.5, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 25,//starting BP
		"Tech Modifier" = 3.5)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.