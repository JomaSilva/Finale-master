mob/proc/statbio()
	if(!genome)
		genome = new/datum/genetics/BioAndroid(/datum/genetics/proto/BioAndroid)
		if(!Class) Class=alert(src,"You are a bio-android. By default, you are a Cell type bioandroid. This comes with: Zenkai, Regeneration, Absorb, and Forms 2/3/4 (4 is Super Saiyan + Perfect.) Do you want to change to a Majin type bioandroid? (less Zenkai, Higher Regen, Absorb, one lategame form (already 3), higher BP mod.)","","Majin-Type","None")
		genome.this_class = Class
	RaceDescription={"Bio Androids are a rather odd race, as they are a combination of several races.
They can have the ability to regenerate, so long as they have a single cell remaining that wasn't obliterated.
These beings can also have the ability to absorb living people or dead, but do not take on their appearance.
Depending on their abilities, (specifically 3 combination race biodroids) they can take higher forms."}


/datum/genetics/proto/BioAndroid
	name = "Bio-Android" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human","Bio-Android") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 1 //remember that this is multiplying the ratio of a genome.
	m_stats = list(
		"Physical Offense" = 1.2,//stats
		"Physical Defense" = 0.8,
		"Ki Offense" = 1.2,
		"Ki Defense" = 0.7,
		"Ki Skill" = 1.5,
		"Technique" = 1,
		"Speed" = 2,
		"Esoteric Skill" = 0.5,
		"Skillpoint Mod" = 1.2,
		"Ascension Mod" = 3,
		"Energy Level" = 1.5,//KiMod
		"Battle Power" = 1.8)//BPMod
	misc_stats = list(
		"Lifespan" = 20,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1.5,//how much potential does this person have?
		"Regeneration" = 30, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 5, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 3, //How fast you adjust and train in gravity.
		"Med Mod" = 1.5, //How fast you train in meditation.
		"Spar Mod" = 1.8, //How fast you spar.
		"Train Mod" = 1.2, //How fast you train.
		"Ki Regeneration" = 1.5,//self explanitory, just really a mod.
		"Anger" = 1.25, //anger stat, this * 100 = final anger.
		"Zenkai" = 2, //zenkai, the hax stat.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 75,//starting BP
		"Tech Modifier" = 5)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	list/Class_Spread = list("None" = 80,"Majin" = 20)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	list/class_stats = list(
		"Majin-Type" = list(
			"Physical Offense" = 0.8,
			"Physical Defense" = 1.2,
			"Technique" = 1.1,
			"Ki Offense" = 1.3,
			"Ki Defense" = 0.7,
			"Ki Skill" = 1.1,
			"Speed" = 2.1,
			"Esoteric Skill" = 0.6,
			"Ascension Mod" = 4.2,
			"Skillpoint Mod" = 1.2,
			"Battle Power" = 2.5,
			"Energy Level" = 1.6,
			"Potential" = 1.5,
			"Regeneration" = 70,
			"Zenkai" = 1,
			"Spar Mod" = 1.5,
			"Med Mod" = 1.6,
			"Ki Regeneration" = 1.4
		)
	)