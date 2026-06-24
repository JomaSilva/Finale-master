mob/proc/statshapeshift()
	RaceDescription="Shapeshifters are a very unique Earthling. They are not really Human, or anything really. More akin to a natural Bio-Android, a shapeshifter will take the form of races it wishes. By taking the form of these races, it can also mimic their stats, which is extremely powerful. Their default stats aren't bad either, being weaker Humans. Caution: Shapeshifting will overwrite the default stats. Additionally, shapeshifting (not Imitation) is semi-permanent."
	if(!genome)
		genome = new/datum/genetics/Shapeshifter(/datum/genetics/proto/Shapeshifter)
		see_invisible = 1
/datum/genetics/proto/Shapeshifter
	name = "Shapeshifter" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1.3,//stats
		"Physical Defense" = 1.6,
		"Ki Offense" = 1,
		"Ki Defense" = 1.6,
		"Ki Skill" = 1,
		"Technique" = 1,
		"Speed" = 2,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1,
		"Ascension Mod" = 4,
		"Energy Level" = 1.6,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 3,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 2,//how much potential does this person have?
		"Regeneration" = 2, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 3, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 5, //How fast you adjust and train in gravity.
		"Med Mod" = 4, //How fast you train in meditation.
		"Spar Mod" = 1.5, //How fast you spar.
		"Train Mod" = 1.2, //How fast you train.
		"Ki Regeneration" = 4,//self explanitory, just really a mod.
		"Anger" = 1.4, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 10,//starting BP
		"Tech Modifier" = 2)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	list/Class_Spread = list("None" = 100)