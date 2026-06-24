mob/proc/statandroid()
	undelayed=1
	givepowerchance=0
	bursticon='All.dmi'
	burststate="5"
	ChargeState="2"
	BLASTSTATE="10"
	CBLASTSTATE="11"
	BLASTICON='10.dmi'
	CBLASTICON='11.dmi'
	RaceDescription="Androids are 100% robotic. A difference between other races is that they are much weaker at birth then their organic counterparts, and have a MUCH higher endurance ability than them. They also absorb energy skills, but also can absorb life-forms. They have lower recovery abilities as well, but their repetoire of modules more than makes up for that. Echoes in the cosmos even speak of infinite energy being attainable by these beings."
	CanEat = 0
	GravMastered=200
	if(!genome)
		genome = new/datum/genetics/Android(/datum/genetics/proto/Android)

/datum/genetics/proto/Android
	name = "Android" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human","Android") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1.5,//stats
		"Physical Defense" = 2,
		"Ki Offense" = 1,
		"Ki Defense" = 1,
		"Ki Skill" = 1.2,
		"Technique" = 1.5,
		"Speed" = 1.5,
		"Esoteric Skill" = 0.1,
		"Skillpoint Mod" = 1,
		"Ascension Mod" = 8,
		"Energy Level" = 1.5,//KiMod
		"Battle Power" = 2)//BPMod
	misc_stats = list(
		"Lifespan" = 32,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 0.5,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 3, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 4, //How fast you train in meditation.
		"Spar Mod" = 2, //How fast you spar.
		"Train Mod" = 0.8, //How fast you train.
		"Ki Regeneration" = 1,//self explanitory, just really a mod.
		"Anger" = 1, //anger stat, this * 100 = final anger.
		"Zenkai" = 0.5, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 25,//starting BP
		"Tech Modifier" = 4)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.