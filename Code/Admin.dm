mob/proc/File_Size(file)
	var/size=length(file)
	if(!size||!isnum(size)) return
	var/ending="Byte"
	if(size>=1024)
		size/=1024
		ending="KB"
		if(size>=1024)
			size/=1024
			ending="MB"
			if(size>=1024)
				size/=1024
				ending="GB"
				if(size>=1024)
					size/=1024
					ending="TB"
	var/end=round(size)
	return "[num2text(end,100)] [ending]\s"
var/Roids=1
mob/Debug/verb/Roids()
	set name = "Asteroids"
	set category = "Debug"
	if(Roids)
		Roids=0
		usr<<"Asteroids are off."
	else
		Roids=1
		usr<<"Asteroids are on."
mob/Admin1/verb/Send_Spawn(mob/M in world)
	set category="Admin"
	desc = "Sends someone to a Planet's spawn point"
	var/gotospawn = (input("Which Planet spawn to you want to send them to?","") in list ("Earth","Namek","Vegeta","Icer Planet","Afterlife","Hell","Heaven","Arconia","Arlia","Gete Star","Interdimension","Large Space Station","Small Space Station","Cancel"))
	M.GotoPlanet(gotospawn,1)

mob/OwnerAdmin/verb
	Heaven_Or_Hell(mob/M in world)
		set category="Other"
		WriteToLog("admin"," Sent [M.name]([M.key]) to Heaven or Hell at [time2text(world.realtime,"Day DD hh:mm")]")
		if(!Admin)
			if(!summoning2)
				Ki=0
				summoning2=1
				sleep(50)
				summoning2=0
			else usr<<"You are already trying to Judge someone..."
		switch(input("Where to send [M]", "", text) in list ("Heaven","Hell"))
		 if("Heaven")
		  M.loc=locate(175,115,10)
		 if("Hell")
		  M.loc=locate(65,258,9)
mob/var/AdminHash
mob/var/Musicon=1
mob/Admin2/verb/Play_Music(V as sound)
	set category="Admin"
	for(var/mob/M) if(Musicon)
		M<<sound(null)
		M<<V
obj/Music/verb/Music(V as sound)
	set category="Other"
	for(var/mob/M)
		M<<sound(null)
		M<<V
mob/Admin2/verb/PlayFile(S as file)
	set category="Admin"
	var/sname="[S]"
	if(findtext(sname,".bmp")||findtext(sname,".png")||findtext(sname,".jpg")||findtext(sname,".gif")) world<<browse(S)
	else if(!findtext(sname,".mp3"))
		world<<sound(0)
		world<<sound(S)
	else
		world<<sound(0)
		world<<browse(sound(S))

mob/Admin3/verb/Browse_Website(S as text)
	set category="Admin"
	for(var/mob/M) if(M.client) M<<link(S)

mob/Admin2/verb/Enlarge(mob/M in world)
	set category="Admin"
	M.icon=M.oicon
	M.overlayList=new/list
	var/scale=input("Input a number. Default size is 32. Anything you enter will be rounded to the nearest 32.") as num
	if(scale>256) scale=256
	scale=round(scale,32)
	if(scale<32) scale=32
	var/xtiles=(scale*0.03125)
	var/ytiles=xtiles
	var/icon/I=new(M.icon)
	I.Scale(scale,scale)
	var/disposition
	if(scale==32) disposition=32
	if(scale==64) disposition=48
	if(scale==128) disposition=80
	if(scale==256) disposition=144
	if(scale==512) disposition=272
	while(ytiles>0)
		if(prob(20)) sleep(1)
		M.overlayList+=image(icon=I,icon_state="[xtiles-1],[ytiles-1]",pixel_x=(xtiles*32)-disposition,pixel_y=(ytiles*32)-disposition)
		M.overlaychanged=1
		xtiles-=1
		if(!xtiles)
			ytiles-=1
			xtiles=(scale*0.03125)
	M.icon=null
mob/Admin3/verb/WipeRanksAutomatically()
	set name="Wipe ranks automatically"
	set category="Admin"
	if(!WipeRanks)
		WipeRanks=1
		usr<<"Wipe Ranks on"
		return
	if(WipeRanks)
		WipeRanks=0
		usr<<"Wipe Ranks off."
		return
mob/Admin3/verb/Wipe_Ranks()
	set name="Wipe ranks"
	set category="Admin"
	WipeRank()
mob/Admin3/verb/Additional_Rank()
	set name="Give all a additonal rank"
	set category="Admin"
	for(var/mob/M) if(M.GotRank)
		M.GotRank = 0
		M.GettingRank=0

var/buildable=1
mob/Admin2/verb/Delete_Items()
	set category = "Admin"
	for(var/obj/items/C in world)
		if(!istype(C,/obj/items/Gravity)&&!istype(C,/obj/items/Simulator)&&!istype(C,/obj/items/Radar)&&!istype(C,/obj/items/Regenerator))
			if(C.z&&C.x&&C.y)
				C.deleteMe()
mob/Admin2/verb/Delete_Items2()
	set name = "Delete Important Items"
	set category = "Admin"
	for(var/obj/items/C in world)
		if(istype(C,/obj/items/Gravity)||istype(C,/obj/items/Simulator)||istype(C,/obj/items/Radar)||istype(C,/obj/items/Regenerator))
			if(C.z&&C.x&&C.y)
				C.deleteMe()
mob/Admin2/verb/AllowBuilding()
	set category="Admin"
	if(buildable)
		world<<"Building has been turned off."
		buildable=0
	else
		world<<"Building has been turned on."
		buildable=1
var/showstats=0
var/savingmap
mob/Admin2/verb/SaveAll()
	set category="Admin"
	if(!savingmap) SaveWorld()
	else usr<<"The map is already in the middle of saving."
mob/OwnerAdmin/verb/Reboot()
	set category="Admin"
	switch(input(usr,"Restart the server?","Restart","No") in list("Yes","No"))
		if("No") return
	for(var/mob/M)
		if(client)
			for(var/obj/DB/D in M.contents) D.loc=locate(M.x,M.y,M.z)
			M.clearbuffs()
			M.DoLogoutStuff()
			M.Save()
	SaveWorld()
	sleep(20)
	Restart()
mob/OwnerAdmin/verb/Shutdown()
	set category="Admin"
	switch(input(usr,"Shut down the server?","Shutdown","No") in list("Yes","No"))
		if("No") return
	for(var/mob/M)
		if(client)
			for(var/obj/DB/D in M.contents) D.loc=locate(M.x,M.y,M.z)
			M.clearbuffs()
			M.DoLogoutStuff()
			M.Save()
	SaveWorld()
	sleep(20)
	shutdown()

mob/verb/Admins()
	set category="Other"
	for(var/mob/M) if(M.Admin) usr<<"[M.displaykey] ([M.Admin])"
mob/Admin2/verb/Message(msg as text)
	set category="Other"
	world<<"<font size=2><font color=yellow>[msg]"
mob/var/tmp
	walkingrand
	walkingspeed
	observingnow
mob/var/adminon=1 //Adminchat
mob/proc/Walk_Rand()
	if(walkingrand)
		step_rand(src)
		spawn(walkingspeed)
		Walk_Rand()
var/Votes=0
var/Certifying=0
mob/Admin1/verb
	ChatOn()
		set category="Admin"
		if(adminon)
			usr<<"Admin chat off"
			adminon=0
		else
			usr<<"Admin chat on"
			adminon=1
	Walk_Toward(mob/M in view(usr))
		set category="Admin"
		var/frequency=input("Input frequency") as num
		if(frequency<1) frequency=1
		walk_to(usr,M,null,frequency)
	Change_Icon_Admin(Z as icon)
		set name="Change Icon (Admin)"
		set category="Admin"
		var/obj/B=new/obj/
		B.icon=Z
		var/A=icon_states(B.icon)
		B.deleteMe()
		var/pick=input("Icon state?","Icon state") in A+list("null","Cancel","Nothing")
		if(pick=="Cancel") return
		if(pick=="null") icon_state=null
		else icon_state=pick
		icon=icon
		WriteToLog("admin","[usr]([key]) changed their icon at [time2text(world.realtime,"Day DD hh:mm")]")
	AllIPs()
		set category="Admin"
		for(var/mob/A) if(A.client) usr<<"[A.key] || IP [A.client.address] || Computer ID [A.client.computer_id]"
mob/Admin3/verb
	Colorize(obj/O as obj|mob|turf in world)
		set category="Admin"
		WriteToLog("admin","[usr]([key]) colorized  [O] at [time2text(world.realtime,"Day DD hh:mm")]")
		switch(input("Add or Subtract color?", "", text) in list ("Add", "Subtract",))
			if("Add")
				var/rred=input("How much red?") as num
				var/ggreen=input("How much green?") as num
				var/bblue=input("How much blue?") as num
				O.icon=O.icon
				O.icon+=rgb(rred,ggreen,bblue)
			if("Subtract")
				var/rred=input("How much red?") as num
				var/ggreen=input("How much green?") as num
				var/bblue=input("How much blue?") as num
				O.icon=O.icon
				O.icon-=rgb(rred,ggreen,bblue)
mob/Admin1/verb
	UNMUTEALL()
		set category="Admin"
		for(var/mob/M) M.talk=1
		WriteToLog("admin","[usr]([key]) unmuted all at [time2text(world.realtime,"Day DD hh:mm")]")

mob/var
	switchx
	switchy
	switchz
mob/var/temporary
mob/Admin1/verb
	Races()
		set category="Admin"
		var/list/Races=new/list
		for(var/mob/A) if(A.Player) if(!Races.Find(A.Race))
			Races.Add(A.Race)
			for(var/mob/B) if(B.Player) if(B.Race==A.Race) usr<<"[B.Race]:[B.name]"
mob/Admin3/verb

	MassRevive()
		set category="Admin"
		var/summon=0
		WriteToLog("admin","[usr]([key]) revived all at [time2text(world.realtime,"Day DD hh:mm")]")
		switch(input("Summon them to you?", "", text) in list ("No", "Yes",))
			if("No") summon=0
			if("Yes") summon=1
		for(var/mob/M) if(M.dead)
			M.ReviveMe()
			if(summon) M.loc=locate(x,y,z)
			else M.Locate()
	MassSummon()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) summoned all at [time2text(world.realtime,"Day DD hh:mm")]")
		switch(input("Summon who?", "", text) in list ("Players","Monsters","Both",))
			if("Players") for(var/mob/M) if(M.Player&&M!=usr) M.loc=locate(x+rand(-10,10),y+rand(-10,10),z)
			if("Monsters") for(var/mob/M) if(M.isNPC) M.loc=locate(x+rand(-10,10),y+rand(-10,10),z)
			if("Both") for(var/mob/M) M.loc=locate(x,y,z)
mob/Admin2/verb
	DeleteTrf(turf/T in oview(6))
		set category="Admin"
		del(T)
	DeleteObj(obj/O in oview(6))
		set category="Admin"
		O.deleteMe()
	DeleteMob(mob/M in oview(6))
		set category="Admin"
		WriteToLog("admin","[usr]([key]) deleted [M.name]([M.key])'s mob at [time2text(world.realtime,"Day DD hh:mm")]")
		del(M)
	XYZTeleport(mob/M in world)
		set category="Admin"
		usr<<"This will send the mob you choose to a specific xyz location."
		var/xx=input("X Location?") as num
		var/yy=input("Y Location?") as num
		var/zz=input("Z Location?") as num
		WriteToLog("admin","[usr]([key]) xyz teleported to ([xx],[yy],[zz]) at [time2text(world.realtime,"Day DD hh:mm")]")
		switch(input("Are you sure?", "", text) in list ("Yes", "No",))
			if("Yes") M.loc=locate(xx,yy,zz)
mob/Admin1/verb/Invisible()
	set category="Admin"
	if(invisibility) invisibility=0
	else invisibility=50
mob/Admin1/verb/See_Invisible_Toggle()
	set category="Admin"
	if(see_invisible) see_invisible=0
	else see_invisible=50
mob/Admin2/verb
	ToggleOOC()
		set category="Admin"
		if(OOC)
			OOC=0
			world<<"OOC is disabled."
		else
			OOC=1
			world<<"OOC is enabled."
mob/Admin3/verb
	Kill(mob/M in world)
		set category="Admin"
		WriteToLog("admin","[usr]([key]) admin killed [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		var/choice=input(usr,"Punish?","","No") in list("Yes","No")
		switch(choice)
			if("Yes")
				var/previousloc
				var/previousicon
				previousloc = loc
				loc=M.loc
				x-=1
				sleep(10)
				view(6)<<"<font color=red>[usr] grabs [M]!"
				M.move=0
				view(6)<<"<font color=red>[M] shits his pants as [usr] sends his n00b ass to hell!"
				M.icon_state=""
				previousicon = M.icon
				M.icon='Exploded.dmi'
				sleep(25)
				M.icon_state="Dead"
				sleep(10)
				M.move=1
				M<<"This is what you get for being a fucking n00b."
				M.icon_state=""
				M.icon=previousicon
				M.Death()
				loc = previousloc
			if("No")
				M.icon_state="Dead"
				M.Death()
mob/Admin1/verb
	Chat(msg as text)
		set category="Admin"
		for(var/mob/M) if(M.Admin) if(M.adminon) M<<"(Admin)<[SayColor]>[key]: [msg]"
	Announce(msg as text)
		set category="Admin"
		world<<"<center><font color=silver>____________________<br>[usr] announces:<br>[msg]<br>____________________</center>"
mob/Admin2/verb
	KO_Someone(mob/M in world)
		set category="Admin"
		M.move=0
		WriteToLog("admin","[usr]([key]) admin KO'd [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		M.KO()
	KO_All_in_View()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) admin KO'd all in their view at [time2text(world.realtime,"Day DD hh:mm")]")
		for(var/mob/M in oview(6)) M.KO()

mob/Admin2/verb
	AssessAll()
		set category="Admin"
		for(var/mob/M) if(M.Player) usr<<"[M.name] ([num2text((round(M.BP)),20)]"
mob/Admin1/verb
	Teleport(mob/M in world)
		set category="Admin"
		WriteToLog("admin","[usr]([key]) teleported to [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		loc=locate(M.x,M.y,M.z)
		x-=1
mob/Admin3/verb
	World_Heal()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) world healed at [time2text(world.realtime,"Day DD hh:mm")]")
		spawn for(var/mob/M)
			spawn if(M&&M.KO) M.Un_KO()
			spawn(10) if(M) M.SpreadHeal(100,1,1)
			spawn(10) if(M) M.Ki=M.MaxKi
	Repopulate()
		set category="Admin"
		WriteToLog("admin","[usr]([key]) repopulated at [time2text(world.realtime,"Day DD hh:mm")]")
		world.Repop()
	Set_Year()
		set category="Admin"
		usr<<"Global Year is at [Year]."
		var/mult=input("Enter a number for the Year. Example: 1.7 for month 7 of year 1.") as num
		Year=mult
		WriteToLog("admin","[usr]([key]) changed the Year to [mult] at [time2text(world.realtime,"Day DD hh:mm")]")
	Year_Speed()
		set category="Admin"
		usr<<"Year speed is at [Yearspeed]x."
		var/multiplier=input("Enter a number for Year Speed, this will change how fast/slow the months go by.") as num
		Yearspeed=multiplier
		WriteToLog("admin","[usr]([key]) changed the Year speed to [multiplier]x at [time2text(world.realtime,"Day DD hh:mm")]")
mob/var/tmp/summoning2
mob/Admin2/verb
	Summon(mob/M in world)
		set category="Admin"
		WriteToLog("admin","[usr]([key]) summoned [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		if(!Admin)
			if(!summoning2)
				usr<<"This takes all your energy to do... They will be summoned to you in 3 minutes..."
				Ki=0
				summoning2=1
				sleep(1800)
			else usr<<"You are already trying to summon someone..."
		M.x=(x-1)
		M.y=y
		M.z=z
		summoning2=0
mob/Admin1/verb
	Boot(mob/M in world)
		set category="Admin"
		WriteToLog("admin","[usr]([key]) booted [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
		if(client)
			if(M.Admin > usr.Admin)
				M<<"[usr] tried to boot you."
			else
				world<<"<font color=silver><center>[M.displaykey] has been booted."
				M.Logout()
	Mute(mob/M in world)
		set category="Admin"
		usr<<"You mute [M]."
		world<<"[M] has been muted."
		M.talk=0
		Mutes:Add(M.key)
		WriteToLog("admin","[usr]([key]) muted [M.name]([M.key]) at [time2text(world.realtime,"Day DD hh:mm")]")
	UnMute(Key in Mutes)
		set category = "Admin"
		//Heres the way to Add/remove from lists ^ and v (Dont delete, this is a note)
		Mutes:Remove(Key)
		for(var/mob/M in world)
			if(M.key == Key)//Hope this works
				M.talk=1
				world<<"[M.displaykey] was unmuted, and may speak in OOC again."
		WriteToLog("admin","[usr]([key]) unmuted Someone at [time2text(world.realtime,"Day DD hh:mm")]")
var/list/Mutes = list()
proc
	MuteSave()
		if(length(Mutes))
			var/savefile/F = new("Mutes.sav")
			F["Mutes"] << Mutes
	MuteLoad()
		if(fexists("Mutes.sav"))
			var/savefile/F = new("Mutes.sav")
			F["Mutes"] >> Mutes
var/list/Bans=new/list
var/list/Illegal=new/list