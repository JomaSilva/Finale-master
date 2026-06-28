//This is the basic setup for a party system. For now, its primary purpose will be controlling friendly fire in fights. Later on it could tie into the contacts system or something.

mob/var/list/Party=new/list()
mob/var/fftoggle=0

mob/verb/Add_to_Party(mob/M in player_list)
	set category="Other"
	var/members=0
	for(var/A in Party) members+=1
	if(members<4)
		if(M.client)
			var/disapproved
			for(var/A in Party)
				if(A==M.name) disapproved=1
			if(usr==M)
				disapproved=1
			if(!disapproved)
				Party+=M.name
				to_chat(usr, "You added [M.name] to your party")
			else
				to_chat(usr, "[M.name] is already in your party, or you are [M.name]!")
	else to_chat(usr, "You can only have 4 party members.")

mob/verb/Remove_from_Party(M in Party)
	set category="Other"
	if(M)
		Party-=M
		to_chat(usr, "You removed [M] from your party")
	else
		to_chat(usr, "You have not made a party!")
mob/verb/Toggle_Friendly_Fire()
	set category ="Other"
	if(usr.fftoggle==0)
		usr.fftoggle=1
		to_chat(usr, "You will now harm your party.")
	else if(usr.fftoggle==1)
		usr.fftoggle=0
		to_chat(usr, "You will not harm your party.")