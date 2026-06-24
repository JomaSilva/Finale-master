mob/proc/statsaiba()
	RaceDescription="Saibaman are used as training dummies. Or as pets. Unusually the second. However, a small subset of Saibaman exhibit higher intelligence- this subset, if you pick this race, is you. Saibaman have low stats, low energy, and low power. However, some stats are relatively high, and their misc modifiers are also decent. Their skill tree ain't bad either- and you gain access to the Self Destruct technique."
	if(!genome)
		genome = new/datum/genetics/Saibaman(/datum/genetics/proto/Saibaman)
		partplant=1
		Metabolism = 2
		satiationMod = 1
/datum/genetics/proto/Saibaman
	name = "Saibamen" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Saibamen") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1,//stats
		"Physical Defense" = 1.7,
		"Ki Offense" = 2,//secret saiba shanagians
		"Ki Defense" = 1.5,
		"Ki Skill" = 0.9,
		"Technique" = 0.8,
		"Speed" = 2,//secret saiba shanagians
		"Esoteric Skill" = 0.4,
		"Skillpoint Mod" = 1.6,//further shanagians
		"Ascension Mod" = 4,
		"Energy Level" = 1,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 5,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 4,//how much potential does this person have?
		"Regeneration" = 5, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 0, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 10, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 4, //How fast you adjust and train in gravity.
		"Med Mod" = 5, //How fast you train in meditation.
		"Spar Mod" = 1.25, //How fast you spar.
		"Train Mod" = 1.1, //How fast you train.
		"Ki Regeneration" = 4,//self explanitory, just really a mod.
		"Anger" = 1.2, //anger stat, this * 100 = final anger.
		"Zenkai" = 1.1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 80,//starting BP
		"Tech Modifier" = 3)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	list/Class_Spread = list("None" = 100)