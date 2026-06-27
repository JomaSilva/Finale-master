mob/proc/statgray()
	var/Choice
	RaceDescription="Grays are a mysterious race that originated from another universe, but somehow a few have found their way here. Most Grays are very studious and reserved and have a deep motivation to obtain total power. The race is able to harness most of their power through deep meditation, and have the best meditation gains in the universe. Grays can also expand their muscles to access even more power. Grays are also incredibly sturdy and can take most attacks thrown at them. In return, however, they have poor reflexes and have a much harder time avoiding attacks. In terms of Battle Power, they are on the higher end of the spectrum in comparison to other races. There exists a special subclass of Grays known only as Hermano. Unlike their counterparts, Hermanos are very scientifically advanced and have incredibly large craniums. The smarter they get, the stronger Hermanos become. Although their IQ is mighty, Hermanos lack the same resilience and accuracy as other grays, but they have better Defense and punching power."
	if(Class=="None") //subclass is RANDOM (like the Saiyan class), not chosen; Hermano is the rare ~5% variant
		if(rand(1,100) <= 5)
			Choice = "Gray - Smarts Type (El Hermano Jokito)"
			src << "<font color=#cda434><b>You were born a Hermano.</b></font>"
		else
			Choice = "Gray - Jiren Type"
			src << "<font color=#cda434><b>You were born a Gray.</b></font>"
	switch(Choice)
		if("Gray - Jiren Type")
			RaceDescription="Grays are a mysterious race that originated from another universe, but somehow a few have found their way here. Most Grays are very studious and reserved and have a deep motivation to obtain total power. The race is able to harness most of their power through deep meditation, and have the best meditation gains in the universe. Grays can also expand their muscles to access even more power. Grays are also incredibly sturdy and can take most attacks thrown at them. In return, however, they have poor reflexes and have a much harder time avoiding attacks. In terms of Battle Power, they are on the higher end of the spectrum in comparison to other races. There exists a special subclass of Grays known only as Hermano. Unlike their counterparts, Hermanos are very scientifically advanced and have incredibly large craniums. The smarter they get, the stronger Hermanos become. Although their IQ is mighty, Hermanos lack the same resilience and accuracy as other grays, but they have better Defense and punching power."
			Class="Gray"
		if("Gray - Smarts Type (El Hermano Jokito)")
			RaceDescription="A mysterious counterpart species to the Grays, Hermanos are gifted with intellect. Unlike their counterparts, Hermanos are very scientifically advanced and have incredibly large craniums. The smarter they get, the stronger Hermanos become. Although their IQ is mighty, Hermanos lack the same resilience and accuracy as Grays, but they have better Defense and punching power."
			Class="Hermano"

	if(!genome)
		genome = new/datum/genetics/Gray(/datum/genetics/proto/Gray)
		genome.this_class = Class

/datum/genetics/proto/Gray
	name = "Gray" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Alien") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 2,//stats
		"Physical Defense" = 2,
		"Ki Offense" = 1.3,
		"Ki Defense" = 1.3,
		"Ki Skill" = 1.5,
		"Technique" = 1.5,
		"Speed" = 2,
		"Esoteric Skill" = 0.3,
		"Skillpoint Mod" = 0.5,
		"Ascension Mod" = 1.5,
		"Energy Level" = 1,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 1.5,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 2,//how much potential does this person have?
		"Regeneration" = 8, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 3, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1.5, //How fast you adjust and train in gravity.
		"Med Mod" = 3, //How fast you train in meditation.
		"Spar Mod" = 2, //How fast you spar.
		"Train Mod" = 1.1, //How fast you train.
		"Ki Regeneration" = 1.8,//self explanitory, just really a mod.
		"Anger" = 1.2, //anger stat, this * 100 = final anger.
		"Zenkai" = 4, //zenkai, the hax stat.
		"Space Breath" = 0,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 25,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("Hermano" = 5, "Gray" = 95)
	class_stats = list(
		"Hermano" = list(
			"Physical Offense" = 1.7,//stats
			"Physical Defense" = 1.7,
			"Ki Offense" = 1.7,
			"Ki Defense" = 1.7,
			"Speed" = 1.7,
			"Esoteric Skill" = 0.9,
			"Energy Level" = 1,//KiMod
			"Battle Power" = 1.2,//BPMod
			"Lifespan" = 2,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
			"Space Breath" = 0,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
			"Starting BP" = 25,//starting BP
			"Tech Modifier" = 1//how naturally good you are at technology
		)
	)