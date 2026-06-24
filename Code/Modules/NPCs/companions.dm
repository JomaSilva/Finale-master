mob
	var/tmp/list/out_mobs = list()
obj/items/companion_obj
	name = "Capturer"
	icon = 'Companion.dmi'
	var
		linked_mob_type = null //we only store the mob type,
		linked_mob_name = null //we store the mob name
		linked_mob_icon = null //and we store the mob icon
		linked_mob_bp = 1 //we overwrite the mob with its bp and shit
		linked_mob_behavior = list(1,1,1,1) //will overwrite emotions with these values. this corrosponds to the modifiers in npc ai.
		linked_mob_relation = list() //will cause the mob to do things for you, and also anger
		linked_mob_intelligence = 1 //affects the abilities of the mob.
		linked_phys_statboost = 0
		linked_ki_statboost = 0
		linked_misc_statboost = 0
		linked_bp_mod = 1
		leveledup = 0

		linked_mob_lvl = 1 //for new abilities and allocating statboosts
		linked_mob_max_lvl = 10 //maximum level. Better rarity pets get bigger maximums.
		linked_mob_exp = 0 //exp to next level

		linked_mob_age = 0 //aging increases level and nothing else.
		last_sig = 0

		default_title = "Master"
		use_name = 0
		shutup = 0
		list/attackcatch = list("HIYA!","Get bent!","HA!", "You should have never come here!","Aww, did someone steal your sweetroll?")
		list/idlecatch = list("Boooored...","*sighs*","Five six seven eight...","%M%, are we going to do anything?")
		list/followcatch = list("Where are we going, %M%?","What a interesting place...")
		list/angercatch = list("GOD DAMN IT!")

		tmp
			mob/npc/pet/mob_reference = null
			mob/owner = null
			spmct
			first_BP
	New()
		..()
		if(!linked_mob_name && linked_mob_type)
			linked_mob_name = initial(linked_mob_type:name)//hail satan hail satan, could randomize these two bits if one wanted to.
			linked_mob_icon = initial(linked_mob_type:icon)//hail satan hail satan
			linked_mob_age = Year
		if(!isnull(linked_mob_name)) name = initial(name) + ": " + linked_mob_name
	proc
		gain_exp(n as num)
			linked_mob_exp += n
			while(linked_mob_exp >= 10 * linked_mob_lvl && linked_mob_lvl < linked_mob_max_lvl)
				linked_mob_exp -= 10*linked_mob_lvl
				.++
				levelup()
		levelup()
			leveledup++
			linked_mob_lvl++
			update_linked_mob()
			return

		toggle_out()
			if(mob_reference)
				remove_linked_mob()
			else
				add_linked_mob()
		upgrade_linked_mob_bp()
			if(owner)
				linked_mob_bp = max((AverageBP / BPSkew) * min(max(0.10,(AverageBP/owner.BP)),1) * max(1,log(2,linked_mob_lvl)) * (2/5),first_BP)
			else
				linked_mob_bp = max((AverageBP / BPSkew) * (2/5),first_BP)
			if(linked_mob_bp < first_BP*0.9) linked_mob_bp *= linked_bp_mod
			if(mob_reference) mob_reference.BP = linked_mob_bp
		update_linked_mob()
			if(isnull(mob_reference)) return
			mob_reference.BP = linked_mob_bp
			mob_reference.kiskill = initial(mob_reference.kiskill) + (linked_mob_intelligence)
			if(linked_phys_statboost)
				mob_reference.physoff = initial(mob_reference.physoff) + (linked_phys_statboost / 4)
				mob_reference.physdef = initial(mob_reference.physdef) + (linked_phys_statboost / 4)

			if(linked_ki_statboost)
				mob_reference.kioff = initial(mob_reference.kioff) + (linked_ki_statboost / 4)
				mob_reference.kidef = initial(mob_reference.kidef) + (linked_ki_statboost / 4)
				mob_reference.kiskill += (linked_ki_statboost / 8)
			if(linked_misc_statboost)
				mob_reference.technique = initial(mob_reference.technique) + (linked_misc_statboost / 4)
				mob_reference.speed = initial(mob_reference.speed) + (linked_misc_statboost / 4)
				mob_reference.magiskill = initial(mob_reference.magiskill) + (linked_misc_statboost / 4)

			mob_reference.techmod = linked_mob_intelligence
			mob_reference.name = linked_mob_name
			mob_reference.icon = linked_mob_icon
			mob_reference.relation = linked_mob_relation
			mob_reference.behavior_vals_m = linked_mob_behavior

		update_mob_link()
			if(isnull(mob_reference)) return
			linked_mob_name = mob_reference.name
			linked_mob_icon = mob_reference.icon
			linked_mob_relation = mob_reference.relation
			linked_mob_intelligence = mob_reference.techmod
			linked_mob_behavior = mob_reference.behavior_vals_m

		remove_linked_mob()
			if(isnull(mob_reference)) return
			linked_mob_name = mob_reference.name
			linked_mob_icon = mob_reference.icon
			linked_mob_relation = mob_reference.relation
			linked_mob_intelligence = mob_reference.techmod
			linked_mob_behavior = mob_reference.behavior_vals_m
			if(mob_reference.current_area)
				mob_reference.current_area.my_npc_list -= mob_reference
				mob_reference.current_area.my_mob_list -= mob_reference
			del(mob_reference)
			return TRUE

		add_linked_mob()
			var/goloc
			if(ismob(loc))
				owner = loc
				goloc = owner.loc
			else if(isturf(loc))
				goloc = loc
			else
				loc:GetTurf()
			first_BP = linked_mob_bp
			mob_reference = new linked_mob_type(goloc)
			update_linked_mob()
			mob_reference.cur_own_sig = last_sig
			mob_reference.comp_obj_ref = src
			mob_reference.default_title = default_title
			mob_reference.use_name = use_name
			mob_reference.shutup = shutup
			mob_reference.attackcatch = attackcatch
			mob_reference.idlecatch = idlecatch
			mob_reference.followcatch = followcatch
			mob_reference.angercatch = angercatch
			mob_reference.current_area = usr.GetArea()
			if(mob_reference.current_area)
				mob_reference.current_area.my_npc_list |= mob_reference
				mob_reference.current_area.my_mob_list |= mob_reference
			return TRUE

		level_poll()
			set background = 1
			set waitfor = 0
			if(mob_reference)
				if(mob_reference.attacking)
					if(prob(50)) gain_exp(1)
			if(linked_mob_age < Year)
				gain_exp(5 * Year - linked_mob_age)
			spawn(5) level_poll()
	verb
		Upgrade()
			set category = null
			set src in usr
			start
			update_linked_mob()
			switch(input(usr,"Whenever your creature levels up (by fighting or during aging) you get a stat boost. You have [leveledup] statboosts remaining. Where do you want to put the statboosts?","Companion Upgrading","Cancel") in list("Physicals","Ki","Misc","BP","Cancel"))
				if("Physicals")
					if(leveledup)
						leveledup--
						linked_phys_statboost++
						goto start
				if("Ki")
					if(leveledup)
						leveledup--
						linked_ki_statboost++
						goto start
				if("Misc")
					if(leveledup)
						leveledup--
						linked_misc_statboost++
						goto start
				if("BP")
					if(leveledup)
						leveledup--
						linked_bp_mod += 0.1
						upgrade_linked_mob_bp()
						goto start
				else return
			goto start
		Use()
			set category = null
			set src in usr
			spmct++
			spawn(10) spmct--
			if(spmct>1)return
			if(mob_reference)
				view(usr)<<"<font color=yellow>[mob_reference] disappears!</font>"
				usr.out_mobs-= mob_reference
				remove_linked_mob()
			else if(linked_mob_type && usr.out_mobs.len <= 1)
				last_sig = usr.signature
				if(add_linked_mob())
					view(usr)<<"<font color=yellow>[mob_reference] appears!!</font>"
					mob_reference.owner_ref = usr
					mob_reference.cur_own_sig = usr.signature
					mob_reference.murderToggle = usr.murderToggle
					usr.out_mobs+= mob_reference
			else usr<<"No creature type linked or too many creatures out! For blank companion shards, link them using a knocked out creature!"

		Remote_Update()
			set category = null
			set src in usr
			spmct++
			spawn(10) spmct--
			if(spmct>1)return
			if(mob_reference)
				switch(input(usr,"What command? \"Stop\" will cause the creature to lose a target and go back to you. Update BP will require 10000 and one food item.","","Cancel") in list("Update Murdertoggle","Update stats","Stop"))
					if("Update Murdertoggle") mob_reference.murderToggle = usr.murderToggle
					if("Update stats") update_linked_mob()
					if("Update BP")
						var/list/foodstuffs = list("Cancel")
						for(var/obj/items/food/nF in usr.contents)
							foodstuffs += nF
						var/obj/items/food/cF = input(usr,"Choose the foodstuffs.") in usr.contents
						if(cF != "Cancel" && usr.zenni >= 10000)
							cF.removeAmount(1)
							usr.zenni -= 10000
							upgrade_linked_mob_bp()
					if("Stop")
						mob_reference.target = null
						mob_reference.resetState()
			else usr<<"No creature out!"
		Info()
			set category = null
			set src in view(1)
			if(linked_mob_name)
				usr << "<font color=orange>[linked_mob_name] is a [linked_mob_type] type creature. It's BP is [linked_mob_bp] with a [linked_bp_mod]x BP modifier.</font>"
				usr << "<font color=orange>[linked_mob_name]'s' relation/intelligence is [linked_mob_relation["[usr.signature]"]]/[linked_mob_intelligence]. (A bigger number is good.)</font>"
				usr << "<font color=orange>[linked_mob_name] has [linked_phys_statboost] boosts to its Physicals.</font>"
				usr << "<font color=orange>[linked_mob_name] has [linked_ki_statboost] boosts to its Ki.</font>"
				usr << "<font color=orange>[linked_mob_name] has [linked_misc_statboost] boosts to its Misc. (Train mods.)</font>"
				usr << "<font color=orange>[linked_mob_name]'s level is [linked_mob_lvl]/[linked_mob_max_lvl] with [linked_mob_exp] exp.</font>"
			else
				usr << "<font color=orange>[name]: Get a creature type in this!"

//----
//now companion AI states
mob/npc/pet
	AIAlwaysActive = 0 //we use this 'empty' variable to our advantage- normally it's just there to check a few things, but we're overwriting that.
	murderToggle=0
	var/f_keep_dist = 2 //convinence's sake- keep the mob from moving if its under this follow distance from the owner.
	var/list/relation = list()
	var/cur_own_sig = 0
	var/setting=1 //1 for follow, 0 for stay.
	var/tmp/mob/owner_ref = null
	var/tmp/obj/items/item_Targ = null
	var/obj/items/companion_obj/comp_obj_ref = null
	var
		default_title = "Master"
		use_name = 0
		shutup = 0
		list/attackcatch = list("HIYA!","Get bent!","HA!", "You should have never come here!","Aww, did someone steal your sweetroll?")
		list/idlecatch = list("Boooored...","*sighs*","Five six seven eight...","%M%, are we going to do anything?")
		list/followcatch = list("Where are we going, %M%?","What a interesting place...")
		list/angercatch = list("DAMN IT!","Piece of shit!!","Bastard!")

		tmp
			is_following = 0

	//as for what activates the AI- thats up to each pet 'type'.
	//new companion AI shits
	proc
		pickupItem()
			if(!owner_ref) return
			if(isnull(item_Targ)) return
			var/d = get_dist(src,item_Targ)
			while(item_Targ in range(5) && d > 1)
				d = get_dist(src,item_Targ)
				step_towards(src,owner_ref)
				sleep(chase_speed*2)
			d = get_dist(src,item_Targ)
			if(d == 1 && item_Targ in range(1))
				item_Targ.Get()

		AI_State_Loop()
			set background = 1
			if(Anger>100) Anger-=((MaxAnger-100)/7500)
			if(Anger<100) Anger=100
			AIRunning=1
			if(StoredAnger>=80)
				Anger+=MaxAnger/100
				StoredAnger--
			stamina = min(maxstamina,stamina+0.25)
			if(techmod >= 7 && (!rand(0,300) && shutup==0) || (shutup > 1 && !rand(0,300*shutup))) random_catch()
			if(!rand(0,999) && behavior_vals[1] > 45 && behavior_vals[2] < 55) relation["[cur_own_sig]"]++
			if(!AIAlwaysActive)
				spawn follow_state()
				spawn(15) AI_State_Loop()
				return //only process stats when we're attackin n shit
			else
				spawn(10) AI_State_Loop()
			if(prob(10)) checkState()
			if(!rand(0,450) && behavior_vals[1] > 45 && behavior_vals[2] < 55) relation["[cur_own_sig]"]++
			if(IsInFight) Anger = max(100 * (behavior_vals[2]/50),Anger)
			if(Anger>MaxAnger*10) Anger=MaxAnger*10
			if(Anger<(((MaxAnger-100)/5)+100)) Emotion="Calm"
			if(Anger>(((MaxAnger-100)/5)+100)) Emotion="Annoyed"
			if(Anger>(((MaxAnger-100)/2.5)+100)) Emotion="Slightly Angry"
			if(Anger>(((MaxAnger-100)/1.66)+100)) Emotion="Angry"
			if(Anger>(((MaxAnger-100)/1.25)+100)) Emotion="Very Angry"
			if(CurrentAnger!=Emotion)
				CurrentAnger=Emotion
				view(usr)<<"<font color=#FF0000>[usr] appears [Emotion]"

		follow_state()
			//set waitfor=0
			if(!owner_ref) return
			if(setting != 1) return
			if(is_following) return
			is_following=1
			var/d = get_dist(src,owner_ref)
			while(owner_ref && d > f_keep_dist + 1)
				d = get_dist(src,owner_ref)
				if((owner_ref.z != z || d > 60) && prob(50))
					loc = owner_ref.loc
				step_towards(src,owner_ref)
				sleep(chase_speed)
			is_following = 0

		get_pissed()
			set waitfor = 0
			Do_Anger_Stuff()
			Emotion = "Very Angry"
			Anger = MaxAnger * 4 //400% PISSED
			behavior_vals_t[2] += 10 * behavior_vals_m[2]
			view(10,src) << "<font color=red size=3>[src] gets EXTREMELY ANGRY!!</font>"
			if(BP > 10000)
				for(var/mob/M in viewers(src))
					if(M.client) M.Quake()
				for(var/turf/T in view(src))
					if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,4)
					else if(prob(5)) spawn(rand(10,150)) createLightningmisc(T,2)
					else if(prob(15)) spawn(rand(10,150)) createDustmisc(T,2)
	//old overwrites
	mobDeath()
		if(client || Player) return
		var/obj/Zenni/A=new/obj/Zenni
		A.zenni = rand(100,4000)
		A.name="[num2text(A.zenni,20)] zenni"
		A.icon_state="Zenni4"
		A.loc = locate(src.x,src.y,src.z)
		globalNPCcount-=1
		comp_obj_ref.remove_linked_mob()
	New()
		..()
		Pet_list += src
		initialState()
		AI_State_Loop()
	Del()
		Pet_list -= src
		..()
	deleteMe()
		..()
		Pet_list -= src
	NPCTicker()
		AIRunning=1
		NPCAscension()
		return
	foundTarget(mob/c)
		if(!src.target && src.hasAI && !client)
			src.attackable=1
			src.target = c
			aggro_loc = src.loc
			AIAlwaysActive=1
			is_following=0
			src.chaseState()
	lostTarget()
		resetState()
		return
	attackState()
		set waitfor=0
		var/d
		while(src.target.HP>0 && src.hasAI)
			d = get_dist(src,target)
			//if the Target is too far away, chase
			if(d>src.keep_dist)
				chaseState()
				return
			if(src.target.KO&&!src.murderToggle)
				break
			if(zanzoAI && prob(5))
				randattackState()
				return
			if(isBlaster && prob(4))
				strafeState()
				return
			if(!prob(relation["cur_own_sig"]))
				if(HP <= HP - e_behavior_vals[1])//fear
					runawayState()
					return
				if(e_behavior_vals[3]>=75 && target.HP <= 40)
					resetState()//no longer fight if kind and target is damaged sufficiently
					return
			//if the Target is too close, avoid
			checkState()
			if(totalTime >= OMEGA_RATE)
				if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
				totalTime -= OMEGA_RATE
				if(d<src.keep_dist)
					//if the path is blocked, take a random step
					. = step_away(src,target)
					if(!.)
						step_rand(src)
				//if we are eligible to attack, do it.
				if(attacking)
					next_attack++
				if(world.time>=next_attack)
					attack()
			sleep(chase_speed)

		//when the loop is done, we've lost the Target
		src.lostTarget()
	chaseState()
		set waitfor=0
		var/d = get_dist(src,target)
		var/blastbreak = 0
		var/dashBreak = 0
		while(d>keep_dist && src.hasAI)
			//if the Target is out of range or dead, bail out.
			if(get_dist(aggro_loc,src)>aggro_dist*2||(src.target.KO&&!src.murderToggle))
				src.lostTarget()
				return 0
			if((e_behavior_vals[1] > 35 || e_behavior_vals[2] >= 75) && monster)
				if(isBlaster && blast_dist >= d && prob(15))
					blastbreak = 1
					break
				if(d <= 10 && d >= 3 && prob(10))
					dashBreak = 1
					break
				//if the path is blocked, take a random step
				checkState()
				if(totalTime >= OMEGA_RATE)
					if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
					totalTime -= OMEGA_RATE
					. = step(src,get_dir(src,target))
					if(!.)
						if(prob(45))
							for(var/turf/T in get_step(src,dir))
								var/turf/nT = get_step(T,dir)
								if(nT.x && nT.y && nT.z && !nT.density)
									emit_Sound('buku.wav')
									loc = locate(nT.x,nT.y,nT.z)
									break
						else
							step_rand(src)
							break
			else
				if(d<=aggro_dist*2)
					//if the path is blocked, take a random step
					checkState()
					if(totalTime >= OMEGA_RATE)
						if(totalTime > MAXIMUM_TIME) totalTime = MAXIMUM_TIME
						totalTime -= OMEGA_RATE
						. = step(src,get_dir(target,src))
						if(!.)
							step_rand(src)
			sleep(chase_speed)
			d = get_dist(src,target)
		if(blastbreak)
			blast()
			spawn(1)
				chaseState()
		else if(dashBreak)
			attack()
			spawn(3)
				chaseState()
		else
			attackState()
		return 1


	resetState()
		set waitfor=0
		if(!owner_ref) deleteMe()

		var
			//allow us longer than it should take to get home via distance
			returntime = world.time + get_dist(src,owner_ref.loc) * (3 + chase_speed)
		while(world.time<returntime&&src.loc!=owner_ref.loc)
			//if the path is blocked, take a random step
			. = step(src,get_dir(src,owner_ref.loc))
			if(!.)
				step_rand(src)
				sleep(chase_speed)

		//src.target = null
		src.aggro_loc = null
		//src.attackable = 0
		IsInFight = 0
		//if(KO) spawn Un_KO()
		if(grabber)
			grabber.grabbee=null
			grabber.attacking=0
			grabber.canfight=1
		grabber=null
		//grabberSTR=null
		//grabParalysis = 0
		for(var/a, a<= behavior_vals.len,a++)//reset behavior pools
			behavior_vals_t[a] = 0
			e_behavior_vals[a] = 0
		//SpreadHeal(150,1,1)
		for(var/datum/Body/B in body)
			if(B.lopped) B.RegrowLimb()
			B.health = B.maxhealth
		AIAlwaysActive=0
		is_following=0
		//Ki=MaxKi
		//stamina=maxstamina
