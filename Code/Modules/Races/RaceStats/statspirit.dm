mob/proc/statspirit()
	RaceDescription="Spirit Dolls are almost human. Emphasis on almost. A race of artifical lifeforms, they closely resemble humans, except pale as porcelain. Because, that's what they were- porcelain. Luckily, when they came to life they are almost indistinguishable from humans. Gameplaywise, they're not. Low stats, high speed, high energy, low power, decent ascension, and high a skillpoint modifier. This makes them a fast but furious fighter- one that specializes in Ki specifically. Their Ki regeneration is pretty darn good too. Additionally, Spirit Dolls do have the ability to leave children."
	if(!genome)
		genome = new/datum/genetics/SpiritDoll(/datum/genetics/proto/SpiritDoll)
		see_invisible = 1
/datum/genetics/proto/SpiritDoll
	name = "Spirit Doll" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 0.8,//stats
		"Physical Defense" = 0.8,
		"Ki Offense" = 1.6,
		"Ki Defense" = 1,
		"Ki Skill" = 1,
		"Technique" = 0.8,
		"Speed" = 2.5,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 2,
		"Ascension Mod" = 7,
		"Energy Level" = 2,//KiMod
		"Battle Power" = 0.9)//BPMod
	misc_stats = list(
		"Lifespan" = 8,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 4,//how much potential does this person have?
		"Regeneration" = 3, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 4, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 5, //How fast you adjust and train in gravity.
		"Med Mod" = 4, //How fast you train in meditation.
		"Spar Mod" = 1.65, //How fast you spar.
		"Train Mod" = 1.1, //How fast you train.
		"Ki Regeneration" = 4,//self explanitory, just really a mod.
		"Anger" = 1.3, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 10,//starting BP
		"Tech Modifier" = 4)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	list/Class_Spread = list("None" = 100)