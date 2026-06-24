mob/proc/statfrost()
	RaceDescription="Frost Demons, or Icers, are a race of lizard-folk who hail from a colder planet. Despite the name, they aren't all actually evil. Rather, in folklore a certain group of Icers made their race be called Frost Demons by fearful aliens. There is generally three types of Frost Demons. Frieza-Types are fast, and hit strong. They're characterized by poor defenses. King Cold types are the opposite. Cooler types are a balanced inbetween."
	if(!genome)
		if(Class=="None")
			Class=alert(src,"Choose an option. Frieza is the offensive type. It excels just attack. Cooler is the strongest in raw power, but suffers in battle power. Cold types are in the middle of Frieza types and Cooler types, basically the most normal of the group.","","Frieza","Cold","Cooler")
		genome = new/datum/genetics/Icer(/datum/genetics/proto/Icer)
		genome.this_class = Class

/datum/genetics/proto/Icer
	name = "Frost Demon" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Frost Demon") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	special_info(var/datum/genetics/invoker,var/prev)
		..()
		if(invoker.savant)
			if(prev > 50 || invoker.majority_genome == "Frost Demon" || invoker.this_class == "Frieza" || invoker.this_class == "Cooler" || invoker.this_class == "King Cold")
				invoker.savant.AscensionAllowed=1//Icers start ascended.
	m_stats = list(
		"Physical Offense" = 1.5,//stats
		"Physical Defense" = 1.1,
		"Ki Offense" = 2,
		"Ki Defense" = 1.1,
		"Ki Skill" = 1.5,
		"Technique" = 1,
		"Speed" = 1.3,
		"Esoteric Skill" = 0.2,
		"Skillpoint Mod" = 1.1,
		"Ascension Mod" = 7,
		"Energy Level" = 2,//KiMod
		"Battle Power" = 1.5)//BPMod
	misc_stats = list(
		"Lifespan" = 10,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 2,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 0, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 5, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 10, //How fast you adjust and train in gravity.
		"Med Mod" = 1.5, //How fast you train in meditation.
		"Spar Mod" = 1.5, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Ki Regeneration" = 1,//self explanitory, just really a mod.
		"Anger" = 1.1, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 1000,//starting BP
		"Tech Modifier" = 3)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("Frieza" = 25,"Cold" = 50,"Cooler" = 25)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	class_stats = list(
		"Cold" = list(
			"Physical Offense" = 1.1,
			"Physical Defense" = 1.5,
			"Technique" = 1.2,
			"Ki Offense" = 1.1,
			"Ki Defense" = 2,
			"Speed" = 1.1,
			"Train Mod" = 1.2,
			"Starting BP" = 110,
			"Battle Power" = 1.45
		),
		"Cooler" = list(
			"Physical Offense" = 1.5,
			"Physical Defense" = 1.5,
			"Technique" = 1.4,
			"Ki Offense" = 1.5,
			"Ki Defense" = 2,
			"Speed" = 1.4,
			"Skillpoint Mod" = 1.1,
			"Battle Power" = 1.4,
			"Energy Level" = 1.5,
			"Tech Modifier" = 2,
			"Ki Regeneration" = 1,
			"Starting BP" = 800,
			"Potential" = 2.5
		)
	)
