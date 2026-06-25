mob/proc/statnamek()
	RaceDescription="Namekians are a peaceful race. Low in stats, but decent everywhere else, they make for a race that's almost as easy to play as Humans. They have a transformation, and are divided into three clans. The Warrior clan are born fighters and the strongest combatants. The Demon clan carry King Piccolo's dark, aggressive lineage and are ferocious casters. The Dragon clan are the healers and creators, masters of regeneration who keep the race's gentle, supportive traditions alive."
	if(!genome)
		genome = new/datum/genetics/Namekian(/datum/genetics/proto/Namekian)
		if(Class=="None") Class=input(usr,"Choose your clan. Warrior clan are the strongest fighters. Demon clan are aggressive dark casters in King Piccolo's lineage. Dragon clan are the supportive healers and creators with unmatched regeneration.","Clan","") in list("Warrior clan","Demon clan","Dragon clan")
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
	Class_Spread = list("Warrior clan" = 25,"Demon clan" = 25,"Dragon clan" = 50) //Dragon clan LAST so it absorbs decide_Class's force-last fallback (the common, supportive clan)
	class_stats = list(
		"Warrior clan" = list(//Nail/Piccolo fighters: strongest combatant, trades away some regen for raw power
			"Physical Offense" = 1.8,//stats
			"Physical Defense" = 1.7,
			"Ki Offense" = 1.7,
			"Ki Defense" = 1.8,
			"Ki Skill" = 1.2,
			"Technique" = 1.2,
			"Speed" = 2.4,
			"Esoteric Skill" = 1,
			"Skillpoint Mod" = 1.3,
			"Energy Level" = 1.5,//KiMod
			"Battle Power" = 1.6,//BPMod
			"Lifespan" = 6,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
			"Potential" = 3,
			"Regeneration" = 7,//strong but the lowest-regen clan
			"Spar Mod" = 2.5,
			"Train Mod" = 1.3,
			"Gravity Mod" = 1.5,
			"Anger" = 1.3,
			"Starting BP" = 50,//starting BP
			"Tech Modifier" = 2//how naturally good you are at technology
		),
		"Demon clan" = list(//King Piccolo lineage: aggressive dark caster, high Ki Offense/Technique/Esoteric/Anger
			"Physical Offense" = 1.3,//stats
			"Physical Defense" = 1.6,
			"Ki Offense" = 2,
			"Ki Defense" = 1.8,
			"Ki Skill" = 1.6,
			"Technique" = 1.8,
			"Speed" = 2,
			"Esoteric Skill" = 1.7,
			"Skillpoint Mod" = 1.4,
			"Energy Level" = 1.6,//KiMod
			"Battle Power" = 1.4,//BPMod
			"Lifespan" = 7,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
			"Potential" = 3.5,
			"Regeneration" = 9,
			"Med Mod" = 4,
			"Ki Regeneration" = 2,
			"Anger" = 2,
			"Starting BP" = 35,//starting BP
			"Tech Modifier" = 3//how naturally good you are at technology
		),
		"Dragon clan" = list(//Dende/Guru healers & creators: the support clan, highest Regen/Potential/Esoteric/Lifespan, lowest offense (keeps Soul Absorb, see namekian.dm)
			"Physical Offense" = 0.8,//stats
			"Physical Defense" = 1.8,
			"Ki Offense" = 0.9,
			"Ki Defense" = 2.2,
			"Ki Skill" = 1.2,
			"Technique" = 1.2,
			"Speed" = 1.8,
			"Esoteric Skill" = 2,
			"Skillpoint Mod" = 1.6,
			"Energy Level" = 1.5,//KiMod
			"Battle Power" = 1.2,//BPMod
			"Lifespan" = 9,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
			"Potential" = 4.5,
			"Regeneration" = 18,//unmatched healing/regeneration
			"Med Mod" = 6,
			"Ki Regeneration" = 2.2,
			"Anger" = 1,
			"Starting BP" = 25,//starting BP
			"Tech Modifier" = 3//how naturally good you are at technology
		)
	)