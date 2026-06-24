mob/var
	dashing=0
	rapidmovement=0
	flightability=1
	flying=0
	RushComplete=0
	tmp
		mob/target= null
		dashtired=0
		lariatCD=0
		candash=1
mob/default/verb
	Select_Target()
		set category="Skills"
		var/mob/list/Targets=new/list
		for(var/mob/M in oview(16)) Targets.Add(M)
		Targets += "Cancel"
		Targets += "Nobody"
		var/Choice=input("Focus your attacks on who?") in Targets
		if(Choice == "Cancel")
			return
		if(Choice == "Nobody") usr.target=null
		usr.target=Choice
		usr << "Your target is now [Choice]"
mob/verb
	Set_Target()
		set category=null
		set src in view(30)
		usr.target=src
		if(usr != src)
			usr<<"Your target is now [src]."

mob/default/verb
	Dash()
		set category="Skills"
		if(candash)
			if(dashing==0)
				dashing=1
				candash=0
				sleep(15)
				candash=1
			else
				dashing=0
				candash=0
				sleep(15)
				candash=1
		else src<<"You can't do that yet."
mob/verb
	SttDash()
		set hidden = 1
		//if(!candash)
		//	sleep(15)
		if(dashing==0  && candash == 1)
			dashing=1
			candash=0
			//sleep(15)
			//candash=1
	StopDash()
		set hidden = 1
		//set category="Skills"
		//if(!candash)
		//	sleep(15)
		//if(dashing==1)
		//	dashing=0
		//	candash=0
		//	sleep(15)
		//	candash=1
		dashing = 0
		candash = 1


//TIERED SKILLS//
//see: Modules/Multi-Stage Moves/skill.dm

/datum/skill/rapidmovement
	skilltype = "Physical" //is it Physical, Ki, or Magic? Not currently used.
	name = "Rapid Movement"
	desc = "The user pumps excess Ki into their nerves and muscles in equal measures to obtain radically increased speed."
	level = 0 //The initial level of the skill is 0.
	expbarrier = 100 //It takes 100 exp to go from 0 to 1 or 1 to 2, but
	maxlevel = 1 //it can only reach level 1.
	can_forget = TRUE //The skill can be refunded.
	common_sense = TRUE //The skill can bypass racial limitations, or in some cases, prereqs.
	tier = 1 //The skill will be listed on page 1 of its tree.
	enabled=0 //You must learn a skill before enabling this to be learned.
	skillcost=2 //The skill costs 2 skillpoinrs.
	prereqs = list() //You must learn "" to enable the skill.
	var/tmp/lastdir = 0 //a unique var for rapidmovement - tmp to avoid wasteful storage

	effector() //The process' loop, handled in Unitimer.
		..() //always include
		switch(level) //this is your most standard operator
			if(0)
				if(levelup == 1) //Standard Level loop - try to implement them unless shenanigans.
					levelup = 0
				if(savant.dir != lastdir) exp += 1 //Wow, I just spin a bunch and get faster?
				lastdir = savant.dir
			if(1)
				if(savant.dir != lastdir) exp += 1 //Wow, I just spin a bunch and get faster?
				lastdir = savant.dir
				expbarrier = 1000
				if(levelup == 1)
					savant << "You've finished familiarizing yourself with your new speed. What if you add some Ki?"
					levelup = 0
					assignverb(/mob/keyable/verb/Rapid_Movement)
			if(2)
				if(levelup == 1)
					savant << "You've become even faster, capable of moving around an enemy after dashing into them."
					levelup = 0
					assignverb(/mob/keyable/verb/Zanzoken_Dash)
	login(var/mob/logger) //Don't forget to refresh all conditional/nonrepeating verbs!
		..()
		if(level >= 1) assignverb(/mob/keyable/verb/Rapid_Movement)
		if(level >= 2) assignverb(/mob/keyable/verb/Zanzoken_Dash)

	before_forget() //What should happen if they forget it?
		savant.speed-=0.1
		if(level>0)
			unassignverb(/mob/keyable/verb/Rapid_Movement)
			unassignverb(/mob/keyable/verb/Zanzoken_Dash)
			usr << "You feel dumber."
	after_learn() //What should happen if they learn it?
		savant.speed+=0.1
		switch(level)
			if(0) savant << "You feel as though you could go even faster, if only you knew how..."
			if(1) assignverb(/mob/keyable/verb/Rapid_Movement)
			if(2) assignverb(/mob/keyable/verb/Zanzoken_Dash)


mob/keyable/verb
	Rapid_Movement()
		set category="Skills"
		rapidProc()
	Zanzoken_Dash()
		set category="Skills"
		rapidmovement = 1
		rapidProc()
		rapidmovement = 0

mob/proc/rapidProc()
	if(usr.dashtired)
		usr << "You can't use this right now. (Either the Lariat is happening, or the dash cooldown is going.)"
	var/kiReq = 10*BaseDrain/(speed)
	if(usr.Ki>=kiReq&&usr.target&&usr.target!=usr&&get_dist(usr,usr.target)<20&&!usr.KO&&!usr.dashtired)
		usr.Ki-=kiReq*BaseDrain
		usr.emit_Sound('chainswoop.wav')
		usr << "You pump Ki into your body and accelerate rapidly towards [usr.target]."
		//rapidmovement=1
		step(src,get_dir(src,src.target))
		step(src,get_dir(src,src.target))
		step(src,get_dir(src,src.target))
		//src.hug=1
		//spawn(1) combathug(src.target,src)
		//spawn(5) src.testRM()
		//rapidmovement=0
	if(!usr.target||get_dist(usr,usr.target)>=20||usr.target==usr)
		usr << "You need a valid target..."

mob/proc/testRM()
	while(1)
		if(src.hug==0)
			src.stopDashing()
			break
		sleep(1)
mob/proc/stopDashing()
		usr << "You stop flitting around."
		usr.dashtired=1
		var/timer=200/usr.speed
		spawn(timer)
				if(timer>15)usr<<"You're ready to use Rapid Movement again."
				usr.dashtired=0

mob/keyable/verb
	Lariat()
		set category="Skills"
		var/staminaReq = angerBuff*1.5/(Ephysoff+Etechnique)*BaseDrain
		if(usr.Ki>=staminaReq&&usr.target&&usr.target!=usr&&get_dist(usr,usr.target)<35&&!usr.KO&&!usr.dashtired)
			usr << "You ignite your energy and launch into a rush attack!"
			Ki-=staminaReq
			usr.dashtired=1
			RushAttack(target)
			emit_Sound('ARC_BTL_CMN_DrgnRush_Start.ogg')
			while(RushComplete==0)
				sleep(0.1)
			if(get_dist(src,target)>1&&canmove)
				step(src,get_dir(src,target))
			if(get_dist(src,target)>1)
				src<<"Your rush failed..."
			else
				for(var/mob/M in view(3))
					M<<"[src] slams into [target]!"
				emit_Sound('ARC_BTL_CMN_DrgnRush_Fnsh.ogg')
				usr.icon_state="Attack"
				spawn(3) usr.icon_state=""
				usr.MeleeAttack(15)
			sleep(30)
			usr.dashtired=0
		else if(!usr.target||get_dist(usr,usr.target)>=12||usr.target==usr)
			usr << "You need a valid target..."
		else if(usr.Ki<=staminaReq)
			usr << "You need at least [staminaReq] Ki to use this skill."

mob/proc/RushAttack(var/mob/M,speed_mult)
	RushComplete=0
	if(!speed_mult) speed_mult = 1
	var/rushSpeed=round(0.4*move_delay*speed_mult,0.1)
	var/justincase=0
	var/flighted = 0
	if(flightability > 1 && do_dash)
		flighted = 3
		if(!flight)
			flighted=1
			start_flying()
			start_superflight()
		else if(!flightspeed)
			flighted=2
			start_superflight()
	while(get_dist(src,M)>1)
		justincase+=1
		if(!canmove)
			src<<"Your rush fails since you can't move!"
			RushComplete=1
			break
		step(src,get_dir(src,M))
		if((justincase==45 && !flighted)||justincase==50)
			src<<"All this running is exhausting..."
			RushComplete=1
			break
		sleep(rushSpeed)
	switch(flighted)
		if(1)
			stop_superflight()
			stop_flying()
		if(2)
			stop_superflight()
	RushComplete=1