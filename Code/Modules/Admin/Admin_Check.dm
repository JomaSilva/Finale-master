mob/proc
	AdminCheck()
		var/trueckey = ckey(key)
		if(Admin1s.Find(trueckey)||Admin==1) Admin_Give()
		if(Admin2s.Find(trueckey)||Admin==2) Admin_Give_2()
		if(Admin3s.Find(trueckey)||Admin==3) Three_Admin_Give()
		if(Admin4s.Find(trueckey)||Admin==4) Full_Admin_Give()
		if(Owners.Find(trueckey)||Admin==5) Owner_Admin_Give()
	Owner_Admin_Give()
		//world.SetConfig("APP/admin", "[ckey]", "role=five")
		verbs+=typesof(/mob/OwnerAdmin/verb)
		verbs+=typesof(/mob/Admin1/verb)
		verbs+=typesof(/mob/Admin2/verb)
		verbs+=typesof(/mob/Admin3/verb)
		verbs+=typesof(/mob/special/verb)
		Admin=5
	Full_Admin_Give()
		//world.SetConfig("APP/admin", "[ckey]", "role=four")
		verbs+=typesof(/mob/OwnerAdmin/verb)
		verbs+=typesof(/mob/Admin1/verb)
		verbs+=typesof(/mob/Admin2/verb)
		verbs+=typesof(/mob/Admin3/verb)
		verbs+=typesof(/mob/special/verb)
		Admin=4
	Three_Admin_Give()
		//world.SetConfig("APP/admin", "[ckey]", "role=three")
		verbs+=typesof(/mob/Admin1/verb)
		verbs+=typesof(/mob/Admin2/verb)
		verbs+=typesof(/mob/Admin3/verb)
		verbs+=typesof(/mob/special/verb)
		Admin=3
	Admin_Give_2()
		//world.SetConfig("APP/admin", "[ckey]", "role=two")
		verbs+=typesof(/mob/Admin1/verb)
		verbs+=typesof(/mob/Admin2/verb)
		verbs+=typesof(/mob/special/verb)
		Admin=2
	Admin_Give()
		//world.SetConfig("APP/admin", "[ckey]", "role=one")
		verbs+=typesof(/mob/Admin1/verb)
		verbs+=typesof(/mob/special/verb)
		Admin=1
	Remove_Commands()
		verbs-=typesof(/mob/Admin3/verb)
		verbs-=typesof(/mob/Admin2/verb)
		verbs-=typesof(/mob/Admin1/verb)
		verbs-=typesof(/mob/special/verb)
		Admin=0
	Remove_All_Commands()
		verbs-=typesof(/mob/OwnerAdmin/verb)
		verbs-=typesof(/mob/Admin1/verb)
		verbs-=typesof(/mob/Admin2/verb)
		verbs-=typesof(/mob/Admin3/verb)
		verbs-=typesof(/mob/special/verb)
mob/var/tmp/averbcheck
var/list/Admin1s=list() //The keys of current admins, they save.
var/list/Admin2s=list()
var/list/Admin3s=list()
var/list/Admin4s=list()
//var/list/Owners=list("kingzombiethe1st","iroquoisredgrave","nevistus","ghost66") //codefags, you can just add to this list with your name if your codebase is private & for your serb.
//and hosts can remove (manually) other owners so if you want absolute control over all servers of your game, you're not getting it here chief.
var/list/Owners=list()
proc/SaveAdmins()
	var/savefile/S=new("Admins")
	S["Admin1s"]<<Admin1s
	S["Admin2s"]<<Admin2s
	S["Admin3s"]<<Admin3s
	S["Admin4s"]<<Admin4s
	S["Owners"]<<Owners
	fdel("cfg/admin.txt")
	file("cfg/admin.txt")<<json_encode(list("Admin1"=Admin1s,"Admin2"=Admin2s,"Admin3"=Admin3s,"Admin4"=Admin4s,"Owners"=Owners))
proc/LoadCfgAdmins()
	if(check_admin_exists())
		var/list/admin_decode=json_decode(file2text(file("cfg/admin.txt")))
		if(islist(admin_decode))
			for(var/i=1, i<=admin_decode?.len,i++)
				if(admin_decode?.len == null) return FALSE //file isn't correctly set.
				for(var/ii, ii<=admin_decode[admin_decode[i]]?.len,i++)
					if(admin_decode[admin_decode[i]]?.len == null) return FALSE //file isn't correctly set.
					var/cky = admin_decode[admin_decode[i]][ii]//this returns a ckey, admin_decode[admin_decode[i]] should be one of the above Admins lists.
					switch(admin_decode[i])
						if("Admin1") Admin1s |= cky
						if("Admin2") Admin2s |= cky
						if("Admin3") Admin3s |= cky
						if("Admin4") Admin4s |= cky
						if("Owners") Owners |= cky
proc/LoadAdmins() if(fexists("Admins"))
	var/savefile/S=new("Admins")
	S["Admin1s"]>>Admin1s
	S["Admin2s"]>>Admin2s
	S["Admin3s"]>>Admin3s
	S["Admin4s"]>>Admin4s
	S["Owners"]>>Owners
	LoadCfgAdmins()

mob/Admin3/verb
	AdminCreate()
		set name = "Create (Admin Ver.)"
		set category="Admin"
		var/varItem
		var/varType=input("What do you want to create?","Create") in list("Object","Mob","Cancel")
		if(varType=="Cancel") return
		if(varType=="Object") varItem=input("What do you want to make?","Create obj") in typesof(/obj) + list("Cancel")
		if(varType=="Mob") varItem=input("What do you want to make?","Create mob") in typesof(/mob) + list("Cancel")
		if(varItem=="Cancel") return
		var/Amount=input("How Many?","Create") as num
		WriteToLog("admin","[usr]([key]) created [Amount] [varItem] at [time2text(world.realtime,"Day DD hh:mm")]")
		while(Amount>0)
			Amount-=1
			new varItem(locate(x,y,z))
	Admin()
		set category="Admin"
		var/list/Choices=new/list
		for(var/mob/Player) if(Player.client) Choices.Add(Player)
		var/mob/Choice=input("Which person?") in Choices
		var/trueckey = ckey(Choice.key)
		if(Choice.Admin >= Admin)
			usr << "They're already the same level as you!"
			return
		Admin1s.Remove(trueckey)
		Admin2s.Remove(trueckey)
		Admin3s.Remove(trueckey)
		Admin4s.Remove(trueckey)
		Owners.Remove(trueckey)
		var/list/levellist = list()
		//levellist += "Admin 0"
		if(Admin>=1) levellist += "Admin 1"
		if(Admin>=2) levellist += "Admin 2"
		if(Admin>=3) levellist += "Admin 3"
		if(Admin>=4) levellist += "Admin 4"
		if(Admin>=5) levellist += "Admin 5"
		levellist += "Cancel"
		var/Level=input("What level of admin? Level 1-3 admins have restriction on verbs. Level 4s are given all non-owner level verbs. Level 5s are treated as owners. Level 6 is the owner.") in levellist
		if(Level=="Admin 1") Admin1s.Add(trueckey)
		if(Level=="Admin 2") Admin2s.Add(trueckey)
		if(Level=="Admin 3") Admin3s.Add(trueckey)
		if(Level=="Admin 4") Admin4s.Add(trueckey)
		if(Level=="Admin 5") Owners.Add(trueckey)
		if(Level!="Cancel") Choice.Admin=Level
		Choice.AdminCheck()
	AdminDemote()
		set name="Admin Demote"
		set category="Admin"
		var/list/Choices=new/list
		for(var/mob/Player) if(Player.client) Choices.Add(Player)
		var/mob/Choice=input("Which person?") in Choices
		var/trueckey = ckey(Choice.key)
		if(Choice.Admin >= Admin)
			usr << "They're the same level or above as you!"
			return
		var/list/levellist = list()
		Admin1s.Remove(trueckey)
		Admin2s.Remove(trueckey)
		Admin3s.Remove(trueckey)
		Admin4s.Remove(trueckey)
		Owners.Remove(trueckey)
		levellist += "No Admin"
		if(Admin>=1) levellist += "Admin 1"
		if(Admin>=2) levellist += "Admin 2"
		if(Admin>=3) levellist += "Admin 3"
		if(Admin>=4) levellist += "Admin 4"
		if(Admin>=5) levellist += "Admin 5"
		levellist += "Cancel"
		var/Level=input("What level of admin? Level 1-3 admins have restriction on verbs. Level 4s are given all non-owner level verbs. Level 5s are treated as owners. Level 6 is the owner.") in levellist
		switch(Level)
			if("Admin 1")
				Admin1s.Add(trueckey)
				Choice.Admin = 1
			if("Admin 2")
				Admin2s.Add(trueckey)
				Choice.Admin = 2
			if("Admin 3")
				Admin3s.Add(trueckey)
				Choice.Admin = 3
			if("Admin 4")
				Admin4s.Add(trueckey)
				Choice.Admin = 4
			if("Admin 5")
				Owners.Add(trueckey)
				Choice.Admin = 5
			if("No Admin") Choice.Admin = 0
		world.SetConfig("APP/admin", "[Choice.ckey]", null)
		Choice.AdminCheck()


proc/check_admin_exists()
	if(fexists("cfg/admin.txt"))
		return TRUE
	return FALSE