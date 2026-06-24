/obj/skill/CustomAttacks/ki/blast/Blast/Teach(var/mob/target)
	if(target:HasSkill(/datum/skill/CustomAttacks/ki/blast/Blast))
		target:teachBlast(savant)
		return

	/*var/tmp/learned = 0
	for(var/datum/skill/nS in savant.learned_skills)
		if(nS==/datum/skill/CustomAttacks/ki/blast/Blast)
			learned = 1
			break
	if(!learned)
		if(target.Study(/datum/skill/CustomAttacks/ki/blast/Blast,savant))
		else
			savant << "Teaching attempt failed!"
			target << "Teaching attempt failed!"
			return FALSE
	savant << "Copying custom skill..."
	target << "Copying custom skill..."
	var/tmp/alreadyknow = 0
	for(var/obj/skill/CustomAttacks/ki/blast/Blast/nS in savant.customattacks)
		if(nS.name==src.name)
			alreadyknow = 1
			break
	if(alreadyknow)
		savant << "Teaching attempt failed! (You already know this skill!)"
		target << "Teaching attempt failed! (You already know this skill!)"
	else
		if(EnoughPoints((learncost - defaultlearncost + 1),target))
			if(target.createdblastamount>=target.maxcreatedblastamount)
				target <<"Your maximum blast count is [target.maxcreatedblastamount]! You currently have [target.createdblastamount]! Delete a few old blasts."
				return
			var/obj/skill/CustomAttacks/ki/blast/Blast/A = new/obj/skill/CustomAttacks/ki/blast/Blast
			for(var/V in src.vars)
				A.vars[V] = src.vars[V]
			A.savant = target
			target.contents += A
			target.customattacks += A
			usr.createdblastamount+=1
			for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in usr.contents)
				S.Update()
			usr << "Created [A]!"
			target.allocatedpoints -= (learncost - defaultlearncost + 1) //you allocate at least 1 skillpoint upon learning - learning it this way is therefore more inefficient on allocated points, but easier
		else
			savant << "Teaching attempt failed! (Target doesn't have enough skillpoints! Cost is [(learncost - defaultlearncost + 1)])"
			target << "Teaching attempt failed! (You don't have enough skillpoints! Cost is [(learncost - defaultlearncost + 1)])"*/

/datum/skill/CustomAttacks/ki/blast/Blast/afterTeach(var/mob/Source)
	Source:teachBlast(savant)
	return

mob/proc/teachBlast(var/mob/Tm)
	if(Tm.createdblastamount>=Tm.maxcreatedblastamount)
		Tm <<"Your maximum blast count is [Tm.maxcreatedblastamount]! You currently have [Tm.createdblastamount]! Delete a few old blasts."
		return
	var/list/tempobjlist = list() //Code is lifted a bit from Yota (http://www.byond.com/forum/?post=164966, look at the bottom!)
	for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in src.contents)
		tempobjlist += S
	var/tempnumb
	for(var/S in tempobjlist)
		tempnumb+=1
	var/obj/skill/CustomAttacks/ki/blast/Blast/choice = input(src,"You can directly teach custom attacks. Teach which blast?")as null|anything in tempobjlist
	if(isnull(choice))
		src <<"No blast."
		Tm <<"[src] didn't give you any preset blasts."
		return
	else 
		var/obj/skill/CustomAttacks/ki/blast/Blast/A = new/obj/skill/CustomAttacks/ki/blast/Blast
		A = choice
		A.savant = Tm
		Tm.contents += A
		Tm.customattacks += A
		Tm.createdblastamount+=1
		for(var/obj/skill/CustomAttacks/ki/blast/Blast/S in Tm.contents)
			S.Update()
		Tm << "Created [A]!"