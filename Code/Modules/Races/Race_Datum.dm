obj/race
	icon = 'White Male.dmi'
	IsntAItem=1
	var
		racename = ""
		raceclass = "None"
	//now for the types
	New()
		..()
		var/mob/nM = new()
		nM.Class = raceclass
		nM.genome = new/datum/genetics()
		nM.StatRace(racename)
		desc = nM.RaceDescription
	Click()
		usr.update_race_desc(racename,desc)
	Saiyan
		overlays = list('Tail.dmi')
		name = "Saiyan"
		racename = "Saiyan"

	Half_Saiyan
		overlays = list('Tail.dmi')
		name = "Half-Saiyan"
		racename = "Half-Saiyan"

	Legendary_Saiyan
		overlays = list('Tail.dmi')
		name = "Legendary-Saiyan"
		racename = "Legendary Saiyan"
	Tsujin
		name = "Tuffle"
		racename = "Tsujin"
	Arlian
		icon = 'Arlian.dmi'
		name = "Arlian"
		racename = "Arlian"
	Majin
		icon = 'Majin1.dmi'
		name = "Majin"
		racename = "Majin"

	Bio_Android
		icon = 'Bio Android 1.dmi'
		name = "Bio-Android"
		racename = "Bio-Android"
	Meta
		icon = 'MetaM.dmi'
		name = "Meta"
		racename = "Meta"
	Kanassa_Jin
		icon = 'Kanassan.dmi'
		name = "Kanassa-Jin"
		racename = "Kanassa-Jin"

	Demigod
		name = "Demigod"
		racename = "Demigod"
		raceclass = "Demigod"
	Makyo
		icon = 'Makyojin.dmi'
		name = "Makyo"
		racename = "Makyo"
	Kai
		icon = 'Kaio.dmi'
		name = "Kai"
		racename = "Kai"
	Saibaman
		icon = 'Saibaman - Form 1.dmi'
		name = "Saibamen"
		racename = "Saibamen"
	Yardrat
		icon = 'Yardrat.dmi'
		name = "Yardrat"
		racename = "Yardrat"
	Android
		icon = 'GochekAndroid.dmi'
		name = "Android"
		racename = "Android"
	Quarter_Saiyan
		overlays = list('Tail.dmi')
		name = "Quarter-Saiyan"
		racename = "Quarter-Saiyan"
	Human
		name = "Human"
		racename = "Human"
	Shapeshifter
		icon = 'cat.dmi'
		name = "Shapeshifter"
		racename = "Shapeshifter"
	Spirit_Doll
		icon = 'Spirit Doll.dmi'
		name = "Spirit Doll"
		racename = "Spirit Doll"
	Namekian
		icon = 'Namek Young.dmi'
		name = "Namekian"
		racename = "Namekian"
		raceclass = "Namekian"
	Heran
		icon = 'spacepirate.dmi'
		name = "Heran"
		racename = "Heran"
	Frost_Demon
		icon='Changling - Form 1.dmi'
		name = "Frost Demon"
		racename = "Frost Demon"
	Alien
		icon = 'Konatsu.dmi'
		name = "Alien"
		racename = "Alien"
	Half_Breed
		name = "Half-Breed"
		racename = "Half-Breed"
	Demon
		name = "Demon"
		racename = "Demon"
	Gray
		icon = 'Jiren.dmi'
		name = "Gray"
		racename = "Gray"