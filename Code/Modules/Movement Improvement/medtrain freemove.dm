mob/proc/Deoccupy()
	if(med)
		usr<<"You stop meditating."
		if(Savable) icon_state=""
		med=0
		deepmeditation=0
		//canfight=1
	if(train)
		usr<<"You stop training."
		if(Savable) icon_state=""
		train=0
		//canfight=1
	if(usr.fishing)
		usr<<"You stop fishing."
		fishing=0
		for(var/obj/bobber/B in view())
			if(B.ownersig == signature) del(B)
	if(dig)
		usr<<"You stop digging."
		dig=0
	if(dig)
		usr<<"You stop digging."
		dig=0
	if(is_drawing)
		powermovetimer+=1