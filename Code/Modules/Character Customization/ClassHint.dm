//At character creation, give the player an INDIRECT but understandable hint at their class/power tier.
//Since a character can't read their own BP without a scouter, this is how a player gets a sense of which
//class they were born into (e.g. a Legendary Saiyan vs a Low-Class one) without seeing the starting number.
//Called once from NewCharacterStuff() after the class is finalized.
mob/proc/class_hint()
	if(!client) return
	var/c = Class
	if(genome && genome.this_class) c = genome.this_class
	var/msg = null
	switch(c)
		//--- Saiyan ---
		if("Legendary", "Legendary Primal Saiyan")
			msg = "A colossal, barely contained power slumbers in your blood. Even your own kind would tremble before what you might become."
		if("Elite")
			msg = "Elite blood runs in your veins. You were born far above the common warriors of your people."
		if("Normal Primal Saiyan")
			msg = "You are a true child of the old ways, an ordinary warrior of your kind, with the wild power of the moon still asleep within you."
		if("Low-Class")
			if(Race == "Heran" || Parent_Race == "Heran")
				msg = "You were born among the lowest of your people, yet something in you grows faster than the rest."
			else
				msg = "You were born a low-class warrior with humble power, but every brush with death only leaves you stronger."
		if("Normal")
			if(Race == "Saiyan" || Parent_Race == "Saiyan")
				msg = "You are a middling warrior of your people, neither weak nor remarkable, with everything still to prove."
			else
				msg = "You are an ordinary person of your kind. You start with little, but your will knows no ceiling."
		//--- Human ---
		if("Ancient Hermit")
			msg = "Your body is frail, but your mind and your mastery over ki are those of a true ancient sage."
		if("Peak Human")
			msg = "You stand at the very peak of human potential. Your honed body is your greatest weapon."
		if("Triclops Descendant")
			msg = "The blood of a swift, technical lineage flows in you, heir to the three-eyed warriors."
		//--- Half-Saiyan lineages ---
		if("New Generation")
			msg = "You are of the new mixed generation, balanced, carrying the best of two worlds."
		if("Future Lineage")
			msg = "You carry the lineage of a grim future: raw physical might bound to a single, focused form."
		if("Awakened Evolution")
			msg = "An immense hidden potential sleeps within you, waiting for the moment it is unlocked."
		//--- Majin ---
		if("Majin")
			msg = "Your elastic flesh mends whatever is torn from it. You are endurance made manifest."
		if("Corrupted Majin")
			msg = "Something unstable and malevolent festers in you, an offensive power well beyond a common Majin."
		//--- Frost Demon ---
		if("Frost Demon")
			msg = "You belong to the cold royalty of the Frost Demons: noble, poised, and balanced."
		if("Mutant Frost Demon")
			msg = "A rare mutation has made a monster of you. Your raw power dwarfs that of your kind."
		//--- Namekian ---
		if("Warrior clan")
			msg = "You are of the warrior clan. You traded healing for raw, brutal combat strength."
		if("Demon clan")
			msg = "Dark blood of the demon clan flows in you, an aggressive caster of the old king's line."
		if("Dragon clan")
			msg = "You are of the dragon clan: frail in a fight, but blessed with unmatched regeneration and potential."
		//--- Bio-Android ---
		if("Majin-Type")
			msg = "Your bio-design favors regeneration and brute force over endless evolution."
		//--- Demigod ---
		if("Demigod")
			msg = "Divine blood runs in you, balanced, yet with some of the highest potential for power."
		if("Ogre")
			msg = "You are a wall of muscle, overwhelming physical force given form."
		if("Genie")
			msg = "You are a defensive guardian, hard to wound, but no great striker."
		//--- Gray ---
		if("Gray")
			msg = "Your strength flows from meditation and swelling muscle, a warrior of silence."
		if("Hermano")
			msg = "Your intellect feeds your power. The wiser you grow, the stronger you become."
		//--- Heran ---
		if("Epsilon")
			msg = "You are a standard Heran, balanced, without extremes."
		if("Omega")
			msg = "A rare stroke of fortune made you an elite among the Herans, with exceptional gifts."
	if(!msg)
		//single-class / "None" races (and the Cell-type Bio-Android default)
		if(Race == "Bio-Android" || Parent_Race == "Bio-Android")
			msg = "You are a perfect lifeform in the making. You absorb, regenerate, and evolve without limit."
		else
			msg = "You search within and take the measure of your own power, the nature you were born with."
	to_chat(src, "<font color=#cda434><i>[msg]</i></font>")
