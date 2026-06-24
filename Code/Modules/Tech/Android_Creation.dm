//stuffs
obj/Creatables
	Android_Creation_Mainframe
		icon = '64x64tech.dmi'
		icon_state="android_pod"
		cost=500000
		neededtech=50
		desc = "Android Creation Mainframes allow you to create Androids or Bio-Androids (for players to create.) Destroying the mainframe will destroy any chance for a android or bioandroid to be created from the machine."
		create_type = /obj/items/Android_Creation_Mainframe

obj/items
	Android_Creation_Mainframe
		icon = '64x64tech.dmi'
		icon_state="android_pod"
		var/can_biod=0
		var/and=0
		var/biod=0
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] bolts the [src] to the ground."
						Bolted=1
						boltersig=usr.signature
			else if(Bolted&&boltersig==usr.signature)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						view(src)<<"<font size=1>[usr] unbolts the [src] from the ground."
						Bolted=0
		verb/Upgrade()
			set category = null
			set src in oview(1)
			switch(input("Upgrading to make Biological Androids costs 1 million Zenni. Do so?","",text) in list("Yes","No",))
				if("Yes")
					var/cost = 1000000
					if(usr.zenni>=cost)
						usr.zenni-=cost
						if(!can_biod) can_biod = 1
						view(src) << "<font size=2 color=red>[src]: BIODROID PRODUCTION ENABLED.</font>"
		verb/Create()
			set category = null
			set src in oview(1)
			if(Bolted)
				var/list/create_list = list()
				create_list+="Cancel"
				if(can_biod && !biod) create_list+="Bio-Android"
				if(!and) create_list+="Android"
				switch(input("This will allow someone to create a android of sorts in on top of this machine. They will have free will. Do so?","",text) in create_list)
					if("Bio-Android") switch(input("Creating a standard Bio-Android costs 100k Zenni. Do so?","",text) in list("Yes","No",))
						if("Yes")
							var/cost = 100000
							if(usr.zenni>=cost)
								usr.zenni-=cost
								biod=1
								bio_creator_list.len++
								bio_creator_list[bio_creator_list.len] = list(x,y,z)
							else
								usr << "Not enough zenni"
					if("Android") switch(input("Creating a standard Android costs 100k Zenni. Do so?","",text) in list("Yes","No",))
						if("Yes")
							var/cost = 100000
							if(usr.zenni>=cost)
								usr.zenni-=cost
								and=1
								android_creator_list.len++
								android_creator_list[android_creator_list.len] = list(x,y,z)
							else
								usr << "Not enough zenni"
		Del()
			if(and) android_creator_list.len--
			if(biod) bio_creator_list.len--
			..()