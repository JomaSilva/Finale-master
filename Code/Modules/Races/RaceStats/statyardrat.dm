mob/proc/statyard()
	givepowerchance=1
	bursticon='All.dmi'
	ChargeState="5"
	burststate="2"
	BLASTSTATE="7"
	BLASTICON='7.dmi'
	CBLASTICON='8.dmi'
	CBLASTSTATE="8"
	RaceDescription="Yardrats are weak, frail, and rather unimpressive. Even with these drawbacks, they are -the- fastest race in existance, with lower delays on attacks and energy skills, and have the natural ability to instantly move to anyone they have met and comitted to memory."
	Makkankoicon='Makkankosappo.dmi'
	hasayyform = 1
	GravMastered=23
	see_invisible=1
	if(!genome)
		genome = new/datum/genetics/Yardrat(/datum/genetics/proto/Yardrat)

/datum/genetics/proto/Yardrat
	name = "Yardrat" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 0.7,//stats
		"Physical Defense" = 0.6,
		"Technique" = 1.1,
		"Ki Offense" = 1.2,
		"Ki Defense" = 0.6,
		"Ki Skill" = 1,
		"Speed" = 2.5,
		"Esoteric Skill" = 0.5,
		"Skillpoint Mod" = 1.2,
		"Ascension Mod" =8,
		"Energy Level" = 1.5,//KiMod
		"Battle Power" = 1.2)//BPMod
	misc_stats = list(
		"Lifespan" = 2,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1,//how much potential does this person have?
		"Regeneration" = 10, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 0, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 5, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 0.9, //How fast you adjust and train in gravity.
		"Med Mod" = 4, //How fast you train in meditation.
		"Spar Mod" = 1.5, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Ki Regeneration" = 2,//self explanitory, just really a mod.
		"Anger" = 1.05, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 20,//starting BP
		"Tech Modifier" = 0.5)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.