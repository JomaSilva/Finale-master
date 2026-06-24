/*for reference
mob/npc/pet
	var
		default_title = "Master"
		use_name = 0
		shutup = 0
		attackcatch = list("HIYA!","Get bent!","HA!", "You should have never come here!","Aww, did someone steal your sweetroll?")
		idlecatch = list("Boooored...","*sighs*","Five six seven eight...","%M%, are we going to do anything?")
		followcatch = list("Where are we going, %M%?","What a interesting place...")
		angercatch = list("GOD DAMN IT!")*/

mob/npc/pet
	proc
		catch_to_text(msg)
			if(isnull(owner_ref))
				return replacetext(msg,"%M%","[default_title]")
			if(use_name == 0)
				msg = replacetext(msg,"%M%","[default_title]")
			else msg = replacetext(msg,"%M%","[owner_ref.name]")

		random_catch()
			if(IsInFight)
				if(attackcatch.len >= 1)
					. = rand(1,attackcatch.len)
					sayType(attackcatch[.],3)
			else if(Anger>(((MaxAnger-100)/1.66)+100))
				if(angercatch.len >= 1)
					. = rand(1,angercatch.len)
					sayType(angercatch[.],3)
			else if(is_following)
				if(followcatch.len >= 1)
					. = rand(1,followcatch.len)
					sayType(followcatch[.],3)
			else
				if(idlecatch.len >= 1)
					. = rand(1,idlecatch.len)
					sayType(idlecatch[.],3)
		edit_catch_list(var/list/L)
			var/list/flavorlists = list()
			selectflavor
			flavorlists -= flavorlists
			flavorlists += "Add Catch"
			flavorlists += "Remove Catch"
			flavorlists += "Done"
			flavorlists += L
			switch(input(usr,"Select Item")as anything in flavorlists)
				if("Add Catch")
					L += input(usr,"Type in the catchphrase. Use '%M%' to designate the master's name or title.")
				if("Remove Catch")
					flavorlists -= flavorlists
					flavorlists += "Done"
					flavorlists += L
					var/choice = input(usr,"Which one to remove?")as anything in flavorlists
					if(choice!="Done")
						L-=choice
				if("Done")
					return L
			goto selectflavor
		
		sync_catch()
			comp_obj_ref.default_title = default_title
			comp_obj_ref.use_name = use_name
			comp_obj_ref.shutup = shutup
			comp_obj_ref.attackcatch = attackcatch
			comp_obj_ref.idlecatch = idlecatch
			comp_obj_ref.followcatch = followcatch
			comp_obj_ref.angercatch = angercatch