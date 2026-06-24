turf/Door
	Enter(mob/M)
		..()
		if(istype(M,/mob))
			if(M.KB) return
			if(icon_state=="Open"||icon_state=="Opening") return 1
			else
				if(icon_state=="Closed")
					if(password)
						if(M.client)
							var/skipguess
							for(var/obj/items/Key/K in M.contents)
								if(K.password.len >=1)
									if(password in K.password)
										skipguess = 1
										break
							if(skipguess)
								Open()
								return 1
							var/guess = input(M,"What's the password?") as text
							if(guess==password)
								Open()
								return 1
						else return
					else
						Open()
						density = 0
						opacity = 0
						return 1
		if(istype(M,/obj))
			if(icon_state=="Open") return 1
	Click()
		..()
		if(icon_state=="Closed")
			if(password)
				if(usr.client)
					var/skipguess
					for(var/obj/items/Key/K in usr.contents)
						if(K.password.len >=1)
							if(password in K.password)
								skipguess = 1
								break
					if(skipguess)
						Open()
						return 1
					else
						for(var/mob/M in view(15,src))
							if(M.client)
								M<<"**[usr] knocks on the door!**"
				else return
			else
				Open()
				return 1
		else
			Close()
	proc/Open()
		density=0
		opacity=0
		flick("Opening",src)
		icon_state="Open"
		spawn(50) Close()
	proc/Close()
		density=1
		opacity=1
		flick("Closing",src)
		icon_state="Closed"
	Door1
		density=1
		icon='Door1.dmi'
		New()
			..()
			icon_state="Closed"
			Close()
	Door2
		density=1
		icon='Door2.dmi'
		New()
			..()
			icon_state="Closed"
			Close()
	Door3
		density=1
		icon='Door3.dmi'
		New()
			..()
			icon_state="Closed"
			Close()
	Door4
		density=1
		icon='Door4.dmi'
		New()
			..()
			icon_state="Closed"
			Close()
	Door5
		density=1
		icon='Door5.dmi'
		New()
			..()
			icon_state="Closed"
			Close()
	Door6
		density=1
		icon='Door6.dmi'
		New()
			..()
			icon_state="Closed"
			Close()