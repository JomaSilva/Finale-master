mob
	New()
		..()
		mob_list += src
		spawn TryStats()
		spawn TestMobParts()
	Del()
		mob_list -= src
		..()