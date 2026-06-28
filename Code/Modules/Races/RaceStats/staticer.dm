mob/proc/statfrost()
	RaceDescription="Frost Demons are a race of lizard-folk who hail from a colder planet. Despite the name, they aren't all actually evil. Rather, in folklore a certain group of Frost Demons made their race be feared by aliens across the cosmos. Most Frost Demons are balanced-strong warriors with naturally high ki power and ascended potential. Every so often, however, a Mutant Frost Demon is born: a rare and monstrously powerful variant whose raw battle power dwarfs that of its kin, the kind of being whole empires are built around."
	if(!genome)
		if(Class=="None") //class is RANDOM at birth (like the Saiyan class), not chosen — Mutant is the rare ~1% variant
			if(rand(1,100) <= 1) Class = "Mutant Frost Demon"
			else Class = "Frost Demon"
			to_chat(src, "<font color=#cda434><b>You were born a [Class].</b></font>")
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
			if(prev > 50 || invoker.majority_genome == "Frost Demon" || invoker.this_class == "Frost Demon" || invoker.this_class == "Mutant Frost Demon")
				invoker.savant.AscensionAllowed=1//Icers start ascended.
			if(invoker.this_class == "Mutant Frost Demon") //Mutant: forma final (Golden) reforcada -> equivalente lendario dos Frost Demons (4x -> 7x)
				invoker.savant.f5mult = 7
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
	Class_Spread = list("Mutant Frost Demon" = 1,"Frost Demon" = 99) //Mutant rolled FIRST (true ~1%, rare powerful variant); Frost Demon is LAST so it absorbs decide_Class's force-last fallback (bred/standard)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	class_stats = list(
		"Frost Demon" = list(
			"Physical Offense" = 1.4,
			"Physical Defense" = 1.4,
			"Technique" = 1.3,
			"Ki Offense" = 1.5,
			"Ki Defense" = 1.5,
			"Speed" = 1.4,
			"Skillpoint Mod" = 1.1,
			"Battle Power" = 1.45,
			"Energy Level" = 1.4,
			"Tech Modifier" = 2,
			"Ki Regeneration" = 1,
			"Starting BP" = 110,
			"Potential" = 2.2
		),
		"Mutant Frost Demon" = list(
			"Physical Offense" = 2.2,
			"Physical Defense" = 1.8,
			"Technique" = 1.4,
			"Ki Offense" = 2.4,
			"Ki Defense" = 1.8,
			"Ki Skill" = 1.8,
			"Speed" = 1.7,
			"Skillpoint Mod" = 1.1,
			"Battle Power" = 3,
			"Energy Level" = 2,
			"Tech Modifier" = 2,
			"Ki Regeneration" = 1.2,
			"Starting BP" = 1200,
			"Potential" = 2.8,
			"Anger" = 1.5
		)
	)
