//quarter saiyan is in this file.
//legend is in this file.
//halfie is in this file.
mob/proc/statsaiyan()
	NoAscension = 1
	RaceDescription="Saiyans are from the Planet Vegeta, they are a warrior People who have evolved over generations to match the harsh conditions of their Planet and its violent conditions. Due to that they have greatly increased strength and endurance. Due to being a warrior race they pride themselves in how powerful they are, and that helped them to be able to push their battle power higher in large jumps when they go through hard training or tough situations, that is probably their most famous feature and what they are known for most. In fact one of the main reasons they have large power increases at once is because of their high 'Zenkai' rate, which means that the more damaged and close to death they become, the greater their power increases because of it. Also there is Super Saiyan, which is a monstrously strong form by just about anyone's standards, and it helps them to increase their base power even further too, putting them far beyond 'normal' beings. Saiyans come in three classes: Low-Class, named because they are born the weakest, and dont  battle power quite as fast (at first) as the other Saiyan classes. Normal Class, these are middle of the road style Saiyans, they have the highest endurance as well on average, they  battle power in between Low-Class and Elite levels and have higher Zenkai than Low Class Saiyans. Elite, these are born the strongest of all Saiyans, and  power much much much faster in base than the other Saiyan classes. They are the purest of the Saiyan bloodlines and have the highest Zenkai rate by far, (greater than any other race in fact) meaning they get the most from high stress situations, their weakness compared to the other Saiyans is that (for the battle power) they cannot take nearly as much damage, but they can dish out a lot more."
	if(Class == "Legendary")
		RaceDescription="Legendary Saiyans are a mutated variety of the latter, and are known for their tendencies to have uncontrollable anger, and they transform MUCH earlier than the normal Saiyans. The downfall to this is that all Legendary Saiyans, at some point in time, will either go insane from the transformation, or sometime before that. Regardless of that problem, they are -always- out of control and insane during the transformation, though it can be controlled during the Restrained transformation."
	GravMastered=10 //Saiyans are native to Vegeta (10x gravity); start acclimated so they aren't crushed/frozen on their own homeworld.
	if(!genome)
		genome = new/datum/genetics/Saiyan(/datum/genetics/proto/Saiyan)
		if(Class != "None")
			genome.this_class = Class //explicit class (bred/egg/admin) wins
		else
			//random Saiyan birth class: ~1% Legendary, ~4% Elite, ~45% Low-Class, ~50% Normal
			var/roll = rand(1,1000)
			if(roll <= 10) Class = "Legendary"
			else if(roll <= 50) Class = "Elite"
			else if(roll <= 500) Class = "Low-Class"
			else Class = "Normal"
			genome.this_class = Class

/datum/genetics/proto/Saiyan
	name = "Saiyan" //Name of race.
	base_icon = 'White Male.dmi' //doesn't really do anything right now, as icons are controlled by other things.
	alternate_icon_flags = list("Human") //These actually do control what racial bodytypes you see. Flags are combined from all parent races.
	special_icon_list = list() //icon 'list' flags. Human gives you human-like bodies, Alien alien. 
	extra_limb_list = list(/datum/Body/Tail/Saiyan_Tail) //Saiyans are born with a tail: this body-part datum's login() sets mob.Tail=1 and adds the tail overlay
	prevalance = 2 //remember that this is multiplying the ratio of a genome.
	special_info(var/datum/genetics/invoker,var/prev)
		..()
		if(invoker.savant && invoker.beenSSJed < prev)
			invoker.beenSSJed = prev
			invoker.savant.Omult=6
			//cada personagem tem um BP minimo um pouco diferente para liberar cada forma (margem aleatoria, varia de pessoa para pessoa).
			//SSJ1/SSJ2 (e Restrained, no Legendary) sao randomizados por classe no switch abaixo; aqui randomizamos as demais formas.
			invoker.savant.ssj3at = initial(invoker.savant.ssj3at) * rand(9,13)/10
			invoker.savant.ultrassjat = initial(invoker.savant.ultrassjat) * rand(9,13)/10
			invoker.savant.rawssj4at = initial(invoker.savant.rawssj4at) * rand(9,13)/10
			invoker.savant.unrestssjat = initial(invoker.savant.unrestssjat) * rand(9,13)/10
			invoker.savant.lssjat = initial(invoker.savant.lssjat) * rand(9,13)/10
			switch(invoker.this_class)
				if("Elite")
					invoker.savant.ssjat= initial(invoker.savant.ssjat) * rand(11,14)/10
					invoker.savant.ssjmod= initial(invoker.savant.ssjmod) *0.5
					invoker.savant.ssj2at= initial(invoker.savant.ssj2at) *rand(9,12)/10
				if("Low-Class")
					invoker.savant.ssjat= initial(invoker.savant.ssjat) *rand(9,12)/10
					invoker.savant.ssj2at= initial(invoker.savant.ssj2at) *rand(11,14)/10
				if("Legendary")
					invoker.savant.restssjat= initial(invoker.savant.restssjat) *(rand(9,12)/10)
					invoker.savant.ssjdrain=0.025
					invoker.savant.ssjmod= initial(invoker.savant.ssjmod) *1
					invoker.savant.legendary=1
					invoker.savant.Omult=8
				else
					invoker.savant.ssjat= initial(invoker.savant.ssjat) *rand(10,12)/10
					invoker.savant.ssj2at= initial(invoker.savant.ssj2at) *rand(9,12)/10
					
			if(prev <= 30)
				invoker.savant.ssjmult = 1.35
				invoker.savant.ultrassjmult = 1.45
				invoker.savant.ssj2mult = 1.75
				invoker.savant.ssj3mult = 2
				invoker.savant.ssj4mult = 3 
				invoker.savant.Omult=1.5
			else
				invoker.savant.NoAscension = 1
				invoker.savant.Metabolism = 2
				invoker.savant.satiationMod = 0.5


	
	m_stats = list(
		"Physical Offense" = 1.4,//stats
		"Physical Defense" = 1,
		"Ki Offense" = 2,
		"Ki Defense" = 1.3,
		"Ki Skill" = 1.8,
		"Technique" = 1,
		"Speed" = 1.9,
		"Esoteric Skill" = 0.2,
		"Skillpoint Mod" = 1.2,
		"Ascension Mod" = 6,
		"Energy Level" = 1.4,//KiMod
		"Battle Power" = 1.6)//BPMod
	misc_stats = list(
		"Lifespan" = 2,//to decide if the resultant person has immortality, it has to be 20 or more. otherwise it dictates lifespan.
		"Potential" = 3,//how much potential does this person have?
		"Regeneration" = 1, //how much regeneration does this person have? regeneration stats are a stepdown. active regen gets the full effect, passive is 1/10th. if its past a low threshold, lopped limbs are considered. past a somewhat higher threshold, and death regen becomes a thing.
		"Breed Type" = 1, //1 for manual, 0 for eggu. 2 for both, 3 for sterile
		"Zanzoken Mod" = 1, //Zanzoken modifier- how fast u zanzo
		"Gravity Mod" = 2, //How fast you adjust and train in gravity.
		"Med Mod" = 1, //How fast you train in meditation.
		"Spar Mod" = 3, //How fast you spar.
		"Train Mod" = 1, //How fast you train.
		"Ki Regeneration" = 1,//self explanitory, just really a mod.
		"Anger" = 1.5, //anger stat, this * 100 = final anger.
		"Zenkai" = 20, //zenkai, the hax stat.
		"Space Breath" = 0,//misc stat misc stat, either 0 or 1. limited to only 0 or 1. only does things at 0 and 1. 0 means they die in space.
		"Starting BP" = 100,//starting BP
		"Tech Modifier" = 1)//how naturally good you are at technology
		//gravity mastered is a product of your home planet's gravity. nothing more, nothing less.
	Class_Spread = list("Legendary" = 1,"Elite" = 4,"Low-Class" = 45,"Normal" = 50) //Legendary rolled FIRST (true ~1%); Normal is LAST so it absorbs decide_Class's force-last fallback (bred Saiyans)
	//format is list("class_name" = weight) //CLASS NAME HERE MUST BE THE SAME AS CLASS NAME BELOW (wont work otherwise.)
	class_stats = list(
		"Low-Class" = list(
			"Physical Offense" = 1.2,
			"Physical Defense" = 0.8,
			"Technique" = 1.1,
			"Ki Offense" = 2,
			"Ki Defense" = 1.2,
			"Speed" = 2,
			"Skillpoint Mod" = 1.4,
			"Battle Power" = 1.4,
			"Energy Level" = 1.2,
			"Zanzoken Mod" = 1.5,
			"Gravity Mod" = 8,
			"Ki Regeneration" = 1.5,
			"Zenkai" = 25,
			"Train Mod" = 1.5,
			"Starting BP" = 10
		),
		"Elite" = list(
			"Physical Offense" = 1.3,
			"Physical Defense" = 1,
			"Technique" = 1.2,
			"Ki Offense" = 2,
			"Ki Defense" = 1.5,
			"Speed" = 1.8,
			"Skillpoint Mod" = 1.1,
			"Battle Power" = 1.8,
			"Energy Level" = 1.4,
			"Tech Modifier" = 2,
			"Ki Regeneration" = 1.1,
			"Starting BP" = 1000,
			"Potential" = 2.5
		),
		"Legendary" = list(
			"Physical Offense" = 1.5,
			"Physical Defense" = 2.2,
			"Technique" = 0.5,
			"Ki Offense" = 1.5,
			"Ki Defense" = 2.2,
			"Ki Skill" = 0.5,
			"Speed" = 1,
			"Skillpoint Mod" = 1,
			"Battle Power" = 3,
			"Energy Level" = 1.2,
			"Tech Modifier" = 1,
			"Ki Regeneration" = 1,
			"Starting BP" = 10000,
			"Potential" = 2,
			"Zenkai" = 15,
			"Spar Mod" = 4,
			"Anger" = 2
		)
	)


mob/var/hasTailGimmicks=0 //Saiyan-type only variable. Use a different one or add checks to oozaru stuff if tails become a bigger racial feature.
mob/proc/Tail_Grow()
	Grow_Tail()
datum/Body/Tail
	Saiyan_Tail
		New()
			..()
			if(savant)
				if(lopped)
					savant.tailgain = 1.25
				else
					savant.tailgain = 0.5
		login()
			..()
			if(lopped)
				savant.tailgain = 1.25
			else
				savant.tailgain = 0.5
		LopLimb(var/nestedlop)
			if(..(nestedlop) == TRUE)
				savant.tailgain = 1.25
				return TRUE
			else
				return FALSE
		RegrowLimb()
			..()
			savant.tailgain = 0.5
mob/proc/statlegend() //Legendary Saiyan is a Saiyan with the Legendary class.
	if(Class == "None") Class = "Legendary"
	statsaiyan()
