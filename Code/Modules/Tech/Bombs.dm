obj/Creatables
	Nuke
		icon = 'Lab.dmi'
		icon_state = "Tool2"
		cost=2000000
		neededtech=90
		desc = "Nukes are very destructive, very big blasts. They absolutely eradicate terrain. Creating one also creates toxic waste."
		create_type = /obj/items/Bomb/Nuke
		do_toxic_waste = 1

	Toxic_Waste
		icon = 'toxicwastebarrel.dmi'
		cost=50000
		neededtech=50
		create_type = /obj/items/Toxic_Waste
		desc = "Toxic Waste is, well, toxic waste. It doesn't really have a use... You won't fling it near anyone, right!? That's not how it works!!"
	Smoke_Bomb
		icon = 'Smoke Bomb.dmi'
		cost=1500
		neededtech=20
		create_type = /obj/items/Smoke_Bomb
		desc = "Smoke bombs don't do any damage. They are annoying though, and they create smoke that lasts for like, 20 seconds. They're also really bad on my sinuse- Don't you fucking buy them, you little shit!"
obj/items/Bomb
	icon = 'Lab.dmi'
	stackable=1
	IsntAItem=1 //make sure to remove this on children (like Nuke) so that admins can spawn 'em.
	icon_state = "Tool2"
	var/strength = 10 //expressed BP of explosion
	var/strengthMod = 1
	var/radius = 2 //radius
	var/radioactive = 0 //chance of mutation
	var/gibbify = 0 //damage limbs
	var/explosionIcon = 'Explosion12013.dmi' //explosion does the centering inhouse, no worries here.
	var/code = "1234 Bravo" //default code for detonators
	var/countdown
	var/isCanceled
	var/running
	proc/explode()
		set background = 1
		view(src)<<"The [src] goes off!"
		if(radius >= 5)
			emit_Sound('explosion.wav')
		var/obj/explosions/nE = spawnExplosion(GetTurf(),explosionIcon,strength,radius)
		if(isobj(nE))
			if(radioactive)
				nE.radioactive = 1
			if(gibbify)
				nE.gibbify = 1
		del(src)

	New()
		..()
		code = "[rand(1,30)][rand(1,9)][rand(1,100)][rand(1,50)]"

	verb/Upgrade()
		set category = null
		set src in view(1)
		switch(input(usr,"Bring me to [usr.intBPcap * strengthMod] strength (from [strength]?) It'll cost ya [log(usr.intBPcap)*60000] zenni.") in list("Okay","Cancel"))
			if("Okay")
				if(usr.zenni >= log(usr.intBPcap)*60000)
					usr.zenni -= log(usr.intBPcap)*60000
					strength = usr.intBPcap * strengthMod
					usr<<"[src]: Done!"

	verb/Set()
		set category=null
		set src in view(1)
		code = input(usr,"Set the code. Any detonator with this code can set this off.","",code) as text
		countdown = input(usr,"Set the countdown in seconds. Detonators can't cancel bombs at a distance.") as num
	verb/Cancel()
		set category=null
		set src in view(1)
		isCanceled=1
		sleep(30)
		isCanceled=0
		return
	verb/Use()
		set category=null
		set src in view(1)
		if(running)
			isCanceled=1
			sleep(30)
			isCanceled=0
			return
		spawn while(countdown)
			sleep(10)
			countdown-=1
			running = 1
			if(isCanceled)
				isCanceled=0
				running = 0
				return
			if(countdown<=0)
				countdown=0
				running=0
				isCanceled=0
				explode()


	Nuke
		IsntAItem=0
		strength = 100
		radius = 35
		strengthMod = 2
		radioactive = 1
		gibbify = 1
		explosionIcon = 'explosionnuke.dmi'

	EMP
		IsntAItem=0
		strength = 50
		radius = 8
		strengthMod = 0.5
		radioactive = 0
		gibbify = 0
		explode()
			set background = 1
			view(src)<<"[src] goes off!"
			spawnExplosionType(/obj/explosions/EMPBoom,strength,GetTurf(),radius)
			del(src)
	Sonic_Bomb
		IsntAItem=0
		strength = 50
		radius = 5
		strengthMod = 0.5
		radioactive = 0
		gibbify = 0
		explode()
			set background = 1
			view(src)<<"[src] goes off!"
			spawnExplosionType(/obj/explosions/SonicBoom,strength,GetTurf(),radius)
			del(src)
	C4
		IsntAItem=0
		strength = 50
		radius = 10
		radioactive = 0
		gibbify = 0
		Upgrade()
			set category = null
			set src in view(1)
			switch(input(usr,"Change: Radius, Strength, Radioactive, or Gibbify.") in list("Radius", "Strength","Radioactive","Gibbify","Cancel"))
				if("Radius")
					if(alert(usr,"Extend radius? It'll cost ya 100k zenni.","","Yes")=="Yes")
						if(radius==15)
							usr << "[src]: Already got 15 radius from 10, chief."
							return
						if(usr.zenni >= 100000)
							usr.zenni -= 100000
							radius = 15
							usr<<"[src]: Done!"
						else
							usr<<"[src]: Not enough cash."
				if("Radioactive")
					if(alert(usr,"Make me radioactive? It'll cost ya 60k zenni (and produce some nasty waste!)","","Yes")=="Yes")
						if(radioactive)
							usr << "[src]: Already radioactive, chief."
							return
						if(usr.zenni >= 60000)
							usr.zenni -= 60000
							radioactive = 1
							new/obj/items/Toxic_Waste(src.loc)
							usr<<"[src]: Done!"
						else
							usr<<"[src]: Not enough cash."
				if("Gibbify")
					if(alert(usr,"Make me send out shrapnel that damages limbs? It'll cost ya 50k zenni.","","Yes")=="Yes")
						if(gibbify)
							usr << "[src]: Already loaded with nasty sharp bits, chief."
							return
						if(usr.zenni >= 50000)
							usr.zenni -= 50000
							gibbify = 1
							usr<<"[src]: Done!"
						else
							usr<<"[src]: Not enough cash."
				if("Strength")
					if(alert(usr,"Bring me to [usr.intBPcap * strengthMod] strength (from [strength]?) It'll cost ya [log(usr.intBPcap)*60000] zenni.","","Yes")=="Yes")
						if(usr.zenni >= log(usr.intBPcap)*60000)
							usr.zenni -= log(usr.intBPcap)*60000
							strength = usr.intBPcap * strengthMod
							usr<<"[src]: Done!"
						else
							usr<<"[src]: Not enough cash."
	Mines
		New()
			..()
			spawn Ticker()
		proc/Ticker()
			set background = 1
			for(var/mob/M in view(1))
				if(proprietor!=M.ckey&&isset)
					icon = savedicon
					explode()
				break
			spawn(5) Ticker()

		var/isset
		var/savedicon = null
		Set()
			set category=null
			set src in usr
			code = input(usr,"Set the code. Any detonator with this code can set this off.","",code) as text
		Cancel()
			set category=null
			set src in usr
			isset = 0
			view(usr) <<"[src]: No longer canceled!"
			icon = savedicon
		Use()
			set category=null
			set src in usr
			isset = 1
			savedicon = icon
			icon = null
			view(usr) <<"[src]: Set!"

		Mine_EMP
			IsntAItem=0
			strength = 50
			radius = 8
			strengthMod = 0.5
			radioactive = 0
			gibbify = 0
			explode()
				set background = 1
				view(src)<<"[src] goes off!"
				spawnExplosionType(/obj/explosions/EMPBoom,strength,GetTurf(),radius)
				del(src)
		Mine_Sonic
			IsntAItem=0
			strength = 50
			radius = 5
			strengthMod = 0.5
			radioactive = 0
			gibbify = 0
			explode()
				set background = 1
				view(src)<<"[src] goes off!"
				spawnExplosionType(/obj/explosions/SonicBoom,strength,GetTurf(),radius)
				del(src)
		Mine
			IsntAItem=0
			strength = 50
			radius = 10
			radioactive = 0
			gibbify = 0
			Upgrade()
				set category = null
				set src in view(1)
				switch(input(usr,"Change: Radius, Strength, Radioactive, or Gibbify.") in list("Radius", "Strength","Radioactive","Gibbify","Cancel"))
					if("Radius")
						if(alert(usr,"Extend radius? It'll cost ya 100k zenni.","","Yes")=="Yes")
							if(radius==15)
								usr << "[src]: Already got 15 radius from 10, chief."
								return
							if(usr.zenni >= 100000)
								usr.zenni -= 100000
								radius = 15
								usr<<"[src]: Done!"
							else
								usr<<"[src]: Not enough cash."
					if("Radioactive")
						if(alert(usr,"Make me radioactive? It'll cost ya 60k zenni (and produce some nasty waste!)","","Yes")=="Yes")
							if(radioactive)
								usr << "[src]: Already radioactive, chief."
								return
							if(usr.zenni >= 60000)
								usr.zenni -= 60000
								radioactive = 1
								new/obj/items/Toxic_Waste(src.loc)
								usr<<"[src]: Done!"
							else
								usr<<"[src]: Not enough cash."
					if("Gibbify")
						if(alert(usr,"Make me send out shrapnel that damages limbs? It'll cost ya 50k zenni.","","Yes")=="Yes")
							if(gibbify)
								usr << "[src]: Already loaded with nasty sharp bits, chief."
								return
							if(usr.zenni >= 50000)
								usr.zenni -= 50000
								gibbify = 1
								usr<<"[src]: Done!"
							else
								usr<<"[src]: Not enough cash."
					if("Strength")
						if(alert(usr,"Bring me to [usr.intBPcap * strengthMod] strength (from [strength]?) It'll cost ya [log(usr.intBPcap)*60000] zenni.","","Yes")=="Yes")
							if(usr.zenni >= log(usr.intBPcap)*60000)
								usr.zenni -= log(usr.intBPcap)*60000
								strength = usr.intBPcap * strengthMod
								usr<<"[src]: Done!"
							else
								usr<<"[src]: Not enough cash."

obj/items
	Toxic_Waste
		icon = 'toxicwastebarrel.dmi'
		fragile = 1
		New()
			..()
		proc/Ticker()
			set background = 1
			for(var/mob/M in view(1))
				if(prob(1))
					M.Mutations+=1
			spawn(10) Ticker()
		Del()
			view(src)<<"[src] goes off!"
			spawnExplosionType(/obj/explosions/ToxicBoom,10,GetTurf(),3)
			..()

obj/items
	Smoke_Bomb
		icon = 'Smoke Bomb.dmi'
		fragile = 1
		verb/Use()
			set category = null
			set src in usr
			view(usr)<<"[usr] uses [src]"
			del(src)
		Del()
			view(src)<<"[src] goes off!"
			spawnExplosionType(/obj/explosions/SmokeBoom,0,GetTurf(),0)
			..()