//quarter saiyan is in statsaiyan.dm at the bottom.
//half saiyan is in statsaiyan.dm at the bottom (past quarter)

mob/proc/stathuman()
	RaceDescription="Humans are probably the most well rounded race. They're not as strong in any catagory than any other race- but they're also not really the weakest. That makes them powerful and intuitive for new players. Humans hail from Earth, a lush green planet full of food and monsters."
	if(!genome)
		genome = new/datum/genetics/Human(/datum/genetics/proto/Human)
		//genome.racial_protos["[/datum/genetics/proto/Human]"] = 100
		


/datum/genetics/proto/Human
	name = "Human" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1,//stats
		"Physical Defense" = 1,
		"Ki Offense" = 1,
		"Ki Defense" = 1,
		"Ki Skill" = 1,
		"Technique" = 1.2,
		"Speed" = 1.1,
		"Esoteric Skill" = 1,
		"Skillpoint Mod" = 1.5,
		"Ascension Mod" = 6,
		"Energy Level" = 1.4,//KiMod
		"Battle Power" = 0.95)//BPMod
	misc_stats = list(
		"Lifespan" = 1,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 3,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 5, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 4, //How fast you train in meditation.
		"Spar Mod" = 1.65, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Ki Regeneration" = 3,//self explanitory, just really a mod.
		"Anger" = 1.5, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 0,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 10,//starting BP
		"Tech Modifier" = 3)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	list/Class_Spread = list("Human" = 100)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	list/class_stats = list("None" = list())
