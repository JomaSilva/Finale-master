mob/proc/statdemon()
	RaceDescription="Demons come from hell, and due to the harsh conditions there with all the lava and stuff, they have evolved to the extreme condition which makes their bodies very very strong, in fact, if you compare them to Saiyans they are physically stronger and faster, they arent quite as endurant to physical attacks as most Saiyans. They find it easy to land hits on opponents, and arent that bad at dodging and blocking. Demons typically arent that gifted mentally but they make up for it with all their raw power and progress easily in CERTAIN skills. Demons are for the most part mindless killing machines who only want to absorb more and more souls by any means necessary, but their intelligence is linked to their power so the stronger they get the smarter and even less evil they can become. They also have the ability to imitate People, but only in name and appearance. They have the special ability to turn People into Majins after they meet certain requirements. It is worth mentioning that a Demon masters gravity at one of the fastest rates of all races, the only ones that come close are probably Frost FDemons. They are slow in ki recovery which also means they dont gather ki very fast either, for example they powerup slowly because of their slow energy gathering. Also, even though their endurance is not that great, they have very good resistance to energy attacks. Also they can learn to become invisible."
	if(!genome)
		genome = new/datum/genetics/Demon(/datum/genetics/proto/Demon)
		GravMastered=25

/datum/genetics/proto/Demon
	name = "Demon" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Demon") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 2 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1.1,//stats
		"Physical Defense" = 1.1,
		"Ki Offense" = 1.8,
		"Ki Defense" = 1.8,
		"Ki Skill" = 1.4,
		"Technique" = 1,
		"Speed" = 1.1,
		"Esoteric Skill" = 0.5,
		"Skillpoint Mod" = 1.3,
		"Ascension Mod" = 6.25,
		"Energy Level" = 1.1,//KiMod
		"Battle Power" = 1.7)//BPMod
	misc_stats = list(
		"Lifespan" = 21,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 3, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 10, //How fast you adjust and train in gravity.
		"Med Mod" = 2, //How fast you train in meditation.
		"Spar Mod" = 1.8, //How fast you spar.
		"Train Mod" = 1.1, //How fast you train.
		"Ki Regeneration" = 0.8,//self explanitory, just really a mod.
		"Anger" = 1, //anger stat, this * 100 = final anger.
		"Zenkai" = 4, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 125,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.