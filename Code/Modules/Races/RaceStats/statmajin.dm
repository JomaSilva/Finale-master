mob/proc/statmajin()
	RaceDescription={"Majins are a genetic anomaly spawned from unknown origins. These beings are born with rather..erm..low intelligence, and not-so impressive stats.\n
They also have incredible death regeneration, rendering them near-immortal. Their control of Ki comes natural to them.\n
Another rather important fact is that these beings can absorb people and take on part of their power and appearance.\n
Often they absorb clothing, which is really just the mimicry they subconsciously use by shaping their body into the form of their victims."}
	if(!genome)
		genome = new/datum/genetics/Majin(/datum/genetics/proto/Majin)
		undelayed=1

/datum/genetics/proto/Majin
	name = "Majin" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Alien","Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 0.9,//stats
		"Physical Defense" = 1.2,
		"Ki Offense" = 0.9,
		"Ki Defense" = 0.5,
		"Ki Skill" = 2.1,
		"Technique" = 1,
		"Speed" = 2,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1.2,
		"Ascension Mod" = 5,
		"Energy Level" = 1.1,//KiMod
		"Battle Power" = 2.3)//BPMod
	misc_stats = list(
		"Lifespan" = 30,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1,//how much potential does this person have?
		"Regeneration" = 100, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 2, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 10, //How fast you adjust and train in gravity.
		"Med Mod" = 1, //How fast you train in meditation.
		"Spar Mod" = 1.8, //How fast you spar.
		"Train Mod" = 1.2, //How fast you train.
		"Ki Regeneration" = 4,//self explanitory, just really a mod.
		"Anger" = 1.3, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 900,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("None" = 100)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
