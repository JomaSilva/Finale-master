proc/Init_Genome()
	if(!original_genome_list) original_genome_list = list() //Load_Settings can read it back as NULL when the savefile lacks the key; `null += helix` below would NOT build a list, leaving every proto unregistered (broke all racial/class stats)
	var/list/working_List = typesof(/datum/genetics/proto) - /datum/genetics/proto //take all the original racial prototypes. WAS list(typesof(...) - proto): wrapping a list in list() NESTS it, so working_List held ONE element (the inner list) -> `new nT` ran on a /list ("new() called with /list", ~138 throws) and NO prototypes registered at boot. typesof() already returns a list.
	for(var/datum/genetics/I in original_genome_list) //remove existing ones
		if(I.type in working_List)
			working_List.Remove(I.type)
	for(var/nT in working_List) //create the "new" prototypes in the master list for others to leech from. its saved so that wipes aren't fucked from new race stat changes.
		var/datum/genetics/helix = new nT
		helix.original_genome = 1
		working_List -= nT
		original_genome_list += helix
	return TRUE

proc/fetch_race_by_Name(name)
	for(var/datum/genetics/I in original_genome_list)
		if(I.name == name)
			return I

//do not use (yet)
/*
proc/delete_Custom_Proto(ckey,num) //used in characterselect.dm to delete custom prototypes associated with the character.
//prototypes have no way of knowing of how they're being used, so in characterselect.dm it's commented out: consider use case
//use case: alien A w/ custom genome screws another player, makes baby
//alien A now wants to delete, this proc activates
//babby, the unborn fuck, now no longer has a parent prototype to draw stats from. broken
	for(var/datum/genetics/I in original_genome_list)
		if(ckey in I.name && I.use_num == num)
			del I
			return*/
