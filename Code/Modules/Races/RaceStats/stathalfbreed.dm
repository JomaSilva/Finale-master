mob/proc/stathalfbreed() //halfbreeds should no longer exist but w/e
	RaceDescription="Half-Breed are a product of breeding between any two races. They inherit the basic stats from their mother, and raw BP from their father. (BP Mod not included.) Often, a Half-Breed will share the characteristics of their mother's race."
	if(!genome)
		genome = new/datum/genetics/Halfbreed(/datum/genetics/proto/Halfbreed)
		ssjmult = 1.35
		ultrassjmult = 1.45
		ssj2mult = 1.75
		ssj3mult = 2
		ssj4mult = 1.75 //just in case, Quarter Saiyans and Halfies should never be able to go beyond SSJ3.
		//all reqs are the same, their base is similar to h*mans anyways kek.
		Omult=1.5
//The race is unused, but just in case in testing someone uses it, then whatever it's below. Alternatively, could make a race called a Half Breed. I know theres one from Ben 10 kek.
/datum/genetics/proto/Halfbreed
	name = "Halfbreed" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Alien","Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 3 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1,//stats
		"Physical Defense" = 1,
		"Ki Offense" = 1,
		"Ki Defense" = 1,
		"Ki Skill" = 1,
		"Technique" = 1,
		"Speed" = 1,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1.2,
		"Ascension Mod" = 10,
		"Energy Level" = 1,//KiMod
		"Battle Power" = 1.5)//BPMod
	misc_stats = list(
		"Lifespan" = 5,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 2,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 3, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 5, //How fast you adjust and train in gravity.
		"Med Mod" = 3, //How fast you train in meditation.
		"Spar Mod" = 3, //How fast you spar.
		"Train Mod" = 3, //How fast you train.
		"Ki Regeneration" = 2,//self explanitory, just really a mod.
		"Anger" = 1.2, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 2,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.




mob/proc/statquarter()
	RaceDescription="Quarter Saiyans are the offspring of Half-Saiyans and another race. Typically has the stats of the non-Half-Saiyan race, with some Saiyan traits."
	if(!genome)
		genome = new/datum/genetics/Quarter_Saiyan(/datum/genetics/proto/Saiyan,/datum/genetics/proto/Human)
		genome.racial_protos["[/datum/genetics/proto/Human]"] = 75
		genome.racial_protos["[/datum/genetics/proto/Saiyan]"] = 25
mob/proc/stathalf()
	RaceDescription="Half Saiyans are the product of cross breeding between a Saiyan and a Human. Ascension is generally the same, and with a lot of help may reach SSJ4. Half-Saiyans do also refer to Saiyans and non-Human hybrids but as an actual race it's solely Human-Saiyan hybrids."
	if(!genome)
		genome = new/datum/genetics/Half_Saiyan(/datum/genetics/proto/Saiyan,/datum/genetics/proto/Human)
		genome.racial_protos["[/datum/genetics/proto/Human]"] = 50
		genome.racial_protos["[/datum/genetics/proto/Saiyan]"] = 50