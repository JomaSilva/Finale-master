mob/proc/statnamek()
	RaceDescription="Namekians are a peaceful race. Low in stats, but decent everywhere else, they make for a race that's almost as easy to play as Humans. They have a transformation, and a special variant called a Albino Namekian. They're particularly ferocious and betray the race's peaceful traits. Additionally, all Namekians are very good at regeneration."
	if(!genome)
		genome = new/datum/genetics/Namekian(/datum/genetics/proto/Namekian)
		if(Class=="None") Class=input(usr,"Which class? New Namekian and Namekian have almost no differences aside from the name. Albino Namekians however are a bit more stat-heavy and abandon the boost in skill points others get.","","") in list("Namekian","Albino Namekian","New Namek")
		genome.this_class = Class
		see_invisible=1
		partplant=1
		Metabolism = 2
		satiationMod = 1
		snamekat/=100
		snamekat*=rand(95,105)

/datum/genetics/proto/Namekian
	name = "Namekian" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Namekian") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1,//stats
		"Physical Defense" = 1.8,
		"Ki Offense" = 1,
		"Ki Defense" = 2,
		"Ki Skill" = 1,
		"Technique" = 1,
		"Speed" = 2,
		"Esoteric Skill" = 1.3,
		"Skillpoint Mod" = 1.4,
		"Ascension Mod" = 5,
		"Energy Level" = 1.5,//KiMod
		"Battle Power" = 1.4)//BPMod
	misc_stats = list(
		"Lifespan" = 7,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 3,//how much potential does this person have?
		"Regeneration" = 10, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 0, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 5, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 5, //How fast you train in meditation.
		"Spar Mod" = 1.5, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Ki Regeneration" = 1.8,//self explanitory, just really a mod.
		"Anger" = 1.2, //anger stat, this * 100 = final anger.
		"Zenkai" = 0.5, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 30,//starting BP
		"Tech Modifier" = 2)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("New Namek" = 25, "Namekian" = 50,"Albino Namekian" = 25)
	class_stats = list(
		"Albino Namekian" = list(
			"Physical Offense" = 1.2,//stats
			"Physical Defense" = 1.6,
			"Ki Offense" = 1.3,
			"Ki Defense" = 1.6,
			"Ki Skill" = 1,
			"Speed" = 1.8,
			"Esoteric Skill" = 1,
			"Energy Level" = 1.4,//KiMod
			"Battle Power" = 1.2,//BPMod
			"Lifespan" = 6,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
			"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
			"Starting BP" = 40,//starting BP
			"Med Mod" = 3,
			"Spar Mod" = 2,
			"Gravity Mod" = 0.8,
			"Anger" = 1.1,
			"Regeneration" = 15,
			"Tech Modifier" = 4//how naturally good you are at technology
		)
	)