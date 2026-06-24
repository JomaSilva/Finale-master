obj/var/Password
obj/var/mapsave

obj/items
	createDust=0
	var/stackable = 0
obj/items/Book
	icon='Books.dmi'
	stackable=0
	var/book={"<html>
<head><title>Notes</title></head><body bgcolor="#000000"><font size=2><font color="#0099FF"></b><!-- write text between <p>, </b> to break (outside of <p>), <strong> bold, <i> italics.--></body><html>"}
	verb/Name()
		set category=null
		name=input("") as text
	verb/View()
		set category=null
		set src in view(1)
		usr<<browse(book,"window=Book;size=500x500")
	verb/Input()
		set category=null
		book=input(usr,"Book","Book",book) as message
obj/var/WindmillShuriken
obj/items/Windmill_Shuriken
	icon='Windmill Shuriken.dmi'
	var/windmillBP = 5
	var/Ammo = 15
	var/maxAmmo = 15
	var/shootSpeed = 1
	var/reload
	verb/Shoot()
		set category="Skills"
		if(!reload)
			if(Ammo>=1)
				reload=1
				var/obj/attack/blast/A=new/obj/attack/blast/
				A.WindmillShuriken=1
				A.loc=locate(usr.x,usr.y,usr.z)
				A.icon=icon
				A.density=1
				A.Pow=usr.Ephysoff
				A.BP=usr.intBPcap
				A.murderToggle=0
				walk(A,usr.dir)
				spawn(100) if(A) del(A)
				sleep(5*shootSpeed)
				reload=0
			else
				usr<<"[src]: Reloading..."
				reload=1
				sleep(50*shootSpeed)
				usr<<"[src]: Done!"
				Ammo=maxAmmo
				reload=0
	verb/Upgrade()
		set category="Skills"
		switch(input(usr,"Ammo, BP, or Speed?") in list("Ammo","BP","Speed","Cancel"))
			if("Ammo")
				var/upgradenum = input(usr,"Increase max ammo by how much? (1000 zenni per increase!)") as num
				if(upgradenum*1000>usr.zenni) return
				else
					usr.zenni -= upgradenum*1000
					maxAmmo += upgradenum
					Ammo = maxAmmo
			if("BP")
				if(alert(usr,"Upgrade BP?","","Yes","No")=="Yes")
					windmillBP = usr.intBPcap
			if("Speed")
				var/upgradenum = input(usr,"Increase speed by how much? (5000 zenni per increase! Maximum speed is 10! You start at 1)") as num
				if(upgradenum*5000>usr.zenni) return
				else
					if(shootSpeed+upgradenum>10)
						usr.zenni -= max((10-shootSpeed),0)
						shootSpeed = 10
					else
						usr.zenni -= upgradenum*5000
						shootSpeed += upgradenum
	verb/Icon()
		set category="Skills"
		switch(alert(usr,"Default or custom?","","Default","Custom"))
			if("Default")
				icon='Windmill Shuriken.dmi'
			if("Custom")
				icon=input(usr,"Select your icon.","Icon selection") as icon
obj/GK_Well
	icon='props.dmi'
	icon_state="21"
	density=1
	var/effectiveness=1
	var/tmp/water = 1
	verb/Action()
		set category="Other"
		set src in oview(1)
		if(!usr.drinking&&!usr.train&&!usr.med&&water)
			usr.drinking=1
			view(6)<<"<font color=red>* [usr] drinks some water. *"
			usr.SpreadHeal(100/effectiveness)
			usr.Ki+=(usr.MaxKi/effectiveness)
			water = 0
			sleep(20)
			usr.drinking=0
			sleep(500)
			water = 1
mob/var/tmp/inhealtank=0
mob/var/tmp/weight=1
mob/var/tmp/SeedSaiba
mob/var/yemmas=0
mob/var/might=0
mob/var/eden=0
mob/var/eating=0
mob/var
	Weighted=0
obj/var/NotSavable
obj/var/equipped=0
mob/var/equipped=0
obj/var/zenni
obj/Zenni
	icon='ZenniIcon.dmi'
	SaveItem=0 //That way tons of it won't be lying on the ground after a reboot
	var/getkey
	var/getIP
	verb/Drop()
		set category=null
		set src in usr
		var/zenni=input("Drop how much zenni?") as num
		if(zenni>usr.zenni) zenni=usr.zenni
		if(zenni>=1)
			usr.zenni-=zenni
			zenni=round(zenni)
			var/obj/Zenni/A=new/obj/Zenni
			A.loc=locate(usr.x,usr.y,usr.z)
			A.zenni=zenni
			A.name="[num2text(A.zenni,20)] zenni"
			A.getkey=usr.key
			A.getIP=usr.client.computer_id
			step(A,usr.dir)
			view(usr)<<"<font size=1><font color=teal>[usr] drops [num2text(zenni,20)] zenni."
			if(A.zenni<1000) A.icon_state="Zenni1"
			else if(A.zenni<10000) A.icon_state="Zenni2"
			else if(A.zenni<99999) A.icon_state="Zenni3"
			else if(A.zenni<100000) A.icon_state="Zenni4"
	verb/Get()
		set category=null
		set src in oview(1)
		usr<<"You pick up [src]."
		oview(usr)<<"<font size=1><font color=teal>[usr] picks up [src.zenni]z."
		WriteToLog("rplog","[usr] picks up [src.zenni]z    ([time2text(world.realtime,"Day DD hh:mm")])")
		usr.zenni+=src.zenni
		del(src)
		return
mob/var
	hasdrill=0
mob/var/scouteron //if you do or do not hear scouter speak
mob/var/spacesuit=0

mob/var
		inven_min=0
		inven_max=30
		count=0
		tmp/invenrunning=0

mob/proc/CheckInventory()
	var/count=0
	for(var/obj/items/o in src)count++
	inven_min=count
	if(inven_min>=inven_max)
		inven_min=inven_max
		src<<"You have no more space in your inventory."
		return TRUE
mob/proc/InvenSet()
	var/count=0
	for(var/obj/items/o in src)count++
	inven_min=count
	return
mob/proc/CondenseLoop()
	var/count = 0
	invenrunning=1
	start
	if(count!=inven_min)
		for(var/obj/items/i in src)
			if(i.Condense())
				del(i)
			sleep(3)
	count = inven_min
	sleep(20)
	goto start