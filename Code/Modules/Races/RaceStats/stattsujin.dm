mob/proc/stattsujin()
	givepowerchance=0.2
	bursticon='All.dmi'
	burststate="5"
	BLASTSTATE="5"
	BLASTICON='5.dmi'
	CBLASTICON='6.dmi'
	CBLASTSTATE="6"
	ChargeState="6"
	RaceDescription="Tsujin are puny manlets who are good at techie stuff. Despite their long history with machines, they do actually have an aptitude for Magic, though no one seems to know how to unlock it. Tsujins have, physically, absolutely no redeeming qualities. They do sport a unnatural beauty, long lifespan, and more among most races, so take that as you will."
	Makkankoicon='Makkankosappo3.dmi'
	GravMastered=10
	mob_size = MOB_SIZE_SMALL
	if(!genome)
		genome = new/datum/genetics/Tsujin(/datum/genetics/proto/Tsujin)

/datum/genetics/proto/Tsujin
	name = "Tsujin" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 0.8,//stats
		"Physical Defense" = 0.8,
		"Technique" = 0.8,
		"Ki Offense" = 0.8,
		"Ki Defense" = 0.8,
		"Ki Skill" = 0.8,
		"Speed" = 1.5,
		"Esoteric Skill" = 0.8,
		"Skillpoint Mod" = 1.5,
		"Ascension Mod" =6,
		"Energy Level" = 0.8,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 2,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1,//how much potential does this person have?
		"Regeneration" = 10, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 2, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 1.2, //How fast you train in meditation.
		"Spar Mod" = 1.65, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Ki Regeneration" = 2,//self explanitory, just really a mod.
		"Anger" = 1.4, //anger stat, this * 100 = final anger.
		"Zenkai" = 3, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 1,//starting BP
		"Tech Modifier" = 7)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
