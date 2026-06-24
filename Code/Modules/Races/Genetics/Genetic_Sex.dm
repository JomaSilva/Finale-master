//i dont care if sex as a concept is too much for BYOND, this is gonna be focused on the actual good parts of sex (i.e. the genetic magic that everyone glosses over in school)


//procedure 1: we input two "racial" archetypes from the donor parents.
mob/var/datum/genetics/womb = null //temporary carrying of "child" genome
mob/var/datum/genetics/genome = null //this is the important variable that carries your unique genome.

proc
	return_new_genome(var/firstparent,var/secondparent) //the var/ bit is to signify that these are, indeed, being defined temporarily.
		//we don't expect this command to be ran frequently, so we're gonna redefine them in proc anyway
		var/fpar = firstparent
		var/spar = secondparent
		//this has no purpose, fuck you, I'm running a campaign to save my fingers, fuck you.
		var/datum/genetics/GENOME = new()
		GENOME.copy_races(fpar,spar)//copying the races from the first/second parent (it accepts multiple races)
		GENOME.build() //now we build the genome's unique stats and name.
		return GENOME

mob/proc/race_genome_post_init()
	genome.savant = src
	genome.post_init_savant()
	return

datum/genetics/proc/copy_races()//Remember, this happens TWICE per bred genome. Once upon breeding, and another "safe" copy upon every person who checks out the character.
	var/list/masterlist = list()
	var/list/prevalentlist = list(1,null)
	for(var/datum/genetics/parent in args)
		if(!istype(parent,/datum/genetics)) return FALSE //fuck you you didn't pass the right shit to this one.
		//we do this in a seperate for() statement for the following command, which lets us calculate prototype ratios
		//i.e. saiyan hybrid breeds with a Icer. What then? Well, 25% Saiyan, 25% Human, 50% Icer. We're calculating those now.
		//calculation as follows: we stick both racial prototype into new lists. for each one, their associatives are divided by two.
		//if any equals are found in the other list, the associative is added with the other one. The two lists are then merged into the final genome.
		if(prevalentlist[2]==null || prevalentlist[1] <= parent.prevalance)
			var/dcontinue = 1
			if(parent.prevalance == prevalentlist[1])
				dcontinue = 0
				if(parent.gender == "Male") dcontinue = 1 //Choosing a male is important, because males override equal prevalance.
			if(dcontinue)
				prevalentlist[2] = parent
				prevalentlist[1] = parent.prevalance
		for(var/name in parent.racial_protos)
			var/datum/genetics/protos = fetch_race_by_Name("[name]")
			if(protos in masterlist) //remember: prototype genomes are from a global master list, everyone references them. This means in this manip list, are those protos.
				masterlist[protos] += parent.racial_protos[name]/2
			else
				masterlist += protos
				masterlist[protos] = parent.racial_protos[name]/2
		//we also take the appearances of every parent
		special_icon_list += parent.special_icon_list
		alternate_icon_flags += parent.alternate_icon_flags
	var/datum/genetics/chad_parent = prevalentlist[2]
	Class_Spread = chad_parent.Class_Spread
	class_stats = chad_parent.class_stats
	base_icon = chad_parent.base_icon //base is the same as the CHAD parent.
	if(chad_parent.this_class) Class_Spread[chad_parent.this_class]++ //increase the weight of the parent's class to make it picked more frequently. This means breeding works across generations too lol.
	if(chad_parent.dominateClass)//this is important in the Ayyliens case: if a class should be ALWAYS picked, then make it always picked in bloodline.
		Class_Spread = list(chad_parent.dominateClass = 1)
		dominateClass = chad_parent.dominateClass
	for(var/datum/genetics/I in masterlist)
		I = "[I.name]"
	racial_protos = masterlist
	return TRUE

datum/genetics/proc/build()
	original_genome = 0
	decide_Race() //we got the name down
	build_stats() //time to take the original stats of the racial protos into us
	//build_misc() //and now we have to build appearance, etc.
	return TRUE

//so, process:
//saiyan a fucks human b. human b is female, this genome is placed inside her temporary "womb" variable.
//when the goy is borne, the goy immediately takes the genome var into himself and the genome initializes.
//in character creation, there are the base races, and then the mother is placed upon the character creation menu under "Breeds"
/datum/genetics/var/mob/holder = null //the mob currently carrying this (womb) genome
