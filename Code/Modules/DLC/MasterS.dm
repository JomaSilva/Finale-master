obj/MSPedestal
	name="Pedestal"
	icon='msword.dmi'
	icon_state="pedestal"
	pixel_x = -56
	pixel_y = -48
	density=1
	IsntAItem=1
	canGrab=0
	SaveItem=1
	Bolted=1
	New()
		..()
		for(var/obj/MSPedestal/A in world)
			if(A.type == type&&A!=src)
				del(A)
		ticksword()
	proc/ticksword()
		if(!hasSword)
			overlays.Cut()
			var/obj/A = new
			A.icon = icon('msword.dmi',"noswordoverlay")
			A.plane = AURA_LAYER + 1
			overlays += A
		if(hasSword)
			overlays.Cut()
			var/obj/A = new
			A.icon = icon('msword.dmi',"swordoverlay")
			A.plane = AURA_LAYER + 1
			overlays += A
	verb
		Description()
			set src in oview(1)
			set category = null
			usr<<"The shrine created to hold a sword. A mysterious power echoes from it."
			if(!hasSword)
				usr<<"The pedestal has nothing inside of it."
				ticksword()
			if(hasSword)
				usr<<"The pedestal has a mysterious sword laying within it. Holy power emanates from the sword."
				ticksword()
		Return_Sword()
			set src in oview(1)
			set category = null
			if(hasSword==1)
				usr<<"The Master Sword is already in the pedestal."
			else
				for(var/obj/items/Equipment/Weapon/Sword/Master_Sword/D in usr.contents)
					if(istype(D,/obj/items/Equipment/Weapon/Sword/Master_Sword) && !D.equipped)
						switch(alert(usr, "Are you sure? You won't be able to use the Master Sword anymore.","","Yes","No"))
							if("Yes")
								del(D)
								hasSword=1
								ticksword()
								view(usr)<<"The Master Sword is sheathed back into the pedestal, where it slumbers in wait once again..."
								emit_Sound('MasterEmeraldShine.wav')
								emit_Sound('landshort.ogg')
							else
								usr<<"You change your mind."
					else
						usr<<"You lack the Master Sword or its currently equipped."
		Take_Sword()
			set src in oview(1)
			set category = null
			if(hasSword==1)
				switch(alert(usr, "Are you sure?","","Yes","No"))
					if("Yes")
						usr<<"You grip the hilt of the sword and begin to pull with all your might..."
						usr.canmove-=1
						sleep(50)
						if(usr.MSWorthy)
							hasSword=0
							ticksword()
							var/obj/items/Equipment/Weapon/Sword/Master_Sword/A = new(locate(usr.x,usr.y,usr.z))
							var/hatcheck =0
							var/clothescheck =0
							var/obj/items/Equipment/Armor/Helmet/Heros_Cap/nH = locate(usr.contents)
							var/obj/items/Equipment/Armor/Body/Heros_Clothes/nHC = locate(usr.contents)
							if(nH) hatcheck = 1
							if(nHC) clothescheck = 1
							if(!hatcheck)
								var/obj/items/Equipment/Armor/Helmet/Heros_Cap/nC = new(locate(usr.x,usr.y,usr.z))
								nC.Move(usr)
							if(!clothescheck)
								var/obj/items/Equipment/Armor/Body/Heros_Clothes/nC = new(locate(usr.x,usr.y,usr.z))
								nC.Move(usr)
							A.Get()
							usr.updateOverlay(/obj/overlay/effects/flickeffects/mshenshin)
							usr.emit_Sound('landshort.ogg')
							view(usr) << "[usr] pulls the Master Sword from the pedestal!"
							usr.canmove+=1
							usr.mastery_enable(/datum/mastery/Artifact/Soul_of_the_Hero)
							for(var/datum/mastery/Artifact/Soul_of_the_Hero/S in usr.masteries)
								S.visible=1
						else
							usr<<"Despite your best efforts, the Sword remains still inside its pedestal..."
							usr.canmove+=1
			else
				usr<<"The pedestal is empty. There's nothing to take."

obj/overlay/effects/flickeffects/mshenshin/EffectStart()
	var/icon/I = icon('beamaxis.dmi')
	pixel_x = round(((32 - I.Width()) / 2),1)
	pixel_y = round(((32 - I.Height()) / 2),1)
	icon = I
	icon += rgb(0,0,50)
	..()
mob/npc/Enemy/Bosses
	Ancient_Guardian
		icon = 'NewPaleMale.dmi'
		New()
			..()
			overlays += 'Clothes_GiBottom.dmi'
			overlays += 'Clothes_Boots.dmi'
			overlays += 'Phoenix Full (Negative Makyo).dmi'
			overlays += 'Clothes_Hooded Cloak 2.dmi'
		strafeAI = 1
		kidef = 50
		physdef = 10
		physoff = 10
		technique = 8
		speed = 6
		zanzoAI = 1


/obj/SacredGroveGate
	name = "Strange Light"
	icon = 'Spirit.dmi'
	density = 0
	canGrab=0
	IsntAItem=1
	pixel_x = 0
	pixel_y = 0
	mouse_opacity = 1
	Crossed(atom/movable/Obstacle)
		if(ismob(Obstacle))
			var/mob/M = Obstacle
			var/area/targetArea
			targetArea = "Earth"
			var/turf/temploc = pickTurf(targetArea,1)
			M.loc = (locate(temploc.x,temploc.y,temploc.z))