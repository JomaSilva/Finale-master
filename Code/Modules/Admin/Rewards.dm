mob/Admin1/verb
	AdminObserve(mob/M in world)
		set category="Admin"
		WriteToLog("admin","[src] observed [M] on [time2text(world.realtime,"Day DD hh:mm")].")
		client.perspective=EYE_PERSPECTIVE
		client.eye=M
		usr.observingnow=1

	Reward(mob/M in world)
		set name = "Reward"
		set category="Admin"
		var/list/rewardList = list()
		rewardList.Add("Cancel")
		rewardList.Add("Heal","Youth", "Power","Tech Skill", "Zenni", "Milestones","Energy","Anger","Anger Greatly")
		if(usr.Admin>=2) rewardList.Add("SSJ", "SSJ2", "SSJ3", "SSJ4","USSJ","Full Power","True Full Power","Super Namek","Heal","Unseal")
		if(usr.Admin>=3) rewardList.Add("Immortality", "Ascension", "Revive",/*, "RP Reward",*/"Give Ritual God")
		switch(input("Give RP Bonus", "", text) in rewardList)
			if("Youth")
				M.Age=M.InclineAge
				M.Body=M.InclineAge
				WriteToLog("admin","[usr]([key]) restored [M.name]([M.key])'s youth at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Power")
				var/REWARD=input("How much?","Multiply [M.BP] x ??(Base BP = True Power x BP Mod")as num
				if(REWARD<0)
					src<<"You cant do that!"
				else
					M.BP*=REWARD
					M.safetyBP*=REWARD
					M<<"You have been rewarded [REWARD]x your BP by [usr]!"
				WriteToLog("admin","[usr]([key]) multiplied [M.name]([M.key])'s power by x[REWARD] at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Zenni")
				var/amount=input("Add how much zenni?") as num
				M.zenni+=amount
				WriteToLog("admin","[usr]([key]) gave [M.name]([M.key]) [amount] zenni at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Tech Skill")
				var/amount=input("Add how much tech xp?") as num
				M.techxp+=amount
				WriteToLog("admin","[usr]([key]) gave [M.name]([M.key]) [amount] tech xp at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Milestones")
				var/REWARD=input("How much?","This will give free Milestones to [M]!")as num
				if(REWARD<0||REWARD>10000)
					src<<"You cant do that!"
				else
					M.totalskillpoints+=REWARD
					M.admingibbedpoints+=REWARD
					M.skillpoints+=REWARD //grant the SPENDABLE pool right away so the gift is usable immediately (skill trees check skillpoints, not totalskillpoints)
					M.availablepoints+=REWARD //and the style-allocatable pool
					M<<"You have been rewarded [REWARD] Milestones by [usr]!"
			if("Energy")
				var/REWARD=input("How much?","Multiply [M.BP] x ??(Base BP = True Power x BP Mod")as num
				if(REWARD<0)
					src<<"You cant do that!"
				else
					M.BP*=REWARD
					M<<"You have been rewarded [REWARD]x your BP by [usr]!"
			if("Anger")
				M.StoredAnger=80
			if("Anger Greatly")
				M.StoredAnger=100
			if("Heal")
				if(M.KO) spawn M.Un_KO()
				spawn(10) M.SpreadHeal(150,1,1)
				for(var/datum/Body/B in M.body)
					if(B.lopped) B.RegrowLimb()
					B.health = B.maxhealth
				spawn(10) M.Ki=M.MaxKi
				spawn(10) M.stamina=M.maxstamina
				if(M.godki && M.godki.tier)
					M.gain_godki(M.godki.max_energy)
			if("SSJ")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Super Saiyan at [time2text(world.realtime,"Day DD hh:mm")]")
				M.SSj()
			if("SSJ4")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Super Saiyan 4 at [time2text(world.realtime,"Day DD hh:mm")]")
				M.SSj4()
				if(M.hasssj4== 1)
					file("AdminoLog.log")<<"[usr]([key]) made [M.name]([M.key]) Super Saiyan 4. The process succeeded."
			if("USSJ")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Ultra Super Saiyan at [time2text(world.realtime,"Day DD hh:mm")]")
				M.Ultra_SSj()
			if("Full Power")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Full Power at [time2text(world.realtime,"Day DD hh:mm")]")
				M.Max_Power()
			if("True Full Power")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) True Full Power at [time2text(world.realtime,"Day DD hh:mm")]")
				M.True_Max_Power()
			if("Super Namek")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Super Namekian at [time2text(world.realtime,"Day DD hh:mm")]")
				if(!M.snamek) M.snamek()
				else usr<<"They are a super namek."
			if("SSJ2")
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Super Saiyan 2 at [time2text(world.realtime,"Day DD hh:mm")]")
				M.SSj2()
			if("SSJ3")
				M.ssj=2
				WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) Super Saiyan 3 at [time2text(world.realtime,"Day DD hh:mm")]")
				M.SSj3()
			if("Ascension")
				var/choice = alert(usr,"This will allow a mob to ascend, regardless of global variables. If Ascension is globally allowed, then this will just start ascension in general, beginning with this mob. Do so? \nAlternatively, if they can already ascend, this will tick the variable in the other direction. They will then be treated as normal.","","Yes","No")
				if(choice=="Yes")
					if(!M.AscensionAllowed)
						AscensionStarted = 1
						world << "Ascension has started."
						usr << "Enabled their ascension."
						M.AscensionAllowed = 1
					else
						usr << "Disabled their ascension."
						M.AscensionAllowed = 0
					WriteToLog("admin","[usr]([key]) toggled [M]'s ascension variable to [M.AscensionAllowed]. (1 == true, 0 == false.)")
			if("Immortality")
				if(!M.immortal)
					M.immortal=1
					usr<<"[M] is now immortal"
					WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) immortal at [time2text(world.realtime,"Day DD hh:mm")]")
				else
					M.immortal=0
					usr<<"[M] is now mortal"
					WriteToLog("admin","[usr]([key]) made [M.name]([M.key]) mortal at [time2text(world.realtime,"Day DD hh:mm")]")
			if("Revive")
				WriteToLog("admin","[usr]([key]) revived [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
				M.ReviveMe()
				M.Locate()
				M.KO=0
				M.SpreadHeal(100,1,1)
				M.move=1
				M.icon_state=""
				M.overlayList-='Halo.dmi'
				M.overlaychanged=1
			if("Give Soul")
				WriteToLog("admin","[usr]([key]) gave a soul to [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
				M.HasSoul = 1
			if("Unseal")
				if(M.isSealed) M.UnSealMob()
				if(alert(usr,"Summon?","","Yes","No")=="Yes")
					M.loc = locate(usr.x,usr.y,usr.z)
			/*if("RP Reward")
				var/list/RPrewardtypelist = list()
				RPrewardtypelist.Add("Cancel")
				RPrewardtypelist.Add("Booster")//,"Artifact", "Skill") //These MUST be reserved as RP rewards for events or given to Event Characters for an edge.
				switch(input("What RP Reward type would you like to give? Boosters can be given out at admin's discretion as a simple event reward. Artifacts and Skills should be rare and only given out once prerequisites are met and after longer/bigger events.", "", text)in RPrewardtypelist)
					if("Booster")
						var/list/RPrewardboosterlist = list()
						RPrewardboosterlist.Add("Cancel")
						RPrewardboosterlist+=typesof(/obj/Artifacts/Boosters)
						var/Choice=input("Which Booster? Each Gem increases their respective stat by 10 while equipped.") in RPrewardboosterlist
						if("Cancel" != Choice) M.contents+=new Choice*/
			if("Give Ritual God")
				var/list/L = list()
				for(var/mob/R in range(5,R))
					if(L.len >= 5) break
					L += R
				INITIALIZEGODPROTOCOL(L)

mob/Admin3/verb/Give(mob/M in world)
	set category="Admin"
	set name = "Give"
	switch(input(usr,"Skill, Item, Rank, Verb? (Verbs don't contain all verbs. Skill is usually your best bet.)") in list("Skill","Rank","Item","Tree","Cancel"))
		if("Item")
			var/list/list1=new/list
			list1+=typesof(/obj)
			list1-=typesof(/obj/Ritual)
			list1-=typesof(/obj/buildables)
			list1-=typesof(/obj/Turfs)
			list1-=typesof(/obj/barrier/Edges)
			list1-=typesof(/obj/Surf)
			list1-=typesof(/obj/Trees)
			list1-=typesof(/obj/Creatables)
			list1-=typesof(/obj/overlay)
			list1-=/obj/Music
			list1-=typesof(/obj/Crater)
			list1-=/obj/impactditch
			list1-=/obj/items
			list1-=/obj/Contact
			list1-=/obj/Faction
			list1-=/obj/Core_Computer
			list1-=/obj/GK_Well
			list1-=/obj/Zenni
			list1-=/obj/DeadZone
			list1-=/obj/DBVTitle
			list1-=/obj/ShootingStar
			list1-=/obj/SplitForm
			list1-=/obj/Explosion
			list1-=/obj/explosions
			list1-=/obj/Tornado
			list1-=/obj/Assess
			list1-=/obj/Teleporter
			list1-=/obj/aurachoice
			list1-=/obj/DummyClothes
			list1-=/obj/clothingwindowverbs
			list1-=/obj/DummyHair
			list1-=typesof(/obj/screen)
			list1-=/obj/hairwindowverbs
			list1-=/obj/aurawindowverbs
			//list1-=/obj/fight_temp_obj
			list1-=/obj/stylewindow
			list1-=/obj/mobCorpse
			list1-=/obj/MafubaEffect
			list1-=/obj/Magic_Portal
			list1-=/obj/Magic_Sifter
			list1-=/obj/MakyoGate
			list1-=/obj/MakyoReturn
			list1-=typesof(/obj/buff)
			list1-=/obj/buildwindow
			list1-=/obj/BuildWindowTmp
			list1-=/obj/BuildWindowCustm
			list1-=/obj/BuildWindowSelect
			list1-=/obj/hotkey
			list1-=typesof(/obj/SkillTree)
			list1-=/obj/treewindow
			list1-=/obj/techwindow
			list1-=typesof(/obj/Plants)
			list1-=/obj/Planets
			list1-=/obj/Spacepod
			list1-=/obj/Rocketship
			list1-=/obj/researchwindow
			list1-=/obj/researchbuttons
			list1-=/obj/Power_Drill
			list1-=/obj/Super_Computer
			list1-=typesof(/obj/barrier)
			list1-=typesof(/obj/CreateAttackWindow)
			list1-=/obj/bigboom
			list1-=/obj/Spirit
			list1-=/obj/BodyswapOBJ
			list1-=/obj/InterdimensionPortal
			list1-=/obj/Sacred_Water
			list1-=/obj/SacredGroveGate
			list1-=/obj/DeadZone
			list1-=/obj/Magic_Portal
			list1-=/obj/Magic_Sifter
			list1-=/obj/Reincarnation_Tree
			list1-=/obj/MSPedestal
			list1-=/obj/SpawnPoint
			//list1-=/obj/Holy_Fountain
			list1+="Cancel"
			/*for(var/A in list1)
				var/obj/nA = locate(A)
				if(nA.IsntAItem)
					list1-=A*/
			var/Choice=input("Give what?") in list1
			if(Choice != "Cancel")
				M.contents+=new Choice
				WriteToLog("admin","[usr]([key]) gave a [Choice] to [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		if("Skill")
			var/list/list1=new/list
			list1+=typesof(/datum/skill)
			list1-=typesof(/datum/skill/tree)
			list1+="Cancel"
			var/Choice=input("Give what?") in list1
			if(Choice != "Cancel")
				M.learnSkill(new Choice, 0, 0)
				WriteToLog("admin","[usr]([key]) gave [Choice] to [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		if("Tree")
			var/list/list1=new/list
			list1+=typesof(/datum/skill/tree)
			list1+="Cancel"
			var/Choice=input("Give what?") in list1
			if(Choice != "Cancel")
				M.getTree(new Choice)
				WriteToLog("admin","[usr]([key]) gave [Choice] to [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		/*if("Verb")
			var/varVerb = input("What do you want to give? (Careful, some of these are not verbs.)","Give Verbs") in typesof(/mob) + list("Cancel")
			if(varVerb != "Cancel")
				if(varVerb == /mob/Rank/)
					var/varVerbs = input("Which one?","Give Verbs") in typesof(/mob/Rank) + list("Cancel")
					M:verbs += varVerbs
					return
				if(varVerb == /mob/Admin1/)
					var/varVerbs1 = input("Which one?","Give Verbs") in typesof(/mob/Admin1) + list("Cancel")
					M:verbs += varVerbs1
					return
				if(varVerb == /mob/Admin2/)
					var/varVerbs2 = input("Which one?","Give Verbs") in typesof(/mob/Admin2) + list("Cancel")
					M:verbs += varVerbs2
					return
				if(varVerb == /mob/Admin3/)
					var/varVerbs3 = input("Which one?","Give Verbs") in typesof(/mob/Admin3) + list("Cancel")
					M:verbs += varVerbs3
					return
				if(varVerb == /mob/OwnerAdmin/)
					var/varVerbs4 = input("Which one?","Give Verbs") in typesof(/mob/OwnerAdmin) + list("Cancel")
					M:verbs += varVerbs4
					return
				else
					M:verbs += varVerb*/
		if("Rank")
			switch(input("Give Rank", "", text) in list ("Earth Guardian","Geti Star King","Arlian King","Earth Assistant Guardian"\
			,"Namekian Elder","North Elder","South Elder","East Elder","West Elder","King Yemma",\
			"Grand Kai","Supreme Kai","King of Vegeta","President","North Kai","South Kai",\
			"East Kai","West Kai","Demon Lord","Frost Demon Lord","Turtle","Crane","King Of Mayko","King Of Acronia", "Arconian Guardian", "Saibamen Rouge Leader","Captain/King of Pirates","Mutany Leader","None",))
				if("Frost Demon Lord") Frost_Demon_Lord=M.signature
				if("Demon Lord") Demon_Lord=M.signature
				if("Earth Guardian") Earth_Guardian=M.signature
				if("King Of Mayko") King_Of_Hell=M.signature
				if("King Of Acronia") King_Of_Acronia=M.signature
				if("Arconian Guardian") Arconian_Guardian=M.signature
				if("Saibamen Rouge Leader") Saibamen_Rouge_Leader=M.signature
				if("Earth Assistant Guardian") Assistant_Guardian=M.signature
				if("Namekian Elder") Namekian_Elder=M.signature
				if("North Elder") North_Elder=M.signature
				if("South Elder") South_Elder=M.signature
				if("East Elder") East_Elder=M.signature
				if("West Elder") West_Elder=M.signature
				if("Grand Kai") Grand_Kai=M.signature
				if("Supreme Kai") Supreme_Kai=M.signature
				if("King of Vegeta") King_of_Vegeta=M.signature
				if("President") President=M.signature
				if("North Kai") North_Kai=M.signature
				if("South Kai") South_Kai=M.signature
				if("East Kai") East_Kai=M.signature
				if("West Kai") West_Kai=M.signature
				if("Turtle") Turtle=M.signature
				if("Crane") Crane=M.signature
				if("King Yemma") King_Yemma=M.signature
				if("Captain/King of Pirates") capt=M.signature
				if("Geti Star King") Geti=M.signature
				if("Mutany Leader") mutany=M.signature
				if("Arlian King") Arlian=M.signature
				if(!("None")) RankList[M.signature]=M.name
			M.Rank_Verb_Assign()