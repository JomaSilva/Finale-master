/datum/skill/tree/namek
	name="Namek Racials"
	desc="Given to all Nameks at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Namekian","Albino Namekian")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/namek/bigform,new/datum/skill/demon/soulabsorb,new/datum/skill/general/materialization,new/datum/skill/general/regenerate,\
	new/datum/skill/namek/fusion,new/datum/skill/namek/SuperNamek,new/datum/skill/namek/Stretchy_Arms)
mob/var/hassoulabsorb=1
/datum/skill/tree/namek/effector()
	if(savant.hassoulabsorb&&savant.Race=="Namekian"&&savant.Class!="Albino Namekian")
		disableskill(/datum/skill/demon/soulabsorb)
		savant.hassoulabsorb = 0
	..()
/datum/skill/namek/SuperNamek
	skilltype = "Form"
	name = "Super Namekian"
	desc = "Unlock what you might call \"Peak Namekian Perfection!\"! You need to be around two million in order to use this."
	can_forget = FALSE
	common_sense = FALSE
	tier = 2
	skillcost=2
	after_learn()
		savant.snamek=1
		savant<<"Power up past two million and let the sparks fly, baby!"

/datum/skill/namek/fusion
	skilltype = "Form"
	name = "Fusion- Namek Style"
	desc = "Ask someone if they'd like to fuse. If so, they will recieve your power and you will be sent to the Sealed Realm."
	can_forget = FALSE
	common_sense = FALSE
	skillcost=2
	tier = 2
	login(var/logger)
		..()
		assignverb(/mob/keyable/verb/Namekian_Fusion)
	after_learn()
		assignverb(/mob/keyable/verb/Namekian_Fusion)
		savant<<"You can fuse!"

	before_forget()
		unassignverb(/mob/keyable/verb/Namekian_Fusion)
		savant<<"You can't fuse!"

/datum/skill/namek/Stretchy_Arms
	skilltype = "Form"
	name = "Stretchy Arms"
	desc = "Unleash your inner Gumby... by pressing grab, if you have a target, your arms will track down your foe and keep them still while you can freely move around."
	can_forget = FALSE
	common_sense = FALSE
	tier = 2
	skillcost=1
	after_learn()
		savant.can_stretch_arms=1
		savant<<"Target a opponent, press grab, and your arms will fly at them! Block (alt) to let go, grab to bring them towards you, attack to do a grab-attack, turning the grab into a regular grab."

mob/var
	can_stretch_arms = 0

	tmp
		is_stretched = 0
		stretch_bring = 0

mob/proc/stretch_arms(var/mob/M)
	set waitfor = 0
	is_stretched = 1
	grabMode = 2
	grabParalysis = 1
	var/grabbedsucc = 0
	var/obj/attack/namek_arm/nA = new
	nA.icon = 'namekarm.dmi'
	nA.icon_state = "end"
	var/i
	while(!blocking)
		i++
		if(i>25) break
		var/d = get_dist(M.loc,nA.loc)
		if(d>1) step_towards(nA,M,20)
		else
			M.grabParalysis = 1
			grabbedsucc = 1
			break
		sleep(1)
	if(grabbedsucc)
		M.grabberSTR = (Ephysoff*expressedBP) / 3
		M.grabber = src
		grabbee = M
		var/bringing =0
		while(M.grabParalysis && !blocking && grabbee)
			if(stretch_bring && !bringing)
				bringing = 1
				spawn
					var/rushSpeed=round(0.3*move_delay,0.1)
					var/justincase=0
					while(get_dist(src,M)>1 && grabbee)
						justincase+=1
						if(!canmove)
							src<<"You're unable to move them any closer!"
							break
						step(M,get_dir(M,src))
						if(justincase==50 || !grabbee)
							src<<"You're unable to move them any closer!"
							break
						sleep(rushSpeed)
					stretch_bring = 0
					bringing = 0
			if(KO||grabbee.z!=usr.z||totalTime==0)
				view()<<"[usr] is forced to release [grabbee]!"
				emit_Sound('groundhit2.wav')
				grabbee.grabberSTR=null
				grabbee.attacking=0
				//grabbee.canfight=1
				grabbee.grabParalysis = 0
				is_choking = 0
				grabMode=0
				//canfight=1
				attacking=0
				grabbee=null
				grabbee.grabber = null
				break
	grabMode = 0
	grabParalysis = 0
	is_stretched = 0
	del(nA)
obj/attack/namek_arm
	var/didmydirchange
	Move()
		var/oldloc = loc
		didmydirchange = dir
		if(..())
			var/obj/attack/namek_arm = new(oldloc)
			namek_arm.icon = 'namekarm.dmi'
			if(didmydirchange != dir)
				if(dir == turn(didmydirchange,90)) namek_arm.icon_state = "right turn"
				if(dir == turn(didmydirchange,-90)) namek_arm.icon_state = "left turn"
			else namek_arm.icon_state = ""

