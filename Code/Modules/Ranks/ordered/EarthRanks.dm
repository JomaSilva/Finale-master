datum/skill/tree/Rank/Earth
	name = "Earth Tree"
	desc = "Iconic Skills based on Martial Arts."
	maxtier = 6
	allowedtier = 6
	tier=1
	constituentskills = list(new/datum/skill/rank/Keep_Body,new/datum/skill/rank/Dead,\
		new/datum/skill/general/splitform,new/datum/skill/general/kikoho,\
		new/datum/skill/rank/Fusion_Dance,new/datum/skill/rank/Kamehameha,new/datum/skill/rank/MakeDragonballs,\
		new/datum/skill/rank/Permission,new/datum/skill/rank/Grow_Senzu,new/datum/skill/rank/Taxes,new/datum/skill/flying/CraneFly,\
		new/datum/skill/style/KameStyle,new/datum/skill/style/CraneStyle, new/datum/skill/rank/Mafuba,new/datum/skill/rank/DeadZone,\
		new/datum/skill/rank/SuperiorSeal,new/datum/skill/ki/Heal,new/datum/skill/Telepathy,new/datum/skill/rank/Dodompa)//earth-based rank skills
	enabled = 0
	can_refund = FALSE

datum/skill/tree/Rank/Earth/growbranches()
	if(savant.Rank!="Earth Guardian") disableskill(/datum/skill/Telepathy)
	switch(savant.Rank)
		if("Earth Guardian")
			enableskill(/datum/skill/style/GodStyle)
			enableskill(/datum/skill/rank/MakeDragonballs)
			enableskill(/datum/skill/rank/Permission)
			enableskill(/datum/skill/rank/Keep_Body)
			enableskill(/datum/skill/rank/Dead)
			enableskill(/datum/skill/rank/Makkankosappo)
			enableskill(/datum/skill/rank/SuperiorSeal)
			enableskill(/datum/skill/rank/DeadZone)
			enableskill(/datum/skill/general/observe)
			enableskill(/datum/skill/Telepathy)
			enableskill(/datum/skill/ki/Heal)
		if("Earth Assistant Guardian")
			enableskill(/datum/skill/rank/Grow_Senzu)
			enableskill(/datum/skill/rank/Permission)
			enableskill(/datum/skill/rank/SuperiorSeal)
			enableskill(/datum/skill/ki/Heal)
		if("Turtle")
			enableskill(/datum/skill/style/KameStyle)
			enableskill(/datum/skill/rank/Kamehameha)
			enableskill(/datum/skill/rank/Mafuba)
		if("Crane")
			enableskill(/datum/skill/style/CraneStyle)
			enableskill(/datum/skill/general/splitform)
			enableskill(/datum/skill/general/kikoho)
			enableskill(/datum/skill/flying/CraneFly)
			enableskill(/datum/skill/rank/Dodompa)
		if("President")
			enableskill(/datum/skill/rank/Taxes)
	savant.LastRank=savant.Rank
	..()

/datum/skill/flying/CraneFly
	desc = "The Crane school has a special method of flight that is much easier for beginners to learn."
	can_forget = FALSE
	common_sense = TRUE
	teacher=TRUE
	tier = 2
	skillcost=0
	enabled=0

/datum/skill/rank/Mafuba
	skilltype = "Magic"
	name = "Mafuba"
	desc = "Mafuba is a pretty deadly skill. In exchange for most of your life, (90%) you'll seal someone permanently inside a dummy jar. They can't escape the beam very easily, but if the container ever were to get damaged, the sealed will easily break free."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 3
	skillcost=1
	enabled=0

/datum/skill/rank/DeadZone
	skilltype = "Magic"
	name = "Open Dead Zone"
	desc = "The Dead Zone is a area where all sealed people go to. If your soul vanishes from existance, the Dead Zone is where you go. Open up a portal to the extreme Void, dragging any unfortunate soul into its depths. Whether or not the person can regain freedom is dependent on your power when opening up the tear."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 6
	skillcost=3
	enabled=0

/datum/skill/rank/SuperiorSeal
	skilltype = "Magic"
	name = "Superior Seal"
	desc = "Seal a target person inside a object or another person. Objects are haphazard, and can be broken by power leakage easily. People, on the other hand, can contain it. The sealed can break free should the lifeform in question ever die, or can weaken the seal by seeping through the persons anger."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 4
	skillcost=2
	enabled=0


mob/var/permission=0
/datum/skill/rank/Permission
	skilltype = "Misc"
	name = "Give Permission"
	desc = "Give permission to a person to use the facilities of the Lookout."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=0
	enabled=0

/datum/skill/rank/Permission/after_learn()
	assignverb(/mob/Rank/verb/Permission)
	savant<<"You give permissions."
/datum/skill/rank/Permission/before_forget()
	unassignverb(/mob/Rank/verb/Permission)
	savant<<"You've forgotten how to give permission?"
/datum/skill/rank/Permission/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Permission)

/datum/skill/rank/Grow_Senzu
	skilltype = "Misc"
	name = "Inbue Bean"
	desc = "Inbue a Bean with magical water-life-energy, becoming enriched with energy. It'll heal and feed pretty darn well."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1
	skillcost=1
	enabled=0

/datum/skill/rank/Grow_Senzu/after_learn()
	assignverb(/mob/Rank/verb/Grow_Senzu_Bean)
	savant<<"You can make a bean!"
/datum/skill/rank/Grow_Senzu/before_forget()
	unassignverb(/mob/Rank/verb/Grow_Senzu_Bean)
	savant<<"You've forgotten how to make beans!?"
/datum/skill/rank/Grow_Senzu/login(var/mob/logger)
	..()
	assignverb(/mob/Rank/verb/Grow_Senzu_Bean)


mob/Rank/verb/Permission(mob/M in view(6))
	set category="Other"
	switch(input("Give permission for [M] to enter the tower and/or HBTC?", "", text) in list ("Tower","Tower and HBTC","Neither",))
		if("Tower")
			usr<<"You give [M] permission to enter the tower"
			M.permission=2
		if("Tower and HBTC")
			usr<<"You give [M] permission to use the HBTC"
			M.permission=1
		if("Neither")
			usr<<"You deny [M] permission to enter the tower or use the HBTC"
			M.permission=0

obj/Portal_Jar
	icon='props.dmi'
	icon_state="Closed"
	density=1
	var/open=0
	verb/Open_Jar()
		set category="Other"
		set src in oview(1)
		if(usr.key==Assistant_Guardian|usr.key==Earth_Guardian)
			if(!open)
				open=1
				icon_state="Open"
				view(9)<<"[usr] opens the jar."
				sleep(600)
				icon_state="Closed"
				open=0
		else usr<<"You cant seem to open it, its locked by magic or something."
	verb/Enter_Jar()
		set category="Other"
		set src in oview(1)
		if(open)
			view(9)<<"[usr] gets in the jar and is whisked away into another world."
			usr.loc=locate(150,150,24)
		else usr<<"You cant get in the jar, its closed."
mob/var/sacredwater
obj/Sacred_Water
	name="Sacred Water"
	icon='props.dmi'
	icon_state="Closed"
	density=1
	verb/Drink()
		set category = null
		set src in oview(1)
		if(!usr.sacredwater)
			if(prob(50)||usr.Ephysdef>=1)
				usr.sacredwater=1
				usr<<"You drink the Sacred Water..."
				sleep(30)
				usr<<"Somethings happening..."
				sleep(30)
				usr<<"Hm, guess it was nothing!"
				sleep(30)
				usr<<"Suddenly you fall over and feel as if you have been hit by a brick."
				usr.KO(null,1)
				sleep(300)
				usr.Un_KO()
				usr<<"You wake up in Korin's Tower where you started and feel hurt."
				usr<<"The fact that you feel so bad proves it wasnt a dream I guess."
				sleep(30)

				usr<<"<font color=yellow>!!*Stamina has increased*!!"
				usr.maxstamina *=1.2
				if(usr.BP<usr.relBPmax)
					usr.BP+=usr.capcheck(usr.BPMod*usr.relBPmax)/5
					usr<<"<font color=yellow>!!*Battle Power has increased*!!"
				else
					usr<<"<font color=yellow>You're too strong to get anything out of the water..."

			else
				usr<<"You drink the Sacred Water..."
				sleep(30)
				usr<<"Somethings happening..."
				sleep(30)
				usr<<"Hm, guess it was nothing!"
				sleep(30)
				usr.Death()
				usr<<"The Sacred Water suddenly kills you!"
		else
			usr<<"You drink the sacred water... Nothing happens."
			usr<<"You've already drunk the sacred water. To you, this is now just regular water that tastes faintly of cat pee. Ugh."
	verb/Description()
		set src in oview(1)
		set category = null
		usr<<"The Sacred Water jar increases your BP and maximum stamina, however you must be above a certain level of durability to use it. Else, you have a 50% chance of dying."
		usr<<"In future updates, the knockout may transport you to a dreamworld where that will decide your fate instead..."
mob/ETax/verb
	Earth_Taxes()
		set category="Other"
		usr<<"Earth's Taxe rates are at [EarthTax]z."
		var/Mult=input("Enter a number for tax rate. This will increase or decrease across Earth. (1 = 1z)") as num
		EarthTax=Mult
	Collect_Earth_Taxes()
		set category="Other"
		usr<<"Earth's bank has [EarthBank]z."
		var/Mult=input("Enter a number to deduct from the bank. (1 = 1z)") as num
		if(Mult<=EarthBank)
			EarthBank-=Mult
			usr.zenni+=Mult
	Exempt_Earth_Taxes(mob/M in world)
		set category="Other"
		M.ETaxExempt=1