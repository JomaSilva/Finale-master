//Essentially, ERP is icky and it should be used sparingly. The changes below are to stop assholes from turning the server into a universe full of impure cucks. I mean, emote is emote,
//but this should at least make it so that the Breed() command is turned into something more humorous than anything else, and the OOC effects can be ignored/disabled anyways.
var/BreedFunnies = 1
mob/Admin3/verb/Disable_Breed_Spoofs()
	set category="Admin"
	switch(input(usr,"Do you want to toggle breed spoofs? It's currently set to [BreedFunnies]. 1 = On, 0 = Off. Yes = 1, No = 0. Will also affect whether or not breed will be broadcasted to OOC") in list ("No","Yes"))
		if("Yes")
			BreedFunnies = 1
		if("No")
			BreedFunnies = 0
	world <<"Breed Funnies set to [BreedFunnies]"
//can be disabled anyways for rp fags who want to have ERP based hierachies in their server. I hope Knuckles murders you in your sleep.
var/RapeSet = 1
mob/Admin3/verb/Disable_Rape()
	set category="Admin"
	switch(input(usr,"Do you want to toggle rape? It's currently set to [RapeSet]. 1 = On, 0 = Off. Yes = 1, No = 0.") in list ("No","Yes"))
		if("Yes")
			RapeSet = 1
		if("No")
			RapeSet = 0
	world <<"Rape set to [RapeSet]"
mob/var
	isBorn = 0
	CanMate = 1
	Reproduce_Biologically=1
	N_Breed = 1
	E_Breed = 0
	Mature_Age=16

obj/Mate1/verb/Breed()
	set name = "Mate"
	set category="Other"
	if(!usr.CanMate)
		usr << "You can't mate, a injury is preventing it!"
		return
	var/mob/M=input("Who?") as null|mob in oview(1)
	if(!M) return
	if(M==usr) return
	if(!M.CanMate || M.N_Breed==0)
		usr<<"[M] cannot breed!"
		return
	switch(input(M,"[usr] wishes to breed with you, the female will produce a chid if anyone creates a Half-Breed(Hybrid/Second Generation) while she is on.", "", text) in list ("No", "Yes",))
		if("Yes")
			view(9)<<"<font color=yellow>[usr] breeds with [M]!"
			sleep(10)
			usr.breed(M,0)
		if("No")
			view(9)<<"<font color=yellow>[usr] is denied by [M]!"
			if(!RapeSet)
				return
			switch(input(usr,"Do you wish to attempt to rape [M]?", "", text) in list ("No", "Yes",))
				if("Yes")
					if(usr.expressedBP>M.expressedBP)
						view(9)<<"<font color=yellow>[usr] rapes [M]!"
						sleep(10)
						usr.breed(M,1)
					else
						view(9)<<"<font color=yellow>[usr] attempted to fuck [M] anyways, but [M] is too strong!!"
						if(usr.pgender=="Female"&&M.pgender=="Female"&&BreedFunnies)
							world<<"<font color=red><b>Dykes get their head on a spike! [usr] raped [M] at [usr.loc]!"
							usr.Death()
						else if(usr.pgender=="Male"&&usr.Race=="Namek"&&M.pgender=="Male"&&BreedFunnies)
							world<<"<font color=red><b>[usr] tried to give [M] his daily dose at [usr.x],[usr.y],[usr.z]!"
							usr.Death()
						else if(usr.pgender=="Male"&&M.pgender=="Male"&&BreedFunnies)
							world<<"<font color=red><b>Faggots and queers get the EXPLOSION! [usr] raped [M] at [usr.x],[usr.y],[usr.z]!"
							usr.Body_Parts()
				if("No")
					return

obj/Mate2/verb/Lay_Egg()
	set name = "Lay an Egg"
	set category="Other"
	if(!usr.CanMate)
		usr << "You can't mate, a injury is preventing it!"
		return
	view(9)<<"<font color=yellow>[usr] lays an egg!"
	sleep(10)
	var/mob/Egg/Z = new(usr.loc)
	Z.name="[usr.name]'s Egg"
	Z.Parent="[usr.name]"
	Z.Father_BP=usr.BP/4
	Z.Father_Race="[usr.Race]"
	Z.Father_Class="[usr.Class]"
	Z.spawnPlanet = usr.Planet
	Z.womb = return_new_genome(usr.genome)
	Z.womb.holder = Z
	Z.SaveMob=1
	Z.isNPC=1

mob/var
	Egg=0
	Husband=""
	Father=""
	Father_BP=0
	Husband_Class=""
	Father_Class=""

mob/proc/breed(var/mob/M,type)
	if(usr.Race=="Half-Breed"||M.Race=="Half-Breed")
		usr<<"Half-Breeds are sterile"
		M<<"Half-Breeds are sterile"
		return
	if(M.pgender=="Female"&&usr.pgender=="Male")
		M.Pregnant=1
		M.Husband="[usr]"
		M.Husband_Race="[usr.Race]"
		M.Husband_BP=usr.BP/4
		M.womb = return_new_genome(usr.genome,M.genome)
		if(M.Husband_BP>=10000)
			M.Husband_BP=10000
		view(9)<<"<font color=red><b>[usr] impregnated [M]!"
		if(BreedFunnies)
			switch(type)
				if(1)
					world<<"<font color=red><b>[usr] raped and impregnated [M] at [usr.x],[usr.y],[usr.z]!"
				else
					world<<"<font color=red><b>[usr] fucked [M] at [usr.x],[usr.y],[usr.z]!"
	else if(usr.pgender=="Female"&&M.pgender=="Male")
		usr.Pregnant=1
		usr.Husband="[M]"
		usr.Husband_Race="[M.Race]"
		usr.Husband_Class="[M.Class]"
		usr.Husband_BP=M.BP/4
		usr.womb = return_new_genome(usr.genome,M.genome)
		if(usr.Husband_BP>=10000)
			usr.Husband_BP=10000
		view(9)<<"<font color=red><b>[M] impregnated [usr]!"
		if(BreedFunnies)
			switch(type)
				if(1)
					world<<"<font color=red><b>[usr] raped and impregnated [M] at [usr.x],[usr.y],[usr.z]!"
				else
					world<<"<font color=red><b>[usr] raped and was impregnated by [M] at [usr.x],[usr.y],[usr.z]!"
	else if(usr.pgender=="Female"&&M.pgender=="Female"&&BreedFunnies)
		switch(type)
			if(1)
				world<<"<font color=red><b>Dykes get their head on a spike! [usr] raped [M] at [usr.x],[usr.y],[usr.z]!"
				usr.Death()
				M.KO()
			else
				view(9)<<"<font color=yellow>Mike 'Faggots go splat' Pence saves the day!!"
				world<<"<font color=red><b>Faggots and queers get the EXPLOSION! [usr] fucked [M] at [usr.loc]!"
				M.Body_Parts()
				usr.Body_Parts()
	else if(usr.pgender=="Male"&&usr.Race=="Namek"&&M.pgender=="Male"&&BreedFunnies)
		world<<"<font color=red><b>[usr] gave [M] his daily dose at [usr.loc]!"
		usr.KO()
		M.KO()
	else if(usr.pgender=="Male"&&M.pgender=="Male"&&BreedFunnies)
		world<<"<font color=red><b>Faggots and queers get the EXPLOSION! [usr] raped [M] at [usr.x],[usr.y],[usr.z]!"
		M.KO()
		usr.Body_Parts()