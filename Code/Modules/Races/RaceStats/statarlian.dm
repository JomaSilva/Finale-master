mob/proc/statarlian()
	RaceDescription="Arlians are bug-men who shouldn't exist. No one knows why they're here, or why they're sharing a planet with the Makyo, but no one cares enough to ask them why. They're actually extremely skilled from a technical point of view, if plagued with abyssmal BP below even that of humans."
	if(!genome)
		genome = new/datum/genetics/Arlian(/datum/genetics/proto/Arlian)
/datum/genetics/proto/Arlian
	name = "Arlian" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Alien") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1.5,//stats
		"Physical Defense" = 0.9,
		"Ki Offense" = 1.25,
		"Ki Defense" = 0.9,
		"Ki Skill" = 1,
		"Technique" = 1.5,
		"Speed" = 2.4,
		"Esoteric Skill" = 0.6,
		"Skillpoint Mod" = 1.7,
		"Ascension Mod" = 7,
		"Energy Level" = 1.3,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 1,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 4,//how much potential does this person have?
		"Regeneration" = 5, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 0, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 20, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 5, //How fast you adjust and train in gravity.
		"Med Mod" = 3, //How fast you train in meditation.
		"Spar Mod" = 1, //How fast you spar.
		"Train Mod" = 3, //How fast you train.
		"Ki Regeneration" = 1.2,//self explanitory, just really a mod.
		"Anger" = 1.1, //anger stat, this * 100 = final anger.
		"Zenkai" = 1.5, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 5,//starting BP
		"Tech Modifier" = 5)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.