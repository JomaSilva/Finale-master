/*mob/keyable/verb/RiftTeleport()
	set category="Skills"
	var/image/I=image(icon='Black Hole.dmi',icon_state="full")
	if(!usr.canmove || usr.KO || usr.deathregening || usr.gravParalysis || usr.stagger) return
	switch(input("Person or Location?","",text) in list("Person","Location",))
		if("Location")
			var/xx=input("X Location?") as num
			var/yy=input("Y Location?") as num
			var/zz=input("Z Location?") as num
			oview(usr)<<"[usr] disappears into a  rift that disappears after they enter."
			spawn flick(I,usr)
			sleep(10)
			usr.loc=locate(xx,yy,zz)
			oview(usr)<<"[usr] appears out of a rift in time-space."
		else
			var/list/A=new/list
			for(var/mob/M) if(M.client) A.Add(M)
			var/Choice=input("Who?") in A
			oview(usr)<<"[usr] disappears into a rift that disappears after they enter."
			spawn flick(I,usr)
			sleep(10)
			for(var/mob/M) if(M==Choice) usr.loc=locate(M.x+rand(-1,1),M.y+rand(-1,1),M.z)
			oview(usr)<<"[usr] appears out of a rift in time-space."*/