mob/proc/Deoccupy()
	if(med)
		to_chat(usr, "You stop meditating.")
		if(Savable) icon_state=""
		med=0
		deepmeditation=0
		//canfight=1
	if(train)
		to_chat(usr, "You stop training.")
		if(Savable) icon_state=""
		train=0
		//canfight=1
	if(usr.fishing)
		to_chat(usr, "You stop fishing.")
		fishing=0
		for(var/obj/bobber/B in view())
			if(B.ownersig == signature) del(B)
	if(dig)
		to_chat(usr, "You stop digging.")
		dig=0
	if(dig)
		to_chat(usr, "You stop digging.")
		dig=0
	if(is_drawing)
		powermovetimer+=1