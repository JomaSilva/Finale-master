obj/Creatables
	Ammo
		icon='GUNS.dmi'
		icon_state="Ammo"
		cost=200
		neededtech=5 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "A single ammo box will reload a weapon with its maximum capacity of rounds. Blasters don't need this"
		create_type = /obj/items/Ammo
	Handgun
		icon='GUNS.dmi'
		icon_state="Handgun"
		cost=500
		neededtech=6 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Handguns are slow firing, relatively weak ranged weapons for those who are Ki deficient."
		create_type = /obj/items/Guns/Handgun
	SMG
		icon='GUNS.dmi'
		icon_state="SMG"
		cost=500
		neededtech=6 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "SMGs are faster than Handguns, but deal less base damage."
		create_type = /obj/items/Guns/SMG
	Rifle
		icon='GUNS.dmi'
		icon_state="Rifle"
		cost= 500
		neededtech=6 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Slower than a SMG, but loads of range and damage."
		create_type = /obj/items/Guns/Rifle
	Rocket_Launcher
		icon='GUNS.dmi'
		icon_state="Rocket Launcher"
		cost=500
		neededtech=6 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "Small clip size, small range... but loads of damage. Long reload time."
		create_type = /obj/items/Guns/Rocket_Launcher
	Shotgun
		icon='GUNS.dmi'
		icon_state="Shotgun"
		cost=500
		neededtech=6 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "For those with DAKKA issues. You may romantically call this the Boomstick."
		create_type = /obj/items/Guns/Shotgun
	Blaster
		icon='Ki_Blaster.dmi'
		icon_state=""
		cost=1200
		neededtech=12 //Deletes itself from contents if the usr doesnt have the needed tech
		desc = "A Ki based solution to the DAKKA deficient."
		create_type = /obj/items/Guns/Blaster
	G_Blaster
		name="Gaster Blaster"
		icon='gblaster.dmi'
		icon_state=""
		cost=3400
		neededtech=99
		desc = "DUN DAH DUN DUN DUH DUN DA... *guitar riff* Basically a better blaster. This is only in the game because Sans got into Smash."
		create_type = /obj/items/Guns/G_Blaster

obj/items
	Ammo
		icon='GUNS.dmi'
		icon_state="Ammo"

obj/items/Guns
	stackable=0
	icon='GUNS.dmi'
	icon_state="Handgun"
	var/fireType = "Physical"
	var/ammo=200
	var/power=2
	var/powerlevel=500 //intBP of upgrader
	var/refire=5
	var/maxammo=200
	var/BlasterR=0
	var/BlasterG=0
	var/BlasterB=0
	var/reserve=10
	var/maxreserve=10
	var/critical=1
	var/failure=1 //Sometimes the shot fails, 50% of the time.
	var/knockback //Can make it a knockback shot
	var/stun //Can make it a stun shot
	var/BulletIcon='23.dmi'
	var/BulletState="23"
	var/shotsound = 'riflelight.ogg'

	New()
		..()
		spawn Ticker()
		if(fireType=="Physical") suffix="[ammo]"

	proc/Ticker()
		set background = 1
		spawn(10) Ticker()

	verb/Info()
		set src in oview(1)
		set category=null
		if(fireType=="Energy") usr<<"Energy: [reserve] / [maxreserve]"
		else usr<<"Ammo: [ammo] / [maxammo]"
		usr<<"Force: [power*powerlevel]"
		usr<<"Refire: [refire]"
		usr<<"Failure Chance: [round(20/failure)]%"
		usr<<"Critical Hit: [critical]%"
		if(knockback) usr<<"Knockback feature installed."
		if(stun) usr<<"Stun feature installed."
		usr<<"Cost to make: [techcost]z"

	verb/fire()
		set name="Shoot"
		set category="Skills"
		set src in usr
		Shoot(usr)

	proc/Shoot(var/mob/UsingMob) if(ismob(UsingMob))
		if(!UsingMob.med&&!UsingMob.train&&!UsingMob.KO&&!UsingMob.blasting)
			if(ammo)
				UsingMob.blasting=1
				usr.emit_Sound(shotsound,0.33)
				var/obj/attack/blast/A=new/obj/attack/blast
				A.loc=locate(UsingMob.x,UsingMob.y,UsingMob.z)
				A.icon=BulletIcon //'Blasts.dmi'
				A.icon_state=BulletState //"Bullet"
				A.density=1
				A.avoidusr=1
				A.physdamage = 1
				A.mods = power
				A.murderToggle=usr.murderToggle
				A.BP=powerlevel
				if(knockback) A.shockwave=1
				if(stun) A.paralysis=1
				if(prob(critical))
					A.BP*=10
				walk(A,UsingMob.dir)
				ammo-=1
				suffix="[ammo]"
				spawn(refire)
				UsingMob.blasting=0
				if(ammo<1) UsingMob<<"Out of ammo, reload."
	Click()
		Shoot(usr)
	verb/Reload()
		set category=null
		if(fireType=="Energy")
			usr<<"You don't need to reload."
			return
		for(var/obj/items/Ammo/A in usr.contents)
			ammo=maxammo
			suffix="[ammo]"
			del(A)
			break
		if(ammo!=maxammo) usr<<"You do not have any more ammo to reload with."
		else
			view(usr) <<"[usr] reloads [src]"
	verb/Icon()
		set category = null
		set src in usr
		switch(input(usr,"GUN ICON: Default or custom?","","default") in list("default","custom","cancel"))
			if("custom")
				icon = input(usr,"Input gun icon.","",'GUNS.dmi') as icon
			if("default")
				icon = 'GUNS.dmi'
				icon_state="Handgun"
		switch(input(usr,"BULLET ICON: Default or custom?","","default") in list("default","custom","cancel"))
			if("custom")
				BulletIcon = input(usr,"Input gun icon.","",'GUNS.dmi') as icon
				BulletState = input(usr,"Input gun state (blank if none.)","Input gun state (blank if none.)","") as text
			if("default")
				BulletIcon='23.dmi'
				BulletState="23"

	verb/Upgrade()
		set src in view(1)
		set category=null
		if(usr.KO) return
		var/cost=0
		var/list/Choices=new/list
		Choices.Add("Cancel")
		if(usr.zenni>=10*maxreserve&&fireType=="Energy") Choices.Add("Energy Reserve ([10*maxreserve]z)")
		if(usr.zenni>=10000) Choices.Add("Force (10000z)")
		if(usr.zenni>=5*maxreserve&&fireType=="Energy") Choices.Add("Energy Refill ([5*maxreserve]z)")
		if(usr.zenni>=500*critical&&critical<20*usr.techmod) Choices.Add("Critical Chance ([500*critical]z)")
		if(usr.zenni>=2000) Choices.Add("Knockback effect (2000z)")
		if(usr.zenni>=3000) Choices.Add("Stun effect (3000z)")
		var/A=input("Upgrade what?") in Choices
		if(A=="Cancel") return
		if(A=="Critical Chance ([500*critical]z)")
			cost=500*critical
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Critical hit chance increased."
			critical+=1
		if(A=="Energy Refill ([5*maxreserve]z)")
			cost=10*maxreserve
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Energy fully restored."
			reserve=maxreserve
		if(A=="Energy Reserve ([10*maxreserve]z)")
			cost=10*maxreserve
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Energy Reserve increased. Energy fully restored."
			maxreserve*=2
			reserve=maxreserve
		if(A=="Force (10000z)")
			cost=10*power
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Force increased."
			powerlevel=usr.intBPcap
		if(A=="Knockback effect (2000z)")
			cost=2000
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Knockback feature added."
			knockback=1
		if(A=="Stun effect (3000z)")
			cost=3000
			if(usr.zenni<cost)
				usr<<"You do not have enough money ([cost]z)"
				return
			usr<<"Stun feature added."
			stun=1
		usr<<"Cost: [cost]z"
		usr.zenni-=cost

		tech+=1
		techcost+=cost
	Handgun
		icon='GUNS.dmi'
		icon_state="Handgun"
		ammo=30
		power=1
		powerlevel=2
		refire=10
		maxammo=30
		BulletIcon='Bullet.dmi'
		BulletState=""
		shotsound = 'handgunheavy.ogg'
		New()
			..()
			suffix="[ammo]"
	SMG
		icon='GUNS.dmi'
		icon_state="SMG"
		BulletIcon='Bullet.dmi'
		BulletState=""
		ammo=200
		power=1
		powerlevel=3
		refire=5
		maxammo=200
		shotsound = 'riflelight.ogg'
	Shotgun
		icon='GUNS.dmi'
		icon_state="Shotgun"
		BulletIcon='Bullet 3.dmi'
		BulletState=""
		ammo=6
		power=2
		powerlevel=5
		refire=25
		maxammo=6
		shotsound = 'shotgun.ogg'
		Click()
			if(!usr.med&&!usr.train&&!usr.KO&&!usr.blasting)
				if(ammo)
					usr.emit_Sound(shotsound,0.33)
					usr.blasting=1
					var/obj/attack/blast/A=new/obj/attack/blast/
					A.loc=locate(usr.x,usr.y,usr.z)
					A.icon=BulletIcon
					A.icon_state=BulletState
					A.density=1
					A.physdamage = 1
					A.avoidusr=1
					A.mods = power
					A.BP=powerlevel
					if(knockback) A.shockwave=1
					if(stun) A.paralysis=1
					if(prob(critical))
						A.BP*=10
					walk(A,usr.dir)
					var/obj/B=new/obj/attack/blast
					B.loc=locate(usr.x,usr.y,usr.z)
					B.icon=BulletIcon
					B.icon_state=BulletState
					B.density=1
					B.mods = power
					B.avoidusr=1
					B.physdamage = 1
					B.BP=powerlevel
					if(knockback) B.shockwave=1
					if(stun) B.paralysis=1
					if(prob(critical))
						B.BP*=10
					step(B,turn(usr.dir,45))
					if(B) walk(B,usr.dir)
					var/obj/C=new/obj/attack/blast
					C.loc=locate(usr.x,usr.y,usr.z)
					C.icon=BulletIcon
					C.icon_state=BulletState
					C.density=1
					C.avoidusr=1
					C.physdamage = 1
					C.mods = power
					C.BP=powerlevel
					if(knockback) C.shockwave=1
					if(stun) C.paralysis=1
					if(prob(critical))
						C.BP*=10
					step(C,turn(usr.dir,-45))
					if(C) walk(C,usr.dir)
					ammo-=1
					suffix="[ammo]"
					spawn(refire)
					usr.blasting=0
					if(ammo<1) usr<<"Out of ammo, reload."
	Rifle
		icon='GUNS.dmi'
		icon_state="Rifle"
		ammo=20
		power=1
		powerlevel=5
		refire=20
		maxammo=20
		BulletIcon='Bullet.dmi'
		BulletState=""

	Rocket_Launcher
		icon='GUNS.dmi'
		icon_state="Rocket Launcher"
		ammo=5
		power=4
		powerlevel=50
		refire=50
		maxammo=5
		BulletIcon='Missile.dmi'
		BulletState=""
		shotsound = 'RPGshot.ogg'
	Blaster
		New()
			..()
			BlasterR=rand(0,255)
			BlasterG=rand(0,255)
			BlasterB=rand(0,255)
		icon='Ki_Blaster.dmi'
		fireType = "Energy"
		BulletIcon='23.dmi'
		power=2
		powerlevel=100
		BulletState="23"
		shotsound = 'rifleheavy.ogg'
		Click()
			set category=null
			if(!usr.med&&!usr.train&&!usr.KO&&!usr.blasting&&reserve>=1)
				usr.blasting=1
				var/obj/attack/blast/A=new/obj/attack/blast/
				usr.emit_Sound(shotsound,volume=0.33)
				A.loc=locate(usr.x,usr.y,usr.z)
				A.icon=BulletIcon
				A.icon_state=BulletState
				A.icon+=rgb(BlasterR,BlasterG,BlasterB)
				A.density=1
				if(knockback) A.shockwave=1
				if(stun) A.paralysis=1
				A.mods = power
				A.physdamage = 0
				A.BP=powerlevel
				A.avoidusr=1
				A.murderToggle=0
				if(prob(critical))
					A.BP*=10
				walk(A,usr.dir)
				reserve-=1
				spawn(100/refire)
				usr.blasting=0
				if(reserve<1) usr<<"[src]: Out of energy!"
	G_Blaster
		icon='gblaster.dmi'
		fireType = "Ki"
		BulletIcon='gblaster.dmi'
		power=2.5
		powerlevel=10000
		BulletState="blast"
		shotsound = 'rifleheavy.ogg'
		Click()
			set category=null
			if(!usr.med&&!usr.train&&!usr.KO&&!usr.blasting&&usr.Ki>=10 * usr.BaseDrain)
				usr.blasting=1
				usr.Ki -= 10 * usr.BaseDrain
				var/obj/attack/blast/A=new/obj/attack/blast/
				usr.emit_Sound(shotsound,0.33)
				A.loc=locate(usr.x,usr.y,usr.z)
				A.icon=BulletIcon
				A.icon_state=BulletState
				A.density=1
				if(knockback) A.shockwave=1
				if(stun) A.paralysis=1
				A.mods = power
				A.physdamage = 0
				A.BP=powerlevel
				A.avoidusr=1
				A.murderToggle=0
				if(prob(critical))
					A.BP*=10
				walk(A,usr.dir)
				spawn(100/refire)
				usr.blasting=0