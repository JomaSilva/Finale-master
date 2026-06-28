mob/proc/statheran()
	RaceDescription="A rare and dying race from the planet Hera who are capable of competing with Saiyans in both power and intellect. They are able to transform twice, and these weaker transformations are made up by a decent base bp."
	if(!genome)
		genome = new/datum/genetics/Heran(/datum/genetics/proto/Heran)
		var/list/options=list("Low-Class","Epsilon")
		if(canomega && rand(1,8) == 5) options.Add("Omega")
		var/Choice = Class
		if(Class=="None") //class is RANDOM (like the Saiyan class), not chosen; Omega only in the pool if the lucky roll above added it
			Choice = pick(options)
			to_chat(src, "<font color=#cda434><b>You were born a [Choice]-class Heran.</b></font>")
		genome.this_class = Choice //was = Class, which stays "None" for a new Heran -> they never got their chosen class (wrong stats + the class hint fell through). Use the selection.


/datum/genetics/proto/Heran
	name = "Heran" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	prevalance = 2 //remember that this is multiplying the ratio of a genome.
	special_info(var/datum/genetics/invoker,var/prev)
		..()
		if(invoker.savant && invoker.beenSSJed < prev)
			invoker.beenSSJed = prev
			invoker.savant.Omult=4
			switch(invoker.this_class)
				if("Omega")
					invoker.savant.ssjat=rand(5500000,8000000)
					invoker.savant.ssjmult=1.30
					invoker.savant.ssjmod=2
					invoker.savant.ssj2mult=2
				if("Low-Class")
					invoker.savant.ssjat=rand(800000,2000000)
					invoker.savant.ssjmult=3
					invoker.savant.ssjdrain=0.025
					invoker.savant.ssjmod=initial(invoker.savant.ssjmod) *0.9
					invoker.savant.ssj2mult=4
				else
					invoker.savant.ssjat=rand(2500000,5000000)
					invoker.savant.ssjmult=2.4
					invoker.savant.ssjmod=initial(invoker.savant.ssjmod) * 0.7
					invoker.savant.ssj2mult=3
					
			if(prev <= 30)
				invoker.savant.ssjmult = 1.35
				invoker.savant.ssj2mult = 1.75
	m_stats = list(
		"Physical Offense" = 1.3,//stats
		"Physical Defense" = 1.2,
		"Ki Offense" = 1.3,
		"Ki Defense" = 1.4,
		"Ki Skill" = 1.4,
		"Technique" = 1,
		"Speed" = 1.5,
		"Esoteric Skill" = 0.5,
		"Skillpoint Mod" = 1.3,
		"Ascension Mod" = 3,
		"Energy Level" = 1.3,//KiMod
		"Battle Power" = 2.5)//BPMod
	misc_stats = list(
		"Lifespan" = 2,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 2,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 4, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 6, //How fast you adjust and train in gravity.
		"Med Mod" = 1, //How fast you train in meditation.
		"Spar Mod" = 1.8, //How fast you spar.
		"Train Mod" = 1.8, //How fast you train.
		"Ki Regeneration" = 0.7,//self explanitory, just really a mod.
		"Anger" = 1.3, //anger stat, this * 100 = final anger.
		"Zenkai" = 6, //zenkai, the hax stat.
		"Space Breath" = 0,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 150,//starting BP
		"Tech Modifier" = 2.5)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("Normal" = 45,"Low-Class" = 45,"Elite" = 4,"Legendary" = 1)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	class_stats = list(
		"Low-Class" = list(
			"Physical Offense" = 1.3,
			"Physical Defense" = 1.4,
			"Technique" = 1.3, //secret low-class hijinks activate
			"Ki Offense" = 1.2,
			"Ki Defense" = 1.4,
			"Speed" = 1.2,
			"Skillpoint Mod" = 1.4,
			"Ascension Mod" = 2.5,
			"Battle Power" = 2,
			"Energy Level" = 1.3,
			"Zanzoken Mod" = 1,
			"Gravity Mod" = 3,
			"Ki Regeneration" = 0.9,
			"Zenkai" = 5,
			"Train Mod" = 2,
			"Med Mod" = 2,
			"Spar Mod" = 3,
			"Starting BP" = 60,
			"Tech Modifier" = 3,
			"Potential" = 3
		),
		"Omega" = list(
			"Physical Offense" = 1.3,
			"Physical Defense" = 1.2,
			"Technique" = 0.9,
			"Ki Offense" = 1.2,
			"Ki Defense" = 1.1,
			"Ki Skill" = 1,
			"Speed" = 1.3,
			"Skillpoint Mod" = 1.2,
			"Battle Power" = 2.75,
			"Energy Level" = 1.5,
			"Ascension Mod" = 2,
			"Ki Regeneration" = 0.6,
			"Starting BP" = 500,
			"Gravity Mod" = 9,
			"Potential" = 1,
			"Zenkai" = 9,
			"Train Mod" = 1,
			"Med Mod" = 1,
			"Spar Mod" = 2,
			"Zanzoken Mod" = 6
		)
	)