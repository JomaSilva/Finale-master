mob/proc/statkai()
	RaceDescription="Kais are what would be the ultimate beings of the universe, if they were not as lazy as they were. They have a very high battle power modifier, and a very good starting power, as well as great stats and the ability to regenerate from attacks that would normally kill people. They can reverse death and teleport, yes teleport, from planet to planet and even between the Afterlife and the Living Realm. They are very fickle in nature, and can be good and benevolent one minute, and evil and coniving the next. Some Kais align themselves with Demons due to their attraction to power, and some are the pinnacle of Good ideals, much like the true Kai."
	if(!genome)
		genome = new/datum/genetics/Kai(/datum/genetics/proto/Kai)

/datum/genetics/proto/Kai
	name = "Kai" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human","Kai") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 2,//stats
		"Physical Defense" = 2,
		"Ki Offense" = 2,
		"Ki Defense" = 2,
		"Ki Skill" = 2,
		"Technique" = 2,
		"Speed" = 2,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 0.8,
		"Ascension Mod" = 6,
		"Energy Level" = 2,//KiMod
		"Battle Power" = 2)//BPMod
	misc_stats = list(
		"Lifespan" = 25,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1,//how much potential does this person have?
		"Regeneration" = 10, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 10, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 3.3, //How fast you train in meditation.
		"Spar Mod" = 1.5, //How fast you spar.
		"Train Mod" = 1.1, //How fast you train.
		"Ki Regeneration" = 4,//self explanitory, just really a mod.
		"Anger" = 1.2, //anger stat, this * 100 = final anger.
		"Zenkai" = 0.5, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 600,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.