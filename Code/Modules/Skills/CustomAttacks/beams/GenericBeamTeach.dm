/obj/skill/CustomAttacks/ki/beam/Beam/Teach(var/mob/target)
	if(target:HasSkill(/datum/skill/CustomAttacks/ki/beam/Beam))
		target:teachBeam(savant)
		return












	/*var/tmp/learned = 0
	for(var/datum/skill/nS in savant.learned_skills)
		if(nS==/datum/skill/CustomAttacks/ki/beam/Beam)
			learned = 1
			break
	if(!learned)
		if(target.Study(/datum/skill/CustomAttacks/ki/beam/Beam,savant))
		else
			savant << "Teaching attempt failed!"
			target << "Teaching attempt failed!"
			return FALSE
	savant << "Copying custom skill..."
	target << "Copying custom skill..."
	var/tmp/alreadyknow = 0
	for(var/obj/skill/CustomAttacks/ki/beam/Beam/nS in savant.customattacks)
		if(nS.name==src.name)
			alreadyknow = 1
			break
	if(alreadyknow)
		savant << "Teaching attempt failed! (You already know this skill!)"
		target << "Teaching attempt failed! (You already know this skill!)"
	else
		if(EnoughPoints((learncost - defaultlearncost + 1),target))
			if(target.createdbeamamount>=target.maxcreatedbeamamount)
				target <<"Your maximum beam count is [target.maxcreatedbeamamount]! You currently have [target.createdbeamamount]! Delete a few old beams."
				return FALSE
			var/obj/skill/CustomAttacks/ki/beam/Beam/A = new/obj/skill/CustomAttacks/ki/beam/Beam
			A = src
			A.savant = target
			target.contents += A
			target.customattacks += A
			if(target.createdbeamamount&&A.name=="Beam")
				A.name = "Beam [target.createdbeamamount]"
				A.storedname = "Beam [target.createdbeamamount]"
			target.createdbeamamount+=1
			for(var/obj/skill/CustomAttacks/ki/beam/Beam/S in usr.contents)
				S.Update()
			target << "Created [A]!"
			target.allocatedpoints -= (learncost - defaultlearncost + 1) //you allocate at least 1 skillpoint upon learning - learning it this way is therefore more inefficient on allocated points, but easier
		else
			savant << "Teaching attempt failed! (Target doesn't have enough skillpoints! Cost is [(learncost - defaultlearncost + 1)])"
			target << "Teaching attempt failed! (You don't have enough skillpoints! Cost is [(learncost - defaultlearncost + 1)])"*/