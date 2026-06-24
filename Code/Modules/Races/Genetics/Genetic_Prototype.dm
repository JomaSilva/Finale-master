
//These general variables are shared by all genomes, but will only be modifiable by the original genomes.
/datum/genetics/var
	prevalance = 1 //How dominate this race's features are. A higher prevalance means values will stray more towards these values.
	//Class is randomly chosen depending on above. A Arlian-type Alien which somehow mates or something with a Saiyan will find their offspring with a random class for a Saiyan.
	//It will take the class of its most prevalant parent.
	//Demons, also, have higher prevalance, but prevalance can somewhat 'cancel' each other out so a Saiyan-Demon hybrid would have notable features of both.
	//This will, however, result in the child only having ONE as a father race. (for current implementation)
	dominateClass = null //if you want a particular class to ALWAYS be chosen as a bloodline- used in Aliens and Uchihas.
	
	beenSSJed = null//special var for transformation type special cases- prevents a race from overriding another unless it has higher prevalence.
	//Used in Saiyan, Heran, and probably more?
	list/Class_Spread = list("None" = 100)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	list/class_stats = list("None" = list())
	//format is "statname" = statvalue
		//or class_stats = list("classname" = list("statname" = statvalue,"statname2" = statevalue2))
		//could do
		/*
		class_stats = list("classname" = list(
			"statname" = statvalue,
			"statname" = statvalue //and so on, recognizing that the comma and tab/spacing seperates racial stats.
		),
		list("classname2" = list(
			"statname" = statvalue...
		)
		)//ending brackets for momma list
		//important note: YOU ARE REPLACING FROM THE MASTER STATPOOL.//
		note: if a class needs a specific body icon you can also do
		class_stats = list("classname" = list(
			"Icon_Type" = "Demigod"... and so on. It doesn't have to be a string, can be just a list either since all this does is ensure that its added to the icon list.
		))
		do remember that comparisons with the icon_type variable can be slow, keep it to strings if you can.
		
		//important note: YOU ARE REPLACING FROM THE MASTER STATPOOL.//
		this means: if the class stat line goes "Physical Offense" = 1.5, the base is 2, then the result will be 3. (1.5 (mult) x 2 (base) = 3.)
	*/

	FLAG_SHAPESHIFTER = FALSE //Whether or not this genetic datum is a shapeshifting type. Perhaps unused.
	FLAG_SHAPESHIFTER_TYPE = FALSE
	list/shapeshift_m = list() //Backup lists of stats
	list/shapeshift_misc = list()
	/*

	Useful Stuff:
		genome.add_to_stat("Potential",0)
		savant.genome.add_to_stat("Energy",0.1)
		savant.genome.add_to_stat("Battle Power",0.1)
		genome.add_to_stat("Physical Offense",5)
		

	*/

/datum/genetics/proto
	var
		description
		home_planet

	proc/special_info(var/datum/genetics/invoker,var/prev)
	//special call that's used when a build_stat() event happens, invoker is the home genome, prev is the prevalance of the prototype (out of 100) in the invoker.
	//most things won't use this- SSJ uses this to nerf stats.
		return TRUE


/*Example prototype race.

/datum/genetics/proto/Dog
	name = "Dog" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
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
		"Skillpoint Mod" = 1,
		"Energy Level" = 1,//KiMod
		"Battle Power" = 1)//BPMod
	misc_stats = list(
		"Lifespan" = 1,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 1,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Ki Regeneration" = 1,//self explanitory, just really a mod.
		"Anger" = 1, //anger stat, this * 100 = final anger.
		"Zenkai" = 1, //zenkai, the hax stat.
		"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 1, //How fast you adjust and train in gravity.
		"Med Mod" = 1, //How fast you train in meditation.
		"Spar Mod" = 1, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Space Breath" = 1,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 1,//starting BP seed. several types.
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	
	class_stats = list("Omega" = list(
			"Zenkai" = 0.5,
			"Anger" = 2 //and so on, recognizing that the comma and tab/spacing seperates racial stats.
		),
		"Weak" = list(
			"Physical Offense" = 0.8,// These do not multiply, in fact they actually SET stat.
			"Physical Defense" = 0.8,
			"Zenkai" = 3
		),
		"None" = list(null)) //and keep a "None" or default Class class if you don't want any of the three classes applied.
	)//ending brackets for momma list
	list/Class_Spread = list("None" = 95, "Omega" = 10,"Weak" = 25)//Normal list rules
	//we then define the class spread. This is how rare a given class should be. Higher is less rare. It's a PERCENT. (x/100 deal)
	//Doesn't need to actually add up, as seen.

*/