obj/mobCorpse
	IsntAItem=1
	var/masterylevel=1//requirement for skinning
	var/list/skinlist=list()
	verb/Eat()
		set category = null
		set src in view(1)
		if(usr.CanEat)
			view()<<"[usr] eats the corpse."
			if(usr.HP<=100)
				usr.SpreadHeal(5,0,0)
			usr.currentNutrition += 30
			del(src)
		else if(!usr.CanEat)
			usr<<"You can't digest food."
	verb/Bury()
		set category = null
		set src in view(1)
		view()<<"[usr] buries [name]"
		GenerateCross(input(usr,"Grave text.","","Here lies [name]") as text)
		del(src)
	verb/Destroy()
		set category = null
		set src in view(1)
		view()<<"[usr] destroys [name]"
		del(src)
	verb/Skin_Corpse()
		set category = null
		set src in view(1)
		for(var/datum/mastery/Life/Skinning/S in usr.learnedmasteries)
			if(S.level>=src.masterylevel)
				usr<<"You skin the [name]!"
				var/count = rand(1,3)
				var/list/tlist = list()
				for(var/turf/T in oview(1))
					tlist+=T
				while(count)
					var/test = pick(tlist)
					var/spawnmat = pick(skinlist)
					var/obj/A = new spawnmat
					A.loc = test
					count--
				var/obj/alchmat = pick(alchemyparts)
				var/obj/B = new alchmat.type
				B.loc = pick(tlist)
				S.expgain(masterylevel*10)
				del(src)
				break
		usr<<"You lack the skill to skin this!"
	proc/GenerateCross(var/text as text)
		var/obj/A  = new
		A.name = "Grave"
		A.desc = "[text]"
		A.loc = locate(src.x,src.y,src.z)
		var/gravecon
		plane = 3
		gravecon = pick(1,2,3,4,5)
		switch(gravecon)
			if(1)
				A.icon = 'Graves.dmi'
				A.icon_state = "1"
			if(2)
				A.icon = 'Graves.dmi'
				A.icon_state = "2"
			if(3)
				A.icon = 'Graves.dmi'
				A.icon_state = "3"
			if(4)
				A.icon = 'Graves.dmi'
				A.icon_state = "4"
			if(5)
				A.icon = 'Graves.dmi'
				A.icon_state = "5"

mob/proc/GenerateCorpse()
	var/obj/mobCorpse/A = new
	A.loc = loc
	A.name = "[name]'s Corpse"
	A.icon = icon
	A.icon_state = "KO"
	A.overlays += icon('Bloody body.dmi',"KO")
	A.overlays += overlays
	if(skinlevel)
		A.masterylevel=skinlevel
	A.skinlist+=skinlist