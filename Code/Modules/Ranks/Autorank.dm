mob/Admin3/verb/Ranks_Automatically()
	set name = "Rank Automatically"
	set category = "Admin"
	if(AutorankOn)
		AutorankOn=0
		world<<"Autorank has been turned off."
		return
	if(!AutorankOn)
		AutorankOn=1
		world<<"Autorank has been turned on."
		return
mob/Admin3/verb/GiveAutoRanks()
	set name="Give Auto Ranks"
	set category="Admin"
	for(var/mob/M) if(M.client&&M.GettingRank==1)
		M.GettingRank=0
	AutoRank()
mob/var
	tmp/GettingRank=0
	GotRank=0
	tmp/AddRankRunning = 0
	GetRank=1
mob/proc
	AddRank()
		if(AddRankRunning) return
		AddRankRunning = 1 //bug about ranks only once fucker (per login)
	//now to the fun bits fuck
		if(GetRank)
			var/chooserank
			switch(spawnPlanet)
				if("Earth")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(Turtle==null)
								Turtle=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Crane==null)
								Crane=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Earth_Guardian==null)
								Earth_Guardian=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Assistant_Guardian==null)
								Assistant_Guardian=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Namek")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(Namekian_Elder==null)
								Namekian_Elder=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(North_Elder==null)
								North_Elder=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(South_Elder==null)
								South_Elder=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(East_Elder==null)
								East_Elder=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(West_Elder==null)
								West_Elder=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Vegeta")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(King_of_Vegeta==null&&Race=="Saiyan")
								King_of_Vegeta=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Saibamen_Rouge_Leader==null&&Race=="Saibaman")
								Saibamen_Rouge_Leader=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Arconia")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(King_Of_Acronia==null)
								King_Of_Acronia=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Arconian_Guardian==null)
								Arconian_Guardian=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Icer Planet")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(Frost_Demon_Lord==null)
								Frost_Demon_Lord=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Arlia")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(King_Of_Hell==null&&Race=="Makyo")
								King_Of_Hell=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Arlian==null)
								Arlian=signature
								GotRank=1
								Rank_Verb_Assign()
						if("No")
							return
				if("Heaven")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(Grand_Kai==null&&Race=="Kai")
								Grand_Kai=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(Supreme_Kai==null&&Race=="Kai")
								Supreme_Kai=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(North_Kai==null&&Race=="Kai")
								North_Kai=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(South_Kai==null&&Race=="Kai")
								South_Kai=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(East_Kai==null&&Race=="Kai")
								East_Kai=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(West_Kai==null&&Race=="Kai")
								West_Kai=signature
								GotRank=1
								Rank_Verb_Assign()
								return
							if(King_Yemma==null)
								King_Yemma=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Hell")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(Demon_Lord==null)
								Demon_Lord=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
				if("Big Gete Star")
					chooserank=alert("Do you want a rank?","","Yes","No")
					switch(chooserank)
						if("Yes")
							if(Geti==null)
								Geti=signature
								GotRank=1
								Rank_Verb_Assign()
								return
						if("No")
							return
proc
	AutoRank()
	//Gives autorank. Following variable sees if ANY of this happens in the first place.
		world<<"Autorank start."
		if(AutorankOn)
			world<<"Autorank on."
			for(var/mob/M in player_list)
				if(M.GettingRank==0)
					M.GettingRank=1
					spawn M.AddRank()
				else continue
		else return