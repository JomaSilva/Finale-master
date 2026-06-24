mob/proc
	Race(choice)
		generatetrees(0)
/*		pickRace(choice)
mob/proc/pickRace(var/A) //for devs: later update will slam ALL racial statshit into their racial trees for better finding.
		switch(A)*/
		//world << "Parent Stuff"
		if(choice == "Pregnant")
			genome.savant = src
			genome.finalize_Race()
			choice = Parent_Race
			StatRace(choice,0)
		else
			src.Race = choice
			src.Parent_Race = choice
			StatRace(choice,1)
	eggpar(mob/M)
		src.Parent="[M.Parent]"
		src.Father_BP=M.Father_BP
		src.Father_Race=M.Father_Race
		src.Parent_Race=M.Father_Race
		src.Parent_Class=M.Father_Class
	parentpar(mob/M)
		src.Parent=M
		src.Parent_BP=M.BP
		src.Father_BP=M.Husband_BP
		if(src.Father_BP==null)
			src.Father_BP=1
		src.Parent_BPMod=M.BPMod
		src.Parent_Ki=M.KiMod
		src.Father_Race="[M.Husband_Race]"
		src.Father_Class="[M.Husband_Class]"
		src.Father="[M.Husband]"
		src.Parent_Race="[M.Race]"
		src.Parent_Class="[M.Class]"
mob/proc/StatRace(choice,genome_override) //choice of race, and then whether or not to overwrite a genome
	var/saveBP
	if(BP > 2) saveBP = BP
	if(genome_override)
		genome = null //genome is being overwritten, vanish it.
		genome_override = genome //just in case
	//Standards
	WaveIcon='Beam3.dmi'
	bursticon='All.dmi'
	burststate="2"
	var/chargo=rand(1,9)
	ChargeState="[chargo]"
	BLASTICON='1.dmi'
	BLASTSTATE="1"
	CBLASTICON='18.dmi'
	CBLASTSTATE="18"
	Makkankoicon='Makkankosappo4.dmi'
	zenni+=200
	//
	switch(choice)
		if("Arlian")
			statarlian()
		if("Majin")
			statmajin()
		if("Bio-Android")
			statbio()
		if("Meta")
			statmeta()
		if("Kanassa-Jin")
			statkanassa()
		if("Demigod")
			statdemi()
		if("Makyo")
			statmakyo()
		if("Kai")
			statkai()
		if("Saibamen")
			statsaiba()
		if("Yardrat")
			statyard()
		if("Android")
			statandroid()
		if("Quarter-Saiyan")
			statquarter()
		if("Human")
			stathuman()
		if("Shapeshifter")
			statshapeshift()
		if("Spirit Doll")
			statspirit()
		if("Tsujin")
			stattsujin()
		if("Namekian")
			statnamek()
		if("Heran")
			statheran()
		if("Legendary Saiyan")
			statlegend()
		if("Saiyan")
			statsaiyan()
		if("Half-Saiyan")
			stathalf()
		if("Frost Demon")
			statfrost()
		if("Alien")
			statalien()
		if("Half-Breed")
			stathalfbreed()
		if("Demon")
			statdemon()
		if("Gray")
			statgray()
		else
			for(var/datum/genetics/proto/gene in original_genome_list)
				if(gene.name == choice)
					genome = new/datum/genetics/Custom(gene)
					break
	BP = max(saveBP,BP)
	if(genome == null)
		genome = genome_override //a just in case.
	if(spawnPlanet)
		GravMastered = max(GravMastered, PlanetGravity(spawnPlanet)) //every race starts acclimated to its home/spawn planet's gravity so high-grav races aren't crushed/frozen at spawn

var/list
	bio_creator_list = list()
	spirit_creator_list = list()
	android_creator_list = list()
